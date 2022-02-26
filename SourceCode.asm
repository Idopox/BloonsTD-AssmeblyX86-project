;AUTHOR: Ido Barkan
;All Rights Reserved
.486
IDEAL
;---------------------------------------------;
; case: DeltaY is bigger than DeltaX		  ;
; input: p1X p1Y,		            		  ;
; 		 p2X p2Y,		           		      ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
Macro DrawLine2DDY p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1X]
	cmp ax, [p2X]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2Y]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2Y]
	sub bx, [p1Y]
	absolute bx
	mov cx, [p2X]
	sub cx, [p1X]
	absolute cx
	mov ax, [p2Y]
lp:
	pusha
	call PIXEL
	popa
	inc [pointY]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = (p2Y - p1Y) = deltay
	add [pointX], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2X - p1X) = daltax
	cmp [pointY], ax ; ax = p2Y
	jne lp
	call PIXEL
ENDM DrawLine2DDY
;---------------------------------------------;
; case: DeltaX is bigger than DeltaY		  ;
; input: p1X p1Y,		            		  ;
; 		 p2X p2Y,		           		      ;
;		 Color -> variable                    ;
; output: line on the screen                  ;
;---------------------------------------------;
Macro DrawLine2DDX p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1Y]
	cmp ax, [p2Y]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2X]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2X]
	sub bx, [p1X]
	absolute bx
	mov cx, [p2Y]
	sub cx, [p1Y]
	absolute cx
	mov ax, [p2X]
lp:
	pusha
	call PIXEL
	popa
	inc [pointX]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = abs(p2X - p1X) = deltax
	add [pointY], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2Y - p1Y) = deltay
	cmp [pointX], ax ; ax = p2X
	jne lp
	call PIXEL
ENDM DrawLine2DDX
Macro absolute a
	local l1
	cmp a, 0
	jge l1
	neg a
l1:
Endm

MODEL small
STACK 100h
DATASEG



BMP_DART_WIDTH = 30
BMP_DART_HEIGHT = 30

BMP_REDBLOON_WIDTH = 12
BMP_REDBLOON_HEIGHT = 12

BMP_TRACK_WIDTH = 320
BMP_TRACK_HEIGHT = 200

Pink = 0EFh




; --------------------------

	;dart shooter BMP File data
	dartShooterUp    db "dUp.bmp",0
    dDown            db "dDown.bmp",0
    dRight           db "dRight.bmp",0
    dLeft            db "dLeft.bmp",0
	
	;Rounds
	;1=red 2=blue 3=green 4=yellow 5=pink
	roundCounter 	dw 	0
	roundOffset 	dw 	10 dup (0)
	round1 			db 	10,	10 dup(1) ;10 red bloons
	round2 			db	15,	10 dup(1),5 dup(2) ; 10 red bloons + 5 blue bloons
	round3 			db	10,	10 dup(2) ; 10 blue bloons
	round4 			db 	15,	10 dup(2),5 dup(3) ; 10 blue bloons + 5 green bloons
	round5 			db	15,	10 dup(3),5 dup(2) ; 10 green bloons + 5 blue bloons
	round6 			db	15,	15 dup(3) ; 15 green bloons
	round7 			db	10,	10 dup(4) ; 10 yellow bloons
	round8 			db	15,	15 dup (4) ; 15 yellow bloons
	round9 			db	15,	10 dup(4),10 dup(5) ; 10 yellow bloons + 10 pink bloons
	round10 		db  20,	20 dup (5) ;20 pink bloons
	
	
	
	;BLOONS DATA STRUCTURE
	bloonIndex 			dw 0 ; has the index for which bloon we want to "manage" right now
	x 					db  0,10,20,30,40,50,60,70,84,101,120,135,150,150,150,148,130,120,107,100,100,100,101,100, 100, 100, 100, 100, 100, 90, 75, 60, 48, 48, 48, 56, 69, 85, 100, 115, 130, 145, 160, 175, 190, 195, 195,195,217,235,235, 235, 235, 235, 235, 227, 213, 196, 182, 171, 156, 142, 138, 138, 138               
	y 					db 78,78,78,78,78,78,78,78,78, 78, 78, 78, 75, 60, 47, 32, 32, 32, 32, 42, 55, 68, 78, 90,  98, 109, 126, 139, 150,153,153,153,150,135,120,110,110,110, 109, 109, 109, 109, 109, 109, 106,  95,  78, 62, 62, 65, 78,  90, 100, 112, 124, 136, 139, 139, 139, 139, 139, 144, 160, 174, 189;end of trail and screen                                         
	bloons 				db 51 dup (0); has the index for the bloon location
	bloonsCount 		dw 1 ; has the number of bloons that current exist
	howManyBloonsStart 	dw 0
	bloonStart 			db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51 ; used for the "startCounter" variable to manage when the bloons will start moving
	bloonLives 			db 51 dup (0) ; has the amount of lives that the bloons have
	startCounter 		db 1 ; help to manage when the bloons will start moving
	
	;DART MONKEY DATA STRUCTURE
	
	DMonkeyIndex 		dw 2 			;has the index for which dart monkey we want to "manage" right now
	DartMonkey 			dw 50 dup  (0) 	;1 - Up 2-Down 3-Right 4-Left, 0 - monkey not placed
	DartMonkeyX 		dw 50 dup  (0) 	;has the x of the monkey position
	DartMonkeyY 		dw 50 dup  (0) 	;has the y of the monkey position
	DartMonkeyRangeX1   dw 50 dup (0)	; has the range of the dart monkey
	DartMonkeyRangeX2   dw 50 dup (0)	; has the range of the dart monkey
	DartMonkeyRangeY1   dw 50 dup (0)	; has the range of the dart monkey
	DartMonkeyRangeY2   dw 50 dup (0)	; has the range of the dart monkey
	DartMonkeyHit 		dw 50 dup (1)	;if the monkey popped baloon the flag will be 1
	DartMonkeyCounter 	dw 2 			;how many dart monkeys are in game right now
	whichDartToPlace 	db 0 			;flag that used when placing dart monkey: 1-Up 2-Down 3-Right 4-Left
	
	
	
	;MouseHandle positions
	Xposition dw 0
	Yposition dw 0
	
	;LIVES
	lives dw 30
	money dw 40
	
	;Time
	seconds db 0
	milSec db 0
	milSecCount db 0
	secCount db 0
	bloonMovedFlag db 0
	
	isEnd 		db 0
	endLoop 	db 0
	firstFlag	db 1
	startFlag 	db 0
	infoFlag 	db 0
	winFlag 	db 0
	
	startIcon db "start.bmp",0
	infoIcon db "info.bmp",0
	rules db "rules.bmp",0
	
	round db "Round:$"
	gameOver db "GAME OVER!$"
	ScrLine 	db 320 dup (0)  ; One picture line read buffer
	
	;track BMP File data
	trackImage	db "track3.bmp",0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	


	
	redBloonName db "red.bmp",0
	blueBloonName db "blue.bmp",0
	greenBloonName db "green.bmp",0
	yellowBloonName db "yellow.bmp",0
	pinkBloonName db "pink.bmp",0
	
	ClearBloonImage db "clear.bmp",0
	
	btdLoading 	db "btd1.bmp",0
	winScreen 	db "win.bmp",0
	loseScreen 	db "lose.bmp",0
	home		db "home.bmp",0
	restart		db "again.bmp",0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0
			  
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
	WhiteMatrix db   BMP_DART_WIDTH*BMP_DART_HEIGHT + 450 dup (255) 
	bloonWhite db BMP_REDBLOON_HEIGHT*BMP_REDBLOON_WIDTH + 450 dup (247)
	clearShootMatrix db 2500 dup (0)
	clearShootPointX dw 0
	clearShootPointY dw 0
	
	xRect dw ?
	yRect dw ?
	lenRect dw ?
	colorRect db ?
	wRect dw ?
	
		   
	; parameter
	matrix dw ?
	
	replay db 0

	TempW dw ?
    pointX dw ? 
	pointY dw ?
    point1X dw ? 
	point1Y dw ?
    point2X dw ? 
	point2Y dw ?
	Color db ?


; --------------------------


CODESEG
start:
	mov ax, @data
	mov ds, ax
	mov ax,0
	int 33h
; --------------------------
@@Game:

	call MouseRegistration
	call initializations

	mov [howManyBloonsStart],10
	mov [bloonsCount],10
	call bloonsMain
	call ending

	call mouseEnd
	cmp [replay],1
	jne @@Game

; --------------------------
	exit:
	call SetText
	mov ax, 4c00h
	int 21h



proc bloonsMain

	mov [bloonIndex],01


@@mainLoop:
	@@innerMain:
		mov si, [bloonIndex]
		cmp [bloonLives + si],0
		je @@continue
		mov bl, [bloonStart + si]
		cmp bl,[startCounter]
		jg @@continue
		
@@update:
		call Update
		cmp [bloonMovedFlag],0
		je @@update
		mov [bloonMovedFlag],0
		
		cmp [lives],0
		jle @@end
		call CheckKeyboard
		cmp [isEnd],0
		jne @@end
		
		@@continue:
		inc [bloonIndex]
		mov bx,[howManyBloonsStart]
		cmp [bloonIndex],bx
		jbe @@innerMain
	inc [startCounter]
	mov [bloonIndex],1
	cmp [bloonsCount],0
	jne @@mainLoop
	
	add [roundCounter],02
	cmp [roundCounter],20
	jge @@won
	
	call StartNewRound
	jmp @@end
	
@@won:
	mov [winFlag],1
	jmp @@end
	

	


@@end:

	mov [isEnd],1
	
ret
endp bloonsMain

proc Update

    mov ah, 02Ch
    int 21h

    cmp [seconds], dh
    jne @@UpdateSeconds
    cmp [milSec], dl
    jne @@UpdateHundredths
    jmp @@End

@@UpdateSeconds:
    mov [seconds], dh
	
		inc [secCount]
		;cmp [secCount],2
		;jb @@End
		call monkeyShoot
		mov [secCount],0
		
    jmp @@End

@@UpdateHundredths:
    mov [milSec], dl
	inc [milSecCount]
	call showLivesMoney
	call clearBloon
	call Bloon
	mov [bloonMovedFlag],1
	
	cmp [milSecCount],8
	jb @@End
	
	
	cmp [milSecCount],12
	jb @@End
	call monkeyShoot
	mov [milSecCount],0
	
	
    jmp @@End

@@End:
    ret
endp Update

;clear the bloons
;input: in [bloonIndex] enter the bloon number
proc clearBloon

	push dx
	push di
	push ax
	push bx
	
	mov ax,02
	int 33h
	
	mov si, [bloonIndex]
	cmp [bloonLives + si],0
	je @@endProc
	
	xor bx,bx
	mov di, [bloonIndex]
	mov bl,[bloons + di]
	
	xor ax,ax
	mov al,[y + bx]
	mov [BmpTop],ax
	mov al,[x + bx]
	mov [BmpLeft], ax
	mov [BmpColSize],12
	mov [BmpRowSize],11
	mov dx, offset ClearBloonImage
	call OpenShowBmp
	
	xor bx,bx
	mov di,[bloonIndex]
	inc	[bloons+di]
	mov bl, [bloons+di]
	
	cmp bl,1
	jg @@checkIfEnd
	jmp @@endProc
	
@@checkIfEnd:
	cmp bl,63
	jbe @@endProc
	xor ax,ax
	mov al,[bloonLives + di]
	sub [lives],ax
	call DestroyBloon
	
@@endProc:
	
	mov ax,01
	int 33h
	
	pop bx
	pop ax
	pop di
	pop dx

ret
endp clearBloon

;input: [bloonIndex]
proc DestroyBloon

	mov di,[bloonIndex]
	

	
	dec [bloonLives + di]
	
	cmp [bloonLives + di],0
	jne @@endProc
	
	xor bx,bx
	mov bl,[bloons + di]
	xor ax,ax
	mov al,[y + bx]
	mov [BmpTop],ax
	mov al,[x + bx]
	mov [BmpLeft], ax
	mov [BmpColSize],12
	mov [BmpRowSize],11
	mov dx, offset ClearBloonImage
	call OpenShowBmp

	dec [bloonsCount]
	mov [bloons+di],0
	
@@endProc:

ret
endp DestroyBloon


;create a new bloon and add him to the bloon data structure
proc Bloon 
	
	push bx
	push dx
	push si
	push ax
	
	mov ax,02
	int 33h
	
	mov si, [bloonIndex]
	cmp [bloonLives + si],0
	je @@endProc
	
	xor bx,bx

	mov bl,[bloons + si]
	cmp bl,63
	jge @@endProc
	xor ax,ax
	mov al,[x + bx]
	mov [BmpLeft],ax
	mov al,[y + bx]
	mov [BmpTop],ax

	
	mov [BmpColSize], 12
	mov [BmpRowSize], 12
	cmp [bloonLives + si],1
	je @@redBloon
	cmp [bloonLives + si],2
	je @@blueBloon
	cmp [bloonLives + si],3
	je @@greenBloon
	cmp [bloonLives + si],4
	je @@yellowBloon
	cmp [bloonLives + si],5
	je @@pinkBloon
	
	
@@pinkBloon:
	mov dx, offset pinkBloonName
	jmp @@print	
	
@@yellowBloon:
	mov dx, offset yellowBloonName
	jmp @@print

@@greenBloon:
	mov dx, offset greenBloonName
	jmp @@print	
	
@@blueBloon:
	mov dx, offset blueBloonName
	jmp @@print
@@redBloon:
	mov dx, offset redBloonName
	jmp @@print

@@print:
	call OpenShowBmp
@@endProc:

	mov ax,01
	int 33h
	
	pop ax
	pop si
	pop dx
	pop bx
ret 
endp Bloon

proc enterRoundsOffsets

mov dx, offset round1
mov [roundOffset],dx
mov dx, offset round2
mov [roundOffset + 2],dx
mov dx, offset round3
mov [roundOffset + 4],dx
mov dx, offset round4
mov [roundOffset + 6],dx
mov dx, offset round5
mov [roundOffset + 8],dx
mov dx, offset round6
mov [roundOffset + 10],dx
mov dx, offset round7
mov [roundOffset + 12],dx
mov dx, offset round8
mov [roundOffset + 14],dx
mov dx, offset round9
mov [roundOffset + 16],dx
mov dx, offset round10
mov [roundOffset + 18],dx


ret
endp enterRoundsOffsets

proc StartNewRound
	
	
	mov di,[roundCounter]
	mov di,[roundOffset + di]
	xor cx,cx
	mov cl,[ di]
	mov [bloonsCount],cx
	mov [howManyBloonsStart],cx
	mov si,1
@@resetBloonsPositionsLives:
	mov di,[roundCounter]
	mov di,[roundOffset + di]
	mov [bloons + si],0
	add di,si
	mov bl,[di]
	mov [bloonLives + si],bl
	inc si
	loop @@resetBloonsPositionsLives
	
	xor ax,ax
	xor bx,bx
	mov bx,[roundCounter]
	; mov al,2
	; div bl
	; mov bl,5
	; mov al,ah
	; xor ah,ah
	; mul bl
	add [money],bx
	
	mov [startCounter],1
	mov [DMonkeyIndex],2
		

	
	call bloonsMain
	
ret
endp StartNewRound


proc initializations 
	call SetGraphic
	
	

	

	call enterRoundsOffsets
	
	mov [roundCounter],0
	
	mov di,[roundCounter]
	mov di,[roundOffset + di]
	xor cx,cx
	mov cl,[ di]
	mov si,1
@@resetBloonsPositionsLives:
	mov di,[roundCounter]
	mov di,[roundOffset + di]
	mov [bloons + si],0
	add di,si
	mov bl,[di]
	mov [bloonLives + si],bl
	inc si
	loop @@resetBloonsPositionsLives
	
	mov [lives],30
	mov [money],60
	mov [startCounter],1
	mov [bloonsCount],1
	mov [isEnd],0
	mov [endLoop],0
	mov [firstFlag],1
	mov [infoFlag],0
	mov [winFlag],0
	mov [startFlag],0
	mov [replay],0
	mov [DartMonkeyCounter],2
	mov [DMonkeyIndex],2
	
	mov si,2
@@resetMonkeyHit:
	mov [DartMonkeyHit + si],1
	mov [DartMonkey + si],0
	mov [DartMonkeyX + si],0
	mov [DartMonkeyY + si],0
	mov [DartMonkeyRangeX1 + si],0
	mov [DartMonkeyRangeX2 + si],0
	mov [DartMonkeyRangeY1 + si],0
	mov [DartMonkeyRangeY2 + si],0
	add si,02
	cmp si,50
	jbe @@resetMonkeyHit
	
	mov ah,2Ch
	int 21h
	mov [seconds],dh
	mov [milSec],dl
	
	mov ax, 0A000h
	mov es, ax
	
	call btdFirstScreen
	
	call screen
	
		
	call showLivesMoney
	
	mov ax,1
	int 33h
ret
endp initializations

proc showLivesMoney
	

	
	
	mov ah, 2
    mov bh, 0
    mov dh, 1
    mov dl, 55
    int 10h
	mov ah,09
	mov dx,offset round
	int 21h
	xor ax,ax
	mov ax,[roundCounter]
	mov bl,2
	div bl
	add ax,1
	call ShowAxDecimal



	mov ah, 2
    mov bh, 0
    mov dh, 21
    mov dl, 75
    int 10h
	mov ax,[money]
	call ShowAxDecimal
	
	
	mov ah, 2
    mov bh, 0
    mov dh, 21
    mov dl, 75
    int 10h
	mov ax,[money]
	call ShowAxDecimal
	
	mov ah,0Ah
	mov al,24h
	mov bh,0
	mov bl,250 ;green
	mov cx,1
	int 10h

	mov ah, 2
    mov bh, 0
    mov dh, 22
    mov dl, 75
    int 10h
	mov ax,[lives]
	call ShowAxDecimal
	
	mov ah,0Ah
	mov al,03
	mov bh,0
	mov bl,01 ;red
	mov cx,01
	int 10h

ret
endp showLivesMoney
proc ending

	mov ax,2
	int 33h
	

	cmp [winFlag],0
	je @@lose
@@win:
	mov dx,offset winScreen
	mov [BmpColSize],320
	mov [BmpRowSize],200
	mov [BmpTop],0
	mov [BmpLeft],0
	call OpenShowBmp
	
	mov [BmpColSize],50
	mov [BmpRowSize],47
	mov [BmpTop],150
	mov [BmpLeft],50
	mov dx,offset home
	call OpenShowBmp
	
	mov [BmpColSize],50
	mov [BmpRowSize],47
	mov [BmpTop],150
	mov [BmpLeft],215
	mov dx,offset restart
	call OpenShowBmp
	
	
	mov ax,1
	int 33h	
	
	jmp @@ret

@@lose:

	
	mov dx,offset loseScreen
	mov [BmpColSize],320
	mov [BmpRowSize],200
	mov [BmpTop],0
	mov [BmpLeft],0
	call OpenShowBmp
	
	mov ah, 2
    mov bh, 0
    mov dh, 17
    mov dl, 55
    int 10h
	mov ah,09
	mov dx,offset round
	int 21h
	xor ax,ax
	mov ax,[roundCounter]
	mov bl,2
	div bl
	add ax,1
	call ShowAxDecimal
	
	mov ax,1
	int 33h	

@@ret:
ret
endp ending

proc mouseEnd
	 @@loop:
	 cmp [endLoop],0
	 je @@loop
	 cmp [endLoop],1
	 je @@ret	 
	 mov [replay],1

@@ret:
ret
endp mouseEnd

proc CheckKeyboard ;check if ESC key was pressed
	push ax
	mov ah,01
	int 16h
	jz @@end
	mov ah,0
	int 16h
	cmp ah,1
	jne @@end
	mov [isEnd],01
	
@@end:
	pop ax
ret
endp CheckKeyboard
proc MouseRegistration
	push ds
	pop  es	 
	mov ax, seg MyMouseHandle 
	mov es, ax
	mov dx, offset MyMouseHandle  
    mov ax,0Ch           
    mov cx,06h ; only if mouse button pressed or released
    int 33h                   
ret
endp MouseRegistration
proc MyMouseHandle far
	
	 shr cx,1
	 mov bh,0
	 sub dx,1
	 mov [Xposition],cx
	 mov [Yposition],dx
	 
	 cmp ax,02h
	 je @@pressed
	 cmp ax,04h
	 je @@released
@@pressed:

	cmp [firstFlag],1
	jne @@notFirst
	cmp [Yposition],140
	jb @@end4
	cmp [Yposition],191
	jg @@end4	
	cmp [Xposition],90
	jb @@end4
	cmp [Xposition],190
	jg @@notPlay
	mov [startFlag],1
	jmp @@end4

@@notPlay:
	cmp [Xposition],240
	jg @@end4
	mov [infoFlag],1
	jmp @@end4
	
@@notFirst:
	cmp [isEnd],1
	je @@notDartMonkey  ;relative jump to @@end
	
@@placeMonkey: ;Check If Dart Monkey Left

	 cmp cx,282
	 jnge @@notDartMonkey
	 cmp cx,297
	 jnbe @@notDartLeft
	 cmp dx,14
	 jnge @@notDartMonkey
	 cmp dx,30
	 jnbe @@notDartLeft
	 mov [whichDartToPlace],4
	 jmp @@end
	 
@@notDartLeft: ;Check If Dart Monkey Right

	 cmp cx,297
	 jnbe @@notDartRight
	 cmp dx,31
	 jnge @@notDartRight
	 cmp dx,47
	 jnbe @@notDartMonkey
	 mov [whichDartToPlace],3
	 jmp @@end
	 
@@notDartRight: ;Check If Dart Monkey Up
	 cmp cx,300
	 jnge @@notDartUp
	 cmp cx,315
	 jnbe @@notDartMonkey
	 cmp dx,31
	 jnge @@notDartUp
	 cmp dx,47
	 jnbe @@notDartMonkey
	 mov [whichDartToPlace],1
	 jmp @@end

@@notDartUp: ;Check If Dart Monkey Down
	 cmp cx,300
	 jnge @@notDartMonkey
	 cmp dx,30
	 jnbe @@notDartMonkey
	 mov [whichDartToPlace],2
	 jmp @@end

@@notDartMonkey:
	 jmp @@end
	 



@@released:
		cmp [isEnd],01
		je @@ended3
		
		cmp [money],40
		jb @@end4
@@checkIfPlaceOnTrail:
		cmp [Xposition],12
		jb @@end4
		cmp [Xposition],267
		jg @@end4
		cmp [Yposition],188
		jg @@end4
		cmp [Yposition],12
		jb @@end4
		
		cmp [Yposition],133
		jb @@NEXT
		cmp [Xposition],72
		jb @@NEXT
		cmp [Yposition],142
		jg @@NEXT
		cmp [Xposition],84
		jbe @@notOnTrail1
		jmp @@NEXT
@@end4:
	jmp @@end3
@@ended3:
	jmp @@ended2
@@NEXT:
		cmp [Xposition],83
		jg @@next_XgreaterThan83
		cmp [Yposition],64
		jbe @@notOnTrail1
		
		cmp [Yposition],90
		jb @@end3
		
		cmp [Xposition],31
		jbe @@notOnTrail1
		
		
		cmp [Yposition],98
		jb @@end3
		
		cmp [Yposition],101
		jbe @@notOnTrail1
		
		cmp [Yposition],133
		jb @@end3

		cmp [Yposition],143
		jg @@YgreaterThan143
		cmp [Xposition],72
		jbe @@notOnTrail1
@@YgreaterThan143:
		cmp [Yposition],180
		jbe @@end3
		cmp [Yposition],188
		jbe @@notOnTrail1
		jmp @@next_XgreaterThan83
@@notOnTrail1:
jmp @@notOnTrail
@@ended2:
jmp @@ended1
@@end3:
jmp @@end2
@@next_XgreaterThan83:
	cmp [Yposition],181
	jb @@YlowerThan181
	cmp [Xposition],122
	jbe @@notOnTrail1
@@YlowerThan181:
	cmp [Xposition],124
	jb @@end3
	cmp [Yposition],20
	jbe @@notOnTrail1
	cmp [Xposition],179
	jge @@XgreaterThan179
	cmp [Yposition],54
	jb @@end3
	cmp [Xposition],138
	jg @@XgreaterThan138
	cmp [Yposition],64
	jbe @@notOnTrail1
@@XgreaterThan138:
	cmp [Yposition],99
	jbe @@end3
	cmp [Yposition],101
	jbe @@notOnTrail1
	cmp [Yposition],127
	jbe @@end3
	cmp [Yposition],130
	jbe @@notOnTrail1
	cmp [Yposition],162
	jbe @@end3
	cmp [Xposition],162
	jb @@end3
	
	jmp @@notOnTrail1
@@XgreaterThan179:
	cmp [Yposition],49
	jbe @@notOnTrail1
	cmp [Yposition],64
	jbe @@end2
	cmp [Xposition],182
	jg @@XgreaterThan182
	cmp [Yposition],96
	jb @@notOnTrail
	cmp [Yposition],127
	jbe @@end2
	cmp [Yposition],130
	jbe @@notOnTrail
	cmp [Yposition],164
	jbe @@end2
	
@@XgreaterThan182:
	cmp [Yposition],164
	jg @@notOnTrail
	cmp [Xposition],223
	jg @@XgreaterThan223
	cmp [Yposition],120
	jge @@YgreaterThan120
	cmp [Xposition],223
	je @@notOnTrail
	cmp [Xposition],222
	je @@notOnTrail
	jmp @@end2
@@YgreaterThan120:
	cmp [Yposition],126
	jbe @@notOnTrail
	jmp @@end2
@@XgreaterThan223:
	cmp [Xposition],248
	jbe @@end2
	cmp [Yposition],145
	jge @@notOnTrail
	cmp [Xposition],260
	jb @@end2
	jmp @@notOnTrail
	
	
	
	
@@end2:
	jmp @@end
@@ended1:
	jmp @@ended



@@notOnTrail:
		
		
@@startPlacing:	
		
		cmp [whichDartToPlace],0
		je @@end
		
		cmp [Xposition],280
		jge @@end
		
		mov ax,[Xposition]
		mov [BmpLeft],ax
		mov ax,[Yposition]
		mov [BmpTop],ax	
		sub [BmpTop],12
		sub [BmpLeft],12
		
		call CreateDartMonkey
		
		jmp @@end
@@ended:	
	 cmp [winFlag],1
	 je @@win
	 cmp [Yposition],162
	 jb @@end
	 cmp [Yposition],198
	 jg @@end
	 cmp [Xposition],81
	 jb @@end
	 cmp [Xposition],137
	 jnbe @@checkPlayAgain1
	 mov [endLoop],02
	 jmp @@end
  @@checkPlayAgain1:
	 cmp [Xposition],182
	 jb @@end
	 cmp [Xposition],239
	 jnbe @@end
	 mov [endLoop],01
	 jmp @@end
@@win:
	 cmp [Yposition],150
	 jb @@end
	 cmp [Yposition],198
	 jg @@end
	 cmp [Xposition],50
	 jb @@end
	 cmp [Xposition],100
	 jnbe @@checkPlayAgain
	 mov [endLoop],02
	 jmp @@end
  @@checkPlayAgain:
	 cmp [Xposition],215
	 jb @@end
	 cmp [Xposition],265
	 jnbe @@end
	 mov [endLoop],01
	 jmp @@end
	
		
 @@end:	

retf
endp MyMouseHandle

proc screen

	
	push si
	push ax
	push dx
	
	mov ax,02
	int 33h
	
	mov [BmpTop],0
	mov [BmpLeft],0
	mov [BmpColSize],320
	mov [BmpRowSize],200
	mov dx, offset trackImage
	call OpenShowBmp

	mov [BmpColSize],12
	mov [BmpRowSize],11
	mov dx,offset ClearBloonImage
	mov cx,65
	mov si,0
@@placeBloonSpots:
		xor ax,ax
		mov al,[x+si]
		mov [BmpLeft],ax
		mov al,[y+si]
		mov [BmpTop],ax
		call OpenShowBmp
		inc si
		loop @@placeBloonSpots
		

@@endProc:

	pop dx
	pop ax	
	pop si

ret
endp screen

;input: [DMonkeyIndex],[bloonIndex] in stack
proc drawShoot

	mov ax,02
	int 33h
	
	push [DMonkeyIndex]
	push [bloonIndex]
	push si
	push di
	
	push [bloonIndex]
	call GetBloonXInBl
	mov [point1X],bx
	
	push [bloonIndex]
	call GetBloonYInBl
	mov [point1Y],bx
	
	mov di,[DMonkeyIndex]
	mov bx,[DartMonkeyX + di]
	add bx,12
	mov [point2X],bx
	mov bx,[DartMonkeyY + di]
	add bx,12
	mov [point2Y],bx
	
	call saveShootBG
	
	mov [Color],0
	call DrawLine2D
		
	mov ax,01
	int 33h
	
	pop di
	pop si
	pop [bloonIndex]
	pop [DMonkeyIndex]
		
ret
endp drawShoot

;input: point1X,point1Y,point2X,point2Y
proc saveShootBG 

	push ax
	push di
	push si
	push bx
	push cx

	mov ax,[point1Y]
	cmp ax,[point2Y]
	jb @@point1Higher
	mov di,[point2Y]
	jmp @@checkLeft
@@point1Higher:
	mov di,ax
	jmp @@checkLeft

@@checkLeft:
	mov ax,[point1X]
	cmp ax,[point2X]
	jb @@point1Left
	mov si,[point2X]
	jmp @@continue
@@point1Left:

	mov si,ax
	jmp @@continue
	
	
@@continue:
		mov [clearShootPointX],si
		mov [clearShootPointY],di 
		mov cx,50
		mov bx,offset clearShootMatrix
@@loop:
		push cx
		push si
		mov cx,50
	@@loop2:
		push cx
		push bx
		
		mov bh,0
		mov cx,si
		mov dx,di
		mov ah,0Dh
		int 10h
		pop bx
		pop cx
		mov [bx],al
		inc bx
		inc si
		loop @@loop2
	inc di
	pop si
	pop cx
	loop @@loop
	
	
	pop cx	
	pop bx	
	pop si	
	pop di	
	pop ax

ret
endp saveShootBG

; input: xPoint yPoint (stack), returns ax = pix
proc coords_to_pix
    push bp
    mov bp, sp

    xPoint equ [bp+6]
    yPoint equ [bp+4]

    push dx
    push bx

    mov ax, yPoint

    mov bx, 320

    xor dx, dx
    mul bx

    add ax, xPoint

    pop bx
    pop dx

    pop bp
    ret 4
endp coords_to_pix

;input: [clearShootPointY],[clearShootPointX]
proc ClearShoot
	
	push di
	push ax
	push cx
	push dx
	
	mov ax,02
	int 33h
	
	push [clearShootPointX]
	push [clearShootPointY]
	call coords_to_pix
	mov di,ax
	mov dx,50
	mov cx,50
	mov [matrix],offset clearShootMatrix
	call putMatrixInScreen
	
	mov ax,01
	int 33h
	
	pop dx	
	pop cx	
	pop ax	
	pop di


ret
endp ClearShoot


proc monkeyShoot

	push di
	push si
	push bx
	push ax
	push [bloonIndex]
	push cx
	push [DMonkeyIndex]
	
	cmp [DartMonkeyCounter],2
	je @@endProc
	

	
	mov di,[DartMonkeyCounter]
	mov si,[howManyBloonsStart]
	
@@CheckBloon:
	mov [DMonkeyIndex],di
	mov [bloonIndex],si
	
	cmp [DartMonkeyHit + di],0
	je @@NextMonkey
	
	push [bloonIndex]
	call GetBloonXInBl

	cmp bx,[DartMonkeyRangeX1 + di]
	jb @@checkAlt
	jmp @@next1
@@checkAlt:
	cmp bx,[DartMonkeyRangeX2 + di]
	jb @@NextBloon
@@next1:	
	add bl,6
	cmp bx,[DartMonkeyRangeX2 + di]
	jg @@checkAlt2
	jmp @@next2
@@checkAlt2:
	cmp bx,[DartMonkeyRangeX1 + di]
	jg @@NextBloon

@@next2:

	push [bloonIndex]
	call GetBloonYInBl
	cmp bx,[DartMonkeyRangeY1 + di]
	jb @@checkAlt3
	jmp @@next3
@@checkAlt3:
	cmp bx,[DartMonkeyRangeY2 + di]
	jb @@NextBloon
@@next3:
	
	add bl,6
	cmp bx,[DartMonkeyRangeY2 + di]
	jg @@checkAlt4
	jmp @@next4
@@checkAlt4:
	cmp bx,[DartMonkeyRangeY1 + di]
	jg @@NextBloon
@@next4:
	jmp @@OnRange
	
	
@@OnRange:
	mov di,[DMonkeyIndex]
	mov si,[bloonIndex]
	
	call drawShoot
	mov [DartMonkeyHit+ di],0
	call OpenSpeaker
	call DoLa
	add [money],1
	call DoDelay
	call ClearShoot
	call DestroyBloon
	call CloseSpeaker
	
@@NextBloon:
	cmp [bloonIndex],0
	jle @@NextMonkey
	dec [bloonIndex]
	mov si,[bloonIndex]
	jmp @@CheckBloon
@@NextMonkey:
	cmp [DMonkeyIndex],0
	jle @@endProc
	sub [DMonkeyIndex],2
	sub di,2
	mov si,[howManyBloonsStart]
	jmp @@CheckBloon

@@endProc:

	mov si,0
	@@resetMonkeyHit1:
	mov [DartMonkeyHit + si],1
	inc si
	cmp si,50
	jng @@resetMonkeyHit1
	
	
	
	pop [DMonkeyIndex]
	pop cx
	pop [bloonIndex]
	pop ax
	pop bx
	pop si
	pop di



ret
endp monkeyShoot

;input [BloonIndex] in stack
;output: bloon X in bl
proc GetBloonXInBl
	
	pop ax
	
	pop si
	
	push si
	
	xor bx,bx
	mov bl,[bloons + si]
	mov si,bx
	mov bl,[ x + si]
	
	pop si
	
	push ax
ret
endp GetBloonXInBl

;input [BloonIndex] in stack
;output: bloon Y in bl
proc GetBloonYInBl
	
	pop ax
	
	pop si
	
	push si
	
	xor bx,bx
	mov bl,[bloons + si]
	mov si,bx
	mov bl,[ y + si]

	pop si

	push ax
ret
endp GetBloonYInBl

;input BmpLeft BmpTop whichDartToPlace
proc CreateDartMonkey
	mov ax,02
	int 33h
		cmp [whichDartToPlace],1
		jne @@notUp
		call dartUp
		jmp @@end
@@notUp:
		cmp [whichDartToPlace],2
		jne @@notDown
		call dartDown
		jmp @@end
@@notDown:
		cmp [whichDartToPlace],3
		jne @@notRight
		call dartRight		
		jmp @@end
@@notRight:
		cmp [whichDartToPlace],4
		jne @@end
		call dartLeft
		jmp @@end

		
@@end:
		xor ax,ax
		mov si,[DartMonkeyCounter]
		mov ax,[BmpLeft]
		mov [DartMonkeyX + si],ax
		mov ax,[BmpTop]
		mov [DartMonkeyY + si],ax
@@determineRange:
		xor ax,ax
		cmp [whichDartToPlace],1
		jne @@RangeDown
		mov [DartMonkey + si],1
		mov ax,[BmpLeft]
		mov [DartMonkeyRangeX1 + si],ax
		sub [DartMonkeyRangeX1 + si],10
		mov [DartMonkeyRangeX2 + si],ax
		add [DartMonkeyRangeX2 + si],40
		mov ax,[BmpTop]
		add ax,30
		mov [DartMonkeyRangeY1 + si],ax
		sub ax,45
		mov [DartMonkeyRangeY2 + si],ax
		jmp @@endProc
		
@@RangeDown:
		cmp [whichDartToPlace],2
		jne @@RangeRight
		mov [DartMonkey + si],2
		mov ax,[BmpLeft]
		mov [DartMonkeyRangeX1 + si],ax
		sub [DartMonkeyRangeX1 + si],10
		mov [DartMonkeyRangeX2 + si],ax
		add [DartMonkeyRangeX2 + si],40
		mov ax,[BmpTop]
		mov [DartMonkeyRangeY1 + si],ax
		add [DartMonkeyRangeY1 + si],15
		mov [DartMonkeyRangeY2 + si],ax
		add [DartMonkeyRangeY2 + si],55
		jmp @@endProc
		
@@RangeRight:
		cmp [whichDartToPlace],3
		jne @@RangeLeft
		mov [DartMonkey + si],3
		mov ax,[BmpLeft]
		mov [DartMonkeyRangeX1 + si],ax
		add [DartMonkeyRangeX1 + si],25
		mov [DartMonkeyRangeX2 + si],ax
		add [DartMonkeyRangeX2 + si],55
		mov ax,[BmpTop]
		mov [DartMonkeyRangeY1 + si],ax
		sub [DartMonkeyRangeY1 + si],10
		mov [DartMonkeyRangeY2 + si],ax
		add [DartMonkeyRangeY2 + si],40
		jmp @@endProc

@@RangeLeft:
		cmp [whichDartToPlace],4
		jne @@endProc
		mov [DartMonkey + si],4
		mov ax,[BmpLeft]
		mov [DartMonkeyRangeX2 + si],ax
		mov [DartMonkeyRangeX1 + si],ax
		sub [DartMonkeyRangeX1 + si],30
		mov ax,[BmpTop]
		mov [DartMonkeyRangeY1 + si],ax
		sub [DartMonkeyRangeY1 + si],10
		mov [DartMonkeyRangeY2 + si],ax
		add [DartMonkeyRangeY2 + si],40
@@endProc:
		add [DartMonkeyCounter],02
		mov [whichDartToPlace],0	
		sub [money],40



mov ax,1
int 33h

ret
endp CreateDartMonkey

proc dartUp

	push [BmpLeft]
	push [BmpTop]
	

	mov [BmpColSize], 25
	mov [BmpRowSize], 25
	mov dx, offset dartShooterUp
	call OpenShowBmp

	pop [BmpTop]
	pop [BmpLeft]
	
ret 
endp dartUp
proc dartDown
	
	push [BmpLeft]
	push [BmpTop]
	

	mov [BmpColSize], 25
	mov [BmpRowSize], 25
	mov dx, offset dDown
	call OpenShowBmp

	pop [BmpTop]
	pop [BmpLeft]
ret 
endp dartDown
proc dartLeft

	push [BmpLeft]
	push [BmpTop]
	

	mov [BmpColSize], 25
	mov [BmpRowSize], 25
	mov dx, offset dLeft
	call OpenShowBmp

	pop [BmpTop]
	pop [BmpLeft]
ret 
endp dartLeft
proc dartRight

	push [BmpLeft]
	push [BmpTop]
	
	

	mov [BmpColSize], 25
	mov [BmpRowSize], 25
	mov dx, offset dRight
	call OpenShowBmp
	
	pop [BmpTop]
	pop [BmpLeft]

ret 
endp dartRight



proc btdFirstScreen
	
	
	mov dx, offset btdLoading
	mov [BmpLeft], 10
	mov [BmpTop], 0
	mov [BmpColSize], 300
	mov [BmpRowSize], 200
	call OpenShowBmp
	
	mov [BmpLeft],90
	mov [BmpTop],140
	mov [BmpColSize],100
	mov [BmpRowSize],51
	mov dx,offset startIcon
	call OpenShowBmp
	
	mov [BmpLeft],190
	mov [BmpTop],140
	mov [BmpColSize],50
	mov [BmpRowSize],50
	mov dx,offset infoIcon
	call OpenShowBmp
	
	mov ax,1
	int 33h
	
@@loop:
	cmp [startFlag],1
	je @@endProc
	cmp [infoFlag],1
	je @@showInfo
	jmp @@loop
@@showInfo:
	mov ax,02
	int 33h
	mov dx,offset rules
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize],320
	mov [BmpRowSize],200
	call OpenShowBmp
	mov ah,01
	int 21h

@@endProc:
	mov [firstFlag],0
	mov [startFlag],0
	mov ax,1
	int 33h
ret
endp btdFirstScreen	



;---------------------------------------------;
; input: point1X point1Y,         ;
; 		 point2X point2Y,         ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
PROC DrawLine2D
	mov cx, [point1X]
	sub cx, [point2X]
	absolute cx
	mov bx, [point1Y]
	sub bx, [point2Y]
	absolute bx
	cmp cx, bx
	jae DrawLine2Dp1 ; deltaX > deltaY
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp cx, dx
	jbe DrawLine2DpNxt1 ; point1Y <= point2Y
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt1:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDY point1X, point1Y, point2X, point2Y
	ret
DrawLine2Dp1:
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp ax, bx
	jbe DrawLine2DpNxt2 ; point1X <= point2X
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt2:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDX point1X, point1Y, point2X, point2Y
	ret
ENDP DrawLine2D
;-----------------------------------------------;
; input: pointX pointY,      					;
;           Color								;
; output: point on the screen					;
;-----------------------------------------------;
PROC PIXEL
	mov bh,0h
	mov cx,[pointX]
	mov dx,[pointY]
	mov al,[Color]
	mov ah,0Ch
	int 10h
	ret
ENDP PIXEL

; in dx - new color 
proc putColorInScreen
	push ds
	push es
	push ax
	push si
	xor si,si
	mov ax, 0A000h
	mov es, ax
	mov ds, ax
	cld ; for movsb direction ds:si --> es:di
	mov cx, 64000	; full screen
	mov [si], dx ; put color in [si]
	mov si, 0 ; starts from the first pixel
	mov di, 1 ; copies prev pixel to the next one, [0]-->[1], [1]-->[2], 
	
	rep movsb ; Copy whole line to the screen, si and di advances in movsb
	
	pop si
	pop ax
	pop es
	pop ds
    ret
endp putColorInScreen		
	
	
; input dx FileName
proc OpenShowBmp near
	push ax
	push cx
	push dx
	push di
	push si
	push bx
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	pop bx
	pop si
	pop di
	pop dx
	pop cx
	pop ax
	ret
endp OpenShowBmp		
	
	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],0
@@ExitProc:	
	ret
endp OpenBmpFile	
	

; input [FileHandle]
proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile


; Read and skip first 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader

; Read BMP file color palette, 256 colors * 4 bytes (400h)
; 4 bytes for each color BGR (3 bytes) + null(transparency byte not supported)	
proc ReadBmpPalette near 		
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette
	
	
	
; Will move out to screen memory the pallete colors
; video ports are 3C8h for number of first color (usually Black, default)
; and 3C9h for all rest colors of the Pallete, one after the other
; in the bmp file pallete - each color is defined by BGR = Blue, Green and Red
proc CopyBmpPalette		near					

	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.(4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette	
	
	
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
    push cx
    
    mov ax, 0A000h
    mov es, ax
    
    mov cx,[BmpRowSize]
    
 
    mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
    xor dx,dx
    mov si,4
    div si
    cmp dx,0
    mov bp,0
    jz @@row_ok
    mov bp,4
    sub bp,dx

@@row_ok:    
    mov dx,[BmpLeft]
    
@@NextLine:
    push cx
    push dx
    
    mov di,cx  ; Current Row at the small bmp (each time -1)
    add di,[BmpTop] ; add the Y on entire screen
    
 
    ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
    mov cx,di
    shl cx,6
    shl di,8
    add di,cx
    add di,dx
     
    ; small Read one line
    mov ah,3fh
    mov cx,[BmpColSize]  
    add cx,bp  ; extra  bytes to each row must be divided by 4
    mov dx,offset ScrLine
    int 21h
    
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,[BmpColSize]  
    mov si,offset ScrLine
    
    ;rep movsb ; Copy line to the screen
 @@DRAWLINE:
    
    cmp [byte ptr si], Pink
    jnz @@NOTCHARACTER
    
    inc si
    inc di
    jmp @@DontDraw
    
@@NOTCHARACTER:
    
    movsb ; Copy line to the screen
    
@@DontDraw:
    loop @@DRAWLINE
    
    pop dx
    pop cx
    
    loop @@NextLine
    
    pop cx
    ret
endp ShowBMP 
	
	
; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

proc putMatrixInScreen
	push es
	push ax
	push si
	
	mov ax, 0A000h
	mov es, ax
	cld ; for movsb direction si --> di
	
	
	mov si,[matrix]
	
NextRow:	
	push cx
	
	mov cx, dx
	rep movsb ; Copy whole line to the screen, si and di advances in movsb
	sub di,dx ; returns back to the begining of the line 
	add di, 320 ; go down one line by adding 320
	
	
	pop cx
	loop NextRow
	
		
	pop si
	pop ax
	pop es
    ret
endp putMatrixInScreen	
	
proc DoDelay
	push cx
	mov cx, 50
	Delay1:
		push cx
		mov cx, 6000
		Delay2:
			loop Delay2
		pop cx
	loop Delay1
	pop cx
	ret
endp DoDelay

proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal		

proc CloseSpeaker

	in al,61h
	and al,11111100b
	out 61h,al

ret
endp CloseSpeaker	

proc OpenSpeaker

	in al,61h
	or al,00000011b
	out 61h,al
	
	mov al,0B6h
	out 43h,al
	
ret
endp OpenSpeaker

proc DoLa

	mov al,98h
	out 42h,al
	mov al,0Ah
	out 42h,al

ret
endp DoLa

proc  SetText
	push ax
	mov ax,2h  
	int 10h
	pop ax
ret
endp 	SetText		
	
proc  SetGraphic
	mov ax,13h   
	int 10h
	ret
endp 	SetGraphic
	
proc DrawPallete
push cx

xor ax,ax
mov [xRect], 0
mov [yRect],0
mov [lenRect],8
mov [wRect],8
mov cx,16
@@loop2:
		push cx
		mov cx,16
	@@loop1:
			mov [colorRect],al
			call DrawFullRect
			inc al
			add [xRect],8
			loop @@loop1
		add [yRect],8
		mov [xRect],0

		pop cx
	loop @@loop2



pop cx
ret
endp DrawPallete
proc DrawVerticalLine
	push cx
	
	mov cx,[lenRect]
	xor si,si
@@loop:
		push cx
		mov cx,[xRect]
		mov ah,0Ch
		mov al,[colorRect]
		mov dx,[yRect]
		add dx,si
		mov bh,0
		int 10h
		pop cx
		inc si
		loop @@loop
	
	

	pop cx
ret
endp DrawVerticalLine
proc DrawFullRect
	push cx

	mov cx,[wRect]
	xor si,si
@@loop:
		push cx
		call DrawVerticalLine
		inc [xRect]
		pop cx
		loop @@loop
		
pop cx
ret
endp DrawFullRect	


END start


