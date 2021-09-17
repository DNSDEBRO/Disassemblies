   LIST OFF
; ***  F O O T B A L L  ***
; Copyright 1979 Atari, Inc
; Designer: Bob Whitehead
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: Dec. 10, 2019
;
;  *** 108 BYTES OF RAM USED 20 BYTES FREE
;  ***   1 BYTE OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1979, ATARI                                        =
; =                                                                            =
; ==============================================================================

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

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

TRUE                    = 1
FALSE                   = 0

   IFNCONST COMPILE_REGION

COMPILE_REGION         = NTSC       ; change to compile for different regions

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
VBLANK_TIME             = 37
OVERSCAN_TIME           = 34

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 68
OVERSCAN_TIME           = 65
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E
ORANGE                  = $40
BLUE                    = $80
DK_GREEN                = $D0

ORANGE_TEAM_BW_VALUE    = BLACK
WHITE_TEAM_BW_VALUE     = WHITE
FOOTBALL_BW_VALUE       = BLACK + 6
FOOTBALL_FIELD_BW_VALUE = BLACK + 10

ORANGE_TEAM_COLOR_VALUE = ORANGE + 8
WHITE_TEAM_COLOR_VALUE  = WHITE - 2
FOOTBALL_COLOR_VALUE    = BLUE + 2
FOOTBALL_FIELD_COLOR_VALUE = DK_GREEN + 6

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 5
H_FOOTBALL              = 4
H_YARD_MARKER           = 8
H_KERNEL                = 200
H_PLAYER                = 14
H_PLAY_INDICATOR        = 5
H_INTERLEAVED_GRAPHICS  = H_PLAY_INDICATOR

W_SCREEN                = 159

W_PLAYER                = 8

BW_HUE_MASK             = $06
COLOR_HUE_MASK          = $F6

VERT_MIN                = 31
VERT_MAX                = 194
HORIZ_MIN               = 31
HORIZ_MAX               = 119

MAX_DOWNS               = 4

MAX_GAME_SELECTION      = 3

GAME_SELECTION_PLAYER_CONTROL = 1
GAME_SELECTION_CPU_CONTROL = 2
GAME_SELECTION_COACH    = 3

INIT_FOOTBALL_HORIZ_POS = 79

LEFT_TEAM_SAFETY_LINE_OF_SCRIMMAGE = 117
LEFT_TEAM_STARTING_LINE_OF_SCRIMMAGE = 83
RIGHT_TEAM_STARTING_LINE_OF_SCRIMMAGE = 151
RIGHT_TEAM_SAFETY_LINE_OF_SCRIMMAGE = 117

INIT_LEFT_PLAYER_TIGHT_HORIZ_POS = 59
INIT_RIGHT_PLAYER_TIGHT_HORIZ_POS = 91
INIT_LEFT_PLAYER_SPLIT_HORIZ_POS = 43
INIT_RIGHT_PLAYER_SPLIT_HORIZ_POS = 107

BLANK_NUMBER_PTR        = (Blank - NumberFonts) / H_FONT

PLAY_PUNT               = 0
PLAY_DEEP               = 0
PLAY_TIGHT_RIGHT        = 1
PLAY_TIGHT_LEFT         = 2
PLAY_SPLIT_RIGHT        = 3
PLAY_SPLIT_LEFT         = 4

POINTS_SAFETY           = 2
POINTS_TOUCHDOWN        = 7

INIT_CLOCK_MINUTES      = 5

INIT_BALL_SNAP_TIMER_VALUE = 127

GAME_OVER               = $FF

MY_MOVE_RIGHT           = <(~MOVE_RIGHT)
MY_MOVE_LEFT            = <(~MOVE_LEFT)
MY_MOVE_DOWN            = <(~MOVE_DOWN)
MY_MOVE_UP              = <(~MOVE_UP)

MOVE_RIGHT_LEFT_PLAYER  = MY_MOVE_RIGHT & P0_JOYSTICK_MASK
MOVE_LEFT_LEFT_PLAYER   = MY_MOVE_LEFT & P0_JOYSTICK_MASK
MOVE_DOWN_LEFT_PLAYER   = MY_MOVE_DOWN & P0_JOYSTICK_MASK
MOVE_UP_LEFT_PLAYER     = MY_MOVE_UP & P0_JOYSTICK_MASK

MOVE_RIGHT_RIGHT_PLAYER = (MY_MOVE_RIGHT >> 4) & P1_JOYSTICK_MASK
MOVE_LEFT_RIGHT_PLAYER  = (MY_MOVE_LEFT >> 4) & P1_JOYSTICK_MASK
MOVE_DOWN_RIGHT_PLAYER  = (MY_MOVE_DOWN >> 4) & P1_JOYSTICK_MASK
MOVE_UP_RIGHT_PLAYER    = (MY_MOVE_UP >> 4) & P1_JOYSTICK_MASK

SOUND_INDEX_MASK        = $F0
SOUND_DURATION_MASK     = $0F

RIGHT_PLAYER_NOT_SELECTED_PLAY = 1 << 7
LEFT_PLAYER_NOT_SELECTED_PLAY = 1 << 6

;===============================================================================
; M A C R O S
;===============================================================================

;-------------------------------------------------------
; INTERLEAVED_GRAPHICS
; Original author: Andrew Davie
; Interleaves graphics data in the assembled ROM. This was constructed to
; hopefully allow readers of the listing to easily see the graphics data that
; makes up a sprite.
;
   MAC INTERLEAVED_GRAPHICS
      IF {1} = 1
     .byte {2}
      ENDIF
      
      IF {1} = 2
     .byte {3}
      ENDIF
      
      IF {1} = 3
      .byte {4}
      ENDIF
      
      IF {1} = 4
      .byte {5}
      ENDIF
      
      IF {1} = 5
      .byte {6}
      ENDIF
   
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
frameCount              ds 1
ballSnapTimer           ds 1
lineMarkerValues        ds 2
;--------------------------------------
lineOfScrimmage         = lineMarkerValues
firstDownMarkerVertPos  = lineOfScrimmage + 1
randomPuntYardage       ds 1
yardMarkingHeight       ds 1
crowdVolumeValue        ds 1
zp_Unused_01            ds 2        ; 2 unused RAM bytes
selectedPlayNumber      ds 2
;--------------------------------------
player1PlayNumber       = selectedPlayNumber
player2PlayNumber       = player1PlayNumber + 1
displayedPlayersVertPos ds 2
;--------------------------------------
player1VertPos          = displayedPlayersVertPos
player2VertPos          = player1VertPos + 1
displayedPlayersHorizPos ds 2
;--------------------------------------
player1HorizPos         = displayedPlayersHorizPos
player2HorizPos         = player1HorizPos + 1
teamVertPositions       ds 8
teamHorizPositions      ds 8
teamCollisionValues     ds 8
controllerPortValues    ds 3
;--------------------------------------
actionButtonValues      = controllerPortValues
;--------------------------------------
leftActionButtonValue   = actionButtonValues
rightActionButtonValue  = leftActionButtonValue + 1
joystickValues          = rightActionButtonValue + 1
controllerPortDebounceValues ds 3
;--------------------------------------
actionButtonDebounceValues = controllerPortDebounceValues
;--------------------------------------
leftActionButtonDebounceValue = actionButtonDebounceValues
rightActionButtonDebounceValue = leftActionButtonDebounceValue + 1
joystickDebounceValues  = rightActionButtonDebounceValue + 1
playerReflectState      ds 2
;--------------------------------------
player1ReflectState     = playerReflectState
player2ReflectState     = player1ReflectState + 1
footballVertPos         ds 1
footballHorizPos        ds 1
objectColorValues       ds 4
;--------------------------------------
player1TeamColor        = objectColorValues
player2TeamColor        = player1TeamColor + 1
footballColor           = player2TeamColor + 1
footballFieldColor      = footballColor + 1
crowdRoarFrequencyPtrs  ds 2
selectedPlayStatus      ds 1
footballCollisionValue  ds 1
footballStatus          ds 1
receivingPlayerIndex    ds 1        ; index of player that caught football
endingPlayTimer         ds 1        ; delay to transition to next play setup
colorCycleMode          ds 1
gameState               ds 1        ; 0 = GAME_ON...-1 = GAME_OVER
startingPossesionLineOfScrimmage ds 1
offensiveTeamIndex      ds 1
scoreBoardValues        ds 5
;--------------------------------------
player1Score            = scoreBoardValues
player2Score            = player1Score + 1
clockSeconds            = player2Score + 1
clockMinutes            = clockSeconds + 1
currentDown             = clockMinutes + 1
teamFormationValues     ds 2
;--------------------------------------
player1TeamFormation    = teamFormationValues
player2TeamFormation    = player1TeamFormation + 1
random                  ds 1
randomVertMotionTimer   ds 1
zp_Unused_02            ds 1        ; 1 unused RAM byte
playerAllowedMotionValues ds 8
interceptionStatus      ds 1        ; non-zero shows pass intercepted
gameSelection           ds 1
selectDebounceRate      ds 1
tmpHueMask              ds 1
;--------------------------------------
tmpDisplayValue         = tmpHueMask
;--------------------------------------
tmpHorizPosDiv16        = tmpDisplayValue
;--------------------------------------
tmpPlayerIndex          = tmpHorizPosDiv16
;--------------------------------------
tmpFootballCollisionValue = tmpPlayerIndex
;--------------------------------------
tmpAllowedDirValues     = tmpFootballCollisionValue
tmpFieldColorIndex      ds 1
;--------------------------------------
tmpOffensivePlay        = tmpFieldColorIndex
;--------------------------------------
tmpFootballMidVert      = tmpOffensivePlay
;--------------------------------------
tmpPlayerNumber         = tmpFootballMidVert
currentPlayerIndex      ds 1        ; index of current displayed player
zp_Unused_03            ds 1        ; 1 unused RAM byte
scoringFrequencyIndex   ds 1
gameMusicSoundValues    ds 1
crowdRoarVolumeModulator ds 1
playersHorizCoarseValue ds 2
;--------------------------------------
player1HorizCoarseValue = playersHorizCoarseValue
player2HorizCoarseValue = player1HorizCoarseValue + 1
playersHorizFineMotionValue ds 2
;--------------------------------------
player1HorizFineMotionValue = playersHorizFineMotionValue
player2HorizFineMotionValue = player1HorizFineMotionValue + 1
digitGraphicPtrs        ds 16
;--------------------------------------
player1ScoreGraphicPtrs = digitGraphicPtrs
player2ScoreGraphicPtrs = digitGraphicPtrs + 4
clockSecondsGraphicPtrs = digitGraphicPtrs + 8
clockMinutesGraphicPtrs = digitGraphicPtrs + 12
currentDownGraphicPtrs  = digitGraphicPtrs + 14

   echo "***",(* - $80 - 4)d, "BYTES OF RAM USED", ($100 - * + 4)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG code
   .org ROM_BASE

Start
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set stack to the beginning
   inx                              ; x = 0
   txa                              ; a = 0
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   lda #H_YARD_MARKER - 1
   sta yardMarkingHeight
   dec random                       ; seed with 255
   jsr ClearGameRAM
   jsr ResetScoreBoardValues
   jsr SetInitPositionsFromSelectedPlay
MainLoop
   sta WSYNC                        ; wait for next scan line
   stx VSYNC                        ; start vertical sync (i.e. D1 = 1)
   stx VBLANK                       ; disable TIA (i.e. D1 = 1)
   stx AUDV0                        ; set volume 0 to max (i.e. x = 255)
   inc frameCount                   ; increment frame count
   bne DetermineTVMode
   inc colorCycleMode               ; incremented ~ every 4.2 seconds
   bne DetermineTVMode
   stx gameState                    ; set game state to GAME_OVER (i.e. x = -1)
DetermineTVMode
   lda gameState                    ; get current game state
   beq SetObjectColorValues         ; branch if GAME_ON
   ldx #$F6
   stx crowdRoarFrequencyPtrs + 1   ; set crowd roar pointer MSB value
SetObjectColorValues
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; keep the B/W switch value
   lsr                              ; shift value right
   bne .setColorHueMask             ; branch if set to COLOR
   pha                              ; push B/W switch value to stack
   txa                              ; move color masking to accumulator
   and #$0F                         ; mask color value...keep luminance value
   tax
   pla                              ; pull B/W switch value from stack
.setColorHueMask
   stx tmpHueMask
   tay
   ldx #<[footballFieldColor - objectColorValues + 1]
   sta WSYNC                        ; start second VSYNC scan line
.setObjectColors
   lda colorCycleMode
   and gameState                    ; mask with current game state
   eor GameColorTable,y             ; flip color bits for color cycling
   and tmpHueMask                   ; mask color values for COLOR / B&W mode
   sta objectColorValues - 1,x      ; set object color value
   sta COLUP0 - 1,x
   iny
   dex
   bne .setObjectColors
   stx WSYNC                        ; start third VSYNC scan line
   stx VSYNC                        ; end vertical sync (i.e. D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   lda frameCount                   ; get current frame count
   and #$3F                         ; 0 <= a <= 63
   ora ballSnapTimer                ; combine with ball snap timer
   ora gameState                    ; combine with current game state
   bne ReadConsolePortsAndSwitches  ; branch if shouldn't decrement game clock
   lda clockSeconds                 ; get clock seconds
   sed
   sbc #1 - 1                       ; carry clear from B/W shift above
   cld
   bpl .setClockSeconds
   lda clockMinutes                 ; get clock minutes
   beq ReadConsolePortsAndSwitches
   lda #$59                         ; reset clock seconds to 59
   dec clockMinutes                 ; reduce clock minutes
.setClockSeconds
   sta clockSeconds
ReadConsolePortsAndSwitches
   jsr ReadConsoleSwitches
   ldx #2
   lda SWCHA                        ; read joystick values
.readControllerPortValues
   tay                              ; move controller input values to y register
   eor controllerPortValues,x       ; flip bits from previous frame read
   and controllerPortValues,x       ; mask previous frame direction values
   sta controllerPortDebounceValues,x;set controller port debounce values
   sty controllerPortValues,x
   lda INPT4 - 1,x                  ; read action button values
   dex
   bpl .readControllerPortValues
   ldx #2
   stx NUSIZ1                       ; set to TWO_MED_COPIES
.setObjectHorizKernelValues
   lda displayedPlayersHorizPos - 1,x;get player's horizontal position
   jsr DetermineObjectHorizValues   ; determine horizontal fine & coarse values
   sty playersHorizCoarseValue - 1,x
   sta playersHorizFineMotionValue - 1,x
   lda displayedPlayersHorizPos - 1,x;get player's horizontal position
   asl                              ; shift value left
   eor displayedPlayersVertPos - 1,x; flip D3 based on player vertical position
   sta playerReflectState - 1,x     ; set player REFLECT state value
   dex
   bne .setObjectHorizKernelValues
   lda footballHorizPos             ; get football horizontal position
   jsr DetermineObjectHorizValues   ; determine football fine & coarse values
DisplayKernel
.waitTime
   ldx INTIM
   bne .waitTime
   sty WSYNC
;--------------------------------------
.coarseMoveFootball
   dey                        ; 2
   bpl .coarseMoveFootball    ; 2³
   sta RESBL,x                ; 4
   sta HMBL                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx tmpFieldColorIndex     ; 3         clear field color index value
   lda footballFieldColor     ; 3
   sta COLUP1                 ; 3 = @12
   sta COLUBK                 ; 3 = @15
   lda #MSBL_SIZE2 | PF_REFLECT;2
   sta.w CTRLPF               ; 4
   ldy #<[currentDownGraphicPtrs - digitGraphicPtrs];2
   sty REFP0                  ; 3 = @26   reflect player (i.e. D3 = 1)
   sty REFP1                  ; 3 = @29   reflect player (i.e. D3 = 1)
   sta HMCLR                  ; 3 = @32
   sta RESP0                  ; 3 = @35
   lda currentDown            ; 3         get current down
   sta RESP1                  ; 3 = @41
   jsr BCD2Digits             ; 6
;--------------------------------------
   lda clockMinutes           ; 3 = @06
   jsr BCD2Digits             ; 6
   ldx #<[clockSeconds - scoreBoardValues + 1];2 = @46
.setGraphicPointersForScoreBoard
   dex                        ; 2
   lda scoreBoardValues,x     ; 4         get score board value
   lsr                        ; 2         shift upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   jsr BCD2Digits             ; 6
;--------------------------------------
   lda scoreBoardValues,x     ; 4 = @26
   and #$0F                   ; 2
   jsr BCD2Digits             ; 6
   bpl .setGraphicPointersForScoreBoard;2³
   ldy #H_FONT                ; 2 = @70
   sty VBLANK                 ; 3 = @73   enable TIA (i.e. D1 = 0)
   lda #HMOVE_R4 | THREE_MED_COPIES;2
;--------------------------------------
   sta NUSIZ0                 ; 3 = @02
   sta HMP1                   ; 3 = @05
   lda #HMOVE_R6 | VERTICAL_DELAY;2
   sta VDELP1                 ; 3 = @10
   sta HMP0                   ; 3 = @13
   sec                        ; 2
   bcs .scoreBoardKernel      ; 3         unconditional branch
   
ScoreBoardKernel
   clc                        ; 2
.scoreBoardKernelLoop
   lda player1TeamColor       ; 3
   sta COLUP0                 ; 3
.scoreBoardKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (clockMinutesGraphicPtrs),y;5      get graphic data for minutes value
   ora ColonGraphic - 1,y     ; 4         combine with colon graphics
   sta GRP1                   ; 3 = @15   draw minutes value
   lda (player1ScoreGraphicPtrs),y;5      get tens graphics data for score
   sta GRP0                   ; 3 = @23   draw player 1 score tens value
   lda (currentDownGraphicPtrs),y;5       get graphics data for current down
   sta GRP1                   ; 3 = @31   draw current down value
   lda (clockSecondsGraphicPtrs),y;5      get tens graphic data for seconds
   ldx footballFieldColor     ; 3
   stx COLUP0                 ; 3 = @42   color timer
   ldx player2TeamColor       ; 3
   sta GRP0                   ; 3 = @48   draw tens seconds value
   lda (player2ScoreGraphicPtrs),y;5      get tens graphics data for score
   sta GRP0                   ; 3 = @56   draw player 2 score tens value
   stx COLUP0                 ; 3 = @59   color player 2 score
   lda #HMOVE_L7              ; 2
   sta HMP0                   ; 3 = @64   shift players left 7 pixels
   sta HMP1                   ; 3 = @67
   lda #0                     ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP1                   ; 3 = @06
   lda player1TeamColor       ; 3
   sta COLUP0                 ; 3 = @12   color player 1 score
   lda (player1ScoreGraphicPtrs + 2),y;5  get ones graphics data for score
   sta GRP0                   ; 3 = @20   draw player 1 score ones value
   lda (clockSecondsGraphicPtrs + 2),y;5  get ones graphic data for seconds
   ldx #HMOVE_R7              ; 2
   stx HMP0                   ; 3 = @30   shift players right 7 pixels
   stx HMP1                   ; 3 = @33
   ldx footballFieldColor     ; 3
   stx COLUP0                 ; 3 = @39   color timer
   ldx player2TeamColor       ; 3
   sta GRP0                   ; 3 = @45   color player 2 score
   lda (player2ScoreGraphicPtrs + 2),y;5  get ones graphic data for score
   sta GRP0                   ; 3 = @53   draw player 2 score ones value
   stx COLUP0                 ; 3 = @56
   bcs ScoreBoardKernel       ; 2³
   sec                        ; 2
   dey                        ; 2
   bne .scoreBoardKernelLoop  ; 2³
   sty GRP0                   ; 3 = @67
   sty VDELP1                 ; 3 = @70
   stx COLUP1                 ; 3 = @73
   ldy #H_PLAY_INDICATOR * 2  ; 2
.drawPlayIndicators
   sta WSYNC
;--------------------------------------
   lda selectedPlayStatus     ; 3         get selected play status values
   asl                        ; 2         shift player 1 status to carry
   asl                        ; 2
   tya                        ; 2         shift scan line to accumulator
   adc #1 - 1                 ; 2         increment with selected play status
   tax                        ; 2
   lda PlayIndicator - 2,x    ; 4
   sta GRP0                   ; 3 = @20   draw player program play indicator
   tya                        ; 2         shift scan line to accumulator
   ora offensiveTeamIndex     ; 3         combine with offensive team index
   tax                        ; 2         set index for offensive indicator
   lda OffensiveIndicator - 2,x;4
   tax                        ; 2         move offensive indicator graphic to x
   lda selectedPlayStatus     ; 3         get selected play status values
   asl                        ; 2         shift player 2 status to carry
   tya                        ; 2         shift scan line to accumulator
   adc #1 - 1                 ; 2         increment with selected play status
   stx GRP0                   ; 3 = @45   draw offensive indicator
   tax                        ; 2
   lda PlayIndicator - 2,x    ; 4
   sta GRP0                   ; 3 = @54   draw player program play indicator
   dey                        ; 2
   dey                        ; 2
   bne .drawPlayIndicators    ; 2³
   sty GRP0                   ; 3 = @63
   sec                        ; 2
   ldx #2                     ; 2
.setFootballPlayerValues
   lda playerReflectState - 1,x;4
   sta WSYNC
;--------------------------------------
   sta REFP0 - 1,x            ; 4
   lda playersHorizFineMotionValue - 1,x;4
   sta HMP0 - 1,x             ; 4
   lda playersHorizCoarseValue - 1,x;4
   sbc #3                     ; 2
.coarsePositionFootballPlayer
   sbc #1                     ; 2
   bne .coarsePositionFootballPlayer;2³
   dex                        ; 2
   sta RESP0,x                ; 4
   bne .setFootballPlayerValues;2³
   sta WSYNC
;--------------------------------------
   ldx player1TeamColor       ; 3
   stx COLUP0                 ; 3 = @06
   clc                        ; 2
   ldx #$F0                   ; 2
   stx PF1                    ; 3 = @13   draw left and right boundaries
   sta PF2                    ; 3 = @16   clear PF2 graphics (i.e. a = 0)
   ldx player1TeamFormation   ; 3
   ldy player2TeamFormation   ; 3
   lda #MSBL_SIZE2 | PF_PRIORITY | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @27
   lda ballSnapTimer          ; 3         get ball snap timer value
   bne .setPlayerNUSIZValues  ; 2³        branch if ball not snapped
   tay                        ; 2
   tax                        ; 2
.setPlayerNUSIZValues
   stx NUSIZ0                 ; 3 = @39
   sty NUSIZ1                 ; 3 = @42
   ldx #39                    ; 2
   txa                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bne .footballFieldKernel   ; 3 + 1     unconditional branch
   
Randomize
   lda crowdRoarVolumeModulator
   asl
   eor crowdRoarVolumeModulator
   asl
   asl
   ror random
   rol crowdRoarVolumeModulator
   rts

PositionFootballWithBallCarrier
   lda teamHorizPositions,y         ; get ball carrier horizontal position
   clc
   adc #(W_PLAYER / 2)              ; increment by the horizontal mid point
   sta footballHorizPos             ; set football horizontal position
   lda teamVertPositions,y          ; get ball carrier vertical position
   adc #(H_PLAYER + 1) / 3          ; carry cleared above
   sta footballVertPos              ; set football vertical position
   rts

.skipDrawPlayer1
   clc                        ; 2
   SLEEP 2                    ; 2
   bcc .checkToDrawPlayer2Sprite;4        unconditional branch...crosses page
   
.skipDrawPlayer2
   clc                        ; 2
   SLEEP 2                    ; 2
   bcc .checkToDrawFirstDownMarker;4      unconditional branch...crosses page
   
FootballFieldKernel
;--------------------------------------
   ldy #0                     ; 2
   sty PF2                    ; 3 = @05
   txa                        ; 2         move scan line count to accumulator
.footballFieldKernel
   bit yardMarkingHeight      ; 3
   beq .alternateFieldColors  ; 2³
   sbc footballVertPos        ; 3         subtract football vertical position
   and #~(H_FOOTBALL - 1)     ; 2         and with 2's complement of H_FOOTBALL
   bne .skipDrawFootball      ; 2³        branch to disable football
   ldy #ENABLE_BM             ; 2
   sty ENABL                  ; 3 = @24
   SLEEP 2                    ; 2
   cpx #H_KERNEL + 1          ; 2
   bcc .checkToDrawPlayer1Sprite;2³
   bcs Overscan               ; 3         unconditional branch
   
.skipDrawFootball
   sta ENABL                  ; 3 = @23
   bne .checkDoneFootballFieldKernel;3    unconditional branch
   
.alternateFieldColors
   inc tmpFieldColorIndex     ; 5         increment field color index
   ldy tmpFieldColorIndex     ; 3
   lda FieldColorEORValues - 1,y;4
   eor footballFieldColor     ; 3         alternate color D1 value
   sta COLUBK                 ; 3 = @31
   lda (crowdRoarFrequencyPtrs),y;5
   and #7                     ; 2         0 <= a <= 7
   ora #8                     ; 2         8 <= a <= 15
   sta AUDF1                  ; 3
   inx                        ; 2         increment scan line count
   clc                        ; 2
   SLEEP 2                    ; 2
   bcc .checkToDrawPlayer2Sprite;3        unconditional branch
   
.checkToDrawPlayer1Sprite
   inx                        ; 2         increment scan line count   
   txa                        ; 2         move scan line count to accumulator
   sbc player1VertPos         ; 3         subtract player 1 vertical position
   cmp #H_PLAYER + 1          ; 2
   bcs .skipDrawPlayer1       ; 2³ + 1
   tay                        ; 2
   lda FootballPlayerSprite,y ; 4
   sta.w GRP0                 ; 4 = @52
.checkToDrawPlayer2Sprite
   txa                        ; 2         move scan line count to accumulator
   sbc player2VertPos         ; 3         subtract player 2 vertical position
   cmp #H_PLAYER + 1          ; 2
   bcs .skipDrawPlayer2       ; 2³ + 1
   tay                        ; 2
   lda FootballPlayerSprite,y ; 4
   sta GRP1                   ; 3 = @70
.checkToDrawFirstDownMarker
   cpx firstDownMarkerVertPos ; 3
   bne FootballFieldKernel    ; 2³
;--------------------------------------
   ldy #$FF                   ; 2 = @01
   sty.w PF2                  ; 4 = @05   draw first down marker
   txa                        ; 2         move scan line count to accumulator
   bit yardMarkingHeight      ; 3
   beq .alternateFieldColors  ; 2³
   sbc footballVertPos        ; 3         subtract football vertical position
   and #~(H_FOOTBALL - 1)     ; 2         and with 2's complement of H_FOOTBALL
   bne .skipDrawFootball      ; 2³        branch to disable football
   ldy #ENABLE_BM             ; 2
   sty ENABL                  ; 3 = @24
   SLEEP 2                    ; 2
.checkDoneFootballFieldKernel
   cpx #H_KERNEL + 1          ; 2
   bcc .checkToDrawPlayer1Sprite;2³
Overscan SUBROUTINE
   ldx #0
   stx GRP0
   stx GRP1
   stx ENABL
   dex                              ; x = -1
   stx PF0
   sta WSYNC
   stx PF1
   stx PF2
   lda #OVERSCAN_TIME
   sta TIM64T
   lda gameMusicSoundValues         ; get game music sound values
   ldx #8
   stx AUDC1                        ; set sound channel for crowd roar
   and #$F0                         ; keep sound index values
   bmi .setAudioMusicValues         ; branch if done playing sound
   dec gameMusicSoundValues         ; decrement game sound duration value
   lsr                              ; shift sound index value
   ora scoringFrequencyIndex        ; combine with scoring frequency index value
   lsr                              ; shift sound index value
   bcc .determineSoundFrequencyIndex; branch if not reducing sound duration
   dec gameMusicSoundValues         ; decrement game sound duration value
.determineSoundFrequencyIndex
   lsr                              ; shift sound index value
   bcs .getGameMusicSoundFrequencies
   lsr                              ; shift sound index value
   and #1
.getGameMusicSoundFrequencies
   tay                              ; set index for reading music frequencies
   lda #12
   ldx GameMusicSoundFrequencies,y
.setAudioMusicValues
   stx AUDF0
   sta AUDC0
   lda crowdRoarFrequencyPtrs       ; get crowd roar frequency LSB value
.incrementCrowdRoarFreqPtr
   adc #23
   cmp #256 - 23
   bcs .incrementCrowdRoarFreqPtr
   sta crowdRoarFrequencyPtrs
   ldx crowdVolumeValue             ; get crowd volume value
   lda frameCount                   ; get current frame count
   and #3
   bne .setCrowdRoarVolumeLevel     ; adjust volume every 4 frames
   lda ballSnapTimer                ; get ball snap timer value
   ora endingPlayTimer              ; combine with ending player timer value
   bne .reduceCrowdVolume           ; branch if ending current play
   inx                              ; increment crowd volume
   cpx #10
   bcc .setCrowdVolumeValue
   lda crowdRoarVolumeModulator     ; get crowd roar volume modulator
   ora #8                           ; volume not lower than 8
   tax
   bne .setCrowdRoarVolumeLevel
   
.reduceCrowdVolume
   dex
   bmi CheckForGameClockExpiration
.setCrowdVolumeValue
   stx crowdVolumeValue
.setCrowdRoarVolumeLevel
   stx AUDV1
CheckForGameClockExpiration
   lda selectedPlayStatus           ; get selected play status value
   beq CheckObjectCollisions        ; branch if both players selected play
   lda clockMinutes                 ; get remaining minutes
   ldx #1
   ora clockSeconds                 ; combine with remaining seconds
   bne .checkPlayerForSelectingPlay ; branch if time left on the clock
   lda #GAME_OVER
   sta gameState                    ; set game state to GAME_OVER
.checkPlayerForSelectingPlay
   ldy #PLAY_PUNT | PLAY_DEEP
   dec ballSnapTimer                ; decrement ball snap timer
   bmi .setSelectedPlayNumber
   lda #INIT_BALL_SNAP_TIMER_VALUE
   sta ballSnapTimer                ; set initial ball snap timer
   lda selectedPlayStatus           ; get selected play status value
   and SelectedPlayStatusMask,x
   beq .checkNextPlayerSelectingPlay; branch if player selected play
   lda joystickDebounceValues       ; get joystick debounce values
   ldy #PLAY_SPLIT_LEFT
   dex
   inx
   bne .determineSelectedPlay       ; branch if processing player 2
   lsr                              ; shift joystick values to lower nybbles
   lsr
   lsr
   lsr
.determineSelectedPlay
   lsr                              ; shift joystick movement value to carry
   bcs .playSelected
   dey                              ; decrement play number
   bne .determineSelectedPlay
   lda actionButtonDebounceValues,x ; get action button debounce value
   bpl .checkNextPlayerSelectingPlay; branch if action button not pressed
.playSelected
   lda gameState                    ; get current game state
   bne .checkNextPlayerSelectingPlay; branch if GAME_OVER
   lda selectedPlayStatus           ; get selected play status values
   eor SelectedPlayStatusMask,x     ; flip player selected play status
   sta selectedPlayStatus           ; set to show play selected
   lda #4
   sta AUDC0
.setSelectedPlayNumber
   sty selectedPlayNumber,x
.checkNextPlayerSelectingPlay
   dex
   bpl .checkPlayerForSelectingPlay
   jmp .waitTime
   
CheckObjectCollisions
   lda frameCount                   ; get current frame count
   and #3                           ; 0 <= a <= 3
   asl                              ; multiply value by 2 (i.e. a is even)
   tax                              ; x points to orange team player
   lda footballVertPos              ; get football vertical position
   adc #(H_FOOTBALL / 2)            ; increment by 2 -- carry clear
   sta tmpFootballMidVert
   ldy #7
.checkObjectCollisions
   lda teamHorizPositions,x         ; get team horizontal position
   sec
   sbc teamHorizPositions,y         ; subtract alterate team horizontal position
   clc
   adc #(W_PLAYER / 2)              ; increment by player horizontal mid point
   cmp #W_PLAYER + 1                ; compare with player width
   bcs .setTeamCollisionValue       ; branch if no horizontal collision
   lda teamVertPositions,x          ; get team vertical position
   sbc teamVertPositions,y          ; subtract alternate verical position
   sec
   adc #(H_PLAYER / 2)
   cmp #H_PLAYER + 1                ; no collision if carry set
.setTeamCollisionValue
   rol teamCollisionValues,x        ; rotate result of compare to D0
   lda footballHorizPos             ; get football horizontal position
   sec
   sbc teamHorizPositions,y         ; subtract team horizontal position
   cmp #W_PLAYER + 1                ; compare with player width
   bcs .setFootballCollisionValue   ; branch if no horizontal collision
   lda tmpFootballMidVert           ; get football vertical mid point
   sbc teamVertPositions,y          ; subtract team vertical position
   cmp #(3 * H_PLAYER) / 4          ; no collision if carry set
.setFootballCollisionValue
   rol footballCollisionValue
   txa
   eor #1
   tax
   dey
   bpl .checkObjectCollisions
   lda ballSnapTimer                ; get ball snap timer value
   beq MovePlayers                  ; branch if ball in play
   dec ballSnapTimer                ; decrement ball snap timer
   bne .setInitPositionsFromSelectedPlay
   ldx offensiveTeamIndex           ; get index value for offensive team
   lsr                              ; a = 0 and carry set
   sta footballStatus               ; clear football status value
   sta receivingPlayerIndex
   sta startingPossesionLineOfScrimmage
   sta interceptionStatus           ; clear interception status
   lda footballVertPos              ; get football vertical position
   sta lineOfScrimmage              ; set value for line of scrimmage
   ldy selectedPlayNumber,x         ; get offense team selected play
   lda gameSelection                ; get current game selection
   eor #3
   beq .placeFootballWithQuarterback; branch if GAME_SELECTION_COACH
   lda QuarterbackHorizOffsetValues,y;get horizontal offset based on play
   adc teamHorizPositions,x         ; adjust quarterback horizontal position
   sta teamHorizPositions,x         ; set quarterback horizontal position
.placeFootballWithQuarterback
   txa                              ; move offensive team index to accumulator
   tay                              ; move offensive team index to y register
   jsr PositionFootballWithBallCarrier;give quarterback the football
   lda random                       ; get current pseudo random value
   ora #160                         ; 160 <= a <= 255
   sta randomVertMotionTimer        ; set timer for random vertical motion
   and #$1F                         ; 0 <= a <= 31
   adc PuntYardageOffset,x          ; incremet by punt yardage offset
   adc lineOfScrimmage              ; increment by line of scrimmage value
   sta randomPuntYardage
.waitTime
   ldx INTIM
   bne .waitTime
   dex                              ; x = -1
   jmp MainLoop
   
.setInitPositionsFromSelectedPlay
   jsr SetInitPositionsFromSelectedPlay
   bne .waitTime                    ; unconditional branch
   
MovePlayers
   txa                              ; x points to orange team player (i.e. even)
   stx currentPlayerIndex
   and #2
   asl
   tax
.movePlayers
   lda #0                           ; assume all directions allowed
   ldy endingPlayTimer              ; get ending play timer value
   bne .pushDirectionalValuesToStack; branch if pausing for new play setup
   ldy gameSelection                ; get current game selection
   cpy #GAME_SELECTION_COACH
   beq .checkLeftPlayerJoystickMoved; branch if GAME_SELECTION_COACH
   sta tmpAllowedDirValues
   lda offensiveTeamIndex           ; get index value for offensive team
   eor #1                           ; flip value for defensive team index
   tay                              ; set y register to defensive team index
   txa
   lsr
   cmp receivingPlayerIndex
   beq .determineControlledPlayer
   lda JoystickMaskValues,y
   sta tmpAllowedDirValues
.determineControlledPlayer
   cpx #2
   ror                              ; shift carry to D7
   eor INPT4,y                      ; flip value based on defense action button
   rol                              ; shift value to carry
   lda tmpAllowedDirValues
   bcc .combineJoystickValues       ; branch if controlling defensive player
   ora JoystickMaskValues - 1,y
.combineJoystickValues
   ora joystickValues               ; combine with joystick values
   eor #$FF                         ; flip bits (i.e. allowed direction is high)
.checkLeftPlayerJoystickMoved
   bit JoystickMaskValues - 1
   bne .checkRightPlayerJoystickMoved;branch if left player moved joystick
   eor playerAllowedMotionValues,x
.checkRightPlayerJoystickMoved
   bit JoystickMaskValues
   bne .determinePlayerVerticalDirection;branch if right player moved joystick
   eor playerAllowedMotionValues + 1,x
.determinePlayerVerticalDirection
   cpx #2
   bcs .pushDirectionalValuesToStack; branch if processing controllable player
   tay                              ; move directional values to y register
   lda teamVertPositions + 1,x      ; get player vertical position
   adc #8
   cmp footballVertPos
   tya                              ; move direction values to accumulator
   bcs .determinePlayerUpMovement   ; branch if below football
   and #~(MOVE_DOWN_RIGHT_PLAYER | MOVE_UP_RIGHT_PLAYER);clear vertical motion
   ora #MOVE_DOWN_RIGHT_PLAYER      ; allow player to MOVE_DOWN
.determinePlayerUpMovement
   ldy teamVertPositions,x          ; get player vertical position
   cpy footballVertPos              ; compare with football vertical position
   bcc .pushDirectionalValuesToStack; branch if above football
   and #~(MOVE_DOWN_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER);clear vertical motion
   ora #MOVE_UP_LEFT_PLAYER         ; allow player to MOVE_UP
.pushDirectionalValuesToStack
   pha                              ; push directional values to stack
   ldy #0
.checkToRestrictPlayerHorizMovement
   lda frameCount                   ; get current frame count
   and #6                           ; a = 0 || a = 2 || a = 4 || a = 6
   beq .setAllowDirectionalValues
   sbc #3
   bpl .setVerticalDirectionForBlocking
   eor SWCHB                        ; flip console switch values
   and DifficultySwitchMask,y       ; isolate player difficulty setting
   beq .setVerticalAllowedDirections; branch if difficulty set to PRO
   lda #~(MOVE_DOWN_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER)
.setVerticalAllowedDirections
   cpx #2
   bcs .setAllowDirectionalValues   ; branch if processing controllable player
   ora #MOVE_DOWN_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER
.setAllowDirectionalValues
   ora #$0F                         ; allow all directions for white team
   sta tmpAllowedDirValues
   pla                              ; pull directional values from stack
   and tmpAllowedDirValues
   pha                              ; push new directional values to stack
.setVerticalDirectionForBlocking
   lda teamCollisionValues,x        ; get team collision value
   and #$0F                         ; keep lower nybble value
   eor #$0F                         ; flip lower nybble value
   beq .checkPlayerDirectionValues  ; branch if no collision
   pla                              ; pull directional values from stack
   and BlockingDirectionalValues,y  ; clear directions not allowed
   pha                              ; push new directional values to stack
.checkPlayerDirectionValues
   pla                              ; pull directional values from stack
   asl                              ; shift move right value to carry
   bcc .checkForPlayerMovingLeft    ; branch if not moving right
   inc teamHorizPositions,x         ; move player right
.checkForPlayerMovingLeft
   asl                              ; shift move left value to carry
   bcc .checkForPlayerMovingDown
   dec teamHorizPositions,x         ; move player left
.checkForPlayerMovingDown
   asl                              ; shift move down value to carry
   bcc .checkForPlayerMovingUp
   inc teamVertPositions,x          ; move player down field
.checkForPlayerMovingUp
   asl                              ; shift move up value to carry
   pha                              ; push directional values to stack
   bcc .keepPlayersInFieldBoundaries
   dec teamVertPositions,x          ; move player up field
.keepPlayersInFieldBoundaries
   lda #VERT_MAX                    ; get vertical boundary max value
   cmp teamVertPositions,x
   bcc .setTeamVerticalPosition     ; branch to set player to vertical boundary
   lda #VERT_MIN                    ; get vertical boundary min value
   cmp teamVertPositions,x
   bcs .setTeamVerticalPosition     ; branch to set player to vertical boundary
   lda teamVertPositions,x          ; get player vertical position
.setTeamVerticalPosition
   sta teamVertPositions,x
   lda #HORIZ_MAX                   ; get horizontal boundary max value
   cmp teamHorizPositions,x
   bcc .setTeamHorizontalPosition   ; branch to set player to horizontal boundary
   lda #HORIZ_MIN                   ; get horizontal boundary min value
   cmp teamHorizPositions,x
   bcs .setTeamHorizontalPosition   ; branch to set player to horizontal boundary
   lda teamHorizPositions,x         ; get player horizontal position
.setTeamHorizontalPosition
   sta teamHorizPositions,x
   inx
   iny
   cpy #2
   bcc .checkToRestrictPlayerHorizMovement
   pla
   txa
   and #2
   beq SetKernelPlayerPositionValues
   jmp .movePlayers
   
SetKernelPlayerPositionValues
   ldx currentPlayerIndex
   lda teamVertPositions,x
   sta player1VertPos
   lda teamVertPositions + 1,x
   sta player2VertPos
   lda teamHorizPositions,x
   sta player1HorizPos
   lda teamHorizPositions + 1,x
   sta player2HorizPos
   jmp .waitTime
   
SetInitPositionsFromSelectedPlay SUBROUTINE
   ldx #1
.setInitPositionsFromSelectedPlay
   stx tmpPlayerIndex
   lda selectedPlayStatus           ; get selected play status values
   bne .determineInitPositions      ; branch if a player not selected play
   lda selectedPlayNumber,x         ; get player selected play
.determineInitPositions
   and #7
   pha                              ; push play selection to stack
   cmp #PLAY_TIGHT_RIGHT            ; set carry if not PLAY_PUNT or PLAY_DEEP
   lda tmpPlayerIndex
   rol                              ; a = (player index * 2) + !(PLAY_PUNT)
   tay
   lda footballVertPos              ; get football vertical position
   clc
   adc InitTeamBackVertOffsetValues,y
   sta teamVertPositions,x          ; set team's back player vertical position
   clc
   adc InitTeamLineVertOffsetValues,y
   sta displayedPlayersVertPos,x
   sta teamVertPositions + 2,x
   sta teamVertPositions + 4,x
   sta teamVertPositions + 6,x
   pla                              ; pull play selection from stack
   cmp #PLAY_SPLIT_RIGHT
   lda #0
   rol
   tay                              ; 0 = PLAY_TIGHT -- 1 = PLAY_SPLIT
   lda #[(W_SCREEN + 1) - W_PLAYER] / 2
   sta teamHorizPositions,x         ; center Quarterback or defensive back
   sta teamHorizPositions + 2,x     ; center Center or Defensive tackle
   lda InitLeftPlayerHorizPositionValues,y
   sta teamHorizPositions + 4,x
   sta displayedPlayersHorizPos,x
   lda InitRightPlayerHorizPositionValues,y
   sta teamHorizPositions + 6,x
   lda TeamFormationNUSIZValues,y
   sta teamFormationValues,x
   dex
   bpl .setInitPositionsFromSelectedPlay
   lda #INIT_FOOTBALL_HORIZ_POS
   sta footballHorizPos
   rts

;
; Horizontal reset starts at cycle 8 (i.e. pixel 24). The object's position is
; incremented by 55 to push their pixel positioning to start at cycle 18 (i.e.
; pixel 54) with an fine adjustment of -6 to start objects at pixel 48.
;
DetermineObjectHorizValues
   clc
   adc #55                          ; increment horizontal position value by 55
   pha                              ; push value to stack for later
   lsr                              ; divide horizontal position by 16
   lsr
   lsr
   lsr
   tay                              ; save the value
   pla                              ; get the object's x position
   and #$0F                         ; keep div16 remainder
   sty tmpHorizPosDiv16             ; division by 16 is coarse movement value
   clc
   adc tmpHorizPosDiv16             ; add in division by 16 remainder
   cmp #15
   bcc .skipSubtractions
   sbc #15                          ; subtract 15
   iny                              ; and increment coarse value
.skipSubtractions
   cmp #8
   eor #$0F
   bcs .shiftFineMotionValue
   adc #1                           ; get 2's complement value for fine motion
   dey                              ; reduce coarse value
.shiftFineMotionValue
   asl
   asl
   asl
   asl
   rts

ReadConsoleSwitches
   ldx #0
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry bit
   ror                              ; rotate SELECT to carry and RESET to D7
   bcs .checkForResetPressed        ; branch if SELECT not pressed
ResetScoreBoardValues
   lda #BLANK_NUMBER_PTR << 4 | BLANK_NUMBER_PTR
   sta player2Score                 ; set player 2 score to Blank character
   sta clockSeconds                 ; set clock seconds to Blank character
   lda #0 << 4 | BLANK_NUMBER_PTR
   sta currentDown
   sta clockMinutes
   lda #6
   sta colorCycleMode
   dex
   stx gameState                    ; set game state to GAME_OVER (i.e. x = -1)
   lda #RIGHT_PLAYER_NOT_SELECTED_PLAY | LEFT_PLAYER_NOT_SELECTED_PLAY
   sta selectedPlayStatus           ; no player selected play
   ldy gameSelection                ; get current game selection
   ldx selectDebounceRate           ; get select debounce rate value
   bne .incrementSelectDebounceTimer; branch if debounce rate not expired
   cpy #MAX_GAME_SELECTION
   bcc .incrementGameSelection
   ldy #0
.incrementGameSelection
   iny
   sty gameSelection                ; set current game selection
   tya                              ; move game selection to accumulator
   ora #BLANK_NUMBER_PTR << 4       ; combine with BLANK_NUMBER_PTR
   sta player1Score                 ; set to show game selection
.incrementSelectDebounceTimer
   inx
   cpx #63
   bcc .setSelectDebounceTimer
   ldx #0
.setSelectDebounceTimer
   stx selectDebounceRate
   rts

.checkForResetPressed
   stx selectDebounceRate           ; reset select debounce timer
   bmi CheckForBallInPlay           ; branch if RESET not pressed
ClearGameRAM
   ldx #<[currentDown - endingPlayTimer + 1]
   lda #0
.clearGameRAM
   sta endingPlayTimer - 1,x
   dex
   bne .clearGameRAM
   inc currentDown
   lda #INIT_CLOCK_MINUTES
   sta clockMinutes                 ; initialize clock minutes
   lda #LEFT_TEAM_STARTING_LINE_OF_SCRIMMAGE
   jmp .initFootballVerticalPosition; set inital football vertical position
   
CheckForBallInPlay
   ldx offensiveTeamIndex           ; get index value for offensive team
   lda ballSnapTimer                ; get ball snap timer value
   beq .gamePlayInAction            ; branch if ball in play
   rts

.gamePlayInAction
   lda endingPlayTimer              ; get ending player timer
   beq CheckForFootballPassOrPunt   ; branch if players allowed to move
   jmp .decrementEndingPlayTimer
   
CheckForFootballPassOrPunt
   lda footballStatus               ; get football status value
   bne .checkForFootballCaught      ; branch if not available for flight
   tay                              ; move football status to y register
   jsr CheckFootballPassingLineMarker;check if passed line of scrimmage (y = 0)
   bcc .checkForLaunchingFootball   ; branch if not passed line of scrimmage
   jmp .footballNotAllowedForPuntOrPass;passed line of scrimmage
   
.checkForLaunchingFootball
   lda actionButtonDebounceValues,x ; get offensive team action button value
   bpl .checkForSafety              ; branch if action button not pressed
   inc footballStatus               ; increment to show football in flight
   lda #12
   sta AUDC0                        ; set audio channel for launching football
.checkForFootballCaught
   bpl CheckForFootballCaught       ; branch if football not caught
.checkForSafety
   jmp .checkForTackledInEndZone
   
CheckForFootballCaught
   lda selectedPlayNumber,x         ; get offensive team selected play
   sta tmpOffensivePlay
   beq .checkIfReceivingTeamCaughtFootball;branch if PLAY_PUNT
   lda TeamFootballCollisionValues,x; get team football collision value
   and footballCollisionValue       ; mask with football collision value
   eor TeamFootballCollisionValues,x
   jsr DetermineReceivingPlayer
   beq .checkIfReceivingTeamCaughtFootball
   bpl OffensivePlayerCaughtFootball; branch if receiver caught football
.checkIfReceivingTeamCaughtFootball
   lda TeamFootballCollisionValues,x
   ora footballCollisionValue
   eor #$FF
   jsr DetermineReceivingPlayer
   bpl DefensivePlayerCaughtFootball
.controlBallInFlight
   clc
   lda teamHorizPositions,x         ; get offensive player horizontal position
   adc #(W_PLAYER / 2)              ; increment by the horizontal mid point
   sta footballHorizPos             ; set football horizontal position
   lda BallInFlightVertDirection,x  ; get ball in flight vertical change
   adc footballVertPos              ; increment by football vertical position
   cmp #H_KERNEL + 24
   sta footballVertPos              ; set football vertical position
   bcs .setBallToLineOfScrimmage
   eor randomPuntYardage
   ora tmpOffensivePlay
   beq SetKickingYardageForMissedPunt
   jmp DetermineAllowedMotionValues
   
DefensivePlayerCaughtFootball
   beq .playerInterceptedBall
   lda tmpOffensivePlay             ; get offensive selected play
   beq .controlBallInFlight         ; branch if PLAY_PUNT
.playerInterceptedBall
   txa                              ; move offensive team index to accumulator
   eor #1                           ; flip value
   sta offensiveTeamIndex           ; set new offensive team index
   lsr                              ; shift defense team index to carry
   tya                              ; move intercept player index to accumulator
   rol
   tax                              ; set index of player with ball
   lda #1
   sta interceptionStatus           ; set to show pass intercepted
   sta scoringFrequencyIndex        ; set scoring frequency index
   lda tmpOffensivePlay             ; get offensive selected play
   beq .setDefensiveReceivingPlayerIndex; branch if PLAY_PUNT
   lda #7 << 4 | 15
   sta gameMusicSoundValues         ; set music values for interception
.setDefensiveReceivingPlayerIndex
   sty receivingPlayerIndex
   lda teamVertPositions,x          ; get ball carrier vertical position
   ldx offensiveTeamIndex           ; get index value for offensive team
   clc
   adc #4
   jsr CheckObjectForCrossingGoalLine
   bcs .setAudioChannelForCatch     ; branch if player not crossed goal line
   bne .setAudioChannelForCatch
   lda InterceptedStartingLineOfScrimmage,x
   sta startingPossesionLineOfScrimmage
   bne .checkToResetNumberOfDowns   ; unconditional branch
   
SetKickingYardageForMissedPunt
   jsr CheckFootballCrossingGoalLine
   bcs .changePlayerPossesion       ; branch if football not crossed goal line
.setBallToLineOfScrimmage
   lda tmpOffensivePlay             ; get offesive selected play
   bne ResetBallToLineOfScrimmage   ; branch if not PLAY_PUNT
   lda ScoringStartingLineOfScrimmage + 1,x
   bne .setFootballVertPosition     ; unconditional branch
   
OffensivePlayerCaughtFootball
   sty receivingPlayerIndex
.setAudioChannelForCatch
   lda #4
   sta AUDC0
.footballNotAllowedForPuntOrPass
   lda #$80
   sta footballStatus               ; set not allow pass or punt
.checkForTackledInEndZone
   txa                              ; move offensive team index to accumulator
   lsr                              ; shift team index value to carry
   lda receivingPlayerIndex
   rol
   tay
   lda teamCollisionValues,y        ; get team collision value
   and #$0F                         ; keep lower nybble value
   eor #$0F                         ; flip lower nybble value
   beq .ballCarrierNotTackled       ; branch if no collision
   jsr CheckFootballCrossingGoalLine
   bcs .checkToResetNumberOfDowns   ; branch if football not crossed goal line
.scoreForCrossingGoalLine
   tya
   and #1
   eor #1
   tax                              ; set index for scoring team
   lda #7 << 4 | 15
   sta gameMusicSoundValues
   lda PointValues,y                ; get player point value
   sta scoringFrequencyIndex        ; set scoring frequency index
   sed
   clc
   adc scoreBoardValues,x           ; increment score by point value
   cld
   sta scoreBoardValues,x           ; set new score for player
   lda ScoringStartingLineOfScrimmage,y
   sta startingPossesionLineOfScrimmage
.changePlayerPossesion
   jmp ChangePlayerPossesion
   
.ballCarrierNotTackled
   jsr PositionFootballWithBallCarrier
   jsr CheckFootballCrossingGoalLine
   bcs .skipScoreForCrossingGoalLine; branch if football not crossed goal line
   bne .scoreForCrossingGoalLine
.skipScoreForCrossingGoalLine
   jmp DetermineAllowedMotionValues
   
ResetBallToLineOfScrimmage
   lda lineOfScrimmage              ; get line of scrimmage value
   sta footballVertPos
.checkToResetNumberOfDowns
   ldx offensiveTeamIndex           ; get index value for offensive team
   ldy interceptionStatus           ; get interception status
   bne ResetNumberOfDowns           ; branch if pass intercepted
   iny                              ; y = 1
   jsr CheckFootballPassingLineMarker;check if ball carrier reached first down
   bcs ResetNumberOfDowns           ; branch if passed first down marker
   ldy currentDown                  ; get current down
   iny                              ; increment number of downs
   cpy #MAX_DOWNS + 1
   bcc .setNextDownValue            ; branch if not exceeded number of downs
   lda footballVertPos              ; get football vertical position
   adc FootballDownTurnoverVertOffsetValues,x
.setFootballVertPosition
   sta footballVertPos
ChangePlayerPossesion
   lda offensiveTeamIndex           ; get index value for offensive team
   eor #1                           ; flip D0 bit
   tax                              ; set x to new offensive team
   sta offensiveTeamIndex           ; set new offensive team index
ResetNumberOfDowns
   ldy #1
.setNextDownValue
   sty currentDown
   lda #128 + 1
   sta endingPlayTimer              ; stall player movement for 128 frames
   sta AUDC0
   sta colorCycleMode
.decrementEndingPlayTimer
   dec endingPlayTimer
   bne .doneCheckFootballPassingLineMarker
   lda startingPossesionLineOfScrimmage
   beq .resetSelectedPlayStatus
.initFootballVerticalPosition
   sta footballVertPos
.resetSelectedPlayStatus
   lda #RIGHT_PLAYER_NOT_SELECTED_PLAY | LEFT_PLAYER_NOT_SELECTED_PLAY
   sta selectedPlayStatus           ; no player selected play
   sta ballSnapTimer
   ldy currentDown                  ; get current down
   dey
   bne .skipInitFirstDownMarker     ; branch if not first down
   lda FirstDownMarkerVertOffsetValues,x
   clc
   adc footballVertPos              ; increment by football vertical position
   sta firstDownMarkerVertPos       ; set first down marker vertical position
.skipInitFirstDownMarker
   jmp SetInitPositionsFromSelectedPlay
   
CheckFootballPassingLineMarker
   lda footballVertPos              ; get football vertical position
   clc
   adc FootballVertOffsetValues,x   ; increment by team offset
   cmp lineMarkerValues,y           ; compare with line marker value
   beq .doneCheckFootballPassingLineMarker
   lda FootballVertOffsetValues,x
   bne .doneCheckFootballPassingLineMarker;branch if checking player 1 team
   rol                              ; shift carry to D0
   eor #1                           ; flip D0 value
   ror                              ; rotate D0 to carry
.doneCheckFootballPassingLineMarker
   rts

DetermineAllowedMotionValues
   lda #3
   sta tmpPlayerNumber
   ldy #7
.determinePlayerGroupAllowedMotion
   ldx #1
.determinePlayerAllowedMotion
   jsr Randomize
   sty tmpPlayerIndex
   lda selectedPlayNumber,x         ; get player selected play
   beq .determineMotionForSelectedPlay;branch if PLAY_PUNT or PLAY_DEEP
   and #1                           ; keep D0 (i.e. 0 = LEFT...1 = RIGHT)
   clc
   adc #1
.determineMotionForSelectedPlay
   asl                              ; multiply value by number of team players
   asl
   ora tmpPlayerNumber              ; combine with player number for the team
   tay
   lda SelectedPlayAllowedMotionValues,y
   ldy gameSelection                ; get current game selection
   cpy #GAME_SELECTION_CPU_CONTROL
   beq .setDesiredVerticalMotion    ; branch if players following set pattern
   and random
.setDesiredVerticalMotion
   ora #MY_MOVE_DOWN | MY_MOVE_UP >> 4
   ldy tmpPlayerNumber
   bne .setPlayerAllowedMotion
   ldy randomVertMotionTimer        ; get random vertical motion timer
   beq .setPlayerAllowedMotion      ; branch if reached 0
   dec randomVertMotionTimer        ; decrement random vertical motion timer
   eor #(MY_MOVE_DOWN | MY_MOVE_UP) | [(MY_MOVE_DOWN | MY_MOVE_UP)] >> 4
.setPlayerAllowedMotion
   and JoystickMaskValues - 1,x
   ldy tmpPlayerIndex
   sta playerAllowedMotionValues,y  ; set player allowed motion values
   dey
   dex
   bpl .determinePlayerAllowedMotion
   dec tmpPlayerNumber
   bpl .determinePlayerGroupAllowedMotion
   rts

BlockingDirectionalValues
   .byte ~MY_MOVE_DOWN, ~MY_MOVE_UP
   
NumberFonts
zero
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $33 ; |..XX..XX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
one
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
two
   .byte $3F ; |..XXXXXX|
   .byte $03 ; |......XX|
   .byte $3F ; |..XXXXXX|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
three
   .byte $3F ; |..XXXXXX|
   .byte $30 ; |..XX....|
   .byte $3C ; |..XXXX..|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
four
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $03 ; |......XX|
five
   .byte $3F ; |..XXXXXX|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
   .byte $03 ; |......XX|
   .byte $3F ; |..XXXXXX|
six
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
   .byte $03 ; |......XX|
   .byte $3F ; |..XXXXXX|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
eight
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
nine
   .byte $3F ; |..XXXXXX|
   .byte $30 ; |..XX....|
   .byte $3F ; |..XXXXXX|
   .byte $33 ; |..XX..XX|
   .byte $3F ; |..XXXXXX|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
;
; last 2 bytes shared with table below
;

ColonGraphic
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   
FootballPlayerSprite
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $5A ; |.X.XX.X.|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $06 ; |.....XX.|
   .byte $07 ; |.....XXX|
;
; last byte shared with table below
;
FieldColorEORValues
   .byte 0, 0, 2, 0, 2, 0, 2, 0, 2, 0
   .byte 2, 0, 2, 0, 2, 0, 2, 0, 2, 2
   
PointValues
   .byte POINTS_SAFETY, POINTS_TOUCHDOWN
   .byte POINTS_TOUCHDOWN, POINTS_SAFETY
   
GameMusicSoundFrequencies
   .byte 27, 15, 27, 15, 27, 18, 20, 15, 20
   .byte 15, 27, 18, 23, 20, 23, 119, 187
   
DifficultySwitchMask
SelectedPlayStatusMask
   .byte LEFT_PLAYER_NOT_SELECTED_PLAY, RIGHT_PLAYER_NOT_SELECTED_PLAY
   
BallInFlightVertDirection
   .byte 1;, -1
;
; last byte shared with table below
;
QuarterbackHorizOffsetValues
   .byte 0 - 1, 15 - 1, -15 - 1, 15 - 1, -15 - 1; carry set for addition
   
   .byte 5, 10, 48                  ; these bytes aren't referenced
   
TeamFootballCollisionValues
   .byte $55, $AA
   
InitTeamBackVertOffsetValues
   .byte 210, 226, 36, 20
   
InitLeftPlayerHorizPositionValues
   .byte INIT_LEFT_PLAYER_TIGHT_HORIZ_POS, INIT_LEFT_PLAYER_SPLIT_HORIZ_POS
   
InitRightPlayerHorizPositionValues
   .byte INIT_RIGHT_PLAYER_TIGHT_HORIZ_POS, INIT_RIGHT_PLAYER_SPLIT_HORIZ_POS
   
TeamFormationNUSIZValues
   .byte THREE_COPIES, THREE_MED_COPIES
   
FootballDownTurnoverVertOffsetValues
   .byte 2, -4

PuntYardageOffset
   .byte (H_PLAYER + 2) * 3, (H_PLAYER + 2) * 11
   
FirstDownMarkerVertOffsetValues
   .byte 21, -16
   
ScoringStartingLineOfScrimmage
   .byte LEFT_TEAM_SAFETY_LINE_OF_SCRIMMAGE
   .byte RIGHT_TEAM_STARTING_LINE_OF_SCRIMMAGE
   .byte LEFT_TEAM_STARTING_LINE_OF_SCRIMMAGE
   .byte RIGHT_TEAM_SAFETY_LINE_OF_SCRIMMAGE
   
InterceptedStartingLineOfScrimmage
   .byte LEFT_TEAM_STARTING_LINE_OF_SCRIMMAGE
   .byte RIGHT_TEAM_STARTING_LINE_OF_SCRIMMAGE
   
GameColorTable
;
; B&W values
;
   .byte FOOTBALL_FIELD_BW_VALUE
   .byte FOOTBALL_BW_VALUE
   .byte WHITE_TEAM_BW_VALUE
   .byte ORANGE_TEAM_BW_VALUE
;
; Color Values
;
   .byte FOOTBALL_FIELD_COLOR_VALUE
   .byte FOOTBALL_COLOR_VALUE
   .byte WHITE_TEAM_COLOR_VALUE
   .byte ORANGE_TEAM_COLOR_VALUE

FootballVertOffsetValues
   .byte 4;, 0
;
; last byte shared with table below
;
PlayIndicator

GRAPHICS_BYTE_IDX SET 1

   REPEAT H_INTERLEAVED_GRAPHICS
   
      INTERLEAVED_GRAPHICS GRAPHICS_BYTE_IDX, $00, $00, $00, $00, $00
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
      INTERLEAVED_GRAPHICS GRAPHICS_BYTE_IDX, $20, $00, $E0, $88, $F8
                                       ; |..X.....|
                                       ; |........|
                                       ; |XXX.....|
                                       ; |X...X...|
                                       ; |XXXXX...|
                                       
GRAPHICS_BYTE_IDX SET GRAPHICS_BYTE_IDX + 1

   REPEND

OffensiveIndicator

GRAPHICS_BYTE_IDX SET 1

   REPEAT H_INTERLEAVED_GRAPHICS
   
      INTERLEAVED_GRAPHICS GRAPHICS_BYTE_IDX, $08, $04, $7E, $04, $08
                                       ; |....X...|
                                       ; |.....X..|
                                       ; |.XXXXXX.|
                                       ; |.....X..|
                                       ; |....X...|
      INTERLEAVED_GRAPHICS GRAPHICS_BYTE_IDX, $10, $20, $7E, $20, $10
                                       ; |...X....|
                                       ; |..X.....|
                                       ; |.XXXXXX.|
                                       ; |..X.....|
                                       ; |...X....|
                                       
GRAPHICS_BYTE_IDX SET GRAPHICS_BYTE_IDX + 1

   REPEND
      
InitTeamLineVertOffsetValues
   .byte (H_PLAYER + 2) << 1, H_PLAYER + 2
   .byte -[(H_PLAYER + 2) << 1], -(H_PLAYER + 2)
   
SelectedPlayAllowedMotionValues
;
; PLAY_PUNT or PLAY_DEEP directions
;
   .byte NO_MOVE
   .byte ~(MOVE_UP_LEFT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_UP_LEFT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_UP_LEFT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
;
; PLAY_TIGHT_LEFT or PLAY_SPLIT_LEFT directions
;
   .byte ~(MOVE_RIGHT_LEFT_PLAYER | MOVE_RIGHT_RIGHT_PLAYER)
   .byte ~(MOVE_RIGHT_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER | MOVE_RIGHT_RIGHT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_UP_LEFT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_RIGHT_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER | MOVE_RIGHT_RIGHT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
;
; PLAY_TIGHT_RIGHT or PLAY_SPLIT_RIGHT directions
;
   .byte ~(MOVE_LEFT_LEFT_PLAYER | MOVE_LEFT_RIGHT_PLAYER)
   .byte ~(MOVE_LEFT_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER | MOVE_LEFT_RIGHT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_LEFT_LEFT_PLAYER | MOVE_UP_LEFT_PLAYER | MOVE_LEFT_RIGHT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   .byte ~(MOVE_UP_LEFT_PLAYER | MOVE_DOWN_RIGHT_PLAYER)
   
BCD2Digits
   sta tmpDisplayValue        ; 3         save value
   asl                        ; 2         multiply value by 4
   asl                        ; 2
   adc tmpDisplayValue        ; 3         add in original (i.e. a * 5)
   sta digitGraphicPtrs,y     ; 5
   lda #>NumberFonts          ; 2
   sta digitGraphicPtrs + 1,y ; 5
   dey                        ; 2
   dey                        ; 2
   rts                        ; 6

CheckFootballCrossingGoalLine
   lda footballVertPos              ; get football vertical position
CheckObjectForCrossingGoalLine
   clc
   adc FootballVertOffsetValues,x   ; increment by football offset value
   cmp #H_KERNEL - 16
   bcs .objectCrossedGoalLine       ; branch if crossed left player goal line
   cmp #56
   bcs .doneDetermineCrossingGoalLine;branch if not crossed right player goal line
.objectCrossedGoalLine
   lda offensiveTeamIndex           ; get index value for offensive team
   rol                              ; multiply by 2 and shift in carry
   tay
   eor offensiveTeamIndex
   and #1
.doneDetermineCrossingGoalLine
   rts

DetermineReceivingPlayer
   ldy #3
   sta tmpFootballCollisionValue
   lda #3 << 6
.determineReceivingPlayer
   bit tmpFootballCollisionValue
   bne .doneDetermineReceivingPlayer; branch if found receiving player
   lsr
   lsr
   dey
   bpl .determineReceivingPlayer
.doneDetermineReceivingPlayer
   tya
   rts

   .org ROM_BASE + 2048 - 4, 10
   .word Start

JoystickMaskValues
   .byte P1_JOYSTICK_MASK, P0_JOYSTICK_MASK
