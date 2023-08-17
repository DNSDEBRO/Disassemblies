   LIST OFF
; ***  A R C A D E  P O N G  ***
; Copyright 2005 Atari
; Designer: Unknown

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: December 10, 2005
;
;  ***    44 BYTES OF RAM USED 84 BYTES FREE
;  *** 1,278 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 2005, ATARI                                        =
; =                                                                            =
; ==============================================================================

   processor 6502
      
;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

   include "macro.h"
   include "tia_constants.h"
   include "vcs.h"

;
; Make sure we are using vcs.h version 1.05 or greater.
;
   IF VERSION_VCS < 105
   
      echo ""
      echo "*** ERROR: vcs.h file *must* be version 1.05 or higher!"
      echo "*** Updates to this file, DASM, and associated tools are"
      echo "*** available at https://dasm-assembler.github.io/"
      echo ""
      err
      
   ENDIF
;
; Make sure we are using macro.h version 1.01 or greater.
;
   IF VERSION_MACRO < 101

      echo ""
      echo "*** ERROR: macro.h file *must* be version 1.01 or higher!"
      echo "*** Updates to this file, DASM, and associated tools are"
      echo "*** available at https://dasm-assembler.github.io/"
      echo ""
      err

   ENDIF

   LIST ON
   
;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 42
OVERSCAN_TIME           = 36
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

RANDOM_SEED             = $B2

ONE_PLAYER_GAME         = 0
TWO_PLAYER_GAME         = 1

; controllerType constants
CONTROLLER_TYPE_PADDLE  = 0
CONTROLLER_TYPE_STICK   = 1

SCORE_MAX               = 11

H_KERNEL                = 128
H_FONT                  = 8
H_BALL                  = 4
H_PADDLE                = 16

XMAX                    = 137
YMIN_PADDLE             = 1
YMAX_PADDLE             = H_KERNEL - H_PADDLE

GAME_WON_TIMER_VALUE    = 255
BALL_LAUNCH_WAIT_TIME   = 79

; gameState constants
GAME_OVER               = 0
BALL_LAUNCHED           = 1
WAIT_FOR_BALL_LAUNCH    = 2
GAME_WON                = 3

; ballVertDirection constants
VMOVE_U2                = $20
VMOVE_U1                = $10
VMOVE_0                 = $00
VMOVE_D1                = $F0
VMOVE_D2                = $E0

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gameTimer               ds 1
controllerType          ds 1
graphicPointerIndex     ds 1
cycleWait               ds 1
temp                    ds 1
;--------------------------------------
tmpBallLowerBounds      = temp
;--------------------------------------
tempHorizPos            = tmpBallLowerBounds
;--------------------------------------
tempCharHolder          = tempHorizPos
;--------------------------------------
player1PaddleValue      = tempCharHolder
player2PaddleValue      ds 1
player2Scanline         ds 1
rightPaddleHeight       ds 1
ballScanline            ds 1
ballHeight              ds 1
graphicDataPointers     ds 2
graphicPointers         ds 12
random                  ds 2
randomSeed              ds 1
gameState               ds 1
gameSelection           ds 1
selectDebounce          ds 1
zp_Unused_00            ds 1
ballStartVertTravel     ds 1
player1VertPos          ds 1
player1Score            ds 1
player2VertPos          ds 1
player2Score            ds 1
ballVertPos             ds 1
ballHorizPos            ds 1
ballHMOVEValue          ds 1
ballVertDirection       ds 1
zp_Unused_01            ds 1
soundPointers           ds 2
soundTableIndex         ds 1
playSound               ds 1
soundDuration           ds 1

   echo "***",(* - $80 - 2)d, "BYTES OF RAM USED", ($100 - * + 2)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
PongLiteral
   .word Blank, P, O, N, G, Blank
   
OnePlayerLiteral
   .word one, P, L, AY, E, R
   
TwoPlayerLiteral
   .word two, P, L, AY, E, R
   .word zero, zero, Blank, Blank, zero, zero

NumberTable
   .word zero, one, two, three, four, five, six, seven, eight, nine

Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
P
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $7C ; |.XXXXX..|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $7C ; |.XXXXX..|
O
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
N
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
G
   .byte $00 ; |........|
   .byte $1E ; |...XXXX.|
   .byte $22 ; |..X...X.|
   .byte $42 ; |.X....X.|
   .byte $4E ; |.X..XXX.|
   .byte $40 ; |.X......|
   .byte $20 ; |..X.....|
   .byte $1E ; |...XXXX.|
   
NumberFonts
zero
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $3E ; |..XXXXX.|
one
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $06 ; |.....XX.|
two
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $3E ; |..XXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
three
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
four
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
five
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $3E ; |..XXXXX.|
six
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $3E ; |..XXXXX.|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $3E ; |..XXXXX.|
seven
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
eight
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $3E ; |..XXXXX.|
nine
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $3E ; |..XXXXX.|
tensLiteral
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|

L
   .byte $00 ; |........|
   .byte $F4 ; |XXXX.X..|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $87 ; |X....XXX|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $83 ; |X.....XX|
AY
   .byte $00 ; |........|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $C4 ; |XX...X..|
   .byte $4A ; |.X..X.X.|
   .byte $51 ; |.X.X...X|
   .byte $91 ; |X..X...X|
E
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $7C ; |.XXXXX..|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $7C ; |.XXXXX..|
R
   .byte $00 ; |........|
   .byte $88 ; |X...X...|
   .byte $90 ; |X..X....|
   .byte $A0 ; |X.X.....|
   .byte $F0 ; |XXXX....|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $F0 ; |XXXX....|
   
RightPaddleAI
   lda gameState                    ; get the current game state
   cmp #WAIT_FOR_BALL_LAUNCH        ; see if waiting for next ball launch
   bne .checkGameWonRightPaddleAI
   lda player2VertPos               ; get right paddle vertical position
   cmp #(H_KERNEL / 2) - H_PADDLE - H_BALL
   beq .jmpToDoneRightPaddleAI
   bcs .moveRightPaddleUp
   inc player2VertPos               ; move right paddle down
   jmp .doneRightPaddleAI
   
.moveRightPaddleUp
   dec player2VertPos
   jmp .doneRightPaddleAI
   
.jmpToDoneRightPaddleAI
   jmp .doneRightPaddleAI
   
.checkGameWonRightPaddleAI
   lda gameState                    ; get the current game state
   cmp #GAME_WON
   bne .doRightPaddleAI             ; do AI if game not won
   lda #YMIN_PADDLE
   sta player2VertPos
   jmp .doneRightPaddleAI
   
.doRightPaddleAI
   lda ballHMOVEValue               ; get the pong ball HMOVE value
   bpl .doneRightPaddleAI           ; branch if moving left
   lda player2VertPos               ; get right paddle vertical position
   cmp ballVertPos                  ; compare with ball vertical position
   bcs .doAIUpPaddleMotion          ; branch if paddle under ball
   lda random                       ; get random number
   ror                              ; rotate value right
   sta random                       ; set new random number
   bcc .moveRightPaddleDown         ; branch if original number was even
   inc player2VertPos               ; move right paddle down twice as fast
.moveRightPaddleDown
   inc player2VertPos
   lda controllerType               ; get controller type
   bne .checkRightPaddleLowerBound  ; branch if CONTROLLER_TYPE_STICK
   lda player2VertPos               ; get right paddle vertical position
   cmp #YMAX_PADDLE
   bcc .doneRightPaddleAI
   lda #YMAX_PADDLE
   sta player2VertPos               ; set right paddle to YMAX
   jmp .doneRightPaddleAI
;
; Same as above computation but branches if this is a joystick game.
;
.checkRightPaddleLowerBound
   lda player2VertPos               ; get right paddle vertical position
   cmp #YMAX_PADDLE
   bcc .doneRightPaddleAI
   lda #YMAX_PADDLE
   sta player2VertPos
   jmp .doneRightPaddleAI
   
.doAIUpPaddleMotion
   lda random                       ; get random number
   rol                              ; rotate value left
   sta random                       ; set new random number
   bcc .moveRightPaddleUpOnePixel   ; branch if D7 was set low
   dec player2VertPos               ; move right paddle up
   beq .setRightPaddleUpperBound
.moveRightPaddleUpOnePixel
   dec player2VertPos
   bne .doneRightPaddleAI
.setRightPaddleUpperBound
   lda #YMIN_PADDLE
   sta player2VertPos               ; set right paddle to YMIN
.doneRightPaddleAI
   jsr NewRandomNumber
   rts

CheckPlayer1JoystickValues SUBROUTINE
   lda controllerType               ; get controller type
   bne .readLeftJoystickValues      ; branch if CONTROLLER_TYPE_STICK
   jmp .donePlayer1JoystickCheck
   
.readLeftJoystickValues
   lda #<~[MOVE_UP]
   bit SWCHA
   beq .moveLeftPaddleUp            ; branch if left joystick is MOVE_UP
   lda #<~[MOVE_DOWN]
   bit SWCHA
   beq .moveLeftPaddleDown          ; branch if left joystick is MOVE_DOWN
   jmp .jmpToDoneJoystickCheck
   
.moveLeftPaddleDown
   lda player1VertPos               ; get left paddle vertical position
   cmp #YMAX_PADDLE
   beq .jmpToDoneJoystickCheck
   lda #2
   adc player1VertPos               ; move left paddle down 2 pixels
   sta player1VertPos
   jmp .jmpToDoneJoystickCheck
   
.moveLeftPaddleUp
   lda player1VertPos               ; get left paddle vertical position
   beq .jmpToDoneJoystickCheck
   dec player1VertPos
   beq .jmpToDoneJoystickCheck
   dec player1VertPos
.jmpToDoneJoystickCheck
   jmp .donePlayer1JoystickCheck    ; could fall through
   
.donePlayer1JoystickCheck
   rts

CheckPlayer2JoystickValues SUBROUTINE
   lda controllerType               ; get controller type
   bne .readRightJoystickValues     ; branch if CONTROLLER_TYPE_STICK
   jmp .doneJoystickCheck
   
.readRightJoystickValues
   lda #<~[MOVE_UP] >> 4
   bit SWCHA
   beq .moveRightPaddleUp           ; branch if right joystick is MOVE_UP
   lda #<~[MOVE_DOWN] >> 4
   bit SWCHA
   beq .moveRightPaddleDown         ; branch if right joystick is MOVE_DOWN
   jmp .donePlayer2JoystickCheck
   
.moveRightPaddleDown
   lda player2VertPos               ; get right paddle vertical position
   cmp #YMAX_PADDLE
   beq .donePlayer2JoystickCheck
   lda #2
   adc player2VertPos               ; move right paddle down 2 pixels
   sta player2VertPos
   jmp .donePlayer2JoystickCheck
   
.moveRightPaddleUp
   lda player2VertPos               ; get right paddle vertical position
   beq .donePlayer2JoystickCheck
   dec player2VertPos
   dec player2VertPos
.donePlayer2JoystickCheck
   rts

.doneJoystickCheck
   rts

MovePongBall
   lda gameState                    ; get the current game state
   cmp #GAME_WON
   bne .checkForBallLaunchWait      ; branch if game not won
   jmp DoneMovePongBall
   
.checkForBallLaunchWait
   cmp #WAIT_FOR_BALL_LAUNCH
   bne .pongBallInPlay              ; branch if ball is in play
   lda gameTimer                    ; get current game timer
   beq .launchPongBall              ; launch ball if reached zero
   dec gameTimer                    ; reduce game timer
   jmp DoneMovePongBall
   
.launchPongBall
   lda #BALL_LAUNCHED
   sta gameState                    ; set game state for launcing ball
   jsr LaunchPongBall
   jmp DoneMovePongBall
   
.pongBallInPlay
   lda ballHMOVEValue               ; get the pong ball HMOVE value
   bmi .pongBallMovingRight         ; branch if moving right
   rol                              ; shift D4 to carry
   rol
   rol
   rol
   bcs .moveBallLeftOnePixel
   dec ballHorizPos
   dec ballHorizPos
   jmp CheckBallVerticalMotion
   
.moveBallLeftOnePixel
   dec ballHorizPos
   jmp CheckBallVerticalMotion
   
.pongBallMovingRight
   rol                              ; shift D4 to carry
   rol
   rol
   rol
   bcs .moveBallRightOnePixel
   inc ballHorizPos
   inc ballHorizPos
   jmp CheckBallVerticalMotion
   
.moveBallRightOnePixel
   inc ballHorizPos
CheckBallVerticalMotion
   lda ballVertDirection
   beq CheckBallPaddleCollisions
   bmi .ballMovingDown
   rol                              ; shift D4 to carry
   rol
   rol
   rol
   bcs .moveBallUpOnePixel
   dec ballVertPos
   dec ballVertPos
   jmp CheckBallPaddleCollisions
   
.moveBallUpOnePixel
   dec ballVertPos
   jmp CheckBallPaddleCollisions
   
.ballMovingDown
   rol                              ; shift D4 to carry
   rol
   rol
   rol
   bcs .moveBallDownOnePixel
   inc ballVertPos                  ; move pong ball down
   inc ballVertPos
   jmp CheckBallPaddleCollisions
   
.moveBallDownOnePixel
   inc ballVertPos
CheckBallPaddleCollisions
   lda ballHorizPos                 ; get the ball's horizontal position
   cmp #XMAX - 9
   beq .checkForBallHitRightPaddle
   cmp #XMAX - 10
   beq .checkForBallHitRightPaddle
   jmp CheckToScorePointForPlayer1
   
.checkForBallHitRightPaddle
   lda ballVertPos                  ; get the ball's vertical position
   clc
   adc #H_BALL
   sta tmpBallLowerBounds           ; set ball lower bounding box value
   lda player2VertPos               ; get right paddle vertical position
   cmp tmpBallLowerBounds
   bcc DetermineBallNewLeftMotion   ; branch if paddle below ball
   jmp CheckToScorePointForPlayer1
   
DetermineBallNewLeftMotion
   clc
   adc #H_PADDLE
   cmp ballVertPos
   bcc CheckToScorePointForPlayer1  ; branch if ball below paddle
   lda player2VertPos               ; get right paddle vertical position
   cmp #3
   bcc .determineBallRandomMotion   ; branch if right paddle at upper limit
   cmp #H_KERNEL - 6
   bcs .determineBallRandomMotion   ; branch if right paddle at lower limit
   jmp .newMotionFromHittingPaddle
   
.determineBallRandomMotion
   jsr NewRandomNumber
   lda random                       ; get random number
   ror                              ; rotate D0 into carry
   bcs .playHittingPaddleSound      ; branch if odd number
   ror
   bcs .moveBallL1D2
   ror
   bcs .moveBallL2D1
   ror
   bcs .moveBallL2U0
   jmp .moveBallL2U1
   
.newMotionFromHittingPaddle
   lda player2VertPos               ; get right paddle vertical position
   adc #2                           ; increment value by 2
   cmp tmpBallLowerBounds
   bcs .moveBallL1U2                ; branch if ball 2 pixels below paddle
   adc #4
   cmp tmpBallLowerBounds
   bcs .moveBallL2U1                ; branch if ball 6 pixels below paddle
   adc #2
   cmp tmpBallLowerBounds
   bcs .moveBallL2U0                ; branch if ball 8 pixels below paddle
   adc #5
   cmp tmpBallLowerBounds
   bcs .moveBallL2D1                ; branch if ball 13 pixels below paddle
   jmp .moveBallL1D2
   
.moveBallL1U2
   lda #HMOVE_L1
   sta ballHMOVEValue
   lda #VMOVE_U2
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallL2U1
   lda #HMOVE_L2
   sta ballHMOVEValue
   lda #VMOVE_U1
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallL2U0
   lda #HMOVE_L2
   sta ballHMOVEValue
   lda #VMOVE_0
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallL2D1
   lda #HMOVE_L2
   sta ballHMOVEValue
   lda #VMOVE_D1
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallL1D2
   lda #HMOVE_L1
   sta ballHMOVEValue
   lda #VMOVE_D2
   sta ballVertDirection
   jmp .playHittingPaddleSound      ; could fall through
   
.playHittingPaddleSound
   lda #<HittingPaddleSoundTable
   ldy #>HittingPaddleSoundTable
   jsr SetupSoundVariables
   jmp CheckBallHittingVertBoundaries
   
CheckToScorePointForPlayer1
   lda ballHorizPos                 ; get ball's horizontal position
   cmp #XMAX - 1                    ; see if ball passed the right paddle
   beq .scorePointForPlayer1
   cmp #XMAX
   beq .scorePointForPlayer1
   jmp CheckLeftPaddleCollision
   
.scorePointForPlayer1
   lda #<PointScoredSoundTable
   ldy #>PointScoredSoundTable
   jsr SetupSoundVariables
   inc player1Score                 ; increment player 1's score
   lda player1Score                 ; get player 1's score
   cmp #SCORE_MAX                   ; see if player 1 won the game
   bne .setStateToWaitForBallLaunch
   lda #GAME_WON
   sta gameState                    ; set game state to show game won
   lda #GAME_WON_TIMER_VALUE
   sta gameTimer                    ; set timer for game won pause
   jmp DoneMovePongBall
   
.setStateToWaitForBallLaunch
   lda #WAIT_FOR_BALL_LAUNCH
   sta gameState
   lda #BALL_LAUNCH_WAIT_TIME
   sta gameTimer                    ; set timer for ball launch wait
   lda #1
   sta ballStartVertTravel          ; set ball to travel right next time
   jmp DoneMovePongBall
   
CheckLeftPaddleCollision
   lda ballHorizPos                 ; get the ball's horizontal position
   cmp #4
   beq .checkForBallHitLeftPaddle
   cmp #5
   beq .checkForBallHitLeftPaddle
   jmp CheckToScorePointForPlayer2
   
.checkForBallHitLeftPaddle
   lda ballVertPos                  ; get the ball's vertical position
   clc
   adc #H_BALL
   sta tmpBallLowerBounds
   lda player1VertPos               ; get left paddle vertical position
   cmp tmpBallLowerBounds
   bcc DetermineBallNewRightMotion
   jmp CheckToScorePointForPlayer2
   
DetermineBallNewRightMotion SUBROUTINE
   adc #H_PADDLE
   cmp ballVertPos
   bcc CheckToScorePointForPlayer2  ; branch if ball below paddle
   lda player1VertPos               ; get left paddle vertical position
   cmp #3
   bcc .determineBallRandomMotion   ; branch if left paddle at upper limit
   cmp #H_KERNEL - 6
   bcs .determineBallRandomMotion   ; branch if left paddle at lower limit
   jmp .newMotionFromHittingPaddle
   
.determineBallRandomMotion
   jsr NewRandomNumber
   lda random
   ror
   bcs .moveBallR1U2
   ror
   bcs .moveBallR2U1
   ror
   bcs .moveBallR2U0
   ror
   bcs .moveBallR2D1
   jmp .moveBallR1D2
   
.newMotionFromHittingPaddle
   lda player1VertPos               ; get left paddle vertical position
   adc #3                           ; increment value by 3
   cmp tmpBallLowerBounds
   bcs .moveBallR1U2                ; branch if ball 3 pixels below paddle
   adc #5
   cmp tmpBallLowerBounds
   bcs .moveBallR2U1                ; branch if ball 8 pixels below paddle
   adc #2
   cmp tmpBallLowerBounds
   bcs .moveBallR2U0                ; branch if ball 10 pixels below paddle
   adc #4
   cmp tmpBallLowerBounds
   bcs .moveBallR2D1                ; branch if ball 14 pixels below paddle
   jmp .moveBallR1D2

.moveBallR1U2
   lda #HMOVE_R1
   sta ballHMOVEValue
   lda #VMOVE_U2
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallR2U1
   lda #HMOVE_R2
   sta ballHMOVEValue
   lda #VMOVE_U1
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallR2U0
   lda #HMOVE_R2
   sta ballHMOVEValue
   lda #VMOVE_0
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallR2D1
   lda #HMOVE_R2
   sta ballHMOVEValue
   lda #VMOVE_D1
   sta ballVertDirection
   jmp .playHittingPaddleSound
   
.moveBallR1D2
   lda #HMOVE_R1
   sta ballHMOVEValue
   lda #VMOVE_D2
   sta ballVertDirection
   jmp .playHittingPaddleSound      ; could fall through
   
.playHittingPaddleSound
   lda #<HittingPaddleSoundTable
   ldy #>HittingPaddleSoundTable
   jsr SetupSoundVariables
   jmp CheckBallHittingVertBoundaries
   
CheckToScorePointForPlayer2 SUBROUTINE
   lda ballHorizPos                 ; get the ball's horizontal position
   beq .scorePointForPlayer2        ; see if ball passed the left paddle
   cmp #1
   beq .scorePointForPlayer2
   jmp CheckBallHittingVertBoundaries
   
.scorePointForPlayer2
   lda #<PointScoredSoundTable
   ldy #>PointScoredSoundTable
   jsr SetupSoundVariables
   inc player2Score                 ; increment player 2's score
   lda player2Score                 ; get player 2's score
   cmp #SCORE_MAX                   ; see if player 2 won the game
   bne .setStateToWaitForBallLaunch
   lda #GAME_OVER                   ; state set to GAME_OVER but set to
   sta gameState                    ; GAME_WON below...this isn't needed
   lda #GAME_WON_TIMER_VALUE
   sta gameTimer                    ; set timer for game won pause
   lda #GAME_WON
   sta gameState                    ; set game state to show game won
   jmp DoneMovePongBall
   
.setStateToWaitForBallLaunch
   lda #WAIT_FOR_BALL_LAUNCH
   sta gameState
   lda #BALL_LAUNCH_WAIT_TIME
   sta gameTimer                    ; set timer for ball launch wait
   lda #0
   sta ballStartVertTravel          ; set ball to travel left next time
   jmp DoneMovePongBall
   
CheckBallHittingVertBoundaries
   lda controllerType               ; get controller type
   bne .checkBallHittingLowerLimit  ; branch if CONTROLLER_TYPE_STICK
   lda ballVertPos                  ; get the ball's vertical position
   cmp #H_KERNEL - 5
   beq .paddleBallHitLowerLimit
   cmp #H_KERNEL - 4
   beq .paddleBallHitLowerLimit
   jmp .checkBallHittingUpperLimit
;
; This is used to check for hitting the lower limit if the player is using
; the paddle controllers instead of the joystick. The routine is identical
; to the one used for the joystick so this isn't needed.
;
.paddleBallHitLowerLimit
   lda #H_KERNEL - 5
   sta ballVertPos                  ; set new vertical position of ball
   lda ballVertDirection            ; get current vertical direction
   eor #$FF                         ; negate it's direction
   sec
   adc #1 - 1
   sta ballVertDirection            ; set new vertical direction
   lda #<HittingBoundarySoundTable
   ldy #>HittingBoundarySoundTable
   jsr SetupSoundVariables
   jmp DoneMovePongBall
   
.checkBallHittingLowerLimit
   lda ballVertPos                  ; get the ball's vertical position
   cmp #H_KERNEL - 5
   beq .ballHitLowerLimit
   cmp #H_KERNEL - 4
   beq .ballHitLowerLimit
   jmp .checkBallHittingUpperLimit
   
.ballHitLowerLimit
   lda #H_KERNEL - 5
   sta ballVertPos                  ; set new vertical position of ball
   lda ballVertDirection            ; get current vertical direction
   eor #$FF                         ; negate it's direction
   sec
   adc #1 - 1
   sta ballVertDirection            ; set new vertical direction
   lda #<HittingBoundarySoundTable
   ldy #>HittingBoundarySoundTable
   jsr SetupSoundVariables
   jmp DoneMovePongBall
   
.checkBallHittingUpperLimit
   lda ballVertPos                  ; get the ball's vertical position
   beq .ballHitUpperLimit
   cmp #1
   beq .ballHitUpperLimit
   jmp DoneMovePongBall
   
.ballHitUpperLimit
   lda #2
   sta ballVertPos                  ; set new vertical position of ball
   lda ballVertDirection            ; get current vertical direction
   eor #$FF                         ; negate it's direction
   sec
   adc #1 - 1
   sta ballVertDirection            ; set new vertical direction
   lda #<HittingBoundarySoundTable
   ldy #>HittingBoundarySoundTable
   jsr SetupSoundVariables
DoneMovePongBall
   rts

LaunchPongBall
   lda ballStartVertTravel          ; get ball start vertical travel value
   beq LaunchBallToLeftPaddle       ; branch if ball to travel left
   lda #0
   sta ballStartVertTravel          ; reset to default (i.e. travel left)
   lda #(XMAX / 2) - 15
   sta ballHorizPos                 ; place ball in the middle of screen
   ldy #6
   lda #HMOVE_R1
   sta ballHMOVEValue               ; set ball HMOVE to move right 1 pixel
   jsr NewRandomNumber
   lda random                       ; get random number
   ror                              ; rotate D0 into carry
   bcc .determineNewBallVertDirection;branch if value is even
   lda #VMOVE_0
   sta ballVertDirection            ; set ball to have no vertical direction
   jmp CoarsePositionPongBall
   
.determineNewBallVertDirection
   ror                              ; rotate random D1 into carry
   bcc .newBallVertDirectionDown    ; branch if D1 set low
   lda #VMOVE_U1
   sta ballVertDirection            ; set ball to move up 1 pixel
   jmp CoarsePositionPongBall
   
.newBallVertDirectionDown
   lda #VMOVE_D1
   sta ballVertDirection            ; set ball to move down 1 pixel
   jmp CoarsePositionPongBall
   
LaunchBallToLeftPaddle SUBROUTINE
   ldy #7
   lda #(XMAX / 2) + 7
   sta ballHorizPos
   lda #HMOVE_L1
   sta ballHMOVEValue               ; set ball HMOVE to move left 1 pixel
   lda #$F0                         ; value not needed...destroyed by PRNG
   jsr NewRandomNumber
   lda random                       ; get random number
   ror                              ; rotate D0 into carry
   bcc .determineNewBallVertDirection;branch if value is even
   lda #VMOVE_0
   sta ballVertDirection            ; set ball to have no vertical direction
   jmp CoarsePositionPongBall
   
.determineNewBallVertDirection
   ror                              ; rotate D1 into carry
   bcc .newBallVertDirectionDown    ; branch if D1 set low
   lda #VMOVE_U1
   sta ballVertDirection
   jmp CoarsePositionPongBall
   
.newBallVertDirectionDown
   lda #VMOVE_D1
   sta ballVertDirection
   jmp CoarsePositionPongBall
   
   sta ballVertDirection            ; this is never executed
CoarsePositionPongBall
   sta WSYNC
.coarsePosLoop
   nop
   dey
   bne .coarsePosLoop
   sta RESM1                        ; set new coarse position for pong ball
   sta HMCLR                        ; clear all horizontal movement
   lda #(H_KERNEL / 2) - H_BALL
   sta ballVertPos
   rts

SetupSoundVariables
   sta soundPointers
   sty soundPointers + 1
   lda #0
   sta soundTableIndex              ; reset sound table index
   sta soundDuration                ; reset sound duration timer
   lda #1
   sta playSound                    ; set to play the sound
   rts

HorizPositionPlayers
   ldx #<RESP0 - RESP0        ; 2
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03   clear player graphic registers
   stx GRP1                   ; 3 = @06
   sta tempHorizPos           ; 3
   jsr CalculatePlayerXPos    ; 6
;--------------------------------------
   ldx #<RESP1 - RESP0        ; 2
   lda tempHorizPos           ; 3
   clc                        ; 2
   adc #8                     ; 2
   jsr CalculatePlayerXPos    ; 6
;--------------------------------------
   lda #MSBL_SIZE4 | THREE_COPIES; 2
   sta NUSIZ0                 ; 3 = @58
   sta NUSIZ1                 ; 3 = @61
   sty COLUP0                 ; 3 = @64
   sty COLUP1                 ; 3 = @67
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @08
   sta COLUPF                 ; 3 = @11
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @16
   sta VDELP1                 ; 3 = @19
   sta WSYNC
;--------------------------------------
   lda #RED_ORANGE + 14       ; 2
   sta COLUBK                 ; 3 = @05
   sta COLUPF                 ; 3 = @08
   rts                        ; 6

CalculatePlayerXPos
   sec                        ; 2
   sta WSYNC
;--------------------------------------
.divideBy15
   sbc #15                    ; 2
   bcs .divideBy15            ; 2³
   eor #7                     ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta HMP0,x                 ; 4 = @43
   sta RESP0,x                ; 4 = @47
   rts                        ; 6

DrawIt
   ldy graphicPointerIndex    ; 3
   lda (graphicPointers + 10),y;5
   sta tempCharHolder         ; 3
   sta WSYNC
;--------------------------------------
   lda (graphicPointers + 8),y; 5
   tax                        ; 2
   lda (graphicPointers),y    ; 5
   SLEEP 2                    ; 2
   sta GRP0                   ; 3 = @17
   lda (graphicPointers + 2),y; 5
   sta GRP1                   ; 3 = @25
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @33
   lda (graphicPointers + 6),y; 5
   ldy tempCharHolder         ; 3
   sta GRP1                   ; 3 = @44
   stx GRP0                   ; 3 = @47
   sty GRP1                   ; 3 = @50
   sta GRP0                   ; 3 = @53
   dec graphicPointerIndex    ; 5
   bpl DrawIt                 ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @65
   sta GRP1                   ; 3 = @68
   sta NUSIZ0                 ; 3 = @71
   sta NUSIZ1                 ; 3 = @74
;--------------------------------------
   rts                        ; 6 = @04
;
; This routine takes 193 cycles (~2 1/2 scan lines) to execute. This 
; computation includes the 6 cycles from the JSR to get here.
;
SetupGraphicPointerData
   ldy #11                    ; 2
.setupGraphicsLoop
   lda (graphicDataPointers),y; 5
   sta graphicPointers,y      ; 5
   dey                        ; 2
   bpl .setupGraphicsLoop     ; 2³
   rts                        ; 6

NewRandomNumber
   jsr NextRandom
   jsr NextRandom
   jsr NextRandom
   lda random                       ; get new random value
   and #3                           ; make value 0 <= x <= 3
   cmp randomSeed
   bcs NewRandomNumber              ; branch if random seed less than 3
   rts

NextRandom
   lda random + 1
   asl
   eor random + 1
   asl
   asl
   rol random
   rol random + 1
   rts
;
; The routine below is never used.
;
SixDigitKernel
   ldy graphicPointerIndex    ; 3
   lda (graphicPointers + 10),y;5
   sta tempCharHolder         ; 3
   sta WSYNC
;--------------------------------------
   lda (graphicPointers + 8),y; 5
   tax                        ; 2
   lda (graphicPointers),y    ; 5
   sta GRP0                   ; 3 = @15
   lda (graphicPointers + 2),y; 5
   sta GRP1                   ; 3 = @23
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @31
   lda (graphicPointers + 6),y; 5
   ldy tempCharHolder         ; 3
   sta GRP1                   ; 3 = @42
   stx GRP0                   ; 3 = @45
   sty GRP1                   ; 3 = @48
   sta GRP0                   ; 3 = @51
   dec graphicPointerIndex    ; 5
   bpl SixDigitKernel         ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @63
   sta GRP1                   ; 3 = @66
   sta NUSIZ0                 ; 3 = @69
   sta NUSIZ1                 ; 3 = @72
;--------------------------------------
   rts                        ; 6 = @02

;
; Only sound channel 0 is used for this game. The sound table data is arranged
; in groups of 4...
; 1) duration timer...when 0 then sound is turned off
; 2) audio channel
; 3) audio frequency
; 4) audio volume
;
HittingPaddleSoundTable
   .byte 1, 12, 9, 8, 0
   
HittingBoundarySoundTable
   .byte 1, 12, 20, 15, 0
   
PointScoredSoundTable
   .byte 1, 14, 1, 10
   .byte 1, 14, 1, 15
   .byte 1, 14, 1, 10
   .byte 1, 14, 1, 15
   .byte 5, 14, 1, 10
   .byte 1, 14, 1, 15, 0
   
BallLaunchedSoundTable
   .byte 4, 15, 6, 8
   .byte 1, 15, 6, 0
   .byte 3, 15, 6, 5, 0
   
CheckToPlayGameSounds
   lda playSound                    ; get value to see if sound is to played
   bne .playGameSounds              ; play sound if not 0
   jmp .doneGameSounds
   
.playGameSounds
   ldy soundTableIndex              ; get the sound table index
   lda (soundPointers),y            ; read data from sound table
   beq .turnOffGameSounds
   cmp soundDuration                ; compare with current sound duration
   beq .incrementSoundIndex
   lda soundDuration                ; get current sound time duration
   bne .incrementSoundDurationTimer
   ldy soundTableIndex
   iny
   lda (soundPointers),y
   sta AUDC0
   iny
   lda (soundPointers),y
   sta AUDF0
   iny
   lda (soundPointers),y
   sta AUDV0
.incrementSoundDurationTimer
   inc soundDuration
   jmp .doneGameSounds
   
.incrementSoundIndex
   lda soundTableIndex              ; get the sound table index
   clc
   adc #4                           ; increment value by 4 for next read
   sta soundTableIndex
   lda #0
   sta soundDuration                ; reset sound duration timer
   jmp .playGameSounds
   
.turnOffGameSounds
   lda #0
   sta playSound                    ; set value to stop sound processing
   sta AUDC0
   sta AUDF0
   sta AUDV0
.doneGameSounds
   rts


Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set stack to the beginning
   lda #0
   ldx #0
.clearLoop
   sta VSYNC,x
   dex
   bne .clearLoop
   jsr GameInitialization
MainLoop
   jsr VerticalSync
   jsr CheckGameStateForAction
   jsr MoveObjects
   jsr CheckToPlayGameSounds
   jsr DisplayKernel
   jsr Overscan
   jmp MainLoop
   
VerticalSync
   ldx #0
   lda #START_VERT_SYNC
   sta WSYNC                        ; wait 3 scan lines before starting
   sta WSYNC                        ; vertical sync
   sta WSYNC
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC                        ; first line of vertical sync
   sta WSYNC                        ; second line of vertical sync
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank period
   lda #STOP_VERT_SYNC
   sta WSYNC                        ; third (final) line of vertical sync
   sta VSYNC                        ; end vertical sync (D1 = 0)
   rts

CheckGameStateForAction
   lda gameState                    ; get the current game state
   beq CheckToStartNewGame          ; branch if GAME_OVER
   cmp #BALL_LAUNCHED
   beq .doneCheckingGameState
   cmp #WAIT_FOR_BALL_LAUNCH
   beq .doneCheckingGameState
   lda gameTimer                    ; get game timer value
   beq .setGameOverState            ; set to GAME_OVER if reached 0
   dec gameTimer                    ; reduce game timer
   jmp .doneCheckingGameState
   
.setGameOverState
   lda #GAME_OVER
   sta gameState
   lda #0
   sta player1Score
   sta player2Score
.doneCheckingGameState
   sta WSYNC
   rts

CheckToStartNewGame
   lda INPT4                        ; read player 1 joystick button
   bmi .checkForPaddleController
   lda #CONTROLLER_TYPE_STICK
   sta controllerType               ; set controller type to joystick
.setBallLaunchedState
   lda #BALL_LAUNCHED
   sta gameState
   jsr LaunchPongBall
   lda #<BallLaunchedSoundTable
   ldy #>BallLaunchedSoundTable
   jsr SetupSoundVariables
   rts

.checkForPaddleController
   lda SWCHA                        ; read player 1 paddle button
   bmi ReadConsoleSwitches
   ldx #CONTROLLER_TYPE_PADDLE
   stx controllerType               ; set controller type to paddle
   jmp .setBallLaunchedState
   
ReadConsoleSwitches
   lda #SELECT_MASK
   bit SWCHB                        ; check console switch values
   beq .selectButtonPressed
   lda #$FF
   sta selectDebounce               ; any non-zero shows SELECT not pressed
   jsr NewRandomNumber
   rts

.selectButtonPressed
   lda selectDebounce               ; get select debounce value
   bne .changeGameSelection
   rts

.changeGameSelection
   lda #0
   sta selectDebounce               ; clear select debounce
   lda gameSelection                ; get current game selection
   beq .setToTwoPlayerGame          ; branch if set to one player game
   lda #ONE_PLAYER_GAME
   sta gameSelection                ; set game selection for one player game
   jmp .doneReadConsoleSwitches
   
.setToTwoPlayerGame
   lda #TWO_PLAYER_GAME
   sta gameSelection                ; set game selection for two player game
.doneReadConsoleSwitches
   rts

MoveObjects
   sta WSYNC
   lda gameState                    ; get the current game state
   beq .stopMovingPaddleBall        ; branch if GAME_OVER
   jsr MovePongBall
   lda gameSelection                ; get current game selection
   bne .checkToMoveRightPaddle      ; branch if two player game
   jsr RightPaddleAI
   jmp .checkToMoveLeftPaddle
   
.checkToMoveRightPaddle
   jsr CheckPlayer2JoystickValues
.checkToMoveLeftPaddle
   jsr CheckPlayer1JoystickValues
   jmp .doneMoveObjects
   
.stopMovingPaddleBall
   lda #HMOVE_0
   sta HMM1
.doneMoveObjects
   rts

DisplayKernel SUBROUTINE
   lda #BLACK
   sta COLUBK
   sta COLUPF
   sta COLUP0
   sta COLUP1
   lda #$FF
   sta PF0
   lda #$FF
   sta PF1
   sta PF2
   sta WSYNC
   lda #56
   ldy #0
   jsr HorizPositionPlayers
   lda #BLACK
   sta COLUBK
   sta COLUPF
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait two scan lines after vertical blank
   sta WSYNC                        ; timer is done
   lda #RED_ORANGE + 14
   sta COLUBK
   sta COLUPF
   ldy #3
.kernelWait
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .kernelWait            ; 2³
   sty VBLANK                 ; 3 = @07   enable TIA (D1 = 0)
   lda #<PongLiteral          ; 2
   sta graphicDataPointers    ; 3
   lda #>PongLiteral          ; 2
   sta graphicDataPointers + 1; 3
   jsr SetupGraphicPointerData; 6
   lda #H_FONT - 1            ; 2
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @05
   sta COLUBK                 ; 3 = @08
   sta WSYNC
;--------------------------------------
   lda #RED_ORANGE + 14       ; 2
   sta COLUBK                 ; 3 = @05
   sta COLUPF                 ; 3 = @08
   ldy #4                     ; 2
.pongLiteralBlankLines
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .pongLiteralBlankLines ; 2³
   sta WSYNC
;--------------------------------------
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @13   turn off vertical delay of GRP0
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #4                     ; 2
   sta cycleWait              ; 3
.wait31Cycles
   dec cycleWait              ; 5
   bne .wait31Cycles          ; 2³
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @45   coarse position net to pixel 135
   lda #1                     ; 2
   sta GRP0                   ; 3 = @50   draw pong net
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @05   turn off vertical delay for GRP0
   sta VDELP1                 ; 3 = @08   turn off vertical delay for GRP1
   sta WSYNC
;--------------------------------------
   lda #RED_ORANGE + 14       ; 2
   sta COLUPF                 ; 3 = @05
   lda #%01110000             ; 2
   sta PF0                    ; 3 = @10   draw left and right arcade borders
   lda #0                     ; 2
   sta PF1                    ; 3 = @15
   lda #0                     ; 2
   sta PF2                    ; 3 = @20
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @05
   lda #MSBL_SIZE2            ; 2
   sta NUSIZ1                 ; 3 = @10   set pong ball to double size
   lda gameState              ; 3         get the current game state
   bne .checkForControllerKernel; 2³        branch if game not over
   jmp JoystickGameKernel     ; 3
   
.checkForControllerKernel
   lda controllerType         ; 3         get controller type
   beq PaddleGameKernel       ; 2³        branch if CONTROLLER_TYPE_PADDLE
   jmp JoystickGameKernel     ; 3
   
PaddleGameKernel
   lda #DUMP_PORTS            ; 2
   ldx #ENABLE_TIA            ; 2
   sta VBLANK                 ; 3 = @29
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   stx VBLANK                 ; 3 = @38
   lda #0                     ; 2
   sta player1VertPos         ; 3
   sta player1PaddleValue     ; 3
   sta player2PaddleValue     ; 3
   lda player2VertPos         ; 3         get right paddle vertical position
   sta player2Scanline        ; 3         place value in scan line count
   lda #<-1                   ; 2
   sta ballHeight             ; 3
   lda #H_PADDLE              ; 2
   tax                        ; 2
   sta rightPaddleHeight      ; 3
   lda #H_BALL                ; 2
   sta ballHeight             ; 3
   sta WSYNC
;--------------------------------------
   lda gameState              ; 3         get the current game state
   cmp #BALL_LAUNCHED         ; 2
   bne .setBallOutOfRange     ; 2³
   lda ballVertPos            ; 3         get the ball's vertical position
   sta ballScanline           ; 3         set scan line (reduced in kernel)
   jmp .setRightPaddleHorizPos; 3
   
.setBallOutOfRange
   lda #<-1                   ; 2
   sta ballScanline           ; 3
.setRightPaddleHorizPos
   sta WSYNC
;--------------------------------------
   ldy #8                     ; 2
.coarseMoveRightPaddle
   SLEEP 2                    ; 2
   dey                        ; 2
   bpl .coarseMoveRightPaddle ; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @69
   lda #H_KERNEL              ; 2
   tay                        ; 2
   lda gameSelection          ; 3         get current game selection
;--------------------------------------
   bne TwoPlayerPaddleKernel  ; 2³+1      branch if a two player game
   jmp OnePlayerPaddleKernel  ; 3
   
   BOUNDARY 0

TwoPlayerPaddleKernel
   sta WSYNC
;--------------------------------------
   lda INPT0                  ; 3         read player 1 paddle value
   bmi .checkToDrawLeftPaddle ; 2³        check if capacitor charged
   inc player1PaddleValue     ; 5
   bne .checkToDrawPongBall   ; 3         unconditional branch
   
.checkToDrawLeftPaddle
   txa                        ; 2
   beq .skipLeftPaddleDraw    ; 2³
   dex                        ; 2
   lda #ENABLE_BM             ; 2
   sta ENAM0                  ; 3 = @17   draw left paddle
   bne .checkToDrawPongBall   ; 3         unconditional branch
   
.skipLeftPaddleDraw
   lda #DISABLE_BM            ; 2
   sta ENAM0                  ; 3 = @16
.checkToDrawPongBall
   lda ballScanline           ; 3         get ball scan line counter
   beq .drawPongBall          ; 2³        branch if scan line to activate ball
   dec ballScanline           ; 5         reduce ball scan line counter
   jmp .readPlayer2Paddle     ; 3
   
.drawPongBall
   lda ballHeight             ; 3         get ball height counter
   beq .disablePongBall       ; 2³
   dec ballHeight             ; 5         reduce ball height counter
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3         enable pong ball (M1)
   bne .readPlayer2Paddle     ; 3         unconditional branch
   
.disablePongBall
   lda #DISABLE_BM            ; 2
   sta ENAM1                  ; 3
.readPlayer2Paddle
   lda INPT1                  ; 3 = @47   worst case cycle count
   bmi .checkToDrawRightPaddle; 2³        check if player 2 capacitor charged
   inc player2PaddleValue     ; 5
   bne .nextScanline          ; 3         unconditional branch
   
.checkToDrawRightPaddle
   lda rightPaddleHeight      ; 3
   beq .skipRightPaddleDraw   ; 2³
   dec rightPaddleHeight      ; 5
   lda #%10000000             ; 2
   sta GRP1                   ; 3 = @65
   bne .nextScanline          ; 3         unconditional branch
   
.skipRightPaddleDraw
   lda #0                     ; 2
   sta GRP1                   ; 3 = @61
.nextScanline
   dey                        ; 2         reduce scan line count
   bne TwoPlayerPaddleKernel  ; 2³
   lda player1PaddleValue     ; 3
   sta player1VertPos         ; 3         set player 1 new vertical position
   lda player2PaddleValue     ; 3
   sta player2VertPos         ; 3         set player 2 new vertical position
   jmp ScoreKernel            ; 3
   
   BOUNDARY 0
   
OnePlayerPaddleKernel SUBROUTINE
   sta WSYNC
;--------------------------------------
   lda INPT0                  ; 3         read player 1 paddle value
   bmi .checkToDrawLeftPaddle ; 2³        check if capacitor charged
   inc player1PaddleValue     ; 5
   bne .checkToDrawPongBall   ; 3         unconditional branch
   
.checkToDrawLeftPaddle
   txa                        ; 2
   beq .skipLeftPaddleDraw    ; 2³
   dex                        ; 2
   lda #ENABLE_BM             ; 2
   sta ENAM0                  ; 3 = @17   draw left paddle
   bne .checkToDrawPongBall   ; 3         unconditional branch

.skipLeftPaddleDraw
   stx ENAM0                  ; 3 = @14
.checkToDrawPongBall
   lda ballScanline           ; 3         get ball scan line counter
   beq .drawPongBall          ; 2³        branch if scan line to activate ball
   dec ballScanline           ; 5         reduce ball scan line counter
   jmp .checkToDrawRightPaddle; 3
   
.drawPongBall
   lda ballHeight             ; 3         get ball height counter
   beq .disablePongBall       ; 2³
   dec ballHeight             ; 5         reduce ball height counter
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3 = @41   enable pong ball (M1)
   bne .checkToDrawRightPaddle; 3         unconditional branch

.disablePongBall
   sta ENAM1                  ; 3
.checkToDrawRightPaddle
   lda player2Scanline        ; 3         get right paddle scan line counter
   beq .drawRightPaddle       ; 2³        branch if scan line for right paddle
   dec player2Scanline        ; 5         reduce right paddle scan line count
   jmp .nextScanline          ; 3
   
.drawRightPaddle
   lda rightPaddleHeight      ; 3         get right paddle height counter
   beq .skipRightPaddleDraw   ; 2³
   dec rightPaddleHeight      ; 5         reduce right paddle height counter
   lda #%10000000             ; 2
   sta GRP1                   ; 3 = @65   draw right paddle
   bne .nextScanline          ; 3         unconditional branch
   
.skipRightPaddleDraw
   sta GRP1                   ; 3 = @59
.nextScanline
   dey                        ; 2
   bne OnePlayerPaddleKernel  ; 2³
   lda player1PaddleValue     ; 3         get player 1 paddle value
   sta player1VertPos         ; 3         set player 1 new vertical position
   jmp ScoreKernel            ; 3
   
JoystickGameKernel SUBROUTINE
   lda player1VertPos         ; 3
   sta player1PaddleValue     ; 3
   lda player2VertPos         ; 3         get right paddle vertical position
   sta player2PaddleValue     ; 3
   lda #H_PADDLE              ; 2
   tax                        ; 2
   sta rightPaddleHeight      ; 3
   lda #H_BALL                ; 2
   sta ballHeight             ; 3
   sta WSYNC
;--------------------------------------
   lda gameState              ; 3         get the current game state
   cmp #BALL_LAUNCHED         ; 2
   bne .setBallOutOfRange     ; 2³
   lda ballVertPos            ; 3         get the ball's vertical position
   sta ballScanline           ; 3
   jmp .setRightPaddleHorizPos; 3
   
.setBallOutOfRange
   lda #<-1                   ; 2
   sta ballScanline           ; 3
.setRightPaddleHorizPos
   sta WSYNC
;--------------------------------------
   ldy #8                     ; 2
.coarseMoveRightPaddle
   SLEEP 2                    ; 2
   dey                        ; 2
   bpl .coarseMoveRightPaddle ; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @69
   ldy #H_KERNEL              ; 2
.kernelLoop
   sta WSYNC
;--------------------------------------
   lda player1PaddleValue     ; 3
   beq .checkToDrawLeftPaddle ; 2³
   dec player1PaddleValue     ; 5
   jmp .checkToDrawPongBall   ; 3
   
.checkToDrawLeftPaddle
   txa                        ; 2
   beq .skipLeftPaddleDraw    ; 2³
   dex                        ; 2
   lda #ENABLE_BM             ; 2
   sta ENAM0                  ; 3 = @17   draw left paddle
   bne .checkToDrawPongBall   ; 3         unconditional branch

.skipLeftPaddleDraw
   stx ENAM0                  ; 3 = @14
.checkToDrawPongBall
   lda ballScanline           ; 3         get ball scan line counter
   beq .drawPongBall          ; 2³        branch if scan line to activate ball
   dec ballScanline           ; 5         reduce ball scan line counter
   jmp .checkToDrawRightPaddle; 3

.drawPongBall
   lda ballHeight             ; 3         get ball height counter
   beq .disablePongBall       ; 2³
   dec ballHeight             ; 5         reduce ball height counter
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3 = @41   enable pong ball (M1)
   bne .checkToDrawRightPaddle; 3         unconditional branch

.disablePongBall
   sta ENAM1                  ; 3
.checkToDrawRightPaddle
   lda player2PaddleValue     ; 3         get right paddle scan line counter
   beq .drawRightPaddle       ; 2³        branch if scan line for right paddle
   dec player2PaddleValue     ; 5         reduce right paddle scan line count
   jmp .nextScanline          ; 3
   
.drawRightPaddle
   lda rightPaddleHeight      ; 3         get right paddle height counter
   beq .skipRightPaddleDraw   ; 2³
   dec rightPaddleHeight      ; 5         reduce right paddle height counter
   lda #%10000000             ; 2
   sta GRP1                   ; 3 = @65   draw right paddle
   bne .nextScanline          ; 3         unconditional branch
   
.skipRightPaddleDraw
   sta GRP1                   ; 3 = @59
.nextScanline
   dey                        ; 2
   bne .kernelLoop            ; 2³
   jmp ScoreKernel            ; 3         could fall through
   
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda #RED_ORANGE + 14       ; 2
   sta COLUBK                 ; 3 = @05
   lda #0                     ; 2
   sta GRP0                   ; 3 = @10   clear GRP0 graphic data
   sta GRP1                   ; 3 = @13   clear GRP1 graphic data
   sta ENAM0                  ; 3 = @16
   sta ENAM1                  ; 3 = @19
   sta ENABL                  ; 3 = @22
   sta HMCLR                  ; 3 = @25
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #56                    ; 2
   ldy #0                     ; 2
   jsr HorizPositionPlayers   ; 6
   sta WSYNC
;--------------------------------------
   lda #RED_ORANGE + 14       ; 2
   sta COLUBK                 ; 3 = @05
   sta COLUPF                 ; 3 = @08
   lda #0                     ; 2
   sta PF0                    ; 3 = @13   clear playfield registers
   sta PF1                    ; 3 = @16
   sta PF2                    ; 3 = @19
   ldy #4                     ; 2
.blankScoreKernelLines
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .blankScoreKernelLines ; 2³
   lda gameState              ; 3         get the current game state
   bne .setGraphicPtrsForScore; 2³        branch if game not over
   jmp GameSelectionKernel    ; 3
   
.setGraphicPtrsForScore
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   lda #MSBL_SIZE4 | THREE_COPIES ; 2
   sta NUSIZ0                 ; 3 = @13
   sta NUSIZ1                 ; 3 = @16
   lda player1Score           ; 3         get player 1's score
   cmp #SCORE_MAX - 1         ; 2         see if need to set tens position
   bcs .setPlayer1TensPosition; 2³
   jmp .setPlayer1ScoreMSBValue; 3
   
.setPlayer1TensPosition
   clc                        ; 2         increment by 6 to point to tens
   adc #6                     ; 2         pointer value
.setPlayer1ScoreMSBValue
   clc                        ; 2
   sta temp                   ; 3
   and #$F0                   ; 2         mask lower nybbles
   ror                        ; 2         divide value by 8
   ror                        ; 2
   ror                        ; 2
   tay                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers        ; 3
   iny                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers+1      ; 3
   lda temp                   ; 3
   and #$0F                   ; 2         mask upper nybbles
   clc                        ; 2
   rol                        ; 2         multiply value by 2
   tay                        ; 2
   lda NumberTable,y          ; 4
;--------------------------------------
   sta graphicPointers + 2    ; 3 = @01
   iny                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers + 3    ; 3
   lda #<Blank                ; 2
   sta graphicPointers + 4    ; 3
   sta graphicPointers + 6    ; 3
   lda #>Blank                ; 2
   sta graphicPointers + 5    ; 3
   sta graphicPointers + 7    ; 3
   lda player2Score           ; 3         get player 2's score
   cmp #SCORE_MAX - 1         ; 2 = @31   see if need to set tens position
   bcs .setPlayer2TensPosition; 2³
   jmp .setPlayer2ScoreMSBValue; 3
   
.setPlayer2TensPosition
   clc                        ; 2         increment by 6 to point to tens
   adc #6                     ; 2         pointer value
.setPlayer2ScoreMSBValue
   sta temp                   ; 3
   and #$F0                   ; 2         mask lower nybbles
   ror                        ; 2         divide value by 8
   ror                        ; 2
   ror                        ; 2
   tay                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers + 8    ; 3
   iny                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers + 9    ; 3
   lda temp                   ; 3
   and #$0F                   ; 2         mask upper nybbles
   clc                        ; 2
   rol                        ; 2         multiply value by 2
;--------------------------------------
   tay                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers + 10   ; 3
   iny                        ; 2
   lda NumberTable,y          ; 4
   sta graphicPointers + 11   ; 3
   lda #H_FONT - 1            ; 2
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   lda #0                     ; 2
   sta PF0                    ; 3 = @13
   sta PF1                    ; 3 = @16
   sta PF2                    ; 3 = @19
   ldy #20                    ; 2
.skipLinesForScoreKernel
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .skipLinesForScoreKernel;2³
   jmp ExitDisplayKernel      ; 3
   
GameSelectionKernel
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   lda #MSBL_SIZE4 | THREE_COPIES; 2
   sta NUSIZ0                 ; 3 = @13
   sta NUSIZ1                 ; 3 = @16
   lda #BRICK_RED + 8         ; 2
   sta WSYNC
;--------------------------------------
   lda #BRICK_RED + 14        ; 2
   sta COLUPF                 ; 3 = @05
   lda gameSelection          ; 3         get current game selection
   bne .drawOnePlayerLiteral  ; 2³        branch if set for two players
   lda #0                     ; 2
   sta PF0                    ; 3 = @15
   lda #0                     ; 2
   sta PF1                    ; 3 = @20
   lda #$FF                   ; 2
   sta PF2                    ; 3 = @25
.drawOnePlayerLiteral
   lda #<OnePlayerLiteral     ; 2
   sta graphicDataPointers    ; 3
   lda #>OnePlayerLiteral     ; 2
   sta graphicDataPointers + 1; 3
   jsr SetupGraphicPointerData; 6
   lda #H_FONT - 1            ; 2
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   lda #0                     ; 2
   sta PF0                    ; 3 = @13
   sta PF1                    ; 3 = @16
   sta PF2                    ; 3 = @19
   ldy #1                     ; 2
.skipKernelLine
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .skipKernelLine        ; 2³
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @13
   sta NUSIZ1                 ; 3 = @16
   lda gameSelection          ; 3         get current game selection
   beq .drawTwoPlayerLiteral  ; 2³        branch if set for one player
   lda #0                     ; 2
   sta PF0                    ; 3 = @26
   lda #0                     ; 2
   sta PF1                    ; 3 = @31
   lda #$FF                   ; 2
   sta PF2                    ; 3 = @36
   jmp .drawTwoPlayerLiteral  ; 3         could fall through
   
.drawTwoPlayerLiteral
   lda #<TwoPlayerLiteral     ; 2
   sta graphicDataPointers    ; 3
   lda #>TwoPlayerLiteral     ; 2
   sta graphicDataPointers + 1; 3
   jsr SetupGraphicPointerData; 6
   lda #H_FONT - 1            ; 2
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta GRP0                   ; 3 = @11
   sta GRP1                   ; 3 = @14
   sta PF0                    ; 3 = @17
   sta PF1                    ; 3 = @20
   sta PF2                    ; 3 = @23
   ldy #3                     ; 2
.skipMoreKernelLines
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bne .skipMoreKernelLines   ; 2³
ExitDisplayKernel
   lda #DISABLE_TIA           ; 2
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3
   sty PF0                    ; 3 = @06
   sty PF1                    ; 3 = @09
   sty PF1                    ; 3 = @12
   sty GRP0                   ; 3 = @15
   sty GRP1                   ; 3 = @18
   sty ENAM0                  ; 3 = @21
   sty ENAM1                  ; 3 = @24
   sty ENABL                  ; 3 = @27   ball not used
   rts                        ; 6

Overscan
   ldx #17
.skipOverscanLines_0
   sta WSYNC
   dex
   bne .skipOverscanLines_0
   sta WSYNC
   sta WSYNC
   ldy #2
.coarseMoveLeftPaddle
   SLEEP 2
   dey
   bpl .coarseMoveLeftPaddle
   SLEEP 2
   sta RESM0                        ; set move left paddle @31 (i.e. pixel 93)
   sta WSYNC
   lda #HMOVE_0
   sta HMP0
   sta HMP1
   sta HMM0
   sta HMBL
   lda ballHMOVEValue
   sta HMM1
   sta HMOVE                        ; HMOVE hit @ cycle 21
   ldx #10
.skipOverscanLines_1
   sta WSYNC
   dex
   bne .skipOverscanLines_1
   rts

GameInitialization
   lda #RED_ORANGE + 14
   sta COLUPF
   lda #BRICK_RED + 14
   sta COLUP1
   lda #BLUE + 14
   sta COLUP0
   lda #MSBL_SIZE4
   sta NUSIZ1
   lda #BLACK
   sta COLUBK
   lda #MSBL_SIZE2 | PF_REFLECT
   sta CTRLPF
   lda #0
   sta VDELBL
   lda #HMOVE_L1
   sta ballHMOVEValue
   lda #RANDOM_SEED
   sta random
   sta random + 1
   sta randomSeed
   jsr LaunchPongBall
   rts

   .org ROM_BASE + 4096 - 4, - 1    ; 4K ROM
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector