;---------------------------------------
; Kempstone Mouse driver Header
;---------------------------------------
mouseInit	jp	_mouseInit		; Инициализация драйвера мыши
						; i: hl - ширина, de - высота рабочей области
						;    256x192, 320x240, 360x288 итд 

mouseUpdate	jp	_mouseUpdate		; Обновление данных из портов мыши (вызывается 1 раз за прервывание)

getMouseX	jp	_getMouseX		; Получить координаты X мыши
						; o: HL - координата X (16bit)

getMouseY	jp	_getMouseY		; Получить координаты Y мыши
						; o: HL - координата Y (16bit)

getMouseDeltaX	jp	_getMouseDeltaX		; Получить дельту смещения мыши по оси X
						; o: HL - дельта X (16bit)

getMouseDeltaY	jp	_getMouseDeltaY		; Получить дельту смещения мыши по оси Y
						; o: HL - дельта Y (16bit)

getMouseRawX	jp	_getMouseRawX		; Получить RAW данные с порта X
						; o: H=0, L - RAW X (8bit)

getMouseRawY	jp	_getMouseRawY		; Получить RAW данные с порта Y
						; o: H=0, L - RAW Y (8bit)

getMouseWheel	jp	_getMouseWheel		; Получить данные с порта колёсика
						; o: H=0, L - RAW Y (8bit) от 0 до 15

getMouseButtons	jp	_getMouseButtons	; Получить состояние кнопок мыши
 						; o: A - биты состояния:
 						;    bit0: левая кнопка (1=нажата)
 						;    bit1: правая кнопка (1=нажата)
 						;    bit2: средняя кнопка (1=нажата)
 						;    bit3: зарезервировано
