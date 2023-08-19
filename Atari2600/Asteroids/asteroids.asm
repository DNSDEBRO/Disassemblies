   LIST OFF
; ***  A S T E R O I D S ***
; Copyright 1981 Atari, Inc.
; Designer: Brad Stewart
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: April 10, 2023
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
;
; Copyright ROM stats
; -------------------------------------------
; *** 1,202 BYTES OF ROM FREE IN BANK0
; ***    82 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 1,284 TOTAL BYTES FREE
;
; No Copyright ROM stats
; -------------------------------------------
; *** 1,556 BYTES OF ROM FREE IN BANK0
; ***    91 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 1,647 TOTAL BYTES FREE
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

   IFNCONST COPYRIGHT_ROM
   
COPYRIGHT_ROM           = TRUE

   ENDIF
   
   IF !(COPYRIGHT_ROM = TRUE || COPYRIGHT_ROM = FALSE)

      echo ""
      echo "*** ERROR: Invalid COPYRIGHT_ROM value"
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

COPYRIGHT_VBLANK_TIME   = 45
COPYRIGHT_OVERSCAN_TIME = 36
GAME_VBLANK_TIME        = 45
GAME_OVERSCAN_TIME      = 36

H_KERNEL                = 89
COPYRIGHT_KERNEL_SCANLINES = 194

INIT_PLAYER_Y           = 41

INIT_HEARTBEAT_TIMER_VALUE = 8
MAX_HEARTBEAT_TIMER_VALUE = 6

SPEED_SLOW              = $70       ; horizontal delay of slow asteroids (1/7)
SPEED_MEDIUM            = $03       ; horizontal delay of medium asteroids (1/3)

   ELSE
   
COPYRIGHT_VBLANK_TIME   = 54
COPYRIGHT_OVERSCAN_TIME = 45
GAME_VBLANK_TIME        = 53
GAME_OVERSCAN_TIME      = 44

H_KERNEL                = 107
COPYRIGHT_KERNEL_SCANLINES = 226

INIT_PLAYER_Y           = 48

INIT_HEARTBEAT_TIMER_VALUE = 6
MAX_HEARTBEAT_TIMER_VALUE = 4

SPEED_SLOW              = $50       ; horizontal delay of slow asteroids (1/5)
SPEED_MEDIUM            = $02       ; horizontal delay of medium asteroids (1/2)

   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

   IF COMPILE_REGION = NTSC

COLORS_RESERVED_LIVES   = ULTRAMARINE_BLUE + 4
COLORS_ASTEROID_00      = WHITE - 2
COLORS_ASTEROID_01      = RED + 4
COLORS_ASTEROID_02      = DK_BLUE + 12
COLORS_ASTEROID_03      = YELLOW + 8
COLORS_ASTEROID_04      = RED_ORANGE + 6
COLORS_ASTEROID_05      = PURPLE + 6
COLORS_ASTEROID_06      = ULTRAMARINE_BLUE + 6
COLORS_ASTEROID_07      = ORANGE_GREEN + 6
COLORS_UFO              = DK_BLUE + 12
COLORS_SATELLITE        = ORANGE_GREEN + 12
COLORS_PLAYER1_SCORE    = RED + 4
COLORS_PLAYER1_SHIP     = RED + 12
COLORS_PLAYER2_SCORE    = DK_GREEN + 6
COLORS_PLAYER2_SHIP     = DK_GREEN + 12
COLORS_COPYRIGHT        = RED + 4

   ELSE
   
COLORS_RESERVED_LIVES   = PURPLE + 4
COLORS_ASTEROID_00      = BLUE_2 + 2
COLORS_ASTEROID_01      = COBALT_BLUE + 4
COLORS_ASTEROID_02      = BRICK_RED + 6
COLORS_ASTEROID_03      = CYAN + 6
COLORS_ASTEROID_04      = TURQUOISE + 8
COLORS_ASTEROID_05      = BRICK_RED + 10
COLORS_ASTEROID_06      = RED + 12
COLORS_ASTEROID_07      = WHITE
COLORS_UFO              = BLUE_2 + 2
COLORS_SATELLITE        = GREEN + 8
COLORS_PLAYER1_SCORE    = RED + 4
COLORS_PLAYER1_SHIP     = COLORS_PLAYER1_SCORE
COLORS_PLAYER2_SCORE    = GREEN + 8
COLORS_PLAYER2_SHIP     = COLORS_PLAYER2_SCORE
COLORS_COPYRIGHT        = RED + 4
   
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

H_RESERVED_SHIPS        = 5
H_DIGITS                = 5
H_COPYRIGHT             = 26
H_LARGE_ASTEROID        = 15
H_MEDIUM_ASTEROID       = 7
H_SMALL_ASTEROID        = 4
H_PLAYER_SHIP           = 5
H_SHIP_EXPLOSION        = 6
H_UFO                   = 3
H_SATELLITE             = 5
H_MISSILE               = 3

W_LARGE_ASTEROID_RECT   = 15
W_MEDIUM_ASTEROID_RECT  = 7
W_SMALL_ASTEROID_RECT   = 3
W_PLAYER_SHIP_RECT      = 4
W_UFO_RECT              = 4
W_SATELLITE_RECT        = 6
W_MISSILE_RECT          = 2

SELECT_DELAY            = $3F
SELECT_AND_RESET_DELAY  = $0F

START_UP_MOVING_ASTEROID_IDX = 0
START_DOWN_MOVING_ASTEROID_IDX = 9
;
; Game selection constants
;
CHILD_GAME_MASK         = %10000000
SELECT_DEBOUNCE_MASK    = %01000000
NUM_PLAYERS_MASK        = %00100000
PLAYER_FEATURE_MASK     = %00011000
BONUS_SHIP_MASK         = %00000110
ASTEROID_SPEED_MASK     = %00000001

ASTEROID_SPEED_SLOW     = 0 << 0
ASTEROID_SPEED_FAST     = 1 << 0

BONUS_SHIP_5K           = 0 << 1
BONUS_SHIP_10K          = 1 << 1
BONUS_SHIP_20K          = 2 << 1
BONUS_SHIP_NONE         = 3 << 1

FEATURE_HYPERSPACE      = 0 << 3
FEATURE_SHIELDS         = 1 << 3
FEATURE_FLIP            = 2 << 3
FEATURE_NONE            = 3 << 3

ONE_PLAYER_GAME         = 0 << 5 
TWO_PLAYER_GAME         = 1 << 5

SELECT_HELD             = 1 << 6
SELECT_RELEASED         = 0 << 6

CHILD_GAME              = 1 << 7
NORMAL_GAME             = 0 << 7
;
; point values
;
POINTS_LARGE_ASTEROIDS  = $0020
POINTS_MEDIUM_ASTEROIDS = $0050
POINTS_SMALL_ASTEROIDS  = $0100
POINTS_PLAYER_SHIP      = $0000
POINTS_UFO              = $1000
POINTS_SATELLITES       = $0200
;
; sound bits contants
;
SOUND_BITS_HEARTBEAT_MASK = %01100000
SOUND_BITS_PLAYER_SHOT  = %00010000
SOUND_BITS_UFO          = %00001000
SOUND_BITS_BONUS_SHIP   = %00000100
SOUND_BITS_THRUST       = %00000010
SOUND_BITS_PLAYER_EXPLODE = %00000001

SOUND_HEARTBEAT_HIGH_FREQ = 1 << 6
SOUND_HEARTBEAT_LOW_FREQ = 0 << 6
SOUND_HEARTBEAT_ON      = 1 << 5
SOUND_HEARTBEAT_OFF     = 0 << 5
;
; sound frequency constants
;
EXPLOSION_SOUND_FREQUENCY = 31
BONUS_SHIP_SOUND_FREQUENCY = 4
THRUST_SOUND_FREQUENCY  = 8
UFO_SOUND_FREQUENCY     = 8
SATELLITE_SOUND_FREQUENCY = 16
;
; sound channel constants
;
BONUS_SHIP_SOUND_CHANNEL = 4
HEARTBEAT_SOUND_CHANNEL = 6
EXPLOSION_SOUND_CHANNEL = 8
UFO_SOUND_CHANNEL       = 12
PLAYER_SHOT_SOUND_CHANNEL = 12
;
; sound volume constants
;
THRUST_SOUND_VOLUME     = 6
UFO_SOUND_VOLUME        = 8
HEARTBEAT_SOUND_VOLUME  = 12
EXPLOSION_SOUND_VOLUME  = 15
PLAYER_SHOT_SOUND_VOLUME = 13

MAX_VOLUME              = 15

NUM_ASTEROIDS           = 9

INIT_NUM_LIVES          = 4

   IF INIT_NUM_LIVES > 16
   
      echo ""
      echo "*** ERROR: Initial number of lives cannot be greater than 16!"
      echo ""
      err
      
   ENDIF
   
MAX_DISPLAY_LIVES       = 6         ; maximum number of lives to display
MAX_NUM_LIVES           = 10

INIT_PLAYER_X           = 29

VERT_OUT_OF_RANGE       = 224

ASTEROID_HORIZ_DELAY_SLOW = $80
ASTEROID_HORIZ_DELAY_MEDIUM = $40
ASTEROID_HORIZ_DELAY_FAST = $00
;
; object ids
;
ID_LARGE_ASTEROID_00    = 0
ID_LARGE_ASTEROID_01    = 1
ID_MEDIUM_ASTEROID      = 2
ID_SMALL_ASTEROID       = 3
ID_PLAYER_SHIP          = 4
ID_UFO                  = 5
ID_SATELLITE            = 6
ID_SHOT1                = 7
ID_SHOT2                = 8
ID_SHOT_UFO             = 9
;
; asteroidAttributes constants
;
ASTEROID_FAST           = %10000000
ASTEROID_HIT            = %01000000
LARGE_ASTEROID          = %00010000
SMALL_ASTEROID          = %00110000
MEDIUM_ASTEROID         = %00100000
ASTEROID_DIRECTION      = %00001000
ASTEROID_ID_MASK        = %00000111

ASTEROID_SIZE_MASK      = LARGE_ASTEROID | MEDIUM_ASTEROID | SMALL_ASTEROID
ASTEROID_TYPE_MASK      = ASTEROID_HIT | ASTEROID_SIZE_MASK

ASTEROID_DIR_LEFT       = %00001000
;
; asteroid HMOVE / NUSIZ constansts
;
ASTEROID_HMOVE_MASK     = %11110000
ASTEROID_HORIZ_ADJ_MASK = %00001000
ASTEROID_NUSIZ_MASK     = %00000111

ASTEROID_HORIZ_ADJ      = 1 << 3
NO_ASTEROID_HORIZ_ADJ   = 0 << 3
;
; asteroid spawning constants
;
SPAWN_TWO_LARGE_ASTEROIDS = %01000000
SPAWN_THREE_LARGE_ASTEROIDS = %10000000
;
; missile direction constants
;
MISSILE_RANGE_MASK      = %11110000
;
; horizontal position constants
;
FINE_MOTION             = %11110000
COARSE_VALUE            = %00001110
OBJECT_SIDE             = %00000001
OBJECT_ON_RIGHT         = 0
OBJECT_ON_LEFT          = 1

LIVES_MASK              = %11110000
DIRECTION_MASK          = %00000111
REFLECT_MASK            = %00001000
;
; objectCollisionState constants
;
MISSILE_COLLISION_MASK_PLAYER = %11000000
COLLISION_MASK_UFO      = %00000011
;
; playerState constants
;
FLIP_FLAG               = %10000000
SHIELD_FLAG             = %01000000
HYPERSPACE_FLAG         = %00000100
KILL_FLAG               = %00000010
GAME_OVER               = %00000001

MAX_SHIELD_TIME         = 32
MAX_HYPERSPACE_TIME     = 31
;
; gameState constants
;
ACTIVE_PLAYER_FLAG      = %10000000
SHOW_SELECT_SCREEN      = %01000000
UFO_FLAG                = %00100000
FIRE_FLAG               = %00010000
UFO_COLLISION_FLAG      = %00001000
UFO_DIR_FLAGS           = %00000110
UFO_LEFT                = %00000001

UFO_DIR_DOWN            = %00000100
UFO_DIR_UP              = %00000010

SPRITE_END              = $FF

;============================================================================
; M A C R O S
;============================================================================

   MAC SLEEP_6
      lda (asteroidVertPos,x)
   ENDM
   
   MAC SLEEP_7
      php
      plp
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
   SEG.U variables
   .org $80

gameSelection           ds 1
random                  ds 2
asteroidVertPos         ds NUM_ASTEROIDS * 2
;--------------------------------------
upMovingAsteroidVertPos    = asteroidVertPos
downMovingAsteroidVertPos  = upMovingAsteroidVertPos + NUM_ASTEROIDS
asteroidHorizPos        ds NUM_ASTEROIDS * 2
;--------------------------------------
upMovingAsteroidHorizPos   = asteroidHorizPos
downMovingAsteriodHorizPos = upMovingAsteroidHorizPos + NUM_ASTEROIDS
asteroidAttributes      ds NUM_ASTEROIDS * 2
;--------------------------------------
upMovingAsteroidAttributes = asteroidAttributes
downMovingAsteroidAttributes = upMovingAsteroidAttributes + NUM_ASTEROIDS
frameCount              ds 2
asteroidHorizSpeed      ds 1
playerVariables         ds 6
;--------------------------------------
activePlayerVariables   = playerVariables
;--------------------------------------
activePlayerAttributes  = activePlayerVariables
activePlayerScore       = activePlayerVariables + 1
reservedPlayerVariables = activePlayerVariables + 3
;--------------------------------------
reservedPlayerAttributes = reservedPlayerVariables
reservedPlayerScore     = reservedPlayerAttributes + 1
asteroidCollisionState  ds 1
soundVariables          ds 3
;--------------------------------------
explosionSoundVolume    = soundVariables
bonusShipSoundTimer     = explosionSoundVolume + 1
;--------------------------------------
playerShotSoundTimer    = bonusShipSoundTimer
;--------------------------------------
heartbeatSoundTimer     = playerShotSoundTimer
soundEngineValues       = soundVariables + 2
explosionOffset         ds 1
;--------------------------------------
copyrightFrameCount     = explosionOffset
gameState               ds 1
playerState             ds 1
playerHorizPos          ds 1
playerVertPos           ds 1
playerObjectPositionAdjustmentValues ds 6
;--------------------------------------
playerShipFractionalPositionValues = playerObjectPositionAdjustmentValues
;--------------------------------------
playerShipHorizFractionalPositionValue = playerShipFractionalPositionValues
playerShipVertFractionalPositionValue = playerShipHorizFractionalPositionValue + 1
playerShipVelocityFraction = playerObjectPositionAdjustmentValues + 2
;--------------------------------------
playerShipHorizVelocityFraction = playerShipVelocityFraction
playerShipVertVelocityFraction = playerShipHorizVelocityFraction + 1
playerShipVelocityValues = playerShipVelocityFraction + 2
;--------------------------------------
playerShipHorizVelocityValue = playerShipVelocityValues
playerShipVertVelocityValue = playerShipHorizVelocityValue + 1
ufoHorizPos             ds 1
ufoVertPos              ds 1
playerMissilesHorizPos  ds 2
;--------------------------------------
playerM1HorizPos        = playerMissilesHorizPos
playerM2HorizPos        = playerM1HorizPos + 1
ufoMissileHorizPos      ds 1
playerMissilesVertPos   ds 2
;--------------------------------------
playerM1VertPos         = playerMissilesVertPos
playerM2VertPos         = playerM1VertPos + 1
ufoMissileVertPos       ds 1
missileDirections       ds 3
;--------------------------------------
playerM1Direction       = missileDirections
playerM2Direction       = playerM1Direction + 1
ufoMissileDirection     = playerM2Direction + 1
upMovingAsteroidIndex   ds 1
;--------------------------------------
upMovingAsteroidLinkListEndIndex = upMovingAsteroidIndex
downMovingAsteroidIndex ds 1
;--------------------------------------
downMovingAsteroidLinkListEndIndex = downMovingAsteroidIndex
playerFeatureTimer      ds 1
;--------------------------------------
shieldTimer             = playerFeatureTimer
;--------------------------------------
hyperspaceTimer         = shieldTimer
newPlayerVertPos        ds 1
scoreColorEOR           ds 1
objectCollisionState    ds 1
tmpRectBottomObjA       ds 1
graphicDataPointers     ds 2
;--------------------------------------
upAsteroidKernelVector  = graphicDataPointers
downAsteroidKernelVector ds 2
;--------------------------------------
   .org downAsteroidKernelVector + 1
   
graphicPointers         ds 12
;--------------------------------------
ufoGraphicsPtr          = graphicPointers
;--------------------------------------
upAsteroidCoarseValue   = ufoGraphicsPtr + 1

   .org upAsteroidCoarseValue + 1
   
playerMissile2Color     ds 1
;--------------------------------------
downAsteroidCoarseValue = playerMissile2Color
upAsteroidFineMotion    ds 1
;--------------------------------------
playerShipColor         = upAsteroidFineMotion
downAsteroidFineMotion  ds 1
;--------------------------------------
ufoColor                = downAsteroidFineMotion
playerShipAttributes    ds 1
ufoAttributes           ds 1
;--------------------------------------
asteroidHorizDelayBits  = ufoAttributes
;--------------------------------------
upAsteroidGraphicsPtr   = playerShipAttributes
downAsteroidGraphicsPtr ds 2
;--------------------------------------
playerShipGraphicsPtr   = downAsteroidGraphicsPtr
upAsteroidSizePtr       ds 2
;--------------------------------------
playerShipOffset        = upAsteroidSizePtr
tmpAsteroidCollisionIdx ds 1
;--------------------------------------
downAsteroidSizePtr     = tmpAsteroidCollisionIdx
;--------------------------------------
tmpPlayerGraphicLSB     = downAsteroidSizePtr
tmpCopyrightChar        ds 1
;--------------------------------------
tmpAsteroidType         = tmpCopyrightChar
;--------------------------------------
tmpShieldUsageCounter   = tmpAsteroidType
;--------------------------------------
tmpUFOGraphicLSB        = tmpShieldUsageCounter
upMovingAsteroidSize    ds 1
;--------------------------------------
tmpCollisionObjectId    = upMovingAsteroidSize
;--------------------------------------
downMovingAsteroidSize  = tmpCollisionObjectId
;--------------------------------------
joystickValue           = downMovingAsteroidSize
;--------------------------------------
livesGraphicIndex       = joystickValue
;--------------------------------------
loopCount               = livesGraphicIndex
;--------------------------------------
tmpCollisionIdObjB      = loopCount
copyrightGraphicPointers ds 12
;--------------------------------------
tmpNewUFODirectionValue = copyrightGraphicPointers
;--------------------------------------
tmpAsteroidBubbleUpBoundary = tmpNewUFODirectionValue
;--------------------------------------
tmpObjectIndex          = tmpAsteroidBubbleUpBoundary
;--------------------------------------
tmpDiv10Remainder       = tmpObjectIndex
;--------------------------------------
tmpObjectPixelValue     = tmpDiv10Remainder
;--------------------------------------
tmpPlayerShipReflectValue = tmpObjectPixelValue
;--------------------------------------
tmpSoundEngineValues    = tmpPlayerShipReflectValue
;--------------------------------------
tmpStartingAsteroidIdx  = tmpSoundEngineValues
;--------------------------------------
tmpRectLeftObjA         = tmpStartingAsteroidIdx
;--------------------------------------
tmpPlayerShipVelocity   = tmpRectLeftObjA
;--------------------------------------
tmpUFOMissileDirection  = tmpPlayerShipVelocity
;--------------------------------------
tmpInitNumberOfAsteroids = tmpUFOMissileDirection
;--------------------------------------
tmpRemainingLives       = tmpInitNumberOfAsteroids
;--------------------------------------
digitPointers           = tmpRemainingLives
;--------------------------------------
tmpAsteroidAttribute    = digitPointers + 1
;--------------------------------------
tmpNonExistentAsteroidIdx = tmpAsteroidAttribute
;--------------------------------------
tmpMissileDirIndex      = tmpNonExistentAsteroidIdx
;--------------------------------------
tmpUFOHorizPixelValue   = tmpMissileDirIndex
;--------------------------------------
tmpStartingIdxForInsertList = tmpUFOHorizPixelValue
;--------------------------------------
tmpRectTopObjA          = tmpStartingIdxForInsertList
;--------------------------------------
tmpShipRotationIndex    = tmpRectTopObjA
;--------------------------------------
tmpPlayerShipVelocityFractionValue = tmpShipRotationIndex

   .org copyrightGraphicPointers + 2
   
tmpDivideBy4            ds 1
;--------------------------------------
downMovingAsteroidColor = tmpDivideBy4
;--------------------------------------
tmpMissileIndex         = downMovingAsteroidColor
;--------------------------------------
insertListIdxToMove     = tmpMissileIndex
;--------------------------------------
leftPF0GraphicIndex     = insertListIdxToMove
;--------------------------------------
tmpNumberValue          = leftPF0GraphicIndex
;--------------------------------------
tmpCurrentObjectId      = tmpNumberValue
;--------------------------------------
tmpCollisionIdObjA      = tmpCurrentObjectId
;--------------------------------------
tmpAsteroidIndex        = tmpCollisionIdObjA
jumpVector              ds 2
;--------------------------------------
tmpSavedStartingAsteroidIdx = jumpVector
;--------------------------------------
leftPF1MSBGraphicIndex  = tmpSavedStartingAsteroidIdx
;--------------------------------------
tmpCollisionHorizPosObjB = leftPF1MSBGraphicIndex
;--------------------------------------
tmpRectLeftObjB         = tmpCollisionHorizPosObjB
;--------------------------------------
tmpAsteroidDirection    = tmpRectLeftObjB
leftPF1LSBGraphicIndex  = jumpVector + 1
;--------------------------------------
upMovingAsteroidId      = leftPF1LSBGraphicIndex
;--------------------------------------
tmpRectTopObjB          = upMovingAsteroidId
downMovingAsteroidId    = tmpRectTopObjB + 1
;--------------------------------------
   .org downMovingAsteroidId
   
leftPF2LSBGraphicIndex  ds 1
leftPF2MSBGraphicIndex  ds 1
rightPF2GraphicIndex    ds 1
leftPF0Graphics         ds 1
leftPF1Graphics         ds 1
leftPF2Graphics         ds 1
rightPF2Graphics        ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E (BANK0)
;===============================================================================

   SEG Bank0
   .org BANK0_BASE
   .rorg BANK0_REORG
   
   jmp BANK1_Start
   
JumpToUpAsteroidKernel
   sta WSYNC
;--------------------------------------
.jmpIntoUpAsteroidKernel
   sta HMOVE                  ; 3 = @03
   sta GRP1                   ; 3 = @06   draw down moving asteroid
   stx NUSIZ1                 ; 3 = @09   set NUSIZ for down moving asteroid
   jmp (upAsteroidKernelVector);5
   
UpMovingAsteroidOnRight
   SLEEP 2                    ; 2 = @16
   SLEEP_7                    ; 7
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda upAsteroidFineMotion   ; 3         get up moving asteroid fine motion
   sta HMCLR                  ; 3 = @33   clear all horizontal motion
   sta HMP0                   ; 3 = @36   set up moving asteroid fine motion
   lda #<CheckToDrawUpMovingAsteroid;2
   sta upAsteroidKernelVector ; 3         set up moving asteroid kernel LSB
   ldx upAsteroidCoarseValue  ; 3         get up moving asteroid coarse value
   lda #0                     ; 2         don't draw up moving asteroid
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle58;2³
   sta RESP0                  ; 3 = @53
.jmpToDownAsteroidKernel
   jmp JumpToDownAsteroidKernel;3
   
.coarseMoveUpAsteroidCycle58
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle63;2³
   sta RESP0                  ; 3 = @58
   beq .jmpToDownAsteroidKernel;3         unconditional branch
   
.coarseMoveUpAsteroidCycle63
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle68;2³
   sta RESP0                  ; 3 = @63
   beq .jmpToDownAsteroidKernel;3         unconditional branch
   
.coarseMoveUpAsteroidCycle68
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle73;2³
   sta RESP0                  ; 3 = @68
   jmp JumpToDownAsteroidKernel;3
   
.coarseMoveUpAsteroidCycle73
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @73
   jmp .jmpIntoDownAsteroidKernel;3 = @76

UpMovingAsteroidOnLeft
   ldx upAsteroidCoarseValue  ; 3 = @17   get up moving asteroid coarse value
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle29;2³
   sta RESP0                  ; 3 = @24
   SLEEP 2                    ; 2
   beq .contMoveUpAsteriodOnLeft_01;3     unconditional branch
   
.coarseMoveUpAsteroidCycle29
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle34;2³
   sta RESP0                  ; 3 = @29
.contMoveUpAsteriodOnLeft_01
   SLEEP 2                    ; 2
   beq .contMoveUpAsteriodOnLeft_02;3     unconditional branch
   
.coarseMoveUpAsteroidCycle34
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle39;2³
   sta RESP0                  ; 3 = @34
.contMoveUpAsteriodOnLeft_02
   SLEEP 2                    ; 2
   beq .contMoveUpAsteriodOnLeft_03;3     unconditional branch
   
.coarseMoveUpAsteroidCycle39
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle44;2³
   sta RESP0                  ; 3 = @39
.contMoveUpAsteriodOnLeft_03
   SLEEP 2                    ; 2
   beq .jmpToDoneMoveUpAsteroidOnLeft;3   unconditional branch
   
.coarseMoveUpAsteroidCycle44
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle49;2³
   sta RESP0                  ; 3 = @44
.jmpToDoneMoveUpAsteroidOnLeft
   SLEEP 2                    ; 2
   beq .doneMoveUpAsteroidOnLeft;3        unconditional branch
   
.coarseMoveUpAsteroidCycle49
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @49
.doneMoveUpAsteroidOnLeft
   sta HMCLR                  ; 3 = @52   clear all horizontal motion
   lda upAsteroidFineMotion   ; 3         get up moving asteroid fine motion
   sta HMP0                   ; 3 = @58   set up moving asteroid fine motion
   lda #<CheckToDrawUpMovingAsteroid;2
   sta upAsteroidKernelVector ; 3         set up moving asteroid kernel LSB
   lda #0                     ; 2         don't draw up moving asteroid
   jmp JumpToDownAsteroidKernel;3
   
CheckToDrawUpMovingAsteroid
   ldx #0                     ; 2 = @16
   lda (upAsteroidSizePtr,x)  ; 6         get up moving asteroid NUSIZ value
   bne .drawUpMovingAsteroid  ; 2³
   inc upMovingAsteroidIndex  ; 5
   ldx upMovingAsteroidIndex  ; 3
   lda asteroidHorizPos,x     ; 4         get up asteroid horizontal position
   sta HMCLR                  ; 3 = @39   clear all horizontal motion
   sta upAsteroidFineMotion   ; 3         set asteroid fine motion value
   lsr                        ; 2         shift COARSE_VALUE right
   and #COARSE_VALUE >> 1     ; 2         keep up asteroid COARSE_VALUE
   sta upAsteroidCoarseValue  ; 3         set up moving asteroid coarse value
   lda #<UpMovingAsteroidKernel;2
   sta upAsteroidKernelVector ; 3         set up moving asteroid kernel LSB
   lda #0                     ; 2         don't draw up moving asteroid
   tax                        ; 2         used to set NUSIZ to ONE_COPY
   jmp JumpToDownAsteroidKernel;3
   
.drawUpMovingAsteroid
   sta HMCLR                  ; 3 = @28   clear all horizontal motion
   sta HMP0                   ; 3 = @31   set up moving asteroid fine motion
   sta upMovingAsteroidSize   ; 3         set up moving asteroid NUSIZ value
   ldx upMovingAsteroidId     ; 3         get up moving asteroid id
   lda AsteroidColorTable,x   ; 4
   sta COLUP0                 ; 3 = @44   color up moving asteroid
   ldx #0                     ; 2
   lda (upAsteroidGraphicsPtr,x);6        get up moving asteroid graphic data
   inc upAsteroidGraphicsPtr  ; 5
   inc upAsteroidSizePtr      ; 5
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   ldx upMovingAsteroidSize   ; 3
   SLEEP 2                    ; 2
   jmp .jmpIntoDownAsteroidKernel;3
   
UpMovingAsteroidKernel
   ldx upMovingAsteroidIndex  ; 3 = @17   get up moving asteroid index
   lda asteroidAttributes,x   ; 4         get up moving asteroid attribute value
   and #ASTEROID_TYPE_MASK    ; 2         keep asteroid type
   sta upAsteroidGraphicsPtr  ; 3
   sta upAsteroidSizePtr      ; 3
   sta HMCLR                  ; 3 = @32   clear all horizontal motion
   lda asteroidAttributes,x   ; 4         get up moving asteroid attribute value
   and #ASTEROID_ID_MASK      ; 2         keep ASTEROID_ID value
   sta upMovingAsteroidId     ; 3 = @41   set asteroid id
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   tya                        ; 2         move scan line to accumulator
   cmp asteroidVertPos,x      ; 4         compare with asteroid scan line
   bne .skipUpAsteroidDraw    ; 2³        branch if not time to draw asteroid
   lda upAsteroidFineMotion   ; 3         get asteroid fine motion value
   ror                        ; 2         shift OBJECT_SIDE to carry
   ldx #<UpMovingAsteroidOnLeft;2
   bcs .upMovingAsteroidOnLeft; 2³        branch if asteroid on the left
   ldx #<UpMovingAsteroidOnRight;2
   stx upAsteroidKernelVector ; 3
   lda #0                     ; 2
   tax                        ; 2
   jmp .jmpIntoDownAsteroidKernel;3 = @76
   
.upMovingAsteroidOnLeft
   stx.w upAsteroidKernelVector;4 = @69
   lda #0                     ; 2
   tax                        ; 2
   jmp .jmpIntoDownAsteroidKernel;3
   
.skipUpAsteroidDraw
   lda #0                     ; 2 = @58
   tax                        ; 2
   jmp JumpToDownAsteroidKernel;3 = @63
   
.endKernel
   jmp EndKernel              ; 3
   
   FILL_BOUNDARY 256, 0
   
JumpToDownAsteroidKernel
   sta WSYNC
;--------------------------------------
.jmpIntoDownAsteroidKernel
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw up moving asteroid
   stx NUSIZ0                 ; 3 = @09   set NUSIZ for up moving asteroid
   jmp (downAsteroidKernelVector);5
   
DownMovingAsteroidOnRight
   iny                        ; 2         increment scan line count
   SLEEP_7                    ; 7
   cpy #H_KERNEL              ; 2
   beq .endKernel             ; 2³ + 1
   lda downAsteroidFineMotion ; 3         get down moving asteroid fine motion
   sta HMCLR                  ; 3 = @33   clear all horizontal motion
   sta HMP1                   ; 3 = @36   set down moving asteroid fine motion
   lda #<CheckToDrawDownMovingAsteroid;2
   sta downAsteroidKernelVector;3         set down moving asteroid kernel LSB
   ldx downAsteroidCoarseValue; 3         get down moving asteroid coarse value
   lda #0                     ; 2         don't draw down moving asteroid
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle58;2³
   sta RESP1                  ; 3 = @53
.jmpToUpAsteroidKernel
   jmp JumpToUpAsteroidKernel ; 3
   
.coarseMoveDownAsteroidCycle58
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle63;2³
   sta RESP1                  ; 3 = @58
   beq .jmpToUpAsteroidKernel ; 3         unconditional branch
   
.coarseMoveDownAsteroidCycle63
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle68;2³
   sta RESP1                  ; 3 = @63
   beq .jmpToUpAsteroidKernel ; 3         unconditional branch
   
.coarseMoveDownAsteroidCycle68
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle73;2³
   sta RESP1                  ; 3 = @68
   jmp JumpToUpAsteroidKernel ; 3
   
.coarseMoveDownAsteroidCycle73
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @73
   jmp .jmpIntoUpAsteroidKernel;3
   
DownMovingAsteroidOnLeft
   ldx downAsteroidCoarseValue; 3 = @17
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle29;2³
   sta RESP1                  ; 3 = @24
   SLEEP 2                    ; 2
   beq .contMoveDownAsteriodOnLeft_01;3   unconditional branch
   
.coarseMoveDownAsteroidCycle29
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle34;2³
   sta RESP1                  ; 3 = @29
.contMoveDownAsteriodOnLeft_01
   SLEEP 2                    ; 2
   beq .contMoveDownAsteriodOnLeft_02;3   unconditional branch
   
.coarseMoveDownAsteroidCycle34
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle39;2³
   sta RESP1                  ; 3 = @34
.contMoveDownAsteriodOnLeft_02
   SLEEP 2                    ; 2
   beq .contMoveDownAsteriodOnLeft_03;3   unconditional branch
   
.coarseMoveDownAsteroidCycle39
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle44;2³
   sta RESP1                  ; 3 = @39
.contMoveDownAsteriodOnLeft_03
   SLEEP 2                    ; 2
   beq .contMoveDownAsteriodOnLeft_04;3   unconditional branch
   
.coarseMoveDownAsteroidCycle44
   dex                        ; 2
   bne .coarseMoveDownAsteroidCycle49;2³
   sta RESP1                  ; 3 = @44
.contMoveDownAsteriodOnLeft_04
   SLEEP 2                    ; 2
   beq .doneMoveDownAsteroidOnLeft;3      unconditional branch
   
.coarseMoveDownAsteroidCycle49
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @49
.doneMoveDownAsteroidOnLeft
   sta HMCLR                  ; 3 = @52   clear all horizontal motion
   lda downAsteroidFineMotion ; 3         get down moving asteroid fine motion
   sta HMP1                   ; 3 = @58   set down moving asteroid fine motion
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .endKernelDownMovingAsteroidKernel;2³
   lda #<CheckToDrawDownMovingAsteroid;2
   sta downAsteroidKernelVector;3         set down moving asteroid kernel LSB
   lda #0                     ; 2         don't draw down moving asteroid
   SLEEP 2                    ; 2
   jmp .jmpIntoUpAsteroidKernel;3 = @76
   
CheckToDrawDownMovingAsteroid
   ldx #0                     ; 2 = @16
   lda (downAsteroidSizePtr,x); 6         get down moving asteroid NUSIZ value
   bne .drawDownMovingAsteroid; 2³
   inc downMovingAsteroidIndex; 5
   ldx downMovingAsteroidIndex; 3
   lda asteroidHorizPos,x     ; 4         get down asteroid horizontal position
   sta HMCLR                  ; 3 = @33   clear all horizontal motion
   sta downAsteroidFineMotion ; 3         set asteroid fine motion value
   lsr                        ; 2         shift COARSE_VALUE right
   and #COARSE_VALUE >> 1     ; 2         keep down asteroid COARSE_VALUE
   sta downAsteroidCoarseValue; 3         set down moving asteroid coarse value
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .endKernelDownMovingAsteroidKernel;2³
   lda #<DownMovingAsteroidKernel;2
   sta downAsteroidKernelVector;3         set down moving asteroid kernel LSB
   lda #0                     ; 2         don't draw down moving asteroid
   tax                        ; 2         used to set NUSIZ to ONE_COPY
   jmp JumpToUpAsteroidKernel ; 3
   
.drawDownMovingAsteroid
   sta HMCLR                  ; 3 = @28   clear all horizontal motion
   sta HMP1                   ; 3 = @31   set down moving asteroid fine motion
   sta downMovingAsteroidSize ; 3         set down moving asteroid NUSIZ value
   ldx downMovingAsteroidId   ; 3         get down moving asteroid id
   lda AsteroidColorTable,x   ; 4
   sta COLUP1                 ; 3 = @44   color down moving asteroid
   ldx #0                     ; 2
   lda (downAsteroidGraphicsPtr,x);6      get down moving asteroid graphic data
   inc downAsteroidGraphicsPtr; 5
   inc downAsteroidSizePtr    ; 5
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .endKernelDownMovingAsteroidKernel;2³
   ldx downMovingAsteroidSize ; 3
   SLEEP 2                    ; 2
   jmp .jmpIntoUpAsteroidKernel;3
   
.endKernelDownMovingAsteroidKernel
   jmp EndKernel              ; 3
   
DownMovingAsteroidKernel
   ldx downMovingAsteroidIndex; 3 = @17   get down moving asteroid index
   lda asteroidAttributes,x   ; 4         get attribute value for asteroid
   and #ASTEROID_TYPE_MASK    ; 2         keep asteroid type
   sta downAsteroidGraphicsPtr; 3
   sta downAsteroidSizePtr    ; 3
   sta HMCLR                  ; 3         clear all horizontal motion
   lda asteroidAttributes,x   ; 4         get attribute value for asteroid
   and #ASTEROID_ID_MASK      ; 2         mask to get asteroid id
   sta downMovingAsteroidId   ; 3
   tya                        ; 2         move scan line to accumulator
   cmp asteroidVertPos,x      ; 4
   bne .skipDownAsteroidDraw  ; 2³ + 1
   lda downAsteroidFineMotion ; 3         get asteroid fine motion value
   ror                        ; 2         shift OBJECT_SIDE value to carry
   ldx #<DownMovingAsteroidOnLeft;2
   bcs .downMovingAsteroidOnLeft;2³ + 1   branch if asteroid on the left
   ldx #<DownMovingAsteroidOnRight;2
   stx downAsteroidKernelVector;3
   lda #0                     ; 2
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .jmpIntoEndKernelCrossBoundary_00;2³ + 1
   tax                        ; 2
   jmp .jmpIntoUpAsteroidKernel;3
   
.jmpIntoEndKernelCrossBoundary_01
   jmp JumpIntoEndKernel      ; 3
   
   FILL_BOUNDARY 256, 0
   
.downMovingAsteroidOnLeft
   stx downAsteroidKernelVector;3
   lda #0                     ; 2
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .jmpIntoEndKernelCrossBoundary_01;2³ + 1
   tax                        ; 2
   jmp .jmpIntoUpAsteroidKernel;3
   
.skipDownAsteroidDraw
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   beq .endKernelDownMovingAsteroidKernel;2³ + 1
   lda #0                     ; 2
   tax                        ; 2
   jmp JumpToUpAsteroidKernel ; 3
   
.jmpIntoEndKernelCrossBoundary_00
   jmp JumpIntoEndKernel      ; 3
   
ScoreKernel
   ldx livesGraphicIndex      ; 3
   lda leftPF0Graphics        ; 3         get the graphics for left PF0
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
.scoreKernelLoop
   sta PF0                    ; 3 = @03
   lda leftPF1Graphics        ; 3
   sta PF1                    ; 3 = @09
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @15
   lda StackedLivesIndicators,x;4
   sta GRP0                   ; 3 = @22
   lda SingleLivesIndicators,x; 4
   sta GRP1                   ; 3 = @29
   dex                        ; 2
   lda #0                     ; 2
   sta PF0                    ; 3 = @36
   ldy leftPF1MSBGraphicIndex ; 3
   sta PF1                    ; 3 = @42
   lda (digitPointers),y      ; 5
   ldy rightPF2Graphics       ; 3
   sty PF2                    ; 3 = @53
   ldy leftPF0Graphics        ; 3         get graphics for left PF0
   sty PF0                    ; 3 = @59
   ldy leftPF1Graphics        ; 3
   SLEEP 2                    ; 2
   sty PF1                    ; 3 = @67
   ldy leftPF1LSBGraphicIndex ; 3
   ora (digitPointers),y      ; 5
;--------------------------------------
   sta leftPF1Graphics        ; 3 = @02   set graphics for left PF1
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @08
   ldy leftPF2LSBGraphicIndex ; 3
   lda (digitPointers),y      ; 5
   ldy leftPF2MSBGraphicIndex ; 3
   ora (digitPointers),y      ; 5
   sta leftPF2Graphics        ; 3
   ldy rightPF2GraphicIndex   ; 3         get the right PF2 graphic index
   lda (digitPointers),y      ; 5         load graphic data for right PF2
   ldy rightPF2GraphicIndex   ; 3
   ldy #0                     ; 2
   sty PF0                    ; 3 = @43
   sty PF1                    ; 3 = @46
   ldy rightPF2Graphics       ; 3
   sty PF2                    ; 3 = @52
   sta rightPF2Graphics       ; 3
   ldy leftPF0GraphicIndex    ; 3
   lda (digitPointers),y      ; 5
   sta leftPF0Graphics        ; 3         store value for left PF0
   SLEEP 2                    ; 2
   dec digitPointers          ; 5
   bpl .scoreKernelLoop       ; 2³
;--------------------------------------
   sta PF0                    ; 3 = @02
   lda leftPF1Graphics        ; 3
   sta PF1                    ; 3 = @08
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @14
   lda StackedLivesIndicators,x;4
   sta GRP0                   ; 3 = @21
   lda SingleLivesIndicators,x; 4
   sta GRP1                   ; 3 = @28
   lda frameCount             ; 3         get current frame count
   ror                        ; 2
   lda #0                     ; 2
   sta PF0                    ; 3 = @38   clear playfield graphic registers
   sta PF1                    ; 3 = @41
   bcs StartAsteroidsKernel   ; 2³
   bcc StartPlayerKernel      ; 3
   
StartAsteroidsKernel
   lda rightPF2Graphics       ; 3
   sta PF2                    ; 3 = @50
   ldx #NUM_ASTEROIDS         ; 2
   lda asteroidAttributes,x   ; 4         get attribute value for asteroid
   and #ASTEROID_ID_MASK      ; 2         mask to get asteroid id
   sta downMovingAsteroidId   ; 3
   tax                        ; 2         move asteroid id to x
   lda AsteroidColorTable,x   ; 4         read color value for asteroid id
   sta downMovingAsteroidColor; 3
   lda leftPF0Graphics        ; 3         get the graphic value for PF0
   sta PF0                    ; 3 = @76   draw last line of score kernel
;--------------------------------------
   lda leftPF1Graphics        ; 3
   sta PF1                    ; 3 = @06
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @12
   ldx #0                     ; 2
   lda asteroidAttributes,x   ; 4         get attribute value for asteroid
   and #ASTEROID_ID_MASK      ; 2         mask to get asteroid id
   sta upMovingAsteroidId     ; 3
   tax                        ; 2         move asteroid id to x
   lda AsteroidColorTable,x   ; 4         read color value for asteroid id
   tax                        ; 2
   lda #0                     ; 2
   ldy #$FF                   ; 2
   sta PF0                    ; 3 = @38   clear playfield graphics
   sta PF1                    ; 3 = @41
   SLEEP 2                    ; 2
   lda rightPF2Graphics       ; 3
   sta PF2                    ; 3 = @49
   lda #0                     ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   stx COLUP0                 ; 3 = @64   color up moving asteroid
   sta GRP0                   ; 3 = @67   clear player graphic data
   sta GRP1                   ; 3 = @70
   sta PF2                    ; 3 = @73   clear PF2 graphic data
   ldx downMovingAsteroidColor; 3         get down moving asteroid color
;--------------------------------------
   sta HMOVE                  ; 3
   stx COLUP1                 ; 3 = @06   color down moving asteroid
   sta NUSIZ1                 ; 3 = @09   set asteroid 1 sprite to ONE_COPY
   jmp (upAsteroidKernelVector);5

StartPlayerKernel SUBROUTINE
   lda rightPF2Graphics       ; 3 = @49
   sta PF2                    ; 3 = @52
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   lda leftPF0Graphics        ; 3
   sta PF0                    ; 3 = @70
   lda leftPF1Graphics        ; 3
   sta PF1                    ; 3 = @76
;--------------------------------------
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @06
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   ldx #<ENABL                ; 2
   txs                        ; 2
   lda #0                     ; 2
   sta PF0                    ; 3 = @45
   sta PF1                    ; 3 = @48
   lda rightPF2Graphics       ; 3
   sta PF2                    ; 3 = @54
   lda #0                     ; 2
   tay                        ; 2
   ldx playerMissile2Color    ; 3
   sta GRP0                   ; 3 = @64
   sta GRP1                   ; 3 = @67
   sta GRP0                   ; 3 = @70
   sta PF2                    ; 3 = @73
   stx COLUPF                 ; 3 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   lda playerHorizPos         ; 3         get player ship horizontal position
   ror                        ; 2         shift OBJECT_SIDE to carry
   and #COARSE_VALUE >> 1     ; 2         mask to get coarse value
   tax                        ; 2         move course value to x
   bcs .playerShipOfLeft      ; 2³        branch if ship on left
   lda playerShipColor        ; 3
   sta COLUP0                 ; 3 = @20
   lda playerShipAttributes   ; 3
   sta VDELP0                 ; 3 = @26
   sta REFP0                  ; 3 = @29
   lda playerHorizPos         ; 3         get player ship horizontal position
   sta HMP0                   ; 3 = @35   set player's fine motion value
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @40
   SLEEP_6                    ; 6
   dex                        ; 2
   bne .coarseMovePlayerCycle58;2³
   sta RESP0                  ; 3 = @53
   beq PositionUFOHorizontally; 3         unconditional branch
   
.coarseMovePlayerCycle58
   dex                        ; 2
   bne .coarseMovePlayerCycle63;2³
   sta RESP0                  ; 3 = @58
   beq PositionUFOHorizontally; 3         unconditional branch
   
.coarseMovePlayerCycle63
   dex                        ; 2
   bne .coarseMovePlayerCycle68;2³
   sta RESP0                  ; 3 = @63
   beq PositionUFOHorizontally; 3         unconditional branch
   
.coarseMovePlayerCycle68
   dex                        ; 2
   bne .coarseMovePlayerCycle73;2³
   sta RESP0                  ; 3 = @68
   beq PositionUFOHorizontally; 3         unconditional branch
   
.coarseMovePlayerCycle73
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @73
   beq .jmpIntoPositionUFOHorizontally;3  unconditional branch
   
.playerShipOfLeft
   SLEEP 2                    ; 2
.coarseMovePlayerShip
   dex                        ; 2
   bne .coarseMovePlayerShip  ; 2
   sta RESP0                  ; 3
   lda playerHorizPos         ; 3         get player ship horizontal position
   sta HMP0                   ; 3         set player's fine motion value
   lda playerShipColor        ; 3
   sta COLUP0                 ; 3
   lda playerShipAttributes   ; 3
   sta VDELP0                 ; 3
   sta REFP0                  ; 3
   stx NUSIZ0                 ; 3
PositionUFOHorizontally
   sta WSYNC
;--------------------------------------
.jmpIntoPositionUFOHorizontally
   sta HMOVE                  ; 3
   lda ufoHorizPos            ; 3         get UFO horizontal position
   ror                        ; 2         shift OBJECT_SIDE value to carry
   and #COARSE_VALUE >> 1     ; 2         mask to get coarse value
   tax                        ; 2
   bcs .ufoOnLeftSide         ; 2³
   lda ufoColor               ; 3
   sta COLUP1                 ; 3 = @20
   lda ufoAttributes          ; 3
   sta VDELP1                 ; 3 = @26
   sta HMCLR                  ; 3 = @29   clear all horizontal motion
   lda ufoHorizPos            ; 3         get UFO horizontal position
   sta HMP1                   ; 3 = @35   set player's fine motion value
   SLEEP_6                    ; 6
   lda #ONE_COPY              ; 2
   sta NUSIZ1                 ; 3 = @46
   dex                        ; 2
   bne .coarseMoveUFOCycle58  ; 2³
   sta RESP1                  ; 3 = @53
   beq DoPlayerKernel         ; 3         unconditional branch
   
.coarseMoveUFOCycle58
   dex                        ; 2
   bne .coarseMoveUFOCycle63  ; 2³
   sta RESP1                  ; 3 = @58
   beq DoPlayerKernel         ; 3         unconditional branch
   
.coarseMoveUFOCycle63
   dex                        ; 2
   bne .coarseMoveUFOCycle68  ; 2³
   sta RESP1                  ; 3 = @63
   beq DoPlayerKernel         ; 3         unconditional branch
   
.coarseMoveUFOCycle68
   dex                        ; 2
   bne .coarseMoveUFOCycle73  ; 2³
   sta RESP1                  ; 3 = @68
   beq DoPlayerKernel         ; 3         unconditional branch
   
.coarseMoveUFOCycle73
   dex                        ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @73
   beq .jmpIntoDoPlayerKernel ; 3         unconditional branch
   
.ufoOnLeftSide
   SLEEP 2                    ; 2
.coarseMoveUFO
   dex                        ; 2
   bne .coarseMoveUFO         ; 2³
   sta RESP1                  ; 3
   sta HMCLR                  ; 3         clear all horizontal motion
   lda ufoHorizPos            ; 3         get UFO horizontal position
   sta HMP1                   ; 3         set player's fine motion value
   lda ufoColor               ; 3
   sta COLUP1                 ; 3
   lda ufoAttributes          ; 3
   sta VDELP1                 ; 3
   stx NUSIZ1                 ; 3
DoPlayerKernel
   sta WSYNC
;--------------------------------------
.jmpIntoDoPlayerKernel
   sta HMOVE                  ; 3 = @03
   stx GRP1                   ; 3 = @06   draw UFO sprite
   cpy ufoMissileVertPos      ; 3
   php                        ; 3 = @12   enable/disable UFO missile (i.e. BALL)
   cpy playerM2VertPos        ; 3
   php                        ; 3 = @18   enable/disable 2nd missile (i.e. M1)
   cpy playerM1VertPos        ; 3
   php                        ; 3 = @24   enable/disable 1st missile (i.e. M0)
   ldx #0                     ; 2
.checkToDrawPlayerShip
   lda (playerShipGraphicsPtr,x);6        read graphics data for player ship
   cmp #SPRITE_END            ; 2
   beq .skipIncrementShipGraphPtr;2³
   inc playerShipGraphicsPtr  ; 5         increment sprite LSB value
   bne .prepareToDrawUFO      ; 3 + 1     unconditional branch
   
.skipIncrementShipGraphPtr
   cpy playerShipOffset       ; 3
   bne .skipPlayerShipDraw    ; 2³ + 1
   lda tmpPlayerGraphicLSB    ; 3
   sta playerShipGraphicsPtr  ; 3
   jmp .checkToDrawPlayerShip ; 3
   
.skipPlayerShipDraw
   txa                        ; 2         a = 0
.prepareToDrawUFO
   sta HMCLR                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw player ship sprite
   ldx #0                     ; 2
.checkToDrawUFO
   lda (ufoGraphicsPtr,x)     ; 6         get graphics data for UFO
   cmp #SPRITE_END            ; 2
   beq .skipIncrementUFOGraphPtr;2³
   inc ufoGraphicsPtr         ; 5         increment sprite LSB value
   bne .prepareToDrawPlayerShip;3         unconditional branch
   
.skipIncrementUFOGraphPtr
   cpy ufoVertPos             ; 3
   bne .skipUFODraw           ; 2³
   lda tmpUFOGraphicLSB       ; 3
   sta ufoGraphicsPtr         ; 3
   jmp .checkToDrawUFO        ; 3
   
.skipUFODraw
   txa                        ; 2         a = 0
.prepareToDrawPlayerShip
   ldx #<ENABL                ; 2
   txs                        ; 2
   tax                        ; 2
   iny                        ; 2         increment scan line
   cpy #H_KERNEL              ; 2
   bne DoPlayerKernel         ; 2³ + 1
EndKernel
   sta WSYNC
;--------------------------------------
JumpIntoEndKernel
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   sta ENABL                  ; 3 = @11
   sta ENAM0                  ; 3 = @14
   sta ENAM1                  ; 3 = @17
   jmp JumpToOverscan         ; 3
   
SetupScoreKernel
   bit gameState                    ; check current game state
   bvc ShowPlayerNumberOrLivesRemaining;branch if not showing select screen
   lda gameSelection                ; get current game selection
   and #<~SELECT_DEBOUNCE_MASK
   bpl .showGameSelection           ; branch if not CHILD_GAME
   cmp #CHILD_GAME
   bne .setGameSelectionForTwoPlayerChild;branch if not ONE_PLAYER CHILD_GAME
   lda #33
   bne SetupForGameSelectionDisplay ; unconditional branch
   
.setGameSelectionForTwoPlayerChild
   lda #66
   bne SetupForGameSelectionDisplay ; unconditional branch
   
.showGameSelection
   tax                              ; move game selection to x register
   inx                              ; increment game selection for display
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   beq .movePlayerSelectionValue    ; branch if ONE_PLAYER_GAME option
   inx                              ; increment game selection for display
.movePlayerSelectionValue
   txa                              ; move game selection value to accumulator
SetupForGameSelectionDisplay
   ldx #0                           ; set x to initial div10 quotient
.divideGameSelectionBy10
   cmp #10
   bcc .doneDivideGameSelectionBy10
   inx                              ; increment quotient
   sec
   sbc #10                          ; subtract game selection by 10
   bcs .divideGameSelectionBy10     ; unconditional branch
   
.doneDivideGameSelectionBy10
   sta tmpDiv10Remainder
   txa                              ; move game selection to accumulator
   asl                              ; multiply value by 16
   asl
   asl
   asl
   ora tmpDiv10Remainder            ; combine with div10 remainder
   sta activePlayerScore + 1        ; set tens value for game selection
   lda #0
   sta activePlayerScore            ; set thousands value for game selection
   lda #<Blank
   sta leftPF2MSBGraphicIndex
   ldx #<oneLSB
   lda gameSelection                ; get current game selection
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   beq .setPF2GraphicsIndexes       ; branch if ONE_PLAYER_GAME
   ldx #<twoLSB
.setPF2GraphicsIndexes
   stx rightPF2GraphicIndex
   jmp ShowLivesShipIcons
   
ShowPlayerNumberOrLivesRemaining SUBROUTINE
   lda playerState                  ; get current player state
   ror                              ; rotate GAME_OVER flag to carry
   bcc ShowNumberOfLivesKernel      ; branch if game not over
   lda #<oneLSB
   bit gameState                    ; check current game state
   bpl .setPF2GraphicsIndexes       ; branch if player 1 is active
   lda #<twoLSB
   bne .setPF2GraphicsIndexes       ; unconditional branch
   
ShowNumberOfLivesKernel
   lda activePlayerAttributes       ; get current player attributes
   and #LIVES_MASK                  ; keep number of remaining lives
   lsr                              ; divide by 4
   lsr
   sta tmpDivideBy4                 ; save value for later
   lsr                              ; divide value by 16
   lsr
   adc tmpDivideBy4                 ; add in div4 so value is * 5
   adc #<zeroLSB
.setPF2GraphicsIndexes
   sta rightPF2GraphicIndex
   lda #<zeroMSB
   sta leftPF2MSBGraphicIndex
ShowLivesShipIcons
   lda #0
   lsr                              ; shift number lives to lower nybbles
   lsr
   lsr
   lsr
   cmp #MAX_DISPLAY_LIVES + 2
   bcc .setupToShowLivesShipIcons
   lda #MAX_DISPLAY_LIVES + 1
.setupToShowLivesShipIcons
   tax
   lda LivesGraphicIndexTable,x
   sta WSYNC                        ; wait for next scan line
   sta livesGraphicIndex
   lda LivesHMOVEValues,x
   sta HMP0                         ; set fine motion for GRP0
   asl                              ; shift values left to move fine motion
   asl                              ; value for GRP1 to upper nybbles
   asl
   asl
   sta HMP1                         ; set fine motion for GRP1
   lda LivesNUSIZValues,x
   sta NUSIZ0                       ; set size for GRP0
   lsr                              ; shift values right to move size values
   lsr                              ; for GRP1 to lower nybbles
   lsr
   lsr
   sta NUSIZ1                       ; set size for GRP1
   ldy LivesCoarseMoveValues,x
.coarseMoveLivesIndicators
   dey
   bpl .coarseMoveLivesIndicators
   sta RESP0
   sta RESP1
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   lda #>NumberFonts
   sta digitPointers + 1
   lda #<[zeroMSB + H_DIGITS] - 1
   sta digitPointers
   lda activePlayerScore + 1        ; get score tens value
   and #$0F                         ; mask upper nybbles
   sta tmpNumberValue               ; save value for later
   asl                              ; multiply by 4
   asl
   adc tmpNumberValue               ; add in original (i.e. multiply by 5)
   adc #<zeroLSB
   sta leftPF2LSBGraphicIndex
   lda activePlayerScore + 1        ; get score tens value
   and #$F0                         ; mask lower nybbles
   lsr                              ; divide the value by 4
   lsr
   sta tmpDivideBy4                 ; save the value for later
   lsr                              ; divide the value by 16
   lsr                              ; add in original
   adc tmpDivideBy4                 ; (i.e. multiply by 5/16)
   adc #<zeroPF1LSB
   sta leftPF1LSBGraphicIndex
   lda activePlayerScore            ; get score thousands value
   and #$0F                         ; mask upper nybbles
   sta tmpNumberValue               ; save value for later
   asl                              ; multiply by 4
   asl
   adc tmpNumberValue               ; add in original (i.e. multiply by 5)
   adc #<zeroPF1MSB
   sta leftPF1MSBGraphicIndex
   lda activePlayerScore            ; get score thousands value
   and #$F0                         ; mask lower nybbles
   lsr                              ; divide the value by 4
   lsr
   sta tmpDivideBy4                 ; save the value for later
   lsr                              ; divide the value by 16
   lsr                              ; add in original
   adc tmpDivideBy4                 ; (i.e. multiply by 5/16)
   sta leftPF0GraphicIndex
   ldx #0
   ldy #<Blank
.suppressZerosLoop
   lda leftPF0GraphicIndex,x
   beq .suppressZero
   cmp #<zeroLSB
   beq .suppressZero
   cmp #<zeroPF1MSB
   beq .suppressZero
   cmp #<zeroPF1LSB
   bne .doneSuppressZeros
.suppressZero
   sty leftPF0GraphicIndex,x
   inx
   cpx #4
   bne .suppressZerosLoop
.doneSuppressZeros
   sta HMCLR
   ldy leftPF0GraphicIndex
   lda (digitPointers),y
   sta leftPF0Graphics
   ldy leftPF1MSBGraphicIndex
   lda (digitPointers),y
   ldy leftPF1LSBGraphicIndex
   ora (digitPointers),y
   sta leftPF1Graphics
   ldy leftPF2LSBGraphicIndex
   lda (digitPointers),y
   ldy leftPF2MSBGraphicIndex
   ora (digitPointers),y
   sta leftPF2Graphics
   ldy rightPF2GraphicIndex
   lda (digitPointers),y
   sta rightPF2Graphics
   dec digitPointers
   lda #COLORS_RESERVED_LIVES
   sta COLUP0
   sta COLUP1
   lda #COLORS_PLAYER1_SCORE
   bit gameState                    ; check current game state
   bpl .setScoreColorValue          ; branch if player 1 is active
   lda #COLORS_PLAYER2_SCORE
.setScoreColorValue
   eor scoreColorEOR
   sta COLUPF                       ; color player score values
   lda #NO_REFLECT
   sta VDELP0                       ; turn off vertical delay on GRP0
   sta VDELP1                       ; turn off vertical delay on GRP1
   sta REFP0                        ; set GRP0 not to reflect
.waitTime
   lda INTIM
   bne .waitTime
   jmp ScoreKernel
   
JumpToOverscan
   lda #<Overscan
   sta jumpVector
   lda #>Overscan
   sta jumpVector + 1
   jmp SwitchToBank1

BANK0_Start
   lda #<BANK1_Start
   sta jumpVector
   lda #>BANK1_Start
   sta jumpVector + 1
   jmp SwitchToBank1

   FILL_BOUNDARY 256, 0

SetObjectHorizValue SUBROUTINE
   ldy asteroidHorizPos,x           ; get object's horizontal position
   stx tmpObjectIndex               ; save object index
   tax                              ; shift number of pixels to x register
   bcs .objectTravelingWest
.objectTravelingEast
   lda EastMovementHorizPosTable,y  ; get East movement value from table
   tay                              ; movement value doubles as table index
   dex                              ; decrement number of pixels to move
   bne .objectTravelingEast
   beq .doneMovingObjectHoriz       ; unconditional branch
   
.objectTravelingWest
   lda WestMovementHorizPosTable,y  ; get West movement value from table
   tay                              ; movement value doubles as table index
   dex                              ; decrement number of pixels to move
   bne .objectTravelingWest
.doneMovingObjectHoriz
   ldx tmpObjectIndex               ; restore object index value
   sta asteroidHorizPos,x           ; set object's new horizontal position value
   ldy #>DoneDetermineObjectHorizValue
   sty jumpVector + 1
   ldy #<DoneDetermineObjectHorizValue
   sty jumpVector
   jmp SwitchToBank1
   
   FILL_BOUNDARY 256, 0
   
EastMovementHorizPosTable
   .byte $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
   .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
   .byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
   .byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
   .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
   .byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
   .byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
   .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
   .byte $62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$63,$6D,$6E,$32,$00,$00
   .byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F
   .byte $90,$91,$92,$65,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
   .byte $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
   .byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
   .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
   .byte $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
   .byte $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF

WestMovementHorizPosTable
   .byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
   .byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
   .byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
   .byte $40,$41,$8D,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
   .byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
   .byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
   .byte $00,$00,$00,$8A,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D
   .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
   .byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F
   .byte $A0,$A1,$A2,$A3,$A4,$A5,$A6,$A7,$A8,$A9,$AA,$AB,$AC,$AD,$AE,$AF
   .byte $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$BC,$BD,$BE,$BF
   .byte $C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC,$CD,$CE,$CF
   .byte $D0,$D1,$D2,$D3,$D4,$D5,$D6,$D7,$D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
   .byte $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
   .byte $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF
   .byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
   
GetUpAsteroidSizeValue
   ldy #0
   lda (upAsteroidSizePtr),y
   ldy #>DetermineUpAsteroidKernelVector
   sty jumpVector + 1
   ldy #<DetermineUpAsteroidKernelVector
   sty jumpVector
   jmp SwitchToBank1

GetDownAsteroidSizeValue
   ldy #0
   lda (downAsteroidSizePtr),y
   ldy #>DetermineDownAsteroidKernelVector
   sty jumpVector + 1
   ldy #<DetermineDownAsteroidKernelVector
   sty jumpVector
   jmp SwitchToBank1

   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $45,$B9,$B4,$4B,$B5,$4B,$BC,$4B,$B4,$4B,$F4,$4B,$B4,$5B,$34,$3B
         .byte $B4,$FB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B0,$4A,$B4,$4B,$BB,$4D,$BD
         .byte $45,$BB,$A4,$0B,$F4,$4B,$F4,$0B,$A4,$BB,$94,$9B,$44,$BB,$44,$BB
         .byte $44,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4A,$B4,$49,$B4,$43,$BD
         .byte $41,$BC,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$6B,$D4,$9B,$A4,$0B,$74,$BB
         .byte $64,$3B,$4B,$B4,$4B,$B0,$4F,$B4,$4B,$B0,$4F,$B1,$46,$BF,$44,$BB
         .byte $44,$BB,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$94,$5B,$34,$BB,$24,$9B
         .byte $54,$9B,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B0,$4B,$B4
         .byte $4B,$B4,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$94,$AB,$74,$FB,$54,$DB
         .byte $E4,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4A,$B4,$42,$B5,$4C,$BB
         .byte $4C,$BA,$B4,$4B,$B4,$49,$B4,$4B,$B4,$4B,$B4,$5B,$A4,$5B,$94,$0B
         .byte $B4,$EB,$4B,$B4,$4B,$B4,$4B,$B0,$4C,$B5,$4B,$B1,$46,$BF,$4A,$BB
         .byte $44,$BA,$B4,$4B,$94,$6B,$F4,$1B,$D4,$1B,$74,$2B,$44,$BB,$44,$BB
         .byte $44,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4F,$B2,$4E,$B0,$43,$BA
         .byte $41,$B8

      ELSE

         .byte $45,$B9,$B4,$4B,$B5,$4B,$BC,$4B,$B4,$4B,$F4,$4B,$B4,$5B,$34,$3B
         .byte $B4,$FB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B0,$4A,$B4,$4B,$BB,$4D,$BD
         .byte $45,$BB,$A4,$0B,$F4,$4B,$F4,$0B,$A4,$BB,$94,$9B,$44,$BB,$44,$BB
         .byte $44,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$49,$B4,$43,$BD
         .byte $41,$BC,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$6B,$D4,$9B,$A4,$0B,$74,$BB
         .byte $64,$3B,$4B,$B4,$4B,$B0,$4F,$B4,$4B,$B4,$4F,$B1,$46,$BF,$44,$BB
         .byte $44,$BB,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$94,$5B,$34,$BB,$24,$9B
         .byte $54,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4
         .byte $4B,$B4,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$94,$AB,$34,$FB,$54,$DB
         .byte $E4,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4A,$B4,$42,$B5,$4C,$BB
         .byte $4C,$BA,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$5B,$B4,$5B,$94,$0B
         .byte $B4,$EB,$4B,$B4,$4B,$B4,$4B,$B0,$4C,$B5,$4B,$B1,$46,$BF,$4A,$BB
         .byte $44,$BA,$B4,$4B,$94,$6B,$F4,$1B,$D4,$1B,$74,$2B,$44,$BB,$44,$BB
         .byte $44,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4F,$B2,$4E,$B0,$43,$BA
         .byte $41,$B8

      ENDIF

CopyrightData
Copyright_00
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $84 ; |X....X..|
   .byte $B4 ; |X.XX.X..|
   .byte $A4 ; |X.X..X..|
   .byte $B4 ; |X.XX.X..|
   .byte $84 ; |X....X..|
   .byte $78 ; |.XXXX...|
Copyright_01
   .byte $00 ; |........|
   .byte $C6 ; |XX...XX.|
   .byte $CE ; |XX..XXX.|
   .byte $DE ; |XX.XXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F6 ; |XXXX.XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $C6 ; |XX...XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $FC ; |XXXXXX..|
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
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FC ; |XXXXXX..|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
Copyright_03
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $CE ; |XX..XXX.|
   .byte $DC ; |XX.XXX..|
   .byte $F8 ; |XXXXX...|
   .byte $CE ; |XX..XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FC ; |XXXXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
Copyright_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
Copyright_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FC ; |XXXXXX..|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|

      IF COMPILE_REGION = PAL50

         .byte $4C,$BA,$44,$BA,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$34,$0B,$B4,$6B
         .byte $34,$3B,$54,$7B,$4B,$B4,$4F,$B6,$4B,$B8,$4B,$B0,$4C,$B1,$4F,$BF
         .byte $44,$BB,$44,$BB,$B4,$4B,$B4,$4B,$B4,$4B,$34,$4B,$B4,$0B,$94,$FB
         .byte $E4,$AB,$C4,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4F,$B4,$4B,$BC,$4F,$BC
         .byte $42,$BA,$46,$BF,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$34,$0B,$B4,$0B
         .byte $24,$6B,$64,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$BE,$4D,$B3
         .byte $4D,$BB,$42,$BB

      ELSE

         .byte $4C,$BA,$44,$BA,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$34,$0B,$B4,$6B
         .byte $34,$3B,$54,$7B,$4B,$B4,$4F,$B6,$4B,$B8,$4B,$B0,$4C,$B1,$4F,$BF
         .byte $44,$BB,$44,$BB,$B4,$4B,$B4,$4B,$B4,$4B,$34,$4B,$B4,$0B,$94,$DB
         .byte $E4,$AB,$C4,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$BC,$4F,$BC
         .byte $42,$BA,$46,$BF,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$34,$0B,$B4,$0B
         .byte $24,$6B,$64,$BB,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$B4,$4B,$BE,$4D,$B3
         .byte $4D,$BB,$42,$BB

      ENDIF
      
DisplayCopyrightInfo SUBROUTINE
   lda #THREE_COPIES
   sta VDELP0                       ; set player objects to vertical delay
   sta VDELP1
   sta NUSIZ0                       ; set to show 3 copies of the players
   sta NUSIZ1
   lda #COLORS_COPYRIGHT
   sta COLUP0
   sta COLUP1
   ldx #6
   sta WSYNC                        ; wait for next scan line
   SLEEP 2
.coarseMovePlayers
   dex
   bpl .coarseMovePlayers
   sta RESP0                        ; coarse move GRP0 to pixel 102
   sta RESP1                        ; coarse move GRP1 to pixel 111
   lda #HMOVE_L1
   sta HMP1                         ; move GRP1 left one pixel (i.e. pixel 110)
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
SetCopyrightGraphicPointers
   lda #>CopyrightData
   sta copyrightGraphicPointers + 1
   sta copyrightGraphicPointers + 3
   sta copyrightGraphicPointers + 5
   sta copyrightGraphicPointers + 7
   sta copyrightGraphicPointers + 9
   sta copyrightGraphicPointers + 11
   lda #<Copyright_00
   sta copyrightGraphicPointers
   lda #<Copyright_01
   sta copyrightGraphicPointers + 2
   lda #<Copyright_02
   sta copyrightGraphicPointers + 4
   lda #<Copyright_03
   sta copyrightGraphicPointers + 6
   lda #<Copyright_04
   sta copyrightGraphicPointers + 8
   lda #<Copyright_05
   sta copyrightGraphicPointers + 10
   ldx #H_COPYRIGHT - 1
   stx loopCount
   ldx #$FF
CopyrightVerticalSync
.waitTime
   lda INTIM
   bne .waitTime
   stx VBLANK                       ; disable TIA (i.e D1 = 1)
   stx VSYNC                        ; start vertical sync (i.e. D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC                        ; end vertical sync (i.e D1 = 0)
   lda #COPYRIGHT_VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
CopyrightVerticalBlanking SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldx #[(COPYRIGHT_KERNEL_SCANLINES - H_COPYRIGHT) / 2]
.centerCopyrightVert
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .centerCopyrightVert   ; 2³
   lda #ENABLE_TIA            ; 2
   sta VBLANK                 ; 3 = @09   enable TIA (D1 = 0)
.drawCopyrightInfo
   ldy loopCount              ; 3
   lda (copyrightGraphicPointers),y; 5
   sta GRP0                   ; 3
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   lda (copyrightGraphicPointers + 2),y;5
   sta GRP1                   ; 3 = @10
   lda (copyrightGraphicPointers + 4),y;5
   sta GRP0                   ; 3 = @18
   lda (copyrightGraphicPointers + 6),y;5
   tax                        ; 2
   lda (copyrightGraphicPointers + 8),y;5
   sta tmpCopyrightChar       ; 3
   lda (copyrightGraphicPointers + 10),y;5
   ldy tmpCopyrightChar       ; 3
   stx GRP1                   ; 3 = @44
   sty GRP0                   ; 3 = @47
   sta GRP1                   ; 3 = @50
   sta GRP0                   ; 3 = @53
   dec loopCount              ; 5
   bpl .drawCopyrightInfo     ; 2³
   ldx #[(COPYRIGHT_KERNEL_SCANLINES - H_COPYRIGHT) / 2];2
.skipBottomLinesForCopyright
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bpl .skipBottomLinesForCopyright;2³
   lda #COPYRIGHT_OVERSCAN_TIME;2
   sta TIM64T                 ; 4         set timer for copyright overscan time
   inc copyrightFrameCount    ; 5
   beq .endCopyrightKernel    ; 2³        do copyright for 256 frames (i.e. ~4 sec)
   jmp SetCopyrightGraphicPointers
   
.endCopyrightKernel
   lda #ONE_COPY              ; 2
   sta VDELP0                 ; 3 = @23
   sta VDELP1                 ; 3 = @26
   sta NUSIZ0                 ; 3 = @29
   sta NUSIZ1                 ; 3 = @32
   lda #<StartGameWithoutCollisionsSet;2 
   sta jumpVector             ; 3
   lda #>StartGameWithoutCollisionsSet;2
   sta jumpVector + 1         ; 3
   jmp SwitchToBank1          ; 3

      IF COMPILE_REGION = PAL50

         .byte $B4,$5B,$74,$3B,$34,$BB,$44,$3B,$04,$BB,$4B,$B4,$4B,$BE,$4B,$BC
         .byte $4F,$B5,$45,$BA,$44,$BB,$44,$BB,$44,$B9,$B4,$4B,$B4,$4B,$B4,$4B
         .byte $B4,$4B,$B4,$5B,$B4,$DB,$F4,$7B,$B4,$AB,$4F,$BA,$4A,$B5,$44,$B3
         .byte $4C,$BB,$4C,$B9,$44,$BB,$44,$BB,$44,$BB,$BB,$45,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$09,$BA,$43,$BC,$0B,$F0,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$45,$BB,$05,$BA,$57,$B5,$43,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BA,$44,$BB,$44,$BB,$44
         .byte $BB,$45,$B9,$47,$B9,$47,$F9,$42,$B8,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BA,$47
         .byte $BA,$47,$BF,$47,$B8,$4B,$B4,$43,$B4,$43,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$46,$B1,$47,$BA,$47,$BE,$44,$44,$BB,$44,$3B,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$45,$B8,$47,$BE,$47
         .byte $BE,$4E,$BA,$43,$90,$43,$B4,$1B,$6C,$89,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45
         .byte $BA,$47,$B5,$0B,$BC,$4F,$BC,$4B,$B4,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$45,$BA,$45
         .byte $BB,$40,$BE,$4F,$B9,$47,$B4,$43,$9C,$5B,$CC,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

      ELSE

         .byte $B4,$5B,$74,$3B,$34,$BB,$44,$BB,$04,$BB,$4B,$B4,$4B,$BE,$4B,$BC
         .byte $4F,$B5,$45,$BA,$44,$BB,$46,$BB,$44,$B9,$B4,$4B,$B4,$4B,$B4,$4B
         .byte $B4,$4B,$B4,$5B,$B4,$DB,$F4,$7B,$B4,$AB,$4F,$BA,$4A,$B5,$44,$B3
         .byte $4C,$BB,$4C,$B9,$44,$BB,$44,$BB,$44,$BB,$BB,$45,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$49,$BA,$43,$BC,$0B,$F0,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$45,$BB,$05,$BA,$57,$B5,$43,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$45,$B9,$47,$B9,$47,$F9,$42,$B8,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BA,$47
         .byte $BA,$47,$BF,$47,$B8,$4B,$B4,$43,$B4,$43,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$46,$B1,$47,$BA,$47,$BE,$44,$44,$BB,$44,$3B,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BA,$47,$BE,$47
         .byte $BF,$4E,$BA,$43,$90,$43,$B4,$1B,$6C,$89,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45
         .byte $BA,$47,$B5,$0B,$BC,$4F,$BC,$4B,$B4,$4B,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$BB,$44,$BB,$45,$BA,$45
         .byte $BB,$40,$BE,$4F,$B9,$47,$B4,$43,$9C,$5B,$CC,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

      ENDIF

   ELSE

   FILL_BOUNDARY 1024, 0

   ENDIF
   
NumberFonts
zeroMSB
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
oneMSB
   .byte $E0 ; |XXX.....|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $60 ; |.XX.....|
   .byte $40 ; |.X......|
twoMSB
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
threeMSB
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
fourMSB
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
fiveMSB
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
sixMSB
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
sevenMSB
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
eightMSB
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
nineMSB
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
zeroLSB
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
oneLSB
   .byte $0E ; |....XXX.|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $06 ; |.....XX.|
   .byte $04 ; |.....X..|
twoLSB
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
threeLSB
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
fourLSB
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
fiveLSB
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
sixLSB
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
sevenLSB
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
eightLSB
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
nineLSB
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|

PF1NumberFonts
zeroPF1MSB
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
onePF1MSB
   .byte $70 ; |.XXX....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $60 ; |.XX.....|
   .byte $20 ; |..X.....|
twoPF1MSB
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
threePF1MSB
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
fourPF1MSB
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
fivePF1MSB
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
sixPF1MSB
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
sevenPF1MSB
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
eightPF1MSB
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
ninePF1MSB
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
zeroPF1LSB
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
onePF1LSB
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
twoPF1LSB
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
threePF1LSB
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
fourPF1LSB
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
fivePF1LSB
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $07 ; |.....XXX|
sixPF1LSB
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
sevenPF1LSB
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
eightPF1LSB
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
ninePF1LSB
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   
StackedLivesIndicators
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
SingleLivesIndicators
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   
   IF COPYRIGHT_ROM
   
      IF COMPILE_REGION = PAL50

         .byte $B8,$4B,$BE,$03,$BC,$0B,$FC,$CB,$54,$0B,$44,$BB,$54,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

      ELSE

         .byte $B8,$4B,$BE,$03,$BC,$0B,$FC,$CB,$54,$0B,$44,$BB,$54,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

HorizMoveSizeTable
LargeAsteroidHorizMoveSizeTable_00
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_L1 | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_R1 | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_L1 | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_R1 | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_L1 | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_R1 | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte 0

   FILL_BOUNDARY 16, 0
   
LargeAsteroidHorizMoveSizeTable_01
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_L1 | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_R1 | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte 0

   FILL_BOUNDARY 32, 0
   
MediumAsteroidHorizMoveSizeTable
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0
   
   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $BC,$43,$FC,$4B,$BC,$0B,$B4,$0B

      ELSE

         .byte $BC,$43,$FC,$4B,$BC,$4B,$F4,$0B

      ENDIF

   ENDIF

   FILL_BOUNDARY 48, 0

SmallAsteroidHorizMoveSizeTable
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0
   
   IF COPYRIGHT_ROM

      .byte $BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

   ENDIF

   FILL_BOUNDARY 64, 0

AsteroidExplosionLargeHorizMoveSizeTable_00
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0

   IF COPYRIGHT_ROM

      .byte $3C,$4B,$B4,$0B

   ENDIF

   FILL_BOUNDARY 80, 0

AsteroidExplosionLargeHorizMoveSizeTable_01
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0

   IF COPYRIGHT_ROM

      .byte $44,$BB,$44,$BB

   ENDIF

   FILL_BOUNDARY 96, 0

AsteroidExplosionMediumAsteroidHorizMoveSizeTable
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0

   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $45,$BA,$43,$BE,$4A,$BE,$4B

      ELSE

         .byte $45,$BA,$43,$BE,$4B,$B2,$4B

      ENDIF

   ENDIF

   FILL_BOUNDARY 112, 0

AsteroidExplosionSmallAsteroidHorizMoveSizeTable
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0
   
AsteroidColorTable
   .byte COLORS_ASTEROID_00, COLORS_ASTEROID_01
   .byte COLORS_ASTEROID_02, COLORS_ASTEROID_03
   .byte COLORS_ASTEROID_04, COLORS_ASTEROID_05
   .byte COLORS_ASTEROID_06, COLORS_ASTEROID_07

LivesGraphicIndexTable
   .byte (H_RESERVED_SHIPS * 1) - 1
   .byte (H_RESERVED_SHIPS * 1) - 1
   .byte (H_RESERVED_SHIPS * 2) - 1
   .byte (H_RESERVED_SHIPS * 3) - 1
   .byte (H_RESERVED_SHIPS * 3) - 1
   .byte (H_RESERVED_SHIPS * 3) - 1
   .byte (H_RESERVED_SHIPS * 3) - 1
   .byte (H_RESERVED_SHIPS * 3) - 1

LivesHMOVEValues
   .byte HMOVE_L5 | HMOVE_L5 >> 4
   .byte HMOVE_L5 | HMOVE_L5 >> 4
   .byte HMOVE_L2 | HMOVE_L5 >> 4
   .byte HMOVE_R5 | HMOVE_R4 >> 4
   .byte HMOVE_L3 | HMOVE_L4 >> 4
   .byte HMOVE_R4 | HMOVE_R3 >> 4
   .byte HMOVE_L4 | HMOVE_L5 >> 4
   .byte HMOVE_L4 | HMOVE_L5 >> 4

LivesNUSIZValues
   .byte ONE_COPY << 4     | ONE_COPY
   .byte ONE_COPY << 4     | ONE_COPY
   .byte ONE_COPY << 4     | ONE_COPY
   .byte ONE_COPY << 4     | ONE_COPY
   .byte ONE_COPY << 4     | TWO_COPIES
   .byte TWO_COPIES << 4   | TWO_COPIES
   .byte TWO_COPIES << 4   | THREE_COPIES
   .byte THREE_COPIES << 4 | THREE_COPIES
   
LivesCoarseMoveValues
   .byte 0, 0, 2, 1, 1, 0, 0, 0
   
   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $BB,$44,$BB,$BB,$44,$BB,$45,$BB,$44,$BA,$41,$BF,$01,$B8,$43,$BC
         .byte $4B,$FC,$C3,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45,$BA,$45,$BA,$45,$BE,$23,$F4
         .byte $4B,$BC,$4B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45,$BB,$45,$BE,$43,$BE,$43,$BC
         .byte $0B,$B4,$4B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB

      ELSE

         .byte $BB,$44,$BB,$BB,$44,$BB,$45,$BB,$44,$BA,$41,$BF,$01,$B0,$43,$BC
         .byte $4B,$FC,$C3,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45,$BA,$45,$BA,$45,$BE,$23,$F4
         .byte $4B,$BC,$4B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB,$BB,$44,$BB,$44,$BB,$45,$BB,$45,$BE,$43,$BE,$43,$BC
         .byte $0B,$B4,$4B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44
         .byte $BB,$44,$BB

      ENDIF

   ENDIF

   FILL_BOUNDARY 0, 0

AsteroidSprites
LargeAsteroid_00
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $1C ; |...XXX..|
   .byte $1E ; |...XXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|

   IF COPYRIGHT_ROM

      .byte $43

   ENDIF

   FILL_BOUNDARY 16, 0

LargeAsteroid_01
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|

   IF COPYRIGHT_ROM

      .byte $BB

   ENDIF

   FILL_BOUNDARY 32, 0

MediumAsteroid
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $0C ; |....XX..|

   IF COPYRIGHT_ROM

      .byte $43,$BE,$4B,$BC,$4B,$B4,$5B,$B4,$5B

   ENDIF

   FILL_BOUNDARY 48, 0

SmallAsteroid
   .byte $60 ; |.XX.....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $20 ; |..X.....|

   IF COPYRIGHT_ROM

      .byte $44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB

   ENDIF

   FILL_BOUNDARY 64, 0
   
AsteroidExplosionSprites
AsteroidExplosionLarge_00
   .byte $A0 ; |X.X.....|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $09 ; |....X..X|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $88 ; |X...X...|
   .byte $01 ; |.......X|
   .byte $10 ; |...X....|
   .byte $40 ; |.X......|
   .byte $11 ; |...X...X|

   IF COPYRIGHT_ROM

      .byte $43,$B4,$4B,$B4,$4B

   ENDIF

   FILL_BOUNDARY 80, 0

AsteroidExplosionLarge_01
   .byte $48 ; |.X..X...|
   .byte $02 ; |......X.|
   .byte $20 ; |..X.....|
   .byte $88 ; |X...X...|
   .byte $01 ; |.......X|
   .byte $40 ; |.X......|
   .byte $14 ; |...X.X..|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
   .byte $21 ; |..X....X|
   .byte $84 ; |X....X..|

   IF COPYRIGHT_ROM

      .byte $BB,$44,$BB,$44,$BB

   ENDIF

   FILL_BOUNDARY 96, 0

AsteroidExplosionMedium
   .byte $50 ; |.X.X....|
   .byte $02 ; |......X.|
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $41 ; |.X.....X|

   IF COPYRIGHT_ROM

      .byte $BC,$41,$B4,$43,$B6,$49,$B0,$5B

   ENDIF

   FILL_BOUNDARY 112, 0

AsteroidExplosionSmall
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $80 ; |X.......|
   .byte $20 ; |..X.....|

PlayerShipSprites
PlayerRotation_00
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte SPRITE_END
PlayerRotation_01
   .byte $20 ; |..X.....|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $30 ; |..XX....|
   .byte SPRITE_END
PlayerRotation_02
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte SPRITE_END
PlayerRotation_03
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
   .byte SPRITE_END
PlayerRotation_04
   .byte $04 ; |.....X..|
   .byte $1C ; |...XXX..|
   .byte $FC ; |XXXXXX..|
   .byte $1C ; |...XXX..|
   .byte $04 ; |.....X..|
   .byte SPRITE_END
PlayerRotation_05
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
   .byte SPRITE_END
PlayerRotation_06
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $30 ; |..XX....|
   .byte $40 ; |.X......|
   .byte SPRITE_END
PlayerRotation_07
   .byte $30 ; |..XX....|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $20 ; |..X.....|
   .byte SPRITE_END
PlayerRotation_08
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte SPRITE_END

PlayerExplosionGraphics
PlayerExplosion_00
   .byte $10 ; |...X....|
   .byte $02 ; |......X.|
   .byte $08 ; |....X...|
   .byte $22 ; |..X...X.|
   .byte $08 ; |....X...|
   .byte SPRITE_END
PlayerExplosion_01
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $80 ; |X.......|
   .byte $04 ; |.....X..|
   .byte $A2 ; |X.X...X.|
   .byte SPRITE_END
PlayerExplosion_02
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $22 ; |..X...X.|
   .byte $10 ; |...X....|
   .byte $04 ; |.....X..|
   .byte SPRITE_END
   
PlayerShieldSprite
   .byte $38 ; |..XXX...|
   .byte $44 ; |.X...X..|
   .byte $54 ; |.X.X.X..|
   .byte $44 ; |.X...X..|
   .byte $38 ; |..XXX...|
   .byte SPRITE_END

UFOSprite
   .byte $10 ; |...X....|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte SPRITE_END
SatelliteSprite
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte SPRITE_END

   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $B4,$CB,$74,$8B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44,$BB,$4C,$BE,$43,$BE,$41
         .byte $B4,$49,$B6,$0B

      ELSE

         .byte $B4,$CB,$74,$8B,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB,$44,$BB
         .byte $44,$BB,$44,$BB,$BB,$44,$BB,$44,$BB,$44,$BB,$4C,$BE,$43,$BE,$40
         .byte $B4,$49,$B6,$0B

      ENDIF

   ENDIF

   FILL_BOUNDARY 240, 0

SwitchToBank1
   sta BANK1STROBE
   jmp (jumpVector)
   
   IF COPYRIGHT_ROM

      IF COMPILE_REGION = PAL50

         .byte $44,$BB,$44,$FF

      ELSE

         .byte $44,$BB,$44,$00
      
      ENDIF

   ELSE

   FILL_BOUNDARY 248, 0

   .byte 0, 0                       ; hotspot locations not available for data

   ENDIF
   
   echo "***", (FREE_BYTES)d, "BYTES OF BANK0 FREE"
   
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

Overscan
   ldx #$FF
   txs                              ; set stack to the beginning
   lda #GAME_OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET to carry
   ror                              ; shift SELECT to carry and RESET to D7
   bcs .clearSelectDebounce         ; branch if SELECT not pressed
   bit gameSelection                ; check current game selection
   bvs .selectSwitchDown            ; branch if SELECT switch held down
   lda gameSelection                ; get current game selection
   ora #SELECT_HELD
   sta gameSelection                ; set to show SELECT button down
   lda gameState                    ; get current game state
   ora #SHOW_SELECT_SCREEN          ; set to show select screen
   sta gameState
   lda playerState                  ; get current player state
   ora #GAME_OVER
   sta playerState                  ; set player state to GAME_OVER
   lda #VERT_OUT_OF_RANGE
   sta playerVertPos
   sta ufoVertPos
   lda #0
   sta frameCount
   sta frameCount + 1
   sta activePlayerAttributes       ; clear active player lives and direction
   sta reservedPlayerVariables      ; clear reserved player lives and direction
.selectSwitchDown
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET to carry
   lda frameCount                   ; get current frame count
   and #SELECT_DELAY                ; game selection changed ~every second
   bcs .checkToIncrementGameSelection;branch if RESET not pressed
   and #SELECT_AND_RESET_DELAY      ; game selection changed ~1/2 second
.checkToIncrementGameSelection
   bne .doneGameSelection
   inc gameSelection                ; increment game selection
   lda gameSelection                ; get current game selection
   ldx #4
.checkToWrapGameSelection
   dex
   bmi .doneGameSelection
   cmp GameSelectionValues,x
   bne .checkToWrapGameSelection
   lda WrapAroundGameSelectionValues,x
   sta gameSelection
.doneGameSelection
   jmp FindOutOfRangeAsteroids
   
.clearSelectDebounce
   lda gameSelection                ; get current game selection
   and #<~SELECT_DEBOUNCE_MASK
   sta gameSelection                ; clear select debounce flag
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET to carry
   bcs FindOutOfRangeAsteroids      ; branch if RESET not pressed
   lda #BLACK
   sta COLUBK                       ; set background color to BLACK
   ldx #<asteroidVertPos
.clearGameRAM
   sta VSYNC,x
   inx
   bne .clearGameRAM
   lda #INIT_NUM_LIVES << 4
   sta activePlayerAttributes       ; set initial number of lives
   sta reservedPlayerAttributes
   lda #INIT_PLAYER_Y
   sta playerVertPos
   jmp StartGameWithCollisionsSet
   
FindOutOfRangeAsteroids
   ldx #START_UP_MOVING_ASTEROID_IDX
.findUpMovingOutOfRangeAsteroid
   lda asteroidVertPos,x            ; get up moving asteroid vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .foundUpMovingOutOfRangeAsteroid
   inx
   bpl .findUpMovingOutOfRangeAsteroid;unconditional branch
   
.foundUpMovingOutOfRangeAsteroid
   cpx #START_UP_MOVING_ASTEROID_IDX
   beq .setOutOfRangeUpAsteroid
   dex
.setOutOfRangeUpAsteroid
   stx upMovingAsteroidLinkListEndIndex
   ldx #START_DOWN_MOVING_ASTEROID_IDX
.findDownMovingOutOfRangeAsteroid
   lda asteroidVertPos,x            ; get down moving asteroid vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .foundDownMovingOutOfRangeAsteroid
   inx
   bpl .findDownMovingOutOfRangeAsteroid;unconditional branch
   
.foundDownMovingOutOfRangeAsteroid
   cpx #START_DOWN_MOVING_ASTEROID_IDX
   beq .setOutOfRangeDownAsteroid
   dex
.setOutOfRangeDownAsteroid
   stx downMovingAsteroidLinkListEndIndex
   ldx #START_UP_MOVING_ASTEROID_IDX
   lda asteroidVertPos,x            ; get up moving asteroid vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CollisionDetection           ; branch if up moving asteroid on screen
   ldx #START_DOWN_MOVING_ASTEROID_IDX
   lda asteroidVertPos,x            ; get down moving asteroid vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CollisionDetection           ; branch if down moving asteroid on screen
   jsr InitAsteroidObjects
   jmp PlayGameSounds
   
CollisionDetection
   lda asteroidCollisionState       ; get asteroid collision state
   bne .performAsteroidCollision    ; branch if asteroid collided
   bit playerState                  ; check current player state
   bvs .shipShieldsActive           ; branch if using shields
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcs .jmpToPlayGameSounds         ; branch if game over
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CheckToPerformAsteroidCollision;branch if not in Hyperspace
   lda hyperspaceTimer              ; get Hyperspace timer value
   beq CheckToSpawnNewPlayerShip    ; branch if Hyperspace timer expired
.shipShieldsActive
   lda ufoVertPos                   ; get UFO current vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CheckToPerformAsteroidCollision;maybe asteroid hit UFO
   lda playerM1Direction
   ora playerM2Direction
   ora ufoMissileDirection
   bne CheckToPerformAsteroidCollision;maybe asteroid hit a missile
   jmp PlayGameSounds
   
CheckToSpawnNewPlayerShip
   lda playerState                  ; get current player state
   and #KILL_FLAG
   beq .repositionVerticalPlayerShipPosition;branch if player not killed
   lda ufoVertPos                   ; get UFO vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CheckToPerformAsteroidCollision;branch if UFO present
   lda ufoMissileDirection          ; get UFO missile direction
   bne CheckToPerformAsteroidCollision;branch if UFO missile present
   ldx #START_UP_MOVING_ASTEROID_IDX
   jsr CheckForFreeCenterSpace      ; check up asteroid in respawning position
   bne .jmpToPlayGameSounds         ; branch if asteroid in respawning position
   ldx #START_DOWN_MOVING_ASTEROID_IDX
   jsr CheckForFreeCenterSpace      ; check down asteroid in respawning position
   bne .jmpToPlayGameSounds         ; branch if asteroid in respawning position
.repositionVerticalPlayerShipPosition
   lda newPlayerVertPos
   sta playerVertPos
   lda #0
   ldx #5
.clearObjectPositionAdjustmentValues
   sta playerObjectPositionAdjustmentValues,x
   dex
   bpl .clearObjectPositionAdjustmentValues
   lda gameSelection                ; get current game selection
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   bne .checkToSwitchPlayers        ; branch if a TWO_PLAYER_GAME
   sta reservedPlayerAttributes
   beq .jmpToPlayGameSounds         ; unconditional branch
   
.checkToSwitchPlayers
   lda reservedPlayerAttributes
   beq .jmpToPlayGameSounds
   lda playerState                  ; get current player state
   and #KILL_FLAG
   beq .jmpToPlayGameSounds         ; branch if player not killed
   jsr SwitchToOtherPlayer
   lda #VERT_OUT_OF_RANGE
   sta upMovingAsteroidVertPos
   sta downMovingAsteroidVertPos
   lda #START_UP_MOVING_ASTEROID_IDX
   sta upMovingAsteroidIndex
   lda #START_DOWN_MOVING_ASTEROID_IDX
   sta downMovingAsteroidIndex
.jmpToPlayGameSounds
   jmp PlayGameSounds
   
CheckToPerformAsteroidCollision
   lda asteroidCollisionState       ; get asteroid collision state
   beq PerformObjectCollisions      ; branch if asteroid not collided
.performAsteroidCollision
   ldx upMovingAsteroidLinkListEndIndex;get up moving non-present asteroid index
   stx tmpNonExistentAsteroidIdx
   ldx #START_UP_MOVING_ASTEROID_IDX
   jsr CheckToSpawnNewAsteroids
   stx upMovingAsteroidLinkListEndIndex
   ldx downMovingAsteroidLinkListEndIndex;get down moving non-present asteroid index
   stx tmpNonExistentAsteroidIdx
   ldx #START_DOWN_MOVING_ASTEROID_IDX
   jsr CheckToSpawnNewAsteroids
   stx downMovingAsteroidLinkListEndIndex
   lda #0
   sta asteroidCollisionState       ; set to show asteroid not collided
   beq .jmpToPlayGameSounds
   
PerformObjectCollisions
.performObjectCollisions
   lda objectCollisionState         ; get object collision state values
   bit objectCollisionState
   bpl .checkUFOCollisionState
   eor #MISSILE_COLLISION_MASK_PLAYER;flip MISSILE_COLLISION_MASK_PLAYER values
   sta objectCollisionState
   bvc .checkMissile2Collisions
   lda playerM1Direction            ; get player missile 1 direction
   beq .performObjectCollisions     ; branch if missile 1 not active
.checkMissile1Collisions
   lda playerM1VertPos              ; get missile 1 vertical position
   ldy playerM1HorizPos             ; get missile 1 horizontal position
   ldx #ID_SHOT1
   jsr CheckAsteroidCollisions      ; check ID_SHOT1 colliding with asteroid
   ldy ufoVertPos                   ; get UFO vertical position
   cpy #VERT_OUT_OF_RANGE
   beq .jmpPlayGameSounds           ; branch if UFO inactive
   jsr DetermineActiveUFOId
   ldy ufoHorizPos
   jsr CheckObjectCollisions
.jmpPlayGameSounds
   jmp PlayGameSounds
   
.checkMissile2Collisions
   lda playerM2Direction            ; get the player's missile 2 direction
   beq .performObjectCollisions     ; branch if missile 2 not active
   lda playerM2VertPos              ; get missile 2 vertical position
   ldy playerM2HorizPos             ; get missile 2 horizontal position
   ldx #ID_SHOT2
   jsr CheckAsteroidCollisions      ; check ID_SHOT2 colliding with asteroid
   ldy ufoVertPos                   ; get UFO vertical position
   cpy #VERT_OUT_OF_RANGE
   beq .doneCheckMissile2Collisions ; branch if UFO inactive
   jsr DetermineActiveUFOId
   ldy ufoHorizPos                  ; get UFO horizontal position
   jsr CheckObjectCollisions
.doneCheckMissile2Collisions
   jmp PlayGameSounds
   
.checkUFOCollisionState
   and #COLLISION_MASK_UFO          ; keep COLLISION_MASK_UFO values
   tax                              ; move COLLISION_MASK_UFO to x register
   inc objectCollisionState
   lda objectCollisionState         ; get object collision state values
   ora #$80                         ; set to check missile collisions next
   tay                              ; move new collision state to y register
   and #COLLISION_MASK_UFO          ; keep COLLISION_MASK_UFO values
   cmp #COLLISION_MASK_UFO
   bne .setObjectCollisionState
   tya                              ; move new collision state to accumulator
   and #<~COLLISION_MASK_UFO        ; clear COLLISION_MASK_UFO values
   tay                              ; move new collision state to y register
.setObjectCollisionState
   sty objectCollisionState
   dex
   bmi .checkUFOMissileCollisions
   dex
   bmi .checkUFOCollisions
   bit playerState                  ; check current player state
   bvc .checkPlayerShipCollisions   ; branch if not using shields
.checkNextObjectCollisions
   jmp .performObjectCollisions
   
.checkPlayerShipCollisions
   lda playerFeatureTimer
   bmi .doneCheckPlayerShipCollisions
   ldy playerHorizPos               ; get player ship horizontal position
   ldx #ID_PLAYER_SHIP
   lda playerVertPos                ; get player ship vertical position
   jsr CheckAsteroidCollisions
   ldy ufoVertPos                   ; get UFO vertical position
   cpy #VERT_OUT_OF_RANGE
   beq .doneCheckPlayerShipCollisions;branch if UFO not present on screen
   jsr DetermineActiveUFOId
   ldy ufoHorizPos                  ; get UFO horizontal position
   jsr CheckObjectCollisions
.doneCheckPlayerShipCollisions
   jmp PlayGameSounds
   
.checkUFOCollisions
   ldy ufoVertPos                   ; get UFO vertical position
   cpy #VERT_OUT_OF_RANGE
   beq .checkNextObjectCollisions   ; branch if UFO not present on screen
   jsr DetermineActiveUFOId
   ldy ufoHorizPos
   jsr CheckAsteroidCollisions      ; check UFO and asteroid collision
   jmp PlayGameSounds
   
.checkUFOMissileCollisions
   lda ufoMissileDirection          ; get UFO missile direction
   beq .checkNextObjectCollisions   ; branch if UFO missile not active
   lda ufoMissileVertPos            ; get UFO missile vertical position
   ldy ufoMissileHorizPos           ; get UFO missile horizontal position
   ldx #ID_SHOT_UFO
   jsr CheckAsteroidCollisions      ; check ID_SHOT_UFO colliding with asteroid
   ldy playerVertPos                ; get player vertical position
   cpy #VERT_OUT_OF_RANGE
   beq PlayGameSounds               ; branch if player not present on screen
   bit playerState                  ; check current player state
   bvs PlayGameSounds               ; branch if player shield is active
   lda playerFeatureTimer
   bmi PlayGameSounds
   ldx #ID_PLAYER_SHIP
   tya                              ; move player vertical position to accumulator
   ldy playerHorizPos               ; get player ship horizontal position
   jsr CheckObjectCollisions        ; check ID_SHOT_UFO and PLAYER_SHIP collision
PlayGameSounds
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcc .playGameSounds              ; branch if game not over
   lda #0                           ; turn off sounds for game over state
   sta AUDV0
   sta AUDV1
   jmp VerticalSync
   
.playGameSounds
   lda soundEngineValues            ; get sound engine values
   sta tmpSoundEngineValues         ; save value temporarily
   ldy #EXPLOSION_SOUND_CHANNEL
   ror tmpSoundEngineValues         ; shift SOUND_BITS_PLAYER_EXPLODE to carry
   bcc .checkForPlayingThrustSounds ; branch if not playing explosion sound
   lda frameCount                   ; get current frame count
   ror                              ; shift D0 to carry bit
   bcs .playPlayerExplosionSounds
   dec explosionSoundVolume
   bne .playPlayerExplosionSounds
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_PLAYER_EXPLODE ; clear SOUND_BITS_PLAYER_EXPLODE value
   sta soundEngineValues
   bcc .checkForPlayingThrustSounds ; unconditional branch
   
.playPlayerExplosionSounds
   ror tmpSoundEngineValues         ; shift SOUND_BITS_THRUST value to carry
   ldx #EXPLOSION_SOUND_FREQUENCY
   lda explosionSoundVolume
   bpl .setLeftAudioChannelValues   ; unconditional branch
   
.checkForPlayingThrustSounds
   ror tmpSoundEngineValues         ; shift SOUND_BITS_THRUST value to carry
   bcc .turnOffLeftAudioChannelValues;branch if not playing thrust sounds
   ldx #THRUST_SOUND_FREQUENCY
   lda #THRUST_SOUND_VOLUME
   bpl .setLeftAudioChannelValues   ; unconditional branch
   
.turnOffLeftAudioChannelValues
   lda #0
.setLeftAudioChannelValues
   sty AUDC0
   stx AUDF0
   sta AUDV0
   ror tmpSoundEngineValues         ; shift SOUND_BITS_BONUS_SHIP value to carry
   bcc .checkToPlayUFOSound         ; branch if not playing bonus ship sounds
   ldx #BONUS_SHIP_SOUND_FREQUENCY
   ldy #MAX_VOLUME
   lda bonusShipSoundTimer          ; get bonus ship sound timer value
   and #$10
   beq .setBonusShipSoundVolume     ; branch to set sound volume
   ldy #0
.setBonusShipSoundVolume
   tya                              ; move volume value to accumulator
   ldy #BONUS_SHIP_SOUND_CHANNEL
   dec bonusShipSoundTimer
   bne .setRightAudioChannelValues
   lda soundEngineValues            ; get sound engine values
   and #<~[SOUND_BITS_PLAYER_SHOT | SOUND_BITS_BONUS_SHIP]
   sta soundEngineValues
   inc bonusShipSoundTimer          ; value = 1
   jmp .turnOffRightAudioChannelValues
   
.checkToPlayUFOSound
   ror tmpSoundEngineValues         ; shift SOUND_BITS_UFO value to carry
   bcc .checkToPlayPlayerShotSound  ; branch if not playing UFO sound
   ldx #UFO_SOUND_FREQUENCY
   lda gameState                    ; get current game state
   and #UFO_FLAG                    ; keep UFO_FLAG value
   bne .playUFOSounds               ; branch if UFO is active
   ldx #SATELLITE_SOUND_FREQUENCY
.playUFOSounds
   lda frameCount                   ; get current frame count
   and #2
   beq .setUFOChannelAndVolume
   dex                              ; decrement frequency by 2
   dex
.setUFOChannelAndVolume
   ldy #UFO_SOUND_CHANNEL
   lda #UFO_SOUND_VOLUME
   bpl .setRightAudioChannelValues  ; unconditional branch
   
.checkToPlayPlayerShotSound
   ror tmpSoundEngineValues         ; shift SOUND_BITS_PLAYER_SHOT to carry
   bcc .checkToPlayHeartbeatSound   ; branch if not playing player shot sounds
   dec playerShotSoundTimer         ; decrement player shot sound timer
   bne .playPlayerShotSound
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_PLAYER_SHOT    ; clear SOUND_BITS_PLAYER_SHOT value
   ora #SOUND_HEARTBEAT_HIGH_FREQ | SOUND_HEARTBEAT_ON
   sta soundEngineValues
   lda #8
   sta heartbeatSoundTimer
.turnOffRightAudioChannelValues
   lda #0
   sta AUDV1
   jmp VerticalSync
   
.playPlayerShotSound
   ldy #PLAYER_SHOT_SOUND_CHANNEL
   lda playerShotSoundTimer         ; get player shot sound timer
   cmp #8
   bcc .determinePlayerShotSoundFrequency
   lda frameCount                   ; get current frame count
   ror                              ; shift D0 to carry
   bcc .determinePlayerShotSoundFrequency;branch on even frame
   ldy #EXPLOSION_SOUND_CHANNEL
.determinePlayerShotSoundFrequency
   lda #15
   sec
   sbc playerShotSoundTimer         ; subtract player shot sound timer
   tax                              ; set sound frequency value
   lda #PLAYER_SHOT_SOUND_VOLUME
.setRightAudioChannelValues
   sty AUDC1
   stx AUDF1
   sta AUDV1
   bpl VerticalSync                 ; unconditional branch
   
.checkToPlayHeartbeatSound
   ldy #HEARTBEAT_SOUND_CHANNEL
   dec heartbeatSoundTimer          ; decrement heartbeat sound timer
   bne .playHeartbeatSound
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_HEARTBEAT_MASK ; clear heartbeat sound values
   ror tmpSoundEngineValues         ; shift SOUND_HEARTBEAT value to carry
   bcs .playHeartbeatToInitTempo    ; branch if SOUND_HEARTBEAT_ON
   ora #SOUND_HEARTBEAT_ON
   ror tmpSoundEngineValues         ; shift SOUND_HEARTBEAT_FREQ to carry
   bcc .incrementHeartbeatTempo     ; branch if SOUND_HEARTBEAT_LOW_FREQ
   ora #SOUND_HEARTBEAT_HIGH_FREQ
.incrementHeartbeatTempo
   sta soundEngineValues
   lda frameCount + 1
   bmi .resetHeartbeatSoundTimer
   
   IF COMPILE_REGION = PAL50
   
      lda #12
   
   ELSE
   
      lda #14
   
   ENDIF

   sec
   sbc frameCount + 1
   bmi .resetHeartbeatSoundTimer
   cmp #MAX_HEARTBEAT_TIMER_VALUE
   bcs .setHeartbeatSoundTimer
.resetHeartbeatSoundTimer
   lda #MAX_HEARTBEAT_TIMER_VALUE
.setHeartbeatSoundTimer
   sta heartbeatSoundTimer
.playHeartbeatSound
   lda soundEngineValues            ; get sound engine values
   rol                              ; rotate SOUND_HEARTBEAT_ON to D7
   rol
   bmi .setHeartbeatFrequencyValue  ; branch if SOUND_HEARTBEAT_ON
   lda #0                           ; set to turn off volume for right channel
   beq .setRightAudioChannelValues  ; unconditional branch
   
.setHeartbeatFrequencyValue
   ldx #19
   bcc .setHeartbeatVolumeValue     ; branch if SOUND_HEARTBEAT_LOW_FREQ
   inx                              ; increment heartbeat frequency
.setHeartbeatVolumeValue
   lda #HEARTBEAT_SOUND_VOLUME
   bpl .setRightAudioChannelValues  ; unconditional branch
   
.playHeartbeatToInitTempo
   ror tmpSoundEngineValues         ; shift SOUND_HEARTBEAT_FREQ to carry
   bcs .setInitHeartbeatTempo       ; branch if SOUND_HEARTBEAT_HIGH_FREQ
   ora #SOUND_HEARTBEAT_HIGH_FREQ
.setInitHeartbeatTempo
   sta soundEngineValues
   lda #INIT_HEARTBEAT_TIMER_VALUE
   sta heartbeatSoundTimer
   bpl .playHeartbeatSound          ; unconditional branch
   
VerticalSync SUBROUTINE
   ldx #$FF
.waitTime
   lda INTIM
   bne .waitTime
   stx VBLANK                       ; disable TIA (i.e. D1 = 1)
   stx VSYNC                        ; start vertical sync (i.e. D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC                        ; end vertical sync (i.e. D1 = 0)
   sta VBLANK                       ; enable TIA (i.e. D1 = 0)
   lda #GAME_VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   inc frameCount                   ; increment frame count
   bne ProcessGameCalculations
   inc frameCount + 1
   bit gameState                    ; check current game state
   bvs ProcessGameCalculations      ; branch if showing select screen
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcc ProcessGameCalculations      ; branch if game in progress
   lda frameCount + 1
   bpl .checkToShowAlternatePlayerScore
   lda gameState                    ; get current game state
   ora #SHOW_SELECT_SCREEN          ; set to show select screen
   sta gameState
.checkToShowAlternatePlayerScore
   lda gameSelection                ; get current game selection
   and #NUM_PLAYERS_MASK            ; keep NUM_PLAYERS value
   beq ProcessGameCalculations      ; branch if ONE_PLAYER_GAME
   jsr SwitchToOtherPlayer          ; switch to show alternate player score
ProcessGameCalculations
   jsr NextRandom
   lda frameCount                   ; get current frame count
   ror                              ; shift D0 into carry
   bcs ProcessAsteroidCalculations  ; branch if doing asteroid kernel this frame
   jmp ProcessShipCalculations
   
ProcessAsteroidCalculations
   ldy #0
   lda asteroidHorizSpeed           ; get asteroid horizontal speed value
   sec
   sbc #[1 << 4] | 1                ; reduce SPEED_SLOW and SPEED_MEDIUM values
   cmp #1 << 4
   bcs .checkMediumSpeedValue       ; branch if SPEED_SLOW not done
   ora #SPEED_SLOW                  ; reset SPEED_SLOW value
   iny                              ; set SPEED_SLOW bit for asteroid
   iny
.checkMediumSpeedValue
   tax                              ; move difference to x register
   and #$0F                         ; keep SPEED_MEDIUM value
   bne .setAsteroidHorizontalSpeed
   txa                              ; move difference to accumulator
   ora #SPEED_MEDIUM                ; reset SPEED_MEDIUM value
   tax
   iny                              ; set SPEED_MEDIUM bit for asteroid
.setAsteroidHorizontalSpeed
   stx asteroidHorizSpeed
   tya                              ; move asteroid delay value to accumulator
   ror                              ; shift delay values to upper nybbles
   ror
   ror
   sta asteroidHorizDelayBits
   lda #<UpMovingAsteroidKernel
   sta upAsteroidKernelVector
   lda #<DownMovingAsteroidKernel
   sta downAsteroidKernelVector
   lda #>HorizMoveSizeTable
   sta downAsteroidSizePtr + 1
   ldx #START_DOWN_MOVING_ASTEROID_IDX
.moveAsteroidsDown
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #VERT_OUT_OF_RANGE           ; check to see if asteroid is visible
   beq .downMovingAsteroidNotVisible; branch if asteroid not visible
   inc asteroidVertPos,x            ; move asteroid down (i.e. increase vert pos)
   jsr MoveAsteroidHorizontally
   inx
   bne .moveAsteroidsDown           ; unconditional branch
   
.downMovingAsteroidNotVisible
   ldx downMovingAsteroidLinkListEndIndex
   lda asteroidVertPos,x            ; get list end asteroid vertical position
   cmp #VERT_OUT_OF_RANGE           ; check to see if asteroid is visible
   beq .setTopUpAsteroidMotionValues; branch if end asteroid not visible
   cmp #H_KERNEL                    ; check if asteroid reached screen bottom
   bcc .downMovingAsteroidVisible   ; branch if asteroid top on screen
   lda #VERT_OUT_OF_RANGE
   sta asteroidVertPos,x            ; set asteroid to not visible
   dec downMovingAsteroidLinkListEndIndex
   bne .downMovingAsteroidNotVisible; unconditional branch
   
.downMovingAsteroidVisible
   lda asteroidAttributes,x         ; get attribute value for asteroid
   lsr                              ; shift ASTEROID_SIZE to lower nybbles
   lsr
   lsr
   lsr
   and #ASTEROID_SIZE_MASK >> 4     ; keep ASTEROID_SIZE value
   tay                              ; move ASTEROID_SIZE value to y register
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp AsteroidLowerBound,y
   bne .setStartingDownMovingAsteroidKernelValues;branch if not reached lower bound
   stx tmpStartingIdxForInsertList
   lda #START_DOWN_MOVING_ASTEROID_IDX
   sta tmpAsteroidBubbleUpBoundary
   jsr InsertNewAsteroidIntoList    ; bubble asteroid to top of list
   lda asteroidVertPos,y            ; get asteroid vertical position
   sec
   sbc #H_KERNEL
   sta asteroidVertPos,x
.setStartingDownMovingAsteroidKernelValues
   ldx #START_DOWN_MOVING_ASTEROID_IDX
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #VERT_OUT_OF_RANGE           ; check to see if asteroid is visible
   beq .setTopUpAsteroidMotionValues; branch if asteroid is not visible
   lda asteroidHorizPos,x           ; get asteroid horizontal position
   sta downAsteroidFineMotion       ; set down asteroid fine motion value
   lsr
   and #COARSE_VALUE >> 1           ; keep coarse position value
   sta downAsteroidCoarseValue      ; set down asteroid coarse motion value
   lda asteroidVertPos,x            ; get asteroid vertical position
   bpl .setTopUpAsteroidMotionValues
   cmp #$FF
   beq .setTopUpAsteroidMotionValues
   lda asteroidHorizPos,x           ; get asteroid horizontal position
   ror                              ; shift object side value to carry
   ldy #<DownMovingAsteroidOnLeft
   bcs .setDownMovingAsteroidKernelVector;branch if asteroid on left side
   ldy #<DownMovingAsteroidOnRight
.setDownMovingAsteroidKernelVector
   sty downAsteroidKernelVector
   lda asteroidAttributes,x         ; get attribute value for asteroid
   and #ASTEROID_TYPE_MASK          ; keep asteroid type
   sec
   sbc #2
   sec
   sbc asteroidVertPos,x
   sta downAsteroidGraphicsPtr      ; set down asteroid graphics pointer
   sta downAsteroidSizePtr          ; set down asteroid size pointer
   ldy #>GetDownAsteroidSizeValue
   sty jumpVector + 1
   ldy #<GetDownAsteroidSizeValue
   sty jumpVector
   jmp SwitchToBank0
   
DetermineDownAsteroidKernelVector
   and #ASTEROID_HORIZ_ADJ_MASK     ; keep ASTEROID_HORIZ_ADJ value
   bne .setTopUpAsteroidMotionValues; branch if not adjusting horizontal motion
   lda downAsteroidFineMotion       ; get asteroid fine motion value
   clc
   adc #1 << 4
   sta downAsteroidFineMotion       ; set asteroid fine motion value
.setTopUpAsteroidMotionValues
   lda asteroidHorizPos             ; get asteroid horizontal position value
   sta upAsteroidFineMotion         ; set asteroid fine motion value
   lsr                              ; shift object side to carry
   and #COARSE_VALUE >> 1
   sta upAsteroidCoarseValue        ; set up asteroid coarse position value
   ldx #START_UP_MOVING_ASTEROID_IDX
   beq .checkNextUpMovingAsteroid   ; unconditional branch
   
.moveAsteroidUp
   dec asteroidVertPos,x            ; decrement asteroid vertical position
.calcUpAsteroidMovingHorizPosition
   jsr MoveAsteroidHorizontally
   inx
.checkNextUpMovingAsteroid
   lda asteroidVertPos,x            ; get asteroid vertical position
   beq DetermineNextUpAsteroidListEnd
   bpl .moveAsteroidUp
   cmp #VERT_OUT_OF_RANGE
   beq CheckToLaunchUFO
   bne MoveTopAsteroidUp            ; unconditional branch
   
DetermineNextUpAsteroidListEnd
   ldx upMovingAsteroidLinkListEndIndex;get end of up asteroid list index
   lda asteroidVertPos,x            ; get up asteroid list end vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .setNextUpMovingAsteroidValues;branch if asteroid out of range
   inx                              ; increment asteroid list index
.setNextUpMovingAsteroidValues
   lda #H_KERNEL
   sta asteroidVertPos,x            ; set vertical position of next up asteroid
   lda asteroidHorizPos
   sta asteroidHorizPos,x           ; set horizontal position of up asteroid
   lda asteroidAttributes           ; get attribute value for asteroid
   sta asteroidAttributes,x         ; set attributes of next up asteroid
   lda #VERT_OUT_OF_RANGE
   sta asteroidVertPos + 1,x        ; set next asteroid OUT_OF_RANGE
   inc upMovingAsteroidLinkListEndIndex
   ldx #START_UP_MOVING_ASTEROID_IDX
   beq .moveAsteroidUp              ; unconditional branch
   
MoveTopAsteroidUp
   dec upMovingAsteroidVertPos      ; decrement asteroid vertical position
   lda asteroidAttributes           ; get attribute value for asteroid
   ror                              ; shift attributes to lower nybbles
   ror
   ror
   ror
   and #ASTEROID_SIZE_MASK >> 4     ; keep asteroid size value
   tay                              ; move asteroid size value to y register
   lda upMovingAsteroidVertPos      ; get asteroid vertical position
   cmp AsteroidUpperBound,y
   beq .topUpMovingAsteroidReachedUpperLimit
   lda asteroidAttributes           ; get attribute value for asteroid
   and #ASTEROID_TYPE_MASK          ; keep asteroid type
   sec
   sbc upMovingAsteroidVertPos      ; subtract asteroid vertical position
   sec
   sbc #2
   sta upAsteroidGraphicsPtr        ; set up moving asteroid graphic pointer
   sta upAsteroidSizePtr            ; set up moving asteroid size pointer
   ldy #>GetUpAsteroidSizeValue
   sty jumpVector + 1
   ldy #<GetUpAsteroidSizeValue
   sty jumpVector
   jmp SwitchToBank0
   
DetermineUpAsteroidKernelVector
   and #ASTEROID_HORIZ_ADJ_MASK     ; keep ASTEROID_HORIZ_ADJ value
   bne .determineUpAsteroidKernelVector;branch if not adjusting horizontal motion
   lda upAsteroidFineMotion         ; get asteroid fine motion value
   clc
   adc #1 << 4
   sta upAsteroidFineMotion         ; set asteroid fine motion value
.determineUpAsteroidKernelVector
   ldy #<UpMovingAsteroidOnLeft
   lda asteroidHorizPos             ; get asteroid horizontal position
   ror                              ; shift OBJECT_SIDE to carry
   bcs .setUpMovingAsteroidKernelVector;branch if asteroid on left side
   ldy #<UpMovingAsteroidOnRight
.setUpMovingAsteroidKernelVector
   sty upAsteroidKernelVector
   bne .calcUpAsteroidMovingHorizPosition;unconditional branch
   
.topUpMovingAsteroidReachedUpperLimit
   jsr BubbleUpAsteroidList
   jmp .setTopUpAsteroidMotionValues
   
CheckToLaunchUFO
   lda SWCHB                        ; read console switches
   bit gameState                    ; check current game state
   bmi .determinePlayerDifficulty   ; branch if player 2 is active
   asl                              ; shift player 1 difficulty to D7
.determinePlayerDifficulty
   asl                              ; shift difficulty value to carry
   bcs .checkToLaunchUFO
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_UFO            ; clear UFO sound bit
   jmp .disableUFO
   
.checkToLaunchUFO
   lda ufoVertPos                   ; get UFO vertical position
   cmp #VERT_OUT_OF_RANGE
   bne MoveUFO                      ; branch if UFO present
   lda playerVertPos                ; get player vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .jmpToSetValuesForAsteroidKernel;branch if player ship not present
   lda #3
   cmp frameCount + 1
   bcs .jmpToSetValuesForAsteroidKernel
   dec explosionOffset
   bne .jmpToSetValuesForAsteroidKernel
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_UFO              ; set to play UFO sound
   sta soundEngineValues
   jsr NextRandom                   ; get new random number
   lsr                              ; shift D0 to carry
   tax
   and #UFO_DIR_FLAGS               ; keep bits for UFO vertical direction
   sta tmpNewUFODirectionValue
   lda gameState                    ; get current game state
   and #<~[UFO_DIR_FLAGS | UFO_LEFT]
   ora tmpNewUFODirectionValue
   bcc .setUFODirectionFlags
   ora #UFO_LEFT
.setUFODirectionFlags
   sta gameState
   lda #HMOVE_R5 | 5 << 1 | OBJECT_ON_RIGHT
   sta ufoHorizPos                  ; set UFO initial horizontal value
   txa                              ; move random number to accumulator
   cmp #H_KERNEL - 10
   beq .setUFOInitVerticalPosition  ; branch if position is bottom of screen
   bcc .setUFOInitVerticalPosition  ; branch if position is above bottom of screen
   sbc #H_KERNEL - 10               ; subtract the kernel height
.setUFOInitVerticalPosition
   sta ufoVertPos
   lda activePlayerScore            ; get score thousands value
   cmp #$15
   bcs .activateUFO                 ; branch if score greater than 14,990
   cmp #$07
   bcc .activateSatellite           ; branch is score less than 7,000
   jsr NextRandom                   ; get new random number
   ror                              ; shift D0 to carry
   bcc .activateUFO
.activateSatellite
   lda gameState                    ; get current game state
   and #<~UFO_FLAG                  ; clear UFO flag to activate satellite
   sta gameState
.jmpToSetValuesForAsteroidKernel
   jmp .setValuesForAsteroidKernel
   
.activateUFO
   lda gameState                    ; get current game state
   ora #UFO_FLAG                    ; set UFO_FLAG to activate UFO
   sta gameState
   bne .jmpToSetValuesForAsteroidKernel;unconditional branch
   
MoveUFO
   lda gameState                    ; get current game state
   and #UFO_DIR_FLAGS               ; keep UFO direction values
   beq CalculateUFOHorizontalPosition
   cmp #UFO_DIR_FLAGS
   beq CalculateUFOHorizontalPosition
   cmp #UFO_DIR_UP
   beq .moveUFOUp
   inc ufoVertPos                   ; move UFO down
   lda ufoVertPos                   ; get UFO vertical position
   cmp #H_KERNEL - 10
   bne DetermineNewUFOVertDirection
   beq .changeUFOVerticalDirection  ; unconditional branch
   
.moveUFOUp
   dec ufoVertPos                   ; move UFO up
   bne DetermineNewUFOVertDirection
.changeUFOVerticalDirection
   lda gameState                    ; get current game state
   eor #UFO_DIR_FLAGS               ; flip UFO direction values
   sta gameState
   jmp CalculateUFOHorizontalPosition
   
DetermineNewUFOVertDirection
   lda frameCount                   ; get current frame count
   asl
   bne CalculateUFOHorizontalPosition
   jsr NextRandom                   ; get new random number
   and #UFO_DIR_FLAGS               ; keep value for UFO direction
   sta tmpNewUFODirectionValue
   lda gameState                    ; get current game state
   and #<~UFO_DIR_FLAGS             ; remove current UFO direction
   ora tmpNewUFODirectionValue
   sta gameState                    ; set new UFO direction
CalculateUFOHorizontalPosition
   ldx #<[ufoHorizPos - asteroidHorizPos]
   lda gameState                    ; get current game state
   ror                              ; shift UFO_LEFT to carry
   jsr MoveObjectHorizontally
   lda ufoHorizPos
   cmp #HMOVE_R5 | 5 << 1 | OBJECT_ON_RIGHT
   bne CheckToLaunchUFOMissile
   lda #0
   sta explosionOffset
   lda soundEngineValues            ; get sound engine values
   and #<~[SOUND_BITS_PLAYER_SHOT | SOUND_BITS_UFO]
.disableUFO
   sta soundEngineValues
   lda #VERT_OUT_OF_RANGE
   sta ufoVertPos
   bne .jmpToSetValuesForAsteroidKernel;unconditional branch
   
CheckToLaunchUFOMissile
   lda ufoMissileDirection          ; get the UFO missile direction
   bne .jmpToSetValuesForAsteroidKernel;branch if UFO missile launched
   jsr NextRandom                   ; get new random number
   and #$0F                         ; 0 <= a <= 15
   tax                              ; set for new missile direction index
   lda gameState                    ; get current game state
   asl                              ; shift UFO flag to carry
   asl
   asl
   txa                              ; move direction index to accumulator
   bcc .launchUFOMissile            ; branch if showing satellite
   and #3                           ; keep top 4 rotation values...0 <= a <= 3
   sta tmpUFOMissileDirection
   lda ufoHorizPos                  ; get UFO horizontal position value
   jsr ConvertHorizPosToPixelValue  ; convert to color closk value
   sta tmpUFOHorizPixelValue
   lda playerHorizPos               ; get player ship horizontal position
   jsr ConvertHorizPosToPixelValue  ; convert to color clock value
   ldy #NO_REFLECT
   sec
   sbc tmpUFOHorizPixelValue        ; subtract UFO color clock value
   bcc .determineUFOMissileQuadrant ; branch if UFO to the left of player ship
   ldy #REFLECT
.determineUFOMissileQuadrant
   lda playerVertPos                ; get player vertical position
   sec
   sbc ufoVertPos                   ; subtract UFO vertical position
   tya                              ; move REFLECT value to accumulator
   bcc .playerShipAboveUFO          ; branch if player ship above UFO
   bne .incrementByOrginalDirection ; branch if UFO to the right of player ship
.rotateMissileToNextQuadrant
   clc
   adc #4
   bpl .incrementByOrginalDirection ; unconditional branch

.playerShipAboveUFO
   bne .rotateMissileToNextQuadrant ; branch if UFO to the right of player ship
.incrementByOrginalDirection
   clc
   adc tmpUFOMissileDirection
.launchUFOMissile
   tax
   ora MissileRangeTable,x
   sta ufoMissileDirection
   lda ufoHorizPos                  ; get UFO horizontal position
   sta ufoMissileHorizPos           ; set UFO missile horizontal position
   lda ufoVertPos                   ; get UFO vertical position
   clc
   adc #3
   sta ufoMissileVertPos            ; set UFO missile vertical position
.setValuesForAsteroidKernel
   lda #>AsteroidSprites
   sta upAsteroidGraphicsPtr + 1
   sta downAsteroidGraphicsPtr + 1
   lda #>HorizMoveSizeTable
   sta upAsteroidSizePtr + 1
   sta downAsteroidSizePtr + 1
   lda #>UpMovingAsteroidKernel
   sta upAsteroidKernelVector + 1
   lda #>DownMovingAsteroidKernel
   sta downAsteroidKernelVector + 1
   lda #START_UP_MOVING_ASTEROID_IDX
   sta upMovingAsteroidIndex
   lda #START_DOWN_MOVING_ASTEROID_IDX
   sta downMovingAsteroidIndex
   jmp BranchToSetupScoreKernel
   
ProcessShipCalculations
   lda #COLORS_PLAYER1_SHIP
   bit gameState                    ; check current game state
   bpl .setPlayerShipColors         ; branch if player 1 is active
   lda #COLORS_PLAYER2_SHIP
.setPlayerShipColors
   sta playerShipColor
   sta playerMissile2Color
   ldx #COLORS_UFO
   lda gameState                    ; get current game state
   and #UFO_FLAG
   beq .setUFOColors
   ldx #COLORS_SATELLITE
.setUFOColors
   stx ufoColor
   lda #0
   sta scoreColorEOR
   lda activePlayerAttributes       ; get current player attributes
   ora reservedPlayerAttributes
   and #LIVES_MASK
   bne ReadJoystickValues           ; branch if a player has lives left
   sta AUDV1                        ; turn off sound volume 1 (i.e. a = 0)
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcs .cycleBackgroundColors       ; branch if game over
   ldx #1
   stx frameCount + 1
   dex                              ; x = 0
   stx frameCount
   lda playerState                  ; get current player state
   ora #GAME_OVER
   sta playerState
.cycleBackgroundColors
   lda frameCount + 1
   rol                              ; rotate D7 to carry
   adc #1 - 1
   rol                              ; rotate D7 to carry
   adc #1 - 1
   rol                              ; rotate D7 to carry
   adc #1 - 1
   rol                              ; rotate D7 to carry
   adc #1 - 1
   and #$F7
   sta COLUBK                       ; set background color for GAME_OVER
   sta scoreColorEOR
   jmp .doneAdjustPlayerShipPositions
   
ReadJoystickValues
   lda SWCHA                        ; read joystick values
   bit gameState                    ; check current game state
   bpl .setJoystickValues           ; branch if player 1 is active
   asl                              ; shift player 2 joystick values
   asl
   asl
   asl
.setJoystickValues
   and #P0_NO_MOVE                  ; mask lower nybbles
   sta joystickValue                ; save current joystick values
   bit playerState                  ; check current player state
   bvc CheckActivePlayerShipFeatures; branch if not using shields
   and #<~MOVE_DOWN                 ; keep MOVE_DOWN value
   beq .shieldsActive
   lda playerState                  ; get current player state
   and #<~SHIELD_FLAG               ; clear shield flag
   sta playerState
   jmp CheckActivePlayerShipFeatures
   
.shieldsActive
   inc shieldTimer                  ; increment shield timer value
   lda shieldTimer
   and #MAX_SHIELD_TIME - 1
   bne .doneCheckForShieldExplosion ; branch if not reached maximum value
   lda playerState                  ; get current player state
   and #<~SHIELD_FLAG               ; turn off shields
   ora #KILL_FLAG                   ; destroy player for having shield on too long
   sta playerState
   lda #128
   sta playerFeatureTimer
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_PLAYER_EXPLODE
   and #<~SOUND_BITS_THRUST
   sta soundEngineValues
   lda #EXPLOSION_SOUND_VOLUME
   sta explosionSoundVolume
.doneCheckForShieldExplosion
   jmp PlayerShipThrustDamping
   
CheckActivePlayerShipFeatures
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .hyperspaceActiveForPlayerShip;branch if player in Hyperspace
   lda shieldTimer
   beq CheckToActivatePlayerShipFeatures
   bmi .doneCheckActivePlayerShipFeatures
   dec shieldTimer
   bpl CheckToActivatePlayerShipFeatures;unconditional branch
   
.hyperspaceActiveForPlayerShip
   lda hyperspaceTimer
   beq .doneCheckActivePlayerShipFeatures;branch if Hyperspace timer expired
   dec hyperspaceTimer
.doneCheckActivePlayerShipFeatures
   jmp .doneAdjustPlayerShipPositions
   
CheckToActivatePlayerShipFeatures
   lda joystickValue                ; get current joystick values
   cmp #[MOVE_DOWN & P0_NO_MOVE]
   bne .disablePlayerFeatures       ; branch if joystick not pushed down
   lda gameSelection                ; get current game selection
   and #PLAYER_FEATURE_MASK         ; keep PLAYER_FEATURE values
   beq .enableHyperspace            ; branch if HYPERSPACE game
   cmp #FEATURE_NONE
   beq .disablePlayerFeatures
   and #FEATURE_SHIELDS             ; keep FEATURE_SHIELDS value
   bne .activateShields
   bit playerState                  ; check current player state
   bmi CheckPlayerShipRotation      ; branch if flipping ship
   lda activePlayerAttributes       ; get current player attributes
   eor #REFLECT_MASK                ; flip REFLECT_MASK value
   sta activePlayerAttributes
   lda playerState                  ; get current player state
   ora #FLIP_FLAG                   ; enable ship flip
   sta playerState
   bne CheckPlayerShipRotation      ; unconditional branch
   
.activateShields
   lda playerState                  ; get current player state
   ora #SHIELD_FLAG                 ; turn on shields
   sta playerState
   inc shieldTimer
   bne CheckPlayerShipRotation      ; unconditional branch
   
.enableHyperspace
   lda playerState                  ; get current player state
   and #HYPERSPACE_FLAG             ; check if hyperspace already active
   bne .warpPlayerToHyperspacePosition;branch if hyperspace currently active
   lda playerState                  ; get current player state
   ora #HYPERSPACE_FLAG             ; enable hyperspace
   sta playerState
   bne CheckPlayerShipRotation      ; unconditional branch
   
.warpPlayerToHyperspacePosition
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   beq CheckPlayerShipRotation      ; branch if player is out of range
   lda #VERT_OUT_OF_RANGE
   sta playerVertPos                ; set player to be out of range
   lda playerState                  ; get current player state
   and #<~[HYPERSPACE_FLAG | KILL_FLAG];remove hyperspace and kill state
   sta playerState
   jsr NewPseudoRandomHorizPosition
   sta playerHorizPos               ; set new horizontal position for player
   lda random                       ; get low random seed
   lsr                              ; divide value by 2 (127 <= a <= 0)
   cmp #(H_KERNEL - [H_PLAYER_SHIP * 2])
   bcc .setPlayerShipHyperspaceVertPosition
   sbc #(H_KERNEL - [H_PLAYER_SHIP * 2])
.setPlayerShipHyperspaceVertPosition
   sta newPlayerVertPos
   lda #0
   ldx #5
.clearObjectPositionAdjustmentValues
   sta playerObjectPositionAdjustmentValues,x
   dex
   bpl .clearObjectPositionAdjustmentValues
   lda #MAX_HYPERSPACE_TIME
   sta hyperspaceTimer
   jmp .doneAdjustPlayerShipPositions
   
.disablePlayerFeatures
   lda playerState                  ; get current player state
   and #<~[FLIP_FLAG | SHIELD_FLAG | HYPERSPACE_FLAG]
   sta playerState
CheckPlayerShipRotation
   lda frameCount                   ; get current frame count
   ror
   ror
   bcc .skipPlayerShipRotation      ; skip ~ every quarter second
   lda activePlayerAttributes       ; get current player attributes
   and #LIVES_MASK                  ; keep remaining lives
   sta tmpRemainingLives
   asl joystickValue                ; shift MOVE_RIGHT to carry
   bcs .checkToRotateShipCounterClockwise;branch if not rotating clockwise
   dec activePlayerAttributes       ; decrement rotation value
.checkToRotateShipCounterClockwise
   asl joystickValue                ; shift MOVE_LEFT to carry
   bcs .doneCheckShipRotation       ; branch if not moving joystick to the left
   inc activePlayerAttributes       ; increment rotation value
.doneCheckShipRotation
   lda activePlayerAttributes       ; get current player attributes
   and #REFLECT_MASK | DIRECTION_MASK;clear remaining lives value
   ora tmpRemainingLives            ; combine with remaining lives
   sta activePlayerAttributes
   jmp CheckToFirePlayerMissile
   
.skipPlayerShipRotation
   asl joystickValue
   asl joystickValue
CheckToFirePlayerMissile
   asl joystickValue                ; shift MOVE_DOWN to carry
   ldy #<INPT5 - INPT4              ; assume player 2 is active
   bit gameState                    ; check current game state
   bmi .checkForFireButtonPressed   ; branch if player 2 is active
   ldy #<INPT4 - INPT4
.checkForFireButtonPressed
   lda INPT4,y                      ; read player's fire button state
   bmi .clearFireButtonDebounceFlag ; branch if fire button not pressed
   lda gameState                    ; get current game state
   and #FIRE_FLAG                   ; keep fire button debounce flag
   bne .checkForShipThrust          ; branch if fire button held down
   lda gameState                    ; get current game state
   ora #FIRE_FLAG                   ; set fire button debounce flag
   sta gameState
   ldy #1
   lda playerM2Direction            ; get missile 2 direction value
   beq .checkToPlayPlayerMissileSounds;branch if missile 2 not active
   dey
   lda playerM1Direction            ; get missile 1 direction value
   bne .checkForShipThrust          ; branch if missile 1 active
.checkToPlayPlayerMissileSounds
   lda playerVertPos                ; get the player's vertical position
   clc
   adc #3
   sta playerMissilesVertPos,y      ; set missile vertical position
   lda playerHorizPos               ; get player ship horizontal position
   sta playerMissilesHorizPos,y
   lda soundEngineValues            ; get sound engine values
   and #SOUND_BITS_BONUS_SHIP
   bne .setPlayerMissileDiectionValues;branch if playing BONUS_SHIP sound
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_PLAYER_SHOT
   sta soundEngineValues
   lda #15
   sta playerShotSoundTimer
.setPlayerMissileDiectionValues
   lda activePlayerAttributes       ; get current player attributes
   and #DIRECTION_MASK              ; keep player direction values
   tax
   lda activePlayerAttributes       ; get current player attributes
   and #REFLECT_MASK | DIRECTION_MASK;keep REFLECT and DIRECTION values
   ora MissileRangeTable,x
   sta missileDirections,y          ; set missile direction value
   jmp .checkForShipThrust

.clearFireButtonDebounceFlag
   lda gameState                    ; get current game state
   and #<~FIRE_FLAG                 ; clear fire button debounce flag
   sta gameState
.checkForShipThrust
   asl joystickValue                ; shift MOVE_UP to carry
   bcs PlayerShipThrustDamping      ; branch if not moving joystick up
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_THRUST
   sta soundEngineValues
   lda activePlayerAttributes       ; get current player attributes
   and #REFLECT_MASK | DIRECTION_MASK;keep current player direction
   tay                              ; move DIRECTION and REFLECT to y register
   lda PlayerThrustValueTable,y
   bpl .adjustPlayerShipVerticalVelocity;branch if not traveling NORTH
   dec playerShipVertVelocityFraction
.adjustPlayerShipVerticalVelocity
   clc
   adc playerShipVertVelocityValue
   sta playerShipVertVelocityValue
   bcc .checkToAdjustPlayerShipHorizontalVelocity
   inc playerShipVertVelocityFraction
.checkToAdjustPlayerShipHorizontalVelocity
   tya                              ; move DIRECTION and REFLECT to accumulator
   clc
   adc #4
   and #REFLECT_MASK | DIRECTION_MASK;keep current player direction
   tay                              ; move DIRECTION and REFLECT to y register
   lda PlayerThrustValueTable,y
   bpl .adjustPlayerShipHorizontalVelocity;branch if not traveling WEST
   dec playerShipHorizVelocityFraction
.adjustPlayerShipHorizontalVelocity
   clc
   adc playerShipHorizVelocityValue
   sta playerShipHorizVelocityValue
   bcc .doneAdjustPlayerShipVelocity
   inc playerShipHorizVelocityFraction
.doneAdjustPlayerShipVelocity
   jmp AdjustPlayerShipPositions
   
PlayerShipThrustDamping
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_THRUST         ; remove SOUND_BITS_THRUST
   sta soundEngineValues
   ldx #1
.playerShipThrustDamping
   lda playerShipVelocityFraction,x ; get player ship velocity fraction value
   ora playerShipVelocityValues,x   ; combine with velocity for magnitude
   beq .adjustNextVelocityValue     ; branch if damping not needed
   lda playerShipVelocityFraction,x ; get player ship velocity fraction value
   asl                              ; multiply by 2 (i.e. a / 128)
   ldy #<-1
   clc
   eor #$FF                         ; get 1's complement (D0 always 1)
   bmi .adjustPlayerShipVelocityForThrustDamping
   iny                              ; y = 0
   sec                              ; set carry for 2's complement adjustment
.adjustPlayerShipVelocityForThrustDamping
   adc playerShipVelocityValues,x
   sta playerShipVelocityValues,x
   tya
   adc playerShipVelocityFraction,x ; adjust ship velocity fraction value
   sta playerShipVelocityFraction,x
.adjustNextVelocityValue
   dex
   bpl .playerShipThrustDamping
AdjustPlayerShipPositions
   ldx #1
.adjustPlayerShipPosition
   lda playerShipVelocityFraction,x ; get player ship velocity fraction value
   tay                              ; move velocity fraction value to y register
   rol
   eor playerShipVelocityFraction,x
   rol
   tya                              ; move velocity fraction to accumulator
   bcc .determinePlayerShipVelocity
   eor #$7F
   sta playerShipVelocityFraction,x
.determinePlayerShipVelocity
   ror                              ; shift upper nybbles to lower nybbles
   ror
   ror
   ror
   and #$0F                         ; mask off carry bits
   cpy #0
   bpl .setPlayerShipVelocityValue  ; branch if velocity in positive direction
   ora #$F0                         ; negate value
.setPlayerShipVelocityValue
   sta tmpPlayerShipVelocity
   tya                              ; move velocity fraction to accumulator
   rol                              ; shift fractional value to upper nybbles
   rol
   rol
   rol
   and #$F0                         ; keep fractional value
   sta tmpPlayerShipVelocityFractionValue
   lda playerShipVelocityValues,x   ; get player ship velocity values
   ror                              ; shift upper nybbles to lower nybbles
   ror
   ror
   ror
   and #$0F                         ; mask off carry bits
   ora tmpPlayerShipVelocityFractionValue
   clc
   adc playerShipFractionalPositionValues,x;adjust player ship fractional postion
   sta playerShipFractionalPositionValues,x
   lda tmpPlayerShipVelocity
   php                              ; push status (i.e. carry bit) to stack
   cpx #0
   beq .adjustPlayerHorizontalPosition
   plp                              ; pull status (i.e. carry bit) from stack
   adc playerVertPos
   sta playerVertPos
   dex
   bpl .adjustPlayerShipPosition    ; unconditional branch
   
.adjustPlayerHorizontalPosition
   plp                              ; pull status (i.e. carry bit) from stack
   bmi .adjustPlayerPositionLeft    ; branch on a negative adjustment value
   adc #1 - 1
   bpl .determinePlayerShipHorizPosition;unconditional branch

.adjustPlayerPositionLeft
   sbc #1 - 1
.determinePlayerShipHorizPosition
   sec
   cmp #0
   bpl .setPlayerShipHorizPosition
   eor #$FF                         ; get 1's complement
   clc
.setPlayerShipHorizPosition
   beq .doneAdjustPlayerShipPositions
   ldx #<[playerHorizPos - asteroidHorizPos]
   jsr DetermineObjectHorizValue
.doneAdjustPlayerShipPositions
   lda #>PlayerShipSprites
   sta playerShipGraphicsPtr + 1
   sta ufoGraphicsPtr + 1
   lda gameState                    ; get current game state
   and #UFO_COLLISION_FLAG          ; keep UFO_COLLISION_FLAG value
   beq DetermineUFOSpriteLSBValue   ; branch if no UFO collision
   lda #<PlayerExplosion_00
   clc
   adc explosionOffset
   sta tmpUFOGraphicLSB             ; set graphic LSB for UFO collision
   lda explosionOffset
   clc
   adc #H_SHIP_EXPLOSION
   sta explosionOffset
   cmp #<[H_SHIP_EXPLOSION * 3]
   bne .checkToReduceNumberOfLives  ; branch if not end of explosion animation
   lda gameState                    ; get current game state
   and #<~UFO_COLLISION_FLAG        ; clear UFO collision value
   sta gameState
   lda soundEngineValues            ; get sound engine values
   and #<~[SOUND_BITS_PLAYER_SHOT | SOUND_BITS_UFO]
   sta soundEngineValues            ; clear PLAYER_SHOT and UFO sound bits
   lda #0
   sta explosionOffset
   lda #VERT_OUT_OF_RANGE
   sta ufoVertPos                   ; place UFO out of range
DetermineUFOSpriteLSBValue
   ldx #<UFOSprite
   lda gameState                    ; get current game state
   and #UFO_FLAG
   bne .setUFOGraphicLSBValue
   ldx #<SatelliteSprite
.setUFOGraphicLSBValue
   stx tmpUFOGraphicLSB
.checkToReduceNumberOfLives
   lda #<[PlayerRotation_00 + H_PLAYER_SHIP]
   sta ufoGraphicsPtr
   ldx #NO_REFLECT
   lda playerFeatureTimer
   bpl .checkToShowShieldSprite
   inc playerFeatureTimer
   lda playerFeatureTimer
   ror                              ; divide value by 2
   and #7                           ; 0 <= a <= 7
   clc
   adc #9                           ; 9 <= a <= 16
   cmp #12
   bne .determinePlayerShipGraphicLSBValue
   lda #VERT_OUT_OF_RANGE
   sta playerVertPos
   lda #63
   sta playerFeatureTimer
   lda #INIT_PLAYER_X
   sta playerHorizPos
   lda #INIT_PLAYER_Y
   sta newPlayerVertPos
   lda activePlayerAttributes       ; get current player attributes
   and #LIVES_MASK                  ; keep number of lives
   sec
   sbc #1 << 4                      ; reduce number of lives
   tay                              ; move number of lives to y
   and #LIVES_MASK
   bne .setNumberOfRemainingLives
   tay                              ; y = 0
.setNumberOfRemainingLives
   sty activePlayerAttributes
   lda #<(PlayerShieldSprite - PlayerShipSprites) / (H_PLAYER_SHIP + 1)
   bpl .determinePlayerShipGraphicLSBValue;unconditional branch
   
.checkToShowShieldSprite
   bit playerState                  ; check current player state
   bvc .determineShipRotationSprite ; branch if not using shields
   lda #NO_REFLECT
   sta tmpPlayerShipReflectValue
   lda #<PlayerShieldSprite
   bne .setPlayerGraphicsLSBValue   ; unconditional branch
   
.determineShipRotationSprite
   lda activePlayerAttributes       ; get current player attributes
   and #REFLECT_MASK | DIRECTION_MASK;keep REFLECT and DIRECTION values
   cmp #REFLECT
   bcc .determinePlayerShipGraphicLSBValue;branch if on left rotation
   ldx #REFLECT
   and #DIRECTION_MASK              ; keep ship DIRECTION values
   eor #$FF                         ; get 1's complement
   adc #9 - 1                       ; increment by number of rotation sprites
.determinePlayerShipGraphicLSBValue
   stx tmpPlayerShipReflectValue
   sta tmpShipRotationIndex
   asl                              ; multiply value by 2
   adc tmpShipRotationIndex         ; add in original so it's multiplied by 3
   asl                              ; multiply value by 6 (i.e. H_PLAYER_SHIP)
   adc #<PlayerShipSprites
.setPlayerGraphicsLSBValue
   sta tmpPlayerGraphicLSB
.determinePlayerShipOffsetValue
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   bne .checkToWrapPlayerShipVertically;branch if player ship visable
   sta playerShipOffset
   lda #<[PlayerRotation_00 + H_PLAYER_SHIP]
   sta playerShipGraphicsPtr
   bne MoveMissiles                 ; unconditional branch
   
.checkToWrapPlayerShipVertically
   lda playerVertPos                ; get the player's vertical position
   bmi .wrapPlayerShipVertically    ; branch if wrapping vertically
.setPlayerShipOffsetValue
   sta playerShipOffset
   sec
   sbc #H_KERNEL - H_PLAYER_SHIP
   bcc .setVisiblePlayerGraphicsLSBValue
   clc
   adc #<-H_PLAYER_SHIP
   sta playerVertPos
   jmp .determinePlayerShipOffsetValue
   
.setVisiblePlayerGraphicsLSBValue
   lda #<[PlayerRotation_00 + H_PLAYER_SHIP]
   sta playerShipGraphicsPtr
   bne .setPlayerShipVDELValue      ; unconditional branch
   
.wrapPlayerShipVertically
   cmp #<-H_PLAYER_SHIP
   bcs .setPlayerShipGraphicsLSBValue
   lda #H_KERNEL
   clc
   adc playerVertPos
   sta playerVertPos
   bne .setPlayerShipOffsetValue    ; unconditional branch

.setPlayerShipGraphicsLSBValue
   eor #$FF                         ; get 1's complement
   sec
   adc tmpPlayerGraphicLSB
   sta playerShipGraphicsPtr
   lda #H_KERNEL
   clc
   adc playerVertPos
   sta playerShipOffset
.setPlayerShipVDELValue
   lda playerShipVertFractionalPositionValue
   rol
   rol
   and #1
   ora tmpPlayerShipReflectValue
   sta playerShipAttributes         ; set VDEL value for player ship
MoveMissiles
   ldx #<[ufoMissileHorizPos - asteroidHorizPos]
   stx tmpMissileIndex
   ldx #<[ufoMissileDirection - missileDirections]
.moveMissiles
   lda missileDirections,x          ; get missile direction value
   bne .moveActiveMissile
.inactivateMissile
   ldy #VERT_OUT_OF_RANGE
   lda playerHorizPos               ; get player ship horizontal position
   cpx #<[ufoMissileDirection - missileDirections]
   bne .setMissileOutOfRange
   lda ufoHorizPos                  ; get UFO horizontal position
.setMissileOutOfRange
   sty playerMissilesVertPos,x      ; set player missile vertical position
   sta playerMissilesHorizPos,x     ; set player missile horizontal position
   stx tmpMissileDirIndex
   ldx tmpMissileIndex
   clc                              ; set to move player missile right
   lda #2                           ; move player missile 2 pixels
   jsr DetermineObjectHorizValue
   jmp .setMissileHorizontalPosition
   
.moveActiveMissile
   lda frameCount                   ; get current frame count
   ror                              ; shift D1 to carry
   ror
   bcs DetermineActiveMissilePositions;branch if not time to decrement range
   lda missileDirections,x          ; get missile direction value
   sec
   sbc #1 << 4                      ; reduce missile range value
   sta missileDirections,x
   and #MISSILE_RANGE_MASK          ; keep MISSILE_RANGE value
   bne DetermineActiveMissilePositions;branch if missile still active
   sta missileDirections,x
   beq .inactivateMissile           ; unconditional branch
   
DetermineActiveMissilePositions
   lda missileDirections,x          ; get missile direction value
   and #REFLECT_MASK | DIRECTION_MASK;keep directional value
   tay
   lda playerShipVertVelocityFraction;get ship vertical velocity fraction value
   php                              ; push status flags to stack
   lsr
   lsr
   lsr
   lsr
   plp                              ; pull status flags from stack
   bpl .adjustMissileVerticalPosition;branch if traveling SOUTH
   ora #$F0                         ; negate value
   clc
   adc #1
.adjustMissileVerticalPosition
   clc
   adc MissileVerticalOffsetTable,y ; adjust by direction vertical offset value
   clc
   adc playerMissilesVertPos,x      ; adjust missile vertical position
   sta playerMissilesVertPos,x
   bpl .determineActiveMissileVerticalPosition
   clc
   adc #H_KERNEL                    ; wrap missile to bottom
   bpl .setMissileVerticalPosition
.determineActiveMissileVerticalPosition
   sec
   sbc #H_KERNEL
   bcc .determineActiveMissileHorizontalPosition
.setMissileVerticalPosition
   sta playerMissilesVertPos,x
.determineActiveMissileHorizontalPosition
   lda playerShipHorizVelocityFraction
   php                              ; push status flags to stack
   lsr
   lsr
   lsr
   lsr
   plp                              ; pull status flags from stack
   bpl .adjustMissileHorizontalPosition;branch if traveling EAST
   ora #$F0                         ; negate value
   clc
   adc #1
.adjustMissileHorizontalPosition
   stx tmpMissileDirIndex
   ldx tmpMissileIndex
   clc
   adc MissileHorizOffsetTable,y    ; adjust by direction horizontal offset
   sec
   bpl .positionMissileHorizontally
   eor #$FF
   adc #2 - 1                       ; 2's complement plus 1
   clc
.positionMissileHorizontally
   beq .setMissileHorizontalPosition
   jsr DetermineObjectHorizValue
.setMissileHorizontalPosition
   txa
   sec
   sbc #<[playerMissilesHorizPos - asteroidHorizPos]
   tay
   lda asteroidHorizPos,x
   sta WSYNC                        ; wait for next scan line
   sta HMM0,y                       ; set missile fine motion value
   ror                              ; rotate object side to carry
   and #COARSE_VALUE >> 1
   bcs .coarseMoveMissileOnLeft
   ldx #6
.coarseMoveMissileOnRight
   dex
   bne .coarseMoveMissileOnRight
   SLEEP 2
   tax                              ; move missile coarse value to x
.coarseMoveMissile
   dex
   bne .coarseMoveMissile
   stx RESM0,y                      ; set missile coarse horizontal position
   beq .moveNextMissile             ; unconditional branch
   
.coarseMoveMissileOnLeft
   tax                              ; move missile coarse value to x
   bcs .coarseMoveMissile           ; unconditional branch
   
.moveNextMissile
   dec tmpMissileIndex
   dec tmpMissileDirIndex
   ldx tmpMissileDirIndex
   bmi .setupScoreKernel
   jmp .moveMissiles
   
.setupScoreKernel
   jmp BranchToSetupScoreKernel

BANK1_Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set stack to beginning
   inx                              ; x = 0
   txa                              ; a = 0
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   lda #VERT_OUT_OF_RANGE
   sta playerVertPos                ; don't show player ship
   lda #$34
   sta random + 1                   ; seed random number values
   sta random
   lda #SHOW_SELECT_SCREEN
   sta gameState
   lda #GAME_OVER
   sta playerState
   
   IF COPYRIGHT_ROM
   
      lda #<DisplayCopyrightInfo
      sta jumpVector
      lda #>DisplayCopyrightInfo
      sta jumpVector + 1
      jmp SwitchToBank0
      
   ELSE
   
      bne StartGameWithoutCollisionsSet

   ENDIF
   
StartGameWithCollisionsSet
   lda #UFO_COLLISION_FLAG
   sta gameState
StartGameWithoutCollisionsSet
   sta bonusShipSoundTimer
   lda #>HorizMoveSizeTable + 32
   sta upAsteroidSizePtr + 1
   sta downAsteroidSizePtr + 1
   lda #>(AsteroidSprites) + 32
   sta upAsteroidGraphicsPtr + 1
   sta downAsteroidGraphicsPtr + 1
   lda #>UpMovingAsteroidKernel + 32
   sta upAsteroidKernelVector + 1
   lda #>DownMovingAsteroidKernel + 32
   sta downAsteroidKernelVector + 1
   jsr InitAsteroidObjects
   lda #SPEED_SLOW | SPEED_MEDIUM
   sta asteroidHorizSpeed
   lda #<DownMovingAsteroidKernel
   sta downAsteroidKernelVector
   lda #VERT_OUT_OF_RANGE
   sta ufoMissileVertPos            ; set UFO missile to out of range
   sta ufoVertPos                   ; set UFO vertical position to out of range
   lda #INIT_PLAYER_X
   sta playerHorizPos
   lda #HMOVE_R4 | 3 << 1 | OBJECT_ON_RIGHT
   sta ufoHorizPos
   sta asteroidCollisionState       ; set to show asteroid collided (i.e. non-zero)
   jmp VerticalSync
   
MoveAsteroidHorizontally
   lda asteroidAttributes,x         ; get attribute value for asteroid
   lsr                              ; shift ASTEROID_TYPE to lower nybbles
   lsr
   lsr
   lsr
   sta tmpAsteroidAttribute
   lda gameSelection                ; get current game selection
   bmi .childGameAsteroidMovementDelay;branch if a CHILD_GAME
   and #ASTEROID_SPEED_MASK         ; keep ASTEROID_SPEED value
   bne .fastMovingAsteroids         ; branch if ASTEROID_SPEED_FAST
   lda tmpAsteroidAttribute         ; get asteroid type
   and #ASTEROID_TYPE_MASK >> 4     ; remove ASTEROID_SPEED value
   bpl .determineToMoveAsteroidHorizontally;unconditional branch
   
.fastMovingAsteroids
   lda tmpAsteroidAttribute         ; get asteroid type
.determineToMoveAsteroidHorizontally
   tay                              ; move asteroid type to y register
   lda AsteroidHorizDelayValues,y   ; get horizontal delay values for asteroid
   beq MoveObjectHorizontally       ; branch if asteroid should move now
.horizontallyDelayAsteroidMovement
   bit asteroidHorizDelayBits
   bne MoveObjectHorizontally
   rts

.childGameAsteroidMovementDelay
   lda #ASTEROID_HORIZ_DELAY_SLOW
   bne .horizontallyDelayAsteroidMovement;unconditional branch
   
MoveObjectHorizontally
   bcs .objectTravelingWest
   lda #<-16
   adc asteroidHorizPos,x           ; decrement object fine motion
   cmp #HMOVE_R7 | 1 << 1 | OBJECT_ON_LEFT
   bne .determineEastTravelingObjectPosition;branch if not color clock 79
   lda #HMOVE_L6 | 2 << 1 | OBJECT_ON_LEFT;set object to color clock 81
   bne .setObjectHorizontalPosition ; unconditional branch

.determineEastTravelingObjectPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; a == 2 || 4 <= a <= 11 || a == 13
   tay
   lda EastTravelingObjectHorizAdjustment - 2,y
   bne .setObjectHorizontalPosition ; unconditional branch
   
.objectTravelingWest
   lda #16 - 1                      ; carry bit set
   adc asteroidHorizPos,x           ; increment object fine motion
   cmp #HMOVE_L4 | 1 << 1 | OBJECT_ON_RIGHT
   bne .determineWestTravelingObjectPosition
   lda #HMOVE_R8 | 6 << 1 | OBJECT_ON_LEFT;set object to color clock 155
   bne .setObjectHorizontalPosition ; unconditional branch
   
.determineWestTravelingObjectPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; 3 <= a <= 11 || a == 13
   tay
   lda WestTravelingObjectHorizAdjustment - 3,y
.setObjectHorizontalPosition
   sta asteroidHorizPos,x
   rts

NewPseudoRandomHorizPosition
   lda random + 1
   and #7                           ; 0 <= a <= 7
   tay
   lda random + 1
   and #$F0                         ; keep upper nybbles for fine motion values
   cmp #HMOVE_L7
   bcc .setRandomHorizCoarseAndSideValues
   cmp #HMOVE_R8
   bcs .setRandomHorizCoarseAndSideValues
   lda #HMOVE_R8
.setRandomHorizCoarseAndSideValues
   ora PseudoRandomHorizPositionCoarseValues,y
   cmp #HMOVE_L4 | 1 << 1 | OBJECT_ON_RIGHT
   bne .doneNewPseudoRandomHorizPosition;branch if not color clock 155
   cmp #HMOVE_L5 | 1 << 1 | OBJECT_ON_RIGHT
   bne .doneNewPseudoRandomHorizPosition;branch if not color clock 154
   cmp #HMOVE_L6 | 1 << 1 | OBJECT_ON_RIGHT
   bne .doneNewPseudoRandomHorizPosition;branch if not color clock 153
   lda #HMOVE_R8 | 6 << 1 | OBJECT_ON_LEFT;set to color clock 155
.doneNewPseudoRandomHorizPosition
   rts

DetermineObjectHorizValue
   ldy #>SetObjectHorizValue
   sty jumpVector + 1
   ldy #<SetObjectHorizValue
   sty jumpVector
   jmp SwitchToBank0
   
DoneDetermineObjectHorizValue
   rts

SwitchToOtherPlayer
   ldx #2
.switchPlayersLoop
   ldy activePlayerVariables,x
   lda reservedPlayerVariables,x
   sty reservedPlayerVariables,x
   sta activePlayerVariables,x
   dex
   bpl .switchPlayersLoop
   lda gameState                    ; get current game state
   eor #ACTIVE_PLAYER_FLAG          ; flip active player flag
   sta gameState
   rts

NextRandom
   lda random                       ; get random low
   asl                              ; shift D7 to carry
   eor random                       ; flip the bits
   asl                              ; shift twice to move D6 to carry
   asl
   rol random + 1                   ; rotate random high so carry is in D0
   rol random                       ; rotate D7 of random high to D0 of random low
   lda random + 1                   ; get random high
   rts

CheckAsteroidCollisions
   stx tmpCollisionIdObjA           ; save object id
   clc
   adc #17                          ; increment object vertical position
   sta tmpRectTopObjA
   clc
   adc ObjectRectangleHeightValues,x;increment by bounding box height
   sta tmpRectBottomObjA
   tya                              ; move object's horiz position to accumulator
   jsr ConvertHorizPosToPixelValue  ; convert horizontal position to pixel value
   sta tmpRectLeftObjA              ; save object pixel value
   ldx #START_UP_MOVING_ASTEROID_IDX
.checkUpAsteroidCollision
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #VERT_OUT_OF_RANGE           ; see if asteroid is active
   beq CheckDownAsteroidCollisions  ; branch if asteroid not active
   tay                              ; move asteroid vertical position to y
   clc
   adc #17                          ; increment asteroid vertical position
   bmi .checkUpAsteroidPreviouslyHit
   cmp tmpRectBottomObjA
   bcs .nextUpMovingAsteroid
   adc #15
   cmp tmpRectTopObjA
   bcc .nextUpMovingAsteroid
.checkUpAsteroidPreviouslyHit
   lda asteroidAttributes,x         ; get attribute value for asteroid
   rol                              ; shift ASTEROID_HIT to carry
   rol
   bcs .nextUpMovingAsteroid        ; branch if asteroid hit
   rol
   rol
   rol
   and #ASTEROID_TYPE_MASK >> 4     ; keep ASTEROID_TYPE
   sta tmpAsteroidType
   tya                              ; move asteroid vertical position to accumulator
   clc
   adc #3
   ldy asteroidHorizPos,x           ; get asteroid horizontal position
   stx tmpAsteroidCollisionIdx
   ldx tmpAsteroidType
   jsr CheckObjectCollisions
   bcs .markUpMovingAsteroidCollided
   ldx tmpAsteroidCollisionIdx
.nextUpMovingAsteroid
   inx
   bne .checkUpAsteroidCollision    ; unconditional branch
   
.markUpMovingAsteroidCollided
   lda upMovingAsteroidVertPos
   bpl .doneCheckUpAsteroidCollision
   ldx upMovingAsteroidLinkListEndIndex;get up moving asteroid index
   lda asteroidAttributes           ; get attribute value for asteroid
   ora asteroidAttributes,x
   and #ASTEROID_HIT
   beq .doneCheckUpAsteroidCollision
   lda asteroidAttributes           ; get attribute value for asteroid
   ora #ASTEROID_HIT | 4
   sta asteroidAttributes           ; set asteroid as HIT
   sta asteroidAttributes,x
.doneCheckUpAsteroidCollision
   rts

CheckDownAsteroidCollisions
   ldx #START_DOWN_MOVING_ASTEROID_IDX
.checkDownAsteroidCollision
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #VERT_OUT_OF_RANGE           ; check to see if asteroid is active
   beq .markDownMovingAsteroidCollided;branch if asteroid not active
   tay                              ; move asteroid vertical position to y
   clc
   adc #17                          ; increment asteroid vertical position
   bmi .checkDownAsteroidPreviouslyHit
   cmp tmpRectBottomObjA
   bcs .nextDownMovingAsteroid
   adc #15
   cmp tmpRectTopObjA
   bcc .nextDownMovingAsteroid
.checkDownAsteroidPreviouslyHit
   lda asteroidAttributes,x         ; get attribute value for asteroid
   rol                              ; shift ASTEROID_HIT to carry
   rol
   bcs .nextDownMovingAsteroid      ; branch if ASTEROID_HIT
   rol
   rol
   rol
   and #ASTEROID_TYPE_MASK >> 4     ; keep ASTEROID_TYPE
   sta tmpAsteroidType
   tya                              ; move asteroid vertical position
   clc
   adc #3                           ; increment asteroid vertical position value
   ldy asteroidHorizPos,x           ; get asteroid horizontal position
   stx tmpAsteroidCollisionIdx
   ldx tmpAsteroidType              ; get asteroid type
   jsr CheckObjectCollisions
   bcs .markDownMovingAsteroidCollided;branch if asteroid collided
   ldx tmpAsteroidCollisionIdx      ; restore asteroid index value
.nextDownMovingAsteroid
   inx
   bne .checkDownAsteroidCollision  ; unconditional branch
   
.markDownMovingAsteroidCollided
   ldy #START_DOWN_MOVING_ASTEROID_IDX
   lda asteroidVertPos,y            ; get down asteroid vertical position
   bpl .doneCheckDownAsteroidCollision
   ldx downMovingAsteroidLinkListEndIndex
   lda asteroidAttributes,x         ; get attribute value for asteroid
   ora asteroidAttributes,y
   and #ASTEROID_HIT
   beq .doneCheckDownAsteroidCollision
   lda asteroidAttributes,y         ; get attribute value for asteroid
   ora #ASTEROID_HIT | 4
   sta asteroidAttributes,x
   sta asteroidAttributes,y
.doneCheckDownAsteroidCollision
   rts

CheckObjectCollisions SUBROUTINE
   stx tmpCollisionIdObjB           ; save object id
   sty tmpCollisionHorizPosObjB     ; save object horizontal position
   clc
   adc #17                          ; increment vertical position
   sta tmpRectTopObjB
   cmp tmpRectTopObjA
   bcc .objectBAboveObjectA
   lda tmpRectTopObjA               ; get object A top rectangle value
   ldx tmpCollisionIdObjA
   adc ObjectRectangleHeightValues,x; increment by bounding box height
   sec
   sbc tmpRectTopObjB               ; subtract object B top rectangle value
   bcs .checkObjectHorizCollision   
.doneCheckObjectCollisions
   rts

.objectBAboveObjectA
   clc
   adc ObjectRectangleHeightValues,x; increment to get bounding box bottom
   sec
   sbc tmpRectTopObjA               ; subtract by object A top rectangle value
   bcc .doneCheckObjectCollisions   ; branch if not colliding vertically
.checkObjectHorizCollision
   lda tmpCollisionHorizPosObjB     ; get object's horizontal position
   jsr ConvertHorizPosToPixelValue  ; convert horizontal position to pixel value
   sta tmpRectLeftObjB              ; save actual pixel value
   ldx tmpCollisionIdObjB           ; get object B id
   cmp tmpRectLeftObjA
   bcc .objectBLeftOfObjectA
   lda tmpRectLeftObjA              ; get object A left rectangle value
   ldx tmpCollisionIdObjA
   adc ObjectBoundingBoxWidthValues,x;increment by bounding box width
   sec
   sbc tmpRectLeftObjB              ; subtract object B left rectangle value
   bcs .continueObjectCollisions
   rts

.objectBLeftOfObjectA
   clc
   adc ObjectBoundingBoxWidthValues,x;increment object B left rectangle value
   sec
   sbc tmpRectLeftObjA
   bcc .doneCheckObjectCollisions
.continueObjectCollisions
   ldx tmpCollisionIdObjA
   cpx #ID_SHOT_UFO + 1
   bne .checkObjectCollisionWithUFO ; unconditional branch
   jmp .doneObjectAsteroidCollisions
   
.checkObjectCollisionWithUFO
   cpx #ID_UFO
   beq .objectCollidedWithUFO
   cpx #ID_SATELLITE
   beq .objectCollidedWithUFO
   ldy tmpCollisionIdObjB
   cpy #ID_UFO
   beq .objectCollidedWithUFO
   cpy #ID_SATELLITE
   bne .checkPlayerShipToUFOCollisions
.objectCollidedWithUFO
   lda gameState                    ; get current game state
   and #UFO_COLLISION_FLAG          ; keep UFO_COLLISION_FLAG value
   beq .setUFOCollision             ; branch if no UFO collision
.doneCheckObjectUFOCollision
   rts

.setUFOCollision
   lda gameState                    ; get current game state
   ora #UFO_COLLISION_FLAG
   sta gameState
   lda #0
   sta explosionOffset
.checkPlayerShipToUFOCollisions
   cpx #ID_PLAYER_SHIP
   beq .ufoPlayerShipCollision
   cpx #ID_SHOT_UFO
   bne .setSoundEngineForExplosion
   lda tmpCollisionIdObjB
   cmp #ID_PLAYER_SHIP
   bne .setSoundEngineForExplosion
.ufoPlayerShipCollision
   lda playerFeatureTimer
   bmi .doneCheckObjectUFOCollision ; branch if player respawn pause
   lda playerState                  ; get current player state
   ora #KILL_FLAG
   sta playerState
   lda #128
   sta playerFeatureTimer
.setSoundEngineForExplosion
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_PLAYER_EXPLODE   ; set to play exploding sound
   and #<~SOUND_BITS_THRUST         ; clear THRUST sound bit
   sta soundEngineValues
   lda #EXPLOSION_SOUND_VOLUME
   sta explosionSoundVolume         ; set initial explosion sound volume
   ldy tmpCollisionIdObjB
   cpy #ID_PLAYER_SHIP
   bcs IncrementScore               ; branch if collision not with an asteroid
   ldy tmpAsteroidCollisionIdx
   lda asteroidAttributes,y         ; get attribute value for asteroid
   ora #ASTEROID_HIT | 4
   sta asteroidAttributes,y         ; set to show asteroid hit and hit color
   sta asteroidCollisionState       ; set to show asteroid collided (i.e. non-zero)
IncrementScore
   cpx #<[playerM1Direction - ufoVertPos]
   bpl .inactivateMissile
   ldy tmpCollisionIdObjB
   cpy #ID_SHOT_UFO
   bne .incrementScore
   ldx #<[ufoMissileDirection - ufoVertPos]
.inactivateMissile
   lda #0
   sta ufoVertPos,x
.incrementScore
   cpx #<[ufoMissileDirection - ufoVertPos]
   beq .doneIncrementScore          ; branch if processing UFO missile directions
   cpx #<[playerM2VertPos - ufoVertPos]
   beq .doneIncrementScore          ; branch if processing missile 2
   cpx #<[ufoMissileVertPos - ufoVertPos]
   beq .doneIncrementScore          ; branch if processing UFO missile
   ldy tmpCollisionIdObjB
   clc
   sed
   lda activePlayerScore + 1        ; get score tens value
   adc PointsLowTable,y             ; increment by points tens value
   sta activePlayerScore + 1
   lda PointsHighTable,y            ; get points thousands value
   bcs .incrementThousandsValue
   beq .doneIncrementScore
.incrementThousandsValue
   adc activePlayerScore            ; increment score thousands value
   sta activePlayerScore
   cld
   tay                              ; move score thousands value to y register
   lda gameSelection                ; get current game selection
   and #BONUS_SHIP_MASK             ; keep BONUS_SHIP values
   beq .determine5000PointExtraLife ; branch if bonus ship every 5,000 points
   cmp #BONUS_SHIP_NONE
   beq .doneIncrementScore          ; branch if no bonus rewarded
   ror
   ror                              ; shift BONUS_SHIP_10K to carry
   tya                              ; move score thousands value to accumulator
   and #$1F
   bcc .checkIfReachedExtraLifePoints;branch if bonus ship every 20,000 points
   and #$0F
.checkIfReachedExtraLifePoints
   bne .doneIncrementScore
   beq .incrementNumberOfLives      ; unconditional branch
   
.determine5000PointExtraLife
   tya                              ; move score thousands value to accumulator
   and #$0F
   beq .incrementNumberOfLives      ; branch if reached 5,000 points
   cmp #$05
   bne .doneIncrementScore          ; branch if not reached 5,000 points
.incrementNumberOfLives
   lda activePlayerAttributes       ; get current player attributes
   clc
   adc #1 << 4                      ; increment number of lives
   tay
   and #LIVES_MASK
   cmp #MAX_NUM_LIVES << 4
   beq .doneIncrementScore
   sty activePlayerAttributes
   lda soundEngineValues            ; get sound engine values
   ora #SOUND_BITS_BONUS_SHIP
   sta soundEngineValues
   lda #127
   sta bonusShipSoundTimer
.doneIncrementScore
   cld
   sec
   rts

.doneObjectAsteroidCollisions
   stx asteroidCollisionState
   pla                              ; pull return address off the stack
   pla
   sec                              ; set to mark asteroid collided
   rts

ConvertHorizPosToPixelValue
   tax                              ; move horizontal position value to x
   and #$0F                         ; mask fine motion value
   tay                              ; move coarse value to y
   txa                              ; move horizontal position value to accumulator
   lsr                              ; shift fine motion value to lower nybble
   lsr
   lsr
   lsr
   tax                              ; move fine motion value to x
   lda FineMotionPixelValues,x
   clc
   adc CoarsePixelValues,y
   rts

DetermineActiveUFOId
   ldx #ID_SATELLITE
   lda gameState                    ; get the current game state
   and #UFO_FLAG                    ; keep UFO flag value
   beq .doneDetermineActiveUFOId    ; branch if satellite is shown
   dex                              ; x = ID_UFO
.doneDetermineActiveUFOId
   tya                              ; move UFO vertical position to accumulator
   rts

CheckToSpawnNewAsteroids
   stx tmpStartingAsteroidIdx
.checkToSpawnNewAsteroid
   lda asteroidVertPos,x            ; get asteroid's vertical position
   bpl .checkForAsteroidHit         ; branch if asteroid is on the screen
   cmp #VERT_OUT_OF_RANGE
   bne .checkForAsteroidHit         ; branch if asteroid is on the screen
   ldx tmpNonExistentAsteroidIdx    ; set x to first asteroid index not on screen
   rts

.checkForAsteroidHit
   lda asteroidAttributes,x         ; get asteroid attribute value
   tay                              ; move attribute value to y
   and #ASTEROID_HIT
   bne .spawnNewAsteroid            ; branch if asteroid hit
.nextAsteroid
   inx
   bpl .checkToSpawnNewAsteroid     ; unconditional branch
   
.rotateAsteroidListDown
   stx tmpAsteroidIndex
   jsr BubbleUpAsteroidList
   dec tmpNonExistentAsteroidIdx
   ldx tmpAsteroidIndex
   bpl .checkToSpawnNewAsteroid     ; unconditional branch
   
.spawnNewAsteroid
   lda asteroidVertPos,x            ; get asteroid's vertical position
   bmi .rotateAsteroidListDown      ; branch if asteroid out of display range
   tya                              ; move asteroid attributes to accumulator
   and #ASTEROID_SIZE_MASK          ; keep ASTEROID_SIZE
   beq .spawnFromLargeAsteroid
   cmp #MEDIUM_ASTEROID
   bne .checkToSpawnFromSecondLargeAsteroid;branch if not MEDIUM_ASTEROID
   jmp .spawnFromMediumAsteroidToSmall
   
.checkToSpawnFromSecondLargeAsteroid
   cmp #SMALL_ASTEROID
   beq .rotateAsteroidListDown      ; branch if SMALL_ASTEROID
.spawnFromLargeAsteroid
   jsr NextRandom
   and #ASTEROID_FAST | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   ora #MEDIUM_ASTEROID             ; make asteroid a MEDIUM_ASTEROID
   sta asteroidAttributes,x         ; set new asteroid attribute value
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #H_KERNEL - [H_MEDIUM_ASTEROID - 1]
   bcc .checkToSpawnSecondMediumAsteroid
   jsr InsertNewAsteroidIntoList
   lda asteroidVertPos,y            ; get asteroid vertical position
   sec
   sbc #H_KERNEL
   sta asteroidVertPos,x
   inc tmpStartingIdxForInsertList
.checkToSpawnSecondMediumAsteroid
   bit gameSelection                ; check current game selection
   bmi .nextAsteroid                ; branch if a CHILD_GAME
   jsr CheckForSpaceToSpawnNewAsteroid
   bcs .nextAsteroid                ; do next asteroid if can't spawn
   lda asteroidVertPos,x            ; get asteroid vertical position
   bmi .insertSecondMediumAsteroidToList
   cmp #H_KERNEL - [H_MEDIUM_ASTEROID + 3]
   bcc .insertSecondMediumAsteroidToList
   jsr InsertNewAsteroidIntoList
   lda asteroidAttributes,x         ; get attribute value for asteroid
   and #ASTEROID_DIRECTION          ; keep asteroid direction value
   sta tmpAsteroidDirection
   jsr NextRandom
   and #ASTEROID_FAST | ASTEROID_ID_MASK;keep asteroid speed and id
   ora #MEDIUM_ASTEROID             ; spawn MEDIUM_ASTEROID
   ora tmpAsteroidDirection         ; set asteroid horizontal direction
   eor #ASTEROID_DIRECTION          ; change direction value
   sta asteroidAttributes,x
   lda asteroidHorizPos,y
   sta asteroidHorizPos,x
   lda asteroidVertPos,y            ; get asteroid vertical position
   clc
   adc #H_MEDIUM_ASTEROID + 3
   sec
   sbc #H_KERNEL
   sta asteroidVertPos,x
   inc tmpNonExistentAsteroidIdx
   jmp .nextAsteroid
   
.insertSecondMediumAsteroidToList
   lda tmpStartingAsteroidIdx       ; get starting asteroid index
   sta tmpSavedStartingAsteroidIdx  ; save value for later
   stx tmpAsteroidBubbleUpBoundary
   ldx tmpNonExistentAsteroidIdx
   jsr BubbleDownAsteroidList
   ldx tmpAsteroidBubbleUpBoundary
   inx
   lda tmpSavedStartingAsteroidIdx
   sta tmpStartingAsteroidIdx
   inc tmpNonExistentAsteroidIdx
   lda asteroidAttributes,x         ; get attribute value for asteroid
   and #ASTEROID_DIRECTION          ; keep asteroid direction value
   sta tmpAsteroidDirection
   jsr NextRandom
   and #ASTEROID_FAST | ASTEROID_ID_MASK;keep asteroid speed and id
   ora #MEDIUM_ASTEROID             ; spawn MEDIUM_ASTEROID
   ora tmpAsteroidDirection         ; set asteroid horizontal direction
   eor #ASTEROID_DIRECTION          ; change direction value
   sta asteroidAttributes,x
   lda asteroidHorizPos - 1,x
   sta asteroidHorizPos,x
   lda asteroidVertPos - 1,x
   clc
   adc #H_MEDIUM_ASTEROID + 3
   cmp #H_KERNEL
   sta asteroidVertPos,x
   bcs .wrapAsteroidVertically
   cmp #H_KERNEL - 6
   bcs .wrapAsteroidVertically
   jmp .nextAsteroid
   
.wrapAsteroidVertically
   jsr InsertNewAsteroidIntoList
   lda asteroidVertPos,y
   sec
   sbc #H_KERNEL
   sta asteroidVertPos,x
   inc tmpNonExistentAsteroidIdx
   jmp .nextAsteroid
   
.spawnFromMediumAsteroidToSmall
   jsr NextRandom
   and #ASTEROID_FAST | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   ora #SMALL_ASTEROID              ; set asteroid to be SMALL_ASTEROID
   sta asteroidAttributes,x         ; set new attribute values
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #H_KERNEL - [H_SMALL_ASTEROID - 1]
   bcc .jmpToNextAsteroid
   jsr InsertNewAsteroidIntoList
   lda asteroidVertPos,y
   sec
   sbc #H_KERNEL
   sta asteroidVertPos,x
   inc tmpNonExistentAsteroidIdx
.jmpToNextAsteroid
   jmp .nextAsteroid

BubbleUpAsteroidList
.bubbleUpAsteroidList
   lda asteroidHorizPos + 1,x       ; get asteroid horizontal position
   sta asteroidHorizPos,x           ; move to the position above
   lda asteroidAttributes + 1,x     ; get attribute value for asteroid
   sta asteroidAttributes,x         ; move to the position above
   lda asteroidVertPos + 1,x        ; get asteroid vertical position
   sta asteroidVertPos,x            ; move to the position above
   inx
   cmp #VERT_OUT_OF_RANGE
   bne .bubbleUpAsteroidList
   rts

InitAsteroidObjects
   lda #0
   bit gameSelection                ; check current game selection
   bmi .setInitNumberOfAsteroids    ; branch if CHILD game
   ldx activePlayerScore            ; get score thousands value
   beq .setInitNumberOfAsteroids    ; branch if less than 1,000
   ora #SPAWN_TWO_LARGE_ASTEROIDS
   cpx #$15
   bcc .setInitNumberOfAsteroids    ; branch if score 15,000 > a >= 1,000
   ora #SPAWN_THREE_LARGE_ASTEROIDS
.setInitNumberOfAsteroids
   sta tmpInitNumberOfAsteroids
   ldx #START_UP_MOVING_ASTEROID_IDX
   jsr InitAsteroidAttributesAndPosition
   stx upMovingAsteroidIndex
   ldx #START_DOWN_MOVING_ASTEROID_IDX
   jsr InitAsteroidAttributesAndPosition
   stx downMovingAsteroidIndex
   rts

InitAsteroidAttributesAndPosition SUBROUTINE
   lda #1
   sta asteroidVertPos,x            ; set asteroid vertical position to 1
   jsr NewPseudoRandomHorizPosition
   sta asteroidHorizPos,x           ; set asteroid horizontal position value
   jsr NextRandom                   ; get a new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   sta asteroidAttributes,x         ; set asteroid new attributes
   inx
   bit tmpInitNumberOfAsteroids
   bvc .setLastAsteroidInitValues
   bmi .spawnThreeInitAsteroids
   lda #[H_LARGE_ASTEROID + 6] * 1
   cpx #START_DOWN_MOVING_ASTEROID_IDX
   bcs .setAsteroidVerticalPosition ; branch if doing down moving asteroids
   bcc .setUpAsteroidInitVertPosition;unconditional branch
   
.spawnThreeInitAsteroids
   lda #[H_LARGE_ASTEROID + 6] * 1
   sta asteroidVertPos,x            ; set asteroid initial vertical position
   jsr NextRandom                   ; get new random number
   and #HMOVE_R2
   ora #HMOVE_0  | 5 << 1 | OBJECT_ON_RIGHT
   sta asteroidHorizPos,x           ; set asteroid initial horizontal value
   jsr NextRandom                   ; get new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   sta asteroidAttributes,x         ; set asteroid initial attributes
   inx                              ; set next asteroid in list
.setUpAsteroidInitVertPosition
   lda #[H_LARGE_ASTEROID + 6] * 2
.setAsteroidVerticalPosition
   sta asteroidVertPos,x            ; set asteroid initial vertical position
   jsr NextRandom                   ; get new random number
   and #HMOVE_R2
   ora #HMOVE_0  | 5 << 1 | OBJECT_ON_RIGHT
   sta asteroidHorizPos,x           ; set asteroid initial horizontal value
   jsr NextRandom                   ; get new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   sta asteroidAttributes,x         ; set asteroid initial attributes
   inx                              ; set next asteroid in list
.setLastAsteroidInitValues
   lda #[H_LARGE_ASTEROID + 6] * 3
   sta asteroidVertPos,x            ; set asteroid initial vertical position
   jsr NewPseudoRandomHorizPosition
   sta asteroidHorizPos,x           ; set asteroid initial horizontal value
   jsr NextRandom                   ; get new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   sta asteroidAttributes,x         ; set asteroid initial attributes
   lda #VERT_OUT_OF_RANGE
   sta asteroidVertPos + 1,x        ; set end of asteroid array
   rts

InsertNewAsteroidIntoList
   stx insertListIdxToMove          ; set the index that will be moved
   ldx tmpStartingIdxForInsertList  ; get the starting index for the list
   jsr BubbleDownAsteroidList
   ldy insertListIdxToMove          ; get the index that will be moved
   iny
   lda asteroidHorizPos,y
   sta asteroidHorizPos,x
   lda asteroidAttributes,y         ; get attribute value for asteroid
   sta asteroidAttributes,x
   rts

BubbleDownAsteroidList
   inx
.bubbleDownAsteroidList
   lda asteroidVertPos,x            ; get asteroid vertical position
   sta asteroidVertPos + 1,x        ; move to the position below
   lda asteroidHorizPos,x           ; get asteroid horizontal position
   sta asteroidHorizPos + 1,x       ; move to the position below
   lda asteroidAttributes,x         ; get attribute value for asteroid
   sta asteroidAttributes + 1,x     ; move to the position below
   dex
   cpx tmpAsteroidBubbleUpBoundary
   bpl .bubbleDownAsteroidList
   inx
   rts

CheckForSpaceToSpawnNewAsteroid
   lda tmpNonExistentAsteroidIdx
   cmp #START_DOWN_MOVING_ASTEROID_IDX
   bcs .checkForSpaceForNewDownAsteroid; branch if a down moving asteroid
   cmp #6
   rts

.checkForSpaceForNewDownAsteroid
   cmp #15
   rts

CheckForFreeCenterSpace SUBROUTINE
.checkForFreeCenterSpace
   lda asteroidVertPos,x            ; get asteroid vertical position
   tay                              ; move vertical position to y register
   cmp #VERT_OUT_OF_RANGE           ; check to see if asteroid is active
   bne .checkIfAsteroidInCenterZone ; branch if asteroid is active
   rts

.checkIfAsteroidInCenterZone
   lda asteroidHorizPos,x           ; get asteroid horizontal position value
   and #COARSE_VALUE | OBJECT_SIDE  ; keep coarse value and side of asteroid
   cmp #6 << 1 | OBJECT_ON_LEFT
   beq .asteroidInCenter
   cmp #5 << 1 | OBJECT_ON_LEFT
   beq .asteroidLeftOfCenter
   cmp #1 << 1 | OBJECT_ON_RIGHT
   beq .asteroidRightOfCenter
.nextAsteroid
   inx
   bpl .checkForFreeCenterSpace     ; unconditional branch
;
; Thomas Jentzsch pointed out in his original pass of reverse engineering this
; ROM that the values below were not adjusted for the PAL50 copyright ROM. This
; caused the safe zone for respawning to be off center in that version.
;
.asteroidInCenter
   tya                              ; move asteroid vertical position to a
   bmi .nextAsteroid                ; branch if asteroid not active
   
   IF [COMPILE_REGION = PAL50 && COPYRIGHT_ROM = TRUE]
   
      cmp #8
   
   ELSE
   
      cmp #INIT_PLAYER_Y - [(H_PLAYER_SHIP * 6) + 3]
   
   ENDIF

   bcc .nextAsteroid
   
   IF [COMPILE_REGION = PAL50 && COPYRIGHT_ROM = TRUE]
   
      cmp #64
   
   ELSE
   
      cmp #INIT_PLAYER_Y + [(H_PLAYER_SHIP * 4) + 3]
   
   ENDIF

   bcs .nextAsteroid
   cmp #0                           ; no safe zone found
   rts

.asteroidLeftOfCenter
.asteroidRightOfCenter
   tya                              ; move vertical position to accumlator
   
   IF [COMPILE_REGION = PAL50 && COPYRIGHT_ROM = TRUE]

      cmp #24
   
   ELSE
   
      cmp #INIT_PLAYER_Y - [(H_PLAYER_SHIP * 3) + 2]
   
   ENDIF

   bcc .nextAsteroid
   
   IF [COMPILE_REGION = PAL50 && COPYRIGHT_ROM = TRUE]
   
      cmp #56
   
   ELSE
   
      cmp #INIT_PLAYER_Y + (H_PLAYER_SHIP * 3)
   
   ENDIF

   bcs .nextAsteroid
   cmp #0                           ; no safe zone found
   rts

MissileRangeTable
   .byte [(10 / 2) + 1] << 4        ; DIR_UP
   .byte [(12 / 2) + 1] << 4        ; DIR_NW_1/8
   .byte [(12 / 2) + 1] << 4        ; DIR_NW_1/4
   .byte [(20 / 2) + 1] << 4        ; DIR_NW_3/8
   .byte [(16 / 2) + 1] << 4        ; DIR_LEFT
   .byte [(20 / 2) + 1] << 4        ; DIR_SW_5/8
   .byte [(12 / 2) + 1] << 4        ; DIR_SW_3/4
   .byte [(12 / 2) + 1] << 4        ; DIR_SW_7/8
;   .byte [(14 / 2) + 1] << 4        ; DIR_DOWN
;   .byte [(14 / 2) + 1] << 4        ; DIR_SE_7/8
;   .byte [(14 / 2) + 1] << 4        ; DIR_SE_3/4
;   .byte [(14 / 2) + 1] << 4        ; DIR_SE_5/8
;   .byte [(14 / 2) + 1] << 4        ; DIR_RIGHT
;   .byte [(14 / 2) + 1] << 4        ; DIR_NE_3/8
;   .byte [(14 / 2) + 1] << 4        ; DIR_NE_1/4
;   .byte [(6 / 2) + 1] << 4         ; DIR_NE_1/8
;
; last 8 bytes shared with table below
;
   
AsteroidHorizDelayValues
;
; slow asteroids
;
   .byte ASTEROID_HORIZ_DELAY_SLOW
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; MEDIUM_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; SMALL_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; MEDIUM_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; SMALL_ASTEROID | ASTEROID_HIT
;
; fast asteroids
;
   .byte ASTEROID_HORIZ_DELAY_SLOW
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; MEDIUM_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_FAST  ; SMALL_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; MEDIUM_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_FAST  ; SMALL_ASTEROID | ASTEROID_HIT
   
EastTravelingObjectHorizAdjustment
   .byte HMOVE_L6 | 2 << 1 | OBJECT_ON_RIGHT
   .byte 0                          ; not used
   .byte HMOVE_L6 | 3 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_L6 | 3 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_L6 | 4 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_L6 | 4 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_L6 | 5 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_L6 | 5 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_L6 | 1 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_L6 | 6 << 1 | OBJECT_ON_LEFT
   .byte 0                          ; not used
   .byte HMOVE_L3 | 1 << 1 | OBJECT_ON_RIGHT

WestTravelingObjectHorizAdjustment
   .byte HMOVE_R8 | 5 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_R8 | 1 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_R6 | 1 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_R8 | 2 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_R8 | 2 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_R8 | 3 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_R8 | 3 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_R8 | 4 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_R8 | 4 << 1 | OBJECT_ON_LEFT
   .byte 0                          ; not used
   .byte HMOVE_R8 | 5 << 1 | OBJECT_ON_LEFT

PseudoRandomHorizPositionCoarseValues
   .byte HMOVE_0  | 3 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_0  | 2 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_0  | 2 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_0  | 3 << 1 | OBJECT_ON_RIGHT
   .byte HMOVE_0  | 3 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_0  | 4 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_0  | 3 << 1 | OBJECT_ON_LEFT
   .byte HMOVE_0  | 2 << 1 | OBJECT_ON_LEFT

FineMotionPixelValues
   .byte 6, 5, 4, 3, 2, 1, 0, 0
   .byte 14, 13, 12, 11, 10, 9, 8, 7
   
CoarsePixelValues
   .byte 0, 0, 85, 0, 100, 13, 115
   .byte 28, 130, 43, 145, 58, 0, 73
   
ObjectRectangleHeightValues
   .byte H_LARGE_ASTEROID - 1
   .byte H_LARGE_ASTEROID - 1
   .byte H_MEDIUM_ASTEROID - 1
   .byte H_SMALL_ASTEROID - 1
   .byte H_PLAYER_SHIP - 1
   .byte H_UFO + 1
   .byte H_SATELLITE + 1
   .byte H_MISSILE - 1
   .byte H_MISSILE - 1
   .byte H_MISSILE - 1
   .byte 36                         ; not used
   
ObjectBoundingBoxWidthValues
   .byte W_LARGE_ASTEROID_RECT
   .byte W_LARGE_ASTEROID_RECT
   .byte W_MEDIUM_ASTEROID_RECT
   .byte W_SMALL_ASTEROID_RECT
   .byte W_PLAYER_SHIP_RECT
   .byte W_UFO_RECT
   .byte W_SATELLITE_RECT
   .byte W_MISSILE_RECT
   .byte W_MISSILE_RECT
   .byte W_MISSILE_RECT
   .byte 36                         ; not used

PointsLowTable
   .byte <[POINTS_LARGE_ASTEROIDS >> 4]
   .byte <[POINTS_LARGE_ASTEROIDS >> 4]
   .byte <[POINTS_MEDIUM_ASTEROIDS >> 4]
   .byte <[POINTS_SMALL_ASTEROIDS >> 4]
   .byte <[POINTS_PLAYER_SHIP >> 4]
   .byte <[POINTS_UFO >> 4]
   .byte <[POINTS_SATELLITES >> 4]
PointsHighTable
   .byte <[POINTS_LARGE_ASTEROIDS >> 12]
   .byte <[POINTS_LARGE_ASTEROIDS >> 12]
   .byte <[POINTS_MEDIUM_ASTEROIDS >> 12]
   .byte <[POINTS_SMALL_ASTEROIDS >> 12]
   .byte <[POINTS_PLAYER_SHIP >> 12]
   .byte <[POINTS_UFO >> 12]
   .byte <[POINTS_SATELLITES >> 12]
   
AsteroidUpperBound
   .byte -H_LARGE_ASTEROID, -H_LARGE_ASTEROID
   .byte -H_MEDIUM_ASTEROID, -H_SMALL_ASTEROID
   
AsteroidLowerBound
   .byte (H_KERNEL + 1) - H_LARGE_ASTEROID
   .byte (H_KERNEL + 1) - H_LARGE_ASTEROID
   .byte (H_KERNEL + 1) - H_MEDIUM_ASTEROID
   .byte (H_KERNEL + 1) - H_SMALL_ASTEROID
   
GameSelectionValues
   .byte SELECT_HELD | TWO_PLAYER_GAME
   .byte CHILD_GAME | SELECT_HELD | ASTEROID_SPEED_FAST
   .byte CHILD_GAME
   .byte CHILD_GAME | SELECT_HELD | TWO_PLAYER_GAME | ASTEROID_SPEED_FAST

WrapAroundGameSelectionValues
   .byte CHILD_GAME | SELECT_HELD
   .byte SELECT_HELD | TWO_PLAYER_GAME
   .byte CHILD_GAME | SELECT_HELD | TWO_PLAYER_GAME
   .byte SELECT_HELD

PlayerThrustValueTable
   .byte -127                       ; DIR_UP
   .byte -117                       ; DIR_NW_1/8
   .byte -90                        ; DIR_NW_1/4
   .byte -49                        ; DIR_NW_3/8
   .byte 0                          ; DIR_LEFT
   .byte 49                         ; DIR_SW_5/8
   .byte 90                         ; DIR_SW_3/4
   .byte 117                        ; DIR_SW_7/8
   .byte 127                        ; DIR_DOWN
   .byte 117                        ; DIR_SE_7/8
   .byte 90                         ; DIR_SE_3/4
   .byte 49                         ; DIR_SE_5/8
   .byte 0                          ; DIR_RIGHT
   .byte -49                        ; DIR_NE_3/8
   .byte -90                        ; DIR_NE_1/4
   .byte -117                       ; DIR_NE_1/8

MissileVerticalOffsetTable
   .byte -4                         ; DIR_UP
   .byte -3                         ; DIR_NW_1/8
   .byte -3                         ; DIR_NW_1/4
   .byte -1                         ; DIR_NW_3/8
   .byte 0                          ; DIR_LEFT
   .byte 1                          ; DIR_SW_5/8
   .byte 3                          ; DIR_SW_3/4
   .byte 3                          ; DIR_SW_7/8
   .byte 4                          ; DIR_DOWN
   .byte 3                          ; DIR_SE_7/8
   .byte 3                          ; DIR_SE_3/4
   .byte 1                          ; DIR_SE_5/8
   .byte 0                          ; DIR_RIGHT
   .byte -1                         ; DIR_NE_3/8
   .byte -3                         ; DIR_NE_1/4
   .byte -3                         ; DIR_NE_1/8
   
MissileHorizOffsetTable
   .byte 0                          ; DIR_UP
   .byte 1                          ; DIR_NW_1/8
   .byte 3                          ; DIR_NW_1/4
   .byte 3                          ; DIR_NW_3/8
   .byte 4                          ; DIR_LEFT
   .byte 3                          ; DIR_SW_5/8
   .byte 3                          ; DIR_SW_3/4
   .byte 1                          ; DIR_SW_7/8
   .byte 0                          ; DIR_DOWN
   .byte -1                         ; DIR_SE_7/8
   .byte -3                         ; DIR_SE_3/4
   .byte -3                         ; DIR_SE_5/8
   .byte -4                         ; DIR_RIGHT
   .byte -3                         ; DIR_NE_3/8
   .byte -3                         ; DIR_NE_1/4
   .byte -1                         ; DIR_NE_1/8

BranchToSetupScoreKernel
   lda #<SetupScoreKernel
   sta jumpVector
   lda #>SetupScoreKernel
   sta jumpVector + 1
   jmp SwitchToBank0

   FILL_BOUNDARY 240, 0
   
SwitchToBank0
   sta BANK0STROBE
   jmp (jumpVector)

   IF COPYRIGHT_ROM
   
      IF COMPILE_REGION = PAL50

         .byte $00,$00,$FF,$00

      ELSE

         .byte $00,$00,$44,$00

      ENDIF

   ELSE   

   FILL_BOUNDARY 248, 0

   .byte 0, 0                       ; hotspot locations not available for data

   ENDIF

   echo "***", (FREE_BYTES)d, "BYTES OF BANK1 FREE"
   
   .word BANK1_Start
   .word BANK1_Start
   .word BANK1_Start