   LIST OFF
; ***  D E M O N S   T O   D I A M O N D S  ***
; Copyright 1982 Atari, Inc.
; Designer: Nick Turner
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 15, 2020
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
; NTSC ROM usage stats
; -------------------------------------------
;  ***  97 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
;  *** 100 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, ATARI, INC.                                  =
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
VBLANK_TIME             = 41
OVERSCAN_TIME           = 37

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 52
OVERSCAN_TIME           = 44
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

SKULL_COLOR             = BLACK + 8
DIAMOND_COLOR           = WHITE + 1

   IF COMPILE_REGION = NTSC

RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
GREEN                   = $C0
ORANGE_GREEN            = $E0
DK_GREEN                = $D0

PLAYFIELD_COLOR         = BLUE + 10

TOP_LASER_BASE_COLOR_00 = ORANGE_GREEN + 8
TOP_LASER_BASE_COLOR_01 = ULTRAMARINE_BLUE + 12
TOP_LASER_BASE_TARGET_COLOR = ULTRAMARINE_BLUE + 12
TOP_SCORE_COLOR         = ULTRAMARINE_BLUE + 12

BOTTOM_LASER_BASE_COLOR_00 = RED_ORANGE + 8
BOTTOM_LASER_BASE_COLOR_01 = RED
BOTTOM_LASER_BASE_TARGET_COLOR = RED
BOTTOM_SCORE_COLOR      = RED + 6

OBJECT_COLOR_EOR        = BRICK_RED + 12

COLOR_ZONE_01           = GREEN + 4
COLOR_ZONE_02           = DK_GREEN + 6
COLOR_ZONE_03           = DK_GREEN + 4
COLOR_ZONE_04           = GREEN + 6
COLOR_ZONE_05           = GREEN + 6
COLOR_ZONE_06           = DK_GREEN + 4
COLOR_ZONE_07           = DK_GREEN + 6
COLOR_ZONE_08           = GREEN + 4

   ELSE

YELLOW                  = $20
GREEN                   = $30
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE                  = $70
COLBALT_BLUE            = $80
BLUE                    = $B0
LT_BLUE                 = $C0

PLAYFIELD_COLOR         = PURPLE + 10

TOP_LASER_BASE_COLOR_00 = GREEN + 8
TOP_LASER_BASE_COLOR_01 = LT_BLUE + 12
TOP_LASER_BASE_TARGET_COLOR = LT_BLUE + 12
TOP_SCORE_COLOR         = LT_BLUE + 12

BOTTOM_LASER_BASE_COLOR_00 = YELLOW + 7
BOTTOM_LASER_BASE_COLOR_01 = BRICK_RED
BOTTOM_LASER_BASE_TARGET_COLOR = BRICK_RED
BOTTOM_SCORE_COLOR      = RED + 12

OBJECT_COLOR_EOR        = COLBALT_BLUE + 12

COLOR_ZONE_01           = DK_GREEN + 4
COLOR_ZONE_02           = GREEN + 6
COLOR_ZONE_03           = GREEN + 4
COLOR_ZONE_04           = DK_GREEN + 6
COLOR_ZONE_05           = DK_GREEN + 6
COLOR_ZONE_06           = GREEN + 4
COLOR_ZONE_07           = GREEN + 6
COLOR_ZONE_08           = DK_GREEN + 4

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

XMIN                    = 14
XMAX                    = 160

XMAX_LASER_BASE         = 136
XMAX_DEMON              = 136
XMAX_SPAWNING_DEMON     = 134
XMAX_DIAMOND            = 140
XMAX_SKULL              = 134
XMAX_EXPLOSION          = 134


MAX_LIVES               = 4
INIT_NUM_LIVES          = MAX_LIVES
INIT_GAME_TIMER_VALUE   = 30
INIT_DEMON_HORIZ_POS    = 69

MAX_GAME_SELECTION      = 6

MAX_WAVE                = 15

INIT_RESET_DEBOUNCE_TIME = 16
INIT_SELECT_DEBOUNCE_TIME = 45

H_DIGITS                = 8
H_LASER_BASE            = 9
H_COPYRIGHT             = 7
H_SKULL_MISSILE         = 8
W_OBJECT                = 18

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

H_OBJECT                = 14
H_KERNEL                = 179

MAX_PADDLE_DISCHARGE_VALUE = 185

YMIN_SKULL_MISSILE      = 9
YMAX_SKULL_MISSILE      = 181
YMIN_TOP_LASER          = 15
YMIN_BOTTOM_LASER       = 8
YMAX_BOTTOM_LASER       = 175
PLAYER_LASER_ADJUSTMENT = 9

BOTTOM_LASER_END_POINT_ZONE_00 = 163
BOTTOM_LASER_END_POINT_ZONE_01 = 145
BOTTOM_LASER_END_POINT_ZONE_02 = 127
BOTTOM_LASER_END_POINT_ZONE_03 = 109
BOTTOM_LASER_END_POINT_ZONE_04 = 91
BOTTOM_LASER_END_POINT_ZONE_05 = 73
BOTTOM_LASER_END_POINT_ZONE_06 = 55
BOTTOM_LASER_END_POINT_ZONE_07 = 37

TOP_LASER_END_POINT_ZONE_00 = 153
TOP_LASER_END_POINT_ZONE_01 = 135
TOP_LASER_END_POINT_ZONE_02 = 117
TOP_LASER_END_POINT_ZONE_03 = 99
TOP_LASER_END_POINT_ZONE_04 = 81
TOP_LASER_END_POINT_ZONE_05 = 63
TOP_LASER_END_POINT_ZONE_06 = 45
TOP_LASER_END_POINT_ZONE_07 = 27

   ELSE
   
H_OBJECT                = 16
H_KERNEL                = 206

MAX_PADDLE_DISCHARGE_VALUE = 198

YMIN_SKULL_MISSILE      = 16
YMAX_SKULL_MISSILE      = 203
YMIN_TOP_LASER          = 23
YMIN_BOTTOM_LASER       = 16
YMAX_BOTTOM_LASER       = 193
PLAYER_LASER_ADJUSTMENT = 11

BOTTOM_LASER_END_POINT_ZONE_00 = 193
BOTTOM_LASER_END_POINT_ZONE_01 = 171
BOTTOM_LASER_END_POINT_ZONE_02 = 149
BOTTOM_LASER_END_POINT_ZONE_03 = 127
BOTTOM_LASER_END_POINT_ZONE_04 = 105
BOTTOM_LASER_END_POINT_ZONE_05 = 83
BOTTOM_LASER_END_POINT_ZONE_06 = 61
BOTTOM_LASER_END_POINT_ZONE_07 = 39

TOP_LASER_END_POINT_ZONE_00 = 183
TOP_LASER_END_POINT_ZONE_01 = 161
TOP_LASER_END_POINT_ZONE_02 = 139
TOP_LASER_END_POINT_ZONE_03 = 117
TOP_LASER_END_POINT_ZONE_04 = 95
TOP_LASER_END_POINT_ZONE_05 = 73
TOP_LASER_END_POINT_ZONE_06 = 51
TOP_LASER_END_POINT_ZONE_07 = 29

   ENDIF

KERNEL_ZONES            = 8

INIT_RESERVED_LIVES     = 4

;
; Object attribute status values
;
OBJECT_DIR_MASK         = %10000000
OBJECT_ACTIVE_MASK      = %01000000
OBJ_ID_MASK             = %00001111

OBJ_DIR_LEFT            = 1 << 7
OBJ_DIR_RIGHT           = 0 << 7
OBJ_ACTIVE              = 0 << 6
OBJ_INACTIVE            = 1 << 6

ID_DEMON_00             = 0
ID_DEMON_01             = 1
ID_DEMON_02             = 2
ID_DEMON_03             = 3
ID_SPAWN_DEMON_00       = 4
ID_SPAWN_DEMON_01       = 5
ID_SPAWN_DEMON_02       = 6
ID_SPAWN_DEMON_03       = 7
ID_DIAMOND_00           = 8
ID_DIAMOND_01           = 9
ID_SKULL                = 10
ID_EXPLOSION_00         = 11
ID_EXPLOSION_01         = 12
ID_EXPLOSION_02         = 13
ID_EXPLOSION_03         = 14
ID_NULL                 = 15
;
; Skull missile status values
;
SKULL_MISSILE_LAUNCH_MASK = %10000000
SKULL_MISSILE_DIR_MASK  = %00100000
SKULL_MISSILE_LAUNCHED  = 1 << 7
SKULL_MISSILE_UP        = 0 << 5
SKULL_MISSILE_DOWN      = 1 << 5
;
; Player status values
;
LASER_ACTIVE_MASK       = %10000000
ACTION_BUTTON_DEBOUNCE_MASK = %01000000
PLAYER_SHOT_OBJ_MASK    = %00100000
PLAYER_STUNNED_MASK     = %00010000
RESERVED_LIVES_MASK     = %00001111

LASER_ACTIVE            = 1 << 7
LASER_INACTIVE          = 0 << 7
ACTION_BUTTON_DOWN      = 1 << 6
ACTION_BUTTON_UP        = 0 << 6
PLAYER_SHOT_OBJ         = 1 << 5
PLAYER_NOT_SHOT_OBJ     = 0 << 5
PLAYER_STUNNED          = 1 << 4
PLAYER_NOT_STUNNED      = 0 << 4
;
; Game state status values
;
GAME_PLAY_MASK          = %10000000
SKULL_BULLET_MASK       = %01000000
NUM_PLAYERS_MASK        = %00100000
COPYRIGHT_MASK          = %00010000
COLOR_CYCLE_MASK        = %00001000
SPONTANEOUS_SKULL_MASK  = %00000100
NEW_WAVE_MASK           = %00000010
OPPONENT_SHOOT_MASK     = %00000001

GAME_PLAY_ON            = 1 << 7
GAME_PLAY_OFF           = 0 << 7
SKULL_BULLET_SLOW       = 1 << 6
SKULL_BULLET_FAST       = 0 << 6
ONE_PLAYER              = 1 << 5
TWO_PLAYERS             = 0 << 5
COPYRIGHT_ON            = 1 << 4
COPYRIGHT_OFF           = 0 << 4
COLOR_CYCLE_ON          = 1 << 3
COLOR_CYCLE_OFF         = 0 << 3
SPONTANEOUS_SKULL_ON    = 1 << 2
SPONTANEOUS_SKULL_OFF   = 0 << 2
NEW_WAVE_ON             = 1 << 1
NEW_WAVE_OFF            = 0 << 1
OPPONENT_SHOOT_ON       = 1 << 0
OPPONENT_SHOOT_OFF      = 0 << 0
;
; Number font index values
;
ZERO_IDX_VALUE          = 0
ONE_IDX_VALUE           = 1
TWO_IDX_VALUE           = 2
THREE_IDX_VALUE         = 3
FOUR_IDX_VALUE          = 4
FIVE_IDX_VALUE          = 5
SIX_IDX_VALUE           = 6
SEVEN_IDX_VALUE         = 7
EIGHT_IDX_VALUE         = 8
NINE_IDX_VALUE          = 9
BLANK_IDX_VALUE         = 10
;
; Point values (BCD format)
;
POINTS_PER_LIFE_WAVE_01 = $0010
POINTS_PER_LIFE_WAVE_02 = $0020
POINTS_PER_LIFE_WAVE_03 = $0030
POINTS_PER_LIFE_WAVE_04 = $0050
POINTS_PER_LIFE_WAVE_05 = $0100
POINTS_PER_LIFE_WAVE_06 = $0150
POINTS_PER_LIFE_WAVE_07 = $0200
POINTS_PER_LIFE_WAVE_08 = $0250
POINTS_PER_LIFE_WAVE_09 = $0300
POINTS_PER_LIFE_WAVE_10 = $0350
POINTS_PER_LIFE_WAVE_11 = $0400
POINTS_PER_LIFE_WAVE_12 = $0500
POINTS_PER_LIFE_WAVE_13 = $0750
POINTS_PER_LIFE_WAVE_14 = $1000
POINTS_PER_LIFE_WAVE_15 = $1500
POINTS_PER_LIFE_WAVE_16 = $2000

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

objectHorizontalPositions ds KERNEL_ZONES * 2
;--------------------------------------
obj0HorizontalPositions = objectHorizontalPositions
obj1HorizontalPositions = obj0HorizontalPositions + KERNEL_ZONES
objectAttributeValues   ds KERNEL_ZONES * 2
;--------------------------------------
obj0AttributeValues     = objectAttributeValues
obj1AttributeValues     = obj0AttributeValues + KERNEL_ZONES
objectSpeedValues       ds KERNEL_ZONES * 2
;--------------------------------------
obj0SpeedValues         = objectSpeedValues
obj1SpeedValues         = obj0SpeedValues + KERNEL_ZONES
objectColorValues       ds 16
;--------------------------------------
obj0ColorValues         = objectColorValues
obj1ColorValues         = obj0ColorValues + KERNEL_ZONES
laserBaseColorValues    ds 4
;--------------------------------------
topLaserBaseColor_00    = laserBaseColorValues
topLaserBaseColor_01    = topLaserBaseColor_00 + 1
bottomLaserBaseColor_00 = laserBaseColorValues + 2
bottomLaserBaseColor_01 = bottomLaserBaseColor_00 + 1
scoreColorValues        ds 2
;--------------------------------------
topScoreColorValue      = scoreColorValues
bottomScoreColorValue   = topScoreColorValue + 1
laserBaseHorizontalPositions ds 2
;--------------------------------------
topLaserBaseHorizPosition = laserBaseHorizontalPositions
bottomLaserBaseHorizPosition = topLaserBaseHorizPosition + 1
objectGraphicPointers   ds 4
;--------------------------------------
obj0GraphicPtrs         = objectGraphicPointers
obj1GraphicPtrs         = objectGraphicPointers + 2
scanlineCount           ds 1
paddleDischargeValues   ds 2
;--------------------------------------
leftPaddleDischargeValue = paddleDischargeValues
rightPaddleDischargeValue = leftPaddleDischargeValue + 1
ballGraphicValue        ds 1
playerStatusValues      ds 2
;--------------------------------------
topPlayerStatusValue    = playerStatusValues
bottomPlayerStatusValue = topPlayerStatusValue + 1
reserveLivesGraphicValues ds 2
;--------------------------------------
topPlayerReserveLivesGraphic = reserveLivesGraphicValues
bottomPlayerReserveLivesGraphic = topPlayerReserveLivesGraphic + 1
topPlayerLaserEndPoint  ds 1
bottomPlayerLaserEndPoint ds 1
skullMissileLowerBound  ds 1
skullMissileUpperBound  ds 1
drawMissileLowerBound   ds 1
drawMissileUpperBound   ds 1
missileObjectHorizPosition ds 1
gameState               ds 1
currentWaveNumber       ds 1
numberOfSpawnedDemons   ds 1
skullMissileStatus      ds 1
currentGameSelection    ds 1
selectDebounceTimer     ds 1
playerScores            ds 4
;--------------------------------------
player2Score            = playerScores
;--------------------------------------
player2HundredValue     = player2Score
player2OnesValue        = player2HundredValue + 1
player1Score            = player2Score + 2
;--------------------------------------
player1HundredsValue    = player1Score
player1OnesValue        = player1HundredsValue + 1
laserBaseHitSoundIdx    ds 1
livesRemainingSoundIdx  ds 1
newWaveColorCycleValue  ds 1
random                  ds 1
randomIndexValue        ds 1
frameCount              ds 2
colorEOR                ds 1
hueMask                 ds 1
wait03Cycles            ds 1
;--------------------------------------
tmpColorClockPositionValue = wait03Cycles
;--------------------------------------
tmpCopyrightGraphicValue = tmpColorClockPositionValue
;--------------------------------------
tmpLaserBaseCenter      = tmpCopyrightGraphicValue
;--------------------------------------
tmpSpawnedDiamondZone   = tmpLaserBaseCenter
;--------------------------------------
tmpShotDiamondZone      = tmpSpawnedDiamondZone
;--------------------------------------
tmpSkullMissileSpeed    = tmpShotDiamondZone
;--------------------------------------
tmpSkullMissileZone     = tmpSkullMissileSpeed
;--------------------------------------
tmpObjectSpeedAdjustment = tmpSkullMissileZone
;--------------------------------------
tmpTopScoreZeroSuppressValue = tmpObjectSpeedAdjustment
;--------------------------------------
tmpRewardedPlayerIndex  = tmpTopScoreZeroSuppressValue
tmpObj0ColorClockValue  ds 1
;--------------------------------------
tmpCopyrightIndex       = tmpObj0ColorClockValue
;--------------------------------------
tmpGameState            = tmpCopyrightIndex
;--------------------------------------
tmpBottomScoreZeroSuppressValue = tmpGameState
digitPointers           ds 16
;--------------------------------------

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60
   
player2DigitPointers    = digitPointers
;--------------------------------------
player2ThousandsDigitPtr = player2DigitPointers
player2HundredsDigitPtr = player2ThousandsDigitPtr + 2
player2TensDigitPtr     = player2HundredsDigitPtr + 2
player2OnesDigitPtr     = player2TensDigitPtr + 2
player1DigitPointers    = player2DigitPointers + 8
;--------------------------------------
player1ThousandsDigitPtr = player1DigitPointers
player1HundredsDigitPtr = player1ThousandsDigitPtr + 2
player1TensDigitPtr     = player1HundredsDigitPtr + 2
player1OnesDigitPtr     = player1TensDigitPtr + 2

   ELSE
   
player1DigitPointers    = digitPointers
;--------------------------------------
player1ThousandsDigitPtr = player1DigitPointers
player1HundredsDigitPtr = player1ThousandsDigitPtr + 2
player1TensDigitPtr     = player1HundredsDigitPtr + 2
player1OnesDigitPtr     = player1TensDigitPtr + 2
player2DigitPointers    = player1DigitPointers + 8
;--------------------------------------
player2ThousandsDigitPtr = player2DigitPointers
player2HundredsDigitPtr = player2ThousandsDigitPtr + 2
player2TensDigitPtr     = player2HundredsDigitPtr + 2
player2OnesDigitPtr     = player2TensDigitPtr + 2

   ENDIF

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
   txa
   sta SWACNT                       ; set all Port A bits to input
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = -1
   stx gameState
   txs                              ; set stack to the beginning
   jsr IncrementGameSelection
   jmp Overscan
    
DrawTopScoreKernel
   sta WSYNC
;--------------------------------------
   lda #BLUE + 2              ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2         hue mask for background color
   sta COLUBK                 ; 3 = @10   set background color
   ldx #5                     ; 2
.coarsePositionScoreObjects
   dex                        ; 2
   bpl .coarsePositionScoreObjects;2³
   sta RESP0                  ; 3 = @44
   sta RESP1                  ; 3 = @47
   lda #HMOVE_L7              ; 2
   sta HMP0                   ; 3 = @52   set GRP0 to color clock 57
   lda #HMOVE_0               ; 2
   sta HMP1                   ; 3 = @57   set GRP1 to color clock 73
   lda topScoreColorValue     ; 3         get top score color value
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @69   set color for top score digits
   sta COLUP1                 ; 3 = @72
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   
   IF COMPILE_REGION = PAL50
   
   sta WSYNC
;--------------------------------------

   ENDIF
   
   ldy #H_DIGITS - 1          ; 2
.drawPlayer2ScoreKernel
   lda (player2ThousandsDigitPtr),y;5     get thousands digit
   asl                        ; 2         shift graphics to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   ora (player2HundredsDigitPtr),y;5      combine with hundreds digit
   sta GRP0                   ; 3 = @21   draw hundreds value
   lda (player2TensDigitPtr),y; 5         get tens digit
   asl                        ; 2         shift graphics to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   ora (player2OnesDigitPtr),y; 5         combine with ones digit
   sta GRP1                   ; 3 = @42   draw ones values
   lda topPlayerReserveLivesGraphic;3        
   sta PF1                    ; 3 = @48   draw remaining lives indicator
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda #0                     ; 2
   sta PF1                    ; 3 = @65
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bpl .drawPlayer2ScoreKernel; 2³
   lda #0                     ; 2         not needed...accumulator already 0
   sta GRP0                   ; 3 = @09
   sta GRP1                   ; 3 = @12
   sta WSYNC
;--------------------------------------

   IF COMPILE_REGION = PAL50
   
   sta WSYNC
;--------------------------------------

   ENDIF
   
   inc scanlineCount          ; 5         increment scan line count
   lda gameState              ; 3         get current game state
   and #NUM_PLAYERS_MASK      ; 2         keep NUM_PLAYERS value
   beq DrawTopLaserBaseKernel ; 2³        branch if TWO_PLAYERS game
   ldx #1                     ; 2
.skip_02ScanLines
   sta WSYNC
;--------------------------------------
   inc scanlineCount          ; 5         increment scan line count
   dex                        ; 2
   bpl .skip_02ScanLines      ; 2³
   sta WSYNC
;--------------------------------------
   sta wait03Cycles           ; 3         not needed...waste 3 cycles
   lda #BLACK + 4             ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2         hue mask for background color
   sta COLUBK                 ; 3 = @13
   lda #$70                   ; 2
   sta PF0                    ; 3 = @18   set to draw border around playfield
   ldx #3                     ; 2
.skip_04ScanLines
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .skip_04ScanLines      ; 2³
   lda colorEOR               ; 3         get color value
   and #$F7                   ; 2         hue mask for background color
   sta COLUBK                 ; 3 = @12
   ldx #6                     ; 2
.skip_07ScanLines
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .skip_07ScanLines      ; 2³
   jmp DrawKernelZone         ; 3
    
DrawTopLaserBaseKernel
   ldx topLaserBaseHorizPosition;3 = @16  get top Laser Base horizontal position
   lda ColorClockPositionValues,x;4       get color clock position value
   sta WSYNC
;--------------------------------------
   sta tmpColorClockPositionValue;3       set top Laser Base color clock value
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpColorClockPositionValue;3       get top Laser Base color clock value
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionTopLaserBase_00
   dey                        ; 2
   bpl .coarsePositionTopLaserBase_00;2³
   sta RESP0                  ; 3
   sta HMP0                   ; 3
   sta WSYNC
;--------------------------------------
   lda tmpColorClockPositionValue;3       get top Laser Base color clock value
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpColorClockPositionValue;3       get top Laser Base color clock value
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionTopLaserBase_01
   dey                        ; 2
   bpl .coarsePositionTopLaserBase_01;2³
   sta RESP1                  ; 3
   sta HMP1                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #BLACK + 4             ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @13
   lda #$70                   ; 2
   sta PF0                    ; 3 = @18   set to draw border around playfield
   ldx #4                     ; 2
   ldy #H_LASER_BASE          ; 2
   lda topLaserBaseColor_00   ; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @34
   lda topLaserBaseColor_01   ; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP1                 ; 3 = @46
.drawFirstHalfTopLaserBase
   dey                        ; 2
   inc scanlineCount          ; 5         increment scan line count
   lda TopLaserBase_00,y      ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda TopLaserBase_01,y      ; 4
   sta GRP1                   ; 3 = @10
   dex                        ; 2
   bne .drawFirstHalfTopLaserBase;2³ + 1  crosses page boundary
   lda colorEOR               ; 3
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @22
   ldx #5                     ; 2
.drawSecondHalfTopLaserBase
   dey                        ; 2
   inc scanlineCount          ; 5         increment scan line count
   lda TopLaserBase_00,y      ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda TopLaserBase_01,y      ; 4
   sta GRP1                   ; 3 = @10
   dex                        ; 2
   bne .drawSecondHalfTopLaserBase;2³
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   stx GRP1                   ; 3 = @06
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
DrawKernelZone
   ldx #KERNEL_ZONES - 1      ; 2
   lda KernelZoneBackgroundColors + KERNEL_ZONES;4        
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @14
.drawKernelZone
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue_00;2³        branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue_00
   lda INPT1                  ; 3         read right paddle controller
   bmi .positionKernelZoneObjects;2³      branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
.positionKernelZoneObjects
   inc scanlineCount          ; 5         increment scan line count
   ldy obj1HorizontalPositions,x;4        get object 1 horizontal position
   lda ColorClockPositionValues,y;4       get color clock position value
   sta tmpColorClockPositionValue;3
   ldy obj0HorizontalPositions,x;4        get object 0 horizontal position       
   lda ColorClockPositionValues,y;4       get color clock position value
   sta WSYNC
;--------------------------------------
   sta tmpObj0ColorClockValue ; 3
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpObj0ColorClockValue ; 3         get object 0 color clock value
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionObject_0
   dey                        ; 2
   bpl .coarsePositionObject_0; 2³
   sta RESP0                  ; 3
   sta HMP0                   ; 3         set object 0 fine motion adjustment
   sta WSYNC
;--------------------------------------
   lda tmpColorClockPositionValue;3       get object 1 color clock value
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpColorClockPositionValue;3       get object 1 color clock value
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionObject_1
   dey                        ; 2
   bpl .coarsePositionObject_1; 2³
   sta RESP1                  ; 3
   sta HMP1                   ; 3         set object 1 fine motion adjustment
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda obj0ColorValues,x      ; 4         get object 0 color value
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @16   set object 0 color value
   lda obj1ColorValues,x      ; 4         get object 1 color value
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP1                 ; 3 = @29   set object 1 color value
   ldy #H_OBJECT - 1          ; 2
   lda obj0AttributeValues,x  ; 4         get object 0 attribute values
   asl                        ; 2         shift OBJ_ID value to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta obj0GraphicPtrs        ; 3         set object 0 graphic LSB value
   lda obj1AttributeValues,x  ; 4         get object 1 attribute values
   asl                        ; 2         shift OBJ_ID value to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta obj1GraphicPtrs        ; 3         set object 1 graphic LSB value
   inc scanlineCount          ; 5         increment scan line count
.drawKernelZoneObjects
   sta WSYNC
;--------------------------------------
   lda (obj0GraphicPtrs),y    ; 5         get object 0 graphic value
   sta GRP0                   ; 3 = @08   set object 0 graphic data
   lda (obj1GraphicPtrs),y    ; 5         get object 1 graphic value
   sta GRP1                   ; 3 = @16   set object 1 graphic data
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue_01;2³        branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue_01
   lda INPT1                  ; 3         read right paddle controller
   bmi .drawLaser             ; 2³        branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
.drawLaser
   lda scanlineCount          ; 3         get current scan line count
   cmp drawMissileLowerBound  ; 3
   bcc .nextKernelZoneScanline; 2³
   cmp drawMissileUpperBound  ; 3
   bcs .disableBall           ; 2³
   lda ballGraphicValue       ; 3
   sta ENABL                  ; 3 = @57
   bpl .nextKernelZoneScanline; 3         unconditional branch
   
.disableBall
   lda #DISABLE_BM            ; 2
   sta ENABL                  ; 3
.nextKernelZoneScanline
   inc scanlineCount          ; 5         increment scan line count
   dey                        ; 2
   bpl .drawKernelZoneObjects ; 2³
   lda KernelZoneBackgroundColors,x;4     get kernel zone background color
   sta WSYNC
;--------------------------------------
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @08   set background color for kernel zone
   lda #0                     ; 2
   sta GRP0                   ; 3 = @13   clear graphic data
   sta GRP1                   ; 3 = @16
   
   IF COMPILE_REGION = PAL50
   
   jsr ReadPaddleControllers  ; 6
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
   jsr ReadPaddleControllers  ; 6
   inc scanlineCount          ; 5         increment scan line count
   sta WSYNC
;--------------------------------------
       
   ENDIF
   
   dex                        ; 2
   bmi .doneDrawKernelZone    ; 2³
   jmp .drawKernelZone        ; 3
    
.doneDrawKernelZone

   IF COMPILE_REGION != PAL50
   
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue_02;2³        branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue_02
   lda INPT1                  ; 3         read right paddle controller
   bmi DrawBottomLaserBaseKernel;2³ + 1   branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
   
   ENDIF
   
DrawBottomLaserBaseKernel SUBROUTINE
   inc scanlineCount          ; 5         increment scan line count
   ldx bottomLaserBaseHorizPosition;3        
   lda ColorClockPositionValues,x;4       get color clock position value
   sta WSYNC
;--------------------------------------
   sta tmpColorClockPositionValue;3
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpColorClockPositionValue;3
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionBottomLaserBase_00
   dey                        ; 2
   bpl .coarsePositionBottomLaserBase_00;2³
   sta RESP0                  ; 3
   sta HMP0                   ; 3
   sta WSYNC
;--------------------------------------
   lda tmpColorClockPositionValue;3
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda tmpColorClockPositionValue;3
   inc scanlineCount          ; 5         increment scan line count
.coarsePositionBottomLaserBase_01
   dey                        ; 2
   bpl .coarsePositionBottomLaserBase_01;2³
   sta RESP1                  ; 3
   sta HMP1                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx #7                     ; 2
   ldy #H_LASER_BASE          ; 2
   lda bottomLaserBaseColor_00; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @19
   lda bottomLaserBaseColor_01; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP1                 ; 3 = @31
   lda #DISABLE_BM            ; 2
   sta ENABL                  ; 3 = @36
.drawFirstHalfBottomLaserBase
   dey                        ; 2
   
   IF COMPILE_REGION != PAL50
   
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue  ;2³         branch if capacitor not charged    
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue
   lda INPT1                  ; 3         read right paddle controller
   bmi .nextDrawBottomLaserBaseLine;2³    branch if capacitor not charged    
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
   
   ENDIF
   
.nextDrawBottomLaserBaseLine
   inc scanlineCount          ; 5         increment scan line count
   lda BottomLaserBase_00,y   ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda BottomLaserBase_01,y   ; 4
   sta GRP1                   ; 3 = @10
   dex                        ; 2
   bne .drawFirstHalfBottomLaserBase;2³
   lda #BLACK + 4             ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @24
   ldx #2                     ; 2
.drawSecondHalfBottomLaserBase
   dey                        ; 2
   
   IF COMPILE_REGION != PAL50
   
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue_01;2³        branch if capacitor not charged     
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue_01
   lda INPT1                  ; 3         read right paddle controller
   bmi .nextDrawSecondHalfLaserBase;2³    branch if capacitor not charged    
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
   
   ENDIF
   
.nextDrawSecondHalfLaserBase
   inc scanlineCount          ; 5         increment scan line count
   lda BottomLaserBase_00,y   ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda BottomLaserBase_01,y   ; 4
   sta GRP1                   ; 3 = @10
   dex                        ; 2
   bne .drawSecondHalfBottomLaserBase;2³
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   stx GRP1                   ; 3 = @06
   lda gameState              ; 3         get current game state
   and #COPYRIGHT_MASK        ; 2         keep COPYRIGHT_MASK value
   beq DrawBottomScoreKernel  ; 2³ + 1    branch if COPYRIGHT_OFF
   
   IF COMPILE_REGION = PAL50
   
   bne DrawCopyrightKernel    ; 3         unconditional branch
   
ReadPaddleControllers SUBROUTINE
   lda INPT0                  ; 3         read left paddle controller
   bmi .readRightPaddleValue  ; 2³        branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta leftPaddleDischargeValue;3
.readRightPaddleValue
   lda INPT1                  ; 3         read right paddle controller
   bmi .doneReadPaddleControllers;2³      branch if capacitor not charged
   lda scanlineCount          ; 3         get current scan line count
   sta rightPaddleDischargeValue;3
.doneReadPaddleControllers
   rts                        ; 6
   
   ENDIF
   
DrawCopyrightKernel
   sta WSYNC
;--------------------------------------
   stx PF0                    ; 3 = @03
   lda #BLUE + 2              ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUBK                 ; 3 = @14
   lda bottomScoreColorValue  ; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @26
   sta COLUP1                 ; 3 = @29
   SLEEP 2                    ; 2
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @36
   ldx #HMOVE_0               ; 2
   stx HMP1                   ; 3 = @41
   sta RESP0                  ; 3 = @44   set GRP0 to color clock 65
   sta RESP1                  ; 3 = @47   set GRP1 to color clock 73
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$C0 | 8 | THREE_COPIES; 2
   sta NUSIZ0                 ; 3 = @08
   ldx #TWO_COPIES            ; 2
   stx NUSIZ1                 ; 3 = @13
   ldx #H_COPYRIGHT           ; 2
.drawCopyrightKernel
   stx tmpCopyrightIndex      ; 3
   sta WSYNC
;--------------------------------------
   ldy #2                     ; 2
.wait09Cycles
   dey                        ; 2
   bne .wait09Cycles          ; 2³
   sta wait03Cycles           ; 3         waste 3 cycles
   lda Copyright_0 - 1,x      ; 4
   sta GRP0                   ; 3 = @21
   lda Copyright_1 - 1,x      ; 4
   sta GRP1                   ; 3 = @28
   ldy Copyright_2 - 1,x      ; 4
   lda Copyright_3 - 1,x      ; 4
   sta tmpCopyrightGraphicValue;3
   lda Copyright_4 - 1,x      ; 4
   ldx tmpCopyrightGraphicValue;3
   sty GRP0                   ; 3 = @49
   stx GRP1                   ; 3 = @52
   sta GRP0                   ; 3 = @55
   ldx tmpCopyrightIndex      ; 3
   dex                        ; 2
   bne .drawCopyrightKernel   ; 2³
   stx GRP0                   ; 3 = @65   clear GRP0 graphics (i.e. x = 0)
   stx GRP1                   ; 3 = @68   clear GRP1 graphics (i.e. x = 0)
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   jmp Overscan
    
DrawBottomScoreKernel SUBROUTINE
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05
   lda #BLUE + 2              ; 2        
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and #$F7                   ; 2
   sta COLUBK                 ; 3 = @15
   ldx #4                     ; 2
.coarsePositionScoreObjects
   dex                        ; 2
   bpl .coarsePositionScoreObjects;2³
   sta RESP0                  ; 3 = @44
   sta RESP1                  ; 3 = @47
   lda #HMOVE_L7              ; 2
   sta HMP0                   ; 3 = @52   set GRP0 to color clock 57
   lda #HMOVE_0               ; 2
   sta HMP1                   ; 3 = @57   set GRP1 to color clock 73
   lda bottomScoreColorValue  ; 3
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUP0                 ; 3 = @69
   sta COLUP1                 ; 3 = @72
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #H_DIGITS - 1          ; 2
.drawBottomScoreKernel
   lda (player1ThousandsDigitPtr),y;5     get thousands digit
   asl                        ; 2         shift graphics to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   ora (player1HundredsDigitPtr),y;5      combine with hundreds digit
   sta GRP0                   ; 3 = @21   draw hundreds value
   lda (player1TensDigitPtr),y; 5         get tens digit
   asl                        ; 2         shift graphics to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   ora (player1OnesDigitPtr),y; 5         combine with ones digit
   sta GRP1                   ; 3 = @42   draw ones values
   lda bottomPlayerReserveLivesGraphic;3        
   sta PF1                    ; 3 = @48   draw remaining lives indicator
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda #0                     ; 2
   sta PF1                    ; 3 = @65
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bpl .drawBottomScoreKernel ; 2³
   lda #0                     ; 2         not needed...accumulator already 0
   sta GRP0                   ; 3 = @09
   sta GRP1                   ; 3 = @12
   sta WSYNC
;--------------------------------------
Overscan

   IF COMPILE_REGION = PAL50
   
   sta WSYNC
   
   ENDIF
   
   ldx #BLACK
   stx COLUBK
   lda #DOUBLE_SIZE
   sta NUSIZ0
   sta NUSIZ1
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan
   lda #DUMP_PORTS | DISABLE_TIA
   sta VBLANK
   stx AUDV0                        ; turn off volume (i.e. x = 0)
   inc frameCount                   ; increment frame count
   bne .checkResetAndSelectSwitches
   inc frameCount + 1
   lda #48
   cmp frameCount + 1
   bne .checkResetAndSelectSwitches
   lda gameState                    ; get current game state
   ora #COLOR_CYCLE_ON              ; set COLOR_CYCLE_ON
   sta gameState
.checkResetAndSelectSwitches
   jsr CheckResetAndSelectSwitches
   bcs CheckToEnableMissile         ; branch if neither switch pressed
   jmp NewFrame
    
CheckToEnableMissile
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs .checkToEnableSkullMissile   ; branch on odd frame
   lsr
   bcs .bottomLaserBaseLaserTopPriority
   lda topPlayerStatusValue         ; get top player status value
   bmi .enableTopLaserBaseLaser     ; branch if LASER_ACTIVE
   lda bottomPlayerStatusValue      ; get bottom player status value
   bmi .enableBottomLaserBaseLaser  ; branch if LASER_ACTIVE
   bpl .checkToEnableSkullMissile   ; unconditional branch
    
.enableTopLaserBaseLaser
   lda topLaserBaseHorizPosition    ; get top Laser Base horizontal position
   sta missileObjectHorizPosition   ; set missile object horizontal position
   lda #8
   sta drawMissileLowerBound        ; set to lower bound for kernel display
   lda topPlayerLaserEndPoint       ; get top player laser end point
   sta drawMissileUpperBound        ; set to upper bound for kernel display
   bne .enableFrameLaser            ; unconditional branch
    
.bottomLaserBaseLaserTopPriority
   lda bottomPlayerStatusValue      ; get bottom player status value
   bmi .enableBottomLaserBaseLaser  ; branch if LASER_ACTIVE
   lda topPlayerStatusValue         ; get top player status value
   bmi .enableTopLaserBaseLaser     ; branch if LASER_ACTIVE
   bpl .checkToEnableSkullMissile   ; unconditional branch
    
.enableBottomLaserBaseLaser
   lda bottomLaserBaseHorizPosition ; get bottom Laser Base horizontal position
   sta missileObjectHorizPosition   ; set missile object horizontal position
   lda #H_KERNEL - 3
   sta drawMissileUpperBound        ; set to upper bound for kernel display
   lda bottomPlayerLaserEndPoint    ; get bottom player laser end point
   sta drawMissileLowerBound        ; set to lower bound for kernel display
.enableFrameLaser
   lda #ENABLE_BM
   sta ballGraphicValue             ; set ball graphic to display in kernel
   bne CheckForLaserCollisions      ; unconditional branch
    
.disableFrameLaser
   lda #DISABLE_BM
   sta ballGraphicValue             ; set ball graphic not to display in kernel
   beq CheckForLaserCollisions      ; unconditional branch
    
.checkToEnableSkullMissile
   lda skullMissileStatus           ; get Skull missile status value
   bpl .disableFrameLaser           ; branch if Skull missile not launched
   lda skullMissileStatus           ; get Skull missile status value
   and #$0F                         ; keep kernel zone of Skull
   tax
   lda objectHorizontalPositions,x  ; get Skull horizontal position
   sta missileObjectHorizPosition   ; set missile object horizontal position
   lda skullMissileLowerBound       ; get Skull missile lower bound value
   sta drawMissileLowerBound        ; set to lower bound for kernel display
   lda skullMissileUpperBound       ; get Skull missile upper bound value
   sta drawMissileUpperBound        ; set to upper bound for kernel display
   bne .enableFrameLaser            ; unconditional branch
   
CheckForLaserCollisions
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcc CheckForTopLaserCollisions   ; branch on even frame
   jmp CheckForBottomLaserCollisions
    
CheckForTopLaserCollisions
   lda topPlayerStatusValue         ; get top player status value
   bpl .checkForSkullMissileCollisions;branch if LASER_INACTIVE
   lda topLaserBaseHorizPosition    ; get top Laser Base horizontal position
   clc
   adc #(W_OBJECT / 2)              ; increment by 9 for center position
   sta tmpLaserBaseCenter
   ldx #KERNEL_ZONES - 1
.checkTopLaserObj0Collision
   lda tmpLaserBaseCenter
   sec
   sbc obj0HorizontalPositions,x    ; subtract object horizontal position
   cmp #W_OBJECT
   bcs .checkNextTopLaserObj0Collision;branch if outside collision bounding box
   lda topPlayerLaserEndPoint       ; get top player laser end point value
   cmp TopLaserBaseLaserEndPointValues,x;compare with kernel zone end point value
   bcc .checkNextTopLaserObj0Collision;branch if not reached zernel zone
   lda obj0AttributeValues,x        ; get object attribute values
   and #OBJECT_ACTIVE_MASK          ; keep OBJECT_ACTIVE value
   bne .checkNextTopLaserObj0Collision;branch if OBJECT_INACTIVE
   jmp DetermineObjectHitByTopLaser
    
.checkNextTopLaserObj0Collision
   dex
   bpl .checkTopLaserObj0Collision
   ldx #(KERNEL_ZONES * 2) - 1
.checkTopLaserObj1Collision
   lda tmpLaserBaseCenter
   sec
   sbc obj1HorizontalPositions - KERNEL_ZONES,x;subtract object horizontal position
   cmp #W_OBJECT
   bcs .checkNextTopLaserObj1Collision;branch if outside collision bounding box
   lda topPlayerLaserEndPoint       ; get op player laser end point value
   cmp TopLaserBaseLaserEndPointValues - KERNEL_ZONES,x;compare with kernel zone end point value
   bcc .checkNextTopLaserObj1Collision;branch if not reached zernel zone
   lda obj1AttributeValues - KERNEL_ZONES,x;get object attribute values
   and #OBJECT_ACTIVE_MASK          ; keep OBJECT_ACTIVE value
   beq DetermineObjectHitByTopLaser ; branch if OBJECT_ACTIVE
.checkNextTopLaserObj1Collision
   dex
   cpx #KERNEL_ZONES - 1
   bne .checkTopLaserObj1Collision
.checkForSkullMissileCollisions
   jmp CheckForSkullMissileCollisions
    
CheckForBottomLaserCollisions SUBROUTINE
   lda bottomPlayerStatusValue      ; get bottom player status value
   bpl .checkForSkullMissileCollisions;branch if LASER_INACTIVE
   lda bottomLaserBaseHorizPosition ; get bottom Laser Base horizontal position
   clc
   adc #(W_OBJECT / 2)              ; increment by 9 for center position
   sta tmpLaserBaseCenter
   ldx #0
.checkBottomLaserObj0Collision
   lda tmpLaserBaseCenter
   sec
   sbc obj0HorizontalPositions,x    ; subtract object horizontal position
   cmp #W_OBJECT
   bcs .checkNextBottomLaserObj0Collision;branch if outside collision bounding box
   lda BottomLaserBaseLaserEndPointValues,x;get kernel zone end point value
   cmp bottomPlayerLaserEndPoint    ; compare with Laser Base laser end point
   bcc .checkNextBottomLaserObj0Collision;branch if not reached zernel zone
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK          ; keep OBJECT_ACTIVE value
   bne .checkNextBottomLaserObj0Collision;branch if OBJECT_INACTIVE
   jmp DetermineObjectHitByBottomLaser
    
.checkNextBottomLaserObj0Collision
   inx
   cpx #KERNEL_ZONES
   bne .checkBottomLaserObj0Collision
   ldx #KERNEL_ZONES
.checkBottomLaserObj1Collision
   lda tmpLaserBaseCenter
   sec
   sbc obj1HorizontalPositions - KERNEL_ZONES,x;subtract object horizontal position
   cmp #W_OBJECT
   bcs .checkNextBottomLaserObj1Collision;branch if outside collision bounding box
   lda BottomLaserBaseLaserEndPointValues - KERNEL_ZONES,x;get kernel zone end point value
   cmp bottomPlayerLaserEndPoint    ; compare with Laser Base laser end point
   bcc .checkNextBottomLaserObj1Collision;branch if not reached zernel zone
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK          ; keep OBJECT_ACTIVE value
   beq .determineObjectHitByBottomLaser;branch if OBJECT_ACTIVE
.checkNextBottomLaserObj1Collision
   inx
   cpx #KERNEL_ZONES * 2
   bne .checkBottomLaserObj1Collision
.checkForSkullMissileCollisions
   jmp CheckForSkullMissileCollisions
    
.determineObjectHitByBottomLaser
   jmp DetermineObjectHitByBottomLaser
    
DetermineObjectHitByTopLaser
   lda topPlayerStatusValue         ; get top player status value
   bmi .determineObjectHitByTopLaser; branch if LASER_ACTIVE
   jmp CheckForSkullMissileCollisions
    
.determineObjectHitByTopLaser
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20 | ID_DIAMOND_00
   bne .checkTopLaserBaseShootingDiamond;branch if object is not a Demon
   lda objectColorValues,x          ; get object color value
   cmp #TOP_LASER_BASE_TARGET_COLOR
   bne .topLaserBaseShotWrongTarget ; branch if not top Laser Base target color
   lda #DIAMOND_COLOR
   sta objectColorValues,x          ; set object color value
   lda frameCount                   ; get current frame count
   lsr                              ; divide by 4
   lsr
   and #1
   tay
   lda DiamondSpawnHorizontalValues,y;get horizontal position for new diamond
   sta objectHorizontalPositions,x
   lda DiamondSpawnAttributeValues,y; get new attributes for diamond
   sta objectAttributeValues,x
   lda #0
   sta objectSpeedValues,x
   stx tmpSpawnedDiamondZone
   sec 
   lda #15
   sbc tmpSpawnedDiamondZone        ; subtract zone for destroyed Demon
   and #7
   tay
   lda DemonPointValues,y           ; get point value for destroyed Demon
   bne .incrementTopPlayerScore     ; unconditional branch
    
.topLaserBaseShotWrongTarget
   lda frameCount                   ; get current frame count
   asl                              ; shift D6 to D7
   and #OBJECT_DIR_MASK             ; keep value for Skull direction
   ora #ID_SKULL
   sta objectAttributeValues,x      ; spawn Skull
   lda #SKULL_COLOR
   sta objectColorValues,x          ; set object color value
   ldy currentWaveNumber            ; get current wave number
   iny
   lda WaveObjectSpeedValues,y
   lsr                              ; divide by 2
   and frameCount
   sta objectSpeedValues,x          ; set Skull speed value
   beq .showTopPlayerShotObject     ; branch if Skull speed set to 0
.checkTopLaserBaseShootingDiamond
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20 | ID_EXPLOSION_03
   cmp #ID_DIAMOND_00
   bne .showTopPlayerShotObject     ; branch if not shooting Diamond
   lda #OBJ_INACTIVE | $20 | ID_EXPLOSION_00
   sta objectAttributeValues,x      ; spawn Explosion
   stx tmpShotDiamondZone
   lda #15
   sbc tmpShotDiamondZone           ; subtract zone for destroyed Diamond
   and #7
   tay
   lda DemonPointValues,y
   asl                              ; multiply by 16 for Diamond point value
   asl
   asl
   asl
.incrementTopPlayerScore
   ldy #<[player2Score - playerScores]
   ldx #0
   jsr IncrementScore
.showTopPlayerShotObject
   lda topPlayerStatusValue         ; get top player status value
   ora #PLAYER_SHOT_OBJ             ; combine with PLAYER_SHOT_OBJ
   sta topPlayerStatusValue         ; set to show top player shot an object
   bne CheckForSkullMissileCollisions;unconditional branch
    
DetermineObjectHitByBottomLaser SUBROUTINE
   lda bottomPlayerStatusValue      ; get bottom player status value
   bmi .determineObjectHitByBottomLaser;branch if LASER_ACTIVE
   jmp CheckForSkullMissileCollisions
    
.determineObjectHitByBottomLaser
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20 | ID_DIAMOND_00
   bne .checkBottomLaserBaseShootingDiamond
   lda objectColorValues,x          ; get object color value
   cmp #BOTTOM_LASER_BASE_TARGET_COLOR
   bne .bottomLaserBaseShotWrongTarget;branch if not bottom Laser Base target color
   lda #DIAMOND_COLOR
   sta objectColorValues,x          ; set object color value
   lda frameCount                   ; get current frame count
   lsr                              ; divide by 4
   lsr
   and #1
   tay
   lda DiamondSpawnHorizontalValues,y;get horizontal position for new diamond
   sta objectHorizontalPositions,x
   lda DiamondSpawnAttributeValues,y; get new attributes for diamond
   sta objectAttributeValues,x
   lda #0
   sta objectSpeedValues,x
   txa
   and #7
   tay
   lda DemonPointValues,y           ; get point value for destroyed Demon
   bne .incrementPlayer1Score       ; unconditional branch
    
.bottomLaserBaseShotWrongTarget
   lda frameCount                   ; get current frame count
   asl                              ; shift D6 to D7
   and #OBJECT_DIR_MASK             ; keep value for Skull direction
   ora #ID_SKULL
   sta objectAttributeValues,x      ; spawn Skull
   lda #SKULL_COLOR
   sta objectColorValues,x          ; set object color value
   ldy currentWaveNumber            ; get current wave number
   iny
   lda WaveObjectSpeedValues,y
   lsr                              ; divide by 2
   and frameCount
   sta objectSpeedValues,x          ; set Skull speed value
   beq .showBottomPlayerShotObject  ; branch if Skull set to not move
.checkBottomLaserBaseShootingDiamond
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20 | ID_EXPLOSION_03
   cmp #ID_DIAMOND_00
   bne .showBottomPlayerShotObject
   lda #OBJ_INACTIVE | $20 | ID_EXPLOSION_00
   sta objectAttributeValues,x      ; spawn Explosion
   txa
   and #7
   tay
   lda DemonPointValues,y
   asl                              ; multiply by 16 for Diamond point value
   asl
   asl
   asl
.incrementPlayer1Score
   ldy #<[player1Score - playerScores]
   ldx #0
   jsr IncrementScore
.showBottomPlayerShotObject
   lda bottomPlayerStatusValue      ; get bottom player status value
   ora #PLAYER_SHOT_OBJ             ; combine with PLAYER_SHOT_OBJ
   sta bottomPlayerStatusValue      ; set to show bottom player shot an object
CheckForSkullMissileCollisions
   lda skullMissileStatus           ; get Skull missile status value
   bpl .doneCheckForSkullMissileCollisions;branch if Skull missile not launched
   lda skullMissileStatus           ; get Skull missile status value
   and #$0F                         ; keep kernel zone of Skull
   tax
   lda skullMissileLowerBound
   cmp #YMIN_SKULL_MISSILE   
   bcs .checkSkullMissileHittingBottomBase
   lda #0
   sta skullMissileStatus           ; clear Skull missile status
   lda gameState                    ; get current game state
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   bne .doneCheckForSkullMissileCollisions;branch if ONE_PLAYER game
   lda objectHorizontalPositions,x  ; get Skull horizontal position
   clc
   adc #8                           ; increment by 8 to get Skull center
   sec
   sbc topLaserBaseHorizPosition    ; subtract top Laser Base position
   bmi .doneCheckForSkullMissileCollisions
   and #$F0
   bne .doneCheckForSkullMissileCollisions
   tax
   beq .skullMissileHitLaserBase    ; unconditional branch
    
.checkSkullMissileHittingBottomBase
   lda skullMissileUpperBound
   cmp #H_KERNEL - 3
   bcc .doneCheckForSkullMissileCollisions
   lda #0
   sta skullMissileStatus           ; clear Skull missile status
   lda objectHorizontalPositions,x  ; get Skull horizontal position
   clc
   adc #8                           ; increment by 8 to get Skull center
   sec
   sbc bottomLaserBaseHorizPosition ; subtract bottom Laser Base position
   bmi .doneCheckForSkullMissileCollisions
   and #$F0
   bne .doneCheckForSkullMissileCollisions
   ldx #<[bottomPlayerStatusValue - playerStatusValues]
.skullMissileHitLaserBase
   jsr PlayerLaserBaseHit
.doneCheckForSkullMissileCollisions
   lda laserBaseHitSoundIdx         ; get Laser Base hit sound index
   ora livesRemainingSoundIdx       ; combine with lives remaining sound index
   bne .clearPlayerLaserActivityValues;branch if playing sounds
   lda gameState                    ; get current game state
   bmi CheckToFireTopLaserBaseLaser ; branch if GAME_PLAY_ON
.clearPlayerLaserActivityValues
   lda topPlayerStatusValue
   and #PLAYER_STUNNED_MASK | RESERVED_LIVES_MASK
   sta topPlayerStatusValue
   lda bottomPlayerStatusValue
   and #PLAYER_STUNNED_MASK | RESERVED_LIVES_MASK
   sta bottomPlayerStatusValue
   jmp DetermineLaserBaseHorizPosition
    
CheckToFireTopLaserBaseLaser
   lda SWCHA                        ; read paddle action buttons
   bmi .clearTopPlayerStunnedValue  ; branch if left paddle button not pressed
   lda gameState                    ; get current game state
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   bne .clearTopPlayerStunnedValue  ; branch if ONE_PLAYER game
   lda #0
   sta frameCount + 1
   lda gameState                    ; get current game state
   and #<~COLOR_CYCLE_ON            ; set to COLOR_CYCLE_OFF 
   sta gameState
   lda topPlayerStatusValue         ; get top player status value
   and #PLAYER_SHOT_OBJ_MASK        ; keep PLAYER_SHOT_OBJ value
   bne .clearTopPlayerStunnedValue  ; branch if PLAYER_SHOT_OBJ
   lda topPlayerStatusValue         ; get top player status value
   bmi .fireTopLaserBaseLaser       ; branch if LASER_ACTIVE
   and #ACTION_BUTTON_DEBOUNCE_MASK ; keep ACTION_BUTTON_DEBOUNCE value
   bne CheckToFireBottomLaserBaseLaser;branch if ACTION_BUTTON_DOWN
   lda topPlayerStatusValue         ; get top player status value
   ora #LASER_ACTIVE | ACTION_BUTTON_DOWN
   sta topPlayerStatusValue
.fireTopLaserBaseLaser
   lda topPlayerLaserEndPoint       ; get top player laser end point value
   clc
   adc #PLAYER_LASER_ADJUSTMENT     ; increment by laser adjustment value
   sta topPlayerLaserEndPoint       ; set new laser end point value
   lsr                              ; divide value by 2
   sta AUDF0                        ; set frequency for shooting laser
   lda #8
   sta AUDV0
   lda topPlayerLaserEndPoint       ; get top player laser end point value
   cmp #H_KERNEL - 3
   bcc CheckToFireBottomLaserBaseLaser
   lda gameState                    ; get current game state
   lsr                              ; shift OPPONENT_SHOOT_MASK to carry
   bcc .clearTopPlayerStunnedValue  ; branch if OPPONENT_SHOOT_OFF
   lda topLaserBaseHorizPosition    ; get top Laser Base horizontal position
   adc #(W_OBJECT / 2) - 1          ; increment to find center (i.e. carry set)
   sbc bottomLaserBaseHorizPosition ; subtract bottom Laser Base position
   cmp #W_OBJECT
   bcs .clearTopPlayerStunnedValue
   ldx #<[bottomPlayerStatusValue - playerStatusValues]
   jsr PlayerLaserBaseHit
.clearTopPlayerStunnedValue
   lda topPlayerStatusValue
   and #<~(LASER_ACTIVE | PLAYER_SHOT_OBJ)
   sta topPlayerStatusValue
   lda #YMIN_TOP_LASER
   sta topPlayerLaserEndPoint
CheckToFireBottomLaserBaseLaser
   lda SWCHA                        ; read paddle action buttons
   asl                              ; shift right value to D7
   bmi .clearBottomPlayerStunnedValue;branch if right button not pressed
   lda #0
   sta frameCount + 1
   lda gameState                    ; get current game state
   and #<~COLOR_CYCLE_ON            ; set to COLOR_CYCLE_OFF
   sta gameState
   lda bottomPlayerStatusValue      ; get bottom player status value
   and #PLAYER_SHOT_OBJ_MASK        ; keep PLAYER_SHOT_OBJ value
   bne .clearBottomPlayerStunnedValue;branch if PLAYER_SHOT_OBJ
   lda bottomPlayerStatusValue      ; get bottom player status value
   bmi .fireBottomLaserBaseLaser    ; branch if LASER_ACTIVE
   and #ACTION_BUTTON_DEBOUNCE_MASK ; keep ACTION_BUTTON_DEBOUNCE value
   bne .checkTopPlayerActionButtonDebounce;branch if ACTION_BUTTON_DOWN
   lda bottomPlayerStatusValue
   ora #LASER_ACTIVE | ACTION_BUTTON_DOWN
   sta bottomPlayerStatusValue
.fireBottomLaserBaseLaser
   lda bottomPlayerLaserEndPoint    ; get bottom player laser end point value
   sec
   sbc #PLAYER_LASER_ADJUSTMENT     ; subtract by laser adjustment value
   sta bottomPlayerLaserEndPoint    ; set new laser end point value
   lsr                              ; divide value by 2
   sta AUDF0                        ; set frequency for shooting laser
   lda #8
   sta AUDV0
   lda bottomPlayerLaserEndPoint    ; get bottom player laser end point value
   cmp #YMIN_BOTTOM_LASER   
   bcs .checkTopPlayerActionButtonDebounce
   lda gameState                    ; get current game state
   lsr                              ; shift OPPONENT_SHOOT_MASK to carry
   bcc .clearBottomPlayerStunnedValue;branch if OPPONENT_SHOOT_OFF
   lda bottomLaserBaseHorizPosition ; get bottom Laser Base horizontal position
   adc #(W_OBJECT / 2) - 1          ; increment to find center (i.e. carry set)
   sbc topLaserBaseHorizPosition    ; subtract top Laser Base horizontal position
   cmp #W_OBJECT
   bcs .clearBottomPlayerStunnedValue
   ldx #<[topPlayerStatusValue - playerStatusValues]
   jsr PlayerLaserBaseHit
.clearBottomPlayerStunnedValue
   lda bottomPlayerStatusValue
   and #<~(LASER_ACTIVE | PLAYER_SHOT_OBJ)
   sta bottomPlayerStatusValue
   lda #YMAX_BOTTOM_LASER  
   sta bottomPlayerLaserEndPoint
.checkTopPlayerActionButtonDebounce
   lda topPlayerStatusValue         ; get top player status value
   and #ACTION_BUTTON_DEBOUNCE_MASK ; keep ACTION_BUTTON_DEBOUNCE value
   beq .checkBottomPlayerActionButtonDebounce;branch if ACTION_BUTTON_UP
   lda SWCHA                        ; read paddle action buttons
   bpl .checkBottomPlayerActionButtonDebounce;branch if left action button pressed
   lda topPlayerStatusValue
   and #<~ACTION_BUTTON_DEBOUNCE_MASK;clear ACTION_BUTTON_DEBOUNCE value
   sta topPlayerStatusValue
.checkBottomPlayerActionButtonDebounce
   lda bottomPlayerStatusValue      ; get bottom player status value
   and #ACTION_BUTTON_DEBOUNCE_MASK
   beq CheckToLaunchSkullMissile    ; branch if ACTION_BUTTON_UP
   lda SWCHA                        ; read paddle action buttons
   asl                              ; shift right value to D7
   bpl CheckToLaunchSkullMissile    ; branch if right action button pressed
   lda bottomPlayerStatusValue
   and #<~ACTION_BUTTON_DEBOUNCE_MASK;clear ACTION_BUTTON_DEBOUNCE value
   sta bottomPlayerStatusValue
CheckToLaunchSkullMissile
   lda skullMissileStatus           ; get Skull missile status value
   bpl DetermineLaserBaseHorizPosition;branch if Skull missile not launched
   lda #8
   sta tmpSkullMissileSpeed         ; set initial Skull missile speed
   lda gameState                    ; get current game state
   asl                              ; shift SKULL_BULLET_MASK to D7
   bpl .determineSkullMissileDirection;branch if SKULL_BULLET_FAST
   lsr tmpSkullMissileSpeed         ; divide by to 2 to slow missile speed
.determineSkullMissileDirection
   lda skullMissileStatus           ; get Skull missile status value
   and #SKULL_MISSILE_DIR_MASK      ; keep SKULL_MISSILE_DIR value
   beq .skullFiringAtBottomLaserBase
   lda SWCHB                        ; read console switches
   asl                              ; shift player 1 difficulty to D7
   bmi .moveSkullMissileUp          ; branch if player 1 set to PRO
   dec tmpSkullMissileSpeed         ; reduce missile speed for AMATEUR
   dec tmpSkullMissileSpeed
.moveSkullMissileUp
   lda skullMissileLowerBound
   cmp #YMIN_SKULL_MISSILE   
   bcc .playSkullMissileSound       ; branch if reached upper bound
   sbc tmpSkullMissileSpeed         ; subtract position to move up
   sta skullMissileLowerBound
   adc #H_SKULL_MISSILE             ; increment by H_SKULL_MISSILE
   sta skullMissileUpperBound       ; set Skull missile upper bound for drawing
   bne .playSkullMissileSound       ; unconditional branch
   
.skullFiringAtBottomLaserBase
   lda SWCHB                        ; read console switches
   bmi .moveSkullMissileDown        ; branch if player 2 set to PRO
   dec tmpSkullMissileSpeed         ; reduce missile speed for AMATEUR
   dec tmpSkullMissileSpeed
.moveSkullMissileDown
   lda skullMissileUpperBound       ; get Skull missile upper bound value
   cmp #YMAX_SKULL_MISSILE
   bcs .playSkullMissileSound       ; branch if reached lower bound
   adc tmpSkullMissileSpeed         ; increment position to move down
   sta skullMissileUpperBound
   sbc #H_SKULL_MISSILE             ; subtract by H_SKULL_MISSILE
   sta skullMissileLowerBound       ; set Skull missile lower bound for drawing
.playSkullMissileSound
   lsr
   sta AUDF0
   lda #8
   sta AUDV0
DetermineLaserBaseHorizPosition
   ldx #1
.determineLaserBaseHorizPosition
   lda playerStatusValues,x         ; get player status values
   and #PLAYER_STUNNED_MASK         ; keep PLAYER_STUNNED value
   bne .nextLaserBaseHorizPosition  ; branch if player not allowed to move
   sec
   lda #MAX_PADDLE_DISCHARGE_VALUE   
   sbc paddleDischargeValues,x      ; subtract scan line discharge occurred
   cmp #XMIN
   bcs .determineLaserBaseMaxLimit  ; branch if within left limit range
   lda #XMIN                        ; set left limit range
.determineLaserBaseMaxLimit
   cmp #XMAX_LASER_BASE
   bcc .determineLaserBasePositionChange;branch if within right limit range
   lda #XMAX_LASER_BASE - 1         ; set right limit range
.determineLaserBasePositionChange
   sec
   sbc laserBaseHorizontalPositions,x;subtract Laser Base horizontal position
   php                              ; push status to stack
   lsr                              ; divide value by 2
   plp                              ; pull status from stack
   bpl .changeLaserBaseHorizontalPosition;branch if positive (i.e. move right)
   ora #$80                         ; set to subtract (i.e. move Laser Base left)
.changeLaserBaseHorizontalPosition
   clc
   adc laserBaseHorizontalPositions,x
   sta laserBaseHorizontalPositions,x
.nextLaserBaseHorizPosition
   dex
   bpl .determineLaserBaseHorizPosition
   lda laserBaseHitSoundIdx         ; get Laser Base hit sound index
   ora livesRemainingSoundIdx       ; combine with lives remaining sound index
   bne NewFrame                     ; branch if playing sounds
   lda gameState                    ; get current game state
   and #<~NEW_WAVE_MASK             ; clear NEW_WAVE value
   sta tmpGameState
   ora #NEW_WAVE_ON
   sta gameState                    ; set to NEW_WAVE_ON
   ldx #(KERNEL_ZONES * 2) - 1
.moveObjectsHorizontally
   lda #0
   sta tmpObjectSpeedAdjustment     ; clear object speed adjustment value
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20
   bne .moveNextObject              ; branch if object not active
   lda tmpGameState
   sta gameState                    ; remove NEW_WAVE_ON value
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   tay
   lda ObjectSpeedMaskingValues,y   ; get object speed masking values
   and objectSpeedValues,x          ; and with object speed value
   beq .determineObjectHorizAdjustment
   inc tmpObjectSpeedAdjustment     ; increment object speed adjustment
.determineObjectHorizAdjustment
   lda objectSpeedValues,x          ; get object speed values
   lsr                              ; shift integer adjustment to lower nybbles
   lsr
   lsr
   lsr
   clc
   adc tmpObjectSpeedAdjustment     ; increment by speed adjustment
   beq .moveNextObject
   ldy objectAttributeValues,x      ; get object attribute values
   bpl .changeObjectHorizontalPosition;branch if traveling right
   eor #$FF                         ; negate value to subtract (i.e. move left)
   adc #1
.changeObjectHorizontalPosition
   adc objectHorizontalPositions,x
   sta objectHorizontalPositions,x
.moveNextObject
   dex
   bpl .moveObjectsHorizontally
NewFrame
.waitTime
   ldx INTIM
   bne .waitTime
   ldx #START_VERT_SYNC
   stx VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta WSYNC
   lda #STOP_VERT_SYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
   lda laserBaseHitSoundIdx         ; get Laser Base hit sound index
   ora livesRemainingSoundIdx       ; combine with lives remaining sound index
   bne .jmpCheckToSpawnObject       ; branch if playing sounds
   ldx #(KERNEL_ZONES * 2) - 1
.checkObjectForReachingPlayfieldEdge
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJECT_ACTIVE_MASK | $20
   bne .checkNextObjectReachingEdge
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJ_ID_MASK                 ; keep object id value
   tay
   lda objectHorizontalPositions,x  ; get object horizontal position
   cmp ObjectHorizontalMaximumValues,y;compare with maximum horizontal value
   beq .checkObjectReachingHorizontalMinimum
   bcs .setObjectHorizontalMaximum  ; set object to horizontal maximum
.checkObjectReachingHorizontalMinimum
   cmp #XMIN
   bcc .setObjectHorizontalMinimum
.checkNextObjectReachingEdge
   dex
   bpl .checkObjectForReachingPlayfieldEdge
.jmpCheckToSpawnObject
   jmp .checkToSpawnObject
    
.setObjectHorizontalMinimum
   lda #XMIN
   sta objectHorizontalPositions,x  ; set object horizontal position
   bne .objectReachedPlayfieldEdge  ; unconditional branch
    
.setObjectHorizontalMaximum
   lda ObjectHorizontalMaximumValues,y;get object horizontal maximum value
   sta objectHorizontalPositions,x  ; set object horizontal position
.objectReachedPlayfieldEdge
   lda gameState                    ; get current game state
   bpl .changeObjectDirection       ; branch if GAME_PLAY_OFF
   and #COLOR_CYCLE_MASK            ; keep COLOR_CYCLE_MASK value
   bne .changeObjectDirection       ; branch if COLOR_CYCLE_ON
   lda #34
   sta AUDF0                        ; set audio cue for reaching playfield edge
   lda #12
   sta AUDV0
   lda objectAttributeValues,x      ; get object attribute values
   and #<~(OBJECT_DIR_MASK | ID_DEMON_03)
   bne .checkDiamondReachingEdge    ; branch if not a Demon object
   lda objectColorValues,x          ; get object color value
   eor #OBJECT_COLOR_EOR            ; flip Demon color for new target color
   sta objectColorValues,x          ; set object color value
   lda DemonTransitionZoneValues,x
   tay
   lda objectAttributeValues,y      ; get object attribute values
   cmp #OBJ_INACTIVE | $20 | ID_NULL
   beq .transitionDemonToNewZone
   lda DemonTransitionZoneValues + KERNEL_ZONES,x
   tay
   lda objectAttributeValues,y      ; get object attribute values
   cmp #OBJ_INACTIVE | $20 | ID_NULL
   bne .changeObjectDirection
.transitionDemonToNewZone
   lda objectAttributeValues,x      ; get object attribute values
   eor #OBJECT_DIR_MASK             ; flip OBJECT_DIR bit
   sta objectAttributeValues,y      ; change direction for next zone
   lda objectHorizontalPositions,x  ; get object horizontal position
   sta objectHorizontalPositions,y  ; set position for next zone
   lda objectColorValues,x          ; get object color value
   sta objectColorValues,y          ; set object color for next zone
   lda objectSpeedValues,x          ; get object speed value
   sta objectSpeedValues,y          ; set object speed for next zone
   lda #OBJ_INACTIVE | $20 | ID_EXPLOSION_00
   sta objectAttributeValues,x      ; set current object to explode
   bpl .checkToSpawnObject          ; unconditional branch
   
.checkDiamondReachingEdge
   lda objectAttributeValues,x      ; get object attribute values
   and #OBJ_INACTIVE | $20 | ID_EXPLOSION_03
   cmp #ID_DIAMOND_00
   bne .changeObjectDirection       ; branch if not a moving Diamond
   lda #OBJ_INACTIVE | $20 | ID_EXPLOSION_00
   sta objectAttributeValues,x      ; set Diamon to explode
   bne .checkToSpawnObject          ; unconditional branch
   
.changeObjectDirection
   lda objectAttributeValues,x      ; get object attribute values
   eor #OBJECT_DIR_MASK             ; flip OBJECT_DIR bit
   sta objectAttributeValues,x
.checkToSpawnObject
   lda laserBaseHitSoundIdx         ; get Laser Base hit sound index
   ora livesRemainingSoundIdx       ; combine with lives remaining sound index
   beq DetermineObjectToSpawn       ; branch if not playing sounds
   jmp CheckForMoreDemonsToSpawn
    
DetermineObjectToSpawn
   lda gameState                    ; get current game state
   and #SPONTANEOUS_SKULL_MASK      ; keep SPONTANEOUS_SKULL value
   beq CheckToSpawnSkullMissile     ; branch if SPONTANEOUS_SKULL_OFF
   jsr NextRandom                   ; get next random number
   cmp #32
   bcs CheckToSpawnSkullMissile
   jsr NextRandom                   ; get next random number
   and #$0F
   tay                              ; set y register for random kernel zone
   lda objectAttributeValues,y      ; get object attribute value
   cmp #OBJ_INACTIVE | $20 | ID_NULL
   bne CheckToSpawnSkullMissile     ; branch if object present
   ldx currentWaveNumber            ; get current wave number
   lda WaveObjectSpawningFrequencyValues,x
   and ObjectSpawningMaskingValues,y
   beq CheckToSpawnSkullMissile
   jsr NextRandom                   ; get next random number
   and #OBJECT_DIR_MASK             ; keep value for object direction
   ora #ID_SPAWN_DEMON_00
   sta objectAttributeValues,y      ; spawn new Demon
   jsr NextRandom
   ldx currentWaveNumber            ; get current wave number
   and WaveObjectSpeedValues,x
   adc #3                           ; increment for initial Demon speed
   sta objectSpeedValues,y
   jsr NextRandom                   ; get next random number
   bmi .setObjectColorForTopLaserBaseTarget;branch to set object color
   lda #BOTTOM_LASER_BASE_TARGET_COLOR
   bpl .setObjectColorValue         ; unconditional branch
    
.setObjectColorForTopLaserBaseTarget
   lda #TOP_LASER_BASE_TARGET_COLOR
.setObjectColorValue
   sta objectColorValues,y
   lda #INIT_DEMON_HORIZ_POS
   sta objectHorizontalPositions,y
   inc numberOfSpawnedDemons        ; increment number of spawned Demons
   jmp CheckForMoreDemonsToSpawn
    
CheckToSpawnSkullMissile
   lda gameState                    ; get current game state
   bpl CheckToSetMovingDiamondSpeed ; branch if GAME_PLAY_OFF
   and #COLOR_CYCLE_MASK            ; keep COLOR_CYCLE_MASK value
   bne CheckToSetMovingDiamondSpeed ; branch if COLOR_CYCLE_ON
   lda skullMissileStatus           ; get Skull missile status value
   bmi CheckToSetMovingDiamondSpeed ; branch if Skull missile launched
   jsr NextRandom                   ; get next random number
   and #$0F
   tay                              ; set y register for random kernel zone
   lda objectAttributeValues,y      ; get object attribute value
   and #OBJ_ID_MASK
   cmp #ID_SKULL
   bne CheckToSetMovingDiamondSpeed ; branch if Skull not in zone
   sty tmpSkullMissileZone
   tya
   and #7
   tay
   lda TopLaserBaseLaserEndPointValues,y
   adc #7
   sta skullMissileLowerBound
   sta skullMissileUpperBound
   jsr NextRandom                   ; get next random number
   and #SKULL_MISSILE_DIR_MASK      ; keep for SKULL_MISSILE_DIR
   ora tmpSkullMissileZone
   ora #SKULL_MISSILE_LAUNCHED
   sta skullMissileStatus
   jmp CheckForMoreDemonsToSpawn
    
CheckToSetMovingDiamondSpeed
   lda frameCount                   ; get current frame count
   and #3
   bne .checkToRemoveSkull
   jsr NextRandom                   ; get next random number
   and #$0F
   tay                              ; set y register for random kernel zone
   lda objectAttributeValues,y      ; get object attribute value
   and #<~(OBJECT_DIR_MASK | ID_DEMON_01)
   cmp #ID_DIAMOND_00
   bne .checkToRemoveSkull          ; branch if not Diamond
   lda frameCount                   ; get current frame count
   and #$0F
   adc #24
   sta objectSpeedValues,y          ; set Diamond speed
   bne CheckToSpawnRandomSkull      ; unconditional branch
   
.checkToRemoveSkull
   lda objectAttributeValues,y      ; get object attribute value
   and #OBJ_ID_MASK
   cmp #ID_SKULL
   bne CheckToSpawnRandomSkull      ; branch if object not ID_SKULL
   lda gameState                    ; get current game state
   and #SPONTANEOUS_SKULL_MASK      ; keep SPONTANEOUS_SKULL value
   beq .removeSkull                 ; branch if SPONTANEOUS_SKULL_OFF
   lda frameCount                   ; get current frame count
   and #$1F
   bne CheckToSpawnRandomSkull
.removeSkull
   lda #OBJ_INACTIVE | $20 | ID_EXPLOSION_00
   sta objectAttributeValues,y
   jmp CheckForMoreDemonsToSpawn
    
CheckToSpawnRandomSkull
   lda gameState                    ; get current game state
   and #SPONTANEOUS_SKULL_MASK      ; keep SPONTANEOUS_SKULL value
   beq .checkToSpawnSkullForWave    ; branch if SPONTANEOUS_SKULL_OFF
   jsr NextRandom
   cmp #32
   bcs .checkToSpawnSkullForWave
   jsr NextRandom                   ; get next random number
   and #$0F
   tay                              ; set y register for random kernel zone
   lda objectAttributeValues,y      ; get object attribute value
   cmp #OBJ_INACTIVE | $20 | ID_NULL
   bne .checkToSpawnSkullForWave    ; branch if object preset
   lda currentWaveNumber            ; get current wave number
   sbc #4
   bcc .checkToSpawnSkullForWave
   tax
   lda WaveObjectSpawningFrequencyValues,x
   and ObjectSpawningMaskingValues,y
   beq .checkToSpawnSkullForWave
.spawnRandomSkull
   lda frameCount                   ; get current frame count
   asl                              ; shift D6 to D7
   and #8
   ora #ID_SKULL
   sta objectAttributeValues,y      ; spawn Skull in zone
   lda #SKULL_COLOR
   sta objectColorValues,y          ; set object color value
   inx
   lda WaveObjectSpeedValues,x
   lsr
   and frameCount
   sta objectSpeedValues,y          ; set Skull speed
   jmp CheckForMoreDemonsToSpawn
    
.checkToSpawnSkullForWave
   lda gameState                    ; get current game state
   and #NUM_PLAYERS_MASK | SPONTANEOUS_SKULL_MASK
   eor #NUM_PLAYERS_MASK | SPONTANEOUS_SKULL_MASK
   bne CheckForMoreDemonsToSpawn
   jsr NextRandom                   ; get next random number
   cmp #5
   bcs CheckForMoreDemonsToSpawn
   jsr NextRandom                   ; get next random number
   and #$0F
   tay
   lda objectAttributeValues,y      ; get object attribute values
   cmp #OBJ_INACTIVE | $20 | ID_NULL
   bne CheckForMoreDemonsToSpawn    ; branch if object present
   ldx currentWaveNumber            ; get current wave number
   lda WaveObjectSpawningFrequencyValues,x
   and SkullSpawningMaskingValues,y
   bne .spawnRandomSkull
CheckForMoreDemonsToSpawn
   lda gameState                    ; get current game state
   and #SPONTANEOUS_SKULL_MASK      ; keep SPONTANEOUS_SKULL value
   beq CheckToIncrementWave         ; branch if SPONTANEOUS_SKULL_OFF
   ldx currentWaveNumber            ; get current wave number
   lda WaveMaximumDemons,x          ; get maximum Demons for wave value
   cmp numberOfSpawnedDemons        ; compare with current number of Demons
   bcs .transitionToNewWave         ; branch if more Demons to spawn
   lda gameState                    ; get current game state
   and #<~(SPONTANEOUS_SKULL_MASK | NEW_WAVE_MASK)
   sta gameState                    ; set to SPONTANEOUS_SKULL_OFF and NEW_WAVE_OFF
   beq .transitionToNewWave
CheckToIncrementWave
   lda gameState                    ; get current game state
   and #NEW_WAVE_MASK               ; keep NEW_WAVE value
   beq .transitionToNewWave         ; branch if NEW_WAVE_OFF
   lda numberOfSpawnedDemons        ; get number of spawned Demons
   beq .transitionToNewWave         ; branch if no Demons spawned
   lda #0
   sta numberOfSpawnedDemons        ; reset number of spawned Demons
   lda currentWaveNumber            ; get current wave number
   cmp #MAX_WAVE
   beq .setNewWaveColorCycleValue
   inc currentWaveNumber            ; increment wave number
.setNewWaveColorCycleValue
   lda #16
   sta newWaveColorCycleValue
.transitionToNewWave
   lda frameCount                   ; get current frame count
   and #3
   bne CheckToPlayGameAlertSounds
   lda newWaveColorCycleValue       ; get new wave color cycle value
   beq CheckToPlayGameAlertSounds   ; branch if not color cycling for new wave
   sta colorEOR                     ; set color EOR for new wave
   dec newWaveColorCycleValue       ; decrement new wave color cycle value
   bne CheckToPlayGameAlertSounds
   lda gameState                    ; get current game state
   ora #SPONTANEOUS_SKULL_ON
   sta gameState
CheckToPlayGameAlertSounds
   lda laserBaseHitSoundIdx         ; get Laser Base hit sound index value
   beq .checkToPlayerRemainingLivesSounds;branch if not playing hit sounds
   lda frameCount                   ; get current frame count
   and #7
   bne .animateObjects
   lda #3
   sta AUDC1
   dec laserBaseHitSoundIdx         ; decrement Laser Base hit sound index
   ldx laserBaseHitSoundIdx         ; get Laser Base hit sound index value
   lda LaserBaseHitSoundFreqValues,x
   sta AUDF1
   lda LaserBaseHitSoundVolumeValues,x
   sta AUDV1
   txa
   bne .animateObjects
   lda topPlayerStatusValue         ; get top player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   sta topPlayerStatusValue
   lda bottomPlayerStatusValue      ; get bottom player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   sta bottomPlayerStatusValue
.animateObjects
   jmp AnimateObjects
    
.checkToPlayerRemainingLivesSounds
   lda livesRemainingSoundIdx       ; get lives remaining sound index value
   beq AnimateObjects               ; branch if not playing game over sounds
   lda frameCount                   ; get current frame count
   and #3
   bne AnimateObjects
   dec livesRemainingSoundIdx       ; decrement lives remaining sound index
   ldx livesRemainingSoundIdx       ; get lives remaining sound index value
   lda #12
   sta AUDC1
   lda LivesRemainingSoundFreqValues,x
   sta AUDF1
   lda LivesRemainingSoundVolumeValues,x
   sta AUDV1
   txa
   bne AnimateObjects
   lda topPlayerStatusValue         ; get top player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   bne .scoreBonusPointsForRemainingLives;branch if lives remaining
   inx
   lda bottomPlayerStatusValue      ; get bottom player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   beq .setColorCycleModeOn         ; branch if no lives remaining
.scoreBonusPointsForRemainingLives
   dec playerStatusValues,x
   lda #16
   sta livesRemainingSoundIdx
   txa                              ; move player index to the accumulator
   asl                              ; multiply by 2
   sta tmpRewardedPlayerIndex       ; set index for rewarded player
   ldy currentWaveNumber            ; get current wave number
   lda LivesRemainingPointHundredsValue,y
   tax
   lda LivesRemainingPointOnesValue,y
   ldy tmpRewardedPlayerIndex
   jsr IncrementScore
   jmp AnimateObjects
    
.setColorCycleModeOn
   lda gameState                    ; get current game state
   and #SKULL_BULLET_MASK | NUM_PLAYERS_MASK | NEW_WAVE_MASK | OPPONENT_SHOOT_MASK
   ora #COLOR_CYCLE_ON              ; set COLOR_CYCLE_ON
   sta gameState
AnimateObjects
   lda frameCount                   ; get current frame count
   and #7
   tax
   lda obj0AttributeValues,x        ; get object 0 attribute value
   and #OBJ_ID_MASK                 ; keep object id value
   tay
   lda obj0AttributeValues,x        ; get object 0 attribute value
   and #~OBJ_ID_MASK                ; clear object id value
   ora ObjectIdAnimationValues,y
   sta obj0AttributeValues,x        ; set new animation object id value
   lda obj1AttributeValues,x
   and #OBJ_ID_MASK                 ; keep object id value
   tay
   lda obj1AttributeValues,x
   and #~OBJ_ID_MASK                ; clear object id value
   ora ObjectIdAnimationValues,y
   sta obj1AttributeValues,x
   lda #>NumberFonts
   sta player1OnesDigitPtr + 1
   sta player1TensDigitPtr + 1
   sta player1HundredsDigitPtr + 1
   sta player1ThousandsDigitPtr + 1
   sta player2OnesDigitPtr + 1
   sta player2TensDigitPtr + 1
   sta player2HundredsDigitPtr + 1
   sta player2ThousandsDigitPtr + 1
   lda #<Blank
   sta player2ThousandsDigitPtr
   sta player2HundredsDigitPtr
   sta player2TensDigitPtr
   sta player1ThousandsDigitPtr
   sta player1HundredsDigitPtr
   sta player1TensDigitPtr
   lda #0
   sta player2OnesDigitPtr
   sta player1OnesDigitPtr
   sta tmpTopScoreZeroSuppressValue
   sta tmpBottomScoreZeroSuppressValue
   lda player2HundredValue          ; get top score hundreds value
   and #$F0                         ; keep thousands value
   beq .determineTopScoreHundredsDigitPtr;branch if leading value is zero
   sta tmpTopScoreZeroSuppressValue ; set to determine zero suppression needed
   lsr                              ; divide by 2 (i.e. H_DIGITS)
   sta player2ThousandsDigitPtr     ; set top score thousands digit LSB value
.determineTopScoreHundredsDigitPtr
   lda player2HundredValue          ; get top score hundreds value
   and #$0F                         ; keep hundreds value
   tax
   ora tmpTopScoreZeroSuppressValue ; combine with thousands value
   beq .determineTopScoreTensDigitPtr;branch if suppressing leading zeroes
   sta tmpTopScoreZeroSuppressValue ; set combined thousands and hundreds value
   txa                              ; move hundreds value to accumulator
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta player2HundredsDigitPtr      ; set top score hundreds digit LSB value
.determineTopScoreTensDigitPtr
   lda player2OnesValue             ; get top score ones value
   and #$F0                         ; keep tens value
   tax
   ora tmpTopScoreZeroSuppressValue ; combine with hundreds value
   beq .determineTopScoreOnesDigitPtr;branch if suppressing leading zeros
   sta tmpTopScoreZeroSuppressValue ; set combined score value
   txa
   lsr                              ; divide by 2 (i.e. H_DIGITS)
   sta player2TensDigitPtr          ; set top score tens digit LSB value
.determineTopScoreOnesDigitPtr
   lda player2OnesValue             ; get top score ones value
   and #$0F                         ; keep ones value
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta player2OnesDigitPtr          ; set top score ones digit LSB value
   lda player1HundredsValue         ; get bottom score hundreds value
   and #$F0                         ; keep thousands value
   beq .determineBottomScoreHundredsDigitPtr
   sta tmpBottomScoreZeroSuppressValue;set to determine zero suppression needed
   lsr                              ; divide by 2 (i.e. H_DIGITS)
   sta player1ThousandsDigitPtr     ; set bottom score thousands digit LSB value
.determineBottomScoreHundredsDigitPtr
   lda player1HundredsValue         ; get bottom score hundreds value
   and #$0F                         ; keep hundreds value
   tax
   ora tmpBottomScoreZeroSuppressValue;combine with thousands value
   beq .determineBottomScoreTensDigitPtr;branch if suppressing leading zeroes
   sta tmpBottomScoreZeroSuppressValue;set combined thousands and hundreds value
   txa                              ; move hundreds value to accumulator
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta player1HundredsDigitPtr      ; set bottom score hundreds digit LSB value
.determineBottomScoreTensDigitPtr
   lda player1OnesValue             ; get bottom score ones value
   and #$F0                         ; keep tens value
   tax
   ora tmpBottomScoreZeroSuppressValue;combine with hundreds value
   beq .determineBottomScoreOnesDigitPtr;branch if suppressing leading zeros
   sta tmpBottomScoreZeroSuppressValue;set combined score value
   txa
   lsr                              ; divide by 2 (i.e. H_DIGITS)
   sta player1TensDigitPtr          ; set bottom score tens digit LSB value
.determineBottomScoreOnesDigitPtr
   lda player1OnesValue             ; get bottom score ones value
   and #$0F                         ; keep ones value
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta player1OnesDigitPtr          ; set bottom score ones digit LSB value
   lda newWaveColorCycleValue       ; get new wave color cycle value
   bne .checkToEnableBall           ; branch if cycling colors for new wave
   ldy #$FF
   lda gameState                    ; get current game state
   and #COLOR_CYCLE_MASK            ; keep COLOR_CYCLE_MASK value
   bne .cycleColors                 ; branch if COLOR_CYCLE_ON
   sta colorEOR                     ; clear colorEOR value (i.e. a = 0)
   beq .setColorHueMaskValue        ; unconditional branch
    
.cycleColors
   ldy #$F7
   lda frameCount                   ; get current frame count
   bne .setColorHueMaskValue
   inc colorEOR
.setColorHueMaskValue
   sty hueMask
.checkToEnableBall
   lda ballGraphicValue             ; get BALL graphic value
   beq .setReservedLivesGraphicValues;branch if BALL not active
   lda #8
   clc
   adc missileObjectHorizPosition   ; increment by object position
   
   IF COMPILE_REGION = PAL50
   
   SLEEP 2
   SLEEP 2
   SLEEP 2
   SLEEP 2
   
   ENDIF
   
   sta WSYNC                        ; wait for next scan line
   tax
   lda ColorClockPositionValues,x   ; get color clock position value
   sta HMBL                         ; set BALL fine motion
   and #$0F                         ; keep coarse position value
   tay
   SLEEP 2
.coarsePositionBall
   dey
   bpl .coarsePositionBall
   sta RESBL
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
.setReservedLivesGraphicValues
   lda topPlayerStatusValue         ; get top player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   tax
   lda ReservedLivesGraphicsData,x
   sta topPlayerReserveLivesGraphic
   lda bottomPlayerStatusValue      ; get bottom player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   tax
   lda ReservedLivesGraphicsData,x
   sta bottomPlayerReserveLivesGraphic
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   ldx #9                     ; 2
   stx scanlineCount          ; 3
   sta HMCLR                  ; 3 = @11   clear horizontal motion registers
   sta CXCLR                  ; 3 = @14   clear all collisions
   lda #PLAYFIELD_COLOR       ; 2
   eor colorEOR               ; 3         flip color bits if COLOR_CYCLE_ON
   and hueMask                ; 3         hue mask for object colors
   sta COLUPF                 ; 3 = @25
   jmp DrawTopScoreKernel     ; 3
     
CheckResetAndSelectSwitches
   lda SWCHB                        ; read the console switches
   ror                              ; shift RESET to carry
   bcc .resetSwitchDown             ; branch if RESET pressed
   ror                              ; shift SELECT to carry
   bcc .selectSwitchDown            ; branch if SELECT pressed
   ldx #1
   stx selectDebounceTimer          ; reset debounce timer value
.consoleSwitchesNotPressed
   sec                              ; set to show RESET or SELECT not pressed
   rts
    
.selectSwitchDown
   dec selectDebounceTimer          ; decrement debounce timer
   bne .consoleSwitchesNotPressed   ; branch if debounce timer not expired
IncrementGameSelection
   lda #INIT_SELECT_DEBOUNCE_TIME
   sta selectDebounceTimer
   lda gameState                    ; get current game state
   and #COPYRIGHT_MASK              ; keep COPYRIGHT_MASK value
   beq .displayNumberOfPlayers      ; branch if COPYRIGHT_OFF
   sed                              ; set to decimal mode
   lda currentGameSelection         ; get current game selection
   clc
   adc #1                           ; increment game selection
   cmp #MAX_GAME_SELECTION + 1
   bne .setCurrentGameSelectionValue
   lda #1
.setCurrentGameSelectionValue
   sta currentGameSelection
   cld                              ; clear decimal mode
.displayNumberOfPlayers
   lda #2
   sta topPlayerStatusValue         ; set to assume display TWO_PLAYERS game
   ldx currentGameSelection         ; get current game selection
   lda GameSelectGameVariationValues - 1,x;get game variation values
   sta gameState
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   beq .displayGameSelectionValues  ; branch if TWO_PLAYERS game
   dec topPlayerStatusValue         ; decrement to display ONE_PLAYER game
.displayGameSelectionValues
   lda #0
   sta bottomPlayerStatusValue
   lda currentGameSelection         ; get current game selection
   tax                              ; move game selection to x register
   sta player2HundredValue          ; set to display current game selection
   lda #BLANK_IDX_VALUE << 4 | BLANK_IDX_VALUE
   sta player2OnesValue             ; set to show Blank values
   sta player1HundredsValue
   sta player1OnesValue
   bne .initObjectGraphicValues     ; unconditional branch
   
.resetSwitchDown
   dec selectDebounceTimer          ; decrement debounce timer
   bne .consoleSwitchesNotPressed   ; branch if debounce timer not expired
   ldx #INIT_RESET_DEBOUNCE_TIME
   stx selectDebounceTimer          ; set RESET debounce timer value
   ldx currentGameSelection         ; get current game selection
   lda GameResetGameVariationValues - 1,x;get game variation values
   sta gameState
   lda #INIT_RESERVED_LIVES
   sta topPlayerStatusValue         ; set initial number of reserved lives
   sta bottomPlayerStatusValue
   ldx #0
   stx player2HundredValue          ; reset player score values
   stx player2OnesValue
   stx player1HundredsValue
   stx player1OnesValue
   lda gameState                    ; get current game state
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   beq .initObjectGraphicValues     ; branch if TWO_PLAYERS game
   lda #BLANK_IDX_VALUE << 4 | BLANK_IDX_VALUE
   sta player2HundredValue          ; show Blank values for player 2 score
   sta player2OnesValue
   lda #0
   sta topPlayerStatusValue
.initObjectGraphicValues
   ldx #>ObstacleGraphics
   stx obj0GraphicPtrs + 1          ; set obstacle graphic MSB value
   stx obj1GraphicPtrs + 1
   lda #DOUBLE_SIZE
   sta NUSIZ0
   sta NUSIZ1
   lda #MSBL_SIZE4 | PF_REFLECT
   sta CTRLPF
   lda #4
   sta AUDC0
   sta CXCLR                        ; clear all hardware collision values
   lda #0
   sta currentWaveNumber            ; set initial wave number
   sta numberOfSpawnedDemons        ; init number of spawned Demons
   sta laserBaseHitSoundIdx         ; clear Laser Base hit sound index
   sta livesRemainingSoundIdx       ; clear lives remaining sound index
   sta newWaveColorCycleValue       ; clear new wave color cycle values
   sta frameCount + 1
   sta AUDV1
   sta skullMissileStatus
   ldx #(KERNEL_ZONES * 2) - 1
   lda #OBJ_INACTIVE | $20 | ID_NULL
.initObjectAttributeValues
   sta objectAttributeValues,x
   dex
   bpl .initObjectAttributeValues
   lda #XMIN
   sta obj0HorizontalPositions + 7
   sta obj0HorizontalPositions + 6
   sta obj0HorizontalPositions + 5
   lda #XMAX_SPAWNING_DEMON
   sta obj1HorizontalPositions + 7
   sta obj1HorizontalPositions + 6
   sta obj1HorizontalPositions + 5
   ldx #<[bottomScoreColorValue - laserBaseColorValues]
.initPlayerColorValues
   lda PlayerColorValues,x
   sta laserBaseColorValues,x
   dex
   bpl .initPlayerColorValues
   clc                              ; set to show RESET or SELECT pressed
   rts
    
NextRandom
   lda random                       ; get current random number value
   ldx randomIndexValue             ; get current index value for random
   eor Overscan,x
   eor DetermineLaserBaseHorizPosition,x
   asl                              ; shift D7 to carry bit
   adc #1 - 1
   eor NewFrame,x
   inx
   stx randomIndexValue             ; set new index value (i.e. 0 <= x <= 255)
   eor topLaserBaseHorizPosition
   eor bottomLaserBaseHorizPosition
   eor frameCount + 1
   eor frameCount
   sta random                       ; set new random number value
   rts
    
IncrementScore
   sed                              ; set to decimal mode
   clc
   adc  playerScores + 1,y          ; increment score ones value
   sta  playerScores + 1,y
   txa                              ; move hundreds points to accumulator
   adc  playerScores,y              ; increment score hundreds value
   sta  playerScores,y
   cld                              ; clear decimal mode
   rts
    
PlayerLaserBaseHit
   lda playerStatusValues,x         ; get player status values
   and #RESERVED_LIVES_MASK         ; keep number of reserved lives
   bne .decrementNumberOfLives
   lda #1
   sta livesRemainingSoundIdx
   bne .setPlayerStunned            ; unconditional branch
   
.decrementNumberOfLives
   dec playerStatusValues,x
.setPlayerStunned
   sta skullMissileStatus
   lda playerStatusValues,x
   ora #PLAYER_STUNNED
   sta playerStatusValues,x
   lda #16
   sta laserBaseHitSoundIdx
   rts
    
PlayerColorValues
   .byte TOP_LASER_BASE_COLOR_00
   .byte TOP_LASER_BASE_COLOR_01
   .byte BOTTOM_LASER_BASE_COLOR_00
   .byte BOTTOM_LASER_BASE_COLOR_01
   .byte TOP_SCORE_COLOR
   .byte BOTTOM_SCORE_COLOR

TopLaserBase_00
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
TopLaserBase_01
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
    
BottomLaserBase_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
BottomLaserBase_01
   .byte $E7 ; |XXX..XXX|
   .byte $BD ; |X.XXXX.X|
   .byte $99 ; |X..XX..X|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
    
ObjectSpeedMaskingValues
   .byte 1, 8, 4, 8, 2, 8, 4, 8
   .byte 0, 8, 4, 8, 2, 8, 4, 8
    
GameResetGameVariationValues
   .byte GAME_PLAY_ON |SKULL_BULLET_FAST|ONE_PLAYER |COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_ON |SKULL_BULLET_FAST|TWO_PLAYERS|COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_ON |SKULL_BULLET_FAST|TWO_PLAYERS|COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_ON
   .byte GAME_PLAY_ON |SKULL_BULLET_SLOW|ONE_PLAYER |COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_ON |SKULL_BULLET_SLOW|TWO_PLAYERS|COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_ON |SKULL_BULLET_SLOW|TWO_PLAYERS|COPYRIGHT_OFF|COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_ON
   
GameSelectGameVariationValues
   .byte GAME_PLAY_OFF|SKULL_BULLET_FAST|ONE_PLAYER |COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_OFF|SKULL_BULLET_FAST|TWO_PLAYERS|COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_OFF|SKULL_BULLET_FAST|TWO_PLAYERS|COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_ON
   .byte GAME_PLAY_OFF|SKULL_BULLET_SLOW|ONE_PLAYER |COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_OFF|SKULL_BULLET_SLOW|TWO_PLAYERS|COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_OFF
   .byte GAME_PLAY_OFF|SKULL_BULLET_SLOW|TWO_PLAYERS|COPYRIGHT_ON |COLOR_CYCLE_OFF|SPONTANEOUS_SKULL_ON|NEW_WAVE_OFF|OPPONENT_SHOOT_ON
   
WaveMaximumDemons
   .byte 16, 32, 32, 48, 48, 64, 64, 80, 80
   .byte 96, 96, 112, 112, 128, 128, 144
   
DemonTransitionZoneValues
   .byte 4, 0, 1, 2, 5, 6, 7, 3
   .byte 12, 8, 9, 10, 13, 14, 15, 11, 4
   .byte 0, 1, 2, 5, 6, 7, 3

ObjectIdAnimationValues
   .byte ID_DEMON_01, ID_DEMON_02, ID_DEMON_03, ID_DEMON_00, ID_SPAWN_DEMON_01
   .byte ID_SPAWN_DEMON_02, ID_SPAWN_DEMON_03, ID_DEMON_00, ID_DIAMOND_01
   .byte ID_DIAMOND_00, ID_SKULL, ID_EXPLOSION_01, ID_EXPLOSION_02
   .byte ID_EXPLOSION_03, ID_NULL, ID_NULL
    
KernelZoneBackgroundColors
   .byte BLACK, COLOR_ZONE_01, COLOR_ZONE_02, COLOR_ZONE_03, COLOR_ZONE_04
   .byte COLOR_ZONE_05, COLOR_ZONE_06, COLOR_ZONE_07, COLOR_ZONE_08
    
TopLaserBaseLaserEndPointValues
   .byte TOP_LASER_END_POINT_ZONE_00
   .byte TOP_LASER_END_POINT_ZONE_01
   .byte TOP_LASER_END_POINT_ZONE_02
   .byte TOP_LASER_END_POINT_ZONE_03
   .byte TOP_LASER_END_POINT_ZONE_04
   .byte TOP_LASER_END_POINT_ZONE_05
   .byte TOP_LASER_END_POINT_ZONE_06
   .byte TOP_LASER_END_POINT_ZONE_07
    
BottomLaserBaseLaserEndPointValues
   .byte BOTTOM_LASER_END_POINT_ZONE_00
   .byte BOTTOM_LASER_END_POINT_ZONE_01
   .byte BOTTOM_LASER_END_POINT_ZONE_02
   .byte BOTTOM_LASER_END_POINT_ZONE_03
   .byte BOTTOM_LASER_END_POINT_ZONE_04
   .byte BOTTOM_LASER_END_POINT_ZONE_05
   .byte BOTTOM_LASER_END_POINT_ZONE_06
   .byte BOTTOM_LASER_END_POINT_ZONE_07

ReservedLivesGraphicsData
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $A0 ; |X.X.....|
   .byte $A8 ; |X.X.X...|
   .byte $AA ; |X.X.X.X.|
   
WaveObjectSpeedValues
   .byte 0, 1, 1, 3, 3, 7, 7, 15, 15, 31
   .byte 31, 63, 63, 127, 127, 255, 255
   
WaveObjectSpawningFrequencyValues
   .byte 8, 8, 4, 4, 2, 2, 1, 1
   .byte 1, 1, 1, 1, 1, 1, 1, 1
   
ObjectSpawningMaskingValues
   .byte 1, 3, 7, 15, 15, 7, 3, 1
   .byte 1, 3, 7, 15, 15, 7, 3, 1
   
SkullSpawningMaskingValues
   .byte 1, 1, 3, 3, 7, 7, 15, 15
   .byte 1, 1, 3, 3, 7, 7, 15, 15

DiamondSpawnHorizontalValues
   .byte 14, 140
    
DiamondSpawnAttributeValues
   .byte OBJ_DIR_RIGHT | ID_DIAMOND_00
   .byte OBJ_DIR_LEFT  | ID_DIAMOND_00

LivesRemainingPointHundredsValue
   .byte POINTS_PER_LIFE_WAVE_01 >> 8
   .byte POINTS_PER_LIFE_WAVE_02 >> 8
   .byte POINTS_PER_LIFE_WAVE_03 >> 8
   .byte POINTS_PER_LIFE_WAVE_04 >> 8
   .byte POINTS_PER_LIFE_WAVE_05 >> 8
   .byte POINTS_PER_LIFE_WAVE_06 >> 8
   .byte POINTS_PER_LIFE_WAVE_07 >> 8
   .byte POINTS_PER_LIFE_WAVE_08 >> 8
   .byte POINTS_PER_LIFE_WAVE_09 >> 8
   .byte POINTS_PER_LIFE_WAVE_10 >> 8
   .byte POINTS_PER_LIFE_WAVE_11 >> 8
   .byte POINTS_PER_LIFE_WAVE_12 >> 8
   .byte POINTS_PER_LIFE_WAVE_13 >> 8
   .byte POINTS_PER_LIFE_WAVE_14 >> 8
   .byte POINTS_PER_LIFE_WAVE_15 >> 8
   .byte POINTS_PER_LIFE_WAVE_16 >> 8
   
LivesRemainingPointOnesValue
   .byte <POINTS_PER_LIFE_WAVE_01
   .byte <POINTS_PER_LIFE_WAVE_02
   .byte <POINTS_PER_LIFE_WAVE_03
   .byte <POINTS_PER_LIFE_WAVE_04
   .byte <POINTS_PER_LIFE_WAVE_05
   .byte <POINTS_PER_LIFE_WAVE_06
   .byte <POINTS_PER_LIFE_WAVE_07
   .byte <POINTS_PER_LIFE_WAVE_08
   .byte <POINTS_PER_LIFE_WAVE_09
   .byte <POINTS_PER_LIFE_WAVE_10
   .byte <POINTS_PER_LIFE_WAVE_11
   .byte <POINTS_PER_LIFE_WAVE_12
   .byte <POINTS_PER_LIFE_WAVE_13
   .byte <POINTS_PER_LIFE_WAVE_14
   .byte <POINTS_PER_LIFE_WAVE_15
   .byte <POINTS_PER_LIFE_WAVE_16

LaserBaseHitSoundFreqValues
   .byte 6, 8, 10, 6, 8, 10, 6, 8
   .byte 10, 6, 8, 10, 6, 8, 10, 6

LaserBaseHitSoundVolumeValues
   .byte 0, 1, 1, 2, 2, 3, 3, 4
   .byte 5, 6, 7, 8, 10, 12, 14, 15

LivesRemainingSoundFreqValues
   .byte 2, 6, 2, 6, 2, 6, 2, 6
   .byte 2, 6, 2, 6, 2, 6, 2, 6

LivesRemainingSoundVolumeValues
   .byte 0, 1, 1, 2, 2, 3, 3, 4, 5
   .byte 6, 7, 8, 9, 10, 11, 13
    
DemonPointValues
   .byte 1, 2, 3, 4, 5, 6, 7, 8
    
Copyright_0
   .byte $79 ; |.XXXX..X|
   .byte $85 ; |X....X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $85 ; |X....X.X|
   .byte $79 ; |.XXXX..X|
Copyright_1
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $77 ; |.XXX.XXX|
Copyright_2
   .byte $71 ; |.XXX...X|
   .byte $41 ; |.X.....X|
   .byte $41 ; |.X.....X|
   .byte $71 ; |.XXX...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $70 ; |.XXX....|
Copyright_3
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $BE ; |X.XXXXX.|
Copyright_4
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $D9 ; |XX.XX..X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $99 ; |X..XX..X|
    
   FILL_BOUNDARY 0, 0
    
ObstacleGraphics
DemonSprites
Demon_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $46 ; |.X...XX.|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $FC ; |XXXXXX..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
    
   FILL_BOUNDARY 16, 0
    
Demon_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $06 ; |.....XX.|
   .byte $D4 ; |XX.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $C6 ; |XX...XX.|
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $7E ; |.XXXXXX.|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
    
   FILL_BOUNDARY 32, 0

Demon_02    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $D0 ; |XX.X....|
   .byte $7E ; |.XXXXXX.|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $FC ; |XXXXXX..|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
    
   FILL_BOUNDARY 48, 0

Demon_03    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $06 ; |.....XX.|
   .byte $D4 ; |XX.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $44 ; |.X...X..|
   .byte $C6 ; |XX...XX.|
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $7E ; |.XXXXXX.|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
    
   FILL_BOUNDARY 64, 0
    
SpawningDemonSprites
SpawningDemon_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 80, 0
    
SpawningDemon_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 96, 0

SpawningDemon_02    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 112, 0

SpawningDemon_03    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $44 ; |.X...X..|
   .byte $38 ; |..XXX...|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|

   FILL_BOUNDARY 128, 0

DiamondSprites
Diamond_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $A8 ; |X.X.X...|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY 144, 0

Diamond_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY 160, 0

Skull

   IF COMPILE_REGION = PAL50
   
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   ENDIF
   
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
    
   FILL_BOUNDARY 176, 0
   
ExplosionSprites
Explosion_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 192, 0

Explosion_01    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 208, 0

Explosion_02    
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 224, 0

Explosion_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
   FILL_BOUNDARY 240, 0
   
Null
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
    
   FILL_BOUNDARY 0, 0

NumberFonts
zero
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
one
   .byte $0E ; |....XXX.|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
two
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
three
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
four
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
five
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
six
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
seven
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
eight
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
nine
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $02 ; |......X.|
   .byte $06 ; |.....XX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
    
ColorClockPositionValues
   .byte HMOVE_L6 | 0, HMOVE_L5 | 0, HMOVE_L4 | 0, HMOVE_L3 | 0, HMOVE_L2 | 0
   .byte HMOVE_L1 | 0, HMOVE_0  | 0, HMOVE_R1 | 0, HMOVE_R2 | 0, HMOVE_R3 | 0
   .byte HMOVE_R4 | 0, HMOVE_R5 | 0, HMOVE_R6 | 0, HMOVE_R7 | 0, HMOVE_L7 | 1
   .byte HMOVE_L6 | 1, HMOVE_L5 | 1, HMOVE_L4 | 1, HMOVE_L3 | 1, HMOVE_L2 | 1
   .byte HMOVE_L1 | 1, HMOVE_0  | 1, HMOVE_R1 | 1, HMOVE_R2 | 1, HMOVE_R3 | 1
   .byte HMOVE_R4 | 1, HMOVE_R5 | 1, HMOVE_R6 | 1, HMOVE_R7 | 1, HMOVE_L7 | 2
   .byte HMOVE_L6 | 2, HMOVE_L5 | 2, HMOVE_L4 | 2, HMOVE_L3 | 2, HMOVE_L2 | 2
   .byte HMOVE_L1 | 2, HMOVE_0  | 2, HMOVE_R1 | 2, HMOVE_R2 | 2, HMOVE_R3 | 2
   .byte HMOVE_R4 | 2, HMOVE_R5 | 2, HMOVE_R6 | 2, HMOVE_R7 | 2, HMOVE_L7 | 3
   .byte HMOVE_L6 | 3, HMOVE_L5 | 3, HMOVE_L4 | 3, HMOVE_L3 | 3, HMOVE_L2 | 3
   .byte HMOVE_L1 | 3, HMOVE_0  | 3, HMOVE_R1 | 3, HMOVE_R2 | 3, HMOVE_R3 | 3
   .byte HMOVE_R4 | 3, HMOVE_R5 | 3, HMOVE_R6 | 3, HMOVE_R7 | 3, HMOVE_L7 | 4
   .byte HMOVE_L6 | 4, HMOVE_L5 | 4, HMOVE_L4 | 4, HMOVE_L3 | 4, HMOVE_L2 | 4
   .byte HMOVE_L1 | 4, HMOVE_0  | 4, HMOVE_R1 | 4, HMOVE_R2 | 4, HMOVE_R3 | 4
   .byte HMOVE_R4 | 4, HMOVE_R5 | 4, HMOVE_R6 | 4, HMOVE_R7 | 4, HMOVE_L7 | 5
   .byte HMOVE_L6 | 5, HMOVE_L5 | 5, HMOVE_L4 | 5, HMOVE_L3 | 5, HMOVE_L2 | 5
   .byte HMOVE_L1 | 5, HMOVE_0  | 5, HMOVE_R1 | 5, HMOVE_R2 | 5, HMOVE_R3 | 5
   .byte HMOVE_R4 | 5, HMOVE_R5 | 5, HMOVE_R6 | 5, HMOVE_R7 | 5, HMOVE_L7 | 6
   .byte HMOVE_L6 | 6, HMOVE_L5 | 6, HMOVE_L4 | 6, HMOVE_L3 | 6, HMOVE_L2 | 6
   .byte HMOVE_L1 | 6, HMOVE_0  | 6, HMOVE_R1 | 6, HMOVE_R2 | 6, HMOVE_R3 | 6
   .byte HMOVE_R4 | 6, HMOVE_R5 | 6, HMOVE_R6 | 6, HMOVE_R7 | 6, HMOVE_L7 | 7
   .byte HMOVE_L6 | 7, HMOVE_L5 | 7, HMOVE_L4 | 7, HMOVE_L3 | 7, HMOVE_L2 | 7
   .byte HMOVE_L1 | 7, HMOVE_0  | 7, HMOVE_R1 | 7, HMOVE_R2 | 7, HMOVE_R3 | 7
   .byte HMOVE_R4 | 7, HMOVE_R5 | 7, HMOVE_R6 | 7, HMOVE_R7 | 7, HMOVE_L7 | 8
   .byte HMOVE_L6 | 8, HMOVE_L5 | 8, HMOVE_L4 | 8, HMOVE_L3 | 8, HMOVE_L2 | 8
   .byte HMOVE_L1 | 8, HMOVE_0  | 8, HMOVE_R1 | 8, HMOVE_R2 | 8, HMOVE_R3 | 8
   .byte HMOVE_R4 | 8, HMOVE_R5 | 8, HMOVE_R6 | 8, HMOVE_R7 | 8, HMOVE_L7 | 9
   .byte HMOVE_L6 | 9, HMOVE_L5 | 9, HMOVE_L4 | 9, HMOVE_L3 | 9, HMOVE_L2 | 9
   .byte HMOVE_L1 | 9, HMOVE_0  | 9, HMOVE_R1 | 9, HMOVE_R2 | 9, HMOVE_R3 | 9
   .byte HMOVE_R4 | 9

ObjectHorizontalMaximumValues
   .byte XMAX_DEMON, XMAX_DEMON, XMAX_DEMON, XMAX_DEMON, XMAX_SPAWNING_DEMON
   .byte XMAX_SPAWNING_DEMON, XMAX_SPAWNING_DEMON, XMAX_SPAWNING_DEMON
   .byte XMAX_DIAMOND, XMAX_DIAMOND, XMAX_SKULL, XMAX_EXPLOSION, XMAX_EXPLOSION
   .byte XMAX_EXPLOSION, XMAX_EXPLOSION, XMAX_EXPLOSION
    
    FILL_BOUNDARY 252, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"
   
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector