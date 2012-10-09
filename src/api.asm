;---------------------------------------
; CLI (Command Line Interface) API
;---------------------------------------

wcKernel		equ		#6006					; WildCommander API
deviceSDZC		equ		#00						; 0-SD(ZC)
deviceNemoM		equ		#01						; Nemo IDE Master
deviceNemoS		equ		#02						; Nemo IDE Slave
flagFile		equ		#00						; flag:#00 - file
flagDir			equ		#10						;      #10 - dir
;---------------------------------------
openStream		ld		d,#00					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
				ld		a,_STREAM
				jp		wcKernel
;---------------------------------------
pathToRoot		ld		d,#ff					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
				ld		bc,#ffff				; устройство (#ffff = не создавать заново, использовать текущий поток)
				ld		a,_STREAM
				jp		wcKernel
;---------------------------------------
checkKeyEnter	ld		a,_ENKE
				jp		wcKernel
;---------------------------------------
checkKeyDel		ld		a,_BSPC
				jp		wcKernel
;---------------------------------------
checkKeyUp		ld		a,_UPPP
				jp		wcKernel
;---------------------------------------
checkKeyDown	ld		a,_DWWW
				jp		wcKernel
;---------------------------------------
checkKeyLeft	ld		a,_LFFF
				jp		wcKernel
;---------------------------------------
checkKeyRight	ld		a,_RGGG
				jp		wcKernel
;---------------------------------------
checkKeyAlt		ld		a,_ALT
				jp		wcKernel
;---------------------------------------
waitKeyCalm		ld		a,_USPO
				jp		wcKernel

waitAnyKey		call	waitKeyCalm
				ld		a,_NUSP					; wait 4 anykey
				jp		wcKernel
;---------------------------------------
getKey			ld		a,#01					; #01 - всегда выдает код из TAI1
				ex		af,af'
				ld		a,_KBSCN
				jp		wcKernel
;---------------------------------------
getKeyWithShift	ld		a,#00					; #00 - учитывает SHIFT
				ex		af,af'
				ld		a,_KBSCN
				jp		wcKernel
;---------------------------------------
setRamPage		ex		af,af'					; A' - номер страницы (от 0)
				ld		a,_MNGC_PL				; #FE - первый текстовый экран (в нём панели)
				jp		wcKernel				; #FF - страница с фонтом (1го текстового экрана)
;---------------------------------------
setVideoPage	ex		af,af'					; #00-#0F - страницы из 1го видео буфера
				ld		a,_MNGCVPL				; #10-#1F - страницы из 2го видео буфера
				jp		wcKernel
;---------------------------------------
setTxtMode		ex		af,af'					; #01 - 1й видео буфер (16 страниц)
				ld		a,_MNGV_PL				; #02 - 2й видео буфер (16 страниц)
				jp		wcKernel
;---------------------------------------
setVideoMode	ex		af,af'
				ld		a,_GVmod
				jp		wcKernel
;---------------------------------------
restoreWC		ld		a,#00					; Восстановление видеорежима для WC (#00 - основной экран (тхт))
				ex		af,af'
				ld		a,_MNGV_PL
				jp		wcKernel
;---------------------------------------
searchEntry		ld		a,_FENTRY
				jp		wcKernel
;---------------------------------------
setFileBegin	ld		a,_GFILE
				jp		wcKernel
;---------------------------------------
setDirBegin		ld		a,_GDIR
				jp		wcKernel
;---------------------------------------
load512bytes	ld		a,_LOAD512
				jp		wcKernel
;---------------------------------------
setHOffset		ld		a,_GXoff
				jp		wcKernel
;---------------------------------------
setVOffset		ld		a,_GYoff
				jp		wcKernel
;---------------------------------------
DMAPL											; Для совместимости с сорцами Budder/MGN
callDma			ex		af,af'
				ld		a,_DMAPL
				jp		wcKernel
;---------------------------------------
checkSync		ld		hl,(_TMN)
				ld		a,h
				or		l
				ret		z						; Z - ещё не было обновлений - выход
				ld		hl,#0000
				ld		(_TMN),hl
				ld		a,1						; NZ - обновление было
				or		a
				ret
;---------------------------------------
