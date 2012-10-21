;---------------------------------------
; CLi (Command Line Interface) API Header
;---------------------------------------
resPal		equ	#01		; ресурс палитра
resSpr		equ	#02		; ресурс спрайт
;---------------------------------------
shellStart	jp	_shellStart
openStream	jp	_openStream
pathToRoot	jp	_pathToRoot
checkKeyEnter	jp	_checkKeyEnter
checkKeyDel	jp	_checkKeyDel
checkKeyUp	jp	_checkKeyUp
checkKeyDown	jp	_checkKeyDown
checkKeyLeft	jp	_checkKeyLeft
checkKeyRight	jp	_checkKeyRight
checkKeyAlt	jp	_checkKeyAlt
checkKeyEsc	jp	_checkKeyEsc
checkKeyF1	jp	_checkKeyF1
checkKeyF2	jp	_checkKeyF2
waitKeyCalm	jp	_waitKeyCalm
waitAnyKey	jp	_waitAnyKey
getKey		jp	_getKey
getKeyWithShift jp	_getKeyWithShift
setRamPage	jp	_setRamPage
setVideoPage	jp	_setVideoPage
setTxtMode	jp	_setTxtMode
setVideoMode	jp	_setVideoMode
restoreWC	jp	_restoreWC
searchEntry	jp	_searchEntry
setFileBegin	jp	_setFileBegin
setDirBegin	jp	_setDirBegin
load512bytes	jp	_load512bytes
setHOffset	jp	_setHOffset
setVOffset	jp	_setVOffset
callDma		jp	_callDma
getFatEntry	jp	_getFatEntry
checkSync	jp	_checkSync
printString	jp	_printString
setScreen	jp	_setScreen
clearGfxScreen	jp	_clearGfxScreen
loadResource	jp	_loadResource
;---------------------------------------