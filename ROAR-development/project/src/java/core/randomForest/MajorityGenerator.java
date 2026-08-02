package project.src.java.core.randomForest;

import project.src.java.core.BasicGenerator;
import project.src.java.util.FileBuilder;
import project.src.java.util.executionSettings.CLI.ConditionalEquationMux.SettingsCli;

import java.util.ArrayList;
import java.util.Objects;

public class MajorityGenerator extends BasicGenerator {
    public void execute(int treeQnt, int classQnt, SettingsCli settings){
        String src = "";

        src += generateHeader("majority", classQnt);
        src += generatePortDeclaration(treeQnt, classQnt);
        src += generateMajorityExpression(classQnt);
        src += generateEndDelimiters();

        FileBuilder.execute(
            src, String.format(
                "output/%s_%s_%dtree_%sdeep_run/majority.v",
                settings.dataset,
                settings.approach,
                settings.trainingParameters.estimatorsQuantity,
                settings.trainingParameters.maxDepth
            ),
            false
        );
    }

    public String generateHeader(String module_name, int classQnt){
        String src = "";

        src += "module majority (\n";
        src += tab(1) + "voted,\n";

        for (int index = 0; index < classQnt; index++) {
            if (index == classQnt - 1){
                src += tab(1) + String.format("class%d_votes\n", index);
            } else {
                src += tab(1) + String.format("class%d_votes,\n", index);
            }

        }
        src += ");\n";
        return src;
    }

    private String generatePortDeclaration(int treeQnt, int classQnt){
        int bitwidth = (int) Math.ceil(Math.log(classQnt) / Math.log(2));

        String src = "";
        int sumBitwidth = (int)(Math.log(Math.abs(treeQnt)) / Math.log(2)) + 1;

        for (int index = 0; index < classQnt; index++){
            src += tab(1);
            src += generatePort(String.format("class%d_votes", index), WIRE, INPUT, sumBitwidth, true);
        }
        src += "\n";
        src += tab(1) + generatePort("voted", WIRE, OUTPUT, bitwidth, true);
        src += "\n";

        return src;
    }

private String generateMajorityExpression(int classQnt) {

    int classBitwidth = (int) Math.ceil(
        Math.log(classQnt) / Math.log(2)
    );

    StringBuilder src = new StringBuilder();

    src.append(tab(1))
       .append("reg [")
       .append(classBitwidth - 1)
       .append(":0] voted_reg;\n\n");

    src.append(tab(1))
       .append("assign voted = voted_reg;\n\n");

    src.append(tab(1))
       .append("always @(*) begin\n");

    for (int currentClass = 0;
         currentClass < classQnt;
         currentClass++) {

        StringBuilder condition = new StringBuilder();

        for (int otherClass = currentClass + 1;
             otherClass < classQnt;
             otherClass++) {

            if (condition.length() > 0) {
                condition.append(" && ");
            }

            condition.append(String.format(
                "(class%d_votes >= class%d_votes)",
                currentClass,
                otherClass
            ));
        }

        if (currentClass == 0) {
            src.append(tab(2)).append("if (");
        } else if (currentClass < classQnt - 1) {
            src.append(tab(2)).append("else if (");
        } else {
            src.append(tab(2)).append("else begin\n");
            src.append(tab(3))
               .append(String.format(
                   "voted_reg = %d'b%s;\n",
                   classBitwidth,
                   toBin(currentClass, classBitwidth)
               ));
            src.append(tab(2)).append("end\n");
            break;
        }

        src.append(condition).append(") begin\n");

        src.append(tab(3))
           .append(String.format(
               "voted_reg = %d'b%s;\n",
               classBitwidth,
               toBin(currentClass, classBitwidth)
           ));

        src.append(tab(2)).append("end\n");
    }

    src.append(tab(1)).append("end\n");

    return src.toString();
}
}
