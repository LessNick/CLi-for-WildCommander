;---------------------------------------
; Hello world example
;---------------------------------------
		org	#c000-4
test1Start	
		db	#7f,"CLA"				; Command Line Application

		ld	hl,test1Msg
		call	printString
		
		xor	a					; no error, clean exit!
		ret
	
test1Msg	db	16,16
		db	"this is test long line with number is #00",#0d
		db	"this is test long line with number is #01",#0d
		db	"this is test long line with number is #02",#0d
		db	"this is test long line with number is #03",#0d
		db	"this is test long line with number is #04",#0d
		db	"this is test long line with number is #05",#0d
		db	"this is test long line with number is #06",#0d
		db	"this is test long line with number is #07",#0d
		db	"this is test long line with number is #08",#0d
		db	"this is test long line with number is #09",#0d
		db	"this is test long line with number is #0a",#0d
		db	"this is test long line with number is #0b",#0d
		db	"this is test long line with number is #0c",#0d
		db	"this is test long line with number is #0d",#0d
		db	"this is test long line with number is #0e",#0d
		db	"this is test long line with number is #0f",#0d
		db	#00

test1End	nop
