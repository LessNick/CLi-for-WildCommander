;--------------------------------------------------------------
; int2str перевод int в текст (десятичное число)
; (C) BUDDER/MGN/TOGYAF - 2011.12.26
;---------------------------------------
;ВЫВОД 16bit ЧИСЛА:
int2str
;i:[HL] - int16
;  EXX DE - String addres
;  o:Decimal string(5)
DECZON2 LD BC,10000
        CALL DELIT
        LD (DE),A:INC DE
DECZ2   LD BC,1000
        CALL DELIT
        LD (DE),A:INC DE
DECZ1   LD BC,100
        CALL DELIT
        LD (DE),A:INC DE
DECZ    LD C,10
        CALL DELIT
        LD (DE),A:INC DE
        LD C,1
        CALL DELIT
        LD (DE),A:INC DE
        RET
;---------------------------------------
DELIT   LD A,#FF
        OR A
DLIT    INC A
        SBC HL,BC:JP NC,DLIT
        ADD HL,BC,A,#30
        RET

word2str
;ВЫВОД 32bit ЧИСЛА:
DECZON4 ;i:[DE,HL] - int32
;           EXX DE - String addres
;        o:Decimal string(10)

	LD BC,#CA00,(CLHL),BC;        1B
	LD BC,#3B9A,(CLDE),BC
	CALL DELIT4T
	EXX:LD (DE),A:INC DE:EXX

	LD BC,#E100,(CLHL),BC;      100M
	LD BC,#05F5,(CLDE),BC
	CALL DELIT4T
	EXX:LD (DE),A:INC DE:EXX

	LD BC,#9680,(CLHL),BC;       10M
	LD BC,#0098,(CLDE),BC
	CALL DELIT4T
	EXX:LD (DE),A:INC DE:EXX

	LD BC,#4240,(CLHL),BC;        1M
	LD BC,#000F,(CLDE),BC
	CALL DELIT4T
	EXX:LD (DE),A:INC DE:EXX

	LD BC,#86A0,(CLHL),BC;      100K
	LD BC,#0001,(CLDE),BC
	CALL DELIT4T
	EXX:LD (DE),A:INC DE:EXX

;---------------------------------------
DELIT4T ;i:[DE,HL]/[CLDE,CLHL]
;        o:[DE,HL] - Remainder
;               BC - Count

        LD IX,0-1
NAZE    OR A
DLTB    LD BC,0
        INC IX
        EX DE,HL:SBC HL,BC:JR C,ND
DLTA    LD BC,0
        EX DE,HL:SBC HL,BC:JR NC,DLTB
        DEC DE
        LD A,D:INC A:JR NZ,NAZE
        LD A,E:INC A:JR NZ,NAZE
        INC DE

        ADD HL,BC
        EX DE,HL
        LD BC,(CLDE)
;-------
ND      ADD HL,BC
        EX DE,HL

Nd      PUSH IX
        POP BC
        LD A,C:ADD A,#30
        RET
;---------------------------------------
CLHL    EQU DLTA+1
CLDE    EQU DLTB+1
;---------------------------------------
