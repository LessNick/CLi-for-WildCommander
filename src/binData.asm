;---------------------------------------------
; Binary Data
;---------------------------------------------

codeBuff	db	"  ",#00
scriptLength
		dw	#0000,#0000
storeKey	db	#00


iBufferPos	db	#00
iBuffer		ds	iBufferSize,#00

curColor	db	defaultCol			; paper | ink
curEColor	db	defaultCol			; paper | ink

zxPal		dw	#0000,#0010,#4000,#4010
		dw	#0200,#0210,#4200,#4210
		dw	#0000,#0018,#6000,#6018
		dw	#0300,#0318,#6300,#6318
		
		;         rR   gG   bB
		;         RRrrrGGgggBBbbb
cliPal		dw	%0000000000000000		; 0.black
		dw	%0000000000010000		; 1.navy 
;		dw	%0100000000000000		; 2.maroon
		dw	%0110000100010000		; 2.amiga pink
;		dw	%0100000000010000		; 3.purple
		dw	%0110001000011000		; 3.light violet
		dw	%0000001000000000		; 4.green
;		dw	%0000001000010000		; 5.teal
		dw	%0000000100010000		; 5.dark teal
;		dw	%0100001000000000		; 6.olive
		dw	%0110000100000000		; 6.orange
		dw	%0110001000010000		; 7.light beige
		;         rR   gG   bB
		;         RRrrrGGgggBBbbb
;		dw	%0010000100001000		; 8.gray
		dw	%0100001000010000		; 8.silver
		dw	%0000000000011000		; 9.blue
		dw	%0110000000000000		;10.red
		dw	%0100000000010000		;11.fuchsia
		dw	%0000001100000000		;12.lime
;		dw	%0000001100011000		;13.aqua
		dw	%0000001000011000		;13.teal
		dw	%0110001100000000		;14.yellow
		dw	%0110001100011000		;15.white

nameEmpty	db	"             "

fileOneLine	db	16,15,"             "
		db	16,15,"             "
		db	16,15,"             "
		db	16,15,"             "
		db	16,15,"             "
		db	16,15,"             "
		db	#0d,#00				; end

helpOneLine	db	"             "
		db	"             "
		db	"             "
		db	"             "
		db	"             "
		db	"             "
		db	#0d,#00				; end

entrySearch	ds	14,#00

rootSearch	db	flagDir,".",#00

curAnimPos	db	#00
curAnim		db	14,15				; timeout,color
		db	5,8				; timeout,color
		db	7,5				; timeout,color
		db	5,8				; timeout,color
		db	#00

hCount		db	#00
historyPos	db	#00
cliHistory	DUP	historySize
		ds	iBufferSize, #00
		EDUP

pathStrPos	dw	#0000
pathString	ds	pathStrSize,#00
		db	#00
