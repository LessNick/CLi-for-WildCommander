;-------------------------------------------------
; micetest - application for test kempstone mouse
;-------------------------------------------------

		org	#c000-4

miceTestStart
		db	#7f,"CLA"		; Command Line Application

		ld	hl,miceInfoMsg
		call	printString

		call	clearGfxScreen

		ld	hl,miceRunMsg
		call	printString

		halt
		call	printWW			; печать

		call	prepareCursor

		ld	hl,319			; txt-mode
		ld	de,239
		call	mouseInit

		ld	hl,miceCallBack
		call	setAppCallBack

miceLoop	halt

		call	updateCursor
		call	mouseUpdate
		call	printWW

		call	getMouseX
		ld	a,l
		ld	(cursorSFileX),a
		ld	a,h
		and	%00000001
		or	%00100010
		ld	(cursorSFileX+1),a

		call	getMouseY
		ld	a,l
		ld	(cursorSFile),a
		ld	a,h
		and	%00000001
		or	%00100010
		ld	(cursorSFile+1),a

		ld	hl,(timeCount)
		inc	hl
		ld	(timeCount),hl
		ld	de,timeCountMsg
		call	int2str

		call	checkKeyEsc
		jp	nz,miceStop		
;---------------
		ld	b,"+"
		ld	c,"-"
		call	getMouseDeltaX
		bit	7,h
		ld	a,b
		ld	(rawXMsg-1),a
		jr	z,micePlusXSkip
		ld	a,c

		ld	(rawXMsg-1),a
		ld	h,#00
		ld	a,255
		sub	l
		and	%01111111
		ld	l,a

micePlusXSkip	ld	de,rawXMsg
		call	char2str
;---------------
		call	getMouseRawX
		ld	de,rawXMsg+4
		call	char2str
;---------------
		ld	b,"+"
		ld	c,"-"
		call	getMouseDeltaY
		bit	7,h
		ld	a,b
		ld	(rawYMsg-1),a
		jr	z,micePlusYSkip
		ld	a,c

		ld	(rawYMsg-1),a
		ld	h,#00
		ld	a,255
		sub	l
		and	%01111111
		ld	l,a

micePlusYSkip	ld	de,rawYMsg
		call	char2str
;---------------
		call	getMouseRawY
		ld	de,rawYMsg+4
		call	char2str
;---------------
		call	getMouseX
		ld	de,posXMsg
		call	int2str
;---------------		
		call	getMouseY
		ld	de,posYMsg
		call	int2str
;---------------
		call	getMouseWheel
		ld	de,posWheelMsg
		call	fourbit2str
;---------------
		ld	b,colorInfo
		ld	c,16
		call	getMouseButtons
		and	%00000001
		cp	%00000001
		ld	a,b
		jr	nz,miceLSet
		ld	a,c
miceLSet	ld	(leftButtonMsg),a

		call	getMouseButtons
		and	%00000010
		cp	%00000010
		ld	a,b
		jr	nz,miceRSet
		ld	a,c
miceRSet	ld	(rightButtonMsg),a

		call	getMouseButtons
		and	%00000100
		cp	%00000100
		ld	a,b
		jr	nz,miceMSet
		ld	a,c
miceMSet	ld	(middleButtonMsg),a

		ld 	hl,micePosMsg
		call	printInLine

		jp	miceLoop
;---------------
miceStop	call	editInit


		xor	a
		call	setScreen
		;call	clearGfxScreen
		call	disableSprites
		
		ld	hl,miceExitMsg
		call	printString

		;ld	hl,restoreMsg
		;call	printString
		call	printRestore

		xor	a			; no error, clean exit!
		ret

miceCallBack	cp	#01			; txt-mode
		jr	z,miceCallGfx
		ld	hl,319			; txt-mode
		ld	de,239
		call	mouseInit
		jp	updateCursor

miceCallGfx	ld	hl,359			; gfx-mode
		ld	de,287
		call	mouseInit
		jp	updateCursor

;-----------------------------------------------------------------------------------------------------------------------------------------------------------
prepareCursor	ld	bc,RAMPage0		; Подключаем страницу sprBank адреса #0000
		ld	a,sprBank
		out	(c),a

		ld	hl,#0000
		ld	de,#0001
		ld	bc,#3fff
		xor	a
		ld	(hl),a
		ldir

		ld	hl,miceCursor
		ld	de,#0000
		ld	b,11
prepareLoop	push	bc
		ld	bc,6
		ldir
		ex	de,hl
		ld	bc,250
		add	hl,bc
		ex	de,hl
		pop	bc
		djnz	prepareLoop

		ld	bc,SGPage		; Указываем страницу для спрайтов
		ld	a,sprBank
		out	(c),a

		ld	bc,RAMPage0		; Подключаем страницу sprBank адреса #0000
		ld	a,(_PAGE0)		; Восстанавливаем банку для WildCommander
		out	(c),a

updateCursor	ld	bc,FMAddr
		ld 	a,%00010000		; Разрешить приём данных (?) Bit 4 - FM_EN установлен
		out	(c),a

		ld	hl,cursorSFile
		ld 	de,#0000+512		; Память с палитрой замапливается на адрес #0000
		ld	bc,6
		ldir

		ld	bc,FMAddr
		xor	a			; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a

		ld	bc,TSConfig		; Включаем отображение спрайта
			  ;76543210
		ld	a,%10000000		; bit 7 - S_EN Sprite Layers Enable
		out	(c),a

		ret
;---------------------------------------
miceInfoMsg	db	16,2,"Kempstone mouse test v 0.02",#0d
		db	16,3,"2013 ",#7f," Breeze\\\\Fishbone Crew",#0d,#0d,#00

miceRunMsg	db	16,colorInfo
		db	"(\\\\/)",#0d
		db	" \\\\/\\\\",#0d
		db	" /__)",#0d
		db	"   (_  Move your mouse...",#0d,#0d
		db	16,16
		db	#00

miceExitMsg	db	16,colorInfo,"Exit.",#0d
		db	16,16
		db	#00

micePosMsg	db	16,colorOk,"Raw: X=",16,16,"+"
rawXMsg		db	"---[---]"

		db	16,14,", ",16,colorOk,"Y=",16,16,"+"
rawYMsg		db	"---[---]"

		db	16,14,", ",16,colorOk,"wheel=",16,16
posWheelMsg	db	"--"

		db	16,14," | "
		db	16
leftButtonMsg	db	colorInfo,"L"
		db	16
middleButtonMsg	db	colorInfo,"M"
		db	16
rightButtonMsg	db	colorInfo,"B"

		db	16,14," | ",16,colorOk,"Pos: X=",16,16
posXMsg		db	"-----"

		db	16,14,", ",16,colorOk,"Y=",16,16
posYMsg		db	"-----"
		
		db	16,14," | ",16,colorOk,"T=",16,16
timeCountMsg	db	"-----"
		db	#00

;---------------
timeCount	dw	#0000
;---------------
cursorSFile	db	#00			; Y0-7     | 8 bit младшие даные Y координаты (0-255px)
			;FLAR S Y8
		db	%00100010		; Y8       | 0й бит - старшие данные Y координаты (256px >)
						; YS       | 1,2,3 бит - высота в блоках по 8 px
						; RESERVED | 4й бит - зарезервирован
						; ACT      | 5й бит - спрайт активен (показывается)
						; LEAP     | 6й бит - указывает, что данный спрайт последний в текущем слое. (для перехода по слоям)
						; YF       | 7й бит - указывает, что данный спрайт нужно отобразить зеркально по вертикали
		
cursorSFileX	db	#00			; X0-7     | 8 bit младшие даные X координаты (0-255px)
			;F  R S X8
		db	%00000010		; X8       | 0й бит - старшие данные X координаты (256px >)
						; XS       | 1,2,3 бит - ширина в блоках по 8 px
						; RESERVED | 4й бит - зарезервирован
						; -        | 5,6й бит - не используются
						; XF       | 7й бит - указывает, что данный спрайт нужно отобразить зеркально по горизонтали
			;TNUM
		db	%00000000		; TNUM	   | Номер тайла для левого верхнего угла.
						;          | 0,1,2,3,4,5й бит - Х координата в битмап
			;SPALTNUM		;          | 6,7й бит +
		db	%00010000		; TNUM     | 0,1,2,3 бит - Y координата в битмап
						; SPAL     | 4,5,6,7й биты номер палитры (?)

miceCursor	db	#be,#00,#00,#00,#00,#00
		db	#1b,#ee,#00,#00,#00,#00
		db	#01,#bb,#ee,#00,#00,#00
		db	#01,#bb,#bb,#ee,#00,#00
		db	#00,#1b,#bb,#bb,#ee,#00
		db	#00,#1b,#bb,#bb,#bb,#00
		db	#00,#01,#bb,#be,#00,#00
		db	#00,#01,#bb,#1b,#e0,#00
		db	#00,#00,#1b,#01,#be,#00
		db	#00,#00,#1b,#00,#1b,#e0
		db	#00,#00,#00,#00,#01,#b0
		db	#00,#00,#00,#00,#00,#00
 		db	#00,#00,#00,#00,#00,#00
 		db	#00,#00,#00,#00,#00,#00
 		db	#00,#00,#00,#00,#00,#00
 		db	#00,#00,#00,#00,#00,#00

miceTestEnd	nop
