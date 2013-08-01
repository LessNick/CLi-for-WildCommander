;---------------------------------------
; cd - change work directory
;---------------------------------------
changeDirSilent	ld	a,1
		ld	(cdNotFound+1),a
		jr	changeDir_00

changeDir	xor	a
		ld	(cdNotFound+1),a

changeDir_00	ex	de,hl				; hl params
		ld	a,(hl)
		cp	"/"
		call	z,resetToRoot

		push	hl
cdLoop		ld	a,(hl)
		cp	#00
		jr	z,cdLastCheck
		cp	"/"
		jr	z,changeNow
		inc	hl
		jr	cdLoop

changeNow	ex	de,hl
		xor	a
		ld	(de),a				; end current pos
		pop	hl
		
		inc	de
		push	de				; store next pos

		ld	a,flagDir			; directory
		call	prepareEntry

		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jp	z,cdNotFound-1

		call	setDirBegin

		call	setPathString

		pop	hl
		jr	cdLoop-1

cdLastCheck	pop	hl
		ld	a,(hl)
		cp	#00
		jp	z,cdExitOk

		ld	a,flagDir			; directory
		call	prepareEntry

		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jr	z,cdNotFound

		call	setDirBegin

		call	setPathString

		jr	cdExitOk

setPathString	;ld	hl,entrySearch+1
		ld	hl,entryForSearch+1
		ld	a,(hl)
		cp	"."
		jr	nz,incPath
		inc	hl
		ld	a,(hl)
		cp	"."
		jr	z,decPath
		cp	#00				; single dir .
		ret	z
		jr	incPath

decPath		ld	a,(lsPathCount+1)
		dec	a
		ld	(lsPathCount+1),a

		ld	hl,pathString
		ld	bc,(pathStrPos)
		add	hl,bc
		ld	e,#00
		ld	(hl),e				; pos
		dec	hl
		dec	bc

cdDelLoop	ld	(hl),e				; /
		dec	hl
		dec	bc
		ld	a,(hl)
		cp	"/"
		jr	nz,cdDelLoop
		inc	bc
		ld	(pathStrPos),bc
		ret

incPath		ld	a,(lsPathCount+1)
		inc	a
		ld	(lsPathCount+1),a

		ld	hl,pathString
		ld	bc,(pathStrPos)
		add	hl,bc
		ex	de,hl

		;ld	hl,entrySearch+1
		ld	hl,entryForSearch+1
cdLoopPath	ld	a,(hl)
		cp	#00
		jr	z,cdEndPath
		ld	(de),a
		inc	hl
		inc	de
		inc	bc
		jr	cdLoopPath

cdEndPath	ld	a,"/"
		ld	(de),a
		inc	bc
		ld	(pathStrPos),bc
		ret

		pop	hl
cdNotFound	ld	a,#00
		cp	#01
		jr	z,cdNotFound_00
		ld	hl,dirNotFoundMsg
		call	printStr

cdNotFound_00	ld	hl,pathString
		ld	bc,(pathStrPos)
		add	hl,bc
		ld	a,#0d
		ld	(hl),a
		
		ld	a,#ff				; alt error
		ex	af,af'
		xor	a
		ret

cdExitOk	ld	hl,pathString
		ld	bc,(pathStrPos)
		add	hl,bc
		ld	a,#0d
		ld	(hl),a

		xor	a				; alt no error
		ex	af,af'
		xor	a				; no error
		ret

resetToRoot	inc	hl
		ld	a,(lsPathCount+1)
		cp	#00
		ret	z				; alredy root
		push	hl
		call	pathToRoot
		xor	a
		ld	(lsPathCount+1),a
		call	initPath
		pop	hl
		ret