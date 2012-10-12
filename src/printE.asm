;---------------------------------------
; Editline print (output) module
;---------------------------------------
editInit	ld		de,#0000					; начальная инициализация
			ld		(printEX),de

editClear	ld		hl,edit256					; очистка редактируемой строки 256 (ASCII)
			ld		de,edit256+1
			ld		bc,127
			ld		a," "
			ld		(hl),a
			ldir

			ld		hl,edit256+128				; очистка буфера256 (Colors)
			ld		de,edit256+129
			ld		bc,127
			ld		a,defaultCol
			ld		(hl),a
			ldir

			ret
;---------------------------------------
printEStr	xor		a							; Печать в строке ввода
			ld		(eStrLen),a

printEStr_0	ld		a,(hl)
			cp		#00
			jr		z,printEExit
			push	hl
			call	printEChar
			ld		a,(printEX)
			inc		a
			cp		80							; Конец буфера edit256
			jr		nz,printEStr_1
			call	printEUp
			xor		a

printEStr_1	ld		(printEX),a

			ld		a,(eStrLen)
			inc		a
			ld		(eStrLen),a

			pop		hl
			inc		hl
			jp		printEStr_0
			
printEUp	push	hl
			ld		hl,edit256
			ld		a,#00
			call	BUF_UPD						; забирается буфер
			call	editInit

			pop		hl
			ret

printEExit	ld		a,(eStrLen)
			ret

printEChar	ld		hl,edit256					; печать символа в редактируемой строке
			ld		de,(printEX)

			add		hl,de
			ld		(hl),a
			
			ld		a,(curEColor)				; печать аттрибутов
			ld		de,128
			add		hl,de
			ld		(hl),a
			ret

;---------------------------------------
showCursor
curTimeOut	ld		a,#00
			cp		#00
			jr		z,sc_01
			dec		a
			ld		(curTimeOut+1),a
			ret

sc_01		ld		hl,curAnimPos
			ld		a,(hl)
			add		a,a
			ld		d,#00
			ld		e,a
			inc		(hl)
			ld		hl,curAnim
			add		hl,de						; frame
			ld		a,(hl)
			cp		#00
			jr		nz,sc_02
			ld		(curAnimPos),a
			ld		hl,curAnim
			ld		a,(hl)
sc_02		ld		(curTimeOut+1),a
			inc		hl
			ld		a,(hl)
			and		%00001111
			ld		c,a
			ld		a,(curEColor)
			and		%11110000
			or		c
			ld		(curEColor),a
			ld		a,cursorType
			call	printEChar
			ld		a,defaultCol
			ld		(curEColor),a
			ret

;---------------------------------------
; in A - ASCII code
printKey	ld		hl,iBuffer
			ld		b,#00
			push	af
			ld		a,(iBufferPos)
			;cp		iBufferSize-1
			cp		80-3						;TODO: iBufferSize
			jr		z,buffOverload				; Конец строки! Бип и выход!
			ld		c,a
			add		hl,bc
			inc		a
			ld		(iBufferPos),a
			pop		af
			ld		(hl),a
			call	printEChar
			
			ld		a,(printEX)
			inc		a
			cp		80							; Конец буфера edit256
			jr		nz,printKey_00
			call	printEUp
			xor		a

printKey_00	ld		(printEX),a

			ld		a,(iBufferPos)
			ld		b,0
			ld		c,a
			ld		hl,iBuffer
			add		hl,bc
			ld		a,(hl)
			ld		(storeKey),a
			ret

buffOverload
			pop		af

			halt
			ld		a,#02
			call	setBorder
			halt
			call	restBorder
			ret

;---------------------------------------
printEX		dw		#0000						; позиция X для печати в edit256
eStrLen		db		#00
