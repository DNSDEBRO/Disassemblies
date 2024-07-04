   LIST OFF
; ***  H U N T  &  S C O R E  ***
; Copyright 1978 Atari, Inc.
; Designer: Jim Huether
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: March 29, 2024
;
;  *** 126 BYTES OF RAM USED 2 BYTES FREE
; NTSC ROM usage stats
; -------------------------------------------
;  ***  6 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
;  ***  5 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1978, ATARI, INC.                                  =
; =                                                                            =
; ==============================================================================

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

;===============================================================================
; H E A D E R - I N C L U D E S
;===============================================================================

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
; F R A M E - T I M I N G S
;===============================================================================

VSYNC_TIME              = 42

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 44
OVERSCAN_TIME           = 33

KEYBOARD_READ_WAIT_DELAY = 9

   ELSE

FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 44
OVERSCAN_TIME           = 45

KEYBOARD_READ_WAIT_DELAY = 15

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

   IF COMPILE_REGION = NTSC

COLOR_LEFT_PLAYER_SCORE = RED_ORANGE + 7
COLOR_RIGHT_PLAYER_SCORE = GREEN + 9
COLOR_CARDS             = DK_BLUE + 2
COLOR_BACKGROUND        = RED + 2
COLOR_LADYBUG           = RED + 8
COLOR_BUTTERFLY         = YELLOW + 8
COLOR_SEAGULLS          = GREEN + 8
COLOR_RANGER            = CYAN + 8
COLOR_TABLE_AND_CHAIRS  = YELLOW + 8
COLOR_CRAB              = BLUE + 8
COLOR_TELEVISION        = DK_GREEN + 8
COLOR_BELL              = YELLOW + 8
COLOR_FLYING_SAUCER     = BRICK_RED + 8
COLOR_SAILBOAT          = ULTRAMARINE_BLUE + 8
COLOR_DEER              = OLIVE_GREEN + 8
COLOR_LLAMA             = DK_BLUE + 8
COLOR_AUTOMOBILE        = DK_GREEN + 8
COLOR_CASTLE            = BROWN + 8
COLOR_BUNNY             = BROWN + 8
COLOR_WILD_CARD         = YELLOW + 8
COLOR_CARD_FONTS        = DK_BLUE + 8

   ELSE

COLOR_LEFT_PLAYER_SCORE = DK_GREEN + 7
COLOR_RIGHT_PLAYER_SCORE = ULTRAMARINE_BLUE + 9
COLOR_CARDS             = CYAN + 2
COLOR_BACKGROUND        = BRICK_RED + 2
COLOR_LADYBUG           = BRICK_RED + 8
COLOR_BUTTERFLY         = GREY_01 + 8
COLOR_SEAGULLS          = ULTRAMARINE_BLUE + 8
COLOR_RANGER            = COLBALT_BLUE + 8
COLOR_TABLE_AND_CHAIRS  = GREY_01 + 8
COLOR_CRAB              = PURPLE + 8
COLOR_TELEVISION        = BLUE + 8
COLOR_BELL              = GREY_01 + 8
COLOR_FLYING_SAUCER     = DK_GREEN + 8
COLOR_SAILBOAT          = OLIVE_GREEN + 8
COLOR_LLAMA             = CYAN + 8
COLOR_DEER              = DK_BLUE + 8
COLOR_AUTOMOBILE        = BLUE + 8
COLOR_CASTLE            = GREY_02 + 8
COLOR_BUNNY             = GREY_02 + 8
COLOR_WILD_CARD         = GREY_01 + 8
COLOR_CARD_FONTS        = CYAN + 8

   ENDIF

BW_LEFT_PLAYER_SCORE    = BLACK + 7
BW_RIGHT_PLAYER_SCORE   = WHITE + 1
BW_CARDS                = BLACK + 8
BW_BACKGROUND           = BLACK

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

MAX_GRID_ROWS           = 6
MAX_GRID_COLUMNS        = 5

H_SCOREBOARD_FONT       = 5
H_OBJECTS               = 20

MAX_COLUMNS_GRID_SIZE_16 = 4
MAX_CARDS_GRID_SIZE_16  = 16
MAX_KEYBOARD_ENTRY_GRID_SIZE_16 = $17     ; BCD
MAX_CARD_PAIRS_GRID_SIZE_16 = [MAX_CARDS_GRID_SIZE_16 / 2]

MAX_COLUMNS_GRID_SIZE_30 = 5
MAX_CARDS_GRID_SIZE_30  = 30
MAX_KEYBOARD_ENTRY_GRID_SIZE_30 = $31     ; BCD
MAX_CARD_PAIRS_GRID_SIZE_30 = [MAX_CARDS_GRID_SIZE_30 / 2]

;
; Keyboard values
;
ID_KEY_NONE             = 0
ID_KEY_01               = 1
ID_KEY_02               = 2
ID_KEY_03               = 3
ID_KEY_04               = 4
ID_KEY_05               = 5
ID_KEY_06               = 6
ID_KEY_07               = 7
ID_KEY_08               = 8
ID_KEY_09               = 9
ID_KEY_ERASE            = 10
ID_KEY_00               = 11
ID_KEY_ENTER            = 12
;
; object ids
;
ID_LADY_BUG             = 0
ID_BUTTERFLY            = 1
ID_WILD_CARD            = 1
ID_SEAGULLS             = 2
ID_RANGER               = 3
ID_TABLE_AND_CHAIRS     = 4
ID_CRAB                 = 5
ID_TELEVISION           = 6
ID_BELL                 = 7
ID_FLYING_SAUCER        = 8
ID_SAILBOAT             = 9
ID_LLAMA                = 10
ID_DEER                 = 11
ID_AUTOMOBILE           = 12
ID_CASTLE               = 13
ID_BUNNY                = 14
ID_INVALID              = 255

TWO_PLAYERS             = 0 << 7
ONE_PLAYER              = 1 << 7
GRID_SIZE_16            = 1 << 6
GRID_SIZE_30            = 0 << 6
WILD_CARD               = 1 << 0
NO_WILD_CARD            = 0 << 0
    
;===============================================================================
; M A C R O S
;===============================================================================

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

playfieldGraphicValues  ds MAX_GRID_ROWS * MAX_GRID_COLUMNS
;--------------------------------------
rightPF0GraphicValues   = playfieldGraphicValues
leftPF1GraphicValues    = rightPF0GraphicValues + MAX_GRID_ROWS
leftPF2GraphicValues    = leftPF1GraphicValues + MAX_GRID_ROWS
rightPF1GraphicValues   = leftPF2GraphicValues + MAX_GRID_ROWS
rightPF2GraphicValues   = rightPF1GraphicValues + MAX_GRID_ROWS
frameCount              ds 1
gameState               ds 1
gameSelection           ds 1
selectDebounce          ds 1
rightPlayerMaskValue    ds 1
playerHorizPositionValues ds MAX_GRID_ROWS
rowGRP0GraphicPtrs      ds MAX_GRID_ROWS * 2
;--------------------------------------
grp0GraphicPtrs_00      = rowGRP0GraphicPtrs
grp0GraphicPtrs_01      = grp0GraphicPtrs_00 + 2
grp0GraphicPtrs_02      = grp0GraphicPtrs_01 + 2
grp0GraphicPtrs_03      = grp0GraphicPtrs_02 + 2
grp0GraphicPtrs_04      = grp0GraphicPtrs_03 + 2
grp0GraphicPtrs_05      = grp0GraphicPtrs_04 + 2
rowGRP1GraphicPtrs      ds MAX_GRID_ROWS * 2
;--------------------------------------
rowGRP1GraphicPtrs_00   = rowGRP1GraphicPtrs
rowGRP1GraphicPtrs_01   = rowGRP1GraphicPtrs_00 + 2
rowGRP1GraphicPtrs_02   = rowGRP1GraphicPtrs_01 + 2
rowGRP1GraphicPtrs_03   = rowGRP1GraphicPtrs_02 + 2
rowGRP1GraphicPtrs_04   = rowGRP1GraphicPtrs_03 + 2
rowGRP1GraphicPtrs_05   = rowGRP1GraphicPtrs_04 + 2
playingCardValues       ds MAX_GRID_ROWS * MAX_GRID_COLUMNS
currentPlayerIndex      ds 1
;--------------------------------------
tmpSpawnedCardValue     = currentPlayerIndex
cardChoiceIndexValues   ds 2
;--------------------------------------
firstCardChoiceIndex    = cardChoiceIndexValues
secondCardChoiceIndex   = firstCardChoiceIndex + 1
keyboardDebounce        ds 1
cardPairChoice          ds 1
frameColumnNumber       ds 1
soundTimer              ds 1
leftPlayerScoreLSBOffset ds 1
rightPlayerScoreLSBOffset ds 1
leftPlayerScoreMSBOffset ds 1
rightPlayerScoreMSBOffset ds 1
tmpColorXOR             ds 1
;--------------------------------------
tmpDeckCycleCount       = tmpColorXOR
playerScores            ds 2
;--------------------------------------
leftPlayerScore         = playerScores
rightPlayerScore        = leftPlayerScore + 1
actionInputAcceptedState ds 1
keyboardButtonValues    ds 2
;--------------------------------------
leftPlayerKeyboardButtonValue = keyboardButtonValues
rightPlayerKeyboardButtonValue = leftPlayerKeyboardButtonValue + 1
scoreBoardDisplayValues ds 2
;--------------------------------------
scoreBoardDisplayLeftValue = scoreBoardDisplayValues
scoreBoardDisplayRightValue = scoreBoardDisplayLeftValue + 1
gameVariation           ds 1
maxGameVariationValues  ds 4
;--------------------------------------
maxCardPairs            = maxGameVariationValues
maxPlayingCardIndex     = maxCardPairs + 1
maxKeyboardEntryValue   = maxPlayingCardIndex + 1
maxColumns              = maxKeyboardEntryValue + 1
wildCardGameStatus      ds 1
randomSeed              ds 1
tmpPlayfieldGraphicPtr  ds 2
;--------------------------------------
tmpObjectColorValue     = tmpPlayfieldGraphicPtr
;--------------------------------------
tmpObjectHorizontalPositionValue = tmpObjectColorValue
;--------------------------------------
tmpRowNumberIdx         = tmpObjectHorizontalPositionValue
;--------------------------------------
tmpCardChoiceIndexValue = tmpRowNumberIdx
;--------------------------------------
tmpCardFaceValue        = tmpCardChoiceIndexValue
;--------------------------------------
tmpObjectGRP0GraphicPtr = tmpCardFaceValue + 1
;--------------------------------------
tmpPlayfieldGraphicIndex = tmpObjectGRP0GraphicPtr
;--------------------------------------
tmpHueMask              ds 1
;--------------------------------------
tmpLeftPlayerScoreGraphicValue = tmpHueMask
;--------------------------------------
tmpScoreBoardValue      = tmpHueMask
;--------------------------------------
tmpCardChoiceIdx        = tmpScoreBoardValue
tmpObjectGRP1GraphicPtr ds 2
;--------------------------------------
tmpRightPlayerScoreGraphicValue = tmpObjectGRP1GraphicPtr
;--------------------------------------
tmpPlayfieldGraphicIdx  = tmpRightPlayerScoreGraphicValue
tmpRandomPlayingCardIndex = tmpPlayfieldGraphicIdx + 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

DetermineScoreBoardDisplayValues
   ldx #<[scoreBoardDisplayRightValue - scoreBoardDisplayValues] + 1
.determineScoreOffsetValues
   lda scoreBoardDisplayValues - 1,x; get score board display value
   and #$0F                         ; keep lower nybbles (i.e. ones value)
   sta tmpScoreBoardValue
   asl                              ; multiply value by 4
   asl
   clc                              ; add original to multiply by 5
   adc tmpScoreBoardValue           ; [i.e. x * 5 = (x * 4) + x]
   sta leftPlayerScoreLSBOffset - 1,x
   lda scoreBoardDisplayValues - 1,x; get score board display value
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide value by 4
   lsr
   sta tmpScoreBoardValue
   lsr                              ; divide value by 16
   lsr
   adc tmpScoreBoardValue           ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]
   sta leftPlayerScoreMSBOffset - 1,x
   dex
   bne .determineScoreOffsetValues
   ldy #$F7
   sty tmpHueMask
   ldy #0
   lda SWCHB                        ; read the console switches
   and #BW_MASK                     ; keep the B/W switch value
   bne .setObjectColorValues        ; branch if set to COLOR
   lda #7                           ; hue mask for B/W (i.e. no color)
   sta tmpHueMask
   ldy #4
.setObjectColorValues
   lda GameColorTable,y
   bit gameState                    ; check current game state
   bvs .colorObjects                ; branch if not cycling colors
   eor tmpColorXOR
   and tmpHueMask
.colorObjects
   sta COLUP0,x
   iny
   inx
   cpx #<[CTRLPF - COLUP0]
   bcc .setObjectColorValues
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   sta PF0                    ; 3 = @06
   sta PF1                    ; 3 = @09
   sta PF2                    ; 3 = @12
   ldx #MSBL_SIZE1 | PF_SCORE | PF_NO_REFLECT;2
   stx CTRLPF                 ; 3 = @17
   
   IF COMPILE_REGION = PAL50

      ldx #29                 ; 2
   
   ELSE
   
      inx                     ; 2         x = 3
      
   ENDIF

.waitDrawScoreKernel
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .waitDrawScoreKernel   ; 2³
   stx tmpLeftPlayerScoreGraphicValue;3
   stx tmpRightPlayerScoreGraphicValue;3
   ldx #H_SCOREBOARD_FONT + 1 ; 2
.drawScoreKernel
   sta WSYNC
;--------------------------------------
   lda tmpLeftPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @06
   ldy leftPlayerScoreMSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$F0                   ; 2         keep upper nybbles
   sta tmpLeftPlayerScoreGraphicValue;3
   ldy leftPlayerScoreLSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$0F                   ; 2         keep lower nybbles
   ora tmpLeftPlayerScoreGraphicValue;3   combine with score MSB graphic
   sta tmpLeftPlayerScoreGraphicValue;3   set left player score graphic
   lda tmpRightPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @39
   ldy rightPlayerScoreMSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and #$F0                   ; 2         keep upper nybbles
   sta tmpRightPlayerScoreGraphicValue;3
   ldy rightPlayerScoreLSBOffset;3
   lda NumberFonts,y          ; 4         get number font graphic value
   and rightPlayerMaskValue   ; 3
   sta WSYNC
;--------------------------------------
   ora tmpRightPlayerScoreGraphicValue;3
   sta tmpRightPlayerScoreGraphicValue;3
   lda tmpLeftPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @12
   dex                        ; 2
   beq DrawPlayingCardsKernel ; 2³
   inc leftPlayerScoreLSBOffset;5
   inc leftPlayerScoreMSBOffset;5
   inc rightPlayerScoreLSBOffset;5
   inc rightPlayerScoreMSBOffset;5
   lda tmpRightPlayerScoreGraphicValue;3
   sta PF1                    ; 3 = @42
   jmp .drawScoreKernel       ; 3
    
DrawPlayingCardsKernel
   stx PF1                    ; 3 = @20
   sta WSYNC
;--------------------------------------
   lda #MSBL_SIZE1 | PF_PRIORITY | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @05
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   stx PF0                    ; 3 = @05
   stx PF1                    ; 3 = @08
   stx PF2                    ; 3 = @11
   inx                        ; 2         x = 0
   beq .horizontallyPositionObjects;3 + 1 unconditional branch

.drawPlayingCardsKernel
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @73
   sta WSYNC
;--------------------------------------
   lda (tmpObjectGRP0GraphicPtr),y;5
   sta GRP0                   ; 3 = @08
   lda (tmpObjectGRP1GraphicPtr),y;5
   sta GRP1                   ; 3 = @16
.drawPlayingCards
   lda leftPF1GraphicValues,x ; 4
   sta PF1                    ; 3 = @23
   lda leftPF2GraphicValues,x ; 4
   sta PF2                    ; 3 = @30
   lda rightPF0GraphicValues,x; 4
   sta PF0                    ; 3 = @37
   lda rightPF1GraphicValues,x; 4
   sta PF1                    ; 3 = @44
   iny                        ; 2
   lda rightPF2GraphicValues,x; 4
   sta PF2                    ; 3 = @63
   cpy #H_OBJECTS             ; 2
   bcc .drawPlayingCardsKernel; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   sta GRP1                   ; 3 = @08
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @13
   cpy #H_OBJECTS + 1         ; 2
   bcc .drawPlayingCards      ; 2³
   sta PF1                    ; 3 = @20
   sta PF2                    ; 3 = @23
   inx                        ; 2
   cpx #MAX_GRID_ROWS         ; 2
   beq ReadKeyboardController ; 2³        branch if done drawing kernel
.horizontallyPositionObjects
   sta WSYNC
;--------------------------------------
   lda playerHorizPositionValues,x;4
   and #$0F                   ; 2         keep coarse position value
   tay                        ; 2
.coarsePositionPlayers
   dey                        ; 2
   bpl .coarsePositionPlayers ; 2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   lda playerHorizPositionValues,x;4
   sta HMP0                   ; 3
   clc                        ; 2
   adc #HMOVE_L1              ; 2
   sta HMP1                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   txa                        ; 2         move group number to accumulator
   tay                        ; 2         save group number to y register
   asl                        ; 2         multiply group by 2
   tax                        ; 2
   lda rowGRP0GraphicPtrs,x   ; 4
   sta tmpObjectGRP0GraphicPtr; 3
   lda rowGRP1GraphicPtrs,x   ; 4
   sta tmpObjectGRP1GraphicPtr; 3
   inx                        ; 2
   lda rowGRP0GraphicPtrs,x   ; 4
   sta tmpObjectGRP0GraphicPtr + 1;3
   lda rowGRP1GraphicPtrs,x   ; 4
   sta tmpObjectGRP1GraphicPtr + 1;3
   tya                        ; 2         move group number to accumulator
   tax                        ; 2         restore group number to x register
   sta WSYNC
;--------------------------------------
   ldy #H_OBJECTS             ; 2
   lda (tmpObjectGRP0GraphicPtr),y;5
   sta tmpObjectColorValue    ; 3         set object color value
   lda SWCHB                  ; 4         read the console switches
   and #BW_MASK               ; 2         keep the B/W switch value
   bne .getPlayingCardObjectColor;2³      branch if set to COLOR
   lda #$0F                   ; 2
   and tmpObjectColorValue    ; 3         remove color / keep luminance
   bpl .checkToColorPlayingCardObjects;3  unconditional branch
    
.getPlayingCardObjectColor
   lda tmpObjectColorValue    ; 3
.checkToColorPlayingCardObjects
   bit gameState              ; 3         check current game state
   bvc .setObjectReflectState ; 2³
   sta COLUP0                 ; 3 = @34
   sta COLUP1                 ; 3 = @37
.setObjectReflectState
   sta WSYNC
;--------------------------------------
   rol                        ; 2         shift REFLECT value
   rol                        ; 2
   rol                        ; 2
   sta REFP1                  ; 3 = @09
   ldy #<-1                   ; 2
   jmp .drawPlayingCards      ; 3
    
ReadKeyboardController
   ldx #0
   stx leftPlayerKeyboardButtonValue
   stx rightPlayerKeyboardButtonValue
   lda #%11101110                   ; start with top row of keyboard controller
.readKeyboardControllerRow
   sta SWCHA                        ; isolate keyboard row
   ldy #KEYBOARD_READ_WAIT_DELAY
.keyboardReadWait
   sta WSYNC
   dey
   bne .keyboardReadWait
   inx                              ; increment keyboard button value
   ldy INPT0                        ; read left keyboard column 01 value
   bmi .checkRightPlayerLeftKeyboardColumn;branch if keyboard button not pressed
   stx leftPlayerKeyboardButtonValue
.checkRightPlayerLeftKeyboardColumn
   ldy INPT2                        ; read right keyboard column 01 value
   bmi .checkLeftPlayerMiddleKeyboardColumn;branch if keyboard button not pressed
   stx rightPlayerKeyboardButtonValue
.checkLeftPlayerMiddleKeyboardColumn
   inx                              ; increment keyboard button value
   ldy INPT1                        ; read left keyboard column 02 value
   bmi .checkRightPlayerMiddleKeyboardColumn;branch if keyboard column not pressed
   stx leftPlayerKeyboardButtonValue
.checkRightPlayerMiddleKeyboardColumn
   sta WSYNC                        ; wait for next scan line
   ldy INPT3                        ; read right keyboard column 02 value
   bmi .checkLeftPlayerRightKeyboardColumn;branch if keyboard column not pressed
   stx rightPlayerKeyboardButtonValue
.checkLeftPlayerRightKeyboardColumn
   inx                              ; increment keyboard button value
   ldy INPT4                        ; read left keyboard column 03 value
   bmi .checkRightPlayerRightKeyboardColumn;branch if keyboard column not pressed
   stx leftPlayerKeyboardButtonValue
.checkRightPlayerRightKeyboardColumn
   ldy INPT5                        ; read right keyboard column 03 value
   bmi .checkNextKeyboardRow        ; branch if keyboard column not pressed
   stx rightPlayerKeyboardButtonValue
.checkNextKeyboardRow
   sec
   rol
   bcs .readKeyboardControllerRow   ; branch to read next keyboard row
   rts
    
NewFrame SUBROUTINE
   lda #VSYNC_TIME
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta TIM8T                        ; set timer for vertical sync period
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   rts
    
Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
   stx gameState
   stx scoreBoardDisplayRightValue
   stx rightPlayerMaskValue         ; hide right player score display
   stx gameSelection                ; clear game selection value
   inx                              ; x = 1
   stx scoreBoardDisplayLeftValue
   bne ResetGameValues              ; unconditional branch

MainLoop
   jsr NewFrame
   jsr CheckConsoleSwitches
.displayScanout
   jsr DetermineScoreBoardDisplayValues
   bcc MainLoop                     ; unconditional branch

ResetGameValues
   ldx #$FF
   txs                              ; set stack to the beginning
   ldx gameSelection                ; get current game selection value
   lda GameVariationTable,x
   sta gameVariation
   ror                              ; shift WILD_CARD value to carry
   ror                              ; shift WILD_CARD value to D7
   sta wildCardGameStatus
   ldy #MAX_GRID_COLUMNS
   ldx #<[frameCount - playfieldGraphicValues]
.initColumnPlayfieldGraphicValues
   lda #MAX_GRID_ROWS
   sta tmpRowNumberIdx
.initRowPlayfieldGaphicValues
   stx tmpPlayfieldGraphicIndex
   lda InitPlayfieldGraphicValues - 1,y
   bit gameVariation                ; check current game variation
   bvc .initPlayfieldGraphicValues  ; branch if GRID_SIZE_30
   cpy #MAX_GRID_COLUMNS - 1
   bne .checkGrid16RightPF0Graphics
   lda #$0F                         ; GRID_SIZE_16 leftPF1GraphicValues
   bne .setPlayfieldGraphicValues   ; unconditional branch

.checkGrid16RightPF0Graphics
   cpy #MAX_GRID_COLUMNS
   bne .setPlayfieldGraphicValues
   lda #$FF                         ; GRID_SIZE_16 rightPF0GraphicValues
.setPlayfieldGraphicValues
   ldx tmpRowNumberIdx
   cpx #MAX_GRID_ROWS - 1
   bcc .initPlayfieldGraphicValues
   lda #$FF
.initPlayfieldGraphicValues
   ldx tmpPlayfieldGraphicIndex
   sta playfieldGraphicValues - 1,x
   dex
   dec tmpRowNumberIdx
   bne .initRowPlayfieldGaphicValues
   dey
   bne .initColumnPlayfieldGraphicValues
   ldx #<[CXCLR - RSYNC] + 1
.clearTIA
   sty RSYNC + 64,x
   dex
   bne .clearTIA
   ldx #<[rightPlayerKeyboardButtonValue - currentPlayerIndex] + 1
.clearGameVariables
   sty currentPlayerIndex - 1,x
   dex
   bne .clearGameVariables
   ldy #<[maxColumns - maxGameVariationValues] + 1
   lda gameSelection                ; get current game selection value
   and #4                           ; a = 0 || a = 4
   tax
.setMaxGameVariationValues
   lda GameVariationMaxValuesTable,x
   sta maxGameVariationValues - 1,y
   inx
   dey
   bne .setMaxGameVariationValues
   ldx #<[currentPlayerIndex - playingCardValues]
   stx firstCardChoiceIndex
   stx secondCardChoiceIndex
   lda gameState                    ; get current game state
   bmi ShufflePlayingCards          ; branch if game in session
   jmp .displayScanout
    
ShufflePlayingCards
   lda #$FF
   sta SWACNT                       ; set port A bits for output (write only)
.resetPlayingCards
   sta playingCardValues - 1,x      ; set card value to ID_INVALID
   dex
   bne .resetPlayingCards
   stx scoreBoardDisplayLeftValue
   stx scoreBoardDisplayRightValue
   lda #2
   sta tmpDeckCycleCount
.shufflePlayingCards
   ldy #[MAX_CARD_PAIRS_GRID_SIZE_30] - 1
   bit gameVariation                ; check current game variation
   bvc .determinePlayingCardValue   ; branch if GRID_SIZE_30
   ldy #[MAX_CARD_PAIRS_GRID_SIZE_16] - 1
.determinePlayingCardValue
   sty tmpSpawnedCardValue
   jsr DetermineScoreBoardDisplayValues
   jsr NewFrame
   ldx #5
.determineRandomNumber
   lsr randomSeed
   rol
   eor randomSeed
   lsr
   lda randomSeed
   bcs .nextRandom
   ora #$40
   sta randomSeed
.nextRandom
   dex
   bne .determineRandomNumber
   sta tmpRandomPlayingCardIndex
   lda #$1F
   bit gameVariation                ; check current game variation
   bvc .determineRandomCardIndex    ; branch if GRID_SIZE_30
   lda #$0F
.determineRandomCardIndex
   and tmpRandomPlayingCardIndex    ; mask for card index value
   ldy tmpSpawnedCardValue
   tax                              ; move random card index to x register
   cpx maxPlayingCardIndex
   bcs .determinePlayingCardValue   ; branch if outside card index range
   lda playingCardValues,x          ; get card value at index
   bpl .determinePlayingCardValue   ; branch if object present at index
   sty playingCardValues,x          ; place new spawned object at index
   dey
   bpl .determinePlayingCardValue
   dec tmpDeckCycleCount
   bne .shufflePlayingCards
   jmp .displayScanout

CheckConsoleSwitches
   inc frameCount
   lda SWCHB                        ; read the console switches
   ror                              ; shift RESET to carry
   bcs .resetNotPressed             ; branch if RESET not pressed
   lda #$0F
   sta rightPlayerMaskValue         ; display right player score value
   ldx #$FF
   stx gameState
   jmp ResetGameValues
    
.resetNotPressed
   lda selectDebounce
   beq .cycleGameColors
   inc selectDebounce
.cycleGameColors
   lda frameCount                   ; get current frame count
   and #$7F                         ; 0 <= a <= 127
   cmp #127
   bne .checkGameSelectSwitch
   lda #0
   inc tmpColorXOR
   bne .checkGameSelectSwitch
   sta gameState
.checkGameSelectSwitch
   sta randomSeed
   lda SWCHB                        ; read the console switches
   eor #$FF                         ; flip the bits
   and #SELECT_MASK                 ; isolate SELECT_MASK value
   bne .selectButtonPressed         ; branch if SELECT held
   sta selectDebounce               ; clear select debounce
   beq .checkToClearKeyboardDebounce; unconditional branch

.selectButtonPressed
   bit selectDebounce
   bmi .checkToClearKeyboardDebounce; branch if select time not expired
   lda #[256 - 64]
   sta selectDebounce
   inc gameSelection                ; increment game selection
   ldx gameSelection                ; get current game selection value
   sed
   lda #0
   clc
.determineGameSelectionDisplay
   adc #1
   dex
   bne .determineGameSelectionDisplay
   sta scoreBoardDisplayLeftValue
   stx scoreBoardDisplayRightValue
   stx rightPlayerMaskValue         ; hide right player score display
   stx gameState
   lda gameSelection                ; get current game selection value
   cmp #8
   bcc .incrementScoreBoardDisplayValue;branch if max selection not reached
   stx scoreBoardDisplayLeftValue   ; reset score board display value
   stx gameSelection                ; reset game selection value
.incrementScoreBoardDisplayValue
   clc
   lda scoreBoardDisplayLeftValue
   adc #1
   sta scoreBoardDisplayLeftValue
   cld
   jmp ResetGameValues
    
.checkToClearKeyboardDebounce
   lda gameState                    ; get current game state
   bpl .setCurrentFrameColumnNumber ; branch if game not in progress
   ldx currentPlayerIndex           ; get current player index
   ldy soundTimer                   ; get sound timer value
   bne CheckSelectedCardPairs       ; branch if playing sound
   lda keyboardButtonValues,x       ; get player keyboard button value
   bne .checkKeyboardDebounceValue  ; branch if keyboard input present
   sta keyboardDebounce             ; clear keyboard debounce (i.e. a = 0)
   beq .setCurrentFrameColumnNumber ; unconditional branch

CheckSelectedCardPairs
   inc soundTimer
   ldy #1
.checkForCorrectCardPair
   sta tmpCardFaceValue
   ldx cardChoiceIndexValues,y      ; get card choice index value
   lda playingCardValues,x          ; get playing card value
   bit wildCardGameStatus           ; check Wild Card game status
   bpl .checkNextCardForCorrectPair ; branch if not a Wild Card game
   cmp #ID_WILD_CARD
   beq CorrectCardPairFound
.checkNextCardForCorrectPair
   dey
   bpl .checkForCorrectCardPair
   cmp tmpCardFaceValue
   beq CorrectCardPairFound
   ldx #23
   stx AUDV0                        ; set to max volume (i.e. 4-bit volume)
   stx AUDC0
   lda soundTimer                   ; get sound timer value
   bne .determineIncorrectPairSoundFrequency;branch if playing sounds
   jmp IncorrectCardPairFound

.determineIncorrectPairSoundFrequency
   and #$80
   beq .setIncorrectCardPairSoundFrequency
   ldx #$1F
.setIncorrectCardPairSoundFrequency
   stx AUDF0
   jmp .setCurrentFrameColumnNumber
    
CorrectCardPairFound
   lda #12
   sta AUDC0
   ldx #8
   stx AUDV0
   lda soundTimer                   ; get sound timer value
   and #$7F                         ; 0 <= a <= 127
   bne .determineCorrectPairSoundFrequency
   jmp IncrementPlayerScore
    
.determineCorrectPairSoundFrequency
   and #$10
   beq .setCorrectCardPairSoundFrequency
   ldx #4
.setCorrectCardPairSoundFrequency
   stx AUDF0
   bne .setCurrentFrameColumnNumber
.checkKeyboardDebounceValue
   sta tmpColorXOR
   ldy keyboardDebounce             ; get keyboard debounce value
   beq .checkToProcessKeyboardInput
   bne .setCurrentFrameColumnNumber ; unconditional branch

.checkToProcessKeyboardInput
   ldy soundTimer                   ; get sound timer value
   beq ProcessKeyboardInput         ; branch if no sounds playing
.setCurrentFrameColumnNumber
   jmp SetCurrentFrameColumnNumber
    
ProcessKeyboardInput
   inc keyboardDebounce             ; increment keyboard debounce
   cmp #ID_KEY_ENTER
   beq .processKeyboardActionInput  ; branch if ENTER key pressed
   cmp #ID_KEY_ERASE
   bne .processKeyboardNumberInput  ; branch if number value pressed
   sty scoreBoardDisplayValues,x    ; clear entered value
   beq .processKeyboardActionInput  ; unconditional branch

.processKeyboardNumberInput
   cmp #ID_KEY_00
   bne .determineEnteredKeyboardValue
   sty keyboardButtonValues,x       ; clear keyboard button value (i.e. y = 0)
.determineEnteredKeyboardValue
   lda scoreBoardDisplayValues,x    ; get player score board display value
   ldy actionInputAcceptedState     ; get action input state value
   beq .determineEnteredKeyboardTensValue;branch if no action input
   lda #0
   sta actionInputAcceptedState     ; clear action input state value
.determineEnteredKeyboardTensValue
   asl                              ; shift current ones value to tens
   asl
   asl
   asl
   eor keyboardButtonValues,x       ; combine with entered value
   cmp maxKeyboardEntryValue
   bcc .setEnteredKeyboardValue     ; branch if within keyboard range
   and #$0F                         ; mask off tens value
.setEnteredKeyboardValue
   sta scoreBoardDisplayValues,x
   jmp .setCurrentFrameColumnNumber
    
.processKeyboardActionInput
   lda #1
   sta actionInputAcceptedState     ; show action input accepted
   lda scoreBoardDisplayValues,x    ; get player score board display value
   bne .determineChoosenCardIndexValue;branch if value entered
   beq .setCurrentFrameColumnNumber ; unconditional branch

.determineChoosenCardIndexValue
   lsr                              ; shift tens value to lower nybbles
   lsr
   lsr
   lsr
   tay
   lda scoreBoardDisplayValues,x
   and #$0F                         ; keep ones value
   iny                              ; increment tens value
   dey                              ; decrement tens value (i.e. restore value)
   beq .setChoosenCardIndexValue    ; branch if no tens value
   clc
.multiplyBy10
   adc #10
   dey
   bne .multiplyBy10
.setChoosenCardIndexValue
   ldx cardPairChoice               ; get card pair choice value
   sta cardChoiceIndexValues,x
   dec cardChoiceIndexValues,x
   tay                              ; move card number to y register
   dey
   lda playingCardValues,y          ; get playing card value
   cmp #ID_INVALID
   bne .checkIfUserChoseSameCard    ; branch if card not removed
   lda #<[currentPlayerIndex - playingCardValues]
   sta cardChoiceIndexValues,x
   bne .setCurrentFrameColumnNumber ; unconditional branch
    
.checkIfUserChoseSameCard
   lda firstCardChoiceIndex
   cmp secondCardChoiceIndex
   bne .checkForSelectingSecondChoice;branch if not selected same card number
   lda #<[currentPlayerIndex - playingCardValues]
   sta secondCardChoiceIndex
   bne .setCurrentFrameColumnNumber ; unconditional branch

.checkForSelectingSecondChoice
   cpx #<[secondCardChoiceIndex - cardChoiceIndexValues]
   beq .enteringSecondCardPairChoice; branch if entering second choice
   inx                              ; x = 1
   stx cardPairChoice
   bne .setCurrentFrameColumnNumber ; unconditional branch

.enteringSecondCardPairChoice
   inc soundTimer
   jmp SetCurrentFrameColumnNumber
    
IncorrectCardPairFound
   ldx gameVariation                ; get current game variation
   bpl .switchPlayers               ; branch if TWO_PLAYERS
   lda rightPlayerScore             ; get right player score value
   sed                              ; set to decimal mode
   clc
   adc #1
   cld
   sta rightPlayerScore
   lda #0
   beq .doneIncorrectCardPairFound  ; unconditional branch

.switchPlayers
   ldx currentPlayerIndex           ; get current player index
   bne .doneIncorrectCardPairFound  ; branch if processing right player
   lda #1
.doneIncorrectCardPairFound
   sta currentPlayerIndex
   jmp InitValuesForDisplayKernel
    
IncrementPlayerScore
   ldx currentPlayerIndex           ; get current player index
   lda playerScores,x               ; get player score
   sed                              ; set to decimal mode
   clc
   ldx currentPlayerIndex           ; get current player index
   bne .checkRightPlayerDifficultySetting;branch if processing right player
   bit SWCHB                        ; check console switch values
   bvs .incrementPlayerScore        ; branch if left player setting set to PRO
   adc #1
   bne .incrementPlayerScore        ; unconditional branch

.checkRightPlayerDifficultySetting
   bit SWCHB                        ; check console switch values
   bmi .incrementPlayerScore        ; branch if right player setting set to PRO
   adc #1
.incrementPlayerScore
   adc #1
   sta playerScores,x
   cld                              ; clear decimal mode
   dec maxCardPairs                 ; reduce number of card pairs to find
   bne MarkCardPairRemoved          ; branch if all pairs not found
   lda #$0F
   sta gameState
MarkCardPairRemoved
   ldy #>playfieldGraphicValues
   sty tmpPlayfieldGraphicPtr + 1   ; set MSB to point to ZP RAM
   iny                              ; y = 1
   sty tmpCardChoiceIdx
.markCardPairRemoved
   ldy tmpCardChoiceIdx
   lda #1
   sta tmpPlayfieldGraphicIdx
   ldx cardChoiceIndexValues,y      ; get card choice index value
   lda #ID_INVALID
   sta playingCardValues,x          ; set card choice as ID_INVALID
   inx
   ldy #0
.determineRowAndColumnValues
   clc
   adc #1                           ; increment grid column
   cmp maxColumns
   bne .decrementCardChoiceIndex    ; branch if not reached end of columns
   iny                              ; increment row number
   lda #0
.decrementCardChoiceIndex
   dex                              ; decrement card choice index value
   bne .determineRowAndColumnValues
   asl                              ; multiply grid column by 2
   tax
   inx
.setRemovedCardPairPlayfieldGraphics
   lda PlayfieldGraphicValuePointers,x
   sta tmpPlayfieldGraphicPtr       ; set graphic pointer LSB value
   lda PlayfieldGraphicMaskingValues,x;get playfield graphic masking value
   eor (tmpPlayfieldGraphicPtr),y   ; flip graphic value
   sta (tmpPlayfieldGraphicPtr),y   ; set playfield graphic value
   dex
   dec tmpPlayfieldGraphicIdx
   bpl .setRemovedCardPairPlayfieldGraphics
   dec tmpCardChoiceIdx
   bpl .markCardPairRemoved
InitValuesForDisplayKernel
   lda #0
   sta soundTimer
   sta cardPairChoice
   sta keyboardDebounce
   sta AUDV0
   lda leftPlayerScore              ; get left player score value
   sta scoreBoardDisplayLeftValue
   lda rightPlayerScore             ; get right player score value
   sta scoreBoardDisplayRightValue
   lda #<[currentPlayerIndex - playingCardValues]
   sta firstCardChoiceIndex
   sta secondCardChoiceIndex
SetCurrentFrameColumnNumber SUBROUTINE
   lda frameCount                   ; get current frame count
   and #$3F                         ; 0 <= a <= 63
   bne .determineFrameColumnNumber
   inc frameColumnNumber            ; increment frame column number
.determineFrameColumnNumber
   ldx frameColumnNumber            ; get current frame column number
   dex
   cpx maxColumns
   bcc .setCurrentFrameColumnNumber ; branch if not reached maximum rows
   ldx #0                           ; reset column index
.setCurrentFrameColumnNumber
   inx
   stx frameColumnNumber
   ldy #MAX_GRID_ROWS
   bit gameState                    ; check current game state
   bvc SetToShowNumberedSquares
.findColumnNumberCard
   lda playingCardValues - 1,x
   bpl SetToShowNumberedSquares     ; branch if not ID_INVALID
   clc
   txa                              ; move frame column number to accumulator
   adc maxColumns
   tax
   dey                              ; decrement column index
   bne .findColumnNumberCard
   inc frameColumnNumber
   bne .determineFrameColumnNumber  ; unconditional branch

SetToShowNumberedSquares
   ldx frameColumnNumber            ; get current frame column number
   ldy #0
   lda ColumnHorizontalPositionValues - 1,x
   sta tmpObjectHorizontalPositionValue
   ldx #MAX_GRID_ROWS
.setObjectHorizontalPositionAndGraphicMSB
   lda tmpObjectHorizontalPositionValue
   sta playerHorizPositionValues - 1,x
   lda #>CardNumberFonts
   sta rowGRP0GraphicPtrs + 1,y
   sta rowGRP1GraphicPtrs + 1,y
   iny
   iny
   dex
   bne .setObjectHorizontalPositionAndGraphicMSB
   lda frameColumnNumber            ; get current frame column number
   sta tmpRowNumberIdx
.showNumberedSquares
   lsr                              ; shift upper nybbles to lower nybbles
   lsr
   lsr
   lsr
   tay
   bne .setNumberedSquareValues
   ldy #10                          ; suppress leading zero
.setNumberedSquareValues
   lda #<CardNumberFonts
   clc
.determineCardTensValue
   adc #H_OBJECTS + 1
   dey
   bne .determineCardTensValue
   sta rowGRP0GraphicPtrs,x         ; set card tens graphic pointer
   lda tmpRowNumberIdx
   and #$0F                         ; keep ones value
   tay
   lda #<[CardNumberFonts - H_OBJECTS] - 1
.determineCardOnesValue
   clc
   adc #H_OBJECTS + 1
   dey
   bpl .determineCardOnesValue
   sta rowGRP1GraphicPtrs,x         ; set card ones graphic pointer
   clc
   sed
   lda tmpRowNumberIdx
   adc maxColumns
   cld
   sta tmpRowNumberIdx
   inx
   inx
   cmp maxKeyboardEntryValue
   bcc .showNumberedSquares
   ldx #<[firstCardChoiceIndex - cardChoiceIndexValues]
   lda frameCount                   ; get current frame count
   and #$20
   beq .checkToDisplayChoosenCard
   inx                              ; increment for secondCardChoiceIndex
.checkToDisplayChoosenCard
   ldy cardChoiceIndexValues,x      ; get card choice index value
   sty tmpCardChoiceIndexValue
   cpy #<[currentPlayerIndex - playingCardValues]
   beq .doneDisplayChoosenCard      ; branch if value not choosen
   iny                              ; increment card choice index value
   tya                              ; move card choice index to accumulator
   ldy #<-1
   ldx #0
.determineCardColumnAndRow
   iny
   cpy maxColumns
   bne .decrementCardChoiceIndexValue;branch if not reached maximum columns
   inx
   ldy #0
.decrementCardChoiceIndexValue
   sec
   sbc #1
   bne .determineCardColumnAndRow
   lda ColumnHorizontalPositionValues,y
   ldy tmpCardChoiceIndexValue
   sta playerHorizPositionValues,x
   txa
   asl
   tax
   lda playingCardValues,y
   tay
   bit wildCardGameStatus           ; check Wild Card game status
   bpl .setPlayingCardGraphicPointers;branch if not a Wild Card game
   cmp #ID_WILD_CARD
   bne .setPlayingCardGraphicPointers
   ldy #<[(WildCard - HuntAndScoreObjects) / H_OBJECTS]
.setPlayingCardGraphicPointers
   lda #>HuntAndScoreObjects
   sta rowGRP0GraphicPtrs + 1,x
   sta rowGRP1GraphicPtrs + 1,x
   lda #<[HuntAndScoreObjects - H_OBJECTS] - 1
.determinePlayingCardGraphicPointers
   clc
   adc #H_OBJECTS + 1
   bcc .nextPlayingCardGraphicPointer
   inc rowGRP0GraphicPtrs + 1,x     ; crosses boundary...increment MSB value
   inc rowGRP1GraphicPtrs + 1,x
.nextPlayingCardGraphicPointer
   dey
   bpl .determinePlayingCardGraphicPointers
   sta rowGRP0GraphicPtrs,x
   sta rowGRP1GraphicPtrs,x
.doneDisplayChoosenCard
   rts
    
InitPlayfieldGraphicValues
   .byte $4F            ; rightPF2GraphicValues
   .byte $82            ; rightPF1GraphicValues
   .byte $10            ; leftPF2GraphicValues
   .byte $08            ; leftPF1GraphicValues
   .byte $FC            ; rightPF0GraphicValues

GameVariationMaxValuesTable
   .byte MAX_COLUMNS_GRID_SIZE_16, MAX_KEYBOARD_ENTRY_GRID_SIZE_16
   .byte MAX_CARDS_GRID_SIZE_16,  MAX_CARD_PAIRS_GRID_SIZE_16
   .byte MAX_COLUMNS_GRID_SIZE_30, MAX_KEYBOARD_ENTRY_GRID_SIZE_30
   .byte MAX_CARDS_GRID_SIZE_30,  MAX_CARD_PAIRS_GRID_SIZE_30

NumberFonts
zero
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
one
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
two
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
three
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $66 ; |.XX..XX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
four
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
five
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
six
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
seven
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
eight
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
nine
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|

GameColorTable
   .byte COLOR_LEFT_PLAYER_SCORE
   .byte COLOR_RIGHT_PLAYER_SCORE
   .byte COLOR_CARDS
   .byte COLOR_BACKGROUND
   .byte BW_LEFT_PLAYER_SCORE
   .byte BW_RIGHT_PLAYER_SCORE
   .byte BW_CARDS
   .byte BW_BACKGROUND

ColumnHorizontalPositionValues
   .byte HMOVE_L5 | 3
   .byte HMOVE_R4 | 4
   .byte HMOVE_L2 | 6
   .byte HMOVE_R7 | 7
   .byte HMOVE_R1 | 9

GameVariationTable
   .byte TWO_PLAYERS | GRID_SIZE_16 | NO_WILD_CARD
   .byte ONE_PLAYER  | GRID_SIZE_16 | NO_WILD_CARD
   .byte TWO_PLAYERS | GRID_SIZE_16 | WILD_CARD
   .byte ONE_PLAYER  | GRID_SIZE_16 | WILD_CARD
   .byte TWO_PLAYERS | GRID_SIZE_30 | NO_WILD_CARD
   .byte ONE_PLAYER  | GRID_SIZE_30 | NO_WILD_CARD
   .byte TWO_PLAYERS | GRID_SIZE_30 | WILD_CARD
   .byte ONE_PLAYER  | GRID_SIZE_30 | WILD_CARD

PlayfieldGraphicValuePointers
   .byte <leftPF1GraphicValues
   .byte <CXM0P
   .byte <leftPF1GraphicValues
   .byte <leftPF2GraphicValues
   .byte <leftPF2GraphicValues
   .byte <rightPF0GraphicValues
   .byte <rightPF0GraphicValues
   .byte <rightPF1GraphicValues
   .byte <rightPF1GraphicValues
   .byte <rightPF2GraphicValues

PlayfieldGraphicMaskingValues
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $0F ; |....XXXX|
   .byte $E0 ; |XXX.....|
   .byte $30 ; |..XX....|
   .byte $80 ; |X.......|
   .byte $F0 ; |XXXX....|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|

HuntAndScoreObjects
LadyBug
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $23 ; |..X...XX|
   .byte $17 ; |...X.XXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0F ; |....XXXX|
   .byte $17 ; |...X.XXX|
   .byte $23 ; |..X...XX|
   .byte $01 ; |.......X|
   .byte COLOR_LADYBUG | [REFLECT >> 3]
Butterfly
   .byte $04 ; |.....X..|
   .byte $22 ; |..X...X.|
   .byte $71 ; |.XXX...X|
   .byte $79 ; |.XXXX..X|
   .byte $ED ; |XXX.XX.X|
   .byte $ED ; |XXX.XX.X|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $3B ; |..XXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $77 ; |.XXX.XXX|
   .byte $77 ; |.XXX.XXX|
   .byte $6F ; |.XX.XXXX|
   .byte $6F ; |.XX.XXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $0E ; |....XXX.|
   .byte $0C ; |....XX..|
   .byte COLOR_BUTTERFLY | [REFLECT >> 3]
Seagulls
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0F ; |....XXXX|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $A8 ; |X.X.X...|
   .byte $A8 ; |X.X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte COLOR_SEAGULLS | [NO_REFLECT >> 3]
Ranger
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $00 ; |........|
   .byte $3F ; |..XXXXXX|
   .byte $08 ; |....X...|
   .byte $0A ; |....X.X.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte COLOR_RANGER | [REFLECT >> 3]
TableAndChairs
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $8F ; |X...XXXX|
   .byte $8F ; |X...XXXX|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $F9 ; |XXXXX..X|
   .byte $F9 ; |XXXXX..X|
   .byte $89 ; |X...X..X|
   .byte $89 ; |X...X..X|
   .byte $89 ; |X...X..X|
   .byte $89 ; |X...X..X|
   .byte $F9 ; |XXXXX..X|
   .byte $F9 ; |XXXXX..X|
   .byte $89 ; |X...X..X|
   .byte $89 ; |X...X..X|
   .byte $8B ; |X...X.XX|
   .byte $8B ; |X...X.XX|
   .byte COLOR_TABLE_AND_CHAIRS | [REFLECT >> 3]
Crab
   .byte $00 ; |........|
   .byte $32 ; |..XX..X.|
   .byte $62 ; |.XX...X.|
   .byte $F1 ; |XXXX...X|
   .byte $E1 ; |XXX....X|
   .byte $73 ; |.XXX..XX|
   .byte $73 ; |.XXX..XX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $6F ; |.XX.XXXX|
   .byte $37 ; |..XX.XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte COLOR_CRAB | [REFLECT >> 3]
Television
   .byte $20 ; |..X.....|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $01 ; |.......X|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $0D ; |....XX.X|
   .byte $0F ; |....XXXX|
   .byte $06 ; |.....XX.|
   .byte $00 ; |........|
   .byte COLOR_TELEVISION | [REFLECT >> 3]
Bell
   .byte $00 ; |........|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $0D ; |....XX.X|
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte COLOR_BELL | [REFLECT >> 3]
FlyingSaucer
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $0D ; |....XX.X|
   .byte $1F ; |...XXXXX|
   .byte $2A ; |..X.X.X.|
   .byte $6A ; |.XX.X.X.|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte COLOR_FLYING_SAUCER | [REFLECT >> 3]
Sailboat
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte COLOR_SAILBOAT | [REFLECT >> 3]
Llama
   .byte $00 ; |........|
   .byte $90 ; |X..X....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $22 ; |..X...X.|
   .byte $21 ; |..X....X|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte COLOR_LLAMA | [REFLECT >> 3]
Deer
   .byte $04 ; |.....X..|
   .byte $08 ; |....X...|
   .byte $90 ; |X..X....|
   .byte $B0 ; |X.XX....|
   .byte $90 ; |X..X....|
   .byte $F8 ; |XXXXX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $3F ; |..XXXXXX|
   .byte $2D ; |..X.XX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $02 ; |......X.|
   .byte $03 ; |......XX|
   .byte COLOR_DEER | [REFLECT >> 3]
Automobile
   .byte $00 ; |........|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $13 ; |...X..XX|
   .byte $39 ; |..XXX..X|
   .byte $3F ; |..XXXXXX|
   .byte $28 ; |..X.X...|
   .byte $2B ; |..X.X.XX|
   .byte $78 ; |.XXXX...|
   .byte $7B ; |.XXXX.XX|
   .byte $60 ; |.XX.....|
   .byte $7F ; |.XXXXXXX|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3B ; |..XXX.XX|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte COLOR_AUTOMOBILE | [REFLECT >> 3]
Castle
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $3C ; |..XXXX..|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $2A ; |..X.X.X.|
   .byte $3A ; |..XXX.X.|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $2F ; |..X.XXXX|
   .byte $2C ; |..X.XX..|
   .byte $2D ; |..X.XX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte $3D ; |..XXXX.X|
   .byte COLOR_CASTLE | [REFLECT >> 3]
Bunny
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $02 ; |......X.|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $1D ; |...XXX.X|
   .byte COLOR_BUNNY | [REFLECT >> 3]
WildCard
   .byte $88 ; |X...X...|
   .byte $88 ; |X...X...|
   .byte $A8 ; |X.X.X...|
   .byte $F8 ; |XXXXX...|
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
   .byte $00 ; |........|
   .byte $0F ; |....XXXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte COLOR_WILD_CARD | [NO_REFLECT >> 3]
CardNumberFonts
CardNumber_00
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte COLOR_CARD_FONTS | [NO_REFLECT >> 3]
CardNumber_01
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
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
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte COLOR_CARD_FONTS | [NO_REFLECT >> 3]
CardNumber_02
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte COLOR_CARD_FONTS | [NO_REFLECT >> 3]
CardNumber_03
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte COLOR_CARD_FONTS | [NO_REFLECT >> 3]
CardNumber_04
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $00 ; |........|
CardNumber_05
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7C ; |.XXXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $0E ; |....XXX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
CardNumber_06
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $78 ; |.XXXX...|
   .byte $7C ; |.XXXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
CardNumber_07
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
CardNumber_08
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
CardNumber_09
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3E ; |..XXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
CardBlank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte COLOR_CARD_FONTS | [NO_REFLECT >> 3]

   FILL_BOUNDARY 250, 234

   .word Start
   .word Start
   .word Start