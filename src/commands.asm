;---------------------------------------------
; Command's table below with all jump vectors
;---------------------------------------------
cmdTable
;--- A ---
	db	"about"
	db	"*"
	dw	showAbout
;--- B ---

;--- C ---
	db	"cd"
	db	"*"
	dw	changeDir

	db	"cls"
	db	"*"
	dw	clearScreen
;--- D ---
	db	"dir"
	db	"*"
	dw	listDir
;--- E ---
	db	"echo"
	db	"*"
	dw	echoString

	db	"exit"
	db	"*"
	dw	closeCli
;--- F ---

;--- G ---

;--- H ---
	db	"help"
	db	"*"
	dw	showHelp
;--- I ---

;--- J ---

;--- K ---

;--- L ---
	db	"ls"
	db	"*"
	dw	listDir
;--- M ---

;--- N ---

;--- O ---

;--- P ---
	db	"pwd"
	db	"*"
	dw	pathWorkDir
;--- Q ---

;--- R ---

;--- S ---
	db	"sh"
	db	"*"
	dw	shellExecute

	db	"sleep"
	db	"*"
	dw	sleepSeconds
;--- T ---

;--- U ---

;--- V ---

;--- W ---

;--- X ---

;--- Y ---

;--- Z ---

;--- table end marker ---
	db	#00
