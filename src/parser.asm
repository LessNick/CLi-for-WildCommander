; Input DE points to command buffer start
; HL points to command table

;startCode
;		ld	de,cmd_buffer
;		call	parser
;		jp	$

;cmd_buffer
;    		db	"cls"
;    		db	"videomode"
;    		db	"border 5"
;		ds	255,0

;parser
;			ld		hl,table
parser		call	eat_space
			ld		(storeAddr),de

			ld		a,(de)
			cp		"#"					; first simbol comment
			ret		z
			cp		";"					; first simbol comment
			ret		z
parse_start
			ld      a,(de)
			cp		#00					; space means end of buffer
			jp		z,end_of_command
			cp		#20					; space means end of command
			jp		z,end_of_command
			cp		(hl)				; Compare a with first character in command table
			jp		nz,next_command		; Move HL to point to the first character of the next command in the table
			inc		de
			inc		hl
			jr		parse_start

next_command
			push 	af
			ld		a,"*"
			cp		(hl)				; Is it the end off command * ?
			jp		z,forward			; Yes inc HL 3 times to set to begining of next command in the table

			ld		a,#00				; Table end reached ?
			cp		(hl)
			jp		z,no_match
			pop		af
			inc		hl
            jp		next_command

forward
			pop		af
			inc		hl
			inc		hl
			inc		hl
			ld		de,(storeAddr)
			jp		parse_start

end_of_command
			call	eat_space

			inc		hl					; increase to *
										; Increase to point to jump vector for command
			ld		a,(hl)
			inc		hl
			ld		h,(hl)
			ld		l,a
			jp		(hl)				; de - addr start params

no_match
			pop		af
										; Routine to print "Unkown command error"
			ld		a,#ff
			ret

eat_space
			ld		a,(de)
			cp		#00
			ret		z			; if reach to the end of buffer
			cp		#20			; check for space
			ret		nz
			inc		de
			jp		eat_space

storeAddr	dw		#0000
;--------------------------------------------------------------
;jumpvector1
;		ld	a,4
;		out	(254),a			; example1
;		ret
;
;jumpvector2
;		ld	a,3
;		out	(254),a			; example2
;		ret
;
;cmd_border
;		ex	de,hl			; hl params
;		call	str2int
;		ld	a,l
;		out	(254),a
;		ret
;
;--------------------------------------------------------------
;		include "str2int.asm"
;--------------------------------------------------------------
; Command table below with all jump vectors.
;table
;		db	"cls"			; Command
;		db	"*"			; 1 byte
;		dw	jumpvector1		; 2 bytes
;
;		db	"videomode"		; Command
;		db	"*"			; 1 byte
;		dw	jumpvector2		; 2 bytes
;
;		db	"border"		; Command
;		db	"*"			; 1 byte
;		dw	cmd_border		; 2 bytes
;
;		db	#00			; table end marker
