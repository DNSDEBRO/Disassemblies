   LIST OFF
; ***  S M U R F  -  R E S C U E  I N  G A R G M E L ' S  C A S T L E  ***
; Copyright 1982 Coleco, Inc.
; Designer: Henry Will, IV
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: June 15, 2021
;
;  ***  88 BYTES OF RAM USED 40 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
; ***   5 BYTES OF ROM FREE IN BANK0
; *** 168 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 173 TOTAL BYTES FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; ***  12 BYTES OF BANK0 FREE
; *** 166 BYTES OF BANK1 FREE
; ===========================================
; *** 178 TOTAL BYTES FREE
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
;
; - There is unexecuted code that allowed user to bypass the entire Smurfette
;     rescued music routine

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

   IFNCONST ORIGINAL_ROM
   
ORIGINAL_ROM            = TRUE

   ENDIF

   IF COMPILE_REGION = PAL60
   
ORIGINAL_ROM            = FALSE

   ENDIF

   IF !(ORIGINAL_ROM = TRUE || ORIGINAL_ROM = FALSE)

      echo ""
      echo "*** ERROR: Invalid ORIGINAL_ROM value"
      echo "*** Valid values: FALSE = 0, TRUE = 1"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

VSYNC_TIME              = 24

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 56
OVERSCAN_TIME           = 36
OVERSCAN_TIME_SCREEN_TRANSITION = OVERSCAN_TIME - 11

H_KERNEL                = 165
H_DRAW_RIVER_ROOM_KERNEL = H_KERNEL - 107

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 71
OVERSCAN_TIME           = 81
OVERSCAN_TIME_SCREEN_TRANSITION = OVERSCAN_TIME - 12

H_KERNEL                = 166
H_DRAW_RIVER_ROOM_KERNEL = H_KERNEL - 108

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
YELLOW                  = $10
LT_RED                  = $20
RED                     = $30
ORANGE                  = $40
DK_PINK                 = $50
VIOLET                  = $60
BLUE                    = $80
LT_BLUE                 = $90
GREEN                   = $C0
LT_BROWN                = $E0

COLOR_SMURF_BLUE        = BLUE + 8
COLOR_PLAYER_ONE_ENERGY_BAR = RED + 4
COLOR_PLAYER_TWO_ENERGY_BAR = COLOR_SMURF_BLUE
COLOR_TREE_LEAVES       = GREEN
COLOR_TREE_SKY          = DK_PINK + 10
COLOR_LAB_FLOOR         = LT_BLUE
COLOR_SMURFETTE_HAIR    = YELLOW + 12
COLOR_HEART             = RED + 4
COLOR_RIVER             = BLUE + 4

   ELSE

BRICK_RED               = $40
YELLOW                  = $40
LT_BROWN                = $40
GREEN                   = $50
RED                     = $60
CYAN_GREEN              = $70
DK_PINK                 = $80
LT_BLUE                 = $90
VIOLET                  = $A0
BLUE_CYAN               = $B0
BLUE                    = $D0

COLOR_SMURF_BLUE        = BLUE_CYAN + 8
COLOR_PLAYER_ONE_ENERGY_BAR = RED + 6
COLOR_PLAYER_TWO_ENERGY_BAR = COLOR_SMURF_BLUE
COLOR_TREE_LEAVES       = CYAN_GREEN
COLOR_TREE_SKY          = DK_PINK + 12
COLOR_LAB_FLOOR         = BLUE_CYAN
COLOR_SMURFETTE_HAIR    = BRICK_RED + 12
COLOR_HEART             = RED + 6
COLOR_RIVER             = BLUE + 4

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

BANK0_BASE              = $1000
BANK1_BASE              = $2000

BANK0_REORG             = $D000
BANK1_REORG             = $F000

BANK0STROBE             = $FF8
BANK1STROBE             = $FF9

XMIN                    = 0
XMAX                    = 159
XMID                    = (XMAX + 1) / 2
XMIN_SMURF              = XMIN + 3
XMIN_SMURF_MUSHROOM_HOUSE = XMIN + 30
XMAX_SMURF              = XMAX - 8
VERT_MIN_SMURF          = 138
VERT_MIN_SMURF_MOUNTAIN_STEP_00 = 151
VERT_MIN_SMURF_MOUNTAIN_STEP_01 = 169
VERT_MIN_SMURF_SPIDER_LEDGE = 163
VERT_MIN_SMURF_GARGAMEL_STOOP_00 = 158
VERT_MIN_SMURF_GARGAMEL_TABLE = 186
VERT_MIN_SMURF_GARGAMEL_CHAIR = 214

VERT_MIN_HAWK_FIELD     = 216
VERT_MIN_HAWK_MOUNTAINS = 194
VERT_MIN_SPIDER         = 183
VERT_MAX_SPIDER         = 254
VERT_MIN_BAT            = 208

HORIZ_SMURF_RESCUED_SMURFETTE = 132
VERT_SMURF_RESCUED_SMURFETTE = 229
STREAM_BANK_HORIZ_POSITION_WEST = 64
STREAM_BANK_HORIZ_POSITION_EAST = 82
;
; Initial horizontal positions
;
INIT_HORIZ_MUSHROOM_OBSTACLE = 0
INIT_HORIZ_FIELD_HAWK   = XMAX - 10
INIT_HORIZ_RIVER_SNAKE  = XMAX - 10
INIT_HORIZ_MOUNTAIN_HAWK = XMAX - 10
INIT_HORIZ_GARGAMEL_BAT = XMAX - 29
INIT_HORIZ_FLYING_OBJECT = 6
HORIZ_FENCE             = XMIN + 30
HORIZ_SMURFETTE         = XMAX - 19
HORIZ_SPIDER_WEB        = 67
INIT_HORIZ_CAVERN_SPIDER = HORIZ_SPIDER_WEB + 8

SMURF_OBSTACLE_HORIZ_RANGE = 30
SMURF_DESCENDING_CHANGE = 4

;
; Initial vertical positions
;
INIT_VERT_HAWK          = <-1
INIT_VERT_SNAKE         = 0
INIT_VERT_SPIDER        = <-6
INIT_VERT_BAT           = <-1

H_FONT                  = 8
H_LIVES                 = 10
H_CLOUDS                = 31
H_SMURFETTE             = 25
H_SMURF                 = 27
H_SMURF_STATIONARY      = H_SMURF
H_SMURF_WALKING_00      = H_SMURF - 1
H_SMURF_WALKING_01      = H_SMURF - 2
H_SMURF_WALKING_02      = H_SMURF - 1
H_SMURF_DUCKING         = H_SMURF - 10
H_SMURF_SITTING         = H_SMURF - 4
H_SMURF_JUMPING         = H_SMURF
H_SMURF_KISSING         = H_SMURF + 7
H_SMURF_DROWNING_00     = H_SMURF - 10
H_SMURF_DROWNING_01     = H_SMURF - 20
H_SMURF_DROWNING_02     = H_SMURF - 20
H_SMURF_DROWNING_03     = H_SMURF - 20
H_SMURF_DROWNING_04     = H_SMURF - 20
H_SUNSET_COLORS         = 63
H_RIVER_ANIMATION       = 4
H_TREE_KERNEL           = 45

SPRITE_END              = 0

INIT_SCREEN_TRANSITION_TIME = 10
;
; Remaining lives constants
;
MAX_REMAINING_LIVES     = 6
INIT_REMAINING_LIVES    = 4
;
; Game selection constants
;
MAX_GAME_SELECTION      = 7
SELECTED_SKILL_MASK     = %00000011
NUM_PLAYERS_GAME_MASK   = %00000100
ACTIVE_PLAYER_MASK      = %10000000

ONE_PLAYER_GAME_SELECTION = 0 << 2
TWO_PLAYER_GAME_SELECTION = 1 << 2

PLAYER_ONE_ACTIVE       = 0 << 7
PLAYER_TWO_ACTIVE       = 1 << 7

MAX_SKILL_LEVEL         = 3
;
; Smurf attribute values
;
SMURF_JUMP_DEBOUNCE_MASK = %01000000
SMURF_VERT_DIR_MASK     = %00100000
SMURF_HORIZ_MOTION_MASK = %00010000
SMURF_HORIZ_DIR_MASK    = %00001000
SMURF_JUMPING_MASK      = %00000100
SMURF_SUPER_JUMP_MASK   = %00000010

SMURF_JUMP_HELD         = 1 << 6
SMURF_JUMP_RELEASED     = 0 << 6
SMURF_VERT_DIR_UP       = 1 << 5
SMURF_VERT_DIR_DOWN     = 0 << 5
SMURF_NO_HORIZ_DIR      = 1 << 4
SMURF_HORIZ_DIR         = 0 << 4
SMURF_HORIZ_DIR_LEFT    = 1 << 3
SMURF_HORIZ_DIR_RIGHT   = 0 << 3
SMURF_JUMPING           = 1 << 2
SMURF_SUPER_JUMPING     = 1 << 1

ID_SMURF_STATIONARY     = 1
ID_SMURF_WALKING        = 2         ; 2 - 5
ID_SMURF_DUCKING        = 6
ID_SMURF_SITTING        = 7
ID_SMURF_JUMPING        = 8
ID_SMURF_KISSING        = 9
ID_SMURF_DROWNING       = 10
;
; Room obstacle attribute values
;
OBJ_HORIZ_DIR_MASK      = %00001000

OBJ_HORIZ_DIR_LEFT      = 0 << 3
OBJ_HORIZ_DIR_RIGHT     = 1 << 3

END_JUMP_ACTION         = 0
;
; Audio Value constants
;
SOUND_PRIORITY_MASK     = %10000000
SOUND_CHANNEL_MASK      = %00100000
END_AUDIO_TUNE          = 0
AUDIO_DURATION_MASK     = $E0
AUDIO_TONE_MASK         = $1F
AUDIO_WAIT              = $F0

SOUND_HIGH_PRIORITY     = 1 << 7
SOUND_LOW_PRIORITY      = 0 << 7
SOUND_TWO_CHANNELS      = 1 << 5
SOUND_ONE_CHANNEL       = 0 << 5

   IF COMPILE_REGION = PAL50

MAX_VOLUME              = 15

   ELSE
   
MAX_VOLUME              = 10

   ENDIF
;
; Room constants
;
ID_ROOM_MUSHROOM_HOUSE  = 0
ID_ROOM_WOODS           = 1
ID_ROOM_RIVER_00        = 2
ID_ROOM_MOUNTAINS       = 3
ID_ROOM_SPIDER_CAVERN   = 4
ID_ROOM_RIVER_01        = 5
ID_ROOM_GARGAMELS_LAB   = 6

MUSHROOM_HOUSE_RULE_IDX = 3
;
; Number font index values
;
ZERO_IDX_VALUE          = <([zero - NumberFonts] / H_FONT)
ONE_IDX_VALUE           = <([one - NumberFonts] / H_FONT)
TWO_IDX_VALUE           = <([two - NumberFonts] / H_FONT)
THREE_IDX_VALUE         = <([three - NumberFonts] / H_FONT)
FOUR_IDX_VALUE          = <([four - NumberFonts] / H_FONT)
FIVE_IDX_VALUE          = <([five - NumberFonts] / H_FONT)
SIX_IDX_VALUE           = <([six - NumberFonts] / H_FONT)
SEVEN_IDX_VALUE         = <([seven - NumberFonts] / H_FONT)
EIGHT_IDX_VALUE         = <([eight - NumberFonts] / H_FONT)
NINE_IDX_VALUE          = <([nine - NumberFonts] / H_FONT)
SKILL_LITERAL_IDX_VALUE_00 = <([SkillLiteral_00 - NumberFonts] / H_FONT)
SKILL_LITERAL_IDX_VALUE_01 = <([SkillLiteral_01 - NumberFonts] / H_FONT)
SKILL_LITERAL_IDX_VALUE_02 = <([SkillLiteral_02 - NumberFonts] / H_FONT)
BLANK_IDX_VALUE         = <([BlankFont - NumberFonts] / H_FONT)
PLAYER_UP_LITERAL_IDX_VALUE = <([PlayerUpLiteral - NumberFonts] / H_FONT)
;
; Score values
;
SCORE_STANDARD_JUMP     = 300
SCORE_SUPER_JUMP        = 400
SCORE_RESCUE_SMURFETTE  = 1000
;
; Game state values
;
GS_INIT_GAME_STATE      = 0
GS_DISPLAY_GAME_SELECTION = 1
GS_INITIALIZE_GAME      = 2
GS_DISPLAY_PLAYER_UP    = 3
GS_DONE_DISPLAY_PLAYER_UP = 4
GS_ADVANCE_TO_GAME_PROCESSING = 5
GS_GAME_IN_PROGRESS     = 6
GS_SET_SMURF_DEATH_VALUES = 7
GS_PERFORM_SMURF_DEATH_ROUTINE = 8
GS_CHECK_TO_ALTERNATE_PLAYERS = 9
GS_DISPLAY_PLAYER_LITERALS = 10

GS_SMURF_RESCUED_SMURFETTE = 13

GS_ALTERNATE_PLAYER_VARIABLES = 17
GS_GAME_OVER            = 18
GS_SMURF_DAMAGE_COLLISION = 19
GS_FALLING_FROM_COLLISION = 20

;===============================================================================
; M A C R O S
;===============================================================================

;
; time wasting macros
;

   MAC SLEEP_3
      lda $FF
   ENDM

   MAC SLEEP_5
      SLEEP 2
      ldx COLUBK
   ENDM

   MAC SLEEP_6
      lda (VSYNC,x)
   ENDM
   
   MAC SLEEP_12
      SLEEP_6
      SLEEP_6
   ENDM

;----------------------------------------------------------
; FILL_BOUNDARY byte#
; Original author: Dennis Debro (borrowed from Bob Smith / Thomas Jentzsch)
;
; Push data to a certain position inside a page.
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

smurfHorizPosition      ds 1
;--------------------------------------
tmpHorizontalJumpChange = smurfHorizPosition
smurfVertPosition       ds 1
;--------------------------------------
tmpVerticalJumpChange   = smurfVertPosition
smurfetteGraphicIndex   ds 1
cloudHorizontalPosition ds 1
roomObstacleGraphicPointer ds 2
roomObjectHorizPosition ds 1
roomObstacleVertPosition ds 1
roomObstacleGraphicIndex ds 1
frameCount              ds 1
gameIdleTimer           ds 1
gameState               ds 1
random                  ds 2
smurfEnergyBarGraphics  ds 2
graphicPointers         ds 12
;--------------------------------------
smurfGraphicPointer     = graphicPointers
smurfColorPointer       = smurfGraphicPointer + 2
;--------------------------------------
livesIndicatorGraphicPtr_00 = graphicPointers
livesIndicatorGraphicPtr_01 = livesIndicatorGraphicPtr_00 + 2
smurfAnimationIndex     ds 1
smurfAttributes         ds 1
roomObstacleAttributes  ds 1
smurfSuperJumpTimer     ds 1
jumpingPositionChangeIndex ds 1
audioIndexValues        ds 3
;--------------------------------------
leftAudioIndexValue     = audioIndexValues
rightAudioIndexValue    = leftAudioIndexValue + 1
soundEffectsAudioIndex  = rightAudioIndexValue + 1
audioDurationValues     ds 3
;--------------------------------------
leftAudioDurationValue  = audioDurationValues
rightAudioDurationValue = leftAudioDurationValue + 1
soundEffectsAudioDurationValue = rightAudioDurationValue + 1
audioVolumeValues       ds 3
;--------------------------------------
leftAudioVolumeValue    = audioVolumeValues
rightAudioVolumeValue   = leftAudioVolumeValue + 1
soundEffectsAudioVolume = rightAudioVolumeValue + 1
audioToneValues         ds 2
;--------------------------------------
leftAudioToneValue      = audioToneValues
rightAudioToneValue     = leftAudioToneValue + 1
audioFrequencyPointer   ds 2
currentlyPlayingAudio   ds 2
soundEffectsAudioToneValue ds 1
currentRoomRuleIndex    ds 1

zpUnused_00             ds 2

selectDebounceTimer     ds 1
;--------------------------------------
haltUserActivityTimer   = selectDebounceTimer
currentGameSelection    ds 1
playerInformationValues ds 12
;--------------------------------------
currentPlayerInformation = playerInformationValues
;--------------------------------------
currentRemainingLives   = currentPlayerInformation
currentPlayerScore      = currentRemainingLives + 1
currentRoomNumber       = currentPlayerScore + 3
currentPlayerSkillLevel = currentRoomNumber + 1
reservedPlayerInformation = currentPlayerInformation + 6
;--------------------------------------
reservedRemainingLives  = reservedPlayerInformation
reservedPlayerScore     = reservedRemainingLives + 1
reservedPlayerRoomNumber = reservedPlayerScore + 3
reservedPlayerSkillLevel = reservedPlayerRoomNumber + 1
roomCycleCount          ds 1
timesThruRoomTally      ds 1
tmpPlayerScore          ds 3
;--------------------------------------
tmpCurrentRoomRuleIndex = tmpPlayerScore
tmpCharHolder           ds 1
;--------------------------------------
tmpRoomObstacleAnimationIndex = tmpCharHolder
;--------------------------------------
tmpSmurfGraphicIdx      = tmpRoomObstacleAnimationIndex
;--------------------------------------
tmpSmurfVertPosition    = tmpSmurfGraphicIdx
tmpSixDigitDisplayLoop  ds 1
;--------------------------------------
tmpSmurfetteGraphicIdx  = tmpSixDigitDisplayLoop
;--------------------------------------
tmpSmurfSkipDrawIdx     = tmpSmurfetteGraphicIdx
stationaryObstacleMask  ds 1
riverSectionHeightValues ds 6
;--------------------------------------
riverHeightSection_05   = riverSectionHeightValues
riverHeightSection_04   = riverHeightSection_05 + 1
riverHeightSection_03   = riverHeightSection_04 + 1
riverHeightSection_02   = riverHeightSection_03 + 1
riverHeightSection_01   = riverHeightSection_02 + 1
riverHeightSection_00   = riverHeightSection_01 + 1
riverAnimationIdx       ds 1

zpUnused_01             ds 2

screenTransitionTimer   ds 1
lastForwardLandVisited  ds 1
spiderSoundTimer        ds 1
obstacleSpawnTimer      ds 1
flyingObjectVertChangeIndex ds 1
flyingObjectVertChangeTimer ds 1
changeSnakeHorizDirTimer ds 1
nextEastRoomRuleIndex   ds 1
scoringRoomIndex        ds 1

   echo "***",(* - $80 - 4)d, "BYTES OF RAM USED", ($100 - * + 4)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E (BANK0)
;===============================================================================

   SEG Bank0
   .org BANK0_BASE
   .rorg BANK0_REORG

Bank0Start
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   cld
   jmp JumpToCurrentGameStateRoutine
    
NumberFonts
zero
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
one
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
two
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $18 ; |...XX...|
   .byte $04 ; |.....X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
three
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $18 ; |...XX...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $38 ; |..XXX...|
four
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
five
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $38 ; |..XXX...|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $3C ; |..XXXX..|
six
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $38 ; |..XXX...|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $1C ; |...XXX..|
seven
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $3C ; |..XXXX..|
eight
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
nine
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $1C ; |...XXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|

SkillLiterals
SkillLiteral_00
   .byte $00 ; |........|
   .byte $62 ; |.XX...X.|
   .byte $92 ; |X..X..X.|
   .byte $12 ; |...X..X.|
   .byte $63 ; |.XX...XX|
   .byte $82 ; |X.....X.|
   .byte $92 ; |X..X..X.|
   .byte $62 ; |.XX...X.|
SkillLiteral_01
   .byte $00 ; |........|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $89 ; |X...X..X|
   .byte $09 ; |....X..X|
   .byte $89 ; |X...X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
SkillLiteral_02
   .byte $00 ; |........|
   .byte $CE ; |XX..XXX.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|

BlankFont
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

PlayerUpLiteral
   .byte $00 ; |........|
   .byte $E8 ; |XXX.X...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $AE ; |X.X.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AE ; |X.X.XXX.|

BlankLivesIndicator
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
LivesIndicator
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $60 ; |.XX.....|
   .byte $DC ; |XX.XXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $68 ; |.XX.X...|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
    
JumpToCurrentGameStateRoutine
   lda gameState                    ; get current game state
   asl                              ; multiply by 2
   tay
   lda GameStateRoutineTable + 1,y
   pha                              ; push game state routine MSB to stack
   lda GameStateRoutineTable,y
   pha                              ; push game state routine LSB to stack
   rts                              ; jump to game state routine

GameStateRoutineTable
   .word InitialGameState - 1
   .word DisplayGameSelection - 1
   .word InitializeGame - 1
   .word AdvanceGameStateAfterTimerExpired - 1
   .word RestorePlayerValuesFromPlayerUpDisplay - 1
   .word AdvanceCurrentGameState - 1
   .word GameProcessing - 1
   .word SetSmurfDeathSoundsAndAnimation - 1
   .word AdvanceGameStateAfterTimerExpired - 1
   .word CheckToAlternatePlayers - 1
   .word DisplayPlayerUpLiterals - 1
   .word AdvanceGameStateAfterTimerExpired - 1
   .word RestorePlayerValuesFromPlayerUpDisplay - 1
   .word SmurfRescuedSmurfette - 1
   .word PlaySmurfRescuedSmurfetteTune - 1
   .word AdvanceLevelForRescuingSmurfette - 1
   .word AdvanceGameStateToGameProcessing - 1
   .word AlternatePlayerVariables - 1
   .word GameOverState - 1
   .word SmurfDamageCollision - 1
   .word SmurfFallingFromCollision - 1

InitialGameState
   ldx #0
   stx smurfAttributes              ; clear Smurf attribute values
   stx currentRoomNumber            ; set room to ID_ROOM_MUSHROOM_HOUSE
   stx soundEffectsAudioIndex
   dex                              ; x = -1
   stx stationaryObstacleMask       ; set to show stationary object
   ldx #<[SmurfThemeSongAudioValues - BackgroundMusicAudioValues]
   jsr SetGameAudioValues           ; set to play Smurf theme song
   lda #MUSHROOM_HOUSE_RULE_IDX
   sta currentRoomRuleIndex
   jsr InitSmurfStartingLocationValues
   jsr SetCurrentRoomToMushroomHouse
   inc gameState                    ; increment to GS_DISPLAY_GAME_SELECTION
   jmp DisplayGameSelection

SmurfDamageCollision
   ldx #<[SmurfFallingAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; set to play Smurf falling sound effect
   inc gameState                    ; increment to GS_FALLING_FROM_COLLISION
SmurfFallingFromCollision
   lda smurfVertPosition            ; get Smurf vertical position
   cmp #VERT_MIN_SMURF
   bne .smurfFallingFromCollision
   lda #GS_SET_SMURF_DEATH_VALUES
   sta gameState
   bne .newFrame                    ; unconditional branch
    
.smurfFallingFromCollision
   lda smurfVertPosition            ; get Smurf vertical position
   sec
   sbc #SMURF_DESCENDING_CHANGE
   cmp #VERT_MIN_SMURF
   bcs .setFallingSmurfVerticalPosition;branch if not reached ground level
   lda #VERT_MIN_SMURF              ; place Smurf to ground level
.setFallingSmurfVerticalPosition
   sta smurfVertPosition
   jmp NewFrame
    
GameProcessing
   lda CXPPMM                       ; check player collision register
   nop
   nop
   bpl .checkToPlayGameBackgroundMusic;branch if players didn't collide
   lda #GS_SMURF_DAMAGE_COLLISION
.setCurrentGameState
   sta gameState
   lda #<~SMURF_JUMPING_MASK
   jsr RemoveSmurfAttributeValue    ; remove SMURF_JUMPING value
.newFrame
   jmp NewFrame
    
.checkToPlayGameBackgroundMusic
   ldx currentlyPlayingAudio
   bne .checkSmurfEnergyLevel       ; branch if currently playing audio
   ldx #<[GameBackgroundMusicAudioValues - BackgroundMusicAudioValues]
   jsr SetGameAudioValues           ; set to recycle game background music
.checkSmurfEnergyLevel
   lda smurfEnergyBarGraphics + 1   ; get Smurf energy value
   bne .checkIfRescuedSmurfette     ; branch if Smurf has energy remaining
   jmp AdvanceCurrentGameState      ; advance to GS_SET_SMURF_DEATH_VALUES

.checkIfRescuedSmurfette
   lda smurfHorizPosition           ; get Smurf horizontal position
   cmp #HORIZ_SMURF_RESCUED_SMURFETTE - 2
   bcc .checkToReduceSmurfEnergyBar
   lda smurfVertPosition            ; get Smurf vertical position
   bpl .setGameStateToSmurfetteRescued;branch if Smurf outside vertical frame
   cmp #VERT_SMURF_RESCUED_SMURFETTE - 6
   bcc .checkToReduceSmurfEnergyBar
.setGameStateToSmurfetteRescued
   lda #GS_SMURF_RESCUED_SMURFETTE
   bne .setCurrentGameState

.checkToReduceSmurfEnergyBar
   lda frameCount                   ; get current frame count
   and #$FF
   bne .checkToReadJoystickValues   ; branch if 256 frames not passed
   clc
   ror smurfEnergyBarGraphics
   rol smurfEnergyBarGraphics + 1
.checkToReadJoystickValues
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_JUMPING_MASK          ; keep SMURF_JUMPING value
   beq .readPlayerJoystickValues    ; branch if Smurf not jumping
   bne .checkSmurfTransitioningFromRoom;unconditional branch

.readPlayerJoystickValues
   jsr ReadJoystickValues
   tax                              ; move joystick values to x register
   and #<~MOVE_DOWN                 ; isolate MOVE_DOWN bit
   bne .checkForJoystickUpCondition ; branch if not MOVE_DOWN
   lda #0
   sta smurfSuperJumpTimer          ; reset Smurf super jump timer
   lda #ID_SMURF_DUCKING
   sta smurfAnimationIndex
   lda #<~SMURF_HORIZ_MOTION_MASK
   jsr RemoveSmurfAttributeValue
.checkSmurfTransitioningFromRoom
   jmp CheckSmurfTransitioningFromRoom

.checkForJoystickUpCondition
   txa                              ; move joystick value to accumulator
   and #<~MOVE_UP                   ; isolate MOVE_UP bit
   bne .checkForJoystickRightCondition;branch if not MOVE_UP
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_JUMP_DEBOUNCE_MASK    ; keep SMURF_JUMP_DEBOUNCE value
   beq .smurfJumping                ; branch if SMURF_JUMP_RELEASED
   jmp .setSmurfToStationaryAnimation

.smurfJumping
   ldx #<[SmurfJumpingAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; set to play Smurf jumping sound effect
   lda smurfSuperJumpTimer          ; get Smurf super jump timer
   bne .performSuperJump            ; branch if doing super jump
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_MOTION_MASK     ; keep SMURF_HORIZ_MOTION value
   bne .performStationaryJump       ; branch if SMURF_NO_HORIZ_DIR
   lda #<[RunningJumpPositionChangeValues - JumpingPositionChangeValues]
   sta jumpingPositionChangeIndex
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   ora #SMURF_JUMP_HELD | SMURF_VERT_DIR_UP | SMURF_NO_HORIZ_DIR | SMURF_JUMPING | 1
.setSmurfAnimationToJumping
   sta smurfAttributes
   lda #ID_SMURF_JUMPING
   sta smurfAnimationIndex
   bne .checkSmurfTransitioningFromRoom;unconditional branch

.performStationaryJump
   lda #<[HorizontalStationaryJumpPositionChangeValues - JumpingPositionChangeValues + 1]
   sta jumpingPositionChangeIndex
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   ora #SMURF_JUMP_HELD | SMURF_VERT_DIR_UP | SMURF_NO_HORIZ_DIR | SMURF_JUMPING
   bne .setSmurfAnimationToJumping  ; unconditional branch

.performSuperJump
   lda #<[SuperJumpPositionChangeValues - JumpingPositionChangeValues]
   sta jumpingPositionChangeIndex
   lda smurfAttributes              ; get Smurf attribute values
   and #<~(SMURF_SUPER_JUMPING | 1)
   ora #SMURF_JUMP_HELD | SMURF_VERT_DIR_UP | SMURF_NO_HORIZ_DIR | SMURF_JUMPING | SMURF_SUPER_JUMPING
   bne .setSmurfAnimationToJumping  ; unconditional branch

.checkForJoystickRightCondition
   txa                              ; move joystick value to accumulator
   and #<~MOVE_RIGHT                ; isolate MOVE_RIGHT bit
   bne .checkForJoystickLeftCondition;branch if not MOVE_RIGHT
   lda smurfAttributes              ; get Smurf attribute values
   and #<~SMURF_HORIZ_DIR_MASK
.setSmurfAttributeToMovingHorizontally
   and #<~SMURF_NO_HORIZ_DIR        ; set to SMURF_HORIZ_DIR
   sta smurfAttributes
   lda smurfAnimationIndex
   cmp #ID_SMURF_DUCKING
   bcc .changeSmurfHorizontalPosition;branch if Smurf walking
   lda #ID_SMURF_STATIONARY
   sta smurfAnimationIndex
.changeSmurfHorizontalPosition
   lda frameCount                   ; get current frame count
   lsr
   bcs CheckSmurfTransitioningFromRoom;branch on odd frames
   inc smurfHorizPosition           ; move Smurf right
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   beq .checkRoomRulesForBoundaryCollisions;branch if SMURF_HORIZ_DIR_RIGHT
   dec smurfHorizPosition           ; move Smurf left
   dec smurfHorizPosition
.checkRoomRulesForBoundaryCollisions
   lda smurfHorizPosition           ; get Smurf horizontal position
   ldy currentRoomRuleIndex
   cmp CurrentRoomBoundaryRules + 1,y
   bcc .setGameStateToSmurfDamageCollision
   cmp CurrentRoomBoundaryRules + 2,y
   bcs .setGameStateToSmurfDamageCollision
   lda #0
   sta smurfSuperJumpTimer          ; reset Smurf super jump timer
   lda frameCount                   ; get current frame count
   and #3
   bne CheckSmurfTransitioningFromRoom
   inc smurfAnimationIndex          ; increment Smurf walking animation
   lda smurfAnimationIndex          ; get Smurf walking animation index
   cmp #ID_SMURF_DUCKING
   bne CheckSmurfTransitioningFromRoom;branch if not done with walking sequence
   ldx #<[SmurfFootstepsAudioValues_00 - SoundEffectsAudioValues]
   lda roomObstacleAttributes
   and #$40
   bne .setSmurfFootstepsAudioValue
   ldx #<[SmurfFootstepsAudioValues_01 - SoundEffectsAudioValues]
.setSmurfFootstepsAudioValue
   jsr SetSoundEffectAudioValues
   lda roomObstacleAttributes
   eor #$40
   sta roomObstacleAttributes
   lda #ID_SMURF_WALKING
   sta smurfAnimationIndex
   bne CheckSmurfTransitioningFromRoom;unconditional branch

.setGameStateToSmurfDamageCollision
   lda #GS_SMURF_DAMAGE_COLLISION
   sta gameState
   bne CheckSmurfTransitioningFromRoom;unconditional branch

.checkForJoystickLeftCondition
   txa                              ; move joystick value to accumulator
   and #<~MOVE_LEFT                 ; isolate MOVE_LEFT bit
   bne .setSmurfAttributeToStationary;branch if not MOVE_LEFT
   lda smurfAttributes              ; get Smurf attribute values
   ora #SMURF_HORIZ_DIR_LEFT
   bne .setSmurfAttributeToMovingHorizontally;unconditional branch

.setSmurfAttributeToStationary
   lda smurfAttributes              ; get Smurf attribute value
   ora #SMURF_NO_HORIZ_DIR
   sta smurfAttributes
.setSmurfToStationaryAnimation
   lda #ID_SMURF_STATIONARY
   sta smurfAnimationIndex
CheckSmurfTransitioningFromRoom SUBROUTINE
   lda smurfHorizPosition           ; get Smurf horizontal position
   cmp #XMAX_SMURF + 1
   bcc .checkSmurfTransitioningToWestRoom
   ldx #<-1
   stx stationaryObstacleMask       ; set to show stationary object
   inx                              ; x = 0
   sta obstacleSpawnTimer           ; set obstacle spawn timer
   lda #INIT_SCREEN_TRANSITION_TIME
   sta screenTransitionTimer
   lda roomObstacleAttributes       ; get room obstacle attribute values
   and #<~OBJ_HORIZ_DIR_MASK
   sta roomObstacleAttributes       ; set to OBJ_HORIZ_DIR_LEFT
   lda #XMIN_SMURF
   sta smurfHorizPosition
   lda currentRoomNumber            ; get current room number
   beq .smurfTransitioningToEastRoom; branch if ID_ROOM_MUSHROOM_HOUSE
   inc timesThruRoomTally           ; increment number of times room visited
   lda timesThruRoomTally           ; get number of times room visited
   cmp roomCycleCount               ; compare with times to visit room
   bcc .checkToSetNextEastRoomRuleIndex;branch if cycling through room
.smurfTransitioningToEastRoom
   ldx #0
   stx timesThruRoomTally           ; reset number of times room visited
   inc currentRoomNumber            ; increment current room number
   lda lastForwardLandVisited       ; get the last forward land visited by Smurf
   cmp currentRoomNumber            ; compare with current room number
   bcs .checkToSetNextEastRoomRuleIndex;branch if Smurf not traversed all lands
   inc lastForwardLandVisited
   stx scoringRoomIndex
   dex                              ; x = -1
   stx smurfEnergyBarGraphics       ; reset Smurf energy bar
   stx smurfEnergyBarGraphics + 1
.checkToSetNextEastRoomRuleIndex
   jsr SetCurrentRoomRuleIndexValue
   cmp nextEastRoomRuleIndex
   bcc .checkIfSmurfTraversedAllLands
   sta nextEastRoomRuleIndex
.checkIfSmurfTraversedAllLands
   lda currentRoomNumber            ; get current room number
   cmp lastForwardLandVisited
   bne .doneSmurfTransitioningToEastRoom;branch if Smurf not traversed all lands
   lda timesThruRoomTally           ; get number of times room visited
   cmp scoringRoomIndex
   bcc .doneSmurfTransitioningToEastRoom
   beq .doneSmurfTransitioningToEastRoom
   sta scoringRoomIndex
   lda currentRoomRuleIndex
   sta nextEastRoomRuleIndex
.doneSmurfTransitioningToEastRoom
   jmp .doneCheckSmurfTransitioningFromRoom

.checkSmurfTransitioningToWestRoom
   cmp #XMIN_SMURF - 1
   bcs .jmpToNewFrame
   lda #<-1
   sta stationaryObstacleMask       ; set to show stationary object
   lda #INIT_SCREEN_TRANSITION_TIME
   sta screenTransitionTimer
   lda #0
   sta obstacleSpawnTimer
   lda roomObstacleAttributes       ; get obstacle attribute values
   ora #OBJ_HORIZ_DIR_RIGHT
   sta roomObstacleAttributes       ; set obstacle to OBJ_HORIZ_DIR_RIGHT
   lda #XMAX_SMURF
   sta smurfHorizPosition           ; set Smurf to right edge
   dec timesThruRoomTally           ; decrement number of times room visited
   bpl .determineWestTravelingRoomRuleIndex
   lda roomCycleCount
   sec
   sbc #1
   sta timesThruRoomTally
   dec currentRoomNumber            ; decrement current room number
.determineWestTravelingRoomRuleIndex
   ldx currentRoomNumber            ; get current room number
   lda WestTravelingRoomRuleIndexValues,x
   sta currentRoomRuleIndex
.doneCheckSmurfTransitioningFromRoom
   lda #<~SMURF_JUMPING_MASK        ; remove SMURF_JUMPING value
   jsr RemoveSmurfAttributeValue
   ldx currentRoomRuleIndex
   lda CurrentRoomBoundaryRules,x
   sta smurfVertPosition
.jmpToNewFrame
   jmp NewFrame

SetSmurfDeathSoundsAndAnimation
   lda #0
   sta timesThruRoomTally           ; reset number of times room visited
   sta smurfEnergyBarGraphics
   sta smurfEnergyBarGraphics + 1
   ldy #ID_SMURF_SITTING
   lda currentRoomNumber            ; get current room number
   cmp #ID_ROOM_RIVER_00
   beq .checkForSmurfDrowning       ; branch if ID_ROOM_RIVER_00
   cmp #ID_ROOM_RIVER_01
   bne .checkForSmurfCapturedBySpider;branch if not ID_ROOM_RIVER_01
.checkForSmurfDrowning
   lda smurfHorizPosition           ; get Smurf horizontal position
   cmp #STREAM_BANK_HORIZ_POSITION_WEST
   bcc .setToPlaySmurfDeathSounds   ; branch if west of stream
   cmp #STREAM_BANK_HORIZ_POSITION_EAST
   bcs .setToPlaySmurfDeathSounds   ; branch if east of stream
   ldy #ID_SMURF_DROWNING
   ldx #<[SmurfDrowningAudioValues - SoundEffectsAudioValues]
   bne .setTimerToHaltUserActivity  ; unconditional branch

.checkForSmurfCapturedBySpider
   cmp #ID_ROOM_SPIDER_CAVERN
   bne .setToPlaySmurfDeathSounds   ; branch if not ID_ROOM_SPIDER_CAVERN
   lda smurfHorizPosition           ; get Smurf horizontal position
   cmp #INIT_HORIZ_CAVERN_SPIDER - 9
   bcc .setToPlaySmurfDeathSounds   ; branch if Smurf left of Spider
   cmp #INIT_HORIZ_CAVERN_SPIDER + 11
   bcs .setToPlaySmurfDeathSounds   ; branch if Smurf right of Spider
   ldx #<[SmurfCapturedBySpiderAudioValues - SoundEffectsAudioValues]
.setTimerToHaltUserActivity
   lda #60
   bne .setSmurfDeathAnimationIndex ; unconditional branch

.setToPlaySmurfDeathSounds
   lda #30
   ldx #<[SmurfDeathAudioValues - SoundEffectsAudioValues]
.setSmurfDeathAnimationIndex
   sty smurfAnimationIndex
   sta haltUserActivityTimer
   jsr SetSoundEffectAudioValues
.jmpToAdvanceCurrentGameState
   jmp .advanceCurrentGameState

AdvanceGameStateAfterTimerExpired
   lda frameCount                   ; get current frame count
   and #4
   bne .jmpToNewFrame
   dec haltUserActivityTimer
   bne .jmpToNewFrame
   beq .jmpToAdvanceCurrentGameState; unconditional branch

AdvanceLevelForRescuingSmurfette
   jsr SetCurrentRoomToMushroomHouse
   lda #<[SmurfetteSprites - SmurfetteSprites + H_SMURFETTE]
   sta smurfetteGraphicIndex
   sta screenTransitionTimer
   lda #0
   sta obstacleSpawnTimer
   inc currentPlayerSkillLevel      ; increment skill level
   ldy currentPlayerSkillLevel      ; get current skill level
   cpy #MAX_SKILL_LEVEL + 1
   bcc .setLevelRoomCycleCount      ; branch if not reached MAX_SKILL_LEVEL
   ldy #MAX_SKILL_LEVEL
   sty currentPlayerSkillLevel      ; set to MAX_SKILL_LEVEL
.setLevelRoomCycleCount
   iny                              ; increment skill level for room cycle count
   sty roomCycleCount
   inc currentRemainingLives        ; increment remaining lives
   bne .setInitRoomVariables        ; unconditional branch

CheckToAlternatePlayers
   lda reservedRemainingLives       ; get reserved remaining lives
   bne AlternatePlayerVariables     ; branch if reserved lives remaining
   lda currentRemainingLives        ; get current remaining lives
   bne .setInitRoomVariables        ; branch if lives remaining
   ldx #<[SmurfThemeSongAudioValues - BackgroundMusicAudioValues]
   jsr SetGameAudioValues
   lda #GS_GAME_OVER
   jmp .setCurrentGameState         ; set game state to GS_GAME_OVER

AlternatePlayerVariables
   ldx #5
.alternatePlayerVariables
   lda currentPlayerInformation,x
   ldy reservedPlayerInformation,x
   sta reservedPlayerInformation,x
   sty currentPlayerInformation,x
   dex
   bpl .alternatePlayerVariables
   lda currentGameSelection         ; get current game selection
   eor #ACTIVE_PLAYER_MASK          ; flip ACTIVE_PLAYER value
   sta currentGameSelection         ; set ACTIVE_PLAYER value
.setInitRoomVariables
   jsr SetCurrentRoomRuleIndexValue
   sta nextEastRoomRuleIndex
   lda #0
   sta scoringRoomIndex
   jsr SmurfEnteringRoomFromRight
   lda currentRemainingLives        ; get current remaining lives
   beq .advanceToNextGameState      ; branch if no remaining lives
   dec currentRemainingLives        ; decrement remaining lives
.advanceToNextGameState
   inc gameState
   jmp .doneCheckSmurfTransitioningFromRoom

RestorePlayerValuesFromPlayerUpDisplay
   jsr InitializeRoomObstaclePositions
   lda currentRoomNumber            ; get current room number
   sta lastForwardLandVisited
   ldy currentPlayerSkillLevel      ; get current skill level
   iny
   sty roomCycleCount
   ldx #2
.restorePlayerScoreFromPlayerUp
   lda tmpPlayerScore,x
   sta currentPlayerScore,x
   dex
   bpl .restorePlayerScoreFromPlayerUp
   bmi AdvanceGameStateToGameProcessing;unconditional branch

DisplayPlayerUpLiterals
   ldx #2
   ldy #BLANK_IDX_VALUE << 4 | BLANK_IDX_VALUE
.savePlayerScoreFromPlayerUp
   lda currentPlayerScore,x
   sta tmpPlayerScore,x
   sty currentPlayerScore,x
   dex
   bpl .savePlayerScoreFromPlayerUp
   ldy #ONE_IDX_VALUE << 4 | PLAYER_UP_LITERAL_IDX_VALUE
   ldx #<[PlayerOneUpAudioValues - SoundEffectsAudioValues]
   lda currentGameSelection         ; get current game selection
   bpl .setPlayerUpLiteral          ; branch if PLAYER_ONE_ACTIVE
   ldy #TWO_IDX_VALUE << 4 | PLAYER_UP_LITERAL_IDX_VALUE
   ldx #<[PlayerTwoUpAudioValues - SoundEffectsAudioValues]
.setPlayerUpLiteral
   sty currentPlayerScore + 1
   jsr SetSoundEffectAudioValues
   lda #30
   sta haltUserActivityTimer
.advanceCurrentGameState
   jmp AdvanceCurrentGameState

SmurfRescuedSmurfette
   ldx #<[SmurfetteRescuedAudioValues - BackgroundMusicAudioValues]
   jsr SetGameAudioValues
   lda #[SCORE_RESCUE_SMURFETTE / 100] - 1
   jsr IncrementScore               ; increment score for saving Smurfette
   lda #VERT_SMURF_RESCUED_SMURFETTE
   sta smurfVertPosition            ; set rescuing Smurfette vertical position
   lda #HORIZ_SMURF_RESCUED_SMURFETTE
   sta smurfHorizPosition           ; set rescuing Smurfette horizontal position
   lda #ID_SMURF_KISSING
   sta smurfAnimationIndex
   lda #<[RescuedSmurfetteSprite - SmurfetteSprites + H_SMURFETTE]
   sta smurfetteGraphicIndex
   bne .advanceCurrentGameState     ; unconditional branch

AdvanceGameStateToGameProcessing
   lda #GS_ADVANCE_TO_GAME_PROCESSING
.setCurrentGameState
   sta gameState
   jmp NewFrame

DisplayGameSelection
   lda currentGameSelection         ; get current game selection
   and #SELECTED_SKILL_MASK         ; keep SELECTED_SKILL value
   clc
   adc #SKILL_LITERAL_IDX_VALUE_02 << 4 | ONE_IDX_VALUE
   sta currentPlayerScore + 1
   lda #SKILL_LITERAL_IDX_VALUE_00 << 4 | SKILL_LITERAL_IDX_VALUE_01
   sta currentPlayerScore
   lda #BLANK_IDX_VALUE << 4 | BLANK_IDX_VALUE
   sta currentPlayerScore + 2
   ldx #1                           ; assume ONE_PLAYER game
   lda currentGameSelection         ; get current game selection
   and #NUM_PLAYERS_GAME_MASK       ; keep NUM_PLAYERS value
   beq .setNumberOfPlayersIndicator ; branch if ONE_PLAYER_GAME_SELECTION
   ldx #2                           ; set for TWO_PLAYER game
.setNumberOfPlayersIndicator
   stx currentRemainingLives
   lda SWCHB                        ; read console switches
   and #SELECT_MASK                 ; keep SELECT value
   bne .resetSelectDebounceTimer    ; branch if SELECT not pressed
   lda selectDebounceTimer          ; get select debounce timer
   beq .incrementGameSelection
   dec selectDebounceTimer
   bpl .doneDisplayGameSelection
.incrementGameSelection
   ldx #<[GameSelectionAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; set to play game selection sound effect
   lda #25
   sta selectDebounceTimer
   lda currentGameSelection         ; get current game selection
   and #NUM_PLAYERS_GAME_MASK | SELECTED_SKILL_MASK
   cmp #MAX_GAME_SELECTION
   beq .wrapGameSelectionValue      ; wrap game selection if reached max
   inc currentGameSelection         ; increment game selection
   bne .doneDisplayGameSelection    ; unconditional branch

.wrapGameSelectionValue
   lda currentGameSelection         ; get current game selection
   and #<~MAX_GAME_SELECTION        ; clear current game selection values
   sta currentGameSelection         ; wrap game selection value to 0
.doneDisplayGameSelection
   jmp NewFrame

.resetSelectDebounceTimer
   lda #0
   sta selectDebounceTimer
   lda INPT4
   bmi .doneDisplayGameSelection    ; branch if left action button not pressed
   bpl AdvanceCurrentGameState

InitializeGame
   lda currentGameSelection         ; get current game selection
   and #SELECTED_SKILL_MASK         ; keep SELECTED_SKILL value
   sta currentPlayerSkillLevel
   sta reservedPlayerSkillLevel
   tay                              ; move SELECTED_SKILL value to y register
   lda #<[SmurfetteSprites - SmurfetteSprites + H_SMURFETTE]
   sta smurfetteGraphicIndex
   iny                              ; increment SELECTED_SKILL value
   sty roomCycleCount               ; set room cycle count value
   lda #MUSHROOM_HOUSE_RULE_IDX
   sta currentRoomRuleIndex
   sta nextEastRoomRuleIndex
   jsr SetCurrentRoomToMushroomHouse
   jsr SmurfEnteringRoomFromRight
   ldy #0
   sty timesThruRoomTally           ; reset number of times room visited
   sty scoringRoomIndex
   sty reservedPlayerRoomNumber
   ldx #2
.initPlayerScoreValues
   sty currentPlayerScore,x
   sty reservedPlayerScore,x
   dex
   bpl .initPlayerScoreValues
   ldx #INIT_REMAINING_LIVES
   stx currentRemainingLives
   lda currentGameSelection         ; get current game selection
   and #NUM_PLAYERS_GAME_MASK | SELECTED_SKILL_MASK
   sta currentGameSelection
   inx
   and #NUM_PLAYERS_GAME_MASK       ; keep NUM_PLAYERS_GAME value
   bne .initReservedRemainingLives  ; branch if TWO_PLAYER_GAME_SELECTION
   ldx #0
.initReservedRemainingLives
   stx reservedRemainingLives
   jmp DisplayPlayerUpLiterals

PlaySmurfRescuedSmurfetteTune
   lda currentlyPlayingAudio
   bne NewFrame                     ; branch if currently playing audio
   beq AdvanceCurrentGameState      ; unconditional branch

;
; The following bytes are never executed. It looks to have been a way for the
; player to bypass listenting to the entire tune for rescuing Smurfette.
; 
   .byte $A6,$3C,$A5,$B5,$10,$02,$A6,$3D,$8A,$30,$1C,$10,$18

GameOverState
   lda currentGameSelection         ; get current game selection
   and #NUM_PLAYERS_GAME_MASK       ; keep NUM_PLAYERS_GAME value
   beq .checkToStartNewGame         ; branch if ONE_PLAYER_GAME_SELECTION
   lda frameCount                   ; get current frame count
   cmp #128
   bne .checkToStartNewGame
   dec gameState                    ; set to GS_ALTERNATE_PLAYER_VARIABLES
.checkToStartNewGame
   lda INPT4                        ; read left action button value
   bmi NewFrame                     ; branch if action button not pressed
   lda #GS_INITIALIZE_GAME
   sta gameState                    ; set game state to GS_INITIALIZE_GAME
   bne NewFrame                     ; unconditional branch

AdvanceCurrentGameState
   inc gameState
NewFrame
.waitTime
   lda INTIM
   bne .waitTime
   lda #DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC                        ; start vertical sync (i.e. D1 = 1)
   lda #VSYNC_TIME
   sta TIM8T                        ; set timer for vertical sync period
   ldx random + 1
   ldy random
   rol random
   rol random + 1
   lda random
   adc #195
   sty random
   eor random
   sta random
   txa
   eor random + 1
   sta random + 1
.vsyncWaitTime
   lda INTIM
   bne .vsyncWaitTime
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (i.e. D1 = 0)
   sta WSYNC
   sta VBLANK                       ; enable TIA (i.e. D1 = 0)
   sta COLUBK                       ; set background color to BLACK
   jmp VerticalBlank

SetCurrentRoomRuleIndexValue
   ldx currentRoomNumber            ; get current room number
   lda EastTravelingRoomRuleIndexValues,x
   sta currentRoomRuleIndex
   rts

SetCurrentRoomToMushroomHouse
   lda #ID_ROOM_MUSHROOM_HOUSE
   sta currentRoomNumber
   sta lastForwardLandVisited
   rts

SmurfEnteringRoomFromRight
   lda #<~SMURF_HORIZ_DIR_MASK
   jsr RemoveSmurfAttributeValue    ; set to SMURF_HORIZ_DIR_RIGHT
InitSmurfStartingLocationValues
   lda #XMIN_SMURF
   ldx currentRoomNumber            ; get current room number
   bne .setSmurfStartingHorizPosition;branch if not ID_ROOM_MUSHROOM_HOUSE
   lda #XMIN_SMURF_MUSHROOM_HOUSE
.setSmurfStartingHorizPosition
   sta smurfHorizPosition
   ldx currentRoomRuleIndex
   lda CurrentRoomBoundaryRules,x
   sta smurfVertPosition
   ldx #$FF
   stx smurfEnergyBarGraphics
   stx smurfEnergyBarGraphics + 1
   lda #ID_SMURF_STATIONARY
   sta smurfAnimationIndex
   rts

FlyingObstacleVertOffsetMaskValues
   .byte 15                   ; Field Hawk vertical offset mask value (0 - 15)
   .byte 0                    ; unused
   .byte 31                   ; Mountain Hawk vertical offset mask value (0 - 31)
   .byte 0, 0                 ; unused
   .byte 7                    ; Bat vertical offset mask value (0 - 7)

FlyingObstacleVertOffsetValues
   .byte VERT_MIN_HAWK_FIELD + 24;Field Hawk vertical offset
   .byte 0                    ; unused
   .byte VERT_MIN_HAWK_MOUNTAINS + 30;Mountains Hawk vertical offset
   .byte 0, 0                 ; unused
   .byte VERT_MIN_BAT + 40    ; Bat vertical offset

InitializeRoomObstaclePositions
   ldx #0
   stx changeSnakeHorizDirTimer
   dex                              ; x = -1
   stx flyingObjectVertChangeIndex
   stx flyingObjectVertChangeTimer
   lda stationaryObstacleMask
   bmi .doneInitializeRoomObstaclePositions;branch if showing stationary object
   ldx currentRoomNumber            ; get current room number
   lda RoomObstacleInitialHorizontalPosition,x
   sta roomObjectHorizPosition      ; set obstacle initial horizontal position
   lda RoomObstacleInitialVerticalPosition,x
   sta roomObstacleVertPosition     ; set obstacle initial vertical position
   cpx #ID_ROOM_WOODS
   beq .initFlyingObstaclePositions ; init Hawk positions
   cpx #ID_ROOM_MOUNTAINS
   beq .initFlyingObstaclePositions ; init Hawk positions
   cpx #ID_ROOM_GARGAMELS_LAB
   beq .initFlyingObstaclePositions ; init Bat positions
   cpx #ID_ROOM_RIVER_00
   beq .initSnakeHorizPosition
   cpx #ID_ROOM_RIVER_01
   bne .doneInitializeRoomObstaclePositions
.initSnakeHorizPosition
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   beq .doneInitializeRoomObstaclePositions;branch if OBJ_HORIZ_DIR_LEFT
   lda #1
   sta roomObjectHorizPosition
   bne .doneInitializeRoomObstaclePositions

.initFlyingObstaclePositions
   lda FlyingObstacleVertOffsetMaskValues - 1,x
   and random                       ; mask with random LSB valye
   adc FlyingObstacleVertOffsetValues - 1,x;increment by vertical offset
   sta roomObstacleVertPosition
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   beq .doneInitializeRoomObstaclePositions;branch if OBJ_HORIZ_DIR_LEFT
   lda #INIT_HORIZ_FLYING_OBJECT
   sta roomObjectHorizPosition
.doneInitializeRoomObstaclePositions
   rts

ReadJoystickValues
   lda SWCHA                        ; read joystick values
   ldx currentGameSelection         ; get current game selection
   bpl .doneReadJoystickValues      ; branch if PLAYER_ONE_ACTIVE
   asl                              ; shift player 2 joystck values
   asl
   asl
   asl
.doneReadJoystickValues
   rts

SetGameAudioValues
   ldy #0
.setGameAudioValues
   lda #0
   sta audioDurationValues,y        ; clear audio duration value
   lda BackgroundMusicAudioValues,x ; get background musing audio value
   sta audioToneValues,y
   sta currentlyPlayingAudio,y      ; set to show currently playing audio
   and #SOUND_CHANNEL_MASK          ; keep SOUND_CHANNEL value
   bne .setMusicNextAudioChannelValue;branch if SOUND_TWO_CHANNELS
   stx audioIndexValues,y
   rts

.setMusicNextAudioChannelValue
   inx                              ; increment audio index value
   lda BackgroundMusicAudioValues,x ; get background musing audio value
   stx audioIndexValues,y
   tax                              ; move audio value to x register
   ldy #1
   bne .setGameAudioValues          ; unconditional branch

SetSoundEffectAudioValues
   lda SoundEffectsAudioValues,x
   bmi .setSoundEffectAudioValues   ; branch if higher priority
   ldy soundEffectsAudioIndex
   lda SoundEffectsAudioValues + 1,y
   bne .doneSetSoundEffectAudioValues;branch if sound effect still active
.setSoundEffectAudioValues
   lda SoundEffectsAudioValues,x
   sta AUDC1
   sta soundEffectsAudioToneValue
   stx soundEffectsAudioIndex
   lda #0
   sta soundEffectsAudioDurationValue
.doneSetSoundEffectAudioValues
   rts

IncrementScore
   sed
   sec
   adc currentPlayerScore + 1       ; increment score hundreds value
   sta currentPlayerScore + 1
   bcc .doneIncrementScore
   lda currentPlayerScore           ; get score thousands value
   bne .incrementThousandsValue
   lda currentRemainingLives        ; get current remaining lives
   cmp #MAX_REMAINING_LIVES
   beq .incrementThousandsValue     ; branch if reached maximum remaining lives
   inc currentRemainingLives        ; increment remaining lives
   ldx #<[ExtraLifeAudioValues - BackgroundMusicAudioValues]
   jsr SetGameAudioValues
.incrementThousandsValue
   lda currentPlayerScore           ; get score thousands value
   clc
   adc #1
   sta currentPlayerScore
.doneIncrementScore
   cld
   rts

RemoveSmurfAttributeValue
   and smurfAttributes
   sta smurfAttributes
   rts

SetRiverAnimationHeight
   sta riverSectionHeightValues,x
DecrementRiverAnimationIndex
   dex
   bpl .doneSetRiverAnimationHeight
   ldx #<[riverHeightSection_00 - riverSectionHeightValues]
.doneSetRiverAnimationHeight
   rts

PositionGRP0Horizontally_BANK0
   ldy #<[RESP0 - RESP0]      ; 2
PositionObjectHorizontally_BANK0
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
   sta RESP0,y                ; 5         set coarse position value
   sta WSYNC
;--------------------------------------
   sta HMP0,y                 ; 5 = @05
   iny                        ; 2
   rts                        ; 6

HorizPositionSmurfAndObstacle_BANK0
   lda smurfHorizPosition     ; 3 = @56   get Smurf horizontal position
   jsr PositionGRP0Horizontally_BANK0;6
;--------------------------------------
   lda smurfAttributes        ; 3         get Smurf attribute values
   sta REFP0                  ; 3 = @19
   lda #MSBL_SIZE1 | ONE_COPY ; 2
   sta NUSIZ0                 ; 3 = @24
   sta NUSIZ1                 ; 3 = @27
   lda roomObjectHorizPosition; 3
   jsr PositionObjectHorizontally_BANK0;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda roomObstacleAttributes ; 3
   sta REFP1                  ; 3 = @09
   ldx smurfAnimationIndex    ; 3
   inx                        ; 2
   txa                        ; 2
   asl                        ; 2
   asl                        ; 2
   tay                        ; 2
   dey                        ; 2
   ldx #3                     ; 2
.setSmurfAnimationDataPointerValues
   lda SmurfAnimationDataPointers_BANK0,y;4
   sta smurfGraphicPointer,x  ; 4
   dey                        ; 2
   dex                        ; 2
   bpl .setSmurfAnimationDataPointerValues;2³
   sta WSYNC
;--------------------------------------
   sta CXCLR                  ; 3 = @03
   ldx currentRoomNumber      ; 3         get current room number
   lda smurfVertPosition      ; 3         get Smurf vertical position
   clc                        ; 2
   adc KernelHeightOffset_BANK0,x;4       increment by kernel height
   sec                        ; 2
   ldy smurfAnimationIndex    ; 3
   sbc SmurfSpriteOffset_BANK0,y;4        subtract sprite height for offset
   bmi .setSmurfSkipDrawIdx   ; 2³
   cmp #H_SMURF - 5           ; 2
   bcc .setSmurfSkipDrawIdx   ; 2³
   lda #H_SMURF - 5           ; 2
.setSmurfSkipDrawIdx
    tay                       ; 2
    rts                       ; 6

SmurfAnimationDataPointers_BANK0
   .word NullSprite
   .word NullSpriteColor
   
   .word SmurfSpriteStationary
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_00
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_01
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_02
   .word SmurfSpriteColors
   
   .word SmurfSpriteStationary
   .word SmurfSpriteColors
   
   .word SmurfSpriteDucking
   .word SmurfSpriteDuckingColors
   
   .word SmurfSpriteSitting
   .word SmurfSpriteColors
   
   .word SmurfSpriteJumping
   .word SmurfSpriteColors
   
KernelHeightOffset_BANK0
   .byte 72                         ; ID_ROOM_MUSHROOM_HOUSE
   .byte 73                         ; ID_ROOM_WOODS

SmurfSpriteOffset_BANK0
   .byte H_SMURF - H_SMURF
   .byte H_SMURF - H_SMURF_STATIONARY
   .byte H_SMURF - H_SMURF_WALKING_00
   .byte H_SMURF - H_SMURF_WALKING_01
   .byte H_SMURF - H_SMURF_WALKING_02
   .byte H_SMURF - H_SMURF_STATIONARY
   .byte H_SMURF - H_SMURF_DUCKING
   .byte H_SMURF - H_SMURF_SITTING
   .byte H_SMURF - H_SMURF_JUMPING

VerticalBlank
   sta WSYNC                        ; wait for next scan line
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
.checkForJoystickMovement
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip joystick values
   beq .checkToDisableDisplay       ; branch if neither joystick moved
   lda #0
   sta gameIdleTimer                ; reset game idle timer
.checkToDisableDisplay
   lda gameIdleTimer                ; get game idle timer value
   bmi .checkForJoystickMovement    ; blank screen if timer expired
   inc frameCount
   bne .checkResetButtonPressed
   inc gameIdleTimer
.checkResetButtonPressed
   lda SWCHB                        ; read console switches
   and #RESET_MASK                  ; keep RESET value
   bne DetermineToPlayAudioSounds   ; branch if RESET not pressed
   sta gameState
   lda currentGameSelection         ; get current game selection
   and #<~ACTIVE_PLAYER_MASK        ; clear ACTIVE_PLAYER value
   sta currentGameSelection         ; show PLAYER_ONE active
DetermineToPlayAudioSounds
   ldx #2
   lda #<SoundEffectsAudioValues
   sta audioFrequencyPointer
   lda #>SoundEffectsAudioValues
   sta audioFrequencyPointer + 1
.determineToPlayAudioSounds
   lda audioDurationValues,x        ; get audio duration value
   beq .checkToPlayNextAudioFrequency;branch if done
   dec audioDurationValues,x        ; decrement audio duration value
   
   IF COMPILE_REGION = PAL50
   
      and #1
      
   ELSE

      and #3
      cmp #3

   ENDIF
   
   bne .setToPlayBackgroundMusic
   ldy audioVolumeValues,x          ; get audio volume value
   dey
   bmi .setToPlayBackgroundMusic
   sty audioVolumeValues,x
.setToPlayBackgroundMusic
   lda #<BackgroundMusicAudioValues
   sta audioFrequencyPointer
   lda #>BackgroundMusicAudioValues
   sta audioFrequencyPointer + 1
   dex
   bpl .determineToPlayAudioSounds
   ldy soundEffectsAudioIndex
   lda soundEffectsAudioToneValue
   beq PlayGameAudioSounds          ; branch if sound effects done
   lda SoundEffectsAudioValues,y
   sta AUDF1
   lda soundEffectsAudioVolume
   sta AUDV1
   inx
   beq .playGameAudioSounds         ; unconditional branch

PlayGameAudioSounds
   ldx #1
.playGameAudioSounds
   ldy audioIndexValues,x
   lda (audioFrequencyPointer),y
   sta AUDF0,x
   lda audioVolumeValues,x
   sta AUDV0,x
   lda audioToneValues,x
   ldy currentRoomNumber            ; get current room number
   cpy #ID_ROOM_SPIDER_CAVERN
   bne .setAudioToneForBackgroundMusic;branch if not ID_ROOM_SPIDER_CAVERN
   ldy currentRemainingLives        ; get current remaining lives
   bne .setSpiderRoomAudioToneValue ; branch if lives remaining
   ldy gameState                    ; get current game state
   cpy #GS_GAME_OVER
   beq .setAudioToneForBackgroundMusic
   cpy #GS_ALTERNATE_PLAYER_VARIABLES
   beq .setAudioToneForBackgroundMusic
.setSpiderRoomAudioToneValue
   lda #1                           ; saw waveform
.setAudioToneForBackgroundMusic
   sta AUDC0,x
   dex
   bpl .playGameAudioSounds
   bmi MoveClouds

.checkToPlayNextAudioFrequency
   ldy audioIndexValues,x
   iny
   lda #MAX_VOLUME
   sta audioVolumeValues,x
   lda (audioFrequencyPointer),y    ; get audio frequency and duration value
   bne .playNextAudioFrequency
   sta audioVolumeValues,x
   sta currentlyPlayingAudio,x      ; set to show no longer playing audio
   beq .setToPlayBackgroundMusic    ; unconditional branch

.playNextAudioFrequency
   cmp #AUDIO_WAIT
   bcc .determineAudioDurationValue ; branch if not doing AUDIO_WAIT
   lda #0
   sta audioVolumeValues,x          ; set volume to NO_SOUND
   lda (audioFrequencyPointer),y
   asl
   asl
   and #$3F
   bne .setAudioIndexAndDurationValues   
.determineAudioDurationValue
   and #AUDIO_DURATION_MASK
   bmi .shiftAudioDurationValue
   lsr
.shiftAudioDurationValue
   lsr
   lsr
   lsr
.setAudioIndexAndDurationValues
   sty audioIndexValues,x
   
   IF COMPILE_REGION = PAL50

      cpx #2
      bcs .setAudioDurationValue    ; branch if playing sound effects
      cmp #8
      bcc .setAudioDurationValue    ; branch if duration is less than 8
      sec                           ; not needed...carry already set
      sbc #7                        ; 1 <= a <= 21
.setAudioDurationValue
      sta audioDurationValues,x
      jmp .setToPlayBackgroundMusic
      
   ELSE

      sta audioDurationValues,x
      bpl .setToPlayBackgroundMusic    ; set to play background music

   ENDIF

MoveClouds
   lda currentRoomNumber            ; get current room number
   cmp #ID_ROOM_RIVER_00
   beq .moveClouds                  ; branch if ID_ROOM_RIVER_00
   cmp #ID_ROOM_RIVER_01
   bne .doneMoveClouds              ; branch if not ID_ROOM_RIVER_01
.moveClouds
   lda frameCount                   ; get current frame count
   and #7
   bne .doneMoveClouds
   ldx cloudHorizontalPosition      ; get clouds horizontal position
   bne .moveCloudsLeft
   ldx #XMAX + 1                    ; wrap clouds to right
.moveCloudsLeft
   dex
   stx cloudHorizontalPosition
.doneMoveClouds
   lda #H_RIVER_ANIMATION
   ldx #5
.resetRiverAnimationHeight
   sta riverSectionHeightValues,x
   dex
   bpl .resetRiverAnimationHeight
   ldx riverAnimationIdx
   lda frameCount                   ; get current frame count
   and #7
   bne .animateRiver
   jsr DecrementRiverAnimationIndex
   stx riverAnimationIdx
.animateRiver
   lda #H_RIVER_ANIMATION - 1
   jsr SetRiverAnimationHeight
   lda #H_RIVER_ANIMATION - 2
   jsr SetRiverAnimationHeight
   lda #H_RIVER_ANIMATION - 2
   jsr SetRiverAnimationHeight
   lda #H_RIVER_ANIMATION - 1
   sta riverSectionHeightValues,x
   jsr ReadJoystickValues
   and #<~MOVE_UP
   beq .decrementSuperJumpTimer
   lda #<~SMURF_JUMP_DEBOUNCE_MASK
   jsr RemoveSmurfAttributeValue    ; clear the SMURF_JUMP_DEBOUNCE value
.decrementSuperJumpTimer
   dec smurfSuperJumpTimer
   bpl CheckSmurfJumpingAction
   lda #0
   sta smurfSuperJumpTimer          ; reset Smurf super jump timer
CheckSmurfJumpingAction
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_JUMPING_MASK          ; keep SMURF_JUMPING value
   bne .changeJumpingSmurfVerticalPosition;branch if Smurf jumping
   jmp .doneCheckSmurfJumpingAction

.changeJumpingSmurfVerticalPosition
   lda smurfVertPosition            ; get Smurf vertical position
   sta tmpSmurfVertPosition
   ldy jumpingPositionChangeIndex
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_VERT_DIR_MASK         ; keep SMURF_VERT_DIR value
   beq .descendingSmurfJump         ; branch if SMURF_VERT_DIR_DOWN
   ldx JumpingPositionChangeValues,y
   bne .ascendingSmurfJump
   lda #<~SMURF_VERT_DIR_MASK
   jsr RemoveSmurfAttributeValue    ; set to SMURF_VERT_DIR_DOWN
   dec jumpingPositionChangeIndex
   dey
   bne .descendingSmurfJump
.ascendingSmurfJump
   txa                              ; set accumulator to horizontal change value
   and #$0F                         ; keep jump action vertical change value
   clc
   adc smurfVertPosition            ; increment Smurf vertical position
   inc jumpingPositionChangeIndex
   jmp .setSmurfJumpingVericalPosition

.descendingSmurfJump
   lda JumpingPositionChangeValues,y
   bne .determineDescendingJumpVerticalChange
   lda smurfVertPosition            ; get Smurf vertical position
   sec
   sbc #SMURF_DESCENDING_CHANGE
   sta smurfVertPosition
   inc smurfHorizPosition
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   beq .doneDescendingJumpHorizontalChange;branch if SMURF_HORIZ_DIR_RIGHT
   dec smurfHorizPosition
   dec smurfHorizPosition
.doneDescendingJumpHorizontalChange
   jmp .doneSmurfJumpingAction

.determineDescendingJumpVerticalChange
   and #$0F                         ; keep jump action vertical change value
   tax
   lda smurfVertPosition            ; get Smurf vertical position
   stx tmpVerticalJumpChange        ; set vertical change for jump action
   sec
   sbc tmpVerticalJumpChange        ; subtract from vertical change value
   dec jumpingPositionChangeIndex
.setSmurfJumpingVericalPosition
   sta smurfVertPosition
   lda JumpingPositionChangeValues,y; get jumping position change value
   lsr                              ; shift horizontal change value
   lsr
   lsr
   lsr
   tax                              ; set x register to horizontal change value
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   bne .smurfJumpingLeft            ; branch if SMURF_HORIZ_DIR_LEFT
   lda smurfHorizPosition           ; get Smurf horizontal position
   stx tmpHorizontalJumpChange      ; set horizontal change for jump action
   clc
   adc tmpHorizontalJumpChange      ; increment by horizontal jump action change
   sta smurfHorizPosition           ; set Smurf new horizontal position
   bcc .doneSmurfJumpingAction      ; unconditional branch

.smurfJumpingLeft
   lda smurfHorizPosition           ; get Smurf horizontal position
   stx tmpHorizontalJumpChange      ; set horizontal change for jump action
   sec
   sbc tmpHorizontalJumpChange      ; decrement by horizontal jump action change
   sta smurfHorizPosition           ; set Smurf new horizontal position
.doneSmurfJumpingAction
   lda smurfVertPosition            ; get Smurf vertical position
   bpl .jmpToDoneCheckSmurfJumpingAction;branch if Smurf outside vertical frame
   ldy #3
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_HORIZ_DIR_MASK        ; keep SMURF_HORIZ_DIR value
   beq .determineRoomBoundaryRulesIndex;branch if SMURF_HORIZ_DIR_RIGHT
   ldy #<-3
.determineRoomBoundaryRulesIndex
   tya                              ; move rule index adjustment to accumulator
   clc
   adc currentRoomRuleIndex         ; increment current room rule index value
   tay
   lda CurrentRoomBoundaryRules,y   ; get vertical position value
   bne .checkToIncrementScoreForJump; branch if new rule to be enforced
.checkCurrentRoomBoundaryRules
   ldy currentRoomRuleIndex         ; restore rule index value
   lda CurrentRoomBoundaryRules,y   ; get current room vertical position value
.checkToIncrementScoreForJump
   cmp tmpSmurfVertPosition         ; compare with Smurf previous position
   bcs .setSmurfFromNonSafeLanding
   cmp smurfVertPosition            ; compare with Smurf new position
   bcc .determineToCheckCurrentRoomBoundaryRules
   lda CurrentRoomBoundaryRules + 1,y
   cmp smurfHorizPosition
   bcs .determineToCheckCurrentRoomBoundaryRules;branch if Smurf to the left of boundary
   lda CurrentRoomBoundaryRules + 2,y
   cmp smurfHorizPosition
   bcc .determineToCheckCurrentRoomBoundaryRules;branch if Smurf to the right of boundary
   cpy nextEastRoomRuleIndex
   bcc .setSmurfSafeLandingVertPosition
   beq .setSmurfSafeLandingVertPosition
   lda currentRoomNumber            ; get current room number
   cmp lastForwardLandVisited
   bne .setSmurfSafeLandingVertPosition;branch if Smurf not traversed all lands
   lda timesThruRoomTally           ; get number times room visited
   cmp scoringRoomIndex
   bne .setSmurfSafeLandingVertPosition
   sty nextEastRoomRuleIndex
   ldx #[SCORE_STANDARD_JUMP / 100] - 1
   lda smurfAttributes              ; get Smurf attribute values
   and #SMURF_SUPER_JUMP_MASK       ; keep SMURF_SUPER_JUMP value
   beq .incrementScoreForSafeJumpLanding;branch if not doing a super jump
   ldx #[SCORE_SUPER_JUMP / 100] - 1
.incrementScoreForSafeJumpLanding
   txa                              ; move point value to accumulator
   sty tmpCurrentRoomRuleIndex
   jsr IncrementScore
   ldy tmpCurrentRoomRuleIndex
.setSmurfSafeLandingVertPosition
   lda CurrentRoomBoundaryRules,y
   sta smurfVertPosition
   sty currentRoomRuleIndex
   lda #30
   sta smurfSuperJumpTimer          ; reset Super Jump timer
   bne .removeSmurfJumpingAction    ; unconditional branch

.setSmurfFromNonSafeLanding
   cpy currentRoomRuleIndex
   bne .checkCurrentRoomBoundaryRules
   lda smurfVertPosition            ; get Smurf vertical position
   bpl .doneCheckSmurfJumpingAction ; branch if Smurf outside vertical frame
   cmp #VERT_MIN_SMURF
   bcs .doneCheckSmurfJumpingAction ; branch if Smurf landed from jump
   lda #VERT_MIN_SMURF
   sta smurfVertPosition
   lda #0
   sta smurfEnergyBarGraphics
   sta smurfEnergyBarGraphics + 1
.removeSmurfJumpingAction
   lda #<~SMURF_JUMPING_MASK
   jsr RemoveSmurfAttributeValue    ; remove SMURF_JUMPING value
.jmpToDoneCheckSmurfJumpingAction
   jmp .doneCheckSmurfJumpingAction

.determineToCheckCurrentRoomBoundaryRules
   cpy currentRoomRuleIndex
   bne .checkCurrentRoomBoundaryRules
.doneCheckSmurfJumpingAction
   ldx currentRoomNumber            ; get current room number
   bne CheckToShowStationaryObject  ; branch if not ID_ROOM_MUSHROOM_HOUSE
   stx roomObjectHorizPosition
   lda roomObstacleAttributes
   and #<~OBJ_HORIZ_DIR_MASK
   sta roomObstacleAttributes
   jmp SetupForSixDigitDisplay

CheckToShowStationaryObject
   cpx #ID_ROOM_SPIDER_CAVERN
   beq MoveObstacle                 ; branch if in ID_ROOM_SPIDER_CAVERN
   lda gameState                    ; get current game state
   cmp #GS_GAME_IN_PROGRESS
   bne .showStationaryObject        ; branch if not GS_GAME_IN_PROGRESS
   lda currentPlayerSkillLevel      ; get current skill level
   beq .showStationaryObject
   lda smurfHorizPosition           ; get Smurf horizontal position
   cpx #ID_ROOM_WOODS
   bne .determineToShowBat
   cmp StationaryObjectEnablingPoint,x
   bcc .showStationaryObject        ; branch to show FENCE
   bcs MoveObstacle                 ; unconditional branch

.determineToShowBat
   cmp StationaryObjectEnablingPoint,x
   bcc MoveObstacle                 ; branch to not show BAT
.showStationaryObject
   lda #<-1
   sta stationaryObstacleMask       ; set to show stationary object
   lda #HORIZ_FENCE
   cpx #ID_ROOM_WOODS
   beq .setStationaryObstacleHorizontalPosition
   lda #HORIZ_SMURFETTE
.setStationaryObstacleHorizontalPosition
   sta roomObjectHorizPosition
.determineStationaryObstacleGraphicPtrs
   lda #<FenceGraphic
   ldy #>FenceGraphic
   cpx #ID_ROOM_WOODS
   beq .setStationaryObstacleGraphicPtrs;branch if ID_ROOM_WOODS
   lda #<SpiderCavernBottomLeftPF0Graphics
   ldy #>SpiderCavernBottomLeftPF0Graphics
.setStationaryObstacleGraphicPtrs
   sta roomObstacleGraphicPointer
   sty roomObstacleGraphicPointer + 1
   lda roomObstacleAttributes
   and #<~OBJ_HORIZ_DIR_MASK
   sta roomObstacleAttributes
   lda #0
   cpx #ID_ROOM_RIVER_00
   beq .setRoomObstacleGraphicIndex ; branch if ID_ROOM_RIVER_00
   cpx #ID_ROOM_RIVER_01
   beq .setRoomObstacleGraphicIndex ; branch if ID_ROOM_RIVER_01
   lda #256 - 57
.setRoomObstacleGraphicIndex
   sta roomObstacleGraphicIndex
   jmp SetupForSixDigitDisplay

MoveObstacle
   lda stationaryObstacleMask
   beq .moveObstacle                ; branch if not showing stationary object
   inc stationaryObstacleMask       ; increment to not show stationary object
   jsr InitializeRoomObstaclePositions
.moveObstacle
   lda currentRoomNumber            ; get current room number
   asl                              ; multiply value by 2
   tay
   lda ObstacleMovementRoutines - 1,y;get obstacle movement routine MSB value
   pha                              ; push value to stack
   lda ObstacleMovementRoutines - 2,y;get obstacle movement routine LSB value
   pha                              ; push value to stack
   rts                              ; call obstacle movement routine

ObstacleMovementRoutines
   .word MoveFlyingObject - 1
   .word MoveSnake - 1
   .word MoveFlyingObject - 1
   .word MoveSpider - 1
   .word MoveSnake - 1
   .word MoveFlyingObject - 1

FlyingObjectVerticalChangeValues
   .byte 0, -2, -1 ,0, 1, 2, 2

FlyingObjectVertChangeMaskValues
   .byte 15, 15, 15                 ; 0 - 15
   .byte 0                          ; 0
   .byte 7, 7                       ; 0 - 7
   .byte 0                          ; 0
FlyingObjectVertChangeTimerAdjustmentValues
   .byte 10, 10, 15, 5, 5, 5, 200

FlyingObjectVerticalMinValues
   .byte 0                          ; ID_ROOM_MUSHROOM_HOUSE...unused
   .byte VERT_MIN_HAWK_FIELD        ; ID_ROOM_WOODS
   .byte 0                          ; ID_ROOM_RIVER_00...unused
   .byte VERT_MIN_HAWK_MOUNTAINS    ; ID_ROOM_MOUNTAINS
   .byte 0                          ; ID_ROOM_SPIDER_CAVERN...unused
   .byte 0                          ; ID_ROOM_RIVER_01...unused
;   .byte VERT_MIN_BAT
;
; last byte shared with table below
;
ObstacleHorizontalChangeMaskValues
   .byte %11010000
   .byte %11111111
   .byte %00001111
   .byte %00000111

RoomObstacleMovementDelayValues
   .byte 7, 3, 1, 0

MoveFlyingObject
   lda roomObjectHorizPosition      ; get flying object horizontal position
   cmp #XMIN + 5
   bcs .flyingObjectActive          ; branch if not reached left border
   ldx #0
   jmp CheckToSpawnNewObstacle

.flyingObjectActive
   lda #0
   sta obstacleSpawnTimer
   lda frameCount                   ; get current frame count
   and #$0F
   bne .moveFlyingObject
   ldx #<[FlyingObjectFlappingAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; play flying object flapping sounds
.moveFlyingObject
   ldx currentPlayerSkillLevel      ; get current skill level
   lda frameCount                   ; get current frame count
   and RoomObstacleMovementDelayValues,x
   bne .doneMoveFlyingObject
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   bne .moveFlyingObjectRight       ; branch if OBJ_HORIZ_DIR_RIGHT
   dec roomObjectHorizPosition
   bne .checkToChangeVerticalChangeIndex;unconditional branch

.moveFlyingObjectRight
   inc roomObjectHorizPosition
.checkToChangeVerticalChangeIndex
   dec flyingObjectVertChangeTimer  ; decrement vertical change timer
   bpl .checkToChangeFlyingObjectHorizDirection
   ldx flyingObjectVertChangeIndex
   inx
   cpx #7
   bne .setFlyingObjectVerticalChangeTimer
   ldx #6
.setFlyingObjectVerticalChangeTimer
   stx flyingObjectVertChangeIndex
   lda random                       ; get random LSB value
   and FlyingObjectVertChangeMaskValues,x
   adc FlyingObjectVertChangeTimerAdjustmentValues,x
   sta flyingObjectVertChangeTimer
   txa
   bne .checkToChangeFlyingObjectHorizDirection
   ldx currentRoomNumber            ; get current room number
   cpx #ID_ROOM_GARGAMELS_LAB
   bne .checkToChangeFlyingObjectHorizDirection;branch if not ID_ROOM_GARGAMELS_LAB
   lda flyingObjectVertChangeTimer  ; get flying object vertical change timer
   clc
   adc #50
   sta flyingObjectVertChangeTimer
.checkToChangeFlyingObjectHorizDirection
   lda flyingObjectVertChangeIndex
   cmp #3
   bne .adjustFlyingObjectVerticalPosition
   lda smurfHorizPosition           ; get Smurf horizontal position
   sec
   sbc roomObjectHorizPosition      ; subtract flying object horizontal position
   bcc .smurfLeftOfFlyingObject     ; branch if Smurf left of flying object
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   beq .adjustFlyingObjectVerticalPosition;branch if OBJ_HORIZ_DIR_LEFT
.incrementFlyingObjectVertChangeTimer
   inc flyingObjectVertChangeTimer
   jmp .adjustFlyingObjectVerticalPosition

.smurfLeftOfFlyingObject
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   beq .incrementFlyingObjectVertChangeTimer;branch if OBJ_HORIZ_DIR_LEFT
.adjustFlyingObjectVerticalPosition
   ldx flyingObjectVertChangeIndex
   lda roomObstacleVertPosition     ; get flying object vertical position
   clc
   adc FlyingObjectVerticalChangeValues,x;adjust by vertical change value
   bmi .checkFlyingObjectReachingVertMinimum
   lda #<-1
.checkFlyingObjectReachingVertMinimum
   ldx currentRoomNumber            ; get current room number
   cmp FlyingObjectVerticalMinValues,x
   bcs .setFlyingObstacleVerticalPosition;branch if within vertical bounds
   lda FlyingObjectVerticalMinValues,x
.setFlyingObstacleVerticalPosition
   sta roomObstacleVertPosition
.doneMoveFlyingObject
   jmp .doneMoveSpider

MoveSnake
   lda roomObjectHorizPosition      ; get Snake horizontal position
   beq CheckToSpawnNewObstacle
   lda #0
   sta obstacleSpawnTimer
   lda frameCount                   ; get current frame count
   and #$1F
   bne .moveSnake
   ldx #<[SnakeHissingAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; set to play Snake sound effect
.moveSnake
   ldx currentPlayerSkillLevel      ; get current skill level
   lda RoomObstacleMovementDelayValues,x
   and frameCount
   bne .doneMoveSnake
   lda roomObstacleAttributes       ; get Snake attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep horizontal facing value
   bne .moveSnakeRight              ; branch if Snake facing right
   dec roomObjectHorizPosition
   dec roomObjectHorizPosition
.moveSnakeRight
   inc roomObjectHorizPosition
.doneMoveSnake
   jmp .doneMoveSpider

CheckToSpawnNewObstacle
   lda obstacleSpawnTimer           ; get obstacle spawn timer
   bne .checkToSpawnNewObstacle
   inc obstacleSpawnTimer           ; increment obstacle spawn number to 1
.checkToSpawnNewObstacle
   lda frameCount                   ; get current frame count
   bne .doneCheckToSpawnNewObstacle
   dec obstacleSpawnTimer           ; decrement obstacle spawn timer
   bne .doneCheckToSpawnNewObstacle
   lda gameState                    ; get current game state
   cmp #GS_GAME_IN_PROGRESS
   bne .doneCheckToSpawnNewObstacle ; branch if not GS_GAME_IN_PROGRESS
   jsr InitializeRoomObstaclePositions
   jmp .doneMoveSpider

.doneCheckToSpawnNewObstacle
   jmp .determineStationaryObstacleGraphicPtrs

MoveSpider
   lda gameState                    ; get current game state
   cmp #GS_GAME_IN_PROGRESS
   bne .moveSpider
   dec spiderSoundTimer             ; decrement Spider sound timer value
   bpl .moveSpider
   lda #23
   sta spiderSoundTimer             ; reset timer when timer expires
   ldx #<[SpiderAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues    ; set to play Spider sound effect
.moveSpider
   ldx currentPlayerSkillLevel      ; get current skill level
   lda frameCount                   ; get current frame count
   and RoomObstacleMovementDelayValues,x
   bne .doneMoveSpider
   ldy roomObstacleVertPosition     ; get Spider vertical position
   lda roomObstacleAttributes       ; get Spider attribute values
   bpl .moveSpiderUp                ; branch if Spider traveling up
.moveSpiderDown
   dey
   dey
   dey
   cpy #VERT_MIN_SPIDER
   bcs .setSpiderVerticalPosition
.changeSpiderVerticalDirection
   lda roomObstacleAttributes
   eor #$80
   sta roomObstacleAttributes
   bmi .moveSpiderDown
.moveSpiderUp
   cpx #3
   bne .moveSpiderUpFast            ; branch if not skill level 3
   iny
   iny
   cpy #VERT_MAX_SPIDER
   bcs .changeSpiderVerticalDirection
   bcc .setSpiderVerticalPosition   ; unconditional branch

.moveSpiderUpFast
   iny
   iny
   iny
   cpy #VERT_MAX_SPIDER - 1
   bcs .changeSpiderVerticalDirection
.setSpiderVerticalPosition
   sty roomObstacleVertPosition
.doneMoveSpider
   lda gameState                    ; get current game state
   cmp #GS_GAME_IN_PROGRESS
   bne AnimateRoomObstacle
   ldx currentRoomNumber            ; get current room number
   beq AnimateRoomObstacle          ; branch if ID_ROOM_MUSHROOM_HOUSE
   cpx #ID_ROOM_SPIDER_CAVERN
   beq AnimateRoomObstacle          ; branch if ID_ROOM_SPIDER_CAVERN
   cpx #ID_ROOM_RIVER_00
   beq CheckToChangeHawkOrSnakeHorizontalDirection;branch if ID_ROOM_RIVER_00
   cpx #ID_ROOM_RIVER_01
   beq CheckToChangeHawkOrSnakeHorizontalDirection;branch if ID_ROOM_RIVER_01
   lda flyingObjectVertChangeIndex
   cmp #6
   bne AnimateRoomObstacle
CheckToChangeHawkOrSnakeHorizontalDirection
   ldx currentPlayerSkillLevel      ; get current skill level
   lda ObstacleHorizontalChangeMaskValues,x
   and random
   bne AnimateRoomObstacle
   lda smurfHorizPosition           ; get Smurf horizontal position
   sec
   sbc roomObjectHorizPosition      ; subtract object horizontal position
   php                              ; push status to stack
   cmp #SMURF_OBSTACLE_HORIZ_RANGE  ; compare with horizonal distance
   bcc .doneChangeHawkOrSnakeHorizDirection;branch if outside horizontal distance
   cmp #<-SMURF_OBSTACLE_HORIZ_RANGE
   bcs .doneChangeHawkOrSnakeHorizDirection;branch if outside horizontal distance
   plp                              ; pull status from stack
   bcc .smurfOnObjectsLeft          ; branch if Smurf left of object
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   bne .obstacleChasingSmurf        ; branch if OBJ_HORIZ_DIR_RIGHT
.checkToChangeObstacleHorizontalDirection
   lda changeSnakeHorizDirTimer
   beq .changeHawkOrSnakeHorizDirection
   dec changeSnakeHorizDirTimer
   bne AnimateRoomObstacle
.changeHawkOrSnakeHorizDirection
   lda #<-1
   sta flyingObjectVertChangeTimer
   sta flyingObjectVertChangeIndex
   lda roomObstacleAttributes       ; get obstacle attribute value
   eor #OBJ_HORIZ_DIR_MASK          ; flip OBJ_HORIZ_DIR value
   sta roomObstacleAttributes
   jmp AnimateRoomObstacle

.obstacleChasingSmurf
   ldx currentRoomNumber            ; get current room number
   cpx #ID_ROOM_RIVER_00
   beq .snakeChasingSmurf           ; branch if ID_ROOM_RIVER_00
   cpx #ID_ROOM_RIVER_01
   bne AnimateRoomObstacle          ; branch if not ID_ROOM_RIVER_01
.snakeChasingSmurf
   ldx currentPlayerSkillLevel      ; get current skill level
   lda ObstacleHorizontalChangeMaskValues,x
   and random + 1
   bne AnimateRoomObstacle          ; branch to continue Snake chasing Smurf
   lda #20
   sta changeSnakeHorizDirTimer     ; reset timer
   bne .changeHawkOrSnakeHorizDirection;unconditional branch

.smurfOnObjectsLeft
   lda roomObstacleAttributes       ; get obstacle attribute values
   and #OBJ_HORIZ_DIR_MASK          ; keep OBJ_HORIZ_DIR value
   bne .checkToChangeObstacleHorizontalDirection;branch if OBJ_HORIZ_DIR_RIGHT
   beq .obstacleChasingSmurf        ; unconditional branch

.doneChangeHawkOrSnakeHorizDirection
   plp                              ; pull status from stack
AnimateRoomObstacle
   lda currentRoomNumber            ; get current room number
   asl                              ; multiply value by 8
   asl
   asl
   sta tmpRoomObstacleAnimationIndex
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 4
   lsr
   and #6
   ora tmpRoomObstacleAnimationIndex
   tay
   lda RoomObstacleAnimationValues - 8,y
   sta roomObstacleGraphicPointer
   lda RoomObstacleAnimationValues - 7,y
   sta roomObstacleGraphicPointer + 1
   tya                              ; move room obstacle animation index
   lsr
   tay
   lda roomObstacleVertPosition
   sbc RoomObstacleSpriteOffsetValues,y
   sta roomObstacleGraphicIndex
SetupForSixDigitDisplay
   lda #59
   jsr PositionGRP0Horizontally_BANK0
   lda #67
   jsr PositionObjectHorizontally_BANK0
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   ldx #0
   stx PF0
   stx PF1
   stx PF2
   stx REFP0
   inx                              ; x = 1
   stx CTRLPF
   inx                              ; x = 2
   ldy #10
.convertBCDToDigits
   lda currentPlayerScore,x         ; get current player score
   and #$0F                         ; keep lower nybbles
   asl                              ; multiply value by 8 (i.e. height of font)
   asl
   asl
   clc                              ; not needed...carry cleared with shift
   adc #<NumberFonts
   sta graphicPointers,y            ; set digit LSB value
   dey
   dey
   lda currentPlayerScore,x         ; get current player score
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2 (i.e. multiply by 8)
   clc                              ; not needed...carry cleared with shift
   adc #<NumberFonts
   sta graphicPointers,y            ; set digit LSB value
   dey
   dey
   dex
   bpl .convertBCDToDigits
   ldy #<BlankFont
   inx
.suppressLeadingZeros
   lda #<zero
   cmp graphicPointers,x
   beq .suppressLeadingZeroValue
   tay
   bne .setDigitPointerMSBValue     ; unconditional branch

.suppressLeadingZeroValue
    sty graphicPointers,x
.setDigitPointerMSBValue
   inx
   lda #>NumberFonts
   sta graphicPointers,x            ; set digit MSB value
   inx
   cpx #10
   bne .suppressLeadingZeros
   sta graphicPointers + 11
   ldx #WHITE
   ldy #COLOR_PLAYER_ONE_ENERGY_BAR
   lda currentGameSelection         ; get current game selection
   bpl .colorEnergyBar              ; branch if PLAYER_ONE_ACTIVE
   ldy #COLOR_PLAYER_TWO_ENERGY_BAR
.colorEnergyBar
   stx COLUP0
   stx COLUP1
   sty COLUPF
   ldx smurfAnimationIndex
   cpx #ID_SMURF_DROWNING
   bcc .keepSmurfRightOfMushroomHouse
   lda frameCount                   ; get current frame count
   and #7
   bne .keepSmurfRightOfMushroomHouse
   inx
   cpx #15
   bne .setAnimationForDrowningSmurf
   ldx #ID_SMURF_DROWNING + 1
.setAnimationForDrowningSmurf
   stx smurfAnimationIndex
.keepSmurfRightOfMushroomHouse
   lda currentRoomNumber            ; get current room number
   bne .checkToChangeObjectDirectionToLeft;branch if not ID_ROOM_MUSHROOM_HOUSE
   lda smurfHorizPosition           ; get Smurf horizontal position
   cmp #XMIN_SMURF_MUSHROOM_HOUSE
   bcs .checkToChangeObjectDirectionToLeft
   lda #XMIN_SMURF_MUSHROOM_HOUSE
   sta smurfHorizPosition           ; set Smurf to ID_ROOM_MUSHROOM_HOUSE XMIN
.checkToChangeObjectDirectionToLeft
   lda roomObjectHorizPosition      ; get room obstacle horizontal position
   cmp #XMAX - 9
   bcc .determineIfHawkScreenForSquakSounds;branch if not off screen right
   lda roomObstacleAttributes       ; get obstacle attribute value
   and #<~OBJ_HORIZ_DIR_MASK
   sta roomObstacleAttributes       ; set to OBJ_HORIZ_DIR_LEFT
.determineIfHawkScreenForSquakSounds
   ldx currentRoomNumber            ; get current room number
   cpx #ID_ROOM_WOODS
   beq .checkToPlayBirdSquakSounds  ; branch if ID_ROOM_WOODS
   cpx #ID_ROOM_MOUNTAINS
   bne DisplayKernel                ; branch if not ID_ROOM_MOUNTAINS
.checkToPlayBirdSquakSounds
   lda frameCount                   ; get current frame count
   and #$3F
   bne DisplayKernel                ; bird squaks ~ every second
   lda stationaryObstacleMask
   bne DisplayKernel                ; branch if showing stationary object
   ldx #<[BirdSquakAudioValues - SoundEffectsAudioValues]
   jsr SetSoundEffectAudioValues
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   lda smurfEnergyBarGraphics ; 3
   sta PF1                    ; 3 = @06
   lda smurfEnergyBarGraphics + 1;3
   sta PF2                    ; 3 = @12
   ldy #H_FONT - 1            ; 2
   ldx #0                     ; 2
   stx REFP1                  ; 3 = @19
   stx GRP0                   ; 3 = @22
   stx GRP1                   ; 3 = @25
   inx                        ; 2         x = 1
   stx VDELP0                 ; 3 = @30
   stx VDELP1                 ; 3 = @33
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3 = @38
   stx NUSIZ1                 ; 3 = @41
.sixDigitDisplayKernel
   lda (graphicPointers + 10),y;5
   sta tmpCharHolder          ; 3        
   sta WSYNC
;--------------------------------------
   lda (graphicPointers),y    ; 5
   sta GRP0                   ; 3 = @08
   lda (graphicPointers + 2),y; 5
   sta GRP1                   ; 3 = @16
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @24
   lda (graphicPointers + 6),y; 5
   tax                        ; 2
   lda (graphicPointers + 8),y; 5
   sty tmpSixDigitDisplayLoop ; 3
   ldy tmpCharHolder          ; 3
   stx GRP1                   ; 3 = @45
   sta GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sty GRP0                   ; 3 = @54
   ldy tmpSixDigitDisplayLoop ; 3
   dey                        ; 2
   bpl .sixDigitDisplayKernel ; 2³
   sta WSYNC
;--------------------------------------
   iny                        ; 2         y = 0
   sty VDELP0                 ; 3 = @05
   sty VDELP1                 ; 3 = @08
   sty GRP0                   ; 3 = @11
   sty GRP1                   ; 3 = @14
   sty PF1                    ; 3 = @17
   sty PF2                    ; 3 = @20
   ldx currentRemainingLives  ; 3         get current remaining lives
   lda RemainingLivesNUSIZValues,x;4        
   sta NUSIZ1                 ; 3 = @30
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta WSYNC
;--------------------------------------
   sta NUSIZ0                 ; 3 = @03
   lda #<BlankLivesIndicator  ; 2
   cpx #1                     ; 2
   bcc .setLivesIndicatorPtr_00;2³
   lda #<LivesIndicator       ; 2
.setLivesIndicatorPtr_00
   sta livesIndicatorGraphicPtr_00;3
   lda #<BlankLivesIndicator  ; 2
   cpx #2                     ; 2
   bcc .setLivesIndicatorPtr_01;2³
   lda #<LivesIndicator       ; 2
.setLivesIndicatorPtr_01
   sta livesIndicatorGraphicPtr_01;3
   lda #WHITE                 ; 2
   ldy #H_LIVES - 1           ; 2
.drawRemainingLivesKernel
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @03
   sta COLUP1                 ; 3 = @06
   lda (livesIndicatorGraphicPtr_00),y;5
   sta GRP0                   ; 3 = @14
   lda (livesIndicatorGraphicPtr_01),y;5
   sta GRP1                   ; 3 = @22
   lda #WHITE                 ; 2
   cpy #7                     ; 2
   bcs .nextRemainingLivesLine; 2³
   lda #COLOR_SMURF_BLUE      ; 2         set color to Smurf blue
.nextRemainingLivesLine
   dey                        ; 2
   bpl .drawRemainingLivesKernel;2³
   lda currentRoomNumber      ; 3         get current room number
   cmp #ID_ROOM_RIVER_00      ; 2
   bcs .jmpToDisplayKernelDriver;2³       branch if not first two rooms
   lda screenTransitionTimer  ; 3
   beq DrawTreesKernel        ; 2³
.jmpToDisplayKernelDriver
   jmp JumpToDisplayKernel_BANK0;3

DrawTreesKernel
   jsr HorizPositionSmurfAndObstacle_BANK0;6
;--------------------------------------
   sty tmpSmurfSkipDrawIdx    ; 3
   stx WSYNC
;--------------------------------------
   lda #0                     ; 2
   tay                        ; 2
   ldx stationaryObstacleMask ; 3
   beq .setStationaryObjectSizeAndColor;2³ branch if not showing fence
   lda #WHITE                 ; 2
   ldy #DOUBLE_SIZE           ; 2
.setStationaryObjectSizeAndColor
   sty NUSIZ1                 ; 3
   sta COLUP1                 ; 3
   lda currentRoomNumber      ; 3         get current room number
   bne .colorTreeLeaves       ; 2³        branch if not ID_ROOM_MUSHROOM_HOUSE
   lda #QUAD_SIZE             ; 2
   sta NUSIZ1                 ; 3         set size for Mushroom house
.colorTreeLeaves
   ldx #COLOR_TREE_LEAVES + 8 ; 2
   stx COLUPF                 ; 3         color tree leaves
   ldy #4                     ; 2
.drawTreeLeaves
   ldx TreeLeavesHeightValues,y;4
.drawTreeLeafSection
   sta WSYNC
;--------------------------------------
   lda TreeLeavesGraphics,y   ; 4
   sta PF2                    ; 3 = @07
   lda #COLOR_TREE_LEAVES + 10; 2
   sta COLUBK                 ; 3 = @12
   dex                        ; 2
   bne .drawTreeLeafSection   ; 2³
   dey                        ; 2
   bpl .drawTreeLeaves        ; 2³
   ldx #7                     ; 2
.wait39Cycles
   dex                        ; 2
   bpl .wait39Cycles          ; 2³
   lda #COLOR_TREE_LEAVES + 8 ; 2
   ldx #COLOR_TREE_LEAVES + 10; 2
   stx COLUPF                 ; 3 = @68
   ldx #H_TREE_KERNEL - 1     ; 2
.drawTreeLimbs
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda TreePF0Graphics,x      ; 4
   sta PF0                    ; 3 = @10
   lda TreePF1Graphics,x      ; 4
   sta PF1                    ; 3 = @17
   lda TreePF2Graphics,x      ; 4
   sta PF2                    ; 3 = @24
   cpx #H_TREE_KERNEL - 9     ; 2
   bne .drawTreeKernelLayer_00; 2³
   lda #LT_BROWN + 6          ; 2
   sta COLUPF                 ; 3 = @33   color tree limbs and trunk
.drawTreeKernelLayer_00
   cpx #H_TREE_KERNEL - 18    ; 2
   bcc .drawTreeKernelLayer_01; 2³
   lda #COLOR_TREE_LEAVES + 8 ; 2
   bcs .nextTreeLimb          ; 3         unconditional branch

.drawTreeKernelLayer_01
   cpx #H_TREE_KERNEL - 30    ; 2
   bcc .drawTreeKernelLayer_02; 2³
   lda #COLOR_TREE_LEAVES + 6 ; 2
   bcs .nextTreeLimb          ; 3         unconditional branch

.drawTreeKernelLayer_02
   lda #COLOR_TREE_LEAVES + 4 ; 2
   cpx #H_TREE_KERNEL - 36    ; 2
   bcs .nextTreeLimb          ; 2³
   lda #COLOR_TREE_SKY        ; 2         color sky
.nextTreeLimb
   dex                        ; 2
   bmi .doneDrawTrees         ; 2³
   bne .drawTreeLimbs         ; 2³
   lda #COLOR_TREE_SKY        ; 2         color sky
   bne .drawTreeLimbs         ; 2³

.doneDrawTrees
   jmp JumpToDisplayKernel_BANK0;3

StationaryObjectEnablingPoint
   .byte XMAX + 1                   ; unused
   .byte HORIZ_FENCE + 30           ; ID_ROOM_WOODS
   .byte XMAX + 1, XMAX + 1, XMAX + 1, XMAX + 1;unused
   .byte 66                         ; ID_ROOM_GARGAMELS_LAB

RoomObstacleInitialHorizontalPosition
   .byte INIT_HORIZ_MUSHROOM_OBSTACLE
   .byte INIT_HORIZ_FIELD_HAWK
   .byte INIT_HORIZ_RIVER_SNAKE
   .byte INIT_HORIZ_MOUNTAIN_HAWK
   .byte INIT_HORIZ_CAVERN_SPIDER
   .byte INIT_HORIZ_RIVER_SNAKE
   .byte INIT_HORIZ_GARGAMEL_BAT

RoomObstacleInitialVerticalPosition
   .byte 0
   .byte INIT_VERT_HAWK
   .byte INIT_VERT_SNAKE
   .byte INIT_VERT_HAWK
   .byte INIT_VERT_SPIDER
   .byte INIT_VERT_SNAKE
   .byte INIT_VERT_BAT

WestTravelingRoomRuleIndexValues
   .byte <[SmurfHomeBoundaryRules - CurrentRoomBoundaryRules + 3]
   .byte <[FieldsBoundaryRules - CurrentRoomBoundaryRules + 3]
   .byte <[FirstStreamBoundaryRules - CurrentRoomBoundaryRules + 3]
   .byte <[MountainsBoundaryRules - CurrentRoomBoundaryRules + 6]
   .byte <[SpiderCavernBoundaryRules - CurrentRoomBoundaryRules + 6]
   .byte <[SecondStreamBoundaryRules - CurrentRoomBoundaryRules + 3]
   .byte <[GargamelsLabBoundaryRules - CurrentRoomBoundaryRules + 12]

EastTravelingRoomRuleIndexValues
   .byte <[SmurfHomeBoundaryRules - CurrentRoomBoundaryRules + 3]
   .byte <[FieldsBoundaryRules - CurrentRoomBoundaryRules]
   .byte <[FirstStreamBoundaryRules - CurrentRoomBoundaryRules]
   .byte <[MountainsBoundaryRules - CurrentRoomBoundaryRules]
   .byte <[SpiderCavernBoundaryRules - CurrentRoomBoundaryRules]
   .byte <[SecondStreamBoundaryRules - CurrentRoomBoundaryRules]
   .byte <[GargamelsLabBoundaryRules - CurrentRoomBoundaryRules]

CurrentRoomBoundaryRules
SmurfHomeBoundaryRules
   .byte 0, 0, 0
   .byte VERT_MIN_SMURF, XMIN, XMAX + 1
   .byte 0, 0, 0
FieldsBoundaryRules
   .byte VERT_MIN_SMURF, XMIN, HORIZ_FENCE - 7
   .byte VERT_MIN_SMURF, HORIZ_FENCE + 15, XMAX + 1
   .byte 0, 0, 0
FirstStreamBoundaryRules
   .byte VERT_MIN_SMURF, XMIN, STREAM_BANK_HORIZ_POSITION_WEST
   .byte VERT_MIN_SMURF, STREAM_BANK_HORIZ_POSITION_EAST - 2, XMAX + 1
   .byte 0, 0, 0
MountainsBoundaryRules
   .byte VERT_MIN_SMURF, XMIN, 28
   .byte VERT_MIN_SMURF_MOUNTAIN_STEP_00, 28, 84
   .byte VERT_MIN_SMURF_MOUNTAIN_STEP_01, 84, XMAX + 1
   .byte 0, 0, 0
SpiderCavernBoundaryRules
   .byte VERT_MIN_SMURF_SPIDER_LEDGE, XMIN,$24
   .byte VERT_MIN_SMURF, 48, 106
   .byte VERT_MIN_SMURF_SPIDER_LEDGE, 120, XMAX + 1
   .byte 0, 0, 0
SecondStreamBoundaryRules
   .byte VERT_MIN_SMURF, XMIN, STREAM_BANK_HORIZ_POSITION_WEST
   .byte VERT_MIN_SMURF, STREAM_BANK_HORIZ_POSITION_EAST - 2, XMAX + 1
   .byte 0, 0, 0
GargamelsLabBoundaryRules
   .byte VERT_MIN_SMURF, XMIN, XMIN + 18
   .byte VERT_MIN_SMURF_GARGAMEL_STOOP_00, XMIN + 20, 40
   .byte VERT_MIN_SMURF_GARGAMEL_TABLE, 44, 67
   .byte VERT_MIN_SMURF_GARGAMEL_CHAIR, 68, 88
   .byte VERT_SMURF_RESCUED_SMURFETTE, 108, HORIZ_SMURF_RESCUED_SMURFETTE + 12
   .byte 0

JumpingPositionChangeValues
HorizontalStationaryJumpPositionChangeValues
   .byte END_JUMP_ACTION, 0 << 4 | 4, 0 << 4 | 3, 0 << 4 | 2, 0 << 4 | 2
   .byte 0 << 4 | 2, 0 << 4 | 2, 0 << 4 | 2, 0 << 4 | 2, 0 << 4 | 2, 0 << 4 | 2
   .byte 0 << 4 | 2, 0 << 4 | 1, 0 << 4 | 1, 0 << 4 | 1, 0 << 4 | 1
   .byte END_JUMP_ACTION
RunningJumpPositionChangeValues
   .byte 1 << 4 | 4, 0 << 4 | 3, 1 << 4 | 2, 0 << 4 | 2, 1 << 4 | 2, 0 << 4 | 2
   .byte 1 << 4 | 2, 0 << 4 | 2, 1 << 4 | 2, 0 << 4 | 2, 1 << 4 | 2, 0 << 4 | 1
   .byte 1 << 4 | 1, 1 << 4 | 1, 1 << 4 | 0, END_JUMP_ACTION
SuperJumpPositionChangeValues
   .byte 1 << 4 | 4, 0 << 4 | 3, 1 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2
   .byte 0 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2, 0 << 4 | 2, 1 << 4 | 2
   .byte 1 << 4 | 2, 1 << 4 | 2, 0 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2, 1 << 4 | 2
   .byte 0 << 4 | 2, 1 << 4 | 2, 1 << 4 | 1, 1 << 4 | 1, 1 << 4 | 1, 1 << 4 | 0
   .byte END_JUMP_ACTION

RoomObstacleAnimationValues
;
; ID_ROOM_WOODS obstacle
;
   .word HawkSprite_00
   .word HawkSprite_01
   .word HawkSprite_02
   .word HawkSprite_01
;
; ID_ROOM_RIVER_00 obstacle
;
   .word SnakeSprite_00
   .word SnakeSprite_01
   .word SnakeSprite_02
   .word SnakeSprite_01
;
; ID_ROOM_MOUNTAINS obstacle
;
   .word HawkSprite_00
   .word HawkSprite_01
   .word HawkSprite_02
   .word HawkSprite_01
;
; ID_ROOM_SPIDER_CAVERN obstacle
;
   .word SpiderSprite_00
   .word SpiderSprite_01
   .word SpiderSprite_02
   .word SpiderSprite_01
;
; ID_ROOM_RIVER_01 obstacle
;
   .word SnakeSprite_00
   .word SnakeSprite_01
   .word SnakeSprite_02
   .word SnakeSprite_01
;
; ID_ROOM_GARGAMELS_LAB obstacle
;
   .word BatSprite_00
   .word BatSprite_01
   .word BatSprite_02
   .word BatSprite_01

RoomObstacleSpriteOffsetValues
   .byte 0, 0, 0, 0           ; ID_ROOM_MUSHROOM_HOUSE
   .byte 0, 7, 9, 7           ; ID_ROOM_WOODS
   .byte 0, 0, 0, 0           ; ID_ROOM_RIVER_00
   .byte 0, 7, 9, 7           ; ID_ROOM_MOUNTAINS
   .byte 0, 1, 1, 1           ; ID_ROOM_SPIDER_CAVERN
   .byte 0, 0, 0, 0           ; ID_ROOM_RIVER_01
   .byte 0, 6, 6, 6           ; ID_ROOM_GARGAMELS_LAB

SoundEffectsAudioValues
   .byte END_AUDIO_TUNE, END_AUDIO_TUNE, END_AUDIO_TUNE
BirdSquakAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 1  ; saw waveform
   .byte  0 << 4 | 11,  0 << 4 | 10,  0 << 4 |  9,  0 << 4 |  8,  0 << 4 |  7
   .byte  0 << 4 |  4,  0 << 4 |  6,  2 << 4 |  4,  0 << 4 |  6,  0 << 4 |  5
   .byte  2 << 4 |  7,  0 << 4 |  5,  0 << 4 |  7,  0 << 4 |  9,  0 << 4 |  6
   .byte  0 << 4 |  9,  0 << 4 | 10,  0 << 4 | 11, END_AUDIO_TUNE
PlayerOneUpAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 12 ; lower pitch square wave
   .byte  7 << 4 | 15,  7 << 4 | 11,  7 << 4 |  8,  7 << 4 |  7,  7 << 4 |  4
   .byte  7 << 4 |  2,  7 << 4 |  0, 16 << 3 | 15, END_AUDIO_TUNE
PlayerTwoUpAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 12 ; lower pitch square wave
   .byte  6 << 4 | 15,  7 << 4 |  0,  7 << 4 |  2,  7 << 4 |  4,  7 << 4 |  7
   .byte  7 << 4 |  8,  7 << 4 | 11, 16 << 3 | 31, END_AUDIO_TUNE
SpiderAudioValues
   .byte SOUND_LOW_PRIORITY | 7     ; low and buzzy
   .byte  0 << 4 |  1,  0 << 4 |  1,  0 << 4 |  2,  0 << 4 |  3, END_AUDIO_TUNE
GameSelectionAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 2
   .byte 28 << 3 |  0, END_AUDIO_TUNE
SmurfFootstepsAudioValues_00
   .byte SOUND_LOW_PRIORITY | 12    ; lower pitch square wave
   .byte  1 << 4 |  4, END_AUDIO_TUNE
SmurfFootstepsAudioValues_01
   .byte SOUND_LOW_PRIORITY | 12    ; lower pitch square wave
   .byte  1 << 4 |  8, END_AUDIO_TUNE
SnakeHissingAudioValues
   .byte SOUND_LOW_PRIORITY | 8     ; white noise
   .byte  2 << 4 |  2, END_AUDIO_TUNE
SmurfFallingAudioValues
   .byte SOUND_LOW_PRIORITY | 4     ; high pitch pure tone
   .byte  1 << 4 |  4,  1 << 4 |  5,  1 << 4 |  6,  1 << 4 |  7,  1 << 4 |  8
   .byte  1 << 4 |  9,  1 << 4 | 10,  3 << 4 | 11,  3 << 4 | 12,  3 << 4 | 13
   .byte  3 << 4 | 14,  3 << 4 | 15, END_AUDIO_TUNE
SmurfDeathAudioValues
   .byte SOUND_HIGH_PRIORITY | 9
   .byte  3 << 4 |  6,  3 << 4 |  5,  3 << 4 |  4,  3 << 4 |  3,  3 << 4 |  4
   .byte  3 << 4 |  5,  3 << 4 |  6,  3 << 4 |  7,  3 << 4 |  8, END_AUDIO_TUNE
SmurfJumpingAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 1  ; saw waveform
   
   IF COMPILE_REGION = PAL50

   .byte  0 << 4 | 12,  0 << 4 | 11,  2 << 4 | 10,  2 << 4 |  9,  2 << 4 |  8
   .byte  2 << 4 |  7,  0 << 4 |  6,  0 << 4 |  5, END_AUDIO_TUNE
   
   ELSE

   .byte  2 << 4 | 12,  2 << 4 | 11,  2 << 4 | 10,  2 << 4 |  9,  2 << 4 |  8
   .byte  2 << 4 |  7,  2 << 4 |  6,  0 << 4 |  5, END_AUDIO_TUNE
   
   ENDIF

FlyingObjectFlappingAudioValues
   .byte SOUND_LOW_PRIORITY | 8     ; white noise
   .byte  1 << 4 |  5, END_AUDIO_TUNE
SmurfDrowningAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 12 ; lower pitch square wave
   .byte  1 << 4 | 12,  1 << 4 |  7,  1 << 4 |  1,  0 << 4 | 13, 28 << 3 | 21
   .byte  1 << 4 |  8,  1 << 4 |  6,  1 << 4 |  3,  1 << 4 |  0,  0 << 4 | 13
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 4 >> 2
   .byte  1 << 4 |  7,  1 << 4 |  5,  1 << 4 |  2,  0 << 4 | 15,  0 << 4 | 13
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 12 >> 2
   .byte  1 << 4 | 12,  1 << 4 | 10,  1 << 4 |  7,  1 << 4 |  5,  1 << 4 |  3
   .byte  1 << 4 |  0
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 12 >> 2
   .byte  1 << 4 | 15,  1 << 4 | 11,  1 << 4 | 13,  1 << 4 |  9,  1 << 4 |  4
   .byte  1 << 4 |  6,  1 << 4 |  4, END_AUDIO_TUNE
SmurfCapturedBySpiderAudioValues
   .byte SOUND_HIGH_PRIORITY | $70 | 7  ; low and buzzy
   .byte  0 << 4 |  7,  2 << 4 |  7,  2 << 4 |  6,  4 << 4 |  4,  0 << 4 |  4
   .byte AUDIO_WAIT | 12 >> 2
   .byte  2 << 4 |  8,  0 << 4 |  7,  0 << 4 |  6,  2 << 4 |  4,  0 << 4 |  4
   .byte AUDIO_WAIT | 0 >> 2
   .byte  2 << 4 | 10,  0 << 4 |  8,  0 << 4 |  7,  0 << 4 |  6,  4 << 4 |  4
   .byte  0 << 4 |  4
   .byte AUDIO_WAIT | 4 >> 2
   .byte  2 << 4 | 11,  0 << 4 |  9,  0 << 4 |  8,  0 << 4 |  7,  4 << 4 |  5
   .byte  0 << 4 |  5
   .byte AUDIO_WAIT | 4 >> 2
   .byte  2 << 4 | 11,  4 << 4 |  7,  0 << 4 |  7,  0 << 4 |  9, END_AUDIO_TUNE

BackgroundMusicAudioValues
ExtraLifeAudioValues
ExtraLifeLeftChannelAudioValues
   .byte SOUND_HIGH_PRIORITY | $50 | SOUND_TWO_CHANNELS | 12;lower pitch square wave
   .byte <[ExtraLifeRightChannelAudioValues - BackgroundMusicAudioValues]
   
   IF COMPILE_REGION = PAL50

   .byte  7 << 4 | 15,  7 << 4 |  7,  7 << 4 |  2, 28 << 3 | 15,  7 << 4 |  2
   .byte 28 << 3 | 15, END_AUDIO_TUNE
   
   ELSE
   
   .byte 24 << 3 | 31,  7 << 4 |  7, 24 << 3 | 18,  6 << 4 | 15, 24 << 3 | 18
   .byte 28 << 3 | 15, END_AUDIO_TUNE
   
   ENDIF
   
ExtraLifeRightChannelAudioValues
   .byte SOUND_LOW_PRIORITY | SOUND_ONE_CHANNEL | 12; lower pitch square wave
   
   IF COMPILE_REGION = PAL50

   .byte  7 << 4 | 15,  7 << 4 |  7,  7 << 4 |  2, 28 << 3 | 15,  7 << 4 |  2
   .byte 28 << 3 | 15, END_AUDIO_TUNE
   
   ELSE

   .byte 24 << 3 | 31,  7 << 4 |  7, 24 << 3 | 18,  6 << 4 | 15, 24 << 3 | 18
   .byte 28 << 3 | 15, END_AUDIO_TUNE

   ENDIF

GameBackgroundMusicAudioValues
GameBackgroundMusicLeftChannelAudioValues
   .byte SOUND_HIGH_PRIORITY | $50 | SOUND_TWO_CHANNELS | 4;high pitch pure tone
   .byte <[GameBackgroundMusicRightChannelAudioValues - BackgroundMusicAudioValues]
   
   IF COMPILE_REGION = PAL50
   
   .byte 20 << 3 | 31, 20 << 3 | 31, 24 << 3 | 23,  7 << 4 |  7, 20 << 3 | 23
   .byte 20 << 3 | 20, 20 << 3 | 18, 20 << 3 | 23, 20 << 3 | 18, 20 << 3 | 17
   .byte 28 << 3 | 15,  6 << 4 | 15, 20 << 3 | 15, 20 << 3 | 17, 24 << 3 | 18
   .byte AUDIO_WAIT | 16 >> 2
   .byte 20 << 3 | 20, 20 << 3 | 23, 24 << 3 | 20,  7 << 4 |  4, 20 << 3 | 20
   .byte 20 << 3 | 23, 20 << 3 | 20, 20 << 3 | 18, 20 << 3 | 20, 20 << 3 | 23
   .byte 24 << 3 | 20
   .byte AUDIO_WAIT | 0 >> 2
   .byte  7 << 4 |  4, 20 << 3 | 20, 20 << 3 | 24, 24 << 3 | 31
   .byte AUDIO_WAIT | 60 >> 2, END_AUDIO_TUNE
   
   ELSE

   .byte 16 << 3 | 31, 16 << 3 | 31, 24 << 3 | 23,  7 << 4 |  7, 16 << 3 | 23
   .byte 16 << 3 | 20, 16 << 3 | 18, 16 << 3 | 23, 16 << 3 | 18, 16 << 3 | 17
   .byte 28 << 3 | 15,  6 << 4 | 15, 16 << 3 | 15, 16 << 3 | 17, 24 << 3 | 18
   .byte AUDIO_WAIT | 8 >> 2
   .byte 16 << 3 | 20, 16 << 3 | 23, 24 << 3 | 20,  7 << 4 |  4, 16 << 3 | 20
   .byte 16 << 3 | 23, 16 << 3 | 20, 16 << 3 | 18, 16 << 3 | 20, 16 << 3 | 23
   .byte 24 << 3 | 20,  7 << 4 |  4, 16 << 3 | 20, 16 << 3 | 24, 24 << 3 | 31
   .byte AUDIO_WAIT | 60 >> 2, AUDIO_WAIT | 16 >> 2, END_AUDIO_TUNE
   
   ENDIF
   
GameBackgroundMusicRightChannelAudioValues
   .byte SOUND_LOW_PRIORITY | SOUND_ONE_CHANNEL | 4;high pitch pure tone
   
   IF COMPILE_REGION = PAL50

   .byte AUDIO_WAIT | 32 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 24 << 3 | 31
   .byte AUDIO_WAIT | 16 >> 2
   .byte 20 << 3 | 27, 20 << 3 | 24, 24 << 3 | 23
   .byte AUDIO_WAIT | 12 >> 2
   .byte 20 << 3 | 23, 24 << 3 | 20, 24 << 3 | 24
   .byte AUDIO_WAIT | 16 >> 2
   .byte 24 << 3 | 31
   .byte AUDIO_WAIT | 16 >> 2
   .byte 24 << 3 | 23
   .byte AUDIO_WAIT | 16 >> 2
   .byte 20 << 3 | 24, 20 << 3 | 27, 24 << 3 | 24
   .byte AUDIO_WAIT | 16 >> 2
   .byte 24 << 3 | 31
   .byte AUDIO_WAIT | 4 >> 2
   .byte 20 << 3 | 17, 20 << 3 | 15, 20 << 3 | 17, 20 << 3 | 18, 24 << 3 | 24
   .byte AUDIO_WAIT | 0 >> 2
   .byte  6 << 4 | 15, 20 << 3 | 17, 20 << 3 | 20, 24 << 3 | 24
   .byte AUDIO_WAIT | 32 >> 2, END_AUDIO_TUNE

   ELSE
   
    .byte AUDIO_WAIT | 32 >> 2
    .byte 24 << 3 | 31
    .byte AUDIO_WAIT | 8 >> 2
    .byte 16 << 3 | 27, 16 << 3 | 24, 24 << 3 | 23
    .byte AUDIO_WAIT | 8 >> 2
    .byte 16 << 3 | 23, 16 << 3 | 20, 24 << 3 | 24
    .byte AUDIO_WAIT | 8 >> 2
    .byte 24 << 3 | 31
    .byte AUDIO_WAIT | 8 >> 2
    .byte 24 << 3 | 23
    .byte AUDIO_WAIT | 8 >> 2
    .byte 16 << 3 | 24, 16 << 3 | 27, 24 << 3 | 24
    .byte AUDIO_WAIT | 8 >> 2
    .byte 24 << 3 | 31
    .byte AUDIO_WAIT | 8 >> 2
    .byte 16 << 3 | 17, 16 << 3 | 15, 16 << 3 | 17, 16 << 3 | 18, 24 << 3 | 24
    .byte  6 << 4 | 15, 16 << 3 | 17, 16 << 3 | 20, 24 << 3 | 24
    .byte AUDIO_WAIT | 32 >> 2, END_AUDIO_TUNE

   ENDIF

SmurfThemeSongAudioValues
SmurfThemeSongLeftChannelAudioValues
   .byte SOUND_HIGH_PRIORITY | $50 | SOUND_TWO_CHANNELS | 4;high pitch pure tone
   .byte <[SmurfThemeSongRightChannelAudioValues - BackgroundMusicAudioValues]
   
   IF COMPILE_REGION = PAL50

   .byte AUDIO_WAIT | 60 >> 2
   .byte 28 << 3 | 15
   .byte AUDIO_WAIT | 4 >> 2
   .byte 28 << 3 | 11,  6 << 4 | 15, 20 << 3 | 13, 20 << 3 | 17, 24 << 3 | 20
   .byte AUDIO_WAIT | 12 >> 2
   .byte 28 << 3 | 15,  7 << 4 |  2, 20 << 3 | 23, 20 << 3 | 18, 24 << 3 | 20
   .byte AUDIO_WAIT | 44 >> 2
   .byte 28 << 3 | 15
   .byte AUDIO_WAIT | 4 >> 2
   .byte 28 << 3 | 11,  6 << 4 | 15, 20 << 3 | 13, 20 << 3 | 17, 24 << 3 | 20
   .byte AUDIO_WAIT | 12 >> 2
   .byte 24 << 3 | 15,  7 << 4 |  2, 20 << 3 | 23, 20 << 3 | 24, 24 << 3 | 23
   .byte AUDIO_WAIT | 60 >> 2, END_AUDIO_TUNE

   ELSE

   .byte 28 << 3 | 31, 28 << 3 | 15
   .byte AUDIO_WAIT | 4 >> 2
   .byte 24 << 3 | 11,  6 << 4 | 15, 16 << 3 | 13, 16 << 3 | 17, 24 << 3 | 20
   .byte AUDIO_WAIT | 8 >> 2
   .byte 28 << 3 | 15,  7 << 4 |  2, 16 << 3 | 23, 16 << 3 | 18, 24 << 3 | 20
   .byte AUDIO_WAIT | 40 >> 2
   .byte 28 << 3 | 15
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 11
   .byte AUDIO_WAIT | 0 >> 2
   .byte  6 << 4 | 15, 16 << 3 | 13, 16 << 3 | 17, 24 << 3 | 20
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 15,  7 << 4 |  2, 16 << 3 | 23, 16 << 3 | 24, 24 << 3 | 23
   .byte AUDIO_WAIT | 60 >> 2, END_AUDIO_TUNE

   ENDIF

SmurfThemeSongRightChannelAudioValues
   .byte SOUND_LOW_PRIORITY | SOUND_ONE_CHANNEL | 12;lower pitch square wave
   
   IF COMPILE_REGION = PAL50

   .byte AUDIO_WAIT | 60 >> 2
   .byte 24 << 3 | 20
   .byte AUDIO_WAIT | 16 >> 2
   .byte 24 << 3 | 24,  7 << 4 |  4
   .byte AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 27, 20 << 3 | 23, 20 << 3 | 18, 20 << 3 | 16, 28 << 3 | 15
   .byte  7 << 4 |  4, 20 << 3 | 24, 20 << 3 | 31, 20 << 3 | 20, 20 << 3 | 23
   .byte 20 << 3 | 24, 20 << 3 | 27, 28 << 3 | 15
   .byte AUDIO_WAIT | 12 >> 2
   .byte 24 << 3 | 17,  7 << 4 |  1, 20 << 3 | 18, 20 << 3 | 15, 24 << 3 | 19
   .byte AUDIO_WAIT | 16 >> 2
   .byte 24 << 3 | 27,  7 << 4 |  8, 20 << 3 | 23, 20 << 3 | 20, 20 << 3 | 31
   .byte 20 << 3 | 20, 28 << 3 | 15
   .byte AUDIO_WAIT | 60 >> 2, END_AUDIO_TUNE

   ELSE

   .byte AUDIO_WAIT | 60 >> 2
   .byte 24 << 3 | 20
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 24,  7 << 4 |  4, 16 << 3 | 27, 16 << 3 | 23, 16 << 3 | 18
   .byte 16 << 3 | 16, 20 << 3 | 15
   .byte AUDIO_WAIT | 8 >> 2
   .byte  7 << 4 |  4, 16 << 3 | 24, 16 << 3 | 31, 16 << 3 | 20, 16 << 3 | 23
   .byte 16 << 3 | 24, 16 << 3 | 27, 28 << 3 | 15
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 17,  7 << 4 |  1, 24 << 3 | 18
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 19
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 27,  7 << 4 |  8, 16 << 3 | 23, 16 << 3 | 20, 16 << 3 | 31
   .byte 16 << 3 | 20, 28 << 3 | 15, END_AUDIO_TUNE
   
   ENDIF

SmurfetteRescuedAudioValues
SmurfetteRescuedLeftChannelAudioValues
   .byte SOUND_HIGH_PRIORITY | $50 | SOUND_TWO_CHANNELS | 4;high pitch pure tone
   .byte <[SmurfetteRescuedRightChannelAudioValues - BackgroundMusicAudioValues]
   
   IF COMPILE_REGION = PAL50

   .byte 20 << 3 | 19
   .byte AUDIO_WAIT | 4 >> 2
   .byte 20 << 3 | 19
   .byte AUDIO_WAIT | 4 >> 2
   .byte 28 << 3 | 14
   .byte AUDIO_WAIT | 12 >> 2
   .byte 16 << 3 | 14
   .byte AUDIO_WAIT | 0 >> 2
   .byte 24 << 3 | 14
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 12
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 11
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 14
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 11
   .byte AUDIO_WAIT | 8 >> 2
   .byte 24 << 3 | 10
   .byte AUDIO_WAIT | 8 >> 2
   .byte 28 << 3 |  9
   .byte AUDIO_WAIT | 8 >> 2
   .byte 16 << 3 |  9
   .byte AUDIO_WAIT | 8 >> 2
   .byte 28 << 3 |  9
   .byte AUDIO_WAIT | 8 >> 2
   .byte 28 << 3 | 10
   .byte AUDIO_WAIT | 8 >> 2
   .byte  2 << 4 | 11, 28 << 3 | 11, END_AUDIO_TUNE

   ELSE

   .byte 20 << 3 | 19
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 19
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 14
   .byte AUDIO_WAIT | 4 >> 2, AUDIO_WAIT | 0 >> 2
   .byte  6 << 4 | 14
   .byte AUDIO_WAIT | 4 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 14
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 12
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 11
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 14
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 11
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 10
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 |  9
   .byte AUDIO_WAIT | 4 >> 2, AUDIO_WAIT | 0 >> 2
   .byte  6 << 4 |  9
   .byte AUDIO_WAIT | 4 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 24 << 3 |  9, 24 << 3 | 10
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 11, END_AUDIO_TUNE
   
   ENDIF

SmurfetteRescuedRightChannelAudioValues
   .byte SOUND_LOW_PRIORITY | SOUND_ONE_CHANNEL | 4;high pitch pure tone
   
   IF COMPILE_REGION = PAL50

   .byte AUDIO_WAIT | 44 >> 2
   .byte 24 << 3 | 19
   .byte AUDIO_WAIT | 28 >> 2
   .byte 20 << 3 | 17
   .byte AUDIO_WAIT | 4 >> 2
   .byte 20 << 3 | 15
   .byte AUDIO_WAIT | 4 >> 2
   .byte 28 << 3 | 14
   .byte AUDIO_WAIT | 24 >> 2
   .byte 28 << 3 | 14, 24 << 3 | 12, 28 << 3 | 15
   .byte AUDIO_WAIT | 20 >> 2
   .byte 28 << 3 | 12
   .byte AUDIO_WAIT | 32 >> 2
   .byte  2 << 4 | 14, 28 << 3 | 14, END_AUDIO_TUNE

   ELSE

   .byte AUDIO_WAIT | 44 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 24 << 3 | 19
   .byte AUDIO_WAIT | 20 >> 2, AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 17
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 20 << 3 | 15
   .byte AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 14
   .byte AUDIO_WAIT | 16 >> 2, AUDIO_WAIT | 44 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 15
   .byte AUDIO_WAIT | 16 >> 2, AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 12
   .byte AUDIO_WAIT | 20 >> 2, AUDIO_WAIT | 0 >> 2, AUDIO_WAIT | 0 >> 2
   .byte 28 << 3 | 14, END_AUDIO_TUNE

   ENDIF

RemainingLivesNUSIZValues
   .byte ONE_COPY << 4 | ONE_COPY, ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY, TWO_COPIES << 4 | ONE_COPY
   .byte TWO_COPIES << 4 | TWO_COPIES, THREE_COPIES << 4 | TWO_COPIES
   .byte THREE_COPIES << 4 | THREE_COPIES

TreePF0Graphics
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
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
TreePF1Graphics
   .byte $89 ; |X...X..X|
   .byte $8D ; |X...XX.X|
   .byte $8D ; |X...XX.X|
   .byte $8F ; |X...XXXX|
   .byte $8F ; |X...XXXX|
   .byte $9B ; |X..XX.XX|
   .byte $9B ; |X..XX.XX|
   .byte $9B ; |X..XX.XX|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $83 ; |X.....XX|
   .byte $83 ; |X.....XX|
   .byte $83 ; |X.....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C7 ; |XX...XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E5 ; |XXX..X.X|
   .byte $E5 ; |XXX..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
TreePF2Graphics
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $0D ; |....XX.X|
   .byte $1D ; |...XXX.X|
   .byte $1D ; |...XXX.X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
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
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
    
TreeLeavesHeightValues
   .byte 4, 4, 6, 7, 4
    
TreeLeavesGraphics
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
    
   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

   .byte $A0,$A8,$D3,$C8,$FF,$A0,$A0,$A0;unused bytes

      ELSE
   
   .byte $A0                        ; unused byte

      ENDIF

   ENDIF

   FILL_BOUNDARY 228, 0
   
JumpToDisplayKernel_BANK0
   lda BANK0_REORG | BANK1STROBE
   lda BANK0_REORG | BANK0STROBE
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   jmp JumpToCurrentGameStateRoutine

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
   
   .byte $B0,$FF,$D0,$A0            ; unused bytes
   
      ELSE
   
   .byte $A0,$A2,$BB,$A9            ; unused bytes
   
      ENDIF
   
   ENDIF

   FILL_BOUNDARY 252, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK0 FREE"
   
   .word Bank0Start                 ; RESET vector
   .word Bank1Start                 ; BRK vector

;===============================================================================
; R O M - C O D E (BANK1)
;===============================================================================

   SEG Bank1
   .org BANK1_BASE
   .rorg BANK1_REORG
   
FREE_BYTES SET 0

Bank1Start

   IF COMPILE_REGION = PAL50

      lda BANK0_REORG | BANK1STROBE
      lda BANK0_REORG | BANK0STROBE

   ELSE

      lda BANK0_REORG | BANK0STROBE
      lda BANK0_REORG | BANK1STROBE

   ENDIF

HorizonSunsetColorValues
   
   IF COMPILE_REGION = NTSC

   .byte YELLOW + 14, YELLOW + 12, YELLOW + 14, YELLOW + 12, YELLOW + 14
   .byte YELLOW + 12, YELLOW + 14, LT_RED + 12, YELLOW + 14, LT_RED + 12
   .byte YELLOW + 14, LT_RED + 12, YELLOW + 14, LT_RED + 12, RED + 14
   .byte LT_RED + 12, RED + 14, LT_RED + 12, RED + 14, ORANGE + 12, RED + 14
   .byte ORANGE + 12, RED + 14, ORANGE + 12, DK_PINK + 14, ORANGE + 10
   .byte DK_PINK + 14, ORANGE + 10, DK_PINK + 14, ORANGE + 10, DK_PINK + 12
   .byte ORANGE + 10, BLUE + 10, ORANGE + 10, DK_PINK + 12, ORANGE + 8
   .byte BLUE + 10, ORANGE + 8, DK_PINK + 12, ORANGE + 8, BLUE + 10, ORANGE + 8
   .byte BLUE + 10, ORANGE + 8, BLUE + 10, ORANGE + 6, BLUE + 8, ORANGE + 6
   .byte BLUE + 8, BLUE + 6, BLUE + 8, DK_PINK + 6, BLUE + 6, BLUE + 4, BLUE + 6
   .byte DK_PINK + 6, BLUE + 4, BLUE + 6, BLUE + 4, BLUE + 6, BLUE + 2, BLUE + 4
   .byte BLUE + 2

   ELSE

   .byte BRICK_RED + 14, BRICK_RED + 12, BRICK_RED + 14, BRICK_RED + 12
   .byte BRICK_RED + 14, BRICK_RED + 12, BRICK_RED + 14, BRICK_RED + 12
   .byte BRICK_RED + 14, BRICK_RED + 12, BRICK_RED + 14, BRICK_RED + 12
   .byte BRICK_RED + 14, BRICK_RED + 12, RED + 14, BRICK_RED + 12, RED + 14
   .byte BRICK_RED + 12, RED + 14, DK_PINK + 12, RED + 14, DK_PINK + 12
   .byte RED + 14, DK_PINK + 12, VIOLET + 14, DK_PINK + 10, VIOLET + 14
   .byte DK_PINK + 10, VIOLET + 14, DK_PINK + 10, VIOLET + 12, DK_PINK + 10
   .byte BLUE_CYAN + 10, DK_PINK + 10, VIOLET + 12, DK_PINK + 8, BLUE_CYAN + 10
   .byte DK_PINK + 8, VIOLET + 12, DK_PINK + 8, BLUE_CYAN + 10, DK_PINK + 8
   .byte BLUE_CYAN + 10, DK_PINK + 8, BLUE_CYAN + 10, DK_PINK + 6, BLUE_CYAN + 8
   .byte DK_PINK + 6, BLUE_CYAN + 8, BLUE_CYAN + 6, BLUE_CYAN + 8, VIOLET + 6
   .byte BLUE_CYAN + 6, BLUE_CYAN + 4, BLUE_CYAN + 6, VIOLET + 6, BLUE_CYAN + 4
   .byte BLUE_CYAN + 6, BLUE_CYAN + 4, BLUE_CYAN + 6, BLUE_CYAN + 2, BLUE_CYAN + 4
   .byte BLUE_CYAN + 2

   ENDIF

MountainHillsPF2Graphics
RiverMountainTopPF2Graphics
   .byte $F7 ; |XXXX.XXX|
   .byte $E3 ; |XXX...XX|
   .byte $C1 ; |XX.....X|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MountainTopPF0Graphics
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MountainTopPF1Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
MountainTopPF2Graphics
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|

MushroomHouseGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
    
SmurfAnimationDataPointers_BANK1
   .word NullSprite
   .word NullSpriteColor
   
   .word SmurfSpriteStationary
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_00
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_01
   .word SmurfSpriteColors
   
   .word SmurfSpriteWalking_02
   .word SmurfSpriteColors
   
   .word SmurfSpriteStationary
   .word SmurfSpriteColors
   
   .word SmurfSpriteDucking
   .word SmurfSpriteDuckingColors
   
   .word SmurfSpriteSitting
   .word SmurfSpriteColors
   
   .word SmurfSpriteJumping
   .word SmurfSpriteColors
   
   .word SmurfSpriteKissing
   .word SmurfKissingColors
   
   .word SmurfSpriteDrowning_00
   .word SmurfSpriteColors
   
   .word SmurfSpriteDrowning_01
   .word SmurfSpriteColors
   
   .word SmurfSpriteDrowning_02
   .word SmurfSpriteColors
   
   .word SmurfSpriteDrowning_03
   .word SmurfSpriteColors
   
   .word SmurfSpriteDrowning_04
   .word SmurfSpriteColors

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
   
   .byte $A4,$D3,$A5,$BA,$CF,$E0,$AE,$A2,$A0,$97,$A0,$AF;unused bytes
   
      ELSE
   
   .byte $C6,$AF,$A0,$A0,$D2,$A0,$A0,$CF,$A2,$9E,$A0,$F0;unused bytes
   
      ENDIF
   
   ENDIF

   FILL_BOUNDARY 0, 0

SmurfSpriteColors
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE

MushroomHouseColors

   IF COMPILE_REGION = NTSC

   .byte YELLOW + 12, YELLOW + 12, YELLOW + 12, YELLOW + 12, YELLOW + 12
   .byte YELLOW + 12, YELLOW + 12, YELLOW + 12, YELLOW + 12, YELLOW + 12
   .byte YELLOW + 12, RED + 4, RED + 4, RED + 6, RED + 6, RED + 6, RED + 8
   .byte RED + 6, RED + 8, RED + 8, RED + 8, RED + 8, RED + 8, RED + 8, RED + 6
   .byte RED + 8, RED + 8, RED + 6, RED + 8, RED + 6, RED + 8, RED + 6, RED + 6
   .byte RED + 6, RED + 6, RED + 6, RED + 6, RED + 4, RED + 6, RED + 6, RED + 4
   .byte RED + 6, RED + 4, RED + 6, RED + 4, RED + 4, RED + 4, RED + 2, RED + 4
   .byte RED + 4, RED + 2, RED + 4, RED + 2, RED + 4, RED + 2, RED + 2, RED + 2

   ELSE

   .byte YELLOW + 14, YELLOW + 14, YELLOW + 14, YELLOW + 14, YELLOW + 14
   .byte YELLOW + 14, YELLOW + 14, YELLOW + 14, YELLOW + 14, YELLOW + 14
   .byte YELLOW + 14, RED + 4, RED + 4, RED + 6, RED + 6, RED + 6, RED + 8
   .byte RED + 6, RED + 8, RED + 8, RED + 8, RED + 8, RED + 8, RED + 8, RED + 6
   .byte RED + 8, RED + 8, RED + 6, RED + 8, RED + 6, RED + 8, RED + 6, RED + 6
   .byte RED + 6, RED + 6, RED + 6, RED + 6, RED + 4, RED + 6, RED + 6, RED + 4
   .byte RED + 6, RED + 4, RED + 6, RED + 4, RED + 4, RED + 4, RED + 2, RED + 4
   .byte RED + 4, RED + 2, RED + 4, RED + 2, RED + 4, RED + 2, RED + 2, RED + 2

   ENDIF

GargamelTablePF1Graphics
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
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
GargamelTablePF2Graphics
   .byte $2F ; |..X.XXXX|
   .byte $2F ; |..X.XXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $23 ; |..X...XX|
   .byte $23 ; |..X...XX|
   .byte $F3 ; |XXXX..XX|
   .byte $63 ; |.XX...XX|
   .byte $43 ; |.X....XX|
   .byte $43 ; |.X....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $40 ; |.X......|
   .byte $C0 ; |XX......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
MountainHillsPF0Graphics
RiverMountainTopPF0Graphics
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
MountainHillsPF1Graphics
RiverMountainTopPF1Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
    
SmurfSpriteDrowning_00
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte SPRITE_END
SmurfSpriteDrowning_01
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte SPRITE_END
SmurfSpriteDrowning_02
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte SPRITE_END
SmurfSpriteDrowning_03
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $79 ; |.XXXX..X|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte SPRITE_END
SmurfSpriteDrowning_04
   .byte $1D ; |...XXX.X|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte SPRITE_END

GargamelTableColors
   .byte VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4
   .byte VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4, VIOLET + 4
   .byte VIOLET + 6, VIOLET + 6, VIOLET + 6, VIOLET + 6, VIOLET + 6, VIOLET + 6
   .byte VIOLET + 6, VIOLET + 6
    
MushroomHouseTreeTrunkPF1Graphics
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|

MushroomHouseTreeTrunkPF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|

KernelHeightOffset_BANK1
   .byte 72                         ; ID_ROOM_MUSHROOM_HOUSE
   .byte 73                         ; ID_ROOM_WOODS
   .byte 70                         ; ID_ROOM_RIVER_00
   .byte 47                         ; ID_ROOM_MOUNTAINS
   .byte 51                         ; ID_ROOM_SPIDER_CAVERN
   .byte 70                         ; ID_ROOM_RIVER_01
   .byte 1                          ; ID_ROOM_GARGAMELS_LAB
   
SmurfSpriteOffset_BANK1
   .byte H_SMURF - H_SMURF
   .byte H_SMURF - H_SMURF_STATIONARY
   .byte H_SMURF - H_SMURF_WALKING_00
   .byte H_SMURF - H_SMURF_WALKING_01
   .byte H_SMURF - H_SMURF_WALKING_02
   .byte H_SMURF - H_SMURF_STATIONARY
   .byte H_SMURF - H_SMURF_DUCKING
   .byte H_SMURF - H_SMURF_SITTING
   .byte H_SMURF - H_SMURF_JUMPING
   .byte H_SMURF - H_SMURF_KISSING - 1
   .byte H_SMURF - H_SMURF_DROWNING_00
   .byte H_SMURF - H_SMURF_DROWNING_01
   .byte H_SMURF - H_SMURF_DROWNING_02
   .byte H_SMURF - H_SMURF_DROWNING_03
   .byte H_SMURF - H_SMURF_DROWNING_04

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50

   .byte $A0,$B0,$A0,$84,$A0,$A0,$D8,$A0; unused bytes
   
      ELSE
   
   .byte $A0,$C9,$A0,$80,$A0,$C9,$A0,$CC; unused bytes
   
      ENDIF

   ENDIF
   
   FILL_BOUNDARY 0, 0

SmurfSpriteDuckingColors
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, BLACK

NullSprite
   .byte $00 ; |........|

SmurfSpriteStationary
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $36 ; |..XX.XX.|
   .byte $66 ; |.XX..XX.|
   .byte $6C ; |.XX.XX..|
   .byte $CF ; |XX..XXXX|
   .byte $F7 ; |XXXX.XXX|
   .byte $70 ; |.XXX....|
   .byte SPRITE_END
SmurfSpriteWalking_00
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $1D ; |...XXX.X|
   .byte $1B ; |...XX.XX|
   .byte $FD ; |XXXXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $DC ; |XX.XXX..|
   .byte $BC ; |X.XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $34 ; |..XX.X..|
   .byte $F4 ; |XXXX.X..|
   .byte $C7 ; |XX...XXX|
   .byte $67 ; |.XX..XXX|
   .byte $66 ; |.XX..XX.|
   .byte SPRITE_END
SmurfSpriteWalking_01
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $74 ; |.XXX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $70 ; |.XXX....|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte SPRITE_END
SmurfSpriteWalking_02
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $78 ; |.XXXX...|
   .byte SPRITE_END
SmurfSpriteDucking
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $F8 ; |XXXXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $30 ; |..XX....|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $60 ; |.XX.....|
   .byte $78 ; |.XXXX...|
   .byte SPRITE_END
SmurfSpriteSitting
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $16 ; |...X.XX.|
   .byte $1C ; |...XXX..|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $BC ; |X.XXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $BC ; |X.XXXX..|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte SPRITE_END
SmurfSpriteJumping
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $1C ; |...XXX..|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $BC ; |X.XXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $BC ; |X.XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte SPRITE_END
SmurfSpriteKissing
   .byte $36 ; |..XX.XX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $F8 ; |XXXXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $30 ; |..XX....|
   .byte $9C ; |X..XXX..|
   .byte $D9 ; |XX.XX..X|
   .byte $BF ; |X.XXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $EC ; |XXX.XX..|
   .byte $CC ; |XX..XX..|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte SPRITE_END

NullSpriteColor
   .byte BLACK

BatSprite_00
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $83 ; |X.....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C7 ; |XX...XXX|
   .byte $C7 ; |XX...XXX|
   .byte $6F ; |.XX.XXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $57 ; |.X.X.XXX|
   .byte $3F ; |..XXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $0F ; |....XXXX|
   .byte $05 ; |.....X.X|
   .byte SPRITE_END
BatSprite_01
   .byte $42 ; |.X....X.|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $8F ; |X...XXXX|
   .byte $05 ; |.....X.X|
   .byte SPRITE_END

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50

   .byte $A0,$A0,$B9                ; unused bytes
       
      ELSE
   
   .byte $8A,$A0,$AC                ; unused bytes

      ENDIF
   
   ENDIF

   FILL_BOUNDARY 0, 0

BatSprite_02
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $FF ; |XXXXXXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $81 ; |X......X|
   .byte SPRITE_END

HawkSprite_00
   .byte $01 ; |.......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $67 ; |.XX..XXX|
   .byte $67 ; |.XX..XXX|
   .byte $6F ; |.XX.XXXX|
   .byte $2F ; |..X.XXXX|
   .byte $1E ; |...XXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $26 ; |..X..XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $0A ; |....X.X.|
   .byte $06 ; |.....XX.|
   .byte $04 ; |.....X..|
   .byte SPRITE_END
HawkSprite_01
   .byte $66 ; |.XX..XX.|
   .byte $EF ; |XXX.XXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $26 ; |..X..XX.|
   .byte $6E ; |.XX.XXX.|
   .byte $0A ; |....X.X.|
   .byte $06 ; |.....XX.|
   .byte $04 ; |.....X..|
   .byte SPRITE_END
HawkSprite_02
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $2F ; |..X.XXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte SPRITE_END
    
GargamelLabLedgeColors
   .byte VIOLET + 4, YELLOW + 2, YELLOW + 2, YELLOW + 2, YELLOW + 4
   .byte YELLOW + 4, YELLOW + 4, YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6

GargamelLabLedgeGraphics
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
    
   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

   .byte $B8,$FF,$C8,$A2,$A0,$AA,$D4,$D5,$91,$A0,$A0,$A0,$E8,$A0;unused bytes

      ELSE
   
   .byte $A0,$80,$D2,$A0,$85,$A0,$A0,$D3,$AD,$80,$A0,$A3,$A0,$86;unused bytes
   
      ENDIF
   
   ENDIF
   
   FILL_BOUNDARY 98, 0
    
SmurfetteSprites
   .byte SPRITE_END
   .byte $36 ; |..XX.XX.|
   .byte $12 ; |...X..X.|
   .byte $1B ; |...XX.XX|
   .byte $16 ; |...X.XX.|
   .byte $3C ; |..XXXX..|
   .byte $2C ; |..X.XX..|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $DB ; |XX.XX.XX|
   .byte $B9 ; |X.XXX..X|
   .byte $0C ; |....XX..|
   .byte $0E ; |....XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $5E ; |.X.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
RescuedSmurfetteSprite
   .byte SPRITE_END
   .byte $36 ; |..XX.XX.|
   .byte $12 ; |...X..X.|
   .byte $1B ; |...XX.XX|
   .byte $16 ; |...X.XX.|
   .byte $3C ; |..XXXX..|
   .byte $2C ; |..X.XX..|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7F ; |.XXXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $9B ; |X..XX.XX|
   .byte $39 ; |..XXX..X|
   .byte $1C ; |...XXX..|
   .byte $6E ; |.XX.XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $5E ; |.X.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
    
SmurfetteHairBunGraphics
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, -1, -1, -1, -1
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
    
SmurfetteColors
   .byte BLACK, WHITE, WHITE, WHITE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, WHITE, WHITE, WHITE, WHITE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURFETTE_HAIR, COLOR_SMURFETTE_HAIR, WHITE, WHITE, WHITE, WHITE

SmurfKissingColors
   .byte COLOR_HEART, COLOR_HEART, COLOR_HEART, COLOR_HEART, COLOR_HEART, COLOR_HEART
   .byte BLACK, BLACK, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE
   .byte COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, COLOR_SMURF_BLUE, WHITE, WHITE
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE

FenceGraphic
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $B0 ; |X.XX....|
   .byte $99 ; |X..XX..X|
   .byte $8D ; |X...XX.X|
   .byte $87 ; |X....XXX|
   .byte $83 ; |X.....XX|
   .byte $C1 ; |XX.....X|
   .byte $E1 ; |XXX....X|
   .byte $B1 ; |X.XX...X|
   .byte $99 ; |X..XX..X|
   .byte $8D ; |X...XX.X|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte SPRITE_END
    
GargarmelLabFloorColors
   .byte COLOR_LAB_FLOOR + 6, COLOR_LAB_FLOOR + 6, COLOR_LAB_FLOOR + 6
   .byte COLOR_LAB_FLOOR + 6, COLOR_LAB_FLOOR + 6, COLOR_LAB_FLOOR + 6
   .byte BLACK, COLOR_LAB_FLOOR + 4, COLOR_LAB_FLOOR + 4, COLOR_LAB_FLOOR + 4
   .byte COLOR_LAB_FLOOR + 4, COLOR_LAB_FLOOR + 4, BLACK, COLOR_LAB_FLOOR + 2
   .byte COLOR_LAB_FLOOR + 2, COLOR_LAB_FLOOR + 2

LeftSpiderWebGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $0E ; |....XXX.|
   .byte $0C ; |....XX..|
   .byte $1E ; |...XXXX.|
   .byte $13 ; |...X..XX|
   .byte $31 ; |..XX...X|
   .byte $23 ; |..X...XX|
   .byte $62 ; |.XX...X.|
   .byte $46 ; |.X...XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $23 ; |..X...XX|
   .byte $31 ; |..XX...X|
   .byte $13 ; |...X..XX|
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $0E ; |....XXX.|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
CenterSpiderWebGraphic
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $D6 ; |XX.X.XX.|
   .byte $93 ; |X..X..XX|
   .byte $11 ; |...X...X|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $D7 ; |XX.X.XXX|
   .byte $93 ; |X..X..XX|
   .byte $D7 ; |XX.X.XXX|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $D7 ; |XX.X.XXX|
   .byte $93 ; |X..X..XX|
   .byte $D7 ; |XX.X.XXX|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $11 ; |...X...X|
   .byte $93 ; |X..X..XX|
   .byte $D6 ; |XX.X.XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
RightSpiderWebGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $60 ; |.XX.....|
   .byte $F0 ; |XXXX....|
   .byte $90 ; |X..X....|
   .byte $18 ; |...XX...|
   .byte $88 ; |X...X...|
   .byte $8C ; |X...XX..|
   .byte $C4 ; |XX...X..|
   .byte $FE ; |XXXXXXX.|
   .byte $C4 ; |XX...X..|
   .byte $8C ; |X...XX..|
   .byte $88 ; |X...X...|
   .byte $18 ; |...XX...|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
   .byte $60 ; |.XX.....|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

SpiderSprite_00
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $92 ; |X..X..X.|
   .byte $BA ; |X.XXX.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $92 ; |X..X..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $28 ; |..X.X...|
   .byte SPRITE_END
SpiderSprite_01
   .byte $44 ; |.X...X..|
   .byte $92 ; |X..X..X.|
   .byte $BA ; |X.XXX.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $92 ; |X..X..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $44 ; |.X...X..|
   .byte SPRITE_END
SpiderSprite_02
   .byte $28 ; |..X.X...|
   .byte $54 ; |.X.X.X..|
   .byte $BA ; |X.XXX.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $92 ; |X..X..X.|
   .byte $AA ; |X.X.X.X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte SPRITE_END
SpiderCavernTopLeftPF0Graphics
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
SpiderCavernTopLeftPF1Graphics
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $9B ; |X..XX.XX|
   .byte $9A ; |X..XX.X.|
   .byte $9A ; |X..XX.X.|
   .byte $9A ; |X..XX.X.|
   .byte $9A ; |X..XX.X.|
   .byte $9A ; |X..XX.X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
SpiderCavernTopLeftPF2Graphics
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $CE ; |XX..XXX.|
   .byte $CE ; |XX..XXX.|
   .byte $CE ; |XX..XXX.|
   .byte $CE ; |XX..XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C4 ; |XX...X..|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
SpiderCavernTopRightPF0Graphics
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
SpiderCavernTopRightPF1Graphics
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $BC ; |X.XXXX..|
   .byte $B8 ; |X.XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
SpiderCavernTopRightPF2Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
SpiderCavernBottomLeftPF0Graphics
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
SpiderCavernBottomLeftPF1Graphics
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $58 ; |.X.XX...|
   .byte $DA ; |XX.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $FA ; |XXXXX.X.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
SpiderCavernBottomLeftPF2Graphics
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
SpiderCavernBottomRightPF0Graphics
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
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
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
SpiderCavernBottomRightPF1Graphics
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
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
SpiderCavernBottomRightPF2Graphics
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $34 ; |..XX.X..|
   .byte $3C ; |..XXXX..|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
SpiderCavernStairGraphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|

SnakeSprite_00
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $C8 ; |XX..X...|
   .byte $38 ; |..XXX...|
   .byte $08 ; |....X...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $60 ; |.XX.....|
   .byte $C0 ; |XX......|
   .byte $98 ; |X..XX...|
   .byte $BC ; |X.XXXX..|
   .byte $E4 ; |XXX..X..|
   .byte $44 ; |.X...X..|
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
SnakeSprite_01
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $90 ; |X..X....|
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $60 ; |.XX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $DC ; |XX.XXX..|
   .byte $76 ; |.XXX.XX.|
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
SnakeSprite_02
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $60 ; |.XX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $C1 ; |XX.....X|
   .byte $7F ; |.XXXXXXX|
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

SpiderCavernBackgroundColors
   .byte DK_PINK + 12, DK_PINK + 12, DK_PINK + 10, DK_PINK + 10, DK_PINK + 12
   .byte DK_PINK + 10, DK_PINK + 10, DK_PINK + 10, DK_PINK + 8,  DK_PINK + 10
   .byte DK_PINK + 10, DK_PINK + 8,  DK_PINK + 10, DK_PINK + 8,  DK_PINK + 10
   .byte DK_PINK + 8,  DK_PINK + 8,  DK_PINK + 10, DK_PINK + 8,  DK_PINK + 8
   .byte DK_PINK + 8,  DK_PINK + 6,  DK_PINK + 8,  DK_PINK + 8,  DK_PINK + 6
   .byte DK_PINK + 8,  DK_PINK + 6,  DK_PINK + 8,  DK_PINK + 6,  DK_PINK + 6
   .byte DK_PINK + 8,  DK_PINK + 6,  DK_PINK + 6,  DK_PINK + 6,  DK_PINK + 4
   .byte DK_PINK + 6,  DK_PINK + 6,  DK_PINK + 4,  DK_PINK + 6,  DK_PINK + 4
   .byte DK_PINK + 6,  DK_PINK + 4,  DK_PINK + 4,  DK_PINK + 6,  DK_PINK + 4
   .byte DK_PINK + 4,  DK_PINK + 4,  DK_PINK + 2,  DK_PINK + 4,  DK_PINK + 4
   .byte DK_PINK + 2,  DK_PINK + 4,  DK_PINK + 2,  DK_PINK + 4,  DK_PINK + 2
   .byte DK_PINK + 2,  DK_PINK + 4,  DK_PINK + 2,  DK_PINK + 2,  DK_PINK + 2
   .byte DK_PINK,      DK_PINK + 2,  DK_PINK,      DK_PINK + 2,  DK_PINK
   .byte DK_PINK,      DK_PINK + 2

CloudGraphic_00
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
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $77 ; |.XXX.XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
CloudGraphic_01
   .byte $00 ; |........|
   .byte $06 ; |.....XX.|
   .byte $6F ; |.XX.XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1E ; |...XXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|

PositionGRP0Horizontally_BANK1 SUBROUTINE
   ldy #<[RESP0 - RESP0]      ; 2
PositionObjectHorizontally_BANK1
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
   sta RESP0,y                ; 5         set coarse position value
   sta WSYNC
;--------------------------------------
   sta HMP0,y                 ; 5
   iny                        ; 2
   rts                        ; 6

DetermineDisplayKernel
   lda screenTransitionTimer        ; get screen transition time value
   bne DrawTransitionScreenKernel   ; branch if showing screen transition
   lda currentRoomNumber            ; get current room number
   asl                              ; multiply value by 2
   tay
   lda GameKernelRoutineTable + 1,y ; get kernel routine MSB value
   pha                              ; push game kernel MSB to stack
   lda GameKernelRoutineTable,y     ; get kernel routine LSB value
   pha                              ; push game kernel LSB to stack
   rts                              ; jump to game kernel

GameKernelRoutineTable
   .word MushroomHouseDisplayKernel - 1
   .word StartWoodsDisplayKernel - 1
   .word RiverRoomDisplayKernel - 1
   .word MountainsDisplayKernel - 1
   .word SpiderCavernDisplayKernel - 1
   .word RiverRoomDisplayKernel - 1
   .word GargamelLabDisplayKernel - 1

DrawTransitionScreenKernel
   dec screenTransitionTimer        ; decrement screen transition timer
   ldx #H_KERNEL
   ldy currentRoomNumber            ; get current room number
   beq .drawTransitionScreenKernel  ; branch if ID_ROOM_MUSHROOM_HOUSE
   cpy #ID_ROOM_WOODS
   beq .drawTransitionScreenKernel  ; branch if ID_ROOM_WOODS
   ldx #H_KERNEL
.drawTransitionScreenKernel
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .drawTransitionScreenKernel;2³ + 1
   ldy #OVERSCAN_TIME_SCREEN_TRANSITION;2
   jmp SetTimerForOverscanTime; 3

HorizPositionSmurfAndObstacle_BANK1
   lda smurfHorizPosition     ; 3         get Smurf horizontal position
   jsr PositionGRP0Horizontally_BANK1;6   horizontally position Smurf
;--------------------------------------
   lda smurfAttributes        ; 3         get Smurf attribute values
   sta REFP0                  ; 3 = @19
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @24
   sta NUSIZ1                 ; 3 = @27
   lda roomObjectHorizPosition; 3
   jsr PositionObjectHorizontally_BANK1;6        
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda roomObstacleAttributes ; 3
   sta REFP1                  ; 3 = @09
SetSmurfAnimationDataPointerValues SUBROUTINE
   ldx smurfAnimationIndex    ; 3
   inx                        ; 2
   txa                        ; 2
   asl                        ; 2
   asl                        ; 2
   tay                        ; 2
   dey                        ; 2
   ldx #3                     ; 2
.setSmurfAnimationDataPointerValues
   lda SmurfAnimationDataPointers_BANK1,y;4
   sta smurfGraphicPointer,x  ; 4
   dey                        ; 2
   dex                        ; 2
   bpl .setSmurfAnimationDataPointerValues;2³
   sta WSYNC
;--------------------------------------
   sta CXCLR                  ; 3 = @03   clear all collision registers
   ldx currentRoomNumber      ; 3         get current room number
   lda smurfVertPosition      ; 3         get Smurf vertical position
   clc                        ; 2
   adc KernelHeightOffset_BANK1,x;4       increment by kernel height
   sec                        ; 2
   ldy smurfAnimationIndex    ; 3
   sbc SmurfSpriteOffset_BANK1,y;4        subtract sprite height for offset
   bmi .setSmurfSkipDrawIdx   ; 2³
   cmp #H_SMURF - 5           ; 2
   bcc .setSmurfSkipDrawIdx   ; 2³
   lda #H_SMURF - 5           ; 2
.setSmurfSkipDrawIdx
   tay                        ; 2
   rts                        ; 6 = @40

DrawSmurfKernel
.drawSmurfKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextSmurfScanline     ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextSmurfScanline     ; 2³
   dey                        ; 2
.nextSmurfScanline
   dex                        ; 2
   bpl .drawSmurfKernel       ; 2³
   rts                        ; 6

DrawSmurfAndRoomObstacleKernel
.drawSmurfAndRoomObstacleKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   inc roomObstacleGraphicIndex;5
   bmi .drawSmurf             ; 2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @32
   bne .getSmurfGraphicIndex  ; 2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndex
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurf
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextSmurfAndRoomObstacleScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextSmurfAndRoomObstacleScanline;2³
   dey                        ; 2
.nextSmurfAndRoomObstacleScanline
   dex                        ; 2
   bpl .drawSmurfAndRoomObstacleKernel;2³
   rts                        ; 6

SpiderCavernDisplayKernel SUBROUTINE
   lda #HORIZ_SPIDER_WEB      ; 2
   jsr PositionGRP0Horizontally_BANK1;6   position left spiderweb graphic
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   lda #HORIZ_SPIDER_WEB + 8  ; 2
   jsr PositionObjectHorizontally_BANK1;6 position right spiderweb graphic
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   ldx #TWO_COPIES            ; 2
   stx NUSIZ0                 ; 3 = @08
   dex                        ; 2         x = 0 (i.e. ONE_COPY)
   stx NUSIZ1                 ; 3 = @13
   lda #PF_PRIORITY           ; 2
   sta CTRLPF                 ; 3 = @18
   lda #BLACK + 8             ; 2
   sta COLUBK                 ; 3 = @23
   lda #VIOLET + 4            ; 2
   sta COLUPF                 ; 3 = @28
   ldx #18                    ; 2
.drawTopSpiderCavern
   sta WSYNC
;--------------------------------------
   lda SpiderCavernTopLeftPF0Graphics,x;4
   sta PF0                    ; 3 = @07
   lda SpiderCavernTopLeftPF1Graphics,x;4
   sta PF1                    ; 3 = @14
   lda SpiderCavernTopLeftPF2Graphics,x;4
   sta PF2                    ; 3 = @21
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   lda SpiderCavernTopRightPF0Graphics,x;4
   sta PF0                    ; 3 = @35
   lda SpiderCavernTopRightPF1Graphics,x;4
   sta PF1                    ; 3 = @42
   lda SpiderCavernTopRightPF2Graphics,x;4
   sta PF2                    ; 3 = @49
   dex                        ; 2
   bpl .drawTopSpiderCavern   ; 2³
   ldx #DK_PINK               ; 2
   stx COLUBK                 ; 3
   ldx #31                    ; 2
.drawSpiderWebKernel
   lda SpiderCavernBottomLeftPF0Graphics,x;4
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   lda SpiderCavernBottomLeftPF1Graphics,x;4
   sta PF1                    ; 3 = @10
   lda SpiderCavernBottomLeftPF2Graphics,x;4
   sta PF2                    ; 3 = @17
   lda LeftSpiderWebGraphic,x ; 4
   sta GRP0                   ; 3 = @24
   lda CenterSpiderWebGraphic,x;4
   sta GRP1                   ; 3 = @31
   lda SpiderCavernBottomRightPF0Graphics,x;4
   sta PF0                    ; 3 = @38
   SLEEP 2                    ; 2
   lda RightSpiderWebGraphic,x; 4
   sta GRP0                   ; 3 = @47
   lda SpiderCavernBottomRightPF1Graphics,x;4
   sta PF1                    ; 3 = @54
   lda SpiderCavernBottomRightPF2Graphics,x;4
   sta PF2                    ; 3 = @61
   dex                        ; 2
   bpl .drawSpiderWebKernel   ; 2³ + 1
   bmi .doneDrawSpiderWebKernel;3         unconditional branch

.skipSpiderDrawSection_00
   lda roomObstacleGraphicIndex;3
   cmp #<-1                   ; 2
   bne .drawSmurfGraphicSection_00;2³
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3 = @38
   beq .drawSmurfGraphicSection_00;3      unconditional branch

.skipSpiderDraw
   lda roomObstacleGraphicIndex;3 = @32
   cmp #<-1                   ; 2
   bne .drawSmurfGraphic      ; 2³
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3 = @41
   beq .drawSmurfGraphic      ; 3         unconditional branch

.doneDrawSpiderWebKernel
   sta HMCLR                  ; 3 = @71
   lda smurfHorizPosition     ; 3         get Smurf horizontal position
   jsr PositionGRP0Horizontally_BANK1;6
;--------------------------------------
   lda smurfAttributes        ; 3         get Smurf attribute values
   sta REFP0                  ; 3 = @19
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @24
   sta NUSIZ1                 ; 3 = @27
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   jsr SetSmurfAnimationDataPointerValues;6
   ldx #12                    ; 2
   lda #0                     ; 2
.drawSpiderCavernKernelSection_00
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda SpiderCavernBackgroundColors + 54,x;4
   sta COLUBK                 ; 3 = @18
   inc roomObstacleGraphicIndex;5
   bmi .skipSpiderDrawSection_00;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @39
   bne .getSmurfGraphicIndexSection_00;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexSection_00
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGraphicSection_00
   lda #0                     ; 2
   iny                        ; 2         increment Smurf graphic index value
   bmi .nextSpiderCavernSection_00;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextSpiderCavernSection_00;2³
   dey                        ; 2
.nextSpiderCavernSection_00
   dex                        ; 2
   bpl .drawSpiderCavernKernelSection_00;2³
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #MSBL_SIZE1 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @16
   lda #0                     ; 2
   sta PF2                    ; 3 = @21
   inc roomObstacleGraphicIndex;5
   bmi .skipSpiderDraw        ; 2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @42
   bne .getSmurfGraphicIndex  ; 2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndex
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGraphic
   lda #0                     ; 2
   iny                        ; 2
   bmi ColorSpiderCavernBackground;2³
   lda (smurfGraphicPointer),y; 5
   bne ColorSpiderCavernBackground;2³
   dey                        ; 2    
ColorSpiderCavernBackground SUBROUTINE
   ldx #53                    ; 2
.colorSpiderCavernBackground
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda SpiderCavernBackgroundColors,x;4
   sta COLUBK                 ; 3 = @18
   inc roomObstacleGraphicIndex;5
   bmi .skipSpiderDraw        ; 2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @39
   bne .getSmurfGraphicIndex  ; 2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndex
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGraphic
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextScanlineColorSpiderCavernBackground;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextScanlineColorSpiderCavernBackground;2³
   dey                        ; 2
.nextScanlineColorSpiderCavernBackground
   dex                        ; 2
   bpl .colorSpiderCavernBackground;2³
   bmi .doneColorSpiderCavernBackground;2³ + 1 unconditional branch

.skipSpiderDraw
   lda roomObstacleGraphicIndex;3
   cmp #<-1                   ; 2
   bne .drawSmurfGraphic      ; 2³
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3 = @38
   beq .drawSmurfGraphic      ; 3         unconditional branch

.skipSpiderDrawCavernBackground
   lda roomObstacleGraphicIndex;3
   cmp #<-1                   ; 2
   bne .drawSmurfGraphicCavernBackground;2³ + 1
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3
   beq .drawSmurfGraphicCavernBackground;4 unconditional branch crosses page

.skipDrawObstacleSpiderStairKernel
   lda roomObstacleGraphicIndex;3 = @30
   cmp #<-1                   ; 2
   bne .drawSmurfSpiderCavernStairKernel;2³ + 1
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3 = @39
   beq .drawSmurfSpiderCavernStairKernel;4 unconditional branch crosses page

.doneColorSpiderCavernBackground
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @16
   lda #$F8                   ; 2
   sta PF1                    ; 3 = @21
   inc roomObstacleGraphicIndex;5
   bmi .skipSpiderDrawCavernBackground;2³ + 1
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @42
   bne .getSmurfGraphicIndexCavernBackground;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexCavernBackground
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGraphicCavernBackground
   lda #0                     ; 2
   iny                        ; 2
   bmi DrawSpiderCavernStairsKernel;2³
   lda (smurfGraphicPointer),y; 5
   bne DrawSpiderCavernStairsKernel;2³
   dey                        ; 2
DrawSpiderCavernStairsKernel
   ldx #23                    ; 2
.drawSpiderCavernStairsKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda SpiderCavernStairGraphics,x;4
   sta PF1                    ; 3 = @18
   inc roomObstacleGraphicIndex;5
   bmi .skipDrawObstacleSpiderStairKernel;2³ + 1
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @39
   bne .getSmurfGraphicIndexSpiderCavernStairSection;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexSpiderCavernStairSection
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfSpiderCavernStairKernel
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextSpiderCavernStairScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextSpiderCavernStairScanline;2³
   dey                        ; 2
.nextSpiderCavernStairScanline
   dex                        ; 2
   bpl .drawSpiderCavernStairsKernel;2³
   inx                        ; 2
   stx PF1                    ; 3 = @73
   stx PF0                    ; 3 = @76
;--------------------------------------
   stx GRP0                   ; 3 = @03
   ldx #VIOLET + 4            ; 2
   stx COLUBK                 ; 3 = @08
   ldy #OVERSCAN_TIME - 1     ; 2
SetTimerForOverscanTime
   sta WSYNC
;--------------------------------------

   IF COMPILE_REGION = PAL60

      sta WSYNC                     ; force even scan line count for PAL60

   ENDIF

   sty TIM64T                 ; 4
   jmp JumpToCurrentGameStateRoutine_BANK1;3

MushroomHouseDisplayKernel
   ldy tmpSmurfSkipDrawIdx    ; 3
   lda #0                     ; 2
   ldx #56                    ; 2
.drawMushroomHouseTopKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   SLEEP_12                   ; 12
   SLEEP 2                    ; 2
   lda MushroomHouseGraphic + 20,x;4
   sta GRP1                   ; 3 = @32
   lda MushroomHouseColors,x  ; 4
   sta COLUP1                 ; 3 = @39
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextMushroomTopScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextMushroomTopScanline;2³
   dey                        ; 2
.nextMushroomTopScanline
   dex                        ; 2
   bpl .drawMushroomHouseTopKernel;2³
   ldx #7                     ; 2
.drawMushroomHouseTreeTrunkKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #GREEN + 4             ; 2
   sta COLUBK                 ; 3 = @16
   lda MushroomHouseGraphic + 12,x;4
   sta GRP1                   ; 3 = @23
   lda MushroomHouseTreeTrunkPF1Graphics,x;4
   sta PF1                    ; 3 = @30
   lda MushroomHouseTreeTrunkPF2Graphics,x;4
   sta PF2                    ; 3 = @37
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextMushroomHouseTreeTrunkScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextMushroomHouseTreeTrunkScanline;2³
   dey                        ; 2
.nextMushroomHouseTreeTrunkScanline
   dex                        ; 2
   bpl .drawMushroomHouseTreeTrunkKernel;2³
   ldx #0                     ; 2
   stx PF1                    ; 3 = @61
   stx PF0                    ; 3 = @64
   ldx #11                    ; 2
.drawMushroomHouseBottomKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @16
   SLEEP_6                    ; 6
   SLEEP 2                    ; 2
   lda MushroomHouseGraphic,x ; 4
   sta GRP1                   ; 3 = @31
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextMushroomHouseBottomScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextMushroomHouseBottomScanline;2³
   dey                        ; 2
.nextMushroomHouseBottomScanline
   dex                        ; 2
   bpl .drawMushroomHouseBottomKernel;2³
   inx                        ; 2         x = 0
   stx GRP1                   ; 3 = @65
   ldy #GREEN + 6             ; 2
   sty WSYNC
;--------------------------------------
   sty COLUBK                 ; 3 = @03
   ldy #OVERSCAN_TIME         ; 2
   jmp SetTimerForOverscanTime; 3

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

   .byte $AE,$89,$B0,$A0,$B0,$A0,$D5,$A5,$D2 ; unused bytes
   
      ELSE

   .byte $D5,$A0,$9F,$D3,$85,$A0,$CD,$C5,$F0 ; unused bytes

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

FenceRoomDisplayKernel SUBROUTINE
.skipObstacleDrawBackgroundLayer_00
   SLEEP_12                   ; 12
   SLEEP_6                    ; 6
   SLEEP 2                    ; 2
   jmp .drawSmurfBackgroundLayer_00;3

.skipDoneObstacleDrawBackgroundLayer_00
   ldy tmpSmurfGraphicIdx | $100;4
   jmp .drawSmurfBackgroundLayer_00;3

StartWoodsDisplayKernel
   ldy tmpSmurfSkipDrawIdx    ; 3
   lda #0                     ; 2
   ldx #56                    ; 2
.drawWoodsKernelBackgroundLayer_00
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   inc roomObstacleGraphicIndex;5
   bmi .skipObstacleDrawBackgroundLayer_00;2³ branch to not draw obstacle
   sty tmpSmurfGraphicIdx     ; 3         set Smurf graphic index value
   ldy roomObstacleGraphicIndex;3         get room obstacle graphic index value
   lda (roomObstacleGraphicPointer),y;5   get graphic data for room obstacle
   sta GRP1                   ; 3 = @32
   bne .skipDoneObstacleDrawBackgroundLayer_00;2³
   dec roomObstacleGraphicIndex;5         decrement room obstacle graphic index
   ldy tmpSmurfGraphicIdx     ; 3         get Smurf graphic index value
.drawSmurfBackgroundLayer_00
   lda #0                     ; 2
   iny                        ; 2         increment Smurf graphic index value
   bmi .nextScanlineBackgroundLayer_00; 2³ branch if not drawing Smurf graphic
   lda (smurfGraphicPointer),y; 5         get Smurf graphic data
   bne .nextScanlineBackgroundLayer_00;2³
   dey                        ; 2
.nextScanlineBackgroundLayer_00
   dex                        ; 2
   bpl .drawWoodsKernelBackgroundLayer_00;2³
   SLEEP_5                    ; 5
   ldx #GREEN + 4             ; 2
   stx COLUBK                 ; 3 = @71
   ldx #3                     ; 2
.drawWoodsKernelBackgroundLayer_01
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #$81                   ; 2
   sta PF1                    ; 3 = @16
   lda #$01                   ; 2
   sta PF2                    ; 3 = @21
   inc roomObstacleGraphicIndex;5
   bmi .drawSmurfBackgroundLayer_01;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @42
   bne .getSmurfGraphicIndex  ; 2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndex
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfBackgroundLayer_01
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextScanlineBackgroundLayer_01;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextScanlineBackgroundLayer_01;2³
   dey                        ; 2
.nextScanlineBackgroundLayer_01
   dex                        ; 2
   bpl .drawWoodsKernelBackgroundLayer_01;2³
   ldx #3                     ; 2
.drawWoodsKernelBackgroundLayer_02
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #$80                   ; 2
   sta PF1                    ; 3 = @16
   lda #0                     ; 2
   sta PF2                    ; 3 = @21
   inc roomObstacleGraphicIndex;5
   bmi .skipObstacleDrawBackgroundLayer_02;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @42
   bne .skipDoneObstacleDrawBackgroundLayer_02;2³
   dec roomObstacleGraphicIndex;5
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfBackgroundLayer_02
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextScanlineBackgroundLayer_02;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextScanlineBackgroundLayer_02;2³
   dey                        ; 2
.nextScanlineBackgroundLayer_02
   dex                        ; 2
   bpl .drawWoodsKernelBackgroundLayer_02;2³
   ldx #0                     ; 2
   stx PF0                    ; 3 = @76
;--------------------------------------
   stx PF1                    ; 3 = @03
   stx COLUBK                 ; 3 = @06
   ldx #10                    ; 2
   jsr DrawSmurfAndRoomObstacleKernel;6
   ldy #GREEN + 6             ; 2
   stx WSYNC
;--------------------------------------
   sty COLUBK                 ; 3 = @03
   ldy #OVERSCAN_TIME         ; 2
   jmp SetTimerForOverscanTime; 3

.skipObstacleDrawBackgroundLayer_02
   SLEEP_12                   ; 12
   SLEEP_6                    ; 6
   SLEEP 2                    ; 2
   jmp .drawSmurfBackgroundLayer_02;3

.skipDoneObstacleDrawBackgroundLayer_02
   ldy tmpSmurfGraphicIdx | $100;4
   jmp .drawSmurfBackgroundLayer_02;3

RiverRoomDisplayKernel
   lda cloudHorizontalPosition;3        
   jsr PositionGRP0Horizontally_BANK1;6
;--------------------------------------
   ldx #WHITE                 ; 2
   stx COLUP0                 ; 3 = @18
   stx COLUP1                 ; 3 = @21
   ldx #MSBL_SIZE1 | ONE_COPY ; 2
   stx NUSIZ0                 ; 3 = @26
   stx NUSIZ1                 ; 3 = @29
   lda cloudHorizontalPosition; 3         get Clouds horizontal position
   clc                        ; 2
   adc #8                     ; 2         increment by 8 for next set of Clouds
   cmp #XMAX + 1              ; 2
   bcc .horizontallyPositionSecondCloud;2³
   sec                        ; 2         not needed...carry already set
   sbc #XMAX + 1              ; 2
.horizontallyPositionSecondCloud
   jsr PositionObjectHorizontally_BANK1;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #MSBL_SIZE1 | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @08
   ldy #H_SUNSET_COLORS - 1   ; 2
   ldx #GREEN + 4             ; 2
   stx COLUPF                 ; 3 = @15
.colorTopHorizon
   lda HorizonSunsetColorValues,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   dey                        ; 2
   cpy #H_SUNSET_COLORS - 12  ; 2
   bne .colorTopHorizon       ; 2³
   ldx #H_CLOUDS - 1          ; 2
.drawClouds
   lda HorizonSunsetColorValues,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda CloudGraphic_00,x      ; 4
   sta GRP0                   ; 3 = @10
   lda CloudGraphic_01,x      ; 4
   sta GRP1                   ; 3 = @17
   dey                        ; 2
   dex                        ; 2
   bpl .drawClouds            ; 2³
.drawUnderCloudHorizonColors
   lda HorizonSunsetColorValues,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   dey                        ; 2
   cpy #H_SUNSET_COLORS - 53  ; 2
   bne .drawUnderCloudHorizonColors;2³
.drawRiverMountainTops
   lda HorizonSunsetColorValues,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda RiverMountainTopPF0Graphics,y;4
   sta PF0                    ; 3 = @10
   lda RiverMountainTopPF1Graphics,y;4
   sta PF1                    ; 3 = @17
   lda RiverMountainTopPF2Graphics,y;4
   sta PF2                    ; 3 = @24
   dey                        ; 2
   bpl .drawRiverMountainTops ; 2³
   sta WSYNC
;--------------------------------------
   ldx #GREEN + 4             ; 2
   stx COLUBK                 ; 3 = @05
   jsr HorizPositionSmurfAndObstacle_BANK1;6
;--------------------------------------
   lda #0                     ; 2
   sta PF1                    ; 3 = @45       
   sta PF0                    ; 3 = @48
   sta PF2                    ; 3 = @52
   sta COLUP1                 ; 3 = @55
   ldx #COLOR_RIVER           ; 2
   stx COLUPF                 ; 3 = @60   color the river
   ldx #H_DRAW_RIVER_ROOM_KERNEL;2
   jsr DrawSmurfKernel        ; 6
.drawRiverRoomDisplayKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda #GREEN + 10            ; 2
   sta COLUBK                 ; 3 = @08
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @16
   lda #0                     ; 2
   sta PF0                    ; 3 = @21
   lda #$80                   ; 2
   sta PF2                    ; 3 = @26
   lda #$F0                   ; 2
   sta PF0                    ; 3 = @31
   SLEEP_12                   ; 12
   SLEEP 2                    ; 2
   lda #0                     ; 2
   sta PF2                    ; 3 = @50
   iny                        ; 2
   bmi .nextRiverRoomScanline ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverRoomScanline ; 2³
   dey                        ; 2
.nextRiverRoomScanline
   dex                        ; 2
   bpl .drawRiverRoomDisplayKernel;2³
.drawRiverSection_00
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$80                   ; 2
   sta PF2                    ; 3 = @24
   lda #$F0                   ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_00   ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_00   ; 2³
   dey                        ; 2
.nextRiverSection_00
   dec riverHeightSection_00  ; 5
   bpl .drawRiverSection_00   ; 2³
.drawRiverSection_01
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$C0                   ; 2
   sta PF2                    ; 3 = @24
   lda #$70                   ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_01   ; 2²
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_01   ; 2³
   dey                        ; 2
.nextRiverSection_01
   dec riverHeightSection_01  ; 5
   bpl .drawRiverSection_01   ; 2³
.drawRiverSection_02
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$E0                   ; 2
   sta PF2                    ; 3 = @24
   lda #$30                   ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_02   ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_02   ; 2³
   dey                        ; 2
.nextRiverSection_02
   dec riverHeightSection_02  ; 5
   bpl .drawRiverSection_02   ; 2³
.drawRiverSection_03
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$F0                   ; 2
   sta PF2                    ; 3 = @24
   lda #$10                   ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_03   ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_03   ; 2³
   dey                        ; 2
.nextRiverSection_03
   dec riverHeightSection_03  ; 5
   bpl .drawRiverSection_03   ; 2³
.drawRiverSection_04
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$F8                   ; 2
   sta PF2                    ; 3 = @24
   lda #0                     ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_04   ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_04   ; 2³
   dey                        ; 2
.nextRiverSection_04
   dec riverHeightSection_04  ; 5
   bpl .drawRiverSection_04   ; 2³
.drawRiverSection_05
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   ldx #0                     ; 2
   stx PF0                    ; 3 = @16
   sty tmpSmurfGraphicIdx     ; 3
   lda #$7C                   ; 2
   sta PF2                    ; 3 = @24
   lda #0                     ; 2
   sta PF0                    ; 3 = @29
   inc roomObstacleGraphicIndex;5
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @45
   ldy tmpSmurfGraphicIdx     ; 3
   stx PF2                    ; 3 = @51
   iny                        ; 2
   bmi .nextRiverSection_05   ; 2³
   lda (smurfGraphicPointer),y; 5
   bne .nextRiverSection_05   ; 2³
   dey                        ; 2
.nextRiverSection_05
   dec riverHeightSection_05  ; 5
   bpl .drawRiverSection_05   ; 2³
   lda #COLOR_RIVER           ; 2
   sta WSYNC
;--------------------------------------
   stx PF2                    ; 3 = @03
   stx PF1                    ; 3 = @06
   stx PF0                    ; 3 = @09
   stx GRP0                   ; 3 = @12
   stx GRP1                   ; 3 = @15
   sta COLUBK                 ; 3 = @18
   ldy #OVERSCAN_TIME - 6     ; 2
   jmp SetTimerForOverscanTime; 3

MountainsDisplayKernel SUBROUTINE
   jsr HorizPositionSmurfAndObstacle_BANK1;6
;--------------------------------------
   sty tmpSmurfSkipDrawIdx    ; 3
   lda #MSBL_SIZE1 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @48
   lda #BLACK                 ; 2
   sta COLUP1                 ; 3 = @53
   ldy #46                    ; 2
   ldx #GREEN + 4             ; 2
   stx COLUPF                 ; 3 = @60
.colorMountainsHorizon
   lda HorizonSunsetColorValues + 16,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   dey                        ; 2
   cpy #46 - 11               ; 2
   bne .colorMountainsHorizon ; 2³
   ldx #8                     ; 2
.drawMountainTopGraphics
   lda HorizonSunsetColorValues + 16,y;4
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda MountainTopPF0Graphics,x;4
   sta PF0                    ; 3 = @10
   lda MountainTopPF1Graphics,x;4
   sta PF1                    ; 3 = @17
   lda MountainTopPF2Graphics,x;4
   sta PF2                    ; 3 = @24
   dey                        ; 2
   bmi .doneDrawMountainTopGraphics;2³
   tya                        ; 2
   and #3                     ; 2
   cmp #3                     ; 2
   bne .drawMountainTopGraphics;2³
   dex                        ; 2
   bpl .drawMountainTopGraphics;2³
.doneDrawMountainTopGraphics
   lda #GREEN + 4             ; 2
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda #0                     ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   lda #GREEN + 10            ; 2
   sta COLUPF                 ; 3 = @19
   lda #MSBL_SIZE1 | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @24
   ldy tmpSmurfSkipDrawIdx    ; 3
   ldx #66                    ; 2
   jsr DrawSmurfAndRoomObstacleKernel;6
   jmp DrawMountainsKernelBackgroundLayers;3

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50
   
   .byte $A0,$B1,$A0,$EF,$A0,$A0,$D3,$A0,$99,$BB,$E5,$C5,$A0,$FF,$A0
   .byte $C0,$B2,$E9,$BA,$C5,$B0,$A0,$EE,$AE,$F0,$BA,$B7,$B0,$A0,$A0

      ELSE
   
   .byte $CF,$A0,$D3,$A0,$C0,$B2,$A5,$D5,$A0,$CF,$A0,$9E,$A0,$F0,$BA
   .byte $A0,$D5,$A0,$A9,$A0,$85,$A0,$C5,$D2,$A0,$8A,$A0,$A8,$D3,$C8

      ENDIF
   
   ENDIF

   FILL_BOUNDARY 55, 0

.skipObstacleDrawBackgroundLayer_00
   SLEEP_12                   ; 12
   SLEEP_6                    ; 6
   SLEEP 2                    ; 2
   jmp .drawSmurfBackgroundLayer_00;3

.skipDoneObstacleDrawBackgroundLayer_00
   ldy tmpSmurfGraphicIdx | $100;4
   jmp .drawSmurfBackgroundLayer_00;3

.skipDoneObstacleDrawBackgroundLayer_01
   ldy tmpSmurfGraphicIdx | $100;4
   jmp .drawSmurfBackgroundLayer_01;3

DrawMountainsKernelBackgroundLayers
   ldx #16                    ; 2
.drawMountainsKernelBackgroundLayer_00
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #GREEN + 4             ; 2
   sta COLUBK                 ; 3 = @16
   inc roomObstacleGraphicIndex;5
   bmi .skipObstacleDrawBackgroundLayer_00;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @37
   bne .skipDoneObstacleDrawBackgroundLayer_00;2³
   dec roomObstacleGraphicIndex;5
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfBackgroundLayer_00
   lda #LT_BROWN + 6          ; 2
   sta COLUBK                 ; 3
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextScanlineBackgroundLayer_00;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextScanlineBackgroundLayer_00;2³
   dey                        ; 2
.nextScanlineBackgroundLayer_00
   dex                        ; 2
   bpl .drawMountainsKernelBackgroundLayer_00;2³
   ldx #12                    ; 2
.drawMountainsKernelBackgroundLayer_01
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda #GREEN + 4             ; 2
   sta COLUBK                 ; 3 = @16
   inc roomObstacleGraphicIndex;5
   SLEEP 2                    ; 2
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda #LT_BROWN + 6          ; 2
   sta COLUBK                 ; 3 = @35
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @43
   bne .skipDoneObstacleDrawBackgroundLayer_01;2³
   dec roomObstacleGraphicIndex;5
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfBackgroundLayer_01
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextScanlineBackgroundLayer_01;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextScanlineBackgroundLayer_01;2³
   dey                        ; 2
.nextScanlineBackgroundLayer_01
   dex                        ; 2
   bpl .drawMountainsKernelBackgroundLayer_01;2³
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   stx GRP0                   ; 3 = @05
   stx GRP1                   ; 3 = @08
   sta WSYNC
;--------------------------------------
   ldy #10                    ; 2
.drawMountainsKernelBackgroundLayer_02
   sta WSYNC
;--------------------------------------
   lda MountainHillsPF0Graphics,y;4
   sta PF0                    ; 3 = @07
   lda MountainHillsPF1Graphics,y;4
   sta PF1                    ; 3 = @14
   lda MountainHillsPF2Graphics,y;4        
   sta PF2                    ; 3 = @21
   dey                        ; 2
   bpl .drawMountainsKernelBackgroundLayer_02;2³
   lda #GREEN + 10            ; 2
   sta WSYNC
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   lda #0                     ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   ldy #OVERSCAN_TIME - 12    ; 2
   jmp SetTimerForOverscanTime; 3

GargamelLabDisplayKernel
   lda roomObjectHorizPosition; 3         get Smurfette horizontal position
   clc                        ; 2
   adc #7                     ; 2         increment by 7 for hairbun position
   ldy #<[RESBL - RESP0]      ; 2
   jsr PositionObjectHorizontally_BANK1;6
   lda #COLOR_SMURFETTE_HAIR  ; 2
   sta COLUPF                 ; 3
   lda #MSBL_SIZE2 | DOUBLE_SIZE;2
   sta CTRLPF                 ; 3
   jsr HorizPositionSmurfAndObstacle_BANK1;6
;--------------------------------------
   lda #0                     ; 2
   ldx #25                    ; 2
   jsr DrawSmurfKernel        ; 6
   ldx smurfetteGraphicIndex  ; 3
   stx tmpSmurfetteGraphicIdx ; 3
   ldx #H_SMURFETTE           ; 2
.drawSmurfetteKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   sty tmpSmurfGraphicIdx     ; 3
   lda SmurfetteColors,x      ; 4
   sta COLUP1                 ; 3 = @21
   ldy tmpSmurfetteGraphicIdx ; 3
   dec tmpSmurfetteGraphicIdx ; 5
   lda SmurfetteSprites,y     ; 4
   and stationaryObstacleMask ; 3
   sta GRP1                   ; 3 = @39
   lda SmurfetteHairBunGraphics,x;4
   and stationaryObstacleMask ; 3
   sta ENABL                  ; 3 = @49
   ldy tmpSmurfGraphicIdx     ; 3
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextDrawSmurfetteScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextDrawSmurfetteScanline;2³
   dey                        ; 2
.nextDrawSmurfetteScanline
   dex                        ; 2
   bpl .drawSmurfetteKernel   ; 2³
   ldx #10                    ; 2
.drawGargamelLedgeKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda GargamelLabLedgeColors,x;4
   sta COLUPF                 ; 3 = @18
   lda GargamelLabLedgeGraphics,x;4
   sta PF1                    ; 3 = @25
   lda #MSBL_SIZE1 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @30
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextGargamelLedgeScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextGargamelLedgeScanline;2³
   dey                        ; 2
.nextGargamelLedgeScanline
   dex                        ; 2
   bpl .drawGargamelLedgeKernel;2³
   ldx #BLACK + 8             ; 2
   stx COLUP1                 ; 3
   ldx #19                    ; 2
.drawGargamelTableKernel
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda GargamelTablePF1Graphics,x;4
   sta PF1                    ; 3 = @18
   lda GargamelTablePF2Graphics,x;4
   sta PF2                    ; 3 = @25
   inc roomObstacleGraphicIndex;5
   bmi .drawSmurfGargamelTableSection_01;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @46
   bne .getSmurfGraphicIndexGargamelTableSection_01;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexGargamelTableSection_01
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGargamelTableSection_01
   lda #0                     ; 2
   iny                        ; 2
   bmi .gargamelTableSection_01;2³
   lda (smurfGraphicPointer),y; 5
   bne .gargamelTableSection_01;2³
   dey                        ; 2
.gargamelTableSection_01
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda GargamelTableColors,x  ; 4
   sta COLUPF                 ; 3 = @18
   lda GargamelTableColors,x  ; 4
   sta COLUPF                 ; 3 = @25
   inc roomObstacleGraphicIndex;5
   bmi .drawSmurfGargamelTableSection_02;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @46
   bne .getSmurfGraphicIndexGargamelTableSection_02;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexGargamelTableSection_02
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGargamelTableSection_02
   lda #0                     ; 2
   iny                        ; 2
   bmi .gargamelTableSection_02;2³
   lda (smurfGraphicPointer),y; 5
   bne .gargamelTableSection_02;2³
   dey                        ; 2
.gargamelTableSection_02
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda GargamelTableColors,x  ; 4
   sta COLUPF                 ; 3 = @18
   lda GargamelTableColors,x  ; 4
   sta COLUPF                 ; 3 = @25
   inc roomObstacleGraphicIndex;5
   bmi .drawSmurfGargamelTableSection_03;2³
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @46
   bne .getSmurfGraphicIndexGargamelTableSection_03;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexGargamelTableSection_03
   ldy tmpSmurfGraphicIdx     ; 3
.drawSmurfGargamelTableSection_03
   lda #0                     ; 2
   iny                        ; 2
   bmi .gargamelTableSection_03;2³
   lda (smurfGraphicPointer),y; 5
   bne .gargamelTableSection_03;2³
   dey                        ; 2
.gargamelTableSection_03
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda (smurfColorPointer),y  ; 5
   sta COLUP0                 ; 3 = @11
   lda GargamelTableColors,x  ; 4
   sta COLUPF                 ; 3 = @18
   SLEEP 2                    ; 2
   inc roomObstacleGraphicIndex;5
   bmi .drawNextSmurfGargamelTableSection;2³ + 1
   sty tmpSmurfGraphicIdx     ; 3
   ldy roomObstacleGraphicIndex;3
   lda (roomObstacleGraphicPointer),y;5
   sta GRP1                   ; 3 = @41
   bne .getSmurfGraphicIndexGargamelTableSection;2³
   dec roomObstacleGraphicIndex;5
.getSmurfGraphicIndexGargamelTableSection
   ldy tmpSmurfGraphicIdx     ; 3
.drawNextSmurfGargamelTableSection
   lda #0                     ; 2
   iny                        ; 2
   bmi .nextGargamelTableScanline;2³
   lda (smurfGraphicPointer),y; 5
   bne .nextGargamelTableScanline;2³
   dey                        ; 2
.nextGargamelTableScanline
   dex                        ; 2
   bmi DrawGargamelLabFloor   ; 2³
   jmp .drawGargamelTableKernel;3

DrawGargamelLabFloor
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   inx                        ; 2         x = 0
   stx PF1                    ; 3 = @08
   stx PF2                    ; 3 = @11
   stx GRP0                   ; 3 = @14
   stx GRP1                   ; 3 = @17
   lda #COLOR_LAB_FLOOR       ; 2
   sta COLUBK                 ; 3 = @22
   stx REFP0                  ; 3 = @25
   stx REFP1                  ; 3 = @28
   stx COLUP0                 ; 3 = @31
   stx COLUP1                 ; 3 = @34
   stx COLUPF                 ; 3 = @37
   sta WSYNC
;--------------------------------------
   ldx #4                     ; 2
.wait24Cycles
   dex                        ; 2
   bpl .wait24Cycles          ; 2³
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @31
   SLEEP 2                    ; 2
   SLEEP_6                    ; 6
   sta RESM0                  ; 3 = @42
   SLEEP 2                    ; 2
   sta RESBL                  ; 3 = @47
   SLEEP_3                    ; 3
   sta RESM1                  ; 3 = @53
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @60
   lda #HMOVE_L2              ; 2
   sta HMP0                   ; 3 = @65
   lda #HMOVE_L1              ; 2
   sta HMM0                   ; 3 = @70
   sta NUSIZ0                 ; 3 = @73
   sta NUSIZ1                 ; 3 = @76
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   inx                        ; 2         x = 0
   stx COLUBK                 ; 3 = @08
   lda #7                     ; 2
   ldx #<[ENABL - GRP0]       ; 2
.setPlayerGraphicValuesForFloor
   sta GRP0,x                 ; 4
   dex                        ; 2
   bpl .setPlayerGraphicValuesForFloor;2³
   ldx #15                    ; 2
   lda #HMOVE_R1              ; 2
   sta HMM1                   ; 3
   lda #HMOVE_R2              ; 2
   sta HMP1                   ; 3
.colorGargamelLabFloorKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda GargarmelLabFloorColors,x;4
   sta COLUBK                 ; 3 = @10
   SLEEP_12                   ; 12
   SLEEP_6                    ; 6
   dex                        ; 2
   bpl .colorGargamelLabFloorKernel;2³
   sta WSYNC
;--------------------------------------
   inx                        ; 2         x = 0

   IF COMPILE_REGION = PAL50

   stx COLUBK                 ; 3

   ENDIF

   ldy #<[ENABL - GRP0]       ; 2
.clearPlayerGraphicRegisters
   stx GRP0,y                 ; 4
   dey                        ; 2
   bpl .clearPlayerGraphicRegisters;2³
   ldy #OVERSCAN_TIME - 20    ; 2
   jmp SetTimerForOverscanTime; 3

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

   .byte $C6,$C3,$ED,$A0,$F2,$C2,$A5,$B0,$A0,$80,$A0,$CD,$C8,$84,$A0,$A0
   .byte $D3,$A0,$8A,$A0,$A5,$A0,$A0,$CF,$D0,$85,$A0,$E0,$BA,$A0,$FF,$A0
   .byte $A0,$A0,$A2,$A0,$93,$FF,$D2,$D2,$AE,$96,$A0,$A5,$BA,$A0,$A7,$A0
   .byte $98,$A0,$89,$C5,$A0,$A5,$B1,$A4,$A0,$96,$A0,$AE,$A9,$C5,$A0,$CE
   .byte $D5,$C6,$BA,$CA,$A0,$FE,$C2,$AC,$B0,$A0,$85,$A0,$C8,$A0,$F0,$EA
   .byte $EA,$EA

      ELSE

   .byte $C3,$A0,$80,$C4,$87,$D2,$C8,$C5,$A0,$AF,$CF,$A5,$C9,$BA,$A0,$A0
   .byte $85,$A0,$81,$A0,$E6,$FF,$AE,$D0,$A0,$BB,$C3,$AC,$C9,$A0,$E3,$A0
   .byte $AC,$C5,$B9,$CC,$A0,$D3,$A0,$A5,$D4,$D2,$C5,$A0,$CF,$A0,$A5,$AE
   .byte $8C,$BA,$A0,$FF,$A0,$8A,$A0,$A0,$C3,$D0,$D2,$A0,$A0,$A0,$B2,$C5
   .byte $A5,$C3,$A0,$E5,$C2,$A0,$D2,$E5,$C5,$AE,$A9,$CF,$8A,$D4,$C0,$A0
   .byte $A0,$EA,$EA,$EA

      ENDIF

   ENDIF

   FILL_BOUNDARY 231, 0

JumpToDisplayKernel_BANK1
    nop
    nop
    nop
    nop
    jmp DetermineDisplayKernel

JumpToCurrentGameStateRoutine_BANK1
   lda BANK1_REORG | BANK1STROBE
   lda BANK1_REORG | BANK0STROBE

   IF ORIGINAL_ROM

   .byte $EA,$EA,$EA,$EA
   
      IF COMPILE_REGION = PAL50
   
   .byte $FF,$FF,$D3,$D3

      ELSE
   
   .byte $A0,$A2,$80,$A0
   
      ENDIF

   ENDIF

   FILL_BOUNDARY 252, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK1 FREE"

   .word Bank1Start                 ; RESET vector
   .word Bank1Start                 ; BRK vector