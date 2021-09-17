   LIST OFF
; ***  S U P E R M A N  ***
; Copyright 1979 Atari, Inc.
; Designer: John Dunn

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: January 18, 2018
;
;  *** 107 BYTES OF RAM USED 20 BYTES FREE
;  ***   2 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1979, ATARI, INC.                                  =
; =                                                                            =
; ==============================================================================
;
; - Game clock not adjusted for PAL50
; - 6 bytes of RAM are unused in the production release...wonder if they were
;   for features that were removed before production

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this
                                    ; assembles to the exact ROM image

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

TRUE                    = 1
FALSE                   = 0

   IFNCONST COMPILE_REGION

COMPILE_REGION          = NTSC      ; change to compile for different regions

   ENDIF

   IF !(COMPILE_REGION = NTSC || COMPILE_REGION = PAL50)

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0, PAL50 = 1"
      echo ""
      err

   ENDIF
   
;===============================================================================
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC
   
VBLANK_TIME             = 55
OVERSCAN_TIME           = 2
STATUS_KERNEL_TIME      = 25

H_KERNEL                = 104

MIN_Y                   = 20
MAX_Y                   = 106

PLAYER_INIT_VERT_POS    = MAX_Y - 10
HELICOPTER_INIT_VERT_POS = MAX_Y - 18
BRIDGE_PIECE_INIT_VERT_POS = MIN_Y + 12

SUPERMAN_WALKING_VERT_MAX = 44

BRIDGE_COMPLETE_Y       = 48

JAIL_Y                  = 63
DAILYPLANET_Y           = 73
PHONEBOOTH_Y            = 40

PLAYER_LOWER_VERT_LIMIT = (MAX_Y / 2) - 1

FLIGHT_SOUND_RANGE_01   = H_KERNEL - 8
FLIGHT_SOUND_RANGE_02   = H_KERNEL - 24
FLIGHT_SOUND_RANGE_03   = H_KERNEL - 40
FLIGHT_SOUND_RANGE_04   = H_KERNEL - 56
FLIGHT_SOUND_RANGE_05   = H_KERNEL - 70
      
   ELSE
   
VBLANK_TIME             = 56
OVERSCAN_TIME           = 16
STATUS_KERNEL_TIME      = 24

H_KERNEL                = 120

MIN_Y                   = 26
MAX_Y                   = 122

PLAYER_INIT_VERT_POS    = MAX_Y - 26
HELICOPTER_INIT_VERT_POS = MAX_Y - 34
BRIDGE_PIECE_INIT_VERT_POS = MIN_Y + 22

SUPERMAN_WALKING_VERT_MAX = 64

BRIDGE_COMPLETE_Y       = 62

JAIL_Y                  = 79
DAILYPLANET_Y           = 89
PHONEBOOTH_Y            = 52

PLAYER_LOWER_VERT_LIMIT = (MAX_Y / 2) + 3

FLIGHT_SOUND_RANGE_01   = H_KERNEL - 8
FLIGHT_SOUND_RANGE_02   = H_KERNEL - 24
FLIGHT_SOUND_RANGE_03   = H_KERNEL - 40
FLIGHT_SOUND_RANGE_04   = H_KERNEL - 56
FLIGHT_SOUND_RANGE_05   = H_KERNEL - 83

   ENDIF

;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
ORANGE                  = $30
ORANGE2                 = ORANGE
RED                     = $40
LIGHT_PURPLE            = $50
PURPLE                  = $60
LIGHT_BLUE              = $80
LIGHT_BLUE2             = LIGHT_BLUE
BLUE                    = $90
CYAN                    = $A0
LIGHT_GREEN             = $B0
LIGHT_GREEN2            = LIGHT_GREEN
GREEN                   = $C0
LIGHT_BROWN             = $E0

COLOR_GANGSTER_1_PANTS  = GREEN + 8
COLOR_GANGSTER_2_PANTS  = LIGHT_BLUE + 6
COLOR_LEX_LUTHER_PANTS  = GREEN + 8
COLOR_SUPERMAN_COSTUME  = LIGHT_BLUE + 6
COLOR_CLARK_KENT_SUIT   = LIGHT_BLUE + 8
COLOR_PHONE_BOOTH       = LIGHT_BLUE + 6
COLOR_DAILY_PLANET_BLUE = COLOR_PHONE_BOOTH
COLOR_BLUE_SUBWAY_WINDOWS = LIGHT_BLUE + 10
COLOR_GREEN_SUBWAY_WINDOWS = GREEN + 10

   ELSE

YELLOW                  = $20
OLIVE_GREEN             = $30
ORANGE                  = $40
ORANGE2                 = $60
RED                     = $60
LIGHT_BROWN             = $70
LIGHT_PURPLE            = $80
LIGHT_GREEN             = $90
CYAN                    = $90
GREEN                   = $90
LIGHT_GREEN2            = $A0
PURPLE                  = $A0
BLUE                    = $B0
LIGHT_BLUE2             = BLUE
LIGHT_BLUE              = $D0

COLOR_GANGSTER_1_PANTS  = OLIVE_GREEN + 8
COLOR_GANGSTER_2_PANTS  = BLUE + 6
COLOR_LEX_LUTHER_PANTS  = OLIVE_GREEN + 8
COLOR_SUPERMAN_COSTUME  = BLUE + 6
COLOR_CLARK_KENT_SUIT   = BLUE + 8
COLOR_PHONE_BOOTH       = BLUE + 6
COLOR_DAILY_PLANET_BLUE = COLOR_PHONE_BOOTH
COLOR_BLUE_SUBWAY_WINDOWS = BLUE + 10
COLOR_GREEN_SUBWAY_WINDOWS = LIGHT_BROWN + 8

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

MY_MOVE_RIGHT           = MOVE_RIGHT >> 4
MY_MOVE_LEFT            = MOVE_LEFT >> 4
MY_MOVE_DOWN            = MOVE_DOWN >> 4
MY_MOVE_UP              = MOVE_UP >> 4
MY_NO_MOVE              = NO_MOVE >> 4

;-------------------------------------------------------------------------------
; frame constants
;
MIN_X                   = 3
MAX_X                   = 240

SUBWAY_X                = 56
SUBWAY_Y                = SUBWAY_X

BRIDGE_COMPLETE_X       = 72
DAILYPLANET_X           = 77
JAIL_X                  = 77
PHONEBOOTH_X            = 48
PLAYER_INIT_HORIZ_POS   = 48

FRAMES_PER_SECOND       = 58        ; not adjusted for PAL50 build

H_FONT                  = 5

NUM_BADGUYS             = 6         ; Lex Luther + 5 Gangsters
NUM_KRYPTONITE_OBJECTS  = 3
NUM_SUBWAY_ENTRANCES    = 4

NORTH_ROOM_OFFSET       = 4
EAST_ROOM_OFFSET        = 5
SOUTH_ROOM_OFFSET       = 6
WEST_ROOM_OFFSET        = 7

LEX_LUTHER_SPAWN_TIME   = 40
GANGSTER1_SPAWN_TIME    = 56
GANGSTER2_SPAWN_TIME    = 88
GANGSTER3_SPAWN_TIME    = 120
GANGSTER4_SPAWN_TIME    = 152
HELICOPTER_SPAWN_TIME   = 188
GANGSTER5_SPAWN_TIME    = 254

SUPERMAN_MOVE_RATE      = 4
CLARK_KENT_MOVE_RATE    = SUPERMAN_MOVE_RATE / 2
KRYPTONITE_MOVE_RATE    = 4
BAD_GUY_MOVE_RATE       = 4         ; for Gangster1 - 4
LOIS_LANE_MOVE_RATE     = 2
LEX_LUTHER_MOVE_RATE    = 2
GANGSTER5_MOVE_RATE     = 2
HELICOPTER_MOVE_RATE    = 2

; playerState flags
WALKING                 = %10000000
CLARK_KENT              = %01000000
HIT_KRYPTONITE          = %00100000

GANGSTER1_IND_VALUE     = %10000000 ; used for PF1 display
GANGSTER2_IND_VALUE     = %00100000 ; used for PF1 display
GANGSTER3_IND_VALUE     = %00001000 ; used for PF1 display
GANGSTER4_IND_VALUE     = %00000010 ; used for PF1 display
GANGSTER5_IND_VALUE     = %00000001 ; used for PF2 display
LEX_LUTHER_IND_VALUE    = %00001100 ; used for PF2 display

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

roomGraphicPtrs         ds 2
characterGraphicPtrs    ds 2
characterColorPtrs      ds 2
playerColorPtrs         ds 2        ; pointer for Superman colors
objectHorizPos          ds 1
objectVertPos           ds 1
dataStructurePtr        ds 2
;--------------------------------------
tmpTimerGraphics        = dataStructurePtr
;--------------------------------------
tmpCarriedObjectHorizOffset = tmpTimerGraphics
currentScanline         = tmpCarriedObjectHorizOffset + 1
playfieldGraphicsOffset ds 1
objectGraphicsOffset    ds 1
playerGraphicsOffset    ds 1
objectLocationPtr       ds 2
currentObjectId         ds 1        ; id of object shown of screen
characterDataPts        ds 2
playerDirection         ds 1
random                  ds 1
tempDirections          ds 1
carriedObjectId         ds 1        ; id of object being carried by Superman
zp_Unused_01            ds 2
tempPlayerCurrentRoom   ds 1
playerLocation          ds 3
;--------------------------------------
playerCurrentRoom       = playerLocation
playerHorizPos          = playerCurrentRoom + 1
playerVertPos           = playerHorizPos + 1
objectSpawningTimer     ds 1
playerState             ds 1
playerGraphicsPtrs      ds 2        ; pointer for Clark Kent/Superman
zp_Unused_02            ds 1
objectLocations         ds 17 * 3
;--------------------------------------
lexLutherLocation          = objectLocations
;--------------------------------------
lexLutherScreen            = lexLutherLocation
lexLutherHorizPos          = lexLutherScreen + 1
lexLutherVertPos           = lexLutherHorizPos + 1
gangsterLocations          = objectLocations + 3
;--------------------------------------
gangster1Location          = gangsterLocations
;--------------------------------------
gangster1Screen            = gangster1Location
gangster1HorizPos          = gangster1Screen + 1
gangster1VertPos           = gangster1HorizPos + 1
;--------------------------------------
gangster2Location          = gangster1Location + 3
;--------------------------------------
gangster2Screen            = gangster2Location
gangster2HorizPos          = gangster2Screen + 1
gangster2VertPos           = gangster2HorizPos + 1
;--------------------------------------
gangster3Location          = gangster2Location + 3
;--------------------------------------
gangster3Screen            = gangster3Location
gangster3HorizPos          = gangster3Screen + 1
gangster3VertPos           = gangster3HorizPos + 1
;--------------------------------------
gangster4Location          = gangster3Location + 3
;--------------------------------------
gangster4Screen            = gangster4Location
gangster4HorizPos          = gangster4Screen + 1
gangster4VertPos           = gangster4HorizPos + 1
;--------------------------------------
gangster5Location          = gangster4Location + 3
;--------------------------------------
gangster5Screen            = gangster5Location
gangster5HorizPos          = gangster5Screen + 1
gangster5VertPos           = gangster5HorizPos + 1
;--------------------------------------
kryptoniteLocations        = gangster5Location + 3
;--------------------------------------
kryptonite1Location        = kryptoniteLocations
;--------------------------------------
kryptonite1Screen          = kryptonite1Location
kryptonite1HorizPos        = kryptonite1Screen + 1
kryptonite1VertPos         = kryptonite1HorizPos + 1
;--------------------------------------
kryptonite2Location        = kryptonite1Location + 3
;--------------------------------------
kryptonite2Screen          = kryptonite2Location
kryptonite2HorizPos        = kryptonite2Screen + 1
kryptonite2VertPos         = kryptonite2HorizPos + 1
;--------------------------------------
kryptonite3Location        = kryptonite2Location + 3
;--------------------------------------
kryptonite3Screen          = kryptonite3Location
kryptonite3HorizPos        = kryptonite3Screen + 1
kryptonite3VertPos         = kryptonite3HorizPos + 1
;--------------------------------------
loisLaneLocation           = kryptonite3Location + 3
;--------------------------------------
loisLaneScreen             = loisLaneLocation
loisLaneHorizPos           = loisLaneScreen + 1
loisLaneVertPos            = loisLaneHorizPos + 1
;--------------------------------------
subwayLocation             = loisLaneLocation + 3
;--------------------------------------
subwayScreen               = subwayLocation
subwayHorizPos             = subwayScreen + 1
subwayVertPos              = subwayHorizPos + 1
;--------------------------------------
nullCharacterLocation      = subwayLocation + 3
;--------------------------------------
nullCharacterScreen        = nullCharacterLocation
nullCharacterHorizPos      = nullCharacterScreen + 1
nullCharacterVertPos       = nullCharacterHorizPos + 1
;--------------------------------------
bridgeCompleteLocation     = nullCharacterLocation + 3
;--------------------------------------
bridgeCompleteScreen       = bridgeCompleteLocation
bridgeCompleteHorizPos     = bridgeCompleteScreen + 1
bridgeCompleteVertPos      = bridgeCompleteHorizPos + 1
;--------------------------------------
bridgePiece0Location       = bridgeCompleteLocation + 3
;--------------------------------------
bridgePiece0Screen         = bridgePiece0Location
bridgePiece0HorizPos       = bridgePiece0Screen + 1
bridgePiece0VertPos        = bridgePiece0HorizPos + 1
;--------------------------------------
bridgePiece1Location       = bridgePiece0Location + 3
;--------------------------------------
bridgePiece1Screen         = bridgePiece1Location
bridgePiece1HorizPos       = bridgePiece1Screen + 1
bridgePiece1VertPos        = bridgePiece1HorizPos + 1
;--------------------------------------
bridgePiece2Location       = bridgePiece1Location + 3
;--------------------------------------
bridgePiece2Screen         = bridgePiece2Location
bridgePiece2HorizPos       = bridgePiece2Screen + 1
bridgePiece2VertPos        = bridgePiece2HorizPos + 1
;--------------------------------------
helicopterLocation         = bridgePiece2Location + 3
;--------------------------------------
helicopterScreen           = helicopterLocation
helicopterHorizPos         = helicopterScreen + 1
helicopterVertPos          = helicopterHorizPos + 1
helicopterPickUpItemTimer  ds 1
helicopterPickUpRAMPtr     ds 1
objectMatrixPtrs           ds 2
objectMoveRate             ds 1
tempObjectLocationPtr      ds 1
matrixTableEndPoint        ds 1
zp_Unused_03               ds 1
frameCount                 ds 1
zp_Unused_04               ds 1
soundDelayTimer            ds 1
zp_Unused_05               ds 1
gameTimer                  ds 2
;--------------------------------------
gameTimerSeconds           = gameTimer
gameTimerMinutes           = gameTimerSeconds + 1
gameTimerOffsets           ds 4
;--------------------------------------
lsbGameTimerOffsets        = gameTimerOffsets
minutesLSBOffset           = lsbGameTimerOffsets
secondsLSBOffset           = minutesLSBOffset + 1
;--------------------------------------
msbGameTimerOffsets        = lsbGameTimerOffsets + 2
minutesMSBOffset           = msbGameTimerOffsets
secondsMSBOffset           = minutesMSBOffset + 1
;--------------------------------------
playfieldGraphics          = gameTimerOffsets
;--------------------------------------
pf0Graphics                = playfieldGraphics
pf1Graphics                = pf0Graphics + 1
pf2Graphics                = pf1Graphics + 1
pf1EnemyIndicators         ds 1     ; used in kernel
pf2EnemyIndicators         ds 1     ; used in kernel
backgroundColor            ds 1
skyColor                   ds 1
pf1GangsterIndicators      ds 1
pf2GangsterIndicators      ds 1
consoleSwitchValue         ds 1
gameState                  ds 1
soundPriority              ds 1

   echo "***",(*-$80 - 6)d, "BYTES OF RAM USED", ($100 - * + 5)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

RoomListDataStructure
NullRoomDS
   .word SubwayGraphics
   .byte ORANGE + 6
   .byte BLACK + 8
   .byte <NullRoomDS
   .byte <NullRoomDS
   .byte <NullRoomDS
   .byte <NullRoomDS

InsideDailyPlanetDS
   .word SubwayGraphics
   .byte WHITE - 2
   .byte BLUE + 10
   .byte <GreenSubwayDS             ; pointer to north room
   .byte <BlueSubwayDS              ; pointer to east room
   .byte <YellowSubwayDS            ; pointer to south room
   .byte <PinkSubwayDS              ; pointer to west room

PhoneBoothRoomDS
   .word PhoneBoothRoom
   .byte LIGHT_BLUE + 12
   .byte BLACK + 10
   .byte <CenterWindowDS            ; pointer to north room
   .byte <BridgeRoomDS              ; pointer to east room
   .byte <BillboardRoomDS           ; pointer to south room
   .byte <TwinTowersDS              ; pointer to west room

BridgeRoomDS
   .word BridgeRoom
   .byte LIGHT_BLUE2 + 10
   .byte BLACK + 10
   .byte <BillboardRoomDS           ; pointer to north room
   .byte <YellowSubwayEntranceDS    ; pointer to east room
   .byte <CenterWindowDS            ; pointer to south room
   .byte <PhoneBoothRoomDS          ; pointer to west room

YellowSubwayEntranceDS
   .word YellowSubwayEntranceRoom
   .byte WHITE - 2
   .byte LIGHT_GREEN + 10
   .byte <JailDS                    ; pointer to north room
   .byte <SixWindowRoomDS           ; pointer to east room
   .byte <TwinTowersDS              ; pointer to south room
   .byte <BridgeRoomDS              ; pointer to west room

SixWindowRoomDS
   .word SixWindowRoom
   .byte LIGHT_GREEN + 12
   .byte BLACK + 10
   .byte <CastleDS                  ; pointer to north room
   .byte <TownHallDS                ; pointer to east room
   .byte <TripleTowerDS             ; pointer to south room
   .byte <YellowSubwayEntranceDS    ; pointer to west room

TownHallDS
   .word TownHallRoom
   .byte LIGHT_PURPLE + 12
   .byte LIGHT_GREEN + 12
   .byte <MetropolisDS              ; pointer to north room
   .byte <JailDS                    ; pointer to east room
   .byte <TwoWindowRoomDS           ; pointer to south room
   .byte <SixWindowRoomDS           ; pointer to west room

JailDS
   .word JailRoom
   .byte PURPLE + 12
   .byte BLACK + 8
   .byte <TripleTowerDS             ; pointer to north room
   .byte <CastleDS                  ; pointer to east room
   .byte <YellowSubwayEntranceDS    ; pointer to south room
   .byte <TownHallDS                ; pointer to west room

CastleDS
   .word CastleRoom
   .byte RED + 12
   .byte BLACK + 8
   .byte <PinkSubwayEntranceDS      ; pointer to north room
   .byte <MetropolisDS              ; pointer to east room
   .byte <SixWindowRoomDS           ; pointer to south room
   .byte <JailDS                    ; pointer to west room

MetropolisDS
   .word MetropolisRoom
   .byte PURPLE + 12
   .byte BLACK + 8
   .byte <BillboardRoomDS           ; pointer to north room
   .byte <CyclopesRoomDS            ; pointer to east room
   .byte <TownHallDS                ; pointer to south room
   .byte <CastleDS                  ; pointer to west room

CyclopesRoomDS
   .word CyclopesRoom
   .byte CYAN + 12
   .byte WHITE - 2
   .byte <NoWindowRoomDS            ; pointer to north room
   .byte <TripleTowerDS             ; pointer to east room
   .byte <GreenSubwayEntranceDS     ; pointer to south room
   .byte <MetropolisDS              ; pointer to west room

TripleTowerDS
   .word TripleTowerRoom
   .byte LIGHT_GREEN2 + 12
   .byte BLACK + 10
   .byte <SixWindowRoomDS           ; pointer to north room
   .byte <PinkSubwayEntranceDS      ; pointer to east room
   .byte <JailDS                    ; pointer to south room
   .byte <CyclopesRoomDS            ; pointer to west room

PinkSubwayEntranceDS
   .word PinkSubwayEntranceRoom
   .byte LIGHT_BLUE + 12
   .byte BLACK + 10
   .byte <TwoWindowRoomDS           ; pointer to north room
   .byte <BillboardRoomDS           ; pointer to east room
   .byte <CastleDS                  ; pointer to south room
   .byte <TripleTowerDS             ; pointer to west room

BillboardRoomDS
   .word BillboardRoom
   .byte GREEN + 10
   .byte BLACK + 8
   .byte <FourWindowRoomDS          ; pointer to north room
   .byte <NoWindowRoomDS            ; pointer to east room
   .byte <MetropolisDS              ; pointer to south room
   .byte <PinkSubwayEntranceDS      ; pointer to west room

NoWindowRoomDS
   .word NoWindowRoom
   .byte BLACK + 10
   .byte LIGHT_GREEN + 10
   .byte <BlueSubwayEntranceDS      ; pointer to north room
   .byte <DailyPlanetDS             ; pointer to east room
   .byte <CyclopesRoomDS            ; pointer to south room
   .byte <BillboardRoomDS           ; pointer to west room

DailyPlanetDS
   .word DailyPlanetRoom
   .byte GREEN + 12
   .byte BLACK + 10
   .byte <FactoryDS                 ; pointer to north room
   .byte <TwoWindowRoomDS           ; pointer to east room
   .byte <CenterWindowDS            ; pointer to south room
   .byte <NoWindowRoomDS            ; pointer to west room

TwoWindowRoomDS
   .word TwoWindowRoom
   .byte BLUE + 12
   .byte BLACK + 8
   .byte <TownHallDS                ; pointer to north room
   .byte <FourWindowRoomDS          ; pointer to east room
   .byte <PinkSubwayEntranceDS      ; pointer to south room
   .byte <DailyPlanetDS             ; pointer to west room

FourWindowRoomDS
   .word FourWindowRoom
   .byte LIGHT_GREEN + 12
   .byte WHITE - 2
   .byte <GreenSubwayEntranceDS     ; pointer to north room
   .byte <BlueSubwayEntranceDS      ; pointer to east room
   .byte <BillboardRoomDS           ; pointer to south room
   .byte <TwoWindowRoomDS           ; pointer to west room

BlueSubwayEntranceDS
   .word BlueSubwayEntranceRoom
   .byte RED + 12
   .byte BLACK + 10
   .byte <CenterWindowDS            ; pointer to north room
   .byte <FactoryDS                 ; pointer to east room
   .byte <NoWindowRoomDS            ; pointer to south room
   .byte <FourWindowRoomDS          ; pointer to west room

FactoryDS
   .word FactoryRoom
   .byte WHITE - 2
   .byte LIGHT_GREEN + 10
   .byte <TwinTowersDS              ; pointer to north room
   .byte <GreenSubwayEntranceDS     ; pointer to east room
   .byte <DailyPlanetDS             ; pointer to south room
   .byte <BlueSubwayEntranceDS      ; pointer to west room

GreenSubwayEntranceDS
   .word GreenSubwayEntranceRoom
   .byte LIGHT_BROWN + 12
   .byte LIGHT_BLUE + 10
   .byte <CyclopesRoomDS            ; pointer to north room
   .byte <CenterWindowDS            ; pointer to east room
   .byte <FourWindowRoomDS          ; pointer to south room
   .byte <FactoryDS                 ; pointer to west room

CenterWindowDS
   .word CenterWindowRoom
   .byte GREEN + 12
   .byte BLUE + 10
   .byte <DailyPlanetDS             ; pointer to north room
   .byte <TwinTowersDS              ; pointer to east room
   .byte <BlueSubwayEntranceDS      ; pointer to south room
   .byte <GreenSubwayEntranceDS     ; pointer to west room

TwinTowersDS
   .word TwinTowersRoom
   .byte BLUE + 12
   .byte BLACK + 10
   .byte <YellowSubwayEntranceDS    ; pointer to north room
   .byte <PhoneBoothRoomDS          ; pointer to east room
   .byte <FactoryDS                 ; pointer to south room
   .byte <CenterWindowDS            ; pointer to west room

YellowSubwayDS
   .word SubwayGraphics
   .byte BLACK + 6
   .byte YELLOW + 10
   .byte <PinkSubwayDS              ; pointer to north room
   .byte <BillboardRoomDS           ; pointer to east room
   .byte <CyclopesRoomDS            ; pointer to south room
   .byte <DailyPlanetDS             ; pointer to west room

PinkSubwayDS
   .word SubwayGraphics
   .byte BLACK + 6
   .byte RED + 10
   .byte <BlueSubwayDS              ; pointer to north room
   .byte <CenterWindowDS            ; pointer to east room
   .byte <NoWindowRoomDS            ; pointer to south room
   .byte <JailDS                    ; pointer to west room

BlueSubwayDS
   .word SubwayGraphics
   .byte BLACK + 6
   .byte COLOR_BLUE_SUBWAY_WINDOWS
   .byte <GreenSubwayDS             ; pointer to north room
   .byte <TownHallDS                ; pointer to east room
   .byte <TwinTowersDS              ; pointer to south room
   .byte <TripleTowerDS             ; pointer to west room

GreenSubwayDS
   .word SubwayGraphics
   .byte BLACK + 6
   .byte COLOR_GREEN_SUBWAY_WINDOWS
   .byte <YellowSubwayDS            ; pointer to north room
   .byte <FactoryDS                 ; pointer to east room
   .byte <CastleDS                  ; pointer to south room
   .byte <TwoWindowRoomDS           ; pointer to west room

;
; audio frequency and channel values are combined as FFFFCCCC
;
AudioChannel_01_Values
   .byte 2 << 4 | 2                 ; bridge completed
   .byte 15 << 4 | 8                ; exploding bridge
   .byte 9 << 4 | 9                 ; placing bad guy in jail
   .byte 4 << 4 | 3                 ; entering Daily Planet...ending game
   .byte 3 << 4 | 4                 ; hitting Lois Lane values
   .byte 6 << 4 | 15                ; hitting kryptonite values

Subway1Location
   .byte <YellowSubwayEntranceDS
   .byte SUBWAY_X, SUBWAY_Y

Subway2Location
   .byte <PinkSubwayEntranceDS
   .byte SUBWAY_X, SUBWAY_Y

Subway3Location
   .byte <BlueSubwayEntranceDS
   .byte SUBWAY_X, SUBWAY_Y

Subway4Location
   .byte <GreenSubwayEntranceDS
   .byte SUBWAY_X, SUBWAY_Y

JailLocation
   .byte <JailDS
   .byte JAIL_X, JAIL_Y

DailyPlanetLocation
   .byte <DailyPlanetDS
   .byte DAILYPLANET_X, DAILYPLANET_Y

PhoneBoothLocation
   .byte <PhoneBoothRoomDS
   .byte PHONEBOOTH_X, PHONEBOOTH_Y

HelicopterMatrix
   .byte <helicopterScreen, <loisLaneScreen
   .byte <helicopterScreen, <nullCharacterScreen
   .byte <helicopterScreen, <kryptonite1Screen
   .byte <helicopterScreen, <bridgePiece0Screen
   .byte <helicopterScreen, <bridgePiece1Screen
   .byte <helicopterScreen, <bridgePiece2Screen
   .byte 0

ObjectListDataStructure
LexLutherDS
   .word LexLutherSprites
   .word LexLutherColors
   .word lexLutherLocation

Gangster1DS
   .word GangsterSprites
   .word Gangster1Colors
   .word gangster1Location

Gangster2DS
   .word GangsterSprites
   .word Gangster2Colors
   .word gangster2Location

Gangster3DS
   .word GangsterSprites
   .word Gangster3Colors
   .word gangster3Location

Gangster4DS
   .word GangsterSprites
   .word Gangster4Colors
   .word gangster4Location

Gangster5DS
   .word GangsterSprites
   .word Gangster5Colors
   .word gangster5Location

LoisLaneDS
   .word LoisLaneSprites
   .word LoisLaneColors
   .word loisLaneLocation

BridgePiece0DS
   .word BridgePiece_0
   .word JailColors
   .word bridgePiece0Location

BridgePiece1DS
   .word BridgePiece_1
   .word JailColors
   .word bridgePiece1Location

BridgePiece2DS
   .word BridgePiece_2
   .word JailColors
   .word bridgePiece2Location

HelicopterDS
   .word HelicopterSprites
   .word HelicopterColors
   .word helicopterLocation

Kryptonite1DS
   .word KryptoniteSprites
   .word JailColors
   .word kryptonite1Location

Kryptonite2DS
   .word KryptoniteSprites
   .word Kryptonite2Colors
   .word kryptonite2Location

Kryptonite3DS
   .word KryptoniteSprites
   .word ClarkKentColors + 5
   .word kryptonite3Location

DailyPlanetSpriteDS
   .word DailyPlanet
   .word DailyPlanetColors
   .word DailyPlanetLocation

PhoneBoothSpriteDS
   .word PhoneBooth
   .word PhoneBoothColors
   .word PhoneBoothLocation

JailSpriteDS
   .word Jail
   .word JailColors
   .word JailLocation

Subway1DS
   .word SubwayEntrance
   .word JailColors
   .word Subway1Location

Subway2DS
   .word SubwayEntrance
   .word JailColors
   .word Subway2Location

Subway3DS
   .word SubwayEntrance
   .word JailColors
   .word Subway3Location

Subway4DS
   .word SubwayEntrance
   .word JailColors
   .word Subway4Location

BridgeCompleteDS
   .word BridgeComplete
   .word JailColors
   .word bridgeCompleteLocation

NullCharacterDS
   .word NullCharacter
   .word 0
   .word nullCharacterLocation

HelicopterColors
   .byte BLACK + 4, BLACK + 4, BLACK + 4, BLACK + 4, BLACK + 4, YELLOW + 8
   .byte YELLOW + 8, YELLOW + 8, ORANGE + 6, ORANGE + 6, BLACK + 4

Gangster1Colors
   .byte YELLOW + 6, YELLOW + 6, RED + 8, RED + 8, RED + 8
   .byte COLOR_GANGSTER_1_PANTS, BLACK + 4, BLACK + 4, COLOR_GANGSTER_1_PANTS
   .byte COLOR_GANGSTER_1_PANTS, COLOR_GANGSTER_1_PANTS, COLOR_GANGSTER_1_PANTS
   .byte COLOR_GANGSTER_1_PANTS

Gangster2Colors
   .byte YELLOW + 6, YELLOW + 6, RED + 8, RED + 8, RED + 8
   .byte COLOR_GANGSTER_2_PANTS, BLACK + 4, BLACK + 4, COLOR_GANGSTER_2_PANTS
   .byte COLOR_GANGSTER_2_PANTS, COLOR_GANGSTER_2_PANTS, COLOR_GANGSTER_2_PANTS
   .byte COLOR_GANGSTER_2_PANTS

Gangster3Colors
   .byte YELLOW + 6, YELLOW + 6, RED + 8, RED + 8, RED + 8, ORANGE + 6
   .byte BLACK + 4, BLACK + 4, ORANGE + 6, ORANGE + 6, ORANGE + 6
Kryptonite2Colors
   .byte ORANGE + 6, ORANGE + 6

Gangster4Colors
   .byte YELLOW + 6, YELLOW + 6, ORANGE + 6, ORANGE + 6, ORANGE + 6, YELLOW + 8
   .byte BLACK + 4, BLACK + 4, YELLOW + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8
   .byte YELLOW + 8

Gangster5Colors
   .byte YELLOW + 6, YELLOW + 6, RED + 8, RED + 8, RED + 8, PURPLE + 6, BLACK + 4
   .byte BLACK + 4, PURPLE + 6, PURPLE + 6, PURPLE + 6, PURPLE + 6, PURPLE + 6
   .byte YELLOW + 6

LexLutherColors
   .byte BLACK + 4, BLACK + 4, RED + 8, RED + 8, RED + 8, RED + 8, RED + 8
   .byte YELLOW + 8, YELLOW + 8, YELLOW + 8, YELLOW + 8, COLOR_LEX_LUTHER_PANTS
   .byte COLOR_LEX_LUTHER_PANTS, COLOR_LEX_LUTHER_PANTS, COLOR_LEX_LUTHER_PANTS
   .byte BLACK + 4

KryptoniteMatrixes
Kryptonite1Matrix
   .byte <kryptonite2Screen, <kryptonite1Screen
   .byte <loisLaneScreen, <kryptonite1Screen
   .byte <kryptonite1Screen, <playerCurrentRoom
   .byte <kryptonite1Screen, <subwayScreen
   .byte 0

Kryptonite2Matrix
   .byte <kryptonite3Screen, <kryptonite2Screen
   .byte <loisLaneScreen, <kryptonite2Screen
   .byte <kryptonite2Screen, <playerCurrentRoom
   .byte <kryptonite2Screen, <subwayScreen
   .byte 0

Kryptonite3Matrix
   .byte <kryptonite1Screen, <kryptonite3Screen
   .byte <kryptonite3Screen, <playerCurrentRoom
   .byte <kryptonite3Screen, <subwayScreen
   .byte 0, 0

PhoneBoothRoom
   .byte $48 ; |.X..X...|
   .byte $01 ; |.......X|
   .byte $B0 ; |X.XX....|
   .byte $4C ; |.X..XX..|
   .byte $24 ; |..X..X..|
   .byte $30 ; |..XX....|
   .byte $1F ; |...XXXXX|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|

BridgeRoom
   .byte $E2 ; |XXX...X.|
   .byte $00 ; |........|
   .byte $B0 ; |X.XX....|
   .byte $F8 ; |XXXXX...|
   .byte $65 ; |.XX..X.X|
   .byte $30 ; |..XX....|
   .byte $FF ; |XXXXXXXX|
   .byte $F1 ; |XXXX...X|
   .byte $F0 ; |XXXX....|

YellowSubwayEntranceRoom
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $E5 ; |XXX..X.X|
   .byte $2A ; |..X.X.X.|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $80 ; |X.......|
   .byte $F0 ; |XXXX....|

SixWindowRoom
   .byte $14 ; |...X.X..|
   .byte $41 ; |.X.....X|
   .byte $30 ; |..XX....|
   .byte $51 ; |.X.X...X|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
   .byte $1F ; |...XXXXX|
   .byte $F3 ; |XXXX..XX|
   .byte $F0 ; |XXXX....|

TownHallRoom
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $49 ; |.X..X..X|
   .byte $E4 ; |XXX..X..|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|

CenterWindowRoom
JailRoom
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $13 ; |...X..XX|
   .byte $11 ; |...X...X|
   .byte $30 ; |..XX....|
   .byte $07 ; |.....XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|

CastleRoom
   .byte $F1 ; |XXXX...X|
   .byte $C4 ; |XX...X..|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $04 ; |.....X..|
   .byte $F0 ; |XXXX....|

MetropolisRoom
   .byte $0A ; |....X.X.|
   .byte $54 ; |.X.X.X..|
   .byte $20 ; |..X.....|
   .byte $A3 ; |X.X...XX|
   .byte $C1 ; |XX.....X|
   .byte $90 ; |X..X....|
   .byte $83 ; |X.....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|

FactoryRoom
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $40 ; |.X......|
   .byte $82 ; |X.....X.|
   .byte $79 ; |.XXXX..X|
   .byte $20 ; |..X.....|
   .byte $CE ; |XX..XXX.|
   .byte $FC ; |XXXXXX..|
   .byte $80 ; |X.......|

TripleTowerRoom
   .byte $10 ; |...X....|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $91 ; |X..X...X|
   .byte $8A ; |X...X.X.|
   .byte $C0 ; |XX......|
   .byte $18 ; |...XX...|
   .byte $C0 ; |XX......|
   .byte $F0 ; |XXXX....|

PinkSubwayEntranceRoom
   .byte $80 ; |X.......|
   .byte $20 ; |..X.....|
   .byte $B0 ; |X.XX....|
   .byte $D5 ; |XX.X.X.X|
   .byte $2A ; |..X.X.X.|
   .byte $B0 ; |X.XX....|
   .byte $C1 ; |XX.....X|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|

BillboardRoom
   .byte $03 ; |......XX|
   .byte $F7 ; |XXXX.XXX|
   .byte $70 ; |.XXX....|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $30 ; |..XX....|
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $F0 ; |XXXX....|

NoWindowRoom
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $81 ; |X......X|
   .byte $09 ; |....X..X|
   .byte $70 ; |.XXX....|
   .byte $E3 ; |XXX...XX|
   .byte $0F ; |....XXXX|
   .byte $70 ; |.XXX....|

DailyPlanetRoom
CyclopesRoom
   .byte $0C ; |....XX..|
   .byte $84 ; |X....X..|
   .byte $70 ; |.XXX....|
   .byte $CF ; |XX..XXXX|
   .byte $28 ; |..X.X...|
   .byte $70 ; |.XXX....|
   .byte $1F ; |...XXXXX|
   .byte $E1 ; |XXX....X|
   .byte $F0 ; |XXXX....|

TwoWindowRoom
   .byte $91 ; |X..X...X|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $F3 ; |XXXX..XX|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $0F ; |....XXXX|
   .byte $70 ; |.XXX....|

FourWindowRoom
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $5A ; |.X.XX.X.|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $18 ; |...XX...|
   .byte $07 ; |.....XXX|
   .byte $F0 ; |XXXX....|

BlueSubwayEntranceRoom
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|

TwinTowersRoom
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
   .byte $70 ; |.XXX....|
   .byte $E1 ; |XXX....X|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $F0 ; |XXXX....|

GreenSubwayEntranceRoom
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $70 ; |.XXX....|
   .byte $D0 ; |XX.X....|
   .byte $20 ; |..X.....|
   .byte $70 ; |.XXX....|
   .byte $C0 ; |XX......|
   .byte $81 ; |X......X|
   .byte $F0 ; |XXXX....|

SubwayGraphics
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $80 ; |X.......|
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

HeroColors
SupermanFlyingColors
   .byte RED + 8, RED + 8, RED + 8, ORANGE + 6, COLOR_SUPERMAN_COSTUME
   .byte COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME
   .byte ORANGE + 6, ORANGE + 6
SupermanWalkingColors
   .byte RED + 8, RED + 8, RED + 8, RED + 8, ORANGE + 6, ORANGE + 6
   .byte COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME
   .byte COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME, COLOR_SUPERMAN_COSTUME
   .byte ORANGE + 6, ORANGE + 6, ORANGE + 6
ClarkKentColors
   .byte YELLOW + 6, YELLOW + 6, RED + 8, RED + 8, RED + 8
   .byte COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT
   .byte COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT
   .byte COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT, COLOR_CLARK_KENT_SUIT
   .byte YELLOW + 6

LoisLaneColors
   .byte LIGHT_GREEN + 8,LIGHT_GREEN + 8,RED + 8,RED + 8,RED + 8,LIGHT_GREEN + 8
   .byte LIGHT_GREEN + 8,LIGHT_GREEN + 8,LIGHT_GREEN + 8,LIGHT_GREEN + 8
   .byte RED + 8,RED + 8,RED + 8,RED + 8

PhoneBoothColors
   .byte COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH
   .byte COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH
   .byte COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH, COLOR_PHONE_BOOTH

DailyPlanetColors
   .byte COLOR_DAILY_PLANET_BLUE, COLOR_DAILY_PLANET_BLUE
   .byte COLOR_DAILY_PLANET_BLUE, COLOR_DAILY_PLANET_BLUE
   .byte COLOR_DAILY_PLANET_BLUE, COLOR_DAILY_PLANET_BLUE
   .byte COLOR_DAILY_PLANET_BLUE, COLOR_DAILY_PLANET_BLUE
   .byte GREEN + 12, WHITE - 4, WHITE - 4, WHITE - 4

JailColors
   .byte YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6
   .byte YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6
   .byte YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6, YELLOW + 6

NumberFonts
zero
   .byte $7A ; |.XXXX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
one
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
two
   .byte $72 ; |.XXX..X.|
   .byte $4E ; |.X..XXX.|
   .byte $78 ; |.XXXX...|
   .byte $1E ; |...XXXX.|
   .byte $7E ; |.XXXXXX.|
three
   .byte $72 ; |.XXX..X.|
   .byte $46 ; |.X...XX.|
   .byte $62 ; |.XX...X.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
four
   .byte $5A ; |.X.XX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $42 ; |.X....X.|
   .byte $4A ; |.X..X.X.|
five
   .byte $78 ; |.XXXX...|
   .byte $1E ; |...XXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
six
   .byte $78 ; |.XXXX...|
   .byte $1E ; |...XXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
seven
   .byte $72 ; |.XXX..X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $4E ; |.X..XXX.|
eight
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
nine
   .byte $7A ; |.XXXX.X.|
   .byte $5E ; |.X.XXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|

HelicopterSprites
Helicopter_0
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $21 ; |..X....X|
   .byte $62 ; |.XX...X.|
   .byte $A6 ; |X.X..XX.|
   .byte $72 ; |.XXX..X.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|
Helicopter_1
   .byte $80 ; |X.......|
   .byte $40 ; |.X......|
   .byte $24 ; |..X..X..|
   .byte $32 ; |..XX..X.|
   .byte $2B ; |..X.X.XX|
   .byte $72 ; |.XXX..X.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|

LexLutherSprites
LexLuther_0
   .byte $E0 ; |XXX.....|
   .byte $38 ; |..XXX...|
   .byte $20 ; |..X.....|
   .byte $2E ; |..X.XXX.|
   .byte $2E ; |..X.XXX.|
   .byte $2E ; |..X.XXX.|
   .byte $2C ; |..X.XX..|
   .byte $3E ; |..XXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0E ; |....XXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0E ; |....XXX.|
   .byte $00 ; |........|
LexLuther_1
   .byte $38 ; |..XXX...|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $2E ; |..X.XXX.|
   .byte $2E ; |..X.XXX.|
   .byte $2E ; |..X.XXX.|
   .byte $2C ; |..X.XX..|
   .byte $3E ; |..XXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0E ; |....XXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0E ; |....XXX.|
   .byte $00 ; |........|

SupermanSprites
SupermanFly_0
   .byte $C6 ; |XX...XX.|
   .byte $36 ; |..XX.XX.|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $3F ; |..XXXXXX|
   .byte $76 ; |.XXX.XX.|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
SupermanFly_1
   .byte $26 ; |..X..XX.|
   .byte $56 ; |.X.X.XX.|
   .byte $8E ; |X...XXX.|
   .byte $1C ; |...XXX..|
   .byte $3F ; |..XXXXXX|
   .byte $76 ; |.XXX.XX.|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
SupermanWalk_0
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
SupermanWalk_1
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $B4 ; |X.XX.X..|
   .byte $B3 ; |X.XX..XX|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $66 ; |.XX..XX.|
NullCharacter
   .byte $00 ; |........|

ClarkKentWalk_0
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
ClarkKentWalk_1
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $BC ; |X.XXXX..|
   .byte $BB ; |X.XXX.XX|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|

GangsterSprites
Gangster_0
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|
   .byte $78 ; |.XXXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $F2 ; |XXXX..X.|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $70 ; |.XXX....|
   .byte $00 ; |........|
Gangster_1
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|
   .byte $78 ; |.XXXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $F2 ; |XXXX..X.|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $C8 ; |XX..X...|
   .byte $88 ; |X...X...|
   .byte $CC ; |XX..XX..|
   .byte $00 ; |........|

LexLutherMatrix
   .byte <helicopterScreen, <lexLutherScreen
   .byte <lexLutherScreen, <kryptonite1Screen
   .byte <playerCurrentRoom, <lexLutherScreen
   .byte 0

LoisLaneMatrix
   .byte <kryptonite3Screen, <loisLaneScreen
   .byte <loisLaneScreen, <playerCurrentRoom
   .byte <loisLaneScreen, <subwayScreen
   .byte 0

FlightSoundHeightRange
   .byte FLIGHT_SOUND_RANGE_01, FLIGHT_SOUND_RANGE_02
   .byte FLIGHT_SOUND_RANGE_03, FLIGHT_SOUND_RANGE_04, FLIGHT_SOUND_RANGE_05

DisplayKernel
   ldx #1
.calculateTimerFontOffsets
   lda gameTimer,x                  ; get the game timer value
   and #$0F                         ; mask off the upper nybbles
   sta lsbGameTimerOffsets,x
   asl                              ; shift the value left to multiply by 4
   asl
   clc                              ; add in original so it's multiplied by 5
   adc lsbGameTimerOffsets,x        ; [i.e. x * 5 = (x * 4) + x]
   sta lsbGameTimerOffsets,x
   lda gameTimer,x                  ; get the game timer value
   and #$F0                         ; mask off the lower nybbles
   lsr                              ; divide the value by 16
   lsr
   lsr
   lsr
   sta msbGameTimerOffsets,x        ; save it for later
   asl                              ; now multiple the value by 4 (x / 4)
   asl
   clc                              ; add in original so it's multiplied by
   adc msbGameTimerOffsets,x        ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]
   sta msbGameTimerOffsets,x
   dex
   bpl .calculateTimerFontOffsets
.waitTime
   lda INTIM                        ; wait for vertical blanking to end
   bne .waitTime
   lda #STATUS_KERNEL_TIME
   sta TIM64T
   ldx #H_FONT - 1
StatusKernel SUBROUTINE
   sta WSYNC
;--------------------------------------
   lda pf1GangsterIndicators  ; 3         get gangster indicator values
   sta PF1                    ; 3 = @06   set PF1 to show gangsters remaining
   lda pf2GangsterIndicators  ; 3         get gangster indicator values
   sta PF2                    ; 3 = @12   set PF2 to show gangsters remaining
   ldy minutesLSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta tmpTimerGraphics       ; 3
   ldy minutesMSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   ldy pf2EnemyIndicators     ; 3
   and #$F0                   ; 2         mask the lower nybble
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   sty.w PF2                  ; 4 = @48
   ora tmpTimerGraphics       ; 3
   sta pf1EnemyIndicators     ; 3
   sta PF1                    ; 3 = @57
   inc minutesLSBOffset       ; 5
   inc minutesMSBOffset       ; 5
   lda pf1GangsterIndicators  ; 3         get gangster indicator values
   ldy pf2GangsterIndicators  ; 3         get gangster indicator values
   sta WSYNC
;--------------------------------------
   sta PF1                    ; 3 = @03   set PF1 to show gangsters remaining
   sty PF2                    ; 3 = @06   set PF2 to show gangsters remaining
   ldy secondsMSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask the upper nybble
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta tmpTimerGraphics       ; 3
   ldy secondsLSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask the upper nybble
   ora tmpTimerGraphics       ; 3
   ldy pf2EnemyIndicators     ; 3
   sta pf2EnemyIndicators     ; 3
   sty.w PF2                  ; 4 = @48
   lda pf1EnemyIndicators     ; 3
   sta PF1                    ; 3 = @54
   inc secondsMSBOffset       ; 5
   inc secondsLSBOffset       ; 5
   dex                        ; 2
   bpl StatusKernel           ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF1                    ; 3 = @05
   sta PF2                    ; 3 = @08
   sta objectGraphicsOffset   ; 3         reset object's graphic offset
   sta playerGraphicsOffset   ; 3         reset player graphic offset
   sta GRP0                   ; 3 = @17
   sta GRP1                   ; 3 = @20
   lda #8                     ; 2
   sta playfieldGraphicsOffset; 3
   lda #H_KERNEL              ; 2
   sta currentScanline        ; 3
   sta WSYNC
;--------------------------------------
   ldx #DOUBLE_SIZE           ; 2
   lda currentObjectId        ; 3         get the current object being shown
   cmp #<HelicopterDS         ; 2
   beq .setSizeOfObject       ; 2³
   cmp #<BridgeCompleteDS     ; 2
   beq .setSizeOfObject       ; 2³
   cmp #<BridgePiece0DS       ; 2
   beq .setSizeOfObject       ; 2³
   cmp #<BridgePiece1DS       ; 2
   beq .setSizeOfObject       ; 2³
   cmp #<BridgePiece2DS       ; 2
   beq .setSizeOfObject       ; 2³
   ldx #ONE_COPY              ; 2
.setSizeOfObject
   stx NUSIZ0                 ; 3
   lda #NO_REFLECT            ; 2
   ldx currentObjectId        ; 3         get the current object being shown
   cpx #<BridgePiece0DS       ; 2         if the object is a human then
   bcs .setObjectReflectState ; 2³        don't reflect the player
   lda playerDirection        ; 3
   asl                        ; 2
.setObjectReflectState
   sta REFP0                  ; 3
   lda playerHorizPos         ; 3
   ldx #1                     ; 2
PositionObjectsOnScreen
   ldy #2                     ; 2
   sec                        ; 2
.determineCoarsePosition
   iny                        ; 2
   sbc #15                    ; 2
   bcs .determineCoarsePosition;2³
   eor #$FF                   ; 2
   sbc #7 - 1                 ; 2         carry clear
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta WSYNC
;--------------------------------------
.coarseMoveObject
   dey                        ; 2
   bpl .coarseMoveObject      ; 2³
   sta RESP0,x                ; 4
   sta HMP0,x                 ; 4
   lda objectHorizPos         ; 3
   dex                        ; 2
   bpl PositionObjectsOnScreen; 2³
.waitTime
   lda INTIM                  ; 4
   bne .waitTime              ; 2³        wait for status kernel to end
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   sta pf0Graphics            ; 3
   sta pf1Graphics            ; 3
   sta pf2Graphics            ; 3
   sta CXCLR                  ; 3 = @26   clear all collisions
   sta WSYNC
;--------------------------------------
   lda backgroundColor        ; 3         get the background/building color
   sta COLUBK                 ; 3 = @06   color the background/buildings
   lda skyColor               ; 3
   sta COLUPF                 ; 3 = @12
   jmp .skipPlayerDraw        ; 3

.kernelLoop
   lda currentScanline        ; 3         get current scanline
   cmp playerVertPos          ; 3         see if player is in scanline zone
   sta WSYNC
;--------------------------------------
   bpl .skipPlayerDraw        ; 2³
   ldy playerGraphicsOffset   ; 3         get player graphic offset for read
   lda (playerColorPtrs),y    ; 5
   sta COLUP1                 ; 3 = @13
   lda (playerGraphicsPtrs),y ; 5
   sta GRP1                   ; 3 = @21   draw player Clark Kent/Superman
   beq .skipPlayerDraw        ; 2³
   inc playerGraphicsOffset   ; 5         increment offset for next scanline
.skipPlayerDraw
   ldx #0                     ; 2
   ldy #0                     ; 2
   lda currentScanline        ; 3         get current scanline
   cmp objectVertPos          ; 3         see if object is in scanline zone
   bpl .skipObjectDraw        ; 2³
   ldy objectGraphicsOffset   ; 3         get object's graphic offset for read
   lda (characterColorPtrs),y ; 5
   tax                        ; 2
   lda (characterGraphicPtrs),y; 5
   tay                        ; 2
   beq .skipObjectDraw        ; 2³
   inc objectGraphicsOffset   ; 5         increment offset for next scanline
.skipObjectDraw
   lda currentScanline        ; 3         get current scanline
   and #$0F                   ; 2
   bne .drawPlayfieldGraphics ; 2³
   sta WSYNC
;--------------------------------------
   sty GRP0                   ; 3 = @03   draw object
   stx COLUP0                 ; 3 = @06
   ldy playfieldGraphicsOffset; 3         get offset for playfield graphics
   bpl .setupPlayfieldValues  ; 2³
   ldy #0                     ; 2
   sty pf0Graphics            ; 3
   sty pf1Graphics            ; 3
   lda roomGraphicPtrs        ; 3         get the graphic pointer LSB
   cmp #<BridgeRoom           ; 2
   bne .setPF2Graphics        ; 2³
   ldy #%11000000             ; 2         draw gap for bridge chasm
.setPF2Graphics
   sty pf2Graphics            ; 3
   jmp .nextScanline          ; 3

.setupPlayfieldValues
   lda (roomGraphicPtrs),y    ; 5
   sta pf0Graphics            ; 3
   dey                        ; 2
   lda (roomGraphicPtrs),y    ; 5
   sta pf1Graphics            ; 3
   dey                        ; 2
   lda (roomGraphicPtrs),y    ; 5
   sta pf2Graphics            ; 3
   dey                        ; 2
   sty playfieldGraphicsOffset; 3
.nextScanline
   dec currentScanline        ; 5         reduce scanline
   lda currentScanline        ; 3         get current scanline
   cmp #8                     ; 2
   bpl .kernelLoop            ; 2³
   jmp Overscan               ; 3

.drawPlayfieldGraphics
   sta WSYNC
;--------------------------------------
   lda pf0Graphics            ; 3
   sta PF0                    ; 3 = @06
   lda pf1Graphics            ; 3
   sta PF1                    ; 3 = @12
   sty GRP0                   ; 3 = @15
   stx COLUP0                 ; 3 = @18
   lda pf2Graphics            ; 3
   sta PF2                    ; 3 = @24
   jmp .nextScanline          ; 3

Overscan
   lda #OVERSCAN_TIME
   sta TIM64T
   lda #0
   sta GRP0
   sta GRP1
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #VBLANK_TIME
   sty TIM64T                       ; set timer for vertical blank
   ldy #DISABLE_TIA
   sty WSYNC                        ; wait for next scan line
   sty VBLANK                       ; disable TIA (D1 = 1)
   sty WSYNC                        ; wait 3 scan lines before starting VSYNC
   sty WSYNC
   sty WSYNC
   sty VSYNC                        ; start vertical sync (D1 = 1)
   sty WSYNC                        ; first line of VSYNC
   sty WSYNC                        ; second line of VSYNC
   sta WSYNC                        ; last line of VSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   sta VBLANK                       ; enable TIA (D1 = 0)
   sta PF2                          ; clear PF2 register (a = 0)
   lda SWCHB                        ; read the console switch values
   tax                              ; move value to x for later
   eor #$FF                         ; flip the bits
   and consoleSwitchValue           ; and value with last frame switch value
   stx consoleSwitchValue           ; move current SWCHB value
   lsr                              ; RESET now in carry
   bcs Start                        ; branch to Start if RESET pressed
   inc frameCount
   lda gameState                    ; get current game state
   bne CheckToIncrementGameTimer    ; branch if GAME ON
   lda frameCount                   ; get the current frame count
   bne .doneVerticalSync            ; cycle game rooms every 256 frames
   lda #8                           ; cycle through the game rooms in
   clc                              ; attract mode
   adc playerCurrentRoom
   cmp #<TwinTowersDS
   bcc .setNewRoomForAttractMode
   lda #<InsideDailyPlanetDS
.setNewRoomForAttractMode
   sta playerCurrentRoom
CheckToIncrementGameTimer
   lda frameCount                   ; get the current frame count
   sec                              ; see if 1 second has passed (i.e. NTSC
   sbc #FRAMES_PER_SECOND           ; refreshes at ~58 frames per second)
   bne .doneVerticalSync
   sta frameCount                   ; reset frame count every second
   lda gameState                    ; get current game state
   beq .doneVerticalSync            ; branch if game over
   inc gameState                    ; set to game in progress
   bne .incrementGameTimer
   lda playerCurrentRoom            ; get current room of player
   sta tempPlayerCurrentRoom        ; save it for later
.incrementGameTimer
   sed
   lda gameTimerSeconds             ; get game timer seconds value
   clc
   adc #1                           ; increment the seconds by 1
   sta gameTimerSeconds
   sec
   sbc #$60                         ; subtract seconds by #$60 (BCD) to see if
   bne .doneVerticalSync            ; minute has passed
   sta gameTimerSeconds             ; set seconds to #$00
   lda gameTimerMinutes             ; get game timer minutes value
   clc
   adc #1                           ; increment the minutes by 1
   sta gameTimerMinutes
.doneVerticalSync
   cld                              ; clear decimal mode
   lda #ORANGE2 + 4
   sta COLUPF
   lda skyColor
   sta COLUBK
   rts

Start
;
; Set up everything so the power up state is known.
;
   sei
   cld                              ; clear decimal mode
   lda #0
   ldx #4
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = #$FF
   txs                              ; point the stack to the beginning
   lda #PF_REFLECT
   sta CTRLPF                       ; REFLECT playfield
   lda #SUBWAY_X
   sta subwayHorizPos               ; set Subway sprite's horiz position
   sta subwayVertPos                ; set Subway sprite's vertical position
   sta kryptonite1VertPos
   lda #>HeroColors
   sta playerColorPtrs + 1
   lda #<BlueSubwayDS               ; pointer to Blue Subway room
   ldx #<kryptoniteLocations        ; pointer to kryptonite locations in RAM
   ldy #NUM_KRYPTONITE_OBJECTS      ; number of sprite locations to set
   jsr SetObjectLocations           ; place kryptonite sprites in Blue Subway
   ldx #<bridgeCompleteLocation     ; pointer to bridge sprite locations in RAM
   jsr SetObjectLocations           ; set location of 4 bridge sprites
   lda #<PhoneBoothRoomDS           ; pointer to LSB of Phone Booth room
   sta tempPlayerCurrentRoom        ; set temp and current room to the Phone
   sta playerCurrentRoom            ; Booth
   lda #PLAYER_INIT_HORIZ_POS
   sta playerHorizPos
   lda #PLAYER_INIT_VERT_POS
   sta playerVertPos
   lda #<NullCharacterDS
   sta carriedObjectId              ; set Superman to not carrying anything
   lda #>SupermanSprites
   sta playerGraphicsPtrs + 1
   lda #<loisLaneLocation
   sta helicopterPickUpRAMPtr
   lda #<BridgeRoomDS               ; pointer to LSB of Bridge room
   sta bridgeCompleteScreen         ; place completed bridge in Bridge room
   lda #BRIDGE_COMPLETE_X           ; horizontal position of completed bridge
   ldx #<bridgeCompleteHorizPos     ; pointer to RAM horiz position
   jsr SetObjectLocations           ; set the bridge pieces and helicopter
                                    ; horizontal positions
   lda #BRIDGE_COMPLETE_Y           ; vertical position of completed bridge
   ldx #<bridgeCompleteVertPos      ; pointer to RAM vertical position
   jsr SetObjectLocations           ; set the bridge pieces and helicopter
                                    ; vertical positions
   jsr VerticalSync                 ; start new frame
MainLoop
   jsr PlayAudioChannel1Sounds
   jsr CheckToMoveLoisLane
   jsr ProcessHelicopterSprite
   jsr MovePlayer
   jsr CheckPlayerCollisions
   jsr CheckForExplodingBridge
   jsr DisplayKernel
   jsr CheckForObjectEnteringSubway
   jsr MoveBadGuys
   jsr MoveKryptoniteSprites
   jsr MoveGangster5
   jsr DisplayKernel
   jsr CheckForXRayVision
   jsr MoveLexLuther
   jsr PlayAudioChannel0Sounds
   jsr DisplayKernel
   jmp MainLoop

CheckIfBridgeCompleted
   ldx #7
.checkCompletedBridgeLoop
   lda bridgePiece0Location,x       ; get the bridge piece horizontal position
   cmp #96                          ; see if greater than position 96
   bcs .doneBridgeCompleteRoutine   ; if so then bridge not complete
   cmp #48                          ; see if less than position 48
   bcc .doneBridgeCompleteRoutine   ; if so then bridge not complete
   dex                              ; check the piece's vertical position
   lda bridgePiece0Location,x       ; get the bridge piece vertical position
   cmp #24                          ; see if at position 24
   bne .doneBridgeCompleteRoutine   ; if not then bridge not complete
   dex                              ; check next piece's location
   dex
   bpl .checkCompletedBridgeLoop
   stx bridgePiece0Screen
   stx bridgePiece1Screen
   stx bridgePiece2Screen
   lda #<BridgeRoomDS               ; get LSB to Bridge Room data structure
   sta bridgeCompleteScreen         ; place completed bridge in Bridge room
   lda #<NullCharacterDS
   sta carriedObjectId              ; set Superman to not carrying anything
   lda #<nullCharacterLocation
   sta helicopterPickUpRAMPtr
   lda #$20
   sta soundPriority
.doneBridgeCompleteRoutine
   rts

CheckForExplodingBridge
   lda gameState                    ; get current game state
   beq .doneExplodingBridgeCheck    ; branch if game over
   lda objectSpawningTimer
   cmp #255
   bcs CheckIfBridgeCompleted
   cmp #0
   bne .spawnObjects
   lda playerCurrentRoom            ; get current room of player
   cmp #<BridgeRoomDS
   bne .doneExplodingBridgeCheck
.incrementSpawningTimer
   inc objectSpawningTimer
.doneExplodingBridgeCheck
   rts

.spawnObjects
   ldy objectSpawningTimer
   cpy #12
   bne .moveBridgePieces
   lda #<NullRoomDS
   sta bridgeCompleteScreen         ; place completed bridge in Null room
   lda #<BridgeRoomDS               ; get LSB to Bridge Room data structure
   sta bridgePiece0Screen           ; place bridge piece 0 in Bridge room
   sta bridgePiece1Screen           ; place bridge piece 1 in Bridge room
   sta bridgePiece2Screen           ; place bridge piece 2 in Bridge room
   lda #$10
   sta soundPriority
   tya
.moveBridgePieces
   bcc .checkToSpawnLexLuther
   inc bridgePiece0HorizPos
   inc bridgePiece0VertPos
   inc bridgePiece0VertPos
   inc bridgePiece1VertPos
   inc bridgePiece1VertPos
   dec bridgePiece2HorizPos
   inc bridgePiece2VertPos
   inc bridgePiece2VertPos
.checkToSpawnLexLuther
   cpy #LEX_LUTHER_SPAWN_TIME
   bne .checkToSpawnGangstersAndHelicopter
   ldx #<lexLutherScreen            ; pointer to Lex Luther screen
   jsr PlaceObjectInBridgeRoom
   lda #<MetropolisDS               ; get LSB to Metropolis data structure
   sta bridgePiece0Screen           ; place bridge piece 0 in Metropolis room
   lda #<TripleTowerDS              ; get LSB to Triple Tower data structure
   sta bridgePiece1Screen           ; place bridge piece 1 in Triple Tower room
   lda #<TwoWindowRoomDS            ; get LSB to Two Window room data structure
   sta bridgePiece2Screen           ; place bridge piece 2 in Two Window room
.checkToSpawnGangstersAndHelicopter
   lda playerState                  ; get current player state
   and #<~WALKING
   bne CheckToSpawnGangstersAndHelicopter
   lda #<-1
   sta objectSpawningTimer
   lda #<GreenSubwayDS              ; get LSB to Green Subway data structure
   sta helicopterScreen             ; place helicopter in Green Subway room
   ldx #<lexLutherLocation          ; point to start of bad guy locations
   ldy #NUM_BADGUYS - 1             ; place all bad guys in Green Subway room
SetObjectLocations
.setLocationLoop
   sta $00,x                        ; set object location (x is RAM offset)
   inx                              ; increase offset by 3 to move to the next
   inx                              ; object's attribute to set
   inx
   dey                              ; continue until done (y holds number of
   bpl .setLocationLoop             ; objects to set)
   ldy #3
   rts

CheckToSpawnGangstersAndHelicopter
.checkToSpawnGangster1
   cpy #GANGSTER1_SPAWN_TIME
   bne .checkToSpawnHelicopter
   ldx #<gangster1Screen
   jsr PlaceObjectInBridgeRoom
.checkToSpawnHelicopter
   cpy #HELICOPTER_SPAWN_TIME
   bne .checkToSpawnGangster5
   ldx #<helicopterScreen
   jsr PlaceObjectInBridgeRoom
   lda #HELICOPTER_INIT_VERT_POS
   sta helicopterVertPos            ; set the helicopter's vertical position
.checkToSpawnGangster5
   cpy #GANGSTER5_SPAWN_TIME
   bne .checkToSpawnGangster2
   ldx #<gangster5Screen
   jsr PlaceObjectInBridgeRoom
.checkToSpawnGangster2
   cpy #GANGSTER2_SPAWN_TIME
   bne .checkToSpawnGangster3
   ldx #<gangster2Screen
   jsr PlaceObjectInBridgeRoom
.checkToSpawnGangster3
   cpy #GANGSTER3_SPAWN_TIME
   bne .checkToSpawnGangster4
   ldx #<gangster3Screen
   jsr PlaceObjectInBridgeRoom
.checkToSpawnGangster4
   cpy #GANGSTER4_SPAWN_TIME
   bne .jmpToIncrementSpawningTimer
   ldx #<gangster4Screen
   jsr PlaceObjectInBridgeRoom
.jmpToIncrementSpawningTimer
   jmp .incrementSpawningTimer

PlaceObjectInBridgeRoom
   lda #<BridgeRoomDS               ; get LSB to Bridge Room data structure
   sta $00,x                        ; place object in Bridge Room
   lda #120
   sta $00 + 1,x                    ; set object's horizontal position
   lda #44
   sta $00 + 2,x                    ; set object's vertical position
   rts

CheckForJoystickMovement
   lda #MY_NO_MOVE
   sta tempDirections               ; set player direction to not moving
   ldx soundPriority                ; get sound priority value
   bmi .doneJoystickMovement        ; branch if made it to Daily Planet
   lda SWCHA                        ; read the player joystick values
   tay                              ; move joystick value to y
   jsr SetPlayerHorizDirection
   tya                              ; move joystick value back to accumulator
   lsr                              ; move player 1 joystick values to lower
   lsr                              ; nybbles
   lsr
   lsr
   pha                              ; save value to stack
   jsr SetPlayerVertDirection
   pla                              ; move player 1 joystick values from stack
   jsr SetPlayerHorizDirection
   tya
   jsr SetPlayerVertDirection
   ldx gameState                    ; get current game state
   beq .checkToStartGameFromJoystickMovement; branch if game over
   lda SWCHB                        ; read the console switch values
   and #SELECT_MASK
   bne .selectNotPressed            ; branch if SELECT not pressed
   sta gameState                    ; set to GAME OVER state (a = 0)
   lda playerCurrentRoom            ; get current room of player
   sta tempPlayerCurrentRoom        ; save it for later
.selectNotPressed
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   bne .setGameStateToGameOn        ; start game if joystick moved
.checkToStartGameFromJoystickMovement
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .doneJoystickMovement        ; branch if joystick not moved
   ldx tempPlayerCurrentRoom        ; recall the current player room
   stx playerCurrentRoom            ; restore player room number
.setGameStateToGameOn
   ldx #1
   stx gameState                    ; set to GAME ON (i.e. non zero value)
.doneJoystickMovement
   rts

SetPlayerHorizDirection
   tax                              ; move joystick value to x
   and #MY_MOVE_LEFT ^ $0F          ; see if player is moving joystick left
   bne .checkForRightDirection
   lda #MY_MOVE_LEFT ^ $0F
   ora tempDirections
   and #MY_MOVE_DOWN
   sta tempDirections
   rts

.checkForRightDirection
   txa                              ; retrieve joystick value
   and #MY_MOVE_RIGHT ^ $0F
   bne .leaveHorizRoutine
   lda #MY_MOVE_DOWN ^ $0F
   ora tempDirections
   and #MY_MOVE_LEFT
   sta tempDirections
.leaveHorizRoutine
   rts

SetPlayerVertDirection
   tax                              ; move joystick value to x
   and #MY_MOVE_UP ^ $0F
   bne .checkForDownDirection
   lda #MY_MOVE_UP ^ $0F
   ora tempDirections
   and #MY_MOVE_RIGHT
   sta tempDirections
   rts

.checkForDownDirection
   txa                              ; retrieve joystick value
   and #MY_MOVE_DOWN ^ $0F
   bne .leaveVertRoutine
   lda #MY_MOVE_RIGHT ^ $0F
   ora tempDirections
   and #MY_MOVE_UP
   sta tempDirections
.leaveVertRoutine
   rts

MoveObject
   sta tempDirections
   lda gameState                    ; get current game state
   beq .doneMoveObject              ; branch if GAME OVER
.moveAgain
   dey                              ; y holds how many times to move
   bmi .doneMoveObject
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_LEFT ^ $0F
   bne .checkToMoveObjectLeft
   inc $00 + 1,x                    ; increment object's horizontal position
.checkToMoveObjectLeft
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_DOWN ^ $0F
   bne .checkToMoveObjectVertically
   dec $00 + 1,x                    ; decrement object's horizontal position
.checkToMoveObjectVertically
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_RIGHT ^ $0F
   bne .checkToMoveObjectUp
   inc $00 + 2,x                    ; increment object's vertical position
.checkToMoveObjectUp
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_UP ^ $0F
   bne .jmpToMoveAgain
   dec $00 + 2,x                    ; decrement object's vertical position
.jmpToMoveAgain
   jmp .moveAgain

.doneMoveObject
   rts

DetermineObjectsNewRoom
   jsr MoveObject                   ; move selected object in game space
   lda $00 + 2,x                    ; get the object's vertical position
   cmp #MAX_Y
   bmi .checkForObjectMovingWest
   lda #MIN_Y
   sta $00 + 2,x                    ; set the object's new vertical position
   ldy #NORTH_ROOM_OFFSET           ; set y to point to current room's north room
   bne SetObjectsNewRoomNumber      ; unconditional branch

.checkForObjectMovingWest
   lda $00 + 1,x                    ; get the object's horizontal position
   cmp #MIN_X
   bcc .placeObjectInWestRoom
   cmp #MAX_X
   bcc .checkForObjectMovingSouth
.placeObjectInWestRoom
   lda #142
   sta $00 + 1,x                    ; set the object's new horizontal position
   ldy #WEST_ROOM_OFFSET            ; set y to point to current room's west room
   bne SetObjectsNewRoomNumber      ; unconditional branch

.checkForObjectMovingSouth
   lda $00 + 2,x                    ; get the object's vertical position
   cmp #MIN_Y
   bpl .checkForObjectMovingEast
   lda #MAX_Y - 1
   sta $00 + 2,x                    ; set the object's new vertical position
   ldy #SOUTH_ROOM_OFFSET           ; set y to point to current room's south room
   bne SetObjectsNewRoomNumber      ; unconditional branch

.checkForObjectMovingEast
   lda $00 + 1,x                    ; get the object's horizontal position
   cmp #147
   bcc .doneNewRoomDetermination
   lda #MIN_X
   sta $00 + 1,x                    ; set the object's new horizontal position
   ldy #EAST_ROOM_OFFSET            ; set y to point to current room's east room
   bne SetObjectsNewRoomNumber      ; not needed -- could fall through

SetObjectsNewRoomNumber
   lda $00,x                        ; get the object's current room
   sta dataStructurePtr
   lda #>RoomListDataStructure
   sta dataStructurePtr + 1
   lda (dataStructurePtr),y         ; get the adjacent room number
   sta $00,x                        ; set the object's new room number
.doneNewRoomDetermination
   rts

MoveKryptoniteSprites
   ldx #KRYPTONITE_MOVE_RATE
   stx objectMoveRate
   ldx #0
   lda playerState                  ; get current player state
   and #HIT_KRYPTONITE
   beq .setKryptoniteMatrixVariables; branch if not hit kryptonite
   ldx #<playerCurrentRoom
.setKryptoniteMatrixVariables
   stx matrixTableEndPoint
   lda #>KryptoniteMatrixes
   sta objectMatrixPtrs + 1
   lda frameCount                   ; get the current frame count
   and #3
   beq .moveKryptonite1
   cmp #2
   beq .moveKryptonite2
   lda #<Kryptonite3Matrix
   sta objectMatrixPtrs
   ldy #<kryptonite3Screen
   jmp .skipSetObjectVertMax

.moveKryptonite2
   lda #<Kryptonite2Matrix
   sta objectMatrixPtrs
   ldy #<kryptonite2Screen
   jmp .skipSetObjectVertMax

.moveKryptonite1
   lda #<Kryptonite1Matrix
   sta objectMatrixPtrs
   ldy #<kryptonite1Screen
   jmp .skipSetObjectVertMax

CheckIfCarriedBySuperman
   cpx carriedObjectId              ; see if same as object being carried
   bne .notCarryingObject
   pla                              ; pull current return position off the
   pla                              ; stack so we return to MainLoop
.notCarryingObject
   rts

MoveBadGuys
   lda #BAD_GUY_MOVE_RATE
   sta objectMoveRate
   lda #0
   sta matrixTableEndPoint
   lda #>Gangster1Thru4Matrixes
   sta objectMatrixPtrs + 1
   lda frameCount                   ; get the current frame count
   and #3
   beq .moveGangster1
   tax
   dex
   beq .moveGangster2
   dex
   beq .moveGangster3
   ldx #<Gangster4DS
   jsr CheckIfCarriedBySuperman
   lda #<Gangster4Matrix
   sta objectMatrixPtrs
   lda #<~GANGSTER4_IND_VALUE
   ldy #<gangster4Location
   jmp DetermineIfGangsterInJail

.moveGangster3
   ldx #<Gangster3DS
   jsr CheckIfCarriedBySuperman
   lda #<Gangster3Matrix
   sta objectMatrixPtrs
   lda #<~GANGSTER3_IND_VALUE
   ldy #<gangster3Location
   jmp DetermineIfGangsterInJail

.moveGangster2
   ldx #<Gangster2DS
   jsr CheckIfCarriedBySuperman
   lda #<Gangster2Matrix
   sta objectMatrixPtrs
   lda #<~GANGSTER2_IND_VALUE
   ldy #<gangster2Location
   jmp DetermineIfGangsterInJail

.moveGangster1
   ldx #<Gangster1DS
   jsr CheckIfCarriedBySuperman
   lda #<Gangster1Matrix
   sta objectMatrixPtrs
   lda #<~GANGSTER1_IND_VALUE
   ldy #<gangster1Location
   jmp DetermineIfGangsterInJail

MoveLexLuther
   ldx #<LexLutherDS
   jsr CheckIfCarriedBySuperman
   lda #LEX_LUTHER_MOVE_RATE
   sta objectMoveRate
   lda #0
   sta matrixTableEndPoint
   lda #GANGSTER5_IND_VALUE
   and pf2GangsterIndicators        ; and to assume Lex Luther in jail
   ldx lexLutherScreen              ; get room number for Lex Luther
   cpx #<NullRoomDS
   beq .setLexLutherValues          ; branch if Lex Luther in jail
   ora #LEX_LUTHER_IND_VALUE        ; place Lex Luther values in indicator
.setLexLutherValues
   sta pf2GangsterIndicators
   lda #<LexLutherMatrix
   sta objectMatrixPtrs
   lda #>LexLutherMatrix
   sta objectMatrixPtrs + 1
   ldy #<lexLutherScreen
   jmp .skipSetObjectVertMax

MoveGangster5
   ldx #<Gangster5DS
   jsr CheckIfCarriedBySuperman
   lda #GANGSTER5_MOVE_RATE
   sta objectMoveRate
   lda #0
   sta matrixTableEndPoint
   lda #<Gangster5Matrix
   sta objectMatrixPtrs
   lda #>Gangster5Matrix
   sta objectMatrixPtrs + 1
   lda #LEX_LUTHER_IND_VALUE
   and pf2GangsterIndicators        ; mask to assume Gangster 5 in jail
   ldx gangster5Screen              ; get room number of Gangster 5
   cpx #<NullRoomDS
   beq .setGangster5Values          ; branch if Gangster 5 in jail
   ora #GANGSTER5_IND_VALUE         ; place Gangster 5 values in indicator
.setGangster5Values
   sta pf2GangsterIndicators
   ldy #<gangster5Location
   jmp DetermineObjectMoveRate

CheckToMoveLoisLane
   lda frameCount                   ; get the current frame count
   and #1                           ; and value to see if even or odd frame
   beq .moveLoisLane                ; branch if even frame
   rts

.moveLoisLane
   lda #<InsideDailyPlanetDS        ; see if Lois Lane is inside Daily Planet
   cmp loisLaneScreen
   bne .checkIfSupermanCarryingLois ; branch if she is not
   lda #<DailyPlanetDS              ; see if helicopter in Daily Planet room
   cmp helicopterScreen
   bne .checkIfSupermanCarryingLois ; branch if not
   sta loisLaneScreen               ; place Lois Lane in Daily Planet room
.checkIfSupermanCarryingLois
   ldx #<LoisLaneDS
   jsr CheckIfCarriedBySuperman
   ldx #LOIS_LANE_MOVE_RATE
   stx objectMoveRate
   dex                              ; x = 1
   lda playerState                  ; get current player state
   and #HIT_KRYPTONITE
   bne .setLoisMatrixVariables      ; branch if hit kryptonite
   ldx #<playerCurrentRoom          ; let player's room be stopping point
.setLoisMatrixVariables
   stx matrixTableEndPoint
   lda #<LoisLaneMatrix
   sta objectMatrixPtrs
   lda #>LoisLaneMatrix
   sta objectMatrixPtrs + 1
   ldy #<loisLaneLocation
   jmp DetermineObjectMoveRate

CheckForObjectEnteringSubway
   lda carriedObjectId              ; get id of object being carried
   cmp #<NullCharacterDS
   bne .doneCheckForEnteringSubway  ; branch if Superman carrying an object
   ldx #<loisLaneLocation - lexLutherLocation
.checkNextObject
   ldy #SUBWAY_X - 1
.checkForObjectEnteringSubway
   tya
   cmp objectLocations + 1,x        ; compare with object's horiz position
   beq DetermineSubwayToPlaceObject
   cmp objectLocations + 2,x        ; compare with object's vert position
   beq DetermineSubwayToPlaceObject
   iny
   cpy #SUBWAY_X + 2
   bne .checkForObjectEnteringSubway
   dex                              ; decrement x three times to point to
   dex                              ; next object's position
   dex
   bpl .checkNextObject
.doneCheckForEnteringSubway
   rts

DetermineSubwayToPlaceObject
   ldy #NUM_SUBWAY_ENTRANCES - 1
   lda objectLocations,x            ; get room number of object
.checkNextSubway
   cmp SubwayEntranceRooms,y
   beq .placeObjectInSubway
   dey
   bpl .checkNextSubway
   rts

.placeObjectInSubway
   lda InsideRooms + 1,y            ; pointer to inside a subway
   sta objectLocations,x
   rts

CheckPlayerCollisions
   lda CXPPMM                       ; read P0/P1 collisions
   bpl .jmpToDonePlayerCollisions   ; branch if players didn't collided
   lda currentObjectId              ; get the current object being shown
   cmp #<PhoneBoothSpriteDS         ; see if it's the phone booth
   bne .checkLoisLaneCollision
   lda playerState                  ; get current player state
   and #~CLARK_KENT
   ldx pf1GangsterIndicators        ; get remaining gangster values
   bne .missionNotDone
   ldx pf2GangsterIndicators
   bne .missionNotDone
   ldx bridgeCompleteScreen         ; get screen location of completed bridge
   cpx #<BridgeRoomDS               ; see if in the Bridge Room
   bne .missionNotDone
   ora #CLARK_KENT
.missionNotDone
   sta playerState
   ldx PhoneBoothLocation + 2       ; get phone booth's vertical position
   dex
   stx playerVertPos                ; set to player's vertical position
.jmpToDonePlayerCollisions
   jmp .donePlayerCollisions

.checkLoisLaneCollision
   lda gameState                    ; get current game state
   beq .jmpToDonePlayerCollisions   ; branch if GAME OVER
   ldy currentObjectId              ; get the current object being shown
   cpy #<LoisLaneDS                 ; see if it's Lois Lane
   bne .checkJailCollision
   ldx soundPriority                ; get sound priority value
   bmi .checkJailCollision          ; branch if made it to Daily Planet
   lda #~HIT_KRYPTONITE             ; set player state to not hit kryptonite
   and playerState                  ; because player touched Lois Lane
   sta playerState
   lda #2
   sta soundPriority
.checkJailCollision
   cpy #<JailSpriteDS               ; see if player collided with Jail
   bne .checkForEnteringDailyPlanet
   ldx carriedObjectId              ; get id of object being carried
   cpx #<LoisLaneDS                 ; see if Superman carrying bad guy
   bpl .donePlayerCollisions        ; branch if not carrying bad guy
   jsr SetPointersToObjectRoom
   ldx #0
   lda #<NullRoomDS
   sta (objectLocationPtr,x)
   lda #<NullCharacterDS
   sta carriedObjectId
   lda #8
   sta soundPriority
   rts

.checkForEnteringDailyPlanet
   cpy #<DailyPlanetSpriteDS        ; see if player collided with Daily Planet
   bne .checkForEnteringSubway
   lda #<InsideDailyPlanetDS        ; set player's current room to inside
   sta playerCurrentRoom            ; the Daily Planet
   lda #CLARK_KENT
   and playerState
   beq .donePlayerCollisions        ; branch if player is Superman
   sta soundPriority
.checkForEnteringSubway
   ldx #4                           ; four subway entrances
   lda #<BridgeCompleteDS           ; set to Data Structure under subways
.checkNextSubwayEntrance
   dex
   bmi .checkForTouchingKryptonite
   sec
   sbc #6
   cmp currentObjectId              ; see if player hit this subway entrance
   bne .checkNextSubwayEntrance
   lda InsideRooms + 1,x            ; point to inside a subway
   sta playerCurrentRoom            ; place player inside the subway
   rts

.checkForTouchingKryptonite
   cpy #<Kryptonite1DS              ; see if player hit kryptonite 1
   beq .playerHitKryptonite
   cpy #<Kryptonite2DS              ; see if player hit kryptonite 2
   beq .playerHitKryptonite
   cpy #<Kryptonite3DS              ; see if player hit kryptonite 3
   bne .skipKryptoniteCollision
.playerHitKryptonite
   lda #WALKING | HIT_KRYPTONITE    ; set player to walking and hit kryptonite
   ora playerState
   sta playerState
   lda #1
   sta soundPriority
.skipKryptoniteCollision
   lda playerState                  ; get current player state
   and #WALKING | CLARK_KENT | HIT_KRYPTONITE
   bne .donePlayerCollisions
   lda carriedObjectId              ; get id of object being carried
   cmp #<NullCharacterDS
   bne .donePlayerCollisions
   lda currentObjectId              ; get the current object being shown
   cmp #<Kryptonite1DS
   bpl .donePlayerCollisions
   sta carriedObjectId              ; Superman carrying current object
   lda #4
   sta soundPriority
.donePlayerCollisions
   rts

PlayAudioChannel0Sounds
   lda gameState                    ; get current game state
   beq TurnOffGameSounds            ; branch if GAME OVER
   lda #3
   sta AUDC0
   lda currentObjectId              ; get the current object being shown
   cmp #<HelicopterDS
   beq HelicopterSoundRoutine
   cmp #<LexLutherDS
   beq LexLutherSoundRoutine
   cmp #<Kryptonite1DS
   beq KryptoniteSoundRoutine
   cmp #<Kryptonite2DS
   beq KryptoniteSoundRoutine
   cmp #<Kryptonite3DS
   beq KryptoniteSoundRoutine
   lda soundDelayTimer
   ora soundPriority
   bne .donePlayAudioChannel0Sounds
   sta AUDV0
.donePlayAudioChannel0Sounds
   rts

HelicopterSoundRoutine
   lda #$0C
   sta AUDF0
   lda #15
.setChannel0Volume
   sta AUDV0
   ldx soundPriority
   bne .doneHelicopterSound
   sta soundDelayTimer
.doneHelicopterSound
   rts

LexLutherSoundRoutine
   lda #$0B
   sta AUDF0
   bne .setChannel0Volume           ; unconditional branch

KryptoniteSoundRoutine
   lda #4
   sta AUDC0
   sta AUDF0
   and frameCount
   sta AUDV0
   rts

XRayVisionSoundRoutine
   jsr CheckForJoystickMovement
   lda #0
   tay
   tax
   ora INPT4                        ; read player 1 fire button
   and INPT5                        ; and with player 2 fire button value
   bmi FlyingSoundRoutine           ; branch if neither fire button is pressed
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .setFlyingSoundVolume        ; branch if joystick not moved
   inx                              ; x = 1
   stx AUDC1                        ; set audio channel for x-ray vision
   lda #6
   and frameCount
   sta AUDF1                        ; set audio frequency for x-ray vision
   tax
   jmp .setFlyingSoundVolume

TurnOffGameSounds
   sta AUDV0                        ; accumulator is 0 so the volume is turned
   sta AUDV1                        ; off to disable sound
   sta gameState
   rts

FlyingSoundRoutine
   lda playerState                  ; get current player state
   bne .setFlyingSoundVolume        ; branch if not FLYING
   lda #8
   sta AUDC1
   sta AUDF1
.determineFlightVertRange
   lda FlightSoundHeightRange,y
   iny
   inx                              ; increment flying volume by 2
   inx
   cmp playerVertPos
   bcs .determineFlightVertRange
.setFlyingSoundVolume
   stx AUDV1
   lda soundDelayTimer
   beq .doneFlyingSoundRoutine
   dec soundDelayTimer
.doneFlyingSoundRoutine
   rts

PlayAudioChannel1Sounds
   lda gameState                    ; get current game state
   beq TurnOffGameSounds            ; branch if GAME OVER
   lda soundPriority
   beq XRayVisionSoundRoutine       ; branch to play x-ray vision routine
   lda soundDelayTimer
   bne .determineSoundFromSoundPriority
   lda #16
   sta soundDelayTimer              ; reset sound delay timer
.determineSoundFromSoundPriority
   ldx #6
   lda soundPriority
.nextSoundBitPriority
   dex
   bmi PlaySoundForClarkKentInDailyPlanet
   lsr                              ; shift D0 to carry bit
   bcc .nextSoundBitPriority        ; check next bit for sound priority
   lda AudioChannel_01_Values,x
   sta AUDC1                        ; set audio channel 1
   lsr                              ; shift frequency value to lower nybbles
   lsr
   lsr
   lsr
   sta AUDF1                        ; set audio frequency 1
   dec soundDelayTimer
   lda soundDelayTimer
   sta AUDV1
   beq .clearSoundPriorityBits
   rts

.clearSoundPriorityBits
   sta soundPriority                ; a = 0
   rts

PlaySoundForClarkKentInDailyPlanet 
   lda soundPriority                ; get sound priority value
   bmi .playEndingGameSound         ; branch if made it to Daily Planet
   lda #48
   sta soundDelayTimer
   lda #%10000000
   sta soundPriority                ; show Clark Kent made it to Daily Planet
.playEndingGameSound
   lda #$0C
   sta AUDC1                        ; set audio channel to a pure tone
   dec soundDelayTimer              ; reduce sound delay timer
   lda soundDelayTimer              ; get sound delay timer
   beq TurnOffGameSounds            ; turn off sound if reached 0
   and #$F0                         ; keep upper nybbles
   beq .playLastGameOverTone        ; branch if playing last game over tones
   and #$E0
   beq .playSecondGameOverTone      ; branch if playing second game over tones
   lda #8                           ; play first game over tones
.decrementSoundDelayTimer
   dec soundDelayTimer
.setChannel_01AudioFrequency
   sta AUDF1
   lda soundDelayTimer
   sta AUDV1
   rts

.playSecondGameOverTone
   lda #6
   bne .decrementSoundDelayTimer    ; unconditional branch
   
.playLastGameOverTone
   lda #10
   bne .setChannel_01AudioFrequency ; unconditional branch

MovePlayer
   jsr CheckForJoystickMovement
   eor #MY_NO_MOVE
   and #(MY_MOVE_LEFT & MY_MOVE_DOWN) ^ $0F
   beq .setPlayerRefectiveState
   lda tempDirections               ; get the player's direction
   sta playerDirection              ; set player's direction
.setPlayerRefectiveState
   lda playerDirection              ; get the player's direction
   asl
   sta REFP1                        ; set player's relective state
   lda playerState                  ; get current player state
   bne SetPlayerPointersForWalking  ; branch if not FLYING
   jmp SetPlayerPointersForFlying

SetPlayerPointersForWalking
   lda #ONE_COPY
   sta NUSIZ1
   lda #<NullCharacterDS
   sta carriedObjectId              ; make sure player not carrying object
   lda playerState                  ; get current player state
   and #CLARK_KENT | HIT_KRYPTONITE
   beq .setToSupermanWalking
   lda playerCurrentRoom            ; get current room of player
   ldx #4
.checkForInsideRoom
   cmp InsideRooms,x                ; see if player is inside a room
   beq .animatePlayer               ; branch if inside a room
   dex
   bpl .checkForInsideRoom
   lda #FLIGHT_SOUND_RANGE_05   
   cmp playerVertPos
   bmi .checkPlayerLowerVertLimit
   sta playerVertPos
.checkPlayerLowerVertLimit
   lda #PLAYER_LOWER_VERT_LIMIT
   cmp playerVertPos
   bpl .animatePlayer
   sta playerVertPos
.animatePlayer
   lda playerState                  ; get current player state
   and #CLARK_KENT
   beq .setToSupermanWalking        ; branch if player is Superman
   ldx #<ClarkKentWalk_0
   lda frameCount                   ; get the current frame count
   and #2
   beq .getClarkKentColorLSB
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .getClarkKentColorLSB
   ldx #<ClarkKentWalk_1
.getClarkKentColorLSB
   ldy #<ClarkKentColors
   lda #<BridgeRoomDS               ; get the Bridge Room LSB
   cmp playerCurrentRoom            ; see if player in Bridge Room
   bne .checkPlayerInPhoneBoothRoom
   
   IF COMPILE_REGION = PAL50
   
   lda #68
   
   ELSE
   
   lda #54
   
   ENDIF
   
   cmp playerHorizPos               ; compare with player horizontal position
   bcs .checkForBridgeComplete      ; branch if player to the left of gap
   sta playerVertPos                ; set vertical position
.checkForBridgeComplete
   lda #<BridgeRoomDS               ; get the Bridge Room LSB
   cmp bridgeCompleteScreen         ; see if completed bridge in Bridge Room
   beq .checkPlayerInPhoneBoothRoom
   lda #67
   cmp playerHorizPos
   bcs .checkPlayerInPhoneBoothRoom
   sta playerHorizPos
.checkPlayerInPhoneBoothRoom
   lda #<PhoneBoothRoomDS           ; get the Phone Booth Room LSB
   cmp playerCurrentRoom            ; see if player in Phone Booth Room
   bne .jmpToSetPlayerGraphicPtrs
   lda #48
   cmp playerHorizPos
   bcc .jmpToSetPlayerGraphicPtrs
   sta playerHorizPos
.jmpToSetPlayerGraphicPtrs
   jmp .setPlayerGraphicPointers

.setToSupermanWalking
   ldx #<SupermanWalk_0
   lda frameCount                   ; get the current frame count
   and #2
   beq .getSupermanWalkingColorLSB
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .getSupermanWalkingColorLSB
   ldx #<SupermanWalk_1
.getSupermanWalkingColorLSB
   ldy #<SupermanWalkingColors
   lda playerState                  ; get current player state
   and #HIT_KRYPTONITE
   bne .jmpToSetPlayerGraphicPtrs   ; branch if hit kryptonite
   stx dataStructurePtr
   lda playerState                  ; get current player state
   and #~WALKING                    ; mask out WALKING bit to assume flying
   ldx playerVertPos                ; get the player's vertical position
   cpx #SUPERMAN_WALKING_VERT_MAX   ; if greater then player is flying
   bcs .setSupermanState
   cpx #FLIGHT_SOUND_RANGE_05       ; check if player is flying
   bcc .setSupermanState
   ora #WALKING                     ; otherwise Superman is walking
.setSupermanState
   sta playerState
   ldx dataStructurePtr
   jmp .setPlayerGraphicPointers

SetPlayerPointersForFlying
   lda #DOUBLE_SIZE
   sta NUSIZ1
   ldx carriedObjectId              ; get id of object being carried
   cpx #<NullCharacterDS
   beq .skipPositionCarriedObject
   jsr SetPointersToObjectRoom
   lda playerCurrentRoom            ; get current room of player
   ldx #0
   sta (objectLocationPtr,x)        ; place object in same room as player
   ldy #<-8
   lda playerDirection
   and #$02
   beq .setCarriedObjectPosition
   ldy #16
.setCarriedObjectPosition
   sty tmpCarriedObjectHorizOffset
   lda playerHorizPos               ; get the player's horizontal position
   inc objectLocationPtr            ; now points to object horizontal position
   clc
   adc tmpCarriedObjectHorizOffset
   sta (objectLocationPtr,x)        ; set object's new horizontal position
   lda playerVertPos                ; get the player's vertical position
   inc objectLocationPtr            ; now points to object vertical position
   sta (objectLocationPtr,x)        ; set object's new vertical position
.skipPositionCarriedObject
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .checkForSupermanDecent      ; branch if player not moving
   lda gameTimerSeconds             ; get the timer seconds value (BCD)
   lsr                              ; divide value by 2
   ora gameTimerMinutes
   bne .skipSetSupermanToWalk
   lda #MY_NO_MOVE
   sta tempDirections
.checkForSupermanDecent
   lda INPT4                        ; read player 1 fire button
   and INPT5                        ; and with player 2 fire button value
   bpl .skipSetSupermanToWalk       ; branch if either fire button is pressed
   lda gameState                    ; get current game state
   beq .skipSetSupermanToWalk       ; branch if GAME OVER
   lda playerVertPos                ; get player's vertical position
   sec
   sbc #4                           ; subtract to make Superman decend
   sta playerVertPos
   cmp #FLIGHT_SOUND_RANGE_05   
   bmi .skipSetSupermanToWalk
   cmp #SUPERMAN_WALKING_VERT_MAX
   bpl .skipSetSupermanToWalk
   lda #WALKING                     ; Superman has landed--set to walking state
   ora playerState
   sta playerState
.skipSetSupermanToWalk
   ldx #<SupermanFly_0
   lda frameCount                   ; get the current frame count
   and #4
   beq .getSupermanFlyingColorLSB
   ldx #<SupermanFly_1
.getSupermanFlyingColorLSB
   ldy #<SupermanFlyingColors
.setPlayerGraphicPointers
   sty playerColorPtrs
   stx playerGraphicsPtrs
   ldy #SUPERMAN_MOVE_RATE
   lda playerState                  ; get current player state
   beq .setObjectLocationPointer    ; branch if FLYING
   ldy #CLARK_KENT_MOVE_RATE
.setObjectLocationPointer
   ldx #<playerLocation
   stx tempObjectLocationPtr
   lda INPT4                        ; read player 1 fire button
   and INPT5                        ; and with player 2 fire button value
   bmi .determinePlayersNewRoom     ; branch if neither fire button is pressed
   lda tempDirections               ; get the player's direction
   cmp #MY_NO_MOVE
   beq .determinePlayersNewRoom     ; branch if player not moving
   lda #<NullCharacter
   sta playerGraphicsPtrs
   rts

.determinePlayersNewRoom
   lda tempDirections               ; get the player's direction
   jmp DetermineObjectsNewRoom

CheckForXRayVision
   lda gameState                    ; get current game state
   beq .notUsingXRayVision          ; branch if GAME OVER
   lda INPT4                        ; read player 1 fire button
   and INPT5                        ; and with player 2 fire button value
   bpl .useXRayVision               ; branch if either fire button is pressed
.notUsingXRayVision
   jmp DetermineObjectsToDisplay

.useXRayVision
   jsr CheckForJoystickMovement     ; check the joystick movement
   cmp #MY_NO_MOVE                  ; if player not looking at a direction
   beq .notUsingXRayVision          ; then don't do x-ray vision
   lda playerCurrentRoom            ; get current room of player
   sta tempPlayerCurrentRoom        ; save it for later
   lda #<NullCharacter              ; point player graphics to the NULL
   sta playerGraphicsPtrs           ; character so not shown in x-ray vision
   lda tempDirections               ; get the player's direction
   ldx #4
.checkNextDirection
   dex
   lsr                              ; move D0 into carry
   bcs .checkNextDirection          ; not looking in direction if carry set
   lda RoomListDirectionOffset,x    ; get direction offset for x-ray vision
   clc                              ; may not be needed carry should be clear
   adc playerCurrentRoom            ; add the offset by the current room
   tax                              ; to get adjacent room for x-ray vision
   lda RoomListDataStructure,x      ; read adjacent room number
   sta playerCurrentRoom            ; set current room number to adjacent room
   jsr DetermineObjectsToDisplay
   lda tempPlayerCurrentRoom        ; recall player current room number
   sta playerCurrentRoom            ; restore original room number
   rts

DetermineObjectsToDisplay
   lda playerCurrentRoom            ; get current room of player
   sta dataStructurePtr
   sta nullCharacterScreen
   lda #>RoomListDataStructure
   sta dataStructurePtr + 1
   ldy #0                           ; set to point to room graphic information
   lda (dataStructurePtr),y         ; read LSB for room graphic info
   sta roomGraphicPtrs              ; set LSB for room graphics
   iny
   lda (dataStructurePtr),y         ; read MSB for room graphic info
   sta roomGraphicPtrs + 1          ; set MSB for room graphics
   iny
   lda (dataStructurePtr),y         ; read color for buildings (background)
   ldx gameState                    ; get current game state
   bne .setSkyColor                 ; branch if GAME ON
   and #$F7
.setSkyColor
   sta skyColor
   iny
   lda (dataStructurePtr),y         ; get color for sky (playfield)
   ldy gameState                    ; get current game state
   bne .setBackgroundColor          ; branch if GAME ON
   and #$F7
.setBackgroundColor
   sta backgroundColor
   lda currentObjectId              ; get the current object being shown
   sta characterDataPts
   lda #>ObjectListDataStructure
   sta characterDataPts + 1
   ldx #21
.flickerSortLoop
   ldy #0
   lda characterDataPts             ; get the LSB for the character data
   clc
   adc #6                           ; increase by 6 to point to new character
   cmp #<NullCharacterDS            ; see if we are done with all characters
   bcs .setCurrentChracterData
   tay
.setCurrentChracterData
   sty characterDataPts
   ldy #4                           ; 4 is offset for object's room
   jsr SetObjectLocationPointers
   ldy #0
   lda (objectLocationPtr),y        ; get current object's room
   cmp playerCurrentRoom            ; see if in same room as player
   beq .showCharacter               ; if so then show the character this frame
   dex                              ; check for next character
   bpl .flickerSortLoop
   lda #<NullCharacterDS
   sta characterDataPts
.showCharacter
   lda characterDataPts
   sta currentObjectId              ; set the current object being shown
   ldy #0
   lda (characterDataPts),y         ; get graphic pointer for character
   sta characterGraphicPtrs         ; set so shown this frame
   iny
   lda (characterDataPts),y
   sta characterGraphicPtrs + 1
   iny
   lda (characterDataPts),y
   sta characterColorPtrs
   iny
   lda (characterDataPts),y
   sta characterColorPtrs + 1
   iny
   jsr SetObjectLocationPointers
   ldy #1
   lda (objectLocationPtr),y        ; get the object's horizontal position
   sta objectHorizPos
   iny
   lda (objectLocationPtr),y        ; get the object's vertical position
   sta objectVertPos                ; set vertical position of shown object
   ldy characterGraphicPtrs         ; get the current character graphics LSB
   ldx #<LoisWalk_1                 ; assume Lois Lane walk animation 1
   lda soundPriority                ; get sound priority value
   and #2                           ; keep touching Lois Lane value
   beq .objectAnimation             ; branch if not playing Lois Lane sound
   cpy #<LoisStationary             ; is current sprite stationary Lois Lane
   beq .setCharacterGraphicsLSB     ; branch to use Lois Lane walk animation 1
.objectAnimation
   lda frameCount                   ; get the current frame count
   and #8
   beq .doneObjectsToDisplay
   ldx #<LexLuther_1
   cpy #<LexLuther_0
   beq .setCharacterGraphicsLSB
   ldx #<Kryptonite_1
   cpy #<Kryptonite_0
   beq .setCharacterGraphicsLSB
   ldx #<Helicopter_1
   cpy #<Helicopter_0
   beq .setCharacterGraphicsLSB
   lda gameState                    ; get current game state
   beq .doneObjectsToDisplay        ; branch if GAME OVER
   ldx #<Gangster_1
   cpy #<Gangster_0
   beq .setCharacterGraphicsLSB
   cpy #<LoisStationary
   bne .doneObjectsToDisplay
   ldx #<LoisWalk_0
.setCharacterGraphicsLSB
   stx characterGraphicPtrs
.doneObjectsToDisplay
   rts

SetObjectLocationPointers
   lda (characterDataPts),y
   sta objectLocationPtr
   iny
   lda (characterDataPts),y
   sta objectLocationPtr + 1
   rts

DetermineObjectDirection
   lda #MY_NO_MOVE
   sta tempDirections               ; assume object will not move
   lda $00,y                        ; get object's room number
   cmp $00,x
   bne .doneDetermineObjectDirection; don't move if not in same room
   lda $00 + 1,y                    ; get object's horizontal position
   cmp $00 + 1,x
   bcc .setObjectToDownDirection
   beq .compareObjectsVertPositions ; branch if same horizontal position
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_LEFT                ; make object move left
   sta tempDirections
   jmp .compareObjectsVertPositions

.setObjectToDownDirection
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_DOWN
   sta tempDirections
.compareObjectsVertPositions
   lda $00 + 2,y                    ; get object's vertical position
   cmp $00 + 2,x
   bcc .setObjectToUpDirection
   beq .doneDetermineObjectDirection; branch if on same scan line
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_RIGHT               ; make object move right
   sta tempDirections
   jmp .doneDetermineObjectDirection

.setObjectToUpDirection
   lda tempDirections               ; get the player's direction
   and #MY_MOVE_UP
   sta tempDirections
.doneDetermineObjectDirection
   lda tempDirections               ; get the player's direction
   rts

DetermineIfGangsterInJail
   tax                              ; save eor'd indicator value to x
   and pf1GangsterIndicators        ; and with remaining gangster value
   sta pf1GangsterIndicators        ; mask out gangster -- assume in jail
   txa
   eor #$FF                         ; flip bits of indicator value
   ora pf1GangsterIndicators        ; or'd to represent gangster not in jail
   tax
   lda $00,y                        ; get room gangster is in
   cmp #<NullRoomDS
   beq .skipSetGangsterIndicators   ; branch if gangster in jail
   stx pf1GangsterIndicators        ; set to show gangster not in jail
.skipSetGangsterIndicators
DetermineObjectMoveRate
   lda #53                          ; not adjusted for PAL50
   cmp $00 + 2,y                    ; compare with object's vertical position
   bpl .skipSetObjectVertMax        ; branch if object below center
   sta $00 + 2,y                    ; set object's vertical position
.skipSetObjectVertMax
   sty tempObjectLocationPtr        ; save current object number
   lda $00,y                        ; get the object's screen
   ldx #4
.checkForSubwayEntrance
   cmp SubwayEntranceRooms,x        ; see if object in subway entrance room
   bne .checkForNextEntrance        ; if not then check for next entrance
   sta subwayScreen                 ; save subway entrance LSB
.checkForNextEntrance
   dex
   bpl .checkForSubwayEntrance
   lda SWCHB                        ; read the console switch values
   bmi .skipObjectSlowDown          ; branch if P1 difficulty set to PRO
   lsr objectMoveRate               ; slow down object move rate
.skipObjectSlowDown
   asl                              ; shift P0 difficulty to D7
   bmi SearchObjectMatrix           ; branch if P0 difficulty set to PRO
   lda playerState                  ; get current player state
   and #HIT_KRYPTONITE
   beq SearchObjectMatrix           ; branch if not hit kryptonite
   ldx playerCurrentRoom            ; get current room of player
   stx loisLaneScreen               ; place Lois Lane in same room as player
   lda #<nullCharacterScreen
   sta helicopterPickUpRAMPtr
SearchObjectMatrix
.searchMatrix
   ldy #0
   lda (objectMatrixPtrs),y         ; read comparison value from matrix
   tax                              ; move to x
   iny                              ; increment y to read next value
   lda (objectMatrixPtrs),y
   tay                              ; move to y
   lda $00,x                        ; read first object's screen
   cmp $00,y                        ; compare with second object's screen
   bne .traverseMatrixTree          ; branch if not in same room
   cpy matrixTableEndPoint
   bne .determineObjectNewDirection
.traverseMatrixTree
   inc objectMatrixPtrs             ; move down matrix tree to check next
   inc objectMatrixPtrs             ; object's
   ldy #0
   lda (objectMatrixPtrs),y         ; read matrix to see if we're done
   bne .searchMatrix                ; the end of the matrix tree holds a 0
   jsr RandomObjectDirection
   jmp .determineObjectNewRoom

.determineObjectNewDirection
   jsr DetermineObjectDirection
.determineObjectNewRoom
   ldx tempObjectLocationPtr        ; load x with current object number
   ldy objectMoveRate
   jmp DetermineObjectsNewRoom

RandomObjectDirection
   lda gameTimerSeconds             ; get the seconds timer for the game
   lsr                              ; shift D1 to carry
   lsr
   bcc .doneRandomObjectDirection
   lda random
   clc
   adc #13
   sta random
.doneRandomObjectDirection
   lda random
   rts

SetPointersToObjectRoom
   stx characterDataPts             ; set to point to object's data structure
   lda #>ObjectListDataStructure
   sta characterDataPts + 1
   ldy #4                           ; 4 is offset for object's room
   jsr SetObjectLocationPointers
   rts

ProcessHelicopterSprite
   lda objectSpawningTimer
   bpl .checkToReleaseCarriedObject
   lda #BRIDGE_PIECE_INIT_VERT_POS
   sta bridgePiece0VertPos          ; place the bridge pieces on the ground
   sta bridgePiece1VertPos
   sta bridgePiece2VertPos
.checkToReleaseCarriedObject
   lda helicopterPickUpRAMPtr       ; get pointer to helicpter carried item
   ldx carriedObjectId              ; get id of Superman carried object
   cmp ObjectListDataStructure + 4,x; see if same objects are being carried
   bne .incrementPickUpItemTimer
   lda #<nullCharacterLocation      ; make Helicopter release item so Superman
   sta helicopterPickUpRAMPtr       ; carries it now
.incrementPickUpItemTimer
   inc helicopterPickUpItemTimer    ; this is incremented every 3 frames
   lda helicopterPickUpItemTimer
   cmp #8
   bne MoveHelicopterSprite
   lda #0
   sta helicopterPickUpItemTimer    ; reset Helicopter pick up timer
MoveHelicopterSprite
   lda helicopterPickUpItemTimer
   cmp #8
   bcc .checkForNewHelicopterPickUpItem
   jsr RandomObjectDirection
   ldx #<helicopterLocation
   ldy #HELICOPTER_MOVE_RATE
   jsr DetermineObjectsNewRoom
   jmp .setHelicopterCarriedItemLocation

.checkForNewHelicopterPickUpItem
   lda #<helicopterLocation
   sta tempObjectLocationPtr
   lda #HELICOPTER_MOVE_RATE
   sta objectMoveRate
   lda #<HelicopterMatrix
   sta objectMatrixPtrs
   lda #>HelicopterMatrix
   sta objectMatrixPtrs + 1
   lda helicopterPickUpRAMPtr
   sta matrixTableEndPoint
   jsr SearchObjectMatrix
   ldy #0
   lda (objectMatrixPtrs),y
   beq .setHelicopterCarriedItemLocation
   ldy #1
   lda (objectMatrixPtrs),y
   tax
   lda $00,x                        ; get object's room number
   cmp helicopterScreen             ; compare it to helicopter's room number
   bne .setHelicopterCarriedItemLocation; branch if not in same room
   lda $00 + 1,x                    ; get object's horizontal position
   sec
   sbc helicopterHorizPos           ; subtract helicopter horizontal position
   clc
   adc #4
   and #%11111000
   bne .setHelicopterCarriedItemLocation; branch if delta greater than 7
   lda $00 + 2,x                    ; get object's vertical position
   sec
   sbc helicopterVertPos            ; subtract helicopter's vertical position
   clc
   adc #4
   and #%11111000
   bne .setHelicopterCarriedItemLocation; branch if delta greater than 7
   ldy helicopterPickUpRAMPtr
   lda $00 + 2,y                    ; get carried object's vertical position
   cmp #24
   bpl .helicopterPickUpNewItem
   lda #24
   sta $00 + 2,y                    ; place carried object on the ground
.helicopterPickUpNewItem
   stx helicopterPickUpRAMPtr       ; set new pickup item RAM pointer
   lda #16                          ; wait ~11 seconds before picking up
   sta helicopterPickUpItemTimer    ; a new item
.setHelicopterCarriedItemLocation
   ldx helicopterPickUpRAMPtr
   lda helicopterScreen             ; get helicopter's room number
   sta $00,x                        ; set carried object's new room number
   lda helicopterHorizPos           ; get helicopter's horizontal position
   sta $00 + 1,x                    ; set carried object's new horiz position
   lda helicopterVertPos            ; get helicopter's vertical position
   sec
   sbc #10                          ; subtract by 10 to be under helicopter
   sta $00 + 2,x                    ; set carried object's new vert position
   rts

Gangster5Matrix
   .byte <lexLutherScreen,<gangster5Screen
   .byte <gangster5Screen,<subwayScreen
   .byte <gangster5Screen,<kryptonite2Screen
   .byte <playerCurrentRoom,<gangster5Screen
   .byte 0

LoisLaneSprites
LoisStationary
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
LoisWalk_0
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X |
   .byte $99 ; |X..XX..X|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $28 ; |..X.X...|
   .byte $24 ; |..X..X..|
   .byte $6C ; |.XX.XX..|
   .byte $00 ; |........|
LoisWalk_1
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $99 ; |X..XX..X|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $1E ; |...XXXX.|
   .byte $12 ; |...X..X.|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|

KryptoniteSprites
Kryptonite_0
   .byte $01 ; |.......X|
   .byte $40 ; |.X......|
   .byte $04 ; |.....X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $20 ; |..X.....|
   .byte $02 ; |......X.|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
Kryptonite_1
   .byte $80 ; |X.......|
   .byte $02 ; |......X.|
   .byte $20 ; |..X.....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $01 ; |.......X|
   .byte $00 ; |........|

PhoneBooth
   .byte $FF ; |XXXXXXXX|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $FF ; |XXXXXXXX|
   .byte $81 ; |X......X|
   .byte $99 ; |X..XX..X|
   .byte $91 ; |X..X...X|
   .byte $91 ; |X..X...X|
   .byte $91 ; |X..X...X|
   .byte $99 ; |X..XX..X|
   .byte $81 ; |X......X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|

DailyPlanet
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $CF ; |XX..XXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $66 ; |.XX..XX.|
   .byte $2C ; |..X.XX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
SubwayEntrance
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $CB ; |XX..X.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|

Jail
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $00 ; |........|

BridgeSprites
BridgeComplete
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $C3 ; |XX....XX|
   .byte $81 ; |X......X|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
BridgePiece_0
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $09 ; |....X..X|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
BridgePiece_1
   .byte $90 ; |X..X....|
   .byte $A4 ; |X.X..X..|
   .byte $C3 ; |XX....XX|
   .byte $01 ; |.......X|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
BridgePiece_2
   .byte $80 ; |X.......|
   .byte $F0 ; |XXXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|

RoomListDirectionOffset
   .byte NORTH_ROOM_OFFSET, EAST_ROOM_OFFSET
   .byte WEST_ROOM_OFFSET, SOUTH_ROOM_OFFSET

SubwayEntranceRooms
   .byte <YellowSubwayEntranceDS, <PinkSubwayEntranceDS
   .byte <BlueSubwayEntranceDS, <GreenSubwayEntranceDS

InsideRooms
   .byte <InsideDailyPlanetDS
   .byte <YellowSubwayDS, <PinkSubwayDS
   .byte <BlueSubwayDS, <GreenSubwayDS

Gangster1Thru4Matrixes
Gangster4Matrix
   .byte <playerCurrentRoom, <gangster4Screen
   .byte <gangster4Screen, <subwayScreen
   .byte <gangster3Screen, <gangster4Screen
   .byte <gangster2Screen, <gangster4Screen
   .byte 0

Gangster3Matrix
   .byte <playerCurrentRoom, <gangster3Screen
   .byte <gangster3Screen, <subwayScreen
   .byte <gangster2Screen, <gangster3Screen
   .byte 0

Gangster2Matrix
   .byte <playerCurrentRoom, <gangster2Screen
   .byte <gangster2Screen, <subwayScreen
   .byte <gangster1Screen, <gangster2Screen
   .byte 0

Gangster1Matrix
   .byte <playerCurrentRoom ,<gangster1Screen
   .byte <gangster4Screen, <gangster1Screen
   .byte <gangster1Screen, <subwayScreen
   .byte <gangster1Screen, <kryptonite3Screen
   .byte 0

   IF COMPILE_REGION = PAL50
   
   .byte $B4, $CA                   ; usused...here to assemble to exact ROM
      
   ELSE
   
   .org ROM_BASE + 4096 - 4, 0
   
   ENDIF
   
   .word Start
   .word 0