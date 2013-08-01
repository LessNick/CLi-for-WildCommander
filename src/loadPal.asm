;---------------------------------------
; loadpal - loading palette
;---------------------------------------
loadGfxPal	call	loadPal
		cp	#00
		jr	nz,exitPal
		
		push	hl
		ld	a,gPalBank			; load Pal File
		call	setVideoPage
		pop	hl

		ld	de,gPalAddr			; сохраняем загруженную палитру
		ld	bc,512
		ldir
		xor	a				; нет ошибок загрузки
		jr	exitPal
;---------------------------------------
loadTxtPal	call	loadPal
		cp	#00
		jr	nz,exitPal
		
		push	hl
		ld	a,palBank			; load Pal File
		call	setVideoPage
		pop	hl

		ld	de,palAddr			; сохраняем загруженную палитру
		push	de
		ld	bc,512
		ldir
		pop	hl
		call	setFilePal

		xor	a

exitPal		ex	af,af'
		xor	a				; убирает сообщение "unknown command"
		ret
;---------------------------------------
loadPal		ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		ex	af,af'
		cp	#00
		call	z,findPalFile
		;cp	#ff
		;ret	z
		push	hl,af
		call	restorePath
		pop	af,hl
		ret

findPalFile	ld	a,flagFile			; file
		call	prepareEntry
			
		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jp	z,fileNotFound
		
		;ld	(fileLength),hl
		;ld	(fileLength+2),de
		call	storeFileLen
		
		ld	a,d				; #0000
		or	e
		jp	nz,wrongFileSize
		ld	a,h
		cp	#02				; #0204 = 512b + header
		jp	nz,wrongFileSize
		ld	a,l
		cp	#04
		jp	nz,wrongFileSize

		call	setFileBegin
		call	prepareSize

		ld	hl,#0000
		push	hl
		call	load512bytes

		pop	hl

		ld	a,(hl)
		cp	127
		jr	nz,wrongPal
		inc	hl

		ld	a,(hl)
		cp	"P"
		jr	nz,wrongPal
		inc	hl

		ld	a,(hl)
		cp	"A"
		jr	nz,wrongPal
		inc	hl

		ld	a,(hl)
		cp	"L"
		jr	nz,wrongPal
		inc	hl

		xor	a
		ret						; pal file is ok

wrongPal	ld	hl,wrongPalMsg
		call	printStr
		ld	a,#ff					; wrong pal file
		ret

setFilePal	ld	bc,FMAddr
		ld 	a,%00010000				; Разрешить приём данных для палитры (?) Bit 4 - FM_EN установлен
		out	(c),a

		ld 	de,#0000				; Память с палитрой замапливается на адрес #0000
		ld	bc,512
		ldir

		ld 	bc,FMAddr			
		xor	a					; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a
		ret

