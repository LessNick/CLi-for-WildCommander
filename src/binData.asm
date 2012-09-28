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

welcomeMsg	db		16,6,"Command Line Interface for WildCommander v0.02",#0d
			db		16,7,"2012 (C) Breeze\\Fishbone Crew",#0d

readyMsg	db		#0d,16,16,"1>"
			db		#00

errorMsg	db		#0d
			db		16,10,"Error! Unknown command.",#0d,#0d
			db		#00

errorParMsg	db		#0d
			db		16,10,"Error! Wrong parameters.",#0d,#0d
			db		#00

anyKeyMsg	db		#0d
			db		16,7,"Press any key to continue.",#0d
endMsg		db		#0d,#00

passedMsg	db		#0d
			db		16,4,"Passed! ;)",#0d,#0d
			db		#00

wrongDevMsg	db		#0d
			db		16,10,"Error! Wrong device ID.",#0d,#0d
			db		#00

dirNotFoundMsg
			db		#0d
			db		16,10,"Error! Directory not found.",#0d,#0d
			db		#00

cantReadDirMsg
			db		#0d
			db		16,10,"Error! Can't read directory.",#0d,#0d
			db		#00

file83Msg	db		16,15,"             ",#00

entrySearch	ds		14,#00

rootSearch	db		FLAGDIR,".",#00

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

;---------------------------------------
; Command table below with all jump vectors.
cmdTable
			db		"exit"					; Command
			db		"*"						; 1 byte
			dw		closeCli				; 2 bytes

			db		"cls"					; Command
			db		"*"						; 1 byte
			dw		clearScreen				; 2 bytes

			db		"pwd"					; Command
			db		"*"						; 1 byte
			dw		pathWorkDir				; 2 bytes

			db		"sleep"					; Command
			db		"*"						; 1 byte
			dw		sleepSeconds			; 2 bytes

			db		"echo"					; Command
			db		"*"						; 1 byte
			dw		echoString				; 2 bytes

			db		"test"					; Command
			db		"*"						; 1 byte
			dw		testPassed				; 2 bytes
			
			db		"ls"					; Command
			db		"*"						; 1 byte
			dw		listDir					; 2 bytes

			db		"dir"					; Command
			db		"*"						; 1 byte
			dw		listDir					; 2 bytes

			db		"cd"					; Command
			db		"*"						; 1 byte
			dw		changeDir				; 2 bytes

			db		#00						; table end marker

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
