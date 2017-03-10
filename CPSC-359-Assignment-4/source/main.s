/*AUTHORS: SHANNON TJ + LAMESS KHARFAN
CPSC 359 ASSIGNMENT 4-INTERACTIVE VIDE0 GAME SNAKE
VALUE PACK IMPLEMENTED- GET THE BLUE SQUARE AND GAIN A LIFE!

SOURCES: 
FrameBufferPixel.s taken from tut08-ex on D2L by Andrew Kuipers.
Subroutines DrawPixel and DrawChar taken from tut07-ex and tut-7-ex
respectively, on D2L, by Andrew Kuipers. 
ISR based off of tut09-ex example, by Andrew Kuipers. 
font.bin take from tut08-ex.
Images Created by Shannon TJ
*/

.section    .init
.globl     _start

_start:
    b       main
    
.section .text

main:
        bl		InstallIntTable	
	bl		EnableJTAG
	bl		InitFrameBuffer

state0:
	bl	startImage

	bl	namesLabel
	bl	startSG
	bl	startQG

//Draw start screen with arrow next to start Image
state1:

	mov	r0, #568
	mov	r1, #468
	bl	drawOver
	

	mov	r0, #300		//x-cordinate
	mov	r1, #468		//y-cordinate	
	bl	drawArrow

state1Loop:
	bl	getInput

	ldr	r0, =buttonPress
	ldr	r1, [r0]

	//Right D-Pad Pressed?
	cmp	r1, #0
	beq	state2

	//A pressed?
	cmp	r1, #4
	beq	restart
	
	b	state1Loop	
	
state2:
	mov	r0, #300
	mov	r1, #468
	bl	drawOver

	mov	r0, #568		//x-cordinate
	mov	r1, #468		//y-cordinate	
	bl	drawArrow
	

state2Loop:
	bl	getInput

	ldr	r0, =buttonPress
	ldr	r1, [r0]

	//Left Pressed?
	cmp	r1, #1
	beq	state1

	//A pressed?
	cmp	r1, #4
	beq	state11
	
	b	state2Loop

restart:
	//Reset lives
	ldr 		r0, =liveNum
	ldr 		r1, [r0]
	mov 		r2, #51
	str		r2, [r0]

	//Reset score
	ldr 		r0, =scoreNum
	mov 		r1, #48
	strb		r1, [r0], #1
	strb 		r1, [r0]

	//Reset apple eaten
	ldr 		r0, =getItem
	mov		r1, #0
	str		r1, [r0]
	
	//Reset game over flag
	ldr 		r0, =loseGame
	ldr 		r1, [r0]
	mov 		r2, #0
	str 		r2, [r0] 
	
state3:	
	//Print Lives/Score labels and their values
	bl 		clearScreen
	bl 		printReady
	bl 		delay
	bl		clearScreen
	
	bl		startLives
	bl		startScore	
	bl 		printLiveNum
	bl 		printScoreNum
	bl		ISR

	//Draw the game border
	bl 		drawBorder

	//Draw boxes
	bl 		drawBoxes

	//Draw the default snake position
	bl 		defaultSnake

	//Reset movement to right
	ldr 		r0, =oldDirection
	mov 		r1, #0
	str 		r1, [r0]
	
	ldr 		r0, =newDirection
	mov 		r1, #0
	str 		r1, [r0]
	
	//Draw default apple
	ldr 		r3, =apple
	ldr 		r0, [r3], #4
	ldr 		r1, [r3]
	ldr		r2, =0xf000
	bl 		drawCell

	bl 		delay
	
state3Loop:
	//MAIN GAME LOOP
	//bl		ISR
	//Get input
	bl 		getInput
	
	ldr 		r0, =buttonPress
	ldr 		r1, [r0]		
	ldr 		r2, =newDirection

	//Joy pad movement, get direction, store direction
	cmp		r1, #3
	strle 		r1, [r2]	
	
	//Start, open pause screen
	cmp		r1, #5
	beq		state5a

	//Do nothing when r1 = 4, 6

	//Move Snake
	bl 		moveSnake

	//Check for a border collision
	ldr 		r9, =liveNum
	ldr		r10, [r9]

	bl 		collisionBorders

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bgt		state3
	
	//Check wall1 for a wall collision
	ldr 		r1, =wall1
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state3

	//Check wall2 for a wall collision
	ldr 		r1, =wall2
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state3

	//Check wall3 for a wall collision
	ldr 		r1, =wall3
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state3
	
checkLife:	
	//Check life coordinates vs snake coordinates
	ldr 	r0, =extraLife
	ldr 	r1, [r0], #4			//r1 = life (x1)
	ldr 	r2, [r0]			//r2 = life (y1)
	add	r3, r1, #32			//r3 = life (x2)
	add 	r4, r2, #32			//r4 = life (y2)

	bl 		collisionCell

	//If life was collected...
	ldr 		r0, =getItem
	ldr		r1, [r0]
	cmp		r1, #1

	bne 		checkApple
	
	sub		r1, #1
	str		r1, [r0]		//reset life collected

	//Set flag that life was collected
	ldr 		r0, =getLife
	str		r1, [r0]

	//Update life number
	bl	gainLife
	bl	printLiveNum

	//Reset coordinates to 0,0
	ldr 	r0, =extraLife
	mov 	r1, #0
	str 	r1, [r0], #4			//r1 = life (x1)
	str 	r0, [r0]			//r2 = life (y1)

checkApple:
	//Check apple coordinates vs snake coordinates
	ldr 	r0, =apple
	ldr 	r1, [r0], #4			//r1 = apple (x1)
	ldr 	r2, [r0]			//r2 = apple (y1)
	add	r3, r1, #32			//r3 = apple (x2)
	add 	r4, r2, #32			//r4 = apple (y2)
	
	bl		collisionCell
	
	//Check if apple eaten
	ldr 		r0, =getItem
	ldr		r1, [r0]
	cmp		r1, #1

	subeq		r1, #1
	streq		r1, [r0]
	beq 		spawnApple

	b 		checkLoss

//DRAW A NEW APPLE
spawnApple:
	bl 		updateScore
	
	ldr 		r5, =snake

	ldr 		r6, [r5], #4
	ldr 		r7, [r5], #4
	ldr		r8, [r5, #8]
	ldr 		r9, [r5]
	
	//Get X, Y coordinates
	mov		r0, r6			//Parameters: snake head (x)
	mov		r1, r7			//snake head (y)
	mov		r2, r8			//snake tail (x)
	mov		r3, r7			//snake head (y)

	bl 		randomX

	//Store X coordinate
	ldr 	r3, =apple
	str	r0, [r3]
	
	mov		r0, r9			//Parameters: snake tail (y)
	mov		r1, r8			//snake tail (x)
	mov		r2, r7			//snake head (y)
	mov		r3, r8			//snake tail (x)
	
	bl 		randomY

	//Store Y coordinate
	ldr 	r3, =apple
	ldr 	r4, [r3], #4
	str	r0, [r3]

recalcApple:	
	//Check apple is not inside a wall
	ldr 	r0, =apple
	ldr 	r1, [r0], #4		//r1 = apple (x)
	ldr 	r2, [r0]		//r2 = apple (y)
	
	bl 	appleWalls

	//Store new coordinates
	ldr 	r3, =apple
	str 	r1, [r3], #4
	str 	r2, [r3]
	
	//Check if spawn was bad (on top of snake)
	//Recalculate coordinates for apple
	ldr 	r3, =badSpawn
	ldr	r4, [r3]
	
	cmp	r4, #1
	subeq	r4, #1
	streq	r4, [r3]
	beq	recalcApple
	
	//Store new apple coordinates (r1 = x, r2 = y)
	ldr 	r0, =apple
	str	r1, [r0], #4
	str	r2, [r0]

	mov 	r0, r1
	mov 	r1, r2
	
	//Check if door needs to be drawn (score = 210)
	ldr 		r3, =scoreNum
	ldrb 		r4, [r3], #1
	cmp		r4, #50
	bne 		drawApple

	ldrb		r4, [r3]
	cmp		r4, #49
	bne 		drawApple

	//Draw door
	ldr		r2, =0xff00
	bl 		drawCell

	b		state4Loop
	
drawApple:	
	//Draw updated apple
	ldr		r2, =0xf000
	bl 		drawCell

checkLoss:	
	//Check for a game over
	ldr 		r9, =loseGame
	ldr 		r10, [r9]
	cmp		r10, #1
	beq 		state7
	
valueCheck:
	//Check if 20 seconds passed (spawn value pack)
	ldr		r9, =valuePack
	ldr		r10, [r9]
	cmp		r10, #1
	subeq		r10, #1
	streq		r10, [r9]
	beq		state10
	
	b 		state3Loop

//DRAW GAME BOARD, APPLE, DEFAULT SNAKE
state4death:	
	bl 		clearScreen
	bl 		printReady
	bl 		delay
	bl		clearScreen
	
state4:	
	//Print Lives/Score labels and their values
	bl		startLives
	bl		startScore	
	bl 		printLiveNum
	bl 		printScoreNum

	//Draw the game border
	bl 		drawBorder

	//Draw boxes
	bl 		drawBoxes
	
	//Draw the default snake position
	bl 		defaultSnake
	
	//Reset movement to right
	ldr 		r0, =oldDirection
	mov 		r1, #0
	str 		r1, [r0]
	
	ldr 		r0, =newDirection
	mov 		r1, #0
	str 		r1, [r0]
	
	//Store new life coordinates (r1 = x, r2 = y)
	ldr 	r0, =extraLife
	ldr	r1, [r0], #4
	ldr	r2, [r0]

	//Overwrite extra life (no valuepacks once door appears)
	mov 	r0, r1
	mov 	r1, r2
	ldr	r2, =0x0000
	bl 	drawCell

	//Draw default apple
	ldr 		r3, =apple
	ldr 		r0, [r3], #4
	ldr 		r1, [r3]
	ldr		r2, =0xff00
	bl 		drawCell

	bl 		delay
	
state4Loop:
	//MAIN DOOR LOOP
	//VALUE PACKS NO LONGER SPAWN ONCE THE WINNING CONDITION HAS BEEN MET
	
	//Get input
	bl 		getInput
	
	ldr 		r0, =buttonPress
	ldr 		r1, [r0]		//r1 = buttonPress[0]
	ldr 		r2, =newDirection

	cmp		r1, #3
	strle 		r1, [r2]		//store direction
	
	cmp		r1, #5			
	beq		state5a			//branch to pause menu

	//Do nothing when r1 = 4, 6

	//Move Snake
	bl 		moveSnake

	//Check for a border collision
	ldr 		r9, =liveNum
	ldr		r10, [r9]

	bl 		collisionBorders

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bgt		state4death
	
	//Check wall1 for a wall collision
	ldr 		r1, =wall1
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state4death

	//Check wall2 for a wall collision
	ldr 		r1, =wall2
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state4death

	//Check wall3 for a wall collision
	ldr 		r1, =wall3
	bl 		collisionWalls

	ldr 		r7, =liveNum
	ldr 		r8, [r7]

	cmp		r10, r8
	bne		state4death

	//Check apple coordinates vs snake coordinates
	ldr 	r0, =apple
	ldr 	r1, [r0], #4			//r1 = apple (x1)
	ldr 	r2, [r0]			//r2 = apple (y1)
	add	r3, r1, #32			//r3 = apple (x2)
	add 	r4, r2, #32			//r4 = apple (y2)
	
	bl		collisionCell
	
	//Check if "golden apple" (door) is reached
	ldr 		r0, =getItem
	ldr		r1, [r0]
	cmp		r1, #1
	
	beq		state8
	bne 		state4Loop

state5a:
	//Draw the pauseMenu border	
	bl	clearScreenP	
	bl 	drawBorderPause
	bl	printPause	
	bl	printCont
	bl	printQuit

state5b:
	mov	r0, #400	
	mov	r1, #420
	bl	drawOver

	mov	r0, #400
	mov	r1, #368
	bl	drawArrow

state5Loop:
	bl	getInput

	ldr	r0, =buttonPress
	ldr	r1, [r0]

	//Down Pressed?
	cmp	r1, #3
	beq	state6

	//A pressed?
	cmp	r1, #4
	beq	restart

	//Start pressed?
	cmp	r1, #5
	beq 	afterPause


	b	state5Loop

state6:
	mov	r0, #400
	mov	r1, #368
	bl	drawOver

	mov	r0, #400
	mov	r1, #420
	bl	drawArrow

state6Loop:
	bl	getInput

	ldr	r0, =buttonPress
	ldr	r1, [r0]

	//Up pressed?	
	cmp	r1, #2
	beq	state5b

	//A pressed?
	cmp	r1, #4
	beq	state11

	//start pressed?
	cmp	r1, #5
	beq	afterPause

	b	state6Loop

//REDRAW THE GAME BOARD AFTER A PAUSE	
afterPause:
	//Remake the game board

	bl 		clearScreenP
	
	bl		startLives
	bl		startScore	
	bl 		printLiveNum
	bl 		printScoreNum

	//Draw the game border
	bl 		drawBorder

	//Draw boxes
	bl 		drawBoxes

	//Redraw snake
	ldr 		r3, =snake
	ldr		r0, [r3], #4 		
	ldr 		r1, [r3], #4
	ldr 		r2, =0x0bc0

	ldr		r5, [r3], #4 		
	ldr 		r6, [r3], #4

	ldr		r7, [r3], #4		
	ldr 		r8, [r3], #4
	
	bl		drawCell
	
	mov 		r0, r5
	mov 		r1, r6
	ldr		r2, =0x0fe0
	
	bl 		drawCell
	
	mov 		r0, r7
	mov 		r1, r8
	ldr 		r2, =0x0fe0
	
	bl 		drawCell

	//Load life coordinates (r1 = x, r2 = y)
	ldr 	r0, =extraLife
	ldr	r1, [r0], #4
	ldr	r2, [r0]

	cmp	r2, #0
	beq	noPacks 
	
	//Draw extra life
	mov 	r0, r1
	mov 	r1, r2
	ldr	r2, =0x00ff
	bl 	drawCell

noPacks:
	//Load updated apple coordinates
	ldr 		r3, =apple
	ldr		r4, [r3], #4
	ldr		r5, [r3]

//CHECK IF A DOOR, APPLE IS ACTIVE ON THE FIELD	
	ldr 		r0, =scoreNum
	ldrb 		r1, [r0], #1
	cmp		r1, #50
	bne 		redrawApple

	ldrb		r1, [r0]
	cmp		r1, #49
	bne 		redrawApple

	mov		r0, r4
	mov		r1, r5
	ldr		r2, =0xff00
	bl 		drawCell

	b		state4

redrawApple:	
	//Draw updated apple
	mov		r0, r4
	mov		r1, r5
	ldr		r2, =0xf000
	bl 		drawCell

	bl 		delay
	b		state3Loop
	
state7:	
	//Snake dies, game over
	bl 		clearScreen
	bl 		drawLoseImage
	bl 		delay

	b 		state9Loop
state8:
	//Win Game!!!
	bl 		clearScreen
	//bl 		printWin
	
	bl		drawWinImage	
	
	bl 		delay

	b 		state9Loop

//Wait for input to go back to main menu
state9Loop:
	bl 		getInput

	ldr 		r0, =buttonPress
	ldr 		r1, [r0]

	cmp		r1, #6
	ble 		end9Loop
	b		state9Loop
end9Loop:	
	bl		clearScreen
	bl 		delay
	b 		state0

state10:
	//Check if life was collected (or not)
	//bl		ISR	
	ldr 		r0, =getLife
	ldr		r1, [r0]
	cmp		r1, #1
	
	bne 		newLife

	sub 		r1, #1
	str		r1, [r0]

	b 	state3Loop

newLife:	
	//Delete previous life
	ldr 		r0, =extraLife
	ldr 		r1, [r0], #4
	ldr 		r2, [r0]

	mov 		r0, r1
	mov 		r1, r2
	ldr 		r2, =0x0000
	bl		drawCell

	//Use snake coordinates to randomize the new extra life
	ldr 		r5, =snake

	ldr 		r6, [r5], #4
	ldr 		r7, [r5], #4
	ldr		r8, [r5, #8]
	ldr 		r9, [r5]

	//Get X, Y coordinates
	mov		r0, r7			//Parameters: apple x, y
	mov		r1, r8		
	mov		r2, r8		
	mov		r3, r7		

	bl 		randomX

	//Store X coordinate
	ldr 	r3, =extraLife
	str	r0, [r3]
	
	mov		r0, r8			//Parameters: apple x, y
	mov		r1, r7			
	mov		r2, r7			
	mov		r3, r8			
	
	bl 		randomY

	//Store Y coordinate
	ldr 	r3, =extraLife
	ldr 	r4, [r3], #4
	str	r0, [r3]
	
recalcLife:	
	//Check value pack is not inside a wall or the snake
	ldr 	r0, =extraLife
	ldr 	r1, [r0], #4		//r1 = life (x)
	ldr 	r2, [r0]		//r2 = life (y)
	
	bl 	appleWalls

	//Store new coordinates
	ldr 	r3, =extraLife
	str 	r1, [r3], #4
	str 	r2, [r3]
	
	//Check if spawn was bad (on top of snake)
	//Recalculate coordinates for value pack
	ldr 	r3, =badSpawn
	ldr	r4, [r3]

	ldr 	r6, =apple
	ldr	r7, [r6], #4
	ldr	r8, [r6]

	//Check if life spawns on top of apple
	cmp	r1, r7
	bne	checkNext

	cmp	r2, r8
	beq	recalcLife

checkNext:	
	//Check if badSpawn is bad value
	cmp	r4, #1
	moveq	r4, #0
	streq	r4, [r3]
	beq	recalcLife
	
	//Store new life coordinates (r1 = x, r2 = y)
	ldr 	r0, =extraLife
	str	r1, [r0], #4
	str	r2, [r0]

	//Draw extra life
	mov 	r0, r1
	mov 	r1, r2
	ldr	r2, =0x00ff
	bl 	drawCell
	
	b	state3Loop
	
state11:
	bl		clearScreen
	bl		drawGameOver

haltLoop$:
	b	haltLoop$

	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////	


	
defaultSnake:
	
	push		{lr}

	//Reset snake coordinates
	ldr 		r0, =snake

	mov		r1, #256
	mov		r2, #448
	str		r1, [r0], #4
	str		r2, [r0], #4
	mov 		r1, #224
	str 		r1, [r0], #4
	str		r2, [r0], #4
	mov 		r1, #192
	str 		r1, [r0], #4
	str 		r2, [r0]
	
	ldr		r3, =snake
	
	//Head Coordinates
	ldr		r0, [r3], #4 		
	ldr 		r1, [r3], #4
	ldr 		r2, =0x0bc0

	//Body Coordinates
	ldr		r5, [r3], #4 		
	ldr 		r6, [r3], #4

	//Tail Coordinates
	ldr		r7, [r3], #4		
	ldr 		r8, [r3], #4

	//Draw snake head, facing right (one cell)
	bl 		drawCell
	
	//Draw snake body (one cell)
	mov 		r0, r5
	mov 		r1, r6
	ldr		r2, =0x0fe0
	
	bl 		drawCell

	//Draw snake tail, facing right (one cell)
	mov 		r0, r7
	mov 		r1, r8
	ldr 		r2, =0x0fe0
	
	bl 		drawCell

	pop		{lr}
	mov 		pc, lr


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////	


collisionBorders:
	
	push 	{lr}
	
	//Get head coordinates
	//Get border coordinates
	ldr 	r0, =snake
	ldr 	r1, =xBorders
	ldr	r2, =yBorders

	ldr	r3, [r0], #4				//r3 = snake [0], head (x)
	ldr 	r4, [r1], #4				//r4 = xBorders [0], 32
	ldr 	r5, [r2], #4				//r5 = yBorders [0], 128

	//Compare x coordinates to head
	cmp	r3, r4
	ble	loseLife

	ldr 	r4, [r1]				//r4 = xBorders [1], 992
	cmp 	r3, r4
	bge 	loseLife

	//Compare y coordinates to head

	ldr 	r3, [r0]				//r3 = snake [1], head (y)
	cmp 	r3, r5
	ble 	loseLife

	ldr 	r5, [r2]				//r5 = yBorders [1], 736
	cmp 	r3, r5
	bge 	loseLife

	//No border collision
	pop	{lr}
	mov 	pc, lr


loseLife:
	push 	{lr}
	
	ldr 	r0, =liveNum			
	ldr 	r1, [r0]				//r1 = liveNum [0]

	cmp 	r1, #48					//If lives > 0 (48 ASCII)
	subne	r1, #1					//Subtract one life
	strne	r1, [r0]

	ldreq 	r2, =loseGame
	moveq 	r3, #1
	streq	r3, [r2]

	//Clear lives
	mov	r0, #360	
	mov	r1, #50
	ldr	r2, =0x0000
	bl 	drawCell
	
	pop	{lr}
	mov	pc, lr
	

gainLife:
	push 	{lr}
	
	ldr 	r0, =liveNum			
	ldr 	r1, [r0]				//r1 =valuePack [0]

	add	r1, #1
	str	r1, [r0]

	//Clear lives
	mov	r0, #360	
	mov	r1, #50
	ldr	r2, =0x0000
	bl 	drawCell
	
	pop	{lr}
	mov	pc, lr


	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

collisionWalls:	

	push 	{lr}
	
	//Get head coordinates
	//Get wall 1 coordinates
	ldr 	r0, =snake

	ldr	r3, [r0], #4				//r3 = snake [0], head (x)
	ldr 	r4, [r1], #4				//r4 = wall [0], 150 (x)
	ldr	r5, [r1], #4				//r5 = wall [1], 406 (x)
	ldr 	r6, [r1], #4				//r6 = wall [2], 328 (y)
	ldr 	r7, [r1]				//r7 = wall [3], 360 (y)
checkX:	
	//Compare leftmost X to head
	cmp	r3, r4
	bge	checkOtherX
	poplt	{lr}
	movlt	pc, lr
	
checkOtherX:	
	//Compare rightmost X to head
	sub	r3, #32
	cmp 	r3, r5					//r5 = wall1 [1], 406 (x)
	ble 	checkY
	popgt	{lr}
	movgt	pc, lr

checkY:	
	//Compare uppermost Y to head
	ldr 	r3, [r0]				//r3 = head (y)
	cmp 	r3, r6
	bge 	checkOtherY
	poplt	{lr}
	movlt   pc, lr

checkOtherY:
	//Compare lowermost Y to head
	sub 	r3, #32
	cmp 	r3, r7
	popgt	{lr}
	movgt	pc, lr
	
	bl	loseLife
	pop 	{lr}
	mov	pc, lr

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


collisionCell:
	push 	{lr}

	ldr 	r5, =snake
	ldr 	r6, [r5], #4			//r6 = snake head (x)
	ldr 	r7, [r5] 			//r7 = snake head (y)
	
appleX:	
	//Compare leftmost X to head
	cmp	r6, r1
	bge	appleOtherX
	poplt	{lr}
	movlt	pc, lr
	
appleOtherX:	
	//Compare rightmost X to head
	add	r6, #32
	cmp 	r6, r3					//r5 = wall1 [1], 406 (x)
	ble 	appleY
	popgt	{lr}
	movgt	pc, lr

appleY:	
	//Compare uppermost Y to head
	cmp 	r7, r2
	bge 	appleOtherY
	poplt	{lr}
	movlt   pc, lr

appleOtherY:
	//Compare lowermost Y to head
	add 	r7, #32
	cmp 	r7, r4
	popgt	{lr}
	movgt	pc, lr
	
clearApple:
	mov	r0, r1
	mov 	r1, r2
	ldr 	r2, =0x0000

	bl 	drawCell

redrawSnake:
	sub	r6, #32
	sub 	r7, #32
	mov 	r0, r6
	mov 	r1, r7
	ldr 	r2, =0x0bc0

	bl 	drawCell

	//Update item flag
	ldr 	r2, =getItem
	mov 	r3, #1
	str	r3, [r2]
	
	pop	{lr}
	mov	pc, lr

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
updateScore:
	push	{lr}
	
	ldr 	r0, =scoreNum				//r0 = scoreNum
	ldrb 	r1, [r0, #1] 				//r1 = scoreNum [1], 48

	//Is the tens place = 9?
	cmp	r1, #57					//If scoreNum [1] != 9
	bne	updateTen
	beq	updateHundred

updateTen:	
	//If not, add 1 to the tens place
	add	r1, #1					//r1 = r1 + 1
	strb	r1, [r0, #1]				//Store new score back

	b 	clearScore
	
updateHundred:	
	//If so, move 0 into the tens place
	sub	r1, #9
	strb	r1, [r0, #1]				//Store new score back

	//Reload the array
	ldr 	r0, =scoreNum				//r0 = scoreNum
	ldrb	r1, [r0]				//r1 = scoreNum [0]

	//Add 1 to the hundreds place
	add 	r1, #1					//Update hundreds place
	strb	r1, [r0]				//Store new hundred back

clearScore:	
	//Clear score
	mov	r0, #740	
	mov	r1, #50
	ldr	r2, =0x0000
	bl 	drawCell

	//Print score
	bl 	printScoreNum
	
	pop	{lr}
	mov	pc, lr
	
	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
moveSnake:

	push		{lr}
	ldr		r3, =snake			//r3 = address of snake[0]

	ldr 		r4, =oldDirection 		//r4 = oldDirection 
	ldr 		r5, =newDirection		//r5 = newDirection 

	ldr 		r6, [r4]			//r6 = oldDirection [0]
	ldr 		r7, [r5]			//r7 = newDirection [0]
	
	//Check allowed movements for the snake head
	cmp 		r6, #0
	beq 		checkRight

	cmp 		r6, #1
	beq 		checkLeft

	cmp 		r6, #2
	beq 		checkUp

	cmp 		r6, #3
	beq 		checkDown

	//If movement in exact opposite direction: do nothing, update in same direction
	//Else: update snake in new direction
checkRight:
	
	//right input
	cmp		r7, #0
	beq 		moveRight

	//left input
	cmp		r7, #1
	beq 		moveRight

	//up input
	cmp 		r7, #2
	streq 		r7, [r4]
	beq 		moveUp

	//down input
	cmp 		r7, #3
	streq		r7, [r4]
	beq 		moveDown

checkLeft:
	
	cmp		r7, #0
	beq 		moveLeft

	cmp		r7, #1
	beq 		moveLeft

	cmp 		r7, #2
	streq		r7, [r4]
	beq 		moveUp

	cmp 		r7, #3
	streq		r7, [r4]
	beq 		moveDown

checkUp:
	
	cmp		r7, #0
	streq		r7, [r4]
	beq 		moveRight

	cmp		r7, #1
	streq		r7, [r4]
	beq 		moveLeft

	cmp 		r7, #2
	beq 		moveUp

	cmp 		r7, #3
	beq 		moveUp

checkDown:
	
	cmp		r7, #0
	streq		r7, [r4]
	beq 		moveRight

	cmp		r7, #1
	streq		r7, [r4]
	beq 		moveLeft

	cmp 		r7, #2
	beq 		moveDown

	cmp 		r7, #3
	beq 		moveDown
	
moveRight:

	//Update head coordinates (head (x) = head (x) + 32)
	
	ldr 		r5, [r3]		//r5 = old head (x)
	add 		r0, r5, #32		//r0 = new head (x)
	str 		r0, [r3], #4		//Store new head (x)
	
	ldr 		r6, [r3], #4		//r6 = head (y), does not need to be changed

	mov 		r1, r6			//r1 = new head (y)
	ldr 		r2, =0x0bc0

	b 		moveSnakeBody

moveLeft:

	//Update head coordinates (head (x) = head (x) - 32)
	
	ldr 		r5, [r3]		//r5 = old head (x)
	sub 		r0, r5, #32		//r0 = new head (x)
	str 		r0, [r3], #4		//Store new head (x)
	
	ldr 		r6, [r3], #4		//r6 = head (y), does not need to be changed

	mov 		r1, r6			//r1 = new head (y)
	ldr 		r2, =0x0bc0

	b 		moveSnakeBody
	
moveUp:	

	//Update head coordinates (head (y) = head (y) - 32)
	
	ldr 		r5, [r3], #4		//r5 = old head (x)
	mov 		r0, r5			//r0 = new head (x), does not need changing
	
	ldr 		r6, [r3]		//r6 = head (y)
	sub 		r1, r6, #32		//r1 = new head (y)
	str 		r1, [r3], #4
	
	ldr 		r2, =0x0bc0

	b 		moveSnakeBody

moveDown:

	//Update head coordinates (head (y) = head (y) + 32)
	
	ldr 		r5, [r3], #4		//r5 = old head (x)
	mov 		r0, r5			//r0 = new head (x), does not need changing
	
	ldr 		r6, [r3]		//r6 = head (y)
	add 		r1, r6, #32		//r1 = new head (y)
	str 		r1, [r3], #4
	
	ldr 		r2, =0x0bc0

	b 		moveSnakeBody
	
moveSnakeBody:
	
	//Update body coordinates (body = old head)
	ldr		r7, [r3]		//r7 = old body (x)
	str 		r5, [r3], #4		//store new body value
	ldr 		r8, [r3]		//r8 = old body (y)
	str 		r6, [r3], #4		//store new body value

	//Update tail coordinates (tail = old body)
	ldr 		r9, [r3]
	str		r7, [r3], #4		//store new tail value
	ldr 		r11, [r3]
	str		r8, [r3]		//store new tail value
	
	//Draw updated head
	bl 		drawCell

	//Draw updated body
	mov 		r0, r5			//r5 = new body (x)
	mov 		r1, r6			//r6 = new body (y)
	ldr		r2, =0x0fe0

	bl 		drawCell
	
	//Draw updated tail
	mov 		r0, r7			//r7 = new tail (x)
	mov 		r1, r8			//r8 = new tail (y)
	ldr 		r2, =0x0fe0

	bl 		drawCell

	//Erase old tail
	mov 		r0, r9
	mov 		r1, r11
	ldr 		r2, =0x0000

	bl 		drawCell
	
	pop		{lr}
	mov		pc, lr


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	

delay:
	push 		{lr}
	mov 		r0, #0
delayLoop:	
	cmp		r0, #0x800000		//r0 < 0x300000?
	popeq 		{lr}
	moveq 		pc, lr			//restart program loop
	add		r0, #1			//r0++
	b		delayLoop		//branch back to delay
	

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
randomX:	

	push	{lr}
	
	x	.req	r0
	y	.req	r1
	z	.req	r2
	w	.req	r3
	t	.req	r4
	
	//initialize x, y, z, w so that they are not zero
	//Must change these for different random numbers
	
	//XOR shift algorithm
	mov	t, x			// t = x
	eor	t, t, lsl #11		// t ^= t << 11
	eor 	t, t, lsr #8		// t ^= t >> 8
	mov	x, y			// x = y
	mov	y, z			// y = z
	mov 	z, w			// z = w
	eor	w, w, lsr #19		// w ^= w >> 19;
	eor	w, t			// w ^= t

	mov	r0, w			// return w in r0

	
	.unreq	x
	.unreq	y
	.unreq	z
	.unreq	w
	.unreq	t	

	//r0 = number to divide
	//r1 = counter

	lsl 	r0, #22
	lsr 	r0, #22
	mov 	r1, #0
	mov	r2, #32

	//r0 = X
	//r1 = counter
	
modX32:
	//Put X into a cell
	cmp	r0, #0	
	ble 	modXNext32	
	sub	r0, #32
	add 	r1, #1
	b 	modX32
		
modXNext32:
	mul	r3, r1, r2
	mov	r0, r3
	
	//ldr 	r3, =apple
	//str	r0, [r3]
	
	pop	{lr}
	mov 	pc, lr

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

		
randomY:	

	push	{lr}
	
	x	.req	r0
	y	.req	r1
	z	.req	r2
	w	.req	r3
	t	.req	r4
	
	//initialize x, y, z, w so that they are not zero
	//Must change these for different random numbers

	//XOR shift algorithm
	mov	t, x			// t = x
	eor	t, t, lsl #11		// t ^= t << 11
	eor 	t, t, lsr #8		// t ^= t >> 8
	mov	x, y			// x = y
	mov	y, z			// y = z
	mov 	z, w			// z = w
	eor	w, w, lsr #19		// w ^= w >> 19;
	eor	w, t			// w ^= t
	
	mov	r0, w			// return w in r0

	.unreq	x
	.unreq	y
	.unreq	z
	.unreq	w
	.unreq	t	

	lsl 	r0, #23
	lsr 	r0, #23
	mov 	r1, #0
	mov	r2, #32

modY32:
	//Put Y into a cell
	cmp	r0, #0	
	ble 	modYNext32	
	sub	r0, #32
	add 	r1, #1
	b 	modY32
		
modYNext32:
	mul	r3, r1, r2
	mov	r0, r3

//	ldr 	r3, =apple
//	ldr 	r4, [r3], #4
//	str	r0, [r3]
	
	pop	{lr}
	mov 	pc, lr

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

appleWalls:
	push 	{lr}

	//Fix leftmost X = 0 - 32 (out of bounds)
	cmp 	r1, #0
	addeq	r1, #64

	cmp	r1, #32
	addeq	r1, #32

	cmp 	r1, #1024
	subeq	r1, #128
	
	cmp	r1, #992
	subeq	r1, #64

	cmp	r1, #960
	subeq	r1, #32

	//Fix apple if uppermost y = 0 - 96  (out of bounds)
	cmp 	r2, #96
	addeq	r2, #64
	addlt	r2, #192

	cmp 	r2, #704
	subeq	r2, #32
	
	cmp 	r2, #736
	subeq	r2, #64

	//Do not allow apple to spawn in default snake position
	cmp	r2, #448
	addeq	r2, #64

//CHECK COLLISION WITH WALL 1
leftWallX1:
	cmp	r1, #160		//Leftmost X of wall 1
	bgt	rightWallX1		//Check if apple x within range of wall 1
	subeq	r1, #64
	beq 	notInWall
	blt	notInWall		//Apple not in any walls

rightWallX1:
	cmp	r1, #416		//Rightmost X of wall 1
	bgt	leftWallX2		//Apple not in wall 1, check wall 2
	addeq	r1, #64			
	beq	notInWall		//Apple not in any walls
	blt	upperWallY1		

upperWallY1:
	cmp 	r2, #352		//Upper Y of wall 1
	bgt 	lowerWallY1
	subeq	r2, #64
	beq	notInWall
	blt	notInWall

lowerWallY1:
	cmp 	r2, #384
	bgt	notInWall
	addeq	r2, #128
	beq 	notInWall
	sublt	r2, #160
	blt	notInWall

//CHECK COLLISION WITH WALL 2
leftWallX2:
	cmp	r1, #608		//Leftmost X of wall 1
	bgt	rightWallX2		//Check if apple x within range of wall 1
	subeq	r1, #64
	beq 	notInWall
	blt	notInWall		//Apple not in any walls

rightWallX2:
	cmp	r1, #864		//Rightmost X of wall 1
	bgt	notInWall  		//Apple not in wall 1, check wall 2
	addeq	r1, #64		
	beq	notInWall		//Apple not in any walls
	blt	upperWallY2		

upperWallY2:
	cmp 	r2, #192		//Upper Y of wall 1
	bgt 	lowerWallY2
	subeq	r2, #32
	beq	notInWall
	blt	notInWall

lowerWallY2:
	cmp 	r2, #224
	bgt	leftWallX3
	addeq	r2, #64
	beq 	notInWall
	addlt	r2, #96
	blt	notInWall

//CHECK COLLISION WITH WALL 3
leftWallX3:
	cmp	r1, #704		//Leftmost X of wall 1
	bgt	rightWallX3		//Check if apple x within range of wall 1
	subeq	r1, #64
	beq 	notInWall
	blt	notInWall		//Apple not in any walls

rightWallX3:
	cmp	r1, #736  		//Rightmost X of wall 1
	bgt	notInWall  		//Apple not in wall 1, check wall 2
	addeq	r1, #64			
	beq	notInWall		//Apple not in any walls
	blt	upperWallY3		

upperWallY3:
	cmp 	r2, #416		//Upper Y of wall 1
	bgt 	lowerWallY3
	subeq	r2, #64
	beq	notInWall
	blt	notInWall

lowerWallY3:
	cmp 	r2, #608
	bgt	notInWall
	addeq	r2, #64
	beq 	notInWall
	sublt	r1, #64
	blt	notInWall
	
notInWall:
//Check for cell spawning on top of snake
	ldr	r3, =snake
	ldr 	r4, [r3], #4
	ldr 	r5, [r3], #4

//Check for cell on snake head
inSnakeHead:	
	cmp 	r1, r4
	bne	inSnakeBody
	cmp	r2, r5
	beq 	recalc

//Check for cell on snake body
inSnakeBody:
	ldr 	r4, [r3], #4
	ldr 	r5, [r3], #4

	cmp 	r1, r4
	bne	inSnakeTail
	cmp	r2, r5
	beq	recalc

//Check for cell on snake tail
inSnakeTail:
	ldr 	r4, [r3], #4
	ldr 	r5, [r3]

	cmp 	r1, r4
	bne 	notInSnake
	cmp	r2, r5
	beq 	recalc
	bne 	notInSnake

//Recalculate coordinates
recalc:
	sub	r1, #32
	sub	r2, #32
	
	ldr 	r3, =badSpawn
	mov 	r4, #1
	str 	r4, [r3]
	
notInSnake:	
	pop	{lr}
	mov 	pc, lr
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
ISR:
	push 	{lr}
	//Enable GPIO IRQ lines on timer compare 1
	ldr		r0, =0x2000B210			// Enable IRQs 1
	mov		r1, #0x2			// bit 1 set for C1
	str		r1, [r0]

	//DELAY = 1 SECOND (FOR TESTING)
	ldr 	r0, =20000000

	//LOAD ORIGINAL TIME + DELAY INTO R3
	ldr	r2, =0x20003004		//CLO address
	ldr	r1, [r2]		//r1 = current time
	add	r3, r1, r0		//r3 = current time + delay

	//LOAD TIMER COMPARE WITH ORIGINAL TIME + DELAY
	ldr	r2, =0x20003010		//timer compare 1 address
	str	r3, [r2]		//r1 = timer compare 1

	// Enable IRQ
	mrs		r0, cpsr
	bic		r0, #0x80
	msr		cpsr_c, r0

	pop	{lr}
	mov 	pc, lr


hang:	b 	hang

InstallIntTable:
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	bx		 lr

irq:
	push	{r0-r12, lr}

	// test if there is an interrupt pending in IRQ Pending 1
	ldr		r0, =0x2000B200
	ldr		r1, [r0]
	tst		r1, #0x100		// bit 8
	beq		irqEnd

	// test that clk 1 IRQ line caused the interrupt
	ldr		r0, =0x2000B204		// IRQ Pending 1 register
	ldr		r1, [r0]
	tst		r1, #2
	beq		irqEnd

doStuff:
	ldr 	r0, =valuePack			
	ldr 	r1, [r0]		//r1 = valuePack[0]
	mov	r1, #1			//change to 1 to indicate an interupt has fired 
	str	r1, [r0]		
	
	// clear bit 2 in the event detect register
	ldr		r0, =0x20003000 
	mov		r1, #0x2
	str		r1, [r0]
	
irqEnd:
	pop	{r0-r12, lr}
	subs	pc, lr, #4


/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
	
/* Draw Pixel
 *  r0 - x
 *  r1 - y
 *  r2 - color
 */
.globl DrawPixel
DrawPixel:
	push	{r4}


	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr


.section .data

.align 4
valuePack:	.word	0
.align 4
	
snake:		.word	256, 448, 224, 448, 192, 448
.align 4 

apple:		.word 	224, 224			//x, y
.align 4

getItem:	.word 0
.align 4

badSpawn:	.word 0
.align 4
	
extraLife:	.word 	0, 0				//x, y
.align 4

getLife:	.word 0
.align 4

xBorders:	.word	0, 992
.align 4

yBorders:	.word 	96, 736
.align 4

wall1:		.word	150, 406, 328, 360			//x1, x2, y1, y2
.align 4

wall2:		.word	598, 844, 172, 204			//x1, x2, y1, y2
.align 4

wall3:		.word	684, 716, 396, 588			//x1, x2, y1, y2
.align 4

oldDirection:	.word 	0					//Default = 0 (right)
.align 4
								//0 = Right
								//1 = Left
						                //2 = Up
								//3 = Down

newDirection:	.word	0
.align 4


loseGame:	.word 0
.align 4

IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word hang
swi_handler:		.word hang
prefetch_handler:	.word hang
data_handler:		.word hang
unused_handler:		.word hang
irq_handler:		.word irq
fiq_handler:		.word hang


