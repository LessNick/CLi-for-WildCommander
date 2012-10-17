;---------------------------------------
; Hello world example
;---------------------------------------
		org	#c000-4
appStart	
		db	#7f,"CLA"				; Command Line Application

		ld	hl,helloMsg
		call	printString
		
		xor	a					; no error, clean exit!
		ret
	
helloMsg	db	16,16,"Hello world!",#0d
		db	#00

appEnd		nop
