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

scopeBinAddr	equ	#c000				; /bin list address start
scopeBinBank	equ	#03				; /bin application list

palAddr		equ	#fc00				; palette file load address
palBank		equ	#03				; palette file load memory bank

gPalAddr	equ	#fe00				; graphics palette file load address
gPalBank	equ	#03				; graphics palette file load memory bank

appAddr		equ	#c000				; application load address
appBank		equ	#04				; application load memory bank

tmpAddr		equ	#c000				; temp buffer load address
tmpBank		equ	#07				; temp buffer load bank

sprAddr		equ	#c000				; sprites load address
sprBank		equ	#08				; sprites load memory bank

		include "wcKernel.h.asm"
		include "tsConf.h.asm"

		include "pluginHead.asm"
		include "cli.asm"

		;include "zx.pal.asm"
		;include "cli.pal.asm"
		;include "boing.pal.asm"

		;include "test1.asm"
		;include "test2.asm"
		;include "test3.asm"
		;include "test4.asm"

		;include "helloworld.asm"
		;include "boing.asm"
		include "type.asm"
		;include "loadMod.asm"
		;include "miceTest.asm"


	;DISPLAY "code size:",/A,endCode-startCode
	;DISPLAY "waitResponse addr:",/A,waitResponse
	;DISPLAY "ttt addr:",/A,ttt
	;DISPLAY "executeApp addr:",/A,executeApp
	;DISPLAY "checkIsBin addr:",/A,checkIsBin
	;DISPLAY "pathString addr:",/A,pathString
	;DISPLAY "checkCallLoop addr:",/A,checkCallLoop

	SAVEBIN "bin/wc/CLI.WMF", startCode, endCode-startCode

	;SAVEBIN "bin/system/pal/zx.pal", zxPalStart, zxPalEnd-zxPalStart
	;SAVEBIN "bin/system/pal/cli.pal", cliPalStart, cliPalEnd-cliPalStart
	;SAVEBIN "bin/demo/boing/boing.pal", boingPalStart, boingPalEnd-boingPalStart

	;SAVEBIN "bin/bin/test1", test1Start, test1End-test1Start
	;SAVEBIN "bin/bin/test2", test2Start, test2End-test2Start
	;SAVEBIN "bin/bin/test3", t3Start, t3End-t3Start
	;SAVEBIN "bin/bin/test4", t4Start, t4End-t4Start
	
	;SAVEBIN "bin/bin/hello", appStart, appEnd-appStart
	;SAVEBIN "bin/demo/boing/boing", BoingStart, BoingEnd-BoingStart
	SAVEBIN "bin/bin/type", typeStart, typeEnd-typeStart
	;SAVEBIN "bin/bin/loadMod", loadModStart, loadModEnd-loadModStart
	;SAVEBIN "bin/bin/miceTest", miceTestStart, miceTestEnd-miceTestStart
