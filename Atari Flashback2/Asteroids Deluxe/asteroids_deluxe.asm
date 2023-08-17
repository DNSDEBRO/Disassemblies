   LIST OFF
; ***  A S T E R O I D S  D E L U X E  ***
; Copyright 2005 Atari
; Designer: Unknown
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: April 19, 2023
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
;
; ROM stats
; -------------------------------------------
; *** 1,390 BYTES OF BANK0 FREE
; ***   281 BYTES OF BANK1 FREE
; *** 3,203 BYTES OF BANK2 FREE
; *** 4,051 BYTES OF BANK3 FREE
; ===========================================
; *** 8,925 TOTAL BYTES FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 2005, ATARI                                        =
; =                                                                            =
; ==============================================================================
;
; Asteroids Deluxe is a hack of Asteroids that was originally done by Brad
; Stewart for the Atari2600. Asteroids Deluxe was written to appear on the
; Atari Flashback2 console.
;
; It seems the original developer of this hack used an Asteroid hack done
; by Thomas Jentzsch as the base for this hack instead of the original
; Asteroids ROM from Atari. To see Thomas' original hacks go to...
; http://www.atariage.com/hack_page.html?SystemID=2600&SoftwareHackID=43
; and
; http://www.atariage.com/hack_page.html?SystemID=2600&SoftwareHackID=160
;
; This game was only done for NTSC so there are no color changes or frame
; changes for PAL.

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

   LIST ON

;===============================================================================
; F R A M E  T I M I N G S
;===============================================================================

VBLANK_TIME             = 45
OVERSCAN_TIME           = 36
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

COLORS_RESERVED_LIVES   = ORANGE_GREEN
COLORS_ASTEROID_00      = GREEN + 6
COLORS_ASTEROID_01      = GREEN + 6
COLORS_ASTEROID_02      = GREEN + 12
COLORS_ASTEROID_03      = GREEN + 12
COLORS_ASTEROID_04      = GREEN + 14
COLORS_ASTEROID_05      = GREEN + 14
COLORS_ASTEROID_06      = GREEN + 14
COLORS_ASTEROID_07      = GREEN + 14
COLORS_UFO              = DK_BLUE + 12
COLORS_SATELLITE        = DK_GREEN + 8
COLORS_PLAYER1_SCORE    = DK_GREEN + 6
COLORS_PLAYER1_SHIP     = DK_GREEN + 14
COLORS_PLAYER2_SCORE    = DK_GREEN + 6
COLORS_PLAYER2_SHIP     = DK_GREEN + 12
COLORS_SELECT_ICON      = GREEN + 14

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

BANK0_BASE              = $1000
BANK1_BASE              = $2000
BANK2_BASE              = $3000
BANK3_BASE              = $4000

BANK0_REORG             = $1000
BANK1_REORG             = $1000
BANK2_REORG             = $1000
BANK3_REORG             = $1000

BANK0STROBE             = $1FF6
BANK1STROBE             = $1FF7
BANK2STROBE             = $1FF8
BANK3STROBE             = $1FF9

SELECT_ICON_XPOS        = 56

H_RESERVED_SHIPS        = 5
H_SELECT_ICON           = 16
H_GAME_SELECTION        = 8
H_KERNEL                = 89
H_DIGITS                = 5
H_LOGO                  = 16
H_COPYRIGHT             = 7
H_LARGE_ASTEROID        = 15
H_MEDIUM_ASTEROID       = 7
H_SMALL_ASTEROID        = 4
H_PLAYER_SHIP           = 5
H_SHIP_EXPLOSION        = 6
H_UFO                   = 3
H_SATELLITE             = 5
H_MISSILE               = 3

W_KILLER_SATELLITES_RECT = 15
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
; asteroid collision constants
;
P1_SHIELD_USAGE_MASK    = %11000000
P2_SHIELD_USAGE_MASK    = %00110000
ASTEROID_COLLISION_MASK = %00000001

MAX_SHIELD_USAGE        = 3

; game selection constants
CHILD_GAME              = %10000000
SELECT_DEBOUNCE         = %01000000
NUM_PLAYERS_BIT         = %00100000
FEATURE_BITS            = %00011000
BONUS_SHIP_BITS         = %00000110
ASTEROID_SPEED_BIT      = %00000001

ASTEROID_SPEED_SLOW     = 0
ASTEROID_SPEED_FAST     = 1

BONUS_SHIP_10K          = 1 << 1
BONUS_SHIP_NONE         = 3 << 1

FEATURE_BITS_NONE       = 3 << 3

ONE_PLAYER_GAME         = 0 << 5 
TWO_PLAYER_GAME         = 1 << 5

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

INIT_HEARTBEAT_TIMER_VALUE = 8
MAX_HEARTBEAT_TIMER_VALUE = 6

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
INIT_PLAYER_Y           = 41

VERT_OUT_OF_RANGE       = 224

SPEED_SLOW              = $70       ; horizontal delay of slow asteroids (1/7)
SPEED_MEDIUM            = $03       ; horizontal delay of medium asteroids (1/3)

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
;horizontal position constants
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

;===============================================================================
; M A C R O S
;===============================================================================

   MAC SLEEP_4
      lda asteroidVertPos,x
   ENDM
   
   MAC SLEEP_6
      SLEEP_4
      SLEEP 2
   ENDM

  MAC FILL_NOP
       REPEAT {1}
         NOP
      REPEND
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
;--------------------------------------
tempCharHolder          = playerShipHorizVelocityFraction
;--------------------------------------
tmpSelectObjectHorizPos = tempCharHolder
playerShipVertVelocityFraction = playerShipHorizVelocityFraction + 1
;--------------------------------------
graphicPointerIndex     = playerShipVertVelocityFraction
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
tmpDiamondOrSharkHorizPos = loopCount
;--------------------------------------
tmpCollisionIdObjB      = tmpDiamondOrSharkHorizPos
tmpNewUFODirectionValue ds 1
;--------------------------------------
tmpAsteroidBubbleUpBoundary = tmpNewUFODirectionValue
;--------------------------------------
tmpPlayerHorizPosValue  = tmpAsteroidBubbleUpBoundary
;--------------------------------------
tmpObjectIndex          = tmpPlayerHorizPosValue
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
tmpAsteroidAttribute    ds 1
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
   
FREE_BYTES SET 0

   FILL_NOP 3
   
JumpToUpAsteroidKernel
   sta WSYNC
;--------------------------------------
JumpIntoUpAsteroidKernel
   sta HMOVE                  ; 3 = @03
   sta GRP1                   ; 3 = @06   draw down moving asteroid
   stx NUSIZ1                 ; 3 = @09   set NUSIZ for down moving asteroid
   jmp (upAsteroidKernelVector);5

UpMovingAsteroidOnRight
   SLEEP 2                    ; 2 = @16
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda upAsteroidFineMotion   ; 3         get up moving asteroid fine motion
   sta HMCLR                  ; 3 = @28   clear all horizontal motion
   sta HMP0                   ; 3 = @31   set up moving asteroid fine motion
   lda #<CheckToDrawUpMovingAsteroid;2
   sta upAsteroidKernelVector ; 3         set up moving asteroid kernel LSB
   ldx upAsteroidCoarseValue  ; 3 = @39   get up moving asteroid coarse value
   beq CoarseMoveExtremeRightUpAsteroid;2³
   cpx #5                     ; 2
   bcc CoarseMoveUpAsteroidOnRight;2³
CoarseMoveExtremeRightUpAsteroid
   ldx #5                     ; 2
   lda #0                     ; 2 = @49
.coarseMoveExtremeRightUpAsteroid
   dex                        ; 2
   bne .coarseMoveExtremeRightUpAsteroid;2³
   sta RESP0                  ; 3 = @76   ** INCONSISTENT ** strobe cycle
;--------------------------------------
   jmp JumpIntoDownAsteroidKernel;3

CoarseMoveUpAsteroidOnRight
   lda #0                     ; 2 = @48
.coarseMoveUpAsteroidOnRight
   dex                        ; 2
   bne .coarseMoveUpAsteroidOnRight;2³
   sta RESP0                  ; 3 = @70
   jmp JumpToDownAsteroidKernel;3

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
   sta RESP0                  ; 3 = @38
.contMoveUpAsteriodOnLeft_03
   SLEEP 2                    ; 2
   beq .jmpToDoneMoveUpAsteroidOnLeft;3   unconditional branch
   
.coarseMoveUpAsteroidCycle44
   dex                        ; 2
   bne .coarseMoveUpAsteroidCycle49;2³
   sta RESP0                  ; 3 = @43
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
   jmp JumpIntoDownAsteroidKernel;3 = @76

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
   bne .setToDrawUpMovingAsteroid;2³      branch if not KILLER_SATELLITE
   lda #>KillerSatelliteSprites;2
   bne .setUpMovingAsteroidGraphicMSB;3   unconditional branch

.setToDrawUpMovingAsteroid
   lda #>AsteroidSprites      ; 2
.setUpMovingAsteroidGraphicMSB
   sta upAsteroidGraphicsPtr + 1;3
   tya                        ; 2         move scan line to accumulator
   cmp asteroidVertPos,x      ; 4         compare with asteroid scan line
   bne .skipUpAsteroidDraw    ; 2³        branch if not time to draw asteroid
   lda upAsteroidFineMotion   ; 3         get asteroid fine motion value
   ror                        ; 2         shift OBJECT_SIDE value to carry
   bcs .upMovingAsteroidOnLeft; 2³        branch if asteroid on the left
   ldx #<UpMovingAsteroidOnRight;2
   stx upAsteroidKernelVector ; 3
   lda #0                     ; 2
   tax                        ; 2
;--------------------------------------
   beq JumpToDownAsteroidKernel;3 + 1     unconditional branch

.upMovingAsteroidOnLeft
   ldx #<UpMovingAsteroidOnLeft;2
   stx.w upAsteroidKernelVector;4
   lda #0                     ; 2
   tax                        ; 2
   beq JumpToDownAsteroidKernel;3 + 1     unconditional branch

.skipUpAsteroidDraw
   lda #0                     ; 2 = @58
   tax                        ; 2
   beq JumpToDownAsteroidKernel;3 + 1     unconditional branch

.endKernel
   jmp EndKernel              ; 3

   FILL_BOUNDARY 256, 0

JumpToDownAsteroidKernel
   sta WSYNC
;--------------------------------------
JumpIntoDownAsteroidKernel
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw up moving asteroid
   stx NUSIZ0                 ; 3 = @09   set NUSIZ for up moving asteroid
   jmp (downAsteroidKernelVector);5

DownMovingAsteroidOnRight
   iny                        ; 2 = @16   increment scan line count
   cpy #H_KERNEL - 3          ; 2
   beq .endKernel             ; 2³ + 1
   lda downAsteroidFineMotion ; 3         get down moving asteroid fine motion
   sta HMCLR                  ; 3 = @26   clear all horizontal motion
   sta HMP1                   ; 3 = @29   set down moving asteroid fine motion
   lda #<CheckToDrawDownMovingAsteroid;2
   sta downAsteroidKernelVector;3         set down moving asteroid kernel LSB
   ldx downAsteroidCoarseValue; 3         get down moving asteroid coarse value
   beq CoarseMoveExtremeRightDownAsteroid;2³
   cpx #5                     ; 2
   bcc CoarseMoveDownAsteroidOnRight;2³
CoarseMoveExtremeRightDownAsteroid
   ldx #5                     ; 2
   lda #0                     ; 2 = @47
.coarseMoveExtremeRightDownAsteroid
   dex                        ; 2
   bne .coarseMoveExtremeRightDownAsteroid;2³
   sta RESP1                  ; 3 = @74   ** INCONSISTENT ** strobe cycle
;--------------------------------------
   jmp JumpIntoUpAsteroidKernel;3 = @01

CoarseMoveDownAsteroidOnRight
   lda #0                     ; 2
.coarseMoveDownAsteroidOnRight
   dex                        ; 2
   bne .coarseMoveDownAsteroidOnRight;2³
   sta RESP1                  ; 3 = @68
   jmp JumpToUpAsteroidKernel ; 3

DownMovingAsteroidOnLeft SUBROUTINE
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
   cpy #H_KERNEL - 3          ; 2
   beq .endKernelDownMovingAsteroidKernel;2³
   lda #<CheckToDrawDownMovingAsteroid;2
   sta downAsteroidKernelVector;3         set down moving asteroid kernel LSB
   lda #0                     ; 2         don't draw down moving asteroid
   SLEEP 2                    ; 2
   jmp JumpIntoUpAsteroidKernel;3 = @76

CheckToDrawDownMovingAsteroid:
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
   cpy #H_KERNEL - 3          ; 2
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
   cpy #H_KERNEL - 3          ; 2
   beq .endKernelDownMovingAsteroidKernel;2³
   ldx downMovingAsteroidSize ; 3
   SLEEP 2                    ; 2
   jmp JumpIntoUpAsteroidKernel;3

.endKernelDownMovingAsteroidKernel
   jmp EndKernel              ; 3

DownMovingAsteroidKernel
   ldx downMovingAsteroidIndex; 3 = @17   get down moving asteroid index
   lda asteroidAttributes,x   ; 4         get attribute value for up moving asteroid
   and #ASTEROID_TYPE_MASK    ; 2         keep asteroid type
   sta downAsteroidGraphicsPtr; 3
   sta downAsteroidSizePtr    ; 3
   sta HMCLR                  ; 3 = @32   clear all horizontal motion
   lda asteroidAttributes,x   ; 4         get attribute value for up moving asteroid
   and #ASTEROID_ID_MASK      ; 2         mask to get asteroid id
   sta downMovingAsteroidId   ; 3
   bne .setForAsteroidMSBGraphicValue;2³  branch if not a Killer Satellite
   lda #>KillerSatelliteSprites;2
   bne .setDownAsteroidMSBGraphicValue;3  unconditional branch

.setForAsteroidMSBGraphicValue
   lda #>AsteroidSprites      ; 2
.setDownAsteroidMSBGraphicValue
   sta downAsteroidGraphicsPtr + 1;3 = @51
   tya                        ; 2         move scan line to accumulator
   cmp asteroidVertPos,x      ; 4         compare with asteroid vertical pos
   bne .skipDownAsteroidDraw  ; 2³        branch if asteroid not on current scan line
   lda downAsteroidFineMotion ; 3         get down asteroid fine motion value
   ror                        ; 2         shift D0 to carry
   bcs .setDownAsteroidKernelVector;2³ + 1 branch if asteroid on left
   ldx #<DownMovingAsteroidOnRight;2
   stx downAsteroidKernelVector;3
.skipDownAsteroidDraw
   lda #0                     ; 2
   iny                        ; 2         increment scan line count
;--------------------------------------
   cpy #H_KERNEL - 3          ; 2 = @01
   beq .jmpToEndKernel        ; 2³ + 1
   tax                        ; 2
   jmp JumpToUpAsteroidKernel ; 3

.endKernel
   jmp JumpIntoEndKernel      ; 3

   FILL_BOUNDARY 256, 0

.setDownAsteroidKernelVector
   ldx #<DownMovingAsteroidOnLeft;2 = @70
   stx downAsteroidKernelVector;3
   lda #0                     ; 2
;--------------------------------------
   iny                        ; 2 = @01   increment scan line count
   cpy #H_KERNEL - 3          ; 2
   beq .endKernel             ; 2³ + 1
   tax                        ; 2
   jmp JumpToUpAsteroidKernel ; 3

.jmpToEndKernel
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
   ror                        ; 2         shift D0 into carry
   lda #0                     ; 2
   sta PF0                    ; 3 = @38   clear playfield graphic registers
   sta PF1                    ; 3 = @41
   bcs StartAsteroidsKernel   ; 2³
   bcc StartPlayerKernel      ; 3         unconditional branch

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
   lda asteroidAttributes,x   ; 4         get top asteroid attributes
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
   stx COLUP0                 ; 3 = @64   color top asteroid
   sta GRP0                   ; 3 = @67   clear player graphic data
   sta GRP1                   ; 3 = @70
   sta PF2                    ; 3 = @73   clear PF2 graphic data
   ldx downMovingAsteroidColor; 3         get down moving asteroid color
;--------------------------------------
   sta HMOVE                  ; 3
   stx COLUP1                 ; 3 = @06   color down moving asteroid
   sta NUSIZ1                 ; 3 = @09   set asteroid 1 sprite to ONE_COPY
   jmp (upAsteroidKernelVector);5

StartPlayerKernel
   lda rightPF2Graphics       ; 3
   sta PF2                    ; 3 = @52
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   lda leftPF0Graphics        ; 3         get the graphics for left PF0
   sta PF0                    ; 3 = @70   draw the last line for score kernel
   lda leftPF1Graphics        ; 3
   sta PF1                    ; 3 = @76
;--------------------------------------
   lda leftPF2Graphics        ; 3
   sta PF2                    ; 3 = @06
   lda playerState            ; 3         get current player state
   and #GAME_OVER             ; 2
   beq .continuePlayerKernel  ; 2³        branch if game active
   jmp GameSelectionKernel    ; 3

.continuePlayerKernel
   SLEEP_6                    ; 6 = @20
   SLEEP_4                    ; 4
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
   SLEEP_4                    ; 4
   dex                        ; 2
   bne .coarseMovePlayerCycle56;2³
   sta RESP0                  ; 3 = @51
   beq PositionUFOHorizontally; 3         unconditional branch

.coarseMovePlayerCycle56
   dex                        ; 2 = @51
   bne .coarseMovePlayerCycle61;2³
   sta RESP0                  ; 3 = @56
   beq PositionUFOHorizontally; 3         unconditional branch

.coarseMovePlayerCycle61
   dex                        ; 2 = @56
   bne .coarseMovePlayerCycle66;2³
   sta RESP0                  ; 3 = @61
   beq PositionUFOHorizontally; 3         unconditional branch

.coarseMovePlayerCycle66
   dex                        ; 2 = @61
   bne .coarseMovePlayerCycle71;2³
   sta RESP0                  ; 3 = @66
   beq PositionUFOHorizontally; 3         unconditional branch

.coarseMovePlayerCycle71
   dex                        ; 2 = @66
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @71
   beq .jmpIntoPositionUFOHorizontally;3 = @74 expected to happen @76

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
   SLEEP 2                    ; 2 = @17
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
   sta GRP0                   ; 3 = @06
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

JmpToCheckToMoveDiamondOrSharkHorizontally
   jmp CheckToMoveDiamondOrSharkHorizontally

SetupScoreKernel
   bit gameState                    ; check the current game state
   bvc ShowPlayerNumberOrLivesRemaining;branch if not showing the select screen
   lda #0
   sta activePlayerScore + 1
   sta activePlayerScore
   lda #<Blank
   sta leftPF2MSBGraphicIndex
   ldx #<zeroMSB
   stx rightPF2GraphicIndex
   jmp ShowLivesShipIcons

ShowPlayerNumberOrLivesRemaining
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   nop                              ; NOTE: These are here as a result of the
   nop                              ; programmer using Thomas' hack as a bases
   lda #<oneLSB                     ; assume player one is active
   bit gameState                    ; check the current game state
   bpl .setPF2GraphicsIndexes       ; branch if player 1 is active
   lda #<twoLSB                     ; set to point to player 2 literal
   bne .setPF2GraphicsIndexes       ; unconditional branch
;
; This code is never executed. It was left over from the original ROM. This 
; would display the number of ships remaining as a number. This hack uses this
; to show the active player number.
;
   .byte $A5,$BC,$29,$F0,$4A,$4A,$85,$F6,$4A,$4A,$65,$F6,$69,$32

.setPF2GraphicsIndexes
   sta rightPF2GraphicIndex
   lda #<zeroMSB
   sta leftPF2MSBGraphicIndex
ShowLivesShipIcons
   lda activePlayerVariables        ; get active player lives and direction
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
   sta livesGraphicIndex            ; set the lives graphic index
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
   jmp BANK0_SwitchToBank1

Bank0Start
   lda #<Bank1Start
   sta jumpVector
   lda #>Bank1Start
   sta jumpVector + 1
   jmp BANK0_SwitchToBank1

GetUpAsteroidSizeValue
   ldy #0
   lda (upAsteroidSizePtr),y
   ldy #>DetermineUpAsteroidKernelVector
   sty jumpVector + 1
   ldy #<DetermineUpAsteroidKernelVector
   sty jumpVector
   jmp BANK0_SwitchToBank1

GetDownAsteroidSizeValue
   ldy #0
   lda (downAsteroidSizePtr),y
   ldy #>DetermineDownAsteroidKernelVector
   sty jumpVector + 1
   ldy #<DetermineDownAsteroidKernelVector
   sty jumpVector
   jmp BANK0_SwitchToBank1

CheckToMoveDiamondOrSharkHorizontally
   lda frameCount                   ; get current frame count
   ror                              ; shift D0 to carry
   bcc .jmpToSetupScoreKernel       ; branch if processing player kernel
   lda playerState                  ; get current player state
   and #HYPERSPACE_FLAG
   bne .jmpToSetupScoreKernel       ; branch if player not shown
   ldx #$FF
   txs                              ; set stack to beginning
   ldx #NUM_ASTEROIDS + 2
.moveSharkOrDiamondHorizontally
   lda asteroidAttributes,x         ; get asteroid attributes
   and #MEDIUM_ASTEROID             ; keep MEDIUM_ASTEROID value
   beq .checkToMoveNextSharkOrDiamond
   lda asteroidAttributes,x         ; get asteroid attributes
   and #ASTEROID_ID_MASK
   bne .checkToMoveNextSharkOrDiamond
   lda asteroidVertPos,x            ; get asteroid vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .checkToMoveNextSharkOrDiamond;branch if object out of range
   txa                              ; move asteroid index number to accumulator
   pha                              ; push value to stack
   lda asteroidHorizPos,x           ; get the asteroid's horizontal position
   jsr BANK0_ConvertHorizPosToPixelValue
   sta tmpDiamondOrSharkHorizPos
   lda playerHorizPos               ; get player's horizontal position
   jsr BANK0_ConvertHorizPosToPixelValue
   sta tmpPlayerHorizPosValue
   pla                              ; pull asteroid index from stack
   tax                              ; move asteroid index to x
   lda tmpDiamondOrSharkHorizPos    ; get diamond or shark horizontal pixel value
   cmp tmpPlayerHorizPosValue       ; compare with player's horizontal pixel value
   beq .checkToMoveNextSharkOrDiamond
   jsr BANK0_MoveObjectHorizontally
.checkToMoveNextSharkOrDiamond
   dex
   bpl .moveSharkOrDiamondHorizontally
.jmpToSetupScoreKernel
   jmp SetupScoreKernel

BANK0_ConvertHorizPosToPixelValue
   tax                              ; move horizontal position value to x
   and #$0F                         ; mask fine motion value
   tay                              ; move coarse value to y
   txa                              ; move horizontal position value to accumulator
   lsr                              ; shift fine motion value to lower nybble
   lsr
   lsr
   lsr
   tax                              ; move fine motion value to x
   lda BANK0_FineMotionPixelValues,x
   clc
   adc BANK0_CoarsePixelValues,y
   rts

BANK0_FineMotionPixelValues
   .byte 6, 5, 4, 3, 2, 1, 0, 0
   .byte 14, 13, 12, 11, 10, 9, 8, 7

BANK0_CoarsePixelValues
   .byte 0, 0, 85, 0, 100, 13, 115
   .byte 28, 130, 43, 145, 58, 0, 73

BANK0_MoveObjectHorizontally
   bcs .objectTravelingLeft
   lda #<-16
   adc asteroidHorizPos,x           ; decrement object fine motion
   cmp #HMOVE_R7 | 1 << 1 | OBJECT_ON_LEFT
   bne .determineRightTravelingAsteroidPosition
   lda #HMOVE_L6 | 2 << 1 | OBJECT_ON_LEFT;set object to color clock 81
   bne .setObjectHorizontalPosition ; unconditional branch
   
.determineRightTravelingAsteroidPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; a == 2 || 4 <= a <= 11 || a == 13
   tay
   lda BANK0_RightTravelingObjectHorizAdjustment - 2,y
   bne .setObjectHorizontalPosition ; unconditional branch

.objectTravelingLeft
   lda #16 - 1                      ; carry bit set
   adc asteroidHorizPos,x           ; increment object fine motion
   cmp #HMOVE_L4 | 1 << 1 | OBJECT_ON_RIGHT
   bne .determineLeftTravelingAsteroidPosition
   lda #HMOVE_R8 | 6 << 1 | OBJECT_ON_LEFT;set object to color clock 155
   bne .setObjectHorizontalPosition ; unconditional branch
   
.determineLeftTravelingAsteroidPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; 3 <= a <= 11 || a == 13
   tay
   lda BANK0_LeftTravelingObjectHorizAdjustment - 3,y
.setObjectHorizontalPosition
   sta asteroidHorizPos,x
   rts

   .byte $40,$00                    ; not used

BANK0_RightTravelingObjectHorizAdjustment
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

BANK0_LeftTravelingObjectHorizAdjustment
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

GameSelectionLiterals
   .word OnePlayerLiteral
   .word PlayerLiteral
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word TwoPlayerLiteral
   .word PlayerLiteral

LeftBigSelectIcon
   .word GameSelectionIcon_00
   .word GameSelectionIcon_01
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank

LeftSmallSelectIcon
   .word GameSelectionIcon_02
   .word GameSelectionIcon_03
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank

RightBigSelectIcon
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word GameSelectionIcon_00
   .word GameSelectionIcon_01

RightSmallSelectIcon
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word PlayerLiteralBlank
   .word GameSelectionIcon_02
   .word GameSelectionIcon_03

OnePlayerLiteral
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $18 ; |...XX...|
PlayerLiteral
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $7C ; |.XXXXX..|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $7C ; |.XXXXX..|
TwoPlayerLiteral
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $0C ; |....XX..|
   .byte $02 ; |......X.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
PlayerLiteralBlank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameSelectionIcon_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $01 ; |.......X|
   .byte $3F ; |..XXXXXX|
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $04 ; |.....X..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameSelectionIcon_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $88 ; |X...X...|
   .byte $90 ; |X..X....|
   .byte $A0 ; |X.X.....|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $C0 ; |XX......|
   .byte $A0 ; |X.X.....|
   .byte $90 ; |X..X....|
   .byte $88 ; |X...X...|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
GameSelectionIcon_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $01 ; |.......X|
   .byte $06 ; |.....XX.|
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GameSelectionIcon_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $A0 ; |X.X.....|
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $40 ; |.X......|
   .byte $A0 ; |X.X.....|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

GameSelectionKernel
   ldx #$FF                   ; 2
   txs                        ; 2         set stack to beginning
   lda #0                     ; 2
   sta PF0                    ; 3 = @25   clear playfield graphic registers
   sta PF1                    ; 3 = @28
   sta PF2                    ; 3 = @31
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3         clear all horizontal movement
   lda #SELECT_ICON_XPOS      ; 2
   ldy #COLORS_SELECT_ICON    ; 2
   jsr PositionSelectionObjectsHorizontally;6 total of 6 scan lines
   ldx #134                   ; 2
.skipGameSelectionScanlines
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .skipGameSelectionScanlines;2³
   sta WSYNC
;--------------------------------------
   lda gameSelection          ; 3         get current game selection
   and #NUM_PLAYERS_BIT       ; 2         see if a two player game
   bne ShowSelectIconOnRight  ; 2³        branch if set for a two player game
   lda frameCount             ; 3         get current frame count
   ror                        ; 2         shift D1 into carry -- icon
   ror                        ; 2         animation updated every 30 frames
   bcc .showSmallSelectIcon   ; 2³
   lda #<LeftBigSelectIcon    ; 2
   sta graphicDataPointers    ; 3
   lda #>LeftBigSelectIcon    ; 2
   sta graphicDataPointers + 1; 3
   jmp DrawGameSelectionGraphics;3 = @29

.showSmallSelectIcon
   lda #<LeftSmallSelectIcon  ; 2
   sta graphicDataPointers    ; 3
   lda #>LeftSmallSelectIcon  ; 2
   sta graphicDataPointers + 1; 3
   jmp DrawGameSelectionGraphics;3 = @30

ShowSelectIconOnRight SUBROUTINE
   lda frameCount             ; 3         get current frame count
   ror                        ; 2         shift D1 into carry -- icon
   ror                        ; 2         animation updated every 30 seconds
   bcc .showSmallSelectIcon   ; 2³
   lda #<RightBigSelectIcon   ; 2
   sta graphicDataPointers    ; 3
   lda #>RightBigSelectIcon   ; 2
   sta graphicDataPointers + 1; 3
   jmp DrawGameSelectionGraphics;3 = @30

.showSmallSelectIcon
   lda #<RightSmallSelectIcon ; 2
   sta graphicDataPointers    ; 3
   lda #>RightSmallSelectIcon ; 2
   sta graphicDataPointers + 1; 3
   jmp DrawGameSelectionGraphics;3 = @31 could just fall through

DrawGameSelectionGraphics
   sta WSYNC
;--------------------------------------
   jsr SetupGraphicPointerData; 6         total of 2 scan lines
   lda #H_SELECT_ICON - 1     ; 2 = @43
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #<GameSelectionLiterals; 2
   sta graphicDataPointers    ; 3
   lda #>GameSelectionLiterals; 2
   sta graphicDataPointers + 1; 3 = @10
   jsr SetupGraphicPointerData; 6         total of 2 scan lines
   lda #H_GAME_SELECTION - 1  ; 2 = @53
   sta graphicPointerIndex    ; 3
   jsr DrawIt                 ; 6
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05   clear player graphic registers
   sta GRP1                   ; 3 = @08
   sta ENABL                  ; 3 = @11   disable BALL
   sta ENAM0                  ; 3 = @14   disable player missiles
   sta ENAM1                  ; 3 = @17
   sta PF0                    ; 3 = @20   clear playfield graphic registers
   sta PF1                    ; 3 = @23
   sta PF2                    ; 3 = @26
   sta VDELP0                 ; 3 = @29   don't vertically delay the players
   sta VDELP1                 ; 3 = @32
   jmp JumpToOverscan         ; 3

PositionSelectionObjectsHorizontally
   sta WSYNC
;--------------------------------------
   ldx #0                     ; 2
   stx GRP0                   ; 3 = @05   clear player graphic registers
   stx GRP1                   ; 3 = @08
   stx VDELP0                 ; 3 = @11   turn off vertical delay of players
   stx VDELP1                 ; 3 = @14
   sta WSYNC
;--------------------------------------
   stx GRP0                   ; 3 = @03
   stx GRP1                   ; 3 = @06
   sta tmpSelectObjectHorizPos; 3
   jsr PositionObjectHorizontally;6
   ldx #1                     ; 2         prepare to move player 2
   lda tmpSelectObjectHorizPos; 3
   clc                        ; 2
   adc #8                     ; 2
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   lda #MSBL_SIZE4 | THREE_COPIES;2
   sta NUSIZ0                 ; 3 = @05
   sta NUSIZ1                 ; 3 = @08
   sty COLUP0                 ; 3 = @11
   sty COLUP1                 ; 3 = @14
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @08   vertically delay players
   sta VDELP1                 ; 3 = @11
   rts                        ; 6

PositionObjectHorizontally
   sec                        ; 2
   sta WSYNC
;--------------------------------------
.divideBy15
   sbc #15                    ; 2
   bcs .divideBy15            ; 2³
   eor #7                     ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta HMP0,x                 ; 4
   sta RESP0,x                ; 4
   rts                        ; 6
;
; This routine takes 193 cycles (~2 1/2 scan lines) to execute. This computation
; includes the 6 cycles from the JSR to get here.
;
SetupGraphicPointerData
   ldy #11                    ; 2
.setupGraphicsLoop
   lda (graphicDataPointers),y; 5
   sta graphicPointers,y      ; 5
   dey                        ; 2
   bpl .setupGraphicsLoop     ; 2³
   rts                        ; 6

   FILL_BOUNDARY 256, 0

DrawIt
   ldy graphicPointerIndex    ; 3
   lda (graphicPointers + 10),y;5
   sta tempCharHolder         ; 3
   sta WSYNC
;--------------------------------------
   lda (graphicPointers + 8),y; 5
   tax                        ; 2
   lda (graphicPointers),y    ; 5
   SLEEP 2                    ; 2
   sta GRP0                   ; 3 = @17
   lda (graphicPointers + 2),y; 5
   sta GRP1                   ; 3 = @25
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @33
   lda (graphicPointers + 6),y; 5
   ldy tempCharHolder         ; 3
   sta GRP1                   ; 3 = @44
   stx GRP0                   ; 3 = @47
   sty GRP1                   ; 3 = @50
   sta GRP0                   ; 3 = @53
   dec graphicPointerIndex    ; 5
   bpl DrawIt                 ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @65
   sta GRP1                   ; 3 = @68
   rts                        ; 6 = @74

   FILL_BOUNDARY 1024, 0

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
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
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
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   
   FILL_BOUNDARY 256, 0

HorizMoveSizeTable
LargeAsteroidHorizMoveSizeTable_00
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
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
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ    | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
   .byte HMOVE_0  | NO_ASTEROID_HORIZ_ADJ | DOUBLE_SIZE
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
   
   FILL_BOUNDARY 48, 0
   
SmallAsteroidHorizMoveSizeTable
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte HMOVE_0  | ASTEROID_HORIZ_ADJ | ONE_COPY
   .byte 0
   
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
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | TWO_COPIES
   .byte TWO_COPIES << 4 | TWO_COPIES
   .byte TWO_COPIES << 4 | THREE_COPIES
   .byte THREE_COPIES << 4 | THREE_COPIES

LivesCoarseMoveValues
   .byte 0, 0, 2, 1, 1, 0, 0, 0
;
; The following bytes are not referenced
;
   .byte $0D,$0D,$0D,$05,$05,$05,$05,$05,$0D,$05,$0D,$05,$0D,$0D,$0D,$00
   .byte $0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$05,$05,$05,$0D,$0D
   
   FILL_BOUNDARY 256, 0

AsteroidSprites
LargeAsteroid_00
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $26 ; |..X..XX.|
   .byte $41 ; |.X.....X|
   .byte $81 ; |X......X|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $42 ; |.X....X.|
   .byte $22 ; |..X...X.|
   .byte $41 ; |.X.....X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|

   FILL_BOUNDARY 16, 0

LargeAsteroid_01   
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $46 ; |.X...XX.|
   .byte $41 ; |.X.....X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $82 ; |X.....X.|
   .byte $84 ; |X....X..|
   .byte $42 ; |.X....X.|
   .byte $82 ; |X.....X.|
   .byte $81 ; |X......X|
   .byte $41 ; |.X.....X|
   .byte $22 ; |..X...X.|
   .byte $1C ; |...XXX..|

   FILL_BOUNDARY 32, 0
   
MediumAsteroid
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $52 ; |.X.X..X.|
   .byte $2C ; |..X.XX..|

   FILL_BOUNDARY 48, 0
   
SmallAsteroid
   .byte $60 ; |.XX.....|
   .byte $90 ; |X..X....|
   .byte $D0 ; |XX.X....|
   .byte $20 ; |..X.....|

   FILL_BOUNDARY 64, 0
   
AsteroidExplosion_00
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

   FILL_BOUNDARY 80, 0
   
AsteroidExplosion_01
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

   FILL_BOUNDARY 96, 0
   
AsteroidExplosion_02
   .byte $50 ; |.X.X....|
   .byte $02 ; |......X.|
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $41 ; |.X.....X|

   FILL_BOUNDARY 112, 0

AsteroidExplosion_03
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $80 ; |X.......|
   .byte $20 ; |..X.....|

   FILL_BOUNDARY 256, 0

KillerSatelliteSprites
LargeKillerSatellite_00
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|

   FILL_BOUNDARY 16, 0

LargeKillerSatellite_01
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|

   FILL_BOUNDARY 32, 0
   
DiamondKillerSatellite
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $2A ; |..X.X.X.|
   .byte $49 ; |.X..X..X|
   .byte $2A ; |..X.X.X.|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|

   FILL_BOUNDARY 48, 0
   
SharkKillerSatellite
   .byte $F0 ; |XXXX....|
   .byte $A0 ; |X.X.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|

   FILL_BOUNDARY 64, 0
   
KillerSatelliteExplosion_00
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

   FILL_BOUNDARY 80, 0

KillerSatelliteExplosion_01
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

   FILL_BOUNDARY 96, 0

KillerSatelliteExplosion_02
   .byte $50 ; |.X.X....|
   .byte $02 ; |......X.|
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $41 ; |.X.....X|

   FILL_BOUNDARY 112, 0

KillerSatelliteExplosion_03
   .byte $40 ; |.X......|
   .byte $10 ; |...X....|
   .byte $80 ; |X.......|
   .byte $20 ; |..X.....|

PlayerShipSprites
PlayerRotation_00
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $22 ; |..X...X.|
   .byte $55 ; |.X.X.X.X|
   .byte $3E ; |..XXXXX.|
   .byte SPRITE_END
PlayerRotation_01
   .byte $20 ; |..X.....|
   .byte $39 ; |..XXX..X|
   .byte $17 ; |...X.XXX|
   .byte $0A ; |....X.X.|
   .byte $3C ; |..XXXX..|
   .byte SPRITE_END
PlayerRotation_02
   .byte $79 ; |.XXXX..X|
   .byte $27 ; |..X..XXX|
   .byte $1D ; |...XXX.X|
   .byte $0A ; |....X.X.|
   .byte $1C ; |...XXX..|
   .byte SPRITE_END
PlayerRotation_03
   .byte $00 ; |........|
   .byte $F2 ; |XXXX..X.|
   .byte $4E ; |.X..XXX.|
   .byte $36 ; |..XX.XX.|
   .byte $1E ; |...XXXX.|
   .byte SPRITE_END
PlayerRotation_04
   .byte $04 ; |.....X..|
   .byte $3A ; |..XXX.X.|
   .byte $C2 ; |XX....X.|
   .byte $3A ; |..XXX.X.|
   .byte $04 ; |.....X..|
   .byte SPRITE_END
PlayerRotation_05
   .byte $1E ; |...XXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $4E ; |.X..XXX.|
   .byte $F2 ; |XXXX..X.|
   .byte $00 ; |........|
   .byte SPRITE_END
PlayerRotation_06
   .byte $1C ; |...XXX..|
   .byte $0A ; |....X.X.|
   .byte $1D ; |...XXX.X|
   .byte $27 ; |..X..XXX|
   .byte $79 ; |.XXXX..X|
   .byte SPRITE_END
PlayerRotation_07
   .byte $3C ; |..XXXX..|
   .byte $0A ; |....X.X.|
   .byte $17 ; |...X.XXX|
   .byte $39 ; |..XXX..X|
   .byte $20 ; |..X.....|
   .byte SPRITE_END
PlayerRotation_08
   .byte $3E ; |..XXXXX.|
   .byte $55 ; |.X.X.X.X|
   .byte $22 ; |..X...X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
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
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $5A ; |.X.XX.X.|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
   .byte SPRITE_END
   
UFOSprite
   .byte $18 ; |...XX...|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte SPRITE_END
SatelliteSprite
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $18 ; |...XX...|
   .byte SPRITE_END

   FILL_BOUNDARY 208, 0

BANK0_SwitchToBank3
   sta BANK3STROBE
   jmp (jumpVector)

BANK0_SwitchToBank2
   sta BANK2STROBE
   jmp (jumpVector)

BANK0_SwitchToBank1
   sta BANK1STROBE
   jmp (jumpVector)

BANK0_SwitchToBank0
   sta BANK0STROBE
   jmp (jumpVector)

   FILL_BOUNDARY 246, 0

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data

   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK0 FREE"

   .word Bank0Start
   .word Bank0Start
   .word Bank0Start

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
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   lda SWCHB                        ; read console switches
   ror                              ; RESET now in carry
   ror                              ; SELECT now in carry RESET now in D7
   bcs .clearSelectDebounce         ; branch if SELECT not pressed
   bit gameSelection                ; check current game selection
   bvs .selectSwitchDown            ; branch if SELECT switch held down
   lda gameSelection                ; get current game selection
   ora #SELECT_DEBOUNCE
   sta gameSelection                ; set SELECT debounce
   lda gameState                    ; get current game state
   ora #SHOW_SELECT_SCREEN
   sta gameState                    ; set to show select screen
   lda playerState                  ; get current player state
   ora #GAME_OVER
   sta playerState                  ; set to show game is over
   jsr InitAsteroidObjects
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
   lda gameSelection                ; get current game selection
   eor #NUM_PLAYERS_BIT             ; alternate between one or two player game
   and #CHILD_GAME | SELECT_DEBOUNCE | NUM_PLAYERS_BIT
   sta gameSelection                ; set new game selection values
.doneGameSelection
   jmp FindOutOfRangeAsteroids

.clearSelectDebounce
   lda gameSelection                ; get current game selection
   and #<~SELECT_DEBOUNCE
   sta gameSelection
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET to carry
   bcs FindOutOfRangeAsteroids      ; branch if RESET not pressed
   lda #BLACK
   sta COLUBK                       ; color the background BLACK
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
   jmp JumpToPlayGameSounds

CollisionDetection
   lda asteroidCollisionState       ; get asteroid collision state
   and #ASTEROID_COLLISION_MASK
   bne .performAsteroidCollision
   bit playerState                  ; check current player state
   bvs .shipShieldsActive           ; branch if using shields
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcs .jmpToPlayGameSounds         ; branch if game over
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CheckToPerformAsteroidCollision;branch if not in Hyperspace
   lda shieldTimer                  ; get shield timer value
   beq CheckToSpawnNewPlayerShip
.shipShieldsActive
   lda ufoVertPos                   ; get UFO current vertical position
   cmp #VERT_OUT_OF_RANGE
   bne CheckToPerformAsteroidCollision;maybe asteroid hit UFO
   lda playerM1Direction
   ora playerM2Direction
   ora ufoMissileDirection
   bne CheckToPerformAsteroidCollision;maybe asteroid hit a missile
   jmp JumpToPlayGameSounds

CheckToSpawnNewPlayerShip
   lda playerState                  ; get current player state
   and #KILL_FLAG
   beq .repositionVerticalPlayerShipPosition      ;2
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
   and #NUM_PLAYERS_BIT             ; see if this is a two player game
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
   jmp JumpToPlayGameSounds

CheckToPerformAsteroidCollision
   lda asteroidCollisionState       ; get asteroid collision state
   and #ASTEROID_COLLISION_MASK     ; keep asteroid collision flag value
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
   lda asteroidCollisionState       ; get asteroid collision state
   and #<~ASTEROID_COLLISION_MASK   ; clear ASTEROID_COLLISION value
   sta asteroidCollisionState
   jmp .jmpToPlayGameSounds

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
   jmp JumpToPlayGameSounds

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
   jmp JumpToPlayGameSounds

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
   lda shieldTimer
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
   jmp JumpToPlayGameSounds

.checkUFOCollisions
   ldy ufoVertPos                   ; get UFO vertical position
   cpy #VERT_OUT_OF_RANGE
   beq .checkNextObjectCollisions   ; branch if UFO not present on screen
   jsr DetermineActiveUFOId
   ldy ufoHorizPos
   jsr CheckAsteroidCollisions      ; check UFO and asteroid collision
   jmp JumpToPlayGameSounds

.checkUFOMissileCollisions
   lda ufoMissileDirection          ; get UFO missile direction
   beq .checkNextObjectCollisions   ; branch if UFO missile not active
   lda ufoMissileVertPos            ; get UFO missile vertical position
   ldy ufoMissileHorizPos           ; get UFO missile horizontal position
   ldx #ID_SHOT_UFO
   jsr CheckAsteroidCollisions      ; check ID_SHOT_UFO colliding with asteroid
   ldy playerVertPos                ; get player vertical position
   cpy #VERT_OUT_OF_RANGE
   beq JumpToPlayGameSounds
   bit playerState                  ; check current player state
   bvs JumpToPlayGameSounds         ; branch if player shield is active
   lda shieldTimer
   bmi JumpToPlayGameSounds
   ldx #ID_PLAYER_SHIP
   tya                              ; move player vertical position to accumulator
   ldy playerHorizPos               ; get player ship horizontal position
   jsr CheckObjectCollisions        ; check ID_SHOT_UFO and PLAYER_SHIP collision
JumpToPlayGameSounds
   lda #<PlayGameSounds
   sta jumpVector
   lda #>PlayGameSounds
   sta jumpVector + 1
   jmp BANK1_SwitchToBank2

VerticalSync SUBROUTINE
   ldx #$FF
.waitTime
   lda INTIM
   bne .waitTime
   stx VSYNC                        ; start vertical sync (D1 = 1)
   stx VBLANK                       ; disable TIA (D1 = 1)
   sta WSYNC                        ; first line of vertical sync
   sta WSYNC                        ; second line of vertical sync
   sta WSYNC                        ; third line of vertical sync
   sta VSYNC                        ; end vertical sync (D1 = 0)
   sta VBLANK                       ; enable TIA (D1 = 0)
   lda #VBLANK_TIME
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
   and #NUM_PLAYERS_BIT             ; keep NUM_PLAYERS_BIT value
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
   beq .setTopUpAsteroidMotionValues
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
   jmp BANK1_SwitchToBank0

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
   jmp BANK1_SwitchToBank0

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
   jsr BubbleDownAsteroidList
   jmp .setTopUpAsteroidMotionValues

CheckToLaunchUFO
   lda SWCHB                        ; read console switches
   bit gameState                    ; check current game state
   bmi .determinePlayerDifficulty   ; branch if player 2 is active
   asl                              ; shift player 1 difficulty to D7
.determinePlayerDifficulty
   asl                              ; shift difficulty value to carry
   bcs .checkToLaunchUFO
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
   jsr NextRandom
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
   jsr BANK1_MoveObjectHorizontally
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
   bcc .launchUFOMissile
   and #3                           ; keep top 4 rotation values...0 <= a <= 3
   sta tmpUFOMissileDirection
   lda ufoHorizPos                  ; get UFO horizontal position value
   jsr BANK1_ConvertHorizPosToPixelValue
   sta tmpUFOHorizPixelValue
   lda playerHorizPos               ; get player ship horizontal position
   jsr BANK1_ConvertHorizPosToPixelValue;convert to color clock value
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
   bcs .doneSetGameOver
   ldx #1
   stx frameCount + 1
   dex                              ; x = 0
   stx frameCount
   lda playerState                  ; get current player state
   ora #GAME_OVER
   sta playerState
   jsr InitAsteroidObjects
.doneSetGameOver
   jmp .doneAdjustPlayerShipPositions

ReadJoystickValues
   lda SWCHA                        ; read joystick values
   and #P0_NO_MOVE                  ; mask player 2's joystick value
   sta joystickValue                ; save joystick value
;
; These bytes are here to waste 8 bytes. They were placed here by Thomas
; Jentzsch for his Asteroids hack to align data. Apparently, Thomas' hack was
; used as a base for this game.
;
   bit joystickValue
   bit joystickValue
   bit joystickValue
   bit joystickValue
   bit playerState                  ; check current player state
   bvc CheckActivePlayerShipFeatures; branch if shield not on
   and #<~MOVE_DOWN                 ; keep MOVE_DOWN value
   beq .shieldsActive
   lda playerState                  ; get current player state
   and #<~SHIELD_FLAG               ; clear shield flag
   sta playerState
   jmp CheckActivePlayerShipFeatures

.shieldsActive
   jmp PlayerShipThrustDamping

CheckActivePlayerShipFeatures
   lda playerVertPos                ; get player's vertical position
   cmp #VERT_OUT_OF_RANGE
   beq .hyperspaceActiveForPlayerShip
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
   beq .playerFeatureActivated      ; branch if joystick pushed down
   jmp .disablePlayerFeatures

.playerFeatureActivated
   lda gameSelection                ; get current game selection
   and #FEATURE_BITS                ; keep FEATURE_BITS value
   cmp #FEATURE_BITS_NONE
   bne .determineToActivateShields
   jmp .disablePlayerFeatures

.determineToActivateShields
   lda asteroidCollisionState
   ror                              ; shift ASTEROID_COLLISION value to carry
   bcc .checkToEnableShields        ; branch if asteroid didn't collide
   jmp CheckPlayerShipRotation

.checkToEnableShields
   lda gameSelection                ; get current game selection
   and #NUM_PLAYERS_BIT             ; see if this is a two player game
   beq .checkToEnablePlayer1Shields ; branch if one player game
   bit gameState                    ; check current game state
   bmi .checkToEnablePlayer2Shields ; branch if player 2 is active
.checkToEnablePlayer1Shields
   lda asteroidCollisionState
   and #P1_SHIELD_USAGE_MASK        ; keep number of times player 1 used shields
   cmp #MAX_SHIELD_USAGE << 6
   beq CheckPlayerShipRotation      ; branch if shield used maximum number of times
   clc
   adc #1 << 6                      ; increment number of times shield used by 1
   sta tmpShieldUsageCounter        ; save shield usage value
   lda asteroidCollisionState
   and #<~P1_SHIELD_USAGE_MASK      ; clear player 1 SHIELD_USAGE values
   ora tmpShieldUsageCounter        ; combine with new shield usage value
   sta asteroidCollisionState       ; set new SHIELD_USAGE value
   jmp .turnOnShield

.checkToEnablePlayer2Shields
   lda asteroidCollisionState
   and #P2_SHIELD_USAGE_MASK        ; keep number of times player 2 used shields
   cmp #MAX_SHIELD_USAGE << 4
   beq CheckPlayerShipRotation      ; branch if shield used maximum number of times
   clc
   adc #1 << 4                      ; increment number of times shield used by 1
   sta tmpShieldUsageCounter        ; save shield usage value
   lda asteroidCollisionState
   and #<~P2_SHIELD_USAGE_MASK      ; clear player 2 SHIELD_USAGE values
   ora tmpShieldUsageCounter        ; combine with new shield usage value
   sta asteroidCollisionState       ; set new SHIELD_USAGE value
.turnOnShield
   lda playerState                  ; get current player state
   ora #SHIELD_FLAG
   sta playerState
   bne CheckPlayerShipRotation      ; unconditional branch
;
; The following bytes are not used. They were left over from the original
; Asteroids ROM for hyperspace feature.
;
   .byte $A5,$C8,$29,$04,$D0,$08,$A5,$C8,$09,$04,$85,$C8,$D0,$36,$A5,$CA
   .byte $C9,$E0,$F0,$30,$A9,$E0,$85,$CA,$A5,$C8,$29,$F9,$85,$C8,$20,$B0
   .byte $19,$85,$C9,$A5,$81,$4A,$C9,$4F,$90,$02,$E9,$4F,$85,$DF,$A9,$00
   .byte $A2,$05,$95,$CB,$CA,$10,$FB,$A9,$1F,$85,$DE,$4C,$2A,$17

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
   lda INPT4                        ; read player 1 fire button state
   and INPT5                        ; combine with player 2 fire button state
   bmi .clearFireButtonDebounceFlag ; branch if fire button not pressed
   lda gameState                    ; get current game state
   and #FIRE_FLAG                   ; keep fire button debounce flag
   bne .checkForShipThrust
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
   ldx playerHorizPos               ; get player ship horizontal position
   stx playerMissilesHorizPos,y
   lda soundEngineValues            ; get sound engine values
   and #SOUND_BITS_BONUS_SHIP
   bne .setPlayerMissileDiectionValues
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
   beq .adjustNextVelocityValue
   lda playerShipVelocityFraction,x ; get player ship velocity fraction value
   nop
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
   beq DetermineUFOSpriteLSBValue
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
   lda gameSelection                ; get current game selection
   and #NUM_PLAYERS_BIT             ; see if this is a two player game
   beq .clearPlayer1ShieldUsage     ; branch if one player game
   bit gameState                    ; check current game state
   bmi .clearPlayer2ShieldUsage     ; branch if player 2 is active
.clearPlayer1ShieldUsage
   lda asteroidCollisionState
   and #<~P1_SHIELD_USAGE_MASK      ; clear P1_SHIELD_USAGE value
   sta asteroidCollisionState
   jmp .doneClearPlayerShieldUsage

.clearPlayer2ShieldUsage
   lda asteroidCollisionState
   and #<~P2_SHIELD_USAGE_MASK      ; clear P2_SHIELD_USAGE value
   sta asteroidCollisionState
.doneClearPlayerShieldUsage
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
   lda playerVertPos
   bmi .wrapPlayerShipVertically
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
   bpl .adjustMissileVerticalPosition
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
   bpl .adjustMissileHorizontalPosition
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

Bank1Start
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
   lda #<ContinueStartupInBank2
   sta jumpVector
   lda #>ContinueStartupInBank2
   sta jumpVector + 1
   jmp BANK1_SwitchToBank2

StartGameWithCollisionsSet
   lda #UFO_COLLISION_FLAG
   sta gameState
StartGameWithoutCollisionsSet
   sta bonusShipSoundTimer
   lda #>AsteroidSprites + 224
   sta upAsteroidSizePtr + 1
   sta downAsteroidSizePtr + 1
   lda #>AsteroidSprites + 225
   sta upAsteroidGraphicsPtr + 1
   sta downAsteroidGraphicsPtr + 1
   lda #>UpMovingAsteroidKernel
   sta upAsteroidKernelVector + 1
   lda #>DownMovingAsteroidKernel + 224
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
   lda asteroidCollisionState
   ora #ASTEROID_COLLISION_MASK
   sta asteroidCollisionState
   jmp VerticalSync

MoveAsteroidHorizontally
   lda asteroidAttributes,x         ; get attribute value for asteroid
   lsr                              ; shift ASTEROID_TYPE to lower nybbles
   lsr
   lsr
   lsr
   sta tmpAsteroidAttribute
   lda gameSelection                ; get current game selection
   bmi .childGameAsteroidMovementDelay;branch if a CHILD_GAME - from Asteroids game..never happens
   and #ASTEROID_SPEED_BIT          ; keep ASTEROID_SPEED_BIT value
   bne .fastMovingAsteroids         ; branch if ASTEROID_SPEED_FAST
   lda tmpAsteroidAttribute         ; get asteroid type
   and #ASTEROID_TYPE_MASK >> 4     ; remove ASTEROID_SPEED_BIT value
   bpl .determineToMoveAsteroidHorizontally;unconditional branch
 
.fastMovingAsteroids
   lda tmpAsteroidAttribute         ; get asteroid type
.determineToMoveAsteroidHorizontally
   tay                              ; move asteroid type to y register
   lda AsteroidHorizDelayValues,y   ; get horizontal delay values for asteroid
   beq BANK1_MoveObjectHorizontally ; branch if asteroid should move now
.horizontallyDelayAsteroidMovement
   bit asteroidHorizDelayBits
   bne BANK1_MoveObjectHorizontally
   rts

.childGameAsteroidMovementDelay
   lda #ASTEROID_HORIZ_DELAY_SLOW
   bne .horizontallyDelayAsteroidMovement;unconditional branch
   
BANK1_MoveObjectHorizontally SUBROUTINE
   bcs .objectTravelingLeft
   lda #<-16
   adc asteroidHorizPos,x           ; decrement object fine motion
   cmp #HMOVE_R7 | 1 << 1 | OBJECT_ON_LEFT
   bne .determineRightTravelingAsteroidPosition
   lda #HMOVE_L6 | 2 << 1 | OBJECT_ON_LEFT;set object to color clock 81
   bne .setObjectHorizontalPosition ; unconditional branch
   
.determineRightTravelingAsteroidPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; a == 2 || 4 <= a <= 11 || a == 13
   tay
   lda BANK1_RightTravelingObjectHorizAdjustment - 2,y
   bne .setObjectHorizontalPosition
   
.objectTravelingLeft
   lda #16 - 1                      ; carry bit set
   adc asteroidHorizPos,x           ; increment object fine motion
   cmp #HMOVE_L4 | 1 << 1 | OBJECT_ON_RIGHT
   bne .determineLeftTravelingAsteroidPosition
   lda #HMOVE_R8 | 6 << 1 | OBJECT_ON_LEFT;set object to color clock 155
   bne .setObjectHorizontalPosition ; unconditional branch
   
.determineLeftTravelingAsteroidPosition
   cmp #HMOVE_L7
   bcc .setObjectHorizontalPosition
   cmp #HMOVE_R8
   bcs .setObjectHorizontalPosition
   and #COARSE_VALUE | OBJECT_SIDE  ; 3 <= a <= 11 || a == 13
   tay
   lda BANK1_LeftTravelingObjectHorizAdjustment - 3,y
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
   jmp BANK1_SwitchToBank2

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
   jsr BANK1_ConvertHorizPosToPixelValue;convert horizontal position to pixel value
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
   ora #ASTEROID_HIT
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
   ora #ASTEROID_HIT
   sta asteroidAttributes,x
   sta asteroidAttributes,y
.doneCheckDownAsteroidCollision
   rts

CheckObjectCollisions
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
   jsr BANK1_ConvertHorizPosToPixelValue;convert horizontal position to pixel value
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
   ora #ASTEROID_HIT
   sta asteroidAttributes,y         ; set to show asteroid hit and hit color
   lda asteroidCollisionState
   ora #ASTEROID_COLLISION_MASK
   sta asteroidCollisionState       ; set to show asteroid collided
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
   and #BONUS_SHIP_BITS             ; keep BONUS_SHIP_BITS values
   beq .determine5000PointExtraLife
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
   lda asteroidCollisionState
   ora #ASTEROID_COLLISION_MASK
   sta asteroidCollisionState
   sec                              ; set to mark asteroid collided
   rts

BANK1_ConvertHorizPosToPixelValue
   tax                              ; move horizontal position value to x
   and #$0F                         ; mask fine motion value
   tay                              ; move coarse value to y
   txa                              ; move horizontal position value to accumulator
   lsr                              ; shift fine motion value to lower nybble
   lsr
   lsr
   lsr
   tax                              ; move fine motion value to x
   lda BANK1_FineMotionPixelValues,x
   clc
   adc BANK1_CoarsePixelValues,y
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
   jsr BubbleDownAsteroidList
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
   lda asteroidAttributes,x         ; get asteroid attributes
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
   lda asteroidAttributes,x         ; get attribute value for asteroid
   and #ASTEROID_FAST | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   ora #MEDIUM_ASTEROID
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
   jsr BubbleUpAsteroidList
   ldx tmpAsteroidBubbleUpBoundary
   inx
   lda tmpSavedStartingAsteroidIdx
   sta tmpStartingAsteroidIdx
   inc tmpNonExistentAsteroidIdx
   lda asteroidAttributes,x         ; get attribute value for asteroid
   and #ASTEROID_DIRECTION          ; keep asteroid direction value
   sta tmpAsteroidDirection
   jsr NextRandom
   lda asteroidAttributes,x         ; get asteroid attributes
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
   lda asteroidAttributes,x         ; get asteroid attributes
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

BubbleDownAsteroidList
.bubbleDownAsteroidList
   lda asteroidHorizPos + 1,x
   sta asteroidHorizPos,x
   lda asteroidAttributes + 1,x     ; get attribute value for asteroid
   sta asteroidAttributes,x
   lda asteroidVertPos + 1,x
   sta asteroidVertPos,x
   inx
   cmp #VERT_OUT_OF_RANGE
   bne .bubbleDownAsteroidList
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
   ldx #START_UP_MOVING_ASTEROID_IDX
   lda asteroidAttributes,x         ; get asteroid attributes
   and #<~ASTEROID_ID_MASK          ; clear ASTEROID_ID value
   sta asteroidAttributes,x
   rts

InitAsteroidAttributesAndPosition
   lda #1
   sta asteroidVertPos,x            ; set asteroid vertical position to 1
   jsr NewPseudoRandomHorizPosition
   sta asteroidHorizPos,x           ; set asteroid horizontal position value
   jsr NextRandom                   ; get a new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   ora #1
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
   ora #2
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
   ora #4
   sta asteroidAttributes,x         ; set asteroid initial attributes
   inx                              ; set next asteroid in list
.setLastAsteroidInitValues
   lda #[H_LARGE_ASTEROID + 6] * 3
   sta asteroidVertPos,x            ; set asteroid initial vertical position
   jsr NewPseudoRandomHorizPosition
   sta asteroidHorizPos,x           ; set asteroid initial horizontal value
   jsr NextRandom                   ; get new random number
   and #LARGE_ASTEROID | ASTEROID_DIRECTION | ASTEROID_ID_MASK
   ora #6
   sta asteroidAttributes,x         ; set asteroid initial attributes
   lda #VERT_OUT_OF_RANGE
   sta asteroidVertPos + 1,x        ; set end of asteroid array
   rts

InsertNewAsteroidIntoList
   stx insertListIdxToMove          ; set the index that will be moved
   ldx tmpStartingIdxForInsertList  ; get the starting index for the list
   jsr BubbleUpAsteroidList
   ldy insertListIdxToMove          ; get the index that will be moved
   iny
   lda asteroidHorizPos,y
   sta asteroidHorizPos,x
   lda asteroidAttributes,y         ; get attribute value for asteroid
   sta asteroidAttributes,x
   rts

BubbleUpAsteroidList
   inx
.bubbleUpAsteroidList
   lda asteroidVertPos,x            ; get asteroid vertical position
   sta asteroidVertPos + 1,x        ; move to the position above
   lda asteroidHorizPos,x           ; get asteroid horizontal position
   sta asteroidHorizPos + 1,x       ; move to the position above
   lda asteroidAttributes,x         ; get attribute value for asteroid
   sta asteroidAttributes + 1,x     ; move to the position above
   dex
   cpx tmpAsteroidBubbleUpBoundary
   bpl .bubbleUpAsteroidList
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

.asteroidInCenter
   tya                              ; move asteroid vertical position to a
   bmi .nextAsteroid                ; branch if asteroid not active
   cmp #INIT_PLAYER_Y - [(H_PLAYER_SHIP * 6) + 3]
   bcc .nextAsteroid
   cmp #INIT_PLAYER_Y + [(H_PLAYER_SHIP * 4) + 3]
   bcs .nextAsteroid
   cmp #0                           ; no safe zone found
   rts

.asteroidLeftOfCenter
.asteroidRightOfCenter
   tya                              ; move vertical position to accumulator
   cmp #INIT_PLAYER_Y - [(H_PLAYER_SHIP * 3) + 2]
   bcc .nextAsteroid
   cmp #INIT_PLAYER_Y + (H_PLAYER_SHIP * 3)
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
; last 8 bytes shared with table below causing the missile range to be off for
; values in quadrants 1 and 4
;

AsteroidHorizDelayValues
;
; slow asteroids
;
   .byte ASTEROID_HORIZ_DELAY_MEDIUM
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; MEDIUM_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; SMALL_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; MEDIUM_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; SMALL_ASTEROID | ASTEROID_HIT
;
; fast asteroids
;
   .byte ASTEROID_HORIZ_DELAY_SLOW
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_FAST  ; MEDIUM_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_FAST  ; SMALL_ASTEROID
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_SLOW  ; LARGE_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_MEDIUM; MEDIUM_ASTEROID | ASTEROID_HIT
   .byte ASTEROID_HORIZ_DELAY_FAST  ; SMALL_ASTEROID | ASTEROID_HIT

BANK1_RightTravelingObjectHorizAdjustment
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

BANK1_LeftTravelingObjectHorizAdjustment
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

BANK1_FineMotionPixelValues
   .byte 6, 5, 4, 3, 2, 1, 0, 0
   .byte 14, 13, 12, 11, 10, 9, 8, 7

BANK1_CoarsePixelValues
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

   .byte $60,$C1,$80,$E1,$C0,$60,$E0,$40 ; not used

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
   lda #<JmpToCheckToMoveDiamondOrSharkHorizontally
   sta jumpVector
   lda #>JmpToCheckToMoveDiamondOrSharkHorizontally
   sta jumpVector + 1
   jmp BANK1_SwitchToBank0

   .byte $60                        ; not used

   FILL_BOUNDARY 464, 0

BANK1_SwitchToBank3
   sta BANK3STROBE
   jmp (jumpVector)

BANK1_SwitchToBank2
   sta BANK2STROBE
   jmp (jumpVector)

BANK1_SwitchToBank1
   sta BANK1STROBE
   jmp (jumpVector)

BANK1_SwitchToBank0
   sta BANK0STROBE
   jmp (jumpVector)

   FILL_BOUNDARY 246, 0

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data
   
   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK1 FREE"

   .word Bank1Start
   .word Bank1Start
   .word Bank1Start

;============================================================================
; R O M - C O D E (BANK2)
;============================================================================

   SEG Bank2
   .org BANK2_BASE
   .rorg BANK2_REORG
   
FREE_BYTES SET 0

SetObjectHorizValue SUBROUTINE
   ldy asteroidHorizPos,x           ; get object's horizontal position
   stx tmpObjectIndex               ; save object index
   tax                              ; shift number of pixels to x register
   bcs .objectTravelingLeft
.objectTravelingRight
   lda RightHorizPosTable,y         ; get right movement value from table
   tay                              ; movement value doubles as table index
   dex                              ; decrement number of pixels to move
   bne .objectTravelingRight
   beq .doneMovingObjectHoriz       ; unconditional branch

.objectTravelingLeft
   lda LeftHorizPosTable,y          ; get left movement value from table
   tay                              ; movement value doubles as table index
   dex                              ; decrement number of pixels to move
   bne .objectTravelingLeft
.doneMovingObjectHoriz
   ldx tmpObjectIndex               ; restore object index value
   sta asteroidHorizPos,x           ; set object's new horizontal position value
   ldy #>DoneDetermineObjectHorizValue
   sty jumpVector + 1
   ldy #<DoneDetermineObjectHorizValue
   sty jumpVector
   jmp BANK2_SwitchToBank1

   FILL_BOUNDARY 256, 0

RightHorizPosTable
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

LeftHorizPosTable
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

ContinueStartupInBank2
   lda #NO_REFLECT
   sta VDELP0                       ; turn off vertical delay on GRP0
   sta VDELP1                       ; turn off vertical delay on GRP1
   sta NUSIZ0
   sta NUSIZ1
   lda #<StartGameWithoutCollisionsSet
   sta jumpVector
   lda #>StartGameWithoutCollisionsSet
   sta jumpVector + 1
   jmp BANK2_SwitchToBank1

Bank2Start
   lda #<Bank1Start
   sta jumpVector
   lda #>Bank1Start
   sta jumpVector + 1
   jmp BANK2_SwitchToBank1

PlayGameSounds
   lda playerState                  ; get current player state
   ror                              ; shift GAME_OVER flag to carry
   bcc .playGameSounds              ; branch if game not over
   lda #0                           ; turn off sounds for game over state
   sta AUDV0
   sta AUDV1
   jmp JumpToVerticalSync

.playGameSounds
   lda soundEngineValues            ; get sound engine values
   sta tmpSoundEngineValues         ; save value temporarily
   ldy #EXPLOSION_SOUND_CHANNEL
   ror tmpSoundEngineValues         ; shift SOUND_BITS_PLAYER_EXPLODE to carry
   bcc .checkForPlayingThrustSounds
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
   bcc .checkToPlayUFOSound
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
   bne .playUFOSounds
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
   jmp JumpToVerticalSync

.playPlayerShotSound
   ldy #PLAYER_SHOT_SOUND_CHANNEL
   lda playerShotSoundTimer         ; get player shot sound timer
   cmp #8
   bcc .determinePlayerShotSoundFrequency
   lda frameCount                   ; get current frame count
   ror                              ; shift D0 to carry
   bcc .determinePlayerShotSoundFrequency
   ldy #EXPLOSION_SOUND_CHANNEL
.determinePlayerShotSoundFrequency
   lda #15
   sec
   sbc playerShotSoundTimer         ; subtract player shot sound timer
   sec
   sbc #5
   tax
   lda #PLAYER_SHOT_SOUND_VOLUME
.setRightAudioChannelValues
   sty AUDC1
   stx AUDF1
   sta AUDV1
   bpl JumpToVerticalSync           ; unconditional branch

.checkToPlayHeartbeatSound
   ldy #HEARTBEAT_SOUND_CHANNEL
   dec heartbeatSoundTimer          ; decrement heartbeat sound timer
   bne .playHeartbeatSound
   lda soundEngineValues            ; get sound engine values
   and #<~SOUND_BITS_HEARTBEAT_MASK ; clear heartbeat sound values
   ror tmpSoundEngineValues         ; shift SOUND_HEARTBEAT value to carry
   bcs .playHeartbeatToInitTempo
   ora #SOUND_HEARTBEAT_ON
   ror tmpSoundEngineValues         ; shift SOUND_HEARTBEAT_FREQ to carry
   bcc .incrementHeartbeatTempo
   ora #SOUND_HEARTBEAT_HIGH_FREQ
.incrementHeartbeatTempo
   sta soundEngineValues
   lda frameCount + 1
   bmi .resetHeartbeatSoundTimer
   lda #14
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

JumpToVerticalSync
   lda #<VerticalSync
   sta jumpVector
   lda #>VerticalSync
   sta jumpVector + 1
   jmp BANK2_SwitchToBank1

   FILL_BOUNDARY 3024, 0

BANK2_SwitchToBank3
   sta BANK3STROBE
   jmp (jumpVector)

BANK2_SwitchToBank2
   sta BANK2STROBE
   jmp (jumpVector)

BANK2_SwitchToBank1
   sta BANK1STROBE
   jmp (jumpVector)

BANK2_SwitchToBank0
   sta BANK0STROBE
   jmp (jumpVector)

   FILL_BOUNDARY 246, 0

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data
   
   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK2 FREE"

   .word Bank2Start
   .word Bank2Start
   .word Bank2Start

;============================================================================
; R O M - C O D E (BANK3)
;============================================================================

   SEG Bank3
   .org BANK3_BASE
   .rorg BANK3_REORG
   
FREE_BYTES SET 0

Bank3Start
   lda #<Bank1Start
   sta jumpVector
   lda #>Bank1Start
   sta jumpVector + 1
   jmp BANK3_SwitchToBank1

   FILL_BOUNDARY 4048, 0
   
BANK3_SwitchToBank3
   sta BANK3STROBE
   jmp (jumpVector)

BANK3_SwitchToBank2
   sta BANK2STROBE
   jmp (jumpVector)

BANK3_SwitchToBank1
   sta BANK1STROBE
   jmp (jumpVector)

BANK3_SwitchToBank0
   sta BANK0STROBE
   jmp (jumpVector)

   FILL_BOUNDARY 246, 0

   .byte 0, 0, 0, 0                 ; hotspot locations not available for data
   
   FILL_BOUNDARY 250, 0

   echo "***", (FREE_BYTES)d, "BYTES OF BANK3 FREE"

   .word Bank3Start
   .word Bank3Start
   .word Bank3Start