;===============================================================================
; @file       G10_TPL2_ED2.asm
;
; @authors     Gallardo_Lucas Uriel
;	       Pessolano Dellamea_Ornella Valentina
;	       García Navarro_Huilen
;              Fernández_María Clara
;
; @date       dia/mes/año
;
; @version    1.0
;===============================================================================

;===============================================================================
; DIRECTIVAS DE INCLUSIÓN
;===============================================================================
    LIST P=16F887
    #include "p16f887.inc"	
	
;===============================================================================
; CONFIGURACIÓN GENERAL DEL MCU
;=============================================================================== 	
    __CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF

;===============================================================================
; DEFINICIÓN DE CONSTANTES
;===============================================================================
    #DEFINE CTRL_DSPL_1 PORTC,RC0
    #DEFINE CTRL_DSPL_2 PORTC,RC1
    #DEFINE CTRL_DSPL_3 PORTC,RC2
;===============================================================================
; DEFINICIÓN DE VARIABLES
;===============================================================================
    CBLOCK 0X20
        DELAY1_Init
        DELAY2_Init
        DELAY3_Init
        DELAY1
        DELAY2
        DELAY3
        DATA_DSPL_1
	DATA_DSPL_2
	DATA_DSPL_3
        NUM_MAX_DSPL
	COUNTER_DSPL
	COUNTER_SEGMENTS
    ENDC

;===============================================================================
; DECLARACIÓN DE MACROS PARA CONFIGURACIÓN DE REGISTROS
;===============================================================================

CFG_DSPL MACRO
    BSF    STATUS,RP0
    BCF    STATUS,RP1       ;Banco 1
    BCF    TRISC,TRISC0
    BCF    TRISC,TRISC1
    BCF    TRISC,TRISC2
    BCF    STATUS,RP0       ;Banco 0
    BCF    CTRL_DSPL_1      ;Pines RC0, RC1 y RC2 comienzan en bajo
    BCF    CTRL_DSPL_2
    BCF    CTRL_DSPL_3
    MOVLW  D'1'             ;Asigno el valor de indice para saber que valor
    MOVWF  DATA_DSPL_1      ;tendrá cada display dependiendo de la tabla
    MOVLW  D'2'
    MOVWF  DATA_DSPL_2
    MOVLW  D'3'
    MOVWF  DATA_DSPL_3
    ENDM

CFG_DIGITS_DSPL MACRO
    BSF    STATUS,RP0
    BCF    STATUS,RP1       ;Banco 1
    CLRF   TRISD            ;Todos el puerto D como salida digital
    BCF    STATUS,RP0       ;Banco 0
    CLRF   PORTD            ;Todo el puerto D comienza en bajo
    ENDM

DSPL_ALL_OFF MACRO
    BCF    STATUS,RP0
    BCF    STATUS,RP1       ;Banco 0
    CLRF   PORTD
    ENDM

DSPL_ALL_ON MACRO
    BCF    STATUS,RP0
    BCF    STATUS,RP1       ;Banco 0
    BSF    PORTD,RD0        ;Todo el puerto D en alto
    BSF    PORTD,RD1
    BSF    PORTD,RD2
    BSF    PORTD,RD3
    BSF    PORTD,RD4
    BSF    PORTD,RD5
    BSF    PORTD,RD6
    ENDM

CFG_DELAY_2ms5 MACRO
    MOVLW  D'5'
    MOVWF  DELAY1_Init
    MOVLW  D'9'
    MOVWF  DELAY2_Init
    MOVLW  D'17'
    MOVWF  DELAY3_Init
    ENDM

CFG_DELAY_300ms MACRO
    MOVLW  D'5'
    MOVWF  DELAY1_Init
    MOVLW  D'169'
    MOVWF  DELAY2_Init
    MOVLW  D'117'
    MOVWF  DELAY3_Init
    ENDM

CFG_DELAY_1s MACRO
    MOVLW  D'255'
    MOVWF  DELAY1_Init
    MOVLW  D'245'
    MOVWF  DELAY2_Init
    MOVLW  D'4'
    MOVWF  DELAY3_Init
    ENDM

CFG_DELAY_2s MACRO
    MOVLW  D'31'
    MOVWF  DELAY1_Init
    MOVLW  D'144'
    MOVWF  DELAY2_Init
    MOVLW  D'148'
    MOVWF  DELAY3_Init
    ENDM

;===============================================================================
; INICIALIZACIÓN DEL MCU (CÓDIGO ABSOLUTO)
;===============================================================================    
    ORG     0x00	;Vector de Reset
    GOTO    INICIO	;Salto al inicio del programa principal
    ORG     0x05	;Ubicación Programa Principal en la memoria 
			;de programa
		
;===============================================================================
; INICIALIZACIÓN DE MACROS PARA CONFIGURACIÓN DE REGISTROS
;===============================================================================    	    
INICIO	    ;-----Inicialización de Macros-------
    CFG_DSPL
    CFG_DIGITS_DSPL
		
;===============================================================================
; INICIO PROGRAMA PRINCIPAL
;===============================================================================						

    CALL   TEST_DSPL
    CFG_DELAY_2ms5
MAIN_LOOP
    CALL   MUX_DSPL
    GOTO   MAIN_LOOP
	
;===============================================================================
; SUBRUTINAS
;===============================================================================	 
;*******************************************************************************
; @brief    Retardo por Software
;           
; @details  Implementa 3 bucles anidados
;           t_DELAY = (4/f_clk)*[(3*p*n*m)+(4*n*m)+(4*m)+5]
;******************************************************************************* 
DELAY_3LOOP
    MOVFW  DELAY1_Init   ;m
    MOVWF  DELAY1
LOOP1
    MOVFW  DELAY2_Init   ;n
    MOVWF  DELAY2
LOOP2
    MOVFW  DELAY3_Init   ;p
    MOVWF  DELAY3
LOOP3
    DECFSZ DELAY3,F
      GOTO   LOOP3
    DECFSZ DELAY2,F
      GOTO   LOOP2
    DECFSZ DELAY1,F
      GOTO   LOOP1
    RETURN

;*******************************************************************************
; @brief    Reset del contador de display
;           
; @details  
;*******************************************************************************
RST_COUNTER_DSPL
    MOVLW    D'3'
    MOVWF    COUNTER_DSPL
    RETURN

;*******************************************************************************
; @brief    Decremento del contador de display
;           
; @details  Decrementa el contador en 1
;*******************************************************************************
DECF_COUNTER_DSPL
    DECF    COUNTER_DSPL,F
    RETURN

;*******************************************************************************
;TABLA DISPLAY CÁTODO COMUN									
;Segmento	dp	g 	f	e	d	c	b	a	HEX
;   a	    0	0	0	0	0	0	0	1	0x01
;   b	    0	0	0	0	0	0	1	0	0x02
;   c	    0	0	0	0	0	1	0	0	0x04
;   d	    0	0	0	0	1	0	0	0	0x08
;   e 	    0 	0	0	1	0	0	0	0	0x10
;   f	    0	0	1	0	0	0	0	0	0x20
;   g    	0	1	0	0	0	0	0	0	0x40
;           
;
;*******************************************************************************
TABLE_TEST_SEGMENTS 
ADDWF PCL,F 
RETLW B'00000001' ;índice 0 -> segmento a 
RETLW B'00000010' ;índice 1 -> segmento b 
RETLW B'00000100' ;índice 2 -> segmento c 
RETLW B'00001000' ;índice 3 -> segmento d 
RETLW B'00010000' ;índice 4 -> segmento e 
RETLW B'00100000' ;índice 5 -> segmento f 
RETLW B'01000000' ;índice 6 -> segmento g 

;*******************************************************************************
;TABLA DE CONTROL			
;RC0	0	0	1
;RC1	0	1	0
;RC2	1	0	0
;*******************************************************************************

TABLE_CTRL_DSPL_CC 
ADDWF PCL,F 
RETLW B'00000000' ;índice 0, no se usa (COUNTER_DSPL nunca vale 0)
RETLW B'00000001' ;COUNTER_DSPL=1 -> RC0 (display 1) 
RETLW B'00000010' ;COUNTER_DSPL=2 -> RC1 (display 2) 
RETLW B'00000100' ;COUNTER_DSPL=3 -> RC2 (display 3) 


;*******************************************************************************
; @brief    Subrutina de testeo de los display
;           
; @details  Enciende los segmenttos de los display uno a uno, desde a hasta g,
;           luego prende y apaga todos los segmentos del display
;*******************************************************************************
TEST_DSPL
                    CALL   RST_COUNTER_DSPL
LOOP_TEST_DSPL      MOVF   COUNTER_DSPL,W
                    CALL   TABLE_CTRL_DSPL_CC
		    MOVWF  PORTC
		    BCF    STATUS,RP0
		    BCF    STATUS,RP1
		    BSF    STATUS,C
		    DSPL_ALL_OFF
		    CFG_DELAY_300ms
		    MOVLW   D'7'
		    MOVWF  COUNTER_SEGMENTS
LOOP_TEST_SEGMENT   RLF    PORTD,F
                    CALL   DELAY_3LOOP
		    DECFSZ COUNTER_SEGMENTS,F
		    GOTO   LOOP_TEST_SEGMENT
		    DSPL_ALL_ON
		    CFG_DELAY_2s
		    CALL   DELAY_3LOOP
		    DSPL_ALL_OFF
		    CALL   DELAY_3LOOP
		    DECFSZ COUNTER_DSPL,F
		    GOTO   LOOP_TEST_DSPL
                    CALL   RST_COUNTER_DSPL
		    RETURN

;*******************************************************************************
; @brief    Actualización de display 1
;           
; @details  Actualiza el caracter mostrado en el display 1
;*******************************************************************************
UPDATE_DSPL_1
    MOVF   DATA_DSPL_1,W
    CALL   TABLE_DECO_DSPL_CC
    MOVWF  PORTD
    MOVF   COUNTER_DSPL,W
    CALL   TABLE_CTRL_DSPL_CC
    MOVWF  PORTC
    CALL   DECF_COUNTER_DSPL
    RETURN

;*******************************************************************************
; @brief    Actualización de display 2
;           
; @details  Actualiza el caracter mostrado en el display 2
;*******************************************************************************
UPDATE_DSPL_2
    MOVF   DATA_DSPL_2,W
    CALL   TABLE_DECO_DSPL_CC
    MOVWF  PORTD
    MOVF   COUNTER_DSPL,W
    CALL   TABLE_CTRL_DSPL_CC
    MOVWF  PORTC
    CALL   DECF_COUNTER_DSPL
    RETURN

;*******************************************************************************
; @brief    Actualización de display 3
;           
; @details  Actualiza el caracter mostrado en el display 3
;*******************************************************************************
UPDATE_DSPL_3
    MOVF   DATA_DSPL_3,W
    CALL   TABLE_DECO_DSPL_CC
    MOVWF  PORTD
    MOVF   COUNTER_DSPL,W
    CALL   TABLE_CTRL_DSPL_CC
    MOVWF  PORTC
    CALL   DECF_COUNTER_DSPL
    RETURN

;*******************************************************************************
; @brief    Subrutina de manejo de displays
;           
; @details  Multiplexa los displays
;*******************************************************************************
MUX_DSPL
    CALL   DELAY_3LOOP
    MOVLW  D'3'
    SUBWF  COUNTER_DSPL,W
    BTFSC  STATUS,Z
    GOTO   UPDATE_DSPL_3
    MOVLW  D'2'	
    SUBWF  COUNTER_DSPL,W	
    BTFSC  STATUS,Z
    GOTO   UPDATE_DSPL_2
    MOVLW  D'1'
    SUBWF  COUNTER_DSPL,W
    BTFSC  STATUS,Z
    GOTO   UPDATE_DSPL_1
    CALL   RST_COUNTER_DSPL
    RETURN

;===============================================================================
    END
;===============================================================================

