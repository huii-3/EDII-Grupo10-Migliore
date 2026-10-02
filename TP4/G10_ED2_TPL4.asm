;===============================================================================
; @file       G10_TPL3_ED2.asm
;
; @authors     Gallardo_Lucas Uriel
;	       Pessolano Dellamea_Ornella Valentina
;	       García Navarro_Huilen
;              Fernández_María Clara
;
; @date       28/09/2026
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
    #DEFINE    LED0     PORTD,RD0
    #DEFINE    LED1     PORTD,RD1
    #DEFINE    LED2     PORTD,RD2
    #DEFINE    LED3     PORTD,RD3
    #DEFINE    LED4     PORTD,RD4
    #DEFINE    LED5     PORTD,RD5
    #DEFINE    LED6     PORTD,RD6
    #DEFINE    LED7     PORTD,RD7
    #DEFINE    KEYPAD_ROW1    PORTB,RB0
    #DEFINE    KEYPAD_ROW2    PORTB,RB1
    #DEFINE    KEYPAD_COL1    PORTB,RB4
    #DEFINE    KEYPAD_COL2    PORTB,RB5
    #DEFINE    KEYPAD_COL3    PORTB,RB6
    #DEFINE    KEYPAD_COL4    PORTB,RB7
    
;===============================================================================
; DEFINICIÓN DE VARIABLES
;=============================================================================== 
    CBLOCK    0X20
        KEYPAD_NUMBER
        ENDC
    
    CBLOCK    0X70
        W_TEMP
        STATUS_TEMP
        ENDC
;===============================================================================
; DECLARACIÓN DE MACROS PARA CONFIGURACIÓN DE REGISTROS
;===============================================================================
CFG_LEDS MACRO
    BANKSEL    TRISD        ;Banco 1
    CLRF       TRISD        ;Todo el puerto D como salida digital
    BANKSEL    PORTD        ;Banco 0
    CLRF       PORTD        ;Todo el puerto D esta en 0
    ENDM
    
LEDS_OFF MACRO              ;Apaga todos los leds
    BANKSEL    PORTD        ;Banco 0
    CLRF       PORTD
    ENDM
    
CFG_KEYPAD MACRO
    BANKSEL    TRISB          ;Banco 1
    BCF        KEYPAD_ROW1    ;Defino las filas como salidas
    BCF        KEYPAD_ROW2
    BSF        KEYPAD_COL1    ;Defino las columnas como entradas digitales
    BSF        KEYPAD_COL2
    BSF        KEYPAD_COL3
    BSF        KEYPAD_COL4
    BANKSEL    ANSELH
    BCF        ANSELH,ANS13   ;Desabilito los pines analógicos del puerto B
    BCF        ANSELH,ANS12
    BCF        ANSELH,ANS11
    BCF        ANSELH,ANS10
    BCF        ANSELH,ANS9
    BCF        ANSELH,ANS8
    BANKSEL    PORTB
    BCF        KEYPAD_ROW1    ;Las filas arrancan en 0
    BCF        KEYPAD_ROW2
    ENDM
    
CFG_ISR MACRO
    BANKSEL    IOCB
    BSF        IOCB,IOCB4     ;Habilita Interrupción por cambio de estado en
    BSF        IOCB,IOCB5     ;los pines RB4, RB5, RB6 y RB7
    BSF        IOCB,IOCB6
    BSF        IOCB,IOCB7
    BANKSEL    OPTION_REG           ;Habilita las resistencias pull-up
    BCF        OPTION_REG,NOT_RBPU  ;integradas del puerto B
    BANKSEL    WPUB
    BSF        WPUB,WPUB4     ;Habilito las resistencias pull-up
    BSF        WPUB,WPUB5     ;individualemente para RB4, RB5, RB6 y RB7
    BSF        WPUB,WPUB6
    BSF        WPUB,WPUB7
    BCF        WPUB,WPUB0     ;Deshabilito las resistencias pull-up
    BCF        WPUB,WPUB1     ;individualmente para RB0, RB1, RB2 y RB3
    BCF        WPUB,WPUB2
    BCF        WPUB,WPUB3
    BANKSEL    INTCON
    BCF        INTCON,RBIF    ;Baja la bandera de Interrupción por IOC
    BSF        INTCON,RBIE    ;Habilita Interrupción por IOC
    BSF        INTCON,GIE     ;Habilita Interrupciones globales
    ENDM
;===============================================================================
; INICIALIZACIÓN DEL MCU (CÓDIGO ABSOLUTO)
;===============================================================================    
    ORG     0x00	    ;Vector de Reset
    GOTO    INICIO	    ;Salto al inicio del programa principal
    ORG     0x04	    ;Vector de Interrupción
    GOTO    ISR_INICIO	    ;Salto al Rutina de Servicio de Interrupción
    ORG     0x05	    ;Ubicación Programa Principal en la memoria 
			    ;de programa
		
;===============================================================================
; INICIALIZACIÓN DE MACROS PARA CONFIGURACIÓN DE REGISTROS
;===============================================================================    	    
INICIO	    ;-----Inicialización de Macros-------
            CFG_LEDS
	    CFG_KEYPAD
	    CFG_ISR
		
;===============================================================================
; INICIO PROGRAMA PRINCIPAL
;===============================================================================						
MAIN_LOOP
    ;...
    GOTO    MAIN_LOOP	

;===============================================================================
; INICIALIZACIÓN DE RUTINAS DE SERVICIO DE INTERRUPCIÓN
;===============================================================================		    
ISR_INICIO		
    ;--------Guardado de Contexto--------
    MOVWF      W_TEMP
    SWAPF      STATUS,W
    MOVWF      STATUS_TEMP
    ;------------------------------------
    ;---Identificación de Interrupción---
    BANKSEL    INTCON
    BTFSC      INTCON,RBIF
      GOTO       ISR_IOC
    GOTO       ISR_FIN
    ;------------------------------------	
		
;===============================================================================
; FINALIZACIÓN DE RUTINAS DE SERVICIO DE INTERRUPCIÓN
;===============================================================================		    
ISR_FIN			    
    ;--------Restauración de Contexto--------
    SWAPF      STATUS_TEMP,W
    MOVWF      STATUS
    SWAPF      W_TEMP,F
    SWAPF      W_TEMP,W
    RETFIE
    ;----------------------------------------
	
;===============================================================================
; SUBRUTINAS
;===============================================================================
;*******************************************************************************
; @brief    Subrutina de lectura del teclado
;
; @details  
;******************************************************************************* 
KEY_READ
        CLRF    KEYPAD_NUMBER
        INCF    KEYPAD_NUMBER
	GOTO    ACTIVE_ROW1	
    ACTIVE_ROW1
        BANKSEL PORTB
        BCF     KEYPAD_ROW1
	BSF     KEYPAD_ROW2
	GOTO    SCANN_COLS	
    ACTIVE_ROW2
        BANKSEL PORTB
        BSF     KEYPAD_ROW1
        BCF     KEYPAD_ROW2
        GOTO    SCANN_COLS
    SCANN_COLS
        BANKSEL PORTB
        BTFSS   KEYPAD_COL1
          GOTO    WAIT_RELEASE
	INCF    KEYPAD_NUMBER
        BTFSS   KEYPAD_COL2
          GOTO    WAIT_RELEASE
        INCF    KEYPAD_NUMBER
        BTFSS   KEYPAD_COL3
          GOTO    WAIT_RELEASE
        INCF    KEYPAD_NUMBER
        BTFSS   KEYPAD_COL4
          GOTO    WAIT_RELEASE
        INCF    KEYPAD_NUMBER
        GOTO    SCANN_ROWS
    SCANN_ROWS
        BTFSS   KEYPAD_ROW1
        GOTO    ACTIVE_ROW2
        BTFSS   KEYPAD_ROW2
          NOP
        GOTO    RST_KEYPAD
    WAIT_RELEASE
    LOOP_COL1
	BTFSS  KEYPAD_COL1
	  GOTO   LOOP_COL1
    LOOP_COL2
	BTFSS  KEYPAD_COL2
	  GOTO   LOOP_COL2
    LOOP_COL3
	BTFSS  KEYPAD_COL3
	  GOTO   LOOP_COL3
    LOOP_COL4
	BTFSS  KEYPAD_COL4
	  GOTO   LOOP_COL4
	BCF    KEYPAD_ROW1
	BCF    KEYPAD_ROW2
	RETURN
    RST_KEYPAD
        CLRF    KEYPAD_NUMBER
        BCF     KEYPAD_ROW1
        BCF     KEYPAD_ROW2
        RETURN

;*******************************************************************************
; @brief    Tabla de decodificación de LEDs
;
; @details  Mapea el valor de W con el pin que se quiera encender de un puerto
;******************************************************************************* 
TABLE_DECO_LEDS
	ADDWF      PCL,F
	RETLW      b'00000000'
	RETLW      b'00000001' ; RD0
        RETLW      b'00000010' ; RD1
        RETLW      b'00000100' ; RD2
        RETLW      b'00001000' ; RD3
        RETLW      b'00010000' ; RD4
        RETLW      b'00100000' ; RD5
        RETLW      b'01000000' ; RD6
        RETLW      b'10000000' ; RD7

;*******************************************************************************
; @brief    Subrutina de testeo del teclado
;
; @details  Dendiendo del valor que se haya leído en el teclado y  luego
;           guardado en KEYPAD_NUMBER será el LED que se encienda
;*******************************************************************************
TEST_KEYPAD
	LEDS_OFF
	MOVF      KEYPAD_NUMBER,W
	CALL      TABLE_DECO_LEDS
	BANKSEL   PORTD
	MOVWF     PORTD
	RETURN

;*******************************************************************************
; @brief    Subrutina de servicio de interrupción para interrupciones por
;           cambio de estado (IOC)
;
; @details  
;******************************************************************************* 
ISR_IOC
	CALL      KEY_READ
	CALL      TEST_KEYPAD
	BANKSEL   INTCON
	BCF       INTCON,RBIF
	GOTO      ISR_FIN
;===============================================================================		
    END
;===============================================================================