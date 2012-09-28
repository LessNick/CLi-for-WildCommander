; CLI (Command Line Interface) Plugin
; (C) breeze/fishbone crew 2012
;---------------------------------------
			org		#6200

			DISP	#8000

; Начало основного кода плагина

pluginStart	push	ix
			cp		#00					; вызов по расширению
			jp		z,callFromExt
			cp		#03					; вызов из меню запуска плагинов
			jp		z,callFromMenu
			jp		pluginExit

;---------------------------------------
			; Устанавливаем CLI-палитру
cliInit		ld		hl,cliPal
			call	initPal

			; Включаем текстовый режим и подготавливаем окружение
			call	txtModeInit

			; Предварительно очищаем экран
			call	clearTxt
			; Инициализируем переменные для печати в консоли
			call	printInit

			call	clearIBuffer
			ret

cliInitDev	call	initPath

			ld		b,deviceSDZC			; устройство SD-Card Z-Controller
			call	openStream
			ret		z						; если устройство найдено

			ld		a,"?"
			ld		(pathString),a

			ld		hl,wrongDevMsg			; иначе сообщить об ошибке
			call	printStr
			ret

initPath	ld		hl,pathString
			ld		de,pathString+1
			ld		bc,pathStrSize-1
			xor		a
			ld		(hl),a
			ldir
			
			ld		bc,#0001
			ld		(pathStrPos),bc
			ld		a,"/"
			ld		(pathString),a
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

			call	checkKeyEnter
			call	nz,enterKey

			call	checkKeyDel
			call	nz,deleteKey

			call	checkKeyUp
			call	nz,upKey

			call	checkKeyDown
			call	nz,downKey

			call	checkKeyLeft
			call	nz,leftKey

			call	checkKeyRight
			call	nz,rightKey

			call	getKeyWithShift
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
txtModeInit
			; Включаем страницу со страндартным фонтом WC
			ld		a,#ff
			call	setRamPage

			; Сохраняем копию шрифта в #0000			
			ld		hl,#c000
			ld		de,#0000
			ld		bc,2048
			ldir

			; Включаем страницу с нашим фонтом
			ld		a,#01
			call	setVideoPage

			; Клонируем шрифт из #0000
			ld		hl,#0000
			ld		de,#c000
			ld		bc,2048
			ldir

			; Включаем страницу с нашим текстовым режимом
			ld		a,#00
			call	setVideoPage

			; Переключаем видео на наш текстовый режим
			ld		a,#01				; #01 - 1й видео буфер (16 страниц)
			call	setTxtMode

			; На всякий случай переключаем разрешайку на 320x240 TXT
			ld		a,%10000011
			jp		setVideoMode

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

			ld		a,(iBuffer)
			cp		#00					; simple enter
			jr		z,enterReady	

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
			ei						
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
echoString	ex		de,hl
			push	hl
			ld		hl,endMsg
			call	printStr
			pop		hl
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
prepareEntry
			push	hl,af
			ld		hl,entrySearch
			ld		de,entrySearch+1
			ld		bc,13
			xor		a
			ld		(hl),a
			ldir
			pop		af
			pop		hl
			ld		de,entrySearch

entryLoop	ld		(de),a
			inc		de
			ld		a,(hl)
			inc		hl
			cp		#00
			ret		z
			cp		"/"
			ret		z
			cp		97					; a
			jr		c,entryLoop
			cp		123					; }
			jr		nc,entryLoop
			sub		#20
			jr		entryLoop

;---------------------------------------
showHelp	ld		hl,helpMsg
			call	printStr
			ld		hl,cmdTable

			ld		c,0
helpAgain	ld		b,13
helpLoop	ld		a,(hl)
			cp		#00
			jr		z,helpExit
			cp		"*"
			jr		nz,helpSkip
			inc		hl
			inc		hl
			inc		hl
			push	hl

helpSpace	ld		a," "
			push	bc
			call	printChar
			call	getNextPos
			pop		bc
			djnz	helpSpace
			pop		hl
			inc		c
			ld		a,c
			cp		6
			jr		nz,helpAgain
			ld		c,0
			push	hl,bc
			ld		hl,endMsg
			call	printStr
			pop		bc,hl
			jr		helpAgain

helpSkip	push	hl,bc
			call	printChar
			call	getNextPos
			pop		bc,hl
			inc		hl
			dec		b
			jr		helpLoop

helpExit	ld		hl,endMsg-1
			call	printStr
			ret

;---------------------------------------
pathWorkDir	ld		hl,endMsg
			call	printStr
			ld		hl,pathString
			call	printStr
			ret
;---------------------------------------
			include "api.asm"
			include	"sleep.asm"
			include	"ls.asm"
			include	"cd.asm"
			include	"sh.asm"
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
