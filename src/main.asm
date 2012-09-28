        DEVICE ZXSPECTRUM128

			org #6000

termWidth	equ		80
termHeight	equ		30
defaultCol	equ		%01011111
cursorType	equ		"_"
iBufferSize	equ		255
historySize	equ		10
bufferAddr	equ		#0000
pathStrSize	equ		255*4

colorDir	equ		15					; white
colorFile	equ		8					; silver
colorRO		equ		1					; navy
colorHidden	equ		13					; teal
colorSystem	equ		2					; amiga pink
colorArch	equ		3					; dark violet

			include "wcKernel.h.asm"
			include "tsConf.h.asm"

			include "pluginHead.asm"
			include "cli.asm"

	;DISPLAY "startCode is:",/A,startCode
	;DISPLAY "endCode is:",/A,endCode
	;DISPLAY "len is:",/A,endCode-startCode
	;DISPLAY "code size (bytes):",/A,(pluginEnd - pluginStart)
	;DISPLAY "code size (blocks):",/A,(pluginEnd - pluginStart) / 512 + 1
	;DISPLAY "iBuffer addr:",/A,iBuffer
	;DISPLAY "sleepSeconds addr:",/A,sleepSeconds
	;DISPLAY "echoString addr:",/A,echoString
	;DISPLAY "enterKey addr:",/A,enterKey
	;DISPLAY "cliHistory addr:",/A,cliHistory
	;DISPLAY "upKey addr:",/A,upKey
	;DISPLAY "leftKey addr:",/A,leftKey
	;DISPLAY "callFromExt addr:",/A,callFromExt
	;DISPLAY "pluginExit addr:",/A,pluginExit
	;DISPLAY "test addr:",/A,test
	DISPLAY "listDir addr:",/A,listDir
	;DISPLAY "changeDir addr:",/A,changeDir
	;DISPLAY "cliInit addr:",/A,cliInit
	;DISPLAY "cdLoop addr:",/A,cdLoop
	;DISPLAY "helpSpace addr:",/A,helpSpace
	;DISPLAY "shellExecute addr:",/A,shellExecute
	;DISPLAY "shExt_01 addr:",/A,shExt_01
	;DISPLAY "pluginStart addr:",/A,pluginStart
	DISPLAY "cdSplitPath addr:",/A,cdSplitPath

	SAVEBIN "bin/CLI.WMF", startCode, endCode-startCode
