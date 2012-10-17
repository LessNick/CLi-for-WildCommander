;---------------------------------------
; cd - change work directory
;---------------------------------------
changeDir	ex	de,hl				; hl params

		ld	a,(hl)
		cp	"/"
		jp	z,cdSplitPath
		cp	"."
		jp	z,cdSplitPath+1

		ld	a,flagDir			; directory
		call	prepareEntry

cdStart		ld	hl,entrySearch
		call	searchEntry
		jr	z,cdNotFound

		call	setDirBegin

		ld	hl,entrySearch+1
		ld	a,(hl)
		cp	"."
		jr	nz,cdIncPath
		inc	hl
		ld	a,(hl)
		cp	"."
		jr	nz,cdSkipPath

		ld	a,(lsPathCount+1)
		cp	#00
		jr	z,cdRoot
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
		ex	de,hl
		jr	cdExitPath

cdRoot		push	hl
		call	initPath
		pop	hl
		xor	a				; alt no error
		ex	af,af'
		xor	a				; no error
		ret

cdIncPath	ld	a,(lsPathCount+1)
		inc	a
		ld	(lsPathCount+1),a

cdSkipPath	ld	hl,pathString
		ld	bc,(pathStrPos)
		add	hl,bc
		ex	de,hl
			
		ld	hl,entrySearch+1
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

cdExitPath	inc	de
		ld	a,#0d
		ld	(de),a
		xor	a				; alt no error
		ex	af,af'
		xor	a				; no error
		ret

cdNotFound	ld	hl,dirNotFoundMsg
		call	printStr
		ld	a,#ff				; alt error
		ex	af,af'
		xor	a
		ret

;---------------------------------------
cdSplitPath	inc	hl
		ld	a,(hl)
		cp	#00
		jr	nz,splitCont

cdSplitReset	call	pathToRoot
		xor	a
		ld	(lsPathCount+1),a
		call	initPath

cdExit		xor	a				; alt no error
		ex	af,af'
		xor	a				; no error
		ret

splitCont	push	hl
		call	cdSplitReset
		pop	hl

splitCont2	ld	a,flagDir			; directory
		call	prepareEntry
		dec	hl
		push	hl
		call	cdStart
		pop	hl
		cp	#00
		ret	nz

		ld	a,(hl)
		cp	#00
		;ret	z				; end path, no error
		jr	z,cdExit

		ld	a,(hl)
		cp	"/"
ttt		jr	nz,splitWrong

		inc	hl
		ld	a,(hl)
		cp	#00
		;ret	z				; end path, no error
		jr	z,cdExit

		jr	splitCont2

splitWrong	ld	hl,wrongPathMsg
		call	printStr
		ret
