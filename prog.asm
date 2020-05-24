CSEG AT 0H
JMP main
DISP1 EQU 0x40
DISP2 EQU 0x48

CUR_SC_LN_0 EQU 0x20
CUR_SC_LN_1 EQU 0x21
CUR_SC_LN_2 EQU 0x22

CUR_SC_RES EQU 0x23

main:

mov DISP1+0, #0xFF
mov DISP1+1, #0xFF
mov DISP1+2, #0xFF
mov DISP1+3, #0xFF
mov DISP1+4, #0xFF
mov DISP1+5, #0xFF
mov DISP1+6, #0xFF
mov DISP1+7, #0xFF
call preGameLoop

mov R7, #0x40
mov R6, #0x48
call drawScreen

main_loop:
call doGameOfLifeStep
mov A, R7
xch A, R6
mov R7, A

main_loop_input_loop:
call drawScreen

MOV a, P3
ANL a, #10000000b
jz main_loop

jmp main_loop_input_loop



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

mov B, #0
JNB CUR_SC_LN_1.1, calculatePixel_j8
mov B, #1

calculatePixel_j8:
CLR C
SUBB A, #5
JZ calculatePixel_res_1
DEC A
JZ calculatePixel_res_2
setb CUR_SC_RES.1
ret
calculatePixel_res_1:
clr CUR_SC_RES.1
ret
calculatePixel_res_2:
mov a, b
jz calculatePixel_res_1
setb CUR_SC_RES.1
ret

preGameLoop:
mov r5, #0 ; X
mov r4, #0 ; Y
;mov P3, #0x00
button_wait_loop:
mov P3, #11111111b
mov a, r5
mov r0, a
call draw_num
mov P3, #11111101b
mov P3, #11111111b
mov a, r4
mov r0, a
call draw_num
mov P3, #11111110b
mov P3, #11111111b
mov R7, #0x40
call drawScreen

MOV a, P3
ANL a, #10000000b
jz button_wait_loop_start

MOV a, P3
ANL a, #01000000b
jz button_wait_loop_swap

MOV a, P3
ANL a, #00100000b
jz button_wait_loop_right

MOV a, P3
ANL a, #00010000b
jz button_wait_loop_left

MOV a, P3
ANL a, #00001000b
jz button_wait_loop_down

MOV a, P3
ANL a, #00000100b
jz button_wait_loop_up

jmp button_wait_loop
button_wait_loop_right:
mov a, r5
clr C
subb a, #7
jz button_wait_loop
inc r5
jmp button_wait_loop
button_wait_loop_left:
mov a, r5
jz button_wait_loop
dec r5
jmp button_wait_loop
button_wait_loop_down:
mov a, r4
jz button_wait_loop
dec r4
jmp button_wait_loop
button_wait_loop_up:
mov a, r4
clr C
subb a, #7
jz button_wait_loop
inc r4
jmp button_wait_loop
button_wait_loop_swap:
mov r0, #0x40
call switchBit
jmp button_wait_loop
button_wait_loop_start:
mov P2, #10111111b
mov P3, #11111100b
ret


switchBit:
; R5: x
; R4: y
; R0: Screen
mov b, #10000000b
mov a, R5
switchBit_loop_beg:
jz switchBit_loop_end
xch a, b
rr a
xch a, b
dec a
jmp switchBit_loop_beg

switchBit_loop_end:
mov a, r0
add a, r4
mov r0, a
mov a, @r0
XRL a, b
mov @R0, a
ret



draw_num:
; r0: num
mov a, r0
jnz draw_num_1
mov P2, #11000000b
ret
draw_num_1:
dec a
jnz draw_num_2
mov P2, #11111001b
ret
draw_num_2:
dec a
jnz draw_num_3
mov P2, #10100100b
ret
draw_num_3:
dec a
jnz draw_num_4
mov P2, #10110000b
ret
draw_num_4:
dec a
jnz draw_num_5
mov P2, #10011001b
ret
draw_num_5:
dec a
jnz draw_num_6
mov P2, #10010010b
ret
draw_num_6:
dec a
jnz draw_num_7
mov P2, #10000010b
ret
draw_num_7:
dec a
jnz draw_num_8
mov P2, #11111000b
ret
draw_num_8:
dec a
jnz draw_num_9
mov P2, #10000000b
ret
draw_num_9:
mov P2, #10010000b
ret


end:

END
