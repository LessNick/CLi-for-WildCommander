;---------------------------------------
; GLi - Graphics Library interface
;---------------------------------------
createSprite	push	af			
		call	setSpriteSize		; ширина / 8 px , высота /8 px

		ld	a,h			; l = (#01+1) * ~20 = 40ms на 1 кадр, h - #08 кадров анимации
		ld	(sprAnim),a
		xor	a
		ld	(sprAnimPos),a
		ld	a,l
		ld	(sprWait),a
		ld	(sprTimeout),a

		call	updateSprite		
		pop	af
		call	setYBitMap
		ret

updateSprite	ld	a,(sprTimeout)
		dec	a
		cp	#00
		jr	nz,updSprite_02
		
		ld	a,(sprAnim)
		ld	c,a
		ld	a,(sprAnimPos)
		inc	a
		cp	c
		jr	nz,updSprite_00
		
		xor	a
updSprite_00	ld	(sprAnimPos),a
		
		ld	b,a
		ld	a,(sprX1)
		and	%00001110
		srl	a
		inc	a
		ld	c,a
updSprite_01	add	a,c
		djnz	updSprite_01
		and	%00011111
		ld	c,a
		ld	a,(sprPX)
		and	%11100000
		or	c
		ld	(sprPX),a

		ld	a,(sprWait)
updSprite_02	ld	(sprTimeout),a

		ld	bc,FMAddr
		ld 	a,%00010000		; Разрешить приём данных (?) Bit 4 - FM_EN установлен
		out	(c),a

		ld	hl,sFile
		ld 	de,#0000+512		; Память с палитрой замапливается на адрес #0000
		ld	bc,6
		ldir

		ld	bc,FMAddr
		xor	a			; Запретить, Bit 4 - FM_EN сброшен
		out	(c),a
		ret

enableSprites	ld	a,#01
		ld	(showSprEnable),a
		jr	showSprites

disableSprites	xor	a
		ld	(showSprEnable),a
			; S_EN	T1_EN	T0_EN	Z80_LP	T1Z_EN	T0Z_EN	T1YS_EN	T0YS_EN
hideSprites	ld	a,%00000000		; запрещаем отображение спрайтов
		jr	setTSConfig

showSprites	ld	a,(showSprEnable)
		cp	#00
		ret	z
		ld	a,%10000000		; разрешаем отображение спрайтов
setTSConfig	ld	bc,TSConfig
		out	(c),a
		ret

setYBitMap	push	af
		and	%00000011
		sla	a
		sla	a
		sla	a
		sla	a
		sla	a
		sla	a
		ld	c,a
		ld	a,(sprPY0)
		and	%00111111
		or	c
		ld	(sprPY0),a
		pop	af
		srl	a
		srl	a
		and	%00001111
		ld	c,a
		ld	a,(sprPY1)
		and	%11110000
		or	c
		ld	(sprPY1),a
		ret

setSpriteSize	ld	a,e			; ширина ?
		dec	a
		and	%00000111
		sla	a
		ld	e,a
		ld	a,(sprX1)
		and	%11110001
		or	e
		ld	(sprX1),a

		ld	a,d			; высота ?
		dec	a
		and	%00000111
		sla	a
		ld	d,a
		ld	a,(sprY1)
		and	%11110001
		or	d
		ld	(sprY1),a
		ret

setSpriteX	ld	a,e			; координата X
		ld	(sprX0),a

		ld	a,d
		and	%00000001
		ld	d,a
		ld	a,(sprX1)
		and	%11111110
		or	d
		ld	(sprX1),a
		ret

setSpriteY	ld	a,e			; координата Y
		ld	(sprY0),a

		ld	a,d
		and	%00000001
		ld	d,a
		ld	a,(sprY1)
		and	%11111110
		or	d
		ld	(sprY1),a
		ret

showSprEnable	db	#00

sprType		db	"   ",#00

sprAnim		db	#00			; количество кадров анимации
sprAnimPos	db	#00			; текущий кадр 
sprWait		db	#00			; сколько отображать 1 кадр * ~20ms
sprTimeout	db	#00			; сколько осталось до смены кадра

sFile		;	структура SFILE
sprY0		db	#00			; Y0-7     | 8 bit младшие даные Y координаты (0-255px)
			;FLAR S Y8
sprY1		db	%00100110		; Y8       | 0й бит - старшие данные Y координаты (256px >)
						; YS       | 1,2,3 бит - высота в блоках по 8 px
						; RESERVED | 4й бит - зарезервирован
						; ACT      | 5й бит - спрайт активен (показывается)
						; LEAP     | 6й бит - указывает, что данный спрайт последний в текущем слое.
						; YF       | 7й бит - указывает, что данный спрайт нужно отобразить зеркально по вертикали
		
sprX0		db	#00			; X0-7     | 8 bit младшие даные X координаты (0-255px)
			;F  R S X8
sprX1		db	%00000110		; X8       | 0й бит - старшие данные X координаты (256px >)
						; XS       | 1,2,3 бит - ширина в блоках по 8 px
						; RESERVED | 4й бит - зарезервирован
						; -        | 5,6й бит - не используются
						; XF       | 7й бит - указывает, что данный спрайт нужно отобразить зеркально по горизонтали
sprPX			;TNUM
sprPY0		db	%00000000		; TNUM	   | Номер тайла для левого верхнего угла.
						;          | 0,1,2,3,4,5й бит - Х координата в битмап
			;SPALTNUM		;          | 6,7й бит +
sprPY1		db	%11110000		; TNUM     | 0,1,2,3 бит - Y координата в битмап
						; SPAL     | 4,5,6,7й биты номер палитры (?)