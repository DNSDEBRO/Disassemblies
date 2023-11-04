   LIST OFF
; ***  M E G A M A N I A  ***
; Copyright 1982 Activision, Inc
; Designer: Steve Cartwright

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: November 3, 2023
;
;  *** 120 BYTES OF RAM USED 8 BYTES FREE
;  ***   0 BYTES OF ROM FREE
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
; - PAL50 version ~17% slower than NTSC
; - RAM locations $E7 and $E8 aren't used

   processor 6502

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
   
   IFNCONST CHEAT_ENABLED
   
CHEAT_ENABLED           = FALSE     ; set to TRUE to enable no death collisions

   ENDIF

   IF !(CHEAT_ENABLED = TRUE || CHEAT_ENABLED = FALSE)

      echo ""
      echo "*** ERROR: Invalid CHEAT_ENABLED value"
      echo "*** Valid values: FALSE = 0, TRUE = 1"
      echo ""
      err

   ENDIF

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
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

VBLANK_TIME             = 48
OVERSCAN_TIME           = 31

   ELSE
   
VBLANK_TIME             = 80
OVERSCAN_TIME           = 58

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

   IF COMPILE_REGION = NTSC

COLOR_PLAYER_2          = GREEN + 4
COLOR_SCORE_PLAYER_2    = GREEN + 2

COLOR_PLAYER_DEATH_BLUE = BLUE + 14
;
; Even Mega Cycle Enemy Colors
;
COLOR_HAMBURGERS_00     = PURPLE + 8
COLOR_COOKIES_00        = YELLOW + 10
COLOR_BUGS_00           = GREEN + 8
COLOR_RADIAL_TIRES_00   = PURPLE + 8
COLOR_DIAMONDS_00       = GREEN + 8
COLOR_STEAM_IRONS_00    = YELLOW + 10
COLOR_BOW_TIES_00       = BRICK_RED + 6
COLOR_SPACE_DICE_00     = YELLOW + 10
;
; Odd Mega Cycle Enemy Colors
;
COLOR_HAMBURGERS_01     = GREEN + 8
COLOR_COOKIES_01        = BRICK_RED + 6
COLOR_BUGS_01           = PURPLE + 8
COLOR_RADIAL_TIRES_01   = GREEN + 8
COLOR_DIAMONDS_01       = YELLOW + 10
COLOR_STEAM_IRONS_01    = PURPLE + 8
COLOR_BOW_TIES_01       = GREEN + 8
COLOR_SPACE_DICE_01     = YELLOW + 10

   ELSE

COLOR_PLAYER_2          = DK_GREEN + 4
COLOR_SCORE_PLAYER_2    = DK_GREEN + 2

COLOR_PLAYER_DEATH_BLUE = COBALT_BLUE + 14
;
; Even Mega Cycle Enemy Colors
;
COLOR_HAMBURGERS_00     = PURPLE + 8
COLOR_COOKIES_00        = YELLOW + 10
COLOR_BUGS_00           = DK_GREEN + 8
COLOR_RADIAL_TIRES_00   = PURPLE + 8
COLOR_DIAMONDS_00       = DK_GREEN + 8
COLOR_STEAM_IRONS_00    = YELLOW + 10
COLOR_BOW_TIES_00       = RED + 6
COLOR_SPACE_DICE_00     = YELLOW + 10
;
; Odd Mega Cycle Enemy Colors
;
COLOR_HAMBURGERS_01     = LT_BLUE + 8
COLOR_COOKIES_01        = GREEN + 6
COLOR_BUGS_01           = DK_GREEN + 8
COLOR_RADIAL_TIRES_01   = LT_BLUE + 8
COLOR_DIAMONDS_01       = YELLOW + 10
COLOR_STEAM_IRONS_01    = DK_GREEN + 8
COLOR_BOW_TIES_01       = LT_BLUE + 8
COLOR_SPACE_DICE_01     = YELLOW + 10

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 8
H_LIVES                 = 10
H_COPYRIGHT             = 8
H_ODD_ENEMY_WAVES       = 12
H_EVEN_ENEMY_WAVES      = 9
H_BLASTER               = 22
H_KERNEL                = 144
H_MISSILE               = 8
H_ENERGY_KERNEL         = 5

ENEMY_MISSILE_OFFSET    = 5

MAX_ENEMY_SECTIONS      = 6
MAX_EVEN_EMENY_SECTIONS = MAX_ENEMY_SECTIONS / 2
MAX_ODD_ENEMY_SECTIONS  = MAX_ENEMY_SECTIONS

INIT_NUM_LIVES          = 3
MAX_NUM_LIVES           = 6

SELECT_DELAY            = 30

INIT_ENEMY_DECENT_RATE  = 64
EMENY_DECENT_RATE_MASK  = $7E

ENEMY_MOVE_LEFT         = 1
ENEMY_MOVE_RIGHT        = 0
INIT_ENEMY_HORIZ_MOVE   = ENEMY_MOVE_LEFT << 3 | ENEMY_MOVE_RIGHT << 2 | ENEMY_MOVE_LEFT << 1 | ENEMY_MOVE_RIGHT << 0

ENEMY_PRESENT           = 1
ENEMY_ABSENT            = 0

XMIN                    = 0
XMAX                    = 160
YMAX                    = 240
PLAYER_MISSLE_YMAX      = H_KERNEL + 2

PLAYER_XMIN             = XMIN + 24
PLAYER_XMAX             = XMAX - 28

IRON_XMIN               = 26
IRON_XMAX               = 64

PLAYER_START_X          = 80
INIT_PLAYER_MISSILE_Y_POS = 17

MEGA_CYCLE              = 8

MAX_DEATH_TIME          = 31
MAX_ENERGY_VALUE        = 83

; SWCHA joystick bits:
MY_MOVE_RIGHT           = <(~MOVE_RIGHT) >> 4
MY_MOVE_LEFT            = <(~MOVE_LEFT) >> 4

; gameState values
GS_RESET_WAVE           = 1
GS_SCORE_RESERVED_ENERGY = 2
GS_RESET_ENERGY         = 4

; objectType ids
ID_HAMBURGER            = 0
ID_COOKIES              = 1
ID_BUGS                 = 2
ID_TIRES                = 3
ID_DIAMONDS             = 4
ID_IRON                 = 5
ID_BOW_TIES             = 6
ID_SPACE_DICE           = 7

; object score values (BCD)
HAMBURGER_SCORE         = $20
COOKIES_SCORE           = $30
BUGS_SCORE              = $40
TIRES_SCORE             = $50
DIAMONDS_SCORE          = $60
IRON_SCORE              = $70
BOW_TIES_SCORE          = $80
SPACE_DICE_SCORE        = $90

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

gameSelection           ds 1
frameCount              ds 1
randomSeed              ds 1
selectDebounce          ds 1
joystickValues          ds 2
;--------------------------------------
player1JoystickValue    = joystickValues
player2JoystickValue    = player1JoystickValue + 1
colorEOR                ds 1
colorBWMask             ds 1
gameColors              ds 5
;--------------------------------------
backgroundColor         = gameColors
energyBackgroundColor   = backgroundColor + 1
playerMissileColor      = energyBackgroundColor + 1
energyBarColor          = playerMissileColor + 1
statusKernelColor       = energyBarColor + 1
digitPointer            ds 12
playerColors            ds 2
;--------------------------------------
player1Color            = playerColors
player2Color            = player1Color + 1
playerScoreColors       ds 2
;--------------------------------------
player1ScoreColor       = playerScoreColors
player2ScoreColor       = player1ScoreColor + 1
remainingLives          ds 2
;--------------------------------------
player1Lives            = remainingLives
player2Lives            = player1Lives + 1
enemyColor              ds 1
enemyDecentRate         ds 1
enemyVertPos            ds 1
loopCount               ds 1
;--------------------------------------
tmpEnemyPattern         = loopCount ; used to bubble up enemies
;--------------------------------------
div16Remainder          = tmpEnemyPattern
;--------------------------------------
objectAnimationPtr      = div16Remainder
;--------------------------------------
tmpEnemyFCValue         = objectAnimationPtr
;--------------------------------------
tmpPlayerMissileVertPos = tmpEnemyFCValue
;--------------------------------------
tmpCopyrightCharHolder  = tmpPlayerMissileVertPos
;--------------------------------------
tmpEnemy0FineMotionValue = tmpCopyrightCharHolder
;--------------------------------------
tmpHitEnemyHorizPos     = tmpEnemy0FineMotionValue
;--------------------------------------
tmpIronVerticalTimerValue = tmpHitEnemyHorizPos
tmpOnesValueHolder      ds 1
;--------------------------------------
tmpEnemyHorizPos        = tmpOnesValueHolder  ; used to bubble up enemies
;--------------------------------------
copyrightLoopCount      = tmpEnemyHorizPos
;--------------------------------------
tmpEnemy1FineMotionValue = copyrightLoopCount
copyrightLinePtr        ds 1
;--------------------------------------
tmpEnemyMissle1Color    = copyrightLinePtr
scanline                ds 1
evenWaveLoopCount       ds 1
;--------------------------------------
tmpGRP1SizeIndex        = evenWaveLoopCount
;--------------------------------------
tmpEnemyHitIndex        = tmpGRP1SizeIndex
tmpEnemyIndex           ds 1
enemyHorizMovementPattern ds 1
oddAttackWaveVertPos    ds 1
energyFC                ds 1        ; fine/coarse position for BALL
energyBarPFValues       ds 3
;--------------------------------------
energyPF0Value          = energyBarPFValues
energyPF1Value          = energyBarPFValues + 1
energyPF2Value          = energyBarPFValues + 2
playerFC                ds 1
attackingObjectPtr      ds 2
attackingEnemyPatterns  ds 12
;--------------------------------------
currentEnemyPattern     = attackingEnemyPatterns
reserveEnemyPattern     = currentEnemyPattern + 6
playerMissileHorizPos   ds 1
enemyFCValues           ds 8
enemyNUSIZIndexes       ds 6
evenEnemyHorizPos       ds 7
;--------------------------------------
leftEvenEnemyHorizPos   = evenEnemyHorizPos
enemySection            = leftEvenEnemyHorizPos + 3
rightEvenEnemyHorizPos  = evenEnemyHorizPos + 4
colorCycleMode          ds 1
blasterColor            ds 1
animationFrame          ds 1
playerHorizPos          ds 1
currentPlayerNumber     ds 1
fireButtonDebounce      ds 1
gameState               ds 1
copyrightScrollRate     ds 1
playerScore             ds 3
waveNumber              ds 1
attackWave              ds 1
points                  ds 1
reserveScore            ds 5
energy                  ds 1

zp_Unused_01            ds 2

enemyCollisionSection   ds 2
;--------------------------------------
enemyCollisionSection_0 = enemyCollisionSection
enemyCollisionSection_1 = enemyCollisionSection_0 + 1
playerDeathTimer        ds 1
enemyMissileVertPos     ds 2
;--------------------------------------
enemyMissile1VertPos    = enemyMissileVertPos
enemyMissile2VertPos    = enemyMissile1VertPos + 1
enemyMissileHorizPos    ds 2
;--------------------------------------
enemyMissile1HorizPos   = enemyMissileHorizPos
enemyMissile2HorizPos   = enemyMissileHorizPos + 1
tmpEnemyVertPos         ds 1
enemyHorizPos           ds 6
lowestOddEnemySection   ds 1
destroyedEnemySoundValue ds 1
playerMissileVertPos    ds 1

   echo "***",(* - $80 - 2)d, "BYTES OF RAM USED", ($100 - * + 2)d, "BYTES FREE"
   
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
   ldx #<[statusKernelColor - backgroundColor]
.setGameColors
   lda GameColorTable,x
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta gameColors,x
   dex
   bpl .setGameColors
   inx                              ; x = 0
   stx CTRLPF                       ; set to NO_REFLECT playfield
   lda backgroundColor
   ldx copyrightScrollRate
   bne .setBlasterColor             ; branch if game not in progress
   ldx currentPlayerNumber          ; get the current player number
   lda playerColors,x               ; get the current player Blaster color
   ldx playerDeathTimer
   beq .setBlasterColor             ; branch if player not in death mode
   lda PlayerDeathColors,x
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
.setBlasterColor
   sta blasterColor
   jsr SetupForStatusKernel
   lda waveNumber                   ; get current wave number
   lsr                              ; shift D0 into carry
   bcc CalcEvenWaveEnemyFCValues    ; branch if this is an even wave number
CalcOddWaveEnemyFCValues
   ldy #MAX_ENEMY_SECTIONS - 1
.calcOddWaveEnemyFCValues
   sty tmpEnemyIndex                ; set enemy index value
   lda #0                           ; assume not time to show enemy
   cpy lowestOddEnemySection
   bcc .setEnemyCopyIndex           ; branch if index lower than lowest section
   lda currentEnemyPattern,y        ; get odd wave enemy pattern
.setEnemyCopyIndex
   lsr
   lsr
   lsr
   lsr
   sta enemyNUSIZIndexes,y
   beq .determineEnemyFCValue
   tax
   lda enemyHorizPos,y              ; get enemy's horizontal position
   clc
   adc EnemyHorizOffsetTable,x
   jsr CheckForEnemyOutOfRange
.determineEnemyFCValue
   jsr CalculateObjectHorizPosition
   sta tmpEnemyFCValue
   tya
   sec
   sbc #3
   ora tmpEnemyFCValue
   ldy tmpEnemyIndex
   sta enemyFCValues,y
   dey
   bpl .calcOddWaveEnemyFCValues
   bmi .doneEnemyFCCalculations     ; unconditional branch

CalcEvenWaveEnemyFCValues
   lda tmpEnemyVertPos              ; get enemy vertical position
   lsr                              ; divide value by 16
   lsr
   lsr
   lsr
   tax
   lda currentEnemyPattern          ; get current enemy pattern value
   and EnemyNUSIZIndexMaskingValues,x
   sta enemyNUSIZIndexes
   lda currentEnemyPattern + 1
   and EnemyNUSIZIndexMaskingValues + 10,x
   sta enemyNUSIZIndexes + 1
   lda currentEnemyPattern + 2
   and EnemyNUSIZIndexMaskingValues,x
   sta enemyNUSIZIndexes + 2
   ldy #MAX_EVEN_EMENY_SECTIONS - 1
CalcEvenWaveEnemyHorizPos
   ldx #1
.calcEvenWaveEnemyHorizPos
   stx evenWaveLoopCount
   lda enemyNUSIZIndexes,y
   cpx #1
   beq .determineEvenWaveEnemyHorizPos
   lsr                              ; shift NUSIZx values to lower nybbles
   lsr
   lsr
   lsr
.determineEvenWaveEnemyHorizPos
   and #7
   beq .setEvenEnemyHorizontalPosition;branch if ONE_COPY
   tax                              ; move NUSIZx value to x
   lda enemyHorizPos                ; get enemy's horizontal position
   clc
   adc EnemyHorizOffsetTable,x      ; increment by NUSIZ horizontal offset
   jsr CheckForEnemyOutOfRange      ; keep enemies within horizontal range
   ldx evenWaveLoopCount
   adc EvenWaveEnemyHorizOffsetValues,x;increment by horizontal offset
   adc EvenEnemyHorizSpacingValues,y; increment by horizontal spacing
   jsr CheckForEnemyOutOfRange      ; keep enemies within horizontal range
.setEvenEnemyHorizontalPosition
   sta leftEvenEnemyHorizPos,y
   ldx evenWaveLoopCount
   beq .nextEvenEnemyPosition
   sta rightEvenEnemyHorizPos,y
.nextEvenEnemyPosition
   dex
   bpl .calcEvenWaveEnemyHorizPos
   dey
   bpl CalcEvenWaveEnemyHorizPos
   ldx #MAX_EVEN_EMENY_SECTIONS - 1
.calcEvenWaveEnemyFCValues
   lda leftEvenEnemyHorizPos,x      ; get left side enemy horizontal position
   jsr CalculateObjectHorizPosition
   sta tmpEnemyFCValue              ; set horizontal fine motion value
   tya                              ; move coarse value to accumulator
   sec
   sbc #3                           ; adjust value for starting at cycle 14
   ora tmpEnemyFCValue              ; combine coarse and fine motion values
   sta enemyFCValues,x
   lda rightEvenEnemyHorizPos,x     ; get right side enemy horizontal position
   jsr CalculateObjectHorizPosition
   sta tmpEnemyFCValue              ; set horizontal fine motion value
   tya                              ; move coarse value to accumulator
   sec
   sbc #3                           ; adjust value for starting at cycle 14
   ora tmpEnemyFCValue              ; combine coarse and fine motion values
   sta enemyFCValues + 4,x
   dex
   bpl .calcEvenWaveEnemyFCValues
.doneEnemyFCCalculations
   lda energy                       ; get energy value (ball horiz position)
   beq .calculateEnergyFCValue
   clc
   adc #46
.calculateEnergyFCValue
   jsr CalculateObjectHorizPosition
   sta energyFC                     ; set horizontal fine motion value
   dey                              ; adjust coarse value by 3
   dey
   dey
   tya                              ; move coarse value to accumulator
   ora energyFC                     ; combine coarse and fine motion values
   sta energyFC
   lda playerHorizPos               ; get the player's horizontal position
   jsr CalculateObjectHorizPosition
   sta playerFC                     ; set horizontal fine motion value
   dey                              ; adjust coarse value by 3
   dey
   dey
   tya                              ; move coarse value to accumulator
   ora playerFC                     ; combine coarse and fine motion values
   sta playerFC
   ldx #<[HMM0 - HMP0]              ; x = 2 so attacking missiles are HMOVEd
   lda enemyMissile1HorizPos
   jsr PositionObjectHorizontally
   inx                              ; x = 3 so missile1 is HMOVEd
   lda enemyMissile2HorizPos
   jsr PositionObjectHorizontally
   inx                              ; x = 4 so ball (player laser) is HMOVEd
   lda playerMissileHorizPos
   jsr HMOVEObject
   jsr Sleep12Cycles
   jsr Sleep12Cycles
   sta HMCLR
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   sta VBLANK                       ; enable TIA (D1 = 0)
   sta NUSIZ1                       ; set player 1 to ONE_COPY
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda backgroundColor        ; 3
   sta COLUBK                 ; 3 = @09
   lda playerMissileColor     ; 3
   sta COLUPF                 ; 3 = @15   color the player missile (i.e. BALL)
   lda waveNumber             ; 3         get current wave number
   lsr                        ; 2         shift D0 into carry
   bcc EvenWaveEnemyKernel    ; 2³        branch if this is an even wave number
   jmp OddWaveEnemyKernel     ; 3

EvenWaveEnemyKernel
   ldx #H_KERNEL - 1          ; 2
.topEmptyKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2         decrement scan line
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc playerMissileVertPos   ; 3         subtract player missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setPlayerMissileValue_a;2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setPlayerMissileValue_a
   sta ENABL                  ; 3 = @21
   cpx enemyVertPos           ; 3
   bcs .topEmptyKernel        ; 2³        branch if not in enemy kernel zone
   ldy #MAX_EVEN_EMENY_SECTIONS - 1;2
.evenWaveEnemySectionLoop
   sty enemySection           ; 3
   lda #HMOVE_0               ; 2
   sta tmpEnemy0FineMotionValue;3
   sta tmpEnemy1FineMotionValue;3
   stx scanline               ; 3         move scan line count to RAM
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda enemyFCValues,y        ; 4         get the fine/coarse enemy position
   and #$0F                   ; 2         mask the fine motion value
   tax                        ; 2         move coarse value to x
   bne .coarseMoveEnemy       ; 2³
   lda #HMOVE_L6              ; 2
   sta tmpEnemy0FineMotionValue;3
   SLEEP 4                    ; 4
   sta RESP0                  ; 3 = @25
   jmp MoveNextEnemyGroup     ; 3

.coarseMoveEnemy
   dex                        ; 2
   bpl .coarseMoveEnemy       ; 2³
   SLEEP 2                    ; 2
   sta RESP0                  ; 3         reset enemy horizontal position
MoveNextEnemyGroup
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda enemyFCValues + 4,y    ; 4         get the fine/coarse enemy position
   and #$0F                   ; 2         mask the fine motion value
   tax                        ; 2         move coarse value to x
   bne .coarseMoveNextGroup   ; 2³
   lda #HMOVE_L6              ; 2
   sta tmpEnemy1FineMotionValue;3
   SLEEP 4                    ; 4
   sta RESP1                  ; 3 = @25
   jmp .doneEnemyCoarseMove   ; 3

.coarseMoveNextGroup
   dex                        ; 2
   bpl .coarseMoveNextGroup   ; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3
.doneEnemyCoarseMove
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda enemyNUSIZIndexes,y    ; 4         get enemy copies index value
   and #7                     ; 2         keep GRP1 enemy size value
   tax                        ; 2
   stx tmpGRP1SizeIndex       ; 3
   lda PlayerCopiesTable,x    ; 4
   sta NUSIZ1                 ; 3 = @21   set enemy size
   lda enemyNUSIZIndexes,y    ; 4
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tax                        ; 2
   stx tmpEnemyIndex          ; 3
   lda PlayerCopiesTable,x    ; 4
   sta NUSIZ0                 ; 3 = @45
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Sleep18Cycles          ; 18
   lda enemyFCValues,y        ; 4
   sta HMP0                   ; 3 = @28
   lda enemyFCValues + 4,y    ; 4
   sta HMP1                   ; 3 = @35
   ldx enemyColor             ; 3
   lda tmpEnemyIndex          ; 3
   bne .determineEnemyMissle2Color;2³
   ldx blasterColor           ; 3
.determineEnemyMissle2Color
   stx tmpEnemyMissle1Color   ; 3
   ldx enemyColor             ; 3
   lda tmpGRP1SizeIndex       ; 3
   bne .colorEnemyMissiles    ; 2³
   ldx blasterColor           ; 3
.colorEnemyMissiles
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpEnemyMissle1Color   ; 3
   sta COLUP0                 ; 3 = @09   color enemy missile1
   stx COLUP1                 ; 3 = @12   color enemy missile2
   lda scanline               ; 3         get last scan line count
   sbc #4                     ; 2         reduce by 4 (i.e. used 4 scan lines)
   tax                        ; 2         move scan line count to x
   lda tmpEnemy0FineMotionValue;3
   sta HMP0                   ; 3 = @25
   lda tmpEnemy1FineMotionValue;3
   sta HMP1                   ; 3 = @31
   ldy #H_EVEN_ENEMY_WAVES - 1; 2
.drawAttackingObject
   dex                        ; 2         reduce scan line
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile1VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile1Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile1Value
   sta ENAM0                  ; 3 = @51
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile2Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile2Value
   sta ENAM1                  ; 3 = @67
   lda (attackingObjectPtr),y ; 5         read attacking object sprite data
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw attacking enemy sprites
   sta GRP1                   ; 3 = @09
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc playerMissileVertPos   ; 3         subtract player missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setPlayerMissileValue_b;2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setPlayerMissileValue_b
   sta ENABL                  ; 3 = @25
   sta.w HMCLR                ; 4 = @29
   dey                        ; 2
   bpl .drawAttackingObject   ; 2³
   ldy enemySection           ; 3
   bit CXP0FB                 ; 3
   bvs .checkPlayerMissileHitEnemy;2³     branch if player missile hit enemy
   sty enemyCollisionSection_0; 3
.checkPlayerMissileHitEnemy
   bit CXP1FB                 ; 3
   bvs .nextEnemySection      ; 2³        branch if player missile hit enemy
   sty enemyCollisionSection_1; 3
.nextEnemySection
   dey                        ; 2
   bmi PrepareToDrawBlasterForEvenWave;2³
   jmp .evenWaveEnemySectionLoop;3

PrepareToDrawBlasterForEvenWave SUBROUTINE
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2         decrement scan line count
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @10   set objects to ONE_COPY
   sta NUSIZ1                 ; 3 = @13
   lda blasterColor           ; 3
   sta COLUP0                 ; 3 = @19
   sta COLUP1                 ; 3 = @22
   sta COLUP1                 ; 3 = @25   waste 3 cycles
   jsr Sleep18Cycles          ; 18
.evenWaveBlasterKernelLoop
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile1VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile1Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile1Value
   sta ENAM0                  ; 3 = @59
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile2Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile2Value
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENAM1                  ; 3 = @06
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc playerMissileVertPos   ; 3         subtract player missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setPlayerMissileValue ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setPlayerMissileValue
   sta ENABL                  ; 3 = @22
   jsr Sleep14Cycles          ; 14
   dex                        ; 2
   cpx #24                    ; 2
   bcs .evenWaveBlasterKernelLoop;2³
   jmp DrawBlasterForEvenWave ; 3

OddWaveEnemyKernel SUBROUTINE
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP 4                    ; 4
   lda playerFC               ; 3         get player's fine/coarse position
   and #$0F                   ; 2         mask fine motion value
   tay                        ; 2
.coarseMovePlayer
   dey                        ; 2
   bpl .coarseMovePlayer      ; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3         coarse move the Blaster
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda blasterColor           ; 3         get the Blaster color
   sta COLUP1                 ; 3 = @09   color the Blaster sprite
   lda enemyColor             ; 3         get the attacking enemy color
   sta COLUP0                 ; 3 = @15   color the attacking enemy sprite
   jsr Sleep12Cycles          ; 12
   lda playerFC               ; 3         get player's fine/coarse position
   sta HMP1                   ; 3 = @33   set player's fine motion
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx #H_KERNEL              ; 2
   ldy #MAX_ODD_ENEMY_SECTIONS - 1;2
   sty enemySection           ; 3
.oddWaveEnemySectionLoop
   dex                        ; 2         decrement scan line
   beq .branchToStatusKernel_a; 2³        branch if done with odd wave kernel
   lda enemyNUSIZIndexes,y    ; 4
   tay                        ; 2
   lda PlayerCopiesTable,y    ; 4
   sta NUSIZ0                 ; 3         set attacking enemy size and copy register
   sta HMCLR                  ; 3         clear horizontal movements
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #DISABLE_BM            ; 2
   cpx #H_BLASTER - 1         ; 2
   bcs .drawOddKernelBlaster_a; 2³
   sta ENABL                  ; 3 = @12   disable Blaster missile
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
.drawOddKernelBlaster_a
   sta GRP1                   ; 3 = @19   draw Blaster graphic
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setOddKernelEnemyMissileValue_a;2³ branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setOddKernelEnemyMissileValue_a
   sta ENAM1                  ; 3 = @35
   dex                        ; 2         decrement scan line
.branchToStatusKernel_a
   beq .branchToStatusKernel_b; 2³        branch if done with odd wave kernel
   ldy enemySection           ; 3
   lda enemyFCValues,y        ; 4         get the fine/coarse enemy position
   and #$0F                   ; 2         mask the fine motion value
   tay                        ; 2         move coarse position value to y register
   lda #DISABLE_BM            ; 2
   cpx #H_BLASTER - 1         ; 2
   bcs .drawOddKernelBlaster_b; 2³
   sta ENABL                  ; 3 = @59   disable Blaster missile
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
.drawOddKernelBlaster_b
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP1                   ; 3 = @06   draw Blaster graphic
   dex                        ; 2         decrement scan line
.branchToStatusKernel_b
   beq .branchToStatusKernel_c; 2³        branch if done with odd wave kernel
   cpy #0                     ; 2
   bne .coarseMoveOddKernelEnemy;2³
   SLEEP 8                    ; 8
   sta RESP0                  ; 3 = @25   coarse move attacking enemy sprite
   lda #HMOVE_L6              ; 2
   sta HMP0                   ; 3 = @30
   jmp .donePositionOddKernelEnemy;3

.coarseMoveOddKernelEnemy
   dey                        ; 2
   bpl .coarseMoveOddKernelEnemy;2³
   sta.w RESP0                ; 4
.donePositionOddKernelEnemy
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #DISABLE_BM            ; 2
   cpx #H_BLASTER - 1         ; 2
   bcs .drawOddKernelBlaster_c; 2³
   sta ENABL                  ; 3 = @12   disable Blaster missile
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
.drawOddKernelBlaster_c
   sta GRP1                   ; 3 = @19   draw Blaster graphic
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setOddKernelEnemyMissileValue_b;2³ branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setOddKernelEnemyMissileValue_b
   sta ENAM1                  ; 3 = @35
   ldy enemySection           ; 3         get the current enemy kernel section
   lda enemyFCValues,y        ; 4         get enemy horizontal movement values
   SLEEP 2                    ; 2
   sta HMP0                   ; 3 = @47   set enemy fine motion value
   lda #H_ODD_ENEMY_WAVES * 2 ; 2
   cpy #MAX_ENEMY_SECTIONS - 1; 2
   bne .setOddKernelEnemyGraphicIndex;2³
   lda oddAttackWaveVertPos   ; 3
.setOddKernelEnemyGraphicIndex
   tay                        ; 2
   dex                        ; 2         decrement scan line
   beq .jmpToStatusKernel     ; 2³        branch if done with odd wave kernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #DISABLE_BM            ; 2
   cpx #H_BLASTER - 1         ; 2
   bcs .drawOddKernelBlaster_d; 2³
   sta ENABL                  ; 3 = @12   disable Blaster missile
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
.drawOddKernelBlaster_d
   sta GRP1                   ; 3 = @19   draw Blaster graphic
   jsr Sleep18Cycles          ; 18
.drawOddWaveAttackingObject
   dex                        ; 2         decrement scan line
.branchToStatusKernel_c
   beq .jmpToStatusKernel     ; 2³        branch if done with odd wave kernel
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   sta HMCLR                  ; 3 = @53   clear horizontal movements
   bne .setOddKernelEnemyMissileValue_c;2³ branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setOddKernelEnemyMissileValue_c
   sta ENAM1                  ; 3 = @60
   lda (attackingObjectPtr),y ; 5         get enemy graphic value
   and OddKernelEnemyMaskingValues,y;4    mask out graphic bits
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06   draw enemy graphic
   cpx #H_BLASTER - 1         ; 2
   bcc .drawOddKernelBlaster_e; 2³
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc playerMissileVertPos   ; 3         subtract player missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setPlayerMissileValue ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setPlayerMissileValue
   sta ENABL                  ; 3 = @26
   dey                        ; 2         decrement enemy graphic index
   bpl .drawOddWaveAttackingObject;2³
   ldy enemySection           ; 3         get enemy kernel section
   bit CXP0FB                 ; 3
   bvs .nextOddKernelEnemySection;2³      branch if player missile hit enemy
   sty enemyCollisionSection_0; 3
.nextOddKernelEnemySection
   dey                        ; 2         decrement enemy kernel section
   sty enemySection           ; 3
   jmp .oddWaveEnemySectionLoop;3

.drawOddKernelBlaster_e
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
   sta GRP1                   ; 3         draw Blaster graphic
   lda #DISABLE_BM            ; 2
   jmp .setPlayerMissileValue ; 3

.jmpToStatusKernel
   beq StatusKernel           ; 3 + 1     unconditional branch (crosses a page)

DrawBlasterForEvenWave SUBROUTINE
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dex                        ; 2         decrement scan line
   dex                        ; 2         decrement scan line
   lda playerFC               ; 3         get player's fine/coarse position
   and #$0F                   ; 2         mask fine motion value
   tay                        ; 2
.coarseMovePlayer
   dey                        ; 2
   bpl .coarseMovePlayer      ; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3         coarse move the Blaster
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda blasterColor           ; 3         get the Blaster color
   sta COLUP1                 ; 3 = @09   color the Blaster sprite
   jsr Sleep18Cycles          ; 18
   lda playerFC               ; 3         get player's fine/coarse position
   sta HMP1                   ; 3 = @33   set player's fine motion
.drawBlasterLoop
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile1VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile1Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile1Value
   sta ENAM0                  ; 3 = @49
   txa                        ; 2         move scan line to accumulator
   sec                        ; 2
   sbc enemyMissile2VertPos   ; 3         subtract enemy missile vertical position
   and #<~(H_MISSILE - 1)     ; 2         and with 2's complement of H_MISSILE
   bne .setEnemyMissile2Value ; 2³        branch if not time to draw missile
   lda #ENABLE_BM             ; 2         enable missile if in range
.setEnemyMissile2Value
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENAM1                  ; 3 = @06
   lda BlasterGraphics,x      ; 4         get Blaster graphic value
   sta GRP1                   ; 3 = @13   draw Blaster graphic
   lda #DISABLE_BM            ; 2         disable Blaster missile
   sta ENABL                  ; 3 = @18
   sta ENABL                  ; 3 = @21
   SLEEP 4                    ; 4
   sta HMCLR                  ; 3 = @28   clear horizontal movements
   dex                        ; 2         decrement scan line
   bne .drawBlasterLoop       ; 2³+1
StatusKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx GRP1                   ; 3 = @06   clear GRP1 data
   stx ENAM0                  ; 3 = @09   disable missile0
   stx ENAM1                  ; 3 = @12   disable missile1
   stx GRP0                   ; 3 = @15   clear GRP0 data
   ldx playerDeathTimer       ; 3         get player death timer
   bne .setPlayerDeathTimer   ; 2³        branch if player currently dieing
   lda enemyMissile1VertPos   ; 3         get vertical position of missile 1
   cmp #20                    ; 2         see if it's reached player area
   bcs .checkMissile2Collision; 2³
   bit CXM0P                  ; 3         check if missile hit Blaster
   bpl .checkMissile2Collision; 2³        branch if enemy didn't shoot player
   ldx #MAX_DEATH_TIME        ; 2
.checkMissile2Collision
   lda enemyMissile2VertPos   ; 3         get vertical position of missile 2
   cmp #20                    ; 2         see if it's reached player area
   bcs .checkBlasterEnemyCollision;2³
   bit CXM1P                  ; 3         check if missile hit Blaster
   bvc .checkBlasterEnemyCollision;2³     branch if enemy didn't shoot player
   ldx #MAX_DEATH_TIME        ; 2
.checkBlasterEnemyCollision
   lda waveNumber             ; 3         get current wave number
   lsr                        ; 2         move D0 to carry
   bcc .setPlayerDeathTimer   ; 2³        enemy can't hit player on odd level
   bit CXPPMM                 ; 3         check if Blaster collided with enemy
   bpl .setPlayerDeathTimer   ; 2³        branch if enemy didn't hit player
   ldx #MAX_DEATH_TIME        ; 2
.setPlayerDeathTimer

   IF CHEAT_ENABLED

      ldx playerDeathTimer    ; 3         waste 3 cycles for CHEAT MODE

   ELSE

      stx playerDeathTimer    ; 3

   ENDIF

   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda energyFC               ; 3         get ball's fine/coarse position
   and #$0F                   ; 2         mask fine motion value
   tax                        ; 2
   SLEEP 4                    ; 4 = @14
.coarseMoveBall
   dex                        ; 2
   bpl .coarseMoveBall        ; 2³
   SLEEP 2                    ; 2
   sta RESBL                  ; 3
   lda energyFC               ; 3         get ball's fine/coarse position
   sta HMBL                   ; 3         set ball's fine motion
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   lda statusKernelColor      ; 3
   sta COLUPF                 ; 3 = @20
   ldx #MSBL_SIZE4            ; 2
   stx CTRLPF                 ; 3 = @25
   sta.w RESP0                ; 4 = @29
   sta RESP1                  ; 3 = @32
   stx NUSIZ1                 ; 3 = @35
   inx                        ; 2
   stx NUSIZ0                 ; 3 = @40   set to two players close
   lda backgroundColor        ; 3
   sta COLUP0                 ; 3 = @46
   sta COLUP1                 ; 3 = @49
   sta HMCLR                  ; 3 = @52
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @57
   lda energyBackgroundColor  ; 3         set the background color to the
   sta COLUBK                 ; 3 = @63   energy level background color
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bit CXP0FB                 ; 3
   bvs .clearCollisionRegister; 2³        branch if player missile hit enemy
   ldx #0                     ; 2
   stx enemyCollisionSection_0; 3
.clearCollisionRegister
   stx CXCLR                  ; 3
   jsr Sleep16Cycles          ; 16
   sta HMCLR                  ; 3 = @35
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Sleep18Cycles          ; 18
   jsr Sleep18Cycles          ; 18
   jsr Sleep12Cycles          ; 12
   jsr Sleep14Cycles          ; 14
   lda #ENABLE_BM             ; 2
   sta ENABL                  ; 3 = @70
   ldx #H_ENERGY_KERNEL - 1   ; 2
.energyKernelLoop
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda EnergyLiteral0,x       ; 4
   sta GRP0                   ; 3 = @10
   lda EnergyLiteral1,x       ; 4
   sta GRP1                   ; 3 = @17
   lda EnergyLiteral2,x       ; 4
   ldy energyPF2Value         ; 3
   sta HMCLR                  ; 3 = @27
   sty PF2                    ; 3 = @30
   sta GRP0                   ; 3 = @33
   lda energyBarColor         ; 3
   sta COLUPF                 ; 3 = @39
   lda energyPF0Value         ; 3
   sta PF0                    ; 3 = @45
   lda energyPF1Value         ; 3
   sta PF1                    ; 3 = @51
   ldy #$FF                   ; 2
   sty PF2                    ; 3 = @56
   sty PF0                    ; 3 = @59
   lda statusKernelColor      ; 3
   sta COLUPF                 ; 3 = @65
   sty PF1                    ; 3 = @68
   dex                        ; 2
   bpl .energyKernelLoop      ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   inx                        ; 2         x = 0
   stx GRP0                   ; 3 = @08
   stx GRP1                   ; 3 = @11
   stx ENABL                  ; 3 = @14
   ldx currentPlayerNumber    ; 3         get the current player number
   ldy remainingLives,x       ; 4         get the number of remaining lives
   lda LivesIndicatorTable,y  ; 4
   sta NUSIZ1                 ; 3 = @28
   lsr                        ; 2         shift upper nybbles to lower
   lsr                        ; 2         nybbles to get the number of copies
   lsr                        ; 2         for player 0
   lsr                        ; 2
   sta NUSIZ0                 ; 3 = @39
   sta RESP0                  ; 3 = @42
   sta RESP1                  ; 3 = @45
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @50
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda playerScoreColors,x    ; 4
   sta COLUP0                 ; 3 = @10
   sta COLUP1                 ; 3 = @13
   jsr Sleep12Cycles          ; 12
   sta HMCLR                  ; 3 = @28
   tya                        ; 2         move remaining lives to accumulator
   tax                        ; 2         move remaining lives to x register
   ldy #H_LIVES - 1           ; 2
.livesKernelLoop
   lda LivesIndicator,y       ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   sta GRP1                   ; 3 = @09
   lda #0                     ; 2
   cpx #2                     ; 2
   bcs .checkForNoLivesLeft   ; 2³
   sta GRP1                   ; 3 = @18   clear GRP1 if remaining lives < 2
.checkForNoLivesLeft
   cpx #0                     ; 2
   bne .nextLivesKernelScanline;2³
   sta GRP0                   ; 3 = @25   clear GRP0 if no lives remain
.nextLivesKernelScanline
   dey                        ; 2
   bpl .livesKernelLoop       ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @08   clear the player graphics
   sty GRP1                   ; 3 = @11   GRP1 is done twice because
   sty GRP1                   ; 3 = @14   it's VDEL'd
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   jsr Sleep18Cycles          ; 18
   sta HMCLR                  ; 3 = @32
   ldx currentPlayerNumber    ; 3         get the current player number
   lda playerScoreColors,x    ; 4
   sta COLUP0                 ; 3 = @42
   sta COLUP1                 ; 3 = @45
   ldy #H_FONT - 1            ; 2
   sty VDELP0                 ; 3 = @50
   sty VDELP1                 ; 3 = @53
.scoreLoop
   sty loopCount              ; 3
   lda (digitPointer + 10),y  ; 5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta tmpOnesValueHolder     ; 3
   lda (digitPointer),y       ; 5
   sta GRP0                   ; 3 = @14
   lda (digitPointer + 2),y   ; 5
   sta GRP1                   ; 3 = @22
   lda (digitPointer + 4),y   ; 5
   sta GRP0                   ; 3 = @30
   lda (digitPointer + 8),y   ; 5
   tax                        ; 2
   lda (digitPointer + 6),y   ; 5
   ldy tmpOnesValueHolder     ; 3
   sta GRP1                   ; 3 = @48
   stx GRP0                   ; 3 = @51
   sty GRP1                   ; 3 = @54
   sta GRP0                   ; 3 = @57
   ldy loopCount              ; 3
   dey                        ; 2
   bpl .scoreLoop             ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   iny                        ; 2         y = 0
   sty GRP0                   ; 3 = @08
   sty GRP1                   ; 3 = @11
   sty GRP0                   ; 3 = @14
   sty GRP1                   ; 3 = @17
   SLEEP 8                    ; 8
   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda backgroundColor        ; 3
   sta COLUBK                 ; 3 = @09
   lda #0                     ; 2
   sta PF0                    ; 3 = @14
   sta PF1                    ; 3 = @17
   sta PF2                    ; 3 = @20
   jsr Sleep12Cycles          ; 12
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @37
   lda #YELLOW + 6            ; 2
   eor colorEOR               ; 3         flip color bits for attract mode
   and colorBWMask            ; 3         mask color values for COLOR / B&W mode
   sta COLUP0                 ; 3 = @48
   sta COLUP1                 ; 3 = @51
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3 = @56
   stx NUSIZ1                 ; 3 = @59
   ldy #(H_COPYRIGHT * 2) - 1 ; 2
   lda #H_COPYRIGHT - 1       ; 2
   sta copyrightLoopCount     ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta VDELP0                 ; 3 = @06
   sta VDELP1                 ; 3 = @09
   lda #0                     ; 2
   sta GRP0                   ; 3 = @14
   sta GRP1                   ; 3 = @17
   sta GRP0                   ; 3 = @20
   lda copyrightScrollRate    ; 3         get the copyright scroll rate
   lsr                        ; 2         divide the value by 8
   lsr                        ; 2
   lsr                        ; 2
   cmp #20                    ; 2
   bcs CopyrightKernel        ; 2³        branch if scroll rate >= 160
   ldy #H_COPYRIGHT - 1       ; 2
   cmp #12                    ; 2
   bcc CopyrightKernel        ; 2³        branch if scroll rate < 96
   sbc #4                     ; 2         subtract value by 4 for line pointer
   tay                        ; 2
CopyrightKernel
   sty copyrightLinePtr       ; 3
   sta HMCLR                  ; 3
.copyrightLogoLoop
   ldy copyrightLinePtr       ; 3
   lda Copyright_5,y          ; 4
   sta tmpCopyrightCharHolder ; 3
   lda Copyright_4,y          ; 4
   tax                        ; 2
   lda Copyright_0,y          ; 4
   sta GRP0                   ; 3 = @72
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dec copyrightLinePtr       ; 5
   lda Copyright_1,y          ; 4
   sta GRP1                   ; 3 = @15
   lda Copyright_2,y          ; 4
   sta GRP0                   ; 3 = @22
   lda Copyright_3,y          ; 4
   ldy tmpCopyrightCharHolder ; 3
   sta GRP1                   ; 3 = @32
   stx GRP0                   ; 3 = @35
   sty GRP1                   ; 3 = @38
   sta GRP0                   ; 3 = @41
   dec copyrightLoopCount     ; 5
   bpl .copyrightLogoLoop     ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @08   turn off player vertical delay
   sta VDELP1                 ; 3 = @11
   sta GRP0                   ; 3 = @14   clear out player graphic data
   sta GRP1                   ; 3 = @17
   lda copyrightScrollRate    ; 3
   beq Overscan               ; 2³        branch if game in progress
   dec copyrightScrollRate    ; 5         reduce copyright scroll rate
   bne Overscan               ; 2³
   dec copyrightScrollRate    ; 5         make sure value is not 0
Overscan
   lda #OVERSCAN_TIME
   ldx #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for overscan period
   stx VBLANK                       ; disable TIA and discharge paddles
   ldx #1
.moveEnemyMissileDownLoop
   ldy enemyMissileVertPos,x        ; get the missile's vertical position
   tya
   clc
   adc #H_MISSILE * 2
   cmp #YMAX
   bcc .moveMissileDown
   ldy #YMAX
   bne .setMissileVerticalPos       ; unconditional branch

.moveMissileDown
   dey                              ; move missile down 2 pixels
   dey
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE * 2              ; see if player went through 2 MegaCycles
   bcc .setMissileVerticalPos       ; branch if not
   dey                              ; move missile down another pixel (faster)
.setMissileVerticalPos
   sty enemyMissileVertPos,x
   dex
   bpl .moveEnemyMissileDownLoop
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
   clc
   adc #<NumberFonts                ; add in number font LSB
   sta digitPointer + 2,x           ; set LSB pointer to digit
   dey
   bpl .bcd2DigitLoop
   ldx #0
.suppressZeroLoop
   lda digitPointer,x               ; get LSB pointer to digit
   eor #<NumberFonts                ; end suppress loop if value not zero
   bne .doneBCD2Digits
   lda #<Blank
   sta digitPointer,x
   inx
   inx
   cpx #10
   bcc .suppressZeroLoop
.doneBCD2Digits
   ldy #MAX_ENEMY_SECTIONS - 1
.checkAllEnemiesDestroyed
   lda currentEnemyPattern,y
   bne .skipIncrementWave
   dey
   bpl .checkAllEnemiesDestroyed
   ldx #GS_RESET_ENERGY | GS_SCORE_RESERVED_ENERGY | GS_RESET_WAVE
   stx gameState
   dex                              ; x = 6 (i.e. MAX_ENEMY_SECTIONS)
   stx lowestOddEnemySection
   inc waveNumber                   ; increment wave number
   lda waveNumber                   ; get current wave number
   and #7                           ; and value to get the attack wave
   sta attackWave
   ldx #0
   stx animationFrame
   stx tmpEnemyVertPos
.skipIncrementWave
   lda copyrightScrollRate
   beq SetEnemyAnimationFrame       ; branch if game in progress
   lda #0
   sta AUDV0                        ; turn off sounds by adjusting volume
   sta AUDV1
   lda playerScore + 2
   and #$0F
   bne .skipSwitchToOtherPlayer
   lda backgroundColor
   sta blasterColor
   lda gameSelection                ; get the current game selection
   lsr                              ; move D0 to carry
   bcc .skipSwitchToOtherPlayer     ; branch if a one player game
   lda frameCount                   ; get current frame count
   and #$7F
   bne .skipSwitchToOtherPlayer
   jsr SwitchToOtherPlayer
.skipSwitchToOtherPlayer
   jmp SetEnemyColor

SetEnemyAnimationFrame
   ldy attackWave                   ; get current attack wave
   ldx animationFrame               ; get current enemy animation frame
   lda frameCount                   ; get current frame count
   and #3
   bne .setEnemyAnimationFrame      ; branch if not divisible by 4
   dex                              ; decrement enemy animation frame
   bpl .setEnemyAnimationFrame
   ldx NumberOfObjectAnimations,y   ; get number of animation frames for wave
.setEnemyAnimationFrame
   stx animationFrame
   jsr SetupSpriteAnimation
   ldx attackWave                   ; get current attack wave
   lda frameCount                   ; get current frame count
   and EnemyDecendingRate,x         ; and value with decending rate
   bne .determineToChangeEnemyVerticalPosition
   inc enemyDecentRate              ; increase enemy decent rate
.determineToChangeEnemyVerticalPosition
   lda enemyDecentRate
   and #EMENY_DECENT_RATE_MASK
   cmp #INIT_ENEMY_DECENT_RATE
   bcc .changeEnemyVerticalPosition
   eor #EMENY_DECENT_RATE_MASK + 1
.changeEnemyVerticalPosition
   clc
   adc #H_KERNEL - INIT_ENEMY_DECENT_RATE
   sta enemyVertPos
SetEnemyColor
   lda waveNumber                   ; get current wave number
   and #$0F
   tax
   lda EnemyColors,x
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta enemyColor
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
   and #<~BW_MASK
   ldy colorCycleMode
.noColorCycling
   sty colorEOR                     ; set color bits for color cycling mode
   asl colorEOR
   sta colorBWMask                  ; set color mask values for COLOR / B&W mode
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blank period
   lda SWCHA                        ; read the player joystick values
   tay
   and #$0F                         ; mask out player 1's values
   sta player2JoystickValue         ; set player 2's joystick value
   tya                              ; move joystick value to accumulator
   lsr                              ; move player 1's joystick value to
   lsr                              ; lower nybble
   lsr
   lsr
   sta player1JoystickValue         ; set player 1's joystick value
   iny                              ; increment joystick value to see if moved
   beq .checkForSelectAndReset      ; branch if joystick not moved
   lda #0
   sta colorCycleMode               ; reset color cycle mode
.checkForSelectAndReset
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   bcs .skipGameReset               ; check for SELECT if RESET not pressed
   ldx #<colorCycleMode
   jmp ClearRAM

.skipGameReset
   ldy #0
   lsr                              ; SELECT now in carry
   bcs .resetSelectDebounce
   lda selectDebounce               ; get the select debounce delay
   beq .incrementGameSelection      ; if it's zero -- increase game selection
   dec selectDebounce               ; decrement select debounce
   bpl .skipGameSelect
.incrementGameSelection
   inc gameSelection
JumpIntoConsoleSwitchCheck
   lda gameSelection                ; get the current game selection
   and #3                           ; make value 0 <= a <= 3
   sta gameSelection                ; set new game selection value
   sta colorCycleMode               ; set new color cycle mode value
   ldy #0
   sty playerScore
   sty playerScore + 1
   sty attackWave
   sty points
   sty AUDV0                        ; turn off volume to turn off sounds
   sty AUDV1
   tay                              ; move game selection to y
   iny                              ; increment so player sees 1 <= y <= 4
   sty playerScore + 2              ; store in score to display game selection
   lda #$FF
   sta copyrightScrollRate
   ldy #SELECT_DELAY
.resetSelectDebounce
   sty selectDebounce
.skipGameSelect
   lda copyrightScrollRate
   beq GameProcessing               ; branch if game in progress
   jmp MainLoop

GameProcessing
   lda destroyedEnemySoundValue     ; get sound for destroyed enemy
   beq .continueGameProcessing
   dec destroyedEnemySoundValue     ; reduce destroyed enemy sound value
   lsr
   sta AUDV1                        ; set volume for destroying enemy
   ldx #$1F
   lsr
   bcs .modulateDestroyingEnemyFrequency
   ldx #0
.modulateDestroyingEnemyFrequency
   stx AUDF1
   lda #7
   sta AUDC1
.continueGameProcessing
   lda gameState                    ; get game state
   lsr                              ; shift GS_RESET_WAVE to carry
   bcs .resetGameWave               ; branch if resetting game wave
   lsr                              ; shift GS_SCORE_RESERVED_ENERGY to carry
   bcs .reduceEnergyForScoring      ; branch if incrementing score by reserved energy
   lsr                              ; shift GS_RESET_ENERGY to carry
   bcs .resetEnergy                 ; branch if resetting energy value
   jmp CheckToPlayDeathSound

.resetEnergy
   inc energy                       ; increment energy level
   lda energy                       ; get the energy value
   cmp #MAX_ENERGY_VALUE
   bcs .doneResetEnergy             ; branch if max energy value reached
   lsr                              ; divide energy value by 4
   lsr
   eor #$FF                         ; flip bits
   sta AUDF0                        ; set audio frequency for resetting energy
   lda #8
   sta AUDC0
   lda #4
   sta AUDV0
   bne .jmpToMainLoop               ; unconditional branch

.doneResetEnergy
   lda gameState                    ; get current game state
   eor #GS_RESET_ENERGY             ; flip GS_RESET_ENERGY value
   sta gameState
   lda #0
   sta AUDV0                        ; turn off volume for sound channel 0
   lda #INIT_ENEMY_DECENT_RATE
   sta enemyDecentRate              ; reset enemy decent rate
   bne .jmpToMainLoop               ; unconditional branch

.reduceEnergyForScoring
   lda frameCount                   ; get current frame count
   and #1
   bne .jmpToMainLoop               ; branch if an odd frame
   lda energy                       ; get the energy value
   bne .bonusForRemainingEnergy
   lda gameState                    ; get current game state
   eor #GS_SCORE_RESERVED_ENERGY    ; flip GS_SCORE_RESERVED_ENERGY value
   sta gameState
.jmpToMainLoop
   jmp JmpToMainLoop

.bonusForRemainingEnergy
   and #$0F
   eor #$FF
   sta AUDF0                        ; set audio frequency for bonus points
   lda #4
   sta AUDV0
   lda #12
   sta AUDC0
   jsr DeterminePointValue
   dec energy                       ; reduce energy level
   jmp IncrementScore               ; increment score for remaining energy

.resetGameWave
   lda gameState
   eor #GS_RESET_WAVE
   sta gameState
   ldy #MAX_ENEMY_SECTIONS - 1
.determineWaveEnemyPattern
   ldx #(ENEMY_ABSENT << 7 | ENEMY_PRESENT << 6 | ENEMY_PRESENT << 5 | ENEMY_PRESENT << 4)
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE * 2
   bcc .determineOddOrEvenWave
   cmp #(MEGA_CYCLE * 3) - 1
   beq .removeThirdEnemyPattern
   and #7                           ; and value to keep the attack wave
   cmp #ID_TIRES
   bcs .determineOddOrEvenWave
.removeThirdEnemyPattern
   ldx #(ENEMY_ABSENT << 7 | ENEMY_PRESENT << 6 | ENEMY_ABSENT << 5 | ENEMY_PRESENT << 4)
.determineOddOrEvenWave
   lsr                              ; move D0 of wave number to carry
   bcs .setEnemyPattern             ; branch if an odd wave number
   ldx InitEvenWaveEnemyPatterns,y
.setEnemyPattern
   stx currentEnemyPattern,y
   ldx #0
   stx playerDeathTimer
   stx enemyHorizPos,y              ; set enemy's horizontal position
   dey
   bpl .determineWaveEnemyPattern
   iny                              ; y = 0
   sty tmpEnemyVertPos
   lda #YMAX
   sta enemyMissile1VertPos
   sta enemyMissile2VertPos
   bne .branchToMainLoop            ; unconditional branch

CheckToPlayDeathSound
   ldx playerDeathTimer             ; get player death timer
   bne PlayerDeathSound             ; play death sound if not 0
   lda energy                       ; get the energy value
   beq EnergyTimerDone              ; branch if energy has run out
   jmp DetermineEnemyToDropMissile

EnergyTimerDone
   ldx #MAX_DEATH_TIME
   stx playerDeathTimer             ; set player death timer
PlayerDeathSound
   txa
   and #$1F
   tax
   cmp #16
   bcc .setVolumeForDeathSound
   eor #$1F
.setVolumeForDeathSound
   lsr
   sta AUDV0
   ldy #$08
   lda frameCount                   ; get current frame count
   lsr                              ; move D0 to carry
   bcs .setChannelForDeathSound     ; branch if this an odd frame
   ldy #$0F
.setChannelForDeathSound
   sty AUDC0
   lda #YMAX
   sta enemyMissile1VertPos
   sta enemyMissile2VertPos
   lda #0
   sta AUDF0
   sta energy
   sta enemyCollisionSection_0
   sta enemyCollisionSection_1
   sta playerMissileVertPos
   cpx #9
   bcs .checkToDecrementPlayerDeathTimer
   sta tmpEnemyVertPos
   ldx #MAX_ENEMY_SECTIONS
   stx lowestOddEnemySection
   dex
.clearEnemyHorizPositions
   sta enemyHorizPos,x
   dex
   bpl .clearEnemyHorizPositions
.checkToDecrementPlayerDeathTimer
   lda frameCount                   ; get current frame count
   and #3
   bne .branchToMainLoop            ; branch if not divisible by 4
   dec playerDeathTimer             ; reduce player death timer
   bne .branchToMainLoop            ; branch if death scene not done
   lda player1Lives                 ; get player 1 lives
   ora player2Lives                 ; or in player 2 lives
   bne .reduceNumberOfLives         ; branch if game still in play
   inc copyrightScrollRate
   lda backgroundColor
   sta blasterColor
   jmp .branchToMainLoop

.reduceNumberOfLives
   jsr ReduceNumberOfLives
   lda #PLAYER_START_X
   sta playerHorizPos
   lda #GS_RESET_ENERGY
   sta gameState
.branchToMainLoop
   jmp JmpToMainLoop

DetermineEnemyToDropMissile
   lda waveNumber                   ; get current wave number
   lsr                              ; move D0 to carry
   bcc .determineEvenWaveEnemyToDropMissile; branch if an even wave number
   jmp .determineOddWaveEnemyToDropMissile

.determineEvenWaveEnemyToDropMissile
   lda enemyVertPos                 ; get enemy vertical position
   cmp #85
   bcs .evenWaveEnemyAbleToDropMissile
   jmp MovePlayerLaserGun

.evenWaveEnemyAbleToDropMissile
   lda frameCount                   ; get current frame count
   lsr                              ; divide value by 16
   lsr
   lsr
   lsr
   and #1
   tax
   ldy #0
.launchEnemyMissile
   sty tmpEnemyIndex
   lda currentEnemyPattern,y
   and EnemyGroupMaskValues,x
   beq .nextLaunchEnemyMissile      ; branch if no enemy found
   lda enemyMissileVertPos,x        ; get enemy missile vertical position
   cmp #YMAX
   bne .nextLaunchEnemyMissile
   txa                              ; move enemy index to accumulator
   asl                              ; multiply value by 4
   asl
   clc                              ; not needed...carry will be clear here
   adc tmpEnemyIndex
   tay
   lda evenEnemyHorizPos,y
   clc
   adc #ENEMY_MISSILE_OFFSET
   sta enemyMissileHorizPos,x
   lda enemyVertPos
   sec
   ldy tmpEnemyIndex
   sbc InitEnemyMissileVertPosOffset,y
   sta enemyMissileVertPos,x
.nextLaunchEnemyMissile
   iny
   cpy #MAX_EVEN_EMENY_SECTIONS
   bcc .launchEnemyMissile
   jmp MovePlayerLaserGun

.determineOddWaveEnemyToDropMissile
   lda attackWave                   ; get current attack wave
   eor #7
   beq MovePlayerLaserGun           ; branch if enemy cannot fire this wave
   lda lowestOddEnemySection
   cmp #MAX_ENEMY_SECTIONS - 1
   bcs MovePlayerLaserGun           ; branch if enemy not present on screen
   lda enemyMissile2VertPos         ; get enemy missile vertical position
   cmp #YMAX
   bne MovePlayerLaserGun           ; branch if enemy missile active
   lda currentEnemyPattern + 4
   beq MovePlayerLaserGun
   lsr
   lsr
   lsr
   lsr
   tay
   lda enemyHorizPos + 4
   clc
   adc #ENEMY_MISSILE_OFFSET
   clc
   adc EnemyHorizOffsetTable,y
   sta enemyMissile2HorizPos
   lda #H_KERNEL - 32
   sec
   sbc oddAttackWaveVertPos
   sta enemyMissile2VertPos
MovePlayerLaserGun
   ldy currentPlayerNumber          ; get the current player number
   ldx playerHorizPos               ; load x with player horizontal position
   lda joystickValues,y             ; get the player's joystick value
   and #MY_MOVE_RIGHT
   bne .checkForMovingLeft
   cpx #PLAYER_XMAX
   bcs .checkForMovingLeft
   inx                              ; move player right
.checkForMovingLeft
   lda joystickValues,y             ; get the player's joystick value
   and #MY_MOVE_LEFT
   bne .setPlayerHorizPosition
   cpx #PLAYER_XMIN
   bcc .setPlayerHorizPosition
   dex                              ; move player left
.setPlayerHorizPosition
   stx playerHorizPos
   lda playerHorizPos               ; get the player's horizontal position
   clc
   adc #5                           ; offset missile by 5
   tax                              ; x is new missile horizontal position
   lda gameSelection                ; get the current game selection
   cmp #2
   bcs .checkToLaunchPlayerMissile  ; branch if not a guided missile game
   stx playerMissileHorizPos        ; set missile's horizontal position
   lda #$FF
   sta fireButtonDebounce
.checkToLaunchPlayerMissile
   lda playerMissileVertPos         ; get the player missile vertical position
   bne .movePlayerMissileVertically ; branch if missile active
   stx playerMissileHorizPos        ; set player missile horizontal position
   sta AUDV0                        ; turn off sound (i.e. a = 0)
   lda INPT4,y                      ; read the player's fire button
   tay                              ; move fire button value to y
   eor fireButtonDebounce           ; flip bits of fire button debounce
   and fireButtonDebounce           ; clear out bits
   sty fireButtonDebounce           ; set fire button debounce bits
   bpl DetermineEnemyHitByBlasterMissile;branch if fire button not pressed
   lda #4
   sta AUDV0
   lda #INIT_PLAYER_MISSILE_Y_POS
.movePlayerMissileVertically
   sta tmpPlayerMissileVertPos
   ldy #4                           ; missile speed for AMATEUR
   lda SWCHB                        ; read console switches
   asl                              ; player 2 difficutly in carry
   ldx currentPlayerNumber          ; get the current player number
   bne .checkToReduceMissileSpeed   ; branch if for player 2
   asl                              ; player 1 difficulty in carry
.checkToReduceMissileSpeed
   bcc .incrementMissileVerticalPosition; branch if AMATEUR
   dey                              ; reduce missile speed
.incrementMissileVerticalPosition
   tya                              ; move missile speed to accumulator
   clc
   adc tmpPlayerMissileVertPos      ; move player missile vertically
   cmp #PLAYER_MISSLE_YMAX
   bcc .setMissileVerticalPosition
   lda #0
   sta AUDV0
.setMissileVerticalPosition
   sta playerMissileVertPos
   lsr                              ; divide value by 8 for the frequency
   lsr
   lsr
   sta AUDF0                        ; set frequency for player missile
   lda #15
   sta AUDC0                        ; set audio channel for player missile
DetermineEnemyHitByBlasterMissile
   ldx #1
.determineEnemyHitByBlasterMissile
   stx tmpEnemyHitIndex
   ldy enemyCollisionSection,x      ; get hit enemy kernel section
   beq .determineNextEnemyHitByBlasterMissile;branch if enemy not hit by player
   dey                              ; decrement enemy kernel section
   sty tmpEnemyIndex
   ldx enemyHorizPos,y              ; get enemy's horizontal position
   lda waveNumber                   ; get current wave number
   lsr                              ; move D0 to carry
   bcs .setHitEnemyHorizPos         ; branch if an odd wave number
   ldx tmpEnemyHitIndex
   lda enemyHorizPos                ; get enemy's horizontal position
   adc EvenWaveEnemyHorizOffsetValues,x
   jsr CheckForEnemyOutOfRange
   tax
.setHitEnemyHorizPos
   stx tmpHitEnemyHorizPos          ; save enemy horizontal position
   lda playerMissileHorizPos        ; get player missile hoizontal position
   sec
   sbc tmpHitEnemyHorizPos          ; subtract hit enemy horizontal position
   bcs .determineEnemyMaskingPattern
   adc #XMAX
.determineEnemyMaskingPattern
   lsr
   lsr
   lsr
   lsr
   lsr
   tay
   lda GRP0_EnemyMaskingPatternValues,y
   ldx tmpEnemyHitIndex
   cpx #0                           ; not needed...could save 2 bytes
   beq .removeHitEnemyFromArray
   lda GRP1_EnemyMaskingPatternValues,y
.removeHitEnemyFromArray
   ldy tmpEnemyIndex
   and currentEnemyPattern,y
   sta currentEnemyPattern,y
   lda #32
   sta destroyedEnemySoundValue
   jsr DeterminePointValue
   lda #0
   sta playerMissileVertPos
.determineNextEnemyHitByBlasterMissile
   ldx tmpEnemyHitIndex
   dex
   bpl .determineEnemyHitByBlasterMissile
   lda attackWave                   ; get current attack wave
   cmp #ID_IRON
   bne DetermineEnemyMovement
   jmp DetermineIronEnemyMovement

DetermineEnemyMovement
   lsr                              ; shift D0 to carry bit
   bcs DetermineOddAttackWaveEnemyMovement;branch if an odd attack wave
   ldy #0                           ; set to cycle once for movement changes
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE - 1
   bcc .incrementEnemyHorizPos      ; branch if we haven't reached a MEGA_CYCLE
   lda frameCount                   ; get current frame count
   cmp #80
   bcc .doneDetermineEvenAttackWaveEnemyMovement; pause enemy for ~1.33 seconds
   cmp #128
   bcs .incrementEnemyHorizPos
   ldy #1                           ; set to cycle twice for movement changes
.incrementEnemyHorizPos
   ldx tmpEnemyVertPos              ; get the enemy's vertical position
   inc enemyHorizPos                ; increment the enemy's horizontal position
   lda enemyHorizPos                ; get enemy's horizontal position
   cmp #XMAX
   bcc .setEnemyHorizontalPosition
   sbc #XMAX                        ; wrap enemy horizontally
.setEnemyHorizontalPosition
   sta enemyHorizPos
   cpx #H_KERNEL + 1
   bcs .setEnemyVerticalPosition
   inx
.setEnemyVerticalPosition
   stx tmpEnemyVertPos
   dey
   bpl .incrementEnemyHorizPos
.doneDetermineEvenAttackWaveEnemyMovement
   jmp DecrementEnergyLevel

DetermineOddAttackWaveEnemyMovement
   ldy #0
   lda waveNumber                   ; get current wave number
   and #$0F
   cmp #MEGA_CYCLE - 1
   bne .determineOddAttackEnemyIndex
   ldy #1
.determineOddAttackEnemyIndex
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE * 2
   bcc .setOddAttackEnemyIndex
   ldy #1
.setOddAttackEnemyIndex
   sty tmpEnemyIndex
   ldx oddAttackWaveVertPos
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE - 1
   bcs .incrementOddAttackEnemyVerticalTimer
   lda frameCount                   ; get current frame count
   and #$50                         ; a = 0 || a = 16 || a = 64 || a = 80
   bne .checkToScrollOddAttackEnemyDown
.incrementOddAttackEnemyVerticalTimer
   inx
.checkToScrollOddAttackEnemyDown
   cpx #29
   bcc .setOddAttackWaveMovementTimerValue
   lda currentEnemyPattern
   sta tmpEnemyPattern
   lda enemyHorizPos                ; get enemy's horizontal position
   sta tmpEnemyHorizPos
   ldy #1
.scrollEnemyDown
   lda enemyHorizPos,y              ; get enemy's horizontal position
   sta enemyHorizPos - 1,y
   lda currentEnemyPattern,y
   sta currentEnemyPattern - 1,y
   iny
   cpy #MAX_ENEMY_SECTIONS
   bcc .scrollEnemyDown
   lda tmpEnemyPattern
   sta currentEnemyPattern + 5
   lda tmpEnemyHorizPos
   sta enemyHorizPos + 5
   lda lowestOddEnemySection
   beq CheckToRotateEnemyPatternRight
   dec lowestOddEnemySection
CheckToRotateEnemyPatternRight
   lda attackWave                   ; get current attack wave
   cmp #ID_IRON
   beq .rotateEnemyMovementPatternRight;branch if ID_IRON wave
   jsr NextRandom
   and #$7F
   clc
   adc #16
   sta enemyHorizPos + 5
.rotateEnemyMovementPatternRight
   lda enemyHorizMovementPattern
   lsr                              ; shift D0 to carry and 0 to D7
   ror enemyHorizMovementPattern    ; shift carry to D7
   ldx #0
.setOddAttackWaveMovementTimerValue
   stx oddAttackWaveVertPos
   ldy tmpEnemyIndex
   dey
   bpl .setOddAttackEnemyIndex
   lda attackWave                   ; get current attack wave
   cmp #ID_COOKIES
   beq DetermineCookieHorizPosition
   cmp #ID_TIRES
   beq MoveTires
   cmp #ID_SPACE_DICE
   beq MoveSpaceDice
   jmp DecrementEnergyLevel

MoveTires
   lda #(INIT_ENEMY_HORIZ_MOVE << 4) | INIT_ENEMY_HORIZ_MOVE
   jmp MoveEnemyHorizontally

DetermineCookieHorizPosition
   ldy #MAX_ENEMY_SECTIONS - 1
.determineCookieHorizPosition
   ldx enemyHorizPos,y              ; get enemy's horizontal position
   inx                              ; move enemy one pixel to the right
   bit frameCount
   bmi .checkCookieHorizWrap        ; branch if frame count > 127
   dex                              ; move enemy one pixel to the left
   dex
.checkCookieHorizWrap
   jsr CheckForEnemyHorizWrap
   dey
   bpl .determineCookieHorizPosition
   jmp DecrementEnergyLevel

DetermineIronEnemyMovement
   ldx oddAttackWaveVertPos
   lda frameCount                   ; get current frame count
   and #$1F                         ; 0 <= a <= 31
   bne .determineIronEnemyMovement
   jsr NextRandom                   ; get new random number ~ every 30 seconds
.determineIronEnemyMovement
   lda frameCount                   ; get current frame count
   and #1
   bne .setIronVerticalTimerValue   ; branch if an odd frame
   lda randomSeed                   ; get current random seed
   and #7
   cmp #4
   bcc .setIronVerticalTimerValue
   inx                              ; increment Iron vertical timer value
.setIronVerticalTimerValue
   stx tmpIronVerticalTimerValue
   ldy #MAX_ENEMY_SECTIONS - 1
.determineIronHorizPosition
   ldx enemyHorizPos,y              ; get enemy's horizontal position
   txa                              ; move enemy's horizontal position to accumulator
   sec
   sbc #IRON_XMIN
   cmp #(IRON_XMAX / 2) + 7
   bcc .determineIronHorizMovement
   ldx #(IRON_XMAX / 2)
.determineIronHorizMovement
   bit randomSeed
   bmi .moveIronsLeft
   inx                              ; move Irons one pixel to the right
   cpx #IRON_XMAX
   bcc .setIronHorizontalPosition
   ldx #IRON_XMAX                   ; set Iron right most pixel to 64
   bne .setIronHorizontalPosition   ; unconditional branch

.moveIronsLeft
   dex                              ; move Irons one pixel to the left
   cpx #IRON_XMIN
   bcs .setIronHorizontalPosition
   ldx #IRON_XMIN                   ; set Iron left most pixel to 26
.setIronHorizontalPosition
   stx enemyHorizPos,y
   dey
   bpl .determineIronHorizPosition
   iny                              ; y = 0
   sty tmpEnemyIndex
   ldx tmpIronVerticalTimerValue
   jmp .checkToScrollOddAttackEnemyDown

MoveSpaceDice
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE
   bcc DecrementEnergyLevel
   lda enemyHorizMovementPattern
MoveEnemyHorizontally
   ldy #MAX_ENEMY_SECTIONS - 1
.moveEnemyHorizontally
   ldx enemyHorizPos,y              ; get enemy's horizontal position
   inx                              ; move enemy one pixel to the right
   rol                              ; shift movement pattern left
   bcc .checkForEnemyHorizWrap      ; branch if enemy moving right
   dex                              ; move enemy one pixel to the left
   dex
.checkForEnemyHorizWrap
   jsr CheckForEnemyHorizWrap       ; check to horizontally wrap enemy
   dey
   bpl .moveEnemyHorizontally
DecrementEnergyLevel
   lda frameCount                   ; get current frame count
   and #$1F
   bne IncrementScore
   lda energy                       ; get the energy value
   beq IncrementScore
   dec energy                       ; reduce energy level
IncrementScore
   lda points                       ; get the current point value
   beq .doneIncrementScore
   sed
   clc
   adc playerScore + 2
   sta playerScore + 2
   bcc .doneIncrementScore
   lda playerScore + 1
   adc #1 - 1
   sta playerScore + 1
   lda playerScore
   adc #1 - 1
   bcc .skipScoreMaxOut
   lda #$99                         ; make the score 999,999
   sta playerScore + 1
   sta playerScore + 2
   inc copyrightScrollRate
.skipScoreMaxOut
   sta playerScore
   lda playerScore + 1
   and #$FF
   bne .doneIncrementScore
   ldy currentPlayerNumber          ; get the current player number
   lda remainingLives,y             ; get the number of remaining lives
   cmp #MAX_NUM_LIVES
   bcs .doneIncrementScore
   adc #1
   sta remainingLives,y
.doneIncrementScore
   cld
   lda #0
   sta points                       ; clear out point value
JmpToMainLoop
   jmp MainLoop

SetupForStatusKernel SUBROUTINE
   ldx #6
   lda waveNumber                   ; get current wave number
   lsr                              ; move D0 to carry
   bcs .setEnergyPlayfieldValues    ; branch if an odd wave number
   ldx #3
   stx enemyCollisionSection_1
.setEnergyPlayfieldValues
   stx enemyCollisionSection_0
   lda energy                       ; get the energy value
   lsr                              ; divide value by 4 for playfeild graphic
   lsr                              ; lookup table
   tax
   lda EnergyPF0Table,x             ; set the energy playfield values based
   sta energyPF0Value               ; on the energy value
   lda EnergyPF1Table,x
   sta energyPF1Value
   lda EnergyPF2Table,x
   sta energyPF2Value
   lda #BLUE + 4                    ; get the color for player 1
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta player1Color                 ; set player1's color
   lda #BLUE + 2                    ; get the color for player1's score
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta player1ScoreColor            ; set player1's score color
   ldx #COLOR_PLAYER_2              ; get the color for player 2
   ldy #COLOR_SCORE_PLAYER_2        ; get the color for player 2's score
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   bne .colorMode
   ldx #BLACK + 8
   ldy #WHITE - 2
.colorMode
   txa
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta player2Color                 ; set player 2's color
   tya
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta player2ScoreColor            ; set player 2's score color
   rts

CheckForEnemyOutOfRange
   bcs .reduceHorizPosValue
   cmp #XMAX
   bcc .skipReduceHorizPosValue
.reduceHorizPosValue
   sbc #XMAX
.skipReduceHorizPosValue
   clc
   rts

SwitchToOtherPlayer
   ldx #5
.swapEnemyPatternLoop
   lda currentEnemyPattern,x        ; get the current enemy pattern
   ldy reserveEnemyPattern,x        ; get the enemy pattern in reserve
   sty currentEnemyPattern,x        ; store reserve pattern in current pattern
   sta reserveEnemyPattern,x        ; move current pattern to reserve
   dex
   bpl .swapEnemyPatternLoop
   ldx #4
.swapPlayerScoreLoop
   lda playerScore,x                ; get the current score
   ldy reserveScore,x               ; get the score value from reserve
   sty playerScore,x                ; store reserve value in current score
   sta reserveScore,x               ; move score to reserve value
   dex
   bpl .swapPlayerScoreLoop
   lda currentPlayerNumber          ; get the current player number
   eor #1                           ; xor with 1 to get new player number
   sta currentPlayerNumber          ; (i.e. 0 <= a <= 1)
   tax
   lda NumberOfObjectAnimations,x
   sta animationFrame
SetupSpriteAnimation
   lda attackWave                   ; get current attack wave
   asl                              ; multiply by 2
   tay
   lda ObjectAnimationTable,y       ; read the LSB for the object animation
   sta objectAnimationPtr
   jmp SetAttackingObjectPtr

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
;   .byte $00 ; |........|
;   .byte $00 ; |........|
;   .byte $00 ; |........|
;   .byte $00 ; |........|
;
; last 4 bytes shared with table below
;
BlasterGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $41 ; |.X.....X|
   .byte $41 ; |.X.....X|
   .byte $41 ; |.X.....X|
   .byte $49 ; |.X..X..X|
   .byte $6B ; |.XX.X.XX|
   .byte $7F ; |.XXXXXXX|
   .byte $5D ; |.X.XXX.X|
   .byte $5D ; |.X.XXX.X|
   .byte $49 ; |.X..X..X|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $1C ; |...XXX..|
   .byte $08 ; |....X...|

Copyright_0
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
   .byte $F7 ; |XXXX.XXX|
   .byte $95 ; |X..X.X.X|
   .byte $87 ; |X....XXX|
   .byte $80 ; |X.......|
   .byte $90 ; |X..X....|
   .byte $F0 ; |XXXX....|
Copyright_1
   .byte $AD ; |X.X.XX.X|
   .byte $A9 ; |X.X.X..X|
   .byte $E9 ; |XXX.X..X|
   .byte $A9 ; |X.X.X..X|
   .byte $ED ; |XXX.XX.X|
   .byte $41 ; |.X.....X|
   .byte $0F ; |....XXXX|
   .byte $00 ; |........|
   .byte $47 ; |.X...XXX|
   .byte $41 ; |.X.....X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $75 ; |.XXX.X.X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
Copyright_2
   .byte $50 ; |.X.X....|
   .byte $58 ; |.X.XX...|
   .byte $5C ; |.X.XXX..|
   .byte $56 ; |.X.X.XX.|
   .byte $53 ; |.X.X..XX|
   .byte $11 ; |...X...X|
   .byte $F0 ; |XXXX....|
   .byte $00 ; |........|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $4B ; |.X..X.XX|
   .byte $4A ; |.X..X.X.|
   .byte $6B ; |.XX.X.XX|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
Copyright_3
   .byte $BA ; |X.XXX.X.|
   .byte $8A ; |X...X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $A2 ; |X.X...X.|
   .byte $3A ; |..XXX.X.|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $80 ; |X.......|
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $BA ; |X.XXX.X.|
   .byte $22 ; |..X...X.|
   .byte $27 ; |..X..XXX|
   .byte $02 ; |......X.|
Copyright_4
   .byte $E9 ; |XXX.X..X|
   .byte $AB ; |X.X.X.XX|
   .byte $AF ; |X.X.XXXX|
   .byte $AD ; |X.X.XX.X|
   .byte $E9 ; |XXX.X..X|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $11 ; |...X...X|
   .byte $11 ; |...X...X|
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $17 ; |...X.XXX|
   .byte $00 ; |........|
Copyright_5
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
   .byte $77 ; |.XXX.XXX|
   .byte $54 ; |.X.X.X..|
   .byte $77 ; |.XXX.XXX|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|
   .byte $00 ; |........|

EnergyLiteral0
   .byte $D2 ; |XX.X..X.|
   .byte $96 ; |X..X.XX.|
   .byte $DE ; |XX.XXXX.|
   .byte $9A ; |X..XX.X.|
   .byte $D2 ; |XX.X..X.|
EnergyLiteral1
   .byte $D5 ; |XX.X.X.X|
   .byte $99 ; |X..XX..X|
   .byte $D5 ; |XX.X.X.X|
   .byte $95 ; |X..X.X.X|
   .byte $D9 ; |XX.XX..X|
EnergyLiteral2
   .byte $D0 ; |XX.X....|
   .byte $50 ; |.X.X....|
   .byte $50 ; |.X.X....|
   .byte $38 ; |..XXX...|
   .byte $A8 ; |X.X.X...|

GameColorTable
   .byte BLACK                      ; background color (sky)
   .byte RED + 2                    ; reduced energy bar color
   .byte RED + 4                    ; player missile (BALL) color
   .byte YELLOW + 10                ; remaining energy color (BALL)
   .byte BLACK + 6                  ; status kernel background color

EnemyColors
;
; even "MegaCycle" colors
;
   .byte COLOR_HAMBURGERS_00        ; Hamburgers
   .byte COLOR_COOKIES_00           ; Cookies
   .byte COLOR_BUGS_00              ; Bugs
   .byte COLOR_RADIAL_TIRES_00      ; Radial Tires
   .byte COLOR_DIAMONDS_00          ; Diamonds
   .byte COLOR_STEAM_IRONS_00       ; Steam Irons
   .byte COLOR_BOW_TIES_00          ; Bow Ties
   .byte COLOR_SPACE_DICE_00        ; Space Dice
;
; odd "MegaCycle" colors
;
   .byte COLOR_HAMBURGERS_01        ; Hamburgers
   .byte COLOR_COOKIES_01           ; Cookies
   .byte COLOR_BUGS_01              ; Bugs
   .byte COLOR_RADIAL_TIRES_01      ; Radial Tires
   .byte COLOR_DIAMONDS_01          ; Diamonds
   .byte COLOR_STEAM_IRONS_01       ; Steam Irons
   .byte COLOR_BOW_TIES_01          ; Bow Ties
   .byte COLOR_SPACE_DICE_01        ; Space Dice

GRP0_EnemyMaskingPatternValues
   .byte $3F,$5F,$6F
   
GRP1_EnemyMaskingPatternValues
   .byte $F3,$F5,$F6
   
EnemyGroupMaskValues
   .byte $F0, $0F

LivesIndicator
   .byte $00 ; |........|
   .byte $F0 ; |XXXX....|
   .byte $20 ; |..X.....|
   .byte $22 ; |..X...X.|
   .byte $37 ; |..XX.XXX|
   .byte $7F ; |.XXXXXXX|
   .byte $37 ; |..XX.XXX|
   .byte $22 ; |..X...X.|
   .byte $20 ; |..X.....|
   .byte $F0 ; |XXXX....|

EnemyNUSIZIndexMaskingValues
   .byte %00000001
   .byte %00000001
   .byte %00000011
   .byte %00000011
   .byte %00000111
   .byte %00000111
   .byte %00010111
   .byte %00010111
   .byte %00110111
   .byte %00110111
   .byte %00000000
   .byte %00000010
   .byte %00000010
   .byte %00000110
   .byte %00000110
   .byte %00010110
   .byte %00010110
   .byte %00110110
   .byte %00110110
   .byte %01110111

EnemyHorizOffsetTable
   .byte 0, 64, 32, 32, 0

PlayerCopiesTable
   .byte ONE_COPY, ONE_COPY, ONE_COPY, TWO_MED_COPIES, ONE_COPY
   .byte TWO_WIDE_COPIES, TWO_MED_COPIES, THREE_MED_COPIES

EvenWaveEnemyHorizOffsetValues
   .byte 0, (XMAX / 2) + 16

EvenEnemyHorizSpacingValues
   .byte 0, 16

EnergyPFValues
EnergyPF0Table
   .byte $00,$00,$00,$00
EnergyPF2Table
   .byte $00,$01,$03,$07,$0F,$1F,$3F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
   .byte $FF,$FF,$FF,$FF,$FF
EnergyPF1Table
   .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$C0,$E0
   .byte $F0,$F8,$FC,$FE,$FF

InitEnemyMissileVertPosOffset
   .byte 50, 41, 27

InitEvenWaveEnemyPatterns
   .byte ENEMY_ABSENT << 7 | ENEMY_ABSENT << 6 | ENEMY_PRESENT << 5 | ENEMY_PRESENT << 4 |ENEMY_ABSENT << 3 | ENEMY_PRESENT << 2 | ENEMY_PRESENT << 1 | ENEMY_PRESENT << 0
   .byte ENEMY_ABSENT << 7 | ENEMY_PRESENT << 6 | ENEMY_PRESENT << 5 | ENEMY_PRESENT << 4 |ENEMY_ABSENT << 3 | ENEMY_PRESENT << 2 | ENEMY_PRESENT << 1 | ENEMY_PRESENT << 0
   .byte ENEMY_ABSENT << 7 | ENEMY_ABSENT << 6 | ENEMY_PRESENT << 5 | ENEMY_PRESENT << 4 |ENEMY_ABSENT << 3 | ENEMY_PRESENT << 2 | ENEMY_PRESENT << 1 | ENEMY_PRESENT << 0
;
; last three bytes shared with table below
;
LivesIndicatorTable
   .byte ONE_COPY                   ; shared
   .byte ONE_COPY                   ; shared
   .byte ONE_COPY                   ; shared
   .byte TWO_COPIES << 4
   .byte TWO_COPIES << 4   | TWO_COPIES
   .byte THREE_COPIES << 4 | TWO_COPIES
   .byte THREE_COPIES << 4 | THREE_COPIES

NumberOfObjectAnimations
   .byte 2, 2, 2, 2, 5, 2, 5, 15

OddKernelEnemyMaskingValues
   .byte $00,$18,$3C,$7E,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7E,$3C,$18,$00
   .byte $00,$00,$00,$00;,$00,$00,$00,$00,$00
;
; last five bytes shared with table below
;
PlayerDeathColors
   .byte BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK
   .byte BLACK + 2, BLACK + 2, BLACK + 4, BLACK + 4, BLACK + 6, BLACK + 6
   .byte BLACK + 8, BLACK + 8, BLACK + 10, BLACK + 10, BLACK + 12, BLACK + 12
   .byte WHITE, COLOR_PLAYER_DEATH_BLUE, WHITE, WHITE, COLOR_PLAYER_DEATH_BLUE
   .byte WHITE, BLACK + 12, BLACK + 10, BLACK + 8, BLACK + 6, BLACK + 4

EnemyDecendingRate
   .byte $FF,$FF,$0F,$0F,$07,$07,$00,$00

ObjectAnimationTable
   .word HamburgerAnimationTable
   .word CookiesAnimationTable
   .word BugsAnimationTable
   .word RadialTiresAnimationTable
   .word DiamondAnimtationTable
   .word SteamIronsAnimationTable
   .word BowTiesAnimationTable
   .word SpaceDiceAnimationTable

DiamondAnimtationTable
   .byte <Diamonds_0, <Diamonds_1, <Diamonds_2
   .byte <Diamonds_3, <Diamonds_2, <Diamonds_1

Diamonds_0
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $C6 ; |XX...XX.|
   .byte $C6 ; |XX...XX.|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
Diamonds_1
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
Diamonds_2
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
Diamonds_3
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
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
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

CookiesAnimationTable
   .byte <Cookies_0, <Cookies_1, <Cookies_2

Cookies_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $FF ; |XXXXXXXX|
Cookies_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
Cookies_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

HamburgerAnimationTable
   .byte <Hamburgers_0, <Hamburgers_1, <Hamburgers_2

Hamburgers_0
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
Hamburgers_1
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|
Hamburgers_2
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $3C ; |..XXXX..|

SteamIronsAnimationTable
   .byte <SteamIrons_0, <SteamIrons_1, <SteamIrons_2

SteamIrons_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
SteamIrons_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
SteamIrons_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $42 ; |.X....X.|
   .byte $42 ; |.X....X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

BowTiesAnimationTable
   .byte <BowTies_0, <BowTies_1, <BowTies_2, <BowTies_3, <BowTies_2, <BowTies_1

BowTies_0
   .byte $00 ; |........|
   .byte $82 ; |X.....X.|
   .byte $C6 ; |XX...XX.|
   .byte $EE ; |XXX.XXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $EE ; |XXX.XXX.|
   .byte $C6 ; |XX...XX.|
   .byte $82 ; |X.....X.|
BowTies_1
   .byte $00 ; |........|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $44 ; |.X...X..|
   .byte $44 ; |.X...X..|
BowTies_2
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $38 ; |..XXX...|
   .byte $38 ; |..XXX...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
BowTies_3
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|

RadialTiresAnimationTable
   .byte <RadialTires_0, <RadialTires_1, <RadialTires_2

RadialTires_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $FF ; |XXXXXXXX|
   .byte $49 ; |.X..X..X|
   .byte $FF ; |XXXXXXXX|
   .byte $6D ; |.XX.XX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $49 ; |.X..X..X|
   .byte $FF ; |XXXXXXXX|
   .byte $42 ; |.X....X.|
RadialTires_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $FF ; |XXXXXXXX|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $42 ; |.X....X.|
RadialTires_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $FF ; |XXXXXXXX|
   .byte $92 ; |X..X..X.|
   .byte $FF ; |XXXXXXXX|
   .byte $B6 ; |X.XX.XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $92 ; |X..X..X.|
   .byte $FF ; |XXXXXXXX|
   .byte $42 ; |.X....X.|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

SpaceDiceAnimationTable
   .byte <SpaceDice + 15, <SpaceDice + 14, <SpaceDice + 13, <SpaceDice + 12
   .byte <SpaceDice + 11, <SpaceDice + 10, <SpaceDice + 9, <SpaceDice + 8
   .byte <SpaceDice + 7, <SpaceDice + 6, <SpaceDice + 5, <SpaceDice + 4
   .byte <SpaceDice + 3, <SpaceDice + 2, <SpaceDice + 1, <SpaceDice

SpaceDice
   .byte $00 ; |........|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $4F ; |.X..XXXX|
   .byte $4F ; |.X..XXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $73 ; |.XXX..XX|
   .byte $73 ; |.XXX..XX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $4F ; |.X..XXXX|
   .byte $4F ; |.X..XXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $7C ; |.XXXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $3E ; |..XXXXX.|
   .byte $73 ; |.XXX..XX|
   .byte $73 ; |.XXX..XX|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|

NextRandom
   lda randomSeed
   asl
   asl
   asl
   eor randomSeed
   asl
   rol randomSeed
   rts

BugsAnimationTable
   .byte <Bugs_0, <Bugs_1, <Bugs_2

Bugs_0
   .byte $00 ; |........|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
Bugs_1
   .byte $00 ; |........|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
Bugs_2
   .byte $00 ; |........|
   .byte $6C ; |.XX.XX..|
   .byte $6C ; |.XX.XX..|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $36 ; |..XX.XX.|
   .byte $36 ; |..XX.XX.|

InitializeGameVariables
   ldx #11
   lda #>NumberFonts
.setDigitPointerMSB
   sta digitPointer,x               ; set the MSB of the digit pointers
   dex
   dex
   bpl .setDigitPointerMSB
   lda #<Cookies_0                  ; set the attacking object pointer to
   sta attackingObjectPtr           ; point to the Cookies sprite
   lda #>Cookies_0
   sta attackingObjectPtr + 1
   lda #(INIT_ENEMY_HORIZ_MOVE << 4) | INIT_ENEMY_HORIZ_MOVE
   sta enemyHorizMovementPattern
   lda #YMAX
   sta enemyMissile1VertPos
   sta enemyMissile2VertPos
   lda #MAX_ENEMY_SECTIONS
   sta lowestOddEnemySection
   sta gameState
   lda #PLAYER_START_X
   sta playerHorizPos
   lda #INIT_ENEMY_DECENT_RATE
   sta enemyDecentRate
   lda #H_KERNEL
   sta enemyVertPos
   ldx #MAX_ENEMY_SECTIONS - 1
.setInitEnemyPatterns
   lda InitEvenWaveEnemyPatterns,x
   sta currentEnemyPattern,x
   sta reserveEnemyPattern,x
   dex
   bpl .setInitEnemyPatterns
   inx                              ; x = 0
   stx AUDV0                        ; turn off sounds by turning off
   stx AUDV1                        ; volume
   lda #(H_ODD_ENEMY_WAVES * 2) - 2
   sta oddAttackWaveVertPos
   ldx #INIT_NUM_LIVES
   stx player1Lives                 ; set initial number of lives for player 1
   inx                              ; x = 4
   lda gameSelection                ; get the current game selection
   lsr                              ; move D0 to carry
   bcs .setPlayer2InitLives         ; branch if a two player game
   ldx #0                           ; set player 2 lives to 0 for 1 player game
.setPlayer2InitLives
   stx player2Lives
   rts

HMOVEObject
   jsr PositionObjectHorizontally
   sta WSYNC
   sta HMOVE
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
Sleep18Cycles
   asl
Sleep16Cycles
   asl
Sleep14Cycles
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

DeterminePointValue
   ldx #8
   lda waveNumber                   ; get current wave number
   cmp #MEGA_CYCLE
   bcs .readPointValueFromTable
   tax
.readPointValueFromTable
   ldy PointValueTable,x
   lda gameState                    ; get current game state
   lsr
   lsr                              ; shift GS_SCORE_RESERVED_ENERGY to carry
   bcc .setPointValue               ; branch if not scoring for reserved energy
   ldy PointValueTable - 1,x
.setPointValue
   sty points
   rts

PointValueTable
   .byte HAMBURGER_SCORE
   .byte COOKIES_SCORE
   .byte BUGS_SCORE
   .byte TIRES_SCORE
   .byte DIAMONDS_SCORE
   .byte IRON_SCORE
   .byte BOW_TIES_SCORE
   .byte SPACE_DICE_SCORE
   .byte SPACE_DICE_SCORE

ReduceNumberOfLives
   jsr SwitchToOtherPlayer
   ldx currentPlayerNumber          ; get the current player number
   lda remainingLives,x             ; get the number of remaining lives
   bne .reduceLives                 ; reduce lives if not 0
   jsr SwitchToOtherPlayer
.reduceLives
   ldx currentPlayerNumber          ; get the current player number
   dec remainingLives,x             ; decrement number of remaining lives
   rts

CheckForEnemyHorizWrap
   cpx #XMIN - 1                    ; see if the enemy is too far left
   bne .checkForLeftWrapAround
   ldx #XMAX - 1
.checkForLeftWrapAround
   cpx #XMAX
   bcc .setNewWrapXPosition
   ldx #XMIN
.setNewWrapXPosition
   stx enemyHorizPos,y
   rts

SetAttackingObjectPtr
   lda ObjectAnimationTable + 1,y   ; read the MSB for the object animation
   sta objectAnimationPtr + 1
   sta attackingObjectPtr + 1
   ldy animationFrame               ; get the current animation frame
   lda (objectAnimationPtr),y       ; read the LSB of the animation object
   sta attackingObjectPtr
   rts

   .org ROM_BASE + 4096 - 4, 0
   .word Start
   .word Start
