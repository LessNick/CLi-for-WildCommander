;---------------------------------------
; type - show txt file application
;--------------------------------------		
		org	#c000-4
typeStart	
		db	#7f,"CLA"			; Command Line Application

		ld	a,h
		or	l
		jp	z,errorPar

		call	checkIsPath

		ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound
		
		ld	(fileLength),hl
		ld	(fileLength+2),de

		call	setFileBegin
		call	prepareSize

		dec	b
typeLoop	push	bc
		ld	b,1
		ld	hl,typeBuffer
		call	load512bytes
		
		ld	hl,typeBuffer
		call	printString

		ld	hl,typeBuffer
		ld	de,typeBuffer+1
		ld	bc,511
		xor	a
		ld	(hl),a
		ldir

		pop	bc
		djnz	typeLoop
		
		ld	hl,typeBufferEnd
		call	printString
		ret

;-------
typeBuffer	ds	512,#00
		db	#00,#00
typeBufferEnd	db	#0d,#00
typeEnd		nop