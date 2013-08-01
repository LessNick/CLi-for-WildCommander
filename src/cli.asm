;---------------------------------------
; Main loop file
;---------------------------------------
		org	#6200
		DISP	#8000

; Начало основного кода плагина

pluginStart	include "api.h.asm"
		ds	10*3,#00				; зарезервировано для будующего расширение
		include "gli.h.asm"
		ds	5*3,#00					; зарезервировано для будующего расширение
		include "mouse.h.asm"
		ds	5*3,#00					; зарезервировано для будующего расширение
		include	"neogs.h.asm"
		ds	5*3,#00					; зарезервировано для будующего расширение

		;ds	10,#00

_shellStart	ld	(storeIx),ix
		call	storeWcInt
		cp	#00					; вызов по расширению
		jp	z,callFromExt
;		cp	#01					; вызов при первом запуске
;		jp	z,callAtStart
		cp	#03					; вызов из меню запуска плагинов
		jp	z,callFromMenu
		jp	wrongExit

;---------------------------------------
;callAtStart	ld	a,#04
;		out	(254),a
;		halt
;		halt
;		xor	a
;		out	(254),a
;		ret
;---------------------------------------
callFromExt	;ld	(fileLength),hl
		;ld	(fileLength+2),de
		call	storeFileLen

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

		; Сохраняем палитру для TXT режима
		ld	a,palBank
		call	setVideoPage
		ld	hl,cliPal
		ld 	de,palAddr
		call	dupPal
		; Сохраняем палитру для GFX режима
		ld	a,gPalBank
		call	setVideoPage
		ld	hl,cliPal
		ld 	de,gPalAddr
		call	dupPal

		;ld	a,appBank
		;call	setVideoPage

		; Инициализируем строку ввода
		call	editInit

		; Предварительно очищаем экран
		call	clearTxt

		; Включаем текстовый режим и подготавливаем окружение
		call	txtModeInit

		; Инициализируем переменные для печати в консоли
		call	printInit

		call	initCallBack

		call	clearGfxScreen			; очищаем графический экран

		ld	a,#03				; устанавливаем режим 360x288
		call	setCliGfxResol

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
callFromMenu	call	setCLiInt

		call	cliInit
		call	cliInitDev

		call	storePath

		ld	de,binPath
		call	checkSystemDirs

		ld	de,fontsPath
		call	checkSystemDirs

		ld	de,libsPath
		call	checkSystemDirs

		ld	de,localePath
		call	checkSystemDirs

		ld	de,systemPath
		call	checkSystemDirs

		call	restorePath

		call	scopeBinary

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

		call	printWW				; печать
		call	checkKeyEnter
		call	nz,enterKey

		call	checkKeyDel
		call	nz,deleteKey

		call	checkKeyAlt
		jr	nz,scrollMode

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

scrollMode	call	checkKeyUp
		call	nz,scrollUp

		call	checkKeyDown
		call	nz,scrollDown

		jr	mainLoop

scrollUp	ld	a,#01
		call	PR_POZ
		ret

scrollDown	ld	a,#02
		call	PR_POZ
		ret

;---------------------------------------
wrongExit	call	restoreExit
		ld	ix,(storeIx)
		ld	a,1	 				; файл не опознан, пусть забирают вьюверы/другой плагин
		ret

pluginExit	call	restoreExit
		ld	ix,(storeIx)
		xor	a	 				; просто выход
		ret

restoreExit	call	clearIBuffer

		; Восстанавливаем ZX-палитру
		ld	hl,zxPal
		call	initPal
		call	restoreWCInt
		call	restoreWC
		ret
;---------------------------------------
storeWcInt	push	hl
		ld	hl,(_WCINT)
		ld	(wcIntAddr+1),hl
		pop	hl
		ret

restoreWCInt	ei
		halt
		di
		push	hl
		ld	hl,(wcIntAddr+1)
		ld	(_WCINT),hl
		pop	hl
		ei
		ret

setCLiInt	ei
		halt
		di
		push	hl
		ld	hl,cliInt
		ld	(_WCINT),hl
		pop	hl
		ei
		ret
;---------------------------------------
cliInt		push	hl,de,bc,af
		exx
		ex	af,af'
		push	hl,de,bc,af

		call	checkKeyAlt
		call	nz,checkVideoKey
		
		pop	af,bc,de,hl		
		exx
		ex	af,af'
		pop	af,bc,de,hl
wcIntAddr	jp	#0000

checkVideoKey	call	checkKeyF1
		jr	nz,setVideo0
		call	checkKeyF2
		jr	nz,setVideo1
		ret

setVideo0	call	hideSprites
		; Переключаем видео на наш текстовый режим
		ld	a,#01					; #01 - 1й видео буфер (16 страниц)
		call	setVideoBuffer

		; На всякий случай переключаем разрешайку на 320x240 TXT
		ld	a,%10000011
		call	setVideoMode

		call	restBorder

		ld	a,palBank
		call	setVideoPage

		ld	hl,palAddr
		call	setFilePal

		ld	a,appBank
		call	setVideoPage

		xor	a
		ld	hl,(callBackApp)
		jp	(hl)

setVideo1	call	showSprites
		; Переключаем видео на графический режим
		ld	a,#02					; #02 - 2й видео буфер (16 страниц)
		call	setVideoBuffer

		; Переключаем графический режим (по умолчанию 360x288 256c)
		ld	a,(currentVMode)
		;ld	a,%11000010
		call	setVideoMode

		ld	a,(curGfxBorder)
		call	setBorder

		ld	a,gPalBank
		call	setVideoPage

		ld	hl,gPalAddr
		call	setFilePal

		ld	a,appBank
		call	setVideoPage
		
		ld	a,#01
		ld	hl,(callBackApp)
		jp	(hl)

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

		jp	setVideo0

;---------------------------------------
; Очистка графического экрана c помощью DMA

gfxCls		ld	a,#10					; Включаем страницу с нашим графическим режимом
		call	setVideoPage

		ld	hl,#0000				; заливаем цветом первые 2 пикселя
		ld	(#c000),hl

		ld	a,#ff
		call	callDma					; ожидаем готовности DMA

		ld	bc,#1010				;
		call	gfxClsDma

		ld	bc,#1111				;		

gfxClsDma	ld	hl,0					; BHL - Source
		ld	de,2					; CDE - Destination
		ld	a,#00					; Инициализация источника(Source) и приёмника(Destination)
		call	callDma

		ld	a,#05					; выставление DMA_T
		ld	b,32*8-1				; B - кол-во бёрстов
		call	callDma
        	
        	ld	a,#06					; выставление DMA_N
        	ld	b,255					; B - размер бёрста
        	call	callDma

		ld	a,#fe					; запуск с ожиданием завершения (o:NZ - DMA занята)
		call	callDma

		ld	a,#00					; Восстанавливаем страницу с текстовым режимом
		call	setVideoPage

		ret

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
		call	dupPal

		ld 	bc,FMAddr			
		xor	a					; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a
		ret

dupPal		ld	b,#00
        	ld	a,16
palLoop		push	hl
		ld	c,32
		ldir
		dec 	a
		pop	hl
		jr 	nz,palLoop
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
		;ld	(curEColor),a
		ld	(curColor),a
		ld	a,(storeKey)
		call	printEChar
		call	printEUp

		ld	a,(iBuffer)
		cp	#00					; simple enter
		jr	z,enterReady

		call	putHistory

		ld	de,iBuffer
		call	checkIsExec				; ./filename

		xor	a					; сброс флагов
		ld	hl,cmdTable
		push	de
		call	parser
		pop	de
		cp	#ff
		jr	nz,enterReady
		call	checkIsBin
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
checkIsExec	push	de
		call	eat_space
		ld	a,(de)
		cp	"."
		jr	nz,noExec
		inc	de
		ld	a,(de)
		cp	"/"
		jr	nz,noExec
		inc	de					; file exec
		call	executeApp
		pop	af					; de
		pop	af					; ret	
		jr	enterReady				; exit

noExec		pop	de
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
		pop	af
		jp	pluginExit

;---------------------------------------
clearScreen	xor	a
		call	PR_POZ
		ret

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
		;ld	hl,restoreMsg
		;call	printStr
		call	printRestore
		call	clearIBuffer
		ret

;---------------------------------------
_checkCallKeys	
		push	hl
		ex	de,hl				; hl - адрес таблицы ключей
							; de - адрес строки с ключами
		xor	a				; сброс флагов
		ld	a,(de)
		cp	"-"
		jr	nz,exitNoKeys
checkCallLoop	push	hl
		call	parser
		ld	de,(storeAddr)
		pop	hl
		cp	#ff
		jr	z,errorCallExit
		ld	a,(de)
		cp	"-"
		jr	z,checkCallLoop

		pop	af
		ex	de,hl
		ret

errorCallExit	ex	hl,de
		push	hl
		ld	hl,unknownParamsMsg
		call	printStr
		pop	hl
		call	printSpaceStr
		;ld	hl,restoreMsg
		;call	printStr
		call	printRestore
		ld	a,#ff

exitNoKeys	pop	hl
		ret
;---------------------------------------
_prepareEntry	push	hl,af
		;ld	hl,entrySearch
		;ld	de,entrySearch+1
		ld	hl,entryForSearch
		ld	de,entryForSearch+1
		ld	bc,13
		xor	a
		ld	(hl),a
		ld	(entryQuote+1),a
		ldir
		pop	af
		pop	hl
		;ld	de,entrySearch
		ld	de,entryForSearch

entryLoop	ld	(de),a
		inc	de
		ld	a,(hl)
		inc	hl

		cp	"\""
		jr	nz, entrySkip

entryQuote	ld	a,#00
		cp	#01					; end quote
		ret	z
		xor	#01
		ld	(entryQuote+1),a
		ld	a,(hl)
		inc	hl

entrySkip	cp	#00
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
		jr	z,helpLast
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

		call	clearOneLine

		pop	bc,de,hl
		jr	newLine

helpSkip	ld	(de),a
		inc	de
		inc	hl
		dec	b
		jr	helpLoop

clearOneLine	ld	hl,helpOneLine
		ld	de,helpOneLine+1
		ld	a," "
		ld	(hl),a
		ld	bc,13*6-1
		ldir
		ret

helpLast	ld	hl,helpOneLine
		call	printStr
;---------------
		ld	hl,helpMsg2
		call	printStr

		ld	a,scopeBinBank
		call	setVideoPage

		call	clearOneLine

		ld	hl,scopeBinAddr
		ld	de,helpOneLine
		xor	a
		ld	(helpCount+1),a

helpLoop2	ld	a,(hl)
		cp	#00
		jr	z,helpExit
		ld	b,8
helpCopy	ld	a,(hl)
		cp	"A"
		jr	c,helpPaste
		cp	"Z"
		jr	nc,helpPaste
		add	32
helpPaste	ld	(de),a
		inc	hl
		inc	de
		djnz	helpCopy
		
helpCount	ld	a,#00
		inc	a
		ld	(helpCount+1),a
		cp	8
		jr	nz,helpSkip2
		xor	a
		ld	(helpCount+1),a
		push	hl,de
		ld	hl,helpOneLine
		call	printStr
		call	clearOneLine
		pop	de,hl
		ld	de,helpOneLine
		jr	helpLoop2

helpSkip2	inc	de
		inc	de
		jr	helpLoop2


helpExit	ld	hl,helpOneLine
		call	printStr
		ret

;---------------------------------------
storeHomePath	push	hl,de,bc

		ld	hl,pathHomeString
		ld	de,pathHomeString+1
		ld	bc,pathStrSize
		xor	a
		ld	(hl),a
		ldir

		ld	hl,pathString			; store current path to home app path
		ld	de,pathHomeString
		call	storeLoop
		pop	bc,de,hl
		ret

restoreHomePath	push	hl,de,bc
		ld	hl,pathHomeString		; restore current path from home app path
		ld	de,pathString
		ld	bc,pathStrSize
		ldir
		pop	bc,de,hl
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

		ld	de,pathBString
storePathCall	ld	hl,pathString
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
		jp	changeDir

;---------------------------------------
_checkIsPath	push	hl
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

;---------------------------------------
checkSystemDirs	call	changeDirSilent
		ex	af,af'
		cp	#00
		ret	z
		jp	systemBroken

;---------------------------------------
scopeBinary	ld	a,scopeBinBank
		call	setVideoPage

		call	clearScopeBin
		call	storePath
		
		ld	de,scopeBinAddr
		ld	(sbCopyName+1),de

		ld	de,binPath
		call	changeDir

		call	setFileBegin

sbReadAgain	call	clearBuffer

		ld	hl,bufferAddr
		ld	b,#01				; 1 block 512b
		call	load512bytes

		ld	hl,bufferAddr

sbLoop		ld	a,(hl)
		cp	#00
		jp	z,sbEnd

		push	hl
		pop	ix
		bit	3,(ix+11)
		jr	nz,sbSkip			; если 1, то запись это ID тома
		
		bit	4,(ix+11)
		jr	nz,sbSkip			; если 1, то каталог
		
		ld	a,(hl)
		cp	#e5
		jr	z,sbSkip

		push	hl
		call	sbCopyName
		pop	hl

sbSkip		
sbCount		ld	a,#00
		inc	a
		ld	(sbCount+1),a
		cp	16					; 16 записей на сектор
		jr	z,sbLoadNext

		ld	bc,32					; 32 byte = 1 item
		add	hl,bc
		jp	sbLoop

sbLoadNext	xor	a
		ld	(sbCount+1),a
		jp 	sbReadAgain

sbEnd		call	restorePath
		ret

sbCopyName	ld	de,scopeBinAddr

		push	hl
		push	de
		ld 	de,#08
		add	hl,de
		ld	a,(hl)
		cp	" "
		jr	nz,sbSkipFile
		inc	hl
		ld	a,(hl)
		cp	" "
		jr	nz,sbSkipFile
		inc	hl
		ld	a,(hl)
		cp	" "
		jr	nz,sbSkipFile
		pop	de
		pop	hl

		ld	b,8					; 16384 / 8 = 2048 bin files		
sbCopy		ld	a,(hl)
		cp	"A"
		jr	c,sbPaste
		cp	"Z"
		jr	nc,sbPaste
		add	32
sbPaste		ld	(de),a
		inc	hl
		inc	de
		djnz	sbCopy

		ld	(sbCopyName+1),de
		ret

sbSkipFile	pop	de
		pop	hl
		ret


clearScopeBin	ld	hl,scopeBinAddr
		ld	de,scopeBinAddr+1
		ld	bc,palAddr-scopeBinAddr-1
		xor	a
		ld	(hl),a
		ldir
		ret

;---------------------------------------
systemBroken	ld	a,%10111111
		ld	(curColor),a
		;ld	(curEColor),a
		call	printClear
		call	clearTxt

		ld	a,%00001011
		call	setBorder

		call	clearScreen

		ld	hl,brokenMsg
		call	printStr
		
		halt
		call	waitAnyKey

		pop	af
		jp	pluginExit

;---------------------------------------
checkIsBin	push	de
		ld	a,scopeBinBank
		call	setVideoPage

		ld	hl,cibFile
		ld	de,cibFile+1
		ld	bc,7
		xor	a
		ld	(hl),a
		ldir

		pop	de
		call	eat_space
		ex	de,hl

		ld	de,scopeBinAddr
cibLoop		ld	b,8
		push	de
		push	hl
cibLoop_00	ld	a,(de)
		cp	#00
		jr	z,cibError
		ld	c,a
		ld	a,(hl)
		cp	c
		jr	nz,cibNext
		inc	hl
		inc	de
		
ttt		ld	a,(hl)

		cp	" "				; end entered name?
		jr	z,cibLoop_01a
							
		cp	#00				; end entered name?
		jr	nz,cibLoop_02
		
cibLoop_01	ld	a,(de)
		cp	" "				; end name in embedded table?
		jr	z,cibOk
		
		cp	#00				; end name in external table?
		jr	nz,cibNext

		inc	hl
		ld	a,(hl)
		cp	" "
		jr	z,cibOk
		
		cp	#00
		jr	z,cibOk

		jr	cibNext

cibLoop_01a	inc	hl
		ld	(cibParams+1),hl
		jr	cibLoop_01

cibLoop_02	djnz	cibLoop_00			; file found
		jr	cibOk

cibNext		pop	hl
		pop	de
		ex	de,hl
		ld	bc,8
		add	hl,bc
		ex	de,hl	
		jr	cibLoop

cibOk		pop	hl
		pop	de
		ld	de,cibFile
		ld	b,8

		xor	a
		ld	(cibOk_00+1),a

cibOk_00	ld	a,#00
		cp	#00
		jr	nz,cibOk_EndName
		ld	a,(hl)
		cp	" "
		jr	nz,cibOk_01
		ld	a,#01
		ld	(cibOk_00+1),a

cibOk_EndName	xor	a
cibOk_01	ld	(de),a
		inc	hl
		inc	de
		djnz	cibOk_00

		;ld	bc,8
		;ldir

		ld	hl,cdBinPath
		ld	de,cibPath
		ld	bc,cibPath-cdBinPath
		ldir

		ld	de,cibPath
cibParams	ld	hl,#0000
		call	executeApp
		xor	a,#00				; no err
		ret

cibError	pop	hl
		pop	de
		ld	a,#ff				; err
		ret

;---------------------------------------
switchScreen	ex	de,hl
		call	str2int
		ld	a,h
		cp	#00
		jp	nz,errorPar
		ld	a,l
		cp	#00
		jp	z,setVideo0
		cp	#01
		jp	z,setVideo1
		jp	errorPar

;---------------------------------------
gfxBorder	ex	de,hl
		call	str2int
		ld	a,h
		cp	#00
		jp	nz,errorPar
		ld	a,l
		ld	(curGfxBorder),a
		ret

;---------------------------------------
wrongFileSize	ld	hl,wrongFileSizeMsg
		call	printStr
		ld	a,#ff				; error
		ret

;---------------------------------------
progressWait	ld	a,(progressWPos)
		ld	b,#00
		ld	c,a
		ld	hl,progressWData
		add	hl,bc
		ld	a,(hl)
		inc	hl
		ld	h,(hl)
		ld	l,a
		call	printStr
		ld	a,(progressWPos)
		inc	a
		inc	a
		cp	#08
		jr	c,progressWSkip
		xor	a
progressWSkip	ld	(progressWPos),a
		ret

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
		include "api.asm"
		include "print.asm"
		include	"sleep.asm"
		include	"ls.asm"
		include	"cd.asm"
		include	"sh.asm"
		include	"exec.asm"
		include "loadPal.asm"
		include "loadSpr.asm"
		include "loadFnt.asm"
		include "parser.asm"
		include "str2int.asm"
		include "int2str.asm"
		include "int2hex.asm"
		include "hex2int.asm"
		include "mouse.asm"
		include "gli.asm"
;---------------------------------------
		include "messages.asm"
		include "commands.asm"

		include "binData.asm"

storeIx		dw	#0000
pluginEnd
;---------------------------------------
	ENT
endCode		nop
