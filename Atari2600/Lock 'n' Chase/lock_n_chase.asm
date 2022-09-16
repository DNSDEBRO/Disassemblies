   LIST OFF
; ***  L O C K  ' N '  C H A S E  ***
; Copyright 1982, Mattel, Inc. 
; Designer: Bruce Pedersen
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: September 13, 2022
;
;  *** 120 BYTES OF RAM USED 8 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
;  *** 384 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
;  *** 418 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, MATTEL, INC.                                 =
; =                                                                            =
; ==============================================================================
;

   processor 6502

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
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

VBLANK_TIME             = 45
OVERSCAN_TIME           = 25

   ELSE
   
VBLANK_TIME             = 75
OVERSCAN_TIME           = 55

   ENDIF

KERNEL_TIME             = 238

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

COLOR_LEFT_PLAYER       = BRICK_RED + 4
COLOR_RIGHT_PLAYER      = GREEN + 8
COLOR_GOLD_BARS         = RED_ORANGE + 12
COLOR_MAZE              = DK_BLUE + 4
COLOR_POLICE            = DK_BLUE + 10
COLOR_LOWER_TREASURE    = PURPLE + 8
COLOR_CLOSED_DOOR       = PURPLE + 10

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

COLOR_LEFT_PLAYER       = BRICK_RED + 4
COLOR_RIGHT_PLAYER      = DK_GREEN + 8
COLOR_GOLD_BARS         = BRICK_RED + 12
COLOR_MAZE              = DK_BLUE + 4
COLOR_POLICE            = DK_BLUE + 10
COLOR_LOWER_TREASURE    = COLBALT_BLUE + 8
COLOR_CLOSED_DOOR       = CYAN + 10

   ENDIF

COLOR_LEFT_PLAYER_REMAINING_LIVES = COLOR_LEFT_PLAYER + 8
COLOR_RIGHT_PLAYER_REMAINING_LIVES = COLOR_RIGHT_PLAYER + 4

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_KERNEL                = 96
H_KERNEL_ZONE           = 16
H_DIGITS                = 7
H_POLICE                = 8
H_THIEF                 = 8

XMIN                    = 5
XMAX                    = 144
YMIN                    = 8
YMAX                    = 88

LOWER_TREASURE_VERT_POS = 40
UPPER_TREASURE_VERT_POS = 56

LOWER_TREASURE_INDEX    = 5
UPPER_TREASURE_INDEX    = 7

TREASURE_HORIZ_POS      = 74

KERNEL_SECTIONS         = 12

INIT_THIEF_HORIZ        = 74
INIT_THIEF_VERT         = 98
INIT_LEFT_POLICE_HORIZ  = 8
INIT_RIGHT_POLICE_HORIZ = 140

INIT_POLICE_VERT_00     = 40
INIT_POLICE_VERT_01     = 40
INIT_POLICE_VERT_02     = 56
INIT_POLICE_VERT_03     = 56

MAX_GOLD_BARS           = 104
INIT_LIVES              = 5
MAX_LIVES               = 7

MAX_LOWER_TREASURES     = 2
MAX_UPPER_TREASURES     = 4

INIT_BONUS_POINT_TIMER_VALUE = 120

GOLD_BARS_MASK          = $AA

MAX_UPPER_TREASURE_POINT_IDX = 4

NUM_POLICE              = 4

ZONE_MAX_POLICE         = 2         ; maximum Police in a given zone
;
; gameState mask values
;
TRAPPED_POLICE_REWARD_MASK = %10000000
ESCAPE_DOOR_MASK        = %01000000
SHOW_LOWER_TREASURE_MASK = %00100000
SHOW_UPPER_TREASURE_MASK = %00010000
ROUND_START_MASK        = %00001000
PAUSE_MOVEMENT_MASK     = %00000100
GAME_ACTIVE_MASK        = %00000010
ALTERNATE_PLAYERS_MASK  = %00000001
;
; gameState values
;
GS_ALTERNATE_PLAYERS    = 1 << 0
GS_NOT_ALTERNATE_PLAYERS = 0 << 0
GS_GAME_ACTIVE          = 1 << 1
GS_GAME_INACTIVE        = 0 << 1
GS_PAUSE_MOVEMENT       = 1 << 2
GS_ALLOW_MOVEMENT       = 0 << 2
GS_START_ROUND          = 1 << 3
GS_NOT_START_ROUND      = 0 << 3
GS_OPEN_ESCAPE_DOOR     = 1 << 6
GS_CLOSE_ESCAPE_DOOR    = 0 << 6
GS_TRAPPED_POLICE_REWARDED = 1 << 7
GS_TRAPPED_POLICE_NOT_REWARDED = 0 << 7
;
; sound id values
;
SOUND_ID_GOLD_BARS      = 1
SOUND_ID_CLOSE_DOOR     = 2
SOUND_ID_UPPER_TREASURE = 3
SOUND_ID_EXTRA_LIFE     = 4
SOUND_ID_POLICE_TRAPPED = 5
SOUND_ID_TREASURE_CAPTURED = 6
SOUND_ID_THIEF_CAPTURED = 7
SOUND_ID_THIEF_ESCAPE   = 8
;
; sound volume constants
;
INIT_GOLD_BAR_VOLUME    = 5
CLOSE_DOOR_VOLUME       = 15
UPPER_TREASURE_VOLUME   = 6
TREASURE_CAPTURED_VOLUME = 15
THIEF_CAPTURED_VOLUME   = 15
THIEF_ESCAPE_VOLUME     = 6
;
; sound frequency constants
;
GOLD_BAR_FREQUENCY      = 1
CLOSE_DOOR_FREQUENCY    = 2
UPPER_TREASURE_FREQUENCY = 31
EXTRA_LIFE_FREQUENCY    = 8
POLICE_TRAPPED_FREQUENCY = 8
TREASURE_CAPTURED_FREQUENCY = 31
THIEF_CAPTURED_FREQUENCY = 6
THIEF_ESCAPE_FREQUENCY  = 31
;
; sound tone constants
;
GOLD_BAR_TONE           = 1
CLOSE_DOOR_TONE         = 2
UPPER_TREASURE_TONE     = 12
EXTRA_LIFE_TONE         = 12
POLICE_TRAPPED_TONE     = 12
TREASURE_CAPTURED_TONE  = 4
THIEF_CAPTURED_TONE     = 8
THIEF_ESCAPE_TONE       = 4
;
; sound duration constants
;
GOLD_BAR_SOUND_DURATION = 5
CLOSE_DOOR_SOUND_DURATION = 3
UPPER_TREASURE_SOUND_DURATION = 255
EXTRA_LIFE_SOUND_DURATION = 96
POLICE_TRAPPED_SOUND_DURATION = 111
TREASURE_CAPTURED_SOUND_DURATION = 111
THIEF_CAPTURED_SOUND_DURATION = 56
THIEF_ESCAPE_SOUND_DURATION = 96
;
; point value constants
;
POINTS_20               = $0020
POINTS_250              = $0250
POINTS_500              = $0500
POINTS_1000             = $1000
POINTS_2000             = $2000
POINTS_4000             = $4000

POINTS_250_INDEX        = 0
POINTS_500_INDEX        = 1
POINTS_1000_INDEX       = 2
POINTS_2000_INDEX       = 3
POINTS_4000_INDEX       = 4
POINTS_20_INDEX         = 5

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
   SEG.U GAME_ZP_VARIABLES
   .org $80

playerScore             ds 6
gameLevelValues         ds 2
;--------------------------------------
leftPlayerLevel         = gameLevelValues
rightPlayerLevel        = leftPlayerLevel + 1
remainingLives          ds 2
;--------------------------------------
leftPlayerRemainingLives = remainingLives
rightPlayerRemainingLives = leftPlayerRemainingLives + 1
gameSelection           ds 1
currentPlayerNumber     ds 1
goldBarsTaken           ds 2
;--------------------------------------
leftPlayerGoldBarsTaken = goldBarsTaken
rightPlayerGoldBarsTaken = leftPlayerGoldBarsTaken + 1
gameState               ds 1
goldBarsRemaining       ds 1
goldBars                ds 23
;--------------------------------------
leftGoldBars            = goldBars
remainingUpperTreasures = leftGoldBars + 11
rightGoldBars           = leftGoldBars + 12
treasureTimerValues     ds 2
;--------------------------------------
lowerTreasureTimerValue = treasureTimerValues
upperTreasureTimerValue = lowerTreasureTimerValue + 1
upperTreasurePointIndex ds 1
remainingLowerTreasures ds 1
extraLifeRewardedState  ds 1
policeMovementState     ds 1
frameCount              ds 1
roundTransitionTimer    ds 1
;--------------------------------------
selectDebounceTimer     = roundTransitionTimer
bonusPointTimer         ds 1
objectHorizPositions    ds 5
;--------------------------------------
thiefHorizPosition      = objectHorizPositions
policeHorizPositions    = thiefHorizPosition + 1
objectKernelHorizPositions ds 5
;--------------------------------------
thiefKernelHorizPosition = objectKernelHorizPositions
policeKernelHorizPositions = thiefKernelHorizPosition + 1
objectVertPositions     ds 5
;--------------------------------------
thiefVertPosition       = objectVertPositions
policeVertPositions     = thiefVertPosition + 1
objectDirectionValues   ds 5
;--------------------------------------
thiefDirectionValue     = objectDirectionValues
policeDirectionValues   = thiefDirectionValue + 1
temporaryZPVariables    ds 23

   .org temporaryZPVariables
;
; Temporary directional variables
;
tmpPoliceDirectionValues ds NUM_POLICE
;--------------------------------------
tmpJoystickValues       = tmpPoliceDirectionValues + 1
;--------------------------------------
tmpAdjustedHorizPosition = tmpJoystickValues
tmpThiefIllegalDirections = tmpJoystickValues + 1
;--------------------------------------
tmpHorizPosDiv16        = tmpThiefIllegalDirections

   .org temporaryZPVariables + 7
   
tmpIllegalDirections    ds 1
tmpPoliceDirection      = tmpIllegalDirections + 2
tmpUpperTreasurePointIndex = tmpPoliceDirection + 2
;--------------------------------------
tmpGameLevelValues      = tmpUpperTreasurePointIndex
tmpPoliceTrappedState   = tmpUpperTreasurePointIndex + 2
tmpThiefMazePosition    = tmpPoliceTrappedState + 2
;--------------------------------------
tmpTreasureIndex        = tmpThiefMazePosition

   .org temporaryZPVariables + 17
   
tmpZonePoliceCount      ds [KERNEL_SECTIONS / 2]

   .org temporaryZPVariables + 17
;
; Temporary Police sort variables
;
tmpPoliceIndex          ds 1
tmpSortedPoliceIndexArray ds NUM_POLICE

   .org temporaryZPVariables
;
; Temporary display kernel variables
;
thiefGraphicPtrs        ds 2
policeGraphicPtrs_00    ds 2
policeGraphicPtrs_01    ds 2
graphicsPointers        ds 12
;--------------------------------------
tmpScanline             = graphicsPointers + 1
;--------------------------------------
tmpPoliceGraphicValue_00 = graphicsPointers + 3
;--------------------------------------
tmpEscapeDoorGraphicValue = graphicsPointers + 5
;--------------------------------------
tmpKernelSection        = graphicsPointers + 7
;--------------------------------------
tmpPoliceGraphicValue_01 = graphicsPointers + 9
;--------------------------------------
tmpScoreAreaChar        ds 1
tmpScoreAreaIndex       ds 1

   .org graphicsPointers + 11

tmpClosedDoorColumns    ds 6
;--------------------------------------
tmpClosedDoorColumn_00  = tmpClosedDoorColumns
tmpClosedDoorColumn_01  = tmpClosedDoorColumn_00 + 1
tmpClosedDoorColumn_02  = tmpClosedDoorColumn_01 + 1
tmpClosedDoorColumn_03  = tmpClosedDoorColumn_02 + 1
tmpClosedDoorColumn_04  = tmpClosedDoorColumn_03 + 1
tmpClosedDoorColumn_05  = tmpClosedDoorColumn_04 + 1

closedDoorMazePositionValues ds 2
;--------------------------------------
firstClosedDoorMazePosition = closedDoorMazePositionValues
secondClosedDoorMazePosition = firstClosedDoorMazePosition + 1
closedDoorTimerValues   ds 2
;--------------------------------------
firstClosedDoorTimer    = closedDoorTimerValues
secondClosedDoorTimer   = firstClosedDoorTimer + 1
previousThiefMazePosition ds 1
policeMovementDelay     ds 1
kernelZonePoliceIndexValues ds KERNEL_SECTIONS
thiefGraphicOffset      ds 1
policeGraphicOffset_00  ds 1
policeGraphicOffset_01  ds 1
policeScanline_00       ds 1
policeScanline_01       ds 1
joystickDirectionValues ds 1
soundDurationValues     ds 2
;--------------------------------------
leftChannelSoundDurationValue = soundDurationValues
rightChannelSoundDurationValue = leftChannelSoundDurationValue + 1
soundPriorityValues     ds 2
;--------------------------------------
leftChannelSoundPriorityValue = soundPriorityValues
rightChannelSoundPriorityValue = leftChannelSoundPriorityValue + 1
random                  ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

PrepareZoneForPolice_00
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpPoliceGraphicValue_01;3
   sta ENAM1                  ; 3 = @09
   asl                        ; 2
   asl                        ; 2
   sta NUSIZ1                 ; 3 = @16
   lda tmpPoliceGraphicValue_00;3
   sta GRP1                   ; 3 = @22
   lda tmpEscapeDoorGraphicValue;3
   sta ENAM0                  ; 3 = @28
   dey                        ; 2
   lda (thiefGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @38
   lda (policeGraphicPtrs_01),y;5
   sta tmpPoliceGraphicValue_01;3
   sta HMM1                   ; 3 = @49
   lda #0                     ; 2
   sta tmpPoliceGraphicValue_00;3
   lda kernelZonePoliceIndexValues - 1,x;4
   tax                        ; 2
   beq .skipPositionPolice_00 ; 2³
   lda objectVertPositions,x  ; 4
   sta policeScanline_00      ; 3
   lda policeGraphicOffset_00 ; 3
   sta WSYNC
;--------------------------------------
   sec                        ; 2
   sbc objectVertPositions,x  ; 4
   sta policeGraphicPtrs_00   ; 3
   lda objectKernelHorizPositions,x;4
   sta HMP1                   ; 3 = @16
   and #$0F                   ; 2
.coarsePositionPolice_00
   sbc #1                     ; 2
   bpl .coarsePositionPolice_00;2³
   sta RESP1                  ; 3
PrepareZoneForPolice_01
   ldx tmpKernelSection       ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpPoliceGraphicValue_01;3
   sta ENAM1                  ; 3 = @09
   asl                        ; 2
   asl                        ; 2
   sta NUSIZ1                 ; 3 = @16
   lda tmpPoliceGraphicValue_00;3
   sta GRP1                   ; 3 = @22
   dey                        ; 2
   lda (thiefGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @32
   lda (policeGraphicPtrs_00),y;5
   sta tmpPoliceGraphicValue_00;3
   sta HMCLR                  ; 3 = @43
   lda kernelZonePoliceIndexValues,x ;4
   tax                        ; 2
   beq .skipPositionPolice_01 ; 2³
   lda #0                     ; 2
   sta tmpPoliceGraphicValue_01;3
   sta ENAM1                  ; 3 = @59
   sta ENAM0                  ; 3 = @62
   lda objectVertPositions,x  ; 4
   sta policeScanline_01      ; 3
   lda policeGraphicOffset_01 ; 3
   sta WSYNC
;--------------------------------------
   sec                        ; 2
   sbc objectVertPositions,x  ; 4
   sta policeGraphicPtrs_01   ; 3
   lda objectKernelHorizPositions,x;4
   sta HMM1                   ; 3 = @16
   and #$0F                   ; 2
.coarsePositionPolice_01
   sbc #1                     ; 2
   bpl .coarsePositionPolice_01;2³
   sta RESM1                  ; 3
   jmp DrawZonePlayerObjects  ; 3
    
.skipPositionPolice_00
   sta WSYNC
;--------------------------------------
   lda (policeGraphicPtrs_00),y;5
   sta tmpPoliceGraphicValue_00;3
   cpy policeScanline_00      ; 3
   bcs .prepareZoneForPolice_01;2³
   sty tmpScanline            ; 3
   lda #<BlankPoliceGraphics + H_POLICE;2
   sec                        ; 2
   sbc tmpScanline            ; 3
   sta policeGraphicPtrs_00   ; 3
.prepareZoneForPolice_01
   jmp PrepareZoneForPolice_01; 3
    
.skipPositionPolice_01
   sta ENAM0                  ; 3 = @55
   sta WSYNC
;--------------------------------------
   lda (policeGraphicPtrs_01),y;5
   sta tmpPoliceGraphicValue_01;3
   sta HMM1                   ; 3 = @11
   cpy policeScanline_01      ; 3
   bcs .drawZonePlayerObjects ; 2³
   sty tmpScanline            ; 3
   lda #<BlankPoliceGraphics + H_POLICE;2
   sec                        ; 2
   sbc tmpScanline            ; 3
   sta policeGraphicPtrs_01   ; 3
.drawZonePlayerObjects
   jmp DrawZonePlayerObjects  ; 3
    
BeginDrawMazeKernel
   lda thiefKernelHorizPosition;3
   ldx #<HMP0 - HMP0          ; 2
   jsr HorizontallyPositionObjects;6
;--------------------------------------
   lda #$C0                   ; 2 = @11
   sta PF0                    ; 3 = @14
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @19
   lda #$7F                   ; 2
   sta PF2                    ; 3 = @24
   lda #0                     ; 2
   sta VDELP1                 ; 3 = @29
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @34
   ldx currentPlayerNumber    ; 3
   lda ThiefColorValues,x     ; 4
   sta COLUP0                 ; 3 = @44
   lda #COLOR_POLICE          ; 2
   sta COLUP1                 ; 3 = @49
   lda #MSBL_SIZE8 | ONE_COPY ; 2
   sta NUSIZ0                 ; 3 = @54
   lda #>PoliceGraphicData    ; 2
   sta policeGraphicPtrs_01 + 1;3
   sta policeGraphicPtrs_00 + 1;3
   lda #>ThiefGraphicData     ; 2
   sta thiefGraphicPtrs + 1   ; 3
   lda #<BlankPoliceGraphics + H_POLICE - H_KERNEL;2
   sta policeGraphicPtrs_01   ; 3
   sta policeGraphicPtrs_00   ; 3
;--------------------------------------
   lda thiefGraphicOffset     ; 3 = @02
   sec                        ; 2
   sbc thiefVertPosition      ; 3
   ldx thiefVertPosition      ; 3
   cpx #H_KERNEL              ; 2
   bcs .setThiefGraphicsLSB   ; 2³
   lda #<BlankThiefGraphics + H_THIEF - H_KERNEL;2
.setThiefGraphicsLSB
   sta thiefGraphicPtrs       ; 3
   lda #<-1                   ; 2
   sta policeScanline_01      ; 3
   sta policeScanline_00      ; 3
   sta HMCLR                  ; 3 = @30
   ldx #DISABLE_BM            ; 2
   stx tmpPoliceGraphicValue_01;3
   stx tmpPoliceGraphicValue_00;3
   lda gameState              ; 3         get current game state
   and #ESCAPE_DOOR_MASK      ; 2         keep ESCAPE_DOOR value
   bne .setEscapeDoorGraphicValue;2³      branch if GS_CLOSE_ESCAPE_DOOR
   ldx #<~DISABLE_BM          ; 2
.setEscapeDoorGraphicValue
   stx tmpEscapeDoorGraphicValue;3
   sta WSYNC
;--------------------------------------
   ldx #KERNEL_SECTIONS - 1   ; 2
   stx tmpKernelSection       ; 3
   ldy #H_KERNEL              ; 2
.drawMazeKernel
   lda #BLACK                 ; 2
   sta tmpClosedDoorColumn_00 ; 3
   sta tmpClosedDoorColumn_01 ; 3
   sta tmpClosedDoorColumn_02 ; 3
   sta tmpClosedDoorColumn_03 ; 3
   sta tmpClosedDoorColumn_04 ; 3
   sta tmpClosedDoorColumn_05 ; 3
   ldx tmpKernelSection       ; 3
   jsr PrepareZoneForPolice_00; 6
   jsr DrawTopMazeKernelZone  ; 6
   jsr DrawZonePlayerObjects  ; 6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawGoldBarKernel      ; 6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawMiddleMazeKernelZone;6
   dec tmpKernelSection       ; 5
   beq .doneDrawMazeKernel    ; 2³
   jsr DrawTopMazeKernelZone  ; 6
   jsr DrawZonePlayerObjects  ; 6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawMiddleMazeKernelZone;6
   jsr DrawGoldBarKernel      ; 6
   sta WSYNC
;--------------------------------------
   dec tmpKernelSection       ; 5
   jmp .drawMazeKernel        ; 3
    
.doneDrawMazeKernel
   jmp DrawScoreAreaKernel    ; 3
    
ThiefColorValues
   .byte COLOR_LEFT_PLAYER, COLOR_RIGHT_PLAYER
    
DrawTopMazeKernelZone
   sta WSYNC
;--------------------------------------
   lda #DISABLE_BM            ; 2
   sta tmpEscapeDoorGraphicValue;3
   ldx tmpKernelSection       ; 3
   lda MazePF0Data,x          ; 4
   sta PF0                    ; 3 = @15
   lda MazePF1Data,x          ; 4
   sta PF1                    ; 3 = @22
   lda MazePF2Data,x          ; 4
   sta PF2                    ; 3 = @29
   sty tmpScanline            ; 3
   tya                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc thiefVertPosition      ; 3         subtract Thief vertical postion
   bcc .skipThiefDraw         ; 2³        branch if out of range
   cmp #H_KERNEL_ZONE - 1     ; 2
   bcs .skipThiefDraw         ; 2³
   lda thiefGraphicOffset     ; 3         get Thief graphic offset value
   sec                        ; 2
   sbc thiefVertPosition      ; 3         subtract vertical position
   sta thiefGraphicPtrs       ; 3
   rts                        ; 6
    
.skipThiefDraw
   lda #<BlankThiefGraphics + H_THIEF;2
   sec                        ; 2
   sbc tmpScanline            ; 3
   sta thiefGraphicPtrs       ; 3
   rts                        ; 6
    
DrawMiddleMazeKernelZone
   sta WSYNC
;--------------------------------------
   lda gameState              ; 3         get current game state
   and #SHOW_UPPER_TREASURE_MASK;2        keep SHOW_UPPER_TREASURE value
   beq .checkToDrawLowerTreasure;2³       branch if not SHOW_UPPER_TREASURE
   lda #DISABLE_BM            ; 2
   cpy #UPPER_TREASURE_VERT_POS - 1;2
   bcc .drawUpperTreasureValue; 2³
   cpy #UPPER_TREASURE_VERT_POS + 2;2
   bcs .drawUpperTreasureValue; 2³
   lda #<~DISABLE_BM          ; 2         enable / draw upper treasure
.drawUpperTreasureValue
   sta ENAM0                  ; 3 = @22
.checkToDrawLowerTreasure
   lda gameState              ; 3         get current game state
   and #SHOW_LOWER_TREASURE_MASK;2        keep SHOW_LOWER_TREASURE value
   beq DrawZonePlayerObjects  ; 2³        branch if not SHOW_LOWER_TREASURE
   cpy #LOWER_TREASURE_VERT_POS;2
   beq .drawLowerTreasure     ; 2³
   cpy #LOWER_TREASURE_VERT_POS - 2;2
   bne DrawZonePlayerObjects  ; 2³
   lda #0                     ; 2
   sta PF2                    ; 3 = @42
   lda #COLOR_MAZE            ; 2
   sta COLUPF                 ; 3 = @47
   jmp DrawZonePlayerObjects  ; 3
    
.drawLowerTreasure
   lda #$80                   ; 2
   sta PF2                    ; 3 = @39
   lda #COLOR_LOWER_TREASURE  ; 2
   sta COLUPF                 ; 3 = @44
DrawZonePlayerObjects
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpPoliceGraphicValue_01;3
   sta ENAM1                  ; 3 = @09
   asl                        ; 2
   asl                        ; 2
   sta NUSIZ1                 ; 3 = @16
   lda tmpPoliceGraphicValue_00;3
   sta GRP1                   ; 3 = @22
   dey                        ; 2
   lda (thiefGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @32
   lda (policeGraphicPtrs_00),y;5
   sta tmpPoliceGraphicValue_00;3
   lda (policeGraphicPtrs_01),y;5
   sta tmpPoliceGraphicValue_01;3
   sta HMM1                   ; 3 = @51
   rts                        ; 6
    
DrawGoldBarKernel
   sta WSYNC
;--------------------------------------
   lda firstClosedDoorMazePosition;3      get first closed door position value
   asl                        ; 2         multiply by 2
   and #$0F                   ; 2         0 <= a <= 15
   cmp tmpKernelSection       ; 3
   bne .checkToDrawSecondClosedDoor;2³ + 1 skip drawing first closed door
   lda firstClosedDoorMazePosition;3      get first closed door position value
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2         divide by 8
   tax                        ; 2
   lda #COLOR_CLOSED_DOOR     ; 2
   sta tmpClosedDoorColumns - 1,x;4
.checkToDrawSecondClosedDoor
   lda secondClosedDoorMazePosition;3     get second closed door position value
   asl                        ; 2         multiply by 2
   and #$0F                   ; 2         0 <= a <= 15
   cmp tmpKernelSection       ; 3
   bne DrawClosedDoorKernel   ; 2³        skip drawing second closed door
   lda secondClosedDoorMazePosition;3     get second closed door position value
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2         divide by 8
   tax                        ; 2
   lda #COLOR_CLOSED_DOOR     ; 2
   sta tmpClosedDoorColumns - 1,x;4
DrawClosedDoorKernel
   lda tmpPoliceGraphicValue_01;3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENAM1                  ; 3 = @06
   asl                        ; 2
   asl                        ; 2
   sta NUSIZ1                 ; 3 = @13
   lda tmpPoliceGraphicValue_00;3
   sta GRP1                   ; 3 = @19
   ldx tmpClosedDoorColumn_03 ; 3
   lda tmpClosedDoorColumn_00 ; 3
   sta COLUBK                 ; 3 = @28
   lda tmpClosedDoorColumn_01 ; 3
   sta COLUBK                 ; 3 = @34
   dey                        ; 2
   lda tmpClosedDoorColumn_02 ; 3
   sta COLUBK                 ; 3 = @42
   lda (thiefGraphicPtrs),y   ; 5
   stx COLUBK                 ; 3 = @50
   ldx tmpClosedDoorColumn_04 ; 3
   stx COLUBK                 ; 3 = @56
   sta GRP0                   ; 3 = @59
   ldx tmpClosedDoorColumn_05 ; 3
   stx COLUBK                 ; 3 = @65
   lda #BLACK                 ; 2
   SLEEP 2                    ; 2
   sta COLUBK                 ; 3 = @72
   sta WSYNC
;--------------------------------------
   ldx tmpKernelSection       ; 3
   lda leftGoldBars - 1,x     ; 4
   and #GOLD_BARS_MASK        ; 2
   sta PF2                    ; 3 = @12
   eor leftGoldBars - 1,x     ; 4
   sta PF1                    ; 3 = @19
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda #COLOR_GOLD_BARS       ; 2
   sta COLUPF                 ; 3 = @28
   lda (policeGraphicPtrs_01),y;5
   sta tmpPoliceGraphicValue_01;3
   sta HMM1                   ; 3 = @39
   lda rightGoldBars - 1,x    ; 4
   and #GOLD_BARS_MASK        ; 2
   sta PF2                    ; 3 = @48
   eor rightGoldBars - 1,x    ; 4
   sta PF1                    ; 3 = @55
   lda (policeGraphicPtrs_00),y;5
   sta tmpPoliceGraphicValue_00;3
   SLEEP 2                    ; 2
   lda #COLOR_MAZE            ; 2
   sta COLUPF                 ; 3 = @70
   lda tmpPoliceGraphicValue_01;3
   sta ENAM1                  ; 3 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   asl                        ; 2
   asl                        ; 2
   sta NUSIZ1                 ; 3 = @10
   lda tmpPoliceGraphicValue_00;3
   sta GRP1                   ; 3 = @16
   lda MazePF1Data,x          ; 4
   sta PF1                    ; 3 = @23
   lda MazePF2Data,x          ; 4
   sta PF2                    ; 3 = @30
   dey                        ; 2
   lda (thiefGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @40
   lda (policeGraphicPtrs_00),y;5
   sta tmpPoliceGraphicValue_00;3
   lda (policeGraphicPtrs_01),y;5
   sta tmpPoliceGraphicValue_01;3
   sta HMM1                   ; 3 = @59
   rts                        ; 6
    
DrawScoreAreaKernel
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta ENAM1                  ; 3 = @11
   lda #MSBL_SIZE1 | THREE_COPIES;2
   sta NUSIZ0                 ; 3 = @16
   sta NUSIZ1                 ; 3 = @19
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @24
   sta VDELP1                 ; 3 = @27
   lda #0                     ; 2
   sta GRP0                   ; 3 = @32
   ldx #HMOVE_R3              ; 2
   lda #HMOVE_R2              ; 2
   sta RESP0                  ; 3 = @39
   sta RESP1                  ; 3 = @42
   sta HMP1                   ; 3 = @45
   stx HMP0                   ; 3 = @48
   lda #>ScoreAreaGraphicData ; 2
   sta graphicsPointers + 1   ; 3
   sta graphicsPointers + 7   ; 3
   sta graphicsPointers + 3   ; 3
   sta graphicsPointers + 9   ; 3
   sta graphicsPointers + 5   ; 3
   sta graphicsPointers + 11  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   ldx currentPlayerNumber    ; 3
   lda RemainingLivesColorValues,x;4
   sta COLUP0                 ; 3 = @21
   sta COLUP1                 ; 3 = @24
   lda gameState              ; 3         get current game state
   and #GAME_ACTIVE_MASK      ; 2         keep GAME_ACTIVE value
   bne .setStatusAreaObjectColors;2³      branch if GAME_ACTIVE
   lda #COLOR_RIGHT_PLAYER_REMAINING_LIVES;2
   sta COLUP0                 ; 3 = @36
.setStatusAreaObjectColors
   lda bonusPointTimer        ; 3         get bonus point timer value
   bne .blinkScore            ; 2³        blink bonus point value
   lda remainingLives,x       ; 4         get player remaining lives
   bne DrawScoreArea          ; 2³ + 1
.blinkScore
   lda frameCount             ; 3         get current frame count
   and #8                     ; 2
   beq DrawScoreArea          ; 2³
   lda BlinkingScoreAreaColors,x;4
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
DrawScoreArea
   ldy #H_DIGITS - 1          ; 2
.drawScoreArea
   sty tmpScoreAreaIndex      ; 3
   lda (graphicsPointers + 10),y;5        
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda (graphicsPointers + 4),y;5
   sta tmpScoreAreaChar       ; 3
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @16
   lda (graphicsPointers + 6),y;5
   sta GRP1                   ; 3 = @24
   lda (graphicsPointers + 2),y;5
   sta GRP0                   ; 3 = @32
   lda (graphicsPointers + 8),y;5
   tay                        ; 2
   lda tmpScoreAreaChar       ; 3
   sty GRP1                   ; 3 = @45
   sta GRP0                   ; 3 = @48
   stx GRP1                   ; 3 = @51
   sta GRP0                   ; 3 = @54
   ldy tmpScoreAreaIndex      ; 3
   dey                        ; 2
   bpl .drawScoreArea         ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta GRP0                   ; 3 = @11
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   sta PF1                    ; 3 = @06
   sta PF2                    ; 3 = @09
   rts                        ; 6
    
RemainingLivesColorValues
   .byte COLOR_LEFT_PLAYER_REMAINING_LIVES
   .byte COLOR_RIGHT_PLAYER_REMAINING_LIVES

BlinkingScoreAreaColors
   .byte BLACK + 8, BLACK + 8
    
ResetGame
   ldy gameSelection                ; get current game selection
   bne ClearRAM                     ; branch if TWO_PLAYER game
Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldy #0
ClearRAM
   lda #0
   tax
.clearZPRAM
   sta VSYNC,x
   dex
   bne .clearZPRAM
   sty gameSelection                ; set current game selection
   lda #INIT_LIVES
   sta leftPlayerRemainingLives
   sta rightPlayerRemainingLives
   jmp InitGameVariables
    
StartNewRound
   jsr WaitForTimerExpiration
   lda #KERNEL_TIME
   sta TIM64T
   ldx #<playerScore
   lda #0
.resetGameVariables
   dex
   sta VSYNC,x
   cpx #<extraLifeRewardedState
   bne .resetGameVariables
   ldx currentPlayerNumber
   lda remainingLives,x             ; get player remaining lives
   beq .alternatePlayers            ; branch if no lives remaining
   lda gameState                    ; get current game state
   and #ALTERNATE_PLAYERS_MASK      ; keep ALTERNATE_PLAYERS value
   beq .setNewRoundGameState        ; branch if not alternating players
.alternatePlayers
   lda gameSelection                ; get current game selection
   eor currentPlayerNumber
   sta currentPlayerNumber
.setNewRoundGameState
   ldx currentPlayerNumber
   lda #GS_START_ROUND | GS_GAME_ACTIVE
   ldy remainingLives,x             ; get player remaining lives
   bne .doneStartNewRound           ; branch if lives remaining
   lda #180
   sta roundTransitionTimer
   lda #GS_PAUSE_MOVEMENT | GS_GAME_ACTIVE
.doneStartNewRound
   sta gameState
InitGameVariables
   ldy #22
.initVariables
   ldx InitVariableIndexValues - 1,y
   lda InitVariableValues - 1,y
   sta playerScore,x
   dey
   bne .initVariables
   lda upperTreasureTimerValue
   ora #$40
   sta upperTreasureTimerValue
   lda gameSelection                ; get current game selection
   bne ResetGoldBars                ; branch if TWO_PLAYER game
   lda goldBarsRemaining            ; get remaining Gold Bars
   bne .horizontalPositionUpperTreasure;branch if Gold Bars remaining
ResetGoldBars
   ldx #11
.storeGoldBarPatterns
   lda ROMGoldBarPatterns,x
   sta leftGoldBars - 1,x
   sta rightGoldBars - 1,x
   dex
   bpl .storeGoldBarPatterns
   lda #MAX_UPPER_TREASURES
   sta remainingUpperTreasures
   lda #0
   sta upperTreasurePointIndex      ; clear Treasure point index value
   lda #MAX_GOLD_BARS
   sta goldBarsRemaining
.horizontalPositionUpperTreasure
   ldx #$FF
   txs
   lda #HMOVE_R5 | 4
   ldx #<HMM0 - HMP0
   jsr HorizontallyPositionObjects
   jmp Overscan
    
ROMGoldBarPatterns
   .byte $00,$7F,$61,$6B,$61,$7F
   .byte $61,$75,$61,$7F,$60,$7F
    
InitVariableIndexValues
   .byte <thiefHorizPosition - playerScore
   .byte <policeHorizPositions - playerScore
   .byte <policeHorizPositions - playerScore + 1
   .byte <policeHorizPositions - playerScore + 2
   .byte <policeHorizPositions - playerScore + 3
   .byte <thiefKernelHorizPosition - playerScore
   .byte <policeKernelHorizPositions - playerScore
   .byte <policeKernelHorizPositions - playerScore + 1
   .byte <policeKernelHorizPositions - playerScore + 2
   .byte <policeKernelHorizPositions - playerScore + 3
   .byte <thiefVertPosition - playerScore
   .byte <policeVertPositions - playerScore
   .byte <policeVertPositions - playerScore + 1
   .byte <policeVertPositions - playerScore + 2
   .byte <policeVertPositions - playerScore + 3
   .byte <policeDirectionValues - playerScore
   .byte <policeDirectionValues - playerScore + 1
   .byte <policeDirectionValues - playerScore + 2
   .byte <policeDirectionValues - playerScore + 3
   .byte <[VDELP0 + 256] - playerScore
   .byte <[CTRLPF + 256] - playerScore
   .byte <remainingLowerTreasures - playerScore
   
InitVariableValues
   .byte INIT_THIEF_HORIZ
   .byte INIT_LEFT_POLICE_HORIZ
   .byte INIT_RIGHT_POLICE_HORIZ
   .byte INIT_LEFT_POLICE_HORIZ
   .byte INIT_RIGHT_POLICE_HORIZ
   .byte HMOVE_R4 | 4
   .byte HMOVE_L1 | 0
   .byte HMOVE_L6 | 9
   .byte HMOVE_L1 | 0
   .byte HMOVE_L6 | 9
   .byte INIT_THIEF_VERT
   .byte INIT_POLICE_VERT_00
   .byte INIT_POLICE_VERT_01
   .byte INIT_POLICE_VERT_02
   .byte INIT_POLICE_VERT_02
   .byte <~MOVE_RIGHT
   .byte <~MOVE_LEFT
   .byte <~MOVE_RIGHT
   .byte <~MOVE_LEFT
   .byte 4 | VERTICAL_DELAY
   .byte MSBL_SIZE1 | PF_REFLECT
   .byte MAX_LOWER_TREASURES
    
Overscan
   jsr WaitForTimerExpiration
   lda #DISABLE_TIA
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   lda roundTransitionTimer
   beq .skipReduceRoundTransitionTimer;branch if timer not expired
   dec roundTransitionTimer
.skipReduceRoundTransitionTimer
   jsr DetermineStatusAreaActivity
   dec frameCount
   jsr NextRandom
   jsr CheckToSpawnTreasure
   jsr PlayGameSounds
   jsr AnimateThiefAndPoliceObjects
   jsr ReadConsoleSwitches
   jsr WaitForTimerExpiration
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   lda #START_VERT_SYNC
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   lda #STOP_VERT_SYNC
   sta VSYNC                        ; stop vertical sync (D1 = 0)
   lda gameState                    ; get current game state
   and #GAME_ACTIVE_MASK            ; keep GAME_ACTIVE value
   bne .gameActive                  ; branch if GAME_ACTIVE
   ldy #$80
   lda SWCHB                        ; read the console switches
   asl                              ; shift right player difficulty to carry
   bcc .checkLeftPlayerDifficultySetting;branch if set to AMATEUR
   sty rightPlayerLevel             ; set right player game level value
.checkLeftPlayerDifficultySetting
   asl                              ; shift left player difficulty to carry
   bcc .checkActionButtonsToStartRound;branch if set to AMATEUR
   sty leftPlayerLevel              ; set left player game level value
.checkActionButtonsToStartRound
   lda INPT4                        ; read left port joystick trigger
   and INPT5                        ; combine with right port joystick trigger
   bmi .skipDeterminePoliceDirections;branch if joystick triggers not pressed
   lda #GS_START_ROUND | GS_GAME_ACTIVE
   sta gameState
   lda #30
   sta roundTransitionTimer
   jmp .skipDeterminePoliceDirections
    
.gameActive
   lda gameState                    ; get current game state
   and #PAUSE_MOVEMENT_MASK         ; keep PAUSE_MOVEMENT value
   beq .checkToStartRound           ; branch if GS_ALLOW_MOVEMENT
   lda roundTransitionTimer
   bne .skipDeterminePoliceDirections;branch if timer not expired
   lda gameSelection                ; get current game selection
   ora leftPlayerRemainingLives     ; combine with left player remaining lives
   beq .skipDeterminePoliceDirections
   lda leftPlayerRemainingLives     ; get left player remaining lives
   ora rightPlayerRemainingLives    ; combine with right player remaining lives
   beq .startNewRound               ; branch if no lives remaining
   lda gameState                    ; get current game state
   and #ALTERNATE_PLAYERS_MASK      ; keep ALTERNATE_PLAYERS value
   ldx currentPlayerNumber
   ora remainingLives,x
   beq .startNewRound
   lda INPT4                        ; read left port joystick trigger
   and INPT5                        ; combine with right port joystick trigger
   bmi .skipDeterminePoliceDirections;branch if joystick triggers not pressed
.startNewRound
   jmp StartNewRound
    
.checkToStartRound
   lda gameState                    ; get current game state
   and #ROUND_START_MASK            ; keep ROUND_START value
   beq .processGameLogic            ; branch if GS_NOT_START_ROUND
   lda #YMAX
   sta thiefVertPosition
   lda INPT4                        ; read left port joystick trigger
   and INPT5                        ; combine with right port joystick trigger
   bpl .skipDeterminePoliceDirections;branch if joystick triggers pressed
   lda SWCHA                        ; read joystick values
   cmp #NO_MOVE
   beq .skipDeterminePoliceDirections;branch if joystick not moving
   lda #GS_GAME_ACTIVE
   sta gameState
.processGameLogic
   lda frameCount                   ; get current frame count
   and #1
   bne .determinePoliceDirections
   jsr DetermineThiefDirections
   jsr MoveObjects
   jsr CheckRemovingGoldBar
   jsr CheckThiefCaptured
   jsr DetermineClosedDoor
   jmp .skipDeterminePoliceDirections
    
.determinePoliceDirections
   jsr DeterminePoliceDirections
.skipDeterminePoliceDirections
   jsr PerformSortPoliceRoutine
   jsr SetPoliceKernelZones
   jsr WaitForTimerExpiration
   lda #ENABLE_TIA
   sta VBLANK
   lda #KERNEL_TIME
   sta TIM64T                       ; set timer for kernel period
   sta WSYNC                        ; wait for next scan line
   jsr BeginDrawMazeKernel
   jmp Overscan
    
WaitForTimerExpiration
   lda T1024T                       ; read interrupt flag
   bpl .waitTime                    ; branch if time not expired
   SLEEP 2
.waitTime
   sta WSYNC                        ; wait for next scan line
   lda T1024T                       ; read interrupt flag
   bpl .waitTime                    ; branch if time not expired
   rts
    
CheckThiefCaptured
   lda gameState                    ; get current game state
   and #PAUSE_MOVEMENT_MASK         ; keep PAUSE_MOVEMENT value
   bne .doneCheckThiefCaptured      ; branch if GS_PAUSE_MOVEMENT
   ldx #NUM_POLICE
.checkThiefCaptured
   lda thiefHorizPosition           ; get Thief horizontal position
   cmp policeHorizPositions - 1,x   ; compare with Police horizontal position
   bne .checkThiefAndPoliceVerticalPosition
   lda thiefVertPosition            ; get Thief vertical position
   sbc policeVertPositions - 1,x    ; subtract Police vertical position
   adc #4
   cmp #12
   bcc .thiefCaptured
.checkThiefAndPoliceVerticalPosition
   lda thiefVertPosition            ; get Thief vertical position
   cmp policeVertPositions - 1,x    ; compare with Police vertical position
   bne .checkNextPoliceForThiefCapture
   lda thiefHorizPosition           ; get Thief horizontal position
   sbc policeHorizPositions - 1,x   ; subtract Police horizontal position
   adc #5
   cmp #12
   bcc .thiefCaptured
.checkNextPoliceForThiefCapture
   dex
   bne .checkThiefCaptured
   lda goldBarsRemaining            ; get remaining Gold Bars
   bne .doneCheckThiefCaptured
   lda thiefVertPosition            ; get Thief vertical position
   cmp #H_KERNEL - 1
   beq .thiefEscaped
   lda gameState                    ; get current game state
   ora #GS_OPEN_ESCAPE_DOOR
   sta gameState
   rts
    
.thiefEscaped
   lda #SOUND_ID_THIEF_ESCAPE
   jsr SetSoundEngineValues
   lda #GS_PAUSE_MOVEMENT | GS_GAME_ACTIVE
   jmp .closeEscapeDoor
    
.thiefCaptured
   lda #SOUND_ID_THIEF_CAPTURED
   jsr SetSoundEngineValues
   ldx currentPlayerNumber
   ldy remainingLives,x             ; get player remaining lives
   dey                              ; decrement remaining lives
   sty remainingLives,x
   lda #GS_PAUSE_MOVEMENT | GS_GAME_ACTIVE | GS_ALTERNATE_PLAYERS
.closeEscapeDoor
   ora gameState
   and #<~ESCAPE_DOOR_MASK          ; set to GS_CLOSE_ESCAPE_DOOR
   sta gameState
   lda #30
   ldx currentPlayerNumber
   ldy leftPlayerRemainingLives     ; get left player remaining lives
   bne .checkToAdvanceGameLevel     ; branch if lives remaining
   lda #180
.checkToAdvanceGameLevel
   sta roundTransitionTimer
   lda goldBarsTaken,x              ; get number of Gold Bars taken
   sec
   sbc #MAX_GOLD_BARS               ; subtract maximum number of Gold Bars
   bcc .doneCheckThiefCaptured
   sta goldBarsTaken,x
   ldy gameLevelValues,x
   iny                              ; increment game level
   sty gameLevelValues,x
.doneCheckThiefCaptured
   rts
    
ReadConsoleSwitches
   lda SWCHB                        ; read the console switches
   lsr                              ; shift RESET to carry
   bcs .checkForGameSelectPressed   ; branch if RESET not pressed
   jmp ResetGame
    
.checkForGameSelectPressed
   lda gameState                    ; get current game state
   and #GAME_ACTIVE_MASK            ; keep GAME_ACTIVE value
   bne .doneReadConsoleSwitches     ; branch if GAME_ACTIVE
   lda SWCHB                        ; read the console switches
   lsr
   lsr                              ; shift SELECT to carry
   bcs .doneReadConsoleSwitches     ; branch if SELECT not pressed
   lda selectDebounceTimer
   cmp #5
   bcs .resetSelectDebounceTimer
   lda gameSelection                ; get current game selection
   eor #1
   sta gameSelection
.resetSelectDebounceTimer
   lda #10
   sta selectDebounceTimer
.doneReadConsoleSwitches
   rts

SoundVolumeValues
   .byte 0                          ; invalid
   .byte INIT_GOLD_BAR_VOLUME
   .byte CLOSE_DOOR_VOLUME
   .byte UPPER_TREASURE_VOLUME
   .byte 0                          ; not used
   .byte 0                          ; not used
   .byte TREASURE_CAPTURED_VOLUME
   .byte THIEF_CAPTURED_VOLUME
   .byte THIEF_ESCAPE_VOLUME

SoundFrequencyValues
   .byte 0                          ; invalid
   .byte GOLD_BAR_FREQUENCY
   .byte CLOSE_DOOR_FREQUENCY
   .byte UPPER_TREASURE_FREQUENCY
   .byte EXTRA_LIFE_FREQUENCY
   .byte POLICE_TRAPPED_FREQUENCY
   .byte TREASURE_CAPTURED_FREQUENCY
   .byte THIEF_CAPTURED_FREQUENCY
   .byte THIEF_ESCAPE_FREQUENCY

SoundToneValues
   .byte 0                          ; invalid
   .byte GOLD_BAR_TONE
   .byte CLOSE_DOOR_TONE
   .byte UPPER_TREASURE_TONE
   .byte EXTRA_LIFE_TONE
   .byte POLICE_TRAPPED_TONE
   .byte TREASURE_CAPTURED_TONE
   .byte THIEF_CAPTURED_TONE
   .byte THIEF_ESCAPE_TONE

SoundDurationValues
   .byte 0                          ; invalid
   .byte GOLD_BAR_SOUND_DURATION
   .byte CLOSE_DOOR_SOUND_DURATION
   .byte UPPER_TREASURE_SOUND_DURATION
   .byte EXTRA_LIFE_SOUND_DURATION
   .byte POLICE_TRAPPED_SOUND_DURATION
   .byte TREASURE_CAPTURED_SOUND_DURATION
   .byte THIEF_CAPTURED_SOUND_DURATION
   .byte THIEF_ESCAPE_SOUND_DURATION
    
SetSoundEngineValues
   ldx #1
.setSoundEngineValues
   cmp soundPriorityValues,x
   bcc .setNextSoundEngineValue
   tay                              ; move sound priority id to y register
   sty soundPriorityValues,x
   lda SoundVolumeValues,y
   sta AUDV0,x
   lda SoundFrequencyValues,y
   sta AUDF0,x
   lda SoundToneValues,y
   sta AUDC0,x
   lda SoundDurationValues,y
   sta soundDurationValues,x
   rts
    
.setNextSoundEngineValue
   dex
   bpl .setSoundEngineValues
   rts
    
PlayGameSounds
   ldx #1
.playSoundChannelSounds
   ldy soundDurationValues,x        ; get sound duration value
   beq .doneSoundChannelSounds
   dey
   sty soundDurationValues,x
   tya                              ; move sound duration to accumulator
   ldy soundPriorityValues,x        ; get sound priority id
   cpy #SOUND_ID_CLOSE_DOOR
   bne .checkToPlayExtraLifeSounds  ; branch if not SOUND_ID_CLOSE_DOOR
   asl
   asl
   sta AUDV0,x
.checkToPlayExtraLifeSounds
   cpy #SOUND_ID_EXTRA_LIFE
   bne .checkToPlayPoliceCapturedSounds;branch if not SOUND_ID_EXTRA_LIFE
   and #$0F                         ; 0 <= a <= 15
   sta AUDV0,x
.checkToPlayPoliceCapturedSounds
   cpy #SOUND_ID_POLICE_TRAPPED
   bne .checkToPlayThiefCapturedSounds;branch if not SOUND_ID_POLICE_TRAPPED
   asl                              ; multiply duration by 2
   and #8
   sta AUDV0,x
.checkToPlayThiefCapturedSounds
   cpy #SOUND_ID_THIEF_CAPTURED
   bne .checkToPlayGoldBarsSounds   ; branch if not SOUND_ID_THIEF_CAPTURED
   lsr
   lsr
   sta AUDV0,x
.checkToPlayGoldBarsSounds
   cpy #SOUND_ID_GOLD_BARS
   bne .checkToPlayThiefEscapedSounds;branch if not SOUND_ID_GOLD_BARS
   sta AUDV0,x
.checkToPlayThiefEscapedSounds
   cpy #SOUND_ID_THIEF_ESCAPE
   bne .checkToPlayUpperTreasureSounds;branch if not SOUND_ID_THIEF_ESCAPE
   and #$1F                         ; 0 <= a <= 31
   sta AUDF0,x
.checkToPlayUpperTreasureSounds
   cpy #SOUND_ID_UPPER_TREASURE
   bne .checkToPlayTreasureCapturedSounds;branch if not SOUND_ID_UPPER_TREASURE
   lsr
   lsr
   and #$0F                         ; 0 <= a <= 15
   tay
   lda UpperTreasureFrequencyValues,y
   sta AUDF0,x
   jmp .playNextSoundChannelSounds
    
UpperTreasureFrequencyValues
   .byte 8, 9, 10, 11, 12, 13, 14, 15
   .byte 16, 15, 14, 13, 12, 11, 10, 9
    
.checkToPlayTreasureCapturedSounds
   cpy #SOUND_ID_TREASURE_CAPTURED
   bne .playNextSoundChannelSounds  ; branch if not SOUND_ID_TREASURE_CAPTURED
   lsr
   
   IF COMPILE_REGION = PAL50
   
      bcs .playNextSoundChannelSounds
      
   ENDIF

   and #$1F                         ; 0 <= a <= 31
   sta AUDF0,x
.playNextSoundChannelSounds
   dex
   bpl .playSoundChannelSounds
   rts
    
.doneSoundChannelSounds
   sty AUDC0,x
   sty AUDV0,x
   sty soundPriorityValues,x
   jmp .playNextSoundChannelSounds
    
DetermineStatusAreaActivity
   lda gameState                    ; get current game state
   and #ROUND_START_MASK            ; keep ROUND_START value
   bne ShowRemainingLives
   lda gameState                    ; get current game state
   and #GAME_ACTIVE_MASK            ; keep GAME_ACTIVE value
   beq ShowCurrentGameSelection     ; branch if not GAME_ACTIVE
   ldx bonusPointTimer              ; get bonus point timer value
   beq CheckToRewardExtraLife       ; branch if bonus point timer expired
   dex
   stx bonusPointTimer              ; reduce bonus point timer
.doneDetermineStatusAreaActivity
   rts
    
CheckToRewardExtraLife
   ldx currentPlayerNumber
   lda playerScore + 4,x            ; get score thousands value
   beq .noExtraLifeReward           ; branch if no thousands value
   and #1
   bne .noExtraLifeReward           ; branch if not 10,000
   ldy extraLifeRewardedState
   beq BCDToDigits                  ; branch if extra life rewarded
   ldy remainingLives,x             ; get player remaining lives
   iny                              ; increment remaining lives
   cpy #MAX_LIVES
   bcs .setSoundForExtraLifeReward
   sty remainingLives,x             ; set new lives count
.setSoundForExtraLifeReward
   lda #0
   sta extraLifeRewardedState
   lda #SOUND_ID_EXTRA_LIFE
   jsr SetSoundEngineValues
   jmp BCDToDigits
    
.noExtraLifeReward
   lda #1
   sta extraLifeRewardedState
BCDToDigits
   ldx currentPlayerNumber
   ldy #4
.bcdToDigits
   lda playerScore,x                ; get player score value
   and #$0F                         ; keep lower nybbles
   asl                              ; multiply by 8 (i.e. H_FONT)
   asl
   asl
   sta graphicsPointers + 6,y
   lda playerScore,x                ; get player score value
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2
   sta graphicsPointers,y
   inx
   inx
   dey
   dey
   bpl .bcdToDigits
   rts
    
ShowRemainingLives
   ldx currentPlayerNumber
   ldy remainingLives,x             ; get player remaining lives
   ldx StatusAreaRemainingLives,y
   ldy #10
   bne .setGraphicPointerValues

ShowCurrentGameSelection
   ldy gameSelection                ; get current game selection
   ldx StatusAreaGameSelection,y
   ldy #10
   bne .setGraphicPointerValues

IncrementPlayerScore
   sed
   clc
   lda PointsOnesValues,y           ; get ones point value
   ldx currentPlayerNumber
   adc playerScore,x                ; increment score ones value
   sta playerScore,x
   lda PointsHundredsValues,y       ; get hundreds point value
   adc playerScore + 2,x            ; increment score hundreds value
   sta playerScore + 2,x
   lda #1 - 1
   adc playerScore + 4,x            ; increment thousands value
   sta playerScore + 4,x
   cld
   bcc .doneDetermineStatusAreaActivity
   lda #$99                         ; set to max score when reached 1M points
   sta playerScore,x
   sta playerScore + 2,x
   sta playerScore + 4,x
   rts

PointsOnesValues
   .byte [POINTS_250 & $FF], [POINTS_500 & $FF], [POINTS_1000 & $FF]
   .byte [POINTS_2000 & $FF], [POINTS_4000 & $FF], [POINTS_20 & $FF]

PointsHundredsValues
   .byte [POINTS_250 >> 8], [POINTS_500 >> 8], [POINTS_1000 >> 8]
   .byte [POINTS_2000 >> 8], [POINTS_4000 >> 8], [POINTS_20 >> 8]
    
ShowBonusPointValue
   lda #INIT_BONUS_POINT_TIMER_VALUE
   sta bonusPointTimer
   ldx StatusAreaBonusPointLiterals,y
   ldy #10
.setGraphicPointerValues
   lda StatusAreaGraphicLSBValues,x
   sta graphicsPointers,y
   dex
   dey
   dey
   bpl .setGraphicPointerValues
   rts
    
StatusAreaBonusPointLiterals
   .byte <[StatusAreaPoints_250 - StatusAreaGraphicLSBValues]  + 5
   .byte <[StatusAreaPoints_500 - StatusAreaGraphicLSBValues]  + 5
   .byte <[StatusAreaPoints_1000 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaPoints_2000 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaPoints_4000 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaPoints_250 - StatusAreaGraphicLSBValues]  + 5

StatusAreaRemainingLives
   .byte 0                          ; invalid
   .byte <[StatusAreaLives_00 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaLives_01 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaLives_02 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaLives_03 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaLives_04 - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaLives_05 - StatusAreaGraphicLSBValues] + 5

StatusAreaGameSelection
   .byte <[StatusAreaOnePlayer - StatusAreaGraphicLSBValues] + 5
   .byte <[StatusAreaTwoPlayers - StatusAreaGraphicLSBValues] + 5

StatusAreaGraphicLSBValues
StatusAreaPoints_500
   .byte <Blank, <five, <zero, <Plus, <zero, <Blank
StatusAreaPoints_1000
   .byte <Plus, <zero, <zero, <one, <zero, <Blank
StatusAreaPoints_2000
   .byte <Plus, <zero, <zero, <two, <zero, <Blank
StatusAreaPoints_4000
   .byte <Plus, <zero, <zero, <four, <zero, <Blank
StatusAreaPoints_250
   .byte <Blank, <two, <zero, <Plus, <five, <Blank
StatusAreaLives_00
   .byte <Blank, <Blank, <Blank, <Blank, <Blank, <Blank
StatusAreaLives_01
   .byte <Blank, <Blank, <LivesIndicator, <Blank, <Blank, <Blank
StatusAreaLives_02
   .byte <Blank, <Blank, <LivesIndicator, <Blank, <LivesIndicator, <Blank
StatusAreaLives_03
   .byte <Blank, <LivesIndicator, <LivesIndicator, <Blank, <LivesIndicator, <Blank
StatusAreaLives_04
   .byte <Blank, <LivesIndicator, <LivesIndicator, <LivesIndicator, <LivesIndicator, <Blank
StatusAreaLives_05
   .byte <Blank, <LivesIndicator, <LivesIndicator, <LivesIndicator, <LivesIndicator, <LivesIndicator
StatusAreaOnePlayer
   .byte <Blank, <Blank, <Blank, <Blank, <Blank, <Blank
StatusAreaTwoPlayers
   .byte <Blank, <Blank, <LivesIndicator, <LivesIndicator, <Blank, <Blank
    
.doneCheckToSpawnTreasure
   rts

CheckToSpawnTreasure
   lda bonusPointTimer              ; get bonus point timer value
   bne .doneCheckToSpawnTreasure    ; branch if bonue point timer not expired
   ldx currentPlayerNumber
   lda gameLevelValues,x            ; get current game level
   and #$0F                         ; keep lower nybbles
   cmp #MAX_UPPER_TREASURE_POINT_IDX
   bcc .checkToSpawnUpperTreasure
   lda #MAX_UPPER_TREASURE_POINT_IDX
.checkToSpawnUpperTreasure
   sta tmpUpperTreasurePointIndex
   ldx #1
   lda gameState                    ; get current game state
   and TreasureMaskValues,x         ; keep Treasure mask value
   bne CheckThiefTakingTreasure     ; branch if Treasure shown
   ldy remainingUpperTreasures
   lda goldBarsRemaining            ; get remaining Gold Bars
   cmp UpperTreasureGoldBarTreshold,y;compare with Gold Bar treshold value
   bcs .turnOffTreasure             ; branch if not taken enough Gold Bars
   lda #SOUND_ID_UPPER_TREASURE
   jsr SetSoundEngineValues         ; initiate sound for Upper Treasure
   dec remainingUpperTreasures      ; decrement times Upper Treasure shown
   jmp .setGameStateForSpawnedTreasure
    
.checkToSpawnLowerTreasure
   lda gameState                    ; get current game state
   and TreasureMaskValues,x         ; keep Treasure mask value
   bne CheckThiefTakingTreasure     ; branch if lower Treasure shown
   lda gameState                    ; get current game state
   beq .turnOffTreasure
   and #ROUND_START_MASK | PAUSE_MOVEMENT_MASK
   bne .turnOffTreasure
   lda thiefVertPosition            ; get Thief vertical position
   cmp #LOWER_TREASURE_VERT_POS
   beq .checkToSpawnNextTreasure    ; branch if Thief in Lower Treasure zone
   lda frameCount                   ; get current frame count
   and #3                           ; 0 <= a <= 3
   bne .checkToSpawnNextTreasure
   ldy treasureTimerValues,x        ; get Lower Treasure timer
   dey                              ; decrement lower Treasure timer
   sty treasureTimerValues,x
   bne .checkToSpawnNextTreasure
   lda remainingLowerTreasures      ; get remaining Lower Treasure value
   beq .checkToSpawnNextTreasure    ; branch if no more Lower Treasure
   dec remainingLowerTreasures      ; reduce remaining Lower Treasures
.setGameStateForSpawnedTreasure
   lda gameState                    ; get current game state
   ora TreasureMaskValues,x
   sta gameState
   lda #255
   sta treasureTimerValues,x
   ldy TreasureIndexValues,x        ; get Treasure index value
   lda leftGoldBars - 1,y
   ora #$80
   sta leftGoldBars - 1,y
   lda rightGoldBars - 1,y
   ora #$80
   sta rightGoldBars - 1,y
   rts
    
.turnOffTreasure
   jsr RemoveTreasureFromDisplay
.checkToSpawnNextTreasure
   dex
   bpl .checkToSpawnLowerTreasure
   rts
    
CheckThiefTakingTreasure
   lda thiefVertPosition            ; get Thief vertical position
   cmp TreasureVerticalPositionValues,x
   bne .thiefNotCapturedTreasure
   lda thiefHorizPosition           ; get Thief horizontal position
   cmp #TREASURE_HORIZ_POS
   bne .thiefNotCapturedTreasure
   stx tmpTreasureIndex             ; set captured Treasure index value
   ldy tmpUpperTreasurePointIndex
   txa                              ; move Treasure index to accumulator
   beq .thiefCapturedTreasure       ; branch if captured lower Treasure
   ldy upperTreasurePointIndex      ; get Treasure point index value
   iny                              ; increment Treasure point index
   sty upperTreasurePointIndex      ; set new Treasure point index value
.thiefCapturedTreasure
   jsr IncrementPlayerScore
   jsr ShowBonusPointValue
   lda #SOUND_ID_TREASURE_CAPTURED
   jsr SetSoundEngineValues
   ldx tmpTreasureIndex
   jmp .removeCapturedTreasureState

.thiefNotCapturedTreasure
   ldy treasureTimerValues,x
   dey
   sty treasureTimerValues,x
   bne .checkToSpawnNextTreasure
.removeCapturedTreasureState
   lda gameState                    ; get current game state
   eor TreasureMaskValues,x         ; flip Treasure show value
   sta gameState
   lda #255
   sta treasureTimerValues,x
RemoveTreasureFromDisplay
   ldy TreasureIndexValues,x        ; get Treasure index value
   lda leftGoldBars - 1,y
   and #$7F
   sta leftGoldBars - 1,y
   lda rightGoldBars - 1,y
   and #$7F
   sta rightGoldBars - 1,y
   rts
    
UpperTreasureGoldBarTreshold
   .byte 0, 5, 25, 55, 89

TreasureVerticalPositionValues
   .byte LOWER_TREASURE_VERT_POS
   .byte UPPER_TREASURE_VERT_POS

TreasureMaskValues
   .byte SHOW_LOWER_TREASURE_MASK
   .byte SHOW_UPPER_TREASURE_MASK

TreasureIndexValues
   .byte LOWER_TREASURE_INDEX
   .byte UPPER_TREASURE_INDEX
    
CheckRemovingGoldBar
   lda thiefVertPosition            ; get Thief vertical position
   and #7
   bne .doneCheckRemovingGoldBar    ; branch if not divisible by 8
   lda thiefVertPosition            ; get Thief vertical position
   lsr
   lsr
   lsr                              ; divide Thief vertical position by 8
   tax
   lda thiefHorizPosition           ; get Thief horizontal position
   sec
   sbc #12
   bcc .doneCheckRemovingGoldBar
   cmp #121
   bcs .doneCheckRemovingGoldBar
   cmp #60
   bcc .determineGoldBarMaskingIndex
   adc #3
.determineGoldBarMaskingIndex
   lsr
   lsr
   lsr
   tay
   lda GoldBarMaskingBits,y         ; get Gold Bar masking bit value
   cpy #8
   bcs .checkRemovingRightGoldBar
   and leftGoldBars - 1,x
   beq .doneCheckRemovingGoldBar
   eor leftGoldBars - 1,x
   sta leftGoldBars - 1,x
   jmp .incrementScoreForRemovingGoldBar
    
.checkRemovingRightGoldBar
   and rightGoldBars - 1,x
   beq .doneCheckRemovingGoldBar
   eor rightGoldBars - 1,x
   sta rightGoldBars - 1,x
.incrementScoreForRemovingGoldBar
   lda #SOUND_ID_GOLD_BARS
   jsr SetSoundEngineValues
   ldy #POINTS_20_INDEX
   jsr IncrementPlayerScore
   dec goldBarsRemaining            ; reduce remaining Gold Bars
   ldx currentPlayerNumber
   ldy goldBarsTaken,x              ; get number of Gold Bars taken
   iny                              ; increment number of Gold Bars taken
   sty goldBarsTaken,x
.doneCheckRemovingGoldBar
   rts
    
GoldBarMaskingBits
   .byte $40,$10,$04,$01,$02,$08,$20,$00
   .byte $00,$20,$08,$02,$01,$04,$10,$40
    
HorizontallyPositionObjects
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   sta HMP0,x                 ; 4 = @07
   and #$0F                   ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sec                        ; 2
.coarsePositionObject
   sbc #1                     ; 2
   bpl .coarsePositionObject  ; 2³
   sta RESP0,x                ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   rts                        ; 6
    
DetermineClosedDoor
   lda bonusPointTimer              ; get bonus point timer value
   bne .doneDetermineClosedDoor     ; branch if bonus point timer not expired
   ldx #0
   jsr DetermineMazePositionValue
   sta tmpThiefMazePosition
   lda firstClosedDoorMazePosition  ; get first closed door position value
   beq .checkSecondClosedDoorTimeExpiration;branch if first door not closed
   dec firstClosedDoorTimer         ; reduce first door timer
   bne .checkSecondClosedDoorTimeExpiration;branch if door timer not expired
   lda #0
   sta firstClosedDoorMazePosition  ; remove first closed door
.checkSecondClosedDoorTimeExpiration
   lda secondClosedDoorMazePosition ; get second closed door position value
   beq .determinePlayerClosingDoor  ; branch if second door not closed
   dec secondClosedDoorTimer        ; reduce second door timer
   bne .determinePlayerClosingDoor  ; branch if door timer not expired
   lda #0
   sta secondClosedDoorMazePosition ; remove second closed door
.determinePlayerClosingDoor
   lda INPT4                        ; read left port joystick trigger
   and INPT5                        ; combine with right port joystick trigger
   bmi .checkToSetThiefMazePositionValue;branch if joystick triggers not pressed
   lda tmpThiefMazePosition
   cmp previousThiefMazePosition
   bne .checkToCloseDoor
   lda thiefVertPosition            ; get Thief vertical position
   clc
   adc #4
   and #$0F                         ; 0 <= a <= 15
   cmp #8
   bcc .checkToSetThiefMazePositionValue
.checkToCloseDoor
   lda previousThiefMazePosition    ; get previous Thief maze position
   beq .checkToSetThiefMazePositionValue
   cmp firstClosedDoorMazePosition  ; compare with first closed door position
   beq .checkToSetThiefMazePositionValue
   cmp secondClosedDoorMazePosition ; compare with second closed door position
   beq .checkToSetThiefMazePositionValue
   ldx firstClosedDoorMazePosition  ; get first closed door position value
   bne .checkToCloseSecondDoor      ; branch if first door already closed
   sta firstClosedDoorMazePosition
   ldx #128
   stx firstClosedDoorTimer
   bne .setSoundForClosedDoor       ; unconditional branch

.checkToCloseSecondDoor
   ldx secondClosedDoorMazePosition ; get second closed door position value
   bne .checkToSetThiefMazePositionValue;branch if second door already closed
   sta secondClosedDoorMazePosition
   ldx #128
   stx secondClosedDoorTimer
.setSoundForClosedDoor
   lda #0
   sta previousThiefMazePosition
   lda #SOUND_ID_CLOSE_DOOR
   jsr SetSoundEngineValues
.checkToSetThiefMazePositionValue
   lda thiefVertPosition            ; get Thief vertical position
   and #$0F                         ; 0 <= a <= 15
   bne .doneDetermineClosedDoor
   lda tmpThiefMazePosition         ; get Thief maze position
   tax
   and #<~7                         ; keep maze horizontal coordinate value
   beq .doneDetermineClosedDoor
   stx previousThiefMazePosition
.doneDetermineClosedDoor
   rts
    
DetermineObjectKernelHorizPosition
   sec
   sbc #3                           ; subtract horizontal position by 3
   sta tmpAdjustedHorizPosition
   lsr                              ; divide adjusted position by 16
   lsr
   lsr
   lsr
   sta tmpHorizPosDiv16             ; division by 16 is coarse movement value
   lda tmpAdjustedHorizPosition     ; get adjusted horizontal position
   asl
   asl
   asl
   asl                              ; multiply div16 remainder by 16
   ora tmpHorizPosDiv16             ; combine with coarse position value
   clc
   adc tmpAdjustedHorizPosition     ; increment by adjusted position
   and #$F0                         ; keep upper nybbles
   adc tmpHorizPosDiv16             ; increment by coarse position value
   eor #$70                         ; get 3-bit 1's complement for fine motion
   rts
    
SetPoliceKernelZones
   ldx #KERNEL_SECTIONS - 1
   lda #0
.clearPoliceKernelZoneValues
   sta kernelZonePoliceIndexValues,x
   dex
   bpl .clearPoliceKernelZoneValues
   ldx #NUM_POLICE
.determinePoliceKernelZone
   ldy tmpSortedPoliceIndexArray - 1,x;get sorted Police index
   lda policeVertPositions - 1,y    ; get Police vertical position
   clc
   adc #7
   lsr
   lsr
   lsr
   and #<~1
   tay
   txa
   and #1
   beq .setPoliceKernelZoneValue
   iny
.setPoliceKernelZoneValue
   lda tmpSortedPoliceIndexArray - 1,x
   sta kernelZonePoliceIndexValues,y
   dex
   bne .determinePoliceKernelZone
   rts
    
PerformSortPoliceRoutine
   jsr SortPoliceIndexArray
.donePerformSortPoliceRoutine
   rts
    
SortPoliceIndexArray
   ldx #1
   stx tmpPoliceIndex
   stx tmpSortedPoliceIndexArray
.bubbleSortPoliceIndexArray
   inc tmpPoliceIndex               ; increment Police index
   ldx tmpPoliceIndex
   cpx #NUM_POLICE + 1
   beq .donePerformSortPoliceRoutine
   lda policeVertPositions - 1,x    ; get Police vertical position
   ldx #1
.sortIteration
   ldy tmpSortedPoliceIndexArray - 1,x
   cmp policeVertPositions - 1,y
   bcc .swapPoliceIndexes           ; branch if vertical position lower
   inx
   cpx tmpPoliceIndex
   bne .sortIteration
.swapPoliceIndexes
   lda tmpPoliceIndex               ; get Police index
   sta tmpSortedPoliceIndexArray - 1,x
.nextSortIteration
   cpx tmpPoliceIndex
   bcs .bubbleSortPoliceIndexArray
   inx
   lda tmpSortedPoliceIndexArray - 1,x
   sty tmpSortedPoliceIndexArray - 1,x
   tay
   jmp .nextSortIteration
    
AnimateThiefAndPoliceObjects
   ldx #1
   jsr AnimateGameObjects
   ldx #0
   jsr AnimateGameObjects
   rts
    
AnimateGameObjects
   lda gameState                    ; get current game state
   and #GAME_ACTIVE_MASK            ; keep GAME_ACTIVE value
   beq .animateGameObjectsStationary; branch if not GAME_ACTIVE
   lda frameCount                   ; get current frame count
   lsr
   lsr
   lsr                              ; divide frame count by 8
   and #3                           ; 0 <= a <= 3
   beq .animateGameObjectsStationary; branch to animate stationary game objects
   cmp #1
   beq .animateMarchingGameObjects_00;branch to animate marching game objects
   cmp #2
   beq .animateGameObjectsStationary; branch to animate stationary game objects
   lda #<PoliceGraphics_02 + 1
   sta policeGraphicOffset_00
   lda #<PoliceMissileGraphics_02 + 1
   sta policeGraphicOffset_01
   lda #<ThiefGraphics_02 + 3
   sta thiefGraphicOffset
   rts
    
.animateMarchingGameObjects_00
   lda #<PoliceGraphics_01 + 1
   sta policeGraphicOffset_00
   lda #<PoliceMissileGraphics_01 + 1
   sta policeGraphicOffset_01
   lda #<ThiefGraphics_01 + 3
   sta thiefGraphicOffset
   rts
    
.animateGameObjectsStationary
   lda #<PoliceGraphics_00 + 1
   sta policeGraphicOffset_00
   lda #<PoliceMissileGraphics_00 + 1
   sta policeGraphicOffset_01
   lda #<ThiefGraphics_00 + 3
   sta thiefGraphicOffset
   rts
    
DetermineAllowedDirection
   cpx #0
   bne .determineAllowedDirection   ; branch if not processing Thief
   lda gameState                    ; get current game state
   and #ESCAPE_DOOR_MASK            ; keep ESCAPE_DOOR value
   beq .determineAllowedDirection   ; branch if GS_CLOSE_ESCAPE_DOOR
   lda thiefHorizPosition           ; get Thief horizontal position
   cmp #[XMAX / 2] + 2
   bne .determineAllowedDirection   ; branch if Thief not in center column
   lda thiefVertPosition
   cmp #YMAX
   bne .determineAllowedDirection
   lda #<[MOVE_DOWN & P0_JOYSTICK_MASK];don't allow MOVE_DOWN
   rts
    
.determineAllowedDirection
   jsr DetermineMazePositionValue
   tay                              ; move maze position to y register
   lda #P0_JOYSTICK_MASK            ; allow all directions
   cpy firstClosedDoorMazePosition
   beq .restrictVertMovementWithClosedDoor;branch if at first closed door
   cpy secondClosedDoorMazePosition
   bne .determineMazeDirectionRestrictions
.restrictVertMovementWithClosedDoor
   lda objectVertPositions,x        ; get object vertical position
   and #8
   beq .checkToRectrictDownMovement
   lda #MOVE_UP                     ; don't allow MOVE_UP direction
.checkToRectrictDownMovement
   bne .determineMazeDirectionRestrictions
   lda #MOVE_DOWN                   ; don't allow MOVE_DOWN direction
.determineMazeDirectionRestrictions
   sta tmpIllegalDirections
   lda objectVertPositions,x        ; get object vertical position
   eor #8
   and #$0F
   bne .dontAllowHorizontalDirection; branch if not at horizontal intersection
   lda MazeRules,y
   and tmpIllegalDirections
   dey
   cpy firstClosedDoorMazePosition
   beq .dontAllowDownDirection
   cpy secondClosedDoorMazePosition
   bne .doneDetermineAllowedDirection
.dontAllowDownDirection
   and #MOVE_DOWN                   ; don't allow MOVE_DOWN direction
.doneDetermineAllowedDirection
   rts
    
.dontAllowHorizontalDirection
   lda tmpIllegalDirections
   and #P0_HORIZ_MOVE               ; don't allow MOVE_LEFT or MOVE_RIGHT
   rts
    
MazeRules
   .byte $C0                        ; not used

   .byte ~[MOVE_RIGHT & MOVE_LEFT], ~[MOVE_RIGHT & MOVE_LEFT]
   .byte ~[MOVE_RIGHT & MOVE_LEFT], ~[MOVE_RIGHT & MOVE_LEFT]
   .byte ~[MOVE_RIGHT & MOVE_LEFT], ~[MOVE_RIGHT & MOVE_LEFT]

   .byte $C0,$C0                    ; not used

   .byte ~[MOVE_RIGHT & MOVE_UP], ~[MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN]

   .byte $00,$C0                    ; not used
    
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN], ~[MOVE_RIGHT & MOVE_LEFT]

   .byte $00,$C0                    ; not used

   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_UP], ~[MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN]

   .byte $00,$C0                    ; not used
    
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN]

   .byte $00,$C0                    ; not used
    
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_UP], ~[MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN], ~[MOVE_RIGHT & MOVE_LEFT]
    
   .byte $00,$C0                    ; not used
    
   .byte ~[MOVE_LEFT & MOVE_UP], ~[MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_RIGHT & MOVE_LEFT & MOVE_DOWN & MOVE_UP]
   .byte ~[MOVE_LEFT & MOVE_DOWN & MOVE_UP], ~[MOVE_LEFT & MOVE_DOWN]

   .byte 0                          ; unused

DetermineMazePositionValue
   lda objectHorizPositions,x       ; get object horizontal position
   lsr                              ; divide position by 2
   bcs .objectNotMazeIntersection   ; branch if odd position
   lsr                              ; divide position by 4
   bcs .objectNotMazeIntersection
   cmp #[80 >> 2]                   ; compare with screen mid point
   adc #[1 - 1]                     ; increment by 1 if on right half
   lsr                              ; divide position by 8
   bcs .objectNotMazeIntersection
   tay
.setMazePositionPositionValue
   lda objectVertPositions,x        ; get object vertical position
   clc
   adc #8                           ; increment position by 8 (i.e. H_OBJECT)
   lsr
   lsr
   lsr
   lsr                              ; divide by 16 for kernel section
   ora MazeHorizCoordinateValues,y  ; combine with horizontal coordinate value
   rts
    
.objectNotMazeIntersection
   ldy #0
   beq .setMazePositionPositionValue;unconditional branch
    
MazeHorizCoordinateValues
   .byte 0 << 3, 0 << 3, 1 << 3, 0 << 3, 0 << 3, 2 << 3, 0 << 3, 0 << 3, 3 << 3
   .byte 0 << 3, 0 << 3, 4 << 3, 0 << 3, 0 << 3, 5 << 3, 0 << 3, 0 << 3, 6 << 3
   .byte 0 << 3, 0 << 3             ; not used
   
   IF COMPILE_REGION != PAL50

      .byte $90,$D0,$D0,$D0,$D0,$50,$30,$B0,$70,$B0,$70,$30
      .byte $B0,$F0,$F0,$F0,$F0,$70,$B0,$70,$B0,$70,$B0,$70
      .byte $B0,$E0,$F0,$F0,$E0,$70,$A0,$C0,$E0,$E0,$C0,$60
    
   ENDIF
    
DeterminePoliceDirections SUBROUTINE
   ldx #[KERNEL_SECTIONS / 2] - 1
   lda policeMovementState          ; get Police movement state
   beq .clearZonePoliceCountValues  ; branch if Police moving
   rts
    
.clearZonePoliceCountValues
   sta tmpZonePoliceCount,x
   dex
   bpl .clearZonePoliceCountValues
   sta tmpPoliceTrappedState        ; clear for Police trapped state
   ldx currentPlayerNumber
   lda gameLevelValues,x            ; get current game level
   sta tmpGameLevelValues
   ldx #NUM_POLICE
.determinePoliceDirections
   lda #P0_JOYSTICK_MASK            ; allow all directions
   ldy policeDirectionValues - 1,x  ; get Police direction value
   beq .flipPoliceDirections
   lda #<~[MOVE_UP & MOVE_DOWN]     ; allow vertical directions
   cpy #<~MOVE_LEFT
   bcs .flipPoliceDirections        ; branch if moving horizontally
   lda #<~[MOVE_RIGHT & MOVE_LEFT]  ; allow horizontal directions
.flipPoliceDirections
   eor policeDirectionValues - 1,x
   sta policeDirectionValues - 1,x
   jsr DetermineAllowedDirection
   ldy leftPlayerLevel              ; get left player game level value
   cpy #2
   bcs .donePoliceTunnelRestrictions; branch if passed level 1
   ldy policeHorizPositions - 1,x   ; get Police horizontal position
   cpy #16
   bne .restrictPoliceFromRightTunnel
   and #<MOVE_LEFT                  ; don't allow MOVE_LEFT (i.e. no tunnel entry)
.restrictPoliceFromRightTunnel
   cpy #132
   bne .donePoliceTunnelRestrictions
   and #<MOVE_RIGHT                 ; don't allow MOVE_RIGHT
.donePoliceTunnelRestrictions
   tay                              ; move restricted direction to y register
   and policeDirectionValues - 1,x
   sta tmpPoliceDirectionValues,x
   lda #P1_NO_MOVE & P0_NO_MOVE
   sta policeDirectionValues - 1,x
   tya                              ; move restricted direction to accumulator
   bne .incrementZonePoliceCount
   inc tmpPoliceTrappedState        ; increment to show Police trapped
.incrementZonePoliceCount
   lda policeVertPositions - 1,x    ; get Police vertical position
   sec
   sbc #H_POLICE                    ; subtract H_POLICE
   lsr
   lsr
   lsr
   lsr                              ; divide by 16 for kernel section
   tay
   lda tmpZonePoliceCount,y         ; get kernel section Police count
   clc
   adc #1
   sta tmpZonePoliceCount,y
   lda policeVertPositions - 1,x    ; get Police vertical position
   eor #8
   and #$0F
   beq .determineNextPoliceDirection; branch if at horizontal intersection
   iny                              ; increment kernel section index
   lda tmpZonePoliceCount,y         ; get kernel section Police count
   adc #1
   sta tmpZonePoliceCount,y
.determineNextPoliceDirection
   dex
   bne .determinePoliceDirections
   ldy tmpPoliceTrappedState        ; get Police trapped state value
   beq ChaseThiefInPoliceArea       ; branch if Police not trapped
   lda gameState                    ; get current game state
   and #TRAPPED_POLICE_REWARD_MASK  ; keep TRAPPED_POLICE_REWARD value
   bne ChaseThiefInPoliceArea       ; branch if GS_TRAPPED_POLICE_REWARDED
   ldy #POINTS_2000_INDEX
   jsr IncrementPlayerScore
   jsr ShowBonusPointValue
   lda #SOUND_ID_POLICE_TRAPPED
   jsr SetSoundEngineValues
   lda gameState                    ; get current game state
   ora #GS_TRAPPED_POLICE_REWARDED
   sta gameState                    ; set to show GS_TRAPPED_POLICE_REWARDED
ChaseThiefInPoliceArea
   ldx #NUM_POLICE
.chaseThiefInPoliceArea
   lda policeHorizPositions - 1,x   ; get Police horizontal position
   sec
   sbc thiefHorizPosition           ; subtract Thief horizontal position
   adc #14
   cmp #28
   bcs .checkThiefInPoliceVerticalArea
   jsr DeterminePoliceSafeVerticalDirections
   lda policeVertPositions - 1,x    ; get Police vertical position
   cmp thiefVertPosition            ; compare with Thief vertical position
   beq .checkThiefInPoliceVerticalArea
   lda #<~MOVE_DOWN
   bcs .chaseThiefVertically        ; branch if Police above Thief
   lda #<~MOVE_UP
.chaseThiefVertically
   and tmpPoliceDirectionValues,x
   beq .checkNextPolice
   jsr IncrementAdjacentZonePoliceCount
   jmp .checkNextPolice
    
.checkThiefInPoliceVerticalArea
   lda policeVertPositions - 1,x    ; get Police vertical position
   sec
   sbc thiefVertPosition            ; subtract Thief vertical position
   adc #14
   cmp #28
   bcs .checkNextPolice
   lda policeHorizPositions - 1,x
   cmp thiefHorizPosition
   lda #<~MOVE_RIGHT
   bcc .chaseThiefHorizontally      ; branch if Police left of Thief
   lda #<~MOVE_LEFT
.chaseThiefHorizontally
   and tmpPoliceDirectionValues,x
   beq .checkNextPolice
   jsr IncrementAdjacentZonePoliceCount
.checkNextPolice
   dex
   bne .chaseThiefInPoliceArea
   ldx #NUM_POLICE
.determineRandomDirection
   lda policeDirectionValues - 1,x        ; get Police direction value
   bne .nextRandomPoliceDirection         ; branch if direction established
   jsr DeterminePoliceSafeVerticalDirections
   lda tmpPoliceDirectionValues,x         ; get temporary Police direction value
   beq .nextRandomPoliceDirection
   sta tmpPoliceDirection
   txa                                    ; move Police number to accumulator
   eor random
   and #3                                 ; 0 <= a <= 3
   tay
   lda PoliceRandomDirectionValues,y      ; get random priority direction value
   clc
.rotateDirectionValue
   ror
   bit tmpPoliceDirection
   beq .rotateDirectionValue
   and tmpPoliceDirection                 ; keep priority direction if choosen
   jsr IncrementAdjacentZonePoliceCount
.nextRandomPoliceDirection
   dex
   bne .determineRandomDirection
   rts
    
PoliceRandomDirectionValues
   .byte $88
   .byte $44
   .byte $22
   .byte $11

IncrementAdjacentZonePoliceCount SUBROUTINE
   sta policeDirectionValues - 1,x  ; set Police direction value
   and #<~[MOVE_DOWN & MOVE_UP]     ; isolate vertical movement value
   beq .doneIncrementAdjacentZonePoliceCount;branch if not moving vertical
   lda policeVertPositions - 1,x    ; get Police vertical position
   eor #8
   and #$0F
   bne .doneIncrementAdjacentZonePoliceCount;branch if not at horiz intersection
   lda policeVertPositions - 1,x    ; get Police vertical position
   lsr
   lsr
   lsr
   lsr                              ; divide by 16 for kernel section
   tay
   dey                              ; decrement for kernel section below Police
   lda policeDirectionValues - 1,x  ; get Police direction value
   cmp #<~MOVE_UP
   bne .incrementZonePoliceCount    ; branch if MOVE_UP
   iny
   iny
.incrementZonePoliceCount
   lda tmpZonePoliceCount,y         ; get kernel section Police count
   clc
   adc #1
   sta tmpZonePoliceCount,y
.doneIncrementAdjacentZonePoliceCount
   rts
    
DeterminePoliceSafeVerticalDirections
   lda policeVertPositions - 1,x    ; get Police vertical position
   eor #8
   and #$0F
   bne .doneIncrementAdjacentZonePoliceCount;branch if not at horiz intersection
   lda policeVertPositions - 1,x    ; get Police vertical position
   sec
   sbc #H_POLICE
   lsr
   lsr
   lsr
   lsr                              ; divide by 16 for kernel section
   tay
   dey                              ; decrement for kernel section below Police
   lda tmpZonePoliceCount,y         ; get kernel section Police count
   cmp #ZONE_MAX_POLICE
   bne .checkPoliceCountForAboveKernelSection;branch if not reached maximum
   lda tmpPoliceDirectionValues,x
   and #MOVE_DOWN                   ; don't allow MOVE_DOWN direction
   sta tmpPoliceDirectionValues,x
.checkPoliceCountForAboveKernelSection
   iny
   iny
   lda tmpZonePoliceCount,y         ; get kernel section Police count
   cmp #ZONE_MAX_POLICE
   bne .doneDeterminePoliceSafeVerticalDirections;branch if not reached maximum
   lda tmpPoliceDirectionValues,x
   and #MOVE_UP                     ; don't allow MOVE_UP direction
   sta tmpPoliceDirectionValues,x
.doneDeterminePoliceSafeVerticalDirections
   rts
    
PoliceMovementDelayValues
   .byte 2                          ; move 2 / 3 frames
   .byte 4                          ; move 4 / 5 frames
   .byte 6                          ; move 6 / 7 frames
   .byte 12                         ; move 12 / 13 frames
    
MoveObjects
   ldx currentPlayerNumber
   ldy gameLevelValues,x            ; get current game level
   lda #0
   sta policeMovementState          ; assume Police movement
   ldx #4
   lda bonusPointTimer              ; get bonus point timer value
   beq .checkToMoveObject           ; branch if bonus point timer expired
   ldx #0
   and #$E0                         ; 112 <= a <= 16 || a == 0
   bne .doneMoveObjects
.checkToMoveObject
   cpy #4
   bcs .moveObject                  ; branch to move Police every frame
   dec policeMovementDelay          ; decrement Police movement delay
   bpl .moveObject
   lda PoliceMovementDelayValues,y  ; get movement delay value for level
   sta policeMovementDelay          ; set Police movement delay
   sta policeMovementState          ; set to non-zero for Police not moving
   ldx #0
.moveObject
   lda objectDirectionValues,x      ; get object direction value
   bit ObjectMovementBitValues
   bne .moveObjectUp                ; branch if object moving up
   bit ObjectMovementBitValues + 1
   bne .moveObjectDown              ; branch if object moving down
   bit ObjectMovementBitValues + 2
   bne .moveObjectLeft              ; branch if object moving left
   bit ObjectMovementBitValues + 3
   bne .moveObjectRight             ; branch if object moving right
   jmp .determineObjectKernelPosition
    
.moveObjectRight
   lda objectHorizPositions,x       ; get object horizontal position
   clc
   adc #1
   cmp #XMAX
   bne .doneMoveObjectRight
   lda #XMIN
.doneMoveObjectRight
   sta objectHorizPositions,x       ; set new horizontal position
   lda #3
   jmp .determineObjectKernelPosition
    
.moveObjectLeft
   lda objectHorizPositions,x       ; get object horizontal position
   sec
   sbc #1
   cmp #XMIN - 1
   bne .doneMoveObjectLeft
   lda #XMAX - 1
.doneMoveObjectLeft
   sta objectHorizPositions,x       ; set new horizontal position
   lda #2
   jmp .determineObjectKernelPosition
    
.moveObjectUp
   lda objectVertPositions,x        ; get object vertical position
   clc
   adc #1
   sta objectVertPositions,x
   lda #0
   jmp .determineObjectKernelPosition
    
.moveObjectDown
   lda objectVertPositions,x        ; get object vertical position
   sec
   sbc #1
   sta objectVertPositions,x
   lda #1
.determineObjectKernelPosition
   lda objectHorizPositions,x       ; get object horizontal position
   jsr DetermineObjectKernelHorizPosition
   sta objectKernelHorizPositions,x
   dex
   bpl .moveObject
.doneMoveObjects
   rts
    
ObjectMovementBitValues
   .byte <~MOVE_UP, <~MOVE_DOWN
   .byte <~MOVE_LEFT, <~MOVE_RIGHT
    
DetermineThiefDirections
   ldx #0
   jsr DetermineAllowedDirection
   sta tmpThiefIllegalDirections
   lda SWCHA                        ; read joystick values
   asl                              ; shift right player values to upper nybbles
   asl
   asl
   asl
   and SWCHA                        ; combine with left player values
   eor #$F0                         ; flip bits
   sta tmpJoystickValues            ; set current joystick value
   bit thiefDirectionValue          ; check Thief direction value
   beq .restrictDiagonalDirections  ; branch if moving same direction
   ldy thiefDirectionValue          ; get Thief direction value
   cmp joystickDirectionValues
   beq .doneDetermineThiefDirections; branch if joystick direction held
.restrictDiagonalDirections
   cpy #<~MOVE_LEFT
   and tmpThiefIllegalDirections    ; remove illegal directions
   bcc .checkToRestrictHorizontalMovement;branch if moving vertical
   and #<~[MOVE_DOWN & MOVE_UP]     ; restrict vertical movement
.checkToRestrictHorizontalMovement
   bcs .doneRestrictDiagonals       ; branch if moving horizontal
   and #<~[MOVE_RIGHT & MOVE_LEFT]  ; restrict horizontal movement
.doneRestrictDiagonals
   bne .restrictIllegalDirections
   lda tmpJoystickValues            ; get current joystick value
.restrictIllegalDirections
   and tmpThiefIllegalDirections    ; restrict illegal directions
   beq .doneDetermineThiefDirections
   bit thiefDirectionValue          ; check Thief direction value
   bne .doneDetermineThiefDirections
   sta thiefDirectionValue          ; set Thief direction value
   lda tmpJoystickValues            ; get current joystick value
   sta joystickDirectionValues
   rts
    
.doneDetermineThiefDirections
   lda thiefDirectionValue          ; get Thief direction value
   and tmpThiefIllegalDirections
   sta thiefDirectionValue          ; set Thief direction value
   lda tmpJoystickValues            ; get current joystick value
   and joystickDirectionValues
   sta joystickDirectionValues
   rts

NextRandom
   lda random                       ; get current random value
   asl                              ; shift D7 to carry
   bcs .setNextRandom               ; branch if greater than 127
   eor #$91
.setNextRandom
   sta random
   rts

   FILL_BOUNDARY 256, -1

MazeGraphicData
MazePF0Data
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
MazePF1Data
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
MazePF2Data
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $8E ; |X...XXX.|
   .byte $80 ; |X.......|
   .byte $8E ; |X...XXX.|
   .byte $00 ; |........|
   .byte $8E ; |X...XXX.|
   .byte $0E ; |....XXX.|
   .byte $8E ; |X...XXX.|
   .byte $00 ; |........|
   .byte $8F ; |X...XXXX|
   .byte $00 ; |........|
    
   FILL_BOUNDARY [H_KERNEL + 4], -1

PoliceGraphicData
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
PoliceGraphics_00
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PoliceGraphics_01
   .byte $30 ; |..XX....|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PoliceGraphics_02
   .byte $0C ; |....XX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BlankPoliceGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PoliceMissileGraphics_00
   .byte HMOVE_0  | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_R2 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_L2 | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_R3 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
PoliceMissileGraphics_01
   .byte HMOVE_0  | [MSBL_SIZE2 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_R2 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_L2 | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_R3 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
PoliceMissileGraphics_02
   .byte HMOVE_R2 | [MSBL_SIZE2 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_R2 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE8 >> 2] | ENABLE_BM
   .byte HMOVE_L2 | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_R3 | [MSBL_SIZE4 >> 2] | ENABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM
   .byte HMOVE_0  | [MSBL_SIZE1 >> 2] | DISABLE_BM

   FILL_BOUNDARY 256, -1

ScoreAreaGraphicData
zero
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
one
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
two
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
three
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $3C ; |..XXXX..|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
four
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
five
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
six
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
eight
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
nine
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Plus
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $3E ; |..XXXXX.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
LivesIndicator
   .byte $66 ; |.XX..XX.|
   .byte $24 ; |..X..X..|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY [H_KERNEL + 16], -1

ThiefGraphicData
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
ThiefGraphics_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $66 ; |.XX..XX.|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ThiefGraphics_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $06 ; |.....XX.|
   .byte $64 ; |.XX..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
ThiefGraphics_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $26 ; |..X..XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
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
BlankThiefGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY 506, - 1

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"

   .word Start                      ; NMI vector
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector