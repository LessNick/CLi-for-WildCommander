;---------------------------------------
; Main print (output) module
;---------------------------------------
printInit	ld	de,#0000				; начальная инициализация
		ld	(printX),de
		ld	a,defaultCol
		ld	(curColor),a

printClear	ld	hl,bufer256				; очистка буфера256 (ASCII)
		ld	de,bufer256+1
		ld	bc,127
		ld	a," "
		ld	(hl),a
		ldir

		ld	hl,bufer256+128				; очистка буфера256 (Colors)
		ld	de,bufer256+129
		ld	bc,127
		;ld	a,defaultCol
		ld	a,(curColor)
		ld	(hl),a
		ldir

		ld	hl,bufer256
		ld	a,#01
		ld	bc,#0000
		call	BUF_UPD
		ret

;---------------------------------------
printSpaceStr	ld	a," "
		ld	(printExitCode+1),a
		call	printStr
		xor	a
		ld	(printExitCode+1),a
		ret

printStr	xor	a					; Печать строки
		ld	(strLen),a

printSLoop	ld	a,(hl)
printExitCode	cp	#00					; Управляющий код: 0 - выход
		jp	z,printSExit

		cp	#09					; Управляющий код: 09 - tab
		jp	z,codeTab
		
		cp	#0C					; Управляющий код: 12 - delete
		jp	z,codeDelete
		cp	#0D					; Управляющий код: 13 - new line (enter) windows
		jp	z,codeEnter
		cp	#0A					; Управляющий код: 10 - new line (enter) unix
		jp	z,codeEnter
		cp	#10					; Управляющий код: 16 - ink
		jp	z,codeInk
		cp	#11					; Управляющий код: 17 - paper
		jp	z,codePaper
		cp	#14					; Управляющий код: 20 - inverse
		jp	z,codeInverse
		cp	"\\"					; Управляющий код: \xNN - где NN шестнадцатеричное значение
		jp	z,codeESC

printS		push	hl
		call	printChar
		ld	a,(printX)
		inc	a
		cp	80					; Конец буфера256
		jr	z,printS_00

		ld	(printX),a

		ld	a,(strLen)
		inc	a
		ld	(strLen),a

		pop	hl
		inc	hl
		jp	printSLoop

printSExit	ld	hl,bufer256
		ld	a,#01
		ld	bc,#0000
		call	BUF_UPD					; забирается буфер
		call	checkUpdate
		ld	a,(strLen)
		ret

printS_00	pop	hl
		push	hl
		inc	hl
		ld	a,(hl)
		cp	#00
		jr	nz,printS_00a
		pop	hl
		jr	printSExit

printS_00a	xor	a
		ld	(printX),a
		jr	nextLine_00

checkUpdate	call	checkSync				; проверяем необходимость обновления экрана
		ret	z					; нового инта не было - выход
		call	printWW
		ret
;---------------------------------------
codeTab		ld	a,(printX)
		srl	a					; /2
		srl	a					; /4
		srl	a					; /8
		cp	#09
		jr	z,codeEnter
		inc	a
		push	hl
		ld	hl,tabTable
		ld	b,0
		ld	c,a
		add	hl,bc
		ld	a,(hl)
		ld	(printX),a
		pop	hl
		inc	hl
		jp	printSLoop
;---------------------------------------
codeDelete	ld	a,(printX)
		cp	#00
		jr	z,codeDelete_00
		dec	a
		ld	(printX),a
codeDelete_00	inc	hl
		jp	printSLoop

codeEnter	inc	hl
		ld	a,(hl)
		cp	#0A					; windows \n\r ?
		jr	nz,nextLine
		inc	hl

nextLine	push	hl

nextLine_00	ld	hl,bufer256
		ld	a,#00
		call	BUF_UPD					; забирается буфер

		call	printClear				; очищаем буфер256
		call	checkUpdate

		xor	a
		ld	(printX),a
		pop	hl
		jp	printSLoop

;---------------------------------------
codeInk		inc	hl
		ld	a,(hl)
		inc	hl

codeInk_0	cp	16					; 16 ? взять цвет по умолчанию
		jr	nz,codeInk_1
		ld	a,defaultCol

codeInk_1	and	%00001111
		ld	c,a
		ld	a,(curColor)
		and	%11110000
		or	c
		ld	(curColor),a
		jp	printSLoop

codePaper	inc	hl
		ld	a,(hl)
		inc	hl

codePaper_0	cp	16					; 16 ? взять цвет по умолчанию
		jr	nz,codePaper_1
		ld	a,defaultCol
		and	%11110000
		jr	codePaper_2

codePaper_1	and	%00001111
		sla	a
		sla	a
		sla	a
		sla	a
codePaper_2	ld	c,a
		ld	a,(curColor)
		and	%00001111
		or	c
		ld	(curColor),a
		jp	printSLoop

codeInverse	inc	hl
		ld	a,(curColor)
		and	%00001111
		sla	a
		sla	a
		sla	a
		sla	a
		ld	b,a
		ld	a,(curColor)
		and	%11110000
		srl	a
		srl	a
		srl	a
		srl	a
		or	b
		ld	(curColor),a
		jp	printSLoop

codeESC		inc	hl
		ld	a,(hl)
codeESC_0	cp	"\\"					; управляющий ESC: BackSlash \
		jp	z,printS
		cp	"t"
		jp	z,codeTab				; управляющий ESC: Tab
		cp	"n"
		jp	z,codeEnter				; управляющий ESC: Enter
		cp	"r"
		jp	z,codeEnter				; управляющий ESC: Enter
		cp	"x"
		jr	z,codeHex				; управляющий ESC: Hex value

		jp	printSLoop+1				; код не опознан = просто напечатать следующий символ

codeHex		inc	hl
		push	hl
		call	hex2int
		pop	hl
		cp	#10					; Управляющий код: 16 - ink
		jr	z,codeHexI
		cp	#11					; Управляющий код: 17 - paper
		jr	z,codeHexP

		inc	hl
		cp	#14					; Управляющий код: 20 - inverse
		jr	z,codeInverse
		jp	printS					; В противном случае просто напечатать код символа

codeHexI	inc	hl
		inc	hl
		ld	a,(hl)
		cp	"\\"
		jp	nz,printS				; Ошибочная структура, пропустить символ
		inc	hl
		ld	a,(hl)
		cp	"x"
		jr	nz,codeESC_0				; Ошибочная структура, пропустить символ
		inc	hl
		push	hl
		call	hex2int
		pop	hl
		inc	hl
		inc	hl
		jp	codeInk_0

codeHexP	inc	hl
		inc	hl
		ld	a,(hl)
		cp	"\\"
		jp	nz,printS				; Ошибочная структура, пропустить символ
		inc	hl
		ld	a,(hl)
		cp	"x"
		jr	nz,codeESC_0				; Ошибочная структура, пропустить символ
		inc	hl
		push	hl
		call	hex2int
		pop	hl
		inc	hl
		inc	hl
		jp	codePaper_0

;---------------------------------------
printChar	ld	hl,bufer256				; печать символа
		ld	de,(printX)
		add	hl,de
		ld	(hl),a
		
		ld	a,(curColor)				; печать аттрибутов
		ld	de,128
		add	hl,de
		ld	(hl),a

		include "printE.asm"
		include "budder.asm"

;---------------------------------------
printX		dw	#0000					; позиция X для печати в буфере256
strLen		db	#00
