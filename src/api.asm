; CLI (Command Line Interface) API

wcKernel		equ		#6006					; WildCommander API
deviceSDZC		equ		#00						; 0-SD(ZC)
deviceNemoM		equ		#01						; Nemo IDE Master
deviceNemoS		equ		#02						; Nemo IDE Slave
flagFile		equ		#00						; flag:#00 - file
flagDir			equ		#10						;      #10 - dir
;---------------------------------------
openStream		ld		d,#00					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
				ld		a,STREAM
				jp		wcKernel
;---------------------------------------
pathToRoot		ld		d,#ff					; окрываем поток с устройством (#00 = инициализация, #ff = сброс в root)
				ld		bc,#ffff				; устройство (#ffff = не создавать заново, использовать текущий поток)
				ld		a,STREAM
				jp		wcKernel
;---------------------------------------
checkKeyEnter	ld		a,ENKE
				jp		wcKernel
;---------------------------------------
checkKeyDel		ld		a,BSPC
				jp		wcKernel
;---------------------------------------
checkKeyUp		ld		a,UPPP
				jp		wcKernel
;---------------------------------------
checkKeyDown	ld		a,DWWW
				jp		wcKernel
;---------------------------------------
checkKeyLeft	ld		a,LFFF
				jp		wcKernel
;---------------------------------------
checkKeyRight	ld		a,RGGG
				jp		wcKernel
;---------------------------------------
waitAnyKey		ld		a,USPO
				call	wcKernel
				ld		a,NUSP					; wait 4 anykey
				jp		wcKernel
;---------------------------------------
getKeyWithShift	ld		a,#00					; #00 - учитывает SHIFT
				ex		af,af'
				ld		a,KBSCN
				jp		wcKernel
;---------------------------------------
setRamPage		ex		af,af'					; A' - номер страницы (от 0)
				ld		a,MNGC_PL				; #FE - первый текстовый экран (в нём панели)
				jp		wcKernel				; #FF - страница с фонтом (1го текстового экрана)
;---------------------------------------
setVideoPage	ex		af,af'					; #00-#0F - страницы из 1го видео буфера
				ld		a,MNGCVPL				; #10-#1F - страницы из 2го видео буфера
				jp		wcKernel
;---------------------------------------
setTxtMode		ex		af,af'					; #01 - 1й видео буфер (16 страниц)
				ld		a,MNGV_PL				; #02 - 2й видео буфер (16 страниц)
				jp		wcKernel
;---------------------------------------
setVideoMode	ex		af,af'
				ld		a,GVmod
				jp		wcKernel
;---------------------------------------
restoreWC		ld		a,#00					; Восстановление видеорежима для WC (#00 - основной экран (тхт))
				ex		af,af'
				ld		a,MNGV_PL
				jp		wcKernel
;---------------------------------------
searchEntry		ld		a,FENTRY
				jp		wcKernel
;---------------------------------------
setFileBegin	ld		a,GFILE
				jp		wcKernel
;---------------------------------------
setDirBegin		ld		a,GDIR
				jp		wcKernel
;---------------------------------------
load512bytes	ld		a,LOAD512
				jp		wcKernel
;---------------------------------------