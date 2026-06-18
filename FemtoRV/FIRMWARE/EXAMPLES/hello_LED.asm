
hello_LED.baremetal.elf: formato do arquivo elf32-littleriscv


Desmontagem da seção .text:

00000000 <_start>:
   0:	004001b7          	lui	gp,0x400
   4:	000802b7          	lui	t0,0x80
   8:	003282b3          	add	t0,t0,gp
   c:	0002a103          	lw	sp,0(t0) # 80000 <IO_HW_CONFIG_RAM>
  10:	00000293          	li	t0,0
  14:	00000097          	auipc	ra,0x0
  18:	7a0080e7          	jalr	1952(ra) # 7b4 <_end>
  1c:	00000317          	auipc	t1,0x0
  20:	1a430067          	jr	420(t1) # 1c0 <exit>

00000024 <MAX7219_shift>:
  24:	fe010113          	addi	sp,sp,-32
  28:	00812c23          	sw	s0,24(sp)
  2c:	00001437          	lui	s0,0x1
  30:	01212823          	sw	s2,16(sp)
  34:	01312623          	sw	s3,12(sp)
  38:	00112e23          	sw	ra,28(sp)
  3c:	00912a23          	sw	s1,20(sp)
  40:	01c40413          	addi	s0,s0,28 # 101c <buff>
  44:	00000793          	li	a5,0
  48:	00700993          	li	s3,7
  4c:	00f00913          	li	s2,15
  50:	00178493          	addi	s1,a5,1
  54:	00f9ea63          	bltu	s3,a5,68 <IO_SSD1351_CMD+0x28>
  58:	00044583          	lbu	a1,0(s0)
  5c:	00048513          	mv	a0,s1
  60:	00000097          	auipc	ra,0x0
  64:	1c4080e7          	jalr	452(ra) # 224 <MAX7219>
  68:	00144783          	lbu	a5,1(s0)
  6c:	00140413          	addi	s0,s0,1
  70:	fef40fa3          	sb	a5,-1(s0)
  74:	00048793          	mv	a5,s1
  78:	fd249ce3          	bne	s1,s2,50 <IO_SSD1351_CMD+0x10>
  7c:	01812403          	lw	s0,24(sp)
  80:	01c12083          	lw	ra,28(sp)
  84:	01412483          	lw	s1,20(sp)
  88:	01012903          	lw	s2,16(sp)
  8c:	00c12983          	lw	s3,12(sp)
  90:	03c00513          	li	a0,60
  94:	02010113          	addi	sp,sp,32
  98:	00000317          	auipc	t1,0x0
  9c:	23030067          	jr	560(t1) # 2c8 <milliwait>

000000a0 <MAX7219_putchar>:
  a0:	ff010113          	addi	sp,sp,-16
  a4:	00812423          	sw	s0,8(sp)
  a8:	00112623          	sw	ra,12(sp)
  ac:	00a00793          	li	a5,10
  b0:	00050413          	mv	s0,a0
  b4:	02f51863          	bne	a0,a5,e4 <MAX7219_putchar+0x44>
  b8:	02000513          	li	a0,32
  bc:	00000097          	auipc	ra,0x0
  c0:	fe4080e7          	jalr	-28(ra) # a0 <MAX7219_putchar>
  c4:	02000513          	li	a0,32
  c8:	00000097          	auipc	ra,0x0
  cc:	fd8080e7          	jalr	-40(ra) # a0 <MAX7219_putchar>
  d0:	00040513          	mv	a0,s0
  d4:	00c12083          	lw	ra,12(sp)
  d8:	00812403          	lw	s0,8(sp)
  dc:	01010113          	addi	sp,sp,16
  e0:	00008067          	ret
  e4:	00d00793          	li	a5,13
  e8:	fcf508e3          	beq	a0,a5,b8 <MAX7219_putchar+0x18>
  ec:	000017b7          	lui	a5,0x1
  f0:	0107a583          	lw	a1,16(a5) # 1010 <font_8x8>
  f4:	000017b7          	lui	a5,0x1
  f8:	00351513          	slli	a0,a0,0x3
  fc:	01c78793          	addi	a5,a5,28 # 101c <buff>
 100:	00000713          	li	a4,0
 104:	00800613          	li	a2,8
 108:	00a706b3          	add	a3,a4,a0
 10c:	00d586b3          	add	a3,a1,a3
 110:	0006c683          	lbu	a3,0(a3)
 114:	00170713          	addi	a4,a4,1
 118:	00178793          	addi	a5,a5,1
 11c:	00d783a3          	sb	a3,7(a5)
 120:	fec714e3          	bne	a4,a2,108 <IO_SSD1351_DAT16+0x8>
 124:	00000097          	auipc	ra,0x0
 128:	f00080e7          	jalr	-256(ra) # 24 <MAX7219_shift>
 12c:	00000097          	auipc	ra,0x0
 130:	ef8080e7          	jalr	-264(ra) # 24 <MAX7219_shift>
 134:	00000097          	auipc	ra,0x0
 138:	ef0080e7          	jalr	-272(ra) # 24 <MAX7219_shift>
 13c:	00000097          	auipc	ra,0x0
 140:	ee8080e7          	jalr	-280(ra) # 24 <MAX7219_shift>
 144:	00000097          	auipc	ra,0x0
 148:	ee0080e7          	jalr	-288(ra) # 24 <MAX7219_shift>
 14c:	00000097          	auipc	ra,0x0
 150:	ed8080e7          	jalr	-296(ra) # 24 <MAX7219_shift>
 154:	00000097          	auipc	ra,0x0
 158:	ed0080e7          	jalr	-304(ra) # 24 <MAX7219_shift>
 15c:	00000097          	auipc	ra,0x0
 160:	ec8080e7          	jalr	-312(ra) # 24 <MAX7219_shift>
 164:	f6dff06f          	j	d0 <MAX7219_putchar+0x30>

00000168 <MAX7219_tty_init>:
 168:	ff010113          	addi	sp,sp,-16
 16c:	00812423          	sw	s0,8(sp)
 170:	00912223          	sw	s1,4(sp)
 174:	00112623          	sw	ra,12(sp)
 178:	00000413          	li	s0,0
 17c:	00000097          	auipc	ra,0x0
 180:	0b8080e7          	jalr	184(ra) # 234 <MAX7219_init>
 184:	00800493          	li	s1,8
 188:	00140413          	addi	s0,s0,1
 18c:	00000593          	li	a1,0
 190:	00040513          	mv	a0,s0
 194:	00000097          	auipc	ra,0x0
 198:	090080e7          	jalr	144(ra) # 224 <MAX7219>
 19c:	fe9416e3          	bne	s0,s1,188 <MAX7219_tty_init+0x20>
 1a0:	00812403          	lw	s0,8(sp)
 1a4:	00c12083          	lw	ra,12(sp)
 1a8:	00412483          	lw	s1,4(sp)
 1ac:	00000537          	lui	a0,0x0
 1b0:	0a050513          	addi	a0,a0,160 # a0 <MAX7219_putchar>
 1b4:	01010113          	addi	sp,sp,16
 1b8:	00000317          	auipc	t1,0x0
 1bc:	0e030067          	jr	224(t1) # 298 <set_putcharfunc>

000001c0 <exit>:
 1c0:	00a1a223          	sw	a0,4(gp) # 400004 <IO_BASE+0x4>

000001c4 <exitl1>:
 1c4:	00051063          	bnez	a0,1c4 <exitl1>

000001c8 <exitl>:
 1c8:	00100293          	li	t0,1
 1cc:	0051a223          	sw	t0,4(gp)
 1d0:	06400513          	li	a0,100
 1d4:	00000097          	auipc	ra,0x0
 1d8:	0f4080e7          	jalr	244(ra) # 2c8 <milliwait>
 1dc:	00200293          	li	t0,2
 1e0:	0051a223          	sw	t0,4(gp)
 1e4:	06400513          	li	a0,100
 1e8:	00000097          	auipc	ra,0x0
 1ec:	0e0080e7          	jalr	224(ra) # 2c8 <milliwait>
 1f0:	00400293          	li	t0,4
 1f4:	0051a223          	sw	t0,4(gp)
 1f8:	06400513          	li	a0,100
 1fc:	00000097          	auipc	ra,0x0
 200:	0cc080e7          	jalr	204(ra) # 2c8 <milliwait>
 204:	00800293          	li	t0,8
 208:	0051a223          	sw	t0,4(gp)
 20c:	06400513          	li	a0,100
 210:	00000097          	auipc	ra,0x0
 214:	0b8080e7          	jalr	184(ra) # 2c8 <milliwait>
 218:	fb1ff06f          	j	1c8 <exitl>

0000021c <abort>:
 21c:	00100073          	ebreak
 220:	00008067          	ret

00000224 <MAX7219>:
 224:	00851293          	slli	t0,a0,0x8
 228:	00b2e2b3          	or	t0,t0,a1
 22c:	2051a023          	sw	t0,512(gp)
 230:	00008067          	ret

00000234 <MAX7219_init>:
 234:	ffc10113          	addi	sp,sp,-4
 238:	00112023          	sw	ra,0(sp)
 23c:	00900513          	li	a0,9
 240:	00000593          	li	a1,0
 244:	00000097          	auipc	ra,0x0
 248:	fe0080e7          	jalr	-32(ra) # 224 <MAX7219>
 24c:	00a00513          	li	a0,10
 250:	00f00593          	li	a1,15
 254:	00000097          	auipc	ra,0x0
 258:	fd0080e7          	jalr	-48(ra) # 224 <MAX7219>
 25c:	00b00513          	li	a0,11
 260:	00700593          	li	a1,7
 264:	00000097          	auipc	ra,0x0
 268:	fc0080e7          	jalr	-64(ra) # 224 <MAX7219>
 26c:	00c00513          	li	a0,12
 270:	00100593          	li	a1,1
 274:	00000097          	auipc	ra,0x0
 278:	fb0080e7          	jalr	-80(ra) # 224 <MAX7219>
 27c:	00f00513          	li	a0,15
 280:	00000593          	li	a1,0
 284:	00000097          	auipc	ra,0x0
 288:	fa0080e7          	jalr	-96(ra) # 224 <MAX7219>
 28c:	00012083          	lw	ra,0(sp)
 290:	00410113          	addi	sp,sp,4
 294:	00008067          	ret

00000298 <set_putcharfunc>:
 298:	000017b7          	lui	a5,0x1
 29c:	00a7ac23          	sw	a0,24(a5) # 1018 <putcharfunc>
 2a0:	00008067          	ret

000002a4 <set_getcharfunc>:
 2a4:	000017b7          	lui	a5,0x1
 2a8:	00a7aa23          	sw	a0,20(a5) # 1014 <getcharfunc>
 2ac:	00008067          	ret

000002b0 <putchar>:
 2b0:	000017b7          	lui	a5,0x1
 2b4:	0187a303          	lw	t1,24(a5) # 1018 <putcharfunc>
 2b8:	00030067          	jr	t1

000002bc <getchar>:
 2bc:	000017b7          	lui	a5,0x1
 2c0:	0147a303          	lw	t1,20(a5) # 1014 <getcharfunc>
 2c4:	00030067          	jr	t1

000002c8 <milliwait>:
 2c8:	006007b7          	lui	a5,0x600
 2cc:	0007a783          	lw	a5,0(a5) # 600000 <IO_BASE+0x200000>
 2d0:	ff010113          	addi	sp,sp,-16
 2d4:	00050593          	mv	a1,a0
 2d8:	0107d793          	srli	a5,a5,0x10
 2dc:	3ff7f513          	andi	a0,a5,1023
 2e0:	00112623          	sw	ra,12(sp)
 2e4:	00000097          	auipc	ra,0x0
 2e8:	3f8080e7          	jalr	1016(ra) # 6dc <__mulsi3>
 2ec:	00551793          	slli	a5,a0,0x5
 2f0:	40a787b3          	sub	a5,a5,a0
 2f4:	00c12083          	lw	ra,12(sp)
 2f8:	00279793          	slli	a5,a5,0x2
 2fc:	00a78533          	add	a0,a5,a0
 300:	00351513          	slli	a0,a0,0x3
 304:	01010113          	addi	sp,sp,16
 308:	00000317          	auipc	t1,0x0
 30c:	03830067          	jr	56(t1) # 340 <wait_cycles>

00000310 <UART_putchar>:
 310:	00a1a423          	sw	a0,8(gp)

00000314 <pcrx>:
 314:	0081a283          	lw	t0,8(gp)
 318:	2002f293          	andi	t0,t0,512
 31c:	fe029ce3          	bnez	t0,314 <pcrx>
 320:	00008067          	ret

00000324 <UART_getchar>:
 324:	0081a503          	lw	a0,8(gp)
 328:	10057293          	andi	t0,a0,256
 32c:	fe028ce3          	beqz	t0,324 <UART_getchar>
 330:	0ff57513          	zext.b	a0,a0
 334:	00a00293          	li	t0,10
 338:	fe5506e3          	beq	a0,t0,324 <UART_getchar>
 33c:	00008067          	ret

00000340 <wait_cycles>:
 340:	ff010113          	addi	sp,sp,-16
 344:	00812423          	sw	s0,8(sp)
 348:	00912223          	sw	s1,4(sp)
 34c:	00050413          	mv	s0,a0
 350:	00112623          	sw	ra,12(sp)
 354:	00000097          	auipc	ra,0x0
 358:	044080e7          	jalr	68(ra) # 398 <cycles>
 35c:	41f45793          	srai	a5,s0,0x1f
 360:	00a404b3          	add	s1,s0,a0
 364:	0084b433          	sltu	s0,s1,s0
 368:	00b785b3          	add	a1,a5,a1
 36c:	00b40433          	add	s0,s0,a1
 370:	00000097          	auipc	ra,0x0
 374:	028080e7          	jalr	40(ra) # 398 <cycles>
 378:	fe85ece3          	bltu	a1,s0,370 <wait_cycles+0x30>
 37c:	00b41463          	bne	s0,a1,384 <wait_cycles+0x44>
 380:	fe9568e3          	bltu	a0,s1,370 <wait_cycles+0x30>
 384:	00c12083          	lw	ra,12(sp)
 388:	00812403          	lw	s0,8(sp)
 38c:	00412483          	lw	s1,4(sp)
 390:	01010113          	addi	sp,sp,16
 394:	00008067          	ret

00000398 <cycles>:
 398:	000016b7          	lui	a3,0x1
 39c:	03c6a783          	lw	a5,60(a3) # 103c <cycles_lap_.1900>
 3a0:	02079263          	bnez	a5,3c4 <cycles+0x2c>
 3a4:	006007b7          	lui	a5,0x600
 3a8:	0007a783          	lw	a5,0(a5) # 600000 <IO_BASE+0x200000>
 3ac:	02000713          	li	a4,32
 3b0:	07f7f793          	andi	a5,a5,127
 3b4:	02f6ae23          	sw	a5,60(a3)
 3b8:	06e79a63          	bne	a5,a4,42c <IO_SDCARD+0x2c>
 3bc:	fff00793          	li	a5,-1
 3c0:	02f6ae23          	sw	a5,60(a3)
 3c4:	c0002873          	rdcycle	a6
 3c8:	00001737          	lui	a4,0x1
 3cc:	03872783          	lw	a5,56(a4) # 1038 <last_cycles32_.1902>
 3d0:	00070613          	mv	a2,a4
 3d4:	00001737          	lui	a4,0x1
 3d8:	02f87263          	bgeu	a6,a5,3fc <cycles+0x64>
 3dc:	03c6a583          	lw	a1,60(a3)
 3e0:	03072683          	lw	a3,48(a4) # 1030 <cycles_.1901>
 3e4:	03472503          	lw	a0,52(a4)
 3e8:	00b685b3          	add	a1,a3,a1
 3ec:	00d5b6b3          	sltu	a3,a1,a3
 3f0:	00a686b3          	add	a3,a3,a0
 3f4:	02b72823          	sw	a1,48(a4)
 3f8:	02d72a23          	sw	a3,52(a4)
 3fc:	03072683          	lw	a3,48(a4)
 400:	03472583          	lw	a1,52(a4)
 404:	03062c23          	sw	a6,56(a2)
 408:	40f687b3          	sub	a5,a3,a5
 40c:	01078533          	add	a0,a5,a6
 410:	00f6b6b3          	sltu	a3,a3,a5
 414:	40d586b3          	sub	a3,a1,a3
 418:	00f537b3          	sltu	a5,a0,a5
 41c:	00d785b3          	add	a1,a5,a3
 420:	02a72823          	sw	a0,48(a4)
 424:	02b72a23          	sw	a1,52(a4)
 428:	00008067          	ret
 42c:	00100713          	li	a4,1
 430:	00f717b3          	sll	a5,a4,a5
 434:	f8dff06f          	j	3c0 <cycles+0x28>

00000438 <printf>:
 438:	fb010113          	addi	sp,sp,-80
 43c:	04f12223          	sw	a5,68(sp)
 440:	03410793          	addi	a5,sp,52
 444:	02812423          	sw	s0,40(sp)
 448:	03212023          	sw	s2,32(sp)
 44c:	01312e23          	sw	s3,28(sp)
 450:	01412c23          	sw	s4,24(sp)
 454:	01512a23          	sw	s5,20(sp)
 458:	01612823          	sw	s6,16(sp)
 45c:	02112623          	sw	ra,44(sp)
 460:	02912223          	sw	s1,36(sp)
 464:	00050413          	mv	s0,a0
 468:	02b12a23          	sw	a1,52(sp)
 46c:	02c12c23          	sw	a2,56(sp)
 470:	02d12e23          	sw	a3,60(sp)
 474:	04e12023          	sw	a4,64(sp)
 478:	05012423          	sw	a6,72(sp)
 47c:	05112623          	sw	a7,76(sp)
 480:	00f12623          	sw	a5,12(sp)
 484:	02500913          	li	s2,37
 488:	07300993          	li	s3,115
 48c:	07800a13          	li	s4,120
 490:	06400a93          	li	s5,100
 494:	06300b13          	li	s6,99
 498:	00044503          	lbu	a0,0(s0)
 49c:	02051663          	bnez	a0,4c8 <printf+0x90>
 4a0:	02c12083          	lw	ra,44(sp)
 4a4:	02812403          	lw	s0,40(sp)
 4a8:	02412483          	lw	s1,36(sp)
 4ac:	02012903          	lw	s2,32(sp)
 4b0:	01c12983          	lw	s3,28(sp)
 4b4:	01812a03          	lw	s4,24(sp)
 4b8:	01412a83          	lw	s5,20(sp)
 4bc:	01012b03          	lw	s6,16(sp)
 4c0:	05010113          	addi	sp,sp,80
 4c4:	00008067          	ret
 4c8:	00140493          	addi	s1,s0,1
 4cc:	09251663          	bne	a0,s2,558 <printf+0x120>
 4d0:	00144503          	lbu	a0,1(s0)
 4d4:	03351263          	bne	a0,s3,4f8 <printf+0xc0>
 4d8:	00c12783          	lw	a5,12(sp)
 4dc:	0007a503          	lw	a0,0(a5)
 4e0:	00478713          	addi	a4,a5,4
 4e4:	00e12623          	sw	a4,12(sp)
 4e8:	00000097          	auipc	ra,0x0
 4ec:	080080e7          	jalr	128(ra) # 568 <print_string>
 4f0:	00148413          	addi	s0,s1,1
 4f4:	fa5ff06f          	j	498 <printf+0x60>
 4f8:	03451063          	bne	a0,s4,518 <printf+0xe0>
 4fc:	00c12783          	lw	a5,12(sp)
 500:	0007a503          	lw	a0,0(a5)
 504:	00478713          	addi	a4,a5,4
 508:	00e12623          	sw	a4,12(sp)
 50c:	00000097          	auipc	ra,0x0
 510:	1c4080e7          	jalr	452(ra) # 6d0 <print_hex>
 514:	fddff06f          	j	4f0 <printf+0xb8>
 518:	03551063          	bne	a0,s5,538 <printf+0x100>
 51c:	00c12783          	lw	a5,12(sp)
 520:	0007a503          	lw	a0,0(a5)
 524:	00478713          	addi	a4,a5,4
 528:	00e12623          	sw	a4,12(sp)
 52c:	00000097          	auipc	ra,0x0
 530:	0a0080e7          	jalr	160(ra) # 5cc <print_dec>
 534:	fbdff06f          	j	4f0 <printf+0xb8>
 538:	01651a63          	bne	a0,s6,54c <printf+0x114>
 53c:	00c12783          	lw	a5,12(sp)
 540:	0007a503          	lw	a0,0(a5)
 544:	00478713          	addi	a4,a5,4
 548:	00e12623          	sw	a4,12(sp)
 54c:	00000097          	auipc	ra,0x0
 550:	d64080e7          	jalr	-668(ra) # 2b0 <putchar>
 554:	f9dff06f          	j	4f0 <printf+0xb8>
 558:	00000097          	auipc	ra,0x0
 55c:	d58080e7          	jalr	-680(ra) # 2b0 <putchar>
 560:	00040493          	mv	s1,s0
 564:	f8dff06f          	j	4f0 <printf+0xb8>

00000568 <print_string>:
 568:	ff010113          	addi	sp,sp,-16
 56c:	00812423          	sw	s0,8(sp)
 570:	00112623          	sw	ra,12(sp)
 574:	00050413          	mv	s0,a0
 578:	00044503          	lbu	a0,0(s0)
 57c:	00051a63          	bnez	a0,590 <print_string+0x28>
 580:	00c12083          	lw	ra,12(sp)
 584:	00812403          	lw	s0,8(sp)
 588:	01010113          	addi	sp,sp,16
 58c:	00008067          	ret
 590:	00000097          	auipc	ra,0x0
 594:	d20080e7          	jalr	-736(ra) # 2b0 <putchar>
 598:	00140413          	addi	s0,s0,1
 59c:	fddff06f          	j	578 <print_string+0x10>

000005a0 <puts>:
 5a0:	ff010113          	addi	sp,sp,-16
 5a4:	00112623          	sw	ra,12(sp)
 5a8:	00000097          	auipc	ra,0x0
 5ac:	fc0080e7          	jalr	-64(ra) # 568 <print_string>
 5b0:	00a00513          	li	a0,10
 5b4:	00000097          	auipc	ra,0x0
 5b8:	cfc080e7          	jalr	-772(ra) # 2b0 <putchar>
 5bc:	00c12083          	lw	ra,12(sp)
 5c0:	00100513          	li	a0,1
 5c4:	01010113          	addi	sp,sp,16
 5c8:	00008067          	ret

000005cc <print_dec>:
 5cc:	ef010113          	addi	sp,sp,-272
 5d0:	10912223          	sw	s1,260(sp)
 5d4:	10112623          	sw	ra,268(sp)
 5d8:	10812423          	sw	s0,264(sp)
 5dc:	11212023          	sw	s2,256(sp)
 5e0:	00050493          	mv	s1,a0
 5e4:	0604de63          	bgez	s1,660 <print_dec+0x94>
 5e8:	02d00513          	li	a0,45
 5ec:	00000097          	auipc	ra,0x0
 5f0:	cc4080e7          	jalr	-828(ra) # 2b0 <putchar>
 5f4:	409004b3          	neg	s1,s1
 5f8:	fedff06f          	j	5e4 <print_dec+0x18>
 5fc:	00a00593          	li	a1,10
 600:	00048513          	mv	a0,s1
 604:	00000097          	auipc	ra,0x0
 608:	180080e7          	jalr	384(ra) # 784 <__modsi3>
 60c:	00140413          	addi	s0,s0,1
 610:	fea40fa3          	sb	a0,-1(s0)
 614:	00a00593          	li	a1,10
 618:	00048513          	mv	a0,s1
 61c:	00000097          	auipc	ra,0x0
 620:	0e4080e7          	jalr	228(ra) # 700 <__divsi3>
 624:	00050493          	mv	s1,a0
 628:	fc049ae3          	bnez	s1,5fc <print_dec+0x30>
 62c:	fd2408e3          	beq	s0,s2,5fc <print_dec+0x30>
 630:	fff40413          	addi	s0,s0,-1
 634:	00044503          	lbu	a0,0(s0)
 638:	03050513          	addi	a0,a0,48
 63c:	00000097          	auipc	ra,0x0
 640:	c74080e7          	jalr	-908(ra) # 2b0 <putchar>
 644:	ff2416e3          	bne	s0,s2,630 <print_dec+0x64>
 648:	10c12083          	lw	ra,268(sp)
 64c:	10812403          	lw	s0,264(sp)
 650:	10412483          	lw	s1,260(sp)
 654:	10012903          	lw	s2,256(sp)
 658:	11010113          	addi	sp,sp,272
 65c:	00008067          	ret
 660:	00010413          	mv	s0,sp
 664:	00040913          	mv	s2,s0
 668:	fc1ff06f          	j	628 <print_dec+0x5c>

0000066c <print_hex_digits>:
 66c:	ff010113          	addi	sp,sp,-16
 670:	00912223          	sw	s1,4(sp)
 674:	fff58593          	addi	a1,a1,-1
 678:	000004b7          	lui	s1,0x0
 67c:	00812423          	sw	s0,8(sp)
 680:	01212023          	sw	s2,0(sp)
 684:	00112623          	sw	ra,12(sp)
 688:	00050913          	mv	s2,a0
 68c:	00259413          	slli	s0,a1,0x2
 690:	7fc48493          	addi	s1,s1,2044 # 7fc <_end+0x48>
 694:	00045e63          	bgez	s0,6b0 <print_hex_digits+0x44>
 698:	00c12083          	lw	ra,12(sp)
 69c:	00812403          	lw	s0,8(sp)
 6a0:	00412483          	lw	s1,4(sp)
 6a4:	00012903          	lw	s2,0(sp)
 6a8:	01010113          	addi	sp,sp,16
 6ac:	00008067          	ret
 6b0:	008957b3          	srl	a5,s2,s0
 6b4:	00f7f793          	andi	a5,a5,15
 6b8:	00f487b3          	add	a5,s1,a5
 6bc:	0007c503          	lbu	a0,0(a5)
 6c0:	ffc40413          	addi	s0,s0,-4
 6c4:	00000097          	auipc	ra,0x0
 6c8:	bec080e7          	jalr	-1044(ra) # 2b0 <putchar>
 6cc:	fc9ff06f          	j	694 <print_hex_digits+0x28>

000006d0 <print_hex>:
 6d0:	00800593          	li	a1,8
 6d4:	00000317          	auipc	t1,0x0
 6d8:	f9830067          	jr	-104(t1) # 66c <print_hex_digits>

000006dc <__mulsi3>:
 6dc:	00050613          	mv	a2,a0
 6e0:	00000513          	li	a0,0
 6e4:	0015f693          	andi	a3,a1,1
 6e8:	00068463          	beqz	a3,6f0 <__mulsi3+0x14>
 6ec:	00c50533          	add	a0,a0,a2
 6f0:	0015d593          	srli	a1,a1,0x1
 6f4:	00161613          	slli	a2,a2,0x1
 6f8:	fe0596e3          	bnez	a1,6e4 <__mulsi3+0x8>
 6fc:	00008067          	ret

00000700 <__divsi3>:
 700:	06054063          	bltz	a0,760 <__umodsi3+0x10>
 704:	0605c663          	bltz	a1,770 <__umodsi3+0x20>

00000708 <__udivsi3>:
 708:	00058613          	mv	a2,a1
 70c:	00050593          	mv	a1,a0
 710:	fff00513          	li	a0,-1
 714:	02060c63          	beqz	a2,74c <__udivsi3+0x44>
 718:	00100693          	li	a3,1
 71c:	00b67a63          	bgeu	a2,a1,730 <__udivsi3+0x28>
 720:	00c05863          	blez	a2,730 <__udivsi3+0x28>
 724:	00161613          	slli	a2,a2,0x1
 728:	00169693          	slli	a3,a3,0x1
 72c:	feb66ae3          	bltu	a2,a1,720 <__udivsi3+0x18>
 730:	00000513          	li	a0,0
 734:	00c5e663          	bltu	a1,a2,740 <__udivsi3+0x38>
 738:	40c585b3          	sub	a1,a1,a2
 73c:	00d56533          	or	a0,a0,a3
 740:	0016d693          	srli	a3,a3,0x1
 744:	00165613          	srli	a2,a2,0x1
 748:	fe0696e3          	bnez	a3,734 <__udivsi3+0x2c>
 74c:	00008067          	ret

00000750 <__umodsi3>:
 750:	00008293          	mv	t0,ra
 754:	fb5ff0ef          	jal	708 <__udivsi3>
 758:	00058513          	mv	a0,a1
 75c:	00028067          	jr	t0
 760:	40a00533          	neg	a0,a0
 764:	0005d863          	bgez	a1,774 <__umodsi3+0x24>
 768:	40b005b3          	neg	a1,a1
 76c:	f9dff06f          	j	708 <__udivsi3>
 770:	40b005b3          	neg	a1,a1
 774:	00008293          	mv	t0,ra
 778:	f91ff0ef          	jal	708 <__udivsi3>
 77c:	40a00533          	neg	a0,a0
 780:	00028067          	jr	t0

00000784 <__modsi3>:
 784:	00008293          	mv	t0,ra
 788:	0005ca63          	bltz	a1,79c <__modsi3+0x18>
 78c:	00054c63          	bltz	a0,7a4 <__modsi3+0x20>
 790:	f79ff0ef          	jal	708 <__udivsi3>
 794:	00058513          	mv	a0,a1
 798:	00028067          	jr	t0
 79c:	40b005b3          	neg	a1,a1
 7a0:	fe0558e3          	bgez	a0,790 <__modsi3+0xc>
 7a4:	40a00533          	neg	a0,a0
 7a8:	f61ff0ef          	jal	708 <__udivsi3>
 7ac:	40b00533          	neg	a0,a1
 7b0:	00028067          	jr	t0

Desmontagem da seção .text.startup:

000007b4 <main>:
 7b4:	ff010113          	addi	sp,sp,-16
 7b8:	00812423          	sw	s0,8(sp)
 7bc:	00112623          	sw	ra,12(sp)
 7c0:	00000437          	lui	s0,0x0
 7c4:	00000097          	auipc	ra,0x0
 7c8:	9a4080e7          	jalr	-1628(ra) # 168 <MAX7219_tty_init>
 7cc:	7dc40513          	addi	a0,s0,2012 # 7dc <main+0x28>
 7d0:	00000097          	auipc	ra,0x0
 7d4:	c68080e7          	jalr	-920(ra) # 438 <printf>
 7d8:	ff5ff06f          	j	7cc <main+0x18>
