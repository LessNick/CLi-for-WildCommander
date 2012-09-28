        DEVICE ZXSPECTRUM128

			org #6000
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
	;DISPLAY "listDir addr:",/A,listDir
	;DISPLAY "changeDir addr:",/A,changeDir
	;DISPLAY "cliInit addr:",/A,cliInit
	;DISPLAY "cdLoop addr:",/A,cdLoop

	SAVEBIN "bin/CLI.WMF", startCode, endCode-startCode
