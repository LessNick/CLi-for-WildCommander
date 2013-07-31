;---------------------------------------
; Load mod to GS
;---------------------------------------
gsPcmd		equ	#bb				; write: #bb - command port
gsPstat		equ	#bb				; read: #bb - register status
gsPdata		equ	#b3				; read/write - data port
gsPreset	equ	#33				; reset constant to be  written into

		org	#c000-4
t3Start	
		db	#7f,"CLA"			; Command Line Application

		ex	de,hl
		
		ld	hl,t3Msg_00
		call	printString
		
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		
		ld	hl,t3Msg_01
		call	printString

		;ld	hl,t3name
		ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound
		
		ld	(fileLength),hl
		ld	(fileLength+2),de

;		ld	hl,t3Msg_02
;		call	printString

		call	setFileBegin
		call	prepareSize

;		ld	hl,#c100
;		call	load512bytes

		push	bc

		ld	hl,t3Msg_03
		call	printString

		call	resetGS

		xor	a				; #00 Reset flags
		call	sendCmd

		ld	a,#f3				; #F3 Warm restart
		call	sendCmd

		ld	a,#23				; #23 Get number of RAM Pages
		call	sendCmd
		call	getData

		ld	a,#30				; #30 Load Module
		call	sendCmd
		ld	a,#d1				; #D1 Open Stream - открыть поток
		call 	sendCmd

		ld	hl,t3Msg_04
		call	printString

		pop	bc

_loopData	push	bc
		ld	b,#01				; load 1 block (512b)
		ld	hl,#c100
		call	load512bytes

		ld	hl,#c100
		;ld	de,(fileLength+2)
		ld	de,#0200

_nextData	ld	a,(hl)

		call	sendData

		inc	hl
		dec	de
		ld	a,d
		or	e
		jr	nz,_nextData			; loop for the next data

_finalize	in	b,(c)
		jp	m,_finalize			; wait for upload last b

		pop	bc
		djnz	_loopData

		ld	a,#d2				; #d2 Close stream
		call	sendCmd
		
		in	a,(gsPdata)			; номер модуля
		out	(gsPdata),a

		ld	hl,t3Msg_05
		call	printString

		ld	a,#31				; #31 - play module
		call	sendCmd

		ld	hl,restoreMsg
		call	printString
		xor	a				; no error, clean exit!
		ret

;-------
sendCmd		out	(gsPcmd),a
waitCmd		in	a,(gsPstat)
		rrca
		jr	c,waitCmd
		ret
;-------
sendData	out	(gsPdata),a
waitData	in	a,(gsPstat)
		rlca
		jr	c,waitData
		ret
;-------
getData		in	a,(gsPstat)
		rlca
		jr	nc,getData
		in	a,(gsPdata)
		ret
;-------
resetGS		ld	a,#80
		out	(gsPreset),a
		ret
;-------
t3Msg_00	db	16,16,"00.Start",#0d,#00
t3Msg_01	db	"01.Search",#0d,#00
t3Msg_02	db	"02.Load",#0d,#00
t3Msg_03	db	"03.Init GS",#0d,#00
t3Msg_04	db	"04.Upload GS",#0d,#00
t3Msg_05	db	"05.Play GS",#0d,#00


t3name		db	"daylight.mod",#00

t3End		nop
