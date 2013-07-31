		org	#c000-4
t4Start	
		db	#7f,"CLA"			; Command Line Application

		;ex	de,hl
		push 	hl		
		ld	hl,t4Msg_00
		call	printString
		pop	hl

		ld	a,h
		or	l
		jp	z,errorPar

		push 	hl
		ld	hl,t4Msg_01
		call	printString
		pop	hl
		push	hl
		call	printString
		ld	hl,t4Msg_01a
		call	printString
		pop	hl

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

		ld	hl,t4Buffer
		call	load512bytes
		
		ld	hl,t4Buffer
		call	printString
		ret

;-------
t4Msg_00	db	16,16,"00.Start",#0d,#00
t4Msg_01	db	16,16,"01.Try to open file \"",#00
t4Msg_01a	db	"\"",#0d,#00
t4Buffer	ds	512,#20
		db	#0d,#00
t4End		nop