   LIST OFF
; ***  G R A N D  P R I X  ***
; Copyright 1982 Activision, Inc.
; Designer: David Crane

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 8, 2016
;
;  *** 125 BYTES OF RAM USED 3 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================
;
; - Kernel consists of 5 horizontal bands for cars and obstacles
; - Each horizontal band is 32 scanlines high
; - David Crane did an excellent break down of Grand Prix at the PRGE 2015
;     https://www.youtube.com/watch?v=nbinkHyWde8
; - Added PAL60 switch to make for an easy PAL60 conversion
; - PAL50 version ~17% slower than NTSC
; - PAL50 timer can be easily adjusted by setting
;     MICROSECONDS_PER_FRAME = 20055 and MICRO_SECONDS_BCD = $20. This will make
;     the timer accurate for the frame refresh rate however the sprites are not
;     fractionally positioned so your finishing time would be worse
; - Moving vertically reduces player speed by ~6%
; - Cars are a single sprite character...NUSIZx is manipulated each scanline
; - I found positioning lower left trees interesting. The coarse position
;     and an additional fine motion adjustment is based on D7 being set high

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
; F R A M E - T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 54
OVERSCAN_TIME           = 30

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 80
OVERSCAN_TIME           = 63
   
   ENDIF
   
MICROSECONDS_PER_FRAME  = 16686
MICRO_SECONDS_BCD       = $16

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
YELLOW_2                = YELLOW
LT_RED                  = $20
RED                     = $30
ORANGE                  = $40
ORANGE_2                = ORANGE
DK_PINK                 = $50
BLUE                    = $80
LT_BLUE                 = $90
CYAN                    = $A0
GREEN                   = $C0
DK_GREEN                = $D0
DK_GREEN_2              = DK_GREEN

COLOR_XOR               = $D0

   ELSE

YELLOW                  = $20
YELLOW_2                = $10
LT_RED                  = $40
RED                     = $60
ORANGE                  = $60
ORANGE_2                = $80
DK_PINK                 = $A0
BLUE                    = $B0
LT_BLUE                 = $C0
CYAN                    = $A0
GREEN                   = $50
DK_GREEN                = $50
DK_GREEN_2              = $D0

COLOR_XOR               = $A0

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

SELECT_DELAY            = 30

KERNEL_SECTIONS         = 5
H_DIGITS                = 8
H_SPRITES               = 32
H_BORDER_TREES          = 13
H_RIVER                 = 39
H_BRIDGE                = 57

OBSTACLE_GEAR_NEUTRAL   = 0
OBSTACLE_GEAR_LOW       = 1
OBSTACLE_GEAR_MID       = 2
OBSTACLE_GEAR_HIGH      = 3

RIVER_CRASH             = $80       ; used to set crashTimer D7 to 1
MAX_CRASH_TIME          = 15

MAX_TRACK_POSITION      = 63

TRACK_BRIDGE_01         = %01000000
TRACK_BRIDGE_02         = %10000000
TRACK_BRIDGE_03         = %11000000

; objectType ids
ID_CAR                  = 0
ID_OIL_SLICK            = 1

W_SCREEN                = 159       ; width of display area

XMIN                    = 0
XMAX                    = W_SCREEN + 24

INIT_PLAYER_VERT_POS    = 85

SPEED_MIN               = 0
SPEED_MAX               = 127

OIL_SLICK_DELAY_MAX     = 8

YMIN                    = 30
YMAX                    = 140

MICRO_SECONDS           = (MICROSECONDS_PER_FRAME / 1000)
MICRO_SECONDS_DELAY     = 256 * [MICROSECONDS_PER_FRAME - (MICRO_SECONDS * 1000)] / 1000

BLANK_OFFSET            = (Blank - NumberFonts) / H_DIGITS

; game state values
GAME_IN_PROGRESS        = %10000000

;===============================================================================
; M A C R O S
;===============================================================================

  MAC FILL_NOP
      REPEAT {1}
         NOP
      REPEND
  ENDM

;
; time wasting macros
;
; These are used to help reduce ROM usage.
;

   MAC SLEEP_3
      lda div16Remainder
   ENDM
   
   MAC SLEEP_5
      dec div16Remainder
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gameSelection           ds 1        ; game selection valid values from 0 - 3
frameCount              ds 1        ; current frame count
random                  ds 1        ; psuedo random number see NextRandom
selectDebounce          ds 1        ; non-zero shows SELECT held
joystickValue           ds 1
colorEOR                ds 1
hueMask                 ds 1
objectColors
;--------------------------------------
treeColors              ds 2        ; 2 bytes used but trees are the same color
riverColor              ds 1
gardenDirtColor         ds 1
roadColor               ds 1
backgroundColor         ds 1
copyrightColor          ds 1
grassColor              ds 1
playerCarColors         ds H_SPRITES; colors for player car stored in RAM
playerVertPos           ds 1        ; values range from 30 - 140
lowerLeftTreeHorizPosValues ds 1
kernelSection           ds 1        ; used in kernel to track current section
;--------------------------------------
loopCount               = kernelSection
riverCollision          ds 1        ; non-zero value player collided with river
collisionKernelSection  ds 1        ; stores section car collided with obstacle
obstacleLSBValues       ds KERNEL_SECTIONS
obstacleSizeLSBValues   ds KERNEL_SECTIONS
obstacleColorLSBValues  ds KERNEL_SECTIONS
obstacleCoarseValues    ds KERNEL_SECTIONS
obstacleFineMotion      ds KERNEL_SECTIONS
playerCarGraphicPtr     ds 2
obstacleGraphicPtr      ds 2
obstacleSizePtr         ds 2
obstacleColorPtr        ds 2
graphicPointers         ds 10       ; used for 6-digit display
gameSelectionPointers   ds 2
;--------------------------------------
div16Remainder          = gameSelectionPointers
;--------------------------------------
tmpRandomXOR            = div16Remainder
;--------------------------------------
tmpEngineVolume         = tmpRandomXOR
;--------------------------------------
tmpPlayerGraphicPtr     = tmpEngineVolume
;--------------------------------------
tmpPlayerAnimationDelay = tmpPlayerGraphicPtr
;--------------------------------------
playerVertMovementDelay = tmpPlayerAnimationDelay
;--------------------------------------
tmpPlayerSpeedDiv16     = playerVertMovementDelay
;--------------------------------------
tmpObstacleHorizPos     = tmpPlayerSpeedDiv16
;--------------------------------------
tmpRandomValue          = tmpObstacleHorizPos
;--------------------------------------
tempFineMotionValue     = gameSelectionPointers + 1
;--------------------------------------
tempPlayerSpeed         = tempFineMotionValue
;--------------------------------------
tempObstacleSpeed       = tempPlayerSpeed
colorCycleMode          ds 1
gameState               ds 1
obstacleHorizPositions  ds KERNEL_SECTIONS
;--------------------------------------
lowerRightTreeHorizPos  = obstacleHorizPositions
obstaclesSpeed          ds 1
currentTrackPosition    ds 1
crashTimer              ds 1
elapsedTime             ds 3
microSecondsFraction    ds 1
playerSpeed             ds 1
playerAnimiationDelayValue ds 1
treeHorizPos            ds 1
riverEdgeHorizPos       ds 1
showingBridge           ds 1        ; non-zero means showing bridge
oilSlickSlideTime       ds 1
playerCarAnimationIndex ds 1
playfieldGraphicData    ds 6
;--------------------------------------
leftPF0GraphicData      = playfieldGraphicData
leftPF1GraphicData      = leftPF0GraphicData + 1
leftPF2GraphicData      = leftPF1GraphicData + 1
rightPF0GraphicData     = leftPF2GraphicData + 1
rightPF1GraphicData     = rightPF0GraphicData + 1
rightPF2GraphicData     = rightPF1GraphicData + 1
gameSelectionGraphic    ds 1
;--------------------------------------
tempSpeed               = gameSelectionGraphic
;--------------------------------------
tempDigitChar           = tempSpeed

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E  (BANK 0)
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
RestartGame
   lda #0
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   lda #MSBL_SIZE8 | PF_PRIORITY
   sta CTRLPF
   jsr InitializeGame
   lda random
   bne MainLoop                     ; branch to MainLoop if not system startup
   ldx #1
   stx random                       ; seed random number generator
   jmp JumpIntoConsoleSwitchCheck

MainLoop
   ldx #7
.setObjectColors
   lda GameColors,x                 ; read game color table
   eor colorEOR                     ; flip color bits based on color cycling
   and hueMask                      ; mask color values for COLOR / B&W mode
   sta objectColors,x
   cpx #<[roadColor - objectColors] ; branch if not tree, river, or dirt colors
   bcs .nextObjectColor
   sta COLUP0,x
.nextObjectColor
   dex
   bpl .setObjectColors
   stx collisionKernelSection       ; reset collision section value (i.e. x = -1)
   lda treeHorizPos
   and #$1F
   clc
   adc #4
   inx                              ; x = 0 (i.e. HMP0)
   jsr CalculateObjectHorizPosition ; calculate position for left group of trees
   jsr PositionObjectsHorizontally  ; position left group of trees
   lda treeHorizPos
   and #$1F
   clc
   adc #68                          ; increment to postion right trees
   inx                              ; x = 1 (i.e. HMP1)
   jsr CalculateObjectHorizPosition ; calculate position for right group of trees
   jsr PositionObjectsHorizontally  ; position right group of trees
   ldx #<[HMM1 - HMP0]
   lda riverEdgeHorizPos            ; get the river edge horizontal position
   beq .positionRiverEdge           ; branch if off the screen
   ldy showingBridge
   bne .positionRiverEdge           ; branch if showing bridge
   adc #9
.positionRiverEdge
   jsr CalculateObjectHorizPosition ; calculate position for river edge
   jsr PositionObjectsHorizontally  ; position river edge
   inx                              ; x = 4 (i.e. HMBL)
   ldy riverEdgeHorizPos            ; get the river edge horizontal position
   iny                              ; increment by one pixel
   tya
   jsr CalculateObjectHorizPosition ; position BALL one pixel to the right
   jsr PositionObjectsHorizontally
   jsr MoveObjectsHorizontally
   sta WSYNC                        ; wait for next scan line
   sta HMCLR                        ; clear horizontal motion values
   sta CXCLR                        ; clear collision registers
   lda crashTimer                   ; get the crash timer
   and #$0F
   cmp #<[backgroundColor - gameSelection + 1]
   bcc .setupKernelToDrawTrees      ; skip flashing road color for crash
   tax
   lda gameSelection - 1,x
   sta roadColor                    ; flash road color for crash
.setupKernelToDrawTrees
   lda #THREE_MED_COPIES
   sta NUSIZ0
   sta NUSIZ1
   sta ENABL                        ; enable BALL (i.e. D1 = 1)
   ldx #H_BORDER_TREES
   ldy playerVertPos
   lda leftPF0GraphicData
   sta PF0
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta VBLANK                 ; 3 = @06   enable TIA (D1 = 0)
   SLEEP_5                    ; 5
   SLEEP 2                    ; 2
   jmp .jmpIntoKernel         ; 3

.doneDrawUpperBorderLoop
   stx NUSIZ0                 ; 3 = @65   set to ONE_COPY (i.e. x = 0)
   stx NUSIZ1                 ; 3 = @68
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3 = @73
   lda backgroundColor        ; 3 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   sta COLUP0                 ; 3 = @09
   sta COLUP1                 ; 3 = @12
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @18
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @24
   sta RESP0                  ; 3 = @27   set player car to pixel 81
   sta CXCLR                  ; 3 = @30   clear all collisions
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @36
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @42
   lda rightPF2GraphicData    ; 3
   sta PF2                    ; 3 = @48
   jmp .determineBridgeOrObstacleKernel;3

.drawUpperBorderLoop
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @57
   txa                        ; 2         move kernel index to accumulator
   beq .doneDrawUpperBorderLoop;2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP_3                    ; 3
   lda BorderTreeSprite,x     ; 4
   sta GRP0                   ; 3 = @13
   sta GRP1                   ; 3 = @16
.jmpIntoKernel
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @22
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @28
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @34
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @40
   lda rightPF2GraphicData    ; 3
   dex                        ; 2
   sta PF2                    ; 3 = @48
   bpl .drawUpperBorderLoop   ; 3         unconditional branch

.determineBridgeOrObstacleKernel
   lda riverEdgeHorizPos      ; 3
   ora showingBridge          ; 3
   beq .enterObstacleKernel   ; 2³        branch if not showing bridge
   ldx #H_RIVER               ; 2
   lda #$1F                   ; 2
   cpy #H_SPRITES - 2         ; 2
   bne .beginBridgeKernel     ; 2³
   sta GRP0                   ; 3 = @69
.beginBridgeKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda roadColor              ; 3
   sta COLUBK                 ; 3 = @09
   jmp .jmpIntoBridgeKernel   ; 3

.enterObstacleKernel
   jmp StartObstacleKernel    ; 3

.skipDrawUpperBridgeKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   sec                        ; 2
   bcs .jmpIntoBridgeKernel   ; 3         unconditional branch

.skipDrawPlayerCarBridgeKernel_1
   lda backgroundColor        ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUPF                 ; 3 = @06
   lda #0                     ; 2
   sta GRP0                   ; 3 = @11
   beq .startDrawMiddleBridgeKernel;3     unconditional branch

.skipDrawPlayerCarMiddleBridge
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   beq .jmpIntoMiddleBridgeKernel;3       unconditional branch

.drawUpperBridgeLoop
   cpy #H_SPRITES             ; 2
   bcs .skipDrawUpperBridgeKernel;2³
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @67
   lda (playerCarGraphicPtr),y; 5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @13
.jmpIntoBridgeKernel
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @19
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @25
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @31
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @37
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @43
   lda rightPF2GraphicData    ; 3
   dey                        ; 2
   sta PF2                    ; 3 = @51
   dex                        ; 2
   bpl .drawUpperBridgeLoop   ; 2³
   cpy #H_SPRITES             ; 2
   bcs .skipDrawPlayerCarBridgeKernel_1;2³
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @66
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @73
   lda backgroundColor        ; 3 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUPF                 ; 3 = @06
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @14
.startDrawMiddleBridgeKernel
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @20
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @26
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @32
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @38
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @44
   lda rightPF2GraphicData    ; 3
   sta PF2                    ; 3 = @50
   dey                        ; 2
   ldx #H_BRIDGE              ; 2
.drawMiddleBridgeKernel
   cpy #H_SPRITES             ; 2
   bcs .skipDrawPlayerCarMiddleBridge;2³
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @66
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @73
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @10
   lda #DISABLE_BM            ; 2
.jmpIntoMiddleBridgeKernel
   sta ENAM1                  ; 3 = @15
   sta ENABL                  ; 3 = @18
   sta PF0                    ; 3 = @21
   sta PF1                    ; 3 = @24
   sta PF2                    ; 3 = @27
   dey                        ; 2
   dex                        ; 2
   bpl .drawMiddleBridgeKernel; 2³
   bmi DrawLowerBridgeKernel  ; 3         unconditional branch

.skipPlayerCarDrawLowerBridge_1
   lda #0                     ; 2
   sta GRP0                   ; 3 = @48
   beq .jmpIntoStartLowerBridgeKernel;3 + 1     crosses page boundary

.skipPlayerCarDrawLowerBridge_2
   lda #0                     ; 2
   sta GRP0                   ; 3 = @62
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda riverColor             ; 3
   sta.w COLUPF               ; 4 = @10
   jmp .jmpIntoSecondScanlineLowerBridge;3

.skipPlayerCarDrawLowerBridge_3
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta.w GRP0                 ; 4 = @07
   jmp .jmpIntoDrawLowerBridge; 3

DrawLowerBridgeKernel
   ldx #H_RIVER - 1           ; 2 = @38
   cpy #H_SPRITES             ; 2
   bcs .skipPlayerCarDrawLowerBridge_1;2³
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @50
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @57
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @64
.jmpIntoStartLowerBridgeKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dey                        ; 2
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3 = @10
   sta ENABL                  ; 3 = @13
   SLEEP 2                    ; 2
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @21
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @27
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @33
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @39
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @45
   lda rightPF2GraphicData    ; 3
   sta PF2                    ; 3 = @51
   cpy #H_SPRITES             ; 2
   bcs .skipPlayerCarDrawLowerBridge_2;2³ + 1   crosses page boundary
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @63
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @70
   lda riverColor             ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUPF                 ; 3 = @06
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @13
.jmpIntoSecondScanlineLowerBridge
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @19
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @25
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @31
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @37
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @43
   lda rightPF2GraphicData    ; 3
   dey                        ; 2
   sta PF2                    ; 3 = @51
.drawLowerBridgeLoop
   cpy #H_SPRITES             ; 2
   bcs .skipPlayerCarDrawLowerBridge_3;2³+ 1    crosses page boundary
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @63
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @70
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @10
.jmpIntoDrawLowerBridge
   dey                        ; 2
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @18
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @24
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @30
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @36
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @42
   lda rightPF2GraphicData    ; 3
   dex                        ; 2
   sta PF2                    ; 3 = @50
   bpl .drawLowerBridgeLoop   ; 2³
StatusKernel
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @58
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @64
   ldy #HMOVE_0               ; 2         assume no motion adjustment for trees
   sty GRP0                   ; 3 = @68   clear GRP0 value
   lda backgroundColor        ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta.w COLUBK               ; 4 = @07
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @13
   lda lowerLeftTreeHorizPosValues;3      get lower tree horizontal value
   asl                        ; 2         shift D7 to carry
   bcc .positionLowerTrees    ; 2³        coarse sprite to pixel 72 if clear
   ldy #HMOVE_R3              ; 2         shift trees right 3 additional pixels
   SLEEP 2                    ; 2         sleep 4 cycles to coarse position
   SLEEP 2                    ; 2         left trees to pixel 87
.positionLowerTrees
   sta RESP0                  ; 3 = @29
   sta HMP0                   ; 3 = @32
   lda CXP0FB                 ; 3         check if player car touched river
   sta riverCollision         ; 3         save collision value
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @44
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @50
   lda rightPF2GraphicData    ; 3
   sta PF2                    ; 3 = @56
   ldx #DISABLE_BM            ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx ENAM1                  ; 3 = @06
   lda gardenDirtColor        ; 3
   sta COLUBK                 ; 3 = @12
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @18
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @24
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @30
   lda #THREE_MED_COPIES      ; 2
   sta NUSIZ1                 ; 3 = @35
   sta NUSIZ0                 ; 3 = @38
   sty HMP0                   ; 3 = @41
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @47
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @53
   lda rightPF2GraphicData    ; 3
   sta PF2                    ; 3 = @59
   lda treeColors             ; 3
   sta COLUP0                 ; 3 = @65
   sta COLUP1                 ; 3 = @68
   ldx #H_BORDER_TREES - 1    ; 2
.drawLowerBorderLoop
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda BorderTreeSprite,x     ; 4
   sta GRP0                   ; 3 = @10
   sta GRP1                   ; 3 = @13
   lda leftPF0GraphicData     ; 3
   sta PF0                    ; 3 = @19
   lda leftPF1GraphicData     ; 3
   sta PF1                    ; 3 = @25
   lda leftPF2GraphicData     ; 3
   sta PF2                    ; 3 = @31
   lda rightPF0GraphicData    ; 3
   sta PF0                    ; 3 = @37
   lda rightPF1GraphicData    ; 3
   sta PF1                    ; 3 = @43
   lda rightPF2GraphicData    ; 3
   sta HMCLR                  ; 3 = @49
   sta PF2                    ; 3 = @52
   dex                        ; 2
   bne .drawLowerBorderLoop   ; 2³
   lda backgroundColor        ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda #THREE_COPIES          ; 2
   sta.w NUSIZ0               ; 4 = @12
   stx PF0                    ; 3 = @15   clear playfield registers (i.e. x = 0)
   stx PF1                    ; 3 = @18
   stx ENABL                  ; 3 = @21   disable BALL
   stx PF2                    ; 3 = @24
   sta.w RESP0                ; 4 = @28
   sta RESP1                  ; 3 = @31
   lsr                        ; 2
   sta NUSIZ1                 ; 3 = @36   set GRP1 to TWO_COPIES
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @41
   lda grassColor             ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda #DK_GREEN_2            ; 2
   eor colorEOR               ; 3
   and hueMask                ; 3
   sta COLUP0                 ; 3 = @17
   sta COLUP1                 ; 3 = @20
   sta.w HMCLR                ; 4 = @24   clear horizontal motion values
   jsr Sleep12Cycles          ; 15
   lda #H_DIGITS - 1          ; 2
   sta loopCount              ; 3
.drawElapsedTime
   ldy.w loopCount            ; 4
   lda (graphicPointers + 6),y; 5
   lsr                        ; 2
   tax                        ; 2
   sta HMCLR                  ; 3 = @60
   lda (graphicPointers),y    ; 5
   sta GRP0                   ; 3 = @68
   lda (graphicPointers + 8),y; 5
   and #$FE                   ; 2
;--------------------------------------
   sta HMOVE                  ; 3 = @02
   sta tempDigitChar          ; 3
   lda (graphicPointers + 2),y; 5
   lsr                        ; 2
   sta GRP1                   ; 3 = @15
   lda (graphicPointers + 4),y; 5
   and DecimalGraphicMask,y   ; 4
   ldy tempDigitChar          ; 3
   sta GRP0                   ; 3 = @30
   stx GRP1                   ; 3 = @33
   sty GRP0                   ; 3 = @36
   dec loopCount              ; 5
   bpl .drawElapsedTime       ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   sta GRP1                   ; 3 = @11
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda backgroundColor        ; 3
   sta COLUBK                 ; 3 = @09
   lda copyrightColor         ; 3
   sta COLUP0                 ; 3 = @15
   sta COLUP1                 ; 3 = @18
   lda #THREE_COPIES          ; 2
   sta NUSIZ1                 ; 3 = @23
   lsr                        ; 2
   sta NUSIZ0                 ; 3 = @28
   lda gameSelection          ; 3         get current game selection
   asl                        ; 2         multiply value by 8
   asl                        ; 2
   asl                        ; 2
   adc #8                     ; 2
   sta gameSelectionPointers  ; 3
   lda #>NumberFonts          ; 2
   sta gameSelectionPointers + 1;3
   ldy #H_DIGITS - 1          ; 2
.drawActivisionLogo
   lda (gameSelectionPointers),y; 5
   lsr                        ; 2         shift right to remove ":"
   sta gameSelectionGraphic   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda Copyright_0,y          ; 4
   sta GRP0                   ; 3 = @10
   lda Copyright_1,y          ; 4
   sta GRP1                   ; 3 = @17
   SLEEP 2                    ; 2
   lda Copyright_3,y          ; 4
   tax                        ; 2
   lda Copyright_2,y          ; 4
   sta GRP0                   ; 3 = @32
   stx GRP1                   ; 3 = @35
   lda gameSelectionGraphic   ; 3
   sta GRP1                   ; 3 = @41
   dey                        ; 2
   bpl .drawActivisionLogo    ; 2³
Overscan
   lda #OVERSCAN_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for overscan period
   stx GRP1
   lda #DISABLE_TIA
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   ldx #H_SPRITES - 1
.setPlayerCarColors
   lda PlayerCarColors,x
   cmp #YELLOW_2
   bcc .determinePlayerColorHue
   eor #COLOR_XOR
.determinePlayerColorHue
   eor colorEOR
   and hueMask
   sta playerCarColors,x
   dex
   bpl .setPlayerCarColors
   lda riverEdgeHorizPos
   ora showingBridge
   bne CheckPlayerCollisions        ; branch if player on the bridge
   ldx #2
.bcd2DigitLoop
   txa                              ; move x to accumulator
   asl                              ; multiply the value by 4 so it can
   asl                              ; be used for the graphicPointers indexes
   tay
   lda elapsedTime,x                ; get the player's elapsed time
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide the value by 2
   sta graphicPointers,y            ; set LSB pointer to digit
   lda elapsedTime,x                ; get the player's elapsed time
   and #$0F                         ; mask the upper nybbles
   asl                              ; multiply value by 8
   asl
   asl
   sta graphicPointers + 2,y        ; set LSB pointer to digit
   dex
   bpl .bcd2DigitLoop
CheckPlayerCollisions
   lda CXM1P                        ; check M1 and player collision
   bpl .checkToBounceOffRiverCollision; branch if player didn't hit river edge
   lda showingBridge
   beq .checkToBounceOffRiverCollision; branch if not showing bridge
   lda #SPEED_MIN
   sta playerSpeed                  ; set player speed to 0
   lda #RIVER_CRASH | MAX_CRASH_TIME
   sta crashTimer
.checkToBounceOffRiverCollision
   lda crashTimer                   ; get current crash timer value
   bpl .checkCarOrOilSlickCollision ; branch if car didn't collide with river
   inc riverEdgeHorizPos            ; bounce player car off river
   inc treeHorizPos
.checkCarOrOilSlickCollision
   ldx currentTrackPosition         ; get the current track position
   inx
   beq .reduceOilSlickSlideTime     ; branch if reached the end of the track
   lda gameState                    ; get current game state
   asl                              ; shift GAME_IN_PROGRESS to carry
   bne .reduceOilSlickSlideTime     ; skip game collisions if race is over
   ldx collisionKernelSection       ; get kernel section where collision occurred
   bmi .reduceOilSlickSlideTime     ; branch if no collision occurred
   lda obstacleFineMotion + 1,x     ; get obstacle fine motion value
   lsr                              ; shift object type to carry
   bcc .playerCollidedWithCar       ; branch if didn't collide with oil slick
   lda #OIL_SLICK_DELAY_MAX
   sta oilSlickSlideTime            ; set the oil slick slide timer value
   bcs .reduceOilSlickSlideTime     ; unconditional branch

.playerCollidedWithCar
   lda obstaclesSpeed
.determineCrashSpeedReduction
   cmp #OBSTACLE_GEAR_LOW << 7      ; set carry if more than OBSTACLE_GEAR_LOW
   rol                              ; shift carry to D0
   cmp #OBSTACLE_GEAR_LOW << 7      ; set carry if more than OBSTACLE_GEAR_LOW
   rol                              ; shift carry to D0
   dex
   bpl .determineCrashSpeedReduction
   and #3                           ; only 4 values for speed reductions
   tay
   lda CrashValueSpeedReductions,y
   sta playerSpeed                  ; reduce speed for colliding with car
   lda #MAX_CRASH_TIME
   sta crashTimer
.reduceOilSlickSlideTime
   lda oilSlickSlideTime            ; get the oil slick slide timer value
   beq PlayGameSounds               ; branch if not sliding from oil slick
   dec oilSlickSlideTime            ; reduce oil slick slide timer
PlayGameSounds
   ldy #0
   sty tmpEngineVolume              ; clear value for engine volume
   lda gameState                    ; get current game state
   asl                              ; shift GAME_IN_PROGRESS to carry
   bne .setPassingCarEngineAudioChannel;branch if race is over
   lda currentTrackPosition         ; get the current track position
   cmp #TRACK_BRIDGE_03 | MAX_TRACK_POSITION - 1
   bcs .setPassingCarEngineAudioChannel; branch if race ending
   ldx #KERNEL_SECTIONS - 1
.determinePassingCarSound
   lda obstacleFineMotion,x         ; get obstacle fine motion value
   lsr                              ; shift object type to carry
   bcs .nextObstaclePosition        ; branch if object is an oil slick
   lda obstacleHorizPositions,x     ; get obstacle car horizontal position
   beq .nextObstaclePosition        ; branch if off the left edge of screen
   bmi .nextObstaclePosition        ; branch if off the right edge of screen
   and #$7F                         ; not needed...determined positive above
   cmp #(128 / 2)
   bcc .increaseEngineVolume
   eor #$7F
.increaseEngineVolume
   clc
   adc tmpEngineVolume
   bpl .setEngineVolume
   lda #$7F
.setEngineVolume
   sta tmpEngineVolume
.nextObstaclePosition
   dex
   bne .determinePassingCarSound
   lda tmpEngineVolume
   lsr                              ; divide value by 16 to get engine volume
   lsr
   lsr
   lsr
   sta AUDV1
   lda #16
   sta AUDF1
   ldy #3
.setPassingCarEngineAudioChannel
   sty AUDC1
   lda gameState                    ; get current game state
   asl                              ; shift GAME_IN_PROGRESS to carry
   bne .checkToPlayBrakingSound     ; branch if race is over
   lda playerSpeed                  ; get the player's speed
   beq .checkToPlayBrakingSound     ; branch if player not moving
   lda oilSlickSlideTime            ; get the oil slick slide timer value
   beq .checkToPlayBrakingSound     ; branch if not sliding from oil slick
   lda #4
   jsr ModulateEngineSound          ; modulate sound for oil slide
.checkToPlayBrakingSound
   ldy #0
   lda colorCycleMode               ; get the current color cycle mode value
   bmi .setPlayerEngineAudioChannel ; branch if in color cycling mode
   lda gameState                    ; get current game state
   asl                              ; shift GAME_IN_PROGRESS to carry
   bne .setPlayerEngineAudioChannel ; branch if race is over
   lda joystickValue                ; get the joystick value
   and #<(~MOVE_LEFT) >> 4          ; check if player is applying brakes
   bne .checkToPlayEngineAccelerationSound; branch if not applying brakes
   sta playerCarAnimationIndex      ; a = 0
   dec playerSpeed                  ; reduce player speed for braking
   bpl .playBrakingSound
   sta playerSpeed                  ; set to 0 for no movement
   tay
.playBrakingSound
   beq .checkToPlayEngineAccelerationSound
   lda #6
   sta AUDV0
   lda frameCount                   ; get the current frame count
   and #1                           ; keep D0 value
   bpl .setPlayerEngineFrequency    ; unconditional branch

.checkToPlayEngineAccelerationSound
   ldy #1
   lda INPT4                        ; read player 1 fire button
   bmi .setEngineAccelerationVolume ; branch if fire button not pressed
   ldy #3
.setEngineAccelerationVolume
   sty AUDV0
   lda playerSpeed                  ; get the player's speed
   lsr                              ; divide value by 2
   and #$0F
   eor #$0F
   clc
   adc #13
.setPlayerEngineFrequency
   sta AUDF0
   ldy #3
.setPlayerEngineAudioChannel
   sty AUDC0
   lda riverCollision               ; check if player car collided with river
   bpl .playCrashingSound           ; branch if not collided with river
   lda #6
   jsr ModulateEngineSound
   ldy #INIT_PLAYER_VERT_POS + 14
   lda playerVertPos                ; get player vertical position
   cmp #INIT_PLAYER_VERT_POS
   bcs .setPlayerPositionFromRiverCollision
   ldy #INIT_PLAYER_VERT_POS - 14
.setPlayerPositionFromRiverCollision
   sty playerVertPos
.playCrashingSound
   lda crashTimer                   ; get current crash timer value
   and #$0F
   beq .resetCrashTimer             ; branch if crash timer reached 0
   lda #0
   sta oilSlickSlideTime            ; reset oil slick slide timer value
   dec crashTimer                   ; reduce crash timer
   lda crashTimer                   ; get current crash timer value
   sta AUDV1                        ; set crash volume
   lda #8
   sta AUDF1
   sta AUDC1
   bne DetermineIfTimeToShowBridge  ; unconditional branch

.resetCrashTimer
   sta crashTimer                   ; a = 0
DetermineIfTimeToShowBridge
   lda showingBridge
   ora riverEdgeHorizPos
   bne .determineToAnimateObstacles ; branch if showing bridge
   lda currentTrackPosition
   cmp #TRACK_BRIDGE_03 | 1
   bcs .determineToAnimateObstacles ; branch if passed all three bridges
   and #$3F                         ; mask bridge count for track position
   bne .determineToAnimateObstacles ; branch if not reaching bridge
   lda treeHorizPos
   and #$10
   cmp #$10
   bne .determineToAnimateObstacles
   inc showingBridge                ; set to non-zero value to show bridge
   lda #W_SCREEN
   sta riverEdgeHorizPos            ; start river edge to right of screen
.determineToAnimateObstacles
   lda currentTrackPosition         ; get current track position
   cmp #TRACK_BRIDGE_03 | MAX_TRACK_POSITION
   bne .animateObstacleSprite       ; branch if not done with race
   ldy treeHorizPos
   cpy #$30
   bcs .animateObstacleSprite
   sta gameState                    ; set for race is over (i.e D6 - D0 high)
.animateObstacleSprite
   lda gameState                    ; get current game state
   cmp #GAME_IN_PROGRESS
   bne .skipIncrementElapsedTime
   inc obstacleGraphicPtr + 1       ; animate obstacle sprite
   ldx obstacleGraphicPtr + 1
   inx
   bne IncrementElapsedTime
   lda #>CarAnimation_00
   sta obstacleGraphicPtr + 1       ; reset obstacle MSB
IncrementElapsedTime
   lda microSecondsFraction         ; get micro second frame fraction
   clc
   adc #MICRO_SECONDS_DELAY         ; set carry bit if overflow
   sta microSecondsFraction
   sed                              ; set to decimal mode
   lda elapsedTime + 2              ; get elapsed time milli seconds
   adc #MICRO_SECONDS_BCD           ; increase value by 16 (BCD)
   sta elapsedTime + 2
   lda elapsedTime + 1              ; get elapsed time seconds value
   adc #1 - 1
   sta elapsedTime + 1
   lda elapsedTime                  ; get elapsed time minutes value
   adc #1 - 1
   sta elapsedTime
   and #$0F
   cmp #6
   bcc .doneIncreaseElapsedTime
   lda elapsedTime
   adc #4 - 1                       ; carry set
   bcc .setElapsedTime
   lda #$99
   sta elapsedTime + 2              ; set elapsed time for roll over
   sta elapsedTime + 1
   lda #$95
   sta gameState                    ; set for race is over
.setElapsedTime
   sta elapsedTime
.doneIncreaseElapsedTime
   cld
.skipIncrementElapsedTime
   lda showingBridge
   ora riverEdgeHorizPos
   bne VerticalSync                 ; branch if showing bridge
   lda currentTrackPosition         ; get current track position
   and #$3F                         ; mask bridge count for track position
   beq VerticalSync                 ; branch if coming off a bridge
   cmp #MAX_TRACK_POSITION - 2
   bcs VerticalSync                 ; branch if reaching end of track segment
   lda random                       ; get current random number
   and #$78                         ; make value between 8 - 240
   sta tmpRandomValue
   lda treeHorizPos                 ; get trees horizontal position
   and #$78                         ; make value between 8 - 240
   cmp tmpRandomValue
   bne VerticalSync
   ldy gameSelection                ; get current game selection
   lda random                       ; get random number
   eor RandomXORTable,y
   sta tmpRandomXOR
   and #3
   tax
   lda obstacleHorizPositions + 1,x ; get obstacle horizonal position
   bne VerticalSync                 ; branch if not reach far left side
   lda #XMAX - 1
   sta obstacleHorizPositions + 1,x ; wrap obstacle to far right side of screen
   lda currentTrackPosition         ; get the current track position
   and #$3F                         ; mask bridge count for track position
   cmp #MAX_TRACK_POSITION - 7
   bcs .spawnOilSlickObstacle
   lda tmpRandomXOR
   and #$9C
   cmp #$9C
   bne .setNewObstacleSpeed
.spawnOilSlickObstacle
   lda #HMOVE_0 | ID_OIL_SLICK
   sta obstacleFineMotion + 1,x     ; set obstacle object to oil slick
.setNewObstacleSpeed
   jsr NextRandom                   ; get a new random number
   lda random                       ; get random number
   eor RandomXORTable,y
   and ObstacleSpeedMaskValues,x
   eor obstaclesSpeed
   sta obstaclesSpeed
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | DISABLE_TIA
   sty WSYNC                        ; wait for next scan line
   sty VBLANK                       ; disable TIA (D1 = 1)
   sty VSYNC                        ; start vertical sync (D1 = 1)
   sty WSYNC                        ; first line of vertical sync
   sty WSYNC                        ; second line of vertical sync
   sty WSYNC                        ; third line of vertical sync
   sta VSYNC                        ; end vertical sync (D1 = 0)
   inc frameCount                   ; increment frame count
   bne DetermineTVMode
   inc colorCycleMode               ; increment every 256 frames
   bne DetermineTVMode
   sec
   ror colorCycleMode
DetermineTVMode
   ldy #$FF                         ; assume color mode
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   bne .colorMode                   ; branch if set to color
   ldy #$0F                         ; hue mask for B/W mode
.colorMode
   tya                              ; move hue masking value to accumulator
   ldy #0
   bit colorCycleMode
   bpl .setColorHueMask             ; branch if not in color cycling mode
   and #$F7                         ; mask for VCS colors (i.e. D0 not used)
   ldy colorCycleMode
.setColorHueMask
   sty colorEOR
   asl colorEOR
   sta hueMask
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blanking period
   lda SWCHA                        ; read joystick values
   lsr                              ; shift player 1 joystick values to lower nybble
   lsr
   lsr
   lsr
   sta joystickValue                ; set joystick value
   cmp #P1_NO_MOVE
   beq CheckSelectAndResetSwitch    ; branch if joystick not moved
   lda #0
   sta colorCycleMode               ; reset color cycling mode value if moved
CheckSelectAndResetSwitch
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForSelectPressed       ; branch if RESET not pressed
   ldx gameSelection                ; get current game selection
   inx
   stx random                       ; seed random number with game selection
   ldx #<colorCycleMode
   jmp RestartGame

.checkForSelectPressed
   ldy #0
   lsr                              ; shift SELECT to carry
   bcs .setSelectDebounceRate       ; branch if SELECT not pressed
   lda selectDebounce               ; get select debounce value
   beq .incrementGameSelection      ; increment game selection if zero
   dec selectDebounce               ; decrement select debounce rate
   bpl .determineGameInProgress
.incrementGameSelection
   inc gameSelection
JumpIntoConsoleSwitchCheck
   lda gameSelection                ; get current game selection
   and #3                           ; make sure value does not go over 3
   sta gameSelection
   sta colorCycleMode
   lda #(BLANK_OFFSET << 4) | BLANK_OFFSET
   sta elapsedTime                  ; show blanks for elapsed time at start up
   sta elapsedTime + 1
   sta elapsedTime + 2
   ldy #SELECT_DELAY
   sta gameState                    ; clear game state
.setSelectDebounceRate
   sty selectDebounce
.determineGameInProgress
   lda gameState                    ; get current game state
   and #<~GAME_IN_PROGRESS
   beq .checkToStartRace
   jmp .setLowerTreeHorizontalValues

.checkToStartRace
   lda gameState                    ; get current game state
   cmp #GAME_IN_PROGRESS
   beq .checkForPlayerAcceleration  ; branch if game in progress
   lda INPT4                        ; read player 1 fire button
   bmi .checkForPlayerAcceleration  ; branch if fire button not pressed
   lda #GAME_IN_PROGRESS
   sta gameState                    ; set to GAME_IN_PROGRESS
   lda #0
   sta frameCount                   ; reset frame count
.checkForPlayerAcceleration
   lda frameCount                   ; get current frame count
   and #7
   bne .setMaximumPlayerSpeed       ; branch if not divisible by 8
   bit INPT4                        ; read player 1 fire button
   bpl .incrementPlayerSpeed        ; branch if fire button pressed
   dec playerSpeed                  ; reduce player's speed
   bpl .bplToSetMaxSpeed
   lda #SPEED_MIN
   sta playerSpeed
.bplToSetMaxSpeed
   bpl .setMaximumPlayerSpeed       ; unconditional branch
   
.incrementPlayerSpeed
   sta colorCycleMode
   inc playerSpeed
.setMaximumPlayerSpeed
   lda playerSpeed                  ; get the player's current speed
   bpl .checkToReduceSpeedForVerticalMovement
   lda #SPEED_MAX
   sta playerSpeed                  ; set the maximum speed
.checkToReduceSpeedForVerticalMovement
   lda joystickValue
   and #(MOVE_RIGHT & MOVE_LEFT) >> 4; isolate vertical movement values
   cmp #(MOVE_RIGHT & MOVE_LEFT) >> 4
   lda playerSpeed                  ; get the player speed
   bcs .determinePlayerAnimationDelay;branch if player not moving vertically
   lsr                              ; divide player speed by 16
   lsr
   lsr
   lsr
   sta tmpPlayerSpeedDiv16
   sec
   lda playerSpeed                  ; get the player speed
   sbc tmpPlayerSpeedDiv16          ; reduce by ~6% for vertical movement
.determinePlayerAnimationDelay
   sta tempPlayerSpeed              ; set player speed
   lsr                              ; divide player speed by 16
   lsr
   lsr
   lsr
   sta tmpPlayerAnimationDelay
   lda tempPlayerSpeed              ; get temporary player speed value
   and #$0F                         ; keep mod16 value
   clc
   adc playerAnimiationDelayValue   ; add in current animation delay value
   cmp #16
   bcc .setPlayerAnimationDelayValue
   inc tmpPlayerAnimationDelay      ; increment if overflow
.setPlayerAnimationDelayValue
   and #$0F
   sta playerAnimiationDelayValue
   lda treeHorizPos
   sec
   sbc tmpPlayerAnimationDelay
   sta treeHorizPos
   cmp #$B0
   bcc .incrementCarAnimationIndex
   sbc #$60
   sta treeHorizPos
   inc currentTrackPosition         ; increment track position
   bne .incrementCarAnimationIndex  ; branch if no roll over
   dec currentTrackPosition         ; reduce track position for roll over
.incrementCarAnimationIndex
   lda tmpPlayerAnimationDelay
   beq .setCarLSBAnimationValue
   inc playerCarAnimationIndex
   lda playerCarAnimationIndex
   cmp #3
   bcc .setPlayerCarAnimationIndex
   lda #0
.setPlayerCarAnimationIndex
   sta playerCarAnimationIndex
.setCarLSBAnimationValue
   lda playerCarAnimationIndex
   clc
   adc #>CarAnimation_00
   sta playerCarGraphicPtr + 1
   lda obstaclesSpeed
   sta tempSpeed
   ldx #KERNEL_SECTIONS - 1
.moveObstacles
   lda tempSpeed                    ; get obstacle speed values
   and #3                           ; keep current kernel section obstacle speed
   sta tempObstacleSpeed
   lda currentTrackPosition         ; get current track position
   and #$3F                         ; mask bridge count for track position
   cmp #MAX_TRACK_POSITION - 1
   bcc .determineObstacleSpeed      ; branch if not reached end of the race
   lda #OBSTACLE_GEAR_NEUTRAL
   sta tempObstacleSpeed
   sta tempSpeed
.determineObstacleSpeed
   lda tmpPlayerAnimationDelay
   sbc tempObstacleSpeed
   sta tempObstacleSpeed
   lda obstacleFineMotion,x         ; get obstacle fine motion value
   lsr                              ; shift object type to carry
   bcc .adjustObstacleHorizontalPosition;branch if object is a car
   lda tmpPlayerAnimationDelay
   sta tempObstacleSpeed
.adjustObstacleHorizontalPosition
   lda obstacleHorizPositions,x     ; get obstacle's horizontal position
   beq .setObstacleNewHorizPosition ; branch if reached the left edge of screen
   sec
   sbc tempObstacleSpeed            ; reduce obstacle horizontal position
   beq .determineNewObstacleCarColors
   cmp #XMAX
   bcc .setObstacleNewHorizPosition
   cmp #XMIN - 16
   bcc .spawnNewObstacleCar
.determineNewObstacleCarColors
   lda random                       ; get random number seed
   and #3 << 5                      ; 4 obstacles (i.e. [4 * H_SPRITES] - H_SPRITES)
   adc #<[ObstacleColors - 1]
   sta obstacleColorLSBValues,x
.spawnNewObstacleCar
   lda #HMOVE_0 | ID_CAR
   sta obstacleFineMotion,x
.setObstacleNewHorizPosition
   sta obstacleHorizPositions,x
   lda tempSpeed                    ; get obstacle speed values
   lsr                              ; shift right twice for next obstacle
   lsr
   sta tempSpeed                    ; set new obstacle speed values
   dex
   bne .moveObstacles
   lda riverEdgeHorizPos
   ora showingBridge
   beq .checkForOilSliding          ; branch if not showing bridge
   lda riverEdgeHorizPos
   sec
   sbc tmpPlayerAnimationDelay
   sta riverEdgeHorizPos
   bcs .checkForOilSliding
   lda #W_SCREEN
   sta riverEdgeHorizPos
   dec showingBridge
   bpl .checkForOilSliding
   lda #XMIN
   sta riverEdgeHorizPos
   sta showingBridge
   inc currentTrackPosition
.checkForOilSliding
   lda oilSlickSlideTime            ; get the oil slick slide timer value
   beq .checkForCrashSpinning       ; branch if not sliding on oil slick
   lda joystickValue                ; get joystick values
   and #(MOVE_DOWN & MOVE_UP) >> 4  ; mask the joystick vertical movement
   sta joystickValue                ; clear vertical movement
   ldy #<(~MOVE_DOWN) >> 4
   lda frameCount                   ; get current frame count
   and #$20
   beq .setOilSlickSlideDirection   ; branch every 32 frames
   ldy #<(~MOVE_UP) >> 4            ; move player up
.setOilSlickSlideDirection
   tya                              ; move vertical movement to accumulator
   ora joystickValue                
   sta joystickValue                ; set new vertical movement
.checkForCrashSpinning
   lda crashTimer                   ; get current crash timer value
   and #$0F
   beq SteerPlayerWithJoystick      ; branch if not skidding from crash
   lsr
   bcc .verifyPlayerPositionForSkid
   eor #$FF                         ; negate value
.verifyPlayerPositionForSkid
   ldy playerVertPos                ; get the player vertical position
   cpy #INIT_PLAYER_VERT_POS
   bcc .skidPlayerForCrash          ; branch if below starting vertical position
   eor #$FF                         ; negate value
.skidPlayerForCrash
   clc
   adc playerVertPos
   sta playerVertPos
SteerPlayerWithJoystick
   lda playerVertMovementDelay      ; get the vertical delay value
   cmp #3
   bcc .setPlayerVertMovementDelay
   lda #3
.setPlayerVertMovementDelay
   sta playerVertMovementDelay
   lda joystickValue                ; get current joystick value
   lsr                              ; shift MOVE_UP to carry
   bcs .checkToSteerPlayerCarDown   ; branch if joystick not pushed up
   lda playerVertPos                ; get player vertical position
   sec
   sbc playerVertMovementDelay      ; subtract from vertical delay
   sta playerVertPos
   jmp KeepPlayerInRoadRange

.checkToSteerPlayerCarDown
   lsr                              ; shift MOVE_DOWN to carry
   bcs KeepPlayerInRoadRange        ; branch if joystick not pushed down
   lda playerVertPos                ; get player vertical position
   adc playerVertMovementDelay      ; increment by vertical delay
   sta playerVertPos
KeepPlayerInRoadRange
   lda playerVertPos                ; get player vertical position
   cmp #YMAX
   bcc .checkPlayerLowerBound
   lda #YMAX                        ; set to maximum vertical position
.checkPlayerLowerBound
   cmp #YMIN
   bcs .setPlayerVerticalPosition
   lda #YMIN                        ; set to minimum vertical position
.setPlayerVerticalPosition
   sta playerVertPos
   ldx #<[rightPF2GraphicData - playfieldGraphicData]
   lda #0
.clearBridgeWaterGraphics
   sta playfieldGraphicData,x
   dex
   bpl .clearBridgeWaterGraphics
   lda riverEdgeHorizPos            ; get the river edge horizontal position
   lsr                              ; divide value by 8
   lsr
   lsr
   tay
   ldx PlayfieldGraphicIndexValues,y
   lda RiverGraphicValues,y
.setBridgeWaterGraphics
   sta playfieldGraphicData,x
   lda #$FF
   inx
   cpx #<[rightPF2GraphicData - playfieldGraphicData + 1]
   bcc .setBridgeWaterGraphics
   dex                              ; x = 5
   ldy #$00
   lda showingBridge
   lsr
   bcs .adjustBridgeWaterGraphics
   dey
.adjustBridgeWaterGraphics
   tya
   eor playfieldGraphicData,x
   sta playfieldGraphicData,x
   dex
   bpl .adjustBridgeWaterGraphics
.setLowerTreeHorizontalValues
   lda treeHorizPos
   and #$1F
   clc
   adc #68
   sta lowerRightTreeHorizPos       ; set lower right tree's horizontal position
   lda treeHorizPos
   jsr Multi16                      ; shift lower nybbles to upper nybbles
   php                              ; push original D4 to CARRY
   eor #$F0                         ; get 1's complement
   clc
   adc #$80
   plp                              ; pull status from stack
   ror                              ; shift CARRY into D7
   sta lowerLeftTreeHorizPosValues
   lda currentTrackPosition         ; get current track position
   and #$3F                         ; mask bridge count for track position
   cmp #MAX_TRACK_POSITION - 1
   bcc SetObstacleAttributes
   lda #>GameSprites
   sta obstacleGraphicPtr + 1
SetObstacleAttributes
   ldx #KERNEL_SECTIONS - 1
.setObstacleAttributes
   lda #<PlayerCarSizeValues
   sta obstacleSizeLSBValues,x      ; set obstacle size LSB value
   lda #$00
   sta obstacleLSBValues,x          ; set obstacle graphic pointer LSB value
   lda obstacleHorizPositions,x     ; get obstacle horizontal position
   sta tmpObstacleHorizPos          ; save value for later
   cpx #<[lowerRightTreeHorizPos - obstacleHorizPositions]
   beq .calculateObstacleHorizPos   ; branch if tree sprite
   ldy colorCycleMode               ; get color cycling mode value
   bpl .setFinishLineHorizPosition  ; branch if not color cycling
   lda #0
   sta tmpObstacleHorizPos
   beq .determineObstacleGraphicLSBValue;unconditional branch

.setFinishLineHorizPosition
   ldy currentTrackPosition         ; get the current track position
   iny
   bne .determineObstacleGraphicLSBValue;branch if not showing finish line
   lda treeHorizPos
   sta obstacleHorizPositions,x
   jmp .calculateObstacleHorizPos

.determineObstacleGraphicLSBValue
   lda tmpObstacleHorizPos          ; get obstacle horizontal position
   sbc #(XMAX - W_SCREEN)
   cmp #XMAX + 43
   bcc .setMidScreenGraphicLSBValue
   lda tmpObstacleHorizPos          ; get obstacle horizontal position
   lsr                              ; divide horizontal postion by 8
   lsr
   lsr
   tay
   lda ObstacleRightGraphicLSBValue,y
   sta obstacleLSBValues,x          ; set obstacle graphic LSB value
   lda ObstacleRightSizeLSBValue,y
   sta obstacleSizeLSBValues,x      ; set obstacle size LSB value
   lda obstacleFineMotion,x         ; get obstacle fine motion value
   lsr                              ; shift object type to carry
   lda tmpObstacleHorizPos
   and #$07
   bcc .jmpToCalculateObstacleHorizPos; branch if object is a car
   lda #$00
.jmpToCalculateObstacleHorizPos
   jmp .calculateObstacleHorizPos

.setMidScreenGraphicLSBValue
   cmp #W_SCREEN - 23
   bcc .calculateObstacleHorizPos
   sbc #W_SCREEN - 23
   lsr
   lsr
   lsr
   tay
   lda ObstacleMidScreenGraphicLSBValue,y
   sta obstacleLSBValues,x
   lda ObstacleMidScreenSizeLSBValue,y
   sta obstacleSizeLSBValues,x
   lda tmpObstacleHorizPos
   sec
   sbc #(XMAX - W_SCREEN)
.calculateObstacleHorizPos
   jsr CalculateObjectHorizPosition
   lsr                              ; shift calculated object fine motion right
   lsr obstacleFineMotion,x         ; shift object id to carry
   rol                              ; rotate to keep fine motion and object type
   sta obstacleFineMotion,x         ; set new fine motion value
   dey
   dey
   dey
   sty obstacleCoarseValues,x
   lda currentTrackPosition
   cmp #$FF
   bne .setAttributesForOilSlick
   lda #<FinishlineGraphics
   sta obstacleLSBValues,x
   lda #<FinishlineColors
   sta obstacleColorLSBValues,x
   lda #<FinishlineSizeValues
   sta obstacleSizeLSBValues,x
   lda #>FinishlineGraphics
   sta obstacleGraphicPtr + 1
   jmp .setNextObstacleAttributes   ; bne branch saves a byte

.setAttributesForOilSlick
   lda obstacleFineMotion,x         ; get obstacle fine motion value
   lsr                              ; shift object type to carry
   bcc .setNextObstacleAttributes   ; branch if object is a car
   lda #<OilSlickAnimation_00
   sta obstacleLSBValues,x
   lda #<OilSlickColors
   sta obstacleColorLSBValues,x
   lda #<OilSlickSizeValues
   sta obstacleSizeLSBValues,x
.setNextObstacleAttributes
   dex
   bmi .jmpToTheMainLoop
   jmp .setObstacleAttributes

.jmpToTheMainLoop
   jmp MainLoop

NextRandom
   lda random
   asl
   asl
   asl
   eor random
   asl
   rol random
   rts

ModulateEngineSound
   sta AUDV1                        ; set the engine volume
   ldy #1
   lda frameCount                   ; get the current frame count
   lsr                              ; shift D0 to carry
   bcc .setEngineAudioFrequency     ; branch on even frames
   ldy #2
.setEngineAudioFrequency
   sty AUDF1
   lda #3
   sta AUDC1
   rts

InitializeGame
   ldx #<[gameSelectionPointers - playerCarGraphicPtr + 1]
.initGraphicPointers
   lda InitGraphicPointerValues,x
   sta playerCarGraphicPtr,x
   dex
   bpl .initGraphicPointers
   lda #INIT_PLAYER_VERT_POS
   sta playerVertPos
   lda #HMOVE_L7 >> 1
   sta lowerLeftTreeHorizPosValues
   ldx #KERNEL_SECTIONS - 1
.initObstacleValues
   lda InitObstacleCoarseMoveValues,x
   sta obstacleCoarseValues,x
   lda InitObstacleFineMoveValues,x
   sta obstacleFineMotion,x
   lda ObstacleColorLSBValues - 1,x
   sta obstacleColorLSBValues,x
   lda #<OilSlickSizeValues
   sta obstacleSizeLSBValues,x
   dex
   bpl .initObstacleValues
   ldx gameSelection                ; get current game selection
   lda StartingTrackPositionValues,x; get starting track position
   sta currentTrackPosition
   rts

MoveObjectsHorizontally
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; move object horizontally
   rts

;
; Horizontal reset starts at cycle 8 (i.e. pixel 24). The object's position is
; incremented by 46 to push their pixel positioning to start at cycle 23 (i.e.
; pixel 69) with an fine adjustment of -6 to start objects at pixel 63.
;
CalculateObjectHorizPosition
   clc                              ; clear carry
   adc #46                          ; increment horizontal position value by 46
   tay                              ; save result for later
   and #$0F                         ; keep lower nybbles
   sta div16Remainder               ; keep div16 remainder
   tya
   lsr                              ; divide horizontal position by 16
   lsr
   lsr
   lsr
   tay                              ; division by 16 is course movement value
   clc
   adc div16Remainder               ; add back division by 16 remainder
   cmp #15
   bcc .determineFineMotionValue
   sbc #15
   iny                              ; increment course movement value
.determineFineMotionValue
   eor #7                           ; get 3-bit 1's complement for fine motion
Multi16
   asl
Sleep12Cycles
   asl
   asl
Sleep8Cycles
   asl
Sleep6Cycles
   rts

RiverGraphicValues
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $03 ; |......XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $03 ; |......XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|

ObstacleColors
ObstacleCarColors_0
   .byte BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK
   .byte WHITE, YELLOW, YELLOW + 2, YELLOW + 4
   .byte YELLOW + 6, YELLOW + 8, BLACK, BLACK + 10
   .byte BLACK + 10, BLACK, YELLOW + 8, YELLOW + 6
   .byte YELLOW + 4, YELLOW + 2, YELLOW, WHITE
   .byte BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK

ObstacleCarColors_1
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, WHITE, GREEN
   .byte GREEN + 2, GREEN + 4, GREEN + 6, GREEN + 8, BLACK, CYAN + 2, CYAN + 2
   .byte BLACK, GREEN + 8, GREEN + 6, GREEN + 4, GREEN + 2, GREEN, WHITE, BLACK
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK

PlayerCarColors
ObstacleCarColors_2
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, WHITE, LT_BLUE
   .byte LT_BLUE + 2, LT_BLUE + 4, LT_BLUE + 6, LT_BLUE + 8, BLACK, ORANGE + 2
   .byte ORANGE + 2, BLACK, LT_BLUE + 8, LT_BLUE + 6, LT_BLUE + 4, LT_BLUE + 2
   .byte LT_BLUE, WHITE, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK

ObstacleCarColors_3
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, WHITE, YELLOW
   .byte LT_RED + 2, RED + 4, ORANGE_2 + 6, DK_PINK + 8, BLACK, YELLOW + 8
   .byte YELLOW + 8, BLACK, DK_PINK + 8, ORANGE_2 + 6, RED + 4, LT_RED + 2
   .byte YELLOW, WHITE, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK

FinishlineColors
OilSlickColors
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK

   BOUNDARY 0

.skipDrawCheckCollision
   sta WSYNC
;--------------------------------------
   bpl .skipSetCollision      ; 2³        branch if no player collision
   stx.w collisionKernelSection;4
.skipDrawPlayerCar_0
   jsr Sleep8Cycles           ; 14
   lda #0                     ; 2
   sta GRP0                   ; 3 = @25
   beq .setupToMoveObstacle   ; 3         unconditional branch

.skipObstacleCollision
   bpl .drawPlayerCarSection_1; 3         unconditional branch

.skipSetCollision
   bpl .skipDrawPlayerCar_0   ; 3         unconditional branch

StartObstacleKernel
   lda playerVertPos          ; 3
   cmp #YMIN                  ; 2
   sta WSYNC
;--------------------------------------
   bne .colorRoad             ; 2³
   lda #$1F                   ; 2
   sta GRP0                   ; 3 = @07   draw top of back tire
.colorRoad
   lda roadColor              ; 3
   sta COLUBK                 ; 3 = @13
   lda #DISABLE_BM            ; 2
   sta ENAM1                  ; 3 = @18
   sta COLUPF                 ; 3 = @21
   lda #KERNEL_SECTIONS - 1   ; 2
   sta kernelSection          ; 3
   ldy playerVertPos          ; 3
.obstacleKernelLoop
   ldx kernelSection          ; 3         get kernel section
   dec kernelSection          ; 5         decremenet for next loop
   lda obstacleLSBValues,x    ; 4
   sta obstacleGraphicPtr     ; 3         set the obstacle graphic pointer LSB
   lda obstacleSizeLSBValues,x; 4
   sta obstacleSizePtr        ; 3         set the obstacle size value
   lda obstacleColorLSBValues,x;4
   sta obstacleColorPtr       ; 3         set the obstacle color pointer LSB
   dey                        ; 2
   cpy #H_SPRITES             ; 2
   lda CXPPMM                 ; 3         check player collisions
   bcs .skipDrawCheckCollision; 2³
   sta WSYNC
;--------------------------------------
   bpl .skipObstacleCollision ; 2³        branch if player's didn't collide
   stx.w collisionKernelSection;4         set collision kernel section
.drawPlayerCarSection_1
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @13
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @21
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @28
.setupToMoveObstacle
   lda obstacleFineMotion,x   ; 4         get obstacle's fine motion value
   sta tempFineMotionValue    ; 3         set the value temporarily
   lda obstacleCoarseValues,x ; 4         get the obstacle's coarse move value
   tax                        ; 2
   dey                        ; 2
   cpy #H_SPRITES             ; 2
   bcs .skipDrawPlayerCar_1   ; 2³
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @55
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @62
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @69
.continueDrawPlayerCar_1
   dey                        ; 2
   cpy #H_SPRITES             ; 2
   lda tempFineMotionValue    ; 3
;--------------------------------------
   bcs .skipPlayerCarDrawCoarseMoveObstacle;2³
   sta CXCLR                  ; 3 = @05
   sta HMP1                   ; 3 = @08
   lda (playerCarGraphicPtr),y; 5
   cpx #6                     ; 2
.coarseMoveObstacle
   dex                        ; 2
   bpl .coarseMoveObstacle    ; 2³
   sta.w RESP1                ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @13
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @20
.jmpIntoThirdObstacleScanline
   lda kernelSection          ; 3
   bmi .endGameKernel         ; 2³
   bcs SkipPlayerDrawObstacleSection;2³ + 1
   ldx #H_SPRITES - 2         ; 2
.obstacleKernelSectionLoop
   dey                        ; 2
   cpy #H_SPRITES             ; 2
   bcs .skipDrawPlayerCar_2   ; 2³ + 1
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @43
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @50
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @57
.jmpIntoObstacleKernelSectionLoop
   sty tmpPlayerGraphicPtr    ; 3
   txa                        ; 2
   tay                        ; 2
   lda (obstacleSizePtr),y    ; 5
   sta NUSIZ1                 ; 3 = @72
   sta HMP1                   ; 3 = @75
;--------------------------------------
   sta HMOVE                  ; 3 = @02
   lda (obstacleGraphicPtr),y ; 5
   sta GRP1                   ; 3 = @10
   lda (obstacleColorPtr),y   ; 5
   and hueMask                ; 3
   sta COLUP1                 ; 3 = @21
   ldy tmpPlayerGraphicPtr    ; 3
   dex                        ; 2
   bpl .obstacleKernelSectionLoop;2³
   jmp .obstacleKernelLoop    ; 3

.endGameKernel
   jsr Sleep12Cycles          ; 6
   sta HMCLR                  ; 3
   jmp StatusKernel           ; 3

.skipDrawPlayerCar_1
   lda #0                     ; 2
   sta.w GRP0                 ; 4 = @54
   jsr Sleep6Cycles           ; 12
   beq .continueDrawPlayerCar_1;3         unconditional branch

.skipPlayerCarDrawCoarseMoveObstacle
   SLEEP 2                    ; 2 = @05
   sta HMP1                   ; 3 = @08
   lda (playerCarGraphicPtr),y; 5         waste 5 cycles
   cpx #6                     ; 2
.skipDrawCoarseMoveObstacleLoop
   dex                        ; 2
   bpl .skipDrawCoarseMoveObstacleLoop;2³
   sta.w RESP1                ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta CXCLR                  ; 3 = @06
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda #0                     ; 2
   sta GRP0                   ; 3 = @17
   jmp .jmpIntoThirdObstacleScanline;3

.skipDrawPlayerCar_2
   jsr Sleep6Cycles           ; 12
   lda #0                     ; 2
   sta GRP0                   ; 3
   jmp .jmpIntoObstacleKernelSectionLoop;3

SkipPlayerDrawObstacleSection
   ldx #H_SPRITES - 2         ; 2 = @31
.skipPlayerDrawObstacleSectionLoop
   dey                        ; 2
   cpy #H_SPRITES             ; 2
   bcs .skipDrawPlayerCar     ; 2³
   lda (playerCarGraphicPtr),y; 5
   sta GRP0                   ; 3 = @45
   lda PlayerCarSizeValues,y  ; 4
   sta NUSIZ0                 ; 3 = @52
   lda playerCarColors,y      ; 4
   sta COLUP0                 ; 3 = @59
.jmpIntoDrawObstacleSection
   sty tmpPlayerGraphicPtr    ; 3
   txa                        ; 2
   tay                        ; 2
   lda (obstacleSizePtr),y    ; 5
   sta HMP1                   ; 3 = @74
;--------------------------------------
   sta HMOVE                  ; 3 = @01
   sta NUSIZ1                 ; 3 = @04
   lda (obstacleGraphicPtr),y ; 5
   sta GRP1                   ; 3 = @12
   lda (obstacleColorPtr),y   ; 5
   and hueMask                ; 3
   sta COLUP1                 ; 3 = @23
   ldy tmpPlayerGraphicPtr    ; 3
   dex                        ; 2
   bpl .skipPlayerDrawObstacleSectionLoop;2³
   jmp .obstacleKernelLoop    ; 3

.skipDrawPlayerCar
   jsr Sleep6Cycles           ; 12
   lda #0                     ; 2
   sta.w GRP0                 ; 4
   beq .jmpIntoDrawObstacleSection;3      unconditional branch

CrashValueSpeedReductions
   .byte SPEED_MIN + 8, SPEED_MIN + 16
   .byte SPEED_MIN + 32, SPEED_MIN + 48
   
RandomXORTable
   .byte $17, $46, $92, $00

PositionObjectsHorizontally
   sta HMP0,x                       ; set object's fine motion value
   sta WSYNC                        ; wait for next scan line
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; set object's coarse position
   rts

ObstacleColorLSBValues
   .byte <ObstacleCarColors_0
   .byte <ObstacleCarColors_1
   .byte <ObstacleCarColors_2
   .byte <ObstacleCarColors_3

PlayerCarSizeValues
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | TWO_COPIES, HMOVE_0 | TWO_COPIES, HMOVE_0 | TWO_COPIES
   .byte HMOVE_R1| TWO_COPIES, HMOVE_L1| TWO_COPIES, HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_R1| QUAD_SIZE,  HMOVE_L1| TWO_COPIES, HMOVE_0 | TWO_COPIES
   .byte HMOVE_0 | TWO_COPIES, HMOVE_0 | TWO_COPIES, HMOVE_0 | TWO_COPIES, HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY

   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_R1| ONE_COPY,   HMOVE_L1| ONE_COPY,   HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_R1| QUAD_SIZE,  HMOVE_L1| ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY

   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_R1| ONE_COPY,   HMOVE_R7| ONE_COPY,   HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE,  HMOVE_0 | QUAD_SIZE
   .byte HMOVE_0 | QUAD_SIZE,  HMOVE_L7| QUAD_SIZE,  HMOVE_L1| ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_R8| ONE_COPY,   HMOVE_0 | ONE_COPY

   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_R1| ONE_COPY,   HMOVE_L1| ONE_COPY,   HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE
   .byte HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE
   .byte HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE,HMOVE_0 | DOUBLE_SIZE
   .byte HMOVE_0 | DOUBLE_SIZE,HMOVE_R1| DOUBLE_SIZE,HMOVE_L1| ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY

FinishlineSizeValues
OilSlickSizeValues
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY
   .byte HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY,   HMOVE_0 | ONE_COPY

   BOUNDARY 0

GameSprites
CarAnimation_00
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
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
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
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
OilSlickAnimation_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $99 ; |X..XX..X|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $EA ; |XXX.X.X.|
   .byte $9D ; |X..XXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $77 ; |.XXX.XXX|
   .byte $AE ; |X.X.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $70 ; |.XXX....|
   .byte $01 ; |.......X|
   .byte $88 ; |X...X...|
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
   
CarAnimation_01
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
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
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
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
   
OilSlickAnimation_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $99 ; |X..XX..X|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $EA ; |XXX.X.X.|
   .byte $9D ; |X..XXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $77 ; |.XXX.XXX|
   .byte $AE ; |X.X.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $70 ; |.XXX....|
   .byte $01 ; |.......X|
   .byte $88 ; |X...X...|
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
   
CarAnimation_02
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $DC ; |XX.XXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|

   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
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
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $0F ; |....XXXX|
   .byte $04 ; |.....X..|
   .byte $1F ; |...XXXXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
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

OilSlickAnimation_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $99 ; |X..XX..X|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $EA ; |XXX.X.X.|
   .byte $9D ; |X..XXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $77 ; |.XXX.XXX|
   .byte $AE ; |X.X.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $70 ; |.XXX....|
   .byte $01 ; |.......X|
   .byte $88 ; |X...X...|
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

   BOUNDARY 0
   
NumberFonts
zero
   .byte $79 ; |.XXXX..X|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $79 ; |.XXXX..X|
one
   .byte $79 ; |.XXXX..X|
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $31 ; |..XX...X|
   .byte $71 ; |.XXX...X|
   .byte $31 ; |..XX...X|
two
   .byte $FD ; |XXXXXX.X|
   .byte $C1 ; |XX.....X|
   .byte $C1 ; |XX.....X|
   .byte $78 ; |.XXXX...|
   .byte $0C ; |....XX..|
   .byte $0D ; |....XX.X|
   .byte $8D ; |X...XX.X|
   .byte $79 ; |.XXXX..X|
three
   .byte $79 ; |.XXXX..X|
   .byte $8D ; |X...XX.X|
   .byte $0D ; |....XX.X|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0D ; |....XX.X|
   .byte $8D ; |X...XX.X|
   .byte $79 ; |.XXXX..X|
four
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $FC ; |XXXXXX..|
   .byte $98 ; |X..XX...|
   .byte $59 ; |.X.XX..X|
   .byte $39 ; |..XXX..X|
   .byte $19 ; |...XX..X|
five
   .byte $F9 ; |XXXXX..X|
   .byte $8D ; |X...XX.X|
   .byte $0D ; |....XX.X|
   .byte $0C ; |....XX..|
   .byte $F8 ; |XXXXX...|
   .byte $C1 ; |XX.....X|
   .byte $C1 ; |XX.....X|
   .byte $FD ; |XXXXXX.X|
six
   .byte $79 ; |.XXXX..X|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $CC ; |XX..XX..|
   .byte $F8 ; |XXXXX...|
   .byte $C1 ; |XX.....X|
   .byte $C5 ; |XX...X.X|
   .byte $79 ; |.XXXX..X|
seven
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0D ; |....XX.X|
   .byte $85 ; |X....X.X|
   .byte $FD ; |XXXXXX.X|
eight
   .byte $79 ; |.XXXX..X|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $79 ; |.XXXX..X|
nine
   .byte $79 ; |.XXXX..X|
   .byte $8D ; |X...XX.X|
   .byte $0D ; |....XX.X|
   .byte $7C ; |.XXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CD ; |XX..XX.X|
   .byte $CD ; |XX..XX.X|
   .byte $79 ; |.XXXX..X|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

GameColors
   .byte DK_GREEN + 4, DK_GREEN + 4 ; treeColors
   .byte BLUE + 4                   ; riverColor
   .byte YELLOW + 8                 ; gardenDirtColor
   .byte BLACK + 6                  ; roadColor
   .byte BLACK                      ; backgroundColor
   .byte ORANGE + 8                 ; copyrightColor
   .byte DK_GREEN + 6               ; grassColor

FinishlineGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $2A ; |..X.X.X.|
   .byte $55 ; |.X.X.X.X|
   .byte $AA ; |X.X.X.X.|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $05 ; |.....X.X|
   .byte $02 ; |......X.|
   .byte $05 ; |.....X.X|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $28 ; |..X.X...|
   .byte $54 ; |.X.X.X..|
   .byte $AA ; |X.X.X.X.|
   .byte $55 ; |.X.X.X.X|
   .byte $2A ; |..X.X.X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

InitGraphicPointerValues
   .word CarAnimation_00
   .word CarAnimation_00
   .word PlayerCarSizeValues
   .word ObstacleColors
   .word NumberFonts
   .word NumberFonts
   .word NumberFonts
   .word NumberFonts
   .word NumberFonts

PlayfieldGraphicIndexValues
   .byte <leftPF0GraphicData - playfieldGraphicData
   .byte <leftPF1GraphicData - playfieldGraphicData
   .byte <leftPF1GraphicData - playfieldGraphicData
   .byte <leftPF1GraphicData - playfieldGraphicData
   .byte <leftPF1GraphicData - playfieldGraphicData
   .byte <leftPF2GraphicData - playfieldGraphicData
   .byte <leftPF2GraphicData - playfieldGraphicData
   .byte <leftPF2GraphicData - playfieldGraphicData
   .byte <leftPF2GraphicData - playfieldGraphicData
   .byte <rightPF0GraphicData - playfieldGraphicData
   .byte <rightPF0GraphicData - playfieldGraphicData
   .byte <rightPF1GraphicData - playfieldGraphicData
   .byte <rightPF1GraphicData - playfieldGraphicData
   .byte <rightPF1GraphicData - playfieldGraphicData
   .byte <rightPF1GraphicData - playfieldGraphicData
   .byte <rightPF2GraphicData - playfieldGraphicData
   .byte <rightPF2GraphicData - playfieldGraphicData
   .byte <rightPF2GraphicData - playfieldGraphicData
   .byte <rightPF2GraphicData - playfieldGraphicData
   .byte <rightPF2GraphicData - playfieldGraphicData
   
InitObstacleCoarseMoveValues
   .byte 4, 0, 0, 0, 0

InitObstacleFineMoveValues
   .byte HMOVE_R2 | ID_CAR, HMOVE_L6 | ID_CAR
   .byte HMOVE_L6 | ID_CAR, HMOVE_L6,| ID_CAR HMOVE_L6 | ID_CAR

StartingTrackPositionValues
   .byte TRACK_BRIDGE_03            ; Watkins Glen
   .byte TRACK_BRIDGE_02            ; Brands Hatch (1 Bridge)
   .byte TRACK_BRIDGE_01            ; Le Mans (2 Bridges)
   .byte 0                          ; Monaco (3 Bridges)

ObstacleSpeedMaskValues
   .byte $C0
   .byte $30
   .byte $0C
   .byte $03
   
DecimalGraphicMask
   .byte %11111111
   .byte %11111111
   .byte %11111111
   .byte %11111111
   .byte %11111110
   .byte %11111110
   .byte %11111110
   .byte %11111110
   
ObstacleRightGraphicLSBValue
   .byte H_SPRITES * 6
   .byte H_SPRITES * 5
   .byte H_SPRITES * 4
ObstacleRightSizeLSBValue
   .byte H_SPRITES * 7
   .byte H_SPRITES * 6
   .byte H_SPRITES * 5
ObstacleMidScreenGraphicLSBValue
   .byte H_SPRITES * 1
   .byte H_SPRITES * 2
   .byte H_SPRITES * 3
ObstacleMidScreenSizeLSBValue
   .byte H_SPRITES * 3
   .byte H_SPRITES * 4
   .byte H_SPRITES * 4

Copyright_0
   .byte $00 ; |........|
   .byte $AD ; |X.X.XX.X|
   .byte $A9 ; |X.X.X..X|
   .byte $E9 ; |XXX.X..X|
   .byte $A9 ; |X.X.X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $41 ; |.X.....X|
   .byte $0F ; |....XXXX|
Copyright_1
   .byte $00 ; |........|
   .byte $50 ; |.X.X....|
   .byte $58 ; |.X.XX...|
   .byte $5C ; |.X.XXX..|
   .byte $56 ; |.X.X.XX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
Copyright_2
   .byte $00 ; |........|
   .byte $BA ; |X.XXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $3A ; |..XXX.X.|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
Copyright_3
   .byte $00 ; |........|
   .byte $E9 ; |XXX.X..X|
   .byte $AB ; |X.X.X.XX|
   .byte $AF ; |X.X.XXXX|
   .byte $AD ; |X.X.XX.X|
   .byte $E9 ; |XXX.X..X|
   .byte $00 ; |........|
   .byte $00 ; |........|

BorderTreeSprite
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $7E ; |.XXXXXX.|
   .byte $6F ; |.XX.XXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DA ; |XX.XX.X.|
   .byte $ED ; |XXX.XX.X|
   .byte $7B ; |.XXXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $37 ; |..XX.XXX|
   .byte $3E ; |..XXXXX.|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   .org ROM_BASE + 4096 - 4, 0      ; 4K ROM
   .word Start
   .word 0
