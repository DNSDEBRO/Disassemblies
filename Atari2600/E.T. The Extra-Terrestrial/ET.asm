   LIST OFF
; ***  E . T.  T H E  E X T R A  -  T E R R E S T R I A L  ***
; Copyright 1982 Atari, Inc.
; Designer: Howard Scott Warshaw
; Artist:   Jerome Domurat

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 18, 2006
;
; *** 115 BYTES OF RAM USED 13 BYTES FREE
;
; NTSC ROM usage stats
; -------------------------------------------
; *** 25 BYTES OF ROM FREE IN BANK0
; *** 24 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 49 TOTAL BYTES FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; *** 23 BYTES OF ROM FREE IN BANK0
; *** 24 BYTES OF ROM FREE IN BANK1
; ===========================================
; *** 47 TOTAL BYTES FREE
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
;
; This is Howard Scott Warshaw's third game with Atari. It was conceived and
; developed in roughly 5 weeks! The licensing deal didn't complete until the
; end of July (in an interview Howard says July 25). Atari wanted this game
; for the Christmas season which meant Howard had to finish this game by
; September 1st!
;
; - Pits are arranged in the order of...
;     1) ID_FOUR_DIAMOND_PITS
;     2) ID_EIGHT_PITS
;     3) ID_ARROW_PITS
;     4) ID_WIDE_DIAMOND_PITS
; - Objects are never placed in the overlapping pits for ID_EIGHT_PITS
; - Playfield is a 2LK while sprites are a 1LK
; - PAL50 conversion adjusts E.T. movement and colors
; - It seems RAM locations $85 and $8B are not used

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
; F R A M E - T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 47
OVERSCAN_TIME           = 45

START_LANDING_TIMER     = 63        ; staring value for landing timer

FRACTIONAL_MOVEMENT_ET_RUNNING = <[(256 * 30) / FPS] + 1;~30 pixels / sec
FRACTIONAL_MOVEMENT_ET_WALKING = <[(256 * 15) / FPS] - 1;~15 pixels / sec
FRACTIONAL_MOVEMENT_FAST_HUMAN = <[(256 * 22) / FPS];~22 pixels / sec
FRACTIONAL_MOVEMENT_SLOW_HUMAN = <[(256 * 14) / FPS];~14 pixels / sec

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 78
OVERSCAN_TIME           = 72

START_LANDING_TIMER     = 57        ; staring value for landing timer

FRACTIONAL_MOVEMENT_ET_RUNNING = <[(256 * 30) / FPS] + 1;~30 pixels / sec
FRACTIONAL_MOVEMENT_ET_WALKING = <[(256 * 15) / FPS] - 1;~15 pixels / sec
FRACTIONAL_MOVEMENT_FAST_HUMAN = <[(256 * 22) / FPS] - 1;~22 pixels / sec
FRACTIONAL_MOVEMENT_SLOW_HUMAN = <[(256 * 14) / FPS] - 1;~14 pixels / sec

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

LT_RED                  = $20
RED                     = $30
ORANGE                  = $40
ORANGE_2                = ORANGE
RED_2                   = ORANGE
DK_PINK                 = $50
DK_BLUE                 = $70
BLUE                    = $80
LT_BLUE                 = $90
GREEN                   = $C0
GREEN_2                 = GREEN
DK_GREEN                = $D0
DK_GREEN_2              = DK_GREEN
LT_BROWN                = $E0
LT_BROWN_2              = LT_BROWN
BROWN                   = $F0
NTSC_BROWN              = BROWN

   ELSE
   
LT_RED                  = $20
LT_BROWN_2              = LT_RED
BROWN                   = LT_RED
GREEN_2                 = $30
RED                     = $40
RED_2                   = RED + 2
ORANGE                  = RED
LT_BROWN                = $50
DK_GREEN                = LT_BROWN
ORANGE_2                = $62
DK_BLUE                 = $70
DK_PINK                 = $80
LT_BLUE                 = $90
BLUE                    = $D0
DK_GREEN_2              = BLUE
GREEN                   = $E0
NTSC_BROWN              = $F0
   
   ENDIF

;===============================================================================
; T I A - M U S I C  C O N S T A N T S
;===============================================================================

SOUND_CHANNEL_SAW       = 1         ; sounds similar to a saw waveform
SOUND_CHANNEL_ENGINE    = 3         ; many games use this for an engine sound
SOUND_CHANNEL_SQUARE    = 4         ; a high pitched square waveform
SOUND_CHANNEL_BASS      = 6         ; fat bass sound
SOUND_CHANNEL_PITFALL   = 7         ; log sound in pitfall, low and buzzy
SOUND_CHANNEL_NOISE     = 8         ; white noise
SOUND_CHANNEL_LEAD      = 12        ; lower pitch square wave sound
SOUND_CHANNEL_BUZZ      = 15        ; atonal buzz, good for percussion

LEAD_F4_SHARP           = 13
LEAD_E4                 = 15
LEAD_D4_SHARP           = 16
LEAD_D4                 = 17
LEAD_C4_SHARP           = 18
LEAD_H3                 = 20
LEAD_A3                 = 23
LEAD_G3_SHARP           = 24
LEAD_F3_SHARP           = 27
LEAD_E3_2               = 31

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

BANK0TOP                = $1000
BANK1TOP                = $2000

BANK0_REORG             = $B000
BANK1_REORG             = $F000

BANK0STROBE             = $FFF8
BANK1STROBE             = $FFF9

LDA_ABS                 = $AD       ; instruction to LDA $XXXX
JMP_ABS                 = $4C       ; instruction for JMP $XXXX

XMIN                    = 0
XMAX                    = 119

ET_YMIN                 = 0
ET_YMAX                 = 58

OBJECT_IN_PIT_Y         = 50
OBJECT_IN_PIT_X         = 41

PIT_XMIN                = 32
PIT_XMAX                = 88

FBI_AGENT_VERT_MAX      = 48
ELLIOTT_VERT_MAX        = 52
SCIENTIST_VERT_MAX      = 48

FBI_AGENT_VERT_TARGET   = 15
ELLIOTT_VERT_TARGET     = 47
SCIENTIST_VERT_TARGET   = 15

FBI_AGENT_HORIZ_TARGET  = 28
ELLIOTT_HORIZ_TARGET    = 60
SCIENTIST_HORIZ_TARGET  = 94

H_ET_GRAPH              = 40        ; height of E.T. face for title screen
H_FONT                  = 8
H_FBIAGENT              = 28
H_ELLIOTT               = 22
H_SCIENTIST             = 28
H_PHONE_PIECES          = 10
H_FLOWER                = 14
H_MOTHERSHIP            = 32
H_YAR                   = 16
H_INDY                  = 20

MAX_GAME_SELECTION      = 3

MAX_ENERGY              = $99       ; maximum energy value (BCD)
MAX_HOLD_CANDY          = 9 << 4

INIT_NUM_TRIES          = 3         ; initial number of tries to get E.T. home
NUM_PHONE_PIECES        = 3

EXTEND_NECK_ENERGY_REDUCTION = $0019
FALLING_IN_PENALTY      = $0269     ; lose 269 energy units for falling pit
EAT_CANDY_ENERGY_INCREMENT = $0360  ; gain 360 energy units for eating candy

; screen id values
ID_FOUR_DIAMOND_PITS    = 0
ID_EIGHT_PITS           = 1
ID_ARROW_PITS           = 2
ID_WIDE_DIAMOND_PITS    = 3
ID_FOREST               = 4
ID_WASHINGTON_DC        = 5
ID_PIT                  = 6
ID_ET_HOME              = 7
ID_TITLE_SCREEN         = 8

; pit id values
ID_PIT_OUT_OF_RANGE     = -1

ID_TOP_DIAMOND_PIT      = 0
ID_LEFT_DIAMOND_PIT     = 1
ID_RIGHT_DIAMOND_PIT    = 2
ID_LOWER_DIAMOND_PIT    = 3

ID_TOP_EIGHT_PITS       = 4
ID_LEFT_EIGHT_PITS      = 5
ID_RIGHT_EIGHT_PIT      = 6
ID_BOTTOM_EIGHT_PIT     = 7

ID_TOP_LEFT_ARROW_PIT   = 8
ID_TOP_RIGHT_ARROW_PIT  = 9
ID_LOWER_LEFT_ARROW_PIT = 10
ID_LOWER_RIGHT_ARROW_PIT = 11

ID_UPPER_LEFT_WIDE_PIT  = 12
ID_UPPER_RIGHT_WIDE_PIT = 13
ID_LOWER_LEFT_WIDE_PIT  = 14
ID_LOWER_RIGHT_WIDE_PIT = 15

; object ids
ID_FBIAGENT             = 0
ID_ELLIOTT              = 1
ID_SCIENTIST            = 2
ID_H_PHONE_PIECE        = 3
ID_S_PHONE_PIECE        = 4
ID_W_PHONE_PIECE        = 5
ID_FLOWER               = 6
ID_MOTHERSHIP           = 7
ID_YAR_0                = 8
ID_YAR_1                = 9
ID_INDY                 = 10

; power zone indicator ids
ID_BLANK_ZONE           = 0
ID_WARP_LEFT_ZONE       = 1
ID_WARP_RIGHT_ZONE      = 2
ID_WARP_UP_ZONE         = 3
ID_WARP_DOWN_ZONE       = 4
ID_FIND_PHONE_ZONE      = 5
ID_EAT_CANDY_ZONE       = 6
ID_RETURN_HOME_ZONE     = 7
ID_CALL_ELLIOTT_ZONE    = 8
ID_CALL_SHIP_ZONE       = 9
ID_LANDING_ZONE         = 10
ID_PIT_ZONE             = 11
ID_FLOWER_ZONE          = 12

; candy status values
FOUR_DIAMOND_PITS_CANDY = %0001
EIGHT_PITS_CANDY        = %0010
ARROW_PITS_CANDY        = %0100
WIDE_DIAMOND_PITS_CANDY = %1000

SHOW_HSW_INITIALS_VALUE = $69       ; BCD value :-)

; player state values
ET_DEAD                 = %10000000
ELLIOTT_REVIVE_ET       = %01000000

; E.T. home Elliott movement values
MOVE_ELLIOTT_RIGHT      = %10000000

; collected candy scoring values
COLLECT_CANDY_SCORE_INC = %01000000
CLOSED_EATING_CANDY_ICON = %00000001

; E.T. motion values
ET_RUNNING              = %10000000
ET_CARRIED_BY_SCIENTIST = %01000000
ET_MOTION_MASK          = %00001111

; human attribute values
RETURN_HOME             = %10000000
MOTION_MASK             = %00001111

; fireResetStatus values
FIRE_BUTTON_HELD        = %10000000
RESET_SWITCH_HELD       = %01000000

; starting screen id values
SET_STARTING_SCREEN     = %10000000
STARTING_SCREEN_ID      = %00001111

; phone piece attribute values
ET_HAS_PHONE_PIECE      = %10000000
PHONE_PIECE_SCREEN_LOC  = %01000000
FBI_HAS_PHONE_PIECE     = %00100000
ELLIOTT_HAS_PHONE_PIECE = %00010000
PHONE_PIECE_PIT_NUMBER  = %00001111

; neck extension values
NECK_EXTENDED           = %10000000
NECK_DECENDING          = %01000000

; flower state values
FLOWER_REVIVED          = %10000000
FLOWER_REVIVE_ANIMATION = %00110000
FLOWER_PIT_NUMBER       = %00001111

; E.T. pit status values
FALLING_IN_PIT          = %10000000
LEVITATING              = %01000000
IN_PIT_BOTTOM           = %00100000

; mothership status values
MOTHERSHIP_PRESENT      = %10000000
ET_GOING_HOME           = %01000000
MOTHERSHIP_LEAVING      = %00000001

; Easter Egg sprite values
SHOW_YAR_SPRITE         = %10000000
SHOW_INDY_SPRITE        = %11000000

; sound data channel 0 values
PLAY_SOUND_CHANNEL0     = %10000000

; Easter Egg status values
DONE_EASTER_EGG_CHECK   = %10000000
DONE_EASTER_EGG_STEPS   = %00000111

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
currentScreenId         ds 1
frameCount              ds 1
secondTimer             ds 1        ; updates ~every second
temp                    ds 1
;--------------------------------------
tempNumberFonts         = temp
;--------------------------------------
powerZoneIndex          = temp
;--------------------------------------
loopCount               = temp
;--------------------------------------
tempJoystickValues      = temp
;--------------------------------------
humanETHorizDistRange   = temp
;--------------------------------------
pointsTensValue         = temp
;--------------------------------------
pointsHundredsValue     = temp
;--------------------------------------
energyIncTensValue      = temp
;--------------------------------------
energyIncHundredsValue  = temp
;--------------------------------------
humanDirectionIndex     = temp
;--------------------------------------
newHumanDirection       = temp
;--------------------------------------
totalCandyCollected     = temp
;--------------------------------------
tempPitNumber           = temp
tempCharHolder          ds 1
zp_Unused_01            ds 1
nextETGraphicData       ds 1
;--------------------------------------
energyDecTensValue      = nextETGraphicData
;--------------------------------------
energyDecHundredsValue  = energyDecTensValue
nextObjectGraphicData   ds 1
nextObjectColorData     ds 1
;--------------------------------------
displayKernelBankSwitch = loopCount
bankSwitchStrobe        = displayKernelBankSwitch + 1
bankSwitchABSJmp        = bankSwitchStrobe + 2
bankSwitchRoutinePtr    = bankSwitchABSJmp + 1
fireResetStatus         ds 1        ; hold when fire button and RESET held
soundDataChannel0       ds 1
unknown                 ds 1
currentSpriteHeight     ds 1
etHeight                ds 1
powerZoneColor          ds 1
timerColor              ds 1
telephoneColor          ds 1
etMotionValues          ds 1
etFractionalDelay       ds 1
humanFractionalDelay    ds 1
etNeckExtensionValues   ds 1
currentObjectHorizPos   ds 1
etHorizPos              ds 1
etHeartHorizPos         ds 1
phonePieceMapHorizPos   ds 1
candyHorizPos           ds 1
humanTargetHorizPos     ds 1
currentObjectVertPos    ds 1
etVertPos               ds 1
etHeartVertPos          ds 1
phonePieceMapVertPos    ds 1
candyVertPos            ds 1
humanTargetVertPos      ds 1
currentObjectId         ds 1
humanAttributes         ds 3
;--------------------------------------
fbiAttributes           = humanAttributes
elliottAttributes       = fbiAttributes + 1
scientistAttributes     = elliottAttributes + 1
objectScreenId          ds 3
;--------------------------------------
fbiScreenId             = objectScreenId
elliottScreenId         = fbiScreenId + 1
scientistScreenId       = elliottScreenId + 1
objectHorizPos          ds 3
;--------------------------------------
fbiAgentHorizPos        = objectHorizPos
elliottHorizPos         = fbiAgentHorizPos + 1
scientistHorizPos       = elliottHorizPos + 1
objectVertPos           ds 3
;--------------------------------------
fbiAgentVertPos         = objectVertPos
elliottVertPos          = fbiAgentVertPos + 1
scientistVertPos        = elliottVertPos + 1
objectGraphicPointers   ds 4
;--------------------------------------
objectGraphicPtrs_0     = objectGraphicPointers
objectGraphicPtrs_1     = objectGraphicPtrs_0 + 2
objectColorPointers     ds 4
;--------------------------------------
objectColorPtrs_0       = objectColorPointers
objectColorPtrs_1       = objectColorPtrs_0 + 2
etGraphicsPointers      ds 4
;--------------------------------------
etGraphicPointers0      = etGraphicsPointers
etGraphicPointers1      = etGraphicPointers0 + 2
playfieldGraphicPtrs    ds 4
;--------------------------------------
pf1GraphicPtrs          = playfieldGraphicPtrs
pf2GraphicPtrs          = pf1GraphicPtrs + 2
graphicPointers         ds 12
phonePieceAttributes    ds 3
;--------------------------------------
h_phonePieceAttribute   = phonePieceAttributes
s_phonePieceAttribute   = h_phonePieceAttribute + 1
w_phonePieceAttribute   = s_phonePieceAttribute + 1
powerZonePointer        ds 2
powerZoneIndicatorId    ds 1
shipLandingTimer        ds 1
candyStatus             ds 1
heldCandyPieces         ds 1
etEnergy                ds 2
etHMOVEValue            ds 1
holdETHorizPos          ds 1
holdETVertPos           ds 1
holdETScreenId          ds 1
etPitStatus             ds 1
currentPitNumber        ds 1
callHomeScreenId        ds 1
extraCandyPieces        ds 1
collectedCandyPieces    ds 1
collectedCandyScoring   ds 1
playerScore             ds 3
startingScreenId        ds 1
playerState             ds 1
gameState               ds 1
numberOfTries           ds 1
flowerState             ds 1
powerZoneLSBValues      ds 3
;--------------------------------------
powerZoneLSBValue_01    = powerZoneLSBValues
powerZoneLSBValue_02    = powerZoneLSBValue_01 + 1
powerZoneLSBValue_03    = powerZoneLSBValue_02 + 1
gameSelection           ds 1
mothershipStatus        ds 1
etAnimationIndex        ds 1
etHomeElliottMovement   ds 1
themeMusicNoteDelay     ds 1
themeMusicFreqIndex     ds 1
easterEggStatus         ds 1
programmerInitialFlag   ds 1
easterEggSpriteFlag     ds 1
artistInitialFlag       ds 1

   echo "***",(* - $80 - 1)d, "BYTES OF RAM USED", ($100 - * + 1)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E  (BANK 0)
;===============================================================================

   SEG Bank0
   .org BANK0TOP
   .rorg BANK0_REORG

   lda BANK0STROBE
   jmp Start

HorizPositionObjects
   ldx #<[RESBL - RESP0]
.moveObjectLoop
   sta WSYNC                        ; wait for next scan line
   lda currentObjectHorizPos,x      ; get object's horizontal position
   tay
   lda HMOVETable,y                 ; get fine motion/coarse position value
   sta HMP0,x                       ; set object's fine motion value
   and #$0F                         ; mask off fine motion value
   tay                              ; move coarse move value to y
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; set object's coarse position
   dex
   bpl .moveObjectLoop
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   pla                              ; pull E.T. horizontal position from stack
   sta etHorizPos
   tax
   lda HMOVETable,x
   sta etHMOVEValue                 ; set E.T. horizontal move value
   jmp JumpToDisplayKernel

SetScreenIdFromStartingScreen
   lda startingScreenId             ; get starting screen id
   bpl .skipScreenIdSet             ; branch if screen id already set
   and #<(~SET_STARTING_SCREEN)
   sta currentScreenId              ; set screen id from starting screen id
   jsr SetCurrentScreenData
   lsr startingScreenId             ; shift right to show value already set
.skipScreenIdSet
   bit mothershipStatus             ; check mothership status
   bmi .jmpToVerticalSync           ; branch if Mothership is present
   lda currentScreenId              ; get the current screen id
   cmp #ID_TITLE_SCREEN
   bne .checkForETHome              ; branch if not on the title screen
.jmpToVerticalSync
   jmp VerticalSync

.checkForETHome
   lda currentScreenId              ; get the current screen id
   cmp #ID_ET_HOME
   bne .checkForElliottToReviveET   ; branch if not on home (game done) screen
   jmp VerticalSync

.checkForElliottToReviveET
   bit playerState                  ; check the player state
   bpl .checkETNeckExtension        ; branch if E.T. is not dead
   bvc .checkETNeckExtension        ; branch if Elliott not reviving E.T.
   lda currentObjectId              ; get the current object id
   bpl .checkETNeckExtension        ; branch if current object still on screen
   ldx #ID_ELLIOTT
   stx currentObjectId              ; set current object id to Elliott
   jsr SetCurrentObjectData
   lda #<(MOVE_UP >> 4)
   sta elliottAttributes            ; set Elliott attributes to move up
   lda currentScreenId              ; get the current screen id
   sta elliottScreenId              ; place Elliott on the current screen
   lda #5
   sta elliottHorizPos
   sta elliottVertPos
.checkETNeckExtension
   bit etNeckExtensionValues        ; check neck extension value
   bpl CheckETPlayerCollisions      ; branch if E.T. neck not extended
.jmpToCheckForETOnPitScreen
   jmp CheckIfETOnPitScreen

CheckETPlayerCollisions
   bit CXPPMM                       ; check player to player collisions
   bpl .jmpToCheckForETOnPitScreen  ; branch if E.T. not collided with object
   ldx currentObjectId              ; get the current object id
   bpl .checkCollisionObjectNotInWell; branch if object not in a well
   jmp .checkCollisionObjectInWell

.checkCollisionObjectNotInWell
   lda humanAttributes,x            ; get the human attribute value
   bmi .jmpToCheckForETOnPitScreen  ; branch if returning home
   txa                              ; move current object id to accumulator
   bne .checkForScientistCollision  ; branch if not FBI Agent
   ldx #NUM_PHONE_PIECES - 1
.checkToTakePhoneOrCandy
   lda phonePieceAttributes,x       ; get phone piece attribute value
   bmi .fbiTakePhonePieceFromET     ; branch if E.T. took phone piece
   dex
   bpl .checkToTakePhoneOrCandy
   lda #$0A
   sta heldCandyPieces              ; clear carried candy from E.T.
   bne .setForFBITakingObjectSound  ; unconditional branch

.fbiTakePhonePieceFromET
   lda frameCount                   ; get the current frame count
   and #PHONE_PIECE_PIT_NUMBER
   ora #FBI_HAS_PHONE_PIECE
   sta phonePieceAttributes,x       ; set new location for phone piece
.setForFBITakingObjectSound
   lda #PLAY_SOUND_CHANNEL0 | $1C
   sta soundDataChannel0
   jmp .setHumanToReturnHome

.checkForScientistCollision
   cpx #ID_SCIENTIST
   bne .etCollidedWithElliott       ; branch if not collided with Scientist
   lda etMotionValues               ; get E.T. motion values
   ora #ET_CARRIED_BY_SCIENTIST     ; set E.T. motion value to show E.T.
   sta etMotionValues               ; carried by Scientist
   rol fbiAttributes                ; set FBI Agent to return home
   sec
   ror fbiAttributes
   rol elliottAttributes            ; set Elliott to return home
   sec
   ror elliottAttributes
   bne .setHumanToReturnHome        ; unconditional branch

.etCollidedWithElliott
   lda #PLAY_SOUND_CHANNEL0 | $0C
   sta soundDataChannel0
   bit playerState                  ; check the player state
   bpl .checkItemExchange           ; branch if E.T. is not dead
   ldy numberOfTries                ; get number of tries
   bpl .reviveET                    ; revive E.T. for another try
   rol gameState                    ; rotate game state left
   sec                              ; set carry and rotate value right to set
   ror gameState                    ; game loss state (i.e. D7 = 1)
   jsr SetCurrentScreenToETHome
   jmp VerticalSync

.reviveET
   dec numberOfTries                ; reduce number of tries
   ldx #$15
   ldy #$00
   jsr IncrementETEnergy            ; give E.T. 1500 units of energy
   sty currentSpriteHeight
   sty playerState                  ; reset player state
   dey                              ; y = -1
   sty currentObjectId
   sty elliottScreenId
   sty elliottAttributes
   bne .setHumanToReturnHome        ; unconditional branch

.checkItemExchange
   ldx #0
   lda #ELLIOTT_HAS_PHONE_PIECE
   bit h_phonePieceAttribute
   bne .giveElliottPhonePieceToET   ; branch if Elliott has H phone piece
   inx
   bit s_phonePieceAttribute
   bne .giveElliottPhonePieceToET   ; branch if Elliott has S phone piece
   inx
   bit w_phonePieceAttribute
   beq .giveCandyPiecesToElliott    ; branch if Elliott has no phone pieces
.giveElliottPhonePieceToET
   lda #ET_HAS_PHONE_PIECE
   sta phonePieceAttributes,x
   bne .setHumanToReturnHome        ; unconditional branch

.giveCandyPiecesToElliott
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   beq .setHumanToReturnHome        ; branch if no candy pieces collected
   clc
   adc collectedCandyPieces         ; increment collected candy pieces
   sta collectedCandyPieces
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   cmp #MAX_HOLD_CANDY              ; see if E.T. is holding maximum candy
   bcc .clearNumberHeldCandyPieces  ; clear held candy count if not
   ldx #NUM_PHONE_PIECES - 1
   lda #$F0
   bit w_phonePieceAttribute
   beq .givePhonePieceToElliott
   dex
   bit s_phonePieceAttribute
   beq .givePhonePieceToElliott
   dex
   bit h_phonePieceAttribute
   bne .clearNumberHeldCandyPieces
.givePhonePieceToElliott
   lda #ELLIOTT_HAS_PHONE_PIECE
   sta phonePieceAttributes,x
.clearNumberHeldCandyPieces
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   and #$0F                         ; mask to clear number of candy held
   sta heldCandyPieces
.setHumanToReturnHome
   ldx currentObjectId              ; get the current object id
   rol humanAttributes,x            ; shift human attribute left
   sec                              ; set carry and shift value right to set
   ror humanAttributes,x            ; RETURN_HOME flag (i.e. D7 = 1)
   bmi CheckIfETOnPitScreen         ; unconditional branch
   
.checkCollisionObjectInWell
   cpx #$80 | ID_FLOWER
   bcs CheckIfETOnPitScreen         ; branch if E.T. didn't pick up phone piece
   lda #PLAY_SOUND_CHANNEL0 | $0D
   sta soundDataChannel0
   txa                              ; move current object id to accumulator
   and #$0F                         ; mask pit value to keep object id
   sec
   sbc #3                           ; subtract value by 3
   tax
   cmp #3
   bcs CheckIfETOnPitScreen         ; branch if E.T. didn't pick up phone piece
   lda #ET_HAS_PHONE_PIECE
   sta phonePieceAttributes,x
   asl                              ; a = 0
   sta currentSpriteHeight
CheckIfETOnPitScreen
   lda currentScreenId              ; get the current screen id
   cmp #ID_FOREST
   bcc CheckETPitCollisions         ; branch if E.T. on a pit screen
.jmpToDetermineHumanDirection
   jmp DetermineHumanDirection

CheckETPitCollisions
   bit etMotionValues               ; check E.T. motion values
   bvs .jmpToDetermineHumanDirection; branch if E.T. carried by Scientist
   bit CXP1FB                       ; check E.T. and playfield collision
   bmi PlaceETInPit                 ; branch if E.T. collided with pit
   lda #0
   sta etPitStatus                  ; clear E.T. pit status flags
   beq .jmpToDetermineHumanDirection; unconditional branch

PlaceETInPit
   bit etNeckExtensionValues        ; check neck extension value
   bmi .jmpToDetermineHumanDirection; branch if E.T. neck extended
   lda etVertPos                    ; get E.T.'s vertical position
   sta holdETVertPos                ; save for when E.T. emerges from pit
   lda etHorizPos                   ; get E.T.'s horizontal position
   sta holdETHorizPos               ; save for when E.T. emerges from pit
   ldy #0
   ldx currentScreenId              ; get the current screen id
   stx holdETScreenId               ; save for when E.T. emerges from pit
   beq SetPitNumberForDiamondPits   ; branch if FOUR_DIAMOND_PITS
   dex
   beq SetPitNumberForEightPits     ; branch if EIGHT_PITS
   dex
   beq SetPitNumberForArrowPits     ; branch if ARROW_PITS
   ldx #ID_UPPER_LEFT_WIDE_PIT
   bne CalculateCurrentPitNumber    ; unconditional branch -- WIDE_DIAMOND_PITS

SetPitNumberForArrowPits
   ldx #ID_TOP_LEFT_ARROW_PIT
CalculateCurrentPitNumber
   stx tempPitNumber
   cmp #59                          ; compare E.T.'s horizontal position
   bcc .compareETVerticalPosition
   iny                              ; y = 1
.compareETVerticalPosition
   lda etVertPos                    ; get E.T.'s vertical position
   cmp #33
   bcc .combineTempPitNumber
   iny
   iny
.combineTempPitNumber
   tya
   ora tempPitNumber
   bne .setCurrentPitNumber         ; unconditional branch
   
SetPitNumberForDiamondPits
   cmp #41                          ; compare E.T.'s horizontal position
   bcs .etNotInPitOne
   lda #ID_LEFT_DIAMOND_PIT         ; show that E.T. is in pit number 1
   bne .setCurrentPitNumber         ; unconditional branch
   
.etNotInPitOne
   cmp #81                          ; compare E.T.'s horizontal position
   bcc .etNotInPitTwo
   lda #ID_RIGHT_DIAMOND_PIT        ; show that E.T. is in pit number 2
   bne .setCurrentPitNumber         ; unconditional branch
   
.etNotInPitTwo
   lda etVertPos                    ; get E.T.'s vertical position
   cmp #29
   lda #ID_TOP_DIAMOND_PIT
   bcc .setCurrentPitNumber         ; set E.T. to pit number 0
   lda #ID_LOWER_DIAMOND_PIT        ; show that E.T. is in pit number 3
   bne .setCurrentPitNumber         ; unconditional branch
   
SetPitNumberForEightPits
   ldx etVertPos                    ; get E.T.'s vertical position
   cpx #19
   bcc .checkForOutOfRangePit
   cpx #40
   bcc .checkHorizPosForPitNumber
   ldy #3
.checkForOutOfRangePit
   cmp #32                          ; compare E.T.'s horizontal position
   bcc .setToOutOfRangePitNumber
   cmp #96                          ; compare E.T.'s horizontal position
   bcs .setToOutOfRangePitNumber
.combineIndexForPitNumber
   tya
   ora #ID_TOP_EIGHT_PITS
   bne .setCurrentPitNumber         ; unconditional branch

.setToOutOfRangePitNumber
   lda #<ID_PIT_OUT_OF_RANGE
   bne .setCurrentPitNumber         ; unconditional branch

.checkHorizPosForPitNumber
   iny                              ; y = 1
   cmp #64                          ; compare E.T. horizontal position
   bcc .combineIndexForPitNumber
   iny                              ; y = 2
   bne .combineIndexForPitNumber    ; unconditional branch
   
.setCurrentPitNumber
   sta currentPitNumber
   lda #ID_PIT
   sta currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
DetermineHumanDirection
   lda frameCount                   ; get the current frame count
   and #3                           ; make value 0 <= a <= 3
   cmp #ID_SCIENTIST + 1
   beq CheckForETCollectingCandy    ; branch if out of human id range
   tax                              ; move object id to x
   lda objectScreenId,x             ; get the object's screen id
   bpl .multiplyScreenIdBy8         ; branch if human is active
   lda humanAttributes,x            ; get human attribute value
   bmi CheckForETCollectingCandy    ; branch if returning home
   lda #ID_WASHINGTON_DC
   jsr CheckForHumanOnScreen
   bcs CheckForETCollectingCandy    ; branch if human on WASHINGTON_DC screen
   sta objectScreenId,x             ; set object screen id to WASHINGTON_DC
   lda HumanTargetVertPosTable,x
   sta objectVertPos,x
   lda HumanTargetHorizPosTable,x
   sta objectHorizPos,x
   lda #<(MOVE_LEFT >> 4)
   sta humanAttributes,x            ; set human to move left
   lda #ID_WASHINGTON_DC
   cmp currentScreenId
   bne CheckForETCollectingCandy
   stx currentObjectId
   jsr SetCurrentObjectData
   jmp CheckForETCollectingCandy

.multiplyScreenIdBy8
   asl
   asl
   asl
   sta humanDirectionIndex
   lda humanAttributes,x            ; get human attribute value
   bpl .checkToChangeHumanDirection ; branch if not returning home
   lda #5
   clc
   bcc .setNewHumanDirection        ; unconditional branch

.checkToChangeHumanDirection
   lda currentScreenId              ; get the current screen id
   cmp #ID_PIT                      ; if on PIT or HOME or TITLE SCREEN then
   bcs CheckForETCollectingCandy    ; don't change human direction
.setNewHumanDirection
   adc humanDirectionIndex
   tay
   lda HumanDirectionTable,y
   bmi CheckForETCollectingCandy
   sta newHumanDirection
   lda humanAttributes,x            ; get human attribute value
   and #$F0                         ; clear current human direction
   ora newHumanDirection            ; or in new direction value
   sta humanAttributes,x            ; set new direction value
CheckForETCollectingCandy
   bit CXP1FB                       ; check E.T. collision with PF and BALL
   bvc .skipCandyCollection         ; branch if E.T. did not collect candy
   ldx currentScreenId              ; get the current screen id
   cpx #ID_FOREST
   bcs .skipCandyCollection         ; branch if E.T. not on a pit screen
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   cmp #MAX_HOLD_CANDY
   bcs .skipCandyCollection         ; branch if E.T. holding maximum candy
   adc #1 * 16                      ; increment held candy pieces by 1
   sta heldCandyPieces
   lda #PLAY_SOUND_CHANNEL0 | $1C
   sta soundDataChannel0
   lda #127                         ; set candy piece vertical position to be
   sta candyVertPos                 ; out of visual range
   lda CandyStatusMaskTable,x
   and candyStatus
   sta candyStatus
.skipCandyCollection
   lda secondTimer
   and #$0F
   bne CheckForETNeckExtension
   lda frameCount                   ; get the current frame count
   and #$3F
   cmp #23
   bne CheckForETNeckExtension
   lda candyStatus                  ; get candy status flag value
   and #$0F
   tax
   lda extraCandyPieces             ; get extra candy pieces value
   sec
   sbc ExtraCandyReductionTable,x
   bmi CheckForETNeckExtension
   sta extraCandyPieces
   lda #$0F
   ora candyStatus
   sta candyStatus
CheckForETNeckExtension
   bit etNeckExtensionValues        ; check neck extension value
   bmi .etNeckExtended              ; branch if E.T. neck extended
   jmp DeterminePitPowerZone

.etNeckExtended
   lda frameCount                   ; get the current frame count
   and #3
   bne .jmpToSetPhoneHiddenLocation
   bvc ExtendedETNeck               ; branch if extending E.T. neck 
   bit etPitStatus                  ; check E.T. pit status flags
   bvs .jmpToSetPhoneHiddenLocation ; branch if E.T. levitating
   dec etNeckExtensionValues
   lda etNeckExtensionValues
   and #7
   cmp #7
   beq .reduceETNeckExtension
   inc etVertPos                    ; move E.T. down 1 pixel
   bne .jmpToSetPhoneHiddenLocation ; unconditional branch
   
.reduceETNeckExtension
   lda #$00
   sta etNeckExtensionValues        ; clear neck extension value
   inc etVertPos                    ; move E.T. down 1 pixel
   ldx #NUM_PHONE_PIECES - 1
.clearHiddenPhonePieceLoc
   lda phonePieceAttributes,x       ; get phone piece attribute value
   and #<(~PHONE_PIECE_SCREEN_LOC)  ; clear phone piece screen location bit to
   sta phonePieceAttributes,x       ; show phone not hidden (i.e. E.T. in pit)
   dex
   bpl .clearHiddenPhonePieceLoc
.jmpToSetPhoneHiddenLocation
   jmp SetPhonePieceHiddenLocation

ExtendedETNeck SUBROUTINE
   inc etNeckExtensionValues
   lda etNeckExtensionValues
   and #7
   cmp #4
   bcs ETNeckExtendedToMax
   lda etVertPos                    ; get E.T.'s vertical position
   beq .jmpToSetPhoneHiddenLocation ; branch if E.T. out of the pit
   dec etVertPos                    ; move E.T. up 1 pixel
.jmpToSetPhoneHiddenLocation
   jmp SetPhonePieceHiddenLocation

ETNeckExtendedToMax
   lda #NECK_EXTENDED | NECK_DECENDING | 3
   sta etNeckExtensionValues        ; set E.T. neck to decend
   ldx #EXTEND_NECK_ENERGY_REDUCTION >> 8
   ldy #EXTEND_NECK_ENERGY_REDUCTION & $FF
   jsr DecrementETEnergy            ; reduce E.T. energy by 19 units
   ldy currentScreenId              ; get the current screen id
   lda powerZoneIndicatorId         ; get the power zone id
   asl                              ; multiply value by 2
   tax
   lda PowerZoneJumpTable + 1,x
   pha
   lda PowerZoneJumpTable,x
   pha
   lda gameSelection                ; get the current game selection
   cmp #2
   bcs .jumpToPowerZone
   lda scientistScreenId            ; get the Scientist's screen id
   bpl .jumpToPowerZone             ; branch if Scientist not at home
   rol scientistAttributes          ; rotate Scientist attribute left and
   clc                              ; clear carry and rotate right to clear
   ror scientistAttributes          ; RETURN_HOME flag (i.e. D7 = 0)
.jumpToPowerZone
   rts

ReviveFlower
   bit flowerState                  ; check the flower state
   bmi .setPhonePieceHiddenLocation ; branch if flower already revived
   inc numberOfTries                ; increment number of tries
   rol flowerState                  ; rotate flower state left
   sec                              ; set carry flag and rotate flower state
   ror flowerState                  ; right to set FLOWER_REVIVED state
   bmi .setPhonePieceHiddenLocation ; unconditional branch
   
LevitateETOutOfPit
   lda #LEVITATING
   sta etPitStatus                  ; set status to show E.T. levitating
   dec etVertPos                    ; move E.T. up two pixels
   dec etVertPos
.setPhonePieceHiddenLocation
   jmp SetPhonePieceHiddenLocation

DetermineHiddenPhonePiece
   ldx #NUM_PHONE_PIECES - 1
.hiddenPhonePieceLoop
   lda phonePieceAttributes,x       ; get phone piece attribute value
   and #<(~PHONE_PIECE_PIT_NUMBER)  ; mask PHONE_PIECE_PIT_NUMBER value
   bne .nextPhonePiece              ; branch if phone piece not hidden
   lda phonePieceAttributes,x       ; get phone piece attribute value
   and #PHONE_PIECE_PIT_NUMBER      ; keep PHONE_PIECE_PIT_NUMBER value
   lsr                              ; divide pit number value by 4
   lsr
   cmp currentScreenId              ; compare with current screen id value
   beq .setPhoneHiddenOnScreen      ; branch if phone piece hidden on screen
.nextPhonePiece
   dex
   bpl .hiddenPhonePieceLoop
.setHiddenPhonePieceLocation
   jmp SetPhonePieceHiddenLocation

.setPhoneHiddenOnScreen
   lda phonePieceAttributes,x       ; get phone piece attribute value
   ora #PHONE_PIECE_SCREEN_LOC      ; set value to show phone hidden on screen
   sta phonePieceAttributes,x
   bne .setHiddenPhonePieceLocation ; unconditional branch
   
WarpETRight
   lda RightScreenIdTable,y
   jmp .warpETToNewScreen

WarpETLeft
   lda LeftScreenIdTable,y
   jmp .warpETToNewScreen

WarpETUp
   lda UpperScreenIdTable,y
   jmp .warpETToNewScreen

WarpETDown
   lda LowerScreenIdTable,y
.warpETToNewScreen
   sta currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
   jmp SetPhonePieceHiddenLocation

ClearElliottReturnHomeFlag
   rol elliottAttributes            ; rotate Elliott attributes left
   clc                              ; clear carry and rotate Elliott attributes
   ror elliottAttributes            ; right to clear RETURN_HOME flag
   bpl SetPhonePieceHiddenLocation  ; unconditional branch
   
CallMothership
   ldx currentObjectId              ; get the current object id
   bmi .checkToStartShipLandingTimer; branch if current object returning home
   bit SWCHB                        ; check console switch values
   bvs SetPhonePieceHiddenLocation  ; branch if player 1 difficulty set to PRO
   cpx #ID_ELLIOTT
   bne SetPhonePieceHiddenLocation  ; branch if current object is not Elliott
.checkToStartShipLandingTimer
   lda shipLandingTimer             ; get timer value for ship landing
   bpl SetPhonePieceHiddenLocation  ; branch if landing timer already started
   bit h_phonePieceAttribute        ; check H phone piece value
   bpl SetPhonePieceHiddenLocation  ; branch if E.T. not taken H phone piece
   bit s_phonePieceAttribute        ; check S phone piece value
   bpl SetPhonePieceHiddenLocation  ; branch if E.T. not taken S phone piece
   bit w_phonePieceAttribute        ; check W phone piece value
   bpl SetPhonePieceHiddenLocation  ; branch if E.T. not taken W phone piece
   lda #PLAY_SOUND_CHANNEL0 | $0C
   sta soundDataChannel0
   lda #START_LANDING_TIMER
   sta shipLandingTimer             ; set ship landing timer value
   lda #RETURN_HOME | P1_NO_MOVE
   sta fbiAttributes                ; set all human objects to return home and
   sta elliottAttributes            ; don't move
   sta scientistAttributes
   bne SetPhonePieceHiddenLocation  ; unconditional branch
   
ReturnCurrentHumanHome
   ldx currentObjectId              ; get the current object id
   bmi SetPhonePieceHiddenLocation  ; branch if human set to return home
   rol humanAttributes,x            ; rotate human attribute value left
   sec                              ; set carry and rotate value right to set
   ror humanAttributes,x            ; RETURN_HOME flag (i.e. D7 = 1)
   bmi SetPhonePieceHiddenLocation  ; unconditional branch
   
EatCandyPiece
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   sec
   sbc #1 * 16                      ; reduce number of candy pieces held by 1
   bcc SetPhonePieceHiddenLocation
   sta heldCandyPieces
   ldx #EAT_CANDY_ENERGY_INCREMENT >> 8
   ldy #EAT_CANDY_ENERGY_INCREMENT & $FF
   jsr IncrementETEnergy            ; increment energy by 360 units
SetPhonePieceHiddenLocation
   ldx #NUM_PHONE_PIECES - 1
   bit w_phonePieceAttribute        ; check W phone piece value
   bvs .setHiddenPhonePiecePosition ; branch if W phone piece present on screen
   dex
   bit s_phonePieceAttribute        ; check S phone piece
   bvs .setHiddenPhonePiecePosition ; branch if S phone piece present on screen
   dex
   bit h_phonePieceAttribute        ; check H phone piece
   bvc .turnOffHiddentPhonePiece    ; branch if H phone piece not on screen
.setHiddenPhonePiecePosition
   lda phonePieceAttributes,x       ; get the phone piece attribute value
   and #PHONE_PIECE_PIT_NUMBER      ; mask bits to keep pit number
   tay
   lda PhonePiecePitHorizPosition,y ; get phone piece pit horizontal position
   sta phonePieceMapHorizPos
   ldx PhonePiecePitVertPosition,y  ; get phone piece pit vertical position
   lda frameCount                   ; get the current frame count
   ror                              ; move D2 of frame count to carry
   ror                              ; flash hidden phone piece every 8 frames
   ror
   bcc .setHiddenPhonePieceVertPos
.turnOffHiddentPhonePiece
   ldx #127
.setHiddenPhonePieceVertPos
   stx phonePieceMapVertPos
   lda powerZoneIndicatorId         ; get current power zone id
   jmp .setPowerZoneGraphicPtrLSB

DeterminePitPowerZone
   lda currentScreenId              ; get the current screen id
   cmp #ID_PIT
   bne DetermineCurrentPowerZone    ; branch if E.T. not in pit
   lda currentObjectId              ; get the current object id
   cmp #$80 | ID_FLOWER
   bne .setPowerZoneToPitZone       ; branch if the flower not present
   lda etHorizPos                   ; get E.T.'s horizontal position
   sbc currentObjectHorizPos        ; subtract flower horizontal position
   cmp #16
   bcs .setPowerZoneToPitZone
   lda #ID_FLOWER_ZONE
   bne .setPowerZoneIndicatorId     ; set power zone to flower zone

.setPowerZoneToPitZone
   lda #ID_PIT_ZONE
   bne .setPowerZoneIndicatorId     ; unconditional branch

DetermineCurrentPowerZone
   lda etHorizPos                   ; get E.T.'s horizontal position
   lsr                              ; divide horizontal value by 8
   lsr
   lsr
   and #$0C                         ; a = 0 || a = 4 || a = 8 || a = 12
   sta powerZoneIndex
   lda etVertPos                    ; get E.T.'s vertical position
   lsr                              ; divide vertical value by 16 (i.e. move
   lsr                              ; upper nybble to lower nybble)
   lsr
   lsr
   ora powerZoneIndex               ; increase value for index pointer
   lsr                              ; divide value by 2 (i.e. 0 <= x <= 7)
   tay
   lda (powerZonePointer),y
   bcc .checkForValidFindPhoneZone  ; branch if index value was even
   lsr                              ; shift upper nybble to lower nybble
   lsr
   lsr
   lsr
.checkForValidFindPhoneZone
   and #$0F
   cmp #ID_FIND_PHONE_ZONE
   bne .checkForValidCallElliottZone
   ldx currentScreenId              ; get the current screen id
   cpx #ID_FOREST
   bcs .setPowerZoneToBlankZone     ; set power zone to blank if in forest
.checkForValidCallElliottZone
   cmp #ID_CALL_ELLIOTT_ZONE
   bne .checkForValidLandingZone
   ldx #ID_FOREST
   cpx currentScreenId
   beq .setPowerZoneToBlankZone     ; set power zone to blank if in forest
.checkForValidLandingZone
   cmp #ID_LANDING_ZONE
   bne .checkForValidCallShipZone
   ldx #ID_FOREST
   cpx currentScreenId
   bne .setPowerZoneToBlankZone     ; set power zone to blank if not in forest
.checkForValidCallShipZone
   cmp #ID_CALL_SHIP_ZONE
   bne .setPowerZoneIndicatorId
   ldx callHomeScreenId
   cpx currentScreenId
   beq .setPowerZoneIndicatorId     ; set power zone if on call home screen
.setPowerZoneToBlankZone
   lda #ID_BLANK_ZONE
.setPowerZoneIndicatorId
   sta powerZoneIndicatorId
.setPowerZoneGraphicPtrLSB
   asl                              ; multiply power zone indicator value by 8
   asl                              ; (height of Power Zone sprites) to set
   asl                              ; graphic pointer LSB
   sta graphicPointers
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
StartNewFrame
   lda #START_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; start vertical sync (D1 = 1)
   inc frameCount                   ; increment frame count each new frame
   bne .firstLineOfVerticalSync
   bit playerState                  ; check player state
   bmi .firstLineOfVerticalSync     ; branch if E.T. dead
   lda gameSelection                ; get the current game selection
   cmp #MAX_GAME_SELECTION
   bcs .firstLineOfVerticalSync
   lda fbiScreenId                  ; get FBI Agent screen id
   bpl .firstLineOfVerticalSync     ; branch if FBI Agent active
   bit etMotionValues               ; check E.T. motion values
   bvs .firstLineOfVerticalSync     ; branch if E.T. carried by Scientist
   lda #P1_NO_MOVE
   sta fbiAttributes                ; set FBI Agent not to move
.firstLineOfVerticalSync
   sta WSYNC
   lda #$3F
   and frameCount
   bne .secondLineOfVerticalSync
   inc secondTimer                  ; increment ~every second (i.e 63 frames)
   lda SWCHB                        ; read console switches
   and #SELECT_MASK
   bne .secondLineOfVerticalSync    ; branch if SELECT not pressed
   ldx gameSelection                ; get the current game selection
   inx                              ; increment game selection
   cpx #MAX_GAME_SELECTION + 1      ; see if game selection should wrap
   bcc .setGameSelection
   ldx #1                           ; set game selection to 1
.setGameSelection
   stx gameSelection
.secondLineOfVerticalSync
   sta WSYNC
   lda currentScreenId              ; get the current screen id
   cmp #ID_TITLE_SCREEN
   bne .endVerticalSync             ; branch if not on TITLE_SCREEN
   lda #24
   sta currentObjectHorizPos
   lda #65
   sta etHorizPos
   lda #58
   sta etHeartHorizPos
   lda #95
   sta phonePieceMapHorizPos
.endVerticalSync
   lda #STOP_VERT_SYNC
   ldx #VBLANK_TIME
   sta WSYNC                        ; last line of vertical sync
   sta VSYNC                        ; end vertical sync (D1 = 0)
   stx TIM64T                       ; set timer for vertical blanking period
   bit mothershipStatus             ; check mothership status
   bpl .checkToPlayThemeForTitleScreen; branch if mothership not present
   jmp DetermineObjectToMove

.checkToPlayThemeForTitleScreen
   lda currentScreenId              ; get the current screen id
   cmp #ID_TITLE_SCREEN
   beq PlayThemeMusic               ; branch if on TITLE_SCREEN
   bit playerState                  ; check player state
   bpl CheckToPlayETFallingSound    ; branch if E.T. not dead
   ldx currentObjectId              ; get the current object id
   dex
   bne CheckToPlayETFallingSound    ; branch if current object is not Elliott
PlayThemeMusic
   lda #7
   sta AUDV1
   lda #SOUND_CHANNEL_LEAD
   sta AUDC1
   ldx themeMusicNoteDelay          ; get theme music note delay value
   dex
   bpl .playCurrentThemeNote        ; hold note if not negative
   ldx #11                          ; initial hold note delay
   ldy themeMusicFreqIndex          ; get theme music frequency index
   iny                              ; increment frequency index
   cpy #55
   bcc .setThemeMusicFreqIndex
   ldy #0
.setThemeMusicFreqIndex
   sty themeMusicFreqIndex
.playCurrentThemeNote
   stx themeMusicNoteDelay
   ldy themeMusicFreqIndex
   lda ThemeMusicFrequencyTable,y
   sta AUDF1
   lda #0
   sta AUDV0
   jmp .donePlayingSoundChannel1

CheckToPlayETFallingSound
   bit etPitStatus                  ; check E.T. pit value
   bpl CheckToPlayETLevitationSound ; branch if E.T. not falling in pit
   lda #SOUND_CHANNEL_SQUARE + 1
   sta AUDC1
   asl                              ; multiple value by 2 to set volume
   sta AUDV1
   lda etVertPos                    ; get E.T.'s vertical position
   lsr                              ; divide value by 2 to set frequency
   sta AUDF1
   bne .donePlayingSoundChannel1    ; unconditional branch
   
CheckToPlayETLevitationSound
   bvc CheckToPlayNeckExtensionSound; branch if E.T. not levitating
   lda etEnergy + 1
   and #$0F
   bne .turnOffETWalkingSound
   lda #4
   sta AUDV1
   lda #$1C
   bne .setSoundChannel1AndFrequency; unconditional branch

CheckToPlayNeckExtensionSound
   lda etNeckExtensionValues        ; get neck extension value
   bpl PlayETWalkingSound           ; branch if E.T. neck not extended
   sec
   rol
   sec
   rol
   sta AUDV1
   lda #$0E
   bne .setSoundChannel1AndFrequency; unconditional branch

PlayETWalkingSound
   lda SWCHA                        ; read joystick values
   cmp #P0_NO_MOVE
   bcs .turnOffETWalkingSound
   bit etMotionValues               ; check E.T. motion values
   bpl .playETWalkingSound          ; branch if E.T. not running
   lda frameCount                   ; get the current frame count
   lsr                              ; divide value by 4
   lsr
   and #7
   sta AUDF1
   lda #SOUND_CHANNEL_SQUARE + 1
   sta AUDC1
   lda #7
   sta AUDV1
   bne .donePlayingSoundChannel1    ; unconditional branch

.playETWalkingSound
   lda frameCount                   ; get the current frame count
   and #7
   bne .turnOffETWalkingSound
   lda frameCount                   ; get the current frame count
   lsr                              ; divide value by 8
   lsr
   lsr
   and #3
   beq .turnOffETWalkingSound
   ldx #7
   stx AUDV1
   adc #$16
   bne .setSoundChannel1AndFrequency

.turnOffETWalkingSound
   lda #0
   sta AUDV1
.setSoundChannel1AndFrequency
   sta AUDC1
   sta AUDF1
.donePlayingSoundChannel1
   lda currentScreenId              ; get the current screen id
   cmp #ID_ET_HOME
   bne .checkIfOnTitleScreen
   jmp SetSpecialSpriteForPit

.checkIfOnTitleScreen
   cmp #ID_TITLE_SCREEN
   bne CheckForTimeToLandMothership
   jmp SetCurrentObjectXYCoordinates

CheckForTimeToLandMothership
   lda shipLandingTimer             ; get ship landing timer value
   bpl .reduceLandingTimerValue     ; branch if timer set for count down
   lda #<BlankIcon
   sta graphicPointers + 2
   beq MoveET                       ; unconditional branch

.reduceLandingTimerValue
   lda frameCount                   ; get the current frame count
   and #$1F
   bne SetCountdownClockSpriteLSB
   dec shipLandingTimer             ; decrement ship landing timer
   bpl PlayShipLandingTimerSound
   lda #<BlankIcon
   sta graphicPointers + 2          ; clear landing timer icon
   lda powerZoneIndicatorId         ; get power zone indicator id
   cmp #ID_LANDING_ZONE
   bne .dontLandMothership          ; branch if E.T. not in landing zone
   lda currentObjectId              ; get the current object id
   bmi .landMothership
   bit SWCHB                        ; check console switch values
   bvs .dontLandMothership          ; branch if player 1 difficulty set to PRO
   cmp #ID_ELLIOTT                  ; don't land Mothership if present human
   bne .dontLandMothership          ; is not Elliott
.landMothership
   lda #PLAY_SOUND_CHANNEL0 | $0D
   sta soundDataChannel0
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   lsr                              ; shift upper nybbles to lower nybble
   lsr
   lsr
   lsr
   clc
   adc collectedCandyPieces         ; add in number of candy held by Elliott
   sta totalCandyCollected          ; save total candy pieces collected
   lsr                              ; divide value by 2
   clc                              ; add collected candy value back in so
   adc totalCandyCollected          ; value is multiplied by 1.5
   cmp #16
   bcs .setExtraCandyPiecesValue
   lda #16
.setExtraCandyPiecesValue
   sta extraCandyPieces
   ldx #ID_MOTHERSHIP
   jsr SetCurrentObjectData         ; set current object to the MOTHERSHIP
   lda #240
   sta currentObjectVertPos         ; set Mothership's vertical position
   lda etHorizPos                   ; get E.T.'s horizontal position
   sec
   sbc #5
   bpl .setMothershipHorizPos
   lda #0
.setMothershipHorizPos
   sta currentObjectHorizPos
   lda #MOTHERSHIP_PRESENT | ET_GOING_HOME
   sta mothershipStatus
   jmp DetermineObjectToMove

.dontLandMothership
   lda #PLAY_SOUND_CHANNEL0 | $1F
   sta soundDataChannel0
   bne MoveET                       ; unconditional branch

PlayShipLandingTimerSound
   lda shipLandingTimer             ; get timer value for ship landing
   ldx #PLAY_SOUND_CHANNEL0 | $04
   cmp #7
   bcc .setSoundDataChannel0
   and #7
   cmp #7
   bne SetCountdownClockSpriteLSB
   ldx #PLAY_SOUND_CHANNEL0 | $0C
.setSoundDataChannel0
   stx soundDataChannel0
SetCountdownClockSpriteLSB
   lda shipLandingTimer             ; get timer value for ship landing
   cmp #8
   bcs .setCountdownClockLSB
   asl                              ; multiply by 8 to speed up timer icon
   asl
   asl
.setCountdownClockLSB
   and #$38
   clc
   adc #<CountdownClockIcons
   sta graphicPointers + 2
MoveET
   lda SWCHA                        ; read joystick values
   lsr                              ; shift player 1 joystick values to
   lsr                              ; lower nybbles
   lsr
   lsr
   sta tempJoystickValues
   lda etMotionValues               ; get E.T. motion values
   and #<(~ET_MOTION_MASK)
   ora tempJoystickValues
   sta etMotionValues               ; set new E.T. joystick direction
   bit playerState                  ; check current player state
   bmi .checkETMotion               ; branch if E.T. dead
   bit INPT4                        ; check player one fire button
   bmi .clearETRunningStatus        ; branch if fire button not pressed
   lda fireResetStatus              ; check to see if fire button held
   bmi .checkETMotion               ; branch if fire button held
   ora #FIRE_BUTTON_HELD
   sta fireResetStatus              ; set status to show fire button held
   lda SWCHA                        ; read joystick values
   cmp #P0_NO_MOVE
   bcs .skipSetETRunningFlag        ; branch if joystick not moved
   rol etMotionValues               ; rotate E.T. motion values left
   sec                              ; set carry and rotate value right to show
   ror etMotionValues               ; E.T. is running (i.e. D7 = 1)
   bne .checkETMotion               ; unconditional branch

.skipSetETRunningFlag
   bit etMotionValues               ; check E.T. motion values
   bvs .checkETMotion               ; branch if E.T. carried by Scientist
   bit etNeckExtensionValues        ; check neck extension value
   bmi .checkETMotion               ; branch if E.T. neck extended
   dec etVertPos                    ; move E.T. up 1 pixel
   bpl .setETNeckExtendedValue
   inc etVertPos                    ; move E.T. down 1 pixel
.setETNeckExtendedValue
   lda #NECK_EXTENDED
   sta etNeckExtensionValues        ; set to show E.T. neck extended
   bne .checkETMotion               ; unconditional branch

.clearETRunningStatus
   rol fireResetStatus              ; rotate fire button held status to carry
   clc                              ; clear carry and rotate value right to
   ror fireResetStatus              ; clear fire button held status
   rol etMotionValues               ; rotate E.T. motion value left
   clc                              ; clear carry and rotate value right to
   ror etMotionValues               ; set E.T. not running (i.e. D7 = 0)
.checkETMotion
   bit etMotionValues               ; check E.T. motion values
   bvc CheckToRestrictETMovementInPit; branch if E.T. not carried Scientist
   lda scientistScreenId            ; get the Scientist screen id
   cmp currentScreenId              ; compare with current screen id
   beq .setETLocationToCurrentObject
   bit etMotionValues               ; check E.T. motion values
   bpl .setCurrentScreenId          ; branch if E.T. not running
   lda etMotionValues               ; get E.T. motion values
   and #<(~ET_CARRIED_BY_SCIENTIST)
   sta etMotionValues               ; release E.T. from Scientist 
   bne .jmpToCheckToMoveET          ; unconditional branch
   
.setCurrentScreenId
   sta currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
.setETLocationToCurrentObject
   lda currentObjectVertPos         ; get current object vertical position
   sta etVertPos                    ; set E.T. vertical position
   lda currentObjectHorizPos        ; get current object horizontal position
   sta etHorizPos                   ; set E.T. horizontal position
.jmpToCheckToMoveET
   jmp CheckIfOkayToMoveET

CheckToRestrictETMovementInPit
   lda etPitStatus                  ; get E.T. pit status values
   bne .restrictETMovement          ; branch if E.T. is in a pit
   bit etNeckExtensionValues        ; check neck extension value
   bpl .jmpToCheckToMoveET          ; branch if E.T. neck not extended
.restrictETMovement
   and #IN_PIT_BOTTOM
   beq CheckForETLevitatingInPit    ; branch if E.T. not reached pit bottom
   ldx etHorizPos                   ; get E.T.'s horizontal position
   lda etMotionValues               ; get E.T. motion values
   and #ET_MOTION_MASK
   ora #[~(MOVE_DOWN & MOVE_UP) >> 4] & 15;don't allow E.T. to move vertically
   cpx #PIT_XMIN                    ; compare E.T. horizontal position
   bcs .checkForPitXMAX
   ora #[(~MOVE_LEFT) >> 4] & 15    ; don't allow E.T. to move left
.checkForPitXMAX
   cpx #PIT_XMAX                    ; compare E.T. horizontal position
   bcc .setETPitMotionValue
   ora #[(~MOVE_RIGHT) >> 4] & 15   ; don't allow E.T. to move right
.setETPitMotionValue
   sta etMotionValues
   jmp CheckIfOkayToMoveET

CheckForETLevitatingInPit
   bit etPitStatus                  ; check E.T. pit values
   bvc ETFallingInPit               ; branch if E.T. not levitating
   lda frameCount                   ; get the current frame count
   and #7
   bne .skipEnergyDecrement
   ldx #$00
   ldy #$01
   jsr DecrementETEnergy            ; decrement energy by 1 unit
.skipEnergyDecrement
   lda currentScreenId              ; get the current screen id
   cmp #ID_FOREST
   bne CheckForETInPit              ; branch if E.T. not in the forest
   lda #0
   sta etPitStatus                  ; clear E.T. pit status flags
   jmp DetermineObjectToMove

CheckForETInPit
   cmp #ID_PIT
   bne CheckIfOkayToMoveET
   lda etVertPos                    ; get E.T.'s vertical position
   cmp #45
   bcc .checkIfETOutOfPit
   lda #IN_PIT_BOTTOM
   sta etPitStatus                  ; set flag to show E.T. at pit bottom
   bne .jmpToDetermineObjectToMove  ; unconditional branch

.checkIfETOutOfPit
   cmp #2                           ; compare E.T.'s vertical position
   bcs .restrictETHorizMovement
   lda holdETVertPos                ; get E.T. vertical position before falling
   sta etVertPos                    ; set E.T. vertical position
   lda holdETHorizPos               ; get E.T. horiz position before falling
   sta etHorizPos                   ; set E.T. horizontal position
   ldx holdETScreenId               ; get E.T. screen id before falling
   stx currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
.jmpToDetermineObjectToMove
   jmp DetermineObjectToMove

.restrictETHorizMovement
   lda etMotionValues               ; get E.T. motion value
   and #ET_MOTION_MASK
   ora #[~(MOVE_RIGHT & MOVE_LEFT) >> 4] & 15; don't allow E.T. to move horiz
   bne .setETPitMotionValue         ; unconditional branch

ETFallingInPit
   bpl .jmpToDetermineObjectToMove  ; branch if E.T. not falling
   ldx etVertPos                    ; get E.T.'s vertical position
   cpx #49
   bcs ETReachedPitBottom
   inc etVertPos
   bne .jmpToDetermineObjectToMove  ; unconditional branch
   
ETReachedPitBottom SUBROUTINE
   lda #PLAY_SOUND_CHANNEL0 | $1F
   sta soundDataChannel0
   ldx #FALLING_IN_PENALTY >> 8     ; reduce energy by 296 units for falling
   ldy #FALLING_IN_PENALTY & $FF    ; into pit 
   jsr DecrementETEnergy            
   lda #IN_PIT_BOTTOM
   sta etPitStatus                  ; set flag to show E.T. at pit bottom
.jmpToDetermineObjectToMove
   jmp DetermineObjectToMove

CheckIfOkayToMoveET
   bit playerState                  ; check player state
   bmi .jmpToDetermineObjectToMove  ; branch if E.T. is dead
   ldx #0
   lda etMotionValues               ; get E.T. motion value
   bpl .determineETFractionalDelay  ; branch if E.T. not running
   inx
.determineETFractionalDelay
   and #ET_MOTION_MASK
   cmp #$0F
   beq CheckToWrapETToAdjacentScreen; branch if E.T. not moving
   lda etFractionalDelay            ; get E.T. fractional delay value
   clc
   adc ETFrameDelayTable,x
   sta etFractionalDelay            ; set E.T. new fractional delay value
   bcc CheckToWrapETToAdjacentScreen; branch if not time to move E.T.
   lda etMotionValues               ; get E.T. motion value
   ldx #1                           ; move E.T.
   jsr ObjectDirectionCheck
   ldx #0
   ldy #1
   jsr DecrementETEnergy            ; reduce energy by 1 unit
   lda etPitStatus                  ; get E.T. pit value flags
   bne DetermineObjectToMove        ; branch if E.T. is in a pit
   lda etMotionValues               ; get E.T. motion value
   bpl CheckToWrapETToAdjacentScreen; branch if E.T. not running
   ldx #1                           ; move E.T. again because he's running
   jsr ObjectDirectionCheck
   ldx #0
   ldy #1
   jsr DecrementETEnergy            ; reduce energy by 1 unit
CheckToWrapETToAdjacentScreen
   ldx currentScreenId              ; get the current screen id
   lda etHorizPos                   ; get E.T.'s horizontal position
   cmp #XMAX + 1
   bcc CheckToWrapETVertically      ; branch if E.T. not on right screen border
   bpl CheckForETWrappingToRight
   lda LeftScreenIdHorizPosTable,x
   beq .setETVertPos                ; never branches -- value never 0
   sta etHorizPos                   ; set E.T. horizontal position
.setETVertPos
   lda LeftScreenIdVertPosTable,x
   beq .jmpToSetScreenIdToLeftScreen
   sta etVertPos                    ; set E.T. vertical position
.jmpToSetScreenIdToLeftScreen
   lda LeftScreenIdTable,x
   jmp SetCurrentScreenId

CheckForETWrappingToRight SUBROUTINE
   lda RightScreenIdHorizPosTable,x
   beq .setETVertPos
   sta etHorizPos                   ; set E.T. horizontal position
.setETVertPos
   lda RightScreenIdVertPosTable,x
   beq .jmpToSetScreenIdToRightScreen
   sta etVertPos                    ; set E.T. vertical position
.jmpToSetScreenIdToRightScreen
   lda RightScreenIdTable,x
   jmp SetCurrentScreenId

CheckToWrapETVertically SUBROUTINE
   lda etVertPos                    ; get E.T.'s vertical position
   cmp #59
   bcc DetermineObjectToMove
   bpl CheckForETWrappingDown
   lda UpperScreenIdHorizPosTable,x
   beq .setETVertPos
   sta etHorizPos                   ; set E.T. horizontal position
.setETVertPos
   lda UpperScreenIdVertPosTable,x
   beq .jmpToSetScreenIdToUpperScreen; never branches -- value never 0
   sta etVertPos                    ; set E.T. vertical position
.jmpToSetScreenIdToUpperScreen
   lda UpperScreenIdTable,x
   jmp SetCurrentScreenId

CheckForETWrappingDown SUBROUTINE
   lda LowerScreenIdHorizPosTable,x
   beq .setETVertPos
   sta etHorizPos                   ; set E.T. horizontal position
.setETVertPos
   lda LowerScreenIdVertPosTable,x
   beq .jmpToSetScreenIdToLowerScreen; never branches -- value never 0
   sta etVertPos                    ; set E.T. vertical position
.jmpToSetScreenIdToLowerScreen
   lda LowerScreenIdTable,x
SetCurrentScreenId
   sta currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
DetermineObjectToMove
   bit mothershipStatus             ; check Mothership status
   bmi CheckToLandMothership        ; branch if Mothership is present
   jmp DetermineToMoveHumans

CheckToLandMothership
   lda mothershipStatus             ; get Mothership status
   bvs .mothershipPickingUpET
   ror                              ; shift D0 to carry
   bcs .mothershipLeavingWithoutET  ; branch if Mothership leaving Earth
   lda frameCount                   ; get the current frame count
   and #3
   bne .playMothershipSound
   inc currentObjectVertPos         ; move Mothership down 1 pixel
   inc etVertPos                    ; move E.T. down 1 pixel
   lda currentObjectVertPos         ; get current object's vertical position
   bmi .playMothershipSound
   cmp #H_MOTHERSHIP
   bcc .playMothershipSound
   ror mothershipStatus             ; rotate Mothership status right
   sec                              ; set carry and rotate Mothership status
   rol mothershipStatus             ; left to set MOTHERSHIP_LEAVING status
.playMothershipSound
   jsr PlayMothershipSound
   lda frameCount                   ; get the current frame count
   and #7
   bne .doneLandMothership
   ldx objectColorPtrs_0
   inx
   cpx #<[MotherShipColors + 6]
   bcc .setMothershipColorPointer
   ldx #<MotherShipColors
.setMothershipColorPointer
   stx objectColorPtrs_0
.doneLandMothership
   jmp SetCurrentObjectXYCoordinates

.mothershipLeavingWithoutET
   dec currentObjectVertPos         ; move current object up 1 pixel
   lda currentObjectVertPos         ; get current object vertical position
   bpl .playMothershipSound
   cmp #240
   bcs .playMothershipSound
   lda #$00
   sta mothershipStatus             ; clear Mothership status flags
   sta graphicPointers + 2
   beq .doneLandMothership          ; unconditional branch

.mothershipPickingUpET
   ror                              ; shift D0 to carry
   bcs .etGoingHome                 ; branch if Mothership leaving Earth
   lda frameCount                   ; get the current frame count
   and #3
   bne .playMothershipSound
   inc currentObjectVertPos         ; move Mothership down 1 pixel
   lda #H_MOTHERSHIP * 2
   sec
   sbc currentObjectVertPos
   cmp #H_MOTHERSHIP / 2
   bcc .setMothershipHeightForLanding
   lda #H_MOTHERSHIP / 2
.setMothershipHeightForLanding
   sta currentSpriteHeight
   lda etVertPos                    ; get E.T.'s vertical position
   clc                              ; carry clear so SBC is A = A - M ~C
   sbc #4 - 1                       ; A = A - 4
   cmp currentObjectVertPos
   bne .playMothershipSound
   ror mothershipStatus             ; rotate Mothership status right
   sec                              ; set carry and rotate Mothership status
   rol mothershipStatus             ; left to set MOTHERSHIP_LEAVING status
   bne .playMothershipSound         ; unconditional branch
   
.etGoingHome
   dec etVertPos                    ; move E.T. up 1 pixel
   dec currentObjectVertPos         ; move current object up 1 pixel
   lda #H_MOTHERSHIP * 2
   sec
   sbc currentObjectVertPos
   cmp #H_MOTHERSHIP / 2
   bcc .setMothershipHeightForLeaving
   lda #H_MOTHERSHIP / 2
.setMothershipHeightForLeaving
   sta currentSpriteHeight
   lda currentObjectVertPos         ; get current object's vertical position
   bpl .playMothershipSound
   cmp #240
   bcs .playMothershipSound
   lda #$00
   sta mothershipStatus             ; clear Mothership status flags
   jsr SetCurrentScreenToETHome
   jmp SetCurrentObjectXYCoordinates

DetermineToMoveHumans
   lda etNeckExtensionValues        ; get neck extension value
   bmi .jmpToSetETGraphicPointers   ; branch if E.T. neck extended
   lda #FRACTIONAL_MOVEMENT_FAST_HUMAN;assume fast human
   bit SWCHB                        ; check console switch values
   bmi .calculateHumanMovementDelay ; branch if player 2 difficulty set to PRO
   lda #FRACTIONAL_MOVEMENT_SLOW_HUMAN;move humans 1 out of 5 frames
.calculateHumanMovementDelay
   clc
   adc humanFractionalDelay
   sta humanFractionalDelay
   bcs MoveHumanSprites
.jmpToSetETGraphicPointers
   jmp SetETGraphicPointers

MoveHumanSprites
   ldx #3
MoveHumanLoop
   dex
   bmi .jmpToSetETGraphicPointers
   lda objectScreenId,x             ; get the human's screen id
   bmi MoveHumanLoop
   cmp #ID_WASHINGTON_DC            ; see if human is on WASHINGTON_DC screen
   bne .checkForHumanOnCurrentScreen
   ldy humanAttributes,x            ; get the human's attributes
   bpl .checkForHumanOnCurrentScreen; branch if not returning home
   lda HumanTargetVertPosTable,x
   sta humanTargetVertPos
   ldy HumanTargetHorizPosTable,x
   sty humanTargetHorizPos
   cmp objectVertPos,x
   bne .moveHumanToHomeArea
   tya
   cmp objectHorizPos,x
   bne .moveHumanToHomeArea
   lda #<-1
   sta objectScreenId,x
   txa                              ; move object id to accumulator
   bne .checkForElliottHome         ; branch if not FBI Agent
   lda #<(~FBI_HAS_PHONE_PIECE)     ; have FBI Agent release phone piece
   and h_phonePieceAttribute
   sta h_phonePieceAttribute
   lda #<(~FBI_HAS_PHONE_PIECE)
   and s_phonePieceAttribute
   sta s_phonePieceAttribute
   lda #<(~FBI_HAS_PHONE_PIECE)
   and w_phonePieceAttribute
   sta w_phonePieceAttribute
.checkForElliottHome
   cpx #ID_ELLIOTT
   bne .checkForScientistHome
   bit etMotionValues               ; check E.T. motion value
   bvs .checkForScientistHome       ; branch if E.T. carried by Scientist
   bit playerState                  ; check player state
   bmi .checkForScientistHome       ; branch if E.T. is dead
   lda #ELLIOTT_HAS_PHONE_PIECE
   bit h_phonePieceAttribute
   bne .clearElliottReturnHomeFlag  ; branch if Elliott has H phone piece
   bit s_phonePieceAttribute
   bne .clearElliottReturnHomeFlag  ; branch if Elliott has S phone piece
   bit w_phonePieceAttribute
   beq .checkForScientistHome       ; branch if Elliott has no phone pieces
.clearElliottReturnHomeFlag
   rol elliottAttributes            ; rotate Elliott attributes left and
   clc                              ; clear carry and rotate value right to
   ror elliottAttributes            ; clear RETURN_HOME flag (i.e. D7 = 0)
.checkForScientistHome
   cpx #ID_SCIENTIST
   bne .checkToClearCurrentHuman
   lda etMotionValues               ; get E.T. motion value
   and #<(~ET_CARRIED_BY_SCIENTIST)
   sta etMotionValues               ; release E.T. from Scientist
.checkToClearCurrentHuman
   cpx currentObjectId
   bne MoveHumanLoop
   lda #<-1
   sta currentObjectId              ; clear human as current object
   lda #0
   sta currentSpriteHeight
   beq MoveHumanLoop                ; unconditional branch

.moveHumanToHomeArea
   ldy #4                           ; human to go to target area
   bne .moveHumanTowardTarget       ; unconditional branch

.checkForHumanOnCurrentScreen
   cmp currentScreenId
   bne MoveHumans
   ldy humanAttributes,x            ; get human attribute value
   bmi MoveHumans                   ; branch if returning home
   lda objectVertPos,x
   cmp HumanVerticalMaxTable,x
   bcc .humanSeekOutET
   dec objectVertPos,x              ; move human up 1 pixel
.humanSeekOutET
   ldy #0
.moveHumanTowardTarget
   jsr MoveHumanTowardTarget
.nextHumanId
   jmp MoveHumanLoop

MoveHumans
   lda humanAttributes,x            ; get human attributes
   lsr                              ; shift MOVE_UP value to carry
   bcc MoveHumanUp
   lsr                              ; shift MOVE_DOWN value to carry
   bcc MoveHumanDown
   lsr                              ; shift MOVE_LEFT value to carry
   bcs .checkForMovingRight
   jmp MoveHumanLeft

.checkForMovingRight
   lsr                              ; shift MOVE_RIGHT value to carry
   bcs .nextHumanId
   jmp MoveHumanRight

MoveHumanUp SUBROUTINE
   dec objectVertPos,x              ; move object up
   bpl .nextHuman                   ; branch if object still on screen
   ldy objectScreenId,x             ; get the current screen id of the object
   lda UpperScreenIdTable,y
   jsr CheckForHumanOnScreen        ; check to see if human on screen
   bcs .moveHumanDown2Pixels        ; branch if human already on the screen
   sta objectScreenId,x             ; set human's new screen id
   cpx currentObjectId              ; see if the human is the current object
   bne .setHumanPosition            ; branch if human not the current object
   lda #<-1
   sta currentObjectId              ; clear human as current object (i.e. human
   lda #0                           ; moved off current screen)
   sta currentSpriteHeight
.setHumanPosition
   lda UpperScreenIdVertPosTable,y
   beq .setHumanHorizontalPosition
   cmp HumanVerticalMaxTable,x
   bcc .setHumanVerticalPosition
   lda HumanVerticalMaxTable,x
   sbc #1
.setHumanVerticalPosition
   sta objectVertPos,x
.setHumanHorizontalPosition
   lda UpperScreenIdHorizPosTable,y
   beq .checkToSetAsCurrentHuman
   sta objectHorizPos,x
.checkToSetAsCurrentHuman
   lda objectScreenId,x             ; get the object's screen id
   cmp currentScreenId              ; see if object is on current screen
   bne .nextHuman                   ; branch if object not on current screen
   stx currentObjectId
   jsr SetCurrentObjectData
.nextHuman
   jmp MoveHumanLoop

.moveHumanDown2Pixels
   inc objectVertPos,x
   inc objectVertPos,x
   jmp MoveHumanLoop

MoveHumanDown SUBROUTINE
   inc objectVertPos,x              ; move object down
   lda HumanVerticalMaxTable,x      ; get the object's vertical max value
   cmp objectVertPos,x              ; compare with object vertical position
   bcs .moveNextHuman
   ldy objectScreenId,x             ; get the current screen id of the object
   lda LowerScreenIdTable,y
   jsr CheckForHumanOnScreen        ; check to see if human on screen
   bcs .moveHumanUp2Pixels          ; branch if human already on the screen
   sta objectScreenId,x             ; set human's new screen id
   cpx currentObjectId              ; see if the human is the current object
   bne .setHumanPosition
   lda #<-1
   sta currentObjectId              ; clear human as current object (i.e. human
   lda #0                           ; moved off current screen)
   sta currentSpriteHeight
.setHumanPosition
   lda LowerScreenIdVertPosTable,y
   beq .setHumanHorizontalPosition
   cmp HumanVerticalMaxTable,x
   bcc .setHumanVerticalPosition
   lda HumanVerticalMaxTable,x
   sbc #1
.setHumanVerticalPosition
   sta objectVertPos,x
.setHumanHorizontalPosition
   lda LowerScreenIdHorizPosTable,y
   beq .checkToSetAsCurrentHuman
   sta objectHorizPos,x
.checkToSetAsCurrentHuman
   lda objectScreenId,x             ; get the object's screen id
   cmp currentScreenId              ; see if object is on current screen
   bne .moveNextHuman               ; branch if object not on current screen
   stx currentObjectId
   jsr SetCurrentObjectData
.moveNextHuman
   jmp MoveHumanLoop

.moveHumanUp2Pixels
   dec objectVertPos,x
   dec objectVertPos,x
   jmp MoveHumanLoop

MoveHumanLeft SUBROUTINE
   dec objectHorizPos,x             ; move object left
   bpl .nextHuman
   ldy objectScreenId,x             ; get the current screen id of the object
   lda LeftScreenIdTable,y
   jsr CheckForHumanOnScreen        ; check to see if human on screen
   bcs .moveHumanRight2Pixels       ; branch if human already on the screen
   sta objectScreenId,x             ; set human's new screen id
   cpx currentObjectId              ; see if the human is the current object
   bne .setHumanPosition
   lda #<-1
   sta currentObjectId              ; clear human as current object (i.e. human
   lda #0                           ; moved off current screen)
   sta currentSpriteHeight
.setHumanPosition
   lda LeftScreenIdVertPosTable,y
   beq .setHumanHorizontalPosition
   cmp HumanVerticalMaxTable,x
   bcc .setHumanVerticalPosition
   lda HumanVerticalMaxTable,x
   sbc #1
.setHumanVerticalPosition
   sta objectVertPos,x
.setHumanHorizontalPosition
   lda LeftScreenIdHorizPosTable,y
   beq .checkToSetAsCurrentHuman
   sta objectHorizPos,x
.checkToSetAsCurrentHuman
   lda objectScreenId,x             ; get the object's screen id
   cmp currentScreenId              ; see if object is on current screen
   bne .nextHuman                   ; branch if object not on current screen
   stx currentObjectId
   jsr SetCurrentObjectData
.nextHuman
   jmp MoveHumanLoop

.moveHumanRight2Pixels
   inc objectHorizPos,x
   inc objectHorizPos,x
   jmp MoveHumanLoop

MoveHumanRight SUBROUTINE
   inc objectHorizPos,x             ; move object right
   ldy objectHorizPos,x             ; get the object's horizontal position
   cpy #XMAX + 1
   bcc .nextHuman
   ldy objectScreenId,x             ; get the current screen id of the object
   lda RightScreenIdTable,y
   jsr CheckForHumanOnScreen        ; check to see if human on screen
   bcs .moveHumanLeft2Pixels        ; branch if human already on the screen
   sta objectScreenId,x             ; set human's new screen id
   cpx currentObjectId              ; see if the human is the current object
   bne .setHumanPosition
   lda #<-1
   sta currentObjectId              ; clear human as current object (i.e. human
   lda #0                           ; moved off current screen)
   sta currentSpriteHeight
.setHumanPosition
   lda RightScreenIdVertPosTable,y
   beq .setHumanHorizontalPosition
   cmp HumanVerticalMaxTable,x
   bcc .setHumanVerticalPosition
   lda HumanVerticalMaxTable,x
   sbc #1
.setHumanVerticalPosition
   sta objectVertPos,x
.setHumanHorizontalPosition
   lda RightScreenIdHorizPosTable,y
   beq .checkToSetAsCurrentHuman
   sta objectHorizPos,x
.checkToSetAsCurrentHuman
   lda objectScreenId,x             ; get the object's screen id
   cmp currentScreenId              ; see if object is on current screen
   bne .nextHuman                   ; branch if object not on current screen
   stx currentObjectId
   jsr SetCurrentObjectData
.nextHuman
   jmp MoveHumanLoop

.moveHumanLeft2Pixels
   dec objectHorizPos,x
   dec objectHorizPos,x
   jmp MoveHumanLoop

SetETGraphicPointers
   bit playerState                  ; check player state
   bpl .setETGraphicPointersNotDead ; branch if E.T. is not dead
   lda #<ETDead_1
   sta etGraphicPointers1
   lda #<ETDead_0
   sta etGraphicPointers0
   lda #12 / 2
   sta etHeight
   bne .setETSpritePtrMSB           ; unconditional branch

.setETGraphicPointersNotDead
   lda etNeckExtensionValues        ; get neck extension value
   bpl .setNormalETGraphicPointers  ; branch if neck not extended
   and #3
   tax
   lda ETNeckExtensionHeightTable,x
   sta etHeight
   lda ETNeckExtensionLSBTable_A,x
   sta etGraphicPointers0
   lda ETNeckExtensionLSBTable_B,x
   sta etGraphicPointers1
   bne .setETSpritePtrMSB           ; unconditional branch
   
.setNormalETGraphicPointers
   lda #18 / 2
   sta etHeight
   lda SWCHA                        ; read joystick values
   cmp #P0_NO_MOVE
   bcs .setToETRestSpritePtrs       ; branch if E.T. not moving
   lda #3
   bit etMotionValues               ; check E.T. motion value
   bpl .determineETAnimationIndex   ; branch if E.T. is not running
   lsr
.determineETAnimationIndex
   and frameCount
   bne .setETSpritePtrMSB
   ldx etAnimationIndex             ; get E.T. animation table index
   dex
   bpl .setETAnimationGraphicPtrs   ; branch if index didn't wrap around
   ldx #2
.setETAnimationGraphicPtrs
   stx etAnimationIndex
   lda ETAnimationLSBTable_A,x
   sta etGraphicPointers0
   lda ETAnimationLSBTable_B,x
   sta etGraphicPointers1
   bne .setETSpritePtrMSB           ; unconditional branch
   
.setToETRestSpritePtrs
   lda #<ETWalkSprite_A0
   sta etGraphicPointers0
   lda #<ETWalkSprite_B0
   sta etGraphicPointers1
.setETSpritePtrMSB
   lda #>ETSprites
   sta etGraphicPointers0 + 1
   sta etGraphicPointers1 + 1
SetSpecialSpriteForPit
   lda currentObjectId              ; get the current object id
   cmp #$80 | ID_FLOWER
   bne DetermineObjectAnimationPtrs
   bit easterEggSpriteFlag          ; check Easter Egg sprite flags
   bpl .setFlowerGrowthAnimation    ; animate flower growth
   ldx #ID_INDY                     ; assume we are showing Indy sprite
   bvs .setEasterEggSpriteInfo      ; branch if set current object data
   dex                              ; reduce object id to be Yar wings up
   lda frameCount                   ; get the current frame count
   and #2
   bne .setEasterEggSpriteInfo
   dex                              ; reduce object id to be Yar wings down
.setEasterEggSpriteInfo
   jsr SetCurrentObjectData
   jmp SetCurrentObjectXYCoordinates

.setFlowerGrowthAnimation
   lda flowerState                  ; get the flower state
   lsr                              ; move revive animation to lower nybbles
   lsr
   lsr
   lsr
   and #3
   tax
   lda FlowerAnimationLSBTable_A,x
   sta objectGraphicPtrs_0
   lda FlowerAnimationLSBTable_B,x
   sta objectGraphicPtrs_1
   jmp SetCurrentObjectXYCoordinates

DetermineObjectAnimationPtrs
   ldx currentObjectId              ; get the current object id
   bmi SetCurrentObjectXYCoordinates
   lda HumanAnimationRate,x         ; get human animation rate
   and frameCount
   bne SetCurrentObjectXYCoordinates; skip animation if not time
   lda objectGraphicPtrs_0          ; get the object's graphic LSB value
   clc
   adc SpriteHeightValues,x         ; increase by sprite height
   cmp HumanEndAnimationTable,x
   bcc .setHumanAnimationGraphicPtrs
   lda ObjectGraphicPointersLSB_0,x
   sta objectGraphicPtrs_0
   lda ObjectGraphicPointersLSB_1,x
   sta objectGraphicPtrs_1
   bne SetCurrentObjectXYCoordinates; unconditional branch

.setHumanAnimationGraphicPtrs
   sta objectGraphicPtrs_0
   lda objectGraphicPtrs_1
   clc
   adc SpriteHeightValues,x
   sta objectGraphicPtrs_1
SetCurrentObjectXYCoordinates
   lda currentScreenId              ; get the current screen id
   cmp #ID_ET_HOME
   beq .setObjectsHorizPosition
   ldx currentObjectId              ; get the current object id
   bmi .setObjectsHorizPosition
   lda objectVertPos,x
   sta currentObjectVertPos
   lda objectHorizPos,x
   sta currentObjectHorizPos
.setObjectsHorizPosition
   lda etHorizPos                   ; get E.T.'s horizontal position
   pha                              ; push value on to stack
   lda #30
   sta etHorizPos                   ; set position for status icons
   jmp HorizPositionObjects

SetCurrentScreenData
   ldx currentScreenId              ; get the current screen id
   lda PlayfieldGraphicPointersMSB,x
   sta pf1GraphicPtrs + 1
   sta pf2GraphicPtrs + 1
   lda PF1GraphicPointersLSB,x
   sta pf1GraphicPtrs
   lda PF2GraphicPointersLSB,x
   sta pf2GraphicPtrs
   lda #$00
   sta easterEggSpriteFlag          ; clear Easter Egg sprite flags
   sta programmerInitialFlag        ; clear flag to show programmer initials
   ldy #<(~PHONE_PIECE_SCREEN_LOC)
   tya
   and h_phonePieceAttribute
   sta h_phonePieceAttribute
   tya
   and s_phonePieceAttribute
   sta s_phonePieceAttribute
   tya
   and w_phonePieceAttribute
   sta w_phonePieceAttribute
   lda #127
   sta etHeartVertPos
   sta phonePieceMapVertPos
   sta candyVertPos
   bit mothershipStatus             ; check Mothership status
   bpl CheckToEnableETHeart         ; branch if Mothership not present
   lda #<-1
   sta currentObjectId
   lda #61
   sta etHorizPos
   lda #244
   sta etVertPos
   lda #18 / 2
   sta etHeight
   lda #<ETWalkSprite_A0
   sta etGraphicPointers0
   lda #<ETWalkSprite_B0
   sta etGraphicPointers1
   lda #>ETSprites
   sta etGraphicPointers0 + 1
   sta etGraphicPointers1 + 1
   ldx #ID_MOTHERSHIP
   jsr SetCurrentObjectData
   lda #56
   sta currentObjectHorizPos
   lda #240
   sta currentObjectVertPos
   rts

CheckToEnableETHeart
   cpx #ID_ET_HOME
   bne .checkForETInPit             ; branch if E.T. not on HOME screen
   bit playerState                  ; check player state
   bpl .doneCheckForETHeart         ; branch if E.T. is not dead
   lda #51
   sta etHeartVertPos
   lda #64
   sta etHeartHorizPos
.doneCheckForETHeart
   rts

.checkForETInPit
   cpx #ID_PIT
   beq PositionETInPit
   txa
   ldx #ID_SCIENTIST
.findCurrentHumanLoop
   cmp objectScreenId,x             ; see if human is on current screen
   beq .setCurrentHumanId           ; if so then set current object attributes
   dex
   bpl .findCurrentHumanLoop
   lda #<-1
   sta currentObjectId
   lda #0
   sta currentSpriteHeight
   sta currentObjectVertPos
   beq CalculatePowerZonePointer    ; unconditional branch

.setCurrentHumanId
   stx currentObjectId              ; set current object id
   jsr SetCurrentObjectData
CalculatePowerZonePointer
   ldx currentScreenId              ; get the current screen id
   cpx #ID_FOREST
   bcs .determinePowerZonePointerLSB; branch if not a well screen
   lda CandyStatusValueTable,x
   and candyStatus
   beq .determinePowerZonePointerLSB
   lda CandyVertPositionTable,x
   sta candyVertPos                 ; set candy vertical position
   lda CandyHorizPositionTable,x
   sta candyHorizPos                ; set candy horizontal position
.determinePowerZonePointerLSB
   lda currentScreenId              ; get the current screen id
   cmp #ID_PIT
   bcs .doneCalculatePowerZonePointer; branch if in pit or game over
   lsr                              ; divide current screen id by 2
   tax
   lda powerZoneLSBValues,x
   bcs .multi8                      ; branch if odd screen id (EIGHT_PITS, FOUR_PITS, WASH)
   lsr                              ; divide value by 2
   bpl .setPowerZonePointerLSB      ; unconditional branch
   
.multi8
   asl
   asl
   asl
.setPowerZonePointerLSB
   and #$78
   sta powerZonePointer
.doneCalculatePowerZonePointer
   rts

CandyVertPositionTable
   .byte 32, 32, 32, 32

CandyHorizPositionTable
   .byte 60, 60, 38, 38

PositionETInPit
   lda #69
   sta etHorizPos
   lda #3
   sta etVertPos
   lda #FALLING_IN_PIT
   sta etPitStatus                  ; set status to show E.T. falling in a pit
   bit playerState                  ; check player state
   bmi .noObjectInCurrentPit        ; branch if E.T. is dead
   ldx #NUM_PHONE_PIECES - 1
.checkPhonePieceInCurrentPit
   lda phonePieceAttributes,x       ; get phone piece attribute value
   and #<(~PHONE_PIECE_PIT_NUMBER)
   bne .checkNextPhonePiece         ; branch if phone piece taken
   lda phonePieceAttributes,x       ; get phone piece attribute value
   and #PHONE_PIECE_PIT_NUMBER      ; keep phone piece pit number
   cmp currentPitNumber             ; compare with current pit number
   beq .setCurrentObjectToPhonePiece; branch if phone piece in current pit
.checkNextPhonePiece
   dex
   bpl .checkPhonePieceInCurrentPit
   lda flowerState                  ; get flower state
   and #FLOWER_PIT_NUMBER           ; keep flower pit number
   cmp currentPitNumber             ; compare with current pit number
   bne .noObjectInCurrentPit        ; branch if flower not in current pit
   lda #$80 | ID_FLOWER
   bne .setCurrentObjectIdInPit     ; unconditional branch

.noObjectInCurrentPit
   ldx #<-1
   stx currentObjectId
   inx                              ; x = 0
   stx currentSpriteHeight
   rts

.setCurrentObjectToPhonePiece
   txa
   adc #$80 | ID_H_PHONE_PIECE - 1
.setCurrentObjectIdInPit
   sta currentObjectId
   and #$0F
   tax
   jsr SetCurrentObjectData
   lda #OBJECT_IN_PIT_Y
   sta currentObjectVertPos
   lda #OBJECT_IN_PIT_X
   sta currentObjectHorizPos
   rts

   BOUNDARY 0

HMOVETable
   .byte HMOVE_R1, HMOVE_R2, HMOVE_R3, HMOVE_R4, HMOVE_R5, HMOVE_R6, HMOVE_R7
COARSE_MOTION SET 0
   REPEAT 8

COARSE_MOTION SET COARSE_MOTION + 1
   .byte HMOVE_L7 | COARSE_MOTION
   .byte HMOVE_L6 | COARSE_MOTION
   .byte HMOVE_L5 | COARSE_MOTION
   .byte HMOVE_L4 | COARSE_MOTION
   .byte HMOVE_L3 | COARSE_MOTION
   .byte HMOVE_L2 | COARSE_MOTION
   .byte HMOVE_L1 | COARSE_MOTION
   .byte HMOVE_0  | COARSE_MOTION
   .byte HMOVE_R1 | COARSE_MOTION
   .byte HMOVE_R2 | COARSE_MOTION
   .byte HMOVE_R3 | COARSE_MOTION
   .byte HMOVE_R4 | COARSE_MOTION
   .byte HMOVE_R5 | COARSE_MOTION
   .byte HMOVE_R6 | COARSE_MOTION
   .byte HMOVE_R7 | COARSE_MOTION

   REPEND

Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set stack to the beginning
   inx                              ; x = 0
   txa
.clearLoop
   sta VSYNC,x
   dex
   bne .clearLoop
   lda #$01
   sta CTRLPF
   sta gameSelection                ; set initial game selection to 1
   lda #>PowerZoneMap
   sta powerZonePointer + 1
   lda #ORANGE + 10
   sta telephoneColor
   lda #LT_BLUE + 12
   sta powerZoneColor
   lda #BROWN + 10
   sta timerColor
   lda #ID_TITLE_SCREEN
   sta currentScreenId              ; set the current screen id
   jsr SetCurrentScreenData
   jmp StartNewFrame

JumpToDisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
   sta WSYNC
   lda #<DisplayKernel
   sta bankSwitchRoutinePtr
   lda #>DisplayKernel
   sta bankSwitchRoutinePtr + 1
   lda #LDA_ABS
   sta displayKernelBankSwitch
   lda #<BANK1STROBE
   sta bankSwitchStrobe
   lda #>BANK1STROBE
   sta bankSwitchStrobe + 1
   lda #JMP_ABS
   sta bankSwitchABSJmp
   jmp.w displayKernelBankSwitch

ObjectDirectionCheck
   ror                              ; shift up motion flag to carry
   bcs .checkForDownMotion          ; check down motion if not moving up
   dec currentObjectVertPos,x       ; move object up
.checkForDownMotion
   ror                              ; shift down motion flag to carry
   bcs .checkForLeftMotion          ; check left motion if not moving down
   inc currentObjectVertPos,x       ; move object down
.checkForLeftMotion
   ror                              ; shift left motion flag to carry
   bcs .checkForRightMotion         ; check right motion if not moving left
   dec currentObjectHorizPos,x      ; move object left
.checkForRightMotion
   ror                              ; shift right motion flag to carry
   bcs .doneObjectDirectionCheck    ; done if not moving right
   inc currentObjectHorizPos,x      ; move object right
.doneObjectDirectionCheck
   rts

MoveHumanTowardTarget
   lda objectVertPos,x              ; get the object's vertical position
   cmp etVertPos,y                  ; compare with target's vertical position
   beq .checkTargetHorizPosition    ; check horizontal position if the same
   bcs .moveObjectUpTowardTarget
   inc objectVertPos,x              ; move object down
   bne .checkTargetHorizPosition    ; unconditional branch
   
.moveObjectUpTowardTarget
   dec objectVertPos,x              ; move object up
.checkTargetHorizPosition
   lda objectHorizPos,x             ; get the object's horizontal position
   cmp etHorizPos,y                 ; compare with target's horizontal position
   beq .doneMoveHumanTowardTarget   ; done if the same
   bcs .moveObjectLeftTowardTarget
   inc objectHorizPos,x             ; move the object right
.doneMoveHumanTowardTarget
   rts

.moveObjectLeftTowardTarget
   dec objectHorizPos,x             ; move the object left
   rts

PhonePiecePitVertPosition
   .byte 19,32,32,44,11,32,32,52,21,21,45,45,15,15,47,47
   
PhonePiecePitHorizPosition
   .byte 62,25,101,62,62,30,95,62,25,100,28,96,30,95,30,95
   .byte 0,0,0,0,0,10,9,11,0,6,5,7,0,14,13,15

PlayfieldGraphicPointersMSB
   .byte >WideDiamondPitGraphics, >EightPitGraphics, >ArrowPitGraphics
   .byte >FourDiamondPitGraphics, >ForestGraphics, >WashingtonDCGraphics
   .byte >PitGraphics, >ETHomePFGraphics

PF1GraphicPointersLSB
   .byte <WideDiamondPitPF1Graphics, <EightPitGraphics, <ArrowPitPF1Graphics
   .byte <FourDiamondPitGraphics, <ForestPF1Graphics, <WashingtonPF1Graphics
   .byte <PitPF1Graphics, <ETHomePF1Graphics

PF2GraphicPointersLSB
   .byte <WideDiamondPitPF2Graphics, <EightPitGraphics, <ArrowPitPF2Graphics
   .byte <FourDiamondPitGraphics, <ForestPF2Graphics, <WashingtonPF2Graphics
   .byte <PitPF2Graphics, <ETHomePF2Graphics

LeftScreenIdHorizPosTable
   .byte 119,119,119,119,68,68
   
RightScreenIdHorizPosTable
   .byte 1,1,1,1,58,58
   
UpperScreenIdHorizPosTable
   .byte 0,117,0,4,0,0
   
LowerScreenIdHorizPosTable
   .byte 0,4,0,117,0,0
   
LeftScreenIdVertPosTable
   .byte 0,0,0,0,4,53
   
RightScreenIdVertPosTable
   .byte 0,0,0,0,4,53
   
UpperScreenIdVertPosTable
   .byte 8,36,57,36,8,57
   
LowerScreenIdVertPosTable
   .byte 2,28,50,28,2,50

LeftScreenIdTable
   .byte ID_EIGHT_PITS,ID_ARROW_PITS, ID_WIDE_DIAMOND_PITS
   .byte ID_FOUR_DIAMOND_PITS, ID_WIDE_DIAMOND_PITS, ID_EIGHT_PITS

RightScreenIdTable
   .byte ID_WIDE_DIAMOND_PITS, ID_FOUR_DIAMOND_PITS, ID_EIGHT_PITS
   .byte ID_ARROW_PITS,ID_EIGHT_PITS, ID_WIDE_DIAMOND_PITS

UpperScreenIdTable
   .byte ID_FOREST, ID_FOREST, ID_FOREST, ID_FOREST
   .byte ID_FOUR_DIAMOND_PITS, ID_FOUR_DIAMOND_PITS

LowerScreenIdTable
   .byte ID_WASHINGTON_DC, ID_WASHINGTON_DC, ID_WASHINGTON_DC
   .byte ID_WASHINGTON_DC, ID_ARROW_PITS, ID_ARROW_PITS

HumanTargetHorizPosTable
   .byte FBI_AGENT_HORIZ_TARGET
   .byte ELLIOTT_HORIZ_TARGET
   .byte SCIENTIST_HORIZ_TARGET
   
HumanTargetVertPosTable
   .byte FBI_AGENT_VERT_TARGET
   .byte ELLIOTT_VERT_TARGET
   .byte SCIENTIST_VERT_TARGET
   
HumanVerticalMaxTable
   .byte FBI_AGENT_VERT_MAX
   .byte ELLIOTT_VERT_MAX
   .byte SCIENTIST_VERT_MAX

FlowerAnimationLSBTable_A
   .byte <Flower_A0, <Flower_A1, <Flower_A2, <Flower_A3

FlowerAnimationLSBTable_B
   .byte <Flower_B0, <Flower_B1, <Flower_B2, <Flower_B3

ObjectGraphicPointersMSB
   .byte >FBIAgent_0, >Elliott_0, >Scientist_0, >H_PhonePiece_0, >S_PhonePiece_0
   .byte >W_PhonePiece_0, >Flower_A0, >MotherShip, >Yar_0, >Yar_1, >IndySprite

ObjectGraphicPointersLSB_0
   .byte <FBIAgent_0, <Elliott_0, <Scientist_0, <H_PhonePiece_0, <S_PhonePiece_0
   .byte <W_PhonePiece_0, <Flower_A0, <MotherShip, <Yar_0, <Yar_1, <IndySprite

ObjectGraphicPointersLSB_1
   .byte <FBIAgent_4, <Elliott_6, <Scientist_5, <H_PhonePiece_1, <S_PhonePiece_1
   .byte <W_PhonePiece_1, <Flower_B0, <MotherShip, <Yar_0, <Yar_1, <IndySprite

ObjectColorPointersMSB
   .byte >FBIAgentColors_A
   .byte >ElliottColors_A
   .byte >ScientistColors_A
   .byte >PhonePieceColors_A
   .byte >PhonePieceColors_A
   .byte >PhonePieceColors_A
   .byte >FlowerColors
   .byte >MotherShipColors
   .byte >YarColor
   .byte >YarColor
   .byte >IndyColors

ObjectColorPointersLSB_A
   .byte <FBIAgentColors_A
   .byte <ElliottColors_A
   .byte <ScientistColors_A
   .byte <PhonePieceColors_A
   .byte <PhonePieceColors_A
   .byte <PhonePieceColors_A
   .byte <FlowerColors
   .byte <MotherShipColors
   .byte <YarColor
   .byte <YarColor
   .byte <IndyColors

ObjectColorPointersLSB_B
   .byte <FBIAgentColors_B
   .byte <ElliottColors_B
   .byte <ScientistColors_B
   .byte <PhonePieceColors_B
   .byte <PhonePieceColors_B
   .byte <PhonePieceColors_B
   .byte <FlowerColors
   .byte <MotherShipColors
   .byte <YarColor
   .byte <YarColor
   .byte <IndyColors

HumanEndAnimationTable
   .byte <FBIAgent_4
   .byte <Elliott_5 + (H_ELLIOTT / 2) - 1
   .byte <Scientist_5

SpriteHeightValues
   .byte H_FBIAGENT/2, H_ELLIOTT/2, H_SCIENTIST/2, H_PHONE_PIECES/2
   .byte H_PHONE_PIECES/2, H_PHONE_PIECES/2, H_FLOWER/2, H_MOTHERSHIP/2
   .byte H_YAR/2, H_YAR/2, H_INDY/2

HumanAnimationRate
   .byte 3, 3, 3
   
ETAnimationLSBTable_A
   .byte <ETWalkSprite_A0, <ETWalkSprite_A1, <ETWalkSprite_A2
   
ETAnimationLSBTable_B
   .byte <ETWalkSprite_B0, <ETWalkSprite_B1, <ETWalkSprite_B2
   
HumanDirectionTable
   .byte NO_MOVE, MOVE_LEFT>>4, MOVE_UP>>4, MOVE_RIGHT>>4, MOVE_UP>>4, MOVE_DOWN>>4
   .byte P0_NO_MOVE, P0_NO_MOVE, MOVE_RIGHT>>4, NO_MOVE, MOVE_LEFT>>4, MOVE_UP>>4
   .byte MOVE_UP>>4, MOVE_DOWN>>4, P0_NO_MOVE, P0_NO_MOVE
   
   .byte MOVE_UP>>4, MOVE_RIGHT>>4, NO_MOVE, MOVE_LEFT>>4, MOVE_UP>>4, MOVE_DOWN>>4
   .byte P0_NO_MOVE, P0_NO_MOVE, MOVE_LEFT>>4, MOVE_DOWN>>4, MOVE_RIGHT>>4, NO_MOVE
   .byte MOVE_UP>>4, MOVE_DOWN>>4, P0_NO_MOVE, P0_NO_MOVE
   
   .byte MOVE_UP>>4, MOVE_RIGHT>>4, MOVE_DOWN>>4, MOVE_LEFT>>4, NO_MOVE
   .byte MOVE_DOWN>>4, P0_NO_MOVE, P0_NO_MOVE, MOVE_UP>>4, MOVE_LEFT>>4
   .byte MOVE_DOWN>>4, MOVE_RIGHT>>4, MOVE_UP>>4, NO_MOVE, P0_NO_MOVE, P0_NO_MOVE
   
ETFrameDelayTable
   .byte FRACTIONAL_MOVEMENT_ET_WALKING, FRACTIONAL_MOVEMENT_ET_RUNNING
   
PowerZoneJumpTable
   .word SetPhonePieceHiddenLocation - 1
   .word WarpETLeft - 1
   .word WarpETRight - 1
   .word WarpETUp - 1
   .word WarpETDown - 1
   .word DetermineHiddenPhonePiece - 1
   .word EatCandyPiece - 1
   .word ReturnCurrentHumanHome - 1
   .word ClearElliottReturnHomeFlag - 1
   .word CallMothership - 1
   .word SetPhonePieceHiddenLocation - 1
   .word LevitateETOutOfPit - 1
   .word ReviveFlower - 1
   
ETNeckExtensionLSBTable_A
   .byte <ETExtensionSprite_A0, <ETExtensionSprite_A1
   .byte <ETExtensionSprite_A2, <ETExtensionSprite_A3
   
ETNeckExtensionLSBTable_B
   .byte <ETExtensionSprite_B0, <ETExtensionSprite_B1
   .byte <ETExtensionSprite_B2, <ETExtensionSprite_B3
   
CandyStatusMaskTable
   .byte ~FOUR_DIAMOND_PITS_CANDY
   .byte ~EIGHT_PITS_CANDY
   .byte ~ARROW_PITS_CANDY
   .byte ~WIDE_DIAMOND_PITS_CANDY

CandyStatusValueTable
   .byte FOUR_DIAMOND_PITS_CANDY
   .byte EIGHT_PITS_CANDY
   .byte ARROW_PITS_CANDY
   .byte WIDE_DIAMOND_PITS_CANDY
   
ExtraCandyReductionTable
   .byte 4, 3, 3, 2, 3, 2, 2, 1, 3, 2, 2, 1, 2, 1, 1, 0
   
ETNeckExtensionHeightTable
   .byte 10, 11, 12, 13

PlayMothershipSound
   lda frameCount                   ; get the current frame count
   ora #$18
   sta AUDF0
   and #7
   sta AUDF1
   lda frameCount                   ; get the current frame count
   lsr
   and #$1F
   cmp #16
   bcc .setVolumeAndChannel
   eor #$0F
.setVolumeAndChannel
   sta AUDV0
   eor #$0F
   sta AUDV1
   lda #$0F
   sta AUDC0
   lda #$0D
   sta AUDC1
   rts

SetCurrentObjectData
   lda SpriteHeightValues,x
   sta currentSpriteHeight
   lda ObjectGraphicPointersLSB_0,x
   sta objectGraphicPtrs_0
   lda ObjectGraphicPointersLSB_1,x
   sta objectGraphicPtrs_1
   lda ObjectGraphicPointersMSB,x
   sta objectGraphicPtrs_0 + 1
   sta objectGraphicPtrs_1 + 1
   lda ObjectColorPointersLSB_A,x
   sta objectColorPtrs_0
   lda ObjectColorPointersLSB_B,x
   sta objectColorPtrs_1
   lda ObjectColorPointersMSB,x
   sta objectColorPtrs_0 + 1
   sta objectColorPtrs_1 + 1
   bit easterEggSpriteFlag          ; check Easter Egg sprite flags
   bmi .doneSetCurrentObjectData    ; branch if showing special object in pit
   lda objectHorizPos,x
   sta currentObjectHorizPos
   lda objectVertPos,x
   sta currentObjectVertPos
.doneSetCurrentObjectData
   rts

ThemeMusicFrequencyTable
   .byte LEAD_A3,LEAD_A3,LEAD_A3,LEAD_A3,LEAD_E4,LEAD_E4,LEAD_E4,LEAD_E4
   .byte LEAD_D4,LEAD_C4_SHARP,LEAD_H3,LEAD_C4_SHARP,LEAD_A3,LEAD_A3,LEAD_A3
   .byte LEAD_A3,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2
   .byte LEAD_E3_2,LEAD_E3_2,LEAD_F3_SHARP,LEAD_F3_SHARP,LEAD_F3_SHARP
   .byte LEAD_F3_SHARP,LEAD_F4_SHARP,LEAD_F4_SHARP,LEAD_F4_SHARP,LEAD_F4_SHARP
   .byte LEAD_E4,LEAD_D4_SHARP,LEAD_C4_SHARP,LEAD_D4_SHARP,LEAD_H3,LEAD_H3
   .byte LEAD_H3,LEAD_H3,LEAD_F3_SHARP,LEAD_F3_SHARP,LEAD_F3_SHARP
   .byte LEAD_F3_SHARP,LEAD_G3_SHARP,LEAD_G3_SHARP,LEAD_G3_SHARP,LEAD_H3
   .byte LEAD_C4_SHARP,LEAD_A3,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2,LEAD_E3_2
   .byte LEAD_E3_2
   
   BOUNDARY 0
   
PowerZoneMap
   .byte ID_WARP_UP_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_BLANK_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_WARP_LEFT_ZONE
   
   .byte ID_LANDING_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_UP_ZONE
   
   .byte ID_LANDING_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_BLANK_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_RIGHT_ZONE
   
   .byte ID_EAT_CANDY_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_BLANK_ZONE
   
   .byte ID_WARP_UP_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_LANDING_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_RIGHT_ZONE
   
   .byte ID_EAT_CANDY_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_RETURN_HOME_ZONE
   
   .byte ID_WARP_LEFT_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_LANDING_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_RIGHT_ZONE
   
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_WARP_LEFT_ZONE
   
   .byte ID_EAT_CANDY_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_UP_ZONE
   
   .byte ID_CALL_SHIP_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_CALL_ELLIOTT_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_LANDING_ZONE << 4 | ID_WARP_RIGHT_ZONE
   
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_LANDING_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_CALL_SHIP_ZONE
   
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_EAT_CANDY_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_LANDING_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_BLANK_ZONE
   
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_WARP_UP_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_FIND_PHONE_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_RETURN_HOME_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_BLANK_ZONE
   
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_RIGHT_ZONE
   .byte ID_CALL_SHIP_ZONE << 4 | ID_RETURN_HOME_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_BLANK_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_LANDING_ZONE
   
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_WARP_DOWN_ZONE
   .byte ID_CALL_ELLIOTT_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_WARP_DOWN_ZONE << 4 | ID_WARP_UP_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_WARP_LEFT_ZONE
   .byte ID_EAT_CANDY_ZONE << 4 | ID_LANDING_ZONE
   .byte ID_WARP_RIGHT_ZONE << 4 | ID_CALL_SHIP_ZONE
   .byte ID_WARP_LEFT_ZONE << 4 | ID_FIND_PHONE_ZONE
   .byte ID_BLANK_ZONE << 4 | ID_RETURN_HOME_ZONE

CheckForHumanOnScreen
   cmp fbiScreenId                  ; compare with FBI screen id
   beq .doneCheckForHumanOnScreen
   cmp elliottScreenId              ; compare with Elliott screen id
   beq .doneCheckForHumanOnScreen
   cmp scientistScreenId            ; compare with Scientist screen id
   beq .doneCheckForHumanOnScreen
   clc                              ; clear carry to show human not on screen
.doneCheckForHumanOnScreen
   rts

IncrementETEnergy
   sed
   sty energyIncTensValue
   lda etEnergy + 1
   clc
   adc energyIncTensValue
   sta etEnergy + 1
   stx energyIncHundredsValue
   lda etEnergy
   adc energyIncHundredsValue
   sta etEnergy
   bcc .doneEnergyIncrement
   lda #MAX_ENERGY
   sta etEnergy
   sta etEnergy + 1
.doneEnergyIncrement
   cld
   rts

SetCurrentScreenToETHome
   lda #ID_ET_HOME
   sta currentScreenId              ; set the current screen id
   sta frameCount
   jsr SetCurrentScreenData
   ldx #ID_ELLIOTT
   stx currentObjectId              ; set Elliott on current screen
   jsr SetCurrentObjectData
   lda #60
   sta currentObjectHorizPos        ; set Elliott's horizontal position
   sta etHorizPos                   ; set E.T. horizontal position
   lda #15
   sta currentObjectVertPos         ; set Elliott's vertical position
   lda #48
   sta etVertPos                    ; set E.T. vertical position
   lda #$00
   sta collectedCandyScoring        ; clear collected candy scoring flags
   sta etHomeElliottMovement        ; clear Elliott movement flags
   rts

DecrementETEnergy
   sty energyDecTensValue
   sed
   lda etEnergy + 1
   sec
   sbc energyDecTensValue
   sta etEnergy + 1
   stx energyDecHundredsValue
   lda etEnergy
   sbc energyDecHundredsValue
   sta etEnergy
   bcs .doneEnergyDecrement
   lda #$00
   sta etEnergy
   sta etEnergy + 1
   rol playerState                  ; rotate E.T. death flag to carry
   sec                              ; set carry
   ror playerState                  ; rotate right to set E.T. death flag
.doneEnergyDecrement
   cld
   rts

   IF COMPILE_REGION = NTSC
   
      .org BANK0TOP + 4096 - 6, 0
      
   ELSE
   
      .org BANK0TOP + 4096 - 8, 0
      .byte 0, -1
      
   ENDIF
   
   .word Start
   .word Start
   .word Start

;============================================================================
; R O M - C O D E  (BANK 1)
;============================================================================

   SEG Bank1
   .org BANK1TOP
   .rorg BANK1_REORG

BANK1Start
   lda BANK0STROBE
   jmp Start

.checkForEndGameKernel
   cpx #64                    ; 2
   bcc .skipObjectDraw        ; 2³
   jmp ScoreKernel            ; 3

.skipObjectDraw
   lda #0                     ; 2
   sta GRP0                   ; 3 = @13
   sta nextObjectGraphicData  ; 3
   lda frameCount             ; 3         get the current frame count
   lsr                        ; 2
   and #$1F                   ; 2
   ora #$40                   ; 2
   sta COLUP0                 ; 3
   lda temp                   ; 3         waste 3 cycles
   nop                        ; 2
   jmp .checkToDrawET         ; 3

GameKernel
   cpx candyVertPos           ; 3
   php                        ; 3 = @41   enable/disable BALL
   cpx phonePieceMapVertPos   ; 3
   php                        ; 3 = @47   enable/disable M1
   cpx etHeartVertPos         ; 3
   php                        ; 3 = @53   enable/disable M0
   inx                        ; 2         increment scan line count
   ldy nextETGraphicData      ; 3
JumpIntoGameKernel
   txa                        ; 2         move scan line count to accumulator
   sec                        ; 2
   sbc currentObjectVertPos   ; 3         subtract object vertical position
   cmp currentSpriteHeight    ; 3         compare with sprite height
   sty GRP1                   ; 3         draw ET graphic data
   sta WSYNC
;--------------------------------------
   bcs .checkForEndGameKernel ; 2³        skip object draw if greater
   tay                        ; 2
   lda (objectGraphicPtrs_0),y; 5
   sta GRP0                   ; 3 = @12
   lda (objectColorPtrs_0),y  ; 5
   sta COLUP0                 ; 3 = @20
   lda (objectGraphicPtrs_1),y; 5
   sta nextObjectGraphicData  ; 3
   lda (objectColorPtrs_1),y  ; 5
   sta nextObjectColorData    ; 3
.checkToDrawET
   txa                        ; 2
   ldx #<ENABL                ; 2
   txs                        ; 2         point stack to ENABL
   tax                        ; 2
   sec                        ; 2
   sbc etVertPos              ; 3
   cmp etHeight               ; 3
   bcs .skipETDraw            ; 2³
   tay                        ; 2
   lda (etGraphicPointers1),y ; 5
   sta nextETGraphicData      ; 3
   lda (etGraphicPointers0),y ; 5
   sta GRP1                   ; 3
.drawNextObjectData
   sta WSYNC
;--------------------------------------
   lda nextObjectGraphicData  ; 3
   sta GRP0                   ; 3 = @06
   lda nextObjectColorData    ; 3
   sta COLUP0                 ; 3 = @12
   txa                        ; 2
   tay                        ; 2
   lda (pf1GraphicPtrs),y     ; 5
   sta PF1                    ; 3 = @24
   lda (pf2GraphicPtrs),y     ; 5
   sta PF2                    ; 3 = @32
   jmp GameKernel             ; 3

.skipETDraw
   lda #0                     ; 2
   sta GRP1                   ; 3 = @60
   sta nextETGraphicData      ; 3
   beq .drawNextObjectData    ; 3         unconditional branch

TitleScreenKernel
.waitLoop
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   cpx #16                    ; 2
   bcc .waitLoop              ; 2³
   lda #LT_RED + 4            ; 2
   sta COLUP0                 ; 3 = @11
   sta COLUP1                 ; 3 = @14
   lda #MSBL_SIZE2 | QUAD_SIZE; 2
   sta NUSIZ0                 ; 3 = @19
   sta NUSIZ1                 ; 3 = @22
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @27
   sta REFP1                  ; 3 = @30
   ldx #15                    ; 2
   sta WSYNC
;--------------------------------------
.drawETTitle
   lda ETTitle_E,x            ; 4
   sta GRP0                   ; 3 = @07
   lda ETTitle_T,x            ; 4
   sta GRP1                   ; 3 = @14
   cpx #2                     ; 2
   bcs .nextETTileScanline    ; 2³
   lda #$0F                   ; 2         enable missiles for dots in E.T.
   sta ENAM0                  ; 3 = @23
   sta ENAM1                  ; 3 = @26
.nextETTileScanline
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   sta WSYNC
;--------------------------------------
   bpl .drawETTitle           ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   sta ENAM0                  ; 3 = @13
   sta ENAM1                  ; 3 = @16
   ldx #47                    ; 2
.upperTitleWaitLoop
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   cpx #64                    ; 2
   bcc .upperTitleWaitLoop    ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   ldy #NO_REFLECT            ; 2
   sty REFP1                  ; 3 = @10
   sta NUSIZ0                 ; 3 = @13
   sta NUSIZ1                 ; 3 = @16
   sta VDELP0                 ; 3 = @19   vertically delay players
   sta VDELP1                 ; 3 = @22
   sty GRP0                   ; 3 = @25   clear plaer graphics
   sty GRP1                   ; 3 = @28
   sty GRP0                   ; 3 = @31
   sty GRP1                   ; 3 = @34
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @39   coarse position player 0 to pixel 117
   sta RESP1                  ; 3 = @42   coarse position player 1 to pixel 126
   sty HMP1                   ; 3 = @45
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @50   position player 0 to pixel 118
   sty REFP0                  ; 3 = @53
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #>TitleETGraphics      ; 2
   sta graphicPointers + 1    ; 3
   sta graphicPointers + 3    ; 3
   sta graphicPointers + 5    ; 3
   sta graphicPointers + 7    ; 3
   sta graphicPointers + 9    ; 3
   sta graphicPointers + 11   ; 3
   lda #<TitleETGraphics_1    ; 2
   sta graphicPointers        ; 3
   lda #<TitleETGraphics_2    ; 2
   sta graphicPointers + 2    ; 3
   lda #<TitleETGraphics_3    ; 2
   sta graphicPointers + 4    ; 3
   lda #<TitleETGraphics_4    ; 2
   sta graphicPointers + 6    ; 3
   lda #<TitleETGraphics_5    ; 2
   sta graphicPointers + 8    ; 3
   lda #<TitleETGraphics_0    ; 2
   sta graphicPointers + 10   ; 3
   sta WSYNC
;--------------------------------------
   lda #LT_BROWN + 10         ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   lda #H_ET_GRAPH - 1        ; 2
   sta loopCount              ; 3
   jsr SixDigitKernel         ; 6
   ldx #110                   ; 2 = @08
.lowerTitleWaitLoop
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   cpx #128                   ; 2
   bcc .lowerTitleWaitLoop    ; 2³
ScoreKernel
   sta WSYNC
;--------------------------------------
   ldx #$FF                   ; 2
   txs                        ; 2         reset stack to beginning
   stx PF1                    ; 3 = @07
   stx PF2                    ; 3 = @10
   inx                        ; 2         x = 0
   stx GRP0                   ; 3 = @15   clear player graphic data
   stx GRP1                   ; 3 = @18
   stx ENAM0                  ; 3 = @21   disable missile graphics
   stx ENAM1                  ; 3 = @24
   stx ENABL                  ; 3 = @27   disable BALL
   sta WSYNC
;--------------------------------------
   lda frameCount             ; 3         get the current frame count
   and #7                     ; 2
   bne .skipFlowerAnimation   ; 2³
   lda flowerState            ; 3         get flower state
   bpl .skipFlowerAnimation   ; 2³        branch if flower not revived
   and #<(~FLOWER_REVIVED)    ; 2
   cmp #FLOWER_REVIVE_ANIMATION;2
   bcs .skipFlowerAnimation   ; 2³
   adc #FLOWER_REVIVED | (1 * 16);2       increment flower animation frame
   sta flowerState            ; 3
   lda #PLAY_SOUND_CHANNEL0 | $03;2
   sta soundDataChannel0      ; 3
.skipFlowerAnimation
   sta WSYNC
;--------------------------------------
   lda #GREEN                 ; 2
   sta COLUP0                 ; 3 = @05
   sta COLUP1                 ; 3 = @08
   ldx #HMOVE_0               ; 2
   stx HMP0                   ; 3 = @13
   sta WSYNC
;--------------------------------------
   stx PF0                    ; 3 = @03   remove border from around screen
   stx COLUBK                 ; 3 = @06   set background color to BLACK
   stx PF1                    ; 3 = @09
   stx PF2                    ; 3 = @12
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   ldy #NO_REFLECT            ; 2
   sty REFP1                  ; 3 = @10
   sta NUSIZ0                 ; 3 = @13
   sta NUSIZ1                 ; 3 = @16
   sta VDELP0                 ; 3 = @19
   sta VDELP1                 ; 3 = @22
   sty GRP0                   ; 3 = @25
   sty GRP1                   ; 3 = @28
   sty GRP0                   ; 3 = @31
   sty GRP1                   ; 3 = @34
   nop                        ; 2
   sta RESP0                  ; 3 = @39   coarse position GRP0 to pixel 117
   sta RESP1                  ; 3 = @42   coarse position GRP1 to pixel 126
   sty HMP1                   ; 3 = @45
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @50   GRP0 now set to pixel 127
   sty REFP0                  ; 3 = @53
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda heldCandyPieces        ; 3         get number of candy pieces held by E.T.
   sta tempNumberFonts        ; 3
   lda etEnergy               ; 3
   sta tempNumberFonts + 1    ; 3
   lda etEnergy + 1           ; 3
   sta tempNumberFonts + 2    ; 3
   lda currentScreenId        ; 3         get the current screen id
   cmp #ID_TITLE_SCREEN       ; 2
   bne .setToShowScoreOrEnergy; 2³
   bit gameState              ; 3         check the game state
   bmi .setToShowScoreOrEnergy; 2³        branch if player loss the game
   lda #>Copyright_0          ; 2         set to show copyright information
   bne .setGraphicPointersMSB ; 3         unconditional branch

.setToShowScoreOrEnergy
   lda #>NumberFonts          ; 2
.setGraphicPointersMSB
   sta graphicPointers + 1    ; 3
   sta graphicPointers + 3    ; 3
   sta graphicPointers + 5    ; 3
   sta graphicPointers + 7    ; 3
   sta graphicPointers + 9    ; 3
   sta graphicPointers + 11   ; 3
   sta WSYNC
;--------------------------------------
   lda currentScreenId        ; 3         get the current screen id
   cmp #ID_ET_HOME            ; 2
   bcc .setGraphicPointers    ; 2³        branch if not showing the score
   lda playerScore            ; 3
   sta tempNumberFonts        ; 3
   lda playerScore + 1        ; 3
   sta tempNumberFonts + 1    ; 3
   lda playerScore + 2        ; 3
   sta tempNumberFonts + 2    ; 3
.setGraphicPointers
   sta WSYNC
;--------------------------------------
   lda #LT_BLUE + 10          ; 2
   sta COLUBK                 ; 3 = @05
   lda tempNumberFonts        ; 3
   and #$F0                   ; 2
   bne .setGraphicsPointerLSB ; 2³
   lda #<[Blank * 2]          ; 2
.setGraphicsPointerLSB
   lsr                        ; 2
   sta graphicPointers        ; 3
   lda tempNumberFonts        ; 3
   and #$0F                   ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta graphicPointers + 2    ; 3
   sta WSYNC
;--------------------------------------
   lda tempNumberFonts + 1    ; 3
   and #$F0                   ; 2
   lsr                        ; 2
   sta graphicPointers + 4    ; 3
   lda tempNumberFonts + 1    ; 3
   and #$0F                   ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta graphicPointers + 6    ; 3
   sta WSYNC
;--------------------------------------
   lda #SHOW_HSW_INITIALS_VALUE; 2
   cmp programmerInitialFlag  ; 3
   bne .skipShowHSWInitials   ; 2³
   lda #[(<HSWInitials / 8) << 4] | [(<HSWInitials + 8) / 8]; 2
   sta tempNumberFonts + 2    ; 3
.skipShowHSWInitials
   lda tempNumberFonts + 2    ; 3
   and #$F0                   ; 2
   lsr                        ; 2
   sta graphicPointers + 8    ; 3
   lda tempNumberFonts + 2    ; 3
   and #$0F                   ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta graphicPointers + 10   ; 3
   sta WSYNC
;--------------------------------------
   ldy #<Blank                ; 2
   ldx currentScreenId        ; 3         get the current screen id
   cpx #ID_ET_HOME            ; 2
   bcc .suppressZeroDigits    ; 2³        branch if not ET_HOME or TITLE_SCREEN
   cpy graphicPointers        ; 3
   bne .checkToSetCopyrightInfo; 2³
   lda graphicPointers + 2    ; 3
   bne .checkToSetCopyrightInfo; 2³
   sty graphicPointers + 2    ; 3
.suppressZeroDigits
   lda graphicPointers + 4    ; 3
   bne .checkToSetCopyrightInfo; 2³
   sty graphicPointers + 4    ; 3
   lda graphicPointers + 6    ; 3
   bne .checkToSetCopyrightInfo; 2³
   sty graphicPointers + 6    ; 3
   lda graphicPointers + 8    ; 3
   bne .checkToSetCopyrightInfo; 2³
   sty graphicPointers + 8    ; 3
.checkToSetCopyrightInfo
   sta WSYNC
;--------------------------------------
   lda #>Copyright_0          ; 2
   cmp graphicPointers + 1    ; 3
   bne .skipSetCopyrightInfo  ; 2³
   lda #<BlankIcon            ; 2
   sta graphicPointers        ; 3
   lda #<Copyright_0          ; 2
   sta graphicPointers + 2    ; 3
   lda #<Copyright_1          ; 2
   sta graphicPointers + 4    ; 3
   lda #<Copyright_2          ; 2
   sta graphicPointers + 6    ; 3
   lda #<Copyright_3          ; 2
   sta graphicPointers + 8    ; 3
   lda #<Copyright_4          ; 2
   sta graphicPointers + 10   ; 3
.skipSetCopyrightInfo
   lda #H_FONT - 1            ; 2
   sta loopCount              ; 3
   jsr SixDigitKernel         ; 6
   sta WSYNC
;--------------------------------------
   lda #SELECT_MASK           ; 2
   and SWCHB                  ; 4   check console switch value
   bne Overscan               ; 2³  branch if SELECT not pressed
   lda #SET_STARTING_SCREEN | ID_TITLE_SCREEN
   sta startingScreenId
   sta gameState
   lda #$00
   sta mothershipStatus             ; clear Mothership status flags
Overscan
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta WSYNC
   ldx #$0F
   stx VBLANK                       ; disable TIA (D1 = 1)
   
   IF COMPILE_REGION = NTSC
   
      jsr Waste12Cycles
      jsr Waste12Cycles
      
   ELSE
   
      nop                           ; waste 12 cycles
      nop
      nop
      nop
      nop
      nop
      
   ENDIF
   
   ldx #OVERSCAN_TIME
   stx TIM64T                       ; set timer for overscan period
   ror SWCHB                        ; shift RESET into carry
   bcs .clearResetHeldFlag          ; branch if RESET not pressed
   lda #RESET_SWITCH_HELD
   bit fireResetStatus              ; check RESET held status
   bvs .skipResetStatus             ; branch if RESET held
   ora fireResetStatus              ; set flag to show RESET held this frame
   sta fireResetStatus
   jmp StartNewGame

.clearResetHeldFlag
   lda fireResetStatus
   and #<(~RESET_SWITCH_HELD)
   sta fireResetStatus
.skipResetStatus
   jsr CheckForYarIndyOrHSWEasterEgg
   jsr CheckToFlyYarSprite
   jsr DetermineToShowArtistInitials
   lda soundDataChannel0            ; get sound data for channel 0
   bmi CheckToPlaySoundForChannel0  ; branch if playing sound for channel 0
   ldx currentObjectId              ; get the current object id
   bmi .turnOffSoundChannel0        ; branch if not human or human not present
   lda currentScreenId              ; get the current screen id
   cmp #ID_ET_HOME
   beq CheckToPlaySoundForChannel0  ; branch if E.T. is home
   lda frameCount                   ; get the current frame count
   and #$0F
   beq PlayHumanWalkingSound
.turnOffSoundChannel0
   lda #PLAY_SOUND_CHANNEL0 | $00
   jmp .setChannel0SoundRegisters

PlayHumanWalkingSound
   lda #19
   sta AUDC0
   bit frameCount
   bne .setHumanWalkingFrequency
   lda #22
.setHumanWalkingFrequency
   sta AUDF0
   lda etHorizPos                   ; get E.T.'s horizontal position
   sbc currentObjectHorizPos        ; subtract human's horizontal position
   bpl .setHorizDistanceRange
   eor #$FF                         ; get absolute value of horiz distance
.setHorizDistanceRange
   sta humanETHorizDistRange
   lda etVertPos                    ; get E.T.'s vertical position
   sbc currentObjectVertPos         ; subtract human's vertical position
   asl                              ; multiply value by 2
   bpl .compareVertAndHorizDistance
   eor #$FF                         ; get absolute value of vert distance
.compareVertAndHorizDistance
   cmp humanETHorizDistRange
   bcs .divideDistanceRangeBy2
   lsr
   bpl .addWithHorizDistance        ; unconditional branch
   
.divideDistanceRangeBy2
   lsr humanETHorizDistRange
.addWithHorizDistance
   clc
   adc humanETHorizDistRange
   bpl .determineHumanSoundVolume
   lda #0
   beq .setHumanWalkingVolume       ; unconditional branch
   
.determineHumanSoundVolume
   lsr
   lsr
   lsr
   eor #$0F
.setHumanWalkingVolume
   sta AUDV0
CheckToPlaySoundForChannel0
   lda soundDataChannel0            ; get sound data for channel 0
   bpl .setToDontSetChannel0Data    ; branch if not player sound for channel 0
.setChannel0SoundRegisters
   sta AUDC0                        ; set sound channel 0 value
   sta AUDV0                        ; set sound channel 0 volume
   sta AUDF0                        ; set sound channel 0 frequency
   asl                              ; shift value left
   beq .setToDontSetChannel0Data    ; branch if channel set to off this frame
   lda #PLAY_SOUND_CHANNEL0 | $00   ; turn off channel 0 sound next frame
   sta soundDataChannel0
   bne .doneCheckToPlaySoundChannel0; unconditional branch
   
.setToDontSetChannel0Data
   lsr soundDataChannel0            ; shift value right (i.e. D7 = 0)
.doneCheckToPlaySoundChannel0
   bit mothershipStatus             ; check the Mothership status
   bmi .jmpToBANK0                  ; branch if Mothership is present
   lda currentScreenId              ; get the current screen id
   cmp #ID_ET_HOME
   beq DoETHomeProcessing           ; branch if ET HOME screen
   cmp #ID_TITLE_SCREEN
   bne .jmpCheckForElliottToReviveET; branch if not on TITLE SCREEN
   bit INPT4                        ; check player one fire button
   bmi .jmpToBANK0                  ; branch if fire button not pressed
   jmp StartNewGame

.jmpToBANK0
   jmp JumpToBank0

.jmpCheckForElliottToReviveET
   jmp CheckForElliottToReviveET

HeldCandyScoreLSB
   .byte $00,$90,$80,$70,$60,$50,$40,$30,$20,$10

HeldCandyScoreMSB
   .byte $00,$04,$09,$14,$19,$24,$29,$34,$39,$44

DoETHomeProcessing
   lda #3
   and frameCount
   bne .skipChangeElliottDirection
   bit etHomeElliottMovement        ; check Elliott move values
   bpl .moveElliottLeft
   inc currentObjectHorizPos        ; move Elliott right
   bne .checkToChangeElliottDirection; unconditional branch
   
.moveElliottLeft
   dec currentObjectHorizPos        ; move Elliott left
.checkToChangeElliottDirection
   lda currentObjectHorizPos        ; get Elliott's horizontal position
   sec
   sbc #28
   cmp #64
   bcc .skipChangeElliottDirection
   lda #MOVE_ELLIOTT_RIGHT
   eor etHomeElliottMovement        ; flip the flag to determine if Elliott
   sta etHomeElliottMovement        ; moves left or right on ET_HOME screen
.skipChangeElliottDirection
   bit collectedCandyScoring        ; check the collected candy scoring values
   bvs IncrementScoreForCollectedCandy;branch if scoring for collected candy
   lda frameCount                   ; get the current frame count
   cmp #96
   bne .checkToIncreaseScoreForHeldCandy
   ldy etEnergy + 1
   ldx etEnergy
   jmp .incrementScore

.checkToIncreaseScoreForHeldCandy
   cmp #192
   beq IncrementScoreForHeldCandy
   cmp #255
   bne .jmpToBranchToBANK0
   lda #COLLECT_CANDY_SCORE_INC
   ora collectedCandyScoring        ; set flag so we increment score for
   sta collectedCandyScoring        ; collected candy pieces
   bne .jmpToBranchToBANK0          ; unconditional branch

IncrementScoreForHeldCandy
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   lsr                              ; move upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   tay
   ldx HeldCandyScoreMSB,y
   lda HeldCandyScoreLSB,y
   tay
.incrementScore
   jsr IncrementScore
   lda #PLAY_SOUND_CHANNEL0 | $0C
   sta soundDataChannel0
   bne .jmpToBranchToBANK0          ; unconditional branch

IncrementScoreForCollectedCandy
   ldy collectedCandyPieces         ; get number of candy held by Elliott
   beq CheckIfPlayerWonGameRound    ; branch if Elliott has no candy
   lda frameCount                   ; get the current frame count
   and #$1F
   bne .openCandyEatingAnimation
   dey                              ; reduce number of candy held by Elliott
   sty collectedCandyPieces
   lda #PLAY_SOUND_CHANNEL0 | $0F
   sta soundDataChannel0
   lda #6
   sta unknown                      ; this not used in the game
   lda #CLOSED_EATING_CANDY_ICON    ; set collected candy scoring flag to
   ora collectedCandyScoring        ; show closed eating candy animation
   sta collectedCandyScoring
   ldx #$07
   ldy #$70
   jsr IncrementScore               ; increment score by 770 points
.jmpToBranchToBANK0
   jmp .branchToBANK0

.openCandyEatingAnimation
   cmp #$0F
   bne .jmpToBranchToBANK0
   lda #PLAY_SOUND_CHANNEL0 | $08
   sta soundDataChannel0
   lda collectedCandyScoring
   and #<(~CLOSED_EATING_CANDY_ICON); set collected candy scoring flag to
   sta collectedCandyScoring        ; show open eating candy animation
   jmp .branchToBANK0

CheckIfPlayerWonGameRound
   bit gameState                    ; check the game state
   bpl .checkToStartNextRound       ; branch if player won this round
   lda #SET_STARTING_SCREEN | ID_TITLE_SCREEN
   sta startingScreenId             ; set screen id to TITLE_SCREEN
   jmp JumpToBank0

.checkToStartNextRound
   bit INPT4                        ; check player one fire button
   bmi .jmpToBranchToBANK0          ; branch if fire button not pressed
   bpl .startNextGameRound          ; unconditional branch

StartNewGame
   lda #16
   sta extraCandyPieces
   sta gameState
   lda #INIT_NUM_TRIES - 1
   sta numberOfTries
   lda #0
   sta playerState                  ; reset player state
   sta collectedCandyPieces         ; initialize number of collected candy
   sta mothershipStatus             ; clear Mothership status flags
   sta etPitStatus                  ; clear E.T. pit status flags
   sta etNeckExtensionValues        ; clear neck extension values
   sta etMotionValues               ; clear E.T. motion value
   sta easterEggStatus              ; clear Easter Egg status flags
   sta playerScore
   sta playerScore + 1
   lda #$03
   sta playerScore + 2              ; set initial score to 3
.startNextGameRound
   rol fireResetStatus              ; rotate fire button held status to carry
   sec                              ; set carry and rotate value right to set
   ror fireResetStatus              ; fire button held status (i.e. D7 = 1)
   rol easterEggStatus              ; rotate status left
   clc                              ; clear carry and rotate status right to
   ror easterEggStatus              ; clear Easter Egg check done flag
   lda #SET_STARTING_SCREEN | ID_FOREST
   sta startingScreenId
   sta mothershipStatus
   lda #<-1
   sta fbiAttributes
   sta elliottAttributes
   sta scientistAttributes
   sta fbiAttributes
   sta elliottAttributes
   sta scientistAttributes
   sta shipLandingTimer
   lda #$0A
   sta heldCandyPieces
   lda frameCount                   ; get the current frame count
   eor secondTimer
   and #7
   cmp #ID_PIT
   bcc .setCallHomeScreenId         ; branch if value less than ID_PIT
   sbc #ID_FOREST                   ; subtract value to get it below ID_PIT
.setCallHomeScreenId
   sta callHomeScreenId
   lda secondTimer
   and #3
   tax
   lda frameCount                   ; get the current frame count
   and #FLOWER_PIT_NUMBER
   sta flowerState                  ; set flower pit number
   adc PsuedoRandomValueIncTable,x
   and #PHONE_PIECE_PIT_NUMBER
   sta s_phonePieceAttribute        ; set S phone piece location
   adc PsuedoRandomValueIncTable,x
   and #PHONE_PIECE_PIT_NUMBER
   sta h_phonePieceAttribute        ; set H phone piece location
   adc PsuedoRandomValueIncTable,x
   and #PHONE_PIECE_PIT_NUMBER
   sta w_phonePieceAttribute        ; set W phone piece location
   lda frameCount                   ; get the current frame count
   and #3
   tax
   lda secondTimer
   sta powerZoneLSBValue_01
   adc PsuedoRandomValueIncTable,x
   sta powerZoneLSBValue_02
   adc PsuedoRandomValueIncTable,x
   sta powerZoneLSBValue_03
   lda extraCandyPieces             ; get number of extra candy pieces
   cmp #31
   bcc .setStartingEnergyToMax
   sbc #31
   lsr                              ; divide value by 2
   tax
   lda NextRoundEnergyValues,x
   sta etEnergy
   sta etEnergy + 1
   lda NextRoundScoreMSB,x
   tax
   ldy #$00
   jsr IncrementScore
   lda #31
   sta extraCandyPieces
   bne CheckForElliottToReviveET    ; unconditional branch

.setStartingEnergyToMax
   lda #MAX_ENERGY
   sta etEnergy
   sta etEnergy + 1
   bne CheckForElliottToReviveET    ; unconditional branch

.branchToBANK0
   jmp JumpToBank0

CheckForElliottToReviveET
   bit playerState                  ; check player state
   bpl JumpToBank0                  ; branch if E.T. is not dead
   bvs JumpToBank0                  ; branch if Elliott coming to revive E.T.
   lda #RETURN_HOME
   sta fbiAttributes                ; set human objects to return home
   sta elliottAttributes
   sta scientistAttributes
   lda #$00
   sta etNeckExtensionValues        ; clear neck extension values
   lda currentScreenId              ; get the current screen id
   cmp #ID_PIT
   bne .setToSendElliottForET       ; branch if E.T. not in a pit
   lda etPitStatus                  ; get E.T. pit status values
   and #IN_PIT_BOTTOM
   bne .setToSendElliottForET       ; branch if E.T. reached bottom of pit
   lda #FALLING_IN_PIT
   sta etPitStatus                  ; set status to show E.T. falling in a pit
   ldx #<-1
   stx currentObjectId
   inx                              ; x = 0
   stx currentSpriteHeight
.setToSendElliottForET
   lda #ELLIOTT_REVIVE_ET
   ora playerState
   sta playerState
JumpToBank0
   lda #<SetScreenIdFromStartingScreen
   sta bankSwitchRoutinePtr
   lda #>SetScreenIdFromStartingScreen
   sta bankSwitchRoutinePtr + 1
   lda #LDA_ABS
   sta displayKernelBankSwitch
   lda #<BANK0STROBE
   sta bankSwitchStrobe
   lda #>BANK0STROBE
   sta bankSwitchStrobe + 1
   lda #JMP_ABS
   sta bankSwitchABSJmp
   jmp.w displayKernelBankSwitch

IncrementScore
   sed
   sty pointsTensValue
   clc
   lda playerScore + 2
   adc pointsTensValue
   sta playerScore + 2
   stx pointsHundredsValue
   lda playerScore + 1
   adc pointsHundredsValue
   sta playerScore + 1
   lda playerScore
   adc #$00
   sta playerScore
   cld
Waste12Cycles
   rts

SixDigitKernel
.sixDigitLoop
   ldy loopCount              ; 3
   lda (graphicPointers),y    ; 5
   sta GRP0                   ; 3
   sta WSYNC
;--------------------------------------
   lda (graphicPointers + 2),y; 5
   sta GRP1                   ; 3 = @08
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @16
   lda (graphicPointers + 6),y; 5
   sta tempCharHolder         ; 3
   lda (graphicPointers + 8),y; 5
   tax                        ; 2
   lda (graphicPointers + 10),y;5
   tay                        ; 2
   lda tempCharHolder         ; 3
   sta GRP1                   ; 3 = @34
   stx GRP0                   ; 3 = @37
   sty GRP1                   ; 3 = @40
   sty GRP0                   ; 3 = @43
   dec loopCount              ; 5
   bpl .sixDigitLoop          ; 2³
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   sta GRP1                   ; 3 = @06
   sta GRP0                   ; 3 = @09
   sta GRP1                   ; 3 = @12
   sta NUSIZ0                 ; 3 = @15   set to show ONE_COPY of players
   sta NUSIZ1                 ; 3 = @18
   sta VDELP0                 ; 3 = @21   turn off vertical delay
   sta VDELP1                 ; 3 = @24
   sta WSYNC
;--------------------------------------
   rts                        ; 6

DisplayKernel
StatusKernel
   lda #THREE_MED_COPIES      ; 2
   sta NUSIZ1                 ; 3
   lda #DK_PINK + 2           ; 2
   sta COLUBK                 ; 3
   lda #ENABLE_TIA            ; 2
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3         enable TIA (D1 = 0)
   sta HMCLR                  ; 3
   sta CXCLR                  ; 3         clear all collisions
   lda #>GameIcons            ; 2
   sta graphicPointers + 1    ; 3
   sta graphicPointers + 3    ; 3
   lda #>Telephone            ; 2
   sta graphicPointers + 5    ; 3
   sta WSYNC
;--------------------------------------
   ldx #NUM_PHONE_PIECES      ; 2
   bit h_phonePieceAttribute  ; 3         check H phone piece value
   bpl .checkForCarringSPiece ; 2³        branch if E.T. not taken H piece
   dex                        ; 2
.checkForCarringSPiece
   bit s_phonePieceAttribute  ; 3         check S phone piece value
   bpl .checkForCarringWPiece ; 2³        branch if E.T. not taken S piece
   dex                        ; 2
.checkForCarringWPiece
   bit w_phonePieceAttribute  ; 3         check W phone piece value
   bpl .setTelephoneIconLSB   ; 2³        branch if E.T. not taken W piece
   dex                        ; 2
.setTelephoneIconLSB
   lda TelephoneIconLSBPtrs,x ; 4
   sta graphicPointers + 4    ; 3
   sta WSYNC
;--------------------------------------
   lda #$00                   ; 2
   ldy currentScreenId        ; 3         get the current screen id
   cpy #ID_ET_HOME            ; 2
   bcc .setupToDrawStatusIcons; 2³
   sta graphicPointers + 2    ; 3
   sta graphicPointers + 4    ; 3
   bne .setupToDrawGameSelection; 2³
   ldx #<EatCandyIcon_0       ; 2
   lda collectedCandyScoring  ; 3         get collected candy scoring value
   ror                        ; 2         shift D0 to carry and branch if
   bcc .setEatingCandyLSB     ; 2³        showing open eating candy animation
   ldx #<EatCandyIcon_1       ; 2
.setEatingCandyLSB
   stx graphicPointers        ; 3
   bne .setupToDrawStatusIcons; 3         unconditional branch

.setupToDrawGameSelection
   lda #>NumberFonts          ; 2
   sta graphicPointers + 1    ; 3
   lda gameSelection          ; 3         get the current game selection
   asl                        ; 2         multiply game selection by 8 (i.e.
   asl                        ; 2         height of digits)
   asl                        ; 2
   sta graphicPointers        ; 3
.setupToDrawStatusIcons
   sta WSYNC
;--------------------------------------
   bit mothershipStatus       ; 3         check Mothership status
   bpl .checkToDrawArtistInitials; 2³        branch if Mothership not present
   lda #$00                   ; 2
   sta graphicPointers + 2    ; 3
   sta graphicPointers + 4    ; 3
.checkToDrawArtistInitials
   lda artistInitialFlag      ; 3
   beq .prepareToDrawIndicators; 2³
   lda #<ArtistInitials       ; 2
   sta graphicPointers + 2    ; 3
.prepareToDrawIndicators
   lda #H_FONT - 1            ; 2
   sta loopCount              ; 3
.drawStatusKernelLoop
   ldy loopCount              ; 3
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda powerZoneColor         ; 3         get power zone color
   pha                        ; 3         push power zone color to stack
   lda telephoneColor         ; 3         get telephone color
   sta COLUP1                 ; 3 = @16   color telephone icon
   lda (graphicPointers + 4),y; 5
   sta GRP1                   ; 3 = @24
   lda (graphicPointers),y    ; 5
   tax                        ; 2
   lda (graphicPointers + 2),y; 5
   tay                        ; 2
   pla                        ; 4         pull power zone color from stack
   sta COLUP1                 ; 3 = @45   color power zone icon
   stx GRP1                   ; 3 = @48
   lda timerColor             ; 3         get the timer color
   sta COLUP1                 ; 3 = @54   color timer icon
   sty GRP1                   ; 3 = @57
   dec loopCount              ; 5
   bpl .drawStatusKernelLoop  ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP1                   ; 3 = @05
   sta NUSIZ1                 ; 3 = @08
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUBK                 ; 3 = @05
   ldx #<[RESP1 - RESP0]      ; 2
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda etHMOVEValue           ; 3
   lda etHMOVEValue           ; 3
   sta HMP0,x                 ; 4 = @14
   and #$0F                   ; 2
   tay                        ; 2
.coarsePositionET
   dey                        ; 2
   bpl .coarsePositionET      ; 2³
   sta RESP0,x                ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #MSBL_SIZE2 | PF_REFLECT; 2
   ldx currentScreenId        ; 3         get the current screen id
   cpx #ID_WASHINGTON_DC      ; 2
   bne .setPlayfieldPriority  ; 2³
   lda #MSBL_SIZE2 | PF_PRIORITY | PF_REFLECT; 2
.setPlayfieldPriority
   sta CTRLPF                 ; 3
   ldx #$FF                   ; 2
   bit SWCHA                  ; 4         check joystick values
   bpl .setETReflectState     ; 2³        branch if joystick pushed right
   inx                        ; 2         x = 0
.setETReflectState
   stx REFP1                  ; 3
   ldx currentObjectId        ; 3         get the current object id
   bmi .skipHumanReflection   ; 2³
   bit etMotionValues         ; 3         check E.T. motion values
   bvs .skipHumanReflection   ; 2³        branch if E.T. carried by Scientist
   ldy #$FF                   ; 2
   lda humanAttributes,x      ; 4         get human attribute value
   bpl .turnToFaceET          ; 2³        branch if not returning home
   lda HumanHorizReflectionTable,x; 4
   bne .determineHumanReflection; 3       unconditional branch

.turnToFaceET
   lda etHorizPos             ; 3         get E.T.'s horizontal position
.determineHumanReflection
   cmp currentObjectHorizPos  ; 3
   bcc .setHumanReflectState  ; 2³
   iny                        ; 2
.setHumanReflectState
   sty REFP0                  ; 3
.skipHumanReflection
   sta WSYNC
;--------------------------------------
   ldx currentScreenId        ; 3         get the current screen id
   cpx #ID_ET_HOME            ; 2
   bne .determineETColorFromEnergy; 2³
   bit etHomeElliottMovement  ; 3         check Elliott movement value
   bpl .moveElliottBehindHouse; 2³        branch if Elliott moving left
   lda #MSBL_SIZE2 | PF_REFLECT; 2
   sta CTRLPF                 ; 3
   bne .setCurrentObjectReflectState; 3   unconditional branch

.moveElliottBehindHouse
   lda #MSBL_SIZE2 | PF_PRIORITY | PF_REFLECT; 2
   sta CTRLPF                 ; 3
   lda #$FF                   ; 2
.setCurrentObjectReflectState
   sta REFP0                  ; 3
.determineETColorFromEnergy
   ldx #$00                   ; 2
   bit playerState            ; 3         check current player state
   bmi .setETColor            ; 2³        branch if E.T. is dead
   lda etEnergy               ; 3         get E.T. energy level
   lsr                        ; 2         divide E.T. energy level by 32 to
   lsr                        ; 2         get E.T. color value
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tax                        ; 2
   inx                        ; 2
.setETColor
   lda ETColors,x             ; 4
   sta COLUP1                 ; 3         set E.T. color based on current state
   sta WSYNC
;--------------------------------------
   ldx currentScreenId        ; 3         get the current screen id
   lda PlayfieldColors,x      ; 4
   sta COLUPF                 ; 3 = @10
   ldy #$FF                   ; 2
   sty PF0                    ; 3 = @15
   sty PF1                    ; 3 = @18
   sty PF2                    ; 3 = @21
   lda BackgroundColors,x     ; 4
   sta COLUBK                 ; 3 = @28
   lda #MSBL_SIZE4            ; 2
   bit mothershipStatus       ; 3         check Mothership status
   bpl .setCurrentObjectSize  ; 2³        branch if Mothership not present
   lda #MSBL_SIZE4 | DOUBLE_SIZE; 2       set Mothership to DOUBLE_SIZE
.setCurrentObjectSize
   sta NUSIZ0                 ; 3 = @40
   lda #MSBL_SIZE4            ; 2
   sta NUSIZ1                 ; 3 = @45
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   ldy currentScreenId        ; 3         get the current screen id
   sta WSYNC
;--------------------------------------
   lda #$00                   ; 2
   sta PF1                    ; 3 = @05
   sta PF2                    ; 3 = @08
   ldx KernelJumpTableIndex,y ; 4
   lda KernelJumpTable + 1,x  ; 4
   pha                        ; 3
   lda KernelJumpTable,x      ; 4
   pha                        ; 3
   lda #0                     ; 2
   tax                        ; 2
   tay                        ; 2
   sta nextETGraphicData      ; 3
   sta nextObjectGraphicData  ; 3
   sta nextObjectColorData    ; 3
   rts                        ; 6

CheckForYarIndyOrHSWEasterEgg
   lda flowerState                  ; get flower state
   and #$F0
   cmp #FLOWER_REVIVED | (1 * 16)
   bne .doneEasterEggCheck          ; branch if flower not revived
   bit easterEggStatus
   bmi .doneEasterEggCheck          ; branch if check done this round
   lda collectedCandyPieces         ; get number of candy held by Elliott
   cmp #7
   bne .setEasterEggStepNotDone     ; branch if not holding 7 pieces of candy
   lda easterEggStatus              ; get Easter Egg status
   and #3
   cmp #3
   bne .checkIfETTookPhonePiece     ; branch if first two steps not done
   lda #2
.checkIfETTookPhonePiece
   tax
   lda phonePieceAttributes,x       ; get phone piece attribute value
   bpl .setEasterEggStepNotDone     ; branch if E.T. not taken phone piece
   ldx easterEggStatus              ; get Easter Egg status
   cpx #2
   bcs .setEasterEggStepDone        ; branch if at least two steps done
   lda EasterEggSpriteValues,x
   sta easterEggSpriteFlag
   lda #50
   sta currentObjectVertPos
.setEasterEggStepDone
   sec
   bcs .setEasterEggStatusFlags     ; unconditional branch
   
.setEasterEggStepNotDone
   clc
.setEasterEggStatusFlags
   lda easterEggStatus              ; get Easter Egg status
   rol                              ; rotate carry flag into D0
   ora #DONE_EASTER_EGG_CHECK
   sta easterEggStatus              ; show Easter Egg check done this round
   and #DONE_EASTER_EGG_STEPS
   cmp #DONE_EASTER_EGG_STEPS
   bne .doneEasterEggCheck          ; branch if all steps not done
   lda #SHOW_HSW_INITIALS_VALUE     ; set value to show HSW's initials :-)
   sta programmerInitialFlag
.doneEasterEggCheck
   rts

   BOUNDARY 0

TitleETGraphics
TitleETGraphics_0
   .byte $D0 ; |XX.X....|
   .byte $00 ; |........|
   .byte $D0 ; |XX.X....|
   .byte $E0 ; |XXX.....|
   .byte $10 ; |...X....|
   .byte $E0 ; |XXX.....|
   .byte $50 ; |.X.X....|
   .byte $F0 ; |XXXX....|
   .byte $40 ; |.X......|
   .byte $F0 ; |XXXX....|
   .byte $A0 ; |X.X.....|
   .byte $D0 ; |XX.X....|
   .byte $A8 ; |X.X.X...|
   .byte $F4 ; |XXXX.X..|
   .byte $C8 ; |XX..X...|
   .byte $F0 ; |XXXX....|
   .byte $A8 ; |X.X.X...|
   .byte $D4 ; |XX.X.X..|
   .byte $EC ; |XXX.XX..|
   .byte $D8 ; |XX.XX...|
   .byte $74 ; |.XXX.X..|
   .byte $F8 ; |XXXXX...|
   .byte $B4 ; |X.XX.X..|
   .byte $F8 ; |XXXXX...|
   .byte $F4 ; |XXXX.X..|
   .byte $58 ; |.X.XX...|
   .byte $F8 ; |XXXXX...|
   .byte $D8 ; |XX.XX...|
   .byte $D0 ; |XX.X....|
   .byte $D0 ; |XX.X....|
   .byte $A0 ; |X.X.....|
   .byte $40 ; |.X......|
   .byte $80 ; |X.......|
TitleETGraphics_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
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
   .byte $03 ; |......XX|
   .byte $02 ; |......X.|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $0D ; |....XX.X|
   .byte $0F ; |....XXXX|
   .byte $1D ; |...XXX.X|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
   .byte $1B ; |...XX.XX|
   .byte $1D ; |...XXX.X|
   .byte $1E ; |...XXXX.|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
TitleETGraphics_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $06 ; |.....XX.|
   .byte $0D ; |....XX.X|
   .byte $08 ; |....X...|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $2F ; |..X.XXXX|
   .byte $1F ; |...XXXXX|
   .byte $37 ; |..XX.XXX|
   .byte $3F ; |..XXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $DD ; |XX.XXX.X|
   .byte $6F ; |.XX.XXXX|
   .byte $B5 ; |X.XX.X.X|
   .byte $1B ; |...XX.XX|
   .byte $1D ; |...XXX.X|
   .byte $17 ; |...X.XXX|
   .byte $3A ; |..XXX.X.|
   .byte $1D ; |...XXX.X|
   .byte $1A ; |...XX.X.|
   .byte $B5 ; |X.XX.X.X|
   .byte $5E ; |.X.XXXX.|
   .byte $F5 ; |XXXX.X.X|
   .byte $6B ; |.XX.X.XX|
   .byte $A7 ; |X.X..XXX|
   .byte $5F ; |.X.XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $7B ; |.XXXX.XX|
TitleETGraphics_3
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7F ; |.XXXXXXX|
   .byte $C0 ; |XX......|
   .byte $AA ; |X.X.X.X.|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EF ; |XXX.XXXX|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $27 ; |..X..XXX|
   .byte $25 ; |..X..X.X|
   .byte $FE ; |XXXXXXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $FE ; |XXXXXXX.|
   .byte $7B ; |.XXXX.XX|
   .byte $D6 ; |XX.X.XX.|
   .byte $BF ; |X.XXXXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $EF ; |XXX.XXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $D3 ; |XX.X..XX|
   .byte $A1 ; |X.X....X|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
TitleETGraphics_4
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $C1 ; |XX.....X|
   .byte $61 ; |.XX....X|
   .byte $30 ; |..XX....|
   .byte $98 ; |X..XX...|
   .byte $9E ; |X..XXXX.|
   .byte $0F ; |....XXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $ED ; |XXX.XX.X|
   .byte $FA ; |XXXXX.X.|
   .byte $F7 ; |XXXX.XXX|
   .byte $EF ; |XXX.XXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $FF ; |XXXXXXXX|
   .byte $D5 ; |XX.X.X.X|
   .byte $A2 ; |X.X...X.|
   .byte $63 ; |.XX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $67 ; |.XX..XXX|
   .byte $E3 ; |XXX...XX|
   .byte $A2 ; |X.X...X.|
   .byte $D5 ; |XX.X.X.X|
   .byte $7F ; |.XXXXXXX|
   .byte $AA ; |X.X.X.X.|
   .byte $D5 ; |XX.X.X.X|
   .byte $FB ; |XXXXX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $2A ; |..X.X.X.|
TitleETGraphics_5
   .byte $FF ; |XXXXXXXX|
   .byte $15 ; |...X.X.X|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $4A ; |.X..X.X.|
   .byte $BF ; |X.XXXXXX|
   .byte $5F ; |.X.XXXXX|
   .byte $2D ; |..X.XX.X|
   .byte $57 ; |.X.X.XXX|
   .byte $BB ; |X.XXX.XX|
   .byte $DD ; |XX.XXX.X|
   .byte $EE ; |XXX.XXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $DD ; |XX.XXX.X|
   .byte $EE ; |XXX.XXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $57 ; |.X.X.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $EB ; |XXX.X.XX|
   .byte $B5 ; |X.XX.X.X|
   .byte $DF ; |XX.XXXXX|
   .byte $EA ; |XXX.X.X.|
   .byte $FF ; |XXXXXXXX|
   .byte $5A ; |.X.XX.X.|
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $F7 ; |XXXX.XXX|
   .byte $BE ; |X.XXXXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $F6 ; |XXXX.XX.|
   .byte $F5 ; |XXXX.X.X|
   .byte $F4 ; |XXXX.X..|
   .byte $E8 ; |XXX.X...|
   .byte $D0 ; |XX.X....|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
NextRoundScoreMSB
   .byte $00, $10, $22, $34, $45, $63, $78, $99
   
NextRoundEnergyValues
   .byte $99, $92, $84, $76, $68, $59, $51, $42

ETColors
   .byte WHITE, DK_GREEN + 14, DK_GREEN + 12, DK_GREEN + 10
   .byte DK_GREEN + 10, DK_GREEN + 10, BLACK

WideDiamondPitGraphics
WideDiamondPitPF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
KernelJumpTableIndex
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
WideDiamondPitPF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
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

ForestGraphics
ForestPF1Graphics
   .byte $AA ; |X.X.X.X.|
   .byte $55 ; |.X.X.X.X|
   .byte $AB ; |X.X.X.XX|
   .byte $57 ; |.X.X.XXX|
   .byte $A2 ; |X.X...X.|
   .byte $C1 ; |XX.....X|
   .byte $C0 ; |XX......|
   .byte $55 ; |.X.X.X.X|
   .byte $A2 ; |X.X...X.|
   .byte $C1 ; |XX.....X|
   .byte $C0 ; |XX......|
   .byte $55 ; |.X.X.X.X|
   .byte $A2 ; |X.X...X.|
   .byte $C1 ; |XX.....X|
   .byte $C0 ; |XX......|
   .byte $55 ; |.X.X.X.X|
   .byte $A2 ; |X.X...X.|
   .byte $C1 ; |XX.....X|
   .byte $D0 ; |XX.X....|
   .byte $55 ; |.X.X.X.X|
   .byte $BA ; |X.XXX.X.|
   .byte $7D ; |.XXXXX.X|
   .byte $FC ; |XXXXXX..|
   .byte $55 ; |.X.X.X.X|
   .byte $BA ; |X.XXX.X.|
   .byte $7D ; |.XXXXX.X|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $38 ; |..XXX...|
   .byte $7D ; |.XXXXX.X|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $38 ; |..XXX...|
   .byte $7D ; |.XXXXX.X|
   .byte $FE ; |XXXXXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $38 ; |..XXX...|
   .byte $55 ; |.X.X.X.X|
   .byte $AA ; |X.X.X.X.|
   .byte $55 ; |.X.X.X.X|
   .byte $2B ; |..X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $83 ; |X.....XX|
   .byte $01 ; |.......X|
   .byte $AB ; |X.X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $83 ; |X.....XX|
   .byte $01 ; |.......X|
   .byte $AB ; |X.X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $83 ; |X.....XX|
   .byte $01 ; |.......X|
   .byte $AB ; |X.X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $83 ; |X.....XX|
   .byte $01 ; |.......X|
   .byte $AB ; |X.X.X.XX|
   .byte $C5 ; |XX...X.X|
   .byte $82 ; |X.....X.|
   .byte $C1 ; |XX.....X|
   .byte $EA ; |XXX.X.X.|
   .byte $E5 ; |XXX..X.X|
   .byte $AA ; |X.X.X.X.|
   .byte $D5 ; |XX.X.X.X|
ForestPF2Graphics
   .byte $55 ; |.X.X.X.X|
   .byte $AB ; |X.X.X.XX|
   .byte $57 ; |.X.X.XXX|
   .byte $2F ; |..X.XXXX|
   .byte $15 ; |...X.X.X|
   .byte $0B ; |....X.XX|
   .byte $55 ; |.X.X.X.X|
   .byte $2A ; |..X.X.X.|
   .byte $15 ; |...X.X.X|
   .byte $0E ; |....XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $15 ; |...X.X.X|
   .byte $0E ; |....XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $15 ; |...X.X.X|
   .byte $0E ; |....XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $15 ; |...X.X.X|
   .byte $0E ; |....XXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $AE ; |X.X.XXX.|
   .byte $54 ; |.X.X.X..|
   .byte $A8 ; |X.X.X...|
   .byte $D0 ; |XX.X....|
   .byte $EA ; |XXX.X.X.|
   .byte $F4 ; |XXXX.X..|
   .byte $A8 ; |X.X.X...|
   .byte $D0 ; |XX.X....|
   .byte $EA ; |XXX.X.X.|
   .byte $F4 ; |XXXX.X..|
   .byte $A8 ; |X.X.X...|
   .byte $D0 ; |XX.X....|
   .byte $EA ; |XXX.X.X.|
   .byte $F4 ; |XXXX.X..|
   .byte $A8 ; |X.X.X...|
   .byte $D1 ; |XX.X...X|
   .byte $EB ; |XXX.X.XX|
   .byte $F7 ; |XXXX.XXX|
   .byte $AA ; |X.X.X.X.|
   .byte $D5 ; |XX.X.X.X|
   .byte $EB ; |XXX.X.XX|
   .byte $C7 ; |XX...XXX|
   .byte $82 ; |X.....X.|
   .byte $81 ; |X......X|
   .byte $AB ; |X.X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $82 ; |X.....X.|
   .byte $01 ; |.......X|
   .byte $AB ; |X.X.X.XX|
   .byte $47 ; |.X...XXX|
   .byte $8A ; |X...X.X.|
   .byte $1D ; |...XXX.X|
   .byte $BE ; |X.XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $AA ; |X.X.X.X.|
   .byte $1D ; |...XXX.X|
   .byte $BE ; |X.XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $AA ; |X.X.X.X.|

KernelJumpTable
   .word JumpIntoGameKernel - 1
   .word TitleScreenKernel - 1

PsuedoRandomValueIncTable
   .byte 115, 13, 91, 213
   
   BOUNDARY 0
   
ETSprites
ETWalkSprite_A0
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2B ; |..X.X.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|
   
ETExtensionSprites_A
ETExtensionSprite_A0
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2B ; |..X.X.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|
ETExtensionSprite_A1
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2B ; |..X.X.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|
ETExtensionSprite_A2
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2B ; |..X.X.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|
ETExtensionSprite_A3
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2B ; |..X.X.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|

ETWalkSprite_B0   
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
ETExtensionSprites_B
ETExtensionSprite_B0
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
ETExtensionSprite_B1
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
ETExtensionSprite_B2
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
ETExtensionSprite_B3
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
ETDead_0
   .byte $E0 ; |XXX.....|
   .byte $A2 ; |X.X...X.|
   .byte $E7 ; |XXX..XXX|
   .byte $EE ; |XXX.XXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $00 ; |........|
ETDead_1
   .byte $E0 ; |XXX.....|
   .byte $E3 ; |XXX...XX|
   .byte $EF ; |XXX.XXXX|
   .byte $ED ; |XXX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|

ETWalkSprite_A1
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $60 ; |.XX.....|
   .byte $00 ; |........|
ETWalkSprite_B1
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $27 ; |..X..XXX|
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
ETWalkSprite_A2
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
ETWalkSprite_B2
   .byte $BF ; |X.XXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $1F ; |...XXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $E1 ; |XXX....X|
   .byte $07 ; |.....XXX|
   .byte $00 ; |........|

ETTitle_E
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $DC ; |XX.XXX..|
   .byte $CE ; |XX..XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $D8 ; |XX.XX...|
   .byte $CC ; |XX..XX..|
   .byte $C6 ; |XX...XX.|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $78 ; |.XXXX...|
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|

ETTitle_T
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|
   .byte $0F ; |....XXXX|

FlowerSpritesA
Flower_A0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0A ; |....X.X.|
   .byte $1A ; |...XX.X.|
   .byte $76 ; |.XXX.XX.|
   .byte $3A ; |..XXX.X.|
Flower_A1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $20 ; |..X.....|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
Flower_A2
   .byte $00 ; |........|
   .byte $14 ; |...X.X..|
   .byte $1C ; |...XXX..|
   .byte $10 ; |...X....|
   .byte $1C ; |...XXX..|
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
Flower_A3
   .byte $14 ; |...X.X..|
   .byte $1C ; |...XXX..|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $18 ; |...XX...|

FlowerSpritesB
Flower_B0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0D ; |....XX.X|
   .byte $07 ; |.....XXX|
   .byte $40 ; |.X......|
   .byte $08 ; |....X...|
Flower_B1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $2A ; |..X.X.X.|
   .byte $0A ; |....X.X.|
   .byte $20 ; |..X.....|
   .byte $0A ; |....X.X.|
   .byte $08 ; |....X...|
Flower_B2
   .byte $00 ; |........|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $10 ; |...X....|
   .byte $12 ; |...X..X.|
   .byte $28 ; |..X.X...|
   .byte $08 ; |....X...|
Flower_B3
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $08 ; |....X...|
   .byte $0A ; |....X.X.|
   .byte $08 ; |....X...|
   .byte $28 ; |..X.X...|
   .byte $08 ; |....X...|

FlowerColors
   .byte BROWN + 14, BROWN + 14, BROWN + 12, ORANGE + 10
   .byte ORANGE + 8, ORANGE + 6, ORANGE + 4

EasterEggSpriteValues
   .byte SHOW_YAR_SPRITE, SHOW_INDY_SPRITE
   
   BOUNDARY 0

NumberFonts
zero
   .byte $FE ; |XXXXXXX.|
   .byte $86 ; |X....XX.|
   .byte $86 ; |X....XX.|
   .byte $86 ; |X....XX.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
one
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
two
   .byte $FE ; |XXXXXXX.|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $02 ; |......X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
three
   .byte $FE ; |XXXXXXX.|
   .byte $86 ; |X....XX.|
   .byte $06 ; |.....XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $02 ; |......X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
four
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
five
   .byte $FE ; |XXXXXXX.|
   .byte $86 ; |X....XX.|
   .byte $06 ; |.....XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $80 ; |X.......|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
six
   .byte $FE ; |XXXXXXX.|
   .byte $86 ; |X....XX.|
   .byte $86 ; |X....XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $80 ; |X.......|
   .byte $88 ; |X...X...|
   .byte $F8 ; |XXXXX...|
   .byte $00 ; |........|
seven
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
eight
   .byte $FE ; |XXXXXXX.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|
nine
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
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

HSWInitials
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $57 ; |.X.X.XXX|
   .byte $54 ; |.X.X.X..|
   .byte $77 ; |.XXX.XXX|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|

   .byte $07 ; |.....XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $71 ; |.XXX...X|
   .byte $73 ; |.XXX..XX|
   .byte $51 ; |.X.X...X|
   .byte $55 ; |.X.X.X.X|
   .byte $57 ; |.X.X.XXX|
   .byte $00 ; |........|

ElliottSprites
Elliott_0
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $7C ; |.XXXXX..|
   .byte $D8 ; |XX.XX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $EC ; |XXX.XX..|
   .byte $82 ; |X.....X.|
   .byte $84 ; |X....X..|
Elliott_1
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $5C ; |.X.XXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $60 ; |.XX.....|
   .byte $06 ; |.....XX.|
Elliott_2
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $20 ; |..X.....|
   .byte $38 ; |..XXX...|
Elliott_3
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
Elliott_4
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $68 ; |.XX.X...|
   .byte $CC ; |XX..XX..|
   .byte $00 ; |........|
Elliott_5
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $DC ; |XX.XXX..|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $68 ; |.XX.X...|
   .byte $CC ; |XX..XX..|

ElliottColors_A
   .byte BLACK, BLACK, ORANGE_2 + 8, RED + 10, RED + 10, RED + 10, LT_BLUE + 10
   .byte LT_BLUE + 10, LT_BLUE + 10, DK_GREEN_2 + 14, DK_GREEN_2 + 14

Elliott_6
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $5C ; |.X.XXX..|
   .byte $B8 ; |X.XXX...|
   .byte $38 ; |..XXX...|
   .byte $68 ; |.XX.X...|
   .byte $CC ; |XX..XX..|
   .byte $86 ; |X....XX.|
   .byte $00 ; |........|
Elliott_7
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $5C ; |.X.XXX..|
   .byte $78 ; |.XXXX...|
   .byte $18 ; |...XX...|
   .byte $78 ; |.XXXX...|
   .byte $60 ; |.XX.....|
   .byte $06 ; |.....XX.|
   .byte $00 ; |........|
Elliott_8
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
Elliott_9
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $60 ; |.XX.....|
   .byte $00 ; |........|
Elliott_10
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $28 ; |..X.X...|
   .byte $0C ; |....XX..|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
Elliott_11
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $5C ; |.X.XXX..|
   .byte $B8 ; |X.XXX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   
ElliottColors_B
   .byte BLACK, ORANGE_2 + 8, RED + 4, RED + 4, RED + 4, LT_BLUE + 10
   .byte LT_BLUE + 10, LT_BLUE + 10, LT_BLUE + 10, DK_GREEN_2 + 14
   .byte DK_GREEN_2 + 14

FourDiamondPitGraphics
FourDiamondPitPF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
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
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
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
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
EightPitGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $E0 ; |XXX.....|
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
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
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
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|

ArrowPitGraphics
ArrowPitPF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
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
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
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
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
ArrowPitPF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Telephone
   .byte $3C ; |..XXXX..|
   .byte $20 ; |..X.....|
   .byte $3C ; |..XXXX..|
   .byte $20 ; |..X.....|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|

TelephoneIconLSBPtrs
   .byte <Telephone, <Telephone - 3, <Telephone - 5, <Telephone - 9

YarSprites
Yar_0
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $7E ; |.XXXXXX.|
   .byte $5A ; |.X.XX.X.|
   .byte $DB ; |XX.XX.XX|
   .byte $3C ; |..XXXX..|
Yar_1
   .byte $24 ; |..X..X..|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   
   BOUNDARY 0

GameIcons
BlankIcon
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
WarpLeftIcon
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $60 ; |.XX.....|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
WarpRightIcon
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
WarpUpIcon
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
WarpDownIcon
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
QuestionIcon
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $1C ; |...XXX..|
   .byte $0E ; |....XXX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
EatCandyIcon_0
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $99 ; |X..XX..X|
   .byte $99 ; |X..XX..X|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
WashingtonIcon
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
CallElliottIcon
   .byte $02 ; |......X.|
   .byte $74 ; |.XXX.X..|
   .byte $C0 ; |XX......|
   .byte $F7 ; |XXXX.XXX|
   .byte $D0 ; |XX.X....|
   .byte $F4 ; |XXXX.X..|
   .byte $62 ; |.XX...X.|
   .byte $01 ; |.......X|
CallShipIcon
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $7E ; |.XXXXXX.|
   .byte $BD ; |X.XXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
LandingZoneIcon
   .byte $00 ; |........|
   .byte $7F ; |.XXXXXXX|
   .byte $49 ; |.X..X..X|
   .byte $5D ; |.X.XXX.X|
   .byte $77 ; |.XXX.XXX|
   .byte $5D ; |.X.XXX.X|
   .byte $49 ; |.X..X..X|
   .byte $7F ; |.XXXXXXX|
LevitateIcon
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
ReviveFlowerIcon
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $41 ; |.X.....X|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   
CountdownClockIcons
CountdownClock_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
CountdownClock_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $E0 ; |XXX.....|
   .byte $D0 ; |XX.X....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
CountdownClock_2
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $D0 ; |XX.X....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
CountdownClock_3
   .byte $70 ; |.XXX....|
   .byte $B0 ; |X.XX....|
   .byte $D0 ; |XX.X....|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $D0 ; |XX.X....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
CountdownClock_4   
   .byte $7E ; |.XXXXXX.|
   .byte $BC ; |X.XXXX..|
   .byte $D8 ; |XX.XX...|
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $D0 ; |XX.X....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
CountdownClock_5   
   .byte $7E ; |.XXXXXX.|
   .byte $BD ; |X.XXXX.X|
   .byte $DB ; |XX.XX.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $E0 ; |XXX.....|
   .byte $D0 ; |XX.X....|
   .byte $B0 ; |X.XX....|
   .byte $70 ; |.XXX....|
CountdownClock_6   
   .byte $7E ; |.XXXXXX.|
   .byte $BD ; |X.XXXX.X|
   .byte $DB ; |XX.XX.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $D3 ; |XX.X..XX|
   .byte $B1 ; |X.XX...X|
   .byte $70 ; |.XXX....|
CountdownClock_7
   .byte $7E ; |.XXXXXX.|
   .byte $BD ; |X.XXXX.X|
   .byte $DB ; |XX.XX.XX|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $DB ; |XX.XX.XX|
   .byte $BD ; |X.XXXX.X|
   .byte $7E ; |.XXXXXX.|
EatCandyIcon_1
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|

Copyright_0
   .byte $79 ; |.XXXX..X|
   .byte $85 ; |X....X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $85 ; |X....X.X|
   .byte $79 ; |.XXXX..X|
   .byte $00 ; |........|
Copyright_1
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $77 ; |.XXX.XXX|
   .byte $00 ; |........|
Copyright_2
   .byte $71 ; |.XXX...X|
   .byte $41 ; |.X.....X|
   .byte $41 ; |.X.....X|
   .byte $71 ; |.XXX...X|
   .byte $11 ; |...X...X|
   .byte $51 ; |.X.X...X|
   .byte $70 ; |.XXX....|
   .byte $00 ; |........|
Copyright_3
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $BE ; |X.XXXXX.|
   .byte $00 ; |........|
Copyright_4
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $D9 ; |XX.XX..X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $99 ; |X..XX..X|
   .byte $00 ; |........|

ArtistInitials
   .byte $1E ; |...XXXX.|
   .byte $1B ; |...XX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $1E ; |...XXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|

DetermineToShowArtistInitials
   ldx #0
   lda gameSelection                ; get the current game selection
   cmp currentScreenId              ; compare with current screen id
   bne .setArtistInitialFlag        ; don't show "JD" initials if not the same
   cmp collectedCandyPieces         ; compare with candy pieces held by Elliott
   bne .setArtistInitialFlag        ; don't show "JD" initials if not the same
   cmp currentObjectId
   bne .setArtistInitialFlag
   cmp #1                           ; see if playing game selection 1
   bne .setArtistInitialFlag        ; don't show "JD" initials if not the same
   lda heldCandyPieces              ; get number of candy pieces held by E.T.
   cmp #2 * 16                      ; don't show "JD" initials if E.T. carrying
   bcs .setArtistInitialFlag        ; more than 1 piece of candy
   dex                              ; x = -1
.setArtistInitialFlag
   stx artistInitialFlag
   rts

   BOUNDARY 0
   
PitGraphics
PitPF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
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
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|

   IF COMPILE_REGION = NTSC
   
IndyColors

   ENDIF
   
   .byte NTSC_BROWN + 8, NTSC_BROWN + 8, NTSC_BROWN + 8, NTSC_BROWN + 12
   .byte NTSC_BROWN + 12, NTSC_BROWN + 14, NTSC_BROWN + 15, NTSC_BROWN + 15
   .byte NTSC_BROWN + 15, NTSC_BROWN + 15, NTSC_BROWN + 15, NTSC_BROWN + 15
   .byte NTSC_BROWN + 15, NTSC_BROWN + 15, NTSC_BROWN + 15, NTSC_BROWN + 15

WashingtonDCGraphics
WashingtonPF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $F4 ; |XXXX.X..|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
WashingtonPF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $00 ; |........|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PitPF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

   IF COMPILE_REGION = NTSC
   
YarColor
   .byte BROWN + 15, BROWN + 15, BROWN + 15, BROWN + 15
   .byte BROWN + 15, BROWN + 15, BROWN + 15, BROWN + 15
   
   ELSE
   
      REPEAT 8
      
         .byte -1
         
      REPEND
      
   ENDIF

PlayfieldColors
   .byte GREEN_2, GREEN_2, GREEN_2, GREEN_2, GREEN_2
   .byte BLACK + 8, BLACK, DK_BLUE + 2, BLACK

BackgroundColors
   .byte DK_GREEN + 4, DK_GREEN + 4, DK_GREEN + 4, DK_GREEN + 4
   .byte DK_GREEN + 4, BLUE + 4, BLACK + 6, LT_BLUE, BLUE

CheckToFlyYarSprite
   bit easterEggSpriteFlag          ; check Easter Egg sprite flags
   bpl .doneYarFlight               ; branch if not showing special sprite
   bvs .doneYarFlight               ; branch if showing Indy sprite
   ldx currentObjectVertPos         ; get Yar's vertical position
   bpl .moveYarUp
   cpx #224
   bcc .doneYarFlight
.moveYarUp
   dec currentObjectVertPos
.doneYarFlight
   rts

   BOUNDARY 0

ScientistSprites
Scientist_0
   .byte $1A ; |...XX.X.|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $5E ; |.X.XXXX.|
   .byte $16 ; |...X.XX.|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
   .byte $E7 ; |XXX..XXX|
Scientist_1
   .byte $1A ; |...XX.X.|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $5C ; |.X.XXX..|
   .byte $2E ; |..X.XXX.|
   .byte $36 ; |..XX.XX.|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
Scientist_2
   .byte $1A ; |...XX.X.|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $2C ; |..X.XX..|
   .byte $2C ; |..X.XX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
Scientist_3
   .byte $1A ; |...XX.X.|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $76 ; |.XXX.XX.|
Scientist_4
   .byte $1A ; |...XX.X.|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $5E ; |.X.XXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|
   .byte $EE ; |XXX.XXX.|
Scientist_5
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $2E ; |..X.XXX.|
   .byte $3A ; |..XXX.X.|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $E6 ; |XXX..XX.|
   .byte $C7 ; |XX...XXX|
Scientist_6
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3A ; |..XXX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $70 ; |.XXX....|
   .byte $1C ; |...XXX..|
Scientist_7
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $34 ; |..XX.X..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
Scientist_8
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $5C ; |.X.XXX..|
   .byte $34 ; |..XX.X..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $76 ; |.XXX.XX.|
   .byte $70 ; |.XXX....|
Scientist_9
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $6E ; |.XX.XXX.|
   .byte $7A ; |.XXXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $EC ; |XXX.XX..|
   .byte $CE ; |XX..XXX.|

ScientistColors_A
   .byte LT_BLUE + 8, RED_2 + 6, RED_2 + 6, RED_2 + 6, WHITE, WHITE - 2
   .byte WHITE - 4, WHITE - 4, WHITE - 4, WHITE - 4, WHITE - 4, BLACK + 8
   .byte BLACK, ORANGE + 8
ScientistColors_B
   .byte LT_BLUE + 8, RED_2 + 6, RED_2 + 6, WHITE, WHITE - 2, WHITE - 4
   .byte WHITE - 4, WHITE - 4, WHITE - 4, WHITE - 4, BLACK + 8, BLACK + 8
   .byte ORANGE + 8, ORANGE + 8

H_PhonePiece_0
   .byte $90 ; |X..X....|
   .byte $64 ; |.XX..X..|
   .byte $3F ; |..XXXXXX|
   .byte $64 ; |.XX..X..|
   .byte $90 ; |X..X....|
H_PhonePiece_1
   .byte $C8 ; |XX..X...|
   .byte $32 ; |..XX..X.|
   .byte $32 ; |..XX..X.|
   .byte $C8 ; |XX..X...|
   .byte $00 ; |........|

S_PhonePiece_0
   .byte $1F ; |...XXXXX|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $15 ; |...X.X.X|
   .byte $7C ; |.XXXXX..|
S_PhonePiece_1
   .byte $3E ; |..XXXXX.|
   .byte $A8 ; |X.X.X...|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $F8 ; |XXXXX...|

W_PhonePiece_0
   .byte $3C ; |..XXXX..|
   .byte $C0 ; |XX......|
   .byte $AA ; |X.X.X.X.|
   .byte $0E ; |....XXX.|
   .byte $E0 ; |XXX.....|
W_PhonePiece_1
   .byte $60 ; |.XX.....|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $FF ; |XXXXXXXX|

PhonePieceColors_A
   .byte BROWN + 14, BROWN + 10, BROWN + 6, BROWN + 4, BROWN + 2
PhonePieceColors_B
   .byte BROWN + 12, BROWN + 8, LT_BROWN_2 + 6, LT_BROWN_2 + 4, LT_BROWN_2 + 2

MotherShip
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $42 ; |.X....X.|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
   .byte $5A ; |.X.XX.X.|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|

MotherShipColors
   .byte DK_PINK + 8, DK_PINK + 6, DK_PINK + 4, DK_PINK + 2, DK_PINK + 4
   .byte DK_PINK + 6, DK_PINK + 8, DK_PINK + 6, DK_PINK + 4, DK_PINK + 2
   .byte DK_PINK + 4, DK_PINK + 6, DK_PINK + 8, DK_PINK + 6, DK_PINK + 4
   .byte DK_PINK + 2, DK_PINK + 4, DK_PINK + 6, DK_PINK + 8, DK_PINK + 6
   .byte DK_PINK + 4, DK_PINK+2
   
   IF COMPILE_REGION = PAL50
   
YarColor
IndyColors
   .byte BROWN + 12, BROWN + 12, BROWN + 12, BROWN + 12, BROWN + 12
   .byte BROWN + 12, BROWN + 12, BROWN + 12, BROWN + 12, BROWN + 12
   
   ENDIF
   
   BOUNDARY 0
   
ETHomePFGraphics
ETHomePF2Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $F4 ; |XXXX.X..|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $F0 ; |XXXX....|
   .byte $B0 ; |X.XX....|
   .byte $B0 ; |X.XX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
ETHomePF1Graphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

FBIAgentSprites
FBIAgent_0
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $6C ; |.XX.XX..|
   .byte $78 ; |.XXXX...|
   .byte $6E ; |.XX.XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $E7 ; |XXX..XXX|
FBIAgent_1
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $58 ; |.X.XX...|
   .byte $70 ; |.XXX....|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $7E ; |.XXXXXX.|
   .byte $2E ; |..X.XXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
FBIAgent_2
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
   .byte $58 ; |.X.XX...|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $DC ; |XX.XXX..|
   .byte $FC ; |XXXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
FBIAgent_3
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $2C ; |..X.XX..|
   .byte $78 ; |.XXXX...|
   .byte $7E ; |.XXXXXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $6E ; |.XX.XXX.|
FBIAgent_4
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $76 ; |.XXX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $76 ; |.XXX.XX.|
   .byte $7C ; |.XXXXX..|
   .byte $3A ; |..XXX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $C6 ; |XX...XX.|
   .byte $E7 ; |XXX..XXX|
FBIAgent_5
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $36 ; |..XX.XX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
FBIAgent_6
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $EC ; |XXX.XX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $1C ; |...XXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
FBIAgent_7
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $76 ; |.XXX.XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $74 ; |.XXX.X..|
   .byte $7E ; |.XXXXXX.|
   .byte $2E ; |..X.XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $6C ; |.XX.XX..|
   .byte $76 ; |.XXX.XX.|

FBIAgentColors_A
   .byte LT_RED + 8, LT_RED + 8, RED_2 + 8, RED_2 + 8, LT_RED + 10, LT_RED + 10
   .byte LT_RED + 10, LT_RED + 10, LT_RED + 8, LT_RED + 8, LT_RED + 8
   .byte LT_RED + 8, LT_RED + 6, BLACK
FBIAgentColors_B
   .byte LT_RED + 8, BLACK, RED_2 + 8, LT_RED + 10, LT_RED + 10, LT_RED + 10
   .byte LT_RED + 10, LT_RED + 10, LT_RED + 8, LT_RED + 8, LT_RED + 8
   .byte LT_RED + 6, BLACK, BLACK

HumanHorizReflectionTable
   .byte 28, 60, 94

IndySprite
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|

   IF COMPILE_REGION = NTSC
   
      .org BANK1TOP + 4096 - 6, 0
            
   ELSE
   
      .org BANK1TOP + 4096 - 8, 0
      .byte -1, 0
      
   ENDIF
   
   .word BANK1Start
   .word BANK1Start
   .word BANK1Start