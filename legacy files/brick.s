.section .text

// r0 - x code
// r1 - y code
// r2 - colorCode
// draws Brick and changes brick state
.global makeBrick
makeBrick:
	PUSH	{r4-r6, lr}
	MOV	r4, r0
	MOV	r5, r1
	MOV	r6, r2
	BL	codeToTile
	STRB	r6, [r0]	// store the brick state

	MOV	r0, r4
	MOV	r1, r5
	MOV	r2, r6
	BL	drawBrick

	POP	{r4-r6, lr}
	MOV	pc, lr


.global	initBricks
initBricks:
	PUSH	{r4-r6, lr}

	MOV	r4, #0
	MOV	r5, #0

	initBrickStateLoop:
		MOV	r0, r4
		MOV	r1, r5

		BL	codeToTile
		STRB	r6, [r0]

		CMP	r0, #0

		MOVNE	r2, r6
		MOVNE	r0, r4
		MOVNE	r1, r5
		BLNE	drawBrick

		//check X
		ADD	r4, r4, #1
		CMP	r4, #10
		BLT	initBrickStateLoop

		//check Y
			ADD	r5, r5, #1
			CMP	r5, #5
			MOVLT	r4, #0
			BLT	initBrickStateLoop

	POP	{r4-r6, lr}
	MOV	PC, LR


// r0 - brick x position
// r1 - brick y position
// r2 - brick type (0, 1, 2, 3)
drawBrick:
	xpos		.req	r5
	ypos		.req	r6
	colorCode	.req	r7


	PUSH	{r3-r8, lr}
	BL	CodeToXY

	MOV	xpos, r0
	MOV	ypos, r1
	MOV	colorCode, r2

	MOV	r3, #64
	MOV	r4, #32

	MOV	r2, #0x0
		// make the outside brick

	ADD	xpos, xpos, #4
	ADD	ypos, ypos, #4

	MOV	r3, #56
	MOV	r4, #24

	CMP	colorCode, #0
	MOVEQ	r2, #0

	CMP	colorCode, #1
	MOVEQ	r2, #0x00FF00	// 1 hit

	CMP	colorCode, #2
	MOVEQ	r2, #0x007700	// 2 hits

	CMP	colorCode, #3
	MOVEQ	r2, #0x003300	// 3 hits


	MOV	r0, xpos
	MOV	r1, ypos

	BL	makeTile

	POP	{r3-r8, lr}
	MOV 	pc, lr


// params
// r0 - x coordinate
// r1 - y coordinate

// returns 0 - didn't hit brick
// 	   1 - hit brick
.global	hitBrick
hitBrick:
	PUSH	{r4-r7, lr}

	// store brick state on register
	BL	XYtoCode
	MOV	r4, r0
	MOV	r5, r1
	BL	codeToTile
        LDRB	r7, [r0]

	CMP	r7, #0

	MOVEQ	r0, #0		// didn't hit brick
	POPEQ	{r4-r7, lr}
	MOVEQ	pc, lr

	SUB	r2, r7, #1	// degrade the brick
	MOV	r0, r4
	MOV	r1, r5
	BL	makeBrick
	// r2 is the color

	MOV	r0, #1		// brick is hit
	POP	{r4-r7, lr}
        MOV	pc, lr

// r0 r1 - xy code
// returns r0 r1 - xy
CodeToXY:
	LSL	r0, r0, #6
	ADD	r0, r0, #36

	LSL	r1, r1, #5
	ADD	r1, r1, #96
	MOV	pc, lr

// r0 r1 - xy position
// returns r0 r1 - xy code
.global XYtoCode
XYtoCode:
	PUSH	{r4,r5,lr}

	MOV	r4, r0
	MOV	r5, r1

	CMP	r5, #96
	MOVLT	r0, #44 //return a not real position
	MOVLT	r1, #44
        POPLT 	{r4-r5, lr}
	MOVLT	PC, LR

	CMP	r5, #192
	MOVGT	r0, #44 //return a not real position
	MOVGT	r1, #44
        POPGT 	{r4-r5, lr}
	MOVGT	PC, LR

	MOV r5, #0 //default layer
	SUB	r1, r1, #96
	yloop:
	CMP	r1, #32
	SUB	r1, r1, #32
	MOVLT	r1, r5
	ADD	r5, r5, #1
	BGE	yloop

	MOV	r4, #0 //default start
	SUB	r0, r0, #36
	xloop:
	CMP	r0, #64
	SUB	r0, r0, #64
	MOVLT	r0, r4
	ADD	r4,r4, #1
	BGE	xloop


	POP	{r4,r5, lr}
	MOV	pc, lr

// params
//r0 - xcode
//r1 - ycode

// return
// r0 - brickStateAddress
codeToTile:
	PUSH	{lr}

	CMP	r0, #9
	LDRGT	r0, =emptyTile //error check first value
	POPGT	{lr}
	MOVGT	pc, lr

	CMP	r1, #1
	BLT	fromZero
	BEQ	fromTen

	CMPGT	r1, #3
	BLT	fromTwenty
	BGT	fromForty
	BEQ	fromThirty

	// invaild input, return 0
	LDR	r0, =emptyTile
	POP	{lr}
	MOV	pc, lr

	fromForty:
		CMP	r0, #0
		LDREQ	r0, =tile40
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #1
		LDREQ	r0, =tile41
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #2
		LDREQ	r0, =tile42
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #3
		LDREQ	r0, =tile43
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #4
		LDREQ	r0, =tile44
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #5
		LDREQ	r0, =tile45
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #6
		LDREQ	r0, =tile46
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #7
		LDREQ	r0, =tile47
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #8
		LDREQ	r0, =tile48
		POPEQ	{lr}
		MOVEQ	pc, lr

		LDR	r0, =tile49
		POP	{lr}
		MOV	pc, lr

	fromTwenty:
		CMP	r0, #0
		LDREQ	r0, =tile20
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #1
		LDREQ	r0, =tile21
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #2
		LDREQ	r0, =tile22
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #3
		LDREQ	r0, =tile23
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #4
		LDREQ	r0, =tile24
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #5
		LDREQ	r0, =tile25
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #6
		LDREQ	r0, =tile26
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #7
		LDREQ	r0, =tile27
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #8
		LDREQ	r0, =tile28
		POPEQ	{lr}
		MOVEQ	pc, lr

		LDR	r0, =tile29
		POP	{lr}
		MOV	pc, lr

	fromThirty:
		CMP	r0, #0
		LDREQ	r0, =tile30
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #1
		LDREQ	r0, =tile31
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #2
		LDREQ	r0, =tile32
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #3
		LDREQ	r0, =tile33
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #4
		LDREQ	r0, =tile34
		POPEQ	{lr}
		MOVEQ	pc, lr


		CMP	r0, #5
		LDREQ	r0, =tile35
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #6
		LDREQ	r0, =tile36
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #7
		LDREQ	r0, =tile37
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #8
		LDREQ	r0, =tile38
		POPEQ	{lr}
		MOVEQ	pc, lr

		LDR	r0, =tile39
		POP	{lr}
		MOV	pc, lr

	fromZero:
		CMP	r0, #0
		LDREQ	r0, =tile0
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #1
		LDREQ	r0, =tile1
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #2
		LDREQ	r0, =tile2
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #3
		LDREQ	r0, =tile3
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #4
		LDREQ	r0, =tile4
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #5
		LDREQ	r0, =tile5
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #6
		LDREQ	r0, =tile6
		POPEQ	{pc}

		CMP	r0, #7
		LDREQ	r0, =tile7
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #8
		LDREQ	r0, =tile8
		POPEQ	{lr}
		MOVEQ	pc, lr

		LDR	r0, =tile9
		POP	{lr}
		MOV	pc, lr

	fromTen:
		CMP	r0, #0
		LDREQ	r0, =tile10
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #1
		LDREQ	r0, =tile11
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #2
		LDREQ	r0, =tile12
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #3
		LDREQ	r0, =tile13
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #4
		LDREQ	r0, =tile14
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #5
		LDREQ	r0, =tile15
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #6
		LDREQ	r0, =tile16
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #7
		LDREQ	r0, =tile17
		POPEQ	{lr}
		MOVEQ	pc, lr

		CMP	r0, #8
		LDREQ	r0, =tile18
		POPEQ	{lr}
		MOVEQ	pc, lr

		LDR	r0, =tile19
		POP	{lr}
		MOV	pc, lr

.global	makeAllBricks
makeAllBricks:
	PUSH	{r4-r6, lr}
	MOV	r4, #0
	MOV	r5, #0

	getBrickStateLoop:
		MOV	r0, r4
		MOV	r1, r5

		BL	codeToTile
		LDRB	r6, [r0]

		MOV	r2, r6
		MOV	r0, r4
		MOV	r1, r5
		CMP	r2, #0
		BLNE	drawBrick

		//check X
		ADD	r4, r4, #1
		CMP	r4, #10
		BLT	getBrickStateLoop

		//check Y
			ADD	r5, r5, #1
			CMP	r5, #3
			MOVLT	r4, #0
			BLT	getBrickStateLoop

	POP	{r4-r6, lr}
	MOV	pc, lr

//returns 0 if not won or 1 if won
.global checkGameWon
checkGameWon:
	push {r4, r5, lr}
	mov r4, #0
        ldr r5, =tile0

checkallbricks:
	ldrb r0, [r5, r4]
	ADD  r4, r4, #1
        CMP  r0, #0
        MOVNE r0, #0
        POPNE {r4,r5,lr}
	MOVNE PC, lr

	CMP r4, #30
	BLT checkallbricks

	MOV r0, #1
        POP {r4, r5, lr}
	MOV pc, lr
	


// 0 - broken
// 1 - 1 hits to break
// 2 - 2 hits to break
// 3 - 3 hit to break
// 4 - special brick 1
// 5 - special brick 2
.section	.data

	tile0:	.byte	1
	tile10:	.byte 	1

	.global	tile20
	tile20:	.byte 	1
	tile30:	.byte	1
	tile40:	.byte	1

	tile1:	.byte	3
	tile11:	.byte	2	// special
	tile21:	.byte	3
	tile31:	.byte	3
	tile41:	.byte	3

	tile2:	.byte	3
	tile12:	.byte	3
	tile22:	.byte	3
	tile32:	.byte	3
	tile42:	.byte	3

	tile3:	.byte	3
	tile13:	.byte	3
	tile23:	.byte	3
	tile33:	.byte	3
	tile43:	.byte	3

	tile4:	.byte	3
	tile14:	.byte	3
	tile24:	.byte	3
	tile34:	.byte	3
	tile44:	.byte	3

	tile5:	.byte	1
	tile15:	.byte	2
	tile25:	.byte	1
	tile35:	.byte	3
	tile45:	.byte	3

	tile6:	.byte	3
	tile16:	.byte	3
	tile26:	.byte	3
	tile36:	.byte	3
	tile46:	.byte	3

	tile7:	.byte	3
	tile17:	.byte	2
	tile27:	.byte	3
	tile37:	.byte	3
	tile47:	.byte	3

	tile8:	.byte	3
	tile18:	.byte	2	// special
	tile28:	.byte	3
	tile38:	.byte	3
	tile48:	.byte	3

	tile9:	.byte	3
	tile19:	.byte	2

	.global tile29
	tile29:	.byte	3
	tile39:	.byte	3
	tile49:	.byte	3


	doTile:	.byte	1

	emptyTile:	.byte	0
	codeLog:	.asciz	"code: (%d, %d)\n"

	test:		.asciz  "array values: {%d}, %d"
