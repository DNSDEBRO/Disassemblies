   LIST OFF
; ***  G O P H E R  ***
; Copyright 1982 US Games Corporation
; Designer: Sylvia Day and Henry Will IV
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: February 26, 2021
;
;  ***  97 BYTES OF RAM USED 31 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, US GAMES CORPORATION                         =
; =                                                                            =
; ==============================================================================
;
; - PAL50 version only adjusted frame times to produce 316 scan lines
; - Colors not adjusted for PAL50
; - ROM contains 13 "garbage" or used bytes

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

TRUE                    = 1
FALSE                   = 0

   IFNCONST COMPILE_REGION

COMPILE_REGION         = NTSC       ; change to compile for different regions

   ENDIF

   IF !(COMPILE_REGION = NTSC || COMPILE_REGION = PAL50)

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0, PAL50 = 1"
      echo ""
      err

   ENDIF

   
;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

VSYNC_TIME              = 22

   IF COMPILE_REGION = PAL50

FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 71
OVERSCAN_TIME           = 62

   ELSE
   
FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 40
OVERSCAN_TIME           = 31

   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E
RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
BLUE                    = $80
OLIVE_GREEN             = $B0
GREEN                   = $C0
LT_BROWN                = $E0
BROWN                   = $F0   

COLOR_PLAYER_1_SCORE    = RED_ORANGE + 8
COLOR_PLAYER_2_SCORE    = OLIVE_GREEN + 12

COLOR_FARMER_SHOES      = BRICK_RED + 4
COLOR_FARMER_PANTS      = BLUE + 8
COLOR_FARMER_SHIRT      = GREEN + 6
COLOR_FARMER            = RED + 8
COLOR_FARMER_HAT        = LT_BROWN + 10
COLOR_GOPHER            = BROWN
COLOR_CARROT_TOP        = GREEN + 4
COLOR_GRASS_01          = OLIVE_GREEN + 10
COLOR_GRASS_02          = OLIVE_GREEN + 12
COLOR_GRASS_03          = OLIVE_GREEN + 14
COLOR_GARDEN_DIRT       = RED_ORANGE + 12

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000
;
; Sprite height constants
;
H_FONT                  = 10
H_DUCK                  = 18
H_FARMER                = 50
H_GRASS_KERNEL          = 13
H_CARROT                = 22
H_KERNEL_VERT_ADJUSTMENT = 41
H_UNDERGROUND_GOPHER    = 12
H_GROUND_KERNEL_SECTION = 12
H_RISING_GOPHER         = 36
;
; Frame horizontal constants
;
XMIN                    = 0
XMAX                    = 159

XMIN_GOPHER             = XMIN + 3
XMAX_GOPHER             = XMAX - 11
XMIN_DUCK               = XMIN + 12
XMAX_DUCK               = XMAX - 11
XMIN_FARMER             = XMIN + 20
XMAX_FARMER             = XMAX - 11

HORIZ_POS_HOLE_00       = 15
HORIZ_POS_HOLE_01       = 31
HORIZ_POS_HOLE_02       = 47
HORIZ_POS_HOLE_03       = 111
HORIZ_POS_HOLE_04       = 127
HORIZ_POS_HOLE_05       = 143

HORIZ_POS_CARROT_00     = 63
HORIZ_POS_CARROT_01     = 79
HORIZ_POS_CARROT_02     = 95
;
; Initial horizontal position constants
;
INIT_FARMER_HORIZ_POS   = [XMAX / 2] + 4
INIT_GOPHER_HORIZ_POS   = XMAX_GOPHER - 1
INIT_SEED_VERT_POS      = 8
;
; Game selection constants
;
ACTIVE_PLAYER_MASK      = $F0
GAME_SELECTION_MASK     = $0F

PLAYER_ONE_ACTIVE       = 0 << 4
PLAYER_TWO_ACTIVE       = 15 << 4

MAX_GAME_SELECTION      = 3
;
; Game State values
;
GS_DISPLAY_COPYRIGHT    = 0
GS_DISPLAY_COPYRIGHT_WAIT = 1
GS_DISPLAY_COMPANY      = 2
GS_DISPLAY_COMPANY_WAIT = 3
GS_RESET_PLAYER_VARIABLES = 4
GS_DISPLAY_GAME_SELECTION = 5
GS_PAUSE_GAME_STATE     = 6
GS_CHECK_FARMER_MOVEMENT = 7
GS_GOPHER_STOLE_CARROT  = 8
GS_DUCK_WAIT            = 9
GS_INIT_GAME_FOR_ALTERNATE_PLAYER = 10
GS_ALTERNATE_PLAYERS    = 11
GS_INIT_GAME_FOR_GAME_OVER = 12
GS_DISPLAY_PLAYER_NUMBER = 13
GS_PAUSE_FOR_ACTION_BUTTON = 14
GS_WAIT_FOR_NEW_GAME    = 15
;
; Carrot constants
;
CARROT_COARSE_POSITION_CYCLE_41 = 0
CARROT_COARSE_POSITION_CYCLE_47 = $80
CARROT_COARSE_POSITION_CYCLE_52 = $7F
;
; Duck constants
;
INIT_DUCK_ANIMATION_RATE = 32
DUCK_ANIMATION_DOWN_WING = INIT_DUCK_ANIMATION_RATE - 8
DUCK_ANIMATION_STATIONARY_WING = DUCK_ANIMATION_DOWN_WING - 8
DUCK_ANIMATION_UP_WING  = DUCK_ANIMATION_STATIONARY_WING - 8

DUCK_HORIZ_DIR_MASK     = %10000000
SEED_TARGET_HORIZ_POS_MASK = %01111111
DUCK_TRAVEL_LEFT        = 1 << 7
DUCK_TRAVEL_RIGHT       = 0 << 7
;
; Gopher constants
;
GOPHER_TARGET_MASK        = $0F

GOPHER_HORIZ_DIR_MASK   = %10000000
GOPHER_TUNNEL_TARGET_MASK = %00000111
GOPHER_CARROT_TARGET_MASK = %00001000

GOPHER_TRAVEL_LEFT      = 1 << 7
GOPHER_TRAVEL_RIGHT     = 0 << 7
GOPHER_CARROT_TARGET    = 1 << 3
GOPHER_TARGET_LEFT_TUNNELS = 0 << 2
GOPHER_TARGET_RIGHT_TUNNELS = 1 << 2

VERT_POS_GOPHER_UNDERGROUND = 0
VERT_POS_GOPHER_ABOVE_GROUND = 35
;
; Seed constants
;
INIT_DECAYING_TIMER_VALUE = 120
DISABLE_SEED            = 128
;
; BCD Point values (subtracted by 1 because carry is set for addition)
;
POINTS_FILL_TUNNEL      = $19
POINTS_BONK_GOPHER      = $99
;
; Wait timer constants
;
WAIT_TIME_GAME_START    = 16        ; wait 239 frames ~ 4 seconds
WAIT_TIME_DISPLAY_COPYRIGHT = 128   ; wait 127 frames ~ 2 seconds
WAIT_TIME_CARROT_STOLEN = 136       ; wait 119 frames ~ 2 seconds
;
; Audio Value constants
;
END_AUDIO_TUNE          = 0
AUDIO_DURATION_MASK     = $E0
AUDIO_TONE_MASK         = $1F
;
; Playfield graphic constants
;
PIXEL_BITS_PF0          = 4
PIXEL_BITS_PF1          = 8
PIXEL_BITS_PF2          = 8

LEFT_PF0_PIXEL_OFFSET   = 0
LEFT_PF1_PIXEL_OFFSET   = LEFT_PF0_PIXEL_OFFSET + PIXEL_BITS_PF0
LEFT_PF2_PIXEL_OFFSET   = LEFT_PF1_PIXEL_OFFSET + PIXEL_BITS_PF1
RIGHT_PF0_PIXEL_OFFSET  = LEFT_PF2_PIXEL_OFFSET + PIXEL_BITS_PF2
RIGHT_PF1_PIXEL_OFFSET  = RIGHT_PF0_PIXEL_OFFSET + PIXEL_BITS_PF0
RIGHT_PF2_PIXEL_OFFSET  = RIGHT_PF1_PIXEL_OFFSET + PIXEL_BITS_PF1

;===============================================================================
; M A C R O S
;===============================================================================

   MAC SLEEP_5
      lda ($00),y
   ENDM
   
;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gardenDirtValues        ds 24
;--------------------------------------
_1stGardenDirtValues    = gardenDirtValues
;--------------------------------------
_1stGardenDirtLeftPFValues = _1stGardenDirtValues
;--------------------------------------
_1stGardenDirtLeftPF0   = _1stGardenDirtLeftPFValues
_1stGardenDirtLeftPF1   = _1stGardenDirtLeftPF0 + 1
_1stGardenDirtLeftPF2   = _1stGardenDirtLeftPF1 + 1
_1stGardenDirtRightPFValues = _1stGardenDirtLeftPFValues + 3
;--------------------------------------
_1stGardenDirtRightPF0  = _1stGardenDirtRightPFValues
_1stGardenDirtRightPF1  = _1stGardenDirtRightPF0 + 1
_1stGardenDirtRightPF2  = _1stGardenDirtRightPF1 + 1
;--------------------------------------
_2ndGardenDirtValues    = gardenDirtValues + 6
;--------------------------------------
_2ndGardenDirtLeftPFValues = _2ndGardenDirtValues
;--------------------------------------
_2ndGardenDirtLeftPF0   = _2ndGardenDirtLeftPFValues
_2ndGardenDirtLeftPF1   = _2ndGardenDirtLeftPF0 + 1
_2ndGardenDirtLeftPF2   = _2ndGardenDirtLeftPF1 + 1
_2ndGardenDirtRightPFValues = _2ndGardenDirtLeftPFValues + 3
;--------------------------------------
_2ndGardenDirtRightPF0  = _2ndGardenDirtRightPFValues
_2ndGardenDirtRightPF1  = _2ndGardenDirtRightPF0 + 1
_2ndGardenDirtRightPF2  = _2ndGardenDirtRightPF1 + 1
;--------------------------------------
_3rdGardenDirtValues    = gardenDirtValues + 12
;--------------------------------------
_3rdGardenDirtLeftPFValues = _3rdGardenDirtValues
;--------------------------------------
_3rdGardenDirtLeftPF0   = _3rdGardenDirtLeftPFValues
_3rdGardenDirtLeftPF1   = _3rdGardenDirtLeftPF0 + 1
_3rdGardenDirtLeftPF2   = _3rdGardenDirtLeftPF1 + 1
_3rdGardenDirtRightPFValues = _3rdGardenDirtLeftPFValues + 3
;--------------------------------------
_3rdGardenDirtRightPF0  = _3rdGardenDirtRightPFValues
_3rdGardenDirtRightPF1  = _3rdGardenDirtRightPF0 + 1
_3rdGardenDirtRightPF2  = _3rdGardenDirtRightPF1 + 1
;--------------------------------------
_4thGardenDirtValues    = gardenDirtValues + 18
;--------------------------------------
_4thGardenDirtLeftPFValues = _4thGardenDirtValues
;--------------------------------------
_4thGardenDirtLeftPF0   = _4thGardenDirtLeftPFValues
_4thGardenDirtLeftPF1   = _4thGardenDirtLeftPF0 + 1
_4thGardenDirtLeftPF2   = _4thGardenDirtLeftPF1 + 1
_4thGardenDirtRightPFValues = _4thGardenDirtLeftPFValues + 3
;--------------------------------------
_4thGardenDirtRightPF0  = _4thGardenDirtRightPFValues
_4thGardenDirtRightPF1  = _4thGardenDirtRightPF0 + 1
_4thGardenDirtRightPF2  = _4thGardenDirtRightPF1 + 1
duckGraphicPtrs         ds 4
;--------------------------------------
duckLeftGraphicPtrs     = duckGraphicPtrs
duckRightGraphicPtrs    = duckLeftGraphicPtrs + 2
duckHorizPos            ds 1
farmerGraphicPtrs       ds 2
farmerHorizPos          ds 1
carrotTopGraphicPtrs    ds 2
carrotGraphicsPtrs      ds 2
displayingCarrotAttributes ds 3
;--------------------------------------
carrotCoarsePositionValue = displayingCarrotAttributes
carrotHorizAdjustValue  = carrotCoarsePositionValue + 1
carrotNUSIZValue        = carrotHorizAdjustValue + 1
zone00_GopherGraphicsPtrs ds 2
gopherHorizPos          ds 1
gopherNUSIZValue        ds 1
zone01_GopherGraphicsPtrs ds 2
zone02_GopherGraphicsPtrs ds 2
farmerAnimationIdx      ds 1
playerInformationValues ds 10
;--------------------------------------
currentPlayerInformation = playerInformationValues
;--------------------------------------
currentPlayerScore      = currentPlayerInformation
initGopherChangeDirectionTimer = currentPlayerScore + 3
carrotPattern           = initGopherChangeDirectionTimer + 1
reservedPlayerInformation = currentPlayerInformation + 5
;-------------------------------------
reservedPlayerScore     = reservedPlayerInformation
reservedGopherChangeDirectionTimer = reservedPlayerScore + 3
reservedPlayerCarrotPattern = reservedGopherChangeDirectionTimer + 1
digitGraphicPtrs        ds 12
actionButtonDebounce    ds 1
tmpMulti2               ds 1
;--------------------------------------
tmpMulti8               = tmpMulti2
;--------------------------------------
tmpCurrentPlayerData    = tmpMulti8
;--------------------------------------
tmpEndGraphicPtrIdx     = tmpCurrentPlayerData
;--------------------------------------
tmpDigitGraphicsColorValue = tmpEndGraphicPtrIdx
;--------------------------------------
tmpCharHolder           = tmpDigitGraphicsColorValue
;--------------------------------------
tmpShovelHorizPos       = tmpCharHolder
;--------------------------------------
tmpShovelVertTunnelIndex = tmpShovelHorizPos
;--------------------------------------
tmpGardenDirtIndex      = tmpShovelVertTunnelIndex
tmpSixDigitDisplayLoop  ds 1
;--------------------------------------
tmpDigitPointerMSB      = tmpSixDigitDisplayLoop
;--------------------------------------
tmpGameAudioSavedY      = tmpDigitPointerMSB
random                  ds 2
frameCount              ds 1
gameIdleTimer           ds 1
audioIndexValues        ds 2
;--------------------------------------
leftAudioIndexValue     = audioIndexValues
rightAudioIndexValue    = leftAudioIndexValue + 1
audioDurationValues     ds 2
audioChannelIndex       ds 1
gameState               ds 1
gameSelection           ds 1
selectDebounce          ds 1
;--------------------------------------
gopherHorizAnimationRate = selectDebounce
gopherVertPos           ds 1
gopherReflectState      ds 1
gopherHorizMovementValues ds 1
gopherVertMovementValues ds 1
gopherChangeDirectionTimer ds 1
gopherTauntTimer        ds 1
duckAttributes          ds 1
fallingSeedVertPos      ds 1
fallingSeedScanline     ds 1
duckAnimationRate       ds 1
fallingSeedHorizPos     ds 1
heldSeedDecayingTimer   ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

   .byte "COPYRIGHT 1982 US GAMES CORP."

Start
;
; Set up everything so the power up state is known.
;
   cld                              ; clear decimal mode
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   dex
   bne .clearLoop
   dex
   txs                              ; set stack to the beginning
   jmp Overscan
       
VerticalBlank
   lda #STOP_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
   inc frameCount
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip joystick values
   beq .checkToDisableDisplay       ; branch if joystick not moved
   lda #0
   sta gameIdleTimer                ; reset game idle timer
.checkToDisableDisplay
   lda gameIdleTimer                ; get game idle timer value
   bmi VerticalBlank                ; perform vertical blanking if timer expired
   lda frameCount                   ; get current frame count
   bne .skipGameIdleTimerIncrement
   inc gameIdleTimer                ; increment every 256 frames
.skipGameIdleTimerIncrement
   jsr PlayGameAudioSounds
   jsr NextRandom
   lda carrotPattern                ; get current Carrot pattern
   bne DetermineCarrotAttributeValues;branch if Carrots remaining
   lda #<NullSprite
   sta carrotTopGraphicPtrs
   sta carrotGraphicsPtrs
   lda #>NullSprite
   sta carrotTopGraphicPtrs + 1
   sta carrotGraphicsPtrs + 1
   jmp AnimateDuckWings
       
DetermineCarrotAttributeValues
   asl                              ; multiply Carrot pattern value by 2
   clc
   adc carrotPattern                ; multiply by 3 (i.e. 2x + x)
   tay
   dey
   ldx #3 - 1
.setCarrotAttributeValues
   lda CarrotAttributeValues,y
   sta displayingCarrotAttributes,x
   dey
   dex
   bpl .setCarrotAttributeValues
AnimateDuckWings
   ldx duckAnimationRate            ; get Duck animation rate value
   beq .disableDuck
   dex
   bne .animateDuckWings
   lda #INIT_DUCK_ANIMATION_RATE
   sta duckAnimationRate
   lda #<DuckWingsStationaryGraphics
   sta duckLeftGraphicPtrs
   bne CheckToPlayDuckQuacking      ; unconditional branch
       
.animateDuckWings
   stx duckAnimationRate
   lda #<DuckWingsDownGraphics
   cpx #DUCK_ANIMATION_DOWN_WING
   beq .setDuckWingGraphicPointerLSB
   lda #<DuckWingsStationaryGraphics
   cpx #DUCK_ANIMATION_STATIONARY_WING
   beq .setDuckWingGraphicPointerLSB
   lda #<DuckWingsUpGraphics
   cpx #DUCK_ANIMATION_UP_WING
   bne CheckToPlayDuckQuacking
.setDuckWingGraphicPointerLSB
   sta duckLeftGraphicPtrs
CheckToPlayDuckQuacking
   lda frameCount                   ; get current frame count
   and #$1F
   bne MoveDuckHorizontally   
   ldx #<[DuckQuackingAudioValues - AudioValues]
   jsr SetGameAudioValues
MoveDuckHorizontally
   lda duckAttributes               ; get Duck attribute values
   bmi .moveDuckLeft                ; branch if DUCK_TRAVEL_LEFT
   inc duckHorizPos
   lda duckHorizPos                 ; get Duck horizontal position
   cmp #XMAX_DUCK
   bcc .moveFallingSeed             ; branch if Duck not reached right edge
.disableDuck
   lda #<NullSprite
   sta duckLeftGraphicPtrs
   sta duckRightGraphicPtrs
   lda #>NullSprite
   sta duckLeftGraphicPtrs + 1
   sta duckRightGraphicPtrs + 1
   lda #0
   sta duckAnimationRate
   beq .moveFallingSeed             ; unconditional branch
       
.moveDuckLeft
   dec duckHorizPos
   lda duckHorizPos                 ; get Duck horizontal position
   cmp #XMIN_DUCK
   bcc .disableDuck                 ; branch if Duck reached left edge
.moveFallingSeed
   lda fallingSeedVertPos           ; get seed vertical position
   bmi .doneMoveDuckHorizontally    ; branch if inactive
   lda heldSeedDecayingTimer        ; get seed decaying timer value
   bne .setFarmerHoldingSeed        ; branch if Farmer holding good seed
   lda duckAttributes               ; get Duck attribute values
   and #SEED_TARGET_HORIZ_POS_MASK  ; keep SEED_TARGET_HORIZ_POS value
   cmp fallingSeedHorizPos
   beq .droppingSeed
   ldx duckAttributes               ; get Duck attribute values
   bmi .moveSeedLeftWithDuck        ; branch if DUCK_TRAVEL_LEFT
   inc fallingSeedHorizPos
   inc fallingSeedHorizPos
.moveSeedLeftWithDuck
   dec fallingSeedHorizPos
   jmp .doneMoveDuckHorizontally
       
.droppingSeed
   inc fallingSeedVertPos           ; increment seed vertical position
   lda fallingSeedVertPos           ; get seed vertical position
   cmp #H_DUCK + H_KERNEL_VERT_ADJUSTMENT + H_FARMER - 2
   beq .disableFallingSeed          ; branch if seed reached ground
   cmp #H_DUCK + H_KERNEL_VERT_ADJUSTMENT + 24
   bcc .doneMoveDuckHorizontally
   cmp #H_DUCK + H_KERNEL_VERT_ADJUSTMENT + 28
   bcs .doneMoveDuckHorizontally
   lda farmerHorizPos               ; get Farmer horizontal position
   sec
   sbc fallingSeedHorizPos          ; subtract seed horizontal position
   bpl .checkForFarmerCatchingSeed
   eor #$FF                         ; get distance absolute value
   clc
   adc #1
.checkForFarmerCatchingSeed
   cmp #5
   bcs .doneMoveDuckHorizontally    ; branch if Farmer didn't catch seed
   lda #INIT_DECAYING_TIMER_VALUE
   sta heldSeedDecayingTimer
   bne .doneMoveDuckHorizontally    ; unconditional branch
       
.setFarmerHoldingSeed
   lda farmerHorizPos               ; get Farmer horizontal position
   sta fallingSeedHorizPos          ; set seed horizontal position
   dec heldSeedDecayingTimer        ; decrement seed decaying timer
   bne .doneMoveDuckHorizontally
.disableFallingSeed
   lda #DISABLE_SEED
   sta fallingSeedVertPos
.doneMoveDuckHorizontally
   lda gameState                    ; get current game state
   cmp #GS_CHECK_FARMER_MOVEMENT
   beq CheckForGopherDiggingTunnel
   jmp .doneVerticalBlank
       
CheckForGopherDiggingTunnel
   lda currentPlayerScore           ; get current score 100,000 value
   beq .checkGopherDiggingUndergroundTunnel;branch if score < 100,000
   lda gopherVertMovementValues
   and #$7F
   beq .checkGopherDiggingUndergroundTunnel
   ora #$88
   sta gopherVertMovementValues     ; set to Taunting Gopher vertical value
.checkGopherDiggingUndergroundTunnel
   lda gopherVertPos                ; get Gopher vertical position
   bne .checkGopherDiggingUpwardTunnel;branch if Gopher not crawling underground
   lda gopherHorizPos               ; get Gopher horizontal position
   ldx gopherReflectState           ; get Gopher REFLECT state
   beq .determineGardenDirtIndex    ; branch if Gopher facing left
   clc
   adc #8
   bne .determineGardenDirtIndex    ; unconditional branch

.checkGopherDiggingUpwardTunnel
   cmp #VERT_POS_GOPHER_ABOVE_GROUND
   beq CheckForPlayerMovingShovel   ; branch if Gopher above ground
   lda gopherHorizMovementValues
   and #GOPHER_TUNNEL_TARGET_MASK
   tax
   lda HorizontalTargetValues,x     ; get Gopher targeted horizontal position
.determineGardenDirtIndex
   jsr DetermineDirtFloorIndex
   txa                              ; move dirt floor RAM index to accumulator
   ldx gopherVertPos                ; get Gopher vertical position
   bne .checkGopherDiggingFirstGardenRow;branch if not crawling underground
   clc
   adc #<[_4thGardenDirtValues - gardenDirtValues]
   bne .gopherDigging               ; unconditional branch
       
.checkGopherDiggingFirstGardenRow
   cpx #VERT_POS_GOPHER_UNDERGROUND + 14
   bcs .gopherDigging               ; branch if Gopher in first garden row
   adc #<[_2ndGardenDirtValues - gardenDirtValues]
   cpx #VERT_POS_GOPHER_UNDERGROUND + 7
   bcs .gopherDigging               ; branch if Gopher in second garden row
   adc #<[_3rdGardenDirtValues - _2ndGardenDirtValues]
.gopherDigging
   tax
   lda DirtMaskingBits,y
   and gardenDirtValues,x           ; isolate dirt bit balue
   bne CheckForPlayerMovingShovel   ; branch if dirt value present
   lda gardenDirtValues,x           ; get dirt value
   ora DirtMaskingBits,y            ; set bit for Gopher digging
   sta gardenDirtValues,x
   stx tmpGardenDirtIndex
   ldx #<[DigTunnelAudioValues - AudioValues]
   jsr SetGameAudioValues
   ldx tmpGardenDirtIndex
   lda gopherVertPos                ; get Gopher vertical position
   beq CheckToChangeGopherHorizontalDirection;branch if crawling underground
   iny                              ; increment index for dirt masking
   lda DirtMaskingBits,y
   bmi .setAdjacentValueForGopherDigging
   cmp #1
   bne .gopherTunnelDig
.setAdjacentValueForGopherDigging
   inx
.gopherTunnelDig
   ora gardenDirtValues,x
   sta gardenDirtValues,x
CheckToChangeGopherHorizontalDirection
   lda gopherVertMovementValues
   bmi CheckForPlayerMovingShovel
   dec gopherChangeDirectionTimer   ; decrement Gopher change direction timer
   bne .checkToChangeGopherHorizontalDirection;branch if not expired
   lda gopherVertMovementValues
   ora #$80
   sta gopherVertMovementValues
   lda initGopherChangeDirectionTimer
   sta gopherChangeDirectionTimer
   bne CheckForPlayerMovingShovel   ; unconditional branch

.checkToChangeGopherHorizontalDirection
   lda gopherVertPos                ; get Gopher vertical position
   beq .changeGopherHorizontalDirection;branch if crawling underground
   lda #$80
   sta gopherVertMovementValues
   bne CheckForPlayerMovingShovel   ; unconditional branch
       
.changeGopherHorizontalDirection
   lda gopherHorizMovementValues
   eor #GOPHER_HORIZ_DIR_MASK       ; flip Gopher horizontal direction value
   sta gopherHorizMovementValues
CheckForPlayerMovingShovel
   lda farmerAnimationIdx           ; get Farmer animation index value
   bne .incrementFarmerAnimationIndex
   lda INPT4                        ; read left player action button value
   ldx gameSelection                ; get current game selection
   bpl .checkPlayerActionButtonPressed;branch if PLAYER_ONE_ACTIVE
   lda INPT5                        ; read right player action button value
.checkPlayerActionButtonPressed
   and #$80                         ; keep action button value
   bpl .playerActionButtonPressed   ; branch if action button pressed
   lda #0
   sta actionButtonDebounce         ; clear action button debounce
.doneCheckForPlayerMovingShovel
   jmp .doneVerticalBlank

.playerActionButtonPressed
   lda actionButtonDebounce         ; get action button debounce value
   bne .doneCheckForPlayerMovingShovel;branch if action button held
   lda #$FF
   sta actionButtonDebounce
.incrementFarmerAnimationIndex
   inc farmerAnimationIdx
   lda farmerAnimationIdx           ; get Farmer animation index value
   cmp #2
   bne .checkFarmerThirdAnimation
   lda #<FarmerSprite_01
   sta farmerGraphicPtrs
   bne .doneCheckForPlayerMovingShovel;unconditional branch
       
.checkFarmerThirdAnimation
   cmp #4
   bne .checkFarmerFirstAnimation
   lda #<FarmerSprite_02
   sta farmerGraphicPtrs
   bne .doneCheckForPlayerMovingShovel;unconditional branch
       
.checkFarmerFirstAnimation
   cmp #8
   bne .doneCheckForPlayerMovingShovel
   lda #0
   sta farmerAnimationIdx           ; reset Farmer animation index
   lda #<FarmerSprite_00
   sta farmerGraphicPtrs
   lda farmerHorizPos               ; get Farmer horizontal position
   sec
   sbc #4
   sta tmpShovelHorizPos
   ldx #10
.determinePlantingCarrotPosition
   lda tmpShovelHorizPos
   sec
   sbc HorizontalTargetValues,x
   bpl .checkShovelHorizPlantingRange
   eor #$FF                         ; get distance absolute value
   clc
   adc #1
.checkShovelHorizPlantingRange
   cmp #6
   bcc .checkToPlantCarrot
   dex
   bpl .determinePlantingCarrotPosition
   jmp .doneVerticalBlank           ; branch if not planing Carrot
       
.checkToPlantCarrot
   cpx #8
   bcc DetermineToFillTunnel
   lda heldSeedDecayingTimer        ; get seed decaying timer value
   beq .doneVerticalBlank           ; branch if Farmer not holding seed
   lda #1 << 2
   cpx #10
   beq .plantCarrot
   lsr                              ; shift Carrot bit right
   cpx #9
   beq .plantCarrot
   lsr                              ; shift Carrot bit right
.plantCarrot
   ora carrotPattern                ; combine with Carrot pattern
   sta carrotPattern                ; set Carrot pattern
   lda #DISABLE_SEED
   sta fallingSeedVertPos           ; disable falling seed
   lda #0
   sta heldSeedDecayingTimer
   beq .doneVerticalBlank           ; unconditional branch

DetermineToFillTunnel
   stx tmpShovelVertTunnelIndex     ; save shovel tunnel index value
   lda gopherVertPos                ; get Gopher vertical position
   beq .determineToFillTunnel       ; branch if crawling underground
   lda gopherHorizMovementValues
   and #GOPHER_CARROT_TARGET_MASK | GOPHER_TUNNEL_TARGET_MASK
   tax
   lda HorizontalTargetValues,x     ; get Gopher targeted horizontal position
   ldx tmpShovelVertTunnelIndex     ; restore shovel tunnel index value
   cmp HorizontalTargetValues,x     ; compare with shovel hole position
   beq .doneVerticalBlank
.determineToFillTunnel
   lda HorizontalTargetValues,x     ; get shovel hole position
   jsr DetermineDirtFloorIndex
.determineTunnelFillIndexValue
   lda gardenDirtValues,x           ; get garden dirt value
   and DirtMaskingBits,y            ; isolate dirt bit
   beq .foundTunnelFillIndexValue   ; branch if tunnel not present
   txa                              ; move dirt floor RAM index to accumulator
   clc
   adc #6
   tax
   cmp #<[duckGraphicPtrs - gardenDirtValues]
   bcc .determineTunnelFillIndexValue
.foundTunnelFillIndexValue
   txa                              ; move dirt floor RAM index to accumulator
   sec
   sbc #6
   bmi .doneVerticalBlank
   tax                              ; move dirt floor RAM index to x register
   jsr FillInTunnel
   cpx #<[_4thGardenDirtValues - gardenDirtValues]
   bcc .checkToFillAdjacentValue    ; branch if not filling bottom dirt row
   dey                              ; decrement for left PF bit
   jsr FillInTunnel                 ; fill left PF bit
   iny
.checkToFillAdjacentValue
   lda DirtMaskingBits,y
   bmi .setAdjacentValueForFillingDirt
   cmp #1
   bne .fillInHole
.setAdjacentValueForFillingDirt
   inx
.fillInHole
   iny
   jsr FillInTunnel
   cpx #<[_4thGardenDirtValues - gardenDirtValues]
   bcc .incrementScoreForTunnelFill ; branch if not filling bottom dirt row
   iny
   jsr FillInTunnel
.incrementScoreForTunnelFill
   ldx #<[FillTunnelAudioValues - AudioValues]
   jsr SetGameAudioValues
   lda #POINTS_FILL_TUNNEL
   jsr IncrementScore
.doneVerticalBlank
   lda gameState                    ; get current game state
   cmp #GS_PAUSE_GAME_STATE
   bcc .checkForResetButtonPressed
   cmp #GS_WAIT_FOR_NEW_GAME
   beq ConvertBCDToDigits
   cmp #GS_ALTERNATE_PLAYERS
   bcs .checkForResetButtonPressed
ConvertBCDToDigits
   ldx #2
   ldy #8
.convertBCDToDigits
   lda currentPlayerScore,x         ; get current player score
   and #$0F                         ; keep lower nybbles
   asl                              ; multiply value by 2
   sta tmpMulti2
   asl                              ; multiply value by 8
   asl
   adc tmpMulti2                    ; multiply value by 10 (i.e. 2x + 8x)
   sta digitGraphicPtrs + 2,y       ; set digit LSB value
   lda currentPlayerScore,x         ; get current player score
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpMulti8
   lsr                              ; divide value by 8 (i.e. multiply by 2)
   lsr
   adc tmpMulti8                    ; multiply by 10 (i.e. 2x + 8x)
   sta digitGraphicPtrs,y           ; set digit LSB value
   dey
   dey
   dey
   dey
   dex
   bpl .convertBCDToDigits
   lda #>Blank
   ldx #0
.suppressZeros
   ldy digitGraphicPtrs,x           ; get digit LSB value
   beq .setDigitPointerMSBValue     ; branch if 0
   lda #>NumberFonts
.setDigitPointerMSBValue
   sta digitGraphicPtrs + 1,x       ; set digit MSB value
   inx
   inx
   cpx #10
   bne .suppressZeros
   lda #>NumberFonts
   sta digitGraphicPtrs + 11
.checkForResetButtonPressed
   lda SWCHB                        ; read console switches
   and #RESET_MASK
   bne DisplayKernel                ; branch if RESET not pressed
   lda gameSelection                ; get current game selection
   and #GAME_SELECTION_MASK         ; keep game selection value
   sta gameSelection
   lda #GS_RESET_PLAYER_VARIABLES
   sta gameState
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   lda #ENABLE_TIA
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @08
   lda fallingSeedVertPos     ; 3         get seed vertical position
   sta fallingSeedScanline    ; 3
   ldx #3                     ; 2
.kernelWait
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .kernelWait            ; 2³
   lda #COLOR_PLAYER_1_SCORE  ; 2
   ldx gameSelection          ; 3         get current game selection
   bpl .sixDigitDisplayKernel ; 2³        branch if PLAYER_ONE_ACTIVE
   lda #COLOR_PLAYER_2_SCORE  ; 2
.sixDigitDisplayKernel
   ldx #0                     ; 2
   ldy #H_FONT - 1            ; 2
   sta tmpDigitGraphicsColorValue;3
   jsr SixDigitDisplayKernel  ; 6
;--------------------------------------
   lda #0                     ; 2 = @01
   sta VDELP0                 ; 3 = @04
   sta VDELP1                 ; 3 = @07
   sta WSYNC
;--------------------------------------
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @05
   sta NUSIZ1                 ; 3 = @08
   ldx #MSBL_SIZE1 | PF_PRIORITY | PF_NO_REFLECT;2
   stx CTRLPF                 ; 3 = @13
   lda fallingSeedHorizPos    ; 3         get falling seed horizontal position
   jsr PositionObjectHorizontally;6       horizontally position BALL (i.e. x = 4)
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   lda duckAttributes         ; 3         get Duck attribute values
   bmi .displayTravelLeftDuck ; 2³        branch if DUCK_TRAVEL_LEFT
   ldx #<[RESP1 - RESP0]      ; 2
   lda duckHorizPos           ; 3         get Duck horizontal position
   jsr PositionObjectHorizontally;6
   ldx #<[RESP0 - RESP0]      ; 2
   lda duckHorizPos           ; 3         get Duck horizontal position
   sec                        ; 2
   sbc #8                     ; 2
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jmp DrawDuckKernel         ; 3
       
.displayTravelLeftDuck 
   lda #REFLECT               ; 2
   sta REFP0                  ; 3 = @14
   sta REFP1                  ; 3 = @17
   ldx #<[RESP0 - RESP0]      ; 2
   lda duckHorizPos           ; 3         get Duck horizontal position
   jsr PositionObjectHorizontally;6
   ldx #<[RESP1 - RESP0]      ; 2
   lda duckHorizPos           ; 3         get Duck horizontal position
   sec                        ; 2
   sbc #8                     ; 2
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
DrawDuckKernel
   ldy #H_DUCK                ; 2
.drawDuckKernel
   lda (duckLeftGraphicPtrs),y; 5
   ldx DuckRightColorValues - 1,y;4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda DuckLeftColorValues - 1,y;4
   sta COLUP0                 ; 3 = @10
   lda (duckRightGraphicPtrs),y;5
   sta GRP1                   ; 3 = @18
   stx COLUP1                 ; 3 = @21
   lda #DISABLE_BM            ; 2
   dec fallingSeedScanline    ; 5
   bne .duckKernelDrawSeed    ; 2³
   lda #$FF                   ; 2         set to ENABLE_BM (i.e. D1 = 1)
.duckKernelDrawSeed
   sta ENABL                  ; 3 = @35
   dey                        ; 2
   bne .drawDuckKernel        ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta REFP0                  ; 3 = @11
   lda #REFLECT               ; 2
   sta REFP1                  ; 3 = @16
   ldx #<[RESP1 - RESP0]      ; 2
   lda farmerHorizPos         ; 3         get Farmer horizontal position
   jsr PositionObjectHorizontally;6
   ldx #<[RESP0 - RESP0]      ; 2
   lda farmerHorizPos         ; 3         get Farmer horizontal position
   sec                        ; 2
   sbc #7                     ; 2
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx #H_KERNEL_VERT_ADJUSTMENT;2
.verticalAdjustmentForFarmerKernel
   sta WSYNC
;--------------------------------------
   lda #DISABLE_BM            ; 2
   dec fallingSeedScanline    ; 5
   bne .vertAdjustmentDrawSeed; 2³
   lda #$FF                   ; 2         set to ENABLE_BM (i.e. D1 = 1)
.vertAdjustmentDrawSeed
   sta ENABL                  ; 3 = @14
   dex                        ; 2
   bne .verticalAdjustmentForFarmerKernel;2³
   ldy #H_FARMER              ; 2
.drawFarmerKernel
   lda (farmerGraphicPtrs),y  ; 5
   ldx FarmerColorValues - 1,y; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   stx COLUP0                 ; 3 = @06
   lda (farmerGraphicPtrs),y  ; 5
   sta GRP1                   ; 3 = @14
   stx COLUP1                 ; 3 = @17
   lda #DISABLE_BM            ; 2
   dec fallingSeedScanline    ; 5
   bne .farmerKernelDrawSeed  ; 2³
   lda #$FF                   ; 2         set to ENABLE_BM (i.e. D1 = 1)
.farmerKernelDrawSeed
   sta ENABL                  ; 3 = @31
   dey                        ; 2
   bne .drawFarmerKernel      ; 2³
   sty ENABL                  ; 3 = @38
   sty CTRLPF                 ; 3 = @41   set to PF_NO_REFLECT
   sta WSYNC
;--------------------------------------
   lda #COLOR_GRASS_01        ; 2
   sta COLUBK                 ; 3 = @05
   sty GRP0                   ; 3 = @08
   sty GRP1                   ; 3 = @11
   sty REFP1                  ; 3 = @14
   sty NUSIZ0                 ; 3 = @17
   lda carrotNUSIZValue       ; 3
   sta NUSIZ1                 ; 3 = @23
   lda #COLOR_GOPHER          ; 2
   sta COLUP0                 ; 3 = @28
   ldx carrotHorizAdjustValue ; 3
   lda carrotCoarsePositionValue;3
   bmi .positionCarrotToCycle47;2³
   bne .positionCarrotToCycle52;2³
   stx RESP1                  ; 3 = @41
   stx HMP1                   ; 3 = @44
   jmp PositionGopherHorizontally;3
       
.positionCarrotToCycle47
   SLEEP 2                    ; 2
   SLEEP_5                    ; 5
   stx RESP1                  ; 3 = @47
   stx HMP1                   ; 3 = @50
   jmp PositionGopherHorizontally;3
       
.positionCarrotToCycle52
   SLEEP_5                    ; 5
   SLEEP_5                    ; 5
   stx RESP1                  ; 3 = @52
   stx HMP1                   ; 3 = @55
PositionGopherHorizontally
   lda gopherHorizPos         ; 3         get Gopher horizontal position
   sec                        ; 2
   sta WSYNC
;--------------------------------------
.coarsePositionGopher
   sbc #15                    ; 2         divide position by 15
   bcs .coarsePositionGopher  ; 2³
   eor #15                    ; 2         4-bit 1's complement for fine motion
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   adc #(8 + 1) << 4          ; 2         increment by 8 for full range
   sta HMP0                   ; 3
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #COLOR_CARROT_TOP      ; 2
   sta COLUP1                 ; 3 = @08
   lda gopherReflectState     ; 3
   sta REFP0                  ; 3 = @14
   ldy #H_GRASS_KERNEL - 1    ; 2
   lda (zone00_GopherGraphicsPtrs),y;5
   ldx GrassColorValues,y     ; 4
   jmp .jmpIntoGrassKernel    ; 3
       
.drawGrassKernel
   lda (zone00_GopherGraphicsPtrs),y;5
   ldx GrassColorValues,y     ; 4
   sta WSYNC
;--------------------------------------
.jmpIntoGrassKernel
   stx COLUBK                 ; 3 = @03
   sta GRP0                   ; 3 = @06
   lda (carrotTopGraphicPtrs),y;5
   sta GRP1                   ; 3
   lda gopherNUSIZValue       ; 3         get Gopher NUSIZ value
   sta NUSIZ0                 ; 3 = @20
   dey                        ; 2
   bpl .drawGrassKernel       ; 2³
   ldy #H_CARROT - 1          ; 2
   lda #RED_ORANGE + 4        ; 2
   sta COLUP1                 ; 3 = @31
.drawFirstGardenDirtKernel
   lda (zone01_GopherGraphicsPtrs),y;5
   ldx #BROWN + 8             ; 2
   sta WSYNC
;--------------------------------------
   stx COLUBK                 ; 3 = @03
   ldx _1stGardenDirtLeftPF0  ; 3
   stx PF0                    ; 3 = @09
   sta GRP0                   ; 3 = @12
   lda (carrotGraphicsPtrs),y ; 5
   ldx _1stGardenDirtLeftPF1  ; 3
   sta GRP1                   ; 3 = @23
   stx PF1                    ; 3 = @26
   ldx _1stGardenDirtLeftPF2  ; 3
   stx PF2                    ; 3 = @32
   ldx _1stGardenDirtRightPF0 ; 3
   lda CarrotColorValues,y    ; 4
   sta COLUP1                 ; 3 = @42
   stx PF0                    ; 3 = @45
   ldx _1stGardenDirtRightPF1 ; 3
   stx PF1                    ; 3 = @51
   ldx _1stGardenDirtRightPF2 ; 3
   stx PF2                    ; 3 = @57
   dey                        ; 2
   cpy #H_CARROT - 8          ; 2
   bcs .drawFirstGardenDirtKernel;2³
.drawSecondGardenDirtKernel
   lda (zone01_GopherGraphicsPtrs),y;5
   sta WSYNC
;--------------------------------------
   ldx _2ndGardenDirtLeftPF0  ; 3
   ldx _2ndGardenDirtLeftPF0  ; 3
   stx PF0                    ; 3 = @09
   sta GRP0                   ; 3 = @12
   lda (carrotGraphicsPtrs),y ; 5
   ldx _2ndGardenDirtLeftPF1  ; 3
   sta GRP1                   ; 3 = @23
   stx PF1                    ; 3 = @26
   ldx _2ndGardenDirtLeftPF2  ; 3
   stx PF2                    ; 3 = @32
   ldx _2ndGardenDirtRightPF0 ; 3
   lda CarrotColorValues,y    ; 4
   sta COLUP1                 ; 3 = @42
   stx PF0                    ; 3 = @45
   ldx _2ndGardenDirtRightPF1 ; 3
   stx PF1                    ; 3 = @51
   ldx _2ndGardenDirtRightPF2 ; 3
   stx PF2                    ; 3 = @57
   dey                        ; 2
   cpy #H_CARROT - 15         ; 2
   bcs .drawSecondGardenDirtKernel;2³
.drawThirdGardenDirtKernel
   lda (zone01_GopherGraphicsPtrs),y;5
   sta WSYNC
;--------------------------------------
   ldx _3rdGardenDirtLeftPF0  ; 3
   ldx _3rdGardenDirtLeftPF0  ; 3
   stx PF0                    ; 3 = @09
   sta GRP0                   ; 3 = @12
   lda (carrotGraphicsPtrs),y ; 5
   ldx _3rdGardenDirtLeftPF1  ; 3
   sta GRP1                   ; 3 = @23
   stx PF1                    ; 3 = @26
   ldx _3rdGardenDirtLeftPF2  ; 3
   stx PF2                    ; 3 = @32
   ldx _3rdGardenDirtRightPF0 ; 3
   lda CarrotColorValues,y    ; 4
   sta COLUP1                 ; 3 = @42
   stx PF0                    ; 3 = @45
   ldx _3rdGardenDirtRightPF1 ; 3
   stx PF1                    ; 3 = @51
   ldx _3rdGardenDirtRightPF2 ; 3
   stx PF2                    ; 3 = @57
   dey                        ; 2
   bpl .drawThirdGardenDirtKernel;2³
   ldy #H_UNDERGROUND_GOPHER - 1;2
.drawFourthGardenDirtKernel
   sta WSYNC
;--------------------------------------
   lda (zone02_GopherGraphicsPtrs),y;5
   sta GRP0                   ; 3 = @08
   ldx _4thGardenDirtLeftPF0  ; 3
   stx PF0                    ; 3 = @14
   lda #0                     ; 2
   sta GRP1                   ; 3 = @19
   ldx _4thGardenDirtLeftPF1  ; 3
   stx PF1                    ; 3 = @25
   ldx _4thGardenDirtLeftPF2  ; 3
   stx PF2                    ; 3 = @31
   lda gopherNUSIZValue       ; 3         get Gopher NUSIZ value
   ldx _4thGardenDirtRightPF0 ; 3
   stx PF0                    ; 3 = @40
   sta NUSIZ0                 ; 3 = @43
   ldx _4thGardenDirtRightPF1 ; 3
   SLEEP 2                    ; 2
   stx PF1                    ; 3 = @51
   ldx _4thGardenDirtRightPF2 ; 3
   stx PF2                    ; 3 = @57
   dey                        ; 2
   bpl .drawFourthGardenDirtKernel;2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta REFP0                  ; 3 = @08
   sta PF0                    ; 3 = @11
   sta PF1                    ; 3 = @14
   sta PF2                    ; 3 = @17
   ldx #6                     ; 2
.endKernelWait
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .endKernelWait         ; 2³
   stx COLUBK                 ; 3 = @07
Overscan
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan
   lda gameState                    ; get current game state
   asl                              ; multiply by 2
   tay
   lda GameStateRoutineTable + 1,y
   pha                              ; push game state routine LSB to stack
   lda GameStateRoutineTable,y
   pha                              ; push game state routine MSB to stack
   rts                              ; jump to game state routine

GameStateRoutineTable
   .word DisplayCopyrightInformation - 1
   .word AdvanceGameStateAfterFrameCountExpire - 1
   .word DisplayCompanyInformation - 1
   .word AdvanceGameStateAfterFrameCountExpire - 1
   .word ResetPlayerVariables - 1
   .word DisplayGameSelection - 1
   .word AdvanceGameStateAfterFrameCountExpire - 1
   .word CheckToMoveFarmerHorizontally - 1
   .word CarrotStolenByGopher - 1
   .word WaitForDuckToAdvanceGameState - 1
   .word InitGameRoundData - 1
   .word CheckToAlternatePlayers - 1
   .word InitGameRoundData - 1
   .word DisplayPlayerNumberInformation - 1
   .word WaitForActionButtonToStartRound - 1
   .word WaitToStartNewGame - 1

DisplayCopyrightInformation
   lda #12
   sta tmpEndGraphicPtrIdx
   lda #>CopyrightLiteralSprites
   sta tmpDigitPointerMSB
   ldy #<CopyrightLiteralSprites
   jsr SetDigitGraphicPointers
   lda #WAIT_TIME_DISPLAY_COPYRIGHT
   sta frameCount
ResetPlayerVariables
   lda #0
   ldx #9
.initPlayerInformationValues
   sta playerInformationValues,x
   dex
   bpl .initPlayerInformationValues
   lda #7
   sta carrotPattern
   sta reservedPlayerCarrotPattern
   lda #15
   sta initGopherChangeDirectionTimer
   sta reservedGopherChangeDirectionTimer
InitGameRoundData
   lda #<NullSprite
   sta duckLeftGraphicPtrs
   sta duckRightGraphicPtrs
   lda #>NullSprite
   sta duckLeftGraphicPtrs + 1
   sta duckRightGraphicPtrs + 1
   lda #DISABLE_SEED
   sta fallingSeedVertPos
   lda #<FarmerSprite_00
   sta farmerGraphicPtrs
   lda #>FarmerSprite_00
   sta farmerGraphicPtrs + 1
   lda #<CarrotTopGraphics
   sta carrotTopGraphicPtrs
   lda #>CarrotTopGraphics
   sta carrotTopGraphicPtrs + 1
   lda #<CarrotGraphics
   sta carrotGraphicsPtrs
   lda #>CarrotGraphics
   sta carrotGraphicsPtrs + 1
   lda #<NullRunningGopher
   sta zone00_GopherGraphicsPtrs
   lda #>NullRunningGopher
   sta zone00_GopherGraphicsPtrs + 1
   lda #<NullSprite
   sta zone01_GopherGraphicsPtrs
   lda #>NullSprite
   sta zone01_GopherGraphicsPtrs + 1
   lda #<RunningGopher_00
   sta zone02_GopherGraphicsPtrs
   lda #>RunningGopher_00
   sta zone02_GopherGraphicsPtrs + 1
   lda #MSBL_SIZE1 | DOUBLE_SIZE
   sta gopherNUSIZValue
   lda #INIT_FARMER_HORIZ_POS
   sta farmerHorizPos
   lda #COLOR_GARDEN_DIRT
   sta COLUPF
   lda #INIT_GOPHER_HORIZ_POS
   sta gopherHorizPos
   sta duckHorizPos
   lda initGopherChangeDirectionTimer
   sta gopherChangeDirectionTimer
   lda #0
   sta gopherVertPos
   sta gopherReflectState
   sta heldSeedDecayingTimer
   sta duckAnimationRate
   ldx #23
.initGardenDirtValues
   sta gardenDirtValues,x
   dex
   bpl .initGardenDirtValues
   sta gopherTauntTimer
   lda #$F0
   sta _4thGardenDirtRightPF2
   sta _4thGardenDirtLeftPF0
   lda random
   and #$7F
   sta gopherVertMovementValues
   lda random + 1
   and #GOPHER_HORIZ_DIR_MASK | GOPHER_TUNNEL_TARGET_MASK
   sta gopherHorizMovementValues
   jmp AdvanceCurrentGameState
       
DisplayCompanyInformation
   lda #12
   sta tmpEndGraphicPtrIdx
   lda #>USGamesLiteral
   sta tmpDigitPointerMSB
   ldy #<USGamesLiteral
   jsr SetDigitGraphicPointers
   jmp ResetPlayerVariables
       
WaitForDuckToAdvanceGameState
   lda duckAnimationRate
   bne .doneAdvanceGameStateAfterFrameCountExpire       
AdvanceGameStateAfterFrameCountExpire
   lda frameCount                   ; get current frame count
   cmp #255
   bne .doneAdvanceGameStateAfterFrameCountExpire;branch if time not expired
   jmp AdvanceCurrentGameState
       
.doneAdvanceGameStateAfterFrameCountExpire
   jmp NewFrame

DisplayGameSelection
   lda #8
   sta tmpEndGraphicPtrIdx
   lda #>GameSelectionLiteralSprites
   sta tmpDigitPointerMSB
   ldy #<GameSelectionLiteralSprites
   jsr SetDigitGraphicPointers
   lda #<Blank
   sta digitGraphicPtrs,x
   lda #>Blank
   sta digitGraphicPtrs + 1,x
   lda gameSelection                ; get current game selection
   and #GAME_SELECTION_MASK         ; keep game selection value
   asl                              ; multiply value by 2
   sta tmpMulti2
   asl                              ; multiply value by 8
   asl
   clc
   adc tmpMulti2
   clc
   adc #10
   sta digitGraphicPtrs + 10
   lda #>NumberFonts
   sta digitGraphicPtrs + 11
   lda SWCHB                        ; read console switches
   and #SELECT_MASK
   bne .selectButtonNotPressed      ; branch if SELECT not pressed
   lda selectDebounce               ; get select debounce value
   bne .doneDisplayGameSelection    ; branch if SELECT button held
   inc gameSelection                ; increment current game selection
   lda gameSelection                ; get current game selection
   and #GAME_SELECTION_MASK         ; keep game selection value
   cmp #MAX_GAME_SELECTION + 1
   bcc .setSelectButtonPressed      ; branch if not reached maximum
   lda #0
   sta gameSelection                ; reset game selection value
.setSelectButtonPressed
   lda #$FF
   sta selectDebounce
.doneDisplayGameSelection
   jmp NewFrame

.selectButtonNotPressed
   lda #0
   sta selectDebounce               ; clear select debounce value
   lda INPT4                        ; read left player action button
   bmi .doneDisplayGameSelection    ; branch if action button not pressed
   ldx #<[StartingThemeAudioValues_00 - AudioValues]
   jsr SetGameAudioValues
   ldx #<[StartingThemeAudioValues_01 - AudioValues]
   jsr SetGameAudioValues
   lda #WAIT_TIME_GAME_START
   sta frameCount
   jmp AdvanceCurrentGameState
       
DisplayPlayerNumberInformation
   lda gameSelection                ; get current game selection
   and #1
   beq .doneDisplayPlayerNumberInformation;branch if ONE_PLAYER_GAME
   lda #10
   sta tmpEndGraphicPtrIdx
   lda #>PlayerNumberLiteralSprites
   sta tmpDigitPointerMSB
   ldy #<PlayerNumberLiteralSprites
   jsr SetDigitGraphicPointers
   lda gameSelection                ; get current game selection
   and #ACTIVE_PLAYER_MASK          ; keep ACTIVE_PLAYER
   tax
   lda #<[one - NumberFonts]
   cpx #PLAYER_TWO_ACTIVE
   bne .setPlayerDigitLSBValue
   clc
   adc #H_FONT
.setPlayerDigitLSBValue
   sta digitGraphicPtrs + 10
   lda #>NumberFonts
   sta digitGraphicPtrs + 11
.doneDisplayPlayerNumberInformation
   jmp AdvanceCurrentGameState

CheckToMoveFarmerHorizontally
   lda SWCHA                        ; read joystick values
   ldx gameSelection                ; get current game selection
   bpl .checkJoystickHorizontalMovement;branch if PLAYER_ONE_ACTIVE
   asl                              ; shift player 2 joystck values
   asl
   asl
   asl
.checkJoystickHorizontalMovement
   tax                              ; move joystick values to x register
   and #<~(MOVE_RIGHT & MOVE_LEFT)  ; keep horizontal motion values
   cmp #<~(MOVE_RIGHT & MOVE_LEFT)
   beq CheckToMoveGopher            ; branch if not moving horizontally
   txa                              ; move joystick values to accumulator
   and #<~MOVE_RIGHT
   bne .moveFarmerLeft              ; branch if not MOVE_RIGHT
   lda farmerHorizPos               ; get Farmer horizontal position
   cmp #XMAX_FARMER
   bcs CheckToMoveGopher            ; branch if Farmer reached right side
   inc farmerHorizPos               ; increment Farmer horizontal position
   bne CheckToMoveGopher            ; unconditional branch
   
.moveFarmerLeft
   lda farmerHorizPos               ; get Farmer horizontal position
   cmp #XMIN_FARMER
   bcc CheckToMoveGopher            ; branch if Farmer reached left side
   dec farmerHorizPos               ; decrement Farmer horizontal position
   bne CheckToMoveGopher            ; not needed...could have fallen through
CheckToMoveGopher
   lda gopherTauntTimer             ; get Gopher taunt timer value
   bne .doneCheckToMoveGopher       ; branch if Gopher taunting
   lda gopherHorizMovementValues
   and #GOPHER_CARROT_TARGET_MASK | GOPHER_TUNNEL_TARGET_MASK
   tax
   lda HorizontalTargetValues,x     ; get Gopher targeted horizontal position
   sec
   sbc gopherHorizPos               ; subtract Gopher horizontal position
   bpl .checkGopherReachingHorizontalTarget
   eor #$FF
   clc
   adc #1                           ; get absolute value
.checkGopherReachingHorizontalTarget
   cmp #3
   bcc .determineToRemoveCarrot
   lda gopherHorizMovementValues
   bmi .moveGopherLeft              ; branch if GOPHER_TRAVEL_LEFT
   inc gopherHorizPos
   inc gopherHorizPos
   lda #REFLECT
   sta gopherReflectState
   lda gopherHorizPos               ; get Gopher horizontal position
   cmp #XMAX_GOPHER
   bcs .wrapGopherToLeftSide
.doneCheckToMoveGopher
   jmp CheckForFarmerBonkingGopher

.wrapGopherToLeftSide
   lda #XMIN_GOPHER
   sta gopherHorizPos
   jmp CheckForFarmerBonkingGopher
       
.moveGopherLeft
   dec gopherHorizPos
   dec gopherHorizPos
   lda #NO_REFLECT
   sta gopherReflectState
   lda gopherHorizPos               ; get Gopher horizontal position
   cmp #XMIN_GOPHER
   bcc .wrapGopherToRightSide
   jmp CheckForFarmerBonkingGopher
       
.wrapGopherToRightSide
   lda #XMAX_GOPHER
   sta gopherHorizPos
   jmp CheckForFarmerBonkingGopher
       
.determineToRemoveCarrot
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_ABOVE_GROUND
   bne MoveGopherVertically         ; branch if Gopher not above ground
   lda gopherHorizMovementValues
   and #3
   tax
   lda #0
   sec
.determineCarrotBitToRemove
   rol                              ; rotate carry into D0
   dex
   bpl .determineCarrotBitToRemove
   eor #$FF
   and carrotPattern                ; mask to remove Carrot bit
   sta carrotPattern
   jmp AdvanceCurrentGameState
       
MoveGopherVertically
   ldy HorizontalTargetValues,x     ; get Gopher targeted horizontal position
   lda gopherReflectState
   beq .moveGopherVertically        ; branch if Gopher facing left
   iny
.moveGopherVertically
   sty gopherHorizPos
   lda gopherVertMovementValues
   and #GOPHER_TARGET_MASK          ; keep vertical target index value
   tax
   lda gopherVertPos                ; get Gopher vertical position
   cmp GopherTargetVertPositions,x
   beq .gopherReachedVerticalTarget ; branch if Gopher reached target
   bcc .moveGopherUp
   dec gopherVertPos                ; move Gopher down
.doneMoveGopherVertically
   jmp CheckForFarmerBonkingGopher

.moveGopherUp
   inc gopherVertPos                ; move Gopher up
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_ABOVE_GROUND
   bne .doneMoveGopherVertically    ; branch if Gopher not above ground
   lda gopherHorizPos               ; get Gopher horizontal position
   sec
   sbc #XMAX / 2
   bmi .determineLeftTargetedCarrot ; branch if Gopher on left half of screen
   lda #GOPHER_TRAVEL_LEFT | GOPHER_CARROT_TARGET
   sta gopherHorizMovementValues
   lda carrotPattern                ; get current Carrot pattern
   lsr
   bcs .doneDetermineTargetedCarrot ; branch if right Carrot present
   inc gopherHorizMovementValues
   lsr
   bcs .doneDetermineTargetedCarrot ; branch if center Carrot present
   inc gopherHorizMovementValues
   bne .doneDetermineTargetedCarrot ; unconditional branch
       
.determineLeftTargetedCarrot
   lda #10
   sta gopherHorizMovementValues
   lda carrotPattern                ; get current Carrot pattern
   and #1 << 2                      ; keep left Carrot value
   bne .doneDetermineTargetedCarrot ; branch if left Carrot present
   dec gopherHorizMovementValues
   lda carrotPattern                ; get current Carrot pattern
   and #1 << 1                      ; keep center Carrot value
   bne .doneDetermineTargetedCarrot ; branch if center Carrot present
   dec gopherHorizMovementValues
.doneDetermineTargetedCarrot
   jmp CheckForFarmerBonkingGopher

.gopherReachedVerticalTarget
   lda gopherVertMovementValues
   and #GOPHER_TARGET_MASK          ; keep vertical target index value
   beq SetGopherNewTargetValues     ; branch if Gopher targeting underground
   lda #$80
   sta gopherVertMovementValues     ; force Gopher to target underground
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_ABOVE_GROUND - 1
   bne CheckForFarmerBonkingGopher
   dec gopherVertPos                ; move Gopher down
   jmp CheckForFarmerBonkingGopher
       
SetGopherNewTargetValues
   jsr NextRandom
   lda random
   sta gopherVertMovementValues
   lda random + 1
   and #GOPHER_HORIZ_DIR_MASK | GOPHER_TUNNEL_TARGET_MASK
   sta gopherHorizMovementValues
   lda currentPlayerScore           ; get current score 100,000 value
   bne .verySmartGopher             ; branch if score > 9,999
   lda SWCHB                        ; read console switches
   ldx gameSelection                ; get current game selection
   bmi .checkDifficultySetting      ; branch if PLAYER_TWO_ACTIVE
   asl                              ; shift left player difficulty to D7
.checkDifficultySetting
   and #$80                         ; keep difficulty setting
   bpl .smartGopherSetting          ; branch if set to AMATEUR
.verySmartGopher
   lda farmerHorizPos               ; get Farmer horizontal position
   cmp #80
   bcc .gopherTargetRightHalfOfScreen;branch if Farmer on left half of screen
   lda gopherHorizMovementValues
   and #<~GOPHER_TARGET_RIGHT_TUNNELS
   sta gopherHorizMovementValues
   bne .smartGopherSetting
.gopherTargetRightHalfOfScreen
   lda gopherHorizMovementValues
   ora #GOPHER_TARGET_RIGHT_TUNNELS
   sta gopherHorizMovementValues
.smartGopherSetting
   lda gopherChangeDirectionTimer   ; get Gopher change direction timer
   bne .decrementGopherChangeDirectionTimer;branch if not expired
.resetGopherChangeDirectionTimer
   lda initGopherChangeDirectionTimer
   sta gopherChangeDirectionTimer
   lda gopherVertMovementValues
   ora #$80
   sta gopherVertMovementValues
   bne CheckForFarmerBonkingGopher  ; unconditional branch
       
.decrementGopherChangeDirectionTimer
   dec gopherChangeDirectionTimer   ; decrement Gopher change direction timer
   beq .resetGopherChangeDirectionTimer;branch if expired
   lda gopherVertMovementValues
   and #$7F
   sta gopherVertMovementValues
CheckForFarmerBonkingGopher SUBROUTINE
   lda farmerAnimationIdx           ; get Farmer animation index value
   cmp #4
   bcc .checkToTauntFarmer
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_ABOVE_GROUND - 1
   bcc .checkToTauntFarmer
   lda farmerHorizPos               ; get Farmer horizontal position
   sec
   sbc gopherHorizPos               ; subtract Gopher horizontal position
   sec
   sbc #3
   bpl .checkFarmerBonkingGopher
   eor #$FF                         ; get distance absolute value
   clc
   adc #1
.checkFarmerBonkingGopher
   cmp #6
   bcs .checkToTauntFarmer
   ldx #<[BonkGopherAudioValues - AudioValues]
   jsr SetGameAudioValues
   lda #POINTS_BONK_GOPHER
   jsr IncrementScore
   lda #INIT_GOPHER_HORIZ_POS - 4
   sta gopherHorizPos
   lda random
   and #GOPHER_HORIZ_DIR_MASK | GOPHER_TUNNEL_TARGET_MASK
   sta gopherHorizMovementValues
   lda #0
   sta gopherVertMovementValues
   sta gopherVertPos
   sta gopherTauntTimer
.checkToTauntFarmer
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_ABOVE_GROUND
   beq .disableZone01GopherSprite   ; branch if Gopher above ground
   cmp #VERT_POS_GOPHER_ABOVE_GROUND - 1
   bne .setZone01GopherGraphicValues
   lda gopherTauntTimer             ; get Gopher taunt timer value
   bne .decrementGopherTauntTimer
   ldx #<[GopherTauntAudioValues - AudioValues]
   jsr SetGameAudioValues
   lda #28
   sta gopherTauntTimer
   bne .setZone01GopherGraphicValues;unconditional branch
       
.decrementGopherTauntTimer
   dec gopherTauntTimer
   lda gopherTauntTimer             ; get Gopher taunt timer value
   bne .setZone01GopherGraphicValues
   sta gopherTauntTimer
.setZone01GopherGraphicValues
   lda gopherVertPos                ; get Gopher vertical position
   cmp #VERT_POS_GOPHER_UNDERGROUND + 7
   bcc .disableZone01GopherSprite
   lda #<[RisingGopherSprite + H_RISING_GOPHER - 1]
   sec
   sbc gopherVertPos
   sta zone01_GopherGraphicsPtrs
   jmp .determineGopherNUSIZValue
       
.disableZone01GopherSprite
   lda #<NullSprite
   sta zone01_GopherGraphicsPtrs
.determineGopherNUSIZValue
   ldx gopherVertPos                ; get Gopher vertical position
   beq .disableZone00GopherSprite   ; branch if crawling underground
   cpx #VERT_POS_GOPHER_ABOVE_GROUND
   beq .initiateGopherRunningAboveGround;branch if Gopher above ground
   lda #MSBL_SIZE1 | DOUBLE_SIZE
   cpx #VERT_POS_GOPHER_UNDERGROUND + 7
   bcc .setZone00GopherGraphicValues
   lda #MSBL_SIZE1 | ONE_COPY
.setZone00GopherGraphicValues
   sta gopherNUSIZValue
   lda zone01_GopherGraphicsPtrs
   clc
   adc #H_CARROT
   sta zone00_GopherGraphicsPtrs
   lda zone01_GopherGraphicsPtrs + 1
   sta zone00_GopherGraphicsPtrs + 1
   jmp .setZone02GopherGraphicValues
       
.disableZone00GopherSprite
   lda #MSBL_SIZE1 | DOUBLE_SIZE
   sta gopherNUSIZValue
   lda #<NullSprite
   sta zone00_GopherGraphicsPtrs
   lda #>NullSprite
   sta zone00_GopherGraphicsPtrs + 1
   jmp .setZone02GopherGraphicValues
       
.initiateGopherRunningAboveGround
   lda #<[RunningGopher_00 - 1]
   sta zone00_GopherGraphicsPtrs
   lda #>RunningGopher_00
   sta zone00_GopherGraphicsPtrs + 1
   lda #MSBL_SIZE1 | DOUBLE_SIZE
   sta gopherNUSIZValue
.setZone02GopherGraphicValues
   lda gopherVertPos                ; get Gopher vertical position
   beq .initiateGopherRunningUnderground;branch if Gopher crawling underground
   cmp #VERT_POS_GOPHER_UNDERGROUND + 7
   bcc .initiateGopherRunningUnderground
   cmp #VERT_POS_GOPHER_ABOVE_GROUND - 13
   bcs AnimateTauntingGopher
   lda #MSBL_SIZE1 | ONE_COPY
   sta gopherNUSIZValue
   lda zone01_GopherGraphicsPtrs
   sec
   sbc #H_GROUND_KERNEL_SECTION
   sta zone02_GopherGraphicsPtrs
   jmp .animateTauntingGopher
       
.initiateGopherRunningUnderground
   lda #<RunningGopher_00
   sta zone02_GopherGraphicsPtrs
   lda #>RunningGopher_00
   sta zone02_GopherGraphicsPtrs + 1
   lda #MSBL_SIZE1 | DOUBLE_SIZE
   sta gopherNUSIZValue
   jmp .animateTauntingGopher
       
AnimateTauntingGopher
   lda #<NullSprite
   sta zone02_GopherGraphicsPtrs
   lda #>NullSprite
   sta zone02_GopherGraphicsPtrs + 1
.animateTauntingGopher
   lda gopherTauntTimer             ; get Gopher taunt timer value
   beq .setGopherCrawlingAnimation  ; branch if done taunting
   cmp #7 * 3
   bcc .checkTauntingGopherAmintationStage02
.setTauntGopherSprite_00
   lda #<GopherTauntSprite_00
   sta zone00_GopherGraphicsPtrs
   lda #>GopherTauntSprite_00
   sta zone00_GopherGraphicsPtrs + 1
   bne DetermineTauntingGopherFacingDirection
       
.checkTauntingGopherAmintationStage02
   cmp #7 * 2
   bcc .tauntingGopherAmintationStage03
.setTauntGopherSprite_01
   lda #<GopherTauntSprite_01
   sta zone00_GopherGraphicsPtrs
   lda #>GopherTauntSprite_01
   sta zone00_GopherGraphicsPtrs + 1
   bne DetermineTauntingGopherFacingDirection
       
.tauntingGopherAmintationStage03
   cmp #7
   bcc .setTauntGopherSprite_01
   bcs .setTauntGopherSprite_00
       
DetermineTauntingGopherFacingDirection
   lda gopherHorizPos               ; get Gopher horizontal position
   sec
   sbc farmerHorizPos               ; subtract Farmer horizontal position
   bcs .faceTauntingGopherLeft      ; branch if Gopher to the right of Farmer
   lda gopherHorizMovementValues
   bpl .setGopherCrawlingAnimation  ; branch if GOPHER_TRAVEL_RIGHT
   and #<~GOPHER_HORIZ_DIR_MASK     ; clear GOPHER_HORIZ_DIR value
   sta gopherHorizMovementValues    ; set to GOPHER_TRAVEL_RIGHT
   inc gopherHorizPos
   lda #REFLECT
   sta gopherReflectState
   jmp .setGopherCrawlingAnimation
       
.faceTauntingGopherLeft
   lda gopherHorizMovementValues
   bmi .setGopherCrawlingAnimation  ; branch if GOPHER_TRAVEL_LEFT
   ora #GOPHER_TRAVEL_LEFT
   sta gopherHorizMovementValues    ; set to GOPHER_TRAVEL_LEFT
   lda #NO_REFLECT
   sta gopherReflectState
   dec gopherHorizPos               ; move Gopher left
.setGopherCrawlingAnimation
   ldx gopherVertPos                ; get Gopher vertical position
   beq .determineGopherCrawlingAnimation;branch if Gopher crawling underground
   cpx #VERT_POS_GOPHER_ABOVE_GROUND
   bne .newFrame                    ; branch if Gopher not above ground
.determineGopherCrawlingAnimation
   lda frameCount                   ; get current frame count
   and #3
   bne .skipGopherAnimationRateFlip
   lda gopherHorizAnimationRate     ; get Gopher horizontal animation rate
   eor #$FF                         ; flip bits
   sta gopherHorizAnimationRate
.checkToAnimateCrawlingGopher
   beq .newFrame
   lda #<RunningGopher_01
   cpx #VERT_POS_GOPHER_UNDERGROUND
   bne .initAboveGroundRunningGopherSprite
   sta zone02_GopherGraphicsPtrs
.newFrame
   jmp NewFrame

.skipGopherAnimationRateFlip
   lda gopherHorizAnimationRate
   jmp .checkToAnimateCrawlingGopher
       
.initAboveGroundRunningGopherSprite
   sta zone00_GopherGraphicsPtrs
   bne .newFrame                    ; unconditional branch
       
CarrotStolenByGopher
   lda #<NullSprite
   sta zone02_GopherGraphicsPtrs
   sta zone01_GopherGraphicsPtrs
   sta zone00_GopherGraphicsPtrs
   lda #>NullSprite
   sta zone02_GopherGraphicsPtrs + 1
   sta zone01_GopherGraphicsPtrs + 1
   sta zone00_GopherGraphicsPtrs + 1
   lda #WAIT_TIME_CARROT_STOLEN
   sta frameCount
   ldx #<[StolenCarrotAudioValues - AudioValues]
   jsr SetGameAudioValues
.advanceCurrentGameState
   jmp AdvanceCurrentGameState

WaitForActionButtonToStartRound
   lda carrotPattern                ; get current Carrot pattern
   beq .advanceCurrentGameState     ; branch if no Carrots left
   lda INPT4                        ; read left player action button
   ldx gameSelection                ; get current game selection
   bpl .checkPlayerActionButtonPressed;branch if PLAYER_ONE_ACTIVE
   lda INPT5                        ; read right player action button
.checkPlayerActionButtonPressed
   and #$80                         ; keep action button value
   bmi .newFrame                    ; branch if action button not pressed
   lda #GS_CHECK_FARMER_MOVEMENT
   sta gameState
   jmp NewFrame
       
WaitToStartNewGame
   ldx leftAudioIndexValue
   lda AudioValues,x
   bne .decrementCurrentGameState
   lda INPT4                        ; read left player action button
   bmi .decrementCurrentGameState   ; branch if action button not pressed
   lda #0
   ldx #9
.initPlayerInformationValues
   sta playerInformationValues,x
   dex
   bpl .initPlayerInformationValues
   lda #7
   sta carrotPattern
   sta reservedPlayerCarrotPattern
   lda #15
   sta initGopherChangeDirectionTimer
   sta reservedGopherChangeDirectionTimer
   lda gameSelection                ; get current game selection
   and #GAME_SELECTION_MASK         ; keep game selection value
   sta gameSelection
   lda #WAIT_TIME_GAME_START
   sta frameCount
   lda #GS_DISPLAY_GAME_SELECTION
   sta gameState
   ldx #<[StartingThemeAudioValues_00 - AudioValues]
   jsr SetGameAudioValues
   ldx #<[StartingThemeAudioValues_01 - AudioValues]
   jsr SetGameAudioValues
   jmp InitGameRoundData
       
.decrementCurrentGameState
   lda frameCount                   ; get current frame count
   cmp #128
   bne NewFrame
   lda gameSelection                ; get current game selection
   and #1
   beq NewFrame                     ; branch if ONE_PLAYER_GAME
   dec gameState
   jmp .alternatePlayers
       
CheckToAlternatePlayers
   lda gameSelection                ; get current game selection
   and #1
   beq .checkForGameOverState       ; branch if ONE_PLAYER_GAME
   lda reservedPlayerCarrotPattern  ; get reserved player Carrot pattern
   bne .alternatePlayers            ; branch if Carrots remaining
.checkForGameOverState
   lda carrotPattern                ; get current Carrot pattern
   bne AdvanceCurrentGameState
   ldx #<[GameOverThemeAudioValues_00 - AudioValues]
   jsr SetGameAudioValues
   ldx #<[GameOverThemeAudioValues_01 - AudioValues]
   jsr SetGameAudioValues
   lda #GS_WAIT_FOR_NEW_GAME
   sta gameState
   bne NewFrame                     ; unconditional branch
       
.alternatePlayers
   lda gameSelection                ; get current game selection
   and #1
   beq AdvanceCurrentGameState      ; branch if ONE_PLAYER_GAME
   lda gameSelection                ; get current game selection
   eor #ACTIVE_PLAYER_MASK
   sta gameSelection
   ldx #4
.alternatePlayerVariables
   lda currentPlayerInformation,x
   sta tmpCurrentPlayerData
   lda reservedPlayerInformation,x
   sta currentPlayerInformation,x
   lda tmpCurrentPlayerData
   sta reservedPlayerInformation,x
   dex
   bpl .alternatePlayerVariables
AdvanceCurrentGameState
   inc gameState
NewFrame SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   lda #START_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; start vertical sync (D1 = 1)
   lda #VSYNC_TIME
   sta TIM8T
.vsyncWaitTime
   lda INTIM
   bne .vsyncWaitTime
   jmp VerticalBlank
       
SixDigitDisplayKernel SUBROUTINE
   stx GRP0                   ; 3
   stx GRP1                   ; 3
   sta WSYNC
;--------------------------------------
   lda #61                    ; 2
   jsr PositionObjectHorizontally;6       position GRP0
;--------------------------------------
   lda #69                    ; 2 = @12
   inx                        ; 2
   jsr PositionObjectHorizontally;6
;--------------------------------------
   stx VDELP0                 ; 3 = @13
   stx VDELP1                 ; 3 = @16
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3 = @21
   stx NUSIZ1                 ; 3 = @24
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpDigitGraphicsColorValue;3
   sta COLUP0                 ; 3 = @09
   sta COLUP1                 ; 3 = @12
.sixDigitDisplayKernel
   lda (digitGraphicPtrs + 10),y;5
   sta tmpCharHolder          ; 3
   sta WSYNC
;--------------------------------------
   lda (digitGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @08
   lda (digitGraphicPtrs + 2),y;5
   sta GRP1                   ; 3 = @16
   lda (digitGraphicPtrs + 4),y;5
   sta GRP0                   ; 3 = @24
   lda (digitGraphicPtrs + 6),y;5
   tax                        ; 2
   lda (digitGraphicPtrs + 8),y;5
   sty tmpSixDigitDisplayLoop ; 3
   ldy tmpCharHolder          ; 3
   stx GRP1                   ; 3 = @45
   sta GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sty GRP0                   ; 3 = @54
   ldy tmpSixDigitDisplayLoop ; 3
   dey                        ; 2
   bpl .sixDigitDisplayKernel ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @66
   sta GRP1                   ; 3 = @69
   rts                        ; 6

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
   adc #(8 + 1) << 4          ; 2         increment by 8 for full range
   sta RESP0,x                ; 4         set coarse position value
   sta WSYNC
;--------------------------------------
   sta HMP0,x                 ; 4
   rts                        ; 6

IncrementScore
   sed
   ldx #2
   sec
.incrementScore
   adc currentPlayerScore,x
   sta currentPlayerScore,x
   bcc .doneIncrementScore
   cpx #2
   beq .checkToDecrementGopherDirectionTimer
.incrementNextScoreValue
   sec
   lda #1 - 1
   dex
   bpl .incrementScore
.doneIncrementScore
   cld
   rts

.checkToDecrementGopherDirectionTimer
   lda currentPlayerScore + 1       ; get current score 1,000
   and #1
   bne .checkToLaunchDuck           ; branch if not evenly divisible by 200
   dec initGopherChangeDirectionTimer
   bne .checkToLaunchDuck
   inc initGopherChangeDirectionTimer
.checkToLaunchDuck
   lda currentPlayerScore + 1       ; get current score 1,000
   and #$0F                         ; keep hundreds value
   cmp #4
   beq .checkGameSelectionForDuck   ; branch if hundreds value is 400
   cmp #9
   bne .incrementNextScoreValue     ; branch if hundreds value not 900
.checkGameSelectionForDuck
   lda gameSelection                ; get current game selection
   and #GAME_SELECTION_MASK         ; keep game selection value
   cmp #2
   bcs .incrementNextScoreValue     ; branch if NO_SEED_PLANTING
   lda carrotPattern                ; get current Carrot pattern
   cmp #7
   beq .incrementNextScoreValue     ; branch if all Carrots present
   lda fallingSeedVertPos           ; get seed vertical position
   bpl .incrementNextScoreValue     ; branch if seed active
   lda #XMIN_DUCK
   ldy random
   sty duckAttributes
   php                              ; push status to stack
   bpl .initDuckHorizontalPosition  ; branch if DUCK_TRAVEL_RIGHT
   lda #XMAX_DUCK
.initDuckHorizontalPosition
   sta duckHorizPos
   lda #XMIN_DUCK + 8
   plp                              ; pull status from stack
   bpl .initFallingSeedHorizontalPosition;branch if DUCK_TRAVEL_RIGHT
   lda #XMAX - 19
.initFallingSeedHorizontalPosition
   sta fallingSeedHorizPos
   tya                              ; move Duck attributes to accumulator
   and #SEED_TARGET_HORIZ_POS_MASK  ; keep SEED_TARGET_HORIZ_POS value
   cmp #[(XMAX + 1) / 8]
   bcs .initDuckSpriteValues
   lda duckAttributes               ; get duck attribute values
   and #DUCK_HORIZ_DIR_MASK         ; keep DUCK_HORIZ_DIR value
   ora #[(XMAX + 1) / 2]
   sta duckAttributes
.initDuckSpriteValues
   lda #INIT_DUCK_ANIMATION_RATE
   sta duckAnimationRate
   lda #<DuckWingsStationaryGraphics
   sta duckLeftGraphicPtrs
   lda #>DuckWingsStationaryGraphics
   sta duckLeftGraphicPtrs + 1
   lda #<DuckFaceGraphics
   sta duckRightGraphicPtrs
   lda #>DuckFaceGraphics
   sta duckRightGraphicPtrs + 1
   lda #INIT_SEED_VERT_POS
   sta fallingSeedVertPos
   lda #0
   sta heldSeedDecayingTimer
   jmp .incrementNextScoreValue
       
NextRandom
   ldx random + 1
   ldy random
   rol random
   rol random + 1
   lda random
   adc #195
   sta random
   tya
   eor random
   sta random
   txa
   eor random + 1
   sta random + 1
   rts

DetermineDirtFloorIndex
   lsr                              ; divide pixel value by 4 for PF pixel value
   lsr
   tay                              ; move PF pixel value to y register
   cmp #[(XMAX + 1) / 8]            ; screen half divided by PF pixel resolution
   bcc .determineDirtFloorIndex     ; branch if on left half of screen
   sbc #[(XMAX + 1) / 8]
.determineDirtFloorIndex
   ldx #0
   cpy #LEFT_PF1_PIXEL_OFFSET
   bcc .doneDetermineDirtFloorIndex ; branch if left PF0 value
   inx
   cpy #LEFT_PF2_PIXEL_OFFSET
   bcc .doneDetermineDirtFloorIndex ; branch if left PF1 value
   inx
   cpy #RIGHT_PF0_PIXEL_OFFSET
   bcc .doneDetermineDirtFloorIndex ; branch if left PF2 value
   inx
   cpy #RIGHT_PF1_PIXEL_OFFSET
   bcc .doneDetermineDirtFloorIndex ; branch if right PF0 value
   inx
   cpy #RIGHT_PF2_PIXEL_OFFSET
   bcc .doneDetermineDirtFloorIndex ; branch if right PF1 value
   inx
.doneDetermineDirtFloorIndex
   tay                              ; set DirtMaskingBits index value
   rts

SetGameAudioValues
   sty tmpGameAudioSavedY           ; save y register value
   inc audioChannelIndex            ; increment audio channel index value
   lda #1
   and audioChannelIndex            ; 0 <= a <= 1
   tay
   lda AudioValues,x                ; get audio tone value
   sta AUDC0,y
   inx                              ; increment for frequency and duration values
   stx audioIndexValues,y
   ldy tmpGameAudioSavedY           ; restore y register value
   rts

PlayGameAudioSounds
   ldx #1
.playGameAudioSounds
   lda audioDurationValues,x        ; get audio duration value
   beq .checkToPlayNextAudioFrequency
   dec audioDurationValues,x        ; decrement audio duration value
.nextAudioChannel
   dex
   bpl .playGameAudioSounds
   rts

.checkToPlayNextAudioFrequency
   ldy audioIndexValues,x
   lda #8
   sta AUDV0,x                      ; set volume for sounds
   lda AudioValues,y                ; get audio frequency and duration value
   bne .playNextAudioFrequency
   sta AUDC0,x                      ; turn off sound
   beq .nextAudioChannel            ; unconditional branch
   
.playNextAudioFrequency
   sta AUDF0,x
   and #AUDIO_DURATION_MASK         ; keep AUDIO_DURATION value
   bmi .setAudioIndexAndDurationValues
   lsr
.setAudioIndexAndDurationValues
   lsr
   lsr
   lsr
   iny
   sty audioIndexValues,x
   sta audioDurationValues,x
   jmp .nextAudioChannel
       
SetDigitGraphicPointers
   ldx #0
.setDigitGraphicPointers
   tya                              ; move LSB graphic value to accumulator
   sta digitGraphicPtrs,x           ; set graphic pointer LSB value
   clc
   adc #H_FONT                      ; increment for next graphic item
   tay                              ; move LSB graphic value to y register
   lda tmpDigitPointerMSB
   sta digitGraphicPtrs + 1,x       ; set graphic pointer MSB value
   inx
   inx
   cpx tmpEndGraphicPtrIdx
   bne .setDigitGraphicPointers
   rts

FillInTunnel
   lda DirtMaskingBits,y
   eor #$FF
   and gardenDirtValues,x
   sta gardenDirtValues,x
   rts

PlayerNumberLiteralSprites
PlayerNumberLiteral_00
   .byte $00 ; |........|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $F3 ; |XXXX..XX|
   .byte $DB ; |XX.XX.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $F3 ; |XXXX..XX|
PlayerNumber_01
   .byte $00 ; |........|
   .byte $D1 ; |XX.X...X|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
   .byte $0B ; |....X.XX|
   .byte $0B ; |....X.XX|
   .byte $0F ; |....XXXX|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
PlayerNumber_02
   .byte $00 ; |........|
   .byte $B0 ; |X.XX....|
   .byte $90 ; |X..X....|
   .byte $98 ; |X..XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $34 ; |..XX.X..|
   .byte $76 ; |.XXX.XX.|
   .byte $62 ; |.XX...X.|
   .byte $62 ; |.XX...X.|
PlayerNumber_03
   .byte $00 ; |........|
   .byte $FB ; |XXXXX.XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FB ; |XXXXX.XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FB ; |XXXXX.XX|
PlayerNumber_04
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $20 ; |..X.....|
   .byte $60 ; |.XX.....|
   .byte $C0 ; |XX......|
   .byte $60 ; |.XX.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $60 ; |.XX.....|
   .byte $C0 ; |XX......|

HorizontalTargetValues
   .byte HORIZ_POS_HOLE_00, HORIZ_POS_HOLE_01
   .byte HORIZ_POS_HOLE_02, HORIZ_POS_HOLE_03
   .byte HORIZ_POS_HOLE_04, HORIZ_POS_HOLE_05
   .byte HORIZ_POS_HOLE_00, HORIZ_POS_HOLE_05
   .byte HORIZ_POS_CARROT_02, HORIZ_POS_CARROT_01, HORIZ_POS_CARROT_00
   
   .byte $BA,$A0,$D3,$A0,$AA,$C8    ; unused bytes

   BOUNDARY 0
   
NumberFonts
zero
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $64 ; |.XX..X..|
   .byte $64 ; |.XX..X..|
   .byte $64 ; |.XX..X..|
   .byte $64 ; |.XX..X..|
   .byte $64 ; |.XX..X..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
one
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
two
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
three
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
four
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $FC ; |XXXXXX..|
   .byte $48 ; |.X..X...|
   .byte $68 ; |.XX.X...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
five
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $78 ; |.XXXX...|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7C ; |.XXXXX..|
six
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $64 ; |.XX..X..|
   .byte $64 ; |.XX..X..|
   .byte $6C ; |.XX.XX..|
   .byte $78 ; |.XXXX...|
   .byte $60 ; |.XX.....|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
seven
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $7C ; |.XXXXX..|
eight
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $4C ; |.X..XX..|
   .byte $5C ; |.X.XXX..|
   .byte $38 ; |..XXX...|
   .byte $74 ; |.XXX.X..|
   .byte $64 ; |.XX..X..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
nine
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $0C ; |....XX..|
   .byte $3C ; |..XXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $4C ; |.X..XX..|
   .byte $4C ; |.X..XX..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|

USGamesLiteral

   IF COMPILE_REGION = PAL50
   
   REPEAT 60
   
      .byte 0                       ; remove copyright for PAL50
      
   REPEND
   
   ELSE
   
USGamesLiteral_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0F ; |....XXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
USGamesLiteral_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $5E ; |.X.XXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
USGamesLiteral_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $25 ; |..X..X.X|
   .byte $25 ; |..X..X.X|
   .byte $2D ; |..X.XX.X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $3D ; |..XXXX.X|
USGamesLiteral_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $EA ; |XXX.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $EF ; |XXX.XXXX|
USGamesLiteral_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $BD ; |X.XXXX.X|
   .byte $A1 ; |X.X....X|
   .byte $A1 ; |X.X....X|
   .byte $BD ; |X.XXXX.X|
USGamesLiteral_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $E0 ; |XXX.....|
   
   ENDIF

GameSelectionLiteralSprites
GameSelection_00
   .byte $00 ; |........|
   .byte $72 ; |.XXX..X.|
   .byte $DA ; |XX.XX.X.|
   .byte $CB ; |XX..X.XX|
   .byte $C9 ; |XX..X..X|
   .byte $D9 ; |XX.XX..X|
   .byte $C1 ; |XX.....X|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $70 ; |.XXX....|
GameSelection_01
   .byte $00 ; |........|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $F6 ; |XXXX.XX.|
   .byte $66 ; |.XX..XX.|
   .byte $67 ; |.XX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C7 ; |XX...XXX|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
GameSelection_02
   .byte $00 ; |........|
   .byte $2F ; |..X.XXXX|
   .byte $2C ; |..X.XX..|
   .byte $AC ; |X.X.XX..|
   .byte $AC ; |X.X.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $6F ; |.XX.XXXX|
   .byte $6C ; |.XX.XX..|
   .byte $2C ; |..X.XX..|
   .byte $2F ; |..X.XXXX|
GameSelection_03
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   
FarmerColorValues
   .byte COLOR_FARMER_SHOES, COLOR_FARMER_SHOES, COLOR_FARMER_SHOES
   .byte COLOR_FARMER_PANTS, COLOR_FARMER_PANTS, COLOR_FARMER_PANTS
   .byte COLOR_FARMER_PANTS, COLOR_FARMER_PANTS, COLOR_FARMER_PANTS
   .byte COLOR_FARMER_PANTS, COLOR_FARMER_PANTS, COLOR_FARMER_PANTS
   .byte COLOR_FARMER_PANTS, COLOR_FARMER_PANTS, COLOR_FARMER_PANTS
   .byte COLOR_FARMER_PANTS, COLOR_FARMER_PANTS, COLOR_FARMER_PANTS
   .byte COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT
   .byte COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT
   .byte COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT
   .byte COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT, COLOR_FARMER_SHIRT
   .byte COLOR_FARMER_SHIRT, COLOR_FARMER, COLOR_FARMER, COLOR_FARMER
   .byte COLOR_FARMER, COLOR_FARMER, COLOR_FARMER, COLOR_FARMER, COLOR_FARMER
   .byte COLOR_FARMER, COLOR_FARMER, COLOR_FARMER, COLOR_FARMER, COLOR_FARMER_HAT
   .byte COLOR_FARMER_HAT, COLOR_FARMER_SHOES, COLOR_FARMER_HAT, COLOR_FARMER_HAT
   .byte COLOR_FARMER_HAT, COLOR_FARMER_HAT

   .byte $90,$A0,$D3,$A0,$A2        ; unused bytes
   
   BOUNDARY 0
   
Blank
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
   
AudioValues
StartingThemeAudioValues_00
   .byte 4                          ; high pitch square wave pure tone
   .byte  6 << 4 | 15,  7 << 4 |  1,  7 << 4 |  3,  7 << 4 |  4,  7 << 4 |  3
   .byte  7 << 4 |  1,  7 << 4 |  3,  7 << 4 | 10,  7 << 4 | 15,  7 << 4 | 13
   .byte  7 << 4 | 10,  7 << 4 |  7,  7 << 4 | 10,  7 << 4 | 15, 28 << 3 | 26
   .byte  6 << 4 | 15,  7 << 4 |  3,  6 << 4 | 15,  7 << 4 |  3,  7 << 4 |  1
   .byte  7 << 4 |  4,  7 << 4 |  1,  7 << 4 | 10,  7 << 4 |  4,  7 << 4 |  2
   .byte  7 << 4 |  1,  7 << 4 |  0, 16 << 3 | 15, 20 << 3 |  9, END_AUDIO_TUNE
StartingThemeAudioValues_01
   .byte 12                         ; lower pitch square wave sound
   .byte  7 << 4 |  1,  7 << 4 |  1, 28 << 3 | 26,  7 << 4 |  4,  7 << 4 |  4
   .byte  7 << 4 |  1,  7 << 4 |  1, 28 << 3 | 15, 28 << 3 | 17,  7 << 4 |  1
   .byte  7 << 4 |  4,  7 << 4 |  1,  7 << 4 |  4,  7 << 4 |  3,  7 << 4 |  7
   .byte  7 << 4 |  3,  7 << 4 |  7,  7 << 4 |  1,  7 << 4 |  2,  7 << 4 |  3
   .byte  7 << 4 |  6,  7 << 4 |  4,  7 << 4 |  1,  7 << 4 | 10, END_AUDIO_TUNE
BonkGopherAudioValues   
   .byte 12                         ; lower pitch square wave sound
   .byte  1 << 4 | 10,  1 << 4 |  2,  0 << 4 | 11,  0 << 4 |  6,  0 << 4 |  1
   .byte END_AUDIO_TUNE
GopherTauntAudioValues
   .byte 4                          ; high pitch square wave pure tone
   .byte  3 << 4 |  7,  1 << 4 |  0,  3 << 4 |  7,  1 << 4 |  0,  1 << 4 |  7
   .byte  3 << 4 | 11,  1 << 4 |  3,  3 << 4 | 11,  1 << 4 |  4,  0 << 4 | 14
   .byte  1 << 4 |  4,  0 << 4 | 14,  1 << 4 |  4,  3 << 4 |  7,  1 << 4 |  0
   .byte  3 << 4 |  7,  1 << 4 |  0,  1 << 4 |  7,  1 << 4 | 11,  1 << 4 |  3
   .byte  3 << 4 | 11, END_AUDIO_TUNE
StolenCarrotAudioValues
   .byte 7                          ; low and buzzy
   .byte  1 << 4 |  3,  0 << 4 |  7,  1 << 4 |  3,  0 << 4 |  7,  1 << 4 |  2
   .byte  0 << 4 |  6,  1 << 4 |  2,  0 << 4 |  6,  1 << 4 |  1,  0 << 4 |  5
   .byte  1 << 4 |  1,  0 << 4 |  5,  1 << 4 |  0,  0 << 4 |  4,  0 << 4 | 15
   .byte  0 << 4 |  3,  0 << 4 | 14,  0 << 4 |  2,  0 << 4 | 13,  0 << 4 |  2
   .byte  0 << 4 | 12,  0 << 4 |  1,  7 << 4 |  2, END_AUDIO_TUNE
DigTunnelAudioValues
   .byte 8                          ; white noise
   .byte  0 << 4 |  4,  0 << 4 |  3, END_AUDIO_TUNE
FillTunnelAudioValues
   .byte 6                          ; bass sound
   .byte  0 << 4 |  1,  0 << 4 |  4,  0 << 4 |  2,  0 << 4 |  6, END_AUDIO_TUNE
DuckQuackingAudioValues
   .byte 1                          ; saw waveform
   .byte  0 << 4 | 15,  0 << 4 | 14,  2 << 4 | 13,  2 << 4 | 12,  4 << 4 | 11
   .byte  0 << 4 | 12, END_AUDIO_TUNE
GameOverThemeAudioValues_00
   .byte 4                          ; high pitch square wave pure tone
   .byte 28 << 3 |  7, 28 << 3 | 11, 28 << 3 | 17, 28 << 3 | 26,  3 << 4 |  3
   .byte  2 << 4 |  0,  3 << 4 |  3,  2 << 4 |  0,  3 << 4 |  3,  2 << 4 |  0
   .byte  3 << 4 |  3,  2 << 4 |  0,  7 << 4 |  4,  6 << 4 |  0,  7 << 4 |  4
   .byte  6 << 4 |  0,  7 << 4 | 15, END_AUDIO_TUNE   
GameOverThemeAudioValues_01
   .byte 4                          ; high pitch square wave pure tone
   .byte 28 << 3 | 11, 28 << 3 | 17, 28 << 3 | 26, 28 << 3 | 19,  3 << 4 |  7
   .byte  2 << 4 |  0,  3 << 4 |  7,  2 << 4 |  0,  3 << 4 |  7,  2 << 4 |  0
   .byte  3 << 4 |  7,  2 << 4 |  0,  7 << 4 | 10,  6 << 4 |  0,  7 << 4 | 10
   .byte  6 << 4 |  0,  7 << 4 |  3, END_AUDIO_TUNE

CarrotGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
CarrotTopGraphics
   .byte $18 ; |...XX...|
   .byte $9A ; |X..XX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $7F ; |.XXXXXXX|
   .byte $5C ; |.X.XXX..|
   .byte $16 ; |...X.XX.|
   .byte $33 ; |..XX..XX|
   .byte $F3 ; |XXXX..XX|
   .byte $5A ; |.X.XX.X.|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

CarrotColorValues
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, RED_ORANGE + 6, BRICK_RED + 4
   .byte RED_ORANGE + 6, BRICK_RED + 4, RED_ORANGE + 6, BRICK_RED + 4
   .byte RED_ORANGE + 6, BRICK_RED + 4, RED_ORANGE + 6, BRICK_RED + 4
   .byte RED_ORANGE + 6, BRICK_RED + 4, RED_ORANGE + 6, BRICK_RED + 4
   .byte RED_ORANGE + 6, BRICK_RED + 4, RED_ORANGE + 6

GrassColorValues
   .byte COLOR_GRASS_03, COLOR_GRASS_03, COLOR_GRASS_03, COLOR_GRASS_03
   .byte COLOR_GRASS_03, COLOR_GRASS_02, COLOR_GRASS_02, COLOR_GRASS_02
   .byte COLOR_GRASS_02, COLOR_GRASS_02, COLOR_GRASS_01, COLOR_GRASS_01
   .byte COLOR_GRASS_01
   
GopherTargetVertPositions
   .byte VERT_POS_GOPHER_UNDERGROUND
   .byte VERT_POS_GOPHER_UNDERGROUND + 7
   .byte VERT_POS_GOPHER_UNDERGROUND + 14
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 13
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 1
   .byte VERT_POS_GOPHER_ABOVE_GROUND
   .byte VERT_POS_GOPHER_UNDERGROUND + 7
   .byte VERT_POS_GOPHER_UNDERGROUND + 14
   
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 13
   .byte VERT_POS_GOPHER_ABOVE_GROUND
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 1
   .byte VERT_POS_GOPHER_UNDERGROUND + 14
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 13
   .byte VERT_POS_GOPHER_ABOVE_GROUND
   .byte VERT_POS_GOPHER_ABOVE_GROUND - 1
   .byte VERT_POS_GOPHER_ABOVE_GROUND

CarrotAttributeValues
   .byte CARROT_COARSE_POSITION_CYCLE_52, HMOVE_L1, ONE_COPY
   .byte CARROT_COARSE_POSITION_CYCLE_47, HMOVE_L2, ONE_COPY
   .byte CARROT_COARSE_POSITION_CYCLE_47, HMOVE_L2, TWO_COPIES
   .byte CARROT_COARSE_POSITION_CYCLE_41, HMOVE_0,  ONE_COPY
   .byte CARROT_COARSE_POSITION_CYCLE_41, HMOVE_0,  TWO_MED_COPIES
   .byte CARROT_COARSE_POSITION_CYCLE_41, HMOVE_0,  TWO_COPIES
   .byte CARROT_COARSE_POSITION_CYCLE_41, HMOVE_0,  THREE_COPIES

FarmerSprites
FarmerSprite_00
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $1E ; |...XXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $31 ; |..XX...X|
   .byte $37 ; |..XX.XXX|
   .byte $37 ; |..XX.XXX|
   .byte $37 ; |..XX.XXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0C ; |....XX..|
   .byte $0B ; |....X.XX|
   .byte $0F ; |....XXXX|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $1D ; |...XXX.X|
   .byte $18 ; |...XX...|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
FarmerSprite_01
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $31 ; |..XX...X|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $08 ; |....X...|
   .byte $0B ; |....X.XX|
   .byte $0F ; |....XXXX|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $1D ; |...XXX.X|
   .byte $18 ; |...XX...|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
FarmerSprite_02
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0D ; |....XX.X|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0B ; |....X.XX|
   .byte $0F ; |....XXXX|
   .byte $1E ; |...XXXX.|
   .byte $1F ; |...XXXXX|
   .byte $1D ; |...XXX.X|
   .byte $18 ; |...XX...|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|

DuckWingsStationaryGraphics
   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $36 ; |..XX.XX.|
   .byte $1B ; |...XX.XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $37 ; |..XX.XXX|
   .byte $0F ; |....XXXX|
   .byte $7C ; |.XXXXX..|
   .byte $02 ; |......X.|
   .byte $1E ; |...XXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
DuckFaceGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $7F ; |.XXXXXXX|
   .byte $C0 ; |XX......|
   .byte $BF ; |X.XXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $7F ; |.XXXXXXX|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
DuckWingsDownGraphics
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $76 ; |.XXX.XX.|
   .byte $1B ; |...XX.XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $FB ; |XXXXX.XX|
   .byte $3D ; |..XXXX.X|
   .byte $1D ; |...XXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $07 ; |.....XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
DuckWingsUpGraphics
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $76 ; |.XXX.XX.|
   .byte $1B ; |...XX.XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $3E ; |..XXXXX.|
   .byte $01 ; |.......X|
   .byte $0F ; |....XXXX|
   
   .byte 0                          ; unused bytes

DuckColorValues
DuckLeftColorValues
   .byte BLUE + 12, BLUE + 12, BLUE + 12, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte 0                          ; unused bytes
DuckRightColorValues
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte BROWN + 12, BROWN + 12, BROWN + 12, WHITE, WHITE, WHITE, RED_ORANGE + 8
   .byte RED_ORANGE + 8, RED_ORANGE + 8
   
CopyrightLiteralSprites

   IF COMPILE_REGION = PAL50

   REPEAT 60
   
      .byte 0                       ; remove copyright for PAL50
      
   REPEND
   
   ELSE
   
Copyright_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $EE ; |XXX.XXX.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8E ; |X...XXX.|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
Copyright_01
   .byte $0E ; |....XXX.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EA ; |XXX.X.X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
Copyright_02
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $01 ; |.......X|
   .byte $97 ; |X..X.XXX|
   .byte $95 ; |X..X.X.X|
   .byte $95 ; |X..X.X.X|
   .byte $95 ; |X..X.X.X|
   .byte $D7 ; |XX.X.XXX|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
Copyright_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $74 ; |.XXX.X..|
   .byte $4E ; |.X..XXX.|
   .byte $44 ; |.X...X..|
Copyright_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $17 ; |...X.XXX|
Copyright_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $77 ; |.XXX.XXX|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|

   ENDIF
   
RisingGopherSprite
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
   .byte $14 ; |...X.X..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $5D ; |.X.XXX.X|
   .byte $77 ; |.XXX.XXX|
   .byte $3E ; |..XXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $7F ; |.XXXXXXX|
   .byte $63 ; |.XX...XX|
   
NullSprite
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
;
; last 13 bytes shared with table below
;
NullRunningGopher
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

RunningGopher_00
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $7C ; |.XXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FA ; |XXXXX.X.|
   .byte $D2 ; |XX.X..X.|
   .byte $72 ; |.XXX..X.|
   .byte $12 ; |...X..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
RunningGopher_01
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $28 ; |..X.X...|
   .byte $7C ; |.XXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FA ; |XXXXX.X.|
   .byte $D2 ; |XX.X..X.|
   .byte $72 ; |.XXX..X.|
   .byte $12 ; |...X..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GopherTauntSprite_00
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $07 ; |.....XXX|
   .byte $2F ; |..X.XXXX|
   .byte $57 ; |.X.X.XXX|
   .byte $07 ; |.....XXX|
   .byte $3B ; |..XXX.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $1E ; |...XXXX.|
   .byte $16 ; |...X.XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GopherTauntSprite_01
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $07 ; |.....XXX|
   .byte $57 ; |.X.X.XXX|
   .byte $2F ; |..X.XXXX|
   .byte $07 ; |.....XXX|
   .byte $3B ; |..XXX.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $1E ; |...XXXX.|
   .byte $16 ; |...X.XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

DirtMaskingBits
;
; PF0 bit masking values
;
   .byte 1 << 4, 1 << 5, 1 << 6, 1 << 7
;
; PF1 bit masking values
;
   .byte 1 << 7, 1 << 6, 1 << 5, 1 << 4, 1 << 3, 1 << 2, 1 << 1, 1 << 0
;
; PF2 bit masking values
;
   .byte 1 << 0, 1 << 1, 1 << 2, 1 << 3, 1 << 4, 1 << 5, 1 << 6, 1 << 7
       
    BOUNDARY 252

   .word Start                      ; RESET vector
   .byte $E0,$88                    ; BRK vector...unused bytes