   LIST OFF
; ***  A I R - S E A  B A T T L E  ***
; Copyright 1977 Atari, Inc.
; Designer: Larry Kaplan

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: May 23, 2016 (cleaned up a bit)
;
;  *** 116 BYTES OF RAM USED 12 BYTES FREE
;  ***   1 BYTE OF ROM FREE
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
; - This game uses a horizontal positioning routine originally derived by Joe
;   Decuir (see CalcXPos). This routine takes an x-position and calculates the
;   horizontal delta for the fine position and the coarse value needed to
;   reset the player's position.
; - The game speeds aren't adjusted for PAL50.
; - The kernel zone height was adjusted for PAL50. PAL50 kernel zones are 4 
;   lines higher than NTSC.
; - D4 of SWCHB is set for output in the NTSC version. I assume this was done
;   to save a bit when calculating missile size based on difficutly setting as
;   D4 sets the missile to size 2. The problem is when the values of SWCHB are
;   masked to get the difficulty setting, D4 is set to 0. This causes the
;   EXPERT missile size to be 0 for NTSC. This isn't used for the PAL version.
;   An EXPERT setting for PAL50 will set the missile to size 2 as intended.
; - It seems RAM locations $91 and $92 are not used.

      processor 6502

   include "tia_constants.h"
   include "vcs.h"

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
; F R A M E - T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC

VBLANK_TIME             = 44
H_KERNEL                = 102
MISSILE_VELOCITY        = 48
MISSILE_YMAX            = 231

   ELSE

VBLANK_TIME             = 45
H_KERNEL                = 123
MISSILE_VELOCITY        = 64
MISSILE_YMAX            = 240

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E
YELLOW                  = $10
RED                     = $30
PURPLE                  = $60
BLUE                    = $90
GREEN_BLUE              = $A0
GREEN                   = $C0

   IF COMPILE_REGION = NTSC

LIGHT_BLUE              = $80
BROWN                   = $E0

   ELSE

LIGHT_BLUE              = $B0
BROWN                   = $20

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000
   
XMIN                    = 8
XMAX                    = 158
MISSILE_XMAX            = XMAX - 7

OBJECT_XMAX_SINGLE      = XMAX - 9
OBJECT_XMAX_DOUBLE      = OBJECT_XMAX_SINGLE - 9

YMIN                    = 255 - H_KERNEL + 7
YMAX                    = 224

YPOS_PLAYER1            = YMIN + 5
YPOS_PLAYER2            = YPOS_PLAYER1 + 8

PLAYER1_GUN_XMIN        = 2
PLAYER2_GUN_XMIN        = 77

PLAYER1_GUN_XMAX        = 69
PLAYER2_GUN_XMAX        = 144

PLAYER1_STARTING_X      = 32
PLAYER2_STARTING_X      = 120

GUN_PIXEL_MOVEMENT      = 2

MAX_GAME_SELECTION      = 27

SELECT_DELAY            = $3F
SCORE_FLASH_DELAY       = $30

BW_HUE_MASK             = $0F
COLOR_HUE_MASK          = $FF

NUM_KERNEL_ZONES        = 10

STARTING_GAME_TIME      = 128
EXPLOSION_TIME          = 32
MAX_WAIT_TIME           = 63

;motion constants
MY_MOVE_RIGHT           = %1000
MY_MOVE_LEFT            = %0100
MY_MOVE_DOWN            = %0010
MY_MOVE_UP              = %0001

;game state values
SYSTEM_POWERUP          = %00001010
GAME_RUNNING            = %11111111

; game variation flags
POLARIS_OR_BOMBER       = %10000000
MOVE_LEFT_RIGHT         = %01000000
POLARIS_VS_BOMBER       = %00100000
SINGLEPLAYER            = %00010000
SHOOTING_GALLERY        = %00001000
WATER_OBSTACLES         = %00000100
OBSTACLES               = %00000010
GUIDED_MISSILES         = %00000001

; objectType ids
ID_LARGE_JET            = 0
ID_SMALL_JET            = 8
ID_747                  = 16
ID_HELICOPTER           = 24
ID_BLIMP                = 32
ID_RABBIT               = 40
ID_CLOWN                = 48
ID_DUCK                 = 56
ID_AIRCRAFT_CARRIER     = 64
ID_PT_BOAT              = 72
ID_FREIGHTER            = 80
ID_PIRATE_SHIP          = 88
ID_MINE_0               = 96
ID_MINE_1               = 104

; object score values (BCD)
LARGE_JET_SCORE         = $03
SMALL_JET_SCORE         = $04
_747_SCORE              = $01
HELICOPTER_SCORE        = $02
BLIMP_SCORE             = $00
RABBIT_SCORE            = $03
CLOWN_SCORE             = $01
DUCK_SCORE              = $02
AIRCRAFT_CARRIER_SCORE  = $03 
PT_BOAT_SCORE           = $04
FREIGHTER_SCORE         = $01
PIRATE_SHIP_SCORE       = $02
MINE_SCORE              = $00

; object state flags
OBJECT_HIT_STATE        = %10000000
OBJECT_DISABLED_STATE   = %11000000

MAX_SCORE               = $99

; velocity values
VELOCITY_SLOW           = 0
VELOCITY_REST           = 16
VELOCITY_FAST           = VELOCITY_REST * 2

OBJECT_VELOCITY_MEDIUM  = 2

MISSILE_HORZ_VELOCITY_90   = 0
MISSILE_HORZ_VELOCITY_60   = 1
MISSILE_HORZ_VELOCITY_30   = 2

MISSILE_VERT_VELOCITY_30   = 1
MISSILE_VERT_VELOCITY_60   = 2
MISSILE_VERT_VELOCITY_90   = 2

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

frameCount              ds 1        ; updated each frame
currentScanline         ds 1        ; keeps track of scan line in kernel
gameTimer               ds 1
selectDebounce          ds 1        ; debounce flag for the SELECT switch
startingKernelScanline  ds 1        ; scan line to start the kernel
scoreGraphics           ds 2        ; PF data to draw the score
;--------------------------------------
scoreGraphic1           = scoreGraphics
scoreGraphic2           = scoreGraphics + 1
temp                    ds 1
;--------------------------------------
tempMissileHorizPos     = temp
;--------------------------------------
tempKernelZone          = temp
;--------------------------------------
tempPlayerIndex         = temp
;--------------------------------------
objectVelocity          = temp
;--------------------------------------
tempXPosition           = temp
;--------------------------------------
tempDiv16               = temp      ; quotient of x-pos / 16 in CalcXPos routine
;--------------------------------------
tempFineMotion          = temp      ; holds fine motion in CalcXPos routine
objectXMax              ds 1
;--------------------------------------
   IF COMPILE_REGION = PAL50
   
kernelZonePad           = objectXMax; only used for PAL50
                                    ; PAL50 kernel zones are 4 lines higher
   ENDIF                            ; than NTSC
   
hueMask                 ds 1        ; masks the color hues
;--------------------------------------
objectStateMask         = hueMask   ; used to show/hide objects
colorXOR                ds 1        ; used to cycle colors to avoid screen burn
;--------------------------------------
playerHitKernelZone     = colorXOR  ; saves which player hit in polaris games
playerScores            ds 2
;--------------------------------------
player1Score            = playerScores
player2Score            = player1Score + 1
scoreOffsets            ds 4
;--------------------------------------
lsbScoreOffsets         = scoreOffsets
player1LSBOffset        = lsbScoreOffsets
player2LSBOffset        = lsbScoreOffsets + 1
;--------------------------------------
msbScoreOffsets         = scoreOffsets + 2
player1MSBOffset        = msbScoreOffsets
player2MSBOffset        = msbScoreOffsets + 1
zpUnused                ds 2        ; two bytes of unused RAM
missileVertPos          ds 2        ; missile y-position
;--------------------------------------
missile2VertPos         = missileVertPos
missile1VertPos         = missileVertPos + 1
randomSeed              ds 1        ; 8-bit random number
tempRandomSeed          ds 1
gameState               ds 1        ; see game state flags in constants
gameSelection           ds 1
gameSelectionBCD        ds 1        ; holds game selection in BCD
gameVariation           ds 1        ; see game variation flags in constants
scoreMask               ds 1        ; used to turn on/off right digits
playerVelocity          ds 2
;--------------------------------------
player1Velocity         = playerVelocity
player2Velocity         = playerVelocity + 1
explosionSpriteOffset   ds 1        ; table offset for the explosion sprite
gameBoardDone           ds 1        ; D7 = 0 done -- D7 = 1 not done
objectShowState         ds 1        ; 0 = show object 1 = don't show object
playerKernelZones       ds 2        ; kernel zone for player in polaris games
;--------------------------------------
player1KernelZone       = playerKernelZones
player2KernelZone       = playerKernelZones + 1
playerGraphicOffsets    ds 2        ; table offset for the player sprites
;--------------------------------------
player1GraphicOffset    = playerGraphicOffsets
player2GraphicOffset    = playerGraphicOffsets + 1
joystickValues          ds 2        ; saved joystick values for players
;--------------------------------------
player1JoystickValue    = joystickValues
player2JoystickValue    = joystickValues + 1
missileTrajectory       ds 2        ; angle of missile movement
;--------------------------------------
player1MissileTraj      = missileTrajectory
player2MissileTraj      = missileTrajectory + 1
missileHorizPos         ds 2        ; missile x-position
;--------------------------------------
missile1HorizPos        = missileHorizPos
missile2HorizPos        = missileHorizPos + 1
missileMask             ds 2        ; used to enable/disable missile in kernel
;--------------------------------------
player2MissileMask      = missileMask
player1MissileMask      = missileMask + 1
audioFrequencies        ds 4
objectGraphicIndex      ds 1
objectAttributes        ds NUM_KERNEL_ZONES; object's size and reflect state
;--------------------------------------
playerDiffState         = objectAttributes + 8
;--------------------------------------
player1DiffState        = playerDiffState
player2DiffState        = playerDiffState + 1
zoneHorizPos            ds NUM_KERNEL_ZONES; x-position of the objects
;--------------------------------------
playerHorizPos          = zoneHorizPos + 8; x-position of the players
;--------------------------------------
player1HorizPos         = playerHorizPos
player2HorizPos         = playerHorizPos + 1
kernelZoneHorizPos      ds NUM_KERNEL_ZONES; fine/coarse value of the objects
;--------------------------------------
playerFineCoarsePos     = kernelZoneHorizPos + 8; fine/coarse value of players
;--------------------------------------
player1FineCoarsePos    = playerFineCoarsePos
player2FineCoarsePos    = playerFineCoarsePos + 1
objectIds               ds NUM_KERNEL_ZONES - 1; object in kernel zone & wait time
missileCollisions       ds NUM_KERNEL_ZONES - 1; collision flags for kernel zone
playerColors            ds NUM_KERNEL_ZONES; color of object's in kernel zone
kernelZoneColors        ds NUM_KERNEL_ZONES; background color of kernel zone

   echo "***",(*-$80 - 2)d, "BYTES OF RAM USED", ($100 - * + 2)d, "BYTES FREE"
   
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
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   lda #SYSTEM_POWERUP
   sta REFP1                        ; REFLECT player 1 (D3 = 1)
   sta CTRLPF                       ; set to SCORE mode and non-relective PF
   sta gameState
   
   IF COMPILE_REGION = NTSC

   lda #%00010000
   sta SWBCNT                       ; set D4 of SWCHB as output

   ENDIF
   
MainLoop
VerticalSync
   lda #DISABLE_TIA | START_VERT_SYNC
   sta WSYNC
   sta VBLANK                       ; disable TIA (D1 = 1)
   sta WSYNC                        ; wait 3 scan lines before starting new
   sta WSYNC                        ; frame
   sta WSYNC
   sta VSYNC                        ; start vertical sync (D1 = 1)
   inc frameCount                   ; increment frame count each new frame
   sta WSYNC                        ; first line of VSYNC
   sta WSYNC                        ; second line of VSYNC
   lda #STOP_VERT_SYNC
   sta WSYNC                        ; third line of VSYNC
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for vertical blanking period
   ldx #$FF
   txs                              ; point stack to the beginning
   jsr GameCalculations
   lda #255 - H_KERNEL              ; the scan line variable is incremented
   sta currentScanline              ; until it reaches 0
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; end last scan line
   sta HMOVE
   sta VBLANK                       ; enable TIA (D1 = 0)
.scoreKernelWait
   sta WSYNC
   sta HMCLR                        ; clear all horizontal positioning
   inc currentScanline
   sta WSYNC
;--------------------------------------
   lda currentScanline        ; 3         continue looping until the
   cmp startingKernelScanline ; 2         appropriate starting scan line has
   bcc .scoreKernelWait       ; 2³        been reached
   cmp #255 - H_KERNEL + 3    ; 2
   bcs BeginPlayfieldKernel   ; 2³
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda scoreGraphic1          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @06
   ldy player1MSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic1          ; 3         save it in the score graphic
   ldy player1LSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask the upper nybble
   ora scoreGraphic1          ; 3         or with score graphic to get LSB
   sta scoreGraphic1          ; 3         value
   lda scoreGraphic2          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @39
   ldy player2MSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic2          ; 3         save it in the score graphic
   ldy player2LSBOffset       ; 3
   lda NumberFonts,y          ; 4         read the number fonts
   and scoreMask              ; 3         scoreMask turns on/off right digits
   ora scoreGraphic2          ; 3         or with score graphic to get LSB
   sta scoreGraphic2          ; 3         value
   sta WSYNC                  ; 3 = @70
;--------------------------------------
   inc currentScanline        ; 5
   lda currentScanline        ; 3
   cmp #YMIN                  ; 2
   bcs BeginPlayfieldKernel   ; 2³
   lda scoreGraphic1          ; 3
   sta PF1                    ; 3 = @18
   inc player1LSBOffset       ; 5
   inc player1MSBOffset       ; 5
   inc player2LSBOffset       ; 5
   inc player2MSBOffset       ; 5
   lda scoreGraphic2          ; 3
   sta PF1                    ; 3 = @44
   jmp ScoreKernel            ; 3
   
BeginPlayfieldKernel
   ldx #0                     ; 2
   stx PF1                    ; 3 = @18   clear PF1 so digit doesn't bleed
   stx objectGraphicIndex     ; 3
.playfieldKernelLoop
   lda objectAttributes,x     ; 4
   sta NUSIZ0                 ; 3 = @28   set the size of the object
   sta REFP0                  ; 3 = @31   set the object's reflect state
   lda CXM0P                  ; 3         read the missile 0 collisions
   lsr                        ; 2         shift the values to D5 and D4
   lsr                        ; 2
   ora CXM1P                  ; 3         read the missile 1 collisions
   sta missileCollisions,x    ; 4         store the collision value
   lda playerColors,x         ; 4         get the colors for objects in zone
   sta COLUP0                 ; 3 = @52
   sta COLUP1                 ; 3 = @55
   lda kernelZoneColors,x     ; 4         get the kernel zone color
   sta COLUBK                 ; 3 = @62
   
   IF COMPILE_REGION = PAL50
   
   lda #3                     ; 2
   sta kernelZonePad          ; 3
   
   ENDIF
   
   sta WSYNC
;--------------------------------------
   lda kernelZoneHorizPos,x   ; 4
   sta HMP0                   ; 3 = @07   set the object's fine motion value
   lda kernelZoneHorizPos,x   ; 4         read again to waste 4 cycles
   and #$0F                   ; 2         mask upper nybble for coarse value
   tay                        ; 2
.coarseMoveObject
   dey                        ; 2
   bpl .coarseMoveObject      ; 2³
   sta RESP0                  ; 3         set the object's coarse position
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bmi .setMissileState       ; 3         unconditional branch
   
ZoneKernel
   sta WSYNC
;--------------------------------------
.setMissileState
   txa                        ; 2         save kernel zone in accumulator
   ldx #<ENAM1                ; 2         load x with location of ENAM1
   txs                        ; 2         set stack to point to ENAM1
   tax                        ; 2         restore kernel zone in x
   sec                        ; 2
   lda currentScanline        ; 3
   sbc missile1VertPos        ; 3
   and player1MissileMask     ; 3
   php                        ; 3 = @22   enables/disables missile 1
   sec                        ; 2
   lda currentScanline        ; 3
   sbc missile2VertPos        ; 3
   and player2MissileMask     ; 3
   sta temp                   ; 3
   lda objectIds,x            ; 4
   bpl .determineSpriteOffset ; 2³
   asl                        ; 2
   bpl .setToExplosionSprite  ; 2³
   lda #0                     ; 2
   beq DrawObjectSprite       ; 3         unconditional branch
   
.setToExplosionSprite
   lda explosionSpriteOffset  ; 3
.determineSpriteOffset
   ora objectGraphicIndex     ; 3
   tay                        ; 2
   lda GameSprites,y          ; 4
DrawObjectSprite
   inc currentScanline        ; 5
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda temp                   ; 3
   php                        ; 3 = @09
   inc objectGraphicIndex     ; 5
   lda objectGraphicIndex     ; 3         get graphic index to see if we're
   and #7                     ; 2         done with the "zone" (same as sprite
   bne ZoneKernel             ; 2³ + 1    height)
   
   IF COMPILE_REGION = PAL50
   
   dec objectGraphicIndex     ; 5         dec index so inc above resets to 0
   dec kernelZonePad          ; 5         reduce PAL50 zone height until done
   bpl ZoneKernel             ; 2³ + 1    crosses page boundary
   
   ENDIF
   
   sta objectGraphicIndex     ; 3         reset object graphic index (a = 0)
   inx                        ; 2
   cpx #NUM_KERNEL_ZONES - 1  ; 2
   bcc .playfieldKernelLoop   ; 2³ + 1    crosses page boundary
   sta HMP0                   ; 3 = @33
   sta WSYNC
;--------------------------------------
   lda kernelZoneHorizPos,x   ; 4         get player2's fine/coarse value
   sta HMP1                   ; 3 = @07   set player2's fine motion
   lda kernelZoneHorizPos,x   ; 4         waste 4 cycles
   and #$0F                   ; 2         mask fine motion
   tay                        ; 2
.coarseMovePlayer2
   dey                        ; 2
   bpl .coarseMovePlayer2     ; 2³
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #DISABLE_BM            ; 2
   sta ENAM0                  ; 3 = @08   disable the missiles
   sta ENAM1                  ; 3 = @11
   lda playerColors + 9       ; 3
   sta COLUP1                 ; 3 = @17
   bit gameVariation          ; 3         if this game doesn't have the gun
   bmi Overscan               ; 2³        at the bottom then go to Overscan
   ldy player1GraphicOffset   ; 3
   ldx player2GraphicOffset   ; 3
AntiAircraftKernel
   sta WSYNC
;--------------------------------------
   lda AntiAircraftGuns,y     ; 4         read player1's gun graphic
   sta GRP0                   ; 3 = @07
   lda AntiAircraftGuns,x     ; 4         read player2's gun graphic
   sta GRP1                   ; 3 = @14
   sta WSYNC
;--------------------------------------
   iny                        ; 2
   inx                        ; 2
   inc currentScanline        ; 5
   txa                        ; 2
   and #7                     ; 2         see if we're done with the "zone"
   bne AntiAircraftKernel     ; 2³
   sta GRP0                   ; 3 = @18   clear the player graphics (a = 0)
   sta GRP1                   ; 3 = @21
   lda kernelZoneColors + 9   ; 3
   sta COLUBK                 ; 3 = @27
Overscan
.overscanWait
   sta WSYNC                        ; skip 2 scan lines because it's a 2LK
   sta WSYNC
   inc currentScanline
   bne .overscanWait
   jmp MainLoop
       
GameCalculations
ReadConsoleSwitches
   lda gameState                    ; get the current game state
   
   IF COMPILE_REGION = NTSC
   
   sta SWCHB                        ; set D4 of SWCHB
   
   ENDIF
   
   cmp #SYSTEM_POWERUP
   beq .showGameSelection           ; branch if game powering up
   lda SWCHB                        ; read the console switches
   ror                              ; RESET value now in carry
   bcs .skipGameReset               ; branch if RESET not pressed
;
; start new game
;
   lda #GAME_RUNNING                ; RESET pressed so show the game is in
   sta gameState                    ; progress
   lda #0
   sta player1Score                 ; reset the player scores
   sta player2Score
   sta selectDebounce               ; reset the select debounce value
   lda #STARTING_GAME_TIME
   sta gameTimer                    ; set the starting game time
   lda frameCount                   ; get the current frame count
   and #1                           ; make the value between 0 and 1
   sta frameCount
   lda #$0F                         ; set score mask to show player2's score
   sta scoreMask
   jmp ResetPlayerPositions
       
.skipGameReset
   ldy #255 - H_KERNEL + 1          ; initial scan line to start kernel
   lda gameTimer
   and gameState
   cmp #$F0
   bcc .setKernelStartScanline
   lda frameCount                   ; get the current frame count
   and #SCORE_FLASH_DELAY           ; see if the score is to drawn (flashing)
   bne .setKernelStartScanline
   ldy #YMIN                        ; ensures score is not drawn
.setKernelStartScanline
   sty startingKernelScanline       ; set scan line to start kernel
   lda frameCount                   ; get current frame count
   and #SELECT_DELAY                ; the select switch is checked ~ every 60
   bne .checkGameSelectSwitch       ; frames or ~ every second
   sta selectDebounce               ; reset select debounce flag
   inc gameTimer                    ; increment timer (rolls over at 255)
   bne .checkGameSelectSwitch
   sta gameState                    ; if timer rolls over set to game over
.checkGameSelectSwitch
   lda SWCHB                        ; read the console switches
   and #SELECT_MASK                 ; mask to find SELECT value
   beq .selectSwitchPressed
   sta selectDebounce               ; show SELECT not pressed this frame
   bne CheckMissileCollisions       ; unconditional branch
   
.selectSwitchPressed
   bit selectDebounce               ; if SELECT held then skip SELECT button
   bmi CheckMissileCollisions       ; logic
   lda #$FF
   sta selectDebounce               ; show the SELECT button is held
   inc gameSelection                ; increment game selection
.showGameSelection
   lda gameSelectionBCD             ; store the game selection (BCD) in
   sta player1Score                 ; player1's score
   ldx #0
   stx player2Score                 ; reset player2's score
   stx scoreMask                    ; clear the score mask
   stx gameState                    ; show that game is over
   stx frameCount                   ; reset frame count
   lda gameSelection                ; get the current game selection number
   cmp #MAX_GAME_SELECTION          ; make sure it doesn't go over the max
   bcc .incrementGameSelection
   stx player1Score                 ; clear player1's score
   stx gameSelection                ; wrap game selection around to 0
.incrementGameSelection
   ldy #$FF                         ; makes the game selection increment by 1
   jsr CalculateScore
   lda player1Score                 ; get new game selection
   sta gameSelectionBCD             ; save for next frame
   ldx #NUM_KERNEL_ZONES - 2
   lda #OBJECT_DISABLED_STATE | MAX_WAIT_TIME - 1
.setObjectIds
   sta objectIds,x
   dex
   bpl .setObjectIds
   ldx gameSelection
   lda GameVariationTable,x         ; set the game variation based on game
   sta gameVariation                ; selection
   bmi .polarisOrBomberGameSelection
   ldy #1
   and #SHOOTING_GALLERY|OBSTACLES
   beq .setObjectShowState
   lda #OBJECT_DISABLED_STATE
   bne .setObjectShowState          ; unconditional branch
   
.polarisOrBomberGameSelection
   rol                              ; shift value left 4 times so
   rol                              ; POLARIS_OR_BOMBER, MOVE_LEFT_RIGHT,
   rol                              ; and POLARIS_VS_BOMBER are in D2,D1,D0
   rol
   and #3                           ; and value for lookup table
   tay
   lda ObjectShowStateTable,y
   cpx #24                          ; set objectShowState if the game type is
   bcc .setObjectShowState          ; not a POLARIS_VS_BOMBER game
   and #%11100111
.setObjectShowState
   sta objectShowState
   lda Player1KernelZoneTable,y     ; set the kernel zone for player 1
   sta player1KernelZone
   lda Player2KernelZoneTable,y     ; set the kernel zone for player 2
   sta player2KernelZone
ResetPlayerPositions
   lda #HMOVE_R2 | 2
   sta player1FineCoarsePos         ; sets player to pixel 98
   sta RESMP0                       ; lock missiles to players
   sta RESMP1                       ; and disable them
   lda #HMOVE_0 | 8
   sta player2FineCoarsePos         ; sets player to pixel 147
   lda #PLAYER1_STARTING_X
   sta player1HorizPos
   lda #PLAYER2_STARTING_X
   sta player2HorizPos
   bne DoneCollisionCheck           ; unconditional branch
       
CheckMissileCollisions
   ldx #1
.checkPlayerCollisionLoop
   lda CXM0P,x                      ; read missile collisions for this frame
   and MissileCollisionMask,x
   beq .checkNextPlayer             ; if no collision then check next player
   ldy #<-1
.checkZoneCollisions
   iny
   cpy #NUM_KERNEL_ZONES - 2
   bcs .checkNextPlayer
   lda missileCollisions + 1,y      ; get missile collision zone value
   and MissileCollisionZoneTable,x
   beq .checkZoneCollisions         ; if none here then check next zone
   jsr CalculateScore               ; collision found -- increment score
.checkNextPlayer
   dex
   bpl .checkPlayerCollisionLoop
DoneCollisionCheck
   sta CXCLR                        ; clear all collisions
   lda gameVariation                ; get the game variation
   and #SINGLEPLAYER                ; mask value to get SINGLEPLAYER flag
   tay
   lda #$F0                         ; assume this is a one player game
   cpy #0                           ; if one player game then branch to
   bne .shiftP1JoystickValues       ; shift the joystick values
   lda SWCHA                        ; read the player joystick values
   and #$F0                         ; mask out player 2's values
.shiftP1JoystickValues
   lsr                              ; shift the value to the lower nybble
   lsr
   lsr
   lsr
   sta player1JoystickValue         ; store player1's joystick value
   lda SWCHA                        ; read the joystick port
   and #$0F                         ; mask out player 1's values
   sta player2JoystickValue         ; store player2's joystick value
   lda frameCount                   ; get the current frame count
   and #$01                         ; make the value between 0 and 1
   tax
   
   IF COMPILE_REGION = NTSC
   
   lda SWCHB                        ; read the console switch values
   eor #$FF                         ; and flip the bits
   and DifficultySwitchMask,x       ; mask to get difficulty values
   beq .setMissileSize              ; set expert missile size (size 1 for NTSC)
   lda #MSBL_SIZE4                  ; make the missiles 4 clocks wide
.setMissileSize
   sta playerDiffState,x
   sta NUSIZ0,x                     ; set missile size
   
   ELSE
   
   ldy #MSBL_SIZE2                  ; assume EXPERT setting
   lda SWCHB                        ; read the console switch values
   and DifficultySwitchMask,x
   bne .setMissileSize
   ldy #MSBL_SIZE4                  ; make the missiles 4 clocks wide
.setMissileSize
   sty playerDiffState,x
   sty NUSIZ0,x                     ; set missile size
   
   ENDIF   
   
   lda gameVariation                ; get the current game variation
   bpl DeterminePlayerVelocity      ; branch if not a polaris game
   and #GUIDED_MISSILES             ; check for the guided missile option
   bne DeterminePlayerVelocity      ; branch to guided missiles
   lda missileVertPos,x             ; get the missile's vertical position
   bne .setMissileTrajectory        ; skip logic if missile still active
DeterminePlayerVelocity
   lda joystickValues,x             ; get the player's joystick value
   and #MY_MOVE_DOWN | MY_MOVE_UP   ; mask all but up and down values
   tay
   lda PlayerVelocityTable,y        ; get player velocity from look up table
   sta playerVelocity,x
   clc
   adc #VELOCITY_REST * 4
   tay
   lda #SHOOTING_GALLERY
   bit gameVariation
   bne DeterminePlayerHorizMovement ; branch if not variable movement
   bvc DetermineAntiAirSpriteOffset ; branch if up down movement
   txa
   bne .setPlayerVelocity           ; branch if player 1
   lda gameVariation                ; get the current game variation
   and #POLARIS_VS_BOMBER
   bne .setMissileTrajectory        ; branch if Polaris vs. Bomber
.setPlayerVelocity
   sty playerVelocity,x
DeterminePlayerHorizMovement
   bit gameVariation
   bmi .setMissileTrajectory        ; branch if Polaris style game
   lda joystickValues,x             ; get the player's joystick value
   and #MY_MOVE_RIGHT               ; get the right motion flag
   beq .movePlayerRight
   lda joystickValues,x             ; get the player's joystick value
   and #MY_MOVE_LEFT                ; get the left motion flag
   bne .skipPlayerHorizPos
   sec
   lda playerHorizPos,x             ; get the player's horizontal position
   sbc #GUN_PIXEL_MOVEMENT          ; reduce by gun pixel movement
   cmp GunXMinTable,x               ; make sure the gun stays within range
   bcs .setPlayersHorizPos
   lda GunXMinTable,x               ; set the player's position to the minimum
   bne .setPlayersHorizPos          ; gun position (unconditional branch)
   
.movePlayerRight
   clc
   lda playerHorizPos,x             ; get the player's horizontal position
   adc #GUN_PIXEL_MOVEMENT          ; increment by gun pixel movement
   cmp GunXMaxTable,x               ; make sure the gun stays within range
   bcc .setPlayersHorizPos
   lda GunXMaxTable,x               ; set the player's position to the maximum
                                    ; gun position
.setPlayersHorizPos
   sta playerHorizPos,x
   jsr CalcXPos                     ; calculate player's fine/coarse value
   sta playerFineCoarsePos,x
.skipPlayerHorizPos
   lda gameVariation
   and #SHOOTING_GALLERY | WATER_OBSTACLES
   cmp #WATER_OBSTACLES
   beq .setSubmarineSpriteOffset
DetermineAntiAirSpriteOffset
   lda joystickValues,x             ; get the player's joystick value
   and #MY_MOVE_DOWN | MY_MOVE_UP   ; mask all but up and down values
   asl                              ; multiply by 8 to get sprite offset
   asl
.setSubmarineSpriteOffset
   asl
   sta playerGraphicOffsets,x
.setMissileTrajectory
   lda gameVariation
   and #GUIDED_MISSILES
   beq .skipGuidedMissiles
   lda joystickValues,x             ; get the player's joystick value
   sta missileTrajectory,x          ; save in trajectory for guided missiles
.skipGuidedMissiles
   lda missileVertPos,x             ; get the missile's vertical position
   bne .determineToDisableMissile   ; branch if not off screen
   bit gameState                    ; check the game state
   bpl .determineIfGameBoardDone    ; branch if game not in play
   lda INPT4 + 48,x                 ; read the player's fire button
   bpl DetermineMissilePosition     ; branch if fire button not pressed
   lda gameVariation                ; get the current game variation
   and #SINGLEPLAYER                ; see if this is a two player game
   beq .determineIfGameBoardDone
   txa
   beq DetermineMissilePosition
.determineIfGameBoardDone
   jmp DetermineIfGameBoardDone

DetermineMissilePosition
   lda gameVariation                ; get the current game variation
   and #POLARIS_VS_BOMBER           ; mask Polaris vs. Bomber value
   tay
   lda #MISSILE_YMAX
   bit gameVariation
   bpl .setMissileVerticalPosition  ; branch if not Polaris vs. Bomber
   lda PlayerVertPosTable,x
   bvc .setMissileVerticalPosition  ; branch if cannot move left or right
   cpx #0
   bne .incrementMissileVertPosition
   cpy #0
   bne .setMissileVerticalPosition
.incrementMissileVertPosition
   clc
   adc #MISSILE_VELOCITY
.setMissileVerticalPosition
   sta missileVertPos,x
   lda #UNLOCK_MISSILE
   sta RESMP0,x
   lda joystickValues,x             ; get the player's joystick value
   sta missileTrajectory,x          ; save in trajectory
   lda #$1F
   sta audioFrequencies,x           ; set audio frequency for firing
   lda #<~DISABLE_BM
   sta missileMask,x                ; set to disable missile
   lda playerHorizPos,x             ; get the player's horizontal position
   sta missileHorizPos,x            ; and set the missile's to the same
   bit gameVariation
   bvc .determineToDisableMissile   ; branch if can't move left and right
   txa                              ; move player index to accumulator
   bne .setMissileMaskToEnable      ; branch if player 2
   lda gameVariation                ; get the current game variation
   and #POLARIS_VS_BOMBER
   bne .determineToDisableMissile   ; branch if Polaris vs. Bomber game
.setMissileMaskToEnable
   lda #(ENABLE_BM ^ $FE)
   sta missileMask,x                ; set to enable missile
.determineToDisableMissile
   lda playerKernelZones,x          ; get the kernel zone for the player
   bmi CalculateMissileXPos         ; branch if not used for the game setting
   tay                              ; y holds index to obstacle object
   lda objectIds,y                  ; disable missile if the obstacle was
   bmi DisablePlayerMissile         ; shot this frame
CalculateMissileXPos
   lda missileHorizPos,x            ; get the missile's horizontal position
   sta tempMissileHorizPos          ; save it for later
   ldy #2
   bit gameVariation
   bmi .setMissileXPosToPlayerXPos  ; branch if this is a polaris style game
   bvc .setMissileXPosFromTrajectory; branch if can't move left or right
   lda gameVariation                ; get the game variation
   and #GUIDED_MISSILES
   tay
   beq DetermineMissileXPos
.setMissileXPosToPlayerXPos
   lda playerHorizPos,x             ; get the player's horizontal position
   sta tempMissileHorizPos          ; save it for later
   jmp DetermineMissileXPos
       
.setMissileXPosFromTrajectory
   lda missileTrajectory,x          ; get missile trajectory
   and #MY_MOVE_DOWN | MY_MOVE_UP
   tay
   lda MissileAngleTable,y
   cpx #0                           ; if this is not player 1 then the value
   beq .incrementMissileXPos        ; is negated so the missile angle can be
   clc                              ; subtracted below
   eor #$FF
   adc #1
.incrementMissileXPos
   clc
   adc missileHorizPos,x
   sta tempMissileHorizPos
   cmp #MISSILE_XMAX
   bcs DisablePlayerMissile
DetermineMissileXPos
   sec
   lda missileHorizPos,x            ; get the missile horizontal position
   sbc tempMissileHorizPos          ; subtract by the temp position
   cmp #$F0 | (HMOVE_R4 >> 4)       ; missile x-movement varies from R4 - L5
   bcs .setMissileFineMotion
   cmp #(HMOVE_L5 >> 4)
   bcs DisablePlayerMissile
.setMissileFineMotion
   asl                              ; move fine motion value to upper nybble
   asl
   asl
   asl
   sta HMM0,x                       ; set missile fine motion
   lda tempMissileHorizPos
   sta missileHorizPos,x
   lda #POLARIS_VS_BOMBER
   bit gameVariation
   bpl .moveMissileUp               ; move missile up if not polaris type game
   bvc .moveMissileDown             ; branch if can't move left or right
   beq .moveMissileUp               ; branch if Polaris vs. Bomber
   txa
   bne .moveMissileUp               ; branch if player 2
.moveMissileDown
   clc
   lda MissileVertVelocityTable,y
   adc missileVertPos,x             ; increment the missile vertical position
   sta missileVertPos,x
   cmp #YMAX
   bcs DisablePlayerMissile         ; disable missile if out of range
   bcc DetermineIfGameBoardDone     ; unconditional branch
       
.moveMissileUp
   sec
   lda missileVertPos,x
   sbc MissileVertVelocityTable,y
   sta missileVertPos,x
   cmp #YMIN
   bcs DetermineIfGameBoardDone
DisablePlayerMissile
   lda #LOCK_MISSILE
   sta RESMP0,x                     ; reset missile position and disable
   lda #0
   sta missileVertPos,x             ; reset the missile's vertical position
   lda #$FF                         ; set frequency high to disable this
   sta audioFrequencies,x           ; frame
DetermineIfGameBoardDone
   jsr NextRandom                   ; re-seed random number
   txa
   bne .skipDeterminingIfBoardDone  ; branch if player 2
   lda randomSeed                   ; get the current random number
   sta tempRandomSeed               ; save for later
   ldy #5                           ; max number of objects per board is 6
.checkIfGameBoardDone
   lda objectIds,y                  ; get the object id
   cmp #OBJECT_DISABLED_STATE | EXPLOSION_TIME
   ror                              ; rotate CARRY into D7
   bpl .setGameBoardDoneState
   dey                              ; next objectId
   bpl .checkIfGameBoardDone
.setGameBoardDoneState
   sta gameBoardDone
.skipDeterminingIfBoardDone
   lda PlayerValueMasks,x           ; get D7/D6 mask values
   sta objectStateMask              ; set value of object state mask
   txa                              ; move player number to accumulator
   ora #6
   tax                              ; x = 6 for player 1 x = 7 for player 2
SetObjectStates
   lda objectAttributes,x           ; get the object attributes
   and #$0F                         ; mask the direction -- keep size
   ora player1DiffState             ; or with difficulty for size of missile
   sta objectAttributes,x           ; save it in object attributes
   ror                              ; shift D0 to carry
   lda #OBJECT_XMAX_DOUBLE          ; assume this is a double size object
   bcs .setObjectXMax
   lda #OBJECT_XMAX_SINGLE
.setObjectXMax
   sta objectXMax
   ldy #1                           ; assume player 2 hit player 1
   cpx player2KernelZone
   beq .setPlayerHitKernelZone
   dey                              ; check if player 2 hit player 2
   cpx player1KernelZone
   beq .setPlayerHitKernelZone
   dey                              ; y = -1 -- show no players were hit
.setPlayerHitKernelZone
   sty playerHitKernelZone
   lda objectIds,x                  ; get the object id
   bmi ObjectShot                   ; branch if shot
   jmp CheckToMoveObject
       
ObjectShot
   cmp #OBJECT_DISABLED_STATE | EXPLOSION_TIME + 1
   bcs .skipObjectDisableTimeIncrement
   inc objectIds,x                  ; increment the time to not show object
.skipObjectDisableTimeIncrement
   lda #WATER_OBSTACLES
   bit gameVariation
   bpl .checkIncrementDisableTime   ; branch if not a polaris type game
   bne .incrementObjectDisableTime  ; branch if not a Torpedo game
.checkIncrementDisableTime
   bit gameBoardDone
   bmi .setMissileSizeForZone       ; branch if game board not done
   cpx #6
   bcc .jmpNextObject
.incrementObjectDisableTime
   inc objectIds,x                  ; increment the time to not show object
   bpl .setMissileSizeForZone
.jmpNextObject
   jmp .nextObject

.setMissileSizeForZone
   lda player1DiffState
   sta objectAttributes,x           ; set missile size
   lda gameVariation                ; get the current game variation
   and #OBSTACLES                   ; branch if this game has obstacles
   bne CheckToSpawnNewObject
   lda randomSeed                   ; get the current random number
   sta tempRandomSeed               ; save it for later use
CheckToSpawnNewObject
   lda objectShowState
   and objectStateMask
   bne .disableObject
   ldy playerHitKernelZone          ; get player zone that was hit
   bmi SpawnNewShootingGalleryObject; branch if no player hit one
   lda playerVelocity,y
   and #$40                         ; mask all but D6
   jmp SetObjectId
       
SpawnNewShootingGalleryObject
   lda gameVariation                ; get the current game variation
   and #SHOOTING_GALLERY | WATER_OBSTACLES
   tay
   cmp #SHOOTING_GALLERY
   bne SpawnNewWaterObstacleObject
   lda tempRandomSeed
   and #$18                         ; make value 0,8,16,or 24 (i.e. from
   clc                              ; ID_LARGE_JET to ID_HELICOPTER)
   adc #ID_RABBIT                   ; add to get shooting gallery objects
   cmp #ID_AIRCRAFT_CARRIER
   bcc SetObjectId                  ; set id if in shooting gallery range
   bcs .disableObject               ; disable object if out of range
       
SpawnNewWaterObstacleObject
   bit gameVariation
   bmi .polarisOrBomberGame
   cpx #6
   bcc .polarisOrBomberGame
   lda #ID_BLIMP
   bne .determineNewObjectId        ; unconditional branch
       
.polarisOrBomberGame
   lda gameSelection                ; get the current game selection
   cmp #24                          ; if less than game 24 then determine
   bcc SpawnNewObject               ; new object to spawn
   lda #ID_MINE_1                   ; spawn a new mine
   bne SetObjectId                  ; unconditional branch
       
SpawnNewObject
   lda randomSeed                   ; get the random seed
   lsr                              ; shift D0 to carry
   lda tempRandomSeed
   and #$18                         ; make value 0,8,16,or 24
   bcs .determineNewObjectId        ; branch if randomSeed is odd
.disableObject
   lda #OBJECT_DISABLED_STATE       ; set value to not display object
   bne SetObjectId                  ; unconditional branch
       
.determineNewObjectId
   cpy #0                           ; set the object id if this is not a
   beq SetObjectId                  ; water obstacle game
   clc
   adc #ID_AIRCRAFT_CARRIER
SetObjectId
   sta objectIds,x
   and #$08
   bne .skipNoReflectSet
   lda #NO_REFLECT | DOUBLE_SIZE    ; set to no reflect and double size
   ora player1DiffState             ; or in player 1 missile size
   sta objectAttributes,x           ; set object's attributes
.skipNoReflectSet
   ldy #HMOVE_0 | 0
   lda tempRandomSeed               ; get the held random number value
   and #REFLECT >> 1                ; and the value to determine which side
   beq .setObjectInitHorizPos       ; object should appear
   asl
   ora objectAttributes,x           ; reflect the object (i.e. travel left)
   sta objectAttributes,x
   lda #OBJECT_XMAX_DOUBLE + 1
   ldy #HMOVE_R6 | 9
.setObjectInitHorizPos
   sta zoneHorizPos,x
   sty kernelZoneHorizPos,x
   jmp .nextObject
       
CheckToMoveObject
   ldy playerHitKernelZone          ; get the player zone that was hit
   bmi .skipVelocityLoad            ; branch if no player hit
   lda playerVelocity,y             ; get the hit player's velocity
.skipVelocityLoad
   ldy #OBJECT_VELOCITY_MEDIUM      ; set the object's velocity -- used below
   sty objectVelocity               ; when calculating object movement
   and #ID_747 | ID_BLIMP | ID_CLOWN
   beq .determineObjectMoveTime     ; branch if not either object
   dec objectVelocity               ; slow the object down
   cmp #ID_BLIMP
   bcc .determineObjectMoveTime
   lda frameCount                   ; get the frame count
   and #2
   bne .nextObject
.determineObjectMoveTime
   lda gameVariation                ; get the game variation
   and #SHOOTING_GALLERY | WATER_OBSTACLES
   tay
   cmp #SHOOTING_GALLERY
   bne MoveObjects
   lda frameCount                   ; get the frame count
   and #$7C
   bne MoveObjects                  ; change ~every 2 seconds
   bit randomSeed
   bvc MoveObjects
   lda objectAttributes,x           ; get the object's attributes
   eor #REFLECT                     ; change it's reflect/direction
   sta objectAttributes,x
MoveObjects
   lda objectAttributes,x           ; get the object's attributes
   and #REFLECT                     ; get it's reflect/direction
   beq .moveObjectRight
   lda zoneHorizPos,x               ; get the object's horizontal position
   sec
   sbc objectVelocity               ; move the object to the left
   bcs .setObjectHorizontalPosition
   lda objectXMax
   bne .disableTorpedoGameObject    ; unconditional branch
   
.moveObjectRight
   clc
   lda zoneHorizPos,x               ; get the object's horizontal position
   adc objectVelocity               ; move the object to the right
   cmp objectXMax
   bcc .setObjectHorizontalPosition
   lda #0
.disableTorpedoGameObject
   cpy #WATER_OBSTACLES
   bne .setObjectHorizontalPosition
   bit gameVariation
   bmi .setObjectHorizontalPosition
   lda #OBJECT_DISABLED_STATE       ; Torpedo game--set value to not display
   sta objectIds,x                  ; object
   bne .nextObject                  ; unconditional branch
   
.setObjectHorizontalPosition
   sta zoneHorizPos,x
   jsr CalcXPos
   sta kernelZoneHorizPos,x
   ldy playerHitKernelZone
   bmi .nextObject
   sta playerFineCoarsePos,y
   lda zoneHorizPos,x
   sta playerHorizPos,y
.nextObject
   dex
   dex
   bmi DoneGameCalculations
   lsr objectStateMask              ; right shift object state mask value
   lsr objectStateMask              ; for next object iteration
   jsr NextRandom                   ; re-seed random number
   jmp SetObjectStates              ; set states of all objects
       
DoneGameCalculations SUBROUTINE
   ldx #1
.loop
   stx tempPlayerIndex
   lda gameVariation                ; get the current game variation
   and #SHOOTING_GALLERY | WATER_OBSTACLES
   lsr
   ora tempPlayerIndex
   tay                              ; save for audio channel offset
   lda #0
   sta AUDV0,x                      ; turn off sounds
   sta scoreGraphics,x              ; clear the score graphics
   lda audioFrequencies,x           ; get the frequency value
   bmi .checkNextAudioFrequency     ; check next frequency if negative
   sta AUDF0,x
   lda AudioChannelTable,y
   sta AUDC0,x
   lda #8
   sta AUDV0,x
   dec audioFrequencies,x
.checkNextAudioFrequency
   lda audioFrequencies + 2,x
   bmi CalculateScoreOffsets
   eor #$1F
   sta AUDF0,x
   lda AudioChannelTable + 1,y
   sta AUDC0,x
   lda #8
   sta AUDV0,x
   dec audioFrequencies + 2,x
CalculateScoreOffsets
   lda playerScores,x               ; get the player's score
   and #$0F                         ; mask off the upper nybbles
   sta temp                         ; save the value for later
   asl                              ; shift the value left to multiply by 4
   asl
   clc                              ; add in original so it's multiplied by 5
   adc temp                         ; [i.e. x * 5 = (x * 4) + x]
   sta lsbScoreOffsets,x
   lda playerScores,x
   and #$F0                         ; mask off the lower nybbles
   lsr                              ; divide the value by 4
   lsr
   sta temp                         ; save the value for later
   lsr                              ; divide the value by 16
   lsr
   clc                              ; add in original so it's multiplied by
   adc temp                         ; 5/16 [i.e. 5x/16 = (x / 16) + (x / 4)]
   sta msbScoreOffsets,x
   dex
   bpl .loop
   lda gameState                    ; get the current game state
   eor #GAME_RUNNING                ; (#$00 = game over, #$FF = game running)
   and gameTimer
   sta colorXOR                     ; save to colorXOR (cycles colors during
   lda #BW_HUE_MASK                 ; attract mode)
   sta hueMask                      ; set default color hue mask (assume B/W)
   ldx #NUM_KERNEL_ZONES - 1
   ldy #NUM_KERNEL_ZONES - 1
   lda SWCHB                        ; read the console switch value
   and #BW_MASK                     ; get the B/W switch value
   beq .storePlayerColors
   lda #COLOR_HUE_MASK
   sta hueMask                      ; set hue mask for color setting
   ldy #(NUM_KERNEL_ZONES * 2) - 1
.storePlayerColors
   lda PlayerColorTable,y
   eor colorXOR
   and hueMask
   sta playerColors,x
   dey                              ; reduce table offset index
   dex
   bpl .storePlayerColors
   ldx #NUM_KERNEL_ZONES - 1
   ldy #NUM_KERNEL_ZONES - 1
   bit gameVariation
   bpl .storeKernelZoneColors
   ldy #(NUM_KERNEL_ZONES * 2) - 1
.storeKernelZoneColors
   lda KernelZoneColorTable,y
   eor colorXOR
   and hueMask
   sta kernelZoneColors,x
   dey                              ; reduce table offset index
   dex
   bpl .storeKernelZoneColors
   sta COLUBK
   lda frameCount
   and #4                           ; explosion updated every 4th frame
   asl                              ; now a = 0 or 8 (sprite height)
   ora #ExplosionSprites - GameSprites
   sta explosionSpriteOffset
   rts

GameVariationTable
; ** Anti-Aircraft **
   .byte OBSTACLES
   .byte OBSTACLES|GUIDED_MISSILES
   .byte SINGLEPLAYER|OBSTACLES
   .byte 0
   .byte GUIDED_MISSILES
   .byte SINGLEPLAYER
; ** Torpedo **
   .byte MOVE_LEFT_RIGHT|WATER_OBSTACLES|OBSTACLES
   .byte MOVE_LEFT_RIGHT|WATER_OBSTACLES|OBSTACLES|GUIDED_MISSILES
   .byte MOVE_LEFT_RIGHT|SINGLEPLAYER|WATER_OBSTACLES|OBSTACLES
   .byte MOVE_LEFT_RIGHT|WATER_OBSTACLES
   .byte MOVE_LEFT_RIGHT|WATER_OBSTACLES|GUIDED_MISSILES
   .byte MOVE_LEFT_RIGHT|SINGLEPLAYER|WATER_OBSTACLES
; ** Shooting Gallery
   .byte SHOOTING_GALLERY
   .byte SHOOTING_GALLERY|GUIDED_MISSILES
   .byte SINGLEPLAYER|SHOOTING_GALLERY
; ** Polaris **
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|GUIDED_MISSILES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|SINGLEPLAYER
; ** Bomber **
   .byte POLARIS_OR_BOMBER|WATER_OBSTACLES
   .byte POLARIS_OR_BOMBER|WATER_OBSTACLES|GUIDED_MISSILES
   .byte POLARIS_OR_BOMBER|SINGLEPLAYER|WATER_OBSTACLES
; ** Polaris vs. Bomber **
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|WATER_OBSTACLES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|WATER_OBSTACLES|GUIDED_MISSILES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|SINGLEPLAYER|WATER_OBSTACLES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|WATER_OBSTACLES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|WATER_OBSTACLES|GUIDED_MISSILES
   .byte POLARIS_OR_BOMBER|MOVE_LEFT_RIGHT|POLARIS_VS_BOMBER|SINGLEPLAYER|WATER_OBSTACLES
   
ObjectShowStateTable
   .byte %00001100,%00000000,%00110000,%01111110
   
Player1KernelZoneTable
   .byte 0, -1, 6, 0
   
Player2KernelZoneTable
   .byte 1, -1, 7, 7
       
PlayerVertPosTable
   .byte YPOS_PLAYER1, YPOS_PLAYER2
       
KernelZoneColorTable
   .byte LIGHT_BLUE, LIGHT_BLUE + 2, LIGHT_BLUE + 2, LIGHT_BLUE + 4, LIGHT_BLUE + 6
   .byte LIGHT_BLUE + 8, LIGHT_BLUE + 10, LIGHT_BLUE + 12, LIGHT_BLUE + 14, BROWN + 8
   
   .byte LIGHT_BLUE + 2, LIGHT_BLUE + 2, LIGHT_BLUE + 2, LIGHT_BLUE + 2, LIGHT_BLUE + 6
   .byte LIGHT_BLUE + 8, LIGHT_BLUE + 10, LIGHT_BLUE + 12, LIGHT_BLUE + 14, BROWN + 8
       
PlayerColorTable
.blackAndWhite
   .byte BLACK + 12, BLACK + 6, BLACK + 10, BLACK + 12, WHITE
   .byte BLACK, BLACK + 6, BLACK, BLACK + 8, BLACK + 6
.color
   .byte GREEN_BLUE + 8, RED + 8, YELLOW + 6, GREEN + 12, BLUE + 12
   .byte PURPLE + 6, GREEN_BLUE + 6, RED + 8, GREEN_BLUE + 8, RED + 8
   
PlayerVelocityTable
   .byte VELOCITY_FAST              ; value not used
   .byte VELOCITY_FAST              ; joystick pushed up
   .byte VELOCITY_SLOW              ; joystick pulled back
   .byte VELOCITY_REST              ; joystick at rest

ScoreTable
   .byte LARGE_JET_SCORE, SMALL_JET_SCORE, _747_SCORE, HELICOPTER_SCORE
   .byte BLIMP_SCORE, RABBIT_SCORE, CLOWN_SCORE, DUCK_SCORE
   .byte AIRCRAFT_CARRIER_SCORE, PT_BOAT_SCORE, FREIGHTER_SCORE
   .byte PIRATE_SHIP_SCORE, MINE_SCORE, MINE_SCORE
   
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
   
GameSprites
LargeJet
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $86 ; |X....XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
SmallJet
   .byte $00 ; |........|
   .byte $BE ; |X.XXXXX.|
   .byte $88 ; |X...X...|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $08 ; |....X...|
   .byte $3E ; |..XXXXX.|
   .byte $00 ; |........|
_747
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $FE ; |XXXXXXX.|
   .byte $0F ; |....XXXX|
   .byte $18 ; |...XX...|
   .byte $30 ; |..XX....|
   .byte $00 ; |........|
Helicopter
   .byte $1F ; |...XXXXX|
   .byte $84 ; |X....X..|
   .byte $CF ; |XX..XXXX|
   .byte $7D ; |.XXXXX.X|
   .byte $0D ; |....XX.X|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
ObservationBlimp
   .byte $7E ; |.XXXXXX.|
   .byte $C3 ; |XX....XX|
   .byte $DB ; |XX.XX.XX|
   .byte $C3 ; |XX....XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Rabbit
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $44 ; |.X...X..|
   .byte $3A ; |..XXX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $46 ; |.X...XX.|
   .byte $00 ; |........|
Clown
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $BD ; |X.XXXX.X|
   .byte $81 ; |X......X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
Duck
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $0C ; |....XX..|
   .byte $0B ; |....X.XX|
   .byte $44 ; |.X...X..|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
AircraftCarrier
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
PTBoat
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $54 ; |.X.X.X..|
   .byte $7F ; |.XXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FC ; |XXXXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
Freighter
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $36 ; |..XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
PirateShip
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $AB ; |X.X.X.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $00 ; |........|
Mine_0
   .byte $2A ; |..X.X.X.|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $2A ; |..X.X.X.|
   .byte $08 ; |....X...|
   .byte $30 ; |..XX....|
   .byte $C0 ; |XX......|
   .byte $00 ; |........|
Mine_1
   .byte $18 ; |...XX...|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   
ExplosionSprites
Explosion_0
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Explosion_1
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $99 ; |X..XX..X|
   .byte $24 ; |..X..X..|
   .byte $99 ; |X..XX..X|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $00 ; |........|
   
AudioChannelTable
   .byte 8, 9, 4, 12, 3, 1, 8
   
AntiAircraftGuns
_60Degrees_0
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
_90Degress
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
_30Degress
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $07 ; |.....XXX|
   .byte $1E ; |...XXXX.|
   .byte $3C ; |..XXXX..|
   .byte $70 ; |.XXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
_60Degress_1
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $70 ; |.XXX....|
   .byte $70 ; |.XXX....|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   
MissileAngleTable
   .byte MISSILE_HORZ_VELOCITY_60   ; value not used
   .byte MISSILE_HORZ_VELOCITY_90   ; joystick pushed back
   .byte MISSILE_HORZ_VELOCITY_30   ; joystick pulled up
   .byte MISSILE_HORZ_VELOCITY_60   ; joystick at rest
   
MissileVertVelocityTable
   .byte MISSILE_VERT_VELOCITY_60   ; value not used
   .byte MISSILE_VERT_VELOCITY_90   ; joystick pushed back
   .byte MISSILE_VERT_VELOCITY_30   ; joystick pushed forward
   .byte MISSILE_VERT_VELOCITY_60   ; joystick at rest
       
MissileCollisionZoneTable
   .byte %00010000, %10000000
       
DifficultySwitchMask
MissileCollisionMask
PlayerValueMasks
   .byte $40, $80

GunXMinTable
   .byte PLAYER1_GUN_XMIN, PLAYER2_GUN_XMIN
GunXMaxTable
   .byte PLAYER1_GUN_XMAX, PLAYER2_GUN_XMAX
       
CalcXPos
   sta tempXPosition                ; save off the x position
   bpl .determineCoarseValue
   cmp #XMAX                        ; make sure object not out of range
   bcc .determineCoarseValue        ; if not compute coarse value
   lda #0
   sta tempXPosition                ; set to min value
.determineCoarseValue
   lsr                              ; divide position by 16
   lsr
   lsr
   lsr
   tay                              ; save the quotient
   lda tempXPosition                ; get the object's x position
   and #$0F                         ; keep div16 remainder
   sty tempDiv16                    ; save div16 value
   clc
   adc tempXPosition                ; add back division by 16 remainder
   cmp #15
   bcc .skipSubtractions
   sbc #15                          ; subtract 15
   iny                              ; and increment coarse value
.skipSubtractions
   cmp #XMIN                        ; make sure hasn't gone pass min x value
   eor #$0F                         ; get 4-bit two's complement for fine motion
   bcs .skipFineIncrement
   adc #1                           ; increment fine motion value
   dey                              ; reduce coarse value
.skipFineIncrement
   iny                              ; increment coarse value
   asl                              ; move fine motion value to upper nybble
   asl
   asl
   asl
   sta tempFineMotion               ; save it for later
   tya                              ; move coarse value to accumulator
   ora tempFineMotion               ; accumualtor holds fine/coarse value
   rts

;
; This is Larry Kaplan's typical LFSR psuedo-random number generator. It was
; derived from an article by Don Lancaster that appeared in BYTE magazine.
; Since this is an 8-bit LFSR the numbers will start to repeat after 255
; iterations.
; Notice that the first time this routine is called the randomSeed is 0. This
; will cause a tap of D6 which will cause the initial value to be 64d.
; see...
; http://www.ciphersbyritter.com/GLOSSARY.HTM#LinearFeedbackShiftRegister
; 
NextRandom
   lsr randomSeed
   rol
   eor randomSeed
   lsr
   lda randomSeed
   bcs .skipTap
   ora #%01000000
   sta randomSeed
.skipTap
   rts

CalculateScore SUBROUTINE
   sty tempKernelZone               ; save off zone where collision happened
   ldy #2                           ; offset for 1 point
   lda tempKernelZone
   bmi .incrementScore
   cmp playerKernelZones,x          ; leave routine if player was hit -- no
   beq .leaveRoutine                ; score for shooting yourself :-)
   txa                              ; move player number to accumulator
   eor #1                           ; XOR the value to check the next
   tay                              ; player
   lda tempKernelZone
   cmp playerKernelZones,y          ; if a player was not hit then
   bne .determinePointValue         ; determine point value
   lda gameVariation                ; leave the routine (no points) if this
   and #POLARIS_VS_BOMBER           ; is not a POLARIS_VS_BOMBER game
   beq .leaveRoutine
   ldy #2                           ; offset for 1 point
   bne .incrementScore              ; unconditional branch

.determinePointValue
   ldy tempKernelZone
   lda objectIds,y
   bmi .leaveRoutine
   lsr                              ; divide the value by 8 to get point
   lsr                              ; value offset
   lsr
   tay                              ; move point value offset to y
   lda gameVariation                ; get the current game variation
   and #OBSTACLES                   ; see if obstacles are present
                                    ; (i.e. every item is one point)
   beq .incrementScore
   tay                              ; move to y so score increments by 1
.incrementScore
   lda ScoreTable,y                 ; read the point value from table
   sed                              ; set to decimal mode
   clc
   adc playerScores,x               ; increment player's score
   sta playerScores,x
   cld                              ; clear decimal mode
   bcs .maxScoreReached             ; end game if score over 99
   cmp #MAX_SCORE                   ; compare to the max score to see if game
   bne .setAudioFrequency           ; should end
.maxScoreReached
   lda #0
   sta gameState                    ; show the game is over
   sta gameTimer                    ; reset the game timer
   sta frameCount                   ; reset the frame count
   lda #MAX_SCORE                   ; set the player's score to the maximum
   sta playerScores,x
.setAudioFrequency
   ldy tempKernelZone
   lda #$1F
   sta audioFrequencies + 2,x
   cpy #8
   bcs .resetPlayerMissile
   lda #OBJECT_HIT_STATE | EXPLOSION_TIME
   sta objectIds,y
.resetPlayerMissile
   lda #0
   sta missileVertPos,x             ; reset the missile's vertical position
   lda #LOCK_MISSILE
   sta RESMP0,x                     ; lock missile to player and disable
.leaveRoutine
   ldy tempKernelZone               ; restore y register
   rts

   IF COMPILE_REGION = NTSC
   
   .org ROM_BASE + 2048 - 6, 106    ; 2K ROM
   .word Start                      ; NMI vector
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector
   
   ELSE
   
   .org ROM_BASE + 2048 - 4, 234    ; 2K ROM
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector
   
   ENDIF
