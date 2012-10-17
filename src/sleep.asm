;---------------------------------------
; sleep - wait in seconds
;---------------------------------------
sleepSeconds	ex	de,hl				; hl params
		call	str2int
		cp	#ff				; wrong params
		jr	nz,sleep_00

errorPar	ld	hl,errorParMsg
		call	printStr
		ret

sleep_00	ld	a,l
		cp	#00
		jr	nz,sleep_01
		ld	hl,anyKeyMsg
		call	printStr

		halt
		call	waitAnyKey
		jr	sleep_02

sleep_01	push	af
		ld	hl,restoreMsg
		call	printStr
		pop	af
		ld	b,a

sleep_01a	push	bc
		ld	b,50

sleep_01b	halt
		djnz	sleep_01b
		pop	bc
		djnz	sleep_01a

sleep_02	ret
