;---------------------------------------
changeDir	ex		de,hl				; hl params

			ld		a,FLAGDIR			; directory
			call	prepareEntry

			ld		hl,entrySearch
			call	searchEntry
			jr		z,cdNotFound

			call	setDirBegin

			ld		hl,entrySearch+1
			ld		a,(hl)
			cp		"."
			jr		nz,cdIncPath
			inc		hl
			ld		a,(hl)
			cp		"."
			jr		nz,cdSkipPath

			ld		a,(lsPathCount)
			cp		#00
			jr		z,cdSkipPath
			dec		a
			ld		(lsPathCount),a
			jr		cdSkipPath
cdIncPath	ld		a,(lsPathCount)
			inc		a
			ld		(lsPathCount),a

cdSkipPath	xor		a					; no error
			ret

cdNotFound	ld		hl,dirNotFoundMsg
			call	printStr
			ret
