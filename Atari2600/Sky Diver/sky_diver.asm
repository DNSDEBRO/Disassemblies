   LIST OFF
; ***  S K Y   D I V E R  ***
; Copyright 1978 Atari, Inc.
; Designer: Jim Huether
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 18, 2022
;
;  *** 87 BYTES OF RAM USED 41 BYTES FREE
; NTSC ROM usage stats
; -------------------------------------------
;  ***  4 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
;  ***  0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1978, ATARI, INC.                                  =
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

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 46
OVERSCAN_TIME           = 33

H_SKY_DIVER_KERNEL      = 140

SKY_DIVER_FALL_RATE     = 3

UNSAFE_PARACHUTE_LAUNCH = 90

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 54
OVERSCAN_TIME           = 45

H_SKY_DIVER_KERNEL      = 174

SKY_DIVER_FALL_RATE     = 4

UNSAFE_PARACHUTE_LAUNCH = 123

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

RED_ORANGE              = $20
RED                     = $40
DK_BLUE                 = $90
ORANGE_GREEN            = $E0

COLOR_LEFT_SKY_DIVER    = ORANGE_GREEN + 6
COLOR_RIGHT_SKY_DIVER   = RED + 6
COLOR_GROUND            = RED_ORANGE + 2
COLOR_SKY               = DK_BLUE + 4

   ELSE

GREEN_YELLOW            = $30
BRICK_RED               = $40
PURPLE                  = $80
BLUE                    = $D0

COLOR_LEFT_SKY_DIVER    = BRICK_RED + 6
COLOR_RIGHT_SKY_DIVER   = PURPLE + 8
COLOR_GROUND            = GREEN_YELLOW + 2
COLOR_SKY               = BLUE + 4

   ENDIF

COLOR_WIND_SOCK         = WHITE - 2
BW_WIND_SOCK            = WHITE - 2
BW_LEFT_SKY_DIVER       = WHITE
BW_RIGHT_SKY_DIVER      = BLACK
BW_GROUND               = BLACK + 2
BW_SKY                  = BLACK + 4

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

XMIN                    = 0
XMAX                    = 141

XMIN_AIRPLANE           = 0
XMAX_AIRPLANE           = 135

H_FONT                  = 5
H_AIRPLANE              = 8
H_JUMPING_SKY_DIVER     = 8
H_PARACHUTING_SKY_DIVER = 16
H_WINDSOCK              = 16

MIN_WIND_VELOCITY       = -6
MAX_WIND_VELOCITY       = 6

WIND_VELOCITY_ADJUSTMENT = 2

SKY_DIVER_PARACHUTE_DRIFT = 1
   
GAME_OVER               = $FF

AIRPLANE_ACTIVE         = 0
AIRPLANE_INACTIVE       = $FF

INIT_REMAINING_JUMPS    = 8
;
; Landing Pad width values
;
LANDING_PAD_WIDTH_LARGE = 10
LANDING_PAD_WIDTH_SMALL = 6
;
; game selection values
;
GS_MOVING_LANDING_PADS  = 1 << 7
GS_CHICKEN              = 1 << 0

LANDING_STATUS_UNSAFE   = 1 << 7
LANDING_STATUS_SAFE     = 1 << 6

POINT_REDUCTION_CRASHING_SKY_DIVER = 4

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
   .org $81

landingPadGraphics      ds 2
;--------------------------------------
leftLandingPadGraphics  = landingPadGraphics
rightLandingPadGraphics = leftLandingPadGraphics + 1
skyDiverVertPositions   ds 2
;--------------------------------------
leftSkyDiverVertPosition = skyDiverVertPositions
rightSkyDiverVertPosition = leftSkyDiverVertPosition + 1
skyDiverScanline        ds 2
;--------------------------------------
leftSkyDiverScanline    = skyDiverScanline
rightSkyDiverScanline   = leftSkyDiverScanline + 1
skyDiverHeightValues    ds 2
;--------------------------------------
leftSkyDiverHeightValue = skyDiverHeightValues
rightSkyDiverHeightValue = leftSkyDiverHeightValue + 1
skyDiverHorizPositions  ds 2
;--------------------------------------
leftSkyDiverHorizPosition = skyDiverHorizPositions
rightSkyDiverHorizPosition = leftSkyDiverHorizPosition + 1
skyDiverCoarsePositionValues ds 2
;--------------------------------------
leftSkyDiverCoarsePositionValue = skyDiverCoarsePositionValues
rightSkyDiverCoarsePositionValue = leftSkyDiverCoarsePositionValue + 1
skyDiverFinePositionValues ds 2
;--------------------------------------
leftSkyDiverFinePositionValue = skyDiverFinePositionValues
rightDiverFinePositionValue = leftSkyDiverFinePositionValue + 1
skyDiverVerticalDelayValues ds 2
;--------------------------------------
leftSkyDiverVerticalDelayValue = skyDiverVerticalDelayValues
rightSkyDiverVerticalDelayValue = leftSkyDiverVerticalDelayValue + 1
playfieldControlValues  ds 1
windSockGraphicsPtrs    ds 4
;--------------------------------------
leftHalfWindSockGraphicsPtrs = windSockGraphicsPtrs
rightHalfWindSockGraphicsPtrs = leftHalfWindSockGraphicsPtrs + 2
skyDiverGraphicsPtrs    ds 4
;--------------------------------------
leftSkyDiverGraphicsPtrs = skyDiverGraphicsPtrs
rightSkyDiverGraphicsPtrs = leftSkyDiverGraphicsPtrs + 2
airplaneVelocity        ds 2
;--------------------------------------
leftPlayerAirplaneVelocity = airplaneVelocity
rightPlayerAirplaneVelocity = leftPlayerAirplaneVelocity
skyDiverDescentSpeed    ds 2
;--------------------------------------
leftSkyDiverDescentSpeed = skyDiverDescentSpeed
rightSkyDiverDescentSpeed = leftSkyDiverDescentSpeed + 1
windResistance          ds 1

zp_unused_00            ds 1

tmpPlayerScoreGraphicValues ds 2
;--------------------------------------
tmpLeftPlayerScoreGraphicValue = tmpPlayerScoreGraphicValues
tmpRightPlayerScoreGraphicValue = tmpLeftPlayerScoreGraphicValue + 1
;--------------------------------------
tmpHueMask              = tmpLeftPlayerScoreGraphicValue
;--------------------------------------
tmpRemainingJumpsValue  = tmpHueMask
;--------------------------------------
tmpRemainingJumpsGraphicData = tmpRemainingJumpsValue
;--------------------------------------
tmpPlayerScoreValue     = tmpRemainingJumpsGraphicData
;--------------------------------------
tmpColorXOR             = tmpRightPlayerScoreGraphicValue
;--------------------------------------
scoreLSBOffsets         ds 2
;--------------------------------------
leftPlayerScoreLSBOffset = scoreLSBOffsets
rightPlayerScoreLSBOffset = leftPlayerScoreLSBOffset + 1
scoreMSBOffsets         ds 2
;--------------------------------------
leftPlayerScoreMSBOffset = scoreMSBOffsets
rightPlayerScoreMSBOffset = leftPlayerScoreMSBOffset + 1
gameVariation           ds 1
gameSelection           ds 1
displayGameSelection    ds 1
selectSwitchDebounce    ds 1
varyingWindFactorRate   ds 1
skyDiverDrag            ds 1
frameCount              ds 1
skyDiverHorizontalSpeed ds 2
;--------------------------------------
leftSkyDiverHorizontalSpeed = skyDiverHorizontalSpeed
rightSkyDiverHorizontalSpeed = leftSkyDiverHorizontalSpeed + 1
landingPadEdgeValueIndex ds 1
initLadingPadGraphicValue ds 1
landingPadLeftEdgeValues ds 2
;--------------------------------------
leftSkyDiverPadLeftEdgeValue = landingPadLeftEdgeValues
rightSkyDiverPadLeftEdgeValue = leftSkyDiverPadLeftEdgeValue + 1
landingPadRightEdgeValues ds 2
;--------------------------------------
leftSkyDiverPadRightEdgeValue = landingPadRightEdgeValues
rightSkyDiverPadRightEdgeValue = leftSkyDiverPadRightEdgeValue + 1
landingPadWidth         ds 1
remainingJumps          ds 1
windSockColor           ds 1
groundColor             ds 1
landingPadMovementIndex ds 1
remainingJumpsGraphicIdx ds 1
skyDiverLandingPadDistance ds 2
;--------------------------------------
leftSkyDiverLandingPadDistance = skyDiverLandingPadDistance
rightSkyDiverLandingPadDistance = leftSkyDiverLandingPadDistance + 1
gameState               ds 1
roundPauseTimer         ds 2
;--------------------------------------
roundPauseTimerFraction = roundPauseTimer
roundPauseTimerInteger  = roundPauseTimerFraction + 1
soundVolumeIndexValues  ds 2
;--------------------------------------
leftPlayerVolumeIndexValue = soundVolumeIndexValues
rightPlayerVolumeIndexValue = leftPlayerVolumeIndexValue + 1
suppressRightPlayerScore ds 1
colorCycleMode          ds 1
skyDiverLandingStatus   ds 2
;--------------------------------------
leftSkyDiverLandingStatus = skyDiverLandingStatus
rightSkyDiverLandingStatus = leftSkyDiverLandingStatus + 1
skyDiverHorizontalVelocity ds 2
;--------------------------------------
leftSkyDiverHorizVelocity = skyDiverHorizontalVelocity
rightSkyDiverHorizVelocity = leftSkyDiverHorizVelocity + 1
windVelocity            ds 1
gameStartTimer          ds 1
airplaneActiveState     ds 2
;--------------------------------------
leftPlayerAirplaneActiveState = airplaneActiveState
rightPlayerAirplaneActiveState = leftPlayerAirplaneActiveState + 1
skyDiverReleasedStatus  ds 2
;--------------------------------------
leftSkyDiverReleasedStatus = skyDiverReleasedStatus
rightSkyDiverReleasedStatus = leftSkyDiverReleasedStatus + 1
skyDiverParachuteLaunchStatus ds 2
;--------------------------------------
leftSkyDiverParachuteLaunchStatus = skyDiverParachuteLaunchStatus
rightSkyDiverParachuteLaunchStatus = leftSkyDiverParachuteLaunchStatus + 1
skyDiverLandingPoints   ds 2
;--------------------------------------
leftSkyDiverLandingPoints = skyDiverLandingPoints
rightSkyDiverLandingPoints = leftSkyDiverLandingPoints + 1
skyDiverParachuteReleaseVertPos ds 2
;--------------------------------------
leftSkyDiverParachuteReleaseVertPos = skyDiverParachuteReleaseVertPos
rightSkyDiverParachuteReleaseVertPos = leftSkyDiverParachuteReleaseVertPos + 1
airplaneHorizPositions  ds 2
;--------------------------------------
leftPlayerAirplaneHorizPosition = airplaneHorizPositions
rightPlayerAirplaneHorizPosition = leftPlayerAirplaneHorizPosition + 1
currentProcessingPlayerIndex ds 1
playerScores            ds 2
;--------------------------------------
leftPlayerScore         = playerScores
rightPlayerScore        = leftPlayerScore + 1

   echo "***",(* - $80 - 2)d, "BYTES OF RAM USED", ($100 - * + 2)d, "BYTES FREE"

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
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = -1
   txs                              ; set stack to the beginning
   stx gameState                    ; set to GAME_OVER
   stx selectSwitchDebounce
   stx suppressRightPlayerScore
   jsr ResetGameSelectionToStartingValue
MainLoop
VerticalSync
   lda #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC
   sta WSYNC
   lda #STOP_VERT_SYNC
   sta WSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
   clc
   lda frameCount                   ; get current frame count
   adc #1
   sta frameCount
   bcc DetermineObjectColorValues
   inc colorCycleMode
DetermineObjectColorValues
   lda SWCHB                        ; read the console switches
   ldx #7
   ldy #9
   and #BW_MASK                     ; keep the B/W switch value
   beq .determineHueMaskValue       ; branch if set to B&W
   ldx #$F7
   ldy #4
.determineHueMaskValue
   lda gameState                    ; get the current game state
   bmi .setHueMaskValue             ; branch if GAME_OVER
   ldx #$FF
.setHueMaskValue
   and colorCycleMode
   sta tmpColorXOR
   stx tmpHueMask
   ldx #<[COLUBK - COLUP0]
.setObjectColorValues
   lda GameColorTable,y
   eor tmpColorXOR
   and tmpHueMask
   sta COLUP0,x
   cpx #<[COLUPF - COLUP0]
   bne .nextColorValue              ; branch if not Wind Sock color
   sta windSockColor
.nextColorValue
   dey
   dex
   bpl .setObjectColorValues
   lda GameColorTable,y
   eor tmpColorXOR
   and tmpHueMask
   sta groundColor                  ; set color for ground
   lda gameVariation                ; get current game variation value
   lsr                              ; shift GS_CHICKEN to carry
   bcc .getPlayerDifficultySettings ; branch if not GS_CHICKEN
   lda #$C0                         ; simulate both players set to PRO
   bne SetAirplaneVelocityValues    ; unconditional branch

.getPlayerDifficultySettings
   lda SWCHB                        ; read the console switches
SetAirplaneVelocityValues
   ldx #1
.setAirplaneVelocityValues
   asl                              ; shift difficulty settings to carry
   bcc .setAmateurAirplaneVelocity  ; branch if set to AMATEUR
   ldy ProAirplaneVelocityValues,x
   bcs .setAirplaneVelocity         ; unconditional branch

.setAmateurAirplaneVelocity
   ldy AmateurAirplaneVelocityValues,x
.setAirplaneVelocity
   sty airplaneVelocity,x
   dex
   bpl .setAirplaneVelocityValues
   lda SWCHB                        ; read the console switches
   lsr                              ; shift RESET to carry
   bcs .checkForGameSelect          ; branch if RESET not pressed
   lda #0
   ldx #<gameState
.clearGameVariables
   sta VSYNC,x
   inx
   cpx #<[rightPlayerScore + 1]
   bne .clearGameVariables
   ldx #1
.initAirplaneAndSkyDiverValues
   jsr InitializeAirplane
   lda #<-1
   sta skyDiverVertPositions,x      ; set Sky Diver to INACTIVE
   lda #<~[H_JUMPING_SKY_DIVER - 1]
   sta skyDiverHeightValues,x
   dex
   bpl .initAirplaneAndSkyDiverValues
   lda #INIT_REMAINING_JUMPS
   sta remainingJumps               ; set intial remaining jumps
   lda gameVariation                ; get current game variation value
   bne ProcessSkyDiverActivity      ; branch if no varying wind factor
   lda varyingWindFactorRate
   jsr DetermineLandingPadEdgeIndex
   bcc ProcessSkyDiverActivity      ; unconditional branch

.checkForGameSelect
   lsr                              ; shift SELECT to carry
   lda #GAME_OVER
   bcc .selectButtonPressed         ; branch if SELECT pressed
   sta selectSwitchDebounce
   bmi ProcessSkyDiverActivity      ; unconditional branch
    
.selectButtonPressed
   sta gameState                    ; set to GAME_OVER
   sta suppressRightPlayerScore
   lda selectSwitchDebounce         ; get SELECT debounce value
   bmi .incrementGameSelection      ; branch if SELECT not held
   eor frameCount
   and #$1F                         ; 0 <= a <= 31
   bne ProcessSkyDiverActivity
.incrementGameSelection
   lda frameCount                   ; get current frame count
   and #$1F                         ; 0 <= a <= 31
   sta selectSwitchDebounce         ; set SELECT debounce value
   inc gameSelection                ; increment game selection
   sed                              ; set to decimal mode
   clc
   lda displayGameSelection         ; get display game selection value
   adc #1
   sta displayGameSelection         ; increment display game selection
   sta leftPlayerScore              ; set to show game selection
   cld                              ; clear decimal mode
   cmp #6
   beq .wrapGameSelectionToStartingValue;branch if reached maximum selection
   jsr SetGameVariationValues
   bne ProcessSkyDiverActivity      ; unconditional branch

.wrapGameSelectionToStartingValue
   jsr ResetGameSelectionToStartingValue
ProcessSkyDiverActivity
   lda currentProcessingPlayerIndex
   eor #1
   tax
   sta currentProcessingPlayerIndex
   lda gameVariation                ; get current game variation value
   bpl CheckToChangeWindVelocity    ; branch if not GS_MOVING_LANDING_PADS
   lda windVelocity                 ; get wind velocity value
   jsr SetWindSockGraphicPointers
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   bne .checkToPlayAirplaneSounds
   ldy landingPadMovementIndex      ; get Landing Pad movement index
   iny
   cpy #24
   bcc .setLandingPadMovementIndex
   ldy #0
.setLandingPadMovementIndex
   sty landingPadMovementIndex
   lda #12
   sec
   sbc landingPadMovementIndex      ; -12 <= a <= 13
   bpl .setMovingLandingPadEdgeIndex
   sec
   eor #$FF                         ; get 1's complement value
   adc #1 - 1                       ; add 1 for absolute value
.setMovingLandingPadEdgeIndex
   sta landingPadEdgeValueIndex
   bpl .checkToPlayAirplaneSounds   ; unconditional branch
    
CheckToChangeWindVelocity
   lda frameCount                   ; get current frame count
   and #$7F                         ; 0 <= a <= 127
   bne .checkToPlayAirplaneSounds
   lsr varyingWindFactorRate
   rol
   eor varyingWindFactorRate
   lsr
   lda varyingWindFactorRate
   bcs .changeWindVelocity
   ora #$40
   sta varyingWindFactorRate
.changeWindVelocity
   lsr
   lda windVelocity                 ; get wind velocity value
   bcs .incrementWindVelocity
   cmp #<MIN_WIND_VELOCITY
   beq .setWindVelocity
   sec
   sbc #WIND_VELOCITY_ADJUSTMENT    ; reduce wind velocity by 2
   jmp .setWindVelocity
    
.incrementWindVelocity
   cmp #MAX_WIND_VELOCITY
   beq .setWindVelocity
   clc
   adc #WIND_VELOCITY_ADJUSTMENT    ; increment wind velocity by 2
.setWindVelocity
   sta windVelocity
   jsr SetWindSockGraphicPointers
.checkToPlayAirplaneSounds
   lda #0
   sta AUDC0,x
   sta skyDiverDrag                 ; clear Sky Diver horizontal drag value
   lda gameState                    ; get current game state
   bmi .moveAirplaneHorizontally    ; branch if GAME_OVER
   lda skyDiverReleasedStatus,x     ; get Sky Diver released status
   bne .incrementRoundPauseTimerValues;branch if Sky Diver released
   lda gameStartTimer               ; get game start timer value
   bmi .playAirplaneEngineSounds    ; branch if time expired
   inc gameStartTimer               ; increment for 127 frames (~2 seconds)
   jmp PositionAirplanesHorizontally
    
.playAirplaneEngineSounds
   lda #1
   sta AUDC0,x
   sta AUDV0,x
   lda #27
   sta AUDF0,x
.incrementRoundPauseTimerValues
   clc
   lda roundPauseTimerFraction      ; get pause timer fraction value
   adc #1                           ; increment each frame
   sta roundPauseTimerFraction
   lda roundPauseTimerInteger       ; get pause timer integer value
   adc #1 - 1                       ; increment after 256 frames
   sta roundPauseTimerInteger
   cmp #2
   bne CheckSkyDiverLandingStatus
   ldx #1
.clearSkyDiverStatuses
   ldy #0
   sty skyDiverLandingStatus,x
   sty skyDiverReleasedStatus,x     ; clear Sky Diver released status
   sty skyDiverParachuteLaunchStatus,x;reset Sky Diver parachute launch status
   sty roundPauseTimerInteger
   dey                              ; y = -1
   sty skyDiverVertPositions,x      ; set Sky Diver to INACTIVE
   jsr InitializeAirplane
   dex
   bpl .clearSkyDiverStatuses
   ldx currentProcessingPlayerIndex
   dec remainingJumps               ; decrement number of remaining jumps
   bmi .setGameStateToGameOver      ; branch if reached end of remaining jumps
   lda gameVariation                ; get current game variation value
   bmi .moveAirplaneHorizontally    ; branch if GS_MOVING_LANDING_PADS
   lda varyingWindFactorRate
   and #7                           ; 0 <= a <= 7
   beq .checkToChangeLandingPadEdgeIndexValue
   sec
   sbc #4                           ; -3 <= a <= 3
   asl                              ; 2(-3 <= a <= 3) range of even values
   sta windVelocity
   jsr SetWindSockGraphicPointers
.checkToChangeLandingPadEdgeIndexValue
   lda gameVariation                ; get current game variation value
   bne .moveAirplaneHorizontally    ; branch if no varying wind factor
   lda varyingWindFactorRate
   jsr DetermineLandingPadEdgeIndex
.moveAirplaneHorizontally
   jmp MoveAirplaneHorizontally
    
.setGameStateToGameOver
   lda #GAME_OVER
   sta gameState
   bmi .moveAirplaneHorizontally    ; unconditional branch

CheckSkyDiverLandingStatus
   lda skyDiverLandingStatus,x      ; get Sky Diver landing status value
   beq DetermineControllerActionToPoll
   bpl .checkToScorePointsForLanding; branch if Sky Diver landed safely
   ldy soundVolumeIndexValues,x
   bmi .decrementCrashingSkyDiverScore;branch if done with volume values
   lda CrashingSkyDiverVolumeValues,y
   sta AUDV0,x
   lda #8
   sta AUDC0,x
   lda #15
   sta AUDF0,x
   dec soundVolumeIndexValues,x     ; decrement sound volume index
.decrementCrashingSkyDiverScore
   txa                              ; move player index value to accumulator
   asl                              ; multiply value by 2
   tay
   lda skyDiverGraphicsPtrs,y       ; get Sky Diver graphics LSB value
   cmp #<CrashingSkyDiver_02
   beq .doneCrashingSkyDiver
   lda playerScores,x               ; get player score
   beq .animateCrashingSkyDiver     ; branch if player score is 0
   sed
   sec
   sbc #1                           ; reduce player score by 1
   sta playerScores,x
   cld
.animateCrashingSkyDiver
   lda skyDiverGraphicsPtrs,y
   clc
   adc #H_JUMPING_SKY_DIVER
   sta skyDiverGraphicsPtrs,y
.doneCrashingSkyDiver
   jmp MoveAirplaneHorizontally
    
.checkToScorePointsForLanding
   asl
   bpl AnimateParachutingSkyDiver
   lda gameVariation                ; get current game variation value
   bpl .incrementPlayerScore        ; branch if not GS_MOVING_LANDING_PADS
   jsr DetermineLandingPadPositions
   lda landingPadLeftEdgeValues,x
   clc
   adc skyDiverLandingPadDistance,x
   sta skyDiverHorizPositions,x
.incrementPlayerScore
   lda skyDiverLandingPoints,x      ; get Sky Diver landing points value
   beq AnimateParachutingSkyDiver   ; branch if done accumulating points
   lsr                              ; divide value by 2
   bcc .decrementSkyDiverLandingPoints;skip point accumulation on evens
   lda #12
   sta AUDC0,x                      ; set audio tone for point accumulation
   lda #8
   sta AUDV0,x                      ; set sound volume for point accumulation
   lda PointAccumulationSoundFrequencyValues,x
   sta AUDF0,x
   sed
   lda playerScores,x               ; get player score
   clc
   adc #1                           ; increment player score by 1
   sta playerScores,x
   cld
.decrementSkyDiverLandingPoints
   dec skyDiverLandingPoints,x
AnimateParachutingSkyDiver
   txa                              ; move player index value to accumulator
   asl                              ; multiply value by 2
   tay
   lda skyDiverGraphicsPtrs,y       ; get Sky Diver graphic LSB value
   cmp #<LandedSkyDiver
   beq .doneAnimateParachutingSkyDiver;branch if Sky Diver landed
   lda skyDiverGraphicsPtrs,y       ; get Sky Diver graphic LSB value
   clc
   adc #H_PARACHUTING_SKY_DIVER
   sta skyDiverGraphicsPtrs,y
.doneAnimateParachutingSkyDiver
   jmp MoveAirplaneHorizontally
    
DetermineControllerActionToPoll
   lda skyDiverReleasedStatus,x     ; get Sky Diver released status
   bne ReadPlayerJoystickValues     ; branch if Sky Diver released
   jmp CheckToReleaseSkyDiver
    
ReadPlayerJoystickValues
   lda SWCHA                        ; read the player joystick values
   eor #$FF                         ; flip the bits
   cpx #0
   bne .determineJoystickMovement   ; branch if processing right player
   lsr                              ; shift left player joystick values
   lsr
   lsr
   lsr
.determineJoystickMovement
   and #$0F                         ; keep joystick values
   tay
   lda skyDiverParachuteLaunchStatus,x;get Sky Diver parachute launch status
   bne .checkJoystickHorizontalMovement;branch if parachute launched
   tya                              ; move joystick values to accumulator
   and #<~[MOVE_DOWN] >> 4
   beq AnimateJumpingSkyDiver       ; branch if not MOVE_DOWN
   lda skyDiverVertPositions,x      ; get Sky Diver vertical position
   cmp #UNSAFE_PARACHUTE_LAUNCH
   bcs AnimateJumpingSkyDiver
   sta skyDiverParachuteReleaseVertPos,x;set parachute release vertical position
   lda #SKY_DIVER_PARACHUTE_DRIFT
   sta skyDiverDescentSpeed,x       ; set Sky Diver descent for open parachute
   sta skyDiverParachuteLaunchStatus,x;set to non-zero for parachute launched
   lda #4
   sta soundVolumeIndexValues,x
   lda #<~[H_PARACHUTING_SKY_DIVER - 1]
   sta skyDiverHeightValues,x
   txa                              ; move player index value to accumulator
   asl                              ; mulitply value by 2
   tay
   lda #<OpenChuteSkyDiver
   sta skyDiverGraphicsPtrs,y
   bne .determineSkyDiverLanding    ; unconditional branch
    
AnimateJumpingSkyDiver
   txa                              ; move player index value to accumulator
   asl                              ; multiply value by 2
   tay
   lda skyDiverGraphicsPtrs,y       ; get Sky Diver graphic LSB value
   cmp #<JumpingSkyDiver_00
   bne .animateJumpingSkyDiver
   lda #<JumpingSkyDiver_01
   bne .doneAnimateJumpingSkyDiver  ; unconditional branch
    
.animateJumpingSkyDiver
   lda #<JumpingSkyDiver_00
.doneAnimateJumpingSkyDiver
   sta skyDiverGraphicsPtrs,y
   lda skyDiverHorizontalSpeed,x
   beq .determineSkyDiverLanding
   cpx #0
   beq .driftLeftSkyDiverWest       ; branch if processing left player
   sec
   sbc #1                           ; reduce right Sky Diver speed by 1
   clc
   bpl .setSkyDiverHorizontalSpeedValue;unconditional branch

.driftLeftSkyDiverWest
   clc
   adc #1                           ; increment left Sky Diver speed by 1
   sec
.setSkyDiverHorizontalSpeedValue
   sta skyDiverHorizontalSpeed,x
   beq .determineSkyDiverLanding
   ror                              ; shift carry to D7
   bmi .setLeftSkyDiverHorizontalChangeValue;branch if processing left Sky Diver
   lsr
   bpl .setSkyDiverHorizontalDragValue;unconditional branch

.setLeftSkyDiverHorizontalChangeValue
   sec                              ; set carry bit
   ror                              ; rotate carry into D7 making number negative
.setSkyDiverHorizontalDragValue
   clc
   adc skyDiverDrag
   sta skyDiverDrag
.determineSkyDiverLanding
   jmp DetermineSkyDiverLanding
    
.checkJoystickHorizontalMovement
   tya                              ; move joystick values to accumulator
   and #<~[MOVE_LEFT] >> 4
   beq .checkJoystickRightMovement  ; branch if not MOVE_LEFT
   sec
   lda skyDiverDrag                 ; get Sky Diver horizontal drag value
   sbc windResistance               ; subtract current Wind resistance
   sta skyDiverDrag
   jmp .adjustDragWithWindVelocity
    
.checkJoystickRightMovement
   tya                              ; move joystick values to accumulator
   and #<~[MOVE_RIGHT] >> 4
   beq .adjustDragWithWindVelocity  ; branch if not MOVE_RIGHT
   clc
   lda skyDiverDrag                 ; get Sky Diver horizontal drag value
   adc windResistance               ; increment by current Wind resistance
   sta skyDiverDrag
.adjustDragWithWindVelocity
   lda windVelocity                 ; get wind velocity value
   clc
   adc skyDiverDrag
   sta skyDiverDrag
   ldy soundVolumeIndexValues,x
   bmi .doneSkyDiverHorizontalMovement
   lda ParachuteOpenVolumeValues,y
   sta AUDV0,x
   lda #8
   sta AUDC0,x
   dec soundVolumeIndexValues,x     ; decrement sound volume index
.doneSkyDiverHorizontalMovement
   jmp DetermineSkyDiverLanding
    
CheckToReleaseSkyDiver
   lda INPT4,x                      ; read the player's fire button value
   bmi .doneDetermineSkyDiverLanding; branch if fire button not pressed
   ldy #0
   sty skyDiverHorizontalVelocity,x
   iny
   sty skyDiverVertPositions,x
   lda airplaneHorizPositions,x     ; get Airplane horizontal position
   clc
   adc #4                           ; offset the horizontal position
   clc
   adc airplaneVelocity,x           ; increment by Airplane velocity
   sta skyDiverHorizPositions,x     ; set jumping Sky Diver horizontal position
   lda airplaneVelocity,x           ; get Airplane velocity
   asl                              ; shift Airplane speed to upper nybbles
   asl
   asl
   asl
   asl
   sta skyDiverHorizontalSpeed,x
   txa                              ; move player index value to accumulator
   asl                              ; multiply value by 2
   tay
   lda #<JumpingSkyDiver_00
   sta skyDiverGraphicsPtrs,y
   lda #<~[H_JUMPING_SKY_DIVER - 1]
   sta skyDiverHeightValues,x
   lda #SKY_DIVER_FALL_RATE
   sta skyDiverDescentSpeed,x
   sta skyDiverReleasedStatus,x
   jmp MoveAirplaneHorizontally
    
DetermineSkyDiverLanding
   clc
   lda skyDiverVertPositions,x      ; get Sky Diver vertical position
   cmp #<-1
   beq .setSkyDiverHorizontalVelocityValue;branch if Sky Diver not active
   lda skyDiverParachuteLaunchStatus,x;get Sky Diver parachute launch status
   beq .skyDiverFallingWithoutParachute;branch if parachute not launched
   lda skyDiverVertPositions,x      ; get Sky Diver vertical position
   cmp #[H_SKY_DIVER_KERNEL - 30]
   bcc .descendSkyDiver
   lda skyDiverHorizPositions,x     ; get Sky Diver horizontal position
   cmp landingPadLeftEdgeValues,x
   bcc .skyDiverLandedOffLandingPad ; branch if Sky Diver left of Landing Pad
   cmp landingPadRightEdgeValues,x
   bcs .skyDiverLandedOffLandingPad ; branch if Sky Diver right of Landing Pad
   lda gameVariation                ; get current game variation value
   lsr                              ; shift GS_CHICKEN to carry
   bcc .determineSkyDiverLandingPointValue;branch if not set to GS_CHICKEN
   txa                              ; move player index value to accumulator
   eor #1                           ; alternate player index
   tay
   lda skyDiverLandingStatus,y      ; get other Sky Diver landing status value
   cmp #LANDING_STATUS_SAFE
   beq .skyDiverLandedOffLandingPad
.determineSkyDiverLandingPointValue
   lda #LANDING_STATUS_SAFE
   sta skyDiverLandingStatus,x
   lda skyDiverHorizPositions,x     ; get Sky Diver horizontal position
   sec
   sbc landingPadLeftEdgeValues,x   ; subtract Landing Pad left edge
   sta skyDiverLandingPadDistance,x
   lda skyDiverParachuteReleaseVertPos,x;get parachute release vertical position
   lsr                              ; divide value by 4
   lsr

   IF COMPILE_REGION = PAL50

      sec
      sbc #8
      bmi .clearSkyDiverParachuteReleasePosition

   ENDIF

   sta skyDiverLandingPoints,x
.clearSkyDiverParachuteReleasePosition
   lda #0
   sta skyDiverParachuteReleaseVertPos,x
.doneDetermineSkyDiverLanding
   jmp MoveAirplaneHorizontally
    
.skyDiverLandedOffLandingPad
   lda #1
   sta skyDiverLandingStatus,x
   lda #9
   sta AUDC0,x
   sta AUDV0,x
   bne .doneDetermineSkyDiverLanding; unconditional branch

.skyDiverFallingWithoutParachute
   lda skyDiverVertPositions,x      ; get Sky Diver vertical position
   cmp #[H_SKY_DIVER_KERNEL - 18]
   bcc .descendSkyDiver
   lda #LANDING_STATUS_UNSAFE
   sta skyDiverLandingStatus,x
   lda #[POINT_REDUCTION_CRASHING_SKY_DIVER + 1] * 2
   sta skyDiverLandingPoints,x
   lda #4
   sta soundVolumeIndexValues,x
   bne .doneDetermineSkyDiverLanding; unconditional branch
    
.descendSkyDiver
   adc skyDiverDescentSpeed,x
   sta skyDiverVertPositions,x
.setSkyDiverHorizontalVelocityValue
   clc
   lda skyDiverHorizontalVelocity,x ; get Sky Diver horizontal velocity
   adc skyDiverDrag                 ; adjust by Sky Diver horizontal drag value
   sta skyDiverHorizontalVelocity,x
   bmi .adjustForSkyDiverTravelingWest;branch if Sky Diver moving West
   lsr
   lsr
   lsr
   bpl .determineSkyDiverHorizontalPosition;unconditional branch

.adjustForSkyDiverTravelingWest
   sec
   ror
   sec
   ror
   sec
   ror
   clc
   adc #1                           ; adjust by -15...maybe [(a / 8) + 225]?
.determineSkyDiverHorizontalPosition
   clc
   adc skyDiverHorizPositions,x
   cmp #XMAX + 1
   bcc .setSkyDiverHorizontalPositionValue;branch if not reached right edge
   bit skyDiverDrag                 ; check Sky Diver horizontal drag value
   bmi .setSkyDiverMinimumHorizValue
   lda #XMAX
   bmi .setSkyDiverHorizontalPositionValue;unconditional branch
    
.setSkyDiverMinimumHorizValue
   lda #XMIN
.setSkyDiverHorizontalPositionValue
   sta skyDiverHorizPositions,x
   lda skyDiverHorizontalVelocity,x
   bpl .restrictSkyDiverEastVelocity; branch if traveling East
   and #7                           ; 0 <= a <= 7
   ora #$F8                         ; subtract 8 from velocity
    
    IF COMPILE_REGION = PAL50
    
    bmi .setSkyDiverHorizontalVelocity;unconditional branch
    
    ELSE
    
    jmp .setSkyDiverHorizontalVelocity
    
    ENDIF
    
.restrictSkyDiverEastVelocity
   and #7                           ; 0 <= a <= 7
.setSkyDiverHorizontalVelocity
   sta skyDiverHorizontalVelocity,x
MoveAirplaneHorizontally
   lda airplaneHorizPositions,x     ; get Airplane horizontal position value
   cmp #<-1
   beq PositionAirplanesHorizontally; branch if Airplane not active
   clc
   adc airplaneVelocity,x           ; increment by Airplane velocity
   cmp #XMAX_AIRPLANE
   bcc .setAirplaneHorizontalPositionValue;branch if Airplane in field of play
   lda gameState                    ; get current game state
   bmi .resetAiplanePositionForGameOver;branch if GAME_OVER
   lda #AIRPLANE_INACTIVE
   sta airplaneActiveState,x
   sta skyDiverReleasedStatus,x
.setAirplaneHorizontalPositionValue
   sta airplaneHorizPositions,x
   jmp PositionAirplanesHorizontally
    
.resetAiplanePositionForGameOver
   jsr InitializeAirplane
PositionAirplanesHorizontally
   ldx #<[rightPlayerAirplaneHorizPosition - leftPlayerAirplaneHorizPosition]
.positionAirplaneHorizontally
   lda airplaneHorizPositions,x
   jsr CalculateHorizPosition
   sta WSYNC                        ; wait for next scan line
   SLEEP 2
   SLEEP 2
   SLEEP 2
   SLEEP 2
   SLEEP 2
   sta HMP0,x
.coarsePositionAirplane
   dey
   bpl .coarsePositionAirplane
   sta RESP0,x
   dex
   bpl .positionAirplaneHorizontally
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   ldx #<[rightSkyDiverHorizPosition - leftSkyDiverHorizPosition]
.setSkyDiverHMOVEValues
   lda skyDiverHorizPositions,x
   jsr CalculateHorizPosition
   sty skyDiverCoarsePositionValues,x
   sta skyDiverFinePositionValues,x
   dex
   bpl .setSkyDiverHMOVEValues
   lda remainingJumps               ; get number of remaining jumps
   clc
   adc #1                           ; increment by 1 for display
   sta tmpRemainingJumpsValue       ; save value for later
   asl                              ; shift the value left to multiply by 4
   asl
   adc tmpRemainingJumpsValue       ; add original to multiply by 5
   asl                              ; multiply value by 2
   sta remainingJumpsGraphicIdx
   ldx #1
   sec
   lda rightSkyDiverVertPosition
   sbc #1
   jmp .setSkyDiverScanlineValue
    
.setSkyDiverKernelValues
   lda leftSkyDiverVertPosition
.setSkyDiverScanlineValue
   lsr                              ; divide vertical position by 2
   sta skyDiverScanline,x
   bcc .nextSkyDiverKernelValue
   lda #VERTICAL_DELAY
   sta skyDiverVerticalDelayValues,x; set Sky Diver vertical delay value
.nextSkyDiverKernelValue
   dex
   bpl .setSkyDiverKernelValues
   ldx #<[rightPlayerScore - playerScores]
.determineScoreOffsetValues
   lda playerScores,x               ; get player score
   and #$0F                         ; keep lower nybbles
   sta tmpPlayerScoreValue
   asl                              ; multiply value by 4
   asl
   clc                              ; add original to multiply by 5
   adc tmpPlayerScoreValue          ; [i.e. x * 5 = (x * 4) + x]
   sta scoreLSBOffsets,x
   lda playerScores,x               ; get player score
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide value by 4
   lsr
   sta tmpPlayerScoreValue
   lsr                              ; divide value by 16
   lsr
   clc                              ; add in original so it's multiplied by
   adc tmpPlayerScoreValue          ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]
   sta scoreMSBOffsets,x
   dex
   bpl .determineScoreOffsetValues
   jsr DetermineLandingPadPositions
   lda #0
   sta rightLandingPadGraphics
   lda initLadingPadGraphicValue    ; get intial Landing Pad graphic value
   sta leftLandingPadGraphics       ; set to left Landing Pad graphic value
.rotateLandingPadGraphicValues
   dey
   bmi DisplayKernel
   lsr leftLandingPadGraphics       ; rotate left Landing Pad graphic value
   rol rightLandingPadGraphics      ; for right Landing Pad graphic value
   jmp .rotateLandingPadGraphicValues
    
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   sta tmpLeftPlayerScoreGraphicValue;3
   sta tmpRightPlayerScoreGraphicValue;3
   lda #MSBL_SIZE1 | PF_SCORE | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @14
   ldx #5                     ; 2
.drawScoreKernel
   sta WSYNC
;--------------------------------------
   lda tmpLeftPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @06
   ldy leftPlayerScoreMSBOffset;3
   cpy #5                     ; 2
   bcs .getLeftPlayerScoreMSBGraphicValue;2³
   lda #0                     ; 2
   beq .setLeftPlayerScoreMSBGraphicValue;3 unconditional branch

.getLeftPlayerScoreMSBGraphicValue
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$F0                   ; 2         keep upper nybbles
.setLeftPlayerScoreMSBGraphicValue
   sta tmpLeftPlayerScoreGraphicValue;3
   ldy leftPlayerScoreLSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$0F                   ; 2         keep lower nybbles
   ora tmpLeftPlayerScoreGraphicValue;3   combine with score MSB graphic
   sta tmpLeftPlayerScoreGraphicValue;3   set left player score graphic
   lda tmpRightPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @44
   ldy rightPlayerScoreMSBOffset;3
   cpy #5                     ; 2
   bcs .getRightPlayerScoreMSBGraphicValue;2³
   lda #0                     ; 2
   beq .setRightPlayerScoreMSBGraphicValue;3 unconditional branch
    
.getRightPlayerScoreMSBGraphicValue
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$F0                   ; 2         keep upper nybbles
.setRightPlayerScoreMSBGraphicValue
   sta tmpRightPlayerScoreGraphicValue;3
   ldy rightPlayerScoreLSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$0F                   ; 2         keep lower nybbles
   ora tmpRightPlayerScoreGraphicValue;3
   sta tmpRightPlayerScoreGraphicValue;3
   dex                        ; 2
;--------------------------------------
   bmi DrawSkyDiverPlaneKernel;2³
   lda suppressRightPlayerScore;3
   bpl .drawScoreBoardValues  ; 2³
   lda #0                     ; 2
   sta tmpRightPlayerScoreGraphicValue;3
.drawScoreBoardValues
   lda tmpLeftPlayerScoreGraphicValue;3
   sta PF1                    ; 3
   inc leftPlayerScoreLSBOffset;5
   inc leftPlayerScoreMSBOffset;5
   inc rightPlayerScoreLSBOffset;5
   inc rightPlayerScoreMSBOffset;5
   lda tmpRightPlayerScoreGraphicValue;3
   sta PF1                    ; 3
   jmp .drawScoreKernel       ; 3
    
DrawSkyDiverPlaneKernel
   stx REFP1                  ; 3
   lda #MSBL_SIZE1 | DOUBLE_SIZE;2
   sta NUSIZ0                 ; 3
   sta NUSIZ1                 ; 3
   ldy #0                     ; 2
   sty PF1                    ; 3
.drawSkyDiverPlaneKernel
   lda leftPlayerAirplaneActiveState;3    get Airplane active state
   beq .getLeftSkyDiverPlaneGraphicData;2³ branch if AIRPLANE_ACTIVE
   lda #0                     ; 2
   beq .drawLeftSkyDiverPlane ; 3         unconditional branch

.getLeftSkyDiverPlaneGraphicData
   lda AirplaneGraphics,y     ; 4
.drawLeftSkyDiverPlane
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda rightPlayerAirplaneActiveState;3   get Airplane active state
   beq .getRightSkyDiverPlaneGraphicData;2³ + 1 branch if AIRPLANE_ACTIVE
   lda #0                     ; 2
   beq .drawRightSkyDiverPlane; 3         unconditional branch

.getRightSkyDiverPlaneGraphicData
   lda AirplaneGraphics,y     ; 4
.drawRightSkyDiverPlane
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   iny                        ; 2
   cpy #H_AIRPLANE            ; 2
   bne .drawSkyDiverPlaneKernel;2³ + 1
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   sta GRP0                   ; 3 = @09
   sta NUSIZ0                 ; 3 = @12
   sta NUSIZ1                 ; 3 = @15
   ldx #1                     ; 2
.positionSkyDiversHorizontally
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   ldy skyDiverCoarsePositionValues,x;4
   lda skyDiverFinePositionValues,x;4
   sta HMP0,x                 ; 4 = @14
.coarsePositionSkyDiver
   dey                        ; 2
   bpl .coarsePositionSkyDiver; 2³
   sta RESP0,x                ; 4
   dex                        ; 2
   bpl .positionSkyDiversHorizontally;2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda leftSkyDiverVerticalDelayValue;3
   sta VDELP0                 ; 3 = @09
   lda rightSkyDiverVerticalDelayValue;3
   sta VDELP1                 ; 3 = @15
   lda playfieldControlValues ; 3
   sta CTRLPF                 ; 3 = @21
   ldx #0                     ; 2
.drawSkyDiverKernel
   txa                        ; 2         move scan line count to accumulator
   sec                        ; 2
   sbc leftSkyDiverScanline   ; 3         subtract Sky Diver scan line
   tay                        ; 2
   and leftSkyDiverHeightValue; 3         and with 2's complement of height
   beq .getLeftSkyDiverGraphicData;2³
   lda #0                     ; 2
   beq .drawLeftSkyDiver      ; 3         unconditional branch

.getLeftSkyDiverGraphicData
   lda (leftSkyDiverGraphicsPtrs),y;5
.drawLeftSkyDiver
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   txa                        ; 2         move scan line count to accumulator
   cmp #[H_SKY_DIVER_KERNEL / 2] - 2;2
   bcc .nextSkyDiverScanline  ; 2³
   lda leftLandingPadGraphics ; 3         get left landing pad graphics value
   sta PF1                    ; 3 = @15   draw left landing pad
   lda groundColor            ; 3         get current color for the ground
   sta COLUBK                 ; 3 = @21
   lda rightLandingPadGraphics; 3         get right landing pad graphics value
   sta PF2                    ; 3 = @27   draw right landing pad
.nextSkyDiverScanline
   txa                        ; 2         move scan line count to accumulator
   inx                        ; 2
   sec                        ; 2
   sbc rightSkyDiverScanline  ; 3         subtract Sky Diver scan line
   tay                        ; 2
   and rightSkyDiverHeightValue;3         and with 2's complement of height
   beq .getRightSkyDiverGraphicData;2³
   lda #0                     ; 2
   beq .drawRightSkyDiver     ; 3         unconditional branch
    
.getRightSkyDiverGraphicData
   lda (rightSkyDiverGraphicsPtrs),y;5
.drawRightSkyDiver
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   cpx #[H_SKY_DIVER_KERNEL / 2];2   
   bne .drawSkyDiverKernel    ; 2³
   lda #0                     ; 2
   ldx #<[GRP1 - GRP0]        ; 2
   sta WSYNC
;--------------------------------------
.clearSkyDiverKernelGraphicData
   sta GRP0,x                 ; 4
   sta PF1,x                  ; 4
   sta VDELP0,x               ; 4
   dex                        ; 2
   bpl .clearSkyDiverKernelGraphicData;2³
   sta tmpRemainingJumpsGraphicData;3
   sta CTRLPF                 ; 3 = @43
   lda windSockColor          ; 3
   sta COLUP0                 ; 3 = @49
   sta COLUP1                 ; 3 = @52
   ldy #7                     ; 2
   sta WSYNC
;--------------------------------------
.coarsePositionWindSock
   dey                        ; 2
   bpl .coarsePositionWindSock; 2³
   SLEEP 2                    ; 2
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   lda #HMOVE_R2              ; 2
   sta HMP1                   ; 3
   lda #HMOVE_R3              ; 2
   sta HMP0                   ; 3
   iny                        ; 2         y = 0
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
.drawWindSockKernel
   lda (leftHalfWindSockGraphicsPtrs),y;5
   sta GRP0                   ; 3 = @11
   lda (rightHalfWindSockGraphicsPtrs),y;5        
   sta GRP1                   ; 3 = @19
   lda tmpRemainingJumpsGraphicData;3
   sta PF1                    ; 3 = @25
   lda remainingJumpsGraphicIdx;3
   lsr                        ; 2
   tax                        ; 2
   cpx #5                     ; 2
   bcs .getRemainingJumpsGraphicData;2³
   lda #0                     ; 2
   beq .setRemainingJumpsGraphicData;3    unconditional branch
    
.getRemainingJumpsGraphicData
   lda NumberFonts,x          ; 4
   and #$0F                   ; 2
.setRemainingJumpsGraphicData
   sta tmpRemainingJumpsGraphicData;3
   lda #0                     ; 2
   sta PF1                    ; 3 = @51
   iny                        ; 2
   cpy #[H_FONT * 2]          ; 2
   bcc .incrementRemainingJumpsIndex;2³
   lda #0                     ; 2
   sta remainingJumpsGraphicIdx;3
   beq .nextWindSockScanline  ; 3         unconditional branch
    
.incrementRemainingJumpsIndex
   inc remainingJumpsGraphicIdx;5
.nextWindSockScanline
   sta WSYNC
;--------------------------------------
   cpy #H_WINDSOCK            ; 2
   bne .drawWindSockKernel    ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @09
   sta GRP1                   ; 3 = @12
   sta WSYNC
;--------------------------------------
   lda #OVERSCAN_TIME
   sta TIM64T
.overscanWaitTime
   lda INTIM
   bne .overscanWaitTime
   jmp MainLoop
    
GameVariationTable
   .byte 0
   .byte 0
   .byte GS_MOVING_LANDING_PADS
   .byte GS_MOVING_LANDING_PADS
   .byte GS_CHICKEN
    
GameColorTable
   .byte COLOR_GROUND
   .byte COLOR_LEFT_SKY_DIVER
   .byte COLOR_RIGHT_SKY_DIVER
   .byte COLOR_WIND_SOCK
   .byte COLOR_SKY

   .byte BW_GROUND
   .byte BW_LEFT_SKY_DIVER
   .byte BW_RIGHT_SKY_DIVER
   .byte BW_WIND_SOCK
;   .byte BW_SKY
;
; last byte shared with table below
;
CrashingSkyDiverVolumeValues
   .byte 4, 7, 5, 15, 6

LandingPadGraphicValues
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|

LandingPadWidthValues
   .byte LANDING_PAD_WIDTH_LARGE
   .byte LANDING_PAD_WIDTH_SMALL
   .byte LANDING_PAD_WIDTH_LARGE
   .byte LANDING_PAD_WIDTH_SMALL
   .byte LANDING_PAD_WIDTH_LARGE

LeftLandingPadLeftEdgeValues
   .byte 11, 15, 19, 23, 27, 31, 35, 39
   .byte 43, 47, 51, 55, 59, 63, 67

RightLandingPadRightEdgeValues
   .byte 133, 129, 125, 121, 117, 113, 109
   .byte 105, 101, 97, 93, 89, 85, 81, 77

DetermineLandingPadPositions
   ldy landingPadEdgeValueIndex
   lda LeftLandingPadLeftEdgeValues,y
   sta leftSkyDiverPadLeftEdgeValue ; set Landing Pad left edge value
   clc
   adc landingPadWidth              ; increment by Landing Pad width
   sta leftSkyDiverPadRightEdgeValue; set Landing Pad right edge value
   lda RightLandingPadRightEdgeValues,y
   sta rightSkyDiverPadRightEdgeValue;set Landing Pad right edge value
   sec
   sbc landingPadWidth              ; subtract by Landing Pad width
   sta rightSkyDiverPadLeftEdgeValue; set Landing Pad left edge value
   rts

InitializeAirplane
   lda #AIRPLANE_ACTIVE
   sta airplaneActiveState,x
   cpx #1
   beq .setPlaneInitialHorizPosition; branch if processing right player Airplane
   lda #XMAX_AIRPLANE - 1
.setPlaneInitialHorizPosition
   sta airplaneHorizPositions,x
   rts

DetermineLandingPadEdgeIndex
.divideValueBy13
   cmp #13
   bcc .setLandingPadEdgeIndexValue
   sec
   sbc #13
   jmp .divideValueBy13

.setLandingPadEdgeIndexValue
   sta landingPadEdgeValueIndex
   rts

ResetGameSelectionToStartingValue
   lda #1
   sta leftPlayerScore
   sta gameSelection                ; set initial game selection
   sta displayGameSelection         ; set initial display game selection
SetGameVariationValues
   ldy gameSelection                ; get current game selection
   ldx #MSBL_SIZE1 | PF_SCORE | PF_REFLECT
   dey
   sty landingPadEdgeValueIndex
   lda GameVariationTable,y
   sta gameVariation
   lsr                              ; shift GS_CHICKEN to carry
   bcc .setInitLandingPadValues     ; branch if not set to GS_CHICKEN
   lda #14
   sta landingPadEdgeValueIndex
   ldx #MSBL_SIZE1 | PF_REFLECT
.setInitLandingPadValues
   stx playfieldControlValues
   lda LandingPadGraphicValues,y
   sta initLadingPadGraphicValue
   lda LandingPadWidthValues,y
   sta landingPadWidth
   ldx #1
.resetGameVariables
   jsr InitializeAirplane
   lda #<-1
   sta skyDiverVertPositions,x      ; set Sky Diver to INACTIVE
   sta skyDiverHeightValues,x
   sta remainingJumps
   txa                              ; move player index value to accumulator
   asl                              ; multiply value by 2
   tay
   lda #<NoWindSockGraphics
   sta windSockGraphicsPtrs,y
   lda #>WindSockGraphics
   sta windSockGraphicsPtrs + 1,y
   sta skyDiverGraphicsPtrs + 1,y
   dex
   bpl .resetGameVariables
   rts

SetWindSockGraphicPointers
   and #$FF
   bpl .setWindSockGraphicsForEastWind;branch if wind blowing East
   eor #$FF                         ; get 1's complement value
   clc
   adc #1                           ; add 1 for absolute value
   asl                              ; multiply by 8 (i.e. H_WINDSOCK / 2)
   asl
   asl
   clc
   adc #<WindSockGraphics
   sta leftHalfWindSockGraphicsPtrs
   lda #<NoWindSockGraphics
   sta rightHalfWindSockGraphicsPtrs
   bne .determineSkyDiverWindResistance

.setWindSockGraphicsForEastWind
   asl                              ; multiply by 8 (i.e. H_WINDSOCK / 2)
   asl
   asl
   clc
   adc #<WindSockGraphics
   sta rightHalfWindSockGraphicsPtrs
   lda #<NoWindSockGraphics
   sta leftHalfWindSockGraphicsPtrs
.determineSkyDiverWindResistance
   lda windVelocity                 ; get wind velocity value
   bpl .setSkyDiverWindResistance   ; branch if wind blowing East
   eor #$FF                         ; get 1's complement value
   clc
   adc #1                           ; add 1 for absolute value
.setSkyDiverWindResistance
   lsr                              ; divide wind speed by 2
   tay
   lda WindResistanceValues,y
   sta windResistance
   rts

CalculateHorizPosition
   ldy #0
   clc
   adc #1                           ; increment horizontal position value
.determineCoarseValue
   cmp #8
   bcc .determineFineMotionValue
   iny                              ; increment coarse position value
   sec
   sbc #15
   bpl .determineCoarseValue
.determineFineMotionValue
   eor #$FF
   clc
   adc #1
   asl
   asl
   asl
   asl
   rts

   FILL_BOUNDARY 0, 234

SkyDiverGraphics
JumpingSkyDiver_00
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
JumpingSkyDiver_01
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $FF ; |XXXXXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
CrashingSkyDiver_00   
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $99 ; |X..XX..X|
   .byte $5A ; |.X.XX.X.|
   .byte $24 ; |..X..X..|
CrashingSkyDiver_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $BD ; |X.XXXX.X|
   .byte $7E ; |.XXXXXX.|
CrashingSkyDiver_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $FF ; |XXXXXXXX|
OpenChuteSkyDiver
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $81 ; |X......X|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
OpenChuteSkyDiver_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $81 ; |X......X|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
LandingSkyDiver_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $DB ; |XX.XX.XX|
   .byte $BD ; |X.XXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
LandingSkyDiver_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
LandedSkyDiver
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|

AirplaneGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $39 ; |..XXX..X|
   .byte $11 ; |...X...X|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|

AmateurAirplaneVelocityValues
   .byte -1;, 1
;
; last byte shared with table below
;
WindSockGraphics
NoWindSockGraphics
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
SlowestWindSockGraphics
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $09 ; |....X..X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
MediumWindSockGraphics
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3D ; |..XXXX.X|
   .byte $39 ; |..XXX..X|
   .byte $31 ; |..XX...X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
FastestWindSockGraphics
   .byte $07 ; |.....XXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|

NumberFonts
zero
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
one
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
two
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
three
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $66 ; |.XX..XX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
four
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
five
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
six
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
seven
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
eight
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
nine
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|

PointAccumulationSoundFrequencyValues
   .byte 23, 31

ParachuteOpenVolumeValues
   .byte 2, 5, 9, 10, 1

WindResistanceValues
   .byte 3, 4, 5, 6

   .org ROM_BASE + 2048 - 4, 0

   .word Start                      ; START vector

ProAirplaneVelocityValues
   .byte -2, 2
