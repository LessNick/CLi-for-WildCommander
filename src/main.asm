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

colorError	equ	10				; red
colorWarning	equ	14				; yellow
colorOk		equ	12				; lime
colorInfo	equ	13				; teal
	
cliTxtPages	equ	5				; size Buffer for cli print (5 pages)
cliTxtBegin	equ	#20				; start page

appAddr		equ	#c000				; application load address
appBank		equ	#03				; application load memory bank

scopeBinAddr	equ	#c000				; /bin list address start
scopeBinBank	equ	#04				; /bin application list

palAddr		equ	#c000				; palette file load address
palBank		equ	#05				; palette file load memory bank

		include "wcKernel.h.asm"
		include "tsConf.h.asm"

		include "pluginHead.asm"
		include "cli.asm"

		;include "helloworld.asm"
		;include "test1.asm"

		;include "zx.pal.asm"
		;include "cli.pal.asm"


	;DISPLAY "closeCli addr:",/A,closeCli
	;DISPLAY "checkIsExec addr:",/A,checkIsExec
	;DISPLAY "callFromMenu addr:",/A,callFromMenu
	DISPLAY "enterKey addr:",/A,enterKey

	SAVEBIN "bin/CLI.WMF", startCode, endCode-startCode
	;SAVEBIN "bin/app/hello", appStart, appEnd-appStart
	;SAVEBIN "bin/app/test1", test1Start, test1End-test1Start

	;SAVEBIN "bin/pal/zx.pal", zxPalStart, zxPalEnd-zxPalStart
	;SAVEBIN "bin/pal/cli.pal", cliPalStart, cliPalEnd-cliPalStart

