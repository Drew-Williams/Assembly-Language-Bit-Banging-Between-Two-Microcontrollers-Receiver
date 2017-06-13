; uncomment following two lines if using 16f627 or 16f628. config uses internal oscillator
	LIST	p=16F628		;tell assembler what chip we are using
	include "p16f628.inc"		;include the defaults for the chip
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)
	
	org	0x0000
	cblock 	0x20 		; start of general purpose registers
		Delay_Count	; delay loop counter
	endc
	
; un-comment the following two lines if using 16f627 or 16f628
	movlw	0x07
	movwf	CMCON	    ; turn comparators off (make it like a 16F84)
	
; set b port for output, a port for input

	bsf	STATUS,RP0	; select bank 1
	movlw	b'00000000'	; set RB7,RB6,RB5 as output
	movwf	TRISB	
	movlw	b'00000100'	; set RA2 as input
	movwf	TRISA
	bcf	STATUS,RP0	; return to bank 0
	
	bcf	PORTB, 5	; turn off RB5
	bcf	PORTB, 6	; turn off RB6
	bcf	PORTB, 7	; turn off RB7

Rcv_RS232   btfsc   PORTA, 2	    ; wait for start bit
	    goto    Rcv_RS232	    ; if RA2 is high,keep looping
	    call    Start_Delay	    ; RA2 was 0, do half bit time 50us delay
	    btfsc   PORTA, 2	    ; be sure RA2 is still low after 50us delay
	    GOTO    Rcv_RS232
	
	    CALL	Bit_Delay
	    BTFSC	PORTA, 2
	    BSF		PORTB, 7
	    btfss	PORTA, 2
	    bcf		PORTB, 7
	    
	    CALL	Bit_Delay
	    BTFSC	PORTA, 2
	    BSF		PORTB, 6
	    btfss	PORTA, 2
	    bcf		PORTB, 6
	    
	    CALL	Bit_Delay
	    btfsc	PORTA, 2
	    bsf		PORTB, 5
	    btfss	PORTA, 2
	    bcf		PORTB, 5
	
	    goto	Rcv_RS232   ; begin waiting for rcv again

; 50us delay
Start_Delay MOVLW   d'11'	    ; 1us
            MOVWF   Delay_Count	    ; 1us
	    NOP			    ; 1us
	    NOP			    ; 1us
	    NOP			    ; 1us
Start_Wait  NOP			    ; 1us x 11
            DECFSZ  Delay_Count , f ; 1us x 10, 2us
            GOTO    Start_Wait	    ; 2us x 10
            RETURN		    ; 2us

; 100us delay
Bit_Delay   MOVLW   d'24'	    ; 1us
            MOVWF   Delay_Count	    ; 1us
	    NOP			    ; 1us
Bit_Wait    NOP			    ; 1us x 24
            DECFSZ  Delay_Count , f ; 1us x 23, 2us
            GOTO    Bit_Wait	    ; 2us x 23
            RETURN		    ; 2us
	    
	    end


