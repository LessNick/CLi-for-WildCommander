shellExecute
			ex		de,hl				; hl params

			ld		a,flagFile			; file
			call	prepareEntry
			
			ld		hl,entrySearch
			call	searchEntry
			jr		z,fileNotFound

			ld		(scriptLength),hl
			ld		(scriptLength+2),de

			call	setFileBegin
			call	prepareSize
			call	loadScript
			ret

fileNotFound
			ld		hl,fileNotFoundMsg
			call	printStr
			ret

callFromExt
			ld		(scriptLength),hl
			ld		(scriptLength+2),de

			call	cliInit
			call	prepareSize

			call	loadScript
			jp		pluginExit


prepareSize	ld		bc,(scriptLength+2)
			ld		a,b
			or		c
			jr		z,ps_01
			ld		b,#20				; 32 * 512 = 16384 (#4000)
			jr		ps_02

ps_01		ld		bc,(scriptLength)
			xor		a
			srl		b
			ld		a,b
			cp		#00
			jr		nz,ps_02
			ld		b,#01				; 1 block 512b
ps_02		cp		#20
			jr		c,ps_03
			ld		b,#20

ps_03		ld		a,c
			cp		#00
			ret		z
			inc		b
			ret

;---------------------------------------
loadScript	ld		hl,bufferAddr
			push	hl
			call	load512bytes

shExt_Loop	call	clearIBuffer
			pop		hl
			ld		de,iBuffer

			ld		bc,#0000
shStr_Loop	ld		a,(hl)
			cp		#00					;end file ?
			ret		z
			cp		#0d					;end string?
			jr		z,shExt_00
			ld		(de),a
			inc		hl
			inc		de
			inc		bc
			jr		shStr_Loop

shExt_00	inc		hl
			ld		a,(hl)
			cp		#0a
			jr		nz,shExt_01
			inc		hl

shExt_01	push	hl
			ld		a,b
			or		c
			jr		z,shExt_Loop		; пропустить пустую строку

			xor		a					; сброс флагов
			ld		hl,cmdTable
			ld		de,iBuffer
			call	parser
			cp		#ff
			jr		nz,shExt_Loop
			
			ld		hl,errorMsg
			call	printStr
			jr		shExt_Loop
