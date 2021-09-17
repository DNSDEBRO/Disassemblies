   LIST OFF
; ***  A S T R O B L A S T  ***
; Copyright 1982 Mattel, Inc.
; Designer: Hal Finney

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: August 16, 2017
;
; *** 115 BYTES OF RAM USED 13 BYTES FREE
;
; NTSC & PAL60 ROM usage stats
; -------------------------------------------
; *** 77 BYTES OF ROM FREE
;
; PAL50 ROM usage stats
; -------------------------------------------
; *** 80 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, MATTEL CANADA, INC.                          =
; =                                                                            =
; ==============================================================================
;
; - Game auto-detects joystick or paddles at power up
; - Sprite data is stored twice in the ROM (only the first occurrance is used)
; - RAM location $91 is not used

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $00         ; set the read address base so this runs on
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
VBLANK_TIME             = 34        ; vertical blanking time for 60 FPS
OVERSCAN_TIME           = 30        ; overscan time for 60 FPS

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 74
OVERSCAN_TIME           = 63

   ENDIF
                                    
;===============================================================================
; C O L O R  C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
RED                     = $30
PURPLE                  = $60
BLUE                    = $80
BLUE_GREEN              = $A0
GREEN                   = $C0

   ELSE

YELLOW                  = $20
GREEN                   = $30
RED                     = $40
PURPLE                  = $60
BLUE_GREEN              = $A0
BLUE                    = $B0

   ENDIF


;======================================================================================
; U S E R - C O N S T A N T S
;======================================================================================

ROM_BASE                = $F000

XMIN                    = 2
XMAX                    = 144

H_KERNEL                = 173
H_UFO                   = 10
H_UFO_BOMB              = 4
H_MISSILE               = 13
H_SPINNERS              = 16
H_BIG_ROCK              = 15
H_SMALL_ROCK            = 6
H_PULSAR                = 11

UFO_VERT_POS            = H_KERNEL - 23
UFO_BOMB_INIT_VERT_POS  = UFO_VERT_POS - 16
LASERBASE_INIT_VERT_POS = 14
MISSILE_INIT_VERT_POS   = LASERBASE_INIT_VERT_POS + 5
SPINNERS_INIT_VERT_POS  = H_KERNEL - 1

SPINNER_ANIMATION_BYTES = <[SpinnerAnimation3_0 + 23 - SpinnerSprites_0]

MAX_ANIMATION_FRAMES    = 4

INIT_NUM_LASER_BASES    = $10       ; BCD value

; point values
POINT_VALUE_BIG_ROCK    = $01
POINT_VALUE_SMALL_ROCK  = $02
POINT_VALUE_SPINNER     = $04
POINT_VALUE_PULSAR      = $08
POINT_VALUE_UFO         = $10

POINT_VALUE_DECREMENT_LASERBASE = $20

; velocity constants
VELOCITY_VERTICAL_MASK  = $0F
VELOCITY_HORIZ_MASK     = $F0

VELOCITY_STATIONARY     = 8

; object ids
ID_LASER_BASE           = 5
ID_MISSILE_1            = 6
ID_MISSILE_2            = 7

; gameState values
GAME_OVER               = %10000000
USING_PADDLES           = %01000000
UFO_BOMBS               = %00100000
UFO_ACTIVE              = %00010000

;===============================================================================
; M A C R O S
;===============================================================================

;-------------------------------------------------------
; FILL_BOUNDARY
; Original author: Dennis Debro (borrowed from Bob Smith / Thomas Jentzsch)
;
; Push data to a certain position inside a page and keep count of how
; many free bytes the programmer will have.
;
; eg: FILL_BOUNDARY 5, -1    ; position at byte #5 in page & fill free space with $FF

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
   
verticalDelta           ds 1
playerHorizValues       ds 8
;--------------------------------------
laserBaseHorizValue     = playerHorizValues + ID_LASER_BASE
missileHorizValues      = laserBaseHorizValue + 1
;--------------------------------------
missile1HorizValue      = missileHorizValues
missile2HorizValue      = missile1HorizValue + 1
objectHorizPositions    ds 8
;--------------------------------------
laserBaseHorizPosition  = objectHorizPositions + ID_LASER_BASE
missileHorizPositions   = laserBaseHorizPosition + 1
;--------------------------------------
missile1HorizPosition   = missileHorizPositions
missile2HorizPosition   = missile1HorizPosition + 1
unused_01               ds 1        ; RAM location $91 is not used
playerOffsetValues      ds 8
;--------------------------------------
laserBaseOffsetValue    = playerOffsetValues + ID_LASER_BASE
missileOffsetValues     = laserBaseOffsetValue + 1
;--------------------------------------
missile1OffsetValue     = missileOffsetValues
missile2OffsetValue     = missile1OffsetValue + 1
playerColorValues       ds 8
;--------------------------------------
laserBaseColorValue     = playerColorValues + ID_LASER_BASE
missileColorValues      = laserBaseColorValue + 1
;--------------------------------------
missile1ColorValue      = missileColorValues
missile2ColorValue      = missile1ColorValue + 1
playerGraphicLSBValues  ds 8
objectVelocity          ds 8
;--------------------------------------
laserBaseVelocity       = objectVelocity + ID_LASER_BASE
missileVelocity         = laserBaseVelocity + 1
;--------------------------------------
missile1Velocity        = missileVelocity
missile2Velocity        = missile1Velocity + 1
objectSortArray         ds 10
gameState               ds 1
randomSeed              ds 1
tempScanline            ds 1
;--------------------------------------
points                  = tempScanline
;--------------------------------------
tempMissileIndex        = points
;--------------------------------------
tempObjectHorizDistance = tempMissileIndex
;--------------------------------------
tempObjectIndex         = tempObjectHorizDistance
;--------------------------------------
tempHighestOffsetValue  = tempObjectIndex
;--------------------------------------
tempUFOHorizPosition    = tempHighestOffsetValue
;--------------------------------------
tempObjectOffsetValue   = tempUFOHorizPosition
;--------------------------------------
laserbaseDebrisLSBValue = tempObjectOffsetValue
;--------------------------------------
tempVolumeSoundBits     = laserbaseDebrisLSBValue
;--------------------------------------
suppressZeroValue       = tempVolumeSoundBits
;--------------------------------------
tempOffsetValue         = suppressZeroValue
;--------------------------------------
tempCoarseValue         = tempOffsetValue
;--------------------------------------
tempDivRemainder        = tempCoarseValue
;--------------------------------------
tempMod127              = tempDivRemainder
temp                    ds 1
;--------------------------------------
tempPlayer0Graphic      = temp
;--------------------------------------
tempMissileOffsetValue  = tempPlayer0Graphic
;--------------------------------------
tempLaserBaseHorizPosition = tempMissileOffsetValue
;--------------------------------------
tempObjectVelocity      = tempLaserBaseHorizPosition
;--------------------------------------
tempFrameCountMod3      = tempObjectVelocity
overscanVector          ds 2
frameCount              ds 1
deathAnimationTimer     ds 1
soundVolumeIndexes      ds 2
;--------------------------------------
soundVolume0Index       = soundVolumeIndexes
soundVolume1Index       = soundVolume0Index + 1
soundBits               ds 1
fireButtonDebounce      ds 1
newObjectVelocityMulti  ds 1
playerScore             ds 3
numberOfLaserBases      ds 1
soundIndex              ds 1
gameLevel               ds 1
paddleValue             ds 1
previousPaddleValue     ds 1
peakScore               ds 3
player0GraphicsPointer  ds 2
player0GraphicOffset    ds 1
player1GraphicsPointer  ds 2
player1GraphicOffset    ds 1
tempPlayer1Graphic      ds 1
pf0GraphicsPointer      ds 2
pf1GraphicsPointer      ds 2
pf2GraphicsPointer      ds 2
digitPlayfieldGraphPtrs ds 16
;--------------------------------------
leftPF0DigitPointer     = digitPlayfieldGraphPtrs
pf1DigitMSBPointer      = leftPF0DigitPointer + 2
pf1DigitLSBPointer      = pf1DigitMSBPointer + 2
pf2DigitMSBPointer      = pf1DigitLSBPointer + 2
pf2DigitLSBPointer      = pf2DigitMSBPointer + 2
numOfBasesPF1GraphPtr   = pf2DigitLSBPointer + 2
numOfBasesPF2GraphPtr   = numOfBasesPF1GraphPtr + 2
rightPF0DigitPointer    = numOfBasesPF2GraphPtr + 2
backgroundColor         ds 1
mountainTerrainColor    ds 1
tempArrayPosition       ds 1

   echo "***",(*-$80 - 1)d, "BYTES OF RAM USED", ($100 - * + 1)d, "BYTES FREE"
   
;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG Bank0
   .org ROM_BASE

AnimateFallingObjects
   lda frameCount                   ; get current frame count
   and #7
   cmp #MAX_ANIMATION_FRAMES + 1
   bcs .doneAnimateFallingObjects
   tax
   lda playerOffsetValues,x         ; get player offset value
   beq .doneAnimateFallingObjects   ; branch if player not active
   lda playerColorValues,x          ; get player color value
   cmp #WHITE - 1
   beq AnimateFallingPulsar         ; branch if object is a pulsar
   cmp #WHITE
   bne .doneAnimateFallingObjects   ; branch if object is not a spinner
   lda playerGraphicLSBValues,x     ; get player graphic LSB value
   clc
   adc playerOffsetValues,x         ; increment by offset value
   sec
   sbc #SPINNER_ANIMATION_BYTES + 1
   lsr
   lsr
   lsr
   lsr
   lsr
   tay
   lda VerticalOffsetTable,y
   adc playerOffsetValues,x
   sta playerOffsetValues,x
   iny
   tya
   and #3
   asl
   asl
   asl
   asl
   asl
   adc #SPINNER_ANIMATION_BYTES + 1
   sec
   sbc playerOffsetValues,x
   sta playerGraphicLSBValues,x
.doneAnimateFallingObjects
   rts

VerticalOffsetTable
   .byte -2, -2, 2, 2
   
AnimateFallingPulsar
   lda playerGraphicLSBValues,x     ; get Pulsar graphic LSB value
   clc
   adc playerOffsetValues,x         ; increment by vertical position
   eor #$17
   sta tempOffsetValue
   cmp #<-6
   lda playerOffsetValues,x         ; get Pulsar vertical position
   bcs .movePulsarDown
   adc #4 + 3
.movePulsarDown
   sbc #3
   sta playerOffsetValues,x         ; set new vertical position for Pulsar
   lda tempOffsetValue
   sec
   sbc playerOffsetValues,x
   sta playerGraphicLSBValues,x
   lda objectHorizPositions,x       ; get pulsar's horizontal position
   sec
   sbc laserBaseHorizPosition       ; subtract laser base horizontal position
   lda objectVelocity,x             ; get the object's velocity
   and #VELOCITY_VERTICAL_MASK      ; keep vertical velocity
   bcs .pulsarToRightOfLaserBase
   eor #VELOCITY_STATIONARY << 4
.pulsarToRightOfLaserBase
   eor #VELOCITY_STATIONARY + 4 << 4
   sta objectVelocity,x
   rts

   FILL_BOUNDARY 112, -1

DisplayKernel
   ldx #<-2
   ldy #H_KERNEL
   sty player0GraphicOffset
   sty player1GraphicOffset
   lda #H_KERNEL + H_BIG_ROCK
   sta player0GraphicsPointer
   sta player1GraphicsPointer
   lda #0
   sta tempPlayer0Graphic
   sta tempPlayer1Graphic
   jmp KernelStart
   
KernelLoop
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   cpy player0GraphicOffset   ; 3
   bcs .setGRP0GraphicValue_0 ; 2³
   lda (player0GraphicsPointer),y;5
.setGRP0GraphicValue_0
   sta GRP0                   ; 3 = @15
   dey                        ; 2
   cpy player1GraphicOffset   ; 3
   bcs .skipSetGRP1GraphicValue_0;2³
   lda (player1GraphicsPointer),y;5
   sta GRP1                   ; 3 = @30
.skipSetGRP1GraphicValue_0
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   cpy player0GraphicOffset   ; 3
   bcs .setGRP0GraphicValue_1 ; 2³
   lda (player0GraphicsPointer),y;5
.setGRP0GraphicValue_1
   sta GRP0                   ; 3 = @15
.jmpIntoKernel
   dey                        ; 2
   beq .prepareToDrawScoreKernel;2³
   cpy player1GraphicOffset   ; 3
   bcs .skipSetGRP1GraphicValue_1;2³
   lda (player1GraphicsPointer),y;5
   sta GRP1                   ; 3 = @32
   jmp SetupPlayerGraphicBufferValues;3
   
.skipSetGRP1GraphicValue_1
   beq SetupPlayerGraphicBufferValues; 2³
.jmpIntoKernelLoop
   cpy player0GraphicOffset   ; 3
   bcs .jmpToDrawMountainTerrain;2³
   lda (player0GraphicsPointer),y;5
   sta tempPlayer0Graphic     ; 3
.jmpToDrawMountainTerrain
   dey                        ; 2
   jmp .checkToDrawMountainTerrain;3
   
SetupPlayerGraphicBufferValues
   cpy player0GraphicOffset   ; 3
   bcs .setupGRP1BufferValue  ; 2³
   lda (player0GraphicsPointer),y;5
   sta tempPlayer0Graphic     ; 3
.setupGRP1BufferValue
   dey                        ; 2
   lda (player1GraphicsPointer),y;5
   sta tempPlayer1Graphic     ; 3
.checkToDrawMountainTerrain
   sta WSYNC
;--------------------------------------
   lda tempPlayer0Graphic     ; 3
   sta GRP0                   ; 3 = @06
   cpy #32                    ; 2
   bcs .checkForPaddleCapacitor;2³
   tya                        ; 2
   sta tempScanline           ; 3
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   lda (pf0GraphicsPointer),y ; 5
   sta PF0                    ; 3 = @29
   lda (pf1GraphicsPointer),y ; 5
   sta PF1                    ; 3 = @37
   lda (pf2GraphicsPointer),y ; 5
   sta PF2                    ; 3 = @45
   ldy tempScanline           ; 3
.checkForPaddleCapacitor
   lda tempPlayer1Graphic     ; 3
   sta GRP1                   ; 3
   bit INPT1                  ; 3         read paddle 1 value
   bmi .skipSetPaddleValue    ; 2³        branch if capacitor charged
   sty paddleValue            ; 3
.skipSetPaddleValue
   lda #0                     ; 2
   sta tempPlayer0Graphic     ; 3
   sta tempPlayer1Graphic     ; 3
KernelStart
   sta WSYNC
;--------------------------------------
   cpy player0GraphicOffset   ; 3
   bcs .drawGRP0ForCurrentSection;2³
   lda (player0GraphicsPointer),y;5
   beq .prepareGRP0ForNextSection;2³
.drawGRP0ForCurrentSection
   sta GRP0                   ; 3 = @15
.nextScanline
   dey                        ; 2
   beq .prepareToDrawScoreKernel;2³
   cpy player1GraphicOffset   ; 3
   bcs .jmpToKernelLoop       ; 2³
   lda (player1GraphicsPointer),y;5
   sta GRP1                   ; 3 = @32
   beq PrepareGRP1ForNextSection;2³
.jmpToKernelLoop
   jmp KernelLoop             ; 3
   
.prepareToDrawScoreKernel
   lda #0                     ; 2
   sta GRP1                   ; 3
   sta GRP0                   ; 3
   jmp DrawScoreKernel        ; 3
   
.prepareGRP0ForNextSection
   sta GRP0                   ; 3 = @16
   lda objectSortArray + 2,x  ; 4
   tax                        ; 2
   lda playerOffsetValues,x   ; 4
   sta player0GraphicOffset   ; 3
   beq .nextScanline          ; 2³
   lda playerGraphicLSBValues,x;4
   sta player0GraphicsPointer ; 3
   dey                        ; 2
   beq .prepareToDrawScoreKernel;2³
   cpy player1GraphicOffset   ; 3
   bcc .drawPlayer1Graphic    ; 2³
   beq .bufferPlayer1GraphicValue;2³
   lda #0                     ; 2
   sta tempPlayer1Graphic     ; 3
   dey                        ; 2
   bne .setupToHorizPositionGRP0;2³
.drawPlayer1Graphic
   lda (player1GraphicsPointer),y;5
   sta GRP1                   ; 3 = @56
.bufferPlayer1GraphicValue
   dey                        ; 2
   lda (player1GraphicsPointer),y;5
   sta tempPlayer1Graphic     ; 3
.setupToHorizPositionGRP0
   sta HMCLR                  ; 3 = @69
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta GRP0                   ; 3 = @05
   lda playerHorizValues,x    ; 4
   and #$0F                   ; 2
   cmp #6                     ; 2
   bcc .coarseMovePlayer0OnLeft;2³
   lda tempPlayer1Graphic     ; 3
   sta GRP1                   ; 3 = @21
   lda playerColorValues,x    ; 4
   sta COLUP0                 ; 3 = @28
   lda playerHorizValues,x    ; 4
   sta HMP0                   ; 3 = @35
   and #$0F                   ; 2
   sbc #5                     ; 2
   sec                        ; 2
.coarseMovePlayer0OnRight
   sbc #1                     ; 2
   bne .coarseMovePlayer0OnRight;2³
   sta RESP0                  ; 3
.doneMovePlayer0
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda #0                     ; 2
   sta GRP0                   ; 3 = @08
   sta tempPlayer1Graphic     ; 3
   jmp .jmpIntoKernel         ; 3
   
PrepareGRP1ForNextSection
   lda objectSortArray + 2,x  ; 4
   tax                        ; 2
   lda playerOffsetValues,x   ; 4
   sta player1GraphicOffset   ; 3
   beq .jmpToKernelLoop       ; 2³
   lda #0                     ; 2
   cpy player0GraphicOffset   ; 3
   bcs .skipGRP0Draw          ; 2³
   lda (player0GraphicsPointer),y;5
.skipGRP0Draw
   dey                        ; 2
   sta HMCLR                  ; 3
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda playerHorizValues,x    ; 4
   and #$0F                   ; 2
   cmp #6                     ; 2
   bcc .positionPlayer1OnLeft ; 2³
   lda playerGraphicLSBValues,x;4
   sta player1GraphicsPointer ; 3
   lda GRP0                   ; 3 = @23
   lda playerColorValues,x    ; 4
   sta COLUP1                 ; 3 = @30
   lda playerHorizValues,x    ; 4
   sta HMP1                   ; 3 = @37
   and #$0F                   ; 2
   sbc #5                     ; 2
.coarseMovePlayer1OnRight
   sbc #1                     ; 2
   bne .coarseMovePlayer1OnRight;2³
   sta RESP1                  ; 3
.donePrepareGRP1ForNextSection
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   cpy player0GraphicOffset   ; 3
   bcs .checkForKernelEnd     ; 2³
   lda (player0GraphicsPointer),y;5
   sta GRP0                   ; 3 = @16
.checkForKernelEnd
   dey                        ; 2
   bne .continueGameKernel    ; 2³
   jmp .prepareToDrawScoreKernel;3
   
.continueGameKernel
   jmp .jmpIntoKernelLoop     ; 3
   
.coarseMovePlayer0OnLeft
   sbc #1                     ; 2 = @18
   bpl .coarseMovePlayer0OnLeft;2³
   sta RESP0                  ; 3
   lda tempPlayer1Graphic     ; 3
   sta GRP1                   ; 3
   lda playerColorValues,x    ; 4
   sta COLUP0                 ; 3
   lda playerHorizValues,x    ; 4
   sta HMP0                   ; 3
   jmp .doneMovePlayer0       ; 3
   
.positionPlayer1OnLeft
   sec                        ; 2 = @16
.coarseMovePlayer1OnLeft
   sbc #1                     ; 2
   bne .coarseMovePlayer1OnLeft;2³
   sta RESP1                  ; 3 = @43
   lda playerGraphicLSBValues,x;4
   sta player1GraphicsPointer ; 3
   lda playerColorValues,x    ; 4
   sta COLUP1                 ; 3 = @57
   lda playerHorizValues,x    ; 4
   sta HMP1                   ; 3 = @64
   jmp .donePrepareGRP1ForNextSection;3
   
DrawScoreKernel
   sta WSYNC
;--------------------------------------
   lda #PF_NO_REFLECT         ; 2
   sta CTRLPF                 ; 3 = @05
   lda #RED + 10              ; 2
   sta COLUBK                 ; 3 = @10
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda backgroundColor        ; 3
   sta COLUBK                 ; 3 = @06
   lda #YELLOW + 8            ; 2
   sta COLUPF                 ; 3 = @11
   ldx #19                    ; 2
.drawScore
   txa                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   sta WSYNC
;--------------------------------------
   lda (leftPF0DigitPointer),y; 5
   sta PF0                    ; 3 = @08
   lda (pf1DigitMSBPointer),y ; 5
   eor (pf1DigitLSBPointer),y ; 5
   sta PF1                    ; 3 = @21
   lda (pf2DigitMSBPointer),y ; 5
   eor (pf2DigitLSBPointer),y ; 5
   sta PF2                    ; 3 = @34
   lda (rightPF0DigitPointer),y;5
   sta PF0                    ; 3 = @42
   lda (numOfBasesPF1GraphPtr),y;5
   sta PF1                    ; 3 = @50
   lda (numOfBasesPF2GraphPtr),y;5
   sta PF2                    ; 3 = @58
   dex                        ; 2
   bpl .drawScore             ; 2³
   lda #PF_REFLECT            ; 2
   sta CTRLPF                 ; 3 = @67
   lda #0                     ; 2
   sta PF0                    ; 3 = @72
   sta PF1                    ; 3 = @75
;--------------------------------------
   sta PF2                    ; 3 = @02
   rts                        ; 6

Start
;
; Set up everything so the power up state is known.
;
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
   lda #0
.clearLoop
   sta VSYNC,x
   txs                              ; set stack pointer
   inx
   bne .clearLoop
   lda #DOUBLE_SIZE
   sta NUSIZ0                       ; set size of players to DOUBLE_SIZE
   sta NUSIZ1
   lda #PF_REFLECT
   sta CTRLPF                       ; set playfield to REFLECT
   sta VDELP1                       ; vertical delay GRP1
   lda #>GameSprites_0
   sta player0GraphicsPointer + 1
   sta player1GraphicsPointer + 1
   lda #>NumberFonts
   ldx #14
.setDigitPlayfieldMSBValues
   sta digitPlayfieldGraphPtrs + 1,x
   dex
   dex
   bpl .setDigitPlayfieldMSBValues
   lda #<zeroNumberFonts_3
   sta rightPF0DigitPointer
   lda #<-1
   sta objectSortArray + 1
   jsr DetermineControllerType
   lda #<InitializeGame
   sta overscanVector
   lda #>InitializeGame
   sta overscanVector + 1
   jmp StartMainLoop
   
InitializeGame
   jsr InitGameBackground
   lda #INIT_NUM_LASER_BASES
   sta numberOfLaserBases
   jsr LaserBaseBCDToDigits
   jsr ScoreBCDToDigits
   bit SWCHB                        ; check difficulty settings
   bpl .setAmateurGameLevel         ; branch if right difficulty set to AMATEUR
   lda #4
   sta gameLevel
   lda #128
   sta newObjectVelocityMulti
   jmp .checkToStartGame
   
.setAmateurGameLevel
   lda #0
   sta gameLevel
   sta newObjectVelocityMulti
.checkToStartGame
   jsr CheckForFireButtonPressed
   bcc .doneInitializeGame          ; branch if fire button not pressed
   jsr ResetLaserBaseInitState
   jmp SetToPerformGameCalculations
   
.doneInitializeGame
   rts

CheckForFireButtonPressed
   jsr NextRandom
   bit gameState                    ; check current game state value
   bvs .readPaddleFireButton        ; branch if USING_PADDLES
   lda INPT4                        ; read left joystick fire button
   and INPT5                        ; and with right joystick fire button
   bpl .fireButtonPressed           ; branch if either fire button is pressed
   clc
   rts

.readPaddleFireButton
   bit SWCHA                        ; read left port paddle fire buttons
   bvc .fireButtonPressed           ; branch if left paddle fire button pressed
   clc
   rts

.fireButtonPressed
   sec
   rts

StartMainLoop
   lda #2
   sta TIM64T
MainLoop
   lda #DUMP_PORTS | DISABLE_TIA
   sta VBLANK
   jsr TimerWait                    ; wait for kernel timer to expire
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan period
   jsr Overscan
   jsr TimerWait                    ; wait for overscan timer to expire
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   lda #START_VERT_SYNC
   sta VSYNC                        ; start vertical sync
   sta WSYNC
   sta WSYNC
   sta WSYNC
   lda #STOP_VERT_SYNC
   sta VSYNC                        ; stop vertical sync
   jsr ObjectSort
   jsr CalculateObjectHorizPositions
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry bit
   bcs .continueMainLoop            ; branch if RESET not pressed
   jmp Start                        ; jump back to do a cold start
   
.continueMainLoop
   jsr TimerWait
   lda mountainTerrainColor
   sta COLUPF
   lda backgroundColor
   sta COLUBK
   lda #247
   sta TIM64T
   jsr SetupKernelForPaddles
   lda #ENABLE_TIA
   sta VBLANK
   jsr DisplayKernel
   jsr DetermineBasePositionForPaddles
   jmp MainLoop
   
Overscan
   jmp (overscanVector)
   
PerformGameCalculations
   inc frameCount                   ; increment current frame count
   ldy #ID_MISSILE_2
   jsr CheckPlayerMissileCollision
   ldy #ID_MISSILE_1
   jsr CheckPlayerMissileCollision
   jsr AnimateFallingObjects
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry bit
   bcs .checkToSpawnNewObjects      ; branch if an odd frame
   jsr CheckPlayerCollisions
   bcs .donePerformGameCalculations
   jsr PlayGameSounds
   jsr CheckToFireMissile
   jsr DetermineLaserbaseVelocity
   jmp .continuePerformGameCalculations
   
.checkToSpawnNewObjects
   jsr SpawnNewObjects
   jsr ScoreBCDToDigits
.continuePerformGameCalculations
   jsr MoveObjectsVertically
   ldx gameLevel
   lda BackgroundColorTable,x
   sta backgroundColor
.donePerformGameCalculations
   rts

SetToPerformGameCalculations
   lda #<PerformGameCalculations
   sta overscanVector
   lda #>PerformGameCalculations
   sta overscanVector + 1
   rts

MoveObjectsForGameOverState
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry bit
   bcs .continueMoveObjectsForGameOverState; don't spawn new object if an odd frame
   jsr SpawnNewObjects
.continueMoveObjectsForGameOverState
   jsr MoveObjectsVertically
   jsr AnimateFallingObjects
   inc frameCount                   ; increment current frame count
   rts

BackgroundColorTable
   .byte BLACK, BLUE, PURPLE, BLUE_GREEN, BLACK + 2
   
CalculateObjectHorizPositions
   ldx #ID_LASER_BASE
   lda frameCount                   ; get current frame count
   and #3                           ; make value 0 <= a <= 3
   sta tempFrameCountMod3
.calculateObjectHorizPositions
   lda objectVelocity,x             ; get object velocity
   jsr DetermineObjectHorizOffset
   adc objectHorizPositions,x       ; add in current object horizontal position value
   cmp #XMIN
   bcc .objectReachedSideBoundaries ; branch if object reached left limit
   cmp #XMAX + 2
   bcs .objectReachedSideBoundaries ; branch if object reached right limit
   sta objectHorizPositions,x
   jsr CalculateHorizontalPosition
.nextObject
   dex
   bpl .calculateObjectHorizPositions
   rts

.objectReachedSideBoundaries
   cpx #ID_LASER_BASE               ; check if object is player's laser base
   beq .nextObject                  ; branch if player laser base
   jsr RemoveObject                 ; remove object from screen
   lda playerColorValues,x          ; get object's color value
   cmp #WHITE - 1
   beq .pulsarReachedSideBoundary   ; branch if pulsar reached side boundary
   cmp #WHITE - 2
   beq .removeUFOFromScreen         ; branch if object is UFO
   jmp .nextObject
   
.pulsarReachedSideBoundary
   lda soundIndex
   sec
   sbc #8
   sta soundIndex
   jmp .nextObject
   
.removeUFOFromScreen
   lda gameState                    ; get current game state
   and #<~(UFO_BOMBS | UFO_ACTIVE)  ; clear UFO_BOMBS and UFO_ACTIVE flags
   sta gameState
   jmp .nextObject
   
DetermineObjectHorizOffset
   lsr                              ; shift horizontal velocity to lower nybbles
   lsr
   lsr
   lsr
   eor #VELOCITY_STATIONARY
   sec
   sbc #VELOCITY_STATIONARY
   clc
   adc tempFrameCountMod3
   lsr
   lsr
   eor #$20
   sec
   sbc #$20
   clc
   rts
;
; Horizontal reset starts at cycle 23 (i.e. pixel 69) for objects on the left
; side of the screen and cycle 48 (i.e. pixel 144) for objects on the right side
; of the screen. Coarse position of objects on the right side of he screen are
; subtracted by 5 in the kernel prior to the coarse positioning cycle loop.
;
CalculateHorizontalPosition
   lda objectHorizPositions,x       ; get object's horizontal position
   tay                              ; move horizontal position to y register
   and #$0F                         ; keep lower nybbles
   sta tempDivRemainder             ; store value for division remainder
   tya                              ; move horizontal position to accumulator
   lsr                              ; divide horizontal position by 16
   lsr
   lsr
   lsr
   tay                              ; store quotient in y register
   clc
   adc tempDivRemainder             ; increment quotient by the division remainder
   cmp #15
   bcc .determineFineMotionValue
   sbc #15                          ; subtract 15 from remainder
   iny                              ; increment quotient for remainder overflow
.determineFineMotionValue
   eor #7                           ; 3-bit 1's complement
   asl                              ; shift to upper nybbles for fine motion
   asl
   asl
   asl
   iny                              ; increment quotient
   sty tempCoarseValue              ; move quotient to coarse position value
   eor tempCoarseValue
   sta playerHorizValues,x
   rts

MoveObjectsVertically
   ldx #7
.moveObjectsVertically
   lda objectVelocity,x             ; get object velocity
   and #VELOCITY_VERTICAL_MASK      ; keep vertical velocity
   sec
   sbc #VELOCITY_STATIONARY
   beq .moveNextObject
   sta verticalDelta
   clc
   adc playerOffsetValues,x
   cmp #LASERBASE_INIT_VERT_POS - 8
   bcc .objectVerticallyOutOfRange  ; branch if object reached the ground
   cmp #H_KERNEL + 51
   bcs .objectVerticallyOutOfRange
   cmp #SPINNERS_INIT_VERT_POS
   bcs .removeObject
   bcc .setObjectNewVerticalPosition; unconditional branch
   
.objectVerticallyOutOfRange
   bit gameState                    ; check current game state value
   bmi .removeObject                ; branch if GAME_OVER
   lda playerColorValues,x          ; get object color value
   cmp #WHITE                       ; check if the object is a spinner
   bne .checkWhichObjectOutOfRange  ; branch if object is not a spinner
   jmp DestroyLaserBase
   
.checkWhichObjectOutOfRange
   cmp #WHITE - 1
   beq .pulsarLanded                ; branch if object is a pulsar
   cmp #WHITE - 3
   beq .removeObject
   and #1
   clc
   adc #$01
   jsr DecrementScore
.removeObject
   jsr RemoveObject
   jmp .moveNextObject
   
.setObjectNewVerticalPosition
   sta playerOffsetValues,x         ; set new vertical position
   lda playerGraphicLSBValues,x     ; get object graphic LSB value
   sec
   sbc verticalDelta
   sta playerGraphicLSBValues,x
.moveNextObject
   dex
   bpl .moveObjectsVertically
   rts

.pulsarLanded
   lda soundIndex
   sec
   sbc #8
   sta soundIndex
   jmp .removeObject
   
TimerWait
   lda T1024T
   bpl .waitTime
   nop
.waitTime
   sta WSYNC
   lda T1024T
   bpl .waitTime
   rts

SpawnNewObjects
   lda gameState                    ; get current game state
   and #UFO_BOMBS | UFO_ACTIVE
   beq .continueSpawnNewObjects     ; branch if UFO not active and no UFO bombs
   jmp DetermineToLaunchUFO
   
.continueSpawnNewObjects
   lda frameCount                   ; get current frame count
   lsr                              ; shift D1 to carry bit
   lsr
   bcs .doneSpawnNewObjects
   lsr                              ; shift D2 to carry bit
   bcs .doneSpawnNewObjects
   bne .determineNewObjectVelocity
   lda gameLevel                    ; get current game level
   asl                              ; multiply value by 32
   asl
   asl
   asl
   asl
   sta newObjectVelocityMulti
   lda #0
.determineNewObjectVelocity
   clc
   adc newObjectVelocityMulti
   tax
   lda NewObjectVerticalVelocityTable,x
   bne .setNewObjectVelocity
   jmp CheckToSpawnUFO
   
.setNewObjectVelocity
   sta tempObjectVelocity
   ldx #4
.searchForInactiveObject
   lda playerOffsetValues,x         ; get player offset value
   beq CheckToSpawnNewObject        ; branch if object not active
   dex
   bpl .searchForInactiveObject
.doneSpawnNewObjects
   rts

CheckToSpawnNewObject
   jsr NextRandom                   ; get new random number
   bpl .determineNewObjectAttributes
   ldy gameLevel
   beq .doneCheckToSpawnNewObject
.determineNewObjectAttributes
   and #$7F
   sta tempMod127
   jsr NextRandom                   ; get new random number
   and #$0F                         ; keep lower nybbles
   adc tempMod127
   sta objectHorizPositions,x       ; set new object's horizontal position
   jsr CalculateHorizontalPosition  ; determine object's HMOVE value
   and #$F1
   eor #$0A
   sta playerColorValues,x          ; set new object's color
   lda tempMod127
   and #1                           ; keep D0 value
   beq .spawnNewRock
   lda #<[SmallRock_0 + H_SMALL_ROCK - SPINNERS_INIT_VERT_POS - (BigRock_0 + H_BIG_ROCK - SPINNERS_INIT_VERT_POS)]
.spawnNewRock
   clc
   adc #<(BigRock_0 + H_BIG_ROCK - SPINNERS_INIT_VERT_POS)
   sta playerGraphicLSBValues,x     ; set object's graphic LSB value
   lda #SPINNERS_INIT_VERT_POS
   sta playerOffsetValues,x         ; set object's initial vertical position
   lda tempObjectVelocity
   sta objectVelocity,x             ; set object's velocity
   ldy gameLevel                    ; get current game level
   cmp SpawningFrequencyTable,y
   bcs .checkToSpawnSpinner
   cmp #$06
   bcc .checkToSpawnPulsar
.doneCheckToSpawnNewObject
   rts

.checkToSpawnSpinner
   jsr NextRandom                   ; get new random number
   and SpinnerSpawnFrequency,y
   bne .doneSpawnSpinnerOrPulsar
   lda #<(SpinnerSprites_0 + H_SPINNERS - SPINNERS_INIT_VERT_POS)
   sta playerGraphicLSBValues,x     ; set spinner graphic LSB value
   lda #WHITE
   sta playerColorValues,x          ; set spinner color
   inc soundIndex
   bit gameState                    ; check current game state value
   bmi .doneSpawnSpinnerOrPulsar    ; branch if GAME_OVER
   jsr SetSpinnerSoundIndicators
.doneSpawnSpinnerOrPulsar
   rts

.checkToSpawnPulsar
   bit gameState                    ; check current game state value
   bmi .doneSpawnSpinnerOrPulsar    ; branch if GAME_OVER
   jsr NextRandom                   ; get new random number
   and PulsarSpawnFrequency,y
   bne .doneSpawnSpinnerOrPulsar
   lda #<(Pulsar_0 + H_PULSAR - SPINNERS_INIT_VERT_POS)
   sta playerGraphicLSBValues,x     ; set pulsar graphic LSB value
   lda #WHITE - 1
   sta playerColorValues,x          ; set pulsar color
   lda soundIndex
   clc
   adc #8
   sta soundIndex
   jmp SetPulsarSoundIndicators
   
NewObjectVerticalVelocityTable
   .byte $07,$00,$06,$00,$05,$00,$07,$00,$06,$00,$07,$00,$06,$00,$00,$07
   .byte $00,$05,$07,$00,$00,$07,$00,$00,$06,$00,$00,$06,$00,$00,$00,$00
   .byte $07,$00,$00,$05,$06,$00,$07,$06,$00,$07,$00,$05,$07,$00,$06,$00
   .byte $00,$00,$05,$00,$07,$05,$00,$00,$00,$00,$04,$00,$06,$00,$00,$00
   .byte $07,$00,$06,$00,$00,$04,$00,$05,$06,$00,$07,$00,$06,$00,$00,$00
   .byte $05,$00,$06,$04,$07,$00,$05,$00,$00,$06,$00,$00,$00,$00,$00,$04
   .byte $07,$05,$00,$06,$00,$00,$04,$05,$06,$00,$00,$00,$05,$00,$06,$07
   .byte $00,$04,$00,$05,$06,$04,$00,$00,$04,$05,$00,$06,$00,$03,$00,$00
   .byte $07,$00,$04,$05,$06,$00,$00,$05,$00,$00,$04,$05,$06,$00,$04,$00
   .byte $05,$00,$05,$04,$00,$03,$04,$05,$00,$03,$06,$04,$00,$00,$03,$05
   
SpawningFrequencyTable
   .byte $07, $07, $06, $05, $05
   
SpinnerSpawnFrequency
   .byte $1F, $07, $07, $0F, $07
   
PulsarSpawnFrequency
   .byte $3F, $0F, $07, $07, $07
   
PlayerMissileHitUFO
   lda gameState                    ; get the current game state
   and #<~(UFO_BOMBS | UFO_ACTIVE)  ; clear UFO_BOMBS and UFO_ACTIVE flags
   sta gameState
   lda tempObjectIndex
   tax
   jsr RemoveObject
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_UFO
   jmp IncrementScore
   
PlayerMissileHitUFOBomb
   lda tempObjectIndex
   tax
   jmp RemoveObject
   
PlayerMissileHitObject
   stx tempObjectIndex              ; save index of object hit by player missile
   tya                              ; move missile index to accumulator
   tax                              ; move missile index to x register
   jsr RemoveObject
   ldx tempObjectIndex              ; get object index of object hit by player missile
   lda playerColorValues,x          ; get object color value
   cmp #WHITE | 1
   beq PlayerMissileHitUFOBomb
   cmp #WHITE - 2
   beq PlayerMissileHitUFO
   cmp #WHITE - 1
   beq PlayerMissileHitPulsar
   cmp #WHITE
   beq PlayerMissileHitSpinner
   and #$01
   bne PlayerMissileHitSmallRock
   ldx #4
.findBigRockToSplit
   lda playerOffsetValues,x         ; get object offset value
   beq SplitBigRockIntoSmallRocks   ; branch if object not active
   dex
   bpl .findBigRockToSplit
   ldx tempObjectIndex
   jsr RemoveObject
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_BIG_ROCK
   jmp IncrementScore
   
PlayerMissileHitSmallRock
   jsr RemoveObject
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_SMALL_ROCK
   jmp IncrementScore
   
SplitBigRockIntoSmallRocks
   ldy tempObjectIndex              ; get object index of object hit by player missile
   lda playerHorizValues,y          ; get horizontal value of hit object
   sta playerHorizValues,x          ; place in horizontal value of inactive object
   lda objectHorizPositions,y       ; get horizontal position of hit object
   sta objectHorizPositions,x       ; place in horizontal position of inactive object
   lda playerOffsetValues,y         ; get offset value of hit object
   clc
   adc #6                           ; increment value by 6
   sta playerOffsetValues,x         ; place in offset value of inactive object
   sbc #11
   sta playerOffsetValues,y         ; place in offset value of hit object
   lda playerColorValues,y          ; get color value of hit object
   eor #1                           ; flip D0 value
   sta playerColorValues,y
   sta playerColorValues,x
   lda playerGraphicLSBValues,y     ; get graphic LSB value for hit object
   clc
   adc #16
   sta playerGraphicLSBValues,x     ; place in graphic LSB of inactive object
   clc
   adc #12
   sta playerGraphicLSBValues,y
   lda objectVelocity,y             ; get hit object's velocity
   clc
   adc #(VELOCITY_STATIONARY - 5) << 4;set hit object's new horizontal velocity
   sta objectVelocity,y             ; set hit object's new velocity
   adc #(VELOCITY_STATIONARY + 2) << 4
   sta objectVelocity,x             ; set object's new velocity
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_BIG_ROCK
   jmp IncrementScore
   
PlayerMissileHitSpinner
   dec soundIndex
   lda tempObjectIndex
   tax
   jsr RemoveObject
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_SPINNER
   jmp IncrementScore
   
PlayerMissileHitPulsar
   lda soundIndex
   sec
   sbc #$08
   sta soundIndex
   lda tempObjectIndex
   tax
   jsr RemoveObject
   jsr SetGameSoundIndicators
   lda #POINT_VALUE_PULSAR
   jmp IncrementScore
   
ObjectSort
   ldy #ID_MISSILE_2
   sty objectSortArray
   ldx #<-1
   stx objectSortArray + 2,y        ; place out of range index at end of array
   ldx #<-2
   dey
.sortObjectsLoop
   lda objectSortArray + 2,x        ; get object index at sort array
   stx tempArrayPosition            ; save current array position for later
   tax                              ; move object index to x register
   lda playerOffsetValues,y
   cmp playerOffsetValues,x
   bcc .sortObjectsLoop
   stx objectSortArray + 2,y
   ldx tempArrayPosition
   sty objectSortArray + 2,x
   ldx #<-2
   dey
   bpl .sortObjectsLoop
   rts

RemoveObject
   lda #0
   sta playerOffsetValues,x
   lda #VELOCITY_STATIONARY
   sta objectVelocity,x             ; set object's vertical velocity to stationary
   rts

ResetLaserBaseInitState
   ldx #ID_LASER_BASE
   lda #HMOVE_R7 | 5
   sta playerHorizValues,x
   lda #74
   sta objectHorizPositions,x
   lda #LASERBASE_INIT_VERT_POS
   sta playerOffsetValues,x
   
   IF COMPILE_REGION = NTSC
   
      lda #RED + 10
      
   ELSE
   
      lda #GREEN + 10
      
   ENDIF
   
   sta playerColorValues,x
   lda #VELOCITY_STATIONARY
   sta objectVelocity,x             ; set laser base vertical velocity
   lda #<LaserDefenseBase_0
   sta playerGraphicLSBValues,x
.doneDetermineLaserbaseVelocity
   rts

DetermineLaserbaseVelocity
   bit gameState                    ; check current game state value
   bvs .doneDetermineLaserbaseVelocity;branch if USING_PADDLES
   lda SWCHA                        ; read joystick values
   lsr                              ; move player 1 joystick values to lower nybbles
   lsr
   lsr
   lsr
   and SWCHA                        ; and with player 2 joystick values
   
   IF COMPILE_REGION = PAL50
   
      eor #$0F
      
   ENDIF
   
   tay
   lda JoystickVelocityTable,y
   sta.w laserBaseVelocity
   rts

JoystickVelocityTable

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60
   
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   
   ELSE
   
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY + 1 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY - 8 << 4 | VELOCITY_STATIONARY
   
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   .byte VELOCITY_STATIONARY - 1 << 4 | VELOCITY_STATIONARY
   
   ENDIF
   
DestroyLaserBase
   lda #POINT_VALUE_DECREMENT_LASERBASE
   jsr DecrementScore               ; decrement score
   ldx #ID_LASER_BASE               ; set x index to point to laser base object
   lda #$30
   sec
   sbc playerOffsetValues,x
   sta laserbaseDebrisLSBValue
   ldy #4
.setLaserbaseDebrisValues
   lda playerHorizValues,x
   sta playerHorizValues,y
   lda objectHorizPositions,x
   sta objectHorizPositions,y
   lda playerOffsetValues,x
   sta playerOffsetValues,y
   lda laserbaseDebrisLSBValue
   sta playerGraphicLSBValues,y
   lda #WHITE
   sta playerColorValues,y
   dey
   bpl .setLaserbaseDebrisValues
   lda #(VELOCITY_STATIONARY + 4) << 4 | VELOCITY_STATIONARY + 1
   sta objectVelocity
   lda #(VELOCITY_STATIONARY - 4) << 4 | VELOCITY_STATIONARY + 1
   sta objectVelocity + 1
   lda #(VELOCITY_STATIONARY + 5) << 4 | VELOCITY_STATIONARY + 2
   sta objectVelocity + 2
   lda #(VELOCITY_STATIONARY - 5) << 4 | VELOCITY_STATIONARY + 2
   sta objectVelocity + 3
   lda #(VELOCITY_STATIONARY - 8) << 4 | VELOCITY_STATIONARY + 3
   sta objectVelocity + 4
.removeObjects
   jsr RemoveObject
   inx
   cpx #ID_MISSILE_2 + 1
   bne .removeObjects
   lda #<PerformDeathAnimation
   sta overscanVector
   lda #>PerformDeathAnimation
   sta overscanVector + 1
   lda #120
   sta deathAnimationTimer          ; do death animation for 120 frames
   jsr SetupDeathAnimtationSounds
   lda #$00
   sta soundIndex
   lda gameState                    ; get current game state
   and #<~(UFO_BOMBS | UFO_ACTIVE)  ; clear UFO_BOMBS and UFO_ACTIVE flags
   sta gameState
   sed                              ; set to decimal mode
   lda numberOfLaserBases           ; get number of remaining laser bases
   sec
   sbc #1                           ; reduce number of laser bases by 1
   sta numberOfLaserBases           ; set new number of remaining laser bases
   cld                              ; clear decimal mode
   jsr LaserBaseBCDToDigits
   sec
   rts

PerformDeathAnimation
   inc frameCount                   ; increment frame count
   jsr MoveObjectsVertically
   jsr PlayDeathSounds
   dec deathAnimationTimer          ; reduce death animtation timer
   bmi .checkForGameOver
   beq .removeDeathAnimtionObjects
   jsr ScoreBCDToDigits
   jmp SetBackgroundForDeathAnimation
   
.removeDeathAnimtionObjects
   ldx #4
.removeNextObject
   jsr RemoveObject
   dex
   bpl .removeNextObject
   jsr InitGameBackground
   rts

.checkForGameOver
   lda numberOfLaserBases           ; get number of remaining laser bases
   beq SetToGameOver                ; branch if no more laser bases left
   lda #0
   sta deathAnimationTimer
   jsr CheckForFireButtonPressed
   bcc .donePerformDeathAnimation   ; branch if fire button not pressed
   jsr ResetLaserBaseInitState
   jsr SetToPerformGameCalculations
.donePerformDeathAnimation
   rts

SetToGameOver
   lda #<MoveObjectsForGameOverState
   sta overscanVector
   lda #>MoveObjectsForGameOverState
   sta overscanVector + 1
   lda gameState                    ; get current game state value
   ora #GAME_OVER
   sta gameState
   lda peakScore
   sta playerScore
   lda peakScore + 1
   sta playerScore + 1
   lda peakScore + 2
   sta playerScore + 2
   jmp ScoreBCDToDigits
   
CheckPlayerCollisions
   ldx objectSortArray
   lda.w laserBaseHorizPosition
   sta tempLaserBaseHorizPosition
.checkPlayerCollisions
   cpx #<-1
   beq .noPlayerCollisions
   lda playerOffsetValues,x         ; get object offset value
   beq .noPlayerCollisions          ; branch if object not active
   cpx #ID_LASER_BASE               ; check if object is player's laser base
   bcs .checkNextPlayerCollision    ; branch if a safe object to player
   lda #$18
   sta tempObjectOffsetValue
   ldy #13
   lda playerColorValues,x          ; get object color value
   and #1
   beq .compareObjectOffsetValues
   ldy #9
   lda #$14
   sta tempObjectOffsetValue
.compareObjectOffsetValues
   lda playerOffsetValues,x
   cmp tempObjectOffsetValue
   bcs .checkNextPlayerCollision
   lda objectHorizPositions,x       ; get object horizontal position
   sec
   sbc tempLaserBaseHorizPosition   ; subtract laser base horizontal position
   bcs .setHorizontalDistance
   eor #$FF
   adc #1
.setHorizontalDistance
   sta tempObjectHorizDistance
   cpy tempObjectHorizDistance
   bcc .checkNextPlayerCollision
   jmp DestroyLaserBase
   
.checkNextPlayerCollision
   lda objectSortArray + 2,x
   tax
   jmp .checkPlayerCollisions
   
.noPlayerCollisions
   clc
   rts

CheckPlayerMissileCollision SUBROUTINE
   lda playerOffsetValues,y         ; get missile offset value
   beq .doneCheckPlayerMissileCollision;branch if missile not active
   sta tempMissileOffsetValue
   sty tempMissileIndex             ; save missile number
   ldx objectSortArray
.checkPlayerMissileCollisionLoop
   cpx tempMissileIndex
   beq .doneCheckPlayerMissileCollision
   lda playerOffsetValues,x         ; get object's offset value
   beq .doneCheckPlayerMissileCollision;branch if object not active
   cpx #ID_LASER_BASE
   bcs .checkNextPlayerMissileCollision;branch if object not harmful object
   sec                              ; subtract object vertical position from
   sbc tempMissileOffsetValue       ; missile vertical position
   cmp #11
   bcs .checkNextPlayerMissileCollision
   lda objectHorizPositions,y       ; get missile horizonal position
   sec
   sbc objectHorizPositions,x       ; subtract object horizontal position
   bcs .setHorizontalDistance
   eor #$FF                         ; get absolute value
   adc #1
.setHorizontalDistance
   sta tempObjectHorizDistance
   lda playerColorValues,x          ; get object color value
   and #1
   eor #1
   asl
   asl
   adc #4
   cmp tempObjectHorizDistance
   bcc .checkNextPlayerMissileCollision
   jmp PlayerMissileHitObject
   
.checkNextPlayerMissileCollision
   lda objectSortArray + 2,x
   tax
   jmp .checkPlayerMissileCollisionLoop
   
.doneCheckPlayerMissileCollision
   rts

CheckToFireMissile
   bit SWCHB                        ; check difficulty settings
   bvs .checkToFireMissile          ; branch if left difficulty set to PRO
   bit gameState                    ; check current game state value
   bvs .readPaddleFireButton        ; branch if USING_PADDLES
   lda INPT4                        ; read left joystick fire button
   and INPT5                        ; and with right joystick fire button
   bpl .checkToFireMissile          ; branch if either fire button is pressed
   bmi .fireButtonNotPressed        ; unconditional branch
   
.readPaddleFireButton
   bit SWCHA                        ; read left port paddle fire buttons
   bvc .checkToFireMissile          ; branch if left paddle fire button pressed
.fireButtonNotPressed
   lda #0
   sta fireButtonDebounce           ; clear fire button debounce rate
   rts

.checkToFireMissile
   dec fireButtonDebounce           ; reduce fire button debounce rate
   bpl .doneCheckToFireMissile      ; branch if not time to fire missile
   lda #5
   sta fireButtonDebounce           ; set fire button debounce rate
   ldx #ID_MISSILE_2
.determineMissileToLaunch
   lda playerOffsetValues,x
   beq .launchMissile
   dex
   cpx #ID_LASER_BASE
   bne .determineMissileToLaunch
.doneCheckToFireMissile
   rts

.launchMissile
   lda.w laserBaseHorizValue        ; get laser base horizontal value
   sta playerHorizValues,x          ; set it to missile horizontal value
   lda.w laserBaseHorizPosition     ; get laser base horizontal position
   sta objectHorizPositions,x       ; set it to missile horizontal position
   lda #MISSILE_INIT_VERT_POS
   sta playerOffsetValues,x
   lda #(VELOCITY_STATIONARY - 8) << 4 | VELOCITY_STATIONARY + 7
   sta objectVelocity,x             ; set missile vertical velocity
   lda #WHITE - 6
   sta playerColorValues,x          ; set missile color
   lda #<(MissileSprite_0 + H_MISSILE - MISSILE_INIT_VERT_POS)
   sta playerGraphicLSBValues,x     ; set missile graphic LSB value
   jmp SetMissileLaunchSoundIndicators
   
SetBackgroundForDeathAnimation
   lda #RED
   sta backgroundColor
   lda #BLACK
   sta mountainTerrainColor
   lda #$30
   sta PF0
   lda #<DeathMountainTerrainPF0GraphicData
   sta pf0GraphicsPointer
   lda #>MountainTerrainGraphics
   sta pf0GraphicsPointer + 1
   rts

InitGameBackground
   ldx gameLevel
   lda BackgroundColorTable,x
   sta backgroundColor
   lda #GREEN + 6
   sta mountainTerrainColor
   lda #<MountainTerrainPF0GraphicData
   sta pf0GraphicsPointer
   lda #>MountainTerrainGraphics
   sta pf0GraphicsPointer + 1
   lda #<MountainTerrainPF1GraphicData
   sta pf1GraphicsPointer
   lda #>MountainTerrainGraphics
   sta pf1GraphicsPointer + 1
   lda #<MountainTerrainPF2GraphicData
   sta pf2GraphicsPointer
   lda #>MountainTerrainGraphics
   sta pf2GraphicsPointer + 1
   lda #$00
   sta PF0
   rts

MountainTerrainGraphics
MountainTerrainPF0GraphicData
   .byte $00, $30, $C0, $00, $00, $00, $00, $00
MountainTerrainPF1GraphicData
   .byte $00, $1C, $22, $C1, $00, $00, $00, $00
MountainTerrainPF2GraphicData
   .byte $00, $00, $0E, $31, $40, $40, $80, $00
DeathMountainTerrainPF0GraphicData
   .byte $00, $30, $F0, $30, $30, $30, $30, $30
   
SetupDeathAnimtationSounds
   lda #$00
   sta AUDC1
   lda #$08
   sta AUDC0
   lda #$14
   sta AUDF0
   lda #60
   sta soundVolume0Index
   lda #$0F
   sta AUDV0
   rts

PlayDeathSounds
   lda soundVolume0Index            ; get sound volume duration value
   beq .donePlayDeathSounds         ; branch if value is zero
   dec soundVolume0Index            ; reduce sound volume duration value
   lda soundVolume0Index            ; get sound volume duration value
   lsr                              ; divide value by 4
   lsr
   sta AUDV0                        ; set death sound volume
.donePlayDeathSounds
   rts

SetMissileLaunchSoundIndicators
   lda soundIndex
   bne .doneSetGameSoundIndicators
   lda soundBits
   and #$06
   bne .clearMissileLaunchSoundBits
   lda soundVolume0Index
   cmp #8
   bcs .doneSetGameSoundIndicators
.clearMissileLaunchSoundBits
   lda #0
   jmp .setVolume0SoundBitIndicators
   
SetSpinnerSoundIndicators
   lda soundIndex
   and #$38
   bne .doneSetGameSoundIndicators
   lda #1
   jmp .setVolume0SoundBitIndicators
   
SetPulsarSoundIndicators
   lda #2
.setVolume0SoundBitIndicators
   tax
   asl
   sta tempVolumeSoundBits
   lda soundBits
   and #1
   ora tempVolumeSoundBits
   sta soundBits
   ldy #0
   jmp .setSoundRegisters
   
SetGameSoundIndicators
   lda gameState                    ; get current game state
   and #UFO_BOMBS                   ; keep UFO_BOMBS flag
   bne .doneSetGameSoundIndicators  ; branch if UFO_BOMBS are active
   lda #3
   jmp .setVolume1SoundBitIndicators
   
SetUFOSoundIndicators
   lda #4
.setVolume1SoundBitIndicators
   tax                              ; move sound index value to x register
   and #1                           ; keep D0 value
   sta tempVolumeSoundBits
   lda soundBits
   and #$06
   ora tempVolumeSoundBits
   sta soundBits
   ldy #1
.setSoundRegisters
   lda SoundVolumeDurationTable,x
   sta soundVolumeIndexes,y
   lda SoundChannelTable,x
   sta AUDC0,y
   lda SoundFrequencyTable,x
   sta AUDF0,y
   lda SoundVolumeTable,x
   sta AUDV0,y
.doneSetGameSoundIndicators
   rts

SoundChannelTable
   .byte $08, $04, $04, $02, $04
   
SoundFrequencyTable
   .byte $10, $10, $04, $06, $0C
   
SoundVolumeTable
   .byte $05, $0A, $08, $0F, $0B
   
SoundVolumeDurationTable
   .byte $10, $FF, $FF, $20, $FF
   
PlayGameSounds
   lda soundVolume0Index            ; get sound volume 0 index
   beq .checkToAdjustSoundChannel1
   dec soundVolume0Index
   beq .turnOffVolumeChannel0
   lda soundBits                    ; get sound bits value
   lsr                              ; divide value by 4
   lsr
   bne .checkToSetChannel0Volume
   bcs .checkToChangeChannel0Frequency;branch if D1 was set
   lda soundVolume0Index            ; get sound volume 0 index
   lsr                              ; divide value by 2
   sta AUDV0                        ; set volume value for audio channel 0
   jmp .checkToAdjustSoundChannel1
   
.checkToChangeChannel0Frequency
   lda soundIndex
   and #7
   beq .turnOffVolumeChannel0
   lda soundVolume0Index
   and #$0F
   eor #$1F
   sta AUDF0
   jmp .checkToAdjustSoundChannel1
   
.checkToSetChannel0Volume
   lda soundIndex
   and #$38
   beq .checkToSetSpinnerSoundIndicator
   lda soundVolume0Index
   and #$08
   sta AUDV0
   jmp .checkToAdjustSoundChannel1
   
.checkToSetSpinnerSoundIndicator
   lda soundIndex
   beq .turnOffVolumeChannel0
   jsr SetSpinnerSoundIndicators
   jmp .checkToAdjustSoundChannel1
   
.turnOffVolumeChannel0
   lda #0
   sta AUDV0
   sta soundVolume0Index
.checkToAdjustSoundChannel1
   lda soundVolume1Index            ; get sound volume 1 index
   beq .donePlayGameSounds          ; branch if value reached 0
   dec soundVolume1Index            ; reduce sound volume 1 index
   lda soundBits                    ; get sound bits value
   lsr                              ; shift D0 to carry bit
   bcc .checkToSetVolumeForUFO
   lda soundVolume1Index            ; get sound volume 1 index
   lsr                              ; divide value by 2
   sta AUDV1                        ; set volume value for audio channel 1
.donePlayGameSounds
   rts

.turnOffVolumeChannel1
   lda #0
   sta AUDV1
   sta soundVolume1Index
   rts

.checkToSetVolumeForUFO
   lda gameState                    ; get current game state
   and #UFO_BOMBS                   ; keep UFO_BOMBS flag
   beq .turnOffVolumeChannel1       ; branch if UFO_BOMBS not active
   lda soundVolume1Index
   lsr
   and #7
   clc
   adc #4
   sta AUDV1
   rts

ScoreBCDToDigits
   lda #0
   sta suppressZeroValue
   ldx #<digitPlayfieldGraphPtrs
   lda playerScore                  ; get player score thousands value
   jsr DetermineDigitLSBValue
   jsr PF0LSBBCDToDigit
   lda playerScore + 1
   jsr DetermineDigitMSBValue
   jsr PF1MSBBCDToDigit
   lda playerScore + 1
   jsr DetermineDigitLSBValue
   jsr PF1LSBBCDToDigit
   lda playerScore + 2
   jsr DetermineDigitMSBValue
   jsr PF2MSBBCDToDigit
   lda playerScore + 2
   jsr DetermineDigitLSBValue
   jmp PF2LSBBCDToDigit
   
LaserBaseBCDToDigits
   lda #0
   sta suppressZeroValue
   ldx #<numOfBasesPF1GraphPtr
   lda numberOfLaserBases           ; get number of remaining laser bases
   jsr DetermineDigitMSBValue
   jsr MultiplyBy5Div16
   jsr OffsetForNumberFonts_0
   lda numberOfLaserBases           ; get number of remaining laser bases
   and #$0F
   jsr MultiplyBy5
   jmp OffsetForNumberFonts_2
   
DetermineDigitMSBValue
   and #$F0                         ; mask lower nybbles
   bne .decrementSuppressZeroValue
   bit suppressZeroValue
   bmi .doneDetermineDigitValue
   lda #<blankNumberFonts_2
   rts

DetermineDigitLSBValue
   and #$0F                         ; mask upper nybbles
   bne .decrementSuppressZeroValue
   bit suppressZeroValue
   bmi .doneDetermineDigitValue
   lda #<twoNumberFonts_0
.doneDetermineDigitValue
   rts

.decrementSuppressZeroValue
   dec suppressZeroValue
   rts

PF1LSBBCDToDigit
   jsr MultiplyBy5
OffsetForNumberFonts_0
   adc #<NumberFonts_0
   sta VSYNC,x
   inx
   inx
   rts

PF2LSBBCDToDigit
PF0LSBBCDToDigit
   jsr MultiplyBy5
   adc #<NumberFonts_3
   sta VSYNC,x
   inx
   inx
   rts

MultiplyBy5
   sta temp                         ; save original value
   asl                              ; multiply value by 4
   asl
   adc temp                         ; add in original so it's multiplied by 5
   rts                              ; [i.e. x * 5 = (x * 4) + x]

PF1MSBBCDToDigit
   jsr MultiplyBy5Div16
   adc #<NumberFonts_1
   sta VSYNC,x
   inx
   inx
   rts

PF2MSBBCDToDigit
   jsr MultiplyBy5Div16
OffsetForNumberFonts_2
   adc #<NumberFonts_2
   sta VSYNC,x
   inx
   inx
   rts

MultiplyBy5Div16
   lsr                              ; divide the value by 4
   lsr
   sta temp                         ; save the value for later
   lsr                              ; divide the value by 16
   lsr
   adc temp                         ; add in original so it's multiplied by
   rts                              ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]

IncrementScore
   sed                              ; set decimal mode
   sta points
   lda playerScore                  ; get player score thousands value
   cmp #$99                         ; see if it's at least 990,000
   beq .checkToSetNewPeakScore
   ldy gameLevel
   lda #$00
.incrementScoreLoop
   adc points
   dey
   bpl .incrementScoreLoop
   adc playerScore + 2              ; increment player score tens value
   sta playerScore + 2              ; set new score tens value
   lda playerScore + 1              ; get player score hundreds value
   adc #$00
   sta playerScore + 1              ; increment score hundreds value
   lda playerScore                  ; get player score thousands value
   adc #$00
   sta playerScore                  ; increment score thousands value
   jsr DetermineGameLevel
   lda playerScore + 1              ; get player hundreds value
   beq CheckToIncrementNumberOfBases
   cmp peakScore+1
   beq .checkToSetNewPeakScore
   bcc .checkToSetNewPeakScore
.incrementNumberOfBases
   lda numberOfLaserBases           ; get number of remaining laser bases
   clc
   adc #1                           ; increment number of laser bases by 1
   bcs .checkToSetNewPeakScore
   sta numberOfLaserBases           ; set new number of remaining laser bases
   cld                              ; clear decimal mode
   jsr LaserBaseBCDToDigits
   jmp .checkToSetNewPeakScore
   
CheckToIncrementNumberOfBases
   lda peakScore + 1                ; get peak score hundreds value
   cmp #$99
   beq .incrementNumberOfBases
.checkToSetNewPeakScore
   lda playerScore                  ; get player score thousands value
   cmp peakScore                    ; compare with peak score thousands value
   bcc .doneIncrementScore          ; branch if thousands value didn't reach peak value
   bne .setNewPeakScore
   lda playerScore + 1              ; get player score hundreds value
   cmp peakScore + 1                ; compare with peak score hundreds value
   bcc .doneIncrementScore          ; branch if hundreds value didn't reach peak value
   bne .setNewPeakScore
   lda playerScore + 2              ; get player score tens value
   cmp peakScore + 2                ; compare with peak score tens value
   bcc .doneIncrementScore          ; branch if tens value didn't reach peack value
   beq .doneIncrementScore
.setNewPeakScore
   lda playerScore
   sta peakScore
   lda playerScore + 1
   sta peakScore + 1
   lda playerScore + 2
   sta peakScore + 2
.doneIncrementScore
   cld                              ; clear decimal mode
   rts

DecrementScore
   sed                              ; set decimal mode
   lsr                              ; divide value by 2
   bcs .checkToSetOnesDigitToZero
   sta points
   ldy gameLevel
.computeScoreDecrementValue
   lda #$00
   clc
.computeScoreDecrementLoop
   adc points
   dey
   bpl .computeScoreDecrementLoop
   sta points                       ; set score decrement value
   lda playerScore + 2              ; get score tens value
   sec
   sbc points                       ; subtract decrement value
   sta playerScore + 2
   lda playerScore + 1
   sbc #$00
   sta playerScore + 1
   lda playerScore
   sbc #$00
   sta playerScore
   bcs .doneDecrementScore          ; branch if the score didn't go negative
   lda #$00                         ; set player's score to zero
   sta playerScore
   sta playerScore + 1
   sta playerScore + 2
   lda #<zeroNumberFonts_3
   sta rightPF0DigitPointer
.doneDecrementScore
   cld                              ; clear decimal mode
DetermineGameLevel
   bit SWCHB                        ; check difficulty settings
   bpl .determineGameLevelForAmateur; branch if right difficulty set to AMATEUR
   lda #4
   sta gameLevel                    ; set to highest game level
   rts

.determineGameLevelForAmateur
   lda #4
   sta gameLevel                    ; set to highest game level
   lda playerScore                  ; get player's score thousands value
   cmp #$01
   bcs .doneDetermineGameLevel      ; branch if score greater than 10,000
   lda playerScore + 1              ; get player's score hundreds value
   cmp #$50
   bcs .doneDetermineGameLevel      ; branch if score greater than 5,000
   dec gameLevel                    ; reduce game level
   cmp #$20
   bcs .doneDetermineGameLevel      ; branch if score greater than 2,000
   dec gameLevel                    ; reduce game level
   cmp #$05
   bcs .doneDetermineGameLevel      ; branch if score greater than 500
   dec gameLevel                    ; reduce game level
   cmp #$01
   bcs .doneDetermineGameLevel      ; branch if score greater than 100
   dec gameLevel                    ; reduce game level
.doneDetermineGameLevel
   rts

.checkToSetOnesDigitToZero
   lda #$01
   sta points
   lda gameLevel                    ; get current game level
   lsr                              ; divide value by 2
   tay
   bcs .computeScoreDecrementValue  ; branch if game level is odd
   lda #<zeroNumberFonts_3
   cmp rightPF0DigitPointer
   beq .setOnesDigitToFive
   sta rightPF0DigitPointer         ; set right PF0 digit to point to "0"
   dey
   bpl .computeScoreDecrementValue
   cld
   rts

.setOnesDigitToFive
   lda #<fiveNumberFonts_3          ; set right PF0 digit to point to "5"
   sta rightPF0DigitPointer
   bne .computeScoreDecrementValue  ; unconditional branch
   
DetermineControllerType
   lda #DUMP_PORTS | DISABLE_TIA
   sta VBLANK
   ldx #0
.waitForCapacitorCharge
   bit INPT0                        ; check paddle 0 value
   bpl .continueDetermineControllerType; branch if capacitor not charged
   dex
   bne .waitForCapacitorCharge
   beq .setControllerTypeToPaddles  ; unconditional branch
   
.continueDetermineControllerType
   lda #DISABLE_TIA
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   ldx #32                          ; wait ~538 scanlines (i.e. ~2 frames)
.outerLoopWait
   ldy #0
.innerLoopWait
   iny
   bne .innerLoopWait
   dex
   bne .outerLoopWait
   bit INPT0                        ; check paddle 0 value
   bpl .doneDetermineControllerType ; branch if capacitor not charged
.setControllerTypeToPaddles
   lda gameState                    ; get current game state value
   ora #USING_PADDLES
   sta gameState                    ; set game state to USING_PADDLES
.doneDetermineControllerType
   rts

SetupKernelForPaddles
   bit gameState                    ; check current game state value
   bvc .doneDetermineControllerType ; branch if USING_JOYSTICKS
   lda #H_KERNEL
   sta paddleValue
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry bit
   lda #DISABLE_TIA
   bcs .oddFrameSetupKernelForPaddles; branch if an odd frame
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta WSYNC                        ; wait for next scan line
   sta WSYNC                        ; wait for next scan line
   rts

.oddFrameSetupKernelForPaddles
   sta WSYNC                        ; wait for 3 scan lines
   sta WSYNC
   sta WSYNC
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   rts

DetermineBasePositionForPaddles
   bit gameState                    ; check current game state value
   bvc .doneDetermineControllerType ; branch if USING_JOYSTICKS
   lda #DUMP_PORTS | DISABLE_TIA
   sta VBLANK
   lda frameCount                   ; get current frame count
   and #1                           ; keep D0 value
   asl                              ; shift D0 to carry bit
   adc paddleValue
   ldx previousPaddleValue
   sta previousPaddleValue          ; set previous paddle value to current
   cpx previousPaddleValue
   bcc .checkLaserBaseHorizLimits
   txa                              ; move previous paddle value to accumulator
.checkLaserBaseHorizLimits
   cmp #XMIN
   bcc .laserBaseReachedLeftLimit
   cmp #XMAX
   bcc .setLaserBaseNewHorizontalPosition
   lda #XMAX
   bne .setLaserBaseNewHorizontalPosition;unconditional branch
   
.laserBaseReachedLeftLimit
   lda #XMIN - 2
.setLaserBaseNewHorizontalPosition
   ldx #ID_LASER_BASE
   sta objectHorizPositions,x
   jmp CalculateHorizontalPosition
   
DetermineToLaunchUFO
   and #UFO_BOMBS                   ; keep UFO_BOMBS flags
   beq CheckToLaunchUFO             ; branch if UFO_BOMBS not active
   lda gameState                    ; get current game state
   and #UFO_ACTIVE                  ; keep UFO_ACTIVE flag
   bne .ufoLaunched                 ; branch if UFO_ACTIVE
   jsr DetermineHighestObjectOffsetValue
   bne .doneDetermineToLaunchUFO
   lda gameState                    ; get current game state
   ora #UFO_ACTIVE                  ; set UFO_ACTIVE flag
   sta gameState
.ufoLaunched
   lda frameCount                   ; get current frame count
   and #$0E
   bne .doneDetermineToLaunchUFO
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 8
   lsr
   lsr
   lsr
   and #3                           ; make value 0 <= a <= 3
   tax
   inx                              ; increment x (i.e. 1 <= x <= 4)
   lda playerOffsetValues,x
   bne .doneDetermineToLaunchUFO    ; branch if obstacle is active
   lda #UFO_BOMB_INIT_VERT_POS
   sta playerOffsetValues,x         ; set UFO bomb vertical position
   lda playerHorizValues            ; get UFO horizontal position
   sta playerHorizValues,x          ; set UFO bomb horizontal position value
   lda objectHorizPositions         ; get UFO horizontal position value
   sta objectHorizPositions,x       ; set UFO bomb horizontal position
   lda #<(UFOBombSprite_0 + H_UFO_BOMB - UFO_BOMB_INIT_VERT_POS)
   sta playerGraphicLSBValues,x     ; set UFO bomb graphic LSB value
   lda #WHITE | 1
   sta playerColorValues,x          ; color UFO bomb
   lda objectHorizPositions         ; get UFO horizontal position
   lsr                              ; divide value by 2
   sta tempUFOHorizPosition
   lda laserBaseHorizPosition       ; get laser base horizontal position
   lsr                              ; divide horizontal position by 2
   sec
   sbc tempUFOHorizPosition         ; subtract UFO horizontal position from laser base
   bcs DetermineUFOBombVelocity     ; branch if laser base to the right of UFO
   cmp #<-28
   bcs .contDetermineUFOBombVelocity
   lda #<-28
   jmp .contDetermineUFOBombVelocity
   
DetermineUFOBombVelocity
   cmp #28
   bcc .contDetermineUFOBombVelocity
   lda #(VELOCITY_STATIONARY - 1) << 2
.contDetermineUFOBombVelocity
   asl                              ; multiply value by 4
   asl
   and #VELOCITY_HORIZ_MASK         ; keep horizontal velocity value
   ora #VELOCITY_STATIONARY - 4
   sta objectVelocity,x             ; set object's velocity
.doneDetermineToLaunchUFO
   rts

CheckToLaunchUFO
   jsr DetermineHighestObjectOffsetValue
   cmp #10
   bcs .doneDetermineToLaunchUFO
   lda playerOffsetValues           ; get top object offset value
   bne .doneDetermineToLaunchUFO    ; branch if object is active
   jsr NextRandom                   ; get new random number
   and #8
   bne .launchUFOFromLeft
   lda #XMAX + 2
   sta objectHorizPositions
   lda #HMOVE_R4 | 10
   sta playerHorizValues
   lda #(VELOCITY_STATIONARY + 3) << 4 | VELOCITY_STATIONARY
   sta objectVelocity
   jmp .continueLaunchUFO
   
.launchUFOFromLeft
   lda #XMIN - 1
   sta objectHorizPositions
   lda #HMOVE_L6 | 1
   sta playerHorizValues
   lda #(VELOCITY_STATIONARY - 4) << 4 | VELOCITY_STATIONARY
   sta objectVelocity               ; set UFO velocity
.continueLaunchUFO
   lda #UFO_VERT_POS
   sta playerOffsetValues           ; set UFO vertical position
   lda #WHITE - 2
   sta playerColorValues
   lda #<(UFOGraphics_0 + H_UFO - 1 - UFO_VERT_POS)
   sta playerGraphicLSBValues
   lda gameState                    ; get current game state
   and #<(~UFO_ACTIVE)              ; mask UFO_ACTIVE flag
   ora #UFO_BOMBS                   ; set UFO_BOMBS flag
   sta gameState
   jmp SetUFOSoundIndicators
   
CheckToSpawnUFO
   bit gameState                    ; check current game state value
   bmi .doneDetermineToLaunchUFO    ; branch if GAME_OVER
   lda gameLevel                    ; get current game level
   cmp #3
   bcc .doneDetermineToLaunchUFO    ; don't spawn UFO if level is less than 3
   jsr NextRandom                   ; get new random number
   and #$3F
   bne .doneDetermineToLaunchUFO
   lda gameState                    ; get current game state
   ora #UFO_ACTIVE                  ; set UFO_ACTIVE flag
   sta gameState
   rts

DetermineHighestObjectOffsetValue
   lda #0
   sta tempHighestOffsetValue
   ldx #4
.determineHighestObjectOffsetValue
   lda playerColorValues,x          ; get object color value
   cmp #WHITE - 2
   beq .nextObject                  ; branch if object is UFO
   lda playerOffsetValues,x         ; get object offset value
   cmp tempHighestOffsetValue       ; compare with highest offset value
   bcc .nextObject
   sta tempHighestOffsetValue
.nextObject
   dex
   bpl .determineHighestObjectOffsetValue
   lda tempHighestOffsetValue
   rts

   FILL_BOUNDARY 0, -1
   
GameSprites_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BigRock_0
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $7B ; |.XXXX.XX|
   .byte $FE ; |XXXXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $3C ; |..XXXX..|
   .byte $3A ; |..XXX.X.|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SmallRock_0
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $38 ; |..XXX...|
   .byte $2C ; |..X.XX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
LaserDefenseBase_0
UFOGraphics_0
   .byte $00 ; |........|
   .byte $7F ; |.XXXXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MissileSprite_0
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerSprites_0
SpinnerAnimation0_0
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation1_0
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $34 ; |..XX.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $16 ; |...X.XX.|
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation2_0
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation3_0
   .byte $00 ; |........|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $2C ; |..X.XX..|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $68 ; |.XX.X...|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Pulsar_0
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
UFOBombSprite_0
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|

   FILL_BOUNDARY 0, -1
   
GameSprites_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BigRock_1
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $6C ; |.XX.XX..|
   .byte $EE ; |XXX.XXX.|
   .byte $7B ; |.XXXX.XX|
   .byte $FE ; |XXXXXXX.|
   .byte $3F ; |..XXXXXX|
   .byte $6E ; |.XX.XXX.|
   .byte $6E ; |.XX.XXX.|
   .byte $3C ; |..XXXX..|
   .byte $3A ; |..XXX.X.|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SmallRock_1
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $38 ; |..XXX...|
   .byte $2C ; |..X.XX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
LaserDefenseBase_1
UFOGraphics_1
   .byte $00 ; |........|
   .byte $7F ; |.XXXXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $7F ; |.XXXXXXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $2A ; |..X.X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MissileSprite_1
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerSprites_1
SpinnerAnimation0_1
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation1_1
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $34 ; |..XX.X..|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $16 ; |...X.XX.|
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation2_1
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SpinnerAnimation3_1
   .byte $00 ; |........|
   .byte $14 ; |...X.X..|
   .byte $14 ; |...X.X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $2C ; |..X.XX..|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $68 ; |.XX.X...|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Pulsar_1
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
UFOBombSprite_1
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|

   FILL_BOUNDARY 0, -1
   
NumberFonts
NumberFonts_0
zeroNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
oneNumberFonts_0
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
twoNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
threeNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
fourNumberFonts_0
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $05 ; |.....X.X|
fiveNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $07 ; |.....XXX|
sixNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $04 ; |.....X..|
   .byte $07 ; |.....XXX|
sevenNumberFonts_0
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
eightNumberFonts_0
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
nineNumberFonts_0
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $05 ; |.....X.X|
   .byte $07 ; |.....XXX|
blankNumberFonts_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
NumberFonts_1
zeroNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
oneNumberFonts_1
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
twoNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
threeNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
fourNumberFonts_1
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
fiveNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
sixNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $40 ; |.X......|
   .byte $70 ; |.XXX....|
sevenNumberFonts_1
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
eightNumberFonts_1
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
nineNumberFonts_1
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $50 ; |.X.X....|
   .byte $70 ; |.XXX....|
blankNumberFonts_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
NumberFonts_2
zeroNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
oneNumberFonts_2
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
twoNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
threeNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
fourNumberFonts_2
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
fiveNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
sixNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
   .byte $02 ; |......X.|
   .byte $0E ; |....XXX.|
sevenNumberFonts_2
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
eightNumberFonts_2
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
nineNumberFonts_2
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
blankNumberFonts_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
NumberFonts_3
zeroNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
oneNumberFonts_3
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
twoNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
threeNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
fourNumberFonts_3
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $A0 ; |X.X.....|
fiveNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
sixNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $E0 ; |XXX.....|
sevenNumberFonts_3
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
eightNumberFonts_3
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
nineNumberFonts_3
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $E0 ; |XXX.....|
   .byte $A0 ; |X.X.....|
   .byte $E0 ; |XXX.....|
blankNumberFonts_3
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
NextRandom
   lda randomSeed
   asl
   asl
   asl
   asl
   clc
   adc randomSeed
   asl
   asl
   asl
   clc
   adc randomSeed
   clc
   adc #149
   sta randomSeed
   eor frameCount
   rts

   FILL_BOUNDARY 250, -1            ; push to the RESET vector (this was done instead
                                    ; of using an .ORG to easily keep track of free ROM)
                                    
   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"

   .word Start                      ; IRQ/NMI vector
   .word Start                      ; START vector
   .word Start                      ; BRK vector