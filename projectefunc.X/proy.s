;  Archivo: LAB3
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador en el puerto A
; Hardware: LEDS en el puerto A
;
; Creado: 6 feb ,2023
; Última modificación: 6 feb,2023
    
PROCESSOR 16F887
#include <xc.inc>
    
 ;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT
 CONFIG WDTE=OFF 
 CONFIG PWRTE=OFF
 CONFIG MCLRE=OFF
 CONFIG CP=OFF
 CONFIG CPD=OFF
 
 CONFIG BOREN=OFF
 CONFIG IESO=OFF
 CONFIG FCMEN=OFF
 CONFIG LVP=OFF
 
 CONFIG WRT= OFF
 CONFIG BOR4V=BOR40V
 
 ;-----Macros---------------
 restart_tmr0 macro
 banksel PORTA 
 movlw   100
    movwf   TMR0
    bcf	    T0IF
    endm
    
 ;------------------------Variables------------------
 PSECT udata_bank0
  cont_1s: DS 1
  cont: DS 2
  stat: DS 1
    var: DS 1
   comp: DS 1
  PSECT udata_shr
 W_TEMP: DS 1
 STATUS_TEMP: DS 1
    
    PSECT resVect, class=CODE,abs, delta=2
    ORG 00h
    resetVec: 
    PAGESEL main
    goto main
    
    ORG 04h
    push:
    movwf W_TEMP
    swapf STATUS,W
    movwf STATUS_TEMP
    
    isr: 
    btfsc RBIF
    call int_iocb
    btfsc T0IF
    call ondas
    pop:
    swapf STATUS_TEMP,W
    movwf STATUS
    swapf W_TEMP,F
    swapf W_TEMP,W
    retfie
    ;------Subrutinas de interrupcion-----
    int_iocb:
    banksel PORTA
    btfss PORTB,0
    call statondacuad
    btfss PORTB,1
    call statondatri
    bcf RBIF
    return
    cont_tmr0:
    restart_tmr0
    incf cont
    movf cont,W
    sublw 5
    btfss ZERO
    goto return_t0  
    clrf cont
    incf PORTA
    movf PORTA,w
    movwf var
    return_t0:
    return
    statondatri:
    
    movlw 0
    movwf stat
    movwf comp
    return
    statondacuad:
    movlw 1
    movwf stat
    movlw 0
    movwf comp
    return
    ondas:
    btfsc stat,0
    call ondacuad
    btfss stat,0
    call ondatri
    return
    ;-----------Funciones principales de las ondas------------
    ondacuad:
    btfsc comp,0
    call lcuad
    btfss comp,0
    call hcuad
    
    return
    ondatri:
    btfsc comp,0
    call dectri
    btfss comp,0
    call inctri
 
    return
    ;----------Aumentos y decrementos con el tmr0------
    dec_tmr0:
    restart_tmr0
    incf cont
    movf cont,W
    sublw 5
    btfss ZERO
    goto return_t0  
    clrf cont
    decf PORTA
    return_t02:
    return
    ;-------------Incremnto de la onda triangular----------
    inctri:
    call cont_tmr0
    movlw 255
    subwf var,w
    btfss STATUS,2
    goto $+2
    goto $+2
    return
    movlw 1
    movwf comp
    movlw 1
    movwf PORTC
    return
    ;----------------Decremento de la onda triangular----------
    dectri:
    call dec_tmr0
    movf PORTA,w
    movwf var
    movlw 0
    subwf var,w
    btfss STATUS,2
    goto $+2
    goto $+2
    return
    movlw 0
    movwf comp
     movlw 0
    movwf PORTC
    return
    hcuad:
    restart_tmr0
    movlw 255
    movwf PORTA
    incf cont
    movf cont,W
    sublw 100
    btfss ZERO
    goto return_t0  
    clrf cont
    movlw 1
    movwf comp
    movlw 1
    movwf PORTC
    return
    lcuad:
    restart_tmr0
    clrf PORTA
    incf cont
    movf cont,W
    sublw 50
    btfss ZERO
    goto return_t0  
    clrf cont
    movlw 0
    movwf comp
    movlw 0
    movwf PORTC
    return
    PSECT code,delta=2,abs
 ORG 100h   
 tabla:
    clrf PCLATH
    bsf PCLATH,0
    andlw 0x0f
    addwf PCL
    ;------------Binarios catodo comun------
    retlw 00111111B	    ;0
    retlw 00000110B	    ;1
    retlw 01011011B	    ;2
    retlw 01001111B	    ;3
    retlw 01100110B	    ;4
    retlw 01101101B	    ;5
    retlw 01111101B	    ;6
    retlw 00000111B	    ;7
    retlw 01111111B	    ;8
    retlw 01101111B	    ;9
    retlw 01110111B	    ;A
    retlw 01111100B	    ;B
    retlw 00111001B	    ;C
    retlw 01011110B	    ;D
    retlw 01111001B	    ;E
    retlw 01110001B	    ;F
    ;-----------------Binarios anodo comun--------
    ;retlw 11000000B	    ;0
    ;retlw 11111001B	    ;1
    ;retlw 10100100B	    ;2
    ;retlw 10110000B	    ;3
    ;retlw 10011001B	    ;4
    ;retlw 10010010B	    ;5
    ;retlw 10000010B	    ;6
    ;retlw 11111000B	    ;7
    ;retlw 10000000B	    ;8
    ;retlw 10010000B	    ;9
    ;retlw 10001000B	    ;A
    ;retlw 10000011B	    ;B
    ;retlw 11000110B	    ;C
    ;retlw 10100001B	    ;D
    ;retlw 10000110B	    ;E
    ;retlw 10001110B	    ;F
 ;----------------------Configuracion---------------
 main: 

   call config_io
   call config_reloj
   call config_tmr0
  call  config_int_enable
  call config_ioc
   banksel PORTA
    
    loop:

    
   

    goto loop
    ;---------------------------Subrutinas----------------------
    config_ioc:
    banksel TRISA
    bsf IOCB,0
    bsf IOCB,1
    banksel PORTA
    movf PORTB,W
    bcf RBIF 
    
    return 
    
    config_int_enable:
    bsf GIE
    bsf T0IE
    bcf T0IF
    bsf RBIE
    bcf RBIF
    return
    config_tmr0:
    banksel TRISA
    bcf T0CS
    bcf PSA ;Establecido en 101, 1:64
    bsf PS2
    bcf PS1
    bsf PS0
    banksel PORTA
    restart_tmr0
    return
    config_io:
     bsf STATUS,5  ;Banco 11
    bsf STATUS,6
    clrf ANSEL ;Pines digitales
    clrf ANSELH
    
    banksel TRISA
    clrf TRISA
    ;Establecemos con entradas los pines del puerto B
    bsf TRISB,0
    bsf TRISB,1
    bcf OPTION_REG,7
    bsf WPUB, 0
    bsf WPUB,1
    
    ;Establecemos los pines del puerto C como salidas
    bcf TRISC,0
    bcf TRISC,1
    bcf TRISC,2
    bcf TRISC,3
    ;Establecemos los pines del puerto E como salida
    ;bcf TRISE,0
    ;Establecemos los pines del puerto D como salidas
    ;clrf TRISD
   ;Limpiamos los pines al iniciar el programa
    bcf STATUS,5
    bcf STATUS,6
    clrf  PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
  return
  config_reloj:
    banksel OSCCON
    bsf IRCF2
    bcf IRCF1
    bsf IRCF0
    bsf SCS
    return
 
 
    
    END
