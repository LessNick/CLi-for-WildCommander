;---------------------------------------
; Amiga Boing example
;---------------------------------------
		org	#c000-4

tableHalf	equ	2520

bitmapYSm	equ	#00					; смещение по оси Y внутри bitmap делённое на 8
								; addr: bitmapYSm 3 * 8 = 24 pixel
								; 24 * 256 (если 16 цветные спрайты) получаем смещение #1800
								; данные спрайта начнутся с #d800

BoingStart	
		db	#7f,"CLA"				; Command Line Application

		ld	hl,boingMsg
		call	printString
		
		ld	hl,infoMsg
		call	printString		

		call	clearGfxScreen

		ld	hl,loadPalMsg
		call	printString

		call	chToHomePath				; установить «домашнюю» директорию

		ld	hl,boingPalFile
		ld	a,resPal
		call	loadResource
		call	printOkStatus

		ld	hl,loadSprMsg
		call	printString

		ld	hl,boingSprFile
		ld	c,bitmapYSm
		ld	a,resSpr
		call	loadResource
		call	printOkStatus

		call	chToCallPath				; восстановить директорию вызова

		ld	hl,appRunMsg
		call	printString
		
		halt
		call	printWW					; печать

		ld	a,#02
		call	setCliGfxResol
		ld	a,#01
		call	setScreen

		call	enableSprites

		call	prepareTable

		ld	bc,tableHalf
		ld	(tableCount+1),bc

		ld	a,bitmapYSm
		ld	hl,#0802			; l = (#01+1) * ~20 = 40ms на 1 кадр, h - #08 кадров анимации
		ld	de,#0404			; ширина / 8 px , высота /8 px
		call	createSprite

sprMove		halt

		call	updateSprite
		call	printWW	

		ld	hl,(timeCount)
		inc	hl
		ld	(timeCount),hl
		ld	de,timeCountMsg
		call	int2str
	
		ld 	hl,boingPosMsg
		call	printInLine

		call	checkKeyEsc
		jp	nz,BoingStop

tableAddr	ld	hl,jumpTable
		ld	a,(hl)
		ld	e,a
		inc	hl
		ld	a,(hl)
		ld	d,a
		inc	hl
		call	setSpriteX

		push	hl
		ex	de,hl
		ld	de,posXMsg
		call	int2str
		pop	hl

		ld	a,(hl)
		ld	e,a
		inc	hl
		ld	a,(hl)
		ld	d,a
		inc	hl
		call	setSpriteY
		
		push	hl
		ex	de,hl
		ld	de,posYMsg
		call	int2str
		pop	hl

tableCount	ld	bc,tableHalf
		dec	bc
		dec	bc
		dec	bc
		dec	bc
		ld	a,b
		or	c
		jr	nz,tableSet
		ld	hl,jumpTable
		ld	bc,tableHalf

tableSet	ld	(tableCount+1),bc
		ld	(tableAddr+1),hl
		jp	sprMove
;
BoingStop	call	editInit

		call	disableSprites

		xor	a
		call	setScreen
		call	clearGfxScreen
		
		ld	hl,appExitMsg
		call	printString
		xor	a			; no error, clean exit!
		ret

;---------------------------------------
prepareTable	ld	bc,tableHalf
		ld	hl,jumpPart-1		; подготавливаем зеркальную копию таблицы
		ld	de,jumpPart

prepareLoop	push	bc
		ld	a,(hl)			; x мл.
		ld	c,a
		dec	hl
		ld	a,(hl)			; x ст.
		ld	b,a
		dec	hl
		ld	a,(hl)			; y мл.
		ex	af,af'
		dec	hl
		ld	a,(hl)			; y ст.
		dec	hl

		ld	(de),a			; y ст.
		inc	de
		ex	af,af'			; y мл.
		ld	(de),a
		inc	de
		ld	a,b			; x ст.
		ld	(de),a
		inc	de
		ld	a,c			; x мл.
		ld	(de),a
		inc	de

		pop	bc
		dec	bc
		dec	bc
		dec	bc
		dec	bc
		ld	a,b
		or	c
		jr	nz,prepareLoop
		ret

boingPalFile	db	"boing.pal",#00
boingSprFile	db	"boing.bin",#00

boingPosMsg	db	16,colorOk,"Boing at posX=",16,16
posXMsg		db	"     "
		db	16,14,",",16,colorOk," posY=",16,16
posYMsg		db	"     "
		db	16,14,".",16,colorOk," Time count=",16,16
timeCountMsg	db	"     "
		db	#00

timeCount	dw	#0000

infoMsg		db	16,2,"Amiga Boing (GLi demo) v 0.03",#0d
		db	16,3,"2012,2013 ",#7f," Breeze\\\\Fishbone Crew",#0d,#0d,#00

		;DISPLAY "loadPalMsg=",/A,loadPalMsg

loadPalMsg	db	16,colorInfo,"Loading palette... ",#00
loadSprMsg	db	16,colorInfo,"Loading sprites... ",#00
appRunMsg	db	#0d,16,colorInfo,"Runing...",#0d,#0d
		db	16,16
		db	#00
appExitMsg	db	16,colorInfo,"Exit.",#0d
		db	16,16
		db	#00

boingMsg	db	16,16,#0d
		db	"               /|___                 ",#0d
		db	"        .__   / (___)                ",#0d
		db	"  _____ |  \\\\_/  |   | ______. _____  ",#0d
		db	"./     \\\\|  \\\\_/  |   |/   ___|/     \\\\.",#0d
		db	"|   |   |   |   |~  |  _|___|   |   |",#0d
		db	"|  _|_  |   |   |   |  \\\\__  |  _|_  |",#0d
		db	"|  \\\\_   |   |   |   |   |   |~ \\\\_   |",#0d
		db	"|   |   |~  |   |   |   |   |   |   |",#0d
		db	"|   |   |   |   |   |   |   |   |   |",#0d
		db	"|   |   |   |   |   |~  |   |   |   |",#0d
		db	"|   |   |   |   |   |   |   |___|  ^|",#0d
		db	"|   |___|___|___|___|\\\\__|__/~zOu|   |",#0d
		db	"|___|~                          |___|",#0d
		db	"              b o i n g              ",#0d,#0d
		db	#00

jumpTable	dw	288,210,287,201
		dw	287,193,287,184,287,176,287,168,287,160,287,151,287,143,287,136
		dw	287,128,287,120,286,113,286,105,286,98,286,91,286,84,285,77
		dw	285,71,285,65,285,59,284,53,284,48,284,42,283,37,283,33
		dw	283,28,282,24,282,20,281,17,281,14,281,11,280,8,280,6
		dw	279,4,279,3,278,1,278,0,277,0,277,0,276,0,276,0
		dw	275,1,274,2,274,3,273,5,273,7,272,9,271,12,271,15,270,19
		dw	269,22,268,26,268,30,267,35,266,40,266,45,265,50,264,56,263,62
		dw	262,68,262,74,261,80,260,87,259,94,258,101,257,109,256,116
		dw	255,124,255,131,254,139,253,147,252,155,251,163,250,172,249,180
		dw	248,188,247,197,246,205,245,206,244,197,243,189,242,181,241,172
		dw	240,164,239,156,237,148,236,140,235,132,234,124,233,117,232,109
		dw	231,102,230,95,228,88,227,81,226,74,225,68,224,62,223,56
		dw	221,51,220,45,219,40,218,35,216,31,215,26,214,22,213,19
		dw	211,15,210,12,209,10,208,7,206,5,205,3,204,2,202,1
		dw	201,0,200,0,198,0,197,0,196,0,194,1,193,2,192,4
		dw	190,6,189,8,188,11,186,14,185,17,183,20,182,24,181,28
		dw	179,32,178,37,176,42,175,47,174,53,172,58,171,64,169,71
		dw	168,77,167,84,165,90,164,97,162,105,161,112,159,119,158,127
		dw	157,135,155,143,154,151,152,159,151,167,149,175,148,184,146,192
		dw	145,200,144,209,142,202,141,193,139,185,138,177,136,168,135,160
		dw	134,152,132,144,131,136,129,128,128,121,126,113,125,106,124,99
		dw	122,91,121,85,119,78,118,72,116,65,115,59,114,54,112,48
		dw	111,43,109,38,108,33,107,29,105,25,104,21,102,17,101,14
		dw	100,11,98,9,97,6,96,4,94,3,93,1,92,0,90,0,89,0
		dw	88,0,86,0,85,1,84,2,82,3,81,5,80,7,78,9
		dw	77,12,76,15,75,18,73,22,72,26,71,30,70,35,68,39
		dw	67,44,66,50,65,55,63,61,62,67,61,73,60,80,59,87
		dw	58,94,56,101,55,108,54,115,53,123,52,131,51,139,50,146
		dw	49,155,48,163,46,171,45,179,44,188,43,196,42,204,41,206
		dw	40,198,39,190,38,181,37,173,36,165,35,156,34,148,34,140,33,133
		dw	32,125,31,117,30,110,29,102,28,95,27,88,26,82,26,75
		dw	25,69,24,63,23,57,22,51,22,46,21,41,20,36,19,31
		dw	19,27,18,23,17,19,17,16,16,13,15,10,15,7,14,5
		dw	13,4,13,2,12,1,12,0,11,0,10,0,10,0,9,0
		dw	9,1,8,2,8,4,7,6,7,8,6,10,6,13,6,16
		dw	5,20,5,24,4,28,4,32,4,37,3,42,3,47,3,52
		dw	2,58,2,64,2,70,2,76,1,83,1,90,1,97,1,104
		dw	1,111,0,119,0,126,0,134,0,142,0,150,0,158,0,166
		dw	0,175,0,183,0,191,0,200,0,208

jumpPart	ds	tableHalf,#00
jumpEnd		nop
BoingEnd	nop
