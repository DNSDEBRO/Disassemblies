   LIST OFF
; ***  B A S K E T B A L L  ***
; Copyright 1977 Atari, Inc.
; Designer: Alan Miller

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: October 1, 2016
;
; NTSC ROM usage stats
; -------------------------------------------
;  *** 114 BYTES OF RAM USED 14 BYTES FREE
;  ***   1 BYTE OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
;  *** 114 BYTES OF RAM USED 14 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1977, ATARI, INC.                                  =
; =                                                                            =
; ==============================================================================
;
; - RAM locations $84 - $86 and $8B - $8D are not used
; - RAM locations for variables changed for PAL50 release...not sure why
; - Computer jumping can be controlled by right port fire button

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

   IFNCONST COMPILE_REGION

COMPILE_REGION          = NTSC      ; change to compile for different regions

   ENDIF

   IF !(COMPILE_REGION = NTSC || COMPILE_REGION = PAL50 || COMPILE_REGION = PAL60)

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0, PAL50 = 1, PAL60 = 2"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 51
OVERSCAN_SCANLINE_COUNT = 1

INIT_XPOS_LEFT_BOUNDARY = 50        ; horizontal position of left bound line
INIT_XPOS_RIGHT_BOUNDARY = 110      ; horizontal position of right bound line

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 67
OVERSCAN_SCANLINE_COUNT = 24

INIT_XPOS_LEFT_BOUNDARY = 52        ; horizontal position of left bound line
INIT_XPOS_RIGHT_BOUNDARY = 107      ; horizontal position of right bound line

   ENDIF

;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
RED                     = $30
COBALT_BLUE             = $60
BLUE                    = $80
DK_GREEN                = $D0


PLAYER_1_COLOR          = DK_GREEN + 10
PLAYER_2_COLOR          = COBALT_BLUE + 4
CLOCK_COLOR             = BLUE + 10
FLOOR_COLOR             = RED + 6

   ELSE

YELLOW                  = $20
OLIVE_GREEN             = $30
RED                     = $60
BLUE                    = $D0

PLAYER_1_COLOR          = OLIVE_GREEN + 10
PLAYER_2_COLOR          = RED + 10
CLOCK_COLOR             = BLUE + 10
FLOOR_COLOR             = YELLOW + 6

   ENDIF
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

VSYNC_TIME              = 42

MAX_NUM_PLAYERS         = 2

INIT_PLAYER2_XPOS       = 84
INIT_PLAYER1_XPOS       = 70
INIT_BALL_XPOS          = 79

XPOS_MINUTES            = 62     ; horizontal position of minutes
XPOS_SECONDS            = 78     ; horizontal position of seconds

W_SCREEN                = 159

XMIN                    = 23
XMAX                    = W_SCREEN - 18


YMIN                    = 90
YMAX                    = 180

Y_MID_COURT             = 135

H_FONT                  = 5
H_BALL                  = 8
H_PLAYER                = 16

SELECT_DELAY            = 63

START_GAME_MINUTES      = $40          ; 4 minutes (BCD)

BW_HUE_MASK             = $07
COLOR_HUE_MASK          = $F7

; Number fonts LSB values
BLANK_LSB_VALUE         = <(Blank - NumberFonts) / H_FONT
ONE_LSB_VALUE           = <(one - NumberFonts) / H_FONT
TWO_LSB_VALUE           = <(two - NumberFonts) / H_FONT
THREE_LSB_VALUE         = <(three - NumberFonts) / H_FONT
FOUR_LSB_VALUE          = <(four - NumberFonts) / H_FONT
FIVE_LSB_VALUE          = <(five - NumberFonts) / H_FONT
SIX_LSB_VALUE           = <(six - NumberFonts) / H_FONT
SEVEN_LSB_VALUE         = <(seven - NumberFonts) / H_FONT
EIGHT_LSB_VALUE         = <(eight - NumberFonts) / H_FONT
NINE_LSB_VALUE          = <(nine - NumberFonts) / H_FONT
COLON_LSB_VALUE         = <(colon - NumberFonts) / H_FONT

; game state values
GAME_OVER               = 0

;
; Scoring basket status flags
;
BASKET_MADE_STATUS      = %10000000
BASKET_SCORED_MASK      = %00000001

;
; Ball possession status flags
;
PLAYER_HAS_BALL_STATUS  = %10000000
PLAYER_SHOOTING         = %01000000
PLAYER_POSSESSION_MASK  = %00000001

;
; Bouncing ball direction status flags
;
BALL_BOUNCING_HORIZ_MASK = %10000000
BALL_BOUNCING_VERT_MASK = %01000000

BALL_BOUNCING_LEFT      = 1 << 7
BALL_BOUNCING_RIGHT     = 0 << 7

BALL_BOUNCING_DOWN      = 1 << 6
BALL_BOUNCING_UP        = 0 << 6

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60
   
frameCount              ds 1

   ENDIF
   
gameState               ds 1
gameSelection           ds 1
selectDebounce          ds 1
unused_01               ds 3        ; 3 unused RAM bytes
scoreBoardValues        ds 4
;--------------------------------------
gameClock               = scoreBoardValues
playerScores            = gameClock + 2
;--------------------------------------
player1Score            = playerScores
player2Score            = playerScores + 1
unused_02               ds 3        ; 3 unused RAM bytes
scanline                ds 1
playerGraphics          ds H_PLAYER * 2
;--------------------------------------
player2Graphics         = playerGraphics
player1Graphics         = player2Graphics + H_PLAYER
ballBounceHeight        ds 1
timerMinutesHorizPos    ds 1
;--------------------------------------
tmpPlayer2HorizPos      = timerMinutesHorizPos
timerSecondsHorizPos    ds 1
leftBoundsHorizPos      ds 1        ; missile 0
rightBoundsHorizPos     ds 1        ; missile 1
ballHorizPos            ds 1
fireButtonDebounceValues ds 2
;--------------------------------------
player1FireButtonDebounce  = fireButtonDebounceValues
player2FireButtonDebounce  = player1FireButtonDebounce + 1
bouncingBallVertDirection ds 1
allowToBlockBallStatus  ds 1
shootingBallLift        ds 1
colorEOR                ds 1

   IF COMPILE_REGION = PAL50

frameCount              ds 1

   ENDIF
   
scoringBasketStatus     ds 1
ballPossessionStatus    ds 1
ballBouncingDirectionStatus ds 1
shootingAnimationCount  ds 1
ballGravityValue        ds 1
playerRunningAnimation  ds 2
;--------------------------------------
player1RunningAnimation = playerRunningAnimation
player2RunningAnimation = player1RunningAnimation + 1
playerHorizontalDirection ds 2
;--------------------------------------
player1HorizontalDirection = playerHorizontalDirection
player2HorizontalDirection = player1HorizontalDirection + 1
playerJumpingValues     ds 2
;--------------------------------------
player1JumpingValue     = playerJumpingValues
player2JumpingValue     = player1JumpingValue + 1
ballInHoopStatus        ds 1
soundVolumeControl      ds 2
;--------------------------------------
leftSoundChannelVolumeControl = soundVolumeControl
rightSoundChannelVolumeControl = leftSoundChannelVolumeControl + 1
ballHorizMotionDelay    ds 1
decBallHorizMotionDelay ds 1
ballVertMotionDelay     ds 1
decBallVertMotionDelay  ds 1
playersVertPos          ds 3
;--------------------------------------
player2VertPos          = playersVertPos
player1VertPos          = player2VertPos + 1
ballScanline            = player1VertPos + 1
ballVerticalPosition    ds 1
cpuPlayerShootingDelay  ds 1
joystickValue           ds 1
kernelFloorColor        ds 1
ballDribblingCount      ds 1
oldBallBounceHeight     ds 1
playersHorizPos         ds 2
;--------------------------------------
player2HorizPos         = playersHorizPos
player1HorizPos         = player2HorizPos + 1
playerReflectValues     ds 2
;--------------------------------------
player1ReflectValue     = playerReflectValues
player2ReflectValue     = player1ReflectValue + 1
clockSpriteGraphics     ds H_FONT * 2
;--------------------------------------
minutesGraphics         = clockSpriteGraphics
secondsGraphics         = minutesGraphics + H_FONT
scoreSpriteGraphics     ds H_FONT * 2
;--------------------------------------
player1ScoreGraphics    = scoreSpriteGraphics
player2ScoreGraphics    = player1ScoreGraphics + H_FONT
newOffensivePlayerHorizPos ds 1
cpuPlayerAggression     ds 1
tmpBallPossessionPlayerIdx ds 1
numberSpritePointer     ds 2
;--------------------------------------
tmpPlayerDistanceValues = numberSpritePointer
;--------------------------------------
tmpPlayerBasketHorizDistance = tmpPlayerDistanceValues
tmpPlayerMidCourtVertDistance = tmpPlayerBasketHorizDistance + 1
hueMask                 = numberSpritePointer
;--------------------------------------
tmpOddEvenFrameCount    = hueMask
;--------------------------------------
tmpJoystickValue        = tmpOddEvenFrameCount
;--------------------------------------
loopCount               = tmpJoystickValue
;--------------------------------------
tmpHorizPosDiv16        = loopCount
;--------------------------------------
tmpShootingBallLiftDiv4 = tmpHorizPosDiv16
;--------------------------------------
tmpPlayerVertPosDiv4    = tmpShootingBallLiftDiv4
;--------------------------------------
playerLegSpritePointer  = tmpPlayerVertPosDiv4
;--------------------------------------
tmpDefensivePlayerIndex = numberSpritePointer + 1
;--------------------------------------
playerScoreColors       = tmpDefensivePlayerIndex
;--------------------------------------
player1ScoreColor       = playerScoreColors
player2ScoreColor       = player1ScoreColor + 1
;--------------------------------------
tmpScoreBoardValue      ds 1
;--------------------------------------
tmpPlayerDistanceDiv4   = tmpScoreBoardValue
;--------------------------------------
player2JoystickValue    = tmpPlayerDistanceDiv4
;--------------------------------------
playerBodySpritePointer = player2JoystickValue
;--------------------------------------
clockColor              ds 1
;--------------------------------------
tmpFontIndex               = clockColor
spriteRAMPointer        ds 2
;--------------------------------------
tmpPlayerWithBall       = spriteRAMPointer
floorColor              ds 1

   echo "***",(* - $80 - 6)d, "BYTES OF RAM USED", ($100 - * + 6)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E (BANK 0)
;===============================================================================

   SEG Bank0
   .org ROM_BASE
   
SetupFontKernelGraphics
   stx spriteRAMPointer + 1         ; x = 0
   lda #>NumberFonts                ; get the MSB of the number fonts
   sta numberSpritePointer + 1      ; set MSB of number sprite
   ldx #<[player2Score - gameClock] ; prepare to draw score board digits
.setupFontKernelGraphicsData
   stx tmpFontIndex
   lda scoreBoardValues,x           ; get the score board value
   and #$0F                         ; mask off the upper nybbles
   sta tmpScoreBoardValue           ; save the value for later
   asl                              ; shift the value left to multiply by 4
   asl
   clc                              ; add in original so it's multiplied by 5
   adc tmpScoreBoardValue           ; [i.e. x * 5 = (x * 4) + x]
   adc #<NumberFonts                ; add in LSB of number fonts
   sta numberSpritePointer          ; to get LSB of pointer to sprite data
   txa                              ; move index to accumulator
   asl                              ; multiply index value by 4
   asl
   adc tmpFontIndex                 ; add in original to multiplied by 5
   adc #<clockSpriteGraphics
   sta spriteRAMPointer
   ldy #H_FONT - 1
.setFontLSBGraphicsData
   lda (numberSpritePointer),y      ; get the number sprite graphic data
   and #$0F                         ; mask off the upper nybbles
   sta (spriteRAMPointer),y         ; place value in RAM
   dey
   bpl .setFontLSBGraphicsData
   lda scoreBoardValues,x           ; get the score board value
   and #$F0                         ; mask off the lower nybbles
   lsr                              ; divide the value by 4
   lsr
   sta tmpScoreBoardValue           ; save the value for later
   lsr                              ; divide the value by 16
   lsr                              ; add in original so it's multiplied by
   adc tmpScoreBoardValue           ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]
   adc #<NumberFonts                ; add in LSB of number fonts
   sta numberSpritePointer          ; set LSB of number sprite
   ldy #H_FONT - 1
.setFontMSBGraphicsData
   lda (numberSpritePointer),y      ; get the number number sprite graphic data
   and #$F0                         ; mask off the lower nybbles
   ora (spriteRAMPointer),y         ; combine with sprite RAM data
   sta (spriteRAMPointer),y         ; place value in RAM
   dey
   bpl .setFontMSBGraphicsData
   dex
   bpl .setupFontKernelGraphicsData
   ldx #H_FONT
.reflectRightPlayerScoreDigits
   lda player2ScoreGraphics - 1,x
   ldy #7                           ; rotating 8 bits of score graphics
.rotateRightPlayerScoreDigits
   rol
   ror player2ScoreGraphics - 1,x
   dey
   bpl .rotateRightPlayerScoreDigits
   dex
   bne .reflectRightPlayerScoreDigits
   rts

;
; Horizontal reset starts at cycle 8 (i.e. pixel 24). The object's position is
; incremented by 55 to push their pixel positioning to start at cycle 18 (i.e.
; pixel 54) with an fine adjustment of -6 to start objects at pixel 48.
;
CalculateObjectHorizPositions
.calculateObjectHorizPositions
   lda timerMinutesHorizPos - 1,x
CalculateObjectHorizPosition
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
   asl                              ; move fine motion value to upper nybble
   asl
   asl
   asl
   sty WSYNC                        ; wait for next scan line
.coarseMoveLoop
   dey
   bpl .coarseMoveLoop
   sta RESP0 - 1,x                  ; set object's coarse position
   sta WSYNC                        ; wait for next scan line
   sta HMP0 - 1,x                   ; set object's fine motion
   dex   
   bne .calculateObjectHorizPositions
   sta WSYNC
   sta HMOVE
   sta WSYNC
   stx HMCLR
   rts

DisplayKernel SUBROUTINE
   lda #INIT_XPOS_LEFT_BOUNDARY
   sta leftBoundsHorizPos
   lda #INIT_XPOS_RIGHT_BOUNDARY
   sta rightBoundsHorizPos
   lda #XPOS_MINUTES
   sta timerMinutesHorizPos
   lda #XPOS_SECONDS
   sta timerSecondsHorizPos
   ldx #<[RESBL - RESP0 + 1]
   stx REFP0                        ; set players to NO_REFLECT (i.e. D3 = 0)
   stx REFP1
   stx NUSIZ0                       ; set players to DOUBLE_SIZE (i.e. x = 5)
   stx NUSIZ1
   jsr CalculateObjectHorizPositions
   ldy #COLOR_HUE_MASK
   sty hueMask                      ; set hue mask assuming COLOR mode
   ldy #0
   lda #FLOOR_COLOR
   sta floorColor                   ; set floor color for COLOR mode
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; keep BW switch value
   bne .setObjectColors             ; branch if set to COLOR
   lda #BLACK + 10                  ; set floor color for B&W mode
   sta floorColor
   lda #BW_HUE_MASK
   sta hueMask                      ; set hue mask for B&W mode
   ldy #4
.setObjectColors
   lda GameColorTable,y
   bit gameState                    ; check current game state
   bvs .skipColorCycling            ; branch if game in progress
   eor colorEOR                     ; cycle colors when game not in progress
   and hueMask
.skipColorCycling
   sta COLUP0,x
   sta playerScoreColors,x
   bit gameState                    ; check current game state
   bvc .setKernelFloorColor         ; branch if game over
   lda floorColor
.setKernelFloorColor
   sta kernelFloorColor
   iny
   inx
   cpx #4
   bcc .setObjectColors
   dex                              ; x = 3
   stx CTRLPF                       ; set to PF_SCORE | PF_REFLECT
.waitTime
   ldx INTIM
   bne .waitTime
   stx WSYNC
;--------------------------------------
   stx VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   ldy #256 - (H_FONT * 3) - 3; 2
   lda #256 - (H_FONT * 3)    ; 2
   sta loopCount              ; 3
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda player1ScoreColor      ; 3         get color for player 1
   sta COLUP0                 ; 3 = @06   color GRP0 (i.e. CTRLPF in score mode)
   lda player1ScoreGraphics,x ; 4
   sta PF1                    ; 3 = @13   draw player 1 score
   lda minutesGraphics,x      ; 4
   sta GRP0                   ; 3 = @20   draw the timer values
   lda secondsGraphics,x      ; 4
   sta GRP1                   ; 3 = @27
   iny                        ; 2         increment scan line
   cpy loopCount              ; 3
   lda clockColor             ; 3         get clock color
   sta COLUP0                 ; 3 = @38   color player graphics for clock
   sta COLUP1                 ; 3 = @41
   lda player2ScoreGraphics,x ; 4
   sta PF1                    ; 3 = @48   draw player 2 score
   lda player2ScoreColor      ; 3         get color for player 2
   sta COLUP1                 ; 3 = @54   color GRP1 (i.e. CTRLPF in score mode)
   bcc ScoreKernel            ; 2³        branch if scan line less than loopCount
   inx                        ; 2 = @58   increment score sprite index
   tya                        ; 2         move scan line count to accumulator
   clc                        ; 2
   adc #3                     ; 2         increment by 3 for new loop count
   sta loopCount              ; 3 = @67
   bmi ScoreKernel            ; 2³        continue kernel until value wraps
   ldx player1ScoreColor      ; 3 = @72
   stx COLUP0                 ; 3 = @75
;--------------------------------------
   sta NUSIZ0                 ; 3 = @02
   sta NUSIZ1                 ; 3 = @05
   sta PF1                    ; 3 = @08
   sta GRP0                   ; 3 = @11
   sta GRP1                   ; 3 = @14
   ldx #<[RESP1 - RESP0 + 1]  ; 2         set x to position player1
   lda player2HorizPos        ; 3         get player2's horizontal position
   sta tmpPlayer2HorizPos     ; 3         save here for horizontal pos routine
   lda player1HorizPos        ; 3 = @25   get player1's horizontal position
   jsr CalculateObjectHorizPosition;6
;--------------------------------------
   lda player1ReflectValue    ; 3 = @12   get player1's reflect value
   sta REFP0                  ; 3 = @15   set GRP0 reflect state
   lda player2ReflectValue    ; 3         get player2's reflect state
   sta REFP1                  ; 3 = @21   set GRP1 reflect state
   lda #MSBL_SIZE4 | PF_REFLECT;2
   sta CTRLPF                 ; 3 = @26   set ball to 4 clocks and reflect PF
   
   IF COMPILE_REGION = PAL50
   
   ldy #0                     ; 2         15 more scan lines for PAL50 playfield
   
   ELSE
   
   ldy #(H_FONT * 3) - 1      ; 2
   
   ENDIF
   
   sty scanline               ; 3         set scan line after drawing score
   ldy #0                     ; 2 = @33
.kernelLoop
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   sty GRP1                   ; 3 = @06
   ldy #ENABLE_BM             ; 2
   sec                        ; 2
   lda ballScanline           ; 3         get the ball's scan line
   sbc scanline               ; 3         subtract current scan line
   and #~(H_BALL - 1)         ; 2 = @18   and with 2's complement of H_BALL
   beq .setBallEnableState    ; 2³        enable if difference between 0 and 7
   ldy #DISABLE_BM            ; 2 = @22
.setBallEnableState
   sty ENABL                  ; 3 = @25
   sty HMM0                   ; 3 = @28   set fine motion of missiles to
   sty HMM1                   ; 3 = @31   HMOVE_0 (i.e. 0 <= y <= 2)
   clc                        ; 2
   lda scanline               ; 3         get the current scan line
   adc #2                     ; 2         increment by 2 (i.e. 2LK)
   sta scanline               ; 3
   lsr                        ; 2         divide scan line value by 8 for
   lsr                        ; 2         basket graphics
   lsr                        ; 2
   tax                        ; 2 = @49
   ldy BasketGraphics,x       ; 4
   sec                        ; 2
   lda player2VertPos         ; 3         get player2's vertical position
   sbc scanline               ; 3         subtract current scan line
   lsr                        ; 2         divide value by 2
   tax                        ; 2         set index for player graphics
   and #~(H_PLAYER - 1)       ; 2 = @67   and with 2's complement of H_PLAYER
   beq .loadPlayer0Graphics   ; 2³        draw player if between 0 and 14
   lda #0                     ; 2 = @71
   beq .drawPlayer0           ; 3         unconditional branch
   
.loadPlayer0Graphics
   lda player2Graphics,x      ; 4
.drawPlayer0
   SLEEP 2                    ; 2 = @76
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   sty PF1                    ; 3 = @09   draw basketball goal graphics
   lda scanline               ; 3         get the current scan line
   cmp #YMIN                  ; 2 = @14
   bcc .determinePlayer1Draw  ; 2³
   ldx kernelFloorColor       ; 3 = @19   get the color for the floor
   stx COLUBK                 ; 3 = @22   color background for floor illusion
   stx ENAM0                  ; 3 = @25
   stx ENAM1                  ; 3 = @28
.determinePlayer1Draw
   sec                        ; 2
   lda player1VertPos         ; 3         get player1's vertical position
   sbc scanline               ; 3         subtract current scan line
   lsr                        ; 2         divide value by 2
   tax                        ; 2         set index for player graphics
   and #~(H_PLAYER - 1)       ; 2         and with 2's complement of H_PLAYER
   beq .loadPlayer1Graphics   ; 2³        draw player if between 0 and 14
   ldy #0                     ; 2
   beq .determineKernelDone   ; 3         unconditional branch
   
.loadPlayer1Graphics
   ldy player1Graphics,x      ; 4
.determineKernelDone
   lda scanline               ; 3         get the current scan line
   cmp #YMAX                  ; 2
   bcs Overscan               ; 2³        branch if done with kernel
   and #3                     ; 2         see if scan line is divisible by 4
   bne .kernelLoop            ; 2³        if not then continue with kernel
   ldx #HMOVE_L1              ; 2         if divisible by 4 then move missiles
   stx HMM0                   ; 3         (i.e. boundary lines) to show
   ldx #HMOVE_R1              ; 2         diagonal line
   stx HMM1                   ; 3
   bne .kernelLoop            ; 3         unconditional branch
   
Overscan SUBROUTINE
   lda #0
   ldy #OVERSCAN_SCANLINE_COUNT
.overscanLoop
   sta WSYNC
   sta COLUBK
   ldx #<[ENABL - GRP0 + 1]
.clearPlayerGraphicRegs
   sta GRP0 - 1,x
   dex
   bne .clearPlayerGraphicRegs
   dey
   bne .overscanLoop
   jsr SetupFontKernelGraphics
   lda #VSYNC_TIME
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta VSYNC                        ; start vertical sync
   sta TIM8T
.waitTime
   ldx INTIM
   bne .waitTime
   stx WSYNC
   stx VSYNC                        ; end vertical sync (i.e. D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T
   bne CheckForGameSelectOrReset    ; unconditional branch

Start
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; set the stack to the beginning
   inx                              ; x = 0
   stx gameState                    ; initialize game state to GAME_OVER
   stx gameSelection                ; clear game selection
   ldx #BLANK_LSB_VALUE << 4 | BLANK_LSB_VALUE
   stx player2Score                 ; set player 2 score to Blank sprite
   ldx #BLANK_LSB_VALUE << 4 | ONE_LSB_VALUE
   stx player1Score                 ; set player 1 score to One sprite
ClearGameTIARegisters
   ldx #<[CXCLR - RSYNC + 1]
   stx ballBounceHeight
   ldy #0
.clearTIALoop
   sty NUSIZ0 + 63,x
   dex
   bne .clearTIALoop
   ldx #<[soundVolumeControl - colorEOR]
.clearGameVariables
   sty colorEOR - 1,x
   dex
   bne .clearGameVariables
   sty gameClock + 1                ; set to 0
   lda #START_GAME_MINUTES | COLON_LSB_VALUE
   sta gameClock
   lda #Y_MID_COURT
   ldx #<[cpuPlayerShootingDelay - soundVolumeControl]
   stx shootingBallLift
.initGameVariables
   sta soundVolumeControl - 1,x
   dex
   bne .initGameVariables
   lda #INIT_PLAYER2_XPOS
   sta player2HorizPos
   sta AUDC1
   lda #INIT_PLAYER1_XPOS
   sta player1HorizPos
   lda #INIT_BALL_XPOS
   sta ballHorizPos
   dec player1HorizontalDirection
   ldx #$10
   stx colorEOR                     ; set color eor value
   dex                              ; x = 15
   stx cpuPlayerAggression
   stx player1ReflectValue
   jmp DisplayKernel
       
CheckForGameSelectOrReset
   inc frameCount                   ; incremented each frame
   lda SWCHB                        ; read the console switches
   ror                              ; RESET now in carry
   bcs .skipGameReset               ; branch if RESET not pressed
   dex                              ; x = #$FF
   stx gameState
   inx                              ; x = 0
   stx player1Score                 ; set player 1 score to zero
   stx player2Score                 ; set player 2 score to zero
   beq ClearGameTIARegisters        ; unconditional branch
   
.skipGameReset
   lda selectDebounce               ; get the select debounce value
   beq .determineToCheckForSelectSwitch                        
   inc selectDebounce
.determineToCheckForSelectSwitch

   IF COMPILE_REGION = PAL50
   
   lda frameCount                   ; get current frame count
   cmp #FPS
   bne .checkForSelectSwitch        ; branch if not reached 50 frames
   stx frameCount                   ; reset frame count
   
   
   ELSE
   
   lda frameCount                   ; get current frame count
   and #SELECT_DELAY                ; the select switch is checked ~ every 60
   bne .checkForSelectSwitch
   
   ENDIF
   
   bit gameState                    ; check current game state
   bpl .skipGameClockReduction      ; skip clock reduction if not in game mode
   sec
   sed                              ; set to decimal mode
   lda gameClock + 1                ; get game clock seconds
   sbc #1                           ; reduce seconds by 1
   bcs .setGameClockSeconds         ; reduce minutes if carry clear
   sec
   lda gameClock                    ; get game clock minutes
   sbc #$10                         ; subtract minute value by 16 to show
   sta gameClock                    ; reduction by 1 (BCD)
   lda #$59                         ; reset game clock seconds to 59
.setGameClockSeconds
   sta gameClock + 1
   cld                              ; clear decimal mode
.skipGameClockReduction
   inc colorEOR
   bne .checkForSelectSwitch
   
   IF COMPILE_REGION = PAL50
   
   stx gameState
   
   ELSE
   
   sta gameState
   
   ENDIF
   
.checkForSelectSwitch
   lda SWCHB                        ; read the console switches
   eor #$FF                         ; flip the bits
   and #SELECT_MASK
   bne .selectSwitchPressed         ; branch if SELECT pressed
   sta selectDebounce               ; clear select debounce value
   beq ReadJoystickValues           ; unconditional branch
   
.selectSwitchPressed
   bit selectDebounce
   bmi ReadJoystickValues
   lda #%11000000
   sta selectDebounce
   inc gameSelection                ; increment game selection
   lda gameSelection                ; get current game selection
   cmp #2
   bne .setToShowGameSelection      ; branch if reached maximum game selection
   lda #0
   sta gameSelection                ; wrap game selection back to the beginning
.setToShowGameSelection
   clc
   adc #BLANK_LSB_VALUE << 4 | ONE_LSB_VALUE; increment value for display
   sta player1Score                 ; set player 1 score to game selection
   lda #BLANK_LSB_VALUE << 4 | BLANK_LSB_VALUE
   sta player2Score                 ; set player 2 score to show Blanks
   lda #GAME_OVER
   sta gameState                    ; set game state to GAME_OVER
ReadJoystickValues
   lda joystickValue                ; get joystick value from last frame
   sta tmpJoystickValue             ; save for later
   lda SWCHA                        ; read the player joystick values
   sta joystickValue                ; save for later
   ldx gameSelection                ; get current game selection
   bne .ignorePlayer1JoystickValues ; branch if one player game
   jmp ReadJoystickActionButtonStatus
       
.ignorePlayer1JoystickValues
   ldx #0
   and #P1_NO_MOVE                  ; keep player 2's values
   sta player2JoystickValue
   lda tmpJoystickValue             ; get the temporary joystick value
   and #P0_NO_MOVE                  ; keep player 1's values
   ora player2JoystickValue         ; or in player2 joystick value
   sta joystickValue                ; save in current joystick value 
   lda ballPossessionStatus         ; check ball possession status
   bmi .determineHorizTargetForPlayer1WithBall; branch if ball in possession
   sec
   lda player2HorizPos              ; get player 2's horizontal position
   sbc ballHorizPos                 ; subtract ball horizontal position
   and #~1
   bne .targetBallHorizontalPosition; branch if distance greater than 1 pixel
   sec
   lda player2VertPos               ; get player 2's vertical position
   sbc ballVerticalPosition         ; subtract ball vertical position
   bcc .targetBallHorizontalPosition; branch player 2 to the left of the ball
   adc ballBounceHeight
   and #~63
   beq .checkForFireButtonHeld      ; branch if height less than 64
.targetBallHorizontalPosition
   txa                              ; a = 0
.determineTargetHorizontalPosition
   clc
   adc ballHorizPos                 ; increment by ball horizontal position
   tay                              ; transfer to target horizontal position
   ldx ballVerticalPosition         ; get ball vertical position
   bne DetermineCPUPlayerJoystickValues; unconditional branch
   
.determineHorizTargetForPlayer1WithBall
   and #PLAYER_POSSESSION_MASK      ; keep D0 to see which player has ball
   beq .checkForCPUPlayerShootingBall; branch if player 1 has the ball
   lda #3
   bne .determineTargetHorizontalPosition;unconditional branch
   
.checkForCPUPlayerShootingBall
   bit ballPossessionStatus         ; check ball possession status
   bvc .determineCPUPlayerHorizTarget; branch if player not preparing to shoot
   dec cpuPlayerShootingDelay
   bpl .checkForFireButtonHeld
   bne ReadJoystickActionButtonStatus;unconditional branch
   
.determineCPUPlayerHorizTarget
   lda frameCount                   ; get current frame count
   
   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60
   
   tax                              ; move frame count to x register
   sec
   and #$3F
   ora #$10
   tay
   sbc player2HorizPos              ; subtract player 2 horizontal position
   
   ELSE
   
   asl
   asl
   tax
   and #$3F
   tay
   cmp player2HorizPos
   
   ENDIF

   bcc DetermineCPUPlayerJoystickValues; branch if player 2 to the right   
   lda player2VertPos               ; get player 2 vertical position
   sbc #Y_MID_COURT                 ; get distance from player 2 and mid court
   bcs .determineCPUPlayerShootingDelay
   eor #$FF                         ; get absolute value
   adc #1
.determineCPUPlayerShootingDelay
   clc
   adc player2HorizPos              ; increment by player 2 horizontal position
   lsr
   lsr
   sta cpuPlayerShootingDelay       ; i.e. (|y - mid | + x) / 4
   ldx #0
   beq .checkForFireButtonHeld      ; unconditional branch
       
DetermineCPUPlayerJoystickValues
   lda frameCount                   ; get current frame count
   and cpuPlayerAggression
   bne ReadJoystickActionButtonStatus
   lda joystickValue                ; get joystick value
   ora #P0_NO_MOVE
   sta joystickValue                ; set left port joystick value to NO_MOVE
   sec
   txa                              ; set to vertical position target
   sbc player2VertPos               ; subtract player 2 vertical position
   lda joystickValue                ; get joystick value
   bcs .setCPUOpponentToMoveDown    ; branch if target is lower then player 2
   and #MOVE_UP                     ; remove D4 to simulate MOVE_UP
   bcc .setCPUOpponentVerticalMovement;unconditional branch
   
.setCPUOpponentToMoveDown
   and #MOVE_DOWN                   ; remove D5 to simulate MOVE_DOWN
.setCPUOpponentVerticalMovement
   sta joystickValue
   sec
   tya                              ; set to horizontal position target
   sbc player2HorizPos              ; subtract CPU opponent horizontal position
   lda joystickValue                ; get joystick value
   bcs .setCPUOpponentToMoveRight   ; branch if target is to the right of player
   and #MOVE_LEFT                   ; remove D6 to simulate MOVE_LEFT
   bcc .setCPUOpponentHorizontalMovement;unconditional branch
   
.setCPUOpponentToMoveRight
   and #MOVE_RIGHT                  ; remove D7 to simulate MOVE_RIGHT
.setCPUOpponentHorizontalMovement
   sta joystickValue
ReadJoystickActionButtonStatus
   ldx #0
.readPlayerFireButton
   lda INPT4,x                      ; read the player's fire button value
   bmi .checkForFireButtonReleased  ; branch if fire button not pressed
.checkForFireButtonHeld
   ldy fireButtonDebounceValues,x   ; get player fire button debounce value
   bmi .checkNextPlayerFireButton   ; branch if fire button held last frame
   dey
   sty fireButtonDebounceValues,x   ; show fire button held this frame
   txa                              ; move player index to accumulator
   ora #PLAYER_HAS_BALL_STATUS      ; combine with PLAYER_HAS_BALL_STATUS
   cmp ballPossessionStatus
   bne .incrementPlayerJumpingValue ; branch if player doesn't have possession
   ora #PLAYER_HAS_BALL_STATUS | PLAYER_SHOOTING;combine with SHOOTING_STATUS
   sta ballPossessionStatus         ; set possession status to SHOOTING_STATUS
   sty shootingAnimationCount       ; clear shooting animation counter
   bne .checkNextPlayerFireButton   ; unconditional branch
       
.incrementPlayerJumpingValue
   ldy playerJumpingValues,x        ; get player jumping value
   bne .jmpToCheckNextPlayerFireButton
   inc playerJumpingValues,x
.jmpToCheckNextPlayerFireButton
   bne .checkNextPlayerFireButton   ; unconditional branch
   
.checkForFireButtonReleased
   lda fireButtonDebounceValues,x   ; get player fire button debounce value
   bpl .checkNextPlayerFireButton   ; branch if fire button not held
   ldy #0
   sty fireButtonDebounceValues,x   ; clear fire button debounce value
   txa                              ; move player index to accumulator
   ora #PLAYER_HAS_BALL_STATUS | PLAYER_SHOOTING;combine with SHOOTING_STATUS
   cmp ballPossessionStatus
   bne .checkNextPlayerFireButton   ; branch if player not shooting ball
   sty ballPossessionStatus         ; clear possession status
   lda ballBouncingDirectionStatus
   and #~BALL_BOUNCING_VERT_MASK    ; clear the ball vertical direction 
   ora bouncingBallVertDirection
   sta ballBouncingDirectionStatus
.checkNextPlayerFireButton
   inx
   cpx #MAX_NUM_PLAYERS - 1
   beq .readPlayerFireButton
   ldx #0
   stx player1RunningAnimation
   stx player2RunningAnimation
   inx                              ; x = 1
.determinePlayerMovement
   ldy playerJumpingValues,x        ; get player jumping value
   bne .determineNextPlayerMovement ; branch if player jumping
   ldy fireButtonDebounceValues,x   ; get fire button debounce value
   bmi .determineNextPlayerMovement ; branch if fire button held down
   lda joystickValue                ; get joystick value
   cpx #0
   bne .setTmpJoystickValue         ; branch if checking player 2
   lsr                              ; shift left port value to lower nybbles
   lsr
   lsr
   lsr
.setTmpJoystickValue
   and #$0F
   sta tmpJoystickValue             ; keep joystick movement value
   lda frameCount                   ; get current frame count
   and #3
   bne .checkPlayerJoystickValues   ; check difficulty switches every 4th frame
   cpx #1
   beq .checkRightPortDifficultySwitch;branch if checking player 2
   bit SWCHB                        ; check console difficulty switches
   bvs .determineNextPlayerMovement ; skip joystick movement if set to PRO
   bvc .checkPlayerJoystickValues   ; unconditional branch
       
.checkRightPortDifficultySwitch
   bit SWCHB                        ; check console difficulty switches
   bmi .determineNextPlayerMovement ; skip joystick movement if set to PRO
.checkPlayerJoystickValues
   lda tmpJoystickValue             ; get the temporary joystick value
   cmp #NO_MOVE >> 4
   beq .determinePlayerHorizChange  ; branch if not moved
   sta playerRunningAnimation,x
.determinePlayerHorizChange
   lsr                              ; move horizontal movement values to D1 - D0
   lsr
   tay                              ; move movement value to y register
   lda PositionChangeValues,y       ; get position delta for movement value
   beq .movePlayerHorizontally
   sta playerHorizontalDirection,x
.movePlayerHorizontally
   clc
   adc playersHorizPos,x
   sta playersHorizPos,x            ; set player's new horizontal position
   lda tmpJoystickValue             ; get the temporary joystick value
   and #3                           ; keep vertical movement values
   tay                              ; move movement value to y register
   lda PositionChangeValues,y       ; get position delta for movement value
   clc
   adc playersVertPos,x             ; change player vertical position
   cmp #YMAX
   bcs .determineNextPlayerMovement
   cmp #YMIN
   bcc .determineNextPlayerMovement
   sta playersVertPos,x             ; set player's new vertical position
.determineNextPlayerMovement
   dex
   beq .determinePlayerMovement
   ldx #1
.checkPlayerBallCollision
   lda CXP0FB,x                     ; get player collision value with PF or BALL
   and #$40                         ; keep player BALL collision value
   beq .checkNextPlayerBallCollision; branch if player didn't hit ball
   sec
   lda playersVertPos,x             ; get player's vertical position
   sbc ballVerticalPosition         ; subtract ball vertical position
   bcs .checkForPlayerStealingBall
   eor #$FF                         ; get absolute value from overflow
   adc #1
.checkForPlayerStealingBall
   ldy allowToBlockBallStatus       ; get status to see if player can block shot
   bne .checkNextPlayerBallCollision; branch if player cannot block shot
   bit ballPossessionStatus         ; check ball possession status
   bpl .checkForJumpingPlayerBlockingShot;branch if player doesn't have ball
   and #~1                          ; and distance with 2's complement of 1
   bne .checkNextPlayerBallCollision; branch if not within 1 scan line distance
   lda frameCount                   ; get current frame count
   and #1                           ; keep D0 value
   sta tmpOddEvenFrameCount
   cpx tmpOddEvenFrameCount
   bne .checkNextPlayerBallCollision; branch if not player's frame
.setPlayerBallPossessionStatus
   txa                              ; move player index to accumulator
   stx tmpBallPossessionPlayerIdx   ; set to index of player that has ball
   ora #PLAYER_HAS_BALL_STATUS
   sta ballPossessionStatus         ; set status to show player has ball
   lda #BALL_BOUNCING_RIGHT | BALL_BOUNCING_DOWN 
   sta ballBouncingDirectionStatus  ; set to bounce ball downward
   sta ballDribblingCount
   bne .checkBallPossessionStatus   ; unconditional branch
       
.checkForJumpingPlayerBlockingShot
   ldy playerJumpingValues,x        ; get player jumping value
   beq .checkForNonJumpingPlayerBlockingShot; branch if player not jumping
   and #~[(H_PLAYER * 2) - 1]
   beq .setPlayerBallPossessionStatus; block ball if player within 32 scan lines
   bne .checkNextPlayerBallCollision
       
.checkForNonJumpingPlayerBlockingShot
   and #~(H_PLAYER - 1)
   beq .setPlayerBallPossessionStatus; branch if within 16 scan line distance
.checkNextPlayerBallCollision
   dex
   bpl .checkPlayerBallCollision
.checkBallPossessionStatus
   bit ballPossessionStatus         ; check ball possession status
   bmi .determineBounceHeightForPossessedBall; branch if player has the ball
   jmp CheckBallForHittingBasket
       
.determineBounceHeightForPossessedBall
   bvs .determineBallHeightForShootingAnimation; branch if preparing to shoot
   ldx tmpBallPossessionPlayerIdx   ; get index of player that has ball
   lda playersVertPos,x             ; get player vertical position
   sta ballVerticalPosition         ; set ball vertical position
   sec
   lda playersHorizPos,x            ; get the player horizontal position
   sbc BallHorizPositionOffsetValues,x
   sta ballHorizPos                 ; set ball horizontal position
   lda ballDribblingCount           ; get ball dribbling count
   and #$0F
   cmp #8
   bcc .setBallHeightForDribbling
   eor #$0F                         ; get 1's complement to reduce bounce height
.setBallHeightForDribbling
   asl
   sta ballBounceHeight
   inc ballDribblingCount           ; increment ball dribbling count
   jmp DetermineToAllowBlockedShot
       
.determineBallHeightForShootingAnimation
   lda frameCount                   ; get current frame count
   and #3                           ; shooting amimation updated every 4 frames
   bne DetermineBouncingBallDirectionStatus
   sta ballGravityValue             ; clear ball gravity value
   inc shootingAnimationCount       ; increment shooting animation count
   lda shootingAnimationCount       ; get shooting animation count
   and #$0F
   cmp #8
   bcc .setShootingAnimationBallHeight
   eor #$0F                         ; get 1's complement to reduce value
.setShootingAnimationBallHeight
   tax
   clc
   adc #7                           ; increment value by 7
   sta shootingBallLift
   lda ShootingBallBounceHeightValues,x
   sta ballBounceHeight
   lda tmpBallPossessionPlayerIdx   ; get index of player that has ball
   bne .setPlayer1BallHorizontalPosition; branch if not player 2
   inc ballBounceHeight             ; increment ball bounce height
   clc
   lda player2HorizPos              ; get player2's horizontal position
   adc BallAndPlayerHorizOffsetValues,x
   sbc #2
   bne .setBallHorizontalPosition   ; unconditional branch
   
.setPlayer1BallHorizontalPosition
   sec
   lda player1HorizPos              ; get player1's horizontal position
   adc #10 - 1                      ; carry set
   sbc BallAndPlayerHorizOffsetValues,x
.setBallHorizontalPosition
   sta ballHorizPos
DetermineBouncingBallDirectionStatus
   ldy #BALL_BOUNCING_LEFT
   ldx tmpBallPossessionPlayerIdx   ; get index of player that has ball
   lda playersVertPos,x             ; get player with ball vertical position
   sta ballVerticalPosition         ; set ball's vertical position
   sec
   lda playersHorizPos,x            ; get player with ball horizontal position
   sbc UnderBasketHorizontalPosition,x; subtract basket horizontal position
   bcs .setPlayerHorizBasketDistance
   eor #$FF                         ; determine absolute value distance
   adc #1
   ldy #BALL_BOUNCING_RIGHT
.setPlayerHorizBasketDistance
   sta tmpPlayerBasketHorizDistance ; save horizontal distance from basket
   sty ballBouncingDirectionStatus  ; set ball horizontal bouncing direction
   ldy #BALL_BOUNCING_UP
   sec
   lda playersVertPos,x             ; get player with ball vertical position
   sbc #Y_MID_COURT                 ; subtract mid court position
   bcs .setPlayerVertMidCountDistance
   eor #$FF                         ; determine absolute value distance
   adc #1
   ldy #BALL_BOUNCING_DOWN
.setPlayerVertMidCountDistance
   sty bouncingBallVertDirection
   sta tmpPlayerMidCourtVertDistance; save vertical distance from mid court
   ldx #2
.determineMinimalPlayerDistance
   lda tmpPlayerDistanceValues - 1,x
   cmp #4
   bcs .setMinimalPlayerDistanceValue
   lda #4
.setMinimalPlayerDistanceValue
   sta tmpPlayerDistanceValues - 1,x
   dex
   bne .determineMinimalPlayerDistance
.divPlaeryDistanceBy2
   lsr tmpPlayerMidCourtVertDistance
   lsr tmpPlayerBasketHorizDistance
   ldx #1
.determineBallMotionDelay
   lda tmpPlayerDistanceValues,x
   cmp #2
   beq .setBallMotionDelay
   cmp #3
   beq DetermineBallMotionDelay
   dex
   beq .determineBallMotionDelay
   bne .divPlaeryDistanceBy2        ; unconditional branch
       
DetermineBallMotionDelay
   lda #2
   sta tmpPlayerDistanceValues,x
   txa                              ; move index to accumulator
   eor #1                           ; flip value to get alternate index
   tax                              ; set x to alternate index
   lda tmpPlayerDistanceValues,x    ; get player distance value
   lsr                              ; divide value by 4
   lsr
   sta tmpPlayerDistanceDiv4
   lda tmpPlayerDistanceValues,x
   sec
   sbc tmpPlayerDistanceDiv4
   sta tmpPlayerDistanceValues,x    ; player distance reduced by 25%
.setBallMotionDelay
   lda tmpPlayerBasketHorizDistance
   sta ballVertMotionDelay
   sta decBallVertMotionDelay
   lda tmpPlayerMidCourtVertDistance
   sta ballHorizMotionDelay
   sta decBallHorizMotionDelay
   jmp DetermineToAllowBlockedShot
       
CheckBallForHittingBasket
   bit CXBLPF                       ; check ball and playfield collision
   bpl .clearBallInHoopStatus       ; branch if ball didn't hit basket
   lda ballVerticalPosition         ; get the ball vertical position
   cmp #YMAX - 60
   bcc .clearBallInHoopStatus
   cmp #YMAX - 30
   bcs .clearBallInHoopStatus
   lda ballBounceHeight
   cmp #70
   bcs .checkForBallInTheHoop
   cmp #54
   bcc .clearBallInHoopStatus
   ldx #0                           ; assume ball is on the left side of screen
   lda ballHorizPos                 ; get the ball horizontal position
   cmp #(W_SCREEN + 1) / 2
   bcc .setScoringBasketStatus      ; branch if ball on left side of the court
   inx                              ; x = 1
.setScoringBasketStatus
   txa                              ; move ball side value to accumulator
   ora #BASKET_MADE_STATUS
   sta scoringBasketStatus          ; set to show made basket and which basket
   sta ballHorizMotionDelay
   sta ballVertMotionDelay
   lda UnderBasketHorizontalPosition,x
   sta ballHorizPos                 ; set ball horizontal position
   sta newOffensivePlayerHorizPos   ; set for offensive player
   lda #Y_MID_COURT
   sta ballVerticalPosition
   lda #12
   sta shootingBallLift
.checkForBallInTheHoop
   bit ballInHoopStatus             ; check ball in the hoop status
   bmi .checkForScoring             ; branch if ball in the hoop
   lda #$80
   sta ballInHoopStatus             ; set to show ball in the hoop
   eor ballBouncingDirectionStatus  ; flip ball horizontal bouncing direction
   sta ballBouncingDirectionStatus
   lda #2
   sta leftSoundChannelVolumeControl
   bne .checkForScoring             ; unconditional branch
       
.clearBallInHoopStatus
   lda #0
   sta ballInHoopStatus
.checkForScoring
   lda scoringBasketStatus          ; get scoring basket status
   bpl .checkToMoveBallHorizontally ; branch if ball not in basket
   ldy ballBounceHeight             ; get ball bouncing height
   cpy #30
   bcs .checkToMoveBallHorizontally
   and #BASKET_SCORED_MASK          ; keep D0 value for which basket scored
   tax                              ; x holds which basket scored
   sta scoringBasketStatus
   ldy #$08
   sty rightSoundChannelVolumeControl
   eor #1                           ; flip D0 so it now represents other player
   tay
   lda newOffensivePlayerHorizPos   ; get offensive player position value
   sta playersHorizPos,y            ; set player's new horizontal position
   lda #Y_MID_COURT
   sta playersVertPos,y             ; set offensive player vertical position
   ldy #(W_SCREEN + 1) / 2
   sty playersHorizPos,x            ; place defensive player at center court
   lda gameState                    ; get the current game state
   beq .checkToMoveBallHorizontally ; skip score increment if game over
   clc
   sed
   lda playerScores,x               ; get the player's score
   adc #2                           ; increment the player's score by 2 points
   sta playerScores,x               ; no three point shoots here :-)
   cld
   txa                              ; move player number to accumulator
   beq .decreaseCPUPlayerAggression ; branch if this for player 1
   lsr cpuPlayerAggression          ; increase computer player aggression
   bne .checkToMoveBallHorizontally
.decreaseCPUPlayerAggression
   sec                              ; set carry
   rol cpuPlayerAggression          ; roll carry bit into D0
.checkToMoveBallHorizontally
   dec decBallHorizMotionDelay
   bne .checkToMoveBallVertically
   lda ballHorizMotionDelay
   sta decBallHorizMotionDelay
   dec ballHorizPos                 ; decrement ball horizontal position
   bit ballBouncingDirectionStatus  ; check ball bouncing direction
   bmi .checkToMoveBallVertically   ; branch if ball bouncing left
   inc ballHorizPos
   inc ballHorizPos                 ; bounce the ball to the right
.checkToMoveBallVertically
   dec decBallVertMotionDelay
   bne DetermineBallLiftAndGravity
   lda ballVertMotionDelay
   sta decBallVertMotionDelay
   dec ballVerticalPosition         ; move ball up the court
   bit ballBouncingDirectionStatus  ; check ball bouncing direction
   bvc DetermineBallLiftAndGravity  ; branch if ball bouncing up
   inc ballVerticalPosition
   inc ballVerticalPosition         ; bounce ball down
DetermineBallLiftAndGravity
   lda frameCount                   ; get the current frame count
   and #3
   bne DetermineToAllowBlockedShot
   clc
   lda ballBounceHeight             ; get the current ball bounce height
   sta oldBallBounceHeight          ; set for comparing later
   adc shootingBallLift             ; increment height by lift
   sec
   sbc ballGravityValue             ; subtract current gravity value
   bcs .setBallBounceHeight
   lda shootingBallLift             ; get shooting ball lift value
   lsr                              ; divide value by 4
   lsr
   sta tmpShootingBallLiftDiv4
   sec
   lda shootingBallLift             ; get shooting ball lift value
   sbc tmpShootingBallLiftDiv4      ; subtract divide by 4 value
   sta shootingBallLift             ; shooting lift value reduced by 25%
   lda #<-1
   sta ballGravityValue
   lda #0
.setBallBounceHeight
   sta ballBounceHeight
   inc ballGravityValue
DetermineToAllowBlockedShot
   sta CXCLR                        ; clear hardware collisions
   ldy #0                           ; assume player allowed to block shot
   bit scoringBasketStatus          ; check scoring basket status
   bmi .noGoalTendingAllowed        ; branch if player made basket
   lda ballBounceHeight             ; get the ball bounce height
   cmp oldBallBounceHeight          ; compare with old ball bounce height
   bcs .setStatusToAllowBlockingShot; branch if greater than old height
   cmp #40
   bcc .setStatusToAllowBlockingShot
.noGoalTendingAllowed
   dey                              ; set to non-zero to not allow shot blocking
.setStatusToAllowBlockingShot
   sty allowToBlockBallStatus
   sec
   lda ballVerticalPosition         ; get ball vertical position
   sbc ballBounceHeight             ; subtract ball bounce height
   sta ballScanline                 ; set ball scanline for kernel
   lda ballBounceHeight
   cmp #2
   bcs PlayGameSounds
   lda #2
   sta leftSoundChannelVolumeControl
PlayGameSounds
   lda #$1F
   sta AUDF0
   lda #$0F
   sta AUDC0
   sta AUDF1
   dec leftSoundChannelVolumeControl
   bpl .setLeftChannelVolume
   lda #0                           ; set to turn off left channel volume
   inc leftSoundChannelVolumeControl; value now set to 0
.setLeftChannelVolume
   sta AUDV0
   lda #8
   dec rightSoundChannelVolumeControl
   bpl .setRightChannelVolume
   lda #0                           ; set to turn off right channel volume
   inc rightSoundChannelVolumeControl; value now set to 0
.setRightChannelVolume
   sta AUDV1
   lda gameState                    ; get the current game state
   bne SetupPlayerGraphics          ; branch if the game is in progress
   sta AUDV0                        ; turn off channel 0 volume
   sta AUDV1                        ; turn off channel 1 volume
SetupPlayerGraphics
   ldx #1
   lda #>PlayerSprites
   sta playerLegSpritePointer + 1   ; set sprite MSB values
   sta playerBodySpritePointer + 1
   lda #>playerGraphics
   sta spriteRAMPointer + 1         ; set the MSB value for the player graphics
.determinePayerSpriteGraphics
   lda frameCount                   ; get current frame count
   and #4
   bne .determineSpriteLegAnimation
   sta playerRunningAnimation,x
.determineSpriteLegAnimation
   lda playerRunningAnimation,x
   beq .setPlayerSpriteLegsToStationary
   lda #<PlayerLegsRunning
   bne .setPlayerLegSpritePointerLSB; unconditional branch
       
.setPlayerSpriteLegsToStationary
   lda #<PlayerLegsStationary       ; point to player sprite stationary legs
.setPlayerLegSpritePointerLSB
   sta playerLegSpritePointer       ; set player leg sprite LSB value
   lda ballPossessionStatus         ; get ball possession status
   bpl .setPlayerBodySpriteToDribble; branch if ball not in a player possession
   and #PLAYER_POSSESSION_MASK      ; keep player index holding ball
   stx tmpPlayerWithBall            ; move player index 
   cmp tmpPlayerWithBall
   bne .setPlayerBodySpriteToDribble; branch if current player not have ball
   lda ballBounceHeight
   cmp #12
   bcc .setPlayerBodySpriteToDribble
   cmp #32
   bcs .setPlayerBodySpriteToShooting_01
   ldy #<PlayerShootingAnimation_00
   bne .setPlayerBodySpritePointerLSB;unconditional branch
   
.setPlayerBodySpriteToShooting_01
   ldy #<PlayerShootingAnimation_01
   bne .setPlayerBodySpritePointerLSB;unconditional branch
       
.setPlayerBodySpriteToDribble
   ldy #<PlayerDribbleAnimation
.setPlayerBodySpritePointerLSB
   sty playerBodySpritePointer
   ldy #(H_PLAYER / 2) - 1
.setPlayerSpriteGraphics
   lda #<player2Graphics
   dex
   bne .movePlayerSpriteAnimationGraphicsToRAM
   lda #<player1Graphics
.movePlayerSpriteAnimationGraphicsToRAM
   inx
   sta spriteRAMPointer             ; set sprite RAM pointer LSB value
   lda (playerLegSpritePointer),y   ; read leg animation sprite data
   sta (spriteRAMPointer),y         ; set leg animation graphic data
   lda spriteRAMPointer             ; get sprite RAM pointer LSB value
   clc
   adc #(H_PLAYER / 2)              ; increment by half of player height
   sta spriteRAMPointer             ; set RAM pointer for body animation
   lda (playerBodySpritePointer),y  ; read body animation sprite data
   sta (spriteRAMPointer),y         ; set body animation graphic data
   dey
   bpl .setPlayerSpriteGraphics
   dex
   beq .determinePayerSpriteGraphics
   lda ballPossessionStatus         ; get ball possession status
   eor #PLAYER_HAS_BALL_STATUS      ; flip player possession status bit
   sta tmpDefensivePlayerIndex      ; keep index of defensive player
   ldx #1
.restrictPlayerToHorizCourtBoundaries
   ldy playersHorizPos,x            ; get player horizontal position
   lda playersVertPos,x             ; get player vertical position
   lsr                              ; divide position by 4
   lsr
   sta tmpPlayerVertPosDiv4
   clc
   adc #YMIN + 4
   cpx #0
   beq .setRightHorizBoundaryForPlayer1; branch if player 1
   cpx tmpDefensivePlayerIndex
   beq .determinePlayerRightHorizBoundary; branch if the defensive player
.setRightHorizBoundaryForPlayer1
   lda #XMAX
.determinePlayerRightHorizBoundary
   cmp playersHorizPos,x
   bcs .restrictPlayerToLeftHorizBoundary; branch if player to the left
   tay                              ; set y register to max horizontal boundary
.restrictPlayerToLeftHorizBoundary
   sec
   lda #56
   sbc tmpPlayerVertPosDiv4
   cpx #1
   beq .setLeftHorizBoundaryForPlayer2; branch if player 2
   cpx tmpDefensivePlayerIndex
   beq .determinePlayerLeftHorizBoundary
.setLeftHorizBoundaryForPlayer2
   lda #XMIN - 11
.determinePlayerLeftHorizBoundary
   cmp playersHorizPos,x
   bcc .setPlayerHorizPositionBoundary
   tay
.setPlayerHorizPositionBoundary
   sty playersHorizPos,x
   dex
   bpl .restrictPlayerToHorizCourtBoundaries
   ldx ballBounceHeight             ; get ball bounce height
   lda #0
   ldy ballHorizPos                 ; get ball horizontal position
   cpy #10
   bcs .checkBallWithRightCourtBorder; branch if ball inside left court
   tax                              ; x = 0
   lda #BALL_BOUNCING_HORIZ_MASK
   ldy #10
.checkBallWithRightCourtBorder
   cpy #W_SCREEN - 9
   bcc .changeBallHorizBouncingDirection; branch if ball inside right court
   tax
   lda #BALL_BOUNCING_HORIZ_MASK
   ldy #W_SCREEN - 10
.changeBallHorizBouncingDirection
   eor ballBouncingDirectionStatus  ; flip horizontal bouncing direction
   sta ballBouncingDirectionStatus
   sty ballHorizPos                 ; set ball new horizontal position
   stx ballBounceHeight
   lda ballVerticalPosition         ; get ball vertical position
   cmp #(YMAX / 2)
   bcs .checkBallForLowerCourtBorder; branch if ball in lower court
   lda #(YMAX / 2)
.checkBallForLowerCourtBorder
   cmp #YMAX
   bcc .setBallVerticalPosition
   lda #YMAX
.setBallVerticalPosition
   sta ballVerticalPosition
   ldx #1
.determinePlayerReflectState
   ldy #$FF
   lda #1
   bit ballPossessionStatus         ; check ball possession status
   bmi .setPlayerReflectForBallPossession; branch if ball in a player possession
   lda playerHorizontalDirection,x  ; get player horizontal direction
   bmi .setPlayerReflectValue       ; branch if moving left
   iny                              ; y = 0
.setPlayerReflectValue
   sty playerReflectValues,x
   dex
   beq .determinePlayerReflectState
   bne DetermineJumpingPlayer       ; unconditional branch
       
.setPlayerReflectForBallPossession
   bne .setPlayer2ReflectForBallPossession; branch if player 2 has possession
   sty player1HorizontalDirection
   sty player1ReflectValue
   lda player2HorizPos              ; get player2's horizontal position
   cmp player1HorizPos              ; compare with player1's horizontal position
   bcc .setPlayer2ReflectValue      ; branch if player 2 to the left of player 1
   iny                              ; y = 0 (i.e. NO_REFLECT)
.setPlayer2ReflectValue
   sty player2ReflectValue
   jmp DetermineJumpingPlayer
       
.setPlayer2ReflectForBallPossession
   iny                              ; y = 0 (i.e. NO_REFLECT)
   sty player2ReflectValue
   sty player2HorizontalDirection
   lda player2HorizPos              ; get player2's horizontal position
   cmp player1HorizPos              ; compare with player1's horizontal position
   bcc .setPlayer1ReflectValue      ; branch if player 2 to the left of player 1
   dey                              ; y = #$FF (i.e. REFLECT)
.setPlayer1ReflectValue
   sty player1ReflectValue
DetermineJumpingPlayer
   ldx #1
.determineJumpingPlayer
   lda playerJumpingValues,x        ; get player jumping value
   beq .changePlayerJumpingVertical ; branch if player not jumping
   inc playerJumpingValues,x        ; increment jumping value
   lda playerJumpingValues,x
   cmp #30
   bcs .clearPlayerJumpingValue     ; branch if player reached end of jump
   cmp #16
   bcs .playerDecendingJumpingArch  ; branch if player reached arch apex
   lda #<-3
   bne .changePlayerJumpingVertical ; move player up to arch apex
       
.playerDecendingJumpingArch
   lda #3
   bne .changePlayerJumpingVertical ; unconditional branch
       
.clearPlayerJumpingValue
   lda #0
   sta playerJumpingValues,x
.changePlayerJumpingVertical
   clc
   adc playersVertPos,x
   sta playersVertPos,x
   dex
   beq .determineJumpingPlayer
   jmp DisplayKernel
       
PlayerSprites
PlayerLegSprites
PlayerLegsRunning
   .byte $E0 ; |XXX.....|
   .byte $87 ; |X....XXX|
   .byte $84 ; |X....X..|
   .byte $84 ; |X....X..|
   .byte $FC ; |XXXXXX..|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
PlayerLegsStationary   
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
PlayerDribbleAnimation
   .byte $E3 ; |XXX...XX|
   .byte $EE ; |XXX.XXX.|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
PlayerShootingAnimation_00
   .byte $E0 ; |XXX.....|
   .byte $EE ; |XXX.XXX.|
   .byte $FB ; |XXXXX.XX|
   .byte $F1 ; |XXXX...X|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
PlayerShootingAnimation_01
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $FC ; |XXXXXX..|
   .byte $C4 ; |XX...X..|
   .byte $E4 ; |XXX..X..|
   .byte $F4 ; |XXXX.X..|
   .byte $E6 ; |XXX..XX.|
   
ShootingBallBounceHeightValues
   .byte 26, 26, 28, 30, 32, 34, 34, 34
       
UnderBasketHorizontalPosition
   .byte XMIN - 1, XMAX - 7
       
NumberFonts
zero
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
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
colon
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
;
; last byte shared with table below
;   
BasketGraphics
   .byte $00 ; |........|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   
BallAndPlayerHorizOffsetValues
   .byte 0, 0, 0, 0, 0, 0, 2, 4

GameColorTable
;
; Color Values
;
   .byte PLAYER_1_COLOR
   .byte PLAYER_2_COLOR
   .byte CLOCK_COLOR
   .byte BLACK
;
; B&W values
;
   .byte BLACK + 6
   .byte WHITE + 1
   .byte WHITE
;
; last 1 byte shared with next table so don't cross page boundaries
;
PositionChangeValues
   .byte 0, 1, -1, 0

   .org ROM_BASE + 2048 - 4, 234
   .word Start
   
BallHorizPositionOffsetValues
   .byte 3, -9
