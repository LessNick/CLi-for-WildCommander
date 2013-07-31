;---------------------------------------
; loadMod - loading mod music into (Neo)GS
;---------------------------------------
					; general sound:
gsCommand	equ	#bb		; write: #bb - command port
gsStatus	equ	#bb		; read:  #bb - register status
gsData		equ	#b3		; read/write - data port
gsReset		equ	#33		; reset

		org	#c000-4
loadModStart	
		db	#7f,"CLA"			; Command Line Application

		ld	a,h
		or	l
		jp	z,errorPar

		push 	hl

		ld	hl,loadModMsg_01
		call	printString

		call	initUpload

		ld	hl,loadModMsg_02
		call	printString
		pop	hl
		push	hl
		call	printString
		ld	hl,loadModMsg_02a
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

		push	bc

		ld	hl,loadModMsg_03
		call	printString

		pop	bc

		dec	b
loadModLoop	push	bc
		ld	b,1
		ld	hl,loadModBuffer
		call	load512bytes

		ld	hl,loadModBuffer
		ld	de,#0200
		call	uploadModule

		ld	hl,loadModMsg_03a
		call	printString

		pop	bc
		djnz	loadModLoop

		call	finalUpload

		in	a,(gsData)	; get module Number
		out	(gsData),a	; select module ?

		ld	hl,loadModMsg_04
		call	printString

		call	playModule
		ret
;------------------------------------------------------------------------
initUpload      ld	a,#80
		out	(gsReset),a	; reset gs

		ld      a,#30           ; #30 Load Module
                call    sendCommand

                ld      a,#d1           ; #d1 Open Stream
                call    sendCommand
                ret
;------------------------------------------------------------------------
uploadModule
getNext		
		
waitReady	in	a,(c)
		jp	p,ready
		in	a,(c)
		jp	m,waitReady	; wait for ready general sound

ready		ld	a,(hl)
		out	(gsData),a
		inc	hl
		dec	de
		ld	a,d
		or	e
		jr	nz,getNext	; loop for the next data

finalize	in	a,(c)
		jp	m,finalize	; wait for upload last byte
		ret
;------------------------------------------------------------------------

playModule	ld	a,#31		;#31 Play module
		call	sendCommand
		ret
;------------------------------------------------------------------------
sendCommand	ld	c,gsCommand
		out	(gsCommand),a	; command port
waitResponse	in	a,(gsStatus)	; wait ready
		rrca
		jr	c,waitResponse
		ret
;------------------------------------------------------------------------
finalUpload	ld	a,#d2		; #d2 Close Stream
		call	sendCommand
		ret
;------------------------------------------------------------------------
loadModMsg_01	db	"Init General Sound (NeoGS)...",#0d,#00
loadModMsg_02	db	16,16,"Try to open MOD file \"",#00
loadModMsg_02a	db	"\"",#0d,#00

loadModMsg_03	db	"Loading module",#00
loadModMsg_03a	db	".",#00
loadModMsg_04	db	#0d,"Play.",#0d,#00

loadModBuffer	ds	512,#00
		db	#00,#00
loadModEnd	nop

		DISPLAY "loadModLoop addr:",/A,loadModLoop
		DISPLAY "loadModBuffer addr:",/A,loadModBuffer