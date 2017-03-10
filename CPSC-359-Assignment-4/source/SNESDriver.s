
	
//SNES DRIVER
.globl getInput
getInput:
	
	push 	{lr}
	mov	r9, #0
	
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
	//lsl	r7, r7, #8		//r7 = 0xff00
	//orr 	r7, r7, #0xff		//r7 = 0xffff
	
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
	add	r9, #1
	cmp	r9, #0x1000		//r0 < 0x300000?
	blt	prePulse
	bge 	updateButtonPress	//reset pulse values			

	
//SUBROUTINES:
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl initGPIO	
initGPIO:
	//CHECK LINE NUMBER
	push 	{lr}
	
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

	pop	{lr}
	mov 	pc, lr			//back to main routine
	
lineTen:	
	//GPIO 10 (DATA, INPUT)
	ldr	r0, =0x20200004		//r0 = base address (pins 10-19)
	ldr	r1, [r0]		//r1 = base address

	mov	r2, #0b111		//r2 = clear mask
	bic	r1, r2			//r1 = bitcleared

	mov	r2, r3			//r2 = input function code
	
	orr	r1, r2			//r1 = GPIO address, output written
	str	r1, [r0] 		//store register to memory

	pop	{lr}
	mov 	pc, lr			//back to main routine
	
lineEleven:	
	//GPIO 11 (CLOCK, OUTPUT)
	ldr	r0, =0x20200004		//r0 = base address (pins 10-19)
	ldr	r1, [r0]		//r1 = base address

	mov	r2, #0b111		//r2 = clear mask
	bic	r1, r2, lsl #3		//r1 = bitcleared

	mov	r2, r3			//r2 = output function code
	
	orr	r1, r2, lsl #3		//r1 = GPIO address, output written
	str	r1, [r0] 		//store register to memory

	pop	{lr}
	mov 	pc, lr			//back to main routine
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl writeLatch
writeLatch:
	push 	{lr}
	
	//WRITE 1 OR 0 TO THE LATCH
	mov	r0, #9			//r0 = pin 9, latch line
	ldr 	r2, =0x20200000		//r2 = base GPIO register
	mov 	r3, #1			//r3 = 1
	lsl	r3, r0			//r3 = aligned for pin 9
	
	teq	r1, #0			//check the value to write 
	
	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	pop	{lr}
	mov 	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl writeClock
writeClock:
	push 	{lr}
	
	//WRITE 1 OR 0 TO THE CLOCK
	mov	r0, #11			//r0 = pin 11, clock line
	ldr 	r2, =0x20200000		//r2 = base GPIO register
	mov 	r3, #1			//r3 = 1
	lsl	r3, r0			//r3 = aligned for pin 11
	
	teq	r1, #0			//check the value to write
	
	streq	r3, [r2, #40]		//r3 = GPCLR0, clear the line
	strne	r3, [r2, #28]		//r3 = GPSET0, set the line

	pop	{lr}
	mov 	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl readData
readData:
	push	{lr}
	
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

	pop	{lr}
	mov	pc, lr			//back to main routine

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
.globl wait
wait:
	push	{lr}
	
	//WAIT A SPECIFIED NUMBER OF MICROSECONDS
	ldr	r2, =0x20003004		//timer address
	ldr	r1, [r2]		//r1 = current time
	add	r3, r1, r0		//r3 = current time + delay

waitLoop:
	//CURRENT TIME < CURRENT TIME + DELAY?
	cmp	r3, r1			
	blt	waitLoop
	
	pop	{lr}
	mov 	pc, lr			//back to main routine
		
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl readSNES
readSNES:
	push 	{lr}
	
	//READS BUTTONS PRESSED ON SNES
	lsl 	r6, r6, #1		//shift left by one position
	
	cmp 	r4, #1			//r4 = 1?
	beq	addOne

	pop	{lr}
	mov 	pc, lr			//back to main routine
	
addOne:	
	add	r6, r6, #1		//r6 = r6 + 1
	pop	{lr}
	mov 	pc, lr			//back to main routine
	
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

.globl updateButtonPress
updateButtonPress:
	//UPDATE BUTTON PRESS, RETURN THE BUTTON PRESSED
	ldr 	r5, =buttonPress
	
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

	//Check for no input
	mov	r7, #0xff
	lsl 	r7, r7, #8
	orr 	r7, r7, #0xff

	cmp 	r6, r7
	beq	pressNothing


	b 	pressOther

pressUp:
	mov 	r6, #2
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressDown:
	mov 	r6, #3
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressLeft:
	mov 	r6, #1
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressRight:
	mov 	r6, #0
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressA:
	mov 	r6, #4
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressNothing:
	//Executes when nothing pressed
	mov 	r6, #7
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressOther:
	//Executes when pressing nothing/undefined buttons
	mov 	r6, #6
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr

pressStart:	
	mov 	r6, #5
	str	r6, [r5]
	pop	{lr}
	mov 	pc, lr
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
.section .data

.globl buttonPress
buttonPress:	.word 	0					//0 = Right
.align 4							//1 = Left
							        //2 = Up
								//3 = Down
								//4 = A
								//5 = Start
								//6 = Nothing	


