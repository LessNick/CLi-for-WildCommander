;---------------------------------------
; type - show txt file application
;--------------------------------------		
		org	#c000-4
typeStart	
		db	#7f,"CLA"			; Command Line Application

		ld	a,h
		or	l
		jp	z,typeInfo

		call	checkIsPath

		ld	a,flagFile			; file
		call	prepareEntry
			
		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jp	z,fileNotFound
		
		;ld	(fileLength),hl
		;ld	(fileLength+2),de
		call	storeFileLen

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

typeInfo	ld	hl,typeVersionMsg
		call	printString
		ret

;-------
typeVersionMsg	db	16,2,"Type (Displays the contents of a text file) v0.02",#0d
		db	16,3,"2013 ",127," Breeze\\\\FBn",#0d,#0d
		
		db	16,12,"Usage: type filename.txt",#0d,#0d
		db	16,16,#00

typeBuffer	ds	512,#00
		db	#00,#00
typeBufferEnd	db	#0d,#00
typeEnd		nop