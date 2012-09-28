; Binary Data

codeBuff	db		"  ",#00
scriptLength
			dw		#0000,#0000
storeKey	db		#00
strLen		db		#00
iBufferPos	db		#00
iBuffer		ds		iBufferSize,#00

curPosX		db		#00					; cursor Pos X
curPosY		db		#00					; cursor Pos Y
curPosAddr	dw		#c000				; cursor Pos Addr
curColor	db		defaultCol			; paper | ink

zxPal		dw		#0000,#0010,#4000,#4010
			dw		#0200,#0210,#4200,#4210
			dw		#0000,#0018,#6000,#6018
			dw		#0300,#0318,#6300,#6318

			
cliPal		
			;         rR   gG   bB
			;         RRrrrGGgggBBbbb
			dw		%0000000000000000	; 0.black
			dw		%0000000000010000	; 1.navy 
			;dw		%0100000000000000	; 2.maroon
			dw		%0110000100010000	; 2.amiga pink
			;dw		%0100000000010000	; 3.purple
			dw		%0110001000011000	; 3.dark violet
			dw		%0000001000000000	; 4.green
			;dw		%0000001000010000	; 5.teal
			dw		%0000000100010000	; 5.dark teal
			;dw		%0100001000000000	; 6.olive
			dw		%0110000100000000	; 6.orange
			dw		%0110001000010000	; 7.light beige
			;         rR   gG   bB
			;         RRrrrGGgggBBbbb
			;dw		%0010000100001000	; 8.gray
			dw		%0100001000010000	; 8.silver
			dw		%0000000000011000	; 9.blue
			dw		%0110000000000000	;10.red
			dw		%0110000000011000	;11.fuchsia
			dw		%0000001100000000	;12.lime
			;dw		%0000001100011000	;13.aqua
			dw		%0000001000011000	;13.teal
			dw		%0110001100000000	;14.yellow
			dw		%0110001100011000	;15.white

file83Msg	db		16,15,"             ",#00

entrySearch	ds		14,#00

rootSearch	db		flagDir,".",#00

cursor_01	db		16,15,cursorType,16,16,#00
cursor_02	db		16,8,cursorType,16,16,#00
cursor_03	db		16,5,cursorType,16,16,#00
cursor_04	db		16,16," ",16,16,#00

curAnimPos	db		#00
curAnim		dw		cursor_01
			db		14
			dw		cursor_02
			db		5
			dw		cursor_03
			db		3
			dw		cursor_04
			db		1
			dw		cursor_03
			db		3
			dw		cursor_02
			db		5
			dw		#00

historyPos	db		#00

cliHistory	ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00
			ds		iBufferSize, #00

pathStrPos	dw		#0000
pathString	ds		pathStrSize,#00
			db		#00