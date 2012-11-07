;---------------------------------------------
; Command's table below with all jump vectors
;---------------------------------------------
cmdTable
;--- A ---

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

	db	"exec"
	db	"*"
	dw	executeApp

	db	"exit"
	db	"*"
	dw	closeCli
;--- F ---

;--- G ---
	db	"gfxborder"
	db	"*"
	dw	gfxBorder

	db	"gfxcls"
	db	"*"
	dw	gfxCls

	db	"gfxloadpal"
	db	"*"
	dw	loadGfxPal

;--- H ---
	db	"help"
	db	"*"
	dw	showHelp
;--- I ---

;--- J ---

;--- K ---

;--- L ---
	db	"loadfnt"
	db	"*"
	dw	loadTxtFnt

	db	"loadpal"
	db	"*"
	dw	loadTxtPal

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
	db	"rehash"
	db	"*"
	dw	scopeBinary
;--- S ---
	db	"screen"
	db	"*"
	dw	switchScreen

	db	"sh"
	db	"*"
	dw	shellExecute

	db	"sleep"
	db	"*"
	dw	sleepSeconds
;--- T ---
;	db	"test"
;	db	"*"
;	dw	testCmd
;--- U ---

;--- V ---

;--- W ---

;--- X ---

;--- Y ---

;--- Z ---

;--- table end marker ---
	db	#00
