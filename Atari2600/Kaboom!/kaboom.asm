   LIST OFF
; ***  K A B O O M !  ***
; Copyright 1981 Activision, Inc.
; Programmer:  Larry Kaplan
; Graphics:    David Crane

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: August 20, 2004
;
;  *** 128 BYTES OF RAM USED 0 BYTES FREE
;  ***   2 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1981, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================

   processor 6502

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

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 48
OVERSCAN_TIME           = 33

   ELSE

FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 79   
OVERSCAN_TIME           = 61

   ENDIF

;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
YELLOW                  = $10
BRICK_RED               = $30
RED                     = $40
BLUE                    = $80
GREEN                   = $D0

WATER_COLOR             = BLUE + 8
LOGO_COLOR              = WATER_COLOR

   ELSE

YELLOW                  = $20
BRICK_RED               = $40
GREEN                   = $50
RED                     = $60
BLUE                    = $B0

WATER_COLOR             = BLUE + 6
LOGO_COLOR              = WATER_COLOR

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000
   
SELECT_DELAY            = 30

PADDLE_MIN              = 2
PADDLE_MAX              = 254

; kernel boundaries
H_KERNEL                = 85

XMIN                    = 5
XMAX                    = 118

MAX_BOMBS               = 8
MAX_BUCKETS             = 3

H_MAD_BOMBER            = 32
H_BOMB                  = 16
H_BUCKETS               = 16
H_SPLASH                = 8
H_ACTIVISION_LOGO       = 8
H_SCORE                 = 8

STARTING_EXPLODING_TIMER = 43
EXPLODING_FLASH_TIME    = STARTING_EXPLODING_TIMER - 11

; bomb group constants
BOMB_GROUP_MAX          = 8

MAX_BOMBS_GROUP1        = 10
MAX_BOMBS_GROUP2        = 20
MAX_BOMBS_GROUP3        = 30
MAX_BOMBS_GROUP4        = 40
MAX_BOMBS_GROUP5        = 50
MAX_BOMBS_GROUP6        = 75
MAX_BOMBS_GROUP7        = 100
MAX_BOMBS_GROUP8        = 150

DROPPING_FREQ           = 18
BOMB_DROP_RATE          = 1

; Mad Bomber traveling values
MAD_BOMBER_TRAVELING_LEFT  = $FF
MAD_BOMBER_TRAVELING_RIGHT = $00

; game state constances
LEVEL_DONE              = $7F
WAIT_LEVEL_START        = $FF

BONUS_BUCKET_FREQ       = 63
CATCHING_BOMB_FREQ      = 16

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
gameSelection           ds 1
frameCount              ds 1
randomSeed              ds 1
colorEOR                ds 1
hueMask                 ds 1
bomberKernelBGColor     ds 1
backgroundColor         ds 1
loopCount               ds 1
;--------------------------------------
scanline                = loopCount
tempCharHolder          ds 1
;--------------------------------------
tempXHolder             = tempCharHolder
;--------------------------------------
temp                    = tempXHolder
;--------------------------------------
scoreColor              = loopCount
player1ScoreColor       = scoreColor
player2ScoreColor       = scoreColor + 1
;--------------------------------------
bomberExpressionState   = tempCharHolder  ; only D7 is used for this
bombColors              ds H_BOMB - 1
bucketsFineCoarse       ds 1
madBomberFineCoarse     ds 1
madBomberHorizPosition  ds 1
madBomberDirection      ds 1
catchingBucketNumber    ds 1
bucketHorizPosition     ds 1
colorCycleMode          ds 1
selectDebounce          ds 1
playerNumber            ds 1        ; ranges from 0 - 1
currentPlayerVariables  ds 5
;--------------------------------------
remainingBuckets        = currentPlayerVariables
bombGroup               = remainingBuckets + 1
playerScore             = bombGroup + 1
reservedPlayerVariables ds 5
;--------------------------------------
reservedRemainingBuckets = reservedPlayerVariables
numberBombsDropped      ds 1
explodingBombNumber     ds 1
gameState               ds 1
bombExplodingTimer      ds 1
catchingBombSoundFreq   ds 1
bonusBucketSoundFreq    ds 1
bombDropVelocity        ds 1
bombFineCoarse          ds 9
bombLSB                 ds 9
bucketGraphics          ds H_BUCKETS * MAX_BUCKETS
thirdRowBucketGraphics  = bucketGraphics
secondRowBucketGraphics = thirdRowBucketGraphics + H_BUCKETS
firstRowBucketGraphics  = secondRowBucketGraphics + H_BUCKETS
digitPointer            ds 12
;--------------------------------------
paddleRangeMax          = digitPointer + 1
bombNumber              = digitPointer + 2
paddleValue             = digitPointer + 3
bombIndexCaught         = digitPointer + 4
tempBombGraphic         = digitPointer + 5
;--------------------------------------
tempCoarseValue         = tempBombGraphic
;--------------------------------------
splashGraphicLoopCount  = tempCoarseValue
bombGraphicPointer      = digitPointer + 6

   echo "***",(* - $80)d, "BYTES OF RAM USED", ($100 - *)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
   txa
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   jmp JumpIntoConsoleSwitchCheck
   
MainLoop
   ldx #18
.loadColorsLoop
   lda GameColors,x                 ; read the game colors from ROM
   ldy bombExplodingTimer
   cpy #EXPLODING_FLASH_TIME
   bcc .doExplodingFlash
   ldy explodingBombNumber          ; get the current exploding bomb
   bne .maskColorValues             ; branch if no bomb exploding
   cpx #4
   bcc .maskColorValues
   lda randomSeed
.doExplodingFlash
   eor bombExplodingTimer
.maskColorValues
   eor colorEOR
   and hueMask
   sta bomberKernelBGColor,x
   dex
   bpl .loadColorsLoop
   sta COLUBK                       ; color the Mad Bomber are background
   ldx playerNumber                 ; get the current player number
   lda scoreColor,x                 ; get the score color for the player
   sta COLUP0                       ; color the player's score
   sta COLUP1
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA
   sta COLUPF                 ; 3 = @06   color playfield black
   lda #MSBL_SIZE8 | PF_PRIORITY | PF_REFLECT; 2
   sta CTRLPF                 ; 3 = @11
   sta PF0                    ; 3 = @14   used to black out HMOVE lines
   ldy #THREE_COPIES          ; 2
   sty NUSIZ0                 ; 3 = @19
   sty NUSIZ1                 ; 3 = @22
   ldy #H_SCORE - 1           ; 2
   sty VDELP0                 ; 3 = @27   VDEL player0 and player 1 (D0 = 1)
   sty VDELP1                 ; 3 = @30
.scoreLoop
   sty loopCount              ; 3
   lda (digitPointer + 10),y  ; 5
   sta tempCharHolder         ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   lda (digitPointer),y       ; 5
   sta GRP0                   ; 3 = @08
   lda (digitPointer + 2),y   ; 5
   sta GRP1                   ; 3 = @16
   lda (digitPointer + 4),y   ; 5
   sta GRP0                   ; 3 = @24
   lda (digitPointer + 8),y   ; 5
   tax                        ; 2
   lda (digitPointer + 6),y   ; 5
   ldy tempCharHolder         ; 3
   sta GRP1                   ; 3 = @42
   stx GRP0                   ; 3 = @45
   sty GRP1                   ; 3 = @48
   sta GRP0                   ; 3 = @48
   ldy loopCount              ; 3
   dey                        ; 2
   bpl .scoreLoop             ; 2³
   iny                        ; 2 = @57   y = 0
   lda bombLSB                ; 3         get the bomb LSB to store in
   sta bombGraphicPointer     ; 3         the graphic pointer for animation
   lda bombFineCoarse         ; 3         get the bomb's fine/coarse value
   sta WSYNC                  ; 3 = @69
;--------------------------------------
   sty VDELP0                 ; 3 = @03   turn off the verical delay of the
   sty VDELP1                 ; 3 = @06   players (D1 = 0)
   sty GRP0                   ; 3 = @09   clear the player graphics
   sty GRP1                   ; 3 = @12
   sta REFP0                  ; 3 = @15   set reflect state
   sta HMP0                   ; 3 = @18   set the bomb's fine horiz position
   and #7                     ; 2         mask to get the coarse horiz value
   tax                        ; 2
.coarseMoveBomb
   dex                        ; 2
   bpl .coarseMoveBomb        ; 2³
   sta RESP0                  ; 3         set bomb's coarse position
   sta WSYNC
;--------------------------------------
   sty NUSIZ1                 ; 3 = @03   single copy of player 1 (y = 0)
   sty tempBombGraphic        ; 3         clear the temp bomb graphic
   sty NUSIZ0                 ; 3 = @09   single copy of player 0 (y = 0)
   lda madBomberFineCoarse    ; 3         get bomber's fine/coarse value
   sta HMP1                   ; 3 = @15   set bomber's fine horiz position
   and #7                     ; 2         mask to get the coarse horiz value
   tax                        ; 2
   lda bombDropVelocity       ; 3         subtraction must start @ cycle 22
.coarseMoveMadBomber
   dex                        ; 2
   bpl .coarseMoveMadBomber   ; 2³
   sta RESP1                  ; 3         set bomber's coarse position
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   ldx #H_MAD_BOMBER - 1      ; 2
   ora #H_BOMB * 2            ; 2
   tay                        ; 2
   lda playerScore            ; 3         get the player's score (MSB)
   cmp #1                     ; 2         see if the player scored >= 100,000
   ror bomberExpressionState  ; 5         rotate carry into D7
   bmi DrawMadBomber          ; 2³
   lda bombExplodingTimer     ; 3
   bne .colorMadBomberLoop    ; 2³
   lda remainingBuckets       ; 3
   beq .colorMadBomberLoop    ; 2³
DrawMadBomber
   lda MadBomberColors,x      ; 4
   eor colorEOR               ; 3
   and hueMask                ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda MadBomber,x            ; 4
   cpx #22                    ; 2         are we drawing Bomber's upper mouth
   bne .checkForLowerMouth    ; 2³        if not check lower mouth
   lda #%01101100             ; 2         Mad Bomber frown graphic
.checkForLowerMouth
   bcs .drawMadBomber         ; 2³
   lda #%01101100             ; 2         Mad Bomber surprise graphic
   bit bomberExpressionState  ; 3
   bmi .drawMadBomber         ; 2³
   lda #%01010100             ; 2         Mad Bomber smile graphic
.drawMadBomber
   sta GRP1                   ; 3
   dey                        ; 2
   dex                        ; 2
   cpx #21                    ; 2
   bcs DrawMadBomber          ; 2³
.colorMadBomberLoop
   lda MadBomberColors,x      ; 4
   eor colorEOR               ; 3
   and hueMask                ; 3
   cpx #3                     ; 2
   bne .colorMadBomber        ; 2³ + 1    crosses page boundary
   lda backgroundColor        ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   sta COLUBK                 ; 3 = @03
   jmp .drawBombHeldByBomber  ; 3
   
.colorMadBomber
   sta WSYNC                  ; 3
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda MadBomber,x            ; 4
   sta GRP1                   ; 3 = @10
.drawBombHeldByBomber
   lda bombColors - 1,y       ; 4
   sta COLUP0                 ; 3 = @17
   lda tempBombGraphic        ; 3
   sta GRP0                   ; 3 = @23
   dey                        ; 2
   cpy #H_BOMB                ; 2
   bcs .skipDrawHeldBomb      ; 2³
   lda (bombGraphicPointer),y ; 5
   sta tempBombGraphic        ; 3
.skipDrawHeldBomb
   dex                        ; 2
   bpl .colorMadBomberLoop    ; 2³ + 1    crosses page boundary
   lda SWCHB                  ; 4         read the console switches
   ldx playerNumber           ; 3         get the current player number
   bne .onePlayerGame         ; 2³        get player 1 difficulty value
   asl                        ; 2         shift to get difficulty in carry
.onePlayerGame
   asl                        ; 2
   lda #ONE_COPY              ; 2
   sta bombNumber             ; 3         reset bomb number at kernel start
   bcs .skipDoubleSizeBuckets ; 2³
   lda #DOUBLE_SIZE           ; 2
.skipDoubleSizeBuckets
   sta WSYNC                  ; 3
;--------------------------------------
   sta NUSIZ1                 ; 3         set size of player buckets
   lda bombColors - 1,y       ; 4
   sta COLUP0                 ; 3 = @10
   lda tempBombGraphic        ; 3
   sta GRP0                   ; 3 = @16
   lda #0                     ; 2
   sta GRP1                   ; 3 = @21   clear the Mad Bomber graphic
   sta CXCLR                  ; 3 = @24   clear all previous collisions
   bcc .calibratePaddle       ; 2³        branch if difficulty set to AMATEUR
   lda #10                    ; 2
.calibratePaddle
   clc                        ; 2
   adc #108                   ; 2
   sta paddleRangeMax         ; 3
   adc #6                     ; 2
   sta paddleValue            ; 3
   lda #H_KERNEL              ; 2         get the kernel height
   sta scanline               ; 3         store it (decremented in kernel)
   dey                        ; 2
   bmi StartBombKernel        ; 2³
.topDroppingBombKernel
   cpy #H_BOMB                ; 2
   bcc .drawTopDroppingBomb   ; 2³
   sta WSYNC                  ; 3
;--------------------------------------
   dec scanline               ; 5
   dey                        ; 2
   bne .topDroppingBombKernel ; 2³
.drawTopDroppingBomb
   lda (bombGraphicPointer),y ; 5
   sta WSYNC                  ; 3
;--------------------------------------
   sta GRP0                   ; 3 = @03   draw the bomb graphic
   lda bombColors - 1,y       ; 4         get the bomb colors to
   sta COLUP0                 ; 3 = @10   color the bomb
   dec scanline               ; 5         reduce the scanline count
   lda INPT0,x                ; 4         read the paddle controller
   bmi .skipReducePaddleValue ; 2³        check if capacitor charged
   dec paddleValue            ; 5
.skipReducePaddleValue
   dey                        ; 2
   bpl .drawTopDroppingBomb   ; 2³
StartBombKernel SUBROUTINE
   sta WSYNC                  ; 3
;--------------------------------------
   inc bombNumber             ; 5         increment bomb number
   ldy bombNumber             ; 3         load y with bomb number for index
   lda bombFineCoarse,y       ; 4         get the fine/coarse value for bomb
   sta HMP0                   ; 3 = @15   set bomb's fine motion value
   sta REFP0                  ; 3 = @18   set reflect state
   and #7                     ; 2         mask the fine motion value
   tay                        ; 2         move to y for coarse movement
.coarseMoveBomb
   dey                        ; 2
   bpl .coarseMoveBomb        ; 2³
   sta RESP0                  ; 3         set bomb's coarse position
   sta WSYNC                  ; 3
;--------------------------------------
   ldy bombNumber             ; 3         load y with bomb number for index
   lda bombLSB,y              ; 4         get the bomb's sprite LSB
   sta bombGraphicPointer     ; 3         store it in graphic pointer
   SLEEP 2                    ; 2         waste 2 cycles so coarse
   lda bucketsFineCoarse      ; 3         get bucket's fine/coarse value
   sta HMP1                   ; 3 = @18   set bucket's fine motion
   and #7                     ; 2         mask the fine motion value
   tay                        ; 2         move to y for coarse movement
.coarseMoveBuckets
   dey                        ; 2
   bpl .coarseMoveBuckets     ; 2³
   sta RESP1                  ; 3         set bucket's coarse position
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   ldy #H_BOMB - 1            ; 2
   lda (bombGraphicPointer),y ; 5
   sta GRP0                   ; 3 = @13   draw the bomb graphic
   lda bombColors - 1,y       ; 4         get the bomb colors to
   sta COLUP0                 ; 3         color the bomb
   lda INPT0,x                ; 4         read the paddle controller
   bmi .skipReducePaddleValue ; 2³        check if capacitor charged
   dec paddleValue            ; 5         reduce paddle value if not charged
.skipReducePaddleValue
   dey                        ; 2
   sta HMCLR                  ; 3 = @36   clear horizontal movements
DroppingBombKernel SUBROUTINE
.drawBomb
   lda bombNumber             ; 3         get the current bomb number
   cmp explodingBombNumber    ; 3         skip the explosion random colors
   bne .skipExplosionColor    ; 2³        if this is not an exploding bomb
   lda randomSeed             ; 3         get the random number
   sta bombColors - 1,y       ; 5         set the color of the bomb explosion
.skipExplosionColor
   lda (bombGraphicPointer),y ; 5
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03   draw the bomb
   lda bombColors - 1,y       ; 4         get the color for the bomb
   sta COLUP0                 ; 3 = @10   color the bomb
.bombKernelLoop
   dec scanline               ; 5
   beq DrawBucketKernel       ; 2³ + 1    crosses page boundary
   lda INPT0,x                ; 4         read the paddle controller
   bmi .skipReducePaddleValue ; 2³        check if capacitor charged
   dec paddleValue            ; 5         reduce paddle value if not charged
.skipReducePaddleValue
   dey                        ; 2
   bpl .drawBomb              ; 2³
   inc bombNumber             ; 5         increment bomb number
   ldy bombNumber             ; 3         load y with bomb number for index
   lda bombLSB,y              ; 4         get the bomb's sprite LSB
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2         waste 2 cycles for coarse move
   sta bombGraphicPointer     ; 3         store it in graphic pointer
   sty bombIndexCaught        ; 3         assume bomb will be caught by bucket
   lda bombFineCoarse,y       ; 4         get the fine/coarse value for bomb
   sta HMP0                   ; 3 = @15   set bomb's fine motion value
   sta REFP0                  ; 3 = @18   set reflect state
   and #7                     ; 2         mask the fine motion value
   tay                        ; 2         move to y for coarse movement
.coarseMoveBomb
   dey                        ; 2
   bpl .coarseMoveBomb        ; 2³
   sta RESP0                  ; 3         set bomb's coarse position
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #H_BOMB                ; 2
   dec scanline               ; 5
   beq JumpIntoBucketKernel   ; 2³ + 1    crosses page boundary
   bne .bombKernelLoop        ; 3         unconditional branch
   
DrawBucketKernel SUBROUTINE
   ldx #H_BUCKETS * MAX_BUCKETS;2
   dey                        ; 2
   bmi .doNextBomb            ; 2³
   bpl .determineBombColor    ; 3         unconditional branch

JumpIntoBucketKernel
   dey                        ; 2
   ldx #H_BUCKETS * MAX_BUCKETS - 1;2
.drawBucketKernelLoop
   stx tempXHolder            ; 3
   ldx playerNumber           ; 3         get the current player number
   lda INPT0,x                ; 4         read the paddle controller
   bmi .resetKernelScanline   ; 2³        check if capacitor charged
   dec paddleValue            ; 5         reduce paddle value if not charged
.resetKernelScanline
   ldx tempXHolder            ; 3
.determineBombColor
   lda bombNumber             ; 3         get the current bomb number
   cmp explodingBombNumber    ; 3         skip the explosion random colors
   bne .skipExplosionColor    ; 2³        if this is not an exploding bomb
   lda BucketColors - 1,x     ; 4         get the bucket colors
   and hueMask                ; 3
   sta WSYNC
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda.w randomSeed           ; 4         get the random number
   sta COLUP0                 ; 3 = @10   set the color of the bomb explosion
   jmp .drawBucket            ; 3
   
.skipExplosionColor
   lda BucketColors - 1,x     ; 4
   eor colorEOR               ; 3
   and hueMask                ; 3
   sta WSYNC
;--------------------------------------
   sta COLUP1                 ; 3 = @03
   lda bombColors - 1,y       ; 4
   sta COLUP0                 ; 3 = @10
.drawBucket
   lda bucketGraphics - 1,x   ; 4
   sta GRP1                   ; 3 = @20
   lda (bombGraphicPointer),y ; 5
   sta GRP0                   ; 3 = @28
   dex                        ; 2
   beq CopyrightKernel        ; 2³
   dey                        ; 2
.nextBucket
   bpl .drawBucketKernelLoop  ; 2³
.doNextBomb
   inc bombNumber             ; 5         increment bomb number
   ldy bombNumber             ; 3         load y with bomb number for index
   bit CXPPMM                 ; 3         check player to player collisions
   bmi .bombCaught            ; 2³        branch if P0 and P1 collide
   sty bombIndexCaught        ; 3
.bombCaught
   lda bombLSB,y              ; 4         get the bomb's sprite LSB
   sta bombGraphicPointer     ; 3         store it in graphic pointer
   lda bombFineCoarse,y       ; 4         get the fine/coarse value for bomb
   sta HMP0                   ; 3 = @66   set bomb's fine motion value
   sta REFP0                  ; 3 = @69   set reflect state (wiggle wick)
   and #7                     ; 2         mask the fine motion value
   sta WSYNC
;--------------------------------------
   tay                        ; 2         move to y for coarse movement
   lda BucketColors - 1,x     ; 4
   eor colorEOR               ; 3
   and hueMask                ; 3
   sta COLUP1                 ; 3 = @15
   lda bucketGraphics - 1,x   ; 4
   sta GRP1                   ; 3 = @22
.coarseMoveBomb_b
   dey                        ; 2
   bpl .coarseMoveBomb_b      ; 2³
   sta RESP0                  ; 3
   lda BombColors + 13,x      ; 4
   eor colorEOR               ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2
   beq .jmpIntoCopyrightKernel; 2³
   and hueMask                ; 3
   sta COLUP1                 ; 3 = @13
   lda bucketGraphics - 1,x   ; 4
   sta GRP1                   ; 3 = @20
   ldy #H_BOMB - 1            ; 2
   dex                        ; 2
   bne .nextBucket            ; 2³
CopyrightKernel
   sta WSYNC
;--------------------------------------
.jmpIntoCopyrightKernel
   stx GRP0                   ; 3         clear the player graphics (x = 0)
   stx GRP1                   ; 3
   lda colorEOR               ; 3
   and hueMask                ; 3
   sta WSYNC
;--------------------------------------
   sta.w COLUBK               ; 4 = @04
   eor #LOGO_COLOR            ; 2
   and hueMask                ; 3
   sta COLUP0                 ; 3 = @12
   sta COLUP1                 ; 3 = @15
   stx HMCLR                  ; 3 = @18   clear horizontal movements
   stx REFP0                  ; 3 = @21
   stx REFP1                  ; 3 = @24
   lda #HMOVE_L1 | TWO_COPIES ; 2
   sta NUSIZ0                 ; 3 = @29
   sta NUSIZ1                 ; 3 = @32
   sta HMP1                   ; 3 = @35   move player 1 left 1 pixel
   sta RESP0                  ; 3 = @38   player 0 @ pixel 114
   sta RESP1                  ; 3 = @41   player 1 @ pixel 122
   ldx #H_ACTIVISION_LOGO - 1 ; 2
.activisionLogoLoop
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda Copyright0,x           ; 4
   sta GRP0                   ; 3 = @10
   lda Copyright1,x           ; 4
   sta GRP1                   ; 3 = @17
   jsr Waste12Cycles          ; 12
   lda Copyright3,x           ; 4
   tay                        ; 2
   lda Copyright2,x           ; 4
   sta GRP0                   ; 3 = @42
   sty GRP1                   ; 3 = @45
   sta HMCLR                  ; 3 = @48
   dex                        ; 2
   bpl .activisionLogoLoop    ; 2³
Overscan SUBROUTINE
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan
   ldx SWCHA                        ; read the paddle fire buttons
   inx
   beq CalculateBucketPosition      ; branch if fire buttons not pressed
   sty colorCycleMode               ; y = 0 from above copyright loop
CalculateBucketPosition
   sec                              ; set carry for subtraction
   lda paddleValue                  ; get the paddle value
   sbc #5                           ; subtract by 5
   bpl .calcPaddleBucketPosDelta    ; keep the value if not negative
   tya                              ; set accumulator to 0
.calcPaddleBucketPosDelta
   sec                              ; set carry for subtraction
   sbc bucketHorizPosition
   clc                              ; clear carry for rotation below
   bpl .compareToPaddleRange        ; branch if subtraction is positive
   sec                              ; set carry for rotation
.compareToPaddleRange
   ror                              ; rotate a right (carry now in D7)
   cmp #PADDLE_MIN
   bcc .skipAttractModeReset        ; branch if less than 2
   cmp #PADDLE_MAX
   bcs .skipAttractModeReset        ; branch if greater than 254
   sty colorCycleMode               ; set to 0
.skipAttractModeReset
   clc                              ; clear carry for addition
   adc bucketHorizPosition          ; 2 <= a <= 254
   cmp paddleRangeMax               ; if less than the max range then
   bcc .setBucketHorizontalPosition ; set bucket horizontal position
   lda paddleRangeMax               ; set bucket position to max paddle range
.setBucketHorizontalPosition
   sta bucketHorizPosition          ; save for the bucket's horiz position
   jsr CalcPosX                     ; calculate fine/coarse value
   sta bucketsFineCoarse
   ldx #H_BUCKETS - 1
.storeBucketGraphicsLoop
   lda BucketGraphics,x
   sta thirdRowBucketGraphics,x
   sta secondRowBucketGraphics,x
   sta firstRowBucketGraphics,x
   ldy remainingBuckets
   beq .clearFirstRowBucket
   dey
   beq .clearSecondRowBucket
   dey
   beq .clearThirdRowBucket
   bne .nextBucketGraphicLine       ; unconditional branch
   
.clearFirstRowBucket
   sty firstRowBucketGraphics,x
.clearSecondRowBucket
   sty secondRowBucketGraphics,x
.clearThirdRowBucket
   sty thirdRowBucketGraphics,x
.nextBucketGraphicLine
   dex
   bpl .storeBucketGraphicsLoop
StoreSplashGraphics
   ldy catchingBucketNumber         ; get number of bucket that caught bomb
   ldx WaterSplashOffset,y          ; set x to it's RAM offset
   lda catchingBombSoundFreq        ; get the cathing bomb sound frequency
   asl                              ; multiply the value by 2
   and #%00011000                   ; make sure value is less than 24 (i.e.
                                    ; 4 animations * H_SPLASH)
   tay
   lda #H_SPLASH - 1
   sta splashGraphicLoopCount
.storeBucketSplashGraphics
   lda SplashAnimations,y
   sta bucketGraphics + 8,x
   iny
   inx
   dec splashGraphicLoopCount
   bpl .storeBucketSplashGraphics
VerticalSync SUBROUTINE   
.waitTime
   lda INTIM                        ; wait until overscan is done
   bne .waitTime
   ldy #DUMP_PORTS | DISABLE_TIA
   sty WSYNC                        ; wait for next scan line
   sty VBLANK                       ; disable TIA and discharge paddles
   sty VSYNC                        ; start vertical sync (D1 = 1)
   sty WSYNC
   sty WSYNC
   sty WSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   inc frameCount                   ; increment frame count each new frame
   bne ReadConsoleSwitches
   inc colorCycleMode               ; increment every 256 frames
   bne ReadConsoleSwitches
   sec                              ; set carry bit
   ror colorCycleMode               ; rotate carry into D7 for color cycling
ReadConsoleSwitches
   ldy #$FF                         ; assume color mode
   lda SWCHB                        ; read the console switches
   and #BW_MASK                     ; get the B/W switch value
   bne .colorMode                   ; branch if set to color
   ldy #$0F
.colorMode
   tya
   ldy #0
   bit colorCycleMode               ; check color cycling mode
   bpl .setColorHueMask             ; branch if not in color cycling mode
   and #$F7                         ; mask for VCS colors (i.e. D0 not used)
   ldy colorCycleMode
.setColorHueMask
   sty colorEOR
   asl colorEOR
   sta hueMask
   lda #VBLANK_TIME
   sta WSYNC
   sta TIM64T                       ; set timer for vertical blank time
   ldy #0
   sty temp
   lda SWCHB                        ; read the console switches
   lsr                              ; RESET now in carry
   bcs .skipGameReset
   jsr ClearGameRAM
   stx gameState                    ; x = #$ff
   asl gameSelection                ; shift the game selection left
   sec
   ror gameSelection                ; set D7 of gameSelection high
   lda #MAX_BUCKETS                 ; set the number of remaining buckets
   sta remainingBuckets             ; also ready so we'll branch to
   sta reservedRemainingBuckets     ; .resetSelectDebounce below :-)
.skipGameReset
   lsr                              ; SELECT now in carry
   bcs .resetSelectDebounce
   lda selectDebounce               ; get the select debounce delay
   beq .incrementGameSelection      ; if it's zero -- increase game selection
   dec selectDebounce               ; decrement select debounce
   bpl .skipGameSelect              ; unconditional branch
   
.incrementGameSelection
   inc gameSelection
JumpIntoConsoleSwitchCheck
   jsr ClearGameRAM
   lda gameSelection                ; get the game selection value
   and #1                           ; alternate the value between 0 and 1 and
   sta gameSelection                ; set D7 low to show RESET not pressed
   tay                              ; move game selection to y
   iny                              ; increment the value so it shows as
   sty playerScore + 2              ; 1 and/or 2 to the user :-)
   ldy #SELECT_DELAY
.resetSelectDebounce
   sty selectDebounce               ; reset select debounce rate
.skipGameSelect
   bit gameSelection                ; see if game was RESET this frame
   bpl .jumpToPlayGameSounds        ; if not then play the game sounds
   lda remainingBuckets
   bne CheckForExplodingBombs
   lda frameCount
   and #$7F
   bne .jumpToPlayGameSounds
   beq SwitchToOtherPlayer          ; unconditional branch
       
CheckForExplodingBombs
   lda bombExplodingTimer           ; get the exploding bomb timer
   beq DoneExplodingBombs
   cmp #EXPLODING_FLASH_TIME
   bcc CheckToReduceNumberOfBuckets
   beq DetermineNextExplodingBomb
.setExplodingBombSprite
   lda bombExplodingTimer           ; get the exploding bomb timer
   and #$0C
   asl                              ; multiply by 4 (i.e. 12 * 4 = 
   asl                              ; NUM_EXPLODE_ANIM * H_BOMB = 48)
   adc #<ExplodingBombs
   ldx explodingBombNumber
   sta bombLSB,x
   dec bombExplodingTimer
.jumpToPlayGameSounds
   jmp PlayGameSounds

DetermineNextExplodingBomb
   ldx explodingBombNumber
   lda #<Blank
   sta bombLSB,x
.bombLoop
   lda #STARTING_EXPLODING_TIMER
   sta bombExplodingTimer
   ldx #MAX_BOMBS
   lda numberBombsDropped
   beq .determineExplodingBombSprite
   dec numberBombsDropped
.determineExplodingBombSprite
   stx explodingBombNumber
   lda bombLSB,x                    ; get the bomb's LSB
   bne .setExplodingBombSprite      ; set explosion pointer if not clear
   dex
   bpl .determineExplodingBombSprite
   lda #EXPLODING_FLASH_TIME
   sta bombExplodingTimer
CheckToReduceNumberOfBuckets
   dec bombExplodingTimer
   bne .jumpToPlayGameSounds
   lda bonusBucketSoundFreq         ; get the bonus bucket sound timer
   bne .skipBucketReduction         ; don't reduce buckets until sound done
   dec remainingBuckets             ; reduce number of player's buckets
.skipBucketReduction
   lda reservedRemainingBuckets
   beq .skipPlayerDataSwap
SwitchToOtherPlayer
   lda gameSelection                ; get the game selection
   lsr                              ; shift right
   bcc .skipPlayerDataSwap          ; branch if not a two player game
   ldx #4
.playerDataSwapLoop
   ldy currentPlayerVariables,x
   lda reservedPlayerVariables,x
   sta currentPlayerVariables,x
   sty reservedPlayerVariables,x
   dex
   bpl .playerDataSwapLoop
   lda playerNumber                 ; alternate player number
   eor #1
   sta playerNumber
.skipPlayerDataSwap
   ldx bombGroup                    ; get the bomb group (game level)
   txa                              ; move it to the accumulator
   beq .skipBombGroupReduction      ; skip if 0 or lowest possible
   dex                              ; reduce the bomb group
   stx bombGroup
   lda MaxBombsPerGroup,x           ; get maximum bombs for bomb group
   lsr                              ; when bomb group reduction happens the
   clc                              ; player is only obligated to catch half
   adc #1                           ; as many bombs for the level
.skipBombGroupReduction
   sta numberBombsDropped
   ldx #WAIT_LEVEL_START
   stx gameState
   bne .jumpToPlayGameSounds        ; unconditional branch
       
DoneExplodingBombs
   bit gameState
   bpl DetermineMadBomberMovement
   lda SWCHA                        ; read the paddle buttons
   ldx playerNumber                 ; get the current player number
   beq .checkPlayerFireButton
   asl                              ; move player 0 fire button value to D7
.checkPlayerFireButton
   asl                              ; player fire button value in carry
   lda #0
   bcs .fireButtonNotPressed        ; branch if fire button not pressed
   sta gameState                    ; show that game is in progress
.fireButtonNotPressed
   sta bombDropVelocity
   jmp .setBombHorizPos
       
DetermineMadBomberMovement
   lda frameCount                   ; get the current frame number
   and #$0F                         ; mask the upper nybble
   bne .skipMadBomberDirectionChange
   jsr NextRandom                   ; get a new random number
   bcs .skipMadBomberDirectionChange
   lda madBomberDirection           ; get the Mad Bomber's direction
   eor #$FF                         ; flip the bits to change direction
   sta madBomberDirection
.skipMadBomberDirectionChange
   bit gameState
   bvs CheckPlayerCollisions
   lda bombDropVelocity
   cmp #DROPPING_FREQ - 1
   bcs CheckPlayerCollisions
   cmp #2
   bcc CheckPlayerCollisions
   lda bombGroup                    ; get the current bomb group
   bit madBomberDirection           ; check direction Mad Bomber is moving
   bpl .addWithHorizPosition
   eor #$FF                         ; make the value positive
   clc
.addWithHorizPosition
   adc madBomberHorizPosition
   cmp #240
   bcc .moveMadBomberLeft
   ldx #MAD_BOMBER_TRAVELING_RIGHT  ; show bomber is traveling right
   lda #XMIN
   bne .setMadBomberDirection       ; unconditional branch
       
.moveMadBomberLeft
   cmp #XMAX
   bcc .setMadBomberPosition
   ldx #MAD_BOMBER_TRAVELING_LEFT   ; show bomber is traveling left
   lda #XMAX
.setMadBomberDirection
   stx madBomberDirection
.setMadBomberPosition
   sta madBomberHorizPosition
   jsr CalcPosX
   sta madBomberFineCoarse
CheckPlayerCollisions
   bit CXPPMM                       ; read the player collision register
   bpl SetFallingBombs              ; branch if no collision
   ldx bombIndexCaught
   lda #<Blank
   sta bombLSB,x                    ; clear the caught bomb sprite
   ldy #MAX_BUCKETS - 1
   cpx #6
   bcc .catchingBucketDetermined
   beq .determineCatchingBucket
   dey
.determineCatchingBucket
   dey
.catchingBucketDetermined
   ldx remainingBuckets
   cpx #MAX_BUCKETS - 1
   beq .determineCatchingBucketOffset
   bcs .setCatchingBucketOffset
   ldy #MAX_BUCKETS - 1
.determineCatchingBucketOffset
   tya
   bne .setCatchingBucketOffset
   iny
.setCatchingBucketOffset
   sty catchingBucketNumber         ; set index of bucket that caught bomb
   lda #CATCHING_BOMB_FREQ
   sta catchingBombSoundFreq
IncrementScore
   sed                              ; set to decimal mode
   clc
   lda bombGroup                    ; get the current bomb group
   adc #1                           ; increment by 1
   ldx #2
   ldy playerScore + 1              ; save to compare for bonus bucket
.incrementScoreLoop
   adc playerScore,x
   sta playerScore,x
   lda #0
   dex
   bpl .incrementScoreLoop
   cld                              ; clear decimal mode
   bcc .skipScoreMaxOut
   sta remainingBuckets             ; player has maxed out the game
   lda #$99                         ; make the score 999,999
   sta playerScore
   sta playerScore + 1
   sta playerScore + 2
.skipScoreMaxOut
   tya                              ; get the player's score MSB
   eor playerScore + 1              ; to see if they reached 1,000 and are
   and #$F0                         ; awarded a new bucket
   beq SetFallingBombs
   ldx remainingBuckets
   inx
   cpx #MAX_BUCKETS + 1
   bcs .initBonusBucketSoundFreq
   stx remainingBuckets
.initBonusBucketSoundFreq
   lda #BONUS_BUCKET_FREQ
   sta bonusBucketSoundFreq
SetFallingBombs
   ldx bombNumber
   lda bombLSB,x
   beq BombAnimation
   ldx #MAX_BOMBS
.setFallingBombsLoop
   lda bombLSB,x
   beq .nextBomb
   lda #<FallingBombs
   sta bombLSB,x
.nextBomb
   dex
   bpl .setFallingBombsLoop
   jmp .bombLoop
       
BombAnimation
   ldx #MAX_BOMBS
.bombAnimationLoop
   lda bombLSB,x                    ; get the LSB for the bomb sprite
   beq .nextBombAnimation           ; if zero then check the next sprite
   dec temp
   jsr NextRandom
   eor frameCount
   and #$03                         ; 4 frames of animation
   asl                              ; multiply the value by 16 (the height
   asl                              ; of the bomb sprite)
   asl
   asl
   adc #<FallingBombs               ; add with starting frame animation LSB
   sta bombLSB,x
.nextBombAnimation
   dex
   bpl .bombAnimationLoop
   lda bombGroup                    ; get the current bomb group
   lsr                              ; divide the value by 2
   clc
   adc #BOMB_DROP_RATE
   adc bombDropVelocity
   sta bombDropVelocity
   sec
   sbc #DROPPING_FREQ
   bcc PlayGameSounds
   sta bombDropVelocity
   ldx #MAX_BOMBS - 1
.dropBombLoop
   lda bombFineCoarse,x
   sta bombFineCoarse + 1,x
   lda bombLSB,x
   sta bombLSB + 1,x
   dex
   bpl .dropBombLoop
   lda #<Blank
   sta bombLSB
   ldx bombGroup
   bit gameState
   bvc .skipIncrementingBombGroup
   lda temp
   ora catchingBombSoundFreq
   bne PlayGameSounds
   asl gameState
   cpx #BOMB_GROUP_MAX - 1
   bcs .skipIncrementingBombGroup
   inx                              ; increment bomb group for next round
   stx bombGroup
.skipIncrementingBombGroup
   txa                              ; move bomb group to accumulator
   lsr
   bcs .incrementNumberBombsDropped ; branch on odd bomb group
   lda bombLSB + 1
   bne PlayGameSounds
.incrementNumberBombsDropped
   inc numberBombsDropped           ; increase the number of bombs dropped
   lda numberBombsDropped           ; compare with the max bombs for bomb
   cmp MaxBombsPerGroup,x           ; group...don't reset if level not done
   bcc DetermineBombHorizPos
   lda #0
   sta numberBombsDropped
   lda #LEVEL_DONE
   sta gameState                    ; show the level is done
DetermineBombHorizPos
   lda randomSeed
   and #$08
.setBombHorizPos
   ora madBomberFineCoarse          ; add in the bomber's fine/coarse value
   sta bombFineCoarse               ; set the fine/coarse position of bomb
   lda #<FallingBombs
   sta bombLSB                      ; set the Bomb sprite LSB
PlayGameSounds
   jsr NextRandom                   ; get a new random number
   and #$03                         ; make sure 3 <= a <= 0
   tax                              ; save for later
   ldy #0
   lda temp
   beq DetermineCatchingBombSound
   txa
   lsr
   adc #1
   sta AUDV0
   ldy #8
DetermineCatchingBombSound SUBROUTINE
   lda catchingBombSoundFreq
   beq DetermineBombExplosionSound
   ldy #8
   dec catchingBombSoundFreq
   cmp #15
   bcc .setVolume
   ldy #12
   sbc bombGroup
.setVolume
   tax
   sty AUDV0
DetermineBombExplosionSound SUBROUTINE
   lda bombExplodingTimer
   beq DetermineSoundFrequency
   ldy #8
   ldx #8
   adc explodingBombNumber
   cmp #EXPLODING_FLASH_TIME
   bcs .setVolume
   lsr
   ldx #31
.setVolume
   sta AUDV0
DetermineSoundFrequency SUBROUTINE
   lda bonusBucketSoundFreq         ; get the sound frequency for new bucket
   beq .setFrequencyAndChannel      ; set frequency if no new bucket rewarded
   dec bonusBucketSoundFreq         ; reduce frequency for next frame
   tax                              ; x now holds new bucket frequency
   lsr                              ; move D1 to carry
   lsr
   bcc .setVolume
   tax                              ; keep shifted value for sound frequency
.setVolume
   ldy #12
   sty AUDV0                        ; set volume for rewarded bucket
.setFrequencyAndChannel
   stx AUDF0
   sty AUDC0
BCD2DigitPtrs       
   ldy #2
.bcd2DigitLoop
   tya                              ; move y to accumulator
   asl                              ; multiply the value by 4 so it can
   asl                              ; be used for the digitPointer indexes
   tax
   lda playerScore,y                ; get the player's score
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide the value by 2
   adc #<NumberFonts                ; add in number font LSB
   sta digitPointer,x               ; set LSB pointer to digit
   lda playerScore,y                ; get the player's score
   and #$0F                         ; mask the upper nybble
   asl                              ; muliply the value by 8
   asl
   asl
   adc #<NumberFonts                ; add in number font LSB
   sta digitPointer + 2,x           ; set LSB pointer to digit
   lda #>NumberFonts                ; set MSB pointer to digits
   sta digitPointer + 1,x
   sta digitPointer + 3,x
   dey
   bpl .bcd2DigitLoop
   ldx #0
.suppressZeroLoop
   lda digitPointer,x               ; get LSB pointer to digit
   eor #<NumberFonts                ; end suppress loop if value not zero
   bne .doneBCD2Digits
   sta digitPointer,x               ; set LSB to point to Space character
   inx
   inx
   cpx #10
   bcc .suppressZeroLoop
   
.doneBCD2Digits
   jmp MainLoop

ClearGameRAM SUBROUTINE
   lda #0
   ldx #<bucketGraphics - colorCycleMode - 1
.clearLoop
   sta colorCycleMode,x
   dex
   bpl .clearLoop
   rts

NextRandom
   lsr randomSeed
   rol
   eor randomSeed
   lsr
   lda randomSeed
   bcs .leaveNextRandom
   ora #%01000000
   sta randomSeed
.leaveNextRandom
   rts
   
CalcPosX
   ldy #<-1
   sec
.divideBy15
   iny
   sbc #15
   bcs .divideBy15
   sty tempCoarseValue
   eor #$FF
   adc #9
   asl
   asl
   asl
   asl
   ora tempCoarseValue
Waste12Cycles
   rts

MadBomberColors
   .byte BLACK + 2, BLACK + 2, BRICK_RED + 10, BRICK_RED + 10, BRICK_RED + 10
   .byte BLACK + 12, BLACK + 2, BLACK + 12, BLACK + 2, BLACK + 12, BLACK + 2
   .byte BLACK + 12, BLACK + 2, BLACK + 12, BLACK + 2, BLACK + 12, BLACK + 2
   .byte BLACK + 12, BLACK + 2, BRICK_RED + 8, BRICK_RED + 10, BRICK_RED + 10
   .byte BRICK_RED + 10, BRICK_RED + 10, BRICK_RED + 10, BRICK_RED + 8
   .byte BLACK + 2, BLACK + 2, BLACK + 2, YELLOW + 4, YELLOW + 2, YELLOW
   
GameColors
   .byte BLACK + 6                  ; Bomber area background color
   .byte GREEN + 4                  ; player area background color
   .byte YELLOW + 10                ; player1 score color
   .byte RED + 2                    ; player2 score color
   
BombColors
   .byte BLACK, BLACK + 2, BLACK + 4, BLACK + 6, BLACK + 6, BLACK + 4, BLACK + 2
   .byte BLACK, BLACK + 8, BLACK + 8, BLACK + 8, BLACK + 8, RED + 14, RED + 14
   .byte RED+14
   
BucketColors
   REPEAT 3
      .byte YELLOW + 2, YELLOW + 2, YELLOW + 4, YELLOW + 4, YELLOW + 6
      .byte YELLOW + 6, WATER_COLOR, YELLOW + 6
;
; splash color
;
      .byte BLUE + 8, BLUE + 8, BLUE + 8, BLUE + 8, BLUE + 8, BLUE + 8
      .byte BLUE + 8, BLUE + 8
   REPEND
   
Copyright0
   .byte $00 ; |........|
   .byte $AD ; |X.X.XX.X|
   .byte $A9 ; |X.X.X..X|
   .byte $E9 ; |XXX.X..X|
   .byte $A9 ; |X.X.X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $41 ; |.X.....X|
   .byte $0F ; |....XXXX|
Copyright1
   .byte $00 ; |........|
   .byte $50 ; |.X.X....|
   .byte $58 ; |.X.XX...|
   .byte $5C ; |.X.XXX..|
   .byte $56 ; |.X.X.XX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
Copyright2
   .byte $00 ; |........|
   .byte $BA ; |X.XXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $3A ; |..XXX.X.|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
Copyright3
   .byte $00 ; |........|
   .byte $E9 ; |XXX.X..X|
   .byte $AB ; |X.X.X.XX|
   .byte $AF ; |X.X.XXXX|
   .byte $AD ; |X.X.XX.X|
   .byte $E9 ; |XXX.X..X|
MadBomber
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $44 ; |.X...X..|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $BA ; |X.XXX.X.|
   .byte $D6 ; |XX.X.XX.|
   .byte $BA ; |X.XXX.X.|
   .byte $D6 ; |XX.X.XX.|
   .byte $BA ; |X.XXX.X.|
   .byte $D6 ; |XX.X.XX.|
   .byte $BA ; |X.XXX.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $6C ; |.XX.XX..|
   .byte $54 ; |.X.X.X..|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $D6 ; |XX.X.XX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   
MaxBombsPerGroup
   .byte MAX_BOMBS_GROUP1 - 1, MAX_BOMBS_GROUP2, MAX_BOMBS_GROUP3, MAX_BOMBS_GROUP4
   .byte MAX_BOMBS_GROUP5, MAX_BOMBS_GROUP6, MAX_BOMBS_GROUP7, MAX_BOMBS_GROUP8
;
; The following are never read. The bomb group maxes out at 7. It looks as if
; they had intended the bomb groups to go to 10.
;
   .byte 255, 255, 240
   
   BOUNDARY 0
   
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SplashAnimations
Splash0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Splash1
   .byte $92 ; |X..X..X.|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $82 ; |X.....X.|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
Splash2
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $44 ; |.X...X..|
   .byte $92 ; |X..X..X.|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
Splash3
   .byte $00 ; |........|
   .byte $92 ; |X..X..X.|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $82 ; |X.....X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
NumberFonts
zero
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
one
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
two
   .byte $7E ; |.XXXXXX |
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3C ; |..XXXX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $46 ; |.X...XX.|
   .byte $3C ; |..XXXX..|
three
   .byte $3C ; |..XXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $46 ; |.X...XX.|
   .byte $3C ; |..XXXX..|
four
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $7E ; |.XXXXXX.|
   .byte $4C ; |.X..XX..|
   .byte $2C ; |..X.XX..|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
five
   .byte $7C ; |.XXXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7C ; |.XXXXX..|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7E ; |.XXXXXX.|
six
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $7C ; |.XXXXX..|
   .byte $60 ; |.XX.....|
   .byte $62 ; |.XX...X.|
   .byte $3C ; |..XXXX..|
seven
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
eight
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
nine
   .byte $3C ; |..XXXX..|
   .byte $46 ; |.X...XX.|
   .byte $06 ; |.....XX.|
   .byte $3E ; |..XXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
FallingBombs
FallingBomb0
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
FallingBomb1
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
FallingBomb2
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
FallingBomb3
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $60 ; |.XX.....|
   .byte $20 ; |..X.....|
ExplodingBombs
ExplodingBomb0
   .byte $00 ; |........|
   .byte $14 ; |...X.X..|
   .byte $91 ; |X..X...X|
   .byte $5A ; |.X.XX.X.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $1D ; |...XXX.X|
   .byte $B8 ; |X.XXX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $59 ; |.X.XX..X|
   .byte $9C ; |X..XXX..|
   .byte $14 ; |...X.X..|
   .byte $12 ; |...X..X.|
   .byte $A0 ; |X.X.....|
   .byte $04 ; |.....X..|
ExplodingBomb1       
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $52 ; |.X.X..X.|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $58 ; |.X.XX...|
   .byte $1C ; |...XXX..|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
ExplodingBomb2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
WaterSplashOffset
   .byte H_SPLASH * 0, H_SPLASH * 2, H_SPLASH * 4, H_SPLASH * 6
   
BucketGraphics
   .byte $FE ; |XXXXXXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $78 ; |.XXXX...|
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   .org ROM_BASE + 2048 - 4, 0      ; 2K ROM
   .word Start                      ; RESET vector
   .word 0                          ; BRK vector