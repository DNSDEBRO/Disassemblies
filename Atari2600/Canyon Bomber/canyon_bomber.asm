   LIST OFF
; ***  C A N Y O N  B O M B E R  ***
; Copyright 1979 Atari, Inc.
; Designer: David Crane

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: November 2, 2007
;
;  *** 126 BYTES OF RAM USED 2 BYTES FREE
;  ***   2 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1979, ATARI, INC.                                  =
; =                                                                            =
; ==============================================================================
;
; - No offical PAL50 version has been dumped. PAL values are my own
;     interpretation (17% slower than NTSC)

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

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
VBLANK_TIME             = 55
OVERSCAN_TIME           = 34

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 81
OVERSCAN_TIME           = 67
   
   ECHO "*** No official PAL50 version was released by Atari"
   ECHO "*** PAL values are my own interpretation"
   
   ENDIF
   
;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
ORANGE                  = $40
BLUE                    = $80

   ELSE

YELLOW                  = $20
ORANGE                  = $60
BLUE                    = $B0
   
   ECHO "*** No official PAL version was released by Atari"
   ECHO "*** PAL colors are my own interpretation"
   
   ENDIF   
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

MIN_GAME_SELECTION      = 1
MAX_GAME_SELECTION      = 8

NUM_OBJECTS             = 7
H_SCORE                 = 5
H_KERNEL                = 60
H_OBJECT                = 8

XMIN                    = 0
XMAX                    = 159

MISSILE_YMIN            = 2
BRICK_YMAX              = 33

MAX_BRICKS_HIT_PER_MISSILE = 6

SELECT_DELAY            = 30

; game state values
GAME_IN_PROGRESS        = %00001111
SHOW_GAME_SELECTION     = %00000000

; game variation values
GAME_TYPE_MASK          = %10000000
NUM_PLAYERS_MASK        = %01000000
SUSPEND_BRICKS_MASK     = %00000100
BOMB_ATTRIBUTE_MASK     = %00000001

; player attribute mask
SEA_SHIP_HIT            = %10000000
OBJECT_SIZE             = %01110000
DIRECTION_MASK          = %00001000
OBJECT_SPEED            = %00000111

; missile attribute mask
DIRECTION_MASK          = %00001000
MISSILE_SPEED           = %00000110

SEA_BOMBER              = 1 << 7
CANYON_BOMBER           = 0 << 7
NUM_PLAYERS_ONE         = 1 << 6
NUM_PLAYERS_TWO         = 0 << 6
BRICKS_SUSPEND          = 1 << 2
BRICKS_FALL             = 0 << 2
UNLIMITED_BOMBS         = 1 << 0
LIMITED_BOMBS           = 0 << 0

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

objectVariables            ds 40
;--------------------------------------
objectHorizPos             = objectVariables
objectCoarseMotionValues   = objectVariables + 1
objectFineMotionValues     = objectVariables + 2
objectColorIndex           = objectVariables + 3
objectAttributes           = objectVariables + 4
;--------------------------------------
player1ObjectVariables     = objectVariables
;--------------------------------------
player1HorizPos            = player1ObjectVariables
player1CoarseMotionValue   = player1ObjectVariables + 1
player1FineMotionValue     = player1ObjectVariables + 2
player1ColorIndex          = player1ObjectVariables + 3
player1Attributes          = player1ObjectVariables + 4
player2ObjectVariables     = objectVariables + 5
;--------------------------------------
player2HorizPos            = player2ObjectVariables
player2CoarseMotionValue   = player2ObjectVariables + 1
player2FineMotionValue     = player2ObjectVariables + 2
player2ColorIndex          = player2ObjectVariables + 3
player2Attributes          = player2ObjectVariables + 4
seaShipObjectVariables     = objectVariables + 10
;--------------------------------------
seaShipHorizPos            = seaShipObjectVariables
seaShipCoarseMotionValues  = seaShipObjectVariables + 1
seaShipFineMotionValues    = seaShipObjectVariables + 2
seaShipColorIndex          = seaShipObjectVariables + 3
seaShipAttributes          = seaShipObjectVariables + 4
;--------------------------------------
seaShip1ObjectVariables    = seaShipObjectVariables
;--------------------------------------
seaShip1HorizPos           = seaShip1ObjectVariables
seaShip1CoarseMotionValue  = seaShip1ObjectVariables + 1
seaShip1FimeMotionValue    = seaShip1ObjectVariables + 2
seaShip1ColorIndex         = seaShip1ObjectVariables + 3
seaShip1Attributes         = seaShip1ObjectVariables + 4
seaShip2ObjectVariables    = seaShipObjectVariables + 5
;--------------------------------------
seaShip2HorizPos           = seaShip2ObjectVariables
seaShip2CoarseMotionValue  = seaShip2ObjectVariables + 1
seaShip2FimeMotionValue    = seaShip2ObjectVariables + 2
seaShip2ColorIndex         = seaShip2ObjectVariables + 3
seaShip2Attributes         = seaShip2ObjectVariables + 4
seaShip3ObjectVariables    = seaShipObjectVariables + 10
;--------------------------------------
seaShip3HorizPos           = seaShip3ObjectVariables
seaShip3CoarseMotionValue  = seaShip3ObjectVariables + 1
seaShip3FimeMotionValue    = seaShip3ObjectVariables + 2
seaShip3ColorIndex         = seaShip3ObjectVariables + 3
seaShip3Attributes         = seaShip3ObjectVariables + 4
seaShip4ObjectVariables    = seaShipObjectVariables + 15
;--------------------------------------
seaShip4HorizPos           = seaShip4ObjectVariables
seaShip4CoarseMotionValue  = seaShip4ObjectVariables + 1
seaShip4FimeMotionValue    = seaShip4ObjectVariables + 2
seaShip4ColorIndex         = seaShip4ObjectVariables + 3
seaShip4Attributes         = seaShip4ObjectVariables + 4
seaShip5ObjectVariables    = seaShipObjectVariables + 20
;--------------------------------------
seaShip5HorizPos           = seaShip5ObjectVariables
seaShip5CoarseMotionValue  = seaShip5ObjectVariables + 1
seaShip5FimeMotionValue    = seaShip5ObjectVariables + 2
seaShip5ColorIndex         = seaShip5ObjectVariables + 3
seaShip5Attributes         = seaShip5ObjectVariables + 4
seaShip6ObjectVariables    = seaShipObjectVariables + 25
;--------------------------------------
seaShip6HorizPos           = seaShip6ObjectVariables
seaShip6CoarseMotionValue  = seaShip6ObjectVariables + 1
seaShip6FimeMotionValue    = seaShip6ObjectVariables + 2
seaShip6ColorIndex         = seaShip6ObjectVariables + 3
seaShip6Attributes         = seaShip6ObjectVariables + 4
seaShip7ObjectVariables    = seaShipObjectVariables + 30
;--------------------------------------
seaShip7HorizPos           = seaShip7ObjectVariables
seaShip7CoarseMotionValue  = seaShip7ObjectVariables + 1
seaShip7FimeMotionValue    = seaShip7ObjectVariables + 2
seaShip7ColorIndex         = seaShip7ObjectVariables + 3
seaShip7Attributes         = seaShip7ObjectVariables + 4

   .org seaShip3ObjectVariables
   
bricks                     ds 48
;--------------------------------------
leftPF0Bricks              = bricks
leftPF1Bricks              = leftPF0Bricks + 8
leftPF2Bricks              = leftPF1Bricks + 8
rightPF0Bricks             = leftPF2Bricks + 8
rightPF1Bricks             = rightPF0Bricks + 8
rightPF2Bricks             = rightPF1Bricks + 8
objectColorArray           ds 4
;--------------------------------------
player1Color               = objectColorArray
player2Color               = objectColorArray + 1
canyonColor                = objectColorArray + 2
playerScores               ds 4
;--------------------------------------
player1Score               = playerScores
player2Score               = player1Score + 2
missileAttributes          ds 2
;--------------------------------------
player1MissileAttributes   = missileAttributes
player2MissileAttributes   = player1MissileAttributes + 1
initMissileVertPosIndex    ds 2
;--------------------------------------
player1InitMissileVertPosIdx = initMissileVertPosIndex
player2InitMissileVertPosIdx = player1InitMissileVertPosIdx + 1
playerFireButtonValues     ds 2
;--------------------------------------
player1FireButtonValue     = playerFireButtonValues
player2FireButtonValue     = player1FireButtonValue + 1
missileVertPos             ds 2
;--------------------------------------
player1MissileVertPos      = missileVertPos
player2MissileVertPos      = player1MissileVertPos + 1
numMissileBricksHit        ds 2
;--------------------------------------
player1NumMissileBricksHit = numMissileBricksHit
player2NumMissileBricksHit = player1NumMissileBricksHit + 1
playerMissCount            ds 2
;--------------------------------------
player1MissCount           = playerMissCount
player2MissCount           = player1MissCount + 1
currentPlayerNumber        ds 1
currentScanline            ds 1
depthIndicatorVertPos      ds 2
;--------------------------------------
player1DepthIndicatorVertPos = depthIndicatorVertPos
player2DepthIndicatorVertPos = player1DepthIndicatorVertPos + 1
paddleValues               ds 2
;--------------------------------------
player1PaddleValue         = paddleValues
player2PaddleValue         = player1PaddleValue + 1
objectKernelIndex          ds 1
numBricksHit               ds 1
gameState                  ds 1
colorCycleMode             ds 1
frameCount                 ds 1
gameSelection              ds 1
gameVariation              ds 1
selectDebounce             ds 1
kernelSectionColor         ds 1
hueMask                    ds 1
colorEOR                   ds 1
numPlayerKernelSections    ds 1
missileHorizPos            ds 2
;--------------------------------------
player1MissileHorizPos     = missileHorizPos
player2MissileHorizPos     = player1MissileHorizPos + 1
depthChargeExplosionSound  ds 1

temporaryVariables         ds 16
;--------------------------------------   
missileDropFrequency       = temporaryVariables
;--------------------------------------
brickDroppingFrequency     = missileDropFrequency
;--------------------------------------
tmpObjectId                = brickDroppingFrequency
;--------------------------------------
div16Value                 = tmpObjectId
;--------------------------------------
digitGraphicPointers       = div16Value
;--------------------------------------
evenLeftPF1GraphPtr        = digitGraphicPointers
;--------------------------------------
missileHorizPosDiv4        = evenLeftPF1GraphPtr
;--------------------------------------
brickRowIndex              = missileHorizPosDiv4
;--------------------------------------
oddLeftPF1GraphPtr         = evenLeftPF1GraphPtr + 2
;--------------------------------------
tmpBrickValue              = oddLeftPF1GraphPtr
;--------------------------------------
brickMaskingBitIndex       = tmpBrickValue
;--------------------------------------
oddLeftPF2GraphPtr         = oddLeftPF1GraphPtr + 2
;--------------------------------------
kernelPlayer1PaddleValue   = oddLeftPF2GraphPtr
;--------------------------------------
shouldFlipMaskingBits      = kernelPlayer1PaddleValue
;--------------------------------------
evenLeftPF2GraphPtr        = oddLeftPF2GraphPtr + 2
;--------------------------------------
brickMaskingValue          = evenLeftPF2GraphPtr
;--------------------------------------
kernelPlayer2PaddleValue   = brickMaskingValue
;--------------------------------------
evenRightPF1GraphPtr       = evenLeftPF2GraphPtr + 2
;--------------------------------------
tmpObjectGraphicIndex      = evenRightPF1GraphPtr
;--------------------------------------
objectGraphicIndex         = tmpObjectGraphicIndex
;--------------------------------------
pointsValue                = objectGraphicIndex
oddRightPF1GraphPtr        = evenRightPF1GraphPtr + 2
oddRightPF2GraphPtr        = oddRightPF1GraphPtr + 2
evenRightPF2GraphPtr       = oddRightPF2GraphPtr + 2
;--------------------------------------
difficultySettingValues    = evenRightPF2GraphPtr
fireButtonValues           ds 1
;--------------------------------------
tempDigitValue             = fireButtonValues

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E (Part 1)
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
   txa
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   inc gameSelection                ; set game selection to 1
   jmp InitializeGame
   
MainLoop
   ldy #6
   ldx #$FF
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; keep BW switch value
   bne .determineHueMaskValue       ; branch if set to COLOR
   ldx #$0F
   ldy #3
.determineHueMaskValue
   lda gameState                    ; get the current game state
   cmp #GAME_IN_PROGRESS            ; check to see if game is being played
   beq .setHueMaskValue             ; branch if game currently in progress
   txa
   and #$F7
   tax
   lda colorCycleMode
   sta colorEOR
.setHueMaskValue
   stx hueMask
   ldx #3
.loadColorsLoop
   lda ObjectColorTable,y
   eor colorEOR
   and hueMask
   sta objectColorArray,x
   sta COLUP0,x
   dey
   dex
   bpl .loadColorsLoop
   lda canyonColor
   sta COLUBK
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3         enable TIA (i.e. D1 = 0)
   ldx #PF_SCORE              ; 2
   stx CTRLPF                 ; 3 = @08
   dex                        ; 2         x = 0
   ldy #H_SCORE - 1           ; 2
.drawScoreKernelLoop
   sta WSYNC
;--------------------------------------
   SLEEP 4                    ; 4
   lda (oddLeftPF1GraphPtr),y ; 5
   and #$F0                   ; 2
   sta PF1                    ; 3 = @17
   lda (oddLeftPF2GraphPtr),y ; 5
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta PF2                    ; 3 = @33
   lda (oddRightPF1GraphPtr),y; 5
   and #$F0                   ; 2
   sta PF1                    ; 3 = @43
   lda (oddRightPF2GraphPtr),y; 5
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta PF2                    ; 3 = @59
   sta WSYNC
;--------------------------------------
   lda (evenLeftPF1GraphPtr),y; 5
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta PF1                    ; 3 = @16
   lda (evenLeftPF2GraphPtr),y; 5
   and #$0F                   ; 2
   sta PF2                    ; 3 = @26
   lda (evenRightPF1GraphPtr),y;5
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta PF1                    ; 3 = @42
   lda (evenRightPF2GraphPtr),y;5
   and #$0F                   ; 2
   sta PF2                    ; 3 = @52
   dex                        ; 2
   bpl .drawScoreKernelLoop   ; 2³
   ldx #1                     ; 2
   dey                        ; 2
   bpl .drawScoreKernelLoop   ; 2³
   iny                        ; 2         y = 0
   sta WSYNC
;--------------------------------------
   sty PF1                    ; 3 = @03
   sty PF2                    ; 3 = @06
   sta WSYNC
;--------------------------------------
   ldx #QUAD_SIZE             ; 2
   stx NUSIZ1                 ; 3 = @05
.drawRemainingMissileCount
   sta WSYNC
;--------------------------------------
   lda player1MissCount       ; 3
   sta PF1                    ; 3 = @06
   jsr Waste16Cycles          ; 6
   SLEEP 4                    ; 4 = @32
   lda player2MissCount       ; 3
   sta PF1                    ; 3 = @38
   dex                        ; 2
   bpl .drawRemainingMissileCount; 2³
   sty CTRLPF                 ; 3 = @45
   sty PF1                    ; 3 = @48
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #ORANGE + 6            ; 2
   eor colorEOR               ; 3
   and hueMask                ; 3
   sta kernelSectionColor     ; 3
   asl                        ; 2
   sta COLUBK                 ; 3 = @16
   sta COLUPF                 ; 3 = @19
   lda canyonColor            ; 3
   sta COLUP1                 ; 3 = @25
   lda #H_KERNEL              ; 2
   sta currentScanline        ; 3
   lda #$55                   ; 2
   jsr SetPFGraphicRegisters  ; 6
   asl                        ; 2 = @65
   sta PF1                    ; 3 = @68
   ldx #<[ENAM1 - 2]          ; 2
   txs                        ; 2
   sty kernelPlayer1PaddleValue;3
;--------------------------------------
   sty kernelPlayer2PaddleValue;3 = @02
   sty objectKernelIndex      ; 3
PrepareToDrawNextObject
   ldx objectKernelIndex      ; 3
   lda objectAttributes,x     ; 4         get object attributes value
   sta REFP0                  ; 3         set object reflective state
   lda objectFineMotionValues,x;4         get object fine motion value
   sta HMP0                   ; 3         set object's fine motion
   lda objectAttributes,x     ; 4         get object attributes value
   lsr                        ; 2         divide value by 2
   sta tmpObjectGraphicIndex  ; 3
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   and #7                     ; 2
   tay                        ; 2
   lda ObjectSizeTable,y      ; 4
   sta NUSIZ0                 ; 3         set object size
   ldy tmpObjectGraphicIndex  ; 3
   lda objectAttributes,x     ; 4
   bpl .setObjectGraphicIndex ; 2³        branch if object not hit
   lda frameCount             ; 3         get current frame count
   and #4                     ; 2         blink hit object every 4th frame
   bne .setObjectGraphicIndex ; 2³
   ldy #0                     ; 2
.setObjectGraphicIndex
   tya                        ; 2
   and #NUM_OBJECTS * H_OBJECT; 2
   sta objectGraphicIndex     ; 3
   ldy objectCoarseMotionValues,x;4
   pla                        ; 4
   pla                        ; 4
   clc                        ; 2
   txa                        ; 2
   adc #5                     ; 2
   sta objectKernelIndex      ; 3
   sta WSYNC
;--------------------------------------
.coarseMovePlayer
   dey                        ; 2
   bne .coarseMovePlayer      ; 2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda kernelSectionColor     ; 3
   asl                        ; 2
   sta COLUPF                 ; 3 = @11
   lda player2MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @20
   lda player1MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @29
   ldy objectColorIndex,x     ; 4
   lda objectColorArray,y     ; 4
   sta COLUP0                 ; 3 = @40
   ldy objectGraphicIndex     ; 3
   dec currentScanline        ; 5
   bpl DrawObjectsKernel      ; 2³
   sta WSYNC
;--------------------------------------
   lda INPT0                  ; 3         read the paddle controller
   bmi .readPlayer2PaddleValue; 2³        branch if capacitor not charged
   bit gameVariation          ; 3         check game variation
   bvs .readPlayer2PaddleValue; 2³        branch if one player game
   lda player1Color           ; 3
   sta COLUPF                 ; 3 = @16   color the player's depth indicator
   lda #0                     ; 2
   sta player1PaddleValue     ; 3
.readPlayer2PaddleValue
   sta WSYNC
;--------------------------------------
   lda INPT1                  ; 3         read the paddle controller
   bmi .jmpToDoneDrawingKernel; 2³        branch if capacitor not charged
   lda player2Color           ; 3
   sta COLUPF                 ; 3 = @11   color the player's depth indicator
   lda #0                     ; 2
   sta player2PaddleValue     ; 3
.jmpToDoneDrawingKernel
   sta WSYNC
;--------------------------------------
   jmp DoneDrawingKernel      ; 3
   
DrawObjectsKernel SUBROUTINE
   dec numPlayerKernelSections; 5 = @56   decrement player kernel section value
   bpl DrawObjects            ; 2³
   lda numPlayerKernelSections; 3         get current player kernel section value
   cmp #<-1                   ; 2
   bne .checkToDrawCanyonKernel;2³
   sta CXCLR                  ; 3 = @68   clear all collision registers
.checkToDrawCanyonKernel
   lda gameVariation          ; 3         get game variation
   bpl DrawCanyonKernel       ; 2³        branch if CANYON_BOMBER game
   dec kernelSectionColor     ; 5 = @76
DrawObjects
   lda kernelSectionColor     ; 3
   asl                        ; 2
   sta COLUBK                 ; 3
.drawObjectsLoop
   lda ObjectGraphics,y       ; 4
   sta GRP0                   ; 3
   lda kernelSectionColor     ; 3
   asl                        ; 2
   eor kernelSectionColor     ; 3
   eor #$40                   ; 2
   tax                        ; 2
   lda numPlayerKernelSections; 3         get current player kernel section value
   bpl .colorDepthIndicator   ; 2³        branch if still drawing player objects
   lda INPT0                  ; 3         read player 1 paddle value
   and #$80                   ; 2         keep D7 value
   cmp kernelPlayer1PaddleValue;3         compare with current player 1 paddle value
   sta kernelPlayer1PaddleValue;3         set new player 1 paddle value
   beq .readPlayer2PaddleValue; 2³        branch if value didn't change
   bit gameVariation          ; 3         check game variation
   bvs .colorDepthIndicator   ; 2³        branch if one player game
   ldx player1Color           ; 3
   lda currentScanline        ; 3
   sta player1PaddleValue     ; 3
   jmp .colorDepthIndicator   ; 3
   
.readPlayer2PaddleValue
   lda INPT1                  ; 3         read player 2 paddle value
   and #$80                   ; 2         keep D7 value
   cmp kernelPlayer2PaddleValue;3         compare with current player 2 paddle value
   sta kernelPlayer2PaddleValue;3         set new player 2 paddle value
   beq .colorDepthIndicator   ; 2³        branch if value didn't change
   ldx player2Color           ; 3
   lda currentScanline        ; 3
   sta player2PaddleValue     ; 3
.colorDepthIndicator
   sta WSYNC
;--------------------------------------
   pla                        ; 4
   pla                        ; 4
   txa                        ; 2
   eor kernelSectionColor     ; 3
   eor #$40                   ; 2
   sta COLUPF                 ; 3 = @18
   iny                        ; 2
   lda player2MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @29
   lda player1MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @38
   dec currentScanline        ; 5
   tya                        ; 2
   and #7                     ; 2
   bne .drawObjectNextScanline; 2³
   jmp PrepareToDrawNextObject; 3
   
.drawObjectNextScanline
   sta WSYNC
;--------------------------------------
   jmp .drawObjectsLoop       ; 3
   
DrawCanyonKernel
   lda #QUAD_SIZE             ; 2
   sta NUSIZ0                 ; 3
   ldy objectColorArray + 3   ; 3
.drawCanyonLoop
   stx WSYNC
;--------------------------------------
   sty COLUPF                 ; 3 = @03
   lda CanyonSideGraphics - 15,x; 4
   sta GRP0                   ; 3 = @10
   sta GRP1                   ; 3 = @13
   lda leftPF0Bricks - 15,x   ; 4
   sta PF0                    ; 3 = @20
   lda leftPF1Bricks - 15,x   ; 4
   sta PF1                    ; 3 = @27
   lda leftPF2Bricks - 15,x   ; 4
   sta PF2                    ; 3 = @34
   lda rightPF0Bricks - 15,x  ; 4
   sta PF0                    ; 3 = @41
   lda rightPF1Bricks - 15,x  ; 4
   sta PF1                    ; 3 = @48
   lda rightPF2Bricks - 15,x  ; 4
   sta PF2                    ; 3 = @55
   pla                        ; 4
   pla                        ; 4
   lda leftPF0Bricks - 15,x   ; 4
   sta PF0                    ; 3 = @70
   lda leftPF1Bricks - 15,x   ; 4
;--------------------------------------
   sta PF1                    ; 3 = @01
   lda leftPF2Bricks - 15,x   ; 4
   sta PF2                    ; 3 = @08
   lda player2MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @17
   lda player1MissileVertPos  ; 3
   cmp currentScanline        ; 3
   php                        ; 3 = @26
   lda rightPF0Bricks - 15,x  ; 4
   sta PF0                    ; 3 = @33
   dec currentScanline        ; 5
   lda rightPF1Bricks - 15,x  ; 4
   sta PF1                    ; 3 = @49
   lda rightPF2Bricks - 15,x  ; 4
   sta PF2                    ; 3 = @56
   lda currentScanline        ; 3
   beq DoneDrawingKernel      ; 2³
   and #3                     ; 2
   bne .drawCanyonLoop        ; 2³
   inx                        ; 2
   lda BrickColorTable - 15,x ; 4
   eor colorEOR               ; 3
;--------------------------------------
   and hueMask                ; 3 = @01
   tay                        ; 2
   lda #0                     ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   jmp .drawCanyonLoop        ; 3

DoneDrawingKernel
   sta WSYNC
;--------------------------------------
   lda canyonColor            ; 3
   sta COLUBK                 ; 3 = @06
   sta COLUPF                 ; 3 = @09
   lda gameVariation          ; 3         get game variation
   bmi .endDrawingKernel      ; 2³        branch if SEA_BOMBER game
   ldx #6                     ; 2
.skipScanlineLines
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .skipScanlineLines     ; 2³
.endDrawingKernel
   ldx currentPlayerNumber    ; 3         get current active player number
   lda INPT0,x                ; 4         read paddle for active player
   bpl Overscan               ; 2³
   lda #0                     ; 2
   sta paddleValues,x         ; 4         clear active player paddle value
Overscan
   ldx #$FF                   ; 2
   txs                        ; 2         set the stack to the beginning
   jsr ClearGraphicRegisters  ; 6
   sta ENAM0                  ; 3
   sta ENAM1                  ; 3
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   lda #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta VSYNC                        ; start vertical sync (i.e. D1 = 1)
   sta TIM8T
   inc frameCount                   ; increment frame count
   bne .vsyncWaitTime
   inc colorCycleMode
   bne .vsyncWaitTime
   lda #$01
   sta gameState
.vsyncWaitTime
   lda INTIM
   bne .vsyncWaitTime
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (i.e. D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   lda selectDebounce               ; get select debounce value
   bne .reduceSelectDebounce        ; reduce value if not zero 
   lda SWCHB                        ; read console switches
   and #SELECT_MASK
   bne .checkForResetPressed        ; branch if SELECT not pressed
   lda #$08
   sta AUDF0
   lda #$0C
   sta AUDC0
   inc gameSelection                ; increment game selection
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION + 1      ; see if maximum game selection has been reached
   bne .setGameSelection            ; branch if maximum not reached
   lda #MIN_GAME_SELECTION          ; set to minimum game selection value
.setGameSelection
   sta gameSelection
   lda #SELECT_DELAY
   sta selectDebounce
   lda #SHOW_GAME_SELECTION
   sta gameState                    ; set game state to show game selection
   jmp InitializeGame
   
.reduceSelectDebounce
   dec selectDebounce               ; reduce select debounce value
   lda SWCHB                        ; read console switches
   and #SELECT_MASK
   beq .checkForResetPressed        ; branch if SELECT pressed
   lda #0
   sta selectDebounce               ; reset select debounce value
.checkForResetPressed
   lda SWCHB                        ; read console switches
   and #RESET_MASK
   bne .resetNotPressed             ; branch if RESET not pressed
   sta AUDC0
   lda #GAME_IN_PROGRESS
   sta gameState                    ; set game state to GAME_IN_PROGRESS
   jmp InitializeGame
   
.resetNotPressed
   lda #$00
   sta AUDC0
   sta AUDC1
   lda SWCHA                        ; read fire buttons
   sta fireButtonValues             ; save fire button values
   lda SWCHB                        ; read console switches
   sta difficultySettingValues      ; save value for difficulty values
   lda frameCount                   ; get current frame count
   and #1                           ; alternate current player each frame
   sta currentPlayerNumber
   tax                              ; move current player number to x
   asl                              ; multiply current player number by 2
   ora #$0C
   sta AUDF0
   cpx #1                           ; check if second player is active this frame
   bne CheckForComputerDroppingBomb ; branch if first player active this frame
   lsr difficultySettingValues      ; shift player 2 difficulty value to D6
   asl fireButtonValues             ; shift player 2 fire button value to D7
CheckForComputerDroppingBomb
   lda gameState                    ; get current game state
   cmp #GAME_IN_PROGRESS            ; check if game currently being played
   bne .jmpToDoneDetermineToDropMissile; branch if game not being played
   ldy ObjectAttributesPointerTable,x
   lda objectAttributes,y
   beq .doneDetermineToDropMissile
   lda gameVariation                ; get game variation
   and #BOMB_ATTRIBUTE_MASK         ; keep BOMB_ATTRIBUTE value
   bne .determineToDropComputerBomb ; branch if UNLIMITED_BOMBS
   lda playerMissCount,x            ; get number of misses for active player
   beq .doneDetermineToDropMissile  ; branch if no missiles left
.determineToDropComputerBomb
   bit gameVariation                ; check game variation
   bvc DetermineToDropMissile       ; branch if two player game
   bit SWCHB                        ; check console switches
   bvs .skipSetMissCountForSingleGame; branch if player 0 difficulty is set to PRO
   lda player2MissCount             ; get number of misses for player 2
   sta player1MissCount             ; move them to number of misses for computer
.skipSetMissCountForSingleGame
   txa                              ; move current player number to accumulator
   bne DetermineToDropMissile       ; branch if current player is player 2
   lda player1MissileVertPos        ; get player 1's missile vertical position
   bpl .doneDetermineToDropMissile
   lda frameCount                   ; get current frame count
   and #$1F
   jmp .setDepthIndicatorVertPos
   
DetermineToDropMissile
   lda fireButtonValues             ; get fire button values
   and #$80                         ; keep D7
   cmp playerFireButtonValues,x
   beq .doneDetermineToDropMissile  ; branch if player fire button value didn't change
   sta playerFireButtonValues,x     ; set new fire button value for player
   cmp #$00
.jmpToDoneDetermineToDropMissile
   bne .doneDetermineToDropMissile
   bit difficultySettingValues      ; check active player's difficulty setting
   bvc .determineDepthIndicatorVertPos; branch if set to AMATEUR setting
   lda missileVertPos,x             ; get current player's missile vertical position
   bpl .doneDetermineToDropMissile  ; branch if missile already launched
.determineDepthIndicatorVertPos
   lda paddleValues,x
.setDepthIndicatorVertPos
   sta depthIndicatorVertPos,x
   lda #0
   sta numMissileBricksHit,x
   sta colorCycleMode               ; reset color cycle timer
   lda #$08
   sta AUDC0
   sta RESMP0,x                     ; unlock missile from player (i.e. D1 = 0)
   ldy initMissileVertPosIndex,x
   lda InitMissileVerticalPosition,y
   sta missileVertPos,x             ; set missile init vertical position
   lda ObjectAttributesPointerTable,y
   tay
   lda objectHorizPos,y             ; get the player's horizontal position
   clc
   adc #5                           ; increase value by 5
   sta missileHorizPos,x            ; set missile init horizontal position
   lda objectAttributes,y           ; get player's attributes value
   and #DIRECTION_MASK | OBJECT_SPEED;keep direction and speed
   tay
   lda gameVariation                ; get game variation
   bpl .setMissileAttributeValue    ; branch if CANYON_BOMBER game
   ldy #0                           ; set missile to have no horizontal movement
.setMissileAttributeValue
   sty missileAttributes,x
.doneDetermineToDropMissile
   lda player1Attributes            ; get player 1 attributes
   bne .determineMissileCollisions  ; branch if player still active on screen
   lda player2Attributes            ; get player 2 attributes
   bne .determineMissileCollisions  ; branch if player still active on screen
   lda player1MissileVertPos        ; get player 1 missile vertical position
   bpl .determineMissileCollisions  ; branch if missile active on screen
   lda player2MissileVertPos        ; get player 2 missile vertical position
   bpl .determineMissileCollisions  ; branch if missile active on screen
   ldx #1
.setPlayerNewAttributesLoop
   ldy ObjectAttributesPointerTable,x
   lda gameState                    ; get current game state
   cmp #GAME_IN_PROGRESS            ; check if game is currently being played
   bne .setPlayerNewSprite          ; branch if game not being played
   lda numMissileBricksHit,x
   bpl .setPlayerNewSprite
   jsr RegisterMissedTarget
.setPlayerNewSprite
   lda frameCount                   ; get current frame count
   eor player1Score + 1
   lsr
   eor player2Score + 1
   and #$3A
   clc
   adc #$11
   sta player1Attributes
   eor #DIRECTION_MASK
   sta player2Attributes
   stx tmpObjectId
   ldx #XMIN
   lda objectAttributes,y           ; get the object's attributes
   and #DIRECTION_MASK              ; keep the direction
   beq .setPlayerNewHorizontalPosition; branch if object traveling to the right
   ldx #XMAX - 14                   ; place object on far right side of screen
.setPlayerNewHorizontalPosition
   stx player1HorizPos,y
   ldx tmpObjectId
   lda frameCount                   ; get current frame count
   lsr
   lsr
   lsr
   and #1
   sta player1ColorIndex
   sta player1InitMissileVertPosIdx
   eor #$01
   sta player2ColorIndex
   sta player2InitMissileVertPosIdx
   lda numMissileBricksHit,x
   ora #$80
   sta numMissileBricksHit,x
   dex
   bpl .setPlayerNewAttributesLoop
.determineMissileCollisions
   ldx currentPlayerNumber          ; get current active player number
   lda gameVariation                ; get game variation
   bmi CheckForMissileHittingShip   ; branch if SEA_BOMBER game
   jmp CheckForMissileHittingBricks
   
CheckForMissileHittingShip
   inc numMissileBricksHit,x
   ldx #<[seaShip5Attributes - seaShipAttributes]
.spawnNewShipLoop
   lda seaShipAttributes,x          ; get sea ship attributes
   bne .checkToStartNextNewShip     ; branch if ship exists in this area
   lsr player1NumMissileBricksHit
   bcc .checkToStartNextNewShip
   lda player2NumMissileBricksHit
   and #$3A
   clc
   adc #$51
   sta seaShipAttributes,x
   ldy #XMIN
   and #DIRECTION_MASK              ; keep the direction
   beq .setShipNewHorizontalPosition; branch if ship traveling to the right
   ldy #XMAX - 14
.setShipNewHorizontalPosition
   sty seaShipHorizPos,x
   lda #2
   sta seaShipColorIndex,x
   rol player2NumMissileBricksHit
.checkToStartNextNewShip
   txa
   sec
   sbc #5
   tax
   bpl .spawnNewShipLoop
   ldx currentPlayerNumber          ; get current active player number
   bne .checkToExplodeMissile       ; branch if player 2 is active
   bit gameVariation                ; check game variation
   bvc .checkToExplodeMissile       ; branch if two player game
   bit difficultySettingValues      ; check active player's difficulty setting
   bvs .checkToExplodeMissile       ; branch if set to PRO setting
   bit CXM0P                        ; check player 1 missile collisions
   bvs .setMissileExplodingVertPos  ; branch if missile hit a ship
.checkToExplodeMissile
   lda depthIndicatorVertPos,x
   bpl .checkForMissileAtExplodingTarget
   lda #$00
.checkForMissileAtExplodingTarget
   cmp missileVertPos,x
   bne .doneCheckingForHittingShip
.setMissileExplodingVertPos
   lda missileVertPos,x             ; get player's missile vertical position
   sta depthIndicatorVertPos,x
   jsr LockMissileToPlayer
   lda #8
   sta depthChargeExplosionSound
   lda depthIndicatorVertPos,x      ; get missile vertical position
   clc
   adc #2                           ; increment value by 2
   ldy #7
.determineMissileKernelSection
   dey
   sec
   sbc #H_OBJECT + 1
   bpl .determineMissileKernelSection
   sty pointsValue                  ; save kernel section of missile for point value
   lda ObjectAttributesPointerTable,y
   tay
   lda objectHorizPos,y             ; get the object's horizontal position
   adc #4                           ; increase value by 4
   sbc missileHorizPos,x            ; subtract missile horizontal position
   bpl .determineMissileHitShip
   eor #$FF                         ; negate value
.determineMissileHitShip
   jsr DivideBy16
   bne .doneCheckingForHittingShip
   lda objectAttributes,y           ; get the object's attribute value
   bmi .doneCheckingForHittingShip  ; branch if hit already recorded for ship
   beq .doneCheckingForHittingShip  ; branch if ship removed from playfield
   ora #SEA_SHIP_HIT                ; show ship has been hit
   and #SEA_SHIP_HIT | OBJECT_SIZE  ; keep this hit flag and ship size
   sta objectAttributes,y
   stx objectColorIndex,y           ; set object color to color of player that hit it
   asl pointsValue                  ; multiply value by 16
   asl pointsValue
   asl pointsValue
   asl pointsValue
   jsr IncrementScore
   lda #15
   sta depthChargeExplosionSound
.doneCheckingForHittingShip
.jmpToMoveObjects
   jmp MoveObjects
   
CheckForMissileHittingBricks
   lda missileVertPos,x             ; get player's missile vertical position
   bmi .checkMissileCollisions      ; branch if out of range
   lsr                              ; divide value by 2
   sta missileDropFrequency
   lda #31
   sec
   sbc missileDropFrequency
   sta AUDF1
   lda #4
   sta AUDC1
.checkMissileCollisions
   lda CXM0P,x                      ; check missile collisions
   and #$C0                         ; keep collision register values
   beq .checkToDropBricks           ; branch if missile didn't hit side of canyon
   jsr DisableMissile
.checkToDropBricks
   lda gameVariation                ; get game variation
   and #SUSPEND_BRICKS_MASK         ; keep SUSPEND_BRICKS_MASK value
   bne .skipBrickDropRoutine        ; branch if BRICKS_SUSPEND
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 4
   lsr
   and #7                           ; make value 7 <= a <= 0
   sta brickDroppingFrequency
   beq .skipBrickDropRoutine
   ldy #40
.dropBricksLoop
   tya
   clc
   adc brickDroppingFrequency
   tax
   lda bricks - 1,x
   sta tmpBrickValue
   lda bricks,x
   and bricks - 1,x
   sta bricks - 1,x
   lda bricks,x
   ora tmpBrickValue
   sta bricks,x
   tya
   sec
   sbc #8
   tay
   bpl .dropBricksLoop
.skipBrickDropRoutine
   ldx currentPlayerNumber          ; get current active player number
   lda missileVertPos,x             ; get player's missile vertical position
   bmi .jmpToMoveObjects
   cmp #MISSILE_YMIN
   bcc .jmpToMoveObjects
   cmp #BRICK_YMAX
   bcs .jmpToMoveObjects
   ldy missileHorizPos,x            ; get the missile's horizontal position
   tya
   clc
   adc #16                          ; increment value by 16
   cpy #(XMAX + 1) / 2
   bcc .determineBrickMaskingBitIndex; branch if missile is on the left side
   clc
   adc #16                          ; increase value by 16 for right side
.determineBrickMaskingBitIndex
   lsr                              ; divide value by 4
   lsr
   sta missileHorizPosDiv4          ; save value for determining row index
   and #7
   sta brickMaskingBitIndex         ; set brick masking bit index
   lda missileHorizPosDiv4          ; get missile horiz position divided by 4 value
   lsr                              ; divide value by 8 so now the horizontal position
   lsr                              ; is divided by 32
   lsr
   sta brickRowIndex                ; save brick row index pointer
   and #1                           ; keep D0 value
   tay                              ; save it y register for later
   lda brickRowIndex                ; get the brick row index
   cmp #3
   bcc .determineToReverseMaskingBits
   iny
.determineToReverseMaskingBits
   sty shouldFlipMaskingBits        ; save to see if we should flip masking bits
   ldy brickMaskingBitIndex
   lda BrickMaskingBits,y
   sta brickMaskingValue
   lda shouldFlipMaskingBits        ; get value to flip masking bits
   and #1                           ; keep D0 value
   beq .removeBricks                ; if not odd then don't flip bits
   ldy #7                           ; reverse bits for reverse PF graphic bits
.exchangeBrickMaskingBits
   lsr brickMaskingValue
   rol
   dey
   bpl .exchangeBrickMaskingBits
   sta brickMaskingValue
.removeBricks
   lda missileVertPos,x             ; get vertical position of missile
   sta pointsValue                  ; save for later
   lda #BRICK_YMAX
   sec
   sbc pointsValue                  ; subtract missile vertical position
   lsr                              ; divide value by 4
   lsr
   sta pointsValue
   asl brickRowIndex                ; multiply brick row index times 5
   asl brickRowIndex
   asl brickRowIndex
   clc
   adc brickRowIndex
   tay
   lda bricks,y                     ; get brick value at location
   and brickMaskingValue            ; and with brick masking bit value
   beq MoveObjects                  ; branch if brick already removed
   lda bricks,y                     ; get brick value at location
   eor brickMaskingValue            ; flip bits to remove brick from array
   sta bricks,y                     ; set new brick value
   inc numMissileBricksHit,x
   lda #$04
   sta AUDC0
   lda numMissileBricksHit,x
   cmp #MAX_BRICKS_HIT_PER_MISSILE
   bne .scoreForHittingBricks
   jsr LockMissileToPlayer
.scoreForHittingBricks
   lsr pointsValue
   inc pointsValue
   jsr IncrementScore
   inc numBricksHit                 ; increment the number of bricks that were hit
   bne MoveObjects
   jmp ReinstateBricks
   
MoveObjects
   ldx #<[seaShip1Attributes - objectVariables + 1]
   ldy #3
   lda gameVariation                ; get game variation
   bpl .setNumberOfPlayerKernelSections; branch if CANYON_BOMBER
   ldy #2
   ldx #<[seaShip6Attributes - objectVariables + 1]
.setNumberOfPlayerKernelSections
   sty numPlayerKernelSections
.moveObjectLoop
   lda objectHorizPos,x             ; get the object's horizontal position
   clc
   adc #1                           ; increment value by 1
   jsr CalculateHorizPosition       ; calculate object's fine and coarse position value
   sta objectFineMotionValues,x     ; set object fine motion value
   sty objectCoarseMotionValues,x   ; set object coarse position value
   lda objectAttributes,x           ; get object attributes
   and #OBJECT_SPEED                ; keep the object's speed value
   and frameCount                   ; and with current frame count
   bne .checkIfObjectExploding      ; branch if object not to move this frame
   lda objectAttributes,x           ; get player attribute values
   jsr DetermineOffsetDirection     ; determine direction offset of player
   adc objectHorizPos,x             ; adjust player position
   sta objectHorizPos,x             ; set new player position value
   bpl .checkIfObjectExploding
   lda objectHorizPos,x             ; get player horizontal position
   cmp #XMAX - 13
   bcc .checkIfObjectExploding
   lda #$00
   sta objectAttributes,x
.checkIfObjectExploding
   lda objectAttributes,x
   bpl .moveNextObject
   lda depthChargeExplosionSound
   cmp #1
   bne .moveNextObject
   lda #0
   sta objectAttributes,x
.moveNextObject
   txa                              ; move index to accumualtor
   sec
   sbc #5                           ; reduce value by 5
   tax
   bpl .moveObjectLoop
   ldx currentPlayerNumber          ; get current active player number
   lda missileVertPos,x             ; get player's missile vertical position
   bmi CheckToPlayDepthChargeExplosion
   cmp #44
   bcs .moveMissileDown
   lda gameVariation                ; get game variation
   bpl .moveMissileDown             ; branch if CANYON_BOMBER
   lda frameCount                   ; get current frame count
   and #2
   bne .determineToMoveMissileHoriz
.moveMissileDown
   dec missileVertPos,x
.determineToMoveMissileHoriz
   lda missileAttributes,x          ; get missile attributes
   and #MISSILE_SPEED               ; keep missile speed
   and frameCount                   ; and with current frame count
   bne .checkToDisableMissile       ; branch if not time to move missile horizontally
   lda missileAttributes,x          ; get missile attributes
   jsr DetermineOffsetDirection     ; determine direction offset of missile
   adc missileHorizPos,x            ; adjust missile horizontal position
   sta missileHorizPos,x            ; set new missile position value
   bpl .checkToDisableMissile
   lda missileHorizPos,x            ; get missile horizontal position
   cmp #XMAX - 1
   bcs .disableMissileForMiss
.checkToDisableMissile
   lda missileVertPos,x             ; get missile vertical position
   bpl CheckToPlayDepthChargeExplosion; branch if missile still in range
.disableMissileForMiss
   jsr DisableMissile
CheckToPlayDepthChargeExplosion
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs MoveMissilesAndRightSideCanyon; branch if an odd frame count
   lda depthChargeExplosionSound
   beq MoveMissilesAndRightSideCanyon
   lda depthChargeExplosionSound
   sta AUDV1
   lda #16
   sbc depthChargeExplosionSound
   sta AUDF1
   lda frameCount                   ; get current frame count
   and #3
   ora #8
   sta AUDC1
   dec depthChargeExplosionSound
MoveMissilesAndRightSideCanyon
   ldx #3
.positionMissileHorizontallyLoop
   lda missileHorizPos - 2,x
   jsr CalculateHorizPosition
   sta HMM0 - 2,x
   jsr CoarseMoveObject
   dex
   cpx #1
   bne .positionMissileHorizontallyLoop
   lda #XMAX - 33
   jsr CalculateHorizPosition       ; calculate right canyon boarder fine motion
   sta HMP1                         ; set player 1 object fine motion
   jsr CoarseMoveObject             ; coarse move right canyon border
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; move objects horizontally
   ldy #3
   ldx #15
   lda gameState                    ; get current game state
   bne SetDigitGraphicsPointers     ; branch if not to show game selection
   lda #<[(Blank - NumberFonts) / H_SCORE] << 4 | [(Blank - NumberFonts) / H_SCORE]
   sta player1Score + 1             ; set score values to point to Blank
   sta player2Score
   sta player2Score + 1
   lda gameSelection                ; get current game selection
   and #$0F                         ; keep lower nybbles
   ora #<[(Blank - NumberFonts) / H_SCORE] << 4
   sta player1Score
SetDigitGraphicsPointers
.setDigitPointersLoop
   lda playerScores,y               ; get the player score value
   jsr DivideBy16                   ; shift upper nybbles to lower nybbles
   jsr DigitToBCD
   dex
   dex
   lda playerScores,y
   jsr DigitToBCD
   dex
   dex
   dey
   bpl .setDigitPointersLoop
   sta HMCLR                        ; clear horizontal positioning
   sta CXCLR                        ; clear all collision flags
   jmp MainLoop
   
DigitToBCD
   and #$0F                         ; mask upper nybbles
   sta tempDigitValue               ; save value for later
   asl tempDigitValue               ; multiply value by 4
   asl tempDigitValue
   clc                              ; add in original so value is mutliplied by 5
   adc tempDigitValue
   adc #<NumberFonts
   sta digitGraphicPointers - 1,x
   lda #>NumberFonts
   sta digitGraphicPointers,x
   rts

ClearGraphicRegisters
   lda #0                     ; 2
   sta GRP0                   ; 3
   sta GRP1                   ; 3
SetPFGraphicRegisters
   sta PF0                    ; 3
   sta PF1                    ; 3
   sta PF2                    ; 3
   rts                        ; 6

DisableMissile
   lda numMissileBricksHit,x
   bne LockMissileToPlayer
RegisterMissedTarget
   lda playerMissCount,x
   beq LockMissileToPlayer
   lda #$0C
   sta AUDC0
   lsr playerMissCount,x
LockMissileToPlayer
   lda #$FF
   sta missileVertPos,x
   lda #LOCK_MISSILE
   sta RESMP0,x
   rts

;
; Horizontal reset starts at cycle 8 (i.e. pixel 24). The object's position is
; incremented by 55 to push their pixel positioning to start at cycle 21 (i.e.
; pixel 63) with an fine adjustment of -5 to start objects at pixel 58.
;
CalculateHorizPosition
   clc                              ; clear carry
   adc #55                          ; increment horizontal position value by 55
   pha                              ; push result to stack
   lsr                              ; divide horizontal position by 16
   lsr
   lsr
   lsr
   tay                              ; division by 16 is course movement value
   pla                              ; pull horizontal position from stack
   and #$0F                         ; mask upper nybbles
   sty div16Value                   ; save division by 16 value
   clc
   adc div16Value
   cmp #15
   bcc .determineFineMotionValue
   sbc #15
   iny
.determineFineMotionValue
   cmp #8
   eor #$0F
   bcs .setHorizFineMotionValue
   adc #1
   dey
.setHorizFineMotionValue
   iny
   asl
   asl
   asl
   asl
   rts

CoarseMoveObject
   sty WSYNC                        ; wait for next scan line
.coarseMoveObjectLoop
   dey                              ; decrement coarse move value
   bne .coarseMoveObjectLoop
   sta RESP0,x                      ; set object's coarse horizontal position
   rts

Waste16Cycles
   lsr
DivideBy16
   lsr
   lsr
   lsr
   lsr
   rts

DetermineOffsetDirection
   and #$0F
   beq .doneDetermineOffsetDirection
   ldy #1                           ; assume object is traveling to the right
   and #REFLECT                     ; keep the REFLECT attribute of the object
   beq .setOffsetDirection
   ldy #<-1                         ; object is traveling to the right
.setOffsetDirection
   tya
.doneDetermineOffsetDirection
   clc
   rts

IncrementScore
   txa                              ; move player number to accumulator
   asl                              ; multiply player number by 2
   tax                              ; set score index
   lda playerScores + 1,x
   sed                              ; set to decimal mode
   clc                              ; clear carry
   adc pointsValue
   sta playerScores + 1,x
   lda #$00
   adc playerScores,x
   sta playerScores,x
   cld                              ; clear decimal mode
   lda gameVariation                ; get game variation
   and #BOMB_ATTRIBUTE_MASK         ; keep BOMB_ATTRIBUTE_MASK value
   beq .doneIncrementScore          ; branch if LIMITED_BOMBS
   lda playerScores,x
   and #<~GAME_IN_PROGRESS
   beq .doneIncrementScore
   sta gameState                    ; set to GAME OVER and show final score
.doneIncrementScore
   ldx currentPlayerNumber          ; get current active player number
   rts

InitializeGame
   ldx #$FF
   txs                              ; reset stack to the beginning
   stx REFP1                        ; REFLECT GRP0 (i.e. D3 = 1)
   stx hueMask
   ldx gameSelection                ; get current game selection
   lda GameVariationTable - 1,x     ; read game variation value from table
   sta gameVariation                ; set game variation value
   lda #0
   sta colorCycleMode
   sta colorEOR
   sta player1Score
   sta player1Score + 1
   sta player2Score
   sta player2Score + 1
   tay
   lda gameVariation                ; get game variation
   and #BOMB_ATTRIBUTE_MASK         ; keep BOMB_ATTRIBUTE_MASK value
   bne .setInitMissileMissCount     ; branch if UNLIMITED_BOMBS
   ldy #$3F
.setInitMissileMissCount
   sty player1MissCount
   sty player2MissCount
   ldx #<[seaShip7ObjectVariables - objectVariables]
.initObjectVariables
   lda #0
   sta objectHorizPos,x
   sta objectAttributes,x
   sta objectColorIndex,x
   txa
   sec
   sbc #5
   tax
   bpl .initObjectVariables
ReinstateBricks
   ldx #1
.disableMissileLoop
   jsr LockMissileToPlayer
   lda #$00
   sta AUDC1
   lda #4
   sta numMissileBricksHit,x
   sta AUDV0,x
   dex
   bpl .disableMissileLoop
   ldx #47
   lda gameVariation                ; get game variation
   bmi .doneReinstateBricks         ; branch if SEA_BOMBER
   lda #2
   sta seaShip2ColorIndex
.resetBricks
   lda #$FF
   sta bricks,x
   dex
   bpl .resetBricks
   inx                              ; x = 0
   stx numBricksHit                 ; reset the number of bricks that were hit
.doneReinstateBricks
   ldx currentPlayerNumber          ; get current active player number
   jmp MoveObjects
   
NumberFonts
zero   
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
one
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
two
   .byte $E7 ; |XXX..XXX|
   .byte $81 ; |X......X|
   .byte $E7 ; |XXX..XXX|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
three
   .byte $E7 ; |XXX..XXX|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
four
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $81 ; |X......X|
five
   .byte $E7 ; |XXX..XXX|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
   .byte $81 ; |X......X|
   .byte $E7 ; |XXX..XXX|
six
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
   .byte $81 ; |X......X|
   .byte $E7 ; |XXX..XXX|
seven
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
eight
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
nine
   .byte $E7 ; |XXX..XXX|
   .byte $24 ; |..X..X..|
   .byte $E7 ; |XXX..XXX|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
Blank
ObjectGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Bomber
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $86 ; |X....XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
Jet
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $0F ; |....XXXX|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
Biplane
   .byte $00 ; |........|
   .byte $BE ; |X.XXXXX.|
   .byte $88 ; |X...X...|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $08 ; |....X...|
   .byte $3E ; |..XXXXX.|
   .byte $00 ; |........|
Helicopter
   .byte $1F ; |...XXXXX|
   .byte $84 ; |X....X..|
   .byte $CF ; |XX..XXXX|
   .byte $7D ; |.XXXXX.X|
   .byte $0D ; |....XX.X|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
Submarine
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
Battleship
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $52 ; |.X.X..X.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
Destroyer
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $14 ; |...X.X..|
   .byte $7F ; |.XXXXXXX|
   .byte $FA ; |XXXXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|

CanyonSideGraphics
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FF ; |XXXXXXXX|
   
ObjectSizeTable
   .byte ONE_COPY, DOUBLE_SIZE, ONE_COPY, ONE_COPY
   .byte ONE_COPY, ONE_COPY, DOUBLE_SIZE, DOUBLE_SIZE
   
BrickMaskingBits
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $04 ; |.....X..|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $20 ; |..X.....|
   .byte $40 ; |.X......|
   .byte $80 ; |X.......|
   
ObjectAttributesPointerTable
   .byte <player1ObjectVariables - objectVariables
   .byte <player2ObjectVariables - objectVariables
   .byte <seaShip1ObjectVariables - objectVariables
   .byte <seaShip2ObjectVariables - objectVariables
   .byte <seaShip3ObjectVariables - objectVariables
   .byte <seaShip4ObjectVariables - objectVariables
   .byte <seaShip5ObjectVariables - objectVariables
   .byte <seaShip6ObjectVariables - objectVariables
   .byte <seaShip7ObjectVariables - objectVariables
   
GameVariationTable
   .byte CANYON_BOMBER|NUM_PLAYERS_ONE|BRICKS_FALL   |LIMITED_BOMBS
   .byte CANYON_BOMBER|NUM_PLAYERS_TWO|BRICKS_FALL   |LIMITED_BOMBS   
   .byte CANYON_BOMBER|NUM_PLAYERS_ONE|BRICKS_SUSPEND|LIMITED_BOMBS
   .byte CANYON_BOMBER|NUM_PLAYERS_TWO|BRICKS_SUSPEND|LIMITED_BOMBS
   .byte CANYON_BOMBER|NUM_PLAYERS_TWO|BRICKS_FALL   |UNLIMITED_BOMBS
   .byte CANYON_BOMBER|NUM_PLAYERS_TWO|BRICKS_SUSPEND|UNLIMITED_BOMBS
   .byte SEA_BOMBER   |NUM_PLAYERS_ONE|BRICKS_FALL   |UNLIMITED_BOMBS
   .byte SEA_BOMBER   |NUM_PLAYERS_TWO|BRICKS_FALL   |UNLIMITED_BOMBS
   
ObjectColorTable
.blackAndWhite
   .byte BLACK + 5
   .byte BLACK + 9
   .byte BLACK
.color
   .byte ORANGE + 6
   .byte YELLOW + 8
   .byte BLACK + 4
   
BrickColorTable
   .byte ORANGE + 12
   .byte ORANGE + 9
   .byte YELLOW + 11
   .byte YELLOW + 8
   .byte ORANGE + 6
   .byte ORANGE + 4
   .byte BLUE + 4
   .byte BLUE + 2
   
   .org ROM_BASE + 2048 - 4, 0      ; 2K ROM
   .word Start                      ; RESET vector
   
InitMissileVerticalPosition
   .byte 56, 47                     ; BRK vector
