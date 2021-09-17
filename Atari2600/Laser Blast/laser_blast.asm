   LIST OFF
; ***  L A S E R   B L A S T  ***
; Copyright 1981 Activision, Inc.
; Designer: David Crane

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: August 9, 2019
;
;  *** 122 BYTES OF RAM USED 6 BYTES FREE
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
; - 1 ROM byte free but there is room for more code optimizations
; - looks as though a LeadShip laser delay was going to be implemented
; - Added PAL60 switch to make for an easy PAL60 conversion
; - PAL50 version ~17% slower than NTSC

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
VBLANK_TIME             = 39
OVERSCAN_TIME           = 28

   ELSE
   
FPS                     = 50        ; ~50 frames per second
VBLANK_TIME             = 80
OVERSCAN_TIME           = 46
   
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
DK_GREEN                = $D0

COLOR_LEADSHIP          = ORANGE
COLOR_TANK_LASER        = BLUE

   ELSE
   
YELLOW                  = $20
DK_GREEN                = $30
RED                     = $60
BLUE                    = $B0
   
COLOR_LEADSHIP          = RED
COLOR_TANK_LASER        = BLUE
   
   ENDIF
   
;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_DIGITS                = 8
H_EXPLOSION_GRAPHICS    = 8
H_LEADSHIP              = 8
H_RESERVED_FLEET        = 8
H_TANKS                 = 8
H_TERRAIN_GRAPHICS      = 8
H_TURRET                = 8

W_MOUNTAIN_TERRAIN      = 40        ; number of mountain terrain bits

XMIN                    = 0
XMAX                    = 160

XMIN_LEADSHIP           = XMIN + 15
XMAX_LEADSHIP           = XMAX - 27

YMAX                    = 130

INIT_LEADSHIP_VERT_MIN  = 66
INIT_TANK_GROUP_HORIZ   = 48

INIT_REMOTE_START_TIMER = 30

LEADSHIP_VERTICAL_INCREMENT = 8     ; value to increase vertical minimum each wave
MAX_NUM_LIVES           = 6

MAX_TANK_GROUP_TURRET_VALUE = 2

LEADSHIP_LASER_SLOPE    = 53        ; 256/53...m = ~4.83...~78 degrees

EXPLANATION_POINT_PTR   = (ExplanationPoint - NumberFonts) / H_DIGITS

;
; Lead Ship status values
;
LEADSHIP_SHOT           = %10000000

TANK_DAMAGE_SOUND_VALUE = 30

MAX_LEADSHIP_LASER_TIMER = 0        ; set to implement Lead Ship laser temp

;
; game selection constants
;
GAME_SELECT_CADET       = 0
GAME_SELECT_LIEUTENANT  = 1
GAME_SELECT_CAPTAIN     = 2
GAME_SELECT_COMMANDER   = 3

CADET_MAX_ATTACK_GROUP  = 3
LIEUTENANT_MAX_ATTACK_GROUP = 4
CAPTAIN_MAX_ATTACK_GROUP = 5
COMMANDER_MAX_ATTACK_GROUP = 5

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80
   
gameSelection           ds 1        ; game variation selected
selectDelayTimer        ds 1        ; set but never changes
selectDebounce          ds 1        ; debounce rate for SELECT switch
actionButtonDebounce    ds 1        ; debounce rate for action button
joystickValue           ds 1        ; active player joystick values
zp_Unused_00            ds 1        ; one unused ZP byte
colorEOR                ds 1
hueMask                 ds 1        ; color hue mask value
objectColors            ds 6
;--------------------------------------
scoreColors             = objectColors
;--------------------------------------
player1ScoreColors      = scoreColors; only one actually used
player2ScoreColors      = player1ScoreColors + 1; never referenced 
terrainColor            = player2ScoreColors + 1
skyColor                = terrainColor + 1
leadShipColor           = skyColor + 1
tankColor               = leadShipColor + 1
leadShipVertPos         ds 1        ; vertical position for LeadShip
leadShipHorizPos        ds 1        ; horizontal position for LeadShip
tankBitArray            ds 1        ; array for active Tanks (only D2 - D0 used)
enemyForcesNUSIZValue   ds 1
leadShipAnimationIdx    ds 1        ; LeadShip animation index (only D2 - D0 used)
leadShipLaserSlopeIntegerValue ds 1
tankLaserSlopeIntegerValue ds 1
leadShipLaserSlopFractionValue ds 1
tankLaserSlopeFractionValue ds 1
leadShipLaserHorizDir   ds 1        ; horizontal direction of LeadShip laser
tankLaserHorizDir       ds 1        ; horizontal direction of attacker laser
zp_Unused_01            ds 2
mountainTerrainWidth    ds 1        ; value never changes
mountainTerrainShiftValue ds 1
tankHorizLaserTarget    ds 1
enableEnemyForcesLaserValue ds 1
leadShipLaserHorizDelta ds 1        ; LeadShip laser horizontal delta value
activateEnemyTurretFrequency ds 1
enemyTankMoveFrequency  ds 1
enemyTankLaserFrequency ds 1
remainingLives          ds 1
tankGroupHorizPos       ds 1        ; horizontal position of Tank group
levelTransitionState    ds 1
leadShipVertMin         ds 1        ; LeadShip minimum vertical position
terrainGraphics         ds 48
;--------------------------------------
leftPF0TerrainGraphics  = terrainGraphics
leftPF1TerrainGraphics  = leftPF0TerrainGraphics + H_TERRAIN_GRAPHICS
leftPF2TerrainGraphics  = leftPF1TerrainGraphics + H_TERRAIN_GRAPHICS
rightPF0TerrainGraphics = leftPF2TerrainGraphics + H_TERRAIN_GRAPHICS
rightPF1TerrainGraphics = rightPF0TerrainGraphics + H_TERRAIN_GRAPHICS
rightPF2TerrainGraphics = rightPF1TerrainGraphics + H_TERRAIN_GRAPHICS
scoreGraphicPtrs        ds 12
leadShipGraphicPtrs     ds 2
explosionGraphicPtrs    ds 2
tankGraphicPtrs         ds 2
colorCycleMode          ds 1
frameCount              ds 1
remoteStartTimer        ds 1
playerScore             ds 3
leadShipTurretHeight    ds 1
tankAttackGroup         ds 1
objectDamageStatus      ds 2
;--------------------------------------
leadShipDamageStatus    = objectDamageStatus
tankDamageStatus        = leadShipDamageStatus + 1
enableEnemyTurret       ds 1        ; D1 used to enable / disable turret
objectTimerValues       ds 2
;--------------------------------------
leadShipLaserFrequency  = objectTimerValues
cycleEnemyTankTimer     = leadShipLaserFrequency + 1
extraLifeSoundValue     ds 1
objectLaserValues       ds 2
;--------------------------------------
leadShipLaserValue      = objectLaserValues
tankLaserValue          = leadShipLaserValue + 1
activeEnemyForcesTurret ds 1        ; which Enemy turret is active (0 - 2)
div16Remainder          ds 1
;--------------------------------------
tmpDigitChar            = div16Remainder
;--------------------------------------
tmpShowLeftReservedFleet = tmpDigitChar
;--------------------------------------
tmpTurretTargetDistance = tmpShowLeftReservedFleet
;--------------------------------------
tmpExplosionSoundVolume = tmpTurretTargetDistance
tmpLoopCount            ds 1
;--------------------------------------
tmpShowRightReservedFleet = tmpLoopCount
tmpTankGroupHorizPos    = tmpShowRightReservedFleet
leadShipLaserColor      ds 1

   echo "***",(* - $80 - 3)d, "BYTES OF RAM USED", ($100 - * + 3)d, "BYTES FREE"

;===============================================================================
; R O M - C O D E  (BANK 0)
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
   jsr InitializeGame
MainLoop
   ldx #<[tankColor - objectColors]
.setObjectColors
   lda GameColors,x                 ; read game color table
   eor colorEOR                     ; flip color bits based on color cycling
   and hueMask                      ; mask color values for COLOR / B&W mode
   sta objectColors,x
   cpx #<[leadShipColor - objectColors]
   bcs .nextObjectColor
   sta COLUP0,x
.nextObjectColor
   dex
   bpl .setObjectColors
   lda #THREE_COPIES
   sta NUSIZ0
   sta NUSIZ1
   lda #MSBL_SIZE8 | PF_PRIORITY
   sta CTRLPF
DisplayKernel
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (D1 = 0)
   sta COLUPF                 ; 3 = @06   set playfield color to BLACK
   sta CXCLR                  ; 3 = @09   clear collisions
   sta HMCLR                  ; 3 = @12   clear horizontal motion registers
   sta leadShipLaserHorizDelta; 3         clear LeadShip laser slope run value
   lda #H_DIGITS - 1          ; 2
   sta tmpLoopCount           ; 3
   sta VDELP0                 ; 3 = @23   VDEL GRP0 (D1 = 1)
   sta VDELP1                 ; 3 = @26   VDEL GRP1 (D1 = 1)
.drawDigits
   ldy tmpLoopCount           ; 3
   lda (scoreGraphicPtrs + 10),y;5
   sta tmpDigitChar           ; 3
   lda (scoreGraphicPtrs + 8),y;5
   tax                        ; 2
   lda (scoreGraphicPtrs),y   ; 5
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   sta GRP0                   ; 3 = @05
   lda (scoreGraphicPtrs + 2),y;5
   sta GRP1                   ; 3 = @13
   lda (scoreGraphicPtrs + 4),y;5
   sta GRP0                   ; 3 = @21
   lda (scoreGraphicPtrs + 6),y;5
   ldy tmpDigitChar           ; 3
   sta GRP1                   ; 3 = @32
   stx GRP0                   ; 3 = @35
   sty GRP1                   ; 3 = @38
   sta GRP0                   ; 3 = @41
   dec tmpLoopCount           ; 5
   bpl .drawDigits            ; 2³
   
   IF COMPILE_REGION = PAL50
   
   lda #HMOVE_R8 | THREE_MED_COPIES;2
   
   ELSE
   
   lda #HMOVE_R8              ; 2
   
   ENDIF
   
   sta HMP1                   ; 3 = @53
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #0                     ; 2
   sty VDELP0                 ; 3 = @08
   sty VDELP1                 ; 3 = @11
   sty GRP0                   ; 3 = @14
   sty GRP1                   ; 3 = @17
   
   IF COMPILE_REGION = PAL50
   
   sta NUSIZ0                 ; 3
   sta NUSIZ1                 ; 3
   
   ENDIF
   
   lda leadShipColor          ; 3
   sta COLUP0                 ; 3 = @23
   sta COLUP1                 ; 3 = @26
   
   IF COMPILE_REGION != PAL50
   
   lda #THREE_MED_COPIES      ; 2
   sta NUSIZ0                 ; 3
   sta NUSIZ1                 ; 3
   
   ENDIF
   
   ldx remainingLives         ; 3         get remaining lives
   bpl .setReservedFleetNUSIZ ; 2³
   ldx #0                     ; 2
.setReservedFleetNUSIZ
   lda ReserveFleetNUSIZTable + 1,x;4
   sta NUSIZ0                 ; 3
   sta tmpShowLeftReservedFleet;3
   lda ReserveFleetNUSIZTable,x;4
   sta NUSIZ1                 ; 3
   sta tmpShowRightReservedFleet;3
   ldy #H_RESERVED_FLEET - 1  ; 2
.drawReservedFleet
   sta WSYNC
;--------------------------------------
   lda Spacecraft_01 - 1,y    ; 4
   bit tmpShowLeftReservedFleet;3
   bmi .checkToShowRightReservedFleet;2³
   sta GRP0                   ; 3 = @12
.checkToShowRightReservedFleet
   bit tmpShowRightReservedFleet;3
   bmi .nextReservedFleetLine ; 2³
   sta GRP1                   ; 3 = @20
.nextReservedFleetLine
   dey                        ; 2
   bne .drawReservedFleet     ; 2³
   sta WSYNC
;--------------------------------------
   sty GRP0                   ; 3 = @03
   sty GRP1                   ; 3 = @06
   lda tankLaserValue         ; 3         get Tank laser value
   and hueMask                ; 3
   sta COLUP1                 ; 3 = @15   color Tank laser
   lda frameCount             ; 3         get current frame count
   bit leadShipDamageStatus   ; 3         check if LeadShip hit
   bmi .colorLeadShip         ; 2³        set damaged LeadShip color
   lda leadShipColor          ; 3
.colorLeadShip
   and hueMask                ; 3
   sta COLUP0                 ; 3
   sta WSYNC
;--------------------------------------
   sty leadShipLaserSlopeIntegerValue;3   reset LeadShip laser slope integer
   sty tankLaserSlopeIntegerValue;3       reset Tank laser slope integer
   sty NUSIZ0                 ; 3 = @09   set to ONE_COPY (i.e. y = 0)
   sty NUSIZ1                 ; 3 = @12   set to ONE_COPY (i.e. y = 0)
   ldy #LOCK_MISSILE | ENABLE_BM;2
   sty RESMP0                 ; 3 = @17
   sty ENABL                  ; 3 = @20
   lda leadShipLaserValue     ; 3
   and #$0F                   ; 2
   bne .enableOrDisableLeadShipLaser;2³
   ldy #DISABLE_BM            ; 2
.enableOrDisableLeadShipLaser
   sty ENAM0                  ; 3
   ldy #ENABLE_BM             ; 2
   lda tankLaserValue         ; 3         get Tank laser value
   and #$0F                   ; 2
   bne .enableOrDisableEnemyForcesLaser;2³
   ldy #DISABLE_BM            ; 2
.enableOrDisableEnemyForcesLaser
   sty enableEnemyForcesLaserValue;3
   lda leadShipLaserValue     ; 3
   and hueMask                ; 3
   sta leadShipLaserColor     ; 3
   lda leadShipHorizPos       ; 3         get LeadShip horizontal position
   ldx #<[HMP0 - HMP0]        ; 2
   jsr CalculateObjectHorizPosition;6     horizontally position LeadShip
;--------------------------------------
   ldx #<[HMM1 - HMP0]        ; 2
   lda tankHorizLaserTarget   ; 3
   clc                        ; 2
   adc #4                     ; 2
   jsr CalculateObjectHorizPosition;6     horizontally position Tank laser
;--------------------------------------
   lda tankGroupHorizPos      ; 3         get Tank group horizontal position
   and #1                     ; 2         keep D0 value
   asl                        ; 2         multiply value by 8 (i.e. H_TANKS)
   asl                        ; 2
   asl                        ; 2
   adc #<TankSprites          ; 2
   sta tankGraphicPtrs        ; 3
   sec                        ; 2
   lda mountainTerrainWidth   ; 3         get mountain terrain width
   sbc mountainTerrainShiftValue;3        subtract scrolling value
   asl                        ; 2         multiply difference by 4
   asl                        ; 2
   clc                        ; 2
   adc tankGroupHorizPos      ; 3
   ldx tankBitArray           ; 3         get active Tank array value
   clc                        ; 2
   adc EnemyTanksHorizOffsetValues,x;4    increment horizontal position
   tay                        ; 2         set y register to horizontal position
   lda EnemyTankNUSIZValues,x ; 4
   cpy #(XMAX / 2) + 16       ; 2
   bcc .determineShowingOneTank;2³
   and #$C0 | MSBL_SIZE8 | TWO_MED_COPIES;2
.determineShowingOneTank
   cpy #(XMAX - 48) + 16      ; 2
   bcc .setEnemyTankNUSIZValue; 2³
   and #$C0 | MSBL_SIZE8 | ONE_COPY;2
.setEnemyTankNUSIZValue
   sta enemyForcesNUSIZValue  ; 3
   tya                        ; 2
   cmp #XMAX                  ; 2
   bcc .horizontallyPositionEnemyTanks;2³
   lda #XMIN                  ; 2
.horizontallyPositionEnemyTanks
   sta tmpTankGroupHorizPos   ; 3
   ldx #<[HMP1 - HMP0]        ; 2
   jsr CalculateObjectHorizPosition;6     horizontally position Enemy Forces
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda tmpTankGroupHorizPos   ; 3
   cmp #134                   ; 2
   bcs .clearTurretTargetDistance;2³
   sta WSYNC
;--------------------------------------
.clearTurretTargetDistance
   dex                        ; 2         x = 0
   stx tmpTurretTargetDistance; 3
   lda enableEnemyForcesLaserValue;3
   sta ENAM1                  ; 3 = @11
   sta WSYNC
;--------------------------------------
   lda leadShipDamageStatus   ; 3         get LeadShip damage status value
   and #2                     ; 2         isolate D1 bit
   lsr                        ; 2         divide by 2
   eor #1                     ; 2
   ora #YMAX + H_LEADSHIP     ; 2
   tax                        ; 2
.drawLeadShipKernel
   clc                        ; 2
   lda tankLaserSlopeIntegerValue;3       get slope integer value
   adc tankLaserSlopeFractionValue;3      increment by laser slope fraction
   sta tankLaserSlopeIntegerValue;3       set new slope integer value
   sta HMCLR                  ; 3
   bcc .checkToDrawLeadShip   ; 2³        branch if not time to alter position
   lda tankLaserHorizDir      ; 3
   sta HMM1                   ; 3
.checkToDrawLeadShip
   txa                        ; 2         move scan line value to accumulator
   sec                        ; 2
   sbc leadShipVertPos        ; 3         subtract LeadShip vertical position
   bcc .doneDrawLeadShipKernel; 2³
   tay                        ; 2         use difference as graphic index
   and #~(H_LEADSHIP - 1)     ; 2
   beq .drawLeadShip          ; 2³
   ldy #H_LEADSHIP - 1        ; 2
.drawLeadShip
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (leadShipGraphicPtrs),y; 5
   sta GRP0                   ; 3 = @11
   dex                        ; 2
   bne .drawLeadShipKernel    ; 3         unconditional branch
   
.doneDrawLeadShipKernel
   lda #UNLOCK_MISSILE        ; 2
   sta RESMP0                 ; 3
   ldy leadShipTurretHeight   ; 3         get LeadShip turret height value
.drawLeadShipLaserKernel
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   dey                        ; 2
   bne .checkLeadShipLaserReachingHorizLimit;2³
   sty GRP0                   ; 3 = @10   stop drawing LeadShip turret
   lda leadShipLaserColor     ; 3
   sta COLUP0                 ; 3 = @16
   jmp .determineAttackLaserSlopeRunValue;3
       
.checkLeadShipLaserReachingHorizLimit
   bit CXM0FB                 ; 3         check LeadShip laser collision
   bvc .determineAttackLaserSlopeRunValue;2³ branch if within horizontal range
   lda #DISABLE_BM            ; 2
   sta ENAM0                  ; 3         disable LeadShip laser
.determineAttackLaserSlopeRunValue
   clc                        ; 2
   lda tankLaserSlopeIntegerValue;3       get slope integer value
   adc tankLaserSlopeFractionValue;3      increment by laser slope fraction
   sta tankLaserSlopeIntegerValue;3       set new slope integer value
   sta HMCLR                  ; 3 = @32
   bcc .determineLeadShipLaserSlopeRunValue;2³
   lda tankLaserHorizDir      ; 3
   sta HMM1                   ; 3
.determineLeadShipLaserSlopeRunValue
   clc                        ; 2
   lda leadShipLaserSlopeIntegerValue;3   get slope integer value
   adc leadShipLaserSlopFractionValue;3   increment by laser slope fraction
   sta leadShipLaserSlopeIntegerValue;3   set new slope integer value
   bcc .nextLeadShipLaserScanline;2³
   lda leadShipLaserHorizDir  ; 3
   sta HMM0                   ; 3
   sta HMP0                   ; 3
   inc leadShipLaserHorizDelta; 5         update laser horizontal delta value
.nextLeadShipLaserScanline
   dex                        ; 2
   bne .drawLeadShipLaserKernel;2³
   ldy #H_TURRET - 1          ; 2
.drawActiveTurret
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #MSBL_SIZE2 | ONE_COPY ; 2
   sta NUSIZ1                 ; 3 = @08   set NUSIZ for turret
   lda enableEnemyTurret      ; 3         get enabling enemy turret value
   sta ENAM1                  ; 3 = @14   set to enable / disable turret
   lda tankColor              ; 3         get Tank color value
   sta COLUP1                 ; 3 = @20   set to color active turret
   clc                        ; 2
   lda leadShipLaserSlopeIntegerValue;3   get slope integer value
   adc leadShipLaserSlopFractionValue;3   increment by laser slope fraction
   sta leadShipLaserSlopeIntegerValue;3   set new slope integer value
   sta HMCLR                  ; 3 = @34
   bcc .determineTurretSlopeRunValue;2³
   lda leadShipLaserHorizDir  ; 3
   sta HMM0                   ; 3 = @41
   sta HMP0                   ; 3 = @44
.determineTurretSlopeRunValue
   clc                        ; 2
   lda tankLaserSlopeIntegerValue;3       get slope integer value
   adc tankLaserSlopeFractionValue;3      increment by laser slope fraction
   sta tankLaserSlopeIntegerValue;3       set new slope integer value
   bcc .nextTurretScanline    ; 2³
   lda tankLaserHorizDir      ; 3
   sta HMM1                   ; 3 = @63   set HMOVE for slope run value
.nextTurretScanline
   dey                        ; 2
   bpl .drawActiveTurret      ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #$3C                   ; 2
   sta GRP1                   ; 3 = @08   draw top of Tanks
   stx ENAM0                  ; 3 = @11
   stx ENAM1                  ; 3 = @14
   lda terrainColor           ; 3
   sta COLUPF                 ; 3 = @20
   lda enemyForcesNUSIZValue  ; 3
   sta NUSIZ1                 ; 3 = @26
   lda scoreColors            ; 3
   sta COLUP0                 ; 3 = @32
   lda #MSBL_SIZE8 | PF_NO_REFLECT;2
   sta CTRLPF                 ; 3
   bit CXM0FB                 ; 3         check LeadShip laser collision
   bvc .drawEnemyForcesKernel ; 2³        branch if didn't reach horizontal limit
   lda #<Blank                ; 2
   sta explosionGraphicPtrs   ; 3         clear explosion graphics LSB value
.drawEnemyForcesKernel
   ldy #H_TANKS - 1           ; 2
.drawEnemyForces
   lda (tankGraphicPtrs),y    ; 5
   tax                        ; 2
   lda (explosionGraphicPtrs),y;5
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta GRP0                   ; 3 = @06
   stx GRP1                   ; 3 = @09
   lda leftPF0TerrainGraphics,y;4
   sta PF0                    ; 3 = @16
   lda leftPF1TerrainGraphics,y;4
   sta PF1                    ; 3 = @23
   lda leftPF2TerrainGraphics,y;4
   sta PF2                    ; 3 = @30
   lda rightPF0TerrainGraphics,y;4
   sta PF0                    ; 3 = @37
   lda rightPF1TerrainGraphics,y;4
   sta PF1                    ; 3 = @44
   lda rightPF2TerrainGraphics,y;4
   sta PF2                    ; 3 = @51
   sta HMCLR                  ; 3 = @54   clear horizontal motion registers
   dey                        ; 2
   bpl .drawEnemyForces       ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda leadShipDamageStatus   ; 3         get LeadShip damage status value
   and #2                     ; 2         isolate D1 value
   lsr                        ; 2         divide by 2
   ora #6                     ; 2
   tax                        ; 2         set index for ground shaking
.drawTerrainGround
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sty PF0                    ; 3 = @06
   sty PF1                    ; 3 = @09
   sty PF2                    ; 3 = @12
   dex                        ; 2
   bpl .drawTerrainGround     ; 2³
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta RESBL                  ; 3 = @06
   inx                        ; 2         x = 0
   stx PF0                    ; 3 = @11   clear playfield graphic registers
   stx PF1                    ; 3 = @14
   stx PF2                    ; 3 = @17
   stx COLUPF                 ; 3 = @20   set playfield color to BLACK
   inx                        ; 2         x = 1 (i.e. TWO_COPIES)
   stx NUSIZ0                 ; 3 = @25
   sta RESP0                  ; 3 = @28
   sta RESP1                  ; 3 = @31
   stx NUSIZ1                 ; 3 = @34
   lda #HMOVE_L3              ; 2
   sta HMCLR                  ; 3 = @39
   sta HMBL                   ; 3 = @42
   lsr                        ; 2
   sta HMP1                   ; 3 = @47
   lda scoreColors            ; 3
   sta COLUP1                 ; 3 = @53
   ldx #H_DIGITS - 1          ; 2
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
   lda #OVERSCAN_TIME
   
   IF COMPILE_REGION = PAL50
   
   sta WSYNC
   sta VBLANK
   
   ENDIF
   
   sta TIM64T
   lda leadShipDamageStatus         ; get LeadShip damage status value
   cmp #1
   bne BCD2Digits
   jsr ResetPlayerInfo
   dec remainingLives               ; reduce number of lives
   bpl BCD2Digits
   inc remoteStartTimer
BCD2Digits
   ldx #2
.bcd2DigitLoop
   txa                              ; move x to accumulator
   asl                              ; multiply the value by 4 so it can
   asl                              ; be used for the graphicPointers indexes
   tay
   lda playerScore,x                ; get the player's score
   and #$F0                         ; mask the lower nybble
   lsr                              ; divide the value by 2
   sta scoreGraphicPtrs,y           ; set LSB pointer to digit
   lda playerScore,x                ; get the player's score
   and #$0F                         ; mask the upper nybbles
   asl                              ; multiply value by 8
   asl
   asl
   sta scoreGraphicPtrs + 2,y       ; set LSB pointer to digit
   dex
   bpl .bcd2DigitLoop
   ldx #<[tankLaserValue - leadShipLaserValue]
.setAudioValuesFromObjectStates
   lda objectLaserValues,x          ; get object laser value
   and #$0F
   beq .decrementObjectTimers
   dec objectLaserValues,x
.decrementObjectTimers
   lda objectTimerValues,x
   beq .reduceObjectDamageValue
   dec objectTimerValues,x
.reduceObjectDamageValue
   lda objectDamageStatus,x         ; get object damage status value
   beq .setObjectLaserVolume        ; branch if object not damaged
   bmi .setObjectLaserVolume        ; branch if LeadShip shot by laser
   dec objectDamageStatus,x         ; decrement object damage value
.setObjectLaserVolume
   lda objectLaserValues,x          ; get object laser value
   and #$0F
   sta AUDV0,x                      ; set volume for object laser
   cpx #<[objectLaserValues - leadShipLaserValue]
   bne .setObjectLaserAudioValues   ; branch if processing Tank laser value
   tay
   bne .determineExplosionGraphicAnimation
   lda #<Blank
   bne .setExplosionGraphicLSBValue ; unconditional branch
       
.determineExplosionGraphicAnimation
   and #(H_EXPLOSION_GRAPHICS * 3) >> 1
   asl
   adc #<ExplosionGraphics
.setExplosionGraphicLSBValue
   sta explosionGraphicPtrs
   tya                              ; restore laser value to accumulator
.setObjectLaserAudioValues
   eor #$0F
   adc LaserAudioFrequencyOffset,x
   sta AUDF0,x
   lda #15
   sta AUDC0,x                      ; set audio channel value for laser
   dex
   bpl .setAudioValuesFromObjectStates
   lda extraLifeSoundValue          ; get extra life sound value
   beq PlayObjectDamagedSounds      ; branch if not playing extra life sounds
   dec extraLifeSoundValue          ; decrement extra life sound value
   lda extraLifeSoundValue          ; get extra life sound value
   and #3
   bne SuppressLeadingZeros         ; sounds updated every 4th frame
   lda #12
   sta AUDV0
   sta AUDC0
   bne .setObjectDamagedSoundFrequency; unconditional branch
       
PlayObjectDamagedSounds
   lda tankDamageStatus             ; get Tank damage status value
   bne .playExplosionSounds         ; branch if Tank damaged
   lda leadShipDamageStatus         ; get LeadShip damage status value
   beq SuppressLeadingZeros         ; branch if LeadShip not damaged
   bpl .playExplosionSounds         ; branch if LeadShip exploding
   ldy #2
   sty AUDV0                        ; set sound volume for damaged LeadShip
   lda #4
   sta AUDC0                        ; set audio channel for damaged LeadShip
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   php                              ; push D0 value to stack
   sec
   lda #YMAX
   sbc leadShipVertPos
   lsr
   lsr
   lsr
   plp
   adc #15
   bne .setObjectDamagedSoundFrequency; unconditional branch
   
.playExplosionSounds
   lsr                              ; divide LeadShip damage status by 2
   sta tmpExplosionSoundVolume
   sta AUDV0                        ; set explosion sound register value
   and #3
   ora #8
   sta AUDC0                        ; set explosion sound channel value
   lda #16
   sec
   sbc tmpExplosionSoundVolume
   ora #16
.setObjectDamagedSoundFrequency
   sta AUDF0
SuppressLeadingZeros
   inx                              ; x = 0
.suppressLeadingZeros
   lda scoreGraphicPtrs,x           ; get score graphic pointer LSB value
   cmp #<zero
   bne DetermineLeadShipGraphics
   lda #<Blank
   sta scoreGraphicPtrs,x           ; suppress leading zeros
   inx
   inx
   cpx #9
   bcc .suppressLeadingZeros
DetermineLeadShipGraphics
   lda #<Blank
   ldy remoteStartTimer             ; get remote start timer value
   bne .setLeadShipGraphicLSB
   lda frameCount                   ; get current frame count
   lsr                              ; shift D0 to carry
   bcs VerticalSync                 ; branch on odd frame
   inc leadShipAnimationIdx         ; incement LeadShip animation index
   lda leadShipAnimationIdx         ; get LeadShip animation index
   cmp #3
   bcc .animateLeadShipGraphics
   lda #0
   sta leadShipAnimationIdx         ; reset LeadShip animation index
.animateLeadShipGraphics
   asl                              ; multiply animation index by 8
   asl
   asl
   adc #<SpacecraftSprites          ; add in SpacecraftSprites LSB
.setLeadShipGraphicLSB
   sta leadShipGraphicPtrs
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   ldy #DUMP_PORTS | DISABLE_TIA | START_VERT_SYNC
   sty WSYNC
   
   IF COMPILE_REGION != PAL50
   
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
   sty colorEOR
   asl colorEOR
   sta hueMask
   lda #VBLANK_TIME
   sta WSYNC                        ; wait for next scan line
   sta TIM64T                       ; set timer for vertical blanking period
   lda selectDelayTimer
   beq .setGameSelection
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForSelectPressed
.restartGame
   ldx #<colorCycleMode
   jmp RestartGame
   
.checkForSelectPressed
   ldy #0
   lsr                              ; shift SELECT to carry
   bcs .setSelectDebounceRate       ; branch if SELECT not pressed
   lda selectDebounce               ; get select debounce value
   beq .incrementGameSelection      ; increment game selection if zero
   dec selectDebounce               ; decrement select debounce rate
   bpl .setJoystickValue
.incrementGameSelection
   inc gameSelection
.setGameSelection
   lda gameSelection                ; get current game selection
   and #3                           ; make sure value does not go over 3
   sta gameSelection
   tay                              ; move game selection to y register
   iny                              ; increment value to display game selection
   sty playerScore + 2              ; place game selection in player score
   lda #0
   sta leadShipDamageStatus
   sta colorCycleMode               ; reset color cycle mode
   sta playerScore
   sta playerScore + 1
   ldy #INIT_REMOTE_START_TIMER
   sty remoteStartTimer
   sty selectDelayTimer
.setSelectDebounceRate
   sty selectDebounce
.setJoystickValue
   lda SWCHA                        ; read joystick values
   tay                              ; move value to y register
   lsr                              ; shift player 1 joystick values
   lsr
   lsr
   lsr
   sta joystickValue                ; set joystick value
   iny
   beq .checkToRemotelyRestartGame  ; branch if joystick not moved
   lda #0
   sta colorCycleMode               ; reset color cycling mode value if moved
.checkToRemotelyRestartGame
   lda remoteStartTimer             ; get remote start timer value
   beq .checkLeadShipCollidingWithTank; branch if not looking for remote start
   lda joystickValue                ; get joystick value
   lsr                              ; shift MOVE_UP to carry
   bcc .restartGame                 ; branch if joystick set to MOVE_UP
   jmp MainLoop
       
.checkLeadShipCollidingWithTank
   lda CXPPMM                       ; get player missile collision values
   eor #$80                         ; flip player collision values
   ora leadShipDamageStatus         ; combine with LeadShip damage value
   bpl IncrementScore               ; branch if LeadShip collided with Tank
.determineAttackGroupFrequency
   jmp .determineAttackGroupFrequencyValues

IncrementScore
   lda levelTransitionState         ; get level transition state
   bne .determineAttackGroupFrequency; branch if moving terrain
   ldy playerScore + 1              ; keep score hundreds value
   sec
   lda leadShipVertMin              ; get LeadShip minimum vertical position
   sbc #INIT_LEADSHIP_VERT_MIN - 8
   asl
   sed
   ldx #2
.incrementScore
   adc playerScore,x
   sta playerScore,x
   lda #0
   dex
   bpl .incrementScore
   cld
   bcc .checkForEarningExtraLife
   lda #EXPLANATION_POINT_PTR << 4 | EXPLANATION_POINT_PTR; player maxed score
   sta playerScore
   sta playerScore + 1
   sta playerScore + 2
   sta remoteStartTimer
.checkForEarningExtraLife
   lda #TANK_DAMAGE_SOUND_VALUE
   sta tankDamageStatus
   tya                              ; move score hundreds value to accumulator
   eor playerScore + 1              ; flip bits with current hundreds value
   and #$F0                         ; keep thousands value
   beq DetermineTankToRemove        ; branch if not reached extra life
   lda remainingLives               ; get remaining lives
   cmp #MAX_NUM_LIVES
   bcs DetermineTankToRemove
   lda #63
   sta extraLifeSoundValue
   inc remainingLives
DetermineTankToRemove
   lda leadShipLaserHorizDelta      ; get LeadShip laser horizontal delta value
   bit leadShipLaserHorizDir        ; check direction of LeadShip laser
   bmi .determineTankToRemove       ; branch if laser traveling right
   eor #$FF                         ; negate laser horizontal delta value
   clc
   adc #1
.determineTankToRemove
   clc
   adc leadShipHorizPos             ; increment by LeadShip horizontal position
   clc
   adc #48
   sec
   sbc tankGroupHorizPos
   sec
   sbc #36
   lsr
   lsr
   lsr
   lsr
   lsr
   tay
   lda tankBitArray                 ; get active Tank array value
   and TankGroupBitMaskingValues,y
   sta tankBitArray
   bne .determineAttackGroupFrequencyValues
   sta mountainTerrainShiftValue    ; clear mountain terrain scroll value
   lda #7
   sta tankBitArray
   lda #W_MOUNTAIN_TERRAIN
   sta mountainTerrainWidth
   lda leadShipVertMin              ; get LeadShip minimum vertical position
   cmp #YMAX
   bcs DetermineAttackGroupDifficulty
   adc #LEADSHIP_VERTICAL_INCREMENT
   sta leadShipVertMin
DetermineAttackGroupDifficulty
   ldx gameSelection                ; get current game selection
.determineAttackGroup
   lda tankAttackGroup
   cmp GameSelectionMaxAttackGroup,x
   bcs .determineAttackGroupFrequencyValues
   inc tankAttackGroup
   cpx #GAME_SELECT_COMMANDER
   beq .determineAttackGroup        ; branch if set to Commander Level
.determineAttackGroupFrequencyValues
   ldx tankAttackGroup
   lda EnemyTankGroupTurretFrequency,x
   sta activateEnemyTurretFrequency
   lda EnemyTankGroupMovementFrequency,x
   sta enemyTankMoveFrequency
   bit CXM1P                        ; check missile 1 collisions
   bpl .checkForLeadShipDamage      ; branch if LeadShip not shot
   lda #LEADSHIP_SHOT
   sta leadShipDamageStatus         ; set to show LeadShip damaged by laser
   sta leadShipLaserValue
.checkForLeadShipDamage
   ldy #63
   lda leadShipDamageStatus         ; get LeadShip damage status value
   beq CheckForActionButton         ; branch if LeadShip not damaged
   sty cycleEnemyTankTimer          ; set timer for cycling enemy Tanks
   bpl .setLeadShipExplosionGraphics; branch if LeadShip exploding
   dec leadShipVertPos              ; move LeadShip down
   lda leadShipVertPos              ; get LeadShip vertical position
   cmp #3
   bcs CheckForActionButton
   lda #30
   sta leadShipDamageStatus
.setLeadShipExplosionGraphics
   and #H_EXPLOSION_GRAPHICS * 3    ; 4 frames of exposion animation
   clc
   adc #<ExplosionGraphics
   sta explosionGraphicPtrs
   lda #<Blank
   sta leadShipGraphicPtrs
CheckForActionButton
   lda INPT4                        ; read left port action button
   and #$80
   cmp actionButtonDebounce         ; compare with last frame value
   sta actionButtonDebounce         ; set new action button value
   beq CheckForPlayerFiringLaser
   cmp #0
   beq CheckForPlayerFiringLaser    ; branch if action button pressed
   lda levelTransitionState         ; get level transition state
   bne CheckForPlayerFiringLaser    ; branch if moving terrain
   lda leadShipLaserFrequency
   bne CheckForPlayerFiringLaser    ; branch if can't fire LeadShip laser
   lda #0                           ; not needed...accumulator 0
   sta colorCycleMode               ; clear color cycle mode value
   lda leadShipDamageStatus         ; get LeadShip damage status value
   bne CheckForPlayerFiringLaser    ; branch if LeadShip damaged
   lda #COLOR_LEADSHIP + 15
   sta leadShipLaserValue
   lda #MAX_LEADSHIP_LASER_TIMER
   sta leadShipLaserFrequency
CheckForPlayerFiringLaser
   lda #1
   sta leadShipTurretHeight         ; set to not draw LeadShip turret
   lda leadShipDamageStatus         ; get LeadShip damage status value
   bne CheckToMoveLeadShip          ; branch if LeadShip damaged
   lda leadShipLaserValue
   and #$0F
   bne .setLeadShipVerticalBoundary
   ldy #HMOVE_0
   lda INPT4                        ; read left port action button
   bmi CheckToMoveLeadShip          ; branch if button not pressed
   lda #10
   sta leadShipTurretHeight         ; set to draw LeadShip turret
   lda joystickValue                ; get joystick value
   lsr
   lsr
   lsr
   bcs .checkForFiringLaserRight    ; branch if not MOVE_LEFT
   ldy #HMOVE_L1
   ldx #LEADSHIP_LASER_SLOPE
.checkForFiringLaserRight
   lsr
   bcs .setLeadShipLaserSlopeValues
   ldy #HMOVE_R1
   ldx #LEADSHIP_LASER_SLOPE
.setLeadShipLaserSlopeValues
   sty leadShipLaserHorizDir
   stx leadShipLaserSlopFractionValue
   jmp DetermineToFireTankLaser
       
CheckToMoveLeadShip
   lda joystickValue                ; get current joystick value
   ldy leadShipDamageStatus         ; get LeadShip damage status value
   beq .checkToMoveLeadShipUp       ; branch if LeadShip not damaged
   bpl .setLeadShipHoizontalBoundaries; branch if LeadShip exploding
   ora #P1_HORIZ_MOVE               ; set to not allow vertical motion
.checkToMoveLeadShipUp
   lsr                              ; shift MOVE_UP to carry
   bcs .checkToMoveLeadShipDown     ; branch if not moving up
   inc leadShipVertPos              ; move LeadShip up
.checkToMoveLeadShipDown
   lsr                              ; shift MOVE_DOWN to carry
   bcs .checkToMoveLeadShipLeft
   dec leadShipVertPos              ; move LeadShip down
.checkToMoveLeadShipLeft
   lsr                              ; shift MOVE_LEFT to carry
   bcs .checkToMoveLeadShipRight
   dec leadShipHorizPos             ; move LeadShip left
.checkToMoveLeadShipRight
   lsr                              ; shift MOVE_RIGHT to carry
   bcs .setLeadShipVerticalBoundary
   inc leadShipHorizPos             ; move LeadShip right
.setLeadShipVerticalBoundary
   ldy leadShipDamageStatus         ; get LeadShip damage status value
   bne .setLeadShipHoizontalBoundaries; branch if LeadShip damaged
   lda #YMAX
   cmp leadShipVertPos
   bcc .setLeadShipVerticalPosition
   lda leadShipVertMin              ; get LeadShip minimum vertical position
   cmp leadShipVertPos
   bcc .setLeadShipHoizontalBoundaries; branch if within verical boundaries
.setLeadShipVerticalPosition
   sta leadShipVertPos
.setLeadShipHoizontalBoundaries
   lda #XMAX_LEADSHIP
   cmp leadShipHorizPos             ; compare with LeadShip horizontal position
   bcc .setLeadShipHorizontalPosition
   lda #XMIN_LEADSHIP
   cmp leadShipHorizPos             ; compare with LeadShip horizontal position
   bcc DetermineToFireTankLaser
.setLeadShipHorizontalPosition
   sta leadShipHorizPos
DetermineToFireTankLaser
   lda levelTransitionState         ; get level transition state
   bne .determineAttackerLaserDirection; branch if moving terrain
   bit colorCycleMode               ; check color cycle mode
   bmi .determineAttackerLaserDirection; branch if cycling colors
   lda cycleEnemyTankTimer          ; get cycle enemy Tank value
   bne .determineAttackerLaserDirection; branch if not time to cycle enemy Tank
   lda frameCount                   ; get current frame count
   and activateEnemyTurretFrequency
   bne .determineAttackerLaserDirection; branch if not time to activate turret
   lda enemyTankLaserFrequency      ; get Tank laser frequency value
   bne .determineAttackerLaserDirection; branch if laser on lock
.cycleActiveEnemyForcesTurretValue
   inc activeEnemyForcesTurret      ; increment Enemy Forces turret value
   lda activeEnemyForcesTurret      ; get active Enemy Forces turret value
   cmp #MAX_TANK_GROUP_TURRET_VALUE + 1
   bcc .determineIfTankActive
   lda #0
   sta activeEnemyForcesTurret      ; reset active Enemy Forces turret value
.determineIfTankActive
   jsr DetermineIfActiveEnemyDestroyed
   beq .cycleActiveEnemyForcesTurretValue; branch if active enemy destroyed
   lda leadShipHorizPos             ; get LeadShip horizontal position
   sta tankHorizLaserTarget         ; set Tank horizontal target
   lda #31
   sta enemyTankLaserFrequency
   sta enableEnemyTurret            ; set to enable turret (i.e. D1 = 1)
.determineAttackerLaserDirection
   lda activeEnemyForcesTurret      ; get active Enemy Forces turret value
   asl                              ; multiply value by 32
   asl
   asl
   asl
   asl
   adc tankGroupHorizPos            ; add in Tank group horizontal position
   ldy #HMOVE_R1                    ; assume LeadShip to the right
   sec
   sbc tankHorizLaserTarget         ; subtract target position
   bpl .determineAttackerLaserSlopeValue
   ldy #HMOVE_L1                    ; LeadShip to the left of Enemy Forces
   eor #$FF                         ; get absolute value of subtraction
   clc
   adc #1
.determineAttackerLaserSlopeValue
   sta tmpTurretTargetDistance
   lsr                              ; divide distance by 4
   lsr
   clc
   adc tmpTurretTargetDistance      ; add back in distance
   lsr tmpTurretTargetDistance      ; divide distance by 2
   adc tmpTurretTargetDistance      ; add to previous division
   sta tankLaserSlopeFractionValue  ; slope calculated as 7x/4
   sty tankLaserHorizDir
   jsr DetermineIfActiveEnemyDestroyed
   bne CheckToMoveEnemyTanks        ; branch if active enemy not destroyed
   sta enableEnemyTurret            ; set to disable turret (i.e. D1 = 0)
   sta tankLaserValue               ; set Tank laser value
   sta enemyTankLaserFrequency      ; clear Tank laser frequency
CheckToMoveEnemyTanks
   lda frameCount                   ; get current frame count
   and enemyTankMoveFrequency
   bne .checkToFireTankLaser        ; branch if not time to move Tanks
   lda leadShipDamageStatus         ; get LeadShip damage status value
   bne .checkToFireTankLaser        ; branch if LeadShip damaged
   lda tankBitArray                 ; get active Tank array value
   ldy leadShipHorizPos             ; get LeadShip horizontal position
   cpy #XMAX / 2                    ; compare with center of screen
   bcc .determineTankGroupHorizDirection; branch if on left side of screen
   ora #8                           ; or with 8 for right side values
.determineTankGroupHorizDirection
   tax
   sec
   tya                              ; set accumulator to LeadShip position
   sbc EnemyForcesLeadShipOffsetValues - 1,x
   sec
   sbc tankGroupHorizPos
   beq .checkToFireTankLaser
   bmi .moveEnemyForcesLeft
   inc tankGroupHorizPos
   inc tankGroupHorizPos
.moveEnemyForcesLeft
   dec tankGroupHorizPos
.checkToFireTankLaser
   lda enemyTankLaserFrequency      ; get Tank laser frequency value
   beq .checkToScrollMountainTerrain
   dec enemyTankLaserFrequency
   lda enemyTankLaserFrequency      ; get Tank laser frequency value
   cmp #15
   bne .checkToScrollMountainTerrain
   lda #COLOR_TANK_LASER + 15
   sta tankLaserValue
.checkToScrollMountainTerrain
   lda mountainTerrainWidth         ; get mountain terrain width
   eor mountainTerrainShiftValue    ; flip mountain terrain scroll value bits
   sta levelTransitionState         ; set level transition state
   beq .jmpToMainLoop               ; branch if done scrolling terrain
   lda #INIT_TANK_GROUP_HORIZ
   sta tankGroupHorizPos
   ldy #0
   sty enableEnemyTurret            ; set to disable turret (i.e. D1 = 0)
   sty tankLaserValue               ; set Tank laser value
   sty enemyTankLaserFrequency
   sty leadShipLaserFrequency
   lda activateEnemyTurretFrequency
   lsr
   lsr
   lsr
   lsr
   lsr
   and frameCount
   bne .jmpToMainLoop
   inc mountainTerrainShiftValue    ; increment mountain terrain scroll value
   lda leadShipDamageStatus         ; get LeadShip damage status value
   beq ScrollMountainTerrain        ; branch if LeadShip not damaged
   lda leadShipHorizPos             ; get LeadShip horizontal position
   sec
   sbc #4
   sta leadShipHorizPos             ; set LeadShip horizontal position
ScrollMountainTerrain
   ldx #H_TERRAIN_GRAPHICS - 1
.scrollMountainTerrain
   lda leftPF0TerrainGraphics,x     ; get left PF0 graphic data
   and #$10                         ; keep D4 value
   cmp #$10
   ror rightPF2TerrainGraphics,x
   rol rightPF1TerrainGraphics,x
   ror rightPF0TerrainGraphics,x
   lda rightPF0TerrainGraphics,x
   and #8
   cmp #8
   ror leftPF2TerrainGraphics,x
   rol leftPF1TerrainGraphics,x
   ror leftPF0TerrainGraphics,x
   dex
   bpl .scrollMountainTerrain
.jmpToMainLoop
   jmp MainLoop

InitializeGame
   ldx #17
   lda #>GameSpriteData
.setGraphicPointerMSBValues
   sta scoreGraphicPtrs,x
   dex
   dex
   bpl .setGraphicPointerMSBValues
   ldx #48
.setTerrainGraphicRAMData
   ldy #H_TERRAIN_GRAPHICS - 1
.internalSetTerrainGraphicRAMData
   lda TerrainGraphicData,y
   sta terrainGraphics - 1,x
   dex
   dey
   bpl .internalSetTerrainGraphicRAMData
   txa
   bne .setTerrainGraphicRAMData
   stx mountainTerrainShiftValue    ; clear mountain terrain scroll value
   jmp ContinueInitializeGame

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
   asl
   asl
   asl
   sta HMP0,x                       ; set object's fine motion value
   sta WSYNC                        ; wait for next scan line
.coarseMoveObject
   dey
   bpl .coarseMoveObject
   sta RESP0,x                      ; set object's coarse position
   rts

DetermineIfActiveEnemyDestroyed
   ldx activeEnemyForcesTurret      ; get active Enemy Forces turret value
   lda TankGroupBitMaskingValues,x  ; get bit masking values
   eor #7                           ; flip bits D2 - D0
   and tankBitArray                 ; mask with Tank array value
   rts

GameSelectionMaxAttackGroup
   .byte CADET_MAX_ATTACK_GROUP, LIEUTENANT_MAX_ATTACK_GROUP
   .byte CAPTAIN_MAX_ATTACK_GROUP, COMMANDER_MAX_ATTACK_GROUP
       
EnemyTankGroupMovementFrequency
   .byte $0F ; |....XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   .byte $01 ; |.......X|
   
EnemyTanksHorizOffsetValues
   .byte 0, 64, 32, 32, 0, 0, 0, 0
   
TankGroupBitMaskingValues
   .byte 3, 5, 6
       
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

GameSpriteData
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

ExplanationPoint
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|

Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
;
; last three bytes shared with table below
;
ExplosionGraphics
Explosion_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
Explosion_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $20 ; |..X.....|
   .byte $81 ; |X......X|
   .byte $04 ; |.....X..|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
Explosion_02
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $10 ; |...X....|
   .byte $42 ; |.X....X.|
   .byte $08 ; |....X...|
   .byte $40 ; |.X......|
   .byte $00 ; |........|
   .byte $00 ; |........|
Explosion_03
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $42 ; |.X....X.|
   .byte $08 ; |....X...|
   .byte $20 ; |..X.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
SpacecraftSprites
Spacecraft_00
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $B6 ; |X.XX.XX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Spacecraft_01
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Spacecraft_02
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $6D ; |.XX.XX.X|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
       
TankSprites
TankSprites_00
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $E7 ; |XXX..XXX|
   .byte $42 ; |.X....X.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
TankSprites_01
   .byte $00 ; |........|
   .byte $A5 ; |X.X..X.X|
   .byte $42 ; |.X....X.|
   .byte $A5 ; |X.X..X.X|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
       
GameColors
   .byte WHITE - 2                  ; player 1 score color
   .byte WHITE - 2                  ; player 2 score color
   .byte DK_GREEN + 4               ; terrain color
   .byte BLACK                      ; sky color
   .byte YELLOW + 10                ; LeadShip color
   .byte BLACK + 6                  ; Enemy Tank color
       
TerrainGraphicData
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $DF ; |XX.XXXXX|
   .byte $8F ; |X...XXXX|
   .byte $07 ; |.....XXX|
   .byte $03 ; |......XX|
   .byte $01 ; |.......X|
   .byte $00 ; |........|
       
ContinueInitializeGame
   inx                              ; x = 1
   stx leadShipTurretHeight         ; set to not draw LeadShip turret
   lda #W_MOUNTAIN_TERRAIN
   sta mountainTerrainWidth
   lda #<Blank
   sta explosionGraphicPtrs
   lda #INIT_LEADSHIP_VERT_MIN
   sta leadShipVertMin
   lda #7
   sta tankBitArray
   lsr                              ; divide value by 2
   sta remainingLives               ; set initial lives to 3
ResetPlayerInfo
   lda #XMIN_LEADSHIP
   sta leadShipHorizPos
   lda #YMAX
   sta leadShipVertPos
   lda #$80
   sta actionButtonDebounce         ; set to not allow LeadShip laser
   rts

EnemyTankNUSIZValues
   .byte MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | TWO_MED_COPIES
   .byte MSBL_SIZE2 | ONE_COPY
   .byte MSBL_SIZE2 | TWO_WIDE_COPIES
   .byte MSBL_SIZE2 | TWO_MED_COPIES
   .byte MSBL_SIZE2 | THREE_MED_COPIES
       
EnemyForcesLeadShipOffsetValues
   .byte 64, 32, 32, 0, 0, 0, 0
   .byte 0, 64, 32, 64, 0, 64, 32, 64

EnemyTankGroupTurretFrequency
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $1F ; |...XXXXX|
      
ReserveFleetNUSIZTable
   .byte $80 | ONE_COPY
   .byte $80 | ONE_COPY
   .byte ONE_COPY
   .byte ONE_COPY
   .byte TWO_MED_COPIES
   .byte TWO_MED_COPIES
   .byte THREE_MED_COPIES
   .byte THREE_MED_COPIES
       
   .org ROM_BASE + 2048 - 4, 0      ; 2K ROM
   .word Start
LaserAudioFrequencyOffset
   .byte 0, 4