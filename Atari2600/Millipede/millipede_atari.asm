   LIST OFF
; ***  M I L L I P E D E  ***
; Copyright 1984 Atari, Inc.
; Designers: Dave Staugas
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: October 27, 2023
;
; *** 126 BYTES OF SUPERCHIP RAM USED 2 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
; *** 126 BYTES OF ZP RAM USED 2 BYTES FREE
;
; ***    95 BYTES OF ROM FREE IN BANK0
; ***   331 BYTES OF ROM FREE IN BANK1
; ***   846 BYTES OF ROM FREE IN BANK2
; ***   237 BYTES OF ROM FREE IN BANK3
; ===========================================
; *** 1,509 TOTAL BYTES FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; *** 128 BYTES OF ZP RAM USED 0 BYTES FREE
;
; ***    95 BYTES OF ROM FREE IN BANK0
; ***   331 BYTES OF ROM FREE IN BANK1
; ***   853 BYTES OF ROM FREE IN BANK2
; ***   215 BYTES OF ROM FREE IN BANK3
; ===========================================
; *** 1,494 TOTAL BYTES FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1984, ATARI INC.                                   =
; =                                                                            =
; ==============================================================================
;

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

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
   
   IF !(ORIGINAL_ROM = TRUE || ORIGINAL_ROM = FALSE)

      echo ""
      echo "*** ERROR: Invalid ORIGINAL_ROM value"
      echo "*** Valid values: FALSE = 0, TRUE = 1"
      echo ""
      err

   ENDIF
   
   IFNCONST CHEAT_ENABLE
   
CHEAT_ENABLE            = FALSE     ; set to TRUE to enable no death collisions

   ENDIF
   
   IF !(CHEAT_ENABLE = TRUE || CHEAT_ENABLE = FALSE)

      echo ""
      echo "*** ERROR: Invalid CHEAT_ENABLE value"
      echo "*** Valid values: FALSE = 0, TRUE = 1"
      echo ""
      err
      
   ENDIF

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
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

VBLANK_TIME             = 127 + 43
OVERSCAN_TIME           = 127 + 35

   ELSE
   
VBLANK_TIME             = 127 + 78
OVERSCAN_TIME           = 127 + 59

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

   IF COMPILE_REGION = NTSC
   
COLORS_ORANGE           = BRICK_RED + 4
COLORS_BLUE             = BLUE + 4
COLORS_YELLOW           = YELLOW + 8
COLORS_PURPLE           = PURPLE + 6
COLORS_RED              = RED + 4
COLORS_COBALT_BLUE      = COBALT_BLUE + 6
COLORS_DK_GREEN         = DK_GREEN + 6
COLORS_DK_BLUE          = DK_BLUE + 8
COLORS_GREY             = BLACK + 8

COLORS_SHOOTER_ZONE     = BLACK + 2
COLORS_SHOOTER_ZONE_FLASH = RED
COLORS_SCORE            = ULTRAMARINE_BLUE + 15
COLORS_POISONED_MUSHROOM_LUMINANCE = 8

   ELSE

COLORS_ORANGE           = BRICK_RED + 6
COLORS_BLUE             = BLUE_2 + 4
COLORS_YELLOW           = YELLOW + 8
COLORS_PURPLE           = COBALT_BLUE + 6
COLORS_RED              = RED + 4
COLORS_COBALT_BLUE      = CYAN + 6
COLORS_DK_GREEN         = DK_GREEN + 8
COLORS_DK_BLUE          = TURQUOISE + 10
COLORS_GREY             = WHITE

COLORS_SHOOTER_ZONE     = BLACK_03 + 2
COLORS_SHOOTER_ZONE_FLASH = RED + 4
COLORS_SCORE            = PURPLE + 15
COLORS_POISONED_MUSHROOM_LUMINANCE = 14

   ENDIF
;
; Color table offset values
;
BEE_COLOR_OFFSET        = 1
EARWIG_COLOR_OFFSET     = 2
MILLIPEDE_COLOR_OFFSET  = 2
SPIDER_COLOR_OFFSET     = 3
MOSQUITO_COLOR_OFFSET   = 4
DDT_CLOUD_COLOR_OFFSET  = 4
DRAGONFLY_COLOR_OFFSET  = 5
INCHWORM_COLOR_OFFSET   = 6
BEETLE_COLOR_OFFSET     = 7
DDT_BOMB_COLOR_OFFSET   = 14
BONUS_POINTS_COLOR_OFFSET = 32

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

BANK0_BASE              = $1000
BANK1_BASE              = $2000
BANK2_BASE              = $3000
BANK3_BASE              = $4000

BANK0_REORG             = $9000
BANK1_REORG             = $B000
BANK2_REORG             = $D000
BANK3_REORG             = $F000

BANK0STROBE             = $FFF6
BANK1STROBE             = $FFF7
BANK2STROBE             = $FFF8
BANK3STROBE             = $FFF9

H_TITLE_BITMAP          = 38
H_GAME_OVER_BITMAP      = 16
H_DIGITS                = 7
H_DDT_CLOUD             = 8
H_SPRITE                = 8
H_SHOOTER               = 6

W_BLANK_SPRITE          = 0
W_SHOOTER               = 4
W_BEE                   = 8
W_EARWIG                = 8
W_SPIDER                = 8
W_MOSQUITO              = 8
W_DRAGONFLY             = 8
W_INCHWORM              = 8
W_BEETLE                = 8
W_MILLIPEDE_HEAD        = 4
W_MILLIPEDE_SEGMENT     = 8
W_DDT                   = 8
W_MILLIPEDE_SEGMENT_00  = 16

XMIN                    = 0
XMAX                    = 128

SHOOTER_START_X         = 60
SHOOTER_START_Y         = 56
SHOOTER_YMIN            = 40
SHOOTER_YMAX            = 56

MILLIPEDE_START_X       = 60

INCHWORM_STARTING_WAVE  = 2

MUSHROOM_TALLY_GROUP_VALUE = 3

SELECT_DELAY            = 15

MAX_LEVEL               = 15

MAX_KERNEL_SECTIONS     = 21
MAX_MILLIPEDE_SEGMENTS  = 9
MUSHROOM_ARRAY_SIZE     = 38

INIT_LIVES              = 3
MAX_LIVES               = 15

LIVES_MASK              = $0F
GAME_WAVE_MASK          = $0F
;
; low game state flags
;
GAME_ACTIVE_MASK        = %10000000
GAME_SELECTION_MASK     = %01000000
SPAWN_HEAD_MASK         = %00100000
SPAWN_EXTRA_SPIDER_MASK = %00010000

GS_GAME_OVER            = 1 << 7
GS_GAME_ACTIVE          = 0 << 7

GS_SELECTING_GAME       = 1 << 6
GS_SPAWN_MILLIPEDE_HEAD = 1 << 5

GS_EXTRA_SPIDER_SPAWNED = 1 << 4

;
; high game state flags
;
SHOW_GAME_OVER_MASK     = %10000000
SPAWN_INCHWORM_TIMER_MASK = %00001111


GS_SHOW_GAME_OVER       = 1 << 7

INIT_INCHWORM_SPAWN_TIMER = 15

;
; wave state flags
;
SWARMING_MASK           = %10000000
SHOW_LITERAL_MASK       = %01000000
ACTION_BUTTON_DEBOUNCE  = %00100000
SWARMING_WAVE_MASK      = %00001100

SWARMING                = 1 << 7
NOT_SWARMING            = 0 << 7
SHOW_LITERALS           = 1 << 6
NOT_SHOW_LITERALS       = 0 << 6
ACTION_BUTTON_RELEASED  = 1 << 5
ACTION_BUTTON_HELD      = 0 << 5

SELECT_DEBOUNCE_MASK    = %01000000

SELECT_SWITCH_HELD      = 1 << 6
SELECT_SWITCH_RELEASED  = 0 << 6

EVEN_NORMAL_MUSHROOM_MASK = $AA
ODD_NORMAL_MUSHROOM_MASK = $55
EVEN_REFLECTED_MUSHROOM_MASK = $55
ODD_REFLECTED_MUSHROOM_MASK = $AA
;
; Kernel zone attribute values
;
MUSHROOM_POISON_MASK    = %10000000
DRAW_INSECT_MASK        = %10000000
DRAW_DDT_CLOUD_MASK     = %01000000

SPRITE_ID_IDX_MASK      = %00111111

POISON_MUSHROOM_ZONE    = 1 << 7
NORMAL_MUSHROOM_ZONE    = 0 << 7

SKIP_DRAW_INSECT_ZONE   = 1 << 7
DRAW_INSECT_ZONE        = 0 << 7

DRAW_MILLIPEDE_CHAIN_ZONE = 3 << 6
DRAW_DDT_CLOUD_ZONE     = 2 << 6

DRAW_LITERAL_ZONE       = 1 << 6
;
; Temporary values for Millipede speed
;
FAST_MILLIPEDE_VALUE    = -1
SLOW_MILLIPEDE_VALUE    = 0

MAX_HORIZ_FRICTION_VALUE = 23

MAX_DDT_BOMBS           = 5

INIT_BEETLE_KERNEL_ZONE = 8
;
; Number font values
;
ID_ZERO                 = 0
ID_ONE                  = 1
ID_TWO                  = 2
ID_THREE                = 3
ID_FOUR                 = 4
ID_FIVE                 = 5
ID_SIX                  = 6
ID_SEVEN                = 7
ID_EIGHT                = 8
ID_NINE                 = 9
ID_BLANK_FONT           = 10
;
; Sprite Id values
;
ID_BLANK                = 0
ID_BEE                  = 1         ; 1 - 2
ID_EARWIG               = 3         ; 3 - 6
ID_SPIDER               = 7         ; 7 - 9
ID_MOSQUITO             = 10        ; 10 - 13
ID_DRAGONFLY            = 14        ; 14 - 16
ID_INCHWORM             = 17        ; 17 - 19
ID_BEETLE               = 20        ; 20 - 27
ID_SHOOTER_DEATH        = 28        ; 28 - 31
ID_SPARK                = 32        ; 32 - 33
ID_MILLIPEDE_HEAD       = 34
ID_MILLIPEDE_SEGMENT    = 35
ID_POINTS_200           = 36
ID_POINTS_300           = 37
ID_POINTS_400           = 38
ID_POINTS_500           = 39
ID_POINTS_600           = 40
ID_POINTS_700           = 41
ID_POINTS_800           = 42
ID_POINTS_900           = 43
ID_POINTS_1000          = 44
ID_POINTS_1200          = 45
ID_POINTS_1800          = 46
ID_DDT                  = 47
ID_DDT_CLOUD            = 48
ID_MILLIPEDE_CHAIN      = 64
;
; Point values (BCD)
;
POINTS_MILLIPEDE_SEGMENT = $0010
POINTS_MILLIPEDE_HEAD   = $0100

POINTS_SPIDER_DISTANT   = $0300
POINTS_SPIDER_MEDIUM    = $0600
POINTS_SPIDER_CLOSE     = $0900
POINTS_SPIDER_CLOSEST   = $1200

POINTS_INCHWORM         = $0100
POINTS_BEE              = $0200
POINTS_BEETLES          = $0300
POINTS_MOSQUITO         = $0400
POINTS_DRAGONFLY        = $0500
POINTS_DDT_BOMB         = $0800
POINTS_EARWIG           = $1000
POINTS_ELIMINATE_MUSHROOM  = 1
POINTS_REMAINING_MUSHROOMS = 5

KERNEL_ZONE_MASK        = %00011111

PLAYER_MOVEMENT_MASK    = %10000000
INSECT_SPEED_MASK       = %01000000

PLAYER_MOVEMENT_HALT    = 1 << 7
PLAYER_MOVEMENT_NORMAL  = 0 << 7

INSECT_SPEED_SLOW       = 1 << 6
INSECT_SPEED_NORMAL     = 0 << 6

;
; Object attribute values
;
OBJECT_HORIZ_DIR_MASK   = %10000000

OBJECT_DIR_LEFT         = 0 << 7
OBJECT_DIR_RIGHT        = 1 << 7

;
; Beetle attribute values
;
BEETLE_HORIZ_DIR_MASK   = %10000000
BEETLE_VERT_DIR_MASK    = %01000000

BEETLE_HORIZ_MOVE       = 1 << 7
BEETLE_NO_HORIZ_MOVE    = 0 << 7

BEETLE_DIR_UP           = 1 << 6
BEETLE_DIR_DOWN         = 0 << 6
;
; Dragonfly attribute values
;
DRAGONFLY_HORIZ_OFFSET_MASK = %11100000
;
; Inchworm attribute values
;
INCHWORM_SPEED_MASK     = %10000000
INCHWORM_HORIZ_DIR_MASK = %01000000

INCHWORM_FAST           = 1 << 7
INCHWORM_SLOW           = 0 << 7

INCHWORM_DIR_RIGHT      = 0 << 6
INCHWORM_DIR_LEFT       = 1 << 6
;
; Earwig attribute values
;
EARWIG_SPEED_MASK       = %10000000

EARWIG_FAST             = 1 << 7
EARWIG_SLOW             = 0 << 7
;
; Millipede attribute values
;
MILLIPEDE_SPEED_MASK    = %01000000
MILLIPEDE_POISONED_MASK = %00100000

MILLIPEDE_FAST          = 1 << 6
MILLIPEDE_SLOW          = 0 << 6

MILLIPEDE_POISONED      = 1 << 5
MILLIPEDE_NORMAL        = 0 << 5
;
; Mosquito attribute values
;
MOSQUITO_SPEED_MASK     = %10000000

MOSQUITO_FAST           = 1 << 7
MOSQUITO_SLOW           = 0 << 7
;
; Spider attribute values
;
SPIDER_VERT_DIR_MASK    = %01000000
SPIDER_HORIZ_MOVE_MASK  = %00100000

SPIDER_DIR_UP           = 0 << 6
SPIDER_DIR_DOWN         = 1 << 6

SPIDER_HORIZ_MOVE       = 1 << 5
SPIDER_NO_HORIZ_MOVE    = 0 << 5

MAX_SPIDER_KERNEL_ZONE  = 10

;
; Bee state values
;
BEE_STATE_ANGRY         = 1 << 7
BEE_STATE_NORMAL        = 0 << 7
;
; Millipede state values
;
MILLIPEDE_SEGMENT_MASK  = %10000000
MILLIPEDE_VERT_DIR_MASK = %01000000
MILLIPEDE_HORIZ_DIR_MASK = %00100000

MILLIPEDE_BODY_SEGMENT  = 1 << 7
MILLIPEDE_HEAD_SEGMENT  = 0 << 7

MILLIPEDE_DIR_UP        = 1 << 6
MILLIPEDE_DIR_DOWN      = 0 << 6

MILLIPEDE_DIR_LEFT      = 1 << 5
MILLIPEDE_DIR_RIGHT     = 0 << 5

SHOOTER_HORIZ_DIR_MASK  = %11000000
SHOOTER_HORIZ_DELAY_MASK = %00111111

MILLIPEDE_BODY_HORIZ_OFFSET = 4

SHOOTER_MOVE_LEFT       = 1 << 7
SHOOTER_MOVE_RIGHT      = 1 << 6

DEMO_SHOOTER_VERT_DIR   = %10000000
DEMO_SHOOTER_HORIZ_DIR  = %01000000

DEMO_SHOOTER_MOVE_UP    = 0 << 7
DEMO_SHOOTER_MOVE_DOWN  = 1 << 7
DEMO_SHOOTER_MOVE_RIGHT = 0 << 6
DEMO_SHOOTER_MOVE_LEFT  = 1 << 6
;
; Kernel Shooter state
;
POSITION_SHOOTER_MASK   = %01000000

POSITION_SHOOTER        = 1 << 6


MUSHROOM_TALLY_AUDIO_FREQUENCY = 10
MUSHROOM_TALLY_AUDIO_VOLUME = 255
MUSHROOM_TALLY_AUDIO_TONE = 8

SHOT_AUDIO_VOLUME       = 255
SHOT_AUDIO_TONE         = 8
END_AUDIO_TUNE          = 0

SHOOTER_EXPLOSION_AUDIO_VOLUME = 255
SHOOTER_EXPLOSION_AUDIO_TONE = 8

HEARTBEAT_AUDIO_TONE    = 15

OBJECT_SPAWNING_BEE     = 1 << 7
OBJECT_SPAWNING_DRAGONFLY = 1 << 5
OBJECT_SPAWNING_MOSQUITO = 1 << 3
OBJECT_SPAWNING_EARWIG  = 1 << 2
OBJECT_SPAWNING_INCHWORM = 1 << 1

MAX_SWARMING_INSECTS_00 = 20
MAX_SWARMING_INSECTS_01 = 30
MAX_SWARMING_INSECTS_02 = 40

;===============================================================================
; M A C R O S
;===============================================================================

   MAC DDT_CREATURE_POINT_VALUE
   
      IF {1} < $10

         .byte [(({1} * 3) / 10) * 16 | ({1} * 3) % 10]
      
      ELSE
      
         .byte {1} * 3
         
      ENDIF

   ENDM

;
; Set sound values macros
;
   MAC SET_AUDIO_TONE
      .byte {1} << 3 | 0
   ENDM
   
   MAC SET_AUDIO_FREQUENCY
      .byte {1} << 3 | 1
   ENDM
   
   MAC SET_SLOWDOWN_AUDIO_FREQUENCY
      .byte {1} << 3 | 5
   ENDM
   
   MAC SET_AUDIO_VOLUME
      .byte {1} << 3 | 2
   ENDM
   
   MAC SET_AUDIO_DURATION
      .byte {1} << 3 | 3
   ENDM
   
   MAC JMP_AUDIO_START
      .byte 0 << 3 | 4
      .byte {1}
   ENDM

;
; time wasting macros
;
   MAC SLEEP_5
      lda shooterZoneBackgroundColor
      SLEEP 2
   ENDM

   MAC SLEEP_6
   
      IF ORIGINAL_ROM
      
         cmp (tmpBitmapDisplayLoop,x)
      
      ELSE
      
         SLEEP 6
         
      ENDIF

   ENDM

   MAC SLEEP_7
      pha
      pla
   ENDM

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

  MAC FILL_NOP
      REPEAT {1}
         NOP
      REPEND
  ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U GAME_ZP_VARIABLES
   .org $80

frameCount              ds 2
gameState               ds 2
random                  ds 2
kernelZoneAttributes_00 ds MAX_KERNEL_SECTIONS + 1
kernelZoneAdjustment    ds 1
kernelZoneAttributes_01 ds MAX_KERNEL_SECTIONS
gameWaveValues          ds 1
inchwormWaveState       ds 1
displayScanOutControl   ds 1
gardenShiftValues       ds 1
beetleSpawnTimer        ds 1
objectSpawningValues    ds 1
waveState               ds 1
leftSoundChannelIndex   ds 1
rightSoundChannelIndex  ds 1
leftSoundAudioDuration  ds 1
rightSoundAudioDuration ds 1
soundRoutineVector      ds 2
tmpAudioValue           ds 1
;--------------------------------------
tmpObjectKernelZone     = tmpAudioValue
shooterVertPos          ds 1
shooterHorizPos         ds 1
shooterHorizFrictionValue ds 1
;--------------------------------------
demoShooterDirectionValues = shooterHorizFrictionValue
shotVertPos             ds 1
shotHorizPos            ds 1
numberOfMillipedeSegments ds 1
;--------------------------------------
waveTransitionTimer     = numberOfMillipedeSegments
millipedeSegmentState   ds MAX_MILLIPEDE_SEGMENTS
millipedeHorizPosition   ds MAX_MILLIPEDE_SEGMENTS
;--------------------------------------
waveNumberSwarmingInsects = millipedeHorizPosition + 3
;--------------------------------------
mushroomTallyGardenArrayIndex = waveNumberSwarmingInsects
numberActiveSwarmingInsects = millipedeHorizPosition + 4
;--------------------------------------
mushroomTallyGardenIndex = numberActiveSwarmingInsects
tmpMushroomTallyFrameDelay = millipedeHorizPosition + 5
;--------------------------------------
tmpSwarmingInsectSpawningTimer = tmpMushroomTallyFrameDelay
insectSwarmShootTally   = millipedeHorizPosition + 6
;--------------------------------------
tmpRemainingMushroomPointValue = insectSwarmShootTally
poisonedMushroomColor   ds 1
tmpRemainingLivesColor  ds 1
;--------------------------------------
tmpNormalMushroomColor  = tmpRemainingLivesColor
shooterZoneBackgroundColor ds 1
growingMushroomGardenArrayIndex ds 1
growingMushroomGardenIndex ds 1
objectListEndValue      ds 1
millipedeBodyKernelZone ds 1
shotMushroomIndex       ds 1
playerScore             ds 3
kernelZoneConflictArray ds 6
conflictArrayStartingIndex ds 1

   IF COMPILE_REGION = PAL50
   
creatureFrameCount      ds 2

   ENDIF

tmpKernelZone_BANK0     ds 1
graphicsPointers        ds 12
;--------------------------------------
tmpPoints               = graphicsPointers
;--------------------------------------
tmpThousandsPoints      = tmpPoints
tmpHundredsPoints       = tmpPoints + 1
tmpOnesPoints           = tmpPoints + 2
;--------------------------------------
tmpCoarsePositionObject0Vector = graphicsPointers
tmpCoarsePositionObject1Vector = tmpCoarsePositionObject0Vector + 2
tmpCoarsePositionShooterVector = tmpCoarsePositionObject1Vector + 2
;--------------------------------------
tmpShotCollisionRoutineVector = tmpCoarsePositionShooterVector
;--------------------------------------
tmpObjectMoveRoutineVector = tmpShotCollisionRoutineVector
;--------------------------------------
tmpObjectSpawningVector = tmpObjectMoveRoutineVector
;--------------------------------------
tmpObjectFineHorizValue = tmpObjectSpawningVector

tmpConflictingZoneValues = graphicsPointers + 6
;--------------------------------------
tmpGRP0GraphicIndex     = tmpConflictingZoneValues
playerShotEnableIndex   = tmpGRP0GraphicIndex + 1
tmpGRP1GraphicIndex     = playerShotEnableIndex + 1
kernelShooterState      = tmpGRP1GraphicIndex + 1
shooterKernelZoneValue  = kernelShooterState + 1
tmpLeftPF1MushroomGraphics = shooterKernelZoneValue + 1
;--------------------------------------
tmpKernelEnableBALL     = tmpLeftPF1MushroomGraphics

tmpZeroSuppressValue    ds 1
;--------------------------------------
tmpExtraLifeState       = tmpZeroSuppressValue
;--------------------------------------
tmpSwarmingWaveValue    = tmpExtraLifeState
;--------------------------------------
tmpMillipedeSegmentIndex = tmpSwarmingWaveValue
;--------------------------------------
tmpLeftPF2MushroomGraphics = tmpMillipedeSegmentIndex
;--------------------------------------
tmpBitmapDisplayLoop    = tmpLeftPF2MushroomGraphics
;--------------------------------------
tmpShotUpperKernelZone  = tmpBitmapDisplayLoop
;--------------------------------------
tmpMushroomArrayIdx     = tmpShotUpperKernelZone
;--------------------------------------
tmpMushroomMaskingBits  = tmpMushroomArrayIdx
;--------------------------------------
tmpSpriteIdx            = tmpMushroomMaskingBits
;--------------------------------------
tmpMillipedeChainEnd    = tmpSpriteIdx
;--------------------------------------
tmpSpiderAttributes     = tmpMillipedeChainEnd
;--------------------------------------
tmpSpiderKernelZoneMax  = tmpSpiderAttributes
;--------------------------------------
tmpInchwormPointValue   = tmpSpiderKernelZoneMax
;--------------------------------------
tmpSpawnDDTBomb         = tmpInchwormPointValue
;--------------------------------------
tmpScoreThousandsValue  = tmpSpawnDDTBomb
;--------------------------------------
tmpMushroomXOR          = tmpScoreThousandsValue
;--------------------------------------
tmpShouldProcessObjectMovements = tmpMushroomXOR
;--------------------------------------
tmpIsolatedMushroomBitValue = tmpShouldProcessObjectMovements
tmpKernelZoneAdjustment ds 1
;--------------------------------------
tmpMillipedeChainGroupHorizOffset = tmpKernelZoneAdjustment
;--------------------------------------
tmpCharHolder           = tmpMillipedeChainGroupHorizOffset
;--------------------------------------
tmpHundredsValueHolder  = tmpCharHolder
;--------------------------------------
tmpMillipedeState       = tmpHundredsValueHolder
;--------------------------------------
tmpRightPF1Graphics     = tmpMillipedeState
;--------------------------------------
tmpShooterKernelZone    = tmpRightPF1Graphics
;--------------------------------------
tmpSpiderKernelZone     = tmpShooterKernelZone
;--------------------------------------
tmpMosquitoMovementDelay = tmpSpiderKernelZone
;--------------------------------------
tmpBeeMovementDelay     = tmpMosquitoMovementDelay
;--------------------------------------
tmpMillipedeSpeed       = tmpBeeMovementDelay
;--------------------------------------
tmpBeetleKernelZone     = tmpMillipedeSpeed
;--------------------------------------
tmpInsectKernelZone     = tmpBeetleKernelZone
;--------------------------------------
tmpNumberOfMushrooms    = tmpInsectKernelZone
;--------------------------------------
tmpSwarmingSpawningInsectValue = tmpNumberOfMushrooms
;--------------------------------------
tmpMushroomMaskingBitValue = tmpSwarmingSpawningInsectValue
;--------------------------------------
tmpDragonflyMovementFrame = tmpMushroomMaskingBitValue
;--------------------------------------
tmpConflictingKernelZoneValue = tmpDragonflyMovementFrame

tmpLeadingSegmentKernelZone ds 1
;--------------------------------------
tmpRightPF2Graphics     = tmpLeadingSegmentKernelZone
;--------------------------------------
tmpPlayerShotEnableIndex = tmpRightPF2Graphics
;--------------------------------------
tmpShotObjectHorizDistance = tmpPlayerShotEnableIndex
;--------------------------------------
tmpMillipedeChainIndex  = tmpShotObjectHorizDistance
;--------------------------------------
tmpObjectCollisionIdx   = tmpMillipedeChainIndex
tmpShotMillipedeState   ds 1
;--------------------------------------
tmpMushroomMaskingBitIndex = tmpShotMillipedeState
;--------------------------------------
tmpLeftPF1FlowerGraphics = tmpMushroomMaskingBitIndex
;--------------------------------------
tmpKernelShooterState   = tmpLeftPF1FlowerGraphics
;--------------------------------------
tmpDDTCloudUpperKernelZone = tmpKernelShooterState
;--------------------------------------
tmpKernelZoneAttributes_00 = tmpDDTCloudUpperKernelZone
;--------------------------------------
tmpBuildingMillipedeChainIndex = tmpKernelZoneAttributes_00
;--------------------------------------
tmpMushroomTallyIndex   = tmpBuildingMillipedeChainIndex
tmpLeftPF2FlowerGraphics ds 1
;--------------------------------------
tmpShooterKernelZoneValue = tmpLeftPF2FlowerGraphics
;--------------------------------------
tmpMillipedeSegmentZone = tmpShooterKernelZoneValue
;--------------------------------------
tmpDDTCloudLowerKernelZone = tmpMillipedeSegmentZone
;--------------------------------------
tmpShotKernelZone       = tmpDDTCloudLowerKernelZone
;--------------------------------------
tmpMushroomTallyGroupCount = tmpShotKernelZone
tmpRightPF1FlowerGraphics ds 1
;--------------------------------------
tmpDDTCloudHorizPosition = tmpRightPF1FlowerGraphics
;--------------------------------------
tmpMillipedeHorizPos    = tmpDDTCloudHorizPosition
;--------------------------------------
tmpEndDDTCloudMushroomMaskingIndex = tmpMillipedeHorizPos
tmpShotMillipedeIndex   ds 1
;--------------------------------------
tmpRightPF2FlowerGraphics = tmpShotMillipedeIndex
;--------------------------------------
tmpNumberOfMillipedeSegments = tmpRightPF2FlowerGraphics
;--------------------------------------
tmpKernelZone_BANK3     = tmpNumberOfMillipedeSegments
;--------------------------------------
tmpShotLowerKernelZone  = tmpKernelZone_BANK3

   echo "***",(* - $80)d, "BYTES OF ZP RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; S U P E R C H I P  R A M - V A R I A B L E S
;===============================================================================
   SEG.U scWriteVars
   .org $1000

objectHorizPositions_W
;--------------------------------------
ddtBombHorizPosition_W  ds MAX_DDT_BOMBS
creatureHorizPositions_W ds 14
;--------------------------------------
beetleHorizPositions_W  = creatureHorizPositions_W
;--------------------------------------
inchwormHorizPosition_W = beetleHorizPositions_W + 1
;--------------------------------------
gardenInsectHorizPosition_W = creatureHorizPositions_W + 2
;--------------------------------------
beeHorizPosition_W      = gardenInsectHorizPosition_W
;--------------------------------------
dragonflyHorizPosition_W = gardenInsectHorizPosition_W
;--------------------------------------
earwigHorizPosition_W   = gardenInsectHorizPosition_W
;--------------------------------------
mosquitoHorizPosition_W = gardenInsectHorizPosition_W

objectAttributes_W
;--------------------------------------
ddtBombAttributes_W     ds MAX_DDT_BOMBS
creatureAttributes_W    ds 14
;--------------------------------------
sparkAttributes_W       = creatureAttributes_W
;--------------------------------------
beetleAttributes_W      = sparkAttributes_W
;--------------------------------------
inchwormAttributes_W    = beetleAttributes_W + 1
;--------------------------------------
gardenInsectAttributes_W = creatureAttributes_W + 2
;--------------------------------------
beeAttributes_W         = gardenInsectAttributes_W
;--------------------------------------
dragonflyAttributes_W   = gardenInsectAttributes_W
;--------------------------------------
earwigAttributes_W      = gardenInsectAttributes_W
;--------------------------------------
mosquitoAttributes_W    = gardenInsectAttributes_W

spriteIdArray_W
;--------------------------------------
ddtBombSpriteIds_W      ds MAX_DDT_BOMBS
creatureSpriteIds_W     ds 14
;--------------------------------------
sparkSpriteId_W         = creatureSpriteIds_W
;--------------------------------------
beetleSpriteId_W        = sparkSpriteId_W
;--------------------------------------
inchwormSpriteId_W      = beetleSpriteId_W + 1
;--------------------------------------
gardenInsectSpriteId_W  = creatureSpriteIds_W + 2
;--------------------------------------
beeSpriteId_W           = gardenInsectSpriteId_W
;--------------------------------------
dragonflySpriteId_W     = gardenInsectSpriteId_W
;--------------------------------------
earwigSpriteId_W        = gardenInsectSpriteId_W
;--------------------------------------
mosquitoSpriteId_W      = gardenInsectSpriteId_W

tmpMaxStartingScoreThousandsValue_W = spriteIdArray_W + 12
tmpMaxStartingScoreHundredsValue_W = spriteIdArray_W + 13

leftFlowerArray_W       ds 11
millipedeAttributes_W   ds MAX_MILLIPEDE_SEGMENTS
rightFlowerArray_W      ds 11
mushroomArray_W         ds MUSHROOM_ARRAY_SIZE
;--------------------------------------
leftMushroomArray_W     = mushroomArray_W
rightMushroomArray_W    = leftMushroomArray_W + [MUSHROOM_ARRAY_SIZE / 2] + 1

   echo "***",(* - $1000)d, "BYTES OF SUPERCHIP RAM USED", ($1080 - *)d, "BYTES FREE"

   SEG.U scReadVars
   .org $1080

objectHorizPositions_R
;--------------------------------------
ddtBombHorizPosition_R  ds MAX_DDT_BOMBS
creatureHorizPositions_R ds 14
;--------------------------------------
beetleHorizPositions_R  = creatureHorizPositions_R
;--------------------------------------
inchwormHorizPosition_R = beetleHorizPositions_R + 1
;--------------------------------------
gardenInsectHorizPosition_R = creatureHorizPositions_R + 2
;--------------------------------------
beeHorizPosition_R      = gardenInsectHorizPosition_R
;--------------------------------------
dragonflyHorizPosition_R = gardenInsectHorizPosition_R
;--------------------------------------
earwigHorizPosition_R   = gardenInsectHorizPosition_R
;--------------------------------------
mosquitoHorizPosition_R = gardenInsectHorizPosition_R

objectAttributes_R
;--------------------------------------
ddtBombAttributes_R     ds MAX_DDT_BOMBS
creatureAttributes_R    ds 14
;--------------------------------------
sparkAttributes_R       = creatureAttributes_R
;--------------------------------------
beetleAttributes_R      = sparkAttributes_R
;--------------------------------------
inchwormAttributes_R    = beetleAttributes_R + 1
;--------------------------------------
gardenInsectAttributes_R = creatureAttributes_R + 2
;--------------------------------------
beeAttributes_R         = gardenInsectAttributes_R
;--------------------------------------
dragonflyAttributes_R   = gardenInsectAttributes_R
;--------------------------------------
earwigAttributes_R      = gardenInsectAttributes_R
;--------------------------------------
mosquitoAttributes_R    = gardenInsectAttributes_R

spriteIdArray_R
;--------------------------------------
ddtBombSpriteIds_R      ds MAX_DDT_BOMBS
creatureSpriteIds_R     ds 14
;--------------------------------------
sparkSpriteId_R         = creatureSpriteIds_R
;--------------------------------------
beetleSpriteId_R        = sparkSpriteId_R
;--------------------------------------
inchwormSpriteId_R      = beetleSpriteId_R + 1
;--------------------------------------
gardenInsectSpriteId_R  = creatureSpriteIds_R + 2
;--------------------------------------
beeSpriteId_R           = gardenInsectSpriteId_R
;--------------------------------------
dragonflySpriteId_R     = gardenInsectSpriteId_R
;--------------------------------------
earwigSpriteId_R        = gardenInsectSpriteId_R
;--------------------------------------
mosquitoSpriteId_R      = gardenInsectSpriteId_R

tmpMaxStartingScoreThousandsValue_R = spriteIdArray_R + 12
tmpMaxStartingScoreHundredsValue_R = spriteIdArray_R + 13

leftFlowerArray_R       ds 11
millipedeAttributes_R   ds MAX_MILLIPEDE_SEGMENTS
rightFlowerArray_R      ds 11
mushroomArray_R         ds MUSHROOM_ARRAY_SIZE
;--------------------------------------
leftMushroomArray_R     = mushroomArray_R
rightMushroomArray_R    = leftMushroomArray_R + [MUSHROOM_ARRAY_SIZE / 2] + 1

;===============================================================================
; R O M - C O D E (BANK0)
;===============================================================================

   SEG Bank0
   .org BANK0_BASE
   .rorg BANK0_REORG

FREE_BYTES SET 0

   .ds 256, 0                       ; first page reserved for Superchip RAM

SetupGameDisplayKernel
   ldx millipedeBodyKernelZone
   cpx #MAX_KERNEL_SECTIONS + 1
   bcs PositionShotHorizontally
   sta WSYNC                        ; wait for next scan line
   lda #$7F
   and kernelZoneAttributes_01 - 1,x
   tay
   lda BANK0_HMOVE_Table + 1,y
   sta.w HMM0                       ; set missile fine motion value
   and #$0F                         ; keep coarse position value
   tay
.coarsePositionMissile_00
   dey
   bpl .coarsePositionMissile_00
   sta RESM0
   sta WSYNC                        ; wait for next scan line
   lda kernelZoneAttributes_01 - 1,x
   and #$7F
   tay
   lda BANK0_HMOVE_Table,y
   sta.w HMM1                       ; set missile fine motion value
   and #$0F                         ; keep coarse position value
   tay
.coarsePositionMissile_01
   dey
   bpl .coarsePositionMissile_01
   sta RESM1
PositionShotHorizontally
   sta WSYNC                        ; wait for next scan line
   lda #MSBL_SIZE1 | PF_REFLECT
   sta CTRLPF
   clc
   ldx shotHorizPos                 ; get Shot horizontal position
   lda BANK0_HMOVE_Table + 1,x
   sta HMBL                         ; set Shot fine motion value
   and #$0F                         ; keep coarse position value
   tay
.coarsePositionShot
   dey
   bpl .coarsePositionShot
   sta RESBL
   bit waveState                    ; check current wave state value
   bvc .waitTime
   lda #DRAW_LITERAL_ZONE | ID_BLANK
   ldx kernelZoneAdjustment         ; get kernel zone adjustment value
   sta kernelZoneAttributes_00 + 14,x
.waitTime
   lda INTIM
   bmi .waitTime
   lda displayScanOutControl        ; get display scan out value
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta VBLANK                 ; 3 = @06
   sta COLUBK                 ; 3 = @09
   sta tmpKernelEnableBALL    ; 3
   lda #>CoarsePositionObject0Routines;2
   sta tmpCoarsePositionObject0Vector + 1;3        
   lda #>CoarsePositionObject1Routines;2
   sta tmpCoarsePositionObject1Vector + 1;3        
   lda #>CoarsePositionShooterRoutines;2        
   sta tmpCoarsePositionShooterVector + 1;3        
   lda #DRAW_LITERAL_ZONE | ID_BLANK;2
   ldx kernelZoneAdjustment   ; 3         get kernel zone adjustment value
   sta kernelZoneAttributes_00,x;4
   txa                        ; 2
   adc #MAX_KERNEL_SECTIONS - 1;2
   tax                        ; 2
   stx tmpKernelZone_BANK0    ; 3
   lda #6                     ; 2
   adc kernelZoneAdjustment   ; 3         increment by kernel zone adjustment
   sta shooterKernelZoneValue ; 3
   SLEEP_7                    ; 7
   sta HMCLR                  ; 3 = @63
   ldy kernelZoneAttributes_00,x;4        get object 0 zone attributes
   bmi .skipDrawInsectZone    ; 2³        branch if SKIP_DRAW_INSECT_ZONE
   ldx objectHorizPositions_R,y;4
;--------------------------------------
   lda BANK0_HMOVE_Table,x    ; 4 = @01
   sta HMP0                   ; 3 = @04
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3        
   tya                        ; 2         move zone attributes to accumulator
   ldx tmpKernelZone_BANK0    ; 3
   jmp (tmpCoarsePositionObject0Vector);5 = @25
    
.skipDrawInsectZone
;--------------------------------------
   SLEEP_7                    ; 7 = @01
   SLEEP_7                    ; 7
   tya                        ; 2         move zone attributes to accumulator
   ldy #0                     ; 2
   jmp CheckToDrawMillipedeChain;3
    
BANK0_CoarsePositionRoutineTableObject_00
   .byte <CoarsePositionObject0ToCycle28
   .byte <CoarsePositionObject0ToCycle33
   .byte <CoarsePositionObject0ToCycle38
   .byte <CoarsePositionObject0ToCycle43
   .byte <CoarsePositionObject0ToCycle48
   .byte <CoarsePositionObject0ToCycle53
   .byte <CoarsePositionObject0ToCycle58
   .byte <CoarsePositionObject0ToCycle63
   .byte <CoarsePositionObject0ToCycle68

DDTCloudSpriteGraphicsZone_01
   .byte $38 ; |..XXX...|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $5C ; |.X.XXX..|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $56 ; |.X.X.XX.|
   .byte $45 ; |.X...X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|

BANK0_WaveColorValues
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   
   .byte COLORS_ORANGE, COLORS_YELLOW, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   .byte COLORS_ORANGE, COLORS_DK_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
    
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY

   FILL_BOUNDARY 256, 0

BANK0_HMOVE_Table
   .byte HMOVE_L5 | 0, HMOVE_L4 | 0, HMOVE_L3 | 0, HMOVE_L2 | 0, HMOVE_L1 | 0
   .byte HMOVE_0  | 0, HMOVE_R1 | 0, HMOVE_R2 | 0, HMOVE_R3 | 0, HMOVE_R4 | 0
   .byte HMOVE_R5 | 0, HMOVE_R6 | 0, HMOVE_R7 | 0, HMOVE_R8 | 0

   .byte HMOVE_L6 | 1, HMOVE_L5 | 1, HMOVE_L4 | 1, HMOVE_L3 | 1, HMOVE_L2 | 1
   .byte HMOVE_L1 | 1, HMOVE_0  | 1, HMOVE_R1 | 1, HMOVE_R2 | 1, HMOVE_R3 | 1
   .byte HMOVE_R4 | 1, HMOVE_R5 | 1, HMOVE_R6 | 1, HMOVE_R7 | 1, HMOVE_R8 | 1
   
   .byte HMOVE_L6 | 2, HMOVE_L5 | 2, HMOVE_L4 | 2, HMOVE_L3 | 2, HMOVE_L2 | 2
   .byte HMOVE_L1 | 2, HMOVE_0  | 2, HMOVE_R1 | 2, HMOVE_R2 | 2, HMOVE_R3 | 2
   .byte HMOVE_R4 | 2, HMOVE_R5 | 2, HMOVE_R6 | 2, HMOVE_R7 | 2, HMOVE_R8 | 2
   
   .byte HMOVE_L6 | 3, HMOVE_L5 | 3, HMOVE_L4 | 3, HMOVE_L3 | 3, HMOVE_L2 | 3
   .byte HMOVE_L1 | 3, HMOVE_0  | 3, HMOVE_R1 | 3, HMOVE_R2 | 3, HMOVE_R3 | 3
   .byte HMOVE_R4 | 3, HMOVE_R5 | 3, HMOVE_R6 | 3, HMOVE_R7 | 3, HMOVE_R8 | 3
   
   .byte HMOVE_L6 | 4, HMOVE_L5 | 4, HMOVE_L4 | 4, HMOVE_L3 | 4, HMOVE_L2 | 4
   .byte HMOVE_L1 | 4, HMOVE_0  | 4, HMOVE_R1 | 4, HMOVE_R2 | 4, HMOVE_R3 | 4
   .byte HMOVE_R4 | 4, HMOVE_R5 | 4, HMOVE_R6 | 4, HMOVE_R7 | 4, HMOVE_R8 | 4
   
   .byte HMOVE_L6 | 5, HMOVE_L5 | 5, HMOVE_L4 | 5, HMOVE_L3 | 5, HMOVE_L2 | 5
   .byte HMOVE_L1 | 5, HMOVE_0  | 5, HMOVE_R1 | 5, HMOVE_R2 | 5, HMOVE_R3 | 5
   .byte HMOVE_R4 | 5, HMOVE_R5 | 5, HMOVE_R6 | 5, HMOVE_R7 | 5, HMOVE_R8 | 5
   
   .byte HMOVE_L6 | 6, HMOVE_L5 | 6, HMOVE_L4 | 6, HMOVE_L3 | 6, HMOVE_L2 | 6
   .byte HMOVE_L1 | 6, HMOVE_0  | 6, HMOVE_R1 | 6, HMOVE_R2 | 6, HMOVE_R3 | 6
   .byte HMOVE_R4 | 6, HMOVE_R5 | 6, HMOVE_R6 | 6, HMOVE_R7 | 6, HMOVE_R8 | 6

   .byte HMOVE_L6 | 7, HMOVE_L5 | 7, HMOVE_L4 | 7, HMOVE_L3 | 7, HMOVE_L2 | 7
   .byte HMOVE_L1 | 7, HMOVE_0  | 7, HMOVE_R1 | 7, HMOVE_R2 | 7, HMOVE_R3 | 7
   .byte HMOVE_R4 | 7, HMOVE_R5 | 7, HMOVE_R6 | 7, HMOVE_R7 | 7, HMOVE_R8 | 7

   .byte HMOVE_L6 | 8, HMOVE_L5 | 8, HMOVE_L4 | 8, HMOVE_L3 | 8, HMOVE_L2 | 8
   .byte HMOVE_L1 | 8, HMOVE_0  | 8, HMOVE_R1 | 8, HMOVE_R2 | 8

NUSIZValues
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY,    MSBL_SIZE1 | ONE_COPY
   .byte MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE
   .byte MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE
   .byte MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE
   .byte MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE
   .byte MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE, MSBL_SIZE1 | DOUBLE_SIZE
   .byte MSBL_SIZE1 | DOUBLE_SIZE

GameObjectColorOffsetValues
   .byte 0
   .byte BEE_COLOR_OFFSET
   .byte BEE_COLOR_OFFSET
   .byte EARWIG_COLOR_OFFSET
   .byte EARWIG_COLOR_OFFSET
   .byte EARWIG_COLOR_OFFSET
   .byte EARWIG_COLOR_OFFSET
   .byte SPIDER_COLOR_OFFSET
   .byte SPIDER_COLOR_OFFSET
   .byte SPIDER_COLOR_OFFSET
   .byte MOSQUITO_COLOR_OFFSET
   .byte MOSQUITO_COLOR_OFFSET
   .byte MOSQUITO_COLOR_OFFSET
   .byte MOSQUITO_COLOR_OFFSET
   .byte DRAGONFLY_COLOR_OFFSET
   .byte DRAGONFLY_COLOR_OFFSET
   .byte DRAGONFLY_COLOR_OFFSET
   .byte INCHWORM_COLOR_OFFSET
   .byte INCHWORM_COLOR_OFFSET
   .byte INCHWORM_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte BEETLE_COLOR_OFFSET
   .byte 0, 0, 0, 0, 0, 0
   .byte MILLIPEDE_COLOR_OFFSET
   .byte MILLIPEDE_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte BONUS_POINTS_COLOR_OFFSET
   .byte DDT_BOMB_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET
   .byte DDT_CLOUD_COLOR_OFFSET

CoarsePositionObject0Routines
CoarsePositionObject0ToCycle28
   sta RESP0                  ; 3 = @28
   tay                        ; 2         move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   stx tmpGRP0GraphicIndex    ; 3
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @44
   lda GameObjectColorOffsetValues,x;4
   adc gameWaveValues         ; 3
   tax                        ; 2
   lda BANK0_WaveColorValues,x; 4
   sta COLUP0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3

CoarsePositionObject0ToCycle33
   tay                        ; 2 = @27   move zone attributes to y register
   lda gameWaveValues         ; 3         get current game wave values
   sta RESP0                  ; 3 = @33
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   stx tmpGRP0GraphicIndex    ; 3
   adc GameObjectColorOffsetValues,x;4
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP0                 ; 3 = @53
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3

CoarsePositionObject0ToCycle38
   tay                        ; 2 = @27   move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta RESP0                  ; 3 = @38
   sta NUSIZ0                 ; 3 = @41
   stx tmpGRP0GraphicIndex    ; 3
   lda gameWaveValues         ; 3         get current game wave values
   adc GameObjectColorOffsetValues,x;4
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3
    
CoarsePositionObject0ToCycle43
   tay                        ; 2 = @27   move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   lda GameObjectColorOffsetValues,x;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   sta RESP0                  ; 3 = @43
   lda BANK0_WaveColorValues,y; 4
   sta COLUP0                 ; 3 = @50
   stx tmpGRP0GraphicIndex    ; 3
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3

CoarsePositionObject0ToCycle48
   tay                        ; 2 = @27   move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   stx tmpGRP0GraphicIndex    ; 3
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @41
   lda GameObjectColorOffsetValues,x;4
   sta RESP0                  ; 3 = @48
   adc gameWaveValues         ; 3
   tax                        ; 2
   lda BANK0_WaveColorValues,x; 4
   sta COLUP0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3

CoarsePositionObject0ToCycle53
   tay                        ; 2 = @27   move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   stx tmpGRP0GraphicIndex    ; 3
   lda GameObjectColorOffsetValues,x;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP0                 ; 3 = @50
   sta RESP0                  ; 3 = @53
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_00;3

CoarsePositionObject0ToCycle58
   tay                        ; 2 = @27   move zone attributes to y register
   lda spriteIdArray_R,y      ; 4         get sprite id value
   tay                        ; 2
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   tax                        ; 2
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @48
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   sta RESP0                  ; 3 = @58
   sty tmpGRP0GraphicIndex    ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta.w COLUP0               ; 4 = @71
   jmp .setHorizFineMotionForObject_01;3

CoarsePositionObject0ToCycle68
   tay                        ; 2 = @27   move zone attributes to y register
   lda spriteIdArray_R,y      ; 4         get sprite id value
   tay                        ; 2
   sty tmpGRP0GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @43
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP0                 ; 3 = @59
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   sta RESP0                  ; 3 = @68
   tax                        ; 2
   ldy objectHorizPositions_R,x;4
;--------------------------------------
   lda BANK0_HMOVE_Table,y    ; 4 = @02
   sta.w HMP1                 ; 4 = @06
   jmp .determineCoarsePositionRoutineForObject_01;3

CoarsePositionObject0ToCycle63
   tay                        ; 2 = @27   move zone attributes to y register
   ldx spriteIdArray_R,y      ; 4         get sprite id value
   stx tmpGRP0GraphicIndex    ; 3
   lda NUSIZValues,x          ; 4         get sprite NUSIZ value
   sta NUSIZ0                 ; 3 = @41
   lda GameObjectColorOffsetValues,x;4
   adc gameWaveValues         ; 3
   tax                        ; 2
   lda BANK0_WaveColorValues,x; 4
   sta COLUP0                 ; 3 = @57
   sta COLUP0                 ; 3 = @60
   sta RESP0                  ; 3 = @63
.doneHorizontalPositioningObject_00
   ldx tmpKernelZone_BANK0    ; 3         get current kernel zone index value
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   tax                        ; 2
;--------------------------------------
.setHorizFineMotionForObject_01
   ldy objectHorizPositions_R,x;4 = @02
   lda BANK0_HMOVE_Table,y    ; 4
   sta HMP1                   ; 3 = @09
.determineCoarsePositionRoutineForObject_01
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda CoarsePositionRoutineTableObject_01,y;4
   sta tmpCoarsePositionObject1Vector;3        
   jmp (tmpCoarsePositionObject1Vector);5 = @25

   .byte 0, 0                       ; not used

NormalMushroomPlayfieldMaskingValues
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte 0, 0                       ; not used

ReflectedMushroomPlayfieldMaskingValues
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte 0, 0                       ; not used

NormalFlowerPlayfieldMaskingValues
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, ODD_NORMAL_MUSHROOM_MASK
   .byte EVEN_NORMAL_MUSHROOM_MASK, 0, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0                       ; not used

ReflectedFlowerPlayfieldMaskingValues
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, ODD_REFLECTED_MUSHROOM_MASK
   .byte EVEN_REFLECTED_MUSHROOM_MASK, 0, 0, 0, 0, 0, 0, 0, 0, 0

SpriteGraphicsZone_05
   .byte $00 ; |........|
   .byte $99 ; |X..XX..X|
   .byte $18 ; |...XX...|
   .byte $2A ; |..X.X.X.|
   .byte $A8 ; |X.X.X...|
   .byte $15 ; |...X.X.X|
   .byte $54 ; |.X.X.X..|
   .byte $22 ; |..X...X.|
   .byte $41 ; |.X.....X|
   .byte $84 ; |X....X..|
   .byte $C4 ; |XX...X..|
   .byte $46 ; |.X...XX.|
   .byte $C0 ; |XX......|
   .byte $06 ; |.....XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $76 ; |.XXX.XX.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $14 ; |...X.X..|
   .byte $28 ; |..X.X...|
   .byte $34 ; |..XX.X..|
   .byte $2C ; |..X.XX..|
   .byte $28 ; |..X.X...|
   .byte $14 ; |...X.X..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $4A ; |.X..X.X.|
   .byte $11 ; |...X...X|
   .byte $40 ; |.X......|
   .byte $44 ; |.X...X..|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $80 ; |X.......|
   .byte $BB ; |X.XXX.XX|
   .byte $BB ; |X.XXX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $28 ; |..X.X...|
   .byte $68 ; |.XX.X...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7F ; |.XXXXXXX|
   .byte $77 ; |.XXX.XXX|
   .byte $76 ; |.XXX.XX.|
   .byte $72 ; |.XXX..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $14 ; |...X.X..|
   .byte $15 ; |...X.X.X|
   .byte $40 ; |.X......|

DDTCloudSpriteGraphicsZone_00
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
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $BA ; |X.XXX.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A8 ; |X.X.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $2A ; |..X.X.X.|
   .byte $7F ; |.XXXXXXX|
   .byte $0A ; |....X.X.|
   .byte $8E ; |X...XXX.|
   .byte $00 ; |........|

RightAudioRoutineVectorTable
   .byte <SetRightAudioChannelTone
   .byte <SetRightAudioChannelFrequency
   .byte <SetRightAudioChannelVolume
   .byte <SetRightSoundAudioDuration
   .byte <JumpToSetNextRightChannelIndexValue
   .byte <SetInsectSlowDownRightAudioChannelFrequency

CoarsePositionObject1Routines
CoarsePositionObject1ToCycle28
   sta RESP1                  ; 3 = @28
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @42
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @58
   SLEEP 2                    ; 2
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle33
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sta.w RESP1                ; 4 = @33
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @43
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta.w COLUP1               ; 4 = @60
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle38
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @38
   sty tmpGRP1GraphicIndex    ; 3
   sta NUSIZ1                 ; 3 = @44
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle43
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   sta.w RESP1                ; 4 = @43
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta.w COLUP1               ; 4 = @60
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle48
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   lda GameObjectColorOffsetValues,y;4
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @48
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle53
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @53
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @60
   jmp .doneHorizontalPositioningObject_01;3

CoarsePositionObject1ToCycle58
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @55
   sta RESP1                  ; 3 = @58
   SLEEP 2                    ; 2
   jmp .doneHorizontalPositioningObject_01;3
    
CoarsePositionObject1ToCycle68
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @55
   ldy shooterHorizPos        ; 3
   lda tmpKernelEnableBALL    ; 3
   ldx tmpKernelZone_BANK0    ; 3
   sta.w RESP1                ; 4 = @68
   SLEEP 2                    ; 2
   sta ENABL                  ; 3 = @73
   jmp NextScanlineAfterPositioningObject_01;3 = @76

CoarsePositionObject1ToCycle63
   ldy spriteIdArray_R,x      ; 4         get sprite id value
   sty tmpGRP1GraphicIndex    ; 3
   lda NUSIZValues,y          ; 4         get sprite NUSIZ value
   sta NUSIZ1                 ; 3 = @39
   lda GameObjectColorOffsetValues,y;4
   adc gameWaveValues         ; 3
   tay                        ; 2
   lda BANK0_WaveColorValues,y; 4
   sta COLUP1                 ; 3 = @55
   ldx shooterHorizPos        ; 3
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @63
.doneHorizontalPositioningObject_01
   lda tmpKernelEnableBALL    ; 3
   ldy shooterHorizPos        ; 3
   ldx tmpKernelZone_BANK0    ; 3
   sta.w ENABL                ; 4 = @76
;--------------------------------------
NextScanlineAfterPositioningObject_01
   bit kernelShooterState     ; 3
   bvc .performSoundRoutine   ; 2³        branch if not positioning Shooter
   lda BANK0_HMOVE_Table + 1,y; 4
   sta HMBL                   ; 3 = @12
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   beq .skipHorizontalPositioningShooter;2³
   lda CoarsePositionRoutineTableShooter - 1,y;4
   sta tmpCoarsePositionShooterVector;3        
   jmp (tmpCoarsePositionShooterVector);5

.skipHorizontalPositioningShooter
   lda kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   sta RESBL                  ; 3 = @28
   tay                        ; 2
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   ldx objectHorizPositions_R,y;4        
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3
    
.performSoundRoutine
    jmp (soundRoutineVector)  ; 5
    
PlayerShotEnableTable
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte ENABLE_BM
   .byte ENABLE_BM
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT
   .byte POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT

MillipedeNUSIZValuesPlayer_0
   .byte MSBL_SIZE2 | ONE_COPY,   MSBL_SIZE2 | ONE_COPY,   MSBL_SIZE2 | TWO_COPIES
   .byte MSBL_SIZE2 | TWO_COPIES, MSBL_SIZE2 | TWO_COPIES, MSBL_SIZE2 | TWO_COPIES

MillipedeNUSIZValuesPlayer_1
   .byte MSBL_SIZE4 | ONE_COPY,   MSBL_SIZE4 | ONE_COPY,   MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY,   MSBL_SIZE4 | TWO_COPIES, MSBL_SIZE4 | TWO_COPIES

CoarsePositionRoutineTableObject_01
   .byte <CoarsePositionObject1ToCycle28
   .byte <CoarsePositionObject1ToCycle33
   .byte <CoarsePositionObject1ToCycle38
   .byte <CoarsePositionObject1ToCycle43
   .byte <CoarsePositionObject1ToCycle48
   .byte <CoarsePositionObject1ToCycle53
   .byte <CoarsePositionObject1ToCycle58
   .byte <CoarsePositionObject1ToCycle63
   .byte <CoarsePositionObject1ToCycle68
   
CoarsePositionRoutineTableShooter
   .byte <CoarsePositionShooterToCycle33
   .byte <CoarsePositionShooterToCycle38
   .byte <CoarsePositionShooterToCycle43
   .byte <CoarsePositionShooterToCycle48
   .byte <CoarsePositionShooterToCycle53
   .byte <CoarsePositionShooterToCycle58
   .byte <CoarsePositionShooterToCycle63
   .byte <CoarsePositionShooterToCycle68

LeftAudioRoutineVectorTable
   .byte <SetLeftAudioChannelTone
   .byte <SetLeftAudioChannelFrequency
   .byte <SetLeftAudioChannelVolume
   .byte <SetLeftSoundAudioDuration
   .byte <JumpToSetNextLeftChannelIndexValue
    
SpriteGraphicsZone_04
   .byte $00 ; |........|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   .byte $9C ; |X..XXX..|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $39 ; |..XXX..X|
   .byte $24 ; |..X..X..|
   .byte $22 ; |..X...X.|
   .byte $C5 ; |XX...X.X|
   .byte $68 ; |.XX.X...|
   .byte $2C ; |..X.XX..|
   .byte $68 ; |.XX.X...|
   .byte $2C ; |..X.XX..|
   .byte $18 ; |...XX...|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $66 ; |.XX..XX.|
   .byte $76 ; |.XXX.XX.|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $90 ; |X..X....|
   .byte $4A ; |.X..X.X.|
   .byte $E0 ; |XXX.....|
   .byte $EE ; |XXX.XXX.|
   .byte $9F ; |X..XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $A3 ; |X.X...XX|
   .byte $AB ; |X.X.X.XX|
   .byte $9B ; |X..XX.XX|
   .byte $18 ; |...XX...|
   .byte $1A ; |...XX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FA ; |XXXXX.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $7A ; |.XXXX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
   
   FILL_BOUNDARY 5, 0

CoarsePositionShooterRoutines
CoarsePositionShooterToCycle33
   sta RESBL                  ; 3 = @33
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle38
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   sta RESBL                  ; 3 = @38
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle43
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   sta.w RESBL                ; 4 = @43
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle48
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   sta RESBL                  ; 3 = @48
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle53
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta.w RESBL                ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle58
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   sta.w RESBL                ; 4
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle63
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta RESBL                  ; 3
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3

CoarsePositionShooterToCycle68
   lda #POSITION_SHOOTER - 1  ; 2
   sta kernelShooterState     ; 3
   and kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   SLEEP 2                    ; 2
   sta RESBL                  ; 3
DrawKernelZoneObjects
   ldy tmpGRP0GraphicIndex    ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda SpriteGraphicsZone_00,y; 4
   sta GRP0                   ; 3 = @10
   ldy tmpGRP1GraphicIndex    ; 3
   lda SpriteGraphicsZone_00,y; 4
   sta GRP1                   ; 3 = @20
   ldx tmpKernelZone_BANK0    ; 3
   lda leftMushroomArray_R - 2,x;4
   and NormalMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF1MushroomGraphics;3
   lda leftMushroomArray_R - 2,x;4
   and ReflectedMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF2MushroomGraphics; 3
   lda rightMushroomArray_R - 2,x;4
   and ReflectedMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF1Graphics    ; 3
   lda rightMushroomArray_R - 2,x;4
   and NormalMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF2Graphics    ; 3
   lda SpriteGraphicsZone_01,y; 4
   sta GRP1                    ;3 = @74
;--------------------------------------
   ldy tmpGRP0GraphicIndex    ; 3 = @01
   lda SpriteGraphicsZone_01,y; 4
   sta GRP0                   ; 3 = @08
   lda shooterZoneBackgroundColor;3       get Shooter zone background color
   cpx shooterKernelZoneValue ; 3
   bne .skipColorShooterKernelZone;2³
   sta COLUBK                 ; 3 = @19   color Shooter zone background
   beq .determineMushroomZoneColorValue;3 unconditional branch

.skipColorShooterKernelZone
   SLEEP_5                    ; 5
.determineMushroomZoneColorValue
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   bpl .setColorForNormalMushroomZone;2³
   lda poisonedMushroomColor  ; 3
   jmp .colorZoneMushrooms    ; 3
    
.setColorForNormalMushroomZone
   lda tmpNormalMushroomColor ; 3
   SLEEP 2                    ; 2
.colorZoneMushrooms
   sta COLUPF                 ; 3 = @37
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_00;2³
   dec.w playerShotEnableIndex; 6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawSpriteGraphicsZone_02;3
    
.prepareToDrawShooter_00
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   stx CTRLPF                 ; 3 = @54
   stx kernelShooterState     ; 3
.drawSpriteGraphicsZone_02
   sta HMCLR                  ; 3 = @60
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @66
   lda tmpLeftPF1MushroomGraphics;3
   sta PF1                    ; 3 = @72
   lda SpriteGraphicsZone_02,y; 4
;--------------------------------------
   stx ENABL                  ; 3 = @03
   sta GRP0                   ; 3 = @06
   ldy tmpGRP1GraphicIndex    ; 3
   lda SpriteGraphicsZone_02,y; 4
   sta GRP1                   ; 3 = @16
   ldx tmpKernelZone_BANK0    ; 3
   lda #SKIP_DRAW_INSECT_ZONE ; 2
   sta kernelZoneAttributes_00,x;4        set to SKIP_DRAW_INSECT_ZONE
   and kernelZoneAttributes_01 - 1,x;4    keep MUSHROOM_POISON_MASK
   sta kernelZoneAttributes_01 - 1,x;4    set to ID_BLANK
   SLEEP 2                    ; 2
   lda.w tmpRightPF1Graphics  ; 4
   sta PF1                    ; 3 = @42
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda leftFlowerArray_R - 2,x; 4
   and NormalFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF1FlowerGraphics;3
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @65
   lda tmpLeftPF1MushroomGraphics;3
   sta PF1                    ; 3 = @71
   lda SpriteGraphicsZone_03,y; 4
;--------------------------------------
   sta GRP1                   ; 3 = @02
   ldy tmpGRP0GraphicIndex    ; 3
   lda SpriteGraphicsZone_03,y; 4
   sta GRP0                   ; 3 = @12
   lda leftFlowerArray_R - 2,x; 4
   and ReflectedFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF2FlowerGraphics;3
   lda rightFlowerArray_R - 2,x;4
   and ReflectedFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF1FlowerGraphics;3
   lda rightFlowerArray_R - 2,x;4
   and NormalFlowerPlayfieldMaskingValues - 2,x;4
   ldx tmpRightPF2Graphics    ; 3
   stx PF2                    ; 3 = @48
   ldx tmpRightPF1Graphics    ; 3
   stx PF1                    ; 3 = @54
   sta tmpRightPF2FlowerGraphics;3
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @63
   ldx tmpLeftPF1MushroomGraphics;3
   lda SpriteGraphicsZone_04,y; 4
   stx PF1                    ; 3 = @73
   sta GRP0                   ; 3 = @76
;--------------------------------------
   ldy tmpGRP1GraphicIndex    ; 3
   lda SpriteGraphicsZone_04,y; 4
   sta GRP1                   ; 3 = @10
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_01;2³
   dec.w playerShotEnableIndex; 6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawSpriteGraphicsZone_05;3
    
.prepareToDrawShooter_01
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   stx CTRLPF                 ; 3
   stx kernelShooterState     ; 3
.drawSpriteGraphicsZone_05
   lda SpriteGraphicsZone_05,y; 4
   cpx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   ldy tmpRightPF1Graphics    ; 3
   sty PF1                    ; 3 = @42
   ldy tmpRightPF2Graphics    ; 3
   sty PF2                    ; 3 = @48
   dec tmpKernelZone_BANK0    ; 5
   ldy tmpLeftPF2FlowerGraphics;3
   sty.w PF2                  ; 4 = @60
   bcs .setToFlashFlowerColor ; 2³        branch to color Flower graphic
   ldy tmpNormalMushroomColor ; 3         get normal Mushroom color
   jmp .colorFlower           ; 3
    
.setToFlashFlowerColor
   clc                        ; 2
   ldy poisonedMushroomColor  ; 3
.colorFlower
   sty COLUPF                 ; 3 = @71
   stx ENABL                  ; 3 = @74
;--------------------------------------
   sta GRP1                   ; 3 = @01
   ldy tmpGRP0GraphicIndex    ; 3
   lda SpriteGraphicsZone_05,y; 4
   sta GRP0                   ; 3 = @11
   lda tmpLeftPF1FlowerGraphics;3
   sta PF1                    ; 3 = @17
JumpIntoGraphicsZone_05
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_02;2³
   dec.w playerShotEnableIndex; 6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawRightFlowerGraphics;3
    
.prepareToDrawShooter_02
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   stx CTRLPF                 ; 3 = @34
   stx kernelShooterState     ; 3
.drawRightFlowerGraphics
   stx tmpKernelEnableBALL    ; 3
   lda #0                     ; 2
   ldx tmpRightPF2FlowerGraphics;3
   stx PF2                    ; 3 = @48
   ldx tmpRightPF1FlowerGraphics;3
   stx PF1                    ; 3 = @54
   ldx tmpObjectFineHorizValue; 3
   stx HMP0                   ; 3 = @60
   ldx tmpKernelZone_BANK0    ; 3
   sta PF2                    ; 3 = @66
   sta ENAM0                  ; 3 = @69
   sta PF1                    ; 3 = @72
   sta GRP1                   ; 3 = @75
;--------------------------------------
   sta GRP0                   ; 3 = @02
   lda tmpNormalMushroomColor ; 3
   sta COLUPF                 ; 3 = @08
   lda kernelZoneAttributes_00,x;4        get object 0 zone attributes
   bmi CheckToDrawMillipedeChain;2³       branch if SKIP_DRAW_INSECT_ZONE
   asl                        ; 2
   bmi .checkToDrawBitmapOrScoreKernel;2³ branch if DRAW_LITERAL_ZONE
   lsr                        ; 2         restore kernel zone attribute value
   jmp (tmpCoarsePositionObject0Vector);5

.checkToDrawBitmapOrScoreKernel
   cpx #5                     ; 2
   bcs .switchToDrawMiddleKernelBitmap;2³
   jmp BANK0_SwitchToScoreKernel;3
    
.switchToDrawMiddleKernelBitmap
   sta ENABL                  ; 3 = @27
   jmp BANK0_SwitchToSetupDrawBitmapKernel;3
    
CheckToDrawMillipedeChain
   asl                        ; 2 = @17
   bmi DrawMillipedeChainKernelZone;2³
   lda DDTCloudSpriteGraphicsZone_00,y;4
   sta GRP0                   ; 3 = @26
   tya                        ; 2
   cmp #ID_DDT_CLOUD          ; 2
   bcc .skipDDTCloudDrawing   ; 2³        branch if not drawing ID_DDT_CLOUD
   adc #H_DDT_CLOUD - 1       ; 2         carry set
   cmp #ID_DDT_CLOUD + 16     ; 2
   bcc .setDDTCloudGraphicIndexValue;2³   branch if drawing ID_DDT_CLOUD
   lda #0                     ; 2
   sta tmpGRP0GraphicIndex    ; 3
   jmp .drawDDTCloudGraphicZone_01;3
    
.skipDDTCloudDrawing
   lda #0                     ; 2
   sec                        ; 2
   SLEEP 2                    ; 2
.setDDTCloudGraphicIndexValue
   SLEEP 2                    ; 2
   sta tmpGRP0GraphicIndex    ; 3
   bcs .skipDDTCloudDrawingZone_01; 2³
.drawDDTCloudGraphicZone_01
   ldx DDTCloudSpriteGraphicsZone_01 - 48,y;4
   jmp .setDDTCloudGraphicsData;3

.skipDDTCloudDrawingZone_01
   tax                        ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.setDDTCloudGraphicsData
   lda #HMOVE_0               ; 2
   sta HMP0                   ; 3 = @58
   ldy tmpKernelZone_BANK0    ; 3
   lda kernelZoneAttributes_00,y;4        get object 0 zone attributes
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   clc                        ; 2
   stx GRP0                   ; 3 = @72
   tax                        ; 2
;--------------------------------------
   ldy objectHorizPositions_R,x;4 = @02
   lda BANK0_HMOVE_Table,y    ; 4
   sta HMP1                   ; 3 = @09
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda CoarsePositionRoutineTableObject_01,y;4
   sta tmpCoarsePositionObject1Vector;3        
   jmp (tmpCoarsePositionObject1Vector);5

DrawMillipedeChainKernelZone SUBROUTINE
   SLEEP 2                    ; 2 = @22
   lsr                        ; 2         restore kernelZoneAttribute value
   and #SPRITE_ID_IDX_MASK    ; 2
   tay                        ; 2
   lda MillipedeNUSIZValuesPlayer_0,y;4
   sta NUSIZ0                 ; 3 = @35
   lda MillipedeNUSIZValuesPlayer_1,y;4
   sta NUSIZ1                 ; 3 = @42
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   and #$7F                   ; 2
   tay                        ; 2
   lda BANK0_HMOVE_Table,y    ; 4
   sta HMP0                   ; 3 = @57
   clc                        ; 2
   adc #16                    ; 2
   sta HMP1                   ; 3 = @64
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   lda gameWaveValues         ; 3         get current game wave values
   clc                        ; 2
   adc #MILLIPEDE_COLOR_OFFSET; 2
;--------------------------------------
   and #7                     ; 2 = @01   0 <= a <= 7
   tax                        ; 2
   lda BANK0_WaveColorValues,x; 4
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   ldx.w shooterHorizPos      ; 4         get Shooter horizontal position
   lda BANK0_HMOVE_Table + 1,x; 4
.coarsePositionMillipede
   dey                        ; 2
   bpl .coarsePositionMillipede;2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   ldy #POSITION_SHOOTER - 1  ; 2
   sta WSYNC
;--------------------------------------
   ldx tmpKernelEnableBALL    ; 3
   stx ENABL                  ; 3 = @06
   bit kernelShooterState     ; 3
   bvc .drawKernelZoneObjects ; 2³
   sty kernelShooterState     ; 3
   sta HMBL                   ; 3 = @17
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
.coarsePositionShooter
   dey                        ; 2
   bpl .coarsePositionShooter ; 2³
   sta RESBL                  ; 3
.drawKernelZoneObjects
   ldy #DISABLE_BM            ; 2
   ldx tmpKernelZone_BANK0    ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   cpx millipedeBodyKernelZone; 3
   bne .drawMillipedeBody     ; 2³
   ldy #ENABLE_BM             ; 2
   bne .drawMillipedeChain_00 ; 3         unconditional branch

.drawMillipedeBody
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.drawMillipedeChain_00
   lda #$44                   ; 2
   sta GRP0                   ; 3 = @18
   sty ENAM0                  ; 3 = @21
   sta GRP1                   ; 3 = @24
   lda leftMushroomArray_R - 2,x;4
   and NormalMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF1MushroomGraphics;3
   lda leftMushroomArray_R - 2,x;4
   and ReflectedMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF2MushroomGraphics;3
   lda rightMushroomArray_R - 2,x;4
   and ReflectedMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF1Graphics    ; 3
   lda rightMushroomArray_R - 2,x;4
   and NormalMushroomPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF2Graphics    ; 3
   sty ENAM1                  ; 3 = @71
   lda #$EE                   ; 2
   sta GRP0                   ; 3 = @76
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda shooterZoneBackgroundColor;3       get Shooter zone background color
   cpx shooterKernelZoneValue ; 3
   bne .skipColorShooterKernelZone;2³
   sta COLUBK                 ; 3 = @14   color Shooter zone background
   beq .determineMushroomZoneColorValue;3 unconditional branch

.skipColorShooterKernelZone
   SLEEP_5                    ; 5
.determineMushroomZoneColorValue
   lda leftFlowerArray_R - 2,x; 4
   and NormalFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF1FlowerGraphics;3
   lda kernelZoneAttributes_01 - 1,x;4    get next kernel zone attribute value
   bpl .setColorForNormalMushroomZone;2³
   lda poisonedMushroomColor  ; 3
   jmp .colorZoneMushrooms    ; 3
    
.setColorForNormalMushroomZone
   lda tmpNormalMushroomColor ; 3
   SLEEP 2                    ; 2
.colorZoneMushrooms
   sta COLUPF                 ; 3 = @43
   ldy playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_00;2³
   dec.w playerShotEnableIndex; 6
   lda PlayerShotEnableTable,y; 4
   tay                        ; 2
   jmp .drawMillipedeChain_02 ; 3
    
.prepareToDrawShooter_00
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldy #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   sty CTRLPF                 ; 3
   sty kernelShooterState     ; 3
.drawMillipedeChain_02
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @69
   lda tmpLeftPF1MushroomGraphics;3
   sta PF1                    ; 3 = @75
;--------------------------------------
   sty ENABL                  ; 3 = @02
   lda #$FF                   ; 2
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   lda #SKIP_DRAW_INSECT_ZONE ; 2
   sta kernelZoneAttributes_00,x;4        set kernel zone attribute value
   and kernelZoneAttributes_01 - 1,x;4    clear SPRITE_ID_IDX
   sta kernelZoneAttributes_01 - 1,x;4    set next kernel zone to ID_BLANK
   lda leftFlowerArray_R - 2,x; 4
   and ReflectedFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpLeftPF2FlowerGraphics;3
   lda tmpRightPF1Graphics    ; 3
   sta.w PF1                  ; 4 = @42
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda rightFlowerArray_R - 2,x;4
   and ReflectedFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF1FlowerGraphics;3
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @65
   lda tmpLeftPF1MushroomGraphics;3
   sta PF1                    ; 3 = @71
   lda #$FF                   ; 2
   sta GRP0                   ; 3 = @76
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda kernelZoneAttributes_00 - 1,x;4    get next kernel zone attribute value
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   ldx tmpKernelZone_BANK0    ; 3
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @42
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda rightFlowerArray_R - 2,x;4
   and NormalFlowerPlayfieldMaskingValues - 2,x;4
   sta tmpRightPF2FlowerGraphics;3
   lda tmpLeftPF2MushroomGraphics;3
   sta PF2                    ; 3 = @65
   lda tmpLeftPF1MushroomGraphics;3
   sta PF1                    ; 3 = @71
   sta HMCLR                  ; 3 = @74
   SLEEP 2                    ; 2
;--------------------------------------
   lda #$EE                   ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_01;2³
   dec.w playerShotEnableIndex; 6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawMillipedeChain_05 ; 3
    
.prepareToDrawShooter_01
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   stx CTRLPF                 ; 3 = @25
   stx kernelShooterState     ; 3
.drawMillipedeChain_05
   dec.w tmpKernelZone_BANK0  ; 6
   SLEEP 2                    ; 2
   ldy tmpRightPF1Graphics    ; 3
   sty PF1                    ; 3 = @42
   ldy tmpRightPF2Graphics    ; 3
   sty PF2                    ; 3 = @48
   cpx #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   bcs .setToFlashFlowerColor ; 2³
   ldy tmpNormalMushroomColor ; 3
   jmp .colorFlower           ; 3
    
.setToFlashFlowerColor
   ldy poisonedMushroomColor  ; 3
   clc                        ; 2
.colorFlower
   lda tmpLeftPF2FlowerGraphics;3
   sta PF2                    ; 3 = @64
   lda tmpLeftPF1FlowerGraphics;3
   sta.w PF1                  ; 4 = @71
   sty COLUPF                 ; 3 = @74
;--------------------------------------
   stx ENABL                  ; 3 = @01
   ldy #DISABLE_BM            ; 2
   sty ENAM1                  ; 3 = @06
   lda #$44                   ; 2
   sta GRP0                   ; 3 = @11
   sta GRP1                   ; 3 = @14
   jmp JumpIntoGraphicsZone_05; 3
    
SpriteGraphicsZone_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C3 ; |XX....XX|
   .byte $15 ; |...X.X.X|
   .byte $54 ; |.X.X.X..|
   .byte $2A ; |..X.X.X.|
   .byte $A8 ; |X.X.X...|
   .byte $66 ; |.XX..XX.|
   .byte $41 ; |.X.....X|
   .byte $22 ; |..X...X.|
   .byte $86 ; |X....XX.|
   .byte $C2 ; |XX....X.|
   .byte $06 ; |.....XX.|
   .byte $C0 ; |XX......|
   .byte $A5 ; |X.X..X.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BA ; |X.XXX.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $40 ; |.X......|
   .byte $44 ; |.X...X..|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $BB ; |X.XXX.XX|
   .byte $BB ; |X.XXX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $2A ; |..X.X.X.|
   .byte $28 ; |..X.X...|
   .byte $08 ; |....X...|
   .byte $28 ; |..X.X...|
   .byte $14 ; |...X.X..|
   .byte $1E ; |...XXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BE ; |X.XXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $38 ; |..XXX...|

SpriteGraphicsZone_01
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $DB ; |XX.XX.XX|
   .byte $9C ; |X..XXX..|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $39 ; |..XXX..X|
   .byte $98 ; |X..XX...|
   .byte $1A ; |...XX.X.|
   .byte $59 ; |.X.XX..X|
   .byte $4C ; |.X..XX..|
   .byte $64 ; |.XX..X..|
   .byte $2C ; |..X.XX..|
   .byte $68 ; |.XX.X...|
   .byte $C3 ; |XX....XX|
   .byte $5A ; |.X.XX.X.|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $36 ; |..XX.XX.|
   .byte $6C ; |.XX.XX..|
   .byte $36 ; |..XX.XX.|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $6C ; |.XX.XX..|
   .byte $36 ; |..XX.XX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7D ; |.XXXXX.X|
   .byte $5D ; |.X.XXX.X|
   .byte $E0 ; |XXX.....|
   .byte $EE ; |XXX.XXX.|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $9F ; |X..XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $8B ; |X...X.XX|
   .byte $AB ; |X.X.X.XX|
   .byte $91 ; |X..X...X|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $34 ; |..XX.X..|
   .byte $7D ; |.XXXXX.X|
   .byte $54 ; |.X.X.X..|
   .byte $45 ; |.X...X.X|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $3A ; |..XXX.X.|
   .byte $7A ; |.XXXX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $55 ; |.X.X.X.X|
   .byte $1C ; |...XXX..|
   .byte $54 ; |.X.X.X..|

SetToLeftChannelSoundRoutineAndContinueKernel
   lda #<PerformLeftChannelSoundRoutine;2
SetNextSoundVectorAndContinueKernel
   sta soundRoutineVector     ; 3
ContinueKernelFromSoundRoutines
   lda #SPRITE_ID_IDX_MASK    ; 2
   and kernelZoneAttributes_00 - 1,x;4    keep SPRITE_ID_IDX value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK0_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   lda BANK0_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   jmp DrawKernelZoneObjects  ; 3
    
   FILL_BOUNDARY 256, 0

SpriteGraphicsZone_02
   .byte $00 ; |........|
   .byte $5A ; |.X.XX.X.|
   .byte $DB ; |XX.XX.XX|
   .byte $5E ; |.X.XXXX.|
   .byte $7B ; |.XXXX.XX|
   .byte $DE ; |XX.XXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $DB ; |XX.XX.XX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $58 ; |.X.XX...|
   .byte $34 ; |..XX.X..|
   .byte $99 ; |X..XX..X|
   .byte $DB ; |XX.XX.XX|
   .byte $5A ; |.X.XX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $6C ; |.XX.XX..|
   .byte $36 ; |..XX.XX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $FE ; |XXXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $F0 ; |XXXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $F5 ; |XXXX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $35 ; |..XX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $D5 ; |XX.X.X.X|
   .byte $B8 ; |X.XXX...|
   .byte $B8 ; |X.XXX...|
   .byte $AB ; |X.X.X.XX|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $7A ; |.XXXX.X.|
   .byte $6E ; |.XX.XXX.|
   .byte $EA ; |XXX.X.X.|
   .byte $E8 ; |XXX.X...|
   .byte $48 ; |.X..X...|
   .byte $00 ; |........|
   .byte $2C ; |..X.XX..|
   .byte $3C ; |..XXXX..|
   .byte $5E ; |.X.XXXX.|
   .byte $BB ; |X.XXX.XX|
   .byte $EA ; |XXX.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $8E ; |X...XXX.|

SpriteGraphicsZone_03
   .byte $00 ; |........|
   .byte $DB ; |XX.XX.XX|
   .byte $5A ; |.X.XX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7B ; |.XXXX.XX|
   .byte $DE ; |XX.XXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $99 ; |X..XX..X|
   .byte $18 ; |...XX...|
   .byte $5A ; |.X.XX.X.|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $34 ; |..XX.X..|
   .byte $58 ; |.X.XX...|
   .byte $5A ; |.X.XX.X.|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $34 ; |..XX.X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $3D ; |..XXXX.X|
   .byte $1C ; |...XXX..|
   .byte $F0 ; |XXXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $95 ; |X..X.X.X|
   .byte $35 ; |..XX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $35 ; |..XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $35 ; |..XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $D5 ; |XX.X.X.X|
   .byte $A0 ; |X.X.....|
   .byte $A8 ; |X.X.X...|
   .byte $AB ; |X.X.X.XX|
   .byte $10 ; |...X....|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $F7 ; |XXXX.XXX|
   .byte $5D ; |.X.XXX.X|
   .byte $5C ; |.X.XXX..|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $14 ; |...X.X..|
   .byte $34 ; |..XX.X..|
   .byte $3C ; |..XXXX..|
   .byte $F5 ; |XXXX.X.X|
   .byte $5D ; |.X.XXX.X|
   .byte $77 ; |.XXX.XXX|
   .byte $24 ; |..X..X..|
   
   FILL_BOUNDARY 136, 0

DetermineToContinueHeartbeatSounds
   ldy numberOfMillipedeSegments;3        get number of Millipede segments
   bmi .doneDetermineToContinueHeartbeatSounds;2³ branch if no more segments
   ldy leftSoundChannelIndex  ; 3         get left sound channel index value
   beq .setToPerformHeartbeatSounds;2³
   cpy #<[PlayerShotAudioValues - LeftSoundChannelValues];2
   bcc .doneDetermineToContinueHeartbeatSounds;2³
.setToPerformHeartbeatSounds
   lda #<PerformPlayHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
.doneDetermineToContinueHeartbeatSounds
   lda #<DonePerformSoundRoutines;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
PlayHeartbeatSounds
   lda tmpAudioValue          ; 3 = @17
   beq .turnOffHeartbeatSounds; 2³
   lda #7                     ; 2
   sta AUDF0                  ; 3 = @24
   lda #7                     ; 2
   sta AUDV0                  ; 3 = @29
.donePerformSoundRoutines
   lda #<DonePerformSoundRoutines;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
.turnOffHeartbeatSounds
   sta AUDV0                  ; 3 = @23
   sta AUDF0                  ; 3 = @26
   beq .donePerformSoundRoutines;3        unconditional branch

SetNextLeftChannelIndexValue
   ldy leftSoundChannelIndex  ; 3         get left sound channel index value
   lda LeftSoundChannelValues + 1,y;4
   sta leftSoundChannelIndex  ; 3
   jmp SetToLeftChannelSoundRoutineAndContinueKernel;3

SetNextRightChannelIndexValue
   ldy rightSoundChannelIndex ; 3         get right sound channel index value
   lda RightSoundChannelValues + 1,y;4
   sta rightSoundChannelIndex ; 3
   lda #<PerformRightChannelSoundRoutine;2
   jmp SetNextSoundVectorAndContinueKernel;3

DecrementLeftSoundAudioDuration
   lda leftSoundAudioDuration ; 3         get sound duration value
   beq .doneDecrementLeftSoundAudioDuration;2³
   dec leftSoundAudioDuration ; 5         decrement sound duration value
   lda #<HoldRightChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
.doneDecrementLeftSoundAudioDuration
   lda #<PerformLeftChannelSoundRoutine;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
DonePlayingLeftSoundRoutine
   sta leftSoundChannelIndex  ; 3
   lda #<HoldLeftChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3

DonePlayingRightSoundRoutine
   sta rightSoundChannelIndex ; 3
   lda #<HoldRightChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
DecrementRightSoundAudioDuration
   lda rightSoundAudioDuration; 3
   beq .doneDecrementRightSoundAudioDuration;2³
   dec rightSoundAudioDuration; 5
   lda #<JumpToDetermineToContinueHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3

.doneSetInsectSlowDownAudioChannelFrequency
   sta rightSoundChannelIndex ; 3
   lda #<JumpToDetermineToContinueHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3

.doneDecrementRightSoundAudioDuration
   lda #<PerformRightChannelSoundRoutine;2
   jmp SetNextSoundVectorAndContinueKernel;3

BANK0_SoundRoutines
HoldLeftChannelAudioSound
   lda leftSoundChannelIndex  ; 3         get left sound channel index value
   bne DecrementLeftSoundAudioDuration;2³ + 1
   sta AUDC0                  ; 3
   sta AUDV0                  ; 3
   sta AUDF0                  ; 3
   sta leftSoundAudioDuration ; 3
   lda #<HoldRightChannelAudioSound;2
   sta soundRoutineVector     ; 3
DonePerformSoundRoutines
   jmp ContinueKernelFromSoundRoutines;3
    
PerformLeftChannelSoundRoutine
   ldy leftSoundChannelIndex  ; 3         get left sound channel index value
   lda LeftSoundChannelValues,y;4
   beq DonePlayingLeftSoundRoutine;2³     branch if reached end of sound routine
   sta tmpAudioValue          ; 3         set audio value
   and #7                     ; 2         keep AUDIO_STRATEGY_INDEX
   tay                        ; 2
   lda LeftAudioRoutineVectorTable,y;4
   jmp SetNextSoundVectorAndContinueKernel;3

HoldRightChannelAudioSound
   lda rightSoundChannelIndex ; 3 = @14   get right sound channel index value
   bne DecrementRightSoundAudioDuration;2³ + 1
   sta AUDC1                  ; 3 = @19
   sta AUDV1                  ; 3 = @22
   sta AUDF1                  ; 3 = @25
   sta rightSoundAudioDuration; 3
   lda #<JumpToDetermineToContinueHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3

PerformRightChannelSoundRoutine
   ldy rightSoundChannelIndex ; 3         get right sound channel index value
   lda RightSoundChannelValues,y;4
   beq DonePlayingRightSoundRoutine;2³ + 1 branch if reached end of sound routine
   sta tmpAudioValue          ; 3         set audio value
   and #7                     ; 2         keep AUDIO_STRATEGY_INDEX
   tay                        ; 2
   lda RightAudioRoutineVectorTable,y;4
   jmp SetNextSoundVectorAndContinueKernel;3

SetInsectSlowDownRightAudioChannelFrequency
   lda inchwormWaveState      ; 3         get Inchworm wave state
   beq .doneSetInsectSlowDownAudioChannelFrequency;2³ + 1
   lsr                        ; 2         divide value by 2
   eor #$FF                   ; 2         flip bits
   sta AUDF1                  ; 3 = @23
   inc rightSoundChannelIndex ; 5         increment right sound channel index
   lda #<HoldRightChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3

SetLeftAudioChannelTone
   lda tmpAudioValue          ; 3 = @14
   inc leftSoundChannelIndex  ; 5         increment left sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDC0                  ; 3 = @28
   jmp SetToLeftChannelSoundRoutineAndContinueKernel;3

SetLeftAudioChannelFrequency
   lda tmpAudioValue          ; 3 = @14
   inc leftSoundChannelIndex  ; 5         increment left sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDF0                  ; 3 = @28
   jmp SetToLeftChannelSoundRoutineAndContinueKernel;3

SetLeftAudioChannelVolume
   lda tmpAudioValue          ; 3 = @14
   inc leftSoundChannelIndex  ; 5         increment left sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDV0                  ; 3 = @28
   lda #<HoldRightChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3

SetLeftSoundAudioDuration
   lda tmpAudioValue          ; 3 = @14
   inc leftSoundChannelIndex  ; 5         increment left sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta leftSoundAudioDuration ; 3
   lda #<HoldRightChannelAudioSound;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
JumpToSetNextLeftChannelIndexValue
   jmp SetNextLeftChannelIndexValue;3

SetRightAudioChannelTone
   lda tmpAudioValue          ; 3 = @14
   inc rightSoundChannelIndex ; 5         increment right sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDC1                  ; 3 = @28
   lda #<PerformRightChannelSoundRoutine;2
   jmp SetNextSoundVectorAndContinueKernel;3

SetRightAudioChannelFrequency
   lda tmpAudioValue          ; 3 = @14
   inc rightSoundChannelIndex ; 5         increment right sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDF1                  ; 3 = @28
   lda #<PerformRightChannelSoundRoutine;2
   jmp SetNextSoundVectorAndContinueKernel;3

SetRightAudioChannelVolume
   lda tmpAudioValue          ; 3 = @14
   inc rightSoundChannelIndex ; 5         increment right sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta AUDV1                  ; 3 = @28
   lda #<JumpToDetermineToContinueHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3

SetRightSoundAudioDuration
   lda tmpAudioValue          ; 3 = @14
   inc rightSoundChannelIndex ; 5         increment right sound channel index
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sta rightSoundAudioDuration; 3
   lda #<JumpToDetermineToContinueHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3

JumpToSetNextRightChannelIndexValue
   jmp SetNextRightChannelIndexValue;3

JumpToDetermineToContinueHeartbeatSounds
   jmp DetermineToContinueHeartbeatSounds;3

PerformPlayHeartbeatSounds
   ldy #<-1                   ; 2 = @13
   lda frameCount             ; 3         get current frame count
   and #$0F                   ; 2         0 <= a <= 15
   beq .playHeartbeatSounds   ; 2³
   cmp #1                     ; 2
   bne .donePerformPlayHeartbeatSounds;2³
   iny                        ; 2         y = 0
.playHeartbeatSounds
   sty tmpAudioValue          ; 3
   lda #<JumpToPlayHeartbeatSounds;2
   jmp SetNextSoundVectorAndContinueKernel;3
    
.donePerformPlayHeartbeatSounds
   lda #<DonePerformSoundRoutines;2
   jmp SetNextSoundVectorAndContinueKernel;3

JumpToPlayHeartbeatSounds
   jmp PlayHeartbeatSounds    ; 3
    
   FILL_BOUNDARY 256, 0
    
RightSoundChannelValues
   .byte END_AUDIO_TUNE

ExtraLifeAudioValues
   SET_AUDIO_TONE       6
   SET_AUDIO_FREQUENCY  6
   SET_AUDIO_VOLUME     3
   SET_AUDIO_DURATION   3
   SET_AUDIO_VOLUME     0
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   4
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_DURATION   5
   SET_AUDIO_FREQUENCY 23
   SET_AUDIO_DURATION  11
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_DURATION   5
   SET_AUDIO_FREQUENCY 23
   SET_AUDIO_DURATION  23
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_DURATION   5
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_DURATION   5
   SET_AUDIO_FREQUENCY 11
   SET_AUDIO_DURATION  11
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_DURATION   5
   SET_AUDIO_FREQUENCY 11
   SET_AUDIO_DURATION  12
   .byte END_AUDIO_TUNE

InsectSlowDownAudioValues
   SET_AUDIO_TONE       4
   SET_SLOWDOWN_AUDIO_FREQUENCY 0
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   2
   SET_AUDIO_TONE      12
   SET_SLOWDOWN_AUDIO_FREQUENCY 0
   SET_AUDIO_DURATION   3
   JMP_AUDIO_START (<[InsectSlowDownAudioValues - RightSoundChannelValues])

EarwigAudioValues
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 24
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 15
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 21
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   JMP_AUDIO_START (<[EarwigAudioValues - RightSoundChannelValues] + 1)

DragonflyAudioValues    
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 31
   SET_AUDIO_VOLUME     3
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 30
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 29
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 28
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_VOLUME     6
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 26
   SET_AUDIO_VOLUME     7
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_VOLUME     6
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 28
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 29
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 30
   SET_AUDIO_DURATION   1
   JMP_AUDIO_START (<[DragonflyAudioValues - RightSoundChannelValues] + 1)

BeetleAudioValues
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 24
   SET_AUDIO_VOLUME     4
   SET_AUDIO_VOLUME     0
   SET_AUDIO_VOLUME     4
   SET_AUDIO_VOLUME     0
   JMP_AUDIO_START (<[BeetleAudioValues - RightSoundChannelValues] + 1)

InchwormAudioValues
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_VOLUME     8
   SET_AUDIO_FREQUENCY  9
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 10
   SET_AUDIO_VOLUME     6
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 14
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 16
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_VOLUME     2
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 16
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 14
   SET_AUDIO_VOLUME     6
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 10
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY  9
   SET_AUDIO_VOLUME     8
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   3
   JMP_AUDIO_START (<[InchwormAudioValues - RightSoundChannelValues] + 1)

SpiderAudioValues
   SET_AUDIO_TONE       4
   SET_AUDIO_FREQUENCY  4
   SET_AUDIO_VOLUME     1
   SET_AUDIO_DURATION   0
   SET_AUDIO_TONE      13
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_VOLUME     6
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_TONE       4
   SET_AUDIO_FREQUENCY  4
   SET_AUDIO_VOLUME     1
   SET_AUDIO_DURATION   0
   SET_AUDIO_TONE      13
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_VOLUME     4
   SET_AUDIO_DURATION   0
   SET_AUDIO_VOLUME     0
   SET_AUDIO_DURATION   0
   JMP_AUDIO_START (<[SpiderAudioValues - RightSoundChannelValues] + 1)

MosquitoAudioValues
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 31
   SET_AUDIO_VOLUME     5
   SET_AUDIO_VOLUME     3
   SET_AUDIO_FREQUENCY 30
   SET_AUDIO_VOLUME     5
   SET_AUDIO_FREQUENCY 28
   SET_AUDIO_VOLUME     7
   SET_AUDIO_FREQUENCY 24
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_VOLUME     5
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_VOLUME     3
   SET_AUDIO_TONE      15
   SET_AUDIO_FREQUENCY  9
   SET_AUDIO_VOLUME     5
   SET_AUDIO_VOLUME     0
   JMP_AUDIO_START (<[MosquitoAudioValues - RightSoundChannelValues] + 16)

BeeAudioValues
   SET_AUDIO_TONE      13
   SET_AUDIO_FREQUENCY 14
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 15
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 16
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 20
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 21
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 22
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 23
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 24
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 25
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 26
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 28
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 29
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 30
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 31
   SET_AUDIO_DURATION   2
   .byte END_AUDIO_TUNE
    
   FILL_BOUNDARY 256, 0
    
LeftSoundChannelValues
   .byte END_AUDIO_TUNE

ShooterCollisionAudioValues
   SET_AUDIO_FREQUENCY  0
   SET_AUDIO_TONE       3
   SET_AUDIO_VOLUME     5
   SET_AUDIO_TONE       3
   SET_AUDIO_DURATION   0
   JMP_AUDIO_START (<[ShooterCollisionAudioValues - LeftSoundChannelValues] + 1)

ShooterMeltingAudioValues    
   SET_AUDIO_FREQUENCY 11
   SET_AUDIO_TONE       4
   SET_AUDIO_VOLUME    12
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 15
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_DURATION   2
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 21
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 23
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 25
   SET_AUDIO_DURATION   3
   SET_AUDIO_VOLUME     2
   SET_AUDIO_FREQUENCY 27
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 29
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 31
   SET_AUDIO_DURATION   2
   SET_AUDIO_FREQUENCY  0
   SET_AUDIO_VOLUME     0
   JMP_AUDIO_START (<[ShooterMeltingAudioValues - LeftSoundChannelValues] + 26)

DDTBombExplosionAudioValues
   SET_AUDIO_TONE       8
   SET_AUDIO_FREQUENCY 16
   SET_AUDIO_VOLUME     9
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 22
   SET_AUDIO_VOLUME     7
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 28
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 31
   SET_AUDIO_DURATION   3
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_VOLUME     7
   SET_AUDIO_DURATION   0
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_VOLUME     5
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 15
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_DURATION   1
   SET_AUDIO_FREQUENCY  4
   SET_AUDIO_DURATION   0
   .byte END_AUDIO_TUNE

MushroomTallyAudioValues
   SET_AUDIO_TONE       8
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_VOLUME     8
   SET_AUDIO_VOLUME     6
   SET_AUDIO_VOLUME     4
   SET_AUDIO_VOLUME     2
   .byte END_AUDIO_TUNE

PlayerShotAudioValues
   SET_AUDIO_TONE       8
   SET_AUDIO_FREQUENCY  3
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  4
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  5
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  6
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  7
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  8
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY  9
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 10
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 11
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 12
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 13
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 14
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 15
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 16
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 17
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 19
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 20
   SET_AUDIO_VOLUME     4
   SET_AUDIO_FREQUENCY 21
   SET_AUDIO_VOLUME     4
   .byte END_AUDIO_TUNE

StartingScoreSelectionAudioValues
   SET_AUDIO_TONE       5
   SET_AUDIO_FREQUENCY 18
   SET_AUDIO_VOLUME     5
   SET_AUDIO_DURATION   2
   .byte END_AUDIO_TUNE
   
   IF ORIGINAL_ROM
   
      .byte $68,$79,$2A,$23,$02,$03,$81,$2A,$23,$02,$03,$91,$2a,$23,$02,$03,$A1
      .byte $3A,$23,$02,$5B,$91,$2A,$23,$02,$03,$C1,$3A,$23,$02,$1B,$A1,$2A,$03
      .byte $02,$91,$2A,$03,$02,$81,$2A,$02,$79,$32,$FB,$02,$13,$40,$41,$3A,$23
      .byte $00

      .byte " DAVE STAUGAS LOVES BEATRICE HABLIG "

   ENDIF

   FILL_BOUNDARY 222, 0

BANK0_SwitchToSetupDrawBitmapKernel
   lda BANK2STROBE
   jmp JumpIntoGraphicsZone_05

   lda BANK0STROBE                  ; not referenced in BANK0
   jmp SetupGameDisplayKernel
    
BANK0_SwitchToScoreKernel
   lda BANK2STROBE
   jmp.w $00
    
BANK0_Start
   lda BANK3STROBE
   jmp BANK3_Start
    
   .byte 0, 0, 0, 0                 ; hotspot locations not available for data

   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK0"
   
   .word BANK0_Start
   .word BANK0_Start
   .word BANK0_Start

;===============================================================================
; R O M - C O D E (BANK1)
;===============================================================================

   SEG Bank1
   .org BANK1_BASE
   .rorg BANK1_REORG

FREE_BYTES SET 0

   .ds 256, 0                       ; first page reserved for Superchip RAM

Overscan
   lda #0
   sta tmpThousandsPoints
   sta tmpHundredsPoints
   sta tmpOnesPoints
   lda inchwormWaveState            ; get Inchworm wave state
   bpl CheckToSpawnMillipedeHead    ; branch if PLAYER_MOVEMENT_NORMAL
   and #INSECT_SPEED_MASK           ; keep OBJECT_SPEED value
   bne .doneCheckToSpawnMillipedeHead;branch if INSECT_SPEED_SLOW
   lda inchwormWaveState            ; get Inchworm wave state
   cmp #PLAYER_MOVEMENT_HALT | 2
   bne .checkIfEnoughTimeToBuildMillipedeSegments
   lda tmpRemainingMushroomPointValue;get point value for Mushroom tally
   sta tmpOnesPoints
   lda #0
   sta tmpRemainingMushroomPointValue;clear Mushroom point value tally
.checkIfEnoughTimeToBuildMillipedeSegments
   jmp CheckIfEnoughTimeToBuildMillipedeSegments
    
CheckToSpawnMillipedeHead
   lda gameState                    ; get current game state
   and #SPAWN_HEAD_MASK             ; keep GS_SPAWN_MILLIPEDE_HEAD value
   beq .doneCheckToSpawnMillipedeHead
   ldx numberOfMillipedeSegments    ; get number of Millipede segments
   bmi .doneCheckToSpawnMillipedeHead;branch if no more Millipede segments
   cpx #6
   bcs .doneCheckToSpawnMillipedeHead
   lda frameCount + 1               ; get frame count high byte value
   lsr                              ; shift D0 to carry
   lda frameCount                   ; get current frame count
   ror
   bcs .doneCheckToSpawnMillipedeHead;branch on odd frame
   ldy playerScore                  ; get score thousands value
   cpy #$10
   bmi .checkPlayerScoreLessThan40000;branch if less than 100,000
   and #$3F                         ; 0 <= a <= 63
   bpl .checkToSpawnMillipedeHead   ; unconditional branch
    
.checkPlayerScoreLessThan40000
   cpy #4
   bmi .checkToSpawnMillipedeHead   ; branch if score less than 40,000
   and #$7F                         ; 0 <= a <= 127
.checkToSpawnMillipedeHead
   cmp #13
   bne .doneCheckToSpawnMillipedeHead
   inx
   stx numberOfMillipedeSegments    ; increment number of Millipede segments
   lda random
   and #4
   bne .launchHeadFromRight
   sta millipedeHorizPosition,x
   lda #MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT | 7
   sta millipedeSegmentState,x
   bne .setSpawnedHeadAttributes    ; unconditional branch

.launchHeadFromRight
   lda #XMAX - W_MILLIPEDE_HEAD
   sta millipedeHorizPosition,x
   lda #MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_RIGHT | 7
   sta millipedeSegmentState,x
.setSpawnedHeadAttributes
   lda #MILLIPEDE_FAST
   sta millipedeAttributes_W,x
.doneCheckToSpawnMillipedeHead
   clc
   lda shotVertPos                  ; get Shot vertical position
   bne CheckShotCollisions          ; branch if Shot active
   sec
CheckShotCollisions
   lda #MAX_KERNEL_SECTIONS + 1
   sbc shotVertPos                  ; subtract Shot vertical position
   sta tmpShotUpperKernelZone
   sta tmpShotLowerKernelZone
   dec tmpShotLowerKernelZone
   lda #[SHOOTER_YMAX + H_SHOOTER] - 1
   sbc shooterVertPos               ; subtract Shooter vertical position
   tay
   lda BANK1_ShooterKernelZoneValues,y;get Shooter KERNEL_ZONE value
   sta tmpShooterKernelZone
   cmp tmpShotUpperKernelZone       ; compare with Shot upper kernel zone
   bcc DetermineDDTCloudCollisionBoundaries;branch if below Shot kernel zone
   inc tmpShotLowerKernelZone
DetermineDDTCloudCollisionBoundaries
   ldy #3
   lda frameCount                   ; get current frame count
   and #3                           ; 0 <= a <= 3
   tax
.determineDDTCloudCollisionBoundaries
   lda ddtBombSpriteIds_R + 1,x     ; get DDT sprite id value
   cmp #ID_DDT_CLOUD
   bcs .setDDTCloudCollisionBoundaryValues;branch if ID_DDT_CLOUD
   dex
   bpl .nextDDTCloudCollisionBoundaryCheck
   ldx #3
.nextDDTCloudCollisionBoundaryCheck
   dey
   bpl .determineDDTCloudCollisionBoundaries
   lda #0
   sta tmpDDTCloudUpperKernelZone
   sta tmpDDTCloudLowerKernelZone
   beq CheckObjectCollisions        ; unconditional branch
    
.setDDTCloudCollisionBoundaryValues
   lda ddtBombHorizPosition_R + 1,x ; get ID_DDT_CLOUD horizontal position
   sta tmpDDTCloudHorizPosition
   lda ddtBombAttributes_R + 1,x    ; get ID_DDT_CLOUD attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta tmpDDTCloudUpperKernelZone
   sec
   sbc #1
   sta tmpDDTCloudLowerKernelZone
CheckObjectCollisions
   ldx #1
.checkShotCollisionWithDDTBomb
   lda ddtBombAttributes_R,x        ; get DDT bomb attribute values
   beq .checkNextDDTBombShotCollision;branch if DDT not present
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpShotUpperKernelZone       ; compare with Shot upper kernel zone
   beq ShotWithinObjectZone
.checkNextDDTBombShotCollision
   inx
   cpx #MAX_DDT_BOMBS
   bcc .checkShotCollisionWithDDTBomb
.checkCreatureShotCollisions
   lda creatureAttributes_R - MAX_DDT_BOMBS,x;get object attribute values
   beq .checkNextCreatureShotCollision;branch if object not present
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpShotLowerKernelZone       ; compare with Shot lower kernel zone
   beq CreatureWithinShotVertRange
CheckCreatureVerticalRangeCollisions
   cmp tmpShotUpperKernelZone       ; compare with Shot upper kernel zone
   beq CreatureWithinShotVertRange
.checkCreatureWithinShooterVertRange
   cmp tmpShooterKernelZone
   beq CreatureWithinShooterVertRange
.checkObjectWithinDDTCloudVertRange
   cmp tmpDDTCloudUpperKernelZone
   beq CreatureWithinDDTCloudVertRange
   cmp tmpDDTCloudLowerKernelZone
   beq CreatureWithinDDTCloudVertRange
.checkNextCreatureShotCollision
   cpx objectListEndValue
   inx
   bcc .checkCreatureShotCollisions
   jmp CheckShotCollisionWithMushroom
    
CreatureWithinShotVertRange
   sta tmpObjectKernelZone
   lda creatureSpriteIds_R - MAX_DDT_BOMBS,x;get creature sprite id value
   bpl .determineCreatureWithinShotHorizRange;branch if not Millipede chain
   clc
   adc #$80                         ; remove MILLIPEDE_CHAIN value
.determineCreatureWithinShotHorizRange
   tay                              ; move creature sprite id to y register
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc objectHorizPositions_R,x     ; subtract object horizontal position
   sta tmpShotObjectHorizDistance
   cmp SpriteWidthValues,y
   lda tmpObjectKernelZone          ; get object kernel zone value
   bcs .checkCreatureWithinShooterVertRange;branch if not in horizontal range
   cmp tmpShooterKernelZone
   beq CreatureWithinShooterVertRange
   jmp .setShotCollisionRoutine
    
ShotWithinObjectZone
   ldy spriteIdArray_R,x            ; get sprite id value
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc objectHorizPositions_R,x     ; subtract object horizontal position
   cmp SpriteWidthValues,y          ; compare with sprite width
   bcs .checkShotCollisionWithDDT   ; branch if not in horizontal range
.setShotCollisionRoutine
   lda #>CollisionRoutines
   sta tmpShotCollisionRoutineVector + 1
   lda ShotCollisionRoutineLSBValues,y
   sta tmpShotCollisionRoutineVector
   jmp (tmpShotCollisionRoutineVector)

.checkShotCollisionWithDDT
   ldx #MAX_DDT_BOMBS
   jmp .checkCreatureShotCollisions
    
CreatureWithinShooterVertRange
   lda creatureSpriteIds_R - MAX_DDT_BOMBS,x;get creature sprite id value
   bpl .determineCreatureWithinShooterHorizRange;branch if not Millipede chain
   clc
   adc #$80                         ; remove MILLIPEDE_CHAIN value
.determineCreatureWithinShooterHorizRange
   tay
   lda shooterHorizPos              ; get Shooter horizontal position
   sec
   sbc objectHorizPositions_R,x     ; subtract object horizontal position
   bcc .creatureToTheLeftOfShooter  ; branch if to the left of object
   cmp SpriteWidthValues,y
   lda tmpShooterKernelZone
   bcs .checkObjectWithinDDTCloudVertRange;branch if not in horizontal range
   bcc CreatureCollisionWithShooter ; unconditional branch

.creatureToTheLeftOfShooter
   cmp #<-[W_SHOOTER - 1]
   lda tmpShooterKernelZone
   bcc .checkObjectWithinDDTCloudVertRange;branch if not in horizontal range
   lda SpriteWidthValues,y
   bne CreatureCollisionWithShooter
   lda tmpShooterKernelZone
   bcs .checkObjectWithinDDTCloudVertRange;unconditional branch

CreatureWithinDDTCloudVertRange
   lda creatureSpriteIds_R - MAX_DDT_BOMBS,x;get creature sprite id value
   bpl .determineCreatureWithinCloudHorizRange;branch if not Millipede chain
   clc
   adc #$80                         ; remove MILLIPEDE_CHAIN value
.determineCreatureWithinCloudHorizRange
   tay
   lda tmpDDTCloudHorizPosition     ; get DDT cloud horizontal position
   sec
   sbc creatureHorizPositions_R - MAX_DDT_BOMBS,x;subtract creature position
   bcc .creatureLeftOfDDTCloud      ; branch if cloud left of creature
   cmp SpriteWidthValues,y
   bcc .creatureCollisionWithDDTCloud
   jmp .checkNextCreatureShotCollision;branch if not in horizontal range
    
.creatureLeftOfDDTCloud
   cmp #<-15
   bcs .creatureCollisionWithDDTCloud
   jmp .checkNextCreatureShotCollision;branch if not in horizontal range
    
CreatureCollisionWithShooter
   lda waveState                    ; get current wave state value
   
   IF CHEAT_ENABLE
   
      ora #$80
      
   ELSE

      and gameState                 ; mask with game state
      
   ENDIF

   bmi .skipCreatureCollisionWithShooter;branch if GS_GAME_OVER and SWARMING
   lda #<~INSECT_SPEED_MASK
   sta inchwormWaveState
   lda #<[ShooterCollisionAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
   lda #<[InsectSlowDownAudioValues - RightSoundChannelValues] - 1
   cmp rightSoundChannelIndex
   bcs .checkToIncrementSwarmingWave; branch to keep right sound channel value
   lda #0
   sta rightSoundChannelIndex       ; reset right sound channel value
.checkToIncrementSwarmingWave
   lda waveState                    ; get current wave state value
   bpl .doneCreatureCollisionWithShooter;branch if NOT_SWARMING
   clc
   adc #1 << 2                      ; increment swarming wave
   and #SWARMING_WAVE_MASK          ; keep SWARMING_WAVE value
   sta tmpSwarmingWaveValue
   lda waveState                    ; get current wave state value
   and #<~SWARMING_WAVE_MASK        ; clear SWARMING_WAVE number
   ora tmpSwarmingWaveValue
   sta waveState
.doneCreatureCollisionWithShooter
   stx shotMushroomIndex
   lda #0
   sta growingMushroomGardenArrayIndex
   jmp CheckIfEnoughTimeToBuildMillipedeSegments
    
.skipCreatureCollisionWithShooter
   lda tmpShooterKernelZone
   jmp .checkObjectWithinDDTCloudVertRange
    
.creatureCollisionWithDDTCloud
   cpy #ID_MILLIPEDE_CHAIN
   bcs CheckCloudCollisionWithMillipede
   cpy #ID_MILLIPEDE_HEAD
   beq CheckCloudCollisionWithMillipede
   cpy #ID_MILLIPEDE_SEGMENT
   beq CheckCloudCollisionWithMillipede
   cpy #ID_SHOOTER_DEATH
   bcs .doneDetermineCloudCollisionRoutine
   lda #>CollisionRoutines
   sta tmpShotCollisionRoutineVector + 1
   bit waveState                    ; check current wave state value
   bpl DetermineCloudCollisionRoutine;branch if not SWARMING
   lda ShotCollisionRoutineLSBValues,y
   sta tmpShotCollisionRoutineVector
   jmp (tmpShotCollisionRoutineVector)

DetermineCloudCollisionRoutine
   lda CloudCollisionRoutineLSBValues,y
   sta tmpShotCollisionRoutineVector
   lda DDTCloudPointValues,y
   jmp (tmpShotCollisionRoutineVector)
    
.doneDetermineCloudCollisionRoutine
   jmp .checkNextCreatureShotCollision
    
SwarmingInsectSpawningValues
   .byte ID_BEE, ID_BEE, ID_BEE, ID_BEE
   .byte ID_DRAGONFLY, ID_DRAGONFLY, ID_DRAGONFLY, ID_DRAGONFLY
   .byte ID_MOSQUITO + 1, ID_MOSQUITO, ID_MOSQUITO + 1, ID_MOSQUITO
   .byte ID_BEE, ID_DRAGONFLY, ID_MOSQUITO + 1, ID_MOSQUITO

SwarmingInsectAudioValues
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
    
CheckCloudCollisionWithMillipede
   ldx #0
   ldy #0
   lda numberOfMillipedeSegments    ; get number of Millipede segments
   sta tmpNumberOfMillipedeSegments
.checkCloudCollisionWithMillipede
   lda millipedeSegmentState,x      ; get Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sec
   sbc tmpDDTCloudUpperKernelZone
   cmp #<-2
   bcc .checkCurrentMillipedeChainDone
   lda tmpDDTCloudHorizPosition     ; get DDT cloud horizontal position
   sec
   sbc millipedeHorizPosition,x     ; subtract segment horizontal position
   bcc .millipedeLeftOfDDTCloud
   cmp #W_MILLIPEDE_HEAD
   bcs .checkCurrentMillipedeChainDone
   bcc .scorePointsForCloudCollisionWithMillipede;unconditional branch

.millipedeLeftOfDDTCloud
   cmp #<-15
   bcc .checkCurrentMillipedeChainDone
.scorePointsForCloudCollisionWithMillipede
   sed
   clc
   lda millipedeSegmentState,x      ; get Millipede segment state
   bmi .scoreForMillipedeSegmentCloudCollision;branch if MILLIPEDE_BODY_SEGMENT
   lda #<[POINTS_MILLIPEDE_SEGMENT * 3]
   adc tmpOnesPoints
   sta tmpOnesPoints
   lda #1 - 1
   beq .incrementHundredsPointValue ; unconditional branch

.scoreForMillipedeSegmentCloudCollision
   lda #[POINTS_MILLIPEDE_HEAD >> 8] * 3
.incrementHundredsPointValue
   adc tmpHundredsPoints
   sta tmpHundredsPoints
   lda tmpThousandsPoints
   adc #1 - 1
   sta tmpThousandsPoints
   cld
   dec numberOfMillipedeSegments    ; reduce number of Millipede segments
   cpx tmpNumberOfMillipedeSegments
   inx
   bcc .checkCloudCollisionWithMillipede
   bcs .doneCheckCloudCollisionWithMillipede;unconditional branch

.checkCurrentMillipedeChainDone
   sty tmpMillipedeChainIndex
   cpx tmpMillipedeChainIndex
   beq .checkMillipedeChainDone
   lda millipedeSegmentState,x      ; get Millipede segment state
   and #<~MILLIPEDE_SEGMENT_MASK
   bpl .setSegmentStateForDDTCloudCollision;set to MILLIPEDE_HEAD_SEGMENT

.breakTheChainForDDTCloudCollision
   lda millipedeSegmentState,x      ; get Millipede segment state
.setSegmentStateForDDTCloudCollision
   sta millipedeSegmentState,y
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   sta millipedeHorizPosition,y
   lda millipedeAttributes_R,x
   sta millipedeAttributes_W,y
   iny
   cpx tmpNumberOfMillipedeSegments
   inx
   bcc .breakTheChainForDDTCloudCollision
   bcs .doneCheckCloudCollisionWithMillipede;unconditional branch

.checkMillipedeChainDone
   iny
   cpx tmpNumberOfMillipedeSegments
   inx
   bcc .checkCloudCollisionWithMillipede
.doneCheckCloudCollisionWithMillipede
   jmp .checkToSpeedUpLastRemainingMillipedeHead
    
CloudCollisionRoutineLSBValues
   .byte <IgnoreDDTCloudCollision
   .byte <DDTCloudCollisionWithBee
   .byte <DDTCloudCollisionWithBee
   .byte <DDTCloudCollisionWithEarwig
   .byte <DDTCloudCollisionWithEarwig
   .byte <DDTCloudCollisionWithEarwig
   .byte <DDTCloudCollisionWithEarwig
   .byte <DDTCloudCollisionWithSpider
   .byte <DDTCloudCollisionWithSpider
   .byte <DDTCloudCollisionWithSpider
   .byte <DDTCloudCollisionWithMosquito
   .byte <DDTCloudCollisionWithMosquito
   .byte <DDTCloudCollisionWithMosquito
   .byte <DDTCloudCollisionWithMosquito
   .byte <DDTCloudCollisionWithDragonfly
   .byte <DDTCloudCollisionWithDragonfly
   .byte <DDTCloudCollisionWithDragonfly
   .byte <DDTCloudCollisionWithInchworm
   .byte <DDTCloudCollisionWithInchworm
   .byte <DDTCloudCollisionWithInchworm
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle
   .byte <DDTCloudCollisionWithBeetle

BANK1_RightAudioValueLowerBounds
   .byte <-1
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]

BANK1_RightAudioValueUpperBounds
   .byte 0
   .byte <[BeeAudioValues - RightSoundChannelValues] + 39
   .byte <[BeeAudioValues - RightSoundChannelValues] + 39
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8

   FILL_BOUNDARY 256, 0

CollisionRoutines
DDTCloudCollisionWithSpider
   lda #ID_POINTS_1800
   sta spriteIdArray_W,x
   lda objectAttributes_R,x         ; get object attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta objectAttributes_W,x
   lda DDTCloudPointValues,y
   sta tmpHundredsPoints
   jmp SetSoundChannelValuesForPointScore

ShotCollisionWithBee
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda objectAttributes_R,x         ; get Bee attribute values
   bmi .scorePointsForShootingBee   ; branch if BEE_STATE_ANGRY
   ora #BEE_STATE_ANGRY
   sta objectAttributes_W,x
   jmp .checkToPlayMushroonTallySounds
    
.scorePointsForShootingBee
   lda #[POINTS_BEE >> 8]
DDTCloudCollisionWithBee
DDTCloudCollisionWithDragonfly
   jmp ScorePointsForPotentialSwarmingInsect

ShotCollisionWithMillipede
   jmp ShotInMillipedeHorizRange
    
ShotCollisionWithEarwig
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda #[POINTS_EARWIG >> 8]
DDTCloudCollisionWithEarwig
   jmp ScorePointsForDestroyingInsect
    
ShotCollisionWithDragonfly
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda #[POINTS_DRAGONFLY >> 8]
   jmp ScorePointsForPotentialSwarmingInsect

ShotCollisionWithBeetle
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda #[POINTS_BEETLES >> 8]
DDTCloudCollisionWithBeetle
   dec gardenShiftValues            ; set to shift garden down
   jmp ScorePointsForDestroyingInsect

ShotCollisionWithMosquito
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda #[POINTS_MOSQUITO >> 8]
DDTCloudCollisionWithMosquito
   inc gardenShiftValues            ; set to shift garden up
   jmp ScorePointsForPotentialSwarmingInsect

ShotCollisionWithInchworm
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda #[POINTS_INCHWORM >> 8]
DDTCloudCollisionWithInchworm
   sta tmpInchwormPointValue        ; save Inchworm point value
   lda gameState + 1                ; get high game state value
   ora #INIT_INCHWORM_SPAWN_TIMER
   sta gameState + 1                ; reinitialize Inchworm spawn timer
   lda tmpInchwormPointValue        ; restore Inchworm point value to accumulator
   
   IF COMPILE_REGION = PAL50
   
      ldy #PLAYER_MOVEMENT_NORMAL | INSECT_SPEED_SLOW | 10
   
   ELSE
   
      ldy #PLAYER_MOVEMENT_NORMAL | INSECT_SPEED_SLOW
   
   ENDIF

   sty inchwormWaveState
   ldy rightSoundChannelIndex       ; get right sound channel index value
   beq .setToPlayInsectSlowDownSounds;branch if right sound channel off
   cpy #<[InsectSlowDownAudioValues - RightSoundChannelValues]
   bcc .doneShotCollisionWithInchworm
.setToPlayInsectSlowDownSounds
   ldy #<[InsectSlowDownAudioValues - RightSoundChannelValues]
   sty rightSoundChannelIndex
.doneShotCollisionWithInchworm
   jmp ScorePointsForDestroyingInsect   

ScorePointsForSpiderShot
   lda #0
   sta shotVertPos                  ; set to turn off shot
   lda objectAttributes_R,x         ; get Spider attribute value
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta objectAttributes_W,x
   sec
   sbc tmpShooterKernelZone         ; subtract Shooter kernel zone
   beq .spiderInShooterKernelZone
   bcc .checkNextShotCollision
   tay                              ; move distance to y register
   lda SpiderPointValues,y
   sta tmpHundredsPoints
   lda SpiderPointSpriteIdValues,y
   sta spriteIdArray_W,x
   jmp SetSoundChannelValuesForPointScore
    
.spiderInShooterKernelZone
   jmp CreatureWithinShooterVertRange
    
IgnoreShotCollision
.checkNextShotCollision
   lda tmpShotUpperKernelZone       ; get Shot upper kernel zone
   jmp .checkNextDDTBombShotCollision

IgnoreDDTCloudCollision
   jmp .checkNextCreatureShotCollision

ShotCollisionWithDDTBomb
   lda #<[DDTBombExplosionAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
   lda objectHorizPositions_R,x     ; get DDT horizontal position
   sec
   sbc #4                           ; subtract by 4
   sta objectHorizPositions_W,x     ; set horizontal position for DDT Cloud
   lsr
   bcc .evenDDTCloudHorizPosition   ; branch if even position
   lsr
   sec
   bcs .setDDTCloudMushroomMaskingBitIndex;unconditional branch

.evenDDTCloudHorizPosition
   lsr
.setDDTCloudMushroomMaskingBitIndex
   tay                              ; set mushroom masking index
   adc #4
   sta tmpEndDDTCloudMushroomMaskingIndex
   lda #ID_DDT_CLOUD
   sta spriteIdArray_W,x            ; set initial DDT Cloud sprite id
   lda #0
   sta shotVertPos                  ; turn off Shot
   lda #[POINTS_DDT_BOMB >> 8]
   sta tmpHundredsPoints            ; set point value for DDT
   lda tmpShotUpperKernelZone
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   sta tmpShotUpperKernelZone
.determineDDTCloudMushroomMaskingBitIndex
   lda tmpShotUpperKernelZone
   cpy #16
   bcc .removeMushroomForDDTCloud
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.removeMushroomForDDTCloud
   tax                              ; move adjusted zone value to x register
   lsr
   tya                              ; move mushroom masking index to accumulator
   bcs .removeRightSideMushroomsForDDTCloud
   lsr
   lda #$FF
   bcs .removeLeftSideOddScanlineMushroom
   eor BANK1_EvenMushroomMaskingBits,y;isolate Mushroom masking bit
   and mushroomArray_R - 2,x        ; remove Mushroom bit
   sta mushroomArray_W - 2,x
   lda #$FF
   eor BANK1_EvenMushroomMaskingBits,y;isolate Flower masking bit
   and leftFlowerArray_R - 2,x      ; remove Flower bit
   jmp .checkToRemoveFlowerForDDTCloud
    
.removeLeftSideOddScanlineMushroom
   eor BANK1_OddMushroomMaskingBits,y;isolate Mushroom masking bit
   dex
   and mushroomArray_R - 2,x
   sta mushroomArray_W - 2,x
   lda #$FF
   eor BANK1_OddMushroomMaskingBits,y;isolate Mushroom masking bit
   and leftFlowerArray_R - 2,x
   jmp .checkToRemoveFlowerForDDTCloud
    
.removeRightSideMushroomsForDDTCloud
   lsr
   lda #$FF
   bcs .removeRightSideOddScanlineMushroom
   eor BANK1_EvenMushroomMaskingBits,y;isolate Mushroom masking bit
   dex
   and mushroomArray_R - 2,x
   sta mushroomArray_W - 2,x
   lda #$FF
   eor BANK1_EvenMushroomMaskingBits,y;isolate Mushroom masking bit
   and leftFlowerArray_R - 2,x
   jmp .checkToRemoveFlowerForDDTCloud
    
.removeRightSideOddScanlineMushroom
   eor BANK1_OddMushroomMaskingBits,y;isolate Mushroom masking bit
   and mushroomArray_R - 2,x
   sta mushroomArray_W - 2,x
   lda #$FF
   eor BANK1_OddMushroomMaskingBits,y;isolate Mushroom masking bit
   and leftFlowerArray_R - 2,x
.checkToRemoveFlowerForDDTCloud
   cpx #<[millipedeAttributes_W - leftFlowerArray_W] + 2
   bcc .removeFlowerForDDTCloud     ; branch if within left Flower index range
   cpx #<[rightFlowerArray_W - leftFlowerArray_W] + 2
   bcc .incrementMushroomMaskingBitValue;branch if not in right Flower index range
   cpx #<[mushroomArray_W - leftFlowerArray_W] + 2
   bcs .incrementMushroomMaskingBitValue;branch if not in Flower index range
.removeFlowerForDDTCloud
   sta leftFlowerArray_W - 2,x
.incrementMushroomMaskingBitValue
   iny
   cpy tmpEndDDTCloudMushroomMaskingIndex
   bne .determineDDTCloudMushroomMaskingBitIndex
   jmp CheckIfEnoughTimeToBuildMillipedeSegments
    
ShotInMillipedeHorizRange
   lda tmpObjectKernelZone          ; get Millipede kernel zone
   cmp tmpShotLowerKernelZone       ; compare with lower shot zone value
   bne .shotInMillipedeHorizRange   ; branch if not in same zone
   jmp CheckCreatureVerticalRangeCollisions

.shotInMillipedeHorizRange
   dec tmpShotUpperKernelZone
   lda tmpShotObjectHorizDistance   ; get horizontal distance value
   and #<~3
   clc
   adc objectHorizPositions_R,x     ; increment by Millipede segment
   tay
   iny
   stx tmpObjectCollisionIdx        ; save object index for later
   ldx numberOfMillipedeSegments    ; get number of Millipede segments
.checkShootingNextMillipedeSegment
   lda millipedeSegmentState,x      ; get Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep Millipede KERNEL_ZONE value
   cmp tmpShotUpperKernelZone
   beq .millipedeShot               ; branch if Millipede in Shot kernel zone
   dex
   bpl .checkShootingNextMillipedeSegment
   bmi .doneShotInMillipedeHorizRange;unconditional branch

.millipedeShot
   tya
   sec
   sbc millipedeHorizPosition,x     ; subtract segment horizontal position
   cmp #W_MILLIPEDE_HEAD - 1
   bcc .scorePointsForShootingMillipede;branch if shot Millipede segment
   dex
   bpl .checkShootingNextMillipedeSegment
.doneShotInMillipedeHorizRange
   inc tmpShotUpperKernelZone
   ldx tmpObjectCollisionIdx        ; restore object index to x register
   jmp .checkNextDDTBombShotCollision
    
.scorePointsForShootingMillipede
   dey
   lda millipedeSegmentState,x      ; get Millipede segment state
   sta tmpShotMillipedeState
   bpl .scorePointsForShootingMillipedeHead;branch if MILLIPEDE_HEAD_SEGMENT
   lda #POINTS_MILLIPEDE_SEGMENT
   sta tmpOnesPoints
   bne .checkEndOfMillipedeChain    ; unconditional branch

.scorePointsForShootingMillipedeHead
   lda #[POINTS_MILLIPEDE_HEAD >> 8]
   sta tmpHundredsPoints
.checkEndOfMillipedeChain
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   sta tmpMillipedeHorizPos
   stx tmpShotMillipedeIndex
   cpx numberOfMillipedeSegments
   beq .foundEndOfMillipedeChain
   lda millipedeSegmentState + 1,x  ; get trailing Millipede segment state
   and #<~MILLIPEDE_SEGMENT_MASK    ; set to MILLIPEDE_HEAD_SEGMENT
   bpl .setMillipedeSegmentState    ; unconditional branch

.breakTheChain
   lda millipedeSegmentState + 1,x  ; get trailing Millipede segment state
.setMillipedeSegmentState
   sta millipedeSegmentState,x
   lda millipedeHorizPosition + 1,x ; get trailing segment horizontal position
   sta millipedeHorizPosition,x
   lda millipedeAttributes_R + 1,x  ; get trailing Millipede segment attributes
   sta millipedeAttributes_W,x
   inx
   cpx numberOfMillipedeSegments
   bne .breakTheChain
.foundEndOfMillipedeChain
   dec numberOfMillipedeSegments
   bmi .determineShotMillipedeLocation
   ldx tmpShotMillipedeIndex        ; get index value of shot Millipede segment
   dex                              ; decrement to get leading Millipede segment
   bmi .determineShotMillipedeLocation
   lda tmpMillipedeHorizPos
.findShotMillipedeSegmentHorizPos
   cmp millipedeHorizPosition,x
   beq CheckToPlaceMushroomForShotMillipede
   dex
   bpl .findShotMillipedeSegmentHorizPos
   bmi .determineShotMillipedeLocation;unconditional branch

CheckToPlaceMushroomForShotMillipede
   lda millipedeSegmentState,x      ; get Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpShotUpperKernelZone
   beq .checkEndOfMillipedeChain
.determineShotMillipedeLocation
   lda shotVertPos                  ; get Shot vertical position
   eor kernelZoneAdjustment
   eor #1
   sta tmpShotKernelZone
   lsr                              ; shift D0 to carry
   tya                              ; move Shot horiz position to accumulator
   bcc .determineMushroomHorizPosition;branch on even scan line
   sbc #W_MILLIPEDE_HEAD
.determineMushroomHorizPosition
   tay                              ; set to Millipede horizonal position
   lda tmpShotMillipedeState        ; get shot Millipede segment state
   and #MILLIPEDE_HORIZ_DIR_MASK    ; keep MILLIPEDE_HORIZ_DIR
   bne .determineMushroomMaskingBitIndex;branch if MILLIPEDE_DIR_LEFT
   tya                              ; get Millipede horizontal position
   clc
   adc #[W_MILLIPEDE_HEAD * 2] - 1
   tay
.determineMushroomMaskingBitIndex
   tya                              ; get Millipede horizontal position
   lsr
   lsr
   and #<~1
   tay
   lda tmpShotKernelZone            ; get Shot adjusted kernel zone
   lsr
   tya                              ; get Millipede horizontal position
   bcs .setMushroomMaskingBitIndex  ; branch if Shot in odd zone
   adc #<[BANK1_EvenMushroomMaskingBits - BANK1_MushroomMaskingBits - 1]
.setMushroomMaskingBitIndex
   tax
   inx
   cmp #63
   bmi .determineMushroomLocation
   ldx #63
.determineMushroomLocation
   txa                              ; move Mushroom masking index to accumulator
   and #$10
   beq .placeMushroomForShotMillipede;branch for left Mushroom array
   lda #<[rightMushroomArray_W - leftMushroomArray_W]
.placeMushroomForShotMillipede
   sec
   adc tmpShotUpperKernelZone
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   tay
   lda mushroomArray_R - 2,y
   ora BANK1_MushroomMaskingBits,x
   sta mushroomArray_W - 2,y
   lda beetleSpawnTimer
   ora #$80
   sta beetleSpawnTimer
.checkToSpeedUpLastRemainingMillipedeHead
   lda numberOfMillipedeSegments    ; get number of Millipede segments
   bne CheckForWaveCompleted        ; branch if more Millipede segments
   lda millipedeAttributes_R
   ora #MILLIPEDE_FAST
   sta millipedeAttributes_W
   jmp .checkToPlayMushroonTallySounds
    
CheckForWaveCompleted
   bpl .turnOffShot                 ; branch if more Millipede segments
   lda gameWaveValues               ; get current game wave values
   cmp #3
   bne .determineWaveTransitionTimerValue;branch if not growing Mushroom Garden
   ldy #<[rightMushroomArray_W - leftMushroomArray_W]
   sty growingMushroomGardenArrayIndex
   ldy #0
   sty growingMushroomGardenIndex
   lda #128 - 256
   bne .setWaveTransitionTimerValue ; unconditional branch

.determineWaveTransitionTimerValue
   lsr                              ; shift D0 to carry
   lda #128 - 256
   bcc .setWaveTransitionTimerValue ; branch if an even wave
   lda #255 - 256
.setWaveTransitionTimerValue
   sta waveTransitionTimer
.turnOffShot
   lda #0
   sta shotVertPos
   jmp .checkToPlayMushroonTallySounds

;
; This code is never executed. It looks as if it could have been an old routine
; for shooting a Bee.
;
      IF ORIGINAL_ROM
      
   .byte $BD,$93,$10,$30,$07,$09,$80,$9D,$13,$10,$30,$61,$A9,$02,$D0,$06
   
      ENDIF

ScorePointsForDestroyingInsect
   bit waveState                    ; check current wave state values
   bpl .scorePointsForNonSwarmingInsects;branch if NOT_SWARMING
   bmi .scorePointsForSwarmingInsects;unconditional branch
    
ScorePointsForPotentialSwarmingInsect
   bit waveState                    ; check current wave state values
   bpl .scorePointsForNonSwarmingInsects;branch if NOT_SWARMING
   dec numberActiveSwarmingInsects  ; reduce number of active Swarming insects
.scorePointsForSwarmingInsects
   ldy insectSwarmShootTally
   bpl .setPointsForDestroyingSwarmingInsect
   tay                              ; move hundreds point value to y register
   cpy #$10
   bcc .determinePointIndexForDDTCloud;branch if point value less than 1,000
   ldy #2
.determinePointIndexForDDTCloud
   lda DDTBonusPointIndexValues,y   ; get bound point index value for DDT_CLOUD
   tay                              ; move index value to y register
.setPointsForDestroyingSwarmingInsect
   lda objectAttributes_R,x         ; get object attribute value
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta objectAttributes_W,x
   lda BonusPointSpriteIdValues,y   ; get swarming bonus point sprite id value
   sta spriteIdArray_W,x            ; set sprite id to swarming bonus point
   lda BonusPointHundredsValues,y   ; get bonus point hundreds value
   sta tmpHundredsPoints
   dey
   bmi .checkToPlayMushroonTallySounds
   sty insectSwarmShootTally
   bpl .checkToPlayMushroonTallySounds;unconditional branch
    
.scorePointsForNonSwarmingInsects
   sta tmpHundredsPoints
   lda #0
   sta objectAttributes_W,x         ; clear object attribute value
SetSoundChannelValuesForPointScore
   ldy spriteIdArray_R,x            ; get sprite id value
   cpy #ID_SHOOTER_DEATH
   bcc .checkToResetRightSoundChannelIndex;branch if an insect
   cpy #ID_POINTS_300
   bcc .checkToPlayMushroonTallySounds;branch if ID_SPARK or ID_MILLIPEDE
   cpy #ID_DDT
   bcs .checkToPlayMushroonTallySounds;branch if ID_DDT or ID_DDT_CLOUD
   ldy #7
.checkToResetRightSoundChannelIndex
   lda rightSoundChannelIndex       ; get right sound channel index value
   cmp BANK1_RightAudioValueLowerBounds,y
   bcc .checkToPlayMushroonTallySounds
   cmp BANK1_RightAudioValueUpperBounds,y
   bcs .checkToPlayMushroonTallySounds
   lda #0
   sta rightSoundChannelIndex       ; reset right sound channel index
.checkToPlayMushroonTallySounds
   lda #<[MushroomTallyAudioValues - LeftSoundChannelValues]
   ldx leftSoundChannelIndex        ; get left sound channel index value
   beq .setLeftSoundChannelIndex    ; branch if playing heart beat
   cmp leftSoundChannelIndex
   bcs .doneSetSoundChannelValuesForPointScore
.setLeftSoundChannelIndex
   sta leftSoundChannelIndex
.doneSetSoundChannelValuesForPointScore
   jmp CheckIfEnoughTimeToBuildMillipedeSegments
    
TimeNeededForMillipedeMovement
   .byte 127 + 6
   .byte 127 + 7
   .byte 127 + 8
   .byte 127 + 9
   .byte 127 + 10
   .byte 127 + 11
   .byte 127 + 12
   .byte 127 + 13
   .byte 127 + 14

SpiderPointValues
   .byte POINTS_SPIDER_CLOSEST >> 8, POINTS_SPIDER_CLOSEST >> 8
   .byte POINTS_SPIDER_CLOSE >> 8,   POINTS_SPIDER_CLOSE >> 8
   .byte POINTS_SPIDER_MEDIUM >> 8,  POINTS_SPIDER_MEDIUM >> 8
   .byte POINTS_SPIDER_DISTANT >> 8, POINTS_SPIDER_DISTANT >> 8
   .byte POINTS_SPIDER_DISTANT >> 8, POINTS_SPIDER_DISTANT >> 8

SpiderPointSpriteIdValues
   .byte ID_POINTS_1200, ID_POINTS_1200, ID_POINTS_900, ID_POINTS_900, ID_POINTS_600
   .byte ID_POINTS_600,  ID_POINTS_300,  ID_POINTS_300, ID_POINTS_300, ID_POINTS_300

DDTBonusPointIndexValues
   .byte 8, 8, 8                    ; ID_POINTS_200
   .byte 7                          ; ID_POINTS_300
   .byte 6                          ; ID_POINTS_400
   .byte 5                          ; ID_POINTS_500
   .byte 4                          ; ID_POINTS_600
   .byte 3                          ; ID_POINTS_700
   .byte 2                          ; ID_POINTS_800
   .byte 1                          ; ID_POINTS_900
    
   FILL_BOUNDARY 256, 0

BonusPointHundredsValues
   .byte [$1000 >> 8]
   .byte [$0900 >> 8]
   .byte [$0800 >> 8]
   .byte [$0700 >> 8]
   .byte [$0600 >> 8]
   .byte [$0500 >> 8]
   .byte [$0400 >> 8]
   .byte [$0300 >> 8]
   .byte [$0200 >> 8]

BonusPointSpriteIdValues
   .byte ID_POINTS_1000, ID_POINTS_900, ID_POINTS_800, ID_POINTS_700
   .byte ID_POINTS_600,  ID_POINTS_500, ID_POINTS_400, ID_POINTS_300, ID_POINTS_200

ShotCollisionRoutineLSBValues
   .byte <IgnoreShotCollision
   .byte <ShotCollisionWithBee
   .byte <ShotCollisionWithBee
   .byte <ShotCollisionWithEarwig
   .byte <ShotCollisionWithEarwig
   .byte <ShotCollisionWithEarwig
   .byte <ShotCollisionWithEarwig
   .byte <ScorePointsForSpiderShot
   .byte <ScorePointsForSpiderShot
   .byte <ScorePointsForSpiderShot
   .byte <ShotCollisionWithMosquito
   .byte <ShotCollisionWithMosquito
   .byte <ShotCollisionWithMosquito
   .byte <ShotCollisionWithMosquito
   .byte <ShotCollisionWithDragonfly
   .byte <ShotCollisionWithDragonfly
   .byte <ShotCollisionWithDragonfly
   .byte <ShotCollisionWithInchworm
   .byte <ShotCollisionWithInchworm
   .byte <ShotCollisionWithInchworm
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <ShotCollisionWithBeetle
   .byte <IgnoreShotCollision       ; ID_SHOOTER_DEATH
   .byte <IgnoreShotCollision       ; ID_SHOOTER_DEATH
   .byte <IgnoreShotCollision       ; ID_SHOOTER_DEATH
   .byte <IgnoreShotCollision       ; ID_SHOOTER_DEATH
   .byte <IgnoreShotCollision       ; ID_SPARK_00
   .byte <IgnoreShotCollision       ; ID_SPARK_01
   .byte <ShotCollisionWithMillipede; ID_MILLIPEDE_HEAD
   .byte <ShotCollisionWithMillipede; ID_MILLIPEDE_SEGMENT
   .byte <IgnoreShotCollision       ; ID_POINTS_200
   .byte <IgnoreShotCollision       ; ID_POINTS_300
   .byte <IgnoreShotCollision       ; ID_POINTS_400
   .byte <IgnoreShotCollision       ; ID_POINTS_500
   .byte <IgnoreShotCollision       ; ID_POINTS_600
   .byte <IgnoreShotCollision       ; ID_POINTS_700
   .byte <IgnoreShotCollision       ; ID_POINTS_800
   .byte <IgnoreShotCollision       ; ID_POINTS_900
   .byte <IgnoreShotCollision       ; ID_POINTS_1000
   .byte <IgnoreShotCollision       ; ID_POINTS_1200
   .byte <IgnoreShotCollision       ; ID_POINTS_1800
   .byte <ShotCollisionWithDDTBomb
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <IgnoreShotCollision
   .byte <ShotCollisionWithMillipede
   .byte <ShotCollisionWithMillipede
   .byte <ShotCollisionWithMillipede
   .byte <ShotCollisionWithMillipede
   .byte <ShotCollisionWithMillipede
   .byte <ShotCollisionWithMillipede

SpriteWidthValues
   .byte W_BLANK_SPRITE             ; ID_BLANK
   .byte W_BEE                      ; ID_BEE
   .byte W_BEE                      ; ID_BEE
   .byte W_EARWIG                   ; ID_EARWIG
   .byte W_EARWIG                   ; ID_EARWIG
   .byte W_EARWIG                   ; ID_EARWIG
   .byte W_EARWIG                   ; ID_EARWIG
   .byte W_SPIDER                   ; ID_SPIDER
   .byte W_SPIDER                   ; ID_SPIDER
   .byte W_SPIDER                   ; ID_SPIDER
   .byte W_MOSQUITO                 ; ID_MOSQUITO
   .byte W_MOSQUITO                 ; ID_MOSQUITO
   .byte W_MOSQUITO                 ; ID_MOSQUITO
   .byte W_MOSQUITO                 ; ID_MOSQUITO
   .byte W_DRAGONFLY                ; ID_DRAGONFLY
   .byte W_DRAGONFLY                ; ID_DRAGONFLY
   .byte W_DRAGONFLY                ; ID_DRAGONFLY
   .byte W_INCHWORM                 ; ID_INCHWORM
   .byte W_INCHWORM                 ; ID_INCHWORM
   .byte W_INCHWORM                 ; ID_INCHWORM
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte W_BEETLE                   ; ID_BEETLE
   .byte 0                          ; ID_SHOOTER_DEATH
   .byte 0                          ; ID_SHOOTER_DEATH
   .byte 0                          ; ID_SHOOTER_DEATH
   .byte 0                          ; ID_SHOOTER_DEATH
   .byte 0                          ; ID_SPARK
   .byte 0                          ; ID_SPARK
   .byte W_MILLIPEDE_HEAD           ; ID_MILLIPEDE_HEAD
   .byte W_MILLIPEDE_SEGMENT        ; ID_MILLIPEDE_SEGMENT
   .byte 0                          ; ID_POINTS_200
   .byte 0                          ; ID_POINTS_300
   .byte 0                          ; ID_POINTS_400
   .byte 0                          ; ID_POINTS_500
   .byte 0                          ; ID_POINTS_600
   .byte 0                          ; ID_POINTS_700
   .byte 0                          ; ID_POINTS_800
   .byte 0                          ; ID_POINTS_900
   .byte 0                          ; ID_POINTS_1000
   .byte 0                          ; ID_POINTS_1200
   .byte 0                          ; ID_POINTS_1800
   .byte W_DDT                      ; ID_DDT
   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0; ID_DDT_CLOUD
   .byte W_MILLIPEDE_SEGMENT_00
   .byte W_MILLIPEDE_SEGMENT_00 + 4
   .byte W_MILLIPEDE_SEGMENT_00 + 8
   .byte W_MILLIPEDE_SEGMENT_00 + 12
   .byte W_MILLIPEDE_SEGMENT_00 + 16
   .byte W_MILLIPEDE_SEGMENT_00 + 20
    
CheckShotCollisionWithMushroom SUBROUTINE
   lda shotVertPos                  ; get Shot vertical position
   beq .checkShotMushroomOrFlower   ; branch if Shot not active
   lda shotHorizPos                 ; get Shot horizontal position
   lsr                              ; divide value by 4
   lsr
   tay
   lda #21
   cpy #16
   bcc .determineMushroomMaskingBitIndex
   lda #41
.determineMushroomMaskingBitIndex
   sec
   sbc shotVertPos
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   tax
   lsr
   tya                              ; move Mushroom masking index to accumulator
   bcs .setMushroomMaskingBitIndex
   adc #<[BANK1_EvenMushroomMaskingBits - BANK1_MushroomMaskingBits]
.setMushroomMaskingBitIndex
   tay
   lda mushroomArray_R - 2,x        ; get Mushroom array value
   and BANK1_MushroomMaskingBits,y  ; mask Mushroom bit value
.checkShotMushroomOrFlower
   beq .doneCheckShotCollisionWithMushroom;branch if Mushroom not present
   stx tmpMushroomArrayIdx
   cpx #<[millipedeAttributes_W - leftFlowerArray_W] + 2
   bcc .checkShotCollisionWithFlower; branch if within left Flower index range
   cpx #<[rightFlowerArray_W - leftFlowerArray_W] + 2
   bcc .checkToScorePointsForRemovingMushroom;branch if not in right Flower index range
   cpx #<[mushroomArray_W - leftFlowerArray_W] + 2
   bcs .checkToScorePointsForRemovingMushroom;branch if not in Flower index range
.checkShotCollisionWithFlower
   lda leftFlowerArray_R - 2,x      ; get Flower array value
   and BANK1_MushroomMaskingBits,y  ; mask Flower bit value
   beq .checkToScorePointsForRemovingMushroom;branch if Flower not present
   ldx shooterVertPos               ; get Shooter vertical position
   ldy BANK1_ShooterKernelZoneValues,x;get Shooter kernel zone
   iny
   cpy shotVertPos
   beq .doneCheckShotCollisionWithMushroom
   bne .turnOffShot                 ; unconditional branch
    
.checkToScorePointsForRemovingMushroom
   lda shotMushroomIndex            ; get previously shot Mushroom value
   and #$3F
   cmp tmpMushroomArrayIdx
   beq .incrementTimesMushroomShot  ; branch if Mushroom shot previously
   lda tmpMushroomArrayIdx          ; get Mushroom array index
   ora #1 << 6
   sta shotMushroomIndex
   bne .turnOffShot                 ; unconditional branch

.incrementTimesMushroomShot
   lda shotMushroomIndex            ; get previously shot Mushroom value
   clc
   adc #1 << 6
   sta shotMushroomIndex
   bcc .turnOffShot                 ; branch if Mushroom not shot four times
   lda #0
   sta shotMushroomIndex            ; clear previously shot Mushroom value
   sed
   lda tmpOnesPoints                ; get ones points value
   clc
   adc #POINTS_ELIMINATE_MUSHROOM
   sta tmpOnesPoints
   lda tmpHundredsPoints
   adc #1 - 1
   sta tmpHundredsPoints
   lda tmpThousandsPoints
   adc #1 - 1
   sta tmpThousandsPoints
   cld
   lda mushroomArray_R - 2,x        ; get Mushroom array value
   eor BANK1_MushroomMaskingBits,y  ; remove Mushroom from array
   sta mushroomArray_W - 2,x
.turnOffShot
   lda #0
   sta shotVertPos
.doneCheckShotCollisionWithMushroom
CheckIfEnoughTimeToBuildMillipedeSegments
   ldy #MAX_MILLIPEDE_SEGMENTS
   sty tmpBuildingMillipedeChainIndex
   ldy #0
   ldx numberOfMillipedeSegments    ; get number of Millipede segments
   bmi .checkForSwarmingWave        ; branch if no more Millipede segments
   lda INTIM                        ; get RIOT timer value
   cmp TimeNeededForMillipedeMovement,x
   txa                              ; move Millipede segments to accumulator
   bcs BuildMillipedeSegments       ; branch if enough time to build Millipede
   jmp CheckIfEnoughTimeLeftForBank01
    
.checkForSwarmingWave
   bit waveState                    ; check current wave state values
   bpl .nonSwarmingWave             ; branch if NOT_SWARMING
   jmp CheckIfEnoughTimeLeftForBank01
    
.nonSwarmingWave
   jmp .doneBuildingMillipedeSegments

BuildMillipedeSegments
.buildMillipedeSegments
   beq .nextMillipedeChainGroup
.processNextMillipedeChain
   lda millipedeSegmentState,x      ; get Millipede segment state
   bpl .nextMillipedeChainGroup     ; branch if MILLIPEDE_HEAD_SEGMENT
   eor millipedeSegmentState - 1,x  ; flip MILLIPEDE_SEGMENT with leading segment
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE
   bne .nextMillipedeChainGroup
   iny
   dex                              ; decrement Millipede segment index
   bne .processNextMillipedeChain
.nextMillipedeChainGroup
   lda MillipedeChainGroupOffsetValues,y
   sta tmpMillipedeChainGroupHorizOffset
   lda MillipedeChainGroupSpriteIds,y
   bne .buildMillipedeChain
   ldy tmpBuildingMillipedeChainIndex
   lda #ID_MILLIPEDE_SEGMENT
   sta spriteIdArray_W + 1,y
   lda #ID_MILLIPEDE_HEAD
   sta spriteIdArray_W + 2,y
   lda millipedeSegmentState,x      ; get Millipede segment state
   clc
   adc #1                           ; increment Millipede segment kernel zone
   bit MillipedeHorizontalDirectionMaskValue
   beq .setRightMovingMillipedeZone ; branch if MILLIPEDE_DIR_RIGHT
   and #KERNEL_ZONE_MASK            ; keep Millipede kernel zone
   sta objectAttributes_W + 1,y
   sta objectAttributes_W + 2,y
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   sec
   bcs .setMillipedeChainGroupPosition;unconditional branch

.setRightMovingMillipedeZone
   and #KERNEL_ZONE_MASK            ; keep Millipede kernel zone
   sta objectAttributes_W + 1,y
   sta objectAttributes_W + 2,y
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   adc tmpMillipedeChainGroupHorizOffset
.setMillipedeChainGroupPosition
   sta objectHorizPositions_W + 1,y
   adc #W_MILLIPEDE_SEGMENT - 1
   sta objectHorizPositions_W + 2,y
   iny
   iny
   sty tmpBuildingMillipedeChainIndex
   ldy #0
   dex
   bpl .buildMillipedeSegments
   bmi .doneBuildingMillipedeSegments;unconditional branch

.buildMillipedeChain
   ldy tmpBuildingMillipedeChainIndex
   sta spriteIdArray_W + 1,y
   lda millipedeSegmentState,x      ; get Millipede segment state
   clc
   adc #1                           ; increment Millipede segment kernel zone
   bit MillipedeHorizontalDirectionMaskValue
   bne .setLeftMovingMillipedeZone  ; branch if MILLIPEDE_DIR_LEFT
   and #KERNEL_ZONE_MASK            ; keep Millipede kernel zone
   sta objectAttributes_W + 1,y
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   adc tmpMillipedeChainGroupHorizOffset
   sta objectHorizPositions_W + 1,y
   inc tmpBuildingMillipedeChainIndex
   ldy #0
   dex
   bpl .buildMillipedeSegments
   bmi .doneBuildingMillipedeSegments;unconditional branch

.setLeftMovingMillipedeZone
   and #KERNEL_ZONE_MASK            ; keep Millipede kernel zone
   sta objectAttributes_W + 1,y
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   sta objectHorizPositions_W + 1,y
   inc tmpBuildingMillipedeChainIndex
   ldy #0
   dex
   bmi .doneBuildingMillipedeSegments
   jmp .buildMillipedeSegments
    
.doneBuildingMillipedeSegments
   ldy tmpBuildingMillipedeChainIndex
   sty objectListEndValue
CheckIfEnoughTimeLeftForBank01
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 5
   bpl CheckToSpawnExtraSpiders
   jmp BANK1_ProcessObjectMovements
    
CheckToSpawnExtraSpiders
   lda gameState                    ; get current game state
   ora #GS_EXTRA_SPIDER_SPAWNED
   cmp gameState                    ; compare with current game state
   sta gameState                    ; set game state value
   beq ProcessSwarmingInsects       ; branch if same game state value
   bit gameState                    ; check current game state
   bvc .checkToSpawnExtraSpiders    ; branch if not GS_SELECTING_GAME
   ldx #SHOOTER_YMAX + 8
   stx shooterVertPos
   ldx #4
   lda #ID_BLANK
.clearExtraSpiderValues
   sta creatureSpriteIds_W,x
   dex
   bpl .clearExtraSpiderValues
   bmi .doneCheckToSpawnExtraSpiders; unconditional branch

.checkToSpawnExtraSpiders
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   tay
   lda gameWaveValues               ; get current game wave values
   bne .checkSpawnAdvanceWaveExtraSpiders
   ldx #4
.spawnExtraSpiders
   lda creatureAttributes_R,x       ; get creature attribute values
   bne .spawnNextExtraSpider        ; branch if object present
   lda InitSpiderHorizontalPositionValues,y
   sta creatureHorizPositions_W,x   ; set Spider horizontal position
   lda #ID_SPIDER
   sta creatureSpriteIds_W,x        ; set creature to ID_SPIDER
.spawnNextExtraSpider
   iny                              ; increment horizontal position index
   dex
   bmi .doneCheckToSpawnExtraSpiders
   lda playerScore                  ; get score thousands value
   cmp ExtraSpiderLaunchScoreValues,x
   bcs .spawnExtraSpiders
.scoreBelowExtraSpiderValue
   lda creatureAttributes_R,x       ; get creature attribute values
   bne .nextExtraCreature           ; branch if object present
   lda #ID_BLANK
   sta creatureSpriteIds_W,x
.nextExtraCreature
   dex
   bpl .scoreBelowExtraSpiderValue
   bmi .doneCheckToSpawnExtraSpiders; unconditional branch

.checkSpawnAdvanceWaveExtraSpiders
   ldx #2
.clearAdvanceWaveExtraCreature
   lda creatureAttributes_R,x       ; get creature attibute values
   bne .nextAdvanceWaveExtraCreature; branch if object present
   sta creatureSpriteIds_W,x        ; clear sprite id
.nextAdvanceWaveExtraCreature
   dex
   bpl .clearAdvanceWaveExtraCreature
   ldx #1
.spawnAdvanceWaveExtraSpiders
   lda objectAttributes_R + 8,x     ; get object attribute values
   bne .spawnNextAdvanceWaveExtraSpider;branch if object present
   lda InitSpiderHorizontalPositionValues,y
   sta objectHorizPositions_W + 8,x;set Spider horizontal position
   lda #ID_SPIDER
   sta spriteIdArray_W + 8,x
.spawnNextAdvanceWaveExtraSpider
   iny                              ; increment horizontal position index
   dex
   bmi .doneCheckToSpawnExtraSpiders
   lda playerScore                  ; get score thousands value
   cmp ExtraSpiderLaunchScoreValues + 3,x
   bcs .spawnAdvanceWaveExtraSpiders; branch if score greater than 29,999
.doneCheckToSpawnExtraSpiders
   jmp .processObjectMovements
    
ProcessSwarmingInsects
   bit inchwormWaveState            ; check Inchworm wave state
   bmi .doneCheckToSpawnExtraSpiders; branch if PLAYER_MOVEMENT_HALT
   lda frameCount                   ; get current frame count
   clc
   adc #1
   and #$0F                         ; 1 <= a <= 15
   tax
   bit waveState                    ; check current wave state values
   bmi .processSwarmingInsects      ; branch if SWARMING
   jmp DetermineObjectSpawningRoutine
    
.processSwarmingInsects
   and #3                           ; 1 <= a <= 3
   sta tmpSwarmingSpawningInsectValue
   cpx #14
   bcs DetermineSwarmingInsectAudioValue
   lda creatureAttributes_R,x       ; get creature attribute values
   bne .animateSwarmingInsect       ; branch if object present
   dec tmpSwarmingInsectSpawningTimer;decrement spawning insect timer value
   bpl .doneProcessSwarmingInsects  ; branch if timer not expired
   lda random + 1
   and #7                           ; 0 <= a <= 7
   ora #1
   dec waveNumberSwarmingInsects    ; decrement number of swarming insects
   bpl .spawnSwarmingInsect         ; branch if more swarming insects available
   inc waveNumberSwarmingInsects
   jmp .doneProcessSwarmingInsects
    
.spawnSwarmingInsect
   sta tmpSwarmingInsectSpawningTimer
   inc numberActiveSwarmingInsects  ; increment number of active swarming insects
   lda waveState                    ; get current game wave values
   and #SWARMING_WAVE_MASK          ; keep SWARMING_WAVE value
   ora tmpSwarmingSpawningInsectValue
   tay
   lda SwarmingInsectSpawningValues,y;get spawning insect id value
   sta creatureSpriteIds_W,x
   cmp #ID_DRAGONFLY
   lda random
   and #$7C                         ; a = 0 || 4 <= a <= 124
   sta creatureHorizPositions_W,x   ; set swarming insect horizontal position
   bcs .setSwarmingDragonflyAttributeValues;branch if ID_DRAGONFLY
   lda #MAX_KERNEL_SECTIONS - 1
   sta creatureAttributes_W,x
   bne .doneProcessSwarmingInsects  ; unconditional branch

.setSwarmingDragonflyAttributeValues
   cmp #103
   lda #[(MAX_KERNEL_SECTIONS - 1) << 1]
   ror                              ; shift carry to D7
   sta creatureAttributes_W,x
   bne .doneProcessSwarmingInsects  ; unconditional branch

.animateSwarmingInsect
   ldy creatureSpriteIds_R,x        ; get creature sprite id value
   lda ObjectAnimationTable,y
   sta creatureSpriteIds_W,x
.doneProcessSwarmingInsects
   jmp .processObjectMovements
    
DetermineSwarmingInsectAudioValue
   bne .doneProcessSwarmingInsects
   lda waveNumberSwarmingInsects
   beq .doneProcessSwarmingInsects
   lda frameCount                   ; get current frame count
   clc
   adc #1
   lsr
   lsr
   lsr
   lsr
   and #3
   sta tmpSwarmingSpawningInsectValue
   lda waveState                    ; get current game wave values
   and #SWARMING_WAVE_MASK          ; keep SWARMING_WAVE value
   ora tmpSwarmingSpawningInsectValue
   tay
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setSwarmingInsectAudioValue
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .doneDetermineSwarmingInsectAudioValue
.setSwarmingInsectAudioValue
   lda SwarmingInsectAudioValues,y
   sta rightSoundChannelIndex
.doneDetermineSwarmingInsectAudioValue
   jmp .processObjectMovements
    
DetermineObjectSpawningRoutine
   lda #>ObjectSpawningRoutines
   sta tmpObjectSpawningVector + 1
   lda ObjectSpawningRoutineTable,x
   sta tmpObjectSpawningVector
   jmp (tmpObjectSpawningVector)
    
ObjectSpawningRoutineTable
   .byte <BranchToCheckToSpawnSpider; not used
   .byte <BranchToCheckToSpawnSpider
   .byte <BranchToCheckToSpawnSpider
   .byte <BranchToCheckToSpawnSpider
   .byte <BranchToCheckToSpawnSpider
   .byte <CheckToSpawnBee
   .byte <CheckToSpawnBeetle
   .byte <CheckToSpawnMosquito
   .byte <CheckToSpawnDragonfly
   .byte <BranchToCheckToSpawnEarwig
   .byte <CheckToSpawnInchworm
   .byte <CheckToSpawnDragonfly
   .byte <CheckToSpawnBee
   .byte <CheckToSpawnMosquito
   .byte <BranchToCheckToSpawnEarwig
   .byte <CheckToSpawnBeetle

InitDDTHorizontalPositionValues
   .byte 32, 40, 48, 56, 64, 72, 80, 88

RandomLeftMushroomValues
   .byte $18,$24,$82,$41,$04,$08,$24,$18
   .byte $92,$61,$48,$84,$11,$22,$43,$83

RandomRightMushroomValues
   .byte $90,$60,$41,$82,$A2,$51,$0A,$05
   .byte $04,$08,$82,$41,$41,$A0,$20,$10

BANK1_MushroomMaskingBits
BANK1_OddMushroomMaskingBits
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
BANK1_EvenMushroomMaskingBits
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00

BANK1_ShooterKernelZoneValues
   .byte 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7
   .byte 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14
   .byte 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20
   .byte 20, 20

BeetleLaunchScoreValues
   .byte $00                     ;       0
   .byte $07                     ;  70,000
   .byte $14                     ; 140,000
   .byte $21                     ; 210,000
   .byte $28                     ; 280,000
   .byte $35                     ; 350,000
   .byte $42                     ; 420,000
   .byte <-1

ExtraSpiderLaunchScoreValues
   .byte $16                     ; 160,000
   .byte $12                     ; 120,000
   .byte $08                     ;  80,000
   .byte $03                     ;  30,000

MillipedeChainGroupSpriteIds
   .byte ID_MILLIPEDE_HEAD
   .byte ID_MILLIPEDE_SEGMENT
   .byte ID_BLANK
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 0
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 1
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 2
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 3
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 4
   .byte DRAW_MILLIPEDE_CHAIN_ZONE | 5

MillipedeChainGroupOffsetValues
   .byte 0, -4, -8, -12, -16, -20, -24, -28, -32

MillipedeHorizontalDirectionMaskValue
   .byte MILLIPEDE_HORIZ_DIR_MASK

InitSpiderHorizontalPositionValues
   .byte 2, 12, 5, 9, 14, 8, 11, 6
   .byte 15, 3, 16, 7, 10, 17, 4, 13

   FILL_BOUNDARY 256, 0

ObjectSpawningRoutines
BranchToCheckToSpawnSpider
   jmp CheckToSpawnSpider

CheckToSpawnMosquito
   lda gardenInsectAttributes_R     ; get garden insect attribute values
   bne .doneCheckForSpawningInsect  ; branch if object present
   lda objectSpawningValues
   and #$10 | OBJECT_SPAWNING_MOSQUITO
   cmp #$10 | OBJECT_SPAWNING_MOSQUITO
   bne .doneCheckForSpawningInsect
   lda objectSpawningValues
   and #<~OBJECT_SPAWNING_MOSQUITO
   sta objectSpawningValues
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setMosquitoAudioValues
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .spawnMosquito
.setMosquitoAudioValues
   lda #<[MosquitoAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.spawnMosquito
   lda #ID_MOSQUITO + 1
   bit random
   bpl .setSpawnedGardenInsectValues
   lda #ID_MOSQUITO
   bne .setSpawnedGardenInsectValues; unconditional branch

CheckToSpawnDragonfly
   lda gardenInsectAttributes_R     ; get garden insect attribute values
   bne .doneCheckForSpawningInsect  ; branch if object present
   lda objectSpawningValues
   and #$40 | OBJECT_SPAWNING_DRAGONFLY
   cmp #$40 | OBJECT_SPAWNING_DRAGONFLY
   bne .doneCheckForSpawningInsect
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setDragonflyAudioValues
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .spawnDragonfly
.setDragonflyAudioValues
   lda #<[DragonflyAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.spawnDragonfly
   lda #ID_DRAGONFLY
   sta dragonflySpriteId_W
   lda random
   and #$7C                         ; a = 0 || 4 <= a <= 124
   sta dragonflyHorizPosition_W     ; set Dragonfly horizontal position value
   cmp #103                         ; move Dragonfly left of greater than 102
   lda #[(MAX_KERNEL_SECTIONS - 1) << 1]
   ror                              ; shift carry to D7
   sta dragonflyAttributes_W        ; set Dragonfly attribute value
   bne .doneCheckForSpawningInsect  ; unconditional branch

CheckToSpawnBee
   lda gardenInsectAttributes_R     ; get garden insect attribute values
   bne .doneCheckForSpawningInsect  ; branch if object present
   lda objectSpawningValues
   bpl .doneCheckForSpawningInsect
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setBeeAudioValues
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .spawnBee
.setBeeAudioValues
   lda #<[BeeAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.spawnBee
   lda #ID_BEE
.setSpawnedGardenInsectValues
   sta gardenInsectSpriteId_W
   lda #MAX_KERNEL_SECTIONS - 1
   sta gardenInsectAttributes_W     ; set object initial KERNEL_SECTION
   lda random
   and #$7C                         ; a = 0 || 4 <= a <= 124
   sta gardenInsectHorizPosition_W  ; set object horizontal position
.doneCheckForSpawningInsect
   jmp .processObjectMovements
    
CheckToSpawnInchworm
   lda gameWaveValues               ; get current game wave values
   cmp #INCHWORM_STARTING_WAVE
   bcc .doneCheckForSpawningInsect  ; branch if not time to launch Inchworm
   lda frameCount                   ; get current frame count
   and #$30
   bne .doneCheckForSpawningInsect
   dec gameState + 1                ; decrement Inchworm spawn timer
   lda gameState + 1                ; get high game state value
   and #SPAWN_INCHWORM_TIMER_MASK   ; keep SPAWN_INCHWORM_TIMER value
   cmp #INIT_INCHWORM_SPAWN_TIMER
   bne .doneCheckForSpawningInsect  ; branch if spawn Inchworm timer not expired
   inc gameState + 1                ; restore high game state value
   lda inchwormAttributes_R
   bne .doneCheckForSpawningInsect  ; branch if object present
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setToPlayInchwormSounds
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .spawnInchworm
.setToPlayInchwormSounds
   lda #<[InchwormAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.spawnInchworm
   lda objectSpawningValues
   and #<~OBJECT_SPAWNING_INCHWORM
   sta objectSpawningValues         ; remove OBJECT_SPAWNING_INCHWORM value
   lda random                       ; get random value for Inchworm kernel zone
   and #7                           ; 0 <= a <= 7
   clc
   adc #7                           ; Inchworm kernel zone between 7 and 14
   ldy #8
   cpy playerScore                  ; compare with score thousands value
   bcc .determineInchwormStartingHorizPosition;branch if score greater than 89,999
   ora #INCHWORM_FAST
.determineInchwormStartingHorizPosition
   ldy #XMIN                        ; assume launching Inchworm from left
   bit random + 1                   ; check random high byte
   bmi .setInchwormPosition         ; branch if launching Inchworm from left
   ora #INCHWORM_DIR_LEFT           ; launch Inchworm from right
   ldy #XMAX - 4
.setInchwormPosition
   sta inchwormAttributes_W         ; set Inchworm attributes
   tya                              ; move horizontal value to accumulator
   sta inchwormHorizPosition_W      ; set Inchworm initial horizontal value
   lda #ID_INCHWORM
   sta inchwormSpriteId_W
   jmp .processObjectMovements
    
BranchToCheckToSpawnEarwig
   jmp CheckToSpawnEarwig

CheckToSpawnBeetle
   lda gameWaveValues               ; get current game wave values
   beq .doneCheckToSpawnBeetle      ; branch if first game wave
   lda beetleSpawnTimer             ; get Beetle spawn timer value
   bpl .doneCheckToSpawnBeetle      ; branch if not time to launch Beetle
   clc
   adc #1
   sta beetleSpawnTimer             ; increment Beetle spawn timer
   and #$0F                         ; 0 <= a <= 15
   bne .doneCheckToSpawnBeetle      ; branch if not time to launch Beetle
   ldy #0
   lda beetleAttributes_R           ; get first Beetle attribute value
   beq .checkToLaunchBeetle         ; branch if object not present
   iny
   lda beetleAttributes_R + 1
   beq .checkToLaunchBeetle         ; branch if second Beetle or Inchworm not present
.reduceBeetleSpawnTimer
   lda beetleSpawnTimer
   sec
   sbc #8
   sta beetleSpawnTimer
.doneCheckToSpawnBeetle
   jmp .processObjectMovements

.checkToLaunchBeetle
   lda beetleSpawnTimer
   and #7 << 4
   lsr
   lsr
   lsr
   lsr
   tax
   lda playerScore                  ; get score thousands value
   cmp BeetleLaunchScoreValues - 1,x
   bcc .reduceBeetleSpawnTimer
   lda random
   and #7                           ; 0 <= a <= 7
   ora beetleSpawnTimer
   sta beetleSpawnTimer
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setToPlayBeetleSounds       ; branch if not playing sounds
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .launchBeetle
.setToPlayBeetleSounds
   lda #<[BeetleAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.launchBeetle
   bit random                       ; check random low byte
   bmi .launchBeetleFromRight       ; branch to launch Beetle from the right
   lda #ID_BEETLE
   sta spriteIdArray_W + 5,y
   lda #INIT_BEETLE_KERNEL_ZONE
   sta beetleAttributes_W,y
   lda #XMIN
   sta beetleHorizPositions_W,y     ; set Beetle to launch from left
   beq .doneLaunchBeetle            ; unconditional branch

.launchBeetleFromRight
   lda #ID_BEETLE + 1
   sta spriteIdArray_W + 5,y
   lda #INIT_BEETLE_KERNEL_ZONE
   sta beetleAttributes_W,y
   lda #XMAX - 8
   sta beetleHorizPositions_W,y
.doneLaunchBeetle
   jmp .processObjectMovements
    
CheckToSpawnEarwig
   lda gardenInsectAttributes_R     ; get garden insect attribute value
   bne .doneCheckToSpawnEarwig      ; branch if object present
   lda objectSpawningValues         ; get object spawing values
   and #OBJECT_SPAWNING_EARWIG      ; keep OBJECT_SPAWNING_EARWIG value
   beq .doneCheckToSpawnEarwig      ; branch if not spawing Earwig
   lda frameCount                   ; get current frame count
   and #$F0                         ; a = 0 || 16 <= a <= 240
   cmp #$70
   bne .doneCheckToSpawnEarwig
   lda frameCount + 1               ; get frame count high byte value
   and #3                           ; 0 <= a <= 7
   bne .doneCheckToSpawnEarwig
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setEarwigAudioValue
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .determineEarwigSpeed
.setEarwigAudioValue
   lda #<[EarwigAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.determineEarwigSpeed
   lda #$FF
   ldy playerScore                  ; get score thousands value
   cpy #$02
   bcc .determineEarwigDirection    ; branch if score less than 20,000
   lda #$40
.determineEarwigDirection
   cmp random
   lda random
   and #7                           ; 0 <= a <= 7
   bcs .setEarwigHorizDirectionAndKernelZone
   ora #EARWIG_FAST
.setEarwigHorizDirectionAndKernelZone
   clc
   adc #MAX_KERNEL_SECTIONS - 8
   sta earwigAttributes_W
   lda #ID_EARWIG + 1
   ldx #XMIN
   bit random + 1                   ; check random high byte
   bpl .initEarwigZoneAndPosition   ; branch to launch Earwig from left
   lda #ID_EARWIG
   ldx #XMAX - 4
.initEarwigZoneAndPosition
   sta earwigSpriteId_W
   stx earwigHorizPosition_W
.doneCheckToSpawnEarwig
   jmp .processObjectMovements
    
CheckToSpawnSpider
   lda creatureAttributes_R,x
   beq .checkToSpawnSpider          ; branch if object not present
   ldy creatureSpriteIds_R,x        ; get creature sprite id value
   lda ObjectAnimationTable,y
   sta creatureSpriteIds_W,x
   jmp .processObjectMovements
    
.checkToSpawnSpider
   lda creatureSpriteIds_R,x        ; get creature sprite id value
   cmp #ID_SPIDER
   bne .processObjectMovements
   lda creatureHorizPositions_R,x   ; get creature horizontal position
   sec
   sbc #1
   sta creatureHorizPositions_W,x
   bne .processObjectMovements
   lda rightSoundChannelIndex       ; get right sound channel index value
   bne .launchSpider
   lda #<[SpiderAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.launchSpider
   bit random                       ; check random low byte
   bmi .launchSpiderFromRight       ; branch to launch Spider from right
   lda #XMIN + 1
   sta creatureHorizPositions_W,x
   lda #OBJECT_DIR_RIGHT | SPIDER_DIR_DOWN | SPIDER_HORIZ_MOVE | [MAX_SPIDER_KERNEL_ZONE - 2]
   sta creatureAttributes_W,x
   bne .processObjectMovements      ; unconditional branch

.launchSpiderFromRight
   lda #XMAX - 8
   sta creatureHorizPositions_W,x
   lda #OBJECT_DIR_LEFT | SPIDER_DIR_DOWN | SPIDER_HORIZ_MOVE | [MAX_SPIDER_KERNEL_ZONE - 2]
   sta creatureAttributes_W,x
.processObjectMovements
   lda #0
   sta tmpShouldProcessObjectMovements;set to process object movements
   lda gardenShiftValues            ; get garden shift value
   bne GardenShiftCheckForActiveDDTCloud
   jmp BANK1_ProcessObjectMovements ; branch if garden not shifting
    
GardenShiftCheckForActiveDDTCloud
   ldx #MAX_DDT_BOMBS - 1
.gardenShiftCheckForActiveDDTCloud
   lda ddtBombAttributes_R,x
   beq .nextDDTCloud                ; branch if object not present
   lda ddtBombSpriteIds_R,x         ; get DDT sprite id value
   cmp #ID_DDT_CLOUD
   bcc .nextDDTCloud                ; branch if ID_DDT
.doneGardenShiftCheckForActiveDDTCloud
   jmp BANK1_ProcessObjectMovements
    
.nextDDTCloud
   dex
   bne .gardenShiftCheckForActiveDDTCloud
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 18
   bcc .doneGardenShiftCheckForActiveDDTCloud;branch if not enough time left
   lda #<-1
   sta tmpSpawnDDTBomb              ; set to spawn new DDT bomb
   lda gardenShiftValues            ; get garden shift value
   bmi ShiftGardenDown              ; branch if garden shifting down
   dec gardenShiftValues            ; decrement shift value
   jmp ShiftGardenUp
    
ShiftGardenDown
   inc gardenShiftValues            ; increment shift value
   ldx #MAX_DDT_BOMBS - 1
.shiftDDTObjectsDown
   lda ddtBombAttributes_R,x        ; get DDT bomb attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp #3
   bcs .shiftObjectDown             ; branch if greater than zone 3
   lda #0
   sta ddtBombAttributes_W,x        ; remove DDT bomb
   bit tmpSpawnDDTBomb
   bpl .shiftNextDDTObjectDown      ; branch if skip spawing DDT bomb
   stx tmpSpawnDDTBomb              ; set to not spawn another DDT bomb
   lda random
   and #7                           ; 0 <= a <= 7
   tay
   lda InitDDTHorizontalPositionValues,y
   sta objectHorizPositions_W,x     ; set new DDT bomb horizontal position
   lda #ID_DDT
   sta spriteIdArray_W,x            ; spawn DDT bomb
   lda #MAX_KERNEL_SECTIONS
   sta objectAttributes_W,x
.shiftObjectDown
   lda objectAttributes_R,x
   sec
   sbc #1
   sta objectAttributes_W,x
.shiftNextDDTObjectDown
   dex
   bne .shiftDDTObjectsDown
   ldx #SKIP_DRAW_INSECT_ZONE
   lda kernelZoneAdjustment         ; get kernel zone adjustment value
   eor #1
   sta kernelZoneAdjustment
   beq .shiftMushroomPatchDown
   stx kernelZoneAttributes_00 + 21
   lda #0
   sta leftMushroomArray_W
   sta rightMushroomArray_W
   sta leftFlowerArray_W
   sta rightFlowerArray_W
   sta kernelZoneAttributes_01 + 20
   jmp .spawnMushrooms
    
.shiftMushroomPatchDown
   stx kernelZoneAttributes_00 + 1
   ldx #0
   stx leftMushroomArray_W + 19
   stx rightMushroomArray_W + 19
   stx kernelZoneAttributes_01 + 20
.shiftPlayerAreaMushroomsDown
   lda leftMushroomArray_R + 2,x
   sta leftMushroomArray_W,x
   lda rightMushroomArray_R + 2,x
   sta rightMushroomArray_W,x
   lda leftFlowerArray_R + 2,x
   sta leftFlowerArray_W,x
   lda rightFlowerArray_R + 2,x
   sta rightFlowerArray_W,x
   lda kernelZoneAttributes_01 + 3,x
   sta kernelZoneAttributes_01 + 1,x
   inx
   cpx #9
   bcc .shiftPlayerAreaMushroomsDown
.shiftGardenAreaMushroomsDown
   lda leftMushroomArray_R + 2,x
   sta leftMushroomArray_W,x
   lda rightMushroomArray_R + 2,x
   sta rightMushroomArray_W,x
   lda kernelZoneAttributes_01 + 3,x
   sta kernelZoneAttributes_01 + 1,x
   inx
   cpx #MAX_KERNEL_SECTIONS - 3
   bcc .shiftGardenAreaMushroomsDown
   lda #0
   sta leftFlowerArray_W + 9
   sta rightFlowerArray_W + 9
   sta leftFlowerArray_W + 10
   sta rightFlowerArray_W + 10
   sta kernelZoneAttributes_01 + 19
.spawnMushrooms
   ldx kernelZoneAdjustment         ; get kernel zone adjustment
   lda random
   and #7                           ; 0 <= a <= 7
   asl                              ; 0 <= a <= 14
   ora kernelZoneAdjustment
   tay
   lda RandomLeftMushroomValues,y
   sta leftMushroomArray_W + 18,x
   lda RandomRightMushroomValues,y
   sta rightMushroomArray_W + 18,x
   jmp BANK1_ProcessObjectMovements
    
ShiftGardenUp
   ldx #MAX_DDT_BOMBS - 1
.shiftDDTObjectsUp
   lda ddtBombAttributes_R,x        ; get DDT bomb attribute values
   beq .shiftNextDDTBombUp          ; branch if object not present
   clc
   adc #1                           ; move object up one kernel zone
   sta ddtBombAttributes_W,x
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp #MAX_KERNEL_SECTIONS
   bcc .shiftNextDDTBombUp
   lda #0
   sta ddtBombAttributes_W,x        ; remove DDT Bomb
.shiftNextDDTBombUp
   dex
   bne .shiftDDTObjectsUp
   ldx #SKIP_DRAW_INSECT_ZONE
   lda kernelZoneAdjustment         ; get kernel zone adjustment
   eor #1
   sta kernelZoneAdjustment
   bne .shiftMushroomPatchUp
   stx kernelZoneAttributes_00 + 1
   lda #0
   sta leftFlowerArray_W + 10
   sta rightFlowerArray_W + 10
   sta leftMushroomArray_W + 19
   sta rightMushroomArray_W + 19
   sta kernelZoneAttributes_01 + 20
   sta kernelZoneAttributes_01
   jmp BANK1_ProcessObjectMovements
    
.shiftMushroomPatchUp
   stx kernelZoneAttributes_00 + 21
   ldx #MAX_KERNEL_SECTIONS - 4
.shiftGardenAreaMushroomsUp
   lda leftMushroomArray_R,x
   sta leftMushroomArray_W + 2,x
   lda rightMushroomArray_R,x
   sta rightMushroomArray_W + 2,x
   lda kernelZoneAttributes_01 + 1,x
   sta kernelZoneAttributes_01 + 3,x
   dex
   cpx #9
   bcs .shiftGardenAreaMushroomsUp
.shiftPlayerAreaMushroomsUp
   lda leftMushroomArray_R,x
   sta leftMushroomArray_W + 2,x
   lda rightMushroomArray_R,x
   sta rightMushroomArray_W + 2,x
   lda leftFlowerArray_R,x
   sta leftFlowerArray_W + 2,x
   lda rightFlowerArray_R,x
   sta rightFlowerArray_W + 2,x
   lda kernelZoneAttributes_01 + 1,x
   sta kernelZoneAttributes_01 + 3,x
   dex
   bpl .shiftPlayerAreaMushroomsUp
   lda #0
   sta leftFlowerArray_W
   sta rightFlowerArray_W
   sta leftFlowerArray_W + 1
   sta rightFlowerArray_W + 1
   sta leftMushroomArray_W
   sta rightMushroomArray_W
   sta leftMushroomArray_W + 1
   sta rightMushroomArray_W + 1
   sta kernelZoneAttributes_01 + 1
   sta kernelZoneAttributes_01
   jmp BANK1_ProcessObjectMovements

ObjectAnimationTable
   .byte ID_BLANK
   .byte ID_BEE + 1
   .byte ID_BEE
   .byte ID_EARWIG + 2
   .byte ID_EARWIG + 3
   .byte ID_EARWIG
   .byte ID_EARWIG + 1
   .byte ID_SPIDER + 1
   .byte ID_SPIDER + 2
   .byte ID_SPIDER
   .byte ID_MOSQUITO + 2
   .byte ID_MOSQUITO + 3
   .byte ID_MOSQUITO
   .byte ID_MOSQUITO + 1
   .byte ID_DRAGONFLY + 1
   .byte ID_DRAGONFLY + 2
   .byte ID_DRAGONFLY
   .byte ID_INCHWORM + 1
   .byte ID_INCHWORM + 2
   .byte ID_INCHWORM
   .byte ID_BEETLE + 2
   .byte ID_BEETLE + 3
   .byte ID_BEETLE + 4
   .byte ID_BEETLE + 5
   .byte ID_BEETLE + 6
   .byte ID_BEETLE + 7
   .byte ID_BEETLE
   .byte ID_BEETLE + 1
   .byte ID_SHOOTER_DEATH
   .byte ID_SHOOTER_DEATH + 1
   .byte ID_SHOOTER_DEATH + 2
   .byte ID_SHOOTER_DEATH + 3
   .byte ID_SPARK
   .byte ID_SPARK + 1
   .byte ID_MILLIPEDE_HEAD
   .byte ID_MILLIPEDE_SEGMENT
   .byte ID_POINTS_200
   .byte ID_POINTS_300
   .byte ID_POINTS_400
   .byte ID_POINTS_500
   .byte ID_POINTS_600
   .byte ID_POINTS_700
   .byte ID_POINTS_800
   .byte ID_POINTS_900
   .byte ID_POINTS_1000
   .byte ID_POINTS_1200
   .byte ID_POINTS_1800

DDTCloudPointValues
   .byte 0                          ; ID_CLOUD
   DDT_CREATURE_POINT_VALUE [POINTS_BEE >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEE >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_EARWIG >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_EARWIG >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_EARWIG >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_EARWIG >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_SPIDER_MEDIUM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_SPIDER_MEDIUM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_SPIDER_MEDIUM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_MOSQUITO >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_MOSQUITO >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_MOSQUITO >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_MOSQUITO >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_DRAGONFLY >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_DRAGONFLY >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_DRAGONFLY >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_INCHWORM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_INCHWORM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_INCHWORM >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
   DDT_CREATURE_POINT_VALUE [POINTS_BEETLES >> 8]
    
   IF ORIGINAL_ROM

      FILL_BOUNDARY 228, 0   

   .byte "  DAVE STAUGAS LOVES BEATRICE HABLIG  "

   ELSE
   
      FILL_BOUNDARY 256, 0

   ENDIF

   FILL_BOUNDARY 228, 0

BANK1_ProcessObjectMovements
   lda BANK2STROBE
   jmp.w $00

BANK1_SwitchToScoreKernel
   lda BANK1STROBE
   jmp Overscan
    
BANK1_Start
   lda BANK3STROBE
   jmp BANK3_Start

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data

   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK1"
   
   .word BANK1_Start
   .word BANK1_Start
   .word BANK1_Start

;===============================================================================
; R O M - C O D E (BANK2)
;===============================================================================

   SEG Bank2
   .org BANK2_BASE
   .rorg BANK2_REORG

FREE_BYTES SET 0

   .ds 256, 0                       ; first page reserved for Superchip RAM

ScoreKernel
   lda #>NumberFonts          ; 2 = @35
   sta graphicsPointers + 1   ; 3
   sta graphicsPointers + 3   ; 3
   SLEEP 2                    ; 2
   ldy #BLACK                 ; 2
   lda playerScore            ; 3         get score thousands value
   lsr                        ; 2         shift upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   bne .setHundredThousandsZeroSuppressValue;2³
   lda #ID_BLANK_FONT         ; 2         suppress leading zero
.setHundredThousandsZeroSuppressValue
   sta tmpZeroSuppressValue   ; 3
   tax                        ; 2
   lda NumberTable,x          ; 4         get graphic LSB value
   sta graphicsPointers       ; 3         set digit graphic pointer LSB value
   lda gameWaveValues         ; 3         get current game wave values
;--------------------------------------
   clc                        ; 2 = @01
   adc #6                     ; 2
   tax                        ; 2
   lda BANK2_WaveColorValues,x; 4         set to score border color index
   and #$F0                   ; 2         keep color value
   ora #7                     ; 2         set luminance value
   sty COLUBK                 ; 3 = @16
   sta COLUPF                 ; 3 = @19
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @24
   sta PF2                    ; 3 = @27
   sty GRP1                   ; 3 = @30
   sty GRP0                   ; 3 = @33
   lda playerScore            ; 3         get score thousands value
   and #$0F                   ; 2         keep lower nybbles
   bne .setTenThousandsZeroSuppressValue;2³
   lda #ID_BLANK_FONT         ; 2
   cmp tmpZeroSuppressValue   ; 3
   bmi .setTenThousandsZeroSuppressValue;2³
   beq .setTenThousandsZeroSuppressValue;2³
   lda #ID_ZERO               ; 2
.setTenThousandsZeroSuppressValue
   sta tmpZeroSuppressValue   ; 3
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers + 2   ; 3         set digit graphic pointer LSB value
   lda playerScore + 1        ; 3         get score hundreds value
   lsr                        ; 2         shift upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   bne .setThousandsZeroSuppressValue;2³
   lda #ID_BLANK_FONT         ; 2
   cmp tmpZeroSuppressValue   ; 3
   beq .setThousandsZeroSuppressValue;2³
   lda #ID_ZERO               ; 2
.setThousandsZeroSuppressValue
   sta tmpZeroSuppressValue   ; 3
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers + 4   ; 3         set digit graphic pointer LSB value
   lda playerScore + 1        ; 3         get score hundreds value
   and #$0F                   ; 2         keep lower nybbles
   bne .setHundredsZeroSuppressValue;2³
   lda #ID_BLANK_FONT         ; 2
   cmp tmpZeroSuppressValue   ; 3
   beq .setHundredsZeroSuppressValue;2³
   lda #ID_ZERO               ; 2
.setHundredsZeroSuppressValue
   sta tmpZeroSuppressValue   ; 3
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers + 6   ; 3         set digit graphic pointer LSB value
   lda playerScore + 2        ; 3         get score ones value
   lsr                        ; 2         shift upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   lda NumberTable,y          ; 4
   sta graphicsPointers + 8   ; 3
   sta WSYNC
;---------------------------------------
   lda.w playerScore + 2      ; 4         get score ones value
   and #$0F                   ; 2         keep lower nybbles
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers + 10  ; 3         set digit graphic pointer LSB value
   ldx #BLACK                 ; 2
   stx COLUPF                 ; 3 = @20
   lda gameState              ; 3         get current game state
   and #LIVES_MASK            ; 2         keep number of lives
   tay                        ; 2
   lda LivesGraphicsPF1Values,y;4
   sta PF1                    ; 3 = @34
   lda LivesGraphicsPF2Values,y;4
   sta PF2                    ; 3 = @41
   stx HMP1                   ; 3 = @44   set to HMOVE_0 (i.e. x = 0)
   inx                        ; 2         x = 1
   stx VDELP0                 ; 3 = @49
   lda #THREE_COPIES          ; 2
   sta RESP0                  ; 3 = @54
   sta RESP1                  ; 3 = @57
   stx VDELP1                 ; 3 = @60
   sta NUSIZ0                 ; 3 = @63
   sta NUSIZ1                 ; 3 = @66
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @71
   lda frameCount             ; 3         get current frame count
   ldx #COLORS_SCORE          ; 2 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   bit gameState              ; 3         check current game state
   bvc .currentlySelectingGame; 2³        branch if not GS_SELECTING_GAME
   SLEEP 2                    ; 2
   and #8                     ; 2
   beq .flashScoreColors      ; 2³
   bne .setScoreColors        ; 3         unconditional branch

.currentlySelectingGame
   jmp .checkToSetColorsForTitleScreen;3
    
.checkToSetColorsForTitleScreen
   bmi .flashScoreColors      ; 2³        branch if GS_GAME_OVER
   bpl .setScoreColors        ; 3         unconditional branch

.flashScoreColors
   tax                        ; 2
.setScoreColors
   stx COLUP0                 ; 3 = @20
   stx COLUP1                 ; 3 = @23
   lda #>NumberFonts          ; 2
   sta graphicsPointers + 5   ; 3
   sta graphicsPointers + 7   ; 3
   sta graphicsPointers + 9   ; 3
   sta graphicsPointers + 11  ; 3
   ldx displayScanOutControl  ; 3         get display scan out value
   lda RemainingLivesColorMaskValues,x;4
   ldx gameWaveValues         ; 3         get current game wave values
   and BANK2_WaveColorValues,x; 4
   sta tmpRemainingLivesColor ; 3
   SLEEP_6                    ; 6
   lda #<BANK0_SoundRoutines  ; 2
   sta soundRoutineVector     ; 3
   lda soundRoutineVector     ; 3         wait 3 cycles
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 1          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 2          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 3          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 4          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 5          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @15
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @23
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 6          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda tmpRemainingLivesColor ; 3
   sta COLUPF                 ; 3 = @74
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   ldy #H_DIGITS - 7          ; 2
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @10
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @18
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @26
   lda (graphicsPointers + 6),y;5
   sta tmpHundredsValueHolder ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @53
   lda tmpHundredsValueHolder ; 3
   sta GRP1                   ; 3 = @59
   stx GRP0                   ; 3 = @62
   sty GRP1                   ; 3 = @65
   sta GRP0                   ; 3 = @68
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @73
   sta VDELP1                 ; 3 = @76
;--------------------------------------
   sta GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   sta PF1                    ; 3 = @09
   sta PF2                    ; 3 = @12
   lda #DISABLE_TIA           ; 2
   sta VBLANK                 ; 3 = @17
   lda #OVERSCAN_TIME
   sta TIM64T
   jmp BANK2_JumpToOverscan   ; 3

RemainingLivesColorMaskValues
   .byte $FF, $FF, $F6

NumberTable
   .byte <zero, <one, <two, <three, <four, <five
   .byte <six, <seven, <eight, <nine, <Blank

NumberFonts
seven
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $3E ; |..XXXXX.|
;
; last byte shared with table below
;
two
   .byte $3E ; |..XXXXX.|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $0E ; |....XXX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
zero
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
three
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
six
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $3C ; |..XXXX..|
   .byte $30 ; |..XX....|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
eight
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
nine
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $06 ; |.....XX.|
   .byte $1E ; |...XXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
;   .byte $1C ; |...XXX..|
;
; last byte shared with table below
;
five
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $3C ; |..XXXX..|
   .byte $30 ; |..XX....|
   .byte $3E ; |..XXXXX.|
one
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
four
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $3E ; |..XXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $1E ; |...XXXX.|
   .byte $0E ; |....XXX.|
   .byte $06 ; |.....XX.|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

LivesGraphicsPF1Values
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $A0 ; |X.X.....|
   .byte $A8 ; |X.X.X...|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
LivesGraphicsPF2Values
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $05 ; |.....X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|

BANK2_WaveColorValues
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE
   .byte COLORS_ORANGE, COLORS_BLUE, COLORS_YELLOW, COLORS_PURPLE
   .byte COLORS_RED, COLORS_COBALT_BLUE, COLORS_DK_GREEN, COLORS_DK_BLUE

   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY
   .byte COLORS_GREY, COLORS_GREY, COLORS_GREY, COLORS_GREY

SetupDrawBitmapKernel SUBROUTINE
   lda playerShotEnableIndex  ; 3 = @40
   sta tmpPlayerShotEnableIndex;3
   lda kernelShooterState     ; 3
   sta tmpKernelShooterState  ; 3
   lda shooterKernelZoneValue ; 3
   sta tmpShooterKernelZoneValue;3
   lda #0                     ; 2
   sta kernelZoneAttributes_01 - 1,x;4
   sta kernelZoneAttributes_00 + 21,x;4
   sta kernelZoneAttributes_00 + 20,x;4
   sta kernelZoneAttributes_00 + 19,x;4
;--------------------------------------
   sta kernelZoneAttributes_00 + 18,x;4 = @01
   ldy #MSBL_SIZE1 | THREE_COPIES;2
   sta REFP0                  ; 3 = @06
   sta REFP1                  ; 3 = @09
   sty NUSIZ0                 ; 3 = @12
   sty NUSIZ1                 ; 3 = @15
   sty VDELP0                 ; 3 = @18
   sty VDELP1                 ; 3 = @21
   sta GRP0                   ; 3 = @24
   sta GRP1                   ; 3 = @27
   sta GRP0                   ; 3 = @30
   sta GRP1                   ; 3 = @33
   sta HMP1                   ; 3 = @36
   sta RESP0                  ; 3 = @39
   sta RESP1                  ; 3 = @42
   ldy #HMOVE_R1              ; 2
   sty HMP0                   ; 3 = @47
   lda #>TitleScreenGraphics  ; 2
   sta graphicsPointers + 1   ; 3
   sta graphicsPointers + 3   ; 3
   sta graphicsPointers + 5   ; 3
   sta graphicsPointers + 7   ; 3
   sta graphicsPointers + 9   ; 3
   sta graphicsPointers + 11  ; 3
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @72
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta VBLANK                 ; 3 = @06   enable TIA (i.e. D1 = 0)
   lda #<TitleBitmap_00       ; 2
   sta graphicsPointers       ; 3
   lda #<TitleBitmap_01       ; 2
   sta graphicsPointers + 2   ; 3
   lda #<TitleBitmap_02       ; 2
   sta graphicsPointers + 4   ; 3
   lda #<TitleBitmap_03       ; 2
   sta graphicsPointers + 6   ; 3
   lda #<TitleBitmap_04       ; 2
   sta graphicsPointers + 8   ; 3
   lda #<TitleBitmap_05       ; 2
   sta graphicsPointers + 10  ; 3
   lda tmpPlayerShotEnableIndex;3
   bmi .prepareToDrawShooter  ; 2³
   sec                        ; 2
   sbc #14                    ; 2
   sta tmpPlayerShotEnableIndex;3
   bcs .positionShooterHorizontally;2³
   adc tmpKernelShooterState  ; 3
   adc #1                     ; 2
   jmp .setKernelShooterState ; 3
    
.prepareToDrawShooter
   lda tmpKernelShooterState  ; 3
.setKernelShooterState
   sta tmpPlayerShotEnableIndex;3
   lda #POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT;2
   sta CTRLPF                 ; 3
   sta tmpKernelShooterState  ; 3
.positionShooterHorizontally
   ldy shooterHorizPos        ; 3
   sta WSYNC
;--------------------------------------
   bit tmpKernelShooterState  ; 3
   bvc .colorBitmapSprites    ; 2³
   lda #POSITION_SHOOTER - 1  ; 2
   sta tmpKernelShooterState  ; 3
   lda BANK2_HMOVE_Table + 1,y; 4
   sta HMBL                   ; 3 = @17
   and #$0F                   ; 2
   tay                        ; 2
.coarsePositionShooter
   dey                        ; 2
   bpl .coarsePositionShooter ; 2³
   sta RESBL                  ; 3
.colorBitmapSprites
   lda tmpNormalMushroomColor ; 3
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @03
   sta COLUP1                 ; 3 = @06
   lda tmpKernelZone_BANK0    ; 3
   sec                        ; 2
   sbc #5                     ; 2
   sta tmpKernelZone_BANK0    ; 3
   lda #SKIP_DRAW_INSECT_ZONE ; 2
   sta kernelZoneAttributes_00,x;4
   sta kernelZoneAttributes_00 - 1,x;4
   sta kernelZoneAttributes_00 - 2,x;4
   sta kernelZoneAttributes_00 - 3,x;4
   sta kernelZoneAttributes_00 - 4,x;4
   bit gameState + 1          ; 3         check high game state value
   bmi .displayGameOverGraphics;2³        branch if GS_SHOW_GAME_OVER
   bit gameState              ; 3         check current game state
   bvs .setupForGameOverOrStartingScore;2³ branch if GS_SELECTING_GAME
   bvc DrawTitleBitmap        ; 3         unconditional branch

.displayGameOverGraphics
   clv                        ; 2         clear overflow for not selecting game
.setupForGameOverOrStartingScore
   jmp SetupPointersForGameOverBitmap;3
    
DrawTitleBitmap
   lda #H_TITLE_BITMAP - 1    ; 2
DrawBitmapKernel
   clc                        ; 2
   sta tmpBitmapDisplayLoop   ; 3
.drawBitmapKernel
   ldy tmpBitmapDisplayLoop   ; 3
   lda (graphicsPointers),y   ; 5
   sta GRP0                   ; 3 = @72
   sta WSYNC
;--------------------------------------
   lda (graphicsPointers + 2),y;5
   sta GRP1                   ; 3 = @08
   lda (graphicsPointers + 4),y;5
   sta GRP0                   ; 3 = @16
   lda (graphicsPointers + 6),y;5
   sta tmpCharHolder          ; 3
   lda (graphicsPointers + 8),y;5
   tax                        ; 2
   lda (graphicsPointers + 10),y;5
   tay                        ; 2
   lda tmpCharHolder          ; 3
   sta GRP1                   ; 3 = @44
   stx GRP0                   ; 3 = @47
   sty GRP1                   ; 3 = @50
   sty GRP0                   ; 3 = @53
   dec tmpBitmapDisplayLoop   ; 5
   bpl .drawBitmapKernel      ; 2³
   ldy #0                     ; 2
   sty GRP0                   ; 3 = @65
   sty GRP1                   ; 3 = @68
   sty GRP0                   ; 3 = @71
   sty GRP1                   ; 3 = @74
;--------------------------------------
   sty VDELP0                 ; 3 = @01
   sty VDELP1                 ; 3 = @04
   lda displayScanOutControl  ; 3         get display scan out value
   sta VBLANK                 ; 3 = @10
   lda tmpPlayerShotEnableIndex;3
   sta playerShotEnableIndex  ; 3
   ldx tmpKernelZone_BANK0    ; 3
   lda kernelZoneAttributes_00,x;4        get object 0 zone attributes
   and #SPRITE_ID_IDX_MASK    ; 2         keep SPRITE_ID_IDX value
   tay                        ; 2
   ldx objectHorizPositions_R,y;4
   lda BANK2_HMOVE_Table,x    ; 4
   sta tmpObjectFineHorizValue; 3
   and #$0F                   ; 2
   tax                        ; 2
   lda BANK2_CoarsePositionRoutineTableObject_00,x;4
   sta tmpCoarsePositionObject0Vector;3
   ldy #0                     ; 2
   lda #>CoarsePositionObject0Routines;2
   sta tmpCoarsePositionObject0Vector + 1;3
   lda #>CoarsePositionObject1Routines;2
   sta tmpCoarsePositionObject1Vector + 1;3
   lda #>CoarsePositionShooterRoutines;2
   sta tmpCoarsePositionShooterVector + 1;3
   lda tmpKernelShooterState  ; 3
   sta kernelShooterState     ; 3
   lda tmpKernelZone_BANK0    ; 3
   beq .doneBitmapKernelForSelectingScore;2³
   lda tmpShooterKernelZoneValue;3
   sta shooterKernelZoneValue ; 3
   jmp BANK2_JumpIntoGraphicsZone_05;3
    
.doneBitmapKernelForSelectingScore
   jmp DoneBitmapKernelForSelectingScore;3
    
   FILL_BOUNDARY 256, 0

BANK2_HMOVE_Table
   .byte HMOVE_L5 | 0, HMOVE_L4 | 0, HMOVE_L3 | 0, HMOVE_L2 | 0, HMOVE_L1 | 0
   .byte HMOVE_0  | 0, HMOVE_R1 | 0, HMOVE_R2 | 0, HMOVE_R3 | 0, HMOVE_R4 | 0
   .byte HMOVE_R5 | 0, HMOVE_R6 | 0, HMOVE_R7 | 0, HMOVE_R8 | 0

   .byte HMOVE_L6 | 1, HMOVE_L5 | 1, HMOVE_L4 | 1, HMOVE_L3 | 1, HMOVE_L2 | 1
   .byte HMOVE_L1 | 1, HMOVE_0  | 1, HMOVE_R1 | 1, HMOVE_R2 | 1, HMOVE_R3 | 1
   .byte HMOVE_R4 | 1, HMOVE_R5 | 1, HMOVE_R6 | 1, HMOVE_R7 | 1, HMOVE_R8 | 1
   
   .byte HMOVE_L6 | 2, HMOVE_L5 | 2, HMOVE_L4 | 2, HMOVE_L3 | 2, HMOVE_L2 | 2
   .byte HMOVE_L1 | 2, HMOVE_0  | 2, HMOVE_R1 | 2, HMOVE_R2 | 2, HMOVE_R3 | 2
   .byte HMOVE_R4 | 2, HMOVE_R5 | 2, HMOVE_R6 | 2, HMOVE_R7 | 2, HMOVE_R8 | 2
   
   .byte HMOVE_L6 | 3, HMOVE_L5 | 3, HMOVE_L4 | 3, HMOVE_L3 | 3, HMOVE_L2 | 3
   .byte HMOVE_L1 | 3, HMOVE_0  | 3, HMOVE_R1 | 3, HMOVE_R2 | 3, HMOVE_R3 | 3
   .byte HMOVE_R4 | 3, HMOVE_R5 | 3, HMOVE_R6 | 3, HMOVE_R7 | 3, HMOVE_R8 | 3
   
   .byte HMOVE_L6 | 4, HMOVE_L5 | 4, HMOVE_L4 | 4, HMOVE_L3 | 4, HMOVE_L2 | 4
   .byte HMOVE_L1 | 4, HMOVE_0  | 4, HMOVE_R1 | 4, HMOVE_R2 | 4, HMOVE_R3 | 4
   .byte HMOVE_R4 | 4, HMOVE_R5 | 4, HMOVE_R6 | 4, HMOVE_R7 | 4, HMOVE_R8 | 4
   
   .byte HMOVE_L6 | 5, HMOVE_L5 | 5, HMOVE_L4 | 5, HMOVE_L3 | 5, HMOVE_L2 | 5
   .byte HMOVE_L1 | 5, HMOVE_0  | 5, HMOVE_R1 | 5, HMOVE_R2 | 5, HMOVE_R3 | 5
   .byte HMOVE_R4 | 5, HMOVE_R5 | 5, HMOVE_R6 | 5, HMOVE_R7 | 5, HMOVE_R8 | 5
   
   .byte HMOVE_L6 | 6, HMOVE_L5 | 6, HMOVE_L4 | 6, HMOVE_L3 | 6, HMOVE_L2 | 6
   .byte HMOVE_L1 | 6, HMOVE_0  | 6, HMOVE_R1 | 6, HMOVE_R2 | 6, HMOVE_R3 | 6
   .byte HMOVE_R4 | 6, HMOVE_R5 | 6, HMOVE_R6 | 6, HMOVE_R7 | 6, HMOVE_R8 | 6

   .byte HMOVE_L6 | 7, HMOVE_L5 | 7, HMOVE_L4 | 7, HMOVE_L3 | 7, HMOVE_L2 | 7
   .byte HMOVE_L1 | 7, HMOVE_0  | 7, HMOVE_R1 | 7, HMOVE_R2 | 7, HMOVE_R3 | 7
   .byte HMOVE_R4 | 7, HMOVE_R5 | 7, HMOVE_R6 | 7, HMOVE_R7 | 7, HMOVE_R8 | 7

   .byte HMOVE_L6 | 8, HMOVE_L5 | 8, HMOVE_L4 | 8, HMOVE_L3 | 8, HMOVE_L2 | 8
   .byte HMOVE_L1 | 8, HMOVE_0  | 8, HMOVE_R1 | 8, HMOVE_R2 | 8

BANK2_CoarsePositionRoutineTableObject_00
   .byte <CoarsePositionObject0ToCycle28
   .byte <CoarsePositionObject0ToCycle33
   .byte <CoarsePositionObject0ToCycle38
   .byte <CoarsePositionObject0ToCycle43
   .byte <CoarsePositionObject0ToCycle48
   .byte <CoarsePositionObject0ToCycle53
   .byte <CoarsePositionObject0ToCycle58
   .byte <CoarsePositionObject0ToCycle63
   .byte <CoarsePositionObject0ToCycle68

DoneBitmapKernelForSelectingScore
   lda tmpKernelZone_BANK3    ; 3
   sta tmpKernelZone_BANK0    ; 3
   lda #0                     ; 2
   sta tmpKernelZone_BANK3    ; 3
   lda tmpShooterKernelZoneValue;3
   ldx #10                    ; 2
.bitmapKernelWait
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .bitmapKernelWait      ; 2³
   sta shooterKernelZoneValue ; 3
   jmp BANK2_JumpIntoGraphicsZone_05;3
    
SetupPointersForGameOverBitmap SUBROUTINE
   lda #>GameOverBitmap       ; 2
   sta graphicsPointers + 1   ; 3
   sta graphicsPointers + 3   ; 3
   sta graphicsPointers + 5   ; 3
   sta graphicsPointers + 7   ; 3
   sta graphicsPointers + 9   ; 3
   sta graphicsPointers + 11  ; 3
   bvs SetupPointersForStartingScore;2³   branch if GS_SELECTING_GAME
   lda #<GameOverBitmap_00    ; 2
   sta graphicsPointers       ; 3
   lda #<GameOverBitmap_01    ; 2
   sta graphicsPointers + 2   ; 3
   lda #<GameOverBitmap_02    ; 2
   sta graphicsPointers + 4   ; 3
   lda #<GameOverBitmap_03    ; 2
   sta graphicsPointers + 6   ; 3
   lda #<GameOverBitmap_04    ; 2
   sta graphicsPointers + 8   ; 3
   lda #<GameOverBitmap_05    ; 2
   sta graphicsPointers + 10  ; 3
   bne .setBankKernelZoneValues;3         unconditional branch

SetupPointersForStartingScore
   lda #<SelectStartingScoreBitmap_00;2
   sta graphicsPointers       ; 3
   lda #<SelectStartingScoreBitmap_01;2
   sta graphicsPointers + 2   ; 3
   lda #<SelectStartingScoreBitmap_02;2
   sta graphicsPointers + 4   ; 3
   lda #<SelectStartingScoreBitmap_03;2
   sta graphicsPointers + 6   ; 3
   lda #<SelectStartingScoreBitmap_04;2
   sta graphicsPointers + 8   ; 3
   lda #<SelectStartingScoreBitmap_05;2
   sta graphicsPointers + 10  ; 3
.setBankKernelZoneValues
   lda tmpKernelZone_BANK0    ; 3
   sta tmpKernelZone_BANK3    ; 3
   lda #0                     ; 2
   sta tmpKernelZone_BANK0    ; 3
   ldx #9                     ; 2
.bitmapKernelWait
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .bitmapKernelWait      ; 2³
   lda #H_GAME_OVER_BITMAP - 1; 2
   jmp DrawBitmapKernel       ; 3
    
   FILL_BOUNDARY 256, 0

TitleScreenGraphics
TitleBitmap_00
   .byte $0F ; |....XXXX|
   .byte $10 ; |...X....|
   .byte $16 ; |...X.XX.|
   .byte $14 ; |...X.X..|
   .byte $16 ; |...X.XX.|
   .byte $10 ; |...X....|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
TitleBitmap_01
   .byte $0B ; |....X.XX|
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $8B ; |X...X.XX|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $0B ; |....X.XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $0D ; |....XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
TitleBitmap_02
   .byte $B8 ; |X.XXX...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $BB ; |X.XXX.XX|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $B8 ; |X.XXX...|
   .byte $00 ; |........|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $B7 ; |X.XX.XXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B7 ; |X.XX.XXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $B0 ; |X.XX....|
   .byte $80 ; |X.......|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
TitleBitmap_03
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8E ; |X...XXX.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8E ; |X...XXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C7 ; |XX...XXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $6F ; |.XX.XXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $C7 ; |XX...XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
TitleBitmap_04
   .byte $4A ; |.X..X.X.|
   .byte $4A ; |.X..X.X.|
   .byte $4A ; |.X..X.X.|
   .byte $4E ; |.X..XXX.|
   .byte $4A ; |.X..X.X.|
   .byte $4A ; |.X..X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $8F ; |X...XXXX|
   .byte $9F ; |X..XXXXX|
   .byte $99 ; |X..XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $8F ; |X...XXXX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
TitleBitmap_05
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $C8 ; |XX..X...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $C8 ; |XX..X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $9E ; |X..XXXX.|
   .byte $BE ; |X.XXXXX.|
   .byte $BE ; |X.XXXXX.|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $BF ; |X.XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $B3 ; |X.XX..XX|
   .byte $B3 ; |X.XX..XX|
   .byte $B3 ; |X.XX..XX|
   .byte $B3 ; |X.XX..XX|
   .byte $BF ; |X.XXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $9E ; |X..XXXX.|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|

   FILL_BOUNDARY 256, 0

CheckToProcessObjectMovements
   lda tmpShouldProcessObjectMovements;get status to process object movements
   bne .skipProcessObjectMovements
   bit inchwormWaveState            ; check Inchworm wave state
   bpl ProcessObjectMoveRoutines    ; branch if PLAYER_MOVEMENT_NORMAL
.skipProcessObjectMovements
   jmp SwitchBankForNewFrame
    
ProcessObjectMoveRoutines
   ldx #4
   lda #>ObjectMovementRoutines
   sta tmpObjectMoveRoutineVector + 1
   bit waveState                    ; check current game wave values
   bpl .processObjectMoveRoutines   ; branch if NOT_SWARMING
   ldx #13
.processObjectMoveRoutines
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 4
   bpl .timeToSafelyProcessMovement ; branch if time available to process move
   jmp SwitchBankForNewFrame
    
.timeToSafelyProcessMovement
   ldy creatureAttributes_R,x       ; get creature attribute values
   bne .processObjectMovementRoutine; branch if creature present
MoveNextObject
   dex
   bpl .processObjectMoveRoutines
   jmp SwitchBankForNewFrame
    
.processObjectMovementRoutine
   lda creatureSpriteIds_R,x        ; get creature sprite id value
   stx tmpSpriteIdx
   tax
   lda ObjectMoveRoutineTable,x
   sta tmpObjectMoveRoutineVector
   ldx tmpSpriteIdx
   jmp (tmpObjectMoveRoutineVector)
       
GameOverBitmap
GameOverBitmap_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $73 ; |.XXX..XX|
   .byte $FB ; |XXXXX.XX|
   .byte $FB ; |XXXXX.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $CB ; |XX..X.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FB ; |XXXXX.XX|
   .byte $79 ; |.XXXX..X|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameOverBitmap_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $DA ; |XX.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $DF ; |XX.XXXXX|
   .byte $8F ; |X...XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameOverBitmap_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $BC ; |X.XXXX..|
   .byte $BC ; |X.XXXX..|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $BC ; |X.XXXX..|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $BC ; |X.XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameOverBitmap_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0E ; |....XXX.|
   .byte $1F ; |...XXXXX|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $1F ; |...XXXXX|
   .byte $0E ; |....XXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameOverBitmap_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $33 ; |..XX..XX|
   .byte $33 ; |..XX..XX|
   .byte $7B ; |.XXXX.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $6B ; |.XX.X.XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameOverBitmap_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $D9 ; |XX.XX..X|
   .byte $D9 ; |XX.XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $1B ; |...XX.XX|
   .byte $1E ; |...XXXX.|
   .byte $DF ; |XX.XXXXX|
   .byte $19 ; |...XX..X|
   .byte $19 ; |...XX..X|
   .byte $DF ; |XX.XXXXX|
   .byte $DE ; |XX.XXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
SelectStartingScoreBitmap
SelectStartingScoreBitmap_00
   .byte $C9 ; |XX..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $89 ; |X...X..X|
   .byte $89 ; |X...X..X|
   .byte $DD ; |XX.XXX.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SelectStartingScoreBitmap_01
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $58 ; |.X.XX...|
   .byte $DC ; |XX.XXX..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $DD ; |XX.XXX.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $39 ; |..XXX..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $39 ; |..XXX..X|
   .byte $21 ; |..X....X|
   .byte $21 ; |..X....X|
   .byte $39 ; |..XXX..X|
SelectStartingScoreBitmap_02
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $95 ; |X..X.X.X|
   .byte $97 ; |X..X.XXX|
   .byte $96 ; |X..X.XX.|
   .byte $D4 ; |XX.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $CE ; |XX..XXX.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $C8 ; |XX..X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $C8 ; |XX..X...|
SelectStartingScoreBitmap_03
   .byte $B8 ; |X.XXX...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $B8 ; |X.XXX...|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $B8 ; |X.XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $73 ; |.XXX..XX|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $72 ; |.XXX..X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $73 ; |.XXX..XX|
SelectStartingScoreBitmap_04
   .byte $DB ; |XX.XX.XX|
   .byte $52 ; |.X.X..X.|
   .byte $52 ; |.X.X..X.|
   .byte $D2 ; |XX.X..X.|
   .byte $92 ; |X..X..X.|
   .byte $92 ; |X..X..X.|
   .byte $DB ; |XX.XX.XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $88 ; |X...X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $9C ; |X..XXX..|
SelectStartingScoreBitmap_05
   .byte $AB ; |X.X.X.XX|
   .byte $AA ; |X.X.X.X.|
   .byte $B2 ; |X.XX..X.|
   .byte $BB ; |X.XXX.XX|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $BB ; |X.XXX.XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   FILL_BOUNDARY 256, 0

ObjectMovementRoutines
MoveBeetle
   jmp MoveBeetleRoutine

MoveBee
   jmp MoveBeeRoutine

MoveEarwig
   tya                              ; move Earwig attributes to accumulator
   asl                              ; shift EARWIG_SPEED to carry
   lda #3                           ; move 1/4 of the time
   bcc .checkMoveEarwigFrame        ; branch if EARWIG_SLOW
   lda #1                           ; move 1/2 of the time
.checkMoveEarwigFrame
   and frameCount
   bne .doneMoveEarwig              ; branch if not time to move Earwig
   lda creatureSpriteIds_R,x        ; get Earwig sprite id value
   lsr
   ldy creatureHorizPositions_R,x   ; get Earwig horizontal position
   bcc .moveEarwigRight
   dey                              ; decrement Earwig horizontal position
   dey
   bpl .setEarwigHorizontalPositionValue
.earwigReachedEdge
   lda creatureAttributes_R,x       ; get Earwig attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   tay
   lda #POISON_MUSHROOM_ZONE
   sta kernelZoneAttributes_01 - 1,y
   lda #0
   sta creatureAttributes_W,x
   jmp CheckToTurnOffRightSoundChannel
    
.moveEarwigRight
   iny                              ; increment Earwig horizontal position
   iny
   cpy #XMAX - 3
   bcs .earwigReachedEdge
.setEarwigHorizontalPositionValue
   tya                              ; move horizontal position to accumulator
   sta creatureHorizPositions_W,x   ; set Earwig horizontal position
.doneMoveEarwig
   jmp MoveNextObject
    
MoveInchworm
   jmp MoveInchwormRoutine
    
MoveDragonfly
   txa                              ; move array index to accumulator
   and #7                           ; 0 <= a <= 7
   sta tmpDragonflyMovementFrame
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   cmp tmpDragonflyMovementFrame
   bne SkipObjectMove               ; branch if not time to move
   tya                              ; move Dragonfly attributes to accumulator
   lsr
   lsr
   lsr
   lsr
   lsr
   tay
   lda creatureHorizPositions_R,x   ; get Dragonfly horizontal position value
   clc
   adc DragonflyHorizontalMovementValues,y
   sta creatureHorizPositions_W,x   ; set Dragonfly horizontal position
   lda creatureAttributes_R,x       ; get Dragonfly attribute value
   clc
   adc #<~DRAGONFLY_HORIZ_OFFSET_MASK;adjust horizontal and vertical position
   sta creatureAttributes_W,x
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   bne .checkToGenerateMushroomForDragonfly
   sta creatureAttributes_W,x
   bit waveState                    ; check current game wave values
   bpl .doneMoveDragonfly           ; branch if NOT_SWARMING
   dec numberActiveSwarmingInsects  ; reduce number of active swarming insects
   jmp MoveNextObject
    
.doneMoveDragonfly
   jmp CheckToTurnOffRightSoundChannel
    
.checkToGenerateMushroomForDragonfly
   jmp CheckToGenerateMushroom
    
MoveMosquito
   tya                              ; move Mosquito attributes to accumulator
   bpl .slowMovingMosquito
   txa                              ; move array index to accumulator
   and #3                           ; 0 <= a <= 3
   sta tmpMosquitoMovementDelay
   lda #3
   bne .checkToMoveMosquito         ; unconditional branch

.slowMovingMosquito
   txa                              ; move array index to accumulator
   and #7                           ; 0 <= a <= 7
   sta tmpMosquitoMovementDelay
   lda #7
.checkToMoveMosquito
   and frameCount
   cmp tmpMosquitoMovementDelay
   bne .doneMoveMosquito
   dey                              ; move Mosquito down
   tya                              ; move Mosquito attributes to accumulator
   sta creatureAttributes_W,x       ; set new Mosquito attribute values
   and #KERNEL_ZONE_MASK            ; keep Mosquito KERNEL_ZONE
   bne .moveMosquitoHorizontally
   sta creatureAttributes_W,x
   bit waveState                    ; check current game wave values
   bpl .checkToTurnOffRightSoundChannel;branch if NOT_SWARMING
   dec numberActiveSwarmingInsects  ; reduce number of active swarming insects
SkipObjectMove
   jmp MoveNextObject

.checkToTurnOffRightSoundChannel
   jmp CheckToTurnOffRightSoundChannel

.moveMosquitoHorizontally
   lda creatureSpriteIds_R,x        ; get Mosquito sprite id value
   tay
   lsr
   lda creatureHorizPositions_R,x
   bcc .moveMosquitoLeft            ; branch if Mosquito moving left
   adc #8 - 1                       ; carry set
   cmp #XMAX - 3
   bcc .setMosquitoHorizontalPosition
.changeMosquitoHorizontalDirection
   tya                              ; move Mosquito sprite id to accumulator
   eor #1
   sta creatureSpriteIds_W,x
   bpl .doneMoveMosquito            ; unconditional branch

.moveMosquitoLeft
   sbc #8 - 1                       ; carry clear
   bmi .changeMosquitoHorizontalDirection
.setMosquitoHorizontalPosition
   sta creatureHorizPositions_W,x
.doneMoveMosquito
   jmp MoveNextObject

MoveFloatingBonusPoints
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   cmp #7
   bne SkipObjectMove
   tya                              ; move object attributes to accumulator
   clc
   adc #1 << 5
   sta creatureAttributes_W,x
   bcc SkipObjectMove
   bit waveState                    ; check current game wave values
   bpl .removeSpiderPointSprite     ; branch if NOT_SWARMING
   lda #0
   sta creatureAttributes_W,x       ; clear object attribute value
   jmp MoveNextObject
    
.removeSpiderPointSprite
   jmp RemoveSpiderPointSprite
    
MoveSpider
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   cmp tmpSpriteIdx
   
   IF COMPILE_REGION = PAL50
   
      beq .checkToChangeSpiderDirections
      
   ELSE
   
      beq SkipObjectMove
      cmp SpiderMoveFrequencyValues,x
      beq SkipObjectMove
      
   ENDIF

   lsr
   lda playerScore                  ; get score thousands value
   bne .moveSpider                  ; branch if score greater than 9,999
   
   IF COMPILE_REGION = PAL50
   
      bcs .checkToChangeSpiderDirections;branch on odd frames
      
   ELSE
   
      bcs SkipObjectMove            ; branch on odd frames
   
   ENDIF
   
.moveSpider
   lda creatureHorizPositions_R,x   ; get Spider horizontal position
   beq TurnOffSpiderSounds          ; branch if Spider reached left edge
   cmp #XMAX - 7
   beq TurnOffSpiderSounds          ; branch if Spider reached right edge
   tya                              ; move Spider attributes to accumulator
   asl                              ; shift OBJECT_HORIZ_DIR to carry
   and #[SPIDER_HORIZ_MOVE_MASK << 1];keep SPIDER_HORIZ_MOVE value
   beq .checkToChangeSpiderDirections;branch if SPIDER_NO_HORIZ_MOVE
   lda #1
   bcs .adjustSpiderHorizontalPosition;branch if Spider moving right
   lda #<-1
.adjustSpiderHorizontalPosition
   clc
   adc creatureHorizPositions_R,x
   sta creatureHorizPositions_W,x
.checkToChangeSpiderDirections

   IF COMPILE_REGION = PAL50
   
      lda creatureFrameCount
      cmp tmpSpriteIdx

   ELSE
   
      lda frameCount                ; get current frame count
      and #7                        ; 0 <= a <= 7
      cmp ChangeSpiderDirectionFrequencyValues,x
   
   ENDIF

   bne .skipSpiderChangingDirections; branch if not time to change direction
   ldy #MAX_SPIDER_KERNEL_ZONE
   lda playerScore                  ; get score thousands value
   cmp #$03
   bcc .setSpiderKernelZoneMaximum  ; branch if less than 30,000
   dey                              ; reduce Spider maxium height by 2
   dey
   cmp #$10
   bcc .setSpiderKernelZoneMaximum  ; branch if score 30,000 <= a < 100,000
   dey                              ; reduce Spider maxium height by 2
   dey
.setSpiderKernelZoneMaximum
   sty tmpSpiderKernelZoneMax
   ldy creatureAttributes_R,x       ; get Spider attribute values
   tya                              ; move Spider attributes to accumulator
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp #1
   beq .setSpiderDirectionToUp      ; branch if Spider in kernel zone 1
   cmp tmpSpiderKernelZoneMax
   bcs .setSpiderDirectionToDown
   lda random
   and SpiderVerticalAdjustmentFrequencyValues,x
   bne .adjustSpiderVerticalPosition
   tya                              ; move Spider attributes to accumulator
   eor #SPIDER_VERT_DIR_MASK        ; flip Spider SPIDER_VERT_DIR value
.determineSpiderHorizontalMovement
   and #<~SPIDER_HORIZ_MOVE_MASK    ; clear SPIDER_HORIZ_MOVE value
   sta tmpSpiderAttributes
   lda random + 1
   and SpiderHorizontalAdjustmentFrequencyValues,x
   beq .setSpiderHorizontalMovementValue
   lda #SPIDER_HORIZ_MOVE
.setSpiderHorizontalMovementValue
   ora tmpSpiderAttributes
   sta creatureAttributes_W,x
   tay                              ; move Spider attributes to y register
.adjustSpiderVerticalPosition
   tya                              ; move Spider attributes to accumulator
   iny                              ; increment Spider kernel zone
   and #SPIDER_VERT_DIR_MASK
   beq .setSpiderVerticalPosition   ; branch if SPIDER_DIR_UP
   dey
   dey
.setSpiderVerticalPosition
   tya
   sta creatureAttributes_W,x
   jmp MoveNextObject
    
.setSpiderDirectionToDown
   tya                              ; move Spider attributes to accumulator
   ora #SPIDER_DIR_DOWN
   bne .determineSpiderHorizontalMovement;unconditional branch
    
.setSpiderDirectionToUp
   tya                              ; move Spider attributes to accumulator
   and #<~SPIDER_DIR_DOWN           ; clear SPIDER_DIR_VALUE
   jmp .determineSpiderHorizontalMovement
    
TurnOffSpiderSounds
   lda rightSoundChannelIndex       ; get right sound channel index value
   cmp #<[SpiderAudioValues - RightSoundChannelValues]
   bcc .doneTurnOffSpiderSounds     ; branch if less than Spider audio value
   cmp #<[MosquitoAudioValues - RightSoundChannelValues]
   bcs .doneTurnOffSpiderSounds     ; branch if greater than Spoder audio value
   lda #0
   sta rightSoundChannelIndex       ; turn off Spider audio sounds
.doneTurnOffSpiderSounds
   jmp RemoveSpiderPointSprite
    
.skipSpiderChangingDirections
   cmp SpiderRemovingMushroomFrequencyValues,x
   beq CheckSpiderForRemovingMushroom
.doneMoveSpider
   jmp MoveNextObject
    
CheckSpiderForRemovingMushroom
   lda creatureAttributes_R,x       ; get Spider attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   sta tmpSpiderKernelZone
   cmp #2
   bcc .doneMoveSpider              ; branch if lower than zone 2
   lda creatureHorizPositions_R,x   ; get Spider horizontal position
   lsr
   lsr                              ; divide value by 4
   tay                              ; move horizontal position to y register
   eor tmpSpiderKernelZone
   lsr                              ; shift D0 to carry
   bcc .determineMushroomBitIndex
   iny                              ; increment horizontal position
.determineMushroomBitIndex
   lda tmpSpiderKernelZone          ; get Spider kernel zone
   cpy #16
   bcc .setMushroomArrayBitIndex
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.setMushroomArrayBitIndex
   tax
   lsr                              ; shift D0 to carry
   tya                              ; get Spider adjusted horizontal position
   and #<~1
   bcs .setMushroomMaskingBitIndex
   adc #<[BANK2_EvenMushroomMaskingBits - BANK2_MushroomMaskingBits - 1]
.setMushroomMaskingBitIndex
   tay
   iny
   cmp #63
   bmi .spiderRemovingMushroom
   ldy #63
.spiderRemovingMushroom
   lda BANK2_MushroomMaskingBits,y  ; get Mushroom masking bit value
   eor #$FF                         ; flip the bits
   tay
   and mushroomArray_R - 2,x        ; remove Mushroom from array
   sta mushroomArray_W - 2,x
   tya
   and leftFlowerArray_R - 2,x      ; remove Flower from array
   sta leftFlowerArray_W - 2,x
   ldx tmpSpriteIdx
   jmp MoveNextObject
    
RemoveSpiderPointSprite
   lda gameWaveValues               ; get current game wave values
   beq .setCreatureSpriteIdToSpider ; branch if first game wave
   lda #ID_BLANK
   cpx #3
   bcc .setCreatureSpriteId
.setCreatureSpriteIdToSpider
   lda #ID_SPIDER
.setCreatureSpriteId
   sta creatureSpriteIds_W,x
   lda #0
   sta creatureAttributes_W,x
   lda random
   and #$0F                         ; 0 <= a <= 15
   ora #1                           ; 1 <= a <= 15
   sta creatureHorizPositions_W,x
   jmp MoveNextObject

MoveInchwormRoutine
   tya                              ; move Inchworm attributes to accumulator
   asl                              ; shift INCHWORM_SPEED to carry
   lda #3                           ; move 1/4 of the time
   bcc .checkMoveInchwormFrame
   lda #1                           ; move 1/2 of the time
.checkMoveInchwormFrame

   IF COMPILE_REGION = PAL50
   
      and creatureFrameCount
      
   ELSE
   
      and frameCount
      
   ENDIF
   
   bne .doneMoveInchworm
   tya                              ; move Inchworm attributes to accumulator
   ldy creatureHorizPositions_R,x   ; get Inchworm horizontal position
   and #INCHWORM_HORIZ_DIR_MASK     ; keep INCHWORM_HORIZ_DIR value
   bne .moveInchwormLeft
   iny
   iny
   cpy #XMAX - 3
   bcc .setInchwormHorizontalPosition
.inchwormReachedEdge
   lda #0
   sta creatureAttributes_W,x
   lda gameState + 1                ; get high game state value
   ora #INIT_INCHWORM_SPAWN_TIMER
   sta gameState + 1                ; reinitialize Inchworm spawn timer
   jmp CheckToTurnOffRightSoundChannel

.moveInchwormLeft
   dey
   dey
   bmi .inchwormReachedEdge
.setInchwormHorizontalPosition
   tya
   sta creatureHorizPositions_W,x
.doneMoveInchworm
   jmp MoveNextObject

MoveBeetleRoutine
   lda #7
   
   IF COMPILE_REGION = PAL50
   
      and creatureFrameCount        ; 0 <= a <= 7
      
   ELSE
   
      and frameCount                ; 0 <= a <= 7
      
  ENDIF
  
   cmp tmpSpriteIdx
   beq .moveBeetle                  ; branch if same value as index
   cmp BeetleMoveFrequencyValues,x
   beq .moveBeetle                  ; branch if time to move Beetle
   jmp MoveNextObject
    
.moveBeetle
   tya                              ; move Beetle attributes to accumulator
   bpl .moveBeetleVertically
   cmp #BEETLE_HORIZ_MOVE | 1
   beq .moveLowestZoneBeetleHorizontally
   lda creatureSpriteIds_R,x        ; get Beetle sprite id value
   lsr
   lda creatureHorizPositions_R,x   ; get Beetle horizontal position
   bcs .moveBeetleLeft              ; branch if Beetle moving left
   adc #2
   cmp #XMAX - 2
   jmp .setBeetleHorizontalPosition
    
.moveBeetleLeft
   sbc #2
   cmp #XMIN - 16
.setBeetleHorizontalPosition
   sta creatureHorizPositions_W,x
   bcc CheckToAddFlowerFromBeetle
   lda #0
   sta creatureAttributes_W,x
   jmp CheckToTurnOffRightSoundChannel
    
.moveLowestZoneBeetleHorizontally
   lda creatureSpriteIds_R,x        ; get Beetle sprite id value
   lsr
   lda creatureHorizPositions_R,x   ; get Beetle horizontal position
   bcs .moveLowestZoneBeetleLeft    ; branch if Beetle moving left
   adc #2
   cmp #111
   sta creatureHorizPositions_W,x
   bcs .setBeetleToMoveUp           ; branch if Bettle greater than pixel 190
   cmp #64
   bcs .determineToSetBeetleToTravelUp;branch if Beetle greater than pixel 143
   bcc .doneMoveBeetle              ; unconditional branch

.moveLowestZoneBeetleLeft
   sbc #2
   cmp #9
   sta creatureHorizPositions_W,x
   bcc .setBeetleToMoveUp           ; branch if Beetle less than pixel 88
   cmp #60
   bcs .doneMoveBeetle              ; branch if Beetle greater than pixel 139
.determineToSetBeetleToTravelUp
   and #2
   bne .doneMoveBeetle
   lda random
   cmp #32
   bcs .doneMoveBeetle
.setBeetleToMoveUp
   lda #BEETLE_NO_HORIZ_MOVE | BEETLE_DIR_UP | 1
   sta creatureAttributes_W,x
.doneMoveBeetle
   jmp MoveNextObject
    
.moveBeetleVertically

   IF COMPILE_REGION = PAL50
   
      lda creatureFrameCount
      lsr                           ; shift D0 to carry
      bcc .doneMoveBeetle           ; branch on even frame count
      lda creatureFrameCount + 1
      lsr                           ; shift D0 to carry
      bcs .doneMoveBeetle          
      
   ELSE
   
      lda frameCount                ; get current frame count
      lsr                           ; shift D0 to carry
      bcc .doneMoveBeetle           ; branch on even frame
      and #4                        ; a = 0 || a = 4
      bne .doneMoveBeetle
   
   ENDIF

   tya                              ; move Beetle attributes to accumulator
   and #BEETLE_VERT_DIR_MASK        ; keep BEETLE_VERT_DIR value
   bne .moveBeetleUp
   tya                              ; move Beetle attributes to accumulator
   sec
   sbc #1                           ; decrement kernel zone (i.e. move Beetle down)
   cmp #1
   bne .setBeetleAttributeValues    ; branch if Beetle not in lowest zone
   lda #BEETLE_HORIZ_MOVE | 1
.setBeetleAttributeValues
   sta creatureAttributes_W,x
   bmi .doneMoveBeetle
   bne CheckToAddFlowerFromBeetle
.moveBeetleUp
   tya                              ; move Beetle attributes to accumulator
   clc
   adc #1                           ; increment kernel zone (i.e. move Beetle up)
   cmp #BEETLE_NO_HORIZ_MOVE | BEETLE_DIR_UP | 8
   bcc .setMovingBeetleAttributeValue
   cmp #BEETLE_NO_HORIZ_MOVE | BEETLE_DIR_UP | 11
   bcs .setBeetleToMoveHorizontally ; branch if Beetle reached highest zone
   ldy #64
   cpy random + 1
   bcc .setMovingBeetleAttributeValue
.setBeetleToMoveHorizontally
   and #<~BEETLE_VERT_DIR_MASK      ; set to clear BEETLE_VERT_DIR value
   ora #BEETLE_HORIZ_MOVE
.setMovingBeetleAttributeValue
   sta creatureAttributes_W,x
CheckToAddFlowerFromBeetle SUBROUTINE
   lda creatureAttributes_R,x       ; get Beetle attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   sta tmpBeetleKernelZone
   lda creatureHorizPositions_R,x   ; get Beetle horizontal position
   lsr                              ; divide by 4
   lsr
   tay
   eor tmpBeetleKernelZone
   lsr                              ; shift D0 to carry
   bcc .determineMushroomBitIndex
   iny
.determineMushroomBitIndex
   lda tmpBeetleKernelZone          ; get Bettle kernel zone
   cpy #16
   bcc .setMushroomArrayBitIndex
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.setMushroomArrayBitIndex
   tax
   lsr
   tya
   and #<~1
   bcs .setMushroomMaskingBitIndex
   adc #<[BANK2_EvenMushroomMaskingBits - BANK2_MushroomMaskingBits] - 1
.setMushroomMaskingBitIndex
   tay
   iny
   cmp #63
   bmi .spawnMushroomToFlower
   ldy #63
.spawnMushroomToFlower
   lda mushroomArray_R - 2,x        ; get Mushroom array value
   and BANK2_MushroomMaskingBits,y  ; keep Mushroom bit value
   ora leftFlowerArray_R - 2,x
   sta leftFlowerArray_W - 2,x
   ldx tmpSpriteIdx
   jmp MoveNextObject

DragonflyHorizontalMovementValues
   .byte 0, 5, 10, 5, 0, -5, -10, -5

SpiderRemovingMushroomFrequencyValues
   .byte 2, 2, 0, 4, 6

ChangeSpiderDirectionFrequencyValues
   .byte 6, 6, 4, 0, 2

BeetleMoveFrequencyValues
   .byte 1, 2, 3, 0, 1

SpiderMoveFrequencyValues
   .byte 3, 4, 5, 6, 7

SpiderHorizontalAdjustmentFrequencyValues
   .byte 1, 2, 4, 8, 16

SpiderVerticalAdjustmentFrequencyValues
   .byte ~81, ~196, ~7, ~138, ~97

MoveBeeRoutine SUBROUTINE
   tya                              ; move Bee attributes to accumulator
   bpl .slowMovingBee               ; branch if BEE_STATE_NORMAL
   txa
   and #1
   sta tmpBeeMovementDelay
   lda #1
   bne .checkToMoveBee              ; unconditional branch
    
.slowMovingBee
   txa
   and #3
   sta tmpBeeMovementDelay
   lda #3
.checkToMoveBee
   and frameCount
   cmp tmpBeeMovementDelay
   bne .doneCheckToGenerateMushroom
   dey                              ; decrement Bee kernel zone
   tya                              ; move Bee attributes to accumulator
   sta creatureAttributes_W,x       ; set Bee new kernel zone
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   bne CheckToGenerateMushroom      ; branch if Bee still active
   sta creatureAttributes_W,x       ; clear Bee attribute values (i.e. a = 0)
   bit waveState                    ; check current game wave values
   bpl .doneMoveBeeRoutine          ; branch if NOT_SWARMING
   dec numberActiveSwarmingInsects  ; reduce number of active swarming insects
   jmp MoveNextObject
    
.doneMoveBeeRoutine
   jmp CheckToTurnOffRightSoundChannel
    
CheckToGenerateMushroom
   cmp #2
   bcc .doneCheckToGenerateMushroom ; branch if below kernel zone 2
   ldy #224
   bit waveState                    ; check current game wave values
   bpl .determineToGenerateMushroom ; branch if NOT_SWARMING
   ldy #32
.determineToGenerateMushroom
   cpy random + 1
   bcc .doneCheckToGenerateMushroom
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   sta tmpInsectKernelZone
   lda creatureHorizPositions_R,x   ; get creature horizontal position
   lsr                              ; divide by 4
   lsr
   tay
   lda tmpInsectKernelZone
   cpy #16
   bcc .setMushroomArrayBitIndex
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.setMushroomArrayBitIndex
   tax
   lsr
   tya
   bcs .setMushroomMaskingBitIndex
   adc #<[BANK2_EvenMushroomMaskingBits - BANK2_MushroomMaskingBits]
.setMushroomMaskingBitIndex
   tay
   lda mushroomArray_R - 2,x        ; get Mushroom array value
   ora BANK2_MushroomMaskingBits,y
   sta mushroomArray_W - 2,x
.doneCheckToGenerateMushroom
   ldx tmpSpriteIdx
   jmp MoveNextObject
    
CheckToTurnOffRightSoundChannel
   ldy creatureSpriteIds_R,x        ; get creature sprite id value
   cpy #ID_SHOOTER_DEATH
   bcs .doneCheckToTurnOffRightSoundChannel
   lda rightSoundChannelIndex       ; get right sound channel index value
   cmp BANK2_RightAudioValueLowerBounds,y
   bcc .doneCheckToTurnOffRightSoundChannel;branch if current sound has priority
   cmp BANK2_RightAudioValueUpperBounds,y
   bcs .doneCheckToTurnOffRightSoundChannel
   lda #0
   sta rightSoundChannelIndex
.doneCheckToTurnOffRightSoundChannel
   jmp MoveNextObject
    
ObjectMoveRoutineTable
   .byte <SkipObjectMove
   .byte <MoveBee
   .byte <MoveBee
   .byte <MoveEarwig
   .byte <MoveEarwig
   .byte <MoveEarwig
   .byte <MoveEarwig
   .byte <MoveSpider
   .byte <MoveSpider
   .byte <MoveSpider
   .byte <MoveMosquito
   .byte <MoveMosquito
   .byte <MoveMosquito
   .byte <MoveMosquito
   .byte <MoveDragonfly
   .byte <MoveDragonfly
   .byte <MoveDragonfly
   .byte <MoveInchworm
   .byte <MoveInchworm
   .byte <MoveInchworm
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <MoveBeetle
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <SkipObjectMove
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
   .byte <MoveFloatingBonusPoints
    
   FILL_BOUNDARY 256, 0

BANK2_RightAudioValueLowerBounds
   .byte <-1
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[BeeAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]

BANK2_RightAudioValueUpperBounds
   .byte 0
   .byte <[BeeAudioValues - RightSoundChannelValues] + 39
   .byte <[BeeAudioValues - RightSoundChannelValues] + 39
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[EarwigAudioValues - RightSoundChannelValues] + 25
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[SpiderAudioValues - RightSoundChannelValues] + 56
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 20
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[DragonflyAudioValues - RightSoundChannelValues] + 31
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[InchwormAudioValues - RightSoundChannelValues] + 35
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8
   .byte <[BeetleAudioValues - RightSoundChannelValues] + 8

BANK2_MushroomMaskingBits
BANK2_OddMushroomMaskingBits
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
BANK2_EvenMushroomMaskingBits
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00

   IF ORIGINAL_ROM
   
      .byte " DAVE STAUGAS LOVES BEATRICE HABLIG "

   ENDIF

   FILL_BOUNDARY 734, 0

BANK2_JumpIntoGraphicsZone_05
   lda BANK0STROBE
   jmp SetupDrawBitmapKernel
    
SwitchBankForNewFrame
   lda BANK3STROBE
   jmp CheckToProcessObjectMovements
    
BANK2_JumpToOverscan
   lda BANK1STROBE
   jmp ScoreKernel
    
BANK2_Start
   lda BANK3STROBE
   jmp BANK3_Start

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data

   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK2"

   .word BANK2_Start
   .word BANK2_Start
   .word BANK2_Start

;===============================================================================
; R O M - C O D E (BANK3)
;===============================================================================

   SEG Bank3
   .org BANK3_BASE
   .rorg BANK3_REORG

FREE_BYTES SET 0

   .ds 256, 0                       ; first page reserved for Superchip RAM

BANK3_Start
   cld
   sei
   ldx #$FF
   txs                              ; set stack to the beginning
   inx                              ; x = 0
   txa
.clearZPLoop
   sta VSYNC,x
   inx
   bne .clearZPLoop
   ldx #$7F
.clearSuperchipRAM
   sta objectHorizPositions_W,x
   dex
   bpl .clearSuperchipRAM
   stx random
   lda #GS_GAME_OVER
   bne .initGameState               ; unconditional branch

SetInitialRemainingLivesValue
   lda #INIT_LIVES - 1
.initGameState
   bit gameState                    ; check current game state
   sta gameState                    ; set game state and initial lives
   lda #0
   sta waveState
SetInitialGameValues
   lda waveState                    ; get current game wave values
   and #<~SWARMING
   sta waveState                    ; clear SWARMING value
   lda gameState + 1                ; get high game state value
   and #SELECT_DEBOUNCE_MASK        ; keep SELECT_DEBOUNCE value
   sta gameState + 1
   lda #0
   bvs .initGameSelectionValues     ; branch if in GAME_SELECTION
   sta playerScore
   sta playerScore + 1
   sta playerScore + 2
.initGameSelectionValues
   sta gameWaveValues
   sta numberOfMillipedeSegments
   sta objectSpawningValues
   sta leftSoundChannelIndex
   sta rightSoundChannelIndex
   sta growingMushroomGardenArrayIndex
   sta displayScanOutControl        ; set to enable scan out
   ldx #10
.setInitialFlowerArrayValues
   sta leftFlowerArray_W,x
   sta rightFlowerArray_W,x
   sta kernelZoneAttributes_01 + 10,x
   dex
   bpl .setInitialFlowerArrayValues
   ldx #11
.setInitialObject0ZoneValues
   sta kernelZoneAttributes_01,x
   dex
   bpl .setInitialObject0ZoneValues
   ldx #[MUSHROOM_ARRAY_SIZE / 2]
.setInitialMushroomPatchValues
   lda InitLeftMushroomPatchValues,x
   sta leftMushroomArray_W,x
   lda InitRightMushroomPatchValues,x
   sta rightMushroomArray_W,x
   dex
   bpl .setInitialMushroomPatchValues
   ldx #4
.setInitDDTValues
   lda BANK3_InitDDTHorizontalPositionValues,x
   sta objectHorizPositions_W,x
   lda InitDDTAttributeValues,x
   sta objectAttributes_W,x
   lda #ID_DDT
   sta spriteIdArray_W,x
   dex
   bne .setInitDDTValues
   lda #1
   sta kernelZoneAdjustment
   lda #COLORS_ORANGE
   sta tmpNormalMushroomColor
   lda #COLORS_SHOOTER_ZONE
   sta shooterZoneBackgroundColor
   lda #>BANK0_SoundRoutines
   sta soundRoutineVector + 1
SetInitInchwormValues
   lda #0
   sta inchwormWaveState
   sta gardenShiftValues            ; clear garden shift value
   lda gameState + 1                ; get high game state value
   ora #INIT_INCHWORM_SPAWN_TIMER
   sta gameState + 1                ; reinitialize Inchworm spawn timer
   ldx #9
   stx objectListEndValue
   lda #<[kernelZoneConflictArray + 5]
   sta conflictArrayStartingIndex   ; set value to end of array
   lda numberOfMillipedeSegments    ; get number of Millipede segments
   bpl .decrementGameWaveValue
   dec gardenShiftValues            ; set to shift garden down
   jmp .setShooterInitialPositionValues
    
.decrementGameWaveValue
   dec gameWaveValues
.setShooterInitialPositionValues
   lda #SHOOTER_START_Y
   sta shooterVertPos
   lda #SHOOTER_START_X
   sta shooterHorizPos
   lda #0
   sta leftSoundChannelIndex
   ldx #MAX_DDT_BOMBS - 1
.setInitialCreatureValues
   sta creatureAttributes_W,x
   dex
   bpl .setInitialCreatureValues
   sta shotVertPos                  ; turn off Shot
   lda gameState                    ; get current game state
   and #<~SPAWN_EXTRA_SPIDER_MASK   ; clear SPAWN_EXTRA_SPIDER value
   sta gameState
ResetGameWaveValues
   lda #0
   sta beetleSpawnTimer
   lda gameState                    ; get current game state
   and #<~SPAWN_HEAD_MASK           ; clear SPAWN_HEAD value
   sta gameState
   and #GAME_SELECTION_MASK
   beq .setNotSelectingGameValues   ; branch if not GS_SELECTING_GAME
   lda #<-1
   sta numberOfMillipedeSegments
   inc gameWaveValues
   jmp SetShooterAndShotKernelValues
    
.setNotSelectingGameValues
   ldx #MAX_MILLIPEDE_SEGMENTS - 1
   stx numberOfMillipedeSegments
   lda gameWaveValues               ; get current game wave values
   clc
   adc #1                           ; increment wave by 1
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   sta gameWaveValues
   beq BuildMillipedeForGameWave    ; branch if game wave rolled over
   cmp #4
   beq SetGameWaveObjectSpawningValues
   lsr                              ; shift D0 to carry
   bcs SetGameWaveObjectSpawningValues;branch on an odd game wave
.alternateSwarmingValue
   lda waveState                    ; get current game wave values
   eor #SWARMING_MASK               ; flip SWARMING value
   sta waveState
   bpl SetGameWaveObjectSpawningValues;branch if NOT_SWARMING
   lda gameState                    ; get current game state
   bmi .reduceGameWaveValues        ; branch if GS_GAME_OVER
   and #SPAWN_EXTRA_SPIDER_MASK     ; keep SPAWN_EXTRA_SPIDER value
   beq .alternateSwarmingValue      ; branch if extra Spider not spawned
.reduceGameWaveValues
   dec gameWaveValues
   ldx #8
   lda #0
.clearCreatureAttributesForStartingSwarm
   sta creatureAttributes_W + 5,x
   dex
   bpl .clearCreatureAttributesForStartingSwarm
   stx numberOfMillipedeSegments
   lda playerScore                  ; get score thousands value
   ldy #MAX_SWARMING_INSECTS_00
   cmp #$04
   bcc .setWaveMaximumSwarmingInsects;branch if score less than 40,000
   ldy #MAX_SWARMING_INSECTS_01
   cmp #$10
   bcc .setWaveMaximumSwarmingInsects;branch if score less than 100,000
   ldy #MAX_SWARMING_INSECTS_02
.setWaveMaximumSwarmingInsects
   sty waveNumberSwarmingInsects
   ldy #0
   ldx #2
.countActiveSwarmingInsects
   lda creatureAttributes_R,x       ; get creature attribute values
   beq .countNextActiveSwarmingInsects;branch if object not present
   lda creatureSpriteIds_R,x        ; get creature sprite id value
   beq .countNextActiveSwarmingInsects;branch if ID_BLANK
   cmp #ID_EARWIG
   bcc .incrementActiveSwarmingInsects;branch if ID_BEE
   cmp #ID_MOSQUITO
   bcc .countNextActiveSwarmingInsects;branch if ID_EARWIG or ID_SPIDER
   cmp #ID_INCHWORM
   bcs .countNextActiveSwarmingInsects;branch if not ID_MOSQUITO or ID_DRAGONFLY
.incrementActiveSwarmingInsects
   iny
.countNextActiveSwarmingInsects
   dex
   bpl .countActiveSwarmingInsects
   sty numberActiveSwarmingInsects
   lda #5
   sta tmpSwarmingInsectSpawningTimer
   lda #<-1
   sta insectSwarmShootTally
   lda #18
   sta objectListEndValue
   jmp SetShooterAndShotKernelValues
    
SetGameWaveObjectSpawningValues
   lda gameWaveValues               ; get current game wave values
   sec
   sbc #1
   and #3                           ; 0 <= a <= 3
   tax
   lda WaveObjectSpawnValues,x
   ora objectSpawningValues
   sta objectSpawningValues
BuildMillipedeForGameWave
   lda gameWaveValues               ; get current game wave values
   ldy #FAST_MILLIPEDE_VALUE
   lsr                              ; shift D0 to carry
   bcc .setMillipedeSpeed           ; branch on an even wave...MILLIPEDE_FAST
   ldx playerScore                  ; get score thousands value
   cpx #$04
   bcs .setMillipedeSpeed           ; MILLIPEDE_FAST if score greater than 39,999
   ldy #SLOW_MILLIPEDE_VALUE
.setMillipedeSpeed
   sty tmpMillipedeSpeed
   lda #MAX_LEVEL
   sec
   sbc gameWaveValues               ; subtract current game wave
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   clc
   adc #3                           ; increment game wave difference by 3
   lsr                              ; divide value by 2 (i.e. 1 <= a <= 9)
   sta tmpMillipedeChainEnd
   lda #MILLIPEDE_START_X
   ldy #MILLIPEDE_BODY_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT | 19
   ldx #0
.buildMillipedeSegment
   cpx tmpMillipedeChainEnd
   bmi .buildMillipedeBodySegment   ; branch if less than Millipede chain end
   lda InitMillipedeHeadHorizPos,x
   sta millipedeHorizPosition,x     ; set Millipede head horizontal position
   lda InitMillipedeHeadState,x
   sta millipedeSegmentState,x      ; set Millipede head state
   lda #MILLIPEDE_FAST
   sta millipedeAttributes_W,x      ; set Millipede head to MILLIPEDE_FAST
   jmp .buildNextMillipedePart
    
InitMillipedeHeadHorizPos
   .byte 64, 47, 77, 14, 108, 31, 93, 2, 124

InitMillipedeHeadState
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT  | 19
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_RIGHT | 18
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT  | 18
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_RIGHT | 18
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT  | 18
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_RIGHT | 18
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT  | 19
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_RIGHT | 19
   .byte MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT  | 19
   
WaveObjectSpawnValues
   .byte 0
   .byte OBJECT_SPAWNING_EARWIG
   .byte $40
   .byte $10
    
.buildMillipedeBodySegment
   clc
   adc #W_MILLIPEDE_HEAD            ; increment by W_MILLIPEDE_HEAD
   sta millipedeHorizPosition,x     ; set position of Millipede body part
   sty millipedeSegmentState,x      ; set initial state of Millipede body part
   bit tmpMillipedeSpeed
   bmi .buildFastMovingMillipede
   lda millipedeAttributes_R,x      ; get Millipede attribute values
   and #<~[MILLIPEDE_SPEED_MASK | MILLIPEDE_POISONED_MASK]
   sta millipedeAttributes_W,x
   jmp .buildNextMillipedePart
    
.buildFastMovingMillipede
   lda #MILLIPEDE_FAST
   sta millipedeAttributes_W,x
.buildNextMillipedePart
   inx
   lda millipedeHorizPosition - 1,x ; get Millipede segment horizontal position
   cpx #MAX_MILLIPEDE_SEGMENTS
   bne .buildMillipedeSegment
   lda #MILLIPEDE_HEAD_SEGMENT | MILLIPEDE_DIR_DOWN | MILLIPEDE_DIR_LEFT | 19
   sta millipedeSegmentState
   lda shotVertPos                  ; get Shot vertical position
   beq .setShotKernelValues         ; branch if Shot not active
   asl                              ; multiply by 2
   adc shotVertPos                  ; multiply by 3 (i.e. [x * 2] + x)
   sec
   sbc #2
.setShotKernelValues
   sta playerShotEnableIndex
   lda shooterVertPos
   sec
   sbc playerShotEnableIndex
   sta kernelShooterState
   lda playerShotEnableIndex
   bne .doneCheckToLaunchPlayerShot
   dec playerShotEnableIndex
   inc kernelShooterState
.doneCheckToLaunchPlayerShot
   lda #MAX_KERNEL_SECTIONS + 1
   sta millipedeBodyKernelZone
   jmp SwitchBanksToSetupGameDisplayKernel
    
NewFrame SUBROUTINE
.waitTime
   lda INTIM
   bmi .waitTime
   lda #START_VERT_SYNC | 1
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; start vertical sync (i.e. D1 = 1)
   lda random + 1
   asl
   eor random + 1
   asl
   asl
   rol random
   rol random + 1
   rol random
   lda playerScore + 1              ; get score hundreds value
   cmp #$50                         ; set carry if score greater than 4,999
   ror                              ; rotate carry to D7
   sta tmpExtraLifeState
   bit gameState                    ; check current game state
   bpl .incrementScore              ; branch if GS_GAME_ACTIVE
   lda #<DonePerformSoundRoutines
   sta soundRoutineVector
   lda #0
   sta tmpThousandsPoints           ; clear points for GS_GAME_OVER
   sta tmpHundredsPoints
   sta tmpOnesPoints
.incrementScore
   sed
   lda tmpOnesPoints                ; get points ones value
   sta WSYNC                        ; wait for next scan line
   clc
   adc playerScore + 2              ; increment score ones value
   sta playerScore + 2              ; set score ones value
   lda tmpHundredsPoints            ; get points hundreds value
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   lda tmpThousandsPoints           ; get points thousands value
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   lda playerScore + 1              ; get score hundreds value
   cld
   cmp #$50                         ; set carry if score greater than 4,999
   ror                              ; rotate carry to D7
   eor tmpExtraLifeState
   sec                              ; set to not increment number of lives
   bpl .checkToIncrementRemainingLives;branch if not reached extra life score
   lda gameState + 1                ; get high game state value
   clc
   adc #1 << 4
   sta gameState + 1
   and #3 << 4
   cmp #3 << 4
   sec                              ; set to not increment number of lives
   bne .checkToIncrementRemainingLives
   lda gameState + 1                ; get high game state value
   and #$CF
   sta gameState + 1
   clc                              ; set to increment number of lives
.checkToIncrementRemainingLives
   sta WSYNC                        ; wait for next scan line
   bcs .setPoisonedMushroomColorValue
   lda #<[ExtraLifeAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
   lda gameState                    ; get current game state values
   and #LIVES_MASK                  ; keep remaining lives
   cmp #MAX_LIVES
   beq .setPoisonedMushroomColorValue
   inc gameState                    ; increment number of lives
.setPoisonedMushroomColorValue
   lda frameCount                   ; get current frame count
   asl
   asl
   ora #COLORS_POISONED_MUSHROOM_LUMINANCE;set luminance value
   sta poisonedMushroomColor
   bit gameState                    ; check current game state
   bpl .endVerticalSync             ; branch if GS_GAME_ACTIVE
   lda waveState                    ; get current game wave values
   ora #SHOW_LITERALS
   sta waveState                    ; set to SHOW_LITERALS
   lda frameCount + 1               ; get frame count high byte value
   and #1
   beq .endVerticalSync
   lda waveState                    ; get current game wave values
   and #<~SHOW_LITERALS
   sta waveState                    ; clear SHOW_LITERALS value
   lda gameState + 1                ; get high game state values
   and #<~SHOW_GAME_OVER_MASK       ; clear SHOW_GAME_OVER value
   sta gameState + 1
.endVerticalSync
   lda #STOP_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC
   lda #VBLANK_TIME
   sta TIM64T
   bit inchwormWaveState            ; check Inchworm wave state
   bvc .modifyCreatureFrameCount    ; branch if INSECT_SPEED_NORMAL
   lda inchwormWaveState            ; get Inchworm wave state
   eor #PLAYER_MOVEMENT_MASK        ; flip PLAYER_MOVEMENT_MASK value
   sta inchwormWaveState
   bpl .modifyCreatureFrameCount    ; branch if PLAYER_MOVEMENT_NORMAL
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs .checkResetAndSelectSwitches ; branch on an odd frame
   inc inchwormWaveState
   bne .checkResetAndSelectSwitches ; unconditional branch

.modifyCreatureFrameCount
   IF COMPILE_REGION = PAL50
   
      dec creatureFrameCount
      bpl .incrementFrameCount           
      inc creatureFrameCount + 1
      lda #6
      sta creatureFrameCount
    
   ENDIF
   
.incrementFrameCount
   inc frameCount                   ; increment frame count
   bne .checkResetAndSelectSwitches
   lda objectSpawningValues
   ora #OBJECT_SPAWNING_MOSQUITO
   sta objectSpawningValues
   inc frameCount + 1               ; increment frame count high byte value
   bne .checkResetAndSelectSwitches
   bit gameState                    ; check current game state
   bpl .checkResetAndSelectSwitches ; branch if GS_GAME_ACTIVE
   lda #DISABLE_TIA
   sta displayScanOutControl        ; set to disable scan out
.checkResetAndSelectSwitches
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForSelectPressed       ; branch if RESET not pressed
   bit gameState + 1                ; check high game state value
   lsr                              ; shift SELECT value to carry
   bvs .checkToInitialSetStartingScoreMaximum;branch if SELECT_SWITCH_HELD
   lda #SELECT_SWITCH_HELD
   sta gameState + 1
   bit gameState                    ; check current game state
   bvs .setInitialRemainingLivesValue;branch if GS_SELECTING_GAME
   jsr ResetGame
   bvs .setInitialRemainingLivesValue;branch if GS_SELECTING_GAME
   lda gameState                    ; get current game state
   and #<~GS_SELECTING_GAME         ; clear GS_SELECTING_GAME value
   sta gameState
.setInitialRemainingLivesValue
   jmp SetInitialRemainingLivesValue
    
.checkForSelectPressed
   lsr                              ; shift SELECT value to carry
   lda gameState + 1                ; get high game state value
   and #<~SELECT_SWITCH_HELD        ; clear SELECT_SWITCH_HELD value
   sta gameState + 1
.checkToInitialSetStartingScoreMaximum
   bcs .checkToSelectStartingScore  ; branch if SELECT not pressed
   lda gameState                    ; get current game state
   ora #GS_SELECTING_GAME
   cmp gameState
   sta gameState
   beq .checkToSelectStartingScore
   and #<~[GAME_ACTIVE_MASK | LIVES_MASK];clear LIVES and GAME_OVER state
   sta gameState
   lda waveState                    ; get current game wave values
   ora #SHOW_LITERALS
   sta waveState                    ; set to SHOW_LITERALS
   lda playerScore                  ; get score thousands value
   cmp #$06
   bcs .setHigherStartingScoreMaximum;branch if greater than 59,999
   lda #$03
   sta tmpMaxStartingScoreThousandsValue_W
   lda #$00
   sta tmpMaxStartingScoreHundredsValue_W
   beq .doneSetInitialStartingScore ; unconditional branch

.setHigherStartingScoreMaximum
   lda playerScore + 1              ; get score hundreds value
   sec
   sed
   sbc #$50                         ; subtract hundreds value by 50
   sta tmpMaxStartingScoreHundredsValue_W
   lda playerScore                  ; get score thousands value
   sbc #$01
   sta tmpMaxStartingScoreThousandsValue_W
   cld
.doneSetInitialStartingScore
   clv                              ; clear overflow for not selecting game
   jmp SetInitialGameValues
    
.checkToSelectStartingScore
   bit gameState                    ; check current game state
   bvs SelectStartingScore          ; branch if GS_SELECTING_GAME
   bpl .animateDDTClouds            ; branch if GS_GAME_ACTIVE
   bit gameState + 1                ; check high game state value
   bpl .checkActionButtonToResetGame; branch if not GS_SHOW_GAME_OVER
.animateDDTClouds
   jmp AnimateDDTClouds
    
.checkActionButtonToResetGame
   bit INPT4                        ; check player's fire button
   bmi .actionButtonNotPressed      ; branch if fire button not pressed
   lda waveState                    ; get current game wave values
   and #<~ACTION_BUTTON_DEBOUNCE    ; clear ACTION_BUTTON_DEBOUNCE value
   cmp waveState
   sta waveState
   beq AnimateDDTClouds
   jsr ResetGame
   jmp SetInitialGameValues
    
SelectStartingScore
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   bne .doneSelectStartingScore
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip bit values
   and #<~[MOVE_DOWN & MOVE_UP]     ; keep vertical motion values
   beq .doneSelectStartingScore     ; branch if no joystick vertical movement
   cmp #<~MOVE_UP
   sed
   bne .decreaseStartingScoreValue  ; branch if not increasing starting score
   lda playerScore                  ; get score thousands value
   cmp #$30
   bcs .doneSelectStartingScore     ; branch if reached maximum starting score
   lda #$50
   clc
   adc playerScore + 1              ; increment starting hundreds points
   sta playerScore + 1
   lda #$01
   adc playerScore                  ; increment starting thousands points
   sta playerScore
   lda tmpMaxStartingScoreHundredsValue_R
   sec
   sbc playerScore + 1
   lda tmpMaxStartingScoreThousandsValue_R
   sbc playerScore                  ; subtract score thousands value
   bcc .decreaseStartingScoreHundredsValue
   lda #<[StartingScoreSelectionAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
   bcs .doneSelectStartingScore     ; unconditional branch

.decreaseStartingScoreValue
   lda playerScore + 1              ; get score hundreds value
   ora playerScore                  ; combine with score thousands value
   beq .doneSelectStartingScore
   lda #<[StartingScoreSelectionAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
.decreaseStartingScoreHundredsValue
   lda playerScore + 1              ; get score hundreds value
   sec
   sbc #$50
   sta playerScore + 1
   lda playerScore                  ; get score thousands value
   sbc #$01
   sta playerScore
.doneSelectStartingScore
   cld
   bit INPT4                        ; check player's fire button
   bmi .actionButtonNotPressed      ; branch if fire button not pressed
   lda waveState                    ; get current game wave values
   and #<~ACTION_BUTTON_DEBOUNCE    ; clear ACTION_BUTTON_DEBOUNCE value
   cmp waveState
   sta waveState
   beq AnimateDDTClouds
   jmp SetInitialRemainingLivesValue
    
.actionButtonNotPressed
   lda waveState                    ; get current game wave values
   ora #ACTION_BUTTON_RELEASED
   sta waveState
AnimateDDTClouds
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs .doneAnimateDDTClouds        ; branch on odd frame
   and #3                           ; 0 <= a <= 3
   tax
   inx                              ; 1 <= a <= 4
   lda #ID_DDT
   cmp spriteIdArray_R,x
   bcs .doneAnimateDDTClouds        ; branch if not ID_DDT_CLOUD
   lda frameCount                   ; get current frame count
   and #8
   beq .incrementDDTCloudAnimationValues
   lda objectAttributes_R,x         ; get DDT Cloud attribute values
   beq .setDDTCloudSpriteId         ; branch if object not present
   lsr
   lsr
   lsr
   lsr
   ora #1
   bne .determineDDTCloudSprite     ; unconditional branch
    
.incrementDDTCloudAnimationValues
   lda objectAttributes_R,x         ; get DDT Cloud attribute values
   beq .setDDTCloudSpriteId         ; branch if object not present
   adc #1 << 5
   bcc .setDDTCloudAnimationValue
   lda #0
.setDDTCloudAnimationValue
   sta objectAttributes_W,x         ; set DDT Cloud animation values
   lsr
   lsr
   lsr
   lsr
   and #<~1
.determineDDTCloudSprite
   tay
   lda DDTCloudAnimationSpriteValues,y
.setDDTCloudSpriteId
   sta spriteIdArray_W,x
.doneAnimateDDTClouds
   lda inchwormWaveState            ; get Inchworm wave state
   bmi .checkToReduceHaltMovementTimer;branch if PLAYER_MOVEMENT_HALT
.checkToIncrementSwarmingWave
   jmp CheckToIncrementSwarmingWave
    
.checkToReduceHaltMovementTimer
   and #INSECT_SPEED_MASK           ; keep OBJECT_SPEED value
   bne .checkToIncrementSwarmingWave; branch if INSECT_SPEED_SLOW
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcc .checkToDecrementRemainingLives;branch on even frames
   jmp SetShooterAndShotKernelValues
    
.checkToDecrementRemainingLives
   dec inchwormWaveState            ; decrement halt movement timer
   bmi PerformShooterDeathAnimation ; branch if PLAYER_MOVEMENT_HALT
   inc waveTransitionTimer
   bit gameState                    ; check current game state
   bmi .setInitInchwormValues       ; branch if GS_GAME_OVER
   dec gameState                    ; reduce number of remaining lives
   lda gameState                    ; get current game state
   and #LIVES_MASK                  ; keep REMAINING_LIVES
   cmp #MAX_LIVES
   bne .setInitInchwormValues       ; branch if not reached
   lda #GS_GAME_OVER
   sta gameState
   sta gameState + 1                ; set to GS_SHOW_GAME_OVER
   
   IF COMPILE_REGION = PAL50
   
      lda #154
      
   ENDIF
   
   sta frameCount
   lda #0
   sta gardenShiftValues            ; clear garden shift value
   sta frameCount + 1               ; reset frame count high byte value
.setInitInchwormValues
   jmp SetInitInchwormValues
    
PerformShooterDeathAnimation
   ldx shotMushroomIndex
   lda inchwormWaveState            ; get Inchworm wave state
   cmp #PLAYER_MOVEMENT_HALT | 31
   bne .alternateShooterZoneBackgroundColor
   lda #<[ShooterMeltingAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
   cpx #10
   bcc .initShooterDeathSprite
   lda objectAttributes_R,x
   sta creatureAttributes_W
   ldx #5
   stx shotMushroomIndex
.initShooterDeathSprite
   lda #ID_SHOOTER_DEATH
   sta spriteIdArray_W,x
   lda shooterHorizPos
   sec
   sbc #2
   bcs .setShooterDeathKernelPositions
   sec                              ; set carry to alternate Shooter zone colors
   lda #0
.setShooterDeathKernelPositions
   sta objectHorizPositions_W,x
   lda #$40
   sta shooterVertPos
   lda #$9F
.alternateShooterZoneBackgroundColor
   bcc .animateShooterDeath
   and #1
   tax
   lda ShooterZoneBackgroundColorValues,x
   sta shooterZoneBackgroundColor
   jmp SetShooterAndShotKernelValues
    
.animateShooterDeath
   lsr
   lsr
   lsr
   and #3                           ; 0 <= a <= 3
   tay
   lda ShooterDeathAnimationValues,y
   sta spriteIdArray_W,x
   lda inchwormWaveState            ; get Inchworm wave state
   cmp #PLAYER_MOVEMENT_HALT | 2
   beq StartWaveMushroomTally
   bcs .setShooterAndShotKernelValues
   bcc CheckToSetMushroomTallySparkSprite;unconditional branch

StartWaveMushroomTally
   lda kernelZoneAdjustment         ; get kernel zone adjustment
   asl                              ; multiply value by 2
   clc
   adc #2                           ; 2a + 2
   sta mushroomTallyGardenArrayIndex
   lda #0
   sta mushroomTallyGardenIndex     ; clear Mushroom garden tally index
   sta tmpMushroomTallyFrameDelay   ; clear Mushroom tally frame delay
   sta tmpRemainingMushroomPointValue;clear remaning Mushroom point value
   sta shotVertPos                  ; turn off shot
   ldx objectListEndValue
   lda #0
.clearCreaturesFromPlayfield
   sta objectAttributes_W,x
   dex
   cpx #<[creatureAttributes_W - objectAttributes_W]
   bcs .clearCreaturesFromPlayfield
   ldx #<[creatureAttributes_W - objectAttributes_W]
   stx objectListEndValue
   ldx #255 - 256
   lda waveTransitionTimer
   bpl .setWaveTransactionTimerValue
   ldx #254 - 256
.setWaveTransactionTimerValue
   stx waveTransitionTimer
   jmp SetShooterAndShotKernelValues
    
CheckToSetMushroomTallySparkSprite
   inc inchwormWaveState            ; increment halt movement timer
   dec tmpMushroomTallyFrameDelay
   bmi .startTallyMushroomsAndFlowers
   lda #ID_SPARK + 1
   sta sparkSpriteId_W
   jmp SetShooterAndShotKernelValues

.startTallyMushroomsAndFlowers
   lda #6
   sta tmpMushroomTallyIndex
   lda #MUSHROOM_TALLY_GROUP_VALUE - 1
   sta tmpMushroomTallyGroupCount
   lda kernelZoneAdjustment         ; get kernel zone adjustment
   lsr                              ; shift zone adjustment to carry
   ror                              ; shift zone adjustment to D7
   sta tmpKernelZoneAdjustment
.tallyMushroomsAndFlowersLoop
   dec tmpMushroomTallyIndex
   bmi .setShooterAndShotKernelValues
   ldy mushroomTallyGardenIndex     ; get Mushroom tally index
   cpy #32
   bcc .checkForMushroomPresenceForTally;branch if tallying Mushrooms
   bne .allMushroomsTallied         ; branch if done tallying Mushrooms
   ldx #16
   lda gameState                    ; get current game state
   bpl .determineMushroomTallyFrameDelayValue;branch if GS_GAME_ACTIVE
   inc gameWaveValues               ; increment current game wave value
.determineMushroomTallyFrameDelayValue
   and #LIVES_MASK                  ; keep REMAINING_LIVES
   bne .setMushroomTallyFrameDelayValue;branch if lives remaining
   ldx #0
.setMushroomTallyFrameDelayValue
   stx tmpMushroomTallyFrameDelay
   lda #0
   sta sparkAttributes_W            ; clear Spark attribute values
   inc mushroomTallyGardenIndex
.setShooterAndShotKernelValues
   jmp SetShooterAndShotKernelValues
    
.allMushroomsTallied
   dec inchwormWaveState            ; decrement halt movement timer
   jmp SetShooterAndShotKernelValues
    
.checkForMushroomPresenceForTally
   tya                              ; move Mushroom tally index to accumulator
   lsr                              ; shift D0 to carry
   lda BANK3_OddMushroomMaskingBits,y
   bcs .setMushroomTallyMaskingBit
   lda BANK3_EvenMushroomMaskingBits,y
.setMushroomTallyMaskingBit
   sta tmpMushroomMaskingBits
   ldx mushroomTallyGardenArrayIndex
   txa
   cpy #16
   bcc .determineMushroomTallyIndexValues;branch if processing left Mushrooms
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.determineMushroomTallyIndexValues
   tay
   lda mushroomTallyGardenIndex
   lsr                              ; shift D0 to carry
   bcc .checkForEvenMushroomPresenceForTally
.checkForOddMushroomPresenceForTally
   lda mushroomArray_R - 2,y        ; get Mushroom array value
   and tmpMushroomMaskingBits       ; isolate Mushroom bit
   bne .checkToTallyOddFlowers      ; branch if Mushroom present
.nextOddMushroomTally
   dex
   dex
   dey
   dey
   cpx #3
   bcs .checkForOddMushroomPresenceForTally
   inx
   bit tmpKernelZoneAdjustment      ; check kernel zone adjustment value
   bpl .setNextMushroomTallyIndex
   inx
   inx
.setNextMushroomTallyIndex
   stx mushroomTallyGardenArrayIndex
   inc mushroomTallyGardenIndex
   jmp .tallyMushroomsAndFlowersLoop
    
.checkForEvenMushroomPresenceForTally
   lda mushroomArray_R - 2,y        ; get Mushroom array value
   and tmpMushroomMaskingBits       ; isolate Mushroom bit
   bne .checkToTallyEvenFlowers     ; branch if Mushroom present
.nextEvenMushroomTally
   inx
   inx
   iny
   iny
   cpx #MAX_KERNEL_SECTIONS
   bcc .checkForEvenMushroomPresenceForTally
   dex
   bit tmpKernelZoneAdjustment      ; check kernel zone adjustment value
   bmi .setNextMushroomTallyIndex
   dex
   dex
   bcs .setNextMushroomTallyIndex

.checkToTallyOddFlowers
   cpy #<[millipedeAttributes_W - leftFlowerArray_W] + 2
   bcc .removeTallyOddFlowerBit     ; branch if within left Flower index range
   cpy #<[rightFlowerArray_W - leftFlowerArray_W] + 2
   bcc .clearOddPoisonMushroomZoneTally;branch if not in right Flower index range
   cpy #<[mushroomArray_W - leftFlowerArray_W] + 2
   bcs .clearOddPoisonMushroomZoneTally;branch if not in Flower index range
.removeTallyOddFlowerBit
   eor #$FF                         ; flip Mushroom bit value
   and leftFlowerArray_R - 2,y      ; remove Flower bit value
   cmp leftFlowerArray_R - 2,y
   sta leftFlowerArray_W - 2,y      ; set Flower bit value
   bne .decrementKernelZoneForMushroomTally;branch if Flower present
.clearOddPoisonMushroomZoneTally
   lda #NORMAL_MUSHROOM_ZONE | ID_BLANK
   sta kernelZoneAttributes_01 - 1,x
   dec tmpMushroomTallyGroupCount   ; decrement Mushroom tally group count
   bpl .nextOddMushroomTally
.decrementKernelZoneForMushroomTally
   txa                              ; move kernel zone value to accumulator
   tay                              ; move kernel zone value to y register
   lda mushroomTallyGardenIndex
   dex
   dex
   cpx #3
   bcs .determineSparkHorizontalPosition
   inx
   bit tmpKernelZoneAdjustment      ; check kernel zone adjustment value
   bpl .nextOddMushroomTallyGardenIndex
   inx
   inx
.nextOddMushroomTallyGardenIndex
   inc mushroomTallyGardenIndex
   bne .determineSparkHorizontalPosition;unconditional branch

.checkToTallyEvenFlowers
   cpy #<[millipedeAttributes_W - leftFlowerArray_W] + 2
   bcc .removeTallyEvenFlowerBit    ; branch if within left Flower index range
   cpy #<[rightFlowerArray_W - leftFlowerArray_W] + 2
   bcc .clearEvenPoisonMushroomZoneTally;branch if not in right Flower index range
   cpy #<[mushroomArray_W - leftFlowerArray_W] + 2
   bcs .clearEvenPoisonMushroomZoneTally;branch if not in Flower index range
.removeTallyEvenFlowerBit
   eor #$FF                         ; flip Mushroom bit value
   and leftFlowerArray_R - 2,y      ; remove Flower bit value
   cmp leftFlowerArray_R - 2,y
   sta leftFlowerArray_W - 2,y      ; set Flower bit value
   bne .incrementKernelZoneForMushroomTally;branch if Flower present
.clearEvenPoisonMushroomZoneTally
   lda #NORMAL_MUSHROOM_ZONE | ID_BLANK
   sta kernelZoneAttributes_01 - 1,x
   dec tmpMushroomTallyGroupCount   ; decrement Mushroom tally group count
   bpl .nextEvenMushroomTally
.incrementKernelZoneForMushroomTally
   txa                              ; move kernel zone value to accumulator
   tay                              ; move kernel zone value to y register
   lda mushroomTallyGardenIndex
   inx
   inx
   cpx #MAX_KERNEL_SECTIONS
   bcc .determineSparkHorizontalPosition
   dex
   bit tmpKernelZoneAdjustment      ; check kernel zone adjustment value
   bmi .nextEvenMushroomTallyGardenIndex
   dex
   dex
.nextEvenMushroomTallyGardenIndex
   inc mushroomTallyGardenIndex
.determineSparkHorizontalPosition
   stx mushroomTallyGardenArrayIndex
   asl
   asl
   beq .scorePointsForRemainingMushrooms
   sec
   sbc #2
.scorePointsForRemainingMushrooms
   sta creatureHorizPositions_W     ; set ID_SPARK horizontal position
   lda #ID_SPARK
   sta sparkSpriteId_W              ; set sprite to ID_SPARK
   tya                              ; move kernel zone value to accumulator
   sec
   sbc kernelZoneAdjustment         ; subtract kernel zone adjustment
   sta sparkAttributes_W            ; set ID_SPARK kernel zone
   lda #POINTS_REMAINING_MUSHROOMS
   sta tmpRemainingMushroomPointValue
   lda #<[MushroomTallyAudioValues - LeftSoundChannelValues]
   sta leftSoundChannelIndex
   lda #1
   sta tmpMushroomTallyFrameDelay
   jmp SetShooterAndShotKernelValues
    
ResetGame
   lda gameState                    ; get current game state
   ora #GS_SELECTING_GAME
   and #<~[GAME_ACTIVE_MASK | LIVES_MASK];clear LIVES and GAME_OVER state
   sta gameState
   lda waveState                    ; get current game wave values
   ora #SHOW_LITERALS
   sta waveState                    ; set to SHOW_LITERALS
   lda #$03
   sta tmpMaxStartingScoreThousandsValue_W
   lda #$00
   sta tmpMaxStartingScoreHundredsValue_W
   lda playerScore                  ; get score thousands value
   bne DetermineStartingScoreValue
   clv                              ; clear overflow for not selecting game
   rts
    
DetermineStartingScoreValue
   sed
   cmp #$06
   bcc .setStartingScoreTo30000     ; branch if score less than 60,000
   cmp #$31
   bcc .setStartingScoreDetermination;branch if score less than 310,000
   bne .setStartingScoreTo300000
   lda playerScore + 1              ; get score hundreds value
   cmp #$50
   bcc .setStartingScoreDetermination
.setStartingScoreTo300000
   lda #$30
   bne .setStartingScoreThousandsValue;unconditional branch

.setStartingScoreTo30000
   lda #$03
.setStartingScoreThousandsValue
   sta playerScore                  ; set starting score thousands value
   lda #$00
   sta playerScore + 1              ; set starting score hundreds value
.setStartingScoreOnesValue
   lda #$00
   sta playerScore + 2              ; set starting score ones value
   lda playerScore                  ; get score thousands value
   sta tmpMaxStartingScoreThousandsValue_W
   lda playerScore + 1              ; get starting score hundreds value
   sta tmpMaxStartingScoreHundredsValue_W
   cld
   bit gameState                    ; check current game state
   rts
    
.setStartingScoreDetermination
   lda playerScore + 1              ; get score hundreds value
   sta tmpHundredsValueHolder
   lda playerScore                  ; get score thousands value
   sec
   sbc #$03                         ; subtract score by 30,000
   sta tmpScoreThousandsValue
   lda #$04
   sta playerScore                  ; set starting score thousands value
   lda #$50
   sta playerScore + 1              ; set starting score hundreds value
.determineStartingScoreValue
   lda tmpHundredsValueHolder       ; get score hundreds value
   sec
   sbc playerScore + 1
   lda tmpScoreThousandsValue       ; get score thousands value
   sbc playerScore
   bcc .setStartingScoreOnesValue
   lda playerScore + 1              ; get score hundreds value
   clc
   adc #$50                         ; increment by 5,000
   sta playerScore + 1
   lda playerScore                  ; get score thousands value
   adc #$01                         ; increment by 10,000
   sta playerScore
   jmp .determineStartingScoreValue
    
ShooterDeathAnimationValues
   .byte ID_SHOOTER_DEATH + 3, ID_SHOOTER_DEATH + 2
   .byte ID_SHOOTER_DEATH + 1, ID_SHOOTER_DEATH

ShooterZoneBackgroundColorValues
   .byte COLORS_SHOOTER_ZONE_FLASH, COLORS_SHOOTER_ZONE
    
CheckToIncrementSwarmingWave
   lda numberOfMillipedeSegments    ; get number of Millipede segments
   bpl CheckToGrowMushroomGarden
   bit gameState                    ; check current game state
   bvs CheckToGrowMushroomGarden    ; branch if GS_SELECTING_GAME
   lda waveState                    ; get current game wave values
   bpl CheckToSpawnWaveTransitionDragonfly;branch if NOT_SWARMING
   lda numberActiveSwarmingInsects  ; get number of active swarming insects
   ora waveNumberSwarmingInsects    ; combine with number of insects for wave
   bne CheckToGrowMushroomGarden    ; branch if insects swarming
   lda rightSoundChannelIndex       ; get right sound channel index value
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .incrementSwarmingWave
   lda #0
   sta rightSoundChannelIndex       ; reset right sound channel value
.incrementSwarmingWave
   lda waveState                    ; get current game wave values
   clc
   adc #1 << 2
   and #SWARMING_WAVE_MASK          ; keep SWARMING_WAVE value
   sta tmpSwarmingWaveValue
   lda waveState                    ; get current game wave values
   and #<~SWARMING_WAVE_MASK        ; clear SWARMING_WAVE value
   ora tmpSwarmingWaveValue
   sta waveState
   lda gameState                    ; get current game state
   and #<~SPAWN_EXTRA_SPIDER_MASK   ; clear SPAWN_EXTRA_SPIDER value
   sta gameState
   jmp .shiftGardenDown
    
CheckToSpawnWaveTransitionDragonfly
   lda waveTransitionTimer
   cmp #208 - 256
   bcs .incrementWaveTransitionTimer
   lda dragonflyAttributes_R        ; get Dragonfly attribute value
   bne .incrementWaveTransitionTimer; branch if Dragonfly present
   lda rightSoundChannelIndex       ; get right sound channel index value
   beq .setToPlayDragonflySounds    ; branch if right sound not active
   cmp #<[EarwigAudioValues - RightSoundChannelValues]
   bcc .spawnDragonfly
.setToPlayDragonflySounds
   lda #<[DragonflyAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
.spawnDragonfly
   lda #ID_DRAGONFLY
   sta dragonflySpriteId_W
   lda random
   and #$7C                         ; a = 0 || 4 <= a <= 124
   sta dragonflyHorizPosition_W     ; set Dragonfly horizontal position value
   cmp #103                         ; move Dragonfly left of greater than 102
   lda #[(MAX_KERNEL_SECTIONS - 1) << 1]
   ror                              ; shift carry to D7
   sta dragonflyAttributes_W        ; set Dragonfly attribute value
.incrementWaveTransitionTimer
   inc waveTransitionTimer
   bne CheckToGrowMushroomGarden
.shiftGardenDown
   dec gardenShiftValues            ; set to shift garden down
   jmp ResetGameWaveValues
    
CheckToGrowMushroomGarden
   ldy #0
   lda growingMushroomGardenArrayIndex
   beq .doneCheckToGrowMushroomGarden;branch if not growing Mushroom garden
   bpl .setMushroomXORValue
   ldy #$FF
.setMushroomXORValue
   sty tmpMushroomXOR
   ldy growingMushroomGardenIndex
   cpy #16
   bcc .setGardenIndexValue         ; branch if processing left Mushrooms
   adc #<[rightMushroomArray_W - leftMushroomArray_W] - 1
.setGardenIndexValue
   and #$7F                         ; mask off D7 value (i.e. 0 <= a <= 127)
   tax
   tya                              ; move growing Mushroom index to accumulator
   lsr                              ; shift D0 to carry
   lda BANK3_EvenMushroomMaskingBits,y
   bcc .setMushroomMaskingBitValue  ; branch if even Mushroom masking
   dex
   lda BANK3_OddMushroomMaskingBits,y
.setMushroomMaskingBitValue
   sta tmpMushroomMaskingBitValue
   cpx #<[millipedeAttributes_W - leftFlowerArray_W] + 2
   bcc .growFlowerAreaMushroomGarden; branch if within left Flower index range
   cpx #<[rightFlowerArray_W - leftFlowerArray_W] + 2
   bcc .growMushroomAreaMushroomGarden;branch if not in right Flower index range
   cpx #<[mushroomArray_W - leftFlowerArray_W] + 2
   bcs .growMushroomAreaMushroomGarden;branch if not in Flower index range
.growFlowerAreaMushroomGarden
   lda tmpMushroomMaskingBitValue
   and leftFlowerArray_R - 2,x      ; mask with left Flower value
   bne .setToFlipGrowingGardenMushroomBits;branch if Flower bit available
   lda tmpMushroomXOR
   eor mushroomArray_R - 4,x
   and tmpMushroomMaskingBitValue
   sta tmpIsolatedMushroomBitValue
   eor mushroomArray_R - 2,x
   sta mushroomArray_W - 2,x
   eor tmpIsolatedMushroomBitValue
   and tmpMushroomMaskingBitValue
   bne .setToFlipGrowingGardenMushroomBits
   beq .setNotToFlipGrowingGardenMushroomBits;unconditional branch
    
.doneCheckToGrowMushroomGarden
   jmp CheckToMoveShooter
    
.growMushroomAreaMushroomGarden
   lda tmpMushroomXOR
   eor mushroomArray_R - 4,x
   and tmpMushroomMaskingBitValue
   sta tmpIsolatedMushroomBitValue
   eor mushroomArray_R - 2,x
   sta mushroomArray_W - 2,x
   eor tmpIsolatedMushroomBitValue
   and tmpMushroomMaskingBitValue
   beq .setNotToFlipGrowingGardenMushroomBits
.setToFlipGrowingGardenMushroomBits
   lda growingMushroomGardenArrayIndex
   ora #1 << 7
   bmi .adjustGrowingMushroomGardenArrayIndex;unconditional branch

.setNotToFlipGrowingGardenMushroomBits
   lda growingMushroomGardenArrayIndex
   and #$7F
.adjustGrowingMushroomGardenArrayIndex
   sec
   sbc #2
   sta growingMushroomGardenArrayIndex
   and #$7F
   cmp #6
   bne CheckToMoveShooter
   lda #<[rightMushroomArray_W - leftMushroomArray_W]
   inc growingMushroomGardenIndex
   ldy growingMushroomGardenIndex
   cpy #<[BANK3_EvenMushroomMaskingBits - BANK3_MushroomMaskingBits]
   bcc .setGrowingMushroomGardenArrayIndex
   lda #0
.setGrowingMushroomGardenArrayIndex
   sta growingMushroomGardenArrayIndex
CheckToMoveShooter
   bit gameState                    ; check current game state
   bvc .checkToMoveShooter          ; branch if not selecting game
   jmp SetShooterAndShotKernelValues
    
.checkToMoveShooter
   bpl MoveShooterForActiveGame     ; branch if not GS_SHOW_GAME_OVER
   jmp MoveShooterForDemoMode
    
MoveShooterForActiveGame
   lda inchwormWaveState            ; get Inchworm wave state
   asl
   bmi .moveShooterForActiveGame    ; branch if INSECT_SPEED_SLOW
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
.moveShooterForActiveGame
   bcs .checkHorizValues
   lda SWCHA                        ; read joystick values
   asl                              ; shift joystick down value into D7
   asl
   bpl .playerMovingDown
   asl                              ; move up value into D7
   bmi .checkHorizValues
   dec shooterVertPos               ; move player up
   lda shooterVertPos               ; get player current vertical position
   cmp #SHOOTER_YMIN + 1
   bne .checkHorizValues
   inc shooterVertPos               ; move player down
   bne .checkHorizValues            ; unconditional branch

.playerMovingDown
   inc shooterVertPos               ; move player down
   lda shooterVertPos               ; get player current vertical position
   cmp #SHOOTER_YMAX + 1
   bne .checkHorizValues
   dec shooterVertPos               ; move player up
.checkHorizValues
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip the bits
   and #<~[MOVE_RIGHT & MOVE_LEFT]  ; isolate horizontal movement values
   bne .determineShooterHorizontalFriction
   sta shooterHorizFrictionValue    ; clear Shooter horizontal friction value
.determineShooterHorizontalFriction
   lda shooterHorizFrictionValue    ; get Shooter horizontal friction value
   cmp #MAX_HORIZ_FRICTION_VALUE
   bcc .incrementShooterHorizontalFrictionIndex
   lda #MAX_HORIZ_FRICTION_VALUE - 1
   sta shooterHorizFrictionValue
.incrementShooterHorizontalFrictionIndex
   inc shooterHorizFrictionValue
   ldx shooterHorizFrictionValue
   lda SWCHA                        ; read joystick values
   bpl .joystickMovedRight
   asl                              ; shift left joystick value to D7
   bmi .checkShooterHorizontalBoundaries
   lda ShooterHorizontalAdjustmentValues,x;get horizontal adjustment value
   eor #$FF                         ; get 1's complement
   sec                              ; set carry
   adc shooterHorizPos              ; adjust Shooter horizontal position
   sta shooterHorizPos
   jmp .checkShooterHorizontalBoundaries
    
.joystickMovedRight
   lda ShooterHorizontalAdjustmentValues,x;get horizontal adjustment value
   clc
   adc shooterHorizPos              ; adjust Shooter horizontal position
   sta shooterHorizPos
   jmp .checkShooterHorizontalBoundaries
    
ShooterHorizontalAdjustmentValues
   .byte 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1
   .byte 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 2, 2

.checkShooterHorizontalBoundaries
   lda shooterHorizPos              ; get Shooter horizontal position
   bpl .checkShooterRightBoundary   ; branch if not passed left edge
   lda #XMIN
   sta shooterHorizPos              ; set Shooter to horizontal minimum
.checkShooterRightBoundary
   cmp #XMAX - 3
   bmi CheckToLaunchPlayerShot      ; branch if not passed right edge
   lda #XMAX - 4
   sta shooterHorizPos              ; set Shooter to horizontal maximum
   bne CheckToLaunchPlayerShot      ; unconditional branch

MoveShooterForDemoMode
   lda SWCHA                        ; read joystick values
   cmp #NO_MOVE
   beq .moveShooterForDemoMode      ; branch if joystick not moved
   lda #0
   sta displayScanOutControl        ; set to enable scan out
   sta frameCount + 1               ; reset frame count high byte value
.moveShooterForDemoMode
   lda frameCount                   ; get the current frame count
   bpl .checkToLaunchShotForDemo
   and #1
   bne .moveShooterHorizontally
   bit demoShooterDirectionValues
   bpl .demoShooterMoveUp           ; branch if DEMO_SHOOTER_MOVE_UP
   lda shooterVertPos               ; get Shooter vertical position
   cmp #SHOOTER_YMAX
   bne .moveShooterDown
   lda demoShooterDirectionValues   ; get demo Shooter direction value
   eor #DEMO_SHOOTER_VERT_DIR       ; flip to DEMO_SHOOTER_MOVE_UP
   sta demoShooterDirectionValues
   bpl .moveShooterHorizontally     ; unconditional branch

.moveShooterDown
   inc shooterVertPos
   bne .moveShooterHorizontally     ; unconditional branch

.demoShooterMoveUp
   lda shooterVertPos               ; get Shooter vertical position
   cmp #SHOOTER_YMIN + 6
   bne .moveShooterUp
   lda demoShooterDirectionValues   ; get demo Shooter direction value
   eor #DEMO_SHOOTER_VERT_DIR       ; flip to DEMO_SHOOTER_MOVE_DOWN
   sta demoShooterDirectionValues
   bmi .moveShooterHorizontally     ; unconditional branch

.moveShooterUp
   dec shooterVertPos
.moveShooterHorizontally
   bit demoShooterDirectionValues   ; check demo Shooter direction values
   bvc .demoShooterMoveRight
   lda shooterHorizPos              ; get Shooter horizontal position
   bne .moveShooterLeft             ; branch if not reached left edge
   lda demoShooterDirectionValues
   eor #DEMO_SHOOTER_HORIZ_DIR      ; flip to DEMO_SHOOTER_MOVE_RIGHT
   sta demoShooterDirectionValues
   jmp .checkToLaunchShotForDemo

.moveShooterLeft
   dec shooterHorizPos
   bpl .checkToLaunchShotForDemo    ; unconditional branch

.demoShooterMoveRight
   lda shooterHorizPos              ; get Shooter horizontal position
   cmp #XMAX - 4
   bne .moveShooterRight            ; branch if not reached right edge
   lda demoShooterDirectionValues
   eor #DEMO_SHOOTER_HORIZ_DIR      ; flip to DEMO_SHOOTER_MOVE_LEFT
   sta demoShooterDirectionValues
   bne .checkToLaunchShotForDemo

.moveShooterRight
   inc shooterHorizPos
.checkToLaunchShotForDemo
   lda shotVertPos                  ; get Shot vertical position
   bne .shotActive                  ; branch if SHOT_ACTIVE
   beq .determineToPlayerPlayerShotSounds

DDTCloudAnimationSpriteValues
   .byte ID_DDT_CLOUD,     ID_DDT_CLOUD,     ID_DDT_CLOUD + 1, ID_DDT_CLOUD + 2
   .byte ID_DDT_CLOUD + 3, ID_DDT_CLOUD + 4, ID_DDT_CLOUD + 3, ID_DDT_CLOUD + 4
   .byte ID_DDT_CLOUD + 3, ID_DDT_CLOUD + 4, ID_DDT_CLOUD + 3, ID_DDT_CLOUD + 4
   .byte ID_DDT_CLOUD + 5, ID_DDT_CLOUD + 6, ID_DDT_CLOUD + 7, ID_DDT_CLOUD + 7

CheckToLaunchPlayerShot
   lda shotVertPos                  ; get Shot vertical position
   bne .shotActive                  ; branch if SHOT_ACTIVE
   lda INPT4                        ; read player's fire button
   bmi SetShooterAndShotKernelValues; branch if fire button not pressed
.determineToPlayerPlayerShotSounds
   lda #<[PlayerShotAudioValues - LeftSoundChannelValues]
   ldx leftSoundChannelIndex        ; get left sound channel index value
   beq .setToPlayPlayerShotSounds   ; branch if left sound not active
   cmp leftSoundChannelIndex
   bcs .launchPlayerShot            ; branch if current sound a higher priority
.setToPlayPlayerShotSounds
   sta leftSoundChannelIndex
.launchPlayerShot
   ldx shooterHorizPos              ; get Shooter horizontal position
   inx
   stx shotHorizPos
   ldx shooterVertPos               ; get Shooter vertical position
   lda BANK3_ShooterKernelZoneValues,x;get Shooter KERNEL_ZONE value
   clc
   adc #2
   sta shotVertPos
.shotActive
   lda inchwormWaveState            ; get Inchworm wave state
   bpl .moveShotUp                  ; branch if PLAYER_MOVEMENT_NORMAL
   and #INSECT_SPEED_MASK           ; keep the OBJECT_SPEED value
   beq SetShooterAndShotKernelValues; branch if INSECT_SPEED_NORMAL
.moveShotUp
   dec shotVertPos
SetShooterAndShotKernelValues
   lda shotVertPos                  ; get Shot vertical position
   beq .setShotKernelValues         ; branch if Shot not active
   asl                              ; multiply by 2
   adc shotVertPos                  ; multiply by 5 (i.e. [x * 2] + x)
   sec
   sbc #2
.setShotKernelValues
   sta playerShotEnableIndex
   lda shooterVertPos
   sec
   sbc playerShotEnableIndex
   sta kernelShooterState
   lda playerShotEnableIndex
   bne AlternateDDTCloudAnimation
   dec playerShotEnableIndex
   inc kernelShooterState
AlternateDDTCloudAnimation
   lda #MAX_KERNEL_SECTIONS + 1
   sta millipedeBodyKernelZone
   ldx #MAX_DDT_BOMBS - 1
.alternateDDTCloudAnimation
   lda ddtBombSpriteIds_R,x         ; get DDT sprite id value
   cmp #ID_DDT_CLOUD + 8
   bcc .checkNextDDTCloudSprite     ; branch if not reached end of animation
   sbc #H_DDT_CLOUD                 ; subtract height to alternate animation
   sta ddtBombSpriteIds_W,x
.checkNextDDTCloudSprite
   dex
   bne .alternateDDTCloudAnimation
   ldx #<tmpConflictingZoneValues
   txs
   ldy conflictArrayStartingIndex   ; get conflict array starting index value
   ldx kernelZoneAdjustment         ; get kernel zone adjustment
   bne .checkForDoneZoneConflictForKernelAdjustment
   beq .checkForDoneZoneConflict    ; unconditional branch

.nextNonKernelAdjustmentConflictingZoneObject
   iny                              ; increment ZP RAM pointer
   sec
   ldx $00,y                        ; get kernel zone conflicting SPRITE_ID_IDX
   bpl .swapNonKernelAdjustmentSpriteIdToObject_01;branch if not MILLIPEDE_CHAIN
   txa                              ; move SPRITE_ID_IDX to accumulator
   and #$7F
   tax
   clc
.swapNonKernelAdjustmentSpriteIdToObject_01
   lda objectAttributes_R,x         ; get object attribute values
   beq .checkForDoneZoneConflict    ; branch if object not present
   sbc #1 - 1                       ; reduce KERNEL_ZONE value
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   pha                              ; push KERNEL_ZONE to stack
   stx tmpSpriteIdx
   tax                              ; move KERNEL_ZONE to x register
   lda #ID_BLANK
   sta kernelZoneAttributes_00,x    ; clear zone attributes for object 0
   lda kernelZoneAttributes_01 - 1,x; get zone attributes for object 1
   and #POISON_MUSHROOM_ZONE        ; keep POISON_MUSHROOM_ZONE value
   ora tmpSpriteIdx                 ; combine with SPRITE_ID_IDX
   sta kernelZoneAttributes_01 - 1,x; set zone attributes for object 1
.checkForDoneZoneConflict
   cpy #<[kernelZoneConflictArray + 5]
   bcc .nextNonKernelAdjustmentConflictingZoneObject
   bcs .doneSetZoneAttributeValues  ; branch if reached end of array

.nextKernelAdjustmentConflictingZoneObject
   iny                              ; increment ZP RAM pointer
   sec
   ldx $00,y                        ; get kernel zone conflicting SPRITE_ID_IDX
   bpl .swapKernelAdjustmentSpriteIdToObject_01;branch if not MILLIPEDE_CHAIN
   txa                              ; move SPRITE_ID_IDX to accumulator
   and #$7F
   tax
   clc
.swapKernelAdjustmentSpriteIdToObject_01
   lda objectAttributes_R,x         ; get object attribute values
   beq .checkForDoneZoneConflictForKernelAdjustment;branch if object not preset
   adc #1 - 1                       ; increment KERNEL_ZONE value
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   pha                              ; push KERNEL_ZONE to stack
   stx tmpSpriteIdx
   tax                              ; move KERNEL_ZONE to x register
   lda #ID_BLANK
   sta kernelZoneAttributes_00,x    ; clear zone attributes for object 0
   lda kernelZoneAttributes_01 - 1,x; get zone attributes for object 1
   and #POISON_MUSHROOM_ZONE        ; keep POISON_MUSHROOM_ZONE value
   ora tmpSpriteIdx                 ; combine with SPRITE_ID_IDX
   sta kernelZoneAttributes_01 - 1,x; set zone attributes for object 1
.checkForDoneZoneConflictForKernelAdjustment
   cpy #<[kernelZoneConflictArray + 5]
   bcc .nextKernelAdjustmentConflictingZoneObject
.doneSetZoneAttributeValues
   lda #0
   pha
   ldx #<[kernelZoneConflictArray + 5]
   txs                              ; point stack to end of conflict array
   ldy objectListEndValue
CheckForConflictingObjectZones
   lda objectAttributes_R,y         ; get object attribute values
   beq .nextObjectList              ; branch if object not present
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   tax
.checkForConflictingObjectZones
   lda kernelZoneAttributes_00,x    ; get object 0 zone attributes
   bmi .checkToSetConflictingKernelZoneValue;branch if SKIP_DRAW_INSECT_ZONE
   bne .checkToSetKernelZoneAttributesForObject_01;branch if object present
   tya                              ; move index to accumulator
   sec
   sbc kernelZoneAttributes_01 - 1,x
   beq .clearObjectsInKernelZone    ; branch if object in kernel zone
   cmp #POISON_MUSHROOM_ZONE
   bne .nextObjectList
.clearObjectsInKernelZone
   lda #SKIP_DRAW_INSECT_ZONE
   sta kernelZoneAttributes_00,x    ; clear kernel zone object 0
   and kernelZoneAttributes_01 - 1,x; keep POISON_MUSHROOM_ZONE value
   sta kernelZoneAttributes_01 - 1,x; clear kernel zone object 1
   jmp .checkForConflictingObjectZones
    
.checkToSetKernelZoneAttributesForObject_01
   lda kernelZoneAttributes_01 - 1,x; get object 1 zone attributes
   asl                              ; shift POISON_MUSHROOM_ZONE to carry
   bne .setConflictingKernelZoneValue;branch if object present
   lda spriteIdArray_R,y            ; get sprite id value
   bmi .setConflictingKernelZoneValue;branch if MILLIPEDE_CHAIN
   tya                              ; move index to accumulator
   bcc .setKernelZoneAttributesForObject_01;branch if NORMAL_MUSHROOM_ZONE
   ora #POISON_MUSHROOM_ZONE
.setKernelZoneAttributesForObject_01
   sta kernelZoneAttributes_01 - 1,x
.nextObjectList
   dey
   bne CheckForConflictingObjectZones
   jmp AnimateConflictingObjects
    
.checkToSetConflictingKernelZoneValue
   asl                              ; shift object 0 zone attributes
   bpl SetZoneAttributesForCloudZone; branch if DRAW_DDT_CLOUD_ZONE
.setConflictingKernelZoneValue
   sty tmpSpriteIdx
   txa                              ; move kernel section to accumulator
   sec
   sbc kernelZoneAdjustment         ; subtract kernel zone adjustment
   sta tmpConflictingKernelZoneValue; set conflicting kernel zone value
   tsx
   bne .checkForEndOfConflictList   ; unconditional branch

.nextConflictingObjectZones
   inx
   ldy $00,x                        ; get kernel zone conflicting SPRITE_ID_IDX
   bmi .checkForEndOfConflictList   ; branch if reached end of conflict array
   lda objectAttributes_R,y         ; get object attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE values
   cmp tmpConflictingKernelZoneValue
   bne .checkForEndOfConflictList   ; branch if not in same kernel zone
   ldy tmpSpriteIdx
   dey
   bne CheckForConflictingObjectZones
   jmp AnimateConflictingObjects
    
.checkForEndOfConflictList
   cpx #<[kernelZoneConflictArray + 5]
   bne .nextConflictingObjectZones  ; branch if not at end of conflict array
   ldy tmpSpriteIdx
   tya
   pha
   dey
   bne CheckForConflictingObjectZones
   jmp AnimateConflictingObjects
    
SetZoneAttributesForCloudZone
   bne .checkToSetMillipedeConflictingZone;branch if object present
   lda spriteIdArray_R,y            ; get sprite id value
   cmp #DRAW_MILLIPEDE_CHAIN_ZONE
   bcc .setCloudZoneAttributesForEmptySprite;branch if not Millipede chain
   lda spriteIdArray_R,y            ; get sprite id value
   sta kernelZoneAttributes_00,x    ; set zone to DRAW_MILLIPEDE_CHAIN_ZONE
   lsr                              ; shift D0 to carry
   lda kernelZoneAttributes_01 - 1,x; get object 1 kernel zone attributes
   ora objectHorizPositions_R,y     ; combine with Millipede horizontal position
   bcc .setMillipedeChainHorizontalPosition
   adc #W_MILLIPEDE_HEAD - 1        ; increment horizontal position (carry set)
   stx millipedeBodyKernelZone
.setMillipedeChainHorizontalPosition
   sta kernelZoneAttributes_01 - 1,x
   jmp .nextObjectList
    
.setCloudZoneAttributesForEmptySprite
   cmp #ID_DDT_CLOUD
   tya                              ; move SPRITE_ID_IDX to accumulator
   bcs .setObject0ZoneAttributes    ; branch if ID_DDT_CLOUD
   ora #SKIP_DRAW_INSECT_ZONE       ; set to skip insect draw
.setObject0ZoneAttributes
   sta kernelZoneAttributes_00,x
   bcs .checkToSetCloudConflictingZone;branch if ID_DDT_CLOUD
.doneSetZoneAttributesForCloudZone
   jmp .nextObjectList
    
.checkToSetMillipedeConflictingZone
   lsr                              ; restore object 0 zone attributes
   sta tmpKernelZoneAttributes_00
   lda spriteIdArray_R,y            ; get sprite id value
   cmp #DRAW_MILLIPEDE_CHAIN_ZONE
   bcs .setConflictingKernelZoneValue;branch if Millipede chain
   cmp #ID_DDT_CLOUD
   lda kernelZoneAttributes_01 - 1,x; get object 1 zone attributes
   ora tmpKernelZoneAttributes_00
   sta kernelZoneAttributes_01 - 1,x
   sty kernelZoneAttributes_00,x
   bcc .nextObjectList              ; branch if not ID_DDT_CLOUD
.checkToSetCloudConflictingZone
   lda kernelZoneAttributes_00 - 1,x; get object 0 zone attributes
   beq .setKernelZoneToDrawDDTCloud ; branch if object not present
   and #DRAW_INSECT_MASK | DRAW_DDT_CLOUD_MASK
   cmp #DRAW_DDT_CLOUD_ZONE
   beq .doneSetZoneAttributesForCloudZone;branch if DRAW_DDT_CLOUD_ZONE
   sty tmpSpriteIdx
   txa                              ; move kernel section to accumulator
   clc
   sbc kernelZoneAdjustment         ; subtract kernel zone adjustment
   sta tmpConflictingKernelZoneValue; set conflicting kernel zone value
   tsx                              ; move stack pointer to x register
   bne .checkForCloudZoneEndOfConflictList;unconditional branch

.nextConflictingCloudZones
   inx
   ldy $00,x
   bmi .checkForCloudZoneEndOfConflictList
   lda objectAttributes_R,y         ; get object attribute values
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpConflictingKernelZoneValue
   bne .checkForCloudZoneEndOfConflictList;branch if not in same kernel zone
   ldy tmpSpriteIdx
   dey
   beq AnimateConflictingObjects
   jmp CheckForConflictingObjectZones
    
.checkForCloudZoneEndOfConflictList
   cpx #<[kernelZoneConflictArray + 5]
   bne .nextConflictingCloudZones
   ldy tmpSpriteIdx
   tya
   ora #$80
   pha
   dey
   beq AnimateConflictingObjects
   jmp CheckForConflictingObjectZones
    
.setKernelZoneToDrawDDTCloud
   lda #DRAW_DDT_CLOUD_ZONE
   sta kernelZoneAttributes_00 - 1,x; set to DRAW_DDT_CLOUD_ZONE
   and kernelZoneAttributes_01 - 2,x; keep POISON_MUSHROOM_ZONE value
   sta kernelZoneAttributes_01 - 2,x; clear SPRITE_ID_IDX_MASK value
   jmp .nextObjectList
    
AnimateConflictingObjects SUBROUTINE
   ldx #<[tmpConflictingZoneValues + 1]
.animateConflictingObjects
   dex
   ldy $00,x
   beq .doneKernelZoneObjectPrioritySort
   lda kernelZoneAttributes_00,y    ; get object 0 zone attributes
   bne .animateConflictingObjects   ; branch if object in zone
   lda kernelZoneAttributes_00 + 1,y; get adjacent zone attribute values
   beq .setKernelZoneToDrawDDTCloud ; branch if no object in zone
   cmp #<[creatureAttributes_R - ddtBombAttributes_R]
   bcc .setKernelZoneToDrawDDTCloud ; branch if not a creature
   lda kernelZoneAttributes_01 - 1,y; get object 1 zone attributes
   and #<~POISON_MUSHROOM_ZONE      ; keep SPRITE_ID_IDX
   tay
   lda spriteIdArray_R,y            ; get sprite id value
   clc
   adc #H_SPRITE
   sta spriteIdArray_W,y
   jmp .animateConflictingObjects
    
.setKernelZoneToDrawDDTCloud
   lda #DRAW_DDT_CLOUD_ZONE
   sta kernelZoneAttributes_00,y    ; set to DRAW_DDT_CLOUD_ZONE
   and kernelZoneAttributes_01 - 1,y; keep POISON_MUSHROOM_ZONE value
   sta kernelZoneAttributes_01 - 1,y; clear SPRITE_ID_IDX_MASK value
   jmp .animateConflictingObjects
    
.doneKernelZoneObjectPrioritySort
   tsx
   stx conflictArrayStartingIndex   ; set conflict array starting index value
   ldx #$FF
   txs                              ; reset stack pointer
   ldx #0
   stx tmpMillipedeSegmentIndex
   ldx numberOfMillipedeSegments    ; get number of Millipede segments
   bmi .switchToSetupGameDisplayKernel;branch if no more Millipede segments
   bit inchwormWaveState            ; check Inchworm wave state
   bmi .switchToSetupGameDisplayKernel;branch if PLAYER_MOVEMENT_HALT
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   cmp #3
   beq CheckToCountRemainingMushrooms;branch to check to spawn Dragonfly or Bee
   jmp CheckToMoveMillipedeSegment
    
.switchToSetupGameDisplayKernel
   jmp SwitchBanksToSetupGameDisplayKernel
    
CheckToCountRemainingMushrooms
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 6
   bmi .switchToSetupGameDisplayKernel
   lda rightSoundChannelIndex       ; get right sound channel index value
   bne CountRemainingMushroomsInGarden;branch if right sound channel active
   lda inchwormWaveState            ; get Inchworm wave state
   and #INSECT_SPEED_MASK           ; keep OBJECT_SPEED value
   beq CheckToPlayTopPriorityInsectSounds;branch if INSECT_SPEED_NORMAL
   lda #<[InsectSlowDownAudioValues - RightSoundChannelValues]
   sta rightSoundChannelIndex
   jmp CountRemainingMushroomsInGarden
    
CheckToPlayTopPriorityInsectSounds
   ldx #2
.checkToPlayTopPriorityInsectSounds
   lda creatureAttributes_R,x
   beq .checkNextTopPriorityInsectSounds;branch if object not present
   ldy creatureSpriteIds_R,x        ; get creature sprite id value
   cpy #ID_SHOOTER_DEATH
   bcs .checkNextTopPriorityInsectSounds;branch if object not an insect
   lda BANK3_RightAudioValueLowerBounds,y
   sta rightSoundChannelIndex
   jmp CountRemainingMushroomsInGarden
    
.checkNextTopPriorityInsectSounds
   dex
   bpl .checkToPlayTopPriorityInsectSounds
   ldx #1
.checkToPlayLowerPriorityInsectSounds
   lda creatureAttributes_R + 3,x
   beq .checkNextLowerPriorityInsectSounds;branch if object not present
   ldy creatureSpriteIds_R + 3,x    ; get sprite id value
   cpy #ID_SHOOTER_DEATH
   bcs .checkNextLowerPriorityInsectSounds;branch if object not an insect
   lda BANK3_RightAudioValueLowerBounds,y
   sta rightSoundChannelIndex
   jmp CountRemainingMushroomsInGarden
    
.checkNextLowerPriorityInsectSounds
   dex
   bpl .checkToPlayLowerPriorityInsectSounds
CountRemainingMushroomsInGarden
   lda #0
   sta tmpNumberOfMushrooms
   lda frameCount                   ; get current frame count
   and #8                           ; a = 0 || a = 8
   bne CountRemainingMushroomsInPlayerArea
   ldx #9
.checkUpperMushroomGarden
   lda leftMushroomArray_R + 10,x   ; get left Mushroom value
   bne .sumMushroomsInLeftGarden    ; branch if Mushrooms present
   lda rightMushroomArray_R + 10,x  ; get right Mushroom value
   bne .sumMushroomsInRightGarden   ; branch if Mushrooms present
   lda kernelZoneAttributes_01 + 11,x;get kernel zone attribute value
   and #<~POISON_MUSHROOM_ZONE
   sta kernelZoneAttributes_01 + 11,x;remove POISON_MUSHROOM value
   bpl .checkNextUpperMushroomGarden; unconditional branch

.sumMushroomsInLeftGarden
   lsr                              ; divide Mushroom value by 2
   tay
   lda MushroomCountValues,y        ; get number of Mushrooms
   adc tmpNumberOfMushrooms         ; increment number of Mushroom value
   sta tmpNumberOfMushrooms
   lda rightMushroomArray_R + 10,x
.sumMushroomsInRightGarden
   lsr                              ; divide Mushroom value by 2
   tay
   lda MushroomCountValues,y        ; get number of Mushrooms
   adc tmpNumberOfMushrooms         ; increment number of Mushroom value
   sta tmpNumberOfMushrooms
.checkNextUpperMushroomGarden
   dex
   cpx kernelZoneAdjustment
   bne .checkUpperMushroomGarden
   lda tmpNumberOfMushrooms         ; get number of upper Mushrooms
   cmp #32
   lda objectSpawningValues         ; get object spawning values
   and #<~OBJECT_SPAWNING_DRAGONFLY ; clear OBJECT_SPAWNING_DRAGONFLY value
   bcs .setDragonflySpawningStatus
   ora #OBJECT_SPAWNING_DRAGONFLY
.setDragonflySpawningStatus
   sta objectSpawningValues
   
   IF COMPILE_REGION = PAL50
   
      ldx numberOfMillipedeSegments ; get number of Millipede segments
      jmp CheckToMoveMillipedeSegment
      
   ENDIF
   
   jmp SwitchBanksToSetupGameDisplayKernel
    
CountRemainingMushroomsInPlayerArea SUBROUTINE
   lda #7
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   tax
.checkLowerMushroomGarden
   lda leftMushroomArray_R,x        ; get left Mushroom array value
   bne .sumMushroomsInLeftGarden    ; branch if Mushrooms present
   lda rightMushroomArray_R,x       ; get right Mushroom array value
   bne .sumMushroomsInRightGarden   ; branch if right Mushrooms present
   lda kernelZoneAttributes_01 + 1,x; get kernel zone attribute values
   and #<~POISON_MUSHROOM_ZONE
   sta kernelZoneAttributes_01 + 1,x; remove POISON_MUSHROOM value
   bpl .checkNextLowerMushroomGarden; unconditional branch

.sumMushroomsInLeftGarden
   lsr                              ; divide Mushroom value by 2
   tay
   lda MushroomCountValues,y        ; get number of Mushrooms
   adc tmpNumberOfMushrooms         ; increment number of Mushroom value
   sta tmpNumberOfMushrooms
   lda rightMushroomArray_R,x       ; get right Mushroom array value
.sumMushroomsInRightGarden
   lsr                              ; divide Mushroom value by 2
   tay
   lda MushroomCountValues,y        ; get number of Mushrooms
   adc tmpNumberOfMushrooms         ; increment number of Mushroom value
   sta tmpNumberOfMushrooms
.checkNextLowerMushroomGarden
   dex
   bpl .checkLowerMushroomGarden
   lda tmpNumberOfMushrooms         ; get number of upper Mushrooms
   cmp #7
   lda objectSpawningValues         ; get object spawning values
   and #<~OBJECT_SPAWNING_BEE       ; clear the OBJECT_SPAWNING_BEE value
   bcs .setBeeSpawningStatus        ; branch if not spawning Bee
   ora #OBJECT_SPAWNING_BEE
.setBeeSpawningStatus
   sta objectSpawningValues
   ldx #2
.checkMushroomsAbovePlayerArea
   lda leftMushroomArray_R + 8,x    ; get left Mushroom array value
   ora rightMushroomArray_R + 8,x   ; combine with right Mushroom array value
   bne .checkNextMushroomsAbovePlayerArea;branch Mushrooms present
   lda kernelZoneAttributes_01 + 9,x
   and #<~POISON_MUSHROOM_ZONE
   sta kernelZoneAttributes_01 + 9,x; remove POISON_MUSHROOM value
.checkNextMushroomsAbovePlayerArea
   dex
   bpl .checkMushroomsAbovePlayerArea

   IF COMPILE_REGION = PAL50
   
      ldx numberOfMillipedeSegments ; get number of Millipede segments
      jmp CheckToMoveMillipedeSegment
       
   ENDIF

.doneMoveMillipedeSegment
   jmp SwitchBanksToSetupGameDisplayKernel
    
CheckToMoveMillipedeSegment
   lda millipedeAttributes_R,x      ; get Millipede attributes
   and #MILLIPEDE_SPEED_MASK        ; keep MILLIPEDE_SPEED value
   bne .moveMillipede               ; branch if MILLIPEDE_FAST
   lda frameCount                   ; get current frame count
   and #1
   bne .doneMoveMillipedeSegment    ; move MILLIPEDE_SLOW every 1/2 frames
.moveMillipede
   lda millipedeSegmentState,x      ; get Millipede segment state
   sta tmpMillipedeState
   bpl .checkToMoveMillipedeHead    ; branch if MILLIPEDE_HEAD_SEGMENT
   lda tmpMillipedeSegmentIndex
   bne .moveMillipedeSegment
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 6
   bmi .doneMoveMillipedeSegment
   stx tmpMillipedeSegmentIndex
.moveMillipedeSegment
   lda millipedeSegmentState - 1,x  ; get leading Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta tmpLeadingSegmentKernelZone
   lda tmpMillipedeState            ; get Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpLeadingSegmentKernelZone
   beq .moveMillipedeSegmentHorizontally;branch if in leading segment zone
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   and #3
   bne .moveMillipedeSegmentHorizontally
   lda millipedeSegmentState - 1,x  ; get leading Millipede segment state
   ora #MILLIPEDE_BODY_SEGMENT
   sta millipedeSegmentState,x
   bne .checkIfDoneMovingMillipedeChain;unconditional branch

.checkToMoveMillipedeHead
   lda millipedeSegmentState + 1,x  ; get trailing Millipede segment state
   bmi .moveMillipedeHead           ; branch if MILLIPEDE_BODY_SEGMENT
   lda INTIM                        ; get RIOT timer value
   cmp #127 + 6
   bmi .doneMoveMillipedeSegment
.moveMillipedeHead
   lda tmpMillipedeState            ; get MILLIPEDE_HEAD_SEGMENT state
   and #MILLIPEDE_HORIZ_DIR_MASK    ; keep MILLIPEDE_HORIZ_DIR value
   bne .checkMillipedeReachingHorizEdges;branch if MILLIPEDE_DIR_LEFT
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   cmp #XMAX - W_MILLIPEDE_HEAD
   beq .checkToMoveMillipedeSegmentVertically;branch if reached right edge
   bne .checkRightMovingMillipedeReachingLeftEdge;unconditional branch
    
.checkMillipedeReachingHorizEdges
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   beq .checkToMoveMillipedeSegmentVertically;branch if reached left edge
   cmp #XMAX - W_MILLIPEDE_HEAD
   beq .moveMillipedeSegmentHorizontally;branch if reached right edge
.checkRightMovingMillipedeReachingLeftEdge
   cmp #XMIN
   beq .moveMillipedeSegmentHorizontally;branch if reached left edge
   and #3
   beq .checkMillipedeCollisionWithMushroom
.moveMillipedeSegmentHorizontally
   lda tmpMillipedeState
   and #MILLIPEDE_HORIZ_DIR_MASK    ; keep MILLIPEDE_HORIZ_DIR value
   bne .decrementMillipedeHorizontalPosition;branch if MILLIPEDE_DIR_LEFT
   inc millipedeHorizPosition,x
   bne .checkIfDoneMovingMillipedeChain;unconditional branch

.decrementMillipedeHorizontalPosition
   dec millipedeHorizPosition,x
.checkIfDoneMovingMillipedeChain
   bit tmpMillipedeState
   bmi .moveNextMillipedeSegment    ; branch if MILLIPEDE_BODY_SEGMENT
   lda #0
   sta tmpMillipedeSegmentIndex
.moveNextMillipedeSegment
   dex
   bmi .doneMoveMillipedeSegment
   jmp CheckToMoveMillipedeSegment
    
.checkToMoveMillipedeSegmentVertically
   jmp CheckToMoveMillipedeSegmentVertically
    
.checkMillipedeCollisionWithMushroom
   lda millipedeHorizPosition,x     ; get Millipede segment horizontal position
   lsr                              ; divide by 4
   lsr
   tay                              ; set to Millipede horizontal position
   lda tmpMillipedeState            ; get Millipede KERNEL_ZONE value
   eor #1
   eor kernelZoneAdjustment
   lsr
   and #MILLIPEDE_HORIZ_DIR_MASK >> 1;keep MILLIPEDE_HORIZ_DIR value
   bne .determineMushroomMaskingBitIndex;branch if MILLIPEDE_DIR_LEFT
   iny
   iny
.determineMushroomMaskingBitIndex
   dey
   bmi .moveMillipedeSegmentHorizontally
   tya
   bcs .setMillipedeMushroomMaskingBitIndex;branch if Millipede in odd zone
   adc #<[BANK3_EvenMushroomMaskingBits - BANK3_MushroomMaskingBits]
.setMillipedeMushroomMaskingBitIndex
   sta tmpMushroomMaskingBitIndex
   tay
   lda millipedeAttributes_R,x      ; get Millipede attribute values
   and #MILLIPEDE_POISONED_MASK
   beq .checkNormalMillipedeCollisionWithMushroom;branch if MILLIPEDE_NORMAL
   lda BANK3_MushroomMaskingBits,y
   bne CheckToMoveMillipedeSegmentVertically
   beq .moveMillipedeSegmentHorizontally;unconditional branch

.checkNormalMillipedeCollisionWithMushroom
   lda tmpMillipedeState            ; get Millipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   clc
   adc kernelZoneAdjustment         ; increment by kernel zone adjustment
   sta tmpMillipedeSegmentZone
   beq .moveMillipedeSegmentHorizontally
   lda tmpMushroomMaskingBitIndex   ; get Mushroom masking index
   and #$10
   beq .checkMushroomPresent        ; branch for left Mushroom array
   lda #MAX_KERNEL_SECTIONS - 1
.checkMushroomPresent
   adc tmpMillipedeSegmentZone
   tay
   lda mushroomArray_R - 1,y        ; get Mushroom array value
   ldy tmpMushroomMaskingBitIndex
   and BANK3_MushroomMaskingBits,y  ; mask Mushroom bit value
   beq .moveMillipedeSegmentHorizontally;branch if Mushroom not present
   ldy tmpMillipedeSegmentZone
   lda kernelZoneAttributes_01,y
   bpl CheckToMoveMillipedeSegmentVertically;branch if NORMAL_MUSHROOM_ZONE
   lda millipedeAttributes_R,x
   ora #MILLIPEDE_POISONED
   sta millipedeAttributes_W,x
CheckToMoveMillipedeSegmentVertically
   lda tmpMillipedeState            ; get Millipede segment state
   tay
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   beq .millipedeReachedBottomZone  ; branch if reached bottom zone
   cmp #5
   bne .moveMillipedeSegmentVertically
   bit tmpMillipedeState            ; check Millipede segment state
   bvc .moveMillipedeSegmentDown    ; branch if MILLIPEDE_DIR_DOWN
   bvs .changeMillipedeVerticalDirection;unconditional branch
    
.millipedeReachedBottomZone
   lda millipedeAttributes_R,x
   and #MILLIPEDE_POISONED_MASK     ; keep MILLIPEDE_POISONED value
   beq .setMillipedeStateForReachingBottom;branch if MILLIPEDE_NORMAL
   lda millipedeAttributes_R,x
   and #<~MILLIPEDE_POISONED_MASK   ; clear MILLIPEDE_POISONED value
   sta millipedeAttributes_W,x
   jmp .changeMillipedeVerticalDirection
    
.setMillipedeStateForReachingBottom
   lda gameState                    ; get current game state
   ora #GS_SPAWN_MILLIPEDE_HEAD
   sta gameState
   lda tmpMillipedeSegmentIndex
   beq .changeMillipedeVerticalDirection
   tay
   lda millipedeSegmentState,y      ; get Millipede segment state
   eor #MILLIPEDE_SEGMENT_MASK | MILLIPEDE_HORIZ_DIR_MASK
   sta millipedeSegmentState,y
.changeMillipedeVerticalDirection
   lda tmpMillipedeState
   eor #MILLIPEDE_VERT_DIR_MASK
   tay
.moveMillipedeSegmentVertically
   tya                              ; move Millipede state to accumulator
   and #MILLIPEDE_VERT_DIR_MASK     ; keep MILLIPEDE_VERT_DIR value
   beq .moveMillipedeSegmentDown    ; branch if MILLIPEDE_DIR_DOWN
   iny                              ; increment Millipede KERNEL_ZONE value
   iny
.moveMillipedeSegmentDown
   dey                              ; decrement Millipede KERNEL_ZONE value
   tya                              ; move Millipede state to accumulator
   eor #MILLIPEDE_HORIZ_DIR_MASK    ; flip MILLIPEDE_HORIZ_DIR value
   sta millipedeSegmentState,x
   jmp .checkIfDoneMovingMillipedeChain

   IF ORIGINAL_ROM
   
      .byte $4C,$E4,$FF             ;never executed
      
   ENDIF

BANK3_RightAudioValueLowerBounds
   .byte <RightSoundChannelValues
   .byte <RightSoundChannelValues
   .byte <RightSoundChannelValues
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[EarwigAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[SpiderAudioValues - RightSoundChannelValues]
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 14
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 14
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 14
   .byte <[MosquitoAudioValues - RightSoundChannelValues] + 14
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[DragonflyAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[InchwormAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
   .byte <[BeetleAudioValues - RightSoundChannelValues]
    
   FILL_BOUNDARY 256, 0

BANK3_ShooterKernelZoneValues
   .byte 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7
   .byte 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14
   .byte 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20
   .byte 20, 20

InitLeftMushroomPatchValues
   .byte $00,$00,$01,$18,$41,$00,$00,$00,$01,$00
   .byte $40,$03,$10,$80,$20,$01,$00,$00,$00,$00
InitRightMushroomPatchValues
   .byte $00,$00,$40,$00,$00,$20,$42,$08,$80,$02
   .byte $00,$10,$10,$00,$00,$40,$0A,$30,$84,$00

BANK3_InitDDTHorizontalPositionValues
   .byte 0, 32, 48, 64, 80

InitDDTAttributeValues
   .byte 0, 18, 15, 17, 8

BANK3_MushroomMaskingBits
BANK3_OddMushroomMaskingBits
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
BANK3_EvenMushroomMaskingBits
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00

   FILL_BOUNDARY 256, 0

MushroomCountValues
   .byte 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6
   .byte 4, 5, 5, 6, 5, 6, 6, 7

   IF ORIGINAL_ROM

      .byte " DAVE STAUGAS LOVES BEATRICE HABLIG "

   ENDIF

    FILL_BOUNDARY 228, 0

SwitchBanksToSetupGameDisplayKernel
   lda BANK0STROBE
   jmp NewFrame

   lda BANK3STROBE
   jmp.w 0

   lda BANK3STROBE
   jmp BANK3_Start

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data

   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK3"

   .word BANK3_Start
   .word BANK3_Start
   .word BANK3_Start