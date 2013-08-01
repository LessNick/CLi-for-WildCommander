;---------------------------------------
; Progress wait example
;---------------------------------------
		org	#c000-4
test2Start	
		db	#7f,"CLA"				; Command Line Application

		ld	hl,test2Msg
		call	printString
		
test2Loop	halt
		call	progressWait
		call	checkKeyEsc
		jr	nz,test2Exit
		jr	test2Loop
test2Exit
		;ld	hl,restoreMsg
		;call	printString
		call	printRestore
		xor	a					; no error, clean exit!
		ret
	
test2Msg	db	16,16,"Press ESC to exit...  "
		db	#00

test2End		nop
