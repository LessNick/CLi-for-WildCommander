; CLI (Command Line Interface) Plugin
; (C) breeze/fishbone crew 2012
;---------------------------------------
wcKernel	equ		#6006
termWidth	equ		80
termHeight	equ		30
defaultCol	equ		%01011111
cursorType	equ		"_"
iBufferSize	equ		255
historySize	equ		10
bufferAddr	equ		#0000
colorDir	equ		15					; white
colorFile	equ		8					; silver
colorRO		equ		1					; navy
colorHidden	equ		13					; teal
colorSystem	equ		2					; amiga pink
colorArch	equ		3					; dark violet

			include "wcKernel.h.asm"

			include "tsConf.h.asm"

			org		#6000
startCode
			; Заголовок (Описатель) плагина
			ds		16					; +00 reserved
			db		"WildCommanderMDL"	; +16 WildCommanderMDL
			db		#02					; +32 Версия формата
			db 		#00					; +33 reserved
			db		#01					; +34 Количество страниц
			db		#00					; +35 номер страницы, которая будет включаться в #8000!

			;dw		#00, #01			; +36 +0 - Номер страницы +1 - Размер блока (512b)
			db		#00, (pluginEnd - pluginStart) / 512 + 1
			db		#00,#00
			db		#00,#00
			db		#00,#00
			db		#00,#00
			db		#00,#00

			ds		16					; +48 - reserved

			db		"SH "				; +64 блок расширений "TXT", "WRD" и т.д.
			ds		31*3				;
			db		#00					; +160 #00

			dw		#6000, #0000		; +161 максимальный размер файла (определяет, какие файлы не нужно передавать)

			; +165 Имя плагина
			;    	 ********************************
			db		"Command Line Interface          "

			db		#03					; +197 Тип условий при которых должен вызываться плагин:
										; 	   #00 - только по расширению
										; 	   #01 - сразу после загрузки плагина
										; 	   #02 - по таймеру скринсейвера
										; 	   #03 - из меню запуска
			db		#00					; +198 reserved

;---------------------------------------
			org		#6200

			DISP	#8000

; Начало основного кода плагина

pluginStart	push	ix
			cp		#00					; вызов из меню запуска плагинов
			jr		z,callFromExt
			cp		#03					; вызов из меню запуска плагинов
			jp		z,callFromMenu
			jp		pluginExit

callFromExt
			ld		(scriptLength),hl
			ld		(scriptLength+2),de

			call	cliInit

			ld		bc,(scriptLength+2)
			ld		a,b
			or		c
			jr		z,callExt_00
			ld		b,#20				; 32 * 512 = 16384 (#4000)
			jr		callExt_01

callExt_00	ld		bc,(scriptLength)
			xor		a
			srl		b
			ld		a,b
			cp		#00
			jr		nz,callExt_01
			ld		b,#01				; 1 block 512b

callExt_01	cp		#20
			jr		c,callExt_02
			ld		b,#20

callExt_02	ld		a,c
			cp		#00
			jr		z,callExt_02a
			inc		b
callExt_02a
			ld		a,LOAD512
			ld		hl,bufferAddr
			push	hl
			call	wcKernel
callExt_Loop_
			call	clearIBuffer
			pop		hl
			ld		de,iBuffer	
callExt_Loop
			ld		a,(hl)
			cp		#00					;end file ?
			jp		z,pluginExit
			;jp		z,$
			cp		#0d					;end string?
			jr		z,callExt_03
			ld		(de),a
			inc		hl
			inc		de
			jr		callExt_Loop

callExt_03	inc		hl
			ld		a,(hl)
			cp		#0a
			jr		nz,callExt_03a
			inc		hl
callExt_03a
			push	hl
			xor		a					; сброс флагов
			ld		hl,cmdTable
			ld		de,iBuffer
			call	parser
			cp		#ff
			jr		nz,callExt_03b
			ld		hl,errorMsg
			call	printStr
callExt_03b	jr		callExt_Loop_

;---------------------------------------
			; Устанавливаем CLI-палитру
cliInit		ld		hl,cliPal
			call	initPal

			; Включаем текстовый режим и подготавливаем окружение
			call	setTxtMode

			; Предварительно очищаем экран
			call	clearTxt
			; Инициализируем переменные для печати в консоли
			call	printInit

			call	clearIBuffer
			ret

cliInitDev	ld		d,#00					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
			ld		b,DEVSDZX				; устройство 
			ld		a,STREAM
			call	wcKernel
			ret		z						; если устройство найдено

			ld		hl,wrongDevMsg			; иначе сообщить об ошибке
			call	printStr
			ret

;---------------------------------------
callFromMenu
			call	cliInit
			call	cliInitDev

cliStart			
			ld		hl,welcomeMsg
			call	printStr

			ei
mainLoop	halt
			call	getInput

			ld		a,ENKE
			call	wcKernel
			call	nz,enterKey

			ld		a,BSPC
			call	wcKernel
			call	nz,deleteKey

			ld		a,UPPP
			call	wcKernel
			call	nz,upKey

			ld		a,DWWW
			call	wcKernel
			call	nz,downKey

			ld		a,LFFF
			call	wcKernel
			call	nz,leftKey

			ld		a,RGGG
			call	wcKernel
			call	nz,rightKey

			ld		a,#00			; #00 - учитывает SHIFT
			ex		af,af'
			ld		a,KBSCN
			call	wcKernel
			call	nz,printKey

			jr		mainLoop

pluginExit
			; Восстанавливаем ZX-палитру
			ld		hl,zxPal
			call	initPal

			call	restoreWC

			pop		ix
			xor		a 					; просто выход
			ret

;---------------------------------------
setTxtMode
			; Включаем страницу со страндартным фонтом WC
			ld		a,#ff
			call	switchPage
			; Копируем в #0000			
			ld		hl,#c000
			ld		de,#0000
			ld		bc,2048
			ldir

			; Включаем страницу с нашим фонтом
										; включение страницы из видео буферов
			ld		a,#01				; #00-#0F - страницы из 1го видео буфера
			ex		af,af'				; #10-#1F - страницы из 2го видео буфера
			ld		a,MNGCVPL
			call	wcKernel
			; Восстанавливаем из #0000
			ld		hl,#0000
			ld		de,#c000
			ld		bc,2048
			ldir

			; Включаем страницу с нашим текстовым режимом
										; включение страницы из видео буферов
			ld		a,#00				; #00-#0F - страницы из 1го видео буфера
			ex		af,af'				; #10-#1F - страницы из 2го видео буфера
			ld		a,MNGCVPL
			call	wcKernel

			; Переключаем видео на наш текстовый режим
			ld		a,#01				; #01 - 1й видео буфер (16 страниц)
			ex		af,af'
			ld		a,MNGV_PL
			call	wcKernel

			; На всякий случай переключаем разрешайку на 320x240 TXT
			ld		a,%10000011
			ex		af,af'
			ld		a,GVmod
			call	wcKernel
			ret

;---------------------------------------
; Очистка текстового экрана
clearTxt	ld      hl,#c000+128		; блок атрибутов
	        ld      de,#c001+128
	        ld		a,(curColor)
	        ld      b,36
attrLoop    push    bc,de,hl
	        ld      bc,127
	        ld      (hl),a
	        ldir
	        pop     hl,de,bc
	        inc     h
	        inc     d
	        djnz    attrLoop

	        ld		a," "				; блок символов
	        ld      hl,#c000
	        ld      de,#c001
	        ld      b,36
scrLoop	    push    bc,de,hl
	        ld      bc,127
	        ld     (hl),a
	        ldir
	        pop     hl,de,bc
	        inc     h
	        inc     d
	        djnz    scrLoop

restBorder
	        ld		a,(curColor)		; бордер
	        and		%11110000
	        srl		a
	        srl		a
	        srl		a
	        srl		a
setBorder
	        ld		bc,Border
	        out		(c),a
        	ret

;---------------------------------------
; Восстановление видеорежима для WC
restoreWC	ld		a,#00				; #00 - основной экран (тхт)
			ex		af,af'
			ld		a,MNGV_PL
			jp		wcKernel

;---------------------------------------
switchPage	ex		af,af'				; A' - номер страницы (от 0)
			ld		a,MNGC_PL			; #FE - первый текстовый экран (в нём панели)
			jp		wcKernel			; #FF - страница с фонтом (1го текстового экрана)

;---------------------------------------
			;ld		hl,zxPal
initPal		ld		bc,FMAddr
			ld 		a,%00010000			; Разрешить приём данных для палитры (?) Bit 4 - FM_EN установлен
			out		(c),a

			ld 		de,#0000			; Память с палитрой замапливается на адрес #0000
			ld		b,e
        	ld		a,16
palLoop		push	hl
			ld		c,32
			ldir
			dec 	a
			pop		hl
			jr 		nz,palLoop

			ld 		bc,FMAddr			
			xor		a					; Запретить, Bit 4 - FM_EN сброшен
			out		(c),a
			ret
;---------------------------------------
upKey		ld		a,(historyPos)
			cp		#00
			ret		z
			dec		a
			ld		(historyPos),a
			ld		hl,iBufferSize		;hl * a
			call	mult16x8
			push	hl
			pop		bc
			ld		hl,cliHistory
			add		hl,bc
			ld		de,iBuffer
			ld		bc,iBufferSize
			ldir
			call	clearLine
			ld		hl,readyMsg+1
			call	printStr
			ld		hl,iBuffer
			call	printStr
			ld		(iBufferPos),a
			ret

;---------------------------------------
downKey		ld		a,(historyPos)
			cp		historySize
			ret		z
			inc		a
			ld		(historyPos),a
			ld		hl,iBufferSize		;hl * a
			call	mult16x8
			push	hl
			pop		bc
			ld		hl,cliHistory
			add		hl,bc
			ld		a,(hl)
			cp		#00
			jr		z,downUndo
			
			ld		de,iBuffer
			ld		bc,iBufferSize
			ldir
			call	clearLine
			ld		hl,readyMsg+1
			call	printStr
			ld		hl,iBuffer
			call	printStr
			ld		(iBufferPos),a
			ret

downUndo	ld		a,(historyPos)
			dec		a
			ld		(historyPos),a
			ret

;---------------------------------------
leftKey		ld		a,(iBufferPos)
			cp		#00
			ret		z
			dec		a
			ld		hl,iBuffer
			ld		b,0
			ld		c,a
			add		hl,bc
			push	af
			ld		a,(storeKey)
			ld		b,a
			ld		a,(hl)
			ld		(storeKey),a
			ld		a,b
			cp		#00
			jr		nz,leftKey_00
			ld		a," "
leftKey_00	call	printChar		
			pop 	af
			;dec		a
			ld		(iBufferPos),a
			ld		a,(curPosX)
			dec		a
			ld		(curPosX),a
			ld		(curPosAddr),a
			ret

;---------------------------------------
rightKey	ld		a,(iBufferPos)
			inc		a
			ld		hl,iBuffer
			ld		b,0
			ld		c,a
			add		hl,bc
			push	af
			push	hl
			dec		hl
			ld		a,(hl)
			cp		#00
			jr		z,rightStop
			pop		hl
			ld		a,(storeKey)
			ld		b,a
			ld		a,(hl)
			ld		(storeKey),a
			ld		a,b
			cp		#00
			jr		nz,rightKey_00
			ld		a," "
rightKey_00	call	printChar		
			pop 	af
			;inc		a
			ld		(iBufferPos),a
			ld		a,(curPosX)
			inc		a
			ld		(curPosX),a
			ld		(curPosAddr),a
			ret
rightStop	pop		hl
			pop		af
			ret

;---------------------------------------
enterKey	ld		a,(storeKey)
			cp		#00
			jr		nz,enterKey_00
			ld		a," "
enterKey_00	call	printChar
			xor		a
			ld		(storeKey),a

			ld		a,(historyPos)
			ld		hl,iBufferSize		;hl * a
			call	mult16x8
			push	hl
			pop 	bc
			ld		hl,cliHistory
			add		hl,bc
			ex		de,hl
			ld		hl,iBuffer
			ld		bc,iBufferSize
			ldir
			ld		a,(historyPos)
			inc		a
			cp		historySize
			jr		nz,enterKey_01
			xor		a
enterKey_01	ld		(historyPos),a
			
			xor		a					; сброс флагов
			ld		hl,cmdTable
			ld		de,iBuffer
			call	parser
			cp		#ff
			jr		nz,enterReady
			ld		hl,errorMsg
			call	printStr
enterReady
			ld		hl,readyMsg
			ld		a,(curPosX)
			cp		#00
			jr		nz,enterReady_01
			inc		hl
enterReady_01			
			call	printStr

			call	clearIBuffer
			ret

;---------------------------------------
deleteKey	ld		a,(iBufferPos)
			cp		#00
			jr		z,buffOverload+1
			ld		hl,iBuffer-1
			ld		b,#00
			ld		c,a
			add		hl,bc
			ld		(hl),b
			dec		a
			ld		(iBufferPos),a
			ld		a," "
			call	printChar
			call	getPrevPos
			ld		a," "
			call	printChar
			ret

;---------------------------------------
printKey	ld		hl,iBuffer
			ld		b,#00
			push	af
			ld		a,(iBufferPos)
			cp		iBufferSize-1
			jr		z,buffOverload		; Конец строки! Бип и выход!
			ld		c,a
			add		hl,bc
			inc		a
			ld		(iBufferPos),a
			pop		af
			ld		(hl),a
			call	printChar
			call	getNextPos
			ld		a,(iBufferPos)
			ld		b,0
			ld		c,a
			ld		hl,iBuffer
			add		hl,bc
			ld		a,(hl)
			ld		(storeKey),a
			ret

buffOverload
			pop		af
			ld		a,#02
			call	setBorder						
			halt
			call	restBorder
			ret

;---------------------------------------
printInit	xor		a
			ld		(curPosX),a
			ld		(curPosY),a
			ld		hl,#c000
			ld		(curPosAddr),hl
			ld		a,defaultCol
			ld		(curColor),a
			ret
;---------------------------------------
printStr	xor		a
			ld		(strLen),a
printStrLoop
			ld		a,(hl)
			cp		"\\"
			jr		nz,skipCode

			inc		hl
			ld		a,(hl)
			cp		"x"
			jr		nz,skipCode_00
			inc		hl
			call	hex2int
			dec		hl
			jr		skipCode

skipCode_00	cp		"n"
			jr		nz,skipCode_01
			ld		a,#0d
			jr		skipCode

skipCode_01	dec		hl					; no esc code simple backslash
			ld		a,"\\"

skipCode	cp		#00					; Управляющий код: 0 - выход
			jp		z,printStrExit

			cp		16					; Управляющий код: 16 - ink
			jr		nz,skipChar_01
			inc		hl
			ld		a,(hl)
			cp		"\\"
			jr		nz,nextCode16
			inc		hl
			ld		a,(hl)
			cp		"x"
			jr		nz,printStrLoop
			inc		hl
			call	hex2int
			dec		hl
nextCode16	cp		16					; 16 - default color
			jr		nz,notDef_01
			ld		a,defaultCol
notDef_01	and		%00001111
			ld		c,a
			ld		a,(curColor)
			and		%11110000
			or		c
			ld		(curColor),a
			inc		hl
			jr		printStrLoop
skipChar_01
			cp		17					; Управляющий код: 17 - paper
			jr		nz,skipChar_02
			inc		hl
			ld		a,(hl)
			cp		"\\"
			jr		nz,nextCode17
			inc		hl
			ld		a,(hl)
			cp		"x"
			jr		nz,printStrLoop
			inc		hl
			call	hex2int
			dec		hl
nextCode17	cp		16					; 16 - default color
			jr		nz,notDef_02
			ld		a,defaultCol
			and		%11110000
			jr		isDef_01
notDef_02	and		%00001111
			sla		a
			sla		a
			sla		a
			sla		a
isDef_01	ld		c,a
			ld		a,(curColor)
			and		%00001111
			or		c
			ld		(curColor),a
			inc		hl
			jp		printStrLoop
skipChar_02
			cp		13					; Управляющий код: 13 - new line (enter)
			jr		nz,skipChar_03
			push	hl
			ld		hl,curPosAddr
			call	getNext_1
			jr		skipFinal
skipChar_03
			cp		20					; Управляющий код: 20 - inverse
			jr		nz,skipChar_04
			ld		a,(curColor)
			and		%00001111
			sla		a
			sla		a
			sla		a
			sla		a
			ld		b,a
			ld		a,(curColor)
			and		%11110000
			srl		a
			srl		a
			srl		a
			srl		a
			or		b
			ld		(curColor),a
			inc		hl
			jp		printStrLoop
skipChar_04				
			push	hl
			call	printChar
			call	getNextPos
			ld		a,(strLen)
			inc		a
			ld		(strLen),a
skipFinal	pop		hl
			inc		hl
			jp		printStrLoop
printStrExit
			ld		a,(strLen)
			ret									; print string len

;---------------------------------------
			;ld		a,"A"
printChar	ld		hl,(curPosAddr)				; печать символа
			ld		(hl),a
			
			ld		a,(curColor)				; печать аттрибутов
			ld		de,128
			add		hl,de
			ld		(hl),a
			ret

getNextPos	ld		hl,curPosAddr
			ld		a,(curPosX)
			inc		a
			cp		termWidth
			jr		z,getNext_1
			ld		(curPosX),a
			inc		(hl)
			ret
getNext_1	xor		a
			ld		(curPosX),a
			ld		(hl),a
			ld		a,(curPosY)
			inc		a
			cp		termHeight
			jr		nz,getNext_2
			xor		a
getNext_2	ld		(curPosY),a
			ld		hl,#c000
			ld		d,a
			ld		e,0
			add		hl,de
			ex		de,hl
			ld		hl,curPosAddr+1
			ld		(hl),d
			ret

getPrevPos	ld		hl,curPosAddr
			ld		a,(curPosX)
			dec		a
			cp		#ff
			jr		z,getPrev_1
			ld		(curPosX),a
			dec		(hl)
			ret
getPrev_1	ld		a,termWidth-1
			ld		(curPosX),a
			ld		(hl),a
			ld		a,(curPosY)
			dec		a
			cp		#ff
			jr		nz,getPrev_2
			ld		a,termHeight-1
getPrev_2	ld		(curPosY),a
			ld		hl,#c000
			ld		d,a
			ld		e,0
			add		hl,de
			ex		de,hl
			ld		hl,curPosAddr+1
			ld		(hl),d
			ret

;---------------------------------------
getInput	
curTimeOut	ld		a,#00
			cp		#00
			jr		z,getInput_01
			dec		a
			ld		(curTimeOut+1),a
			ret
getInput_01
			ld		hl,curAnimPos
			ld		a,(hl)
			add		a,a
			add		a,(hl)
			ld		d,#00
			ld		e,a
			inc		(hl)
			ld		hl,curAnim
			add		hl,de
			ld		c,(hl)				; frame
			inc		hl
			ld		b,(hl)
			inc		hl
			ld		a,b
			or		c
			jr		nz,getInput_02
			xor		a
			ld		(curAnimPos),a
			jr		getInput

getInput_02
			ld		a,(hl)				; timeout
			ld		(curTimeOut+1),a
			ld		hl,(curPosX)
			push	hl
			ld		hl,(curPosAddr)
			push	hl
			push	bc
			pop		hl
			call	printStr
			pop		hl
			ld		(curPosAddr),hl
			pop		hl
			ld		(curPosX),hl
			ret

clearIBuffer
			ld		hl,iBuffer
			ld		de,iBuffer+1
			ld		bc,iBufferSize-1
			xor		a
			ld		(hl),a
			ldir
			ld		(iBufferPos),a
			ret

;---------------------------------------
closeCli	pop		af					; skip sp ret
			pop		af
			jp		pluginExit

;---------------------------------------
clearScreen	call	clearTxt
			call	printInit
			ret
;---------------------------------------
pathWorkDir
			ret

;---------------------------------------
sleepSeconds
			ex		de,hl				; hl params
			call	str2int
			cp		#ff					; wrong params
			jr		nz,sleep_00
			ld		hl,errorParMsg
			call	printStr
			ret

sleep_00	ld		a,l
			cp		#00
			jr		nz,sleep_01
			ld		hl,anyKeyMsg
			call	printStr

			halt
			ld		a,NUSP				; wait 4 anykey
			call	wcKernel
			jr		sleep_02

sleep_01	ld		b,a
sleep_01a	push	bc
			ld		b,50
sleep_01b	halt
			djnz	sleep_01b
			pop		bc
			djnz	sleep_01a
sleep_02
			ret

;---------------------------------------
echoString	ex		de,hl
			push	hl
			ld		hl,endMsg
			call	printStr
			pop		hl
			call	printStr
			ret
;---------------------------------------
testPassed	ld		hl,passedMsg
			call	printStr
			ret

;---------------------------------------
clearLine	ld		a,#00
			ld		(curPosX),a
			ld		(curPosAddr),a
			ld		b,termWidth
clLoop		push	bc
			ld		a," "
			call	printChar
			call	getNextPos
			pop		bc
			djnz	clLoop
			call	getPrevPos
			ld		a,#00
			ld		(curPosX),a
			ld		(curPosAddr),a
			ret

;---------------------------------------
listDir		;ld		d,#00					; окрываем поток с устройством (пока всегда #00)
			;ld		b,DEVSDZX				; устройство 
			;ld		a,STREAM
			;call	wcKernel
			;jp		nz,lsError				; если устройство не найдено
			;ld		a,GIPAGPL
			;call	wcKernel

lsPathCount	ld		a,#00					; path counter
			cp		#00
			jr		nz,lsNotRoot

			ld		d,#ff					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
			ld		bc,#ffff				; устройство (#ffff = не создавать заново, использовать текущий поток)
			ld		a,STREAM
			call	wcKernel
			jr		lsBegin

lsNotRoot	ld		hl,rootSearch
			ld		a,FENTRY
			call	wcKernel
			jp		z,lsCantReadDir

lsBegin		ld		hl,endMsg
			call	printStr
			
			xor		a
			ld		(lsCount+1),a

			ld		a,GFILE
			call	wcKernel

lsReadAgain	call	clearBuffer

			ld		hl,bufferAddr
			ld		b,#01					; 1 block 512b
			ld		a,LOAD512
			call	wcKernel

			ld		hl,bufferAddr

lsLoop		ld		a,(hl)
			cp		#00
			jp		z,lsEnd					; если #00 конец записей

			push	hl
			pop		ix
			bit		3,(ix+11)
			jr		nz,lsSkip+1				; если 1, то запись это ID тома
			ld		a,(hl)
			cp		#e5
			jr		z,lsSkip+1

			push	hl
			call	lsCopyName

			bit		4,(ix+11)
			jr		z,lsNext_00			; если 1, то каталог
			ld		a,colorDir
			jr		lsNext

lsNext_00	bit		0,(ix+11)
			jr		z,lsNext_01			; если 1, то файл только для чтения
			ld		a,colorRO
			jr		lsNext

lsNext_01	bit		1,(ix+11)
			jr		z,lsNext_02			; если 1, то файл скрытый
			ld		a,colorHidden
			jr		lsNext

lsNext_02	bit		2,(ix+11)
			jr		z,lsNext_03			; если 1, то файл системный
			ld		a,colorSystem
			jr		lsNext

lsNext_03	bit		5,(ix+11)
			jr		z,lsNext_04			; если 1, то файл системный
			ld		a,colorArch
			jr		lsNext

lsNext_04	ld		a,colorFile			; в противном случает - обычный файл

lsNext		ld		(file83Msg+1),a
			ld		hl,file83Msg
			call	printStr

lsCount		ld		a,#00
			inc		a
			ld		(lsCount+1),a
			cp		#06
			jr		nz,lsSkip
			xor		a
			ld		(lsCount+1),a
			ld		hl,endMsg
			call	printStr

lsSkip		pop		hl

itemsCount	ld		a,#00
			inc		a
			ld		(itemsCount+1),a
			cp		16						; 16 записей на сектор
			jr		z,lsLoadNext

			ld		bc,32					; 32 byte = 1 item
			add		hl,bc
			jp		lsLoop

lsEnd		ld		hl,endMsg
			call	printStr
			ret

lsLoadNext	xor		a
			ld		(itemsCount+1),a
			jp 		lsReadAgain

clearBuffer	ld		hl,bufferAddr
			ld		de,bufferAddr+1
			ld		bc,#1fff
			xor		a
			ld		(hl),a
			ldir
			ret

lsCopyName	push	hl
			ld		hl,file83Msg+2
			ld		de,file83Msg+3
			ld		bc,12
			ld		a," "
			ld		(hl),a
			ldir
			pop		hl
			ld		de,file83Msg+2
			ld		b,#00
lsCopyLoop	ld		a,(hl)
			cp		" "
			jr		z,lsCopySkip
			ld		(de),a
			inc		de
lsCopySkip	inc		b						; счётчик символов всего (позиция)
			inc		hl
			ld		a,b
			cp		11
			ret		z
			cp		8						; 8.3
			jr		nz,lsCopyLoop
			ld		a,(hl)
			cp		" "
			ret		z
			ld		a,"."
			ld		(de),a
			inc		de
			jr		lsCopyLoop

lsCantReadDir
			ld		hl,cantReadDirMsg
			call	printStr
			ret

;---------------------------------------
changeDir	ex		de,hl				; hl params
			push	hl
			ld		hl,entrySearch
			ld		de,entrySearch+1
			ld		bc,13
			xor		a
			ld		(hl),a
			ldir
			pop		hl
			ld		de,entrySearch
			ld		a,FLAGDIR			; directory

cdLoop		ld		(de),a
			inc		de
			ld		a,(hl)
			inc		hl
			cp		#00
			jr		nz,cdLoop

			ld		hl,entrySearch
			ld		a,FENTRY
			call	wcKernel
			jr		z,cdNotFound

			ld		a,GDIR
			call	wcKernel

			ld		hl,entrySearch+1
			ld		a,(hl)
			cp		"."
			jr		nz,cdIncPath
			inc		hl
			ld		a,(hl)
			cp		"."
			jr		nz,cdSkipPath

			ld		a,(lsPathCount)
			cp		#00
			jr		z,cdSkipPath
			dec		a
			ld		(lsPathCount),a
			jr		cdSkipPath
cdIncPath	ld		a,(lsPathCount)
			inc		a
			ld		(lsPathCount),a

cdSkipPath	xor		a					; no error
			ret
cdNotFound
			ld		hl,dirNotFoundMsg
			call	printStr
			ret

;---------------------------------------
			include "parser.asm"
			include "str2int.asm"
			include "hex2int.asm"
;---------------------------------------
			include "binData.asm"
pluginEnd
;---------------------------------------
	ENT

endCode		nop
