   LIST OFF
; ***  P L A Q U E  A T T A C K  ***
; Copyright 1983 Activision, Inc
; Programmer: Steve Cartwright

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: February 20, 2020
;
;  *** 123 BYTES OF RAM USED 5 BYTES FREE
;  ***  29 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1983, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================
;
; - Steve Cartwright's third VCS game with Activision
; - Game was completed in 6 weeks
;     - developed because another Activision game was behind schedule
; - Borrows heavily from Megamania
; - Looks as though they planned to have 5 game options
; - PAL50 version ~17% slower than NTSC
; - screen is disabled when no player activity for
;     ~1:12 for NTSC and ~1:30 for PAL50

   processor 6502

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

VBLANK_TIME             = 53
OVERSCAN_TIME           = 35

   ELSE
   
VBLANK_TIME             = 85
OVERSCAN_TIME           = 62

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
PURPLE                  = $50
COBALT_BLUE             = $60
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
BLUE_2                  = BLUE
LT_BLUE                 = $90
GREEN                   = $C0
DK_GREEN                = $D0

COLOR_PLAYER1_TOOTHPASTE_TUBE = LT_BLUE + 10
COLOR_PLAYER2_TOOTHPASTE_TUBE = DK_GREEN + 6

COLOR_HOT_DOG           = BRICK_RED

   ELSE

YELLOW                  = $20
RED_ORANGE              = $20
GREEN                   = $30
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE                  = $70
BLUE                    = $B0
LT_BLUE                 = $C0
BLUE_2                  = $D0

COLOR_PLAYER1_TOOTHPASTE_TUBE = BLUE_2 + 10
COLOR_PLAYER2_TOOTHPASTE_TUBE = GREEN + 6

COLOR_HOT_DOG           = RED

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 8
H_LIVES                 = 10
H_COPYRIGHT             = 8
H_TOOTHPASTE_TUBE       = 22
H_KERNEL                = 104
H_TOOTHPASTE            = 8
H_TOOTH                 = 14
H_JUNK_FOOD             = 18
H_HAMBURGER             = 11
H_HOTDOG                = 8
H_FRIES                 = 13
H_STRAWBERRY            = 14
H_GUM_DROPS             = 14
H_DONUTS                = 9
H_CANDY_CANES           = 14
H_ICE_CREAM_CONES       = 14

SELECT_DELAY            = 30

MAX_JUNK_FOOD_SECTIONS  = 8

XMIN                    = 0
XMAX                    = 160

TOOTHPASTE_TUBE_YMIN    = 8
TOOTHPASTE_TUBE_YMAX    = 74
TOOTHPASTE_TUBE_XMIN    = 15
TOOTHPASTE_TUBE_XMAX    = 141

INIT_GAME_FRAME_DELAY   = 32
INCREMENT_LEVEL_FRAME_DELAY = 32
STARTING_NEW_WAVE_FRAME_DELAY = 48
SWAP_PLAYERS_FRAME_DELAY = 80
SWAP_VARIABLES_FRAME_DELAY = 16
TOOTH_PLACEMENT_SOUND_FRAME_DELAY = 16

INIT_TOOTHPASTE_TUBE_VERT_FACING_UP = TOOTHPASTE_TUBE_YMIN - 1
INIT_TOOTHPASTE_TUBE_VERT_FACING_DOWN = TOOTHPASTE_TUBE_YMAX

INIT_TOOTHPASTE_TUBE_HORIZ_POS = (XMAX / 2) - 1

TOOTHPASTE_YMAX         = 224

; SWCHA joystick bits:
MY_MOVE_RIGHT           = <(MOVE_RIGHT) >> 4
MY_MOVE_LEFT            = <(MOVE_LEFT) >> 4
MY_MOVE_DOWN            = <(MOVE_DOWN) >> 4
MY_MOVE_UP              = <(MOVE_UP) >> 4

; Toothpaste Tube facing values
TOOTHPASTE_TUBE_FACING_UP = 0 << 7
TOOTHPASTE_TUBE_FACING_DOWN = 1 << 7

; gameState status values
DEMO_MODE               = %10000000

; current wave status values
JUNK_FOOD_VERT_DIR_MASK = %10000000
TOOTH_DECAYING_MASK     = %01000000
SWAP_PLAYER_VARIABLES   = %00000100
ADVANCING_NEW_WAVE      = %00000010
STARTING_NEW_WAVE       = %00000001

MAX_TOOTH_PASTE_TUBE_ANIMATION_IDX = 11

MAX_TOOTH_DECAY_ANIMATION  = 4

MAX_RESERVED_TEETH      = 6
; wave time values
WAVE_TIME_ADVANCED      = 33
WAVE_TIME_BEGINNER      = 48

; object score values (BCD)
WAVE_01_POINTS          = $05
WAVE_02_POINTS          = $10
WAVE_03_POINTS          = $15
WAVE_04_POINTS          = $20
WAVE_05_POINTS          = $25
WAVE_06_POINTS          = $30
WAVE_07_POINTS          = $35
WAVE_08_POINTS          = $40

; arriving Junk Food values
NO_ARRIVING_JUNK_FOOD   = 1

JUNK_FOOD_MOVE_LEFT     = 0
JUNK_FOOD_MOVE_RIGHT    = 1

INIT_JUNK_FOOD_HORIZ_MOVE = JUNK_FOOD_MOVE_RIGHT << 3 | JUNK_FOOD_MOVE_LEFT << 2 | JUNK_FOOD_MOVE_RIGHT << 1 | JUNK_FOOD_MOVE_LEFT

;===============================================================================
; M A C R O S
;===============================================================================

;-------------------------------------------------------
; FILL_BOUNDARY byte#
; Original author: Dennis Debro (borrowed from Bob Smith / Thomas Jentzsch)
;
; Push data to a certain position inside a page and keep count of how
; many free bytes the programmer will have.
;
; eg: FILL_BOUNDARY 5, 234    ; position at byte #5 in page with $EA is byte filler
FREE_BYTES SET 0
.BYTES_TO_SKIP SET 0

   MAC FILL_BOUNDARY
      IF <. > {1}

.BYTES_TO_SKIP SET (256 - <.) + {1}

      ELSE

.BYTES_TO_SKIP SET (256 - <.) - (256 - {1})

      ENDIF

      REPEAT .BYTES_TO_SKIP

FREE_BYTES SET FREE_BYTES + 1

     .byte {2}

     REPEND

   ENDM
   
;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gameSelection           ds 1
frameCount              ds 1
randomSeed              ds 1
selectDebounce          ds 1
playerControlValues     ds 1
junkFoodGraphicPtrs     ds 2
junkFoodColorPtrs       ds 2
toothpasteTubeGraphPtrs ds 2
digitPointers           ds 12
colorCycleMode          ds 1
gameState               ds 1
copyrightScrollRate     ds 1
currentPlayerNumber     ds 1
lowerTeethNUSIZ         ds 4
upperTeethNUSIZ         ds 4
teethPatternIndexes     ds 2
;--------------------------------------
lowerTeethPatternIndex  = teethPatternIndexes
upperTeethPatternIndex  = lowerTeethPatternIndex + 1
toothDecayColors        ds 2
;--------------------------------------
lowerToothDecayColor    = toothDecayColors
upperToothDecayColor    = lowerToothDecayColor + 1
toothDecayHorizPos      ds 2
;--------------------------------------
lowerToothDecayHorizPos = toothDecayHorizPos
upperToothDecayHorizPos = lowerToothDecayHorizPos + 1
toothpasteVelocity      ds 1
topJunkFoodGraphicIndex ds 1
toothpasteTubeHorizPos  ds 1
toothpasteHorizPos      ds 1
removeTeethPattern      ds 1
decayingToothHorizPositionIndex ds 1
junkFoodHorizPos        ds 6
toothpasteTubeVertPos   ds 1
toothpasteVertPos       ds 1
currentPlayerVariables  ds 7
;--------------------------------------
bonusTeeth              = currentPlayerVariables
playerScore             = bonusTeeth + 1
currentWave             = playerScore + 3
toothPatternValues      = currentWave + 1
;--------------------------------------
lowerTeethValues        = toothPatternValues
upperTeethValues        = lowerTeethValues + 1
reservePlayerVariables  ds 7
;--------------------------------------
reservePlayerLives      = reservePlayerVariables
reservePlayerScore      = reservePlayerLives + 1
reservePlayerWave       = reservePlayerScore + 3
reservePlayerToothPattenValues = reservePlayerWave + 1
;--------------------------------------
reservePlayerLowerTeethValues = reservePlayerToothPattenValues
reservePlayerUpperTeethValues = reservePlayerLowerTeethValues + 1
junkFoodPatternIndex    ds 8
junkFoodHorizMovementValues ds 2
;--------------------------------------
arrivingJunkFoodHorizMovement = junkFoodHorizMovementValues
normalJunkFoodHorizMovement = arrivingJunkFoodHorizMovement + 1
movementSpeedValues     ds 3
;--------------------------------------
junkFoodHorizSpeedValue = movementSpeedValues
junkFoodVertSpeedValue  = junkFoodHorizSpeedValue + 1
arrivingJunkFoodSpeedValue = junkFoodVertSpeedValue + 1
junkFoodPositionDeltaValues ds 3
;--------------------------------------
junkFoodHorizDelta      = junkFoodPositionDeltaValues
junkFoodVertDelta       = junkFoodHorizDelta + 1
arrivingJunkFoodHorizDelta = junkFoodVertDelta + 1
fractionalPositionValues ds 3
;--------------------------------------
junkFoodHorizFractionalPosValue = fractionalPositionValues
junkFoodVertFractionalPosValue = junkFoodHorizFractionalPosValue + 1
currentWaveStatus       ds 1
frameDelayValue         ds 1

zp_Unused_01            ds 2

junkFoodCollisionValues ds 8
toothDecayAnimationIndexes ds 2
;--------------------------------------
lowerToothDecayAnimationIdx = toothDecayAnimationIndexes
upperToothDecayAnimationIdx = lowerToothDecayAnimationIdx + 1
upperToothDecayGraphPtr ds 2
lowerToothDecayGraphPtr ds 2

zp_Unused_02            ds 1

toothPlacementSoundValues ds 1
wavePointValue          ds 1
toothBonusSoundVolume   ds 1
toothPlacementSoundVolume ds 1
toothpasteSoundValue    ds 1
junkFoodHitSoundValue   ds 1
toothpasteTubeAnimationIdx ds 1
toothpasteTubeFacingDir ds 1
tmpPlayerJoystickValues ds 1
;--------------------------------------
tmpCharHolder           = tmpPlayerJoystickValues
;--------------------------------------
tmpScanline             = tmpCharHolder
;--------------------------------------
tmpJunkFoodDiv15Remainder = tmpScanline
;--------------------------------------
tmpJunkFoodPatternIndex = tmpJunkFoodDiv15Remainder
;--------------------------------------
tmpBonusToothBitIndex   = tmpJunkFoodPatternIndex
;--------------------------------------
tmpLowerTeethPatternIndex = tmpBonusToothBitIndex
;--------------------------------------
tmpJunkFoodIndex        = tmpLowerTeethPatternIndex
;--------------------------------------
tmpBoundaryJunkFoodHorizPos = tmpJunkFoodIndex
;--------------------------------------
tmpBonusTeethLoopCount  = tmpBoundaryJunkFoodHorizPos
;--------------------------------------
tmpMovementSpeedValue   = tmpBonusTeethLoopCount
tmpSixDigitLoopCount    ds 1
;--------------------------------------
tmpJunkFoodKernelSection = tmpSixDigitLoopCount
;--------------------------------------
tmpUpperTeethPatternIndex = tmpJunkFoodKernelSection
;--------------------------------------
tmpJunkFoodPattern      = tmpUpperTeethPatternIndex
;--------------------------------------
tmpArrivingJunkFoodDirection = tmpJunkFoodPattern
tmpDrawLogoLoopCount    ds 1
;--------------------------------------
tmpArrivingJunkFoodLocation = tmpDrawLogoLoopCount
tmpToothIndex           ds 1
tmpJunkFoodHorizPos     ds 1
tmpJunkFoodNUSIZIndex   ds 1
;--------------------------------------
tmpJunkFoodNUSIZValue   = tmpJunkFoodNUSIZIndex
toothpasteStatus        ds 1
numberOfDecayingTeeth   ds 2
;--------------------------------------
numberOfLowerDecayingTeeth = numberOfDecayingTeeth
numberOfUpperDecayingTeeth = numberOfLowerDecayingTeeth + 1

   echo "***",(* - $80 - 3)d, "BYTES OF RAM USED", ($100 - * + 3)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E
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
ClearRAM
   lda #0
.clearLoop
   sta VSYNC,x
   txs
   inx
   stx CTRLPF                       ; set to PF_NO_REFLECT and MSBL_SIZE1
   bne .clearLoop
   jsr InitializeGameVariables
   ldx randomSeed                   ; get random seed value
   bne MainLoop                     ; branch if been through cart startup once
   inx                              ; x = 1
   stx randomSeed                   ; initialize random seed
   jmp JumpIntoConsoleSwitchCheck
       
MainLoop
   lda junkFoodHorizPos + 5         ; get top Junk Food horizontal position
   ldx #8                           ; assume to keep all Junk Food pattern
   cmp #XMAX - 32
   bcc .setTopJunkFoodNUSIZValue    ; branch if all 3 patterns visable
   sbc #XMAX - 32
   jsr Div16
   tax                              ; set index for NUSIZ masking table
.setTopJunkFoodNUSIZValue
   lda junkFoodPatternIndex + 7     ; get top Junk Food pattern value
   and JunkFoodNUSIZIndexMaskingValues,x
   sta tmpJunkFoodNUSIZIndex        ; set index for reading NUSIZ table
   beq .setTmpJunkFoodHorizPosition ; branch if no Junk Food present
   tax                              ; move index value to x register
   lda PlayerNUSIZValueTable,x      ; get NUSIZx value for pattern 
   sta tmpJunkFoodNUSIZValue
   lda JunkFoodHorizOffsetTable,x
   clc
   adc junkFoodHorizPos + 5         ; increment by top Junk Food position
   cmp #XMAX
   bcc .setTmpJunkFoodHorizPosition
   sbc #(XMAX / 2) + 16
.setTmpJunkFoodHorizPosition
   sta tmpJunkFoodHorizPos
   ldx #<[upperToothDecayAnimationIdx - toothDecayAnimationIndexes]
.determineToothDecayColor
   ldy #YELLOW + 14                 ; assume tooth decay
   lda toothDecayAnimationIndexes,x ; get tooth decay animation index
   beq .clearToothDecayHorizPosition
   lda frameCount                   ; get current frame count
   and #3
   bne .setToothDecayColor
   dec toothDecayAnimationIndexes,x ; tooth decay animated every 4 frames
   beq .clearToothDecayHorizPosition
   lda frameCount                   ; get current frame count
   and #7
   bne .setToothDecayColor
   ldy #WHITE - 2
   bpl .setToothDecayColor          ; unconditional branch
       
.clearToothDecayHorizPosition
   sta toothDecayHorizPos,x         ; clear horizontal position (i.e. a = 0)
   sta numberOfDecayingTeeth,x
   tay                              ; set y register to BLACK
.setToothDecayColor
   sty toothDecayColors,x
   dex
   bpl .determineToothDecayColor
   ldx toothpasteTubeAnimationIdx   ; get Toothpaste Tube animation index
   cpx #MAX_TOOTH_PASTE_TUBE_ANIMATION_IDX
   bcc .determineToothpasteTubeGraphicLSBValue
   ldx #MAX_TOOTH_PASTE_TUBE_ANIMATION_IDX
.determineToothpasteTubeGraphicLSBValue
   lda UpFacingToothpasteTubeLSBValues,x;get up facing graphic LSB value
   bit toothpasteTubeFacingDir      ; check Toothpaste Tube vert direction
   bpl .setToothpasteTubeGraphicLSBValue;branch if facing up
   lda DownFacingToothpasteTubeLSBValues,x;get down facing graphic LSB value
.setToothpasteTubeGraphicLSBValue
   sta toothpasteTubeGraphPtrs
   ldx upperToothDecayAnimationIdx
   jsr DetermineToothDecayGraphLSBValue
   sta upperToothDecayGraphPtr
   ldx lowerToothDecayAnimationIdx
   jsr DetermineToothDecayGraphLSBValue
   sta lowerToothDecayGraphPtr
   ldx currentPlayerNumber          ; get the current player number
   lda ToothpasteTubeColors,x       ; get player Toothpaste Tube color
   sta COLUP0                       ; set color for player's score
   sta COLUP1
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   lda colorCycleMode               ; get color cycle mode value
   rol                              ; rotate D7 to D1
   rol
   rol
   and #DISABLE_TIA                 ; disable TIA when no player activity
   sta VBLANK
   jsr SetupFontHeightSixDigitDisplay
   lda #<Blank
   ldx #10
.setDigitPointerLSBToBlank
   sta digitPointers,x
   dex
   dex
   bpl .setDigitPointerLSBToBlank
   ldy #<BonusToothIndicator
   sta HMCLR
   ldx bonusTeeth             ; 3         get bonus teeth value
   dex                        ; 2         reduce value for display
   sta WSYNC
;--------------------------------------
   bmi .drawBonusTeeth        ; 2³        branch if no bonus teeth
   txa                        ; 2         move bonus teeth to accumulator
   asl                        ; 2         multiply value by 2
   tax                        ; 2
.setBonusTeethIndicator
   sty digitPointers,x        ; 4
   dex                        ; 2
   dex                        ; 2
   bpl .setBonusTeethIndicator; 2³
.drawBonusTeeth
   sta WSYNC
;--------------------------------------
   lda #WHITE - 2             ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   jsr SetupFontHeightSixDigitDisplay;6
   ldx numberOfUpperDecayingTeeth;3       get number of upper decaying teeth
   lda PlayerNUSIZValueTable,x; 4         get NUSIZ value for decaying teeth
   sta NUSIZ0                 ; 3 = @30
   sta WSYNC
;--------------------------------------
   ldy #$FF                   ; 2
   sty PF1                    ; 3 = @05
   sty PF2                    ; 3 = @08
   sty PF2                    ; 3 = @11
   lda upperToothDecayHorizPos; 3         get upper decayed tooth horiz position
   sec                        ; 2
.coarsePositionUpperDecayedTooth
   sbc #15                    ; 2
   bcs .coarsePositionUpperDecayedTooth;2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP0                   ; 3 = @13
   lda toothpasteVertPos      ; 3         get Toothpaste vertical position
   sec                        ; 2
   sbc #H_KERNEL - 1          ; 2
   cmp #H_TOOTHPASTE          ; 2
   bcs .colorGumArea          ; 2³
   lda #ENABLE_BM             ; 2
   sta ENABL                  ; 3
.colorGumArea
   sta WSYNC
;--------------------------------------
   lda #RED + 4               ; 2
   sta COLUPF                 ; 3 = @05
   sta VDELP0                 ; 3 = @08   turn off VDEL (i.e. D0 = 0)
   sta VDELP1                 ; 3 = @11
   lda toothpasteHorizPos     ; 3         get Toothpaste horizontal position
   sec                        ; 2
.coarsePositionToothpaste
   sbc #15                    ; 2
   bcs .coarsePositionToothpaste;2³
   sta RESBL                  ; 3
   sta WSYNC
;--------------------------------------
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMBL                   ; 3 = @13
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda upperToothDecayColor   ; 3
   sta COLUP0                 ; 3 = @09
   jsr Waste20Cycles          ; 20
   jsr Waste20Cycles          ; 20
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta HMCLR                  ; 3 = @58
   sta HMCLR                  ; 3 = @61
   tay                        ; 2         y = 0
.drawUpperTeeth
   lda PF2GumGraphicValues,y  ; 4
   ldx PF1GumGraphicValues,y  ; 4
   sta PF2                    ; 3 = @74
;--------------------------------------
   stx PF1                    ; 3 = @01
   lda ToothGraphic,y         ; 4
   sta GRP1                   ; 3 = @08
   lda (upperToothDecayGraphPtr),y;5
   sta GRP0                   ; 3 = @16
   lda upperTeethNUSIZ        ; 3
   sta RESP1                  ; 3 = @22
   sta NUSIZ1                 ; 3 = @25
   SLEEP 2                    ; 2
   lda upperTeethNUSIZ + 1    ; 3
   sta RESP1                  ; 3 = @33
   sta NUSIZ1                 ; 3 = @36
   SLEEP 2                    ; 2
   lda upperTeethNUSIZ + 2    ; 3
   sta RESP1                  ; 3 = @44
   sta NUSIZ1                 ; 3 = @47
   lda upperTeethNUSIZ + 3    ; 3
   iny                        ; 2
   sta RESP1                  ; 3 = @55
   sta NUSIZ1                 ; 3 = @58
   cpy #H_TOOTH               ; 2
   bcc .drawUpperTeeth        ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   lda toothpasteTubeHorizPos ; 3
   sec                        ; 2
.coarsePositionToothpasteTube
   sbc #15                    ; 2
   bcs .coarsePositionToothpasteTube;2²
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP0                   ; 3 = @13
   ldx currentPlayerNumber    ; 3         get the current player number
   lda ToothpasteTubeColors,x ; 4
   sta COLUP0                 ; 3 = @23
   ldy #7                     ; 2
   sty tmpJunkFoodKernelSection;3
   lda #ONE_COPY              ; 2
   sta CXCLR                  ; 3 = @33   clear collision registers
   sta NUSIZ0                 ; 3 = @36
   ldx #H_KERNEL              ; 2
   jmp .skipDrawToothpasteTube_02;3
       
KernelLoop
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   dex                        ; 2
   beq .checkToDrawLowerGumArea_01;2³
   lda junkFoodHorizPos - 2,y ; 4
   stx tmpScanline            ; 3         save scan line value
   ldx #8                     ; 2         assume to keep all Junk Food pattern
   cmp #XMAX - 32             ; 2
   bcc .setJunkFoodNUSIZValue ; 2³        branch if all 3 patterns visable
   sbc #XMAX - 32             ; 2
   lsr                        ; 2         divide value by 16
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tax                        ; 2         set index for NUSIZ masking table
.setJunkFoodNUSIZValue
   lda junkFoodPatternIndex,y ; 4         get Junk Food pattern value
   and JunkFoodNUSIZIndexMaskingValues,x;4
   bne .setJunkFoodNUSIZValueFromTable;2³
   sta tmpJunkFoodNUSIZValue  ; 3         set Junk Food NUSIZ value
   ldx tmpScanline            ; 3         restore scanline value
   bpl .doneSettingUpJunkFoodForKernel;3  unconditional branch

.setJunkFoodNUSIZValueFromTable
   tax                        ; 2         move index value to x register
   lda PlayerNUSIZValueTable,x; 4         get NUSIZx value for pattern
   sta tmpJunkFoodNUSIZValue  ; 3
   lda JunkFoodHorizOffsetTable,x;4
   clc                        ; 2
   adc junkFoodHorizPos - 2,y ; 4
   cmp #XMAX                  ; 2
   ldx tmpScanline            ; 3         restore scan line value
   bcc .doneSettingUpJunkFoodForKernel;2³
   sbc #(XMAX / 2) + 16       ; 2
.doneSettingUpJunkFoodForKernel
   sta WSYNC
;--------------------------------------
   sta tmpJunkFoodHorizPos    ; 3         set Junk Food horizontal position
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   bcs .skipDrawToothpasteTube_01;2³      branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
   sta GRP0                   ; 3 = @24   draw Toothpaste Tube sprite
.skipDrawToothpasteTube_01
   dex                        ; 2
.checkToDrawLowerGumArea_01
   beq .checkToDrawLowerGumArea_02;2³
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   lda #0                     ; 2         assume not drawing Toothpaste Tube
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   bcs .skipDrawToothpasteTube_02;2³      branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
.skipDrawToothpasteTube_02
   ldy tmpJunkFoodNUSIZValue  ; 3
   sty NUSIZ1                 ; 3         set NUSIZ1 for Junk Food
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03   draw Toothpaste Tube sprite
   dex                        ; 2
   beq .checkToDrawLowerGumArea_02;2³
   lda tmpJunkFoodHorizPos    ; 3
   lda tmpJunkFoodHorizPos    ; 3
   sec                        ; 2
.coarseMoveJunkFood
   sbc #15                    ; 2
   bcs .coarseMoveJunkFood    ; 2³
   sta.w RESP1                ; 4
   sta WSYNC
;--------------------------------------
   sta tmpJunkFoodDiv15Remainder;3
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   bcs .skipDrawToothpasteTube_03;2³      branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
   sta GRP0                   ; 3 = @24   draw Toothpaste Tube sprite
.skipDrawToothpasteTube_03
   dex                        ; 2
.checkToDrawLowerGumArea_02
   beq .checkToDrawLowerGumArea;2³
   lda tmpJunkFoodDiv15Remainder;3
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP1                   ; 3
   ldy tmpJunkFoodKernelSection;3
   lda CXP1FB                 ; 3         get Junk Food / Toothpaste collision
   sta junkFoodCollisionValues,y;5        set kernel section collision value
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .skipDrawToothpasteTube_04;2³      branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
   sta GRP0                   ; 3 = @13   draw Toothpaste Tube sprite
.skipDrawToothpasteTube_04
   lda tmpJunkFoodKernelSection;3
   ldy topJunkFoodGraphicIndex; 3
   cmp #MAX_JUNK_FOOD_SECTIONS - 1;2
   bcs .drawJunkFoodKernel    ; 2³
   ldy #H_JUNK_FOOD - 5       ; 2
.drawJunkFoodKernel
   dec tmpJunkFoodKernelSection;5
   bpl DrawJunkFoodKernel     ; 3         unconditional branch
   
IncrementScore
   bit gameState                    ; check current game state
   bmi .doneIncrementScore          ; branch if in DEMO_MODE
   sed
   clc
   adc playerScore + 2              ; increment ones position
   sta playerScore + 2
   bcc .doneIncrementScore
   lda playerScore + 1              ; get hundreds position
   adc #1 - 1                       ; increment when carry set
   sta playerScore + 1
   lda playerScore                  ; get thousands position
   adc #1 - 1                       ; increment when carry set
   bcc .checkForEarningBonusTooth
   lda #$99                         ; make the score 999,999
   sta playerScore + 1
   sta playerScore + 2
   inc copyrightScrollRate
.checkForEarningBonusTooth
   sta playerScore
   lda playerScore + 1              ; get hundreds position
   and #$1F
   bne .doneIncrementScore
   lda bonusTeeth                   ; get current bonus teeth count
   cmp #MAX_RESERVED_TEETH
   bcs .doneIncrementScore
   inc bonusTeeth                   ; increment number of bonus teeth
.doneIncrementScore
   cld
   rts

DetermineToothDecayGraphLSBValue
   cpx #MAX_TOOTH_DECAY_ANIMATION
   bcc .determineToothDecayGraphLSBValue
   ldx #MAX_TOOTH_DECAY_ANIMATION
.determineToothDecayGraphLSBValue
   lda ToothDecayAnimationValues,x
   rts

DrawJunkFoodKernel
   sta CXCLR                  ; 3 = @36
   sta HMCLR                  ; 3 = @39
.nextScanlineForJunkFoodKernel
   dex                        ; 2         decrement scan line
.checkToDrawLowerGumArea
   beq DrawLowerGumAreaKernel ; 2³
   sty tmpJunkFoodIndex       ; 3
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   lda #0                     ; 2
   bcs .prepareToDrawJunkFood ; 2³        branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
.prepareToDrawJunkFood
   ldy tmpJunkFoodIndex       ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw Toothpaste Tube sprite
   lda (junkFoodGraphicPtrs),y; 5
   sta GRP1                   ; 3 = @14
   lda (junkFoodColorPtrs),y  ; 5
   sta COLUP1                 ; 3 = @22
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteVertPos      ; 3         subtract Toothpaste vertical position
   and #~(H_TOOTHPASTE - 1)   ; 2         and with H_TOOTHPASTE 2's complement
   bne .drawToothpasteInJunkFoodKernel;2³ branch if not time to draw Toothpaste
   lda #ENABLE_BM             ; 2
.drawToothpasteInJunkFoodKernel
   sta ENABL                  ; 3
   dey                        ; 2
   bpl .nextScanlineForJunkFoodKernel;2³
   dex                        ; 2
   beq DrawLowerGumAreaKernel ; 2³
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc toothpasteTubeVertPos  ; 3         subtract Toothpaste Tube vert position
   tay                        ; 2         move difference to y register
   lda #0                     ; 2
   cpy #H_TOOTHPASTE_TUBE + 1 ; 2
   bcs .nextKernelLoop        ; 2³        branch if not time to draw
   lda (toothpasteTubeGraphPtrs),y;5
.nextKernelLoop
   ldy tmpJunkFoodKernelSection;3
   jmp KernelLoop             ; 3
       
DrawLowerGumAreaKernel
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   stx GRP1                   ; 3 = @06
   lda #WHITE - 2             ; 2
   sta COLUP1                 ; 3 = @11
   lda lowerToothDecayHorizPos; 3
   sec                        ; 2
.coarsePositionLowerDecayedTooth
   sbc #15                    ; 2
   bcs .coarsePositionLowerDecayedTooth;2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP0                   ; 3 = @13
   ldx tmpJunkFoodKernelSection;3
   lda CXP1FB                 ; 3         get Junk Food / Toothpaste collision
   sta junkFoodCollisionValues,x;4        set kernel section collision value
   jsr Waste20Cycles          ; 20
   sta RESP1                  ; 3 = @46
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Waste18Cycles          ; 18
   jsr Waste16Cycles          ; 16
   lda lowerToothDecayColor   ; 3
   sta COLUP0                 ; 3 = @43
   sta CXCLR                  ; 3 = @46
   ldx numberOfLowerDecayingTeeth;3       get number of lower decaying teeth
   lda PlayerNUSIZValueTable,x; 4         get NUSIZ value for decaying teeth
   sta NUSIZ0                 ; 3 = @56
   sta HMCLR                  ; 3 = @59
   ldy #H_TOOTH - 1           ; 2
.drawLowerTeeth
   lda PF2GumGraphicValues,y  ; 4
   ldx PF1GumGraphicValues,y  ; 4
   SLEEP 2                    ; 2
   sta PF2                    ; 3 = @74
;--------------------------------------
   stx PF1                    ; 3 = @01
   lda ToothGraphic,y         ; 4
   sta GRP1                   ; 3 = @08
   lda (lowerToothDecayGraphPtr),y;5
   sta GRP0                   ; 3 = @16
   lda lowerTeethNUSIZ        ; 3
   sta RESP1                  ; 3 = @22
   sta NUSIZ1                 ; 3 = @25
   SLEEP 2                    ; 2
   lda lowerTeethNUSIZ + 1    ; 3
   sta RESP1                  ; 3 = @33
   sta NUSIZ1                 ; 3 = @39
   SLEEP 2                    ; 2
   lda lowerTeethNUSIZ + 2    ; 3
   sta RESP1                  ; 3 = @47
   sta NUSIZ1                 ; 3 = @50
   lda lowerTeethNUSIZ + 3    ; 3
   dey                        ; 2
   sta RESP1                  ; 3 = @58
   sta NUSIZ1                 ; 3 = @61
   bpl .drawLowerTeeth        ; 2³
   iny                        ; 2         y = 0
   sty ENABL                  ; 3
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sty PF1                    ; 3 = @03
   sty PF2                    ; 3 = @06
   sty COLUPF                 ; 3 = @09
   lda #WHITE - 2             ; 2
   sta COLUP0                 ; 3
   ldy #H_FONT - 1            ; 2
   lda copyrightScrollRate    ; 3
   and #$1F                   ; 2
   cmp #20                    ; 2
   bcs .setLoopCountForCopyright;2³
   ldy #0                     ; 2
   cmp #12                    ; 2
   bcc .setLoopCountForCopyright;2³
   sbc #12                    ; 2
   tay                        ; 2
.setLoopCountForCopyright
   sty tmpSixDigitLoopCount   ; 3
   tya                        ; 2
   eor #7                     ; 2         get 3-bit 1's complement
   sta tmpDrawLogoLoopCount   ; 3
   lda #<Copyright_5          ; 2
   ldx #8                     ; 2
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
.setupCopyrightGraphicPointers
   sta digitPointers + 2,x    ; 4
   sbc #H_COPYRIGHT           ; 2
   sta digitPointers,x        ; 4
   sbc #H_COPYRIGHT           ; 2
   dex                        ; 2
   dex                        ; 2
   dex                        ; 2
   dex                        ; 2
   bpl .setupCopyrightGraphicPointers;2³
   jsr SetupForSixDigitDisplay; 6
   lda #$78                   ; 2
   sta PF1                    ; 3 = @25
   lda #MSBL_SIZE8 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @30
   sta NUSIZ1                 ; 3 = @33
   sta HMCLR                  ; 3 = @36
   lda #HMOVE_L1              ; 2
   sta HMBL                   ; 3 = @41
   ldy #H_FONT - 1            ; 2
   sty ENABL                  ; 3 = @46
.activisionLogoLoop
   lda ActivisionLogo_4,y     ; 4
   tax                        ; 2
   lda ActivisionLogo_0,y     ; 4
   sta GRP0                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda ActivisionRainbowColors,y;4
   sta COLUPF                 ; 3 = @10
   lda ActivisionLogo_1,y     ; 4
   sta GRP1                   ; 3 = @17
   lda ActivisionLogo_2,y     ; 4
   sta GRP0                   ; 3 = @24
   lda tmpCharHolder          ; 3         waste 3 cycles
   SLEEP 2                    ; 2
   lda ActivisionLogo_3,y     ; 4
   sta GRP1                   ; 3 = @36
   stx GRP0                   ; 3 = @39
   sta GRP1                   ; 3 = @42
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @47
   dey                        ; 2
   dec tmpDrawLogoLoopCount   ; 5
   bpl .activisionLogoLoop    ; 2³
   ldy #OVERSCAN_TIME
   ldx #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sty TIM64T                       ; set timer for overscan period
   stx VBLANK                       ; disable TIA and discharge paddles
   sta VDELP0
   sta VDELP1
   sta GRP0
   sta GRP1
   sta GRP0
   sta PF1
   sta ENABL
   lda copyrightScrollRate          ; get copyright scroll rate value
   beq CheckToPlayToothDecayingSound
   bit gameState                    ; check current game state
   bmi CheckToPlayToothDecayingSound; branch if in DEMO_MODE
   lda playerScore + 2              ; get score tens value
   and #$0F                         ; keep 1's value
   beq .checkToSwapPlayerVariables  ; branch if not in SELECT mode
   cmp #5
   bne CheckToPlayToothDecayingSound; unconditional branch
   
.checkToSwapPlayerVariables
   lda frameCount                   ; get current frame count
   and #$7F
   bne CheckToPlayToothDecayingSound
   lda gameSelection                ; get the current game selection
   lsr                              ; shift D0 to carry
   bcc CheckToPlayToothDecayingSound; branch if ONE_PLAYER game
   jsr SwapPlayerVariables
CheckToPlayToothDecayingSound
   bit gameState                    ; check current game state
   bmi .clearToothSoundValues       ; branch if in DEMO_MODE
   lda lowerToothDecayAnimationIdx  ; get lower tooth decay animation value
   ora upperToothDecayAnimationIdx  ; combine with upper tooth decay value
   beq CheckToPlayToothBonusSound   ; branch if no tooth decaying this frame
   tay                              ; move combine tooth decay value to y
   eor #$1F                         ; get 5-bit 1's complement
   sta AUDF0                        ; set tooth decay frequency
   lda #8
   sta AUDV0                        ; set tooth decay volume
   lda #1
   sta AUDC0                        ; set tooth decay audio channel
   tya                              ; move combined tooth decay value to a
   bne .clearToothSoundValues       ; unconditional branch

   .byte $85,$19,$F0,$0A            ; unused opcodes
       
.clearToothSoundValues
   lda #0
   sta toothBonusSoundVolume
   sta toothPlacementSoundVolume
   sta toothpasteSoundValue
   beq CheckToPlayJunkFoodHitSound  ; unconditional branch
       
CheckToPlayToothBonusSound
   lda toothBonusSoundVolume        ; get tooth bonus sound volume value
   beq .checkToPlayToothPlacementSounds;branch if not playing bonus sound
   dec toothBonusSoundVolume        ; reduce sound volume value
   lsr                              ; divide value by 2
   sta AUDV0                        ; set volume for bonus sound
   sta AUDV1
   lda #12
   sta AUDC0                        ; set sound channel value for bonus sound
   sta AUDC1
   sta AUDF0
   clc
   adc #3
   sta AUDF1
.checkToPlayToothPlacementSounds
   lda toothPlacementSoundVolume    ; get tooth placement sound volume
   beq .clearToothPlacementSoundValues;branch if done playing sound
   lsr                              ; divide value by 2
   sta toothPlacementSoundVolume    ; set new tooth placement volume value
   sta AUDV0
   sta AUDV1
   bpl CheckToPlayToothpasteSound   ; unconditional branch
       
.clearToothPlacementSoundValues
   sta toothPlacementSoundValues
CheckToPlayToothpasteSound
   lda toothpasteSoundValue         ; get Toothpaste sound value
   bmi CheckToPlayJunkFoodHitSound  ; branch if done playing Toothpaste sound
   sta AUDV0                        ; set sound volume for Toothpaste sound
   eor #$1F                         ; get 5-bit 1's complement
   sta AUDF0
   lda #12
   sta AUDC0
   lda currentWaveStatus            ; get current wave status values
   and #$0F
   bne .decrementToothpasteSoundValue
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs CheckToPlayJunkFoodHitSound  ; branch on odd frames
.decrementToothpasteSoundValue
   dec toothpasteSoundValue
CheckToPlayJunkFoodHitSound
   lda junkFoodHitSoundValue        ; get Junk Food hit sound value
   bmi SetTeethNUSIZValues          ; branch if done playing hit sound
   bit gameState                    ; check current game state
   bmi .decrementJunkFoodHitSoundValue;branch if in DEMO_MODE
   sta AUDV1                        ; set sound volume for Junk Food hit sound
   sta AUDF1
   lda #8
   sta AUDC1
   lda frameCount                   ; get current frame count
   and #3
   bne .checkToDecrementJunkFoodHitSoundValue
   sta AUDV1                        ; modulate hit volume every 4 frames
.checkToDecrementJunkFoodHitSoundValue
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcc SetTeethNUSIZValues          ; branch on even frames
.decrementJunkFoodHitSoundValue
   dec junkFoodHitSoundValue
SetTeethNUSIZValues
   lda lowerTeethPatternIndex
   sta tmpLowerTeethPatternIndex
   lda upperTeethPatternIndex
   sta tmpUpperTeethPatternIndex
   ldx #3
.setTeethNUSIZValues
   lda tmpLowerTeethPatternIndex    ; get lower teeth pattern
   and #3                           ; keep D1 and D0
   tay
   lda TeethNUSIZValues,y
   sta lowerTeethNUSIZ,x            ; set lower teeth NUSIZ value
   lda tmpUpperTeethPatternIndex    ; get upper teeth pattern
   and #3                           ; keep D1 and D0
   tay
   lda TeethNUSIZValues,y
   sta upperTeethNUSIZ,x            ; set upper teeth NUSIZ value
   lsr tmpLowerTeethPatternIndex
   lsr tmpLowerTeethPatternIndex
   lsr tmpUpperTeethPatternIndex
   lsr tmpUpperTeethPatternIndex
   dex
   bpl .setTeethNUSIZValues
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
.checkForShootingJunkFood
   lda junkFoodCollisionValues - 1,x; get Junk Food collision values
   asl                              ; shift collision register to carry
   asl
   bcc .checkNextJunkFoodCollision  ; branch if no collision this frame
   lda wavePointValue               ; get point value for current wave
   jsr IncrementScore               ; increment score for hitting Junk Food
   lda #15
   sta junkFoodHitSoundValue        ; set Junk Food hit sound value
   lda toothpasteTubeHorizPos       ; get Toothpaste Tube horizontal value
   clc
   adc #8                           ; get Toothpaste horizontal position
   sec
   sbc junkFoodHorizPos - 2,x       ; subtract Junk Food horizontal position
   jsr Div16                        ; divide value by 16
   tay
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #$0F                         ; keep current player Junk Food pattern
   and DestroyedJunkFoodMaskingValues,y;remove destroyed Junk Food
   sta tmpJunkFoodPatternIndex      ; set for removing Junk Food object
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #$F0                         ; keep alternate player Junk Food pattern
   ora tmpJunkFoodPatternIndex      ; combine with new value
   sta junkFoodPatternIndex,x       ; set new Junk Food pattern value
   and #$0F                         ; keep current player Junk Food pattern
   bne .turnOffToothpasteShot       ; branch if all Junk Food not removed
   lda #XMAX + 32
   sta junkFoodHorizPos - 2,x
   lda arrivingJunkFoodHorizMovement
   and BitMaskingValues,x
   sta arrivingJunkFoodHorizMovement
.turnOffToothpasteShot
   lda #TOOTHPASTE_YMAX
   sta toothpasteVertPos
.checkNextJunkFoodCollision
   dex
   bpl .checkForShootingJunkFood
   lda currentWaveStatus            ; get current wave status values
   and #$0F
   ora lowerToothDecayAnimationIdx  ; combine with lower tooth decay value
   ora upperToothDecayAnimationIdx  ; combine with upper tooth decay value
   bne DetermineJunkFoodSpeedValues ; branch if a tooth is decaying
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
.checkForWaveDoneNoJunkFood
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #$0F                         ; keep current player Junk Food pattern
   bne DetermineJunkFoodSpeedValues ; branch if all Junk Food not removed
   dex
   bpl .checkForWaveDoneNoJunkFood
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
.initJunkFoodForNewWave
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   ora #7
   sta junkFoodPatternIndex,x       ; place Junk Food in Junk Food section
   cpx #2
   bcc .initNextJunkFoodValue
   lda #XMAX + 32
   sta junkFoodHorizPos - 2,x
.initNextJunkFoodValue
   dex
   bpl .initJunkFoodForNewWave
   lda #ADVANCING_NEW_WAVE
   sta currentWaveStatus
   lda #TOOTHPASTE_YMAX
   sta toothpasteVertPos            ; turn off Toothpaste shot
   lda #INCREMENT_LEVEL_FRAME_DELAY
   sta frameDelayValue
   lda lowerTeethPatternIndex
   sta lowerTeethValues
   lda upperTeethPatternIndex
   sta upperTeethValues
   inc currentWave                  ; increment current wave
   bit gameState                    ; check current game state
   bpl .determineTeethPatternIndex  ; branch if not in DEMO_MODE
   lda #3
   sta bonusTeeth                   ; set bonus teeth value for DEMO
   stx lowerTeethValues             ; set teeth values for DEMO
   stx upperTeethValues
   lda currentWave                  ; get current wave number
   and #$0F
   sta currentWave                  ; set new wave number
.determineTeethPatternIndex
   lsr toothpasteStatus             ; shift Toothpaste status right
   bcc DetermineJunkFoodSpeedValues ; branch if not run out of toothpaste
   inx                              ; x = 0
   stx lowerTeethPatternIndex       ; clear teeth pattern values
   stx upperTeethPatternIndex
DetermineJunkFoodSpeedValues
   lda currentWave                  ; get current wave number
   ldy gameSelection                ; get the current game selection
   cpy #2
   bcc .determineJunkFoodSpeedValues; branch if game selection for advanced
   lsr                              ; divide wave number by 2
.determineJunkFoodSpeedValues
   tay                              ; move wave value to y register
   lda #0
   cpy #3
   bcc .setJunkFoodHorizontalSpeed  ; branch if before the Strawberry wave
   tya                              ; move wave number to accumulator
   clc
   adc #6                           ; carry set...adc #5 would save a byte
.setJunkFoodHorizontalSpeed
   sta junkFoodHorizSpeedValue
   tya                              ; move wave number to accumulator
   clc
   adc #2
   cmp #16
   bcc .setJunkFoodVerticalSpeed
   lda #16
.setJunkFoodVerticalSpeed
   sta junkFoodVertSpeedValue
   asl
   asl
   asl
   sta arrivingJunkFoodSpeedValue
   lda frameCount                   ; get current frame count
   and #$40
   bne .checkForDecayingTooth
   tax                              ; x = 0
   lda currentWave                  ; get current wave number
   and #6
   bne .setJunkFoodVerticalSpeedAdvanced
   stx junkFoodHorizSpeedValue
.setJunkFoodVerticalSpeedAdvanced
   cmp #6                           ; check if Candy Canes or Ice Cream wave
   bne .checkForDecayingTooth       ; branch if not Candy Canes or Ice Cream wave
   stx junkFoodVertSpeedValue
.checkForDecayingTooth
   lda lowerToothDecayAnimationIdx  ; get lower tooth decay value
   ora upperToothDecayAnimationIdx  ; combine with upper tooth decay value
   beq .setJunkFoodGraphicPointers  ; branch if no tooth decaying
   lda #0
   sta junkFoodVertSpeedValue       ; stop Junk Food vertical movement
.setJunkFoodGraphicPointers
   lda currentWave                  ; get current wave number
   and #7
   tax
   lda JunkFoodGraphicLSBValues,x
   sta junkFoodGraphicPtrs          ; set Junk Food graphic LSB value
   lda JunkFoodColorLSBValues,x
   sta junkFoodColorPtrs            ; set Junk Food color LSB value
   lda currentWaveStatus            ; get current wave status values
   and #$0F
   bne DetermineJunkFoodFractionalMovement
   lda toothpasteTubeAnimationIdx   ; get Toothpaste Tube animation index
   bne DetermineJunkFoodFractionalMovement
   lda toothpasteVertPos            ; get Toothpaste vertical position
   cmp #TOOTHPASTE_YMAX
   bne DetermineJunkFoodFractionalMovement
   ldx #1
   stx toothpasteStatus             ; set D0 to show player out of Toothpaste
.clearJunkFoodPatternIndexValues
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #$F0                         ; clear current Junk Food pattern index
   sta junkFoodPatternIndex,x
   dex
   bpl .clearJunkFoodPatternIndexValues
   asl junkFoodVertSpeedValue
   asl arrivingJunkFoodSpeedValue
DetermineJunkFoodFractionalMovement
   ldx #2
.determineJunkFoodFractionalMovement
   lda movementSpeedValues,x        ; get movement speed value
   sta tmpMovementSpeedValue        ; save movement speed for later
   jsr Div16                        ; divide value by 16
   sta junkFoodPositionDeltaValues,x
   lda tmpMovementSpeedValue        ; get movement speed value
   and #$0F                         ; get mod16 value
   clc
   adc fractionalPositionValues,x   ; increment by fractional value
   cmp #16
   bcc .setFractionalPositionValues
   inc junkFoodPositionDeltaValues,x; increment position change value
.setFractionalPositionValues
   and #$0F
   sta fractionalPositionValues,x
   dex
   bpl .determineJunkFoodFractionalMovement
   ldx #2
.bcd2DigitLoop
   txa                              ; move x to accumulator
   asl                              ; multiply the value by 4 so it can
   asl                              ; be used for the digitPointers indexes
   tay
   lda playerScore,x                ; get the player's score
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide the value by 2
   sta digitPointers,y              ; set LSB pointer to digit
   lda playerScore,x                ; get the player's score
   and #$0F                         ; mask the upper nybble
   asl                              ; multiply the value by 8
   asl
   asl
   sta digitPointers + 2,y          ; set LSB pointer to digit
   dex
   bpl .bcd2DigitLoop
   ldx #0
   ldy #<Blank
.suppressZeroLoop
   lda digitPointers,x              ; get LSB pointer to digit
   bne VerticalSync                 ; end suppress loop if value not zero
   sty digitPointers,x
   inx
   inx
   cpx #10
   bcc .suppressZeroLoop
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | START_VERT_SYNC
   sty WSYNC                        ; wait for next scan line
   sty VSYNC                        ; start vertical sync (D1 = 1)
   sty WSYNC
   sty WSYNC
   sty WSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   inc frameCount                   ; increment frame count each new frame
   bne .setVerticalBlankingTime     ; set VBLANK time if not reached 256 frames
   inc gameState                    ; increment every 256 frames (i.e. ~4 secs)
   lda gameState                    ; get current game state
   and #$C7
   sta gameState
   and #7
   bne .setVerticalBlankingTime
   inc colorCycleMode               ; increment every 2,048 frames
   bne .setVerticalBlankingTime
   sec                              ; set carry bit
   ror colorCycleMode               ; shift carry to D7 to disable TIA
.setVerticalBlankingTime
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blank period
   ldy SWCHA                        ; read the player joystick values
   lda frameCount                   ; get current frame count
   and #7
   bne SetPlayerControlValues
   lda copyrightScrollRate
   beq SetPlayerControlValues
   ldy #NO_MOVE
   dec copyrightScrollRate
   bne SetPlayerControlValues
   dec copyrightScrollRate
   lda gameState                    ; get current game state
   bmi SetPlayerControlValues       ; branch if in DEMO_MODE
   ora #DEMO_MODE
   sta gameState                    ; set game state to DEMO_MODE
   ldx #<tmpPlayerJoystickValues
   bne .jmpToClearRAM               ; unconditional branch
       
SetPlayerControlValues
   lda currentPlayerNumber          ; get the current player number
   lsr                              ; shift D0 to carry
   tya                              ; shift joystick value to accumulator
   bcs .setPlayerJoystickValue      ; branch if player 2 currently active
   jsr ShiftUpperNybblesToLower
.setPlayerJoystickValue
   and #$0F                         ; keep joystick values
   sta playerControlValues
   ldx currentPlayerNumber          ; get the current player number
   lda INPT4,x                      ; read action button
   and #$80                         ; isolate player action button value
   ora playerControlValues
   sta playerControlValues
   lda SWCHB                        ; read console switches
   cpx #0
   beq .setPlayerDifficultyValue    ; branch if player 1 currently active
   lsr                              ; shift values right
.setPlayerDifficultyValue
   and #P0_DIFF_MASK
   ora playerControlValues
   sta playerControlValues
   iny
   beq .checkForSelectAndReset
   lda #0
   sta colorCycleMode
.checkForSelectAndReset
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   bcs .checkForSelectPressed       ; branch if RESET not pressed
   ldx #<colorCycleMode
.jmpToClearRAM
   jmp ClearRAM
   
.checkForSelectPressed
   ldy #0
   lsr                              ; SELECT now in carry
   bcs .resetSelectDebounce         ; branch if SELECT not pressed
   lda selectDebounce               ; get the select debounce delay
   beq .incrementGameSelection      ; if it's zero -- increase game selection
   dec selectDebounce               ; decrement select debounce
   bpl .skipGameSelect
.incrementGameSelection
   inc gameSelection
JumpIntoConsoleSwitchCheck
   lda gameSelection                ; get the current game selection
   and #3                           ; make value 0 <= a <= 3
   sta gameSelection                ; set new game selection value
   sta colorCycleMode               ; set new color cycle mode value
   sta gameState                    ; set game state to not in DEMO_MODE
   ora #[(Blank - NumberFonts) / H_FONT] << 4
   tay
   iny
   sty playerScore + 2
   lda #[(Blank - NumberFonts) / H_FONT] << 4 | [(Blank - NumberFonts) / H_FONT]
   sta playerScore
   sta playerScore + 1
   lda #$FF
   sta copyrightScrollRate
   ldy #SELECT_DELAY
.resetSelectDebounce
   sty selectDebounce
.skipGameSelect
   lda gameState                    ; get current game state
   bpl .skipDemoModePlayerMovement  ; branch if not in DEMO_MODE
   lda #MY_MOVE_RIGHT
   bit frameCount                   ; check current frame count
   bpl .setDemoHorizontalMovement   ; branch if less than 128 frames
   lda #MY_MOVE_LEFT
.setDemoHorizontalMovement
   sta playerControlValues
   lda #MY_MOVE_UP
   bit randomSeed
   bvc .setDemoVerticalMovement
   lda #MY_MOVE_DOWN
.setDemoVerticalMovement
   and playerControlValues
   sta playerControlValues
   bpl .checkToDelayFrameActivity   ; unconditional branch
   
.skipDemoModePlayerMovement
   lda copyrightScrollRate
   bne .doneCheckDelayFrameActivity
.checkToDelayFrameActivity
   ldx frameDelayValue              ; get frame delay value
   beq .continueGameProcessing
   dex                              ; decrement frame delay value
   bpl .setFrameDelayValue
   inx                              ; x = 0
.setFrameDelayValue
   stx frameDelayValue
.doneCheckDelayFrameActivity
   jmp JmpToMainLoop

.continueGameProcessing
   lda currentWaveStatus            ; get current wave status values
   and #ADVANCING_NEW_WAVE          ; keep ADVANCING_NEW_WAVE value
   bne CheckToScorePointsForRemainingToothpaste;branch if starting new wave
   jmp CheckToSwapPlayerVariables
       
CheckToScorePointsForRemainingToothpaste
   lda frameCount                   ; get current frame count
   and #7
   beq ScorePointsForRemainingToothpaste;branch every 8 frames
   jmp .branchToDoneScoringBonusPoints
       
ScorePointsForRemainingToothpaste
   lda toothpasteTubeAnimationIdx   ; get Toothpaste Tube animation index
   beq DetermineBonusPointsForRemainingTeeth
   lda #15
   dec toothpasteTubeAnimationIdx   ; reduce Toothpaste Tube animation index
   bne .scorePointsForRemainingToothpaste;not needed...could fall through
.scorePointsForRemainingToothpaste
   sta toothpasteSoundValue
   lda wavePointValue               ; get point value for current wave
   jsr IncrementScore
.doneScoringBonusPointsForWave
   jmp JmpToMainLoop

DetermineBonusPointsForRemainingTeeth
   ldy #1
.checkRemainingTeethForBonus
   ldx #7
.determineBonusPointsForRemainingTeeth
   stx tmpBonusToothBitIndex
   lda teethPatternIndexes,y        ; get Teeth pattern index value
   and BitIsolationValues,x
   beq .checkNextToothForBonus      ; branch if tooth not present in position
   eor teethPatternIndexes,y        ; flip tooth pattern values
   sta teethPatternIndexes,y        ; set with tooth removed
   sta teethPatternIndexes,y
   ldx currentWave                  ; get current wave number
   dex
   cpx #4
   bcc .incrementRemainingTeethBonus
   ldx #4
.incrementRemainingTeethBonus
   lda wavePointValue               ; get point value for current wave
   jsr IncrementScore
   dex
   bpl .incrementRemainingTeethBonus
   lda #16
   sta toothBonusSoundVolume
   bpl .doneScoringBonusPointsForWave;unconditional branch
   
.checkNextToothForBonus
   ldx tmpBonusToothBitIndex
   dex
   bpl .determineBonusPointsForRemainingTeeth
   dey
   bpl .checkRemainingTeethForBonus
   ldy #STARTING_NEW_WAVE_FRAME_DELAY
   ldx #STARTING_NEW_WAVE
   lda gameSelection                ; get the current game selection
   lsr                              ; shift D0 to carry
   bcc .resetCurrentWaveStatus      ; branch if ONE_PLAYER game
   ldx #SWAP_PLAYER_VARIABLES | STARTING_NEW_WAVE
.resetCurrentWaveStatus
   sty frameDelayValue
   stx currentWaveStatus
   lda #15
   sta toothPlacementSoundValues
.branchToDoneScoringBonusPoints
   bpl .doneScoringBonusPointsForWave;unconditional branch

CheckToSwapPlayerVariables
   lda currentWaveStatus            ; get current wave status values
   and #SWAP_PLAYER_VARIABLES
   beq .checkToStartNewWave
   lda reservePlayerLives           ; get reserve player lives
   ora reservePlayerLowerTeethValues; combine with reserve player lower teeth
   ora reservePlayerUpperTeethValues; combine with reserve player upper teeth
   beq .setToStartNewWave
   jsr SwapPlayerVariables
.setToStartNewWave
   lda #STARTING_NEW_WAVE
   sta currentWaveStatus
.checkToStartNewWave
   lda currentWaveStatus            ; get current wave status values
   lsr                              ; shift STARTING_NEW_WAVE to carry
   bcs CheckToResetForNewWave       ; branch if starting new wave
   jmp DetermineWavePointValue
       
CheckToResetForNewWave
   lda bonusTeeth                   ; get number of bonus teeth
   ora lowerTeethValues
   ora upperTeethValues
   ora lowerToothDecayAnimationIdx  ; combine with lower tooth decay value
   ora upperToothDecayAnimationIdx  ; combine with upper tooth decay value
   ora toothpasteTubeAnimationIdx   ; combine with Toothpaste Tube animation
   bne ResetForNewWave
   lda reservePlayerLives           ; get reserve player lives
   ora reservePlayerLowerTeethValues; combine with reserve player lower teeth
   ora reservePlayerUpperTeethValues; combine with reserve player upper teeth
   bne .setWaveStatusToSwapPlayers
   dec copyrightScrollRate
   lda #TOOTHPASTE_YMAX
   sta toothpasteVertPos
.setWaveStatusToSwapPlayers
   lda #SWAP_PLAYERS_FRAME_DELAY
   sta frameDelayValue
   lda #SWAP_PLAYER_VARIABLES | STARTING_NEW_WAVE
   sta currentWaveStatus
.jmpToMainLoop
   jmp JmpToMainLoop

ResetForNewWave
   lda #WAVE_TIME_ADVANCED          ; get time value for advanced players
   ldx gameSelection                ; get the current game selection
   cpx #2
   bcc .setTimerForWave             ; branch if game selection for advanced
   lda #WAVE_TIME_BEGINNER          ; get time value for beginner players
.setTimerForWave
   sta toothpasteTubeAnimationIdx   ; set Toothpaste Tube animation index
   lda #INIT_TOOTHPASTE_TUBE_HORIZ_POS
   sta toothpasteTubeHorizPos
   lda currentWave                  ; get current wave number
   lsr                              ; shift D0 to carry
   lda #TOOTHPASTE_TUBE_FACING_UP
   ldx #INIT_TOOTHPASTE_TUBE_VERT_FACING_UP
   sta topJunkFoodGraphicIndex
   bcc .setToothpasteTubeDirection  ; branch if an odd wave
   ldx #H_JUNK_FOOD
   stx topJunkFoodGraphicIndex
   ldx #INIT_TOOTHPASTE_TUBE_VERT_FACING_DOWN
   lda #TOOTHPASTE_TUBE_FACING_DOWN
.setToothpasteTubeDirection
   sta toothpasteTubeFacingDir
   ora currentWaveStatus
   sta currentWaveStatus
   stx toothpasteTubeVertPos
   lda frameCount                   ; get current frame count
   and #3
   bne .jmpToMainLoop
   lda lowerTeethValues
   ora upperTeethValues
   beq CheckForBonusToothPlacement
PlaceTeethInDisplayArray
   ldx #1
.placeTeethInDisplayArray
   ldy #7
.checkBitPatternForDiplayArray
   lda toothPatternValues,x         ; get tooth pattern values
   and BitIsolationValues,y         ; isolate tooth for particular bit
   beq .nextToothBitPattenCheck     ; branch if tooth not present
   ora teethPatternIndexes,x        ; combine value for displayed tooth pattern
   sta teethPatternIndexes,x
   lda toothPatternValues,x
   and BitMaskingValues,y
   sta toothPatternValues,x         ; remove current tooth value to show placed
   jmp PlayToothPlacementSounds
       
.nextToothBitPattenCheck
   dey
   bpl .checkBitPatternForDiplayArray
   dex
   bpl .placeTeethInDisplayArray
CheckForBonusToothPlacement
   ldx #15
.checkForBonusToothPlacement
   stx tmpBonusTeethLoopCount
   lda bonusTeeth                   ; get number of bonus teeth
   beq .doneCheckForBonusToothPlacement;branch if no bonus teeth
   lda tmpBonusTeethLoopCount       ; get current loop count value
   lsr                              ; divide value by 2
   tax
   ldy BitMaskingIndexValues,x
   lda tmpBonusTeethLoopCount       ; get current loop count value
   and #1                           ; keep D0 for vertical tooth placement
   tax
   lda teethPatternIndexes,x        ; get tooth pattern index value
   and BitIsolationValues,y
   bne .checkNextPositionForBonusTooth;branch if tooth present in position
   lda teethPatternIndexes,x        ; get tooth pattern index value
   ora BitIsolationValues,y         ; place tooth in missing position
   sta teethPatternIndexes,x
   dec bonusTeeth                   ; reduce number of bonus teeth
   jmp PlayToothPlacementSounds
       
.checkNextPositionForBonusTooth
   ldx tmpBonusTeethLoopCount
   dex
   bpl .checkForBonusToothPlacement
.doneCheckForBonusToothPlacement
   lda currentWaveStatus            ; get current wave status values
   and #JUNK_FOOD_VERT_DIR_MASK     ; keep Junk Food vertical direction value
   sta currentWaveStatus
   ldx #(INIT_JUNK_FOOD_HORIZ_MOVE << 4) | INIT_JUNK_FOOD_HORIZ_MOVE
   stx normalJunkFoodHorizMovement
   lda #STARTING_NEW_WAVE_FRAME_DELAY
   sta frameDelayValue
   ldx #0
   stx arrivingJunkFoodHorizMovement; set so all new Junk Food transition
   jmp JmpToMainLoop
       
DetermineWavePointValue
   ldy gameSelection                ; get the current game selection
   lda currentWave                  ; get current wave number
   cmp #7
   bcc .determineGameSelectionWavePointValue
   lda #7                           ; set to max index for point value lookup
.determineGameSelectionWavePointValue
   cpy #2
   bcc .setWavePointValue           ; branch if game selection for advanced
   lsr                              ; divide level by 4 for beginners
   lsr
.setWavePointValue
   tax
   lda WavePointValueTable,x        ; get point value from lookup table
   sta wavePointValue               ; set point value for current wave
   ldx #$3F                         ; reduce Toothpaste Tube timer ~60 seconds
   lda lowerTeethPatternIndex       ; get lower teeth pattern index
   ora upperTeethPatternIndex       ; combine with upper teeth pattern index
   bne DecrementToothpasteTubeTimer ; branch if there are teeth remaining
   ldx #$1F                         ; reduce Toothpaste Tube timer ~30 seconds
DecrementToothpasteTubeTimer
   txa
   and frameCount
   bne MoveToothpasteTube
   lda toothpasteTubeAnimationIdx   ; get Toothpaste Tube animation index
   beq MoveToothpasteTube
   dec toothpasteTubeAnimationIdx   ; reduce Toothpaste Tube animation index
MoveToothpasteTube
   lda playerControlValues          ; get player control values
   sta tmpPlayerJoystickValues      ; set for joystick value determination
   lda toothpasteTubeVertPos        ; get Toothpaste Tube vertical position
   ldx #TOOTHPASTE_TUBE_FACING_UP
   ldy #TOOTHPASTE_TUBE_FACING_DOWN
   lsr tmpPlayerJoystickValues      ; shift MOVE_UP value to carry
   bcs .checkForToothpasteTubeMovingDown;branch if not moving up
   cmp #TOOTHPASTE_TUBE_YMAX
   bcs .checkForToothpasteTubeMovingDown
   inc toothpasteTubeVertPos        ; move Toothpaste Tube up
   stx toothpasteTubeFacingDir
.checkForToothpasteTubeMovingDown
   lsr tmpPlayerJoystickValues      ; shift MOVE_DOWN value to carry
   bcs .checkForToothpasteTubeMovingLeft;branch if not moving down
   cmp #TOOTHPASTE_TUBE_YMIN
   bcc .checkForToothpasteTubeMovingLeft
   dec toothpasteTubeVertPos        ; move Toothpaste Tube down
   sty toothpasteTubeFacingDir
.checkForToothpasteTubeMovingLeft
   lda toothpasteTubeHorizPos
   lsr tmpPlayerJoystickValues      ; shift MOVE_LEFT to carry
   bcs .checkForToothpasteTubeMovingRight;branch if not moving left
   cmp #TOOTHPASTE_TUBE_XMIN
   bcc .checkForToothpasteTubeMovingRight
   dec toothpasteTubeHorizPos
.checkForToothpasteTubeMovingRight
   lsr tmpPlayerJoystickValues      ; shift MOVE_RIGHT to carry
   bcs .setToothpasteTubeFacingDirection;branch if not moving right
   cmp #TOOTHPASTE_TUBE_XMAX
   bcs .setToothpasteTubeFacingDirection
   inc toothpasteTubeHorizPos
.setToothpasteTubeFacingDirection
   lda toothpasteTubeVertPos        ; get Toothpaste Tube vertical position
   cmp #TOOTHPASTE_TUBE_YMAX
   bne .checkToFaceToothpasteTubeUp
   sty toothpasteTubeFacingDir      ; set Toothpaste Tube to face down
.checkToFaceToothpasteTubeUp
   cmp #TOOTHPASTE_TUBE_YMIN - 1
   bne .setToothpasteHorizPosition
   stx toothpasteTubeFacingDir      ; set Toothpaste Tube to face up
.setToothpasteHorizPosition
   lda toothpasteTubeHorizPos       ; get Toothpaste Tube horizontal position
   clc
   adc #3                           ; increment for Toothpaste horizontal offset
   sta toothpasteHorizPos           ; set Toothpaste horizontal position
   lda toothpasteSoundValue
   bmi CheckToLaunchToothpaste
   cmp #8
   bcs .moveToothpasteVertically
CheckToLaunchToothpaste
   lda playerControlValues          ; get player control values
   bmi .moveToothpasteVertically    ; branch if action button not pressed
   lda toothpasteVertPos            ; get Toothpaste vertical position
   cmp #TOOTHPASTE_YMAX
   bne .moveToothpasteVertically
   lda toothpasteTubeAnimationIdx   ; get Toothpaste Tube animation index
   beq .determineToothpasteReachedBoundary
   ldx #6
   bit playerControlValues          ; check player control values
   bvc .setToothpasteSpeed          ; branch if set to AMATEUR
   dex                              ; reduce by 2 to slow speed for EXPERT
   dex
.setToothpasteSpeed
   txa
   bit toothpasteTubeFacingDir      ; check Toothpaste Tube vert direction
   bpl .setToothpasteVelocity       ; branch if facing up
   eor #$FF                         ; negate value to travel down
   clc
   adc #1
.setToothpasteVelocity
   sta toothpasteVelocity           ; represents speed and direction
   lda #15
   sta toothpasteSoundValue
   lda toothpasteTubeVertPos        ; get Toothpaste Tube vertical position
   adc #8                           ; increment value by 8
   sta toothpasteVertPos            ; for Toothpaste vertical position
.moveToothpasteVertically
   lda toothpasteVertPos            ; get Toothpaste vertical position
   clc
   adc toothpasteVelocity
   sta toothpasteVertPos
.determineToothpasteReachedBoundary
   lda toothpasteVertPos            ; get Toothpaste vertical position
   sec
   sbc #128
   cmp #(TOOTHPASTE_YMAX / 2)
   bcs .checkToMoveJunkFood
   lda #TOOTHPASTE_YMAX
   sta toothpasteVertPos            ; set Toothpaste vertical position
.checkToMoveJunkFood
   bit currentWaveStatus            ; check current wave status
   bpl MoveJunkFoodDown             ; branch if Junk Food traveling down
   jmp MoveJunkFoodUp
       
MoveJunkFoodDown
   lda topJunkFoodGraphicIndex      ; get top Junk Food graphic index value
   clc
   adc junkFoodVertDelta
   sta topJunkFoodGraphicIndex
   cmp #H_JUNK_FOOD + 1
   bcc .checkForTouchingLowerTooth
   jsr NextRandom
   ldx #0
   stx topJunkFoodGraphicIndex      ; set to not draw top Junk Food pattern
   lda junkFoodPatternIndex         ; get lower Junk Food pattern value
   sta tmpJunkFoodPatternIndex
.bubbleUpJunkFoodArray
   cpx #2
   bcc .bubbleUpJunkFoodPatternArray
   lda junkFoodHorizPos - 1,x       ; get Junk Food horizontal position
   sta junkFoodHorizPos - 2,x       ; move to adjacent Junk Food position
.bubbleUpJunkFoodPatternArray
   lda junkFoodPatternIndex + 1,x   ; get Junk Food pattern value
   sta junkFoodPatternIndex,x       ; move to adjacent Junk Food pattern
   inx
   cpx #MAX_JUNK_FOOD_SECTIONS - 1
   bcc .bubbleUpJunkFoodArray
   lda tmpJunkFoodPatternIndex
   sta junkFoodPatternIndex + 7
   lda #XMAX + 32
   sta junkFoodHorizPos + 5         ; set top Junk Food horizontal position
   lda arrivingJunkFoodHorizMovement
   lsr
   and #$FC
   sta arrivingJunkFoodHorizMovement
   lda normalJunkFoodHorizMovement
   lsr
   ror normalJunkFoodHorizMovement
.checkForTouchingLowerTooth
   lda topJunkFoodGraphicIndex
   sec
   sbc #6
   bne .moveTravelingDownJunkFoodHoriz
   tay                              ; y = 0
   lda junkFoodHorizPos             ; get bottom Junk Food horizontal position
   sta tmpBoundaryJunkFoodHorizPos
   lda junkFoodPatternIndex + 2     ; get bottom Junk Food pattern value
   and #7                           ; keep current player Junk Food pattern
   jsr CheckToRemoveDecayingTooth
   lda arrivingJunkFoodHorizMovement
   and #$FC
   ora #NO_ARRIVING_JUNK_FOOD << 1
   sta arrivingJunkFoodHorizMovement
   bit currentWaveStatus            ; check current wave status
   bmi .doneMoveJunkFoodTravelingDown;branch if Junk Food traveling up
.moveTravelingDownJunkFoodHoriz
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
   jsr MoveArrivingJunkFoodHorizontally
.moveTravelingDownNormalJunkFoodHoriz
   jsr MoveNormalJunkFoodHorizontally
   dex
   cpx #3
   bcs .moveTravelingDownNormalJunkFoodHoriz
.doneMoveJunkFoodTravelingDown
   jmp JmpToMainLoop

MoveJunkFoodUp
   lda topJunkFoodGraphicIndex
   sec
   sbc junkFoodVertDelta
   sta topJunkFoodGraphicIndex
   bpl .checkForTouchingUpperTooth
   lda #H_JUNK_FOOD
   sta topJunkFoodGraphicIndex
   jsr NextRandom
   ldx #MAX_JUNK_FOOD_SECTIONS - 2
   lda junkFoodPatternIndex + 7     ; get top Junk Food pattern value
   sta tmpJunkFoodPatternIndex
.bubbleDownJunkFoodArray
   cpx #2
   bcc .bubbleDownJunkFoodPatternArray
   lda junkFoodHorizPos - 2,x       ; get Junk Food horizontal position
   sta junkFoodHorizPos - 1,x       ; move to adjacent Junk Food position
.bubbleDownJunkFoodPatternArray
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   sta junkFoodPatternIndex + 1,x   ; move to adjacent Junk Food pattern
   dex
   bpl .bubbleDownJunkFoodArray
   lda tmpJunkFoodPatternIndex
   sta junkFoodPatternIndex
   lda #XMAX + 32
   sta junkFoodHorizPos
   lda arrivingJunkFoodHorizMovement
   and #$FE
   asl
   sta arrivingJunkFoodHorizMovement
   lda normalJunkFoodHorizMovement
   asl
   rol normalJunkFoodHorizMovement
.checkForTouchingUpperTooth
   lda currentWave                  ; get current wave number
   and #7
   tax
   lda topJunkFoodGraphicIndex
   sec
   sbc JunkFoodHeightValues,x
   bne .moveTravelingUpJunkFoodHoriz
   ldy #<[upperToothDecayAnimationIdx - toothDecayAnimationIndexes]
   lda junkFoodHorizPos + 5         ; get top Junk Food horizontal position
   sta tmpBoundaryJunkFoodHorizPos
   lda junkFoodPatternIndex + 7     ; get top Junk Food pattern value
   and #7                           ; keep current player Junk Food pattern
   jsr CheckToRemoveDecayingTooth
   lda arrivingJunkFoodHorizMovement
   ora #NO_ARRIVING_JUNK_FOOD << 7
   sta arrivingJunkFoodHorizMovement
   bit currentWaveStatus            ; check current wave status
   bpl JmpToMainLoop                ; branch if Junk Food traveling down
.moveTravelingUpJunkFoodHoriz
   ldx #2
   jsr MoveArrivingJunkFoodHorizontally
.moveTravelingUpNormalJunkFoodHoriz
   jsr MoveNormalJunkFoodHorizontally
   inx
   cpx #MAX_JUNK_FOOD_SECTIONS - 1
   bcc .moveTravelingUpNormalJunkFoodHoriz
JmpToMainLoop
   jmp MainLoop

InitializeGameVariables
   ldx #11
   ldy #>NumberFonts
.initDigitPointersMSBValue
   sty digitPointers,x
   dex
   dex
   bpl .initDigitPointersMSBValue
   dey
   sty junkFoodColorPtrs + 1        ; Junk Food colors 1 page below NumberFonts
   dey
   sty junkFoodGraphicPtrs + 1      ; Junk Food graphics 1 page below colors
   sty upperToothDecayGraphPtr + 1
   sty lowerToothDecayGraphPtr + 1
   dey
   sty toothpasteTubeGraphPtrs + 1  ; Toothpaste Tube graphics 1 page below
   lda #INIT_GAME_FRAME_DELAY
   sta frameDelayValue
   lda #TOOTHPASTE_YMAX
   sta toothpasteVertPos            ; set Toothpaste vertical position
   lda #15
   sta toothPlacementSoundValues
   ldx #%00111100
   stx lowerTeethValues             ; initialize teeth values
   stx upperTeethValues
   lda gameSelection                ; get the current game selection
   lsr                              ; shift D0 to carry
   bcc .setWaveStateToStartNewWave  ; branch if ONE_PLAYER game
   stx reservePlayerLowerTeethValues; initialize reserve player teeth values
   stx reservePlayerUpperTeethValues
.setWaveStateToStartNewWave
   lda #STARTING_NEW_WAVE
   sta currentWaveStatus
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
.resetJunkFoodValues
   lda #7 << 4 | 7
   sta junkFoodPatternIndex,x
   lda #XMAX + 32
   sta junkFoodHorizPos - 2,x
   dex
   bpl .resetJunkFoodValues
   rts

MoveArrivingJunkFoodHorizontally
   lda arrivingJunkFoodSpeedValue   ; get arriving junk food speed
   lsr                              ; divide value by 16
   lsr
   lsr
   lsr
   clc
   adc #1
   sta tmpArrivingJunkFoodLocation
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #$0F                         ; keep current player Junk Food pattern
   beq .doneMoveArrivingJunkFoodHorizontally;branch if no Junk Food items
   lda arrivingJunkFoodHorizMovement
   and BitIsolationValues,x
   bne .doneMoveArrivingJunkFoodHorizontally
   lda randomSeed                   ; get random seed value
   and #$3F                         ; 0 <= a <= 63
   adc #48                          ; 48 <= a <= 111
   cmp #(XMAX / 2)
   bcs .setArrivingJunkFoodDirection
   sec
   sbc #31                          ; 17 <= a <= 48
.setArrivingJunkFoodDirection
   sta tmpArrivingJunkFoodDirection
   cmp #(XMAX / 2)
   lda junkFoodHorizPos - 2,x       ; get Junk Food horizonal position
   bcs .moveArrivingJunkFoodLeft
   adc arrivingJunkFoodHorizDelta   ; move Junk Food to the right
   sta junkFoodHorizPos - 2,x
   sec
   sbc tmpArrivingJunkFoodDirection
   cmp tmpArrivingJunkFoodLocation
   bcc .setJunkFoodToNotArriving
   rts

.moveArrivingJunkFoodLeft
   sbc arrivingJunkFoodHorizDelta   ; move Junk Food to the left
   sta junkFoodHorizPos - 2,x
   lda tmpArrivingJunkFoodDirection
   sec
   sbc junkFoodHorizPos - 2,x
   cmp tmpArrivingJunkFoodLocation
   bcs .doneMoveArrivingJunkFoodHorizontally
.setJunkFoodToNotArriving
   lda arrivingJunkFoodHorizMovement
   ora BitIsolationValues,x
   sta arrivingJunkFoodHorizMovement
.doneMoveArrivingJunkFoodHorizontally
   rts

MoveNormalJunkFoodHorizontally
   lda arrivingJunkFoodHorizMovement; get arriving Junk Food values
   and BitIsolationValues,x
   beq .doneMoveNormalJunkFoodHorizontally;branch if Junk Food arriving
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   and #7                           ; keep current player Junk Food pattern
   bne .determineNormalJunkFoodHorizDirection;branch if Junk Food present
   lda #XMAX + 32
   sta junkFoodHorizPos - 2,x
   rts

.determineNormalJunkFoodHorizDirection
   lda normalJunkFoodHorizMovement  ; get normal Junk Food movement values
   and BitIsolationValues,x
   beq .moveJunkFoodLeft            ; branch if bit set to move left
   lda junkFoodHorizPos - 2,x       ; get Junk Food horizonal position
   clc
   adc junkFoodHorizDelta           ; increment Junk Food horizontal position
   sta junkFoodHorizPos - 2,x
   cmp #XMAX - 50
   bcs .changeNormalJunkFoodHorizDirection
   rts

.moveJunkFoodLeft
   lda junkFoodHorizPos - 2,x       ; get Junk Food horizontal position
   sec
   sbc junkFoodHorizDelta           ; decrement Junk Food horizontal position
   sta junkFoodHorizPos - 2,x
   cmp #XMIN + 11
   bcs .doneMoveNormalJunkFoodHorizontally
.changeNormalJunkFoodHorizDirection
   lda normalJunkFoodHorizMovement
   eor BitIsolationValues,x
   sta normalJunkFoodHorizMovement
.doneMoveNormalJunkFoodHorizontally
   rts

CheckToRemoveDecayingTooth
   sta tmpJunkFoodPattern
   sta tmpArrivingJunkFoodLocation  ; not needed or used for routine
   ldx toothDecayAnimationIndexes,y ; get tooth decay animation value
   dex
   cpx #3
   bcc .removeTooth                 ; branch if time to remove decaying tooth
   ldx #5
.searchForDecayingTooth
   lda tmpBoundaryJunkFoodHorizPos  ; get boundary Junk Food horizontal position
   sec
   sbc ToothHorizontalPositionValues,x
   cmp #XMIN + 14
   bcc .foundToothToDecay           ; branch if within range of Tooth
   asl tmpJunkFoodPattern
   dex
   bpl .searchForDecayingTooth
   inx                              ; x = 0
   stx toothDecayAnimationIndexes,y
   rts

.foundToothToDecay
   stx decayingToothHorizPositionIndex
   lda tmpJunkFoodPattern
   and teethPatternIndexes,y
   sta removeTeethPattern
   bne SetStartingToothDecayAnimationRate
   sta toothDecayAnimationIndexes,y ; clear tooth decay animation index
   rts

SetStartingToothDecayAnimationRate
   lda toothDecayAnimationIndexes,y ; get tooth decay animation value
   bne SetDecayingToothHorizPosition; branch if tooth decaying
   sty tmpToothIndex
   tay                              ; a = 0
   lda currentWaveStatus            ; get current wave status values
   ora #TOOTH_DECAYING_MASK
   sta currentWaveStatus            ; set status to show tooth decaying
   lda lowerTeethPatternIndex       ; get lower teeth pattern index
   sta lowerTeethValues
   lda upperTeethPatternIndex
   ldx #15
.determineNumberOfRemainingTeeth
   lsr lowerTeethValues             ; shift lower teeth values right
   ror                              ; rotate carry to D7 and D0 to carry
   bcc .nextNumberOfRemainingTeeth  ; branch if tooth missing
   iny                              ; increment number of remaining teeth
.nextNumberOfRemainingTeeth
   dex
   bpl .determineNumberOfRemainingTeeth
   cpy #5
   bcc SetToothDecayAnimationIndexValue;branch if less than 5 teeth remaining
   lda #22
   sec
   sbc currentWave
   bcs .setToothDecayAnimationIndexValue
SetToothDecayAnimationIndexValue
   lda #0
.setToothDecayAnimationIndexValue
   clc
   adc #7
   ldy tmpToothIndex                ; get tooth index value
   sta toothDecayAnimationIndexes,y ; set tooth decay animation value
SetDecayingToothHorizPosition
   ldx decayingToothHorizPositionIndex
   lda removeTeethPattern
.determineDecayingToothPattern
   cpx #5
   bcs .setDecayingToothHorizPosition
   lsr                              ; shift remove teeth pattern right
   inx
   bpl .determineDecayingToothPattern;unconditional branch
   
.setDecayingToothHorizPosition
   sta numberOfDecayingTeeth,y
   tax
   lda JunkFoodHorizOffsetTable,x   ; get Junk Food horizontal offset
   ldx decayingToothHorizPositionIndex
   clc
   adc ToothHorizontalPositionValues,x;increment by Tooth horizontal position
   adc #8                           ; increment by decaying tooth offset
   sta toothDecayHorizPos,y
   rts

.removeTooth
   lda removeTeethPattern           ; get teeth pattern to remove
   and teethPatternIndexes,y        ; isolate teeth to be removed
   eor teethPatternIndexes,y        ; flip pattern value to remove teeth
   sta teethPatternIndexes,y
   rts

SwapPlayerVariables
   ldx #6
.swapPlayerVariables
   lda currentPlayerVariables,x
   ldy reservePlayerVariables,x
   sty currentPlayerVariables,x
   sta reservePlayerVariables,x
   dex
   bpl .swapPlayerVariables
   ldx #MAX_JUNK_FOOD_SECTIONS - 1
.swapJunkFoodPatternValues
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   jsr ShiftUpperNybblesToLower
   sta tmpJunkFoodPatternIndex
   lda junkFoodPatternIndex,x       ; get Junk Food pattern value
   asl
   asl
   asl
   asl
   ora tmpJunkFoodPatternIndex
   sta junkFoodPatternIndex,x
   dex
   bpl .swapJunkFoodPatternValues
   lda gameSelection                ; get the current game selection
   lsr                              ; shift D0 to carry
   bcc .doneSwapPlayerVariables     ; branch if ONE_PLAYER game
   lda currentPlayerNumber          ; get the current player number
   eor #1                           ; flip D0
   sta currentPlayerNumber          ; set new current player number
.doneSwapPlayerVariables
   lda #SWAP_VARIABLES_FRAME_DELAY
   sta frameDelayValue
   rts

   .byte $85,$02,$85,$2A,$A2,$0B,$95,$8B,$CA,$CA,$10,$FA;unused opcodes

SetupFontHeightSixDigitDisplay
   lda #H_FONT - 1            ; 2
   sta tmpSixDigitLoopCount   ; 3
SetupForSixDigitDisplay
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   ldx #HMOVE_R1 | MSBL_SIZE8 | THREE_COPIES;2
   stx NUSIZ0                 ; 3 = @16
   stx NUSIZ1                 ; 3 = @19
   ldy #PF_REFLECT            ; 2
   lda #HMOVE_L4              ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   sta RESBL                  ; 3 = @34
   sty CTRLPF                 ; 3 = @37
   sta HMBL                   ; 3 = @40
   stx HMP0                   ; 3 = @43
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sty VDELP0                 ; 3 = @06
   sty VDELP1                 ; 3 = @09
   dey                        ; 2         y = 0
   sty GRP0                   ; 3 = @14
   sty GRP1                   ; 3 = @17
   sty GRP0                   ; 3 = @20
   sta tmpCharHolder          ; 3
   sta HMCLR                  ; 3 = @26
.drawSixDigitDisplay
   ldy tmpSixDigitLoopCount   ; 3
   lda (digitPointers + 10),y ; 5
   sta tmpCharHolder          ; 3
   lda (digitPointers + 8),y  ; 5
   tax                        ; 2
   lda (digitPointers),y      ; 5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   lda (digitPointers + 2),y  ; 5
   sta GRP1                   ; 3 = @14
   lda (digitPointers + 4),y  ; 5
   sta GRP0                   ; 3 = @22
   lda (digitPointers + 6),y  ; 5
   ldy tmpCharHolder          ; 3
   sta GRP1                   ; 3 = @33
   stx GRP0                   ; 3 = @36
   sty GRP1                   ; 3 = @39
   sta GRP0                   ; 3 = @42
   dec tmpSixDigitLoopCount   ; 5
   bpl .drawSixDigitDisplay   ; 2³
   lda #HMOVE_R8              ; 2
   sta HMP0                   ; 3 = @54
   sta HMP1                   ; 3 = @57
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   sta GRP1                   ; 3 = @11
   sta GRP0                   ; 3 = @14
   rts                        ; 6

   FILL_BOUNDARY 0, 234
   
ToothpasteTubeGraphics
DownFacingToothpasteTube_03
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
;
; last 7 bytes bytes shared with next table so don't cross page boundaries
;
UpFacingToothpasteTube_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
DownFacingToothpasteTube_02
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
;
; last 5 bytes shared with next table so don't cross page boundaries
;
UpFacingToothpasteTube_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
DownFacingToothpasteTube_04
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
;
; last 9 bytes shared with next table so don't cross page boundaries
;
UpFacingToothpasteTube_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
DownFacingToothpasteTube_05
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
;
; last 11 bytes shared with next table so don't cross page boundaries
;
BlankToothpasteTube   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
;
; last 12 bytes shared with next table so don't cross page boundaries
;
UpFacingToothpasteTube_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
DownFacingToothpasteTube_01
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
;
; last 3 bytes shared with next table so don't cross page boundaries
;
UpFacingToothpasteTube_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
UpFacingToothpasteTube_00
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $88 ; |X...X...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
DownFacingToothpasteTube_00
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
   
TeethNUSIZValues
   .byte ONE_COPY, TWO_MED_COPIES, TWO_COPIES, THREE_COPIES
   
JunkFoodGraphics
HamburgerGraphics
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
StrawberriesGraphics
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $5E ; |.X.XXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $5E ; |.X.XXXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $14 ; |...X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
HotdogGraphics
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GumDropsGraphics
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FriesGraphics
   .byte $00 ; |........|
   .byte $7F ; |.XXXXXXX|
   .byte $6B ; |.XX.X.XX|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $6B ; |.XX.X.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $AF ; |X.X.XXXX|
   .byte $25 ; |..X..X.X|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
DonutsGraphics
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
CandyCanesGraphics
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $33 ; |..XX..XX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
IceCreamConesGraphics
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

ToothGraphic
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
ToothDecayGraphic_2
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ToothDecayGraphic_1   
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ToothDecayGraphic_0
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
JunkFoodNUSIZIndexMaskingValues
   .byte %110
   .byte %100
   .byte %000
   .byte %000
   .byte %000
   .byte %000
   .byte %001
   .byte %011
   .byte %111
   
ToothpasteTubeColors
   .byte COLOR_PLAYER1_TOOTHPASTE_TUBE, COLOR_PLAYER2_TOOTHPASTE_TUBE

PlayToothPlacementSounds
   bit gameState                    ; check current game state
   bmi .donePlayToothPlacementSounds; branch if in DEMO_MODE
   lda #31
   sta toothPlacementSoundVolume
   sta AUDV0
   sta AUDV1
   lda #12
   sta AUDC0
   sta AUDC1
   inc toothPlacementSoundValues
   lda toothPlacementSoundValues
   clc
   adc #2
   eor #$1F
   sta AUDF0
   lsr
   sta AUDF1
   lda lowerTeethValues
   ora upperTeethValues
   bne .donePlayToothPlacementSounds
   lda #TOOTH_PLACEMENT_SOUND_FRAME_DELAY
   sta frameDelayValue
.donePlayToothPlacementSounds
   jmp MainLoop

JunkFoodColors
HamburgerColors
   .byte BLACK, RED_ORANGE + 8, RED_ORANGE + 8, YELLOW + 2, GREEN + 4, RED + 2
   .byte YELLOW + 10, YELLOW + 2, RED_ORANGE + 8, RED_ORANGE + 6, RED_ORANGE + 4
StrawberriesColors
   .byte BLACK, RED + 2, RED + 2, RED + 4, RED + 4, RED + 4, RED + 4, RED + 4
   .byte RED + 2, RED + 2, GREEN + 6, GREEN + 6, GREEN + 6, GREEN + 6
HotdogColors
   .byte BLACK, YELLOW + 4, YELLOW + 6, YELLOW + 8, COLOR_HOT_DOG + 2
   .byte COLOR_HOT_DOG + 2, YELLOW + 8, YELLOW + 4, BLACK
GumDropsColors
   .byte BLACK, RED + 2, RED + 4, RED + 4, RED + 4, RED + 4, RED + 4, RED + 2
   .byte GREEN + 6, GREEN + 6, GREEN + 6, GREEN + 6, GREEN + 6, GREEN + 6
FriesColors
   .byte BLACK, WHITE - 2, WHITE - 2, WHITE - 2, WHITE - 2, WHITE - 2, WHITE - 2
   .byte YELLOW + 4, YELLOW + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8
DonutsColors
   .byte BLACK, RED_ORANGE + 4, RED_ORANGE + 4, RED_ORANGE + 4, RED + 10
   .byte RED + 10, RED + 10, RED + 10, RED + 10
CandyCanesColors
   .byte BLACK, WHITE - 2, WHITE - 2, RED + 4, RED + 4, WHITE - 2, WHITE - 2
   .byte RED + 4, RED + 4, WHITE - 2, WHITE - 2, RED + 4, RED + 4, WHITE - 2
IceCreamConesColors
   .byte BLACK, RED_ORANGE + 8, RED_ORANGE + 8, RED_ORANGE + 8, RED_ORANGE + 8
   .byte RED_ORANGE + 8, RED_ORANGE + 8, GREEN + 6, GREEN + 6, GREEN + 6
   .byte WHITE - 2, RED + 4, RED + 4, RED + 4
   
PF1GumGraphicValues
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

PF2GumGraphicValues
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
ToothDecayAnimationValues
   .byte <ToothGraphic, <ToothDecayGraphic_2, <ToothDecayGraphic_1
   .byte <ToothDecayGraphic_0, <ToothGraphic
   
JunkFoodGraphicLSBValues
   .byte <HamburgerGraphics, <HotdogGraphics, <FriesGraphics
   .byte <StrawberriesGraphics, <GumDropsGraphics, <DonutsGraphics
   .byte <CandyCanesGraphics, <IceCreamConesGraphics

JunkFoodColorLSBValues
   .byte <HamburgerColors, <HotdogColors, <FriesColors, <StrawberriesColors
   .byte <GumDropsColors, <DonutsColors, <CandyCanesColors, <IceCreamConesColors
   
UpFacingToothpasteTubeLSBValues
   .byte <BlankToothpasteTube
   .byte <UpFacingToothpasteTube_05
   .byte <UpFacingToothpasteTube_05
   .byte <UpFacingToothpasteTube_04
   .byte <UpFacingToothpasteTube_04
   .byte <UpFacingToothpasteTube_03
   .byte <UpFacingToothpasteTube_03
   .byte <UpFacingToothpasteTube_02
   .byte <UpFacingToothpasteTube_02
   .byte <UpFacingToothpasteTube_01
   .byte <UpFacingToothpasteTube_01
   .byte <UpFacingToothpasteTube_00
   
DownFacingToothpasteTubeLSBValues
   .byte <BlankToothpasteTube
   .byte <DownFacingToothpasteTube_05
   .byte <DownFacingToothpasteTube_05
   .byte <DownFacingToothpasteTube_04
   .byte <DownFacingToothpasteTube_04
   .byte <DownFacingToothpasteTube_03
   .byte <DownFacingToothpasteTube_03
   .byte <DownFacingToothpasteTube_02
   .byte <DownFacingToothpasteTube_02
   .byte <DownFacingToothpasteTube_01
   .byte <DownFacingToothpasteTube_01
   .byte <DownFacingToothpasteTube_00
       
ChangeJunkFoodVerticalDirection
   lda lowerTeethPatternIndex       ; get lower teeth pattern value
   ora upperTeethPatternIndex       ; combine with upper teeth pattern value
   beq .doneChangeJunkFoodVerticalDirection;branch if no teeth left
   bit currentWaveStatus            ; check current wave status
   bvc .checkJunkFoodDirectionToTeeth;branch if tooth not decaying
.changeJunkFoodVerticalDirection
   lda currentWaveStatus            ; get current wave status values
   and #JUNK_FOOD_VERT_DIR_MASK
   eor #JUNK_FOOD_VERT_DIR_MASK
   sta currentWaveStatus
.checkJunkFoodDirectionToTeeth
   lda currentWaveStatus            ; get current wave status values
   asl                              ; shift JUNK_FOOD_VERT_DIR_MASK to carry
   rol                              ; rotate JUNK_FOOD_VERT_DIR_MASK to D0
   and #1
   tax
   lda teethPatternIndexes,x        ; get tooth pattern values
   beq .changeJunkFoodVerticalDirection;branch if no teeth in desired direction
.doneChangeJunkFoodVerticalDirection
   rts

Div16
ShiftUpperNybblesToLower
Waste20Cycles
   lsr
Waste18Cycles
   lsr
Waste16Cycles
   lsr
   lsr
   rts
       
DestroyedJunkFoodMaskingValues
   .byte 3, 5, 6, 3, 3, 1, 5, 4, 6, 6, 4
   
BitMaskingIndexValues
   .byte 0, 7, 1, 6, 2, 5, 3, 4
   
WavePointValueTable
   .byte WAVE_01_POINTS, WAVE_02_POINTS, WAVE_03_POINTS, WAVE_04_POINTS
   .byte WAVE_05_POINTS, WAVE_06_POINTS, WAVE_07_POINTS, WAVE_08_POINTS

   FILL_BOUNDARY 0, 234
   
NumberFonts
zero
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
one
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
two
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3C ; |..XXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $46 ; |.X...XX.|
   .byte $3C ; |..XXXX..|
three
   .byte $3C ; |..XXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $46 ; |.X...XX.|
   .byte $3C ; |..XXXX..|
four
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $7E ; |.XXXXXX.|
   .byte $4C ; |.X..XX..|
   .byte $2C ; |..X.XX..|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
five
   .byte $7C ; |.XXXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7C ; |.XXXXX..|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
six
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $60 ; |.XX.....|
   .byte $62 ; |.XX...X.|
   .byte $3C ; |..XXXX..|
seven
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
eight
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
nine
   .byte $3C ; |..XXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $3E ; |..XXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
       
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
ActivisionLogo_0
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ActivisionLogo_1
   .byte $2D ; |..X.XX.X|
   .byte $29 ; |..X.X..X|
   .byte $E9 ; |XXX.X..X|
   .byte $A9 ; |X.X.X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $61 ; |.XX....X|
   .byte $2F ; |..X.XXXX|
   .byte $00 ; |........|
ActivisionLogo_2
   .byte $50 ; |.X.X....|
   .byte $58 ; |.X.XX...|
   .byte $5C ; |.X.XXX..|
   .byte $56 ; |.X.X.XX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
ActivisionLogo_3
   .byte $BA ; |X.XXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $3A ; |..XXX.X.|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
ActivisionLogo_4 
   .byte $E9 ; |XXX.X..X|
   .byte $AB ; |X.X.X.XX|
   .byte $AF ; |X.X.XXXX|
   .byte $AD ; |X.X.XX.X|
   .byte $E9 ; |XXX.X..X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
Copyright_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F7 ; |XXXX.XXX|
   .byte $95 ; |X..X.X.X|
   .byte $87 ; |X....XXX|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
Copyright_1
   .byte $00 ; |........|
   .byte $47 ; |.X...XXX|
   .byte $41 ; |.X.....X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $75 ; |.XXX.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
Copyright_2
   .byte $00 ; |........|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $4B ; |.X..X.XX|
   .byte $4A ; |.X..X.X.|
   .byte $6B ; |.XX.X.XX|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
Copyright_3
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $27 ; |..X..XXX|
   .byte $22 ; |..X...X.|
Copyright_4
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $17 ; |...X.XXX|
Copyright_5
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $73 ; |.XXX..XX|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|
   
ActivisionRainbowColors
   .byte BLUE + 4, DK_GREEN + 6, DK_GREEN + 6, YELLOW + 10
   .byte RED_ORANGE + 6, RED_ORANGE + 6, RED + 4, BLACK
   
BitMaskingValues
   .byte %11111110
   .byte %11111101
   .byte %11111011
   .byte %11110111
   .byte %11101111
   .byte %11011111
   .byte %10111111
   .byte %01111111
   
BitIsolationValues
   .byte %00000001
   .byte %00000010
   .byte %00000100
   .byte %00001000
   .byte %00010000
   .byte %00100000
   .byte %01000000
   .byte %10000000

ToothHorizontalPositionValues
   .byte 11, 28, 44, 61, 77, 94
   
BonusToothIndicator
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|

JunkFoodHeightValues
   .byte H_HAMBURGER - 1
   .byte H_HOTDOG - 1
   .byte H_FRIES - 1
   .byte H_STRAWBERRY - 1
   .byte H_GUM_DROPS - 1
   .byte H_DONUTS - 1
   .byte H_CANDY_CANES - 1
   .byte H_ICE_CREAM_CONES - 1
   
NextRandom
   lda randomSeed
   asl
   asl
   asl
   eor randomSeed
   asl
   rol randomSeed
   jmp ChangeJunkFoodVerticalDirection
       
JunkFoodHorizOffsetTable
   .byte 0, 32, 16, 16, 0;, 0, 0, 0
;
; last 3 bytes shared with table below
;   
PlayerNUSIZValueTable
   .byte ONE_COPY, ONE_COPY, ONE_COPY, TWO_COPIES
   .byte ONE_COPY, TWO_MED_COPIES, TWO_COPIES, THREE_COPIES

   .org ROM_BASE + 4096 - 4, 234
   .word Start
   .word Start
   
   echo "***",(FREE_BYTES)d, "BYTES OF ROM FREE"