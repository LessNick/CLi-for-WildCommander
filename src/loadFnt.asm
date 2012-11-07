;---------------------------------------
; loadfnt - loading font
;---------------------------------------
loadTxtFnt	call	loadFnt
		cp	#00
		jr	nz,exitFnt
		
		push	hl
		; Включаем страницу с нашим фонтом
		ld	a,#01
		call	setVideoPage

		; Клонируем шрифт из #0000
		ld	hl,#0000
		ld	de,#c000
		ld	bc,2048
		ldir
		pop	hl

		xor	a

exitFnt		ex	af,af'
		xor	a				; убирает сообщение "unknown command"
		ret
;---------------------------------------
loadFnt		ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		ex	af,af'
		cp	#00
		call	z,findFntFile
		;cp	#ff
		;ret	z
		push	hl,af
		call	restorePath
		pop	af,hl
		ret

findFntFile	ld	a,flagFile			; file
		call	prepareEntry
			
		ld	hl,entrySearch
		call	searchEntry
		jp	z,fileNotFound
		
		ld	(fileLength),hl
		ld	(fileLength+2),de
		;ld	a,d
		;or	e
		;jr	nz


		call	setFileBegin
		call	prepareSize

		ld	hl,#0000
		push	hl
		call	load512bytes

		pop	hl

		xor	a
		ret