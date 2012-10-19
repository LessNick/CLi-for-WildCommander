;---------------------------------------
; exec - execute application
;---------------------------------------
executeApp	ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		ex	af,af'
		cp	#00
		call	z,exeApp
		
		call	restorePath
		ret

exeApp		ld	a,flagFile			; file
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
;---------------------------------------		
runApp		call	cliInit
		call	prepareSize

		;call	scopeBinary
		
		call	loadSApp
		cp	#00
		jp	z,pluginExit
		jp	wrongExit
;---------------------------------------
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
		ld	a,#ff				; wrong application
		ret
