; -----------------------------------------------------------------------
; Iron Man-style reactor LED controller
; (C)2010 Mike Bourgeous
    #include <p12f508.inc>

; -----------------------------------------------------------------------
; Configuration bits: adapt to your setup and needs
    __CONFIG _IntRC_OSC & _WDT_OFF & _CP_OFF & _MCLRE_OFF

; -----------------------------------------------------------------------
; constants
#define	FADE_LOOPS	6
#define	CYCLE_LOOPS	3

; -----------------------------------------------------------------------
; variables
vars	UDATA
d1	res	1
d2	res	1
d3	res	1
tmp1	res	1
onval	res	1
offval	res	1
i	res	1
loops	res	1

; -----------------------------------------------------------------------
; oscillator calibration
calibration	CODE	0x1ff
	dw	0x0c1e

; -----------------------------------------------------------------------
; relocatable code
PROG	CODE
start
	; Initialize chip settings
	movwf	OSCCAL
	movlw	b'11001111'
	option

	movlw	0x00
	movwf	GPIO
	tris	GPIO

	;goto flash_leds
	goto cycle_leds_init
	;goto fade_leds_init

	; Turn all outputs on for testing
	movlw	0xff
	movwf	GPIO
	goto	$



; PWM
fade_leds_init
	movlw	FADE_LOOPS
	movwf	loops

fade_leds
	movlw	0x01
	movwf	tmp1
	clrf	offval

	movlw	0xff
	movwf	onval
rising
	call	pwm_cycle
	incfsz	tmp1
	goto rising

	movlw	0xff
	movwf	tmp1
falling
	call	pwm_cycle
	decfsz	tmp1
	goto	falling

	decfsz	loops
	goto	fade_leds

	clrf	GPIO
	call	Delay_50ms
	goto	cycle_leds_init


; Does a single PWM cycle.  Pass duty cycle in tmp1, on value in onval, off value in offval.
pwm_cycle
	; On phase - tmp1 ns
	movfw	onval
	movwf	GPIO
	movfw	tmp1
	movwf	i
	nop
pwm_on
	call	Delay_10ns
	;goto $+1
	;goto $+1
	decfsz	i
	goto	pwm_on

	; Off phase - (256-tmp1) ns
	movfw	offval
	movwf	GPIO
	clrf	i
	movfw	tmp1
	subwf	i
pwm_off
	call	Delay_10ns
	;goto $+1
	;goto $+1
	decfsz	i
	goto	pwm_off

	retlw	0


cycle_leds_init
	movlw	CYCLE_LOOPS
	movwf	loops

cycle_leds
	bsf	STATUS, C
	movlw	b'11111110'
	movwf	tmp1
	movlw	6
	movwf	i
cycle_leds_loop
	movfw	tmp1
	movwf	GPIO
	call	Delay_50ms
	rlf	tmp1

	decfsz	i
	goto	cycle_leds_loop

	decfsz	loops
	goto	cycle_leds

	clrf	GPIO
	call	Delay_50ms
	call	Delay_50ms
	call	Delay_50ms
	call	Delay_50ms
	goto	fade_leds_init


flash_leds
	movlw	0x00
	movwf	GPIO
	call	Delay_500ms
	movlw	0x3f
	movwf	GPIO
	call	Delay_500ms
	goto	flash_leds ; loop forever


Delay_10ns
			;6 cycles
	goto	$+1
	goto	$+1
	goto	$+1

			;4 cycles (including call)
	return


Delay_50ms
			;49993 cycles
	movlw	0x0E
	movwf	d1
	movlw	0x28
	movwf	d2
Delay_50ms_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_50ms_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

Delay_500ms
			;499994 cycles
	movlw	0x03
	movwf	d1
	movlw	0x18
	movwf	d2
	movlw	0x02
	movwf	d3
Delay_500ms_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	$+2
	decfsz	d3, f
	goto	Delay_500ms_0

			;2 cycles
	goto	$+1

			;4 cycles (including call)
	return

END
