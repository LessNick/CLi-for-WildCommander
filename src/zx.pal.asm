		org	#c100

zxPalStart	
		db	#7f,"PAL"				; Palette signature

		DUP	16
		dw	#0000,#0010,#4000,#4010
		dw	#0200,#0210,#4200,#4210
		dw	#0000,#0018,#6000,#6018
		dw	#0300,#0318,#6300,#6318
		EDUP

zxPalEnd	nop
