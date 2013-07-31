;---------------------------------------
; NeoGS (General Sound) Library Header
;---------------------------------------
cReset		equ	#80			; команда reset
cGetRAMPages	equ	#23			; Получить число страниц в GS. (В базовой версии 3 страницы)

pReset		equ	#33			; порт resrt
pDataOutReg 	equ	#b3			; порт регистра данных (Data->GS)
pDataInReg	equ	#b3			; порт регистра вывода (GS->Data)

pCmdReg		equ	#bb			; порт регистр команд для GS
pStatusReg	equ	#bb			; порт регистра состояния. Биты:
						;  7й — Data bit, флаг данных
						;  6,5,4,3,2,1й — Не используются
						;  0й — Command bit, флаг команд 

tReset		equ	32			; время ожидания инициализации карты после reset (1/48.888) секунды
						; 32/48.888 = ~0.654 секунды
;---------------------------------------
initGS		jp	_initGS			; Инициализация NeoGS (reset)
						; i: нет параметров
						; o: нет данных

detectGS	jp	_detectGS		; Проверка наличия карты (NeoGS)

uploadGsByte	jp	_uploadGsByte		; Загрузка 1 байта данных в NeoGS

sendGsCmd	jp	_sendGsCmd		; Отправить команду карте

sendWaitGsCmd	jp	_sendWaitGsCmd		; Отправить команду и дождаться ответа

		include	"neogs.asm"