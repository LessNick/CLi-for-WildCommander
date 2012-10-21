;--------------------------------------------------------------
;		ld 	de,stringAddr  		; ascii
;		ld 	hl,intAddr		; code
;		call 	int2hex

int2hex		push	hl
		ld 	a,(hl)			; перевод числа в текст
		push 	hl
		and 	#f0
		rra 
		rra 
		rra 
		rra 
		
		ld 	hl,letters
		ld 	b,0
		ld 	c,a
		add 	hl,bc
		
		ld 	a,(hl)
		ld 	(de),a
		inc	de
		
		pop 	hl
		ld 	a,(hl)
		and 	#0f
		
		ld 	hl,letters
		ld 	b,0
		ld 	c,a
		add 	hl,bc
		
		ld 	a,(hl)
		ld 	(de),a
						
		pop	hl
		ret

letters	db	"0123456789ABCDEF"