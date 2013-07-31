;---------------------------------------
; Editline print (output) module
;---------------------------------------
_editInit	ld	de,#0000				; начальная инициализация
		ld	(printEX),de

editClear	ld	hl,edit256				; очистка редактируемой строки 256 (ASCII)
		ld	de,edit256+1
		ld	bc,127
		ld	a," "
		ld	(hl),a
		ldir

		ld	hl,edit256+128				; очистка буфера256 (Colors)
		ld	de,edit256+129
		ld	bc,127
		;ld	a,defaultCol
		ld	a,(curColor)
		ld	(hl),a
		ldir

		ret

_printInLine	push	hl
		ld	hl,#0000
		ld	(printEX),hl
		pop	hl
		call	printEStr
		
		ld 	hl,edit256
		ld 	a,#01
		ld 	bc,#0000				; reserved
		call	BUF_UPD
		ret
;---------------------------------------
printEStr	xor	a					; Печать в строке ввода
		ld	(eStrLen),a

printEStr_0	ld	a,(hl)
		cp	#00
		jr	z,printEExit

		cp	#09					; Управляющий код: 09 - tab
		jp	z,codeETab
		cp	#10					; Управляющий код: 16 - ink
		jp	z,codeEInk
		cp	#11					; Управляющий код: 17 - paper
		jp	z,codeEPaper
		cp	#14					; Управляющий код: 20 - inverse
		jp	z,codeEInverse

		push	hl
		call	printEChar
		ld	a,(printEX)
		inc	a
		cp	80					; Конец буфера edit256
		jr	nz,printEStr_1
		call	printEUp
		xor	a

printEStr_1	ld	(printEX),a

		ld	a,(eStrLen)
		inc	a
		ld	(eStrLen),a

		pop	hl
		inc	hl
		jp	printEStr_0
			
printEUp	push	hl
		ld	hl,edit256
		ld	a,#00
		call	BUF_UPD					; забирается буфер
		call	editInit

		pop	hl
		ret

printEExit	ld	a,(eStrLen)
		ret

printEChar	ld	hl,edit256				; печать символа в редактируемой строке
		ld	de,(printEX)

		add	hl,de
		ld	(hl),a
			
		;ld	a,(curEColor)				; печать аттрибутов
		ld	a,(curColor)
		ld	de,128
		add	hl,de
		ld	(hl),a
		ret

;---------------------------------------
showCursor
curTimeOut	ld	a,#00
		cp	#00
		jr	z,sc_01
		dec	a
		ld	(curTimeOut+1),a
		ret

sc_01		ld	hl,curAnimPos
		ld	a,(hl)
		add	a,a
		ld	d,#00
		ld	e,a
		inc	(hl)
		ld	hl,curAnim
		add	hl,de					; frame
		ld	a,(hl)
		cp	#00
		jr	nz,sc_02

		ld	(curAnimPos),a
		ld	hl,curAnim
		ld	a,(hl)

sc_02		ld	(curTimeOut+1),a
		inc	hl
		ld	a,(hl)
		and	%00001111
		ld	c,a
		;ld	a,(curEColor)
		ld	a,(curColor)
		and	%11110000
		or	c
		;ld	(curEColor),a
		ld	(curColor),a
		ld	a,cursorType
		call	printEChar
		ld	a,defaultCol
		;ld	(curEColor),a
		ld	(curColor),a
		ret

;---------------------------------------
; in A - ASCII code
printKey	ld	hl,iBuffer
		ld	b,#00
		push	af
		ld	a,(iBufferPos)
		;cp	iBufferSize-1
		cp	80-3					;TODO: iBufferSize
		jr	z,buffOverload				; Конец строки! Бип и выход!

		ld	c,a
		add	hl,bc
		inc	a
		ld	(iBufferPos),a
		pop	af
		ld	(hl),a
		call	printEChar
		
		ld	a,(printEX)
		inc	a
		cp	80					; Конец буфера edit256
		jr	nz,printKey_00
		call	printEUp
		xor	a

printKey_00	ld	(printEX),a

		ld	a,(iBufferPos)
		ld	b,0
		ld	c,a
		ld	hl,iBuffer
		add	hl,bc
		ld	a,(hl)
		ld	(storeKey),a
		ret

buffOverload	pop	af

		halt
		ld	a,#02
		call	setBorder
		halt
		call	restBorder
		ret
;---------------------------------------
codeETab	ld	a,(printEX)
		srl	a					; /2
		srl	a					; /4
		srl	a					; /8
		cp	#09
		jp	z,printEStr_0
		inc	a
		push	hl
		ld	hl,tabTable
		ld	b,0
		ld	c,a
		add	hl,bc
		ld	a,(hl)
		ld	(printEX),a
		pop	hl
		inc	hl
		jp	printEStr_0
;---------------------------------------
codeEInk	inc	hl
		ld	a,(hl)
		inc	hl

codeEInk_0	cp	16					; 16 ? взять цвет по умолчанию
		jr	nz,codeEInk_1
		ld	a,defaultCol

codeEInk_1	and	%00001111
		ld	c,a
		ld	a,(curColor)
		and	%11110000
		or	c
		ld	(curColor),a
		jp	printEStr_0

codeEPaper	inc	hl
		ld	a,(hl)
		inc	hl

codeEPaper_0	cp	16					; 16 ? взять цвет по умолчанию
		jr	nz,codeEPaper_1
		ld	a,defaultCol
		and	%11110000
		jr	codeEPaper_2

codeEPaper_1	and	%00001111
		sla	a
		sla	a
		sla	a
		sla	a
codeEPaper_2	ld	c,a
		ld	a,(curColor)
		and	%00001111
		or	c
		ld	(curColor),a
		jp	printEStr_0

codeEInverse	inc	hl
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
		jp	printEStr_0
;---------------------------------------
printEX		dw	#0000					; позиция X для печати в edit256
eStrLen		db	#00
