;---------------------------------------
; loadpal - loading palette
;---------------------------------------
loadPal		ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		ex	af,af'
		cp	#00
		call	z,findPalFile
		
		call	restorePath
		ret

findPalFile	ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound

		ld	(scriptLength),hl
		ld	(scriptLength+2),de

		call	setFileBegin
		call	prepareSize
		call	loadPalFile
		ret

;---------------------------------------
loadPalFile	ld	a,palBank
		call	setVideoPage

		ld	hl,palAddr-4
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

		ld	bc,FMAddr
		ld 	a,%00010000				; Разрешить приём данных для палитры (?) Bit 4 - FM_EN установлен
		out	(c),a

		ld	hl,#c000
		ld 	de,#0000				; Память с палитрой замапливается на адрес #0000
		ld	bc,512
		ldir

		ld 	bc,FMAddr			
		xor	a					; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a
		ret

wrongPal	ld	hl,wrongPalMsg
		call	printStr
		ld	a,#ff				; wrong pal file
		ret
