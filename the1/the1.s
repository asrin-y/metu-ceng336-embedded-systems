PROCESSOR 18F8722
    
#include <xc.inc>

; configurations
CONFIG OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF

; global variable declarations
GLOBAL flag1,toggle,temp_b,flag2,temp_c,copy_b
GLOBAL _t1, _t2, _t3
; allocating memory for variables
PSECT udata_acs
    copy_b:
	DS 1    ; allocates 1 byte
    flag1:
	DS 1    ; allocates 1 byte
    flag2:
	DS 1    ; allocates 1 byte
    temp_b:
	DS 1    ; allocates 1 byte
    temp_c:
	DS 1    ; allocates 1 byte
    toggle:
	DS 1    ; allocates 1 byte
    _t1:
        DS 1    ; allocate 1 byte
    _t2:
        DS 1    ; allocate 1 byte
    _t3:
        DS 1    ; allocate 1 byte
PSECT resetVec,class=CODE,reloc=2
resetVec:
    goto    main

; DO NOT DELETE OR MODIFY
; 500ms pass check for test scripts
ms500_passed:
    nop
    return

; DO NOT DELETE OR MODIFY
; 1sec pass check for test scripts
ms1000_passed:
    nop
    return

full_sec_delay:
    movlw 0x84      ; copy desired value to W
    movwf _t3       ; copy W into t3
    _loop3:
        movlw 0xAF      ; copy desired value to W
        movwf _t2       ; copy W into t2
        _loop2:
            movlw 0x8F      ; copy desired value to W
            movwf _t1       ; copy W into t1
            _loop1:
                decfsz _t1, 1   ; decrement t1, if 0 skip next 
                goto _loop1     ; else keep counting down
                decfsz _t2, 1   ; decrement t2, if 0 skip next 
                goto _loop2     ; else keep counting down
                decfsz _t3, 1   ; decrement t3, if 0 skip next 
                goto _loop3     ; else keep counting down
                return    
		
half_sec_delay:
    movlw 0x42      ; copy desired value to W
    movwf _t3       ; copy W into t3
    _loop31:
        movlw 0xAF      ; copy desired value to W
        movwf _t2       ; copy W into t2
        _loop21:
            movlw 0x8F      ; copy desired value to W
            movwf _t1       ; copy W into t1
            _loop11:
                decfsz _t1, 1   ; decrement t1, if 0 skip next 
                goto _loop11     ; else keep counting down
                decfsz _t2, 1   ; decrement t2, if 0 skip next 
                goto _loop21     ; else keep counting down
                decfsz _t3, 1   ; decrement t3, if 0 skip next 
                goto _loop31     ; else keep counting down
                return 
init:
    clrf flag1
    clrf flag2
    clrf toggle
    
    movlw 00001111B
    movwf LATB
    
    movlw 00000011B
    movwf LATC
    
    movlw 0xFF
    movwf LATD
    
    clrf TRISA
    clrf TRISB
    clrf TRISC
    clrf TRISD
    clrf TRISE
    bsf TRISA,4
    bsf TRISE,4
    
    call full_sec_delay
    call default_config
    return
    
default_config:
    movlw 00000001B
    movwf LATB
    movwf LATC
    clrf LATD
    return

set_flag1:
    bsf flag1,0
    return

set_flag2:
    bsf flag2,0
    return

check_release1:
    btfsc PORTE,4
    goto loop1
    bcf flag1,0
    goto loop2
    
turn_off_b:
    movff LATB,temp_b
    clrf LATB
    bsf toggle,0
    goto continue1
    
turn_on_b:
    movff temp_b,LATB
    bcf toggle,0
    goto continue1

check_release2:
    btfsc PORTE,4
    goto continue2
    bcf flag1,0
    bcf toggle,0
    goto loop3
    
check_release3:
    btfsc PORTA,4
    goto loop2
    bcf flag2,0
    goto increment_b
    goto loop2
    
check_release4:
    btfsc PORTE,4
    goto continue4
    bcf flag1,0
    bcf toggle,0
    goto loop4
    
check_release5:
    btfsc PORTA,4
    goto loop3
    bcf flag2,0
    goto increment_c
    goto loop3
    
increment_b:
    btfsc temp_b,3
    goto reset_b
    rlncf temp_b
    bsf temp_b,0
    goto loop2
  
increment_c:
    btfsc temp_c,0
    goto c_0
    goto c_1

c_0:
    rlncf temp_c
    goto loop3
   
c_1:
    rrncf temp_c
    goto loop3
    
reset_b:
    clrf temp_b
    bsf temp_b,0
    goto loop2
   
turn_off_c:
    movff LATC,temp_c
    clrf LATC
    bsf toggle,0
    goto continue3
turn_on_c:
    movff temp_c,LATC
    bcf toggle,0
    goto continue3
    
set_countdown1:
    movff temp_b,LATD
    goto countdown
    
set_countdown2:
    movff temp_b,copy_b
    goto countdown_helper

countdown_helper:
    btfss copy_b,0
    goto set_countdown1
    rrcf copy_b
    rlcf temp_b
    goto countdown_helper
    
start_over:
    call default_config
    goto loop1
    
PSECT CODE

main:
    call init
    call ms1000_passed
    ; a loop here, maybe
    loop1:
	call half_sec_delay
	call ms500_passed
        btfsc PORTE,4
	call set_flag1
	nop
	btfsc flag1,0
	goto check_release1
	goto loop1
    loop2:
	call half_sec_delay
	call ms500_passed
	btfss toggle,0
	goto turn_off_b
	goto turn_on_b
    continue1:
	btfsc PORTE,4
	call set_flag1
	nop
	btfsc flag1,0
	call check_release2
	nop
    continue2:
	btfsc PORTA,4
	call set_flag2
	nop
	btfsc flag2,0
	call check_release3
	goto loop2
    loop3:
	call half_sec_delay
	call ms500_passed
	movff temp_b,LATB
	btfss toggle,0
	goto turn_off_c
	goto turn_on_c
    continue3:
	btfsc PORTE,4
	call set_flag1
	nop
	btfsc flag1,0
	call check_release4
	nop
    continue4:
	btfsc PORTA,4
	call set_flag2
	nop
	btfsc flag2,0
	call check_release5
	goto loop3
    loop4:
	call half_sec_delay
	call ms500_passed
	movff temp_c,LATC
	btfsc temp_c,0
	goto set_countdown1
	goto set_countdown2
    countdown:
    	call half_sec_delay
	call ms500_passed
	btfss LATD,0
	goto start_over
	rrcf LATD
	bcf LATD,7
	goto countdown
	
end resetVec