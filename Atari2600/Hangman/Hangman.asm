   LIST OFF
; ***  H A N G M A N  ***
; Copyright 1978 Atari, Inc.
; Designer: Alan Miller

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: Sept. 24, 2019
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
;  ***  11 BYTES OF ROM FREE
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
;
; - All RAM utilized so no JSR/RTS used to preserve stack usage
; - Auto game over if idle for ~4 minutes
; - Words consist of no more than 6 letters (including NULL characters)
; - Grade level vocabulary words take up two pages in ROM
; - Dictionary changes for different regions
;   - Third grade
;     ===========
;     NTSC  COLOR
;     PAL50 COLOUR
;
;   - Sixth grade
;     ===========
;     NTSC  GLAMOR
;     PAL50 GLASS
;
;   - Ninth grade
;     ===========
;     NTSC  OMELET
;     PAL50 OBLIGE
;
;   - High School
;     ===========
;     NTSC  JALOPY
;     PAL50 JUMBLE

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

;
; The free bytes are different for the different compile regions. This value
; will be used with the FILL_BOUNDARY macro to ensure this is assembles to the
; exact released ROM.
;
   IF COMPILE_REGION = NTSC
   
FILL_BYTE               = 234

   ELSE
   
FILL_BYTE               = 0         

   ENDIF
   
;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

VERTICAL_SYNC_TIME      = 42

   IF COMPILE_REGION = NTSC

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 40

H_KERNEL                = 215
KERNEL_SKIPLINES        = 4
KERNEL_END              = H_KERNEL + 3

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 50

H_KERNEL                = 240
KERNEL_SKIPLINES        = 21
KERNEL_END              = H_KERNEL - 47

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
RED_ORANGE              = $20
RED                     = $40
PURPLE                  = $50
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
LT_BLUE                 = $90
CYAN                    = $A0
LT_BROWN                = $E0
BROWN                   = $F0

COLOR_3RD_GRADE_PLAYER_ONE = BROWN + 6
COLOR_3RD_GRADE_PLAYER_TWO = RED_ORANGE + 10
COLOR_3RD_GRADE_PLAYFIELD = LT_BLUE + 8
COLOR_3RD_GRADE_BACKGROUND = RED + 2

COLOR_6TH_GRADE_PLAYER_ONE = RED_ORANGE + 10
COLOR_6TH_GRADE_PLAYER_TWO = RED + 6
COLOR_6TH_GRADE_PLAYFIELD = ULTRAMARINE_BLUE + 4
COLOR_6TH_GRADE_BACKGROUND = LT_BROWN + 8

COLOR_9TH_GRADE_PLAYER_ONE = PURPLE + 6
COLOR_9TH_GRADE_PLAYER_TWO = RED_ORANGE + 10
COLOR_9TH_GRADE_PLAYFIELD = YELLOW + 6
COLOR_9TH_GRADE_BACKGROUND = CYAN + 2

COLOR_HIGH_SCHOOL_PLAYER_ONE = BROWN + 6
COLOR_HIGH_SCHOOL_PLAYER_TWO = RED + 6
COLOR_HIGH_SCHOOL_PLAYFIELD = BLUE + 3
COLOR_HIGH_SCHOOL_BACKGROUND = RED_ORANGE + 10
   
   ELSE
   
YELLOW                  = $20
GREEN                   = $30
DK_GREEN                = $50
RED                     = $60
COLBALT_BLUE            = $80
CYAN                    = $90
LT_BLUE                 = $B0
BLUE                    = $D0

COLOR_3RD_GRADE_PLAYER_ONE = COLBALT_BLUE + 6
COLOR_3RD_GRADE_PLAYER_TWO = YELLOW + 10
COLOR_3RD_GRADE_PLAYFIELD = LT_BLUE + 8
COLOR_3RD_GRADE_BACKGROUND = RED + 2

COLOR_6TH_GRADE_PLAYER_ONE = YELLOW + 10
COLOR_6TH_GRADE_PLAYER_TWO = RED + 6
COLOR_6TH_GRADE_PLAYFIELD = BLUE + 4
COLOR_6TH_GRADE_BACKGROUND = DK_GREEN + 8

COLOR_9TH_GRADE_PLAYER_ONE = COLBALT_BLUE + 6
COLOR_9TH_GRADE_PLAYER_TWO = YELLOW + 10
COLOR_9TH_GRADE_PLAYFIELD = LT_BLUE + 6
COLOR_9TH_GRADE_BACKGROUND = CYAN + 2

COLOR_HIGH_SCHOOL_PLAYER_ONE = GREEN + 6
COLOR_HIGH_SCHOOL_PLAYER_TWO = RED + 6
COLOR_HIGH_SCHOOL_PLAYFIELD = BLUE + 3
COLOR_HIGH_SCHOOL_BACKGROUND = YELLOW + 10

   ENDIF

BW_PLAYER_ONE           = BLACK
BW_PLAYER_TWO           = WHITE - 2
BW_PLAYFIELD            = BLACK + 4
BW_BACKGROUND           = BLACK + 8
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000
  
NUM_ROWS                = 20        ; number of playfield rows
H_KERNEL_SECTION        = 9
H_FONT                  = 5

NUM_LETTERS             = 27        ; letters plus NULL Letter character

MAX_INCORRECT_LETTER_COUNT = 11
MAX_SCORE               = 5
MAX_GAME_SELECTION      = 8
;
;game state values
;
SYSTEM_POWERUP          = %00010000
GAME_ON                 = 255
GAME_OVER               = 0
;
; game variation flags
;
TWO_PLAYER_OPPONENT     = 1 << 7
COMPOSING_WORD          = 1 << 6
TWO_PLAYERS             = 1 << 1
CURRENT_PLAYER_MASK     = %00000001
ONE_PLAYER              = 0 << 1

BIT_VALUE_SIXTH_LETTER  = 1
BIT_VALUE_FIFTH_LETTER  = 2
BIT_VALUE_FOURTH_LETTER = 4
BIT_VALUE_THIRD_LETTER  = 8
BIT_VALUE_SECOND_LETTER = 16
BIT_VALUE_FIRST_LETTER  = 32
;
; Number fonts LSB values
;
BLANK_LSB_VALUE         = <(Blank - NumberFonts)
ZERO_LSB_VALUE          = <(zero - NumberFonts)
ONE_LSB_VALUE           = <(one - NumberFonts)
TWO_LSB_VALUE           = <(two - NumberFonts)
THREE_LSB_VALUE         = <(three - NumberFonts)
FOUR_LSB_VALUE          = <(four - NumberFonts)
FIVE_LSB_VALUE          = <(five - NumberFonts)
SIX_LSB_VALUE           = <(six - NumberFonts)
SEVEN_LSB_VALUE         = <(seven - NumberFonts)
EIGHT_LSB_VALUE         = <(eight - NumberFonts)
NINE_LSB_VALUE          = <(nine - NumberFonts)

;===============================================================================
; M A C R O S
;===============================================================================

;-------------------------------------------------------------------------------
; FILL_BOUNDARY {byte#}, {byte filler}
; Original author: Dennis Debro (borrowed from Bob Smith / Thomas Jentzsch)
;
; Push data to a certain position inside a page and keep count of how
; many free bytes the programmer will have.
;
; eg: FILL_BOUNDARY 5, 234    ; position at byte #5 in page with $EA as filler
;
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

;-------------------------------------------------------------------------------
; COMPRESS_WORD {1st}, {2nd}, {3rd}, {4th}, {5th}, {6th}
;
; There are 27 possible lettervalues (alphabet + NULL character). This would
; take at most 5 bits. The Hangman words are limited to 6 letters. This equates
; to 30 bits. This makes a compacted Hangman word use 4 bytes (i.e. 30 / 8 ˜ 4)
;
   MAC COMPRESS_WORD
   
      .byte ([({1} - CharacterSet) / H_FONT] << 2) & 255 | [({2} - CharacterSet) / H_FONT] >> 3
      .byte ([({2} - CharacterSet) / H_FONT] << 5) & 255 | [({3} - CharacterSet) / H_FONT] & 31
      .byte ([({4} - CharacterSet) / H_FONT] << 2) & 255 | [({5} - CharacterSet) / H_FONT] >> 3
      .byte ([({5} - CharacterSet) / H_FONT] << 5) & 255 | [({6} - CharacterSet) / H_FONT] & 31
      
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

playfieldGraphics       ds 100
;--------------------------------------
pf0Graphics             = playfieldGraphics
leftPF1Graphics         = pf0Graphics + NUM_ROWS
leftPF2Graphics         = leftPF1Graphics + NUM_ROWS
rightPF1Graphics        = leftPF2Graphics + NUM_ROWS
rightPF2Graphics        = rightPF1Graphics + NUM_ROWS
frameCount              ds 1
wordDataPointer         ds 2
;--------------------------------------
tmpFoundLetterValues    = wordDataPointer
;--------------------------------------
tmpNextKernelSection    = tmpFoundLetterValues
;--------------------------------------
tmpWordIndexBit         = tmpNextKernelSection
;--------------------------------------
tmpReflectedLetterGraphic = wordDataPointer + 1
hueMask                 ds 1
;--------------------------------------
scoreGraphic1           = hueMask
;--------------------------------------
tmpLetterGraphic        = scoreGraphic1
colorXOR                ds 1
;--------------------------------------
scoreGraphic2           = colorXOR
;--------------------------------------
tmpSecondLetterGraphic  = scoreGraphic2
;--------------------------------------
tmpFourthLetterGraphic  = tmpSecondLetterGraphic
gameVariation           ds 1
selectDebounce          ds 1
playerScores            ds 2
;--------------------------------------
player1Score            = playerScores
player2Score            = player1Score + 1
gameState               ds 1
gameSelection           ds 1
selectedLetter          ds 1
letterSoundDuration     ds 1
gameIdleTimer           ds 1
incorrectLetterCount    ds 1
hangmanWord             ds 6
;--------------------------------------
hangmanFirstLetter      = hangmanWord
hangmanSecondLetter     = hangmanFirstLetter + 1
hangmanThirdLetter      = hangmanSecondLetter + 1
hangmanFourthLetter     = hangmanThirdLetter + 1
hangmanFifthLetter      = hangmanFourthLetter + 1
hangmanSixthLetter      = hangmanFifthLetter + 1
previousSelectedLetters ds 4
composedWordLetterValues ds 1
letterSelectTimer       ds 1
colorCycleTimer         ds 1

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                  ; wait for next scan line
;--------------------------------------
   sta VBLANK                 ; 3         enable TIA (D1 = 0)
   lda #MSBL_SIZE1 | PF_SCORE | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3 = @08   set playfield control to SCORE
   ldx #4                     ; 2
.skipKernelLines
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03   not needed...player graphics not used
   dex                        ; 2
   bne .skipKernelLines       ; 2³
   ldx #H_FONT                ; 2
   lda #0                     ; 2
   sta scoreGraphic1          ; 3
   sta scoreGraphic2          ; 3
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda scoreGraphic1          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @06
   lda player1Score           ; 3         get player1's score
   and #$F0                   ; 2         mask lower nybbles
   lsr                        ; 2         move upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2         set index value for offset
   lda NumberFontOffsets,y    ; 4         get number font ROM offset value
   clc                        ; 2
   adc NumberFontScanlineIncrement,x;4    increment by scan line value
   tay                        ; 2         set value to y index
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic1          ; 3         save it in the score graphic
   lda scoreGraphic2          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @48
   lda player1Score           ; 3         get player1's score
   and #$0F                   ; 2         mask upper nybbles
   tay                        ; 2         set index value for offset
   lda NumberFontOffsets,y    ; 4
   clc                        ; 2
   adc NumberFontScanlineIncrement,x;4    increment by scan line value
   sta WSYNC
;--------------------------------------
   tay                        ; 2         set value to y index
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask the upper nybble
   ora scoreGraphic1          ; 3         combine with score graphic value
   sta scoreGraphic1          ; 3
   sta PF1                    ; 3 = @17   set left score graphic value
   lda player2Score           ; 3         get player2's score
   and #$F0                   ; 2         mask lower nybbles
   lsr                        ; 2         move upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2         set index value for offset
   lda NumberFontOffsets,y    ; 4         get number font ROM offset value
   ldy scoreGraphic2          ; 3
   sty PF1                    ; 3 = @42   set right score graphic value
   clc                        ; 2
   adc NumberFontScanlineIncrement,x;4    increment by scan line value
   tay                        ; 2         set value to y index
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic2          ; 3         save it in the score graphic
   lda player2Score           ; 3         get player2's score
   and #$0F                   ; 2         mask upper nybbles
   sta WSYNC
;--------------------------------------
   tay                        ; 2         set index value for offset
   lda NumberFontOffsets,y    ; 4         get number font ROM offset value
   ldy scoreGraphic1          ; 3
   sty PF1                    ; 3 = @12   set left score graphic value
   clc                        ; 2
   adc NumberFontScanlineIncrement,x;4    increment by scan line value
   tay                        ; 2         set value to y index
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask upper nybbles
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   ora scoreGraphic2          ; 3         combine with score graphic value
   sta scoreGraphic2          ; 3
   sta PF1                    ; 3 = @41   set right score graphic value
   dex                        ; 2
   bmi GameKernel             ; 2³
   jmp ScoreKernel            ; 3
   
; --------------------- PF Timings --------------------
; | PF0 |   PF1   |   PF2   | PF0 |   PF1   |   PF2   |
; |22.??|27 ..  ??|38 ..  ??|48.51|54 ..  ??|64 ..  ??|
;
GameKernel SUBROUTINE
   lda #0                     ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta PF0                    ; 3 = @59   clear playfield graphic values
   sta PF2                    ; 3 = @62
   sta PF1                    ; 3 = @65
   sta CTRLPF                 ; 3 = @69   set to PF_NO_REFLECT (i.e. D0 = 0)
   ldx #KERNEL_SKIPLINES      ; 2
.skipKernelLines
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .skipKernelLines       ; 2³
   ldy #256 - H_KERNEL        ; 2
   lda #256 - H_KERNEL + H_KERNEL_SECTION;2
   sta tmpNextKernelSection   ; 3
   ldx #0                     ; 2         not needed...x already 0
.kernelSectionLoop
   sta WSYNC
;--------------------------------------
.gameKernelLoop
   lda pf0Graphics,x          ; 4         get PF0 graphic data
   asl                        ; 2         shift to upper nybbles
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   sta PF0                    ; 3 = @15   set left PF0 graphic value
   lda leftPF1Graphics,x      ; 4         get left PF1 graphic data
   sta PF1                    ; 3 = @22   set left PF1 graphic value
   lda leftPF2Graphics,x      ; 4         get left PF2 graphic data
   sta PF2                    ; 3 = @29   set left PF2 graphic value
   lda pf0Graphics,x          ; 4         get PF0 graphic data
   sta PF0                    ; 3 = @36   set right PF0 graphic value
   lda rightPF1Graphics,x     ; 4         get right PF1 graphic data
   sta PF1                    ; 3 = @43   set right PF1 graphic value
   iny                        ; 2         increment scan line count
   lda rightPF2Graphics,x     ; 4         get right PF2 graphic data
   sta PF2                    ; 3 = @52   set right PF2 graphic value
   cpy tmpNextKernelSection   ; 3
   bcc .kernelSectionLoop     ; 2³        branch if not done with kernel section
   inx                        ; 2         increment playfield graphic index
   tya                        ; 2         move scan line count to accumulator
   clc                        ; 2
   adc #H_KERNEL_SECTION      ; 2         increment by kernel section height
   sta tmpNextKernelSection   ; 3         set new kernel section limit
.overscanLoop
   iny                        ; 2         increment scan line
   beq VerticalSync           ; 2³        branch if frame done
   cpy #KERNEL_END            ; 2
   bcc .gameKernelLoop        ; 2³        branch if not done drawing kernel
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05   clear playfield graphics
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   sta WSYNC
;--------------------------------------
   beq .overscanLoop          ; 3         unconditional branch
   
VerticalSync SUBROUTINE
   lda #VERTICAL_SYNC_TIME
   sta HMCLR                        ; not needed...player graphics not used
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta TIM8T                        ; set timer for vertical sync period
   inc frameCount                   ; incremented each frame
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   jmp CheckSelectAndResetSwitch

Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   lda #SYSTEM_POWERUP
   sta gameState
ResetGame
   ldx #$FF
   txs                              ; set stack to the beginning
   stx selectedLetter               ; reset selected letter (i.e. x = -1)
   stx letterSoundDuration
   lda #0
   ldx #<[frameCount - playfieldGraphics]
.clearZPPlayfieldGraphics
   sta playfieldGraphics - 1,x
   dex
   bne .clearZPPlayfieldGraphics
   ldx #<[CXCLR - WSYNC]
.clearTIALoop
   sta NUSIZ0 + 63,x
   dex
   bne .clearTIALoop
   ldx #14
.clearGameVariables
   sta gameIdleTimer - 1,x
   dex
   bne .clearGameVariables
   sta AUDV0                        ; turn off sounds
   sta AUDV1
   lda gameSelection                ; get current game selection
   and #3                           ; keep mod4 value
   asl                              ; multiply value by 4
   asl
   tay                              ; set index to read color table
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; mask to get B/W switch value
   bne .setColorsLoop
   ldy #16                          ; set index to read B/W values
.setColorsLoop
   lda GameColorTable,y             ; read colors from game color table
   sta COLUP0,x                     ; set game colors from table values
   iny                              ; increment table read index
   inx
   cpx #<[COLUBK - COLUP0 + 1]
   bcc .setColorsLoop
   lda #31
   sta AUDF0
   sta AUDF1
   lda #12
   sta AUDC0
   sta AUDC1
   lda #%11111100
   sta pf0Graphics + NUM_ROWS - 1   ; set initial six blanks for letters
   lda #%11101111
   sta leftPF1Graphics + NUM_ROWS - 1
   lda #%01111101
   sta leftPF2Graphics + NUM_ROWS - 1
   lda #%10111110
   sta rightPF1Graphics + NUM_ROWS - 1
   lda #%00011111
   sta rightPF2Graphics + NUM_ROWS - 1
   lda gameVariation                ; get the current game variation
   bpl .setGameVariationValue       ; branch if not TWO_PLAYER_OPPONENT
   ora #COMPOSING_WORD              ; set to show player COMPOSING_WORD
.setGameVariationValue
   sta gameVariation
.determineVocabularyPointer
   inc frameCount                   ; increment frame count
   lda frameCount                   ; used for pseudo random LSB pointer
   asl                              ; multiply value by 4
   asl
   sta wordDataPointer              ; set the LSB for reading word library
   lda colorCycleTimer              ; get for pseudo random value
   and #7
   ora #>WordLibrary                ; combine with WordLibrary MSB
   sta wordDataPointer + 1          ; set the MSB for reading word library
   ldx gameSelection                ; get current game selection
   cpx #0
   beq .thirdGradeVocabulary        ; third grade vocabulary for games 1 and 5
   cpx #4
   beq .thirdGradeVocabulary
   cpx #1
   beq .sixthGradeVocabulary        ; sixth grade vocabulary for games 2 and 6
   cpx #5
   beq .sixthGradeVocabulary
   cpx #2
   beq .ninthGradeVocabulary        ; ninth grade vocabulary for games 3 and 7
   cpx #6
   beq .ninthGradeVocabulary
   cpx #3
   beq .highSchoolVocabulary        ; high school vocabulary for games 4 and 8
   cpx #7
   beq .highSchoolVocabulary
   bne .doneDetermineWordFromWordLibrary;unconditional branch
   
.thirdGradeVocabulary
   and #>(_3rdGradeLibrary | 256)
   sta wordDataPointer + 1
   bne DetermineWordFromWordLibrary ; unconditional branch
   
.sixthGradeVocabulary
   and #>(_6thGradeLibrary | 256)
   sta wordDataPointer + 1
   bne DetermineWordFromWordLibrary ; unconditional branch
   
.ninthGradeVocabulary
   and #>(_9thGradeLibrary | 256)
   sta wordDataPointer + 1
   bne DetermineWordFromWordLibrary ; unconditional branch
   
.highSchoolVocabulary
   lda wordDataPointer              ; get word data pointer LSB value
   cmp #256 - 8
   beq .determineVocabularyPointer  ; branch if 2 words from page end
   cmp #256 - 4
   beq .determineVocabularyPointer  ; branch if 1 word from page end
DetermineWordFromWordLibrary
   ldy #0
   ldx #0
.determineWordFromWordLibrary
   lda (wordDataPointer),y          ; get library letter data
   lsr                              ; divide value by 4
   lsr
   and #$1F
   sta hangmanWord,x                ; set word letter value
   iny
   lda (wordDataPointer),y          ; get next library letter data
   lsr                              ; divide value by 32
   lsr
   lsr
   lsr
   lsr
   sta hangmanWord + 1,x            ; set next word letter value
   dey
   lda (wordDataPointer),y          ; get word letter value
   asl                              ; multiply value by 8
   asl
   asl
   ora hangmanWord + 1,x            ; combine with next word letter value
   and #$1F
   sta hangmanWord + 1,x            ; set next word letter value
   iny
   lda (wordDataPointer),y          ; get next word letter value
   and #$1F
   sta hangmanWord + 2,x            ; set word letter value
   txa
   bne .doneDetermineWordFromWordLibrary
   inx
   inx
   inx
   iny
   jmp .determineWordFromWordLibrary
   
.doneDetermineWordFromWordLibrary
   jmp DisplayKernel
   
CheckSelectAndResetSwitch
   lda gameState                    ; get current game state
   cmp #SYSTEM_POWERUP
   bne .checkForResetSwitch         ; branch if not powering up
   lda #<-1
   sta gameSelection                ; initialize game selection
   lda #$3F
   sta composedWordLetterValues     ; set to show all letters found
   bne ShowGameSelection            ; unconditional branch
   
.checkForResetSwitch
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET to carry
   bcs .skipGameReset               ; branch if RESET not pressed
   lda #0
   bit gameState                    ; check current game state
   bvs .setToGameInProgress         ; branch if GAME_ON
   sta player1Score                 ; reset player score values
   sta player2Score
.setToGameInProgress
   sta selectDebounce               ; clear select debounce value
   lda #GAME_ON
   sta gameState                    ; set game state to GAME_ON
   jmp ResetGame
   
.skipGameReset
   lda frameCount                   ; get current frame count
   and #$3F
   bne .checkForSelectSwitch
   sta selectDebounce               ; clear select debounce (i.e. a = 0)
   inc colorCycleTimer
   inc letterSelectTimer            ; increment letter select timer
   inc gameIdleTimer                ; increment game idle timer
   bne .checkForSelectSwitch        ; branch if game not idle for 4 minutes
   lda #MAX_INCORRECT_LETTER_COUNT
   sta incorrectLetterCount         ; set to show reached max incorrect tries
   lda #GAME_OVER
   sta gameState                    ; set game state to GAME_OVER
.checkForSelectSwitch
   lda SWCHB                        ; read console switches
   and #SELECT_MASK
   beq .selectSwitchPressed         ; branch if SELECT pressed
   sta selectDebounce
   bne DetermineGameColors          ; unconditional branch
   
.selectSwitchPressed
   bit selectDebounce               ; check select debounce value
   bmi DetermineGameColors          ; branch if SELECT held
   lda #<-1
   sta selectDebounce               ; show the SELECT button is held
   lda #$3F
   sta composedWordLetterValues     ; set to show all letters found
   inc gameSelection                ; increment game selection
ShowGameSelection
   ldx #0
   stx player1Score                 ; reset score value to show game selection
   ldx gameSelection                ; get current game selection
   lda #(BLANK_LSB_VALUE / H_FONT) << 4 | (BLANK_LSB_VALUE / H_FONT)
   sta player2Score                 ; set player 2 score to Blank sprite
.setGameSelectionDisplay
   sed
   lda player1Score                 ; get player 1 score value
   clc
   adc #1                           ; increment value by 1
   sta player1Score                 ; set score value for game selection
   cld
   dex
   bne .setGameSelectionDisplay
   stx gameState                    ; set game state to GAME_OVER (i.e. x = 0)
   stx frameCount
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION + 1
   bcc .incrementGameSelectionDisplayValue;branch if not reached maximum selection
   stx player1Score                 ; reset player 1 score for game selection
   stx gameSelection                ; reset game selection value
.incrementGameSelectionDisplayValue
   sed
   clc
   lda player1Score                 ; get player 1 score value
   adc #1                           ; increment value by 1
   sta player1Score                 ; set score value for game selection
   cld
   ldx gameSelection                ; get current game selection
   lda GameVariationTable,x         ; get game variation for selected game
   sta gameVariation                ; set game variation value
DetermineGameColors SUBROUTINE
   lda gameSelection                ; get current game selection
   and #3                           ; keep mod4 value
   asl                              ; multiply value by 4
   asl
   tay                              ; set index to read color table
   ldx #0
   lda gameState                    ; get current game state
   eor #$FF                         ; flip the bits
   and colorCycleTimer
   sta colorXOR
   lda #$FF
   sta hueMask                      ; assume color (i.e. keep color hues)
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; mask to get B/W switch value
   bne .setColorsLoop
   lda #$0F
   sta hueMask                      ; mask color values for B/W option
   ldy #16                          ; set index to read B/W values
.setColorsLoop
   lda GameColorTable,y
   eor colorXOR
   and hueMask                      ; mask color hue
   bit gameState                    ; check current game state
   bvs .skipColorSet                ; branch if GAME_ON
   sta COLUP0,x
   lda #0
   sta AUDV0                        ; turn off sounds
   sta AUDV1
.skipColorSet
   iny
   inx
   cpx #<[COLUBK - COLUP0 + 1]
   bcc .setColorsLoop
   bit gameVariation                ; check current game variation
   bvs PlayChangingLetterSounds     ; branch if player COMPOSING_WORD
   bit gameState                    ; check current game state
   bvc PlayChangingLetterSounds     ; branch if GAME_OVER
   lda composedWordLetterValues     ; get found letter value
   cmp #$3F
   beq PlayChangingLetterSounds     ; branch if all letters found
   bit SWCHB                        ; check console difficulty switches
   bvc .checkPlayer2DifficultySettings;branch if player 1 set to AMATEUR
   lda gameVariation                ; get the current game variation
   and #CURRENT_PLAYER_MASK         ; see which player is currently active
   beq .checkLetterSelectTimerExhaution;branch if player 1 is active
.checkPlayer2DifficultySettings
   bit SWCHB                        ; check console difficulty switches
   bpl PlayChangingLetterSounds     ; branch if player 2 set to AMATEUR
   lda gameVariation                ; get the current game variation
   and #CURRENT_PLAYER_MASK         ; see which player is currently active
   beq PlayChangingLetterSounds     ; branch if player 1 is active
.checkLetterSelectTimerExhaution
   lda letterSelectTimer            ; get letter select timer value
   cmp #9
   bcc PlayChangingLetterSounds     ; branch if less than 9 seconds
   cmp #19
   bcc PlayTimeWarningSounds        ; warn player after 10 seconds
   jmp IncorrectLetterSelected
   
PlayTimeWarningSounds
   lda frameCount                   ; get current frame count
   and #1
   bne PlayChangingLetterSounds
   sta AUDV1                        ; set volume for warning sound
   lda frameCount                   ; get current frame count
   and #$3F
   bne PlayChangingLetterSounds
   lda #8
   sta AUDV1
PlayChangingLetterSounds
   inc letterSoundDuration
   lda letterSoundDuration
   cmp #8
   bne .playChangingLetterSounds
   lda #0
   sta AUDV0                        ; turn off letter sounds
.playChangingLetterSounds
   lda composedWordLetterValues     ; get found letter value
   cmp #$3F
   bne CheckToScrollThroughAlphabet ; branch if word not complete
   jmp DoneScrollThroughAlphabet
   
CheckToScrollThroughAlphabet
   lda incorrectLetterCount         ; get incorrect letter count
   and #$0F                         ; mask action button debounce value
   cmp #MAX_INCORRECT_LETTER_COUNT
   beq .joystickPushedUp            ; branch if reached max incorrect letters
   lda letterSoundDuration          ; get letter sound duration value
   cmp #208
   bcc ReadJoystickValues
   jmp DoneScrollThroughAlphabet
   
ReadJoystickValues
   lda gameVariation                ; get the current game variation
   and #CURRENT_PLAYER_MASK         ; mask to get active player
   bne .readRightPlayerJoystickValues;branch if right player active
   lda SWCHA                        ; read the player joystick values
   asl                              ; shift MOVE_DOWN to carry
   asl
   asl
   bcc .joystickPushedDown          ; branch if MOVE_DOWN
   asl                              ; shift MOVE_UP to carry
   bcc .joystickPushedUp            ; branch if MOVE_UP
   jmp DoneScrollThroughAlphabet
   
.readRightPlayerJoystickValues
   lda SWCHA                        ; read the player joystick values
   ror                              ; shift MOVE_UP to carry
   bcc .joystickPushedUp            ; branch if MOVE_UP
   ror                              ; shift MOVE_DOWN to carry
   bcc .joystickPushedDown          ; branch if MOVE_DOWN
   jmp DoneScrollThroughAlphabet
   
.joystickPushedUp
   lda letterSoundDuration          ; get letter sound duration value
   cmp #12
   bcs .resetGameIdleTimer
   bcc DoneScrollThroughAlphabet    ; unconditional branch
   
.resetGameIdleTimer
   lda #0                           ; reset letter selection debounce
   sta letterSoundDuration          ; reset letter sound duration value
   sta gameIdleTimer                ; reset game idle timer
.incrementLetterSelection
   inc selectedLetter
   lda #NUM_LETTERS
   cmp selectedLetter
   bne .checkForwardLetterUsed      ; branch if not reached maximum letters
   lda #0
   sta selectedLetter               ; reset selected letter
.checkForwardLetterUsed
   ldy selectedLetter               ; get current selected letter value
   lda PreviousSelectedLetterBitMask,y;get the bit mask value for the letter
   ldx PreviousSelectedLetterRAMIndexes,y;get index for previous select letter
   and previousSelectedLetters,x    ; and value with previous selected letters
   bne .incrementLetterSelection    ; branch if letter previously selected
   beq SelectedLetterToGraphic      ; unconditional branch
   
.joystickPushedDown
   lda letterSoundDuration          ; get letter sound duration value
   cmp #12
   bcc DoneScrollThroughAlphabet
   lda #0
   sta letterSoundDuration          ; reset letter sound duration value
   sta gameIdleTimer                ; reset game idle timer
.decrementLetterSelection
   dec selectedLetter
   lda selectedLetter               ; get current selected letter value
   cmp #<-1
   beq .setToCharacterSetEnd        ; branch if selected letter out of range
   cmp #<-2
   beq .setToCharacterSetEnd        ; branch if selected letter out of range
   jmp .checkBackwardsLetterUsed
   
.setToCharacterSetEnd
   lda #NUM_LETTERS - 1
   sta selectedLetter               ; set to NULL character
.checkBackwardsLetterUsed
   ldy selectedLetter               ; get current selected letter value
   lda PreviousSelectedLetterBitMask,y
   ldx PreviousSelectedLetterRAMIndexes,y;get index for previous select letter
   and previousSelectedLetters,x    ; and value with previous selected letters
   bne .decrementLetterSelection    ; branch if letter previously selected
SelectedLetterToGraphic
   lda selectedLetter               ; get current selected letter value
   asl                              ; multiply value by 5
   asl
   clc
   adc selectedLetter               ; x * 5 = (x * 4) + x
   adc #H_FONT - 1
   tay
   ldx #H_FONT
.setSelectedLetterGraphicValues
   lda CharacterSet,y
   sta rightPF1Graphics + 4,x
   dey
   dex
   bne .setSelectedLetterGraphicValues
   lda #$7F
   and incorrectLetterCount         ; clear action button debounce value
   sta incorrectLetterCount
   bit gameVariation                ; check current game variation
   bvs .setSelectedLetterSoundValues; branch if player COMPOSING_WORD
   ldy selectedLetter               ; get current selected letter value
   lda SelectedLetterAudioFrequencies,y;get audio frequency for selected leter
   sta AUDF0
.setSelectedLetterSoundValues
   lda #8
   sta AUDV0
   lda #12
   sta AUDC0
DoneScrollThroughAlphabet
   lda selectedLetter               ; get current selected letter value
   cmp #<-1
   bne CheckToSwitchPlayers         ; branch if letter not out of range
   lda #0
   sta selectedLetter               ; reset selected letter
   beq SelectedLetterToGraphic      ; unconditional branch
   
CheckToSwitchPlayers
   lda #0
   sta tmpNextKernelSection
   lda composedWordLetterValues     ; get found letter value
   cmp #$3F
   bne CheckToReadActionButton      ; branch if word not complete
   lda #0
   sta incorrectLetterCount         ; reset incorrect letter count
   bit gameVariation                ; check current game variation
   bvc .drawBlankIndicatorsUnderLetters;branch if player not COMPOSING_WORD
   lda #~COMPOSING_WORD
   and gameVariation                ; clear COMPOSING_WORD bit
   eor #CURRENT_PLAYER_MASK         ; flip to alternate current active player
   sta gameVariation
   lda #<-1
   sta selectedLetter               ; set selected letter out of range
   lda #0
   sta composedWordLetterValues     ; clear found letter values
   ldx #5
.clearWordGraphicValues
   sta pf0Graphics + 12,x
   sta leftPF1Graphics + 12,x
   sta leftPF2Graphics + 12,x
   sta rightPF1Graphics + 12,x
   sta rightPF2Graphics + 12,x
   dex
   bne .clearWordGraphicValues
   sta letterSelectTimer            ; clear letter select timer
   sta letterSoundDuration          ; clear letter sound duration value
.drawBlankIndicatorsUnderLetters
   jmp DrawBlankIndicatorsUnderLetters
   
CheckToReadActionButton
   lda incorrectLetterCount         ; get incorrect letter count
   and #$0F                         ; mask action button debounce value
   cmp #MAX_INCORRECT_LETTER_COUNT
   beq .setJoystickButtonDebounce   ; branch if reached max incorrect letters
   lda incorrectLetterCount         ; get incorrect letter count
   bpl .readActionButton            ; branch if action button held
   jmp DrawBlankIndicatorsUnderLetters
   
.readActionButton
   lda gameVariation                ; get the current game variation
   and #CURRENT_PLAYER_MASK         ; get the current active player number
   tax
   lda INPT4,x                      ; read action button of active player
   bpl .setJoystickButtonDebounce
   jmp DrawBlankIndicatorsUnderLetters
   
.setJoystickButtonDebounce
   lda #1 << 7
   ora incorrectLetterCount
   sta incorrectLetterCount         ; set to show action button pressed
   bit gameVariation                ; check current game variation
   bvc DetermineLetterNumberFound   ; branch if player not COMPOSING_WORD
   lda #1 << 6
   sta tmpWordIndexBit
   lda composedWordLetterValues     ; get found letter value
   rol
   rol
   ldx #<-1
.determineWordIndex
   lsr tmpWordIndexBit
   inx                              ; increment index value
   rol                              ; shift composed word D7 to carry
   bcs .determineWordIndex
   lda selectedLetter               ; get current selected letter value
   sta hangmanWord,x                ; set letter in appropriate position
   jmp PlayCorrectLetterSound
   
DetermineLetterNumberFound SUBROUTINE
   ldy selectedLetter               ; get current selected letter value
   lda PreviousSelectedLetterBitMask,y
   ldx PreviousSelectedLetterRAMIndexes,y;get index for previous select letter
   ora previousSelectedLetters,x
   sta previousSelectedLetters,x    ; set to show letter selected
   lda hangmanSixthLetter           ; get sixth letter of word
   cmp selectedLetter
   bne .checkForFindingFifthLetter  ; branch if not choosen sixth letter
   lda #BIT_VALUE_SIXTH_LETTER
   sta tmpFoundLetterValues         ; set to show sixth letter found
.checkForFindingFifthLetter
   lda hangmanFifthLetter           ; get fifth letter of word
   cmp selectedLetter
   bne .checkForFindingFourthLetter ; branch if not choosen fifth letter
   lda #BIT_VALUE_FIFTH_LETTER
   ora tmpFoundLetterValues
   sta tmpFoundLetterValues         ; set to show fifth letter found
.checkForFindingFourthLetter
   lda hangmanFourthLetter          ; get fourth letter of word
   cmp selectedLetter
   bne .checkForFindingThirdLetter  ; branch if not choosen fourth letter
   lda #BIT_VALUE_FOURTH_LETTER
   ora tmpFoundLetterValues
   sta tmpFoundLetterValues         ; set to show fourth letter found
.checkForFindingThirdLetter
   lda hangmanThirdLetter           ; get third letter of word
   cmp selectedLetter
   bne .checkForFindingSecondLetter ; branch if not choosen third letter
   lda #BIT_VALUE_THIRD_LETTER
   ora tmpFoundLetterValues
   sta tmpFoundLetterValues         ; set to show third letter found
.checkForFindingSecondLetter
   lda hangmanSecondLetter          ; get second letter of word
   cmp selectedLetter
   bne .checkForFindingFirstLetter  ; branch if not choosen second letter
   lda #BIT_VALUE_SECOND_LETTER
   ora tmpFoundLetterValues
   sta tmpFoundLetterValues         ; set to show second letter found
.checkForFindingFirstLetter
   lda hangmanFirstLetter           ; get first letter of word
   cmp selectedLetter
   bne .checkToPlayIncorrectLetterSound;branch if didn't find first letter
   lda #BIT_VALUE_FIRST_LETTER
   ora tmpFoundLetterValues
   sta tmpFoundLetterValues         ; set to show first letter found
.checkToPlayIncorrectLetterSound
   lda tmpFoundLetterValues         ; get found letter value
   bne PlayCorrectLetterSound       ; branch if some letters found
   lda selectedLetter               ; get current selected letter value
   cmp #NUM_LETTERS - 1
   beq .drawBlankIndicatorsUnderLetters;branch if selected NULL character
IncorrectLetterSelected
   bit gameState                    ; check current game state
   bvc .incrementIncorrectLetterCount;branch if GAME_OVER
   lda #8
   sta AUDF0
   sta AUDV0
   lda #15
   sta AUDC0
   lda #224
   sta letterSoundDuration
   lda incorrectLetterCount         ; get incorrect letter count
   and #$0F                         ; mask action button debounce value
   cmp #MAX_INCORRECT_LETTER_COUNT
   beq .incrementIncorrectLetterCount;branch if reached max incorrect letters
   cmp #MAX_INCORRECT_LETTER_COUNT - 1
   bne .incrementIncorrectLetterCount
   lda gameVariation                ; get the current game variation
   and #TWO_PLAYER_OPPONENT | COMPOSING_WORD | TWO_PLAYERS
   bne .incrementIncorrectLetterCount
   lda player2Score                 ; get player 2 score
   clc
   sed
   adc #1                           ; increment player 2 score
   sta player2Score
   cld
.incrementIncorrectLetterCount
   inc incorrectLetterCount
   lda #0
   sta letterSelectTimer            ; clear letter select timer
   sta AUDV1
   lda incorrectLetterCount         ; get incorrect letter count
   and #$0F                         ; mask action button debounce value
   tay
   cpy #MAX_INCORRECT_LETTER_COUNT + 1
   bne SetHangmanGraphicValues
   dey
   dec incorrectLetterCount
   bne .maxedIncorrectAttempts      ; unconditional branch
   
SetHangmanGraphicValues
   lda HangmanGraphicLeft,y
   sta leftPF1Graphics,y
   lda HangmanGraphicRight,y
   sta leftPF2Graphics,y
.maxedIncorrectAttempts
   lda gameVariation                ; get the current game variation
   and #TWO_PLAYERS
   beq .drawBlankIndicatorsUnderLetters;branch if a ONE_PLAYER game
   lda gameVariation                ; get the current game variation
   eor #CURRENT_PLAYER_MASK         ; flip to alternate current active player
   sta gameVariation
.drawBlankIndicatorsUnderLetters
   jmp DrawBlankIndicatorsUnderLetters
   
PlayCorrectLetterSound
   lda selectedLetter               ; get current selected letter value
   cmp #NUM_LETTERS - 1
   beq .silenceAudioChannel_01      ; branch if selected NULL character
   lda #8
   sta AUDF0
   sta AUDV0
   lda #12
   sta AUDC0
   lda #224
   sta letterSoundDuration
   lda #0
   sta letterSelectTimer            ; clear letter select timer
.silenceAudioChannel_01
   lda #0
   sta AUDV1
   lda selectedLetter               ; get current selected letter value
   asl                              ; multiply value by 5
   asl
   clc
   adc selectedLetter               ; x * 5 = (x * 4) + x
   adc #H_FONT - 1
   tay
   ldx #H_FONT
   lda selectedLetter               ; get current selected letter value
   cmp #NUM_LETTERS - 1
   bne SetFoundLetterGraphicValues  ; branch if not selected NULL character
   jmp CheckForCompletedWord
   
SetFoundLetterGraphicValues
.setFoundLetterGraphicValues
   lda CharacterSet,y
   sta tmpReflectedLetterGraphic    ; store graphic in temporary space
   sta tmpLetterGraphic
   ror tmpReflectedLetterGraphic    ; reflect graphic for playfield display
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   ror tmpReflectedLetterGraphic
   rol
   sta tmpReflectedLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   ora composedWordLetterValues
   sta composedWordLetterValues     ; set found letter value
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_SIXTH_LETTER      ; keep SIXTH_LETTER bit
   beq .checkToSetFifthLetterGraphic; branch if sixth letter not found
   lda tmpReflectedLetterGraphic
   lsr
   lsr
   lsr
   sta rightPF2Graphics + 12,x      ; set graphic for sixth letter
.checkToSetFifthLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_FIFTH_LETTER
   beq .checkToSetFourthLetterGraphic;branch if fifth letter not found
   lda tmpLetterGraphic
   asl
   ora rightPF1Graphics + 12,x      ; set graphic for fifth letter
   sta rightPF1Graphics + 12,x
.checkToSetFourthLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_FOURTH_LETTER
   beq .checkToSetThirdLetterGraphic; branch if fourth letter not found
   lda tmpReflectedLetterGraphic
   rol
   bcc .setPF0ValueForFourthLetter
   sta tmpFourthLetterGraphic
   lda #1 << 7
   ora rightPF1Graphics + 12,x      ; set graphic for fourth letter
   sta rightPF1Graphics + 12,x
   lda tmpFourthLetterGraphic
.setPF0ValueForFourthLetter
   and #$F0
   ora pf0Graphics + 12,x
   sta pf0Graphics + 12,x
.checkToSetThirdLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_THIRD_LETTER
   beq .checkToSetSecondLetterGraphic;branch if third letter not found
   lda tmpReflectedLetterGraphic
   lsr
   ora leftPF2Graphics + 12,x       ; set graphic for third letter
   sta leftPF2Graphics + 12,x
.checkToSetSecondLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_SECOND_LETTER
   beq .checkToSetFirstLetterGraphic; branch if second letter not found
   lda tmpLetterGraphic
   ror
   bcc .setPF1ValueForSecondLetter
   sta tmpSecondLetterGraphic
   lda #1 << 0
   ora leftPF2Graphics + 12,x       ; set graphic for second letter
   sta leftPF2Graphics + 12,x
   lda tmpSecondLetterGraphic
.setPF1ValueForSecondLetter
   and #$0F
   ora leftPF1Graphics + 12,x
   sta leftPF1Graphics + 12,x
.checkToSetFirstLetterGraphic
   lda tmpFoundLetterValues         ; get found letter value
   and #BIT_VALUE_FIRST_LETTER
   beq .nextFoundLetterGraphic      ; branch if first letter not found
   lda tmpReflectedLetterGraphic
   lsr
   and #$0C
   ora pf0Graphics + 12,x           ; set graphic for first letter
   sta pf0Graphics + 12,x
   lda tmpLetterGraphic
   asl
   asl
   asl
   asl
   asl
   and #$E0
   ora leftPF1Graphics + 12,x
   sta leftPF1Graphics + 12,x
.nextFoundLetterGraphic
   dey
   dex
   beq CheckForCompletedWord
   jmp .setFoundLetterGraphicValues
   
CheckForCompletedWord
   lda incorrectLetterCount         ; get incorrect letter count
   and #$0F                         ; mask action button debounce value
   cmp #MAX_INCORRECT_LETTER_COUNT
   beq DrawBlankIndicatorsUnderLetters
   bit gameVariation                ; check current game variation
   bvs DrawBlankIndicatorsUnderLetters;branch if player COMPOSING_WORD
   lda selectedLetter               ; get current selected letter value
   cmp #NUM_LETTERS - 1
   beq DrawBlankIndicatorsUnderLetters;branch if selected NULL character
   lda composedWordLetterValues     ; get found letter value
   cmp #$3F
   bne DrawBlankIndicatorsUnderLetters;branch if all letters not found
   lda gameVariation                ; get the current game variation
   and #CURRENT_PLAYER_MASK         ; get the current active player number
   tax
   sed
   lda playerScores,x               ; get active player's score
   clc
   adc #1                           ; increment score by 1
   cld
   sta playerScores,x
   lda gameVariation                ; get the current game variation
   and #TWO_PLAYER_OPPONENT | COMPOSING_WORD | TWO_PLAYERS
   beq DrawBlankIndicatorsUnderLetters
   lda playerScores,x               ; get player score
   cmp #MAX_SCORE
   bcc DrawBlankIndicatorsUnderLetters;branch if not reached MAX_SCORE
   lda #GAME_OVER
   sta gameState                    ; max score reached...set to GAME_OVER
   lda #MAX_INCORRECT_LETTER_COUNT
   sta incorrectLetterCount
DrawBlankIndicatorsUnderLetters
   lda hangmanFirstLetter           ; get first letter in word
   cmp #NUM_LETTERS - 1
   bne .checkToDrawBlankForSecondLetter;branch if first letter not NULL
   lda #%11110000
   sta pf0Graphics + NUM_ROWS - 1
   lda #%00001111
   sta leftPF1Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_FIRST_LETTER
   ora composedWordLetterValues     ; set to show first letter composed
   sta composedWordLetterValues
.checkToDrawBlankForSecondLetter
   lda hangmanSecondLetter
   cmp #NUM_LETTERS - 1
   bne .checkToDrawBlankForThirdLetter;branch if second letter not NULL
   lda #%11110000
   and leftPF1Graphics + NUM_ROWS - 1
   sta leftPF1Graphics + NUM_ROWS - 1
   lda #%01111100
   sta leftPF2Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_SECOND_LETTER
   ora composedWordLetterValues     ; set to show second letter composed
   sta composedWordLetterValues
.checkToDrawBlankForThirdLetter
   lda hangmanThirdLetter
   cmp #NUM_LETTERS - 1
   bne .checkToDrawBlankForFourthLetter;branch if third letter not NULL
   lda #%00000001
   and leftPF2Graphics + NUM_ROWS - 1
   sta leftPF2Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_THIRD_LETTER
   ora composedWordLetterValues     ; set to show third letter composed
   sta composedWordLetterValues
.checkToDrawBlankForFourthLetter
   lda hangmanFourthLetter
   cmp #NUM_LETTERS - 1
   bne .checkToDrawBlankForFifthLetter;branch if fourth letter not NULL
   lda #%00001111
   and pf0Graphics + NUM_ROWS - 1
   sta pf0Graphics + NUM_ROWS - 1
   lda #%00111110
   sta rightPF1Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_FOURTH_LETTER
   ora composedWordLetterValues     ; set to show fourth letter composed
   sta composedWordLetterValues
.checkToDrawBlankForFifthLetter
   lda hangmanFifthLetter
   cmp #NUM_LETTERS - 1
   bne .checkToDrawBlankForSixthLetter;branch if fifth letter not NULL
   lda #1 << 7
   and rightPF1Graphics + NUM_ROWS - 1
   sta rightPF1Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_FIFTH_LETTER
   ora composedWordLetterValues     ; set to show fifth letter composed
   sta composedWordLetterValues
.checkToDrawBlankForSixthLetter
   lda hangmanSixthLetter
   cmp #NUM_LETTERS - 1
   bne .doneDrawBlankIndicatorsUnderLetters;branch if sixth letter not NULL
   lda #0
   sta rightPF2Graphics + NUM_ROWS - 1
   lda #BIT_VALUE_SIXTH_LETTER
   ora composedWordLetterValues     ; set to show sixth letter composed
   sta composedWordLetterValues
.doneDrawBlankIndicatorsUnderLetters
   lda #0
   sta PF0
   sta PF1
   sta PF2
   jmp DisplayKernel
   
CharacterSet
A
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
   .byte $11 ; |...X...X|
B
   .byte $1F ; |...XXXXX|
   .byte $09 ; |....X..X|
   .byte $0F ; |....XXXX|
   .byte $09 ; |....X..X|
   .byte $1F ; |...XXXXX|
C
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
D
   .byte $1F ; |...XXXXX|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $09 ; |....X..X|
   .byte $1F ; |...XXXXX|
E
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
F
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
G
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $13 ; |...X..XX|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
H
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
I
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
J
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
K
   .byte $12 ; |...X..X.|
   .byte $14 ; |...X.X..|
   .byte $18 ; |...XX...|
   .byte $14 ; |...X.X..|
   .byte $12 ; |...X..X.|
L
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
M
   .byte $1F ; |...XXXXX|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
N
   .byte $11 ; |...X...X|
   .byte $19 ; |...XX..X|
   .byte $15 ; |...X.X.X|
   .byte $13 ; |...X..XX|
   .byte $11 ; |...X...X|
O
   .byte $1F ; |...XXXXX|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
P
   .byte $1F ; |...XXXXX|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
Q
   .byte $1E ; |...XXXX.|
   .byte $12 ; |...X..X.|
   .byte $12 ; |...X..X.|
   .byte $16 ; |...X.XX.|
   .byte $1F ; |...XXXXX|
R
   .byte $1E ; |...XXXX.|
   .byte $12 ; |...X..X.|
   .byte $1E ; |...XXXX.|
   .byte $14 ; |...X.X..|
   .byte $12 ; |...X..X.|
S
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $1F ; |...XXXXX|
   .byte $01 ; |.......X|
   .byte $1F ; |...XXXXX|
T
   .byte $1F ; |...XXXXX|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
U
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
V
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
W
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $1F ; |...XXXXX|
X
   .byte $11 ; |...X...X|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $11 ; |...X...X|
Y
   .byte $11 ; |...X...X|
   .byte $0A ; |....X.X.|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
Z
   .byte $1F ; |...XXXXX|
   .byte $02 ; |......X.|
   .byte $04 ; |.....X..|
   .byte $08 ; |....X...|
   .byte $1F ; |...XXXXX|
   
NULL
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   .byte $1F ; |...XXXXX|
   
SelectedLetterAudioFrequencies
   .byte 28, 28, 18, 18, 16, 16, 18, 20, 20, 22, 22, 25, 25
   .byte 25, 25, 28, 18, 18, 20, 20, 22, 25, 18, 22, 22, 25, 0
   
PreviousSelectedLetterBitMask
   .byte 1 << 7, 1 << 6, 1 << 5, 1 << 4, 1 << 3, 1 << 2, 1 << 1, 1 << 0
   .byte 1 << 7, 1 << 6, 1 << 5, 1 << 4, 1 << 3, 1 << 2, 1 << 1, 1 << 0
   .byte 1 << 7, 1 << 6, 1 << 5, 1 << 4, 1 << 3, 1 << 2, 1 << 1, 1 << 0
   .byte 1 << 7, 1 << 6
   
PreviousSelectedLetterRAMIndexes
   .byte 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
   .byte 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3
   
HangmanGraphics
HangmanGraphicLeft
   .byte $03 ; |......XX|
   .byte $FF ; |XXXXXXXX|
   .byte $C0 ; |XX......|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C1 ; |XX.....X|
   .byte $DF ; |XX.XXXXX|
   .byte $D7 ; |XX.X.XXX|
   .byte $D3 ; |XX.X..XX|
   .byte $DB ; |XX.XX.XX|
   .byte $C2 ; |XX....X.|
HangmanGraphicRight
   .byte $C6 ; |XX...XX.|
   .byte $3F ; |..XXXXXX|
   .byte $04 ; |.....X..|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $04 ; |.....X..|
   .byte $77 ; |.XXX.XXX|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $1F ; |...XXXXX|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   
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
   .byte $EE ; |XXX.XXX.|
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
   
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
GameColorTable
   .byte COLOR_3RD_GRADE_PLAYER_ONE, COLOR_3RD_GRADE_PLAYER_TWO
   .byte COLOR_3RD_GRADE_PLAYFIELD, COLOR_3RD_GRADE_BACKGROUND

   .byte COLOR_6TH_GRADE_PLAYER_ONE, COLOR_6TH_GRADE_PLAYER_TWO
   .byte COLOR_6TH_GRADE_PLAYFIELD, COLOR_6TH_GRADE_BACKGROUND

   .byte COLOR_9TH_GRADE_PLAYER_ONE, COLOR_9TH_GRADE_PLAYER_TWO
   .byte COLOR_9TH_GRADE_PLAYFIELD, COLOR_9TH_GRADE_BACKGROUND

   .byte COLOR_HIGH_SCHOOL_PLAYER_ONE, COLOR_HIGH_SCHOOL_PLAYER_TWO
   .byte COLOR_HIGH_SCHOOL_PLAYFIELD, COLOR_HIGH_SCHOOL_BACKGROUND
   
   .byte BW_PLAYER_ONE, BW_PLAYER_TWO, BW_PLAYFIELD, BW_BACKGROUND
   
NumberFontOffsets
   .byte ZERO_LSB_VALUE, ONE_LSB_VALUE, TWO_LSB_VALUE, THREE_LSB_VALUE
   .byte FOUR_LSB_VALUE, FIVE_LSB_VALUE, SIX_LSB_VALUE, SEVEN_LSB_VALUE
   .byte EIGHT_LSB_VALUE, NINE_LSB_VALUE, BLANK_LSB_VALUE
   
NumberFontScanlineIncrement
   .byte 4, 4, 3, 2, 1, 0
   
GameVariationTable
   .byte ONE_PLAYER
   .byte ONE_PLAYER
   .byte ONE_PLAYER
   .byte ONE_PLAYER
   .byte TWO_PLAYERS
   .byte TWO_PLAYERS
   .byte TWO_PLAYERS
   .byte TWO_PLAYERS
   .byte TWO_PLAYER_OPPONENT | COMPOSING_WORD
   
   FILL_BOUNDARY 0, FILL_BYTE       ; push to the next page
   
WordLibrary
_3rdGradeLibrary
    COMPRESS_WORD A, B, O, U, T, NULL
    COMPRESS_WORD A, F, T, E, R, NULL
    COMPRESS_WORD A, G, A, I, N, NULL
    COMPRESS_WORD A, L, W, A, Y, S
    COMPRESS_WORD A, R, R, I, V, E
    COMPRESS_WORD A, W, A, Y, NULL, NULL
    COMPRESS_WORD B, A, L, L, NULL, NULL
    COMPRESS_WORD B, E, E, N, NULL, NULL
    COMPRESS_WORD B, E, F, O, R, E
    COMPRESS_WORD B, E, S, T, NULL, NULL
    COMPRESS_WORD B, E, T, T, E, R
    COMPRESS_WORD B, I, T, T, E, R
    COMPRESS_WORD B, L, A, C, K, NULL
    COMPRESS_WORD B, L, U, E, NULL, NULL
    COMPRESS_WORD B, O, A, S, T, NULL
    COMPRESS_WORD B, R, A, N, C, H
    COMPRESS_WORD B, R, I, N, G, NULL
    COMPRESS_WORD B, R, O, W, N, NULL
    COMPRESS_WORD C, A, P, NULL, NULL, NULL
    COMPRESS_WORD C, H, I, L, L, Y
    COMPRESS_WORD C, H, O, O, S, E
    COMPRESS_WORD C, L, E, A, N, NULL
    COMPRESS_WORD C, L, E, A, R, NULL
    
    IF COMPILE_REGION = NTSC
    
    COMPRESS_WORD C, O, L, O, R, NULL
    
    ELSE
    
    COMPRESS_WORD C, O, L, O, U, R
    
    ENDIF
    
    COMPRESS_WORD C, O, U, L, D, NULL
    COMPRESS_WORD D, E, A, R, NULL, NULL
    COMPRESS_WORD D, O, L, L, NULL, NULL
    COMPRESS_WORD E, A, R, L, Y, NULL
    COMPRESS_WORD E, S, C, A, P, E
    COMPRESS_WORD E, V, E, R, Y, NULL
    COMPRESS_WORD F, A, L, S, E, NULL
    COMPRESS_WORD F, L, U, F, F, Y
    COMPRESS_WORD F, R, I, E, N, D
    COMPRESS_WORD G, I, F, T, NULL, NULL
    COMPRESS_WORD G, L, A, D, NULL, NULL
    COMPRESS_WORD G, R, E, E, N, NULL
    COMPRESS_WORD H, A, L, F, NULL, NULL
    COMPRESS_WORD H, A, V, E, NULL, NULL
    COMPRESS_WORD H, E, A, R, NULL, NULL
    COMPRESS_WORD H, I, K, E, NULL, NULL
    COMPRESS_WORD H, O, U, R, NULL, NULL
    COMPRESS_WORD I, N, V, E, N, T
    COMPRESS_WORD J, U, M, P, NULL, NULL
    COMPRESS_WORD J, U, S, T, NULL, NULL
    COMPRESS_WORD K, E, E, P, NULL, NULL
    COMPRESS_WORD K, I, N, D, NULL, NULL
    COMPRESS_WORD K, N, O, W, NULL, NULL
    COMPRESS_WORD L, A, N, D, NULL, NULL
    COMPRESS_WORD L, A, U, G, H, NULL
    COMPRESS_WORD L, E, A, P, NULL, NULL
    COMPRESS_WORD L, I, G, H, T, NULL
    COMPRESS_WORD L, I, T, T, L, E
    COMPRESS_WORD L, I, K, E, NULL, NULL
    COMPRESS_WORD L, I, V, E, NULL, NULL
    COMPRESS_WORD L, O, O, K, NULL, NULL
    COMPRESS_WORD L, O, W, E, R, NULL
    COMPRESS_WORD L, U, M, B, E, R
    COMPRESS_WORD M, A, G, N, E, T
    COMPRESS_WORD M, A, K, E, NULL, NULL
    COMPRESS_WORD M, A, N, Y, NULL, NULL
    COMPRESS_WORD M, A, S, H, NULL, NULL
    COMPRESS_WORD M, E, R, R, Y, NULL
    COMPRESS_WORD M, E, L, O, N, NULL
    COMPRESS_WORD M, I, L, K, NULL, NULL
    COMPRESS_WORD M, O, T, H, E, R
    COMPRESS_WORD M, U, C, H, NULL, NULL
    COMPRESS_WORD M, U, S, T, NULL, NULL
    COMPRESS_WORD N, A, M, E, NULL, NULL
    COMPRESS_WORD N, E, V, E, R, NULL
    COMPRESS_WORD N, I, G, H, T, NULL
    COMPRESS_WORD N, O, T, E, NULL, NULL
    COMPRESS_WORD N, U, R, S, E, NULL
    COMPRESS_WORD O, F, T, E, N, NULL
    COMPRESS_WORD O, N, C, E, NULL, NULL
    COMPRESS_WORD O, P, E, N, NULL, NULL
    COMPRESS_WORD O, V, E, R, NULL, NULL
    COMPRESS_WORD P, A, C, K, NULL, NULL
    COMPRESS_WORD P, I, C, K, NULL, NULL
    COMPRESS_WORD P, I, T, C, H, NULL
    COMPRESS_WORD P, L, A, I, N, NULL
    COMPRESS_WORD P, L, A, Y, NULL, NULL
    COMPRESS_WORD P, L, E, A, S, E
    COMPRESS_WORD P, R, E, T, T, Y
    COMPRESS_WORD P, U, L, L, NULL, NULL
    COMPRESS_WORD R, E, A, D, NULL, NULL
    COMPRESS_WORD R, E, P, A, Y, NULL
    COMPRESS_WORD R, I, D, E, NULL, NULL
    COMPRESS_WORD R, I, G, H, T, NULL
    COMPRESS_WORD R, O, U, N, D, NULL
    COMPRESS_WORD S, A, I, D, NULL, NULL
    COMPRESS_WORD S, C, H, O, O, L
    COMPRESS_WORD S, H, O, E, NULL, NULL
    COMPRESS_WORD S, I, L, E, N, T
    COMPRESS_WORD S, I, M, P, L, E
    COMPRESS_WORD S, L, E, E, P, NULL
    COMPRESS_WORD S, M, A, L, L, NULL
    COMPRESS_WORD S, O, M, E, NULL, NULL
    COMPRESS_WORD S, O, O, N, NULL, NULL
    COMPRESS_WORD S, T, O, P, NULL, NULL
    COMPRESS_WORD T, A, K, E, NULL, NULL
    COMPRESS_WORD T, E, L, L, NULL, NULL
    COMPRESS_WORD T, H, A, N, K, NULL
    COMPRESS_WORD T, H, E, I, R, NULL
    COMPRESS_WORD T, H, E, R, E, NULL
    COMPRESS_WORD T, H, E, Y, NULL, NULL
    COMPRESS_WORD T, H, I, N, K, NULL
    COMPRESS_WORD T, H, O, S, E, NULL
    COMPRESS_WORD T, H, R, E, E, NULL
    COMPRESS_WORD T, I, M, E, NULL, NULL
    COMPRESS_WORD T, O, D, A, Y, NULL
    COMPRESS_WORD T, R, E, E, NULL, NULL
    COMPRESS_WORD T, R, I, P, NULL, NULL
    COMPRESS_WORD V, E, R, S, E, NULL
    COMPRESS_WORD V, E, R, Y, NULL, NULL
    COMPRESS_WORD W, A, L, K, NULL, NULL
    COMPRESS_WORD W, E, A, K, NULL, NULL
    COMPRESS_WORD W, A, G, O, N, NULL
    COMPRESS_WORD W, E, A, R, NULL, NULL
    COMPRESS_WORD W, E, E, K, NULL, NULL
    COMPRESS_WORD W, H, A, T, NULL, NULL
    COMPRESS_WORD W, H, E, R, E, NULL
    COMPRESS_WORD W, H, I, C, H, NULL
    COMPRESS_WORD W, H, I, T, E, NULL
    COMPRESS_WORD W, I, N, K, NULL, NULL
    COMPRESS_WORD W, O, U, L, D, NULL
    COMPRESS_WORD W, R, E, N, C, H
    COMPRESS_WORD W, R, I, T, E, NULL
    COMPRESS_WORD Y, E, L, L, O, W
    
_6thGradeLibrary
    COMPRESS_WORD A, B, S, O, R, B
    COMPRESS_WORD A, C, H, E, NULL, NULL
    COMPRESS_WORD A, C, T, I, V, E
    COMPRESS_WORD A, D, M, I, R, E
    COMPRESS_WORD A, D, V, I, C, E
    COMPRESS_WORD A, D, U, L, T, NULL
    COMPRESS_WORD A, L, L, O, W, NULL
    COMPRESS_WORD A, M, O, N, G, NULL
    COMPRESS_WORD A, M, U, S, E, NULL
    COMPRESS_WORD A, N, N, U, A, L
    COMPRESS_WORD A, N, S, W, E, R
    COMPRESS_WORD B, E, G, I, N, NULL
    COMPRESS_WORD B, L, E, A, C, H
    COMPRESS_WORD B, O, A, R, D, NULL
    COMPRESS_WORD B, O, L, D, L, Y
    COMPRESS_WORD B, O, N, U, S, NULL
    COMPRESS_WORD B, R, A, V, E, NULL
    COMPRESS_WORD B, U, I, L, D, NULL
    COMPRESS_WORD C, H, O, O, S, E
    COMPRESS_WORD C, O, L, U, M, N
    COMPRESS_WORD C, O, M, B, A, T
    COMPRESS_WORD C, O, U, G, H, NULL
    COMPRESS_WORD C, O, U, N, T, NULL
    COMPRESS_WORD C, U, R, E, NULL, NULL
    COMPRESS_WORD D, E, F, E, N, D
    COMPRESS_WORD D, E, L, A, Y, NULL
    COMPRESS_WORD D, O, C, T, O, R
    COMPRESS_WORD D, R, A, M, A, NULL
    COMPRESS_WORD D, R, O, W, S, Y
    COMPRESS_WORD E, C, H, O, NULL, NULL
    COMPRESS_WORD E, F, F, O, R, T
    COMPRESS_WORD E, N, J, O, Y, NULL
    COMPRESS_WORD E, N, O, U, G, H
    COMPRESS_WORD E, S, C, O, R, T
    COMPRESS_WORD E, X, C, E, L, NULL
    COMPRESS_WORD E, X, P, A, N, D
    COMPRESS_WORD F, O, R, G, E, T
    COMPRESS_WORD F, O, R, T, Y, NULL
    COMPRESS_WORD F, R, O, W, N, NULL
    
    IF COMPILE_REGION = NTSC
    
    COMPRESS_WORD G, L, A, M, O, R
    
    ELSE
    
    COMPRESS_WORD G, L, A, S, S, NULL
    
    ENDIF
    
    COMPRESS_WORD G, O, S, S, I, P
    COMPRESS_WORD G, R, A, N, T, NULL
    COMPRESS_WORD G, R, A, Z, E, NULL
    COMPRESS_WORD G, R, E, E, D, Y
    COMPRESS_WORD G, R, I, E, F, NULL
    COMPRESS_WORD G, U, E, S, S, NULL
    COMPRESS_WORD H, A, B, I, T, NULL
    COMPRESS_WORD H, E, I, G, H, T
    COMPRESS_WORD H, O, A, R, S, E
    COMPRESS_WORD H, O, O, K, NULL, NULL
    COMPRESS_WORD H, U, M, I, D, NULL
    COMPRESS_WORD I, N, C, O, M, E
    COMPRESS_WORD I, N, S, E, C, T
    COMPRESS_WORD J, A, G, G, E, D
    COMPRESS_WORD K, I, N, D, L, E
    COMPRESS_WORD L, E, A, D, E, R
    COMPRESS_WORD L, E, G, A, L, NULL
    COMPRESS_WORD L, E, N, G, T, H
    COMPRESS_WORD L, I, A, B, L, E
    COMPRESS_WORD L, O, C, A, T, E
    COMPRESS_WORD L, O, Y, A, L, NULL
    COMPRESS_WORD L, U, X, U, R, Y
    COMPRESS_WORD M, A, G, I, C, NULL
    COMPRESS_WORD M, E, A, N, T, NULL
    COMPRESS_WORD M, E, D, D, L, E
    COMPRESS_WORD M, I, N, O, R, NULL
    COMPRESS_WORD M, I, N, U, T, E
    COMPRESS_WORD M, I, S, H, A, P
    COMPRESS_WORD M, O, D, E, R, N
    COMPRESS_WORD M, O, T, T, O, NULL
    COMPRESS_WORD N, A, S, T, Y, NULL
    COMPRESS_WORD N, O, R, M, A, L
    COMPRESS_WORD N, O, T, I, C, E
    COMPRESS_WORD O, B, J, E, C, T
    COMPRESS_WORD P, A, L, M, NULL, NULL
    COMPRESS_WORD P, I, E, C, E, NULL
    COMPRESS_WORD P, U, R, S, U, E
    COMPRESS_WORD P, A, N, I, C, NULL
    COMPRESS_WORD P, I, R, A, T, E
    COMPRESS_WORD P, L, E, D, G, E
    COMPRESS_WORD P, O, W, E, R, NULL
    COMPRESS_WORD P, R, I, D, E, NULL
    COMPRESS_WORD R, A, D, A, R, NULL
    COMPRESS_WORD R, A, I, D, E, R
    COMPRESS_WORD R, A, I, S, E, NULL
    COMPRESS_WORD R, E, A, D, Y, NULL
    COMPRESS_WORD R, E, A, S, O, N
    COMPRESS_WORD R, E, T, I, R, E
    COMPRESS_WORD R, E, S, U, L, T
    COMPRESS_WORD R, U, L, I, N, G
    COMPRESS_WORD R, U, M, B, L, E
    COMPRESS_WORD S, E, C, R, E, T
    COMPRESS_WORD S, E, V, E, R, E
    COMPRESS_WORD S, H, E, E, P, NULL
    COMPRESS_WORD S, I, G, H, T, NULL
    COMPRESS_WORD S, I, N, C, E, NULL
    COMPRESS_WORD S, L, O, G, A, N
    COMPRESS_WORD S, M, E, A, R, NULL
    COMPRESS_WORD S, O, L, V, E, NULL
    COMPRESS_WORD S, O, R, R, O, W
    COMPRESS_WORD S, T, R, I, C, T
    COMPRESS_WORD S, T, U, P, I, D
    COMPRESS_WORD S, U, F, F, E, R
    COMPRESS_WORD S, U, G, A, R, NULL
    COMPRESS_WORD S, Y, M, B, O, L
    COMPRESS_WORD T, A, L, E, N, T
    COMPRESS_WORD T, A, M, P, E, R
    COMPRESS_WORD T, E, M, P, T, NULL
    COMPRESS_WORD T, E, M, P, E, R
    COMPRESS_WORD T, H, E, F, T, NULL
    COMPRESS_WORD T, H, I, G, H, NULL
    COMPRESS_WORD T, H, R, E, A, T
    COMPRESS_WORD T, H, O, U, G, H
    COMPRESS_WORD T, H, U, M, P, NULL
    COMPRESS_WORD T, R, U, T, H, NULL
    COMPRESS_WORD U, N, K, I, N, D
    COMPRESS_WORD U, N, S, A, F, E
    COMPRESS_WORD U, R, G, E, N, T
    COMPRESS_WORD V, A, C, A, T, E
    COMPRESS_WORD V, A, N, I, S, H
    COMPRESS_WORD V, I, C, T, O, R
    COMPRESS_WORD V, I, S, U, A, L
    COMPRESS_WORD V, O, Y, A, G, E
    COMPRESS_WORD W, H, O, L, E, NULL
    COMPRESS_WORD W, I, S, D, O, M
    COMPRESS_WORD W, O, M, A, N, NULL
    COMPRESS_WORD Y, E, A, R, N, NULL
    COMPRESS_WORD Z, O, N, E, NULL, NULL
    
_9thGradeLibrary
    COMPRESS_WORD A, C, U, T, E, NULL
    COMPRESS_WORD A, D, A, P, T, NULL
    COMPRESS_WORD A, L, L, O, Y, NULL
    COMPRESS_WORD A, L, O, O, F, NULL
    COMPRESS_WORD B, E, A, U, T, Y
    COMPRESS_WORD B, I, C, K, E, R
    COMPRESS_WORD B, L, I, S, S, NULL
    COMPRESS_WORD B, O, T, A, N, Y
    COMPRESS_WORD B, R, I, B, E, NULL
    COMPRESS_WORD C, A, N, N, Y, NULL
    COMPRESS_WORD C, I, R, C, L, E
    COMPRESS_WORD C, L, E, A, V, E
    COMPRESS_WORD C, L, I, E, N, T
    COMPRESS_WORD C, O, D, D, L, E
    COMPRESS_WORD C, O, M, A, NULL, NULL
    COMPRESS_WORD D, A, T, A, NULL, NULL
    COMPRESS_WORD D, A, W, D, L, E
    COMPRESS_WORD D, E, C, E, I, T
    COMPRESS_WORD D, E, C, E, N, T
    COMPRESS_WORD D, E, F, E, C, T
    COMPRESS_WORD D, E, F, I, N, E
    COMPRESS_WORD D, E, P, O, S, E
    COMPRESS_WORD D, E, T, E, C, T
    COMPRESS_WORD D, R, I, F, T, NULL
    COMPRESS_WORD E, D, I, B, L, E
    COMPRESS_WORD E, F, F, E, C, T
    COMPRESS_WORD E, N, D, E, A, R
    COMPRESS_WORD E, N, G, U, L, F
    COMPRESS_WORD E, N, T, I, C, E
    COMPRESS_WORD E, X, A, M, NULL, NULL
    COMPRESS_WORD E, X, C, E, S, S
    COMPRESS_WORD F, A, L, T, E, R
    COMPRESS_WORD F, E, U, D, A, L
    COMPRESS_WORD F, I, C, K, L, E
    COMPRESS_WORD F, I, E, R, C, E
    COMPRESS_WORD F, I, G, U, R, E
    COMPRESS_WORD F, I, N, I, T, E
    COMPRESS_WORD G, A, L, A, X, Y
    COMPRESS_WORD G, A, U, N, T, NULL
    COMPRESS_WORD G, U, I, D, E, NULL
    COMPRESS_WORD H, A, V, E, N, NULL
    COMPRESS_WORD H, A, Z, A, R, D
    COMPRESS_WORD H, O, A, X, NULL, NULL
    COMPRESS_WORD H, U, M, B, L, E
    COMPRESS_WORD I, G, N, I, T, E
    COMPRESS_WORD I, M, P, E, L, NULL
    COMPRESS_WORD I, M, P, I, S, H
    COMPRESS_WORD I, M, P, U, R, E
    COMPRESS_WORD I, N, D, I, C, T
    COMPRESS_WORD I, N, D, U, C, E
    COMPRESS_WORD I, N, J, U, R, Y
    COMPRESS_WORD I, N, T, E, N, T
    COMPRESS_WORD I, N, V, I, T, E
    COMPRESS_WORD J, O, V, I, A, L
    COMPRESS_WORD L, A, I, R, NULL, NULL
    COMPRESS_WORD L, I, N, G, E, R
    COMPRESS_WORD L, E, G, I, O, N
    COMPRESS_WORD L, O, C, K, NULL, NULL
    COMPRESS_WORD L, U, R, K, NULL, NULL
    COMPRESS_WORD M, A, N, G, Y, NULL
    COMPRESS_WORD M, A, R, I, N, E
    COMPRESS_WORD M, I, S, F, I, T
    COMPRESS_WORD M, O, L, T, E, N
    COMPRESS_WORD M, O, R, A, L, E
    COMPRESS_WORD M, U, T, I, N, Y
    COMPRESS_WORD M, O, U, R, N, NULL
    COMPRESS_WORD N, A, U, S, E, A
    COMPRESS_WORD N, O, R, M, A, L
    COMPRESS_WORD N, O, V, E, L, NULL
    COMPRESS_WORD O, D, D, I, T, Y
    COMPRESS_WORD O, F, F, E, N, D
    
    IF COMPILE_REGION = NTSC
    
    COMPRESS_WORD O, M, E, L, E, T
    
    ELSE
    
    COMPRESS_WORD O, B, L, I, G, E
    
    ENDIF
    
    COMPRESS_WORD O, M, I, T, NULL, NULL
    COMPRESS_WORD O, R, D, A, I, N
    COMPRESS_WORD P, A, R, A, D, E
    COMPRESS_WORD P, E, R, I, L, NULL
    COMPRESS_WORD P, H, A, S, E, NULL
    COMPRESS_WORD P, I, C, K, L, E
    COMPRESS_WORD P, L, A, N, E, NULL
    COMPRESS_WORD P, R, E, F, E, R
    COMPRESS_WORD P, U, R, I, F, Y
    COMPRESS_WORD Q, U, A, K, E, NULL
    COMPRESS_WORD Q, U, E, S, T, NULL
    COMPRESS_WORD Q, U, O, R, U, M
    COMPRESS_WORD R, A, G, E, NULL, NULL
    COMPRESS_WORD R, A, M, B, L, E
    COMPRESS_WORD R, A, N, D, O, M
    COMPRESS_WORD R, A, T, I, O, N
    COMPRESS_WORD R, A, T, I, O, NULL
    COMPRESS_WORD R, E, A, C, T, NULL
    COMPRESS_WORD R, E, A, L, M, NULL
    COMPRESS_WORD R, E, C, E, N, T
    COMPRESS_WORD R, E, D, E, E, M
    COMPRESS_WORD R, E, L, I, C, NULL
    COMPRESS_WORD R, E, P, E, L, NULL
    COMPRESS_WORD R, E, V, E, R, T
    COMPRESS_WORD R, E, V, I, S, E
    COMPRESS_WORD R, E, V, O, L, T
    COMPRESS_WORD R, O, Y, A, L, NULL
    COMPRESS_WORD R, U, S, T, L, E
    COMPRESS_WORD S, A, N, E, NULL, NULL
    COMPRESS_WORD S, C, O, F, F, NULL
    COMPRESS_WORD S, H, A, M, E, NULL
    COMPRESS_WORD S, H, R, E, W, D
    COMPRESS_WORD S, I, E, G, E, NULL
    COMPRESS_WORD S, L, A, N, T, NULL
    COMPRESS_WORD S, O, B, E, R, NULL
    COMPRESS_WORD S, O, L, A, R, NULL
    COMPRESS_WORD S, U, P, P, L, E
    COMPRESS_WORD S, P, H, E, R, E
    COMPRESS_WORD T, A, R, I, F, F
    COMPRESS_WORD T, E, M, P, O, NULL
    COMPRESS_WORD T, I, M, E, L, Y
    COMPRESS_WORD T, I, M, I, D, NULL
    COMPRESS_WORD T, O, X, I, C, NULL
    COMPRESS_WORD U, N, R, U, L, Y
    COMPRESS_WORD U, P, H, O, L, D
    COMPRESS_WORD V, A, I, N, NULL, NULL
    COMPRESS_WORD V, A, R, Y, NULL, NULL
    COMPRESS_WORD V, E, T, O, NULL, NULL
    COMPRESS_WORD V, I, V, I, D, NULL
    COMPRESS_WORD V, O, L, U, M, E
    COMPRESS_WORD V, O, U, C, H, NULL
    COMPRESS_WORD W, E, L, D, NULL, NULL
    COMPRESS_WORD W, H, I, M, NULL, NULL
    COMPRESS_WORD W, I, T, C, H, NULL
    COMPRESS_WORD W, R, E, T, C, H
    COMPRESS_WORD Z, A, N, Y, NULL, NULL
    
HighSchoolLibrary
    COMPRESS_WORD A, B, S, U, R, D
    COMPRESS_WORD A, B, Y, S, S, NULL
    COMPRESS_WORD A, E, R, I, A, L
    COMPRESS_WORD A, I, S, L, E, NULL
    COMPRESS_WORD A, L, I, E, N, NULL
    COMPRESS_WORD A, L, P, A, C, A
    COMPRESS_WORD A, M, A, Z, E, D
    COMPRESS_WORD A, M, U, L, E, T
    COMPRESS_WORD A, R, C, T, I, C
    COMPRESS_WORD A, S, K, E, W, NULL
    COMPRESS_WORD B, A, L, L, O, T
    COMPRESS_WORD B, A, N, A, N, A
    COMPRESS_WORD B, L, A, Z, E, R
    COMPRESS_WORD B, U, R, E, A, U
    COMPRESS_WORD C, A, C, T, U, S
    COMPRESS_WORD C, A, J, O, L, E
    COMPRESS_WORD C, A, L, I, C, O
    COMPRESS_WORD C, A, L, L, O, W
    COMPRESS_WORD C, A, R, E, E, R
    COMPRESS_WORD C, A, U, L, K, NULL
    COMPRESS_WORD C, H, A, O, S, NULL
    COMPRESS_WORD C, H, A, S, M, NULL
    COMPRESS_WORD C, L, I, Q, U, E
    COMPRESS_WORD C, O, H, O, R, T
    COMPRESS_WORD C, O, U, S, I, N
    COMPRESS_WORD D, A, Z, Z, L, E
    COMPRESS_WORD D, E, B, R, I, S
    COMPRESS_WORD D, E, F, I, L, E
    COMPRESS_WORD D, E, L, U, G, E
    COMPRESS_WORD D, I, N, G, H, Y
    COMPRESS_WORD D, R, O, W, S, Y
    COMPRESS_WORD E, A, S, I, L, Y
    COMPRESS_WORD E, L, I, X, I, R
    COMPRESS_WORD E, X, O, T, I, C
    COMPRESS_WORD F, I, E, R, Y, NULL
    COMPRESS_WORD F, O, C, U, S, NULL
    COMPRESS_WORD F, O, S, S, I, L
    COMPRESS_WORD F, R, A, C, A, S
    COMPRESS_WORD F, R, E, N, Z, Y
    COMPRESS_WORD F, U, N, G, U, S
    COMPRESS_WORD G, A, U, G, E, NULL
    COMPRESS_WORD G, E, N, I, U, S
    COMPRESS_WORD G, E, Y, S, E, R
    COMPRESS_WORD G, R, O, T, T, O
    COMPRESS_WORD G, R, U, D, G, E
    COMPRESS_WORD G, Y, R, A, T, E
    COMPRESS_WORD H, E, C, T, I, C
    COMPRESS_WORD H, E, R, E, S, Y
    COMPRESS_WORD H, Y, B, R, I, D
    COMPRESS_WORD I, G, U, A, N, A
    COMPRESS_WORD I, N, D, I, G, O
    COMPRESS_WORD I, M, P, A, L, A
    COMPRESS_WORD I, N, F, L, U, X
    COMPRESS_WORD I, T, S, E, L, F
    
    IF COMPILE_REGION = NTSC
    
    COMPRESS_WORD J, A, L, O, P, Y
    
    ELSE
    
    COMPRESS_WORD J, U, M, B, L, E
    
    ENDIF
    
    COMPRESS_WORD J, A, G, U, A, R
    COMPRESS_WORD J, E, S, T, E, R
    COMPRESS_WORD J, E, W, E, L, NULL
    COMPRESS_WORD J, O, C, K, E, Y
    COMPRESS_WORD K, H, A, K, I, NULL
    COMPRESS_WORD K, I, D, N, E, Y
    COMPRESS_WORD K, I, M, O, N, O
    COMPRESS_WORD L, A, R, D, E, R
    COMPRESS_WORD L, A, X, I, T, Y
    COMPRESS_WORD L, I, N, E, A, R
    COMPRESS_WORD L, I, Z, A, R, D
    COMPRESS_WORD L, O, A, T, H, E
    COMPRESS_WORD M, A, N, I, A, NULL
    COMPRESS_WORD M, A, R, T, Y, R
    COMPRESS_WORD M, I, L, L, E, R
    COMPRESS_WORD M, U, R, M, U, R
    COMPRESS_WORD M, I, N, E, R, NULL
    COMPRESS_WORD M, U, S, C, L, E
    COMPRESS_WORD M, U, S, E, U, M
    COMPRESS_WORD M, Y, S, T, I, C
    COMPRESS_WORD N, A, I, V, E, NULL
    COMPRESS_WORD N, E, B, U, L, A
    COMPRESS_WORD N, I, C, K, E, L
    COMPRESS_WORD N, O, M, A, D, NULL
    COMPRESS_WORD N, O, Z, Z, L, E
    COMPRESS_WORD O, A, S, I, S, NULL
    COMPRESS_WORD O, C, E, L, O, T
    COMPRESS_WORD O, P, A, Q, U, E
    COMPRESS_WORD O, R, I, E, N, T
    COMPRESS_WORD O, R, N, A, T, E
    COMPRESS_WORD P, A, C, I, F, Y
    COMPRESS_WORD P, A, L, T, R, Y
    COMPRESS_WORD P, A, R, C, E, L
    COMPRESS_WORD P, A, T, H, O, S
    COMPRESS_WORD P, E, T, I, T, E
    COMPRESS_WORD P, L, A, S, M, A
    COMPRESS_WORD Q, U, A, R, T, Z
    COMPRESS_WORD Q, U, E, N, C, H
    COMPRESS_WORD Q, U, E, R, Y, NULL
    COMPRESS_WORD R, E, L, I, E, F
    COMPRESS_WORD R, A, N, C, I, D
    COMPRESS_WORD R, H, Y, T, H, M
    COMPRESS_WORD R, O, T, A, R, Y
    COMPRESS_WORD R, U, F, F, L, E
    COMPRESS_WORD S, A, F, E, T, Y
    COMPRESS_WORD S, A, L, A, R, Y
    COMPRESS_WORD S, E, A, N, C, E
    COMPRESS_WORD S, E, I, Z, E, NULL
    COMPRESS_WORD S, E, R, E, N, E
    COMPRESS_WORD S, H, R, E, W, D
    COMPRESS_WORD S, I, M, I, L, E
    COMPRESS_WORD S, O, L, E, M, N
    COMPRESS_WORD S, O, N, I, C, NULL
    COMPRESS_WORD S, U, R, V, E, Y
    COMPRESS_WORD T, H, E, O, R, Y
    COMPRESS_WORD T, H, I, E, F, NULL
    COMPRESS_WORD T, H, W, A, R, T
    COMPRESS_WORD T, O, R, Q, U, E
    COMPRESS_WORD T, Y, R, A, N, T
    COMPRESS_WORD U, N, I, Q, U, E
    COMPRESS_WORD V, A, C, U, U, M
    COMPRESS_WORD V, A, N, I, T, Y
    COMPRESS_WORD V, I, O, L, E, T
    COMPRESS_WORD V, O, G, U, E, NULL
    COMPRESS_WORD W, E, A, P, O, N
    COMPRESS_WORD W, E, I, R, D, NULL
    COMPRESS_WORD Y, A, C, H, T, NULL
    COMPRESS_WORD Y, I, E, L, D, NULL
    COMPRESS_WORD Y, O, L, K, NULL, NULL
    COMPRESS_WORD Z, E, N, I, T, H
    COMPRESS_WORD Z, I, T, H, E, R

   FILL_BOUNDARY <(ROM_BASE + 4096 - 6), FILL_BYTE; 4K ROM

   echo "***",(FREE_BYTES)d, "BYTES OF ROM FREE"
   
   .word Start                      ; NMI vector
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector