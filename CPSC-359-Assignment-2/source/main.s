//LAMESS KHARFAN AND SHANNON TJ
//CPSC 359 ASSIGNMENT 2
//FEBRUARY 25, 2016 

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
    	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART
	
	//Print program author's names to the screen
	ldr	r0, =creatorNames
	mov	r1, #53
	bl	WriteStringUART

reloopProgram:
	//Clear all registers
	mov 	r0, #0
	mov 	r1, #0
	mov 	r2, #0
	mov 	r3, #0
	mov 	r4, #0
	mov 	r5, #0
	mov 	r6, #0
	mov 	r7, #0
	mov 	r8, #0
	mov 	r9, #0
	mov 	r10, #0
	mov 	r11, #0
	mov 	r12, #0
	
	//Print student prompt
	ldr	r0, =studentPrompt
	mov	r1, #37
	bl	WriteStringUART
	
	//Read the number of students from the user
	ldr	r0, =ABuff
	mov 	r1, #256
	bl	ReadLineUART

	bl 	studentRoutine

	//r3 = sum
	//r4 = increment counter
	mov	r3, #0 
	mov	r4, #1 

gradeLoop:
	//COUNTER < STUDENTS?
	cmp	r4, r12
	bgt	preAvg
	
	cmp	r4, #1
	beq	grade1

	cmp	r4, #2
	beq 	grade2

	cmp	r4, #3
	beq	grade3

	cmp	r4, #4
	beq 	grade4

	cmp	r4, #5
	beq	grade5

	cmp	r4, #6
	beq 	grade6

	cmp	r4, #7
	beq	grade7

	cmp	r4, #8
	beq 	grade8

	cmp	r4, #9
	beq	grade9

//PRINT GRADE PROMPTS
grade1:
	ldr	r0, =gradePrompt1
	mov	r1, #45
	bl	WriteStringUART

	b	readGrade

grade2:
	ldr	r0, =gradePrompt2
	mov	r1, #46
	bl	WriteStringUART
	
	b	readGrade

grade3:
	ldr	r0, =gradePrompt3
	mov	r1, #45
	bl	WriteStringUART
	
	b	readGrade

grade4:
	ldr	r0, =gradePrompt4
	mov	r1, #46
	bl	WriteStringUART
	
	b	readGrade

grade5:
	ldr	r0, =gradePrompt5
	mov	r1, #45
	bl	WriteStringUART
	
	b	readGrade

grade6:
	ldr	r0, =gradePrompt6
	mov	r1, #45
	bl	WriteStringUART
	
	b	readGrade

grade7:
	ldr	r0, =gradePrompt7
	mov	r1, #47
	bl	WriteStringUART
	
	b	readGrade

grade8:
	ldr	r0, =gradePrompt8
	mov	r1, #45
	bl	WriteStringUART
	
	b	readGrade

grade9:
	ldr	r0, =gradePrompt9
	mov	r1, #45
	bl	WriteStringUART
	
	b	readGrade

readGrade:
	//Read the grade from the user
	ldr	r0, =ABuff
	mov	r1, #256
	bl	ReadLineUART 

	bl 	gradeRoutine

	//r3 = sum
	//r4 = increment counter
	add	r3, r3, r5	
	add 	r4, r4, #1	
	
	b	gradeLoop

preAvg:
	//MOVES VALUES, SETS UP THE AVERAGE	
	//r5 = sum
	//r6 = average
	mov	r5, r3
	mov	r6, #0

	//r7 = scratch value that is being divided 
	mov	r7, r3

	//r8 = number to divide by
	mov	r8, r4
	sub 	r8, r8, #1 
	
calcAvg:
	//CALCULATE THE AVERAGE	
	//r7 is now a garbage signed number, do not use
	cmp	r7, #0
	ble	printSum

	sub	r7, r7, r8
	add	r6, r6, #1
	b	calcAvg
	
printSum:
	//PRINT THE SUM
	ldr	r0, =sumOfGrades
	mov	r1, #12
	bl	WriteStringUART

	//r10 = sum
	//r11 = counter
	mov	r10, r5
	mov	r11, #0
	
	bl 	asciiRoutine

printAvg:
	//PRINT THE AVERAGE
	ldr	r0, =averageGrade
	mov	r1, #16
	bl	WriteStringUART

	//r10 = average
	//r11 = counter
	mov 	r10, r6
	add	r11, r11, #1
	
	bl 	asciiRoutine
	
restart:
	//RESTART THE ENTIRE PROGRAM
	b	reloopProgram
	

//SUBROUTINES:
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
	
studentRoutine:
	mov 	r12, #0
	//r8 = # of characters read
	//r7 = the power #
	//r6 = increment counter
	mov	r8, r0 	
	sub 	r7, r0, #1
	mov 	r6, #0

	//Check for spacebar/empty input
	cmp	r8, #0
	beq	studentError1
	
readLoop:
	//READ EVERY CHARACTER	
	cmp 	r6, r8
	bge	finalNum
	
	//r9 = ASCII value
	ldr	r0, =ABuff
	ldrb	r9, [r0, r6]
	
	//ERROR TEST 1 (non-integer values?)
	cmp	r9, #48
	blt	studentError1
	cmp 	r9, #57
	bgt	studentError1

	//r9 = integer value
	sub	r9, r9, #48	
	mov	r10, #1
	mov 	r11, #10
	
powerLoop:
	//CALCULATE POWER OF 10
	cmp	r7, #0
	beq	append
	
	mul 	r10, r10, r11
	sub 	r7, #1
	
	b	powerLoop

append:
	//FINAL INTEGER IN ONE REGISTER
	
	//r9 = r9 x power of 10
	mul 	r9, r9, r10
	//r12 = final integer value
	add	r12, r12, r9 	
	add	r6, #1	

	//Read next character
	b 	readLoop 

finalNum:
	//ERROR TEST 2 (out of bounds?)
	cmp	r12, #0
	beq	studentError2
	
	cmp 	r12, #9
	bgt	studentError2

	//Input has been read, meets the conditions
	mov 	pc, lr

studentError1:
	//writeUART error message
	ldr	r0, =invalidFormat
	mov	r1, #22
	bl	WriteStringUART
	
	b	reloopProgram
studentError2:
	//writeUART error message
	ldr	r0, =invalidStudent
	mov	r1, #66
	bl	WriteStringUART
	
	b 	reloopProgram

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
	
gradeRoutine:
	mov 	r5, #0
	//r8 = # of characters read
	//r7 = the power #
	//r6 = increment counter
	mov	r8, r0 	
	sub 	r7, r0, #1
	mov 	r6, #0

	//Check for spacebar/empty input
	cmp	r8, #0
	beq	gradeError1
	
readLoop2:
	//READ EVERY CHARACTER	
	cmp 	r6, r8
	bge	finalNum2
	
	//r9 = ASCII value
	ldr	r0, =ABuff
	ldrb	r9, [r0, r6]
	
	//ERROR TEST 1 (non-integer values?)
	cmp	r9, #48
	blt	gradeError1
	cmp 	r9, #57
	bgt	gradeError1

	//r9 = integer value
	sub	r9, r9, #48	
	mov	r10, #1
	mov 	r11, #10
	
powerLoop2:
	//CALCULATE POWER OF 10
	cmp	r7, #0
	beq	append2
	
	mul 	r10, r10, r11
	sub 	r7, #1
	
	b	powerLoop2

append2:
	//FINAL INTEGER IN ONE REGISTER
	
	//r9 = r9 x power of 10
	mul 	r9, r9, r10
	//r5 = final integer value
	add	r5, r5, r9 	
	add	r6, #1	

	//Read next character
	b 	readLoop2 

finalNum2:
	//ERROR TEST 2 (out of bounds?)
	cmp 	r5, #0
	blt	gradeError2

	cmp 	r5, #100
	bgt	gradeError2

	//Input has been read, meets the conditions
	mov 	pc, lr

gradeError1:
	//writeUART error message
	ldr	r0, =invalidFormat
	mov	r1, #22
	bl	WriteStringUART
	
	b	gradeLoop
gradeError2:
	//writeUART error message
	ldr	r0, =invalidGrade
	mov	r1, #62
	bl	WriteStringUART
	
	b 	gradeLoop

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

asciiRoutine:
	//Check number of digits
	mov	r9, #0 
	
	cmp 	r10, #100
	bge	threeDigits

	cmp 	r10, #10
	bge 	twoDigits

	b	oneDigit

threeDigits:
	//Get the hundreds digit
	sub	r10, r10, #100
	add	r9, r9, #1

	cmp	r10, #100
	blt	printThree

	b	threeDigits

printThree:
	//Print the hundreds digit
	add	r9, r9, #48
	strb 	r9, [r9]
	
	ldrb	r0, [r9]
	mov	r1, #1
	bl 	WriteStringUART

	//Reset value in r9
	mov	r9, #0 
	b	twoDigits
	
twoDigits:
	//Get the tens digit (when equal to zero i.e. 101)
	cmp	r10, #10
	blt	printTwo

twoNonzero:
	//Get the tens digit (when nonzero i.e. 110)
	sub	r10, r10, #10
	add	r9, r9, #1

	cmp	r10, #10
	blt	printTwo

	b	twoNonzero

printTwo:
	//Print the tens digit
	add 	r9, r9, #48
	strb	r9, [r9]
	
	ldrb	r0, [r9]
	mov	r1, #1
	bl 	WriteStringUART

	b	oneDigit
	
oneDigit:	
	//Get and print the unit digit
	add	r10, r10, #48
	strb	r10, [r10]

	ldrb	r0, [r10]
	mov	r1, #1
	bl 	WriteStringUART

	ldr	r0, =newLine
	mov	r1, #2
	bl	WriteStringUART

	//The mov pc,lr instruction did not work here
	cmp	r11, #1
	blt	printAvg

	b	restart

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

.section .data

//STRINGS TO BE PRINTED	
 
creatorNames:
	.ascii "Created by: Lamess Kharfan and Shannon Tucker-Jones\n\r"

gradePrompt1:
	.ascii	"Please enter the grade of the first student: "  

gradePrompt2:
	.ascii	"Please enter the grade of the second student: " 

gradePrompt3:
	.ascii	"Please enter the grade of the third student: " 

gradePrompt4:
	.ascii	"Please enter the grade of the fourth student: "

gradePrompt5:
	.ascii	"Please enter the grade of the fifth student: " 

gradePrompt6:
	.ascii	"Please enter the grade of the sixth student: " 

gradePrompt7:
	.ascii	"Please enter the grade of the seventh student: " 

gradePrompt8:
	.ascii	"Please enter the grade of the eigth student: "

gradePrompt9:
	.ascii	"Please enter the grade of the ninth student: " 

studentPrompt:
	.ascii "Please enter the number of students: "

invalidFormat:
	.ascii "Wrong number format!\n\r"
	
invalidStudent:
	.ascii "Invalid number! The number of students should be between 1 and 9\n\r" 

invalidGrade:
	.ascii "Invalid number! The number grade should be between 0 and 100\n\r"

sumOfGrades:
	.ascii "The sum is: " 

averageGrade:
	.ascii "The average is: " 

newLine:
	.ascii "\n\r"

ABuff:
	.rept	256 
	.byte 	0
	.endr
