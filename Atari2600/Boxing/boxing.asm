   LIST OFF
; ***  B O X I N G  ***
; Copyright 1980 Activision, Inc
; Designer: Bob Whitehead
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: July 24, 2020
;
;  *** 114 BYTES OF RAM USED 14 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; Though the assembler reports 14 bytes of RAM free, there are actually 16 more
; RAM bytes available because of how the RAM layout.
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1980, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================

   processor 6502

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
VBLANK_TIME             = 40
OVERSCAN_TIME           = 34

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 79
OVERSCAN_TIME           = 55
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC
   
LT_RED                  = $20
DK_GREEN                = $D0

COLOR_BOXING_RING       = LT_RED + 8

   ELSE

YELLOW                  = $20
DK_GREEN                = $50
   
COLOR_BOXING_RING       = YELLOW + 8

   ENDIF

COLOR_LEFT_BOXER        = BLACK + 12
COLOR_RIGHT_BOXER       = BLACK
COLOR_BACKGROUND        = DK_GREEN + 6

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

W_SCREEN                = 159

XMIN                    = 0
XMAX                    = 160

XMIN_BOXER              = 30
XMAX_BOXER              = 109

INIT_RIGHT_BOXER_X      = 119
INIT_RIGHT_BOXER_Y      = 112

YMIN                    = 3
YMAX                    = 87

H_KERNEL_SECTION        = 16
H_FONT                  = 7
H_BOXER                 = H_KERNEL_SECTION * 3

BW_HUE_MASK             = $06
COLOR_HUE_MASK          = $F6

GAME_OVER               = $FF

FRAME_ANIMATION_RATE    = 8

NUM_CHARACTERS          = 17        ; number of characters in character set

; Number fonts LSB values
ZERO_IDX_VALUE          = 0
ONE_IDX_VALUE           = 1
TWO_IDX_VALUE           = 2
THREE_IDX_VALUE         = 3
FOUR_IDX_VALUE          = 4
FIVE_IDX_VALUE          = 5
SIX_IDX_VALUE           = 6
SEVEN_IDX_VALUE         = 7
EIGHT_IDX_VALUE         = 8
NINE_IDX_VALUE          = 9
BLANK_IDX_VALUE         = 10
COLON_IDX_VALUE         = 11
K_IDX_VALUE             = 12
COPYRIGHT_0_IDX_VALUE   = 13
COPYRIGHT_1_IDX_VALUE   = 14
COPYRIGHT_2_IDX_VALUE   = 15
COPYRIGHT_3_IDX_VALUE   = 16

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
      
      IF {1} = 6
     .byte {7}
      ENDIF
      
      IF {1} = 7
     .byte {8}
      ENDIF
      
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
frameCount              ds 1
objectColorValues       ds 4
;--------------------------------------
leftBoxerColor          = objectColorValues
rightBoxerColor         = leftBoxerColor + 1
boxingRingColor         = rightBoxerColor + 1
copyrightColor          = boxingRingColor + 1
boxerBodySectionValue   ds 1
graphicPointers         ds 8
joystickValues          ds 2
;--------------------------------------
leftPlayerJoystickValues = joystickValues
rightPlayerJoystickValues = leftPlayerJoystickValues + 1
scoreBoardValues        ds 4
;--------------------------------------
clockMinutes            = scoreBoardValues
clockSeconds            = clockMinutes + 1
playerScores            = clockSeconds + 1
;--------------------------------------
leftBoxerScore          = playerScores
rightBoxerScore         = leftBoxerScore + 1
framesPerSecondCount    ds 1
rightAudioToneValue     ds 1
colorCycleMode          ds 1
gameState               ds 1
extendedArmMaximum      ds 8        ; 4 bytes not used ($99, $9B, $9D, $9F)
boxerHorizPositions     ds 2
;--------------------------------------
leftBoxerHorizPos       = boxerHorizPositions
rightBoxerHorizPos      = leftBoxerHorizPos + 1
boxerVertPositions      ds 2
;--------------------------------------
leftBoxerVertPos        = boxerVertPositions
rightBoxerVertPos       = leftBoxerVertPos + 1
leftBoxerGraphicPtr     ds 2
leftBoxerHMOVEPtr       ds 2
rightBoxerGraphicPtr    ds 2
rightBoxerHMOVEPtr      ds 2
tmpDirectionalValues    ds 1
;--------------------------------------
tmpXRegister            = tmpDirectionalValues
tmpHueMask              ds 1
;--------------------------------------
tmpHorizPosDiv16        = tmpHueMask
;--------------------------------------
tmpBoxerPosition        = tmpHorizPosDiv16
maximumPunchExtension   ds 1
actionButtonDelay       ds 8        ; 4 bytes not used ($B0, $B2, $B4, $B6)
boxerAnimationValues    ds 8
;--------------------------------------
leftBoxerAnimationValues = boxerAnimationValues
;--------------------------------------
leftBoxerFaceAnimationValue = leftBoxerAnimationValues
leftBoxerUpperArmAnimationValue = leftBoxerFaceAnimationValue + 1
leftBoxerLowerArmAnimationValue = leftBoxerUpperArmAnimationValue + 1
;--------------------------------------
rightBoxerAnimationValues = leftBoxerAnimationValues + 4
;--------------------------------------
rightBoxerFaceAnimationValue = rightBoxerAnimationValues
rightBoxerUpperArmAnimationValue = rightBoxerFaceAnimationValue + 1
rightBoxerLowerArmAnimationValue = rightBoxerUpperArmAnimationValue + 1
tmpLeftBoxerVertPos     ds 1
tmpRightBoxerVertPos    ds 1
boxerKernelSectionVertPos ds 8
;--------------------------------------
whiteBoxerKernelSectionVertPos = boxerKernelSectionVertPos
blackBoxerKernelSectionVertPos = whiteBoxerKernelSectionVertPos + 4
boxerGraphicLSBValues   ds 8
;---------------------------------------
whiteBoxerGraphicLSBValues = boxerGraphicLSBValues
blackBoxerGraphicLSBValues = whiteBoxerGraphicLSBValues + 4
hitBoxerStunTimer       ds 1
hitBoxerIndex           ds 1
punchingArmIndex        ds 1
boxerIndexFacingRight   ds 1
fontColor               ds 1
zp_Unused_01            ds 1
boxingRoundState        ds 1
selectDebounceRate      ds 1
gameSelection           ds 1
consoleSwitchValues     ds 1
cpuBoxerDancingValue    ds 1
rightAudioVolumeValue   ds 1
random                  ds 2
targetedCPUVertOffset   ds 1
targetedCPUHorizOffset  ds 1
targetedCPUBoxerHorizPos ds 1
targetedCPUBoxerVertPos ds 1
actionButtonValues      ds 8        ; 4 bytes not used ($E4, $E6, $E8, $EA)
actionButtonDebounceValues ds 8     ; 4 bytes not used ($EC, $EE, $F0, $F2)

   echo "***",(* - $80 - 1)d, "BYTES OF RAM USED", ($100 - * + 1)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG code
   .org ROM_BASE
   
Start
   sei                              ; disable interrupts
   cld                              ; clear decimal mode

   IF COMPILE_REGION = PAL50

   ldx #0
   txa                              ; a = 0
.clearLoop
   sta VSYNC,x
   txs                              ; set stack to the beginning when done
   inx
   bne .clearLoop

   ELSE

   ldx #$FF
   txs                              ; set stack to the beginning
   inx                              ; x = 0
   txa                              ; a = 0
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop

   ENDIF

   inc random                       ; seed random with 1
   jsr InitializeGameVariables
   jmp IncrementGameSelection

.drawLeftBoxer
   tay                        ; 2         move difference value to y register
   lda (leftBoxerGraphicPtr),y; 5         get left boxer graphic data
   sta GRP0                   ; 3 = @52   draw left boxer
   lda (leftBoxerHMOVEPtr),y  ; 5         get left boxer NUSIZ value
.setLeftBoxerHMOVEValue
   sta HMP0                   ; 3 = @60
   sec                        ; 2
   tay                        ; 2         move NUSIZ value to y register
   txa                        ; 2         move scan line to accumulator
   sbc tmpRightBoxerVertPos   ; 3         subtract right boxer vertical position
   cmp #H_KERNEL_SECTION      ; 2
   sty NUSIZ0                 ; 3 = @74   set left boxer NUSIZ value
;--------------------------------------
   sta HMOVE                  ; 3 = @01
   beq .setRightBoxerKernelValues;2³
   SLEEP 2                    ; 2
.checkToDrawRightBoxer
   bcs .skipRightBoxerDraw    ; 2³
   tay                        ; 2         move difference value to y register
   lda (rightBoxerGraphicPtr),y;5         get right boxer graphic data
   sta GRP1                   ; 3 = @17   draw right boxer
   lda (rightBoxerHMOVEPtr),y ; 5         get right boxer NUSIZ value
.setRightBoxerSizeValues
   sta NUSIZ1                 ; 3 = @25   set right boxer NUSIZ value
   sta HMP1                   ; 3 = @28   set right boxer HMOVE value
   sec                        ; 2
.nextBoxingRingScanline
   txa                        ; 2         move scan line to accumulator
   inx                        ; 2         increment scan line count
   sbc tmpLeftBoxerVertPos    ; 3         subtract left boxer vertical position
   cmp #H_KERNEL_SECTION      ; 2
   bcc .drawLeftBoxer         ; 2³
   bne .skipLeftBoxerDraw     ; 2³
   ldy boxerBodySectionValue  ; 3         get boxer body section value
   inc boxerBodySectionValue  ; 5         increment boxer body section value
   lda boxerKernelSectionVertPos + 1,y;4  get boxer section vertical position
   sta tmpLeftBoxerVertPos    ; 3         set left boxer vertical position
   lda boxerGraphicLSBValues + 1,y;4      get boxer graphic LSB value
   sta leftBoxerGraphicPtr    ; 3         set left boxer graphic pointer value
   sta leftBoxerHMOVEPtr      ; 3         set left boxer NUSIZ pointer value
   txa                        ; 2         move scan line to accumulator
   sbc tmpRightBoxerVertPos   ; 3         subtract right boxer vertical position
   cmp #H_KERNEL_SECTION      ; 2
;--------------------------------------
   sta HMOVE                  ; 3 = @02
   bne .checkToDrawRightBoxer ; 2³
.setRightBoxerKernelValues
   pla                        ; 4         pull right boxer vertical position
   sta tmpRightBoxerVertPos   ; 3         set right boxer vertical position
   pla                        ; 4         pull right boxer graphic LSB value
   sta rightBoxerGraphicPtr   ; 3         set right boxer graphic pointer value
   sta rightBoxerHMOVEPtr     ; 3         set right boxer NUSIZ pointer value
   and #$0F                   ; 2
   sta.w GRP1                 ; 4 = @27
   bcs .nextBoxingRingScanline; 3         unconditional branch

.skipLeftBoxerDraw
   lda #0                     ; 2
   sta GRP0                   ; 3 = @49
   sta GRP0                   ; 3 = @52
   SLEEP 2                    ; 2
   bpl .setLeftBoxerHMOVEValue; 3         unconditional branch

StartBoxingRingKernel
   ldx #0                     ; 2
   sta HMCLR                  ; 3 = @31
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   iny                        ; 2         y = 16
   sty PF1                    ; 3 = @08
.skipRightBoxerDraw
   lda #0                     ; 2
   cpx #140                   ; 2
   sta GRP1                   ; 3 = @15
   sta.w PF2                  ; 4 = @19
   bcc .setRightBoxerSizeValues;2³
   tax                        ; 2
   lda #69                    ; 2         horizontal position for GRP1
   ldy #44                    ; 2         horizontal position for GRP0
   jsr DrawInnerBoxingRingPosts;6         draw posts and position for copyright
   jsr DrawOuterBoxingRingPosts;6
;--------------------------------------
   stx PF1                    ; 3 = @40
   stx COLUPF                 ; 3 = @43
   stx VDELP0                 ; 3 = @46
   stx REFP0                  ; 3 = @49
   jsr SetPlayersToTwoCopies  ; 6
   jsr CharacterFontDisplayKernel;6
   lda #OVERSCAN_TIME

   IF COMPILE_REGION = PAL50

   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta TIM64T                       ; set timer for overscan time
   sta HMCLR
   lda #HMOVE_L2
   sta HMBL

   ELSE

   sta TIM64T                       ; set timer for overscan time

   ENDIF

   lda boxingRoundState             ; get boxing round state
   beq ReadJoystickValues           ; branch if round over
   dec framesPerSecondCount         ; decrement frames per second count
   bpl ReadJoystickValues           ; branch if not time to reduce timer
   lda #FPS - 1
   sta framesPerSecondCount         ; reset frames per second
   lda clockSeconds                 ; get clock seconds

   IF COMPILE_REGION != PAL50

   sec

   ENDIF

   sed
   sbc #1                           ; reduce clock seconds by 1
   cld
   bcs .setClockSeconds             ; branch if not time to reduce minutes
   lda clockMinutes                 ; get clock minutes value
   sbc #16 - 1                      ; subtract by 16 (i.e. carry clear)
   sta clockMinutes
   lda #$59                         ; reset clock seconds to 59
.setClockSeconds
   sta clockSeconds
   tay                              ; move clock seconds to y register
   bne ReadJoystickValues           ; branch if not zero
   ldy clockMinutes                 ; get clock minutes value
   cpy #ZERO_IDX_VALUE << 4 | COLON_IDX_VALUE
   bne ReadJoystickValues           ; branch if minutes left on the clock
   sta boxingRoundState             ; set to boxing round over
   lda #$40
   jsr SetRightAudioCircuitValues
ReadJoystickValues
   lda SWCHA                        ; get joystick values
   sta leftPlayerJoystickValues     ; set left player joystick value
   ldy gameSelection                ; get current game selection
   beq .setRightPlayerJoystickValues; branch if TWO_PLAYER
   lda leftBoxerScore               ; get left boxer score
   sed
   sbc #4
   cld
   cmp rightBoxerScore              ; set carry when right score <= (left score - 4)
   lda clockMinutes                 ; get clock minutes value
   eor #$14                         ; add 20 (i.e. same operation as ora)
   jsr DetermineCPUBoxerDirectionValues
.setRightPlayerJoystickValues
   asl
   asl
   asl
   asl
   sta rightPlayerJoystickValues    ; set right player joystick value
   ldx #<[copyrightColor - objectColorValues + 1]
NewFrame
.waitTime
   ldy INTIM
   bne .waitTime
   dey                              ; y = -1
   sta WSYNC                        ; wait for next scan line
   sty VSYNC                        ; start vertical sync (i.e. D1 = 1)

   IF COMPILE_REGION != PAL50

   sty VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta RESBL                        ; coarse position BALL to pixel 27
   sta HMCLR                        ; clear horizontal motion values

   ELSE

   sta RESBL                        ; coarse position BALL to pixel 18

   ENDIF

   sty ENABL                        ; enable BALL (i.e. D1 = 1)
   lda #MSBL_SIZE8 | PF_REFLECT
   sta CTRLPF
   inc frameCount                   ; increment frame count
   bne DetermineTVMode
   inc colorCycleMode               ; incremented ~ every 4.2 seconds
   bne DetermineTVMode
   sty gameState                    ; set to GAME_OVER
DetermineTVMode
   lda SWCHB                        ; read console switches
   sta consoleSwitchValues          ; save console switch values
   and #BW_MASK                     ; keep the B/W switch value
   bne .setObjectColorValues        ; branch if set to COLOR
   ldy #$0F
.setObjectColorValues
   tya                              ; move hue mask value to accumulator
   ldy gameState                    ; get current game state
   bpl .setColorHueMask             ; branch if GAME_ON
   and #$F7                         ; mask for VCS colors
.setColorHueMask
   sta tmpHueMask
.setObjectColors
   lda colorCycleMode
   and gameState                    ; mask for color cycling
   eor GameColorTable - 1,x         ; flip color bits for color cycling
   and tmpHueMask                   ; mask color values for COLOR / B&W mode
   sta objectColorValues - 1,x      ; set object color value
   sta COLUP0 - 1,x
   dex

   IF COMPILE_REGION = PAL50

   stx COLUPF                       ; set playfield color to BLACK (i.e. x = 0)
   bne .setObjectColors
   stx AUDC1
   lda #VBLANK_TIME

   ELSE

   bne .setObjectColors
   stx COLUPF                       ; set playfield color to BLACK (i.e. x = 0)
   stx AUDC1
   lda #VBLANK_TIME
   sta HMBL                         ; set BALL HMOVE value

   ENDIF

   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   stx VSYNC                        ; end vertical sync (i.e. D1 = 0)
   sta TIM64T                       ; set timer for vertical blanking period
   lda rightAudioToneValue          ; get right audio tone value
   beq .setMusicRegisterValues      ; branch if not playing sound
   dec rightAudioVolumeValue        ; decrement right audio volume value
   ldx rightAudioVolumeValue        ; get right audio volume value
   bne .setMusicRegisterValues
   stx rightAudioToneValue          ; set right audio tone to 0
.setMusicRegisterValues
   sta AUDC0
   txa                              ; move music volume value to accumulator
   lsr                              ; divide value by 2
   sta AUDV0
   lda consoleSwitchValues          ; get console switch values
   lsr                              ; shift RESET to carry
   bcs .checkSelectSwitch           ; branch if RESET not pressed
   jsr InitializeGameVariables
   sta boxingRoundState             ; set to non-zero (i.e. currently boxing)
.checkSelectSwitch
   lsr                              ; shift SELECT to carry
   bcs .setSelectDebounceTimer      ; branch if SELECT not pressed
   dec selectDebounceRate
   bpl DetermineToMoveBoxer
IncrementGameSelection
   ldy gameSelection                ; get current game selection
   iny                              ; increment game selection
   tya                              ; move game selection to accumulator
   and #1                           ; get mod2 value
   sta gameSelection                ; set game selection (i.e. 0 <= a <= 1)

   IF COMPILE_REGION != PAL50

   sta gameState

   ENDIF

   sta colorCycleMode
   sty leftBoxerScore               ; set to display game selection
   lsr                              ; a = 0
   sta gameState
   lda #BLANK_IDX_VALUE << 4 | BLANK_IDX_VALUE
   sta rightBoxerScore              ; set to show BLANK for right boxer score
   sta clockMinutes                 ; set to show BLANK for minutes
   sta clockSeconds                 ; set to show BLANK for seconds
   stx boxingRoundState             ; set to boxing round over
   ldx #29
.setSelectDebounceTimer
   stx selectDebounceRate
DetermineToMoveBoxer
   ldx #<[rightPlayerJoystickValues - joystickValues]
.determineToMoveBoxer
   txa                              ; move index to accumulator
   asl                              ; multiply index by 4
   asl
   tay
   asl consoleSwitchValues          ; shift difficulty setting to carry
   lda boxingRoundState             ; get boxing round state
   beq .setNotToMoveBoxer           ; branch if boxing round over
   txa                              ; move index to accumulator
   eor hitBoxerIndex                ; flip with index of hit boxer
   bne .checkForExtendedPunch       ; branch if not hit boxer
   lda hitBoxerStunTimer            ; get hit boxer stun timer value
   bne .setNotToMoveBoxer           ; branch if hit boxer stunned...no move
.checkForExtendedPunch
   lda boxerAnimationValues,y
   ora boxerAnimationValues + 2,y
   and #3 << 6
   bne .setNotToMoveBoxer           ; branch if punch extended
   ldy joystickValues,x             ; get player joystick values
   bcc .checkToMoveBoxer            ; branch if difficulty set to AMATEUR
   lda frameCount                   ; get current frame count
   lsr
   bcs .checkToMoveBoxer            ; branch on an odd frame
.setNotToMoveBoxer
   ldy #P0_NO_MOVE
.checkToMoveBoxer
   tya                              ; move directional values to accumulator
   ldy boxerHorizPositions,x        ; get boxer horizontal position
   sta tmpDirectionalValues
   jsr DetermineBoxerDirection
   jsr CheckBoxerHorizBoundary
   jsr CheckBoxerBoundary           ; ensure boxers not overlapping
   sty boxerHorizPositions,x        ; set boxer horizontal position
   stx boxerIndexFacingRight        ; set index for boxer facing right
   cpy rightBoxerHorizPos
   bcc .checkMoveBoxerVertical
   inc boxerIndexFacingRight        ; increment to right boxer facing right
.checkMoveBoxerVertical
   ldy boxerVertPositions,x         ; get boxer vertical position
   jsr DetermineBoxerDirection
   cpy #YMIN
   bcs .checkBoxerVertMax           ; branch if boxer within min limit
   ldy #YMIN                        ; set to place boxer at min limit
.checkBoxerVertMax
   cpy #YMAX + 1
   bcc .setBoxerVertPosition        ; branch if boxer within max limit
   ldy #YMAX                        ; set to place boxer at max limit
.setBoxerVertPosition
   sty boxerVertPositions,x
   jsr CheckBoxerBoundary
   sty boxerVertPositions,x
   dex
   bpl .determineToMoveBoxer
   jsr DetermineBoxerHorizontalDistances;get horizontal distance between boxers
   cmp #(8 * 3) + 2
   ldy #7 << 3                      ; assume maximum punch 2 animation frame
   bcs .incrementMaximumPunchExtension;branch if greater than QUAD_SIZE
   cmp #(8 * 2) + 2
   bcs .determinePunchExtensionForVertDistance;branch if greater than DOUBLE_SIZE
   ldy #5 << 3
.determinePunchExtensionForVertDistance
   jsr DetermineBoxerVerticalDistances;get vertical distance between boxers
   cmp #(H_KERNEL_SECTION / 2) - 1
   bcc .setMaximumPunchExtension
   cmp #(H_KERNEL_SECTION * 2) - 4
   bcc .incrementMaximumPunchExtension
   cmp #(H_KERNEL_SECTION * 3) - 1
   bcc .setMaximumPunchExtension
   ldy #7 << 3
.incrementMaximumPunchExtension
   tya                              ; move punch extension value to accumulator
   clc
   adc #2 << 3                      ; increment punch animation
   tay
.setMaximumPunchExtension
   sty maximumPunchExtension
   ldx #7
   nop                              ; not needed
.determineBoxerAnimationValues
   txa                              ; move index to accumulator
   lsr                              ; divide by 2 (i.e. shift D0 to carry)
   php                              ; push carry status to stack
   lsr                              ; divide index by 4
   tay                              ; 0 <= y <= 1
   plp                              ; pull index D0 value from stack
   bcs .setBoxerGraphicLSBValues    ; branch on odd index value
   lda leftBoxerVertPos             ; get left boxer vertical position
   lsr actionButtonDelay,x          ; shift action button delay
   bcs .determineExtendedArmMaximum ; branch if delaying action button
   sbc rightBoxerVertPos            ; subtract right boxer vertical position

   IF COMPILE_REGION = PAL50

   eor ComputeBoxerCollisionBoxes - 7,x;only used to flip D7 value

   ELSE

   eor GameColorTable + 1,x         ; only used to flip D7 value

   ENDIF

   ora actionButtonValues,x         ; combine with action button value
   asl                              ; shift action button value to carry
   lda #8
   bcc .incrementBoxerAnimationValue; branch if action button pressed
   lda hitBoxerStunTimer            ; get hit boxer stun timer value
   beq .setHitBoxerAnimationValue   ; branch if hit boxer not stunned
   lda #<-8                         ; set to reduce boxer animation value
   cpy hitBoxerIndex                ; check if processing hit boxer
   bne .incrementBoxerAnimationValue; branch if not processing hit boxer
.setHitBoxerAnimationValue
   lda #<-2
.incrementBoxerAnimationValue
   clc
   adc boxerAnimationValues,x
   bmi .checkToResetActionDebounceValue
   cmp extendedArmMaximum,x         ; compare with extended arm maximum value
   bcc .setBoxerAnimationValue      ; branch if not reached extended arm maximum
   beq .setBoxerAnimationValue      ; branch if reached maximum
.checkToResetActionDebounceValue
   lda boxerAnimationValues,x       ; get boxer animation values
   cmp extendedArmMaximum,x
   beq .resetActionDebounceValue    ; branch if reached maximum arm extension
   lsr                              ; shift D0 to carry
   lda boxerAnimationValues,x       ; get boxer animation values
   sbc #1
   clc                              ; set to not reached extended arm maximum
   bmi .setActionButtonDebounceValue; branch to set debounce to not pressed
.setBoxerAnimationValue
   sta boxerAnimationValues,x
   bcc .determineExtendedArmMaximum ; branch if not reached extended arm maximum
   lda actionButtonDebounceValues,x ; get action button debounce value
   bpl .setActionButtonDebounceValue; branch if action held last frame
   jsr CheckToScoreBoxerForPunch
.resetActionDebounceValue
   lda actionButtonValues,x         ; get action button value
.setActionButtonDebounceValue
   sta actionButtonDebounceValues,x
   jsr DetermineActionButtonValue
   sta actionButtonValues,x         ; set action button value
.determineExtendedArmMaximum
   lda extendedArmMaximum,x
   cmp maximumPunchExtension
   beq .setBoxerGraphicLSBValues
   bcs .setExtendedArmMaximum
   adc #8 + 9
.setExtendedArmMaximum
   adc #<-9
   cmp boxerAnimationValues,x
   beq .setBoxerGraphicLSBValues
   sta extendedArmMaximum,x
.setBoxerGraphicLSBValues
   lda boxerVertPositions,y         ; get boxer vertical position
   clc
   adc KernelSectionOffsetValues,x  ; increment by kernel section offset
   sta boxerKernelSectionVertPos,x  ; set boxer kernel offset
   lda boxerAnimationValues,x       ; get boxer animation values
   lsr                              ; divide value by 8
   lsr
   lsr
   tay
   lda BoxingAnimationOffsetValues,y
   clc
   adc BoxerGraphicLSBValues,x
   sta boxerGraphicLSBValues,x      ; set boxer graphic LSB value
   dex
   bpl .determineBoxerAnimationValues
   lda boxerIndexFacingRight        ; get index of right facing boxer
   asl                              ; multiply value by 4
   asl
   tax
   lda boxerKernelSectionVertPos,x  ; get right facing boxer vertical position
   sta tmpLeftBoxerVertPos          ; set left boxer vertical position
   lda boxerGraphicLSBValues,x      ; get right facing boxer graphic LSB value
   sta leftBoxerGraphicPtr          ; set left boxer graphic LSB value
   sta leftBoxerHMOVEPtr            ; set left boxer HMOVE LSB value
   stx boxerBodySectionValue        ; set left facing boxer index value
   txa                              ; move index value to accumulator
   eor #7                           ; get 3-bit 1's complement
   tax                              ; set to index of left facing boxer
   ldy #2
   lda #0
.placeRightBoxerKernelValuesToStack
   pha                              ; push right boxer graphic LSB to stack
   lda boxerKernelSectionVertPos,x  ; get left facing boxer vertical position
   pha                              ; push right boxer vertical offset to stack
   dex
   lda boxerGraphicLSBValues,x      ; get left facing boxer graphic LSB value
   dey
   bpl .placeRightBoxerKernelValuesToStack
   sta rightBoxerGraphicPtr         ; set right boxer graphic LSB value
   sta rightBoxerHMOVEPtr           ; set right boxer HMOVE LSB value
   lda boxerKernelSectionVertPos,x  ; get left facing boxer vertical offset value
   sta tmpRightBoxerVertPos         ; set right boxer vertical position
   lda cpuBoxerDancingValue
   beq .determinePunchedBoxerValues
   dec cpuBoxerDancingValue
.determinePunchedBoxerValues
   lda hitBoxerStunTimer            ; get hit boxer stun timer value
   beq DisplayKernel                ; branch if hit boxer not stunned
   lda hitBoxerIndex                ; get index of hit boxer
   tax                              ; set x register for position value index
   asl                              ; multiply value by 4
   asl
   tay                              ; set y register for body animation index
   lda #8
   dec hitBoxerStunTimer            ; decrement hit boxer stun timer value
   bne .setPunchedBoxerAnimationValues
   lda #0
.setPunchedBoxerAnimationValues
   sta leftBoxerUpperArmAnimationValue,y
   lda #5 << 3 | 1
   sta boxerAnimationValues,y
   sta leftBoxerLowerArmAnimationValue,y
   ldy punchingArmIndex             ; get index of punching arm
   lda PunchedBoxerOffsetValues,y   ; get punched boxer vertical offset value
   clc
   adc boxerVertPositions,x         ; adjust punched boxer vertical position
   sta boxerVertPositions,x         ; set punched boxer vertical position
   lda boxerIndexFacingRight        ; get index of right facing boxer
   cmp #1
   bcc .setPunchedBoxerHorizontalPosition;branch if left boxer facing right
   lda #$FF
.setPunchedBoxerHorizontalPosition
   eor PunchedBoxerOffsetValues + 1,y;get punched boxer horizontal offset value
   adc boxerHorizPositions,x        ; adjust punched boxer horizontal position
   tay
   jsr CheckBoxerHorizBoundary      ; ensure punched boxer stays in the ring
DisplayKernel SUBROUTINE
.waitTime
   ldx INTIM
   bne .waitTime
   stx WSYNC
;---------------------------------------
   stx VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   sta HMCLR                  ; 3 = @06   clear horizontal motion values
   ldx #MSBL_SIZE1 | TWO_WIDE_COPIES;2
   stx NUSIZ0                 ; 3 = @11
   stx NUSIZ1                 ; 3 = @14
   ldy #HMOVE_L6              ; 2
   lda leftBoxerColor         ; 3
ScoreBoardKernel
   sty HMP0                   ; 3
   sty HMP1                   ; 3
   sta fontColor              ; 3
   ldy #2                     ; 2
.scoreBoardKernel
   dex                        ; 2
   bmi .doneScoreBoardKernel  ; 2³
   jsr NewScanline            ; 6
;--------------------------------------
   lda scoreBoardValues,x     ; 4 = @13   get score board value
   and #$0F                   ; 2         keep ones value
   sta graphicPointers,y      ; 5         set graphic pointer for ones value
   lda scoreBoardValues,x     ; 4         get score board value
   lsr                        ; 2         shift tens value to lower nybble
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   bne .setGraphicPointerTensValue;2³     branch if not suppressing tens value
   cpx #<[playerScores - clockMinutes];2
   bcc .setGraphicPointerTensValue;2³     branch if drawing clock values
   lda #BLANK_IDX_VALUE       ; 2         set to suppress leading zero
.setGraphicPointerTensValue
   sta graphicPointers + 4,y  ; 5 
   jsr NewScanline            ; 6
;--------------------------------------
   dey                        ; 2 = @11
   dey                        ; 2
   bpl .scoreBoardKernel      ; 2³
   jsr CharacterFontDisplayKernel;6
;--------------------------------------
   ldy #HMOVE_R6              ; 2 = @13
   lda copyrightColor         ; 3         get copyright color value
   eor #6                     ; 2
   bcs ScoreBoardKernel       ; 3         unconditional branch

.doneScoreBoardKernel
   jsr DrawOuterBoxingRingPosts;6
;--------------------------------------
   ldx boxerIndexFacingRight  ; 3 = @40   get index of right facing boxer
   lda rightBoxerHorizPos     ; 3
   ldy leftBoxerHorizPos      ; 3
   jsr DrawInnerBoxingRingPosts;6
;--------------------------------------
   sty REFP0                  ; 3 = @12   reflect GRP0 (i.e. D3 = 1)
   ldy #$0F                   ; 2        
   sty AUDF1                  ; 3        
   sty AUDV1                  ; 3        
   sty VDELP0                 ; 3 = @23
   jmp StartBoxingRingKernel  ; 3

DrawInnerBoxingRingPosts
   jsr NewScanline            ; 6
;--------------------------------------
   pha                        ; 3 = @12   push horizontal position to stack
   tya                        ; 2
   ldy #$3F                   ; 2
   sty PF1                    ; 3 = @19
   ldy #$FF                   ; 2
   sty PF2                    ; 3 = @24
   jsr NewScanline            ; 6
;--------------------------------------
   ldy leftBoxerColor         ; 3 = @12
   jsr PositionObjectHorizontally;6
   txa                        ; 2
   eor #1                     ; 2
   tax                        ; 2
   ldy rightBoxerColor        ; 3
   pla                        ; 4
   jmp PositionObjectHorizontally;3

CharacterFontDisplayKernel
   sec                        ; 2
   lda #<[CharacterSet + (H_FONT * NUM_CHARACTERS)];2
.characterFontDisplayKernel
   sta WSYNC
;--------------------------------------
   sbc #NUM_CHARACTERS        ; 2
   tay                        ; 2
   lda (graphicPointers + 4),y; 5
   sta GRP0                   ; 3 = @12
   lda fontColor              ; 3
   sta COLUP0                 ; 3 = @18
   sta COLUP1                 ; 3 = @21
   lda (graphicPointers),y    ; 5
   sta GRP1                   ; 3 = @29
   lda (graphicPointers + 6),y; 5
   stx tmpXRegister           ; 3
   tax                        ; 2
   lda (graphicPointers + 2),y; 5
   stx GRP0                   ; 3 = @47
   sta GRP1                   ; 3 = @50
   lda rightBoxerColor        ; 3
   sta COLUP0                 ; 3 = @56
   sta COLUP1                 ; 3 = @59
   ldx tmpXRegister           ; 3
   tya                        ; 2
   bne .characterFontDisplayKernel;2³
   sta GRP0                   ; 3 = @69
   sta GRP1                   ; 3 = @72
SetPlayersToTwoCopies
   iny                        ; 2         y = 1 (i.e. TWO_COPIES)
;--------------------------------------
   sty NUSIZ0                 ; 3 = @01
   sty NUSIZ1                 ; 3 = @04
   rts                        ; 6

DetermineBoxerDirection
   asl tmpDirectionalValues         ; shift current directional value to carry
   sty tmpBoxerPosition             ; save current positional value
   bcs .checkToDecrementPositionalValue
   iny                              ; increment positional value
.checkToDecrementPositionalValue
   asl tmpDirectionalValues         ; shift current directional value to carry
   bcs .doneDetermineBoxerDirection
   dey                              ; decrement positional value
.doneDetermineBoxerDirection
   rts

InitializeGameVariables
   ldx #20
   ldy #9
   sty AUDF0
.initGameVariables
   lda #0
   sta clockSeconds,y
   sta extendedArmMaximum - 2,x
   txa                              ; move x index to accumulator
   sta boxerHorizPositions - 2,x
   lda #>CharacterSet
   sta graphicPointers - 1,x
   lda GameInitTable,y
   sta rightBoxerHorizPos - 2,x
   dex
   dex
   dey
   bpl .initGameVariables
   lda #TWO_IDX_VALUE << 4 | COLON_IDX_VALUE
   sta clockMinutes                 ; set clock to two minutes
   rts

SetRightAudioCircuitValues
   sta rightAudioVolumeValue        ; set right audio volume value
   lsr                              ; divide by 2
   eor #$0C
   and #$0C                         ; a = 8 || a = 12
   sta rightAudioToneValue          ; set right audio tone value
   rts

CheckBoxerBoundary
   jsr DetermineBoxerVerticalDistances
   bcs .doneCheckBoxerBoundary      ; branch if not within vertical range
   jsr DetermineBoxerHorizontalDistances
   bcs .doneCheckBoxerBoundary      ; branch if not within horizontal range
   ldy tmpBoxerPosition
.doneCheckBoxerBoundary
   rts

   BOUNDARY 0

CharacterSet

FONT_BYTE_IDX SET 1

   REPEAT H_FONT

      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $3C, $66, $66, $66, $66, $66, $3C
                                       ; |..XXXX..|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |..XXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $7E, $18, $18, $18, $18, $78, $38
                                       ; |.XXXXXX.|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |.XXXX...|
                                       ; |..XXX...|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $7E, $60, $60, $3C, $06, $46, $7C
                                       ; |.XXXXXX.|
                                       ; |.XX.....|
                                       ; |.XX.....|
                                       ; |..XXXX..|
                                       ; |.....XX.|
                                       ; |.X...XX.|
                                       ; |.XXXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $3C, $46, $06, $0C, $06, $46, $3C
                                       ; |..XXXX..|
                                       ; |.X...XX.|
                                       ; |.....XX.|
                                       ; |....XX..|
                                       ; |.....XX.|
                                       ; |.X...XX.|
                                       ; |..XXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $0C, $0C, $7E, $4C, $2C, $1C, $0C
                                       ; |....XX..|
                                       ; |....XX..|
                                       ; |.XXXXXX.|
                                       ; |.X..XX..|
                                       ; |..X.XX..|
                                       ; |...XXX..|
                                       ; |....XX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $7C, $46, $06, $7C, $60, $60, $7E
                                       ; |.XXXXX..|
                                       ; |.X...XX.|
                                       ; |.....XX.|
                                       ; |.XXXXX..|
                                       ; |.XX.....|
                                       ; |.XX.....|
                                       ; |.XXXXXX.|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $3C, $66, $66, $7C, $60, $62, $3C
                                       ; |..XXXX..|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |.XXXXX..|
                                       ; |.XX.....|
                                       ; |.XX...X.|
                                       ; |..XXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $18, $18, $18, $0C, $06, $42, $7E
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |....XX..|
                                       ; |.....XX.|
                                       ; |.X....X.|
                                       ; |.XXXXXX.|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $3C, $66, $66, $3C, $66, $66, $3C
                                       ; |..XXXX..|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |..XXXX..|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |..XXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $3C, $46, $06, $3E, $66, $66, $3C
                                       ; |..XXXX..|
                                       ; |.X...XX.|
                                       ; |.....XX.|
                                       ; |..XXXXX.|
                                       ; |.XX..XX.|
                                       ; |.XX..XX.|
                                       ; |..XXXX..|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $00, $00, $00, $00, $00, $00, $00
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
                                       ; |........|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $00, $18, $18, $00, $18, $18, $00
                                       ; |........|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |........|
                                       ; |...XX...|
                                       ; |...XX...|
                                       ; |........|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $C6, $CC, $D8, $F0, $D8, $CC, $C6
                                       ; |XX...XX.|
                                       ; |XX..XX..|
                                       ; |XX.XX...|
                                       ; |XXXX....|
                                       ; |XX.XX...|
                                       ; |XX..XX..|
                                       ; |XX...XX.|
                                       
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $AD, $A9, $E9, $A9, $ED, $41, $0F
                                       ; |X.X.XX.X|
                                       ; |X.X.X..X|
                                       ; |XXX.X..X|
                                       ; |X.X.X..X|
                                       ; |XXX.XX.X|
                                       ; |.X.....X|
                                       ; |....XXXX|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $50, $58, $5C, $56, $53, $11, $F0      
                                       ; |.X.X....|
                                       ; |.X.XX...|
                                       ; |.X.XXX..|
                                       ; |.X.X.XX.|
                                       ; |.X.X..XX|
                                       ; |...X...X|
                                       ; |XXXX....|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $BA, $8A, $BA, $A2, $3A, $80, $FE
                                       ; |X.XXX.X.|
                                       ; |X...X.X.|
                                       ; |X.XXX.X.|
                                       ; |X.X...X.|
                                       ; |..XXX.X.|
                                       ; |X.......|
                                       ; |XXXXXXX.|
      INTERLEAVED_GRAPHICS FONT_BYTE_IDX, $E9, $AB, $AF, $AD, $E9, $00, $00
                                       ; |XXX.X..X|
                                       ; |X.X.X.XX|
                                       ; |X.X.XXXX|
                                       ; |X.X.XX.X|
                                       ; |XXX.X..X|
                                       ; |........|
                                       ; |........|

FONT_BYTE_IDX SET FONT_BYTE_IDX + 1

   REPEND

ComputeBoxerCollisionBoxes
   jsr DetermineBoxerHorizontalDistances
   cmp #(8 * 3) + 5
   bcs .doneComputeBoxerCollisionBoxes
DetermineBoxerVerticalDistances
   sec
   lda leftBoxerVertPos             ; get left boxer vertical position
   sbc rightBoxerVertPos            ; subtract right boxer vertical position
   bcs .compareVerticalDistance     ; branch if left boxer below right boxer
   eor #$FF                         ; get vertical distance absolute value
   adc #1
.compareVerticalDistance
   cmp #H_BOXER
.doneComputeBoxerCollisionBoxes
   rts

DetermineBoxerHorizontalDistances
   sec
   lda leftBoxerHorizPos            ; get left boxer horizontal position
   sbc rightBoxerHorizPos           ; subtract right boxer horizontal position
   bcs .compareHorizontalDistance   ; branch if left boxer left of right boxer
   eor #$FF                         ; get horizontal distance absolute value
   adc #1
.compareHorizontalDistance
   cmp #(8 * 2) - 2
   rts

CheckBoxerHorizBoundary
   cpy #XMIN_BOXER
   bcs .checkBoxerHorizMax          ; branch if boxer within left limit
   ldy #XMIN_BOXER                  ; set to place boxer at left limit
.checkBoxerHorizMax
   cpy #XMAX_BOXER + 1     
   bcc .setBoxerHorizPosition       ; branch if boxer within right limit
   ldy #XMAX_BOXER                  ; set to place boxer at right limit
.setBoxerHorizPosition
   sty boxerHorizPositions,x
   rts

CheckToScoreBoxerForPunch
   jsr ComputeBoxerCollisionBoxes
   bcs .doneCheckToScoreBoxerForPunch;branch if boxer not in punching range
   adc #<-11                        ; subtract 11 from vertical distance
   cmp #18
   lda hitBoxerStunTimer            ; get hit boxer stun timer value
   bne .doneCheckToScoreBoxerForPunch;branch if hit boxer stunned
   lda boxingRoundState             ; get boxing round state
   beq .doneCheckToScoreBoxerForPunch;branch if boxing round over
   lda #3
   sta actionButtonDelay,x          ; set action button delay for 2 frames
   lda #15
   sta AUDC1                        ; set audio channel for punch
   bcs .doneCheckToScoreBoxerForPunch
   sta hitBoxerStunTimer            ; set stunned boxer timer value
   stx punchingArmIndex             ; set index for punching arm
   lda #57
   sta cpuBoxerDancingValue
   cmp extendedArmMaximum,x         ; set carry if boxer close
   lda playerScores,y               ; get player score value
   sed
   adc #1                           ; increment player score for punch
   cld 
   bcc .setPlayerScoreValue         ; branch if score not reached 100 (i.e. KO)
   lda #K_IDX_VALUE << 4 | ZERO_IDX_VALUE;set to show "KO" in player score
.setPlayerScoreValue
   sta playerScores,y
   lda #$0F
   bcc .setRightAudioCircuitValues  ; branch if score not reached 100 (i.e. KO)
   lda #0
   sta boxingRoundState             ; set to boxing round over
   lda #$40
.setRightAudioCircuitValues
   jsr SetRightAudioCircuitValues
   tya                              ; move player index to accumulator
   eor #1                           ; flip player index
   sta hitBoxerIndex
.readActionButton
   lda INPT4,y                      ; read action button
.doneCheckToScoreBoxerForPunch
   rts

DetermineActionButtonValue
   lda boxingRoundState             ; get boxing round state
   beq .simulateCPUActionButtonNotPressed;branch if boxing round over
   tya                              ; shift boxer index value to accumulator
   and gameSelection
   beq .readActionButton            ; read player action button value
   lda random
   and #$1F                         ; 0 <= a <= 31
   beq .checkForAggressiveCPUForLowerScore
   lda cpuBoxerDancingValue
   beq .determineCPUBoxerVertRangeForPunch
   lda hitBoxerIndex
   bne .determineCPUBoxerVertRangeForPunch;branch if Black Boxer hit
   lda leftBoxerHorizPos            ; get left boxer horizontal position
   sec
   sbc #(8 * 5)
   cmp #(XMAX / 2)
   bcs .checkForAggressiveCPUForLowerScore;branch if left boxer on right side
.determineCPUBoxerVertRangeForPunch
   jsr ComputeBoxerCollisionBoxes
   bcs .setCPUBoxerActionButtonValue; branch for CPU boxer not to punch
   adc #<-11                        ; subtract 11 from vertical distance
   cmp #21
   bcs .setCPUBoxerActionButtonValue; branch for CPU boxer not to punch
.checkForAggressiveCPUForLowerScore
   lda rightBoxerScore              ; get right boxer score
   cmp leftBoxerScore               ; compare with left boxer score
   lda clockMinutes                 ; get clock minutes value
   eor #$13                         ; 17 <= a <= 19
   bit SWCHB                        ; check right player difficulty setting
   bpl .checkForLessAggressiveCPUBoxer;branch if right player set to AMATEUR
   ora #$24                         ; 53 <= a <= 55
.checkForLessAggressiveCPUBoxer
   bcc .determineCPUBoxerActionButtonValue;branch if CPU boxer score lower
   ora #$0B                         ; simulate less punching for CPU boxer
.determineCPUBoxerActionButtonValue
   and random + 1
   bne .simulateCPUActionButtonNotPressed
   clc                              ; simulate CPU action button pressed
   lda actionButtonDebounceValues,x
   bmi .setCPUBoxerActionButtonValue; branch for CPU boxer to punch
.simulateCPUActionButtonNotPressed
   sec
.setCPUBoxerActionButtonValue
   ror                              ; set simulated action button value
   rts

BoxingAnimationOffsetValues
   .byte 0 * H_KERNEL_SECTION
   .byte 1 * H_KERNEL_SECTION
   .byte 1 * H_KERNEL_SECTION
   .byte 1 * H_KERNEL_SECTION
   .byte 0 * H_KERNEL_SECTION
   .byte 0 * H_KERNEL_SECTION
   .byte 2 * H_KERNEL_SECTION
   .byte 2 * H_KERNEL_SECTION
   .byte 3 * H_KERNEL_SECTION
   .byte 3 * H_KERNEL_SECTION

CopyrightLSBValues
   .byte COPYRIGHT_1_IDX_VALUE
   .byte 0                          ; not used
   .byte COPYRIGHT_3_IDX_VALUE
   .byte 0                          ; not used
   .byte COPYRIGHT_0_IDX_VALUE
   .byte 0                          ; not used
   .byte COPYRIGHT_2_IDX_VALUE
   
GameColorTable
    .byte COLOR_LEFT_BOXER, COLOR_RIGHT_BOXER
    .byte COLOR_BOXING_RING, COLOR_BACKGROUND

BoxerGraphicLSBValues
    .byte <BoxerUpperArmGraphics, <BoxerBodyGraphics, <BoxerLowerArmGraphics, 0
    .byte <BoxerUpperArmGraphics, <BoxerBodyGraphics, <BoxerLowerArmGraphics;, 0
;
; last byte shared with table below
;
    
KernelSectionOffsetValues
   .byte 0 * (H_KERNEL_SECTION + 1)
   .byte 1 * (H_KERNEL_SECTION + 1)
   .byte 2 * (H_KERNEL_SECTION + 1)
   .byte 0 * (H_KERNEL_SECTION + 1)
   .byte 0 * (H_KERNEL_SECTION + 1)
   .byte 1 * (H_KERNEL_SECTION + 1)
   .byte 2 * (H_KERNEL_SECTION + 1)
;   .byte 0 * (H_KERNEL_SECTION + 1)
;
; last byte shared with table below
;
BoxerGraphics
BoxerUpperArmGraphics
BoxerUpperArmGraphics_01
   .byte $00 ; |........|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3B ; |..XXX.XX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7B ; |.XXXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $3B ; |..XXX.XX|
   .byte $3B ; |..XXX.XX|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
BoxerUpperArmGraphics_02
   .byte $00 ; |........|
   .byte $0F ; |....XXXX|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $3D ; |..XXXX.X|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3A ; |..XXX.X.|
   .byte $3E ; |..XXXXX.|
   .byte $F7 ; |XXXX.XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
BoxerUpperArmGraphics_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $C3 ; |XX....XX|
   .byte $18 ; |...XX...|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
BoxerUpperArmGraphics_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $78 ; |.XXXX...|
   .byte $1E ; |...XXXX.|
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $9C ; |X..XXX..|
   .byte $1F ; |...XXXXX|
   .byte $3C ; |..XXXX..|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
BoxerBodyGraphics
BoxerBodyGraphics_01
   .byte $0E ; |....XXX.|
   .byte $1E ; |...XXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $1E ; |...XXXX.|
   .byte $0E ; |....XXX.|
   .byte $0F ; |....XXXX|
BoxerBodyGraphics_02
   .byte $0F ; |....XXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
BoxerLowerArmGraphics
BoxerLowerArmGraphics_01
   .byte $0F ; |....XXXX|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $3B ; |..XXX.XX|
   .byte $3B ; |..XXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $7B ; |.XXXX.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3B ; |..XXX.XX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
BoxerLowerArmGraphics_02
   .byte $0F ; |....XXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $F7 ; |XXXX.XXX|
   .byte $3E ; |..XXXXX.|
   .byte $3A ; |..XXX.X.|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3D ; |..XXXX.X|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
BoxerLowerArmGraphics_03
   .byte $0F ; |....XXXX|
   .byte $18 ; |...XX...|
   .byte $C3 ; |XX....XX|
   .byte $E3 ; |XXX...XX|
   .byte $E3 ; |XXX...XX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BoxerLowerArmGraphics_04
   .byte $0F ; |....XXXX|
   .byte $3C ; |..XXXX..|
   .byte $1F ; |...XXXXX|
   .byte $9C ; |X..XXX..|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|
   .byte $3C ; |..XXXX..|
   .byte $FC ; |XXXXXX..|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

PositionObjectHorizontally
   sty COLUP0,x               ; 4
   clc                        ; 2
   adc BoxerHorizOffsetValues,x;4         increment horizontal position
   tay                        ; 2         move adjusted position to y register
   and #$0F                   ; 2         keep div16 remainder
   sta tmpHorizPosDiv16       ; 3         division by 16 is coarse movement value
   tya                        ; 2
   lsr                        ; 2         divide position by 16
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   clc                        ; 2
   adc tmpHorizPosDiv16       ; 3         increment by div16 remainder
   cmp #15                    ; 2
   bcc .skipSubtractions      ; 2³
   sbc #15                    ; 2
   iny                        ; 2         increment coarse value
.skipSubtractions
   sta HMCLR                  ; 3        
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP 2                    ; 2        
   eor #7                     ; 2         get 3-bit 1's complement
   asl                        ; 2         shift value to set fine motion
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2 = @15
.coarsePositionPlayer
   dey                        ; 2  
   bpl .coarsePositionPlayer  ; 2³
   sta RESP0,x                ; 4
   sta HMP0,x                 ; 4
NewScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   rts                        ; 6

DrawOuterBoxingRingPosts
   ldx #10                    ; 2
   lda boxingRingColor        ; 3         get boxing ring color
   sta COLUPF                 ; 3         color playfield
   ldy #0                     ; 2        
   sta HMCLR                  ; 3
.drawBoxingRingPosts
   jsr NewScanline            ; 6
;--------------------------------------
   lda #$30                   ; 2 = @11
   sta PF1                    ; 3 = @14
   sty PF2                    ; 3 = @17
   lda CopyrightLSBValues - 2,x;4
   sta graphicPointers - 2,x  ; 4
   dex                        ; 2
   dex                        ; 2
   bne .drawBoxingRingPosts   ; 2³
   rts                        ; 6

BoxerHorizOffsetValues
   .byte 19;, 2
;
; last byte shared with table below
;
PunchedBoxerOffsetValues
   .byte 2, 1, -2, 1, 2, -1, -2, -1
    
GameInitTable
   .byte INIT_RIGHT_BOXER_X
   .byte INIT_RIGHT_BOXER_Y
   .byte >BoxerGraphics
   .byte >LeftBoxerSizeValues
   .byte >BoxerGraphics
   .byte >RightBoxerSizeValues
    
RightBoxerSizeValues
RightBoxerUpperArmSizeValues
   .byte HMOVE_R2 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L4 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R6 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_R2 | ONE_COPY,    HMOVE_L4 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R6 | DOUBLE_SIZE
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_R2 | ONE_COPY,    HMOVE_L7 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L6 | ONE_COPY
   .byte HMOVE_R4 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_R6 | DOUBLE_SIZE, HMOVE_R4 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_L7 | ONE_COPY,    HMOVE_L7 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L4 | ONE_COPY
   .byte HMOVE_L4 | DOUBLE_SIZE, HMOVE_L2 | DOUBLE_SIZE, HMOVE_R4 | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE
   .byte HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_R6 | QUAD_SIZE,   HMOVE_R8 | QUAD_SIZE
   .byte HMOVE_R6 | DOUBLE_SIZE, HMOVE_R5 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

RightBoxerBodySizeValues
   .byte HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L5 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R5 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_R3 | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L4 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R4 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_L1 | ONE_COPY,    HMOVE_L3 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

RightBoxerLowerArmSizeValues
   .byte HMOVE_L6 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R4 | DOUBLE_SIZE
   .byte HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L6 | ONE_COPY,    HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R4 | DOUBLE_SIZE, HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_L4 | ONE_COPY,    HMOVE_L6 | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_L4 | DOUBLE_SIZE, HMOVE_R6 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY
   .byte HMOVE_R1 | ONE_COPY,    HMOVE_R6 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_L5 | ONE_COPY,    HMOVE_L6 | DOUBLE_SIZE, HMOVE_L7 | DOUBLE_SIZE, HMOVE_L7 | QUAD_SIZE
   .byte HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_L4 | QUAD_SIZE
   .byte HMOVE_L4 | QUAD_SIZE,   HMOVE_R8 | QUAD_SIZE,   HMOVE_R6 | DOUBLE_SIZE, HMOVE_0  | ONE_COPY
   .byte HMOVE_R7 | ONE_COPY;,HMOVE_R7 | ONE_COPY, HMOVE_0  | TWO_MED_COPIES, HMOVE_L4 | 8 | TWO_MED_COPIES
;
; last 3 bytes shared with code below
;
DetermineCPUBoxerDirectionValues
   bcc .setCPUBoxerTargetedPositions; branch if player score lower than CPU
   lsr                              ; a = 10 || a = 11
   nop                              ; not needed
.setCPUBoxerTargetedPositions
   and frameCount
   bne .nextRandom
   lda random                       ; get random seed value
   and #$3F                         ; 0 <= a <= 63
   sta targetedCPUVertOffset
   lda leftBoxerVertPos             ; get left boxer vertical position
   sta targetedCPUBoxerVertPos      ; set CPU boxer targeted vertical position
   lda leftBoxerHorizPos            ; get left boxer horizontal position
   sta targetedCPUBoxerHorizPos     ; set CPU boxer targeted horizontal position
   lda random + 1                   ; get random seed MSB
   and #$1F                         ; 0 <= a <= 31
   sta targetedCPUHorizOffset
.nextRandom
   lda random
   asl
   eor random
   asl
   asl
   rol random + 1
   rol random
   lda targetedCPUBoxerHorizPos     ; get CPU boxer targeted horizontal position
   cmp #(XMAX / 2) - 10
   bcs .adjustTargetedHorizontalOffset;branch if left boxer on right side of ring
   adc #14 + 44
.adjustTargetedHorizontalOffset
   sbc #(8 * 5) + 4
   clc
   adc targetedCPUHorizOffset
   ldy #P1_NO_MOVE                  ; assume no movement for CPU boxer
   cmp rightBoxerHorizPos
   beq .determineCPUBoxerVerticalDirection;branch if no horizontal movement
   ldy #MOVE_RIGHT >> 4
   bcs .determineCPUBoxerVerticalDirection;branch if moving right
   ldy #MOVE_LEFT >> 4
.determineCPUBoxerVerticalDirection
   lda targetedCPUBoxerVertPos      ; get CPU boxer targeted vertical position
   sec
   sbc #(H_BOXER - H_KERNEL_SECTION)
   clc
   adc targetedCPUVertOffset
   cmp #192
   bcs .adjustAllowedVerticalDirection;branch to allow MOVE_UP direction
   cmp rightBoxerVertPos
   beq .determineCPUBoxerAllowedDirection;branch if no vertical movement
   dey                              ; allow MOVE_UP direction
   bcc .determineCPUBoxerAllowedDirection
.adjustAllowedVerticalDirection
   dey                              ; decrement allowed motion value
.determineCPUBoxerAllowedDirection
   tya                              ; move direction values to accumulator
   ldy cpuBoxerDancingValue
   cpy #16
   bcc .doneDetermineCPUBoxerDirectionValues
   ldy hitBoxerIndex
   bne .danceCPUBoxerVertically     ; branch if Black Boxer not hit
   tya
.danceCPUBoxerVertically
   eor #P1_HORIZ_MOVE
.doneDetermineCPUBoxerDirectionValues
   rts

LeftBoxerSizeValues
LeftBoxerUpperArmSizeValues
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L7 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L6 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R4 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L7 | ONE_COPY,    HMOVE_L6 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R4 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L2 | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_L4 | DOUBLE_SIZE, HMOVE_L4 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_L1 | DOUBLE_SIZE, HMOVE_L6 | DOUBLE_SIZE, HMOVE_R7 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_R7 | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_L6 | DOUBLE_SIZE, HMOVE_L6 | QUAD_SIZE,   HMOVE_L4 | QUAD_SIZE,   HMOVE_L4 | QUAD_SIZE
   .byte HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_L6 | QUAD_SIZE
   .byte HMOVE_R7 | DOUBLE_SIZE, HMOVE_L4 | DOUBLE_SIZE, HMOVE_R5 | ONE_COPY,    HMOVE_0  | ONE_COPY

LeftBoxerBodySizeValues
   .byte HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L5 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R5 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L3 | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY
   .byte HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L6 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R6 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_R1 | ONE_COPY,    HMOVE_R3 | ONE_COPY,    HMOVE_0  | ONE_COPY

LeftBoxerLowerArmSizeValues
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L4 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_L1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_R6 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_R7 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_0  | ONE_COPY,    HMOVE_L4 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R6 | ONE_COPY,    HMOVE_R7 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L7 | DOUBLE_SIZE, HMOVE_R6 | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_R1 | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE
   .byte HMOVE_0  | DOUBLE_SIZE, HMOVE_0  | DOUBLE_SIZE, HMOVE_R4 | DOUBLE_SIZE, HMOVE_R4 | ONE_COPY
   .byte HMOVE_0  | ONE_COPY,    HMOVE_L1 | ONE_COPY,    HMOVE_R2 | ONE_COPY,    HMOVE_0  | ONE_COPY

   .byte HMOVE_0  | ONE_COPY,    HMOVE_L5 | DOUBLE_SIZE, HMOVE_R4 | DOUBLE_SIZE, HMOVE_L7 | QUAD_SIZE
   .byte HMOVE_R6 | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE,   HMOVE_0  | QUAD_SIZE
   .byte HMOVE_R4 | QUAD_SIZE,   HMOVE_R4 | QUAD_SIZE,   HMOVE_R8 | DOUBLE_SIZE, HMOVE_R4 | ONE_COPY
   .byte HMOVE_0  | ONE_COPY;, HMOVE_0  | ONE_COPY, HMOVE_R1 | ONE_COPY, HMOVE_0  | ONE_COPY
;
; last 3 bytes shares with data below
;
   .org ROM_BASE + 2048 - 4, 0      ; 2K ROM
   .word Start
   .word Start
