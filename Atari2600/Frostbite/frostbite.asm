   LIST OFF
; ***  F R O S T B I T E  ***
; Copyright 1983 Activision, Inc
; Designer: Steve Cartwright

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: Sept 10, 2018
;
; *** 124 BYTES OF RAM USED 4 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
; ***   3 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; ***  2 BYTES OF ROM FREE
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
; - Steve Cartwright's fifth VCS game with Activision
; - PAL50 version ~17% slower than NTSC
; - Fish don't respawn for a level once 12 have been eaten
; - screen is disabled when no player activity for
;     ~1:12 for NTSC and ~1:30 for PAL50
; - Magic Fish icon shown once player reaches level 21

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

VBLANK_TIME             = 48
OVERSCAN_TIME           = 31

INCREMENT_SCORE_FRAME_DELAY = 6
SWAP_PLAYERS_FRAME_DELAY = 112
INCREMENT_LEVEL_FRAME_DELAY = 48

   ELSE

VBLANK_TIME             = 58
OVERSCAN_TIME           = 37

INCREMENT_SCORE_FRAME_DELAY = 5
SWAP_PLAYERS_FRAME_DELAY = 96
INCREMENT_LEVEL_FRAME_DELAY = 39

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
DK_BLUE                 = $90
CYAN                    = $A0
OLIVE_GREEN             = $B0
GREEN                   = $C0
DK_GREEN                = $D0
ORANGE_GREEN            = $E0
BROWN                   = $F0

COLOR_ARTIC_SEA         = DK_BLUE
COLOR_COPYRIGHT         = WHITE - 2
COLOR_IGLOO             = BLACK + 6
COLOR_IGLOO_DOOR_FLASH  = BRICK_RED + 8
COLOR_INIT_ICE_BLOCK    = WHITE - 2
COLOR_CHANGE_ICE_BLOCK  = DK_BLUE + 8
COLOR_PLAYER_1_SCORE    = BLUE + 14
COLOR_PLAYER_2_SCORE    = OLIVE_GREEN + 10
COLOR_DAY_SKY           = BLUE + 4
COLOR_SNOW_GEESE        = BLUE + 15
COLOR_FISH              = GREEN + 10
COLOR_KING_CRAB         = BRICK_RED + 8
COLOR_KILLER_CLAM       = YELLOW + 10
COLOR_BAILEY_COAT       = BLACK + 6


NORTHERN_LIGHTS_COLOR_01 = YELLOW + 8
NORTHERN_LIGHTS_COLOR_02 = YELLOW + 8
NORTHERN_LIGHTS_COLOR_03 = RED_ORANGE + 8
NORTHERN_LIGHTS_COLOR_04 = RED_ORANGE + 8
NORTHERN_LIGHTS_COLOR_05 = BRICK_RED + 8
NORTHERN_LIGHTS_COLOR_06 = BRICK_RED + 8
NORTHERN_LIGHTS_COLOR_07 = RED + 8
NORTHERN_LIGHTS_COLOR_08 = PURPLE + 8
NORTHERN_LIGHTS_COLOR_09 = COBALT_BLUE + 8
NORTHERN_LIGHTS_COLOR_10 = ULTRAMARINE_BLUE + 8

   ELSE

YELLOW                  = $20
RED_ORANGE              = $20
GREEN                   = $30
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE                  = $70
COLBALT_BLUE            = $80
CYAN                    = $A0
BLUE                    = $B0
DK_BLUE                 = BLUE
LT_BLUE                 = $C0
BLUE_2                  = $D0

COLOR_ARTIC_SEA         = BLUE + 2
COLOR_COPYRIGHT         = WHITE
COLOR_IGLOO             = WHITE
COLOR_IGLOO_DOOR_FLASH  = RED_ORANGE + 12
COLOR_INIT_ICE_BLOCK    = WHITE
COLOR_CHANGE_ICE_BLOCK  = $90 + 10
COLOR_PLAYER_1_SCORE    = BLUE + 14
COLOR_PLAYER_2_SCORE    = DK_GREEN + 10
COLOR_DAY_SKY           = BLUE + 6
COLOR_SNOW_GEESE        = BLUE + 15
COLOR_FISH              = DK_GREEN + 8
COLOR_KING_CRAB         = BRICK_RED + 12
COLOR_KILLER_CLAM       = RED_ORANGE + 10
COLOR_BAILEY_COAT       = BLACK + 4

NORTHERN_LIGHTS_COLOR_01 = YELLOW + 8
NORTHERN_LIGHTS_COLOR_02 = YELLOW + 8
NORTHERN_LIGHTS_COLOR_03 = BRICK_RED + 8
NORTHERN_LIGHTS_COLOR_04 = BRICK_RED + 8
NORTHERN_LIGHTS_COLOR_05 = RED + 8
NORTHERN_LIGHTS_COLOR_06 = RED + 8
NORTHERN_LIGHTS_COLOR_07 = COLBALT_BLUE + 8
NORTHERN_LIGHTS_COLOR_08 = COLBALT_BLUE + 8
NORTHERN_LIGHTS_COLOR_09 = CYAN + 8
NORTHERN_LIGHTS_COLOR_10 = CYAN + 8

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 8
H_BAILEY                = 18
H_COPYRIGHT             = 8
H_OBSTACLE              = 8
H_POLAR_GRIZZLY         = 19

SELECT_DELAY            = 30

XMIN                    = 0
XMAX                    = 160
YMIN_BAILEY             = 27
YMAX_BAILEY             = 112

INIT_NUM_LIVES          = 3
INIT_TEMPERATURE_VALUE  = $45       ; BCD
INIT_BAILEY_HORIZ_POS   = 64
INIT_POLAR_GRIZZLY_HORIZ_POS = XMAX - 20
INIT_DELAY_ACTION_VALUE = 64
INIT_IGLOO_STATUS       = 0

MAX_IGLOO_INDEX         = 15

MAX_EATEN_FISH          = 12

MAX_RESERVED_LIVES      = 9

OBSTACLE_DIR_MASK       = %10000000
ICE_BLOCK_DIR_MASK      = %01000000
OBSTACLE_TYPE_MASK      = %00000011

; gameState status values
DEMO_MODE               = %10000000

; Igloo status values
BAILEY_ENTERED_IGLOO    = %10000000

POINT_VALUE_MASK        = %11110000

OBSTACLE_NUSIZ_MASK     = %00001111
OBSTACLE_HORIZ_OFFSET_MASK = %11110000

ID_SNOW_GOOSE           = 0
ID_FISH                 = 1
ID_KING_CRAB            = 2 
ID_KILLER_CLAM          = 3

; currentLevelStatus values
BAILEY_SINKING          = %10000000
LEVEL_COMPLETE          = %01000000
SWAP_PLAYERS            = %00100000
BAILEY_FREEZING         = %00010000
INCREMENT_LEVEL         = %00001000

MAGIC_FISH_LEVEL        = 20

; Ice Block score values (BCD)
LEVEL_01_POINTS         = $10
LEVEL_02_POINTS         = $20
LEVEL_03_POINTS         = $30
LEVEL_04_POINTS         = $40
LEVEL_05_POINTS         = $50
LEVEL_06_POINTS         = $60
LEVEL_07_POINTS         = $70
LEVEL_08_POINTS         = $80
LEVEL_09_POINTS         = $90

POLAR_GRIZZLY_LEVEL     = 3

EAT_FISH_SOUND_VALUE    = %01000000
SOUND_VALUE_MASK        = %00011111

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
currentJoystickValues   ds 1
digitPointers           ds 12
;--------------------------------------
obstacleGraphicPtrs     = digitPointers
polarGrizzlyGraphicPtrs = obstacleGraphicPtrs + 2
baileyGraphicPtrs       = polarGrizzlyGraphicPtrs + 2
baileyColorPtrs         = baileyGraphicPtrs + 2
obstacleAttributes      ds 4
currentPointValue       ds 1
objectSpeedValues       ds 3
;--------------------------------------
iceBlockSpeedValue      = objectSpeedValues
obstacleSpeedValue      = iceBlockSpeedValue + 1
;--------------------------------------
polarGrizzlySpeedValue  = obstacleSpeedValue
baileySpeedValue        = obstacleSpeedValue + 1
fractionalPositionValues ds 3
iceBlockFineMotionValues ds 2
;--------------------------------------
iceBlockPlayerFineMotion = iceBlockFineMotionValues
iceBlockMissileFineMotion = iceBlockPlayerFineMotion + 1
iceBlockFineMotionIndex ds 1
iceBlocksHorizPos       ds 4
obstacleGraphicLSBValues ds 4
obstacleColors          ds 4
iceBlockColors          ds 4
actionButtonDebounce    ds 1
obstacleCollisionValues ds 8
baileyObstacleCollisionIdx ds 1
baileyIceBlockCollisionIdx ds 1
currentKernelSection    ds 1
skyColor                ds 1
landColor               ds 1
polarGrizzlyColor       ds 1
iglooDoorColor          ds 1
colorCycleMode          ds 1
iglooGraphicValues      ds 5
gameState               ds 1
copyrightScrollRate     ds 1
currentPlayerNumber     ds 1
currentPlayerVariables  ds 6
;--------------------------------------
playerScore             = currentPlayerVariables
currentLevel            = playerScore + 3
remainingLives          = currentLevel + 1
buildingIglooIdx        = remainingLives + 1
reservePlayerVariables  ds 6
;--------------------------------------
reservePlayerScore      = reservePlayerVariables
reserveCurrentLevel     = reservePlayerScore + 3
reserveRemainingLives   = reserveCurrentLevel + 1
reservedBuildingIglooIdx = reserveRemainingLives + 1
kernelObstacleHorizPos  ds 4
obstacleNUSIZValues     ds 4
obstaclePatternIndex    ds 4
obstacleHorizPos        ds 4
baileyVertPos           ds 1
temperatureValue        ds 1
baileyHorizPos          ds 1
frameDelayValue         ds 1
polarGrizzlyHorizPos    ds 1
iglooStatus             ds 1
baileyJumpingOffsetIdx  ds 1
baileyGraphicOffsetValue ds 1
playerRefectState       ds 1
baileyGrizzlyCollisionValue ds 1
baileyAnimationIdx      ds 1
polarGrizzlyAnimationIdx ds 1
baileyColorOffsetValue  ds 1
currentLevelStatus      ds 1
obstacleCollisionIndex  ds 1
soundValuesChannel_00   ds 1
soundValuesChannel_01   ds 1
completedIceBlocksDelay ds 1
baileyLandingStatus     ds 1
numberOfFishEaten       ds 1
tmpCharHolder           ds 1
;--------------------------------------
tmpDiv15Remainder       = tmpCharHolder
;--------------------------------------
tmpHorizPositionValue   = tmpDiv15Remainder
;--------------------------------------
tmpIglooKernelIdx       = tmpHorizPositionValue
;--------------------------------------
tmpIceBlockKernelIdx    = tmpIglooKernelIdx
;--------------------------------------
tmpKernelIdx            = tmpIceBlockKernelIdx
;--------------------------------------
tmpMovementSpeedValue   = tmpKernelIdx
;--------------------------------------
tmpHorizPosition        = tmpMovementSpeedValue
;--------------------------------------
tmpBaileyReflectState   = tmpHorizPosition
;--------------------------------------
tmpPolarGrizzlyReflectState = tmpBaileyReflectState
;--------------------------------------
tmpNewIceBlockDirection = tmpPolarGrizzlyReflectState
;--------------------------------------
tmpNewObstacleType      = tmpNewIceBlockDirection
;--------------------------------------
tmpObstacleAttribute    = tmpNewObstacleType
;--------------------------------------
tmpBaileySpeedValue     = tmpObstacleAttribute
tmpSixDigitLoopCount    ds 1
;--------------------------------------
tmpNorthernLightsColorMod = tmpSixDigitLoopCount
;--------------------------------------
tmpSpeedValue           = tmpNorthernLightsColorMod
;--------------------------------------
tmpHorizJoystickValues  = tmpSpeedValue
tmpDrawLogoLoopCount    ds 1
;--------------------------------------
tmpBaileyXMIN           = tmpDrawLogoLoopCount
changeIceBlockDirection ds 1

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
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
ClearRAM
   lda #0
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   jsr InitializeGameVariables
   ldx randomSeed                   ; get random seed value
   bne MainLoop                     ; branch if been through cart startup once
   inx                              ; x = 1
   stx randomSeed                   ; initialize random seed
   jmp JumpIntoConsoleSwitchCheck

MainLoop
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
   asl                              ; muliply the value by 8
   asl
   asl
   sta digitPointers + 2,y          ; set LSB pointer to digit
   dex
   bpl .bcd2DigitLoop
   inx                              ; x = 0
   ldy #<Blank
.suppressZeroLoop
   lda digitPointers,x              ; get LSB pointer to digit
   bne .setupGameColors             ; branch if done suppressing zeros
   sty digitPointers,x              ; store Blank character in digit
   inx
   inx
   cpx #10
   bcc .suppressZeroLoop
.setupGameColors
   jsr DetermineGameColors
   lda skyColor                     ; get color value for sky
   sta COLUBK                       ; set background color
   ldx currentPlayerNumber          ; get the current player number
   lda PlayerScoreColorsValues,x
   sta COLUP0                       ; set player colors for score digits
   sta COLUP1
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta HMCLR                        ; clear horizontal motion values
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda colorCycleMode         ; 3         get color cycle mode value
   rol                        ; 2         rotate D7 to D1
   rol                        ; 2
   rol                        ; 2
   and #DISABLE_TIA           ; 2         disable TIA when no player activity
   sta VBLANK                 ; 3 = @17
   jsr SetupFontHeightSixDigitDisplay;6
;--------------------------------------
   lda #<Blank                ; 2 = @22
   sta digitPointers          ; 3
   sta digitPointers + 6      ; 3
   sta digitPointers + 8      ; 3
   sta digitPointers + 10     ; 3
   lda #<DegressIndicator     ; 2
   sta digitPointers + 4      ; 3
   lda remainingLives         ; 3         get remaining lives
   beq .drawTemperature       ; 2³        branch if no remaining lives
   asl                        ; 2         multiply by 8 (i.e. H_FONT)
   asl                        ; 2
   asl                        ; 2
   sta digitPointers + 10     ; 3
.drawTemperature
   lda temperatureValue       ; 3         get current temperature value
   and #$F0                   ; 2         mask the lower nybble
   beq .setPointerForOnesValue; 2³        branch if no tens value
   lsr                        ; 2         divide the value by 2
   sta digitPointers          ; 3         set LSB pointer to digit
.setPointerForOnesValue
   lda temperatureValue       ; 3         get current temperature value
   and #$0F                   ; 2         mask the upper nybble
   sta HMCLR                  ; 3         clear horizontal motion
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   asl                        ; 2         multiply the value by 8
   asl                        ; 2
   asl                        ; 2
   sta digitPointers + 2      ; 3         set LSB pointer to digit
   lda digitPointers          ; 3         get temperature tens value
   cmp #<Blank                ; 2
   bne .checkToDrawMagicFish  ; 2³        branch if tens value present
   lda currentLevelStatus     ; 3         get curent level status values
   bne .checkToDrawMagicFish  ; 2³
   lda frameCount             ; 3         get current frame count
   and #8                     ; 2
   bne .checkToDrawMagicFish  ; 2³
   lda skyColor               ; 3
   sta COLUP0                 ; 3         blink temperature every 8 frames
   sta COLUP1                 ; 3
.checkToDrawMagicFish
   lda currentLevel           ; 3         get the current level
   cmp #MAGIC_FISH_LEVEL      ; 2
   bcc .drawTemperatureAndRemainingLives;2³
   lda #<Fish_00              ; 2         draw Magic Fish when passed level 20
   sta digitPointers + 6      ; 3
   lda #>Fish_00              ; 2
   sta digitPointers + 7      ; 3
.drawTemperatureAndRemainingLives
   jsr SetupFontHeightSixDigitDisplay;6
   ldx baileyAnimationIdx     ; 3         get Bailey animation index
   lda BaileyGraphicValues,x  ; 4         get Bailey graphic LSB value
   clc                        ; 2
   adc baileyGraphicOffsetValue;3         increment by graphic offset value
   sta baileyGraphicPtrs      ; 3
   lda BaileyColorValues,x    ; 4         get Bailey color LSB value
   clc                        ; 2
   adc baileyGraphicOffsetValue;3         increment by graphic offset value
   adc baileyColorOffsetValue ; 3         increment by color offset value
   sta baileyColorPtrs        ; 3
   ldx #>BaileyGraphics       ; 2         Bailey graphics and color on same page
   stx baileyGraphicPtrs + 1  ; 3
   stx baileyColorPtrs + 1    ; 3
   inx                        ; 2
   stx polarGrizzlyGraphicPtrs + 1;3
   stx obstacleGraphicPtrs + 1; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx polarGrizzlyAnimationIdx;3         get Polar Grizzly animation index
   lda PolarGrizzlyAnimationValues,x;4
   sta polarGrizzlyGraphicPtrs; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   sta VDELP0                 ; 3 = @14
   lda #COLOR_IGLOO           ; 2
   sta COLUPF                 ; 3 = @19
   lda iglooDoorColor         ; 3
   sta COLUP1                 ; 3 = @25
   lda randomSeed             ; 3         get random seed value
   sta tmpNorthernLightsColorMod;3
   and #2                     ; 2
   eor NorthernLightsColors + 9;4
   sta HMCLR                  ; 3 = @40
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda baileyHorizPos         ; 3         get Bailey's horizontal position
   cmp #15                    ; 2
   bcs .coarsePositionBailey  ; 2³
   sec                        ; 2
   sbc #15                    ; 2         subtract 14 saves 2 bytes
   ldx #HMOVE_L6              ; 2
   SLEEP 2                    ; 2
   sta.w RESP0                ; 4 = @25   coarse position Bailey to pixel 75
   stx HMP0                   ; 3 = @28
   bne .startNorthernLightsKernel;3       unconditional branch

.coarsePositionBailey
   SLEEP 2                    ; 2
.baileyHorizPosDiv15
   sbc #15                    ; 2
   bcs .baileyHorizPosDiv15   ; 2³
   sta RESP0                  ; 3         set Bailey's coarse position
.startNorthernLightsKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta tmpDiv15Remainder      ; 3         save remainder value for later
   lda tmpNorthernLightsColorMod;3        get color modulator value
   cmp #128                   ; 2
   rol                        ; 2         shift carry to D0
   sta tmpNorthernLightsColorMod;3
   and #2                     ; 2         keep D1 value
   eor NorthernLightsColors + 8;4
   sta COLUBK                 ; 3 = @25
   lda tmpDiv15Remainder      ; 3         get Bailey Bailey fine motion value
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP0                   ; 3 = @41
   lda playerRefectState      ; 3         get player REFLECT state
   sta REFP0                  ; 3 = @47   set REFLECT state for Bailey
   lsr                        ; 2         shift Polar Grizzly REFLECT state
   sta REFP1                  ; 3 = @52   set REFLECT state for Polar Grizzly
   lda buildingIglooIdx       ; 3         get building Igloo index value
   cmp #MAX_IGLOO_INDEX       ; 2
   bne ColorNorthernLights    ; 2³        branch if not done building Igloo
   sta RESP1                  ; 3         coarse position igloo door
ColorNorthernLights
   ldx #7                     ; 2
.colorNorthernLights
   lda tmpNorthernLightsColorMod;3
   cmp #128                   ; 2
   rol                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta tmpNorthernLightsColorMod;3
   and #2                     ; 2
   eor NorthernLightsColors,x ; 4
   cpx #0                     ; 2
   bne .setColorForNorthernLights;2³
   lda landColor              ; 3
.setColorForNorthernLights
   sta COLUBK                 ; 3 = @22
   lda #0                     ; 2
   sta PF1                    ; 3 = @27
   txa                        ; 2         move index to accumulator
   lsr                        ; 2         divide value by 4
   lsr                        ; 2
   tay                        ; 2         set index for drawing igloo top
   lda iglooGraphicValues + 3,y;4         get graphic value for igloo top
   dex                        ; 2
   sta PF1                    ; 3 = @44
   sta HMCLR                  ; 3 = @47
   bpl .colorNorthernLights   ; 2³
   ldy baileyVertPos          ; 3         get Bailey vertical position
   ldx #11                    ; 2
   stx VDELP1                 ; 3         delay GRP1 write (i.e. D0 = 1)
.drawIglooKernel
   stx tmpIglooKernelIdx      ; 3
   cpx #8                     ; 2
   lda IglooDoorGraphic,x     ; 4
   sta GRP1                   ; 3
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta PF1                    ; 3 = @06   clear PF1 register for left side
   bcs .skipBaileyDrawIglooSection;2³
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .skipBaileyDrawIglooSection;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @22
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyIglooKernel
   sta GRP0                   ; 3 = @30
   lda tmpIglooKernelIdx      ; 3         get igloo kernel index value
   lsr                        ; 2         divide by 4 (i.e. H_IGLOO_BRICK)
   lsr                        ; 2
   tax                        ; 2         set index for igloo graphics
   lda iglooGraphicValues,x   ; 4
   ldx tmpIglooKernelIdx      ; 3         restore igloo kernel index
   dex                        ; 2         decrement igloo kernel index
   sta PF1                    ; 3 = @51
   bpl .drawIglooKernel       ; 2³
   bmi .doneDrawIglooKernel   ; 3         unconditional branch

.skipBaileyDrawIglooSection
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   jmp .drawBaileyIglooKernel ; 3

.doneDrawIglooKernel
   inx                        ; 2         x = 0
   txa                        ; 2
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP1                   ; 3 = @06
   bcs .setPolarGrizzlyColorAndSize;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @16
   lda (baileyGraphicPtrs),y  ; 5
.setPolarGrizzlyColorAndSize
   sta GRP0                   ; 3 = @24
   stx PF1                    ; 3 = @27
   lda polarGrizzlyColor      ; 3
   sta COLUP1                 ; 3 = @33
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ1                 ; 3 = @38
   txa                        ; 2
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .positionPolarGrizzlyHorizontally;2³
   lda (baileyGraphicPtrs),y  ; 5
   tax                        ; 2
   lda (baileyColorPtrs),y    ; 5
.positionPolarGrizzlyHorizontally
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx GRP0                   ; 3 = @06
   sta COLUP0                 ; 3 = @09
   lda polarGrizzlyHorizPos   ; 3         get Polar Grizzly horizontal position
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.coarsePositionPolarGrizzly
   sbc #15                    ; 2
   bcs .coarsePositionPolarGrizzly;2³
   sta RESP1                  ; 3         set Polar Grizzly coarse position
   sta CXCLR                  ; 3         clear all hardward collision values
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta tmpDiv15Remainder      ; 3         save remainder value for later
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .setPolarGrizzlyFineMotion;2³
   lda (baileyGraphicPtrs),y  ; 5
   sta GRP0                   ; 3
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3
.setPolarGrizzlyFineMotion
   lda tmpDiv15Remainder      ; 3         get Polar Grizzly fine motion value
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP1                   ; 3
   ldx #H_POLAR_GRIZZLY - 1   ; 2
.polarGrizzlyKernel
   dey                        ; 2
   sty tmpKernelIdx           ; 3
   txa                        ; 2
   tay                        ; 2
   lda (polarGrizzlyGraphicPtrs),y;5
   sta GRP1                   ; 3
   lda #0                     ; 2
   ldy tmpKernelIdx           ; 3
   cpy #H_BAILEY + 1          ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .drawBaileyForPolarGrizzlyKernel;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @13
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyForPolarGrizzlyKernel
   sta GRP0                   ; 3 = @21
   jsr Waste14Cycles          ; 14
   sta HMCLR                  ; 3 = @38
   ldy tmpKernelIdx           ; 3
   dex                        ; 2
   bpl .polarGrizzlyKernel    ; 2³
   lda CXPPMM                 ; 3         get player collision values
   bpl .noBaileyGrizzlyCollision;2³       branch if players didn't collide
   sta baileyGrizzlyCollisionValue;3      Bailey and Grizzly collided
.noBaileyGrizzlyCollision
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @08
   bcs ObstacleKernelSection  ; 2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @18
   lda (baileyGraphicPtrs),y  ; 5
ObstacleKernelSection
   sta GRP0                   ; 3 = @26
   sta CXCLR                  ; 3 = @29   clear hardware collision registers
   ldx #7                     ; 2
.drawObstacleKernelSection
   stx currentKernelSection   ; 3
   lda #0                     ; 2
   sta GRP1                   ; 3 = @39
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .obstacleKernelScanline_01;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @53
   lda (baileyGraphicPtrs),y  ; 5
.obstacleKernelScanline_01
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   lda #COLOR_ARTIC_SEA       ; 2
   sta COLUBK                 ; 3 = @11   set color for Artic Sea
   txa                        ; 2         move kernel section to accumulator
   lsr                        ; 2         divide value by 2
   tax                        ; 2
   lda iceBlocksHorizPos,x    ; 4         get Ice Block horizontal position
   bcc .kernelSectionTypeDetermined; 2³   branch if an Ice Block section
   lda kernelObstacleHorizPos,x;4         get obstacle kernel horizontal position
.kernelSectionTypeDetermined
   sta tmpHorizPositionValue  ; 3
   lda obstacleNUSIZValues,x  ; 4
   sta NUSIZ1                 ; 3
   sta HMCLR                  ; 3
   lda #0                     ; 2
   sta VDELP1                 ; 3
   sta REFP1                  ; 3
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .obstacleKernelScanline_02;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3
   lda (baileyGraphicPtrs),y  ; 5
.obstacleKernelScanline_02
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   lda tmpHorizPositionValue  ; 3
   cmp #15                    ; 2
   dey                        ; 2
   bcs .coarsePositionObstacle; 2³
   sec                        ; 2
   sbc #15                    ; 2         subtract 14 saves 2 bytes
   ldx #HMOVE_L6              ; 2
   sta.w RESP1                ; 4 = @25   coarse position obstacle to pixel 75
   stx HMP1                   ; 3 = @28
   bne .obstacleKernelScanline_03;3       unconditional branch

.coarsePositionObstacle
   sbc #15                    ; 2
   bcs .coarsePositionObstacle; 2³
   sta RESP1                  ; 3
.obstacleKernelScanline_03
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   tax                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .setObstacleFineMotionValue;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3
   lda (baileyGraphicPtrs),y  ; 5
   sta GRP0                   ; 3
.setObstacleFineMotionValue
   txa                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   eor #7 << 4                ; 2         3-bit 1's complement for fine motion
   sta HMP1                   ; 3
   lda currentKernelSection   ; 3         get current kernel section value
   lsr                        ; 2         divide value by 2
   tax                        ; 2
   lda obstacleGraphicLSBValues,x;4       get obstacle graphic LSB value
   sta obstacleGraphicPtrs    ; 3
   lda obstacleColors,x       ; 4
   sta COLUP1                 ; 3
   lda obstacleAttributes,x   ; 4         get obstacle attribute value
   bpl .obstacleKernelScanline_04;2³      branch if traveling right
   lda #REFLECT               ; 2
   sta REFP1                  ; 3
.obstacleKernelScanline_04
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   bcs .determineObstacleOrIceBlockKernel;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @17
   lda (baileyGraphicPtrs),y  ; 5
   sta GRP0                   ; 3 = @25
.determineObstacleOrIceBlockKernel
   lda #LOCK_MISSILE | VERTICAL_DELAY;2
   sta RESMP1                 ; 3 = @30
   sta VDELP1                 ; 3 = @33
   lda currentKernelSection   ; 3         get current kernel section value
   lsr                        ; 2         divide value by 2
   sta CXCLR                  ; 3 = @51   clear hardware collision values
   sta HMCLR                  ; 3 = @54   clear horizontal motion values
   bcc .iceBlockKernel        ; 2³        branch on ice block kernel section
   ldx #H_OBSTACLE - 1        ; 2
.drawObstacleKernel
   dey                        ; 2
   sty tmpKernelIdx           ; 3
   txa                        ; 2
   tay                        ; 2
   lda (obstacleGraphicPtrs),y; 5
   sta GRP1                   ; 3
   ldy tmpKernelIdx           ; 3
   cpy #H_BAILEY + 1          ; 2
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .drawBaileyObstacleKernel;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @13
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyObstacleKernel
   sta GRP0                   ; 3 = @21
   dex                        ; 2
   bpl .drawObstacleKernel    ; 2³
   ldx currentKernelSection   ; 3         get current kernel section value
   lda CXPPMM                 ; 3         get player collision values
   sta obstacleCollisionValues,x;4        set collision value for section
   dex                        ; 2
   jmp .drawObstacleKernelSection;3

.iceBlockKernel
   tax                        ; 2
   lda iceBlockColors,x       ; 4
   sta COLUP1                 ; 3 = @66
   lda #0                     ; 2
   sta GRP1                   ; 3 = @71
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .drawBaileyIceBlockScanline_02;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @13
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyIceBlockScanline_02
   sta GRP0                   ; 3 = @21
   lda #MSBL_SIZE8 | THREE_MED_COPIES;2
   sta NUSIZ1                 ; 3 = @26
   lda #0                     ; 2
   sta GRP1                   ; 3 = @31
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .drawBaileyIceBlockScanline_03;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @13
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyIceBlockScanline_03
   sta GRP0                   ; 3 = @21
   jsr Waste12Cycles          ; 12
   lda iceBlockMissileFineMotion;3
   sta RESMP1                 ; 3 = @39
   sta HMM1                   ; 3 = @42
   lda iceBlockPlayerFineMotion;3
   sta HMP1                   ; 3 = @48
   ldx #6                     ; 2
   stx tmpIceBlockKernelIdx   ; 3
.drawIceBlock
   dey                        ; 2
   ldx #$FF                   ; 2
   stx GRP1                   ; 3
   cpy #H_BAILEY + 1          ; 2
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .drawBaileyIceBlockScanline_04;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @13
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyIceBlockScanline_04
   sta GRP0                   ; 3 = @21
   stx ENAM1                  ; 3 = @24
   ldx tmpIceBlockKernelIdx   ; 3
   lda IceBlockFineMotionAdjustmentValues,x;4
   sta HMM1                   ; 3 = @34
   sta HMP1                   ; 3 = @37
   dec tmpIceBlockKernelIdx   ; 5
   bpl .drawIceBlock          ; 2³
   sta HMCLR                  ; 3 = @47
   dey                        ; 2
   cpy #H_BAILEY + 1          ; 2
   lda #0                     ; 2
   sta GRP1                   ; 3 = @56
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENAM1                  ; 3 = @06
   bcs .drawBaileyIceBlockScanlineFinal;2³
   lda (baileyColorPtrs),y    ; 5
   sta COLUP0                 ; 3 = @16
   lda (baileyGraphicPtrs),y  ; 5
.drawBaileyIceBlockScanlineFinal
   sta GRP0                   ; 3 = @24
   ldx currentKernelSection   ; 3         get current kernel section value
   lda CXPPMM                 ; 3         get player collision values
   ora CXM1P                  ; 3         combine with missile collision value
   sta obstacleCollisionValues,x;4
   dex                        ; 2
   bmi .doneDrawingGameKernel ; 2³
   jmp .drawObstacleKernelSection;3

.doneDrawingGameKernel
   stx baileyObstacleCollisionIdx;3       set to reset collision values
   stx baileyIceBlockCollisionIdx;3
   inx                        ; 2         x = 0
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx GRP0                   ; 3 = @06
   stx GRP1                   ; 3 = @09
   stx REFP0                  ; 3 = @12
   stx REFP1                  ; 3 = @15
   sta HMCLR                  ; 3 = @18
   stx VDELP1                 ; 3 = @21
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
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
   eor #7                     ; 2
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
   bpl .setupCopyrightGraphicPointers;2³ + 1
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx #BLACK                 ; 2
   stx COLUBK                 ; 3 = @08
   stx COLUPF                 ; 3 = @11
   lda #COLOR_COPYRIGHT       ; 2
   sta COLUP0                 ; 3 = @16
   sta COLUP1                 ; 3 = @19
   ldx #11                    ; 2
   lda #>CopyrightFonts       ; 2
.setDigitPointersMSBValue
   sta digitPointers,x        ; 4
   dex                        ; 2
   dex                        ; 2
   bpl .setDigitPointersMSBValue;2³
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
   lda #OVERSCAN_TIME
   ldx #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scanline
   sta TIM64T                       ; set timer for overscan period
   stx VBLANK                       ; disable TIA and discharge paddles
   lda #0
   sta GRP0
   sta GRP1
   sta GRP0
   sta PF1
   sta ENABL
   lda copyrightScrollRate          ; get copyright scroll rate
   beq ResetIglooGraphicValues
   lda playerScore + 2              ; get score tens value
   and #$0F                         ; keep 1's value
   ora currentLevelStatus           ; combine with current level status values
   bne ResetIglooGraphicValues      ; branch if game in SELECT_MODE
   lda frameCount                   ; get current frame count
   and #$7F
   bne ResetIglooGraphicValues
   lda gameSelection                ; get current game selection
   lsr                              ; shift D0 to carry
   bcc ResetIglooGraphicValues
   jsr SwapPlayerVariables
ResetIglooGraphicValues
   ldx #4
   lda #0
.resetIglooGraphicValues
   sta iglooGraphicValues,x
   dex
   bpl .resetIglooGraphicValues
   bit gameState                    ; check current game state
   bpl CheckToPlayGameSounds        ; branch if not DEMO_MODE
   jmp SetObstacleCollisionIndex

CheckToPlayGameSounds
   lda baileyColorOffsetValue       ; get Bailey color offset value
   ora baileyGraphicOffsetValue     ; combine with Bailey graphic offset value
   beq .checkFirstPrioritySoundChannel_1; branch if Bailey not sinking or freezing
   clc
   tax
   adc #8
   sta AUDF0
   sta AUDF1
   lda #12
   sta AUDC1
   lda #1
   sta AUDC0
   lda #4
   cpx #18
   bne .setVolumeForDeathSounds
   lda #0
   sta soundValuesChannel_01        ; clear sound channel 1 values
.setVolumeForDeathSounds
   sta AUDV0
   sta AUDV1
.checkFirstPrioritySoundChannel_1
   bit soundValuesChannel_01        ; check sound channel 1 values
   bvc .checkFirstPrioritySoundChannel_0; branch if not playing eating fish sounds
   dec soundValuesChannel_01        ; decrement sound values
   lda soundValuesChannel_01        ; get sound  channel 1 value
   and #SOUND_VALUE_MASK            ; keep sound values
   bne .setFirstPrioritySoundChannel_1Values
   sta soundValuesChannel_01        ; clear sound channel 1 values (i.e. a = 0)
.setFirstPrioritySoundChannel_1Values
   sta AUDF1
   ldx #12
   stx AUDC1
   ldx #0
   and #3
   beq .setSoundVolumeForEatingFish
   lda #$10
   jsr IncrementScore               ; increment score for eating fish
   ldx #5
.setSoundVolumeForEatingFish
   stx AUDV1
.checkFirstPrioritySoundChannel_0
   bit soundValuesChannel_00        ; check sound channel 0 values
   bpl .checkSecondPrioritySoundChannel_1
   dec soundValuesChannel_00        ; decrement sound values
   lda soundValuesChannel_00        ; get sound  channel 0 value
   and #SOUND_VALUE_MASK            ; keep sound values
   bne .setFirstPrioritySoundChannel_0Values
   sta soundValuesChannel_00        ; clear sound channel 0 values (i.e. a = 0)
.setFirstPrioritySoundChannel_0Values
   sta AUDV0
   cmp #7
   bcs .setFirstPrioritySoundChannel_0Frequency
   lda #7
.setFirstPrioritySoundChannel_0Frequency
   sta AUDF0
   lda #12
   sta AUDC0
.checkSecondPrioritySoundChannel_1
   bit soundValuesChannel_01        ; check sound channel 1 values
   bpl .checkSecondPrioritySoundChannel_0; branch if not playing sound
   dec soundValuesChannel_01        ; decrement sound values
   lda soundValuesChannel_01        ; get sound  channel 1 value
   and #SOUND_VALUE_MASK            ; keep sound values
   bne .setSecondPrioritySoundChannel_1Values
   sta soundValuesChannel_01        ; clear sound channel 1 values (i.e. a = 0)
.setSecondPrioritySoundChannel_1Values
   lsr
   sta AUDV1
   lda #8
   sta AUDC1
   lda #2
   sta AUDF1
.checkSecondPrioritySoundChannel_0
   bit soundValuesChannel_00        ; check sound channel 0 values
   bvc SetObstacleCollisionIndex
   lda soundValuesChannel_00        ; get sound  channel 0 value
   and #SOUND_VALUE_MASK            ; keep sound values
   lsr
   sta AUDV0
   sta AUDV1
   lda #12
   sta AUDC0
   sta AUDC1
   lda soundValuesChannel_00        ; get sound  channel 0 value
   bit buildingIglooIdx             ; check building Igloo index value
   bmi .divSoundValueBy2            ; branch if no Igloo blocks
   sec
   sbc #2
   ldx #12                          ; value for channel 0 frequency
   ldy #15                          ; value for channel 1 frequency
   bne .setSecondPrioritySoundChannel_0Values; unconditional branch

.divSoundValueBy2
   lsr
   ldx #5                           ; value for channel 0 frequency
   ldy #1                           ; value for channel 1 frequency
.setSecondPrioritySoundChannel_0Values
   stx AUDF0
   sty AUDF1
   and #SOUND_VALUE_MASK            ; keep sound values
   beq .setSoundChannel_0Value
   ora #1 << 6
.setSoundChannel_0Value
   sta soundValuesChannel_00
SetObstacleCollisionIndex
   ldx #7
.setObstacleCollisionIndex
   dex
   lda obstacleCollisionValues + 1,x; get obstacle collision value
   bpl .checkForBaileyIceBlockCollision; branch if no collision occurred
   txa                              ; move index to accumulator
   lsr                              ; divide value by 2
   sta baileyObstacleCollisionIdx
.checkForBaileyIceBlockCollision
   lda obstacleCollisionValues,x    ; get ice block collision value
   bpl .checkSectionForCollision    ; branch if no collision occurred
   txa                              ; move index to accumulator
   lsr                              ; divide value by 2
   sta baileyIceBlockCollisionIdx
.checkSectionForCollision
   dex
   bpl .setObstacleCollisionIndex
   lda #3
   bit gameState                    ; check current game state
   bmi .setInitMovementSpeed        ; branch if in DEMO_MODE
   lda currentLevel                 ; get the current level
.setInitMovementSpeed
   clc

   IF COMPILE_REGION = PAL50

   adc #3
   sta tmpMovementSpeedValue
   lsr                              ; divide value by 4
   lsr
   adc tmpMovementSpeedValue        ; add back original (i.e. (5x + 15) / 4)

   ELSE        

   adc #4

   ENDIF

   tay                              ; move initial movement speed to y register
   sec
   sbc #15
   bcc .determineSpeedFractionalValues
.reduceInitMovementSpeed
   dey
   dey
   dey
   sbc #7
   bcs .reduceInitMovementSpeed
.determineSpeedFractionalValues
   tya                              ; move initial movement speed to accumulator
   ldx #0
   lsr                              ; divide value by 2
   jsr DetermineFractionalPositioning; determine Ice Block fractional position
   inx
   dey                              ; reduce initial movement speed for obstacle
   tya
   jsr DetermineFractionalPositioning; determine Obstacle Speed fractional value
   inx
   iny
   tya
   jsr DetermineFractionalPositioning;determine Bailey fractional value
   lda #0
   sta changeIceBlockDirection      ; clear change Ice Block direction indicator
   ldx currentPlayerNumber          ; get the current player number
   lda INPT4,x                      ; read action button
   tay                              ; move action button value to y register
   and actionButtonDebounce         ; and with debounce value
   eor actionButtonDebounce         ; flip D7 value
   sty actionButtonDebounce         ; set debounce value
   bpl .setIceBlockFineMotionValues ; branch if action button not released
   lda baileyJumpingOffsetIdx       ; get jumping index value
   bne .setIceBlockFineMotionValues ; branch if Bailey is jumping
   lda #<-1
   sta changeIceBlockDirection      ; set D7 high to change Ice Block direction
.setIceBlockFineMotionValues
   ldx iceBlockFineMotionIndex      ; get Ice Block fine motion index value
   lda IceBlockFineMotionValues,x   ; get Ice Block fine motion value
   tay
   and #$F0                         ; keep upper nybbles for missile fine motion
   sta iceBlockMissileFineMotion
   tya                              ; get Ice Block fine motion value
   asl                              ; shift player fine motion to upper nybbles
   asl
   asl
   asl
   sta iceBlockPlayerFineMotion
   ldx currentLevel                 ; get the current level
   cpx #8
   bcc .setLevelPointValue          ; set point value if less than level 8
   ldx #8                           ; set to maximum point value
.setLevelPointValue
   lda PointValueTable,x
   and #POINT_VALUE_MASK            ; keep point values
   sta currentPointValue            ; set current point value
   ldx buildingIglooIdx             ; get building Igloo index value
   bmi .doneSetIglooRAMValues       ; branch if no Igloo blocks
   ldx #0
.setIglooRAMValues
   ldy IglooGraphicRAMIndexValues,x ; get index pointer value for Igloo RAM
   lda IglooGraphicValues,x
   sta iglooGraphicValues,y
   cpx buildingIglooIdx
   bcs .doneSetIglooRAMValues
   inx
   bpl .setIglooRAMValues           ; unconditional branch

.doneSetIglooRAMValues
   lda frameCount                   ; get current frame count
   and #7
   bne VerticalSync
   jsr NextRandom                   ; get new random number every 8 frames
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | START_VERT_SYNC
   sty WSYNC                        ; wait for next scanline
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
   sta WSYNC                        ; wait for next scanline
   sta TIM64T                       ; set timer for vertical blank period
   ldy SWCHA                        ; read the player joystick values
   lda frameCount                   ; get current frame count
   and #7
   bne SetPlayerControlValues
   lda copyrightScrollRate          ; get copyright scroll rate
   beq SetPlayerControlValues
   ldy #NO_MOVE
   dec copyrightScrollRate
   bne SetPlayerControlValues
   dec copyrightScrollRate
   lda gameState                    ; get current game state
   bmi SetPlayerControlValues       ; branch if in DEMO_MODE
   ora #DEMO_MODE
   sta gameState                    ; set game state to DEMO_MODE
   ldx #<kernelObstacleHorizPos
   bne .jmpToClearRAM               ; unconditional branch   

SetPlayerControlValues
   lda currentPlayerNumber          ; get the current player number
   lsr                              ; shift D0 to carry
   tya                              ; shift joystick value to accumulator
   bcs .setPlayerJoystickValue      ; branch if player 2 currently active
   jsr ShiftUpperNybblesToLower     ; shift player 1 joystick values
.setPlayerJoystickValue
   and #$0F                         ; keep joystick values
   sta currentJoystickValues
   iny
   beq .checkForSelectAndReset      ; branch if joystick not moved
   lda #0
   sta colorCycleMode               ; reset color cycle mode
.checkForSelectAndReset
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   bcs .skipGameReset               ; check for SELECT if RESET not pressed
   ldx #<colorCycleMode
.jmpToClearRAM
   jmp ClearRAM

.skipGameReset
   ldy #0
   lsr                              ; SELECT now in carry
   bcs .resetSelectDebounce
   lda selectDebounce               ; get the select debounce delay
   beq .incrementGameSelection      ; if it's zero -- increase game selection
   dec selectDebounce               ; decrement select debounce
   bpl .skipGameSelect
.incrementGameSelection
   sta AUDV0
   sta AUDV1
   sta baileyGraphicOffsetValue
   sta baileyColorOffsetValue
   sta soundValuesChannel_01        ; clear sound channel 1 values
   lda #1 << 7 | 15
   sta soundValuesChannel_00
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
   sty playerScore                  ; show current game selection
   lda #[(Blank - NumberFonts) / H_FONT] << 4 | [(Blank - NumberFonts) / H_FONT]
   sta playerScore + 1
   sta playerScore + 2
   lda #$FF
   sta copyrightScrollRate
   ldy #SELECT_DELAY
.resetSelectDebounce
   sty selectDebounce
.skipGameSelect
   lda frameDelayValue              ; get frame delay value
   beq GameProcessing
   dec frameDelayValue
   bpl JmpToMainLoop                ; unconditional branch

GameProcessing
   bit gameState                    ; check current game state
   bmi .checkBaileyChasedOffScreen  ; branch if in DEMO_MODE
   lda copyrightScrollRate          ; get copyright scroll rate
   bne JmpToMainLoop
.checkBaileyChasedOffScreen
   lda currentLevelStatus           ; get current level status values
   ora baileyHorizPos               ; combine with Bailey horizontal position
   bne .checkToDecrementIceBlockDelayValue; branch if Bailey not chased off screen
   lda #BAILEY_SINKING
   sta currentLevelStatus           ; set level status to BAILEY_SINKING
.checkToDecrementIceBlockDelayValue
   lda completedIceBlocksDelay
   beq .checkToPerformBaileyDeathAnimation
   dec completedIceBlocksDelay
.checkToPerformBaileyDeathAnimation
   bit currentLevelStatus           ; check current level status value
   bpl .checkToRewardLevelCompletePoints; branch if Bailey not sinking
   lda baileyGraphicOffsetValue     ; get Bailey graphic offset value
   cmp #H_BAILEY
   bcs .setLevelStatusToSwapPlayers ; branch if done sinking animation
   jsr BaileyDeathAnimation
   inc baileyGraphicOffsetValue     ; increment to show Bailey sinking
JmpToMainLoop 
   jmp .mainLoop

.setLevelStatusToSwapPlayers
   lda #SWAP_PLAYERS
   sta currentLevelStatus
   lda #SWAP_PLAYERS_FRAME_DELAY
   sta frameDelayValue              ; set to delay action for ~1.86 seconds
   bne JmpToMainLoop                ; unconditional branch
       
.checkToRewardLevelCompletePoints
   bvc CheckToSwapPlayers           ; branch if not rewarding Igloo points
   bit buildingIglooIdx             ; check building Igloo index value
   bmi .checkToRewardPointsForRemainingTemperature; branch if no Igloo blocks
   dec buildingIglooIdx
   lda #INCREMENT_SCORE_FRAME_DELAY
   bne .incrementScoreForBonus      ; set to delay action for 6 frames

.checkToRewardPointsForRemainingTemperature
   lda temperatureValue             ; get current temperature value
   beq .setLevelStatusToIncrementLevel; branch if reached 0 -- time out
   jsr ReduceTemperature
   lda #2                           ; set to delay action for 2 frames
.incrementScoreForBonus 
   sta frameDelayValue
   lda currentPointValue            ; get current point value
   jsr IncrementScore
   lda #1 << 6 | 21
   sta soundValuesChannel_00
   bne JmpToMainLoop                ; unconditional branch

.setLevelStatusToIncrementLevel
   sta numberOfFishEaten            ; reset number of fish eaten (i.e. a = 0)
   lda #INCREMENT_LEVEL
   sta currentLevelStatus
   lda #INCREMENT_LEVEL_FRAME_DELAY
   sta frameDelayValue              ; set to delay action for 48 frames
   bne JmpToMainLoop                ; unconditional branch

CheckToSwapPlayers
   lda currentLevelStatus           ; get current level status values
   and #SWAP_PLAYERS                ; keep SWAP_PLAYERS bit value
   beq CheckForBaileyFreezingAnimation; branch if not swapping players
   bit gameState                    ; check current game state
   bmi .initIceBlockAndObstacleValues; branch if in DEMO_MODE
   lda remainingLives               ; get remaining lives
   ora reserveRemainingLives        ; combine with reserved remaining lives
   bne .swapPlayerVariables         ; branch if lives remaining
   sta currentLevelStatus           ; clear current level status (i.e. a = 0)
   dec copyrightScrollRate          ; decrement scroll rate value
   bmi JmpToMainLoop                ; unconditional branch

.swapPlayerVariables
   jsr SwapPlayerVariables
   lda remainingLives               ; get remaining lives
   bne .decrementRemainingLives     ; branch if lives remaining
   jsr SwapPlayerVariables
.decrementRemainingLives
   dec remainingLives
.initIceBlockAndObstacleValues
   jsr SetInitIceBlockAndObstacleValues
   jmp JmpToMainLoop

CheckForBaileyFreezingAnimation
   lda currentLevelStatus           ; get current level status values
   and #BAILEY_FREEZING             ; keep BAILEY_FREEZING status bit
   beq CheckToIncrementLevel        ; branch if Bailey not freezing
   jsr BaileyDeathAnimation
   inc baileyColorOffsetValue
   lda baileyColorOffsetValue       ; get Bailey color offset value
   cmp #H_BAILEY
   bne .doneCheckForBaileyFreezingAnimation
   jmp .setLevelStatusToSwapPlayers

.doneCheckForBaileyFreezingAnimation
   jmp .mainLoop

CheckToIncrementLevel 
   lda currentLevelStatus           ; get current level status values
   and #INCREMENT_LEVEL             ; keep INCREMENT_LEVEL bit value
   beq DetermineMovementForDemoMode ; branch if not incrementing level
   bit gameState                    ; check current game state
   bmi .initIceBlockAndObstacleValues; branch if in DEMO_MODE
   inc currentLevel                 ; increment current level

   IF COMPILE_REGION = PAL50

   bpl .initIceBlockAndObstacleValues; unconditional branch (PAL50 saves a byte)

   ELSE

   jmp .initIceBlockAndObstacleValues

   ENDIF

DetermineMovementForDemoMode
   bit gameState                    ; check current game state
   bpl CheckGrizzlyChasingBailey    ; branch if not in DEMO_MODE
   lda #7
   cmp currentLevel
   bcc .determineMovementForDemoMode
   sta currentLevel
.determineMovementForDemoMode
   lda #0
   sta baileyColorOffsetValue
   sta baileyGraphicOffsetValue
   sta soundValuesChannel_00        ; clear sound channel 0 values
   sta soundValuesChannel_01        ; clear sound channel 1 values
   sta baileyGrizzlyCollisionValue  ; clear Bailey and Grizzly collision value
   lda baileyVertPos                ; get Bailey vertical position
   cmp #YMIN_BAILEY
   bne .determineBaileyIceKernelMovement; branch if Bailey not standing on shore
   lda #<(MOVE_LEFT & MOVE_UP) >> 4
   ldx frameCount                   ; get current frame count
   cpx #80
   bcc .setJoystickValuesForStandingOnShore
   lda #<(MOVE_RIGHT & MOVE_UP) >> 4
.setJoystickValuesForStandingOnShore
   sta currentJoystickValues
.determineBaileyIceKernelMovement
   ldx baileyIceBlockCollisionIdx   ; get Bailey Ice Block collision value
   dex
   bpl .compareHorizPosToNextIceBlock; branch if Bailey standing on Ice Block
   ldx #3                           ; set index for top row Ice Blocks
.compareHorizPosToNextIceBlock
   lda baileyHorizPos               ; get Bailey's horizontal position
   cmp iceBlocksHorizPos,x          ; compare with Ice Block position
   bcs .determineBaileyDemoMovement ; branch if Bailey to the right of Ice Block
   adc #XMAX
.determineBaileyDemoMovement
   adc #1
   sec
   sbc iceBlocksHorizPos,x
   cmp #75
   bcs .checkBaileyOnTopIceBlockRow
   lda #<-1
   sta obstacleCollisionIndex       ; reset obstacle collision index value
   lda #<(MOVE_LEFT & MOVE_DOWN) >> 4
   bit frameCount                   ; check frame count
   bpl .setJoystickValuesForDemoMode; branch if less than 128
   lda #<(MOVE_RIGHT & MOVE_UP) >> 4
   bne .setJoystickValuesForDemoMode

.checkBaileyOnTopIceBlockRow
   cpx #2
   bne CheckGrizzlyChasingBailey    ; branch if Bailey not on top Ice Block row
   lda #<(MOVE_LEFT & MOVE_UP) >> 4
.setJoystickValuesForDemoMode
   sta currentJoystickValues
CheckGrizzlyChasingBailey
   bit baileyGrizzlyCollisionValue  ; check Bailey and Grizzly collision value
   bpl .doneCheckGrizzlyChasingBailey; branch if didn't collide
   lda baileyJumpingOffsetIdx       ; get jumping index value
   bne .doneCheckGrizzlyChasingBailey; branch if Bailey is jumping
   lda currentLevel                 ; get the current level
   cmp #POLAR_GRIZZLY_LEVEL
   bcc .doneCheckGrizzlyChasingBailey; branch if Polar Grizzly not active
   lda #REFLECT
   sta playerRefectState            ; set Bailey REFLECT state
   lda frameCount                   ; get current frame count
   and #3
   sta polarGrizzlyAnimationIdx
   beq .animateBaileyForGrizzlyChase
   lda polarGrizzlyHorizPos         ; get Polar Grizzly horizontal position
   cmp #XMIN + 16
   bcc .animateBaileyForGrizzlyChase; branch if Grizzly reached left border
   dec polarGrizzlyHorizPos         ; decrement Polar Grizzly horizontal position
.animateBaileyForGrizzlyChase
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 2
   and #3
   sta baileyAnimationIdx
   dec baileyHorizPos               ; decrement Bailey's horizontal position
   lda #1
   sta AUDC0
   lda #8
   sta AUDC1
   lda #4                           ; LSR would save a byte
   sta AUDV0
   sta AUDV1
   lda frameCount                   ; get current frame count
   asl                              ; multiply value by 4
   asl
   and #$1F
   sta AUDF0
   sta AUDF1
   jmp .mainLoop

.doneCheckGrizzlyChasingBailey
   lda currentLevel                 ; get the current level
   lsr                              ; shift D0 to carry
   bcc MoveObstacles                ; branch on even levels
   cmp #2
   bcc MoveObstacles
   lda frameCount                   ; get current frame count
   and #$0F
   bne MoveObstacles
   dec iceBlockFineMotionIndex      ; decrement Ice Block fine motion index
   bpl MoveObstacles
   lda #15
   sta iceBlockFineMotionIndex      ; reset Ice Block fine motion index value
MoveObstacles
   ldx #3
.moveObstacles
   lda currentLevel                 ; get the current level
   cmp #5
   bcc .moveObstacleHorizontally
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep obstacle type value
   tay
   lda frameCount                   ; get current frame count
   and #$40
   bne .checkToMoveAllButKingCrab   ; branch every 64 frames
   cpy #ID_KILLER_CLAM
   beq .moveNextObstacle            ; branch if obstacle is a KILLER_CLAM
   bne .moveObstacleHorizontally

.checkToMoveAllButKingCrab
   cpy #ID_KING_CRAB
   beq .moveNextObstacle            ; branch if obstacle is a KING_CRAB
.moveObstacleHorizontally
   lda obstacleAttributes,x         ; get obstacle attribute value
   asl                              ; shift obstacle direction to carry
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   bcs .moveObstacleLeft            ; branch if obstacle moving left
   adc obstacleSpeedValue           ; move obstacle right
   jmp .setObstacleHorizPos

.moveObstacleLeft
   sbc obstacleSpeedValue
.setObstacleHorizPos
   sta obstacleHorizPos,x
   and #$F8
   cmp #XMAX + 40
   beq .spawnNewObstacle
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   jsr DetermineObstacleNUSIZValues
   jmp .checkBaileyMovingWithObstacle

.spawnNewObstacle
   jsr NextRandom
   jsr SpawnNewObstacle
.checkBaileyMovingWithObstacle
   cpx obstacleCollisionIndex
   bne .moveNextObstacle            ; branch if not collided with obstacle
   lda obstacleAttributes,x         ; get obstacle attribute value
   asl                              ; shift obstacle direction to carry
   lda baileyHorizPos               ; get Bailey's horizontal position
   bcs .obstacleMovingBaileyLeft    ; branch if obstacle traveling left
   adc obstacleSpeedValue           ; obstacle pushing Bailey right
   bcc .checkBaileyRightBoundary    ; unconditional branch

.obstacleMovingBaileyLeft
   sbc obstacleSpeedValue
.checkBaileyRightBoundary
   cmp #XMAX
   bcc .setBaileyPositionForObstacleNudge
   lda #XMIN
.setBaileyPositionForObstacleNudge
   sta baileyHorizPos
.moveNextObstacle
   dex
   bpl .moveObstacles
   ldx #3
.setObstacleColorsAndGraphicPtrs
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep obstacle type value
   tay                              ; move obstacle type to y register
   lda ObstacleColorValues,y
   sta obstacleColors,x             ; set obstacle color value
   tya                              ; move obstacle type to accumulator
   asl                              ; multiply value by 2
   tay
   lda #8
   cpy #ID_KILLER_CLAM << 1
   bne .determineObstacleAnimationIndex; branch if obstacle not KILLER_CLAM
   asl                              ; KILLER_CLAM animated every 16 frames
.determineObstacleAnimationIndex
   and frameCount
   bne .setObstacleGraphicLSBValue
   iny                              ; increment for animation frame
.setObstacleGraphicLSBValue
   lda ObstacleGraphicLSBValues,y
   sta obstacleGraphicLSBValues,x
   cpy #ID_FISH << 1
   bcc .nextObstacleColorAndGraphicPtrs; branch if obstacle doesn't float in sea
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 8
   lsr
   lsr

   IF COMPILE_REGION != PAL50

   and #$1F

   ENDIF

   cmp #16
   bcc .floatObstacleInArticSea
   eor #$1F
.floatObstacleInArticSea
   tay
   lda obstacleGraphicLSBValues,x   ; get obstacle graphic LSB value
   clc
   adc FloatingObstacleOffsetValues,y; increment by offset
   sta obstacleGraphicLSBValues,x   ; set LSB for floating obstacle graphic
.nextObstacleColorAndGraphicPtrs
   dex
   bpl .setObstacleColorsAndGraphicPtrs
   ldx baileyJumpingOffsetIdx       ; get jumping index value
   beq .checkBaileySinkingInSea     ; branch if Bailey not jumping
   jmp ChangeBaileyVerticalPosition

.checkBaileySinkingInSea 
   ldx baileyIceBlockCollisionIdx   ; get Bailey Ice Block collision value
   bpl CheckToChangeIceBlockColor   ; branch if Bailey standing on Ice Block
   lda baileyVertPos                ; get Bailey vertical position
   cmp #YMIN_BAILEY
   bne .setBaileyToSinkingInSea     ; branch if Bailey not standing on shore
   jmp CheckJoystickVerticalMovementValues

.setBaileyToSinkingInSea
   lda #BAILEY_SINKING
   sta currentLevelStatus
   jmp .mainLoop

CheckToChangeIceBlockColor
   bit baileyLandingStatus          ; get Bailey jump landing status value
   bpl CheckToChangeIceBlockDirection; branch if Bailey landed from jump
   lda iceBlockColors,x             ; get color of Ice Blocks
   cmp #COLOR_INIT_ICE_BLOCK
   bne CheckToChangeIceBlockDirection; branch if points recorded for Ice Block
   lda soundValuesChannel_01        ; get sound channel 1 values
   bne .baileyChangedIceBlockColor  ; branch if playing sounds from channel
   lda #1 << 7 | 15
.baileyChangedIceBlockColor
   sta soundValuesChannel_01
   lda #COLOR_CHANGE_ICE_BLOCK
   sta iceBlockColors,x
   lda #16
   sta completedIceBlocksDelay
   lda #0
   sta baileyLandingStatus          ; clear Bailey landing status
   lda currentPointValue            ; get current point value
   jsr IncrementScore               ; increment score for changing Ice Block
   lda buildingIglooIdx             ; get building Igloo index value
   cmp #MAX_IGLOO_INDEX
   beq CheckToChangeIceBlockDirection; branch if done building Igloo
   inc buildingIglooIdx             ; increment Igloo blocks

   IF COMPILE_REGION != PAL50

   jmp CheckForBaileyEatingFish

   ENDIF

CheckToChangeIceBlockDirection
   bit buildingIglooIdx             ; check building Igloo index value
   bmi CheckForBaileyEatingFish     ; branch if no Igloo blocks
   bit obstacleCollisionIndex       ; check obstacle collision index value
   bpl CheckForBaileyEatingFish     ; branch if Bailey collided with obstacle
   bit changeIceBlockDirection      ; check change Ice Block direction value
   bpl CheckForBaileyEatingFish     ; branch if not changing Ice Block direction
   ldx baileyIceBlockCollisionIdx   ; get Bailey Ice Block collision value
   bmi CheckForBaileyEatingFish     ; branch if Bailey not on Ice Block
   lda obstacleAttributes,x         ; get obstacle attribute value
   eor #ICE_BLOCK_DIR_MASK          ; flip Ice Block direction value
   sta obstacleAttributes,x         ; set new Ice Block direction
   lda buildingIglooIdx             ; get building Igloo index value
   cmp #MAX_IGLOO_INDEX
   beq .skipRemoveIglooBlock        ; branch if done building Igloo
   dec buildingIglooIdx             ; decrement Igloo blocks
.skipRemoveIglooBlock
   lda #1 << 7 | 15
   sta soundValuesChannel_01
CheckForBaileyEatingFish
   ldx baileyIceBlockCollisionIdx   ; get Bailey Ice Block collision value
   lda baileyObstacleCollisionIdx
   bmi CheckBaileyRidingIceBlock    ; branch if no obstacle collision this frame
   tax                              ; move Bailey obstacle collision value to x
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep obstacle type value
   cmp #ID_FISH
   bne .determineIceBlockDirectionValue; branch if obstacle not a FISH
   inc numberOfFishEaten            ; increment number of fish eaten
   lda baileyHorizPos               ; get Bailey's horizontal position
   clc
   adc #8                           ; increment horizontal position by 8
   sec
   sbc obstacleHorizPos,x
   jsr Div16                        ; divide value by 16
   tay
   lda obstaclePatternIndex,x       ; get obstacle pattern index value
   and RemovedFishMaskingValues,y   ; remove fish eaten by Bailey
   sta obstaclePatternIndex,x
   jsr DetermineObstacleNUSIZValues
   lda #EAT_FISH_SOUND_VALUE | 27
   sta soundValuesChannel_01
   lda #16
   sta frameDelayValue              ; set to delay action for 16 frames
   bpl CheckBaileyRidingIceBlock    ; unconditional branch

.determineIceBlockDirectionValue
   stx obstacleCollisionIndex
   lda obstacleAttributes,x         ; get obstacle attribute value
   lsr
   and #OBSTACLE_DIR_MASK >> 1      ; keep obstacle direction
   eor #$40                         ; flip direction bit value
   sta tmpNewIceBlockDirection
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #$8F                         ; keep obstacle direction and type values
   ora tmpNewIceBlockDirection      ; combine with new Ice Block direction
   sta obstacleAttributes,x         ; set obstacle attribute value
CheckBaileyRidingIceBlock
   bit obstacleCollisionIndex
   bpl CheckForLevelCompleted       ; branch if Bailey collided with obstacle
   lda baileyHorizPos               ; get Bailey's horizontal position
   sta tmpHorizPosition
   lda iceBlockSpeedValue
   sta tmpSpeedValue
   lda obstacleAttributes,x         ; get obstacle attribute value
   asl                              ; shift Ice Block direction to carry
   asl
   jsr ChangeBaileyPositionOnIceBlock
   cmp #XMIN + 9
   bcs .checkBaileyHorizMax         ; branch if Bailey right of minimum
   lda #XMIN + 9                    ; set to minimum Bailey position
.checkBaileyHorizMax
   cmp #XMAX - 9
   bcc .setBaileyHorizontalPosition ; branch if Bailey left of maximum
   lda #XMAX - 9                    ; set to maximum Bailey position
.setBaileyHorizontalPosition
   sta baileyHorizPos
CheckJoystickVerticalMovementValues
   lda currentJoystickValues        ; get current joystick values
   and #<(MOVE_LEFT & MOVE_RIGHT) >> 4;keep vertical movement values
   cmp #<(MOVE_LEFT & MOVE_RIGHT) >> 4
   beq CheckForLevelCompleted       ; branch if not moving vertically
   lsr                              ; shift MOVE_UP to carry
   bcs .joystickPushedDown          ; branch if not moving up
   lda baileyVertPos                ; get Bailey vertical position
   cmp #YMIN_BAILEY
   bne .baileyJumpingUp             ; branch if Bailey not standing on shore
   lda #XMAX - 33
   sec
   sbc baileyHorizPos
   cmp #8
   bcs CheckForLevelCompleted
   lda buildingIglooIdx             ; get building Igloo index value
   cmp #MAX_IGLOO_INDEX
   bne CheckForLevelCompleted       ; branch if not done building Igloo
   lda #BAILEY_ENTERED_IGLOO
   sta iglooStatus                  ; set to show Bailey entered Igloo
.baileyJumpingUp

   IF COMPILE_REGION = PAL50

   ldx #<[BaileyJumpingUpOffsetValues - BaileyJumpingOffsetValues + 14]

   ELSE

   ldx #<[BaileyJumpingUpOffsetValues - BaileyJumpingOffsetValues + 16]

   ENDIF

   lda #1 << 7 | 15
   sta soundValuesChannel_00
   bne .setInitBaileyJumpingOffsetIndexValue; unconditional branch

.joystickPushedDown
   lda baileyVertPos                ; get Bailey vertical position
   cmp #YMAX_BAILEY
   bcs CheckForLevelCompleted

   IF COMPILE_REGION = PAL50

   ldx #<[BaileyJumpingDownOffsetValues - BaileyJumpingOffsetValues + 13]

   ELSE

   ldx #<[BaileyJumpingDownOffsetValues - BaileyJumpingOffsetValues + 15]

   ENDIF

   lda #1 << 7 | 15
   sta soundValuesChannel_00
.setInitBaileyJumpingOffsetIndexValue
   stx baileyJumpingOffsetIdx
ChangeBaileyVerticalPosition
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs CheckForLevelCompleted       ; branch on odd frame
   dex
   lda BaileyJumpingOffsetValues,x  ; get Bailey jumping offset value
   clc
   adc baileyVertPos                ; increment Bailey vertical position
   sta baileyVertPos                ; set Bailey's new vertical position
   cpx #16
   bne .setBaileyJumpingOffsetIndexValue
   ldx #0
.setBaileyJumpingOffsetIndexValue
   stx baileyJumpingOffsetIdx
   cpx #0
   bne CheckForLevelCompleted
   stx baileyGrizzlyCollisionValue  ; clear Bailey and Grizzly collision value
   dex                              ; x = -1
   stx baileyLandingStatus          ; set landing status to show Bailey landed
CheckForLevelCompleted
   lda baileyVertPos                ; get Bailey vertical position
   cmp #6
   bcs CheckToResetIceBlockColors
   lda #0
   sta baileyVertPos                ; set Bailey position for entering Igloo
   sta iglooStatus                  ; clear Bailey entered Igloo status
   lda #LEVEL_COMPLETE
   sta currentLevelStatus
   sta frameDelayValue              ; set to delay action for 64 frames
CheckToResetIceBlockColors
   lda completedIceBlocksDelay
   bne MoveIceBlocks
   lda buildingIglooIdx             ; get building Igloo index value
   cmp #MAX_IGLOO_INDEX
   beq MoveIceBlocks                ; branch if done building Igloo
   ldx #3
.checkForAllBlocksDone
   lda #COLOR_INIT_ICE_BLOCK
   cmp iceBlockColors,x
   beq MoveIceBlocks                ; branch if found one section WHITE
   dex
   bpl .checkForAllBlocksDone
   ldx #3
.resetIceBlockColors
   sta iceBlockColors,x             ; set Ice Block color to WHITE
   dex
   bpl .resetIceBlockColors
MoveIceBlocks
   ldx #3
.moveIceBlocks
   lda iceBlocksHorizPos,x          ; get Ice Block horizontal position
   sta tmpHorizPosition
   lda iceBlockSpeedValue
   sta tmpSpeedValue
   lda obstacleAttributes,x         ; get obstacle attribute value
   asl                              ; shift Ice Block direction to carry
   asl
   jsr ChangeIceBlockPosition
   sta iceBlocksHorizPos,x          ; set Ice Block horizontal position
   dex
   bpl .moveIceBlocks
   bit obstacleCollisionIndex
   bpl DetermineBaileyAnimationIndexValue; branch if Bailey collided with obstacle
   bit iglooStatus                  ; check Bailey entered Igloo status
   bpl CheckJoystickHorizontalMovementValues; branch if Bailey not entered Igloo
   lda #XMAX - 37
   sta baileyHorizPos
   bne DetermineBaileyAnimationIndexValue; unconditional branch

CheckJoystickHorizontalMovementValues
   lda baileySpeedValue
   ldy baileyJumpingOffsetIdx       ; get jumping index value
   bne .setBaileyHorizSpeedValue    ; branch if Bailey is jumping
   lda frameCount                   ; get current frame count
   and #1
.setBaileyHorizSpeedValue
   sta tmpBaileySpeedValue
   lda currentJoystickValues        ; get current joystick values
   and #<(MOVE_UP & MOVE_DOWN) >> 4 ; keep horizontal values
   sta tmpHorizJoystickValues
   lda #XMIN + 10
   ldy baileyVertPos                ; get Bailey vertical position
   cpy #YMIN_BAILEY
   bne .setBaileyHorizMinValue      ; branch if Bailey not standing on shore
   lda #XMIN + 17
.setBaileyHorizMinValue
   sta tmpBaileyXMIN
   lda baileyHorizPos               ; get Bailey's horizontal position
   lsr tmpHorizJoystickValues       ; shift MOVE_LEFT to carry bit
   lsr tmpHorizJoystickValues
   lsr tmpHorizJoystickValues
   bcs .checkBaileyMoveRight        ; branch if not moving left
   ldy #REFLECT
   cmp tmpBaileyXMIN
   bcc .setBaileyMovementHorizontalPosition
   sbc tmpBaileySpeedValue
   jmp .setBaileyMovementHorizontalPosition

.checkBaileyMoveRight
   lsr tmpHorizJoystickValues       ; shift MOVE_RIGHT to carry bit
   bcs DetermineBaileyAnimationIndexValue; branch if not moving right
   ldy #NO_REFLECT
   cmp #XMAX - 10
   bcs .setBaileyMovementHorizontalPosition
   adc tmpBaileySpeedValue
.setBaileyMovementHorizontalPosition
   sta baileyHorizPos
   sty tmpBaileyReflectState
   lda playerRefectState            ; get player REFLECT state
   and #REFLECT << 1                ; keep Polar Grizzly REFLECT state
   ora tmpBaileyReflectState        ; compine with Bailey REFECT state
   sta playerRefectState            ; set player REFLECT state
DetermineBaileyAnimationIndexValue
   ldx #2                           ; assume Bailey jumping
   lda baileyJumpingOffsetIdx       ; get jumping index value
   and #$0F
   cmp #7
   bcs DeterminePolarGrizzlyMovement; set Bailey graphic index for jumping
   ldx #0
   lda currentJoystickValues        ; get current joystick values
   and #<(MOVE_UP & MOVE_DOWN) >> 4 ; keep horizontal movement values
   cmp #<(MOVE_UP & MOVE_DOWN) >> 4
   beq DeterminePolarGrizzlyMovement; branch if not moving horizontally
   lda frameCount                   ; get current frame count
   and #4
   lsr                              ; divide value by 4
   lsr
   tax                              ; set for Bailey animation index
DeterminePolarGrizzlyMovement
   stx baileyAnimationIdx
   ldx playerRefectState            ; get player REFLECT state
   lda frameCount                   ; get current frame count
   and #$3F
   bne .setPolarGrizzlyReflectState
   jsr ReduceTemperature            ; reduce temperature
   bne .determinePolarGrizzlyReflectState; branch if not reached 0 degrees
   lda #BAILEY_FREEZING
   sta currentLevelStatus           ; set level status to BAILEY_FREEZING
.determinePolarGrizzlyReflectState
   ldx #REFLECT << 1
   lda baileyHorizPos               ; get Bailey's horizontal position
   cmp polarGrizzlyHorizPos         ; compare with Polar Grizzly position
   bcs .setPolarGrizzlyReflectState ; branch if Bailey to the right of Grizzly
   ldx #NO_REFLECT << 1
.setPolarGrizzlyReflectState
   stx tmpPolarGrizzlyReflectState
   lda currentLevel                 ; get the current level
   cmp #POLAR_GRIZZLY_LEVEL
   bcc .mainLoop                    ; branch if Polar Grizzly not active
   lda playerRefectState            ; get player REFLECT state
   and #REFLECT                     ; keep Bailey REFLECT state
   ora tmpBaileyReflectState        ; combine with Polar Grizzly REFLECT state
   sta playerRefectState
   and #REFLECT << 1                ; keep Polar Grizzly REFLECT state
   tax
   lda polarGrizzlyHorizPos         ; get Polar Grizzly horizontal position
   cpx #NO_REFLECT << 1
   bne .checkPolarGrizzlyRightBoundary
   cmp #XMIN + 16
   bcc .mainLoop
   sbc polarGrizzlySpeedValue
   jmp .setPolarGrizzlyHorizontalPosition

.checkPolarGrizzlyRightBoundary
   cmp #XMAX - 20
   bcs .mainLoop
   adc polarGrizzlySpeedValue
.setPolarGrizzlyHorizontalPosition
   sta polarGrizzlyHorizPos
   ldy polarGrizzlyAnimationIdx     ; get Polar Grizzly animation index
   lda polarGrizzlySpeedValue
   beq .mainLoop
   dey
   bpl .setPolarGrizzlyAnimationIndex
   ldy #7
.setPolarGrizzlyAnimationIndex
   sty polarGrizzlyAnimationIdx
.mainLoop
   jmp MainLoop

DetermineGameColors
   bit gameState                    ; check current game state
   bpl .determineDayOrNightColorScheme; branch if not in DEMO_MODE
   lda buildingIglooIdx             ; get building Igloo index value
   sta reservedBuildingIglooIdx
   lda #0
   sta iceBlockFineMotionIndex
   beq .setToNightColorScheme       ; unconditional branch

.determineDayOrNightColorScheme
   lda currentLevel                 ; get the current level
   lsr                              ; divide value by 8
   lsr
   lsr
   lda #COLOR_DAY_SKY
   ldx #WHITE - 4
   ldy #BLACK + 4
   bcc .setLevelColorScheme         ; branch to set to day color scheme
.setToNightColorScheme
   lda #BLUE
   ldx #BLACK + 2
   ldy #WHITE - 2
.setLevelColorScheme
   sta skyColor
   stx landColor
   sty polarGrizzlyColor
   lda buildingIglooIdx             ; get building Igloo index value
   cmp #MAX_IGLOO_INDEX
   bne .setIglooDoorAndGrizzlyColors; branch if not done building Igloo
   ldx #BLACK
   bit gameState                    ; check current game state
   bmi .flashIglooDoor              ; branch if in DEMO_MODE
   lda currentLevel                 ; get the current level
   lsr                              ; divide value by 8
   lsr
   lsr
   bcc .setIglooDoorAndGrizzlyColors
.flashIglooDoor
   lda frameCount                   ; get current frame count
   eor randomSeed
   and #8
   bne .setIglooDoorAndGrizzlyColors
   ldx #COLOR_IGLOO_DOOR_FLASH
.setIglooDoorAndGrizzlyColors 
   stx iglooDoorColor
   ldx landColor
   lda currentLevel                 ; get the current level
   cmp #POLAR_GRIZZLY_LEVEL
   bcs .doneDetermineGameColors
   stx polarGrizzlyColor
.doneDetermineGameColors
   rts

InitializeGameVariables
   ldx #<-1
   stx buildingIglooIdx
   stx reservedBuildingIglooIdx
   ldx #INIT_NUM_LIVES
   stx remainingLives               ; set initial number of lives
   lda gameSelection                ; get current game selection
   lsr                              ; shift D0 to carry
   bcc .setInitialLevelNumber       ; branch if ONE_PLAYER game
   inx                              ; increment number of lives for player 2
   stx reserveRemainingLives        ; set player 2 initial number of lives
.setInitialLevelNumber
   bit gameState                    ; check current game state
   bmi SetInitIceBlockAndObstacleValues; branch if in DEMO_MODE
   asl                              ; multiply game selection by 2
   asl
   sta currentLevel                 ; set initial level
   sta reserveCurrentLevel          ; set player 2 initial level
SetInitIceBlockAndObstacleValues
   ldx #3
.setInitIceBlockAndObstacleValues
   lda #COLOR_INIT_ICE_BLOCK
   sta iceBlockColors,x             ; reset Ice Block colors
   ldy #8
   lda currentLevel                 ; get the current level
   lsr                              ; shift D0 to carry
   lda InitIceBlockAndObstacleHorizPos,x
   and #$F0                         ; keep Ice Block init horizontal position
   bcc .setIceBlockPositionAndObstacleValues; branch if an even level
   ldy #0
.setIceBlockPositionAndObstacleValues
   sta iceBlocksHorizPos,x
   sta obstacleAttributes,x
   sty iceBlockFineMotionIndex
   lda InitIceBlockAndObstacleHorizPos,x; get obstacle init horizontal position
   asl                              ; shift value to upper nybbles
   asl
   asl
   asl
   jsr SetObstacleStartingHorizPos
   dex
   bpl .setInitIceBlockAndObstacleValues
   ldx #<[currentLevelStatus - baileyVertPos]
.setInitValues
   lda #0
   sta AUDV0
   sta AUDV1
   cpx #<[iglooStatus - baileyVertPos]
   bcs .setInitValue
   lda InitValueTable,x
.setInitValue
   sta baileyVertPos,x
   dex
   bpl .setInitValues
   stx obstacleCollisionIndex
   rts

IncrementScore
   sed
   bit gameState                    ; check current game state
   bmi .doneIncrementScore          ; branch if in DEMO_MODE
   clc
   adc playerScore + 2              ; increment tens position
   sta playerScore + 2
   bcc .doneIncrementScore
   lda playerScore + 1              ; get hundreds position
   adc #1 - 1                       ; increment when carry set
   sta playerScore + 1
   lda playerScore                  ; get thousands position
   adc #1 - 1                       ; increment when carry set
   sta playerScore
   lda playerScore + 1              ; get hundreds position
   and #$FF
   beq .incrementRemainingLives
   cmp #$50
   bne .doneIncrementScore          ; branch if not time to increment lives
.incrementRemainingLives
   lda remainingLives               ; get remaining lives
   cmp #MAX_RESERVED_LIVES
   bcs .doneIncrementScore
   inc remainingLives               ; increment remaining lives
.doneIncrementScore
   cld
   rts

ReduceTemperature
   lda temperatureValue             ; get current temperature value
   sed
   sec
   sbc #1
   sta temperatureValue
   cld
   rts

SpawnNewObstacle SUBROUTINE
   lda randomSeed                   ; get random seed value
   and #7
   sta tmpNewObstacleType
.spawnNewObstacle
   lda currentLevel                 ; get the current level
   cmp #7
   bcc .determineNewObstacle
   lda #7
.determineNewObstacle
   cmp tmpNewObstacleType
   bcs .checkToSpawnFish
   dec tmpNewObstacleType
   bpl .spawnNewObstacle            ; unconditional branch
   
.checkToSpawnFish
   lda numberOfFishEaten            ; get number of fish eaten
   cmp #MAX_EATEN_FISH
   bcc .setNewObstacleType          ; branch if max fish not eaten
   lda tmpNewObstacleType           ; get new obstacle type
   and #3                           ; get mod4 value (i.e. only 4 obstacle types)
   cmp #ID_FISH
   bne .setNewObstacleType
   inc tmpNewObstacleType           ; make new obstacle ID_KING_CRAB
.setNewObstacleType
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_DIR_MASK | ICE_BLOCK_DIR_MASK; clear OBSTACLE_TYPE value
   ora tmpNewObstacleType           ; combine with new obstacle type
   sta tmpObstacleAttribute
   lda randomSeed                   ; get random seed value
   and #$80                         ; keep bit for OBSTACLE_DIR_MASK value
   jmp DetermineObstacleStartingHorizPos

   FILL_BOUNDARY 0, 234

BaileyGraphics
BaileyWalkingGraphics_00
   .byte $FF ; |XXXXXXXX|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $5E ; |.X.XXXX.|
   .byte $5E ; |.X.XXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $70 ; |.XXX....|
   .byte $00 ; |........|
BaileyWalkingGraphics_01
   .byte $FF ; |XXXXXXXX|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $4E ; |.X..XXX.|
   .byte $5E ; |.X.XXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $70 ; |.XXX....|
BaileyJumpingGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $14 ; |...X.X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $42 ; |.X....X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $70 ; |.XXX....|
   .byte $00 ; |........|
   .byte $00 ; |........|

BaileyColors
   .byte YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6, COLOR_BAILEY_COAT
   .byte COLOR_BAILEY_COAT, COLOR_BAILEY_COAT, COLOR_BAILEY_COAT
   .byte COLOR_BAILEY_COAT, COLOR_BAILEY_COAT, BRICK_RED + 6, BRICK_RED + 6
   .byte BRICK_RED + 6, RED_ORANGE + 4, RED_ORANGE + 4, RED_ORANGE + 4
   .byte RED_ORANGE + 4, RED_ORANGE + 4, RED_ORANGE + 4
FrozenBaileyColors
   .byte DK_BLUE + 2, DK_BLUE + 2, DK_BLUE + 4, DK_BLUE + 4, DK_BLUE + 6
   .byte DK_BLUE + 6, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8
   .byte DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8
   .byte DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8, DK_BLUE + 8

BaileyDeathAnimation_00
   .byte $7E ; |.XXXXXX.|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $7D ; |.XXXXX.X|
   .byte $75 ; |.XXX.X.X|
   .byte $FF ; |XXXXXXXX|
   .byte $F7 ; |XXXX.XXX|
   .byte $BE ; |X.XXXXX.|
   .byte $BC ; |X.XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BaileyDeathAnimation_01
   .byte $7E ; |.XXXXXX.|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $BE ; |X.XXXXX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $F7 ; |XXXX.XXX|
   .byte $7D ; |.XXXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

BaileyGraphicValues
   .byte <BaileyWalkingGraphics_00
   .byte <BaileyWalkingGraphics_01
   .byte <BaileyJumpingGraphic
   .byte <BaileyJumpingGraphic
   .byte <BaileyDeathAnimation_00
   .byte <BaileyDeathAnimation_01

BaileyColorValues
   .byte <BaileyColors + 1
   .byte <BaileyColors
   .byte <BaileyColors + 1
   .byte <BaileyColors + 1
   .byte <BaileyColors + 1
   .byte <BaileyColors + 1

NorthernLightsColors
   .byte NORTHERN_LIGHTS_COLOR_01, NORTHERN_LIGHTS_COLOR_02
   .byte NORTHERN_LIGHTS_COLOR_03, NORTHERN_LIGHTS_COLOR_04
   .byte NORTHERN_LIGHTS_COLOR_05, NORTHERN_LIGHTS_COLOR_06
   .byte NORTHERN_LIGHTS_COLOR_07, NORTHERN_LIGHTS_COLOR_08
   .byte NORTHERN_LIGHTS_COLOR_09, NORTHERN_LIGHTS_COLOR_10

BaileyJumpingOffsetValues
BaileyJumpingDownOffsetValues

   IF COMPILE_REGION = PAL50

   .byte 8, 7, 6, 5, 3, 2, 0, 0, 0, 0, -1, -2, -2, 0, 0

   ELSE

   .byte 6, 5, 5, 5, 4, 3, 2, 1, 0, 0, 0, 0, -1, -2, -2

   ENDIF

BaileyJumpingUpOffsetValues

   IF COMPILE_REGION = PAL50

   .byte 0, 2, 2, 1, 0, 0, 0, 0, -2, -3, -5, -6, -7, -8, 0, 0

   ELSE

   .byte 3, 2, 2, 1, 0, 0, 0, 0, -1, -2, -3, -4, -5, -5, -5, -6

   ENDIF

RemovedFishMaskingValues
   .byte 3, 5, 6, 3, 3, 1, 5, 4, 6, 6, 4

ChangeBaileyPositionOnIceBlock
ChangeIceBlockPosition
   bcs .iceBlockMovingLeft
   lda tmpHorizPosition             ; get object horizontal position
   adc tmpSpeedValue                ; increment by speed value
   jmp .doneChangePosition

.iceBlockMovingLeft
   lda tmpHorizPosition             ; get object horizontal position
   sbc tmpSpeedValue                ; decrement by speed value
.doneChangePosition
   jsr CheckForIceBlockWrapAround
   rts

   IF COMPILE_REGION != PAL50

   FILL_BOUNDARY 252, 234

   ENDIF

InitObstaclePatternIndexes
   .byte 1, 5, 5, 7

   IF COMPILE_REGION = PAL50

   .byte 7

   ENDIF

ObstacleColorValues
   .byte COLOR_SNOW_GEESE, COLOR_FISH, COLOR_KING_CRAB, COLOR_KILLER_CLAM

InitValueTable
   .byte YMIN_BAILEY
   .byte INIT_TEMPERATURE_VALUE
   .byte INIT_BAILEY_HORIZ_POS
   .byte INIT_DELAY_ACTION_VALUE
   .byte INIT_POLAR_GRIZZLY_HORIZ_POS
   .byte INIT_IGLOO_STATUS

ObstacleGraphicLSBValues
   .byte <SnowGeese_00
   .byte <SnowGeese_01
   .byte <Fish_00
   .byte <Fish_01
   .byte <KingCrab_01
   .byte <KingCrab_00
   .byte <KillerClam_01
   .byte <KillerClam_00

SnowGeese_00
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
SnowGeese_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $36 ; |..XX.XX.|
   .byte $E4 ; |XXX..X..|
KingCrab_00
   .byte $FF ; |XXXXXXXX|
   .byte $EB ; |XXX.X.XX|
   .byte $6A ; |.XX.X.X.|
   .byte $BD ; |X.XXXX.X|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $42 ; |.X....X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
KingCrab_01
   .byte $FF ; |XXXXXXXX|
   .byte $EB ; |XXX.X.XX|
   .byte $6A ; |.XX.X.X.|
   .byte $BD ; |X.XXXX.X|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
KillerClam_01
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $D5 ; |XX.X.X.X|
   .byte $80 ; |X.......|

   IF COMPILE_REGION = PAL50

   .byte $00 ; |........|           there is a gap in the Clam sprite for PAL50

   ELSE

   .byte $80 ; |X.......|

   ENDIF

   .byte $AB ; |X.X.X.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

IglooGraphicRAMIndexValues
   .byte 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 4

KillerClam_00
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $D5 ; |XX.X.X.X|
   .byte $AB ; |X.X.X.XX|
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
Fish_00
   .byte $00 ; |........|
   .byte $9C ; |X..XXX..|
   .byte $CF ; |XX..XXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $7D ; |.XXXXX.X|
   .byte $CE ; |XX..XXX.|
   .byte $9C ; |X..XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Fish_01
   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $DE ; |XX.XXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $DE ; |XX.XXXX.|
   .byte $0C ; |....XX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

PolarGrizzlyGraphics
PolarGrizzlyGraphics_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1B ; |...XX.XX|
   .byte $09 ; |....X..X|
   .byte $3F ; |..XXXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
PolarGrizzlyGraphics_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3F ; |..XXXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
PolarGrizzlyGraphics_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $36 ; |..XX.XX.|
   .byte $12 ; |...X..X.|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|

FloatingObstacleOffsetValues
   .byte 4, 3, 2, 1, 0, 0, 0, 1
   .byte 2, 3, 4, 3, 2, 1, 0, 0

IceBlockFineMotionAdjustmentValues
   .byte HMOVE_L3, HMOVE_L2, HMOVE_L2, HMOVE_R1, HMOVE_L2;, HMOVE_L1, HMOVE_L2
;
; last 2 bytes shared with table below
;
ObstacleNUSIZIndexMaskingValues
PointValueTable
   .byte LEVEL_01_POINTS | 6
   .byte LEVEL_02_POINTS | 4
   .byte LEVEL_03_POINTS | 0
   .byte LEVEL_04_POINTS | 0
   .byte LEVEL_05_POINTS | 0
   .byte LEVEL_06_POINTS | 0
   .byte LEVEL_07_POINTS | 1
   .byte LEVEL_08_POINTS | 3
   .byte LEVEL_09_POINTS | 7
   
IceBlockFineMotionValues
   .byte HMOVE_R8 | HMOVE_L4 >> 4
   .byte HMOVE_R8 | HMOVE_L3 >> 4
   .byte HMOVE_R8 | HMOVE_L2 >> 4
   .byte HMOVE_R8 | HMOVE_L1 >> 4
   .byte HMOVE_R8 | HMOVE_0 >> 4
   .byte HMOVE_R7 | HMOVE_0 >> 4
   .byte HMOVE_R6 | HMOVE_0 >> 4
   .byte HMOVE_R5 | HMOVE_0 >> 4
   .byte HMOVE_R4 | HMOVE_0 >> 4
   .byte HMOVE_R5 | HMOVE_0 >> 4
   .byte HMOVE_R6 | HMOVE_0 >> 4
   .byte HMOVE_R7 | HMOVE_0 >> 4
   .byte HMOVE_R8 | HMOVE_0 >> 4
   .byte HMOVE_R8 | HMOVE_L1 >> 4
   .byte HMOVE_R8 | HMOVE_L2 >> 4
   .byte HMOVE_R8 | HMOVE_L3 >> 4

BaileyDeathAnimation
   ldx #4
   lda frameCount                   ; get current frame count
   and #8
   bne .setBaileyDeathAnimationIndex
   inx
.setBaileyDeathAnimationIndex
   stx baileyAnimationIdx
   ldx #4
   stx frameDelayValue              ; set to delay action for 4 frames
   rts

Div16
ShiftUpperNybblesToLower
   lsr
   lsr
   lsr
Waste14Cycles
   lsr
Waste12Cycles
   rts

SetupFontHeightSixDigitDisplay
   lda #H_FONT - 1            ; 2
   sta tmpSixDigitLoopCount   ; 3
SetupForSixDigitDisplay

   IF COMPILE_REGION = PAL50

   ldx #12                    ; 2
.skip13ScanlinesForPAL50
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2
   bpl .skip13ScanlinesForPAL50;2³

   ELSE

   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2

   ENDIF

   ldx #HMOVE_R1 | MSBL_SIZE8 | THREE_COPIES;2
   stx NUSIZ0                 ; 3 = @16
   stx NUSIZ1                 ; 3 = @19
   ldy #PF_REFLECT            ; 2
   lda #HMOVE_L4              ; 2

   IF COMPILE_REGION = PAL50

   sty CTRLPF                 ; 3 = @22
   sta HMBL                   ; 3 = @25

   ELSE

   SLEEP 2                    ; 2

   ENDIF

   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   sta RESBL                  ; 3 = @34

   IF COMPILE_REGION != PAL50

   sty CTRLPF                 ; 3 = @37
   sta HMBL                   ; 3 = @40

   ENDIF

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

SwapPlayerVariables SUBROUTINE
   lda #1
   eor currentPlayerNumber          ; flip D0
   sta currentPlayerNumber          ; set new current player number
   ldx #5
.swapPlayerVariables
   lda currentPlayerVariables,x
   ldy reservePlayerVariables,x
   sty currentPlayerVariables,x
   sta reservePlayerVariables,x
   dex
   bpl .swapPlayerVariables
   rts

NextRandom
   ldy #2
.nextRandom
   lda randomSeed
   asl
   asl
   asl
   eor randomSeed
   asl
   rol randomSeed
   dey
   bpl .nextRandom
   rts

DetermineObstacleStartingHorizPos
   eor tmpObstacleAttribute         ; flip OBSTACLE_DIR_MASK value
   sta obstacleAttributes,x
   asl                              ; shift OBSTACLE_DIR_MASK to carry
   lda #XMAX + 8
   bcs SetObstacleStartingHorizPos  ; branch if obstacle traveling left
   lda #XMIN - 40
SetObstacleStartingHorizPos
   sta obstacleHorizPos,x           ; set obstacle horizontal position
   lda currentLevel                 ; get the current level
   cmp #POLAR_GRIZZLY_LEVEL
   bne .setInitObstaclePatternIndex
   lda #0
.setInitObstaclePatternIndex
   and #3
   tay
   lda InitObstaclePatternIndexes,y
   sta obstaclePatternIndex,x
DetermineObstacleNUSIZValues
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   ldy #8
   cmp #XMAX - 32
   bcc .setObstacleNUSIZValues
   sbc #XMAX - 32
   jsr Div16
   tay                              ; set index for NUSIZ masking table
.setObstacleNUSIZValues
   lda obstaclePatternIndex,x       ; get obstacle pattern index value
   and ObstacleNUSIZIndexMaskingValues,y
   tay                              ; set index for reading NUSIZ table
   lda ObstacleNUSIZValues,y
   and #OBSTACLE_NUSIZ_MASK
   sta obstacleNUSIZValues,x
   tya
   beq .setObstacleKernelHorizPos
   lda ObstacleHorizOffsetTable,y
   and #OBSTACLE_HORIZ_OFFSET_MASK
   clc
   adc obstacleHorizPos,x
   cmp #XMAX
   bcc .setObstacleKernelHorizPos
   sbc #(XMAX / 2) + 16
.setObstacleKernelHorizPos
   sta kernelObstacleHorizPos,x
   rts

PolarGrizzlyAnimationValues
   .byte <PolarGrizzlyGraphics_00, <PolarGrizzlyGraphics_00
   .byte <PolarGrizzlyGraphics_01, <PolarGrizzlyGraphics_01
   .byte <PolarGrizzlyGraphics_02, <PolarGrizzlyGraphics_02
   .byte <PolarGrizzlyGraphics_01, <PolarGrizzlyGraphics_01

InitIceBlockAndObstacleHorizPos
   .byte 1 << 4 | 10
   .byte 5 << 4 | 12
   .byte 1 << 4 | 11
   .byte 5 << 4 | 13

IglooDoorGraphic
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

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
;
; last 5 bytes shared with table below
;
DegressIndicator
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
       
CheckForIceBlockWrapAround
   cmp #XMIN - 16
   bcc .checkForIceBlockRightWrapAround
   sbc #(XMAX / 2) + 16
.checkForIceBlockRightWrapAround
   cmp #XMAX
   bcc .doneCheckForIceBlockWrapAround
   sbc #XMAX
.doneCheckForIceBlockWrapAround
   rts

CopyrightFonts
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

   IF COMPILE_REGION = NTSC

   .byte RED_ORANGE + 6, RED_ORANGE + 6, RED + 4, BLACK

   ELSE

   .byte BRICK_RED + 6, BRICK_RED + 6, RED + 4, BLACK

   ENDIF

ObstacleNUSIZValues
ObstacleHorizOffsetTable
   .byte 0 << 4 | ONE_COPY, 2 << 4 | ONE_COPY, 1 << 4 | ONE_COPY
   .byte 1 << 4 | TWO_COPIES, 0 << 4 | ONE_COPY, 0 << 4 | TWO_MED_COPIES
   .byte 0 << 4 | TWO_COPIES, 0 << 4 | THREE_COPIES

DetermineFractionalPositioning
   sta tmpMovementSpeedValue
   jsr Div16                        ; divide speed value by 16
   sta objectSpeedValues,x          ; set speed value
   lda tmpMovementSpeedValue
   and #$0F
   clc
   adc fractionalPositionValues,x   ; increment by speed mod 16
   cmp #16
   bcc .setFractionalPositionValues
   inc objectSpeedValues,x          ; increment speed value
.setFractionalPositionValues
   and #$0F
   sta fractionalPositionValues,x
   rts

IglooGraphicValues
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $70 ; |.XXX....|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|

PlayerScoreColorsValues
   .byte COLOR_PLAYER_1_SCORE, COLOR_PLAYER_2_SCORE

   FILL_BOUNDARY 252, 234

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"

   .word Start                      ; RESET vector
   .word Start                      ; BRK vector