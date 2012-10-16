;---------------------------------------
; exec - execute application
;---------------------------------------
executeApp	ex	de,hl				; hl params

		ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound

		ld	(scriptLength),hl
		ld	(scriptLength+2),de

		call	setFileBegin
		call	prepareSize
		call	loadSApp
		ret

loadSApp	ld	a,appBank
		call	setVideoPage

		ld	hl,appAddr-4
		push	hl
		call	load512bytes

		pop	hl

		ld	a,(hl)
		cp	127
		jr	nz,wrongApp
		inc	hl

		ld	a,(hl)
		cp	"C"
		jr	nz,wrongApp
		inc	hl

		ld	a,(hl)
		cp	"L"
		jr	nz,wrongApp
		inc	hl

		ld	a,(hl)
		cp	"A"
		jr	nz,wrongApp
		inc	hl

		jp	appAddr

wrongApp	ld	hl,wrongAppMsg
		call	printStr
		ret
