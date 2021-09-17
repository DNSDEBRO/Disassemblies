   LIST OFF
; ***  B A R N S T O R M I N G  ***
; Copyright 1982 Activision, Inc
; Programmer: Steve Cartwright

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: February 13, 2018
;
;  *** 118 BYTES OF RAM USED 10 BYTES FREE
;  *** 282 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================
;
; - This is Steven Cartwright's first VCS game
; - Noted as the first Activision game to use the sunset from the Venetian
;     Blinds demo
; - RAM locations $9E - $A1 are unused
;     possibly could've been used for a removed feature
; - PAL50 version ~17% slower than NTSC
; - Moving vertically reduces pilot speed by ~6%

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
PAL60                   = 2

TRUE                    = 1
FALSE                   = 0

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
; F R A M E - T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

FPS                     = 60        ; ~60 frames per second
VBLANK_TIME             = 48
OVERSCAN_TIME           = 33

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 87
OVERSCAN_TIME           = 54
   
   ENDIF
   
;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
LT_RED                  = $20
RED                     = $30
ORANGE                  = $40
DK_PINK                 = $50
COLBALT_BLUE            = $60
ULTAMARINE_BLUE         = $70
BLUE                    = $80
LT_BLUE                 = $90
CYAN                    = $A0
GREEN                   = $C0
DK_GREEN                = $D0

;
; Horizon Colors
;
HORIZON_COLOR_LINE_01   = YELLOW
HORIZON_COLOR_LINE_02   = YELLOW + 10
HORIZON_COLOR_LINE_03   = YELLOW + 8
HORIZON_COLOR_LINE_04   = LT_RED + 8
HORIZON_COLOR_LINE_05   = LT_RED + 8
HORIZON_COLOR_LINE_06   = RED + 8
HORIZON_COLOR_LINE_07   = RED + 8
HORIZON_COLOR_LINE_08   = ORANGE + 8
HORIZON_COLOR_LINE_09   = ORANGE + 8
HORIZON_COLOR_LINE_10   = DK_PINK + 8
HORIZON_COLOR_LINE_11   = COLBALT_BLUE + 8
HORIZON_COLOR_LINE_12   = COLBALT_BLUE + 8
HORIZON_COLOR_LINE_13   = ULTAMARINE_BLUE + 8
HORIZON_COLOR_LINE_14   = ULTAMARINE_BLUE + 8
HORIZON_COLOR_LINE_15   = BLUE + 8
HORIZON_COLOR_LINE_16   = BLUE + 8

   ELSE

YELLOW                  = $20
BRICK_RED               = $40
GREEN                   = $50
DK_GREEN                = GREEN
RED                     = $60
ORANGE                  = $60
PURPLE                  = $70
COLBALT_BLUE            = $80
CYAN                    = $A0
LT_BLUE                 = $C0
BLUE                    = $D0

;
; Horizon Colors
;
HORIZON_COLOR_LINE_01   = YELLOW
HORIZON_COLOR_LINE_02   = YELLOW + 10
HORIZON_COLOR_LINE_03   = YELLOW + 8
HORIZON_COLOR_LINE_04   = YELLOW + 8
HORIZON_COLOR_LINE_05   = BRICK_RED + 8
HORIZON_COLOR_LINE_06   = BRICK_RED + 8
HORIZON_COLOR_LINE_07   = BRICK_RED + 8
HORIZON_COLOR_LINE_08   = RED + 8
HORIZON_COLOR_LINE_09   = RED + 8
HORIZON_COLOR_LINE_10   = COLBALT_BLUE + 8
HORIZON_COLOR_LINE_11   = COLBALT_BLUE + 8
HORIZON_COLOR_LINE_12   = CYAN + 8
HORIZON_COLOR_LINE_13   = CYAN + 8
HORIZON_COLOR_LINE_14   = LT_BLUE + 8
HORIZON_COLOR_LINE_15   = LT_BLUE + 8
HORIZON_COLOR_LINE_16   = LT_BLUE + 8

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

SELECT_DELAY            = 30

H_FONT                  = 8
H_WINDMILL              = 57
H_HORIZON               = 12
H_PILOT                 = 21
H_BARN                  = 48

W_SCREEN                = 160       ; width of display area

XMIN                    = 0
XMAX                    = W_SCREEN + 80

YMIN                    = 20
YMAX                    = 125

PLAYER_XMIN             = XMIN + 24
PLAYER_XMAX             = W_SCREEN - 28

MICRO_SECONDS_DELAY     = $AB       ; 0.668

MAX_GAME_SELECTION      = 3

MAX_PILOT_ANIMATION     = 3

RPM_MIN                 = 0
RPM_MAX                 = 7
;
; ground obstacle types
;
TYPE_WINDMILL           = 0
TYPE_BARN               = 1
;
; ground obstacle generation values
;
NO_GROUND_OBSTACLE      = 0
SHOW_BARN_OBSTACLE      = %10
SHOW_WINDMILL_OBSTACLE  = %11
;
; vertical barn clearance values
;
BARN_CLEARANCE_AMATEUR  = YMAX - 25
BARN_CLEARNACE_PRO      = YMAX - 4
;
; barn count constants
;
HEDGE_HOPPER_BARN_COUNT = 10
CROP_DUSTER_BARN_COUNT  = 15
STUNT_PILOT_BARN_COUNT  = 15
FLYING_ACE_BARN_COUNT   = 25
;
; speed constants
;
PILOT_MIN_SPEED         = 0
PILOT_MAX_SPEED         = 37
OBSTACLE_MAX_SPEED      = PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 38 / 100)
;
; goose spawning constancts
;
SPAWN_NO_GOOSE          = %000
SPAWN_TOP_GOOSE         = %001
SPAWN_MIDDLE_GOOSE      = %010
SPAWN_BOTTOM_GOOSE      = %100
   
BLANK_OFFSET = (Blank - NumberFonts) / H_FONT

;===============================================================================
; M A C R O S
;===============================================================================

;
; DEC2BCD decimal number
;
; Converts a decimal number to BCD format
;
; ex. DEC2BCD 15....yields .byte $15
;
   MAC DEC2BCD
      .byte ({1} / 10) * 16 | {1} % 10
   ENDM

;
; time wasting macros
;
; These are used in the kernel for constant cycle times
;
   MAC SLEEP_3
      sta waste3Cycles
   ENDM
   
   MAC SLEEP_5
      dec loopCount
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
   
gameSelection              ds 1
frameCount                 ds 1
randomSeed                 ds 1
selectDebounce             ds 1
playerJoystickValue        ds 1
colorEOR                   ds 1
colorBWMask                ds 1
gameColors                 ds 8
;--------------------------------------
grassFieldColor            = gameColors
copyrightBackgroundColor   = grassFieldColor + 1
windmillColor              = copyrightBackgroundColor + 1
;--------------------------------------
roadColor                  = windmillColor
planeColor                 = roadColor + 1
skyColor                   = planeColor + 1
geeseColor                 = skyColor + 1
;--------------------------------------
weatherVaneColor           = geeseColor
;--------------------------------------
copyrightColor             = weatherVaneColor
groundColor                = copyrightColor + 1
mountainColor              = groundColor + 1
planeVertPosition          ds 1
pilotAnimationIndex        ds 1
windmillAnimationIndex     ds 1
barnCountGraphicPointers   ds 4
;--------------------------------------
barnCountTensPointers      = barnCountGraphicPointers
barnCountOnesPointers      = barnCountGraphicPointers + 2
gameSelectionPointers      ds 2
gameVariationsPointers     ds 2
pilotGraphicPointers       ds 2
obstacleGraphicPointers    ds 2
zp_Unused_01               ds 4     ; 4 bytes of unused RAM
barnGraphics               ds 2
;--------------------------------------
barnRoofGraphics           = barnGraphics
barnSideGraphics           = barnRoofGraphics + 1
groundObstacleTableIndex   ds 1
geeseSpawningIndex         ds 1
windmillBladesGraphicPointer ds 2
colorCycleMode             ds 1
engineVolume               ds 1
collisionIndicator         ds 1
pilotCrashTimer            ds 1
obstacleCollisionTimers    ds 4
;--------------------------------------
groundObstacleCollisionTimer = obstacleCollisionTimers
courseCompleteStatus       ds 1
collisionArray             ds 4
elapsedTime                ds 4
;--------------------------------------
elapsedTimeMinutes         = elapsedTime
elapsedTimeSeconds         = elapsedTime + 1
elapsedTimeMilliSeconds    = elapsedTime + 2
elapsedTimeMicroSeconds    = elapsedTime + 3
elapsedTimeGraphicPointers ds 10
geeseNUSIZIndexes          ds 3
geeseNUSIZValues           ds 3
audioValues                ds 6
;--------------------------------------
audioChannel00Value        = audioValues
audioChannel01Value        = audioChannel00Value + 1
audioFrequence00Value      = audioValues + 2
audioFrequence01Value      = audioFrequence00Value + 1
audioVolume00Value         = audioValues + 4
audioVolume01Value         = audioVolume00Value + 1
pilotLaunchStatus          ds 1
geeseSpawningValues        ds 1
gameState                  ds 1
timeInBarn                 ds 1
barnCountNumber            ds 1
engineRPMs                 ds 1
speedValues                ds 2
;--------------------------------------
obstacleSpeed              = speedValues
pilotSpeed                 = obstacleSpeed + 1
motionDelayValues          ds 2
;--------------------------------------
vertMotionDelay            = motionDelayValues
horizMotionDelay           = vertMotionDelay + 1
fractionalDelayValues      ds 2
;--------------------------------------
pilotFractionalDelayValue  = fractionalDelayValues
obstacleFractionalDelayValue = pilotFractionalDelayValue + 1
kernelIndex                ds 1
geeseAnimationIndex        ds 1
fencePostHorizPosition     ds 1
clearPF1                   ds 1           ; always 0...not used written to
barnHorizPosition          ds 1
obstacleSizeAndFineMotion  ds 4
obstacleHorizCoarseValues  ds 4
obstacleHorizPositions     ds 4
;--------------------------------------
groundObstacleHorizPosition = obstacleHorizPositions
obstacleFineMotion         ds 1
obstacleGraphicLSBValues   ds 4
flyingGeeseGraphicLSB      ds 1
hitGooseGraphicLSB         ds 1
groundObstacleType         ds 1
groundObstacleMask         ds 1
loopCount                  ds 1
;--------------------------------------
div16Remainder             = loopCount
;--------------------------------------
tmpObstacleFineMotion      = div16Remainder
;--------------------------------------
tmpPilotGraphicIndex       = tmpObstacleFineMotion
;--------------------------------------
tmpGameSelectionGraphic    = tmpPilotGraphicIndex
;--------------------------------------
tmpPilotSpeedDiv16         = tmpGameSelectionGraphic
;--------------------------------------
tmpFencePostHorizPosition  = tmpPilotSpeedDiv16
;--------------------------------------
tmpGeeseSpawningRate       = tmpFencePostHorizPosition
;--------------------------------------
tmpGeeseSpawningValue      = tmpGeeseSpawningRate
;--------------------------------------
tmpGameVariationValue      = tmpGeeseSpawningValue
tempDigitChar              ds 1
;--------------------------------------
tmpSpeed                   = tempDigitChar
;--------------------------------------
tmpHorizMotionDelay        = tmpSpeed
;--------------------------------------
tmpWindmillGraphicIndex    = tmpHorizMotionDelay
;--------------------------------------
tmpBarnGraphicIndex        = tmpWindmillGraphicIndex
tmpColonMask               ds 1
;--------------------------------------
tmpGooseHorizPosition      = tmpColonMask
tmpBarnClearance           ds 1
;--------------------------------------
tmpScrollingGooseIndex     = tmpBarnClearance
waste3Cycles               ds 1           ; used to waste 3 cycles in kernel

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
   sei                              ; disable interrupts
   cld                              ; clear decimal mode
   ldx #0
ClearRAM
   lda #0
.clearLoop
   sta VSYNC,x
   txs
   inx
   bne .clearLoop
   jsr InitializeGameVariables
   lda randomSeed                   ; get random seed value
   bne MainLoop                     ; branch if been through cart startup once
   ldx #1
   stx randomSeed                   ; initialize random seed
   dex                              ; x = 0
   jmp JumpIntoConsoleSwitchCheck

MainLoop
   ldx #<[mountainColor - gameColors]
.setGameColors
   lda GameColorTable,x
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta gameColors,x
   cpx #<[copyrightBackgroundColor - gameColors]
   bcs .nextColorIndex
   sta COLUBK,x
.nextColorIndex
   dex
   bpl .setGameColors
   lda #33
   ldx #<[HMP0 - HMP0]
   jsr PositionObjectHorizontally   ; position GRP0
   lda #40
   inx                              ; x = 1
   stx CTRLPF                       ; set to PF_REFLECT
   jsr PositionObjectHorizontally
   lda fencePostHorizPosition       ; get fence post horizontal position
   inx                              ; x = 2
   jsr PositionObjectHorizontally   ; position first fence post (i.e. M0)
   lda fencePostHorizPosition       ; get fence post horizontal position
   clc
   adc #64
   cmp #W_SCREEN
   bcc .positionSecondFencePost
   sbc #W_SCREEN
.positionSecondFencePost
   inx                              ; x = 3
   jsr HMOVEObject                  ; position second fence post (i.e M1)
   sta WSYNC
   sta HMCLR                        ; clear horizontal movement values
   ldx #3
.setObstacleSizeAndFineMotion
   lda obstacleHorizPositions,x     ; get obstacle horizontal position
   jsr CalculateObjectHorizPosition ; calculate coarse and fine motion
   sta tmpObstacleFineMotion
   lda obstacleSizeAndFineMotion,x
   and #$0F                         ; remove old fine motion value
   ora tmpObstacleFineMotion
   sta obstacleSizeAndFineMotion,x  ; set obstacle size and fine motion value
   sta obstacleSizeAndFineMotion,x  ; do it again :-)
   dey                              ; reduce obstacle coarse value by 4
   dey
   dey
   dey
   sty obstacleHorizCoarseValues,x  ; set obstacle coarse value
   dex
   bpl .setObstacleSizeAndFineMotion
   lda skyColor                     ; get the sky color
   sta COLUBK                       ; color the background for the sky
DisplayKernel SUBROUTINE
.waitTime
   ldy INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sty VBLANK                 ; 3         enable TIA (D1 = 0)
   sty NUSIZ0                 ; 3 = @09   set player 0 to ONE_COPY
   sty NUSIZ1                 ; 3 = @12   set player 1 to ONE_COPY
   lda #BLACK + 2             ; 2
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUP0                 ; 3 = @23
   sta COLUP1                 ; 3 = @26
   ldx #1                     ; 2
.emptyScanlinesForStatusKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2
   bpl .emptyScanlinesForStatusKernel;2³
   ldy #H_FONT - 1            ; 2
.drawBarnCount
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (barnCountTensPointers),y;5
   sta GRP0                   ; 3 = @11
   lda (barnCountOnesPointers),y;5
   sta GRP1                   ; 3 = @19
   dey                        ; 2
   bpl .drawBarnCount         ; 2³
   jmp ElapsedTimeKernel      ; 3
       
GameColorTable
   .byte DK_GREEN + 6               ; grass field color
   .byte BLACK                      ; copyright background color
   .byte DK_GREEN                   ; plane wing color
   .byte YELLOW + 10                ; plane color
   .byte BLUE + 8                   ; sky color
   .byte WHITE                      ; geese color
   .byte YELLOW + 4                 ; ground color
   .byte YELLOW + 2                 ; mountain color
       
BarnColors
   .byte ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2
   .byte ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2
   .byte ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2
   .byte ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2, ORANGE + 2
   .byte DK_GREEN, BLACK + 6, BLACK + 6, BLACK + 6, BLACK + 6, BLACK + 6
   .byte BLACK + 6, BLACK + 6, BLACK + 4, BLACK + 4, BLACK + 4, BLACK + 4
   .byte BLACK + 4, BLACK + 4, BLACK + 4, BLACK + 2, BLACK + 2, BLACK + 2
   .byte BLACK + 2, BLACK + 2, BLACK + 2, BLACK + 2, DK_GREEN, DK_GREEN + 6
   
MountainsPF0Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
 
InitBarnNumber
   DEC2BCD HEDGE_HOPPER_BARN_COUNT
   DEC2BCD CROP_DUSTER_BARN_COUNT
   DEC2BCD STUNT_PILOT_BARN_COUNT
   DEC2BCD FLYING_ACE_BARN_COUNT
       
ElapsedTimeKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @08
   sty GRP1                   ; 3 = @11
   iny                        ; 2
   sty NUSIZ1                 ; 3 = @16   set to TWO_COPIES (i.e. y = 1)
   ldy #THREE_COPIES          ; 2
   sty NUSIZ0                 ; 3 = @21
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   sta RESP0                  ; 3 = @29
   sta RESP1                  ; 3 = @32
   ldx #1                     ; 2
.emptyScanlinesForElapsedTime
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #ONE_COPY              ; 2
   SLEEP_3                    ; 3
   dec loopCount              ; 5
   lda #H_FONT - 1            ; 2
   sta loopCount              ; 3         set initial loop count value
   lda elapsedTimeGraphicPointers + 2;3   get elapsed time seconds LSB value
   cmp #<Blank                ; 2
   dex                        ; 2
   sta HMCLR                  ; 3 = @28
   bpl .emptyScanlinesForElapsedTime;2³
   bcc .setColonMask          ; 2³
   sty NUSIZ0                 ; 3 = @35   set sprite size to ONE_COPY
   sty NUSIZ1                 ; 3 = @38
   dex                        ; 2         x = #$FE
.setColonMask
   stx tmpColonMask           ; 3
.drawElapsedTime
   ldy loopCount              ; 3
   lda (elapsedTimeGraphicPointers),y;5
   ora TimeDigitColonSprite,y ; 4
   and tmpColonMask           ; 3
   sta GRP0                   ; 3
   lda (elapsedTimeGraphicPointers + 2),y;5
   sta GRP1                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (elapsedTimeGraphicPointers + 8),y;5
   sta tempDigitChar          ; 3
   lda (elapsedTimeGraphicPointers + 6),y;5
   tax                        ; 2
   lda (elapsedTimeGraphicPointers + 4),y;5
   ora TimeDigitDecimalSprite,y;4
   ldy tempDigitChar          ; 3
   sta GRP0                   ; 3 = @33
   stx GRP1                   ; 3 = @36
   sty GRP0                   ; 3 = @39
   dec loopCount              ; 5
   bpl .drawElapsedTime       ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$00                   ; 2
   sta GRP0                   ; 3 = @08
   sta GRP1                   ; 3 = @11
   jmp HorizonKernel          ; 3
       
GroundColors
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte WHITE
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte WHITE
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
   .byte YELLOW + 4
       
HorizonKernel
   ldx #H_HORIZON             ; 2
.drawHorizon
   lda HorizonColors,x        ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   cpx #8                     ; 2
   bcs .skipMountainDraw      ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda mountainColor          ; 3
   sta COLUPF                 ; 3 = @12
   lda MountainsPF0Graphics,x ; 4
   sta PF0                    ; 3 = @19
   lda MountainsPF1Graphics,x ; 4
   sta PF1                    ; 3 = @26
   lda MountainsPF2Graphics,x ; 4
   sta PF2                    ; 3 = @33
   jmp .nextHorizonScanline   ; 3
       
.skipMountainDraw
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
.nextHorizonScanline
   dex                        ; 2
   bpl .drawHorizon           ; 2³
   ldx #$00                   ; 2
   ldy grassFieldColor        ; 3
   lda planeColor             ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUPF                 ; 3 = @03
   sty COLUBK                 ; 3 = @06
   stx PF0                    ; 3 = @09
   stx PF1                    ; 3 = @12
   stx PF2                    ; 3 = @15
   stx NUSIZ1                 ; 3 = @18   set to ONE_SIZE (i.e. x = 0)
   stx CTRLPF                 ; 3 = @21   set to PF_NO_REFLECT
   lda windmillColor          ; 3
   sta RESP1                  ; 3 = @27
   sta COLUP1                 ; 3 = @30
   lda #HMOVE_R1              ; 2
   sta HMP1                   ; 3 = @35
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Sleep12Cycles          ; 6
   jsr Sleep12Cycles          ; 6
   sta HMCLR                  ; 3 = @30
   ldx #4                     ; 2
   stx kernelIndex            ; 3
   ldy planeVertPosition      ; 3         get the plane vertical position
AirObstacleKernel
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawAirKernel_0;2³ + 1
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @15
   lda AirplanePlayfieldGraphic,y;4
   sta PF1                    ; 3 = @22
.decrementAirKernelIndex
   dex                        ; 2         reduce kernel index
   stx kernelIndex            ; 3
   lda obstacleSizeAndFineMotion,x;4      get size and fine motion value
   sta NUSIZ0                 ; 3 = @34   set obstacle size
   sta obstacleFineMotion     ; 3         store fine motion of obstacle
   lda #$00                   ; 2
   sta PF1                    ; 3 = @42
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawAirKernel_1;2³ + 1
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @56
   lda AirplanePlayfieldGraphic,y;4
.coarsePositionObstacle
   sty tmpPilotGraphicIndex   ; 3
   sta PF1                    ; 3 = @66
   jmp CoarsePositionObstacle ; 3
   
.skipPilotDrawAirKernel_0
   lda #$00                   ; 2 = @11
   sta PF1                    ; 3 = @14
   sta GRP1                   ; 3 = @17
   SLEEP_3                    ; 3
   jmp .decrementAirKernelIndex;3
   
.skipPilotDrawAirKernel_1
   lda #$00                   ; 2 = @52
   sta PF1                    ; 3 = @55
   sta GRP1                   ; 3 = @58
   jmp .coarsePositionObstacle; 3
   
CoarsePositionObstacle SUBROUTINE
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   lda obstacleHorizCoarseValues,x;4
   tax                        ; 2         move coarse value to x register
   bmi .coarsePositionObstacleCycle25;2³
   cpx #5                     ; 2
   bcs .positionObstacleRight ; 2³
   cpx #2                     ; 2
   bcs .coarsePositionObstacleMid;2³
.coarsePositionObstacleLeft
   dex                        ; 2
   bpl .coarsePositionObstacleLeft;2³
   SLEEP 2                    ; 2
   sta RESP0                  ; 3 = @33
.jmpIntoMoveObstacleLeft
   jsr Sleep12Cycles          ; 6
   lda #$00                   ; 2
   sta PF1                    ; 3 = @50
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .jmpDoneCoarsePositionObstacleLeft;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @59
.jmpDoneCoarsePositionObstacleLeft
   jmp .doneCoarsePositioning ; 3

.coarsePositionObstacleCycle25
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   sta.w RESP0                ; 4 = @25   coarse position to pixel 75
   lda #HMOVE_L6              ; 2
   sta HMP0                   ; 3         set to pixel 69
   jmp .jmpIntoMoveObstacleLeft;3
       
.coarsePositionObstacleMid
   SLEEP_3                    ; 3 = @23
   dex                        ; 2
   dex                        ; 2
   SLEEP_3                    ; 3 = @30
.coarsePositionObstacle
   dex                        ; 2
   bpl .coarsePositionObstacle; 2³
   sta.w RESP0                ; 4 = @48
   lda #$00                   ; 2
   sta PF1                    ; 3 = @53
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .doneCoarsePositionObstacleMid;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @67
.doneCoarsePositionObstacleMid
   jmp .doneCoarsePositioning ; 3

.positionObstacleRight
   sbc #5                     ; 2 = @18
   tax                        ; 2
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcc .drawPilotSprite       ; 2³
   SLEEP_3                    ; 3
   SLEEP_5                    ; 5
   jmp .clearRightPF1Register ; 3
       
.drawPilotSprite
   lda (pilotGraphicPointers),y;5
   SLEEP 2                    ; 2
   sta GRP1                   ; 3 = @37
.clearRightPF1Register
   lda #$00                   ; 2
   sta PF1                    ; 3 = @42
   SLEEP_3                    ; 3
.coarsePositionObstacleRight
   dex                        ; 2
   bpl .coarsePositionObstacleRight;2³
   sta.w RESP0                ; 4
.doneCoarsePositioning
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   cpy #H_PILOT               ; 2
   bcc .drawAirplaneGraphic   ; 2³
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   jmp DetermineObstacleKernel; 3
       
.drawAirplaneGraphic
   lda AirplanePlayfieldGraphic,y;4
   sta PF1                    ; 3 = @15
DetermineObstacleKernel
   ldx kernelIndex            ; 3         get kernel index
   beq GroundObstacleKernel   ; 2² + 1    branch if time to draw ground kernel
   lda.w flyingGeeseGraphicLSB; 4
   sta obstacleGraphicPointers; 3
   lda obstacleFineMotion     ; 3
   sta HMP0                   ; 3 = @33
   lda weatherVaneColor       ; 3
   sta.w COLUP0               ; 4 = @40
   ldx #12                    ; 2
.airObstacleKernel
   lda clearPF1               ; 3
   sta PF1                    ; 3 = @48
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawAirKernelLoop;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @62
   lda AirplanePlayfieldGraphic,y;4
   sta PF1                    ; 3 = @69
   sty tmpPilotGraphicIndex   ; 3
   txa                        ; 2
   tay                        ; 2
.nextAirKernelScanline 
;--------------------------------------
   sta HMOVE                  ; 3
   ldx kernelIndex            ; 3
   lda obstacleGraphicLSBValues,x;4
   sta obstacleGraphicPointers; 3
   lda (obstacleGraphicPointers),y;5
   sta GRP0                   ; 3 = @21
   tya                        ; 2
   tax                        ; 2
   ldy tmpPilotGraphicIndex   ; 3
   lda CXPPMM                 ; 3
   SLEEP_3                    ; 3
   sta HMCLR                  ; 3         clear horizontal motions
   dex                        ; 2
   bpl .airObstacleKernel     ; 2³
   ldx #$00                   ; 2
   stx obstacleFineMotion     ; 3
   stx PF1                    ; 3 = @49
   ldx kernelIndex            ; 3
   dey                        ; 2
   ora CXP0FB                 ; 3
   ora collisionArray,x       ; 4
   sta collisionArray,x       ; 4
   sta CXCLR                  ; 3
   jmp AirObstacleKernel      ; 3
       
.skipPilotDrawAirKernelLoop
   sta GRP1                   ; 3
   sty tmpPilotGraphicIndex   ; 3
   txa                        ; 2
   tay                        ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   jmp .nextAirKernelScanline ; 3
       
GroundObstacleKernel
   lda obstacleFineMotion     ; 3
   sta HMP0                   ; 3 = @28
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   ldx #H_WINDMILL + 14       ; 2
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawGroundKernelLoop;2³
   lda #$00                   ; 2
   sta PF1                    ; 3 = @47
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @55
   lda AirplanePlayfieldGraphic,y;4
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta PF1                    ; 3 = @68
   jmp .nextGroundObstacleKernelScanline;3
       
.skipPilotDrawGroundKernelLoop
   lda #$00                   ; 2
   sta PF1                    ; 3 = @48
   sta GRP1                   ; 3 = @51
.nextGroundObstacleKernelScanline
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Sleep16Cycles          ; 6
   jsr Sleep12Cycles          ; 6
   sta HMCLR                  ; 3 = @33
   lda #$00                   ; 2
   sta PF1                    ; 3 = @38
   inc tmpPilotGraphicIndex   ; 5
   dec tmpPilotGraphicIndex   ; 5
   dey                        ; 2
   cpy #H_PILOT               ; 2
   bcs .determineGroundObstacleSkipPilotDraw;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @62
   lda AirplanePlayfieldGraphic,y;4
   sta PF1                    ; 3 = @69
   jmp DetermineGroundObstacleKernel; 3
       
.determineGroundObstacleSkipPilotDraw
   lda #$00                   ; 2
   sta GRP1                   ; 3 = @60
   sta PF1                    ; 3 = @63
   jmp DetermineGroundObstacleKernel;3    could have fallen through
       
DetermineGroundObstacleKernel
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   lda groundObstacleType     ; 3   get the ground obstacle type
   bne BarnKernel             ; 2³  branch if Barn
   jsr Sleep12Cycles          ; 6
   lda windmillColor          ; 3
   sta COLUP0                 ; 3 = @26
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
.windmillKernel
   dey                        ; 2
   lda #$00                   ; 2
   sta PF1                    ; 3 = @41
   cpy #H_PILOT               ; 2
   bcc .drawPlaneWindmillKernel;2³
   sty tmpPilotGraphicIndex   ; 3
   txa                        ; 2
   tay                        ; 2
   jmp .nextWindmillScanline  ; 3
       
.drawPlaneWindmillKernel
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @54
   lda AirplanePlayfieldGraphic,y;4
   sty tmpPilotGraphicIndex   ; 3
   stx tmpWindmillGraphicIndex; 3
   ldy tmpWindmillGraphicIndex; 3
   sta PF1                    ; 3 = @70
.nextWindmillScanline
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   cpx #H_WINDMILL            ; 2
   bcs .drawWindmillBlades    ; 2³
   lda WindmillGraphics,y     ; 4
   jmp .maskWindmillGraphics  ; 3
       
.drawWindmillBlades
   lda (windmillBladesGraphicPointer),y;5
.maskWindmillGraphics
   and groundObstacleMask     ; 3
   sta GRP0                   ; 3 = @19
   ldy tmpPilotGraphicIndex   ; 3
   dex                        ; 2
   bpl .windmillKernel        ; 2³
   jmp CopyrightKernel        ; 3
       
BarnKernel
   jsr Sleep18Cycles          ; 6
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
.barnKernel
   dey                        ; 2
   lda #$00                   ; 2
   sta PF1                    ; 3 = @41
   cpy #H_PILOT               ; 2
   bcc .drawPlaneBarnKernel   ; 2³
   sta GRP1                   ; 3 = @48
   sty tmpPilotGraphicIndex   ; 3
   txa                        ; 2
   tay                        ; 2
   jmp .drawWeatherVane       ; 3
       
.drawPlaneBarnKernel
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @54
   lda AirplanePlayfieldGraphic,y;4
   sty tmpPilotGraphicIndex   ; 3
   stx tmpBarnGraphicIndex    ; 3
   ldy tmpBarnGraphicIndex    ; 3
   sta PF1                    ; 3 = @70
.drawWeatherVane
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda geeseColor             ; 3
   sta COLUP0                 ; 3 = @09
   lda WeatherVaneGraphics - H_BARN + 1,y;4
   and groundObstacleMask     ; 3
   sta GRP0                   ; 3 = @19
   ldy tmpPilotGraphicIndex   ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   cpx #H_BARN                ; 2
   beq DrawBarn               ; 2³
   dex                        ; 2
   bpl .barnKernel            ; 3         unconditional branch
   
   FILL_BOUNDARY 3, 234             ;  push next routine 3 bytes into next page

.skipPilotDrawForBarnRoof
   sta GRP1                   ; 3 = @50
   sty tmpPilotGraphicIndex   ; 3
   jmp .nextBarnRoofScanline  ; 3
       
DrawBarn
   dex                        ; 2
.drawBarnRoof
   dey                        ; 2
   lda #$00                   ; 2
   sta PF1                    ; 3 = @42
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawForBarnRoof;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @54
   lda AirplanePlayfieldGraphic,y;4
   sty tmpPilotGraphicIndex   ; 3
   SLEEP 2                    ; 2
   sta PF1                    ; 3 = @66
.nextBarnRoofScanline
   txa                        ; 2
   tay                        ; 2
   lda #QUAD_SIZE             ; 2
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   sta NUSIZ0                 ; 3 = @06
   lda BarnColors,y           ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUP0                 ; 3 = @19
   lda barnRoofGraphics       ; 3
   sta GRP0                   ; 3 = @25
   ldy tmpPilotGraphicIndex   ; 3
   dex                        ; 2
   cpx #H_BARN / 2            ; 2
   bcs .drawBarnRoof          ; 2³
   lda #HMOVE_R2              ; 2
   sta HMP0                   ; 3 = @39   shift barn side right 2 pixels
.drawBarnSide
   dey                        ; 2
   lda #$00                   ; 2
   sta PF1                    ; 3 = @46
   cpy #H_PILOT               ; 2
   bcs .skipPilotDrawForBarnSide;2³
   lda (pilotGraphicPointers),y;5
   sta GRP1                   ; 3 = @58
   lda AirplanePlayfieldGraphic,y;4
   sty tmpPilotGraphicIndex   ; 3
   sta PF1                    ; 3 = @68
.nextBarnSideScanline
   txa                        ; 2
   tay                        ; 2
   lda #QUAD_SIZE             ; 2
   SLEEP 2                    ; 2
;--------------------------------------
   sta HMOVE                  ; 3
   sta NUSIZ0                 ; 3 = @06
   lda BarnColors,y           ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUP0                 ; 3 = @19
   lda barnSideGraphics       ; 3
   sta GRP0                   ; 3 = @25
   ldy tmpPilotGraphicIndex   ; 3
   sta HMCLR                  ; 3 = @31
   SLEEP_3                    ; 3
   dex                        ; 2
   bpl .drawBarnSide          ; 2³
   jmp CopyrightKernel        ; 3
   
.skipPilotDrawForBarnSide
   sta GRP1                   ; 3
   sty tmpPilotGraphicIndex   ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   jmp .nextBarnSideScanline  ; 3
       
CopyrightKernel
   lda CXPPMM                 ; 3         read player collision values
   ora CXP0FB                 ; 3         combine with playfield collision
   ora collisionArray         ; 3
   sta collisionArray         ; 3
   sta CXCLR                  ; 3         clear collision registers
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$00                   ; 2
   sta GRP1                   ; 3 = @08
   sta GRP0                   ; 3 = @11
   lda roadColor              ; 3
   sta COLUBK                 ; 3 = @17
   lda copyrightColor         ; 3
   sta COLUP0                 ; 3 = @23
   sta COLUP1                 ; 3 = @26
   lda #THREE_MED_COPIES      ; 2
   sta NUSIZ0                 ; 3 = @31
   sta NUSIZ1                 ; 3 = @34
   ldy #12                    ; 2
.drawFence
   cpy #7                     ; 2
   ldx #DISABLE_BM            ; 2
   bcs .nextFenceLine         ; 2³
   ldx #ENABLE_BM             ; 2
.nextFenceLine
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx ENAM0                  ; 3 = @06
   stx ENAM1                  ; 3 = @09
   lda GroundColors,y         ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUBK                 ; 3 = @22
   dey                        ; 2
   bpl .drawFence             ; 2³
   ldy #2                     ; 2
.drawGround
   lda #DISABLE_BM            ; 2
   ldx groundColor            ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENAM0                  ; 3 = @06
   sta ENAM1                  ; 3 = @09
   stx COLUBK                 ; 3 = @12
   dey                        ; 2
   bpl .drawGround            ; 2³
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   lda copyrightBackgroundColor;3
   sta COLUBK                 ; 3 = @09
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP_3                    ; 3
   ldx #NO_REFLECT            ; 2
   stx HMCLR                  ; 3 = @11
   stx REFP0                  ; 3 = @14
   stx REFP1                  ; 3 = @17
   inx                        ; 2         x = 1
   stx NUSIZ0                 ; 3 = @22   set to TWO_COPIES
   SLEEP_3                    ; 3
   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   inx                        ; 2
   inx                        ; 2
   stx NUSIZ1                 ; 3 = @38   set to THREE_COPIES
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3
   ldy #H_FONT - 1            ; 2
.drawActivitionCopyright
   lda (gameSelectionPointers),y;5
   sta tmpGameSelectionGraphic; 3
   sta WSYNC
;--------------------------------------   
   sta HMOVE                  ; 3
   lda Copyright_0,y          ; 4
   sta GRP0                   ; 3 = @10
   lda Copyright_1,y          ; 4
   sta GRP1                   ; 3 = @17
   SLEEP 2                    ; 2
   lda Copyright_3,y          ; 4
   tax                        ; 2
   lda Copyright_2,y          ; 4
   sta GRP0                   ; 3 = @32
   stx GRP1                   ; 3 = @35
   lda tmpGameSelectionGraphic; 3
   sta GRP1                   ; 3 = @42
   sta HMCLR                  ; 3 = @45
   dey                        ; 2
   bpl .drawActivitionCopyright;2³
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @54
   sty GRP1                   ; 3 = @57
   lda #OVERSCAN_TIME         ; 2
   ldx #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scanline
   sta TIM64T                       ; set time for overscan
   stx VBLANK
   lda #>NumberFonts
   sta barnCountTensPointers + 1
   sta barnCountOnesPointers + 1
   sta gameSelectionPointers + 1    ; set game selection graphic MSB value
   lda barnCountNumber              ; get barn count number
   and #$F0                         ; keep upper nybbles
   lsr                              ; divide by 2 (i.e. multiply by H_FONT)
   bne .setBarnCountTensValue
   lda #<Blank                      ; suppress leading zero
.setBarnCountTensValue
   sta barnCountTensPointers
   ldx gameSelection                ; get current game selection
   inx                              ; increment value to be between 1 and 4
   txa                              ; move game number to accumulator
   asl                              ; multiple by 8 (i.e. H_FONT)
   asl
   asl
   sta gameSelectionPointers        ; set game selection graphic LSB value
   lda barnCountNumber
   and #$0F
   asl
   asl
   asl
   sta barnCountOnesPointers
   ldy #8
   ldx #2
.bcd2DigitLoop
   lda elapsedTime,x                ; get elapsed time
   and #$0F                         ; mask the upper nybbles
   asl                              ; multiply by 8 (i.e. H_FONT)
   asl
   asl
   sta elapsedTimeGraphicPointers,y
   dex
   bmi .doneBCD2Digit
   dey
   dey
   lda elapsedTime + 1,x            ; get elapsed time
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide by 2 (i.e. multiply by H_FONT)
   sta elapsedTimeGraphicPointers,y
   dey
   dey
   bpl .bcd2DigitLoop
.doneBCD2Digit
   cld
   lda gameState                    ; get current game state
   bne AnimateGeese                 ; branch if GAME_OVER
   lda colorCycleMode
   bmi AnimateGeese
AnimateGeese
   lda frameCount                   ; get current frame count
   and #7
   bne .determineHitGooseGraphicLSB ; animate goose every 8th frame
   ldx geeseAnimationIndex          ; get geese animation index
   inx                              ; increment animation index
   txa                              ; move geese animationto accumulator
   and #7
   sta geeseAnimationIndex          ; restrict animation index to less than 8
   tay
   lda GeeseGraphicLSBValues,y
   sta flyingGeeseGraphicLSB
.determineHitGooseGraphicLSB
   ldy #<GeeseGraphics_00
   lda frameCount                   ; get current frame count
   and #1                           ; keep D0 value
   bne .setHitGooseGraphicsLSB      ; branch on odd frame
   ldy #<GeeseGraphics_02
.setHitGooseGraphicsLSB
   sty hitGooseGraphicLSB
   ldx #5
.setAudioValues
   ldy #0
   lda colorCycleMode
   cmp #$20
   bcs .setTIAAudioValues
   lda gameState                    ; get current game state
   bne .setTIAAudioValues           ; branch if GAME_OVER
   ldy audioValues,x
.setTIAAudioValues
   sty AUDC0,x
   dex
   bpl .setAudioValues
   lda pilotCrashTimer              ; get the crash timer value
   bne VerticalSync                 ; branch if plane in crash mode
   lda pilotSpeed                   ; get pilot speed
   cmp #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 73 / 100)
   bcs VerticalSync                 ; branch if higher than 73% of PILOT_MAX_SPEED
   lda planeVertPosition            ; get the plane vertical position
   cmp #YMAX
   bcs VerticalSync
   inc planeVertPosition            ; move plane down
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | START_VERT_SYNC
   sty WSYNC                        ; wait for next scan line
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
   ror colorCycleMode               ; rotate carry to D7 to enable color cycling
ReadConsoleSwitches
   ldy #$FF                         ; assume color mode
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   bne .colorMode
   ldy #$0F                         ; hue mask value for B/W mode
.colorMode
   tya
   ldy #0
   bit colorCycleMode               ; check if in color cycling mode
   bpl .noColorCycling
   and #~BW_MASK
   ldy colorCycleMode
.noColorCycling
   sty colorEOR                     ; set color bits for color cycling mode
   asl colorEOR
   sta colorBWMask                  ; set color mask values for COLOR / B&W mode
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blank period
   lda SWCHA                        ; read the player joystick values
   tay                              ; transfer joystick values to y register
   ldx groundObstacleCollisionTimer ; get ground collision timer value
   beq .shiftJoystickValues
   ldy #P1_JOYSTICK_MASK            ; assume no movement from joystick
.shiftJoystickValues
   tya                              ; move joystick value to accumulator
   lsr                              ; move player 1's joystick value to
   lsr                              ; lower nybble
   lsr
   lsr
   sta playerJoystickValue          ; set player joystick value
   iny                              ; increment joystick value to see if moved
   beq .checkForJoystickButtonPress ; branch if joystick not moved
.clearAttractMode
   lda #0
   sta colorCycleMode
   jmp .checkForSelectAndReset
       
.checkForJoystickButtonPress
   bit INPT4                        ; read left port action button
   bpl .clearAttractMode            ; branch if button pressed
.checkForSelectAndReset
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   bcs .skipGameReset               ; check for SELECT if RESET not pressed
   ldx #<colorCycleMode
   jmp ClearRAM
   
.skipGameReset
   ldy #0
   lsr                              ; SELECT now in carry
   bcs .setSelectDebounceValue      ; branch if SELECT not pressed
   lda selectDebounce               ; get select debound value
   beq .incrementGameSelection
   dec selectDebounce               ; decrement select debounce value
   bpl .determineGameInProgress
.incrementGameSelection
   inc gameSelection
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION
   bne JumpIntoConsoleSwitchCheck
   jsr NextRandom
JumpIntoConsoleSwitchCheck
   lda gameSelection                ; get current game selection
   and #3
   sta gameSelection                ; keep game selection between 0 and 3
   sta colorCycleMode
   lda #(BLANK_OFFSET << 4) | BLANK_OFFSET
   sta barnCountNumber
   sta elapsedTimeMinutes
   sta elapsedTime + 1
   sta elapsedTime + 2
   sta elapsedTimeMicroSeconds
   lda #<Blank
   sta elapsedTimeGraphicPointers + 2
   ldy #SELECT_DELAY
   sty gameState                    ; set to non zero to show GAME_OVER
.setSelectDebounceValue
   sty selectDebounce
.determineGameInProgress
   lda colorCycleMode
   bmi .jmpToMainLoop               ; branch if in color cycling mode
   lda gameState                    ; get current game state
   beq .determinePilotLaunched      ; branch if game in progress
.jmpToMainLoop
   jmp MainLoop

.determinePilotLaunched
   lda pilotLaunchStatus            ; get pilot launch status value
   bne .determineCourseCompleted    ; branch if pilot in flight
   bit INPT4                        ; read left port action button
   bpl .setToPilotLaunched          ; branch if button pressed
   jmp MainLoop
   
.setToPilotLaunched
   lda #1
   sta pilotLaunchStatus
   sta frameCount
.determineCourseCompleted
   bit courseCompleteStatus         ; check course complete status
   bpl .checkForTimeExpiration      ; branch if course not complete
   lda obstacleHorizPositions + 3   ; get first row geese horizontal position
   ora obstacleHorizPositions + 1   ; combine with last geese row position
   ora obstacleHorizPositions + 2   ; combine with middle geese row position
   bne .reducePilotSpeedForLanding  ; branch if geese are flying
   lda planeVertPosition            ; get the plane vertical position
   cmp #YMAX
   bne .reducePilotSpeedForLanding
   lda #<StationaryPilotSprite
   sta pilotGraphicPointers
   inc gameState                    ; increment to non zero to show GAME_OVER
.reducePilotSpeedForLanding
   lda frameCount                   ; get current frame count
   ldx pilotSpeed                   ; get pilot speed
   beq .reducePilotRPMForLanding    ; branch if pilot not moving
   cpx #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 30 / 100)
   bcs .rapidlyReducePilotSpeedForLanding; branch if greater than 30% of max speed
   and #3
   bne .reducePilotRPMForLanding
   dec pilotSpeed                   ; reduce pilot speed every fourth frame
   jmp .reducePilotRPMForLanding
       
.rapidlyReducePilotSpeedForLanding
   and #1
   bne .reducePilotRPMForLanding    ; branch if odd frame
   dec pilotSpeed                   ; reduce pilot speed every second frame
.reducePilotRPMForLanding
   lda frameCount                   ; get current frame count
   and #3
   bne .jmpToScrollGeese
   lda engineRPMs                   ; get engine RPM value
   beq .jmpToScrollGeese            ; branch if not accelerating
   dec engineRPMs                   ; decrement engine RPM value
.jmpToScrollGeese
   jmp ScrollGeese

.checkForTimeExpiration
   lda elapsedTimeMinutes           ; get elapsed time minutes value
   cmp #$05
   bne IncrementElapsedTime         ; branch if timer hasn't reached 5 minutes
   inc gameState                    ; increment to show GAME_OVER
   jmp ScrollGeese

IncrementElapsedTime
   clc
   lda elapsedTimeMicroSeconds      ; get elapsed time micro seconds
   adc #MICRO_SECONDS_DELAY         ; set carry bit if overflow
   sta elapsedTimeMicroSeconds
   lda #1
   sed                              ; set to decimal mode
   adc elapsedTime + 2              ; increment elapsed time milli seconds
   sta elapsedTime + 2
   lda elapsedTime + 1              ; get elapsed time seconds value
   adc #1 - 1
   sta elapsedTime + 1
   cld                              ; clear decimal mode
   cmp #$60                         ; check for reaching 60 seconds
   bcc .doneIncreaseElapsedTime
   lda #0
   sta elapsedTime + 1              ; reset seconds value
   inc elapsedTimeMinutes           ; increment minutes value
.doneIncreaseElapsedTime
   lda frameCount                   ; get current frame count
   and #1
   bne .determineEngineRPMValue     ; branch on odd frame
   bit INPT4                        ; read left port action button
   bmi .pilotNotAccelerating        ; branch if not pressed
   ldx pilotSpeed                   ; get pilot speed
   inx                              ; increment pilot speed
   cpx #PILOT_MAX_SPEED
   bcc .setPilotSpeed
   ldx #PILOT_MAX_SPEED
.setPilotSpeed
   stx pilotSpeed
   lda frameCount                   ; get current frame count
   and #7
   bne .jmpToDetermineEngineRPMValue
   inc engineRPMs                   ; increment engine RPM value
.jmpToDetermineEngineRPMValue
   jmp .determineEngineRPMValue

.pilotNotAccelerating
   lda frameCount                   ; get current frame count
   and #7
   bne .checkToDeceleratePilot
   dec engineRPMs                   ; decrement engine RPM value
.checkToDeceleratePilot
   ldx pilotSpeed                   ; get pilot speed
   cpx #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 36 / 100)
   bcs .deceleratePilot             ; branch if greater than 36% of max speed
   inc pilotSpeed                   ; increment pilot speed
   jmp .determineEngineRPMValue
       
.deceleratePilot
   beq .determineEngineRPMValue
   dec pilotSpeed                   ; reduce pilot speed
.determineEngineRPMValue
   lda engineRPMs                   ; get engine RPM value
   bpl .restrictEngineRPMValue
   lda #RPM_MIN
.restrictEngineRPMValue
   cmp #RPM_MAX + 1
   bcc .setEngineRPMValue
   lda #RPM_MAX
.setEngineRPMValue
   sta engineRPMs
   ldx #0
   lda frameCount                   ; get current frame count
   and #1
   bne ScrollGeese                  ; branch on odd frame
   lda playerJoystickValue          ; get joystick values
   eor #$0F
   and #([~P0_VERT_MOVE] >> 4) & $0F; keep vertical movement values
   beq .setObstacleSpeed
   lda obstacleSpeed                ; get obstacle speed
   clc
   adc #5                           ; increment obstacle speed by 5
   cmp #OBSTACLE_MAX_SPEED
   bcc .restrictObstacleSpeed       ; branch if less than max speed
   lda #OBSTACLE_MAX_SPEED          ; keep obstacle speed constrained
.restrictObstacleSpeed
   tax
.setObstacleSpeed
   stx obstacleSpeed
ScrollGeese
   nop
   lda geeseSpawningValues
   ldx #3
.scrollGooseLoop
   sta tmpGeeseSpawningValue
   and #1
   beq .nextGooseScroll
   lda obstacleHorizPositions,x     ; get goose horizontal position
   bne .scrollGoose                 ; branch if not reached left side
   lda #W_SCREEN
.scrollGoose
   ldy horizMotionDelay             ; get horizontal motion delay
   dey                              ; decrement horizontal motion delay
   sty tmpHorizMotionDelay
   sec
   sbc tmpHorizMotionDelay          ; subtract delay from horizontal position
   sta tmpGooseHorizPosition        ; set goos new horizontal position
   beq .gooseScrollOutOfView        ; branch if reached left side
   cmp #W_SCREEN + 1
   bcs .gooseScrollOutOfView        ; branch if wrapped to right side
   lda obstacleSizeAndFineMotion,x  ; get goose size and fine motion
   and #$F0                         ; clear old NUSIZ value
   sta obstacleSizeAndFineMotion,x
   ldy geeseNUSIZValues - 1,x
   lda tmpGooseHorizPosition
   cmp GooseNUSIZMaxHorizPosition,y
   bcs .setGooseHorizontalPosition
   lda obstacleSizeAndFineMotion,x  ; get obstacle size and fine motion
   ora geeseNUSIZValues - 1,x       ; combine with goose NUSIZ value
   sta obstacleSizeAndFineMotion,x
   lda tmpGooseHorizPosition        ; get derived horizontal position
   jmp .setGooseHorizontalPosition  ; set goose new horizontal position
;
; The next 11 bytes of code were repeated from above and left in the production
; ROM but not used
;
   lda obstacleSizeAndFineMotion,x  ; get obstacle size and fine motion
   ora geeseNUSIZValues - 1,x       ; combine with goose NUSIZ value
   sta obstacleSizeAndFineMotion,x
   lda tmpGooseHorizPosition        ; get derived horizontal position
   jmp .setGooseHorizontalPosition  ; set goose new horizontal position
       
.gooseScrollOutOfView
   lda obstacleSizeAndFineMotion,x  ; get obstacle size and fine motion
   and #$0F                         ; keep obstacle NUSIZ value
   cmp #ONE_COPY
   beq .setGooseNUSIZValue          ; branch if only one copy of goose
   tay                              ; move NUSIZ to y register
   lda InitialGooseHorizPosition,y
   sta obstacleHorizPositions,x     ; set goose horizontal position
   lda obstacleSizeAndFineMotion,x  ; get obstacle size and fine motion
   and #$F0                         ; keep fine motion value
   sta obstacleSizeAndFineMotion,x  ; set goose NUSIZ value to ONE_COPY
   lda #ONE_COPY
   sta geeseNUSIZValues - 1,x
   jmp .nextGooseScroll
       
.setGooseNUSIZValue
   inc geeseNUSIZIndexes - 1,x      ; increment index to NUSIZ table
   lda geeseNUSIZIndexes - 1,x      ; get index for NUSIZ table
   and #3
   sta geeseNUSIZIndexes - 1,x      ; restrict value to less than 4
   tay                              ; move NUSIZ index to y register
   stx tmpScrollingGooseIndex       ; save the current goose index for later
   ldx gameSelection                ; get current game selection
   lda #>GeeseNUSIZTable
   sta gameVariationsPointers + 1
   lda GeeseNUSIZLSBValues,x
   sta gameVariationsPointers       ; set game variation pointer for NUSIZ value
   lda (gameVariationsPointers),y
   ldx tmpScrollingGooseIndex       ; reset current goose index to x register
   sta geeseNUSIZValues - 1,x       ; set new NUSIZ value for goose
   lda GooseSpawningValues,x
   eor geeseSpawningValues
   sta geeseSpawningValues
   lda #XMIN
.setGooseHorizontalPosition
   sta obstacleHorizPositions,x     ; set obstacle horizontal position
.nextGooseScroll
   lda tmpGeeseSpawningValue
   lsr
   dex
   beq AnimatePilotAndWindmillBlades
   jmp .scrollGooseLoop
       
AnimatePilotAndWindmillBlades
   lda gameState                    ; get current game state
   bne .reducePilotCrashTimer       ; branch if GAME_OVER
   lda frameCount                   ; get current frame count
   and #1
   bne .animatePilot                ; branch on odd frame
   bit INPT4                        ; read left port action button
   bpl .incrementPilotAnimationIndex; increment animation every other frame
   lda frameCount                   ; get current frame count
   and #3
   bne .animatePilot
.incrementPilotAnimationIndex
   inc pilotAnimationIndex
.animatePilot
   ldx pilotAnimationIndex          ; get pilot animation index
   cpx #MAX_PILOT_ANIMATION
   bcc .setPilotGraphicLSBValue
   ldx #0
   stx pilotAnimationIndex          ; reset animation index value
.setPilotGraphicLSBValue
   lda PilotGraphicLSBValues,x
   sta pilotGraphicPointers
   lda frameCount                   ; get current frame count
   and #3
   bne AnimateWindmillBlades
   inc windmillAnimationIndex       ; increment animation index every 4 frames
AnimateWindmillBlades
   ldx windmillAnimationIndex       ; get windmill animation index
   cpx #3
   bcc .setWindmillGraphicPointers
   ldx #0
.setWindmillGraphicPointers
   stx windmillAnimationIndex
   lda WindmillBladeGraphicLSBValues,x
   sta windmillBladesGraphicPointer
   lda #>WindmillBladeGraphics
   sta windmillBladesGraphicPointer + 1
.reducePilotCrashTimer
   ldx pilotCrashTimer              ; get crash timer value
   beq .checkToReduceTimeInBarn
   dex
   stx pilotCrashTimer
.checkToReduceTimeInBarn
   ldx timeInBarn                   ; get time value for being in barn
   beq SetGeeseGraphicPointers
   dex                              ; reduce time in barn value
   stx timeInBarn                   ; set new time in barn value
SetGeeseGraphicPointers
   ldx #3
.setGeeseGraphicPointers
   lda flyingGeeseGraphicLSB
   sta obstacleGraphicLSBValues,x
   dex
   bne .setGeeseGraphicPointers
   stx audioVolume01Value           ; x = 0
   lda #31
   sec
   sbc engineRPMs
   sta audioFrequence00Value
   lda #10
   sta audioChannel00Value
   lda frameCount                   ; get current frame count
   and #3
   bne .setVolumeForEngineValue     ; branch if not divisible by 4
   inc engineVolume                 ; increment engine volume
   lda engineVolume                 ; get engine volume value
   cmp #3
   bcc .setEngineVolumeValue
   lda #3
.setEngineVolumeValue
   sta engineVolume
.setVolumeForEngineValue
   lda engineVolume                 ; get engine volume value
   tay                              ; transfer value to y register
   bit INPT4                        ; read left port action button
   bmi .setAudioVolumeForChannel_0  ; branch if not pressed
   iny                              ; increment value for volume
.setAudioVolumeForChannel_0
   sty audioVolume00Value
   ldy groundObstacleTableIndex
   lda #>GroundObstacleGenerationTable
   sta gameVariationsPointers + 1
   ldx gameSelection                ; get current game selection
   lda GoundObstacleGenerationLSBValues,x
   sta gameVariationsPointers
   lda (gameVariationsPointers),y
   sta tmpGameVariationValue
   lda groundObstacleHorizPosition  ; get ground obstacle horizontal position
   cmp #64
   bcs .reduceGroundObstacleCollisionTimer
   ldy #10
   sty audioChannel01Value
   ldy #21
   sty audioFrequence01Value
   cmp #PLAYER_XMIN + 8
   bcc .determineAudioVolume_01
   dec audioFrequence01Value
   eor #$3F
.determineAudioVolume_01
   lsr
   ldy planeVertPosition            ; get the plane vertical position
   cpy #85
   bcc .setAudioVolume_01Value
   lda #$00
.setAudioVolume_01Value
   and groundObstacleMask
   sta audioVolume01Value
.reduceGroundObstacleCollisionTimer
   ldx groundObstacleCollisionTimer ; get ground collision timer value
   beq .checkCollisions             ; branch if reached 0
   dex                              ; decrement ground collision timer value
   stx groundObstacleCollisionTimer
   jmp DeterminePlaneShakeFromCollision
       
.checkCollisions
   dex                              ; x = -1
   stx collisionIndicator
   bit collisionArray               ; check ground obstacle collision registers
   bmi PilotCollidedWithGroundObstacle; branch if a collision occurred
   jmp CheckGeeseCollision
       
PilotCollidedWithGroundObstacle
   lda tmpGameVariationValue        ; get current obstacle value
   lsr
   bcs .pilotCrashIntoGroundObstacle; branch if ground obstacle is a Windmill
   lda barnHorizPosition            ; get barn horizontal position
   sec
   sbc #24
   cmp #PLAYER_XMIN + 10
   bcs .determineBarnClearance
   lda #1
   sta audioVolume00Value
   lda #0
   sta audioVolume01Value
.determineBarnClearance
   lda barnHorizPosition            ; get barn horizontal position
   cmp #PLAYER_XMIN - 12
   bcc .checkToReduceBarnCount
   lda #BARN_CLEARANCE_AMATEUR
   bit SWCHB                        ; check difficulty switches
   bvc .setBarnClearanceValue       ; branch if left difficulty set to AMATEUR
   lda #BARN_CLEARNACE_PRO
.setBarnClearanceValue
   sta tmpBarnClearance
   lda planeVertPosition            ; get the plane vertical position
   cmp tmpBarnClearance             ; compare with barn clearance
   bcc .pilotCrashIntoGroundObstacle; branch if pilot hit side of barn
.checkToReduceBarnCount
   ldy timeInBarn                   ; get time in barn value
   bne .doneCheckBarnCollision
   lda #80
   sta timeInBarn
   lda barnHorizPosition            ; get barn horizontal position
   cmp #48
   bcc .doneCheckBarnCollision
   lda barnCountNumber              ; get current barn count
   beq .doneCheckBarnCollision
   sed                              ; set to decimal mode
   sec
   sbc #1                           ; reduce barn count by 1
   sta barnCountNumber
   bne .doneCheckBarnCollision
   dec courseCompleteStatus         ; decrement to show course completed
.doneCheckBarnCollision
   cld
   jmp CheckGeeseCollision
       
.pilotCrashIntoGroundObstacle
   lda #70
   sta pilotCrashTimer
   lsr                              ; divide value by 2 (i.e. a = 35)
   sta groundObstacleCollisionTimer
DeterminePlaneShakeFromCollision
   lda #8
   sta audioChannel01Value
   ldx #0
   stx audioVolume00Value
   stx engineRPMs
   stx collisionArray               ; clear ground collision registers
   lda groundObstacleCollisionTimer ; get ground collision timer value
   lsr
   sta audioVolume01Value
   lda collisionIndicator
   bmi .continuePilotCollisionChecks
   lda planeVertPosition            ; get the plane vertical position
   ldx collisionIndicator
   cpx #1
   beq .shakePilotForInsideBarnCollision; branch if pilot hit inside of barn
   clc
   adc #4                           ; move plane down 4 scanlines
   tax                              ; move plane new vertical position to x
   lda frameCount                   ; get current frame count
   and #1
   bne .jmpToSetPlaneVertPositionForCrash; branch on odd frame
   txa                              ; move plane new vertical position to a
   sec
   sbc #9                           ; move plance up 9 scanlines (i.e. 5 from original)
   tax                              ; move plane new vertical position to x
.jmpToSetPlaneVertPositionForCrash
   jmp .setPlaneVertPositionFromCrash

.shakePilotForInsideBarnCollision
   clc
   adc #5                           ; move plane down 5 scanlines
   tax                              ; move plane new vertical position to x
   lda frameCount                   ; get current frame count
   and #1
   bne .setPlaneVertPositionFromCrash; branch on odd frame
   txa                              ; move plane new vertical position to a
   sec
   sbc #6                           ; move plane up 6 scanlines (i.e. 1 from original)
   cmp #BARN_CLEARANCE_AMATEUR
   bcs .setRegisterToPlaneVertPosition
   clc
   adc #2                           ; move plane down 2 scanlines
.setRegisterToPlaneVertPosition
   tax
.setPlaneVertPositionFromCrash
   stx planeVertPosition
   lda collisionIndicator
   bmi .continuePilotCollisionChecks
   beq .pilotHitTopOfGroundObstacle
   lsr
   bcs .pilotHitBarnRoofInsideBarn
   jmp .setPilotSpeedForGroundCollision
       
.continuePilotCollisionChecks
   lda tmpGameVariationValue        ; get current obstacle value
   lsr
   bcs .pilotCollidedWithWindmill   ; branch if ground obstacle is a Windmill
   lda barnHorizPosition            ; get barn horizontal position
   cmp #57
   bcs .setPilotSpeedForGroundCollision
   lda planeVertPosition            ; get the plane vertical position
   cmp #(YMAX - YMIN) - [(YMAX - YMIN) * 15 / 100]
   bcc .pilotHitTopOfGroundObstacle ; branch if less than 15% of play area
.pilotHitBarnRoofInsideBarn
   lda #1
   sta collisionIndicator
   lda #1
   sta horizMotionDelay             ; set horizontal motion delay
   lda #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 90 / 100)
   sta pilotSpeed                   ; set to 90% of max speed
   jmp CheckGeeseCollision
       
.pilotHitTopOfGroundObstacle
   lda #1
   sta horizMotionDelay             ; set horizontal motion delay
   lda #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 90 / 100)
   sta pilotSpeed                   ; set to 90% of max speed
   lda #0
   sta collisionIndicator
   jmp CheckGeeseCollision
       
.pilotCollidedWithWindmill
   lda groundObstacleHorizPosition  ; get Windmill horizontal position
   cmp #PLAYER_XMIN + 8
   bcc .pilotHitTopOfGroundObstacle ; branch if Windmill left of pilot plane
.setPilotSpeedForGroundCollision
   ldx #PILOT_MIN_SPEED             ; get pilot minimum speed value
   stx pilotSpeed                   ; set pilot speed to minimum speed value
   dex                              ; x = -1
   stx horizMotionDelay             ; set horizontal motion delay to -1
   lda #2
   sta collisionIndicator
   jmp CheckGeeseCollision
       
CheckGeeseCollision
   ldx #3
.checkGeeseCollision
   ldy obstacleCollisionTimers,x
   beq .reduceSpeedForGooseCollision
   dey                              ; reduce obstacle collision timer
   sty obstacleCollisionTimers,x
   cpy #39
   bcc .setHitGooseHorizPosition
   lda #12
   sta audioChannel01Value
   lda #31
   sta audioFrequence01Value
   lda #5
   sta audioVolume01Value
.setHitGooseHorizPosition
   ldy obstacleHorizPositions,x     ; get obstacle horizontal position
   beq .nextGooseCollision          ; branch if goose left side of screen
   iny                              ; increment goose horizontal position
   iny
   sty obstacleHorizPositions,x     ; set new horizontal position for goose
   lda hitGooseGraphicLSB
   sta obstacleGraphicLSBValues,x   ; set goos graphic to hit goose
   lda #0
   sta collisionArray,x             ; clear collision register
   jmp .nextGooseCollision
       
.reduceSpeedForGooseCollision
   lda collisionArray,x             ; check collision value for goose
   bpl .nextGooseCollision          ; branch if didn't collide with goose
   lda #0
   sta engineRPMs
   lda #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 57 / 100)
   sta pilotSpeed                   ; reduce speed to 57% of maximum
   lda #48
   sta obstacleCollisionTimers,x
.nextGooseCollision
   dex
   bne .checkGeeseCollision
   ldx #<[pilotSpeed - speedValues]
   lda groundObstacleCollisionTimer ; get ground collision timer value
   beq .determineMotionDelayValues  ; branch if reached 0
   ldx #<[obstacleSpeed - speedValues]
.determineMotionDelayValues
   lda speedValues,x                ; get speed values
   cpx #<[pilotSpeed - speedValues]
   bne .determineMotionDelayValue   ; branch if doing obstacle speed
   lda playerJoystickValue          ; get joystick values
   and #([~P0_VERT_MOVE] >> 4) & $0F; keep vertical movement values
   cmp #([~P0_VERT_MOVE] >> 4) & $0F
   lda pilotSpeed                   ; get pilot speed
   bcs .determineMotionDelayValue   ; branch if not moving vertically
   lsr                              ; divide pilot speed by 16
   lsr
   lsr
   lsr
   sta tmpPilotSpeedDiv16
   sec
   lda pilotSpeed                   ; get pilot speed
   sbc tmpPilotSpeedDiv16           ; reduce by ~6% for vertical movement
.determineMotionDelayValue
   sta tmpSpeed                     ; set temporary speed
   lsr                              ; divide speed by 16
   lsr
   lsr
   lsr
   sta motionDelayValues,x          ; set motion delay value
   lda tmpSpeed                     ; get temporary speed
   and #$0F                         ; mod 16
   clc
   adc fractionalDelayValues,x      ; increment by fractional delay
   cmp #16
   bcc .setNewFractionalDelayValue
   inc motionDelayValues,x          ; increment when greater than 16
.setNewFractionalDelayValue
   and #$0F
   sta fractionalDelayValues,x
   dex
   bpl .determineMotionDelayValues
   bit courseCompleteStatus         ; check course complete status
   bmi ScrollFencePosts             ; branch if course completed
   lda playerJoystickValue          ; get joystick values
   and #([~MOVE_DOWN] >> 4) & $0F
   bne .checkForPilotAscending      ; branch if joystick not pulled down
   lda planeVertPosition            ; get the plane vertical position
   clc
   adc vertMotionDelay              ; increment by motion delay
   sta planeVertPosition            ; set plane vertical position
.checkForPilotAscending
   lda playerJoystickValue          ; get joystick values
   and #([~MOVE_UP] >> 4) & $0F
   bne .checkMinimumVertBounds      ; branch if joystick not pushed up
   lda planeVertPosition            ; get the plane vertical position
   sec
   sbc vertMotionDelay              ; decrement by motion delay
   sta planeVertPosition            ; set plane vertical position
.checkMinimumVertBounds
   lda planeVertPosition            ; get the plane vertical position
   cmp #YMIN
   bcs .checkMaximumVertBounds      ; branch if within minimum range
   lda #YMIN
.checkMaximumVertBounds
   cmp #YMAX + 1
   bcc .setPlaneVerticalPosition    ; branch if within maximum range
   lda #YMAX
.setPlaneVerticalPosition
   sta planeVertPosition
ScrollFencePosts
   lda fencePostHorizPosition       ; get fence post horizontal position
   sec
   sbc horizMotionDelay             ; move left by motion delay value
   sta tmpFencePostHorizPosition    ; set temporary post horizontal position
   cmp #W_SCREEN
   bne .scrollFencePosts            ; branch if not on right side
   lda #XMIN
   jmp .setFencePostHorizPosition
       
.scrollFencePosts
   cmp #XMAX
   bcc .setFencePostHorizPosition   ; branch if less than horizontal max
   sec
   lda #XMIN
   sbc tmpFencePostHorizPosition
   sta tmpFencePostHorizPosition
   sec
   lda #W_SCREEN
   sbc tmpFencePostHorizPosition
.setFencePostHorizPosition
   sta fencePostHorizPosition
   lda groundObstacleType           ; get ground obstacle type
   beq ScrollWindmill               ; branch if windmill
   sec
   lda barnHorizPosition            ; get barn horizontal position
   sbc horizMotionDelay
   cmp #XMAX
   bcc .setBarnHorizontalPosition
   lda #XMIN
   sta groundObstacleHorizPosition  ; set ground obstacle horizontal position
.setBarnHorizontalPosition
   sta barnHorizPosition            ; set barn horizontal position
   bne .jmpToSetBarnGraphics        ; branch if not reached left side
   jmp SpawnGroundObstacle
       
.jmpToSetBarnGraphics
   jmp SetBarnGraphics

ScrollWindmill
   sec
   lda groundObstacleHorizPosition  ; get ground obstacle horizontal position
   sbc horizMotionDelay
   cmp #XMAX
   bcc .setWindmillHorizPosition
   lda #XMIN
.setWindmillHorizPosition
   sta groundObstacleHorizPosition  ; set ground obstacle horizontal position
   beq SpawnGroundObstacle
   jmp .determineGeeseSpawningValues
       
SpawnGroundObstacle
   ldx #0
   stx collisionArray               ; clear ground collision values
   dex                              ; x = #$FF
   stx groundObstacleMask           ; set to show ground obstacle
   inc groundObstacleTableIndex
   lda groundObstacleTableIndex
   and #63
   sta groundObstacleTableIndex
   tay
   lda #>GroundObstacleGenerationTable
   sta gameVariationsPointers + 1
   ldx gameSelection                ; get current game selection
   lda GoundObstacleGenerationLSBValues,x
   sta gameVariationsPointers
   lda (gameVariationsPointers),y
   beq .setToNoGroundObstacle
   lsr
   bcs .setToSpawnWindmillObstacle
   jmp .setToSpawnBarnObstacle
       
.setToNoGroundObstacle
   lda #TYPE_WINDMILL
   sta groundObstacleType           ; set obstacle type to TYPE_WINDMILL
   sta groundObstacleMask           ; set not to show ground obstacle
   lda #W_SCREEN - 1
   sta groundObstacleHorizPosition  ; set ground obstacle horizontal position
   jmp .determineGeeseSpawningValues
       
.setToSpawnWindmillObstacle
   ldx #TYPE_WINDMILL
   stx groundObstacleType           ; set obstacle type to TYPE_WINDMILL
   dex                              ; x = #$FF
   stx groundObstacleMask           ; set to show ground obstacle
   lda #W_SCREEN - 1
   sta groundObstacleHorizPosition  ; set ground obstacle horizontal position
   jmp .determineGeeseSpawningValues
       
.setToSpawnBarnObstacle
   sta groundObstacleType
   lda #W_SCREEN + 23
   sta barnHorizPosition
   jmp SetBarnGraphics
       
SetBarnGraphics
   lda #$FF
   sta barnRoofGraphics             ; set barn roof graphic value
   lda #$FE
   sta barnSideGraphics             ; set barn side graphic value
   lda barnHorizPosition            ; get barn horizontal position
   cmp #W_SCREEN
   bcc .checkForBarnScrollingOffLeftSide; branch if not off right side
   sbc #W_SCREEN                    ; subtract screen width from position
   lsr                              ; divide value by 4
   lsr
   tax
   jmp ScrollBarn
       
.checkForBarnScrollingOffLeftSide
   cmp #PLAYER_XMIN
   bcc .barnScrollingOffLeftSide    ; branch if barn left of player plane
   ldx #6
   jmp ScrollBarn
       
.barnScrollingOffLeftSide
   ldx #0
   stx groundObstacleMask           ; set to not show ground obstacle
   lsr                              ; divide barn position by 4
   lsr
   clc
   adc #7                           ; add 7 for scrolling barn mask value
   tax
ScrollBarn
   ldy #<[barnSideGraphics - barnGraphics]
.scrollBarn
   lda barnGraphics,y
   and ScrollingBarnGraphicsMaskValues,x
   sta barnGraphics,y
   dey
   bpl .scrollBarn
   lda barnHorizPosition            ; get barn horizontal position
   sec
   sbc #24
   cmp #224
   bcc .setGroundObstacleHorizPosition
   sec                              ; not needed...carry already set
   sbc #96
.setGroundObstacleHorizPosition
   sta groundObstacleHorizPosition  ; set ground obstacle horizontal position
.determineGeeseSpawningValues
   ldx pilotSpeed                   ; get pilot speed
   cpx #PILOT_MAX_SPEED - (PILOT_MAX_SPEED * 14 / 100)
   bcc .doneScrollingGroundObstacle ; branch if less than 14% of max speed
   lda #63                          ; assume to spawn geese every ~60 frames
   bit SWCHB                        ; check difficulty switches
   bpl .setGeeseSpawningRateValue   ; branch if right difficulty set to AMATEUR
   lsr                              ; divide geese spwaning timer by 2
.setGeeseSpawningRateValue
   sta tmpGeeseSpawningRate
   lda frameCount                   ; get current frame count
   and tmpGeeseSpawningRate
   bne .setGeeseSpawningIndex       ; skip increment of spawing index
   inc geeseSpawningIndex
.setGeeseSpawningIndex
   lda geeseSpawningIndex           ; get geese spawning index value
   and #$0F                         ; make sure value less than 15
   sta geeseSpawningIndex
   tay                              ; move geese spawning index to y-register
   ldx gameSelection                ; get current game selection
   lda #>GeeseSpawningVariationValues
   sta gameVariationsPointers + 1
   lda GeeseSpawningLSBValues,x
   sta gameVariationsPointers
   lda (gameVariationsPointers),y
   ora geeseSpawningValues
   sta geeseSpawningValues
.doneScrollingGroundObstacle
   jmp MainLoop

   FILL_BOUNDARY 0, 234
   
GroundObstacleGenerationTable
HedgeHopperGroundObstacleGenerationValues
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, NO_GROUND_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte NO_GROUND_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, NO_GROUND_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, NO_GROUND_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE

CropDusterGroundObstacleGenerationValues
   .byte SHOW_WINDMILL_OBSTACLE, NO_GROUND_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE

StuntPilotGroundObstacleGenerationValues
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, NO_GROUND_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE

FlyingAceGroundObstacleGenerationValues
   .byte NO_GROUND_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, NO_GROUND_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, NO_GROUND_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte NO_GROUND_OBSTACLE, SHOW_BARN_OBSTACLE, SHOW_BARN_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE, SHOW_WINDMILL_OBSTACLE
   .byte SHOW_WINDMILL_OBSTACLE, SHOW_BARN_OBSTACLE

GoundObstacleGenerationLSBValues
   .byte <HedgeHopperGroundObstacleGenerationValues
   .byte <CropDusterGroundObstacleGenerationValues
   .byte <StuntPilotGroundObstacleGenerationValues
   .byte <FlyingAceGroundObstacleGenerationValues
   
GeeseSpawningLSBValues
   .byte <HedgeHopperGeeseSpawingValues
   .byte <CropDusterGeeseSpawingValues
   .byte <StuntPilotGeeseSpawningValues
   .byte <FlyingAceGeeseSpawningValues
   
GeeseNUSIZLSBValues
   .byte <HedgeHopperGeeseNUSIZTable
   .byte <CropDusterGeeseNUZIZTable
   .byte <StuntPilotGeeseNUSIZTable
   .byte <FlyingAceGeeseNUSIZTable
   
GooseSpawningValues
   .byte SPAWN_NO_GOOSE             ; never used or referenced
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   
ScrollingBarnGraphicsMaskValues
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $F0 ; |XXXX....|
   .byte $E0 ; |XXX.....|
   .byte $C0 ; |XX......|
   .byte $80 ; |X.......|
   .byte $FF ; |XXXXXXXX|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   
InitialGooseHorizPosition
   .byte XMIN                       ; ONE_COPY...not used
   .byte 16                         ; TWO_COPIES
   .byte 32                         ; TWO_MED_COPIES
   .byte 32                         ; THREE_COPIES
   .byte 64                         ; TWO_WIDE_COPIES
   
GooseNUSIZMaxHorizPosition
   .byte XMIN                       ; ONE_COPY
   .byte 144                        ; TWO_COPIES
   .byte 128                        ; TWO_MED_COPIES
   .byte 128                        ; THREE_COPIES
   .byte 96                         ; TWO_WIDE_COPIES
   
GeeseNUSIZTable
HedgeHopperGeeseNUSIZTable
CropDusterGeeseNUZIZTable
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
StuntPilotGeeseNUSIZTable
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
   .byte TWO_WIDE_COPIES
FlyingAceGeeseNUSIZTable
   .byte TWO_WIDE_COPIES
   .byte ONE_COPY
   .byte TWO_MED_COPIES
   .byte TWO_WIDE_COPIES
   
GeeseSpawningVariationValues
HedgeHopperGeeseSpawingValues
CropDusterGeeseSpawingValues
   .byte SPAWN_NO_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_BOTTOM_GOOSE | SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE

StuntPilotGeeseSpawningValues   
   .byte SPAWN_NO_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE

FlyingAceGeeseSpawningValues
   .byte SPAWN_NO_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_BOTTOM_GOOSE | SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_BOTTOM_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
   .byte SPAWN_TOP_GOOSE
   .byte SPAWN_MIDDLE_GOOSE
       
InitializeGameVariables
   lda #<GeeseGraphics_00
   sta obstacleGraphicPointers
   sta flyingGeeseGraphicLSB
   lda #>GeeseGraphics
   sta obstacleGraphicPointers + 1
   lda #<StationaryPilotSprite
   sta pilotGraphicPointers
   lda #>StationaryPilotSprite
   sta pilotGraphicPointers + 1
   lda #>NumberFonts
   sta elapsedTimeGraphicPointers + 1
   sta elapsedTimeGraphicPointers + 3
   sta elapsedTimeGraphicPointers + 5
   sta elapsedTimeGraphicPointers + 7
   sta elapsedTimeGraphicPointers + 9
   sta barnCountTensPointers + 1
   sta barnCountOnesPointers + 1
   lda #0
   ldx gameSelection                ; get current game selection
   cpx #MAX_GAME_SELECTION
   bne .setGroundObstacleTableIndex
   lda randomSeed
   and #$3F
.setGroundObstacleTableIndex
   sta groundObstacleTableIndex
   and #$0F
   sta geeseSpawningIndex
   lda InitBarnNumber,x             ; get the starting number of barns (BCD)
   sta barnCountNumber              ; set initial barn number
   lda #YMAX
   sta planeVertPosition
   lda #1
   sta geeseNUSIZIndexes
   sta geeseNUSIZIndexes + 1
   sta geeseNUSIZIndexes + 2
   ldx #<[groundObstacleMask - flyingGeeseGraphicLSB]
.initValues
   lda #0
   sta flyingGeeseGraphicLSB,x
   dex
   bpl .initValues
   rts

HMOVEObject
   jsr PositionObjectHorizontally;6
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   rts                        ; 6
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
Sleep18Cycles
   asl
Sleep16Cycles
   asl
   asl
Sleep12Cycles
   rts

PositionObjectHorizontally
   jsr CalculateObjectHorizPosition
   sta HMP0,x                       ; set object's fine motion value
   sta WSYNC                        ; wait for next scan line
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; reset object's coarse position
   rts

NextRandom
   lda randomSeed
   asl
   asl
   asl
   eor randomSeed
   asl
   rol randomSeed
   lda randomSeed
   rts

TimeDigitColonSprite
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
TimeDigitDecimalSprite
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
MountainsPF1Graphics
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $1F ; |...XXXXX|
   .byte $0E ; |....XXX.|
   .byte $04 ; |.....X..|
   
MountainsPF2Graphics
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0F ; |....XXXX|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY 0, 234
       
NumberFonts
zero
   .byte $78 ; |.XXXX...|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $78 ; |.XXXX...|
one
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $70 ; |.XXX....|
   .byte $30 ; |..XX....|
two
   .byte $FC ; |XXXXXX..|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $78 ; |.XXXX...|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $8C ; |X...XX..|
   .byte $78 ; |.XXXX...|
three
   .byte $78 ; |.XXXX...|
   .byte $8C ; |X...XX..|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $8C ; |X...XX..|
   .byte $78 ; |.XXXX...|
four
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $FC ; |XXXXXX..|
   .byte $98 ; |X..XX...|
   .byte $58 ; |.X.XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
five
   .byte $F8 ; |XXXXX...|
   .byte $8C ; |X...XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $F8 ; |XXXXX...|
   .byte $C0 ; |XX......|
   .byte $C0 ; |XX......|
   .byte $FC ; |XXXXXX..|
six
   .byte $78 ; |.XXXX...|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $F8 ; |XXXXX...|
   .byte $C0 ; |XX......|
   .byte $C4 ; |XX...X..|
   .byte $78 ; |.XXXX...|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $84 ; |X....X..|
   .byte $FC ; |XXXXXX..|
eight
   .byte $78 ; |.XXXX...|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $78 ; |.XXXX...|
   .byte $78 ; |.XXXX...|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $78 ; |.XXXX...|
nine
   .byte $78 ; |.XXXX...|
   .byte $8C ; |X...XX..|
   .byte $0C ; |....XX..|
   .byte $7C ; |.XXXXX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $CC ; |XX..XX..|
   .byte $78 ; |.XXXX...|
       
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
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
   
PilotGraphicLSBValues
   .byte <PilotAnimation_00, <PilotAnimation_01, <PilotAnimation_02
   
PilotAnimation_00
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $FC ; |XXXXXX..|
   .byte $FD ; |XXXXXX.X|
   .byte $A1 ; |X.X....X|
   .byte $40 ; |.X......|
   .byte $11 ; |...X...X|
   .byte $21 ; |..X....X|
   .byte $08 ; |....X...|
   .byte $31 ; |..XX...X|
   .byte $65 ; |.XX..X.X|
   .byte $B0 ; |X.XX....|
   .byte $31 ; |..XX...X|
   .byte $04 ; |.....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
PilotAnimation_01
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $FD ; |XXXXXX.X|
   .byte $FD ; |XXXXXX.X|
   .byte $A0 ; |X.X.....|
   .byte $41 ; |.X.....X|
   .byte $11 ; |...X...X|
   .byte $20 ; |..X.....|
   .byte $09 ; |....X..X|
   .byte $B1 ; |X.XX...X|
   .byte $64 ; |.XX..X..|
   .byte $31 ; |..XX...X|
   .byte $31 ; |..XX...X|
   .byte $04 ; |.....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
PilotAnimation_02   
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $FD ; |XXXXXX.X|
   .byte $FC ; |XXXXXX..|
   .byte $A1 ; |X.X....X|
   .byte $41 ; |.X.....X|
   .byte $10 ; |...X....|
   .byte $21 ; |..X....X|
   .byte $09 ; |....X..X|
   .byte $30 ; |..XX....|
   .byte $E5 ; |XXX..X.X|
   .byte $31 ; |..XX...X|
   .byte $30 ; |..XX....|
   .byte $04 ; |.....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   
GeeseGraphicLSBValues
   .byte <GeeseGraphics_01, <GeeseGraphics_01
   .byte <GeeseGraphics_01, <GeeseGraphics_00
   .byte <GeeseGraphics_02, <GeeseGraphics_02
   .byte <GeeseGraphics_00, <GeeseGraphics_01
   
StationaryPilotSprite
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $FC ; |XXXXXX..|
   .byte $FD ; |XXXXXX.X|
   .byte $A1 ; |X.X....X|
   .byte $41 ; |.X.....X|
   .byte $11 ; |...X...X|
   .byte $20 ; |..X.....|
   .byte $09 ; |....X..X|
   .byte $31 ; |..XX...X|
   .byte $E5 ; |XXX..X.X|
   .byte $31 ; |..XX...X|
   .byte $30 ; |..XX....|
   .byte $04 ; |.....X..|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   
WindmillBladeGraphicLSBValues
   .byte <WindmillBladeGraphic_00 - H_WINDMILL + 1
   .byte <WindmillBladeGraphic_01 - H_WINDMILL + 1
   .byte <WindmillBladeGraphic_02 - H_WINDMILL + 1
   
   FILL_BOUNDARY 0, 234

GeeseGraphics
GeeseGraphics_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $06 ; |.....XX.|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GeeseGraphics_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $C0 ; |XX......|
   .byte $60 ; |.XX.....|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $07 ; |.....XXX|
   .byte $02 ; |......X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
GeeseGraphics_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $40 ; |.X......|
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $36 ; |..XX.XX.|
   .byte $E4 ; |XXX..X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
WeatherVaneGraphics
   .byte $80 ; |X.......|
   .byte $11 ; |...X...X|
   .byte $53 ; |.X.X..XX|
   .byte $FE ; |XXXXXXX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $62 ; |.XX...X.|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
AirplanePlayfieldGraphic
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $A8 ; |X.X.X...|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
WindmillGraphics
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $82 ; |X.....X.|
   .byte $C6 ; |XX...XX.|
   .byte $82 ; |X.....X.|
   .byte $AA ; |X.X.X.X.|
   .byte $82 ; |X.....X.|
   .byte $92 ; |X..X..X.|
   .byte $82 ; |X.....X.|
   .byte $AA ; |X.X.X.X.|
   .byte $82 ; |X.....X.|
   .byte $C6 ; |XX...XX.|
   .byte $82 ; |X.....X.|
   .byte $FE ; |XXXXXXX.|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $6C ; |.XX.XX..|
   .byte $44 ; |.X...X..|
   .byte $54 ; |.X.X.X..|
   .byte $44 ; |.X...X..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $54 ; |.X.X.X..|
   .byte $44 ; |.X...X..|
   .byte $54 ; |.X.X.X..|
   .byte $44 ; |.X...X..|
   .byte $6C ; |.XX.XX..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $7C ; |.XXXXX..|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $FE ; |XXXXXXX.|
   
HorizonColors
   .byte HORIZON_COLOR_LINE_01, HORIZON_COLOR_LINE_02, HORIZON_COLOR_LINE_03
   .byte HORIZON_COLOR_LINE_04, HORIZON_COLOR_LINE_05, HORIZON_COLOR_LINE_06
   .byte HORIZON_COLOR_LINE_07, HORIZON_COLOR_LINE_08, HORIZON_COLOR_LINE_09
   .byte HORIZON_COLOR_LINE_10, HORIZON_COLOR_LINE_11, HORIZON_COLOR_LINE_12
   .byte HORIZON_COLOR_LINE_13, HORIZON_COLOR_LINE_14, HORIZON_COLOR_LINE_15
   .byte HORIZON_COLOR_LINE_16
   
WindmillBladeGraphics
WindmillBladeGraphic_00
   .byte $FE ; |XXXXXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $90 ; |X..X....|
   .byte $91 ; |X..X...X|
   .byte $12 ; |...X..X.|
   .byte $97 ; |X..X.XXX|
   .byte $8E ; |X...XXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $8E ; |X...XXX.|
   .byte $87 ; |X....XXX|
   .byte $02 ; |......X.|
   .byte $81 ; |X......X|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
WindmillBladeGraphic_01
   .byte $FE ; |XXXXXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $90 ; |X..X....|
   .byte $11 ; |...X...X|
   .byte $92 ; |X..X..X.|
   .byte $97 ; |X..X.XXX|
   .byte $0E ; |....XXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $8E ; |X...XXX.|
   .byte $07 ; |.....XXX|
   .byte $82 ; |X.....X.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
WindmillBladeGraphic_02
   .byte $FE ; |XXXXXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $91 ; |X..X...X|
   .byte $92 ; |X..X..X.|
   .byte $17 ; |...X.XXX|
   .byte $8E ; |X...XXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $0E ; |....XXX.|
   .byte $87 ; |X....XXX|
   .byte $82 ; |X.....X.|
   .byte $01 ; |.......X|
   .byte $80 ; |X.......|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
   FILL_BOUNDARY 252, 234           ; push to RESET vector (this was done 
                                    ; instead of using an .ORG to easily keep
                                    ; track of free ROM)

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"
       
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector