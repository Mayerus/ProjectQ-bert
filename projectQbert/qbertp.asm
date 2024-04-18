; PROGRAM:	Q*BERT
; AUTHOR:	Omri Mayer
; VERSION:	1.00
; UPDATED:	15/03/2020

; DESCRIPTION:
; Q*bert /ˈkjuːbərt/ is an arcade game developed and published for the North
; American market by Gottlieb in 1982. It is a 2D action game with puzzle
; elements that uses isometric graphics to create a pseudo-3D effect. 
; The objective of the game is to change the color of every cube in the pyramid 
; by making Q*bert, the on-screen character, hop on top of the cube 
; while avoiding obstacles and enemies. 
; Players use the keyboard to control the character.

JUMPS
IDEAL
MODEL small
STACK 100h	

Clock		equ es:6Ch

cr			equ	13		;carriage return
lf			equ	10		; line feed
x			equ [bp+8]	
stack_x_a	equ [bp+6]
stack_y_a	equ [bp+4]

PURPLE	equ 23h
PINK	equ 3Ch

DATASEG
	
	filename 	db 'imgs\qb.bmp',0
	filehandle 	dw ?
	Header 		db 54 dup (0)
	Palette 	db 256*4 dup (0)
	ScrLine 	db 320 dup (0)
	ErrorMsg 	db 'Error', cr, lf,'$'
	; printed on screen when player wins
	winMsg		db 15 dup(lf),cr, 16 dup(' '),'You won!',10 dup(' '), '$'
	gameOverMsg	db 15 dup(lf),cr, 16 dup(' '),'GAME OVER',10 dup(' '), '$'
	; the number of lives is written on screen
	threeLivesMsg	db cr,'Lives: 3','$'
	twoLivesMsg		db cr,'Lives: 2','$'
	oneLifeMsg		db cr,'Lives: 1','$'
	noLifeMsg		db cr,'Lives: 0','$'
	livesMsgs		dw oneLifeMsg, twoLivesMsg, threeLivesMsg
	
	; q*bert's sprite is manually drawn because bmp format doesn't support "transparent" pixels
	q0	db	40h,  4 dup( 02Bh )
	q1	db	21h,  3 dup( 02Bh ), 5 dup( 02Ah )
	q2	db	12h,  02Ah, 02Ah, 02Bh, 2 dup( 02Ah, 0Fh, 0Fh )
	q3	db	13h,  02Ah, 02Bh, 02Bh, 2 dup(02Ah, 0, 0)
	q4	db	04h,  02Ah, 02Ah, 02Ah, 02Bh,2 dup( 02Ah, 0, 0 ), 2Bh
	q5	db	05h,  02Ah, 02Ah, 02Bh, 02Bh, 02Bh, 02Ah, 02Ah, 4 dup( 02Bh ), 02Ch, 02Ch
	q6	db	06h,  02Ah, 02Ah, 02Ah, 10 dup( 02Bh ), 02Ch
	q7	db	07h,  02Ah, 02Ah, 4 dup( 02Bh, 02Ah ), 02Ah, 02Ah, 02Bh, 02Bh, 02Ch
	q8	db	18h,  5 dup(02Ah), 02Bh, 02Ah, 02Ah
	q9	db	0A8h, 02Ah, 02Ah, 0, 0, 02Bh
	qA	db	29h,  6 dup( 02Ah )
	qB	db	0B9h, 02Ah, 0, 0, 02Ah
	qC	db	3Ah,  5 dup( 02Ah )
	qD	db	0CAh, 02Ah, 02Ah
	qE	db	3Bh,  02Ah 
	qF	db	7Bh,  02Ah
	q10	db	3Ch,  02Ah
	q11	db	7Ch,  02Ah
	q12	db	3Dh,  02Ah
	q13	db	7Dh,  02Ah
	q14	db	2Eh,  02Bh, 02Bh, 02Bh
	q15	db	7Eh,  02Ah, 02Bh, 02Bh
	q16	db	3Fh,  02Ah, 02Bh, 02Ch,02Ch
	q17	db	9Fh,  02Ah, 02Bh, 02Ch

	qSprite dw q0,q1,q2,q3,q4,q5,q6,q7,q8,q9,qA,qB,qC,qD,qE,qF,q10,q11,q12,q13,q14,q15,q16,q17
	qlen 	db 5,9,0Ah,0Ah,0Ch,0Eh,0Fh,10h,9,6,7,5,6,3,2,2,2,2,2,2,4,4,5,4
	
	; slick's sprite (drawn the same way as q*bert)
	s0	db	10h, 02Ah
	s1	db	40h, 02Ah
	s2	db	60h, 02Ah
	s3	db	21h, 02Ah
	s4	db	41h, 4 dup(02Ah)
	s5	db	02h, 02Ah
	s6	db	32h, 02Ah
	s7	db	52h, 02Ah
	s8	db	72h, 02Ah
	s9	db	13h, 02Ah, 02Ah, 3 dup(2, 02Ah), 02Ah
	sA	db	24h, 2, 02Ah, 7 dup(2)
	sB	db	15h, 10 dup(0)
	sC	db	16h, 2 dup(2, 94h), 0Fh,0,0,0Fh,0,2,2
	sD	db	17h, 2,2,94h,2, 2 dup(0Fh,0,2), 2
	sE	db	18h, 2,2,2,94h,7 dup(2)
	sF	db	29h, 10 dup(2)
	s10	db	2Ah, 6 dup(2), 0,0,2
	s11	db	3Bh, 8 dup(2)
	s12	db	3Ch, 2,2
	s13	db	8Ch, 2,2
	s14	db	4Dh, 2
	s15	db	8Dh, 2
	s16	db	4Eh, 2
	s17	db	8Eh, 2
	s18	db	4Fh, 2,2,2
	s19	db	8Fh, 2,2,2
	
	sSprite dw s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19
	slen 	db 2,2,2,2,5,2,2,2,2,0Ah,0Ah,0Bh,0Ch,0Ch,0Ch,0Bh,0Ah,9h,3,3,2,2,2,2,4,4
	
	; wrongWay's sprite (drawn the same way as q*bert)
	w0	 db 30h,	2 dup(PURPLE)
	w1	 db 0A0h,	PURPLE
	w2	 db 21h, 	2 dup(PURPLE)
	w3	 db 0B1h,	PURPLE
	w4	 db 02, 	3 dup(PINK)
	w5	 db 0A2h, 	PURPLE
	w6	 db 0C2h, 	2 dup(PURPLE)
	w7	 db 03, 	PINK
	w8	 db 33h, 	PINK
	w9	 db 63h, 	2 dup(PURPLE)
	wA	 db 93h, 	2 dup(PURPLE)
	wB	 db 0E3h, 	PURPLE
	wC	 db 4, 		2 dup(PINK)
	wD	 db 44h, 	6 dup(PURPLE)
	wE	 db 0D4h, 	PURPLE
	wF	 db 15h, 	PINK, 3 dup(PURPLE), 0Fh, 0, 0Fh, PURPLE
	w10	 db 0C5h, 	3 dup(PURPLE)
	w11	 db 26h, 	PURPLE, PURPLE, 4 dup(0), 0Fh, PURPLE
	w12	 db 0B6h, 	2 dup(PURPLE)
	w13	 db 0E6h, 	2 dup(PURPLE)
	w14	 db 17h, 	4 dup(PURPLE), 0, 0Fh, 0, 0, 3 dup(PURPLE)
	w15	 db 0F7h, 	PURPLE
	w16	 db 08,		PINK, PINK, PURPLE, 0Fh, 0Fh, PURPLE, PURPLE, 0Fh, 0, PINK, PINK
	w17	 db 19h,	PINK, 4 dup(0Fh), PURPLE, PURPLE
	w18	 db 0Ah,	2 dup(PINK), 0Fh, 0, 0, 0Fh, 0Fh, PURPLE, PURPLE
	w19	 db 0Bh,	2 dup(PINK), 0Fh, 0Fh, 0, 0Fh, 0Fh, 3 dup(PURPLE)
	w1A	 db 0Ch,	2 dup(PINK), PURPLE, 0Fh, 0Fh, 0, 0
	w1B	 db 9Ch,	PINK, PURPLE
	w1C	 db 1Dh,	PINK, PINK, 2 dup(PURPLE)
	w1D	 db 6Dh,	0
	w1E	 db 0ADh,	PINK, 3 dup(PURPLE)
	w1F	 db 0Eh,	5 dup(PINK)
	w20	 db 0BEh,	PINK
	w21	 db 2Fh,	3 dup(PINK)
	w22	 db 0CFh,	PINK, PURPLE

	wSprite dw w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,wA,wB,wC,wD,wE,wF,w10,w11,w12,w13,w14,w15,w16,w17, w18,w19,w1A,w1B,w1C,w1D,w1E,w1F,w20,w21,w22
	wlen 	db 3,2,3,2,4,2,3,2,2,3,3,2,3,7,2,9,4,9,3,3,0Ch,2,0Ch,8,0Ah,0Bh,8,3,5,2,5,6,2,4,3
	
	; the curse bubble sprite
	; these repetitive sequences are renamed and joined to short the code and make it more visible
	sq1 equ 0,0, 2 dup(0Fh)
	sq2 equ 0,0, 3 dup(0Fh)
	sq3 equ 3 dup(0Fh), 0,0
	sq4 equ 0,0, 4 dup(0Fh)
	sq5 equ 0,0, 5 dup(0Fh)
	sq6 equ 0,0,0Fh
	sq7 equ 0,0Fh,0
	sq8 equ 0,2 dup(0Fh)
	sq9 equ 2 dup(0Fh), 0
	sqA equ 4 dup(0Fh)
	sqB equ sq8, sq7
	sqC equ 0Fh, 0,0Fh
	sqD equ 0Fh, 0,0
	sqE	equ 3 dup(0Fh)
	
	c0	db  0D0h, 19 dup(0Fh)
	c1	db  81h,  29 dup(0Fh)
	c2	db  52h,  36 dup(0Fh)
	c3	db  33h,  10 dup(0Fh), 0,0, 12 dup(0Fh), 4 dup(0), 13 dup(0Fh)
	c4	db  24h,  11 dup(0Fh), 2 dup(sq2),sq3,sq7,0, 13 dup(0Fh)
	c5	db  15h,  sqA,5 dup(0),2 dup(sq3),sq9,2 dup(0Fh),2 dup(sq2),0,0,0,sqA,sq2
	c6	db  06h,  0Fh,sq3,7 dup(0Fh),sq6,0,2 dup(sqD),3 dup(0Fh),sq8,0Fh,sq6,6 dup(0),sq3,sqA
	c7	db  07h,  sqE,sq1,3 dup(0),sq8,sq6,6 dup(0),sq5,sq6,sq4,sq1,sq4
	c8	db  08h,  0Fh,2 dup(sq9),sq3,0Fh,0,sq3,4 dup(0),sq1,0,0,sq6,sq8,sq1,sq7,sq4
	c9	db  09h,  sqE,sq7,2 dup(0Fh),sqB,3 dup(0Fh),sq1,0,sqA,0,sq2,sq7,sq9,sqC,sq5
	cA	db  0Ah,  sqE,0,2 dup(sqD),2 dup(0Fh,0),0Fh,9 dup(0),2 dup(0Fh),sq4,sq7,3 dup(0,0Fh),sq5
	cB	db  0Bh,  3 dup(0Fh),sq8,0,sq1,sq7,3 dup(0Fh),8 dup(0),0Fh,sq4,0,sqA,sq7,0Fh,0,6 dup(0Fh)
	cC	db  0Ch,   sq3,5 dup(0Fh),sq6,sq8,sq1,2 dup(sq8),sq5,3 dup(0),sqB,6 dup(0Fh)
	cD	db  0Dh,   sqA,	6 dup(0),6 dup(0Fh),0,3 dup(0Fh),0,17 dup(0Fh),0,8 dup(0Fh)
	cE	db  1Eh,   11 dup(0Fh),0,sq8,sq8,sq5,sq4,7 dup(0),0Fh,sq4
	cF	db  2Fh,   10 dup(0Fh),3 dup(sq5),0Fh,3 dup(0),3 dup(0Fh),sq2
	c10	db  3,10h,  41 dup(0Fh)
	c11	db  5,11h,  37 dup(0Fh)
	c12	db  8,12h,  31 dup(0Fh)
	c13	db  0Fh,13h, 20 dup(0Fh)
	c14	db  1Eh,14h, 3 dup(0Fh)
	c15	db  1Eh,15h, 0Fh, 0Fh
	c16	db  1Dh,16h, 3 dup(0Fh)
	c17	db  1Dh,17h, 0Fh, 0Fh
	c18	db  1Ch,18h, 0Fh, 0Fh
	
	cSprite	dw c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,cA,cB,cC,cD,cE,cF,c10,c11,c12,c13,c14,c15,c16,c17,c18
	clen	db 20,30,37,42,44,47,49,49,49,49,49,49,49,48,46,44,43,39,33,22,5,4,5,4,4
	
	darkGreen	db 94h
	green		db 2h
	orangeRed	db 02Ah
	darkOrange	db 02Bh
	orange1		db 02Ch
	white		db 0Fh
	black		db 0
	qColors 	dw orangeRed, darkOrange, orange1, white, black
	
	; the high byte is the x value and the lower is the y value 
	; cubes states: 0-null/fall range 1-can be stepped
	row0 	db 8 dup(0)
	row1	db 0,7 dup(1),0
	row2	db 0,6 dup(1),0
	row3	db 0,5 dup(1),0
	row4	db 0,4 dup(1),0
	row5	db 0,3 dup(1),0
	row6	db 0,2 dup(1),0
	row7	db 0,1 dup(1),0
	row8	db 2 dup(0)
		
	; the cubes' coordinates: the high byte is the x value and the low one is the y value
	row0_p	dw 09618h,0A029h,0AA3Ah,0B44Bh,0BE5Ch,0c86dh,0d27eh,0dc8fh
	row1_p	dw 8c29h, 963ah, 0A04bh,0AA5ch,0B46dh,0be7eh,0c88fh,0d2a0h,0dcb1h
	row2_p	dw 823ah, 8c4bh, 965ch, 0A06dh,0AA7eh,0B48fh,0bea0h,0C8b1h
	row3_p	dw 784bh, 825ch, 8c6dh, 967eh, 0A08fh,0AAa0h,0B4B1h
	row4_p	dw 6e5ch, 786dh, 827eh, 8c8fh, 96a0h, 0a0b1h
	row5_p	dw 646dh, 6e7eh, 788fh, 82a0h, 8cb1h
	row6_p	dw 5a7eh, 648fh, 6ea0h, 78b1h
	row7_p	dw 508fh, 5aa0h, 64b1h
	row8_p 	dw 46A0h, 50B1h
	; num of rows
	pyr_len 	db 9
	; num of cubes on every row
	rows_len	db 8,9,8,7,6,5,4,3,2
	pyramid		dw row0 ,row1, row2, row3, row4, row5, row6, row7, row8
	pyramid_p	dw row0_p, row1_p, row2_p, row3_p, row4_p, row5_p, row6_p, row7_p, row8_p

	SCALE		db 	10	
	; colors
	pinkRed		db 0Ch
	yellow		db 2ch
	darkRed		db 28h
	seaBlue		db 9
	lightB		db 35h
	navyBlue 	db 37h
	lightBlue	db 36h
	grey		db 18h
	color		db 040h
	; colors arranged by state
	st_colors	dw black, lightB, seaBlue
	sideClrs	dw black, 2 dup(yellow)
	
	; variables used in the procedure drawCube
	state	db	?
	Xa		db	?
	Ya		db	?
	Xb		db	?
	Yb		db	?
	c_h		db	? 
	Xc		db	?
	dY		db	?

	; indexes used in the procedure drawCube
	i		db	?
	iMax	db	?
	j		db 	?
	jMax	db	?
	k		db	?
	kMax	db	?
	init_i	db	?
	
	; qbert's (i;j) position on the pyramid 
	qRow 	db 1
	qColumn	db 1
	sRow	db 0
	sColumn db 2
	wRow	db 6
	wColumn db 3
	; the player has 3 tries to win the game 
	lives 	db 3
	qMoved	db 0
	
	
	preTick	db ? 	; the last recorded time
	sMoved	db 1	; holds the time between every move
	sPause	db 0	; holds the time between every presence of slick on the pyramid
	sStyle	db 2	; slick can descend from 4 different points: 0(0;1), 1(1;0), 2(0;2), 3(2;0). Picked randomly
	sPauseConst db 5

	wPreTick	db ? 	; the last recorded time
	wMoved	db 1	; holds the time between every move
	wPause	db 5	; holds the time between every presence of slick on the pyramid
	wStyle	db 2	; slick can descend from 4 different points: 0(0;1), 1(1;0), 2(0;2), 3(2;0). Picked randomly
	wPauseConst db 5

CODESEG
;the methods from "oFile", to "copyBmp" are used to project a bmp on screen
proc oFile  
	; Open file
	mov		ah, 3Dh
	xor 	al, al
	lea 	dx, [filename]
	int 	21h
	jc 		openError
	mov 	[filehandle], ax
	ret
openError:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp oFile

proc rHeader
; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	lea dx,[Header]
	int 21h
	ret
endp rHeader

proc rPal
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	lea dx,[Palette]
	int 21h
	ret
endp rPal

proc copyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	lea si,[Palette]
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
		mov al,[si+2] ; Get red value.
		shr al,2 ; Max. is 255, but video palette maximal
		; value is 63. Therefore dividing by 4.
		out dx,al ; Send it.
		mov al,[si+1] ; Get green value.
		shr al,2
		out dx,al ; Send it.
		mov al,[si] ; Get blue value.
		shr al,2
		out dx,al ; Send it.
		add si,4 ; Point to next color.
		; (There is a null chr. after every color.)
		loop PalLoop
	ret
endp copyPal

proc copyBmp
; BMP graphics are saved upside-down.
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx, 200	
	PrintBMPLoop:
		push cx
		; di = cx*320, point to the correct screen line
		mov di, cx
		shl cx, 6
		shl di, 8
		add di, cx
		;sub di, 0A0h
		; Read one line
		mov ah, 3fh
		mov cx, 320
		lea dx, [ScrLine]
		int 21h
		mov ah, 3fh
		; Copy one line into video memory
		cld ; Clear direction flag, for movsb
		mov cx, 320
		lea si, [ScrLine]
		rep movsb 	; Copy line to the screen
					;rep movsb is same as the following code:
					;	mov es:di, ds:si
					;	inc si
					;	inc di
					;	dec cx
					;	loop until cx=0
		pop cx
		loop PrintBMPLoop
	ret
endp copyBmp

proc startScreen
; projects the start screen. Stops when keyboard is pressed.
		; Graphic mode
	mov  ax, 13h
	int  10h
	; Process BMP file
	call oFile
	call rHeader
	call rPal
	call copyPal
	call copyBmp
	; Wait for key press
	mov  ah, 1
	int  21h
	; Back to text mode to clean the screen
	mov ax, 2
	int 10h
	ret
endp startScreen

proc commonCalc
; Gets: x, x_a. Returns: ~0.6(x-x_a)
	push bp
	mov bp, sp
	mov cx, [bp+10]
	mov al, cl
	mov cx, [bp+ 8]
	sub al, cl
	mov dl, 6
	mul dl
	mov dl, 10
	div dl
	pop bp 
	ret
endp commonCalc
	
proc fX
; Gets: x, x_a, y_a. Returns: ~0.6(x-x_a) + y_a
;currently overrides the registers' values
	call commonCalc
	push bp
	mov bp,sp
	cmp ah, 5d		;starting round a number
	jbe noChange
	inc al
noChange:
	xor ah,ah		;end round a number
	add ax, stack_y_a
	mov x, ax
	pop bp
	ret 4
endp fX

proc gX
; Gets: x, x_a, y_a. Returns: ~0.6(x_a-x) + y_a
	;currently overrides the registers' values
	call commonCalc
	push bp
	mov bp, sp
	cmp ah, 5d		;start round a number
	jbe noChange2
	inc al
noChange2:
	xor ah,ah	;end round a number
	sub	stack_y_a, ax
	mov ax, stack_y_a
	mov x, ax
	pop bp
	ret 4
endp gX

proc hX
;Gets: x, c_h. Returns: 0.6 * x + c_h
	pop bx	; ip
	pop cx 	;
	pop ax	;
	mov ax, ax
	mov dl, 6
	mul dl
	mov dl, 10
	div dl
	cmp ah, 5d		;start round a number
	jbe noChange5
	inc al
noChange5:
	xor ah,ah	;end round a number
	add	ax, cx
	push ax
	push bx
	ret
endp hX

proc drawCube
;Gets: x, y, state. Draws a cube relatively to the point (x,y)
	push bp
	mov  bp, sp
	mov  ax, [bp+4]
	mov  [state], al
	mov  ax, [bp+6]
	mov  [Xb],ah
	mov  dl, [SCALE]
	add  [Xb], dl
	mov  [Xa], ah
	mov	 [Ya], al
	;calling fX output to define Yb , 
	pop bp
	xor  ax,ax
	mov  al, [Xb]
	push ax			;push x_b
	mov	 al, [Xa]
	push ax			;push x_a
	mov  al, [Ya]
	push ax			;push y_a	
	call gX
	pop  cx
	mov  [word Yb], cx
	; defines c_h=Yb-(~0.6Xb)
	mov  al, [Xb]
	mov  dl, 6
	mul  dl
	mov  dl, 10
	div  dl
	cmp  ah, 5d
	jbe  noChange3
	inc  al
	noChange3:
		xor ah,ah
		mov dl,[Yb]
		sub dl, al
		mov [c_h], dl
	; defines Xc=~(Ya-C_h)/0.6
	mov	 al, [Ya]  
	sub  al, [c_h]
	mov  bl, 10
	mul	 bl
	mov  bl, 6
	div  bl
	cmp  ah, 3
	jbe  noChange4
	inc  al
	noChange4:
		mov [Xc], al
	; defines dY=Ya-Yb
	mov al, [Ya]
	mov [dY], al
	mov al,[Yb]
	sub [dY], al
	;defines initial i index
	mov al, [Xa]
	mov [i], al
	;defines final i index(iMax)
	mov al, [Xb]
	mov [iMax], al
	;the loop draws the cube
	cubeFor:
		;defines initial j index
		xor  ax,ax
		mov  al,[i]
		push ax
		mov  al,[Xa]
		push ax
		mov  al,[Ya]
		push ax
		call gX
		pop  [word j]
		;defines final j index(jMax)
		xor  ax,ax
		mov  al,[i]
		push ax
		mov  al,[Xa]
		push ax	
		mov  al,[Ya]
		push ax
		call fX
		pop [word jMax]	
		; that is the side q*bert steps on and its color is variant through the game
		topFor:
			xor dh, dh
			xor cx, cx
			mov cl, [i]
			mov dl, [j]
			push di
			mov di, [word state]
			and di, 0FFh
			shl di, 1
			mov bx, [st_colors + di]
			pop di
			mov al, [bx]
			mov ah,0Ch
			int 10h
			mov cl, [iMax]
			sub cl, [i]
			shl cl, 1
			add cl, [i]
			mov dl, [j]
			mov ah,0Ch
			int 10h
			inc [j]
			mov dl, [jMax]
			cmp [j], dl
			jbe topFor
		;defines initial k index
		xor  ax,ax
		mov  al,[i]
		mov  [init_i], al
		push ax
		mov  al,[Xa]
		push ax
		mov  al,[Ya]
		push ax
		call fX
		pop  ax
		inc  al
		mov  [k], al
		;defines final k index(kMax)
		mov bl, [k]
		dec bl
		mov al,[dY]
		shl al, 1
		dec al
		mov [kMax], bl
		add [kMax], al
		sideFor:
			push di
			mov di, [word state]
			and di, 0FFh
			shl di, 1
			mov bx, [sideClrs + di]
			pop di
			mov al, [bx]
			xor bh, bh
			mov cl, [i]
			mov dl, [k]
			mov ah, 0Ch
			int 10h		
			mov cl, [Xa]
			;to create symmetric appearance, the leftmost blue line stroke isn't drawn
			cmp [i], cl
			je	skipFrst
			cmp al, [black]
			je 	project
			mov al, [pinkRed]
			project:
				mov cl, [iMax]
				sub cl, [i]
				shl cl, 1
				add cl, [i]
				mov dl, [k]
				mov ah,0Ch
				int 10h
			skipFrst:
				inc [k]
			mov cl, [kMax]
			cmp [k], cl
			jb sideFor
		inc [i]
		mov dl, [Xb]
		cmp [i],dl
		jbe cubeFor
	ret 4	
endp drawCube

proc drawPyramid
	; si is the pyramid_p's offset
	xor si,si
	cubesMatrix:
		; di is each row's offset
		xor di, di
		cubesRow:
			mov	 bx, [pyramid_p + si]		
			; the cube's relative (x,y) position 
			push [bx+di]			
			mov	 bx, [pyramid+si]
			shr  di, 1
			mov  ax, [bx+di]
			and  ax, 0Fh			
			; the cube's state
			push ax
			shl	 di, 1
			; draws cube
			call drawCube
			add  di, 2
			xor  ax, ax
			shr	 si, 1
			mov  al, [rows_len + si]
			shl  si, 1
			shl	 al, 1
			cmp  di, ax
			jb	 cubesRow
		add si, 2
		mov al, [pyr_len]
		shl al, 1
		cmp	si, ax
		jb cubesMatrix
	ret
endp drawPyramid

proc drawCurse
;generates curses sprite
	push bp
	mov  bp, sp
	mov  ax, [bp+4] ; relative (x,y) position to screen
	;row's index
	xor  si, si
	xor  dh, dh
	cRows:
		xor cx, cx
		mov bx, [cSprite + si] 		; the row's address
		cmp si, 20h
		jb	bytePos
		
		mov dx, [bx]				; relative position to the top-left sprite's corner
		mov cl, dl			
		mov al, ah
		xor ah, ah
		add cx, ax	; x coordinate
		mov dl, dh
		xor dh, dh
		mov ax, [bp+4]
		xor ah,ah
		add dx, ax	; y coordinate
		
		mov di,2
		jmp posInRegs
	bytePos:
		mov dl, [bx]				; relative position to the top-left sprite's corner
		shl dx, 4					; shifting to the high-byte
		mov cl, dh				
		mov al, ah
		xor ah, ah
		add cx, ax	; x coordinate
		mov ax, [bp+4]
		xor dh, dh
		shr dx, 4
		xor ah,ah
		add dx, ax	; y coordinate
		mov ax, [bp+4] 
		mov di, 1
	posInRegs:
		cPixls:
			mov  bx, [cSprite + si] 
			mov  ah, 0ch			
			mov  al, [bx+di]		; pixel's color
			xor  bx, bx
			int  10h
			inc  cl
			inc  di
			shr  si, 1
			mov  bl, [clen + si]	; the row's (length-1)*2
			shl  si, 1
			cmp  di, bx
			jb   cPixls
		mov  ax, [bp+4]
		add  si, 2
		cmp  si, 30h				; the array's of rows length-1
		jbe cRows
	pop bp
	ret 2
endp drawCurse

proc drawQbert
;generates q*bert's sprite
	push bp
	mov  bp, sp
	mov  ax, [bp+4] ; relative (x,y) position to screen
	;row's index
	xor  si, si
	xor  dh, dh
	qRows:
		mov bx, [qSprite + si] 		; the row's address
		mov dl, [bx]				; relative position to the top-lest sprite's corner
		shl dx, 4
		mov cl, dh				
		mov al, ah
		xor ah, ah
		add cx, ax	; x coordinate
		mov ax, [bp+4]
		xor dh, dh
		shr dx, 4
		xor ah,ah
		add dx, ax	; y coordinate
		mov ax, [bp+4] 
		mov di, 1
		qPixls:
			mov  bx, [qSprite + si] 
			mov  ah, 0ch			
			mov  al, [bx+di]		; pixel's color
			xor  bx, bx
			int  10h
			inc  cl
			inc  di
			shr  si, 1
			mov  bl, [qlen + si]	; the row's (length-1)*2
			shl  si, 1
			cmp  di, bx
			jb   qPixls
		mov  ax, [bp+4]
		add  si, 2
		cmp  si, 2Eh				; the array's of rows length-1
		jbe qRows
	pop bp
	ret 2
endp drawQbert

proc drawSlick
;generates Slick's sprite
	push bp
	mov  bp, sp
	mov  ax, [bp+4] ; relative (x,y) position to screen
	;row's index
	xor  si, si
	xor  dh, dh
	sRows:
		xor cx, cx
		mov bx, [sSprite + si] 		; the row's address
		mov dl, [bx]				; relative position to the top-left sprite's corner
		shl dx, 4					; shifting to the high-byte
		mov cl, dh				
		mov al, ah
		xor ah, ah
		add cx, ax	; x coordinate
		mov ax, [bp+4]
		xor dh, dh
		shr dx, 4
		xor ah,ah
		add dx, ax	; y coordinate
		mov ax, [bp+4] 
		mov di, 1
		sPixls:
			mov  bx, [sSprite + si] 
			mov  ah, 0ch			
			mov  al, [bx+di]		; pixel's color
			xor  bx, bx
			int  10h
			inc  cl
			inc  di
			shr  si, 1
			mov  bl, [slen + si]	; the row's (length-1)*2
			shl  si, 1
			cmp  di, bx
			jb   sPixls
		mov  ax, [bp+4]
		add  si, 2
		cmp  si, 30h				; the array's of rows length-1
		jbe sRows
	pop bp
	ret 2
endp drawSlick

proc drawWrongWay
;generates WrongWay's sprite
	push bp
	mov  bp, sp
	mov  ax, [bp+4] ; relative (x,y) position to screen
	;row's index
	xor  si, si
	xor  dh, dh
	wRows:
		xor cx, cx
		mov bx, [wSprite + si] 		; the row's address
		mov dl, [bx]				; relative position to the top-left sprite's corner
		shl dx, 4					; shifting to the high-byte
		mov cl, dh				
		mov al, ah
		xor ah, ah
		add cx, ax	; x coordinate
		mov ax, [bp+4]
		xor dh, dh
		shr dx, 4
		xor ah,ah
		add dx, ax	; y coordinate
		mov ax, [bp+4] 
		mov di, 1
		wPixls:
			mov  bx, [wSprite + si] 
			mov  ah, 0ch			
			mov  al, [bx+di]		; pixel's color
			xor  bx, bx
			int  10h
			inc  cl
			inc  di
			shr  si, 1
			mov  bl, [wlen + si]	; the row's (length-1)*2
			shl  si, 1
			cmp  di, bx
			jb   wPixls
		mov  ax, [bp+4]
		add  si, 2
		cmp  si, 44h				; the array's of rows length-1
		jbe wRows
	pop bp
	ret 2
endp drawWrongWay

proc drawSprites
	;draws the cube q*bert is on
	xor ah, ah
	mov al, [qRow]
	mov si, ax
	shl si, 1
	mov bx, [pyramid_p + si]
	mov al, [qColumn]
	mov di, ax
	shl di, 1
	mov ax, [bx + di]
	push ax
	push ax
	shr di, 1
	mov bx, [pyramid+si]
	mov ax, [bx+di]
	push ax
	call drawCube
		
	;draws the cube slick is on
	xor ah, ah
	mov al, [sRow]
	mov si, ax
	shl si, 1
	mov bx, [pyramid_p + si]
	mov al, [sColumn]
	mov di, ax
	shl di, 1
	mov ax, [bx + di]
	push ax
	push ax
	shr di, 1
	mov bx, [pyramid+si]
	mov ax, [bx+di]
	push ax
	call drawCube	

	;draws the cube wrongWay is on
	xor ah, ah
	mov al, [wRow]
	mov si, ax
	shl si, 1
	mov bx, [pyramid_p + si]
	mov al, [wColumn]
	mov di, ax
	shl di, 1
	mov ax, [bx + di]
	push ax
	push ax
	shr di, 1
	mov bx, [pyramid+si]
	mov ax, [bx+di]
	push ax
	call drawCube

	;draws wrongWay if he is on the pyramid
	cmp [wPause], 0
	ja skipWrongWay
	pop ax
	; position adjustments
	add ah, 3
	sub al, 0Bh
	push ax
	call drawWrongWay
	jmp dontSkipWrongWay
skipWrongWay:
	pop ax ; pops wronWay's coordinates
dontSkipWrongWay:
	;draws slick if he is on the pyramid
	cmp [sRow], 0 
	je skipSlick
	cmp [sColumn], 0
	je skipSlick
	cmp [sPause], 0
	ja skipSlick
	pop ax
	add ah, 4
	sub al, 10h
	push ax
	call drawSlick
	jmp dontSkipSlick
skipSlick:
	pop ax ;pops slick's coordinates
dontSkipSlick:
	;draws q*bert
	pop ax
	add ah, 4
	sub al, 10h
	push ax
	call drawQbert
	ret	
endp drawSprites

proc Movement
; when --some-- keyboard buttons are pressed q*bert moves
	mov ah, 11h		; checks if any key on extended keyboard was pressed
	int 16h
	jz  noPress
	mov ah, 10h		; gets the scancode of the button
	int 16h
	cmp ah, 4Eh		; "quit" button
	je	quit
	; A relevant key button has been pressed, hence the cube which qbert is currently on an also the two above it shall be drawn to conceal q*bert"
	push ax
	sub  sp, 10h
	push bp
	mov  bp, sp
	;draws the upper cubes
	; the parameters of three calls are pushed ahead instead of pushing before every call
	xor  ah, ah
	mov  al, [qRow]
	mov  si, ax
	shl	 si, 1
	; si is pushed to be restored later
	mov  [bp+16], si
	mov	 bx, [pyramid_p + si]
	; the cube's relative (x,y) position 
	mov  al, [qColumn]
	mov  di, ax
	shl  di, 1
	; the coordinates for every call
	; di is pushed to be restored later
	mov  [bp+14], di
	mov  ax, [bx+di]
	mov  [bp+12], ax				
	mov  ax, [bx+di-2]
	mov	 [bp+ 8], ax
	mov  bx, [pyramid_p + si - 2]
	mov  ax, [bx+di]
	mov	 [bp + 4], ax
	; the state for every call
	mov	 bx, [pyramid+si]
	shr  di, 1
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp+0Ah], ax
	mov  ax, [bx+di-1]
	and  ax, 0Fh
	mov  [bp + 6], ax
	mov  bx, [pyramid+si-2]
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp + 2], ax
	pop bp
	; draws cube
	call drawCube
	call drawCube
	call drawCube
	pop di		; di is restored
	pop si		; si is restored

	pop ax
	;for those who get difficult with the keyboard, two options are avalilable without any  dependence of one on the other: the extended key buttons: 4, 5, 7 and 8 ; and the keys o, p, l and ";".
	; what keyboard button was pressed
	cmp ah, 18h
	je movNorthWest
	cmp ah, 26h
	je movSouthWest
	cmp ah, 27h
	je movSouthEast
	cmp ah, 19h
	je movNorthEast

	; what keyboard button was pressed
	cmp ah, 47h
	je movNorthWest
	cmp ah, 4Bh
	je movSouthWest
	cmp ah, 4Ch
	je movSouthEast
	cmp ah, 48h
	je movNorthEast
	jmp reDrawSprites
quit:
	; game over\quit status
	push bp
	mov  bp, sp
	mov ax, 0
	mov  [bp+4],ax
	pop  bp
	jmp noPress
movNorthEast:
	dec [qRow]
	jmp updateGraphics
movSouthEast:
	inc [qColumn]
	jmp updateGraphics
movSouthWest:
	inc [qRow]
	jmp updateGraphics
movNorthWest:
	dec [qColumn]
	jmp updateGraphics
updateGraphics:
	;changes the state in the new position
	xor ah, ah
	mov al, [qRow]
	shl al, 1
	mov si, ax
	mov bx, [pyramid + si]
	xor al, al
	mov al, [qColumn]
	mov di, ax
	mov al, [bx + di]
	cmp ax, 0
	ja onCube
	; decreases live by one when the player falls from edge
	dec [lives]
	; saves all of the regs' values on the stack
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	; draw the curse bubble
	xor ah, ah
	mov al, [qRow]
	mov si, ax
	shl si, 1
	mov bx, [pyramid_p + si]
	mov al, [qColumn]
	mov di, ax
	shl di, 1
	mov ax, [bx + di]
	push ax
	call drawCurse
	
	; wait for first change in timer
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
FirstTick:
	cmp ax, [Clock]
	je FirstTick
	; count 1 sec
	mov cx, 36 ; 18x0.055sec = ~1sec
DelayLoop:
	mov ax, [Clock]
	mov dx, 1
Tick:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop
	; going back and forth between text and graphic mode to clear the screen
	mov ax, 2
	int 10h
	mov ax,13h
	int 10h
	; redraws pyramid
	call drawPyramid
	; restores regs' values
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	; reposition qbert on the top of the pyramid
	mov [qRow], 1
	mov [qColumn], 1
	call drawSprites
	jmp updateGraphics
onCube:
	cmp al, 1
	je firstToSecond
	jmp secondToFirst
firstToSecond:
	inc [bx + di]
	jmp reDrawSprites
secondToFirst:
	dec [bx + di]
reDrawSprites:
	call drawSprites
noPress:
	call isWin
	ret
endp Movement

proc sMovement
; changes slick's coordinates approximately every 1 second
	sub  sp, 10h
	push bp
	mov  bp, sp
	; draws the upper cubes
	; the parameters of three calls are pushed ahead instead of pushing before every single call
	xor  ah, ah
	mov  al, [sRow]
	mov  si, ax
	shl	 si, 1
	; si is pushed to be restored later
	mov  [bp+16], si
	mov	 bx, [pyramid_p + si]
	; the cube's relative (x,y) position 
	mov  al, [sColumn]
	mov  di, ax
	shl  di, 1
	; the coordinates for every call
	; di is pushed to be restored later
	mov  [bp+14], di
	mov  ax, [bx+di]
	mov  [bp+12], ax				
	mov  ax, [bx+di-2]
	mov	 [bp+ 8], ax
	mov  bx, [pyramid_p + si - 2]
	mov  ax, [bx+di]
	mov	 [bp + 4], ax
	; the state for every call
	mov	 bx, [pyramid+si]
	shr  di, 1
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp+0Ah], ax
	mov  ax, [bx+di-1]
	and  ax, 0Fh
	mov  [bp + 6], ax
	mov  bx, [pyramid+si-2]
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp + 2], ax
	pop bp
	; draws cubes
	call drawCube
	call drawCube
	call drawCube
	pop di		; di is restored
	pop si		; si is restored
changePos:
	;changes slick's position
	cmp [sStyle],0
	je haltCond0
	cmp [sStyle],1
	je haltCond1
	cmp [sStyle],2
	je haltCond2
	cmp [sStyle],3
	je haltCond3
; as long as slick hasn't reached certain position depend on his movement style, he keeps going
haltCond0:
	cmp [sRow], 7
	jb onPyramid
	jmp stopStyle
haltCond1:
	cmp [sColumn], 7
	jb onPyramid
	jmp stopStyle
haltCond2:
	cmp [sRow],6
	jb onPyramid
	jmp stopStyle
haltCond3:
	cmp [sColumn],6
	jb onPyramid
stopStyle:
	; activating slick's pause
	mov al, [sPauseConst]
	mov [sPause], al
	call slickRandomStyle
	jmp skipDrawing
onPyramid:
	; changes slick's current position, depend on his style
	cmp [sStyle],0
	je style0And2
	cmp [sStyle],1
	je style1And3
	cmp [sStyle],2
	je style0And2
	cmp [sStyle],3
	je style1And3
style0And2:
	inc [sRow]
	jmp checkState
style1And3:
	inc [sColumn]	
checkState:
	;changes the state in the new position
	xor ah, ah
	mov al, [sRow]
	shl al, 1
	mov si, ax
	mov bx, [pyramid + si]
	xor al, al
	mov al, [sColumn]
	mov di, ax
	mov al, [bx + di]
	cmp al, 2
	jne drawSlickAndCube
changeState:
	dec [bx + di]	
drawSlickAndCube:
	call drawSprites
skipDrawing:
	ret
endp sMovement

proc wMovement
; changes WrongWay's coordinates approximately every 1 second
	sub  sp, 10h
	push bp
	mov  bp, sp
	;draws the upper cubes
	; the parameters of three calls are pushed ahead instead of pushing before every call
	xor  ah, ah
	mov  al, [wRow]
	mov  si, ax
	shl	 si, 1
	; si is pushed to be restored later
	mov  [bp+16], si
	mov	 bx, [pyramid_p + si]
	; the cube's relative (x,y) position 
	mov  al, [wColumn]
	mov  di, ax
	shl  di, 1
	; the coordinates for every call
	; di is pushed to be restored later
	mov  [bp+14], di
	mov  ax, [bx+di]
	mov  [bp+12], ax				
	mov  ax, [bx+di-2]
	mov	 [bp+ 8], ax
	mov  bx, [pyramid_p + si - 2]
	mov  ax, [bx+di]
	mov	 [bp + 4], ax
	; the state for every call
	mov	 bx, [pyramid+si]
	shr  di, 1
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp+0Ah], ax
	mov  ax, [bx+di-1]
	and  ax, 0Fh
	mov  [bp + 6], ax
	mov  bx, [pyramid+si-2]
	mov  ax, [bx+di]
	and  ax, 0Fh
	mov  [bp + 2], ax
	pop bp
	; draws cube
	call drawCube
	call drawCube
	call drawCube
	pop di		; di is restored
	pop si		; si is restored
; as long as wrongWay hasn't reached row one, he keeps going
haltCond:
	cmp [wRow], 2
	ja wOnPyramid
wStopStyle:
	mov al, [sPauseConst] ; same pause constant as slick's
	mov [wPause], al
	call drawSprites
	call wrongWayRandomStyle
	ret
wOnPyramid:
	;changes wrongWay's position
	dec [wRow]
drawWrongWayAndCube:
	call drawSprites
	ret
endp wMovement

proc random
; gets a range and generates a random
	; initialize
	push bp
	mov bp, sp
	mov dx, [bp+4]
	mov ax, 40h
	mov es, ax
	mov cx, 1
	mov bx, 0
	; generate random number, cx number of times
	mov ax, [Clock] ; read timer counter
	mov ah, [byte cs:bx] ; read one byte from memory
	xor al, ah ; xor memory and counter
	and al, dl ; leave result between 0-to dl's value
	mov [bp+4], ax
	pop bp
	ret
endp random

proc slickRandomStyle
; when slick gets to the edge of the cube, its coordinates reset
;picks randomly the manner of descending (4 options)
	mov ax, 3
	push ax
	call random
	pop ax
	mov [sStyle], al
	cmp [sStyle],0
	je style0
	cmp [sStyle],1
	je style1
	cmp [sStyle],2
	je style2
	cmp [sStyle],3
	je style3
style0:
	mov [sRow],0
	mov [sColumn],1
	ret
style1:
	mov [sRow],1
	mov [sColumn],0
	ret
style2:
	mov [sRow],0
	mov [sColumn],2
	ret
style3:
	mov [sRow],2
	mov [sColumn],0
	ret
endp slickRandomStyle

proc wrongWayRandomStyle
; when wrongWay gets to the edge of the cube, its coordinates reset
;picks randomly the manner of ascending
	mov ax, 7
	push ax
	call random
	pop ax
	inc al
	; if the random's output plus one will be more than six, it isn't count and wrongWay is considered as "out of the pyramid until a legal value will be generated.
	cmp al,6
	jbe inRange
	mov [wRow], 2 
	mov [wPause], 0
	ret
inRange:
	mov [wColumn],al
	mov dl, 9
	sub dl, al
	mov [wRow], dl
	ret
endp wrongWayRandomStyle

proc slickEncounter
; an encounter between q*bert and slick will cause slick to disappear
	mov al, [sRow]
	cmp [qRow], al
	jne noSlickEncounter
	mov al, [sColumn]
	cmp [qColumn], al
	jne noSlickEncounter
	; if instruction pointer has came so far, it means q*bert and slick are on the same cube, thus slick shall be "paused" and removed from the pyramid
	mov al, [sPauseConst]
	mov [sPause], al
	call slickRandomStyle
noSlickEncounter:
	ret
endp SlickEncounter

proc wrongWayEncounter
; an encounter between q*bert and wrongWay will cause q*bert lose one life and be sent to the top of the pyramid
	cmp [wRow], 1
	jbe noEncounter
	mov al, [wRow]
	cmp [qRow], al
	jne noEncounter
	mov al, [wColumn]
	cmp [qColumn], al
	jne noEncounter
	; if instruction pointer has came so far, it means q*bert and slick are on the same cube, thus slick shall be "paused" and removed from the pyramid
	;draw curse bubble
	
	; saves regs' values
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	xor ah, ah
	mov al, [qRow]
	mov si, ax
	shl si, 1
	mov bx, [pyramid_p + si]
	mov al, [qColumn]
	mov di, ax
	shl di, 1
	mov ax, [bx + di]
	sub ax, 0D27h
	push ax
	call drawCurse
	
	; wait for first change in timer
	mov ax, 40h
	mov es, ax
	mov ax, [Clock]
FirstTick1:
	cmp ax, [Clock]
	je FirstTick1
	; count 1 sec
	mov cx, 36 ; 36x0.055sec = ~2sec
DelayLoop1:
	mov ax, [Clock]
	mov dx, 1
Tick1:
	cmp ax, [Clock]
	je Tick
	loop DelayLoop1
	; clears screen by going back and forth between text and graphic mode
	mov ax, 2
	int 10h
	mov ax,13h
	int 10h
	; draws the pyramid
	call drawPyramid
	; restires regs' values
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	; redraws the characters
	call drawSprites
	dec [lives]
	mov [qRow], 1
	mov [qColumn], 1
noEncounter:
	ret
endp wrongWayEncounter

proc isWin
; checks if all the needed cubes have been stepped, otherwise the game continues
	; checks "pyramid"
	; si is "pyramid's" offset
	mov si, 2
	rows:
		; di is each row's offset
		mov di, 1
		cubes:			
			; gets the cube's state
			mov	bx, [pyramid+si]
			mov al, [bx+di]
			; if any cube is not in state "2" the player surely haven't won yet. 
			cmp al, 2
			jb	noWin
			inc di
			xor ax, ax
			shr	si, 1
			xor ah, ah
			mov al, [rows_len + si]
			shl si, 1
			dec ax
			cmp di, ax
			jb	cubes
		add si, 2
		mov al, [pyr_len]
		dec al
		shl al, 1
		cmp	si, ax
		jb rows
win:
	push bp
	mov  bp, sp
	mov ax, 2
	mov [bp+6], ax
	pop bp
	ret
noWin:
	ret
endp isWin

proc game
; in charge of the continual game (division of labor); timing between the variant procedures etc
	mov ah, 2Ch
	int 21h
	mov [preTick], dh
	true:
		cmp [lives], 2
		jb one
		cmp [lives], 2
		je two
		three:
			mov dx, offset threelivesMsg
			jmp printLives
		two:
			mov dx, offset twolivesMsg
			jmp printLives
		one:
			mov dx, offset oneLifeMsg
		printLives:
			mov ah, 9h
			int 21h
	; clock check
	mov ah, 2Ch
	int 21h
	cmp [preTick],dh
	je sameSecond1
	; slick pauses between every entry to the cube
	cmp [sPause], 0
	jne pauseSlickCountdown
	cmp [sMoved], 0
	jne prepareToMoveSlick
	;code of moving
	mov [sMoved], 2 ; instructs him to stand still on the next second
	mov [preTick], dh
	call sMovement
	prepareToMoveSlick:
		mov [preTick], dh
		dec [sMoved]
		jmp sameSecond1
	pauseSlickCountdown:
		mov [preTick], dh
		dec [sPause]
	sameSecond1:
		; clock check
		mov ah, 2Ch
		int 21h
		cmp [wPreTick],dh
		je sameSecond
		; slick pauses between every entry to the cube
		cmp [wPause], 0
		jne pauseWrongWayCountdown
		cmp [wMoved], 0
		jne prepareToMoveWrongWay
		;code of moving
		mov [wMoved], 2 ; instructs him to stand still on the next second
		mov [wPreTick], dh
		call wMovement
		prepareToMoveWrongWay:
		; when wrongWay is in the pyramid
			mov [wPreTick], dh
			dec [wMoved]
			jmp sameSecond
		pauseWrongWayCountdown:
		; when wrongWay is not on the pyramid a countdown is active.
			mov [wPreTick], dh
			dec [wPause]
	sameSecond:
		mov ax,1
		; ax will be used to store a status value: 0-no change, 1-quit, 2 - win, 3-game over 
		push ax	; if the "quit" button is pressed the procedure to be called will change the "0" to "1".
		call Movement
		call slickEncounter
		call wrongWayEncounter
		cmp [lives], 0
		pop ax
		cmp [lives], 0
		je gameOver
		cmp ax, 1	; 1 is the "keep going" status
		je true
	nop 
	cmp ax , 2		; 2 is the win status
	jne gameOver
	mov dx, offset winMsg
	mov ah, 9h
	int 21h
	; Wait for key press
	mov  ah, 1
	int  21h
	ret
gameOver:
	mov dx, offset noLifeMsg
	mov ah, 9h
	int 21h
	mov dx, offset gameOverMsg
	mov ah, 9h
	int 21h
	; Wait for key press
	mov  ah, 1
	int  21h
	ret
endp game

start:
	mov	 ax, @data
	mov	 ds, ax
	call startScreen
	; Graphic mode
	mov  ax, 13h
	int  10h
	call drawPyramid
	push 9A2Ah
	call drawQbert
	call game
	; text mode
	xor ah, ah
	mov al, 2
	int 10h	
	pop  ax
	mov  cx, ax
exit: 
	mov  ax, 4c00h
	int  21h
END start