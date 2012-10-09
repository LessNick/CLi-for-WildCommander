;---------------------------------------
; hex to int converter
;---------------------------------------
;in: hl,str addr | "0A"
;out:a,byte      | #0a (10)

hex2int		ld		a,(hl)
			call	hex2int_
			sla		a
			sla		a
			sla		a
			sla		a
			and		%11110000
			ld		c,a
			inc		hl
			ld		a,(hl)
			inc		hl
			call	hex2int_
			and		%00001111
			or		c
			ret

hex2int_	cp		"0"
			jr		c,wrongHex
			cp		"9"+1
			jr		nc,hCheck_00
			sub		#30					; 0 - 9
			ret

hCheck_00	cp		"A"
			jr		c,wrongHex
			cp		"F"+1
			jr		nc,hCheck_01
			sub		55					; A = 10
			ret
hCheck_01	cp		"a"
			jr		c,wrongHex
			cp		"f"+1
			jr		nc,wrongHex
			sub		87					; a = 10
			ret

wrongHex	xor		a
			ret
