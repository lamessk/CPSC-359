.section .text

//PRINT "LIVES:"
.globl startLives
startLives:
	push	{lr}
	ldr	r0, =endLives		//r0 = address of EndLives
	ldr	r4, =lives		//r1 = address of lives[0]
	mov	r9, #50			//r9 = initial y coordinate
	mov	r10, #250		//r10 = register for spacing characters/initial x coordinate
loopLives:
	ldrb	r11, [r4], #1 		//r11 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, #10		//Increment spacing between chars	

	cmp	r0, r4			//reached end of array?
	bne 	loopLives		//loop until reach array end
	popeq 	{lr}
	moveq	pc, lr


//PRINT "SCORE:"
.globl startScore
startScore:
	push 	{r9-r11,lr}
	ldr	r0, =endScore	
	ldr	r1, =score	
	mov	r9, #50			
	mov	r10, #620	
loopScore:
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char
	add	r10, #10		//Increment spacing between chars	

	cmp	r0, r1			//reached end of array?
	bne 	loopScore		//loop until reach array end
	popeq	{r9-r11,lr}
	moveq	pc, lr

		
//PRINT NUMBER OF LIVES
.globl printLiveNum
printLiveNum:
	push 	{r9-r11,lr}
	ldr	r0, =endLiveNum	
	ldr	r1, =liveNum	
	mov	r9, #50	
	mov	r10, #360	
loopLiveNum:	
	ldrb	r11, [r1], #1 		
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopLiveNum
	popeq	{r9-r11,lr}
	moveq	pc, lr

	
//PRINT NUMBER OF POINTS
.globl printScoreNum
printScoreNum:
	push 	{r9-r11,lr}
	ldr	r0, =endScoreNum	
	ldr	r1, =scoreNum		
	mov	r9, #50			
	mov	r10, #740	
loopScoreNum:	
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopScoreNum
	popeq	{r9-r11,lr}
	moveq	pc, lr

//PRINT PRE-GAME MESSAGE
.globl printReady
printReady:
	push 	{r9-r11, lr}
	ldr	r0, =endReady
	ldr 	r1, =getReady
	mov 	r9, #400
	mov 	r10, #440
loopReady:	
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopReady
	popeq	{r9-r11,lr}
	moveq	pc, lr

//PRINT GAME OVER MESSAGE
.globl printLose
printLose:
	push 	{r9-r11, lr}
	ldr	r0, =endLose
	ldr 	r1, =lose
	mov 	r9, #400
	mov 	r10, #440
loopLose:	
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopLose
	popeq	{r9-r11,lr}
	moveq	pc, lr


//PRINT WINNING MESSAGE
.globl printWin
printWin:
	push 	{r9-r11, lr}
	ldr	r0, =endWin
	ldr 	r1, =win
	mov 	r9, #400
	mov 	r10, #440
loopWin:	
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopWin
	popeq	{r9-r11,lr}
	moveq	pc, lr

//PRINT GAME OVER MESSAGE
.globl printOver
printOver:
	push 	{r9-r11, lr}
	ldr	r0, =endOver
	ldr 	r1, =gameOver
	mov 	r9, #400
	mov 	r10, #440
loopOver:	
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char	
	add	r10, #10		//Increment spacing between chars
	
	cmp	r0, r1			//reached end of array?
	bne	loopLose
	popeq	{r9-r11,lr}
	moveq	pc, lr
.globl namesLabel
namesLabel:	
	push	{lr}

	ldr	r0, =endNames		//r9 = address of EndNames
	ldr	r4, =names		//r10 = address of names[0]
	mov	r9, #120		//r13 = initial y coordinate
	mov	r10, #400		//r11 = register for spacing characters/initial x coordinate
loopNames:
	ldrb	r11, [r4], #1 		//r12 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, r10, #10		//Increment spacing between chars	

	cmp	r0, r4			//reached end of array?
	bne 	loopNames			//loop until reach array end

	popeq	{lr}
	moveq	pc, lr
.globl startSG
startSG:
	push	{lr}
	
	ldr	r0, =startGameEnd	//r9 = address of StartGameEnd
	ldr	r4, =startGame		//r10 = address of startGame[0]
	mov	r9, #480		//r13 = Initial y coordinate 
	mov	r10, #340		//r11 = register for spacing characters/where x coordinat begins
loopSG:
	ldrb	r11, [r4], #1 		//r12 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, r10, #10		//Increment spacing between chars	

	cmp	r0, r4			//reached end of array?
	bne 	loopSG			//loop until reach array end
	popeq	{lr}
	moveq	pc, lr
.globl startQG
startQG:	
	push	{lr}

	ldr	r0, =quitGameEnd	//r9 = address of quitGameEnd
	ldr	r4, =quitGame		//r10 = address of quitGame[0]
	mov	r9, #480		//r13 = initial y-coordinate
	mov	r10, #600		//r11 = register for spacing characters
loopQG:
	ldrb	r11, [r4], #1 		//r12 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, r10, #10		//Increment spacing between chars	

	cmp	r0, r4			//reached end of array?
	bne 	loopQG			//loop until reach array end

	popeq	{lr}
	moveq	pc, lr


	
//PRINT "CONTINUE":
.globl printCont
printCont:
	push	{r9-r11,lr}
	ldr	r0, =endCont		//r0 = address of EndContine
	ldr	r1, =cont		//r1 = address of continue[0]
	mov	r9, #372		//r9 = initial y coordinate
	mov	r10, #448		//r10 = register for spacing characters/initial x coordinate
loopCont:
	ldrb	r11, [r1], #1 		//r11 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, #10		//Increment spacing between chars	

	cmp	r0, r1			//reached end of array?
	bne 	loopCont		//loop until reach array end
	popeq 	{r9-r11,lr}
	moveq	pc, lr


//PRINT "QUITGAME":
.globl printQuit
printQuit:
	push 	{r9-r11,lr}
	ldr	r0, =quitGameEnd	
	ldr	r1, =quitGame	
	mov	r9, #432			
	mov	r10, #448	
loopQuit:
	ldrb	r11, [r1], #1 	
	
	bl	DrawChar		//draw char
	add	r10, #10		//Increment spacing between chars	

	cmp	r0, r1			//reached end of array?
	bne 	loopQuit		//loop until reach array end
	popeq	{r9-r11,lr}
	moveq	pc, lr

	
//PRINT "GAME PAUSED":
.globl printPause
printPause:
	push	{r9-r11,lr}
	ldr	r0, =endPaused		//r0 = address of EndContine
	ldr	r1, =paused		//r1 = address of continue[0]
	mov	r9, #320		//r9 = initial y coordinate
	mov	r10, #444		//r10 = register for spacing characters/initial x coordinate
loopPause:
	ldrb	r11, [r1], #1 		//r11 = byte, post increment by 1, contains current char in array
	
	bl	DrawChar		//draw char
	add	r10, #10		//Increment spacing between chars	

	cmp	r0, r1			//reached end of array?
	bne 	loopPause		//loop until reach array end
	popeq 	{r9-r11,lr}
	moveq	pc, lr


// Draw the character to the screen
.globl DrawChar
DrawChar:
	push	{r0-r8, lr}

	chAdr	.req	r4
	px	.req	r5
	py	.req	r6
	row	.req	r7
	mask	.req	r8

	ldr	chAdr,	=font		// load the address of the font map
	mov	r0, r11			// load the character into r0
	add	chAdr,	r0, lsl #4	// char address = font base + (char * 16)

	mov	py, r9			// init the Y coordinate (pixel coordinate)

charLoop$:
	mov	px, r10			// init the X coordinate

	mov	mask,	#0x01		// set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	// load the row byte, post increment chAdr

rowLoop$:
	tst	row,	mask		// test row byte against the bitmask
	beq	noPixel$

	mov	r0, px
	mov	r1, py
	ldr	r2, =0xFFFF		// COLOR
	bl	DrawPixel		// draw white pixel at (px, py)

noPixel$:
	add	px, #1			// increment x coordinate by 1
	lsl	mask, #1		// shift bitmask left by 1

	tst	mask, #0x100		// test if the bitmask has shifted 8 times (test 9th bit)
	beq	rowLoop$

	add	py, #1			// increment y coordinate by 1

	tst	chAdr,	#0xF
	bne	charLoop$		// loop back to charLoop$, unless address evenly divisibly by 16

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop	{r0-r8, lr}
	mov 	pc, lr


.section .data

names:	.byte	'M', 'A', 'D', 'E', ' ', 'B', 'Y', ':', ' ', 'L', 'A', 'M', 'E', 'S', 'S', ' ', 'A', 'N', 'D', ' ', 'S', 'H', 'A', 'N', 'N', 'O', 'N'  				//Array for our names
endNames:				//Dummy label for end of array
.align

quitGame:	.byte	'Q', 'U', 'I', 'T', ' ', 'G', 'A', 'M', 'E'		//Array for "game over"
quitGameEnd:									//Dummy label for end of array
.align

gameOver:	.byte	'G', 'A', 'M', 'E', ' ', 'O', 'V', 'E', 'R', ' '	//Array for "quit game"
endOver:									//Dummy label for end of array
.align

startGame:	.byte	'S', 'T', 'A', 'R', 'T', ' ', 'G', 'A', 'M', 'E'		//Array for "START GAME"
startGameEnd:									//Dummy label for end of array
.align

.align 4
font:		.incbin	"font.bin"
.align 4

.globl scoreNum	
scoreNum:	.byte	'0', '0', '0' 				//Array for number of points
endScoreNum:							//Dummy label for end of array
.align 

.globl liveNum
liveNum:	.byte	'3'  					//Array for number of lives
endLiveNum:							//Dummy label for end of array
.align

lives:		.byte	'L', 'I', 'V', 'E', 'S', ':'  				//Array for lives
endLives:							//Dummy label for end of array
.align

score:		.byte	'S', 'C', 'O', 'R', 'E', ':'  		//Array for score
endScore:							//Dummy label for end of array
.align

getReady:	.byte	'G', 'E', 'T', ' ', 'R', 'E', 'A', 'D', 'Y', '.', '.', '.'	//Array for Get Ready...
endReady:										//Dummy label for end of array
.align 

lose:		.byte	'Y', 'O', 'U', ' ', 'L', 'O', 'S', 'E'  	//Array for Loss
endLose:							//Dummy label for end of array
.align 

win:		.byte	'Y', 'O', 'U', ' ', 'W', 'I', 'N', '!', '!', '!' //Array for Win
endWin:							//Dummy label for end of array


cont:		.byte	'R', 'E', 'S', 'T', 'A', 'R', 'T',  ' ', 'G', 'A', 'M', 'E'	//Array for RESTART
endCont:										//Dummy label for end of array
.align	

paused:		.byte	'G', 'A', 'M', 'E', ' ', 'P', 'A', 'U', 'S', 'E', 'D'   //Array for paused
endPaused:									//Dummy label for end of array
.align

	
