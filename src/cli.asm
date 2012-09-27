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
scriptAddr	equ		#0000

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
			db		"Command Line Interface v0.01    "

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
			ld		hl,scriptAddr
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

;---------------------------------------
callFromMenu
			call	cliInit
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
			include "parser.asm"
			include "str2int.asm"
			include "hex2int.asm"
;---------------------------------------
codeBuff	db		"  ",#00
scriptLength
			dw		#0000,#0000
storeKey	db		#00
strLen		db		#00
iBufferPos	db		#00
iBuffer		ds		iBufferSize,#00

curPosX		db		#00					; cursor Pos X
curPosY		db		#00					; cursor Pos Y
curPosAddr	dw		#c000				; cursor Pos Addr
curColor	db		defaultCol			; paper | ink

zxPal		dw		#0000,#0010,#4000,#4010
			dw		#0200,#0210,#4200,#4210
			dw		#0000,#0018,#6000,#6018
			dw		#0300,#0318,#6300,#6318

			
cliPal		
			;         rR   gG   bB
			;         RRrrrGGgggBBbbb
			dw		%0000000000000000	; 0.black
			dw		%0000000000010000	; 1.navy 
			;dw		%0100000000000000	; 2.maroon
			dw		%0110000100010000	; 2.amiga pink
			;dw		%0100000000010000	; 3.purple
			dw		%0010000000010000	; 3.dark violet
			dw		%0000001000000000	; 4.green
			;dw		%0000001000010000	; 5.teal
			dw		%0000000100010000	; 5.dark teal
			;dw		%0100001000000000	; 6.olive
			dw		%0110000100000000	; 6.orange
			dw		%0110001000010000	; 7.light beige
			;         rR   gG   bB
			;         RRrrrGGgggBBbbb
			;dw		%0010000100001000	; 8.gray
			dw		%0100001000010000	; 8.silver
			dw		%0000000000011000	; 9.blue
			dw		%0110000000000000	;10.red
			dw		%0110000000011000	;11.fuchsia
			dw		%0000001100000000	;12.lime
			;dw		%0000001100011000	;13.aqua
			dw		%0000001000011000	;13.teal
			dw		%0110001100000000	;14.yellow
			dw		%0110001100011000	;15.white

welcomeMsg	db		16,6,"Command Line Interface for WildCommander v0.01 Build ",#0d
			db		16,7,"2012 (C) Breeze\\Fishbone Crew",#0d

readyMsg	db		#0d,16,16,"1>"
			db		#00

errorMsg	db		#0d
			db		16,10,"Error! Unknown command.",#0d,#0d
			db		#00

errorParMsg	db		#0d
			db		16,10,"Error! Wrong parameters.",#0d,#0d
			db		#00

anyKeyMsg	db		#0d
			db		16,7,"Press any key to continue.",#0d
endMsg		db		#0d,#00

passedMsg	db		#0d
			db		16,4,"Passed! ;)",#0d,#0d
			db		#00

cursor_01	db		16,15,cursorType,16,16,#00
cursor_02	db		16,8,cursorType,16,16,#00
cursor_03	db		16,5,cursorType,16,16,#00
cursor_04	db		16,16," ",16,16,#00

curAnimPos	db		#00
curAnim		dw		cursor_01
			db		14
			dw		cursor_02
			db		5
			dw		cursor_03
			db		3
			dw		cursor_04
			db		1
			dw		cursor_03
			db		3
			dw		cursor_02
			db		5
			dw		#00

;---------------------------------------
; Command table below with all jump vectors.
cmdTable
			db	"exit"					; Command
			db	"*"						; 1 byte
			dw	closeCli				; 2 bytes

			db	"cls"					; Command
			db	"*"						; 1 byte
			dw	clearScreen				; 2 bytes

			db	"pwd"					; Command
			db	"*"						; 1 byte
			dw	pathWorkDir				; 2 bytes

			db	"sleep"					; Command
			db	"*"						; 1 byte
			dw	sleepSeconds			; 2 bytes

			db	"echo"					; Command
			db	"*"						; 1 byte
			dw	echoString				; 2 bytes

			db	"test"					; Command
			db	"*"						; 1 byte
			dw	testPassed				; 2 bytes

			db	#00			; table end marker

historyPos	db	#00

cliHistory	ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
			ds	iBufferSize, #00
pluginEnd
;---------------------------------------
	ENT

endCode		nop
