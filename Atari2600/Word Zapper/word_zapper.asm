   LIST OFF
; ***  W O R D   Z A P P E R  ***
; Copyright 1982 US Games Corporation
; Designer: Henry Will IV
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: November 17, 2020
;
;  *** 116 BYTES OF RAM USED 12 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, US GAMES CORPORATION                         =
; =                                                                            =
; ==============================================================================
;
; - PAL50 version only adjusted frame times to produce 314 scan lines
; - Colors not adjusted for PAL50
; - ROM contains 32 "garbage" or used bytes
; - You can read Henry's notebook he kept while developing this game and others
;   from the Wayback Machine...https://tinyurl.com/y6aya4k5


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

VSYNC_TIME              = 19

   IF COMPILE_REGION = PAL50

FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 65
OVERSCAN_TIME           = 65

   ELSE
   
FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 34
OVERSCAN_TIME           = 34

   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

YELLOW                  = $10
RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
PURPLE                  = $50
COBALT_BLUE             = $60
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
LT_BLUE                 = $90
CYAN                    = $A0
OLIVE_GREEN             = $B0
GREEN                   = $C0
DK_GREEN                = $D0
LT_BROWN                = $E0
BROWN                   = $F0   

CHARACTER_COLORS_TIMER_AREA = GREEN + 10
CHARACTER_COLORS_SCROLL_AREA = WHITE
CHARACTER_COLORS_WORD_AREA = LT_BROWN + 10

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 13
H_WORD_ZAPPER           = 7
W_WORD_ZAPPER           = 8 * 2     ; DOUBLE_SIZE
H_OBSTACLE              = 6
H_MOUNTAINS             = 10
H_KERNEL                = 190
;
; Frame horizontal constants
;
XMIN                    = 8
XMAX                    = 148
;
; Message Area horizontal constants
;
HORIZ_POS_TIMER_AREA    = 37
HORIZ_POS_WORD_AREA     = 36
INIT_HORIZ_POS_SCROLL_AREA = 45
;
; Word Zapper horizontal constants
;
XMIN_WORD_ZAPPER        = XMIN + 2
XMAX_WORD_ZAPPER        = XMAX - 13
WORD_ZAPPER_LANDING_HORIZ_POS = XMIN_WORD_ZAPPER + 27
;
; Word Zapper vertical constants
;
YMAX_WORD_ZAPPER        = 136
YMIN_WORD_ZAPPER        = 57
WORD_ZAPPER_LANDING_VERT_POS = YMIN_WORD_ZAPPER

KERNEL_SECTIONS         = 4
MISSILE_SPEED_VALUE     = 4
MAX_GAME_SELECTION      = 24
INIT_GAME_TIMER_VALUE   = $99       ; BCD
INIT_LETTER_LASER_TIME  = 30
OBSTACLE_ANIMATIONS     = 4
INIT_SHOTS_FOR_FREEBIE  = 5
INIT_SCROLLER_ALPHABET_SCRAMBLE_TIME = 5
;
; Game Round constants
;
MAX_ROUNDS              = 2
GAME_ROUNDS_DONE        = 9
;
; Game Selection masks
;
METEOR_DENSITY_MASK     = %00000001
METEOR_SPEED_MASK       = %00000010
;
; Obstacle Spawn Times
;
SPAWN_TIME_ZONKER       = 90
SPAWN_TIME_SCROLLER     = 180
SPAWN_TIME_DOOMSDAY     = 240
;
; Game State values
;
GS_OBSTACLE_ENTRY_MARCH = 1
GS_WORD_ZAPPER_ENTRANCE = 3
GS_SET_GAME_SELECTION_LITERALS = 5
GS_START_NEW_GAME       = 6
GS_NEW_ROUND            = 7
GS_GAME_IN_PROGRESS     = 10
GS_WORD_ZAPPER_LANDING  = 17
GS_DISPLAY_SCORE_RANKING = 20
GS_SET_TO_DISPLAY_SCORE_RANKING = 22

;
; Sound Index Values
;
WORD_ZAPPER_ENTRANCE_AUDIO_IDX = 0
LAUNCH_LETTER_LASER_AUDIO_IDX = 4
LAUNCH_MISSILE_AUDIO_IDX = 8
COMPLETED_WORD_AUDIO_IDX = 12
EXPLOSION_AUDIO_IDX     = 16
ZONKER_COLLISION_AUDIO_IDX = 20
SCROLLER_COLLISION_AUDIO_IDX = 24
TIMER_EXPIRED_AUDIO_IDX = 28
GAME_WON_AUDIO_IDX      = 32
BONKER_COLLISION_AUDIO_IDX = 36
OBSTACLE_ENTRANCE_AUDIO_IDX = 40
DOOMSDAY_SPAWN_AUDIO_IDX = 40
STARTING_ROUND_AUDIO_IDX = 44
START_NEW_GAME_AUDIO_IDX = 48
INCREMENT_GAME_SELECTION_AUDIO_IDX = 52
WORD_ZAPPER_LANDED_AUDIO_IDX = 56
SHOT_TARGET_LETTER_AUDIO_IDX = 60

;===============================================================================
; M A C R O S
;===============================================================================

   MAC CHAR_SET_OFFSET

   .byte <[({1} / 2) + 42]
   
   ENDM

   MAC COMPRESS_SIX_LETTER_WORD

      .byte <[({6} - CommonEnglishLetters) << 4] | ({5} - CommonEnglishLetters)
      .byte <[({4} - CommonEnglishLetters) << 4] | ({3} - CommonEnglishLetters)
      .byte <[({2} - CommonEnglishLetters) << 4] | ({1} - CommonEnglishLetters)
      
   ENDM

   MAC COMPRESS_FOUR_LETTER_WORD
   
      .byte <[({4} - CommonEnglishLetters) << 4] | ({3} - CommonEnglishLetters)
      .byte <[({2} - CommonEnglishLetters) << 4] | ({1} - CommonEnglishLetters)
      
   ENDM
   

   MAC COMPRESS_FIVE_LETTER_WORD
   
      .byte <({5} - CommonEnglishLetters)
      .byte <[({4} - CommonEnglishLetters) << 4] | ({3} - CommonEnglishLetters)
      .byte <[({2} - CommonEnglishLetters) << 4] | ({1} - CommonEnglishLetters)
      
   ENDM
   
   MAC BYTE_STRING

      CHAR_SET_OFFSET {1}
      CHAR_SET_OFFSET {2}
      CHAR_SET_OFFSET {3}
      CHAR_SET_OFFSET {4}
      CHAR_SET_OFFSET {5}
      CHAR_SET_OFFSET {6}

   ENDM   
   
;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
characterGraphicPtrs    ds 12
;--------------------------------------
tmpWordZapperGraphicIdx = characterGraphicPtrs
;--------------------------------------
tmpObstacleVertPos      = tmpWordZapperGraphicIdx + 1
;--------------------------------------
obstacleGraphicPtrs     = tmpObstacleVertPos + 1
;--------------------------------------
obstacleColorPtrs       = obstacleGraphicPtrs + 2
;--------------------------------------
tmpEndKernelZone        = obstacleColorPtrs + 2
tmpFourthCharacter      ds 1
;--------------------------------------
tmpKernelSection        = tmpFourthCharacter
tmpFifthCharacter       ds 1
;--------------------------------------
tmpObstacleGraphicIdx   = tmpFifthCharacter
;--------------------------------------
tmpRamDataPointerIdx    ds 1
;--------------------------------------
tmpActionButtonValues   = tmpRamDataPointerIdx
;--------------------------------------
tmpObstacleColorValue   = tmpActionButtonValues
zpUnused_00             ds 1
messageAreaDataValues   ds 19
;--------------------------------------
timerAreaDataValues     = messageAreaDataValues
scrollAreaDataValues    = timerAreaDataValues + 6
wordAreaDataValues      = scrollAreaDataValues + 6
tmpMessageAreaHorizPos  ds 1
;--------------------------------------
tmpWordCountMulti2      = tmpMessageAreaHorizPos
;--------------------------------------
tmpLetterLaserActiveTimer = tmpWordCountMulti2
;--------------------------------------
tmpLetterIndex          = tmpLetterLaserActiveTimer
;--------------------------------------
tmpEnglishWordOffset    = tmpLetterIndex
randomMod16             ds 1
ramDataPointer          ds 2
previousJoystickValues  ds 1
joystickDebounceValues  ds 1        ; never referenced
scrollAreaHorizPos      ds 1
gameScrollingSpeed      ds 1
selectedScrollSpeedValue ds 1
scrollerAlphabetScrambleTimer ds 1
wordZapperGraphicPtrs   ds 2
actionButtonValues      ds 1
wordZapperColorPtrs     ds 2
wordZapperAnimationIdx  ds 1
obstacleAnimationOffset ds 1
gameState               ds 1
wordZapperHorizPos      ds 1
wordZapperVertPos       ds 1
random                  ds 3
wordZapperMissileHorizPos ds 1
wordZapperMissileVertPos ds 1
wordZapperColorValue    ds 1
wordZapperGraphicValue  ds 1
obstacleHorizPos        ds 4
obstacleVertPos         ds 4
obstacleGraphicLSBValues ds 4
obstacleVelocityValues  ds 4
frameSecondsCount       ds 1
currentGameTimer        ds 1
;--------------------------------------
tmpSelectDebounceRate   = currentGameTimer
targetLetters           ds 7
letterLaserActiveTimer  ds 1
targetLetterIndex       ds 1
letterLaserLetterIndex  ds 1
gameIdleTimer           ds 1
gameSelection           ds 1
currentRound            ds 1
consoleSwitchDebounceValues ds 1
playerGamerTimerValues  ds 2
;--------------------------------------
player1GameTimerValue   = playerGamerTimerValues
player2GameTimerValue   = player1GameTimerValue + 1
shotTallyForFreebie     ds 1
activePlayerNumber      ds 1
playerCorrectWordCount  ds 2
;--------------------------------------
player1CorrectWordCount = playerCorrectWordCount
player2CorrectWordCount = player1CorrectWordCount + 1
tvTypeSwitchValue       ds 1
obstacleSpawningTimer   ds 1
destroyedWordZapperGraphicLSB ds 1
zpUnused_01             ds 1
audioChannelIndex       ds 1
audioFrequencyAdjustmentValues ds 2
;--------------------------------------
leftChannelFreqAdjustment = audioFrequencyAdjustmentValues
rightChannelFreqAdjustment = leftChannelFreqAdjustment + 1
audioFrequencyValues    ds 2
;--------------------------------------
leftChannelFrequencyValue = audioFrequencyValues
rightChannelFrequencyValue = leftChannelFrequencyValue + 1
audioDurationValues     ds 2
;--------------------------------------
leftChannelAudioDuration = audioDurationValues
rightChannelAudioDuration = leftChannelAudioDuration + 1
initAudioVolumeDurationValues ds 2
;--------------------------------------
leftChannelInitVolumeDuration = initAudioVolumeDurationValues
rightChannelInitVolumeDuration = leftChannelInitVolumeDuration + 1
audioVolumeDurationValues ds 2
;--------------------------------------
leftChannelVolumeDuration = audioVolumeDurationValues
rightChannelVolumeDuration = leftChannelVolumeDuration + 1
audioVolumeValues       ds 2
;--------------------------------------
leftChannelVolumeValue  = audioVolumeValues
rightChannelVolumeValue = leftChannelVolumeValue + 1
frameCount              ds 1

   echo "***",(* - $80 - 2)d, "BYTES OF RAM USED", ($100 - * + 2)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

   .byte "COPYRIGHT 1982 US GAMES CORP."

Start
;
; Set up everything so the power up state is known.
;
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set stack to the beginning
   lda #0
.clearLoop
   sta VSYNC,x
   dex
   bne .clearLoop
   ldy #START_NEW_GAME_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for starting new game
   ldx #17
.initGameTitleMessage
   lda GameTitleLiterals,x          ; get game title literal values
   sta messageAreaDataValues,x      ; set message area character values
   dex
   bpl .initGameTitleMessage
   lda #HORIZ_POS_TIMER_AREA
   sta scrollAreaHorizPos           ; set horizontal position for scroll area
   dec wordZapperHorizPos
   dec wordZapperVertPos
   dec random
   dec random + 1
   dec random + 2
   dec gameIdleTimer                ; init game idle timer to 255
   lda #3
   sta actionButtonValues           ; set to disable game start
   lda #<Zonkers_00
   sta obstacleGraphicLSBValues
   asl                              ; multiply value by 2
   sta obstacleGraphicLSBValues + 3 ; set to Doomsday_00 sprite
   lda #<Scrollers_00
   sta obstacleGraphicLSBValues + 2
   lda #6
   sta obstacleSpawningTimer        ; wait ~6 seconds before spawning obstacle
   lda #1
   sta destroyedWordZapperGraphicLSB; set to not set Word Zapper graphics
   lda #<Blank
   sta wordZapperGraphicPtrs
   lda #>Blank
   sta wordZapperGraphicPtrs + 1
   lda #2
   sta currentGameTimer
   lda #ULTRAMARINE_BLUE + 2
   sta COLUBK
VerticalBlank
   sta WSYNC                        ; wait for next scan line
   sta VSYNC
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blank time
   rol random + 2
   rol random
   rol random + 1
   ror
   ror
   ror
   eor random + 1
   asl
   asl
   sta random + 2
   lda INPT4                        ; read left player action button value
   and #$80
   beq .resetGameIdleTimerValue     ; branch if action button pressed
   lda INPT5                        ; read right player action button value
   and #$80                         ; branch if action button pressed
   beq .resetGameIdleTimerValue
   lda SWCHA                        ; read joystick values
   eor #$FF                         ; flip joystick values
   bne .resetGameIdleTimerValue     ; branch if joystick moved
   lda SWCHB                        ; read console switches
   eor #$FF                         ; flip console switch bits
   and #SELECT_MASK | RESET_MASK
   beq .checkForGameIdleTimeout     ; branch if neither SELECT or RESET pressed
.resetGameIdleTimerValue
   inc random                       ; increment current random value
   lda #255
   sta gameIdleTimer                ; set game idle timer value
.checkForGameIdleTimeout
   lda gameIdleTimer                ; get game idle timer value
   bne SetWordZapperGraphicValues
   jmp VerticalBlank                ; perform vertical blanking if timer expired
       
SetWordZapperGraphicValues
   lda destroyedWordZapperGraphicLSB; get destroyed Word Zapper graphic LSB
   bne .animateWordZapperExplosion  ; branch if performing Word Zapper explosion
   ldx wordZapperAnimationIdx       ; get Word Zapper animation index
   lda WordZapperAnimationSprites,x ; get LSB value for Word Zapper graphic
   sta wordZapperGraphicPtrs        ; set Word Zapper graphic pointer LSB value
   lda WordZapperAnimationSprites + 1,x;get MSB value for Word Zapper graphic
   sta wordZapperGraphicPtrs + 1    ; set Word Zapper graphic pointer MSB value
   lda WordZapperAnimationColors,x  ; get LSB value for Word Zapper colors
   sta wordZapperColorPtrs          ; set Word Zapper color pointer LSB value
   lda WordZapperAnimationColors + 1,x;get MSB value for Word Zapper colors
   sta wordZapperColorPtrs + 1      ; set Word Zapper color pointer MSB value
   jmp SetupMessageAndTimerAreasForDisplay
       
.animateWordZapperExplosion
   cmp #<[DestroyedObstacle_03 + 32]
   beq .doneWordZapperExplosionRoutine
   cmp #1
   beq SetupMessageAndTimerAreasForDisplay;branch if not showing Word Zapper
   sta wordZapperGraphicPtrs        ; set exploding Word Zapper graphic LSB
   eor #$80
   sta wordZapperColorPtrs          ; set exploding Word Zapper color LSB
   ldx #>DestroyedObstacleColor_00
   stx wordZapperGraphicPtrs + 1
   stx wordZapperColorPtrs + 1
   tax                              ; move explosion color LSB to x register
   lda frameSecondsCount            ; get frame seconds count
   and #3
   bne SetupMessageAndTimerAreasForDisplay;branch if not time to animate
   txa                              ; restore explosion color LSB to accumulator
   clc
   adc #160
   sta destroyedWordZapperGraphicLSB
   bne SetupMessageAndTimerAreasForDisplay
       
.doneWordZapperExplosionRoutine
   ldx #0
   stx currentGameTimer             ; reset current game timer
   inx                              ; x = 1
   stx destroyedWordZapperGraphicLSB; set to not show Word Zapper
   lda #<Blank
   sta wordZapperGraphicPtrs        ; set Word Zapper sprite to Blank
   lda #>Blank
   sta wordZapperGraphicPtrs + 1
SetupMessageAndTimerAreasForDisplay
   lda #HORIZ_POS_TIMER_AREA
   jsr PositionObjectsForMessageArea; position sprites for timer area
   lda #THREE_MED_COPIES
   sta NUSIZ0
   sta NUSIZ1
   lda #<timerAreaDataValues
   jsr SetupMessageAreaForDisplay   ; setup for timer area display
   lda #CHARACTER_COLORS_TIMER_AREA
   sta COLUP0                       ; color sprites for timer area
   sta COLUP1
   lda #0
   sta PF0
   sta PF1
   sta PF2
   lda #PF_PRIORITY | PF_REFLECT
   sta CTRLPF
   jsr PlayGameAudioSounds
   inc frameCount                   ; increment frame count
   ldy #KERNEL_SECTIONS - 1
.processObstacles
   lda obstacleGraphicLSBValues,y   ; get obstacle graphic LSB value
   tax
   cmp #$80
   bcc .moveObstacle                ; branch if not an explosion
   lda frameSecondsCount            ; get frame seconds count
   and #3
   bne .skipObstacleExplosionAnimation
   txa                              ; move obstacle graphic LSB to accumulator
   adc #$1F
   bcs .checkToSpawnNewObstacle     ; branch if done with explosion animation
   sta obstacleGraphicLSBValues,y
.skipObstacleExplosionAnimation
   jmp .nextObstacle

.moveObstacle
   lda obstacleHorizPos,y           ; get obstacle horizontal position
   beq .checkToSpawnNewObstacle     ; branch if obstacle not active
   clc
   adc obstacleVelocityValues,y     ; increment by obstacle velocity
   cmp #XMAX
   bcs .checkToSpawnNewObstacle     ; branch if obstacle not active
   cmp #XMIN
   bcc .checkToSpawnNewObstacle     ; branch if obstacle not active
   jmp .setObstacleHorizontalPosition
       
.checkToSpawnNewObstacle
   lda obstacleSpawningTimer        ; get obstacle spawning timer
   bne .inactivateObstacle          ; branch if not spawning this frame
   lda gameSelection                ; get current game selection
   and #METEOR_DENSITY_MASK         ; keep METEOR_DENSITY value
   bne .configureManyObstacles      ; branch if METEOR_DENSITY_DENSE
   lda random + 1
   and #$0D
   bne .inactivateObstacle
.configureManyObstacles
   lda random                       ; get current random value
   inc random                       ; increment current random value
   and #$24
   beq .determineObstacleVelocityValue
.inactivateObstacle
   lda #0
   sta obstacleVertPos,y
   beq .setObstacleHorizontalPosition;unconditional branch
       
.determineObstacleVelocityValue
   lda gameSelection                ; get current game selection
   and #METEOR_SPEED_MASK           ; keep METEOR_SPEED value
   beq .configureForSlowObstacles   ; branch if METEOR_SPEED_SINGLE
   lda random                       ; get current random value
   and #3                           ; 0 <= a <= 3
   clc
   adc #<-2                         ; subtract value by 2
   adc #1 - 1
   bne .setObstacleVelocityValue    ; unconditional branch
   
.configureForSlowObstacles
   lda random                       ; get current random value
   and #1                           ; 0 <= a <= 1
   clc
   adc #<-1                         ; subtract value by 1
   adc #1 - 1
.setObstacleVelocityValue
   sta obstacleVelocityValues,y
   lda frameCount                   ; get current frame count
   and #7                           ; 0 <= a <= 7
   clc
   adc #12                          ; 12 <= a <= 19
   adc KernelZoneValues,y
   sta obstacleVertPos,y            ; set new obstacle vertical position
   lda #<Bonker_00
   ldx random + 1
   inc random + 1
   cpx #SPAWN_TIME_ZONKER
   bcc .setValuesForSpawnedObstacle ; branch to spawn Bonker
   lda #<Zonkers_00
   cpx #SPAWN_TIME_SCROLLER
   bcc .setValuesForSpawnedObstacle ; branch to spawn Zonker
   cpx #SPAWN_TIME_DOOMSDAY
   bcc .checkToSpawnScroller
   lda SWCHB                        ; read console switches
   and #P1_DIFF_MASK                ; keep right difficulty value
   beq .inactivateObstacle          ; branch if NOVICE (i.e. no Doomsday)
   tya                              ; move kernel section index to accumulator
   pha                              ; push value to stack
   ldy #DOOMSDAY_SPAWN_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for spawning Doomsday
   pla                              ; pull kernel section index from stack
   tay                              ; reset y register with kernel section value
   lda #<Doomsday_00
   bne .setValuesForSpawnedObstacle ; unconditional branch
       
.checkToSpawnScroller
   lda SWCHB                        ; read console switches
   and #P0_DIFF_MASK                ; keep left difficulty value
   beq .inactivateObstacle          ; branch if NOVICE (i.e. no Scroller)
   lda #<Scrollers_00
.setValuesForSpawnedObstacle
   sta obstacleGraphicLSBValues,y
   lda obstacleVelocityValues,y     ; get obstacle velocity value
   bpl .initiateObstacleOnLeft      ; branch if traveling right
   lda #XMAX
   jmp .setObstacleHorizontalPosition; init obstacle on right
       
.initiateObstacleOnLeft
   lda #XMIN
.setObstacleHorizontalPosition
   sta obstacleHorizPos,y
.nextObstacle
   dey
   bmi SetWordZapperPositionBoundaries
   jmp .processObstacles
       
SetWordZapperPositionBoundaries
   sta CXCLR                        ; clear collision registers
   ldx wordZapperHorizPos           ; get Word Zapper horizontal position
   cpx #XMAX_WORD_ZAPPER
   bcc .checkWordZapperLeftBoundary ; branch if not reached right boundary
   ldx #XMAX_WORD_ZAPPER
.checkWordZapperLeftBoundary
   cpx #XMIN_WORD_ZAPPER
   bcs .setWordZapperHorizonalBoundary;branch if not reached left boundary
   ldx #XMIN_WORD_ZAPPER
.setWordZapperHorizonalBoundary
   stx wordZapperHorizPos
   ldy wordZapperVertPos            ; get Word Zapper vertical position
   cpy #YMAX_WORD_ZAPPER
   bcc .checkWordZapperLowerBoundary; branch if not reached upper boundary
   ldy #YMAX_WORD_ZAPPER
.checkWordZapperLowerBoundary
   cpy #YMIN_WORD_ZAPPER
   bcs .setWordZapperVerticalBoundary;branch if not reached lower boundary
   ldy #YMIN_WORD_ZAPPER
.setWordZapperVerticalBoundary
   sty wordZapperVertPos
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   lda #ENABLE_TIA
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   ldx #H_KERNEL              ; 2
.topBlankLines
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   cpx #H_KERNEL - 9          ; 2
   bcs .topBlankLines         ; 2³
   jsr SixDigitDisplayKernel  ; 6
.blankLinesBeforeScrollArea
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   cpx #H_KERNEL - 24         ; 2
   bcs .blankLinesBeforeScrollArea;2³
   lda #<scrollAreaDataValues ; 2
   jsr SetupMessageAreaForDisplay;6       setup for scroll area display
   lda #$F8                   ; 2
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   sta PF1                    ; 3 = @06
   lda scrollAreaHorizPos     ; 3         get scroll area horizontal position
   jsr PositionObjectsForMessageArea;6
;--------------------------------------
   lda #CHARACTER_COLORS_SCROLL_AREA;2
   sta COLUP0                 ; 3 = @14   color sprites for scroll area
   sta COLUP1                 ; 3 = @17
   jsr SixDigitDisplayKernel  ; 6
;--------------------------------------
   lda #MSBL_SIZE8 | DOUBLE_SIZE;2 = @26
   sta NUSIZ0                 ; 3 = @29   set size for Word Zapper
   lda #MSBL_SIZE1 | ONE_COPY ; 2
   sta NUSIZ1                 ; 3 = @34   set size for obstacles
   lda wordZapperHorizPos     ; 3         get Word Zapper horizontal position
   jsr PositionGRP0Horizontally;6         position Word Zapper horizontally
;--------------------------------------
   lda wordZapperMissileHorizPos;3 = @18
   ldy #<[RESM0 - RESP0]      ; 2
   jsr PositionObjectHorizontally;6       position Word Zapper missile
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$30                   ; 2
   sta PF0                    ; 3 = @08
   lda #$00                   ; 2
   sta PF1                    ; 3 = @13
   lda #YELLOW + 14           ; 2
   sta wordZapperColorValue   ; 3         set color for Letter Laser
   sta COLUP0                 ; 3 = @21
   lda wordZapperGraphicValue ; 3
   sta GRP0                   ; 3 = @27   draw Letter Laser
   lda #0                     ; 2
   sta tmpWordZapperGraphicIdx; 3         reset Word Zapper graphic index
   lda #>ObstacleSprites      ; 2
   sta obstacleGraphicPtrs + 1; 3         set obstacle graphic pointer MSB value
   lda #>ObstacleColors       ; 2
   sta obstacleColorPtrs + 1  ; 3         set obstacle color pointer MSB value
   dex                        ; 2         decrement scan line count
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3
   dex                        ; 2         decrement scan line count
   jmp BeginKernelSectionKernel;3
       
.doneGameKernel
   jmp DrawMountainsKernel    ; 3

BeginKernelSectionKernel
   lda #KERNEL_SECTIONS       ; 2
   sta tmpKernelSection       ; 3
.nextKernelSection
   dec tmpKernelSection       ; 5
   bmi .doneGameKernel        ; 2³
   dex                        ; 2         decrement scan line count
   cpx wordZapperMissileVertPos;3         compare missile vertical position
   php                        ; 3         push compare to stack
   cpx wordZapperVertPos      ; 3         compare Word Zapper vertical position
   bcs PositionObstacleHorizontally;2³    branch if not time to draw Word Zapper
   ldy tmpWordZapperGraphicIdx; 3         get Word Zapper graphic index value
   lda (wordZapperColorPtrs),y; 5         get Word Zapper color value
   sta wordZapperColorValue   ; 3
   lda (wordZapperGraphicPtrs),y;5        get Word Zapper graphic data
   beq .setWordZapperGraphicValue;2³
   iny                        ; 2         increment Word Zapper graphic index
.setWordZapperGraphicValue
   sta wordZapperGraphicValue ; 3
   sty tmpWordZapperGraphicIdx; 3
PositionObstacleHorizontally
   ldy tmpKernelSection       ; 3
   lda obstacleHorizPos,y     ; 4         get obstacle horizontal position
   sta WSYNC
;--------------------------------------
   sec                        ; 2
.coarsePositionObstacle
   sbc #15                    ; 2         divide position by 15
   bcs .coarsePositionObstacle; 2³
   eor #15                    ; 2         4-bit 1's complement for fine motion
   asl                        ; 2         shift remainder to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   adc #(8 + 1) << 4          ; 2         increment by 8 for full range
   SLEEP 2                    ; 2
   sta RESP1                  ; 3         set coarse position value
   sta WSYNC
;--------------------------------------
   sta HMP1                   ; 3 = @03
   lda wordZapperGraphicValue ; 3
   sta GRP0                   ; 3 = @09
   lda wordZapperColorValue   ; 3
   sta COLUP0                 ; 3 = @15
   pla                        ; 4         pull status to enable/disable missile
   sta ENAM0                  ; 3 = @22
   lda obstacleGraphicLSBValues,y;4       get obstacle graphic LSB value
   cmp #$80                   ; 2
   bcs .setObstacleGraphicLSBValue;2³     branch if explosion sprite
   clc                        ; 2
   adc obstacleAnimationOffset; 3         increment for obstacle animation
.setObstacleGraphicLSBValue
   sta obstacleGraphicPtrs    ; 3         get obstacle graphic pointer LSB value
   eor #$80                   ; 2
   sta obstacleColorPtrs      ; 3         set obstacle color pointer LSB value
   lda KernelZoneValues,y     ; 4
   sta tmpEndKernelZone       ; 3         set end of kernel zone value
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2         decrement scan line count
   dex                        ; 2         decrement scan line count
   lda obstacleVertPos,y      ; 4
   sta tmpObstacleVertPos     ; 3
   lda #0                     ; 2
   sta tmpObstacleGraphicIdx  ; 3
   bpl .checkToDrawWordZapperMissile;3    unconditional branch
       
.drawKernelSection
   sta WSYNC
;--------------------------------------
.nextKernelSectionScanLine
   dex                        ; 2         decrement scan line count
   cpx tmpEndKernelZone       ; 3
   bcc .nextKernelSection     ; 2³
   txa                        ; 2         move scan line to accumulator
   lsr                        ; 2         shift D0 to carry
   bcc .checkToDrawObstacle   ; 2³ + 1    branch on an even scan line
.checkToDrawWordZapperMissile
   cpx wordZapperMissileVertPos;3         compare missile vertical position
   php                        ; 3         push status to stack
   pla                        ; 4         pull status to enable/disable missile
   sta ENAM0                  ; 3
   cpx wordZapperVertPos      ; 3         compare Word Zapper vertical position
   bcs .drawKernelSection     ; 2³ + 1    branch if not time to draw Word Zapper
   ldy tmpWordZapperGraphicIdx; 3         get Word Zapper graphic index value
   lda (wordZapperColorPtrs),y; 5         get Word Zapper color value
   sta wordZapperColorValue   ; 3
   lda (wordZapperGraphicPtrs),y;5        get Word Zapper graphic data
   beq .setWordZapperGraphicIndex;2³      branch if done drawing Word Zapper
   iny                        ; 2         increment Word Zapper graphic index
.setWordZapperGraphicIndex
   sty tmpWordZapperGraphicIdx; 3
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda wordZapperColorValue   ; 3
   sta COLUP0                 ; 3 = @09
   jmp .nextKernelSectionScanLine;3

   .byte $B1                        ; unused byte
   
.checkToDrawObstacle
   cpx tmpObstacleVertPos     ; 3         compare obstacle vertical position
   bcs .skipObstacleDraw      ; 2³        branch if not time to draw obstacle
   ldy tmpObstacleGraphicIdx  ; 3         get obstacle graphic index value
   lda (obstacleColorPtrs),y  ; 5         get obstacle color value
   sta tmpObstacleColorValue  ; 3
   lda (obstacleGraphicPtrs),y; 5         get obstacle graphic data
   beq .setObstacleGraphicIndex;2³        branch if done drawing obstacle
   iny                        ; 2         increment obstacle graphic index
.setObstacleGraphicIndex
   sty tmpObstacleGraphicIdx  ; 3
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda tmpObstacleColorValue  ; 3
   sta COLUP1                 ; 3 = @09
   dex                        ; 2         decrement scan line count
   jmp .checkToDrawWordZapperMissile;3
       
.skipObstacleDraw
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   jmp .checkToDrawWordZapperMissile;3
       
   .byte $85                        ; unused byte

DrawMountainsKernel
   ldy #(H_MOUNTAINS * 6) - 1 ; 2
.drawMountainsKernel
   lda #<~(PF_SCORE | PF_REFLECT);2
   sta WSYNC
;--------------------------------------
   sta CTRLPF                 ; 3 = @03   set playfield to PF_NO_REFLECT
   dex                        ; 2         decrement scan line count
   lda MountainGraphics,y     ; 4
   sta PF0                    ; 3 = @12
   dey                        ; 2
   lda MountainGraphics,y     ; 4
   sta PF1                    ; 3 = @21
   dey                        ; 2
   lda MountainGraphics,y     ; 4
   sta PF2                    ; 3 = @30
   dey                        ; 2
   lda MountainGraphics,y     ; 4
   sta PF0                    ; 3 = @39
   dey                        ; 2
   lda MountainGraphics,y     ; 4
   sta PF1                    ; 3 = @48
   dey                        ; 2
   lda MountainGraphics,y     ; 4
   sta PF2                    ; 3 = @57
   dey                        ; 2
   bpl .drawMountainsKernel   ; 2³
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   ldy #136 + (MSBL_SIZE8 | PF_REFLECT);2
   sty CTRLPF                 ; 3 = @07
   lda #THREE_MED_COPIES      ; 2
   sta NUSIZ0                 ; 3 = @12
   sta NUSIZ1                 ; 3 = @15
   lda #HORIZ_POS_WORD_AREA   ; 2
   jsr PositionObjectsForMessageArea;6
;--------------------------------------
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @14
   lda #<wordAreaDataValues   ; 2
   jsr SetupMessageAreaForDisplay;6       setup for word area display
   lda #CHARACTER_COLORS_WORD_AREA;2
   sta COLUP0                 ; 3         color sprites for word area
   sta COLUP1                 ; 3
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   jsr SixDigitDisplayKernel  ; 6
.endDisplayKernel
   sta WSYNC
;--------------------------------------
   dex                        ; 2         decrement scan line count
   bpl .endDisplayKernel      ; 2³
   lda #DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (D1 = 1)
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan
   lda SWCHA                        ; read joystick values
   tax                              ; move current values to x register
   eor previousJoystickValues
   and previousJoystickValues
   stx previousJoystickValues
   sta joystickDebounceValues
   lda INPT4                        ; read left player action button value
   rol                              ; shift action button value to carry
   lda INPT5                        ; read right player action button value
   rol                              ; rotate values to D1 and D0
   rol
   and #3                           ; keep action button values
   sta tmpActionButtonValues
   eor actionButtonValues           ; flip action button values
   and actionButtonValues
   asl                              ; shift debounce values
   asl
   ora tmpActionButtonValues        ; combine with current action button values
   sta actionButtonValues
   ldx wordZapperAnimationIdx       ; get Word Zapper animation index
   inx                              ; 2 animations per frame
   inx
   cpx #8
   bcc .setWordZapperAnimationIndex ; branch if within animation frame
   ldx #0
.setWordZapperAnimationIndex
   stx wordZapperAnimationIdx
   lda frameSecondsCount            ; get frame seconds count
   and #3
   bne ScrollLetters
   lda obstacleAnimationOffset      ; get obstacle animation offset value
   clc
   adc #H_OBSTACLE                  ; increment by H_OBSTACLE
   cmp #[H_OBSTACLE * OBSTACLE_ANIMATIONS]
   bcc .setObstacleAnimationOffset  ; branch if within animation range
   lda #0
.setObstacleAnimationOffset
   sta obstacleAnimationOffset
ScrollLetters
   lda letterLaserActiveTimer       ; get Letter Laser timer value
   bne .jmpToGameStateRoutine       ; branch if Letter Laser active
   lda gameState                    ; get current game state
   cmp #GS_GAME_IN_PROGRESS
   bne .jmpToGameStateRoutine
   lda selectedScrollSpeedValue
   sta gameScrollingSpeed
.scrollLetters 
   dec scrollAreaHorizPos           ; decrement scroll area horizontal position
   lda scrollAreaHorizPos           ; get scroll area horizontal position
   cmp #INIT_HORIZ_POS_SCROLL_AREA - 16
   bne .decrementLetterScrollingSpeed
   lda #INIT_HORIZ_POS_SCROLL_AREA
   sta scrollAreaHorizPos           ; reset scroll area horizontal position
   ldx #0
   ldy #1
.rotateScrollAreaLetters 
   lda scrollAreaDataValues,y       ; get next data area character
   sta scrollAreaDataValues,x       ; set data area character
   inx
   iny
   cpy #6
   bne .rotateScrollAreaLetters
   lda scrollerAlphabetScrambleTimer;get Scroller alphabet scramble timer
   bne .scrambleScrollingAlphabet   ; branch if scrambling alphabet for Scroller
   ldy scrollAreaDataValues + 4
   iny
   cpy #<[(_Blank / 2) + 42] + 1
   bne .checkToScrollFreebieInAlphabet;branch if ending character not a Blank
   ldy #<[(_A / 2) + 42]
   bne .setEndingAlphabetLetter     ; set ending character to an "A"
       
.checkToScrollFreebieInAlphabet
   cpy #<[((_Z + 2) / 2) + 42]
   bne .setEndingAlphabetLetter     ; branch if not reached end of alphabet
   ldy #<[(_Freebie / 2) + 42]
   lda shotTallyForFreebie          ; get shots tallied for Freebie
   beq .setEndingAlphabetLetter     ; branch to show Freebie
   ldy #<[(_Blank / 2) + 42]
   bne .setEndingAlphabetLetter     ; unconditional branch
       
.scrambleScrollingAlphabet
   lda random                       ; get current random value
   and #$1F                         ; 0 <= a <= 31
   cmp #26
   bcc .determineNewCharacterForAlphabet;branch if within alphabet range
   sbc #26                          ; get random number within alphabet range
.determineNewCharacterForAlphabet
   clc
   adc #<[(_A / 2) + 42]            ; increment by alphabet character offset
   tay
.setEndingAlphabetLetter
   sty scrollAreaDataValues + 5
.decrementLetterScrollingSpeed
   dec gameScrollingSpeed
   lda gameScrollingSpeed
   bne .scrollLetters
.jmpToGameStateRoutine
   lda #0
   sta wordZapperGraphicValue       ; clear Word Zapper graphic value
   lda gameState                    ; get current game state
   asl                              ; multiply by 2
   tay
   iny
   lda GameStateRoutineTable,y
   pha                              ; push game state routine MSB to stack
   dey
   lda GameStateRoutineTable,y
   pha                              ; push game state routine LSB to stack
   rts                              ; jump to game state routine

GameStateRoutineTable
   .word CheckToAdvanceNextGameState - 1
   .word StartObstacleEntranceMarch - 1
   .word CheckToAdvanceNextGameState - 1
   .word PlayWordZapperEntranceSounds - 1
   .word WordZapperLandingRoutine - 1
   .word SetGameSelectionLiterals - 1
   .word StartNewGame - 1
   .word SetupForNewRound - 1
   .word CheckToAdvanceNextGameState - 1
   .word SetupTargetLetters - 1
   .word CheckObjectCollisions - 1
   .word TargetLettersDoneMoveLeft - 1
   .word TargetLettersDoneMoveRight - 1
   .word TargetLettersDoneMoveLeft - 1
   .word TargetLettersDoneMoveRight - 1
   .word TargetLettersDoneMoveLeft - 1
   .word TargetLettersDoneMoveRight - 1
   .word WordZapperLandingRoutine - 1
   .word CheckToSwitchToAlternatePlayer - 1
   .word CheckToAdvanceNextGameState - 1
   .word DisplayPlayerScoreRanking - 1
   .word CheckToStartNewGame - 1
   .word SetGameStateToDisplayScoreRanking - 1

SetGameSelectionLiterals
   ldx #17
.initGameSelectionLiterals 
   lda GameSelectionLiterals,x
   sta messageAreaDataValues,x
   dex
   bpl .initGameSelectionLiterals
   lda SWCHB                        ; read console switches
   tax                              ; move console switch value to x register
   eor consoleSwitchDebounceValues  ; flip bits from last read
   and consoleSwitchDebounceValues
   stx consoleSwitchDebounceValues  ; set to current frame console switch value
   and #SELECT_MASK                 ; keep SELECT value
   beq .checkToIncrementGameSelection;branch if SELECT held last frame
   sta tmpSelectDebounceRate
   bne .incrementGameSelection
       
.checkToIncrementGameSelection
   lda tmpSelectDebounceRate
   bne .keepGameSelectionWithinRange
   lda SWCHB                        ; read console switches
   and #SELECT_MASK                 ; keep SELECT button value
   bne .keepGameSelectionWithinRange; branch if SELECT not pressed
   lda #1
   sta tmpSelectDebounceRate
.incrementGameSelection
   ldy #INCREMENT_GAME_SELECTION_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for game selection
   inc gameSelection                ; increment game selection
.keepGameSelectionWithinRange
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION
   bne DisplayGameSelectionNumber
   lda #0
   sta gameSelection                ; reset game selection
DisplayGameSelectionNumber
   sec
   adc #1 - 1
   ldx #<[(_Blank / 2) + 42]        ; point to Blank
   cmp #10
   bcc .displayGameSelectionNumber  ; branch to suppress tens value
   ldx #<[(_1 / 2) + 42]
   sbc #10                          ; subtract (i.e divide) by 10
   cmp #10
   bcc .displayGameSelectionNumber  ; branch it set tens value to 1
   ldx #<[(_2 / 2) + 42]
   sbc #10                          ; subtract (i.e divide) by 10
.displayGameSelectionNumber
   stx timerAreaDataValues + 4      ; set game selection tens value
   ora #<[(_0 / 2) + 42]
   sta timerAreaDataValues + 5      ; set game selection ones value
   lda actionButtonValues           ; get action button values
   and #$0C                         ; keep action button debounce values
   beq .doneSetGameSelectionLiterals; branch if action button not pressed
   inc gameState
   lda gameSelection                ; get current game selection
   lsr                              ; divide value by 8 for SCROLL_SPEED value
   lsr
   lsr
   tax                              ; move SCROLL_SPEED to x register
   inx
   stx selectedScrollSpeedValue
.doneSetGameSelectionLiterals
   jmp MoveWordZapperMissile

StartNewGame
   ldx #INIT_GAME_TIMER_VALUE
   stx player1GameTimerValue
   lda SWCHB                        ; read console switches
   and #BW_MASK
   sta tvTypeSwitchValue
   beq .initPlayer2TimerValue       ; branch if set to B/W
   ldx #0
.initPlayer2TimerValue 
   stx player2GameTimerValue
   lda #0
   sta activePlayerNumber           ; reset active player number
   lda #MAX_ROUNDS
   sta currentRound                 ; set initial round number
   sta player2CorrectWordCount
   ldy #START_NEW_GAME_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for starting new game
   jmp StepToNextGameState

SetupForNewRound
   ldx #255
   stx obstacleSpawningTimer        ; wait ~255 seconds before spawning obstacle
   inx                              ; x = 0
   stx destroyedWordZapperGraphicLSB
   ldx #5
.resetMessageAreasForNewRound
   lda #<[(_Blank / 2) + 42]
   sta timerAreaDataValues,x        ; clear timer data area
   sta wordAreaDataValues,x         ; clear word data area
   txa                              ; move index to accumulator
   clc
   adc #<[(_A / 2) + 42]            ; increment by alphabet character offset
   sta scrollAreaDataValues,x
   dex
   bpl .resetMessageAreasForNewRound
   lda #4
   sta currentGameTimer
   ldx #0
   stx letterLaserActiveTimer       ; inactivate Letter Laser
   lda gameSelection                ; get current game selection
   and #7
   beq .setInitialShotsForFreebie
   ldx #INIT_SHOTS_FOR_FREEBIE
.setInitialShotsForFreebie
   stx shotTallyForFreebie
   and #4
   beq .setMatchForEnglishWords
   lda currentRound                 ; get current round number
   eor #3                           ; get 2-bit 1's complement
   clc
   adc #2
   tax                              ; set number of letters
.setMatchForScrambledLetters
   lda random                       ; get current random value
   adc random + 1
   sta random
   dec random + 1
   and #$1F                         ; 0 <= a <= 31
   cmp #26
   bcc .determineNewScrambledLetter ; branch if within alphabet range
   sbc #26                          ; get random number within alphabet range
.determineNewScrambledLetter
   clc
   adc #<[(_A / 2) + 42]            ; increment by alphabet character offset
   sta wordAreaDataValues,x         ; place scrambled letter in word area
   dex
   bpl .setMatchForScrambledLetters
   jmp StepToNextGameState
       
.setMatchForEnglishWords
   lda #<[SixCharacterWords - EnglishWordLibrary]
   ldx #5                           ; assume 6 character word
   ldy currentRound                 ; get current round number
   beq .determineEnglishWordOffset  ; branch if last round
   lda #<[FiveCharacterWords - EnglishWordLibrary]
   dex
   dey                              ; decrement current round
   beq .determineEnglishWordOffset  ; branch if second round
   dex
   lda frameCount                   ; get current frame count
   and #$1E
   jmp .setEnglishWordIndexValue

.determineEnglishWordOffset
   sta tmpEnglishWordOffset
   lda random                       ; get current random value
   and #$0F                         ; 0 <= a <= 15
   sta randomMod16
   asl                              ; multiply by 2
   clc                              ; not needed...carry cleared with ASL above
   adc randomMod16                  ; add in original...multiplied by 3
   adc tmpEnglishWordOffset
.setEnglishWordIndexValue
   tay
.setCommonEnglishWord
   txa                              ; move letter index to accumulator
   ror                              ; shift D0 to carry
   lda EnglishWordLibrary,y         ; get letter index for word
   bcc .evenWordIndexValue          ; branch in even letter index
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   jmp .placeLetterInWordAreaData
       
.evenWordIndexValue
   and #$0F                         ; keep lower nybbles
   iny                              ; increment letter index pointer
.placeLetterInWordAreaData
   stx tmpLetterIndex               ; save off letter index value
   tax                              ; move common letter index to x register
   lda CommonEnglishLetters,x
   ldx tmpLetterIndex               ; restore letter index value
   sta wordAreaDataValues,x         ; place letter in Word Data Area
   dex
   bpl .setCommonEnglishWord
   jmp StepToNextGameState
       
CheckToStartNewGame
   lda actionButtonValues           ; get action button values
   and #$0C                         ; keep action button debounce values
   beq .checkResetButtonPressed     ; branch if action button not pressed
   lda #GS_START_NEW_GAME
   jmp .setNewGameStateValue
       
.checkResetButtonPressed
   lda SWCHB                        ; read console switches
   and #RESET_MASK                  ; keep RESET value
   bne CheckToAdvanceNextGameState  ; branch if RESET not pressed
   lda #GS_SET_GAME_SELECTION_LITERALS
   jmp .setNewGameStateValue
       
CheckToAdvanceNextGameState
   lda currentGameTimer             ; get current game timer value
   bne .doneCheckToAdvanceNextGameState;branch if game timer not expired
   inc gameState                    ; advance to next game state
.doneCheckToAdvanceNextGameState 
   jmp MoveWordZapperMissile

SetupTargetLetters
   ldy #5
.setupTargetLetters
   lda wordAreaDataValues,y
   sta targetLetters,y
   lda #<[(_QuestionMark / 2) + 42]
   sta wordAreaDataValues,y         ; store "?" in word area
   dey
   bpl .setupTargetLetters
   lda #<[(_Blank / 2) + 42]
   sta wordAreaDataValues + 6
   sta targetLetters + 6
   lda currentRound                 ; get current round number
   eor #3                           ; get 2-bit 1's complement
   tax
   lda #<[(_Freebie / 2) + 42]
   sta targetLetters + 3,x          ; place Freebie at the end of the word
   ldx activePlayerNumber           ; get active player number
   lda playerGamerTimerValues,x     ; get player game timer value
   sta currentGameTimer
   lda #0
   sta targetLetterIndex            ; reset target letter index
   lda #3
   sta obstacleSpawningTimer        ; wait ~3 seconds before spawning obstacle
   ldy #STARTING_ROUND_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for starting a round
   jmp StepToNextGameState
       
CheckObjectCollisions
   lda SWCHB                        ; read console switches
   and #RESET_MASK                  ; keep RESET value
   bne .checkObjectCollisions       ; branch if RESET not pressed
   lda #GAME_ROUNDS_DONE
   sta currentRound                 ; set round number out of round range
   lda #GS_WORD_ZAPPER_LANDING
   jmp .setNewGameStateValue
       
.checkObjectCollisions
   lda CXM0P                        ; get Word Zapper missile collision value
   and #$80                         ; keep missile / obstacle collision value
   beq .checkWordZapperObstacleCollisions;branch if obstacle not shot
   ldx #KERNEL_SECTIONS - 1
   lda wordZapperMissileVertPos     ; get Word Zapper missile vertical position
.determineMissileObstacleCollisionSection
   cmp KernelZoneValues,x
   bcs .determineObstacleShotByWordZapper;branch if found kernel section
   dex
   bne .determineMissileObstacleCollisionSection
.determineObstacleShotByWordZapper
   lda #0
   sta wordZapperMissileVertPos     ; disable Word Zapper missile
   lda obstacleGraphicLSBValues,x   ; get obstacle graphic LSB value
   cmp #$80
   bcs .checkWordZapperObstacleCollisions;branch if an explosion
   lda #<DestroyedObstacle_00
   sta obstacleGraphicLSBValues,x
   ldy #EXPLOSION_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for explosion
   lda shotTallyForFreebie          ; get shot tallied for Freebie
   beq .checkWordZapperObstacleCollisions
   dec shotTallyForFreebie          ; decrement shots needed for Freebie
.checkWordZapperObstacleCollisions
   lda CXPPMM                       ; get player and missile collision values
   and #$80                         ; keep player collision value
   bne .playerObjectsCollided       ; branch if players collided
   jmp .decrementLetterLaserTimer
       
.playerObjectsCollided
   ldx #KERNEL_SECTIONS - 1
.determineCollisionSection
   lda wordZapperVertPos            ; get Word Zapper vertical position
   sec
   sbc obstacleVertPos,x            ; subtract obstacle vertical position
   cmp #12
   bcc .playerCollidedWithObstacle
   cmp #<-10
   bcs .playerCollidedWithObstacle
   dex
   bpl .determineCollisionSection
   bmi .decrementLetterLaserTimer   ; unconditional branch
       
.playerCollidedWithObstacle
   lda obstacleGraphicLSBValues,x   ; get obstacle graphic LSB value
   cmp #$80
   bcs .decrementLetterLaserTimer   ; branch if exploding obstacle
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   sec
   sbc obstacleHorizPos,x           ; subtract obstacle horizontal position
   cmp #7
   bcc .determineTypeOfCollidedObstacle
   cmp #<-15
   bcc .decrementLetterLaserTimer
.determineTypeOfCollidedObstacle
   jsr DetermineCollisionObstacle
   beq PlayerCollidedWithDoomsday
   bcs PlayerCollidedWithScroller
   lda obstacleVelocityValues,x     ; get obstacle velocity value
   asl                              ; obstacle direction to carry
   bcs .bumpWordZapperLeft          ; branch if obstacle traveling left
   asl
   asl
   asl
   adc wordZapperHorizPos           ; increment Word Zapper horizontal position
   jmp .setBumpedWordZapperHorizPosition
       
.bumpWordZapperLeft
   lda obstacleVelocityValues,x     ; get obstacle velocity value
   eor #$FF
   clc
   adc #1                           ; get obstacle velocity absolute value
   asl                              ; multiply value by 16
   asl
   asl
   asl
   ldx wordZapperHorizPos           ; get Word Zapper horizontal position
   sta wordZapperHorizPos
   txa
   sec
   sbc wordZapperHorizPos           ; move Word Zapper left
   bcs .setBumpedWordZapperHorizPosition
   lda #XMIN - 3
.setBumpedWordZapperHorizPosition
   sta wordZapperHorizPos
   lda #BONKER_COLLISION_AUDIO_IDX  ; assume collision with Bonker
   cpy #<[BonkerSprites] >> 5
   beq .setBumpedWordZapperAudioIndex;branch to play Bonker collision sounds
   lda #ZONKER_COLLISION_AUDIO_IDX  ; set to play Zonker collision sounds
.setBumpedWordZapperAudioIndex
   tay                              ; move audio index to y register
   jsr SetGameAudioValues           ; set audio values for collision
   jmp .decrementLetterLaserTimer
       
PlayerCollidedWithDoomsday
   ldy #EXPLOSION_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for explosion
   jsr SetGameAudioValues
   lda #<DestroyedObstacle_00
   sta destroyedWordZapperGraphicLSB
   bne .decrementLetterLaserTimer   ; unconditional branch
       
PlayerCollidedWithScroller
   ldy #SCROLLER_COLLISION_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for Scroller collision
   lda #INIT_SCROLLER_ALPHABET_SCRAMBLE_TIME
   sta scrollerAlphabetScrambleTimer; set timer value for scrambling alphabet
.decrementLetterLaserTimer
   ldy letterLaserActiveTimer       ; get Letter Laser timer value
   beq CheckToLaunchLetterLaser     ; branch if Letter Laser inactive
   dey                              ; decrement Letter Laser timer
   sty letterLaserActiveTimer
   cpy #[INIT_LETTER_LASER_TIME / 2]
   bcs .flashLetterLaser
   jmp CheckToRemoveLetterFromScrollArea
       
.flashLetterLaser
   cpy #INIT_LETTER_LASER_TIME - 1
   beq .activateLetterLaser
   cpy #INIT_LETTER_LASER_TIME - 5
   beq .activateLetterLaser
   cpy #INIT_LETTER_LASER_TIME - 10
   beq .activateLetterLaser
   bne AnimateLetterExplosion       ; unconditional branch
       
CheckToLaunchLetterLaser
   lda #8
   ldx activePlayerNumber           ; get active player number
   beq .checkToLaunchLetterLaser    ; branch if player 1 active
   lsr                              ; shift to check player 2 action button
.checkToLaunchLetterLaser
   and actionButtonValues
   beq .doneAnimateLetterExplosion  ; branch if action button not depressed
   ldy #LAUNCH_LETTER_LASER_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for Letter Laser
   lda #INIT_LETTER_LASER_TIME
   sta letterLaserActiveTimer
   tay
   lda #<-1
   sta letterLaserLetterIndex
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   cmp #XMIN_WORD_ZAPPER + 20
   bcc .activateLetterLaser
   cmp #XMAX_WORD_ZAPPER - 37
   bcs .activateLetterLaser
   clc                              ; not needed...carry cleared with compare
   adc #(W_WORD_ZAPPER / 2) + 4     ; center of Word Zapper plus center of font
   sec
   sbc scrollAreaHorizPos           ; subtract scroll area horizontal position
   lsr                              ; divide value by 16
   lsr
   lsr
   lsr
   tax                              ; set index for letter
   lda scrollAreaDataValues,x       ; get character shot by Letter Laser
   cmp #<[(_Blank / 2) + 42]
   beq .activateLetterLaser         ; branch if Blank
   stx letterLaserLetterIndex
   ldx targetLetterIndex            ; get target letter index value
   cmp #<[(_Freebie / 2) + 42]
   bne .checkIfShotTargetLetter     ; branch if not a Freebie
   lda #INIT_SHOTS_FOR_FREEBIE
   sta shotTallyForFreebie          ; shot Freebie...reset shot tally
   bne .shotTargetLetter            ; unconditional branch
   
.checkIfShotTargetLetter
   cmp targetLetters,x              ; compare with target letter
   bne .activateLetterLaser         ; branch if not target letter
.shotTargetLetter
   txa                              ; move target letter index to accumulator
   ora #$80                         ; set D7
   sta targetLetterIndex
   sty tmpLetterLaserActiveTimer
   ldy #SHOT_TARGET_LETTER_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for target letter
   ldy tmpLetterLaserActiveTimer    ; restore Letter Laser active timer
.activateLetterLaser
   lda #$18
   sta wordZapperGraphicValue       ; set graphic for Letter Laser
AnimateLetterExplosion
   ldx #<[(_LetterExplosion_00 / 2) + 42];set to beginning of letter explosion
   cpy #INIT_LETTER_LASER_TIME - 10
   bcc .animateLetterExplosionForward
   inx                              ; set to point to LetterExplosionSprite_01
   cpy #INIT_LETTER_LASER_TIME - 5
   bcc .animateLetterExplosionForward
   inx                              ; set to point to LetterExplosionSprite_02
.animateLetterExplosionForward
   tya                              ; Letter Laser timer value in accumulator
   ror
   ror                              ; shift D1 to carry
   txa                              ; move letter explosion to accumulator
   adc #1 - 1
   ldx letterLaserLetterIndex
   cpx #<-1
   beq .doneAnimateLetterExplosion
   sta scrollAreaDataValues,x       ; place letter explosion in scroll area
.doneAnimateLetterExplosion
   jmp CheckToLaunchWordZapperMissile

CheckToRemoveLetterFromScrollArea
   cpy #INIT_LETTER_LASER_TIME - 16
   bcc .checkToMoveTargetLetterToWordArea
   ldx letterLaserLetterIndex
   lda #<[(_Blank / 2) + 42]
   sta scrollAreaDataValues,x
   ldx targetLetterIndex            ; get target letter index value
   bmi .doneCheckToRemoveLetterFromScrollArea;branch if shot target letter
   lda #0
   sta letterLaserActiveTimer
.doneCheckToRemoveLetterFromScrollArea
   jmp CheckToLaunchWordZapperMissile

.checkToMoveTargetLetterToWordArea
   lda targetLetterIndex            ; get target letter index value
   and #$7F                         ; clear D7 value
   sta targetLetterIndex
   cpy #0
   bne .animateTargetLetterInWordArea;branch if Letter Laser timer not expired
   ldx targetLetterIndex            ; get target letter index value
   lda targetLetters,x              ; get target letter value
   sta wordAreaDataValues,x         ; place target letter in word area
   inc targetLetterIndex            ; increment target letter index value
   ldx #6
.checkForCompletedTargets
   lda targetLetters,x              ; get target letter value
   cmp #<[(_Blank / 2) + 42]
   beq .nextIndexForCompletedTargets; branch if removed
   cmp wordAreaDataValues,x
   bne CheckToLaunchWordZapperMissile
.nextIndexForCompletedTargets
   dex
   bpl .checkForCompletedTargets
   ldx #5
.moveTargetLettersToWordArea
   lda targetLetters,x              ; get target letter value
   cmp #<[(_Freebie / 2) + 42]
   bne .placeTargetLetterInWordArea ; branch if not a Freebie
   lda #<[(_Blank / 2) + 42]
.placeTargetLetterInWordArea 
   sta wordAreaDataValues,x
   dex
   bpl .moveTargetLettersToWordArea
   inc gameState
   ldy #COMPLETED_WORD_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for completed word
   dec currentRound                 ; decrement current round number
   bpl .donePlaceTargetLetterInWordArea;branch if not completed all rounds
   ldy #GAME_WON_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for winning game
   jsr SetGameAudioValues
   lda #4
   sta leftChannelFrequencyValue
   lda #$F8
   sta leftChannelVolumeValue
.donePlaceTargetLetterInWordArea
   jmp .setCurrentGameTimerValue

.animateTargetLetterInWordArea
   ldx #<[(_LetterExplosion_02 / 2) + 42]
   cpy #INIT_LETTER_LASER_TIME - 25
   bcc .animateLetterExplosionBackwards
   dex                              ; set to point to LetterExplosionSprite_01
   cpy #INIT_LETTER_LASER_TIME - 20
   bcc .animateLetterExplosionBackwards
   dex                              ; set to point to LetterExplosionSprite_00
.animateLetterExplosionBackwards
   tya                              ; Letter Laser timer value in accumulator
   ror
   ror                              ; shift D1 to carry
   txa                              ; move letter explosion to accumulator
   adc #1 - 1
   ldx targetLetterIndex            ; get target letter index value
   sta wordAreaDataValues,x
CheckToLaunchWordZapperMissile
   lda wordZapperMissileVertPos     ; get Word Zapper missile vertical position
   bne CheckForPlayerMovingWordZapper;branch if missile active
   lda #2
   ldx activePlayerNumber           ; get active player number
   beq .checkMissileActionButtonPressed;branch if player 1 active
   lsr                              ; shift to check player 2 action button
.checkMissileActionButtonPressed
   and actionButtonValues
   bne CheckForPlayerMovingWordZapper;branch if not launching missile
   lda previousJoystickValues       ; get joystick values
   ldx activePlayerNumber           ; get active player number
   beq .checkToLaunchWordZapperMissile;branch if player 1 active
   asl                              ; shift player 2 joystck values
   asl
   asl
   asl
.checkToLaunchWordZapperMissile
   and #<~(MOVE_RIGHT & MOVE_LEFT)
   eor #<~(MOVE_RIGHT & MOVE_LEFT)
   beq CheckForPlayerMovingWordZapper;branch if not moving horizontally
   pha                              ; push directional values to stack
   ldy #LAUNCH_MISSILE_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for launching missile
   pla                              ; pull directional values from stack
   cmp #<~MOVE_LEFT
   beq .launchLeftTravelingMissile  ; branch if moving joystick left
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   cmp #XMAX_WORD_ZAPPER - 6
   bcs CheckForPlayerMovingWordZapper
   clc                              ; carry already clear
   adc #16                          ; place 16 pixels right of Word Zapper
   ora #1
   bne .setWordZapperMissileHorizPosition;unconditional branch
       
.launchLeftTravelingMissile
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   cmp #XMIN_WORD_ZAPPER + 7
   bcc CheckForPlayerMovingWordZapper
   sbc #6                           ; place 6 pixels left of Word Zapper
   and #$FE
.setWordZapperMissileHorizPosition
   sta wordZapperMissileHorizPos
   lda wordZapperVertPos            ; get Word Zapper vertical position
   sec
   sbc #H_WORD_ZAPPER  + 1
   ora #1
   sta wordZapperMissileVertPos
CheckForPlayerMovingWordZapper
   jsr PlaceTimerInDisplayArea
   lda previousJoystickValues       ; get joystick values
   ldx activePlayerNumber           ; get active player number
   beq .checkJoystickPushedRight    ; branch if player 1 active
   asl                              ; shift player 2 joystck values
   asl
   asl
   asl
.checkJoystickPushedRight
   tax                              ; move joystick values to x register
   and #<~MOVE_RIGHT
   bne .checkJoystickPushedLeft     ; branch if joystick not pushed right
   inc wordZapperHorizPos           ; move Word Zapper right
   inc wordZapperHorizPos
.checkJoystickPushedLeft
   txa                              ; move joystick values to accumulator
   and #<~MOVE_LEFT
   bne .checkJoystickPushedDown     ; branch if joystick not pushed left
   dec wordZapperHorizPos           ; move Word Zapper left
   dec wordZapperHorizPos
.checkJoystickPushedDown
   txa                              ; move joystick values to accumulator
   and #<~MOVE_DOWN
   bne .checkJoystickPushedUp       ; branch if joystick not pushed down
   dec wordZapperVertPos            ; move Word Zapper down
   dec wordZapperVertPos
.checkJoystickPushedUp
   txa                              ; move joystick values to accumulator
   and #<~MOVE_UP
   bne .checkGameTimerForExpiration ; branch if joystick not pushed up
   inc wordZapperVertPos            ; move Word Zapper up
   inc wordZapperVertPos
.checkGameTimerForExpiration
   lda currentGameTimer             ; get current game timer value
   bne .moveWordZapperMissile       ;branch if game timer not expired
   lda #GS_WORD_ZAPPER_LANDING
   sta gameState
   ldy #TIMER_EXPIRED_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for timer expired
.setCurrentGameTimerValue
   ldx activePlayerNumber           ; get active player number
   lda currentGameTimer             ; get current game timer value
   sta playerGamerTimerValues,x
.moveWordZapperMissile
   jmp MoveWordZapperMissile

TargetLettersDoneMoveRight
   lda #ULTRAMARINE_BLUE + 2
   sta COLUBK
   lda currentRound                 ; get current round number
   bpl .moveWordZapperRight         ; branch if not completed all game rounds
   lda random                       ; get current random value
   and #5
   bne .moveWordZapperRight         ; branch if not flashing background
   lda #WHITE
   sta COLUBK
.moveWordZapperRight
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   clc
   adc #3                           ; increment by 3
   cmp #XMAX_WORD_ZAPPER - 15
   bcs .doneTargetLettersDoneMoveRight
   sta wordZapperHorizPos           ; set Word Zapper horizontal position
   jmp MoveWordZapperMissile
       
.doneTargetLettersDoneMoveRight
   jmp StepToNextGameState

TargetLettersDoneMoveLeft
   lda #ULTRAMARINE_BLUE + 2
   sta COLUBK
   lda currentRound                 ; get current round number
   bpl .moveWordZapperLeft          ; branch if not completed all game rounds
   lda random                       ; get current random value
   and #9
   bne .moveWordZapperLeft          ; branch if not flashing background
   lda #WHITE
   sta COLUBK
.moveWordZapperLeft 
   lda wordZapperHorizPos           ; get Word Zapper horizontal position
   sec
   sbc #3
   cmp #XMIN_WORD_ZAPPER + 15
   bcc .doneTargetLettersDoneMoveLeft
   sta wordZapperHorizPos           ; set Word Zapper horizontal position
   jmp MoveWordZapperMissile
       
.doneTargetLettersDoneMoveLeft
   jmp StepToNextGameState

CheckToSwitchToAlternatePlayer
   lda #HORIZ_POS_TIMER_AREA
   sta scrollAreaHorizPos
   lda currentRound                 ; get current round number
   cmp #GAME_ROUNDS_DONE
   bne .switchToAlternatePlayer     ; branch if game round not done
   lda #GS_SET_GAME_SELECTION_LITERALS
   bne .setNewGameStateValue        ; set game state to show game selection
       
.switchToAlternatePlayer
   ldx activePlayerNumber           ; get active player number
   sta playerCorrectWordCount,x     ; set active player round number
   txa                              ; move active player number to accumulator
   eor #1                           ; flip D0 to alternate player number
   tax
   lda playerCorrectWordCount,x     ; get player correct word count value
   bmi .checkToClearMessageDataArea ; branch if alternate player done
   lda playerGamerTimerValues,x     ; get player game timer value
   beq .checkToClearMessageDataArea ; branch if timer expired
   stx activePlayerNumber
   bne .setCurrentRoundForActivePlayer;unconditional branch
   
.checkToClearMessageDataArea
   ldx activePlayerNumber           ; get active player number
   lda playerCorrectWordCount,x     ; get player correct word count value
   bmi ClearMessageDataArea
   lda playerGamerTimerValues,x     ; get player game timer value
   beq ClearMessageDataArea         ; branch if timer expired
.setCurrentRoundForActivePlayer
   lda playerCorrectWordCount,x     ; get player correct word count value
   sta currentRound                 ; set round number for current player
   lda #GS_NEW_ROUND
.setNewGameStateValue
   sta gameState
   jmp MoveWordZapperMissile
       
ClearMessageDataArea
   lda #<[(_Blank / 2) + 42]
   ldx #17
.clearMessageDataArea
   sta messageAreaDataValues,x
   dex
   bpl .clearMessageDataArea
   inx                              ; x = 0
   stx activePlayerNumber
   lda #2
   sta currentGameTimer
   jmp StepToNextGameState
       
DisplayPlayerScoreRanking
   ldx #5
   lda #<[(_Blank / 2) + 42]
.clearTimerArea
   sta timerAreaDataValues,x
   dex
   bpl .clearTimerArea
   ldx activePlayerNumber           ; get active player number
   lda playerGamerTimerValues,x     ; get player game timer value
   sta currentGameTimer
   jsr PlaceTimerInDisplayArea
   ldx activePlayerNumber           ; get active player number
   lda playerCorrectWordCount,x     ; get player correct word count value
   and #3                           ; keep word count value
   asl                              ; multiply value by 2
   sta tmpWordCountMulti2
   asl                              ; multiply value by 4
   clc
   adc tmpWordCountMulti2           ; add in multi 2 (i.e. multiply value by 6)
   tay
   ldx #5
.setScoreRankingLiteral
   lda ScoreRankingLiterals,y       ; get score ranking literal
   sta scrollAreaDataValues,x       ; place in scroll area
   iny
   dex
   bpl .setScoreRankingLiteral
   lda #2
   sta currentGameTimer
   lda tvTypeSwitchValue            ; get TV Type switch value
   and #BW_MASK
   bne StepToNextGameState          ; branch if not set to B/W
   lda activePlayerNumber           ; get active player number
   eor #1                           ; flip D0 to alternate player number
   sta activePlayerNumber
   bpl StepToNextGameState          ; unconditional branch
       
WordZapperLandingRoutine
   lda #ULTRAMARINE_BLUE + 2
   sta COLUBK
   ldx wordZapperHorizPos           ; get Word Zapper horizontal position
   cpx #WORD_ZAPPER_LANDING_HORIZ_POS
   beq .landWordZapper
   bcs .moveLandingWordZapperLeft
   inx                              ; increment Word Zapper horizontal position
   bcc .setLandingWordZapperHorizPos; unconditional branch
   
.moveLandingWordZapperLeft
   dex                              ; decrement Word Zapper horizontal position
.setLandingWordZapperHorizPos
   stx wordZapperHorizPos
   jmp MoveWordZapperMissile
       
.landWordZapper
   ldy wordZapperVertPos            ; get Word Zapper vertical position
   cpy #WORD_ZAPPER_LANDING_VERT_POS
   beq .wordZapperLanded
   dec wordZapperVertPos
   jmp MoveWordZapperMissile
       
.wordZapperLanded
   ldy #WORD_ZAPPER_LANDED_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for landing Word Zapper
StepToNextGameState
   inc gameState
   jmp MoveWordZapperMissile
       
SetGameStateToDisplayScoreRanking
   lda #GS_DISPLAY_SCORE_RANKING
   sta gameState
MoveWordZapperMissile SUBROUTINE
   lda wordZapperMissileVertPos     ; get Word Zapper missile vertical position
   beq NewFrame                     ; branch if missile not active
   lda wordZapperMissileHorizPos    ; get missile horizontal position
   tax                              ; move horizontal position to x register
   and #1                           ; keep D0 value
   beq .moveWordZapperMissileLeft   ; branch if missile traveling left
   txa                              ; get missile horizontal position
   clc
   adc #MISSILE_SPEED_VALUE         ; increment by MISSILE_SPEED_VALUE
   cmp #XMAX
   bcc .setWordZapperMissileHorizPosition;branch if not reached right side
   jmp .inactivateWordZapperMissile
       
.moveWordZapperMissileLeft
   txa                              ; get missile horizontal position
   sec
   sbc #MISSILE_SPEED_VALUE         ; decrement by MISSILE_SPEED_VALUE
   cmp #XMIN
   bcs .setWordZapperMissileHorizPosition;branch if not reached left side
.inactivateWordZapperMissile
   lda #0
   sta wordZapperMissileVertPos
.setWordZapperMissileHorizPosition
   sta wordZapperMissileHorizPos
NewFrame
.waitTime
   lda INTIM
   bne .waitTime
   lda #START_VERT_SYNC
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; start vertical sync (D1 = 1)
   lda #VSYNC_TIME
   sta TIM8T
   ldx frameSecondsCount            ; get frame seconds count
   inx                              ; increment frame seconds
   cpx #60                          ; missed in the PAL50 conversion
   bcc .setFrameSecondsCount
   ldx #0
   lda obstacleSpawningTimer        ; get obstacle spawning timer
   beq .decrementScrollerAlphabetScrambleTimer;branch if spawning timer done
   dec obstacleSpawningTimer
.decrementScrollerAlphabetScrambleTimer
   lda scrollerAlphabetScrambleTimer;get Scroller alphabet scramble timer
   beq .decrementGameTimer          ; branch if alphabet scramble timer done
   dec scrollerAlphabetScrambleTimer
.decrementGameTimer
   dec gameIdleTimer                ; decrement game idle timer
   lda currentGameTimer             ; get current game timer value
   beq .setFrameSecondsCount        ;branch if game timer expired
   sed
   clc
   sbc #1 - 1                       ; reduce game timer value
   sta currentGameTimer
   cld
.setFrameSecondsCount
   stx frameSecondsCount
.vsyncWaitTime
   lda INTIM
   bne .vsyncWaitTime
   jmp VerticalBlank
       
CommonEnglishLetters
E
   CHAR_SET_OFFSET _E
T
   CHAR_SET_OFFSET _T
O
   CHAR_SET_OFFSET _O
A
   CHAR_SET_OFFSET _A
I
   CHAR_SET_OFFSET _I
N
   CHAR_SET_OFFSET _N
S
   CHAR_SET_OFFSET _S
H
   CHAR_SET_OFFSET _H
R
   CHAR_SET_OFFSET _R
D
   CHAR_SET_OFFSET _D
L
   CHAR_SET_OFFSET _L
U
   CHAR_SET_OFFSET _U
P
   CHAR_SET_OFFSET _P
F
   CHAR_SET_OFFSET _F
M
   CHAR_SET_OFFSET _M
C
   CHAR_SET_OFFSET _C

EnglishWordLibrary
   COMPRESS_FOUR_LETTER_WORD L, A, S, T
   COMPRESS_FOUR_LETTER_WORD D, U, S, T
   COMPRESS_FOUR_LETTER_WORD R, A, I, N
   COMPRESS_FOUR_LETTER_WORD S, H, E, D
   COMPRESS_FOUR_LETTER_WORD F, A, S, T
   COMPRESS_FOUR_LETTER_WORD F, O, U, R
   COMPRESS_FOUR_LETTER_WORD M, A, R, S
   COMPRESS_FOUR_LETTER_WORD P, O, O, F
   COMPRESS_FOUR_LETTER_WORD S, T, A, R
   COMPRESS_FOUR_LETTER_WORD M, O, O, N
   COMPRESS_FOUR_LETTER_WORD S, H, I, P
   COMPRESS_FOUR_LETTER_WORD F, I, R, E
   COMPRESS_FOUR_LETTER_WORD S, H, O, T
   COMPRESS_FOUR_LETTER_WORD T, H, E, M
   COMPRESS_FOUR_LETTER_WORD T, I, M, E
   COMPRESS_FOUR_LETTER_WORD L, A, N, D

FiveCharacterWords
   COMPRESS_FIVE_LETTER_WORD S, A, U, C, E
   COMPRESS_FIVE_LETTER_WORD S, P, A, C, E
   COMPRESS_FIVE_LETTER_WORD S, P, E, L, L
   COMPRESS_FIVE_LETTER_WORD F, L, A, S, H
   COMPRESS_FIVE_LETTER_WORD L, A, S, E, R
   COMPRESS_FIVE_LETTER_WORD S, H, O, O, T
   COMPRESS_FIVE_LETTER_WORD T, I, M, E, R
   COMPRESS_FIVE_LETTER_WORD R, E, S, E, T
   COMPRESS_FIVE_LETTER_WORD C, O, L, O, R
   COMPRESS_FIVE_LETTER_WORD S, U, P, E, R
   COMPRESS_FIVE_LETTER_WORD C, O, U, N, T
   COMPRESS_FIVE_LETTER_WORD F, L, A, M, E
   COMPRESS_FIVE_LETTER_WORD S, P, A, C, E
   COMPRESS_FIVE_LETTER_WORD A, L, I, E, N
   COMPRESS_FIVE_LETTER_WORD S, O, U, N, D
   COMPRESS_FIVE_LETTER_WORD T, H, R, E, E

SixCharacterWords
   COMPRESS_SIX_LETTER_WORD S, A, U, C, E, R
   COMPRESS_SIX_LETTER_WORD M, E, T, E, O, R
   COMPRESS_SIX_LETTER_WORD R, A, N, D, O, M
   COMPRESS_SIX_LETTER_WORD L, E, T, T, E, R
   COMPRESS_SIX_LETTER_WORD S, E, L, E, C, T   
   COMPRESS_SIX_LETTER_WORD S, T, R, I, P, E
   COMPRESS_SIX_LETTER_WORD P, L, E, A, S, E   
   COMPRESS_SIX_LETTER_WORD A, C, T, I, O, N   
   COMPRESS_SIX_LETTER_WORD P, U, F, F, E, R   
   COMPRESS_SIX_LETTER_WORD S, C, R, E, E, N
   COMPRESS_SIX_LETTER_WORD S, C, R, O, L, L   
   COMPRESS_SIX_LETTER_WORD U, N, S, A, F, E   
   COMPRESS_SIX_LETTER_WORD R, O, T, A, T, E
   COMPRESS_SIX_LETTER_WORD N, E, T, H, E, R   
   COMPRESS_SIX_LETTER_WORD M, A, N, U, A, L   
   COMPRESS_SIX_LETTER_WORD D, I, R, E, C, T
   
MountainGraphics
   .hex FFFFFFFFFFFF          ; |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|
   .hex DFFFF03FFF30          ; |XX.XXXXXXXXXXXXXXXXX......XXXXXXXXXXXXXX..XX....|
   .hex DFFFE01F7F30          ; |XX.XXXXXXXXXXXXXXXX........XXXXX.XXXXXXX..XX....|
   .hex CFFFC00F3F30          ; |XX..XXXXXXXXXXXXXX..........XXXX..XXXXXX..XX....|
   .hex C77F000F1F30          ; |XX...XXX.XXXXXXX............XXXX...XXXXX..XX....|
   .hex C703000F0F30          ; |XX...XXX......XX............XXXX....XXXX..XX....|
   .hex C70100070F30          ; |XX...XXX.......X.............XXX....XXXX..XX....|
   .hex C30100070F30          ; |XX....XX.......X.............XXX....XXXX..XX....|
   .hex C10000030730          ; |XX.....X......................XX.....XXX..XX....|
   .hex C10000010730          ; |XX.....X.......................X.....XXX..XX....|
       
WordZapperAnimationSprites
   .word WordZapper_00, WordZapper_00
   .word WordZapper_01, WordZapper_02

WordZapperSprites
Freebie
WordZapper_00
   .byte $80 ; |X.......|
   .byte $BC ; |X.XXXX..|
   .byte $E6 ; |XXX..XX.|
   .byte $7F ; |.XXXXXXX|
   .byte $19 ; |...XX..X|
   .byte $25 ; |..X..X.X|
   .byte $00 ; |........|
WordZapper_01
   .byte $01 ; |.......X|
   .byte $3D ; |..XXXX.X|
   .byte $67 ; |.XX..XXX|
   .byte $FE ; |XXXXXXX.|
   .byte $98 ; |X..XX...|
   .byte $A4 ; |X.X..X..|
   .byte $00 ; |........|
WordZapper_02
   .byte $19 ; |...XX..X|
   .byte $3D ; |..XXXX.X|
   .byte $67 ; |.XX..XXX|
   .byte $FE ; |XXXXXXX.|
   .byte $98 ; |X..XX...|
   .byte $A4 ; |X.X..X..|
   .byte $00 ; |........|

WordZapperAnimationColors
   .word WordZapperColor_00, WordZapperColor_01
   .word WordZapperColor_02, WordZapperColor_03

WordZapperColors
WordZapperColor_00
   .byte GREEN + 10, OLIVE_GREEN + 8, OLIVE_GREEN + 8
   .byte OLIVE_GREEN + 14, OLIVE_GREEN + 8, COBALT_BLUE + 14
WordZapperColor_01
   .byte GREEN + 10, OLIVE_GREEN + 8, OLIVE_GREEN + 8
   .byte OLIVE_GREEN + 12, OLIVE_GREEN + 8, COBALT_BLUE + 14
WordZapperColor_02
   .byte GREEN + 10, OLIVE_GREEN + 8, OLIVE_GREEN + 8
   .byte OLIVE_GREEN + 10, OLIVE_GREEN + 8, COBALT_BLUE + 14
WordZapperColor_03
   .byte GREEN + 14, OLIVE_GREEN + 8, OLIVE_GREEN + 8
   .byte OLIVE_GREEN + 12, OLIVE_GREEN + 8, COBALT_BLUE + 14
   
GameSelectionLiterals
   BYTE_STRING _G, _A, _M, _E, _Blank, _Blank
   BYTE_STRING _Blank, _Blank, _Blank, _Blank, _Blank, _Blank
   BYTE_STRING _Blank, _Blank, _Blank, _Blank, _Blank, _Blank
   
GameTitleLiterals
   BYTE_STRING _Blank, _W, _O, _R, _D, _Blank
   BYTE_STRING _Z, _A, _P, _P, _E, _R
   BYTE_STRING _Blank, _Blank, _Blank, _Blank, _Blank, _Blank

ScoreRankingLiterals
   BYTE_STRING _Blank, _Blank, _Blank, _E, _C, _A
   BYTE_STRING _Blank, _P, _M, _A, _H, _C
   BYTE_STRING _E, _I, _K, _O, _O, _R
   BYTE_STRING _R, _E, _P, _P, _A, _Z

KernelZoneValues
   .byte 44, 69, 94, 119
   
   .byte $A4,$85,$C1,$A0            ; unused bytes

   BOUNDARY 0
   
ObstacleSprites
BonkerSprites
Bonker_00
   .byte $08 ; |....X...|
   .byte $0C ; |....XX..|
   .byte $20 ; |..X.....|
   .byte $63 ; |.XX...XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
Bonker_01
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $40 ; |.X......|
   .byte $61 ; |.XX....X|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
Bonker_02
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   .byte $60 ; |.XX.....|
   .byte $42 ; |.X....X.|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
Bonker_03
   .byte $04 ; |.....X..|
   .byte $0C ; |....XX..|
   .byte $60 ; |.XX.....|
   .byte $23 ; |..X...XX|
   .byte $02 ; |......X.|
   .byte $00 ; |........|

DestroyedObstacleColor_00
   .byte BRICK_RED + 14, BRICK_RED + 14, BRICK_RED + 14
   .byte BRICK_RED + 14, BRICK_RED + 14, BRICK_RED + 14
   
   BOUNDARY 16

ZonkerSprites
Zonkers_00
   .byte $22 ; |..X...X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
Zonkers_01
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $22 ; |..X...X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
Zonkers_02
   .byte $22 ; |..X...X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $22 ; |..X...X.|
   .byte $00 ; |........|
Zonkers_03
   .byte $08 ; |....X...|
   .byte $14 ; |...X.X..|
   .byte $22 ; |..X...X.|
   .byte $14 ; |...X.X..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   
DestroyedObstacleColor_01
   .byte BRICK_RED + 14, BRICK_RED + 14, BRICK_RED + 14
   .byte BRICK_RED + 14, BRICK_RED + 14, GREEN + 12
   
   .byte $A0,$A4                    ; unused bytes
   
   BOUNDARY 32
   
DoomsdaySprites
Doomsday_00
   .byte $07 ; |.....XXX|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $0E ; |....XXX.|
   .byte $07 ; |.....XXX|
   .byte $00 ; |........|
Doomsday_01
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $EE ; |XXX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
Doomsday_02
   .byte $E0 ; |XXX.....|
   .byte $70 ; |.XXX....|
   .byte $38 ; |..XXX...|
   .byte $70 ; |.XXX....|
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
Doomsday_03
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $77 ; |.XXX.XXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   
DestroyedObstacleColor_02
   .byte BRICK_RED + 14, BRICK_RED + 14, ULTRAMARINE_BLUE + 2
   .byte BRICK_RED + 14, BRICK_RED + 14, CYAN
   
   .byte $92,$A0                    ; unused bytes

   BOUNDARY 32
   
ScrollerSprites
Scrollers_00
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
Scrollers_01
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
Scrollers_02
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
Scrollers_03
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|

DestroyedObstacleColor_03
   .byte BRICK_RED + 14, ULTRAMARINE_BLUE + 2, BRICK_RED + 14
   .byte ULTRAMARINE_BLUE + 2, BRICK_RED + 14, LT_BROWN + 8
   
   .byte $AC,$A0                    ; unused bytes

   BOUNDARY 32
   
ObstacleColors
BonkerColors
BonkerColor_00
   .byte LT_BROWN + 10, LT_BROWN + 8, LT_BROWN + 8
   .byte LT_BROWN + 8, LT_BROWN + 10, BLACK
BonkerColor_01
   .byte LT_BROWN + 10, LT_BROWN + 8, LT_BROWN + 8
   .byte LT_BROWN + 8, LT_BROWN + 10, BLACK
BonkerColor_02
   .byte LT_BROWN + 10, LT_BROWN + 8, LT_BROWN + 8
   .byte LT_BROWN + 8, LT_BROWN + 10, BLACK
BonkerColor_03
   .byte LT_BROWN + 10, LT_BROWN + 8, LT_BROWN + 8
   .byte LT_BROWN + 8, LT_BROWN + 10, BLACK
   
DestroyedObstacle_00
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $C3 ; |XX....XX|
   .byte $00 ; |........|
   
   .byte $B2,$A0                    ; unused bytes
   
   BOUNDARY 32
   
ZonkerColors
ZonkerColor_00
   .byte OLIVE_GREEN + 6, YELLOW + 8, OLIVE_GREEN + 6
   .byte YELLOW + 8, OLIVE_GREEN + 6, BLACK
ZonkerColor_01
   .byte YELLOW + 8, OLIVE_GREEN + 6, YELLOW + 8
   .byte OLIVE_GREEN + 6, YELLOW + 8, BLACK
ZonkerColor_02
   .byte YELLOW + 8, OLIVE_GREEN + 6, YELLOW + 8
   .byte OLIVE_GREEN + 6, YELLOW + 8, BLACK
ZonkerColor_03
   .byte OLIVE_GREEN + 6, YELLOW + 8, OLIVE_GREEN + 6
   .byte YELLOW + 8, OLIVE_GREEN + 6, BLACK

DestroyedObstacle_01
   .byte $81 ; |X......X|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   
   .byte $C1,$A0                    ; unused bytes
   
   BOUNDARY 32
   
DoomsdayColors
DoomsdayColor_00
   .byte BRICK_RED + 4, BRICK_RED + 4, BRICK_RED + 4
   .byte BRICK_RED + 4, BRICK_RED + 4, BLACK
DoomsdayColor_01
   .byte BRICK_RED + 4, BRICK_RED + 4, BRICK_RED + 4
   .byte BRICK_RED + 4, BRICK_RED + 4, BLACK
DoomsdayColor_02
   .byte BRICK_RED + 8, BRICK_RED + 8, BRICK_RED + 8
   .byte BRICK_RED + 8, BRICK_RED + 8, BLACK
DoomsdayColor_03
   .byte BRICK_RED + 8, BRICK_RED + 8, BRICK_RED + 8
   .byte BRICK_RED + 8, BRICK_RED + 8, BLACK

DestroyedObstacle_02
   .byte $24 ; |..X..X..|
   .byte $81 ; |X......X|
   .byte $40 ; |.X......|
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   
   .byte $A4,$97                    ; unused bytes
   
   BOUNDARY 32

ScrollerColors
ScrollerColor_00
   .byte BROWN + 2, BROWN + 6, BROWN + 8
   .byte BROWN + 6, BROWN + 4, BLACK
ScrollerColor_01
   .byte BROWN + 4, BROWN + 2, BROWN + 6
   .byte BROWN + 8, BROWN + 6, BLACK
ScrollerColor_02
   .byte BROWN + 6, BROWN + 4, BROWN + 2
   .byte BROWN + 6, BROWN + 8, BLACK
ScrollerColor_03
   .byte BROWN + 8, BROWN + 6, BROWN + 4
   .byte BROWN + 2, BROWN + 6, BLACK
   
DestroyedObstacle_03
   .byte $42 ; |.X....X.| $FBF8
   .byte $80 ; |X.......| $FBF9
   .byte $81 ; |X......X| $FBFA
   .byte $01 ; |.......X| $FBFB
   .byte $42 ; |.X....X.| $FBFC
   .byte $00 ; |........| $FBFD
   
   .byte $A0,$A0                    ; unused bytes
   
   BOUNDARY 0
       
CharacterSet
_LetterExplosion_00
   .word LetterExplosionSprite_00
_LetterExplosion_01
   .word LetterExplosionSprite_01
_LetterExplosion_02
   .word LetterExplosionSprite_02
_LetterExplosion_03
   .word LetterExplosionSprite_03
_QuestionMark
   .word QuestionMarkCharacter
_Blank
   .word Blank
_0
   .word Sprite_0
_1
   .word Sprite_1
_2
   .word Sprite_2
_3
   .word Sprite_3
_4
   .word Sprite_4
_5
   .word Sprite_5
_6
   .word Sprite_6
_7
   .word Sprite_7
_8
   .word Sprite_8
_9
   .word Sprite_9
_0x0A
   .word Sprite_A
_0x0B
   .word Sprite_B
_0x0C
   .word Sprite_C
_0x0D
   .word Sprite_D
_0x0E
   .word Sprite_E
_0x0F
   .word Sprite_F
_Freebie
   .word Freebie
_A
   .word Sprite_A
_B
   .word Sprite_B
_C
   .word Sprite_C
_D
   .word Sprite_D
_E
   .word Sprite_E
_F
   .word Sprite_F
_G
   .word Sprite_G
_H
   .word Sprite_H
_I
   .word Sprite_I
_J
   .word Sprite_J
_K
   .word Sprite_K
_L
   .word Sprite_L
_M
   .word Sprite_M
_N
   .word Sprite_N
_O
   .word Sprite_O
_P
   .word Sprite_P
_Q
   .word Sprite_Q
_R
   .word Sprite_R
_S
   .word Sprite_S
_T
   .word Sprite_T
_U
   .word Sprite_U
_V
   .word Sprite_V
_W
   .word Sprite_W
_X
   .word Sprite_X
_Y
   .word Sprite_Y
_Z
   .word Sprite_Z

LetterExplosionSprites
LetterExplosionSprite_00
   .byte $40 ; |.X......|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $05 ; |.....X.X|
   .byte $80 ; |X.......|
   .byte $11 ; |...X...X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $08 ; |....X...|
LetterExplosionSprite_01
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
   .byte $21 ; |..X....X|
   .byte $00 ; |........|
   .byte $48 ; |.X..X...|
   .byte $02 ; |......X.|
   .byte $80 ; |X.......|
   .byte $04 ; |.....X..|
   .byte $20 ; |..X.....|
   .byte $09 ; |....X..X|
   .byte $00 ; |........|
   .byte $84 ; |X....X..|
   .byte $40 ; |.X......|
LetterExplosionSprite_02
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $06 ; |.....XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $63 ; |.XX...XX|
   .byte $03 ; |......XX|
   .byte $30 ; |..XX....|
   .byte $36 ; |..XX.XX.|
   .byte $06 ; |.....XX.|
;
; last byte shared with table below
;
LetterExplosionSprite_03
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $CC ; |XX..XX..|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
   .byte $1B ; |...XX.XX|
   .byte $1B ; |...XX.XX|
Sprite_P
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_Z
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
;
; last byte shared with table below
;
Sprite_S
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
Sprite_Y
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
;
; last 2 bytes shared with table below
;
Sprite_X
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
;
; last byte shared with table below
;
Sprite_K
   .byte $C3 ; |XX....XX|
   .byte $C7 ; |XX...XXX|
   .byte $CE ; |XX..XXX.|
   .byte $DC ; |XX.XXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $DC ; |XX.XXX..|
   .byte $CE ; |XX..XXX.|
   .byte $C7 ; |XX...XXX|
;
; last byte shared with table below
;
Sprite_R
   .byte $C3 ; |XX....XX|
   .byte $C7 ; |XX...XXX|
   .byte $CE ; |XX..XXX.|
   .byte $DC ; |XX.XXX..|
   .byte $F8 ; |XXXXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_B
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
       
.continueDetermineCollisionObstacle
   tay
   lda #0
   sta obstacleVertPos,x            ; remove collided obstacle
   sta obstacleHorizPos,x
   cpy #<[DoomsdaySprites] >> 5
   rts

   BOUNDARY 0
   
Sprite_D
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
Sprite_W
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
;
; last 3 bytes shared with table below
;
Sprite_M
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_U
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
;
; last 5 bytes shared with table below
;
Sprite_H
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
;
; last 4 bytes shared with table below
;
Sprite_A
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_O
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_G
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $CF ; |XX..XXXX|
   .byte $CF ; |XX..XXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_C
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
QuestionMarkCharacter
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $3E ; |..XXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
;
; last byte shared with table below
;
Sprite_I
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_J
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
Sprite_N
   .byte $C7 ; |XX...XXX|
   .byte $C7 ; |XX...XXX|
   .byte $C7 ; |XX...XXX|
   .byte $CF ; |XX..XXXX|
   .byte $CF ; |XX..XXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $FB ; |XXXXX.XX|
   .byte $F3 ; |XXXX..XX|
   .byte $F3 ; |XXXX..XX|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
Sprite_Q
   .byte $79 ; |.XXXX..X|
   .byte $FB ; |XXXXX.XX|
   .byte $F6 ; |XXXX.XX.|
   .byte $CC ; |XX..XX..|
   .byte $DA ; |XX.XX.X.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
Sprite_T
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
;
; last 3 bytes shared with table below
;
Sprite_L
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
;
; last 5 bytes shared with table below
;
Sprite_F
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
;
; last byte shared with table below
;
Sprite_E
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
Sprite_V
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
Sprite_1
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $78 ; |.XXXX...|
   .byte $38 ; |..XXX...|
;
; last byte shared with table below
;
Sprite_7
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
   .byte $43 ; |.X....XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
       
DetermineCollisionObstacle
   lda obstacleGraphicLSBValues,x   ; get obstacle graphic LSB value
   rol                              ; shift D6 and D5 to D1 and D0
   rol
   rol
   rol
   and #3
   jmp .continueDetermineCollisionObstacle

   BOUNDARY 0

Sprite_9
   .byte $60 ; |.XX.....|
   .byte $70 ; |.XXX....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $3E ; |..XXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_0
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_8
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_3
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1E ; |...XXXX.|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_5
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
;
; last 2 bytes shared with table below
;
Sprite_2
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $70 ; |.XXX....|
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $C3 ; |XX....XX|
   .byte $E7 ; |XXX..XXX|
   .byte $7E ; |.XXXXXX.|
;
; last byte shared with table below
;
Sprite_6
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0E ; |....XXX.|
;
; last byte shared with table below
;
Sprite_4
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $66 ; |.XX..XX.|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
PlayGameAudioSounds
   ldx #1
.playGameAudioSounds
   lda audioDurationValues,x        ; get audio duration value
   bne .determineAudioVolumeAndFrequency
   sta AUDC0,x                      ; set channel audio tone
   beq .nextAudioChannel            ; unconditional branch
       
.determineAudioVolumeAndFrequency
   dec audioDurationValues,x        ; decrement audio duration value
   dec audioVolumeDurationValues,x  ; decrement audio volume duration value
   bne .setAudioVolumeAndFrequency
   dec audioVolumeValues,x          ; decrement volume value
   lda initAudioVolumeDurationValues,x
   sta audioVolumeDurationValues,x  ; reseed audio volume duration
.setAudioVolumeAndFrequency
   lda audioVolumeValues,x          ; get channel volume value
   sta AUDV0,x                      ; set sound volume
   lda audioFrequencyValues,x       ; get channel audio frequency value
   clc
   adc audioFrequencyAdjustmentValues,x;increment by frequency adjustment value
   sta audioFrequencyValues,x       ; set channel audio frequency value
   sta AUDF0,x
.nextAudioChannel
   dex
   bpl .playGameAudioSounds
   rts

AudioValues
;
; Each audio value configuration uses 4 bytes arranged as...
; |------------|-----------|----------|--------|----------|
; | Frequency  |   Audio   |  Audio   |        |  Volume  |
; | Adjustment | Frequency | Duration |  Tone  | Duration |
; |------------|-----------|----------|--------|----------|
   .byte 253,         1,       159,    10 << 4 |     1
   .byte   8,         0,        64,     5 << 4 |     1
   .byte   1,         0,        31,     0 << 4 |     4
   .byte 228,       255,       111,     1 << 4 |     4
   .byte 254,        20,        79,     5 << 4 |     3
   .byte 252,       255,         7,     3 << 4 |     4
   .byte 252,       253,         5,     3 << 4 |    12
   .byte   4,        20,        66,     0 << 4 |    12   
   .byte   0,         3,       255,     1 << 4 |    12
   .byte   0,         1,        15,     1 << 4 |     1   
   .byte   0,        31,       144,     0 << 4 |     3   
   .byte 255,         0,        31,     0 << 4 |    15   
   .byte 255,       255,         8,     1 << 4 |    12   
   .byte   0,         2,        15,     1 << 4 |     7   
   .byte   1,        31,        31,     0 << 4 |     8   
   .byte  16,         1,        63,     4 << 4 |     4
          
StartObstacleEntranceMarch
   ldx #KERNEL_SECTIONS - 1
   stx currentGameTimer
.setPositionAndVelocityForObstacleEntrance
   lda #1
   sta obstacleVelocityValues,x     ; set obstacle velocity to move right
   lda KernelZoneValues,x
   clc
   adc #15
   sta obstacleVertPos,x            ; set obstacle vertical position
   lda #XMIN
   sta obstacleHorizPos,x           ; set obstacle horizontal position
   dex
   bpl .setPositionAndVelocityForObstacleEntrance
   ldy #OBSTACLE_ENTRANCE_AUDIO_IDX
   jsr SetGameAudioValues           ; set audio values for obstacle entrance
   jmp StepToNextGameState
       
PlayWordZapperEntranceSounds
   ldy #0
   sty destroyedWordZapperGraphicLSB
   jsr SetGameAudioValues           ; set audio values for Word Zapper entrance
   jmp StepToNextGameState
       
   .byte $A0,$E0,$A0                ; unused bytes

   BOUNDARY 0
   
SixDigitDisplayKernel
   txa                        ; 2         move scan line to accumulator
   pha                        ; 3
   ldy #H_FONT - 1            ; 2
   lda (characterGraphicPtrs + 10),y;5
   ldx VSYNC                  ; 3
   tax                        ; 2
   lda (characterGraphicPtrs + 6),y;5
   sta tmpFourthCharacter     ; 3
   lda (characterGraphicPtrs + 8),y;5
   sta tmpFifthCharacter      ; 3
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   jmp .jmpIntoSixDigitDisplayKernelLoop;3
   
.sixDigitDisplayKernelLoop
   lda (characterGraphicPtrs + 10),y;5
   ldx VSYNC                  ; 3
   tax                        ; 2
;--------------------------------------
   lda (characterGraphicPtrs + 8),y;5 = @02
   sta tmpFifthCharacter      ; 3
   lda (characterGraphicPtrs + 6),y;5
   sta tmpFourthCharacter     ; 3
.jmpIntoSixDigitDisplayKernelLoop
   lda (characterGraphicPtrs),y;5
   cmp VSYNC                  ; 3
   sta GRP0                   ; 3 = @24
   lda (characterGraphicPtrs + 2),y;5
   sta GRP1                   ; 3 = @32
   lda (characterGraphicPtrs + 4),y;5
   sta GRP0                   ; 3 = @40
   lda tmpFourthCharacter     ; 3
   sta GRP1                   ; 3 = @46
   lda tmpFifthCharacter      ; 3
   sta GRP0                   ; 3 = @52
   lda tmpFifthCharacter      ; 3
   stx GRP1                   ; 3 = @58
   dey                        ; 2
   bpl .sixDigitDisplayKernelLoop;2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   pla                        ; 4
   clc                        ; 2
   adc #<~H_FONT              ; 2
   tax                        ; 2
   rts                        ; 6

SetupMessageAreaForDisplay
   sta ramDataPointer         ; 3         set ramDataPointer LSB value
   txa                        ; 2         move scan line to accumulator
   pha                        ; 3         push scan line to stack
   ldy #5                     ; 2
   ldx #11                    ; 2
.setupMessageAreaForDisplay
   lda (ramDataPointer),y     ; 5         get character data in message area
   sec                        ; 2
   sbc #42                    ; 2
   asl                        ; 2
   sty tmpRamDataPointerIdx   ; 3
   tay                        ; 2
   iny                        ; 2
   lda CharacterSet,y         ; 4         get character MSB value
   sta characterGraphicPtrs,x ; 4         set graphic pointer MSB value
   dey                        ; 2
   dex                        ; 2
   lda CharacterSet,y         ; 4         get character LSB value
   sta characterGraphicPtrs,x ; 4         set graphic pointer LSB value
   dex                        ; 2
   ldy tmpRamDataPointerIdx   ; 3
   dey                        ; 2
   bpl .setupMessageAreaForDisplay;2³
   pla                        ; 4         pull scan line from stack
   tax                        ; 2         restore scan line count
   rts                        ; 6

PositionGRP0Horizontally
   ldy #<[RESP0 - RESP0]      ; 2
PositionObjectHorizontally
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   dex                        ; 2
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
   dex                        ; 2
   sta HMP0,y                 ; 5
   iny                        ; 2
   rts                        ; 6

PositionObjectsForMessageArea
   sta tmpMessageAreaHorizPos ; 3         save current message area position
   jsr PositionGRP0Horizontally;6
   lda tmpMessageAreaHorizPos ; 3         get current message area position
   clc                        ; 2
   adc #16                    ; 2         increment for next character
   jsr PositionObjectHorizontally;6       position GRP1 horizontally
   dex                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   rts                        ; 6

PlaceTimerInDisplayArea
   ldx #2                           ; timer offset position for ONE_PLAYER game
   lda tvTypeSwitchValue            ; get TV Type switch value
   bne .placeTimerInDisplayArea     ; branch if set to ONE_PLAYER game
   ldx #0                           ; timer offset position for player 1
   lda activePlayerNumber           ; get active player number
   beq .placeTimerInDisplayArea     ; branch if player 1 is active
   ldx #4                           ; timer offset position for player 2
.placeTimerInDisplayArea
   lda currentGameTimer             ; get current game timer value
   tay                              ; move game timer to y register
   and #15                          ; keep ones value
   ora #<[(_0 / 2) + 42]
   sta timerAreaDataValues + 1,x    ; place ones value to timer area
   tya                              ; move game timer value to accumulator
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   ora #<[(_0 / 2) + 42]
   sta timerAreaDataValues,x        ; place tens value to timer area
   rts

SetGameAudioValues
   inc audioChannelIndex            ; increment audio channel index value
   lda #1
   and audioChannelIndex            ; 0 <= a <= 1
   tax
   lda AudioValues,y                ; get audio frequency adjustment value
   sta audioFrequencyAdjustmentValues,x
   lda AudioValues + 1,y            ; get audio frequency value
   sta audioFrequencyValues,x
   lda AudioValues + 2,y            ; get audio duration value
   sta audioDurationValues,x
   lda AudioValues + 3,y            ; get audio tone and volume duration
   sta AUDC0,x                      ; set audio tone
   lsr                              ; shift volume duration to lower nybbles
   lsr
   lsr
   lsr
   sta initAudioVolumeDurationValues,x
   sta audioVolumeDurationValues,x
   lda #$FF
   sta audioVolumeValues,x
   rts

   .byte $F0,$C6,$A0,$C6,$D3,$C8,$A0,$A4,$A0;unused bytes
       
    BOUNDARY 252
   
   .word Start                      ; RESET vector
   .byte $E0,$88                    ; BRK vector