;---------------------------------------
; NeoGS (General Sound) Library
;---------------------------------------
_uploadGsByte	in	a,(c)
		rlca
		jr	c,uploadGsByte

		ld	a,(hl)
		out	(pDataOutReg),a
		inc	hl
		ret

;---------------------------------------
_initGS		ld	a,cReset
		out	(pReset),a
		ld	b,tReset
		ei
		halt
		djnz	$-2
		ret

;---------------------------------------
_detectGS	in	a,(pDataInReg)
		ld	b,#00
		ld	c,a
stab		in	a,(pDataInReg)
		cp	c
		jr	nz,wse
		djnz	stab

		ld	a,cGetRAMPages
		out	(pCmdReg),a
		ld	bc,#0f00
dik		dec	bc
		ld	a,b
		or	c
		jr	z,wse
		in	a,(pStatusReg)		
		rrca
		jr	c,dik
		in	a,(pDataInReg)
		cp	#03
		jr	c,wse

		ld	a,#01
		out	(pDataOutReg),a
		ld	a,#6a
		call	sendWaitGsCmd

		xor	a
		out	(pDataOutReg),a
		ld	a,#6b
		call	sendWaitGsCmd
		
		xor	a
wze		ld	(gsStatus),a
		push	af
		ld	a,#f3
		call	sendGsCmd

		pop	af
		ret

wse		ld	a,#01
		or	a
		jr	wze

;---------------------------------------
_sendGsCmd	out	(pCmdReg),a
		ret

_sendWaitGsCmd	out	(pCmdReg),a
gswc		in	a,(pStatusReg)
		rrca
		jr	c,gswc
		ret
;-------
gwc		in	a,(pStatusReg)
		rrca
		ret

;-------
getdat		in	a,(pStatusReg)
		rlca
		jr	nc,getdat
		in	a,(pDataInReg)
		ret
;-------
muteGs		ld	a,#f3
		jr	_sendGsCmd

;-------
playGs		ld	a,#31
		jr	_sendGsCmd

;-------
gsStatus	db	#FF
