   LIST OFF
; ***  C E N T I P E D E  ***
; Copyright 1982 Atari, Inc.
; Designers: Josh Littlefield and David W. Payne
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: February 16, 2022
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
; *** 187 BYTES OF ROM FREE IN BANK0
; ***   4 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 191 TOTAL BYTES FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; *** 176 BYTES OF BANK0 FREE
; ***   0 BYTES OF BANK1 FREE
; ===========================================
; *** 176 TOTAL BYTES FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, ATARI INC.                                   =
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

;===============================================================================
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

VBLANK_TIME             = 43
TITLE_OVERSCAN_TIME     = 33
OVERSCAN_TIME           = 36

   ELSE
   
VBLANK_TIME             = 77
TITLE_OVERSCAN_TIME     = 58
OVERSCAN_TIME           = 60

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

COLORS_SCORE            = ULTRAMARINE_BLUE + 15
COLOR_TITLE_MUSHROOM    = DK_BLUE + 10

   ELSE

YELLOW                  = $20
RED_ORANGE              = $20
GREEN                   = $30
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE                  = $70
COLBALT_BLUE            = $80
TURQUOISE               = $90
CYAN                    = $A0
BLUE                    = $B0
DK_BLUE                 = BLUE
LT_BLUE                 = $C0
BLUE_2                  = $D0

COLORS_SCORE            = WHITE + 1
COLOR_TITLE_MUSHROOM    = TURQUOISE + 10

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

BANK0_BASE              = $1000
BANK1_BASE              = $2000

BANK0_REORG             = $D000
BANK1_REORG             = $F000

BANK0STROBE             = $FFF8
BANK1STROBE             = $FFF9

MAX_KERNEL_SECTIONS     = 20
MAX_CENTIPEDE_SEGMENTS  = 9
;
; Sprite size constants
;
; ----- Title screen bitmap constants -----
H_CENTIPEDE_BITMAP      = 90
H_ATARI_BITMAP          = 50
H_COPYRIGHT_BITMAP      = 25
H_MUSHROOM_BITMAP       = 9
; ----- Game Sprite size constants -----
H_OBJECTS               = 6
H_DIGITS                = 7
H_MUSHROOMS             = 4
H_SHOOTER               = 3
W_FLEA                  = 4
W_CENTIPEDE_HEAD        = 4
W_SCORPION              = 8
W_SPIDER                = 8
;
; Screen boundary constants
;
XMIN                    = 0
XMAX                    = 128
SHOOTER_YMIN            = 44
SHOOTER_YMAX            = 56
SHOOTER_START_X         = 60
SHOOTER_START_Y         = SHOOTER_YMAX
CENTIPEDE_START_X       = 60

MAX_TITLE_SCREEN_CYCLE  = 2         ; title screen shown for 512 frames
;
; Game selection constants
;
SELECT_DELAY            = 15
MAX_LEVEL               = 15
;
; Mushroom constants
;
MUSHROOM_ARRAY_SIZE     = 38

ODD_LEFT_PF1_MUSHROOM_MASK = $AA
ODD_LEFT_PF2_MUSHROOM_MASK = $55
ODD_RIGHT_PF1_MUSHROOM_MASK = $55
ODD_RIGHT_PF2_MUSHROOM_MASK = $AA

EVEN_LEFT_PF1_MUSHROOM_MASK = $55
EVEN_LEFT_PF2_MUSHROOM_MASK = $AA
EVEN_RIGHT_PF1_MUSHROOM_MASK = $AA
EVEN_RIGHT_PF2_MUSHROOM_MASK = $55
;
; Remaining lives constants
;
INIT_LIVES              = 3
MAX_LIVES               = 7

LIVES_MASK              = $F0
GAME_WAVE_MASK          = $0F
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
ID_CHILDREN_ICON        = 11
;
; Sprite Id values
;
ID_FLEA                 = 0         ; 0 - 1
ID_SPIDER               = 2         ; 2 - 5
ID_POINTS_300           = 6
ID_POINTS_600           = 7
ID_POINTS_900           = 8
ID_SCORPION             = 10        ; 10 - 13
ID_EXPLOSION            = 16        ; 16 - 19
ID_BLANK_SPRITE         = 22
ID_CENTIPEDE_HEAD       = 23
ID_CENTIPEDE_BODY       = 24
;
; Point values
;
POINTS_CENTIPEDE_SEGMENT = 10
POINTS_CENTIPEDE_HEAD   = 100
POINTS_SPIDER_DISTANT   = 300
POINTS_SPIDER_MEDIUM    = 600
POINTS_SPIDER_CLOSE     = 900
POINTS_FLEA             = 200
POINTS_SCORPION         = 1000
POINTS_ELIMINATE_MUSHROOM  = 1
POINTS_REMAINING_MUSHROOMS = 5

; game state flags
SELECT_SCREEN           = %01000000

GAME_SELECTION_MASK     = %01000000
EASY_PLAY_GAME          = 1 << 6
STANDARD_PLAY_GAME      = 0 << 6
;
; Kernel zone attribute values
;
POISON_MUSHROOM_MASK    = %10000000
SPRITE_ID_MASK          = %00011111

POISON_MUSHROOM_ZONE    = 1 << 7
NORMAL_MUSHROOM_ZONE    = 0 << 7
;
; Centipede attribute values
;
CENTIPEDE_SPEED_MASK    = %01000000
CENTIPEDE_POISONED_MASK = %00100000

CENTIPEDE_FAST          = 1 << 6
CENTIPEDE_SLOW          = 0 << 6

CENTIPEDE_POISONED      = 1 << 5
CENTIPEDE_NORMAL        = 0 << 5
;
; Spider attribute values
;
SPIDER_POINTS_MASK      = %11000000
SPIDER_POINTS_TIMER_MASK = %00110000
OBJECT_SHOT_AUDIO_TIMER_MASK = %00001100
SPIDER_HORIZ_MOVE_MASK  = %00000010
SPIDER_SPEED_MASK       = %00000001

SPIDER_POINTS_300       = 1 << 6
SPIDER_POINTS_600       = 2 << 6
SPIDER_POINTS_900       = 3 << 6

SPIDER_HORIZ_MOVE       = 1 << 1
SPIDER_NO_HORIZ_MOVE    = 0 << 1

SPIDER_SLOW             = 1 << 0
SPIDER_FAST             = 0 << 0
;
; Centipede state values
;
CENTIPEDE_SEGMENT_MASK  = %10000000
CENTIPEDE_VERT_DIR_MASK = %01000000
CENTIPEDE_HORIZ_DIR_MASK = %00100000

CENTIPEDE_BODY_SEGMENT  = 1 << 7
CENTIPEDE_HEAD_SEGMENT  = 0 << 7

CENTIPEDE_DIR_UP        = 1 << 6
CENTIPEDE_DIR_DOWN      = 0 << 6

CENTIPEDE_DIR_LEFT      = 1 << 5
CENTIPEDE_DIR_RIGHT     = 0 << 5
;
; Flea state values
;
FLEA_SHOT_MASK          = %01000000

FLEA_STATE_ANGRY        = 1 << 6
FLEA_STATE_NORMAL       = 0 << 6
;
; Scorpion state values
;
SCORPION_DIR_MASK       = %10000000
SCORPION_SPEED_MASK     = %01000000

SCORPION_DIR_LEFT       = 1 << 7
SCORPION_DIR_RIGHT      = 0 << 7

SCORPION_FAST           = 1 << 6
SCORPION_SLOW           = 0 << 6

SCORPION_INACTIVE       = $FF
;
; Spider state values
;
SPIDER_HORIZ_DIR_MASK   = %10000000
SPIDER_VERT_DIR_MASK    = %01000000

SPIDER_DIR_LEFT         = 0 << 7
SPIDER_DIR_RIGHT        = 1 << 7
SPIDER_DIR_UP           = 0 << 6
SPIDER_DIR_DOWN         = 1 << 6

SPIDER_INACTIVE         = $FF
KERNEL_ZONE_MASK        = %00011111
;
; Color table offset values
;
MUSHROOM_COLOR_OFFSET   = 0
FLEA_COLOR_OFFSET       = 1
CENTIPEDE_COLOR_OFFSET  = 3
SPIDER_COLOR_OFFSET     = 5
POINTS_600_COLOR_OFFSET = 6
SCORPION_COLOR_OFFSET   = 7
POINTS_900_COLOR_OFFSET = 7
;
; Flea sound values
;
FLEA_INACTIVE           = $FF
FLEA_AUDIO_VOLUME       = 15
FLEA_AUDIO_TONE         = 13
;
; Bonus life state values
;
BONUS_LIFE_VALUE_MASK   = %01100000

BONUS_LIFE_ACHIEVED     = 1 << 5
PLAYING_BONUS_LIFE_SOUNDS = 1 << 6
;
; Scorpion sound values
;
SCORPION_AUDIO_VOLUME   = 15
SCORPION_AUDIO_TONE     = 13
;
; Spider sound values
;
SPIDER_AUDIO_VOLUME     = 7
SPIDER_AUDIO_TONE       = 4

MIN_SPIDER_KERNEL_ZONE  = 0
MAX_SPIDER_KERNEL_ZONE  = 7

OBJECT_SHOT_AUDIO_TONE  = 8
;
; Shooter horizontal adjustment values
;
SHOOTER_HORIZ_DIR_MASK  = %11000000
SHOOTER_HORIZ_DELAY_MASK = %00111111
DEMO_SHOOTER_VERT_DIR   = %10000000
DEMO_SHOOTER_HORIZ_DIR  = %01000000

SHOOTER_MOVE_LEFT       = 1 << 7
SHOOTER_MOVE_RIGHT      = 1 << 6

DEMO_SHOOTER_MOVE_UP    = 0 << 7
DEMO_SHOOTER_MOVE_DOWN  = 1 << 7
DEMO_SHOOTER_MOVE_RIGHT = 0 << 6
DEMO_SHOOTER_MOVE_LEFT  = 1 << 6
;
; Kernel Shooter state
;
POSITION_SHOOTER_MASK   = %01000000

POSITION_SHOOTER        = 1 << 6
;
; Shooter collision state values
;
SHOOTER_COLLISION_DELAY_MASK = %01100000
MAX_SHOOTER_COLLISION_DELAY = 3 << 5
SHOOTER_COLLISION_DELAY_INCREMENT = 1 << 5

GS_MUSHROOM_TALLY_MASK  = %01000000
GS_MUSHROOM_TALLY       = 1 << 6

GS_TITLE_SCREEN_PROCESSING = $E0
GS_RESET_WAVE           = $F0

MUSHROOM_TALLY_AUDIO_FREQUENCY = 10
MUSHROOM_TALLY_AUDIO_VOLUME = 255
MUSHROOM_TALLY_AUDIO_TONE = 8
;
; Shooter / Shot audio values
;
SHOT_AUDIO_VOLUME       = 255
SHOT_AUDIO_TONE         = 8

SHOOTER_EXPLOSION_AUDIO_VOLUME = 255
SHOOTER_EXPLOSION_AUDIO_TONE = 8

HEARTBEAT_AUDIO_TONE    = 15

;===============================================================================
; M A C R O S
;===============================================================================

;
; time wasting macros
;

   MAC SLEEP_4
      SLEEP 2
      SLEEP 2
   ENDM
   
   MAC SLEEP_6
      SLEEP_4
      SLEEP 2
   ENDM

   MAC SLEEP_7
      pla
      pha
   ENDM
   
   MAC SLEEP_8
      SLEEP_6
      SLEEP 2
   ENDM

   MAC SLEEP_14
      SLEEP_7
      SLEEP_7
   ENDM

   MAC SLEEP_18
      SLEEP_14
      SLEEP_4
   ENDM
   
   MAC SLEEP_21
      SLEEP_14
      SLEEP_7
   ENDM

   MAC SLEEP_35
      SLEEP_21
      SLEEP_14
   ENDM

   MAC SLEEP_47
      REPEAT 22
         SLEEP 2
      REPEND
      lda tmpLeftPF1Graphics
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

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U TITLE_SCREEN_ZP_VARIABLES
   .org $80

centipedeFineMotion     ds 11
mushroomNUSIZIdx        ds 1
tmpMushroomGraphicIdx   ds 1
;--------------------------------------
tmpCharHolder           = tmpMushroomGraphicIdx
tmpGraphicIdx           ds 1
;--------------------------------------
mushroomSize            = tmpGraphicIdx
titleScreenCycleCount   ds 1

   SEG.U GAME_ZP_VARIABLES
   .org $80

objectHorizMovementIdx  ds MAX_KERNEL_SECTIONS
;--------------------------------------
graphicsPointers        = objectHorizMovementIdx
;--------------------------------------
tmpHundredsValueHolder  = objectHorizMovementIdx + 12
tmpZeroSuppressValue    = objectHorizMovementIdx + 13
kernelZoneAttributes    ds MAX_KERNEL_SECTIONS
;--------------------------------------
centipedeAttributes     = kernelZoneAttributes
spawnNewHeadState       = centipedeAttributes + 9
shooterCollisionState   = kernelZoneAttributes + 15
mushroomTallyState      = kernelZoneAttributes + 16
bonusLifeSoundEngineValues = kernelZoneAttributes + 17
gameState               = kernelZoneAttributes + 18
gameSelection           = kernelZoneAttributes + 19
centipedeBodyKernelZone ds 1
frameCount              ds 1
tmpCentipedeChainEnd    ds 1
;--------------------------------------
tmpSpriteId             = tmpCentipedeChainEnd
;--------------------------------------
tmpGameWave             = tmpSpriteId
;--------------------------------------
tmpLeftPF1Graphics      = tmpGameWave
;--------------------------------------
tmpCentipedeKernelZone  = tmpLeftPF1Graphics
;--------------------------------------
tmpMushroomTallySpriteIdx = tmpCentipedeKernelZone
;--------------------------------------
tmpSpiderSprite         = tmpMushroomTallySpriteIdx
;--------------------------------------
tmpLeadingSegmentKernelZone = tmpSpiderSprite
tmpLeftPF2Graphics      ds 1
;--------------------------------------
tmpShotCentipedeState   = tmpLeftPF2Graphics
;--------------------------------------
tmpCentipedeSegmentKernelZone = tmpShotCentipedeState
;--------------------------------------
tmpKernelEnableBALL     = tmpCentipedeSegmentKernelZone
;--------------------------------------
tmpCentipedeChainIdx    = tmpKernelEnableBALL
tmpRightPF1Graphics     ds 1
;--------------------------------------
tmpShotKernelZone       = tmpRightPF1Graphics
;--------------------------------------
tmpShooterKernelZone    = tmpShotKernelZone
;--------------------------------------
tmpCentipedeState       = tmpShooterKernelZone
;--------------------------------------
tmpSpiderKernelZoneDistance = tmpCentipedeState
;--------------------------------------
tmpFlickerPriorityValue = tmpSpiderKernelZoneDistance
mushroomArray           ds MUSHROOM_ARRAY_SIZE
tmpConflictingObjectIds ds 5
;--------------------------------------
tmpCentipedeAttribute   = tmpConflictingObjectIds
;--------------------------------------
tmpRightPF2Graphics     = tmpCentipedeAttribute + 2
;--------------------------------------
tmpMushroomMaskingBitIndex = tmpRightPF2Graphics
tmpKernelZone           = tmpMushroomMaskingBitIndex + 1
;--------------------------------------
tmpShotCentipedeIndex   = tmpKernelZone

   .org tmpConflictingObjectIds + 4

player0GraphicPtr       ds 2
;--------------------------------------
tmpCentipedeSegmentIndex = player0GraphicPtr
playerShotEnableIndex   ds 1
kernelShooterState      ds 1
centipedeState          ds MAX_CENTIPEDE_SEGMENTS
centipedeHorizPostion   ds MAX_CENTIPEDE_SEGMENTS
;--------------------------------------
mushroomTallyFrameCount = centipedeHorizPostion + 5

mushroomTallyIdx        = centipedeHorizPostion + 7
tmpMushroomTallyMaskingBitIdx = centipedeHorizPostion + 8
gameWaveValues          ds 1
shotHorizPos            ds 1
shooterHorizPos         ds 1
shotVertPos             ds 1
shooterVertPos          ds 1
numberOfCentipedeSegments ds 1
shotMushroomIndex       ds 1
playerScore             ds 3
fleaHorizPos            ds 1
fleaState               ds 1
scorpionHorizPos        ds 1
scorpionState           ds 1
spiderHorizPos          ds 1
;--------------------------------------
shooterExplosionAudioFrequencyValue = spiderHorizPos
spiderState             ds 1
spiderAttributes        ds 1
shooterHorizMovementAdjustment ds 1
;--------------------------------------
demoShooterDirectionValues = shooterHorizMovementAdjustment
selectDebounce          ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E (BANK0)
;===============================================================================

   SEG Bank0
   .org BANK0_BASE
   .rorg BANK0_REORG

Bank0Start
   sta BANK1STROBE

SetupGameDisplayKernel
   sta WSYNC                        ; wait for next scan line
   ldx centipedeBodyKernelZone      ; get Centipede body kernel zone
   ldy objectHorizMovementIdx,x     ; get Centipede horizontal position
   iny
   lda HMOVE_Table,y
   sta HMM0                         ; set missile fine motion value
   and #$0F                         ; keep coarse position value
   tay
.coarsePositionMissile_0
   dey
   bpl .coarsePositionMissile_0
   sta RESM0
   sta WSYNC                        ; wait for next scan line
   ldy objectHorizMovementIdx,x     ; get Centipede horizontal position
   lda HMOVE_Table,y
   sta HMM1 + 256                   ; set missile fine motion value
   and #$0F                         ; keep coarse position value
   tay
   ldx #<[mushroomArray - 1]
   txs
.coarsePositionMissile_1
   dey
   bpl .coarsePositionMissile_1
   sta RESM1
   sta WSYNC                        ; wait for next scan line
   ldy #MAX_KERNEL_SECTIONS - 1
   sty tmpKernelZone
   SLEEP 2
   ldx shotHorizPos                 ; get Shot horizontal position
   lda HMOVE_Table + 1,x
   sta HMBL                         ; set Shot fine motion value
   and #$0F                         ; keep coarse position value
   tay
.coarsePositionShot
   dey
   bpl .coarsePositionShot
   sta RESBL
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   lda gameWaveValues               ; get current game wave values
   clc
   adc #CENTIPEDE_COLOR_OFFSET
   and #7
   tay
   lda WaveColorValues,y
   sta COLUP0                       ; color Centipede segments
   sta COLUP1
   lda #DISABLE_BM
   sta tmpKernelEnableBALL
   sta ENABL
.waitTime
   ldx INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   stx VBLANK                 ; 3         enable TIA (D1 = 0)
   sta HMCLR                  ; 3 = @06   clear all horizontal movements
   ldy #MAX_KERNEL_SECTIONS - 1;2
PlayfieldKernelLoop
   lda kernelZoneAttributes,y ; 4         get kernel zone attribute value
   and #SPRITE_ID_MASK        ; 2         keep SPRITE_ID value
   tax                        ; 2
   stx tmpSpriteId            ; 3
   lda NUSIZValuesPlayer_0,x  ; 4
   sta NUSIZ0                 ; 3 = @26
   lda NUSIZValuesPlayer_1,x  ; 4
   sta NUSIZ1                 ; 3 = @33
   lda objectHorizMovementIdx,y;4         get object horizontal movement index
   tay                        ; 2
   lda HMOVE_Table,y          ; 4         get object's horizontal movement value
   sta HMP0                   ; 3 = @46   set object's fine motion value
   clc                        ; 2
   adc #16                    ; 2         increment fine motion value
   sta HMP1                   ; 3 = @53
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
   cpx #26                    ; 2
   bmi CheckCentipedeObjectKernelZone;2³
   jmp CentipedeBodyKernelZone; 3

GameObjectColorOffsetValues
   .byte FLEA_COLOR_OFFSET, FLEA_COLOR_OFFSET, SPIDER_COLOR_OFFSET
   .byte SPIDER_COLOR_OFFSET, SPIDER_COLOR_OFFSET, SPIDER_COLOR_OFFSET
   .byte SPIDER_COLOR_OFFSET, POINTS_600_COLOR_OFFSET, POINTS_900_COLOR_OFFSET
   .byte 7                          ; not used
   .byte SCORPION_COLOR_OFFSET, SCORPION_COLOR_OFFSET, SCORPION_COLOR_OFFSET
   .byte SCORPION_COLOR_OFFSET
   .byte 3, 3                       ; not used
   .byte 0, 1, 2, 4
   .byte CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET
   .byte CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET
   .byte CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET
   .byte CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET, CENTIPEDE_COLOR_OFFSET

.centipedeBodyAndHeadKernelZone
   jmp CentipedeBodyAndHeadKernelZone;3

CheckCentipedeObjectKernelZone
   cpx #25                    ; 2 = @64
   bpl .centipedeBodyAndHeadKernelZone;2³ branch if Centipede sprite
   lda tmpKernelEnableBALL    ; 3         get value to enable / disable BALL
   sta WSYNC
;--------------------------------------
   sta ENABL                  ; 3 = @03   enable / disable BALL this scan line
   lda GameObjectColorOffsetValues,x;4
   adc gameWaveValues         ; 3
   and #7                     ; 2
   tax                        ; 2
   lda WaveColorValues,x      ; 4
   sta COLUP0                 ; 3 = @21
.coarsePositionObject
   dey                        ; 2
   bpl .coarsePositionObject  ; 2³
   sta RESP0                  ; 3
   ldx shooterHorizPos        ; 3         get Shooter horizontal position
   sta WSYNC
;--------------------------------------
   bit kernelShooterState     ; 3         check to position Shooter
   bvc .drawKernelZoneObjects ; 2³        branch if Shooter already positioned
   lda #[POSITION_SHOOTER - 1]; 2
   sta kernelShooterState     ; 3         set to not position Shooter again
   lda HMOVE_Table + 1,x      ; 4
   sta HMBL                   ; 3 = @17   set Shooter horizontal fine motion
   and #$0F                   ; 2         keep Shooter coarse position value
   tay                        ; 2
.coarsePositionShooter
   dey                        ; 2
   bpl .coarsePositionShooter ; 2³
   sta RESBL                  ; 3
.drawKernelZoneObjects
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx tmpSpriteId + 256      ; 4
   ldy #H_OBJECTS - 1         ; 2
   lda Player0GraphicLSBTable,x;4
   sta player0GraphicPtr      ; 3
   lda #>GameSprites          ; 2
   sta player0GraphicPtr + 1  ; 3
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @29
   dey                        ; 2
   ldx tmpKernelZone          ; 3         get kernel zone value
   lda kernelZoneAttributes,x ; 4
   bpl .colorNormalMushrooms  ; 2³        branch if NORMAL_MUSHROOM_ZONE
   lda frameCount             ; 3         get current frame count
   asl                        ; 2         multiply value by 4
   asl                        ; 2
   ora #$0F                   ; 2         set to max luminance
   sta COLUPF                 ; 3 = @52   color poisonous mushrooms
   jmp .decrementPlayerShotIndex;3

.colorNormalMushrooms
   lda gameWaveValues         ; 3         get current game wave values
   and #7                     ; 2
   tax                        ; 2
   lda WaveColorValues,x      ; 4
   sta COLUPF + 256           ; 4 = @56
.decrementPlayerShotIndex
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_00;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawPlayerShot_00     ; 3 = @76

.prepareToDrawShooter_00
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3 = @73
   stx kernelShooterState     ; 3
.drawPlayerShot_00
;--------------------------------------
   stx ENABL                  ; 3 = @03
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @11
   lda tmpKernelZone          ; 3
   bne .setKernelZoneMushroomGraphics;2³
   sta tmpLeftPF1Graphics     ; 3
   sta tmpLeftPF2Graphics     ; 3
   sta tmpRightPF1Graphics    ; 3
   sta tmpRightPF2Graphics    ; 3
   beq .drawMushroomsKernel   ; 3         unconditional branch

.setKernelZoneMushroomGraphics
   tsx                        ; 2         move mushroom index to x register
   txa                        ; 2
   lsr                        ; 2         divide index by 4 (i.e. H_MUSHROOMS)
   lsr                        ; 2
   bcc .evenKernelSectionMuchrooms;2³
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_RIGHT_PF2_MUSHROOM_MASK;2
   jmp .drawMushroomsKernel   ; 3

.evenKernelSectionMuchrooms
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_RIGHT_PF2_MUSHROOM_MASK;2
.drawMushroomsKernel
   sta tmpRightPF2Graphics    ; 3
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @08
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @14
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @20
   ldx tmpKernelZone + 256    ; 4
   lda kernelZoneAttributes,x ; 4
   and #<~SPRITE_ID_MASK      ; 2         clear SPRITE_ID value
   ora #ID_BLANK_SPRITE       ; 2
   sta kernelZoneAttributes,x ; 4
   lda #0                     ; 2
   sta objectHorizMovementIdx,x;4
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @08
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @14
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @20
   SLEEP_21                   ; 21
   lda tmpRightPF2Graphics + 256;4
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @08
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @14
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @20
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_01;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawPlayerShot_01     ; 3

.prepareToDrawShooter_01
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3 = @37
   stx kernelShooterState     ; 3
.drawPlayerShot_01
   SLEEP 2                    ; 2
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   SLEEP_14                   ; 14
   stx ENABL                  ; 3 = @73
   sta WSYNC
;--------------------------------------
   lda (player0GraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @08
   lda #0                     ; 2
   sta PF1                    ; 3 = @13
   sta PF2                    ; 3 = @16
   sta HMBL                   ; 3 = @19
   SLEEP_6                    ; 6
DecrementPlayerShotIndex
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_02;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .doneKernelZone        ; 3 = @45

.prepareToDrawShooter_02
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3 = @42
   stx kernelShooterState     ; 3
.doneKernelZone
   stx tmpKernelEnableBALL    ; 3
   lda #HMOVE_0               ; 2
   sta HMBL                   ; 3 = @53
   SLEEP_8                    ; 8
   dec tmpKernelZone + 256    ; 6
   sta ENAM0                  ; 3 = @70
   sta GRP1                   ; 3 = @73
   sta GRP0                   ; 3 = @76
;--------------------------------------
   ldy tmpKernelZone          ; 3
   bmi .jmpToScoreKernel      ; 2³
   jmp PlayfieldKernelLoop    ; 3

.jmpToScoreKernel
   jmp ScoreKernel            ; 3

CentipedeBodyAndHeadKernelZone SUBROUTINE
   lda tmpKernelEnableBALL    ; 3
   sta ENABL                  ; 3 = @76
;--------------------------------------
   lda gameWaveValues         ; 3         get current game wave values
   adc #CENTIPEDE_COLOR_OFFSET - 1;2      carry set
   and #7                     ; 2
   tax                        ; 2
   lda WaveColorValues,x      ; 4
   sta COLUP0                 ; 3 = @16
   ldx shooterHorizPos        ; 3
   SLEEP 2                    ; 2
.coarsePositionCentipedeBody
   dey                        ; 2
   bpl .coarsePositionCentipedeBody;2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   bit kernelShooterState     ; 3
   bvc .drawKernelZoneObjects ; 2³
   lda #[POSITION_SHOOTER - 1]; 2
   sta kernelShooterState     ; 3
   lda HMOVE_Table + 1,x      ; 4
   sta HMBL                   ; 3 = @17
   and #$0F                   ; 2
   tay                        ; 2
.coarsePositionShooter
   dey                        ; 2
   bpl .coarsePositionShooter ; 2³
   sta RESBL                  ; 3
.drawKernelZoneObjects
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #H_OBJECTS - 1         ; 2
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @12
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @19
   dey                        ; 2
   ldx tmpKernelZone          ; 3
   lda kernelZoneAttributes,x ; 4
   bpl .colorNormalMushrooms  ; 2³
   lda frameCount             ; 3         get current frame count
   asl                        ; 2         multiply value by 4
   asl                        ; 2
   ora #$0F                   ; 2         set to max luminance
   sta COLUPF                 ; 3 = @42
   jmp .decrementPlayerShotIndex;3

.colorNormalMushrooms
   lda gameWaveValues         ; 3 = @34   get current game wave values
   and #7                     ; 2
   tax                        ; 2
   lda WaveColorValues,x      ; 4
   sta COLUPF + 256           ; 4 = @46
.decrementPlayerShotIndex
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_00;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawPlayerShot_00     ; 3

.prepareToDrawShooter_00
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3
   stx kernelShooterState     ; 3
.drawPlayerShot_00
   sta WSYNC
;--------------------------------------
   stx ENABL                  ; 3 = @03
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @10
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @17
   lda tmpKernelZone          ; 3
   beq .clearMushroomGraphics ; 2³
   tsx                        ; 2
   txa                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   bcc .evenKernelSectionMuchrooms; 2³
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_RIGHT_PF2_MUSHROOM_MASK;2
   jmp .drawMushroomsKernel   ; 3

.clearMushroomGraphics
   sta tmpLeftPF1Graphics     ; 3
   sta tmpLeftPF2Graphics     ; 3
   sta tmpRightPF1Graphics    ; 3
   sta tmpRightPF2Graphics    ; 3
   jmp .drawMushroomsKernel   ; 3

.evenKernelSectionMuchrooms
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_RIGHT_PF2_MUSHROOM_MASK;2
.drawMushroomsKernel
   sta tmpRightPF2Graphics    ; 3
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @14
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @20
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @26
   ldx tmpKernelZone          ; 3
   lda #0                     ; 2
   sta objectHorizMovementIdx,x;4
   SLEEP_7                    ; 7
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @14
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @20
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @26
   lda kernelZoneAttributes,x ; 4
   and #<~SPRITE_ID_MASK      ; 2         clear SPRITE_ID value
   ora #ID_BLANK_SPRITE       ; 2
   sta kernelZoneAttributes,x ; 4
   SLEEP_4
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   lda CentipedeBody_00,y     ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @10
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @16
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @22
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_01;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .doneKernelZone        ; 3

.prepareToDrawShooter_01
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3
   stx kernelShooterState     ; 3
.doneKernelZone
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   SLEEP_14                   ; 14
   stx ENABL                  ; 3 = @71
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   lda CentipedeHead,y        ; 4
   sta GRP1                   ; 3 = @14
   lda #0                     ; 2
   sta PF1                    ; 3 = @19
   sta PF2                    ; 3 = @22
   jmp DecrementPlayerShotIndex;3

CentipedeBodyKernelZone SUBROUTINE
   lda tmpKernelEnableBALL    ; 3
   SLEEP 2                    ; 2
   sta ENABL + 256            ; 4 = @72
   sta WSYNC
;--------------------------------------
   lda gameWaveValues         ; 3         get current game wave values
   adc #CENTIPEDE_COLOR_OFFSET - 1;2      carry set
   and #7                     ; 2
   tax                        ; 2
   lda WaveColorValues,x      ; 4
   sta COLUP0                 ; 3 = @16
   ldx shooterHorizPos        ; 3         get Shooter horizontal position
   SLEEP 2                    ; 2
.coarsePositionCentipedeBody
   dey                        ; 2
   bpl .coarsePositionCentipedeBody;2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   bit kernelShooterState     ; 3
   bvc .drawKernelZoneObjects ; 2³
   lda #[POSITION_SHOOTER - 1]; 2
   sta kernelShooterState     ; 3
   lda HMOVE_Table + 1,x      ; 4
   sta HMBL                   ; 3 = @17
   and #$0F                   ; 2
   tay                        ; 2
.coarsePositionShooter
   dey                        ; 2
   bpl .coarsePositionShooter ; 2³
   sta RESBL                  ; 3
.drawKernelZoneObjects
   ldx #DISABLE_BM            ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy tmpKernelZone          ; 3
   cpy centipedeBodyKernelZone; 3
   bne .drawCentipedeBody     ; 2³
   ldx #ENABLE_BM             ; 2
.drawCentipedeBody
   lda CentipedeBody_00 + H_OBJECTS - 1;4
   sta GRP0                   ; 3 = @20
   stx ENAM0                  ; 3 = @23
   sta GRP1                   ; 3 = @26
   ldy tmpKernelZone          ; 3         get kernel zone value
   lda kernelZoneAttributes,y ; 4         get kernel zone attributes
   bpl .colorNormalMushrooms  ; 2³        branch if NORMAL_MUSHROOM_ZONE
   lda frameCount             ; 3         get current frame count
   asl                        ; 2         multiply value by 4
   asl                        ; 2
   ora #$0F                   ; 2         set to max luminance
   sta COLUPF                 ; 3 = @47
   jmp .decrementPlayerShotIndex;3

.colorNormalMushrooms
   lda gameWaveValues         ; 3         get current game wave values
   and #7                     ; 2
   tay                        ; 2
   lda WaveColorValues,y      ; 4
   sta COLUPF                 ; 3 = @50
.decrementPlayerShotIndex
   ldy playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_00;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,y; 4
   tay                        ; 2
   jmp .drawPlayerShot_00     ; 3

.prepareToDrawShooter_00
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldy #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   sty CTRLPF                 ; 3
   sty kernelShooterState     ; 3
.drawPlayerShot_00
   sta WSYNC
;--------------------------------------
   sty ENABL                  ; 3 = @03
   stx ENAM1                  ; 3 = @06
   lda CentipedeBody_00 + H_OBJECTS - 2;4
   sta GRP0                   ; 3 = @13
   sta GRP1                   ; 3 = @16
   lda tmpKernelZone          ; 3         get kernel zone value
   bne .setKernelZoneMushroomGraphics;2³
   sta tmpLeftPF1Graphics     ; 3
   sta tmpLeftPF2Graphics     ; 3
   sta tmpRightPF1Graphics    ; 3
   sta tmpRightPF2Graphics    ; 3
   beq .drawMushroomsKernel   ; 3         unconditional branch

.setKernelZoneMushroomGraphics
   tsx                        ; 2         move mushroom index to x register
   txa                        ; 2
   lsr                        ; 2         divide index by 4 (i.e. H_MUSHROOMS)
   lsr                        ; 2
   bcc .evenKernelSectionMuchrooms;2³
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #ODD_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #ODD_RIGHT_PF2_MUSHROOM_MASK;2
   jmp .drawMushroomsKernel   ; 3

.evenKernelSectionMuchrooms
   pla                        ; 4         pull left mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_LEFT_PF1_MUSHROOM_MASK;2
   sta tmpLeftPF1Graphics     ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_LEFT_PF2_MUSHROOM_MASK;2
   sta tmpLeftPF2Graphics     ; 3
   pla                        ; 4         pull right mushroom value from stack
   tax                        ; 2         save mushroom value to x register
   and #EVEN_RIGHT_PF1_MUSHROOM_MASK;2
   sta tmpRightPF1Graphics    ; 3
   txa                        ; 2         move mushroom value to accumulator
   and #EVEN_RIGHT_PF2_MUSHROOM_MASK;2
.drawMushroomsKernel
   sta tmpRightPF2Graphics    ; 3
   ldy #H_OBJECTS - 3         ; 2
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @16
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @22
   ldx tmpKernelZone + 256    ; 4
   lda kernelZoneAttributes,x ; 4
   and #<~SPRITE_ID_MASK      ; 2         clear SPRITE_ID value
   ora #ID_BLANK_SPRITE       ; 2
   sta kernelZoneAttributes,x ; 4
   SLEEP_4                    ; 4
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @16
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @22
   lda #0                     ; 2
   sta objectHorizMovementIdx,x;4
   tsx                        ; 2         move mushroom index to x register
   SLEEP 2                    ; 2
   pla                        ; 4
   pla                        ; 4
   txs                        ; 2         restore stack pointer to mushroomArray
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   lda tmpLeftPF1Graphics     ; 3
   sta PF1                    ; 3 = @16
   lda tmpLeftPF2Graphics     ; 3
   sta PF2                    ; 3 = @22
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_01;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .drawPlayerShot_01     ; 3

.prepareToDrawShooter_01
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3 = @39
   stx kernelShooterState     ; 3
.drawPlayerShot_01
   lda tmpRightPF2Graphics    ; 3
   sta PF2                    ; 3 = @48
   lda tmpRightPF1Graphics    ; 3
   sta PF1                    ; 3 = @54
   dey                        ; 2
   SLEEP_14                   ; 14
   stx ENABL                  ; 3 = @73
   sta WSYNC
;--------------------------------------
   ldy #0                     ; 2
   sty ENAM1                  ; 3 = @05
   sty PF1                    ; 3 = @08
   sty PF2                    ; 3 = @11
   lda CentipedeBody_00,y     ; 4
   sta GRP0                   ; 3 = @18
   sta GRP1                   ; 3 = @21
   ldx playerShotEnableIndex  ; 3
   bmi .prepareToDrawShooter_02;2³
   dec playerShotEnableIndex + 256;6
   lda PlayerShotEnableTable,x; 4
   tax                        ; 2
   jmp .doneKernelZone        ; 3

.prepareToDrawShooter_02
   lda kernelShooterState     ; 3
   sta playerShotEnableIndex  ; 3
   ldx #[POSITION_SHOOTER | MSBL_SIZE4 | DISABLE_BM | PF_REFLECT];2
   stx CTRLPF                 ; 3 = @38
   stx kernelShooterState     ; 3
.doneKernelZone
   stx tmpKernelEnableBALL    ; 3
   SLEEP_7                    ; 7
   lda #HMOVE_0               ; 2
   sta HMBL                   ; 3 = @56
   SLEEP_6                    ; 6
   dec tmpKernelZone          ; 5
   sta ENAM0                  ; 3 = @70
   sta GRP0                   ; 3 = @73
   sta GRP1                   ; 3 = @76
;--------------------------------------
   ldy tmpKernelZone          ; 3
   bmi ScoreKernel            ; 2³
   jmp PlayfieldKernelLoop    ; 3

   FILL_BOUNDARY 58, 234

ScoreKernel
   sta GRP0                   ; 3 = @12
   sta GRP1                   ; 3 = @15
   lda #>NumberFonts          ; 2
   sta graphicsPointers + 1   ; 3
   sta graphicsPointers + 3   ; 3
   sta graphicsPointers + 5   ; 3
   sta graphicsPointers + 7   ; 3
   sta graphicsPointers + 9   ; 3
   sta graphicsPointers + 11  ; 3
   ldy #ID_BLANK_FONT         ; 2
   sty tmpZeroSuppressValue   ; 3
   bit gameSelection          ; 3         check current game selection
   bvc .setScoreGraphicPointers;2³        branch if STANDARD_PLAY_GAME
   lda #ID_CHILDREN_ICON      ; 2
   bvs .setHundredThousandsZeroSuppressValue;3 unconditional branch

.setScoreGraphicPointers
   lda playerScore            ; 3         get score thousands value
   lsr                        ; 2         shift upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   bne .setHundredThousandsZeroSuppressValue;2³
   lda #ID_BLANK_FONT         ; 2         suppress leading zero
.setHundredThousandsZeroSuppressValue
   sta tmpZeroSuppressValue   ; 3
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers       ; 3         set digit graphic pointer LSB value
   lda gameWaveValues         ; 3         get current game wave values
   clc                        ; 2
   adc #6                     ; 2
   and #7                     ; 2
   tay                        ; 2         set to score border color index
   lda WaveColorValues,y      ; 4         get color value for score border
   and #$F0                   ; 2         keep color value
   ora #7                     ; 2         set luminance value
   sta COLUPF                 ; 3 = @19
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @24
   sta PF2                    ; 3 = @27
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
   jmp .setOnesBCDToDigitPointerValue;3

   IF ORIGINAL_ROM

      .byte $EA,$C5,$8D,$F0,$02,$A9,$00   ; left over from the prototype ROM
      
   ENDIF

.setOnesBCDToDigitPointerValue
   tay                        ; 2
   lda NumberTable,y          ; 4
   sta graphicsPointers + 8   ; 3
   lda playerScore + 2        ; 3         get score ones value
   and #$0F                   ; 2         keep lower nybbles
   sta WSYNC
;--------------------------------------
   tay                        ; 2
   lda NumberTable,y          ; 4         get graphic LSB value
   sta graphicsPointers + 10  ; 3         set digit graphic pointer LSB value
   ldx #BLACK                 ; 2
   stx COLUPF                 ; 3 = @14
   lda gameWaveValues         ; 3         get current game wave values
   lsr                        ; 2         shift lives to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
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
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bit gameState              ; 3         check current game state
   bvc .setScoreColorsForActiveGame;2³    branch if not selecting game
   lda frameCount             ; 3         used to flash score colors
   jmp .setScoreColors        ; 3

.setScoreColorsForActiveGame
   lda #COLORS_SCORE          ; 2
   sta COLUP0                 ; 3 = @14
.setScoreColors
   sta COLUP0                 ; 3 = @17
   sta COLUP1 + 256           ; 4 = @21
   SLEEP_47                   ; 47
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   lda #COLORS_SCORE          ; 2
   sta COLUPF                 ; 3 = @73
   sta WSYNC
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
   sta WSYNC
;--------------------------------------
   jmp SwitchToOverscan       ; 3

TitleScreenProcessing
   lda #HMOVE_0
   sta centipedeFineMotion
   sta centipedeFineMotion + 5
   sta centipedeFineMotion + 10
   sta frameCount                   ; clear frame count
   sta titleScreenCycleCount        ; reset title screen cycle count
   ldx playerScore                  ; get score thousands value
   cpx #GS_TITLE_SCREEN_PROCESSING
   bne .initTitleScreenCentipedeMotionValues
   sta playerScore
.initTitleScreenCentipedeMotionValues
   lda #HMOVE_L1
   sta centipedeFineMotion + 6
   sta centipedeFineMotion + 9
   lda #HMOVE_L2
   sta centipedeFineMotion + 7
   sta centipedeFineMotion + 8
   lda #HMOVE_R2
   sta centipedeFineMotion + 2
   sta centipedeFineMotion + 3
   lda #HMOVE_R1
   sta centipedeFineMotion + 1
   sta centipedeFineMotion + 4
   lda #COLOR_TITLE_MUSHROOM
   sta COLUP1
TitleScreenKernel SUBROUTINE
   lda #0
.waitTime
   ldx INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   stx VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   SLEEP_21                   ; 21
   sta HMCLR + 256            ; 4 = @28
   lda CentipedeLogoColor + 7 ; 4
   sta COLUP0                 ; 3 = @35
   sta RESP1                  ; 3 = @39   reposition mushroom to pixel 117
   lda frameCount             ; 3         get current frame count
   and #7                     ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @49   reposition centipede to pixel 147
   sta WSYNC
;--------------------------------------
   beq BubbleUpCentipedeFineMotion;2³     bubble up if frame count divisible by 8
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   bne .doneCentipedeFineMotionBubbleUp;3 unconditional branch

BubbleUpCentipedeFineMotion
   ldx centipedeFineMotion    ; 3
   ldy #0                     ; 2
.bubbleUpLoop
   lda centipedeFineMotion + 1,y;4
   sta centipedeFineMotion,y  ; 5
   iny                        ; 2
   cpy #10                    ; 2
   bne .bubbleUpLoop          ; 2³
   stx centipedeFineMotion + 10;3
.doneCentipedeFineMotionBubbleUp
   stx WSYNC
;--------------------------------------
   ldx #H_MUSHROOM_BITMAP     ; 2
   stx mushroomNUSIZIdx       ; 3
   dex                        ; 2
   ldy #H_CENTIPEDE_BITMAP - 1; 2
   lda centipedeFineMotion + 9; 3
   sta HMP0                   ; 3 = @15
   jmp CentipedeLogoKernel    ; 3         could have fallen through

CentipedeLogoKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
.drawLogoLoop
   lda CentipedeLogo,y        ; 4         get Centipede logo graphic data
   sta GRP0                   ; 3 = @10
   lda MushroomSprite,x       ; 4         get Mushroom graphic data
   sta GRP1                   ; 3 = @17
   dey                        ; 2         decrement Centipede logo index
   bmi AtariLogoKernel        ; 2³
   dex                        ; 2         decrement Mushroom sprite index
   bmi .doneDrawMushroomSprite; 2³
   stx tmpMushroomGraphicIdx  ; 3
   ldx mushroomNUSIZIdx       ; 3
   lda MushroomNUSIZTable,x   ; 4         get NUSIZx values for Mushrooms
   sta mushroomSize           ; 3
   ldx tmpMushroomGraphicIdx  ; 3
   lda MushroomColorTable,x   ; 4         read color values for mushroom
   ldx mushroomSize           ; 3
   sta COLUP1                 ; 3 = @51   color mushroom sprite
   stx NUSIZ1                 ; 3 = @54   set NUSIZx value of mushroom
   ldx tmpMushroomGraphicIdx  ; 3
   sta WSYNC
;--------------------------------------
   jmp .drawLogoLoop          ; 3

.doneDrawMushroomSprite
   lda mushroomNUSIZIdx       ; 3 = @29   get the index for the mushroom
   sta RESP1                  ; 3 = @32   reposition mushroom to pixel 96
   tax                        ; 2         move mushroom index to x
   lsr                        ; 2         move D0 of index to carry
   lda centipedeFineMotion,x  ; 4         load HMOVE value for centipede logo
   sta HMP0                   ; 3 = @43   set fine motion of centipede logo
   lda AtariLogoKernel - 20,x ; 4         read code for mushroom fine motion
   sta HMP1                   ; 3 = @50   set fine motion of mushroom sprite
   bcc .setCentipedeLogoColor ; 2³        reposition mushroom on odd indexes
   sta RESP1                  ; 3 = @55   reposition mushroom to pixel 165
.setCentipedeLogoColor
   lda CentipedeLogoColor,x   ; 4
   sta COLUP0                 ; 3         color centipede logo
   dec mushroomNUSIZIdx       ; 5         decrement mushroom index
   ldx #H_MUSHROOM_BITMAP - 1 ; 2
   bne CentipedeLogoKernel    ; 3         unconditional branch

AtariLogoKernel
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   lda #HMOVE_R7              ; 2
   sta HMP0                   ; 3 = @13
   lda #HMOVE_R6              ; 2
   sta HMP1                   ; 3 = @18
   SLEEP_18                   ; 18
   sta RESP0                  ; 3 = @39   set GRP0 to pixel 124
   sta RESP1                  ; 3 = @42   set GPR1 to pixel 132
   ldx #15                    ; 2
.skipLinesForAtariLogo
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .skipLinesForAtariLogo ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @16
   sta VDELP1                 ; 3 = @19
   ldy #H_ATARI_BITMAP - 1    ; 2
   sty tmpGraphicIdx          ; 3
   SLEEP_35                   ; 35

   IF COMPILE_REGION = PAL50

      ldy tmpGraphicIdx + 256 ; 4

   ELSE

      SLEEP 2                 ; 2
      ldy tmpGraphicIdx       ; 3

   ENDIF

.drawAtariLogo
   ldy tmpGraphicIdx          ; 3
   lda AtariLogo_00,y         ; 4
   sta GRP0 + 256             ; 4 = @71
   lda AtariLogo_01,y         ; 4
;--------------------------------------
   sta GRP1                   ; 3 = @02
   lda AtariLogo_02,y         ; 4
   sta GRP0                   ; 3 = @09
   lda AtariLogo_03,y         ; 4
   sta tmpCharHolder          ; 3
   tya                        ; 2         move graphic index to accumulator
   asl                        ; 2         multiply value by 2
   adc frameCount             ; 3         add in frame count for rainbow colors
   sta COLUP0                 ; 3 = @26
   sta COLUP1                 ; 3 = @29
   lda AtariLogo_04,y         ; 4
   ldx AtariLogo_05,y         ; 4
   ldy tmpCharHolder          ; 3
   stx GRP1                   ; 3 = @43
   sty GRP0                   ; 3 = @46
   sta GRP1                   ; 3 = @49
   sta GRP0                   ; 3 = @52
   dec tmpGraphicIdx          ; 5
   bpl .drawAtariLogo         ; 2³
   lda #HMOVE_L1              ; 2
   sta HMP0                   ; 3 = @64
   sta HMP1                   ; 3 = @67
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08   clear the player graphics
   sta GRP1                   ; 3 = @11   GRP0 must be written to twice
   sta GRP0                   ; 3 = @14   because players are VDEL'd
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #H_COPYRIGHT_BITMAP - 1; 2
   sta tmpGraphicIdx          ; 3
.drawCopyright
   ldy tmpGraphicIdx          ; 3
   lda Copyright_00,y         ; 4
   sta GRP0                   ; 3 = @72
   sta WSYNC
;--------------------------------------
   lda Copyright_01,y         ; 4
   sta GRP1                   ; 3 = @07
   lda Copyright_02,y         ; 4
   sta GRP0                   ; 3 = @14
   lda Copyright_03,y         ; 4
   sta tmpCharHolder          ; 3
   tya                        ; 2         waste 2 cycles
   lda #COLORS_SCORE          ; 2
   sta COLUP0                 ; 3 = @28
   sta COLUP1                 ; 3 = @31
   lda Copyright_04,y         ; 4
   ldx Copyright_05,y         ; 4
   ldy tmpCharHolder          ; 3
   stx GRP1                   ; 3 = @45
   sty GRP0                   ; 3 = @48
   sta GRP1                   ; 3 = @51
   sta GRP0                   ; 3 = @54
   dec tmpGraphicIdx          ; 5
   bpl .drawCopyright         ; 2³
   ldx #ONE_COPY              ; 2
   stx NUSIZ0                 ; 3 = @66
   stx NUSIZ1                 ; 3 = @69
   stx GRP0                   ; 3 = @72
   stx GRP1                   ; 3 = @75
;--------------------------------------
   stx GRP0                   ; 3 = @02
   stx VDELP0                 ; 3 = @05
   stx VDELP1                 ; 3 = @08
   sta WSYNC
;--------------------------------------
   bit INPT4                        ; read player's fire button
   bpl .jmpGameScreenOverscan       ; branch if fire button pressed
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET value to carry
   bcc .jmpGameScreenOverscan       ; branch if RESET pressed
   lsr                              ; shift SELECT value to carry
   lda selectDebounce               ; get select debounce value
   bne .incrementTitleScreenFrameCount
   bcc .jmpGameScreenOverscan       ; branch if SELECT pressed
.incrementTitleScreenFrameCount
   inc frameCount                   ; increment frame count
   bne TitleScreenNewFrame          ; branch if not wrapped to 0
   lda selectDebounce
   beq .incrementTitleScreenCycleCount
   dec selectDebounce
.incrementTitleScreenCycleCount
   inc titleScreenCycleCount
   lda titleScreenCycleCount        ; get title screen cycle count
   cmp #MAX_TITLE_SCREEN_CYCLE
   bne TitleScreenNewFrame
.jmpGameScreenOverscan
   jmp SwitchToGameScreenOverscan

TitleScreenNewFrame SUBROUTINE
   lda #TITLE_OVERSCAN_TIME
   sta TIM64T
.waitTime
   lda INTIM
   bne .waitTime
   ldx #START_VERT_SYNC
   stx WSYNC                        ; wait for next scan line
   stx VSYNC                        ; start vertical sync (i.e. D1 = 1)
   stx WSYNC
   stx WSYNC
   stx WSYNC
   stx WSYNC
   ldx #STOP_VERT_SYNC
   stx VSYNC                        ; end vertical sync (i.e. D1 = 0)
   ldx #VBLANK_TIME
   stx TIM64T                       ; set timer for vertical blank period
   jmp TitleScreenKernel

CheckToPlayBonusLifeSound
   bit bonusLifeSoundEngineValues
   bvs .playBonusLifeSounds         ; branch if PLAYING_BONUS_LIFE_SOUNDS
   lda frameCount                   ; get current frame count
   and #$7F                         ; 0 <= a <= 127
   cmp #15
   bne .doneCheckToPlayBonusLifeSound
   lda bonusLifeSoundEngineValues   ; get bonus life sound engine values
   and #BONUS_LIFE_ACHIEVED         ; keep BONUS_LIFE_ACHIEVED value
   beq .doneCheckToPlayBonusLifeSound;branch if no BONUS_LIFE_ACHIEVED
   lda bonusLifeSoundEngineValues   ; get bonus life sound engine values
   ora #PLAYING_BONUS_LIFE_SOUNDS
   sta bonusLifeSoundEngineValues   ; set to PLAYING_BONUS_LIFE_SOUNDS
.playBonusLifeSounds
   lda frameCount                   ; get current frame count
   and #$7F                         ; 0 <= a <= 127
   lsr
   lsr
   lsr                              ; 0 <= a <= 15
   tay
   lda #13
   cpy #10
   bmi .setBonusLifeSoundTone
   lda #4
.setBonusLifeSoundTone
   sta AUDC0
   lda BonusLifeSoundFrequencyValues,y
   sta AUDF0
   lda #15
   sta AUDV0
   lda #0
   sta AUDC1
   sta AUDV1
   sta AUDF1
   lda frameCount                   ; get current frame count
   and #$7F                         ; 0 <= a <= 127
   cmp #127
   bne .doneCheckToPlayBonusLifeSound
   lda bonusLifeSoundEngineValues   ; get bonus life sound engine values
   and #<~BONUS_LIFE_VALUE_MASK     ; clear BONUS_LIFE values
   sta bonusLifeSoundEngineValues
.doneCheckToPlayBonusLifeSound
   lda #PF_REFLECT
   sta CTRLPF                       ; set playerfield to REFLECT
   jmp SetupGameDisplayKernel

BonusLifeSoundFrequencyValues
   .byte 0, 0, 24, 19, 16, 16, 19, 16
   .byte 16, 16, 24, 24, 29, 24, 24, 24

   IF (COMPILE_REGION != PAL50 && ORIGINAL_ROM)

      .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
      .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$A5,$85,$29,$07,$AA,$E6
      .byte $85,$B1,$82,$4C,$0E,$FA,$85,$02,$B1,$80,$85,$1B

   ENDIF

   FILL_BOUNDARY 0, 0

CentipedeLogo
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $4E ; |.X..XXX.|
   .byte $CF ; |XX..XXXX|
   .byte $C3 ; |XX....XX|
   .byte $CF ; |XX..XXXX|
   .byte $4E ; |.X..XXX.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $46 ; |.X...XX.|
   .byte $52 ; |.X.X..X.|
   .byte $D3 ; |XX.X..XX|
   .byte $D3 ; |XX.X..XX|
   .byte $D3 ; |XX.X..XX|
   .byte $46 ; |.X...XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $4E ; |.X..XXX.|
   .byte $CF ; |XX..XXXX|
   .byte $C3 ; |XX....XX|
   .byte $CF ; |XX..XXXX|
   .byte $4E ; |.X..XXX.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $C3 ; |XX....XX|
   .byte $C9 ; |XX..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $D3 ; |XX.X..XX|
   .byte $C3 ; |XX....XX|
   .byte $CB ; |XX..X.XX|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $4E ; |.X..XXX.|
   .byte $CF ; |XX..XXXX|
   .byte $C3 ; |XX....XX|
   .byte $CF ; |XX..XXXX|
   .byte $4E ; |.X..XXX.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $62 ; |.XX...X.|
   .byte $4E ; |.X..XXX.|
   .byte $CF ; |XX..XXXX|
   .byte $CF ; |XX..XXXX|
   .byte $CF ; |XX..XXXX|
   .byte $4E ; |.X..XXX.|
   .byte $62 ; |.XX...X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $5A ; |.X.XX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $99 ; |X..XX..X|
   .byte $81 ; |X......X|
MushroomSprite
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $76 ; |.XXX.XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|

MushroomColorTable

   IF COMPILE_REGION = NTSC

      .byte PURPLE + 6, PURPLE + 6, PURPLE + 2, PURPLE + 6, PURPLE + 6
      .byte PURPLE + 8, PURPLE + 8, PURPLE + 10, PURPLE + 10

   ELSE

      .byte COLBALT_BLUE + 6, COLBALT_BLUE + 6, COLBALT_BLUE + 2
      .byte COLBALT_BLUE + 6, COLBALT_BLUE + 6, COLBALT_BLUE + 8
      .byte COLBALT_BLUE + 8, COLBALT_BLUE + 10, COLBALT_BLUE + 10

   ENDIF

MushroomNUSIZTable
   .byte TWO_WIDE_COPIES,  TWO_WIDE_COPIES, THREE_MED_COPIES, THREE_COPIES
   .byte TWO_WIDE_COPIES,  ONE_COPY       , TWO_WIDE_COPIES,  THREE_MED_COPIES
   .byte THREE_MED_COPIES, TWO_WIDE_COPIES

CentipedeLogoColor

   IF COMPILE_REGION = NTSC

      .byte ULTRAMARINE_BLUE + 15, GREEN + 10, YELLOW + 10, PURPLE + 8, RED + 6
      .byte ULTRAMARINE_BLUE + 8, DK_GREEN + 8, DK_BLUE + 12, BRICK_RED + 10
      .byte RED + 12

   ELSE

      .byte PURPLE + 15, LT_BLUE + 10, BLACK + 26, DK_GREEN + 8, BRICK_RED + 6
      .byte PURPLE + 8, BLUE_2 + 8, TURQUOISE + 12, GREEN + 10, BRICK_RED + 12

   ENDIF

Copyright_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $77 ; |.XXX.XXX|
   .byte $45 ; |.X...X.X|
   .byte $77 ; |.XXX.XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
AtariLogo_00
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
      
         .byte $4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F
         .byte $4F,$4F,$4F,$4F,$4F,$94,$A4,$E4,$94,$94,$94,$E4,$00,$00,$FC,$25
         .byte $27,$26,$E4,$20,$20,$20,$E1,$23,$27,$2D,$F9,$00,$00,$04,$9F,$2C
         .byte $82,$10,$C3,$B3
      
      ELSE
      
         .byte $4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$F7,$85,$88,$A9,$F7,$85
         .byte $89,$A5,$AF,$29,$F0,$4A,$4A,$4A,$4A,$A8,$B9,$91,$F7,$85,$84,$B9
         .byte $96,$FC,$85,$85,$A9,$01,$85,$04,$85,$05,$A0,$04,$85,$02,$A9,$00
         .byte $85,$08,$A9,$0C

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

Copyright_01
   .byte $43 ; |.X....XX|
   .byte $41 ; |.X.....X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $75 ; |.XXX.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $E0 ; |XXX.....|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $43 ; |.X....XX|
AtariLogo_01
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
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
Copyright_02
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $4B ; |.X..X.XX|
   .byte $4A ; |.X..X.X.|
   .byte $6B ; |.XX.X.XX|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $62 ; |.XX...X.|
   .byte $62 ; |.XX...X.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $61 ; |.XX....X|
   .byte $61 ; |.XX....X|
   .byte $61 ; |.XX....X|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
AtariLogo_02
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $C1 ; |XX.....X|
   .byte $C1 ; |XX.....X|
   .byte $E1 ; |XXX....X|
   .byte $E1 ; |XXX....X|
   .byte $E1 ; |XXX....X|
   .byte $F1 ; |XXXX...X|
   .byte $F1 ; |XXXX...X|
   .byte $71 ; |.XXX...X|
   .byte $79 ; |.XXXX..X|
   .byte $79 ; |.XXXX..X|
   .byte $79 ; |.XXXX..X|
   .byte $39 ; |..XXX..X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $1D ; |...XXX.X|
   .byte $1D ; |...XXX.X|
   .byte $1D ; |...XXX.X|
   .byte $1D ; |...XXX.X|
   .byte $1D ; |...XXX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
Copyright_05
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $AB ; |X.X.X.XX|
   .byte $AA ; |X.X.X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $22 ; |..X...X.|
   .byte $27 ; |..X..XXX|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $8C ; |X...XX..|
   .byte $8C ; |X...XX..|
   .byte $88 ; |X...X...|
   .byte $D8 ; |XX.XX...|
   .byte $D8 ; |XX.XX...|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
AtariLogo_05
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
   .byte $E1 ; |XXX....X|
   .byte $E1 ; |XXX....X|
   .byte $E1 ; |XXX....X|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|
   .byte $EC ; |XXX.XX..|

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

         .byte $22,$22,$3E,$22,$22,$14,$C8,$00,$00,$9F,$90,$90,$90,$93,$90,$90
         .byte $90,$FB,$08,$08,$08,$0F,$F8,$BC,$BD,$8D,$3E,$F9,$87

      ELSE

         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$80,$80
         .byte $C0,$C0,$C0,$E0,$E0,$E0,$F0,$F0,$F8,$F8,$FC,$FC,$FE

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

Copyright_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $17 ; |...X.XXX|
   .byte $11 ; |...X...X|
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $17 ; |...X.XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $61 ; |.XX....X|
   .byte $61 ; |.XX....X|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $67 ; |.XX..XXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $67 ; |.XX..XXX|
   .byte $63 ; |.XX...XX|
   .byte $61 ; |.XX....X|
   .byte $63 ; |.XX...XX|
   .byte $77 ; |.XXX.XXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
AtariLogo_03
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7C ; |.XXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
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
Copyright_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $77 ; |.XXX.XXX|
   .byte $54 ; |.X.X.X..|
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $98 ; |X..XX...|
   .byte $98 ; |X..XX...|
   .byte $98 ; |X..XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $98 ; |X..XX...|
   .byte $98 ; |X..XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
AtariLogo_04
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
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

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$02
         .byte $0C,$14,$14,$1C,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00
         .byte $00,$FF,$00,$00,$FF,$00,$00,$FF

      ELSE

         .byte $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
         .byte $16,$F6,$DB,$C0,$AA,$B8,$F2,$F2,$F3,$F4,$F5,$F6,$00,$00,$00,$00
         .byte $18,$3C,$5A,$18,$3C,$18,$99,$BD,$FF,$FF,$DB,$99,$81,$81,$4F,$4F
         .byte $4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F,$4F

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

HMOVE_Table
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
   .byte HMOVE_L1 | 8, HMOVE_0  | 8, HMOVE_R1 | 8, HMOVE_R2 | 8, HMOVE_R3 | 8

   FILL_BOUNDARY 0, 0

GameSprites
FleaSprites
Flea_00
   .byte $A0 ; |X.X.....|
   .byte $50 ; |.X.X....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|
Flea_01
   .byte $28 ; |..X.X...|
   .byte $50 ; |.X.X....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|

ScorpionSprites
ScorpionRight_00
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $8E ; |X...XXX.|
   .byte $9F ; |X..XXXXX|
   .byte $9E ; |X..XXXX.|
   .byte $51 ; |.X.X...X|
ScorpionRight_01
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $4E ; |.X..XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $91 ; |X..X...X|
ScorpionLeft_00
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $FA ; |XXXXX.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $89 ; |X...X..X|
ScorpionLeft_01
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $71 ; |.XXX...X|
   .byte $F9 ; |XXXXX..X|
   .byte $A9 ; |X.X.X..X|
   .byte $8A ; |X...X.X.|

SpiderSprites
Spider_00
   .byte $81 ; |X......X|
   .byte $5A ; |.X.XX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $BD ; |X.XXXX.X|
   .byte $7E ; |.XXXXXX.|
Spider_01
   .byte $99 ; |X..XX..X|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $A5 ; |X.X..X.X|
   .byte $42 ; |.X....X.|
Spider_02
   .byte $7E ; |.XXXXXX.|
   .byte $BD ; |X.XXXX.X|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $5A ; |.X.XX.X.|
   .byte $81 ; |X......X|
Spider_03
   .byte $99 ; |X..XX..X|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $A5 ; |X.X..X.X|
   .byte $42 ; |.X....X.|

PointSprites
_300Points
   .byte $FE ; |XXXXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $6A ; |.XX.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
_600Points
   .byte $FE ; |XXXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EA ; |XXX.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $BE ; |X.XXXXX.|
   .byte $00 ; |........|
_900Points
   .byte $3E ; |..XXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $EA ; |XXX.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|

ExplosionSprites
Explosion_00
   .byte $4A ; |.X..X.X.|
   .byte $90 ; |X..X....|
   .byte $3D ; |..XXXX.X|
   .byte $FE ; |XXXXXXX.|
   .byte $7D ; |.XXXXX.X|
   .byte $BA ; |X.XXX.X.|
Explosion_01
   .byte $11 ; |...X...X|
   .byte $4A ; |.X..X.X.|
   .byte $1C ; |...XXX..|
   .byte $3C ; |..XXXX..|
   .byte $5D ; |.X.XXX.X|
   .byte $AA ; |X.X.X.X.|
Explosion_02
   .byte $10 ; |...X....|
   .byte $4A ; |.X..X.X.|
   .byte $A0 ; |X.X.....|
   .byte $14 ; |...X.X..|
   .byte $55 ; |.X.X.X.X|
   .byte $28 ; |..X.X...|
Explosion_03
   .byte $11 ; |...X...X|
   .byte $4E ; |.X..XXX.|
   .byte $B5 ; |X.XX.X.X|
   .byte $3E ; |..XXXXX.|
   .byte $5D ; |.X.XXX.X|
   .byte $AA ; |X.X.X.X.|

BlankSprite
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

CentipedeSprites
CentipedeHead
   .byte $40 ; |.X......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $40 ; |.X......|
CentipedeBody_00
   .byte $44 ; |.X...X..|
   .byte $EE ; |XXX.XXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $44 ; |.X...X..|
CentipedeBody_01
   .byte $49 ; |.X..X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $ED ; |XXX.XX.X|
   .byte $49 ; |.X..X..X|
CentipedeBody_02
   .byte $22 ; |..X...X.|
   .byte $B7 ; |X.XX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $B7 ; |X.XX.XXX|
   .byte $22 ; |..X...X.|
CentipedeBody_03
   .byte $92 ; |X..X..X.|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $92 ; |X..X..X.|

PlayerShotEnableTable
   .byte DISABLE_BM, ENABLE_BM,  ENABLE_BM,  ENABLE_BM,  DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM | 4, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

         .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$A9,$48,$1A,$88,$98,$58
         .byte $A7,$08,$4E,$95

      ELSE

         .byte $00,$50,$28,$A8,$5E,$1F,$BB,$51,$18,$1C,$0C; Galaxian graphics

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

LivesGraphicsPF1Values
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $A0 ; |X.X.....|
   .byte $A8 ; |X.X.X...|
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

NumberTable
   .byte <zero, <one, <two, <three, <four, <five, <six
   .byte <seven, <eight, <nine, <Blank, <ChildrenIcon

NumberFonts
zero
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
one
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
two
   .byte $FE ; |XXXXXXX.|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $3C ; |..XXXX..|
   .byte $06 ; |.....XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
three
   .byte $FC ; |XXXXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7C ; |.XXXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FC ; |XXXXXX..|
four
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $FE ; |XXXXXXX.|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
five
   .byte $FC ; |XXXXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
six
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $7C ; |.XXXXX..|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
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
   .byte $7C ; |.XXXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|

Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

ChildrenIcon
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $54 ; |.X.X.X..|
   .byte $BA ; |X.XXX.X.|
   .byte $C6 ; |XX...XX.|

Player0GraphicLSBTable
   .byte <Flea_00
   .byte <Flea_01
   .byte <Spider_00
   .byte <Spider_01
   .byte <Spider_02
   .byte <Spider_03
   .byte <_300Points
   .byte <_600Points
   .byte <_900Points
   .byte 0                          ; not used
   .byte <ScorpionRight_00
   .byte <ScorpionLeft_00
   .byte <ScorpionRight_01
   .byte <ScorpionLeft_01
   .byte 0, 0                       ; not used
   .byte <Explosion_00
   .byte <Explosion_01
   .byte <Explosion_02
   .byte <Explosion_03
   .byte 0, 0                       ; not used
   .byte <BlankSprite
   .byte <CentipedeHead
   .byte <CentipedeBody_00

NUSIZValuesPlayer_0
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | TWO_COPIES, MSBL_SIZE2 | TWO_COPIES
   .byte MSBL_SIZE2 | TWO_COPIES, MSBL_SIZE2 | TWO_COPIES

NUSIZValuesPlayer_1
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY, MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY, MSBL_SIZE4 | ONE_COPY
   .byte MSBL_SIZE4 | TWO_COPIES, MSBL_SIZE4 | TWO_COPIES

WaveColorValues

   IF COMPILE_REGION = NTSC
   
      .byte BRICK_RED + 4, BLUE + 4, YELLOW + 8, PURPLE + 6, RED + 4
      .byte COBALT_BLUE + 6, DK_GREEN + 6, DK_BLUE + 8
   
   ELSE
   
      .byte BRICK_RED + 4, BLUE + 4, YELLOW + 8, COLBALT_BLUE + 6, RED + 6
      .byte CYAN + 4, GREEN + 4, BLUE_2 + 8

   ENDIF

   IF ORIGINAL_ROM

      IF COMPILE_REGION = PAL50

         .byte $44,$B4,$D4,$98,$A5,$85,$9C,$A5,$A5,$98,$00,$00,$FF,$A2,$22,$22
         .byte $23,$23,$23,$22,$22,$22,$22,$23,$FF,$00,$C0

      ELSE
      
         .byte $34,$84,$E4
;
; graphics data from Vanguard ROM
;
         .byte $10,$10,$10,$54,$7D,$00,$D3,$93,$95,$95,$95,$99,$D9,$00,$33,$4A
         .byte $4A,$4B,$4A,$4A,$4B,$00,$C4,$40

      ENDIF

   ENDIF

   FILL_BOUNDARY 236, 0

SwitchToGameScreenOverscan
   sta BANK1STROBE
   jmp TitleScreenProcessing

SwitchToOverscan
   sta BANK1STROBE
   jmp CheckToPlayBonusLifeSound

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
   
         .byte $88,$FF,$12,$85
      
      ENDIF
      
   ELSE
      
      FILL_BOUNDARY 248, 0          ; hotspot locations not available for data

      .byte 0, 0
   
   ENDIF
   
   FILL_BOUNDARY 252, 0
   
   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK0"
   
   .word BANK1Start

   IF COMPILE_REGION = PAL50

      .byte $F7,$21

   ELSE   

      .byte $DE,$F4

   ENDIF

;============================================================================
; R O M - C O D E (BANK1)
;============================================================================

   SEG Bank1
   .org BANK1_BASE
   .rorg BANK1_REORG
   
FREE_BYTES SET 0

BANK1Start
   lda #1
   nop
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   lda #0
.clearLoop
   sta WSYNC,x
   dex
   bne .clearLoop
   stx gameWaveValues
   lda #GS_TITLE_SCREEN_PROCESSING
   sta numberOfCentipedeSegments
   sta playerScore
   jmp VerticalSync

StartNewGame
   lda #0
   sta gameState
   lda #[INIT_LIVES << 4 | 0]
   sta gameWaveValues               ; set initial lives and wave
ResetMushroomArray
   ldx #MUSHROOM_ARRAY_SIZE
.setInitialMushroomPatchValues
   lda InitMushroomValues,x
   sta mushroomArray,x
   dex
   bpl .setInitialMushroomPatchValues
   stx fleaHorizPos                 ; set to FLEA_INACTIVE
   stx scorpionHorizPos             ; set to SCORPION_INACTIVE
   inx                              ; x = 0
   stx shotVertPos
   stx AUDV0
   stx playerScore + 2
   stx playerScore + 1
   stx playerScore
ResetGameWave
   lda #SHOOTER_START_X
   sta shooterHorizPos              ; set Shooter initial horizontal position
   lda #SHOOTER_START_Y
   sta shooterVertPos               ; set Shooter initial vertical position
   ldx playerScore                  ; get score thousands value
   lda gameWaveValues               ; get current game wave values
   sec
   sbc #1                           ; reduce wave by 1
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   cpx #4
   bmi .setGameWaveValue            ; branch if score less than 40,000
   and #$0E                         ; 0 <= a <= 14
.setGameWaveValue
   sta tmpGameWave                  ; save game wave value
   lda gameWaveValues               ; get current game wave values
   and #LIVES_MASK                  ; keep number of remaining lives
   ora tmpGameWave                  ; combine with game wave
   sta gameWaveValues               ; set new GAME_LEVEL value
   ldx #MAX_KERNEL_SECTIONS - 2
   lda #ID_BLANK_SPRITE
.clearKernelZoneAttributes
   sta kernelZoneAttributes,x
   dex
   bpl .clearKernelZoneAttributes
   stx spiderState                  ; set to SPIDER_INACTIVE
   inx                              ; x = 0
   stx AUDV0
   stx AUDV1
   lda gameSelection                ; get current game selection
   and #[GAME_SELECTION_MASK | CENTIPEDE_POISONED_MASK]
   ora #ID_BLANK_SPRITE
   sta gameSelection
   lda gameWaveValues               ; get current game wave values
   cmp #1 << 4
   bcs .decrementLives              ; branch if lives remaining
   lda gameState                    ; get current game state
   ora #SELECT_SCREEN               ; set to show SELECT_SCREEN for game over
   sta gameState
   bne SetNumberOfCentipedeSegments ; unconditional branch

.decrementLives
   sec
   sbc #1 << 4
   sta gameWaveValues
   lda #0
   sta shooterHorizMovementAdjustment;clear horizontal movement adjustment
SetNumberOfCentipedeSegments SUBROUTINE
   ldx #MAX_CENTIPEDE_SEGMENTS - 1
   stx numberOfCentipedeSegments
   ldx playerScore                  ; get score thousands value
   lda gameWaveValues               ; get current game wave values
   cpx #4
   bmi .setGameWaveValue            ; branch if score less than 40,000
   ora #1
.setGameWaveValue
   clc
   adc #1                           ; increment level by 1
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   sta tmpGameWave                  ; save game wave value
   lda gameWaveValues               ; get current game wave values
   and #LIVES_MASK                  ; keep number of remaining lives
   ora tmpGameWave                  ; combine with game wave
   sta gameWaveValues               ; set new GAME_LEVEL value
   lda #MAX_LEVEL
   bit gameSelection                ; check current game selection
   bvs .setCentipedeChainEnd        ; branch if EASY_PLAY_GAME
   sec
   sbc gameWaveValues               ; subtract current game wave
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
.setCentipedeChainEnd
   clc
   adc #3                           ; increment game wave difference by 3
   lsr                              ; divide value by 2 (i.e. 1 <= a <= 9)
   sta tmpCentipedeChainEnd
   lda #CENTIPEDE_START_X
   ldy #[CENTIPEDE_BODY_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT | 19]
   ldx #0
.buildCentipedeSegment
   cpx tmpCentipedeChainEnd
   bmi .buildCentipedeBodySegment   ; branch if less than Centipede chain end
   lda InitCentipedeHeadHorizPos,x
   sta centipedeHorizPostion,x      ; set Centipede head horizontal position
   lda InitCentipedeHeadState,x
   sta centipedeState,x             ; set Centipede head state
   lda kernelZoneAttributes,x
   ora #CENTIPEDE_FAST
   sta kernelZoneAttributes,x       ; set Centipede head to CENTIPEDE_FAST
   jmp .buildNextCentipedePart

InitCentipedeHeadHorizPos
   .byte 64, 47, 77, 14, 108, 31, 93, 2, 124

InitCentipedeHeadState
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT  | 19]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_RIGHT | 18]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT  | 18]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_RIGHT | 18]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT  | 18]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_RIGHT | 18]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT  | 19]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_RIGHT | 19]
   .byte [CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT  | 19]

.buildCentipedeBodySegment
   clc
   adc #W_CENTIPEDE_HEAD            ; increment by W_CENTIPEDE_HEAD
   sta centipedeHorizPostion,x      ; set position of Centipede body part
   sty centipedeState,x             ; set initial state of Centipede body part
   lda gameWaveValues               ; get current game wave values
   and #1
   beq .buildFastMovingCentipede    ; branch if even wave
   lda kernelZoneAttributes,x
   and #<~[CENTIPEDE_SPEED_MASK | CENTIPEDE_POISONED_MASK];clear Centipede state
   sta kernelZoneAttributes,x
   bne .buildNextCentipedePart      ; unconditional branch

.buildFastMovingCentipede
   lda kernelZoneAttributes,x
   ora #CENTIPEDE_FAST
   sta kernelZoneAttributes,x
.buildNextCentipedePart
   inx
   lda centipedeHorizPostion - 1,x  ; get Centipede segment horizontal position
   cpx #MAX_CENTIPEDE_SEGMENTS
   bne .buildCentipedeSegment
   lda #[CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT | 19]
   sta centipedeState
   lda spawnNewHeadState            ; get spawn new head state
   and #<~CENTIPEDE_POISONED_MASK
   sta spawnNewHeadState
   jmp SetShooterAndShotKernelValues

VerticalSync
   ldx #[START_VERT_SYNC | DISABLE_TIA]
   stx WSYNC                        ; wait for next scan line
   stx VSYNC                        ; start vertical sync (i.e. D1 = 1)
   stx VBLANK                       ; disable TIA (i.e. D1 = 1)
   stx WSYNC
   stx WSYNC
   stx WSYNC
   ldx #STOP_VERT_SYNC
   stx VSYNC                        ; end vertical sync (i.e. D1 = 0)
   ldx #VBLANK_TIME
   stx TIM64T                       ; set timer for vertical blank period
   lda playerScore                  ; get score thousands value
   cmp #GS_TITLE_SCREEN_PROCESSING
   bne .gameNewFrame
   jmp SwitchToTitleScreenProcessing

.gameNewFrame
   inc frameCount                   ; increment frame count
   bit gameState                    ; check current game state
   bvc .readConsoleSwitches         ; branch if not selecting game
   bit INPT4                        ; read player's fire button
   bpl .jmpToStartNewGame           ; branch if fire button pressed
.readConsoleSwitches
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET into carry
   bcc .jmpToStartNewGame           ; branch if RESET pressed
   lsr                              ; shift SELECT into carry
   lda selectDebounce               ; get select debounce value
   bne .decrementSelectDebounceValue; branch if select debounce not zero
   bcs .decrementSelectDebounceValue; branch if SELECT not pressed
   sta playerScore                  ; clear player's score when SELECT pressed
   sta playerScore + 1
   sta playerScore + 2
   lda #SELECT_DELAY
   sta selectDebounce               ; reset select debounce rate
   lda gameState                    ; get the current game state
   ora #SELECT_SCREEN
   sta gameState                    ; set to show player selecting game
   lda gameSelection                ; get current game selection
   eor #GAME_SELECTION_MASK         ; flip GAME_SELECTION value
   sta gameSelection
   lda gameWaveValues               ; get current game wave values
   and #GAME_WAVE_MASK              ; clear number of remaining lives
   sta gameWaveValues
   bpl .decrementSelectDebounceValue; unconditional branch

.jmpToStartNewGame
   jmp StartNewGame

.decrementSelectDebounceValue
   lda selectDebounce
   beq .incrementShooterCollisionDelay
   dec selectDebounce
.incrementShooterCollisionDelay
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   beq .checkToTallyWaveMushrooms   ; branch if no SHOOTER_COLLISION
   cmp #MAX_SHOOTER_COLLISION_DELAY
   beq StartWaveMushroomTally       ; branch if MAX_SHOOTER_COLLISION_DELAY
   lda frameCount                   ; get current frame count
   and #$1F                         ; 0 <= a <= 31
   bne .checkToTallyWaveMushrooms
   lda #SHOOTER_COLLISION_DELAY_INCREMENT
   clc
   adc shooterCollisionState
   sta shooterCollisionState
   jmp .checkToTallyWaveMushrooms

StartWaveMushroomTally
   lda shooterCollisionState        ; get Shooter collision state
   and #<~SHOOTER_COLLISION_DELAY_MASK
   sta shooterCollisionState        ; clear SHOOTER_COLLISION_DELAY value
   lda mushroomTallyState           ; get Mushroom tally game state value
   ora #GS_MUSHROOM_TALLY
   sta mushroomTallyState           ; set to GS_MUSHROOM_TALLY
   lda #<-2
   sta mushroomTallyIdx
   lda #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
   sta tmpMushroomTallyMaskingBitIdx
   lda #0
   sta mushroomTallyFrameCount
.checkToTallyWaveMushrooms
   bit mushroomTallyState           ; check Mushroom tally game state value
   bvs .performWaveMushroomTally    ; branch if GS_MUSHROOM_TALLY
   jmp CheckToResetGameWave

.performWaveMushroomTally
   sta shotVertPos
   ldy #50
   sty centipedeHorizPostion + 6
   ldy mushroomTallyIdx             ; get Mushroom tally index
   ldx tmpMushroomTallyMaskingBitIdx
   lda mushroomTallyFrameCount      ; get Mushroom tally frame count
   and #3
   bne .incrementMushroomTallyFrameCount
.determineMushroomTallyIndexValues
   dec centipedeHorizPostion + 6
   beq .setMushroomTallyIndex
   iny                              ; increment Mushroom array index
   iny
   txa
   eor #$20
   tax
   cpy #MUSHROOM_ARRAY_SIZE + 2
   bmi .checkForMushroomPresenceForTally
   inx
   ldy #0
   cpx #$10
   bmi .determineTallyMushroomMaskingBitIndex;branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.determineTallyMushroomMaskingBitIndex
   cpx #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
   bne .checkForMushroomPresenceForTally
   jmp .allMushroomsTallied

.turnOffMushroomTallySounds
   lda #0
   sta AUDV0
   sta AUDF0
.setMushroomTallyIndex
   sty mushroomTallyIdx
   stx tmpMushroomTallyMaskingBitIdx
   jmp SetShooterAndShotKernelValues

   IF ORIGINAL_ROM

      iny                              ; never executed
      
   ENDIF

.checkForMushroomPresenceForTally
   lda mushroomArray,y
   and MushroomMaskingBits,x        ; mask Mushroom bit value
   beq .determineMushroomTallyIndexValues;branch if Mushroom not present
   sty mushroomTallyIdx
   stx tmpMushroomTallyMaskingBitIdx
.incrementMushroomTallyFrameCount
   lda mushroomTallyFrameCount
   inc mushroomTallyFrameCount
   and #2
   bne .turnOffMushroomTallySounds
   tya                              ; move Musroom tally index to accumulator
   lsr                              ; divide by 2
   eor #$FF                         ; get 1's complement
   clc
   adc #MAX_KERNEL_SECTIONS
   tay
   txa
   and #%11011111
   asl
   asl
   beq .setMushroomExplosionHorizPosition
   sbc #1
.setMushroomExplosionHorizPosition
   tax
   stx objectHorizMovementIdx,y
   lda mushroomTallyFrameCount      ; get Mushroom tally frame count
   and #3                           ; 0 <= a <= 3
   sta tmpMushroomTallySpriteIdx
   lda kernelZoneAttributes,y
   and #<~SPRITE_ID_MASK            ; clear SPRITE_ID value
   ora #$10
   ora tmpMushroomTallySpriteIdx
   sta kernelZoneAttributes,y
   bit gameState                    ; check current game state
   bvs .setShooterAndShotKernelValues;branch if selecting game
   bit bonusLifeSoundEngineValues
   bvs IncrementScoreForRemainingMushrooms;branch if PLAYING_BONUS_LIFE_SOUNDS
   lda #MUSHROOM_TALLY_AUDIO_TONE
   sta AUDC0
   lda #MUSHROOM_TALLY_AUDIO_FREQUENCY
   sta AUDF0
   lda #MUSHROOM_TALLY_AUDIO_VOLUME
   sta AUDV0
IncrementScoreForRemainingMushrooms
   lda mushroomTallyFrameCount
   and #7
   cmp #1
   bne .setShooterAndShotKernelValues
   sed 
   clc 
   lda #POINTS_REMAINING_MUSHROOMS
   adc playerScore + 2              ; increment score ones value
   sta playerScore + 2              ; set score ones value
   lda #1 - 1
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .doneIncrementScoreForRemainingMushrooms
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .doneIncrementScoreForRemainingMushrooms
   adc #1 << 4
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
.doneIncrementScoreForRemainingMushrooms
   cld
.setShooterAndShotKernelValues
   jmp SetShooterAndShotKernelValues

.allMushroomsTallied
   lda mushroomTallyState           ; get Mushroom tally game state value
   and #<~GS_MUSHROOM_TALLY
   sta mushroomTallyState           ; clear GS_MUSHROOM_TALLY state
   lda #GS_RESET_WAVE
   sta numberOfCentipedeSegments
   bit gameState                    ; check current game state
   bvs .jmpToTitleScreenProcessing  ; branch if selecting game
   jmp SetShooterAndShotKernelValues

.jmpToTitleScreenProcessing
   jmp SwitchToTitleScreenProcessing

CheckToResetGameWave
   ldy #0
   lda #<-1
   sta centipedeBodyKernelZone      ; set Centipede body out of range
   lda numberOfCentipedeSegments    ; get number of remaining Centipede segments
   bpl PlayBackgroundSounds         ; branch if more Centipede segments
   cmp #GS_RESET_WAVE
   bne .checkToResetMushroomArray   ; branch if all Mushrooms not tallied
   jmp ResetGameWave

.checkToResetMushroomArray
   cmp #GS_TITLE_SCREEN_PROCESSING
   bne .setNumberOfCentipedeSegments
   jmp ResetMushroomArray

.setNumberOfCentipedeSegments
   jmp SetNumberOfCentipedeSegments

ShotAudioFrequencyValues
   .byte $00,$00,$01,$01,$02,$02,$03,$04,$05,$06

PlayBackgroundSounds
   bit gameState                    ; check current game state
   bvs CheckToPlayShooterExplosionSounds;branch if selecting game
   bit bonusLifeSoundEngineValues
   bvs CheckToPlayShooterExplosionSounds;branch if PLAYING_BONUS_LIFE_SOUNDS
   lda spiderAttributes             ; get Spider attribute values
   and #OBJECT_SHOT_AUDIO_TIMER_MASK; keep OBJECT_SHOT_AUDIO_TIMER value
   beq .playHeartbeatSounds
   cmp #3 << 2
   beq .clearObjectShotAudioTimer   ; branch if reached maximum timer value
   clc
   lda #1 << 2
   adc spiderAttributes             ; increment OBJECT_SHOT_AUDIO_TIMER
   sta spiderAttributes
   lda #OBJECT_SHOT_AUDIO_TONE
   bne .setBackgroundSoundsAudioValues;unconditional branch

.clearObjectShotAudioTimer
   lda #<~OBJECT_SHOT_AUDIO_TIMER_MASK
   and spiderAttributes
   sta spiderAttributes
   lda #OBJECT_SHOT_AUDIO_TONE
   bne .setBackgroundSoundsAudioValues;unconditional branch

.playHeartbeatSounds
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   bne PlayShotSounds
   lda #HEARTBEAT_AUDIO_TONE
.setBackgroundSoundsAudioValues
   sta AUDF0
   sta AUDC0
   lda #15
   sta AUDV0
   bne CheckToPlayShooterExplosionSounds

PlayShotSounds
   ldx shooterVertPos               ; get Shooter vertical position
   lda ShooterKernelZoneValues,x    ; get Shooter KERNEL_ZONE value
   clc
   adc #H_SHOOTER
   sbc shotVertPos                  ; subtract Shot vertical position
   tay
   ldx #0
   cpy #9
   beq .setShotAudioTone
   bpl .setShotAudioValues
   ldx #SHOT_AUDIO_VOLUME
   lda ShotAudioFrequencyValues,y
   ldy #SHOT_AUDIO_TONE
.setShotAudioTone
   sty AUDC0
.setShotAudioValues
   stx AUDV0
   sta AUDF0
CheckToPlayShooterExplosionSounds
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   beq CentipedeFlickerSortAlgorithm; branch if no SHOOTER_COLLISION
   lda #SPIDER_INACTIVE
   sta spiderState
   sta fleaHorizPos
   sta scorpionHorizPos
   bit gameState                    ; check current game state
   bvs CentipedeFlickerSortAlgorithm; branch if selecting game
   bit bonusLifeSoundEngineValues
   bvs CentipedeFlickerSortAlgorithm; branch if PLAYING_BONUS_LIFE_SOUNDS
   sta AUDV0
   lda #SHOOTER_EXPLOSION_AUDIO_TONE
   sta AUDC0
   lda frameCount                   ; get current frame count
   and #1
   bne .setShooterExplosionAudioFrequency
   inc shooterExplosionAudioFrequencyValue
.setShooterExplosionAudioFrequency
   lda shooterExplosionAudioFrequencyValue
   sta AUDF0
CentipedeFlickerSortAlgorithm
   ldy #0
   sty tmpFlickerPriorityValue
   sty tmpCentipedeChainIdx
   lda centipedeState               ; get Centipede head state
.centipedeFlickerSortAlgorithm
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   sta tmpCentipedeKernelZone
   ldx #0
   sty tmpConflictingObjectIds
.checkReachingEndOfCentipedeSegments
   cpy numberOfCentipedeSegments
   beq .alternateObjectsInSameZone  ; branch if reached end of Centipede chain
   iny                              ; increment Centipede index
   lda centipedeState,y             ; get trailing Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpCentipedeKernelZone
   bne .checkReachingEndOfCentipedeSegments;branch if not same zone
   lda centipedeState,y             ; get trailing Centipede segment state
   bpl .setFlickerSortPriority      ; branch if CENTIPEDE_HEAD_SEGMENT
   lda centipedeState - 1,y         ; get leading Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpCentipedeKernelZone
   beq .checkReachingEndOfCentipedeSegments;branch if leading segment in same zone
.setFlickerSortPriority
   lda tmpFlickerPriorityValue
   ora FlickerPriorityBitValues,y
   sta tmpFlickerPriorityValue
   inx
   sty tmpConflictingObjectIds,x
   bne .checkReachingEndOfCentipedeSegments;unconditional branch
   
.alternateObjectsInSameZone
   cpx #0
   beq .alternateCentipedeObjectForKernel;branch if no Cenetipede zone conflict
   lda frameCount                   ; get current frame count
   cpx #1
   beq .twoCentipedeConflictsInZone ; branch if two Centipede zone conflicts
   cpx #2
   beq .threeCentipedeConflictsInZone;branch if three Centipede zone conflicts
   cpx #3
   beq .fourCentipedeConflictsInZone;branch if four Centipede zone conflicts
   and #$3F                         ; 0 <= a <= 63
   tay
   ldx FiveCentipedeZoneConflictIndexes,y
   bpl .alternateCentipedeObjectForKernel;unconditional branch
   
.twoCentipedeConflictsInZone
   and #1                           ; 0 <= a <= 1
   tax
   bpl .alternateCentipedeObjectForKernel;unconditional branch
   
.threeCentipedeConflictsInZone
   and #$3F                         ; 0 <= a <= 63
   tay
   ldx ThreeCentipedeZoneConflictIndexes,y
   bpl .alternateCentipedeObjectForKernel;unconditional branch
   
.fourCentipedeConflictsInZone
   and #3                           ; 0 <= a <= 3
   tax
.alternateCentipedeObjectForKernel
   ldy tmpConflictingObjectIds,x
   lda centipedeHorizPostion,y      ; get Centipede horizontal position
   ldx tmpCentipedeKernelZone
   sta objectHorizMovementIdx,x     ; set to Centipede horizontal position
   inc centipedeAttributes,x        ; animate Centipede segment
.animateCentipedeChain
   cpy numberOfCentipedeSegments
   beq .checkToMoveCentipedeChain   ; branch if reached end of Centipede chain
   iny                              ; increment Centipede index
   lda centipedeState,y             ; get trailing Centipede segment state
   bpl .checkToMoveCentipedeChain   ; branch if CENTIPEDE_HEAD_SEGMENT
   lda centipedeState,y             ; get trailing Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpCentipedeKernelZone
   bne .checkToMoveCentipedeChain   ; branch if not in trailing segment zone
   inc centipedeAttributes,x        ; animate Centipede segment
   lda centipedeHorizPostion,y      ; get trailing segment horizontal position
   cmp objectHorizMovementIdx,x
   bcs .animateCentipedeChain       ; branch if to the right of object
   sta objectHorizMovementIdx,x
   bcc .animateCentipedeChain       ; unconditional branch

.checkToMoveCentipedeChain
   lda kernelZoneAttributes,x       ; get kernel zone attributes
   and #SPRITE_ID_MASK              ; keep SPRITE_ID value
   cmp #26
   bmi .processNextCentipedeChain   ; branch if not Centipede chain
   and #1
   beq .processNextCentipedeChain
   stx centipedeBodyKernelZone
   lda objectHorizMovementIdx,x
   clc
   adc #W_CENTIPEDE_HEAD
   sta objectHorizMovementIdx,x
.processNextCentipedeChain
   ldy tmpCentipedeChainIdx
   cpy numberOfCentipedeSegments
   beq MoveSpider                   ; branch if reached end of Centipede chain
   iny                              ; increment Centipede index
   sty tmpCentipedeChainIdx
   lda tmpFlickerPriorityValue
   and FlickerPriorityBitValues,y
   bne .processNextCentipedeChain
   lda centipedeState,y             ; get Centipede segment state
   bpl .nextCentipedeChainGroup     ; branch if CENTIPEDE_HEAD_SEGMENT
   lda centipedeState,y             ; get Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   sta tmpCentipedeKernelZone
   lda centipedeState - 1,y         ; get leading Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpCentipedeKernelZone
   beq .processNextCentipedeChain
.nextCentipedeChainGroup
   lda centipedeState,y             ; get Centipede segment state
   jmp .centipedeFlickerSortAlgorithm

.inactivateSpider
   lda #SPIDER_INACTIVE
   sta spiderState
   jmp TurnOffSoundChannel_01

.changeSpiderVerticalDirection
   lda spiderState                  ; get current Spider state
   eor #SPIDER_VERT_DIR_MASK        ; flip SPIDER_VERT_DIR value
.setSpiderVerticalDirection
   sta spiderState
   lda spiderAttributes             ; get Spider attribute values
   and #<~SPIDER_HORIZ_MOVE_MASK    ; clear SPIDER_HORIZ_MOVE value
   sta spiderAttributes
   adc centipedeHorizPostion
   adc centipedeState + 1
   adc INTIM                        ; increment by RIOT timer value
   and #SPIDER_HORIZ_MOVE_MASK
   ora spiderAttributes
   sta spiderAttributes
   jmp .changeSpiderVerticalPosition

.setSpiderDirectionToUp
   lda spiderState                  ; get current Spider state
   and #<~SPIDER_DIR_DOWN           ; clear SPIDER_DIR_VALUE
   jmp .setSpiderVerticalDirection

.setSpiderDirectionToDown
   lda spiderState                  ; get current Spider state
   ora #SPIDER_DIR_DOWN
   bne .setSpiderVerticalDirection  ; unconditional branch

MoveSpider
   lda #0
   sta tmpConflictingObjectIds
   sta tmpConflictingObjectIds + 1
   lda spiderState                  ; get current Spider state
   cmp #SPIDER_INACTIVE
   beq CheckToLaunchSpider          ; branch if SPIDER_INACTIVE
   bit spiderAttributes             ; check Spider attribute values
   bvs .showSpiderPointValue        ; branch if showing Spider point value
   bmi .showSpiderPointValue        ; branch if showing Spider point value
   lda frameCount                   ; get current frame count
   and #7
   cmp #2
   beq .animateSpider
   cmp #4
   beq .animateSpider
   lda spiderHorizPos               ; get Spider horizontal position
   cmp #XMAX - [W_SPIDER - 1]
   beq .inactivateSpider
   cmp #XMIN
   beq .inactivateSpider
   lda spiderAttributes             ; get Spider attribute values
   and #SPIDER_HORIZ_MOVE_MASK      ; keep SPIDER_HORIZ_MOVE value
   beq .checkToMoveSpiderVertically ; branch if SPIDER_NO_HORIZ_MOVE
   lda spiderAttributes             ; get Spider attribute values
   and #SPIDER_SPEED_MASK           ; keep SPIDER_SPEED value
   and frameCount
   bne .checkToMoveSpiderVertically
   bit spiderState                  ; check current Spider state
   bmi .incrementSpiderHorizontalPosition;branch if SPIDER_DIR_RIGHT
   dec spiderHorizPos
   jmp .checkToMoveSpiderVertically

.incrementSpiderHorizontalPosition
   inc spiderHorizPos
.checkToMoveSpiderVertically
   lda frameCount                   ; get current frame count
   and #3
   bne .animateSpider
   lda spiderAttributes             ; get Spider attribute values
   and #SPIDER_SPEED_MASK           ; keep SPIDER_SPEED value
   beq .moveSpiderVertically        ; branch if SPIDER_FAST
   lda frameCount                   ; get current frame count
   and #4
   bne .animateSpider
.moveSpiderVertically
   lda spiderState                  ; set Spider state value
   and #KERNEL_ZONE_MASK            ; keep Spider kernel zone value
   beq .setSpiderDirectionToUp      ; branch if in MIN_SPIDER_KERNEL_ZONE
   cmp #MAX_SPIDER_KERNEL_ZONE
   beq .setSpiderDirectionToDown
   adc centipedeHorizPostion + 1    ; get a psuedo random number
   adc shotVertPos
   and #%10101011
   bne .changeSpiderVerticalPosition
   jmp .changeSpiderVerticalDirection

.showSpiderPointValue
   jmp ShowSpiderPointValue

.animateSpider
   jmp AnimateSpider

CheckToLaunchSpider
   lda frameCount                   ; get current frame count
   cmp #55
   bne .doneCheckToLaunchSpider
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   bne .doneCheckToLaunchSpider     ; branch if SHOOTER_COLLISION
   ldx #0
   lda playerScore                  ; get score thousands value
   bne .launchSpider
   lda playerScore + 1              ; get score hundreds value
   cmp #$50
   bpl .launchSpider                ; branch if greater than 4,999
   inx                              ; increment for SPIDER_SLOW
.launchSpider
   txa
   ora #SPIDER_HORIZ_MOVE
   sta spiderAttributes
   lda INTIM                        ; get RIOT timer value
   adc shooterHorizPos
   and #4
   beq .launchSpiderFromRight
   lda #XMIN + 1
   sta spiderHorizPos
   lda #[SPIDER_DIR_RIGHT | SPIDER_DIR_DOWN | $20 | 6]
   sta spiderState
.doneCheckToLaunchSpider
   jmp TurnOffSoundChannel_01

.launchSpiderFromRight
   lda #XMAX - W_SPIDER
   sta spiderHorizPos
   lda #[SPIDER_DIR_LEFT | SPIDER_DIR_DOWN | 6]
   sta spiderState
   jmp TurnOffSoundChannel_01

.changeSpiderVerticalPosition
   bit spiderState                  ; check current Spider state
   bvc .moveSpiderUp                ; branch if SPIDER_DIR_UP
   dec spiderState
   jmp AnimateSpider

.moveSpiderUp
   inc spiderState
   jmp AnimateSpider

ShowSpiderPointValue
   lda spiderState                  ; get current Spider state
   and #KERNEL_ZONE_MASK            ; keep Spider KERNEL_ZONE value
   tay
   lda kernelZoneAttributes,y       ; get zone attribute value for Spider zone
   and #SPRITE_ID_MASK              ; keep SPRITE_ID value
   cmp #ID_BLANK_SPRITE
   beq .setSpiderPointValueSprite
   lda frameCount                   ; get current frame count
   lsr
   bcs TurnOffSoundChannel_01       ; branch if odd frame
.setSpiderPointValueSprite
   lda spiderAttributes             ; get Spider attribute values
   and #SPIDER_POINTS_MASK          ; keep SPIDER_POINTS value
   clc
   rol
   rol
   rol
   adc #ID_POINTS_300 - 1
   sta tmpSpriteId
   lda kernelZoneAttributes,y       ; get zone attribute value for Spider zone
   and #<~SPRITE_ID_MASK            ; clear SPRITE_ID value
   ora tmpSpriteId
   sta kernelZoneAttributes,y
   ldx spiderHorizPos
   stx objectHorizMovementIdx,y
   lda frameCount                   ; get current frame count
   and #$0F
   bne TurnOffSoundChannel_01
   lda spiderAttributes             ; get Spider attribute values
   adc #1 << 4
   sta spiderAttributes
   and #SPIDER_POINTS_TIMER_MASK    ; keep SPIDER_POINTS_TIMER value
   bne TurnOffSoundChannel_01
   lda #SPIDER_INACTIVE
   sta spiderState
   lda #0
   sta spiderAttributes
   beq TurnOffSoundChannel_01       ; unconditional branch

SpiderAudioFrequenceValues
   .byte $1E,$1B,$12,$00,$12,$1B,$1E,$1B,$12,$00,$1E,$1B,$12,$00,$12,$1B

AnimateSpider
   lda spiderState                  ; get current Spider state
   and #KERNEL_ZONE_MASK            ; keep Spider KERNEL_ZONE value
   tay                              ; move Spider KERNEL_ZONE to y register
   lda frameCount                   ; get current frame count
   and #$18
   lsr
   lsr
   lsr
   adc #ID_SPIDER
   sta tmpSpiderSprite
   lda kernelZoneAttributes,y       ; get zone attribute value for Spider zone
   and #<~SPRITE_ID_MASK            ; clear SPRITE_ID value
   ora tmpSpiderSprite
   sta kernelZoneAttributes,y       ; set SPRITE_ID to animate Spider
   ldx spiderHorizPos
   stx objectHorizMovementIdx,y     ; set Spider horizontal position
   bit gameState                    ; check current game state
   bvs TurnOffSoundChannel_01       ; branch if selecting game
   bit bonusLifeSoundEngineValues
   bvs TurnOffSoundChannel_01       ; branch if PLAYING_BONUS_LIFE_SOUNDS
   lda #SPIDER_AUDIO_TONE
   sta AUDC1
   lda frameCount                   ; get current frame count
   and #$3F                         ; 0 <= a <= 63
   lsr
   lsr                              ; 0 <= a <= 15
   tay
   lda SpiderAudioFrequenceValues,y
   sta AUDF1
   lda #SPIDER_AUDIO_VOLUME
   bpl .setSpiderSoundVolume        ; unconditional branch
   
TurnOffSoundChannel_01
   lda #0
.setSpiderSoundVolume
   sta AUDV1
   lda fleaHorizPos                 ; get Flea horizontal position
   bpl MoveFlea                     ; branch if FLEA_ACTIVE
   jmp CheckToLaunchFlea

MoveFlea
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   beq .moveFleaDown
   cmp #5
   beq .moveFleaDown
   cmp #10
   beq .moveFleaDown
   and #3
   bne AnimateFlea
   lda playerScore                  ; get score thousands value
   cmp #6
   bpl .moveFleaDown                ; branch if greater than 59,999
   bit fleaState
   bvc AnimateFlea                  ; branch if FLEA_STATE_NORMAL
.moveFleaDown
   dec fleaState                    ; decrement Flea kernel section
   lda fleaState                    ; get current Flea state
   and #$1E
   cmp #$1E
   bne GenerateMushroomFromFlea
   ldx #FLEA_INACTIVE
   stx fleaHorizPos
   inx
   stx fleaState
   beq .donePlayFleaSounds          ; unconditional branch
   
GenerateMushroomFromFlea
   adc mushroomArray
   adc mushroomArray + 13
   adc mushroomArray + 8
   adc fleaState
   tay
   lda TurnOffSoundChannel_01,y     ; get random byte code value
   bmi AnimateFlea
   lda fleaHorizPos                 ; get Flea horizontal position
   lsr
   lsr                              ; divide value by 4
   tay
   lda fleaState                    ; get current Flea state
   lsr
   tya
   bcs .setMushroomMaskingBitIndex  ; branch if an odd scan line
   adc #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
.setMushroomMaskingBitIndex
   tax
   lda #MAX_KERNEL_SECTIONS - 1
   sec
   sbc fleaState                    ; subtract Flea kernel zone
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE difference
   asl                              ; multiply by 2 for Mushroom array index
   tay
   txa                              ; move Mushroom masking index to accumulator
   and #$10
   beq .setMushroomFromFlea         ; branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.setMushroomFromFlea
   lda mushroomArray,y
   ora MushroomMaskingBits,x        ; set Mushroom bit value
   sta mushroomArray,y
AnimateFlea
   lda fleaState                    ; get current Flea state
   and #KERNEL_ZONE_MASK            ; keep Flea kernel zone
   tay
   lda kernelZoneAttributes,y       ; get kernel zone attribute values
   and #<~SPRITE_ID_MASK            ; clear SPRITE_ID value
   tax                              ; move kernel zone value to x register
   lda frameCount                   ; get current frame count
   and #2
   bne CheckToPlayFleaSounds
   inx                              ; increment to animate Flea sprite
CheckToPlayFleaSounds
   stx kernelZoneAttributes,y
   ldx fleaHorizPos                 ; get Flea horizontal position
   stx objectHorizMovementIdx,y     ; set position for kernel
   lda frameCount                   ; get current frame count
   and #1
   beq .donePlayFleaSounds          ; branch if even frame
   bit gameState                    ; check current game state
   bvs .donePlayFleaSounds          ; branch if selecting game
   bit bonusLifeSoundEngineValues
   bvs .donePlayFleaSounds          ; branch if PLAYING_BONUS_LIFE_SOUNDS
   lda fleaState                    ; get current Flea state
   eor #$FF                         ; flip bits
   sta AUDF1                        ; set audio frequency for Flea
   lda #FLEA_AUDIO_VOLUME
   sta AUDV1
   lda #FLEA_AUDIO_TONE
   sta AUDC1
.donePlayFleaSounds
   jmp CheckToAnimateShooterExplosion

CheckToLaunchFlea
   bit fleaState                    ; check Flea state
   bmi .checkToLaunchFlea           ; branch if FLEA_INACTIVE
   lda frameCount                   ; get current frame count
   cmp #41
   bne ProcessScorpion
.checkToLaunchFlea
   lda INTIM                        ; get RIOT timer value
   cmp #19
   bmi .doneCheckToLaunchFlea
   lda scorpionHorizPos             ; get Scorpion horizontal position
   cmp #SCORPION_INACTIVE
   bne ProcessScorpion              ; branch if SCORPION_ACTIVE
   lda gameWaveValues               ; get current game wave values
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   beq ProcessScorpion              ; branch if not Flea wave
   ldx #15
   lda #XMIN
   sta scorpionHorizPos
.determineFleaHorizontalPosition
   lda mushroomArray + 22,x
   lsr
   tay
   lda InitFleaHorizontalAdjustmentValues,y
   adc scorpionHorizPos
   sta scorpionHorizPos
   dex
   bpl .determineFleaHorizontalPosition
   stx scorpionHorizPos             ; set to SCORPION_INACTIVE
   cmp #5
   bmi .setFleaHorizontalPosition   ; branch if less than 5
   cmp #10
   bpl .dontLaunchFlea              ; branch if greater than 10
   lda playerScore                  ; get score thousands value
   cmp #$12
   bpl .setFleaHorizontalPosition   ; branch if greater than 120,000
.dontLaunchFlea
   lda #[FLEA_STATE_ANGRY | $20 | 31]
   sta fleaState
.doneCheckToLaunchFlea
   jmp CheckToAnimateShooterExplosion

.setFleaHorizontalPosition
   adc shooterHorizPos
   adc mushroomArray + 7
   adc centipedeState
   adc spiderState
   and #$1F                         ; 0 <= a <= 31
   asl
   asl
   sta fleaHorizPos                 ; 0 <= a <= 124
   lda #MAX_KERNEL_SECTIONS - 1
   sta fleaState
   jmp CheckToAnimateShooterExplosion

ProcessScorpion
   lda scorpionHorizPos             ; get Scorpion horizontal position
   cmp #SCORPION_INACTIVE
   bne .moveScorpion                ; branch if SCORPION_ACTIVE
   jmp LaunchScorpion

.moveScorpion
   bit scorpionState                ; check Scorpion direction
   bpl .scorpionTravelingRight      ; branch if SCORPION_DIR_RIGHT
   bvc .moveScorpionLeft            ; branch if SCORPION_SLOW
   dec scorpionHorizPos
.moveScorpionLeft
   dec scorpionHorizPos
   bpl AnimateScorpion              ; branch if Scorpion still visible
.scorpionReachedEdge
   lda #SCORPION_INACTIVE
   sta scorpionHorizPos
   lda #MAX_KERNEL_SECTIONS - 1
   sec
   sbc scorpionState                ; subtract Scorpion kernel zone
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE difference
   asl                              ; multiply by 2 for Mushroom array index
   tay
   lda mushroomArray,y              ; get left Mushroom array for Scorpion zone
   bne .setMushroomsToPoisoned      ; branch if Mushrooms remaining
   lda mushroomArray + 1,y          ; get right Mushroom array for Scorpion zone
   beq .doneMoveScorpion            ; branch if no Mushrooms in Scorpion zone
.setMushroomsToPoisoned
   lda scorpionState                ; get current Scorpion state
   and #KERNEL_ZONE_MASK            ; keep Scorpion kernel zone value
   tax
   lda kernelZoneAttributes,x
   ora #POISON_MUSHROOM_ZONE
   sta kernelZoneAttributes,x
.doneMoveScorpion
   jmp CheckToAnimateShooterExplosion

.scorpionTravelingRight
   bvc .moveScorpionRight           ; branch if SCORPION_SLOW
   inc scorpionHorizPos
.moveScorpionRight
   inc scorpionHorizPos
   cmp #XMAX - [W_SCORPION + 1]
   bpl .scorpionReachedEdge         ; branch if Scorpion reached right edge
AnimateScorpion
   ldx #ID_SCORPION
   lda scorpionState                ; get current Scorpion state
   bpl .animateScorpion             ; branch if SCORPION_DIR_RIGHT
   inx
.animateScorpion
   and #KERNEL_ZONE_MASK            ; keep Scorpion KERNEL_ZONE value
   tay
   lda frameCount                   ; get current frame count
   and #8
   beq .setScorpionSprite
   inx
   inx
.setScorpionSprite
   lda kernelZoneAttributes,y       ; get zone attribute value for Scorpion zone
   and #<~SPRITE_ID_MASK
   sta kernelZoneAttributes,y
   txa                              ; move Scorpion SPRITE_ID to accumulator
   ora kernelZoneAttributes,y
   sta kernelZoneAttributes,y       ; set Scorpion SPRITE_ID
   ldx scorpionHorizPos
   stx objectHorizMovementIdx,y
   bit gameState                    ; check current game state
   bvs .doneAnimateScorpion         ; branch if selecting game
   bit gameState                    ; check game state again -- why???
   bvs .doneAnimateScorpion
   lda frameCount                   ; get current frame count
   lsr
   bcc .doneAnimateScorpion         ; branch if even frame
   and #7
   tay
   lda ScorpionAudioFrequencyValues,y
   sta AUDF1
   lda #SCORPION_AUDIO_TONE
   sta AUDC1
   lda #SCORPION_AUDIO_VOLUME
   sta AUDV1
.doneAnimateScorpion
   jmp CheckToAnimateShooterExplosion

ScorpionAudioFrequencyValues
   .byte $0C,$14,$0C,$14,$0A,$18,$0A,$18

LaunchScorpion
   lda frameCount                   ; get current frame count
   cmp #147
   bne CheckToAnimateShooterExplosion
   lda gameWaveValues               ; get current game wave values
   and #GAME_WAVE_MASK              ; keep GAME_WAVE value
   cmp #3
   bmi CheckToAnimateShooterExplosion;branch if less than 3
   lda mushroomArray + 4
   adc centipedeState
   adc centipedeHorizPostion
   adc spiderHorizPos
   and #3
   bne CheckToAnimateShooterExplosion
   lda centipedeHorizPostion + 1
   adc centipedeState + 2
   adc playerScore + 2              ; increment by score ones value
   adc mushroomArray + 6
   and #$1F                         ; 0 <= a <= 31
   tay
   lda playerScore                  ; get score thousands value
   cmp #2
   bmi .initSlowMovingScorpion      ; branch if less than 20,000
   tya
   and #3
   beq .initSlowMovingScorpion
   lda #SCORPION_FAST               ; initialize a SCORPION_FAST Scorpion
.initSlowMovingScorpion
   ora InitialScorpionStateValues,y
   sta scorpionState
   bmi .initScorpionForTravelingLeft; branch if SCORPION_DIR_LEFT
   lda #XMIN
   sta scorpionHorizPos
   beq CheckToAnimateShooterExplosion;unconditional branch

InitialScorpionStateValues
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 9]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 10]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 11]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 12]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 13]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 14]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 15]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 16]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 17]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 18]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 19]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 9]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 10]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 11]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 12]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 13]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 14]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 10]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 9]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 15]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 16]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 17]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 18]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 19]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 19]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 18]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 17]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 16]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 9]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 8]
   .byte [SCORPION_DIR_LEFT  | SCORPION_SLOW | 10]
   .byte [SCORPION_DIR_RIGHT | SCORPION_SLOW | 18]

.initScorpionForTravelingLeft
   lda #XMAX - [W_SCORPION + 1]
   sta scorpionHorizPos
CheckToAnimateShooterExplosion
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   beq MoveShooter                  ; branch if no SHOOTER_COLLISION
   ldy shooterVertPos               ; get Shooter vertical position
   lda ShooterKernelZoneValues,y    ; get Shooter KERNEL_ZONE value
   eor #$FF                         ; get 1's complement
   clc
   adc #MAX_KERNEL_SECTIONS - 1
   tay                              ; set to Shooter kernel zone
   lda frameCount                   ; get current frame count
   lsr
   lsr
   and #3
   clc
   adc #ID_EXPLOSION
   sta kernelZoneAttributes,y       ; set Shoorter explosion SPRITE_ID
   lda shooterHorizPos              ; get Shooter horizontal position
   sec
   sbc #4
   bpl .setExplosionHorizontalPosition
   lda #XMIN
.setExplosionHorizontalPosition
   sta objectHorizMovementIdx,y
   lda #97
   sta playerShotEnableIndex
   sta kernelShooterState
   jmp SwitchToCheckToPlayBonusLifeSound

MoveShooter
   bit gameState                    ; check current game state
   bvc ReadJoystickValues           ; branch if not selecting game
   jmp MoveShooterForDemoMode

ReadJoystickValues
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
   bpl .joystickMovedRight
   asl                              ; shift left joystick value to D7
   bpl .joystickMovedLeft
   lda shooterHorizPos              ; get Shooter horizontal position
   and #3
   beq .clearShooterHorizontalAdjustment
   lda shooterHorizMovementAdjustment;get Shooter horizontal movement adjustment
   and #SHOOTER_HORIZ_DIR_MASK      ; keep SHOOTER_HORIZ_DELAY value
   sta shooterHorizMovementAdjustment
   bmi .driftShooterLeft            ; branch if SHOOTER_MOVE_LEFT
   bpl .driftShooterRight           ; unconditional branch

.clearShooterHorizontalAdjustment
   lda #0
   sta shooterHorizMovementAdjustment;clear horizontal movement adjustment
   beq .checkShooterHorizontalBoundaries;unconditional branch

.joystickMovedLeft
   lda frameCount                   ; get current frame count
   and #7
   bne .moveShooterLeft
   lda shooterHorizMovementAdjustment;get Shooter horizontal movement adjustment
   bmi .checkToMoveShooterLeft      ; branch if SHOOTER_MOVE_LEFT
   lda #SHOOTER_MOVE_LEFT
   sta shooterHorizMovementAdjustment
.checkToMoveShooterLeft
   and #SHOOTER_HORIZ_DELAY_MASK    ; keep SHOOTER_HORIZ_DELAY value
   cmp #3
   beq .moveShooterLeft
.driftShooterLeft
   inc shooterHorizMovementAdjustment
.moveShooterLeft
   lda shooterHorizMovementAdjustment;get Shooter horizontal movement adjustment
   and #SHOOTER_HORIZ_DELAY_MASK    ; keep SHOOTER_HORIZ_DELAY value
   eor #$FF
   clc
   adc #1                           ; negate value
   clc
   adc shooterHorizPos              ; adjust Shooter horizontal position
   sta shooterHorizPos
   jmp .checkShooterHorizontalBoundaries

.joystickMovedRight
   lda frameCount                   ; get current frame count
   and #7
   bne .moveShooterRight
   lda shooterHorizMovementAdjustment;get Shooter horizontal movement adjustment
   bit shooterHorizMovementAdjustment
   bvs .checkToMoveShooterRight     ; branch if SHOOTER_MOVE_RIGHT
   lda #SHOOTER_MOVE_RIGHT
   sta shooterHorizMovementAdjustment
.checkToMoveShooterRight
   and #SHOOTER_HORIZ_DELAY_MASK    ; keep SHOOTER_HORIZ_DELAY value
   cmp #3
   beq .moveShooterRight
.driftShooterRight
   inc shooterHorizMovementAdjustment
.moveShooterRight
   lda shooterHorizMovementAdjustment;get Shooter horizontal movement adjustment
   and #SHOOTER_HORIZ_DELAY_MASK    ; keep SHOOTER_HORIZ_DELAY value
   clc
   adc shooterHorizPos              ; adjust Shooter horizontal position
   sta shooterHorizPos
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

MoveShooterForDemoMode SUBROUTINE
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
   cmp #SHOOTER_YMIN
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
   bne .checkToLaunchShotForDemo    ; unconditional branch

.moveShooterRight
   inc shooterHorizPos
.checkToLaunchShotForDemo
   lda shotVertPos                  ; get Shot vertical position
   bne .moveShotUp                  ; branch if SHOT_ACTIVE
   beq .launchPlayerShot
   
CheckToLaunchPlayerShot
   lda shotVertPos                  ; get Shot vertical position
   bne .moveShotUp                  ; branch if SHOT_ACTIVE
   lda INPT4                        ; read player's fire button
   bmi SetShooterAndShotKernelValues; branch if fire button not pressed
.launchPlayerShot
   ldx shooterHorizPos              ; get Shooter horizontal position
   inx
   stx shotHorizPos
   ldx shooterVertPos               ; get Shooter vertical position
   lda ShooterKernelZoneValues,x    ; get Shooter KERNEL_ZONE value
   clc
   adc #2
   sta shotVertPos
.moveShotUp
   dec shotVertPos
SetShooterAndShotKernelValues
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
   jmp SwitchToCheckToPlayBonusLifeSound

Overscan
   ldx #OVERSCAN_TIME
   stx TIM64T
   bit mushroomTallyState           ; check Mushroom tally game state value
   bvc CheckToSpawnCentipedeHead    ; branch if not GS_MUSHROOM_TALLY
   jmp DoneOverscan

CheckToSpawnCentipedeHead
   lda spawnNewHeadState            ; get spawn new head state
   and #CENTIPEDE_POISONED_MASK
   beq .doneCheckToSpawnCentipedeHead;branch if CENTIPEDE_NORMAL
   lda frameCount                   ; get current frame count
   ldx playerScore                  ; get score thousands value
   cpx #$10
   bmi .checkPlayerScoreLessThan100000;branch if less than 100,000
   and #$3F                         ; 0 <= a <= 63
   bpl .checkToSpawnCentipedeHead   ; unconditional branch

.checkPlayerScoreLessThan100000
   cpx #4
   bmi .checkToSpawnCentipedeHead   ; branch if less than 40,000
   and #$7F                         ; 0 <= a <= 127
   bpl .checkToSpawnCentipedeHead   ; could fall through

.checkToSpawnCentipedeHead
   cmp #13
   bne .doneCheckToSpawnCentipedeHead
   ldx numberOfCentipedeSegments    ; get number of Centipede segments
   cpx #MAX_CENTIPEDE_SEGMENTS - 1
   beq .doneCheckToSpawnCentipedeHead;branch if maximum segments present
   inx
   stx numberOfCentipedeSegments    ; increment number of Centipede segments
   lda shooterHorizPos              ; get Shooter horizontal position
   adc spiderHorizPos               ; increment by Spider horizontal position
   lsr                              ; shift D0 to carry
   bcc .launchHeadFromRight
   lda #XMIN
   sta centipedeHorizPostion,x
   lda #[CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_LEFT | 6]
   sta centipedeState,x
   bne .setSpawnedHeadAttributes    ; unconditional branch
   
.launchHeadFromRight
   lda #XMAX - W_CENTIPEDE_HEAD
   sta centipedeHorizPostion,x
   lda #[CENTIPEDE_HEAD_SEGMENT | CENTIPEDE_DIR_DOWN | CENTIPEDE_DIR_RIGHT | 6]
   sta centipedeState,x
.setSpawnedHeadAttributes
   lda centipedeAttributes,x        ; get Centipede attribute values
   and #<~CENTIPEDE_POISONED_MASK   ; clear CENTIPEDE_POISONED value
   ora #CENTIPEDE_FAST              ; set Centipede head speed to CENTIPEDE_FAST
   sta centipedeAttributes,x
.doneCheckToSpawnCentipedeHead
   ldx #0
   lda shotVertPos                  ; get Shot vertical position
   bne CheckShotCollisionWithCentipede;branch if SHOT_ACTIVE
   jmp CheckToEndOverscan

CheckShotCollisionWithCentipede
   lda #<-1
   sta tmpShotCentipedeIndex
   lda #MAX_KERNEL_SECTIONS
   sec
   sbc shotVertPos                  ; subtract Shot vertical position
   sta tmpShotKernelZone
.checkShotInCentipedeHorizRange
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc centipedeHorizPostion,x      ; subtract Centipede horizontal position
   cmp #W_CENTIPEDE_HEAD
   bcs .checkReachedCentipedeChainEnd;branch if out range of Centipede
   cmp #0
   bcs .shotInCentipedeHorizRange   ; branch if within range of Centipede
.checkReachedCentipedeChainEnd
   cpx numberOfCentipedeSegments
   bne .checkNextCentipedeSegment
   jmp CheckToPlaceMushroomForShotCentipede

.checkNextCentipedeSegment
   inx
   bpl .checkShotInCentipedeHorizRange;unconditional branch

.shotInCentipedeHorizRange
   lda centipedeState,x             ; get Centipede state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpShotKernelZone
   bne .checkReachedCentipedeChainEnd;branch if Centipede not shot
   dec numberOfCentipedeSegments
   ldy centipedeHorizPostion,x      ; get Centipede horizontal position
   lda centipedeState,x             ; get Centipede state
   sta tmpShotCentipedeState
   stx tmpShotCentipedeIndex
   cpx numberOfCentipedeSegments
   bmi .breakTheChain
   bne ScorePointsForCentipede
.breakTheChain
   lda centipedeState + 1,x         ; get trailing Centipede segment state
   and #<~CENTIPEDE_SEGMENT_MASK
   sta centipedeState,x             ; set to CENTIPEDE_HEAD_SEGMENT
   lda centipedeHorizPostion + 1,x  ; get adjacent Centipede horizontal position
   sta centipedeHorizPostion,x
   lda kernelZoneAttributes + 1,x   ; get adjacent Centipede attributes
   and #[CENTIPEDE_SPEED_MASK | CENTIPEDE_POISONED_MASK]
   sta tmpCentipedeAttribute
   lda kernelZoneAttributes,x       ; get Centipede attributes
   and #<~[CENTIPEDE_SPEED_MASK | CENTIPEDE_POISONED_MASK]
   ora tmpCentipedeAttribute        ; combine with adjacent Centipede attribute
   sta kernelZoneAttributes,x
.checkEndOfCentipedeChain
   cpx numberOfCentipedeSegments
   beq ScorePointsForCentipede
   inx                              ; increment Centipede index
   lda centipedeState + 1,x         ; get trailing Centipede segment state
   sta centipedeState,x
   lda centipedeHorizPostion + 1,x  ; get trailing Centipede horizontal position
   sta centipedeHorizPostion,x
   lda centipedeAttributes + 1,x    ; get trailing Centipede attributes
   and #[CENTIPEDE_SPEED_MASK | CENTIPEDE_POISONED_MASK]
   sta tmpCentipedeAttribute
   lda centipedeAttributes,x        ; get Centipede attributes
   and #<~[CENTIPEDE_SPEED_MASK | CENTIPEDE_POISONED_MASK]
   ora tmpCentipedeAttribute        ; combine with adjacent Centipede attribute
   sta centipedeAttributes,x
   bpl .checkEndOfCentipedeChain    ; unconditional branch

ScorePointsForCentipede
   bit gameState                    ; check current game state
   bvs .doneScorePointsForCentipede ; branch if selecting game
   bit tmpShotCentipedeState
   sed
   clc
   bmi .scorePointsForCentipedeSegment
   lda #[POINTS_CENTIPEDE_HEAD / 100]
.incrementScoreForShootingCentipede
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .initObjectShotAudioTimerValue
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .initObjectShotAudioTimerValue;branch if reached maximum number of lives
   adc #1 << 4                      ; increment number of lives
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
   bpl .initObjectShotAudioTimerValue;unconditional branch

.scorePointsForCentipedeSegment
   lda #POINTS_CENTIPEDE_SEGMENT
   adc playerScore + 2              ; increment score ones value
   sta playerScore + 2              ; set score ones value
   lda #1 - 1
   beq .incrementScoreForShootingCentipede;unconditional branch
   
.initObjectShotAudioTimerValue
   lda spiderAttributes             ; get Spider attribute values
   ora #1 << 2
   sta spiderAttributes
.doneScorePointsForCentipede
   cld
   ldx tmpShotCentipedeIndex
   dex
   cpx numberOfCentipedeSegments
   bpl .determineShotCentipedeLocation
   jmp .checkNextCentipedeSegment

CheckToPlaceMushroomForShotCentipede
   ldx tmpShotCentipedeIndex
   bmi CheckShotCollisionWithSpider
.determineShotCentipedeLocation
   lda shotVertPos                  ; get Shot vertical position
   lsr                              ; shift D0 to carry
   tya                              ; move Centipede horizontal position
   bcc .determineMushroomHorizPosition;branch on an even scan line
   sbc #W_CENTIPEDE_HEAD
.determineMushroomHorizPosition
   tay                              ; set to Centipede horizonal position
   lda tmpShotCentipedeState        ; get shot Centipede state
   and #CENTIPEDE_HORIZ_DIR_MASK    ; keep CENTIPEDE_HORIZ_DIR value
   bne .determineMushroomMaskingBitIndex;branch if CENTIPEDE_DIR_LEFT
   tya                              ; set to Centipede horizontal position
   clc
   adc #[W_CENTIPEDE_HEAD * 2] - 1
   tay
.determineMushroomMaskingBitIndex
   tya                              ; get Centipede horizontal position
   lsr
   lsr
   lsr
   asl                              ; a = [a / 4] & 254
   tay
   lda shotVertPos                  ; get Shot vertical position
   lsr
   tya                              ; get Centipede horizontal position
   bcs .setMushroomMaskingBitIndex  ; branch if Shot in odd zone
   adc #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits - 1]
.setMushroomMaskingBitIndex
   tax
   inx
   cmp #63
   bmi .determineMushroomLocation
   ldx #63
.determineMushroomLocation
   lda shotVertPos                  ; get Shot vertical position
   sec
   sbc #1
   asl                              ; multiply by 2 for Mushroom array index
   tay
   txa                              ; move Mushroom masking index to accumulator
   and #$10
   beq .placeMushroomForShotCentipede;branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.placeMushroomForShotCentipede
   lda mushroomArray,y              ; get Mushroom array value
   ora MushroomMaskingBits,x        ; set Mushroon in place of shot Centipede
   jmp PlaceMushroomValueInArray

.checkShotCollisionWithFlea
   jmp CheckShotCollisionWithFlea

CheckShotCollisionWithSpider
   bit spiderAttributes             ; check Spider attribute values
   bvs .checkShotCollisionWithFlea  ; branch if showing Spider point value
   bmi .checkShotCollisionWithFlea  ; branch if showing Spider point value
   lda spiderState                  ; get current Spider state
   cmp #SPIDER_INACTIVE
   beq .checkShotCollisionWithFlea  ; branch if SPIDER_INACTIVE
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc spiderHorizPos               ; subtract Spider horizontal position
   cmp #W_SPIDER + 1
   bcc .checkShotInSpiderHorizontalRange
   jmp CheckShotCollisionWithFlea

.checkShotInSpiderHorizontalRange
   cmp #<[0 - 1]
   bmi CheckShotCollisionWithFlea
   lda spiderState                  ; get current Spider state
   and #KERNEL_ZONE_MASK            ; keep Spider KERNEL_ZONE value
   cmp tmpShotKernelZone
   beq .spiderShot
   sec
   sbc #1
   cmp tmpShotKernelZone
   bne CheckShotCollisionWithFlea
.spiderShot
   lda #MAX_KERNEL_SECTIONS - 1
   sec
   sbc spiderState                  ; subtract Spider kernel zone
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta tmpSpiderKernelZoneDistance
   asl                              ; multiply by 2
   clc
   adc tmpSpiderKernelZoneDistance  ; multiply by 3 (i.e. [x * 2] + x])
   sec
   sbc shooterVertPos               ; subtract Shooter vertical position
   bpl .scorePointsForSpider
   eor #$FF                         ; get 1's complement value
.scorePointsForSpider
   tax
   lda SpiderPointValues,x          ; get Spider point value
   tay                              ; move point value to y register
   bit gameState                    ; check current game state
   bvs .doneCheckShotCollisionWithSpider;branch if selecting game
   sed
   clc
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .doneCheckShotCollisionWithSpider
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .doneCheckShotCollisionWithSpider;branch if maximum lives reached
   adc #1 << 4                      ; increment number of lives
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
.doneCheckShotCollisionWithSpider
   cld
   tya                              ; move Spider point value to accumulator
   lsr                              ; divide value by 4
   lsr
   tay
   lda SpiderPointAttributeValues,y
   sta spiderAttributes
   jmp TurnOffShot

SpiderPointValues
   .byte [POINTS_SPIDER_CLOSE / 100],   [POINTS_SPIDER_CLOSE / 100]
   .byte [POINTS_SPIDER_CLOSE / 100],   [POINTS_SPIDER_CLOSE / 100]
   .byte [POINTS_SPIDER_CLOSE / 100],   [POINTS_SPIDER_CLOSE / 100]
   .byte [POINTS_SPIDER_MEDIUM / 100],  [POINTS_SPIDER_MEDIUM / 100]
   .byte [POINTS_SPIDER_MEDIUM / 100],  [POINTS_SPIDER_MEDIUM / 100]
   .byte [POINTS_SPIDER_MEDIUM / 100],  [POINTS_SPIDER_MEDIUM / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100], [POINTS_SPIDER_DISTANT / 100]
   .byte [POINTS_SPIDER_DISTANT / 100]

SpiderPointAttributeValues
   .byte [SPIDER_POINTS_300 | 4]
   .byte [SPIDER_POINTS_600 | 4]
   .byte [SPIDER_POINTS_900 | 4]

CheckShotCollisionWithFlea
   lda fleaHorizPos                 ; get Flea horizontal position
   bmi CheckShotCollisionWithScorpion;branch if FLEA_INACTIVE
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc fleaHorizPos                 ; subtract Flea horizontal position
   cmp #W_FLEA
   bcs CheckShotCollisionWithScorpion;branch if out range of Flea
   cmp #0
   bcc CheckShotCollisionWithScorpion;branch if out range of Flea
   lda fleaState                    ; get current Flea state
   and #KERNEL_ZONE_MASK            ; keep Flea KERNEL_ZONE value
   cmp tmpShotKernelZone
   beq .fleaShot
   sec
   sbc #1
   cmp tmpShotKernelZone
   bne CheckShotCollisionWithScorpion;branch if out range of Flea
.fleaShot
   bit fleaState                    ; check current Flea state
   bvs .scorePointsForFlea          ; branch if FLEA_STATE_ANGRY
   lda fleaState                    ; get current Flea state
   ora #FLEA_STATE_ANGRY
   sta fleaState                    ; set to move Flea faster
   bne CheckShotCollisionWithScorpion;unconditional branch

.scorePointsForFlea
   bit gameState                    ; check current game state
   bvs .doneCheckShotCollisionWithFlea;branch if selecting game
   lda #[POINTS_FLEA / 100]
   clc
   sed
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .doneCheckShotCollisionWithFlea
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .doneCheckShotCollisionWithFlea;branch if reached maximum number of lives
   adc #1 << 4                      ; increment number of lives
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
.doneCheckShotCollisionWithFlea
   cld
   ldy #FLEA_INACTIVE
   sty fleaHorizPos
   sty fleaState
   jmp CheckToEndOverscan

CheckShotCollisionWithScorpion SUBROUTINE
   bit scorpionHorizPos
   bmi CheckShotCollisionWithMushroom;branch if SCORPION_INACTIVE
   lda shotHorizPos                 ; get Shot horizontal position
   sec
   sbc scorpionHorizPos             ; subtract Scorpion horizontal position
   cmp #W_SCORPION
   bcs CheckShotCollisionWithMushroom;branch if out range of Scorpion
   cmp #0
   bcc CheckShotCollisionWithMushroom;branch if out range of Scorpion
   lda scorpionState                ; get current Scorpion state
   and #KERNEL_ZONE_MASK            ; keep Scorpion KERNEL_ZONE value
   cmp tmpShotKernelZone
   bne CheckShotCollisionWithMushroom
   bit gameState                    ; check current game state
   bvs .doneCheckShotCollisionWithScorpion;branch if selecting game
   lda #[POINTS_SCORPION / 100]
   clc
   sed
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .initObjectShotAudioTimerValue
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .initObjectShotAudioTimerValue;branch if reached maximum number of lives
   adc #1 << 4                      ; increment number of lives
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
.initObjectShotAudioTimerValue
   lda spiderAttributes             ; get Spider attribute values
   ora #1 << 2
   sta spiderAttributes
.doneCheckShotCollisionWithScorpion
   cld
   ldy #SCORPION_INACTIVE
   sty scorpionHorizPos
   jmp TurnOffShot

CheckShotCollisionWithMushroom SUBROUTINE
   lda shotHorizPos                 ; get Shot horizontal position
   lsr                              ; divide value by 4
   lsr
   tay
   lda shotVertPos                  ; get Shot vertical position
   lsr                              ; shift D0 to carry
   tya                              ; move Shot horiz position to accumulator
   bcs .setMushroomMaskingBitIndex  ; branch if odd scan line
   adc #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
.setMushroomMaskingBitIndex
   tax
   lda shotVertPos                  ; get Shot vertical position
   sec
   sbc #1
   asl                              ; multiply by 2 for Mushroom array index
   tay
   txa                              ; move Mushroom masking index to accumulator
   and #$10
   beq .checkPresenceOfMushroom     ; branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.checkPresenceOfMushroom
   lda mushroomArray,y              ; get Mushroom array value
   and MushroomMaskingBits,x        ; mask Mushroom bit value
   beq CheckToEndOverscan           ; branch if Mushroom not present
   cpx shotMushroomIndex
   beq .mushroomShotTwice           ; branch if Mushroom shot previously
   txa                              ; move Mushroom index to accumulator
   ora #$80
   cmp shotMushroomIndex
   beq .scorePointsForRemovingMushroom;branch if shot three times
   stx shotMushroomIndex
   bne TurnOffShot                  ; unconditional branch

.mushroomShotTwice
   txa                              ; move Mushroom index to accumulator
   ora #$80                         ; set D7 to show shot twice
   sta shotMushroomIndex
   bne TurnOffShot                  ; unconditional branch

.scorePointsForRemovingMushroom
   lda #<-1
   sta shotMushroomIndex
   bit gameState                    ; check current game state
   bvs .doneCheckShotCollisionWithMushroom;branch if selecting game
   sed
   lda #POINTS_ELIMINATE_MUSHROOM
   clc
   adc playerScore + 2              ; increment score ones value
   sta playerScore + 2              ; set score ones value
   lda #1 - 1
   adc playerScore + 1              ; increment score hundreds value
   sta playerScore + 1              ; set score hundreds value
   bcc .doneCheckShotCollisionWithMushroom
   lda #1 - 1
   adc playerScore                  ; increment score thousands value
   sta playerScore                  ; set score thousands value
   cld
   lda gameWaveValues               ; get current game wave values
   cmp #MAX_LIVES << 4
   bpl .doneCheckShotCollisionWithMushroom;branch if maximum lives reached
   adc #1 << 4                      ; increment number of lives
   sta gameWaveValues
   lda bonusLifeSoundEngineValues
   ora #BONUS_LIFE_ACHIEVED
   sta bonusLifeSoundEngineValues
   lda frameCount                   ; get current frame count
   and #$0F                         ; 0 <= a <= 15
   sta frameCount
.doneCheckShotCollisionWithMushroom
   cld
   lda mushroomArray,y              ; get Mushroom array value
   eor MushroomMaskingBits,x        ; remove Mushroom from array
PlaceMushroomValueInArray
   sta mushroomArray,y
   bne TurnOffShot                  ; branch if Mushrooms remaining in zone
   tya                              ; move Mushroom array index to accumulator
   lsr
   bcc .checkRightSideMushroom
   dey                              ; decrement for left Mushroom array
.checkToRemovePoisonMushroomState
   ldx mushroomArray,y
   bne TurnOffShot                  ; branch if Mushrooms remaining in zone
   sec
   sbc #MAX_KERNEL_SECTIONS - 1
   eor #$FF
   clc
   adc #1
   tax
   lda kernelZoneAttributes,x
   and #<~POISON_MUSHROOM_MASK      ; remove POISON_MUSHROOM value
   sta kernelZoneAttributes,x
   bpl TurnOffShot                  ; unconditional branch

.checkRightSideMushroom
   iny
   bcc .checkToRemovePoisonMushroomState;unconditional branch

TurnOffShot
   lda #0
   sta AUDV0
   sta shotVertPos
CheckToEndOverscan
   lda numberOfCentipedeSegments
   bpl ShooterCollisionDetection
   jmp DoneOverscan

ShooterCollisionDetection
   ldx #0
   lda #SHOOTER_YMAX + 2
   sec
   sbc shooterVertPos
   tay
   lda ShooterKernelZoneValues,y    ; get Shooter KERNEL_ZONE value
   sta tmpShooterKernelZone
.checkShooterCollisionWithCentipede
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   bne CheckShooterCollisionWithSpiderOrFlea;branch if SHOOTER_COLLISION
   lda shooterHorizPos              ; get Shooter horizontal position
   sec
   sbc centipedeHorizPostion,x      ; subtract Centipede horizontal position
   cmp #W_CENTIPEDE_HEAD
   bcs .checkNextCentipedeSegmentCollision
   cmp #<-3
   bpl .shooterInCentipedeHorizRange
.checkNextCentipedeSegmentCollision
   cpx numberOfCentipedeSegments
   beq CheckShooterCollisionWithSpiderOrFlea
   inx
   bne .checkShooterCollisionWithCentipede;unconditional branch

.shooterInCentipedeHorizRange
   lda centipedeState,x             ; get Centipede state
   and #KERNEL_ZONE_MASK            ; keep Centipede KERNEL_ZONE value
   cmp tmpShooterKernelZone
   bne .checkNextCentipedeSegmentCollision;branch if not in vertical range
   lda #SHOOTER_COLLISION_DELAY_INCREMENT
   ora shooterCollisionState
   sta shooterCollisionState
   lda #0
   sta shooterExplosionAudioFrequencyValue
   jmp DoneOverscan

CheckShooterCollisionWithSpiderOrFlea
   bit gameSelection                ; check current game selection
   bvc .checkSpiderCollisionWithShooter;branch if STANDARD_PLAY_GAME
   jmp CheckSpiderForRemovingMushroom

.checkSpiderCollisionWithShooter
   bit spiderAttributes             ; check Spider attribute values
   bmi .checkFleaCollisionWithShooter;branch if showing Spider point value
   bvs .checkFleaCollisionWithShooter;branch if showing Spider point value
   lda shooterHorizPos              ; get Shooter horizontal position
   sec
   sbc spiderHorizPos               ; subtract Spider horizontal position
   cmp #W_SPIDER
   bcs .checkFleaCollisionWithShooter;branch if not within horizontal range
   cmp #<-3
   bmi .checkFleaCollisionWithShooter
   lda spiderState                  ; get current Spider state
   and #KERNEL_ZONE_MASK            ; keep Spider KERNEL_ZONE value
   cmp tmpShooterKernelZone
   bne .checkFleaCollisionWithShooter;branch if not in vertical range
   lda #SHOOTER_COLLISION_DELAY_INCREMENT
   ora shooterCollisionState
   sta shooterCollisionState
   lda #0
   sta shooterExplosionAudioFrequencyValue
   jmp DoneOverscan

.checkFleaCollisionWithShooter
   lda fleaHorizPos                 ; get Flea horizontal position
   bmi CheckSpiderForRemovingMushroom;branch if FLEA_INACTIVE
   lda shooterHorizPos              ; get Shooter horizontal position
   sec
   sbc fleaHorizPos                 ; subtract Flea horizontal position
   cmp #W_FLEA
   bcs CheckSpiderForRemovingMushroom;branch if not within horizontal range
   cmp #<-W_FLEA + 1
   bmi CheckSpiderForRemovingMushroom
   lda fleaState                    ; get current Flea state
   and #KERNEL_ZONE_MASK            ; keep Flea KERNEL_ZONE value
   cmp tmpShooterKernelZone
   bne CheckSpiderForRemovingMushroom;branch if not in vertical range
   lda #SHOOTER_COLLISION_DELAY_INCREMENT
   ora shooterCollisionState
   sta shooterCollisionState
   lda #0
   sta shooterExplosionAudioFrequencyValue
   lda #$F0
   sta fleaHorizPos
   jmp DoneOverscan

CheckSpiderForRemovingMushroom SUBROUTINE
   bit spiderAttributes             ; check Spider attribute values
   bvs MoveCentipede                ; branch if showing Spider point value
   bmi MoveCentipede                ; branch if showing Spider point value
   lda spiderHorizPos               ; get Spider horizontal position
   clc
   adc #[W_SPIDER / 2] - 1          ; get Spider center
   lsr                              ; divide by 4
   lsr
   tay
   lda spiderState                  ; get current Spider state
   cmp #SPIDER_INACTIVE
   beq MoveCentipede                ; branch if SPIDER_INACTIVE
   lsr
   tya
   bcs .setMushroomMaskingBitIndex  ; branch if Spider in odd zone
   adc #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
.setMushroomMaskingBitIndex
   tax
   lda #MAX_KERNEL_SECTIONS - 1
   sec
   sbc spiderState                  ; subtract Spider kernel zone
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE difference
   asl                              ; multiply by 2 for Mushroom array index
   tay
   txa                              ; move Mushroom masking index to accumulator
   and #$10
   beq .spiderRemovingMushroom      ; branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.spiderRemovingMushroom
   lda MushroomMaskingBits,x        ; get Mushroom masking bit value
   eor #$FF                         ; flip bits
   and mushroomArray,y              ; remove Mushroom bit from array
   sta mushroomArray,y              ; set new Mushroom array value
MoveCentipede
   lda frameCount                   ; get current frame count
   and #0
   bne .doneMoveCentipede           ; branch never taken
   bit mushroomTallyState           ; check Mushroom tally game state value
   bvs .doneMoveCentipede           ; branch if GS_MUSHROOM_TALLY
   ldx #0
   stx tmpCentipedeSegmentIndex
   ldx numberOfCentipedeSegments
   lda shooterCollisionState        ; get Shooter collision state
   and #SHOOTER_COLLISION_DELAY_MASK; keep SHOOTER_COLLISION_DELAY value
   bne .doneMoveCentipede           ; branch if SHOOTER_COLLISION
   lda frameCount                   ; get current frame count
   and #7
   cmp #3
   beq .doneMoveCentipede
.checkToMoveCentipedeSegment
   lda centipedeAttributes,x        ; get Centipede attributes
   and #CENTIPEDE_SPEED_MASK        ; keep CENTIPEDE_SPEED value
   bne .moveCentipede               ; branch if CENTIPEDE_FAST
   lda frameCount                   ; get current frame count
   and #1
   beq .moveCentipede
.doneMoveCentipede
   jmp DoneOverscan

.moveCentipede
   lda centipedeState,x             ; get Centipede state value
   sta tmpCentipedeState
   bpl .checkToMoveCentipedeHead    ; branch if CENTIPEDE_HEAD_SEGMENT
   lda tmpCentipedeSegmentIndex     ; get Centipede segment index
   bne .moveCentipedeSegment        ; branch if not beginning of Centipede
   lda INTIM                        ; get RIOT timer value
   cmp #6
   bpl .setCentipedeSegmentIndex
   jmp DoneOverscan

.setCentipedeSegmentIndex
   stx tmpCentipedeSegmentIndex
.moveCentipedeSegment
   lda centipedeState - 1,x         ; get leading Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta tmpLeadingSegmentKernelZone
   lda tmpCentipedeState            ; get Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   cmp tmpLeadingSegmentKernelZone
   beq .moveCentipedeSegmentHorizontally;branch if in leading segment zone
   lda centipedeHorizPostion,x      ; get Centipede horizontal segment position
   and #3
   bne .moveCentipedeSegmentHorizontally
   lda centipedeState - 1,x         ; get leading Centipede segment state
   ora #CENTIPEDE_BODY_SEGMENT
   sta centipedeState,x
   bne .checkIfDoneMovingCentipedeChain;unconditional branch

.checkToMoveCentipedeHead
   lda centipedeState + 1,x         ; get trailing Centipede segment state
   bmi .moveCentipedeHead           ; branch if CENTIPEDE_BODY_SEGMENT
   lda INTIM                        ; get RIOT timer value
   cmp #6
   bpl .moveCentipedeHead
   jmp DoneOverscan

.moveCentipedeHead
   lda tmpCentipedeState            ; get CENTIPEDE_HEAD_SEGMENT state
   and #CENTIPEDE_HORIZ_DIR_MASK    ; keep CENTIPEDE_HORIZ_DIR value
   bne .checkCentipedeReachingHorizEdges;branch if CENTIPEDE_DIR_LEFT
   lda centipedeHorizPostion,x      ; get horizontal position
   cmp #XMAX - W_CENTIPEDE_HEAD
   beq .checkToMoveCentipedeSegmentVertically;branch if reached right edge
   bne .checkRightMovingCentipedeReachingLeftEdge;unconditional branch

.checkCentipedeReachingHorizEdges
   lda centipedeHorizPostion,x      ; get Centipede segment horizontal position
   beq .checkToMoveCentipedeSegmentVertically;branch if reached left edge
   cmp #XMAX - W_CENTIPEDE_HEAD
   beq .moveCentipedeSegmentHorizontally;branch if reached right edge
.checkRightMovingCentipedeReachingLeftEdge
   cmp #XMIN
   beq .moveCentipedeSegmentHorizontally;branch if reached left edge
   and #3
   beq .checkCentipedeCollisionWithMushroom
.moveCentipedeSegmentHorizontally
   lda tmpCentipedeState
   and #CENTIPEDE_HORIZ_DIR_MASK    ; keep CENTIPEDE_HORIZ_DIR value
   bne .decrementCentipedeHorizontalPosition;branch if CENTIPEDE_DIR_LEFT
   inc centipedeHorizPostion,x
   bne .checkIfDoneMovingCentipedeChain;unconditional branch

.decrementCentipedeHorizontalPosition
   dec centipedeHorizPostion,x
.checkIfDoneMovingCentipedeChain
   bit tmpCentipedeState
   bmi .moveNextCentipedeSegment    ; branch if CENTIPEDE_BODY_SEGMENT
   lda #0
   sta tmpCentipedeSegmentIndex
.moveNextCentipedeSegment
   dex
   bmi .doneMoveCentipede
   jmp .checkToMoveCentipedeSegment

.checkCentipedeCollisionWithMushroom
   lda centipedeHorizPostion,x      ; get Centipede horizontal position
   lsr                              ; divide by 4
   lsr
   tay                              ; set to Centipede horizontal position
   lda tmpCentipedeState            ; get Centipede KERNEL_ZONE value
   lsr
   and #CENTIPEDE_HORIZ_DIR_MASK >> 1;keep CENTIPEDE_HORIZ_DIR value
   bne .determineMushroomMaskingBitIndex;branch if CENTIPEDE_DIR_LEFT
   iny
   iny
.determineMushroomMaskingBitIndex
   dey
   bmi .moveCentipedeSegmentHorizontally;branch if out of range
   tya
   bcs .setCentipedeMushroomMaskingBitIndex;branch if Centipede in odd zone
   adc #<[EvenScanlineMushroomMaskingBits - MushroomMaskingBits]
.setCentipedeMushroomMaskingBitIndex
   sta tmpMushroomMaskingBitIndex
   tay
   lda centipedeAttributes,x        ; get Centipede attribute values
   and #CENTIPEDE_POISONED_MASK
   beq .checkNormalCentipedeCollisionWithMushroom;branch if CENTIPEDE_NORMAL
   lda MushroomMaskingBits,y
   bne .checkToMoveCentipedeSegmentVertically
   beq .moveCentipedeSegmentHorizontally;unconditional branch

.checkNormalCentipedeCollisionWithMushroom
   lda tmpCentipedeState            ; get Centipede segment state
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   sta tmpCentipedeSegmentKernelZone
   lda #MAX_KERNEL_SECTIONS - 1
   sec
   sbc tmpCentipedeSegmentKernelZone; subtract Centipede kernel zone
   asl                              ; multiply by 2 for Mushroom array index
   tay
   lda tmpMushroomMaskingBitIndex   ; get Mushroom masking index
   and #$10
   beq .checkMushroomPresent        ; branch for left Mushroom array
   iny                              ; increment for right Mushroom array
.checkMushroomPresent
   lda mushroomArray,y              ; get Mushroom array value
   ldy tmpMushroomMaskingBitIndex
   and MushroomMaskingBits,y        ; mask Mushroom bit value
   beq .moveCentipedeSegmentHorizontally;branch if Mushroom not present
   ldy tmpCentipedeSegmentKernelZone
   lda kernelZoneAttributes,y       ; get kernel zone attribute values
   bpl .checkToMoveCentipedeSegmentVertically;branch if NORMAL_MUSHROOM_ZONE
   lda centipedeAttributes,x
   ora #CENTIPEDE_POISONED
   sta centipedeAttributes,x        ; set segment to CENTIPEDE_POISONED
.checkToMoveCentipedeSegmentVertically
   lda tmpCentipedeState            ; get Centipede segment state
   tay
   and #KERNEL_ZONE_MASK            ; keep KERNEL_ZONE value
   beq .centipedeReachedBottomZone  ; branch if reached bottom zone
   cmp #5
   bne .moveCentipedeSegmentVertically
   bit tmpCentipedeState            ; check Centipede segment state
   bvc .moveCentipedeSegmentDown    ; branch if CENTIPEDE_DIR_DOWN
   bvs .changeCentipedeVerticalDirection;unconditional branch

.centipedeReachedBottomZone
   lda centipedeAttributes,x
   and #CENTIPEDE_POISONED_MASK     ; keep CENTIPEDE_POISONED value
   beq .setCentipedeStateForReachingBottom;branch if CENTIPEDE_NORMAL
   lda centipedeAttributes,x
   and #<~CENTIPEDE_POISONED_MASK   ; clear CENTIPEDE_POISONED value
   sta centipedeAttributes,x
   jmp .changeCentipedeVerticalDirection

.setCentipedeStateForReachingBottom
   lda spawnNewHeadState            ; get spawn new head state
   ora #CENTIPEDE_POISONED
   sta spawnNewHeadState
   lda tmpCentipedeSegmentIndex
   beq .changeCentipedeVerticalDirection
   tay
   lda centipedeState,y
   eor #[CENTIPEDE_SEGMENT_MASK | CENTIPEDE_HORIZ_DIR_MASK]
   sta centipedeState,y
.changeCentipedeVerticalDirection
   lda tmpCentipedeState
   eor #CENTIPEDE_VERT_DIR_MASK
   tay
.moveCentipedeSegmentVertically
   tya                              ; move Centipede state to accumulator
   and #CENTIPEDE_VERT_DIR_MASK     ; keep CENTIPEDE_VERT_DIR value
   beq .moveCentipedeSegmentDown    ; branch if CENTIPEDE_DIR_DOWN
   iny                              ; increment Centipede KERNEL_ZONE value
   iny
.moveCentipedeSegmentDown
   dey                              ; decrement Centipede KERNEL_ZONE value
   tya                              ; move Centipede state to accumulator
   eor #CENTIPEDE_HORIZ_DIR_MASK    ; flip CENTIPEDE_HORIZ_DIR value
   sta centipedeState,x
   jmp .checkIfDoneMovingCentipedeChain
   
DoneOverscan
.overscanWait
   ldx INTIM
   bne .overscanWait
   jmp VerticalSync

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
   
         .byte $10
   
      ELSE

         .byte $40

      ENDIF
      
   ENDIF

ThreeCentipedeZoneConflictIndexes
   .byte 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2
   .byte 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2
   .byte 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0

FiveCentipedeZoneConflictIndexes
   .byte 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3
   .byte 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2
   .byte 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3

InitMushroomValues
   .byte $00,$00,$00,$84,$00,$30,$00,$0A,$01,$00,$20,$00,$80,$00,$10,$10
   .byte $03,$10,$40,$00,$00,$02,$01,$00,$00,$08,$00,$42,$00,$20,$41,$00
   .byte $18,$00,$01,$40,$00,$00,$00,$00
   
MushroomMaskingBits
OddScanlineMushroomMaskingBits
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
   .byte $00,$40,$00,$10,$00,$04,$00,$01,$00,$02,$00,$08,$00,$20,$00,$80
EvenScanlineMushroomMaskingBits
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00
   .byte $80,$00,$20,$00,$08,$00,$02,$00,$01,$00,$04,$00,$10,$00,$40,$00

InitFleaHorizontalAdjustmentValues
   .byte 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6
   .byte 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6
   .byte 4, 5, 5, 6, 5, 6, 6, 7

ShooterKernelZoneValues
   .byte 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7
   .byte 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14
   .byte 10, 14, 15, 15, 15, 16, 16, 16, 17, 17, 17, 18, 18, 18, 19, 19, 19, 20
   .byte 20, 20

FlickerPriorityBitValues
   .byte $00,$01,$02,$04,$08,$10,$20,$40,$80
   
   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = NTSC
   
         .byte $00,$01,$02,$03,$04,$05,$06,$0B,$0B,$0B,$0C,$0C,$0C,$00,$09,$09
         .byte $0A,$0A,$0A,$0B
   
      ELSE
      
         .byte $CE,$8A,$E4,$E4,$24,$E4,$84,$EE,$E2,$82,$E3,$22,$E3,$ED,$29,$E9
         .byte $89,$E9,$CA,$55
    
      ENDIF
      
   ENDIF

   FILL_BOUNDARY 236, 0

SwitchToTitleScreenProcessing
   sta BANK0STROBE
   jmp Overscan

SwitchToCheckToPlayBonusLifeSound
   sta BANK0STROBE
   jmp Overscan

   IF ORIGINAL_ROM
   
      IF COMPILE_REGION = PAL50
   
         .byte $FF,$01,$DF,$DB
         
      ENDIF
      
   ELSE

      FILL_BOUNDARY 248, 0          ; hotspot locations not available for data
   
      .byte 0, 0

   ENDIF

   FILL_BOUNDARY 252, 0

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE IN BANK1"
   
   .word BANK1Start
   
   IF COMPILE_REGION = PAL50
   
      .byte $C5,$2F
   
   ELSE

      .byte $50,$FF
   
   ENDIF