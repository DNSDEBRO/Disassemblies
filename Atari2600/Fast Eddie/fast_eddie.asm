   LIST OFF
; ***  F A S T   E D D I E  ***
; Copyright 1982 Sirius
; Programmer: Mark Turmell

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 16, 2018
;
;  *** 122 BYTES OF RAM USED 6 BYTES FREE
;  ***   2 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, SIRIUS                                       =
; =                                                                            =
; ==============================================================================

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

   IF COMPILE_REGION != NTSC

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

FPS                     = 60        ; ~60 frames per second
VSYNC_TIME              = 42
VBLANK_TIME             = 39
OVERSCAN_TIME           = 38

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0F
YELLOW                  = $10
RED_ORANGE              = $20
RED                     = $40
BLUE                    = $80
LT_BLUE                 = $90
GREEN                   = $C0

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_DIGITS                = 8
H_KERNEL                = 220
H_KERNEL_SECTION        = 26

MAX_LIVES               = 3

XMIN                    = 8
XMAX                    = 149
XMID                    = (XMAX - XMIN) / 2

MAX_COLLECTED_PRIZES    = 10
MAX_PRIZES              = 10

MIN_KERNEL_SECTION      = 1
MAX_KERNEL_SECTION      = 5

LADDER_DELAY_VALUE      = 10

INIT_AWARD_TIMER_VALUE  = 125

MAX_GAME_SCREEN         = 10
MAX_GAME_LEVEL          = 8

MAX_FRAME_COLLISION_VALUE = 4


FAST_EDDIE_LADDER_DOWN_DIR = 0
FAST_EDDIE_LADDER_UP_DIR = ~FAST_EDDIE_LADDER_DOWN_DIR

;
; initial horizontal positions values
;
; initial Sneaker horizontal position values
INIT_HORIZ_POS_HIGH_TOP = XMID + 12
INIT_HORIZ_POS_SNEAKER_02 = XMAX - 48
INIT_HORIZ_POS_SNEAKER_03 = XMID + 2
INIT_HORIZ_POS_SNEAKER_04 = [XMID / 2] - 4
INIT_HORIZ_POS_SNEAKER_05 = XMIN - 3
; initial Prize horizontal position values
INIT_HORIZ_POS_PRIZE_02 = XMID - 20
INIT_HORIZ_POS_PRIZE_03 = XMID / 2
INIT_HORIZ_POS_PRIZE_04 = XMAX - 29
INIT_HORIZ_POS_PRIZE_05 = XMID
; initial Fast Eddie horizontal position value
INIT_HORIZ_POS_FAST_EDDIE = XMID + 4

;
; Sneaker right border values
;
SNEAKER_ONE_COPY_RIGHT_BOUNDARY = XMAX - 1
SNEAKER_TWO_COPIES_RIGHT_BOUNDARY = XMAX - 16
SNEAKER_TWO_MED_COPIES_RIGHT_BOUNDARY = XMAX - 32
SNEAKER_THREE_COPIES_RIGHT_BOUNDARY = XMAX - 32
SNEAKER_TWO_WIDE_COPIES_RIGHT_BOUNDARY = XMAX - 1
SNEAKER_DOUBLE_SIZE_RIGHT_BOUNDARY = XMAX - 11
SNEAKER_THREE_MED_COPIES_RIGHT_BOUNDARY = XMAX - 1
SNEAKER_QUAD_SIZE_RIGHT_BOUNDARY = XMAX - 26

;===============================================================================
; M A C R O S
;===============================================================================

;
; time wasting macros
;

   MAC SLEEP_3
      bit $FF
   ENDM
   
   MAC SLEEP_6
      eor ($FC,x)
   ENDM
   
   MAC SLEEP_7 
      rol ROM_BASE,x
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

sneakerHorizDelta       ds 5        ; movement values for Sneakers
;--------------------------------------
highTopHorizDelta       = sneakerHorizDelta
sneakerHorizDeltaValues = highTopHorizDelta + 1
;--------------------------------------
_05PlatformSneakerHorizDelta = sneakerHorizDeltaValues
_04PlatformSneakerHorizDelta = _05PlatformSneakerHorizDelta + 1
_03PlatformSneakerHorizDelta = _04PlatformSneakerHorizDelta + 1
_02PlatformSneakerHorizDelta = _03PlatformSneakerHorizDelta + 1
objectHorizPositions    ds 5        ; Sneaker horizontal position values
;--------------------------------------
highTopHorizPosition    = objectHorizPositions
sneakerHorizPositions   = highTopHorizPosition + 1
;--------------------------------------
_05PlatformSneakerHorizPos = sneakerHorizPositions
_04PlatformSneakerHorizPos = _05PlatformSneakerHorizPos + 1
_03PlatformSneakerHorizPos = _04PlatformSneakerHorizPos + 1
_02PlatformSneakerHorizPos = _03PlatformSneakerHorizPos + 1
prizeHorizPositions     ds 4        ; prize horizontal position values
;--------------------------------------
_05PlatformPrizeHorizPos = prizeHorizPositions
_04PlatformPrizeHorizPos = _05PlatformPrizeHorizPos + 1
_03PlatformPrizeHorizPos = _04PlatformPrizeHorizPos + 1
_02PlatformPrizeHorizPos = _03PlatformPrizeHorizPos + 1
fastEddieHorizPos       ds 1        ; Fast Eddie horizontal position
objectFCHorizValues     ds 9        ; fine / coarse horizontal values 
;--------------------------------------
tmpGameSelectionFCValues = objectFCHorizValues
fastEddieFCHorizValue   ds 1
ladderPlacementValue    ds 1        ; does PF2 ladders when D7 is low
ladderGraphicPtrs       ds 20       ; graphic pointers to ladders
;--------------------------------------
kernelPF1LadderGraphicPtrs = ladderGraphicPtrs
kernelPF2LadderGraphicPtrs = kernelPF1LadderGraphicPtrs + 2

unused_00               ds 1

kernelPFLadderIndex     ds 1        ; index to read ladder graphics
middleSneakerMoveDelay  ds 1        ; movement delay value for Sneaker
ladderJustificationValue ds 1
numberOfLives           ds 1        ; number of remaining lives
gameSelectionGraphicPtrs ds 2       ; graphic pointers for game selection
;--------------------------------------
prizeGraphicPtrs        = gameSelectionGraphicPtrs; graphic pointers for prize
;--------------------------------------
sneakerNUSIZValuePtrs   = prizeGraphicPtrs; NUSIz pointers for Sneakers
prizeMovementDelayValue ds 1
;--------------------------------------
tmpFastEddieDeathSoundDelay = prizeMovementDelayValue
;--------------------------------------
prizeSpawningPlatform   = tmpFastEddieDeathSoundDelay
footAnimationIndex      ds 1        ; animation index for Sneaker feet
platformColor           ds 1        ; platform color value
alwaysZero              ds 1        ; set and never used
sneakerGraphicPtrs      ds 2        ; graphic pointer for Sneaker graphics

unused_01               ds 1

prizeColor              ds 1        ; color value for prizes
highTopGraphicPtrs      ds 2        ; graphic pointer for High-Top graphics
sneakerFeetGraphicPtrs  ds 2        ; graphic pointer for Sneaker feet graphics
highTopColorPtrs        ds 2        ; pointer to High-Top colors
fastEddieGraphicPtrs    ds 2        ; graphic pointer for Fast Eddie
fastEddieKernelGraphicPtrs ds 2     ; only used in kernel
tmpScoreHundredsGraphic ds 1
;--------------------------------------
tmpFastEddieGraphic     = tmpScoreHundredsGraphic
;--------------------------------------
tmpPF1LadderGraphic     = tmpFastEddieGraphic
tmpHighTopGraphic       ds 1
actionButtonDebounce    ds 1        ; debounce value for action button
fastEddieColorPtrs      ds 2        ; pointers to Fast Eddie color data
fastEddieJumpingDelayValue ds 1
fastEddieAnimationIndex ds 1        ; animation index for Fast Eddie
tmpFastEddieHorizDelta  ds 1
;--------------------------------------
tmpLadderKernelSection  = tmpFastEddieHorizDelta
fastEddieHorizLadderValues ds 5
fastEddieKernelSection  ds 1        ; Fast Eddie kernel section
fastEddieSinkingOffset  ds 1
prizesCollected         ds 1        ; number of prizes collected
ladderSoundValue        ds 1
fastEddieLadderDir      ds 1        ; direction Fast Eddie traversing ladder
fastEddieOnLadderValue  ds 1
fastEddieLadderDelay    ds 1

unused_02               ds 1

currentScreen           ds 1
prizeControlValue       ds 1
prizeArray              ds 4
tmpPrizePoints          ds 1
;--------------------------------------
tmpFastEddiePrizeKernelSection = tmpPrizePoints
screenDoneAwardTimer    ds 1
tmpScoreIndexValues     ds 4
;--------------------------------------
tmpKernelSection        = tmpScoreIndexValues
tmpObjectIndex          = tmpKernelSection + 1
tmpFastEddieCoarseValue = tmpObjectIndex + 1
;--------------------------------------
tmpSneakerCoarseValue   = tmpFastEddieCoarseValue
tmpSneakerNUSIZPtr      ds 2
;--------------------------------------
digitGraphicPtrs        = tmpSneakerNUSIZPtr
;--------------------------------------
tmpFastEddieLiteral_05  = digitGraphicPtrs
tmpFastEddieFontLoop    = digitGraphicPtrs + 1
playerScore             ds 2        ; two bytes for score (BCD)
fastEddieHorizDir       ds 1
allowedToSpawnPrize     ds 1
moveMiddlePlatformSneakers ds 1
gameSelection           ds 1        ; current game selection and level
gameState               ds 1
frameCollisionCount     ds 1
fastEddieDeathSequence  ds 1
resetDebounce           ds 1        ; debounce value for RESET switch
frameCount              ds 1
gameOverSoundFrequency  ds 1
gameOverSoundValues     ds 1
currentPlatformColor    ds 1
startBWValue            ds 1        ; B/W values read at boot up for pause
collectedPrizeSoundValue ds 1

unused_03               ds 1

remainingLivesColor     ds 1
;--------------------------------------
ladderColor             = remainingLivesColor
floatingPrizePointValue ds 1
selectDebounce          ds 1        ; debounce value for SELECT switch

   echo "***",(* - $80 - 4)d, "BYTES OF RAM USED", ($100 - * + 4)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

Start
;
; Set up everything so the power up state is known.
;
   sei
   cld
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = #$FF
   txs                              ; set stack to the beginning
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   sta startBWValue                 ; save B/W switch value at cart startup
   lda #MAX_LIVES
   sta numberOfLives                ; initialize number of lives
   sta prizeMovementDelayValue
   sta fastEddieLadderDelay
   ldy #>FastEddieColorValues
   sty fastEddieGraphicPtrs + 1     ; Fast Eddie colors and graphics on same page
   sty fastEddieColorPtrs + 1
   sty prizeColor
   iny                              ; y = #$FC
   sty actionButtonDebounce         ; set D7 high for action button held
   sty highTopColorPtrs + 1         ; set High-Top colors pointer MSB value
   lda #>SneakerGraphics
   sta sneakerGraphicPtrs + 1       ; Sneaker and High-Top graphics on same page
   sta highTopGraphicPtrs + 1
   sta sneakerFeetGraphicPtrs + 1
   lda #LT_BLUE + 7
   sta ladderPlacementValue
   sta platformColor                ; initialize platform color
   ldy #<[fastEddieHorizPos - sneakerHorizDelta]
.initHorizPositionsAndDirections
   lda InitHorizPosAndDirValues,y
   sta sneakerHorizDelta,y
   dey
   bpl .initHorizPositionsAndDirections
   iny                              ; y = 0
   jsr DetermineLadderPlacement
NewFrame
   ldx #VSYNC_TIME
   sta WSYNC                        ; wait for next scanline
   stx VBLANK                       ; disable TIA (i.e. D1 = 1)
   stx VSYNC                        ; start VSYNC (i.e. D1 = 1)
   stx TIM8T                        ; set timer for VSYNC period
   lda playerScore                  ; get player score value
   and #$0F                         ; keep lower nybbles (i.e. tens value)
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta tmpScoreIndexValues
   lda playerScore                  ; get player score value
   and #$F0                         ; keep upper nybbles (i.e. hundreds value)
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpScoreIndexValues + 1
   lda playerScore + 1              ; get player score value
   and #$0F                         ; keep lower nybbles (i.e. thousands value)
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta tmpScoreIndexValues + 2
   lda playerScore + 1              ; get player score value
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpScoreIndexValues + 3
   lda platformColor                ; get current platform color value
   clc
   adc #98                          ; increment by 98
   sta remainingLivesColor          ; set remaining lives color
   ldx #VBLANK_TIME
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scanline
   sta VSYNC                        ; end VSYNC (i.e. D1 = 0)
   stx TIM64T                       ; set timer for VBLANK period
   lda gameState                    ; get current game state
   bpl .skipGamePaused              ; branch if game not in progress
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   cmp startBWValue                 ; compare with value at startup
   beq .skipGamePaused              ; branch if game not paused
   ldx #0
   stx AUDV1                        ; turn off channel 1 sound
   stx AUDV0                        ; turn off channel 0 sound
   ldx #$FF
   txs                              ; set stack to the beginning
   jsr IncrementPlatformColor
   bne .jmpToDisplayKernel          ; unconditional branch
   
.skipGamePaused
   dec ladderJustificationValue     ; decremented each frame
   inc frameCount                   ; incremented each frame
   bne IncrementScoreForScreenDone  ; branch to skip initiating Sneaker move
   lda _05PlatformSneakerHorizDelta ; get bottom platform Sneaker direction
   bne IncrementScoreForScreenDone  ; branch if bottom platform Sneaker moving
   inc _05PlatformSneakerHorizDelta ; increment to move Sneaker right
IncrementScoreForScreenDone
   lda screenDoneAwardTimer         ; get award timer for completing screen
   bpl .incrementScoreForScreenDone
   jmp CheckForGameRestart
       
.incrementScoreForScreenDone
   and #3                           ; get mod4 value of screen done timer
   cmp #3
   bne .doneIncrementScoreForScreenDone; increment every 4th frame
   sed
   ldy currentScreen                ; get current screen number
   dey                              ; decrememnt value (i.e. 0 <= y <= 10)
   tya                              ; shift value to accumulator
   ora #1                           ; set D0 to increment score tens value
   clc
   adc playerScore                  ; increment score tens value
   sta playerScore
   lda playerScore + 1              ; get score thousands value
   adc #1 - 1
   sta playerScore + 1              ; increment thousands when a roll over
   cld
   inc moveMiddlePlatformSneakers
.doneIncrementScoreForScreenDone
   dec screenDoneAwardTimer         ; reduce award timer value
   ldx #0
   stx AUDV1
   dex                              ; x = #$FF
   txs                              ; set stack to the beginning
   jsr IncrementPlatformColor
   lda #13
   sta AUDC0                        ; set audio channel for award sound
   lda screenDoneAwardTimer         ; get award timer for completing screen
   sta AUDF0
   sta AUDV0
   bmi AdvancePlayerToNextScreen
.jmpToDisplayKernel
   jmp DisplayKernel

AdvancePlayerToNextScreen
   lda HighTopColorLSBValues + 1
   sta highTopColorPtrs             ; set High-Top color pointer MSB value
   lda HighTopGraphicLSBValues_01
   sta highTopGraphicPtrs           ; init High-Top graphic pointer LSB value
   sta actionButtonDebounce         ; set D7 high for action button not pressed
   lda #<FastEddieWalkingColors
   sta fastEddieColorPtrs           ; set Fat Eddie color pointer LSB value
   lda #INIT_HORIZ_POS_FAST_EDDIE
   sta fastEddieHorizPos            ; init Fast Eddie horizontal position
   ldy #0
   ldx #$FF
   txs                              ; set stack to the beginning
   jsr DetermineLadderPlacement
   ldy #0
   sty frameCount                   ; reset frame counter
   sty _05PlatformSneakerHorizDelta ; set bottom Sneaker not to move
   sty AUDV0                        ; turn off sounds by reducing volume
   sty AUDV1
   sty prizeControlValue
   sty prizeArray + 1               ; set Blank prize for 2nd platform
   sty prizeArray + 3               ; set Blank prize for 4th platform
   sty frameCollisionCount          ; clear frame collision count
   sty fastEddieDeathSequence       ; clear Fast Eddie death sequence value
   iny                              ; y = 1
   sty prizesCollected              ; initialize number of prizes collected
   sty floatingPrizePointValue      ; point to the first prize point value
   sty collectedPrizeSoundValue
   sty fastEddieKernelSection       ; initialize Fast Eddie platform
   inc numberOfLives                ; increment number of lives
   ldy numberOfLives                ; get number of lives
   cpy #MAX_LIVES + 1
   bcc .incrementGameScreen
   dey                              ; reduce value for lives maximum
   sty numberOfLives                ; set number of lives to maximum value
.incrementGameScreen
   inc currentScreen                ; increment screen value
   ldy currentScreen                ; get current screen number
   cpy #(MAX_GAME_SCREEN / 2) + 1
   beq .incrementGameLevel
   cpy #MAX_GAME_SCREEN + 1
   bcc .initPrizeArrayForNewScreen
.incrementGameLevel
   inc gameSelection                ; increment game level
   lda gameSelection                ; get current game level
   cmp #MAX_GAME_LEVEL
   bcc .determineReachingMaxGameScreen
   lda #3
   sta gameSelection                ; set game level to level 3
.determineReachingMaxGameScreen
   cpy #(MAX_GAME_SCREEN / 2) + 1
   beq .setGameScreen
   ldy #1                           ; re-init game screen when reached max
.setGameScreen
   sty currentScreen
.initPrizeArrayForNewScreen
   sty prizeArray + 2               ; set prize for 3rd platform
   sty prizeArray                   ; set prize for 1st platform
   lda #INIT_HORIZ_POS_SNEAKER_05 + 4
   sta _05PlatformSneakerHorizPos   ; init bottom Sneaker horizontal position
CheckForGameRestart
   lda INPT4                        ; read left port action button
   bmi .checkForResetSwitchPressed  ; branch if button not pressed
   lda gameOverSoundFrequency       ; get game over sound frequence value
   bne .checkForResetSwitchPressed  ; branch if playing game over sounds
   lda gameState                    ; get current game state
   bpl .startNewGame                ; branch if game not in progress
.checkForResetSwitchPressed
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForResetSwitchReleased ; branch if RESET not pressed
.startNewGame
   ldy #<-1
   sty resetDebounce                ; set D7 high to show RESET held
   sty gameState                    ; set game state to game in progress
   iny                              ; y = 0
   sty AUDV1                        ; turn off sounds by reducing volume
   sty AUDV0
   sty playerScore                  ; reset player score to 0
   sty playerScore + 1
   sty fastEddieOnLadderValue       ; clear to show Fast Eddie not on a ladder
   sty frameCount                   ; reset frame counter
   sty _05PlatformSneakerHorizDelta ; init bottom Sneaker movement value
   sty prizeControlValue
   sty prizeArray                   ; set Blank prize for 1st platform
   sty prizeArray + 2               ; set Blank prize for 3rd platform
   sty gameOverSoundFrequency       ; clear game over sound frequency value
   sty middleSneakerMoveDelay
   sty moveMiddlePlatformSneakers   ; clear so Sneakers don't move on first level
   iny                              ; y = 1
   sty prizesCollected              ; initialize number of prizes collected
   sty floatingPrizePointValue      ; point to the first prize point value
   sty currentScreen
   sty prizeArray + 1               ; set prize for 2nd platform
   sty prizeArray + 3               ; set prize for 4th platform
   sty fastEddieKernelSection       ; initialize Fast Eddie platform
   lda #MAX_LIVES
   sta numberOfLives                ; initialize number of lives
   lda HighTopColorLSBValues + 1
   sta highTopColorPtrs             ; set High-Top colors pointer LSB value
   lda HighTopGraphicLSBValues_01 + 1
   sta highTopGraphicPtrs           ; set High-Top graphic pointer LSB value
   sta actionButtonDebounce         ; set D7 high for action button held
   sta screenDoneAwardTimer
   lda #RED + 7
   sta platformColor                ; initialize platform color
   lda #<FastEddieStationary
   sta fastEddieGraphicPtrs         ; set Fast Eddie for stationary graphics
   lda #>FastEddieStationary
   sta fastEddieGraphicPtrs + 1
   lda #<FastEddieWalkingColors
   sta fastEddieColorPtrs
   lda #INIT_HORIZ_POS_SNEAKER_05 + 4
   sta _05PlatformSneakerHorizPos   ; init bottom Sneaker horizontal position
   lda #INIT_HORIZ_POS_FAST_EDDIE
   sta fastEddieHorizPos            ; set Fast Eddie init horizontal position
   sta highTopHorizPosition         ; set High-Top init horizontal position
   bpl .doneCheckForGameRestart     ; unconditional branch
       
.checkForResetSwitchReleased
   lda resetDebounce                ; get RESET debounce value
   bpl CheckGameSelectSwitch        ; branch if RESET switch not held
   sta gameState                    ; set to game in progress (i.e. D7 = 1)
   ldy #0
   sty resetDebounce                ; clear debounce to show RESET not held
   ldx #$FF
   txs                              ; set stack to the beginning
   jsr DetermineLadderPlacement
.doneCheckForGameRestart
   jmp DisplayKernel

CheckGameSelectSwitch
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   lsr                              ; shift SELECT to carry
   bcc .selectSwitchPressed         ; branch if SELECT pressed
   sta selectDebounce               ; clear D7 value to show SELECT not pressed
   lda gameState                    ; get current game state
   bpl .setGameSelectionGraphicPtrs ; branch if game not in progress
   bmi .checkToPlayGameSounds       ; unconditional branch
       
.selectSwitchPressed
   lda selectDebounce               ; get SELECT debounce value
   bpl .incrementGameSelection      ; branch if SELECT released
   lda gameState                    ; get current game state
   clc
   adc #3
   sta gameState
   bpl .setGameSelectionGraphicPtrs ; branch if game not in progress
.incrementGameSelection
   ldy #<-1
   sty selectDebounce               ; set debounce to show SELECT held
   iny                              ; y = 0
   sty gameState
   inc gameSelection                ; increment game selection
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_LEVEL
   bcc .setGameSelectionGraphicPtrs
   lda #0
   sta gameSelection
.setGameSelectionGraphicPtrs
   ldy gameSelection                ; get current game selection
   lda GameSelectionGraphicLSBValues,y
   sta gameSelectionGraphicPtrs
   lda #>NumberFonts
   sta gameSelectionGraphicPtrs + 1
   inc gameState
   bpl .checkToPlayGameSounds
   ldx #0
   stx gameState
   dex                              ; x = #$FF
   txs                              ; set stack to the beginning
   jsr IncrementPlatformColor
.checkToPlayGameSounds
   jmp CheckToPlayGameSounds

PlayFastEddieDeathSounds
   inc tmpFastEddieDeathSoundDelay  ; increment Fast Eddie death sound delay
   lda tmpFastEddieDeathSoundDelay  ; get Fast Eddie death sould delay value
   lsr                              ; shift D0 to carry
   bcs .donePlayFastEddieDeathSounds; skip sound values on even frames
   lda #<FastEddieStationary
   sta fastEddieGraphicPtrs
   lda #>FastEddieStationary
   sta fastEddieGraphicPtrs + 1
   inc fastEddieSinkingOffset       ; increment Fast Eddie sinking offset
   lda #0
   sta AUDV1
   lda #15
   sta AUDV0
   lda #4
   sta AUDC0
   lda fastEddieSinkingOffset       ; get Fast Eddie sinking offset
   sta AUDF0                        ; set death sound audio frequency
   inc platformColor                ; increment platform color for death
   cmp #17
   bcs .doneFastEddieDeathSequence  ; branch when sinking offset done
.donePlayFastEddieDeathSounds
   jmp DisplayKernel

.doneFastEddieDeathSequence
   ldy #<-1
   sty actionButtonDebounce         ; set debounce to show held this frame
   iny                              ; y = 0
   sty fastEddieDeathSequence       ; clear Fast Eddie death sequence value
   sty fastEddieSinkingOffset       ; clear Fast Eddie sinking offset
   sty AUDV0                        ; turn off sounds by reducing volume
   sty AUDV1
   sty fastEddieOnLadderValue       ; clear to show Fast Eddie not on a ladder
   sty _05PlatformSneakerHorizDelta
   sty frameCollisionCount          ; clear frame collision count
   sty frameCount
   sty moveMiddlePlatformSneakers   ; clear so Sneakers don't move on first level
   sty middleSneakerMoveDelay
   iny                              ; y = 1
   sty prizeSpawningPlatform        ; set platform for next spawning prize
   sty fastEddieKernelSection       ; initialize Fast Eddie platform
   lda #<FastEddieGraphic_00
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_00
   sta fastEddieGraphicPtrs + 1
   lda #<FastEddieWalkingColors
   sta fastEddieColorPtrs
   lda currentPlatformColor         ; get current platform color
   sta platformColor                ; set platform color for kernel
   lda #INIT_HORIZ_POS_FAST_EDDIE
   sta fastEddieHorizPos            ; set Fast Eddie init horizontal position
   lda #INIT_HORIZ_POS_SNEAKER_05 + 4
   sta _05PlatformSneakerHorizPos
CheckToPlayGameSounds
   lda ladderSoundValue             ; get ladder sound value
   beq CheckToPlayGameOverSounds    ; branch if not playing ladder sounds
   sta AUDV1                        ; set sound volume for ladder movement
   sta AUDC1                        ; set audio channel value for ladder movment
   ldy #0
   sty AUDF1
   dec ladderSoundValue
   dec ladderSoundValue
   bne CheckToPlayGameOverSounds
   sty AUDV1                        ; turn off sound if done ladder movement
CheckToPlayGameOverSounds
   lda gameOverSoundFrequency       ; get game over sound frequency value
   beq .doneCheckToPlayGameOverSounds;branch if not playing game over sounds
   sta AUDF1                        ; set frequency for game over sounds
   lda gameOverSoundValues          ; get game over sound values
   eor #$0F
   sta AUDV1                        ; set volume for game over sounds
   lsr                              ; divide volume by 2
   sta AUDC1                        ; set audio channel for game over sounds
   dec gameOverSoundValues          ; decrement game over sounds
   bpl .doneCheckToPlayGameOverSounds
   lda #5
   sta gameOverSoundValues
   dec gameOverSoundFrequency       ; decrement game over sound frequency value
   bne .doneCheckToPlayGameOverSounds
   lda #0                           ; done with game over sequence
   sta AUDV1                        ; turn off volume
   sta AUDV0
   sta gameSelection                ; reset game level
.doneCheckToPlayGameOverSounds
   lda actionButtonDebounce         ; get action button debounce value
   bmi .checkToPlayFastEddieDeathSounds; branch if held this frame
   lda ladderSoundValue             ; get ladder sound value
   bne .checkToPlayFastEddieDeathSounds; branch if playing ladder sounds
   lda gameState                    ; get current game state
   bpl .checkToPlayFastEddieDeathSounds; branch if game not in progress
   lda fastEddieAnimationIndex      ; get Fast Eddie animation index
   cmp #5
   bcc .donePlayingJumpingSound     ; branch if Fast Eddie not starting jump
   clc
   adc prizeMovementDelayValue
   sta AUDF1                        ; set frequency for jumping sound
   lda prizeMovementDelayValue
   eor #7                           ; get 3-bit 1's complement
   ora #8
   sta AUDV1                        ; set volume for jumping sound
   lda #13
   sta AUDC1
   bne .checkToPlayFastEddieDeathSounds; unconditional branch
       
.donePlayingJumpingSound
   lda #0
   sta AUDV1
.checkToPlayFastEddieDeathSounds
   lda fastEddieDeathSequence       ; get Fast Eddie death sequence value
   bpl .checkToStartFastEddieDeathSequence; branch if not in death sequence
   jmp PlayFastEddieDeathSounds
       
.checkToStartFastEddieDeathSequence
   lda frameCollisionCount          ; get frame collision count
   cmp #MAX_FRAME_COLLISION_VALUE
   bne CheckToSpawnNewPrize
   ldy #<-1
   sty fastEddieDeathSequence       ; set to show Fast Eddie in death sequence
   lda platformColor                ; get kernel platform color value
   sta currentPlatformColor         ; save while color cycling for death
   dec numberOfLives                ; decrement number of lives
   bpl CheckToSpawnNewPrize         ; branch if lives remaining
   lda #MAX_LIVES
   sta numberOfLives                ; reset number of lives
   sta gameState                    ; set to game not in progress
   lda #RED_ORANGE + 7
   sta currentPlatformColor         ; reset platform color when game over
   lda #30
   sta gameOverSoundFrequency       ; set game over sound frequency
   lda #10
   sta gameOverSoundValues          ; set sound values for game over
   iny                              ; y = 0
   sty ladderSoundValue             ; clear ladder sound value
CheckToSpawnNewPrize
   lda prizeControlValue
   bne .checkToSpawnNewPrize
   jmp PlaySoundForCollectedPrize
       
.checkToSpawnNewPrize
   bpl .checkToPlaySoundForCollectedPrize
   lda allowedToSpawnPrize          ; determine if allowed to spawn prize
   beq .determinePrizeFloatingPointValue; branch if new prize not allowed
   ldy tmpFastEddiePrizeKernelSection;get section Fast Eddie collected prize
   lda currentScreen                ; get current screen number
   cmp #MAX_PRIZES + 1
   bcc .setPrizeArrayValue
   lda #MAX_PRIZES
.setPrizeArrayValue
   sta prizeArray - 1,y             ; set prize for Fast Eddie platform
   lda #0
   sta allowedToSpawnPrize          ; set to not allow spawning prize
.determinePrizeFloatingPointValue
   lda floatingPrizePointValue      ; get floating point value number
   clc
   adc #MAX_PRIZES                  ; increment by maximum prizes
   cmp #19                          ; make sure it doesn't go past "90"
   bcc .setPrizeFloatingPointArrayValue
   lda #19                          ; set to maximum prize point value of "90"
.setPrizeFloatingPointArrayValue
   ldy fastEddieKernelSection       ; get Fast Eddie kernel section
   sta prizeArray - 1,y             ; set to show float point value
   lda floatingPrizePointValue
   sta tmpPrizePoints
   cmp #10
   bcc .incrementScoreForPrizePoints
   lda #9
   sta tmpPrizePoints
.incrementScoreForPrizePoints
   sed
   lda playerScore                  ; get score tens value
   clc
   adc tmpPrizePoints               ; increment by the prize point value
   sta playerScore
   lda playerScore + 1              ; get score hundreds value
   adc #1 - 1                       ; increment if there is an overflow
   sta playerScore + 1
   cld
   sty tmpFastEddiePrizeKernelSection;set section for collecting prize
   inc floatingPrizePointValue      ; increment floating point value
   lda #105
   sta collectedPrizeSoundValue
   sta prizeControlValue
   ldx prizesCollected              ; get number of prizes collected
   cpx #MAX_COLLECTED_PRIZES
   bcs .checkToPlaySoundForCollectedPrize; branch if collected maximum prizes
   inx                              ; increment number of prizes collected
   stx prizesCollected              ; set number of prizes collected
   lda HighTopColorLSBValues,x
   sta highTopColorPtrs
.checkToPlaySoundForCollectedPrize
   dec collectedPrizeSoundValue     ; decrement collected prize sound value
   bne PlaySoundForCollectedPrize   ; branch if still playing sound
   ldx #0
   ldy tmpFastEddiePrizeKernelSection;get section Fast Eddie collected prize
   stx prizeArray - 1,y             ; set prize to Blank sprite
   inx                              ; x = 1
   stx collectedPrizeSoundValue
   ldy prizeSpawningPlatform        ; get platform for spawning prize
   dey
   beq PlaySoundForCollectedPrize
   lda prizeArray - 1,y             ; get prize index value
   bne PlaySoundForCollectedPrize   ; branch if not a Blank sprite
   cpy fastEddieKernelSection
   beq PlaySoundForCollectedPrize   ; branch if pointing to Fast Eddie platform
   dex                              ; x = 0
   stx collectedPrizeSoundValue
   stx AUDV0
   stx prizeControlValue
   lda prizesCollected              ; get number of prizes collected
   cmp #MAX_COLLECTED_PRIZES
   bcs .donePlaySoundForCollectedPrize; branch if collected maximum prizes
   lda currentScreen                ; get current screen number
   cmp #MAX_PRIZES + 1
   bcc .setNewPrizeItem             ; branch if not reached maximum prizes
   lda #MAX_PRIZES
.setNewPrizeItem
   sta prizeArray - 1,y
   ldx NewPrizeIndexItemValues,y    ; get index to spawn new prize value
   lda highTopHorizPosition         ; get Hip-Top's horizontal position
   clc
   adc #30                          ; new prize horizontal location offset
   cmp #XMAX + 1
   bcc .setHorizPositionForNewPrize
   lda #XMAX + 1
.setHorizPositionForNewPrize
   sta objectHorizPositions,x
PlaySoundForCollectedPrize
   lda collectedPrizeSoundValue     ; get collected prize sould value
   beq .donePlaySoundForCollectedPrize
   sec
   sbc #65
   bcs .playSoundForCollectedPrize
   lda #0
   sta AUDV0
   beq .donePlaySoundForCollectedPrize; unconditional branch
       
.playSoundForCollectedPrize
   lsr
   lsr
   sta AUDF0                        ; set audio frequency for collected prize
   eor #8
   sta AUDV0
   lda #13
   sta AUDC0
.donePlaySoundForCollectedPrize
   lda fastEddieOnLadderValue       ; get Fast Eddie ladder value
   beq .checkFastEddieForJumping    ; branch if Fast Eddie not on a ladder
   dec fastEddieLadderDelay         ; decrement ladder delay value
   beq MoveFastEddieOnLadder        ; branch when reached 0
   jmp MoveSneakersHorizontally
       
.checkFastEddieForJumping
   jmp CheckFastEddieForJumping

MoveFastEddieOnLadder
   lda #LADDER_DELAY_VALUE
   sta fastEddieLadderDelay         ; set ladder delay value
   lda fastEddieLadderDir           ; get ladder direction
   beq .fastEddieMovingDownLadder   ; branch if moving down ladder
   ldy fastEddieAnimationIndex      ; get Fast Eddie animation index
   lda FastEddieVertAnimationValues,y
   sta fastEddieGraphicPtrs
   lda #>FastEddieVertical
   sta fastEddieGraphicPtrs + 1
   lda FastEddieVerticalColorLSBValues,y
   sta fastEddieColorPtrs
   lda FastEddieVerticalReflectValues,y
   sta REFP1
   sta fastEddieHorizDir
   iny                              ; increment Fast Eddie animation index
   sty fastEddieAnimationIndex      ; set new animation index value
   cpy #3
   bcc .doneMoveFastEddieOnLadder   ; branch if not reached maximum animation
   inc fastEddieKernelSection       ; move Fast Eddie up one level
   lda #0
   sta fastEddieOnLadderValue       ; clear to show Fast Eddie not on a ladder
   lda #<FastEddieWalkingColors     ; set Fast Eddie walking on platform colors
   sta fastEddieColorPtrs
   lda #<FastEddieGraphic_00        ; set Fast Eddie graphics for stationary
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_00
   sta fastEddieGraphicPtrs + 1
.doneMoveFastEddieOnLadder
   jmp MoveSneakersHorizontally

.fastEddieMovingDownLadder
   ldy fastEddieAnimationIndex      ; get Fast Eddie animation index
   cpy #1
   bne .moveFastEddieDownLadder     ; branch if not reached minimum animation
   dec fastEddieKernelSection       ; move Fast Eddie down one level
.moveFastEddieDownLadder
   lda FastEddieVertAnimationValues,y
   sta fastEddieGraphicPtrs
   lda #>FastEddieVertical
   sta fastEddieGraphicPtrs + 1
   lda FastEddieVerticalColorLSBValues,y
   sta fastEddieColorPtrs
   lda FastEddieVerticalReflectValues,y
   sta REFP1
   sta fastEddieHorizDir
   dec fastEddieAnimationIndex      ; decrement Fast Eddie animation index
   lda fastEddieAnimationIndex      ; get Fast Eddie animation index
   cmp #<-2
   bne .doneMoveFastEddieOnLadder
   lda #0
   sta fastEddieOnLadderValue       ; clear to show Fast Eddie not on a ladder
   lda #<FastEddieGraphic_00        ; set Fast Eddie graphics for stationary
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_00
   sta fastEddieGraphicPtrs + 1
   sta actionButtonDebounce
   lda #<FastEddieWalkingColors     ; set Fast Eddie walking on platform colors
   sta fastEddieColorPtrs
   bne .doneMoveFastEddieOnLadder   ; unconditional branch
       
CheckFastEddieForJumping
   lda actionButtonDebounce         ; get action button debounce value
   bpl .fastEddieJumping            ; branch if pressed this frame
   jmp CheckFastEddieForDemoModeJumping
       
.fastEddieJumping
   lda fastEddieHorizPos            ; get Fast Eddie's horizontal position
   clc
   adc tmpFastEddieHorizDelta
   sta fastEddieHorizPos            ; set Fast Eddie new horizontal position
   cmp #XMIN
   bcs .checkFastEddieRightRestrictions
   lda #XMIN                        ; get horizontal minimum value
   sta fastEddieHorizPos            ; set Fast Eddie to left border
   bne .checkToUpdateJumpingAnimation; unconditional branch
       
.checkFastEddieRightRestrictions
   cmp #XMAX
   bcc .checkToUpdateJumpingAnimation; branch if Fast Eddie not at right border
   lda #XMAX
   sta fastEddieHorizPos            ; set Fast Eddie to right border
.checkToUpdateJumpingAnimation
   dec fastEddieJumpingDelayValue   ; decrement jumping delay value
   bne .doneCheckFastEddieForJumping
   lda #6
   sta fastEddieJumpingDelayValue   ; reset jumping delay value
   dec fastEddieAnimationIndex      ; decrement Fast Eddie animation index
   bmi .fastEddieDoneJumping
   ldy fastEddieAnimationIndex
   lda FastEddieJumpingGraphicLSBValues,y
   sta fastEddieGraphicPtrs
   lda FastEddieJumpingColorLSBValues,y
   sta fastEddieColorPtrs
   lda #>FastEddieJumpingGraphic
   sta fastEddieGraphicPtrs + 1
   bmi .doneCheckFastEddieForJumping; unconditional branch
       
.fastEddieDoneJumping
   lda #<FastEddieGraphic_00        ; set Fast Eddie graphics for stationary
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_00
   sta fastEddieGraphicPtrs + 1
   sta actionButtonDebounce         ; set D7 high for action button not pressed
   lda #<FastEddieWalkingColors     ; set Fast Eddie walking on platform colors
   sta fastEddieColorPtrs
.doneCheckFastEddieForJumping
   jmp MoveSneakersHorizontally

CheckFastEddieForDemoModeJumping
   lda gameState                    ; get current game state
   bmi CheckIfFireButtonPressedForJumping;branch if game in progress
   lda _05PlatformSneakerHorizPos   ; get bottom Sneaker horiz position
   ldy _05PlatformSneakerHorizDelta ; get bottom Sneaker direction
   bmi .checkSneakerApproachingEddieRight; branch if bottom Sneaker traveling left
   cmp #INIT_HORIZ_POS_FAST_EDDIE - 24
   beq .setActionButtonStateForJumping; branch if in range for Fast Eddie to jump
.setFastEddieStationaryForDemoMode
   jmp SetFastEddieStationaryForDemoMode

.checkSneakerApproachingEddieRight
   cmp #INIT_HORIZ_POS_FAST_EDDIE + 16
   beq .setActionButtonStateForJumping; branch if in range for Fast Eddie to jump
   bne .setFastEddieStationaryForDemoMode; unconditional branch
       
CheckIfFireButtonPressedForJumping
   lda INPT4                        ; read left port action button
   bmi CheckToReadPlayerJoystickValues;branch if button not pressed
.setActionButtonStateForJumping
   sta actionButtonDebounce
   lda #6
   sta fastEddieAnimationIndex
   sta fastEddieJumpingDelayValue
CheckToReadPlayerJoystickValues
   lda gameState                    ; get current game state
   bpl .setFastEddieStationaryForDemoMode; branch if game not in progress
   lda SWCHA                        ; read the player joystick values
   cmp #$FF
   beq .setFastEddieStationaryForDemoMode; branch if joystick not moved
   lsr                              ; shift player 1 values to lower nybbles
   lsr
   lsr
   lsr
   tay                              ; move joystick values to y register
   and #<(~MOVE_RIGHT) >> 4         ; keep MOVE_RIGHT value
   bne .checkForJoystickMovingLeft  ; branch if joystick not moved right
   ldx #NO_REFLECT
   stx REFP1
   stx fastEddieHorizDir            ; set Fast Eddie direction not to reflect
   inx                              ; x = 1
   stx tmpFastEddieHorizDelta
   inc fastEddieHorizPos            ; increment Fast Eddie horizontal position
   lda fastEddieHorizPos            ; get Fast Eddie horizontal position
   cmp #XMAX
   bcc .doneJoystickHorizontalChecks; branch if Fast Eddie within frame
   lda #XMAX
   sta fastEddieHorizPos            ; set Fast Eddie position to right border
.doneJoystickHorizontalChecks
   jmp DetermineEddieFootAnimation

.checkForJoystickMovingLeft
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_LEFT) >> 4          ; keep MOVE_LEFT value
   bne .checkForJoystickMovingUp    ; branch if joystick not moved left
   lda #REFLECT
   sta REFP1
   sta fastEddieHorizDir            ; set Fast Eddie direction to reflect
   dec fastEddieHorizPos            ; decrement Fast Eddie horizontal position
   lda #<-1
   sta tmpFastEddieHorizDelta
   lda fastEddieHorizPos            ; get Fast Eddie horizontal position
   cmp #XMIN
   bcs .doneJoystickHorizontalChecks; branch if Fast Eddie within frame
   lda #XMIN
   sta fastEddieHorizPos            ; set Fast Eddie position to left border
   bpl .doneJoystickHorizontalChecks; unconditional branch
   
.checkForJoystickMovingUp
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_UP) >> 4            ; keep MOVE_UP value
   bne .checkForJoystickMovingDown  ; branch if joystick not moved up
   ldy fastEddieKernelSection       ; get Fast Eddie kernel section
   lda fastEddieHorizLadderValues,y ; get ladder position value
   tax                              ; move position value to x for later
   tay                              ; move position value to y register
   dey
   dey
   tya
   cmp fastEddieHorizPos
   bcs .checkMovingUpRightSideLadders
   clc                              ; carry already clear
   adc #12                          ; increment value for ladder pixel range
   cmp fastEddieHorizPos
   bcs .setFastEddieMovingUpLadder  ; branch if Fast Eddie to the left of range
.checkMovingUpRightSideLadders
   txa                              ; move position value to accumulator
   clc
   adc #80                          ; increment for right side pixel range
   tay
   dey
   dey
   tya
   cmp fastEddieHorizPos
   bcs .doneJoystickHorizontalChecks; branch if Eddie out of ladder range
   clc                              ; carry already clear
   adc #12                          ; increment value for ladder pixel range
   cmp fastEddieHorizPos
   bcc DetermineEddieFootAnimation  ; branch if Eddie out of ladder range
.setFastEddieMovingUpLadder
   lda fastEddieKernelSection       ; get Fast Eddie kernel section
   cmp #MAX_KERNEL_SECTION
   bcs DetermineEddieFootAnimation  ; branch if Fast Eddie on top platform
   iny                              ; increment value to place Eddie
   iny                              ; in ladder center
   iny
   iny
   iny
   iny
   sty fastEddieHorizPos            ; set Fast Eddie horizontal position
   sty fastEddieLadderDir           ; set to non-zero value for traveling up
   sta fastEddieOnLadderValue       ; set to show Fast Eddie on a ladder
   lda #0
   sta fastEddieAnimationIndex
   lda #64
   sta ladderSoundValue
   bpl .doneJoystickVerticalChecks  ; unconditional branch
   
.checkForJoystickMovingDown
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_DOWN) >> 4          ; keep MOVE_DOWN value
   bne DetermineEddieFootAnimation  ; branch if joystick not moved down
   ldy fastEddieKernelSection       ; get Fast Eddie kernel section
   dey
   lda fastEddieHorizLadderValues,y ; get ladder position value
   tay                              ; move position value to y register
   tax                              ; move position value to x for later
   dey
   dey
   tya
   cmp fastEddieHorizPos
   bcs .checkMovingDownRightSideLadders
   clc                              ; carry already clear
   adc #12                          ; increment value for ladder pixel range
   cmp fastEddieHorizPos
   bcc .checkMovingDownRightSideLadders
   lda fastEddieKernelSection
   cmp #MIN_KERNEL_SECTION
   bne .setFastEddieMovingDownLadder
.doneJoystickVerticalChecks
   jmp MoveSneakersHorizontally

.checkMovingDownRightSideLadders
   txa                              ; move position value to accumulator
   clc
   adc #80                          ; increment for right side pixel range
   tay
   dey
   dey
   tya
   cmp fastEddieHorizPos
   bcs DetermineEddieFootAnimation  ; branch if Eddie out of ladder range
   clc                              ; carry already clear
   adc #12                          ; increment value for ladder pixel range
   cmp fastEddieHorizPos
   bcc DetermineEddieFootAnimation  ; branch if Eddie out of ladder range
   lda fastEddieKernelSection
   cmp #MIN_KERNEL_SECTION
   beq MoveSneakersHorizontally
.setFastEddieMovingDownLadder
   sta fastEddieOnLadderValue       ; set to show Fast Eddie on a ladder
   ldx #FAST_EDDIE_LADDER_DOWN_DIR
   stx fastEddieLadderDir           ; set to move down ladder
   inx                              ; x = 1
   stx fastEddieAnimationIndex
   iny                              ; increment value to place Eddie
   iny                              ; in ladder center
   iny
   iny
   iny
   iny
   sty fastEddieHorizPos            ; set Fast Eddie horizontal position
   lda #64
   sta ladderSoundValue
   bne MoveSneakersHorizontally     ; unconditional branch
       
DetermineEddieFootAnimation
   lda prizeMovementDelayValue
   cmp #1
   bne MoveSneakersHorizontally
   lda footAnimationIndex           ; get foot animation index value
   beq .setFastEddieFootAnimation
   lda #<FastEddieGraphic_00
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_00
   sta fastEddieGraphicPtrs + 1
   bmi MoveSneakersHorizontally     ; unconditional branch
       
.setFastEddieFootAnimation
   lda #<FastEddieGraphic_01
   sta fastEddieGraphicPtrs
   lda #>FastEddieGraphic_01
   sta fastEddieGraphicPtrs + 1
   bmi MoveSneakersHorizontally     ; unconditional branch
       
SetFastEddieStationaryForDemoMode
   lda #<FastEddieStationary
   sta fastEddieGraphicPtrs
   lda #>FastEddieStationary
   sta fastEddieGraphicPtrs + 1
   lda #0
   sta tmpFastEddieHorizDelta
MoveSneakersHorizontally
   ldy #MAX_KERNEL_SECTION - 1
.moveSneakersHorizontally
   lda objectHorizPositions,y       ; get Sneaker horizontal position
   clc
   adc sneakerHorizDelta,y          ; increment position by delta value
   sta objectHorizPositions,y       ; set Sneaker horizontal position
   cmp #XMIN + 1
   bcs .checkSneakerForReachingRightBoundary
   inc middleSneakerMoveDelay       ; increment move delay for middle Sneakers
   bne .moveSneakerRight
   inc moveMiddlePlatformSneakers   ; increment to move move Sneakers
.moveSneakerRight 
   lda #1
   sta sneakerHorizDelta,y
   bne .moveNextSneaker             ; unconditional branch
       
.checkSneakerForReachingRightBoundary
   ldx gameSelection                ; get current game selection
   lda SneakerNUSIZLSBValues,x
   sta tmpSneakerNUSIZPtr
   lda #>SneakerNUSIZValues
   sta tmpSneakerNUSIZPtr + 1
   lda (tmpSneakerNUSIZPtr),y
   tax
   lda objectHorizPositions,y       ; get Sneaker horizontal position
   cmp SneakerRightBoundaryValues,x
   bcc .moveNextSneaker
   lda #<-1
   sta sneakerHorizDelta,y          ; set to move Sneaker left one pixel
.moveNextSneaker
   dey
   bpl .moveSneakersHorizontally
   dec prizeMovementDelayValue
   bne DetermineSneakerHorizPositions
   inc _03PlatformPrizeHorizPos     ; move prize on platform 3 right
   lda _03PlatformPrizeHorizPos     ; get platform 3 prize horizontal position
   cmp #XMAX + 27
   bne .movePlatform_04Prize
   lda #XMIN + 8
   sta _03PlatformPrizeHorizPos     ; wrap prize to left side of screen
.movePlatform_04Prize
   dec _04PlatformPrizeHorizPos     ; move prize on platform 4 left
   lda _04PlatformPrizeHorizPos     ; get platform 4 prize horizontal position
   cmp #XMIN + 7
   bne .cyclePrizeColorValue
   lda #XMAX + 26
   sta _04PlatformPrizeHorizPos     ; wrap prize to right side of screen
.cyclePrizeColorValue
   lda prizeColor
   clc
   adc #16
   sta prizeColor
   lda #5
   sta prizeMovementDelayValue
   lda footAnimationIndex
   beq .setSneakerFootAnimation
   lda #<SneakerGraphic_00
   sta sneakerGraphicPtrs
   ldx prizesCollected              ; get number of prizes collected
   lda HighTopGraphicLSBValues_00,x
   sta highTopGraphicPtrs
   lda #<HighTopGraphics_00
   sta sneakerFeetGraphicPtrs
   dec footAnimationIndex
   beq DetermineSneakerHorizPositions
.setSneakerFootAnimation
   lda #<SneakerGraphic_01
   sta sneakerGraphicPtrs
   ldx prizesCollected              ; get number of prizes collected
   lda HighTopGraphicLSBValues_01,x
   sta highTopGraphicPtrs
   lda #<HighTopGraphics_01
   sta sneakerFeetGraphicPtrs
   inc footAnimationIndex
DetermineSneakerHorizPositions
   ldy #INIT_HORIZ_POS_SNEAKER_05 + 4
   lda gameSelection
   ora moveMiddlePlatformSneakers
   bne CalculateObjectHorizPosition
   lda #INIT_HORIZ_POS_HIGH_TOP + 2
   sta _04PlatformSneakerHorizPos
   sty _02PlatformSneakerHorizPos
CalculateObjectHorizPosition
.calculateObjectHorizPosition
   lda objectHorizPositions,y       ; get object horizontal position value
   ldx #1
.divideBy15
   cmp #15
   bcc .setObjectFineCoarsePositionValue
   sec
   sbc #15
   inx                              ; increment coarse movement value
   bne .divideBy15                  ; unconditional branch
   
.setObjectFineCoarsePositionValue
   stx objectFCHorizValues,y
   tax                              ; move division remainder to x register
   lda HorizontalFineMotionValues,x ; get horizontal fine motion value
   ora objectFCHorizValues,y
   sta objectFCHorizValues,y
   dey
   bpl .calculateObjectHorizPosition
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   sta REFP1                  ; 3 = @11
   sta alwaysZero             ; 3         value never used
   sta kernelPFLadderIndex    ; 3         reset kernel PF ladder index value
   sta HMP1                   ; 3 = @20
   sta CXCLR                  ; 3 = @23   clear all collisions
   ldx #H_KERNEL              ; 2
DrawTopKernelItems
   sta WSYNC
;--------------------------------------
   cpx #H_KERNEL - 1          ; 2
   beq .scoreAndFastEddieLiteralKernel;2³
   jmp DrawNumberLivesKernel  ; 3
       
.drawScoreKernel
   jmp DrawScoreKernel        ; 3

.scoreAndFastEddieLiteralKernel
   lda gameState              ; 3         get current game state
   bmi .drawScoreKernel       ; 2³        branch if game in progress
   lda platformColor          ; 3
   cmp #BLUE + 7              ; 2
   bcc .drawScoreKernel       ; 2³
   beq DrawFastEddieLiteralKernel;2³
   bcs .drawFastEddieLiteralKernel;3
       
DrawFastEddieLiteralKernel
   ldx #$FF                   ; 2 = @22
   txs                        ; 2         set stack to the beginning
   jsr IncrementPlatformColor ; 6
.drawFastEddieLiteralKernel
   sta HMCLR                  ; 3
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   ldx #4                     ; 2
   sta WSYNC
;--------------------------------------
.wait19Cycles
   dex                        ; 2
   bne .wait19Cycles          ; 2³
   SLEEP 2                    ; 2
   SLEEP_7                    ; 7
   SLEEP 2                    ; 2
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @35
   sta RESP0                  ; 3 = @38
   sta RESP1                  ; 3 = @41
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   lda #H_DIGITS - 1          ; 2
   sta tmpFastEddieFontLoop   ; 3
   sta VDELP0                 ; 3 = @19
   sta VDELP1                 ; 3 = @22
.drawFastEddieLiteral
   ldy tmpFastEddieFontLoop   ; 3
   lda FastEddieLiteral_05,y  ; 4
   sta.w tmpFastEddieLiteral_05;4
   sta WSYNC
;--------------------------------------
   lda FastEddieLiteral_04,y  ; 4
   tax                        ; 2
   lda FastEddieLiteral_00,y  ; 4
   SLEEP_3                    ; 3
   sta GRP0                   ; 3 = @16
   lda FastEddieLiteral_01,y  ; 4
   sta.w GRP1                 ; 4 = @24
   lda FastEddieLiteral_02,y  ; 4
   sta.w GRP0                 ; 4 = @32
   lda FastEddieLiteral_03,y  ; 4
   ldy.w tmpFastEddieLiteral_05;4
   sta GRP1                   ; 3 = @43
   stx GRP0                   ; 3 = @46
   sty GRP1                   ; 3 = @49
   sta GRP0                   ; 3 = @52
   dec tmpFastEddieFontLoop   ; 5
   bpl .drawFastEddieLiteral  ; 2³
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @64
   sta VDELP1                 ; 3 = @67
   jmp DoneScoreAndFastEddieLiteralKernel;3
       
DrawScoreKernel SUBROUTINE
   sta HMCLR                  ; 3
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   ldx #4                     ; 2
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3
   sta WSYNC
;--------------------------------------
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @05
   sta REFP1                  ; 3 = @08
   SLEEP_7                    ; 7
   SLEEP 2                    ; 2
.wait19Cycles
   dex                        ; 2
   bne .wait19Cycles          ; 2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #H_DIGITS - 1          ; 2
   sta digitGraphicPtrs       ; 3
   lda #>NumberFonts          ; 2
   sta digitGraphicPtrs + 1   ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3
   lda #TWO_COPIES            ; 2
   sta NUSIZ1                 ; 3
.drawScore
   ldy tmpScoreIndexValues    ; 3         get value for tens position
   lda (digitGraphicPtrs),y   ; 5         get tens value graphic data
   tax                        ; 2         move tens position graphic data to x
   ldy tmpScoreIndexValues + 3; 3         get value for ten thousands position
   sta WSYNC
;--------------------------------------
   lda (digitGraphicPtrs),y   ; 5         get ten thousands value graphic data
   ldy tmpScoreIndexValues + 2; 3         get value for thousands position
   sta GRP0                   ; 3 = @11
   lda (digitGraphicPtrs),y   ; 5         get thousands value graphic data
   sta GRP1                   ; 3 = @19
   ldy tmpScoreIndexValues + 1; 3         get value for hundreds position
   lda (digitGraphicPtrs),y   ; 5         get hundreds value graphic data
   sta tmpScoreHundredsGraphic; 3
   ldy #<zero                 ; 2
   lda (digitGraphicPtrs),y   ; 5         get ones value graphic data
   ldy tmpScoreHundredsGraphic; 3
   sty GRP0                   ; 3 = @43
   stx GRP1                   ; 3 = @46
   sta GRP0                   ; 3 = @49
   dec digitGraphicPtrs       ; 5
   bpl .drawScore             ; 2³
DoneScoreAndFastEddieLiteralKernel
   lda #ONE_COPY              ; 2
   sta NUSIZ1                 ; 3 = @61
   sta GRP0                   ; 3 = @64
   sta GRP1                   ; 3 = @67
   ldx #H_KERNEL - 9          ; 2
   lda #4                     ; 2
   sta tmpKernelSection       ; 3
   lda #8                     ; 2
;--------------------------------------
   sta tmpObjectIndex         ; 3
   jmp DrawTopKernelItems     ; 3
       
DrawNumberLivesKernel SUBROUTINE
   cpx #H_KERNEL - 10         ; 2 = @09
   bne .checkToDrawGameSelectionKernel;2³
   lda #0                     ; 2
   sta PF0                    ; 3 = @16
   sta PF1                    ; 3 = @19
   ldy numberOfLives          ; 3         get number of lives
   lda PF2LivesIndicatorValues,y;4
   sta WSYNC
;--------------------------------------
   sta PF2                    ; 3 = @03
   lda remainingLivesColor    ; 3
   sta COLUPF                 ; 3 = @09
   ldy #4                     ; 2
.wait24Cycles
   dey                        ; 2
   bpl .wait24Cycles          ; 2³
   ldy numberOfLives          ; 3         get number of lives
   lda PF0LivesIndicatorValues,y;4
   sta PF0                    ; 3 = @45
   lda #0                     ; 2
   sta PF1                    ; 3 = @50
   sta PF2                    ; 3 = @53
   sta PF0                    ; 3 = @56
   ldy numberOfLives          ; 3         get number of lives
   lda PF2LivesIndicatorValues,y;4
   sta WSYNC
;--------------------------------------
   SLEEP_3                    ; 3
   sta PF2                    ; 3 = @06
   lda remainingLivesColor    ; 3
   sta COLUPF                 ; 3 = @12
   ldy #3                     ; 2
.wait19Cycles
   dey                        ; 2
   bpl .wait19Cycles          ; 2³
   ldy numberOfLives          ; 3         get number of lives
   lda PF0LivesIndicatorValues,y;4
   sta PF0                    ; 3 = @43
   lda #0                     ; 2
   sta PF1                    ; 3 = @48
   sta PF2                    ; 3 = @51
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   dex                        ; 2
   sta COLUPF                 ; 3 = @07
.checkToDrawGameSelectionKernel
   cpx #H_KERNEL - 13         ; 2
   beq DrawGameSelectionKernel; 2³
   jmp .checkDisplayKernelDone; 3
       
DrawGameSelectionKernel
   txs                        ; 2 = @19   push scanline value to stack
   lda gameState              ; 3         get current game state
   bmi .continueDrawGameSelectionKernel;2³ branch if game in progress
   lda #HMOVE_R4 | 5          ; 2
   sta tmpGameSelectionFCValues;3
.continueDrawGameSelectionKernel
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3
   lda tmpGameSelectionFCValues;3
   sta HMP0                   ; 3
   and #$0F                   ; 2         mask to keep coarse position value
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda tmpGameSelectionFCValues;3         waste 3 cycles
   SLEEP_6                    ; 6
   SLEEP_7                    ; 7
.coarsePositionGameSelection
   dex                        ; 2
   bne .coarsePositionGameSelection;2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   lda fastEddieFCHorizValue  ; 3
   sta HMP1                   ; 3 = @06   set Fast Eddie fine motion value
   and #$0F                   ; 2         mask to keep coarse position value
   sta tmpFastEddieCoarseValue; 3
   sta WSYNC
;--------------------------------------
   ldx tmpFastEddieCoarseValue; 3         get Fast Eddie coarse position value
   SLEEP_3                    ; 3
   lda fastEddieFCHorizValue  ; 3         waste 3 cycles
   SLEEP_7                    ; 7
.coarsePositionFastEddie
   dex                        ; 2
   bne .coarsePositionFastEddie;2³
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda fastEddieHorizDir      ; 3         get Fast Eddie horiz direction value
   sta REFP1                  ; 3 = @09   set Fast Eddie reflect state
   sta WSYNC
;--------------------------------------
   lda #HMOVE_0               ; 2
   sta HMP1                   ; 3 = @05
   lda gameState              ; 3         get current game state
   bmi DrawTopKernelSection   ; 2³        branch if game in progress
   tsx                        ; 2         pull scanline value from stack
   ldy #H_DIGITS              ; 2
.drawGameSelection
   sta WSYNC
;--------------------------------------
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3 = @05
   lda (gameSelectionGraphicPtrs),y;5
   sta GRP0                   ; 3 = @13
   dex                        ; 2
   dey                        ; 2
   bpl .drawGameSelection     ; 2³
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @24
   ldy #20                    ; 2
.skip21Scanlines
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   dey                        ; 2
   bpl .skip21Scanlines       ; 2³
   jmp .doneDrawTopKernelSection;3
       
DrawTopKernelSection 
   lda fastEddieKernelSection ; 3         get Fast Eddie kernel section
   cmp #MAX_KERNEL_SECTION    ; 2         compare with top kernel section
   bne .setFastEddieToBlankGraphic;2³     branch if Fast Eddie not in section
   lda fastEddieGraphicPtrs   ; 3         get Fast Eddie graphic LSB value
   clc                        ; 2
   adc fastEddieSinkingOffset ; 3         increment by death sinking value
   sta fastEddieKernelGraphicPtrs;3       set Fast Eddie kernel graphic value
   lda fastEddieGraphicPtrs + 1;3
   sta fastEddieKernelGraphicPtrs + 1;3
   bmi .startDrawingToKernelSection;3     unconditional branch
       
.setFastEddieToBlankGraphic
   lda #<BlankGraphics        ; 2
   sta fastEddieKernelGraphicPtrs;3
   lda #>BlankGraphics        ; 2
   sta fastEddieKernelGraphicPtrs + 1;3
.startDrawingToKernelSection
   tsx                        ; 2         pull scanline value from stack
   ldy #H_KERNEL_SECTION      ; 2
.drawTopKernelSection
   lda (fastEddieKernelGraphicPtrs),y;5
   sta tmpFastEddieGraphic    ; 3
   lda (highTopGraphicPtrs),y ; 5
   sta tmpHighTopGraphic      ; 3
   lda (fastEddieColorPtrs),y ; 5
   sta WSYNC
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda tmpFastEddieGraphic    ; 3
   sta GRP1                   ; 3 = @09
   lda (highTopColorPtrs),y   ; 5
   sta COLUP0                 ; 3 = @17
   lda tmpHighTopGraphic      ; 3
   sta GRP0                   ; 3 = @23
   dex                        ; 2
   dey                        ; 2
   cpy #H_KERNEL_SECTION - 17 ; 2
   bne .checkToDrawHighTopSprite;2³
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda fastEddieDeathSequence ; 3         get Fast Eddie death sequence value
   bmi .donePlayerCollisionCheck;2³       branch if in death sequence
   lda CXPPMM                 ; 3         read player collision values
   bpl .donePlayerCollisionCheck;2³       branch if players didn't collide
   lda prizesCollected        ; 3         get number of prizes collected
   cmp #MAX_COLLECTED_PRIZES  ; 2
   bcc .donePlayerCollisionCheck;2³       branch if not collected maximum prizes
   lda screenDoneAwardTimer   ; 3         get award timer for completing screen
   bpl .donePlayerCollisionCheck;2³
   lda #INIT_AWARD_TIMER_VALUE; 2
   sta screenDoneAwardTimer   ; 3
.donePlayerCollisionCheck
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   dex                        ; 2
   dex                        ; 2
.checkToDrawHighTopSprite
   cpy #H_KERNEL_SECTION - 23 ; 2
   bne .drawTopKernelSection  ; 2³
.drawHighTopFeetKernel
   lda (fastEddieKernelGraphicPtrs),y;5
   sta tmpFastEddieGraphic    ; 3
   lda (sneakerFeetGraphicPtrs),y;5
   sta tmpHighTopGraphic      ; 3
   lda (fastEddieColorPtrs),y ; 5
   sta WSYNC
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda tmpFastEddieGraphic    ; 3
   sta GRP1                   ; 3 = @09
   lda HighTopColors,y        ; 4
   sta COLUP0                 ; 3 = @16
   lda tmpHighTopGraphic      ; 3
   sta GRP0                   ; 3 = @22
   dex                        ; 2
   dey                        ; 2
   bpl .drawHighTopFeetKernel ; 2³
   lda CXPPMM                 ; 3         read player collision values
   bpl .doneDrawTopKernelSection;2³       branch if players didn't collide
   lda fastEddieDeathSequence ; 3         get Fast Eddie death sequence value
   bmi .doneDrawTopKernelSection;2³       branch if in death sequence
   lda #MAX_FRAME_COLLISION_VALUE;2
   sta frameCollisionCount    ; 3
   sta ladderSoundValue       ; 3
.doneDrawTopKernelSection
   dex                        ; 2
   sta WSYNC
;--------------------------------------
   sty PF0                    ; 3 = @03
   iny                        ; 2
   sty GRP0                   ; 3 = @08
   sty GRP1                   ; 3 = @11
.checkDisplayKernelDone
   beq DrawPlatformKernel     ; 2³ + 1
   dex                        ; 2         decrement scanline
   beq .startNewFrame         ; 2³ + 1
   jmp DrawTopKernelItems     ; 3
       
.startNewFrame
   jmp NewFrame

DrawPlatformKernel SUBROUTINE
   lda platformColor          ; 3
   sta COLUPF                 ; 3 = @21
   lda #$FF                   ; 2
   sta PF1                    ; 3 = @26
   sta PF2                    ; 3 = @29
   sta WSYNC
;--------------------------------------
.doneDrawPlatformKernel 
   sta CXCLR                  ; 3         clear all collisions
   jmp SetupPrizeValuesForKernel;3
       
DrawLadderKernel
   ldy #H_KERNEL_SECTION      ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda prizeColor             ; 3
   sta COLUP0                 ; 3 = @17
   lda fastEddieKernelSection ; 3         get Fast Eddie kernel section
   cmp tmpKernelSection       ; 3         compare with current kernel section
   bne .setFastEddieToBlankGraphic;2³     branch if Fast Eddie not in section
   lda fastEddieGraphicPtrs   ; 3         get Fast Eddie graphic LSB value
   clc                        ; 2
   adc fastEddieSinkingOffset ; 3         increment by death sinking value
   sta fastEddieKernelGraphicPtrs;3       set Fast Eddie kernel graphic value
   lda fastEddieGraphicPtrs + 1;3
   sta fastEddieKernelGraphicPtrs + 1;3
   jmp .prepareToDrawLadderKernel;3
       
.setFastEddieToBlankGraphic
   lda #<BlankGraphics        ; 2
   sta fastEddieKernelGraphicPtrs;3
   lda #>BlankGraphics        ; 2
   sta fastEddieKernelGraphicPtrs + 1;3
.prepareToDrawLadderKernel
   SLEEP_6                    ; 6
   SLEEP_6                    ; 6
   lda #0                     ; 2
   sta PF0                    ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda ladderColor            ; 3
   sta COLUPF                 ; 3 = @09
   lda (kernelPF1LadderGraphicPtrs),y;5
   sta PF1                    ; 3 = @17
   lda (kernelPF2LadderGraphicPtrs),y;5
   sta PF2                    ; 3 = @25
   dey                        ; 2
.drawPrizeKernel
   sta WSYNC
;--------------------------------------
   lda (prizeGraphicPtrs),y   ; 5
   sta GRP0                   ; 3 = @08
   lda (fastEddieKernelGraphicPtrs),y;5
   sta GRP1                   ; 3 = @16
   lda (fastEddieColorPtrs),y ; 5
   sta COLUP1                 ; 3 = @24
   lda (kernelPF2LadderGraphicPtrs),y;5
   sta PF2                    ; 3 = @32
   lda (kernelPF1LadderGraphicPtrs),y;5
   sta PF1                    ; 3 = @40
   lda ladderColor            ; 3
   sta COLUPF                 ; 3 = @46
   SLEEP 2                    ; 2
   dex                        ; 2
   dey                        ; 2
   cpy #H_KERNEL_SECTION - 16 ; 2
   bne .drawPrizeKernel       ; 2³
   lda CXPPMM                 ; 3         read player collision values
   bpl .drawSneakersKernel    ; 2³        branch if players didn't collide
   ldy fastEddieKernelSection ; 3
   lda prizeArray - 1,y       ; 4         get prize index value
   beq DrawSneakersKernel     ; 2³        branch if prize is a Blank sprite
   cmp #MAX_PRIZES + 1        ; 2
   bcs DrawSneakersKernel     ; 2³        branch if floating point value
   lda prizeControlValue      ; 3
   beq .setPrizeControlValue  ; 2³
   sta allowedToSpawnPrize    ; 3
.setPrizeControlValue
   ldx #<-1                   ; 2
   stx prizeControlValue      ; 3
   ldy fastEddieKernelSection ; 3
   inx                        ; 2         x = 0
   stx prizeArray - 1,y       ; 4         set prize index to a Blank sprite
   sta CXCLR                  ; 3         clear all collisions
DrawSneakersKernel
   ldy #H_KERNEL_SECTION - 16 ; 2
.drawSneakersKernel
   txs                        ; 2         push scanline value to stack
   lda (kernelPF1LadderGraphicPtrs),y;5
   sta tmpPF1LadderGraphic    ; 3
   lda (fastEddieKernelGraphicPtrs),y;5
   tax                        ; 2
   lda SneakerColors,y        ; 4
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @03
   lda (fastEddieColorPtrs),y ; 5
   sta COLUP1                 ; 3 = @11
   stx GRP1                   ; 3 = @14
   lda (sneakerGraphicPtrs),y ; 5
   sta GRP0                   ; 3 = @22
   lda tmpPF1LadderGraphic    ; 3
   sta PF1                    ; 3 = @28
   lda (kernelPF2LadderGraphicPtrs),y;5
   sta PF2                    ; 3 = @36
   cpy #H_KERNEL_SECTION - 16 ; 2
   bne .continueDrawSneakerKernel;2³
   jmp SetupSneakerValuesForKernel;3
       
.continueDrawSneakerKernel 
   tsx                        ; 2         pull scanline value from stack
   dex                        ; 2
   dey                        ; 2
   bpl .drawSneakersKernel    ; 2³
   txs                        ; 2         push scanline value to stack
   ldx tmpKernelSection       ; 3
   dec tmpKernelSection       ; 5
   dec tmpObjectIndex         ; 5
   lda platformColor          ; 3
   SLEEP 2                    ; 2
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @72
   sty GRP1                   ; 3 = @75
;--------------------------------------
   sta COLUPF                 ; 3 = @02
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @07
   sta PF1                    ; 3 = @10
   sta PF2                    ; 3 = @13
   ldy kernelPFLadderIndex    ; 3         get kernel PF ladder index value
   iny                        ; 2         increment by 4 to point to next value
   iny                        ; 2
   iny                        ; 2
   iny                        ; 2
   sty kernelPFLadderIndex    ; 3         set new kernel PF ladder index value
   lda ladderGraphicPtrs,y    ; 4
   sta kernelPF1LadderGraphicPtrs;3
   lda ladderGraphicPtrs + 2,y; 4
   sta kernelPF2LadderGraphicPtrs;3
   lda ladderGraphicPtrs + 1,y; 4
   sta kernelPF1LadderGraphicPtrs + 1;3
   lda ladderGraphicPtrs + 3,y; 4
   sta kernelPF2LadderGraphicPtrs + 1;3
   cpx #1                     ; 2
   bne .checkFastEddieSneakerCollision;2³
   sta WSYNC
;--------------------------------------
.checkFastEddieSneakerCollision
   cpx fastEddieKernelSection ; 3
   bne .checkForDoneGameKernel; 2³
   lda CXPPMM                 ; 3         read player collision values
   bpl .clearFrameCollisionCount;2³       branch if players didn't collide
   lda fastEddieOnLadderValue ; 3         get Fast Eddie ladder value
   bne .checkForDoneGameKernel; 2³        branch if Fast Eddie on a ladder
   inc frameCollisionCount    ; 5         increment frame collision count
   bne .checkForDoneGameKernel; 3         unconditional branch
       
.clearFrameCollisionCount
   lda #0                     ; 2
   sta frameCollisionCount    ; 3
.checkForDoneGameKernel
   cpy #16                    ; 2
   bcs .doneGameKernel        ; 2³        branch if ladder index done
   tsx                        ; 2         pull scanline value from stack
   jmp .doneDrawPlatformKernel; 3
       
.doneGameKernel
   sta WSYNC
;--------------------------------------
   tsx                        ; 2         pull scanline value from stack
   dex                        ; 2
   ldx #24                    ; 2
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @05
   jmp DrawTopKernelItems     ; 3
       
SetupPrizeValuesForKernel 
   ldy tmpKernelSection       ; 3 = @09   get current kernel section
   lda prizeArray - 1,y       ; 4         get prize index value
   tay                        ; 2         move prize index value to y register
   lda PrizeGraphicLSBValues,y; 4
   sta prizeGraphicPtrs       ; 3
   lda PrizeGraphicMSBValues,y; 4
   sta prizeGraphicPtrs + 1   ; 3         set prize graphic pointers
   ldy tmpObjectIndex         ; 3
   lda #ONE_COPY              ; 2
   txs                        ; 2         push scanline value to stack
   sta NUSIZ0                 ; 3         set to ONE_COPY for prize sprite
   lda objectFCHorizValues,y  ; 4
   sta HMP0                   ; 3
   and #$0F                   ; 2         keep coarse movement value
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda objectFCHorizValues,y  ; 4
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.coarsePositionPrize
   dex                        ; 2
   bne .coarsePositionPrize   ; 2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   tsx                        ; 2         pull scanline from stack
   jmp DrawLadderKernel       ; 3

DetermineLadderPlacement
   ldx #MAX_KERNEL_SECTION - 1
.determineLadderPlacement
   stx tmpLadderKernelSection
   jmp DetermineRandomLadderPlacement
       
.setPFLadderPlacementValues
   ldx tmpLadderKernelSection
   sec
   lda ladderPlacementValue         ; get ladder placement value
   bpl .setPlacementForPF2LadderGraphics; branch for PF2 graphics when D7 low
   lda ladderJustificationValue     ; get ladder justification value
   bpl .setRightJustifiedPF1LadderGraphics; branch to right justify when D7 low
   lda #<LeftJustifiedLadderGraphics
   sta ladderGraphicPtrs,y
   lda #>LeftJustifiedLadderGraphics
   sta ladderGraphicPtrs + 1,y
   lda #17                          ; must be between pixels 77 - 89 on left
   sta fastEddieHorizLadderValues,x ; or pixels 159 - 171 on the right side
   bcs .setNoPF2LadderGraphics      ; unconditional branch
       
.setRightJustifiedPF1LadderGraphics
   lda #<RightJustifiedLadderGraphics
   sta ladderGraphicPtrs,y
   lda #>RightJustifiedLadderGraphics
   sta ladderGraphicPtrs + 1,y
   lda #33                          ; must be between pixels 93 - 105 on left
   sta fastEddieHorizLadderValues,x ; or pixels 173 - 185 on the right side
.setNoPF2LadderGraphics
   lda #<BlankGraphics
   sta ladderGraphicPtrs + 2,y
   lda #>BlankGraphics
   sta ladderGraphicPtrs + 3,y
   bcs .determineNextSectionLadderPlacement;unconditional branch
   
.setPlacementForPF2LadderGraphics
   lda ladderJustificationValue     ; get ladder justification value
   bpl .setRightJustifiedPF2LadderGraphics; branch to right justify when D7 low
   lda #<LeftJustifiedLadderGraphics
   sta ladderGraphicPtrs + 2,y
   lda #>LeftJustifiedLadderGraphics
   sta ladderGraphicPtrs + 3,y
   lda #65
   sta fastEddieHorizLadderValues,x
   bcs .setNoPF1LadderGraphics      ; unconditional branch
   
.setRightJustifiedPF2LadderGraphics
   lda #<RightJustifiedLadderGraphics
   sta ladderGraphicPtrs + 2,y
   lda #>RightJustifiedLadderGraphics
   sta ladderGraphicPtrs + 3,y
   lda #49
   sta fastEddieHorizLadderValues,x
.setNoPF1LadderGraphics
   lda #<BlankGraphics
   sta ladderGraphicPtrs,y
   lda #>BlankGraphics
   sta ladderGraphicPtrs + 1,y
.determineNextSectionLadderPlacement
   iny
   iny
   iny
   dex
   iny
   cpy #16
   bne .determineLadderPlacement
   ldy #3
.setLadderGraphicPointers
   lda ladderGraphicPtrs,y
   sta ladderGraphicPtrs + 16,y
   dey
   bpl .setLadderGraphicPointers
   rts

SneakerNUSIZValues
LevelOneSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, ONE_COPY
;
; last 2 bytes shared with table below
;
LevelTwoSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, ONE_COPY, ONE_COPY, TWO_COPIES
LevelThreeSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, TWO_WIDE_COPIES, DOUBLE_SIZE, TWO_WIDE_COPIES
LevelFourSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, TWO_MED_COPIES, TWO_COPIES, TWO_WIDE_COPIES
LevelFiveSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, DOUBLE_SIZE, QUAD_SIZE, TWO_WIDE_COPIES
LevelSixSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, THREE_COPIES, DOUBLE_SIZE, TWO_WIDE_COPIES
LevelSevenSneakerSizeValues
   .byte ONE_COPY, ONE_COPY, TWO_MED_COPIES, DOUBLE_SIZE, THREE_MED_COPIES
LevelEightSneakerSizeValues
   .byte ONE_COPY, DOUBLE_SIZE, TWO_MED_COPIES, THREE_COPIES, THREE_MED_COPIES
  
FastEddieColorValues
FastEddieJumpingColorValues_02
   .byte BLACK, BLACK, BLACK, BLACK, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, GREEN + 7, GREEN + 7, YELLOW + 12, YELLOW + 12, YELLOW + 12
   .byte BLUE + 15, BLUE + 15, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   
FastEddieJumpingColorValues_00
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, GREEN + 7, GREEN + 7, YELLOW + 12, YELLOW + 12, YELLOW + 12
   .byte BLUE + 15, BLUE + 15, BLACK, BLACK, BLACK, BLACK
   
FastEddieJumpingColorValues_01
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, GREEN + 7
   .byte GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, YELLOW + 12, YELLOW + 12, YELLOW + 12, BLUE + 15, BLUE + 15
   .byte BLUE + 15, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK

FastEddieJumpingGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E6 ; |XXX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
FastEddieWalkingColors
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, GREEN + 7, YELLOW + 12, YELLOW + 12, YELLOW + 12
   .byte BLUE + 15, BLUE + 15, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK

FastEddieVerticalColors_00
   .byte BLACK, BLACK, BLACK, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, YELLOW + 12, YELLOW + 12
   .byte BLUE + 15, BLUE + 15, BLUE + 15, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   
FastEddieVerticalColors_01
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, YELLOW + 10
   .byte YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10, YELLOW + 10
   .byte YELLOW + 10, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7, GREEN + 7
   .byte GREEN + 7, GREEN + 7, GREEN + 7, YELLOW + 12, YELLOW + 12, BLUE + 15
   .byte BLUE + 15, BLACK, BLACK
   
FastEddieGraphic_00
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $74 ; |.XXX.X..|
   .byte $74 ; |.XXX.X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E6 ; |XXX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FastEddieGraphic_01
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $47 ; |.X...XXX|
   .byte $47 ; |.X...XXX|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E6 ; |XXX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FastEddieStationary
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $E6 ; |XXX..XX.|
   .byte $E6 ; |XXX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FastEddieVertical
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $17 ; |...X.XXX|
   .byte $17 ; |...X.XXX|
   .byte $14 ; |...X.X..|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

HighTopColors
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE
   .byte WHITE, RED_ORANGE + 6, RED_ORANGE + 6, RED_ORANGE + 6, RED_ORANGE + 6
   .byte RED_ORANGE + 6, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, WHITE, WHITE, WHITE, WHITE, BLACK, BLACK, BLACK
   .byte BLACK, BLACK, BLACK, BLACK
   
EddiePrizeGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $1C ; |...XXX..|
   .byte $7F ; |.XXXXXXX|
   .byte $49 ; |.X..X..X|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_10PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $E6 ; |XXX..XX.|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $46 ; |.X...XX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PerfumePrizeGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3E ; |..XXXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $2A ; |..X.X.X.|
   .byte $36 ; |..XX.XX.|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SmileyPrizeGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $82 ; |X.....X.|
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FishPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $8C ; |X...XX..|
   .byte $DE ; |XX.XXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $DE ; |XX.XXXX.|
   .byte $8C ; |X...XX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
TankPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $D5 ; |XX.X.X.X|
   .byte $AB ; |X.X.X.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $38 ; |..XXX...|
   .byte $7F ; |.XXXXXXX|
   .byte $68 ; |.XX.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
HammerPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $40 ; |.X......|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BalloonPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $2E ; |..X.XXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
WateringCanPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $4B ; |.X..X.XX|
   .byte $48 ; |.X..X...|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
AcePrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $6B ; |.XX.X.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
HeartPrizeGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $36 ; |..XX.XX.|
   .byte $00 ; |........|

BlankGraphics      
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BlankPrizeGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_20PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $72 ; |.XXX..X.|
   .byte $45 ; |.X...X.X|
   .byte $45 ; |.X...X.X|
   .byte $25 ; |..X..X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $62 ; |.XX...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_30PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $62 ; |.XX...X.|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $65 ; |.XX..X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $62 ; |.XX...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_40PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $22 ; |..X...X.|
   .byte $25 ; |..X..X.X|
   .byte $25 ; |..X..X.X|
   .byte $F5 ; |XXXX.X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $A2 ; |X.X...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_50PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $62 ; |.XX...X.|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $65 ; |.XX..X.X|
   .byte $45 ; |.X...X.X|
   .byte $72 ; |.XXX..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_60PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $62 ; |.XX...X.|
   .byte $95 ; |X..X.X.X|
   .byte $95 ; |X..X.X.X|
   .byte $E5 ; |XXX..X.X|
   .byte $85 ; |X....X.X|
   .byte $85 ; |X....X.X|
   .byte $62 ; |.XX...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_70PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $45 ; |.X...X.X|
   .byte $45 ; |.X...X.X|
   .byte $25 ; |..X..X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $72 ; |.XXX..X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_80PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $22 ; |..X...X.|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $25 ; |..X..X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
_90PointGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $22 ; |..X...X.|
   .byte $55 ; |.X.X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $35 ; |..XX.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
       
DetermineRandomLadderPlacement
   lda ladderPlacementValue
   ror
   lda ladderJustificationValue
   ror
   eor ladderPlacementValue
   ldx ladderJustificationValue
   sta ladderJustificationValue
   stx ladderPlacementValue
   jmp .setPFLadderPlacementValues
       
HorizontalFineMotionValues
   .byte HMOVE_L7, HMOVE_L6, HMOVE_L5, HMOVE_L4
   .byte HMOVE_L3, HMOVE_L2, HMOVE_L1, HMOVE_0
   .byte HMOVE_R1, HMOVE_R2, HMOVE_R3, HMOVE_R4
   .byte HMOVE_R5, HMOVE_R6, HMOVE_R7
   
PF2LivesIndicatorValues
   .byte $00 ; |........|
   .byte $E0 ; |XXX.....|
   .byte $0E ; |....XXX.|
   .byte $EE ; |XXX.XXX.|
   
NewPrizeIndexItemValues
   .byte <highTopHorizPosition - objectHorizPositions
   .byte <_05PlatformPrizeHorizPos - objectHorizPositions
   .byte <_04PlatformPrizeHorizPos - objectHorizPositions
   .byte <_03PlatformPrizeHorizPos - objectHorizPositions
   .byte <_02PlatformPrizeHorizPos - objectHorizPositions
   
FastEddieVertAnimationValues
   .byte <FastEddieVertical
   .byte <FastEddieVertical - 4
   
FastEddieVerticalColorLSBValues
   .byte <FastEddieVerticalColors_00
   .byte <FastEddieVerticalColors_01

;
; the following bytes are not used
;
   .byte $B0,$A0,$90,$00,$E0,$0E,$EE,$00,$05,$06,$07,$08

   BOUNDARY 0
   
NumberFonts       
zero
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
one
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
two
   .byte $7F ; |.XXXXXXX|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3E ; |..XXXXX.|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $43 ; |.X....XX|
   .byte $3E ; |..XXXXX.|
three
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1E ; |...XXXX.|
   .byte $03 ; |......XX|
   .byte $43 ; |.X....XX|
   .byte $3E ; |..XXXXX.|
four
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7F ; |.XXXXXXX|
   .byte $26 ; |..X..XX.|
   .byte $16 ; |...X.XX.|
   .byte $0E ; |....XXX.|
   .byte $06 ; |.....XX.|
five
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7F ; |.XXXXXXX|
six
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3E ; |..XXXXX.|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $41 ; |.X.....X|
   .byte $7F ; |.XXXXXXX|
eight
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
nine
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|

SneakerGraphics
SneakerGraphic_00
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $E4 ; |XXX..X..|
   .byte $E4 ; |XXX..X..|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

SneakerColors
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, LT_BLUE + 8, LT_BLUE + 8
   .byte LT_BLUE + 8, LT_BLUE + 8, LT_BLUE + 8, LT_BLUE + 8, BLACK, BLACK
   
SneakerGraphic_01
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $27 ; |..X..XXX|
   .byte $27 ; |..X..XXX|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
HighTopGraphics_00
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $E4 ; |XXX..X..|
   .byte $E4 ; |XXX..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
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
   .byte $02 ; |......X.|
   .byte $A7 ; |X.X..XXX|
   .byte $AD ; |X.X.XX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
HighTopGraphics_01
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $27 ; |..X..XXX|
   .byte $27 ; |..X..XXX|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
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
   .byte $02 ; |......X.|
   .byte $A7 ; |X.X..XXX|
   .byte $AD ; |X.X.XX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
PrizeGraphicLSBValues
   .byte <BlankPrizeGraphic - 16
   .byte <HeartPrizeGraphics - 16
   .byte <FishPrizeGraphics - 16
   .byte <TankPrizeGraphics - 16
   .byte <PerfumePrizeGraphic - 16
   .byte <BalloonPrizeGraphics - 16
   .byte <WateringCanPrizeGraphics - 16
   .byte <AcePrizeGraphics - 16
   .byte <SmileyPrizeGraphic - 16
   .byte <HammerPrizeGraphics - 16
   .byte <EddiePrizeGraphic - 16
   .byte <_10PointGraphic - 16
   .byte <_20PointGraphic - 16
   .byte <_30PointGraphic - 16
   .byte <_40PointGraphic - 16
   .byte <_50PointGraphic - 16
   .byte <_60PointGraphic - 16
   .byte <_70PointGraphic - 16
   .byte <_80PointGraphic - 16
   .byte <_90PointGraphic - 16
       
PrizeGraphicMSBValues
   .byte >BlankPrizeGraphic
   .byte >HeartPrizeGraphics
   .byte >FishPrizeGraphics
   .byte >TankPrizeGraphics
   .byte >PerfumePrizeGraphic
   .byte >BalloonPrizeGraphics
   .byte >WateringCanPrizeGraphics - 1
   .byte >AcePrizeGraphics
   .byte >SmileyPrizeGraphic
   .byte >HammerPrizeGraphics
   .byte >EddiePrizeGraphic
   .byte >_10PointGraphic
   .byte >_20PointGraphic
   .byte >_30PointGraphic
   .byte >_40PointGraphic
   .byte >_50PointGraphic
   .byte >_60PointGraphic
   .byte >_70PointGraphic
   .byte >_80PointGraphic
   .byte >_90PointGraphic

InitHorizPosAndDirValues
   .byte 1                          ; init High Top direction
   .byte 0                          ; init platform 5 Sneaker direction
   .byte -1                         ; init platform 4 Sneaker direction
   .byte 1                          ; init platform 3 Sneaker direction
   .byte -1                         ; init platform 2 Sneaker direction
   .byte INIT_HORIZ_POS_HIGH_TOP, INIT_HORIZ_POS_SNEAKER_05
   .byte INIT_HORIZ_POS_SNEAKER_04, INIT_HORIZ_POS_SNEAKER_03
   .byte INIT_HORIZ_POS_SNEAKER_02, INIT_HORIZ_POS_PRIZE_05
   .byte INIT_HORIZ_POS_PRIZE_04, INIT_HORIZ_POS_PRIZE_03
   .byte INIT_HORIZ_POS_PRIZE_02, INIT_HORIZ_POS_FAST_EDDIE
       
FastEddieVerticalReflectValues
   .byte NO_REFLECT, REFLECT, NO_REFLECT
   
PF0LivesIndicatorValues
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $EE ; |XXX.XXX.|
   .byte $EE ; |XXX.XXX.|
   
FastEddieJumpingGraphicLSBValues
   .byte <FastEddieJumpingGraphic
   .byte <FastEddieJumpingGraphic - 3
   .byte <FastEddieJumpingGraphic - 6
   .byte <FastEddieJumpingGraphic - 6
   .byte <FastEddieJumpingGraphic - 6
   .byte <FastEddieJumpingGraphic - 3

FastEddieJumpingColorLSBValues
   .byte <FastEddieJumpingColorValues_02
   .byte <FastEddieJumpingColorValues_00
   .byte <FastEddieJumpingColorValues_01
   .byte <FastEddieJumpingColorValues_01
   .byte <FastEddieJumpingColorValues_01
   .byte <FastEddieJumpingColorValues_00
   
HighTopGraphicLSBValues_00
   .byte <HighTopGraphics_00 + 1, <HighTopGraphics_00 + 2
   .byte <HighTopGraphics_00 + 3, <HighTopGraphics_00 + 4
   .byte <HighTopGraphics_00 + 5, <HighTopGraphics_00 + 6
   .byte <HighTopGraphics_00 + 7, <HighTopGraphics_00 + 8
   .byte <HighTopGraphics_00 + 9, <HighTopGraphics_00 + 10
   .byte <HighTopGraphics_00 + 16
   
HighTopGraphicLSBValues_01
   .byte <HighTopGraphics_01 + 1, <HighTopGraphics_01 + 2
   .byte <HighTopGraphics_01 + 3, <HighTopGraphics_01 + 4
   .byte <HighTopGraphics_01 + 5, <HighTopGraphics_01 + 6
   .byte <HighTopGraphics_01 + 7, <HighTopGraphics_01 + 8
   .byte <HighTopGraphics_01 + 9, <HighTopGraphics_01 + 10
   .byte <HighTopGraphics_01 + 16
   
HighTopColorLSBValues
   .byte <HighTopColors + 1, <HighTopColors + 2
   .byte <HighTopColors + 3, <HighTopColors + 4
   .byte <HighTopColors + 5, <HighTopColors + 6
   .byte <HighTopColors + 7, <HighTopColors + 8
   .byte <HighTopColors + 9, <HighTopColors + 10
   .byte <HighTopColors + 16
   
LeftJustifiedLadderGraphics
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
   .byte $F0 ; |XXXX....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   .byte $90 ; |X..X....|
   
RightJustifiedLadderGraphics
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   
GameSelectionGraphicLSBValues
   .byte <one - 1, <two - 1, <three - 1, <four - 1 
   .byte <five - 1, <six - 1, <seven - 1, <eight - 1, <nine - 1
   
SneakerRightBoundaryValues
   .byte SNEAKER_ONE_COPY_RIGHT_BOUNDARY, SNEAKER_TWO_COPIES_RIGHT_BOUNDARY
   .byte SNEAKER_TWO_MED_COPIES_RIGHT_BOUNDARY, SNEAKER_THREE_COPIES_RIGHT_BOUNDARY
   .byte SNEAKER_TWO_WIDE_COPIES_RIGHT_BOUNDARY, SNEAKER_DOUBLE_SIZE_RIGHT_BOUNDARY
   .byte SNEAKER_THREE_MED_COPIES_RIGHT_BOUNDARY, SNEAKER_QUAD_SIZE_RIGHT_BOUNDARY
       
SetupSneakerValuesForKernel
   ldy gameSelection          ; 3
   lda SneakerNUSIZLSBValues,y; 4
   sta sneakerNUSIZValuePtrs  ; 3
   lda #>SneakerNUSIZValues   ; 2
   sta sneakerNUSIZValuePtrs + 1;3
   ldy tmpKernelSection       ; 3
   lda (sneakerNUSIZValuePtrs),y;5
   sta NUSIZ0                 ; 3 = @69
   lda objectFCHorizValues,y  ; 4
   sta HMP0                   ; 3 = @76
;--------------------------------------
   and #$0F                   ; 2         keep coarse movement value
   sta tmpSneakerCoarseValue  ; 3
   sta WSYNC
;--------------------------------------
   ldx tmpSneakerCoarseValue  ; 3
   sta CXCLR                  ; 3         clear all collisions
   lda objectFCHorizValues,y  ; 4
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.coarsePositionSneaker
   dex                        ; 2
   bne .coarsePositionSneaker ; 2³
   SLEEP 2                    ; 2
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #H_KERNEL_SECTION - 16 ; 2
   jmp .continueDrawSneakerKernel;3
       
FastEddieLiteral_00
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $F7 ; |XXXX.XXX|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $F3 ; |XXXX..XX|
   .byte $00 ; |........|
FastEddieLiteral_01
   .byte $B8 ; |X.XXX...|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $98 ; |X..XX...|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $1D ; |...XXX.X|
   .byte $00 ; |........|
FastEddieLiteral_02
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
FastEddieLiteral_03
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
   .byte $00 ; |........|
FastEddieLiteral_04
   .byte $E7 ; |XXX..XXX|
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $94 ; |X..X.X..|
   .byte $E7 ; |XXX..XXX|
   .byte $00 ; |........|
FastEddieLiteral_05
   .byte $2F ; |..X.XXXX|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $AF ; |X.X.XXXX|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $2F ; |..X.XXXX|
   .byte $00 ; |........|
       
IncrementPlatformColor
   lda platformColor                ; get current platform color
   clc
   adc #16                          ; increment platform color value
   sta platformColor                ; set new platform color
   rts

SneakerNUSIZLSBValues
   .byte <LevelOneSneakerSizeValues
   .byte <LevelTwoSneakerSizeValues
   .byte <LevelThreeSneakerSizeValues
   .byte <LevelFourSneakerSizeValues
   .byte <LevelFiveSneakerSizeValues
   .byte <LevelSixSneakerSizeValues
   .byte <LevelSevenSneakerSizeValues
   .byte <LevelEightSneakerSizeValues
   .byte <LevelEightSneakerSizeValues
       
   .org ROM_BASE + 4096 - 4, 0      ; 4K ROM
   .word Start
   .word Start