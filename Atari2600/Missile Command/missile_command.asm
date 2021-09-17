   LIST OFF
; ***  M I S S I L E  C O M M A N D  ***
; Copyright 1981 Atari, Inc.
; Designer: Rob Fulop

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: September 7, 2020
;
;  *** 124 BYTES OF RAM USED 4 BYTES FREE
;  ***  13 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1981, ATARI, INC.                                  =
; =                                                                            =
; ==============================================================================

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
VBLANK_TIME             = 48
OVERSCAN_TIME           = 26

INIT_IBM_VERT_DELAY     = 32        ; ~ 7.5 pixels per frame
INIT_IBM_VERT_DELAY_CHILD = 8       ; ~ 1.875 pixels per frame

IBM_VERT_DELAY_INCREMENT_CHILD = 8

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 58
OVERSCAN_TIME           = 32

INIT_IBM_VERT_DELAY     = 45        ; ~ 8.79 pixels per frame
INIT_IBM_VERT_DELAY_CHILD = 21      ; ~ 4.1 pixels per frame

IBM_VERT_DELAY_INCREMENT_CHILD = 7

   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
YELLOW                  = $10
RED_ORANGE              = $20
RED                     = $40
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
GREEN                   = $C0
DK_GREEN                = $D0

COLOR_FIRST_WAVE_CLUSTER_CITIES = BLUE + 4
COLOR_FIRST_WAVE_CLUSTER_IBM = RED + 8
COLOR_FIRST_WAVE_CLUSTER_SKY = BLACK
COLOR_FIRST_WAVE_CLUSTER_MISSILE_BASE = RED_ORANGE + 4
COLOR_FIRST_WAVE_CLUSTER_SCORE = RED + 7

COLOR_SECOND_WAVE_CLUSTER_CITIES = BLUE + 4
COLOR_SECOND_WAVE_CLUSTER_IBM = GREEN + 14
COLOR_SECOND_WAVE_CLUSTER_SKY = BLACK
COLOR_SECOND_WAVE_CLUSTER_MISSILE_BASE = DK_GREEN + 8
COLOR_SECOND_WAVE_CLUSTER_SCORE = WHITE

COLOR_THIRD_WAVE_CLUSTER_CITIES = DK_GREEN + 10
COLOR_THIRD_WAVE_CLUSTER_IBM = RED + 8
COLOR_THIRD_WAVE_CLUSTER_SKY = BLACK
COLOR_THIRD_WAVE_CLUSTER_MISSILE_BASE = BLUE + 4
COLOR_THIRD_WAVE_CLUSTER_SCORE = BLUE + 8

COLOR_FOURTH_WAVE_CLUSTER_CITIES = BLUE + 10
COLOR_FOURTH_WAVE_CLUSTER_IBM = YELLOW + 10
COLOR_FOURTH_WAVE_CLUSTER_SKY = BLACK
COLOR_FOURTH_WAVE_CLUSTER_MISSILE_BASE = RED + 4
COLOR_FOURTH_WAVE_CLUSTER_SCORE = RED_ORANGE + 4

COLOR_FIFTH_WAVE_CLUSTER_CITIES = RED_ORANGE + 8
COLOR_FIFTH_WAVE_CLUSTER_IBM = RED + 12
COLOR_FIFTH_WAVE_CLUSTER_SKY = BLUE + 4
COLOR_FIFTH_WAVE_CLUSTER_MISSILE_BASE = DK_GREEN + 10
COLOR_FIFTH_WAVE_CLUSTER_SCORE = DK_GREEN + 10

COLOR_SIXTH_WAVE_CLUSTER_CITIES = BLUE + 8
COLOR_SIXTH_WAVE_CLUSTER_IBM = WHITE
COLOR_SIXTH_WAVE_CLUSTER_SKY = GREEN + 4
COLOR_SIXTH_WAVE_CLUSTER_MISSILE_BASE = BLACK
COLOR_SIXTH_WAVE_CLUSTER_SCORE = WHITE

COLOR_SEVENTH_WAVE_CLUSTER_CITIES = YELLOW + 10
COLOR_SEVENTH_WAVE_CLUSTER_IBM = WHITE
COLOR_SEVENTH_WAVE_CLUSTER_SKY = ULTRAMARINE_BLUE + 4
COLOR_SEVENTH_WAVE_CLUSTER_MISSILE_BASE = GREEN + 8
COLOR_SEVENTH_WAVE_CLUSTER_SCORE = GREEN + 10

COLOR_EIGHTH_WAVE_CLUSTER_CITIES = RED + 4
COLOR_EIGHTH_WAVE_CLUSTER_IBM = BLACK
COLOR_EIGHTH_WAVE_CLUSTER_SKY = YELLOW + 10
COLOR_EIGHTH_WAVE_CLUSTER_MISSILE_BASE = GREEN + 8
COLOR_EIGHTH_WAVE_CLUSTER_SCORE = RED + 4

   ELSE

YELLOW                  = $20
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE_2                = $70
PURPLE                  = $80
BLUE                    = $D0

COLOR_FIRST_WAVE_CLUSTER_CITIES = BLUE + 2
COLOR_FIRST_WAVE_CLUSTER_IBM = RED + 8
COLOR_FIRST_WAVE_CLUSTER_SKY = BLACK
COLOR_FIRST_WAVE_CLUSTER_MISSILE_BASE = BRICK_RED + 4
COLOR_FIRST_WAVE_CLUSTER_SCORE = RED + 6

COLOR_SECOND_WAVE_CLUSTER_CITIES = BLUE + 2
COLOR_SECOND_WAVE_CLUSTER_IBM = DK_GREEN + 14
COLOR_SECOND_WAVE_CLUSTER_SKY = BLACK
COLOR_SECOND_WAVE_CLUSTER_MISSILE_BASE = PURPLE_2 + 8
COLOR_SECOND_WAVE_CLUSTER_SCORE = WHITE

COLOR_THIRD_WAVE_CLUSTER_CITIES = PURPLE_2 + 10
COLOR_THIRD_WAVE_CLUSTER_IBM = RED + 10
COLOR_THIRD_WAVE_CLUSTER_SKY = BLACK
COLOR_THIRD_WAVE_CLUSTER_MISSILE_BASE = BLUE + 2
COLOR_THIRD_WAVE_CLUSTER_SCORE = BLUE + 8

COLOR_FOURTH_WAVE_CLUSTER_CITIES = BLUE + 10
COLOR_FOURTH_WAVE_CLUSTER_IBM = YELLOW + 12
COLOR_FOURTH_WAVE_CLUSTER_SKY = BLACK
COLOR_FOURTH_WAVE_CLUSTER_MISSILE_BASE = RED + 4
COLOR_FOURTH_WAVE_CLUSTER_SCORE = BRICK_RED + 4

COLOR_FIFTH_WAVE_CLUSTER_CITIES = BRICK_RED + 6
COLOR_FIFTH_WAVE_CLUSTER_IBM = RED + 12
COLOR_FIFTH_WAVE_CLUSTER_SKY = BLUE + 2
COLOR_FIFTH_WAVE_CLUSTER_MISSILE_BASE = PURPLE_2 + 10
COLOR_FIFTH_WAVE_CLUSTER_SCORE = PURPLE_2 + 10

COLOR_SIXTH_WAVE_CLUSTER_CITIES = BLUE + 8
COLOR_SIXTH_WAVE_CLUSTER_IBM = WHITE
COLOR_SIXTH_WAVE_CLUSTER_SKY = DK_GREEN + 4
COLOR_SIXTH_WAVE_CLUSTER_MISSILE_BASE = BLACK
COLOR_SIXTH_WAVE_CLUSTER_SCORE = WHITE

COLOR_SEVENTH_WAVE_CLUSTER_CITIES = YELLOW + 12
COLOR_SEVENTH_WAVE_CLUSTER_IBM = WHITE
COLOR_SEVENTH_WAVE_CLUSTER_SKY = PURPLE + 2
COLOR_SEVENTH_WAVE_CLUSTER_MISSILE_BASE = DK_GREEN + 8
COLOR_SEVENTH_WAVE_CLUSTER_SCORE = DK_GREEN + 10

COLOR_EIGHTH_WAVE_CLUSTER_CITIES = RED + 4
COLOR_EIGHTH_WAVE_CLUSTER_IBM = BLACK
COLOR_EIGHTH_WAVE_CLUSTER_SKY = YELLOW + 12
COLOR_EIGHTH_WAVE_CLUSTER_MISSILE_BASE = DK_GREEN + 8
COLOR_EIGHTH_WAVE_CLUSTER_SCORE = RED + 4

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

W_SCREEN                = 160

   IF COMPILE_REGION = PAL50

H_MISSILE_KERNEL        = 102

   ELSE
   
H_MISSILE_KERNEL        = 84

   ENDIF

H_FONT                  = 7
H_CITY                  = 9
H_MISSILE_BASE          = 4
H_SMALL_EXPLOSION       = 8
H_LARGE_EXPLOSION       = 16

XMIN                    = 0
XMAX                    = 159
XMID                    = (XMAX / 2)

XMIN_TARGET_CONTROL     = XMIN + 9
XMAX_TARGET_CONTROL     = XMAX - 8
YMIN_TARGET_CONTROL     = 10
YMAX_TARGET_CONTROL     = H_MISSILE_KERNEL - 1

MAX_CITIES              = 6
MAX_LAUNCHED_ABM        = 3
MAX_WAVE_NUMBER         = 15
MAX_GAME_SELECTION      = $34       ; BCD

INIT_NUMBER_LAUNCH_ABM  = 10
INIT_TARGET_CONTROL_POSITION = 50
INIT_ABM_VERT_POSITION  = 1

HORIZ_POSITION_CITY_01  = 24
HORIZ_POSITION_CITY_02  = 40
HORIZ_POSITION_CITY_03  = 56
HORIZ_POSITION_MISSILE_BASE = 80
HORIZ_POSITION_CITY_04  = 106
HORIZ_POSITION_CITY_05  = 122
HORIZ_POSITION_CITY_06  = 138
;
; Point values in BCD
;
UNUSED_ABM_POINTS       = $0005
IBM_POINTS              = $0025
SAVED_CITY_POINTS       = $0100
ENEMY_CRUISE_MISSILE_POINTS = $0125
;
; Game variation flags
;
NUM_PLAYERS_MASK        = %10000000
SMART_CRUISE_MISSILES   = %01000000
STARTING_WAVE_MASK      = %00001110
FAST_TARGET_CONTROL     = %00000001
TARGET_CONTROL_MASK     = %00000001
; Game variation bits
ONE_PLAYER_GAME         = 0 << 7
TWO_PLAYER_GAME         = 1 << 7
SMART_CRUISE_MISSILE    = 1 << 6
DUMB_CRUISE_MISSILE     = 0 << 6
FAST_TARGET_CONTROL     = 1
SLOW_TARGET_CONTROL     = 0
;
; Game state flags
;
GAME_OVER               = %10000000
RESET_DEBOUNCE_MASK     = %01000000
GAME_SELECTION_SCREEN   = %00000100
RESERVED_MISSILE_DUMP_MASK = %00000011
RESET_DOWN              = 0 << 6
RESET_RELEASED          = 1 << 6
;
; Sound engine mask values
;
SOUND_ENGINE_LEFT_CHANNEL_MASK = %00001111
SOUND_ENGINE_RIGHT_CHANNEL_MASK = %11110000
;
; Sound engine values
;
SOUND_TURN_OFF_VOLUME   = 0
SOUND_BEGINNING_WAVE_ALARM = 1
SOUND_ABM_EXHAUSTION    = 2
SOUND_ENEMY_CRUISE_MISSILE = 3
SOUND_REMAINING_ABM_TALLY = 4
SOUND_REMAINING_CITIES_TALLY = 5
SOUND_BONUS_CITY        = 6
SOUND_THE_END           = 7
SOUND_ABM_LAUNCHING     = 16
SOUND_ABM_EXPLODING     = 32
SOUND_WORLD_EXPLOSION   = 48
SOUND_CITY_EXPLOSION    = 64
;
; Initial sound frequency values
;
SOUND_BEGINNING_WAVE_ALARM_FREQUENCY = 4
SOUND_POINT_TALLY_FREQUENCY = 24
;
; Initial sound tone values
;
SOUND_ABM_LAUNCHING_TONE = 8
SOUND_CRUISE_MISSILE_TONE = 5
SOUND_POINT_TALLY_TONE  = 8
SOUND_BONUS_CITY_TONE   = 12
;
; Initial sound volume values
;
SOUND_ABM_LAUNCHING_VOLUME = 6
SOUND_ABM_EXHAUSTION_VOLUME = 8
SOUND_BONUS_CITY_VOLUME = 8
INIT_CRUISE_MISSILE_VOLUME = 2

   IF COMPILE_REGION = PAL50

INIT_ABM_TALLY_VOLUME   = 6
MAX_BEGINNING_WAVE_ALARM_FREQUENCY = 16

INIT_WAVE_TRANSITION_TIMER_ALARM = 127 + 33
WAVE_TRANSITION_INIT_TARGET_CONTROL = 127 + 25
WAVE_TRANSITION_NEW_WAVE = 127 + 41

   ELSE
   
INIT_ABM_TALLY_VOLUME   = 7
MAX_BEGINNING_WAVE_ALARM_FREQUENCY = 20

INIT_WAVE_TRANSITION_TIMER_ALARM = 127 + 41
WAVE_TRANSITION_INIT_TARGET_CONTROL = 127 + 33
WAVE_TRANSITION_NEW_WAVE = 127 + 49

   ENDIF
;
; Missile status values
;
ACTIVE_EXPLOSION_SIZE_MASK = %10000000
ACTION_BUTTON_DEBOUNCE_MASK = %00001000
ACTIVE_SMALL_EXPLOSION  = 0 << 7
ACTIVE_LARGE_EXPLOSION  = 1 << 7
ACTION_BUTTON_DOWN      = 1 << 3
ACTION_BUTTON_UP        = 0 << 3
;
; Game option flags
;
WORLD_EXPLOSION_MASK    = %10000000
CHILD_GAME_MASK         = %01000000
CHILD_GAME              = 1 << 6
;
; Launched ABM attribute flags
;
ABM_ACTIVE              = %10000000
ABM_DISTANCE_MASK       = %01000000
ABM_EXPLODING_FLAG      = %00100000
ABM_HORIZ_DISTANCE_GREATER = 0 << 6
ABM_VERT_DISTANCE_GREATER = 1 << 6
;
; Pixel offset for ABM launch
;
ABM_EXPERT_MOVEMENT_VALUE = 1
ABM_AMATEUR_MOVEMENT_VALUE = 2
;
; Current Enemy Missile flags
;
ENEMY_MISSILE_DIRECTION_MASK = %11110000
ENEMY_MISSILE_TYPE_MASK = %00000010
ENEMY_MISSILE_TYPE_IBM  = 0 << 1
ENEMY_MISSILE_TYPE_CRUISE = 1 << 1

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

frameCount              ds 1
tmpDeltaY               ds 1
;--------------------------------------
tmpEnemyMissileSlopeIntegerValue = tmpDeltaY
;--------------------------------------
tmpCurrentIBMVertPos    = tmpEnemyMissileSlopeIntegerValue
;--------------------------------------
tmpIBMPlanetCollisionHorizPosition = tmpCurrentIBMVertPos
tmpHundredsValueHolder  ds 1
;--------------------------------------
tmpScoreMultiplier      = tmpHundredsValueHolder
;--------------------------------------
tmpColorTableIndexMulti = tmpScoreMultiplier
;--------------------------------------
tmpTargetControlDeltaX  = tmpColorTableIndexMulti
;--------------------------------------
tmpTargetContolMinDistValue = tmpTargetControlDeltaX
;--------------------------------------
tmpMaximumMissileCount  = tmpTargetContolMinDistValue
;--------------------------------------
tmpDeltaX               = tmpMaximumMissileCount
;--------------------------------------
tmpCollisionBoxArea     = tmpDeltaX
;--------------------------------------
tmpGreatestDistance     = tmpCollisionBoxArea
;--------------------------------------
tmpEnemyTargetPosition  = tmpGreatestDistance
;--------------------------------------
tmpIBMHorizPosition     = tmpEnemyTargetPosition
tmpEnemyMissileVertPos  ds 1
;--------------------------------------
tmpActiveExplosionVertPos = tmpEnemyMissileVertPos
;--------------------------------------
tmpTargetContolMaxDistValue = tmpActiveExplosionVertPos
;--------------------------------------
tmpDiv4                 = tmpTargetContolMaxDistValue
;--------------------------------------
tmpIBMFarthestOffsetValue = tmpDiv4
activeABMVertPos        ds 1
targetControlScanline   ds 1
hueMask                 ds 1
;--------------------------------------
objectHorizPositions    = hueMask
;--------------------------------------
tmpSpawnedIBMSlopeFraction = objectHorizPositions
activeExplodingABMHorizPos ds 1
;--------------------------------------
tmpIBMHorizAdjustment   = activeExplodingABMHorizPos
tmpActiveIBMHorizPos    ds 1
;--------------------------------------
tmpMissileIndex         = tmpActiveIBMHorizPos
activeABMHorizPos       ds 1
targetControlHorizPos   ds 1
missileGraphicsPointer  ds 2
;--------------------------------------
activeExplosionGraphicPointer = missileGraphicsPointer
;--------------------------------------
ibmHorizOffsetPointer   = activeExplosionGraphicPointer
;--------------------------------------
ibmNUSIZPointer         = ibmHorizOffsetPointer
;--------------------------------------
ibmHorizPositionPointer = ibmNUSIZPointer
targetControlVertPosValues ds 2
;--------------------------------------
targetControlVertFracPos = targetControlVertPosValues
targetControlVertIntPos = targetControlVertFracPos + 1
targetControlHorizPosValues ds 2
;--------------------------------------
targetControlHorizFracPos = targetControlHorizPosValues
targetControlHorizIntPos = targetControlHorizFracPos + 1
enemyMissileNUSIZValues ds 2
;--------------------------------------
currentIBMNUSIZValue    = enemyMissileNUSIZValues
alternateIBMNUSIZValue  = currentIBMNUSIZValue + 1
enemyMissileVertPos     ds 2
;--------------------------------------
currentIBMVertPos       = enemyMissileVertPos
alternateIBMVertPos     = currentIBMVertPos + 1
enemyMissileSlopeFractionValues ds 2
;--------------------------------------
currentIBMSlopeFraction = enemyMissileSlopeFractionValues
alternativeIBMSlopeFraction = currentIBMSlopeFraction + 1
enemyMissileValues      ds 2
;--------------------------------------
currentIBMValues        = enemyMissileValues
alternativeIBMValues    = currentIBMValues + 1
enemyMissileHorizPos    ds 2
;--------------------------------------
currentIBMHorizPos      = enemyMissileHorizPos
alternativeIBMHorizPos  = currentIBMHorizPos + 1
ibmFractionalDelay      ds 1
ibmVerticalDelay        ds 2
explodingABMAnimationIndexes ds 3
activeExplosionHeight   ds 1
explodingABMState       ds 1
explodingABMVertPos     ds 3
explodingABMHorizPos    ds 3
cityGraphicPointers     ds 12
;--------------------------------------
_1stCityGraphicPointer  = cityGraphicPointers
_2ndCityGraphicPointer  = _1stCityGraphicPointer + 2
_3rdCityGraphicPointer  = _2ndCityGraphicPointer + 2
_4thCityGraphicPointer  = _3rdCityGraphicPointer + 2
_5thCityGraphicPointer  = _4thCityGraphicPointer + 2
_6thCityGraphicPointer  = _5thCityGraphicPointer + 2
launchedABMAttributes   ds 3
launchedABMGreatestDistance ds 3
abmOriginToTargetDiffChange ds 3
abmDistanceChangeValues ds 3
abmOriginToTargetDifference ds 3
launchedABMHorizPositions ds 3
launchedABMVertPositions ds 3
launchedABMIndex        ds 1
digitGraphicPointers    ds 12
explodingABMColor       ds 1
random                  ds 2
tmpLoopCount            ds 1
;--------------------------------------
tmpJoystickValue        = tmpLoopCount
;--------------------------------------
tmpGameSelectionDelay   = tmpJoystickValue
;--------------------------------------
tmpABMPositionIncrement = tmpGameSelectionDelay
;--------------------------------------
tmpPointsOnesValue      = tmpABMPositionIncrement
;--------------------------------------
tmpColorXOR             = tmpPointsOnesValue
;--------------------------------------
tmpMod16                = tmpColorXOR
;--------------------------------------
tmpIBMSlopeFraction     = tmpMod16
;--------------------------------------
tmpIBMDirectionValue    = tmpIBMSlopeFraction
;--------------------------------------
tmpBonusCityPosition    = tmpIBMDirectionValue
;--------------------------------------
tmpActiveExplosionHeight = tmpBonusCityPosition
;--------------------------------------
tmpIBMDeltaX            = tmpActiveExplosionHeight
gameState               ds 1
abmMoveFromReserveDelay ds 1
launchingBaseABMs       ds 1
remainingWaveIBMs       ds 1
;--------------------------------------
waveTransitionTimerValue = remainingWaveIBMs
soundEngineValues       ds 1
leftAudioValues         ds 1
;--------------------------------------
remainingCityTallyIndex = leftAudioValues
;--------------------------------------
remainingABMTallyVolume = remainingCityTallyIndex
;--------------------------------------
beginningWaveAlarmFrequency = remainingABMTallyVolume
;--------------------------------------
abmExhaustionFrequencyIndex = beginningWaveAlarmFrequency
;--------------------------------------
enemyCruiseMissleVolume = abmExhaustionFrequencyIndex
;--------------------------------------
theEndLeftAudioVolume   = enemyCruiseMissleVolume
;--------------------------------------
bonusCityLeftSoundIndex = theEndLeftAudioVolume
rightAudioValues        ds 1
;--------------------------------------
explodingABMVolumeIndex = rightAudioValues
;--------------------------------------
abmLaunchingSoundIndex  = explodingABMVolumeIndex
;--------------------------------------
explosionAudioValues    = abmLaunchingSoundIndex
objectColorValues       ds 5
;--------------------------------------
cityColor               = objectColorValues
ibmColor                = cityColor + 1
skyColor                = ibmColor + 1
missileBaseColor        = skyColor + 1
scoreColor              = missileBaseColor + 1
waveNumber              ds 1
colorCycleMode          ds 1
gameSelection           ds 1
selectDebounce          ds 1
remainingWaveCruiseMissiles ds 1
playerCityArray         ds 2
;--------------------------------------
player1CityArray        = playerCityArray
player2CityArray        = player1CityArray + 1
activeABMNUSIZValue     ds 1
playerScore             ds 6
currentPlayerNumber     ds 1
bonusCitiesRewarded     ds 2
;--------------------------------------
player1BonusCitiesRewarded = bonusCitiesRewarded
player2BonusCitiesRewarded = player1BonusCitiesRewarded + 1
gameVariation           ds 1
cruiseMissileVerticalDelay ds 2
gameOptions             ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
Start
   jmp ColdStart
   
PositionObjectsHorizontally
   ldx #<[targetControlHorizPos - objectHorizPositions]
.positionObjectsHorizontally
   lda #2                           ; adjustment value for missile or BALL
   cpx #<[tmpActiveIBMHorizPos - objectHorizPositions]
   bcs .adjustObjectHorizPosition   ; branch if object is a missile or BALL
   lda #1
   ldy activeExplosionHeight        ; get active explosion 2's complement height
   cpy #~(H_LARGE_EXPLOSION - 1)
   bne .adjustObjectHorizPosition
   lda #<-4                         ; adjust for large explosion
.adjustObjectHorizPosition
   clc
   adc objectHorizPositions,x
   ldy #3 - 1                       ; minimum coarse position color clock is 69
   sec
.divideBy15
   iny                              ; increment for coarse positioning
   sbc #15                          ; divide horizontal position by 15
   bcs .divideBy15
   eor #$FF                         ; get 1's complement of remainder
   sbc #7 - 1                       ; subtract value by 7 (i.e. carry clear)
   asl                              ; shift to upper nybbles for fine motion
   asl
   asl
   asl
   sta WSYNC                        ; force to next scan line
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; set object's coarse position
   sta HMP0,x                       ; set object's fine motion value
   lda activeExplosionHeight
   bne .donePositionObjectsHorizontally
   dex
   bpl .positionObjectsHorizontally
.donePositionObjectsHorizontally
   sta WSYNC
   sta HMOVE
   sta WSYNC
   rts

ColdStart
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
   stx SWACNT                       ; set all of SWCHA as input
   txa                              ; a = 0
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = #$FF
   txs                              ; set stack to beginning
   lda #GAME_OVER | GAME_SELECTION_SCREEN | 3
   sta gameState
   lda #1
   sta gameSelection                ; set to first game selection
MainLoop
VerticalSync
   lda #DISABLE_TIA
   sta VBLANK                       ; disable TIA (D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   lda #STOP_VERT_SYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   inc frameCount                   ; increment frame count
   bne .checkToMoveABMsFromReserve
   inc colorCycleMode               ; incremented ~ every 4.2 seconds
   lda gameState                    ; get current game state
   bpl .checkToMoveABMsFromReserve  ; branch if not GAME_OVER
   lda gameVariation                ; get the current game variation
   bpl .checkToMoveABMsFromReserve  ; branch if ONE_PLAYER_GAME
   lda currentPlayerNumber          ; get the current player number
   eor #1                           ; flip D0
   sta currentPlayerNumber          ; set new current player number
.checkToMoveABMsFromReserve
   lda abmMoveFromReserveDelay      ; get move from reserve delay value
   beq TallyPointsForRemainingABMsAndCities;branch if timer done
   dec abmMoveFromReserveDelay      ; decrement move from reserve delay
   bne TallyPointsForRemainingABMsAndCities
   jsr MoveABMsFromReserve          ; move remaining ABMs from reserve
TallyPointsForRemainingABMsAndCities
   bit gameState                    ; check current game state
   bpl .checkToTallyPointsForRemainingABMs;branch if not GAME_OVER
   lda #127 + 128
   sta waveTransitionTimerValue     ; set wave transition timer
.checkToTallyPointsForRemainingABMs
   lda waveTransitionTimerValue     ; get wave transition timer
   cmp #127 + 105
   bne .tallyPointsForRemainingCities;branch if not talling for remaining ABMs
   lda remainingCityTallyIndex      ; get remaining city tally index value
   bne .checkForGameReset
   lda #INIT_ABM_TALLY_VOLUME
   sta remainingABMTallyVolume
   lda launchingBaseABMs            ; get number of ABMs left at launch base
   bne .recordPointsForRemainingABMs; branch if ABMs left to launch
   jsr MoveABMsFromReserve          ; move reserve ABMs to be counted
   lda launchingBaseABMs            ; get number of ABMs left at launch base
   beq TallyPointsForRemainingCities; branch if no more ABMs left to launch
.recordPointsForRemainingABMs
   lda #SOUND_REMAINING_ABM_TALLY
   sta soundEngineValues            ; set to play SOUND_REMAINING_ABM_TALLY
   dec launchingBaseABMs            ; reduce number of ABMs left at launch base
   lda #<UNUSED_ABM_POINTS
   ldy #>UNUSED_ABM_POINTS
   jsr IncrementScore               ; increase score for remaining ABMs
.checkForGameReset
   jmp CheckForGameReset
   
TallyPointsForRemainingCities
   lda #127 + 97
   sta waveTransitionTimerValue     ; set wave transition timer for 97 ticks
   lda #SOUND_TURN_OFF_VOLUME
   sta soundEngineValues
   sta remainingCityTallyIndex
.tallyPointsForRemainingCities
   lda waveTransitionTimerValue     ; get wave transition timer value
   cmp #127 + 97
   bne .decrementWaveTransitionTimerValue
   lda frameCount                   ; get current frame count
   and #$0F
   bne CheckForGameReset            ; tally Cities every 16 frames
   ldx remainingCityTallyIndex      ; get remaining City tally index value
.lookForRemainingCities
   cpx #MAX_CITIES
   beq .setToPlayBeginningWaveAlarm ; branch if all City points tallied
   ldy CityBonusTallyOrder,x        ; get index for City bonus tally
   lda cityGraphicPointers,y        ; get City graphic pointer LSB value
   cmp #<CitySprite
   beq .recordPointsForSavedCity    ; branch if City present
   inx                              ; increment index for City bonus tally
   bne .lookForRemainingCities      ; unconditional branch
   
.recordPointsForSavedCity
   lda DestroyedCityPointer         ; get LSB for destroyed City sprite
   sta cityGraphicPointers,y        ; set to show City destroyed
   inx                              ; increment index for City bonus tally
   stx remainingCityTallyIndex
   lda #<SAVED_CITY_POINTS
   ldy #>SAVED_CITY_POINTS
   jsr IncrementScore               ; increment score for remaining cities
   lda #SOUND_REMAINING_CITIES_TALLY
   sta soundEngineValues            ; set to play SOUND_REMAINING_CITIES_TALLY
   bne CheckForGameReset            ; unconditional branch
   
.setToPlayBeginningWaveAlarm
   lda #INIT_WAVE_TRANSITION_TIMER_ALARM
   sta waveTransitionTimerValue
   lda #SOUND_BEGINNING_WAVE_ALARM_FREQUENCY
   sta beginningWaveAlarmFrequency
   lda #SOUND_BEGINNING_WAVE_ALARM
   sta soundEngineValues            ; set to play SOUND_BEGINNING_WAVE_ALARM
   jsr CheckToRewardBonusCities
   jmp DetermineCurrentLaunchedABMIndex
   
.decrementWaveTransitionTimerValue
   lda soundEngineValues            ; get sound engine values
   cmp #SOUND_BONUS_CITY
   beq CheckForGameReset            ; branch if playing SOUND_BONUS_CITY
   bit waveTransitionTimerValue     ; check wave transition timer value
   bpl CheckForGameReset            ; branch if done transitioning wave time
   lda frameCount                   ; get current frame count
   and #3
   bne CheckForGameReset
   dec waveTransitionTimerValue
   bmi .checkToInitTargetControlPosition;branch if still transitioning wave
   jmp InitializeWaveValues
   
.checkToInitTargetControlPosition
   lda waveTransitionTimerValue     ; get wave transition timer value
   cmp #WAVE_TRANSITION_INIT_TARGET_CONTROL
   bne CheckForGameReset            ; skip init Target Control position
   lda #INIT_TARGET_CONTROL_POSITION
   sta targetControlHorizIntPos
   sta targetControlVertIntPos
   jsr CheckToIncrementWaveNumber
CheckForGameReset
   bit gameState                    ; check current game state
   bvc ResetCityAndDigitSprites     ; branch if RESET_DOWN
   lda SWCHB                        ; read console switches
   and #SELECT_MASK | RESET_MASK    ; mask to get SELECT and RESET values
   beq .selectAndResetPressed       ; branch if SELECT and RESET are pressed
   lsr                              ; RESET now in carry
   bcc StartNewGame                 ; branch if RESET down
.selectAndResetPressed
   jmp CheckForGameSelect
   
StartNewGame
   lda #0
   sta gameState
ResetCityAndDigitSprites
   lda #<CitySprite
   ldy #>CitySprite
   ldx #10
.resetCityAndDigitSpriteLoop
   sta cityGraphicPointers,x        ; set City sprite LSB
   sty cityGraphicPointers + 1,x    ; set City sprite MSB
   sty digitGraphicPointers + 1,x   ; set digit graphic pointer MSB
   dex
   dex
   bpl .resetCityAndDigitSpriteLoop
   iny                              ; y = 0
   ldx #5
.clearPlayerScores
   sty playerScore,x                ; set player score to 0
   dex
   bpl .clearPlayerScores
   sty player2CityArray             ; clear player 2 city array
   sty currentPlayerNumber          ; set new current player number
   sty gameOptions
   sty player1BonusCitiesRewarded
   sty player2BonusCitiesRewarded
   ldy gameSelection                ; get current game selection
   lda GameVariationTable,y         ; get game selection game variation
   ldx #$3F
   stx player1CityArray             ; reset player 1 City array
   cpy #$18
   bcc .setGameVariation            ; branch if ONE_PLAYER_GAME
   tya                              ; move game selection to accumulator
   sed
   sec
   sbc #$17                         ; subtract to get game variation
   tay
   cld
   lda GameVariationTable,y         ; get game selection game variation
   stx player2CityArray             ; reset player 2 City array
   ora #TWO_PLAYER_GAME             ; set D7 for TWO_PLAYER_GAME
   ldx #1
   stx currentPlayerNumber          ; set new current player number
.setGameVariation
   sta gameVariation                ; set current game variation
   cpy #$17
   bne .determineStartingWaveNumber ; branch if not CHILD_GAME
   ldy #CHILD_GAME
   sty gameOptions
.determineStartingWaveNumber
   and #STARTING_WAVE_MASK          ; mask starting wave from game variation
   tax                              ; move starting wave number to x
   dex                              ; reduce value by 1
   stx waveNumber                   ; save the starting wave number
   lda #H_MISSILE_KERNEL
   sta currentIBMVertPos
   sta alternateIBMVertPos
   lda gameState                    ; get current game state
   ora #RESET_RELEASED
   sta gameState                    ; set to show RESET_RELEASED
   bit gameState                    ; check current game state
   bmi .checkForGameSelect          ; branch if GAME_OVER
   lda #INIT_TARGET_CONTROL_POSITION
   sta targetControlVertIntPos
   sta targetControlHorizIntPos
   ldx #SOUND_BEGINNING_WAVE_ALARM
   stx soundEngineValues            ; set to play SOUND_BEGINNING_WAVE_ALARM
   ldx #SOUND_BEGINNING_WAVE_ALARM_FREQUENCY
   stx beginningWaveAlarmFrequency
   lda #INIT_IBM_VERT_DELAY - 13
   bit gameOptions
   bvc DetermineIBMFractionDelayValue;branch if not CHILD_GAME
   lda #INIT_IBM_VERT_DELAY_CHILD - 13
DetermineIBMFractionDelayValue
   ldy waveNumber                   ; get current wave number
   iny
.determineIBMFractionDelayValue
   clc
   adc #13
   dey
   bpl .determineIBMFractionDelayValue
   sta ibmFractionalDelay           ; set initial IBM fractional delay
   lda #WAVE_TRANSITION_NEW_WAVE
   sta waveTransitionTimerValue
   lda frameCount                   ; get current frame count
   ora #2
   sta random                       ; seed random number
   sta random + 1
.checkForGameSelect
   jmp CheckForGameSelect
   
InitializeWaveValues
   ldy #MAX_WAVE_NUMBER
   lda waveNumber                   ; get current wave number
   cmp #MAX_WAVE_NUMBER + 1
   bcs .determineNumberOfIBMsForWave
   tay
.determineNumberOfIBMsForWave
   lda MaximumWaveIBMValues,y       ; get maximum IBMs for wave
   bit gameOptions
   bvc .setNumberOfIBMsForWave      ; branch if not CHILD_GAME
   lsr                              ; divide value by 2
.setNumberOfIBMsForWave
   sta remainingWaveIBMs            ; set remaining wave IBMs
   lda MaximumWaveCruiseMissileValues,y
   sta remainingWaveCruiseMissiles  ; set remaining wave cruise missiles
   lda #INIT_NUMBER_LAUNCH_ABM
   sta launchingBaseABMs            ; initialize number of ABMs at missile base
   lda #XMID
   ldy #INIT_ABM_VERT_POSITION
   ldx #MAX_LAUNCHED_ABM - 1
.initABMValues
   sta launchedABMHorizPositions,x
   sty launchedABMVertPositions,x
   sty launchedABMAttributes,x
   dec launchedABMAttributes,x
   dex
   bpl .initABMValues
   stx currentIBMNUSIZValue
   stx alternateIBMNUSIZValue
   inx                              ; x = 0
   stx soundEngineValues            ; set to SOUND_TURN_OFF_VOLUME
   lda #RESET_RELEASED
   sta gameState
CheckForGameSelect
   ldy #31
   lda SWCHB                        ; read console switches
   and #SELECT_MASK | RESET_MASK    ; keep SELECT and RESET values
   bne .setGameSelectionDelayValue
   ldy #7
.setGameSelectionDelayValue
   sty tmpGameSelectionDelay
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   lsr                              ; SELECT now in carry
   lda #$FF
   bcc .selectSwitchDown
   sta selectDebounce               ; reset select debounce value
   bne .doneCheckForGameSelect      ; unconditional branch
   
.selectSwitchDown
   sta gameState
   lda selectDebounce               ; get select debounce value
   bmi .incrementGameSelectionValue
   eor frameCount
   and tmpGameSelectionDelay
   bne .doneCheckForGameSelect
.incrementGameSelectionValue
   lda frameCount                   ; get current frame count
   and tmpGameSelectionDelay
   sta selectDebounce
   sed
   clc
   lda gameSelection                ; get current game selection
   adc #1                           ; increment game selection by 1
   cmp #MAX_GAME_SELECTION + 1      ; make sure game selection is within bounds
   bne .setNewGameSelection
   lda #1                           ; set to wrap game selection to 1
.setNewGameSelection
   sta gameSelection
   cld
   lda #SOUND_TURN_OFF_VOLUME
   sta soundEngineValues            ; set to SOUND_TURN_OFF_VOLUME
   sta colorCycleMode
   sta waveNumber
   sta targetControlVertIntPos
   sta targetControlHorizIntPos
.doneCheckForGameSelect
   bit gameOptions
   bpl CheckForActionButtonPressed  ; branch if not WORLD_EXPLOSION
   jmp DetermineCurrentLaunchedABMIndex
   
CheckForActionButtonPressed
   jsr NextRandom                   ; get next random number
   ldx currentPlayerNumber          ; get the current player number
   lda INPT4,x                      ; read player action button
   bpl .actionButtonPressed         ; branch if player pressing action button
   lda explodingABMState            ; get exploding ABM state
   and #~ACTION_BUTTON_DEBOUNCE_MASK; clear ACTION_BUTTON_DEBOUNCE value
   sta explodingABMState
   jmp DetermineABMMovementValue
   
.actionButtonPressed
   lda explodingABMState            ; get exploding ABM state
   and #ACTION_BUTTON_DEBOUNCE_MASK ; keep ACTION_BUTTON_DEBOUNCE value
   bne DetermineABMMovementValue    ; branch if action button held
   ldx #MAX_LAUNCHED_ABM - 1
.searchForNonActiveABM
   lda launchedABMAttributes,x      ; get launched ABM attribute
   bpl LaunchABM                    ; branch if ABM not active
   dex
   bpl .searchForNonActiveABM
.abmLaunchExhausted
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   bne DetermineABMMovementValue    ; branch if sounds set for left channel
   sta abmExhaustionFrequencyIndex
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_ABM_EXHAUSTION
   sta soundEngineValues            ; set to play SOUND_ABM_EXHAUSTION
   bne DetermineABMMovementValue    ; unconditional branch
   
LaunchABM
   lda #ACTION_BUTTON_DOWN
   ora explodingABMState            ; combine with exploding ABM state
   sta explodingABMState            ; set to show ACTION_BUTTON_DOWN
   lda waveTransitionTimerValue     ; get wave transition timer value
   bmi DetermineABMMovementValue    ; branch if transitioning waves
   lda launchingBaseABMs            ; get number of ABMs left at missile base
   beq .abmLaunchExhausted          ; branch if no more ABMs at missile base
   dec launchingBaseABMs            ; reduce number of ABMs at missile base
   bne .setSoundEngineForLaunchingABM;branch if more ABMs at missile base
   jsr MoveABMsFromReserve
.setSoundEngineForLaunchingABM
   lda soundEngineValues            ; get sound engine values
   cmp #SOUND_ABM_EXPLODING
   bcs DetermineLaunchedABMTargetValues;branch if playing higher priority sound
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   ora #SOUND_ABM_LAUNCHING
   sta soundEngineValues            ; set to play SOUND_ABM_LAUNCHING
   lda #10
   sta abmLaunchingSoundIndex
DetermineLaunchedABMTargetValues
   lda #XMID
   sec
   sbc targetControlHorizIntPos     ; subtract Target Control position
   bcs .setTargetControlHorizDistance;branch if on left side of screen
   inc launchedABMHorizPositions,x
   eor #$FF                         ; get distance absolute value
   adc #1
.setTargetControlHorizDistance
   sta tmpTargetControlDeltaX       ; set horizontal distance from center
   lda targetControlVertIntPos      ; get Target Control vertical position
   sec
   sbc #INIT_ABM_VERT_POSITION
   cmp tmpTargetControlDeltaX
   bcc .greaterTargetHorizontalDistance;branch if horizontal distance greater
   sta tmpTargetContolMaxDistValue  ; set from vertical distance from target
   lda #ABM_ACTIVE | ABM_VERT_DISTANCE_GREATER
   sta launchedABMAttributes,x
   jmp .setLaunchedABMTargetValues
   
.greaterTargetHorizontalDistance
   ldy tmpTargetControlDeltaX       ; get horizontal distance from center
   sta tmpTargetContolMinDistValue  ; set from vertical distance from target
   sty tmpTargetContolMaxDistValue
   lda #ABM_ACTIVE | ABM_HORIZ_DISTANCE_GREATER
   sta launchedABMAttributes,x
.setLaunchedABMTargetValues
   lda tmpTargetContolMaxDistValue
   sta launchedABMGreatestDistance,x
   sta abmOriginToTargetDiffChange,x
   lda tmpTargetContolMinDistValue
   sta abmDistanceChangeValues,x
   lda #0
   sta abmOriginToTargetDifference,x;reset origin to target points difference
DetermineABMMovementValue
   lda SWCHB                        ; read console switches
   asl                              ; shift player 2 difficulty setting to carry
   ldx currentPlayerNumber          ; get the current player number
   bne .determineABMMovement        ; branch if player 2 is active
   asl                              ; shift player 1 difficulty setting to carry
.determineABMMovement
   ldy #ABM_AMATEUR_MOVEMENT_VALUE  ; assume difficulty setting set to AMATEUR
   bcc .setABMMovementValue
   dey                              ; reduce movement if set to EXPERT
.setABMMovementValue
   sty tmpABMPositionIncrement
   ldx #MAX_LAUNCHED_ABM - 1
.moveActiveABMLoop
   lda launchedABMAttributes,x      ; get launched ABM attribute
   bmi MoveActiveABM                ; branch if ABM_ACTIVE
.jmpToNextLaunchedABM
   jmp .nextLaunchedABM
   
MoveActiveABM
   and #ABM_EXPLODING_FLAG          ; keep ABM_EXPLODING value
   bne .jmpToNextLaunchedABM        ; branch if ABM exploding
   lda abmOriginToTargetDifference,x; get origin to target point difference
   clc
   adc abmDistanceChangeValues,x    ; increment by distance change value
   sta abmOriginToTargetDifference,x; set new origin to target difference
   cmp abmOriginToTargetDiffChange,x
   bcc .moveActiveABM
   sbc abmOriginToTargetDiffChange,x
   sta abmOriginToTargetDifference,x; restore origin to target point difference
   lda launchedABMAttributes,x      ; get launched ABM attribute
   and #ABM_DISTANCE_MASK           ; keep ABM_DISTANCE value
   bne .doubleChangeX               ; branch if ABM_VERT_DISTANCE_GREATER
.doubleChangeY
   lda launchedABMVertPositions,x   ; get the launched ABM vertical position
   clc
   adc tmpABMPositionIncrement      ; move launched ABM up the screen
   sta launchedABMVertPositions,x
   jmp .moveActiveABM
   
.doubleChangeX
   lda #XMID                        ; get horizontal mid value
   cmp launchedABMHorizPositions,x  ; compare with ABM horizontal position
   bcs .doubleChangeXLeft           ; branch if ABM on left side of screen
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   clc
   adc tmpABMPositionIncrement      ; increment ABM horizontal position
   sta launchedABMHorizPositions,x
   jmp .moveActiveABM
   
.doubleChangeXLeft
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   sec
   sbc tmpABMPositionIncrement      ; subtract ABM horizontal position
   sta launchedABMHorizPositions,x
.moveActiveABM
   lda launchedABMAttributes,x      ; get launched ABM attribute
   and #ABM_DISTANCE_MASK           ; keep ABM_DISTANCE value
   beq .moveActiveABMHorizontally   ; branch if ABM_HORIZ_DISTANCE_GREATER
   lda launchedABMVertPositions,x   ; get launched ABM vertical position
   clc
   adc tmpABMPositionIncrement      ; move launched ABM up the screen
   sta launchedABMVertPositions,x
   jmp .checkABMReachingTargetPosition
   
.moveActiveABMHorizontally
   lda #XMID                        ; get horizontal mid value
   cmp launchedABMHorizPositions,x  ; compare with ABM horizontal position
   bcs .abmTravelingLeft            ; branch if ABM on left side of screen
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   clc
   adc tmpABMPositionIncrement      ; increment ABM horizontal position
   sta launchedABMHorizPositions,x
   jmp .checkABMReachingTargetPosition
   
.abmTravelingLeft
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   sec
   sbc tmpABMPositionIncrement      ; subtract ABM horizontal position
   sta launchedABMHorizPositions,x
.checkABMReachingTargetPosition
   lda launchedABMGreatestDistance,x
   sec
   sbc tmpABMPositionIncrement
   sta launchedABMGreatestDistance,x
   bcc .setABMAttributeToExploding
   bne .nextLaunchedABM
.setABMAttributeToExploding
   lda #ABM_EXPLODING_FLAG
   ora launchedABMAttributes,x
   sta launchedABMAttributes,x      ; show launched ABM as exploding
   ldy #0
   sty explodingABMAnimationIndexes,x;set to start of exploding animation
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   sec
   sbc #4
   sta explodingABMHorizPos,x       ; set exploding ABM horizontal position
   lda launchedABMVertPositions,x   ; get launched ABM vertical position
   sbc #4
   sta explodingABMVertPos,x        ; set exploding ABM vertical position
.nextLaunchedABM
   dex
   bmi .doneMoveActiveABM
   jmp .moveActiveABMLoop
   
.doneMoveActiveABM
   ldx launchedABMIndex             ; get current launched ABM index
   ldy #H_MISSILE_KERNEL
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   sta activeABMHorizPos
   lda launchedABMAttributes,x      ; get launched ABM attribute
   and #ABM_EXPLODING_FLAG          ; keep ABM_EXPLODING value
   bne .setActiveABMVerticalPosition; branch if ABM exploding
   ldy launchedABMVertPositions,x   ; get launched ABM vertical position
.setActiveABMVerticalPosition
   sty activeABMVertPos
   lda waveTransitionTimerValue     ; get wave transition timer value
   bpl ReadJoystickValues           ; branch if not transitioning waves
   cmp #WAVE_TRANSITION_INIT_TARGET_CONTROL
   bcc ReadJoystickValues           ; branch allowed to move Target Control
   jmp .setTargetControlDisplayPositions
   
ReadJoystickValues
   lda SWCHA                        ; get the joystick values
   ldy currentPlayerNumber          ; get the current player number
   beq .setCurrentJoystickValue     ; branch if player 1 is active
   dey                              ; reduce so y = 0
   asl                              ; shift player 2's joystick value to MSB
   asl
   asl
   asl
.setCurrentJoystickValue
   sta tmpJoystickValue
   bit gameOptions
   bvc .determineTargetControlSpeed ; branch if not CHILD_GAME
   ldy #4                           ; target control speed index for CHILD_GAME
   bne .moveTargetControl           ; unconditional branch
   
.determineTargetControlSpeed
   lda gameVariation                ; get the current game variation
   lsr                              ; shift TARGET_CONTROL_MASK to carry
   bcc .moveTargetControl           ; branch if SLOW_TARGET_CONTROL
   ldy #2
.moveTargetControl
   lda targetControlHorizFracPos    ; get Target Control horizontal fraction
   rol tmpJoystickValue             ; shift MOVE_RIGHT value to carry
   bcs .checkToMoveTargetLeft       ; branch if joystick not moved right
   adc TargetControlFractionalDelayValues,y
   sta targetControlHorizFracPos    ; set new fraction value
   lda targetControlHorizIntPos     ; get Target Control horizontal integer
   adc TargetControlFractionalDelayValues + 1,y
   sta targetControlHorizIntPos     ; set new integer value
.checkToMoveTargetLeft
   rol tmpJoystickValue             ; shift MOVE_LEFT value to carry
   bcs .checkToMoveTargetDown       ; branch if joystick not moved left
   sec
   lda targetControlHorizFracPos
   sbc TargetControlFractionalDelayValues,y
   sta targetControlHorizFracPos
   lda targetControlHorizIntPos
   sbc TargetControlFractionalDelayValues + 1,y
   sta targetControlHorizIntPos
.checkToMoveTargetDown
   lda targetControlVertFracPos
   rol tmpJoystickValue             ; shift MOVE_DOWN value to carry
   bcs .checkToMoveTargetUp         ; branch if joystick not moved down
   sec
   sbc TargetControlFractionalDelayValues,y
   sta targetControlVertFracPos
   lda targetControlVertIntPos
   sbc TargetControlFractionalDelayValues + 1,y
   sta targetControlVertIntPos
.checkToMoveTargetUp
   rol tmpJoystickValue             ; shift MOVE_UP value to carry
   bcs .checkTargetControlPositionBoundaries;branch if joystick not moved up
   adc TargetControlFractionalDelayValues,y
   sta targetControlVertFracPos
   lda targetControlVertIntPos
   adc TargetControlFractionalDelayValues + 1,y
   sta targetControlVertIntPos
.checkTargetControlPositionBoundaries
   ldy #XMAX_TARGET_CONTROL         ; get Target Control horizontal maximum
   cpy targetControlHorizIntPos
   bcs .checkTargetControlHorizontalMinimum;branch if within horizontal maximum
   sty targetControlHorizIntPos     ; set horizontal position to maximum
.checkTargetControlHorizontalMinimum
   ldy #XMIN_TARGET_CONTROL         ; get Target Control horizontal minimum
   cpy targetControlHorizIntPos
   bcc .checkTargetControlVerticalMinimum;branch if within horizontal minimum
   sty targetControlHorizIntPos     ; set horizontal position to minimum
.checkTargetControlVerticalMinimum
   ldy #YMIN_TARGET_CONTROL         ; get Target Control vertical minimum
   cpy targetControlVertIntPos
   bcc .checkTargetControlVerticalMaximum;branch if within vertical minimum
   sty targetControlVertIntPos      ; set vertical position to minimum
.checkTargetControlVerticalMaximum
   ldy #YMAX_TARGET_CONTROL         ; get Target Control vertical maximum
   cpy targetControlVertIntPos
   bcs .setTargetControlDisplayPositions;branch if within vertical maximum
   sty targetControlVertIntPos      ; set vertical position to maximum
.setTargetControlDisplayPositions
   lda targetControlHorizIntPos
   sta targetControlHorizPos
   lda targetControlVertIntPos
   sta targetControlScanline
   ldy alternateIBMNUSIZValue
   lda alternativeIBMValues         ; get alternate IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   beq .alternateEnemyMissileValuesForDisplay;branch if IBM
   tya                              ; move alternate IBM NUSIZ value
   ora #MSBL_SIZE2
   tay
.alternateEnemyMissileValuesForDisplay
   lda currentIBMNUSIZValue
   sty currentIBMNUSIZValue
   sta alternateIBMNUSIZValue
   lda currentIBMVertPos
   ldy alternateIBMVertPos
   sty currentIBMVertPos
   sta alternateIBMVertPos
   lda currentIBMValues             ; get current IBM value
   ldy alternativeIBMValues         ; get alternate IBM value
   sty currentIBMValues             ; set current IBM value from alternate
   sta alternativeIBMValues         ; set alternate IBM value from current
   lda currentIBMSlopeFraction
   ldy alternativeIBMSlopeFraction
   sty currentIBMSlopeFraction
   sta alternativeIBMSlopeFraction
   lda alternativeIBMHorizPos
   sta tmpActiveIBMHorizPos
   ldy currentIBMHorizPos
   sty alternativeIBMHorizPos
   sta currentIBMHorizPos
   lda currentIBMNUSIZValue         ; get current IBM NUSIZ value
   cmp #<-1
   bne MoveEnemyMissileVertically   ; branch if enemy missile active
   ldx #10
.determineToTargetRandomCity
   lda cityGraphicPointers,x        ; get City graphic pointer LSB value
   cmp #<CitySprite
   beq .targetRandomCity            ; branch if City sprite present
   dex
   dex
   bpl .determineToTargetRandomCity
   lda random                       ; get current random number value
   and #7                           ; 0 <= a <= 7
   jmp .setIBMSlopeFractionValue
   
.targetRandomCity
   lda random                       ; get current random number value
   and #7                           ; 0 <= a <= 7
   cmp #MAX_CITIES
   bcs .setIBMSlopeFractionValue
   asl                              ; multiply City value by 2
   tax
.determineCityToTarget
   lda cityGraphicPointers,x        ; get City graphic pointer LSB value
   cmp #<CitySprite
   beq .foundCityToTarget           ; branch if City sprite present
   inx
   inx
   cpx #12
   bne .determineCityToTarget
   ldx #0                           ; look again...starting at the beginning
   beq .determineCityToTarget       ; unconditional branch
   
.foundCityToTarget
   txa                              ; move City index to accumulator
   lsr                              ; divide City index by 2
.setIBMSlopeFractionValue
   sta currentIBMSlopeFraction
MoveEnemyMissileVertically
   lda frameCount                   ; get current frame count
   and #1
   tax
   lda ibmVerticalDelay,x           ; get IBM vertical delay value
   clc
   adc ibmFractionalDelay           ; increment by fractional delay
   sta ibmVerticalDelay,x           ; set IBM vertical delay value
   bcc DetermineCurrentLaunchedABMIndex;branch if not time to move missile
   lda currentIBMVertPos            ; get current IBM vertical position
   cmp #H_MISSILE_KERNEL
   beq DetermineCurrentLaunchedABMIndex
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   beq .moveEnemyMissileVertically  ; branch if not CRUISE_MISSILE
   bit gameVariation                ; check current game variation
   bvc .moveEnemyMissileVertically  ; branch if DUMB_CRUISE_MISSILES
   lda frameCount                   ; get current frame count
   and #1
   tax
   lda cruiseMissileVerticalDelay,x ; get cruise missile vertical delay value
   beq .moveEnemyMissileVertically
   inc currentIBMVertPos            ; move CRUISE_MISSILE upward
   inc currentIBMVertPos
   dec cruiseMissileVerticalDelay,x
   jmp DetermineCurrentLaunchedABMIndex
   
.moveEnemyMissileVertically
   dec currentIBMVertPos
DetermineCurrentLaunchedABMIndex
   ldx launchedABMIndex             ; get current launched ABM index
   dex                              ; decrement launched ABM index
   bpl .setCurrentLaunchedABMIndex  ; branch if no rollover
   ldx #MAX_LAUNCHED_ABM - 1
.setCurrentLaunchedABMIndex
   stx launchedABMIndex
   lda frameCount                   ; get current frame count
   and #$0F
   sta tmpMod16                     ; keep mod16 value
   asl                              ; shift to upper nybbles for color value
   asl
   asl
   asl
   ora tmpMod16                     ; combine with mod16 for luminance
   sta explodingABMColor            ; set color for exploding ABM
   ldy #<Blank
   lda launchedABMAttributes,x      ; get launched ABM attribute
   and #ABM_EXPLODING_FLAG          ; keep ABM_EXPLODING value
   beq .setActiveExplodingABMGraphicPointer;branch if ABM not exploding
   lda explodingABMAnimationIndexes,x;get exploding ABM animation index
   tax
   ldy ABMExplodingAnimationTable,x ; get ABM explosion graphic LSB value
.setActiveExplodingABMGraphicPointer
   sty activeExplosionGraphicPointer
   lda #>ABMExplosionSprites
   sta activeExplosionGraphicPointer + 1;set active exploding ABM graphic MSB
   lda explodingABMState            ; get exploding ABM state
   and #~ACTIVE_EXPLOSION_SIZE_MASK ; clear ACTIVE_EXPLOSION_SIZE value
   sta explodingABMState
   ldy #MSBL_SIZE2 | ONE_COPY
   lda #~(H_SMALL_EXPLOSION - 1)
   cpx #4
   bcc .setActiveExplosionKernelValues
   cpx #12
   bcs .setActiveExplosionKernelValues
   lda explodingABMState            ; get exploding ABM state
   ora #ACTIVE_LARGE_EXPLOSION      ; combine with ACTIVE_LARGE_EXPLOSION
   sta explodingABMState
   lda #~(H_LARGE_EXPLOSION - 1)
   ldy #MSBL_SIZE2 | DOUBLE_SIZE
.setActiveExplosionKernelValues
   sta activeExplosionHeight
   sty activeABMNUSIZValue
   ldx launchedABMIndex             ; get current launched ABM index
   lda explodingABMVertPos,x        ; get exploding ABM vertical position
   bit explodingABMState            ; check exploding ABM state
   bpl .setActiveExplosionVerticalPosition;branch if ACTIVE_SMALL_EXPLOSION
   clc
   adc #<-4
.setActiveExplosionVerticalPosition
   sta tmpActiveExplosionVertPos
   lda frameCount                   ; get current frame count
   and #7
   bne AnimateCityExplosions        ; ABM explosion animated every 8 frames
   ldx #MAX_LAUNCHED_ABM - 1
.animateABMExplosions
   inc explodingABMAnimationIndexes,x;increment ABM explosion animation index
   lda explodingABMAnimationIndexes,x;get ABM explosion animation index value
   cmp #16
   bne .animateNextABMExplosion
   lda #0
   sta launchedABMAttributes,x
   lda #XMID
   sta launchedABMHorizPositions,x
   lda #INIT_ABM_VERT_POSITION
   sta launchedABMVertPositions,x
.animateNextABMExplosion
   dex
   bpl .animateABMExplosions
AnimateCityExplosions
   ldx #10
.animateCityExplosions
   lda cityGraphicPointers,x        ; get City graphic pointer LSB value
   cmp #<CitySprite
   beq .animateNextCityExplosions   ; branch if City sprite present
   cmp DestroyedCityPointer
   beq .animateNextCityExplosions   ; branch if a destroyed City sprite
   cmp #<ProgrammerInitials
   beq .animateNextCityExplosions   ; branch if programmer initials present
   lda frameCount                   ; get current frame count
   and #$0F
   bne .animateNextCityExplosions   ; City explosions animated every 16 frames
   lda cityGraphicPointers,x        ; get City graphic pointer LSB value
   clc
   adc #H_CITY                      ; increment for explosion animation
   sta cityGraphicPointers,x        ; set new City graphic pointer LSB value
.animateNextCityExplosions
   dex
   dex
   bpl .animateCityExplosions
   lda #57 - 1
   sta objectHorizPositions         ; set to position GRP0 for six digit display
   lda #65 - 1
   sta objectHorizPositions + 1     ; set to position GRP1 for six digit display
   lda activeExplosionHeight
   sta tmpActiveExplosionHeight
   lda #0
   sta activeExplosionHeight        ; cleared so explosion sprite not positioned
   jsr PositionObjectsHorizontally
   lda tmpActiveExplosionHeight
   sta activeExplosionHeight
   ldx #0                           ; used to set left channel sound volume
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   asl                              ; multiply value by 2
   tay
   lda LeftSoundRoutineTable + 1,y
   pha                              ; push sound routine MSB to stack
   lda LeftSoundRoutineTable,y
   pha                              ; push sound routine LSB to stack
   rts                              ; call sound routine

LeftSoundRoutineTable
   .word SetLeftAudioChannelValues - 1
   .word PlayBeginningWaveAlarm - 1
   .word PlayABMExhaustionSounds - 1
   .word PlayEnemyCruiseMissileSounds - 1
   .word PlayRemainingABMTallySounds - 1
   .word PlayRemainingCitiesPointTallySounds - 1
   .word PlayBonusCitySounds - 1
   .word PlayTheEndSounds - 1
   
PlayBonusCitySounds
   lda bonusCityLeftSoundIndex      ; get Bonus City sound index value
   and #3                           ; 0 <= a <= 3
   bne .playBonusCitySounds         ; right channel frequency updated ~4 frames
   lda random                       ; get current random number value
   and #7                           ; 0 <= a <= 7
   sta rightAudioValues             ; set random frequency for right channel
.playBonusCitySounds
   ldy #SOUND_BONUS_CITY_TONE
   ldx #SOUND_BONUS_CITY_VOLUME
   lda rightAudioValues
   dec bonusCityLeftSoundIndex
   bne .setLeftAudioChannelValues
   lda #SOUND_BEGINNING_WAVE_ALARM
   sta soundEngineValues            ; set to play SOUND_BEGINNING_WAVE_ALARM
   lda #SOUND_BEGINNING_WAVE_ALARM_FREQUENCY
   sta beginningWaveAlarmFrequency
   bne .setLeftAudioChannelValues
   
PlayRemainingABMTallySounds
   dec remainingABMTallyVolume
   lda remainingABMTallyVolume
   jmp .playPointTallySounds
   
PlayRemainingCitiesPointTallySounds
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   cmp #3
   bcs .setLeftAudioChannelValues   ; branch if greater than 2
   eor #7                           ; get 3-bit 2's complement
.playPointTallySounds
   asl                              ; multiply value by 2
   tax                              ; move to x register for volume value
   ldy #SOUND_POINT_TALLY_TONE
   lda #SOUND_POINT_TALLY_FREQUENCY
   bne .setLeftAudioChannelValues
   
PlayEnemyCruiseMissileSounds
   lda frameCount                   ; get current frame count
   ldx enemyCruiseMissleVolume
   and #$1F
   bne .determineCruiseMissileSoundFrequency;branch to not increase volume
   cpx #14
   beq .determineCruiseMissileSoundFrequency;branch if reached maximum volume
   inc enemyCruiseMissleVolume
.determineCruiseMissileSoundFrequency
   lda frameCount                   ; get current frame count
   and #3                           ; 0 <= a <= 3
   ora #8                           ; 8 <= a <= 11
   ldy #SOUND_CRUISE_MISSILE_TONE
   bne SetLeftAudioChannelValues    ; unconditional branch
   
PlayABMExhaustionSounds
   ldy abmExhaustionFrequencyIndex
   lda ABMExhaustionFrequencyValues,y
   ldx #SOUND_ABM_EXHAUSTION_VOLUME
   iny
   sty abmExhaustionFrequencyIndex
   cpy #8
   beq .clearLeftSoundEngineValues
   ldy #5
   bne .setLeftAudioChannelValues   ; unconditional branch
   
.clearLeftSoundEngineValues
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_RIGHT_CHANNEL_MASK;keep right channel sound values
   sta soundEngineValues
   ldx #0
   stx leftAudioValues
.setLeftAudioChannelValues
   jmp SetLeftAudioChannelValues
   
PlayTheEndSounds
   ldy #8
   sty AUDC0
   lda frameCount                   ; get current frame count
   and #$0F
   bne .playTheEndSounds
   inc theEndLeftAudioVolume        ; volume incremented every 16 frames
   lda theEndLeftAudioVolume
   cmp #16
   bne .playTheEndSounds
   lda #SOUND_WORLD_EXPLOSION
   sta soundEngineValues            ; set to play SOUND_WORLD_EXPLOSION
   ldx #80
   stx explosionAudioValues
   beq SetLeftAudioChannelValues    ; not needed...never zero
.playTheEndSounds
   ldx theEndLeftAudioVolume
   stx AUDV0
   txa
   sta AUDF0
   eor #$FF
   jmp SetRightAudioChannelValues
   
PlayBeginningWaveAlarm
   lda waveTransitionTimerValue     ; get wave transition timer value
   cmp #WAVE_TRANSITION_INIT_TARGET_CONTROL
   bcs SetLeftAudioChannelValues
   ldx beginningWaveAlarmFrequency
   txa
   inx
   cpx #MAX_BEGINNING_WAVE_ALARM_FREQUENCY
   bne .setBeginningWaveAlarmFrequency
   ldx #SOUND_BEGINNING_WAVE_ALARM_FREQUENCY
.setBeginningWaveAlarmFrequency
   stx beginningWaveAlarmFrequency
   ldy #12
   ldx #8
SetLeftAudioChannelValues
   stx AUDV0
   sty AUDC0
   sta AUDF0
   ldx #0                           ; used to set right channel sound volume
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_RIGHT_CHANNEL_MASK;keep right channel sound values
   cmp #SOUND_ABM_LAUNCHING
   beq PlayABMLaunchingSound        ; branch if playing SOUND_ABM_LAUNCHING
   cmp #SOUND_ABM_EXPLODING
   beq PlayABMExplodingSound        ; branch if playing SOUND_ABM_EXPLODING
   cmp #SOUND_WORLD_EXPLOSION
   bcs PlayWorldOrCityExplosionSound; branch if playing world or city explosion
   jmp SetRightAudioChannelValues
   
PlayWorldOrCityExplosionSound
   dec explosionAudioValues
   beq .clearRightSoundEngineValues
   lda explosionAudioValues
   and #$70
   lsr
   lsr
   lsr
   lsr
   tay
   ldx WorldOrCityExplosionVolumeValues,y
   ldy #8
   lda explosionAudioValues
   and #$0F
   ora #16
   bne SetRightAudioChannelValues   ; unconditional branch
   
WorldOrCityExplosionVolumeValues
   .byte 2, 4, 6, 8, 14
   
PlayABMLaunchingSound
   ldy #SOUND_ABM_LAUNCHING_TONE
   ldx #SOUND_ABM_LAUNCHING_VOLUME
   lda frameCount                   ; get current frame count
   and #3
   bne .checkIfDonePlayingABMLaunchingSound
   dec abmLaunchingSoundIndex       ; sound index decremented every 4 frames
   beq .clearRightSoundEngineValues
.checkIfDonePlayingABMLaunchingSound
   lda abmLaunchingSoundIndex
   bne SetRightAudioChannelValues
.clearRightSoundEngineValues
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   sta soundEngineValues
   bit gameOptions
   bpl .setRightAudioChannelValues  ; branch if not WORLD_EXPLOSION
   lda #GAME_OVER | RESET_RELEASED | 3
   sta gameState
   lda #0
   sta gameOptions                  ; clear game option values
   sta waveNumber                   ; reset wave number
   sta colorCycleMode
.setRightAudioChannelValues
   jmp SetRightAudioChannelValues
   
PlayABMExplodingSound
   ldy explodingABMVolumeIndex
   ldx ExplodingABMVolumeValues,y
   lda frameCount                   ; get current frame count
   and #7
   bne .playABMExplodingSound
   iny
   sty explodingABMVolumeIndex
   cpy #16
   beq .clearRightSoundEngineValues
.playABMExplodingSound
   lda #$1F
   ldy #8
SetRightAudioChannelValues
   stx AUDV1
   sty AUDC1
   sta AUDF1
   ldy #0
   ldx #$0F                         ; hue mask for B/W mode
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   beq .determineColorHueMaskValues ; branch if set to B&W
   ldx #$FF                         ; hue mask for COLOR mode
.determineColorHueMaskValues
   bit gameState                    ; check current game state
   bpl .setColorHueMask             ; branch if not GAME_OVER
   txa                              ; move hue mask value to accumulator
   and #$F7                         ; mask for VCS colors
   tax                              ; move hue mask to x register
   ldy #$FF
.setColorHueMask
   stx hueMask
   tya
   and colorCycleMode
   sta tmpColorXOR
   ldx #0
   ldy #0
   lda waveNumber                   ; get current wave number
   cmp #255
   beq .setObjectColors
   and #$0E                         ; 0 <= a <= 14
   lsr                              ; divide value by 2
   sta tmpColorTableIndexMulti
   asl                              ; multiply value by 4
   asl
   clc                              ; not needed...carry clear from shifting
   adc tmpColorTableIndexMulti      ; multiply * 5 [i.e. x * 5 = (x * 4) + x]
   tay
.setObjectColors
   lda GameColorTable,y             ; get game color values for wave
   eor tmpColorXOR                  ; flip color bits for color cycling
   and hueMask                      ; mask color values for COLOR / B&W mode
   sta objectColorValues,x          ; set object color value
   inx
   iny
   cpx #5
   bne .setObjectColors
   bit gameOptions
   bmi DisplayGameSelectionValues   ; branch if WORLD_EXPLOSION
   ldy soundEngineValues            ; get sound engine values
   cpy #SOUND_WORLD_EXPLOSION
   bcc DisplayGameSelectionValues   ; branch if world or city not exploding
   lda explosionAudioValues
   and hueMask
   cpy #SOUND_CITY_EXPLOSION
   bcc .setMissileBaseColorValue    ; branch if SOUND_WORLD_EXPLOSION
   sta cityColor
   bcs DisplayGameSelectionValues   ; unconditional branch
   
.setMissileBaseColorValue
   sta missileBaseColor
DisplayGameSelectionValues
   ldx currentPlayerNumber          ; get the current player number
   lda gameState                    ; get current game state
   and #GAME_SELECTION_SCREEN
   beq ConvertBCDToDigitPointers    ; branch if game in progress
   lda gameSelection                ; get current game selection
   sta playerScore + 4,x            ; place in score ten thousands value
   ldy #$00
   sty playerScore + 2,x            ; place in score hundreds value
   iny                              ; increment for number of players value
   cmp #$18
   bcc .setNumberOfPlayersValue     ; branch if ONE_PLAYER_GAME
   iny                              ; y = 2
.setNumberOfPlayersValue
   sty playerScore,x
ConvertBCDToDigitPointers
   lda playerScore + 4,x            ; get score ten thousands value
   jsr ShiftMSBToLSB                ; shift upper nybbles to lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers         ; set digit graphic pointer LSB value
   lda playerScore + 4,x            ; get score ten thousands value
   and #$0F                         ; keep lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers + 2     ; set digit graphic pointer LSB value
   lda playerScore + 2,x            ; get score hundreds value
   jsr ShiftMSBToLSB                ; shift upper nybbles to lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers + 4     ; set digit graphic pointer LSB value
   lda playerScore + 2,x            ; get score hundreds value
   and #$0F                         ; keep lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers + 6     ; set digit graphic pointer LSB value
   lda playerScore,x                ; get score ones value
   jsr ShiftMSBToLSB                ; shift upper nybbles to lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers + 8     ; set digit graphic pointer LSB value
   lda playerScore,x                ; get score ones value
   and #$0F                         ; keep lower nybbles
   tay
   lda NumberTable,y                ; get graphic LSB value
   sta digitGraphicPointers + 10    ; set digit graphic pointer LSB value
   ldx #0
   ldy #<Blank
.suppressZeroLoop
   lda digitGraphicPointers,x       ; cycle through the graphics pointers to
   cmp #<zero                       ; find one that points to zero
   bne .checkToDisplayGameSelectionValues
   sty digitGraphicPointers,x       ; set the LSB to point to the space
   inx                              ; increment x by 2 to get the next LSB value
   inx
   cpx #10
   bne .suppressZeroLoop
.checkToDisplayGameSelectionValues
   lda gameState                    ; get current game state
   and #GAME_SELECTION_SCREEN       ; check to see if player selecting game variation
   beq .checkToSetSkyExplosionColors; branch if game in progress
   sty digitGraphicPointers + 6
   sty digitGraphicPointers + 4
   sty digitGraphicPointers + 8
.checkToSetSkyExplosionColors
   lda explodingABMColor
   and hueMask
   sta explodingABMColor
   bit gameOptions
   bpl .setDigitColorValues         ; branch if not WORLD_EXPLOSION
   lda soundEngineValues            ; get sound engine values
   cmp #SOUND_WORLD_EXPLOSION
   bne .setDigitColorValues         ; branch if not SOUND_WORLD_EXPLOSION
   lda explosionAudioValues
   and hueMask
   sta skyColor
.setDigitColorValues
   lda scoreColor
   eor tmpColorXOR
   and hueMask
   sta COLUP0
   sta COLUP1
   lda #THREE_COPIES
   sta NUSIZ1
   sta VDELP0                       ; vertical delay GRP0 (D0 = 1)
   sta VDELP1                       ; vertical delay GRP1 (D0 = 1)
   lda skyColor
   sta COLUBK
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   sta tmpEnemyMissileSlopeIntegerValue;3 clear slope integer value
   sta HMM0                   ; 3 = @09
   sta HMM1                   ; 3 = @12
   sta HMBL                   ; 3 = @15
   lda #H_FONT - 1            ; 2
   sta tmpLoopCount           ; 3
.drawDigits
   ldy tmpLoopCount           ; 3
   lda (digitGraphicPointers),y;5
   sta GRP0                   ; 3
   sta WSYNC
;--------------------------------------
   lda (digitGraphicPointers + 2),y;5
   sta GRP1                   ; 3 = @08
   lda (digitGraphicPointers + 4),y;5
   sta GRP0                   ; 3 = @16
   lda (digitGraphicPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (digitGraphicPointers + 8),y;5
   tax                        ; 2
   lda (digitGraphicPointers + 10),y;5
   tay                        ; 2
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @44
   stx GRP0                   ; 3 = @47
   sty GRP1                   ; 3 = @50
   sty GRP0                   ; 3 = @53
   dec tmpLoopCount           ; 5
   bpl .drawDigits            ; 2³
   sta WSYNC
;--------------------------------------
   ldy #0                     ; 2
   sty VDELP0                 ; 3 = @05
   sty VDELP1                 ; 3 = @08
   sty GRP0                   ; 3 = @11
   sty GRP1                   ; 3 = @14
   ldy #MSBL_SIZE4 | PF_REFLECT;2
   sty CTRLPF                 ; 3 = @19
   lda frameCount             ; 3         get current frame count
   and #$0F                   ; 2
   sta COLUPF                 ; 3
   sta WSYNC
;--------------------------------------
   lda ibmColor               ; 3
   sta COLUP0                 ; 3 = @06
   lda skyColor               ; 3
   sta COLUBK                 ; 3 = @12
   lda explodingABMColor      ; 3
   sta COLUP1                 ; 3 = @18
   ldy scoreColor             ; 3
   lda currentIBMValues       ; 3         get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK;2         keep ENEMY_MISSILE_TYPE value
   bne .setExplodingABMColorValue;2³      branch if CRUISE_MISSILE
   tay                        ; 2         y = 0
   lda frameCount             ; 3         get current frame count
   and #8                     ; 2
   bne .setExplodingABMColorValue;2³
   ldy #$0F                   ; 2
.setExplodingABMColorValue
   tya                        ; 2
   and hueMask                ; 3
   sta explodingABMColor      ; 3
   ldx launchedABMIndex       ; 3         get current launched ABM index
   lda explodingABMHorizPos,x ; 4
   sta activeExplodingABMHorizPos;3
   lda currentIBMNUSIZValue   ; 3         get current IBM NUSIZ value
   sta NUSIZ0                 ; 3 = @63
   lda activeABMNUSIZValue    ; 3
   sta NUSIZ1                 ; 3 = @72
   ldx #<[activeExplodingABMHorizPos - objectHorizPositions];2
   lda #54                    ; 2
   sta TIM8T                  ; 4         set to expire after ~5 scan lines
   jsr .positionObjectsHorizontally;6
;--------------------------------------
   lda #HMOVE_0               ; 2
   sta HMP1                   ; 3 = @11
.missileKernelWait
   lda INTIM                  ; 4
   bne .missileKernelWait     ; 2³
   ldx #H_MISSILE_KERNEL - 1  ; 2
.missileKernelLoop
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #ENABLE_BM             ; 2
   cpx currentIBMVertPos      ; 3
   bne .checkToDrawIBMOrCruiseMissile;2³
   ldy explodingABMColor      ; 3
   sty COLUP0                 ; 3
   bne .drawEnemyMissile      ; 3         unconditional branch
   
.checkToDrawIBMOrCruiseMissile
   bit currentIBMValues       ; 3
   bne .disableEnemyMissile   ; 2³        branch if CRUISE_MISSILE
   bcs .drawEnemyMissile      ; 2³
.disableEnemyMissile
   lda #DISABLE_BM            ; 2
.drawEnemyMissile
   sta ENAM0                  ; 3         enable / disable enemy missile
   lda tmpEnemyMissileSlopeIntegerValue;3 get enemy missile slope integer value
   clc                        ; 2
   adc currentIBMSlopeFraction; 3         increment by slope fraction value
   sta tmpEnemyMissileSlopeIntegerValue;3 set enemy missile slope integer value
   ldy #HMOVE_0               ; 2         assume no horizontal move
   bcc .setEnemyMissileSlopeRunValue;2³
   ldy currentIBMValues       ; 3         get current IBM value
.setEnemyMissileSlopeRunValue
   sty HMM0                   ; 3         set to adjust enemy missile run value
   sta WSYNC
;--------------------------------------
   lda #DISABLE_BM            ; 2         assume target not on current scanline
   cpx targetControlScanline  ; 3
   bne .drawTargetControl     ; 2³
   lda #ENABLE_BM             ; 2         enable BALL to draw target control
.drawTargetControl
   sta ENABL                  ; 3 = @12
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc tmpActiveExplosionVertPos;3
   tay                        ; 2
   bit explodingABMState      ; 3         check exploding ABM state
   bpl .checkToDrawActiveExplosion;2³     branch if ACTIVE_SMALL_EXPLOSION
   lsr                        ; 2         divide by 2 (i.e. DOUBLE_HEIGHT)
   tay                        ; 2
   asl                        ; 2         restore difference value
.checkToDrawActiveExplosion
   and activeExplosionHeight  ; 3
   bne .skipABMExplosionDraw  ; 2³        branch to not draw ABM explosion
   lda (activeExplosionGraphicPointer),y;5
   jmp .drawABMExplosion      ; 3
   
.skipABMExplosionDraw
   lda #0                     ; 2
.drawABMExplosion
   sta GRP1                   ; 3 = @48
   lda #DISABLE_BM            ; 2
   cpx activeABMVertPos       ; 3
   bne .drawActiveABM         ; 2³
   lda #ENABLE_BM             ; 2
.drawActiveABM
   sta ENAM1                  ; 3 = @60
   dex                        ; 2
   bne .missileKernelLoop     ; 2³
   sta WSYNC
;--------------------------------------
   ldx #ENABLE_BM             ; 2
   lda activeABMVertPos       ; 3
   cmp #1                     ; 2
   beq .cityKernelDrawActiveABM;2³
   ldx #DISABLE_BM            ; 2
   jmp .setABMDrawingStateCityKernel;3
   
.cityKernelDrawActiveABM
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.setABMDrawingStateCityKernel
   stx ENAM1                  ; 3 = @17
   lda #DISABLE_BM            ; 2
   sta ENAM0                  ; 3 = @22
   sta ENAM0                  ; 3 = @25
   sta RESP0                  ; 3 = @28
   lda missileBaseColor       ; 3
   sta COLUPF                 ; 3 = @34
   lda cityColor              ; 3
   sta COLUP0                 ; 3 = @40
   sta COLUP1                 ; 3 = @43
   sta COLUP1                 ; 3 = @46
   ldy #H_CITY - 1            ; 2
   lda #$30                   ; 2
   ldx #$84                   ; 2         value not needed...wastes 2 cycles
   sta RESP1                  ; 3 = @65
   sty ENAM1                  ; 3 = @68
   sta PF0                    ; 3 = @71
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @76
;--------------------------------------
   sta NUSIZ1                 ; 3 = @03
.drawCitiesLoop
   sta WSYNC
;--------------------------------------
   lda LaunchingMissileBase,y ; 4
   sta PF2                    ; 3 = @07
   lda (_3rdCityGraphicPointer),y;5
   tax                        ; 2
   lda (_1stCityGraphicPointer),y;5
   sta GRP0                   ; 3 = @22
   lda (_2ndCityGraphicPointer),y;5
   SLEEP 2                    ; 2
   sta GRP0                   ; 3 = @32
   lda RESP0                  ; 3         waste 3 cycles
   stx GRP0                   ; 3 = @38
   lda (_6thCityGraphicPointer),y;5
   tax                        ; 2
   lda (_4thCityGraphicPointer),y;5
   sta GRP1                   ; 3 = @53
   lda (_5thCityGraphicPointer),y;5
   sta GRP1                   ; 3 = @61
   SLEEP 2                    ; 2
   stx GRP1                   ; 3 = @66
   dey                        ; 2
   bpl .drawCitiesLoop        ; 2³
   sta WSYNC
;--------------------------------------
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ1                 ; 3 = @05
   lda missileBaseColor       ; 3
   sta COLUBK                 ; 3 = @11
   sta COLUBK                 ; 3 = @14
   lda #0                     ; 2
   sta PF2                    ; 3 = @19
   sta PF0                    ; 3 = @22
   sta GRP0                   ; 3 = @25
   ldy launchingBaseABMs      ; 3         get number of ABMs at missile base
   lda MissilePointerTable,y  ; 4
   sta missileGraphicsPointer ; 3
   lda #>MissileGraphics      ; 2
   sta missileGraphicsPointer + 1;3
   ldy #H_MISSILE_BASE - 1    ; 2
   sta RESP1                  ; 3 = @45
   lda skyColor               ; 3
   sta COLUP1                 ; 3 = @51
   sta COLUPF                 ; 3 = @54
   lda gameState              ; 3         get current game state
   and #RESERVED_MISSILE_DUMP_MASK;2      keep used missile dump count
   tax                        ; 2
.drawReservedMissileDump
   sta WSYNC
;--------------------------------------
   lda (missileGraphicsPointer),y;5
   sta GRP1                   ; 3 = @08
   lda ReservedMissileDumpGraphicValues,x;4
   sta PF0                    ; 3 = @15
   jsr ShiftMSBToLSB          ; 6
   sta PF0                    ; 3 = @40
   dey                        ; 2
   bpl .drawReservedMissileDump;2³
   sta WSYNC
;--------------------------------------
   lda missileBaseColor       ; 3
   sta COLUBK                 ; 3 = @06
   lda #OVERSCAN_TIME         ; 2
   sta TIM64T                 ; 4
   iny                        ; 2         y = 0
   sty GRP1                   ; 3 = @17
   lda currentIBMNUSIZValue         ; get current IBM NUSIZ value
   cmp #<-1
   bne DetermineIBMCollisions       ; branch if enemy missile active
   bit waveTransitionTimerValue     ; check wave transition timer value
   bmi DetermineIBMCollisions       ; branch if transitioning waves
   jsr SpawnNextGroupOfMissiles
   bcc .nextFrame                   ; branch if missile spawned
   lda alternateIBMVertPos          ; get alternate IBM vertical position
   cmp #H_MISSILE_KERNEL
   bne .nextFrame                   ; branch if alternate IBM present
   jsr SetCityArrayValues
.nextFrame
   jmp .overscanWait
   
DetermineIBMCollisions
   ldy currentIBMVertPos            ; get current IBM vertical position
   bne DetermineIfIBMCollidedWithExplosion
   jsr DetermineIBMCollisionWithPlanetObjects
   jmp .overscanWait
   
DetermineIfIBMCollidedWithExplosion
   and #7                           ; keep object size value
   tax                              ; move object NUSIZ value to x register
   lda MaximumMissileCountValues,x  ; get maximum missile count for NUSIZ value
   sta tmpMissileIndex
   ldy IBMHorizOffsetIndexValues,x
   lda IBMHorizOffsetPointerValues,y
   sta ibmHorizOffsetPointer
   lda IBMHorizOffsetPointerValues + 1,y
   sta ibmHorizOffsetPointer + 1
   lda #H_MISSILE_KERNEL - 1        ; get IBM starting vertical position
   sec
   sbc currentIBMVertPos            ; subtract current IBM vertical position
   sta tmpDeltaY
   lda currentIBMSlopeFraction
   sta tmpIBMSlopeFraction
   jsr DetermineIBMHorizontalAdjustmentValue
.determineIfIBMCollidedWithExplosion
   ldy tmpMissileIndex
   lda currentIBMHorizPos           ; get current IBM horizontal position
   clc
   adc (ibmHorizOffsetPointer),y    ; increment by missile index offset
   ldy currentIBMVertPos            ; get current IBM vertical position
   sty tmpEnemyMissileVertPos
   ldy currentIBMValues             ; get current IBM value
   cpy #HMOVE_R1 | ENEMY_MISSILE_TYPE_IBM
   bcc .adjustLeftTravelingIBMHorizPosition;branch if traveling left
   clc
   adc tmpIBMHorizAdjustment        ; adjustment for right traveling IBM
   jmp .determineABMAndIBMCollisionBoxArea
   
.adjustLeftTravelingIBMHorizPosition
   sec
   sbc tmpIBMHorizAdjustment
.determineABMAndIBMCollisionBoxArea
   sta tmpIBMHorizPosition
   ldx launchedABMIndex             ; get current launched ABM index
   lda launchedABMAttributes,x      ; get launched ABM attribute
   and #ABM_EXPLODING_FLAG          ; keep ABM_EXPLODING value
   beq .doneCheckExplosionDestroyingEnemyMissile;branch if ABM not exploding
   ldy launchedABMVertPositions,x   ; get launched ABM vertical position
   lda launchedABMHorizPositions,x  ; get launched ABM horizontal position
   tax
   jsr ComputeABMAndIBMCollsionBoxArea
   sta tmpCollisionBoxArea
   ldx launchedABMIndex             ; get current launched ABM index
   ldy explodingABMAnimationIndexes,x;get ABM explosion animation index value
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   beq .checkMissileInExplosionArea ; branch if IBM
   bit gameVariation                ; check current game variation
   bvc .checkMissileInExplosionArea ; branch if DUMB_CRUISE_MISSILES
   lda ExplosionBoundingBoxArea,y   ; get explosion bounding box area
   cmp tmpCollisionBoxArea
   bcc .doneCheckExplosionDestroyingEnemyMissile
   lda tmpCollisionBoxArea          ; get collision box area
   cmp #3
   bcc ScorePointsForDestroyingEnemyMissile;branch if cruise missile within range
   lda frameCount                   ; get current frame count
   and #1
   tax
   lda #2
   sta cruiseMissileVerticalDelay,x ; set cruise missile vertical delay value
   bne .doneCheckExplosionDestroyingEnemyMissile;unconditional branch
   
   .byte $90, $07                   ; two unreferenced bytes...never executed
   
.checkMissileInExplosionArea
   lda ExplosionBoundingBoxArea,y   ; get explosion bounding box area
   cmp tmpCollisionBoxArea
   bcs ScorePointsForDestroyingEnemyMissile
.doneCheckExplosionDestroyingEnemyMissile
   jmp .checkNextIBMForExplosionCollision
   
ScorePointsForDestroyingEnemyMissile
   ldy #>IBM_POINTS
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   beq .scorePointsForDestroyingEnemyMissile;branch if IBM
   iny                              ; increment for CRUISE_MISSILE
.scorePointsForDestroyingEnemyMissile
   lda #<(IBM_POINTS | ENEMY_CRUISE_MISSILE_POINTS)
   jsr IncrementScore
   lda soundEngineValues            ; get sound engine values
   cmp #SOUND_WORLD_EXPLOSION
   bcs .advanceIBMPointer
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   ora #SOUND_ABM_EXPLODING
   sta soundEngineValues            ; set to play SOUND_ABM_EXPLODING
   lda #0
   sta explodingABMVolumeIndex
.advanceIBMPointer
   lda ibmHorizOffsetPointer
   clc
   adc #13
   sta ibmNUSIZPointer
   ldy tmpMissileIndex
   lda (ibmNUSIZPointer),y
   sta currentIBMNUSIZValue         ; set current IBM NUSIZ value
   cmp #<-1
   bne .prepareCheckNextIBMForExplosionCollision;branch if enemy missile active
   lda #H_MISSILE_KERNEL + 1
   sta currentIBMVertPos
   bne .overscanWait                ; unconditional branch
   
.prepareCheckNextIBMForExplosionCollision
   lda ibmNUSIZPointer
   clc
   adc #13
   sta ibmHorizPositionPointer
   lda currentIBMHorizPos
   clc
   adc (ibmHorizPositionPointer),y
   sta currentIBMHorizPos
   lda ibmHorizOffsetPointer        ; get IBM offset pointer LSB value
   sec
   sbc #(13 * 2)                    ; subtract increment to restore value
   sta ibmHorizOffsetPointer
.checkNextIBMForExplosionCollision
   dec tmpMissileIndex
   bmi .overscanWait
   jmp .determineIfIBMCollidedWithExplosion
   
.overscanWait
   lda INTIM
   bne .overscanWait
   lda #DISABLE_TIA
   sta WSYNC                        ; wait for next scanline
   sta VBLANK                       ; disable TIA (D1 = 1)
   lda #BLACK
   sta COLUBK                       ; set background color to BLACK
   jmp MainLoop
   
SpawnNextGroupOfMissiles
   ldy #HMOVE_0 | ENEMY_MISSILE_TYPE_IBM
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   beq .determineTypeOfMissileToSpawn;branch if IBM
   lda alternativeIBMValues         ; get alternate IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   bne .determineTypeOfMissileToSpawn;branch if alternate IBM is CRUISE_MISSILE
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_RIGHT_CHANNEL_MASK;keep right channel sound values
   sta soundEngineValues
.determineTypeOfMissileToSpawn
   sty currentIBMValues
   bit waveTransitionTimerValue     ; check wave transition timer value
   bmi .setInitialIBMVerticalPosition;branch if transitioning waves
   lda remainingWaveIBMs            ; get remaining wave IBMs
   bne .spawnEnemyMissileOrCruiseMissile;branch if IBMs remaining for wave
   lda remainingWaveCruiseMissiles  ; get remaining wave cruise missiles
   bne .spawnEnemyCruiseMissile     ; branch if cruise missiles remaining
.setInitialIBMVerticalPosition
   lda #H_MISSILE_KERNEL
   sta currentIBMVertPos
   sec                              ; set to show no missile spawned
   rts

.spawnEnemyCruiseMissile
   ldy #INIT_CRUISE_MISSILE_VOLUME
   sty enemyCruiseMissleVolume
   ldy #<-1
   sty currentIBMValues             ; set to show IBM not active
   lda frameCount                   ; get current frame count
   and #1
   tax
   iny                              ; y = 0
   sty cruiseMissileVerticalDelay,x
   dec remainingWaveCruiseMissiles  ; decrement remaining cruise missile count
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_RIGHT_CHANNEL_MASK;keep right channel sound values
   ora #SOUND_ENEMY_CRUISE_MISSILE
   sta soundEngineValues            ; set to play SOUND_ENEMY_CRUISE_MISSILE
   bne .spawnEnemyMissiles          ; unconditional branch
   
.spawnEnemyMissileOrCruiseMissile
   lda random                       ; get current random number value
   and #$18
   bne .spawnEnemyMissiles
   lda remainingWaveCruiseMissiles  ; get remaining wave cruise missiles
   bne .spawnEnemyCruiseMissile     ; branch if cruise missiles remaining
.spawnEnemyMissiles
   ldy currentIBMSlopeFraction
   lda ObjectHorizontalPositionValues,y
   sta tmpEnemyTargetPosition
   bit currentIBMValues
   bmi .spawnSingleIBM              ; branch if spawning ENEMY_MISSILE_TYPE_CRUISE
   lda remainingWaveIBMs            ; get remaining wave IBMs
   cmp #4
   bcs .determineSpawnedIBMNUSIZValue;branch if more than 3 IBMs remaining
   tay                              ; 1 <= y <= 3
   lda IBMFinalGroupingNUSIZValues,y; get NUSIZ values for final IBM grouping
   jmp .setEnemyMissileNUSIZValue
   
.determineSpawnedIBMNUSIZValue
   cpy #6
   bcc DetermineSpawnedIBMNUSIZValue; branch if IBM targeting cities
.spawnSingleIBM
   lda #MSBL_SIZE1 | ONE_COPY
   beq .setEnemyMissileNUSIZValue
   
DetermineSpawnedIBMNUSIZValue
   lda random                       ; get current random number value
   lsr                              ; divide value by 8
   lsr
   lsr
   and #7                           ; 0 <= a <= 7
   tay
   lda InitialIBMNUSIZValues,y
.setEnemyMissileNUSIZValue
   tay                              ; move missile NUSIZ value to y register
   sta currentIBMNUSIZValue
   lda IBMGroupingFarthestOffsetValues,y
   sta tmpIBMFarthestOffsetValue
   lda random                       ; get current random number value
   cmp #XMAX + 1
   bcc .checkIfFarthestGroupedIBMOutOfRange;branch if within horizontal range
   lsr                              ; divide value by 2 (i.e. 0 <= a <= 79)
.checkIfFarthestGroupedIBMOutOfRange
   clc
   adc tmpIBMFarthestOffsetValue    ; increment by farthest IBM offset value
   cmp #XMAX + 1
   bcc .setSpawnedIBMHorizontalPosition;branch if within horizontal range
   lsr                              ; divide value by 2 (i.e. 0 <= a <= 79)
.setSpawnedIBMHorizontalPosition
   sec
   sbc tmpIBMFarthestOffsetValue    ; subtract farthest IBM offset value
   sta currentIBMHorizPos           ; set IBM horizontal position
   cmp tmpEnemyTargetPosition
   bcs .setEnemyMissileToTravelLeft ; branch if starting right of target
   clc
   adc tmpIBMFarthestOffsetValue    ; increment by farthest IBM offset value
   cmp tmpEnemyTargetPosition       ; compare farthest IBM with target position
   bcc .farthestIBMLeftOfTarget     ; branch if left of target
   lda tmpEnemyTargetPosition       ; get target position value
   clc
   adc tmpIBMFarthestOffsetValue    ; increment by farthest IBM offset value
   cmp #XMAX + 1
   bcs .checkForFarthestIBMToTargetObject;branch if not within range
   lda tmpIBMFarthestOffsetValue    ; get farthest IBM offset value
   lsr                              ; divide value by 2
   clc
   adc currentIBMHorizPos           ; increment by IBM horizontal position
   cmp tmpEnemyTargetPosition
   bcs .setEnemyMissileToTravelRight;branch if to the right of target
.checkForFarthestIBMToTargetObject
   lda tmpEnemyTargetPosition       ; get target position value
   cmp tmpIBMFarthestOffsetValue    ; compare with farthest IBM offset value
   bcc .setEnemyMissileToTravelRight
   ldx #HMOVE_L1
.setFarthestIBMToTargetObject
   lda tmpIBMFarthestOffsetValue    ; get farthest IBM offset value
   clc
   adc currentIBMHorizPos           ; increment by IBM horizontal position
   bne .setEnemyMissileHorizontalDirectionValue;unconditional branch
   
.setEnemyMissileToTravelRight
   ldx #HMOVE_R1
   lda currentIBMHorizPos           ; left most IBM to target object
   jmp .setEnemyMissileHorizontalDirectionValue
   
.farthestIBMLeftOfTarget
   ldx #HMOVE_R1
   bne .setFarthestIBMToTargetObject; unconditional branch
   
.setEnemyMissileToTravelLeft
   ldx #HMOVE_L1
   lda currentIBMHorizPos           ; left most IBM to target object
.setEnemyMissileHorizontalDirectionValue
   stx tmpIBMDirectionValue
   tax                              ; move IBM horizontal position to x register
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   ora tmpIBMDirectionValue         ; combine with IBM direction value
   sta currentIBMValues             ; set new IBM value
   txa                              ; move IBM horizontal position to accumulator
   ldy #H_MISSILE_KERNEL - 1
   sty currentIBMVertPos            ; set IBM starting vertical position
   sec
   sbc tmpEnemyTargetPosition       ; subtract to get horizontal distance
   bcs .determineSpawnedIBMSlope
   eor #$FF
   adc #1
.determineSpawnedIBMSlope
   sty tmpCurrentIBMVertPos
   jsr DetermineIBMTargetEndPointDifference
   stx tmpIBMHorizAdjustment
   ldx #0
   sta tmpIBMDeltaX
   jsr DetermineSpawnedIBMSlope
   stx tmpSpawnedIBMSlopeFraction
   jmp .setSpawnedMissileGroupValues
   
DetermineIBMTargetEndPointDifference
   sta tmpIBMDeltaX
   lda #0
DetermineSpawnedIBMSlope
   ldy #7
.determineIBMHorizDistFromTarget
   rol tmpIBMDeltaX                 ; multiply by 2 (carry set if > 127)
   rol                              ; 2x + C
   bcs .addInError
   cmp tmpCurrentIBMVertPos
   bcc .nextIteration               ; branch if not reached vertical target
   sbc tmpCurrentIBMVertPos         ; subtract vertical target position
.nextIteration
   dey
   bpl .determineIBMHorizDistFromTarget
   rol tmpIBMDeltaX                 ; multiply by 2 plus carry
   ldx tmpIBMDeltaX
   rts

.addInError
   sbc tmpCurrentIBMVertPos         ; subtract vertical target position
   sec                              ; set to increment horiz distance by 1
   bcs .nextIteration               ; unconditional branch
   
.setSpawnedMissileGroupValues
   lda tmpSpawnedIBMSlopeFraction
   sta currentIBMSlopeFraction
   lda currentIBMValues             ; get current IBM value
   and #ENEMY_MISSILE_TYPE_MASK     ; keep ENEMY_MISSILE_TYPE value
   bne .doneSpawnNextGroupOfMissiles; branch if CRUISE_MISSILE
   ldy currentIBMNUSIZValue         ; get current IBM NUSIZ value
   lda remainingWaveIBMs            ; get remaining wave IBMs
   clc                              ; clear carry
   sbc MaximumMissileCountValues,y  ; subtract missile count for size plus one
   sta remainingWaveIBMs            ; set remaining wave IBMs
.doneSpawnNextGroupOfMissiles
   clc
   rts

DetermineIBMCollisionWithPlanetObjects
   lda currentIBMNUSIZValue         ; get current IBM NUSIZ value
   and #7                           ; keep object size value
   tay
   lda MaximumMissileCountValues,y  ; get maximum missile count for NUSIZ value
   sta tmpMaximumMissileCount
   lda IBMHorizOffsetIndexValues,y
   tay
   lda IBMHorizOffsetPointerValues,y
   sta ibmHorizOffsetPointer
   lda IBMHorizOffsetPointerValues + 1,y
   sta ibmHorizOffsetPointer + 1
   lda #H_MISSILE_KERNEL - 1        ; get IBM starting vertical position
   sta tmpDeltaY
   lda currentIBMSlopeFraction
   sta tmpIBMSlopeFraction
   jsr DetermineIBMHorizontalAdjustmentValue
.determineIfIBMCollidedWithPlanetObjects
   ldy tmpMaximumMissileCount
   lda currentIBMHorizPos
   clc
   adc (ibmHorizOffsetPointer),y
   ldx currentIBMValues             ; get current IBM value
   cpx #HMOVE_R1 | ENEMY_MISSILE_TYPE_IBM
   bcs .adjustRightTravelingIBMHorizPosition;branch if traveling right
   sec
   sbc tmpIBMHorizAdjustment        ; adjustment for left traveling IBM
   jmp .determinePlanetObjectAndIBMCollisionBoxArea
   
.adjustRightTravelingIBMHorizPosition
   clc
   adc tmpIBMHorizAdjustment
.determinePlanetObjectAndIBMCollisionBoxArea
   sta tmpIBMPlanetCollisionHorizPosition
   ldy #0
.determineEnemyMissileObjectCollision
   lda ObjectHorizontalPositionValues,y;get object horizontal position
   sec
   sbc #4
   cmp tmpIBMPlanetCollisionHorizPosition
   bcs .checkNextObjectCollision    ; branch if IBM left of Planet object
   adc #8
   cmp tmpIBMPlanetCollisionHorizPosition
   bcs .enemyMissileCollidedWithTarget;branch if IBM hit Planet object
.checkNextObjectCollision
   iny
   cpy #7
   bne .determineEnemyMissileObjectCollision
   jmp .checkNextMissile
   
.enemyMissileCollidedWithTarget
   cpy #6
   bne .enemyDestroyedCity          ; branch if not collided with Missile Base
   lda #32
   sta abmMoveFromReserveDelay      ; set delay to move ABMs from reserve
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   ora #SOUND_WORLD_EXPLOSION
   sta soundEngineValues            ; set to play SOUND_WORLD_EXPLOSION
   lda #80
   sta explosionAudioValues
   lda #0
   sta launchingBaseABMs            ; clear number of ABMs left at launch base
   beq .checkNextMissile            ; unconditional branch
   
.enemyDestroyedCity
   tya                              ; move city position index to accumulator
   asl                              ; multiply value by 2
   tax                              ; set to read city graphic data
   ldy CityExplosionSpritePointerValues_2;get CityExplosion_2 LSB value
   lda cityGraphicPointers,x        ; get city graphic pointer LSB value
   cmp DestroyedCityPointer
   beq .setDestroyedCityLSBValue    ; branch if a destroyed city sprite
   ldy CityExplosionSpritePointerValues_0; get CityExplosion_0 LSB value
   lda soundEngineValues            ; get sound engine values
   and #SOUND_ENGINE_LEFT_CHANNEL_MASK;keep left channel sound values
   ora #SOUND_CITY_EXPLOSION
   sta soundEngineValues            ; set to play SOUND_CITY_EXPLOSION
   lda #80
   sta explosionAudioValues
.setDestroyedCityLSBValue
   sty cityGraphicPointers,x
.checkNextMissile
   dec tmpMaximumMissileCount
   bpl .determineIfIBMCollidedWithPlanetObjects
   lda #<-1
   sta currentIBMNUSIZValue
   lda #H_MISSILE_KERNEL + 1
   sta currentIBMVertPos
   rts

ComputeABMAndIBMCollsionBoxArea
   txa                              ; move ABM horizontal position to accumulator
   sec
   sbc tmpIBMHorizPosition          ; subtract IBM horizontal position
   bcs .setIBMAndABMHorizDistance
   eor #$FF                         ; get horizontal distance absolute value
   adc #1
.setIBMAndABMHorizDistance
   sta tmpDeltaX
   tya                              ; move ABM vertical position to accumulator
   sec
   sbc tmpEnemyMissileVertPos       ; subtract enemy missile vertical position
   bcs .determineSmallestDistance
   eor #$FF                         ; get vertical distance absolute value
   adc #1
.determineSmallestDistance
   cmp tmpDeltaX
   bcc .computeABMAndIBMCollisionBoxArea;branch if horizontal distance greater
   ldx tmpDeltaX                    ; move horizontal distance to x register
   sta tmpGreatestDistance
   txa                              ; move horizontal distance to accumulator
.computeABMAndIBMCollisionBoxArea
   lsr                              ; divide smallest distance by 4
   lsr
   sta tmpDiv4
   asl                              ; multiply value by 2
   clc
   adc tmpDiv4                      ; multiply by 3 [i.e. x * 3 = (x * 2) + x]
   lsr                              ; divide value by 2 [i.e. 3x / 8]
   clc
   adc tmpGreatestDistance          ; increment by greatest distance
   rts

DetermineIBMHorizontalAdjustmentValue SUBROUTINE
   lda #0
   sta tmpIBMHorizAdjustment        ; clear horizontal adjustment value
   ldx #8
.determineIBMHorizontalAdjustmentValue
   asl                              ; shift D7 to carry
   rol tmpIBMHorizAdjustment        ; shift carry into D0
   asl tmpDeltaY                    ; multiply vertical delta by 2
   bcc .nextIteration
   clc
   adc tmpIBMSlopeFraction
   bcc .nextIteration               ; branch if no difference overflow
   inc tmpIBMHorizAdjustment
.nextIteration
   dex
   bne .determineIBMHorizontalAdjustmentValue
   sta tmpSpawnedIBMSlopeFraction   ; not used
   rts

NextRandom
   asl random                       ; multiply random seed by 2
   rol random + 1                   ; shift random seed bits
   bpl .checkRandomSeedD1Bit
   inc random                       ; increment random seed value
.checkRandomSeedD1Bit
   lda random                       ; get current random number value
   bit RandomBitTapValue
   beq .checkToReseedRandom         ; branch if D1 is low
   eor #1                           ; flip random seed D0 value
   sta random
.checkToReseedRandom
   ora random + 1                   ; combine with random high
   bne .doneNextRandom              ; branch if either value not 0
   inc random                       ; increment random seed (i.e. value now 1)
.doneNextRandom
   lda random                       ; get current random number value
   rts

RandomBitTapValue
   .byte 2
   
MoveABMsFromReserve
   ldy #1                           ; initial missile reserve count
   lda gameState                    ; get current game state
   and #RESERVED_MISSILE_DUMP_MASK  ; keep used missile dump count
   beq .moveABMsFromReserve         ; branch if no missile reserves used
   cmp #1
   beq .moveLastMissileReserve      ; branch if one missile reserve used
   lda #0
   sta launchingBaseABMs            ; clear number of ABMs left at missile base
   rts

.moveLastMissileReserve
   iny                              ; increment missile reserve count
.moveABMsFromReserve
   tya                              ; move missile reserve count to accumulator
   ora gameState                    ; combine with game state
   sta gameState                    ; set number of missile reserves used
   lda #INIT_NUMBER_LAUNCH_ABM
   sta launchingBaseABMs            ; set initial number of ABMs at missile base
   rts

IncrementScore
   sta tmpPointsOnesValue
   ldx #5                           ; assume score multiplier of 5
   lda waveNumber                   ; get current wave number
   cmp #12
   bcs .setScoreMultiplier          ; branch if greater than 11
   lsr                              ; divide wave number by 2
   tax                              ; set score multiplier
.setScoreMultiplier
   stx tmpScoreMultiplier
.incrementScore
   ldx currentPlayerNumber          ; get the current player number
   lda tmpPointsOnesValue           ; get points ones value
   sed
   clc
   adc playerScore,x                ; increment score ones value
   sta playerScore,x
   tya                              ; move points hundreds value to accumulator
   adc playerScore + 2,x            ; increment score hundreds value
   sta playerScore + 2,x
   lda #1 - 1
   adc playerScore + 4,x            ; increment score ten thousands value
   sta playerScore + 4,x
   cld
   dec tmpScoreMultiplier
   bpl .incrementScore
   rts

SetCityArrayValues
   ldx #0
   txa
.determineCityArrayValues
   ldy cityGraphicPointers,x        ; get city graphic pointer LSB value
   sec                              ; set carry to assume city present
   cpy #<CitySprite
   beq .checkNextCityValue          ; branch if city sprite present
   clc                              ; clear carry -- city not present
.checkNextCityValue
   rol                              ; rotate carry to D0
   inx
   inx
   cpx #12
   bne .determineCityArrayValues
   ldx currentPlayerNumber          ; get the current player number
   sta playerCityArray,x
.initWaveTransitionTimer
   ldx #127 + 128
   stx waveTransitionTimerValue
   inx                              ; x = 0
   stx targetControlHorizIntPos
   stx targetControlVertIntPos
   stx theEndLeftAudioVolume
   rts

CheckToIncrementWaveNumber
   bit gameVariation                ; check current game variation
   bmi .checkToIncrementWaveForTwoPlayerGame;branch if TWO_PLAYER_GAME
   lda player1CityArray             ; get player 1 city array value
   bne .checkToAlternatePlayersForWave;branch if cities remain
.checkToInitiateEasterEgg
   lda #SOUND_THE_END
   sta soundEngineValues            ; set to play SOUND_THE_END
   ldx #$FF
   stx gameOptions
   lda gameSelection                ; get current game selection
   cmp #$13
   bne .initWaveTransitionTimer     ; branch if game 13 not selected
   lda playerScore + 2              ; get player score hundreds value
   ora playerScore + 4              ; combine with score ten thousands value
   bne .initWaveTransitionTimer     ; branch if player scored points
   lda #<ProgrammerInitials
   sta _6thCityGraphicPointer       ; set LSB value to programmer initials
   dec _6thCityGraphicPointer + 1   ; decrement graphic point MSB value
   bne .initWaveTransitionTimer     ; unconditional branch
   
.checkToIncrementWaveForTwoPlayerGame
   ldx currentPlayerNumber          ; get the current player number
   lda playerCityArray,x            ; get player city array value
   bne .checkToAlternatePlayers     ; branch if cities remain
   txa                              ; move active player number to accumulator
   eor #1                           ; flip value
   tax
   lda playerCityArray,x            ; get player city array value
   beq .checkToInitiateEasterEgg    ; branch if no more cities remain
   stx currentPlayerNumber          ; set new current player number
   jmp .checkToAlternatePlayersForWave
   
.checkToAlternatePlayers
   txa                              ; move active player number to accumulator
   eor #1                           ; flip value
   tax
   lda playerCityArray,x            ; get player city array value
   beq .resetToOriginalPlayer       ; branch if no cities remain
   stx currentPlayerNumber          ; set new current player number
   jmp .checkToAlternatePlayersForWave
   
.resetToOriginalPlayer
   txa                              ; move active player number to accumulator
   eor #1                           ; flip D0
   sta currentPlayerNumber          ; set new current player number
   tax                              ; move active player number to x
   jmp .incrementWaveNumber
   
.checkToAlternatePlayersForWave
   ldx currentPlayerNumber          ; get the current player number
   bne SetCityGraphicPointerLSBValues;branch if player 2 is active
.incrementWaveNumber
   inc waveNumber                   ; increment wave number
   lda waveNumber                   ; get current wave number
   cmp #16
   bcs SetCityGraphicPointerLSBValues;branch if wave number greater than 15
   lda ibmFractionalDelay           ; get IBM fractional delay value
   clc
   adc #IBM_VERT_DELAY_INCREMENT_CHILD
   bit gameOptions
   bvs .setIBMFractionalDelay       ; branch if CHILD_GAME
   adc #13 - IBM_VERT_DELAY_INCREMENT_CHILD
.setIBMFractionalDelay
   sta ibmFractionalDelay
SetCityGraphicPointerLSBValues
   lda playerCityArray,x            ; get player city array value
   ldx #10
.determineCityGraphicPointerLSBValues
   lsr                              ; shift player city array value
   ldy #<CitySprite
   bcs .setCityGraphicPointerLSBValue;branch if city present
   ldy DestroyedCityPointer         ; get LSB for destroyed city sprite
.setCityGraphicPointerLSBValue
   sty cityGraphicPointers,x
   dex
   dex
   bpl .determineCityGraphicPointerLSBValues
   rts

ShiftMSBToLSB
   and #$F0                         ; mask the LSB value...not needed
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   rts

CheckToRewardBonusCities
   ldx currentPlayerNumber          ; get the current player number
   lda playerScore + 4,x            ; get score ten thousands value
   cmp bonusCitiesRewarded,x        ; compare with number of cities rewarded
   beq .doneCheckToRewardBonusCities; branch if rewarded for bonus city
   lda playerCityArray,x            ; get player city array value
   cmp #$3F
   beq .doneCheckToRewardBonusCities; branch if no cities destroyed
   lda #SOUND_BONUS_CITY
   sta soundEngineValues            ; set to play SOUND_BONUS_CITY
   lda #160
   sta bonusCityLeftSoundIndex
   lda random                       ; get current random number value
   and #7
   cmp #MAX_CITIES
   bcc .initPlacementOfBonusCity
   sbc #MAX_CITIES - 2
.initPlacementOfBonusCity
   tay
   lda BonusCityBitPositionValues,y
   sta tmpBonusCityPosition
.determinePlacementOfBonusCity
   lda tmpBonusCityPosition         ; get bonus city position value
   and playerCityArray,x            ; check if city present in position
   beq .placeBonusCity              ; branch if position available
   lsr tmpBonusCityPosition         ; shift bonus city position
   bcc .determinePlacementOfBonusCity
   lda #%00100000
   sta tmpBonusCityPosition
   bne .determinePlacementOfBonusCity;unconditional branch
   
.placeBonusCity
   lda playerCityArray,x            ; get player city array value
   ora tmpBonusCityPosition
   sta playerCityArray,x
   lda bonusCitiesRewarded,x        ; get number of cities rewarded
   sed                              ; set to decimal mode
   clc
   adc #1                           ; increment number of cities rewarded
   cld                              ; clear decimal mode
   sta bonusCitiesRewarded,x        ; set number of cities rewarded
   jmp CheckToRewardBonusCities
   
.doneCheckToRewardBonusCities
   rts

ExplosionBoundingBoxArea
   .byte 1
   .byte 2
   .byte 3
   .byte 4
   .byte 2
   .byte 4
   .byte 6
   .byte 8
   .byte 6
   .byte 4
   .byte 2
   .byte 4
   .byte 3
   .byte 2
   .byte 1

MaximumMissileCountValues
   .byte 1 - 1                      ; ONE_COPY
   .byte 2 - 1                      ; TWO_COPIES
   .byte 2 - 1                      ; TWO_MED_COPIES
   .byte 3 - 1                      ; THREE_COPIES
   .byte 2 - 1                      ; TWO_WIDE_COPIES
   .byte 1 - 1                      ; DOUBLE_SIZE...not used
   .byte 3 - 1                      ; THREE_MED_COPIES
   .byte 2 - 1                      ; QUAD_SIZE...not used

IBMHorizOffsetIndexValues
   .byte 0                          ; ONE_COPY
   .byte 2                          ; TWO_COPIES
   .byte 6                          ; TWO_MED_COPIES
   .byte 4                          ; THREE_COPIES
   .byte 10                         ; TWO_WIDE_COPIES
   .byte 0                          ; DOUBLE_SIZE...not used
   .byte 8                          ; THREE_MED_COPIES

IBMGroupingFarthestOffsetValues
   .byte 0, 16, 32, 32, 64, 0, 64, 0

ObjectHorizontalPositionValues
   .byte HORIZ_POSITION_CITY_01
   .byte HORIZ_POSITION_CITY_02
   .byte HORIZ_POSITION_CITY_03
   .byte HORIZ_POSITION_CITY_04
   .byte HORIZ_POSITION_CITY_05
   .byte HORIZ_POSITION_CITY_06
   .byte HORIZ_POSITION_MISSILE_BASE
   .byte HORIZ_POSITION_MISSILE_BASE
   
InitialIBMNUSIZValues
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | TWO_COPIES
   .byte MSBL_SIZE1 | TWO_MED_COPIES
   .byte MSBL_SIZE1 | THREE_COPIES
   .byte MSBL_SIZE1 | TWO_WIDE_COPIES
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | THREE_MED_COPIES
   .byte MSBL_SIZE1 | TWO_WIDE_COPIES
   
IBMFinalGroupingNUSIZValues
   .byte MSBL_SIZE1 | ONE_COPY      ; not used...value never 0
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | TWO_MED_COPIES
;   .byte MSBL_SIZE1 | THREE_MED_COPIES
;
; last byte shared with table below
;

CityBonusTallyOrder
   .byte <_4thCityGraphicPointer - cityGraphicPointers
   .byte <_5thCityGraphicPointer - cityGraphicPointers
   .byte <_3rdCityGraphicPointer - cityGraphicPointers
   .byte <_1stCityGraphicPointer - cityGraphicPointers
   .byte <_2ndCityGraphicPointer - cityGraphicPointers
   .byte <_6thCityGraphicPointer - cityGraphicPointers
   
IBMHorizOffsetPointerValues
   .word IBMHorizOffsetValues
   .word IBMHorizOffsetValues + 1
   .word IBMHorizOffsetValues + 3
   .word IBMHorizOffsetValues + 6
   .word IBMHorizOffsetValues + 8
   .word IBMHorizOffsetValues + 11
   
IBMHorizOffsetValues
   .byte 0, 0, 16, 0, 16, 32, 0
   .byte 32, 0, 32, 64, 0, 64, -1
   
IBMNUSIZValues
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | TWO_COPIES
   .byte MSBL_SIZE1 | TWO_MED_COPIES
   .byte MSBL_SIZE1 | TWO_COPIES
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | TWO_MED_COPIES
   .byte MSBL_SIZE1 | TWO_WIDE_COPIES
   .byte MSBL_SIZE1 | TWO_MED_COPIES
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY

IBMHorizPositionValues
   .byte 16, 0, 16, 0, 0, 32, 0, 32, 0, 0, 64, 0

ABMExhaustionFrequencyValues
   .byte 12, 10, 8, 6, 4, 2, 0, 0

ExplodingABMVolumeValues
   .byte 15, 12, 10, 8, 10, 8, 8, 6, 4, 4
   .byte 8, 8, 6, 4, 2, 19, 20, 21, 22

MaximumWaveIBMValues
   .byte 12, 15, 18, 12, 16, 14, 17, 10
   .byte 13, 16, 19, 12, 14, 16, 18, 20

ReservedMissileDumpGraphicValues
   .byte $A0,$80;,0, 0
;
; last 2 bytes shared with table below
;
MaximumWaveCruiseMissileValues
   .byte 0, 0, 0, 0, 0, 1, 1, 2, 3, 4, 4, 5, 5, 6, 6, 7

BonusCityBitPositionValues
   .byte %00100000
   .byte %00010000
   .byte %00001000
   .byte %00000100
   .byte %00000010
   .byte %00000001
   
GameVariationTable
   .byte 0                          ; not used
   .byte DUMB_CRUISE_MISSILE  | (1 - 1) | SLOW_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (1 - 1) | FAST_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (1 - 1) | SLOW_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (1 - 1) | FAST_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (7 - 1) | SLOW_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (7 - 1) | FAST_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (7 - 1) | SLOW_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (7 - 1) | FAST_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (11 - 1)| SLOW_TARGET_CONTROL
   .byte 0, 0, 0, 0, 0, 0           ; not used
   .byte DUMB_CRUISE_MISSILE  | (11 - 1)| FAST_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (11 - 1)| SLOW_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (11 - 1)| FAST_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (15 - 1)| SLOW_TARGET_CONTROL
   .byte DUMB_CRUISE_MISSILE  | (15 - 1)| FAST_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (15 - 1)| SLOW_TARGET_CONTROL
   .byte SMART_CRUISE_MISSILE | (15 - 1)| FAST_TARGET_CONTROL
   
TargetControlFractionalDelayValues
   .byte 0, 1, 128, 1, 128, 0
   
ProgrammerInitials
   .byte $98 ; |X..XX...|
   .byte $A8 ; |X.X.X...|
   .byte $C8 ; |XX..X...|
   .byte $AE ; |X.X.XXX.|
   .byte $98 ; |X..XX...|
   .byte $98 ; |X..XX...|
   .byte $EF ; |XXX.XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
GameColorTable
   .byte COLOR_FIRST_WAVE_CLUSTER_CITIES
   .byte COLOR_FIRST_WAVE_CLUSTER_IBM
   .byte COLOR_FIRST_WAVE_CLUSTER_SKY
   .byte COLOR_FIRST_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_FIRST_WAVE_CLUSTER_SCORE

   .byte COLOR_SECOND_WAVE_CLUSTER_CITIES
   .byte COLOR_SECOND_WAVE_CLUSTER_IBM
   .byte COLOR_SECOND_WAVE_CLUSTER_SKY
   .byte COLOR_SECOND_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_SECOND_WAVE_CLUSTER_SCORE
   
   .byte COLOR_THIRD_WAVE_CLUSTER_CITIES
   .byte COLOR_THIRD_WAVE_CLUSTER_IBM
   .byte COLOR_THIRD_WAVE_CLUSTER_SKY
   .byte COLOR_THIRD_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_THIRD_WAVE_CLUSTER_SCORE

   .byte COLOR_FOURTH_WAVE_CLUSTER_CITIES
   .byte COLOR_FOURTH_WAVE_CLUSTER_IBM
   .byte COLOR_FOURTH_WAVE_CLUSTER_SKY
   .byte COLOR_FOURTH_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_FOURTH_WAVE_CLUSTER_SCORE

   .byte COLOR_FIFTH_WAVE_CLUSTER_CITIES
   .byte COLOR_FIFTH_WAVE_CLUSTER_IBM
   .byte COLOR_FIFTH_WAVE_CLUSTER_SKY
   .byte COLOR_FIFTH_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_FIFTH_WAVE_CLUSTER_SCORE

   .byte COLOR_SIXTH_WAVE_CLUSTER_CITIES
   .byte COLOR_SIXTH_WAVE_CLUSTER_IBM
   .byte COLOR_SIXTH_WAVE_CLUSTER_SKY
   .byte COLOR_SIXTH_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_SIXTH_WAVE_CLUSTER_SCORE

   .byte COLOR_SEVENTH_WAVE_CLUSTER_CITIES
   .byte COLOR_SEVENTH_WAVE_CLUSTER_IBM
   .byte COLOR_SEVENTH_WAVE_CLUSTER_SKY
   .byte COLOR_SEVENTH_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_SEVENTH_WAVE_CLUSTER_SCORE

   .byte COLOR_EIGHTH_WAVE_CLUSTER_CITIES
   .byte COLOR_EIGHTH_WAVE_CLUSTER_IBM
   .byte COLOR_EIGHTH_WAVE_CLUSTER_SKY
   .byte COLOR_EIGHTH_WAVE_CLUSTER_MISSILE_BASE
   .byte COLOR_EIGHTH_WAVE_CLUSTER_SCORE
   
MissilePointerTable
   .byte <Blank, <Missile01, <Missile02, <Missile03, <Missile04, <Missile05
   .byte <Missile06, <Missile07, <Missile08, <Missile09, <Missile10
   
NumberTable
   .byte <zero, <one, <two, <three, <four
   .byte <five, <six, <seven, <eight, <nine
   
   BOUNDARY 0
   
ABMExplodingAnimationTable
   .byte <ABMExplosionSprite_0, <ABMExplosionSprite_1, <ABMExplosionSprite_2
   .byte <ABMExplosionSprite_3, <ABMExplosionSprite_0, <ABMExplosionSprite_1
   .byte <ABMExplosionSprite_2, <ABMExplosionSprite_3, <ABMExplosionSprite_3
   .byte <ABMExplosionSprite_2, <ABMExplosionSprite_1, <ABMExplosionSprite_0
   .byte <ABMExplosionSprite_3, <ABMExplosionSprite_2, <ABMExplosionSprite_1
   .byte <ABMExplosionSprite_0
   
ABMExplosionSprites
ABMExplosionSprite_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ABMExplosionSprite_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
ABMExplosionSprite_2
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
ABMExplosionSprite_3
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
CitySprite
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $26 ; |..X..XX.|
   .byte $22 ; |..X...X.|
   
CitySpritePointerValues
   .word CitySprite
   
CityExplosionSprites
CityExplosion_0
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $26 ; |..X..XX.|
   .byte $22 ; |..X...X.|
CityExplosion_1
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
CityExplosion_2
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
CityExplosion_3
   .byte $FF ; |XXXXXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
CityExplosion_4
   .byte $FF ; |XXXXXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
CityDestroyed
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
DestroyedCityPointer
   .word CityDestroyed

CityExplosionSpritePointerValues_0
   .word CityExplosion_0

CityExplosionSpritePointerValues_2
   .word CityExplosion_2

LaunchingMissileBase
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   
NumberFonts
zero
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $CE ; |XX..XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
one
   .byte $FC ; |XXXXXX..|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
two
   .byte $FE ; |XXXXXXX.|
   .byte $E0 ; |XXX.....|
   .byte $78 ; |.XXXX...|
   .byte $3C ; |..XXXX..|
   .byte $0E ; |....XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
three
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $06 ; |.....XX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $7E ; |.XXXXXX.|
four
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $FE ; |XXXXXXX.|
   .byte $CC ; |XX..XX..|
   .byte $6C ; |.XX.XX..|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
five
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
six
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $60 ; |.XX.....|
   .byte $3C ; |..XXXX..|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
eight
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
nine
   .byte $78 ; |.XXXX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   
MissileGraphics
Missile10
   .byte $AA ; |X.X.X.X.|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile09
   .byte $A8 ; |X.X.X...|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile08
   .byte $A0 ; |X.X.....|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile07
   .byte $80 ; |X.......|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile06
   .byte $00 ; |........|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile05
   .byte $00 ; |........|
   .byte $50 ; |.X.X....|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile04
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
Missile02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $10 ; |...X....|
Missile01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|

   .org ROM_BASE + 4096 - 6, 0
   .word Start
   .word Start
   .word Start