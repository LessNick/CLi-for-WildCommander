		org	#c100

cliPalStart	
		db	#7f,"PAL"				; Palette signature

		DUP	16
		;         rR   gG   bB
		;         RRrrrGGgggBBbbb
		dw	%0000000000000000		; 0.black
		dw	%0000000000010000		; 1.navy 
		dw	%0110000100010000		; 2.amiga pink
		dw	%0110001000011000		; 3.light violet
		dw	%0000001000000000		; 4.green
		dw	%0000000100010000		; 5.dark teal
		dw	%0110000100000000		; 6.orange
		dw	%0110001000010000		; 7.light beige
		;         rR   gG   bB
		;         RRrrrGGgggBBbbb
		dw	%0100001000010000		; 8.silver
		dw	%0000000000011000		; 9.blue
		dw	%0110000000000000		;10.red
		dw	%0100000000010000		;11.fuchsia
		dw	%0000001100000000		;12.lime
		dw	%0000001000011000		;13.teal
		dw	%0110001100000000		;14.yellow
		dw	%0110001100011000		;15.white

		EDUP
cliPalEnd	nop