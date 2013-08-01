;---------------------------------------
; loadspr - loading sprite resource
;---------------------------------------

loadSprites	xor	a
		ld	a,c
		; TODO: если значение получилось больше #40, то включить следующую банку!
		sla	a
		sla	a
		sla	a	
		ld	(addAddr+2),a

		ex	de,hl
		ld	a,(hl)
		cp	#00
		jp	z,errorPar

		call	checkIsPath
		ex	af,af'
		cp	#ff
		jr	z,exitSpr

loadSpr		push	hl
		ld	a,(hl)
		inc	hl
		cp	#00
		jr	nz,loadSpr+1
		dec	hl
		dec	hl
		ld	de,sprType+2

		ld	a,(hl)
		ld	(de),a
		dec	de
		dec	hl
		ld	a,(hl)
		ld	(de),a
		dec	de
		dec	hl
		ld	a,(hl)
		ld	(de),a				; store extension

		pop	hl

		call	findSprFile
		;cp	#ff
		;ret	z
		push	hl,af
		call	restorePath
		pop	af,hl

exitSpr		ex	af,af'
		ret

findSprFile	ld	a,flagFile			; file
		call	prepareEntry
			
		;ld	hl,entrySearch
		;call	searchEntry
		call	eSearch
		jp	z,fileNotFound

		;ld	(fileLength),hl
		;ld	(fileLength+2),de
		call	storeFileLen

		call	setFileBegin
		call	prepareSize

		; TODO: Сделать проверку на тип файла, если bin = просто загрузка
		; если другой тип (tga,bmp,spr) загружать по частям и декодировать
		; если файл больше длины #4000, сменить банку

		ld	a,sprBank
		call	setVideoPage

		ld	a,(_PAGE3)			; устанавливаем страницу где у нас живут спрайты
		ld	bc,SGPage
		out	(c),a

		push	bc
		ld	hl,sprAddr
addAddr		ld	bc,#0000
		add	hl,bc
		pop	bc
		push	hl
		call	load512bytes
		pop	hl

		xor	a
		ret
