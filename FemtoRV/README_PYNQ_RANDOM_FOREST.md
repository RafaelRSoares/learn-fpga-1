# FemtoRV + Random Forest na PYNQ-Z2

Este documento descreve o processo de adaptação do FemtoRV para a placa PYNQ-Z2 e a integração de um acelerador de Random Forest ao processador RISC-V. O objetivo foi validar uma arquitetura em que o núcleo RISC-V controla a execução, enquanto a inferência da Random Forest é executada em hardware.

A implementação final usa o FemtoRV32 Quark como processador, a placa PYNQ-Z2 como plataforma FPGA e um módulo `random_forest.v` conectado ao datapath por meio de instruções customizadas.

## 1. Objetivo

O objetivo do experimento foi implementar e validar uma Random Forest acelerada em hardware, controlada por um processador RISC-V na PYNQ-Z2.

A arquitetura final segue o fluxo:

```text
Python / scikit-learn
        ↓
Treinamento da Random Forest
        ↓
Exportação dos nós da floresta
        ↓
Firmware C
        ↓
Instruções customizadas RISC-V
        ↓
FemtoRV32 Quark
        ↓
Módulo random_forest.v
        ↓
Predição em hardware
```

O RISC-V não executa a Random Forest em software. Ele atua como controlador, enviando dados, iniciando a inferência e lendo o resultado. A classificação é feita pelo módulo de hardware `random_forest.v`.

## 2. Plataforma usada

A plataforma usada foi:

```text
Placa: PYNQ-Z2
FPGA: Zynq-7020
Ferramenta: Vivado 2023.1
Processador softcore: FemtoRV32 Quark
Clock interno do SoC: 50 MHz
Firmware: C bare-metal compilado para RV32I
```

A PYNQ-Z2 fornece um clock de entrada de 125 MHz. Para deixar o projeto mais estável, foi usado o Clocking Wizard do Vivado para gerar um clock interno de 50 MHz para o FemtoRV.

## 3. Adaptação inicial do FemtoRV para PYNQ-Z2

A primeira etapa foi portar o FemtoRV para a PYNQ-Z2 e validar que o processador conseguia executar firmware.

Foi usada uma configuração mínima do SoC:

```verilog
`define NRV_IO_LEDS
`define NRV_IO_HARDWARE_CONFIG
`define NRV_FEMTORV32_QUARK

`define NRV_FREQ 50
`define NRV_RAM 65536
`define NRV_RESET_ADDR 0
`define NRV_ADDR_WIDTH 24

`define NRV_CONFIGURED
```

Inicialmente, periféricos como UART, OLED, SPI Flash e MAX7219 foram desativados para reduzir a complexidade do projeto.

Os LEDs da PYNQ-Z2 foram mapeados para as saídas `D1`, `D2`, `D3` e `D4` do FemtoSoC. A saída `D5` foi usada como indicação de reset liberado.

## 4. Clock e reset

No começo, o clock da PYNQ foi usado diretamente:

```verilog
assign clk = pclk;
```

Depois, foi adicionado um Clocking Wizard para gerar 50 MHz a partir do clock externo de 125 MHz:

```verilog
wire clk;
wire pll_locked;

clk_wiz_0 clk_wiz_inst (
   .clk_out1(clk),
   .reset(1'b0),
   .locked(pll_locked),
   .clk_in1(pclk)
);
```

O reset foi implementado com um contador interno. O processador só sai de reset depois que o Clocking Wizard indica que o clock está estável:

```verilog
reg [20:0] reset_cnt = 0;
wire reset = &reset_cnt;

always @(posedge clk) begin
   if(RESET || !pll_locked) begin
      reset_cnt <= 0;
   end else if(!reset) begin
      reset_cnt <= reset_cnt + 1'b1;
   end
end
```

Esse reset também pode ser acionado pelo botão físico da PYNQ-Z2.

## 5. Validação do firmware básico

Antes de integrar a Random Forest, foi criado um firmware simples para controlar os LEDs.

A primeira versão corrigida usou a macro `LEDS(x)` do `femtorv32.h`:

```c
#include <femtorv32.h>

int main() {
    int x = 0;

    while(1) {
        LEDS(x);

        for(volatile int i = 0; i < 100000; i++) {
        }

        x++;
    }

    return 0;
}
```

Um erro importante corrigido nessa etapa foi entender que `IO_LEDS` é apenas o deslocamento do registrador de LEDs, e não o endereço absoluto. O endereço correto é:

```text
IO_BASE + IO_LEDS = 0x400000 + 0x4 = 0x400004
```

A forma correta de acessar os LEDs é:

```c
LEDS(x);
```

ou:

```c
IO_OUT(IO_LEDS, x);
```

Com isso, o FemtoRV foi validado executando firmware próprio na PYNQ-Z2.

## 6. Integração inicial da Random Forest por MMIO

O módulo `random_forest.v` foi inicialmente integrado como periférico memory-mapped. Foram criados dois registradores de IO:

```verilog
localparam IO_RF_ADDR_bit = 12;
localparam IO_RF_DATA_bit = 13;
```

O registrador `IO_RF_ADDR` seleciona qual registrador interno da Random Forest será acessado. O registrador `IO_RF_DATA` escreve ou lê o valor correspondente.

Foram definidos registradores internos para:

```text
RF_REG_STATUS  → estado/ready
RF_REG_RESULT  → resultado da classificação
RF_REG_FEAT0   → feature 0
RF_REG_FEAT1   → feature 1
RF_REG_FEAT2   → feature 2
RF_REG_FEAT3   → feature 3
RF_REG_TADDR   → endereço da memória da árvore
RF_REG_TMEM    → dado da memória da árvore
RF_REG_START   → início da inferência
```

Essa etapa validou que o RISC-V conseguia carregar árvores, enviar features, iniciar a inferência e ler o resultado por MMIO.

## 7. Instruções customizadas no FemtoRV32 Quark

Depois da validação por MMIO, o datapath do FemtoRV32 Quark foi modificado para reconhecer instruções customizadas usando o opcode `custom-0`.

Foi adicionado o sinal:

```verilog
wire isCUSTOM0 = (instr[6:2] == 5'b00010);
```

O atalho original usado para detectar `JAL` foi substituído por uma comparação explícita, para evitar conflito com instruções customizadas:

```verilog
wire isJAL = (instr[6:2] == 5'b11011);
```

O writeback da CPU foi estendido para permitir que uma instrução customizada escreva no registrador de destino:

```verilog
wire [31:0] writeBackData =
   (isSYSTEM            ? cycles       : 32'b0) |
   (isLUI               ? Uimm         : 32'b0) |
   (isALU               ? aluOut       : 32'b0) |
   (isAUIPC             ? PCplusImm    : 32'b0) |
   (isJALR   | isJAL    ? PCplus4      : 32'b0) |
   (isLoad              ? LOAD_data    : 32'b0) |
   (isCUSTOM0           ? custom_rdata : 32'b0);
```

Também foram exportados para o SoC os sinais:

```verilog
output       custom_valid,
output [2:0] custom_funct3,
output [31:0] custom_rs1,
output [31:0] custom_rs2
```

Esses sinais permitem que o SoC identifique qual instrução customizada está sendo executada e use os valores dos registradores `rs1` e `rs2`.

## 8. Mapeamento das instruções customizadas

Foi usado o campo `funct3` para selecionar a operação da Random Forest:

```text
funct3 = 000 → ler resultado da Random Forest
funct3 = 001 → ler status/ready
funct3 = 010 → iniciar classificação
funct3 = 011 → escrever feature0
funct3 = 100 → escrever feature1
funct3 = 101 → escrever feature2
funct3 = 110 → escrever feature3
funct3 = 111 → escrever nó da árvore
```

Com isso, o firmware passou a controlar a Random Forest usando instruções customizadas, em vez de MMIO comum.

As features são enviadas usando instruções customizadas que colocam o valor em `rs1`. A escrita de nós da árvore usa `rs1` como endereço e `rs2` como dado.

## 9. Formato dos nós da árvore

O módulo `random_forest.v` usa palavras de 32 bits para representar cada nó da árvore.

O formato usado foi:

```text
bits [31:29] → índice da feature
bits [28:16] → threshold
bits [15:8]  → classe esquerda
bits [7:0]   → classe direita
```

A função usada no firmware para empacotar um nó foi:

```c
static uint32_t pack_node(
    uint32_t feature,
    uint32_t threshold,
    uint32_t left_class,
    uint32_t right_class
) {
    return ((feature & 7) << 29)
         | ((threshold & 0x1FFF) << 16)
         | ((left_class & 0xFF) << 8)
         | (right_class & 0xFF);
}
```

## 10. Validação com árvore manual

Antes de usar uma floresta treinada, foi criada uma floresta manual simples para validar a lógica de classificação.

O teste classificava quatro entradas e deveria gerar a sequência:

```text
classe 0 → classe 1 → classe 2 → classe 3
```

Nos LEDs da PYNQ-Z2, isso apareceu como:

```text
LD0 → LD1 → LD2 → LD3
```

Esse teste confirmou que o módulo de Random Forest estava recebendo features, percorrendo os nós e retornando classes corretamente.

## 11. Treinamento da Random Forest em Python

Depois da validação manual, foi criado um script Python para treinar uma Random Forest no dataset Iris e exportar os nós para o formato aceito pelo hardware.

A floresta foi configurada com:

```text
4 árvores
profundidade máxima 3
15 nós por árvore
4 features
3 classes
```

Isso corresponde às constantes usadas pelo módulo de hardware:

```verilog
localparam TREE_COUNT = 4;
localparam DEPTH = 3;
localparam NODES_PER_TREE = 15;
```

O script gera automaticamente:

```text
rf_load_node(tree, node, data);
```

para cada nó da floresta.

Ele também exporta algumas amostras de teste para serem classificadas na FPGA.

## 12. Validação contra o scikit-learn

A floresta treinada foi exportada para o firmware e executada na PYNQ-Z2.

Foram classificadas 12 amostras do conjunto de teste Iris. O resultado do hardware foi:

```text
11 acertos em 12 amostras
```

Depois, o mesmo conjunto foi verificado no Python usando o modelo original do scikit-learn. O resultado também foi:

```text
11 acertos em 12 amostras
```

A amostra errada foi a mesma no hardware e no Python:

```text
X = [49, 25, 45, 17]
classe esperada = 2
classe prevista = 1
```

Isso indicou que o erro não estava na implementação em hardware, mas sim no próprio modelo treinado. Portanto, o FPGA reproduziu corretamente o comportamento do modelo do scikit-learn.

## 13. Medição de ciclos

O contador de ciclos do FemtoRV foi usado para medir o tempo de inferência.

A medição inicial indicou valores na ordem de:

```text
145 a 155 ciclos
```

Com clock interno de 50 MHz, cada ciclo dura:

```text
1 / 50 MHz = 20 ns
```

Assim, uma inferência de aproximadamente 155 ciclos corresponde a:

```text
155 × 20 ns = 3100 ns = 3,1 µs
```

Esse valor mede a chamada completa de classificação pelo firmware, incluindo envio das features, start, espera pelo ready e leitura do resultado.

## 14. Saída com ILA

Como os LEDs são limitados, foi adicionado um ILA (Integrated Logic Analyzer) do Vivado para observar os resultados internos.

Foram criados registradores de debug acessíveis pelo firmware:

```text
dbg_sample   → índice da amostra
dbg_expected → classe esperada
dbg_pred     → classe prevista
dbg_cycles   → ciclos medidos
dbg_correct  → acertos acumulados
dbg_pulse    → pulso de captura
```

O ILA foi configurado com os seguintes probes:

```text
probe0: dbg_sample    [31:0]
probe1: dbg_expected  [31:0]
probe2: dbg_pred      [31:0]
probe3: dbg_cycles    [31:0]
probe4: dbg_correct   [31:0]
probe5: dbg_pulse     [0:0]
probe6: custom_funct3 [2:0]
```

O trigger foi configurado em:

```text
dbg_pulse == 1
```

Com profundidade de captura maior, como 8192 amostras, foi possível observar uma rodada inteira de classificações.

O ILA mostrou diretamente, para cada amostra:

```text
sample
expected
pred
cycles
correct
```

Com isso, a saída deixou de depender apenas dos LEDs.

## 15. Resultado atual

O estado atual do projeto é:

```text
FemtoRV32 Quark rodando na PYNQ-Z2
Clock interno de 50 MHz
Firmware C bare-metal funcionando
Random Forest treinada em Python
Nós exportados automaticamente
Módulo random_forest.v integrado ao SoC
Instruções customizadas controlando a inferência
Resultados validados contra scikit-learn
ILA capturando predição, esperado, ciclos e acertos
```

O fluxo validado é:

```text
Python treina a Random Forest
        ↓
Script exporta os nós
        ↓
Firmware carrega a floresta
        ↓
RISC-V envia features por instruções customizadas
        ↓
Acelerador em hardware executa a inferência
        ↓
Resultado é retornado ao firmware
        ↓
ILA mostra predição, esperado, ciclos e acertos
```

## 16. Próximos passos

Os próximos passos planejados são:

```text
1. Comparar desempenho da inferência em hardware contra uma versão em software no RISC-V.
2. Calcular speedup em ciclos.
3. Melhorar a saída dos resultados, possivelmente com UART ou outro mecanismo.
4. Organizar o código final e remover trechos temporários.
5. Automatizar melhor a geração do firmware a partir da floresta treinada.
6. Testar diferentes tamanhos de floresta e profundidades.
7. Medir uso de recursos no Vivado.
```

O próximo experimento recomendado é implementar a mesma classificação da Random Forest em C puro, rodando no FemtoRV, e comparar os ciclos com a versão acelerada em hardware.

A métrica principal será:

```text
speedup = ciclos_software / ciclos_hardware
```
