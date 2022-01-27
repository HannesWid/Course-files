;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Mall för lab1 i TSEA28 Datorteknik Y
;;
;; 210105 KPa: Modified for distance version
;;

	;; Ange att koden är för thumb mode
	.thumb
	.text
	.align 2

	;; Ange att labbkoden startar här efter initiering
	.global	main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Ange vem som skrivit koden
;;               student LiU-ID: Hanwi495
;; + ev samarbetspartner LiU-ID: Petsv206
;;
;; Placera programmet här

invalidcodestring .string "Felaktig kod! "

main:				; Start av programmet
	bl inituart		;initiera systemet
	bl initGPIOF
	bl initGPIOE
	mov r10,#(0x20001013 & 0xffff) ;Ladda lösenkoden på dess respektive minnesadresser
	movt r10,#(0x20001013 >> 16)
	mov r11,#0x02
	strb r11,[r10]

	mov r10,#(0x20001012 & 0xffff)
	movt r10,#(0x20001012 >> 16)
	mov r11,#0x01
	strb r11,[r10]

	mov r10,#(0x20001011 & 0xffff)
	movt r10,#(0x20001011 >> 16)
	mov r11,#0x01
	strb r11,[r10]

	mov r10,#(0x20001010 & 0xffff)
	movt r10,#(0x20001010 >> 16)
	mov r11,#0x02
	strb r11,[r10]
	b startmainloop

init:
	bl clearinput ;Rensa buffern samt deaktivera alarmet
	bl deactivatealarm
	mov r12, #0 ;Rensa antalet keyinputs i deaktiverade läget.
deactivatedloop:
	bl getkey
	bl validkey
	cmp r6, #0x1
	bne skipinvalidinput
	bl addkey
	add r12,r12,#1
skipinvalidinput:
	cmp r4, #0xC
	bne checkinputforA
	cmp r12, #0x8
	bne startmainloop
	bl changepasswordcheck
	cmp r4, #0x1
	bne init
	bl changepassword
	bl clearinput
	b startmainloop
checkinputforA:
	cmp r4, #0xA
	bne deactivatedloop
startmainloop:
	bl activatealarm

mainloop:
	bl getkey
	cmp r4, #0xF
	beq checkcodeinput
	bl addkey
	b mainloop
checkcodeinput:
	bl checkcode
	cmp r4, #0x1
	beq init
	.align 2
	adr r4,invalidcodestring
	.align 2
	mov r5,#0xE
	bl printstring
	bl clearinput
	b mainloop


printstring: ;; R4 ska vara laddad med en string samt r5 med längden på stringen
	push {lr}
	mov r6, #0x0
printloop:
	ldrb r0, [r4]
	bl printchar
	add r4, r4, #1
	subs r5, r5, #1
	cmp r5, #0
	bne printloop
	pop {lr}
	bx lr

deactivatealarm: ;Avaktivera alarmet
	mov r1, #(GPIOF_GPIODATA & 0xffff)
	movt r1, #(GPIOF_GPIODATA >> 16)
	mov r0, #0x08
	str r0, [r1]
	bx lr

activatealarm: ;Aktivera alarmet
	mov r1, #(GPIOF_GPIODATA & 0xffff)
	movt r1, #(GPIOF_GPIODATA >> 16)
	mov r0, #0x02
	str r0, [r1]
	bx lr

getkey: ;Hämta knappen som tryckts ner
	mov r1, #(GPIOE_GPIODATA & 0xffff)
	movt r1, #(GPIOE_GPIODATA >> 16)
waitforpress:
	ldr r4, [r1]
	ands r4, #0x10
	beq waitforpress
waitforrelease:
	ldr r4, [r1]
	ands r4, #0x10
	bne waitforrelease
	ldr r4, [r1]
	bx lr

validkey: ;Kollar om knapptrycket får vara med i nya lösenordet
	cmp r4, #0xA
	beq invalidkey
	cmp r4, #0xB
	beq invalidkey
	cmp r4, #0xC
	beq invalidkey
	cmp r4, #0xD
	beq invalidkey
	cmp r4, #0xE
	beq invalidkey
	cmp r4, #0xF
	beq invalidkey
	mov r6, #0x1
	bx lr
invalidkey:
	push{lr}
	mov r6, #0x0
	pop{lr}
	bx lr

addkey: ;Lägg till nyckeln i den första minnesadressen och flytta fram resten
	mov r0,#(0x20001000 & 0xffff) ;8 minnesadresser används för att kunna byta lösenord
	movt r0,#(0x20001000 >> 16)

	mov r1,#(0x20001001 & 0xffff)
	movt r1,#(0x20001001 >> 16)

	mov r2,#(0x20001002 & 0xffff)
	movt r2,#(0x20001002 >> 16)

	mov r3,#(0x20001003 & 0xffff)
	movt r3,#(0x20001003 >> 16)

	mov r6,#(0x20001004 & 0xffff)
	movt r6,#(0x20001004 >> 16)

	mov r7,#(0x20001005 & 0xffff)
	movt r7,#(0x20001005 >> 16)

	mov r8,#(0x20001006 & 0xffff)
	movt r8,#(0x20001006 >> 16)

	mov r9,#(0x20001007 & 0xffff)
	movt r9,#(0x20001007 >> 16)


	ldrb r5,[r8] ; Vi flyttar fram varje sparat värde en plats i minnesaddresserna
	strb r5,[r9] ; Värdet på plats 0x20001007 försvinner.
	ldrb r5,[r7]
	strb r5,[r8]
	ldrb r5,[r6]
	strb r5,[r7]
	ldrb r5,[r3]
	strb r5,[r6]
	ldrb r5,[r2]
	strb r5,[r3]
	ldrb r5,[r1]
	strb r5,[r2]
	ldrb r5,[r0]
	strb r5,[r1]

	strb r4,[r0] ; värdet från knapptrycket sparas på minnesadress 0x20001000

	bx lr

clearinput: ;Rensa de spara knapptrycken som behövs
	mov r0,#(0x20001000 & 0xffff)
	movt r0,#(0x20001000 >> 16)

	mov r1,#(0x20001001 & 0xffff)
	movt r1,#(0x20001001 >> 16)

	mov r2,#(0x20001002 & 0xffff)
	movt r2,#(0x20001002 >> 16)

	mov r3,#(0x20001003 & 0xffff)
	movt r3,#(0x20001003 >> 16)

	mov r8, #0xFF
	strb r8,[r0]
	strb r8,[r1]
	strb r8,[r2]
	strb r8,[r3]

	bx lr

checkcode: ;Kollar om inmatningssekvensen överensstämmer med lösenkoden
	mov r0,#(0x20001000 & 0xffff)
	movt r0,#(0x20001000 >> 16)
	mov r1,#(0x20001010 & 0xffff)
	movt r1,#(0x20001010 >> 16)

	ldr r8, [r0]
	ldr r9, [r1]
	cmp r8, r9
	bne invalidcode
	mov r4, #0x1
	bx lr
invalidcode:
	push{lr}
	mov r4, #0x0
	pop{lr}
	bx lr

changepasswordcheck: ;Kollar om de nya lösenordet är giltigt (D.v.s överensstämmer med sekvensen innan).
	mov r0,#(0x20001000 & 0xffff)
	movt r0,#(0x20001000 >> 16)
	mov r1,#(0x20001004 & 0xffff)
	movt r1,#(0x20001004 >> 16)
	ldr r8, [r0]
	ldr r9, [r1]
	cmp r8, r9
	bne invalidcodeinput
	mov r4, #0x1
	bx lr
invalidcodeinput:
	push{lr}
	mov r4, #0x0
	pop{lr}
	bx lr

changepassword: ;Ändrar lösenordet till det nya inmatade lösenordet
	mov r1,#(0x20001003 & 0xffff)
	movt r1,#(0x20001003 >> 16)
	mov r10,#(0x20001013 & 0xffff)
	movt r10,#(0x20001013 >> 16)
	ldrb r11,[r1]
	strb r11,[r10]

	mov r1,#(0x20001002 & 0xffff)
	movt r1,#(0x20001002 >> 16)
	mov r10,#(0x20001012 & 0xffff)
	movt r10,#(0x20001012 >> 16)
	ldrb r11,[r1]
	strb r11,[r10]

	mov r1,#(0x20001001 & 0xffff)
	movt r1,#(0x20001001 >> 16)
	mov r10,#(0x20001011 & 0xffff)
	movt r10,#(0x20001011 >> 16)
	ldrb r11,[r1]
	strb r11,[r10]

	mov r1,#(0x20001000 & 0xffff)
	movt r1,#(0x20001000 >> 16)
	mov r10,#(0x20001010 & 0xffff)
	movt r10,#(0x20001010 >> 16)
	ldrb r11,[r1]
	strb r11,[r10]
	bx lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;;
;;; Allt här efter ska inte ändras
;;;
;;; Rutiner för initiering
;;; Se labmanual för vilka namn som ska användas
;;;
	
	.align 4

;; 	Initiering av seriekommunikation
;;	Förstör r0, r1 
	
inituart:
	mov r1,#(RCGCUART & 0xffff)		; Koppla in serieport
	movt r1,#(RCGCUART >> 16)
	mov r0,#0x01
	str r0,[r1]

	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x01
	str r0,[r1]		; Koppla in GPIO port A

	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOA_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOA_GPIOAFSEL >> 16)
	mov r0,#0x03
	str r0,[r1]		; pinnar PA0 och PA1 som serieport

	mov r1,#(GPIOA_GPIODEN & 0xffff)
	movt r1,#(GPIOA_GPIODEN >> 16)
	mov r0,#0x03
	str r0,[r1]		; Digital I/O på PA0 och PA1

	mov r1,#(UART0_UARTIBRD & 0xffff)
	movt r1,#(UART0_UARTIBRD >> 16)
	mov r0,#0x08
	str r0,[r1]		; Sätt hastighet till 115200 baud
	mov r1,#(UART0_UARTFBRD & 0xffff)
	movt r1,#(UART0_UARTFBRD >> 16)
	mov r0,#44
	str r0,[r1]		; Andra värdet för att få 115200 baud

	mov r1,#(UART0_UARTLCRH & 0xffff)
	movt r1,#(UART0_UARTLCRH >> 16)
	mov r0,#0x60
	str r0,[r1]		; 8 bit, 1 stop bit, ingen paritet, ingen FIFO
	
	mov r1,#(UART0_UARTCTL & 0xffff)
	movt r1,#(UART0_UARTCTL >> 16)
	mov r0,#0x0301
	str r0,[r1]		; Börja använda serieport

	bx  lr

; Definitioner för registeradresser (32-bitars konstanter) 
GPIOHBCTL	.equ	0x400FE06C
RCGCUART	.equ	0x400FE618
RCGCGPIO	.equ	0x400fe608
UART0_UARTIBRD	.equ	0x4000c024
UART0_UARTFBRD	.equ	0x4000c028
UART0_UARTLCRH	.equ	0x4000c02c
UART0_UARTCTL	.equ	0x4000c030
UART0_UARTFR	.equ	0x4000c018
UART0_UARTDR	.equ	0x4000c000
GPIOA_GPIOAFSEL	.equ	0x40004420
GPIOA_GPIODEN	.equ	0x4000451c
GPIOE_GPIODATA	.equ	0x400240fc
GPIOE_GPIODIR	.equ	0x40024400
GPIOE_GPIOAFSEL	.equ	0x40024420
GPIOE_GPIOPUR	.equ	0x40024510
GPIOE_GPIODEN	.equ	0x4002451c
GPIOE_GPIOAMSEL	.equ	0x40024528
GPIOE_GPIOPCTL	.equ	0x4002452c
GPIOF_GPIODATA	.equ	0x4002507c
GPIOF_GPIODIR	.equ	0x40025400
GPIOF_GPIOAFSEL	.equ	0x40025420
GPIOF_GPIODEN	.equ	0x4002551c
GPIOF_GPIOLOCK	.equ	0x40025520
GPIOKEY		.equ	0x4c4f434b
GPIOF_GPIOPUR	.equ	0x40025510
GPIOF_GPIOCR	.equ	0x40025524
GPIOF_GPIOAMSEL	.equ	0x40025528
GPIOF_GPIOPCTL	.equ	0x4002552c

;; Initiering av port F
;; Förstör r0, r1, r2
initGPIOF:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x20		; Koppla in GPIO port F
	str r0,[r1]
	nop 			; Vänta lite
	nop
	nop

	mov r1,#(GPIOHBCTL & 0xffff)	; Använd apb för GPIO
	movt r1,#(GPIOHBCTL >> 16)
	ldr r0,[r1]
	mvn r2,#0x2f		; bit 5-0 = 0, övriga = 1
	and r0,r0,r2
	str r0,[r1]

	mov r1,#(GPIOF_GPIOLOCK & 0xffff)
	movt r1,#(GPIOF_GPIOLOCK >> 16)
	mov r0,#(GPIOKEY & 0xffff)
	movt r0,#(GPIOKEY >> 16)
	str r0,[r1]		; Lås upp port F konfigurationsregister

	mov r1,#(GPIOF_GPIOCR & 0xffff)
	movt r1,#(GPIOF_GPIOCR >> 16)
	mov r0,#0x1f		; tillåt konfigurering av alla bitar i porten
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAMSEL >> 16)
	mov r0,#0x00		; Koppla bort analog funktion
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPCTL & 0xffff)
	movt r1,#(GPIOF_GPIOPCTL >> 16)
	mov r0,#0x00		; använd port F som GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIODIR & 0xffff)
	movt r1,#(GPIOF_GPIODIR >> 16)
	mov r0,#0x0e		; styr LED (3 bits), andra bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPUR & 0xffff)
	movt r1,#(GPIOF_GPIOPUR >> 16)
	mov r0,#0x11		; svag pull-up för tryckknapparna
	str r0,[r1]

	mov r1,#(GPIOF_GPIODEN & 0xffff)
	movt r1,#(GPIOF_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar som digital I/O
	str r0,[r1]

	bx lr


;; Initiering av port E
;; Förstör r0, r1
initGPIOE:
	mov r1,#(RCGCGPIO & 0xffff)    ; Clock gating port (slå på I/O-enheter)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x10		; koppla in GPIO port B
	str r0,[r1]
	nop			; vänta lite
	nop
	nop

	mov r1,#(GPIOE_GPIODIR & 0xffff)
	movt r1,#(GPIOE_GPIODIR >> 16)
	mov r0,#0x0		; alla bitar är ingångar
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar är GPIO
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAMSEL >> 16)
	mov r0,#0x00		; använd inte analoga funktioner
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPCTL & 0xffff)
	movt r1,#(GPIOE_GPIOPCTL >> 16)
	mov r0,#0x00		; använd inga specialfunktioner på port B	
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPUR & 0xffff)
	movt r1,#(GPIOE_GPIOPUR >> 16)
	mov r0,#0x00		; ingen pullup på port B
	str r0,[r1]

	mov r1,#(GPIOE_GPIODEN & 0xffff)
	movt r1,#(GPIOE_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar är digital I/O
	str r0,[r1]

	bx lr


;; Utskrift av ett tecken på serieport
;; r0 innehåller tecken att skriva ut (1 byte)
;; returnerar först när tecken skickats
;; förstör r0, r1 och r2 
printchar:
	mov r1,#(UART0_UARTFR & 0xffff)	; peka på serieportens statusregister
	movt r1,#(UART0_UARTFR >> 16)
loop1:
	ldr r2,[r1]			; hämta statusflaggor
	ands r2,r2,#0x20		; kan ytterligare tecken skickas?
	bne loop1			; nej, försök igen
	mov r1,#(UART0_UARTDR & 0xffff)	; ja, peka på serieportens dataregister
	movt r1,#(UART0_UARTDR >> 16)
	str r0,[r1]			; skicka tecken
	bx lr




