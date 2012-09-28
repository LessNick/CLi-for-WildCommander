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
			
			db		"ls"					; Command
			db		"*"						; 1 byte
			dw		listDir					; 2 bytes

			db		"dir"					; Command
			db		"*"						; 1 byte
			dw		listDir					; 2 bytes

			db		"cd"					; Command
			db		"*"						; 1 byte
			dw		changeDir				; 2 bytes
			
			db		"sh"					; Command
			db		"*"						; 1 byte
			dw		shellExecute			; 2 bytes

			db		"help"					; Command
			db		"*"						; 1 byte
			dw		showHelp				; 2 bytes

			db		#00						; table end marker
