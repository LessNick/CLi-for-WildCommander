;---------------------------------------
; Hello world example
;---------------------------------------
		org	#c000-4
test2Start	
		db	#7f,"CLA"				; Command Line Application

		ld	hl,test2Msg
		call	printString
		
		xor	a					; no error, clean exit!
		ret
	
test2Msg	db	16,16,"Hello world!",#0d
		db	#00

test2End		nop
