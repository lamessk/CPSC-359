//AUTHORS: LAMESS KHARFAN 10150607 AND SHANNON TJ 10101385
//VERSION: MAR 8, 2016
//SOURCES USED: TUTORIALS 5 AND 6 (ANDREW KUIPERS), LECTURES 5 AND 6 (JALAL KAWASH)

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    	mov     sp, #0x8000 		// Initializing the stack pointer
	bl	EnableJTAG 		// Enable JTAG
	bl	InitUART    		// Initialize the UART

	//Print program author's names to the screen
	ldr	r0, =creatorNames
	mov	r1, #53
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
reloop:
	//Please press a button...
	ldr	r0, =pressPrompt
	mov	r1, #26
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART

prePulse:	
	//INITIALIZE SAMPLING BUTTONS 
	mov 	r6, #0 
	
	//INITIALIZE DATA, CLOCK, LATCH LINES
	mov 	r0, #9			//parameter: line number
	mov 	r3, #0b001		//parameter: function code (output)
	bl	initGPIO

	mov 	r0, #10			//parameter: line number
	mov 	r3, #0b000		//parameter: function code (input)
	bl	initGPIO

	mov 	r0, #11			//parameter: line number
	mov 	r3, #0b001		//parameter: function code (output)
	bl	initGPIO	
	
	//CLOCK = 1
	mov 	r1, #1			//parameter: setting line
	bl	writeClock		//set the clock

	//LATCH = 1
	mov 	r1, #1			//parameter: setting line
	bl	writeLatch		//set the latch

	//WAIT TWELVE MICROSECONDS
	mov 	r0, #12			//parameter: length of time
	bl	wait			//wait twelve microseconds

	//LATCH = 0
	mov 	r1, #0 			//parameter: clearing line
	bl	writeLatch		//clear the latch

	mov 	r7, #0xff		//r7 = 0xff
	lsl	r7, r7, #8		//r7 = 0xff00
	orr 	r7, r7, #0xff		//r7 = 0xffff
	
	mov 	r5, #0			//r5 = i = 0
	and 	r6, r6, #0x0 		//r6 = sampling buttons
	mov 	r6, #0xf		//r6 = 0xf
	mov	r8, #0 			//r8 = 0
	
pulseLoop:
	cmp 	r5, #12			//r5 = 12?
	beq 	endPulse
	
	mov 	r0, #6			//parameter: length of time
	bl	wait			//wait six microseconds

	mov 	r1, #0			//parameter: clearing line
	bl 	writeClock		//clear the clock

	mov 	r0, #6 			//parameter: length of time
	bl 	wait			//wait six microseconds

	mov 	r1, r5			//r1 = r5
	bl 	readData 		//read GPIO bit i (r5)

	bl 	readSNES		//r6 = button sequence

	mov 	r1, #1			//parameter: setting line
	bl 	writeClock		//set the clock

	add	r5, r5, #1		//r5 = i++

	b 	pulseLoop		//pulse again

endPulse:	
	cmp	r6, r7			//r6 = 0xffff?
	bge 	prePulse		//reset pulse values
				
					//parameter: r6, button value
	bl 	printMessage		//print button message
	
delay:
	cmp	r8, #0x300000		//r8 < 0x300000?
	beq	reloop			//restart program loop
	add	r8, r8, #1		//r8++
	b	delay			//branch back to delay
	
//SUBROUTINES:
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

	
initGPIO:
	//CHECK LINE NUMBER
	cmp	r0, #9			//r0 = 9?
	beq	lineNine		

	cmp 	r0, #10			//r0 = 10?
	beq 	lineTen

	b 	lineEleven 		//r0 = 11?

lineNine:	
	//GPIO 9 (LATCH, OUTPUT)
	ldr	r0, =0x20200000		//r0 = base address (pins 0-9)
	ldr	r1, [r0]		//r1 = base address

	mov	r2, #0b111		//r2 = clear mask
	bic	r1, r2, lsl #27		//r1 = bitcleared
	
	mov	r2, r3			//r2 = output function code
	
	orr	r1, r2, lsl #27		//r1 = GPIO address, output written
	str	r1, [r0] 		//store register to memory
	
lineTen:	
	//GPIO 10 (DATA, INPUT)
	ldr	r0, =0x20200004		//r0 = base address (pins 10-19)
	ldr	r1, [r0]		//r1 = base address

	mov	r2, #0b111		//r2 = clear mask
	bic	r1, r2			//r1 = bitcleared

	mov	r2, r3			//r2 = input function code
	
	orr	r1, r2			//r1 = GPIO address, output written
	str	r1, [r0] 		//store register to memory
	
lineEleven:	
	//GPIO 11 (CLOCK, OUTPUT)
	ldr	r0, =0x20200004		//r0 = base address (pins 10-19)
	ldr	r1, [r0]		//r1 = base address

	mov	r2, #0b111		//r2 = clear mask
	bic	r1, r2, lsl #3		//r1 = bitcleared

	mov	r2, r3			//r2 = output function code
	
	orr	r1, r2, lsl #3		//r1 = GPIO address, output written
	str	r1, [r0] 		//store register to memory

	mov 	pc, lr			//back to main routine
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

writeLatch:
	//WRITE 1 OR 0 TO THE LATCH
	mov	r0, #9			//r0 = pin 9, latch line
	ldr 	r2, =0x20200000		//r2 = base GPIO register
	mov 	r3, #1			//r3 = 1
	lsl	r3, r0			//r3 = aligned for pin 9
	
	teq	r1, #0			//check the value to write 
	
	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov 	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

writeClock:
	//WRITE 1 OR 0 TO THE CLOCK
	mov	r0, #11			//r0 = pin 11, clock line
	ldr 	r2, =0x20200000		//r2 = base GPIO register
	mov 	r3, #1			//r3 = 1
	lsl	r3, r0			//r3 = aligned for pin 11
	
	teq	r1, #0			//check the value to write
	
	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	mov 	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

readData:
	//READ VALUE IN GPLEV0 
	mov 	r0, #10			//r0 = pin 10, data line
	ldr 	r2, =0x20200000		//r2 = base register
	ldr 	r1, [r2, #52]		//r1 = GPLEV0
	mov 	r3, #1			//r3 = 1
	lsl	r3, r0			//r3 = aligned for pin 10
	
	and 	r1, r3			//mask everything else
	teq	r1, #0			//check GPLEV0 value to read
	
	moveq	r4, #0			//r4 = return 0
	movne	r4, #1			//r4 = return 1

	mov	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

wait:
	//WAIT A SPECIFIED NUMBER OF MICROSECONDS
	ldr	r2, =0x20003004		//timer address
	ldr	r1, [r2]		//r1 = current time
	add	r3, r1, r0		//r3 = current time + delay

waitLoop:
	//CURRENT TIME < CURRENT TIME + DELAY?
	cmp	r3, r1			
	blt	waitLoop
	mov 	pc, lr			//back to main routine
		
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

readSNES:
	//READS BUTTONS PRESSED ON SNES
	lsl 	r6, r6, #1		//shift left by one position
	
	cmp 	r4, #1			//r4 = 1?
	beq	addOne

	mov 	pc, lr			//back to main routine
	
addOne:	
	add	r6, r6, #1		//r6 = r6 + 1
	mov 	pc, lr			//back to main routine
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

printMessage:
	//CHECK WHICH PRINT STATEMENT TO USE

	//You have pressed...
	ldr	r0, =pressButton
	mov	r1, #17
	bl	WriteStringUART

	//Check for B button
	mov 	r7, #0xf7
	lsl	r7, r7, #8
	orr 	r7, r7, #0xff
	
	cmp 	r6, r7
	beq 	pressB

	//Check for Y button
	mov 	r7, #0xfb
	lsl	r7, r7, #8
	orr 	r7, r7, #0xff
	
	cmp 	r6, r7
	beq	pressY

	//Check for select button
	mov 	r7, #0xfd
	lsl	r7, r7, #8
	orr 	r7, r7, #0xff
	
	cmp	r6, r7
	beq	pressSelect

	//Check for start button
	mov 	r7, #0xfe
	lsl	r7, r7, #8
	orr 	r7, r7, #0xff
	
	cmp	r6, r7
	beq	pressStart

	//Check for up
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0x7f
	
	cmp	r6, r7
	beq	pressUp

	//Check for down
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xbf
	
	cmp	r6, r7
	beq 	pressDown

	//Check for left
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xdf
	
	cmp	r6, r7
	beq 	pressLeft

	//Check for right
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xef
	
	cmp	r6, r7
	beq 	pressRight

	//Check for A button
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xf7
	
	cmp	r6, r7
	beq	pressA

	//Check for X button
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xfb
	
	cmp	r6, r7
	beq 	pressX

	//Check for Left trigger
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xfd

	cmp	r6, r7
	beq 	pressL

	//Check for Right trigger
	mov 	r7, #0xff
	lsl	r7, r7, #8
	orr 	r7, r7, #0xfe
	
	cmp	r6, r7
	beq 	pressR

	b 	pressMulti
	
pressB:
	ldr	r0, =buttonB
	mov	r1, #4
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressY:
	ldr	r0, =buttonY
	mov	r1, #4
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressSelect:
	ldr	r0, =select
	mov	r1, #9
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressUp:
	ldr	r0, =jpadUp
	mov	r1, #13
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressDown:
	ldr	r0, =jpadDown
	mov	r1, #15
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressLeft:
	ldr	r0, =jpadLeft
	mov	r1, #15
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressRight:
	ldr	r0, =jpadRight
	mov	r1, #16
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressA:
	ldr	r0, =buttonA
	mov	r1, #4
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressX:
	ldr	r0, =buttonX
	mov	r1, #4
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressL:
	ldr	r0, =triggerLeft
	mov	r1, #15
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressR:
	ldr	r0, =triggerRight
	mov	r1, #16
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressMulti:
	ldr	r0, =multiButtons
	mov	r1, #23
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
	b	delay

pressStart:	
	//Terminate program
	ldr	r0, =start
	mov	r1, #34
	bl	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #1
	bl	WriteStringUART
	
haltLoop:
	b 	haltLoop

	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
	
.section .data

creatorNames:
	.ascii "Created by: Lamess Kharfan and Shannon Tucker-Jones\n\r"

pressPrompt:	
	.ascii "Please press a button...\n\r"  //26

pressButton:	
	.ascii "You have pressed "		//17

jpadRight:	
	.ascii "Joy-pad RIGHT.\n\r"		//16

jpadLeft:	
	.ascii "Joy-pad LEFT.\n\r"		//15

jpadUp:	
	.ascii "Joy-pad UP.\n\r"		//13

jpadDown:	
	.ascii "Joy-pad DOWN.\n\r"		//15

triggerLeft:	
	.ascii "LEFT TRIGGER.\n\r"		//15

triggerRight:	
	.ascii "RIGHT TRIGGER.\n\r"		//16

buttonA:	
	.ascii "A.\n\r"			//4

buttonB:	
	.ascii "B.\n\r"			//4

buttonX:	
	.ascii "X.\n\r"			//4

buttonY:	
	.ascii "Y.\n\r"			//4

select:	
	.ascii "SELECT.\n\r"			//9

start:	
	.ascii "START. Program is terminating...\n\r"	//34

multiButtons:
	.ascii "more than one button.\n\r" //23
	
newLine:	
	.ascii "\n"				//1
