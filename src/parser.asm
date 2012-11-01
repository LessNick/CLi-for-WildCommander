;---------------------------------------
; Command line parser
;---------------------------------------
; In: de, command string addr
;	  hl, table of commands list
; Out:a,#ff = command not found
;     a,#00 - command found, hl - addr params start

;startCode
;		ld	hl,table
;		ld	de,cmd_buffer
;		call	parser

parser		call	eat_space
		ld	(storeAddr),de

		ld	a,(de)
		cp	"#"				; first simbol comment
		ret	z
		cp	";"				; first simbol comment
		ret	z

parse_start	ld      a,(de)
		cp	#00				; space means end of buffer
		jp	z,end_of_command
		cp	#20				; space means end of command
		jp	z,end_of_command

		cp	"A"
		jr	c,parse_skip
		cp	"Z"
		jr	nc,parse_skip
		add	32

parse_skip	cp	(hl)				; Compare a with first character in command table
		jp	nz,next_command			; Move HL to point to the first character of the next command in the table
		inc	de
		inc	hl
		jr	parse_start

next_command	push 	af
		ld	a,"*"
		cp	(hl)				; Is it the end off command * ?
		jp	z,forward			; Yes inc HL 3 times to set to begining of next command in the table

		ld	a,#00				; Table end reached ?
		cp	(hl)
		jp	z,no_match
		pop	af
		inc	hl
            	jp	next_command

forward		pop	af
		inc	hl
		inc	hl
		inc	hl
		ld	de,(storeAddr)
		jp	parse_start

end_of_command	call	eat_space
		ld	a,(hl)
		cp	"*"
		jr	nz,no_match+1

		inc	hl				; increase to *
							; Increase to point to jump vector for command
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		jp	(hl)				; de - addr start params

no_match	pop	af
							; Routine to print "Unkown command error"
		ld	a,#ff
		ret

eat_space	ld	a,(de)
		cp	#00
		ret	z				; if reach to the end of buffer
		cp	#20				; check for space
		ret	nz
		inc	de
		jp	eat_space

storeAddr	dw	#0000
