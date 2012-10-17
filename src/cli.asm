;---------------------------------------
; Main loop file
;---------------------------------------
		org	#6200

		DISP	#8000

; Начало основного кода плагина

pluginStart	include "api.h.asm"
		include "api.asm"

_shellStart	push	ix
		cp	#00					; вызов по расширению
		jp	z,callFromExt
		cp	#03					; вызов из меню запуска плагинов
		jp	z,callFromMenu
		jp	wrongExit

;---------------------------------------
callFromExt	ld	(scriptLength),hl
		ld	(scriptLength+2),de

		call	checkExtention
		jp	z,runSh
		dec	a
		jp	z,runApp
;		dec	a
;		jp	z,mp3muz
		jp	wrongExit

;---------------------------------------
checkExtention	push	hl,de
		ld	de,entry
		call	getFatEntry

		ld	hl,entry+8
		ld	de,extSh
		call	checkEStr
		ld	a,0
		jr	z,checkEExit

		ld	hl,entry+8
		ld	de,extSpace
		call	checkEStr
		ld	a,1
		jr	z,checkEExit

		;ld	hl,entry+8
		;ld	de,mp3
		;call	checkEStr
		;d	a,2
		;jr	z,checkEExit
		
		ld	a,#ff

checkEExit	pop 	de,hl
		or 	a
		ret

checkEStr	ld 	a,(de)
		cp 	(hl)
		ret 	nz
		inc 	hl
		inc 	de
		
		ld	a,(de)
		cp	(hl)
		ret 	nz
		inc 	hl
		inc	de

		ld	a,(de)
		cp	(hl)
        	ret

;---------------------------------------
		; Устанавливаем CLI-палитру
cliInit		ld	hl,cliPal
		call	initPal

		; Инициализируем строку ввода
		call	editInit

		; Предварительно очищаем экран
		call	clearTxt

		; Включаем текстовый режим и подготавливаем окружение
		call	txtModeInit

		; Инициализируем переменные для печати в консоли
		call	printInit
		ret

cliInitDev	call	initPath

		ld	b,deviceSDZC			; устройство SD-Card Z-Controller
		call	openStream
		ret	z				; если устройство найдено

		ld	a,"?"
		ld	(pathString),a

		ld	hl,wrongDevMsg			; иначе сообщить об ошибке
		call	printStr
		ret

initPath	ld	hl,pathString
		ld	de,pathString+1
		ld	bc,pathStrSize-1
		xor	a
		ld	(hl),a
		ldir
			
		ld	bc,#0001
		ld	(pathStrPos),bc
		ld	a,"/"
		ld	(pathString),a
		ld	a,#0d
		ld	(pathString+1),a
		xor	a
		ld	(lsPathCount+1),a
		ret

;---------------------------------------
callFromMenu	call	cliInit
		call	cliInitDev

cliStart	ld	a,#00				
		cp	#00
		jr	nz,cliStart_0	
		ld	hl,versionMsg			; cold start
		call	printStr
		ld	hl,typeHelpMsg
		call	printStr
		ld	a,#01
		ld	(cliStart+1),a
			
cliStart_0	ld	hl,readyMsg			; warm start
		call	printEStr

		ei
mainLoop	halt					; Главный цикл (опрос клавиатуры)

		call	showCursor

		ld 	hl,edit256
		ld 	a,#01
		ld 	bc,#0000			; reserved
		call	BUF_UPD

		call	PRINTWW				; печать
		call	checkKeyEnter
		call	nz,enterKey

		call	checkKeyDel
		call	nz,deleteKey

		call	checkKeyAlt
		jr	nz,scrollMode
		call	z,scrollStop

skipAltKey	call	checkKeyUp
		call	nz,upKey

		call	checkKeyDown
		call	nz,downKey

		call	checkKeyLeft
		call	nz,leftKey

		call	checkKeyRight
		call	nz,rightKey

		call	getKeyWithShift
		call	nz,printKey

		jr	mainLoop

scrollStop	ld	a,#00
		ret	z
		xor	a
		ld	(scrollStop+1),a			; scroll stop
		ret

scrollMode	call	checkKeyUp
		call	nz,scrollUp

		call	checkKeyDown
		call	nz,scrollDown

		jr	mainLoop

scrollUp	ld	a,#01
		ld	(scrollStop+1),a			; scroll start
		ld	a,#01
		call	PR_POZ
		ret

scrollDown	ld	a,#01
		ld	(scrollStop+1),a			; scroll start
		ld	a,#02
		call	PR_POZ
		ret

;---------------------------------------
wrongExit	call	restoreExit
		pop	ix
		ld	a,1	 				; файл не опознан, пусть забирают вьюверы/другой плагин
		ret

pluginExit	call	restoreExit
		pop	ix
		xor	a	 				; просто выход
		ret

restoreExit	call	clearIBuffer

		; Восстанавливаем ZX-палитру
		ld	hl,zxPal
		call	initPal

		call	restoreWC
		ret

;---------------------------------------
txtModeInit	; Включаем страницу со страндартным фонтом WC
		ld	a,#ff
		call	setRamPage

		; Сохраняем копию шрифта в #0000			
		ld	hl,#c000
		ld	de,#0000
		ld	bc,2048
		ldir

		; Включаем страницу с нашим фонтом
		ld	a,#01
		call	setVideoPage

		; Клонируем шрифт из #0000
		ld	hl,#0000
		ld	de,#c000
		ld	bc,2048
		ldir

		; Включаем страницу с нашим текстовым режимом
		ld	a,#00
		call	setVideoPage

		; Переключаем видео на наш текстовый режим
		ld	a,#01					; #01 - 1й видео буфер (16 страниц)
		call	setTxtMode

		; На всякий случай переключаем разрешайку на 320x240 TXT
		ld	a,%10000011
		jp	setVideoMode

;---------------------------------------
; Очистка текстового экрана
			; Включаем страницу с нашим текстовым режимом
clearTxt	ld	a,#00
		call	setVideoPage

		ld	b,cliTxtPages

		ld      hl,#c000+128				; блок атрибутов
	        ld      de,#c001+128
	        ld	a,(curColor)
	        ld      b,64
attrLoop    	push    bc,de,hl
	        ld      bc,127
	        ld      (hl),a
	        ldir
	        pop     hl,de,bc
	        inc     h
	        inc     d
	        djnz    attrLoop

	        ld	a," "					; блок символов
	        ld      hl,#c000
	        ld      de,#c001
	        ld      b,64
scrLoop	   	push    bc,de,hl
	        ld      bc,127
	        ld     (hl),a
	        ldir
	        pop     hl,de,bc
	        inc     h
	        inc     d
	        djnz    scrLoop

restBorder  	ld	a,defaultCol				; восстановление бордера по умолчанию
	        and	%11110000
	        srl	a
	        srl	a
	        srl	a
	        srl	a

setBorder   	ld	bc,Border
	        out	(c),a
        	ret

;---------------------------------------
		;ld	hl,zxPal
initPal		ld	bc,FMAddr
		ld 	a,%00010000				; Разрешить приём данных для палитры (?) Bit 4 - FM_EN установлен
		out	(c),a

		ld 	de,#0000				; Память с палитрой замапливается на адрес #0000
		ld	b,e
        	ld	a,16
palLoop		push	hl
		ld	c,32
		ldir
		dec 	a
		pop	hl
		jr 	nz,palLoop

		ld 	bc,FMAddr			
		xor	a					; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a
		ret

;---------------------------------------
upKey		ld	a,(hCount)
		cp	#00
		ret	z
		ld	a,(historyPos)
		cp	#00
		jr	nz,upKey_00
		ld	c,a
		ld	a,(hCount)
		dec	a
		add	a,c
		jr	upKey_00a

upKey_00	dec	a

upKey_00a	push	af
		ld	hl,iBufferSize				;hl * a
		call	mult16x8
		push	hl
		pop	bc
		ld	hl,cliHistory
		add	hl,bc

		pop	af
		ld	(historyPos),a

upKey_01	ld	de,iBuffer
		ld	bc,iBufferSize
		ldir

		call	editInit
			
		ld	hl,readyMsg
		call	printEStr

		ld	hl,iBuffer
		call	printEStr

		ld	(iBufferPos),a
		ret

;---------------------------------------
downKey		ld	a,(hCount)
		cp	#00
		ret	z

		ld	a,(historyPos)
		cp	historySize
		jr	c,dnKey_00
		xor	a
		jr	dnKey_00a

dnKey_00	dec	a
		cp	#ff
		jr	nz,dnKey_00a

		xor	a

dnKey_00a	ld	hl,iBufferSize				;hl * a
		call	mult16x8
		push	hl
		pop	bc
		ld	hl,cliHistory
		add	hl,bc

		ld	a,(hCount)
		inc	a
		ld	c,a
		ld	a,(historyPos)
		inc	a
		cp	c
		jr	c,dnKey_00b
		ld	a,1
dnKey_00b	ld	(historyPos),a

		ld	de,iBuffer
		ld	bc,iBufferSize
		ldir

		call	editInit

		ld	hl,readyMsg
		call	printEStr

		ld	hl,iBuffer
		call	printEStr
		ld	(iBufferPos),a

		ret

;---------------------------------------
leftKey		ld	a,(iBufferPos)
		cp	#00
		ret	z
		dec	a
		ld	hl,iBuffer
		ld	b,0
		ld	c,a
		add	hl,bc
		push	af
		ld	a,(storeKey)
		ld	b,a
		ld	a,(hl)
		ld	(storeKey),a
		ld	a,b
		cp	#00
		jr	nz,leftKey_00
		ld	a," "
leftKey_00	call	printEChar
		pop 	af
		ld	(iBufferPos),a
		ld	a,(printEX)
		dec	a
		ld	(printEX),a
		ret

;---------------------------------------
rightKey	ld	a,(iBufferPos)
		inc	a
		ld	hl,iBuffer
		ld	b,0
		ld	c,a
		add	hl,bc
		push	af
		push	hl
		dec	hl
		ld	a,(hl)
		cp	#00
		jr	z,rightStop
		pop	hl
		ld	a,(storeKey)
		ld	b,a
		ld	a,(hl)
		ld	(storeKey),a
		ld	a,b
		cp	#00
		jr	nz,rightKey_00
		ld	a," "
rightKey_00	call	printEChar
		pop 	af
		ld	(iBufferPos),a
		ld	a,(printEX)
		inc	a
		ld	(printEX),a
		ret
rightStop	pop	hl
		pop	af
		ret

;---------------------------------------
enterKey	ld	a,defaultCol
		ld	(curEColor),a
		ld	a,(storeKey)
		call	printEChar
		call	printEUp
		ld	a,(iBuffer)
		cp	#00					; simple enter
		jr	z,enterReady

		call	putHistory

		xor	a					; сброс флагов
		ld	hl,cmdTable
		ld	de,iBuffer
		call	parser
		cp	#ff
		jr	nz,enterReady
		call	printInit
		ld	hl,errorMsg
		call	printStr

enterReady	ld	hl,readyMsg
		call	printEStr
		call	clearIBuffer
		ret

clearIBuffer	ld	hl,iBuffer
		ld	de,iBuffer+1
		ld	bc,iBufferSize-1
		xor	a
		ld	(hl),a
		ldir
		ld	(iBufferPos),a
		ret

putHistory	ld	a,(hCount)
		cp	historySize
		jr	c,ph_00

		ld	hl,cliHistory+iBufferSize
		ld	de,cliHistory
		ld	bc,(historySize-1)*iBufferSize
		ldir

		dec	a

ph_00		ld	hl,iBufferSize				;hl * a
		call	mult16x8
		push	hl
		pop 	bc
		ld	hl,cliHistory
		add	hl,bc
		ex	de,hl
		ld	hl,iBuffer
		ld	bc,iBufferSize
		ldir

		ld	a,(hCount)
		inc	a
		cp	historySize+1
		jr	nc,ph_01
		ld	(hCount),a

ph_01		ld	a,(hCount)
		ld	(historyPos),a
		ret

;---------------------------------------
deleteKey	ld	a,(iBufferPos)
		cp	#00					; уже удалено до самого конца
		jp	z,buffOverload+1

		ld	hl,iBuffer-1
		ld	b,#00
		ld	c,a
		add	hl,bc
		ld	(hl),b

		dec	a
		ld	(iBufferPos),a

		ld	a," "
		call	printEChar

		ld	a,(printEX)
		dec	a
		cp	#ff					; Начало строки буфера edit256
		jr	nz,putEX

;		ld	a,(iBufferPos)
;		cp	80-3					; 1>_ = 3 simbols
;		jr	c,delSkip
;		ld	a,79					; _ = 1 simbol
;delSkip	ld	b,#00
;		ld	c,a
;		ld	de,
;		ld	a,#01					; move up
;		call	PR_POZ

		ld	a,79
putEX		ld	(printEX),a
		
		ld	a,(iBufferPos)
		cp	#00
		ret	nz
		ld	a," "
		call	printEChar
		ret

;---------------------------------------
closeCli	pop	af					; skip sp ret
		pop	af
		jp	pluginExit

;---------------------------------------
clearScreen	xor	a
		call	PR_POZ
		ret

;---------------------------------------
showAbout	ld	hl,versionMsg
		call	printStr
		ld	hl,aboutMsg
		jr	echoPrint

;---------------------------------------
echoString	ex	de,hl
		push	hl
		call	printInit

		ld	hl,echoBuffer
		ld	de,echoBuffer+1
		ld	bc,eBufferSize-1
		xor	a
		ld	(hl),a
		ldir
		ld	(quoteFlag+1),a
		pop	hl
		ld	de,echoBuffer

echoStr_00	ld	a,(hl)
		cp	#00
		jr	z,echoPrint
		cp	"\""
		jr	nz,echoStr_01
		ld	a,(quoteFlag+1)
		xor	#01
		ld	(quoteFlag+1),a
		jr	echoStr_02

echoStr_01	ld	(de),a
		inc	de
echoStr_02	inc	hl
		jr	echoStr_00

echoPrint	ld	(de),a
		
		ld	hl,echoBuffer
quoteFlag	ld	a,#00
		cp	#01
		jr	nz,quoteOk
		ld	hl,wrongQuote
quoteOk		call	printStr
		ld	hl,restoreMsg
		call	printStr
		call	clearIBuffer
		ret

;---------------------------------------
prepareEntry	push	hl,af
		ld	hl,entrySearch
		ld	de,entrySearch+1
		ld	bc,13
		xor	a
		ld	(hl),a
		ldir
		pop	af
		pop	hl
		ld	de,entrySearch

entryLoop	ld	(de),a
		inc	de
		ld	a,(hl)
		inc	hl
		cp	#00
		ret	z
		cp	"/"
		ret	z
		cp	97					; a
		jr	c,entryLoop
		cp	123					; }
		jr	nc,entryLoop
		sub	#20
		jr	entryLoop

;---------------------------------------
showHelp	ld	hl,helpMsg
		call	printStr
			
		ld	hl,cmdTable

newLine		ld	de,helpOneLine
		ld	c,0
helpAgain	ld	b,13
helpLoop	ld	a,(hl)
		cp	#00
		jr	z,helpExit
		cp	"*"
		jr	nz,helpSkip
		inc	hl
		inc	hl
		inc	hl

helpSpace	ld	a," "
		ld	(de),a
		inc	de
		djnz	helpSpace

		inc	c
		ld	a,c
		cp	6
		jr	nz,helpAgain

		push	hl,de,bc
		ld	hl,helpOneLine
		call	printStr
		ld	hl,helpOneLine
		ld	de,helpOneLine+1
		ld	a," "
		ld	(hl),a
		ld	bc,13*6-1
		ldir
		pop	bc,de,hl
		jr	newLine

helpSkip	ld	(de),a
		inc	de
		inc	hl
		dec	b
		jr	helpLoop

helpExit	ld	hl,helpOneLine
		call	printStr
		ret

;---------------------------------------
pathWorkDir	ld	hl,pathString
		call	printStr
		ret
;---------------------------------------
storePath	ld	hl,pathBString
		ld	de,pathBString+1
		ld	bc,pathStrSize
		xor	a
		ld	(hl),a
		ldir

		ld	hl,pathString
		ld	de,pathBString
storeLoop	ld	a,(hl)
		cp	#00
		ret	z
		cp	#0d
		ret	z
		ld	(de),a
		inc	hl
		inc	de
		jr	storeLoop

restorePath	ld	de,pathBString
		call	changeDir
		ret

;---------------------------------------
checkIsPath	push	hl
		xor	a
		ld	(needCd+1),a
		ld	(pathCd+1),hl

cipLoop		ld	a,(hl)
		cp	#00
		jr	z,needCd
		cp	"/"
		jr	nz,cipNext
		ld	a,#01
		ld	(needCd+1),a
		ld	(pathCd+1),hl
cipNext		inc	hl
		jr	cipLoop

needCd		ld	a,#00				; need cd?
		cp	#00
		jr	z,cipExit

pathCd		ld	hl,#0000
		xor	a
		ld	(hl),a
		push	hl

		call	storePath
		pop	hl
		pop	de
		ld	a,(de)
		cp	#00				; root ?
		jr	nz,pathCd_00
		ld	de,rootPath
		
pathCd_00	inc	hl
		push	hl
		call	changeDir

pathCd_01	pop	hl
		ret

cipExit		call	storePath
		pop	hl
		xor	a
		ex	af,af'
		xor	a
		ret

rootPath	db	"/",#00
;---------------------------------------

;testCmd		; Включаем страницу для приложений
;		ld	a,#02
;		call	setVideoPage
;		ld	hl,exampleStart
;		ld	de,#c000
;		ld	bc,exampleEnd-exampleStart
;		ldir
;		call	#c000
;		ret
;
;exampleStart
;		ld	hl,helloMsg
;		call	printStr
;		ret
;exampleEnd
;
;helloMsg	db	16,16,"Hello world!",#0d
;		db	#00

;---------------------------------------
		include "print.asm"
		include	"sleep.asm"
		include	"ls.asm"
		include	"cd.asm"
		include	"sh.asm"
		include	"exec.asm"
		include "parser.asm"
		include "str2int.asm"
		include "hex2int.asm"
;---------------------------------------
		include "messages.asm"
		include "commands.asm"

		include "binData.asm"

pluginEnd
;---------------------------------------
	ENT
endCode		nop
