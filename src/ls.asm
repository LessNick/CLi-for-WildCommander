;---------------------------------------
; ls/dir - read directory
;---------------------------------------
listDir		ex	de,hl
		ld	a,(hl)
		cp	#00
		jr	z,lsPathCount

		push	hl
		call	storePath
		pop	de
		call	changeDir
		ex	af,af'
		cp	#00
		call	z,lsPathCount

		call	restorePath
		ret


lsPathCount	ld	a,#00					; path counter
		cp	#00
		jr	nz,lsNotRoot

		call	pathToRoot
		jr	lsBegin

lsNotRoot	ld	hl,rootSearch
		call	searchEntry
		jp	z,lsCantReadDir

lsBegin		xor	a
		ld	(lsCount+1),a
		ld	(itemsCount+1),a

		call	setFileBegin

lsReadAgain	call	clearBuffer

		ld	hl,bufferAddr
		ld	b,#01					; 1 block 512b
		call	load512bytes

		ld	hl,bufferAddr

lsLoop		ld	a,(hl)
		cp	#00
		jp	z,lsEnd					; если #00 конец записей

		push	hl
		pop	ix
		bit	3,(ix+11)
		jr	nz,lsSkip+1				; если 1, то запись это ID тома
		ld	a,(hl)
		cp	#e5
		jr	z,lsSkip+1

		push	hl
		call	lsCopyName

		bit	4,(ix+11)
		jr	z,lsNext_00				; если 1, то каталог
		ld	a,colorDir
		jr	lsNext

lsNext_00	bit	0,(ix+11)
		jr	z,lsNext_01				; если 1, то файл только для чтения
		ld	a,colorRO
		jr	lsNext

lsNext_01	bit	1,(ix+11)
		jr	z,lsNext_02				; если 1, то файл скрытый
		ld	a,colorHidden
		jr	lsNext

lsNext_02	bit	2,(ix+11)
		jr	z,lsNext_03				; если 1, то файл системный
		ld	a,colorSystem
		jr	lsNext

lsNext_03	bit	5,(ix+11)
		jr	z,lsNext_04				; если 1, то файл системный
		ld	a,colorArch
		jr	lsNext

lsNext_04	ld	a,colorFile				; в противном случает - обычный файл

lsNext		ld	(de),a

lsCount		ld	a,#00
		inc	a
		ld	(lsCount+1),a
		cp	#06
		jr	nz,lsSkip
		xor	a
		ld	(lsCount+1),a

		ld	hl,fileOneLine
		call	printStr

lsSkip		pop	hl

itemsCount	ld	a,#00
		inc	a
		ld	(itemsCount+1),a
		cp	16					; 16 записей на сектор
		jr	z,lsLoadNext

		ld	bc,32					; 32 byte = 1 item
		add	hl,bc
		jp	lsLoop

lsEnd		ld	a,(lsCount+1)
		cp	#00
		jr	z,lsEnd_01

lsEnd_00	ld	hl,nameEmpty
		call	lsCopyName
		ld	a,(lsCount+1)
		inc	a
		ld	(lsCount+1),a
		cp	#06
		jr	nz,lsEnd_00			

		ld	hl,fileOneLine
		call	printStr
			
lsEnd_01	ld	hl,restoreMsg
		call	printStr
		ret

lsLoadNext	xor	a
		ld	(itemsCount+1),a
		jp 	lsReadAgain

clearBuffer	ld	hl,bufferAddr
		ld	de,bufferAddr+1
		ld	bc,#1fff
		xor	a
		ld	(hl),a
		ldir
		ret

lsCopyName	push	hl
		ld	hl,fileOneLine
		ld	b,0
		ld	a,(lsCount+1)
		ld	c,a
		add	a,a
		add	a,a
		add	a,a
		add	a,a
		sbc	c
		ld	c,a
		add	hl,bc
		ex	de,hl
		pop	hl
		inc	de
		push	de
		inc	de
			
		ld	bc,#0000
lsCopyLoop	ld	a,(hl)
		cp	" "
		jr	z,lsCopySkip
		ld	(de),a
		inc	de
		inc	c					; счётчик символов отпечатано (позиция)
lsCopySkip	inc	b					; счётчик символов всего (позиция)
		inc	hl
		ld	a,b
		cp	11
		jr	z,lsCopyRet
		cp	8					; 8.3
		jr	nz,lsCopyLoop
		ld	a,(hl)
		cp	" "
		jr	z,lsCopyRet
		ld	a,"."
		inc	c
		ld	(de),a
		inc	de
		jr	lsCopyLoop

lsCopyRet	ld	a,c
		cp	12
		jr	nc,lsCopyRet_0
		ld	a," "
		ld	(de),a
		inc	c
		inc	de
		jr	lsCopyRet

lsCopyRet_0	pop	de
		ret

lsCantReadDir	ld	hl,cantReadDirMsg
		call	printStr
		ret
