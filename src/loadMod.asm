;---------------------------------------
; loadMod - loading mod music into (Neo)GS
;---------------------------------------

		org	#c000-4
loadModStart	
		db	#7f,"CLA"			; Command Line Application

		xor	a
		ld	(enableAutoPlay+1),a
		ld	(modPrintString+1),a

		ld	a,h
		or	l
		jp	z,modShowInfo
		ld	a,(hl)
		cp	#00
		jp	z,modShowInfo

		ld	de,keyTable
		call	checkCallKeys
		cp	#ff
		ret	z				; exit: error params

		ld	a,(hl)
		cp	#00
		ret	z				; no file

		push	hl
modNoParams	ld	hl,loadModMsg_01
		call	modPrintString

		call	initGS
		call	detectGS
		ld	a,(gsStatus)			; #00 - no error (GS present)
		cp	#00				; #01-#ff - something wrong
		jr	z,gsPresent
		
		ld	hl,loadModMsg_Error
		call	modPrintString
		jp	errExit

gsPresent	ld	hl,loadModMsg_Ok
		call	modPrintString

		ld	hl,loadModMsg_02
		call	modPrintString

;		ld	ix,(storeIx)			; wc panel status
;		ld	a,(ix+29)
		call	getPanelStatus
		cp	#02
		jr	nz,sdUnmounted
		
		ld	hl,loadModMsg_Error
		call	modPrintString
		jp	errExit

sdUnmounted	ld	hl,loadModMsg_Ok
		call	modPrintString

		ld	hl,loadModMsg_03
		call	modPrintString
		pop	hl
		push	hl
		call	modPrintString
		ld	hl,loadModMsg_03a
		call	modPrintString
		pop	hl

		call	checkIsPath

		ld	a,flagFile			; file
		call	prepareEntry
			
		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jr	z,modNotFound

		;ld	(fileLength),hl
		;ld	(fileLength+2),de
		call	storeFileLen

		ld	l,h				; count mod length in blocks
		ld	h,e
		srl	d
		rr	h
		rr	l
		srl	d
		rr	h
		rr	l
		srl	d
		rr	h
		rr	l
		inc	l
		jr	nz,$+3
		inc	h
		ld	(modLenBlocks),hl

		call	setFileBegin

		ld	hl,loadModMsg_Ok
		call	modPrintString

		ld	hl,loadModMsg_04
		call	modPrintString

		call	loadModFile			; load mod file into general sound card

		ld	hl,loadModMsg_Ok
		call	modPrintString

enableAutoPlay	ld	a,#00
		cp	#01
		jr	nz,loadModExit

		ld	hl,loadModMsg_05
		call	modPrintString

		;ld	a,#31
		;call	sendGsCmd
		call	playGs

loadModExit	;ld	hl,restoreMsg
		;call	modPrintString
		call	printRestore
		ret

modNotFound	ld	hl,loadModMsg_Error
		call	modPrintString
		ret

errExit		pop	hl
		ret

modShowInfo	ld	hl,modVersionMsg
		call	printString
		ld	hl,modUsageMsg
		call	printString
		ret

modLoaderHelp	ld	hl,modUsageMsg
		jp	printString

modPrintString	ld	a,#00
		cp	#01
		ret	z
		jp	printString

setAutoPlay	ld	a,#01
		ld	(enableAutoPlay+1),a
		ret

setSilentMode	ld	a,#01
		ld	(modPrintString+1),a
		ret

modLoaderVer	ld	hl,modVersionMsg
		jp	printString

;---------------------------------------
loadModFile	xor	a
		call	sendWaitGsCmd
		ld	a,#f3
		call	sendWaitGsCmd
		ld	a,#23
		call	sendWaitGsCmd
		exa
		ld	a,#30
		call	sendWaitGsCmd
		ld	a,#d1
		call	sendWaitGsCmd
		exa

		ld	de,#0006
		ld	h,d
		ld	l,a

		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de

		ld	a,(modLenBlocks+1)
		cp	h
		jr	nz,zem

		ld	b,a
		ld	a,(modLenBlocks)
		cp	l
		ld	a,b
		jr	z,noi

zem		jr	nc,brka
noi		or	a
		jr	z,na

noir		push	af
		ld	b,#00
		call	uploadGsData
		pop	af
		dec	a
		jr	nz,noir

na		ld	a,(modLenBlocks)
		ld	b,a
		call	uploadGsData

		ld	a,#d2
		call	sendWaitGsCmd
		in	a,(#b3)
		out	(#b3),a
		ret

brka		ld	a,#d2
		call	sendWaitGsCmd
		ret

;---------------------------------------
uploadGsData	push	bc
		ld	hl,loadBuffer
		ld	b,4
		call	load512bytes

		ld	hl,loadBuffer
		ld	bc,#00bb
		ld	e,#02

uploadGsLoop	call	uploadGsByte
		call	uploadGsByte
		call	uploadGsByte
		call	uploadGsByte

		djnz	uploadGsLoop

		dec	e
		jr	nz,uploadGsLoop

		pop	bc
		djnz	uploadGsData
		ret

; 		include	"neogs.h.asm"

modLenBlocks    dw	#0000
;------------------------------------------------------------------------
modVersionMsg	db	16,2,"MOD file loader for (Neo)GS Card v0.02",#0d
		db	16,3,"2013 ",127," Breeze\\\\FBn & Koshi(Budder)/MGN",#0d,#0d
		db	#00

modUsageMsg	db	16,12,"Usage: loadmod [switches] filename.mod",#0d
		db	16,16,"  -a \t",16,8,"autoplay. allow to automatically play the file after upload",#0d
		db	16,16,"  -s \t",16,8,"silent mode. additional information is not displayed",#0d
		db	16,16,"  -v \t",16,8,"version. show application's version and copyrights",#0d
		db	16,16,"  -h \t",16,8,"help. show this info",#0d,#0d
		db	16,16,#00


loadModMsg_01	db	16,13,"Try to detect General Sound (NeoGS)... \t",#00
loadModMsg_02	db	16,13,"Check NeoGS SD Card is't used... \t",#00

loadModMsg_03	db	16,13,"Try to open MOD file '",#00
loadModMsg_03a	db	"'... \t",#00

loadModMsg_04	db	16,13,"Loading module... \t\t\t",#00

loadModMsg_05	db	16,13,"Autoplay start...",#0d,#00

loadModMsg_Ok	db	16,16,"[ ",16,colorOk,"  OK  ",16,16," ]",#0d,#00
loadModMsg_Error
		db	16,16,"[ ",16,colorError,"ERROR!",16,16," ]",#0d,#00

;---------------------------------------------
; Key's table for params
;---------------------------------------------
keyTable	db	"-a"
		db	"*"
		dw	setAutoPlay

		db	"-h"
		db	"*"
		dw	modLoaderHelp

		db	"-s"
		db	"*"
		dw	setSilentMode

		db	"-v"
		db	"*"
		dw	modLoaderVer

;--- table end marker ---
		db	#00

loadBuffer	ds	2048,#00
loadModEnd	nop

		;DISPLAY "loadModStart addr:",/A,loadModStart
		;DISPLAY "sdUnmounted addr:",/A,sdUnmounted
		;DISPLAY "loadModLoop addr:",/A,loadModLoop
		;DISPLAY "loadModBuffer addr:",/A,loadModBuffer