   LIST OFF
; ***  F I S H I N G   D E R B Y  ***
; Copyright 1981 Activision, Inc.
; Designer: David Crane

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 7, 2019
;
;  *** 119 BYTES OF RAM USED 9 BYTES FREE
;  ***   1 BYTE OF ROM FREE
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
;
; - Fish kernel consists of 7 horizontal bands
; - ROM sprites must be separated by 16 bytes (i.e. H_FISH)
; - Added PAL60 switch to make for an easy PAL60 conversion
; - PAL50 version ~17% slower than NTSC...movement delay by frame count
; - Shark sprite drawn by HMOVE and NUSIZ values

   processor 6502

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
; F R A M E - T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 48
OVERSCAN_TIME           = 32

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 75
OVERSCAN_TIME           = 63
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
ORANGE                  = $40
BLUE                    = $80

COLOR_FISHERMAN_FACE    = ORANGE + 10
COLOR_LEFT_FISHERMAN    = ORANGE + 2
COLOR_RIGHT_FISHERMAN   = ORANGE + 2
COLOR_PLATFORM          = BLACK
COLOR_SKY               = BLUE + 12
COLOR_EOR               = BLUE + 4
COLOR_SEA               = BLUE + 2
COLOR_SHARK             = BLACK
COLOR_FISH              = YELLOW + 12

   ELSE
   
YELLOW                  = $20
RED                     = $60
BLUE                    = $B0

COLOR_FISHERMAN_FACE    = RED + 10
COLOR_LEFT_FISHERMAN    = BLUE
COLOR_RIGHT_FISHERMAN   = BLUE
COLOR_PLATFORM          = BLACK
COLOR_SKY               = BLUE + 12
COLOR_EOR               = BLUE + 4
COLOR_SEA               = BLUE + 2
COLOR_SHARK             = BLACK
COLOR_FISH              = YELLOW + 12

   ENDIF
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

FISH_KERNEL_SECTIONS    = 7

H_DIGITS                = 8
H_COPYRIGHT             = 8
H_FISHERMAN_HEAD        = 8
H_FISHERMAN_BODY        = 16
H_FISH                  = 16
H_WATER_SHIMMER         = 16

H_FISH_KERNEL           = [(FISH_KERNEL_SECTIONS - 1) * H_FISH]

XMIN                    = 0
XMAX                    = 160

XMIN_FISH               = XMIN + 20
XMAX_FISH               = XMAX - 29
XMAX_SHARK              = XMAX - 56

MIN_FISHING_POLE_VALUE  = 4
MAX_FISHING_POLE_VALUE  = 15

MIN_FISH_HOOK_VERT      = 0
MAX_FISH_HOOK_VERT      = 48

FISH_TYPE_MASK          = %10000000
ID_SHARK                = 1 << 7
ID_FISH                 = 0 << 7
FISH_DIRECTION_MASK     = %00001000
FISH_MOVEMENT_DELAY     = %00000111
FISH_DIRECTION_LEFT     = 1 << 3
FISH_DIRECTION_RIGHT    = 0 << 3

MAX_SCORE               = $99

BLANK_NUMBER_PTR        = (Blank - NumberFonts) / H_DIGITS

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gameSelection           ds 1
frameCount              ds 1
randomSeed              ds 1
screenSaverColorEOR     ds 1
hueMask                 ds 1
objectColors            ds 8
;--------------------------------------
fishermanColors         = objectColors
;--------------------------------------
leftFishermanColor      = fishermanColors
rightFishermanColor     = leftFishermanColor + 1; not referenced
platformColors          = rightFishermanColor + 1
skyColor                = platformColors + 1
colorEOR                = skyColor + 1
seaColor                = colorEOR + 1
floatingFishColors      = seaColor + 1
;--------------------------------------
sharkColor              = floatingFishColors
fishColors              = sharkColor + 1
joystickValues          ds 2
;--------------------------------------
player1JoystickValue    = joystickValues
player2JoystickValue    = player1JoystickValue + 1
zp_Unused_01            ds 1
selectDebounce          ds 1        ; non-zero shows SELECT held
fishingPolePFValues     ds 4
;--------------------------------------
fishingPolePF1Values    = fishingPolePFValues
;--------------------------------------
leftFishingPolePF1Value = fishingPolePF1Values
rightFishingPolePF1Value = leftFishingPolePF1Value + 1
fishingPolePF2Values    = fishingPolePFValues + 2
;--------------------------------------
leftFishingPolePF2Value = fishingPolePF2Values
rightFishingPolePF2Value = leftFishingPolePF2Value + 1
fishingPoleValues       ds 2
;--------------------------------------
leftFishingPoleValues   = fishingPoleValues
rightFishingPoleValues  = leftFishingPoleValues + 1
playerFishingLineHorizPos ds 2
;--------------------------------------
leftFishingLineHorizPos = playerFishingLineHorizPos
rightFishingLineHorizPos = leftFishingLineHorizPos + 1
zp_Unused_02            ds 1
fishingLineSlopeIntegerValue ds 2
;--------------------------------------
leftFishingLineSlopeIntegerValue = fishingLineSlopeIntegerValue
rightFishingLineSlopeIntegerValue = leftFishingLineSlopeIntegerValue + 1
fishingLineSlopeFractionValues ds 2
;--------------------------------------
leftFishingLineSlopeFractionValue = fishingLineSlopeFractionValues
rightFishingLineSlopeFractionValue = leftFishingLineSlopeFractionValue + 1
fishingLineHMOVEValues  ds 2
;--------------------------------------
leftFishingLineHMOVEValue = fishingLineHMOVEValues
rightFishingLineHMOVEValue = leftFishingLineHMOVEValue + 1
fishingHookHorizPos     ds 2
;--------------------------------------
leftFishingHookHorizPos = fishingHookHorizPos
rightFishingHookHorizPos = leftFishingHookHorizPos + 1
fishingLineHookHorizDistance ds 2
;--------------------------------------
leftFishingLineHookHorizDistance = fishingLineHookHorizDistance
rightFishingLineHookHorizDistance = leftFishingLineHookHorizDistance + 1
fishingHookVertDistance ds 2
;--------------------------------------
leftPlayerHookVertDistance = fishingHookVertDistance
rightPlayerHookVertDistance = leftPlayerHookVertDistance + 1
hookedFishHorizPos      ds 1
playerHookedFishIndex   ds 1
hookedFishStatus        ds 1
hookedFishLSBOffset     ds 1
hookedFishCoarsePosition ds 1
hookedFishFineMotion    ds 1
fishingHookSkillMask    ds 2
;--------------------------------------
leftFishingHookSkillMask = fishingHookSkillMask
rightFishingHookSkillMask = leftFishingHookSkillMask + 1
digitGraphicPtrs        ds 8
;--------------------------------------
tensDigitGraphicPtrs    = digitGraphicPtrs
;--------------------------------------
player1TensDigitGraphicPtrs = tensDigitGraphicPtrs
player2TensDigitGraphicPtrs = player1TensDigitGraphicPtrs + 2
;--------------------------------------
onesDigitGraphicPtrs    = digitGraphicPtrs + 4
;--------------------------------------
player1OnesDigitGraphicPtrs = onesDigitGraphicPtrs
player2OnesDigitGraphicPtrs = onesDigitGraphicPtrs + 2
floatingFishGraphicPtrs ds 2
hookedFishGraphicPtrs   ds 2
floatingFishNUSIZPtrs   ds 2
colorCycleMode          ds 1
playerScore             ds 2
;--------------------------------------
player1Score            = playerScore
player2Score            = player1Score + 1
hookedFishVertPos       ds 1
gameState               ds 1
fishingHookVertPos      ds 2
;--------------------------------------
leftFishingHookVertPos  = fishingHookVertPos
rightFishingHookVertPos = leftFishingHookVertPos + 1
fishingHookKernelValues ds 2
;--------------------------------------
leftFishingHookKernelValue = fishingHookKernelValues
rightFishingHookKernelValue = leftFishingHookKernelValue + 1
floatingFishHorizPos    ds 7
;--------------------------------------
sharkHorizPos           = floatingFishHorizPos + 6
floatingFishCoarsePosition ds 7
;--------------------------------------
sharkCoarsePosition     = floatingFishCoarsePosition + 6
floatingFishFineMotion  ds 7
;--------------------------------------
sharkFineMotion         = floatingFishFineMotion + 6
floatingFishStatus      ds 7
;--------------------------------------
sharkStatus             = floatingFishStatus + 6
floatingFishLSBValues   ds 7
;--------------------------------------
sharkLSBValue           = floatingFishLSBValues + 6
hookedFishLSBValues     ds 7
zp_Unused_03            ds 1
hookedFishIndex         ds 2
;--------------------------------------
leftHookedFishIndex     = hookedFishIndex
rightHookedFishIndex    = leftHookedFishIndex + 1
caughtFishWeight        ds 2
;--------------------------------------
player1CaughtFishWeight = caughtFishWeight
player2CaughtFishWeight = player1CaughtFishWeight + 1
sharkAteFishValue       ds 1        ; any non-zero shows shark ate fish
sharkFishCollisionValues ds 1
audioChannelEatingFish  ds 1
div16Remainder          ds 1
;--------------------------------------
tmpFloatingFishNUSIZMask = div16Remainder
;--------------------------------------
tmpFloatingFishDir      = tmpFloatingFishNUSIZMask
;--------------------------------------
tmpFloatingFishLSBOffset = tmpFloatingFishDir
;--------------------------------------
tmpPlayer2FishingLineOffset = tmpFloatingFishLSBOffset
;--------------------------------------
tmpCPUPlayerAllowedMotion = tmpPlayer2FishingLineOffset
;--------------------------------------
tmpFishingLineHookDistance = tmpCPUPlayerAllowedMotion
;--------------------------------------
tmpFishingHookVertPos   = tmpFishingLineHookDistance
;--------------------------------------
tmpHorizDistRiseDiff    = tmpFishingHookVertPos
tmpHookedFishDir        ds 1
;--------------------------------------
tmpFishingHookVertDistance = tmpHookedFishDir
fishingHookHorizLineDiff ds 1

   echo "***",(* - $80 - 3)d, "BYTES OF RAM USED", ($100 - * + 3)d, "BYTES FREE"

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
RestartGame
   lda #0
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   lda #PF_PRIORITY | PF_REFLECT
   sta CTRLPF
   jsr InitializeGame
   lda randomSeed                   ; get random seed value
   bne MainLoop                     ; branch if been through cart startup once
   ldx #1
   stx randomSeed                   ; initialize random seed
   dex                              ; x = 0
   jmp SetGameSelection
       
MainLoop
   ldx #<[fishColors - objectColors]
.setObjectColors
   lda GameColors,x                 ; read game color table
   eor screenSaverColorEOR          ; flip color bits based on color cycling
   and hueMask                      ; mask color values for COLOR / B&W mode
   sta objectColors,x
   cpx #<[colorEOR - objectColors]
   bcs .nextObjectColor
   sta COLUP0,x
.nextObjectColor
   dex
   bpl .setObjectColors
   lda leftFishingHookVertPos       ; get left fishing hook vertical position
   sta leftFishingHookKernelValue   ; value decremented in kernel
   lda rightFishingHookVertPos      ; get right fishing hook vertical position
   sta rightFishingHookKernelValue  ; value decremented in kernel
   lda rightFishingLineHorizPos     ; get right fishing line position
   ldx #<[HMBL - HMP0]
   jsr PositionObjectHorizontally   ; position player 2 fishing line
   lda leftFishingLineHorizPos      ; get left fishing line position
   dex                              ; x = 3 (i.e. HMM1)
   jsr PositionObjectHorizontally   ; postion player 1 fishing line
   lda leftFishingLineSlopeFractionValue
   sta leftFishingLineSlopeIntegerValue
   lda rightFishingLineSlopeFractionValue
   sta rightFishingLineSlopeIntegerValue
   lda #40
   ldx #<[HMP0 - HMP0]
   stx REFP0
   jsr PositionObjectHorizontally   ; horizontally position score tens digit
   lda #48
   inx                              ; x = 1 (i.e. HMP1)
   jsr MoveObjectHorizontally       ; horizontally position score ones digit
   lda #MSBL_SIZE8 | TWO_WIDE_COPIES
   sta NUSIZ0
   sta NUSIZ1
   sta PF0
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   sta HMCLR                  ; 3 = @06
   sta CXCLR                  ; 3 = @09
   ldy #H_DIGITS - 1          ; 2
.drawDigits
   sta WSYNC
;--------------------------------------
   lda (player1TensDigitGraphicPtrs),y;5
   sta GRP0                   ; 3 = @08
   lda (player1OnesDigitGraphicPtrs),y;5
   sta GRP1                   ; 3 = @16
   jsr Waste18Cycles          ; 18
   lda (player2TensDigitGraphicPtrs),y;5
   sta GRP0                   ; 3 = @42
   lda (player2OnesDigitGraphicPtrs),y;5
   sta GRP1                   ; 3 = @50
   dey                        ; 2
   bpl .drawDigits            ; 2³
   sta WSYNC
;--------------------------------------
   lda #REFLECT               ; 2
   sta REFP1                  ; 3 = @05   set player 2 fisherman to REFLECT
   ldx #0                     ; 2
   stx GRP0                   ; 3 = @10
   stx GRP1                   ; 3 = @13
   jsr PositionObjectHorizontally;6       position player 1 fisherman
   inx                        ; 2         x = 1 (i.e. HMP1)
   lda #134                   ; 2
   jsr MoveObjectHorizontally ; 6         position player 2 fisherman
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ0                 ; 3         set to DOUBLE_SIZE to draw heads
   sta NUSIZ1                 ; 3
   ldy #H_FISHERMAN_HEAD - 1  ; 2
.drawFishermanHeads
   sta WSYNC
;--------------------------------------
   lda FishermanHeadGraphics,y; 4
   sta GRP0                   ; 3 = @07
   sta GRP1                   ; 3 = @10
   lda screenSaverColorEOR    ; 3
   cpy #H_FISHERMAN_HEAD - 3  ; 2
   bcs .colorFishermanHeads   ; 2³        branch if coloring hats
   eor #COLOR_FISHERMAN_FACE  ; 2         color fisherman face
.colorFishermanHeads
   and hueMask                ; 3
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   ldx #$CF                   ; 2         graphic bytes for fisherman neck
   sta WSYNC
;--------------------------------------
   dey                        ; 2
   bpl .drawFishermanHeads    ; 2³
   stx GRP0                   ; 3 = @07
   lda leftFishermanColor     ; 3         get color for left fisherman body
   sta COLUP0                 ; 3 = @13   set color for left fisherman body
   eor colorEOR               ; 3         flip bits
   sta COLUP1                 ; 3 = @19   set color for right fisherman body
   lda leftFishingPolePF1Value; 3
   sta PF1                    ; 3 = @25   set PF1 value for left fishing pole
   lda leftFishingPolePF2Value; 3
   sta PF2                    ; 3 = @31   set PF2 value for left fishing pole
   lda #ENABLE_BM             ; 2
   sta ENABL                  ; 3 = @36   enable for right fishing line
   sta ENAM1                  ; 3 = @39   enable for left fishing line
   stx GRP1                   ; 3 = @42
   lda rightFishingPolePF2Value;3
   sta PF2                    ; 3 = @48   set PF2 value for right fishing pole
   lda rightFishingPolePF1Value;3
   sta PF1                    ; 3 = @54   set PF1 value for right fishing pole
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF1                    ; 3 = @05
   sta PF2                    ; 3 = @08
   ldy #H_FISHERMAN_BODY - 1  ; 2
   sta HMCLR                  ; 3 = @13
.drawFishermanBody
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   tya                        ; 2         move index to accumulator
   lsr                        ; 2         divide index by 2
   tax                        ; 2         move index to x register
   lda FishermanBodyGraphics,x; 4
   sta GRP0                   ; 3 = @16
   sta GRP1                   ; 3 = @19
   tya                        ; 2         move index to accumulator
   and #1                     ; 2         keep D0 value
   tax                        ; 2         set x register to player number
   clc                        ; 2
   lda fishingLineSlopeIntegerValue,x;4   get fishing line slope integer value
   adc fishingLineSlopeFractionValues,x;4 increment by slope fraction value
   sta fishingLineSlopeIntegerValue,x;4   set fishing line slope integer value
   sta HMCLR                  ; 3 = @42
   bcc .nextFishermanBodyScanline;2³      branch if no overflow
   lda fishingLineHMOVEValues,x;4         get fishing line HMOVE value
   sta HMM1,x                 ; 4 = @52   set to adjust fishing line position
.nextFishermanBodyScanline
   dey                        ; 2
   bpl .drawFishermanBody     ; 2³ + 1    crosses a page boundary
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @08
   sty GRP1                   ; 3 = @11
   lda #$F0                   ; 2
   sta PF0                    ; 3 = @16   set to draw platform
   asl                        ; 2
   sta PF1                    ; 3 = @21
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$70                   ; 2
   sta PF0                    ; 3 = @08   set to draw platform support
   lda #$A0                   ; 2
   sta PF1                    ; 3 = @13
   lda hookedFishStatus       ; 3         get status values of hooked fish
   sta REFP1                  ; 3 = @19   set caught fish REFLECT state
   lda hookedFishFineMotion   ; 3
   sta HMP1                   ; 3         set fine motion value for hooked fish
   ldy hookedFishCoarsePosition;3
   sta WSYNC
;--------------------------------------
.coarsePostionHookedFish
   dey                        ; 2
   bpl .coarsePostionHookedFish;2³
   sta.w RESP1                ; 4
   sta WSYNC
;--------------------------------------
   iny                        ; 2         y = 0
   sty NUSIZ1                 ; 3         set to MSBL_SIZE1 | ONE_COPY
   sty NUSIZ0                 ; 3         set to MSBL_SIZE1 | ONE_COPY
   ldy #H_WATER_SHIMMER - 1   ; 2
   lda randomSeed             ; 3         get random seed value
.colorWaterShimmer
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   and #2                     ; 2         keep random seed D1 bit
   eor colorEOR               ; 3         flip color bits
   sta COLUBK                 ; 3 = @11   set color for water shimmer
   cpy #(H_WATER_SHIMMER / 2) - 1;2
   bcs .determineFishingLineRunValue;2³
   eor #6                     ; 2
   sta COLUPF                 ; 3 = @20   color platform
   sta COLUP1                 ; 3 = @23   color player 1 fishing line
.determineFishingLineRunValue
   tya                        ; 2         move index to accumulator
   and #1                     ; 2         keep D0 value
   tax                        ; 2         set x register to player number
   clc                        ; 2
   lda fishingLineSlopeIntegerValue,x;4   get fishing line slope integer value
   adc fishingLineSlopeFractionValues,x;4 increment by slope fraction value
   sta fishingLineSlopeIntegerValue,x;4   set fishing line slope integer value
   sta HMCLR                  ; 3 = @46
   bcc .nextWaterShimmerScanline;2³
   lda fishingLineHMOVEValues,x;4         get fishing line HMOVE value
   sta HMM1,x                 ; 4 = @56   set to adjust fishing line position
.nextWaterShimmerScanline
   lda randomSeed             ; 3         get random seed value
   cmp #128                   ; 2         set carry if 255 <= a <= 128
   rol                        ; 2         multiply by 2 with carry in D0
   sta randomSeed             ; 3         a = 2a + (a > 127)
   dey                        ; 2
   bpl .colorWaterShimmer     ; 2³
   sta WSYNC
;--------------------------------------
   lda seaColor               ; 3
   sta COLUBK                 ; 3 = @06   color sea
   lda platformColors         ; 3
   sta COLUPF                 ; 3 = @12   color platform supports
   lda fishColors             ; 3
   sta COLUP1                 ; 3 = @18   color caught fish
   ldy #<-2                   ; 2
   ldx #FISH_KERNEL_SECTIONS - 1;2
.fishKernelSection
   sta WSYNC
;--------------------------------------
   iny                        ; 2
   sty tmpFloatingFishNUSIZMask;3
   iny                        ; 2
   lda floatingFishColors,y   ; 4
   sta COLUP0                 ; 3 = @14   color floating fish
   lda hookedFishLSBValues,x  ; 4
   sta hookedFishGraphicPtrs  ; 3         set hooked fish graphic LSB value
   ldy #H_FISH - 1            ; 2
   lda (hookedFishGraphicPtrs),y;5
   sta GRP1                   ; 3 = @31   draw caught fish
   lda floatingFishStatus,x   ; 4         get floating fish status value
   sta REFP0                  ; 3 = @38   set floating fish REFLECT state
   lda CXPPMM                 ; 3         get player collision value
   asl                        ; 2         shift player collision to carry
   ror sharkFishCollisionValues;5         shift value to D0
   lda floatingFishLSBValues,x; 4         get floating fish LSB value
   sta floatingFishGraphicPtrs; 3         set floating fish graphic LSB value
   lda floatingFishFineMotion,x;4
   sta HMP0                   ; 3 = @62   set floating fish fine motion value
   ldy #H_FISH - 2            ; 2
   lda (hookedFishGraphicPtrs),y;5
   ldy floatingFishCoarsePosition,x;4
   sta GRP1                   ; 3 = @76
;--------------------------------------
.coarsePostionFloatingFish
   dey                        ; 2
   bpl .coarsePostionFloatingFish;2³
   sta.w RESP0                ; 4
   ldy #H_FISH - 3            ; 2
.drawFishKernelSection
   lda (floatingFishGraphicPtrs),y;5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw floating fish
   lda (hookedFishGraphicPtrs),y;5
   sta GRP1                   ; 3 = @14   draw hooked fish
   lda (floatingFishNUSIZPtrs),y;5        get NUSIZ value for floating fish
   and tmpFloatingFishNUSIZMask;3
   sta NUSIZ0                 ; 3 = @25   set NUSIZ value
   sta HMCLR                  ; 3 = @28
   sta HMP0                   ; 3 = @31
   dec rightFishingHookKernelValue;5
   bpl .determineRightFishingLineRunValue;2³
   lda #DISABLE_BM            ; 2
   sta ENABL                  ; 3 = @43   disable right fishing line
.determineRightFishingLineRunValue
   clc                        ; 2
   lda rightFishingLineSlopeIntegerValue;3
   adc rightFishingLineSlopeFractionValue;3
   sta rightFishingLineSlopeIntegerValue;3
   bcc .leftFishingLineKernel ; 2³
   lda rightFishingLineHMOVEValue;3
   sta HMBL                   ; 3 = @62
.leftFishingLineKernel
   dey                        ; 2
   lda (floatingFishGraphicPtrs),y;5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw floating fish
   lda (hookedFishGraphicPtrs),y;5
   sta GRP1                   ; 3 = @14   draw hooked fish
   lda (floatingFishNUSIZPtrs),y;5        get NUSIZ value for floating fish
   and tmpFloatingFishNUSIZMask;3
   sta NUSIZ0                 ; 3 = @25   set NUSIZ value
   sta HMCLR                  ; 3 = @28
   sta HMP0                   ; 3 = @31
   dec leftFishingHookKernelValue;5
   bpl .determineLeftFishingLineRunValue;2³
   lda #DISABLE_BM            ; 2
   sta ENAM1                  ; 3         disable left fishing line
.determineLeftFishingLineRunValue
   clc                        ; 2
   lda leftFishingLineSlopeIntegerValue;3
   adc leftFishingLineSlopeFractionValue;3
   sta leftFishingLineSlopeIntegerValue;3
   bcc .nextDrawFishKernelSection;2³
   lda leftFishingLineHMOVEValue;3
   sta HMM1                   ; 3 = @63
.nextDrawFishKernelSection
   dey                        ; 2
   bpl .drawFishKernelSection ; 2³
   dex                        ; 2
   bmi CopyrightKernel        ; 2³
   jmp .fishKernelSection     ; 3
       
CopyrightKernel
   sta WSYNC
;--------------------------------------
   lda platformColors         ; 3
   sta COLUBK                 ; 3 = @06
   ldx #0                     ; 2
   stx PF1                    ; 3 = @11   clear playfield graphic registers
   stx REFP0                  ; 3 = @14
   stx REFP1                  ; 3 = @17
   inx                        ; 2         x = 1 (i.e. TWO_COPIES)
   stx NUSIZ0                 ; 3 = @22
   stx NUSIZ1                 ; 3 = @25
   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @36
   ldx #H_COPYRIGHT - 1       ; 2
.drawActivisionLogo
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda Copyright_0,x          ; 4
   sta GRP0                   ; 3 = @10
   lda Copyright_1,x          ; 4
   sta GRP1                   ; 3 = @17
   SLEEP 2                    ; 2
   lda Copyright_3,x          ; 4
   tay                        ; 2
   lda Copyright_2,x          ; 4
   sta GRP0                   ; 3 = @32
   sty GRP1                   ; 3 = @35
   sta HMCLR                  ; 3 = @38
   dex                        ; 2
   bpl .drawActivisionLogo    ; 2³
Overscan

   IF COMPILE_REGION = PAL50

   sta WSYNC
   lda #OVERSCAN_TIME
   sta TIM64T
   sta VBLANK                       ; disable TIA (D1 = 1)

   ELSE

   lda #OVERSCAN_TIME
   sta TIM64T

   ENDIF

   ldx #FISH_KERNEL_SECTIONS - 1
.moveFloatingFish
   lda floatingFishStatus,x         ; get floating fish status value
   tay                              ; move status to y register
   and #FISH_MOVEMENT_DELAY         ; keep movement delay value
   and frameCount
   ora gameState                    ; combine with current game state
   bne .moveNextFish                ; branch if not time to move fish
   tya                              ; move status to accumulator
   and #FISH_DIRECTION_MASK         ; keep REFLECT state
   bne .moveFishLeft                ; branch if fish facing left
   inc floatingFishHorizPos,x
   inc floatingFishHorizPos,x
.moveFishLeft
   dec floatingFishHorizPos,x
   ldy #<[FishSprite_01 - H_FISH]
   lda floatingFishHorizPos,x       ; get floating fish horizontal position
   and #2                           ; keep D1 value
   bne .setFloatingFishLSBOffset
   ldy #<[FishSprite_02 - H_FISH]
.setFloatingFishLSBOffset
   sty tmpFloatingFishLSBOffset
   lda hookedFishVertPos            ; get hooked fish vertical position
   beq .animateFishSprite           ; branch if fish not hooked
   ldy playerHookedFishIndex        ; get player number for hooked fish
   inx                              ; increment fish index value
   txa                              ; move index value to accumulator
   dex                              ; restore fish index value
   cmp hookedFishIndex,y
   bne .animateFishSprite           ; branch if not current hooked fish
   lda tmpFloatingFishLSBOffset
   sta hookedFishLSBOffset
   lda floatingFishStatus,x         ; get floating fish status value
   sta hookedFishStatus
   lda #<[Blank - H_FISH]
   sta tmpFloatingFishLSBOffset
.animateFishSprite
   lda tmpFloatingFishLSBOffset
   clc
   adc #H_FISH
   ldy floatingFishStatus,x         ; get floating fish status value
   bpl .setFloatingFishLSBValue     ; branch if not ID_SHARK
   adc #<[SharkSprite_01 - Blank - H_FISH]
.setFloatingFishLSBValue
   sta floatingFishLSBValues,x
   ldy #FISH_DIRECTION_RIGHT
   lda floatingFishHorizPos,x       ; get floating fish horizontal position
   cmp #XMIN_FISH
   bcc .setFloatingFishDirectionValue
   ldy #FISH_DIRECTION_LEFT
   lda #XMAX_FISH
   cpx #6
   bne .determineFishReachedRightBoundary; branch if not ID_SHARK
   lda #XMAX_SHARK
.determineFishReachedRightBoundary
   cmp floatingFishHorizPos,x       ; compare floating fish horizontal position
   bcs .moveNextFish
.setFloatingFishDirectionValue
   sty tmpFloatingFishDir
   lda floatingFishStatus,x         ; get floating fish status value
   and #~FISH_DIRECTION_MASK        ; clear FISH_DIRECTION_MASK value
   ora tmpFloatingFishDir           ; combine with new direction
   sta floatingFishStatus,x
.moveNextFish
   dex
   bpl .moveFloatingFish
   lda frameCount                   ; get current frame count
   and #7
   beq CheckToScorePointsForCatchingFish
   tax
   dex                              ; 1 <= x <= 6
   lda floatingFishStatus,x         ; get floating fish status value
   bmi CheckToScorePointsForCatchingFish; branch if ID_SHARK
   lda randomSeed                   ; get random seed value
   eor frameCount
   and #7
   ora gameState                    ; combine with current game state
   bne CheckToScorePointsForCatchingFish
   lda floatingFishStatus,x         ; get floating fish status value
   eor #FISH_DIRECTION_MASK         ; flip the FISH_DIRECTION_MASK value
   sta floatingFishStatus,x         ; change fish direction
CheckToScorePointsForCatchingFish
   lda frameCount                   ; get current frame count
   and #1                           ; keep D0 value
   tax
   lda audioChannelEatingFish       ; get audio value for eating fish
   sta AUDC0,x
   beq .checkToScoreForCatchingFish
   dec audioChannelEatingFish
.checkToScoreForCatchingFish
   lda caughtFishWeight,x           ; get caught fish weight value
   beq BCD2Digits                   ; branch if done tallying weight
   lda frameCount                   ; get current frame count
   and #2
   ora gameState                    ; combine with current game state
   bne BCD2Digits
   lda #4
   sta AUDC0,x                      ; set audio channel for scoring points
   sed
   lda playerScore,x                ; get player score
   clc
   adc #1                           ; increment score by 1
   sta playerScore,x
   cmp #MAX_SCORE
   bne .doneIncrementScore
   sta gameState                    ; set to show game not in session
   lda #1                           ; set so game halts next time through
   sta caughtFishWeight,x
.doneIncrementScore
   cld
   dec caughtFishWeight,x
BCD2Digits
   txa                              ; move player number to accumulator
   asl                              ; multiply player number by 2
   tay
   lda playerScore,x                ; get player score value
   and #$F0                         ; keep tens value
   lsr                              ; divide value by 2
   bne .setTensValueGraphicPointer
   lda #<Blank
.setTensValueGraphicPointer
   sta tensDigitGraphicPtrs,y
   lda playerScore,x                ; get player score value
   and #$0F                         ; keep ones value
   asl                              ; multiply value by 8
   asl
   asl
   sta onesDigitGraphicPtrs,y
   lda #0
   sta fishingPolePF1Values,x
   sta fishingPolePF2Values,x
   ldy fishingPoleValues,x
   beq DetermineFishingLineHorizPos
.setFishingPolePFValues
   sec                              ; set carry bit
   ror fishingPolePF1Values,x       ; rotate caryy to D7 and D0 to carry
   rol fishingPolePF2Values,x       ; rotate D7 to carry and carry to D0
   dey
   bne .setFishingPolePFValues
DetermineFishingLineHorizPos
   lda fishingPoleValues,x          ; get fishing pole values
   asl                              ; multiply value by 4
   asl
   clc                              ; not needed...carry cleared from asl
   adc #16
   cpx #<[rightFishingPoleValues - leftFishingPoleValues]
   bne .setFishingLineHorizPos      ; branch if determing left player line
   sta tmpPlayer2FishingLineOffset
   lda #XMAX
   sec
   sbc tmpPlayer2FishingLineOffset
.setFishingLineHorizPos
   sta playerFishingLineHorizPos,x
   lda frameCount                   ; get current frame count
   and #7                           ; update random values every 8th frame
   bne DetermineHookedFishLSBValue
   ldy #2
.nextRandom
   lda randomSeed
   asl
   asl
   asl
   eor randomSeed
   asl
   rol randomSeed
   dey
   bpl .nextRandom
DetermineHookedFishLSBValue
   lda hookedFishVertPos            ; get hooked fish vertical position
   beq CheckPlayerJoystickValues    ; branch if fish not hooked
   sec
   lda #H_FISH_KERNEL - 1
   sbc hookedFishVertPos
   lsr                              ; divide value by 16
   lsr
   lsr
   lsr
   tay                              ; set y to hooked fish kernel section
   lda hookedFishVertPos            ; get hooked fish vertical position
   and #$0F                         ; get mod 16 value
   clc
   adc hookedFishLSBOffset          ; add with graphic LSB value
   sta hookedFishLSBValues,y        ; set hooked fish graphic LSB value
   clc
   adc #H_FISH                      ; increment with H_FISH
   sta hookedFishLSBValues + 1,y    ; set adjacent graphic LSB value
   lda sharkFishCollisionValues     ; get shark / fish collision value
   and #4                           ; keep collision bit for eating fish
   beq CheckPlayerJoystickValues    ; branch if shark didn't eat fish
   lda #1
   sta sharkAteFishValue            ; set to show shark ate fish
   lda sharkStatus                  ; get shark status values
   eor #FISH_DIRECTION_MASK         ; flip shark direction value
   sta sharkStatus                  ; change shark direction
CheckPlayerJoystickValues
   lda frameCount                   ; get current frame count
   and #2
   ora gameState                    ; combine with current game state
   bne VerticalSync
   lda joystickValues,x             ; get player joystick values
   and #<(~MOVE_LEFT) >> 4          ; isolate MOVE_LEFT bit
   bne .checkForJoystickPushRight   ; branch if player not pushing left
   dec fishingPoleValues,x          ; reduce player fishing pole value
.checkForJoystickPushRight
   lda joystickValues,x             ; get player joystick values
   and #<(~MOVE_RIGHT) >> 4         ; isolate MOVE_RIGHT bit
   bne .determineFishingPoleBoundaries; branch if player not pushing right
   inc fishingPoleValues,x          ; increment player fishing pole value
.determineFishingPoleBoundaries
   lda fishingPoleValues,x
   cmp #MIN_FISHING_POLE_VALUE
   bcs .checkFishingPoleMaxValue
   lda #MIN_FISHING_POLE_VALUE
.checkFishingPoleMaxValue
   cmp #MAX_FISHING_POLE_VALUE + 1
   bcc .setPlayerFishingPoleValue
   lda #MAX_FISHING_POLE_VALUE
.setPlayerFishingPoleValue
   sta fishingPoleValues,x
   lda hookedFishIndex,x            ; get index of hooked fish
   bne VerticalSync                 ; branch if player hooked fish
   lda joystickValues,x             ; get player joystick values
   lsr                              ; shift MOVE_UP to carry
   bcs .checkForJoystickPushDown    ; branch if joystick not moving up
   dec fishingHookVertPos,x         ; move player fish hook up
.checkForJoystickPushDown
   lsr                              ; shift MOVE_DOWN to carry
   bcs .determineFishHookVertBoundaries
   inc fishingHookVertPos,x         ; move player fish hook down
.determineFishHookVertBoundaries
   lda fishingHookVertPos,x         ; get fishing hook vertical position
   bpl .checkFishHookLowerBoundary
   lda #MIN_FISH_HOOK_VERT
.checkFishHookLowerBoundary
   cmp #MAX_FISH_HOOK_VERT
   bcc .setPlayerFishHookVertPos
   lda #MAX_FISH_HOOK_VERT
.setPlayerFishHookVertPos
   sta fishingHookVertPos,x
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | DISABLE_TIA | START_VERT_SYNC
   sty WSYNC

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

   sty VBLANK                       ; disable TIA (D1 = 1)

   ENDIF

   sty VSYNC                        ; start vertical sync
   sty WSYNC
   sty WSYNC
   sty WSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   inc frameCount                   ; increment frame count
   bne DetermineTVMode
   inc colorCycleMode
   bne DetermineTVMode
   sec                              ; set carry
   ror colorCycleMode               ; rotate carry to set D7 = 1
DetermineTVMode
   ldy #$FF                         ; assume color mode
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   bne .colorMode                   ; branch if set to color
   ldy #$0F                         ; hue mask for B/W mode
.colorMode
   tya                              ; move hue masking value to accumulator
   ldy #0
   bit colorCycleMode
   bpl .setColorHueMask             ; branch if not in color cycling mode
   and #$F7                         ; mask for VCS colors (i.e. D0 not used)
   ldy colorCycleMode
.setColorHueMask
   sty screenSaverColorEOR
   sta hueMask
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blanking period
   ldy #$FF                         ; assume AMATEUR setting
   lda SWCHB                        ; read console switches
   and DifficultySwitchMask,x       ; mask difficulty settings
   bne .setFishingHookSkillMask
   ldy #$FC                         ; mask setting for EXPERT
.setFishingHookSkillMask
   sty fishingHookSkillMask,x
   lda SWCHA                        ; read joystick values
   tay                              ; move value to y register
   and #P1_HORIZ_MOVE
   sta player2JoystickValue         ; set player 2 joystick value
   tya                              ; shift joystick value to accumulator
   and #P1_VERT_MOVE
   asl
   cmp #$0F
   bcc .setPlayer2JoystickValues
   ora #<~(MOVE_LEFT) >> 4
.setPlayer2JoystickValues
   and #P1_VERT_MOVE
   ora player2JoystickValue
   sta player2JoystickValue
   tya                              ; shift joystick value to accumulator
   lsr                              ; shift player 1 values to lower nybbles
   lsr
   lsr
   lsr
   sta player1JoystickValue         ; set player 1 joystick value
   iny                              ; increment joystick value
   beq .checkForResetPressed        ; branch if neither joystick moved
   stx colorCycleMode
.checkForResetPressed
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForSelectPressed
   ldx #<colorCycleMode
   jmp RestartGame
   
.checkForSelectPressed
   ldy #0
   lsr                              ; shift SELECT to carry
   bcs .setSelectDebounceRate       ; branch if SELECT not pressed
   lda selectDebounce               ; get select debounce value
   beq .incrementGameSelection      ; increment game selection if zero
   dec selectDebounce               ; decrement select debounce rate
   bpl .doneSetGameSelection
.incrementGameSelection
   inc gameSelection
SetGameSelection
   lda gameSelection                ; get current game selection
   and #1
   sta gameSelection
   sta colorCycleMode
   ora #BLANK_NUMBER_PTR << 4       ; combine with Blank character
   tay                              ; move game selection to y register
   iny                              ; increment to show game 1 or 2
   sty player1Score                 ; set game selection for display purposes
   lda #BLANK_NUMBER_PTR << 4 | BLANK_NUMBER_PTR
   sta player2Score                 ; set player 2 score to Blank character
   ldy #30
   sty gameState                    ; set to non zero for game not in progress
.setSelectDebounceRate
   sty selectDebounce
.doneSetGameSelection
   lda gameState                    ; get current game state
   beq CheckToDeterminePlayer2AI    ; branch if game in progress
   jmp SetFloatingFishNUSIZPtrs
       
CheckToDeterminePlayer2AI
   txa                              ; move active player number to accumulator
   bne CheckToMoveHookedFish        ; branch if checking player 2 this frame
   lda gameSelection                ; get current game selection
   bne CheckToMoveHookedFish        ; branch if TWO_PLAYER game

   IF COMPILE_REGION = PAL50

   tay                              ; y = 0

   ELSE

   ldy #0

   ENDIF

.determinePossibleFishToHook
   lda floatingFishHorizPos,y       ; get floating fish horizontal position
   cmp #XMAX / 2
   bcs .determineAllowedVerticalMotion; branch if floating fish on right side
   iny                              ; increment to check next fish
   cpy #6
   bcc .determinePossibleFishToHook ; branch if not ID_SHARK
   ldy #1
.determineAllowedVerticalMotion
   lda rightFishingHookVertPos      ; get right fishing hook vertical position
   cmp HookedFishingHookVertPosValues,y
   ldy #<(MOVE_DOWN) >> 4
   bcc .setAllowedVerticalMotion
   ldy #<(MOVE_UP) >> 4
.setAllowedVerticalMotion
   sty tmpCPUPlayerAllowedMotion
   lda frameCount                   ; get current frame count
   ora #~P1_VERT_MOVE << 4          ; set so HORIZ_MOVE not possible
   lsr
   lsr
   lsr
   lsr
   and tmpCPUPlayerAllowedMotion
   ldy rightHookedFishIndex         ; get player 2 hooked fish value
   beq .setCPUOpponentJoystickValue ; branch if player 2 didn't hook fish
   lda #<(MOVE_LEFT) >> 4
.setCPUOpponentJoystickValue
   sta player2JoystickValue
CheckToMoveHookedFish
   ldy hookedFishIndex,x            ; get index of hooked fish
   beq MovePlayerFishingHook        ; branch if player didn't hook fish
   lda floatingFishStatus - 1,y     ; get hooked fish status value
   and #FISH_DIRECTION_MASK         ; keep direction value
   eor #FISH_DIRECTION_MASK         ; flip direction value
   clc
   adc floatingFishHorizPos - 1,y   ; adjust with fish horizontal position
   sta fishingHookHorizPos,x        ; set hooked fish horizontal position
   jmp DetermineFishingLineValues
       
MovePlayerFishingHook
   lda playerFishingLineHorizPos,x  ; get fishing line horizontal position
   cmp fishingHookHorizPos,x
   beq DetermineFishingLineValues
   bcc .moveFishingHookLeft
   inc fishingHookHorizPos,x
   inc fishingHookHorizPos,x
.moveFishingHookLeft
   dec fishingHookHorizPos,x
DetermineFishingLineValues
   ldy #HMOVE_L1
   lda playerFishingLineHorizPos,x  ; get fishing line horizontal position
   sec
   sbc fishingHookHorizPos,x        ; subtract fishing hook horizontal position
   sta fishingHookHorizLineDiff     ; set distance value
   bpl .setFishingLineHMOVEValue    ; branch if hook to the left of line
   ldy #HMOVE_R1
   eor #$FF
   clc                              ; could save a byte with adc #1...carry set
   adc #2
.setFishingLineHMOVEValue
   sty fishingLineHMOVEValues,x
   sta tmpFishingLineHookDistance
   sta fishingLineHookHorizDistance,x
   clc
   lda fishingHookVertPos,x         ; get fishing hook vertical position
   adc #H_FISHERMAN_BODY + 1        ; increase by kernel height for true depth
   sta tmpFishingHookVertDistance
   sta fishingHookVertDistance,x
   lda #0
   sta fishingLineSlopeFractionValues,x; clear fishing line slope value
   asl tmpFishingLineHookDistance   ; multiple distance by 2
   ldy #$80
.determineFishingLineSlope
   sec
   lda tmpFishingLineHookDistance   ; distance * 2
   sbc tmpFishingHookVertDistance   ; 2a - b
   bmi .checkToSetNextBit           ; branch when the result is negative
   sta tmpHorizDistRiseDiff         ; not utilized for this routine
   tya
   ora fishingLineSlopeFractionValues,x
   sta fishingLineSlopeFractionValues,x
.checkToSetNextBit
   asl tmpHorizDistRiseDiff
   tya
   lsr
   tay
   bne .determineFishingLineSlope
   ldy hookedFishIndex,x            ; get index of hooked fish
   beq CheckForHookedFish           ; branch if player didn't hook fish
   lda fishingHookVertDistance,x
   sec
   sbc fishingLineHookHorizDistance,x
   cmp #16
   bpl CheckForHookedFish
   lda fishingHookHorizLineDiff     ; get fishing hook and line difference
   and #$80                         ; keep D7 value (i.e. negative value)
   lsr
   lsr
   lsr
   lsr
   sta tmpHookedFishDir             ; set for new direction of hooked fish
   lda floatingFishStatus - 1,y     ; get hooked fish status value
   and #~FISH_DIRECTION_MASK        ; clear FISH_DIRECTION_MASK value
   ora tmpHookedFishDir
   sta floatingFishStatus - 1,y
CheckForHookedFish
   ldx playerHookedFishIndex        ; get player number for hooked fish
   ldy hookedFishIndex,x            ; get index of hooked fish
   dey
   lda sharkAteFishValue            ; get status of shark eating hooked fish
   beq CheckToReelInHookedFish      ; branch if shark didn't eat hooked fish
   lda #8
   sta audioChannelEatingFish       ; set audio value for shark eating fish
   lda #<Blank
   sta hookedFishLSBValues + 5
   sta hookedFishLSBValues + 6
   jmp .resetCaughtFishValues
       
CheckToReelInHookedFish
   lda leftHookedFishIndex          ; get player 1 hooked fish index
   ora rightHookedFishIndex         ; combine with player 2 hooked fish index
   beq SetFloatingFishHorizValues   ; branch if no player caught fish
   lda floatingFishHorizPos,y       ; get floating fish horizontal position
   sta hookedFishHorizPos
   lda hookedFishVertPos            ; get hooked fish vertical position
   beq RewardPlayerForCaughtFish    ; branch if fish not hooked
   lda INPT4,x                      ; read action button
   bpl .reelInHookedFish            ; branch if action button pressed
   txa                              ; move player number to accumulator
   beq .checkToReelInHookedFish     ; branch if processing left player
   lda gameSelection                ; get current game selection
   bne .checkToReelInHookedFish     ; branch if TWO_PLAYER game
   bit sharkHorizPos                ; check shark position for AI action button
   bvc .reelInHookedFish            ; branch if simulating AI action button
.checkToReelInHookedFish
   lda frameCount                   ; get current frame count
   and #3
   bne .setFloatingFishHorizValues
.reelInHookedFish
   dec hookedFishVertPos
   beq RewardPlayerForCaughtFish
   lda hookedFishVertPos            ; get hooked fish vertical position
   lsr                              ; divide value by 2
   bcs .setFloatingFishHorizValues  ; branch if on odd scanline
   and #7
   beq .setFloatingFishHorizValues
   dec fishingHookVertPos,x
.setFloatingFishHorizValues
   jmp SetFloatingFishHorizValues

RewardPlayerForCaughtFish 
   clc
   tya                              ; move caught fish index to accumulator
   eor #7                           ; flip D2 - D0 bits
   and #$FE

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

   clc                              ; not needed...carry cleared above

   ENDIF

   adc caughtFishWeight,x
   sta caughtFishWeight,x
.resetCaughtFishValues
   lda #0
   sta hookedFishIndex,x            ; set to show player not hooked fish
   sta sharkAteFishValue            ; set to show shark didn't eat caught fish
   sta hookedFishVertPos            ; clear hooked fish vertical position
   lda #<Blank
   sta hookedFishLSBValues + 6
   lda InitFishStatusValues,y
   sta floatingFishStatus,y         ; reset floating fish status
   lda InitFishHorizPos,y
   sta floatingFishHorizPos,y       ; reset floating fish horizontal position
   txa                              ; move index to accumulator
   eor #1                           ; flip D0 value
   tax                              ; set new index value
   ldy hookedFishIndex,x            ; get index of hooked fish
   beq SetFloatingFishHorizValues   ; branch if player didn't hook fish
   stx playerHookedFishIndex
   lda HookedFishKernelSectionVertPos - 1,y
   sta hookedFishVertPos            ; set hooked fish vertical position
SetFloatingFishHorizValues SUBROUTINE
   ldx #6
.setFloatingFishHorizValues
   lda floatingFishHorizPos,x       ; get floating fish horizontal position
   jsr CalculateObjectHorizPosition ; determine fish fine / coarse value
   sta floatingFishFineMotion,x     ; set fish fine motion value
   sty floatingFishCoarsePosition,x ; set fish coarse position value
   ldy #<[rightHookedFishIndex - leftHookedFishIndex]
.determineHookedFish
   lda hookedFishIndex,y            ; get index of hooked fish
   ora gameState                    ; combine with current game state
   bne .nextDetermineHookedFish     ; branch if not allowed to catch fish
   lda fishingHookVertPos,y         ; get fishing hook vertical position
   and fishingHookSkillMask,y       ; mask with difficulty setting
   sta tmpFishingHookVertPos
   lda HookedFishingHookVertPosValues,x
   and fishingHookSkillMask,y
   cmp tmpFishingHookVertPos
   bne .nextDetermineHookedFish
   lda floatingFishHorizPos,x       ; get floating fish horizontal position
   adc #3
   cmp fishingHookHorizPos,y
   bne .nextDetermineHookedFish
   lda floatingFishStatus,x         ; get floating fish status value
   bmi .nextDetermineHookedFish     ; branch if ID_SHARK
   lda floatingFishLSBValues,x      ; get floating fish LSB value
   cmp #<Blank
   beq .nextDetermineHookedFish     ; branch if fish not present
   inx
   stx hookedFishIndex,y            ; set to index of hooked fish
   dex
   lda HookedFishingHookVertPosValues,x
   sta fishingHookVertPos,y
   lda hookedFishVertPos            ; get hooked fish vertical position
   bne .setFloatingFishNewDirection ; branch if fish hooked
   lda HookedFishKernelSectionVertPos,x
   sta hookedFishVertPos            ; set hooked fish vertical position
   sty playerHookedFishIndex
   lda floatingFishHorizPos,x       ; get floating fish horizontal position
   sta hookedFishHorizPos           ; set hooked fish horizontal position
   lda #8
   sta AUDC0,y                      ; set audio channel for catching fish
.setFloatingFishNewDirection
   lda randomSeed                   ; get random seed value
   and #FISH_DIRECTION_MASK
   sta floatingFishStatus,x
.nextDetermineHookedFish
   dey
   bpl .determineHookedFish
   dex
   bpl .setFloatingFishHorizValues
   lda hookedFishHorizPos           ; get hooked fish horizontal position
   jsr CalculateObjectHorizPosition
   sta hookedFishFineMotion
   sty hookedFishCoarsePosition
   lda frameCount                   ; get current frame count
   bne SetFloatingFishNUSIZPtrs
   lda randomSeed                   ; get random seed value
   lsr                              ; divide value by 2
   and #$0F                         ; keep lower nybbles
   eor sharkStatus                  ; slip shark direction and movement delay
   sta sharkStatus                  ; set new direction and movement delay
SetFloatingFishNUSIZPtrs
   ldy #<SharkTravelingLeftNUSIZValues
   lda sharkStatus                  ; get shark status values
   and #FISH_DIRECTION_MASK         ; keep shark direction value
   bne .setFloatingFishNUSIZPtrs    ; branch if shark traveling left
   ldy #<SharkTravelingRightNUSIZValues
.setFloatingFishNUSIZPtrs
   sty floatingFishNUSIZPtrs
   jmp MainLoop

InitializeGame
   ldx #FISH_KERNEL_SECTIONS - 1
.initGameVariables
   lda InitFishHorizPos,x
   sta floatingFishHorizPos,x       ; set floating fish horizontal position
   lda InitFishStatusValues,x
   sta floatingFishStatus,x         ; set floating fish status
   lda #<FishSprite_01
   sta floatingFishLSBValues,x      ; set floating fish LSB value
   lda #<Blank
   sta sharkLSBValue                ; set shark LSB value
   sta hookedFishLSBValues,x        ; set hooked fish LSB value
   cpx #2
   bcs .initNextVariable
   lda #7
   sta fishingPoleValues,x          ; set fishing pole values
   sta AUDV0,x                      ; set sound volume level
   lda InitHookHorizPosition,x
   sta fishingHookHorizPos,x        ; set fishing hook horizontal position
   lda InitAudioFrequencyValues,x
   sta AUDF0,x                      ; set audio frequency values
.initNextVariable
   dex
   bpl .initGameVariables
   ldx #13
   lda #>NumberFonts
.setDigitMSBValues
   sta digitGraphicPtrs,x           ; all sprites on the same page
   dex
   dex
   bpl .setDigitMSBValues
   rts

MoveObjectHorizontally
   jsr PositionObjectHorizontally
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; move object horizontally
   rts

;
; Horizontal reset starts at cycle 8 (i.e. pixel 24). The object's position is
; incremented by 46 to push their pixel positioning to start at cycle 23 (i.e.
; pixel 69) with an fine adjustment of -6 to start objects at pixel 63.
;
CalculateObjectHorizPosition
   clc                              ; clear carry
   adc #46                          ; increment horizontal position value by 46
   tay                              ; save result for later
   and #$0F                         ; keep lower nybbles
   sta div16Remainder               ; keep div16 remainder
   tya
   lsr                              ; divide horizontal position by 16
   lsr
   lsr
   lsr
   tay                              ; division by 16 is course movement value
   clc
   adc div16Remainder               ; add back division by 16 remainder
   cmp #15
   bcc .determineFineMotionValue
   sbc #15
   iny                              ; increment course movement value
.determineFineMotionValue
   eor #7                           ; get 3-bit 1's complement for fine motion
   asl
Waste18Cycles
   asl
   asl
   asl
   rts

PositionObjectHorizontally
   jsr CalculateObjectHorizPosition
   sta HMP0,x                       ; set object's fine motion value
   sta WSYNC                        ; wait for next scan line
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; set object's coarse position
   rts

InitFishStatusValues
   .byte ID_FISH  | FISH_DIRECTION_LEFT  | 3
   .byte ID_FISH  | FISH_DIRECTION_RIGHT | 3
   .byte ID_FISH  | FISH_DIRECTION_LEFT  | 3
   .byte ID_FISH  | FISH_DIRECTION_RIGHT | 3
   .byte ID_FISH  | FISH_DIRECTION_LEFT  | 3
   .byte ID_FISH  | FISH_DIRECTION_RIGHT | 3
   .byte ID_SHARK | FISH_DIRECTION_RIGHT | 7

InitFishHorizPos
   .byte 132, 21, 132, 21, 132, 21, 21

HookedFishKernelSectionVertPos
   .byte H_FISH_KERNEL - (H_FISH * 0) - 1
   .byte H_FISH_KERNEL - (H_FISH * 1) - 1
   .byte H_FISH_KERNEL - (H_FISH * 2) - 1
   .byte H_FISH_KERNEL - (H_FISH * 3) - 1
   .byte H_FISH_KERNEL - (H_FISH * 4) - 1
   .byte H_FISH_KERNEL - (H_FISH * 5) - 1
   .byte H_FISH_KERNEL - (H_FISH * 6) + 1

Copyright_0
   .byte $00 ; |........|
   .byte $AD ; |X.X.XX.X|
   .byte $A9 ; |X.X.X..X|
   .byte $E9 ; |XXX.X..X|
   .byte $A9 ; |X.X.X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $41 ; |.X.....X|
   .byte $0F ; |....XXXX|
Copyright_1
   .byte $00 ; |........|
   .byte $50 ; |.X.X....|
   .byte $58 ; |.X.XX...|
   .byte $5C ; |.X.XXX..|
   .byte $56 ; |.X.X.XX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
Copyright_2
   .byte $00 ; |........|
   .byte $BA ; |X.XXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $3A ; |..XXX.X.|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
Copyright_3
   .byte $00 ; |........|
   .byte $E9 ; |XXX.X..X|
   .byte $AB ; |X.X.X.XX|
   .byte $AF ; |X.X.XXXX|
   .byte $AD ; |X.X.XX.X|
   .byte $E9 ; |XXX.X..X|
   .byte $00 ; |........|
   .byte $00 ; |........|

   BOUNDARY 0

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
   IF COMPILE_REGION = PAL50

   .byte $3C ; |..XXXX..|

   ELSE

   .byte $7E ; |.XXXXXX.|

   ENDIF

   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|

   IF COMPILE_REGION = PAL50

   .byte $18 ; |...XX...|

   ELSE

   .byte $78 ; |.XXXX...|

   ENDIF

   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
two
   .byte $7E ; |.XXXXXX.|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

FishSprite_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $4C ; |.X..XX..|
   .byte $5E ; |.X.XXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $3D ; |..XXXX.X|
   .byte $5E ; |.X.XXXX.|
   .byte $4C ; |.X..XX..|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

FishSprite_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $CC ; |XX..XX..|
   .byte $DE ; |XX.XXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $3D ; |..XXXX.X|
   .byte $DE ; |XX.XXXX.|
   .byte $CC ; |XX..XX..|
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

SharkSprite_01
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $45 ; |.X...X.X|
   .byte $5E ; |.X.XXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $F8 ; |XXXXX...|
   .byte $7C ; |.XXXXX..|
   .byte $F0 ; |XXXX....|
   .byte $80 ; |X.......|

FishermanHeadGraphics
   .byte $48 ; |.X..X...|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $70 ; |.XXX....|
   .byte $60 ; |.XX.....|
   .byte $F8 ; |XXXXX...|
   .byte $A0 ; |X.X.....|
   .byte $80 ; |X.......|

FishermanBodyGraphics
   .byte $66 ; |.XX..XX.|
   .byte $F4 ; |XXXX.X..|
   .byte $F4 ; |XXXX.X..|
   .byte $DC ; |XX.XXX..|
   .byte $CC ; |XX..XX..|
   .byte $C4 ; |XX...X..|
   .byte $E0 ; |XXX.....|
   .byte $D4 ; |XX.X.X..|

DifficultySwitchMask
   .byte P0_DIFF_MASK, P1_DIFF_MASK

SharkSprite_02
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $44 ; |.X...X..|
   .byte $5F ; |.X.XXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $5F ; |.X.XXXXX|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|

SharkTravelingLeftNUSIZValues
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_R8| MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_R1| MSBL_SIZE8 | QUAD_SIZE
   .byte HMOVE_R1| MSBL_SIZE8 | QUAD_SIZE
   .byte HMOVE_R4| MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_R1| MSBL_SIZE8 | QUAD_SIZE
   .byte HMOVE_R1| MSBL_SIZE8 | QUAD_SIZE
   .byte HMOVE_0 | MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_L5| MSBL_SIZE2 | QUAD_SIZE
   .byte HMOVE_L7| MSBL_SIZE8 | TWO_COPIES
   .byte HMOVE_L2| MSBL_SIZE4 | TWO_COPIES
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_R7| MSBL_SIZE2 | QUAD_SIZE

SharkTravelingRightNUSIZValues
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_R2| MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_L1| MSBL_SIZE2 | QUAD_SIZE
   .byte HMOVE_L1| MSBL_SIZE2 | QUAD_SIZE
   .byte HMOVE_L4| MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_L1| MSBL_SIZE2 | QUAD_SIZE
   .byte HMOVE_L1| MSBL_SIZE2 | QUAD_SIZE
   .byte HMOVE_0 | MSBL_SIZE1 | QUAD_SIZE
   .byte HMOVE_R5| MSBL_SIZE8 | QUAD_SIZE
   .byte HMOVE_L3| MSBL_SIZE8 | TWO_COPIES
   .byte HMOVE_R2| MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_0 | MSBL_SIZE1 | TWO_COPIES
   .byte HMOVE_R3| MSBL_SIZE2 | QUAD_SIZE

GameColors
   .byte COLOR_LEFT_FISHERMAN, COLOR_RIGHT_FISHERMAN, COLOR_PLATFORM
   .byte COLOR_SKY, COLOR_EOR, COLOR_SEA, COLOR_SHARK, COLOR_FISH

HookedFishingHookVertPosValues
   .byte 45, 38, 31, 24, 17, 10, 3

InitAudioFrequencyValues
   .byte 16, 18

   .org ROM_BASE + 2048 - 4, 0      ; 2K ROM
   .word Start
InitHookHorizPosition
   .byte 44, 116