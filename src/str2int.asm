;---------------------------------------
; string to int converter
;---------------------------------------
; in: hl,string addr
; out:hl = value

str2int		ld	bc,#0000
		ld	de,#0000
		ex	de,hl
		ld	(intBuffer),hl
		ex	de,hl

calcLen		ld	a,(hl)
		cp	#20					; end as space
		jr	z,calcVal
		cp	#00					; end as zero
		jr	z,calcVal
		cp	"0"
		jr	c,wrongValue
		cp	"9"+1
		jr	nc,wrongValue
		inc	b
		inc	hl
		jr	calcLen

calcVal		ld	a,b
		cp	#00
		jr	z,wrongValue

		ld	(calcEnd+1),a
		ld	b,#00

calcLoop	dec	hl
		ld	a,(hl)
		sub	#30					; ascii 0

		push	hl
		push	bc

		push	af
		ld	a,b
		or	c
		jr	nz,calcSkip
		pop	af
		ld	h,0
		ld	l,a
		ld      (intBuffer),hl
		pop	af
		ld	bc,10
		jr	calcNext

calcSkip	pop	af
		push	bc
		pop	hl
		call	mult16x8
		ex	de,hl
		ld	hl,(intBuffer)
		add	hl,de
		ld      (intBuffer),hl

		pop	hl					; bc
		ld	a,10
		call    mult16x8
		push	hl
		pop	bc

calcNext	pop	hl

calcEnd		ld	a,#00
		dec	a
		ld	(calcEnd+1),a
		cp	#00
		jr	nz,calcLoop
		ld	hl,(intBuffer)
		xor	a					; ok
		ret

wrongValue	ld	hl,#0000
		ld	a,#ff					; error!
		ret

;-------------------------------------------
; multiplication
;-------------------------------------------
; in: hl * a
; out:hl,low de,high

mult16x8	ld	de,#0000
		ld	(mult16x8_2 + 1),de
	        cp      #00
		jr	nz,mult16x8_00
		ld	hl,#0000
		ret

mult16x8_00	cp	#01
		ret	z

		push	bc
		dec	a
		ld	b,a
		ld	c,0
		push	hl
		pop	de

mult16x8_0	add	hl,de
		jr	nc,mult16x8_1
		push	de
		ld	de,(mult16x8_2 + 1)
		inc	de
		ld	(mult16x8_2 + 1),de
		pop	de
mult16x8_1	djnz	mult16x8_0

mult16x8_2	ld	de,#0000
		pop	bc
		ret							

;-------------------------------------------
intBuffer	dw	#0000
