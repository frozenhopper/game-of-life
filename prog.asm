CSEG AT 0H
JMP main
DISP1 EQU 0x40
DISP2 EQU 0x48

CUR_SC_LN_0 EQU 0x20
CUR_SC_LN_1 EQU 0x21
CUR_SC_LN_2 EQU 0x22

CUR_SC_RES EQU 0x23

main:
mov DISP1+0, #01111101b
mov DISP1+1, #11011111b
mov DISP1+2, #11010111b
mov DISP1+3, #01111110b
mov DISP1+4, #11010111b
mov DISP1+5, #01110111b
mov DISP1+6, #11101011b
mov DISP1+7, #10111110b

mov R7, #0x40
call drawScreen

mov R7, #0x40
mov R6, #0x48
call doGameOfLifeStep

mov R7, #0x48
call drawScreen
jmp end

drawScreen:
; R7: MEMORY OF SCREEN TO DRAW
mov a, r7
mov r0, a
mov R1, #11111110b ; WHAT ROW TO DISPLAY
mov R2, #00000001b ; LOOP COUNTER (via bitshifting -> faster)
mov A, R1
drawScreen_loop_0:
mov P1, @R0
mov P0, A
mov P0, #0xFF
rl A
inc R0
xch A, R2
rlc A
xch A, R2
jnc drawScreen_loop_0
ret

doGameOfLifeStep:
; R7: CURRENT SCREEN
; R6: NEXT SCREEN
mov a, r7
mov r0, a
mov a, r6
mov r1, a

mov R3, #00000100b ; LOOP COUNTER (via bitshifting -> faster)
doGameOfLifeStep_loop_0:
mov CUR_SC_LN_0, @r0
inc R0
mov CUR_SC_LN_1, @r0
inc R0
mov CUR_SC_LN_2, @r0
dec r0
call calculateLine
inc r1
mov @r1, CUR_SC_RES
xch a, r3
rlc a
xch a, r3
jnc doGameOfLifeStep_loop_0

mov CUR_SC_LN_0, @r0
inc r0
mov CUR_SC_LN_1, @r0
mov b, r0
mov a, r7
mov r0, a
mov CUR_SC_LN_2, @r0
call calculateLine
inc r1
mov @r1, CUR_SC_RES

mov CUR_SC_LN_1, @r0
inc r0
mov CUR_SC_LN_2, @r0
mov r0, b
mov CUR_SC_LN_0, @R0
call calculateLine
mov a, r6
mov r1, a
mov @R1, cur_sc_res
ret


calculateLine:
mov R2, #00000001b ; LOOP COUNTER (via bitshifting -> faster)
calculateLine_loop_0:
call calculatePixel
xch A, CUR_SC_LN_0
rl A
xch A, CUR_SC_LN_0
xch A, CUR_SC_LN_1
rl A
xch A, CUR_SC_LN_1
xch A, CUR_SC_LN_2
rl A
xch A, CUR_SC_LN_2
xch A, CUR_SC_RES
rl A
xch A, CUR_SC_RES
xch A, R2
rlc A
xch A, R2
jnc calculateLine_loop_0
ret

calculatePixel:
; cur_sc_ln_0..2 are relevant display rows
; current pixel in cur_sc_ln_1[1]
MOV A, #0x00
JNB CUR_SC_LN_0.0, calculatePixel_j0
inc A
calculatePixel_j0:
JNB CUR_SC_LN_0.1, calculatePixel_j1
inc A
calculatePixel_j1:
JNB CUR_SC_LN_0.2, calculatePixel_j2
inc A
calculatePixel_j2:
JNB CUR_SC_LN_1.0, calculatePixel_j3
inc A
calculatePixel_j3:
JNB CUR_SC_LN_1.2, calculatePixel_j4
inc A
calculatePixel_j4:
JNB CUR_SC_LN_2.0, calculatePixel_j5
inc A
calculatePixel_j5:
JNB CUR_SC_LN_2.1, calculatePixel_j6
inc A
calculatePixel_j6:
JNB CUR_SC_LN_2.2, calculatePixel_j7
inc A
calculatePixel_j7:
; count pixels
CLR C
SUBB A, #5
JZ calculatePixel_res_1
DEC A
JZ calculatePixel_res_1
setb CUR_SC_RES.1
ret
calculatePixel_res_1:
clr CUR_SC_RES.1
ret


end:

END
