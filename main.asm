;***********************************************************
;
;		YMZ294 Handler Program
;
;		RA0	Output	WR/CS	Low = Write Enable
;		RA1	Output	A0	Low = Address mode, High = Data mode
;		RA2	Output	IC	Low = Reset
;	   (RA3 Output	SCL
;		RA4	Output	SDA)
;
;		RB0	Output	D0	Data Bus
;		RB1	Output	D1
;		RB2	Output	D2
;		RB3	Output	D3
;		RB4	Output	D4
;		RB5	Output	D5
;		RB6	Output	D6
;		RB7	Output	D7
;
;�@		CLK	4MHz ORC
;
;***********************************************************
;YMZ init code by hijiri~
;http://hijiri3.s65.xrea.com/sorekore/develop/pic/PIC04_YMZ.htm

	LIST	P=PIC16F84A
	INCLUDE "P16F84A.INC"
	__CONFIG _HS_OSC & _PWRTE_ON & _WDT_OFF & _CP_OFF

#define BANK0	bcf	STATUS,RP0
#define BANK1	bsf	STATUS,RP0

;******************************
;  �ϐ����W�X�^���t��`
;******************************


cnt1		equ	0Dh		;�^�C�}�p�J�E���^
cnt2		equ	0Eh
cnt3		equ	0Fh
cnt4		equ	10h

adr		equ	12h
dat		equ	13h


;���W�X�^
ROM_CHIP	EQU	15h		;�f�o�C�X�A�h���X�̎w��Ŏg��
ROM_ADD_H	EQU	16h		;�A�h���X���1�o�C�g�̎w��Ɏg��
ROM_ADD_L	EQU	17h		;�A�h���X����1�o�C�g�̎w��Ɏg��
BUFFER		EQU	18h		;�e���ԃr�b�g���i�[
DATA_IN		EQU	19h		;EEPROM��M�f�[�^
DATA_OUT	EQU	1Ah		;EEPROM�ɑ��M����f�[�^
BITCOUNT	EQU	1Bh		;�N���b�N���̃��W�X�^�u8�v
AY_ADDRL	EQU 1Ch		;AY �A�h���X�ϐ�0-7
AY_ADDRH	EQU 1Dh		;AY �A�h���X�ϐ�8-15
AY_STATUS	EQU	1Eh		;AY �X�e�[�^�X�ϐ�, 00000000=x,x,x,LASTREAD,WAITCHK,ADDRH,ADDRL,WAITFE
AY_V		EQU 1Fh		;�ǂݍ��ݐ��J�E���^ (SNG10�p)
AY_IF		EQU 20h		;����ϐ�
AY_COUNT	EQU 21h		;���[�v�J�E���^
;DBG_CNT		EQU	22h	;�f�o�b�O�p�J�E���^


; �x���^�C�}�[�p
T0 EQU 13H
T1 EQU 14H
T2 EQU 15H
T3 EQU 16H

; �萔
SCL     EQU  3  ; SCL�[�q�Ƃ���[�q�ԍ�
SDA     EQU  4  ; SDA�[�q�Ƃ���[�q�ԍ�
DO      EQU  0
DI      EQU  1
ACK_BIT EQU  2  ; ACK�M���̗L��

;*** ���Z�b�g�x�N�^ ***
		org	0
		goto	START


;********************************
; ���C���v���O����
;********************************
;*** ������ ****
		org	8

START
		;call	TIME1M
		call	PIC_INI		;PIC initialize
		clrf	PORTB		;all clear
		clrf	PORTA		;all clear

;**** ���C�����[�v *****
MAIN
		call	TIME5M
		call	MIX
		call	TIME150M

		CALL CHA_O5E
		CALL CHA_NON
		CALL TIME1S
		CALL CHA_O5E
		CALL TIME1S
		CALL CHA_NOFF

		clrf	AY_ADDRL
		clrf	AY_ADDRH
		clrf	AY_STATUS
		clrf	AY_COUNT
		clrf	AY_V
		;clrf	DBG_CNT

		BCF		AY_V, 0
		MOVLW  h'0000'
		MOVWF  ROM_CHIP    ;�f�o�C�X�A�h���X���w��
		MOVLW  h'0000'
		MOVWF  ROM_ADD_H   ;�A�h���X���1�o�C�g���w��
		MOVLW  h'0000'
		MOVWF  ROM_ADD_L   ;�A�h���X����1�o�C�g���w��
		CALL   ROM_READ    ;ROM�ǂݏo�����[�`����
LOOP1
		call	TIME1S
		goto	LOOP1



;************************************
;  PIC�������T�u���[�`��
;************************************
PIC_INI
;PortSet
		BANK1			;Set page 1
		movlw	00H		;all RB output
		movwf	TRISB		;PortB set
		movlw	00H		;all RA output
		movwf	TRISA		;PortA set
		BANK0			;Set Page 0
		return

;************************************
;  ���ʐݒ�Ɖ���
;************************************
MIX
		movlw		07h		;Address
		movwf		adr
		movlw		38h		;Data
		movwf		dat
		call		WREG
		return

CHA_NOFF
		movlw		08h		;Address		(Ach Volume Setting)
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		return

CHA_NON
		movlw		08h		;Address		(Ach Volume Setting)
		movwf		adr
		movlw		B'00001111'	;Data
		movwf		dat
		call		WREG
		return

CHA_O5C
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000001'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'00011100'	;Data
		movwf		dat
		call		WREG
		return

CHA_O5D
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'11111101'	;Data
		movwf		dat
		call		WREG
		return

CHA_O5E
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'11100010'	;Data
		movwf		dat
		call		WREG
		return

CHA_O5G
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'10111101'	;Data
		movwf		dat
		call		WREG
		return

CHA_O5A
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'10101001'	;Data
		movwf		dat
		call		WREG
		return

CHA_O6C
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'10001110'	;Data
		movwf		dat
		call		WREG
		return

CHA_O6E
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'01110000'	;Data
		movwf		dat
		call		WREG
		return

CHA_O6G
		movlw		01h		;Address
		movwf		adr
		movlw		B'00000000'	;Data
		movwf		dat
		call		WREG
		movlw		00h		;Address
		movwf		adr
		movlw		B'01011110'	;Data
		movwf		dat
		call		WREG
		return



;************************************
;  YMZ294�̃��W�X�^�փf�[�^��������
;************************************
;a0 low=addr high=value
;wrcs low=disabled high=enabled
;                       rst a0 wr/cs
WREG
		;movlw		B'00000100'
		BSF			PORTA, 2
		BCF			PORTA, 1
		BCF			PORTA, 0
		;movwf		PORTA
		movf		adr,W
		movwf		PORTB; write addr
		;movlw		B'00000101'
		BSF			PORTA, 2
		BCF			PORTA, 1
		BSF			PORTA, 0
		;movwf		PORTA 
		;movlw		B'00000110'
		;movwf		PORTA
		BSF			PORTA, 2
		BSF			PORTA, 1
		BCF			PORTA, 0
		movf		dat,W
		movwf		PORTB; write value
		;movlw		B'00000111'
		;movwf		PORTA
		BSF			PORTA, 2
		BSF			PORTA, 1
		BSF			PORTA, 0
		return

;---------------EEPROM�֘A���[�`��--------------
;I2C EEROM Read routine
;http://nagoyacoder.web.fc2.com/pic/pic_i2c.html
;Supports up to 512kbit(64KB) EEPROM
; I2CEEPROM �ǂݏo��
ROM_READ
  CALL   SDA_IN      ;SDA�[�q����̓��[�h�ɂ���

  CALL   START_CON   ;�X�^�[�g�V�[�P���X��
  CALL   ROM_TIM

  MOVLW  h'00A0'     ;�R���g���[���r�b�g+�������݃r�b�g
  IORWF  ROM_CHIP,W  ;��L�Ƀf�o�C�X�A�h���X��������
  MOVWF  DATA_OUT    ;DATA_OUT���W�X�^�Ɉړ�
  CALL   BYTE_OUT    ;�R���g���[���V�[�P���X�i1�o�C�g�j�̑��o
  CALL   ROM_TIM

  MOVF   ROM_ADD_H,W
  MOVWF  DATA_OUT    ;�A�h���X��ʂ�DATA_OUT���W�X�^�Ɉړ�
  CALL   BYTE_OUT    ;�A�h���X��ʑ��M
  CALL   ROM_TIM

  MOVF   ROM_ADD_L,W
  MOVWF  DATA_OUT    ;�A�h���X���ʂ�DATA_OUT���W�X�^�Ɉړ�
  CALL   BYTE_OUT    ;�A�h���X���ʑ��M
  CALL   ROM_TIM

  CALL   START_CON   ;�X�^�[�g�V�[�P���X��
  CALL   ROM_TIM

  MOVLW  h'00A1'     ;�R���g���[���r�b�g+�ǂݍ��݃r�b�g
  IORWF  ROM_CHIP,W  ;��L�Ƀf�o�C�X�A�h���X��������
  MOVWF  DATA_OUT    ;DATA_OUT���W�X�^�Ɉړ�
  CALL   BYTE_OUT    ;�R���g���[���V�[�P���X�i1�o�C�g�j�̑��o
  CALL   ROM_TIM

SEQ_READ
	;RSF Playback Routine
	;Register Stream Flow has 2 bytes of address and value follows
	;0x00 0x01 0x02 0x03 ...
	;adrh adrl val1 val2 ... valx valy
	;
	;          76543210
	;          --------
	;if adrl = 00010001, write val1 in 0x00 and val2 in 0x04
	;if adrh = 00001100, write valx in 0x0a and valy in 0x0b
	;
	;Please delete header before write the rsf file!
	BTFSS	AY_STATUS, 4 ;if lastread = 0
	CALL	SEQ_READ_INT
	BCF		AY_STATUS, 4 ; lastread = 0

	; Debug routine
	; 0x00 = loop number, PORTB = DATA_IN
	;MOVLW	0x00
	;xorwf	DBG_CNT,W
	;btfsc	STATUS,Z
	;GOTO	DBGLOOP

	BTFSC   AY_STATUS, 0 ;if WAITFE = 1
	goto	SEQFEWAIT

	;check if writing data
	BTFSS	AY_STATUS, 3; if wait check = 0
	GOTO	WRITELOOP

	MOVLW	h'FF'
	MOVWF	AY_IF
	movf	AY_IF,W; DATA2 if DATA1 = DATA2, 
	xorwf	DATA_IN,W; DATA1
	btfsc	STATUS,Z; do next
	goto	SEQWAIT;FF=wait

	MOVLW	h'FE'
	MOVWF	AY_IF
	movf	AY_IF,W; DATA2 if DATA1 = DATA2, 
	xorwf	DATA_IN,W; DATA1
	btfsc	STATUS,Z; do next
	goto	SEQWAITFE;FE=wait x times

WRITELOOP
	BCF		AY_STATUS, 3; no wait check

	BTFSS	AY_STATUS, 2 ;if ADDRH = 0
	goto 	SEQADDRH; load addr hi

	BTFSS	AY_STATUS, 1 ;if ADDRL = 0
	goto 	SEQADDRL; load addr lo

	;Start reading values...
	;First, Lower address
	CLRF	AY_COUNT
LAW ;lower ay address (0x00-0x07) write
	BTFSC	AY_ADDRL, 0 ;if bit set, then write
	CALL 	SEQWRITE	; write reg
	RRF		AY_ADDRL, 1; incl to next bit
	incf	AY_COUNT,F ; incl. loop
	movf	AY_COUNT,W
	xorlw	0x08
	btfss	STATUS,Z
	GOTO 	LAW
	
HAW; higher ay address(0x08-0x0D) write
	BTFSC	AY_ADDRH, 0 ;if bit set, then write
	CALL 	SEQWRITE	; write reg.
	RRF		AY_ADDRH, 1; incl to next bit
	incf	AY_COUNT,F ; incl. loop
	movf	AY_COUNT,W
	xorlw	0x0E
	btfss	STATUS,Z
	GOTO 	HAW

	;Clear STATUS
	BCF		AY_STATUS, 1;L
	BCF		AY_STATUS, 2;H
	BSF		AY_STATUS, 3;WAITCHK
	BSF		AY_STATUS, 4;LASTREAD

	;INCF	DBG_CNT, 1

	GOTO	SEQWAIT; end of 1 frame, wait 15ms


	;SNG10 Playback Routine
	;SNG10 consisted of address and value
	;0x00 0x01 0x02 0x03 ... 
	;addr valu addr valu ... 0x10 0x00

	;BTFSS	AY_V, 0
	;GOTO	SEQADDR
	;MOVF   DATA_IN,W
	;MOVWF  dat
	;BCF		AY_V, 0
	;MOVLW	h'FE'
	;MOVWF	AY_IF
	;movf	adr,W	; DATA2 if DATA1 < DATA2, FE < adr
	;subwf	AY_IF,W	; DATA1 (FF = EOL)
	;btfss	STATUS,C; do next (end reading)
	;CALL	LAST_READ
	;MOVLW	h'0F'
	;MOVWF	AY_IF
	;movf	AY_IF,W	; DATA2 if DATA1 < DATA2, adr < 0F
	;subwf	adr,W	; DATA1 (00-0E is vaild address)
	;btfss	STATUS,C; do next (write register)
	;CALL	SEQWREG
	;CALL   TIME10M
	;GOTO   SEQ_READ

;SEQWREG ;back to SEQREAD (SNG10)
;	CALL	WREG
;	GOTO	SEQ_READ

;SEQADDR ;back to SEQREAD (SNG10)
;	MOVF	DATA_IN,W
;	MOVWF	adr
;	BSF		AY_V, 0
;	GOTO	SEQ_READ

DBGLOOP
	MOVF	DATA_IN, 0
LOOP2
	MOVWF	PORTB
	goto	LOOP2

SEQ_READ_INT
  BSF    BUFFER,ACK_BIT ;ACK�r�b�g�𗧂ĂĘA���ǂݏo���ɂ���
  CALL   BYTE_IN     ;1�o�C�g����M�i��M���ACK�𑗏o����j
  RETURN

SEQWAIT
	CALL   TIME15M
	GOTO   SEQ_READ

SEQWAITFE
	BSF		AY_STATUS, 0
	GOTO	SEQ_READ

SEQFEWAIT
LOOPFE	
	CALL	TIME15M
	decfsz	DATA_IN,F
	GOTO	LOOPFE
	BCF		AY_STATUS, 0; Clear WAITFE
	GOTO	SEQ_READ

SEQADDRL
	MOVF   DATA_IN,W
	MOVWF  AY_ADDRL
	BSF    AY_STATUS, 1
	GOTO   SEQ_READ

SEQADDRH
	MOVF   DATA_IN,W
	MOVWF  AY_ADDRH
	BSF    AY_STATUS, 2
	GOTO   SEQ_READ

SEQWRITE
	MOVF	DATA_IN, 0
	MOVWF	dat
	MOVF	AY_COUNT, 0
	MOVWF	adr
	CALL	WREG
	CALL	SEQ_READ_INT
	RETURN

LAST_READ
  BCF    BUFFER,ACK_BIT ;ACK�r�b�g�𑗏o���Ȃ��ōŏI�ǂݏo��
  CALL   BYTE_IN     ;1�o�C�g����M�i��M���ACK�͑��o���Ȃ��j
  CALL   ROM_TIM

  ;add routine here

  CALL   STOP_CON    ;�X�g�b�v�V�[�P���X��

  RETURN             ;���̃T�u���[�`�����甲����

; I2C EEPROM �X�^�[�g�V�[�P���X
START_CON
  BSF    PORTA,SCL
  CALL   ROM_TIM
  CALL   SDA_OUT
  BCF    PORTA,SDA
  CALL   ROM_TIM
  BCF    PORTA,SCL
  CALL   SDA_IN
  RETURN

; I2C EEPROM �X�g�b�v�V�[�P���X
STOP_CON
  CALL   SDA_OUT
  BCF    PORTA,SDA
  BSF    PORTA,SCL
  CALL   ROM_TIM
  CALL   SDA_IN
  RETURN
  
; I2C EEPROM 1�o�C�g���M
BYTE_OUT
  MOVLW  H'0008'
  MOVWF  BITCOUNT    ;8���[�v
BYTE_OUT_2
  BSF    BUFFER,DO
  BTFSS  DATA_OUT,7
  BCF    BUFFER,DO
  CALL   BIT_OUT
  RLF    DATA_OUT,F
  DECFSZ BITCOUNT,F
  GOTO   BYTE_OUT_2
  CALL   BIT_IN
  RETURN

; I2C EEPROM 1�o�C�g��M
BYTE_IN
  CLRF   DATA_IN
  MOVLW  H'0008'
  MOVWF  BITCOUNT    ;8���[�v 
  BCF    STATUS,C
BYTE_IN_2
  RLF    DATA_IN,F
  CALL   BIT_IN
  BTFSC  BUFFER,DI
  BSF    DATA_IN,0
  DECFSZ BITCOUNT,F
  GOTO   BYTE_IN_2
  BSF    BUFFER,DO
  BTFSC  BUFFER,ACK_BIT
  BCF    BUFFER,DO
  CALL   BIT_OUT
  RETURN

; I2C EEPROM 1�r�b�g���M
BIT_OUT
  BCF    PORTA,SCL
  BTFSS  BUFFER,DO
  GOTO   BIT_OUT_3
BIT_OUT_2
  BSF    PORTA,SCL
  CALL   ROM_TIM
  BCF    PORTA,SCL
  CALL   SDA_IN
  RETURN
BIT_OUT_3
  CALL   SDA_OUT
  BCF    PORTA,SDA
  GOTO   BIT_OUT_2

; I2C EEPROM 1�r�b�g��M
BIT_IN
  BCF    PORTA,SCL
  CALL   SDA_IN
  BSF    BUFFER,DI
  BSF    PORTA,SCL
  CALL   ROM_TIM
  BTFSS  PORTA,SDA
  BCF    BUFFER,DI
  BCF    PORTA,SCL
  RETURN

; I2C EEPROM SDA���͒[�q�ݒ�
SDA_IN
  BSF    STATUS,RP0  ;BANK1�ֈړ�
  BSF    TRISA,SDA   ;SDA�[�q����͐ݒ�
  BCF    STATUS,RP0  ;BANK0�ֈړ�
  RETURN

; I2C EEPROM SDA�o�͒[�q�ݒ�
SDA_OUT
  BSF    STATUS,RP0  ;BANK1�ֈړ�
  BCF    TRISA,SDA   ;SDA�[�q���o�͐ݒ�
  BCF    STATUS,RP0  ;BANK0�ֈړ�
  BSF    PORTA,SDA
  RETURN

; I2C EEPROM �^�C�~���O�����p
ROM_TIM
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
  GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
; GOTO   $+1         ;2�T�C�N��
  RETURN             ;2�T�C�N��

; �ȍ~�A�x���^�C�}�[

; 0.4ms
TIME04
  MOVLW  D'250'
  MOVWF  T1
TIMELOOP1
  NOP
  DECFSZ T1,F
  GOTO   TIMELOOP1
  RETURN

; 20ms
TIME20
  MOVLW  D'50'
  MOVWF  T2
TIMELOOP2
  CALL   TIME04
  DECFSZ T2,F
  GOTO   TIMELOOP2
  RETURN

; 1s
TIME1000
  MOVLW  D'50'
  MOVWF  T3
TIMELOOP3
  CALL   TIME20
  DECFSZ T3,F
  GOTO   TIMELOOP3
  RETURN

;*********************************
;  �^�C�}�[�T�u���[�`��
;	TIME10	:10usec
;	TIME100 :100usec
;	TIME1M	:1msec
;*********************************


TIME1M					;1msec(about)
		movlw	0FFh
		movwf	cnt1
T_LP1		nop
		decfsz	cnt1,F
		goto	T_LP1
		return

TIME5M					;5msec(about)
		movlw	05h
		movwf	cnt2
T_LP2		call	TIME1M
		decfsz	cnt2,f
		goto	T_LP2
		return

TIME150M
		movlw	01Eh		;SET 30
		movwf	cnt3
T_LP3		call	TIME5M
		decfsz	cnt3,f
		goto	T_LP3
		return

TIME15M
		movlw	03h		;SET 3
		movwf	cnt3
T_LP5		call	TIME5M
		decfsz	cnt3,f
		goto	T_LP5
		return


TIME1S
		movlw	0C8h		;SET 200
		movwf	cnt4
T_LP4		call	TIME5M
		decfsz	cnt4,f
		goto	T_LP4
		return


;L�`�J

;LEDON
;		movlw B'00000101'
;		movwf PORTA
;		return

;LEDOFF
;		movlw B'00000001'
;		movwf PORTA
;		return

		END