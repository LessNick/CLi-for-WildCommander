        DEVICE ZXSPECTRUM128

;   +----------+-----------+----------+
;   |Результат | Состояние | Мнемоника|
;   |сравнения |  флагов   |  условия |
;   +----------+-----------+----------+
;   |   A=X    |   Z=1     |    Z     |
;   +----------+-----------+----------+
;   |  A<>X    |   Z=0     |    NZ    |
;   +----------+-----------+----------+
;   | Беззнаковое сравнение (0...255) |
;   +----------+-----------+----------+
;   |   A<X    |  CY=1     |    C     |
;   +----------+-----------+----------+
;   |  A>=X    |  CY=0     |    NC    |
;   +----------+-----------+----------+
;   | С учетом знака    (-128...+127) |
;   +----------+-----------+----------+
;   |   A<X    |   S=1     |    P     |
;   +----------+-----------+----------+
;   |  A>=X    |   S=0     |    M     |
;   +----------+-----------+----------+

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

cliTxtPages	equ		5					; size Buffer for cli print (5 pages)
cliTxtBegin	equ		#20					; start page

			include "wcKernel.h.asm"
			include "tsConf.h.asm"

			include "pluginHead.asm"
			include "cli.asm"

	;DISPLAY "scrollUp addr:",/A,scrollUp
	;DISPLAY "scrollDown addr:",/A,scrollDown
	;DISPLAY "checkNext addr:",/A,checkNext
	;DISPLAY "limitBottom addr:",/A,limitBottom
	;DISPLAY "test addr:",/A,test
	;DISPLAY "incBLimit0 addr:",/A,incBLimit0
	;DISPLAY "scrollPos addr:",/A,scrollPos

	SAVEBIN "bin/CLI.WMF", startCode, endCode-startCode
