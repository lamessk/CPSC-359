.section .text

.globl startImage
startImage: 
	push	{lr}

	mov	r0, #100		//x-cordinate
	mov	r1, #100		//y-cordinate

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #824		//Length
	mov	r8, #568		//Height
	ldr	r9, =mainImage		//Load backround image into r9

outerLoop:

	mov	r3, #0			//reset pixels drawn x
	mov	r0, #100		//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	done1		
	
drawLoop:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoop		//If yes, branch to done

	ldrh	r2, [r9], #2		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoop

done1:
	pop	{lr}
	mov	pc, lr

.globl drawLoseImage
drawLoseImage: 
	push	{lr}

	mov	r0, #0		//x-cordinate
	mov	r1, #100		//y-cordinate

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #924		//Length
	mov	r8, #468		//Height
	ldr	r9, =loseImage		//Load backround image into r9

outerLoopDL:

	mov	r3, #0			//reset pixels drawn x
	mov	r0, #0		//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	done1DL		
	
drawLoopDL:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoopDL		//If yes, branch to done

	ldrh	r2, [r9], #2		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoopDL

done1DL:
	pop	{lr}
	mov	pc, lr

.globl drawWinImage
drawWinImage: 
	push	{lr}

	mov	r0, #0		//x-cordinate
	mov	r1, #100		//y-cordinate

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #924		//Length
	mov	r8, #468		//Height
	ldr	r9, =winImage		//Load backround image into r9

outerLoopDW:

	mov	r3, #0			//reset pixels drawn x
	mov	r0, #0		//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	done1DW		
	
drawLoopDW:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoopDW		//If yes, branch to done

	ldrh	r2, [r9], #2		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoopDW

done1DW:
	pop	{lr}
	mov	pc, lr

.globl drawGameOver
drawGameOver: 
	push	{lr}

	mov	r0, #0		//x-cordinate
	mov	r1, #100	//y-cordinate

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #924		//Length
	mov	r8, #368		//Height
	ldr	r9, =gameOverImage		//Load backround image into r9

outerLoopGO:

	mov	r3, #0			//reset pixels drawn x
	mov	r0, #0			//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	done1GO		
	
drawLoopGO:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoopGO		//If yes, branch to done

	ldrh	r2, [r9], #2		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoopGO

done1GO:
	pop	{lr}
	mov	pc, lr

.globl drawArrow
drawArrow:
	push	{lr}

	mov	r10, r0

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #31			//Length
	mov	r8, #30			//Height

	ldr	r9, =arrow		//Load backround image into r9

outerLoopA:
	mov	r3, #0			//reset pixels drawn x
	mov	r0, r10			//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	done		
	
drawLoopA:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoopA		//If yes, branch to done

	ldrh	r2, [r9], #2		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoopA

done:	
	pop	{lr}
	mov	pc, lr

.globl drawOver
drawOver:
	push	{lr}

	mov	r10, r0

	mov	r3, #0			//Pixels drawn x
	mov	r6, #0			//Pixels drawn y
	mov	r7, #31			//Length
	mov	r8, #30			//Height

outerLoopDO:
	mov	r3, #0			//reset pixels drawn x
	mov	r0, r10			//Re-initialize x -coordinate
	add	r1, r1, #1		//Add one to y coordinate
	add	r6, r6, #1		//Add one to pixels drawn y

	cmp	r6, r8			//Pixels drawn y < y bound?
	bge	doneDO		
	
drawLoopDO:
	cmp	r3, r7			//Pixels drawn < Length?
	bge	outerLoopDO		//If yes, branch to done

	ldr	r2, =0x000 		

	push	{r0, r1, r2}
	bl	DrawPixel
	pop	{r0, r1, r2}			
	
	add	r3, r3, #1		//Add one to pixels drawn	
	add	r0, r0, #1		//Add one to the x-coordinat

	b	drawLoopDO

doneDO:	
	pop	{lr}
	mov	pc, lr

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
.globl clearScreen
clearScreen:
	push 		{lr}

	mov		r0, #0
	mov 		r1, #0
	ldr		r2, =0x0000
	
	add		r3, r0, #1024		//r3 = final x coordinate
	add 		r4, r1, #768		//r4 = final y coordinate
loopClear:				
	cmp		r0, r3		
	bge		clearNext

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add		r0, #1
	b		loopClear

clearNext: 
	sub		r0, #1024			//r0 = original x coordinate
	add		r1, #1
	cmp 		r1, r4 		
	popeq		{lr}
	moveq 		pc, lr
	b 		loopClear
	
	pop		{lr}
	mov 		pc, lr
	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
.globl drawBorder
drawBorder:
	push		{lr}
	
	//DRAW TOP
	mov		r0, #0				//x coordinate
	mov		r1, #96				//y coordinate
	ldr		r2, =0xFFFF			//color
	
	bl 		drawBorderTopBottom

	//DRAW BOTTOM
	mov 		r0, #0				
	mov		r1, #736			

	bl 		drawBorderTopBottom

	//DRAW LEFT
	mov 		r0, #0
	mov		r1, #128
	
	bl 		drawBorderLeftRight

	//DRAW RIGHT
	mov		r0, #992
	mov		r1, #128

	bl 		drawBorderLeftRight

	pop		{lr}
	mov 		pc, lr

	
//DRAW TOP/BOTTOM OF BORDER	
drawBorderTopBottom:
	push 		{lr}
	add		r3, r0, #1024			//final x
	add		r4, r1, #32			//final y
loopTop:
	cmp		r0, r3
	bge		topNext

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add 		r0, #1
	b 		loopTop

topNext:
	sub 		r0, #1024 
	add 		r1, #1
	cmp 		r1, r4		
	popeq		{lr}
	moveq		pc, lr
	b 		loopTop

	
//DRAW LEFT/RIGHT SIDES OF BORDER
drawBorderLeftRight:
	push		{lr}
	add		r3, r0, #32
	add		r4, r1, #640
loopLeft:
	cmp		r1, r4
	bge		leftNext

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add		r1, #1
	b		loopLeft

leftNext: 
	sub		r1, #640
	add		r0, #1
	cmp 		r0, r3
	popeq		{lr}
	moveq 		pc, lr
	b 		loopLeft


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

.globl drawBoxes
drawBoxes:
	push		{lr}

	mov		r0, #160
	mov		r1, #384
	ldr		r2, =0xFFFF
	
	mov		r3, #8

drawBoxesLoop:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}	
	cmp		r3, #0
	beq		drawSecondBox

	sub		r3, #1
	add		r0, #32
	b		drawBoxesLoop	

drawSecondBox:
	mov		r0, #160
	mov		r1, #352
	ldr		r2, =0xFFFF
	mov		r3, #8

drawBoxLoop2:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}
	cmp		r3, #0
	beq		drawThirdBox
	
	sub		r3, #1
	add		r0, #32
	b		drawBoxLoop2		

drawThirdBox:
	mov		r0, #608
	mov		r1, #192
	ldr		r2, =0xFFFF
	mov		r3, #8

drawBoxLoop3:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}
	cmp		r3, #0
	beq		drawFourthBox

	sub		r3, #1
	add		r0, #32
	b		drawBoxLoop3	


drawFourthBox:
	mov		r0, #608
	mov		r1, #224
	ldr		r2, =0xFFFF
	mov		r3, #8

drawBoxLoop4:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}
	cmp		r3, #0
	beq		drawFifthBox
	
	sub		r3, #1
	add		r0, #32
	b		drawBoxLoop4

drawFifthBox:
	mov		r0, #704
	mov		r1, #416
	ldr		r2, =0xFFFF
	mov		r3, #6

drawBoxLoop5:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}
	cmp		r3, #0
	beq		drawSixthBox
	
	sub		r3, #1
	add		r1, #32
	b		drawBoxLoop5

drawSixthBox:
	mov		r0, #736
	mov		r1, #416
	ldr		r2, =0xFFFF
	mov		r3, #6

drawBoxLoop6:
	push		{r0 - r3}
	bl		drawCell
	pop		{r0 - r3}
	cmp		r3, #0
	popeq		{lr}
	moveq		pc, lr
	
	sub		r3, #1
	add		r1, #32
	b		drawBoxLoop6

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
.globl drawCell	
drawCell:
	push		{lr}
	add		r3, r0, #32		//r3 = final x coordinate
	add 		r4, r1, #32		//r4 = final y coordinate
loopCell:				
	cmp		r0, r3		
	bge		cellNext

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add		r0, #1
	b		loopCell

cellNext: 
	sub		r0, #32			//r0 = original x coordinate
	add		r1, #1
	cmp 		r1, r4 		
	popeq		{lr}
	moveq 		pc, lr
	b 		loopCell	


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
.globl drawBorderPause
drawBorderPause:
	push		{lr}
	
	//DRAW TOP
	mov		r0, #200			//x coordinate
	mov		r1, #200			//y coordinate
	ldr		r2, =0xD824			//color
	
	bl 		drawBorderTopBottomPause

	//DRAW BOTTOM
	mov 		r0, #200				
	mov		r1, #500			

	bl 		drawBorderTopBottomPause

	//DRAW LEFT
	mov 		r0, #200
	mov		r1, #200
	
	bl 		drawBorderLeftRightPause

	//DRAW RIGHT
	mov		r0, #768
	mov		r1, #200

	bl 		drawBorderLeftRightPause

	pop		{lr}
	mov 		pc, lr

	
//DRAW TOP/BOTTOM OF BORDER	
.globl drawBorderTopBottomPause
drawBorderTopBottomPause:
	push 		{lr}
	add		r3, r0, #600			//final x
	add		r4, r1, #32			//final y
loopTopPause:
	cmp		r0, r3
	bge		topNextPause

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add 		r0, #1
	b 		loopTopPause

topNextPause:
	sub 		r0, #600 
	add 		r1, #1
	cmp 		r1, r4		
	popeq		{lr}
	moveq		pc, lr
	b 		loopTopPause

	
//DRAW LEFT/RIGHT SIDES OF BORDER
.globl drawBorderLeftRightPause
drawBorderLeftRightPause:
	push		{lr}
	add		r3, r0, #32
	add		r4, r1, #300
loopLeftPause:
	cmp		r1, r4
	bge		leftNextPause

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add		r1, #1
	b		loopLeftPause

leftNextPause: 
	sub		r1, #300
	add		r0, #1
	cmp 		r0, r3
	popeq		{lr}
	moveq 		pc, lr
	b 		loopLeftPause


.globl clearScreenP
clearScreenP:
	push 		{lr}

	mov		r0, #200
	mov 		r1, #200
	ldr		r2, =0x0000
	
	add		r3, r0, #600		//r3 = final x coordinate
	add 		r4, r1, #332		//r4 = final y coordinate
loopClearP:				
	cmp		r0, r3		
	bge		clearNextP

	push		{r0-r4}
	bl 		DrawPixel
	pop		{r0-r4}

	add		r0, #1
	b		loopClearP

clearNextP: 
	sub		r0, #600			//r0 = original x coordinate
	add		r1, #1
	cmp 		r1, r4 		
	popeq		{lr}
	moveq 		pc, lr
	b 		loopClearP
	
	pop		{lr}
	mov 		pc, lr

