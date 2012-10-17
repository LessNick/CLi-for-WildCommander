;---------------------------------------
; CLI (Command Line Interface) Plugin
; (C) breeze/fishbone crew 2012
;---------------------------------------

        DEVICE ZXSPECTRUM128

		org	#be00
edit256		ds	128," "				; 128 bytes ascii
		ds	128,defaultCol			; 128 bytes colors
		
		org	#bf00

bufer256	ds	128," "				; 128 bytes ascii
		ds	128,defaultCol			; 128 bytes colors

		org	#6000

termWidth	equ	80
termHeight	equ	30
defaultCol	equ	%01011111
cursorType	equ	"_"
iBufferSize	equ	255
historySize	equ	10
eBufferSize	equ	iBufferSize
bufferAddr	equ	#0000
pathStrSize	equ	255*4

colorDir	equ	15				; white
colorFile	equ	8				; silver
colorRO		equ	1				; navy
colorHidden	equ	13				; teal
colorSystem	equ	2				; amiga pink
colorArch	equ	3				; dark violet

cliTxtPages	equ	5				; size Buffer for cli print (5 pages)
cliTxtBegin	equ	#20				; start page

appAddr		equ	#c000				; application load address
appBank		equ	#03				; application load memory bank

		include "wcKernel.h.asm"
		include "tsConf.h.asm"

		include "pluginHead.asm"
		include "cli.asm"

		include "helloworld.asm"
		include "test1.asm"


	;DISPLAY "downKey addr:",/A,downKey
	;DISPLAY "echoStr_00 addr:",/A,echoStr_00
	;DISPLAY "testCmd addr:",/A,testCmd
	;DISPLAY "executeApp addr:",/A,executeApp
	;DISPLAY "checkExtention addr:",/A,checkExtention
	;DISPLAY "listDir addr:",/A,listDir
	;DISPLAY "shellExecute addr:",/A,shellExecute
	;DISPLAY "executeApp addr:",/A,executeApp
	;DISPLAY "cdRoot addr:",/A,cdRoot
	;DISPLAY "cdSplitPath addr:",/A,cdSplitPath
	;DISPLAY "ttt addr:",/A,ttt
	;DISPLAY "cdNotFound addr:",/A,cdNotFound
	;DISPLAY "cdStart addr:",/A,cdStart
	DISPLAY "changeDir addr:",/A,changeDir

	SAVEBIN "bin/CLI.WMF", startCode, endCode-startCode
	SAVEBIN "bin/app/hello", appStart, appEnd-appStart
	SAVEBIN "bin/app/test1", test1Start, test1End-test1Start
