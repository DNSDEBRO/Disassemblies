   LIST OFF
; ***  S E A Q U E S T  ***
; Copyright 1983 Activision, Inc
; Programmer: Steve Cartwright

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: May 18, 2018
;
;  *** 113 BYTES OF RAM USED 15 BYTES FREE
;  ***   4 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1983, ACTIVISION                                   =
; =                                                                            =
; ==============================================================================
;
; - Steve Cartwright's fourth VCS game with Activision
; - Diver is drawn by HMBL values
; - PAL50 version ~17% slower than NTSC
; - 10 bytes of RAM are not used wondering if they were for a removed feature
; - ROM contains table values that are not used

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
; F R A M E  T I M I N G S
;===============================================================================

   IF COMPILE_REGION = NTSC || COMPILE_REGION = PAL60

VBLANK_TIME             = 48
OVERSCAN_TIME           = 31

   ELSE
   
VBLANK_TIME             = 85
OVERSCAN_TIME           = 54

   ENDIF

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0E

   IF COMPILE_REGION = NTSC

YELLOW                  = $10
RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
PURPLE                  = $50
COBALT_BLUE             = $60
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
LT_BLUE                 = $90
CYAN                    = $A0
OLIVE_GREEN             = $B0
GREEN                   = $C0
DK_GREEN                = $D0
LT_BROWN                = $E0

COLOR_SKY               = ULTRAMARINE_BLUE + 4
COLOR_SEAWEED_00        = GREEN
COLOR_SEAWEED_01        = OLIVE_GREEN
COLOR_SEAWEED_02        = CYAN
COLOR_RETRIEVED_DIVERS  = BLUE + 2
COLOR_PLAYER1_SCORE     = YELLOW + 10
COLOR_PLAYER2_SCORE     = CYAN + 15
COLOR_SEA               = LT_BLUE
COLOR_PLAYER1           = YELLOW + 8
COLOR_PLAYER2           = CYAN + 10

COLOR_KILLER_SHARK_00   = GREEN + 8
COLOR_KILLER_SHARK_01   = LT_BROWN + 8
COLOR_KILLER_SHARK_02   = PURPLE + 8
COLOR_KILLER_SHARK_03   = BRICK_RED + 6
COLOR_KILLER_SHARK_04   = GREEN + 6
COLOR_KILLER_SHARK_05   = LT_BROWN + 8
COLOR_KILLER_SHARK_06   = GREEN + 8
COLOR_KILLER_SHARK_07   = BRICK_RED + 6
COLOR_KILLER_SHARK_08   = LT_BLUE

   ELSE

YELLOW                  = $20
RED_ORANGE              = $20
GREEN                   = $30
BRICK_RED               = $40
DK_GREEN                = $50
RED                     = $60
PURPLE_2                = $70
PURPLE                  = $80
CYAN                    = $90
COBALT_BLUE             = $A0
BLUE                    = $B0
OLIVE_GREEN             = $B0
LT_BLUE                 = $B0
BLUE_2                  = $D0

COLOR_SKY               = BLUE + 4
COLOR_SEAWEED_00        = DK_GREEN
COLOR_SEAWEED_01        = PURPLE_2
COLOR_SEAWEED_02        = CYAN
COLOR_RETRIEVED_DIVERS  = BLUE + 2
COLOR_PLAYER1_SCORE     = YELLOW + 10
COLOR_PLAYER2_SCORE     = BLUE + 15
COLOR_SEA               = BLUE
COLOR_PLAYER1           = YELLOW + 8
COLOR_PLAYER2           = BLUE + 10

COLOR_KILLER_SHARK_00   = GREEN + 8
COLOR_KILLER_SHARK_01   = YELLOW + 8
COLOR_KILLER_SHARK_02   = RED + 8
COLOR_KILLER_SHARK_03   = BRICK_RED + 6
COLOR_KILLER_SHARK_04   = DK_GREEN + 6
COLOR_KILLER_SHARK_05   = YELLOW + 8
COLOR_KILLER_SHARK_06   = GREEN + 8
COLOR_KILLER_SHARK_07   = BRICK_RED + 6
COLOR_KILLER_SHARK_08   = LT_BLUE

   ENDIF

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_FONT                  = 8
H_OXYGEN_FONT           = 5
H_RESERVE_SUBS          = 9
H_RETRIEVED_DIVERS      = 9
H_SEAQUEST_SUB          = 14
H_COPYRIGHT             = 8

SELECT_DELAY            = 30

MAX_RESERVED_SUBS       = 6
MAX_RETRIEVED_DIVERS    = 6

XMIN                    = 0
XMAX                    = 160

SEAQUEST_YMIN           = 13
SEAQUEST_YMAX           = 108
SEAQUEST_XMIN           = XMIN + 21
SEAQUEST_XMAX           = XMAX - 26

INIT_SEAQUEST_HORIZ     = 76
INIT_SEAQUEST_VERT      = SEAQUEST_YMIN

; Obstacle Attribute Values
OBSTACLE_TYPE_MASK      = %00000100
OBSTACLE_HORIZ_DIR_MASK = %00001000
OBSTACLE_SPEED_MASK     = %00010000

MAX_OXYGEN_VALUE        = 64

MAX_SEAQUEST_SUB_DEATH_TIME = 23

; game state values
GS_REWARD_FOR_OXYGEN    = %10
GS_INCREMENT_OXYGEN     = %01

;===============================================================================
; M A C R O S
;===============================================================================

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
frameCount              ds 1
randomSeed              ds 1
selectDebounce          ds 1
currentJoystickValues   ds 1
colorEOR                ds 1
colorBWMask             ds 1
gameColors              ds 11
playerScoreColors       = gameColors
;--------------------------------------
player1ScoreColor       = playerScoreColors
player2ScoreColor       = player1ScoreColor + 1
seaColor                = gameColors + 2
playerColors            = seaColor + 1
;--------------------------------------
player1Color            = playerColors
player2Color            = player1Color + 1
skyColor                = player2Color + 1
copyrightBackgroundColor = skyColor + 1
;--------------------------------------
oxygenLiteralColor      = copyrightBackgroundColor
oxygenBarColor          = oxygenLiteralColor + 1
seaFloorColor           = oxygenBarColor + 1
oxygenBackgroundColor   = seaFloorColor + 1
copyrightColor          = oxygenBackgroundColor + 1
digitPointers           ds 12
;--------------------------------------
obstacleGraphicPtrs     = digitPointers
;--------------------------------------
obstacleSpeedValues     = obstacleGraphicPtrs
;--------------------------------------
tmpDiverSpeed           = obstacleSpeedValues
tmpObstacleSpeed        = tmpDiverSpeed + 1
tmpEnemySubTorpedoSpeed = tmpObstacleSpeed + 1
;--------------------------------------
diverEnemyMissileHMOVEPtr = digitPointers + 2
diverEnemyMissileEnablePtr = diverEnemyMissileHMOVEPtr + 2
seaquestSubGraphicPtrs  = diverEnemyMissileEnablePtr + 2
obstacleHorizPos        ds 4
colorCycleMode          ds 1
copyrightScrollRate     ds 1
obstaclePatternIndex    ds 4
obstacleNUSIZIndexes    ds 4
obstacleColors          ds 4
collisionValues         ds 7
;--------------------------------------
seaquestTorpedoCollisionValue = collisionValues + 4
seaquestObstacleCollisionValue = collisionValues + 5
seaquestBallCollisionValue = collisionValues + 6
currentPlayerNumber     ds 1
currentPlayerVariables  ds 7
;--------------------------------------
playerScore             = currentPlayerVariables
reserveSubs             = playerScore + 3
currentLevel            = reserveSubs + 1
levelDifficulty         = currentLevel + 1
retrievedDivers         = levelDifficulty + 1
reservePlayerVariables  ds 7
;--------------------------------------
reservePlayerScore      = reservePlayerVariables
reservePlayerSubs       = reservePlayerScore + 3
seaquestSubHorizPos     ds 1
enemySubTorpedoOrDiverHorizPos ds 4
;--------------------------------------
diverHorizPos           = enemySubTorpedoOrDiverHorizPos
enemySubTorpedoHorizPos = diverHorizPos
seaquestSubHMOVEValue   ds 1
obstacleHMOVEValues     ds 1
enemyTorpedoOrDiverHMOVEValues ds 1
currentPointValue       ds 1
fractionalPositionValues ds 3

zp_Unused_01            ds 4

seaquestSubHorizDir     ds 1
seaquestTorpedoHorizDir ds 1

zp_Unused_02            ds 1

obstacleAttributes      ds 4
killerSharkFloatingValue ds 1
obstacleAnimationIdx    ds 1

zp_Unused_03            ds 1

seaquestSubAnimationIdx ds 1
seaquestSubVertPos      ds 1
tmpSixDigitLoopCount    ds 1
;--------------------------------------
tmpSeaquestGraphicIdx   = tmpSixDigitLoopCount
;--------------------------------------
tmpCopyrightCharHolder  = tmpSeaquestGraphicIdx
;--------------------------------------
tmpEnemySubTorpedoHorizPos = tmpCopyrightCharHolder
;--------------------------------------
tmpTorpedoHorizPos      = tmpEnemySubTorpedoHorizPos
;--------------------------------------
tmpObstacleAttributeValue = tmpTorpedoHorizPos
;--------------------------------------
tmpDifficultySettings   = tmpObstacleAttributeValue
;--------------------------------------
tmpSeaquestSubCoarseValue = tmpDifficultySettings
;--------------------------------------
tmpObstacleSpeedUp      = tmpSeaquestSubCoarseValue
;--------------------------------------
tmpSpeedValues          = tmpObstacleSpeedUp
;--------------------------------------
tmpDiverSpeedValue      = tmpSpeedValues
;--------------------------------------
tmpOxygenBarColor       = tmpDiverSpeedValue
;--------------------------------------
tmpKillerSharkAnimIndex = tmpOxygenBarColor
;--------------------------------------
tmpSpawnObstacleDir     = tmpKillerSharkAnimIndex
;--------------------------------------
tmpEnemySubTorpedoOffset = tmpSpawnObstacleDir
tmpCharHolder           ds 1
;--------------------------------------
tmpObstacleGraphicIdx   = tmpCharHolder
;--------------------------------------
tmpCopyrightLoopCount   = tmpObstacleGraphicIdx
;--------------------------------------
tmpSeaSurfaceColorMod   = tmpCopyrightLoopCount
;--------------------------------------
tmpObstacleSpeedValue   = tmpSeaSurfaceColorMod
tmpSeaSurfaceColor      ds 1
;--------------------------------------
tmpCopyrightLinePtr     = tmpSeaSurfaceColor
;--------------------------------------
tmpSeaFloorColor        = tmpCopyrightLinePtr
tmpEnemySubTorpedoSpeedValue = tmpCopyrightLinePtr
kernelSection           ds 1
oxygenValue             ds 1
torpedoHorizPos         ds 1
gameState               ds 1
seaquestSubDeathAnimIdx ds 1
pickupDiverSoundValue   ds 1
shootingKillerSharkSoundValue ds 1
shootingEnemySubSoundValue ds 1
seaquestTorpedoSoundValues ds 1
;--------------------------------------
rewardSoundValues       = seaquestTorpedoSoundValues

zp_Unused_04            ds 3

diverArray              ds 4

zp_Unused_05            ds 1

enemyPatrolSubHorizPos  ds 1
enemyPatrolSubHMOVEValue ds 1
subCollisionValue       ds 1
oxygenWarningIndicator  ds 1
movementSpeedValue      ds 1

   echo "***",(* - $80 - 10)d, "BYTES OF RAM USED", ($100 - * + 10)d, "BYTES FREE"
   
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
   ldx #$FF
   txs                              ; set stack to the beginning
   inx                              ; x = 0
   jsr ResetVariables
   inc randomSeed
   jmp CheckToExecuteGameProcessing
       
MainLoop
   ldx #<[HMM0 - HMP0]
   ldy torpedoHorizPos              ; get Seaquest torpedo horizontal position
   lda KernelHorizPositionValueTable + 1,y;get HMOVE value for position
   jsr PositionTorpedoesHoriz
   ldx #<[copyrightColor - gameColors]
.setGameColors
   lda GameColorTable,x
   eor colorEOR                     ; flip color bits for attract mode
   and colorBWMask                  ; mask color values for COLOR / B&W mode
   sta gameColors,x
   dex
   bpl .setGameColors
   ldx seaquestSubHorizPos          ; get Sequest sub horizontal position
   lda KernelHorizPositionValueTable - 1,x;get HMOVE value for position
   sta seaquestSubHMOVEValue        ; set Seaquest sub HMOVE value
   ldx enemyPatrolSubHorizPos       ; get Enemy Patrol Sub horizontal position
   cpx #XMAX
   bcc .setEnemyPatrolSubHMOVEValue ; branch if less than XMAX
   ldx #XMIN
.setEnemyPatrolSubHMOVEValue
   lda KernelHorizPositionValueTable,x;get HMOVE value for position
   sta enemyPatrolSubHMOVEValue     ; set Enemy Patrol Sub HMOVE value
   ldx #3
.determineObstacleNUSIZValues
   ldy #8
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   cmp #128
   bcc .setObstacleNUSIZValues
   sbc #128
   jsr Div16
   tay
.setObstacleNUSIZValues
   lda obstaclePatternIndex,x
   and ObstacleNUSIZIndexMaskingValues,y
   sta obstacleNUSIZIndexes,x
   dex
   bpl .determineObstacleNUSIZValues
   ldy #2
.bcd2DigitLoop
   tya                              ; move y to accumulator
   asl                              ; multiply the value by 4 so it can
   asl                              ; be used for the digitPointers indexes
   tax
   lda playerScore,y                ; get the player's score
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide the value by 2
   sta digitPointers,x              ; set LSB pointer to digit
   lda playerScore,y                ; get the player's score
   and #$0F                         ; mask the upper nybble
   asl                              ; muliply the value by 8
   asl
   asl
   sta digitPointers + 2,x          ; set LSB pointer to digit
   dey
   bpl .bcd2DigitLoop
   iny                              ; y = 0
.suppressZeroLoop
   lda digitPointers,y              ; get digit value
   bne .setDigitPointerMSBValues    ; no need to suppress if zero
   lda #<Blank
   sta digitPointers,y              ; place a Black in digit value
   iny
   iny
   cpy #10
   bne .suppressZeroLoop
.setDigitPointerMSBValues
   jsr SetDigitPointersMSBValues
   lda skyColor
   sta COLUBK
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scan line
   sta HMOVE
   sta VBLANK                       ; enable TIA (D1 = 0)
   ldx currentPlayerNumber          ; get the current player number
   lda playerScoreColors,x
   sta COLUP0
   sta COLUP1
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   jsr Waste18Cycles          ; 18
   ldy #H_FONT - 1            ; 2
   sty VDELP0                 ; 3 = @26
   sty VDELP1                 ; 3 = @29
   sta HMCLR                  ; 3 = @32
.drawSixDigitDisplay
   sty tmpSixDigitLoopCount   ; 3
   lda (digitPointers + 10),y ; 5
   sta tmpCharHolder          ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (digitPointers),y      ; 5
   sta GRP0                   ; 3 = @11
   lda (digitPointers + 2),y  ; 5
   sta GRP1                   ; 3 = @19
   lda (digitPointers + 4),y  ; 5
   sta GRP0                   ; 3 = @27
   lda (digitPointers + 8),y  ; 5
   tax                        ; 2
   lda (digitPointers + 6),y  ; 5
   ldy tmpCharHolder          ; 3
   sta GRP1                   ; 3 = @45
   stx GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sta GRP0                   ; 3 = @54
   ldy tmpSixDigitLoopCount   ; 3
   dey                        ; 2
   bpl .drawSixDigitDisplay   ; 2³
   iny                        ; 2         y = 0
   ldx #4                     ; 2         skip 5 scanlines after score
.skipScanlinesAfterScoreDisplay
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sty VDELP0                 ; 3 = @06
   sty VDELP1                 ; 3 = @09
   sty GRP0                   ; 3 = @12
   sty GRP1                   ; 3 = @15
   dex                        ; 2
   bpl .skipScanlinesAfterScoreDisplay;2³
   ldy reserveSubs            ; 3         get number of reserve submarines
   lda IndicatorNUSIZValueTable,y;4
   sta NUSIZ1                 ; 3 = @29
   jsr ShiftUpperNybblesToLower;20
   sta NUSIZ0                 ; 3 = @52
   ldx #H_RESERVE_SUBS - 1    ; 2
.drawReservedSubs
   lda ReserveSubGraphic,x    ; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   cpy #0                     ; 2
   beq .drawRemainingReservedSubs;2³ + 1  branch if no reserve subs left
   sta GRP0                   ; 3 = @10
.drawRemainingReservedSubs
   cpy #2                     ; 2
   bcc .nextReservedSubLine   ; 2³
   sta GRP1                   ; 3 = @17
.nextReservedSubLine
   dex                        ; 2
   bpl .drawReservedSubs      ; 2³ + 1    crosses page boundary
   lda seaquestSubHMOVEValue  ; 3
   and #$0F                   ; 2         keep coarse movement value
   sta tmpSeaquestSubCoarseValue;3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda enemyPatrolSubHMOVEValue;3
   and #$0F                   ; 2         keep coarse movement value
   tax                        ; 2
   bne .coarsePositionEnemyPatrolSub;2³
   lda #HMOVE_L6              ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @25
   sta HMP1                   ; 3 = @28
   bne .positionSeaquestSub   ; 3         unconditional branch
   
.coarsePositionEnemyPatrolSub
   dex                        ; 2
   bne .coarsePositionEnemyPatrolSub;2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3
.positionSeaquestSub
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda enemyPatrolSubHMOVEValue;3
   ldx seaquestSubHMOVEValue  ; 3
   ldy tmpSeaquestSubCoarseValue;3        get Seaquest coarse position value
   sty tmpSeaquestSubCoarseValue;3        waste 3 cycles
.coarsePositionSeaquestSub
   dey                        ; 2
   bpl .coarsePositionSeaquestSub;2³
   sta.w RESP0                ; 4
   stx HMP0                   ; 3
   sta HMP1                   ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #COLOR_SKY             ; 2
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUBK                 ; 3 = @14
   ldx seaquestSubAnimationIdx; 3
   lda SeaquestSubGraphicLSBValues,x;4
   sta seaquestSubGraphicPtrs ; 3
   lda #>SeaquestSubGraphics  ; 2
   sta seaquestSubGraphicPtrs + 1;3
   sta obstacleGraphicPtrs + 1; 3
   lda #>DiverEnemyMissileAnimationTables;2
   sta diverEnemyMissileHMOVEPtr + 1;3
   sta diverEnemyMissileEnablePtr + 1;3
   sta HMCLR                  ; 3 = @43
   lda seaquestSubHorizDir    ; 3         get direction Seaquest sub is facing
   sta REFP0                  ; 3 = @49   set reflective state
   ldx currentPlayerNumber    ; 3         get the current player number
   lda playerColors,x         ; 4
   sta COLUP0                 ; 3
   lda #MSBL_SIZE8 | DOUBLE_SIZE;2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta NUSIZ0                 ; 3 = @06   set torpedo and submarine sizes
   ldy seaquestSubVertPos     ; 3         get Seaquest Sub vertical position
   ldx seaquestSubDeathAnimIdx; 3         get death animation value
   beq .setEnemyPatrolSubValues;2³
   lda SeaquestSubDeathColorValues - 1,x;4
   sta COLUP0                 ; 3         set Seaquest Sub death color
   cpx #15                    ; 2
   bcs .setEnemyPatrolSubValues;2³
   cpx #10                    ; 2
   bcs .setSeaquestSubDeathGraphicValue;2³
   ldx #10                    ; 2
.setSeaquestSubDeathGraphicValue
   lda SeaquestSubDeathGraphicValues - 10,x;4
   sta seaquestSubGraphicPtrs ; 3         set graphic pointer for explosion
.setEnemyPatrolSubValues
   ldx #BLACK + 9             ; 2
   stx REFP1                  ; 3 = @37   refect Enemy Patrol Sub
   stx COLUP1                 ; 3 = @40   color Enemy Patrol Sub
   stx CXCLR                  ; 3 = @43   clear all collisions
   ldx #9                     ; 2
.colorHorizon
   lda HorizonColors,x        ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   dex                        ; 2
   bpl .colorHorizon          ; 2³
   inx                        ; 2         x = 0
   stx NUSIZ1                 ; 3 = @15   set to ONE_COPY
   lda randomSeed             ; 3         get current random number
   sta tmpSeaSurfaceColorMod  ; 3
   ldx seaquestSubAnimationIdx; 3         get Seaquest Sub animation index
   lda SeaquestSubGraphicLSBValues,x;4    get Seaquest Sub graphic LSB value
   adc #2                     ; 2         increment value for sea surface
   sta obstacleGraphicPtrs    ; 3
   ldx #9                     ; 2
.drawSeaSurfaceKernel
   dey                        ; 2
   sty tmpSeaquestGraphicIdx  ; 3
   lda tmpSeaSurfaceColorMod  ; 3         get sea surface color modulator value
   cmp #128                   ; 2         set carry when greater than 127
   rol                        ; 2         shift carry to D0
   sta tmpSeaSurfaceColorMod  ; 3
   and #2                     ; 2         keep D1
   eor seaColor               ; 3         flip D1 for sea surface color cycles
   sta tmpSeaSurfaceColor     ; 3
   cpx #2                     ; 2
   bcc .skipSeaSurfaceSeaquestDraw;2³
   txa                        ; 2
   tay                        ; 2
   lda tmpSeaSurfaceColor     ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda (obstacleGraphicPtrs),y; 5
   sta GRP1                   ; 3 = @14
   ldy tmpSeaquestGraphicIdx  ; 3
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .nextSeaSurfaceScanline; 2³
   lda (seaquestSubGraphicPtrs),y;5
.drawSeaSurfaceSeaquestSub
   sta GRP0                   ; 3
.nextSeaSurfaceScanline
   dex                        ; 2
   bpl .drawSeaSurfaceKernel  ; 2³
   bmi .doneDrawSeaSurfaceKernel;3        unconditional branch
       
.skipSeaSurfaceSeaquestDraw
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda #0                     ; 2
   sta GRP1                   ; 3 = @11
   beq .drawSeaSurfaceSeaquestSub;3       unconditional branch
       
.doneDrawSeaSurfaceKernel
   dey                        ; 2
   lda copyrightBackgroundColor;3
   dey                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   lda #<-1                   ; 2
   ldx #6                     ; 2
.resetKernelCollectionValues
   sta collisionValues,x      ; 4
   dex                        ; 2
   bpl .resetKernelCollectionValues;2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda seaColor               ; 3
   sta COLUBK                 ; 3 = @09
   ldx #3                     ; 2
   lda CXPPMM                 ; 3         read player collision values
   sta subCollisionValue      ; 3         set Enemy Patrol Sub collision value
KernelLoop
   stx kernelSection          ; 3
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .prepareToPositionObstacle;2³
   lda (seaquestSubGraphicPtrs),y;5
   sta GRP0                   ; 3 = @13
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @20
.prepareToPositionObstacle
   sty tmpSeaquestGraphicIdx  ; 3
   lda obstacleNUSIZIndexes,x ; 4
   beq .setObstacleHMOVEValues; 2³
   tay                        ; 2
   lda ObstacleHorizOffsetTable,y;4
   clc                        ; 2
   adc obstacleHorizPos,x     ; 4
   cmp #XMAX                  ; 2
   bcc .setObstacleHMOVEValues; 2³        branch if less than XMAX
   sbc #(XMAX / 2) + 16       ; 2
.setObstacleHMOVEValues
   tax                        ; 2
   lda KernelHorizPositionValueTable,x;4  get HMOVE value for position
   sta obstacleHMOVEValues    ; 3         set obstacle HMOVE value
   ldy tmpSeaquestGraphicIdx  ; 3
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .setupThirdKernelLoopScanline;2³
   lda (seaquestSubGraphicPtrs),y;5
   sta GRP0                   ; 3 = @13
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @20
.setupThirdKernelLoopScanline
   lda #0                     ; 2
   tax                        ; 2
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .thirdKernelLoopScanline;2³
   lda (seaquestSubGraphicPtrs),y;5
   ldx TorpedoEnablingValues,y; 4
.thirdKernelLoopScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   stx ENAM0                  ; 3 = @09   disable missile (i.e. x = 0)
   lda obstacleHMOVEValues    ; 3         get obstacle HMOVE value
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   bne .coarsePositionObstacle; 2²
   lda #HMOVE_L6              ; 2
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @25
   sta HMP1                   ; 3 = @28
   bne .fourthKernelLoopScanline;3         unconditional branch
       
.coarsePositionObstacle
   dex                        ; 2
   bne .coarsePositionObstacle; 2³
   SLEEP 2                    ; 2
   sta RESP1                  ; 3
.fourthKernelLoopScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .prepareToPositionBallObject;2³
   lda (seaquestSubGraphicPtrs),y;5
   sta GRP0                   ; 3 = @17
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @24
.prepareToPositionBallObject
   ldx kernelSection          ; 3
   lda enemySubTorpedoOrDiverHorizPos,x;4 get horizontal position
   cmp #XMAX                  ; 2
   bcc .setBallHMOVEValues    ; 2³
   lda #XMIN                  ; 2
.setBallHMOVEValues
   tax                        ; 2
   lda KernelHorizPositionValueTable + 3,x;4 get HMOVE value for position
   sta enemyTorpedoOrDiverHMOVEValues;3   set BALL HMOVE value
   sta HMCLR                  ; 3
   lda #0                     ; 2
   tax                        ; 2
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .fifthKernelLoopScanline;2³
   lda (seaquestSubGraphicPtrs),y;5
   ldx TorpedoEnablingValues,y; 4
.fifthKernelLoopScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   stx ENAM0                  ; 3 = @09
   lda enemyTorpedoOrDiverHMOVEValues;3
   and #$0F                   ; 2         keep coarse movement value
   tax                        ; 2
   bne .coarsePositionBall    ; 2³
   lda #HMOVE_L6              ; 2
   SLEEP 2                    ; 2
   sta RESBL                  ; 3
   sta HMBL                   ; 3
   bne .sixthKernelLoopScanline;2³
       
.coarsePositionBall
   dex                        ; 2
   bne .coarsePositionBall    ; 2³
   SLEEP 2                    ; 2
   sta RESBL                  ; 3
.sixthKernelLoopScanline
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .setObstacleNUSIZForKernel;2³
   lda (seaquestSubGraphicPtrs),y;5
   sta GRP0                   ; 3 = @17
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @24
.setObstacleNUSIZForKernel
   ldx kernelSection          ; 3
   lda obstacleNUSIZIndexes,x ; 4
   tax                        ; 2
   lda PlayerNUSIZValueTable,x; 4
   sta NUSIZ1                 ; 3 = @40
   lda obstacleHMOVEValues    ; 3
   sta HMP1                   ; 3 = @46
   lda enemyTorpedoOrDiverHMOVEValues;3
   sta HMBL                   ; 3 = @52
   ldx kernelSection          ; 3
   lda obstacleAttributes,x   ; 4         get obstacle attribute value
   sta REFP1                  ; 3 = @62
   and #7                     ; 2
   tax                        ; 2
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .setupForObstacleGraphicPointers;2³
   lda (seaquestSubGraphicPtrs),y;5
   sta GRP0                   ; 3 = @13
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @20
.setupForObstacleGraphicPointers
   lda ObstacleGraphicLSBValues,x;4
   cpx #4                     ; 2
   bcs .setObstacleGraphicLSBValue;2³     branch if obstacle is an Enemy Sub
   adc killerSharkFloatingValue;3         increment to show Shark floating
.setObstacleGraphicLSBValue
   sta obstacleGraphicPtrs    ; 3
   sta CXCLR                  ; 3
   ldx kernelSection          ; 3
   lda #VERTICAL_DELAY        ; 2
   sta VDELP1                 ; 3
   lda obstacleColors,x       ; 4
   sta COLUP1                 ; 3
   sta HMCLR                  ; 3
   lda obstacleAttributes,x   ; 4         get obstacle attribute value
   and #$0F                   ; 2
   tax                        ; 2
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   lda (seaquestSubGraphicPtrs),y;5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcs .setBallGraphicPointerValues;2³
   sta GRP0                   ; 3 = @08
   lda TorpedoEnablingValues,y; 4
   sta ENAM0                  ; 3 = @15
.setBallGraphicPointerValues
   lda DiverEnemyMissileHMOVEValues,x;4
   sta diverEnemyMissileHMOVEPtr;3
   lda EnableDiverEnemyMissileValues,x;4
   sta diverEnemyMissileEnablePtr;3
   ldx #14                    ; 2
.kernelSectionLoop
   dey                        ; 2
   stx tmpObstacleGraphicIdx  ; 3
   sty tmpSeaquestGraphicIdx  ; 3
   ldy tmpObstacleGraphicIdx  ; 3
   lda (obstacleGraphicPtrs),y; 5
   sta GRP1                   ; 3
   lda (diverEnemyMissileHMOVEPtr),y;5
   sta HMBL                   ; 3
   lda (diverEnemyMissileEnablePtr),y;5
   ldy tmpSeaquestGraphicIdx  ; 3
   cpy #H_SEAQUEST_SUB - 2    ; 2
   ldx TorpedoEnablingValues,y; 4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta ENABL                  ; 3 = @06
   sta CTRLPF                 ; 3 = @09
   bcs .skipSeaquestDraw      ; 2³
   stx ENAM0                  ; 3 = @14
   lda (seaquestSubGraphicPtrs),y;5
.nextKernelSectionScanline
   sta GRP0                   ; 3
   ldx tmpObstacleGraphicIdx  ; 3
   dex                        ; 2
   bpl .kernelSectionLoop     ; 2³
   bmi .doneKernelSectionLoop ; 3         unconditional branch
       
.skipSeaquestDraw
   lda #0                     ; 2
   bcs .nextKernelSectionScanline;3       unconditional branch
       
.doneKernelSectionLoop
   inx                        ; 2         x = 0
   txa                        ; 2
   sta VDELP1                 ; 3
   dey                        ; 2
   cpy #H_SEAQUEST_SUB - 2    ; 2
   bcs .setKernelCollisionValues;2³
   lda (seaquestSubGraphicPtrs),y;5
   ldx TorpedoEnablingValues,y; 4
.setKernelCollisionValues
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   stx ENAM0                  ; 3 = @09
   ldx kernelSection          ; 3
   txa                        ; 2
   bit CXP0FB                 ; 3
   bvc .checkSeaquestSubTorpedoCollision;2³ branch if not hit by enemy torpedo
   stx seaquestBallCollisionValue;3       set value to any non-negative number
.checkSeaquestSubTorpedoCollision
   bit CXM0P                  ; 3
   bpl .checkForBallCollision ; 2³        branch if didn't shot obstacle
   stx seaquestTorpedoCollisionValue;3    set section for torpedo collision
.checkForBallCollision
   bit CXP1FB                 ; 3
   bvc .checkSeaquestSubObstacleCollision;2³
   sta collisionValues,x      ; 4         store kernel section for collision
.checkSeaquestSubObstacleCollision
   bit CXPPMM                 ; 3         check player collision values
   bpl .nextKernelLoop        ; 2³
   stx seaquestObstacleCollisionValue;3   store kernel section for collision
.nextKernelLoop
   dex                        ; 2
   bmi SeaFloorKernel         ; 2³
   jmp KernelLoop             ; 3
       
SeaWeedColorValues
   .byte COLOR_SEAWEED_00, COLOR_SEAWEED_00, COLOR_SEAWEED_00, COLOR_SEAWEED_00
   .byte COLOR_SEAWEED_01, COLOR_SEAWEED_01, COLOR_SEAWEED_02, COLOR_SEAWEED_02
   
SeaFloorKernel
   ldx #7                     ; 2
.colorSeaWeedSection
   lda SeaWeedColorValues,x   ; 4
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   dex                        ; 2
   bpl .colorSeaWeedSection   ; 2³
   lda seaFloorColor          ; 3
   sta COLUPF                 ; 3 = @16
   ldy #4                     ; 2
   lda #PF_REFLECT            ; 2
   sta CTRLPF                 ; 3 = @23
.drawSeaFloorReef
   lda SeaFloorReefGraphics - 1,y;4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta PF0                    ; 3 = @06
   sta PF1                    ; 3 = @09
   sta PF2                    ; 3 = @12
   dey                        ; 2
   bne .drawSeaFloorReef      ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx PF0                    ; 3 = @06   x = #$FF
   stx PF1                    ; 3 = @09
   stx PF2                    ; 3 = @12
   sty GRP0                   ; 3 = @15   y = 0
   sty GRP1                   ; 3 = @18
   lda #MSBL_SIZE4 | PF_REFLECT;2
   sta CTRLPF                 ; 3
   sta RESP0                  ; 3 = @26
   sta RESP1                  ; 3 = @29
   sta HMCLR                  ; 3 = @32
   sty NUSIZ1                 ; 3 = @35   set to ONE_COPY
   iny                        ; 2         y = 1
   sty NUSIZ0                 ; 3 = @40   set to TWO_COPIES
   lda oxygenValue            ; 3         get oxygen value
   beq .determineOxygenHMOVEValues;2³
   clc                        ; 2
   adc #46                    ; 2
.determineOxygenHMOVEValues
   tay                        ; 2
   lda KernelHorizPositionValueTable,y;4
   tay                        ; 2
   and #$0F                   ; 2
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda oxygenLiteralColor     ; 3
   sta COLUP0                 ; 3 = @09
   sta COLUP1                 ; 3 = @12
   lda #HMOVE_L1              ; 2
   SLEEP 2                    ; 2
.coarsePositionOxygenBar
   dex                        ; 2
   bpl .coarsePositionOxygenBar;2³
   sta RESBL                  ; 3
   sta HMP1                   ; 3
   sty HMBL                   ; 3
   lda seaFloorColor          ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUPF                 ; 3 = @06
   sta tmpSeaFloorColor       ; 3
   jsr Waste18Cycles          ; 18
   sta HMCLR                  ; 3 = @30
   inx                        ; 2         x = 0
   stx REFP0                  ; 3 = @35
   stx REFP1                  ; 3 = @38
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda oxygenBackgroundColor  ; 3
   sta COLUBK                 ; 3 = @09
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #0                     ; 2
   ldx oxygenBarColor         ; 3         get oxygen bar color value
   lda seaquestSubVertPos     ; 3         get Seaquest Sub vertical position
   cmp #SEAQUEST_YMIN         ; 2
   beq .setKernelOxygenBarColor;2³        branch if Seaquest Sub at top
   lda oxygenValue            ; 3         get current oxygen value
   beq .setKernelOxygenBarColor;2³        branch if no oxygen left
   lda seaquestSubDeathAnimIdx; 3
   bne .setKernelOxygenBarColor;2³
   lda #16                    ; 2
   cmp oxygenValue            ; 3
   bcc .setKernelOxygenBarColor;2³
   ldy #15                    ; 2
   and frameCount             ; 3
   bne .setKernelOxygenBarColor;2³
   ldx oxygenLiteralColor     ; 3         get oxygen literal color
.setKernelOxygenBarColor
   stx tmpOxygenBarColor      ; 3
   sty oxygenWarningIndicator ; 3
   lda oxygenValue            ; 3         get current oxygen value
   lsr                        ; 2         divide value by 4 for graphic index
   lsr                        ; 2
   tay                        ; 2
   lda #ENABLE_BM             ; 2
   ldx #H_OXYGEN_FONT - 1     ; 2
   sta ENABL                  ; 3
.drawOxygenKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda OxygenLiteral_00,x     ; 4
   sta GRP0                   ; 3 = @10
   lda OxygenLiteral_01,x     ; 4
   sta GRP1                   ; 3 = @17
   lda LeftPF2OxygenBarGraphics,y;4
   sta PF2                    ; 3 = @24
   lda OxygenLiteral_02,x     ; 4
   sta.w GRP0                 ; 4 = @32
   lda tmpOxygenBarColor      ; 3
   sta.w COLUPF               ; 4 = @39
   lda RightPF2OxygenBarGraphics,y;4
   SLEEP 2                    ; 2
   sta PF2                    ; 3 = @48
   lda tmpSeaFloorColor       ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   sta COLUPF                 ; 3 = @60
   dex                        ; 2
   bpl .drawOxygenKernel      ; 2³
   ldy retrievedDivers        ; 3         get number of retrieved divers
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta COLUBK                 ; 3 = @06
   inx                        ; 2         x = 0
   stx GRP0                   ; 3 = @11
   stx GRP1                   ; 3 = @14
   stx PF0                    ; 3 = @17
   stx PF1                    ; 3 = @20
   stx PF2                    ; 3 = @23
   stx ENABL                  ; 3 = @26
   lda IndicatorNUSIZValueTable,y;4
   sta NUSIZ1                 ; 3 = @33
   jsr ShiftUpperNybblesToLower;20
   sta NUSIZ0                 ; 3 = @56
   lda tmpSeaFloorColor       ; 3         waste 3 cycles...not needed
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   jsr Waste18Cycles          ; 18
   jsr Waste16Cycles          ; 16
   sta RESP0                  ; 3 = @40
   sta RESP1                  ; 3 = @43
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @48
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldx #COLOR_RETRIEVED_DIVERS; 2
   lda retrievedDivers        ; 3         get number of retrieved divers
   cmp #MAX_RETRIEVED_DIVERS  ; 2
   bne .colorRetrievedDivers  ; 2³
   lda seaquestSubVertPos     ; 3
   cmp #SEAQUEST_YMIN         ; 2
   beq .colorRetrievedDivers  ; 2³
   lda frameCount             ; 3
   and #8                     ; 2
   bne .colorRetrievedDivers  ; 2³
   ldx #BLACK + 6             ; 2
.colorRetrievedDivers
   txa                        ; 2
   eor colorEOR               ; 3
   and colorBWMask            ; 3
   sta COLUP0                 ; 3 = @39
   sta COLUP1                 ; 3 = @42
   sta HMCLR                  ; 3 = @45
   ldx #H_RETRIEVED_DIVERS    ; 2
.drawRetrievedDiversKernel
   lda RetrievedDiverGraphics - 1,x ;4
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   sta GRP1                   ; 3 = @09
   lda #0                     ; 2
   cpy #2                     ; 2
   bcs .checkForNoDiversLeft  ; 2³
   sta GRP1                   ; 3 = @18   clear GRP1 if retrieved divers < 2
.checkForNoDiversLeft
   cpy #0                     ; 2
   bne .nextDiversKernelScanline;2³
   sta GRP0                   ; 3 = @25   clear GRP0 if retrieved divers = 0
.nextDiversKernelScanline
   dex                        ; 2
   bne .drawRetrievedDiversKernel;2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   stx GRP0                   ; 3 = @06   clear player graphic values
   stx GRP1                   ; 3 = @09
   stx GRP0                   ; 3 = @12   done twice because it's VDEL'd
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda copyrightBackgroundColor;3
   sta COLUBK                 ; 3 = @09
   lda copyrightColor         ; 3
   sta COLUP0                 ; 3 = @15
   sta COLUP1                 ; 3 = @18
   sta COLUPF                 ; 3 = @21
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3 = @26
   stx NUSIZ1                 ; 3 = @29
   ldy #(H_COPYRIGHT * 2) - 1 ; 2
   lda #H_COPYRIGHT - 1       ; 2
   sta tmpCopyrightLoopCount  ; 3
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
   sty tmpCopyrightLinePtr    ; 3
   sta HMCLR                  ; 3
.copyrightLogoLoop
   ldy tmpCopyrightLinePtr    ; 3
   lda Copyright_5,y          ; 4
   sta tmpCopyrightCharHolder ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda Copyright_4,y          ; 4
   tax                        ; 2
   lda Copyright_0,y          ; 4
   sta GRP0                   ; 3 = @16
   dec tmpCopyrightLinePtr    ; 5
   lda Copyright_1,y          ; 4
   sta GRP1                   ; 3 = @28
   lda Copyright_2,y          ; 4
   sta GRP0                   ; 3 = @35
   lda Copyright_3,y          ; 4
   ldy tmpCopyrightCharHolder ; 3
   sta GRP1                   ; 3 = @45
   stx GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sta GRP0                   ; 3 = @54
   dec tmpCopyrightLoopCount  ; 5
   bpl .copyrightLogoLoop     ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @08
   sta VDELP1                 ; 3 = @11
   sta GRP0                   ; 3 = @14
   sta GRP1                   ; 3 = @17
   lda #OVERSCAN_TIME
   ldx #DUMP_PORTS | DISABLE_TIA
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for overscan period
   stx VBLANK                       ; disable TIA and discharge paddles
   ldy #12
   lda pickupDiverSoundValue        ; get pickup Diver sound value
   beq .checkToPlayOxygenWarningSound
   dec pickupDiverSoundValue        ; reduce pickup Diver sound value
   lsr                              ; divide value by 2
   sta AUDV1                        ; set volume for channel 1
   sty AUDC1
   lda retrievedDivers              ; get number of retrieved divers
   cmp #MAX_RETRIEVED_DIVERS
   bcc .setPickingUpDiverFrequency  ; branch if not retrieved all divers
   ldy #3
.setPickingUpDiverFrequency
   sty AUDF1
   lda #0
   sta shootingKillerSharkSoundValue; clear other sound values
   sta shootingEnemySubSoundValue
   sta oxygenWarningIndicator
.checkToPlayOxygenWarningSound
   lda oxygenWarningIndicator
   beq PlayShootingObstacleSounds
   lda #1
   sta shootingKillerSharkSoundValue
   sta shootingEnemySubSoundValue
   lda frameCount                   ; get current frame count
   and #$10                         ; keep D4
   lsr                              ; shift value right to set D3
   ora #4                           ; value alternates between 4 and 12
   sta AUDC1
   lda #24
   sta AUDF1
   lda #8
   sta AUDV1
   bpl ColorObstaclesForDifficulty  ; unconditional branch
   
PlayShootingObstacleSounds
   ldy #12
   lda shootingKillerSharkSoundValue
   beq .checkToPlayShootingSubSound
   dec shootingKillerSharkSoundValue; decrement Killer Shark sound value
   lsr                              ; divide value by 2
   sta AUDF1                        ; set frequency for shooting Killer Shark
   and #4
   sta AUDV1                        ; set volume for shooting Killer Shark
   sty AUDC1                        ; set for pure tone sound
.checkToPlayShootingSubSound
   lda shootingEnemySubSoundValue
   beq ColorObstaclesForDifficulty
   dec shootingEnemySubSoundValue   ; decrement Enemy Sub sound value
   lsr                              ; divide value by 2
   sta AUDV1                        ; set volume for shooting Enemy Sub
   lsr
   bcc .setShootingSubFrequency
   ldy #20
.setShootingSubFrequency
   sty AUDF1
   lda #8
   sta AUDC1
ColorObstaclesForDifficulty
   ldx #3
.colorObstaclesForDifficulty
   lda levelDifficulty              ; get level difficulty value
   and #7
   tay
   lda obstacleAttributes,x         ; get obstacle attribute value
   asl                              ; shift left...WHITE color for Enemy Sub
   and #OBSTACLE_TYPE_MASK << 1
   bne .setObstacleColor            ; branch if obstacle is an Enemy Sub
   lda KillerSharkColorValues,y     ; get Killer Shark colors for difficulty
.setObstacleColor
   eor colorEOR
   and colorBWMask
   sta obstacleColors,x
   dex
   bpl .colorObstaclesForDifficulty
   lda currentLevel                 ; get the current level
   clc
   adc #2                           ; increment value by 2
   cmp #9
   bcc .setCurrentPointValue        ; branch if not more than the max
   lda #9
.setCurrentPointValue
   asl                              ; multiply value by 16 for BCD value
   asl
   asl
   asl
   sta currentPointValue            ; set current point value
   ldx #4
.checkAllDiversRescued
   lda diverArray - 1,x             ; get Diver array value
   bpl .skipResetDiverArray         ; branch if Diver not rescued
   dex
   bne .checkAllDiversRescued
   ldy #3
.resetDiverArray
   stx diverArray,y                 ; reset Diver array value (x = 0)
   dey
   bpl .resetDiverArray
.skipResetDiverArray
   lda copyrightScrollRate          ; get copyright scroll rate
   beq AnimateSeaquestSub
   lda playerScore + 2              ; get player score tens value
   and #$0F                         ; keep 1's value
   bne .skipSwappingPlayerVariables ; branch if in SELECT mode
   lda frameCount                   ; get current frame count
   and #$7F
   bne .skipSwappingPlayerVariables
   lda gameSelection                ; get current game selection
   lsr                              ; shift D0 to carry
   bcc .skipSwappingPlayerVariables ; branch if a one player game
   jsr SwapPlayerVariables
.skipSwappingPlayerVariables
   dec copyrightScrollRate
   bne AnimateSeaquestSub
   dec copyrightScrollRate
AnimateSeaquestSub
   lda frameCount                   ; get current frame count
   and #3
   bne .doneAnimateSeaquestSub
   dec seaquestSubAnimationIdx      ; decrement every 4th frame
   bpl .doneAnimateSeaquestSub
   lda #2
   sta seaquestSubAnimationIdx      ; set to maximum animation frames
.doneAnimateSeaquestSub
   lda frameCount                   ; get current frame count
   and #7
   bne VerticalSync
   jsr NextRandom                   ; get a new random number every 8 frames
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
   tay                              ; move joystick values to y register
   ldx currentPlayerNumber          ; get the current player number
   bne .setPlayerJoystickValue      ; branch if player 2 is active
   jsr ShiftUpperNybblesToLower     ; shift player 1 joystick values
.setPlayerJoystickValue
   and #$0F
   sta currentJoystickValues
   iny
   beq .checkForSelectAndReset      ; branch if joystick not moved
   lda #0
   sta colorCycleMode               ; reset color cycle mode
.checkForSelectAndReset
   lda SWCHB                        ; read console switches
   lsr                              ; RESET now in carry
   bcs .skipGameReset               ; check for SELECT if RESET not pressed
   jsr InitializeGameVariables
   jmp MainLoop
       
.skipGameReset
   ldy #0
   lsr                              ; SELECT now in carry
   bcs .resetSelectDebounce
   lda selectDebounce               ; get the select debounce delay
   beq .incrementGameSelection      ; if it's zero -- increase game selection
   dec selectDebounce               ; decrement select debounce
   bpl CheckToExecuteGameProcessing
.incrementGameSelection
   inc gameSelection
   lda gameSelection                ; get the current game selection
   and #1                           ; make value 0 <= a <= 1
   sta gameSelection                ; set new game selection value
   sta colorCycleMode               ; set new color cycle mode value
   tay                              ; shift game selection to y register
   jsr InitializeGameVariables
   iny
   sty playerScore + 2
   ldx #<-1
   stx copyrightScrollRate
   ldy #SELECT_DELAY
   sty selectDebounce
   bpl .jmpToMainLoop               ; unconditional branch
   
.resetSelectDebounce
   sty selectDebounce
CheckToExecuteGameProcessing
   lda copyrightScrollRate
   beq GameProcessing               ; branch if game in progress
   jmp CheckCollisionWithDiverOrTorpedo
       
GameProcessing
   lda gameState                    ; get current game state
   lsr                              ; shift GS_REWARD_FOR_OXYGEN to carry
   lsr
   bcs RewardForRemainingOxygen
   jmp CheckToMoveEnemyPatrolSub
       
RewardForRemainingOxygen
   ldx currentPlayerNumber          ; get the current player number
   lda oxygenValue                  ; get oxygen value
   beq .doneRewardForRemainingOxygen; branch if done rewarding for oxygen
   and #$0F                         ; get mod16 value
   eor #$FF                         ; flip bits
   sta AUDF0                        ; set increasing frequency value
   sec
   sbc #5
   sta AUDF1
   lda #12
   sta AUDC0                        ; set sound to produce pure tones
   sta AUDC1
   lsr                              ; a = 6
   tax
   lda frameCount                   ; get current frame count
   and #1
   bne .jmpToMainLoop
   sta oxygenWarningIndicator       ; clear oxygen warning indicator (a = 0)
   dec oxygenValue                  ; decrement oxygen value
   bne .setVolumeForRemainingOxygen
   tax
.setVolumeForRemainingOxygen
   stx AUDV0
   stx AUDV1
   lda currentPointValue
   jsr IncrementScore
.jmpToMainLoop
   jmp MainLoop

.doneRewardForRemainingOxygen
   lda frameCount                   ; get current frame count
   and #$0F
   beq CheckToIncrementLevel
   lsr rewardSoundValues
   lda rewardSoundValues
   sta AUDV0
   sta AUDV1
   bpl .jmpToMainLoop               ; unconditional branch
       
CheckToIncrementLevel
   lda retrievedDivers              ; get number of retrieved divers
   bne RewardForRetrievedDivers
   inc currentLevel                 ; increment current level
   lda levelDifficulty              ; get level difficulty value
   cmp currentLevel                 ; compare with current level
   bcs .resetObstacleHorizPositions ; branch to skip difficulty increment
   inc levelDifficulty              ; increment difficulty
.resetObstacleHorizPositions 
   jsr ResetObstacleHorizPositions
   lda #GS_INCREMENT_OXYGEN
   sta gameState
   bne .jmpToMainLoop               ; unconditional branch
       
RewardForRetrievedDivers
   dec retrievedDivers              ; decrement Divers
   lda #31
   sta rewardSoundValues
   sta AUDV0                        ; set volume level for reward sound
   sta AUDV1
   lda #12
   sta AUDC0                        ; set to pure tone for reward sound
   sta AUDC1
   sta AUDF0
   lsr                              ; divide by 2 (a = 6)
   sta AUDF1
   ldx currentLevel                 ; get the current level
   cpx #19
   bcc .bonusPointsForRetrievedDivers
   ldx #19
.bonusPointsForRetrievedDivers
   lda #$50
   jsr IncrementScore
   dex
   bpl .bonusPointsForRetrievedDivers
   bmi .jmpToMainLoop               ; unconditional branch
       
CheckToMoveEnemyPatrolSub
   ldy currentLevel                 ; get the current level
   cpy #2
   bcc .checkEnemyPatrolSubCollision; branch if not level to launch
   cpy #6
   bcc .moveEnemyPatrolSub
   ldy #6
.moveEnemyPatrolSub
   lda frameCount                   ; get current frame count
   and EnemyPatrolSubMovementDelay - 2,y
   bne .checkEnemyPatrolSubCollision
   dec enemyPatrolSubHorizPos       ; move Enemy Patrol Sub (always moves left)
.checkEnemyPatrolSubCollision
   bit subCollisionValue
   bpl .checkToIncrementOxygen      ; branch if submarines didn't collide
   lda #XMIN
   sta enemyPatrolSubHorizPos       ; clear Enemy Patrol Sub horizontal value
   sta gameState
   lda #MAX_SEAQUEST_SUB_DEATH_TIME
   sta seaquestSubDeathAnimIdx
.checkToIncrementOxygen
   lda gameState                    ; get current game state
   lsr                              ; shift GS_INCREMENT_OXYGEN to carry
   bcc CheckCollisionWithDiverOrTorpedo; branch if not incrementing oxygen
   jsr IncrementOxygenValue
   bcc .doneCheckToMoveEnemyPatrolSub; branch if not reached maximum oxygen
   lda frameCount                   ; get current frame count
   ldx #3
.spawnNewObstacles
   jsr SpawnNewObstacle
   lsr tmpSpawnObstacleDir
   lda tmpSpawnObstacleDir
   dex
   bpl .spawnNewObstacles
   inx                              ; x = 0
   stx torpedoHorizPos              ; set Torpedo horizontal position
   stx AUDV1
   lda gameState                    ; get current game state
   eor #GS_INCREMENT_OXYGEN         ; flip GS_INCREMENT_OXYGEN value
   sta gameState
.doneCheckToMoveEnemyPatrolSub
   jmp MainLoop

EnemyPatrolSubMovementDelay
   .byte 3, 3, 3, 1, 1, 1, 0
       
CheckCollisionWithDiverOrTorpedo
   ldy #XMIN
   ldx seaquestBallCollisionValue   ; get BALL collision value
   bmi CheckSeaquestTorpedoCollision; branch if no BALL collision this frame
   lda obstacleAttributes,x         ; get obstacle attributes
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   beq .pickingUpDiver              ; branch if obstacle is a Killer Shark
   sty enemySubTorpedoHorizPos,x
   lda #MAX_SEAQUEST_SUB_DEATH_TIME
   sta seaquestSubDeathAnimIdx
   bne .animateObstacles            ; unconditional branch
       
.pickingUpDiver
   lda retrievedDivers              ; get number of retrieved divers
   cmp #MAX_RETRIEVED_DIVERS
   bcs CheckSeaquestTorpedoCollision
   inc retrievedDivers
   lda #23
   sta pickupDiverSoundValue
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #$0F
   sta obstacleAttributes,x         ; clear obstacle speed up value
   sty diverHorizPos,x              ; clear Diver horizontal position (y = 0)
   lda #<-1
   sta diverArray,x                 ; show Diver rescued
   bmi CheckSeaquestTorpedoCollision; unconditional branch
       
.animateObstacles
   jmp AnimateObstacles

CheckSeaquestTorpedoCollision
   ldx seaquestTorpedoCollisionValue; get Seaquest torpedo collision value
   bmi CheckKillerSharkCollisionWithDiver;branch if torpedo didn't collide
   lda torpedoHorizPos              ; get Torpedo horizontal position
   cmp #XMIN + 8
   bcc CheckKillerSharkCollisionWithDiver
   cmp #XMAX - 7
   bcs CheckKillerSharkCollisionWithDiver
   sty torpedoHorizPos              ; clear horizontal position (y = 0)
   sta tmpTorpedoHorizPos
   lda currentPointValue
   jsr IncrementScore               ; increment score
   ldy #32
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #$0F
   sta obstacleAttributes,x
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   bne .setShootingEnemySubSoundValue; branch if obstacle is an Enemy Sub
   ldy #16
   sty shootingKillerSharkSoundValue; set sound valud for shooting Killer Shark
   bpl .removeShotObstacleFromArray ; unconditional branch
       
.setShootingEnemySubSoundValue
   sty shootingEnemySubSoundValue
.removeShotObstacleFromArray
   lda tmpTorpedoHorizPos           ; get torpedo horizontal position
   adc #8                           ; increment by size of torpedo
   sec
   sbc obstacleHorizPos,x
   jsr Div16
   tay
   lda obstaclePatternIndex,x       ; get obstacle pattern index value
   and DestroyedObstacleMaskingValues,y; remove destroyed obstacle
.resetObstacleCollisionValue
   sta obstaclePatternIndex,x
   bne CheckKillerSharkCollisionWithDiver
   lda #<-1
   sta collisionValues,x
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   bne CheckKillerSharkCollisionWithDiver;branch if obstacle is an Enemy Sub
   lda randomSeed
   jsr SpawnNewObstacle
CheckKillerSharkCollisionWithDiver
   ldx #3
.checkKillerSharkCollisionWithDiver
   lda collisionValues,x            ; get kernel section collision value
   bmi .checkNextKillerSharkDiverCollision;branch if no collision
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   bne .checkNextKillerSharkDiverCollision;branch if obstacle is an Enemy Sub
   lda diverHorizPos,x              ;get Diver horizontal position
   cmp #XMIN + 8
   bcc .checkNextKillerSharkDiverCollision
   cmp #XMAX - 9
   bcs .checkNextKillerSharkDiverCollision
   lda obstacleAttributes,x         ; get obstacle attribute value
   ora #$10
   sta obstacleAttributes,x
.checkNextKillerSharkDiverCollision
   dex
   bpl .checkKillerSharkCollisionWithDiver
   ldx seaquestObstacleCollisionValue;get Seaquest obstacle collision
   bmi AnimateObstacles             ; branch if no collision this frame
   lda #<-1
   sta seaquestObstacleCollisionValue;reset Seaquest obstacle collision
   lda currentPointValue            ; get current point value
   jsr IncrementScore               ; increment score for destroying obstacle
   lda #MAX_SEAQUEST_SUB_DEATH_TIME
   sta seaquestSubDeathAnimIdx
   lda seaquestSubHorizPos          ; get Seaquest sub horizontal position
   clc
   adc #16                          ; increment by size of Seaquest Sub
   sec
   sbc obstacleHorizPos,x
   bcs .removeObstacleCollidedWithSeaquestSub
   lda #7 << 3
.removeObstacleCollidedWithSeaquestSub
   lsr
   lsr
   lsr
   tay
   lda obstaclePatternIndex,x       ; get obstacle pattern index value
   and DestroyedObstacleMaskingValues + 3,y; remove destroyed obstacle
   bpl .resetObstacleCollisionValue ; unconditional branch
       
AnimateObstacles
   ldx frameCount                   ; get current frame count
   txa                              ; move frame count to accumulator
   lsr
   lsr
   and #$0F
   cmp #8
   bcc .setKillerSharkFloatingValue
   eor #$0F
.setKillerSharkFloatingValue
   sta killerSharkFloatingValue
   txa                              ; move frame count to accumulator
   and #7
   bne .setKillerSharkAnimIndex
   dec obstacleAnimationIdx         ; reduce animation index every 8 frames
   bpl .setKillerSharkAnimIndex
   lda #2
   sta obstacleAnimationIdx
.setKillerSharkAnimIndex
   txa                              ; move frame count to accumulator
   lsr                              ; divide value by 2
   and #1
   sta tmpKillerSharkAnimIndex
   ldx #3
.determineObstacleAnimationIndex
   ldy obstacleAttributes,x         ; get obstacle attribute value
   tya                              ; move obstacle attribute to accumulator
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   beq .setBittingKillerSharkAnimationIndex;branch if Killer Shark
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_HORIZ_DIR_MASK | OBSTACLE_TYPE_MASK
   ora seaquestSubAnimationIdx      ; set Enemy Sub animation index value
   bpl .setNextObstacleAnimationIndex; unconditional branch
   
.setBittingKillerSharkAnimationIndex
   tya                              ; move obstacle attribute to accumulator
   cmp #$10
   bcc .setObstacleAnimationIndex   ; branch if not moving fast with Diver
   and #OBSTACLE_SPEED_MASK | OBSTACLE_HORIZ_DIR_MASK
   ora tmpKillerSharkAnimIndex
   bpl .setNextObstacleAnimationIndex
       
.setObstacleAnimationIndex
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_HORIZ_DIR_MASK     ; keep horizontal direction value
   ora obstacleAnimationIdx         ; combine animation index
.setNextObstacleAnimationIndex
   sta obstacleAttributes,x
   dex
   bpl .determineObstacleAnimationIndex
   lda copyrightScrollRate          ; get copyright scroll rate
   bne .moveObstacles
   ldx seaquestSubDeathAnimIdx      ; get Seaquest Sub death animation index
   bne PlaySeaquestSubDeathSounds   ; branch if Seaquest Sub in death state
.moveObstacles 
   jmp MoveObstacles

PlaySeaquestSubDeathSounds SUBROUTINE
   lda #XMIN
   sta torpedoHorizPos              ; remove Seaquest torpedo from frame
   sta oxygenWarningIndicator       ; clear oxygen warning indicator
   lda frameCount                   ; get current frame count
   and #3
   bne .jmpToMainLoop
   sta enemyPatrolSubHorizPos       ; a = 0
   sta AUDV1
   dec seaquestSubDeathAnimIdx
   beq RestartLevelForSeaquestDeath
   lda seaquestSubDeathAnimIdx      ; get Seaquest Sub death amimation index
   cmp #MAX_SEAQUEST_SUB_DEATH_TIME - 8
   bcc .setSecondLevelSeaquestSubDeathSoundValues
   ldx #3
   and #1                           ; keep D0
   bne .setFirstLevelSeaquestSubDeathSoundValues; branch on odd value
   ldx #16
.setFirstLevelSeaquestSubDeathSoundValues
   stx AUDF0
   lda #6
   sta AUDV0
   lda #15
   sta AUDC0
   bpl .donePlaySeaquestSubDeathSounds
       
.setSecondLevelSeaquestSubDeathSoundValues
   sta AUDV0
   lda #8
   sta AUDC0
   lda #16
   sta AUDF0
   lda #0
   sta oxygenValue
.donePlaySeaquestSubDeathSounds
   bpl .jmpToMainLoop

RestartLevelForSeaquestDeath
   sta AUDV0
   sta AUDC0
   sta seaquestSubHorizDir
   jsr ResetObstacleHorizPositions
   jsr SetSeaquestSubInitPosition
   ldx retrievedDivers              ; get number of retrieved divers 
   beq .skipDecrementRetrievedDivers; branch if no retrieved divers
   dec retrievedDivers              ; reduce number of retrieved divers
.skipDecrementRetrievedDivers
   ldx #3
.clearObstacleSpeedUpValue 
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #$0F                         ; clear speed up value
   sta obstacleAttributes,x
   dex
   bpl .clearObstacleSpeedUpValue
   lda gameState                    ; get current game state
   ora #GS_INCREMENT_OXYGEN
   sta gameState                    ; set to increment oxygen
   lda reserveSubs                  ; get number of reserve submarines 
   ora reservePlayerSubs
   bne .decrementReservedSubs
   inc copyrightScrollRate
   sta seaquestSubVertPos           ; set vertical position to 0 (a = 0)
   bpl .jmpToMainLoop               ; unconditional branch
   
.decrementReservedSubs
   jsr DecrementReservedSubs
.jmpToMainLoop
   jmp JmpToMainLoop

MoveObstacles SUBROUTINE
   lda levelDifficulty              ; get current level difficulty
   clc
   adc #16
   sta tmpEnemySubTorpedoSpeedValue
   sec
   sbc #10
   sta tmpObstacleSpeedValue
   lsr
   sta tmpDiverSpeedValue
   ldx #2
.determineObstacleSpeedValues
   lda tmpSpeedValues,x
   jsr DetermineFractionalPositioning
   dex
   bpl .determineObstacleSpeedValues
   ldx #3
.moveObstacles
   lda obstacleAttributes,x         ; get obstacle attribute value
   jsr ShiftUpperNybblesToLower
   sta tmpObstacleSpeedUp           ; save speed up value
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   bcs .moveObstacleLeft            ; branch if traveling left
   adc tmpObstacleSpeed             ; increment obstacle position
   sta obstacleHorizPos,x
   and #$F8
   cmp #XMAX
   jmp .determineToSpawnNewObstacle
       
.moveObstacleLeft
   sbc tmpObstacleSpeed
   sta obstacleHorizPos,x
   and #$F8
   cmp #XMIN - 40
.determineToSpawnNewObstacle
   bne .moveDiverOrEnemyTorpedo
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_TYPE_MASK          ; keep OBSTACLE_TYPE
   eor #OBSTACLE_TYPE_MASK          ; flip OBSTACLE_TYPE value
   sta tmpObstacleAttributeValue
   lda randomSeed                   ; get current random seed value
   and #OBSTACLE_HORIZ_DIR_MASK     ; keep D4 value
   ora tmpObstacleAttributeValue    ; combine to set obstacle direction
   sta obstacleAttributes,x
   lda randomSeed                   ; get random number
   sta tmpObstacleSpeedUp
   jsr DetermineObstacleStartingHorizPos
.moveDiverOrEnemyTorpedo
   lda obstacleAttributes,x         ; get obstacle attribute value
   lsr
   lsr
   lsr                              ; shift OBSTACLE_TYPE_MASK into carry
   bcs .moveEnemySubTorpedo         ; branch if Enemy Sub
   lsr                              ; shift OBSTACLE_HORIZ_DIR_MASK to carry
   ldy diverArray,x                 ; get Diver array value
   dey
   bpl .moveDiver                   ; branch if Diver present
   jmp .moveNextObstacle
       
.moveDiver
   bcs .moveDiverLeft               ; branch if obstacle traveling left
   lsr tmpObstacleSpeedUp           ; shift speed up value to carry
   lda tmpObstacleSpeed
   bcs .moveDiverRight              ; branch if obstacle moving faster
   lda tmpDiverSpeed                ; increment by Diver speed
.moveDiverRight
   clc
   adc diverHorizPos,x
   jmp .determineDiverReachingRightBorder
       
.moveDiverLeft
   lsr tmpObstacleSpeedUp           ; shift speed up value to carry
   lda tmpObstacleSpeed
   bcs .setDiverMovementSpeed       ; branch if obstacle moving faster
   lda tmpDiverSpeed
.setDiverMovementSpeed
   sta tmpObstacleSpeedValue
   beq .moveNextObstacle
   lda diverHorizPos,x              ; get Diver horizontal position
   bne .decrementDiverPosition      ; branch if not reached left boundary
   lda #XMAX
.decrementDiverPosition
   sec
   sbc tmpObstacleSpeedValue
   bne .determineDiverReachingRightBorder
   lda #XMAX
.determineDiverReachingRightBorder
   cmp #XMAX
   bcc .setEnemySubTorpedoOrDiverHorizPos
   lda #0
   sta diverArray,x                 ; show Diver reached border
   jmp .setEnemySubTorpedoOrDiverHorizPos
       
.moveEnemySubTorpedo
   lda enemySubTorpedoHorizPos,x    ; get Enemy Sub torpedo horizontal position
   sta tmpEnemySubTorpedoHorizPos
   bne .enemySubTorpedoInFlight
   ldy obstaclePatternIndex,x       ; get obstacle pattern index
   beq .checkToSpawnNewObstacle     ; branch if obstacle not present
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #OBSTACLE_HORIZ_DIR_MASK     ; keep obstacle horizontal direction
   ora obstaclePatternIndex,x       ; combine with pattern index value
   tay
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   clc
   adc EnemySubTorpedoHorizAdjustValues,y
   sta tmpEnemySubTorpedoOffset
   sec
   sbc #39
   cmp #88
   bcs .disableEnemySubTorpedoOrDiver
.enemySubTorpedoInFlight
   lda obstacleAttributes,x         ; get obstacle attribute value
   jsr ShiftUpperNybblesToLower     ; shift OBSTACLE_HORIZ_DIR_MASK to carry
   lda tmpEnemySubTorpedoHorizPos   ; get Enemy Sub torpedo horizontal position
   bcs .moveEnemySubTorpedoLeft     ; branch if moving left
   adc tmpEnemySubTorpedoSpeed      ; increment by Enemy Sub torpedo speed
   jmp .checkTorpedoOrDiverReachingRightBorder
       
.moveEnemySubTorpedoLeft
   sbc tmpEnemySubTorpedoSpeed      ; subract by Enemy Sub torpedo speed
.checkTorpedoOrDiverReachingRightBorder 
   cmp #XMAX
   bcc .setEnemySubTorpedoOrDiverHorizPos
.checkToSpawnNewObstacle
   lda obstaclePatternIndex,x       ; get obstacle pattern index
   bne .disableEnemySubTorpedoOrDiver
   lda randomSeed                   ; get current random number
   ora #$80                         ; set D7 high
   jsr SpawnNewObstacle
.disableEnemySubTorpedoOrDiver 
   lda #XMIN
.setEnemySubTorpedoOrDiverHorizPos
   sta enemySubTorpedoOrDiverHorizPos,x
.moveNextObstacle
   dex
   bmi CheckForSeaquestSubSurfacing
   jmp .moveObstacles
       
CheckForSeaquestSubSurfacing
   lda copyrightScrollRate
   bne .doneCheckForSeaquestSubSurfacing
   lda seaquestSubVertPos           ; get Seaquest Sub vertical position
   cmp #SEAQUEST_YMIN
   bne MoveSeaquestSubmarine        ; branch if not at the top
   lda oxygenValue                  ; get oxygen value
   cmp #MAX_OXYGEN_VALUE
   beq MoveSeaquestSubmarine
   lda retrievedDivers              ; get number of retrieved divers
   bne .checkForRescuingAllDivers
   lda #MAX_SEAQUEST_SUB_DEATH_TIME
   sta seaquestSubDeathAnimIdx
.doneCheckForSeaquestSubSurfacing
   jmp JmpToMainLoop

.checkForRescuingAllDivers
   cmp #MAX_RETRIEVED_DIVERS
   bne .seaquestSubSurfacedWithoutMaxDivers
   sta gameState                    ; set to GS_REWARD_FOR_OXYGEN (a = 6)
   bpl .doneCheckForSeaquestSubSurfacing; unconditional branch
   
.seaquestSubSurfacedWithoutMaxDivers 
   jsr IncrementOxygenValue
   bcc .doneCheckForSeaquestSubSurfacing; branch if not reached maximum oxygen
   dec retrievedDivers              ; reduce number of rescued divers
   inc levelDifficulty              ; increment level difficulty
   lda #0
   sta AUDV0
   sta AUDV1
MoveSeaquestSubmarine
   lda currentJoystickValues        ; get current joystick values
   and #<(~MOVE_UP) >> 4            ; isolate MOVE_UP value
   bne .checkForMovingDown          ; branch if joystick not moving up
   ldx seaquestSubVertPos           ; get Seaquest sub vertical position
   cpx #SEAQUEST_YMIN + 1
   bcc .checkForMovingDown
   dec seaquestSubVertPos           ; move Seaquest sub up
.checkForMovingDown
   lda currentJoystickValues        ; get current joystick values
   and #<(~MOVE_DOWN) >> 4          ; isolate MOVE_DOWN value
   bne .checkForMovingLeft          ; branch if joystick not moving down
   ldx seaquestSubVertPos
   cpx #SEAQUEST_YMAX
   bcs .checkForMovingLeft
   inc seaquestSubVertPos           ; move Seaquest sub down
.checkForMovingLeft
   lda currentJoystickValues        ; get current joystick values
   and #<(~MOVE_LEFT) >> 4          ; isolate MOVE_LEFT value
   bne .checkForMovingRight         ; branch if joystick not moving left
   lda #REFLECT
   sta seaquestSubHorizDir
   lda seaquestSubHorizPos          ; get Seaquest Sub horizontal position
   cmp #SEAQUEST_XMIN + 1
   bcc .checkForMovingRight
   dec seaquestSubHorizPos          ; move Seaquest sub left
.checkForMovingRight
   lda currentJoystickValues        ; get current joystick values
   and #<(~MOVE_RIGHT) >> 4         ; isolate MOVE_RIGHT value
   bne CheckToLaunchSeaquestTorpedo ; branch if joystick not moving right
   sta seaquestSubHorizDir
   lda seaquestSubHorizPos          ; get Seaquest Sub horizontal position
   cmp #SEAQUEST_XMAX
   bcs CheckToLaunchSeaquestTorpedo ; branch if reached right edge
   inc seaquestSubHorizPos          ; move Seaquest Sub right
CheckToLaunchSeaquestTorpedo
   lda torpedoHorizPos              ; get Seaquest torpedo horizontal position
   bne .playSeaquestTorpedoSound    ; branch if torpedo in flight
   sta AUDV0                        ; turn off volume (a = 0)
   lda seaquestSubHorizDir
   sta seaquestTorpedoHorizDir
   ldy currentPlayerNumber          ; get the current player number
   lda INPT4,y                      ; read action button
   bmi CheckToReduceOxygenLevel     ; branch if button not pressed
   lda seaquestSubVertPos           ; get Seaquest Sub vertical position
   cmp #SEAQUEST_YMIN + 5
   bcc CheckToReduceOxygenLevel     ; branch if Seaquest Sub at sea surface
   lda #16
   sta seaquestTorpedoSoundValues
   lda #15
   sta AUDC0
   lda seaquestSubHorizPos          ; get Seaquest Sub horizontal position
   clc
   adc #8
.playSeaquestTorpedoSound
   tay
   lda seaquestTorpedoSoundValues
   sta AUDF0                        ; set sound frequency for torpedo sound
   ldx oxygenValue                  ; get oxygen value
   cpx #17
   bcs .setSeaquestTorpedoVolume
   lda #0
.setSeaquestTorpedoVolume
   lsr
   sta AUDV0                        ; set volume for torpedo sound
   lda frameCount                   ; get current frame count
   and #3
   bne .moveSeaquestTorpedo
   dec seaquestTorpedoSoundValues
.moveSeaquestTorpedo
   lda SWCHB                        ; read console switches
   sta tmpDifficultySettings
   lda seaquestTorpedoHorizDir      ; get torpedo horizontal direction
   lsr                              ; shift direction value to D0
   lsr
   lsr
   tax                              ; move direction index to x register
   tya
   adc SeaquestTorpedoAmateurSpeed,x; add in Seaquest torpedo speed
   asl tmpDifficultySettings        ; shift player 2 difficulty to carry
   ldy currentPlayerNumber          ; get the current player number
   bne .checkToReduceSpeedForPro    ; branch if player 2 is active
   asl tmpDifficultySettings        ; shift player 1 difficulty to carry
.checkToReduceSpeedForPro
   bcc .setTorpedoHorizPosition     ; branch if set to AMATEUR
   clc
   adc SeaquestTorpedoProFactor,x   ; offset speed for PRO seeting
.setTorpedoHorizPosition
   sta torpedoHorizPos
   cmp #XMAX
   bcc .restrictTorpedoToBoundaries
   lda #XMIN
   sta AUDV0
.restrictTorpedoToBoundaries
   sta torpedoHorizPos
CheckToReduceOxygenLevel
   ldy oxygenValue                  ; get oxygen value
   lda seaquestSubVertPos           ; get Seaquest Sub vertical position
   cmp #SEAQUEST_YMIN +  7
   bcc .setNewOxygenValue
   lda frameCount                   ; get current frame count
   and #$1F
   bne .setNewOxygenValue
   dey                              ; decrement oxygen value every 63 frames
   bne .setNewOxygenValue
   tay                              ; not needed...y is 0 from dey above
   lda #MAX_SEAQUEST_SUB_DEATH_TIME
   sta seaquestSubDeathAnimIdx
.setNewOxygenValue
   sty oxygenValue
JmpToMainLoop
   jmp MainLoop

SeaquestTorpedoProFactor
   .byte -2, 2
       
InitializeGameVariables
   ldx #<colorCycleMode
ResetVariables
   lda #0       
.clearLoop
   sta VSYNC,x
   inx
   cpx #<movementSpeedValue + 1
   bne .clearLoop
   ldx #3
.initColorObstacles
   lda #OLIVE_GREEN + 8
   sta obstacleColors - 1,x
   dex
   bne .initColorObstacles
   stx AUDV0                        ; turn off volume (x = 0)
   stx AUDV1
   inx                              ; x = 1
   stx gameState                    ; set to increment oxygen
   ldx #3
   stx reserveSubs                  ; set initial number of reserve submarines
   inx                              ; x = 4
   lda gameSelection                ; get current game selection
   lsr                              ; shift D0 to carry
   bcc SetSeaquestSubInitPosition   ; branch if ONE_PLAYER game
   stx reservePlayerSubs
SetSeaquestSubInitPosition
   lda #INIT_SEAQUEST_VERT
   sta seaquestSubVertPos
   lda #INIT_SEAQUEST_HORIZ
   sta seaquestSubHorizPos
   rts

DetermineFractionalPositioning
   sta movementSpeedValue
   jsr Div16                        ; divide speed value by 16
   sta obstacleSpeedValues,x        ; set speed value
   lda movementSpeedValue
   and #$0F    
   clc
   adc fractionalPositionValues,x   ; increment by speed mod 16
   cmp #16
   bcc .setFractionalPositionValues
   inc obstacleSpeedValues,x        ; incement speed value
.setFractionalPositionValues
   and #$0F
   sta fractionalPositionValues,x
   rts

IncrementScore
   sed
   clc
   adc playerScore + 2              ; increment tens position
   sta playerScore + 2
   bcc .doneIncrementScore
   lda playerScore + 1              ; get hundreds position
   adc #1 - 1                       ; increment when carry set
   sta playerScore + 1
   lda playerScore                  ; get thousands position
   adc #1 - 1                       ; increment when carry set
   bcc .skipScoreMaxOut
   lda #$99                         ; make the score 999,999
   sta playerScore + 1
   sta playerScore + 2
   inc copyrightScrollRate
.skipScoreMaxOut
   sta playerScore
   lda playerScore + 1              ; get score thousands position
   and #$FF
   bne .doneIncrementScore
   lda reserveSubs                  ; get number of reserve submarines
   cmp #MAX_RESERVED_SUBS
   bcs .doneIncrementScore
   inc reserveSubs                  ; increment number of reserve submarines
.doneIncrementScore
   cld
   rts
   
SpawnNewObstacle
   sta tmpSpawnObstacleDir
   lda levelDifficulty              ; get current level difficulty
   and #7
   tay
   lda tmpSpawnObstacleDir
   and #OBSTACLE_HORIZ_DIR_MASK     ; keep value for obstacle direction
   sta obstacleAttributes,x         ; set obstacle direction
   bne .spawnNewObstaclesTravelingLeft; branch if traveling left
   lda InitObstaclePatternIndexes,y
   and #$0F
   sta obstaclePatternIndex,x
   bne DetermineObstacleStartingHorizPos
       
.spawnNewObstaclesTravelingLeft
   lda InitObstaclePatternIndexes,y
   jsr ShiftUpperNybblesToLower
   sta obstaclePatternIndex,x
DetermineObstacleStartingHorizPos
   ldy #XMAX + 8
   lda obstacleAttributes,x         ; get obstacle attribute value
   and #$0F
   sta obstacleAttributes,x         ; remove speed up value
   and #OBSTACLE_HORIZ_DIR_MASK     ; keep obstacle direction
   beq .setObstacleStartingHorizPos ; branch if traveling right
   ldy #XMIN - 41
.setObstacleStartingHorizPos
   sty obstacleHorizPos,x
   lda tmpSpawnObstacleDir          ; get obstacle direction
   ldy diverArray,x                 ; get value from Diver array
   bmi .doneSpawnNewObstacle        ; branch if Diver rescued
   cmp #80
   bcc .doneSpawnNewObstacle
   ldy #1
   sty diverArray,x                 ; spawn new diver
.doneSpawnNewObstacle
   rts

ResetObstacleHorizPositions
   ldx #3
.resetObstacleHorizPositions
   lda #XMIN - 48
   sta obstacleHorizPos,x
   lda #XMIN
   sta enemySubTorpedoOrDiverHorizPos,x
   dex
   bpl .resetObstacleHorizPositions
   rts

EnemySubTorpedoHorizAdjustValues
   .byte 0, 32, 16, 32, 0, 32, 16, 32
   .byte 0, 32, 16, 16, 0, 0, 0, 0

   .byte $DA                        ; unused byte

COARSE_MOTION SET 0
KernelHorizPositionValueTable
   .byte HMOVE_L6 | COARSE_MOTION, HMOVE_L5 | COARSE_MOTION
   .byte HMOVE_L4 | COARSE_MOTION, HMOVE_L3 | COARSE_MOTION
   .byte HMOVE_L2 | COARSE_MOTION, HMOVE_L1 | COARSE_MOTION
   .byte HMOVE_0  | COARSE_MOTION, HMOVE_R1 | COARSE_MOTION
   .byte HMOVE_R2 | COARSE_MOTION, HMOVE_R3 | COARSE_MOTION
   .byte HMOVE_R4 | COARSE_MOTION, HMOVE_R5 | COARSE_MOTION
   .byte HMOVE_R6 | COARSE_MOTION, HMOVE_R7 | COARSE_MOTION
   
   REPEAT 10
   
COARSE_MOTION SET COARSE_MOTION + 1

   .byte HMOVE_L7 | COARSE_MOTION, HMOVE_L6 | COARSE_MOTION
   .byte HMOVE_L5 | COARSE_MOTION, HMOVE_L4 | COARSE_MOTION
   .byte HMOVE_L3 | COARSE_MOTION, HMOVE_L2 | COARSE_MOTION
   .byte HMOVE_L1 | COARSE_MOTION, HMOVE_0  | COARSE_MOTION
   .byte HMOVE_R1 | COARSE_MOTION, HMOVE_R2 | COARSE_MOTION
   .byte HMOVE_R3 | COARSE_MOTION, HMOVE_R4 | COARSE_MOTION
   .byte HMOVE_R5 | COARSE_MOTION, HMOVE_R6 | COARSE_MOTION
   .byte HMOVE_R7 | COARSE_MOTION

   REPEND
       
DecrementReservedSubs
   jsr SwapPlayerVariables
   lda reserveSubs                  ; get number of reserve submarines
   bne .decrementReservedSubs       ; branch if subs remaining for player
   jsr SwapPlayerVariables          ; switch back to original player
.decrementReservedSubs
   dec reserveSubs
   rts

SetDigitPointersMSBValues
   ldy #11
   lda #>NumberFonts
.setDigitPointersMSBValue
   sta digitPointers,y
   dey
   dey
   bpl .setDigitPointersMSBValue
   rts

HorizonColors
   .byte YELLOW + 4, RED_ORANGE + 4, BRICK_RED + 4, BRICK_RED + 4, RED + 4
   .byte RED + 4, PURPLE + 4, PURPLE + 4, COBALT_BLUE + 4, COBALT_BLUE + 4
       
GameColorTable
   .byte COLOR_PLAYER1_SCORE        ; player 1 score color
   .byte COLOR_PLAYER2_SCORE        ; player 2 score color
   .byte COLOR_SEA                  ; sea color
   .byte COLOR_PLAYER1              ; player 1 color
   .byte COLOR_PLAYER2              ; player 2 color
   .byte BLUE + 4                   ; sky color
   .byte BLACK                      ; oxygen literal color
   .byte WHITE - 2                  ; oxygen bar color
   .byte BLACK + 6                  ; sea floor color
   .byte BRICK_RED + 2              ; oxygen background color
   .byte BLUE + 6                   ; copyright color
   
SeaquestSubGraphicLSBValues
   .byte <SeaquestSubGraphics_00
   .byte <SeaquestSubGraphics_01
   .byte <SeaquestSubGraphics_02
       
   FILL_BOUNDARY 0, 234

DiverEnemyMissileAnimationTables
LeftEnemySubTorpedoAnimation
RightDiverAnimation_00
   .byte HMOVE_0, HMOVE_L1, HMOVE_L1, HMOVE_R2, HMOVE_L3, HMOVE_L1
   .byte HMOVE_0, HMOVE_L2, HMOVE_0, HMOVE_R2, HMOVE_0, HMOVE_R1, HMOVE_R1
;
; last 2 bytes shared with table below
;
RightDiverAnimation_01
   .byte HMOVE_0, HMOVE_0, HMOVE_L1, HMOVE_L1, HMOVE_L1, HMOVE_L1, HMOVE_0
   .byte HMOVE_L2, HMOVE_0, HMOVE_R2, HMOVE_R1, HMOVE_R1, HMOVE_0, HMOVE_0
;
; last byte shared with table below
;
RightDiverAnimation_02
RightDiverAnimation_03
RightEnemySubTorpedoAnimation
   .byte HMOVE_0, HMOVE_L1, HMOVE_L1, HMOVE_R2, HMOVE_L3, HMOVE_L1, HMOVE_0
   .byte HMOVE_L2, HMOVE_0, HMOVE_R2, HMOVE_0, HMOVE_R1, HMOVE_R1, HMOVE_0
;
; last byte shared with table below
;
LeftDiverAnimation_00
   .byte HMOVE_0, HMOVE_R1, HMOVE_R1, HMOVE_R1, HMOVE_R1, HMOVE_R3, HMOVE_L2
   .byte HMOVE_R1, HMOVE_0, HMOVE_L2, HMOVE_0, HMOVE_L1, HMOVE_L1, HMOVE_0, HMOVE_R3
   
LeftDiverAnimation_01
   .byte HMOVE_0, HMOVE_0, HMOVE_R2, HMOVE_R1, HMOVE_R1, HMOVE_R3, HMOVE_L2
   .byte HMOVE_R1, HMOVE_0, HMOVE_L2, HMOVE_L1, HMOVE_L1, HMOVE_0, HMOVE_0, HMOVE_R3
   
LeftDiverAnimation_02
LeftDiverAnimation_03
   .byte HMOVE_0, HMOVE_R1, HMOVE_R1, HMOVE_R1, HMOVE_R1, HMOVE_R3, HMOVE_L2
   .byte HMOVE_R1, HMOVE_0, HMOVE_L2, HMOVE_0, HMOVE_L1, HMOVE_L1, HMOVE_0, HMOVE_R3

DiverNUSIZAndENABLValues_00
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM
   .byte MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | DISABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
;
; last byte shared with table below
;
DiverNUSIZAndENABLValues_01
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE2 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM
   .byte MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM
   
DiverNUSIZAndENABLValues_02
DiverNUSIZAndENABLValues_03
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM
   .byte MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE2 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | ENABLE_BM, MSBL_SIZE1 | ENABLE_BM
       
SeaquestSubDeathAnimationGraphics
SeaquestSubDeathAnimationGraphics_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $28 ; |..X.X...|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
;
; last byte shared with table below
;
SeaquestSubDeathAnimationGraphics_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $44 ; |.X...X..|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $28 ; |..X.X...|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
SeaquestSubDeathAnimationGraphics_00
   .byte $00 ; |........|
   .byte $82 ; |X.....X.|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $82 ; |X.....X.|
   .byte $00 ; |........|
;
; last byte shared with table below
;
SeaquestSubGraphics
SeaquestSubGraphics_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7D ; |.XXXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
SeaquestSubGraphics_01
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $7F ; |.XXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
SeaquestSubGraphics_02
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $FE ; |XXXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $FD ; |XXXXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
   
EnemySubTorpedoNUSIZAndENABLValues
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | DISABLE_BM
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE4 | ENABLE_BM
   .byte MSBL_SIZE1 | DISABLE_BM, MSBL_SIZE1 | DISABLE_BM
   .byte MSBL_SIZE4 | ENABLE_BM, MSBL_SIZE1 | DISABLE_BM
;
; last 7 bytes shared with table below
;       
KillerSharkGraphics
KillerShark_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $D8 ; |XX.XX...|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $0C ; |....XX..|
   .byte $08 ; |....X...|
;
; last 8 bytes shared with table below
;
KillerShark_01
KillerShark_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $91 ; |X..X...X|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $8C ; |X...XX..|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

SeaquestSubDeathGraphicValues
   .byte <SeaquestSubDeathAnimationGraphics_00
   .byte <SeaquestSubDeathAnimationGraphics_01
   .byte <SeaquestSubDeathAnimationGraphics_01
   .byte <SeaquestSubDeathAnimationGraphics_02
   .byte <SeaquestSubDeathAnimationGraphics_02
       
   FILL_BOUNDARY 0, 234
       
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
;
; last 4 bytes shared with table below
;
TorpedoEnablingValues
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte ENABLE_BM, DISABLE_BM, DISABLE_BM
;
; last 5 bytes shared with table below
;
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
   .byte $51 ; |.X.X...X|
   .byte $73 ; |.XXX..XX|
   .byte $51 ; |.X.X...X|
   .byte $77 ; |.XXX.XXX|
   .byte $00 ; |........|
       
SetObjectHorizPosition
   sta HMP0,x                       ; set object's fine motion value
   and #$0F                         ; keep lower nybbles for coarse value
   tay                              ; move coarse value to y register
   iny
   iny
   iny
   sta WSYNC                        ; wait for next scanline
.coarseHorizPositionObject
   dey
   bpl .coarseHorizPositionObject
   sta RESP0,x                      ; set object's coarse motion value
   rts

PositionTorpedoesHoriz
   jsr SetObjectHorizPosition
   sta WSYNC                        ; wait for next scanline
   sta HMOVE                        ; move objects horizontally
   jsr Waste12Cycles
   jsr Waste12Cycles
   sta HMCLR                        ; clear horizontal movement
   rts

NextRandom
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
   rts

ObstacleNUSIZIndexMaskingValues
   .byte 6, 4, 0, 0, 0, 0, 1, 3, 7
   
PlayerNUSIZValueTable
   .byte ONE_COPY, ONE_COPY, ONE_COPY, TWO_COPIES
   .byte ONE_COPY, TWO_MED_COPIES, TWO_COPIES, THREE_COPIES
       
InitObstaclePatternIndexes
   .byte 4 << 4 | 1, 4 << 4 | 1, 6 << 4 | 3, 6 << 4 | 3
   .byte 5 << 4 | 5, 5 << 4 | 5, 7 << 4 | 7, 7 << 4 | 7
   
DestroyedObstacleMaskingValues
   .byte 3, 5, 6, 3, 3, 1, 5, 4, 6, 6, 4

KillerSharkColorValues
   .byte COLOR_KILLER_SHARK_00, COLOR_KILLER_SHARK_01, COLOR_KILLER_SHARK_02
   .byte COLOR_KILLER_SHARK_03, COLOR_KILLER_SHARK_04, COLOR_KILLER_SHARK_05
   .byte COLOR_KILLER_SHARK_06, COLOR_KILLER_SHARK_07, COLOR_KILLER_SHARK_08
       
SeaquestSubDeathColorValues
   .byte LT_BLUE, LT_BLUE, LT_BLUE, LT_BLUE, LT_BLUE, LT_BLUE + 2, LT_BLUE + 4
   .byte LT_BLUE + 6, LT_BLUE + 8, LT_BLUE + 10, LT_BLUE + 12, LT_BLUE + 12
   .byte LT_BLUE + 12, LT_BLUE + 12, WHITE, BLACK, WHITE, BLACK, WHITE, BLACK
   .byte WHITE, BLACK, WHITE
       
LeftPF2OxygenBarGraphics
   .byte $00 ; |........|
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $07 ; |.....XXX|
   .byte $0F ; |....XXXX|
   .byte $1F ; |...XXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
       
RightPF2OxygenBarGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $C0 ; |XX......|
   .byte $E0 ; |XXX.....|
   .byte $F0 ; |XXXX....|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
       
ObstacleHorizOffsetTable
   .byte 0, 32, 16, 16, 0
       
IndicatorNUSIZValueTable
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY
   .byte ONE_COPY << 4 | ONE_COPY
   .byte TWO_COPIES << 4 | ONE_COPY
   .byte TWO_COPIES << 4 | TWO_COPIES
   .byte THREE_COPIES << 4 | TWO_COPIES
   .byte THREE_COPIES << 4 | THREE_COPIES
       
ReserveSubGraphic
   .byte $00 ; |........|
   .byte $80 ; |X.......|
   .byte $FC ; |XXXXXX..|
   .byte $FE ; |XXXXXXX.|
   .byte $FE ; |XXXXXXX.|
   .byte $BE ; |X.XXXXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $04 ; |.....X..|
       
OxygenLiteral_00
   .byte $EA ; |XXX.X.X.|
   .byte $AE ; |X.X.XXX.|
   .byte $A4 ; |X.X..X..|
   .byte $AE ; |X.X.XXX.|
   .byte $EA ; |XXX.X.X.|
OxygenLiteral_01
   .byte $4E ; |.X..XXX.|
   .byte $4A ; |.X..X.X.|
   .byte $4A ; |.X..X.X.|
   .byte $E8 ; |XXX.X...|
   .byte $AE ; |X.X.XXX.|
OxygenLiteral_02
   .byte $D2 ; |XX.X..X.|
   .byte $96 ; |X..X.XX.|
   .byte $DE ; |XX.XXXX.|
   .byte $9A ; |X..XX.X.|
   .byte $D2 ; |XX.X..X.|
   
;
; the following 9 bytes are not utilized
;
   .byte $00, $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF
       
DiverEnemyMissileHMOVEValues
   .byte <RightDiverAnimation_00, <RightDiverAnimation_01
   .byte <RightDiverAnimation_02, <RightDiverAnimation_03
   .byte <RightEnemySubTorpedoAnimation, <RightEnemySubTorpedoAnimation
   .byte <RightEnemySubTorpedoAnimation, <RightEnemySubTorpedoAnimation
   .byte <LeftDiverAnimation_00, <LeftDiverAnimation_01
   .byte <LeftDiverAnimation_02, <LeftDiverAnimation_03
   .byte <LeftEnemySubTorpedoAnimation, <LeftEnemySubTorpedoAnimation
   .byte <LeftEnemySubTorpedoAnimation, <LeftEnemySubTorpedoAnimation
   .byte 0, 0, 0, 0                 ; these bytes aren't used or referenced
   
EnableDiverEnemyMissileValues
   .byte <DiverNUSIZAndENABLValues_00, <DiverNUSIZAndENABLValues_01
   .byte <DiverNUSIZAndENABLValues_02, <DiverNUSIZAndENABLValues_03
   .byte <EnemySubTorpedoNUSIZAndENABLValues, <EnemySubTorpedoNUSIZAndENABLValues
   .byte <EnemySubTorpedoNUSIZAndENABLValues, <EnemySubTorpedoNUSIZAndENABLValues
   .byte <DiverNUSIZAndENABLValues_00, <DiverNUSIZAndENABLValues_01
   .byte <DiverNUSIZAndENABLValues_02, <DiverNUSIZAndENABLValues_03
   .byte <EnemySubTorpedoNUSIZAndENABLValues, <EnemySubTorpedoNUSIZAndENABLValues
   .byte <EnemySubTorpedoNUSIZAndENABLValues, <EnemySubTorpedoNUSIZAndENABLValues
       
ObstacleGraphicLSBValues
   .byte <KillerShark_00
   .byte <KillerShark_01
   .byte <KillerShark_02
   .byte 0                          ; not used
   .byte <SeaquestSubGraphics_00
   .byte <SeaquestSubGraphics_01
   .byte <SeaquestSubGraphics_02
   .byte 184, 184, 192, 184         ; not used
       
SeaquestTorpedoAmateurSpeed
   .byte 5 , -5
       
Div16
ShiftUpperNybblesToLower
Waste20Cycles
   lsr
Waste18Cycles
   lsr
Waste16Cycles
   lsr
   lsr
Waste12Cycles
   rts

IncrementOxygenValue
   lda frameCount                   ; get current frame count
   and #1
   bne .playIncreasingOxygenSound
   sta oxygenWarningIndicator
   inc oxygenValue                  ; increment oxygen value
.playIncreasingOxygenSound
   lda oxygenValue                  ; get oxygen value
   lsr
   eor #$FF
   sta AUDF0
   clc
   adc #7
   sta AUDF1
   lda #8
   sta AUDC0
   sta AUDC1
   lsr
   sta AUDV0
   sta AUDV1
   lda oxygenValue                  ; get oxygen value
   cmp #MAX_OXYGEN_VALUE
   rts

SwapPlayerVariables
   ldx #6
.swapPlayerVariables
   lda currentPlayerVariables,x
   ldy reservePlayerVariables,x
   sta reservePlayerVariables,x
   sty currentPlayerVariables,x
   dex
   bpl .swapPlayerVariables
   lda currentPlayerNumber          ; get the current player number
   eor #1                           ; flip D0
   sta currentPlayerNumber          ; set new current player number
   rts

SeaFloorReefGraphics
   .byte $FF ; |XXXXXXXX|
   .byte $E7 ; |XXX..XXX|
   .byte $C3 ; |XX....XX|
   .byte $81 ; |X......X|

RetrievedDiverGraphics
   .byte $80 ; |X.......|
   .byte $40 ; |.X......|
   .byte $20 ; |..X.....|
   .byte $F0 ; |XXXX....|
   .byte $18 ; |...XX...|
   .byte $0F ; |....XXXX|
   .byte $0C ; |....XX..|
   .byte $02 ; |......X.|
   .byte $02 ; |......X.|
       
   FILL_BOUNDARY 252, 234

   echo "***", (FREE_BYTES)d, "BYTES OF ROM FREE"
   
   .word Start                      ; RESET vector
   .byte $00, $FD                   ; BRK vector