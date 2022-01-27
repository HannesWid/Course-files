;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Template for lab2 in TSEA28 Datorteknik Y
;;
;; 210105 KPa: Modified for remote version
;;
;;
;; Lab 2: Use two ports for interrupts: Port E pin 4 and port D pin 7
;;
;;    Port B pin 0-7 defined as outputs
;;    Port D pin 2,3,6,7 defined as inputs, pin 7 interrupt on rising edge
;;    Port E pin 0-5 defined as inputs, pin 4 interrupt on rising edge
;;    Port F pin 0-4 defined as outputs

;;
;; Predefined subroutines
;;
;;  inituart:   Initialize uart0 to use 115200 baud, 8N1.
;;  initGPIOB:  Initialize port B, all outputs
;;  initGPIOD:  Initialize port D, interrupt generation on pin 7
;;  initGPIOE:  Initialize port E. interrupt generation on pin 4
;;  initGPIOF:  Initialize port F
;;  initint:    Initialize NVIC to have GPIOD prio 2, GPIOE prio 5
;;  SKBAK:        Print "Bakgrundsprogram"
;;  SKAVH:        Print "=====Avbrott hoger"
;;  SKAVV:        Print "--Avbrott vanster"
;;  DELAY:        Delay, r1=number of ms to wait
;;

	.thumb	; Code is using Thumb mode
	.text	; Code is put into the program memory

;*****************************************************
;*
;* Constants that are not stored in pogram memory
;*
;* Used together with offset constants defined below
;*
;*****************************************************
UART0_base   .equ    0x4000c000    ; Start adress for UART

GPIOA_base   .equ    0x40004000    ; General Purpose IO port A start adress
GPIOB_base   .equ    0x40005000    ; General Purpose IO port B start adress
GPIOC_base   .equ    0x40006000    ; General Purpose IO port C start adress
GPIOD_base   .equ    0x40007000    ; General Purpose IO port D start adress
GPIOE_base   .equ    0x40024000    ; General Purpose IO port E start adress
GPIOF_base   .equ    0x40025000    ; General Purpose IO port F start adress

GPIO_HBCTL   .equ    0x400FE06C    ; GPIO buss choise

NVIC_base    .equ    0xe000e000    ; Nested Vectored Interrupt Controller

GPIO_KEY     .equ    0x4c4f434b    ; Key value to unlock configuration registers

RCGCUART     .equ    0x400FE618    ; Enable UART port
RCGCGPIO     .equ    0x400fe608    ; Enable GPIO port

;*****************************************************
;
; Use as offset together with base-definitions above
; 
;*****************************************************
UARTDR      .equ    0x0000    ; Data register
UARTFR      .equ    0x0018    ; Flag register
UARTIBRD    .equ    0x0024    ; Baud rate control1
UARTFBRD    .equ    0x0028    ; Baud rate control2
UARTLCRH    .equ    0x002c    ;
UARTCTL     .equ    0x0030    ; Control register

GPIODATA    .equ    0x03fc    ; Data register
GPIODIR     .equ    0x0400    ; Direction select
GPIOIS      .equ    0x0404    ; interrupt sense
GPIOIBE     .equ    0x0408    ; interrupt both edges
GPIOIEV     .equ    0x040c    ; interrupt event
GPIOIM      .equ    0x0410    ; interrupt mask
GPIORIS     .equ    0x0414    ; raw interrupt status
GPIOMIS     .equ    0x0418    ; masked interrupt status
GPIOICR     .equ    0x041c    ; interrupt clear
GPIOAFSEL   .equ    0x0420    ; alternate function select
GPIODR2R    .equ    0x0500    ; 2 mA Drive select
GPIODR4R    .equ    0x0504    ; 4 mA Drive select
GPIODR8R    .equ    0x0508    ; 8 mA Drive select
GPIOODR     .equ    0x050c    ; Open drain select
GPIOPUR     .equ    0x510    ; pull-up select
GPIOPDR     .equ    0x514    ; pull-down select
GPIOSLR     .equ    0x518    ; slew rate control select
GPIODEN     .equ    0x51c    ; digital enable
GPIOLOCK    .equ    0x520    ; lock register
GPIOCR      .equ    0x524    ; commit
GPIOAMSEL   .equ    0x528    ; analog mode select
GPIOPCTL    .equ    0x52c    ; port control

NVIC_EN0    .equ    0x100    ; Enable interrupt 0-31
NVIC_PRI0   .equ    0x400    ; Select priority interrupts 0-3
NVIC_PRI1   .equ    0x404    ; Select priority interrupts 4-7
NVIC_PRI7   .equ    0x41c    ; Select priority interrupts 28-31
NVIC_PRI12  .equ    0x430    ; Select priority interrupts 48-51


;*****************************************************
;
; Definitions found in "Introduktion till Darma"
; 
;*****************************************************

GPIOB_GPIODATA	.equ	0x400053fc ; dataregister port B
GPIOB_GPIODIR	.equ	0x40005400 ; riktningsregister port B
GPIOD_GPIODATA	.equ	0x40007330 ; dataregister port D
GPIOD_GPIODIR	.equ	0x40007400 ; riktningsregister port D
GPIOD_GPIOICR	.equ	0x4000741c ; rensa avbrottsrequest port D
GPIOE_GPIODATA	.equ	0x400240fc ; dataregister port E
GPIOE_GPIODIR	.equ	0x40024400 ; riktningsregister port E
GPIOE_GPIOICR	.equ	0x4002441c ; rensa avbrottsrequest port E
GPIOF_GPIODATA	.equ	0x4002507c ; dataregister port F
GPIOF_GPIODIR	.equ	0x40025400 ; riktningsregister port F
GPIOF_GPIOICR	.equ	0x4002541c ; rensa avbrottrequest port F
	
	
;*****************************************************
;
; Texts used by SKBAK, SKAVH, SKAVV
; 
;*****************************************************
	
            .align 4    ; make sure these constants start on 4 byte boundary
Bakgrundstext    .string    "Bakgrundsprogram",13,10,0
Lefttextstart    .string "----AVBROTT v",0xe4, "nster",13,10,0
Leftstar         .string "----------*",13,10,0
Lefttextend      .string "----SLUT v",0xe4, "nster",13,10,0
Righttextstart   .string "==============AVBROTT h",0xf6, "ger",13,10,0
Rightstar        .string "====================*",13,10,0
Righttextend     .string "==============SLUT h",0xf6, "ger",13,10,0

    
    .global main    ; main is defined in this file
    .global intgpiod    ; intgpiod is defined in this file
    .global intgpioe    ; intgpioe is defined in this file

    .align 0x100    ; Start main at an adress ending with two zeros

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Place your program here
;;
;;                 student LiU-ID: Hanwi495
;; + lab group participant LiU-ID: Petsv206


main:
	bl inituart
	bl initGPIOE
	bl initGPIOD
	bl initint
	bl initmemory
mainloop:
	;Disable interrupt
	cpsid i
	bl SKBAK
	;Enable interrupt
	cpsie i
	mov r1, #1000
	bl DELAY
    b mainloop

initmemory:
	;init registers for used memory adresses
	mov r0,#(0x00010203 & 0xffff)
    movt r0,#(0x00010203 >> 16)
    mov r1,#(0x10111213 & 0xffff)
    movt r1,#(0x10111213 >> 16)
    mov r2,#(0x20212223 & 0xffff)
    movt r2,#(0x20212223 >> 16)
    mov r3,#(0x30313233 & 0xffff)
    movt r3,#(0x30313233 >> 16)
    mov r4,#(0x40414243 & 0xffff)
    movt r4,#(0x40414243 >> 16)
    mov r5,#(0x50515253 & 0xffff)
    movt r5,#(0x50515253 >> 16)
    mov r6,#(0x60616263 & 0xffff)
    movt r6,#(0x60616263 >> 16)
    mov r7,#(0x70717273 & 0xffff)
    movt r7,#(0x70717273 >> 16)
    mov r8,#(0x80818283 & 0xffff)
    movt r8,#(0x80818283 >> 16)
    mov r9,#(0x90919293 & 0xffff)
    movt r9,#(0x90919293 >> 16)
    mov r10,#(0xa0a1a2a3 & 0xffff)
    movt r10,#(0xa0a1a2a3 >> 16)
    mov r11,#(0xb0b1b2b3 & 0xffff)
    movt r11,#(0xb0b1b2b3 >> 16)
    mov r12,#(0xc0c1c2c3 & 0xffff)
    movt r12,#(0xc0c1c2c3 >> 16)
    bx lr



    .align 0x100    ; Place interrupt routine for GPIO port D at an adress that ends with two zeros
;***********************************************
;*
;* Place your interrupt routine for GPIO port D here
;*
intgpiod:
    ;Interrupt for GPIO port D
    mov r0, #(GPIOD_GPIOICR & 0xffff)
    movt r0, #(GPIOD_GPIOICR >> 16)
    mov r1, #(1<<7)
    str r1, [r0]
 	push {lr}
	bl SKAVH
	pop {lr}
	bx lr
    .align 0x100    ; Place interrupt routine for GPIO port E
                    ; at an adress that ends with two zeros
;**********************************************
;*
;* Place your interrupt routine for GPIO port E here
;*
intgpioe:
    ;interrupt for GPIO port E
    mov r0, #(GPIOE_GPIOICR & 0xffff)
    movt r0, #(GPIOE_GPIOICR >> 16)
    mov r1, #(1<<4)
    str r1, [r0]
 	push {lr}
	bl SKAVV
	pop {lr}
	bx lr
    .align 0x100    ; Next routine is started at an adress in the program memory that ends with two zeros
;*******************************************************************************************************
;*
;* Subrutines. Nothing of this needs to be changed in the lab.
;*

    .align 2

;* SKBAK: Prints the text "Bakgrundsprogram" slowly
;* Destroys r3, r2, r1, r0
SKBAK:
    push {lr}
    adr  r3,Bakgrundstext
    bl   slowprintstring
    pop  {lr}
    bx   lr

;* SKAVV: Prints the text "Avbrott vanster" followed by 5 lines
;*        with - and a star at the end
;* Destroys r3, r2, r1, r0
SKAVV:
    push {lr}
    adr  r3,Lefttextstart
    bl   slowprintstring
    mov  r2,#5
leftloop:
    mov  r1,#1200
    bl   DELAY
    adr  r3,Leftstar
    bl   slowprintstring
    subs r2,r2,#1
    bne  leftloop
    adr  r3,Lefttextend
    bl   slowprintstring
    pop  {lr}
    bx   lr

;* SKAVH: Prints the text "Avbrott hoger" followed by 5 lines
;*        with = and a star at the end
;* Destroys r3, r2, r1, r0
SKAVH:
    push {lr}
    adr  r3,Righttextstart
    bl   slowprintstring
    mov  r2,#5
rightloop:
    mov r1,#1200
    bl   DELAY
    adr  r3,Rightstar
    bl   slowprintstring
    subs r2,r2,#1
    bne  rightloop
    adr  r3,Righttextend
    bl   slowprintstring
    pop  {lr}
    bx   lr

;* DELAY:
;* r1 = number of ms
DELAY:
    push {r0,r1}
loop_millisecond:
    mov  r0,#0x1300
loop_delay:
    subs r0,r0,#1
    bne  loop_delay
    subs r1,r1,#1
    bne  loop_millisecond
    pop  {r0,r1}
    bx   lr

;* inituart: Initialize serial communiation (enable UART0, set baudrate 115200, 8N1 format)
inituart:
    mov  r1,#(RCGCUART & 0xffff)
    movt r1,#(RCGCUART >> 16)
    ldr  r0,[r1]
    orr  r0,#0x01
    str  r0,[r1]

;   activate  GPIO Port A
    mov  r1,#(RCGCGPIO & 0xffff)
    movt r1,#(RCGCGPIO >> 16)
    ldr  r0,[r1]
    orr  r0,#0x01
    str  r0,[r1]

    nop
    nop
    nop

;   Connect pin 0 and 1 on GPIO port A to the UART function (default for UART0)
;   Allow alt function and enable digital I/O on  port A pin 0 and 1
    mov  r1,#(GPIOA_base & 0xffff)
    movt r1,#(GPIOA_base >> 16)
    ldr  r0,[r1,#GPIOAFSEL]
    orr  r0,#0x03
    str  r0,[r1,#GPIOAFSEL]

    ldr  r0,[r1,#GPIODEN]
    orr  r0,#0x03
    str  r0,[r1,#GPIODEN]

;   Set clockfrequency on the uart, calculated as BRD = 16 MHz / (16 * 115200) = 8.680556
;    => BRDI = 8, BRDF=0.6805556, DIVFRAC=(0.6805556*64+0.5)=44 
;      Final settting of uart clock:
;         8 in UARTIBRD (bit 15 to 0 in UARTIBRD)
    mov  r1,#(UART0_base & 0xffff)
    movt r1,#(UART0_base >> 16)
    mov  r0,#0x08
    str  r0,[r1,#UARTIBRD]

;        44 in UARTFBRD (bit 5 to 0 in UARTFBRD)
    mov  r0,#44
    str  r0,[r1,#UARTFBRD]

;   initialize 8 bit, no FIFO buffert, 1 stop bit, no paritety bit (0x60 to bit 7 to 0 in UARTLCRH)
    mov  r0,#0x60
    str  r0,[r1,#UARTLCRH]

;   activate uart (0 to bits 15 and 14, 0 to bit 11, 0x6 to bits 9 to 7, 0x01 to bits 5 downto 0 in UARTCTL)

    mov  r0,#0x0301
    str  r0,[r1,#UARTCTL]

    bx   lr

    .align 0x10

; initGPIOB, set GPIO port B pin 7 downto 0 as outputs
; destroys r0, r1
initGPIOB:
    mov  r1,#(RCGCGPIO & 0xffff)
    movt r1,#(RCGCGPIO >> 16)
    ldr  r0,[r1]
    orr  r0,#0x02    ; Activate GPIO port B
    str  r0,[r1]
    nop              ; 5 clock cycles before the port can be used
    nop
    nop

    mov  r1,#(GPIO_HBCTL & 0xffff)    ; Select bus for GPIOB
    movt r1,#(GPIO_HBCTL >> 16)
    ldr  r0,[r1]
    bic  r0,#0x02       ; Select apb bus for GPIOB (reset bit 1)
    str  r0,[r1]

    mov  r1,#(GPIOB_base & 0xffff)
    movt r1,#(GPIOB_base >> 16)
    mov  r0,#0xff    ; all pins are outputs
    str  r0,[r1,#GPIODIR]

    mov  r0,#0        ; all pins connects to the GPIO port
    str  r0,[r1,#GPIOAFSEL]

    mov  r0,#0x00    ; disable analog function
    str  r0,[r1,#GPIOAMSEL]

    mov  r0,#0x00    ; Use port B as GPIO without special functions
    str  r0,[r1,#GPIOPCTL]

    mov  r0,#0x00    ; No pullup pins on port B
    str  r0,[r1,#GPIOPUR]

    mov  r0,#0xff    ; all pins are digital I/O
    str  r0,[r1,#GPIODEN]

    bx   lr


; initGPIOD, set pins 2,3,6,7 as inputs
; destroy r0, r1
initGPIOD:
    mov  r1,#(RCGCGPIO & 0xffff)
    movt r1,#(RCGCGPIO >> 16)
    ldr  r0,[r1]
    orr  r0,#0x08    ; aktivera GPIO port D clocking
    str  r0,[r1]
    nop              ; 5 clock cycles before the port can be used
    nop
    nop

    mov  r1,#(GPIO_HBCTL & 0xffff)    ; do not use ahb for GPIOD
    movt r1,#(GPIO_HBCTL >> 16)
    ldr  r0,[r1]
    bic  r0,#0x08       ; use apb bus for GPIOD
    str  r0,[r1]

    mov  r1,#(GPIOD_base & 0xffff)
    movt r1,#(GPIOD_base >> 16)
    mov  r0,#(GPIO_KEY & 0xffff)
    movt r0,#(GPIO_KEY >> 16)
    str  r0,[r1,#GPIOLOCK]        ; unlock port D configuration register

    mov  r0,#0xcc    ; Allow the 4 pins in the port to be configured
    str  r0,[r1,#GPIOCR]

    mov  r0,#0x0        ; all are inputs
    str  r0,[r1,#GPIODIR]

    mov  r0,#0        ; all pins are GPIO pins
    str  r0,[r1,#GPIOAFSEL]

    mov  r0,#0x00    ; disable analog function
    str  r0,[r1,#GPIOAMSEL]

    mov  r0,#0x00    ; Use port D as GPIO without special functions
    str  r0,[r1,#GPIOPCTL]

    mov  r0,#0x00    ; No pullup on port D
    str  r0,[r1,#GPIOPUR]

    mov  r0,#0xff    ; all pins are digital I/O
    str  r0,[r1,#GPIODEN]

    bx    lr

; initGPIOE, set pins bit 0-5 as inputs
; destroys r0, r1
initGPIOE:
    mov  r1,#(RCGCGPIO & 0xffff)
    movt r1,#(RCGCGPIO >> 16)
    ldr  r0,[r1]
    orr  r0,#0x10    ; activate GPIO port E
    str  r0,[r1]
    nop              ; 5 clock cycles before the port can be used
    nop
    nop

    mov  r1,#(GPIO_HBCTL & 0xffff)    ; Do not use ahb (high performance bus) for GPIOE
    movt r1,#(GPIO_HBCTL >> 16)
    ldr  r0,[r1]
    bic  r0,#0x10       ; use apb bus for GPIOE
    str  r0,[r1]

    mov  r1,#(GPIOE_base & 0xffff)
    movt r1,#(GPIOE_base >> 16)
    mov  r0,#0x00        ; all pins are inputs
    str  r0,[r1,#GPIODIR]

    mov  r0,#0        ; all port bits used as GPIO
    str  r0,[r1,#GPIOAFSEL]

    mov  r0,#0x00    ; disable analog functionality
    str  r0,[r1,#GPIOAMSEL]

    mov  r0,#0x00    ; use port E as GPIO without special funtionality
    str  r0,[r1,#GPIOPCTL]

    mov  r0,#0x00    ; No pullup on port E
    str  r0,[r1,#GPIOPUR]

    mov  r0,#0x3f    ; all pins are digital I/O
    str  r0,[r1,#GPIODEN]

    bx   lr


; initGPIOF, set pin 0-3 as outputs, pin 4 as input with pullup
; destroys r0, r1

initGPIOF:
    mov  r1,#(RCGCGPIO & 0xffff)
    movt r1,#(RCGCGPIO >> 16)
    ldr  r0,[r1]
    orr  r0,#0x20    ; activate GPIO port F
    str  r0,[r1]
    nop              ; 5 clock cycles before the port can be used
    nop
    nop

    mov  r1,#(GPIO_HBCTL & 0xffff)    ; Choose bus type for GPIOF
    movt r1,#(GPIO_HBCTL >> 16)
    ldr  r0,[r1]
    bic  r0,#0x20    ; Select GPIOF port connected to the apb bus
    str  r0,[r1]

    mov  r1,#(GPIOF_base & 0xffff)
    movt r1,#(GPIOF_base >> 16)
    mov  r0,#(GPIO_KEY & 0xffff)
    movt r0,#(GPIO_KEY >> 16)
    str  r0,[r1,#GPIOLOCK]        ; unlock port F configuration registers

    mov  r0,#0x1f    ; allow all 5 pins to be configured
    str  r0,[r1,#GPIOCR]

    mov  r0,#0x00    ; disable analog function
    str  r0,[r1,#GPIOAMSEL]

    mov  r0,#0x00    ; use port F as GPIO
    str  r0,[r1,#GPIOPCTL]

    mov  r0,#0x0f    ; use bit 0-3 as outputs (do NOT press the black buttons on Darma!)
    str  r0,[r1,#GPIODIR]

    mov  r0,#0        ; all pins is used by GPIO
    str  r0,[r1,#GPIOAFSEL]

    mov  r0,#0x10    ; weak pull-up for pin 4
    str  r0,[r1,#GPIOPUR]

    mov  r0,#0xff    ; all pins are digitala I/O
    str  r0,[r1,#GPIODEN]

    bx   lr


; initint, initialize interrupt management
; destroys r0,r1
; Enable interrupts from pin 7 port D and pin 4 port E
initint:
    ; disable interrupts while configuring
    cpsid    i

    ; Generate interrupt from port D, GPIO port D is interrupt nr 3 (vector 19)
    ; positiv edge, high priority interrupt

    ; Generete interrupt from port E, GPIO port E is interrupt nr 4 (vector 20)
    ; positiv edge, low priority interrupt


    ; GPIO Port D setup
    ; interrupt generated by positive edge
    mov  r1,#(GPIOD_base & 0xffff)
    movt r1,#(GPIOD_base >> 16)
    mov  r0,#0x00    ; edge detection
    str  r0,[r1,#GPIOIS]

    ; clear interrupts (unnecessary)
    mov  r0,#0xff    ; clear interrupts
    str  r0,[r1,#GPIOICR]

    ; ignorera fallande flank
    mov  r0,#0x00    ; Use IEV to control
    str  r0,[r1,#GPIOIBE]

    ; stigande flank edge
    mov  r0,#0xcc    ; rising edge
    str  r0,[r1,#GPIOIEV]

    ;clear interrupts
    mov  r0,#0xff    ; clear interrupts
    str  r0,[r1,#GPIOICR]

    ; enable interrupts from bit 7
    mov  r0,#0x80    ; Send interrupt to controller
    str  r0,[r1,#GPIOIM]

    ; NVIC management of interrupts from GPIOport D
    ; NVIC_priority interrupt setup
    mov  r1,#(NVIC_base & 0xffff)
    movt r1,#(NVIC_base >> 16)
    ldr  r0,[r1,#NVIC_PRI0]        ; Set priority 2
    bic  r0,r0,#0xe0000000        ; clear bits 31-29
    orr  r0,r0,#0x40000000
    str  r0,[r1,#NVIC_PRI0]

    ; NVIC_enable port D interrupt
    ldr  r0,[r1,#NVIC_EN0]
    orr  r0,#0x00000008            ; enable interrupt nr 3
    str  r0,[r1,#NVIC_EN0]


    ; GPIO port E setup
    ; interrupt activated by input signal edge
    mov  r1,#(GPIOE_base & 0xffff)
    movt r1,#(GPIOE_base >> 16)
    mov  r0,#0x00    ; edge detection
    str  r0,[r1,#GPIOIS]

    ; clear interrupts (unnecessary)
    mov  r0,#0xff    ; clear interrupts
    str  r0,[r1,#GPIOICR]

    ; Enable positive edge (ignore falling edge)
    mov  r0,#0x00    ; Use IEV to control
    str  r0,[r1,#GPIOIBE]

    mov  r0,#0x10    ; rising edge
    str  r0,[r1,#GPIOIEV]

    ; clear interrupt
    mov  r0,#0xff    ; clear interrupts
    str  r0,[r1,#GPIOICR]

    ; enable interrupts from bit 4
    mov  r0,#0x10    ; Send interrupt to controller
    str  r0,[r1,#GPIOIM]

    ; NVIC setup to handle GPIO port E generated interrupt requests
    ; NVIC_priority interrupt 4
    mov  r1,#(NVIC_base & 0xffff)
    movt r1,#(NVIC_base >> 16)
    ldr  r0,[r1,#NVIC_PRI1]        ; Set priority 5
    mvn  r2,#0x000000e0    ; clear bits 7 downto 5
    and  r0,r2
    orr  r0,#0x000000a0
    str  r0,[r1,#NVIC_PRI1]

    ; NVIC_enable allow interrupt nr 4 (port E)
    ldr  r0,[r1,#NVIC_EN0]
    orr  r0,#0x00000010
    str  r0,[r1,#NVIC_EN0]

    ; enable interrupts
    cpsie i

    bx   lr


; Start adress in r3, string terminated with the value 0
; destroy r0, r1, r3
slowprintstring:
    push {lr}
nextchar:
    ldrb r0,[r3],#1
    cmp  r0,#0
    beq  slowprintstringdone
    bl   printchar
    mov  r1,#40
    bl   DELAY
    b    nextchar
slowprintstringdone:
    pop  {lr}
    bx   lr

printchar:
;   Print character located in r0 (bit 7 - bit 0)
;   Check bit 5 (TXFF) in UART0_FR, wait until it is 0
;   send bit 7-0 to UART0_DR
    push {r1}
loop1:
    mov  r1,#(UART0_base & 0xffff)
    movt r1,#(UART0_base >> 16)
    ldr  r1,[r1,#UARTFR]
    ands r1,#0x20           ; Check if send buffer is full
    bne  loop1              ; branch if full 
    mov  r1,#(UART0_base & 0xffff)
    movt r1,#(UART0_base >> 16)
    str  r0,[r1,#UARTDR]    ; send character
    pop  {r1}
    bx   lr


