   LIST OFF
; ***  G A M M A  -  A T T A C K  ***
; Copyright 1983, Gammation
; Designer: Robert L. Esken, Jr.
;
; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: December 28, 2023
;
;  *** 125 BYTES OF RAM USED 3 BYTES FREE
;  ***   0 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1983, GAMMATION                                    =
; =                                                                            =
; ==============================================================================

   processor 6502
   
;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $00         ; set the read address base so this runs on
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
PAL60                   = 2

TRUE                    = 1
FALSE                   = 0

;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 79
H_OVERSCAN              = 20

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

COLOR_MOUNTAIN          = RED
COLOR_TANK              = BLACK
COLOR_GROUND            = RED + 8
COLOR_SKY               = COBALT_BLUE + 2
COLOR_SAUCER            = RED_ORANGE + 12
COLOR_SAUCER_LASER      = WHITE + 1
COLOR_HIT_SAUCER        = RED + 14

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_KERNEL                = 74
H_COPYRIGHT_FONT        = 7
H_SCORE_BOARD_FONT      = 5
H_MOUNTAIN_TERRAIN      = 7

XMIN                    = 1
XMAX                    = 72

INIT_SAUCER_HORIZ_POS   = 56
INIT_SAUCER_VERT_POS    = 16

INIT_OBJECT_HIT_TIMER   = 31

MAX_GAME_SELECTION      = 4

MOUNTAIN_ARRAY_SIZE     = 24

SELECT_DELAY            = 62
;
; Mountain scrolling constants
;
MOUNTAIN_SCROLL_DIR_LEFT = $80
MOUNTAIN_SCROLL_DIR_NONE = 0
MOUNTAIN_SCROLL_DIR_RIGHT = $7F
;
; Tank speed constants
;
TANK_SLOW_VELOCITY      = 1
TANK_MEDIUM_VELOCITY    = 2
TANK_FAST_VELOCITY      = 3

TANK_SCROLL_SPEED       = 2
;
; Tank position constants
;
VERT_POSITION_TANK_00   = 48
VERT_POSITION_TANK_01   = 54
VERT_POSITION_TANK_02   = 60
VERT_POSITION_TANK_03   = 67
;
; object ids
;
ID_SAUCER_LASER         = 0
ID_SAUCER               = 1
ID_TANK_MISSILE         = 2
ID_TANK_00              = 3
ID_TANK_01              = 4
ID_TANK_02              = 5
ID_TANK_03              = 6

;===============================================================================
; M A C R O S
;===============================================================================

   MAC SLEEP_3
   
      lda frameCount + 1

   ENDM

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

gameSelection           ds 1
currentRack             ds 1
actionButtonDebounce    ds 1
mountainScrollDirection ds 1
remainingTanks          ds 1
saucerHoveringLimit     ds 1
currentGameSpeed        ds 1
frameCount              ds 2
tankVelocity            ds 1
tmpObjectIndex          ds 1
;--------------------------------------
tmpTankIndex            = tmpObjectIndex
objectScanlineValues    ds 14
kernelZoneVectorLSBValues ds 11

zp_unused_00            ds 3

tmpScoreBoardIndex      ds 1
;--------------------------------------
tmpKernelZoneIndex      = tmpScoreBoardIndex
tmpMountainGraphicIndex ds 1
;--------------------------------------
tmpScoreBoardDigitIdx   = tmpMountainGraphicIndex
;--------------------------------------
tmpSavedObjectIndex     = tmpScoreBoardDigitIdx
scoreBoardPF1Graphics   ds 5
scoreBoardPF2Graphics   ds 5
playerScore             ds 2 
;--------------------------------------
playerScoreHundredsValue = playerScore
playerScoreOnesValue    = playerScoreHundredsValue + 1
objectFineMotionValues  ds 7
;--------------------------------------
saucerLaserFineMotionValue = objectFineMotionValues
saucerFineMotionValue   = objectFineMotionValues + 1
tankMissileFineMotionValue = objectFineMotionValues + 2
tankFineMotionValues    = objectFineMotionValues + 3
;--------------------------------------
tankFineMotionValue_00  = tankFineMotionValues
tankFineMotionValue_01  = tankFineMotionValue_00 + 1
tankFineMotionValue_02  = tankFineMotionValue_01 + 1
tankFineMotionValue_03  = tankFineMotionValue_02 + 1
objectCoarsePositionValues ds 7
;--------------------------------------
saucerLaserCoarsePosValue = objectCoarsePositionValues
saucerCoarsePosValue    = objectCoarsePositionValues + 1
tankMissileCoarsePosValue = objectCoarsePositionValues + 2
tankCoarsePositionValues = objectCoarsePositionValues + 3
;--------------------------------------
tankCoarsePosition_00   = tankCoarsePositionValues
tankCoarsePosition_01   = tankCoarsePosition_00 + 1
tankCoarsePosition_02   = tankCoarsePosition_01 + 1
tankCoarsePosition_03   = tankCoarsePosition_02 + 1
objectHorizontalPositions ds 7
;--------------------------------------
saucerLaserHorizPosition = objectHorizontalPositions
saucerHorizPosition     = objectHorizontalPositions + 1
tankMissileHorizPosition = objectHorizontalPositions + 2
tankHorizPositions      = objectHorizontalPositions + 3
;--------------------------------------
tankHorizPosition_00    = tankHorizPositions
tankHorizPosition_01    = tankHorizPosition_00 + 1
tankHorizPosition_02    = tankHorizPosition_01 + 1
tankHorizPosition_03    = tankHorizPosition_02 + 1
gameState               ds 1
objectVerticalPositions ds 7
;--------------------------------------
saucerLaserIndex        = objectVerticalPositions
saucerVerticalPosition  = objectVerticalPositions + 1
tankMissileVerticalPosition = objectVerticalPositions + 2
tankVerticalPositions   = objectVerticalPositions + 3
;--------------------------------------
tankVertPosition_00     = tankVerticalPositions
tankVertPosition_01     = tankVertPosition_00 + 1
tankVertPosition_02     = tankVertPosition_01 + 1
tankVertPosition_03     = tankVertPosition_02 + 1
tankMissileSoundVolume  ds 1
objectSpriteLSBValues   ds 7
;--------------------------------------
saucerLaserSpriteLSBValue = objectSpriteLSBValues
saucerSpriteLSBValue    = objectSpriteLSBValues + 1
tankMissileLSBValue     = objectSpriteLSBValues + 2
tankSpriteLSBValues     = objectSpriteLSBValues + 3
;--------------------------------------
tankSpriteLSBValue_00   = tankSpriteLSBValues
tankSpriteLSBValue_01   = tankSpriteLSBValue_00 + 1
tankSpriteLSBValue_02   = tankSpriteLSBValue_01 + 1
tankSpriteLSBValue_03   = tankSpriteLSBValue_02 + 1
activateSaucerLaserDisplay ds 1
activeTankIndex         ds 1
objectHitTimer          ds 1
objectColorValues       ds 5
;--------------------------------------
colorTank               = objectColorValues
;--------------------------------------
colorCopyrightBackground = colorTank
colorGround             = objectColorValues + 1
colorSky                = objectColorValues + 2
colorSaucer             = objectColorValues + 3
colorSaucerLaser        = objectColorValues + 4
;--------------------------------------
colorCopyright          = colorSaucerLaser
mountainPlayfieldGraphics ds MOUNTAIN_ARRAY_SIZE
;--------------------------------------
mountainPF0Graphics     = mountainPlayfieldGraphics
mountainPF1Graphics     = mountainPF0Graphics + 8
mountainPF2Graphics     = mountainPF1Graphics + 8
tmpScoreBoardGraphics   ds 4
;--------------------------------------
tmpScoreBoardPF1Graphics = tmpScoreBoardGraphics
tmpScoreBoardPF2Graphics = tmpScoreBoardPF1Graphics + 2
;--------------------------------------
tmpKernelJmpVectors     = tmpScoreBoardGraphics
;--------------------------------------
tmpKernelZoneVector     = tmpKernelJmpVectors
tmpCoarsePositionVector = tmpKernelZoneVector + 2
;--------------------------------------
tmpAdjustedHorizPos     = tmpScoreBoardGraphics
;--------------------------------------
tankMissileGraphicIdx   ds 1
scanline                ds 1

   echo "***",(* - $80 - 3)d, "BYTES OF RAM USED", ($100 - * + 3)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E
;===============================================================================

   SEG code
   .org ROM_BASE

Start
   sei
   cld
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   lda #$10
   sta SWBCNT                       ; set D4 of SWCHB as output
   lda #128
   sta frameCount
   lda #1
   sta gameSelection                ; set initial game selection
   sta playerScoreOnesValue         ; set to display initial game selection
ResetGame
   lda #INIT_SAUCER_HORIZ_POS
   sta saucerSpriteLSBValue
   sta saucerHorizPosition          ; set Saucer horizontal position
   adc #4
   sta saucerLaserHorizPosition     ; set Saucer laser horizontal position
   ldx #MOUNTAIN_ARRAY_SIZE - 1
.setInitialMountainGraphicValues
   lda InitMountainGraphics,x
   sta mountainPlayfieldGraphics,x
   dex
   bpl .setInitialMountainGraphicValues
   ldx #4
   stx remainingTanks
.setInitialObjectColorValues
   lda InitObjectColors,x
   sta objectColorValues,x
   dex
   bpl .setInitialObjectColorValues
   ldy #<[OffScreenSprite - SpriteGraphics]
   ldx #<[tankMissileHorizPosition - objectHorizontalPositions]
.setInitialTankValues
   sty objectSpriteLSBValues,x
   adc #8
   sta objectHorizontalPositions,x
   inx
   cpx #8
   bne .setInitialTankValues
   lda #INIT_SAUCER_VERT_POS
   sta saucerVerticalPosition
   sta saucerHoveringLimit
   lda #0
   sta playerScoreHundredsValue     ; initialize score hundreds value
NewFrame
   lda #DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; disable TIA (i.e. D1 = 1)
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC                        ; start vertical sync (i.e. D1 = 1)
   sta CTRLPF                       ; set to PF_SCORE
   lda #0
   inc frameCount + 1               ; increment frame count
   bpl .verticalSync
   inc frameCount
   sta frameCount + 1
.verticalSync
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC                        ; end vertical sync (i.e. D1 = 0)     
   sta activateSaucerLaserDisplay   ; clear Saucer laser display value
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   ldx #$FF
   txs                              ; set stack to the beginning
   jsr PerformGameCalculations
   lda colorSaucer
   sta COLUP1
   sta CXCLR
   sta $2E                          ; not needed
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   sta WSYNC
;--------------------------------------
   sta scanline               ; 3
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   sta PF1                    ; 3 = @06
   sta PF2                    ; 3 = @09
   tax                        ; 2
   lda objectHitTimer         ; 3         get object hit timer value
   and #2                     ; 2
   beq .setNormalSkyColor     ; 2³
   lda colorSaucerLaser       ; 3
   bne .setSkyBackgroundColor ; 3         unconditional branch
    
.setNormalSkyColor
   lda colorSky               ; 3
.setSkyBackgroundColor
   sta COLUP0                 ; 3 = @27   set to hide left side score values
   sta COLUBK                 ; 3 = @30
.drawScoreBoardKernel
   lda scoreBoardPF1Graphics,x; 4
   sta PF1                    ; 3 = @37
   lda scoreBoardPF2Graphics,x; 4
   sta PF2                    ; 3 = @44
   inx                        ; 2
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   lda scanline               ; 3         get current scan line count
   clc                        ; 2
   adc #2                     ; 2
   sta scanline               ; 3         increment by 2 (i.e. 2LK)
   cpx #H_SCORE_BOARD_FONT    ; 2
   bne .drawScoreBoardKernel  ; 2³
   lda #0                     ; 2
   sta PF1                    ; 3 = @19
   sta PF2                    ; 3 = @22
   sta CTRLPF                 ; 3 = @25
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   tay                        ; 2
   sta tmpKernelZoneIndex     ; 3
   sta tankMissileGraphicIdx  ; 3
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @03
   lda colorSaucerLaser       ; 3
   sta COLUP1                 ; 3 = @09
   lda #$EE                   ; 2
   sta tmpMountainGraphicIndex; 3         any value greater than 127
   lda #>CoarsePositionObject ; 2
   sta tmpCoarsePositionVector + 1;3
   lda #>KernelSetupRoutines  ; 2
   sta tmpKernelZoneVector + 1; 3
   bne .checkKernelZoneDone   ; 3 + 1     crosses page boundary
    
NextKernelZone
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   inc tmpKernelZoneIndex     ; 5
.nextKernelZone
   lda SpriteGraphics,y       ; 4         get GRP0 graphic data
   sta GRP0                   ; 3 = @07
   beq .drawMountainTerrain   ; 2³        branch if done drawing GRP0
   iny                        ; 2         increment GRP0 graphic index
.drawMountainTerrain
   lda scanline               ; 3         get scan line count
   and #3                     ; 2         0 <= a <= 3
   bne .incrementScanline     ; 2³
   ldx tmpMountainGraphicIndex; 3
   bmi .incrementScanline     ; 2³        branch if done drawing mountains
   lda mountainPF0Graphics,x  ; 4
   sta PF0                    ; 3 = @30
   lda mountainPF1Graphics,x  ; 4
   sta PF1                    ; 3 = @37
   lda mountainPF2Graphics,x  ; 4
   sta PF2                    ; 3 = @44
   lda MountainColorValues,x  ; 4
   clc                        ; 2
   adc colorTank              ; 3
   sta COLUPF                 ; 3 = @56
   dec tmpMountainGraphicIndex; 5
.incrementScanline
   inc scanline               ; 5         increment scan line count
   ldx tankMissileGraphicIdx  ; 3         get Tank missile graphic index
   sta HMCLR                  ; 3 = @72
   lda activateSaucerLaserDisplay;3       get Saucer laser activation value
   beq .tankMissileScanline   ; 2³        branch if not drawing Saucer laser
;--------------------------------------
   lda #HMOVE_L2              ; 2
   sta HMM1                   ; 3 = @06   shift Saucer laser left 2 pixels
.tankMissileScanline
   sta WSYNC
;--------------------------------------
   lda SpriteGraphics,y       ; 4         get GRP0 graphic data
   sta GRP0                   ; 3 = @07
   beq .checkToDrawTankMissile; 2³        branch if done drawing GRP0
   iny                        ; 2         increment GRP0 graphic index
.checkToDrawTankMissile
   lda TankMissileSprite,x    ; 4         get Tank missile graphic data
   sta GRP1                   ; 3 = @18
   beq .setTankMissileGraphicIndex;2³     branch if done drawing Tank missile
   inx                        ; 2         increment Tank missile graphic index
.setTankMissileGraphicIndex
   stx tankMissileGraphicIdx  ; 3
.checkKernelZoneDone
   ldx tmpKernelZoneIndex     ; 3
   lda objectScanlineValues,x ; 4         get zone scan line value
   beq .checkToDrawCopyrightKernel;2³
   cmp scanline               ; 3
   bpl .nextScanline          ; 2³
   lda kernelZoneVectorLSBValues,x;4
   sta tmpKernelZoneVector    ; 3
   jmp (tmpKernelZoneVector)  ; 5 = @51
    
.checkToDrawCopyrightKernel
   lda #H_KERNEL              ; 2
   cmp scanline               ; 3
   bne .nextScanline          ; 2³
   lda colorCopyrightBackground;3
   sta COLUBK                 ; 3
   sta WSYNC
;--------------------------------------
   lda #MSBL_SIZE1 | TWO_COPIES;2
   sta NUSIZ0                 ; 3 = @05
   sta NUSIZ1                 ; 3 = @08
   lda colorCopyright         ; 3
   sta COLUP0                 ; 3 = @14
   ldx #DISABLE_BM            ; 2
   stx ENAM1                  ; 3 = @19
   ldy #8                     ; 2
   sta WSYNC
;--------------------------------------
.coarsePositionCopyrightSprites
   dey                        ; 2
   bne .coarsePositionCopyrightSprites;2³
   sta RESP0                  ; 3 = @47
   sta RESP1                  ; 3 = @50
.drawCopyrightKernel
   ldy #4                     ; 2
   sta WSYNC
;--------------------------------------
.copyrightDelay
   dey                        ; 2
   bne .copyrightDelay        ; 2³
   lda CopyrightFont_00,x     ; 4
   sta GRP0                   ; 3 = @26
   lda CopyrightFont_01,x     ; 4
   sta GRP1                   ; 3 = @33 
   lda CopyrightFont_02,x     ; 4
   ldy CopyrightFont_03,x     ; 4
   SLEEP 2                    ; 2
   sta GRP0                   ; 3 = @46
   sty GRP1                   ; 3 = @49
   inx                        ; 2
   cpx #H_COPYRIGHT_FONT      ; 2
   bne .drawCopyrightKernel   ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @60
   sta GRP1                   ; 3 = @63
   ldx #H_OVERSCAN            ; 2
.overscan
   sta WSYNC
   dex
   bne .overscan
   jmp NewFrame
    
.nextScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jmp .nextKernelZone        ; 3
    
PerformGameCalculations
   lda frameCount + 1               ; get current frame count
   and #1
   beq ProcessUserInputs            ; branch on even frames
   jmp CheckSaucerLaserCollisionWithTank
    
ProcessUserInputs
   lda SWCHB                        ; read console switches
   ror                              ; shift RESET value to carry
   bcs .checkForSelectPressed       ; branch if RESET not pressed
   lda gameState                    ; get current game state
   bne .checkToCycleColors          ; branch if game in progress
   lda #1
   sta frameCount
   sta gameState                    ; set to show game in progress
   lda #0
   sta currentRack                  ; reset current rack
   sta playerScoreOnesValue         ; initialize score ones value
   lda gameSelection                ; get current game selection
   sta currentGameSpeed
   jmp ResetGame
    
.checkForSelectPressed
   ldx #0
   stx gameState                    ; clear current game state
   ror                              ; shift SELECT value to carry
   bcs .checkToCycleColors          ; branch if SELECT not pressed
   lda frameCount + 1               ; get current frame count
   and #SELECT_DELAY
   cmp #SELECT_DELAY
   bne .checkToCycleColors
   lda #128
   sta frameCount
   lda #0
   sta playerScoreHundredsValue     ; initialize score hundreds value
   inc gameSelection                ; increment game selection value
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION + 1
   bne .setToDisplayCurrentGameSelection
   lda #1
   sta gameSelection                ; wrap to initial game selection value
.setToDisplayCurrentGameSelection
   sta playerScoreOnesValue
.checkToCycleColors
   lda frameCount
   and #$80                         ; a == 0 || a == 128
   beq .checkToAnimateSaucer
   lda #128
   sta frameCount
   lda frameCount + 1               ; get current frame count
   bne .checkToAnimateSaucer
   ldx #4
.cycleObjectColors
   inc objectColorValues,x          ; increment object color value
   dex
   bpl .cycleObjectColors
.checkToAnimateSaucer
   lda saucerSpriteLSBValue         ; get Saucer sprite LSB value
   cmp #<[GammySprite - SpriteGraphics]
   beq ReadJoystickValues           ; branch if showing GAMMY
   and #1                           ; 0 <= a <= 1
   tax
   lda SaucerAnimation,x            ; animate Saucer sprite
   sta saucerSpriteLSBValue
ReadJoystickValues
   lda SWCHA                        ; read joystick values
   and #P1_JOYSTICK_MASK            ; keep right joystick values
   ror                              ; shift MOVE_UP to carry
   bcs .checkJoystickMovedDown
   ldx saucerVerticalPosition       ; get Saucer vertical position
   cpx saucerHoveringLimit
   bmi .checkJoystickMovedDown      ; branch if reached hovering limit
   dec saucerVerticalPosition       ; decrement Saucer vertical position
.checkJoystickMovedDown
   ror                              ; shift MOVE_DOWN to carry
   bcs .checkJoystickMovedLeft
   ldx saucerVerticalPosition       ; get Saucer vertical position
   cpx #INIT_SAUCER_VERT_POS + 24
   bpl .checkJoystickMovedLeft
   inc saucerVerticalPosition       ; increment Saucer vertical position
.checkJoystickMovedLeft
   ror                              ; shift MOVE_LEFT to carry
   bcs .checkJoystickMovedRight
   ldx #MOUNTAIN_SCROLL_DIR_RIGHT
   stx mountainScrollDirection
.checkJoystickMovedRight
   ror                              ; shift MOVE_RIGHT to carry
   bcs ResetZoneScanlineValues      ; branch if not MOVE_RIGHT
   ldx #MOUNTAIN_SCROLL_DIR_LEFT
   stx mountainScrollDirection
ResetZoneScanlineValues
   lda #0
   ldx #14
.clearZoneScanlineValues
   sta objectScanlineValues,x       ; clear zone scan line value
   dex
   bne .clearZoneScanlineValues
   ldx #0
   stx tmpKernelZoneIndex           ; reset kernel zone index for processing
   ldy #0
   sty tmpSavedObjectIndex
   lda saucerSpriteLSBValue         ; get Saucer sprite LSB value
   cmp #<[GammySprite - SpriteGraphics]
   bne ReadControllerActionButton   ; branch if not showing GAMMY
   iny
   bne .setSaucerScanlineValues     ; unconditional branch

ReadControllerActionButton
   lda objectHitTimer               ; get object hit timer value
   beq .readControllerActionButton  ; branch if object not doing hit animation
   lda #4
   sta saucerLaserIndex
   bne .activateSaucerLaser         ; unconditional branch
    
.readControllerActionButton
   lda INPT5 + 48                   ; read right controller action button
   bmi .clearActionButtonDebounceValue;branch if action button not pressed
   lda actionButtonDebounce         ; get action button debounce
   bne .activateSaucerLaser         ; branch if action button held
   lda #1
   sta actionButtonDebounce
   stx saucerLaserIndex             ; reset Saucer laser index (i.e. x = 0)
.activateSaucerLaser
   lda saucerLaserIndex
   cmp #4
   beq .turnOffSaucerLaserDisplay
   inc saucerLaserIndex
   ldy saucerLaserIndex
   lda SaucerLaserScanlineValues - 1,y; y never 0
   bne .setSaucerLaserScanlineValue ; unconditional branch
    
.clearActionButtonDebounceValue
   stx actionButtonDebounce         ; clear action button debounce (i.e. x = 0)
   jmp .activateSaucerLaser
    
.turnOffSaucerLaserDisplay
   lda saucerVerticalPosition       ; get Saucer vertical position
.setSaucerLaserScanlineValue
   sta objectScanlineValues,x
   ldy #ID_SAUCER_LASER
   lda #<SetupToDisableSaucerLaser
   sta kernelZoneVectorLSBValues
   lda saucerLaserHorizPosition
   jsr DetermineObjectHorizPositionValues
   inx
   iny
.setSaucerScanlineValues
   lda #<SetupToDrawSaucerZone
   sta kernelZoneVectorLSBValues,x
   lda saucerVerticalPosition       ; get Saucer vertical position
   sta objectScanlineValues,x
   inx
   lda saucerSpriteLSBValue         ; get Saucer sprite LSB value
   cmp #<[GammySprite - SpriteGraphics]
   beq .nextObjectIndex             ; branch if showing GAMMY
   lda saucerVerticalPosition       ; get Saucer vertical position
   cmp objectScanlineValues
   beq .nextObjectIndex
   adc #6
   sta objectScanlineValues,x
   lda #<SetupToDrawSaucerLaser
   sta kernelZoneVectorLSBValues,x
   inx
.nextObjectIndex
   iny                              ; increment object index value
   sty tmpObjectIndex
   lda tankMissileHorizPosition     ; get Tank missile horizontal position
   cmp #XMAX - 8
   bpl .determineToLaunchTankMissile
   lda tankMissileVerticalPosition  ; get Tank missile vertical position
   cmp #19
   bpl .moveTankMissileUp
.determineToLaunchTankMissile
   lda #$40
   and frameCount + 1
   bne DetermineActiveTankToFireMissile
   lda #0
   sta tankMissileSoundVolume
   beq MoveTanks                    ; unconditional branch
    
DetermineActiveTankToFireMissile
   lda #4
   sta tankMissileSoundVolume
   lda activeTankIndex              ; get current active Tank index
   cmp #ID_TANK_03
   bne .determineActiveTankToFireMissile
   lda #ID_TANK_00 - 1
   sta activeTankIndex              ; reset to point to ID_TANK_00
.determineActiveTankToFireMissile
   inc activeTankIndex              ; increment active Tank index
   ldy activeTankIndex
   lda tankSpriteLSBValues - 3,y    ; get Tank sprite LSB value
   cmp #<[DestroyedTankSprite - SpriteGraphics]
   beq MoveTanks                    ; branch if Tank destroyed
   cmp #<[OffScreenSprite - SpriteGraphics]
   beq MoveTanks
   lda tankHorizPositions - 3,y     ; get active Tank horizontal position
   and #$7F                         ; 0 <= a <= 127
   adc #4
   sta tankMissileHorizPosition     ; set Tank missile horizontal position
   lda objectVerticalPositions,y
   sta tankMissileVerticalPosition
.moveTankMissileUp
   lda tankMissileVerticalPosition  ; get Tank missile vertical position
   sec
   sbc currentGameSpeed             ; decrement by current speed (i.e. move up)
   sta tankMissileVerticalPosition
   sta objectScanlineValues,x
   lda mountainScrollDirection      ; get mountain scroll direction value
   beq .moveTankMissile             ; branch if MOUNTAIN_SCROLL_DIR_NONE
   bmi .scrollTankMissileLeft       ; branch if MOUNTAIN_SCROLL_DIR_LEFT
   inc tankMissileHorizPosition
   inc tankMissileHorizPosition
   jmp .moveTankMissile
    
.scrollTankMissileLeft
   dec tankMissileHorizPosition
   dec tankMissileHorizPosition
.moveTankMissile
   clc
   lda tankMissileHorizPosition     ; get Tank missile horizontal position
   adc currentGameSpeed             ; increment by current game speed
   sta tankMissileHorizPosition     ; set new Tank missile horizontal position
   ldy tmpObjectIndex               ; get current processing object index value
   jsr DetermineObjectHorizPositionValues
   lda #<[OffScreenSprite - SpriteGraphics]
   sta tankMissileLSBValue
   lda #<SetupToDrawTankMissile
   sta kernelZoneVectorLSBValues,x
   inx
MoveTanks
   ldy tmpObjectIndex               ; get current processing object index value
   iny
   stx tmpKernelZoneIndex           ; save current kernel zone index value
   sty tmpSavedObjectIndex
   ldy #0
   sty tmpTankIndex
.moveTanks
   ldy tmpTankIndex
   lda tankSpriteLSBValues,y        ; get Tank sprite LSB value
   cmp #<[OffScreenSprite - SpriteGraphics]
   bne .determineTankScrollSpeed    ; branch if Tank visible on screen
   lda tankHorizPositions,y         ; get Tank horizontal position
   cmp #XMAX
   bmi .determineTankScrollSpeed    ; branch if Tank not reached right side
   lda mountainScrollDirection      ; get mountain scroll direction value
   bmi .setTankOffScreenScrollingLeft;branch if MOUNTAIN_SCROLL_DIR_LEFT
   lda TankSpriteLSBValues,y
.setTankSpriteLSBValue
   sta tankSpriteLSBValues,y
.determineTankScrollSpeed
   lda mountainScrollDirection      ; get mountain scroll direction value
   beq .determineTankVelocity       ; branch if MOUNTAIN_SCROLL_DIR_NONE
   bpl .scrollTankRight             ; branch if MOUNTAIN_SCROLL_DIR_RIGHT
   lda tankHorizPositions,y         ; get Tank horizontal position
   sec
   sbc #TANK_SCROLL_SPEED
   sta tankHorizPositions,y
   jmp .determineTankVelocity
    
.setTankOffScreenScrollingLeft
   lda #<[OffScreenSprite - SpriteGraphics]
   bne .setTankSpriteLSBValue       ; unconditional branch
    
.wrapTankToRight
   lda #XMAX
   bne .setTankHorizontalPosition   ; unconditional branch
    
.wrapTankToLeft
   lda #XMIN
   bne .setTankHorizontalPosition   ; unconditional branch
    
.determineTankVelocity
   lda playerScoreOnesValue         ; get score ones value
   and #3                           ; 0 <= a <= 3
   cmp tmpTankIndex
   bne .setTankSlowVelocity
   lda playerScoreHundredsValue     ; get score hundreds value
   and #1                           ; 0 <= a <= 1
   bne .setTankFastVelocity
   lda #TANK_MEDIUM_VELOCITY
   bne .setTankVelocity
    
.setTankFastVelocity
   lda #TANK_FAST_VELOCITY
   bne .setTankVelocity             ; unconditional branch
    
.setTankSlowVelocity
    lda #TANK_SLOW_VELOCITY
.setTankVelocity
   sta tankVelocity
   lda playerScoreOnesValue         ; get score ones value
   and #1                           ; 0 <= a <= 1
   beq .determineToMoveTank
   lda tankVelocity
   eor #$FF                         ; get 1's complement...not negated
   sta tankVelocity
.determineToMoveTank
   ldy currentGameSpeed
   lda TankFrameDelayValues,y       ; get Tank frame delay value
   ldy tmpTankIndex
   and frameCount + 1               ; mask with current frame count
   bne .tankNotMoving               ; branch if not time to move Tank
   lda tankHorizPositions,y         ; get Tank horizontal position
   clc
   adc tankVelocity                 ; adjust by Tank velocity
   jmp .checkToWrapTankSprite
    
.scrollTankRight
   lda tankHorizPositions,y         ; get Tank horizontal position
   clc
   adc #TANK_SCROLL_SPEED
   sta tankHorizPositions,y
   jmp .determineTankVelocity
    
.tankNotMoving
   lda tankHorizPositions,y         ; get Tank horizontal position
.checkToWrapTankSprite
   cmp #XMAX + 3
   bpl .wrapTankToLeft
   cmp #XMIN
   bmi .wrapTankToRight
.setTankHorizontalPosition
   sta tankHorizPositions,y
   ldy tmpSavedObjectIndex
   jsr DetermineObjectHorizPositionValues
   ldy tmpTankIndex
   lda InitTankVerticalPositons,y
   sta tankVerticalPositions,y
   sta objectScanlineValues,x
   lda tankSpriteLSBValues,y
   beq .setTankExplosionAnimation_00
   cmp #<[TankExplosionSprite_00 - SpriteGraphics]
   beq .setTankExplosionAnimation_01
   cmp #<[TankExplosionSprite_01 - SpriteGraphics]
   beq .setTankExplosionAnimation_00
   bne .setTankKernelZoneVectorValue; unconditional branch
    
.setTankExplosionAnimation_01
   lda #<[TankExplosionSprite_01 - SpriteGraphics]
   bne .setTankExplosionSpriteValue
    
.setTankExplosionAnimation_00
   lda #<[TankExplosionSprite_00 - SpriteGraphics]
.setTankExplosionSpriteValue
   sta tankSpriteLSBValues,y
   lda objectHitTimer               ; get object hit timer value
   bne .setTankKernelZoneVectorValue; branch if doing object hit animation
   lda #<[DestroyedTankSprite - SpriteGraphics]
   sta tankSpriteLSBValues,y
.setTankKernelZoneVectorValue
   lda SetupToDrawTankLSBValues,y
   sta kernelZoneVectorLSBValues,x
   inx
   iny
   inc tmpSavedObjectIndex
   inc tmpTankIndex
   lda tmpTankIndex
   cmp #4
   beq .doneMoveTanks
   jmp .moveTanks
    
.doneMoveTanks
   stx tmpKernelZoneIndex           ; save current kernel zone index value
   lda remainingTanks               ; get remaining Tanks
   bne CheckTankMissieCollisionWithSaucer;branch if Tanks remaining
   lda objectHitTimer               ; get object hit timer value
   bne CheckTankMissieCollisionWithSaucer;branch if doing object hit animation
   ldy #ID_TANK_00
   lda #<[OffScreenSprite - SpriteGraphics]
.resetTankSpriteLSBValues
   sta objectSpriteLSBValues,y
   iny
   cpy #ID_TANK_03 + 1
   bne .resetTankSpriteLSBValues
   lda #4
   sta remainingTanks
   inc currentRack                  ; increment current rack
   ldy gameSelection                ; get current game selection
   lda currentRack                  ; get current rack
   and #$0F                         ; 0 <= a <= 15
   cmp #8
   beq .setHighestGameSpeed
   and #4                           ; a == 0 || a == 4
   bne .setMediumGameSpeed
   beq .setCurrentGameSpeed         ; unconditional branch

.setHighestGameSpeed
   iny
.setMediumGameSpeed
   iny
.setCurrentGameSpeed
   sty currentGameSpeed
CheckTankMissieCollisionWithSaucer
   ldy #ID_SAUCER
   lda objectHorizontalPositions,y
   jsr DetermineObjectHorizPositionValues
   lda tankMissileVerticalPosition  ; get Tank missile vertical position
   sec
   sbc saucerVerticalPosition       ; subtract Saucer vertical position
   bmi .checkToReduceSaucerHoverLimit;branch if not in Saucer vertical range
   cmp #4
   bpl .checkToReduceSaucerHoverLimit;branch if not in Saucer vertical range
   lda tankMissileHorizPosition     ; get Tank missile horizontal position
   sec
   sbc saucerHorizPosition          ; subtract Saucer horizontal position
   bmi .checkToReduceSaucerHoverLimit;branch if Tank missile to the left of Saucer
   cmp #8
   bpl .checkToReduceSaucerHoverLimit
   lda saucerSpriteLSBValue         ; get Saucer sprite LSB value
   cmp #<[GammySprite - SpriteGraphics]
   beq .checkToReduceSaucerHoverLimit;branch if Tank missile hit GAMMY
   lda #INIT_OBJECT_HIT_TIMER
   sta objectHitTimer
   lda #COLOR_HIT_SAUCER
   sta colorSaucer                  ; color Saucer for being hit
.checkToReduceSaucerHoverLimit
   lda colorSaucer                  ; get Saucer color
   cmp #COLOR_HIT_SAUCER
   bne SetRemainingKernelZoneValues ; branch if Saucer not in hit mode
   lda objectHitTimer               ; get object hit timer value
   bne SetRemainingKernelZoneValues ; branch if doing object hit animation
   lda #COLOR_SAUCER
   sta colorSaucer
   lda saucerHoveringLimit          ; get Saucer hover limit value
   adc #4
   sta saucerHoveringLimit
   lda saucerVerticalPosition       ; get Saucer vertical position
   adc #4
   cmp #INIT_SAUCER_VERT_POS + 24
   bmi .setSaucerVerticalPosition
   lda #<[GammySprite - SpriteGraphics]
   sta saucerSpriteLSBValue
   lda #INIT_SAUCER_VERT_POS + 24
.setSaucerVerticalPosition
   sta saucerVerticalPosition
SetRemainingKernelZoneValues
   ldx tmpKernelZoneIndex           ; get current processing kernel zone index
   ldy #0
.setRemainingKernelZoneValues
   lda ObjectScanlineValues,y
   beq SortKernelZoneValues
   sta objectScanlineValues,x
   lda ObjectKernelZoneLSBValues,y
   sta kernelZoneVectorLSBValues,x
   inx
   iny
   bne .setRemainingKernelZoneValues
    
SortKernelZoneValues
   ldy #0
   sty tmpKernelZoneIndex
.sortKernelZoneValues
   lda objectScanlineValues + 1,y
   beq .checkDoneSortKernelZoneValues
   cmp objectScanlineValues,y       ; compare with adjacent scan line value
   bpl .nextSortKernelZoneValues
   beq .nextSortKernelZoneValues
   tax                              ; move scan line value to x register
   lda objectScanlineValues,y
   sta objectScanlineValues + 1,y
   stx objectScanlineValues,y
   ldx kernelZoneVectorLSBValues + 1,y
   lda kernelZoneVectorLSBValues,y
   sta kernelZoneVectorLSBValues + 1,y
   stx kernelZoneVectorLSBValues,y
   inc tmpKernelZoneIndex
.nextSortKernelZoneValues
   cpy #9
   beq .checkDoneSortKernelZoneValues
   iny
   bne .sortKernelZoneValues        ; unconditional branch
    
.checkDoneSortKernelZoneValues
   lda tmpKernelZoneIndex
   bne SortKernelZoneValues
   rts
    
CheckSaucerLaserCollisionWithTank
   lda CXM1P                        ; read missile 1 to player collision
   and #$80                         ; keep missile 1 to player 0 collision
   beq .doneCheckSaucerLaserCollisionWithTank;branch if no collision
   ldx saucerLaserIndex
   lda objectSpriteLSBValues + 2,x
   cmp #<[TankGraphics - SpriteGraphics]
   bne .doneCheckSaucerLaserCollisionWithTank;branch if object not a Tank
   lda #INIT_OBJECT_HIT_TIMER
   sta objectHitTimer
   sta actionButtonDebounce
   dec remainingTanks               ; decrement remaining Tanks
   lda remainingTanks
   adc #2 - 1                       ; carry set from compare
   asl                              ; shift lower nybbles to upper nybbles
   asl
   asl
   asl
   ora remainingTanks               ; combine with remaining tanks
   sed                              ; set decimal mode
   clc
   adc playerScoreOnesValue         ; increment score ones value
   sta playerScoreOnesValue
   lda playerScoreHundredsValue     ; get score hundreds value
   adc #1 - 1                       ; increment if an overflow
   sta playerScoreHundredsValue
   cld
   lda #0
   sta saucerLaserIndex
   sta objectSpriteLSBValues + 2,x
.doneCheckSaucerLaserCollisionWithTank
   lda frameCount
   and #$80
   beq PerformGameSoundRoutines
   lda #0
   sta AUDV0
   sta AUDV1
   beq CheckToScrollMountainTerrain ; unconditional branch
    
PerformGameSoundRoutines
   lda objectHitTimer               ; get object hit timer value
   beq .checkToPlayerSaucerLaserSounds;branch if done object hit animation
   dec objectHitTimer
   cmp #15
   bmi .checkToPlayerSaucerLaserSounds
   lda objectHitTimer               ; get object hit timer value
   sta AUDV0                        ; set sound volume for hit animation
   lda #15
   sta AUDC0
   lda #20
   sta AUDF0
   bne CheckToScrollMountainTerrain ; unconditional branch
    
.checkToPlayerSaucerLaserSounds
   lda INPT5 + 48                   ; read right controller action button
   bpl .playSaucerLaserSounds       ; branch if action button pressed
   lda #0
   sta AUDV0
   beq .playTankMissileSounds       ; unconditional branch
    
.playSaucerLaserSounds
   lda #8
   sta AUDV0
   sta frameCount
   sta AUDC0
   sta AUDF0
.playTankMissileSounds
   lda tankMissileSoundVolume       ; get Tank missile sound volume
   sta AUDV1
   lda tankMissileVerticalPosition  ; get Tank missile vertical position
   lsr                              ; divide value by 4
   lsr
   sta AUDF1
   lda #3
   sta AUDC1
CheckToScrollMountainTerrain
   lda mountainScrollDirection      ; get mountain scroll direction value
   bne .checkToScrollMountainTerrain
   beq PrepareScoreBoardDisplay     ; unconditional branch
    
.checkToScrollMountainTerrain
   bpl ScrollMountainTerrainRight   ; branch if MOUNTAIN_SCROLL_DIR_RIGHT
   ldx #MOUNTAIN_SCROLL_DIR_NONE
   stx mountainScrollDirection
.scrollMountainTerrainLeft
   lda mountainPF0Graphics,x
   and #$10
   beq .clearCarryForLeftScrollingMountailGraphics
   sec
   bne .rotateLeftScrollingMountainGraphics;unconditional branch
    
.clearCarryForLeftScrollingMountailGraphics
   clc
.rotateLeftScrollingMountainGraphics
   ror mountainPF2Graphics,x
   rol mountainPF1Graphics,x
   ror mountainPF0Graphics,x
   inx
   cpx #8
   bne .scrollMountainTerrainLeft
   beq PrepareScoreBoardDisplay     ; unconditional branch
    
ScrollMountainTerrainRight
   ldx #MOUNTAIN_SCROLL_DIR_NONE
   stx mountainScrollDirection
.scrollMountainTerrainRight
   lda mountainPF2Graphics,x
   rol
   bcc .setRightScrollingPF0MountainGraphics
   lda #8
   ora mountainPF0Graphics,x
   bcs .rotateRightScrollingMountainGraphics;unconditional branch
    
.setRightScrollingPF0MountainGraphics
   lda mountainPF0Graphics,x
   and #$F0
.rotateRightScrollingMountainGraphics
   rol
   sta mountainPF0Graphics,x
   ror mountainPF1Graphics,x
   rol mountainPF2Graphics,x
   inx
   cpx #8
   bne .scrollMountainTerrainRight
PrepareScoreBoardDisplay
   ldy #0
   sty tmpScoreBoardIndex
.prepareScoreBoardDisplay
   ldx #0
   stx tmpScoreBoardDigitIdx        ; reset score board digit index
.determineScoreBoardGraphicValues
   lda playerScoreOnesValue         ; get score ones value
   cpx #2
   bmi .prepareDisplayScoreHundredsValue;branch if doing hundreds values
   bne .determineScoreBoardDigitValue
.shiftUpperNybblesToLowerNybbles
   lsr
   lsr
   lsr
   lsr
   jmp .determineScoreBoardDigitValue
    
.prepareDisplayScoreHundredsValue
   lda playerScoreHundredsValue     ; get score hundreds value
   cpx #1
   bne .shiftUpperNybblesToLowerNybbles;branch if doing MSB
.determineScoreBoardDigitValue
   and #$0F                         ; keep lower nybbles
   tax                              ; move value to x register
   cpy #H_SCORE_BOARD_FONT - 1
   beq .getBottomScoreBoardGraphicIndexValue
   lda ScoreBoardGraphicIndexValues,x
   cpy #0
.nextScoreBoardIndexValue
   beq .determineScoreBoardGraphicIndexValue
   lsr
   lsr
   dey
   jmp .nextScoreBoardIndexValue
    
.getBottomScoreBoardGraphicIndexValue
   lda BottomScoreBoardGraphicIndexValues,x
.determineScoreBoardGraphicIndexValue
   and #3                           ; 0 <= a <= 3
   ldx tmpScoreBoardDigitIdx
   cpx #2
   bmi .setScoreBoardGraphicValues  ; branch if doing hundreds values
   clc
   adc #<[CompressedScoreBoardPF2Graphics - CompressedScoreBoardGraphics]
.setScoreBoardGraphicValues
   tay
   lda CompressedScoreBoardGraphics,y
   sta tmpScoreBoardGraphics,x
   inc tmpScoreBoardDigitIdx
   ldx tmpScoreBoardDigitIdx        ; get score board digit index
   ldy tmpScoreBoardIndex
   cpx #4
   bne .determineScoreBoardGraphicValues;branch if not doing last digit
   lda tmpScoreBoardPF1Graphics     ; get temporary score board PF1 graphics
   and #$F0                         ; keep upper nybbles
   sta tmpScoreBoardPF1Graphics
   lda tmpScoreBoardPF1Graphics + 1
   and #$0F                         ; keep lower nybbles
   ora tmpScoreBoardPF1Graphics     ; combine with score board PF1 graphics
   sta scoreBoardPF1Graphics,y
   lda tmpScoreBoardPF2Graphics
   and #$0F                         ; keep lower nybbles
   sta tmpScoreBoardPF2Graphics
   lda tmpScoreBoardPF2Graphics + 1
   and #$F0                         ; keep upper nybbles
   ora tmpScoreBoardPF2Graphics     ; combine with score board PF2 graphics
   sta scoreBoardPF2Graphics,y
   inc tmpScoreBoardIndex
   ldy tmpScoreBoardIndex
   cpy #H_SCORE_BOARD_FONT
   bne .prepareScoreBoardDisplay
   rts

KernelSetupRoutines SUBROUTINE
SetupToDrawGround
   lda colorGround            ; 3
   sta COLUBK                 ; 3
   jmp NextKernelZone         ; 3

SetupToDrawMountainTerrain
   lda #H_MOUNTAIN_TERRAIN    ; 2
   sta tmpMountainGraphicIndex; 3
   bne .nextKernelZone        ; 3         unconditional branch

SetupToDisableSaucerLaser
   lda #DISABLE_BM            ; 2
   sta ENAM1                  ; 3 = @56
.nextKernelZone
   jmp NextKernelZone         ; 3

SetupToDrawTankMissile
   lda frameCount + 1         ; 3         get current frame count
   and #1                     ; 2         0 <= a <= 1
   beq .nextKernelZone        ; 2³
   lda tankMissileLSBValue    ; 3         get Tank missile sprite LSB value
   sta tankMissileGraphicIdx  ; 3
   jmp NextKernelZone         ; 3

   .byte $A2,$00                    ; unused bytes
    
PositionSaucerHorizontally
PositionTankHorizontally
   lda objectFineMotionValues,x;4
   sta HMP0                   ; 3 = @75
;--------------------------------------
   lda objectCoarsePositionValues,x;4 = @03
   sta tmpCoarsePositionVector; 3
   ldx #<[RESP0 - RESP0]      ; 2
   sta WSYNC
;--------------------------------------
   jmp (tmpCoarsePositionVector);5
    
PositionMissileHorizontally
   lda frameCount + 1         ; 3         get current frame count
   and #1                     ; 2         0 <= a <= 1
   beq .positionSaucerLaserHorizontally;2³
   ldx #<[tankMissileFineMotionValue - objectFineMotionValues];2
   bne .positionTankMissileHorizontally;3 unconditional branch
    
.positionSaucerLaserHorizontally
   ldx #<[saucerLaserFineMotionValue - objectFineMotionValues];2
   lda objectFineMotionValues,x;4         get Saucer Laser fine motion value
   sta HMM1                   ; 3
   lda #MSBL_SIZE4 | QUAD_SIZE; 2
   sta NUSIZ1                 ; 3
   lda objectCoarsePositionValues,x;4
   ldx #<[RESM1 - RESP0]      ; 2
   bne .coarsePositionMissile ; 3         unconditional branch
    
.positionTankMissileHorizontally
   lda objectFineMotionValues,x;4         get Tank missile fine motion value
   sta HMP1                   ; 3
   lda #MSBL_SIZE1 | ONE_COPY ; 2
   sta NUSIZ1                 ; 3
   lda objectCoarsePositionValues,x;4     get Tank missile coarse position value
   ldx #<[RESP1 - RESP0]      ; 2
.coarsePositionMissile
   sta tmpCoarsePositionVector; 3
   sta WSYNC
;--------------------------------------
   jmp (tmpCoarsePositionVector);5
    
SetupToDrawSaucerZone
   ldy saucerSpriteLSBValue   ; 3
   lda colorSaucer            ; 3
   sta COLUP0                 ; 3
   ldx #<[saucerFineMotionValue - objectFineMotionValues];2
   stx activateSaucerLaserDisplay;3       set to non-zero to active Saucer laser
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ0                 ; 3
   jmp PositionSaucerHorizontally;3

SetupToDrawSaucerLaser
   lda frameCount + 1         ; 3         get current fame count
   and #1                     ; 2         0 <= a <= 1
   bne .nextKernelZone        ; 2³
   lda #ENABLE_BM             ; 2
   sta ENAM1                  ; 3
   bne .nextKernelZone        ; 3         unconditional branch

SetupToDrawZoneTank_00
   ldy tankSpriteLSBValue_00  ; 3 = @54
   ldx #<[tankFineMotionValue_00 - objectFineMotionValues];2
   bne .colorTankSprite       ; 3         unconditional branch
    
SetupToDrawZoneTank_01
   ldy tankSpriteLSBValue_01  ; 3
   ldx #<[tankFineMotionValue_01 - objectFineMotionValues];2
   bne .colorTankSprite       ; 3         unconditional branch

SetupToDrawZoneTank_02
   ldy tankSpriteLSBValue_02  ; 3
   ldx #<[tankFineMotionValue_02 - objectFineMotionValues];2
   bne .colorTankSprite       ; 3         unconditional branch
    
SetupToDrawZoneTank_03
   ldy tankSpriteLSBValue_03  ; 3
   ldx #<[tankFineMotionValue_03 - objectFineMotionValues];2
.colorTankSprite
   lda colorTank              ; 3
   sta COLUP0                 ; 3 = @65
   jmp PositionTankHorizontally;3
    
   .byte 46                         ; unused

SaucerLaserScanlineValues
   .byte 53, 59, 66, 69

SpriteGraphics
   .byte $00 ; |........|
OffScreenSprite
   .byte $00 ; |........|
GammySprite
   .byte $63 ; |.XX...XX|
   .byte $14 ; |...X.X..|
   .byte $3E ; |..XXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $73 ; |.XXX..XX|
   .byte $67 ; |.XX..XXX|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $77 ; |.XXX.XXX|
DestroyedTankSprite
   .byte $00 ; |........|

   .byte 0, 0                       ; unused

TankExplosionSprites
TankExplosionSprite_00
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $C3 ; |XX....XX|
   .byte $99 ; |X..XX..X|
   .byte $99 ; |X..XX..X|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
TankExplosionSprite_01
   .byte $81 ; |X......X|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $81 ; |X......X|
   .byte $00 ; |........|

   .byte $11,$22,$74,$78,$FF,$AB,$7E,$00;unused Tank graphics

TankGraphics
   .byte $01 ; |.......X|
   .byte $06 ; |.....XX.|
   .byte $7A ; |.XXXX.X.|
   .byte $F4 ; |XXXX.X..|
   .byte $68 ; |.XX.X...|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $AB ; |X.X.X.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
SaucerSprites
SaucerSprite_00
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
SaucerSprite_01
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
;
; unused bytes
;
   .byte $00,$99,$99,$9B,$99,$9D,$BF
   .byte $DB,$99,$99,$99,$99,$9D,$89
   .byte $D9,$91,$99,$19,$91,$99,$99

CoarsePositionObject
   lda #0                     ; 2
   sta GRP0                   ; 3
   sta GRP1                   ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   sta RESP0,x                ; 4
   jmp NextKernelZone         ; 3
    
DetermineObjectHorizPositionValues
   clc
   adc #16                          ; increment horizontal position
   asl                              ; multiply value by 2
   sta tmpAdjustedHorizPos
   eor #$FF                         ; get 1's complement value
   and #$F8
   lsr
   lsr
   sta objectCoarsePositionValues,y
   lda tmpAdjustedHorizPos
   and #7
   eor #$FF                         ; get 1's complement value
   sec
   adc #1 - 1                       ; increment by 1 (i.e. carry set)
   asl                              ; shift to upper nybbles for fine motion
   asl
   asl
   asl
   sta objectFineMotionValues,y
   rts
    
ScoreBoardGraphicIndexValues
   .byte 3 << 6 | 3 << 4 | 3 << 2 | 0 << 0
   .byte 1 << 6 | 1 << 4 | 1 << 2 | 1 << 0
   .byte 2 << 6 | 0 << 4 | 1 << 2 | 0 << 0
   .byte 1 << 6 | 0 << 4 | 1 << 2 | 0 << 0
   .byte 1 << 6 | 0 << 4 | 3 << 2 | 3 << 0
   .byte 1 << 6 | 0 << 4 | 2 << 2 | 0 << 0
   .byte 3 << 6 | 0 << 4 | 2 << 2 | 0 << 0
   .byte 1 << 6 | 1 << 4 | 1 << 2 | 0 << 0
   .byte 3 << 6 | 0 << 4 | 3 << 2 | 0 << 0
   .byte 1 << 6 | 0 << 4 | 3 << 2 | 0 << 0

   .byte $CC,$CA,$A8,$C5,$88,$88    ; unused
   
BottomScoreBoardGraphicIndexValues
   .byte 0, 1, 0, 0, 1, 0, 0, 1, 0, 1
   
   .byte $03,$00,$00,$00,$00,$02    ; unused

CompressedScoreBoardGraphics
CompressedScoreBoardPF1Graphics
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $88 ; |X...X...|
   .byte $AA ; |X.X.X.X.|
CompressedScoreBoardPF2Graphics   
   .byte $77 ; |.XXX.XXX|
   .byte $44 ; |.X...X..|
   .byte $11 ; |...X...X|
   .byte $55 ; |.X.X.X.X|

CopyrightFonts
CopyrightFont_00
   .byte $38 ; |..XXX...|
   .byte $44 ; |.X...X..|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $BA ; |X.XXX.X.|
   .byte $44 ; |.X...X..|
   .byte $38 ; |..XXX...|
CopyrightFont_01
   .byte $F7 ; |XXXX.XXX|
   .byte $85 ; |X....X.X|
   .byte $85 ; |X....X.X|
   .byte $85 ; |X....X.X|
   .byte $B7 ; |X.XX.XXX|
   .byte $95 ; |X..X.X.X|
   .byte $F5 ; |XXXX.X.X|
CopyrightFont_02
   .byte $22 ; |..X...X.|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $3E ; |..XXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
CopyrightFont_03
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|

TankMissileSprite
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $04 ; |.....X..|
   .byte $10 ; |...X....|
   .byte $40 ; |.X......|
   .byte $00 ; |........|

   .byte $00,$03,$0C,$30,$C0,$00    ; unused Tank missile graphics
   
SetupToDrawTankLSBValues
   .byte <SetupToDrawZoneTank_00
   .byte <SetupToDrawZoneTank_01
   .byte <SetupToDrawZoneTank_02
   .byte <SetupToDrawZoneTank_03

ObjectScanlineValues
   .byte 12, 17, 45, 0

ObjectKernelZoneLSBValues
   .byte <PositionMissileHorizontally
   .byte <SetupToDrawMountainTerrain
   .byte <SetupToDrawGround

InitMountainGraphics
InitPF0MountainGraphics
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
InitPF1MountainGraphics
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $06 ; |.....XX.|
InitPF2MountainGraphics
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C7 ; |XX...XXX|
   .byte $C3 ; |XX....XX|
   .byte $81 ; |X......X|
   .byte $80 ; |X.......|
   .byte $00 ; |........|

InitTankVerticalPositons
   .byte VERT_POSITION_TANK_00
   .byte VERT_POSITION_TANK_01
   .byte VERT_POSITION_TANK_02
   .byte VERT_POSITION_TANK_03

   .byte 80, 0                      ; unused

TankSpriteLSBValues
   .byte <[TankGraphics - SpriteGraphics]
   .byte <[TankGraphics - SpriteGraphics]
   .byte <[TankGraphics - SpriteGraphics]
   .byte <[TankGraphics - SpriteGraphics]
   
   .byte 2                          ; unused
    
InitObjectColors
   .byte COLOR_TANK
   .byte COLOR_GROUND
   .byte COLOR_SKY
   .byte COLOR_SAUCER
   .byte COLOR_SAUCER_LASER
    
MountainColorValues
   .byte COLOR_MOUNTAIN + 0
   .byte COLOR_MOUNTAIN + 0
   .byte COLOR_MOUNTAIN + 2
   .byte COLOR_MOUNTAIN + 2
   .byte COLOR_MOUNTAIN + 4
   .byte COLOR_MOUNTAIN + 4
   .byte COLOR_MOUNTAIN + 6
   .byte COLOR_MOUNTAIN + 6
    
TankFrameDelayValues
   .byte $43, $43, $03, $23, $21;, $37, $42    ; next 2 bytes shared for higher racks
    
SaucerAnimation
   .byte <[SaucerSprite_00 - SpriteGraphics]
   .byte <[SaucerSprite_01 - SpriteGraphics]
    
   .byte $01,$21,$42,$82,$21        ; unused
       
   .org ROM_BASE + 2048 - 6, 0      ; 2K ROM

   .word Start
   .word Start
   .word Start