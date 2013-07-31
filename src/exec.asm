;---------------------------------------
; exec - execute application
;---------------------------------------
executeApp	ld	(appParams+1),hl	
		ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		call	storeHomePath
		
		ex	af,af'
		cp	#00
		call	z,exeApp

		;call	restorePath			; restore start path at exit (ok or error)
		ret

exeApp		ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound

		ld	(fileLength),hl
		ld	(fileLength+2),de

		call	setFileBegin
		call	prepareSize
		call	loadApp
		ret
;---------------------------------------		
runApp		call	cliInit
		call	prepareSize
		
		call	loadApp
		cp	#00
		jp	z,pluginExit
		jp	wrongExit
;---------------------------------------
loadApp		ld	a,appBank
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

appParams	ld	hl,#0000
		push	hl
		call	restorePath
		pop	hl
		jp	appAddr

wrongApp	ld	hl,wrongAppMsg
		call	printStr
		ld	a,#ff				; wrong application
		ret
