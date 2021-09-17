   LIST OFF
; ***  M O U S E  T R A P  ***
; Copyright 1982 Coleco, Inc.
; Designers: Sylvia Day and Henry Will, IV
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: March 26, 2021
;
;  *** 122 BYTES OF RAM USED 6 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, COLECO, INC.                                 =
; =                                                                            =
; ==============================================================================

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;

   include "vcs.h"
   include "macro.h"
   include "tia_constants.h"

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

COMPILE_REGION         = NTSC       ; change to compile for different regions

   ENDIF

   IF !(COMPILE_REGION = NTSC || COMPILE_REGION = PAL50 || COMPILE_REGION = PAL60)

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0, PAL50 = 1, PAL60 = 2"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

VSYNC_TIME              = 22

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 40
OVERSCAN_TIME           = 36

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 67
OVERSCAN_TIME           = 66
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
YELLOW                  = $10
RED                     = $30
LT_BLUE                 = $90
GREEN                   = $C0

COLOR_CAT               = YELLOW + 14
COLOR_MAZE              = GREEN + 12
RESERVE_BONE_COLOR      = GREEN + 12
MAZE_COLOR_XOR          = LT_BLUE + 4

   ELSE

GREEN                   = $30
YELLOW                  = $40
RED                     = $60
CYAN                    = $90

COLOR_CAT               = YELLOW + 10
COLOR_MAZE              = GREEN + 10
RESERVE_BONE_COLOR      = GREEN + 10
MAZE_COLOR_XOR          = CYAN + 3

   ENDIF

RESERVE_LIVES_COLOR     = BLACK + 10
COLOR_MOUSE             = WHITE - 4
COLOR_DOG               = RED + 6
SCORE_COLOR             = YELLOW + 10

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

XMIN                    = 0
XMAX                    = 159
XMID                    = (XMAX + 1) / 2

H_KERNEL_SECTION        = 18
;
; Game initial values
;
INIT_PLAYER_HORIZ_POS   = XMID
INIT_NUM_LIVES          = 3
INIT_PLAYER_MAZE_COORDINATES = 5 << 4 | 5 
INIT_BOTTOM_CAT_HOME_COORDINATES = 4 << 4 | 7
INIT_TOP_CAT_HOME_COORDINATES = 5 << 4 | 0
INIT_RIGHT_CAT_HOME_COORDINATES = 9 << 4 | 4
INIT_LEFT_CAT_HOME_COORDINATES = 0 << 4 | 3
;
; Allowed direction constants
;
ALLOW_MOVEMENT_MASK     = %10000000
DIR_CHANGE_MASK         = %01000000
DIR_ADJUSTMENT_MASK     = %00100000
MOVEMENT_STEPS_MASK     = %00011111

CURRENTLY_MOVING        = 0 << 7
STOPPED_AT_INTERSECTION = 1 << 7
VERT_DIR_CHANGE         = 1 << 6
HORIZ_DIR_CHANGE        = 0 << 6
DIR_ADJUSTMENT_NEGATIVE = 1 << 5
DIR_ADJUSTMENT_POSITIVE = 0 << 5

MAX_NUM_CHEESE          = 66
;
; Game board status constants
;
CHEESE_TALLY_MASK       = $7F
TRAPDOOR_MASK           = $80
;
; BCD Point values (subtracted by 1 because carry is set for addition)
;
POINTS_EAT_CHEESE       = $00
POINTS_BITE_CAT         = $09
POINTS_CLEAR_RACK       = $99
;
; Audio Value constants
;
END_AUDIO_TUNE          = 0
AUDIO_DURATION_MASK     = $E0
AUDIO_TONE_MASK         = $1F
;
; Sprite constants
;
BLANK_MOUSE_SPRITE_OFFSET = 0
MOUSE_SPRITE_OFFSET     = 21
DOG_SPRITE_OFFSET       = 56
CAT_FACING_DOWN_SPRITE_OFFSET = 90
CAT_FACING_UP_SPRITE_OFFSET = 127
BLANK_CAT_SPRITE_OFFSET = 140
CAT_FACING_LEFT_SPRITE_OFFSET = 161
CAT_FACING_RIGHT_SPRITE_OFFSET = 179

FAST_CAT_DELAY_VALUE    = 15
INIT_DOG_TIMER_VALUE    = 100
;
; Maze building constants
;
MAZE_BUILD_RAM_IDX_MASK = $7F
MAZE_BUILD_REMOVE_BIT   = 0 << 7 
MAZE_BUILD_ADD_BIT      = 1 << 7
;
; Cat directional constants
;
DIRECTION_HORIZONTAL    = 1 << 1
DIRECTION_VERTICAL      = 0 << 1
DIRECTION_NEGATIVE      = 0 << 0
DIRECTION_POSITIVE      = 1 << 0

CAT_DIR_UP              = DIRECTION_VERTICAL | DIRECTION_NEGATIVE
CAT_DIR_DOWN            = DIRECTION_VERTICAL | DIRECTION_POSITIVE
CAT_DIR_LEFT            = DIRECTION_HORIZONTAL | DIRECTION_NEGATIVE
CAT_DIR_RIGHT           = DIRECTION_HORIZONTAL | DIRECTION_POSITIVE

;===============================================================================
; M A C R O S
;===============================================================================

;
; time wasting macros
;
   MAC SLEEP_6
      lda (GRP0,x)
   ENDM
   
   MAC SLEEP_12
      SLEEP_6
      SLEEP_6
   ENDM

;----------------------------------------------------------
; MAZE_RULES
;
; Build the byte representation of the Maze Rules. Upper nybble represents
; rules for a standard maze. The lower nybble represents the rules for the
; altered (Trapdoor closed) maze.
;
   MAC MAZE_RULES
      .byte {1} & $F0 | [({2} & $F0) >> 4]
   ENDM

;----------------------------------------------------------
; CAT_DIR_PRIORITY
;
; Build the byte representation of the Cat direction priority for a maze
; coordinate.
;
   MAC CAT_DIR_PRIORITY
      .byte {1} << 6 | {2} << 4 | {3} << 2 | {4} << 0
   ENDM
   
;----------------------------------------------------------
; FILL_BOUNDARY byte#
; Original author: Dennis Debro (borrowed from Bob Smith / Thomas Jentzsch)
;
; Push data to a certain position inside a page.
;
; eg: FILL_BOUNDARY 5, 234    ; position at byte #5 in page with $EA is byte filler

.BYTES_TO_SKIP SET 0

   MAC FILL_BOUNDARY
      IF <. > {1}

.BYTES_TO_SKIP SET (256 - <.) + {1}

      ELSE

.BYTES_TO_SKIP SET (256 - <.) - (256 - {1})

      ENDIF

      REPEAT .BYTES_TO_SKIP

     .byte {2}

     REPEND

   ENDM
   
;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

mazeCheese              ds 48
;--------------------------------------
leftPF0MazeCheese       = mazeCheese
leftPF1MazeCheese       = leftPF0MazeCheese + 8
leftPF2MazeCheese       = leftPF1MazeCheese + 8
rightPF0MazeCheese      = leftPF2MazeCheese + 8
rightPF1MazeCheese      = rightPF0MazeCheese + 8
rightPF2MazeCheese      = rightPF1MazeCheese + 8
mazeGraphicPointers     ds 6
;--------------------------------------
pf0GraphicPointer       = mazeGraphicPointers
pf1GraphicPointer       = pf0GraphicPointer + 2
pf2GraphicPointer       = pf1GraphicPointer + 2
mouseLSBPointers        ds 8
catLSBPointers          ds 8
playerHorizPos          ds 1
playerAllowedDirection  ds 1
playerMazeCoordinates   ds 1
catHorizPositionValues  ds 8
catAllowedDirections    ds 4
catMazeCoordinates      ds 4
tmpCatDirection         ds 1
;--------------------------------------
tmpCheeseRAMValue       = tmpCatDirection
;--------------------------------------
tmpScoreColor           = tmpCheeseRAMValue
;--------------------------------------
tmpCatHorizPos          = tmpScoreColor
;--------------------------------------
tmpHeightKernelSection  = tmpCatHorizPos
;--------------------------------------
tmpMulti2               = tmpHeightKernelSection
;--------------------------------------
tmpMulti8               = tmpMulti2
;--------------------------------------
tmpMouseCoordinateY     = tmpMulti8
;--------------------------------------
tmpCoordinateX          = tmpMouseCoordinateY
;--------------------------------------
tmpCatPlayerVertDistance = tmpCoordinateX
;--------------------------------------
tmpVertCatIndex         = tmpCatPlayerVertDistance
;--------------------------------------
tmpMazeCoordinates      = tmpVertCatIndex
;--------------------------------------
tmpObjectIntersectionState = tmpMazeCoordinates
;--------------------------------------
tmpCatZoneConflictState = tmpObjectIntersectionState
mouseGraphicPointer     ds 2
catGraphicPointer       ds 2
animationTimer          ds 1
gameOverState           ds 1
remainingBones          ds 1
remainingLives          ds 1
digitGraphicPtrs        ds 8
;--------------------------------------
tmpTopMazeBoneGraphics  = digitGraphicPtrs
;--------------------------------------
tmpMazeBoneGraphicsNW   = tmpTopMazeBoneGraphics
tmpMazeBoneGraphicsNE   = tmpMazeBoneGraphicsNW + 1
tmpKernelSection        = digitGraphicPtrs + 2
;--------------------------------------
tmpDesiredDirectionIndex = tmpKernelSection
tmpKernelMazeIdx        = digitGraphicPtrs + 3
;--------------------------------------
tmpCurrentCatCoordinateY = tmpKernelMazeIdx + 1
;--------------------------------------
tmpCatIndex             = tmpCurrentCatCoordinateY
;--------------------------------------
tmpCatCoordinateX       = tmpCatIndex
;--------------------------------------
tmpDesiredCoordinateY   = tmpCatCoordinateX
;--------------------------------------
tmpCatCoordinateValue   = tmpDesiredCoordinateY
;--------------------------------------
tmpCatPlayerHorizDistance = tmpCatCoordinateValue
;--------------------------------------
tmpBottomMazeBoneGraphics = tmpCatPlayerHorizDistance
;--------------------------------------
tmpMazeBoneGraphicsSW   = tmpBottomMazeBoneGraphics
tmpMazeBoneGraphicsSE   = tmpMazeBoneGraphicsSW + 1
;--------------------------------------
tmpCatReleaseTimerIdx   = tmpMazeBoneGraphicsSE
;--------------------------------------
tmpMazeAllowedDirection = tmpCatReleaseTimerIdx
;--------------------------------------
tmpCatDesiredDirectionIndex = digitGraphicPtrs + 6
;--------------------------------------
tmpAllowedDirection     = tmpCatDesiredDirectionIndex
;--------------------------------------
indicatorsLSBValue      = tmpAllowedDirection
;--------------------------------------
tmpCatPlayerABSVertDistance = indicatorsLSBValue
;--------------------------------------
tmpCatCoordinateY       = tmpCatPlayerABSVertDistance
tmpCurrentObjectType    = digitGraphicPtrs + 7
;--------------------------------------
tmpCatAllowedDirection  = tmpCurrentObjectType
;--------------------------------------
tmpDogCoordinateY       = tmpCatAllowedDirection
;--------------------------------------
tmpCurrentCatIdx        = tmpDogCoordinateY
;--------------------------------------
tmpBittenCatIndex       = tmpCurrentCatIdx
gameBoardStatus         ds 1
startRoundPauseTimer    ds 1
catReleaseTimer         ds 2
;--------------------------------------
verticalCatsReleaseTimer = catReleaseTimer
horizontalCatsReleaseTimer = verticalCatsReleaseTimer + 1
actionButtonDebounce    ds 1
playerScore             ds 2
currentMazeColor        ds 1
mouseCollisionTimer     ds 1
newRackStatus           ds 1
dogTimer                ds 1
catMovementDelay        ds 1
audioIndexValue         ds 1
audioDurationValue      ds 1
gameIdleTimer           ds 1
frameCount              ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
Start
;
; Set up everything so the power up state is known.
;
   cld                              ; clear decimal mode
   lda #0
.clearLoop
   sta VSYNC,x                      ; WARNING...value of x is unknown
   dex
   bne .clearLoop
   lda #MSBL_SIZE4 | PF_REFLECT
   sta CTRLPF
   ldx #5
.setInitMazeGraphicPointers
   lda InitMazeGraphicPointers,x
   sta mazeGraphicPointers,x
   dex
   bpl .setInitMazeGraphicPointers
   txs                              ; set stack to beginning
StartNewGame
   jsr InitializeGame
   ldx #<[RESBL - RESP0]
   lda #83
   jsr PositionObjectHorizontally   ; horizontally position BALL (maze center)
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; horizontally move all objects
VerticalBlank
   lda #STOP_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   sta VBLANK                       ; enable TIA (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   sta CXCLR                        ; clear all collisions
   sta HMCLR                        ; clear horizontal motion
   dec frameCount
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcc StartNewGame                 ; branch if RESET pressed
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip joystick values
   beq .checkToDisableDisplay       ; branch if neither joystick moved
   lda #0
   sta gameIdleTimer                ; reset game idle timer
.checkToDisableDisplay
   lda gameIdleTimer                ; get game idle timer value
   bmi VerticalBlank                ; perform vertical blanking if timer expired
   lda frameCount                   ; get current frame count
   bne .skipGameIdleTimerIncrement
   inc gameIdleTimer
.skipGameIdleTimerIncrement
   ldx gameOverState                ; get game over state
   beq SetPlayerSprite              ; branch if not GAME_OVER
   dec mouseCollisionTimer
   lda #BLANK_MOUSE_SPRITE_OFFSET
   sta mouseLSBPointers + 5
SetPlayerSprite
   ldy dogTimer                     ; get Dog timer value
   beq .doneSetPlayerSprite         ; branch if Dog time expired
   ldx #7
   dey
   beq .resetPlayerToMouse          ; branch it reset player to MOUSE_ID
.setPlayerToDogSprite
   lda mouseLSBPointers,x
   cmp #<[MOUSE_SPRITE_OFFSET + H_KERNEL_SECTION]
   bcs .setNextSectionToDog
   adc #<[DOG_SPRITE_OFFSET - MOUSE_SPRITE_OFFSET]
   sta mouseLSBPointers,x
.setNextSectionToDog
   dex
   bpl .setPlayerToDogSprite
   bmi .doneSetPlayerSprite         ; unconditional branch
   
.resetPlayerToMouse
   lda mouseLSBPointers,x
   cmp #<[MOUSE_SPRITE_OFFSET + H_KERNEL_SECTION + 3]
   bcc .setNextSectionToMouse
   sbc #<[DOG_SPRITE_OFFSET - MOUSE_SPRITE_OFFSET]
   sta mouseLSBPointers,x
.setNextSectionToMouse
   dex
   bpl .resetPlayerToMouse
.doneSetPlayerSprite
   jsr PlayGameAudioSounds
   lda animationTimer               ; get animation timer value
   and #1
   bne .animateTrapDoors
   tax                              ; x = 0
   jsr SetMazePlayfieldPointers
   ldy #4
   bne AlterMazePlayfieldGraphics   ; unconditional branch
   
.animateTrapDoors
   lda gameBoardStatus
   bmi .trapDoorOpen                ; branch if Trapdoor open
   ldx #2
   jsr SetMazePlayfieldPointers
   ldy #20
   bne AlterMazePlayfieldGraphics   ; unconditional branch
   
.trapDoorOpen
   ldx #4
   jsr SetMazePlayfieldPointers
   ldy #0
AlterMazePlayfieldGraphics
   lda #9
   sta tmpCoordinateX
.alterMazePlayfieldGraphics
   lda AlternateMazeValues,y
   bmi .setPlayfieldGraphicForAlternativeMaze
   tax
   iny
   lda mazeCheese,x
   and AlternateMazeValues,y
.alterPlayfieldGraphicsForAlternateMaze
   sta mazeCheese,x
   iny
   dec tmpCoordinateX
   bpl .alterMazePlayfieldGraphics
   bmi CheckForActionButtonPressed  ; unconditional branch
   
.setPlayfieldGraphicForAlternativeMaze
   and #MAZE_BUILD_RAM_IDX_MASK
   tax
   iny
   lda mazeCheese,x
   ora AlternateMazeValues,y
   bne .alterPlayfieldGraphicsForAlternateMaze;unconditional branch
   
CheckForActionButtonPressed
   ldx actionButtonDebounce         ; get action button debounce value
   lda INPT4                        ; read left player action button value
   bmi .checkToActivateDog          ; branch if action button not pressed
   cpx #46
   beq .doneCheckForActionButtonPressed
   inc actionButtonDebounce         ; increment action button debounce value
   cpx #15
   bne .doneCheckForActionButtonPressed
   lda gameBoardStatus              ; get game board status value
   eor #TRAPDOOR_MASK               ; flip Trapdoor value
   sta gameBoardStatus
   ldx #<[TrapdoorAudioValues - AudioValues]
   jsr SetGameAudioValues
   lda #46
   bne .setActionButtonDebounce     ; unconditional branch
   
.checkToActivateDog
   txa                              ; move action button debounce to accumulator
   beq .doneCheckForActionButtonPressed
   cpx #46
   beq .clearActionButtonDebounce
   lda remainingBones               ; get remaining Bones
   beq .clearActionButtonDebounce   ; branch if no Bones remaining
   lda dogTimer                     ; get Dog timer value
   bmi .clearActionButtonDebounce
   lda mouseCollisionTimer          ; get Mouse collision timer value
   bne .clearActionButtonDebounce   ; branch if in Mouse collision routine
   lda #INIT_DOG_TIMER_VALUE
   sta dogTimer
   ldx #<[DogAudioValues - AudioValues]
   jsr SetGameAudioValues
   dec remainingBones               ; decrement remaining Bones
.clearActionButtonDebounce
   lda #0
.setActionButtonDebounce
   sta actionButtonDebounce
.doneCheckForActionButtonPressed
   lda animationTimer               ; get animation timer value
   and #1
   bne AnimateGameSprites
   lda startRoundPauseTimer
   beq .checkToDecrementDogTimer
   dec startRoundPauseTimer
.checkToDecrementDogTimer
   lda dogTimer                     ; get Dog timer value
   beq AnimateGameSprites
   lda mouseCollisionTimer          ; get Mouse collision timer value
   bne AnimateGameSprites           ; branch if in Mouse collision routine
   dec dogTimer
AnimateGameSprites
   inc animationTimer               ; increment animation timer
   lda animationTimer               ; get animation timer value
   cmp #8
   bne .checkToAnimateSpritesStage_02
   lda #>AnimationSprites_01
   sta mouseGraphicPointer + 1
   bne CheckToAlternateMazeColorsForCollision;unconditional branch
   
.checkToAnimateSpritesStage_02
   cmp #10
   bne .checkToAnimateSpritesStage_03
   lda #>AnimationSprites_02
   sta mouseGraphicPointer + 1
   lda #>AnimationSprites_01
   sta catGraphicPointer + 1
   bne CheckToAlternateMazeColorsForCollision;unconditional branch
   
.checkToAnimateSpritesStage_03
   cmp #18
   bne .checkToAnimateSpritesStage_00
   lda #>AnimationSprites_03
   sta mouseGraphicPointer + 1
   lda #>AnimationSprites_00
   sta catGraphicPointer + 1
   bne CheckToAlternateMazeColorsForCollision;unconditional branch
   
.checkToAnimateSpritesStage_00
   cmp #20
   bne CheckToAlternateMazeColorsForCollision
   lda #0
   sta animationTimer               ; reset animation timer value
   lda #>AnimationSprites_00
   sta mouseGraphicPointer + 1
CheckToAlternateMazeColorsForCollision
   lda mouseCollisionTimer          ; get Mouse collision timer value
   beq CheckToMovePlayerObject      ; branch if not in Mouse collision routine
   lda dogTimer                     ; get Dog timer value
   bne .doneAlternateMazeColorsForCollision;branch if Dog active
   lda mouseCollisionTimer          ; get Mouse collision timer value
   and #7
   bne .doneAlternateMazeColorsForCollision
   lda currentMazeColor             ; get current maze color
   eor #MAZE_COLOR_XOR              ; alternate color for Mouse collision
   sta COLUPF
   sta currentMazeColor
.doneAlternateMazeColorsForCollision
   jmp .convertBCDToDigits
   
CheckToMovePlayerObject
   ldy playerMazeCoordinates        ; get player maze coordinate value
   lda playerAllowedDirection       ; get player allowed direction
   sta tmpAllowedDirection
   lda #0
   sta tmpObjectIntersectionState   ; clear object intersection state
   sta tmpCurrentObjectType         ; set to not processing ID_CAT
   jsr DetermineObjectMovement
   lda tmpAllowedDirection
   sta playerAllowedDirection
   sty playerMazeCoordinates
   lda tmpObjectIntersectionState   ; get object intersection state
   beq CheckToStartRound            ; branch if object in intersection
   bne .convertBCDToDigits          ; unconditional branch
   
CheckToStartRound
   lda startRoundPauseTimer
   cmp #90
   bcc .checkToReduceRemainingLives
.convertBCDToDigits
   jmp ConvertBCDToDigits
   
.checkToReduceRemainingLives
   cmp #89
   bne DeterminePlayerDirectionValues
   lda newRackStatus
   bmi DetermineNewRackCatReleaseTime;branch if RACK_CLEARED
   dec remainingLives
DetermineNewRackCatReleaseTime
   lda #0
   sta newRackStatus
   dec startRoundPauseTimer
   lda playerScore + 1              ; get score ones value
   eor #$FF                         ; flip the values
   and #$77
   tay
   lda playerScore                  ; get score hundreds value
   and #1
   tax
   tya
   sta catReleaseTimer,x
   asl
   tay
   txa
   eor #1
   tax
   tya
   sta catReleaseTimer,x
DeterminePlayerDirectionValues
   lda playerMazeCoordinates        ; get player maze coordinate value
   tax                              ; move player coordinates to x register
   and #7                           ; keep y-coordinate value
   sta tmpMouseCoordinateY
   txa                              ; get player maze coordinate value
   and #$F0                         ; keep x-coordinate value
   lsr                              ; divide value by 2
   ora tmpMouseCoordinateY          ; combine with y-coordinate
   tax
   lda MazeRules,x
   ldx gameBoardStatus
   bmi .openTrapdoorMazeRules       ; branch if Trapdoor open
   and #$F0                         ; keep closed Trapdoor maze rules
   bne .readLeftJoystickPort
.openTrapdoorMazeRules
   asl
   asl
   asl
   asl
.readLeftJoystickPort
   ora SWCHA                        ; combine with joystick values
   tax                              ; move allowed direction to x register
   and #P0_HORIZ_MOVE               ; isolate HORIZ_MOVE values
   eor #P0_HORIZ_MOVE
   bne .checkForPlayerMovingVertically;branch if player not moving horizontally
   txa                              ; move allowed direction to accumulator
   and #P0_VERT_MOVE
   eor #P0_VERT_MOVE
   beq .checkForPlayerMovingVertically
   txa                              ; move allowed direction to accumulator
   and #P0_NO_MOVE
   cmp #(MOVE_LEFT & P0_NO_MOVE)
   bne .joystickPushedRight         ; branch if not moving left
   lda #DIR_ADJUSTMENT_NEGATIVE
   bne .joystickMovedHorizontally   ; unconditional branch
   
.joystickPushedRight
   lda #DIR_ADJUSTMENT_POSITIVE
   beq .joystickMovedHorizontally   ; unconditional branch
   
.checkForPlayerMovingVertically
   txa                              ; move allowed direction to accumulator
   and #P0_NO_MOVE
   cmp #(MOVE_UP & P0_NO_MOVE)
   bne .checkForPlayerMovingDown    ; branch if not moving up
   lda playerMazeCoordinates        ; get player maze coordinate value
   and #$0F                         ; keep y-coordinate value
   tax
   inc mouseLSBPointers,x
   dex
   lda #MOUSE_SPRITE_OFFSET - H_KERNEL_SECTION + 1
   ldy #VERT_DIR_CHANGE | DIR_ADJUSTMENT_NEGATIVE | (H_KERNEL_SECTION - 1)
   bne .setPlayerVerticalDirectionValues;unconditional branch
   
.checkForPlayerMovingDown
   cmp #(MOVE_DOWN & P0_NO_MOVE)
   bne ConvertBCDToDigits           ; branch if player not moving down
   lda playerMazeCoordinates        ; get player maze coordinate value
   and #$0F                         ; keep y-coordinate value
   tax
   dec mouseLSBPointers,x           ; decrement LSB value to move player down
   inx
   lda #MOUSE_SPRITE_OFFSET + H_KERNEL_SECTION - 1
   ldy #VERT_DIR_CHANGE | DIR_ADJUSTMENT_POSITIVE | (H_KERNEL_SECTION - 1)
.setPlayerVerticalDirectionValues
   sta mouseLSBPointers,x
   sty playerAllowedDirection
   bne ConvertBCDToDigits           ; unconditional branch
   
.joystickMovedHorizontally
   sta playerAllowedDirection
   lda playerHorizPos               ; get player horizontal position
   cmp #INIT_PLAYER_HORIZ_POS
   bne .determinePlayerHorizontalSteps;branch if not in starting point
   lda playerAllowedDirection       ; get player allowed direction
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .setPlayerHorizontalDirectionValues;branch if DIR_ADJUSTMENT_NEGATIVE
   lda #4 << 4 | 5
   sta playerMazeCoordinates
.setPlayerHorizontalDirectionValues
   lda #7
   ora playerAllowedDirection
   sta playerAllowedDirection
   bne ConvertBCDToDigits           ; unconditional branch
   
.determinePlayerHorizontalSteps
   lda playerAllowedDirection       ; get player allowed direction
   ldx playerHorizPos               ; get player horizontal position
   jsr DetermineObjectHorizontalSteps
   sta playerAllowedDirection
ConvertBCDToDigits SUBROUTINE
   ldx #1
   ldy #4
.convertBCDToDigits
   lda playerScore,x                ; get player score
   and #$0F                         ; keep lower nybbles
   asl                              ; multiply value by 2
   sta tmpMulti2
   asl                              ; multiply value by 8
   asl
   adc tmpMulti2                    ; multiply value by 10 (i.e. 2x + 8x)
   sta digitGraphicPtrs + 2,y       ; set digit LSB value
   lda playerScore,x                ; get player score
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpMulti8
   lsr                              ; divide value by 8 (i.e. multiply by 2)
   lsr
   adc tmpMulti8                    ; multiply by 10 (i.e. 2x + 8x)
   sta digitGraphicPtrs,y           ; set digit LSB value
   ldy #0
   dex
   bpl .convertBCDToDigits
   lda #>AnimationSprites_02
   inx                              ; x = 0
.suppressZeros
   ldy digitGraphicPtrs,x           ; get digit LSB value
   beq .setDigitPointerMSBValue
   lda #>NumberFonts
.setDigitPointerMSBValue
   sta digitGraphicPtrs + 1,x
   inx
   inx
   cpx #6
   bne .suppressZeros
   lda #>NumberFonts
   sta digitGraphicPtrs + 7
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   tax                        ; 2         x = 0
   ldy #9                     ; 2
   lda #SCORE_COLOR           ; 2
   sta tmpScoreColor          ; 3
   jsr SetupToDisplayScore    ; 6
;--------------------------------------
   lda SWCHB                  ; 4 = @72   read console switches
   and #BW_MASK               ; 2         keep B/W value
   bne .drawRemainingBones    ; 2³        branch if set to COLOR
;--------------------------------------
   lda mouseCollisionTimer    ; 3         get Mouse collision timer value
   bne .drawRemainingBones    ; 2³        branch if in Mouse collision routine
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3         hide playfield graphics
.drawRemainingBones
   jsr Skip2Scanlines         ; 6
;--------------------------------------
   ldy remainingBones         ; 3         get remaining Bones
   lda #<BonesIndicator       ; 2
   jsr SetIndicatorGraphics   ; 6
   ldy #5                     ; 2
   lda #RESERVE_BONE_COLOR    ; 2
   jsr SetColorForSixDigitKernel;6
   jsr Skip2Scanlines         ; 6
;--------------------------------------
   ldy remainingLives         ; 3
   lda #<LivesIndicator       ; 2
   jsr SetIndicatorGraphics   ; 6
   ldy #11                    ; 2
   lda #RESERVE_LIVES_COLOR   ; 2
   jsr SetColorForSixDigitKernel;6
   sta WSYNC
;--------------------------------------
   lda dogTimer               ; 3         get Dog timer value
   cmp #41                    ; 2
   bcs .colorDogSprite        ; 2³
   and #8                     ; 2
   bne .colorDogSprite        ; 2³
   lda #COLOR_MOUSE           ; 2
   sta COLUP0                 ; 3 = @16
   bne .colorCatSprites       ; 3         unconditional branch
   
.colorDogSprite
   lda #COLOR_DOG             ; 2
   sta COLUP0                 ; 3 = @13
.colorCatSprites
   lda #COLOR_CAT             ; 2
   sta COLUP1                 ; 3 = @24
   lda #0                     ; 2
   sta tmpKernelSection       ; 3
   sta tmpKernelMazeIdx       ; 3
   tax                        ; 2
   sta NUSIZ0                 ; 3 = @37
   sta WSYNC
;--------------------------------------
   sta NUSIZ1                 ; 3 = @03
   lda playerHorizPos         ; 3         get player horizontal position
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$50                   ; 2
   sta tmpMazeBoneGraphicsNW  ; 3
   sta tmpMazeBoneGraphicsNE  ; 3
   sta tmpMazeBoneGraphicsSW  ; 3
   sta tmpMazeBoneGraphicsSE  ; 3
   lda leftPF1MazeCheese + 1  ; 3         get NW cheese value
   and #1 << 5                ; 2
   bne .checkToEnableMazeBoneNE;2³
   sta tmpMazeBoneGraphicsNW  ; 3         remove NW Bone
.checkToEnableMazeBoneNE
   lda rightPF2MazeCheese + 1 ; 3         get NE cheese value
   and #1 << 1                ; 2
   bne .checkToEnableMazeBoneSW;2³
   sta tmpMazeBoneGraphicsNE  ; 3         remove NE Bone
.checkToEnableMazeBoneSW
   lda leftPF1MazeCheese + 5  ; 3         get SW cheese value
   and #1 << 5                ; 2
   bne .checkToEnableMazeBoneSE;2³
   sta tmpMazeBoneGraphicsSW  ; 3         remove SW Bone
.checkToEnableMazeBoneSE
   lda rightPF2MazeCheese + 5 ; 3         get SE cheese value
   and #1 << 1                ; 2
   bne .doneCheckToEnableMazeBones;2³
   sta tmpMazeBoneGraphicsSE  ; 3         remove SE Bone
.doneCheckToEnableMazeBones
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   jmp DrawMazeKernel         ; 3
   
CheckToLaunchCatFromHome
   and catReleaseTimer,x
   stx tmpCatReleaseTimerIdx        ; save index for later...x gets trashed
   beq LaunchCatFromHome
   rts

SetIndicatorGraphics
   sta indicatorsLSBValue     ; 3
   ldx #8                     ; 2
.setIndicatorGraphics
   lda #<AnimationSprites_02  ; 2
   dey                        ; 2
   bmi .setIndicatorLSBValue  ; 2³
   lda indicatorsLSBValue     ; 3
.setIndicatorLSBValue
   sta digitGraphicPtrs - 2,x ; 4
   lda #>AnimationSprites_02  ; 2
   sta digitGraphicPtrs - 1,x ; 4
   dex                        ; 2
   dex                        ; 2
   bne .setIndicatorGraphics  ; 2³
   rts                        ; 6

LaunchCatFromHome
   ldx #3
.launchCatFromHome
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   cmp AdvancedCatHomeCoordiateValues,y
   beq .checkToLaunchCat            ; branch if Cat in Home location
   cmp InitCatHomeCoordiateValues,y
   beq .checkToLaunchCat            ; branch if Cat in Home location
   dex
   bpl .launchCatFromHome
   bmi .doneLaunchCatFromHome
   
.checkToLaunchCat
   lda catAllowedDirections,x
   sta tmpCatAllowedDirection
   lda #STOPPED_AT_INTERSECTION
   sta catAllowedDirections,x
   tya                              ; move Cat index to accumulator
   pha                              ; push Cat index value to stack
   sta tmpVertCatIndex
   jsr DetermineCatAllowedInZone
   pla                              ; pull Cat index value from stack
   tay                              ; restore Cat index
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   bpl .launchCat                   ; branch if safe to launch Cat
   lda tmpCatAllowedDirection
   sta catAllowedDirections,x
   bne .doneLaunchCatFromHome       ; unconditional branch
   
.launchCat
   lda LaunchedCatCoordinates,y
   sta catMazeCoordinates,x
   ldx InitCatKernelZoneValues,y
   lda #XMIN
   sta catHorizPositionValues,x
   lda #BLANK_CAT_SPRITE_OFFSET
   sta catLSBPointers,x
   ldx LaunchedCatKernelZoneValues,y
   lda InitCatGraphicPointerLSBValues,y
   sta catLSBPointers,x
   lda LaunchedCatHorizontalPositionValues,y
   sta catHorizPositionValues,x
   tya                              ; move Cat index to accumulator
   clc
   ror                              ; rotate D0 to carry
   tax
   lda #15
   bcc .resetCatReleaseTimer        ; branch if even Cat index
   lda #15 << 4
.resetCatReleaseTimer
   ora catReleaseTimer,x
   sta catReleaseTimer,x
.doneLaunchCatFromHome
   ldx tmpCatReleaseTimerIdx        ; restore Cat release timer index value
   rts

PositionObjectHorizontally
   sta WSYNC
;--------------------------------------
   sec                        ; 2
.coarsePositionObject
   sbc #15                    ; 2         divide position by 15
   bcs .coarsePositionObject  ; 2³
   eor #15                    ; 2         4-bit 1's complement for fine motion
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   adc #(8 + 1) << 4          ; 2         increment 2's complement by 8
   sta RESP0,x                ; 4         set coarse position value
   sta WSYNC
;--------------------------------------
   sta HMP0,x                 ; 4
   rts                        ; 6

Skip4Scanlines
   sta WSYNC
   sta WSYNC
Skip2Scanlines
   sta WSYNC
   sta WSYNC
   rts

DrawMazeKernel
   ldy #H_KERNEL_SECTION - 4  ; 2
.drawMazeKernel
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   ldy tmpKernelMazeIdx       ; 3
   sta HMCLR                  ; 3
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   lda (pf0GraphicPointer),y  ; 5
   sta PF0                    ; 3 = @14
   lda (pf1GraphicPointer),y  ; 5
   sta PF1                    ; 3 = @22
   lda (pf2GraphicPointer),y  ; 5
   sta PF2                    ; 3 = @30
   ldx tmpKernelSection       ; 3
   lda MazePF1Graphics + 2,x  ; 4
   sta ENABL                  ; 3 = @40
   ldy #H_KERNEL_SECTION - 3  ; 2
   lda catHorizPositionValues,x;4
   bne .horizontallyPositionCat;2³
.bottomKernelSection
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   iny                        ; 2
   cpy #H_KERNEL_SECTION      ; 2
   bne .bottomKernelSection   ; 2³
   beq .newKernelSection      ; 3 + 1     unconditional branch
   
.horizontallyPositionCat
   sta tmpCatHorizPos         ; 3
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   iny                        ; 2
   lda (mouseGraphicPointer),y; 5
   tay                        ; 2
   lda tmpCatHorizPos         ; 3
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
.coarsePositionCat
   sbc #15                    ; 2         divide position by 15
   bcs .coarsePositionCat     ; 2³
   eor #15                    ; 2         4-bit 1's complement for fine motion
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   adc #(8 + 1) << 4          ; 2         increment 2's complement by 8
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMP1                   ; 3 = @03
   sty GRP0                   ; 3 = @06
   ldy #H_KERNEL_SECTION - 1  ; 2
   lda (mouseGraphicPointer),y; 5
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
.newKernelSection
   ldx tmpKernelSection       ; 3
   lda mouseLSBPointers,x     ; 4
   sta mouseGraphicPointer    ; 3
   lda catLSBPointers,x       ; 4
   sta catGraphicPointer      ; 3
   ldy #0                     ; 2
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   inc tmpKernelMazeIdx       ; 5
   ldy tmpKernelMazeIdx       ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP1                   ; 3 = @06
   stx GRP0                   ; 3 = @09
   lda (pf0GraphicPointer),y  ; 5
   sta PF0                    ; 3 = @17
   lda (pf1GraphicPointer),y  ; 5
   sta PF1                    ; 3 = @25
   lda (pf2GraphicPointer),y  ; 5
   sta PF2                    ; 3 = @33
   ldy #H_KERNEL_SECTION - 17 ; 2
.topKernelSection
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   stx GRP0                   ; 3 = @06
   iny                        ; 2
   cpy #H_KERNEL_SECTION - 14 ; 2
   bne .topKernelSection      ; 2³
.drawTopBoneSectionLoop
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   stx GRP0                   ; 3 = @06
   ldx tmpKernelSection       ; 3
   cpx #1                     ; 2
   beq .drawTopKernelSectionBone;2³
   cpx #5                     ; 2
   bne .doneTopDrawBoneSection; 2³
.drawTopKernelSectionBone
   lda tmpMazeBoneGraphicsNW - 1,x;4
   sta PF1                    ; 3 = @24
   SLEEP_12                   ; 12
   lda tmpMazeBoneGraphicsNE - 1,x;4
   sta PF1                    ; 3 = @43
.doneTopDrawBoneSection
   iny                        ; 2
   cpy #H_KERNEL_SECTION - 12 ; 2
   bne .drawTopBoneSectionLoop; 2³
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
.drawCheeseKernel
   stx GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   lda #MSBL_SIZE4 | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @11
   ldx tmpKernelSection       ; 3
   lda leftPF0MazeCheese,x    ; 4
   sta PF0                    ; 3 = @21
   lda leftPF1MazeCheese,x    ; 4
   sta PF1                    ; 3 = @28
   lda leftPF2MazeCheese,x    ; 4
   sta PF2                    ; 3 = @35
   lda rightPF0MazeCheese,x   ; 4
   sta PF0                    ; 3 = @42
   lda rightPF1MazeCheese,x   ; 4
   sta PF1                    ; 3 = @49
   lda rightPF2MazeCheese,x   ; 4
   sta PF2                    ; 3 = @56
   iny                        ; 2
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   cpy #H_KERNEL_SECTION - 10 ; 2
   bne .drawCheeseKernel      ; 2³
;--------------------------------------
   ldy tmpKernelMazeIdx       ; 3 = @01
   stx GRP0                   ; 3 = @04
   sta GRP1                   ; 3 = @07
   lda #MSBL_SIZE4 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @12
   lda (pf0GraphicPointer),y  ; 5
   sta PF0                    ; 3 = @20
   lda (pf1GraphicPointer),y  ; 5
   sta PF1                    ; 3 = @28
   lda (pf2GraphicPointer),y  ; 5
   sta PF2                    ; 3 = @36
   ldy #H_KERNEL_SECTION - 9  ; 2
.drawBottomBoneSectionLoop
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   stx GRP0                   ; 3 = @06
   ldx tmpKernelSection       ; 3
   cpx #1                     ; 2
   beq .drawBottomKernelSectionBone;2³
   cpx #5                     ; 2
   bne .doneBottomDrawBoneSection;2³
.drawBottomKernelSectionBone
   lda tmpMazeBoneGraphicsNW - 1,x;4
   sta PF1                    ; 3 = @24
   SLEEP_12                   ; 12
   lda tmpMazeBoneGraphicsNE - 1,x;4
   sta PF1                    ; 3 = @43
.doneBottomDrawBoneSection
   iny                        ; 2
   cpy #H_KERNEL_SECTION - 7  ; 2
   bne .drawBottomBoneSectionLoop;2³
.drawBottomKernelSection
   lda (mouseGraphicPointer),y; 5
   tax                        ; 2
   lda (catGraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   stx GRP0                   ; 3 = @06
   sty tmpHeightKernelSection ; 3
   ldy tmpKernelMazeIdx       ; 3
   lda (pf1GraphicPointer),y  ; 5
   sta PF1                    ; 3 = @20
   ldy tmpHeightKernelSection ; 3
   iny                        ; 2
   cpy #H_KERNEL_SECTION - 4  ; 2
   bne .drawBottomKernelSection;2³ + 1
   inc tmpKernelMazeIdx       ; 5
   ldx tmpKernelSection       ; 3
   inx                        ; 2
   stx tmpKernelSection       ; 3
   cpx #8                     ; 2
   beq .mazeKernelDone        ; 2³
   jmp .drawMazeKernel        ; 3
   
.mazeKernelDone
   ldy #16                    ; 2
   lda (pf0GraphicPointer),y  ; 5
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   lda (pf1GraphicPointer),y  ; 5
   sta PF1                    ; 3 = @11
   lda (pf2GraphicPointer),y  ; 5
   sta PF2                    ; 3 = @19
   jsr Skip4Scanlines         ; 6
;--------------------------------------
   lda #0
   sta PF0
   sta PF1
   sta PF2
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   lda mouseCollisionTimer          ; get Mouse collision timer value
   bne CheckPlayerCollisions        ; branch if in Mouse collision routine
   lda animationTimer               ; get animation timer value
   bne DetermineToLaunchCatFromHome
   ldx #1
.decrementCatReleaseTime
   lda catReleaseTimer,x            ; get Cat release timer value
   and #$0F                         ; keep even Cat index release timer
   beq .checkToDecrementOddCatReleaseTime;branch if release time expired
   cmp #15
   beq .checkToDecrementOddCatReleaseTime;branch if not reducing release time
   dec catReleaseTimer,x            ; decrement even Cat index release time
.checkToDecrementOddCatReleaseTime
   lda catReleaseTimer,x            ; get Cat release timer value
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   beq .decrementNextCatReleaseTime ; branch if release time expired
   cmp #15
   beq .decrementNextCatReleaseTime ; branch if not reducing release time
   lda catReleaseTimer,x            ; get Cat release timer value
   sec
   sbc #1 << 4                      ; decrement odd Cat index release time
   sta catReleaseTimer,x
.decrementNextCatReleaseTime
   dex
   bpl .decrementCatReleaseTime
DetermineToLaunchCatFromHome
   ldx #1
   ldy #3
.determineToLaunchCatFromHome
   lda #$F0
   jsr CheckToLaunchCatFromHome
   dey                              ; decrement Cat index
   lda #$0F
   jsr CheckToLaunchCatFromHome
   dey                              ; decrement Cat index
   dex
   bpl .determineToLaunchCatFromHome
   lda catMovementDelay
   and animationTimer
   beq CheckToChangeCatDirection
   ldx #4
.checkToMoveCat
   dex
   bmi CheckToChangeCatDirection
   lda catAllowedDirections,x
   sta tmpAllowedDirection
   ldy catMazeCoordinates,x         ; get Cat maze coordinate value
   lda #0
   sta tmpObjectIntersectionState   ; clear object intersection state
   lda #1
   sta tmpCurrentObjectType         ; set to processing Cat
   stx tmpCatIndex
   jsr DetermineObjectMovement
   ldx tmpCatIndex                  ; restore Cat index value
   lda tmpAllowedDirection
   sta catAllowedDirections,x
   sty catMazeCoordinates,x
   jmp .checkToMoveCat
   
CheckToChangeCatDirection
   lda animationTimer               ; get animation timer value
   and #3
   tax
   stx tmpCurrentCatIdx
   lda catAllowedDirections,x
   bpl CheckPlayerCollisions        ; branch if CURRENTLY_MOVING
   jsr DetermineToChangeCatDirection
   jsr DetermineCatFacingDirection
   ldx tmpCurrentCatIdx
   sta catAllowedDirections,x
CheckPlayerCollisions
   lda mouseCollisionTimer          ; get Mouse collision timer value
   bne .incrementCollisionTimer     ; branch if in Mouse collision routine
   lda CXPPMM                       ; check player collision values
   bpl NewFrame                     ; branch if no player collision
   ldx #<[PlayerCollisionAudioValues - AudioValues]
   jsr SetGameAudioValues
.incrementCollisionTimer
   inc mouseCollisionTimer
   lda mouseCollisionTimer
   cmp #48
   bne NewFrame
   lda #COLOR_MAZE
   sta COLUPF
   sta currentMazeColor
   lda #0
   sta mouseCollisionTimer
   lda dogTimer                     ; get Dog timer value
   beq .resetRackPlayerPositionValues;branch if Dog timer expired
   lda playerMazeCoordinates        ; get player maze coordinate value
   and #7                           ; keep y-coordinate value
   sta tmpCatZoneConflictState      ; clear D7 value
   sta tmpDogCoordinateY
   tay                              ; move Dog y-coordinate to y register
   lda playerAllowedDirection       ; get player allowed direction
   bmi .checkCatDogCollisionInCurrectSection;branch if STOPPED_AT_INTERSECTION
   jsr DetermineDesiredCoordinateY
   jsr SetDesiredUpdatedCoordinates
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   bmi .scoreForBitingCat           ; branch if Dog in Cat zone
.checkCatDogCollisionInCurrectSection
   ldy tmpDogCoordinateY
   jsr SetDesiredUpdatedCoordinates
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   bmi .scoreForBitingCat           ; branch if Dog in Cat zone
   bpl NewFrame                     ; unconditional branch
   
.scoreForBitingCat
   tya                              ; move bitten Cat index to accumulator
   tax                              ; move bitten Cat index to x register
   jsr RemoveBittenCat
   stx tmpBittenCatIndex
   lda #POINTS_BITE_CAT
   jsr IncrementScore
   ldx #<-1
.resetBittenCatHome
   inx
   cpx #4
   beq .newFrame
   ldy InitCatKernelZoneValues,x
   stx tmpCatZoneConflictState      ; clear D7 value
   jsr SetDesiredUpdatedCoordinates
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   bmi .resetBittenCatHome          ; branch if in same Cat zone
   txa                              ; move index to accumulator
   tay
   ldx tmpBittenCatIndex
   jsr ResetCatHomePosition
.newFrame
   jmp NewFrame
   
.resetRackPlayerPositionValues
   lda remainingLives
   bne .resetPlayerPositionValues   ; branch if lives remaining
   lda gameOverState                ; get game over state
   bne .resetPlayerPositionValues   ; branch if GAME_OVER set
   inc gameOverState                ; set to GAME_OVER (i.e. non-zero value)
.resetPlayerPositionValues
   jsr ResetPlayerPositionValues
NewFrame SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   lda #START_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta VBLANK                       ; disable TIA (D1 = 1)
   lda #VSYNC_TIME
   sta TIM8T
   ldx #1
.checkBonesAndLivesValueOutOfRange
   lda remainingBones,x
   bmi .valueOutOfRange             ; branch if value negative
   cmp #5                           ; max lives and max bones
   bcc .checkNextValueOutOfRange
   dec remainingBones,x
   dec remainingBones,x
.valueOutOfRange
   inc remainingBones,x
.checkNextValueOutOfRange
   dex
   bpl .checkBonesAndLivesValueOutOfRange
.vsyncWaitTime
   lda INTIM
   bne .vsyncWaitTime
   jmp VerticalBlank
   
TrapdoorClosedPF1MazeGraphics
   .byte $FF ; |XXXXXXXX|
   .byte $08 ; |....X...|
   .byte $88 ; |X...X...|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $80 ; |X.......|
   .byte $8F ; |X...XXXX|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $80 ; |X.......|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $08 ; |....X...|
   .byte $8F ; |X...XXXX|
   .byte $80 ; |X.......|
   .byte $FF ; |XXXXXXXX|
   
AlternateMazeValues
   .byte <leftPF1MazeCheese  - mazeCheese + 4 | MAZE_BUILD_ADD_BIT
   .byte 1 << 3
   .byte <rightPF1MazeCheese - mazeCheese + 4 | MAZE_BUILD_ADD_BIT
   .byte 1 << 0
;
; last 16 bytes shared with table below
;
   .byte <leftPF1MazeCheese  - mazeCheese + 2 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 7)
   .byte <leftPF2MazeCheese  - mazeCheese + 2 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 4)
   .byte <leftPF2MazeCheese  - mazeCheese + 4 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 4)
   .byte <leftPF2MazeCheese  - mazeCheese + 6 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 0)
   .byte <rightPF0MazeCheese - mazeCheese + 2 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 7)
   .byte <rightPF0MazeCheese - mazeCheese + 4 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 7)
   .byte <rightPF1MazeCheese - mazeCheese + 6 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 4)
   .byte <rightPF2MazeCheese - mazeCheese + 2 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 3)
;
; last 4 bytes shared with table below
;
   .byte <leftPF1MazeCheese  - mazeCheese + 4 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 3)
   .byte <rightPF1MazeCheese - mazeCheese + 4 | MAZE_BUILD_REMOVE_BIT
   .byte <~(1 << 0)
   .byte <leftPF1MazeCheese  - mazeCheese + 2 | MAZE_BUILD_ADD_BIT
   .byte 1 << 7
   .byte <leftPF2MazeCheese  - mazeCheese + 2 | MAZE_BUILD_ADD_BIT
   .byte 1 << 4
   .byte <leftPF2MazeCheese  - mazeCheese + 4 | MAZE_BUILD_ADD_BIT
   .byte 1 << 4
   .byte <leftPF2MazeCheese  - mazeCheese + 6 | MAZE_BUILD_ADD_BIT
   .byte 1 << 0
   .byte <rightPF0MazeCheese - mazeCheese + 2 | MAZE_BUILD_ADD_BIT
   .byte 1 << 7
   .byte <rightPF0MazeCheese - mazeCheese + 4 | MAZE_BUILD_ADD_BIT
   .byte 1 << 7
   .byte <rightPF1MazeCheese - mazeCheese + 6 | MAZE_BUILD_ADD_BIT
   .byte 1 << 4
   .byte <rightPF2MazeCheese - mazeCheese + 2 | MAZE_BUILD_ADD_BIT
   .byte 1 << 3

AudioValues
StartingThemeAudioValues
   .byte 4                          ; high pitch square wave pure tone
   .byte  5 << 4 | 10,  5 << 4 |  1,  5 << 4 |  4,  5 << 4 |  3,  4 << 4 | 15
   .byte 11 << 4 |  8,  5 << 4 |  7,  4 << 4 | 15, 11 << 4 |  2, 11 << 4 |  1
   .byte 11 << 4 |  6, 11 << 4 |  4, 11 << 4 |  0, 10 << 4 | 15, 11 << 4 |  3
   .byte 11 << 4 |  2, 10 << 4 | 14, 10 << 4 | 13, 11 << 4 |  1, END_AUDIO_TUNE
TrapdoorAudioValues
   .byte 12                         ; lower pitch square wave sound
   .byte  0 << 4 |  9,  0 << 4 |  5,  0 << 4 |  8,  0 << 4 |  4,  0 << 4 |  7
   .byte  0 << 4 |  3,  0 << 4 |  6,  0 << 4 |  2,  0 << 4 |  5, END_AUDIO_TUNE
EatingCheeseAudioValues
   .byte 4                          ; high pitch square wave pure tone
   .byte  3 << 4 | 10,  3 << 4 |  3,  2 << 4 | 15, END_AUDIO_TUNE
EatingBoneAudioValues
   .byte 15                         ; buzz sound
   .byte  0 << 4 | 11,  0 << 4 | 10,  0 << 4 |  9,  0 << 4 |  7,  0 << 4 |  5
   .byte  0 << 4 |  4,  0 << 4 |  3,  0 << 4 |  4,  0 << 4 |  5,  0 << 4 |  6
   .byte END_AUDIO_TUNE
PlayerCollisionAudioValues
   .byte 1                          ; saw waveform
   .byte  2 << 4 |  9,  0 << 4 |  8,  0 << 4 |  7,  0 << 4 |  6,  0 << 4 |  5
   .byte  0 << 4 |  4,  0 << 4 |  3,  6 << 4 |  2,  4 << 4 |  3,  0 << 4 |  4
   .byte  0 << 4 |  5,  0 << 4 |  6,  0 << 4 |  7, END_AUDIO_TUNE
DogAudioValues
   .byte 6                          ; bass sound
   .byte  0 << 4 | 12,  0 << 4 | 11,  0 << 4 | 10,  0 << 4 |  9,  0 << 4 |  8
   .byte  0 << 4 |  7,  0 << 4 |  6,  0 << 4 |  5,  0 << 4 |  5,  0 << 4 |  4
   .byte  0 << 4 |  5,  0 << 4 |  6,  0 << 4 |  7,  0 << 4 |  8,  0 << 4 |  9
   .byte  0 << 4 |  6,  0 << 4 |  5,  0 << 4 |  4,  2 << 4 |  3,  0 << 4 |  4
   .byte END_AUDIO_TUNE

DetermineMazeCoordinateValueY
   tya                              ; move maze coordinates to accumulator
   and #7                           ; keep y-coordinate value
   tax                              ; move y-coordinate to x register
   lda tmpCurrentObjectType
   rts

InitCatGraphicPointerLSBValues
   .byte CAT_FACING_RIGHT_SPRITE_OFFSET, CAT_FACING_LEFT_SPRITE_OFFSET
   .byte CAT_FACING_LEFT_SPRITE_OFFSET, CAT_FACING_RIGHT_SPRITE_OFFSET
   
   IF COMPILE_REGION = NTSC
   
   .byte $A0,$82,$A0,$B7            ; unused bytes
   
   ELSE
   
   .byte $B0,$B2,$E6,$A0
   
   ENDIF

   BOUNDARY 0
   
AnimationSprites_00

   FILL_BOUNDARY MOUSE_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY DOG_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $EE ; |XXX.XXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $92 ; |X..X..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_DOWN_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $54 ; |.X.X.X..|
   .byte $72 ; |.XXX..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $72 ; |.XXX..X.|
   .byte $22 ; |..X...X.|
   .byte $74 ; |.XXX.X..|
   .byte $78 ; |.XXXX...|
   .byte $90 ; |X..X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_UP_SPRITE_OFFSET, 0
   
   .byte $2A ; |..X.X.X.|
   .byte $4E ; |.X..XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $4E ; |.X..XXX.|
   .byte $44 ; |.X...X..|
   .byte $2E ; |..X.XXX.|
   .byte $1E ; |...XXXX.|
   .byte $09 ; |....X..X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_LEFT_SPRITE_OFFSET, 0

   .byte $00 ; |........|
   .byte $52 ; |.X.X..X.|
   .byte $71 ; |.XXX...X|
   .byte $A9 ; |X.X.X..X|
   .byte $D9 ; |XX.XX..X|
   .byte $F9 ; |XXXXX..X|
   .byte $AA ; |X.X.X.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $71 ; |.XXX...X|
   .byte $21 ; |..X....X|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY CAT_FACING_RIGHT_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $8A ; |X...X.X.|
   .byte $4E ; |.X..XXX.|
   .byte $55 ; |.X.X.X.X|
   .byte $5B ; |.X.XX.XX|
   .byte $5F ; |.X.XXXXX|
   .byte $91 ; |X..X...X|
   .byte $9F ; |X..XXXXX|
   .byte $8E ; |X...XXX.|
   .byte $84 ; |X....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $55 ; |.X.X.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
MazePF0Graphics
   .byte $F0 ; |XXXX....|
   .byte $10 ; |...X....|
   .byte $F0 ; |XXXX....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $F0 ; |XXXX....|
   
MazePF1Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $08 ; |....X...|
   .byte $88 ; |X...X...|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $8F ; |X...XXXX|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $80 ; |X.......|
   .byte $87 ; |X....XXX|
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $08 ; |....X...|
   .byte $8F ; |X...XXXX|
   .byte $80 ; |X.......|
   .byte $FF ; |XXXXXXXX|
   
MazePF2Graphics
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   
AdvancedCatHomeCoordiateValues
   .byte INIT_BOTTOM_CAT_HOME_COORDINATES + (1 << 4);incremented x-coordinate
   .byte INIT_TOP_CAT_HOME_COORDINATES - (1 << 4);decremented x-coordinate
   .byte INIT_RIGHT_CAT_HOME_COORDINATES - 1;decremented y-coordinate
   .byte INIT_LEFT_CAT_HOME_COORDINATES + 1;incremented y-coordinate

InitCatHomeCoordiateValues
   .byte INIT_BOTTOM_CAT_HOME_COORDINATES
   .byte INIT_TOP_CAT_HOME_COORDINATES
   .byte INIT_RIGHT_CAT_HOME_COORDINATES
   .byte INIT_LEFT_CAT_HOME_COORDINATES

   BOUNDARY 0
   
AnimationSprites_01
   
   FILL_BOUNDARY MOUSE_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $EC ; |XXX.XX..|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY DOG_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_DOWN_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $51 ; |.X.X...X|
   .byte $72 ; |.XXX..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $72 ; |.XXX..X.|
   .byte $22 ; |..X...X.|
   .byte $74 ; |.XXX.X..|
   .byte $78 ; |.XXXX...|
   .byte $48 ; |.X..X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_UP_SPRITE_OFFSET, 0

   .byte $8A ; |X...X.X.|
   .byte $4E ; |.X..XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $4E ; |.X..XXX.|
   .byte $44 ; |.X...X..|
   .byte $2E ; |..X.XXX.|
   .byte $1E ; |...XXXX.|
   .byte $12 ; |...X..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY CAT_FACING_LEFT_SPRITE_OFFSET, 0

   .byte $00 ; |........|
   .byte $51 ; |.X.X...X|
   .byte $72 ; |.XXX..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $89 ; |X...X..X|
   .byte $F9 ; |XXXXX..X|
   .byte $71 ; |.XXX...X|
   .byte $21 ; |..X....X|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $55 ; |.X.X.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY CAT_FACING_RIGHT_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $4A ; |.X..X.X.|
   .byte $8E ; |X...XXX.|
   .byte $95 ; |X..X.X.X|
   .byte $9B ; |X..XX.XX|
   .byte $9F ; |X..XXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $5B ; |.X.XX.XX|
   .byte $8E ; |X...XXX.|
   .byte $84 ; |X....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
RemoveBittenCat
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   and #7                           ; keep y-coordinate value
   tay
   jsr RemoveCat
   lda catAllowedDirections,x
   bmi .setCatCoordinatesOutOfRange ; branch if STOPPED_AT_INTERSECTION
   jsr DetermineDesiredCoordinateY
   jsr RemoveCat
.setCatCoordinatesOutOfRange
   lda #STOPPED_AT_INTERSECTION
   sta catAllowedDirections,x
   lda #0 << 4 | 14
   sta catMazeCoordinates,x
   rts

RemoveCat
   lda #XMIN
   sta catHorizPositionValues,y
   lda #BLANK_CAT_SPRITE_OFFSET
   sta catLSBPointers,y
   rts

DetermineDesiredCoordinateY
   cmp #VERT_DIR_CHANGE
   bcc .doneDetermineDesiredCoordinateY;branch if moving horizontally
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   beq .incrementDesiredYCoordinate ; branch if DIR_ADJUSTMENT_POSITIVE
   dey
   bpl .doneDetermineDesiredCoordinateY;unconditional branch
   
.incrementDesiredYCoordinate
   iny
.doneDetermineDesiredCoordinateY
   rts

LaunchedCatHorizontalPositionValues
   .byte 73, 87, 134, 26

InitCatHorizontalPositionValues
   .byte 73, 87, 150, 10

   BOUNDARY 0
   
AnimationSprites_02

   FILL_BOUNDARY MOUSE_SPRITE_OFFSET, 0

   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $EE ; |XXX.XXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY DOG_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY CAT_FACING_DOWN_SPRITE_OFFSET, 0

LivesIndicator
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $BA ; |X.XXX.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $D6 ; |XX.X.XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $6C ; |.XX.XX..|
   
MazePF0GraphicValues
   .word MazePF0Graphics
   
MazePF1GraphicValues
   .word MazePF1Graphics
   .word TrapdoorClosedPF1MazeGraphics
   .word TrapdoorOpenPF1MazeGraphics
   
MazePF2GraphicValues
   .word MazePF2Graphics
   .word TrapdoorClosedPF2MazeGraphics
   .word TrapdoorOpenPF2MazeGraphics
   
ROMCheeseDotPattern
   .byte $50, $50, $50, $00, $00, $50
   .byte $50, $50, $2A, $22, $22, $AA
   .byte $A2, $22, $2A, $A2, $14, $45
   .byte $44, $54, $44, $05, $44, $14
   .byte $80, $20, $20, $A0, $20, $00
   .byte $20, $80, $45, $54, $44, $45
   .byte $44, $54, $45, $44, $A2, $A2
   .byte $A2, $0A, $0A, $A2, $A2, $AA

TrapdoorOpenPF1MazeGraphics
   .byte $FF ; |XXXXXXXX|
   .byte $08 ; |....X...|
   .byte $88 ; |X...X...|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $8F ; |X...XXXX|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $8F ; |X...XXXX|
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $08 ; |....X...|
   .byte $8F ; |X...XXXX|
   .byte $80 ; |X.......|
   .byte $FF ; |XXXXXXXX|
   
BonesIndicator
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   
SetGameAudioValues
   lda AudioValues,x                ; get audio tone value
   sta AUDC0
   inx                              ; increment for frequency and duration values
   stx audioIndexValue
   rts

LaunchedCatCoordinates
   .byte INIT_BOTTOM_CAT_HOME_COORDINATES - 1;decremented y-coordinate
   .byte INIT_TOP_CAT_HOME_COORDINATES + 1;incremented y-coordinate
   .byte INIT_RIGHT_CAT_HOME_COORDINATES - (1 << 4);decremented x-coordinate
   .byte INIT_LEFT_CAT_HOME_COORDINATES + (1 << 4);incremented x-coordinate

InitCatKernelZoneValues
   .byte 7, 0, 4, 3
   
LaunchedCatKernelZoneValues
   .byte 6, 1, 4, 3
   
TrapdoorClosedPF2MazeGraphics
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $10 ; |...X....|
   .byte $11 ; |...X...X|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   
SetMazePlayfieldPointers
   lda MazePF0GraphicValues
   sta pf0GraphicPointer
   lda MazePF0GraphicValues + 1
   sta pf0GraphicPointer + 1
   lda MazePF1GraphicValues,x
   sta pf1GraphicPointer
   lda MazePF1GraphicValues + 1,x
   sta pf1GraphicPointer + 1
   lda MazePF2GraphicValues,x
   sta pf2GraphicPointer
   lda MazePF2GraphicValues + 1,x
   sta pf2GraphicPointer+1
   rts

   BOUNDARY 0

AnimationSprites_03

   FILL_BOUNDARY MOUSE_SPRITE_OFFSET, 0

   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $6E ; |.XX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY DOG_SPRITE_OFFSET, 0
   
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY (CAT_FACING_DOWN_SPRITE_OFFSET + 1), 0

MazeRules
   MAZE_RULES MOVE_RIGHT,                  MOVE_RIGHT
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES MOVE_UP,                     [MOVE_RIGHT & MOVE_UP]
   MAZE_RULES P0_NO_MOVE,                  P0_NO_MOVE
   MAZE_RULES P0_NO_MOVE,                  P0_NO_MOVE
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [P0_VERT_MOVE & MOVE_RIGHT], [P0_VERT_MOVE & MOVE_RIGHT]
   MAZE_RULES MOVE_UP,                     MOVE_UP

   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [P0_HORIZ_MOVE & MOVE_UP],   [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [P0_HORIZ_MOVE & MOVE_DOWN]
   MAZE_RULES P0_VERT_MOVE,                P0_VERT_MOVE
   MAZE_RULES [MOVE_RIGHT & MOVE_UP],      P0_VERT_MOVE
   MAZE_RULES P0_HORIZ_MOVE,               [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [MOVE_RIGHT & MOVE_UP],      [MOVE_RIGHT & MOVE_UP]

   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & MOVE_UP],       [MOVE_LEFT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [P0_HORIZ_MOVE & MOVE_UP],   [MOVE_RIGHT & MOVE_UP]
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES MOVE_UP,                     [MOVE_RIGHT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     MOVE_LEFT
   MAZE_RULES [MOVE_RIGHT & P0_VERT_MOVE], [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_LEFT & MOVE_UP],       MOVE_LEFT
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [P0_HORIZ_MOVE & MOVE_DOWN]
   MAZE_RULES [MOVE_RIGHT & P0_VERT_MOVE], [MOVE_RIGHT & P0_VERT_MOVE]
   MAZE_RULES [MOVE_RIGHT & P0_VERT_MOVE], [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_LEFT & MOVE_UP],       MOVE_LEFT

   MAZE_RULES MOVE_RIGHT,                  MOVE_RIGHT
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES MOVE_DOWN,                   [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [MOVE_RIGHT & P0_VERT_MOVE], [MOVE_RIGHT & P0_VERT_MOVE]
   MAZE_RULES MOVE_UP,                     [MOVE_LEFT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES MOVE_RIGHT,                  MOVE_RIGHT

   MAZE_RULES MOVE_LEFT,                   MOVE_LEFT
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES MOVE_DOWN,                   [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [MOVE_LEFT & P0_VERT_MOVE]
   MAZE_RULES MOVE_UP,                     [MOVE_RIGHT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES MOVE_LEFT,                   MOVE_LEFT

   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    MOVE_RIGHT
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [MOVE_RIGHT & P0_VERT_MOVE], [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_RIGHT & MOVE_UP],      MOVE_RIGHT
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [P0_HORIZ_MOVE & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [MOVE_LEFT & P0_VERT_MOVE]
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_RIGHT & MOVE_UP],      MOVE_RIGHT

   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [MOVE_RIGHT & MOVE_UP],      [MOVE_RIGHT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [P0_HORIZ_MOVE & MOVE_UP],   [MOVE_LEFT & MOVE_UP]
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES MOVE_UP,                     [MOVE_LEFT & MOVE_UP]
   MAZE_RULES P0_HORIZ_MOVE,               P0_HORIZ_MOVE

   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [P0_HORIZ_MOVE & MOVE_UP],   [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [P0_HORIZ_MOVE & MOVE_DOWN]
   MAZE_RULES P0_VERT_MOVE,                P0_VERT_MOVE
   MAZE_RULES [MOVE_LEFT & MOVE_UP],       P0_VERT_MOVE
   MAZE_RULES P0_HORIZ_MOVE,               [P0_HORIZ_MOVE & MOVE_UP]
   MAZE_RULES [MOVE_RIGHT & MOVE_DOWN],    [MOVE_RIGHT & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & MOVE_UP],       [MOVE_LEFT & MOVE_UP]

   MAZE_RULES MOVE_LEFT,                   MOVE_LEFT
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES MOVE_UP,                     [MOVE_LEFT & MOVE_UP]
   MAZE_RULES P0_NO_MOVE,                  P0_NO_MOVE
   MAZE_RULES P0_NO_MOVE,                  P0_NO_MOVE
   MAZE_RULES [MOVE_LEFT & MOVE_DOWN],     [MOVE_LEFT & MOVE_DOWN]
   MAZE_RULES [MOVE_LEFT & P0_VERT_MOVE],  [MOVE_LEFT & P0_VERT_MOVE]
   MAZE_RULES MOVE_UP,                     MOVE_UP

SetupToDisplayScore
   stx GRP0                   ; 3         clear player graphics (i.e. x = 0)
   stx GRP1                   ; 3
   sta WSYNC
;--------------------------------------
   lda #69                    ; 2
   jsr PositionObjectHorizontally; 6
;--------------------------------------
   lda #77                    ; 2 = @12
   inx                        ; 2
   jsr PositionObjectHorizontally; 6
;--------------------------------------
   ldx #TWO_COPIES            ; 2 = @12
   stx NUSIZ0                 ; 3 = @15
   stx NUSIZ1                 ; 3 = @18
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpScoreColor          ; 3
SetColorForSixDigitKernel
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
.drawIt
   sta WSYNC
;--------------------------------------
   lda (digitGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @08
   lda (digitGraphicPtrs + 2),y;5
   sta GRP1                   ; 3 = @16
   SLEEP_12                   ; 12
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda (digitGraphicPtrs + 6),y;5
   tax                        ; 2
   lda (digitGraphicPtrs + 4),y;5
   sta GRP0                   ; 3 = @47
   stx GRP1                   ; 3 = @50
   dey                        ; 2
   bpl .drawIt                ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @59
   sta GRP1                   ; 3 = @62
   rts                        ; 6

TrapdoorOpenPF2MazeGraphics
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $FF ; |XXXXXXXX|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|
   .byte $F1 ; |XXXX...X|
   .byte $01 ; |.......X|
   .byte $F1 ; |XXXX...X|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|

   BOUNDARY 0
   
NumberFonts
zero
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
one
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
two
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
three
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $38 ; |..XXX...|
   .byte $0C ; |....XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
four
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
five
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
six
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $C0 ; |XX......|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
eight
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
nine
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $0C ; |....XX..|
   .byte $7C ; |.XXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
   
IncrementScore
   sec
   ldx #1
.incrementScore
   sed
   adc playerScore,x
   sta playerScore,x
   cld
   bcc .incrementNextScoreValue
   cpx #1
   bne .incrementNextScoreValue
   lda playerScore                  ; get score hundreds value
   and #$0F                         ; keep hundreds value
   cmp #5 - 1
   beq .incrementNumberOfLives
   cmp #10 - 1
   bne .incrementScoreHundredsValue
.incrementNumberOfLives
   inc remainingLives
.incrementScoreHundredsValue
   sec
.incrementNextScoreValue
   lda #0
   dex
   bpl .incrementScore
   rts

DetermineObjectMovement
   clc
   lda tmpAllowedDirection          ; get allowed direction value
   tax                              ; move allowed direction to x register
   bpl .determineObjectMovement     ; branch if object allowed to move
   rts

.determineObjectMovement
   txa                              ; move directional values to accumulator
   and #DIR_CHANGE_MASK             ; keep DIR_CHANGE value
   bne .moveObjectVertically        ; branch if moving vertically
   lda tmpCurrentObjectType         ; get current object tpe value
   bne .moveCatHorizontally         ; branch if ID_CAT
   txa                              ; move directional values to accumulator
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .movePlayerLeft              ; branch if DIR_ADJUSTMENT_NEGATIVE
   inc playerHorizPos
   bne DecrementMovementSteps       ; unconditional branch
   
.movePlayerLeft
   dec playerHorizPos
   bne DecrementMovementSteps       ; unconditional branch
   
.moveCatHorizontally
   tya                              ; move maze coordinates to accumulator
   and #7                           ; keep y-coordinate value
   tax
   lda tmpAllowedDirection          ; get allowed direction value
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .moveCatLeft                 ; branch if DIR_ADJUSTMENT_NEGATIVE
   inc catHorizPositionValues,x
   bcc DecrementMovementSteps       ; unconditional branch
   
.moveCatLeft
   dec catHorizPositionValues,x
   bcc DecrementMovementSteps       ; unconditional branch
   
.moveObjectVertically
   txa                              ; move directional values to accumulator
   and #DIR_ADJUSTMENT_MASK
   bne .moveObjectUp                ; branch if DIR_ADJUSTMENT_NEGATIVE
   jsr DetermineMazeCoordinateValueY
   bne .moveCatDown
   dec mouseLSBPointers,x
   dec mouseLSBPointers + 1,x
   bcc DecrementMovementSteps       ; unconditional branch
   
.moveCatDown
   dec catLSBPointers,x
   dec catLSBPointers + 1,x
   bcc DecrementMovementSteps       ; unconditional branch
   
.moveObjectUp
   jsr DetermineMazeCoordinateValueY
   bne .moveCatUp
   inc mouseLSBPointers,x
   inc mouseLSBPointers - 1,x
   bcc DecrementMovementSteps       ; unconditional branch
   
.moveCatUp
   inc catLSBPointers,x
   inc catLSBPointers - 1,x
DecrementMovementSteps
   lda tmpAllowedDirection          ; get allowed direction value
   tax                              ; move allowed direction to x register
   and #<~MOVEMENT_STEPS_MASK       ; clear the MOVEMENT_STEPS value
   sta tmpAllowedDirection
   txa                              ; move allowed direction to accumulator
   and #MOVEMENT_STEPS_MASK         ; keep the MOVEMENT_STEPS value
   tax                              ; move movement steps to x register
   dex
   beq .removeObjectFromZone        ; branch if MOVEMENT_STEPS done
   txa                              ; move MOVEMENT_STEPS to accumulator
   ora tmpAllowedDirection          ; combine with allowed direction
   sta tmpAllowedDirection          ; update with new MOVEMENT_STEPS value
   lda #1
   sta tmpObjectIntersectionState   ; set to show object not in intersection
   jmp .doneDetermineObjectMovement
   
.removeObjectFromZone
   lda tmpAllowedDirection
   and #DIR_CHANGE_MASK             ; keep DIR_CHANGE value
   beq .determineNewXCoordinateValue; branch if HORIZ_DIR
   jsr DetermineMazeCoordinateValueY
   bne .removeCatFromZone           ; branch if ID_CAT
   lda #BLANK_MOUSE_SPRITE_OFFSET
   sta mouseLSBPointers,x
   beq .setNewMazeCoordinateValues  ; unconditional branch
   
.removeCatFromZone
   lda #BLANK_CAT_SPRITE_OFFSET
   sta catLSBPointers,x
.setNewMazeCoordinateValues
   lda tmpAllowedDirection
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .determineNewMovingUpYCoordinateValue;branch if DIR_ADJUSTMENT_NEGATIVE
   lda tmpCurrentObjectType
   beq .determineNewMovingDownYCoordinateValue;branch if ID_MOUSE
   lda catHorizPositionValues,x
   sta catHorizPositionValues + 1,x
   lda #XMIN
   sta catHorizPositionValues,x
.determineNewMovingDownYCoordinateValue
   jsr DetermineMazeCoordiateValue
   inx                              ; increment y-coordinate value
   bpl .setCoordinateNewYValue      ; unconditional branch
   
.determineNewMovingUpYCoordinateValue
   jsr DetermineMazeCoordiateValue
   dex                              ; decrement y-coordinate value
.setCoordinateNewYValue
   txa                              ; move y-coordinate value to accumulator
   ora tmpCoordinateX               ; combine with x-coordinate value
   bcc CheckForMouseEatingCheese    ; unconditional branch
   
.determineNewXCoordinateValue
   ldx #16
   lda tmpAllowedDirection
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   beq .setCoordinateNewXValue      ; branch if DIR_ADJUSTMENT_POSITIVE
   ldx #<-16
.setCoordinateNewXValue
   sty tmpMazeCoordinates
   txa                              ; move horizontal adjustment to accumulator
   adc tmpMazeCoordinates           ; adjust Maze coordinate x value
CheckForMouseEatingCheese
   tay                              ; move Maze coordinate value to y register
   lda tmpCurrentObjectType
   bne .doneMouseEatingCheese       ; branch if ID_CAT
   tya                              ; move Mouse coordinate value to accumulator
   sty playerMazeCoordinates
   and #7                           ; keep y-coordinate value
   sta tmpMouseCoordinateY
   tya                              ; move Mouse coordinate value to accumulator
   and #$F0                         ; keep x-coordinate value
   lsr
   lsr
   lsr
   tax
   lda CheeseBitMaskingValues,x
   clc                              ; not needed...carry cleared from bit shifts
   adc tmpMouseCoordinateY          ; increment by y-coordinate
   tay
   lda mazeCheese,y                 ; get cheese RAM value
   sta tmpCheeseRAMValue
   lda CheeseBitMaskingValues + 1,x
   and mazeCheese,y
   cmp tmpCheeseRAMValue
   beq .cheeseAlreadyEaten
   sta mazeCheese,y
   lda playerMazeCoordinates        ; get player maze coordinate value
   and #$F0                         ; keep x-coordinate value
   cpy #9
   beq .checkMouseEatingLeftBone
   cpy #13
   beq .checkMouseEatingLeftBone
   cpy #41
   beq .checkMouseEatingRightBone
   cpy #45
   beq .checkMouseEatingRightBone
.mouseEatingCheese
   lda #POINTS_EAT_CHEESE
   jsr IncrementScore
   ldx #<[EatingCheeseAudioValues - AudioValues]
   jsr SetGameAudioValues
   inc gameBoardStatus              ; increment Cheese eaten
   lda gameBoardStatus              ; get current game board status
   and #CHEESE_TALLY_MASK           ; keep tally of Cheese eaten
   cmp #MAX_NUM_CHEESE
   bcs .rackCleared                 ; branch if eaten all the Cheese
   ldy playerMazeCoordinates        ; get player maze coordinate value
.doneMouseEatingCheese
   jmp .doneCheckForMouseEatingCheese
   
.checkMouseEatingLeftBone
   cmp #1 << 4 | 0
   beq .incrementNumberOfBonesCollected
   bne .mouseEatingCheese
   
.checkMouseEatingRightBone
   cmp #8 << 4 | 0
   bne .mouseEatingCheese
.incrementNumberOfBonesCollected
   ldx #<[EatingBoneAudioValues - AudioValues]
   jsr SetGameAudioValues
   inc remainingBones
   ldy playerMazeCoordinates        ; get player maze coordinate value
   jmp .doneCheckForMouseEatingCheese

.rackCleared
   lda #$80
   sta newRackStatus
   lda #POINTS_CLEAR_RACK
   jsr IncrementScore
   jsr InitializeNewRack
   lda catMovementDelay
   bmi .setToSlowCatDelayValue
   ora #$80
   bne .setNewRackCatMovementDelay  ; unconditional branch
   
.setToSlowCatDelayValue
   asl
   ora #1
.setNewRackCatMovementDelay
   sta catMovementDelay
   ldx #$FF
   txs                              ; reset stack to the beginning
   jmp NewFrame
   
.cheeseAlreadyEaten
   sta mazeCheese,y
   ldy playerMazeCoordinates        ; get Player Maze coordinate value
.doneCheckForMouseEatingCheese
   lda #0
   sta tmpObjectIntersectionState   ; clear object intersection state
   ldx #STOPPED_AT_INTERSECTION
   lda tmpAllowedDirection
   and #DIR_CHANGE_MASK             ; keep DIR_CHANGE value
   stx tmpAllowedDirection
   beq .doneDetermineObjectMovement ; branch if HORIZ_DIR_CHANGE
   inc tmpObjectIntersectionState   ; set to show object not in intersection
.doneDetermineObjectMovement
   rts

DetermineMazeCoordiateValue
   tya                              ; move coordinate value to accumulator
   tax                              ; move coordinate value to x register
   and #$F0                         ; keep x-coordinate value
   sta tmpCoordinateX
MoveYCoordinateToXRegister
   tya                              ; move coordinate value to accumulator
   and #7                           ; keep y-coordinate value
   tax                              ; move y-coordinate value to x register
   rts

DetermineToChangeCatDirection
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   and #7                           ; keep y-coordinate value
   sta tmpCatCoordinateValue
   lda playerMazeCoordinates        ; get player maze coordinate value
   and #7                           ; keep y-coordinate value
   sec
   sbc tmpCurrentCatCoordinateY
   sta tmpCatPlayerVertDistance
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   lsr                              ; shift x-coordinate value to lower nybbles
   lsr
   lsr
   lsr
   sta tmpCatCoordinateValue
   lda playerMazeCoordinates        ; get player maze coordinate value
   lsr                              ; shift x-coordinate value to lower nybbles
   lsr
   lsr
   lsr
   sec
   sbc tmpCatCoordinateValue
   sta tmpCatPlayerHorizDistance
   ldy #2
   lda tmpCatPlayerVertDistance
   bpl .setVerticalDistanceABSValue ; branch if player below Cat
   eor #$FF                         ; get vertical distance absolute value
   sec
   adc #1 - 1
.setVerticalDistanceABSValue
   sta tmpCatPlayerABSVertDistance
   lda tmpCatPlayerHorizDistance
   bpl .setHorizontalDistanceABSValue;branch if player to the right of Cat
   eor #$FF                         ; get horizontal distance absolute value
   sec
   adc #1 - 1
.setHorizontalDistanceABSValue
   pha                              ; push absolute distance value to stack
   lda dogTimer                     ; get Dog timer value
   beq .catSearchingForMouse        ; branch if Dog timer expired
   lda tmpCatPlayerVertDistance     ; get vertical distance value
   eor #$80                         ; -/+ 127
   sta tmpCatPlayerVertDistance     ; set Cat vertical distance to "scare"
   lda tmpCatPlayerHorizDistance    ; get horizontal distance value
   eor #$80                         ; -/+ 127
   sta tmpCatPlayerHorizDistance    ; set Cat horizontal distance to "scare"
   pla                              ; pull horizontal distance from stack
   cmp tmpCatPlayerABSVertDistance
   bcs .horizontalDistancePriority  ; branch if horizontal distance greater
   bcc .setTopPriorityDirectionIndexValue;unconditional branch

.catSearchingForMouse
   pla                              ; pull horizontal distance from stack
   cmp tmpCatPlayerABSVertDistance
   bcs .horizontalDistancePriority  ; branch if horizontal distance is greater
.setTopPriorityDirectionIndexValue
   dey
   dey
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   sec
   bcs .determineCatZoneConflictPriority;unconditional branch
   
.horizontalDistancePriority
   beq .setTopPriorityDirectionIndexValue;branch if same distances
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   cmp #5 << 4 | 0
   lda tmpCatPlayerHorizDistance
   bcc .determineCatZoneConflictPriority;branch if Cat on left half of maze
   eor #$80
.determineCatZoneConflictPriority
   bpl .setCatDesiredDirectionIndex ; branch if no Cat zone conflict
   iny
.setCatDesiredDirectionIndex
   sty tmpCatDesiredDirectionIndex
   lda SWCHB                        ; read console switches
   and #P0_DIFF_MASK                ; keep right difficulty switch value
   bne .determineAllowedDirectionIndex;branch if set to PRO (i.e. Smart Cats)
   lda playerScore + 1              ; get score ones value
   and #3
   sta tmpCatDesiredDirectionIndex
.determineAllowedDirectionIndex
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   and #7                           ; keep y-coordinate value
   sta tmpMazeCoordinates
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   lsr                              ; shift x-coordinate value to lower nybbles
   lsr
   lsr
   lsr
   sta tmpCatCoordinateX
   cmp #5
   bcc .setCatMazeCoordinates       ; branch if Cat on left side of Maze
   sec                              ; not needed...carry already set
   sbc #9                           ; -4 <= a <= 0
   eor #$FF
   sec
   adc #1 - 1                       ; 0 <= a <= 4
.setCatMazeCoordinates
   asl
   asl
   asl
   ora tmpMazeCoordinates           ; combine with Cat y-coordinate value
   tay
   cpy #0 << 4 | 3
   beq .jmpSetCatInSameZone         ; branch if left launch box area
   cpy #0 << 4 | 4
   beq .jmpSetCatInSameZone         ; branch if left launch box area
   lda gameBoardStatus
   bpl DetermineDesiredPriorityDirection;branch if Trapdoor closed
   tya                              ; move coordinate value to accumulator
   clc
   adc #2 << 4 | 8
   tay
DetermineDesiredPriorityDirection
   lda MazeAllowedDirectionValues,y ; get position allowed direction values
   sta tmpMazeAllowedDirection
   ldy tmpCatDesiredDirectionIndex
.determineDesiredPriorityDirection
   beq .desiredPriorityDirectionFound
   lsr                              ; shift to get next allowed direction value
   lsr
   dey                              ; decrement desired Cat direction value
   bne .determineDesiredPriorityDirection
.desiredPriorityDirectionFound
   and #3                           ; keep current allowed direction value
   sta tmpCatDirection
   lda #4
   sta tmpDesiredDirectionIndex
.determineCatAllowedDesiredDirection
   jsr DetermineCatAllowedInZone
   dec tmpDesiredDirectionIndex
   beq .foundCatDesiredDirection
   lda tmpCatZoneConflictState      ; get Cat zone conflict state
   bpl .foundCatDesiredDirection    ; branch if no Cat zone conflict
   lda tmpMazeAllowedDirection
   lsr tmpMazeAllowedDirection      ; shift to get next allowed direction value
   lsr tmpMazeAllowedDirection
   and #3                           ; keep current allowed direction value
   sta tmpCatDirection
   bpl .determineCatAllowedDesiredDirection;unconditional branch
   
.foundCatDesiredDirection
   lda catMazeCoordinates,x         ; get Cat maze coordinate value
   cmp #5 << 4 | 0
   bcc .doneDetermineToChangeCatDirection;branch if Cat on left side of maze
   lda tmpCatDirection
   bmi .doneDetermineToChangeCatDirection
   cmp #CAT_DIR_LEFT
   bcc .doneDetermineToChangeCatDirection;branch if Cat moving vertically
   eor #1                           ; flip DIR_ADJUSTMENT value
   sta tmpCatDirection
.doneDetermineToChangeCatDirection
   rts

DetermineCatAllowedInZone
   lda tmpVertCatIndex
   bmi .setCatZoneConflict
   cmp #CAT_DIR_LEFT
   bcs .doneDetermineCatAllowedInZone;branch if Cat moving horizontally
   ldy catMazeCoordinates,x         ; get Cat maze coordinate value
   cmp #CAT_DIR_DOWN
   bne .decrementDesiredYCoordinate ; branch if Cat not moving moving down
   iny                              ; increment desired y-coordinate for Top Cat
   bne .setDesiredLaunchCoordinates ; unconditional branch
   
.decrementDesiredYCoordinate
   dey                              ; decrement y-coordinate for Bottom Cat
.setDesiredLaunchCoordinates
SetDesiredUpdatedCoordinates
   tya                              ; move coordinate values to accumulator
   and #7                           ; keep desired y-coordinate value
   sta tmpDesiredCoordinateY
   ldy #3
.checkSharingZones
   lda catMazeCoordinates,y         ; get Cat maze coordinate value
   and #$0F                         ; keep y-coordinate value
   sta tmpCatCoordinateY
   cmp tmpDesiredCoordinateY
.jmpSetCatInSameZone
   beq .setCatZoneConflict          ; branch if in same zone
   lda catAllowedDirections,y
   bmi .checkNextCatSafeZone        ; branch if STOPPED_AT_INTERSECTION
   cmp #VERT_DIR_CHANGE
   bcc .checkNextCatSafeZone        ; branch if moving horizontally
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   beq .incrementCatYCoordinate     ; branch if DIR_ADJUSTMENT_POSITIVE
   dec tmpCatCoordinateY
   jmp .checkCatSharingZones
   
.incrementCatYCoordinate
   inc tmpCatCoordinateY
.checkCatSharingZones
   lda tmpCatCoordinateY
   cmp tmpDesiredCoordinateY
   beq .setCatZoneConflict          ; branch if in same zone
.checkNextCatSafeZone
   dey
   bpl .checkSharingZones
   rts

.setCatZoneConflict
   lda #$80
   sta tmpCatZoneConflictState      ; set state to show Cat zone conflict
.doneDetermineCatAllowedInZone
   rts

DetermineCatFacingDirection
   lda catAllowedDirections,x
   sta tmpAllowedDirection
   ldy catMazeCoordinates,x         ; get Cat maze coordinate value
   cpy #0 << 4 | 14
   beq .setCatHorizontalStepValue
   lda tmpCatDirection
   bpl .determineCatFacingDirection
.setCatHorizontalStepValue
   jmp .setObjectHorizontalStepValue

.determineCatFacingDirection
   tax                              ; move Cat direction value to x register
   and #DIR_CHANGE_MASK >> 5        ; keep CAT_DIR_CHANGE value
   beq .checkToSetCatVerticalDirection;branch if CAT_DIRECTION_VERTICAL
   txa                              ; move Cat direction value to accumulator
   and #DIR_ADJUSTMENT_MASK >> 5    ; keep CAT_ADJUSTMENT value
   bne .setCatToFacingRight         ; branch if CAT_DIRECTION_POSITIVE
   jsr MoveYCoordinateToXRegister
   lda #CAT_FACING_LEFT_SPRITE_OFFSET
   sta catLSBPointers,x             ; set to CAT_FACING_LEFT
   lda #CURRENTLY_MOVING | HORIZ_DIR_CHANGE | DIR_ADJUSTMENT_NEGATIVE
   jmp .determineCatHorizontalSteps
   
.setCatToFacingRight
   jsr MoveYCoordinateToXRegister
   lda #CAT_FACING_RIGHT_SPRITE_OFFSET
   sta catLSBPointers,x             ; set to CAT_FACING_RIGHT
   lda #CURRENTLY_MOVING | HORIZ_DIR_CHANGE | DIR_ADJUSTMENT_POSITIVE
   beq .determineCatHorizontalSteps ; unconditional branch
   
.checkToSetCatVerticalDirection
   txa                              ; move Cat direction value to accumulator
   bne .checkToSetCatFacingDown     ; branch if CAT_DIRECTION_POSITIVE
   jsr MoveYCoordinateToXRegister
   lda catHorizPositionValues,x
   sta catHorizPositionValues - 1,x
   lda #XMIN
   sta catHorizPositionValues,x
   lda #CAT_FACING_UP_SPRITE_OFFSET
   sta catLSBPointers,x             ; set to CAT_FACING_UP
   lda #CAT_FACING_UP_SPRITE_OFFSET - H_KERNEL_SECTION
   sta catLSBPointers - 1,x
   lda #VERT_DIR_CHANGE | DIR_ADJUSTMENT_NEGATIVE | 17
   bne .doneDetermineObjectDirectionalSteps;unconditional branch
   
.checkToSetCatFacingDown
   cmp #CAT_DIR_DOWN
   bne .doneDetermineObjectDirectionalSteps
   jsr MoveYCoordinateToXRegister
   lda #CAT_FACING_DOWN_SPRITE_OFFSET
   sta catLSBPointers,x             ; set to CAT_FACING_DOWN
   lda #CAT_FACING_DOWN_SPRITE_OFFSET + H_KERNEL_SECTION
   sta catLSBPointers + 1,x
   lda #VERT_DIR_CHANGE | DIR_ADJUSTMENT_POSITIVE | 17
   bne .doneDetermineObjectDirectionalSteps;unconditional branch
   
.determineCatHorizontalSteps
   pha                              ; push Cat desired direction value to stack
   tya                              ; move maze coordinate value to accumulator
   and #7                           ; keep y-coordinate value
   tax
   lda catHorizPositionValues,x     ; get Cat horizontal position
   tax
   pla                              ; restore Cat desired direction value
DetermineObjectHorizontalSteps
   sta tmpAllowedDirection
   cpx #58
   beq .setHorizStepsForXCoordinate03;branch if in x-coordinate 3
   cpx #73
   beq .setHorizStepsForXCoordinate04;branch if in x-coordinate 4
   cpx #87
   beq .setHorizStepsForXCoordinate05;branch if in x-coordinate 5
   cpx #102
   beq .setHorizStepsForXCoordinate06;branch if in x-coordinate 6
   bne .setHorizStepValueTo16Moves  ; unconditional branch
   
.setHorizStepsForXCoordinate03
   and #ALLOW_MOVEMENT_MASK | DIR_CHANGE_MASK | DIR_ADJUSTMENT_MASK
   beq .setHorizStepValueTo15Moves  ; branch if MOVE_RIGHT
   bne .setHorizStepValueTo16Moves  ; unconditional branch
   
.setHorizStepsForXCoordinate04
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .setHorizStepValueTo15Moves  ; branch if MOVE_LEFT
   beq .setHorizStepValueTo14Moves  ; unconditional branch
   
.setHorizStepsForXCoordinate05
   and #ALLOW_MOVEMENT_MASK | DIR_CHANGE_MASK | DIR_ADJUSTMENT_MASK
   beq .setHorizStepValueTo15Moves  ; branch if MOVE_RIGHT
.setHorizStepValueTo14Moves
   lda #14
   bne .setObjectHorizontalStepValue; unconditional branch
   
.setHorizStepsForXCoordinate06
   and #DIR_ADJUSTMENT_MASK         ; keep DIR_ADJUSTMENT value
   bne .setHorizStepValueTo15Moves  ; branch if MOVE_LEFT
.setHorizStepValueTo16Moves
   lda #16
   bne .setObjectHorizontalStepValue; unconditional branch
   
.setHorizStepValueTo15Moves
   lda #15
.setObjectHorizontalStepValue
   ora tmpAllowedDirection
.doneDetermineObjectDirectionalSteps
   rts

MazeAllowedDirectionValues
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP

   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_DOWN,  CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT

   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT

   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_LEFT
   
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT

   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_DOWN   
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP

   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_UP
   
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT

   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_DOWN,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_UP
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT,  CAT_DIR_LEFT

   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_DOWN,  CAT_DIR_LEFT,  CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_UP,    CAT_DIR_RIGHT, CAT_DIR_UP,    CAT_DIR_DOWN
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_UP,    CAT_DIR_UP,    CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_LEFT,  CAT_DIR_RIGHT, CAT_DIR_LEFT,  CAT_DIR_LEFT
   CAT_DIR_PRIORITY CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT, CAT_DIR_RIGHT

InitializeGame
   lda #COLOR_MAZE
   sta COLUPF                       ; reset maze color
   sta currentMazeColor
   lda #INIT_NUM_LIVES
   sta remainingLives               ; set initial number of lives
   ldx #0
   stx gameOverState                ; set to not GAME_OVER
   stx gameIdleTimer                ; clear game idle timer value
   stx mouseCollisionTimer
   stx playerScore                  ; clear player score
   stx playerScore + 1
   inx                              ; x = 1
   stx remainingBones               ; set initial number of Bones collected
   lda SWCHB                        ; read console switches
   bpl .setCatMovementDelayValue    ; branch if right difficulty set to AMATEUR
   ldx #FAST_CAT_DELAY_VALUE
.setCatMovementDelayValue
   stx catMovementDelay
InitializeNewRack
   lda dogTimer                     ; get Dog timer value
   beq ResetCheeseDotArray
   clc
   adc #$5A
   sta dogTimer
ResetCheeseDotArray
   ldx #59                          ; could have been 47d
.resetCheeseDotArray
   lda ROMCheeseDotPattern,x
   sta mazeCheese,x
   dex
   bpl .resetCheeseDotArray
   inx                              ; x = 0
   stx gameBoardStatus
   jsr SetGameAudioValues
ResetPlayerPositionValues
   lda #180
   sta startRoundPauseTimer
   lda #STOPPED_AT_INTERSECTION
   sta playerAllowedDirection
   lda #INIT_PLAYER_MAZE_COORDINATES
   sta playerMazeCoordinates
   lda #XMIN
   ldx #7
.initCatHorizontalPositions
   sta catHorizPositionValues,x
   dex
   bpl .initCatHorizontalPositions
   lda #>AnimationSprites_00
   sta mouseGraphicPointer + 1
   sta catGraphicPointer + 1
   ldx #7
   lda #BLANK_MOUSE_SPRITE_OFFSET
   ldy #BLANK_CAT_SPRITE_OFFSET
.initSpriteLSBValues
   sta mouseLSBPointers,x
   sty catLSBPointers,x
   dex
   bpl .initSpriteLSBValues
   lda #MOUSE_SPRITE_OFFSET
   sta mouseLSBPointers + 5
   lda #INIT_PLAYER_HORIZ_POS
   sta playerHorizPos
   ldy #3
.resetCatHomePositions
   tya
   tax
   jsr ResetCatHomePosition
   dey
   bpl .resetCatHomePositions
   sty verticalCatsReleaseTimer
   sty horizontalCatsReleaseTimer
;
; disable top most Cat
;
   lda #0 << 4 | 14
   sta catMazeCoordinates + 1
   lda #XMIN
   sta catHorizPositionValues
   lda #BLANK_CAT_SPRITE_OFFSET
   sta catLSBPointers
   rts

CheeseBitMaskingValues
   .byte <leftPF0MazeCheese - mazeCheese
   .byte <~(1 << 6)
   .byte <leftPF1MazeCheese - mazeCheese
   .byte <~(1 << 5)
   .byte <leftPF1MazeCheese - mazeCheese
   .byte <~(1 << 1)
   .byte <leftPF2MazeCheese - mazeCheese
   .byte <~(1 << 2)
   .byte <leftPF2MazeCheese - mazeCheese
   .byte <~(1 << 6)
   .byte <rightPF0MazeCheese - mazeCheese
   .byte <~(1 << 5)
   .byte <rightPF1MazeCheese - mazeCheese
   .byte <~(1 << 6)
   .byte <rightPF1MazeCheese - mazeCheese
   .byte <~(1 << 2)
   .byte <rightPF2MazeCheese - mazeCheese
   .byte <~(1 << 1)
   .byte <rightPF2MazeCheese - mazeCheese
   .byte <~(1 << 5)
   
InitMazeGraphicPointers
   .word MazePF0Graphics
   .word MazePF1Graphics
   .word MazePF2Graphics
   
ResetCatHomePosition
   lda #STOPPED_AT_INTERSECTION
   sta catAllowedDirections,x       ; disable Cat movement
   lda InitCatHomeCoordiateValues,y
   sta catMazeCoordinates,x         ; set Cat initial maze coordinates
   lda InitCatKernelZoneValues,y
   tax
   lda InitCatGraphicPointerLSBValues,y
   sta catLSBPointers,x
   lda InitCatHorizontalPositionValues,y
   sta catHorizPositionValues,x     ; set Cat initial horizontal position
   tya
   clc
   ror
   tax
   lda #$FA
   bcc .initCatReleaseTimer
   lda #$AF
.initCatReleaseTimer
   and catReleaseTimer,x
   sta catReleaseTimer,x
   rts

PlayGameAudioSounds
   lda audioDurationValue           ; get audio duration value
   beq .checkToPlayNextAudioFrequency
   dec audioDurationValue           ; decrement audio duration value
   rts

.checkToPlayNextAudioFrequency
   ldx audioIndexValue
   lda #10
   sta AUDV0                        ; set volume for sounds
   lda AudioValues,x                ; get audio frequency and duration value
   bne .playNextAudioFrequency
   sta AUDC0                        ; turn off sound
   rts

.playNextAudioFrequency
   sta AUDF0
   and #AUDIO_DURATION_MASK
   lsr
   lsr
   lsr
   lsr
   sta audioDurationValue
   inx
   stx audioIndexValue
   rts

   IF COMPILE_REGION = NTSC
   
   .byte $BB,$D2,$A0,$A0,$A0,$A0,$E0,$A0,$E0,$A0;unused bytes
   
   ELSE
   
   .byte $A9,$B3,$CA,$B1,$DB,$A0,$A0,$FE,$CC,$85;unused bytes
   
   ENDIF
   
   .org ROM_BASE + 4096 - 4, 0
   .word Start                      ; RESET vector
   
   IF COMPILE_REGION = NTSC
   
   .byte $A5,$FF                    ; BRK vector (unused bytes)
   
   ELSE
   
   .byte $E0,$88                    ; BRK vector (unused bytes)
   
   ENDIF