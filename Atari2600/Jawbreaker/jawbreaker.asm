   LIST OFF
; ***  J A W B R E A K E R  ***
; (c) 1982 Tiger Electronic Toys, Inc.
; Designer: John Harris

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: January 14, 2005
;
;  *** 123 BYTES OF RAM USED 5 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, TIGER ELECTRONIC TOYS, INC.                  =
; =                                                                            =
; ==============================================================================
;
; - This game was know as Sierra Online's Jawbreaker II for the A8
; - This game uses the actual horizontal positioning value
;   (i.e. FINE_MOTION | COARSE_VALUE) for the position of the sprites. This
;   makes the horizontal calculations look a bit awkward. The value is
;   incremented/decremented by 16 and if there is an over flow 15 is added/
;   subtracted from the value to get the new position.
; - The PF is used as a masking. In other words the playfield is inverted. The
;   player sees the background. The playfield is BLACK and the background is
;   colored. Notice how when the player eats a candy bar the value is OR'd
;   to store the value vs. AND'd to remove it.
; - SWCHA is not used to read the joystick values. Instead John uses location
;   $0288. This value returns the same value as SWCHA. It's not known why this
;   register was used. Some theories are John didn't know about SWCHA, he
;   tried to confuse people coming behind him, or the value was double
;   meaning. Maybe it was used for a table read or to skip code (this was not
;   confirmed in the disassembly though).
; - RAM location $D6 isn't used
; - The game speeds aren't adjusted for PAL50.
; - This game uses a lot of overlays and flags.

   processor 6502
      
;
; Set the read address base so this runs on the real VCS and compiles to the
; exact ROM image. This must be done before including the vcs.h header file.
;
TIA_BASE_READ_ADDRESS = $30

   include "tia_constants.h"
   include "vcs.h"
   include "macro.h"

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
; A S S E M B L E R - S W I T C H E S
;===============================================================================

NTSC                    = 0
PAL50                   = 1
PAL60                   = 2

TRUE                    = 1
FALSE                   = 0

   IFNCONST COMPILE_REGION

COMPILE_REGION          = NTSC      ; change to compile for different regions

   ENDIF

   IF !(COMPILE_REGION = NTSC || COMPILE_REGION = PAL50 || COMPILE_REGION = PAL60)

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0, PAL50 = 1, PAL60 = 2"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 38
OVERSCAN_TIME           = 31

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 69
OVERSCAN_TIME           = 57
   
   ENDIF

;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0F
RED                     = $44

   IF COMPILE_REGION = NTSC

FIRST_SMILEY_COLOR      = $CA
SECOND_SMILEY_COLOR     = $8A
THIRD_SMILEY_COLOR      = $2A
FOURTH_SMILEY_COLOR     = $4A
PURPLE                  = $60
PLAYER1_LIVES_COLOR     = $6C
PLAYER2_LIVES_COLOR     = $AC
PLAYER1_ACTIVE_LIVES_COLOR = $EF
PLAYER2_ACTIVE_LIVES_COLOR = $CF
PLAYER1_SCORE_COLOR     = RED
PLAYER2_SCORE_COLOR     = $C4

   ELSE

FIRST_SMILEY_COLOR      = $CA
SECOND_SMILEY_COLOR     = $DA
THIRD_SMILEY_COLOR      = $7A
FOURTH_SMILEY_COLOR     = $4A
PURPLE                  = $80
PLAYER1_LIVES_COLOR     = $0F
PLAYER2_LIVES_COLOR     = $0F
PLAYER1_ACTIVE_LIVES_COLOR = $2F
PLAYER2_ACTIVE_LIVES_COLOR = $5D
PLAYER1_SCORE_COLOR     = $36
PLAYER2_SCORE_COLOR     = $96

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

VSYNC_TIME              = 24

COLOR_LIGHT_LUM         = $F7

H_FONT                  = 8
H_PLAYER                = 10
H_SMILEY                = 12
H_ROW                   = 18

XMIN                    = HMOVE_L7 | 0
XMAX                    = HMOVE_R1 | 9

YMIN                    = 6
YMID                    = 77
YMAX                    = 149

PLAYER_XMIN             = HMOVE_R3 | 4
PLAYER_XMID             = HMOVE_L7 | 9
PLAYER_XMAX             = HMOVE_L3 | 13

TOOTHBRUSH_XMIN         = HMOVE_L1 | 4
TOOTHBRUSH_XMAX         = HMOVE_L4 | 8

PASS_THROUGH_XMIN       = HMOVE_L5 | 1
PASS_THROUGH_XMAX       = HMOVE_R6 | 8

INIT_SELECT_DEBOUNCE    = $94
INIT_VITAMIN_TIME       = 63

NUM_RAM_CANDY           = 36

MAX_GAME_SELECTION      = 6
MAX_GAME_BOARD          = 8

MAX_SMILEY_ANIMATIONS   = 8

MAX_KERNEL_SECTIONS     = 9
NUM_PASS_THROUGH_GAPS   = 8

NUM_CANDY_BARS          = 135
STARTING_NUM_LIVES      = 3
MAX_NUM_SMILIES         = 4
MAX_NUM_LIVES           = 4

PLAYER1_CANDY_MASK      = %10101010
PLAYER2_CANDY_MASK      = %01010101

; point values (BCD)
MUNCHING_CANDY_POINT_VALUE = $01
MUNCHING_SMILEY_POINT_VALUE = $20
LEVEL_DONE_POINT_VALUE  = $50

; player state mask values
MASK_LIVES              = %111

; game state mask values
MASK_GAME_SELECTION     = %111
MASK_GAME_RUNNING       = %10000000

; player frame state mask vales
MASK_DIRECTION          = %11110000
MASK_DIRECTION_HORIZ    = %00110000
MASK_DIRECTION_VERT     = %11000000
DIRECTION_DOWN          = %10000000
DIRECTION_UP            = %01000000
DIRECTION_RIGHT         = %00100000
DIRECTION_LEFT          = %00010000

; smiley directions
FIRST_SMILEY_TRAVEL_LEFT = %00010000
SECOND_SMILEY_TRAVEL_LEFT = %00100000
THIRD_SMILEY_TRAVEL_LEFT = %01000000
FOURTH_SMILEY_TRAVEL_LEFT = %10000000

MASK_ANIMATION          = %1111

RAND_EOR_8              = $4D

; frame rate values
MOVE_FRAME_RATE_6       = $67
MOVE_FRAME_RATE_7       = $77
MOVE_FRAME_RATE_8       = $87
MOVE_FRAME_RATE_9       = $97
MOVE_FRAME_RATE_10      = $A7
MOVE_FRAME_RATE_11      = $B7

; player frame delay values
INIT_PLAYER_DELAY_VALUE = MOVE_FRAME_RATE_8
FAST_MOVING_PLAYER      = $08       ; move 8 out of 8 frames (no frame delay)
SLOW_MOVING_PLAYER      = $07       ; move 7 out of 8 frames

; smiley frame delay values
FAST_MOVING_SMILEY      = $08
MEDIUM_MOVING_SMILEY    = $06
SLOW_MOVING_SMILEY      = $05

;
; bit equates
;
D7                      = %10000000
D6                      = %01000000
D5                      = %00100000
D4                      = %00010000
D3                      = %00001000
D2                      = %00000100
D1                      = %00000010
D0                      = %00000001

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

tempVariables           ds 2
;--------------------------------------
digitPointers           = tempVariables
;--------------------------------------
tmpPassThroughDirections = digitPointers
;--------------------------------------
tmpSmileyDirections     = tempVariables
;--------------------------------------
tmpMovementDelta        = tempVariables
;--------------------------------------
tmpSmileyRowValues      = tmpMovementDelta
;--------------------------------------
vertMovementDelta       = tmpMovementDelta
horizMovementDelta      = vertMovementDelta + 1
;--------------------------------------
smileyGraphicsPointer   = tempVariables
;--------------------------------------
playerCoarseXPos        = tempVariables
playerFineXPos          = playerCoarseXPos + 1
;--------------------------------------
playerPFPixelValue      = playerCoarseXPos
;--------------------------------------
bitPointerCandyRAM      = playerPFPixelValue
tmpSmileyXPos           ds 2
;--------------------------------------
playerGraphicsPointer   = tmpSmileyXPos
;--------------------------------------
candyRAMPointer         = playerGraphicsPointer
;--------------------------------------
kernelCandyBarPatterns  = tempVariables
;--------------------------------------
leftCandyBarPatterns    = kernelCandyBarPatterns
;--------------------------------------
leftPF1CandyBarPattern  = leftCandyBarPatterns
leftPF2CandyBarPattern  = leftPF1CandyBarPattern + 1
rightCandyBarPatterns   = kernelCandyBarPatterns + 2
;--------------------------------------
rightPF2CandyBarPattern = rightCandyBarPatterns
rightPF1CandyBarPattern = rightPF2CandyBarPattern + 1
frameDelayDifference    ds 1
;--------------------------------------
frameDelayMSB           = frameDelayDifference
;--------------------------------------
newFrameDelayLSB        = frameDelayMSB
;--------------------------------------
skipAllowMotionState    = newFrameDelayLSB
;--------------------------------------
kernelSection           = skipAllowMotionState
playerGraphicIndex      ds 1
;--------------------------------------
holdDelayMotionValue    = playerGraphicIndex
smileyIndex             ds 1        ; used in kernel
tmpSmileyGraphics       ds 1        ; used in kernel
;--------------------------------------
tmpPlayerGraphics_a     = tmpSmileyGraphics
tempDigit               ds 1
;--------------------------------------
tmpPlayerXPos           = tempDigit
;--------------------------------------
tmpSmileyCoarseValue    = tmpPlayerXPos ; used in kernel
;--------------------------------------
lowestSmileyRowValue    = tmpSmileyCoarseValue
tmpScanlineCount        ds 1
;--------------------------------------
tmpPlayerGraphics_b     = tmpScanlineCount
;--------------------------------------
loopCount               = tmpPlayerGraphics_b
playerGraphics          ds H_PLAYER
smileyRowValues         ds MAX_NUM_SMILIES
;--------------------------------------
toothbrushRow           = smileyRowValues
smileyHorizValues       ds MAX_NUM_SMILIES
;--------------------------------------
toothbrushHorizValue   = smileyHorizValues
smileyDelayMotion       ds MAX_NUM_SMILIES
smileyColors            ds MAX_NUM_SMILIES
;--------------------------------------
playerDeathAnimationIndex = smileyColors
;--------------------------------------
toothbrushSoundIndexes  = playerDeathAnimationIndex + 1
;--------------------------------------
toothbrushSoundIndex1   = toothbrushSoundIndexes
toothbrushSoundIndex2   = toothbrushSoundIndexes + 1
toothbrushSoundIndex3   = toothbrushSoundIndexes + 2
smileyGraphics          ds H_SMILEY
playfieldCandy          ds 36
;--------------------------------------
leftPF1Candy            = playfieldCandy
leftPF2Candy            = leftPF1Candy + MAX_KERNEL_SECTIONS
rightPF2Candy           = leftPF2Candy + MAX_KERNEL_SECTIONS
rightPF1Candy           = rightPF2Candy + MAX_KERNEL_SECTIONS
smileyInSection         ds 1
selectDebounce          ds 1
unused_01               ds 1        ; unused ZP RAM
passThroughGapDelayMotion ds 1
ballHorizPos            ds NUM_PASS_THROUGH_GAPS
playerStates            ds 2
;--------------------------------------
player1State            = playerStates
player2State            = player1State + 1
frameDelay              ds 1        ; used to delay player movements
vitaminActiveTimer      ds 1        ; time player can eat smilies
randomSeed              ds 1
gameState               ds 1
numCandyBarsEaten       ds 2
;--------------------------------------
player1NumCandyBarsEaten = numCandyBarsEaten
player2NumCandyBarsEaten = player1NumCandyBarsEaten + 1
gameBoardState          ds 1
playerDelayMotion       ds 1
playerHorizPos          ds 1
playerVertPos           ds 1
playerScoreLSB          ds 2
;--------------------------------------
player1ScoreLSB         = playerScoreLSB
player2ScoreLSB         = player1ScoreLSB + 1
gameTimer               ds 1
passThroughDirections   ds 1
smileyDirections        ds 1
smileyAnimationIndex    ds 1
playerFrameState        ds 1        ; ddddaaaa d = direction - a = animation frame
levelNumber             ds 1
smileyIndexes           ds MAX_NUM_SMILIES
currentSmileyNumber     ds 1        ; used in kernel
soundIndex              ds 1
playerScoreMSB          ds 2
;--------------------------------------
player1ScoreMSB         = playerScoreMSB
player2ScoreMSB         = player1ScoreMSB + 1

   echo "***",(* - $80 - 1)d, "BYTES OF RAM USED", ($100 - * + 1)d, "BYTES FREE"

;============================================================================
; R O M - C O D E (BANK 0)
;============================================================================

   SEG Bank0
   .org ROM_BASE

Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   dex
   bne .clearLoop
   sta gameState
   dex                              ; x = #$FF
   txs                              ; set stack to the beginning
   lda #MSBL_SIZE8 | PF_REFLECT
   sta CTRLPF
   sta randomSeed
   ldx #MAX_KERNEL_SECTIONS - 2     ; only 8 sections have pass throughs
.setInitPassThroughPositions
   txa
   clc
   adc #1
   sta ballHorizPos,x
   dex
   bpl .setInitPassThroughPositions
   lda #%10100100                   ; set initial pass through directions
   sta passThroughDirections        ; 0 = move right 1 = move left
   lda #$0D
   sta passThroughGapDelayMotion
   ldx #9
   stx WSYNC                        ; wait for next scan line
.coarseMoveVitamin
   dex
   bne .coarseMoveVitamin
   sta RESM0                        ; position vitamin @ pixel 141
   jsr ResetPlayfieldState
   lda #INIT_PLAYER_DELAY_VALUE
   sta playerDelayMotion
   jmp Overscan

; Understanding how the frame movements are calculated
; ----------------------------------------------------------------------------
; This game uses fractional delay values to control the movement of the
; objects. Unfortunatley the values weren't changed for the PAL50 version so the
; PAL50 version of the game runs slower than the NTSC version.
;
; To get the movement of the object use the formula...
; frameDelay / delayMotionValueMSB
; This will give you how many frames the object is allowed to move.

DetermineIfTimeToMoveObject
   sta holdDelayMotionValue         ; save delay motion for later
   lsr                              ; divide the frame delay value by 16
   lsr                              ; so the upper nybbles now reside in
   lsr                              ; the lower nybbles
   lsr
   sta frameDelayMSB                ; save it for later
   lda holdDelayMotionValue         ; get the delay motion value
   and #$0F                         ; mask upper nybbles
   sec
   sbc frameDelay                   ; subtract the current frame delay value
   bpl .delayObjectMotion           ; delay motion if the value is positive
   ldy #<-1
.getNewFrameDelayLSB
   iny
   clc
   adc frameDelayMSB
   bmi .getNewFrameDelayLSB
   sta newFrameDelayLSB             ; save new frame delay LSB
   lda holdDelayMotionValue         ; get current frame delay value
   and #$F0                         ; mask LSB
   ora newFrameDelayLSB             ; or in new LSB for new frame delay value
   sty skipAllowMotionState
   clc                              ; clear carry to allow movement this frame
   rts

.delayObjectMotion
   sta frameDelayDifference         ; save the difference from subrtaction
   lda holdDelayMotionValue         ; get initial delay motion value
   and #$F0                         ; mask lower nybbles
   ora frameDelayDifference         ; or in new lower nybble values
   sec                              ; set carry to skip movement this frame
   rts

ResetCandyPlayfield
   ldx #NUM_RAM_CANDY
.resetCandyPlayfieldLoop
   lda player1State                 ; check to see if player 1 is active
   beq .skipPlayer2Reset
   asl                              ; shift active player flag to carry
   ldy #0
   lda #PLAYER1_CANDY_MASK
   bcs .resetPlayer2CandyEaten
   sty player1NumCandyBarsEaten     ; reset number of candy eaten by player 1
   bcc .skipPlayer2Reset            ; unconditional branch
   
.resetPlayer2CandyEaten
   sty player2NumCandyBarsEaten     ; reset number of candy eaten by player 2
   lda #PLAYER2_CANDY_MASK
.skipPlayer2Reset
   and playfieldCandy - 1,x
   sta playfieldCandy - 1,x
   cpx #10
   bcs .nextCandySet
   ora #%11000000
   sta playfieldCandy - 1,x
.nextCandySet
   dex
   bne .resetCandyPlayfieldLoop
   rts

IncrementScore
   tay                              ; move points to y temporarily
   jsr SetXForActivePlayer          ; determine which player is active
   tya                              ; restore accumulator with point value
   sed                              ; set decimal mode
   clc
   adc playerScoreLSB,x
   sta playerScoreLSB,x
   lda playerScoreMSB,x
   adc #0
   sta playerScoreMSB,x
   cld                              ; clear decimal mode
   rts

SetXForActivePlayer
   ldx #0                           ; assume player 1 is active
   lda player1State                 ; get player 1's state
   bpl .leaveRoutine                ; leave routine if player 1 is active
   ldx #1                           ; set for player 2 active
.leaveRoutine
   rts

DetermineRowOfPlayer
   lda playerVertPos                ; get the player's vertical position
   ldy #0
   sec
   sbc #5
   beq .doneDetermineRowOfPlayer
.incrementRowNumber
   iny
   sec
   sbc #H_ROW
   beq .doneDetermineRowOfPlayer
   cmp #192
   bcc .incrementRowNumber
.doneDetermineRowOfPlayer
   rts

BCDToDigits
   sta tempDigit              ; 3
   and #$F0                   ; 2         mask the lower nybbles
   lsr                        ; 2         divide the value by 2
   clc                        ; 2
   adc #<NumberFonts          ; 2         add in number font LSB
   sta digitPointers,x        ; 4         set LSB pointer to digit
   lda #>NumberFonts          ; 2         get the number fon MSB
   adc #0                     ; 2
   sta digitPointers + 1,x    ; 4         set MSB pointer to digit
   lda tempDigit              ; 3 = @26   reload accumulator with digit
LSBToDigits
   and #$0F                   ; 2         mask the upper nybble
   asl                        ; 2         muliply the value by 8
   asl                        ; 2
   asl                        ; 2
   clc                        ; 2
   adc #<NumberFonts          ; 2         add in number font LSB
   sta digitPointers + 2,x    ; 4         set LSB pointer to digit
   lda #>NumberFonts          ; 2
   adc #0                     ; 2
   sta digitPointers + 3,x    ; 4         set MSB pointer to digit
   rts                        ; 6 = @30

ResetPlayfieldState
   jsr ResetCandyPlayfield
   lda #INIT_VITAMIN_TIME
   sta gameBoardState
   stx AUDC0                        ; set audio channels to 0 (x = 0)
   stx AUDC1
ResetPlayerPositions
   jsr SetSmileyAttributes
   ldx #MAX_NUM_SMILIES - 1
.setInitSmileyValues
   txa                              ; move smiley number to accumulator
   sta smileyIndexes,x
   asl                              ; multiply smiley number by 2
   adc #1                           ; increment the value by 1
   sta smileyRowValues,x            ; to set smiley initial row value and
   sta smileyHorizValues,x          ; set smiley's init horizontal position
   dex
   bpl .setInitSmileyValues
   ldx #H_PLAYER - 1
.setInitJawGraphics
   lda InitJawGraphics,x
   sta playerGraphics,x
   dex
   bpl .setInitJawGraphics
   lda #PLAYER_XMID
   sta playerHorizPos               ; center player horizontally
   lda #YMID
   sta playerVertPos                ; center player vertically
   inx                              ; x = 0
   stx COLUPF                       ; set playfield color to BLACK
   stx playerFrameState
   stx vitaminActiveTimer
   lda #%10100000
   sta smileyDirections             ; set initial smiley directions
   lda gameBoardState               ; get the current board state
   ora #INIT_VITAMIN_TIME
   sta gameBoardState
   lda #PURPLE + 6
   sta COLUBK                       ; set background color
   rts

SetSmileyAttributes
   lda levelNumber                  ; get current level number
   ldx player1State                 ; check to see if player 1 is active
   bpl .maskLevelNumber             ; branch if not (i.e. player 2 active)
   lsr                              ; shift player 1 level number into lower
   lsr                              ; nybbles
   lsr
.maskLevelNumber
   and #$07
   asl                              ; multiply value by 4
   asl
   tay
   ldx #MAX_NUM_SMILIES - 1
.setAttributes
   lda SmileyColorTable,x
   sta smileyColors,x
   lda SmileyDelayMotionValues,y
   sta smileyDelayMotion,x
   iny
   dex
   bpl .setAttributes
   rts

; Comments on this from David Galloway:
; This constant doesn't give proper coverage. The sequence repeats after 35
; iterations.
;
; If they had only used #$4E then the sequence is a proper LFSR with 127
; iterations before repeat covering every value from 1 - 127
NextRandom
   lda randomSeed
   asl
   bcc .skipXOR
   eor #RAND_EOR_8
.skipXOR
   sta randomSeed
   rts

DetermineLevelNumber SUBROUTINE
   lda levelNumber                  ; get current level number
   ldx player1State                 ; check to see if player 1 is active
   bpl .maskLevelNumber             ; branch if not (i.e. player 2 active)
   lsr                              ; shift player 1 level number into lower
   lsr                              ; nybbles
   lsr
.maskLevelNumber
   and #$07
   rts

Overscan
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   lda gameTimer                    ; get the current game timer
   lsr                              ; shift D0 into carry
   bcc ReadConsoleSwitches          ; branch if on an even time value
   jmp CheckPlayerSmileyCollision
   
ReadConsoleSwitches
   lda SWCHB                        ; read console switch value
   tay                              ; save value in y for later use
   and #SELECT_MASK
   bne .checkForGameReset
   lda selectDebounce               ; get select debounce rate
   bpl .incrementGameSelection
   dec selectDebounce               ; reduce select debounc rate
   bne .incrementAttractModeTimer
.incrementGameSelection
   lda #INIT_SELECT_DEBOUNCE
   sta selectDebounce               ; re-initialize select debounce rate
   inc gameState
   lda gameState                    ; get game state for game selection
   and #MASK_GAME_SELECTION         ; mask the game selection
   cmp #MAX_GAME_SELECTION
   bcc .setGameSelection
   lda #0
.setGameSelection
   sta gameState
   jsr ResetPlayfieldState
   bne .incrementAttractModeTimer   ; unconditional branch
   
.checkForGameReset
   lda #0
   sta selectDebounce               ; reset select debounce rate
   tya                              ; move console switch value to accumulator
   and #RESET_MASK                  ; mask for GAME RESET
   beq StartNewGame                 ; start a new game of RESET pressed
   lda gameState                    ; get current game state
   bmi CheckForGameOver             ; branch if game in progress
.incrementAttractModeTimer
   inc vitaminActiveTimer           ; increment attract mode timer
   bpl .jmpToVerticalSync
   ldy vitaminActiveTimer           ; get attract mode timer
   iny
   bne .jmpToVerticalSync
   lda #$80
   sta vitaminActiveTimer           ; reset attract mode timer
   jsr NextRandom                   ; get new random number for color cycling
   lda #PURPLE + 6
   eor randomSeed
   and #COLOR_LIGHT_LUM
   sta COLUBK
   lda randomSeed
   and #COLOR_LIGHT_LUM
   sta COLUPF
   ldx #MAX_NUM_SMILIES - 1
.setSmileyAttractModeColors
   lda smileyColors,x
   eor randomSeed
   and #COLOR_LIGHT_LUM
   sta smileyColors,x
   dex
   bpl .setSmileyAttractModeColors
.jmpToVerticalSync
   jmp VerticalSync
   
StartNewGame
   lda gameState                    ; get current game state
   bmi .initializeGameVariables     ; branch if game in progress
   ora #MASK_GAME_RUNNING
   sta gameState                    ; set game state to GAME_RUNNING
   lda vitaminActiveTimer           ; get the attract mode timer
   sta randomSeed                   ; set it to the random seed
.initializeGameVariables
   ldx #0
   stx levelNumber
   stx player1ScoreLSB
   stx player2ScoreLSB
   stx player1ScoreMSB
   stx player2ScoreMSB
   stx player1State
   jsr ResetPlayfieldState
   stx player1NumCandyBarsEaten
   stx player2NumCandyBarsEaten
   ldx #STARTING_NUM_LIVES
   stx player1State                 ; set player1's initial number of lives
   lda gameState                    ; get current game state
   lsr                              ; move D0 to carry
   bcs .setPlayer2Lives             ; branch if a two player game
   ldx #0
.setPlayer2Lives
   stx player2State
   bpl .jmpToVerticalSync           ; unconditional branch
   
CheckForGameOver
   ldx #1
.checkNumberOfLives
   lda playerStates,x               ; get current player state
   and #MASK_LIVES                  ; mask to get number of remaining lives
   bne jmpToMoveSmiliesOrToothbrush ; branch if player has lives remaining
   dex                              ; check next player
   bpl .checkNumberOfLives
   lda gameState                    ; get current game state
   and #~MASK_GAME_RUNNING
   sta gameState                    ; set game state to GAME OVER
   jmp .incrementAttractModeTimer
   
CheckPlayerSmileyCollision
   bit gameBoardState               ; check game board state
   bvs DoPlayerDeathAnimation       ; branch if player caught by smiley
   bmi jmpToMoveSmiliesOrToothbrush
   lda CXPPMM                       ; check player to player collisions
   bpl jmpToMoveSmiliesOrToothbrush ; branch if no player collisions
   jsr DetermineRowOfPlayer
   bne jmpToMoveSmiliesOrToothbrush
   ldx #H_SMILEY - 1
   lda vitaminActiveTimer           ; determine if vitamin is active
   beq SmileyCaughtPlayer           ; if not active then smiley caught player   
   ldx #MAX_NUM_SMILIES
   tya                              ; move player row number to accumulator
.findSmileyLoop
   dex
   bmi jmpToMoveSmiliesOrToothbrush ; branch if no smiley found
   cmp smileyRowValues,x
   bne .findSmileyLoop
   lda #138
   sta soundIndex
   lda #$80
   sta smileyRowValues,x
   lda #MUNCHING_SMILEY_POINT_VALUE
   jsr IncrementScore
jmpToMoveSmiliesOrToothbrush
   jmp MoveSmiliesOrToothbrush
   
SmileyCaughtPlayer SUBROUTINE
.clearSmileyGraphics
   sta smileyGraphics,x             ; a = 0
   dex
   bpl .clearSmileyGraphics
   sta soundIndex
   sta playerDeathAnimationIndex    ; reset player death animtion index
   lda #%00111000
   sta playerGraphics
   lda #%01111100
   sta playerGraphics + 1
   lda #%10000000
   sta smileyRowValues
   lda #4
   sta smileyHorizValues            ; set death animation frame wait
   lda gameBoardState               ; get the current board state
   ora #%01000000
   sta gameBoardState               ; set to show player caught by smiley
   bne .setPlayerDeathAnimation     ; unconditional branch
   
DoPlayerDeathAnimation
   dec smileyHorizValues            ; reduce death animation frame wait
   bne .jmpToVerticalSync
   lda #4
   sta smileyHorizValues            ; reset death animation frame wait
.setPlayerDeathAnimation
   lda playerDeathAnimationIndex
   asl                              ; multiply by 8
   asl
   asl
   tay
   ldx #0
.setPlayerDeathGraphics
   lda InitJawGraphics + 2,y
   sta playerGraphics + 2,x
   iny                              ; increment graphics table index
   inx                              ; increment RAM location index
   cpx #H_PLAYER - 2
   bcc .setPlayerDeathGraphics
   lda #4
   sta AUDC1
   lda #6
   sta AUDV1
   inc playerDeathAnimationIndex    ; increment player death animation index
   lda playerDeathAnimationIndex    ; get death animtion index
   clc
   adc #3                           ; increase value by 3 for death frequency
   sta AUDF1
   cmp #10
   bne .jmpToVerticalSync
   lda #0
   sta AUDC1
   lda gameBoardState               ; get the current board state
   and #%10111111                   ; clear the player caught by smiley flag
   sta gameBoardState
   jsr SetXForActivePlayer          ; determine which player is active
   dec playerStates,x               ; reduce number of lives
   lda gameState                    ; get current game state
   lsr                              ; move D0 to carry
   bcc .jmpToResetPlayerPositions   ; branch if this is a one player game
   ldx #0                           ; assume player 1 is active
   lda player1State                 ; check to see if player 1 is active
   bmi .checkNumberOfRemainingLives
   ldx #1                           ; set index for player 2
.checkNumberOfRemainingLives
   lda playerStates,x               ; get current player state
   and #MASK_LIVES                  ; mask to get number of remaining lives
   beq .jmpToResetPlayerPositions   ; branch if no more lives remaining
   lda player1State                 ; check to see if player 1 is active
   bmi .setPlayer2Active            ; branch if player 1 is active
   ora #%10000000                   ; make player 1 active
   bmi .setPlayerActiveState        ; unconditional branch
   
.setPlayer2Active
   and #%01111111
.setPlayerActiveState
   sta player1State
.jmpToResetPlayerPositions
   jsr ResetPlayerPositions
.jmpToVerticalSync
   jmp VerticalSync
   
MoveSmiliesOrToothbrush
   lda gameBoardState               ; get the current board state
   bpl DetermineToMoveSmilies       ; move smilies if board not finished 
   ldx #0                           ; index for tooth brush horizontal value
   jmp MoveToothbrush
   
DetermineToMoveSmilies
   ldx #MAX_NUM_SMILIES - 1
MoveNextSmiley
   lda gameState                    ; get the current game state
   and #MASK_GAME_SELECTION         ; mask to get game selection
   lsr                              ; divide value by 2 (0 <= a <= 3)
   tay
   lda SmileyFrameDelayValues,y
   sta frameDelay                   ; set frame delay for smilies
   lda smileyDelayMotion,x
   jsr DetermineIfTimeToMoveObject
   sta smileyDelayMotion,x
   bcc MoveSmileySprite
   jmp DoNextSmiley
   
MoveSmileySprite
   lda smileyDirections             ; get the smiley direction values
   sta tmpSmileyDirections          ; save to manipulate the values
   txa                              ; move smiley number to accumulator
   tay                              ; move smiley number to y
.shiftSmileyDirectionToCarry
   asl tmpSmileyDirections          ; shift current smiley direction to carry
   dey                              ; reduce smiley number
   bpl .shiftSmileyDirectionToCarry
   lda smileyRowValues,x            ; get smiley's row value
   bpl .moveSmiley
   inc smileyRowValues,x
   beq .setSmileyToRow10
   jmp DoNextSmiley
   
.moveSmiley
   bcs .smileyTravelingLeft
   jsr MoveSmileyRight              ; increment the smiley horizontal position
   cmp #XMIN                        ; compare with XMIN to see if off screen
.checkIfSmileyOffScreen
   beq DetermineNewRowOfSmiley
   cmp #HMOVE_L6 | 3
   beq DetermineSmileyChangeDirection
   cmp #HMOVE_R4 | 6
   beq DetermineSmileyChangeDirection
   bne .doneMoveSmileySprite        ; unconditional branch
   
.smileyTravelingLeft
   jsr MoveSmileyLeft               ; decrement the smiley horizontal position
   cmp #XMAX                        ; compare with XMAX to see if off screen
   jmp .checkIfSmileyOffScreen
   
.setSmileyToRow10
   lda #10
   sta smileyRowValues,x
   jmp DetermineNewRowOfSmiley
   
DetermineSmileyChangeDirection
   jsr DetermineRowOfPlayer
   tya                              ; move row number to accumulator
   cmp smileyRowValues,x            ; compare with row value of smiley
   bne .randomlyChangeDirection
   jsr NextRandom                   ; re-seed random number
   cmp #48
   bcc .checkToChangeSmileyDirection
   lda smileyHorizValues,x          ; get smiley's horizontal position
   and #$0F                         ; mask fine motion position
   clc
   adc #4
   sta tmpSmileyXPos                ; save for later
   lda playerHorizPos               ; get the player's horizontal position
   and #$0F                         ; mask fine motion position
   cmp tmpSmileyXPos                ; compare with smiley's coarse position
   bcc .playerToTheLeftOfSmiley
   lda smileyDirections             ; get the smiley direction values
   and SmileyLeftTravelValues,x
   beq .changeSmileyDirection
   bne .doneMoveSmileySprite        ; unconditional branch
   
.playerToTheLeftOfSmiley
   lda smileyDirections             ; get the smiley direction values
   and SmileyLeftTravelValues,x
   bne .changeSmileyDirection
   beq .doneMoveSmileySprite        ; unconditional branch
   
.randomlyChangeDirection
   jsr NextRandom                   ; re-seed random number
   cmp #192                         ; if value greater than 192 then don't
   bcc .checkToChangeSmileyDirection; change smiley direction
   bcs .doneMoveSmileySprite        ; unconditional branch
   
.checkToChangeSmileyDirection
   jsr NextRandom                   ; re-seed random number
   bmi .changeSmileyDirection       ; change smiley direction if random >= 128
   bpl .doneMoveSmileySprite        ; unconditional branch
   
.changeSmileyDirection
   lda smileyDirections             ; get the smiley direction values
   and SmileyLeftTravelValues,x
   bne .setSmileyDirectionToRight
   lda smileyDirections             ; get the smiley direction values
   ora SmileyLeftTravelValues,x     ; or in the left travel value for smiley
   jmp .setSmileyDirection          ; could use unconditionl branch -- bne
   
.setSmileyDirectionToRight
   lda smileyDirections             ; get the smiley direction values
   and SmileyRightTravelValues,x    ; and in the right travel value for smiley
.setSmileyDirection
   sta smileyDirections
.doneMoveSmileySprite
   jmp DetermineToMoveSmiley
   
DetermineNewRowOfSmiley SUBROUTINE
   lda vitaminActiveTimer           ; determine if the vitamin is active
   bne CalculateRandomSmileyRow     ; branch if vitamin active
   jsr NextRandom                   ; get a new random number
   cmp #32
   bcc CalculateRandomSmileyRow
   jsr DetermineRowOfPlayer         ; get the row the player is in
   tya                              ; move player row to accumulator
   jmp NewSmileyRowFound
   
CalculateRandomSmileyRow
   jsr NextRandom                   ; get a new random number
   ldy #<-1
.nextRow
   iny                              ; increment row count
   sec
   sbc #(H_SMILEY * 2) + 4
   beq NewSmileyRowFound
   cmp #228
   bcc .nextRow
NewSmileyRowFound
   tya                              ; move computed row to accumulator
   cmp smileyRowValues,x            ; compare with the row of smiley
   beq .setNewSmileyRowValue
   ldy #MAX_NUM_SMILIES - 1
.findFreeSmileyRow
   cmp smileyRowValues,y            ; compare with row of another smiley
   beq CalculateRandomSmileyRow     ; re-compute row if in same row as another
   dey
   bpl .findFreeSmileyRow
.setNewSmileyRowValue
   sta smileyRowValues,x
   jsr DetermineRowOfPlayer         ; get the row the player is in
   tya                              ; move player row to accumulator
   cmp smileyRowValues,x            ; see if player and smiley in same row
   bne SetSmileyNewDirection
   lda playerHorizPos               ; get the player's horizontal position
   and #$0F                         ; mask fine motion position
   cmp #8                           ; compare player's coarse value with 8
   bcc .setSmileyDirectionToRight
   bcs .setSmileyDirectionToLeft    ; unconditional branch
   
SetSmileyNewDirection
   jsr NextRandom
   bmi .setSmileyDirectionToRight
.setSmileyDirectionToLeft
   lda smileyDirections             ; get the smiley direction values
   ora SmileyLeftTravelValues,x     ; or in the left travel value for smiley
   sta smileyDirections             ; set to make smiley move left next frame
   lda #XMIN
   bne .setSmileyNewHorizontalValue ; unconditional branch
   
.setSmileyDirectionToRight
   lda smileyDirections             ; get the smiley direction values
   and SmileyRightTravelValues,x    ; and in the right travel value for smiley
   sta smileyDirections             ; set to make smiley move right next frame
   lda #XMAX
.setSmileyNewHorizontalValue
   sta smileyHorizValues,x
DetermineToMoveSmiley
   dec skipAllowMotionState         ; reduce skipAllowMotionState value
   bmi DoNextSmiley                 ; branch if not moving this frame
   jmp MoveSmileySprite
   
DoNextSmiley
   dex
   bmi .doneMovingSmilies
   jmp MoveNextSmiley
   
.doneMovingSmilies
   jmp VerticalSync
   
MoveToothbrush
   lda toothbrushSoundIndex1
   beq CheckToMoveToothbrushRight
   bpl ChangeToothbrushToLeft
   jsr MoveSmileyRight              ; move toothbrush to the right
   cmp #TOOTHBRUSH_XMIN
   bne .doneMovingSmilies
   lda #0
   sta toothbrushSoundIndex1
   lda #7
   sta toothbrushSoundIndex3
   lda #12
   sta toothbrushSoundIndex2
   bne .doneMovingSmilies           ; unconditional branch
   
ChangeToothbrushToLeft
   dec toothbrushSoundIndex2
   lda toothbrushSoundIndex2
   bmi .moveToothbrushLeft_a
   lsr                              ; divide value by 2
   sta AUDV1                        ; for sound volume
.moveToothbrushLeft_a
   jsr MoveSmileyLeft
   cmp #TOOTHBRUSH_XMAX
   bne .setChannelAndFreqForToothbrush
   jsr ResetPlayfieldState
   bne .doneToothbrushMovement      ; unconditional branch
   
CheckToMoveToothbrushRight
   lda toothbrushSoundIndex3
   lsr                              ; shift D0 to carry
   bcc ChangeToothbrushToRight      ; if even then change Toothbrush direction
   dec toothbrushSoundIndex2
   lda toothbrushSoundIndex2
   bmi .moveToothbrushLeft_b
   lsr                              ; divide value by 2
   sta AUDV1                        ; for sound volume
.moveToothbrushLeft_b
   jsr MoveSmileyLeft
   cmp #HMOVE_L6 | 5
   bne .setChannelAndFreqForToothbrush
   dec toothbrushSoundIndex3
   lda #12
   sta toothbrushSoundIndex2
.setChannelAndFreqForToothbrush
   lda #$08
   sta AUDC1
   lda #$05
   sta AUDF1
.doneToothbrushMovement
   jmp VerticalSync
   
ChangeToothbrushToRight
   dec toothbrushSoundIndex2
   lda toothbrushSoundIndex2
   bmi .moveToothbrushRight
   lsr                              ; divide value by 2
   sta AUDV1                        ; for sound volume
.moveToothbrushRight
   jsr MoveSmileyRight
   cmp #TOOTHBRUSH_XMIN
   bne .setChannelAndFreqForToothbrush
   lda #12
   sta toothbrushSoundIndex2
   dec toothbrushSoundIndex3
   bpl .setChannelAndFreqForToothbrush
   lda #1
   sta toothbrushSoundIndex1
   bne .doneToothbrushMovement      ; unconditional branch
   
MoveSmileyRight
   lda smileyHorizValues,x          ; get the smiley's horizontal value
   clc
   adc #16                          ; increment value by 16
   bvc .setSmileyHorizPosition      ; check to see if overflow happened
   adc #15                          ; if so then add 15 for the new position
.setSmileyHorizPosition
   sta smileyHorizValues,x
   rts

MoveSmileyLeft
   lda smileyHorizValues,x          ; get the smiley's horizontal value
   sec
   sbc #16                          ; subtract value by 16
   bvc .setSmileyHorizPosition      ; check to see if overflow happened
   sbc #15                          ; if so the subtract 15 for new position
   jmp .setSmileyHorizPosition
   
VerticalSync SUBROUTINE
.waitTime
   lda TIMINT
   bpl .waitTime
   sta WSYNC                        ; end last scan line
   lda #DISABLE_TIA | START_VERT_SYNC
   sta VBLANK                       ; disable TIA (D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   ldx #VSYNC_TIME
   stx TIM8T                        ; set timer for vertical sync time
   bit gameState                    ; check if game in progress
   bmi CheckForActiveVitamin        ; branch if game in progress
   sta gameTimer                    ; set game timer to 2
   jmp CheckPlayerVitaminCollision
   
CheckForActiveVitamin
   dec gameTimer                    ; reduce game timer
   bne CheckPlayerVitaminCollision
   lda #30
   sta gameTimer                    ; reset game timer
   bit gameBoardState               ; check game board state
   bmi CheckPlayerVitaminCollision  ; branch if game board done
   bvs CheckPlayerVitaminCollision  ; branch if player caught by smiley
   lda vitaminActiveTimer           ; get the vitamin timer
   beq DetermineToActivateVitamin   ; branch if vitamin not active
   dec vitaminActiveTimer           ; reduce vitamin timer
   beq .vitaminNotActive
   ldy #RED                         ; Smilies to be RED (vitamin active)
   ldx #MAX_NUM_SMILIES - 1
   lda vitaminActiveTimer           ; get the vitamin timer
   cmp #5                           ; see if it's time to flash smiley colors
   bcs .colorSmilies                ; color smiley RED if greater than 4             
   lsr                              ; move D0 to carry
   bcs .colorSmilies                ; color RED on odd frames
   ldy #WHITE                       ; Smilies to be WHITE
.colorSmilies
   sty smileyColors,x               ; set Smiley colors
   lda #$C7
   sta smileyDelayMotion,x
   dex
   bpl .colorSmilies
   bmi DoGameSounds                 ; unconditional branch
   
.vitaminNotActive
   jsr SetSmileyAttributes
   jmp .vsyncWaitTime
   
DetermineToActivateVitamin
   lda gameBoardState               ; get the current board state
   and #$0F                         ; mask to get the vitamin timer
   beq CheckPlayerVitaminCollision  ; branch if vitamin active
   dec gameBoardState               ; reduce the vitamin timer
   ldy gameBoardState               ; load y with the current game board state
   tya                              ; move gameBoardState to accumulator
   and #$0F                         ; mask to get current vitamin timer
   bne CheckPlayerVitaminCollision
   tya                              ; move gameBoardState to accumulator
   and #%00110000
   bne CheckPlayerVitaminCollision
   inc gameBoardState
CheckPlayerVitaminCollision
   bit CXM0P                        ; check missile 0 collisions
   bvc DoGameSounds                 ; branch if player not eaten vitamin
   lda gameBoardState               ; get the current board state
   ora #$0F                         ; set the init vitamin timer
   sta gameBoardState
   jsr DetermineLevelNumber
   sta vitaminActiveTimer           ; set the init vitamin active timer
   lda #13
   sta soundIndex
   sec
   sbc vitaminActiveTimer
   sta vitaminActiveTimer
   lda gameBoardState               ; get the current board state
   sec
   sbc #$10
   sta gameBoardState
   lda #1
   sta gameTimer                    ; set game timer to 1
DoGameSounds
   lda soundIndex                   ; get the sound index value
   beq .vsyncWaitTime               ; skip sound if set to 0
   bmi .playExtraLifeOrEatingSmiley ; extra life or points for smiley sound
   lda #8
   sta AUDC1
   lda #24
   sta AUDF1
   lda soundIndex
   sta AUDV1
   dec soundIndex
   dec soundIndex
   lda soundIndex
   cmp #2
   bcs .vsyncWaitTime
   lda #0
   sta AUDC1
   sta soundIndex
   beq .vsyncWaitTime               ; unconditional branch
   
.playExtraLifeOrEatingSmiley
   cmp #144
   bcs .playExtraLifeSound
   and #$7F                         ; mask D7 of sound index
   tax                              ; move to x for table index
   dec soundIndex
   lda #12
   sta AUDC1
   sta AUDV1
   lda MoveToothbrush + 14,x        ; use code for freq and channel values
   sta AUDF1
   bne .vsyncWaitTime
   sta AUDC1
   sta soundIndex
   beq .vsyncWaitTime               ; unconditional branch
   
.playExtraLifeSound
   sta AUDV1
   lda #12
   sta AUDC1
   lda #1
   sta AUDF1
   dec soundIndex
   dec soundIndex
   lda soundIndex
   cmp #192
   bcs .vsyncWaitTime
   lda #0
   sta soundIndex                   ; reset sound index
   sta AUDC1
.vsyncWaitTime
   lda TIMINT
   bpl .vsyncWaitTime
   lda #0
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   sta VBLANK                       ; enable TIA (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
   sta CXCLR                        ; clear all collision registers
   jmp StartGameCalculations
   
SmileyRightTravelValues
   .byte ~FOURTH_SMILEY_TRAVEL_LEFT, ~THIRD_SMILEY_TRAVEL_LEFT
   .byte ~SECOND_SMILEY_TRAVEL_LEFT, ~FIRST_SMILEY_TRAVEL_LEFT
   
SmileyLeftTravelValues
   .byte FOURTH_SMILEY_TRAVEL_LEFT, THIRD_SMILEY_TRAVEL_LEFT
   .byte SECOND_SMILEY_TRAVEL_LEFT, FIRST_SMILEY_TRAVEL_LEFT
   
SmileyColorTable
   .byte FIRST_SMILEY_COLOR, SECOND_SMILEY_COLOR
   .byte THIRD_SMILEY_COLOR, FOURTH_SMILEY_COLOR
   
SmileyDelayMotionValues
   .byte MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_10
   .byte MOVE_FRAME_RATE_11, MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_8
   .byte MOVE_FRAME_RATE_10, MOVE_FRAME_RATE_10, MOVE_FRAME_RATE_7
   .byte MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_10, MOVE_FRAME_RATE_9
   .byte MOVE_FRAME_RATE_7, MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_9
   .byte MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_6, MOVE_FRAME_RATE_8
   .byte MOVE_FRAME_RATE_9, MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_6
   .byte MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_9, MOVE_FRAME_RATE_7
   .byte MOVE_FRAME_RATE_6, MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_9
   .byte MOVE_FRAME_RATE_6, MOVE_FRAME_RATE_6, MOVE_FRAME_RATE_8
   .byte MOVE_FRAME_RATE_8, MOVE_FRAME_RATE_6
   
SmileyFrameDelayValues
   .byte FAST_MOVING_SMILEY, MEDIUM_MOVING_SMILEY, SLOW_MOVING_SMILEY
   
InitJawGraphics
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   
   .byte $00 ; |........|
   .byte $00 ; |........|

StartGameCalculations
   bit gameBoardState               ; check the game board state
   bvc CheckForEatingCandy          ; branch if player not caught by smiley
   jmp SetSmileySpriteAnimation
   
; Understanding how the pointers are calculated for eating dots algorithm
; ---------------------------------------------------------------------------
;
; The player has a horizontal range in pixels of 75 - 204. To determine these
; values we use the formula (((C * 5) + 4) * 3) + HMOVE.
;
; The PF pixels are set up in the following manner (the PF is reflected)
;
; ----------------------- PF Pixels -----------------------
; |  PF0  |   PF1   |   PF2   |   PF2   |   PF1   |  PF0  |
; |68 . 83|84 .. 115|116.. 147|148.. 179|180.. 211|212.227|
;
; Only PF1 and PF2 are used for the dots. Also remember the display is
; inverted...meaning the purple items are the background colors and the black
; items are the PF values.
;
; PF1 starts are cycle 84. Using the formula above the least coarse value to
; get in this area is 5.
;
; So to compute the coarse value pixel associated to the dots John first
; reduces the value by 5 (the least coarse value for the dot patterns). Then
; he takes this value and multiplies it by 15 which would be
; [((C * 5) + 4) * 3] - 87 which is...
; the computed coarse pixel position minus the least coarse pixel position for
; the dots.
;
; Next John adds in the fine motion value to get the player's horizontal
; pixel. If the player is moving right then the value is made negative so the
; fine motion is *added* to 7 (the fine motion offset). Once the fine motion
; has been added the value is increased by 2 and the following table is used
; for the PF pixels.
;
; ----------------------- PF Pixels -----------------------
; |  PF0  |   PF1   |   PF2   |   PF2   |   PF1   |  PF0  |
; |0  . 15|16 ..  47|48 ..  79|80 .. 111|112.. 143|144.159|

CheckForEatingCandy
   jsr DetermineRowOfPlayer         ; y holds the row the player is in
   bne CheckForGameBoardDone
   lda playerHorizPos               ; get the player's horizontal position
   and #$0F                         ; mask fine motion position
   sec
   sbc #5                           ; subtract 5 from coarse value
   sta playerCoarseXPos             ; save value for later
   beq .computeFineMotionPosition   ; this could be removed to save 2 bytes
   asl                              ; multiply the value by 16
   asl
   asl
   asl
   sec
   sbc playerCoarseXPos             ; subtract original value so the value
   sta playerCoarseXPos             ; becomes (x * 15)
.computeFineMotionPosition
   lda playerHorizPos               ; get the player's horizontal position
   lsr                              ; shift the fine motion value down to
   lsr                              ; the lower nybbles
   lsr
   lsr
   ldx playerHorizPos               ; get the player's horizontal position
   bpl .computePointerForCandyRAM   ; branch if fine motion is moving left
   ora #$F0                         ; make negative so it's added to coarse
                                    ; value
.computePointerForCandyRAM
   sta playerFineXPos
   lda #HMOVE_L7 >> 4
   sec
   sbc playerFineXPos               ; subtract fine motion value
   clc
   adc playerCoarseXPos             ; add in coarse value to get position
   clc
   adc #2
   bmi CheckForGameBoardDone        ; branch if value out of range
   sta playerPFPixelValue
   and #7
   bne CheckForGameBoardDone        ; branch if value not divisible by 8
   lda playerPFPixelValue           ; get the PF pixel value
   lsr                              ; divide the value by 8 (represents the
   lsr                              ; bit values of the candy RAM values)
   lsr
   sta bitPointerCandyRAM
   lsr                              ; divide the value by 32 to get the index
   lsr                              ; to read the pointers to RAM
   tax
   lda PlayfieldCandyPointers,x
   sta candyRAMPointer
   lda #0                           ; set MSB to 0 because we are reading/
   sta candyRAMPointer + 1          ; writing to ZP
   lda bitPointerCandyRAM
   ldx player1State                 ; check to see if player 1 is active
   bpl .removeEatenCandyBar         ; branch if player 2 is active
   clc
   adc #16                          ; add 16 to get player 1 masking offset
.removeEatenCandyBar
   tax
   lda (candyRAMPointer),y          ; read the candy bar pattern for the row
   and CandyBarMaskingValues,x
   bne .determineToMovePlayer
   lda (candyRAMPointer),y          ; read the candy bar pattern for the row
   ora CandyBarMaskingValues,x      ; or in the masking value
   sta (candyRAMPointer),y          ; and set the pattern for the candy bars
   lda #MUNCHING_CANDY_POINT_VALUE
   jsr IncrementScore               ; increment score for eating candy bar
   lda soundIndex
   bne .incrementCandyBarsEaten
   lda #10
   sta soundIndex
.incrementCandyBarsEaten
   jsr SetXForActivePlayer          ; determine which player is active
   inc numCandyBarsEaten,x          ; increment player's number of candy eaten
   bne .determineToMovePlayer       ; unconditional branch
   
CheckForGameBoardDone
   lda gameBoardState               ; get the current game board state
   bmi SetToothbrushGraphics        ; branch if board done
   jsr SetXForActivePlayer          ; determine which player is active
   lda numCandyBarsEaten,x          ; get number of candy eaten by player
   cmp #NUM_CANDY_BARS              ; compare with max number of candy
.determineToMovePlayer
   bne DetermineToMovePlayer
   lda #LEVEL_DONE_POINT_VALUE
   jsr IncrementScore               ; increment score with bonus points
   lda gameBoardState               ; get the current game board state
   ora #%10001111
   sta gameBoardState               ; set to show board finished
   ldx #MAX_NUM_SMILIES - 1
.loop
   lda #$FF
   sta smileyRowValues,x
   sta toothbrushSoundIndex1
   txa
   sta smileyIndexes,x
   dex
   bpl .loop
   lda #0
   sta smileyDirections
   lda #HMOVE_L4 | 8
   sta toothbrushHorizValue
   lda #4
   sta toothbrushRow                ; set the toothbrush in row 4
   lda #YMID
   sta playerVertPos                ; center player vertically
   lda #PLAYER_XMID
   sta playerHorizPos               ; center player horizontally
   lda #WHITE
   sta smileyColors
   jsr DetermineLevelNumber         ; get the current level number
   cmp #MAX_GAME_BOARD - 1          ; see if the player has reached the max
   beq SetToothbrushGraphics        ; if so then skip the extra life logic
   and #1                           ; only increment the number of lives if
   beq IncrementGameLevel           ; this is an odd level number
   jsr SetXForActivePlayer          ; determine which player is active
   lda playerStates,x               ; get current player state
   and #MASK_LIVES                  ; mask to get number of remaining lives
   cmp #MAX_NUM_LIVES               ; see if reached max number of lives
   beq IncrementGameLevel
   inc playerStates,x               ; increment number of lives
   lda #255
   sta soundIndex
IncrementGameLevel
   ldx player1State                 ; check to see if player 1 is active
   bpl .incrementPlayer2LevelNumber
   lda levelNumber                  ; get current level number
   clc
   adc #8                           ; increment by 8 to increase player 1's
   sta levelNumber                  ; level number
   bne SetToothbrushGraphics        ; unconditional branch
   
.incrementPlayer2LevelNumber
   inc levelNumber
SetToothbrushGraphics
   ldx #H_SMILEY - 1
.toothbrushGraphicsLoop
   lda Toothbrush,x
   sta smileyGraphics,x
   dex
   bpl .toothbrushGraphicsLoop
   ldx #H_PLAYER - 1
.setJawSpriteGraphics
   lda JawSprites,x
   sta playerGraphics,x
   dex
   bpl .setJawSpriteGraphics
DetermineToMovePlayer
   lda gameState                    ; get current game state
   bpl .skipJoystickRead            ; branch if game not in progress
   bit gameBoardState               ; check game board state
   bmi .skipJoystickRead            ; branch if board done
   jsr SetXForActivePlayer          ; determine which player is active
   jsr DetermineRowOfPlayer
   bne DeterminePlayerDifficulty
   lda INPT4,x                      ; read the player's fire button value
   bpl .skipJoystickRead            ; skip joystick read if pressing button
DeterminePlayerDifficulty
   ldy #SLOW_MOVING_PLAYER          ; assume EXPERT (delay 1 out 8 frames)
   lda SWCHB                        ; read the console switches
   and DifficultySwitchMask,x       ; and the difficulty mask for the player
   bne .setJawsFrameDelay           ; set frame delay if EXPERT setting
   ldy #FAST_MOVING_PLAYER          ; use AMATEUR setting (no frame delay)
.setJawsFrameDelay
   sty frameDelay                   ; set frame delay for player motion
   lda playerDelayMotion
   jsr DetermineIfTimeToMoveObject
   sta playerDelayMotion
   bcc DeterminePlayerDirection
.skipJoystickRead
   jmp SetSmileySpriteAnimation
   
DeterminePlayerDirection
   lda $0288                        ; read joystick values
   ldx player1State                 ; check to see if player 1 is active
   bpl .shiftPlayer1JoystickValues  ; shift joystick values if active
   and #$0F                         ; mask player 1's joystick values
   bne .determineMovementDelta      ; unconditional branch
   
.shiftPlayer1JoystickValues
   lsr                              ; shift player 1's joystick values
   lsr                              ; to the lower nybbles
   lsr
   lsr
.determineMovementDelta
   tax                              ; move joystick values to x
   lda HorizontalDirectionTable,x   ; read horizontal delta values
   sta horizMovementDelta
   lda VerticalDirectionTable,x     ; read vertical delta values
   sta vertMovementDelta
   beq DeterminePlayerHorizMovement ; branch if invalid vertical value
   jsr DetermineVertAllowedMotion
   bcs DeterminePlayerHorizMovement
   lda horizMovementDelta           ; get the horizontal movement direction
   bne DeterminePlayerVertMovement  ; branch if valid horizontal value
   lda vertMovementDelta            ; get the vertical movement direction
   bmi .movePlayerUp                ; if negative then player moving up
   bpl .movePlayerDown              ; if positive then player moving down
                                    ; unconditional branch
DeterminePlayerVertMovement
   lda vertMovementDelta            ; get the vertical movement direction
   bmi .determineMovePlayerUp       ; branch if moving up
   lda playerFrameState             ; get the current player frame state
   and #MASK_DIRECTION_VERT
   beq .movePlayerDown
   cmp #DIRECTION_DOWN              ; check if the player is moving down
   beq DeterminePlayerHorizMovement ; branch if player moving down
.movePlayerDown
   lda playerFrameState             ; get the current player frame state
   and #$0F                         ; mask the direction bits
   ora #DIRECTION_DOWN              ; or in the downward direction
   sta playerFrameState             ; set the direction and branch
   bne MovePlayerVertically         ; unconditional branch
   
.determineMovePlayerUp
   lda playerFrameState             ; get the current player frame state
   and #MASK_DIRECTION_VERT
   beq .movePlayerUp
   cmp #DIRECTION_UP                ; check to see if the player is moving up
   beq DeterminePlayerHorizMovement ; branch if player moving up
.movePlayerUp
   lda playerFrameState             ; get the current player frame state
   and #$0F                         ; mask the direction bits
   ora #DIRECTION_UP                ; or in the upward direction
   sta playerFrameState             ; set the direction and branch
   bne MovePlayerVertically         ; unconditional branch
   
DeterminePlayerHorizMovement
   lda horizMovementDelta           ; get the horizontal movement direction
   beq DetermineMovementByDirection ; branch if invalid horizontal value
   jsr DetermineRowOfPlayer
   bne DetermineMovementByDirection
   lda horizMovementDelta           ; get the horizontal movement direction
   jsr DetermineHorizAllowedMotion
   bcs DetermineMovementByDirection
   lda horizMovementDelta           ; get the horizontal movement direction
   bmi .movePlayerLeft              ; branch if moving left (negative)
   lda playerFrameState             ; get the current player frame state
   and #$0F                         ; mask the direction bits
   ora #DIRECTION_RIGHT             ; or in right direction
   sta playerFrameState             ; set the direction and branch
   bne MovePlayerHorizontally       ; unconditional branch
   
.movePlayerLeft
   lda playerFrameState             ; get the current player frame state
   and #$0F                         ; mask the direction bits
   ora #DIRECTION_LEFT              ; or in left direction
   sta playerFrameState             ; set the direction and branch
   bne MovePlayerHorizontally       ; unconditional branch
   
DetermineMovementByDirection
   lda playerFrameState             ; get current player frame state
   and #DIRECTION_DOWN
   beq .checkPlayerMovingDown
   lda #1
.determineVertAllowedMotion
   jsr DetermineVertAllowedMotion
   bcc MovePlayerVertically
   bcs .setPlayerMotionToNotMoving  ; unconditional branch
   
.checkPlayerMovingDown
   lda playerFrameState             ; get current player frame state
   and #DIRECTION_UP
   beq .checkHorizMovementByDirection
   lda #<-1
   bne .determineVertAllowedMotion  ; unconditional branch
   
.checkHorizMovementByDirection
   lda playerFrameState             ; get current player frame state
   and #DIRECTION_RIGHT
   beq .checkPlayerMovingLeft
   lda #1
.determineHorizAllowedMotion
   jsr DetermineHorizAllowedMotion
   bcc MovePlayerHorizontally
.setPlayerMotionToNotMoving
   lda playerFrameState             ; get current player frame state
   and #$0F                         ; mask the direction bits
   sta playerFrameState             ; set player direction to not moving
   jmp SetSmileySpriteAnimation
   
.checkPlayerMovingLeft
   lda playerFrameState             ; get current player frame state
   and #DIRECTION_LEFT
   beq .setPlayerMotionToNotMoving
   lda #<-1
   bne .determineHorizAllowedMotion ; unconditional branch
   
MovePlayerVertically SUBROUTINE
   lda playerFrameState             ; get current player frame state
   bmi .movePlayerUp
   dec playerVertPos
   dec playerVertPos
   bne .determineJawsSpriteAnimation; unconditional branch
   
.movePlayerUp
   inc playerVertPos
   inc playerVertPos
   bne .determineJawsSpriteAnimation; unconditional branch
   
MovePlayerHorizontally
   lda playerFrameState             ; get current player frame state
   and #DIRECTION_RIGHT
   beq .movePlayerRight
   lda playerHorizPos               ; get the player's horizontal position
   sec
   sbc #16                          ; subtract value by 16
   bvc .setPlayerHorizontalPosition ; check to see if overflow happened
   sbc #15                          ; if so then subtract 15 for new position
.setPlayerHorizontalPosition
   sta playerHorizPos
.determineJawsSpriteAnimation
   dec skipAllowMotionState         ; reduce skipAllowMotionState value
   bmi SetPlayerSpriteAnimation     ; branch if not moving this frame
   jmp DeterminePlayerDirection
   
.movePlayerRight
   lda playerHorizPos               ; get the player's horizontal position
   clc
   adc #16                          ; increment value by 16
   bvc .setPlayerHorizontalPosition ; check to see if overflow happened
   adc #15                          ; if so then add in 15 for new position
   bne .setPlayerHorizontalPosition ; unconditional branch
   
SetPlayerSpriteAnimation
   lda gameTimer                    ; get the current game timer
   lsr                              ; shift D0 to carry
   bcc .doSmileySpriteAnimation     ; branch if on an even time value
   lda playerFrameState             ; get current player frame state
   and #MASK_DIRECTION              ; get the player's direction
   beq SetSmileySpriteAnimation
   and #MASK_DIRECTION_VERT
   beq .setForHorizontalAnimation
   lda #<JawSpritesVertical         ; set the player graphics LSB
   sta playerGraphicsPointer
   lda #>JawSpritesVertical         ; set the player graphics MSB
   sta playerGraphicsPointer + 1
   bne .incrementPlayerFrameState   ; unconditional branch
   
.setForHorizontalAnimation
   lda #<JawSpritesHorizontal
   sta playerGraphicsPointer
   lda #>JawSpritesHorizontal
   sta playerGraphicsPointer + 1
.incrementPlayerFrameState
   inc playerFrameState
   lda playerFrameState             ; get current player frame state
   and #$07
   bne .setPlayerSpriteIndex
   lda playerFrameState             ; get current player frame state
   and #MASK_DIRECTION              ; reset animation frame to 0
   sta playerFrameState
.setPlayerSpriteIndex
   and #$06
   asl                              ; multiply value by 8 (H_PLAYER)
   asl
   asl
   tay
   ldx #0
.setPlayerGraphics
   lda (playerGraphicsPointer),y    ; read player sprite table
   sta playerGraphics,x             ; set player graphics
   iny
   inx
   cpx #H_PLAYER
   bcc .setPlayerGraphics
   bcs MovePassThroughGaps          ; unconditional branch
   
SetSmileySpriteAnimation
   lda gameTimer                    ; get the current game timer
   lsr                              ; shift D0 into carry
   bcs MovePassThroughGaps          ; branch if on an odd timer value
.doSmileySpriteAnimation
   bit gameBoardState               ; check game board state
   bmi MovePassThroughGaps          ; branch if game board done
   bvs MovePassThroughGaps          ; branch if player caught by smiley
   lda smileyAnimationIndex         ; get smiley animation index
   clc
   adc #1                           ; increment value by 1
   cmp #MAX_SMILEY_ANIMATIONS * 2
   bcc .setSmileyAnimationIndex
   lda #0                           ; reset smiley animation index to 0
.setSmileyAnimationIndex
   sta smileyAnimationIndex
   and #$7E
   tay
   lda SmileyAnimationTable,y
   sta smileyGraphicsPointer
   lda SmileyAnimationTable + 1,y
   sta smileyGraphicsPointer + 1
   ldy #H_SMILEY - 1
.setSmileyGraphics
   lda (smileyGraphicsPointer),y
   sta smileyGraphics,y
   dey
   bpl .setSmileyGraphics
MovePassThroughGaps
   lda passThroughDirections        ; get the pass through direction values
   sta tmpPassThroughDirections     ; save in temp variable to be manipulated
   ldx #NUM_PASS_THROUGH_GAPS - 1
.movePassThroughGapLoop
   lda passThroughGapDelayMotion    ; get the pass through delay values
   and PassThroughDelayMask,x       ; get delay for current pass through
   beq .setPassThroughGapDelay      ; move pass through if 0
   lda passThroughGapDelayMotion    ; get the pass through delay values
   and PassThroughMask,x            ; isolate value for current pass through
   sta passThroughGapDelayMotion    ; set pass through delay value
   asl tmpPassThroughDirections     ; shift directions left so next direction
   jmp .nextPassThroughGap          ; is in D7
   
.setPassThroughGapDelay
   lda #%11001101
   and PassThroughDelayMask,x       ; get delay for current pass through
   ora passThroughGapDelayMotion    ; or with current delay values
   sta passThroughGapDelayMotion
   asl tmpPassThroughDirections     ; shift current directions to carry
   bcs .movePassThroughLeft
.movePassThroughRight
   lda ballHorizPos,x               ; get horizontal position of "gap"
   clc
   adc #16                          ; increment value by 16
   bvc .checkXMAXRange              ; check to see if overflow happened
   adc #15                          ; if so then add in 15 for new position
.checkXMAXRange
   cmp #PASS_THROUGH_XMIN
   bne .doneCurrentGapMovement
   lda passThroughDirections        ; get the pass through direction values
   ora PassThroughDelayMask,x       ; or the mask value in to make the gap
   sta passThroughDirections        ; move left next frame
.movePassThroughLeft
   lda ballHorizPos,x               ; get horizontal position of "gap"
   sec
   sbc #16                          ; subtract value by 16
   bvc .checkXMINRange              ; check to see if overflow happened
   sbc #15                          ; if so the subtract 15 for new position
.checkXMINRange
   cmp #PASS_THROUGH_XMAX
   bne .doneCurrentGapMovement
   lda passThroughDirections        ; get the pass through direction values
   and PassThroughMask,x            ; and the mask value to make the gap move
   sta passThroughDirections        ; right next frame
   bne .movePassThroughRight
.doneCurrentGapMovement
   sta ballHorizPos,x
.nextPassThroughGap
   dex
   bpl .movePassThroughGapLoop
   ldx #MAX_NUM_SMILIES - 1
SortSmilies
.tempStoreSmileyLoop
   lda smileyRowValues,x            ; get the row value of the smiley
   sta tmpSmileyRowValues,x         ; save it in temporary variable
   dex
   bpl .tempStoreSmileyLoop
   sta lowestSmileyRowValue         ; save last value in floor value
   ldy #0
   sty smileyIndexes
.sortSmiliesLoop
   ldx #MAX_NUM_SMILIES - 1
.lowestRowValueLoop
   lda lowestSmileyRowValue         ; get the current lowest smiley row
   cmp tmpSmileyRowValues,x         ; compare it with the row value
   bcc .lookForNextLowestRowValue   ; branch if less than row value
   lda tmpSmileyRowValues,x         ; get smiley row value
   sta lowestSmileyRowValue         ; save it as the new floor value
   stx smileyIndexes,y              ; save index in smiley index values
.lookForNextLowestRowValue
   dex
   bpl .lowestRowValueLoop
   ldx smileyIndexes,y
   lda smileyRowValues,x
   bpl .skipSmileyIndexSwap
   dey
   lda smileyIndexes,y
   iny
   sta smileyIndexes,y
.skipSmileyIndexSwap
   lda #255
   sta tmpSmileyRowValues,x
   sta lowestSmileyRowValue
   iny
   cpy #MAX_NUM_SMILIES
   bcc .sortSmiliesLoop
   jmp DoneGameCalculations
   
DetermineHorizAllowedMotion SUBROUTINE
   bmi .determineAllowedLeftMotion
   lda playerHorizPos               ; get the player's horizontal position
   cmp #PLAYER_XMAX                 ; player can move right if they have not
   bne .setMotionAllowed            ; reached the right side of the playfield
.setMotionNotAllowed
   sec                              ; set carry to show motion not allowed
   rts

.determineAllowedLeftMotion
   lda playerHorizPos               ; get the player's horizontal position
   cmp #PLAYER_XMIN                 ; player can move left if they have not
   beq .setMotionNotAllowed         ; reached the left side of the playfield
.setMotionAllowed
   clc                              ; clear carry to show motion allowed
   rts

DetermineVertAllowedMotion SUBROUTINE
   bmi .determineAllowedUpwardMotion
   lda playerVertPos                ; get the player's vertical position
   cmp #YMAX
   bcs .setMotionNotAllowed
.determineBasedOnHorizPos
   lda playerHorizPos               ; get the player's horizontal position
   cmp #PLAYER_XMAX                 ; if the player is on the left or right
   beq .setMotionAllowed            ; side of the playfield then they are
   cmp #PLAYER_XMIN                 ; allowed to move vertically
   beq .setMotionAllowed
   jsr DetermineRowOfPlayer
   bne .setMotionAllowed
   tya                              ; move row number to accumulator
   tax                              ; move row number to x
   lda vertMovementDelta            ; get verical movement delta
   bpl .findGapForVerticalMovement  ; branch if moving down
   dex                              ; moving up so reduce row number
.findGapForVerticalMovement
   lda playerHorizPos               ; get the player's horizontal position
   and #$0F                         ; mask fine motion position
   sec
   sbc #4                           ; subtract coarse position by 4
   sta tmpPlayerXPos                ; save it for later
   lda ballHorizPos,x               ; get horizontal position of "gap"
   and #$0F                         ; mask the fine motion position
   cmp tmpPlayerXPos                ; compare to the player's coarse position
   bne .setMotionNotAllowed         ; vertical motion not allowed if not equal
   lda ballHorizPos,x               ; get horizontal position of "gap" again
   and #$F0                         ; mask the coarse position
   sta tmpPlayerXPos                ; save it for later
   lda playerHorizPos               ; get the player's horizontal position
   and #$F0                         ; mask the player's coarse position
   sec
   sbc tmpPlayerXPos                ; subtract the "gap's" coarse position
   cmp #17                          ; vertical motion not allowed if greater
   bcs .setMotionNotAllowed         ; than 16
.setMotionAllowed
   clc                              ; clear carry to show motion allowed
   rts

.determineAllowedUpwardMotion
   lda playerVertPos                ; get the player's vertical position
   cmp #YMIN                        ; branch if vertical position is greater
   bcs .determineBasedOnHorizPos    ; than min value
.setMotionNotAllowed
   sec                              ; set carry to show motion not allowed
   rts

PlayfieldCandyPointers
   .byte leftPF1Candy, leftPF2Candy, rightPF2Candy, rightPF1Candy
   
HorizontalDirectionTable
   .byte 0, 0, 0, 0, 0, 1, 1, 1, 0, -1, -1, -1, 0, 0, 0, 0
   
VerticalDirectionTable
   .byte 0, 0, 0, 0, 0, 1, -1, 0, 0, 1, -1, 0, 0, 1, -1, 0
   
Toothbrush
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $55 ; |.X.X.X.X|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C0 ; |XX......|
   .byte $55 ; |.X.X.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
JawSprites
JawSpritesHorizontal
JawSpritesHorizontal_00
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesHorizontal_01
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesHorizontal_02
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesHorizontal_03
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

JawSpritesVertical
JawSpritesVertical_00
   .byte $34 ; |..XX.X..|
   .byte $76 ; |.XXX.XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $76 ; |.XXX.XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $34 ; |..XX.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesVertical_01
   .byte $34 ; |..XX.X..|
   .byte $76 ; |.XXX.XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $76 ; |.XXX.XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $34 ; |..XX.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesVertical_02
   .byte $20 ; |..X.....|
   .byte $62 ; |.XX...X.|
   .byte $46 ; |.X...XX.|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $62 ; |.XX...X.|
   .byte $46 ; |.X...XX.|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
JawSpritesVertical_03
   .byte $20 ; |..X.....|
   .byte $62 ; |.XX...X.|
   .byte $46 ; |.X...XX.|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $62 ; |.XX...X.|
   .byte $46 ; |.X...XX.|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
PassThroughDelayMask
   .byte D0, D1, D2, D3, D4, D5, D6, D7
   
PassThroughMask
   .byte ~D0, ~D1, ~D2, ~D3, ~D4, ~D5, ~D6, ~D7
   
CandyBarMaskingValues
   REPEAT 2
      .byte D6, D4, D2, D0, D0, D2, D4, D6
   REPEND

   REPEAT 2
      .byte D7, D5, D3, D1, D1, D3, D5, D7
   REPEND

DifficultySwitchMask
   .byte P0_DIFF_MASK, P1_DIFF_MASK
   
SmileySprites
SmileyAnimation_0
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_1
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $ED ; |XXX.XX.X|
   .byte $ED ; |XXX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DE ; |XX.XXXX.|
   .byte $E1 ; |XXX....X|
   .byte $F3 ; |XXXX..XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_2
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $F6 ; |XXXX.XX.|
   .byte $F6 ; |XXXX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F9 ; |XXXXX..X|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_3
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7B ; |.XXXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_4
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_5
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $ED ; |XXX.XX.X|
   .byte $1E ; |...XXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_6
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $F6 ; |XXXX.XX.|
   .byte $0F ; |....XXXX|
   .byte $9F ; |X..XXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SmileyAnimation_7
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7B ; |.XXXX.XX|
   .byte $87 ; |X....XXX|
   .byte $CF ; |XX..XXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   
SmileyAnimationTable
   .word SmileyAnimation_0, SmileyAnimation_1, SmileyAnimation_2
   .word SmileyAnimation_3, SmileyAnimation_4, SmileyAnimation_5
   .word SmileyAnimation_6, SmileyAnimation_7

NumberFonts
zero
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
one
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
two
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
three
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
four
   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $3C ; |..XXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $7E ; |.XXXXXX.|
   .byte $0C ; |....XX..|
   .byte $00 ; |........|
five
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $7C ; |.XXXXX..|
   .byte $06 ; |.....XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
six
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $60 ; |.XX.....|
   .byte $7C ; |.XXXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
seven
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
eight
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
nine
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $3E ; |..XXXXX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
DoneGameCalculations
   lda #0
   sta GRP0                         ; clear the player graphics to avoid
   sta GRP1                         ; bleeding for next frame
   sta VDELP0                       ; do not vertical delay the players
   sta VDELP1
   sta NUSIZ1
   sta smileyIndex
   sta smileyInSection              ; set smiley not in kernel section
   ldx smileyIndexes
   stx currentSmileyNumber
   ldy smileyRowValues,x
   bne .setTempSmileyGraphics
   lda #$FF
   sta smileyInSection              ; set smiley in kernel section
   lda smileyGraphics
.setTempSmileyGraphics
   sta tmpSmileyGraphics
   lda leftPF1Candy                 ; get the left PF1 candy values
   ldy player1State                 ; check to see if player 1 is active
   bmi .setLeftPF1CandyPattern      ; branch if player 1 is active
   asl                              ; shift candy value left for player 2
.setLeftPF1CandyPattern
   ora #$80 | PLAYER2_CANDY_MASK
   sta leftPF1CandyBarPattern       ; set the left PF1 pattern for the kernel
   lda leftPF2Candy                 ; get the left PF2 candy values
   cpy #0                           ; remember y holds the active player flag
   bpl .setLeftPF2CandyPattern
   lsr                              ; shift candy value right for player 1
.setLeftPF2CandyPattern
   ora #PLAYER1_CANDY_MASK
   sta leftPF2CandyBarPattern       ; set the left PF2 pattern for the kernel
   lda rightPF2Candy                ; get the right PF2 candy values
   cpy #0                           ; y holds the active player flag
   bmi .setRightPF2CandyPattern
   asl                              ; shift candy value left for player 2
.setRightPF2CandyPattern
   ora #PLAYER2_CANDY_MASK
   sta rightPF2CandyBarPattern      ; set right PF2 pattern for the kernel
   lda rightPF1Candy                ; get the right PF1 candy values
   cpy #0                           ; y holds the active player flag
   bpl .setRightPF1CandyPattern
   lsr                              ; shift candy value right for player 1
.setRightPF1CandyPattern
   ora #PLAYER1_CANDY_MASK
   sta rightPF1CandyBarPattern      ; set right PF1 pattern for the kernel
   lda gameState                    ; get the current game state
   and #MASK_GAME_SELECTION         ; mask to get game selection
   clc                              ; increment number so player sees game
   adc #1                           ; selection as 1 - 6
   ldx #2
   jsr LSBToDigits
DisplayKernel SUBROUTINE
.waitTime
   ldy TIMINT
   bpl .waitTime
   ldy #0
   jsr LivesKernel
;--------------------------------------
   lda #%10110000             ; 2
   sta PF0                    ; 3 = @22
   ldx smileyIndexes          ; 3
   lda smileyHorizValues,x    ; 4
   sta HMCLR                  ; 3 = @32
   sta HMP1                   ; 3 = @35
   and #$0F                   ; 2
   sta tmpSmileyCoarseValue   ; 3
   lda playerHorizPos         ; 3
   sta HMP0                   ; 3 = @46
   and #$0F                   ; 2
   sta WSYNC
;--------------------------------------
   tax                        ; 2 = @02
.coarseMovePlayer
   dex                        ; 2
   bne .coarseMovePlayer      ; 2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #MSBL_SIZE4            ; 2
   sta NUSIZ0                 ; 3 = @08
   lda #0                     ; 2
   sta kernelSection          ; 3
   sta playerGraphicIndex     ; 3
   sta VDELP1                 ; 3 = @19
   sta VDELP0                 ; 3 = @22
   sta HMP0                   ; 3 = @25
   ldy #1                     ; 2
   jmp JumpIntoGameKernel     ; 3
   
DigitLoop
   lda (digitPointers + 6),y  ; 5
   tax                        ; 2
   lda NumberFonts,y          ; 4
   sta tempDigit              ; 3
   lda (digitPointers + 2),y  ; 5
   sta GRP1                   ; 3 = @30
   nop                        ; 2
   lda (digitPointers + 4),y  ; 5
   ldy tempDigit              ; 3
   sta GRP0                   ; 3 = @43
   stx GRP1                   ; 3 = @46
   sty GRP0                   ; 3 = @49
   sty GRP1                   ; 3 = @52
   ldy loopCount              ; 3
   iny                        ; 2
   bne .drawDigits            ; 3
   
DrawScoreDigits
   lda PlayerScoreColors,y    ; 4
   ldx vitaminActiveTimer     ; 3
   bpl .colorScoreDigits      ; 2
   eor randomSeed             ; 3
   and #COLOR_LIGHT_LUM       ; 2
.colorScoreDigits
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3
   lda #TWO_COPIES            ; 2
   sta NUSIZ1                 ; 3
   sta VDELP0                 ; 3
   sta VDELP1                 ; 3
   sta HMCLR                  ; 3
   tay                        ; 2
.drawDigits
   lda (digitPointers),y      ; 5
   sta GRP0                   ; 3 = @68
   sta WSYNC
;--------------------------------------
   sty loopCount              ; 3
   cpy #H_FONT - 1            ; 2
   bcc DigitLoop              ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @12
   sta GRP1                   ; 3 = @15
   sta GRP0                   ; 3 = @18
   rts                        ; 6

LivesKernel
   lda playerStates,y         ; 4         get current player state
   and #MASK_LIVES            ; 2         get number of remaining lives
   tax                        ; 2         move lives number to x
   lda LivesIndicatorCount,x  ; 4
   bne .getLivesIndicatorColor; 2³        set lives colors if lives remain
   lda #PURPLE + 6            ; 2         set color to maze color
   bne .determineLivesColor   ; 3         unconditional branch
   
.getLivesIndicatorColor
   lda ActivePlayerLivesColor,y; 4
.determineLivesColor
   ldx vitaminActiveTimer     ; 3
   bpl .colorLivesIndicator   ; 2³
   eor randomSeed             ; 3
   and #$7F                   ; 2
.colorLivesIndicator
   sta COLUP0                 ; 3
   ldx #5                     ; 2
   stx WSYNC
;--------------------------------------
.coarseMoveLives
   dex                        ; 2
   bne .coarseMoveLives       ; 2³
   stx RESP0                  ; 3 = @27   set lives indicators @ pixel 81
   ldx #4                     ; 2
.wait19Cycles
   dex                        ; 2
   bne .wait19Cycles          ; 2³
   lda playerStates,y         ; 4 = @52   get current player state
   and #MASK_LIVES            ; 2         get number of remaining lives
   tax                        ; 2         move lives number to x
   lda LivesIndicatorCount,x  ; 4
   sta NUSIZ0                 ; 3 = @63
   sta RESP1                  ; 3 = @66
   sta WSYNC
;--------------------------------------
   lda #%00110000             ; 2
   sta PF0                    ; 3 = @05
   lda #%00000000             ; 2
   sta PF1                    ; 3 = @10
   sta PF2                    ; 3 = @13
   ldx LivesIndicatorColor,y  ; 4
   lda vitaminActiveTimer     ; 3
   bmi DrawLivesIndicators    ; 2²
   stx COLUP1                 ; 3 = @25
DrawLivesIndicators
   ldy #0                     ; 2
.livesIndicatorLoop
   lda (digitPointers + 4),y  ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda LivesIndicator,y       ; 4
   sta GRP0                   ; 3 = @10
   iny                        ; 2
   cpy #H_FONT - 1            ; 2
   bcc .livesIndicatorLoop    ; 2²
   jsr SetXForActivePlayer    ; 6         determine which player is active
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP1                   ; 3 = @05
   sta GRP0                   ; 3 = @08
   sta GRP1                   ; 3 = @11
   ldy #5                     ; 2
.coarseMoveScoreDigits
   dey                        ; 2
   bne .coarseMoveScoreDigits ; 2²
   sta RESP0                  ; 3 = @40
   sta RESP1                  ; 3 = @43
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @48
   lda ActivePlayerLivesColor,x; 4
   ldx vitaminActiveTimer     ; 3
   bpl .colorPlayer0          ; 2³
   eor randomSeed             ; 3
   and #COLOR_LIGHT_LUM       ; 2
.colorPlayer0
   sta COLUP0                 ; 3 = @65
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #%11111111             ; 2
   sty PF1                    ; 3 = @08
   sty PF2                    ; 3 = @11
   rts                        ; 6

LivesIndicatorColor
   .byte PLAYER1_LIVES_COLOR, PLAYER2_LIVES_COLOR
   
LivesIndicatorCount
   .byte ONE_COPY,ONE_COPY,MSBL_SIZE2,TWO_COPIES,THREE_COPIES
   
LivesIndicator
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   
DetermineToDrawPlayers
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .setPlayerGraphics     ; 2³
   cpx #H_PLAYER              ; 2
   bcs .setPlayerGraphics     ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.setPlayerGraphics
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda smileyInSection        ; 3
Waste12Cycles
   rts                        ; 6

.setPlayer2PF2CandyPattern
   lda rightPF2Candy,x        ; 4
   ora #PLAYER2_CANDY_MASK    ; 2
   sta rightPF2CandyBarPattern; 3
   lda rightPF1Candy,x        ; 4
   lsr                        ; 2
   jmp .setRightPF1CandyPattern; 3
   
MainKernelLoop
   lda #0                     ; 2
   ldx playerGraphicIndex     ; 3
   cpy playerVertPos          ; 3
   bcc LastScanlineOfSection  ; 2³
   cpx #H_PLAYER              ; 2
   bcs LastScanlineOfSection  ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
LastScanlineOfSection
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda #%10000000             ; 2
   sta PF1                    ; 3 = @08
   lda #ENABLE_BM             ; 2
   sta ENABL                  ; 3 = @13   enable ball (pass through gap)
   lda #%00000000             ; 2
   sta PF2                    ; 3 = @18
   iny                        ; 2         increment scan line count
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .skipReadPlayerGraphics; 2³
   cpx #H_PLAYER              ; 2
   bcs .skipReadPlayerGraphics; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.skipReadPlayerGraphics
   sta tmpPlayerGraphics_b    ; 3
   stx playerGraphicIndex     ; 3
   ldx currentSmileyNumber    ; 3
   lda smileyHorizValues,x    ; 4
   ldx kernelSection          ; 3
   sta HMCLR                  ; 3 = @56
   sta HMP1                   ; 3 = @59
   and #$0F                   ; 2
   sta tmpSmileyCoarseValue   ; 3
   sta WSYNC
;--------------------------------------
   lda tmpPlayerGraphics_b    ; 3
   sta GRP0                   ; 3 = @06
   lda player1State           ; 3         check to see if player 1 is active
   bmi .setPlayer2PF2CandyPattern; 2³     branch if player 2 is active
   lda rightPF2Candy,x        ; 4
   asl                        ; 2
   ora #PLAYER2_CANDY_MASK    ; 2
   sta rightPF2CandyBarPattern; 3
   lda rightPF1Candy,x        ; 4
.setRightPF1CandyPattern
   ora #PLAYER1_CANDY_MASK    ; 2
   sta rightPF1CandyBarPattern; 3
JumpIntoGameKernel
   iny                        ; 2         increment scan line counter
   lda #0                     ; 2
   ldx playerGraphicIndex     ; 3
   cpy playerVertPos          ; 3
   bcc SectionFirstScanline   ; 2³
   cpx #H_PLAYER              ; 2
   bcs SectionFirstScanline   ; 2³
   lda playerGraphics,x       ; 4
   inc playerGraphicIndex     ; 5
SectionFirstScanline
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   ldx #DISABLE_BM            ; 2
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @10
   stx ENABL                  ; 3 = @13   disable ball graphic
   sta PF2                    ; 3 = @16
   ldx currentSmileyNumber    ; 3
   lda smileyRowValues,x      ; 4
   cmp kernelSection          ; 3
   bne .noSmileyThisSection   ; 2³
   lda smileyColors,x         ; 4
   sta COLUP1                 ; 3 = @35   color smiley
   sta smileyInSection        ; 3         set to say smiley is in section
   lda smileyGraphics         ; 3
   sta tmpSmileyGraphics      ; 3
.jmpIntoFirstSection
   iny                        ; 2         increment scan line counter
   ldx playerGraphicIndex     ; 3
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .skipSetPlayerGraphics ; 2³
   cpx #H_PLAYER              ; 2
   bcs .skipSetPlayerGraphics ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.skipSetPlayerGraphics
   iny                        ; 2         increment scan line counter
   stx playerGraphicIndex     ; 3
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3
   cpy playerVertPos          ; 3         compare scan line and player vert
   bcc .waste4Cycles          ; 2³
   cpx #H_PLAYER              ; 2
   bcs MoveSmileyNoPlayer     ; 2³
   lda playerGraphics,x       ; 4
   ldx tmpSmileyCoarseValue   ; 3
   beq .resetSmileyPosition   ; 2³
   nop                        ; 2 = @23
.coarseMoveSmiley
   dex                        ; 2
   bne .coarseMoveSmiley      ; 2³
.resetSmileyPosition
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   inc playerGraphicIndex     ; 5
   jmp ScanlineAfterSmileyMove; 3
   
.noSmileyThisSection
   lda #0                     ; 2
   sta smileyInSection        ; 3         set to say smiley not in section
   sta tmpSmileyGraphics      ; 3
   jmp .jmpIntoFirstSection   ; 3
   
.waste4Cycles
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2 = @13
MoveSmileyNoPlayer SUBROUTINE
   lda #0                     ; 2 = @15
   ldx.w tmpSmileyCoarseValue ; 4
   beq .resetSmileyPosition   ; 2³
   nop                        ; 2 = @23
.coarseMoveSmiley
   dex                        ; 2
   bne .coarseMoveSmiley      ; 2³
.resetSmileyPosition
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
ScanlineAfterSmileyMove
   sta GRP0                   ; 3 = @14
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @20
   lda smileyInSection        ; 3
   beq .skipSmileyVariables   ; 2³
   ldx smileyIndex            ; 3
   cpx #MAX_NUM_SMILIES - 1   ; 2
   bcs .setTempSmileyGraphic  ; 2³
   inx                        ; 2
   stx smileyIndex            ; 3
   lda smileyIndexes,x        ; 4
   sta currentSmileyNumber    ; 3
.setTempSmileyGraphic
   lda smileyGraphics + 1     ; 3
   sta tmpSmileyGraphics      ; 3
.skipSmileyVariables
   ldx playerGraphicIndex     ; 3
   iny                        ; 2         increment scan line number
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc SectionFifthScanline   ; 2³
   cpx #H_PLAYER              ; 2
   bcs SectionFifthScanline   ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
SectionFifthScanline SUBROUTINE
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda smileyInSection        ; 3
   beq .skipSetSmileyGraphic2 ; 2³
   lda smileyGraphics + 2     ; 3
   sta tmpSmileyGraphics      ; 3
.skipSetSmileyGraphic2
   jsr DetermineToDrawPlayers ; 6
;--------------------------------------
   beq .skipSetSmileyGraphic3 ; 2³
   lda smileyGraphics + 3     ; 3 = @23
   sta tmpSmileyGraphics      ; 3
.skipSetSmileyGraphic3
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc SectionSeventhScanline; 2³
   cpx #H_PLAYER              ; 2
   bcs SectionSeventhScanline; 2
   lda playerGraphics,x       ; 4
   inx                        ; 2
SectionSeventhScanline
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   cpy #79                    ; 2
   bne .skipVitamin           ; 2³
   lda gameBoardState         ; 3         get the current board state
   and #$0F                   ; 2         mask to get vitamin timer
   bne .skipVitamin           ; 2³        branch if vitamin not be shown
   lda #ENABLE_BM             ; 2
   sta ENAM0                  ; 3 = @25
.skipVitamin
   lda smileyInSection        ; 3
   beq .skipSetSmileyGraphic4 ; 2³
   lda smileyGraphics + 4     ; 3
   sta tmpSmileyGraphics      ; 3
.skipSetSmileyGraphic4
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc SectionEighthScanline  ; 2³
   cpx #H_PLAYER              ; 2
   bcs SectionEighthScanline  ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
SectionEighthScanline
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda gameBoardState         ; 3         get the current board state
   bpl .skipToothbrushHandle  ; 2³        branch if not showing Toothbrush
   lda #QUAD_SIZE             ; 2
   sta NUSIZ1                 ; 3 = @19
   lda #RED                   ; 2
   sta COLUP1                 ; 3 = @24
.skipToothbrushHandle
   lda smileyInSection        ; 3
   beq JumpIntoCandyBarKernel ; 2³
   lda smileyGraphics + 5     ; 3
   sta tmpSmileyGraphics      ; 3
   jmp JumpIntoCandyBarKernel ; 3
   
CandyBarKernel
.skipSmileyDraw
   lda rightPF2CandyBarPattern; 3
   sta.w PF2                  ; 4
   lda rightPF1CandyBarPattern; 3
   sta PF1                    ; 3
   bne .nextCandyBarScanline  ; 3         unconditional branch
   
.skipPlayerDraw
   lda #$FF                   ; 2
   bne .drawRightCandyBars    ; 3         unconditional branch
   
.skipPlayerDraw_c
   sta WSYNC
;--------------------------------------
   bmi .jmpIntoNextCandyScanline; 3         unconditional branch
   
.skipPlayerDraw_b
   lda #0                     ; 2
   beq StartNextCandyScanline ; 3         unconditional branch
   
.skipSmileyDraw_b
   lda rightPF2CandyBarPattern; 3
   sta.w  PF2                 ; 4
   lda rightPF1CandyBarPattern; 3
   sta PF1                    ; 3
   bne .continueCandyBarKernel; 3         unconditional branch
   
.skipPlayerDraw_d
   lda #$FF                   ; 2
   bne .drawNextRightCandyBars; 3         unconditional branch
   
.skipPlayerDraw_f
   sta WSYNC
;--------------------------------------
   bmi JmpIntoEndCandyBarKernel; 3        unconditional branch
   
.skipPlayerDraw_e
   lda #0                     ; 2
   beq EndCandyBarKernel      ; 3         unconditional branch
   
JumpIntoCandyBarKernel
   iny                        ; 2         increment scan line count
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .startCandyBarKernel   ; 2³
   cpx #H_PLAYER              ; 2
   bcs .startCandyBarKernel   ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.startCandyBarKernel
   iny                        ; 2         increment scan line count
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda leftPF1CandyBarPattern ; 3
   sta PF1                    ; 3 = @15
   lda leftPF2CandyBarPattern ; 3
   sta PF2                    ; 3 = @21
   cpy playerVertPos          ; 3
   bcc .skipPlayerDraw        ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.drawRightCandyBars
   sta tmpPlayerGraphics_b    ; 3
   lda smileyInSection        ; 3
   beq .skipSmileyDraw        ; 2³
   nop                        ; 2
   lda rightPF2CandyBarPattern; 3
   sta PF2                    ; 3 = @48
   lda rightPF1CandyBarPattern; 3
   sta PF1                    ; 3 = @54
   lda smileyGraphics + 6     ; 3
   sta tmpSmileyGraphics      ; 3
.nextCandyBarScanline
   iny                        ; 2         increment scan line count
   cpx #H_PLAYER + 1          ; 2
   bcs .skipPlayerDraw_b      ; 2³
   lda tmpPlayerGraphics_b    ; 3
   bmi .skipPlayerDraw_c      ; 2³
StartNextCandyScanline
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
.jmpIntoNextCandyScanline
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda leftPF1CandyBarPattern ; 3
   sta PF1                    ; 3 = @15
   lda leftPF2CandyBarPattern ; 3
   sta PF2                    ; 3 = @21
   cpy playerVertPos          ; 3
   bcc .skipPlayerDraw_d      ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.drawNextRightCandyBars
   sta tmpPlayerGraphics_b    ; 3
   lda smileyInSection        ; 3
   beq .skipSmileyDraw_b      ; 2³
   nop                        ; 2
   lda rightPF2CandyBarPattern; 3
   sta PF2                    ; 3 = @48
   lda rightPF1CandyBarPattern; 3
   sta PF1                    ; 3 = @54
   lda smileyGraphics + 7     ; 3
   sta tmpSmileyGraphics      ; 3
.continueCandyBarKernel
   cpx #H_PLAYER              ; 2
   bcs .skipPlayerDraw_e      ; 2³
   lda tmpPlayerGraphics_b    ; 3
   bmi .skipPlayerDraw_f      ; 2³
EndCandyBarKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
JmpIntoEndCandyBarKernel SUBROUTINE
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @14
   sta PF2                    ; 3 = @17
   lda smileyInSection        ; 3
   beq .skipSetSmileyGraphic8 ; 2³
   lda smileyGraphics + 8     ; 3
   sta tmpSmileyGraphics      ; 3
.skipSetSmileyGraphic8
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .skipPlayerDraw_a      ; 2³
   cpx #H_PLAYER              ; 2
   bcs .skipPlayerDraw_a      ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.skipPlayerDraw_a
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda gameBoardState         ; 3         get the current board state
   bpl .skipDrawToothbrush    ; 2³        branch if not showing Toothbrush
   lda #ONE_COPY              ; 2
   sta NUSIZ1                 ; 3
   lda #WHITE                 ; 2
   sta COLUP1                 ; 3
.skipDrawToothbrush
   lda smileyInSection        ; 3
   beq .determineToDrawPlayers; 2³
   lda smileyGraphics + 9     ; 3
   sta tmpSmileyGraphics      ; 3
.determineToDrawPlayers
   jsr DetermineToDrawPlayers ; 6
;--------------------------------------
   beq .setVitaminEnableState ; 2³
   lda #DISABLE_BM            ; 2
   sta ENAM0                  ; 3 = @25
   lda smileyGraphics + 10    ; 3
   sta tmpSmileyGraphics      ; 3
   lda #DISABLE_BM            ; 2
.setVitaminEnableState
   sta ENAM0                  ; 3
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .skipPlayerDraw_b      ; 2³
   cpx #H_PLAYER              ; 2
   bcs .skipPlayerDraw_b      ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.skipPlayerDraw_b
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   lda smileyInSection        ; 3
   beq .skipSetSmileyGraphic11; 2³
   lda smileyGraphics + 11    ; 3
   sta tmpSmileyGraphics      ; 3
.skipSetSmileyGraphic11
   iny                        ; 2
   stx playerGraphicIndex     ; 3
   inc kernelSection          ; 5
   ldx kernelSection          ; 3
   lda leftPF2Candy,x         ; 4
   ldx player1State           ; 3         check to see if player 1 is active
   bpl .orInCandyMask         ; 2³        branch if player 1 is active
   lsr                        ; 2
.orInCandyMask
   ora #PLAYER1_CANDY_MASK    ; 2
   sta leftPF2CandyBarPattern ; 3
   ldx playerGraphicIndex     ; 3
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc PositionPassThroughGap ; 2³
   cpx #H_PLAYER              ; 2
   bcs PositionPassThroughGap ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
PositionPassThroughGap SUBROUTINE
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda tmpSmileyGraphics      ; 3
   sta GRP1                   ; 3 = @09
   iny                        ; 2
   lda #0                     ; 2
   cpy playerVertPos          ; 3
   bcc .setTempPlayerGraphics ; 2³
   cpx #H_PLAYER              ; 2
   bcs .setTempPlayerGraphics ; 2³
   lda playerGraphics,x       ; 4
   inx                        ; 2
.setTempPlayerGraphics
   sta tmpPlayerGraphics_a    ; 3
   stx playerGraphicIndex     ; 3
   sty tmpScanlineCount       ; 3         store scan line count for later
   sta HMCLR                  ; 3 = @40
   ldx kernelSection          ; 3
   lda ballHorizPos - 1,x     ; 4
   sta HMBL                   ; 3 = @50
   and #$0F                   ; 2         mask ball fine motion
   tay                        ; 2
   sta WSYNC
;--------------------------------------
   lda tmpPlayerGraphics_a    ; 3
   sta GRP0                   ; 3 = @06
   lda #0                     ; 2
   sta GRP1                   ; 3 = @11
   txa                        ; 2
   ldx playerGraphicIndex     ; 3
   cmp #MAX_KERNEL_SECTIONS   ; 2
   beq ScoreKernel            ; 2³
   lda #0                     ; 2 = @22
.coarseMoveBall
   dey                        ; 2
   bne .coarseMoveBall        ; 2³
   sty RESBL                  ; 3
   ldy tmpScanlineCount       ; 3         restore scan line count
   iny                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   cpy playerVertPos          ; 3
   bcc .skipPlayerDraw        ; 2³
   cpx #H_PLAYER              ; 2
   bcs .skipPlayerDraw        ; 2³
   lda playerGraphics,x       ; 4
   inc playerGraphicIndex     ; 5
.skipPlayerDraw
   sta GRP0                   ; 3 = @24
   ldx kernelSection          ; 3
   lda leftPF1Candy,x         ; 4
   ldx player1State           ; 3         check to see if player 1 is active
   bmi .setLeftPF1CandyPattern; 2³        branch if player 2 is active
   asl                        ; 2
.setLeftPF1CandyPattern
   ora #$80 | PLAYER2_CANDY_MASK; 2
   sta leftPF1CandyBarPattern ; 3
   iny                        ; 2
   jmp MainKernelLoop         ; 3
   
ScoreKernel
   lda levelNumber            ; 3 = @24   get level number
   ldx player1State           ; 3         check to see if player 1 is active
   bpl .maskForLevelNumber    ; 2³        branch if player 1 is active
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
.maskForLevelNumber
   and #$07                   ; 2
   clc                        ; 2         increment by 1 so player sees
   adc #1                     ; 2         level number starting with 1
   ldx #2                     ; 2
   jsr LSBToDigits            ; 6
   ldy #1                     ; 2         do lives kernel for player 2
   jsr LivesKernel            ; 6
;--------------------------------------
   sty PF0                    ; 3 = @20
   iny                        ; 2         y = 0
   lda player1ScoreMSB        ; 3
   ldx #0                     ; 2
   jsr BCDToDigits            ; 6 = @33
;--------------------------------------
   lda player1ScoreLSB        ; 3 = @16
   ldx #4                     ; 2
   jsr BCDToDigits            ; 6 = @24
;--------------------------------------
   jsr DrawScoreDigits        ; 6 = @10
   ldy #1                     ; 2 = @36
   lda player2ScoreMSB        ; 3
   ldx #0                     ; 2
   jsr BCDToDigits            ; 6 = @47
;--------------------------------------
   lda player2ScoreLSB        ; 3 = @30
   ldx #4                     ; 2
   jsr BCDToDigits            ; 6 = @38
;--------------------------------------
   lda gameState              ; 3 = @21   get current game state
   lsr                        ; 2         move D0 to carry
   bcs .drawSecondPlayerScore ; 2²        branch if this is a two player game
   ldx #6                     ; 2
.skipSevenScanLines
   stx WSYNC
   dex                        ; 2
   bpl .skipSevenScanLines    ; 2³
   jsr Waste12Cycles          ; 6
   bmi .jmpToOverscan         ; 3         unconditional branch
   
.drawSecondPlayerScore
   jsr DrawScoreDigits        ; 6
.jmpToOverscan
   jmp Overscan               ; 3
   
PlayerScoreColors
   .byte PLAYER1_SCORE_COLOR, PLAYER2_SCORE_COLOR, BLACK, BLACK, BLACK
   
ActivePlayerLivesColor
   .byte PLAYER1_ACTIVE_LIVES_COLOR, PLAYER2_ACTIVE_LIVES_COLOR
   
   .org ROM_BASE + 4096 - 6, 0
   .word Start
   .word Start
   .word Start