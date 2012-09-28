; WildCommander API Header
;---------------------------------------
MNGC_PL		equ	#00		; включение страницы на #C000 (из выделенного блока)
						; нумерация совпадает с использующейся в +36
						; i:A' - номер страницы (от 0)
						;   #FF - страница с фонтом (1го текстового экрана)
						;   #FE - первый текстовый экран (в нём панели)

PRWOW		equ	#01		; вывод окна на экран
						; i:IX - адрес по которому лежит структура окна (SOW)

RRESB		equ	#02		; cтирание окна (восстановление информации)
						; i:IX - SOW

PRSRW		equ	#03		; печать строки в окне
						; i:IX - SOW
						;   HL - Text addres (должен быть в #8000-#BFFF!)
						;   D - Y
						;   E - X
						;   BC - Lenght

PRIAT		equ	#04		; выставление цвета (вызывается сразу после PRSRW)
						; i:PRSRW - выставленные координаты и длина
						;   A' - цвет

GADRW		equ	#05		; получение адреса в окне
						; i:IX - SOW
						;   D - Y
						;   E - X
						; o:HL - Address

CURSOR		equ	#06		; печать курсора
						; i:IX - SOW

CURSER		equ	#07		; стирание курсора (восстановление цвета)
						; i:IX - SOW

YN			equ	#08		; меню ok/cancel
						; i:A'
						;   #01 - инициализация (вычисляет координаты)
						;   #00 - обработка нажатий (вызывать раз в фрейм)
						;   #FF - выход
						; o:NZ - выбран CANCEL
						;   Z - выбран OK

ISTR		equ	#09		; редактирование строки
						; i:A'
						;   #FF - инициализация (рисует курсор)
						; i:HL - адрес строки
						;   DE - CURMAX+CURNOW (длина строки + начальная позиция курсора в ней)
						;   #00 - опрос клавиатуры
						;         >опрашивает LF,RG,BackSpace
						;         >собственно редактируется строка
						;         >нужно вызывать каждый фрейм
						;   #01 - выход (стирает курсор)

NORK		equ	#0a		; перевод байта в HEX (текстовый формат)
						; i:HL - Text Address
						;   A - Value

TURBOPL		equ	#0e		; i:B - выбор Z80/AY
						;   #00 - меняется частота Z80
						; i:C - %00 - 3.5 MHz
						;   %01 - 7 MHz
						;   %10 - 14 MHz
						;   %11 - 28 MHz (в данный момент 14MHz)
						;   #01 - меняется частота AY
						; i:C - %00 - 1.75 MHz
						;   %01 - 1.7733 MHz
						;   %10 - 3.5 MHz
						;   %11 - 3.546 MHz

GEDPL		equ	#0f		; восстановление паллитры, всех оффсетов и txt режима
						; ! обязательно вызывать при запуске плагина!
						; (включает основной txt экран)
						; i:none


; работа с файлами:
;---------------------------------------
LOAD512		equ	#30		; потоковая загрузка файла
						; i:HL - Address
						;   B - Blocks (512b)
						; o:HL - New Value

SAVE512		equ	#31		; потоковая запись файла
						; i:HL - Address
						;   B - Blocks (512b)
						; o:HL - New Value

GIPAGPL		equ	#32		; позиционировать на начало файла
						; (сразу после запуска плагина — уже вызвана)

TENTRY		equ	#33		; получить ENTRY(32) из коммандера
						; (структура как в каталоге FAT32)
						; i:DE - Address
						; o:DE(32) - ENTRY

CHTOSEP		equ	#34		; разложение цепочки активного файла в сектора
						; i:DE - BUFFER (куда кидать номера секторов)
						;   BC - BUFFER END (=BUFFER+BUFFERlenght)

TENTRYN		equ	#35		; reserved ???

TMRKDFL		equ	#36		; получить заголовок маркированного файла
						; i:HL - File number (1-2047)
						;   DE - Address (32byte buffer) [#8000-#BFFF!]
						;   (if HL=0; o:BC - count of marked files)
						; o:NZ - File not found or other error
						;   Z - Buffer updated
						;   >так же делается позиционированиена на начало этого файла!!!
						;   >соотв. функции LOAD512/SAVE512 будут читать/писать этот файл от начала.

TMRKNXT		equ	#37		; reserved ???

;			equ	#38		; reserved ???

STREAM		equ	#39		; работа с потоками
						; i:D - номер потока (0/1)
						;   B - устройство: 0-SD(ZC)
						;					1-Nemo IDE Master
						;					2-Nemo IDE Slave
						;   C - раздел (не учитывается)
						;   BC=#FFFF: включает поток из D (не возвращает флагов)
						;	          иначе создает/пересоздает поток.
						; o:NZ - устройство или раздел не найдены
						;   Z - можно начинать работать с потоком

MKFILE		equ	#3a		; создание файла в активном каталоге
						; i:DE(12) - name(8)+ext(3)+flag(1)
						;   HL(4) - File Size
						; o:NZ - Operation failed
						;   A - type of error (in next versions!)
						;   Z - File created
						;   ENTRY(32) [use TENTRY]

FENTRY		equ	#3b		; поиск файла/каталога в активной директории
						; i:HL - flag(1),name(1-12),#00
						; 		 flag:#00 - file
						;		      #10 - dir
						;		 name:"NAME.TXT","DIR"...
						; o: Z - entry not found
						;    NZ - CALL GFILE/GDIR for activating file/dir

LOAD256		equ	#3c		; reserved ???
LOADNONE	equ	#3d		; reserved ???

GFILE		equ	#3e		; выставить указатель на начало найденного файла
						; (вызывается после FENTRY!)

GDIR		equ	#3f		; сделать найденный каталог активным
						; (вызывается после FENTRY!)

; работа с режимами графики
;---------------------------------------
MNGV_PL		equ	#40		; включение видео страницы
						; i:A' - номер видео страницы
						;   #00 - основной экран (тхт)
						;   >паллитра выставляется автоматом
						;   >как и все режимы и смещения
						;   #01 - 1й видео буфер (16 страниц)
						;   #02 - 2й видео буфер (16 страниц)

MNGCVPL		equ	#41		; включение страницы из видео буферов
						; i:A' - номер страницы
						;   #00-#0F - страницы из 1го видео буфера
						;   #10-#1F - страницы из 2го видео буфера

GVmod		equ	#42		; включение видео режима (разрешение+тип)
						; i:A' - видео режим
						;   [7-6]: %00 - 256x192
						;          %01 - 320x200
						;          %10 - 320x240
						;          %11 - 360x288
						;   [5-2]: %0000
						;   [1-0]: %00 - ZX
						;          %01 - 16c
						;          %10 - 256c
						;          %11 - txt

GYoff		equ	#43		; выставление смещения экрана по Y
						; i:HL - Y (0-511)

GXoff		equ	#44		; выставление смещения экрана по X
						; i:HL - X (0-511)

; некоторые коды клавиатуры
;---------------------------------------
SPKE		equ	#10		; (SPACE)
UPPP		equ	#11		; (UP Arrow)
DWWW		equ	#12		; (Down Arrow)
LFFF		equ	#13		; (Left Arrow)
RGGG		equ	#14		; (Right Arrow)
TABK		equ	#15		; (Tab)
ENKE		equ	#16		; (Enter)
ESC			equ	#17		;
BSPC		equ	#18		; (Backspace)
PGU			equ	#19		; (pgUP)
PGD			equ	#1A		; (pgDN)
HOME		equ	#1B		;
END			equ	#1C		;
F1			equ	#1D		;
F2			equ	#1E		;
F3			equ	#1F		;
F4			equ	#20		;
F5			equ	#21		;
F6			equ	#22		;
F7			equ	#23		;
F8			equ	#24		;
F9			equ	#25		;
F10			equ	#26		;
ALT			equ	#27		;
SHIFT		equ	#28		;
CTRL		equ	#29		;
KBSCN		equ	#2A		; опрос клавишь
  						; i:A' - обработчик
						; 	#00 - учитывает SHIFT (TAI1/TAI2)
						; 	#01 - всегда выдает код из TAI1
						; o: NZ: A - TAI1/TAI2 (see PS2P.ASM)
						; 	  Z: A=#00 - unknown key
						; 	     A=#FF - buffer end
;			equ	#2b
;			equ	#2c
ANYK		equ	#2d		; any key
USPO		equ	#2e		; pause for keyboard ready (recomended for NUSP)
NUSP		equ	#2f		; waiting for any key
