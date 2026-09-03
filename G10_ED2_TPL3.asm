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
    BCF    PORTC,RC0
    BCF    PORTC,RC1
    BCF    PORTC,RC2
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
    CFG_DELAY_2ms5
		
;===============================================================================
; INICIO PROGRAMA PRINCIPAL
;===============================================================================						
MAIN_LOOP
    
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
    MOVLW    D'1'
    SUBWF    COUNTER_DSPL
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





TEST_DSPL
    RST_COUNTER_DSPL
LOOP_TEST_DSPL
    MOVF   COUNTER_DSPL
    TABLE_CTRL_DSPL
