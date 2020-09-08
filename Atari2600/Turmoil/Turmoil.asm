   LIST OFF
; ***  T U R M O I L  ***
; Copyright 1982 Sirius
; Programmer: Mark Turmell

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: December 7, 2018
;
;  *** 121 BYTES OF RAM USED 7 BYTES FREE
;  *** 143 BYTES OF ROM FREE
;
; ==============================================================================
; = THIS REVERSE-ENGINEERING PROJECT IS BEING SUPPLIED TO THE PUBLIC DOMAIN    =
; = FOR EDUCATIONAL PURPOSES ONLY. THOUGH THE CODE WILL ASSEMBLE INTO THE      =
; = EXACT GAME ROM, THE LABELS AND COMMENTS ARE THE INTERPRETATION OF MY OWN   =
; = AND MAY NOT REPRESENT THE ORIGINAL VISION OF THE AUTHOR.                   =
; =                                                                            =
; = THE ASSEMBLED CODE IS © 1982, SIRIUS                                       =
; =                                                                            =
; ==============================================================================

   processor 6502

;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

   include vcs.h
   include macro.h
   include tia_constants.h

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

   IF COMPILE_REGION != NTSC

      echo ""
      echo "*** ERROR: Invalid COMPILE_REGION value"
      echo "*** Valid values: NTSC = 0"
      echo ""
      err

   ENDIF

;===============================================================================
; F R A M E - T I M I N G S
;===============================================================================

FPS                     = 60        ; ~60 frames per second
VSYNC_TIME              = 42
VBLANK_TIME             = 59
OVERSCAN_SCANLINES      = 23

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

BLACK                   = $00
WHITE                   = $0F
YELLOW                  = $10
RED_ORANGE              = $20
BRICK_RED               = $30
RED                     = $40
PURPLE                  = $50
COBALT_BLUE             = $60
ULTRAMARINE_BLUE        = $70
BLUE                    = $80
LT_BLUE                 = $90
OLIVE_GREEN             = $B0
GREEN                   = $C0
ORANGE_GREEN            = $E0

;===============================================================================
; U S E R - C O N S T A N T S
;===============================================================================

ROM_BASE                = $F000

H_DIGITS                = 8
H_KERNEL                = 212
H_LEVEL_TRANSITION_KERNEL = 144
H_KERNEL_LANE           = 15
H_SNEAKERS              = 10

INIT_RESERVED_SHIPS     = 3
MAX_RESERVED_SHIPS      = 6

XMIN                    = 0
XMAX                    = 160

INIT_PLAYER_SHIP_HORIZ  = (XMAX / 2) - 6
INIT_RESERVED_SHIPS_HORIZ = 10
INIT_PLAYER_SHIP_ALLEY  = 5

NUM_LANES               = 7

MAX_GAME_LEVEL          = 8

OBSTACLE_ANIMATION_RATE = 24

MAX_COLLECTED_PRIZES    = 15

; obstacle attribute values
OBSTACLE_DIR_MASK       = %00000001
OBSTACLE_DIR_LEFT       = 0
OBSTACLE_DIR_RIGHT      = 1

;obstacle ids
ID_BLANK                = 0
ID_CANNON_BALL          = 1
ID_ENEMY_FIGHTER_01     = 2
ID_PRIZE                = 3
ID_TIE_FIGHTER          = 4
ID_BULLET               = 5
ID_MISSILE              = 6
ID_ENEMY_FIGHTER_02     = 7
ID_CRAWLER              = 8
ID_ARROW                = 9
ID_TANK                 = 10
ID_EXPLOSION            = 11
ID_GHOST_SHIP           = 12

; point value constants (BCD)
POINT_VALUE_BLANK       = $000
POINT_VALUE_CANNON_BALL = $100
POINT_VALUE_FIGHTER_01  = $020
POINT_VALUE_PRIZE       = $060
POINT_VALUE_TIE_FIGHTER = $060
POINT_VALUE_BULLET      = $010
POINT_VALUE_MISSILE     = $030
POINT_VALUE_FIGHTER_02  = $010
POINT_VALUE_CRAWLER     = $040
POINT_VALUE_ARROW       = $100
POINT_VALUE_TANK        = $050
POINT_VALUE_EXPLOSION   = $000
POINT_VALIE_GHOST_SHIP  = $080

; game level obstacles limit values
OBSTACLE_LIMIT_LEVEL_01 = 64
OBSTACLE_LIMIT_LEVEL_02 = 112
OBSTACLE_LIMIT_LEVEL_03 = 144
OBSTACLE_LIMIT_LEVEL_04 = 176
OBSTACLE_LIMIT_LEVEL_05 = 192
OBSTACLE_LIMIT_LEVEL_06 = 208
OBSTACLE_LIMIT_LEVEL_07 = 224
OBSTACLE_LIMIT_LEVEL_08 = 240
OBSTACLE_LIMIT_LEVEL_09 = 240
OBSTACLE_LIMIT_LEVEL_10 = 255

INIT_GHOST_SHIP_SOUND_INDEX = 25
INIT_ARROW_SPAWN_SOUND_INDEX = 30

;===============================================================================
; M A C R O S
;===============================================================================

;
; time wasting macros
;

   MAC SLEEP_3
      bit $FF
   ENDM
   
   MAC SLEEP_7 
      rol ROM_BASE,x
   ENDM

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================
   SEG.U variables
   .org $80

tmpObstacleIndex        ds 1        ; holds index for new spawning obstacles
currentKernelLane       ds 1        ; lane being drawn in kernel
obstacleAnimationIndex  ds 1        ; animation index for obstacle
playerShipGraphicPtr    ds 2        ; graphic pointers for Player Ship
tmpScoreIndexValues     ds 4
playerScore             ds 2        ; two bytes for score (BCD)
digitGraphicPtrs        ds 2        ; graphic pointers to character display
;--------------------------------------
tmpLivesGraphicPtrs_00  = digitGraphicPtrs
;--------------------------------------
tmpPlayLevelGraphicPtrs = tmpLivesGraphicPtrs_00
;--------------------------------------
tmpObstacleHorizPosPtrs = tmpPlayLevelGraphicPtrs
;--------------------------------------
tmpObstacleTypePtrs     = tmpObstacleHorizPosPtrs
;--------------------------------------
tmpTurmoilLiteral_05    = tmpObstacleTypePtrs
tmpTurmoilFontLoop      = tmpPlayLevelGraphicPtrs + 1
playerShotSoundIndex    ds 1        ; value for playing Play Ship shot sounds
playerShipAlley         ds 1        ; alley occupied by Player Ship
newSpawnedObstacle      ds 1        ; new "random" obstacle to spawn
;--------------------------------------
gameOverSoundNoteHoldValue = newSpawnedObstacle
laneColor               ds 1        ; color value for lanes
playerShipColorPtrs     ds 2        ; set but never used
random                  ds 2        ; 16-bit random number
playerShipVertDelay     ds 1        ; delay value for Player Ship movement
playerShipVertSoundIndex ds 1       ; value for playing Player Ship movement

unused_00               ds 1

objectHorizPos          ds 16       ; horizontal position values
;--------------------------------------
playerShipHorizPos      = objectHorizPos
obstacleHorizPos        = objectHorizPos + 1
playerShipShotHorizPos  = obstacleHorizPos + 7
reservedShipsHorizPos   = playerShipShotHorizPos + 7
;--------------------------------------
tmpTransitionKernelBKColor = playerShipShotHorizPos
kernelFCPosValues       ds 16       ; fine / coarse horizontal values
;--------------------------------------
playerShipFCValue       = kernelFCPosValues
obstacleFCValues        = playerShipFCValue + 1
playerShipShotFCValues  = obstacleFCValues + 7
reservedShipsFCValue    = playerShipShotFCValues + 7
gameState               ds 1
reservedShips           ds 1        ; number of reserved ships
prizeFrameTimer         ds 1
obstacleGraphicPtr      ds 2        ; graphic pointers for obstacles

unused_01               ds 1

obstacleList            ds 7        ; list of obstacles
gameOverSoundIndex      ds 1        ; value for playing game over sounds
selectDebounce          ds 1
obstacleSpeedValue      ds 1        ; speed of obstacles
allowedToSpawnObstacles ds 1
obstaclesDestroyed      ds 1        ; number of obstacles destroyed
levelTransitionSoundIndex ds 1      ; value for playing level transition sounds
laneColorStatus         ds 1        ; value to color lanes or BLACK them out
tmpHighScoreIndexValues ds 4
savedGameLevel          ds 1        ; set but never referenced

unused_02               ds 1

prizesCollected         ds 1        ; number of prizes collected for the level
prizePointValue         ds 1        ; prize point value...reduced each frame
prizeFrameLoopCount     ds 1
currentPrizeLane        ds 1        ; lane occupied by ID_PRIZE
tmpLivesGraphicPtrs_01  ds 2
;--------------------------------------
tmpKernelShipGraphicPtr = tmpLivesGraphicPtrs_01
obstacleGraphicLSBPtr   ds 2        ; pointer to read obstacle graphic values
obstacleAttributes      ds 7        ; obstacle movement values
resetDebounce           ds 1
tmpHundredsGraphic      ds 1
;--------------------------------------
tmpPlayerShipGraphic    = tmpHundredsGraphic
;--------------------------------------
tmpObstacleMovementDelay = tmpPlayerShipGraphic
playerShipShotHorizDir  ds 7        ; direction values for Player Ship shots
gameLevel               ds 1        ; current game level
playerShipShotPtr       ds 2        ; pointer to draw Player Ship shoots
startBWValue            ds 1        ; B/W values read at boot up for pause
obstacleColorPtrs       ds 2        ; pointer to obstacle colors
arrowSpawnSoundIndex    ds 1        ; value for playing arrow spawning
tankSpawnSoundIndex     ds 1        ; value for playing Tank spawning
obstacleShotCollisionValues ds 1    ; each bit represents a lane
playerShipReflectValue  ds 1        ; reflect state of Player Ship
tmpTurmoilLiteralColor  ds 1
;--------------------------------------
tmpPlayerShipCollisionValue = tmpTurmoilLiteralColor
playerShipCollisionSoundIndex ds 1

unused_03               ds 1

sneakerGraphicPtr       ds 2        ; graphic pointer for Sneaker graphics
;--------------------------------------
transitionKernelBKColor = sneakerGraphicPtr
tmpTransitionKernelPFColorIdx = transitionKernelBKColor + 1
tmpEnableDisablePlayShot ds 1
;--------------------------------------
transitionKernelPFColor = tmpEnableDisablePlayShot
kernelStatus            ds 1
ghostShipSoundIndex     ds 1        ; value for playing Ghost Ship sounds
;--------------------------------------
tmpPlayLevelIndex       = ghostShipSoundIndex
ghostShipSpawnTimer     ds 1        ; timer to spawn Ghost Ship for non-movement

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
   sei
   cld
   lda #0
   tax
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   dex                              ; x = #$FF
   txs                              ; set stack to the beginning
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   sta startBWValue                 ; save B/W switch value at cart startup
   lda #>ObstacleGraphics
   sta obstacleGraphicPtr + 1       ; set obstacle graphics MSB value
   lda #<ObstacleColorValues
   sta obstacleColorPtrs            ; set default obstacle color LSB value
   lda #>ObstacleColorValues
   sta obstacleColorPtrs + 1        ; set default obstacle color MSB value
   lda #254
   sta random + 1
   sta obstacleGraphicLSBPtr + 1
   lda #REFLECT
   sta playerShipReflectValue       ; set player ship to point right
   lda #1
   sta tmpObstacleIndex
   sta CTRLPF                       ; set playfield to REFLECT (i.e. D0 = 1)
   lda #INIT_PLAYER_SHIP_ALLEY
   sta playerShipAlley
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos
   lda #INIT_RESERVED_SHIPS_HORIZ
   sta reservedShipsHorizPos
   lda #20
   sta newSpawnedObstacle
   lda #YELLOW + 8
   sta laneColor
   lda #<PlayerShipColorValues
   sta playerShipColorPtrs
   lda #>PlayerShipColorValues
   sta playerShipColorPtrs + 1
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   lda #1
   sta obstacleSpeedValue
   jsr SetObstacleValuesForGameLevel
NewFrame
   ldx #VSYNC_TIME
   sta WSYNC                        ; wait for next scanline
   stx VBLANK                       ; disable TIA (i.e. D1 = 1)
   stx VSYNC                        ; start VSYNC (i.e. D1 = 1)
   stx TIM8T                        ; set timer for VSYNC period
   inc ghostShipSpawnTimer          ; increment Ghost Ship timer each frame
   lda playerScore                  ; get player score value
   and #$0F                         ; keep lower nybbles (i.e. tens value)
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta tmpScoreIndexValues
   lda playerScore                  ; get player score value
   and #$F0                         ; keep upper nybbles (i.e. hundreds value)
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpScoreIndexValues + 1
   lda playerScore + 1              ; get player score value
   and #$0F                         ; keep lower nybbles (i.e. thousands value)
   asl                              ; multiply by 8 (i.e. H_DIGITS)
   asl
   asl
   sta tmpScoreIndexValues + 2
   lda playerScore + 1              ; get player score value
   and #$F0                         ; keep upper nybbles (i.e. ten thousands)
   lsr                              ; divide by 2 (i.e. multiply by 8)
   sta tmpScoreIndexValues + 3
   inc random
   lda gameState                    ; get current game state
   bmi VerticalBlank                ; branch if game in progress
   inc tmpTurmoilLiteralColor
   lda #0
   sta laneColorStatus              ; clear lane color status
VerticalBlank
   ldx #VBLANK_TIME
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; wait for next scanline
   sta VSYNC                        ; end VSYNC (i.e. D1 = 0)
   stx TIM64T                       ; set timer for VBLANK period
   lda gameState                    ; get current game state
   bpl .skipGamePaused              ; branch if game not in progress
   lda SWCHB                        ; read console switches
   and #BW_MASK                     ; get the B/W switch value
   cmp startBWValue                 ; compare with value at startup
   beq .skipGamePaused              ; branch if game not paused
   lda #0
   sta AUDV1                        ; turn off channel 1 sound
   sta AUDV0                        ; turn off channel 0 sound
   lda laneColor                    ; get current lane color
   clc
   adc #16                          ; increment color value
   sta laneColor                    ; set new lane color value
   jmp DisplayKernel
       
.skipGamePaused
   ldx #NUM_LANES - 1
   lda kernelStatus                 ; get kernel status value
   cmp #1
   beq AdvanceToNextLevel           ; branch if transitioning level
   lda obstaclesDestroyed           ; get number of obstacles destroyed
   ldy gameLevel                    ; get current game level
   cmp NumberOfObstaclesToDestroy,y ; compare with obstacles to destroy
   bcc CheckObstaclesDestroyedForLevel; branch if not destroyed all obstacles
.checkAllObjectsRemoved
   lda obstacleList,x               ; get obstacle type for lane
   bne CheckObstaclesDestroyedForLevel; branch if not ID_BLANK
   dex
   bpl .checkAllObjectsRemoved
AdvanceToNextLevel
   lda #0
   sta obstaclesDestroyed           ; reset number of obstacles destroyed
   sta ghostShipSpawnTimer          ; reset Ghost Ship timer
   lda #1
   sta playerShipAlley              ; place player ship in alley 1
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos           ; set player ship to starting horiz position
   lda #0
   sta tankSpawnSoundIndex          ; clear Tank spawn sound index
   sta playerShotSoundIndex
   sta playerShipVertSoundIndex     ; clear vertical sound index
   sta playerShipCollisionSoundIndex; clear player ship collision sound index
   lda gameState                    ; get current game state
   bpl .incrementReservedShips      ; branch if game not in progress
   inc gameLevel                    ; increment game level
   lda gameLevel                    ; get current game level
   cmp #MAX_GAME_LEVEL + 1
   bcc .incrementReservedShips      ; branch if not reached max level
   lda #MAX_GAME_LEVEL
   sta gameLevel                    ; set to max game level
.incrementReservedShips
   inc reservedShips                ; increment number of reserved ships
   lda reservedShips                ; get number of reserved ships
   cmp #MAX_RESERVED_SHIPS + 1
   bcc .setReservedShipsHorizPos    ; branch if not reached max reserved ships
   lda #MAX_RESERVED_SHIPS
   sta reservedShips                ; set to max reserved ships
.setReservedShipsHorizPos
   tay                              ; move reserved ships value to y register
   lda ReservedShipsHorizPosValues,y
   sta reservedShipsHorizPos
   lda #255
   sta levelTransitionSoundIndex
   beq CheckToPlayLevelTransitionSound; branch never taken
   sta kernelStatus                 ; set kernel status to show transition
   bmi CheckToPlayLevelTransitionSound
       
CheckObstaclesDestroyedForLevel
   lda obstaclesDestroyed           ; get number of obstacles destroyed
   ldy gameLevel                    ; get current game level
   cmp NumberOfObstaclesToDestroy,y ; compare with obstacles to destroy
   bcc CheckToPlayLevelTransitionSound; branch if not destroyed all obstacles
   lda #<-1
   sta allowedToSpawnObstacles      ; set to not allow obstacle spawning
CheckToPlayLevelTransitionSound
   lda levelTransitionSoundIndex    ; get level transition sound index
   beq CheckToPlayGameOverSounds    ; branch if done level transition sound
   dec levelTransitionSoundIndex
   beq .donePlayLevelTransitionSound
   tay                              ; save level transition sound to y register
   lsr                              ; divide value by 8 for frequency
   lsr
   lsr
   sta AUDF0
   sta AUDF1
   tya                              ; get level transition sound index
   and #$0F
   sta AUDV1
   sta AUDV0
   lda #4
   sta AUDC0
   lda #7
   sta AUDC1
   jmp CalculateObjectHMOVEValues
       
.donePlayLevelTransitionSound
   lda #0
   sta AUDV1
   sta AUDV0
   sta levelTransitionSoundIndex
   sta allowedToSpawnObstacles      ; set to allow obstacle spawning
   sta playerShipCollisionSoundIndex; clear player ship collision sound index
   sta tmpPlayerShipCollisionValue  ; clear player ship collision value
   sta kernelStatus                 ; set kernel status to show game kernel
   sta playerShipShotHorizPos
   sta playerShipShotHorizPos + 1
   sta playerShipShotHorizPos + 2
   sta playerShipShotHorizPos + 3
   sta playerShipShotHorizPos + 4
   sta playerShipShotHorizPos + 5
   sta playerShipShotHorizPos + 6
   sta prizesCollected              ; clear number of prizes collected
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   ldx #1
   stx playerShipAlley              ; place player ship in alley 1
   ldx #$FF
   txs
   jsr SetObstacleValuesForGameLevel
   lda gameLevel                    ; get current game level
   cmp #3
   bcc .resetLaneColor              ; branch if less than level 3
   lda laneColorStatus              ; get lane color status
   beq .setLaneColorToBlack         ; branch if cycling lane colors
.resetLaneColor
   lda #ULTRAMARINE_BLUE + 8
   sta laneColor
   lda #0
   sta laneColorStatus              ; clear lane color status
   beq CheckToPlayGameOverSounds    ; unconditional branch
       
.setLaneColorToBlack
   lda #<-1
   sta laneColorStatus              ; set to not cycle lane color
   lda #BLACK
   sta laneColor                    ; color lanes to BLACK
CheckToPlayGameOverSounds
   lda gameOverSoundIndex           ; get game over sound index
   beq CheckForGameRestart
   dec gameOverSoundNoteHoldValue   ; decrement value to hold game over notes
   bne .jmpCheckForResetSwitchPressed
   lda #6
   sta gameOverSoundNoteHoldValue   ; hold note for 6 frames
   inc gameOverSoundIndex           ; increment game over sound index
   lda gameOverSoundIndex           ; get game over sound index
   tay                              ; save game over sound index to y register
   lda #4
   sta AUDC0
   lda #5
   sta AUDC1                        ; set game over audio channel values
   lda #15
   sta AUDV0
   sta AUDV1                        ; set to maximum volume
   tya                              ; move game over sound index to accumulator
   eor #$0F                         ; flip lower nybbles to decrease value
   sta AUDF0
   tya                              ; move game over sound index to accumulator
   eor #8
   sta AUDF1
   cpy #48
   bcs .donePlayGameOverSounds
.jmpCheckForResetSwitchPressed
   jmp .checkForResetSwitchPressed

.donePlayGameOverSounds
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   lda #0
   sta AUDV1                        ; turn off sound by reducing volume
   sta AUDV0
   sta gameOverSoundIndex           ; clear game over sound index
   sta gameState
   sta gameLevel
   sta obstaclesDestroyed           ; reset number of obstacles destroyed
   ldx #$FF
   txs
   jsr SetObstacleValuesForGameLevel
   lda #ULTRAMARINE_BLUE + 8
   sta laneColor
   lda tmpHighScoreIndexValues      ; get high score ten thousands index
   cmp tmpScoreIndexValues + 3      ; compare with score ten thousands index
   bcc .setHighScoreValues          ; set high score values
   bne CheckForGameRestart
   lda tmpHighScoreIndexValues + 1  ; get high score thousands index value
   cmp tmpScoreIndexValues + 2      ; compare with score thousands index value
   bcc .setHighScoreValues          ; set high score values
   bne CheckForGameRestart
   lda tmpHighScoreIndexValues + 2  ; get high score hundreds index value
   cmp tmpScoreIndexValues + 1      ; compare with score hundreds index value
   bcc .setHighScoreValues          ; set high score values
   bne CheckForGameRestart
   lda tmpHighScoreIndexValues + 3  ; get high score tens index value
   cmp tmpScoreIndexValues          ; compare with score tens index value
   bcc .setHighScoreValues          ; set high score values
   bne CheckForGameRestart
.setHighScoreValues
   lda tmpScoreIndexValues + 3      ; get score ten thousands index
   sta tmpHighScoreIndexValues      ; set high score ten thousands index
   lda tmpScoreIndexValues + 2      ; get score thousands index value
   sta tmpHighScoreIndexValues + 1  ; set high score thousands index value
   lda tmpScoreIndexValues + 1      ; get score hundreds index value
   sta tmpHighScoreIndexValues + 2  ; set high score hundreds index value
   lda tmpScoreIndexValues          ; get score tens index value
   sta tmpHighScoreIndexValues + 3  ; set high score tens index value
CheckForGameRestart
   lda INPT4                        ; read left port action button
   bmi .checkForResetSwitchPressed  ; branch if button not pressed
   lda gameState                    ; get current game state
   bpl .startNewGame                ; branch if game not in progress
.checkForResetSwitchPressed
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   bcs .checkForResetSwitchReleased ; branch if RESET not pressed
.startNewGame
   ldy #<-1
   sty resetDebounce                ; set D7 high to show RESET held
   sty gameState                    ; set game state to game in progress
   iny                              ; y = 0
   sty prizeFrameLoopCount          ; clear prize frame loop count
   sty currentPrizeLane             ; clear value for prize lane
   sty playerScore
   sty playerScore + 1
   sty AUDV1                        ; turn off sound by reducing volume
   sty AUDV0
   sty gameOverSoundIndex           ; clear game over sound index
   sty levelTransitionSoundIndex
   sty allowedToSpawnObstacles      ; set to allow obstacle spawning
   iny                              ; y = 1
   sty laneColorStatus              ; set to not cycle lane color
   sty playerShipAlley              ; place player ship in alley 1
   lda #INIT_RESERVED_SHIPS
   sta reservedShips                ; set initial number of reserved ships
   lda ReservedShipsHorizPosValues + 3
   sta reservedShipsHorizPos
   jmp CalculateObjectHMOVEValues
       
.checkForResetSwitchReleased
   lda resetDebounce                ; get RESET debounce value
   bpl .checkForGameOverDisplayState; branch if RESET switch not held
   sta gameState
   ldx #$FF
   txs
   jsr SetObstacleValuesForGameLevel
   lda #0
   sta resetDebounce                ; clear debounce to show RESET not held
   sta tmpPlayerShipCollisionValue  ; clear player ship collision value
   sta obstaclesDestroyed           ; reset number of obstacles destroyed
   lda #1
   sta kernelStatus                 ; set kernel status to show transition
   lda gameLevel                    ; get current game level
   sta savedGameLevel               ; never used or referenced
   dec gameLevel                    ; decrement game level
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   jmp CalculateObjectHMOVEValues
       
.checkForGameOverDisplayState
   lda gameOverSoundIndex           ; get game over sound index
   beq CheckGameSelectSwitch        ; branch if not playing game over sounds
   jmp DisplayKernel
       
CheckGameSelectSwitch
   lda SWCHB                        ; read console switches
   lsr                              ; shift RESET to carry
   lsr                              ; shift SELECT to carry
   bcc .selectSwitchPressed
   sta selectDebounce               ; clear D7 value to show SELECT not pressed
   bpl CheckPlayerShipCollision     ; unconditional branch
       
.selectSwitchPressed
   lda #0
   sta AUDV1                        ; turn off sound by reducing volume
   sta AUDV0
   sta prizeFrameLoopCount          ; clear prize frame loop count
   sta playerShipCollisionSoundIndex; clear player ship collision sound index
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   lda #ULTRAMARINE_BLUE + 8
   sta laneColor
   lda selectDebounce               ; get SELECT debounce value
   bpl .incrementGameSelection      ; branch if SELECT released
   lda gameState                    ; get current game state
   clc
   adc #3                           ; increment value by 3
   sta gameState
   bpl CheckPlayerShipCollision     ; branch if less than 128
   lda #0                           ; increment game selection ~43 frames
   sta gameState
.incrementGameSelection
   inc gameLevel                    ; increment game level
   lda gameLevel                    ; get current game level
   cmp #MAX_GAME_LEVEL + 1
   bcc .setSelectDebounceToSelectHeld
   lda #0
   sta gameLevel                    ; reset game level
.setSelectDebounceToSelectHeld
   lda #<-1
   sta selectDebounce               ; set debounce to show SELECT held
   ldx #$FF
   txs
   jsr SetObstacleValuesForGameLevel
CheckPlayerShipCollision SUBROUTINE
   lda playerShipCollisionSoundIndex; get player ship collision sound index
   bne .cycleLaneColorsForCollision ; branch if playing collision sound
   lda tmpPlayerShipCollisionValue  ; get player ship collision value
   bpl .jmpToResetPlayerShipGraphics; branch if no collision
   lda gameState                    ; get current game state
   bmi .playerShipCollisionWithObstacle; branch if game in progress
.jmpToResetPlayerShipGraphics
   jmp .resetPlayerShipGraphics

.playerShipCollisionWithObstacle
   ldy playerShipAlley              ; get Player Ship alley
   lda obstacleList - 1,y           ; get obstacle type in Player Ship alley
   cmp #ID_PRIZE
   bne .playerShipCollidedWithObstacle; branch if ID_PRIZE not in alley
   sta tmpPlayerShipCollisionValue  ; clear collision value for ID_PRIZE
   lda #80
   sta prizePointValue              ; rewarded 800 points for collecting prize
   lda #0
   sta prizeFrameLoopCount          ; clear prize frame loop count
   lda #ID_GHOST_SHIP
   sta obstacleList - 1,y           ; spawn ID_PRIZE to ID_GHOST_SHIP
   lda playerShipHorizPos
   cmp #INIT_PLAYER_SHIP_HORIZ
   bcs .placeGhostShipOnLeftSide
   lda #XMAX - 5
   sta obstacleHorizPos - 1,y
   lda #1 << 4 | OBSTACLE_DIR_LEFT
   sta obstacleAttributes - 1,y
   bne .jmpToResetPlayerShipGraphics; unconditional branch
       
.placeGhostShipOnLeftSide
   lda #XMIN + 6
   sta obstacleHorizPos - 1,y
   lda #1 << 4 | OBSTACLE_DIR_RIGHT
   sta obstacleAttributes - 1,y
   bne .jmpToResetPlayerShipGraphics
       
.playerShipCollidedWithObstacle
   lda #ID_BLANK
   sta obstacleList - 1,y           ; remove obstacle from list
.cycleLaneColorsForCollision
   lda gameOverSoundNoteHoldValue
   cmp #2
   beq .changeLaneColorForDeathSequence
   cmp #8
   bne .setReservedShipsHorizPos
.changeLaneColorForDeathSequence
   inc playerShipCollisionSoundIndex
   lda laneColorStatus              ; get lane color status
   bne .playShipDeathSound          ; branch if not cycling lane colors
   inc laneColor                    ; increment lane color luminance
.playShipDeathSound
   lda playerShipCollisionSoundIndex; get player ship collision sound index
   tay                              ; move sound index to y register
   lda #13
   sta AUDC0
   lda #4
   sta AUDC1
   lda #15
   sta AUDV0
   sta AUDV1
   tya                              ; move sound index to accumulator
   eor #$0F
   sta AUDF0
   tya                              ; move sound index to accumulator
   eor #8
   sta AUDF1
   cpy #23
   bcs .setValuesForDeathSequenceEnd; branch if sound index greater than 22
   lda PlayerShipDeathGraphicsLSBValues,y
   sta playerShipGraphicPtr
   lda #>PlayerShipDeathGraphics
   sta playerShipGraphicPtr + 1
   bmi .setReservedShipsHorizPos    ; unconditional branch
       
.setValuesForDeathSequenceEnd
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
   lda #>PlayerShipGraphics
   sta playerShipGraphicPtr + 1
   lda #0
   sta prizePointValue
   sta tankSpawnSoundIndex          ; clear Tank spawn sound index
   sta arrowSpawnSoundIndex         ; clear Arrow spawn sound index
   sta levelTransitionSoundIndex
   sta AUDV0                        ; turn off sound by reducing volume
   sta AUDV1
   sta playerShipCollisionSoundIndex; clear player ship collision sound index
   sta tmpPlayerShipCollisionValue
   sta ghostShipSpawnTimer          ; reset Ghost Ship timer
   lda #10
   sta arrowSpawnSoundIndex
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos
   lda laneColorStatus              ; get lane color status
   bne .decrementReservedShips      ; branch if not cycling lane colors
   lda #ULTRAMARINE_BLUE + 8
   sta laneColor
.decrementReservedShips
   dec reservedShips                ; decrement number of reserved ships
   bpl .resetPlayerShipGraphics
   ldy #0
   sty reservedShips                ; set number of reserved ships to 0
   iny                              ; y = 1
   sty gameOverSoundIndex
.resetPlayerShipGraphics
   lda #<PlayerShipGraphics
   sta playerShipGraphicPtr
.setReservedShipsHorizPos
   ldy reservedShips                ; get number of reserved ships
   lda ReservedShipsHorizPosValues,y
   sec
   sbc gameLevel
   sta reservedShipsHorizPos        ; set reserved ships horizontal position
   ldx #NUM_LANES
.processPlayerShots
   lda obstacleShotCollisionValues  ; get obstacle shot collision value
   and LaneShotCollisionMaskValues,x; mask lane shot collision bit
   bne .playerShotObstacle
.skipPlayerShotCollision
   jmp .movePlayerShipShot

.playerShotObstacle
   lda #XMAX + 20
   sta playerShipShotHorizPos,x     ; move player shot out of range
   lda obstacleShotCollisionValues  ; get obstacle shot collision value
   eor LaneShotCollisionMaskValues,x
   sta obstacleShotCollisionValues  ; clear collision value for lane
   lda obstacleList,x               ; get obstacle type for lane
   tay                              ; move obstacle type to y register
   cmp #ID_PRIZE
   beq .skipPlayerShotCollision     ; score no points for shooting ID_PRIZE
   cmp #ID_TANK
   beq .playerShotTank              ; branch if obstacle is a TANK
   lda gameState                    ; get current game state
   bpl .skipPointsForShootingObstacle; branch if game not in progress
   inc obstaclesDestroyed           ; increment number of obstacles destroyed
   sed
   lda playerScore                  ; get score tens value
   clc
   adc ObstaclePointValues,y        ; increment by obstacle point value
   sta playerScore
   lda playerScore + 1              ; get score thousands value
   adc #1 - 1                       ; increment by one when carry set
   sta playerScore + 1
   cld
.skipPointsForShootingObstacle
   jmp .setObstacleToExplosion

.playerShotTank
   lda obstacleAttributes,x
   and #OBSTACLE_DIR_MASK           ; keep DIRECTION value
   beq .playerShotLeftTravelingTank ; branch if TANK traveling left
   lda obstacleHorizPos,x           ; get TANK horizontal position
   cmp #XMIN + 14
   bcc .movePlayerShipShot
   cmp #(XMAX / 2) + 5
   bcs .scorePointsForDestroyingTank
   sec
   sbc #8                           ; nudge TANK 8 pixels left
   sta obstacleHorizPos,x           ; set TANK horizontal position
   jmp .movePlayerShipShot
       
.playerShotLeftTravelingTank
   lda obstacleHorizPos,x           ; get TANK horizontal position
   cmp #XMAX - 15
   bcs .movePlayerShipShot
   cmp #(XMAX / 2) - 5
   bcc .scorePointsForDestroyingTank
   clc
   adc #8                           ; nudge TANK 8 pixels right
   sta obstacleHorizPos,x           ; set TANK horizontal position
   jmp .movePlayerShipShot
       
.scorePointsForDestroyingTank
   lda gameState                    ; get current game state
   bpl .setObstacleToExplosion      ; branch if game not in progress
   sed
   lda playerScore                  ; get score tens value
   clc
   adc #POINT_VALUE_TANK >> 4
   sta playerScore
   lda playerScore + 1              ; get score thousands value
   adc #1 - 1                       ; increment by one when carry set
   sta playerScore + 1
   cld
.setObstacleToExplosion
   lda #ID_EXPLOSION
   sta obstacleList,x               ; get obstacle type to ID_EXPLOSION
   lda obstacleAttributes,x
   and #OBSTACLE_DIR_MASK           ; keep DIRECTION value
   beq .explosionTravelingLeft      ; branch if obstacle traveling left
   lda obstacleList,x               ; BUG?? should be obstacleHorizPos,x??
   cmp #(XMAX / 2) + 5
   bcs .movePlayerShipShot
   lda obstacleAttributes,x         ; get obstacle movement values
   eor #OBSTACLE_DIR_MASK           ; flip obstacle direction bit
   sta obstacleAttributes,x
.explosionTravelingLeft
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   cmp #(XMAX / 2) + 5
   bcc .movePlayerShipShot          ; branch if obstacle on left side
   lda obstacleAttributes,x         ; get obstacle movement values
   eor #OBSTACLE_DIR_MASK           ; flip obstacle direction bit
   sta obstacleAttributes,x
.movePlayerShipShot
   lda playerShipShotHorizPos,x     ; get player ship shot horizontal position
   beq .nextLane                    ; branch if reached left side
   clc
   adc playerShipShotHorizDir,x     ; increment by direction value
   sta playerShipShotHorizPos,x     ; set player ship shot horizontal position
   cmp #XMAX - 2
   bcs .turnOffPlayerShot           ; branch if reached right side
   cmp #XMIN + 1
   bcs .nextLane
.turnOffPlayerShot
   lda #XMIN
   sta playerShipShotHorizPos,x
.nextLane
   dex
   bmi AnimateObstacleGraphics
   jmp .processPlayerShots
       
AnimateObstacleGraphics
   lda obstacleAnimationIndex       ; get obstacle animation index value
   clc
   adc #OBSTACLE_ANIMATION_RATE     ; animate obstacles ~ every 5 frames
   sta obstacleAnimationIndex       ; set new animation index value
   bpl .firstObstacleAnimationPtrs  ; branch if animation index is positive
   lda #<ObstacleGraphicLSBValues_00
   sta obstacleGraphicLSBPtr
   jmp SetExplosiionTypeValues
       
.firstObstacleAnimationPtrs
   lda #<ObstacleGraphicLSBValues_01
   sta obstacleGraphicLSBPtr
SetExplosiionTypeValues
   inc tmpObstacleIndex
   ldx #NUM_LANES - 1
.setExplosionTypeValues
   lda obstacleList,x               ; get obstacle type for lane
   cmp #ID_EXPLOSION
   bne .nextExplosionType           ; branch if not ID_EXPLOSION
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   cmp #(XMAX / 2) + 15
   bcs .setExplosionToMoveEveryFrame
   cmp #(XMAX / 2) - 15
   bcc .setExplosionToMoveEveryFrame
   lda #ID_BLANK
   sta obstacleList,x               ; remove ID_EXPLOSION item
   lda #XMAX
   sta obstacleHorizPos,x           ; place item out of range
   bmi .nextExplosionType           ; unconditional branch
       
.setExplosionToMoveEveryFrame
   lda obstacleAttributes,x         ; get ID_EXPLOSION attribute value
   and #$0F                         ; clear movement delay value
   sta obstacleAttributes,x
.nextExplosionType
   dex
   bpl .setExplosionTypeValues
   ldx #NUM_LANES - 1
.moveObstacles
   lda obstacleAttributes,x         ; get obstacle attribute values
   cmp #$FF
   beq .beqMoveNextObstacle         ; branch if obstacle is ID_PRIZE
   lsr                              ; shift movement delay to lower nybbles
   lsr
   lsr
   lsr
   sta tmpObstacleMovementDelay
   and tmpObstacleIndex
   cmp tmpObstacleMovementDelay
   bne .moveNextObstacle
   lda obstacleHorizPos,x           ; get obstacle horizontal position
.beqMoveNextObstacle
   beq .moveNextObstacle
   ldy obstacleList,x               ; get obstacle type for lane
   cpy #ID_CANNON_BALL
   bne .changeObstacleHorizPos      ; branch if obstacle not ID_CANNON_BALL
   inc obstacleSpeedValue           ; increment speed for ID_CANNON_BALL
   inc obstacleSpeedValue
   inc obstacleSpeedValue
.changeObstacleHorizPos
   lda obstacleAttributes,x
   and #OBSTACLE_DIR_MASK
   beq .moveObstacleLeft
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   clc
   adc obstacleSpeedValue           ; increment position by obstacle speed
   jmp .setObstacleHorizPos
       
.moveObstacleLeft
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   sec
   sbc obstacleSpeedValue           ; decrement position by obstacle speed
.setObstacleHorizPos
   sta obstacleHorizPos,x
   cpy #ID_CANNON_BALL
   bne .checkForObstacleOutOfRange  ; branch if obstacle not ID_CANNON_BALL
   dec obstacleSpeedValue           ; set obstacle speed value back to original
   dec obstacleSpeedValue
   dec obstacleSpeedValue
.checkForObstacleOutOfRange
   cmp #XMAX + 40
   bcs .spawnNewObstacle            ; branch if obstacle out range to the right
   cmp #XMAX - 5
   bcs .checkTankOrCannonBallReachingLimit
   cmp #XMIN + 6
   bcs .moveNextObstacle
.checkTankOrCannonBallReachingLimit
   lda obstacleList,x               ; get obstacle type for lane
   cmp #ID_TANK
   beq .changeObstacleDirection     ; change direction of Tank
   cmp #ID_CANNON_BALL
   bne .checkToSpawnTankFromArrow
   lda #5
   sta playerShipVertSoundIndex
   bne .changeObstacleDirection     ; unconditional branch
       
.checkToSpawnTankFromArrow
   cmp #ID_ARROW
   bne .spawnNewObstacle
   lda #ID_TANK
   sta obstacleList,x
   sta tankSpawnSoundIndex          ; set Tank spawn sound index value
.changeObstacleDirection
   lda obstacleAttributes,x         ; get obstacle attribute values
   eor #OBSTACLE_DIR_MASK           ; flip OBSTACLE_DIR value
   sta obstacleAttributes,x
   lda playerShipCollisionSoundIndex; get player ship collision sound index
   beq .moveNextObstacle            ; branch if not playing collision sound
   lda #ID_BLANK
   sta obstacleList,x               ; set obstacle to ID_BLANK
   jmp .moveNextObstacle
       
.spawnNewObstacle
   stx tmpObstacleIndex             ; save current obstacle index
   lda #0
   sta obstacleHorizPos,x           ; set obstacle horizontal position to XMIN
   sta obstacleList,x               ; set obstacle to ID_BLANK
   ldx #$FF
   txs
   jsr SpawnNewObstacle
   ldx tmpObstacleIndex             ; restore currenct obstacle index
.moveNextObstacle
   dex
   bmi CheckToSpawnPrizeToCannonball
   jmp .moveObstacles
       
CheckToSpawnPrizeToCannonball
   inc prizeFrameTimer              ; increment prize frame timer
   bpl .checkToIncrementScoreForPrize; branch if not reached 128
   lda #0
   sta prizeFrameTimer              ; reset prize frame timer
   lda prizeFrameLoopCount          ; get prize frame loop count
   beq SetLaneColors                ; branch if no prize present
   dec prizeFrameLoopCount          ; decrement prize frame loop count
   bne SetLaneColors
   ldx currentPrizeLane             ; get lane number for prize
   lda #ID_CANNON_BALL
   sta obstacleList,x               ; replace ID_PRIZE with ID_CANNON_BALL
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   cmp #(XMAX / 2)
   bcs .setCannonBallToTravelLeft   ; branch if obstacle to the right
   inc obstacleHorizPos,x           ; increment obstacle horizontal position
   lda #0 << 4 | OBSTACLE_DIR_RIGHT
   sta obstacleAttributes,x         ; set obstacle to travel right
   bne SetLaneColors                ; unconditional branch
       
.setCannonBallToTravelLeft
   lda #0 << 4 | OBSTACLE_DIR_LEFT
   sta obstacleAttributes,x
SetLaneColors
   lda laneColorStatus              ; get lane color status
   beq .incrementLaneColor          ; branch if cycling lane colors
   lda #BLACK
   sta laneColor                    ; set lane color to BLACK
   beq .checkToIncrementScoreForPrize; unconditional branch
       
.incrementLaneColor
   lda laneColor                    ; get current lane color
   clc
   adc #16                          ; increment lane color value
   sta laneColor
.checkToIncrementScoreForPrize
   lda gameState                    ; get current game state
   bmi IncrementScoreForPrize       ; branch if game in progress
   jmp AnimateSneakerGraphics
       
IncrementScoreForPrize
   lda playerShipCollisionSoundIndex; get player ship collision sound index
   beq .incrementScoreForPrize      ; branch if not playing collision sound
   jmp AnimateSneakerGraphics
       
.incrementScoreForPrize
   lda prizePointValue
   beq CheckToPlayPlayerShipVertSound
   asl
   asl
   sta AUDF0
   eor #10 << 2
   sta AUDF1
   lda #4
   sta AUDC0
   lda #4
   sta AUDC1
   lda #15
   sta AUDV1
   sta AUDV0
   sed
   lda playerScore                  ; get score tens value
   clc
   adc #1
   sta playerScore
   lda playerScore + 1              ; get score thousands value
   adc #1 - 1                       ; increment by one when carry set
   sta playerScore + 1
   cld
   dec prizePointValue
   bne .doneIncrementScoreForPrize
   lda #0
   sta AUDV1
   sta AUDV0
   inc prizesCollected              ; increment number of prizes collected
.doneIncrementScoreForPrize
   jmp AnimateSneakerGraphics

CheckToPlayPlayerShipVertSound
   lda playerShipVertSoundIndex
   beq CheckToPlaySoundForPlayerShot
   sta AUDF0                        ; set frequency for player ship sound
   lda #15
   sta AUDV0                        ; set to maximum volume
   lda #1
   sta AUDC0
   dec playerShipVertSoundIndex     ; decrement player ship sound index
   bne CheckToPlaySoundForPlayerShot
   lda #0
   sta AUDV0
CheckToPlaySoundForPlayerShot
   lda playerShotSoundIndex         ; get player shot sound index
   beq CheckToPlayTankSpawnSound
   eor #$1F                         ; flip bits to increase frequency
   sta AUDF0
   lda #15
   sta AUDV0                        ; set to maximum volume
   lda #12
   sta AUDC0
   dec playerShotSoundIndex         ; decrement player shot sound index
   bne CheckToPlayTankSpawnSound
   lda #0                           ; done playing player shot sound
   sta AUDV0
CheckToPlayTankSpawnSound
   lda tankSpawnSoundIndex          ; get Tank spawn sound index value
   beq CheckToPlayArrowSound
   sta AUDF1                        ; set sound frequency for Tank
   lda #15
   sta AUDV1                        ; set to maximum volume
   lda #4
   sta AUDC1
   inc tankSpawnSoundIndex          ; increment Tank spawn sound index
   lda tankSpawnSoundIndex          ; get Tank spawn sound index value
   cmp #30
   bne AnimateSneakerGraphics
   lda #0                           ; done playing Tank spawn sound
   sta tankSpawnSoundIndex
   sta AUDV1
CheckToPlayArrowSound
   lda arrowSpawnSoundIndex
   beq CheckToPlayGhostShipSound
   sta AUDF1
   lda #15
   sta AUDV1                        ; set to maximum volume
   lda #8
   sta AUDC1
   dec arrowSpawnSoundIndex
   bne CheckToPlayGhostShipSound
   lda #0                           ; done playing Arrow sound
   sta AUDV1
CheckToPlayGhostShipSound
   lda ghostShipSoundIndex
   beq AnimateSneakerGraphics
   lsr                              ; divide value by 2
   sta AUDF1                        ; set frequency value for Ghost Ship
   lda #15
   sta AUDV1                        ; set to maximum volume
   lda #12
   sta AUDC1
   dec ghostShipSoundIndex
   bne AnimateSneakerGraphics
   lda #0
   sta AUDV1
AnimateSneakerGraphics
   dec newSpawnedObstacle
   bpl .checkToMovePlayerShip
   lda #ID_ARROW
   sta newSpawnedObstacle
   lda #>SneakerGraphics
   sta sneakerGraphicPtr + 1        ; set Sneaker MSB value
   lda sneakerGraphicPtr            ; get Sneaker LSB value
   cmp #<SneakerGraphic_00
   bne .setSneakerToFirstAnimation  ; branch if not set to first animation
   lda #<SneakerGraphic_01
   sta sneakerGraphicPtr            ; set Sneaker to second animation
   bne .checkToMovePlayerShip       ; unconditional branch
       
.setSneakerToFirstAnimation
   lda #<SneakerGraphic_00
   sta sneakerGraphicPtr
.checkToMovePlayerShip
   lda playerShipCollisionSoundIndex; get player ship collision sound index
   beq CheckToMovePlayerShip        ; branch if not playing collision sound
   jmp CalculateObjectHMOVEValues
       
CheckToMovePlayerShip
   lda gameState                    ; get current game state
   bmi ReadPlayerJoystickValues     ; branch if game in progress
   lda random + 1
   ldx #3
   stx playerShipVertDelay          ; set so player ship moves this frame
   bne .shiftMovementValues         ; unconditional branch
       
ReadPlayerJoystickValues
   lda SWCHA                        ; read the player joystick values
   cmp #$FF
   bne .shiftMovementValues         ; branch if joystick moved
   jmp .doneCheckToMovePlayerShip
       
.shiftMovementValues
   inc random + 1
   lsr                              ; shift player 1 values to lower nybbles
   lsr
   lsr
   lsr
   eor #$0F                         ; flip movement value bits
   tay                              ; move joystick values to y register
   and #<(~MOVE_RIGHT) >> 4         ; keep MOVE_RIGHT value
   beq .checkForJoystickMovingLeft
   ldx playerShipAlley              ; get Player Ship alley
   lda obstacleList - 1,x           ; get obstacle type in Player Ship alley
   cmp #ID_PRIZE
   beq .checkToMovePlayerShipRight
   lda playerShipHorizPos
   cmp #INIT_PLAYER_SHIP_HORIZ
   beq .facePlayerShipRight
.checkToMovePlayerShipRight
   lda playerShipHorizPos           ; get player ship horizontal position
   cmp #XMAX - 16
   bcs .facePlayerShipRight         ; branch if reached right side
   lda gameState                    ; get current game state
   bpl .facePlayerShipRight         ; branch if game not in progress
   inc playerShipHorizPos           ; move player ship right
   inc playerShipHorizPos           ; move player ship right
.facePlayerShipRight
   lda #NO_REFLECT
   sta playerShipReflectValue
   beq .checkForJoystickMovingUp    ; unconditional branch
       
.checkForJoystickMovingLeft
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_LEFT) >> 4          ; keep MOVE_LEFT value
   beq .checkForJoystickMovingUp
   ldx playerShipAlley              ; get Player Ship alley
   lda obstacleList - 1,x           ; get obstacle type in Player Ship alley
   cmp #ID_PRIZE
   beq .checkToMovePlayerShipLeft
   lda playerShipHorizPos
   cmp #(XMAX / 2) - 6
   beq .facePlayerShipLeft
.checkToMovePlayerShipLeft
   lda playerShipHorizPos
   cmp #XMIN + 8
   bcc .facePlayerShipLeft
   lda gameState                    ; get current game state
   bpl .facePlayerShipLeft          ; branch if game not in progress
   dec playerShipHorizPos
   dec playerShipHorizPos
.facePlayerShipLeft
   lda #REFLECT
   sta playerShipReflectValue
.checkForJoystickMovingUp
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_UP) >> 4            ; keep MOVE_UP value
   beq .checkForJoystickMovingDown  ; branch if joystick not moved up
   inc playerShipVertDelay          ; increment player ship vertical delay value
   lda playerShipVertDelay          ; get player ship vertical delay value
   cmp #4
   bcc .doneCheckToMovePlayerShip   ; branch if not time to move
   lda #0
   sta playerShipVertDelay
   sta ghostShipSpawnTimer          ; clear timer for vertical movement
   lda #14
   sta playerShipVertSoundIndex
   lda playerShipHorizPos
   cmp #(XMAX / 2) - 10
   bcc .doneCheckToMovePlayerShip
   cmp #(XMAX / 2)
   bcs .doneCheckToMovePlayerShip
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos
   inc playerShipAlley              ; move player ship up
   lda playerShipAlley              ; get player ship alley
   cmp #NUM_LANES
   bcc .doneCheckToMovePlayerShip
   lda #NUM_LANES
   sta playerShipAlley
   bpl .doneCheckToMovePlayerShip
       
.checkForJoystickMovingDown
   tya                              ; move joystick values to accumulator
   and #<(~MOVE_DOWN) >> 4          ; keep MOVE_DOWN value
   beq .doneCheckToMovePlayerShip   ; branch if joystick not moved down
   inc playerShipVertDelay          ; increment player ship vertical delay value
   lda playerShipVertDelay          ; get player ship vertical delay value
   cmp #4
   bcc .doneCheckToMovePlayerShip   ; branch if not time to move
   lda #14
   sta playerShipVertSoundIndex
   lda #0
   sta playerShipVertDelay
   sta ghostShipSpawnTimer          ; clear timer for vertical movement
   lda playerShipHorizPos
   cmp #(XMAX / 2) - 10
   bcc .doneCheckToMovePlayerShip
   cmp #(XMAX / 2) - 1
   bcs .doneCheckToMovePlayerShip
   lda #INIT_PLAYER_SHIP_HORIZ
   sta playerShipHorizPos
   dec playerShipAlley              ; move player ship down
   bne .doneCheckToMovePlayerShip
   inc playerShipAlley
.doneCheckToMovePlayerShip
   lda gameState                    ; get current game state
   bpl .playerShipFiringShot        ; branch if game not in progress
   lda INPT4                        ; read left port action button
   bmi CalculateObjectHMOVEValues   ; branch if button not pressed
.playerShipFiringShot
   lda playerShipHorizPos
   cmp #INIT_PLAYER_SHIP_HORIZ
   bne CalculateObjectHMOVEValues
   ldy playerShipAlley              ; get Player Ship alley
   inc random + 1
   dey
   lda playerShipShotHorizPos,y     ; get shot horizontal position
   bne CalculateObjectHMOVEValues   ; branch if Player Shot active in alley
   lda obstacleList,y               ; get obstacle type for lane
   cmp #ID_PRIZE
   beq CalculateObjectHMOVEValues   ; don't allow shots in alley with ID_PRIZE
   lda #(XMAX / 2) - 2
   sta playerShipShotHorizPos,y     ; set player shot inital horizontal position
   lda #14
   sta playerShotSoundIndex
   lda playerShipReflectValue       ; get player ship direction
   bne .setPlayerShotDirToTravelLeft; branch if player ship traveling left
   lda #4
   sta playerShipShotHorizDir,y
   bpl CalculateObjectHMOVEValues   ; unconditional branch
   
.setPlayerShotDirToTravelLeft
   lda #<-4
   sta playerShipShotHorizDir,y
CalculateObjectHMOVEValues
   ldy #15
.calculateObjectHMOVEValues
   lda objectHorizPos,y             ; get object horizontal position
   ldx #1
.determineObjectCoarseValue
   cmp #15
   bcc .setObjectFineCoarsePositionValue
   sec
   sbc #15                          ; divide position value by 15
   inx                              ; increment x for coarse value
   bne .determineObjectCoarseValue  ; unconditional branch
   
.setObjectFineCoarsePositionValue
   stx kernelFCPosValues,y          ; set object coarse value
   tax                              ; shift div15 remainder to x register
   lda ObjectFineHMOVEValues,x      ; get fine motion value based on remainder
   ora kernelFCPosValues,y          ; combine with coarse value
   sta kernelFCPosValues,y          ; set object fine / coarse position value
   dey
   bpl .calculateObjectHMOVEValues
DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC
;--------------------------------------
   sta VBLANK                 ; 3 = @03   enable TIA (i.e. D1 = 0)
   lda #7                     ; 2
   sta currentKernelLane      ; 3
   ldx #H_KERNEL              ; 2
.displayKernel
   sta WSYNC
;--------------------------------------
   cpx #H_KERNEL              ; 2
   beq DrawTurmoilLiteralKernel;2³
.waitForKernelDone
   dex                        ; 2
   beq .doneDisplayKernel     ; 2³
   jmp .displayKernel         ; 3
       
.doneDisplayKernel
   lda #BLACK                 ; 2
   sta COLUPF                 ; 3 = @14
   jmp NewFrame
   
.jmpToDrawScoreKernel
   jmp DrawScoreKernel        ; 3

DrawTurmoilLiteralKernel
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @10
   sta REFP1                  ; 3 = @13
   lda gameState              ; 3         get current game state
   bmi .jmpToDrawScoreKernel  ; 2³        branch if game in progress
   lda laneColor              ; 3
   cmp #ULTRAMARINE_BLUE + 8  ; 2
   bcs .jmpToDrawScoreKernel  ; 2³
   sta HMCLR                  ; 3 = @28
   lda tmpTurmoilLiteralColor ; 3
   sta COLUP0                 ; 3 = @34
   sta COLUP1                 ; 3 = @37
   ldx #4                     ; 2
   sta WSYNC
;--------------------------------------
.skip4Scanlines
   dex                        ; 2
   bne .skip4Scanlines        ; 2³
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_7                    ; 7
   SLEEP 2                    ; 2
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @22
   sta RESP0                  ; 3 = @25
   sta RESP1                  ; 3 = @28
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @08
   sta NUSIZ1                 ; 3 = @11
   lda #H_DIGITS - 1          ; 2
   sta tmpTurmoilFontLoop     ; 3
   sta VDELP0                 ; 3 = @19
   sta VDELP1                 ; 3 = @22
.drawTurmoilLiteral
   ldy tmpTurmoilFontLoop     ; 3
   lda TurmoilLiteral_05,y    ; 4
   sta.w tmpTurmoilLiteral_05 ; 4
   sta WSYNC
;--------------------------------------
   lda TurmoilLiteral_04,y    ; 4
   tax                        ; 2
   lda TurmoilLiteral_00,y    ; 4
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   sta GRP0                   ; 3 = @18
   lda TurmoilLiteral_01,y    ; 4
   sta.w GRP1                 ; 4 = @26
   lda TurmoilLiteral_02,y    ; 4
   sta.w GRP0                 ; 4 = @34
   lda TurmoilLiteral_03,y    ; 4
   ldy.w tmpTurmoilLiteral_05 ; 4
   sta GRP1                   ; 3 = @45
   stx GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sta GRP0                   ; 3 = @54
   dec tmpTurmoilFontLoop     ; 5
   bpl .drawTurmoilLiteral    ; 2³
   lda #0                     ; 2
   sta VDELP0                 ; 3 = @66
   sta VDELP1                 ; 3 = @69
   sta GRP0                   ; 3 = @72
   sta GRP1                   ; 3 = @75
;--------------------------------------
   jmp .doneTopStatusKernel   ; 3 = @02
       
DrawScoreKernel
   sta HMCLR                  ; 3 = @32
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3 = @37
   sta COLUP1                 ; 3 = @40
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @45
   ldx #4                     ; 2
   lda #HMOVE_L1              ; 2
   sta HMP1                   ; 3 = @52
   sta WSYNC
;--------------------------------------
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @05
   sta REFP1                  ; 3 = @08
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
.coarsePositionScoreDigits
   dex                        ; 2
   bne .coarsePositionScoreDigits;2³
   sta RESP0                  ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #<one - 1              ; 2
   sta tmpPlayLevelGraphicPtrs; 3
   lda #>one                  ; 2
   sta tmpPlayLevelGraphicPtrs + 1;3
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @18
   lda #TWO_COPIES            ; 2
   sta NUSIZ1                 ; 3 = @23
   lda gameState              ; 3         get current game state
   bmi .drawScore             ; 2³        branch if game in progress
   lda laneColor              ; 3
   cmp #OLIVE_GREEN + 8       ; 2
   bcc .drawScore             ; 2³
   lda #BRICK_RED + 8         ; 2
   sta COLUP0                 ; 3
   sta COLUP1                 ; 3
   bpl .drawHighScore         ; 3         unconditional branch
   
.drawScore
   ldy tmpScoreIndexValues    ; 3         get value for tens position
   lda (digitGraphicPtrs),y   ; 5         get tens value graphic data
   tax                        ; 2         move tens position graphic data to x
   ldy tmpScoreIndexValues + 3; 3         get value for ten thousands position
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   lda (digitGraphicPtrs),y   ; 5         get ten thousands value graphic data
   ldy tmpScoreIndexValues + 2; 3         get value for thousands position
   sta GRP0                   ; 3 = @13
   lda (digitGraphicPtrs),y   ; 5         get thousands value graphic data
   sta GRP1                   ; 3 = @21
   ldy tmpScoreIndexValues + 1; 3         get value for hundreds position
   lda (digitGraphicPtrs),y   ; 5         get hundreds value graphic data
   sta tmpHundredsGraphic     ; 3
   ldy #<zero                 ; 2
   lda (digitGraphicPtrs),y   ; 5         get ones value graphic data
   ldy tmpHundredsGraphic     ; 3
   sty GRP0                   ; 3 = @45
   stx GRP1                   ; 3 = @48
   sta GRP0                   ; 3 = @51
   dec digitGraphicPtrs       ; 5
   bpl .drawScore             ; 2³
   bmi .doneTopStatusKernel   ; 3         unconditional branch
       
.drawHighScore
   ldy tmpHighScoreIndexValues + 3;3      get value for tens position
   lda (digitGraphicPtrs),y   ; 5         get tens value graphic data
   tax                        ; 2         move tens position graphic data to x
   ldy tmpHighScoreIndexValues; 3         get value for ten thousands position
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   lda (digitGraphicPtrs),y   ; 5         get ten thousands value graphic data
   ldy tmpHighScoreIndexValues + 1;3      get value for thousands position
   sta GRP0                   ; 3 = @13
   lda (digitGraphicPtrs),y   ; 5         get thousands value graphic data
   sta GRP1                   ; 3 = @21
   ldy tmpHighScoreIndexValues + 2;3      get value for hundreds position
   lda (digitGraphicPtrs),y   ; 5         get hundreds value graphic data
   sta tmpHundredsGraphic     ; 3
   ldy #<zero                 ; 2
   lda (digitGraphicPtrs),y   ; 5         get ones value graphic data
   ldy tmpHundredsGraphic     ; 3
   sty GRP0                   ; 3 = @45
   stx GRP1                   ; 3 = @48
   sta GRP0                   ; 3 = @51
   dec digitGraphicPtrs       ; 5
   bpl .drawHighScore         ; 2³
.doneTopStatusKernel
   lda #ONE_COPY              ; 2
   sta NUSIZ1                 ; 3
   sta GRP0                   ; 3
   sta GRP1                   ; 3
   sta GRP0                   ; 3
   sta GRP1                   ; 3
   lda kernelStatus           ; 3         get kernel status
   bne LevelTransitionKernel  ; 2³        branch to show level transition
   jmp GamePlayKernel         ; 3
       
LevelTransitionKernel
   sta WSYNC
;--------------------------------------
   lda #ONE_COPY              ; 2
   sta NUSIZ0                 ; 3 = @05
   lda #H_DIGITS              ; 2
   sta tmpPlayLevelIndex      ; 3
   lda #WHITE                 ; 2
   sta COLUP0                 ; 3 = @15
   sta WSYNC
;--------------------------------------
   ldy gameLevel              ; 3         get current game level
   lda NumberLSBValues,y      ; 4
   sta tmpPlayLevelGraphicPtrs; 3
   lda #>NumberFonts          ; 2
   sta tmpPlayLevelGraphicPtrs + 1;3
   sta WSYNC
;--------------------------------------
   dec transitionKernelBKColor;5
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   inc tmpTransitionKernelPFColorIdx;5
   ldx #H_LEVEL_TRANSITION_KERNEL;2
   ldy transitionKernelBKColor; 3
   lda tmpTransitionKernelPFColorIdx;3
   sta transitionKernelPFColor; 3
   lda #$C8                   ; 2
   sta PF0                    ; 3 = @21
   lda #$3C                   ; 2
   sta PF1                    ; 3 = @26
   lda #$2C                   ; 2
   sta PF2                    ; 3 = @31
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP 2                    ; 2
   sta RESP1                  ; 3 = @42
   sta.w RESP0                ; 4 = @46
   sta COLUP1                 ; 3 = @49
   lda #QUAD_SIZE             ; 2
   sta NUSIZ1                 ; 3 = @54
.levelTransitionKernel
   dec transitionKernelPFColor; 5
   lda transitionKernelPFColor; 3
   sta WSYNC
;--------------------------------------
   sta COLUPF                 ; 3 = @03
   dey                        ; 2
   sty COLUBK                 ; 3 = @08
   cpx #H_LEVEL_TRANSITION_KERNEL - 84;2
   bne .checkToDrawSecondKernelSection;2³
   lda #0                     ; 2
   sta GRP1                   ; 3 = @17
   sta GRP0                   ; 3 = @20
   beq .nextLevelTransitionLine;3         unconditional branch
       
.checkToDrawSecondKernelSection
   bcc .nextLevelTransitionLine;2³
   cpx #H_LEVEL_TRANSITION_KERNEL - 54;2
   bcs .nextLevelTransitionLine;2³
   cpx #H_LEVEL_TRANSITION_KERNEL - 64;2
   bcc .checkToDrawPlayLevel  ; 2³
   lda #$FF                   ; 2
   sta GRP1                   ; 3 = @28
   lda #0                     ; 2
   sta GRP0                   ; 3 = @33
   sta COLUP1                 ; 3 = @36
   beq .nextLevelTransitionLine;3         unconditional branch
       
.checkToDrawPlayLevel
   cpx #H_LEVEL_TRANSITION_KERNEL - 72;2
   bcc .clearPlayLevelGraphics; 2³
   sty tmpTransitionKernelBKColor;3
   ldy tmpPlayLevelIndex      ; 3
   lda (tmpPlayLevelGraphicPtrs),y;5
   sta GRP0                   ; 3 = @42
   dec tmpPlayLevelIndex      ; 5
   ldy tmpTransitionKernelBKColor;3
   bne .nextLevelTransitionLine;2³
.clearPlayLevelGraphics 
   lda #0                     ; 2
   sta GRP0                   ; 3
.nextLevelTransitionLine
   dex                        ; 2
   bne .levelTransitionKernel ; 2³ + 1
   sta WSYNC
;--------------------------------------
   stx COLUPF                 ; 3 = @03
   stx COLUBK                 ; 3 = @06
   stx NUSIZ1                 ; 3 = @09
   ldx #4                     ; 2
.wait4Scanlines
   sta WSYNC
;--------------------------------------
   dex                        ; 2
   bne .wait4Scanlines        ; 2³
   jmp DrawStatusKernel       ; 3
       
GamePlayKernel
   lda #MSBL_SIZE8            ; 2
   sta NUSIZ0                 ; 3
   lda playerShipFCValue      ; 3
   sta HMP0                   ; 3
   and #$0F                   ; 2
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda playerShipReflectValue ; 3         get player ship reflect value
   sta REFP0                  ; 3 = @06
   lda playerShipFCValue      ; 3         waste 3 cycles
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
.coarsePositionPlayerShip
   dex                        ; 2
   bne .coarsePositionPlayerShip;2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta WSYNC
;--------------------------------------
   stx HMP0                   ; 3 = @03
BeginLaneKernel
   ldy currentKernelLane      ; 3
   lda playerShipShotFCValues - 1,y;4     get Player Ship shot HMOVE value
   and #$0F                   ; 2         keep coarse position value
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda playerShipShotFCValues - 1,y;4     get Player Ship shot HMOVE value
   sta HMM0                   ; 3 = @07   set Player Ship fine motion value
   sta CXCLR                  ; 3 = @10   clear all collisions
   lda laneColor              ; 3
   sta COLUPF                 ; 3 = @16
.coarsePositionPlayerShot
   dex                        ; 2
   bne .coarsePositionPlayerShot;2³
   sta RESM0                  ; 3
   sta WSYNC
;--------------------------------------
   lda #$FF                   ; 2
   sta PF0                    ; 3 = @05
   sta PF1                    ; 3 = @08
   lda LanePF2GraphicData,y   ; 4
   sta PF2                    ; 3 = @15
   lda obstacleFCValues - 1,y ; 4
   sta HMP1                   ; 3 = @22
   and #$0F                   ; 2
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   lda obstacleFCValues - 1,y; 4
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
.coarsePositionObstacle
   dex                        ; 2
   bne .coarsePositionObstacle; 2³
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   lda playerShipShotHorizPos - 1,y;4
   beq .playerShotDisabled    ; 2³
   lda #<PlayerShotEnabledGraphicValues;2
   sta playerShipShotPtr      ; 3
   lda #>PlayerShotEnabledGraphicValues;2
   sta playerShipShotPtr + 1  ; 3
   bmi .determineObstacleColorLSBValue;3  unconditional branch
       
.playerShotDisabled
   lda #<BlankGraphic         ; 2 = @09
   sta playerShipShotPtr      ; 3
   lda #>BlankGraphic         ; 2
   sta playerShipShotPtr + 1  ; 3
.determineObstacleColorLSBValue
   lda obstacleList - 1,y     ; 4 = @23   get obstacle type
   tay                        ; 2         shift obstacle type to y register
   cpy #ID_ARROW              ; 2
   beq .setObstacleColorLSBForArrow;2³
   cpy #ID_GHOST_SHIP         ; 2
   beq .setObstacleColorLSBForGhostShip;2³
   cpy #ID_EXPLOSION          ; 2
   bcc .setObstacleColorLSBValue;2³
   lda #<ExplosionColorValues ; 2
   sta obstacleColorPtrs      ; 3
   jmp .setObstacleGraphicLSBAndDirection;3 = @45
       
.setObstacleColorLSBForArrow
.setObstacleColorLSBForGhostShip
   lda #<ArrowAndGhostShipColorValues;2
   sta obstacleColorPtrs      ; 3
   jmp .setObstacleGraphicLSBAndDirection;3
       
.setObstacleColorLSBValue
   lda #<ObstacleColorValues ;2
   sta obstacleColorPtrs;3
.setObstacleGraphicLSBAndDirection
   lda (obstacleGraphicLSBPtr),y;5
   sta obstacleGraphicPtr     ; 3
   ldy currentKernelLane      ; 3
   lda obstacleAttributes - 1,y;4
   and #OBSTACLE_DIR_MASK     ; 2
   bne .obstacleFacingRight   ; 2³
   lda #REFLECT               ; 2
   sta REFP1                  ; 3 = @69
   bpl .checkToDrawPlayerShip ; 3         unconditional branch
       
.obstacleFacingRight
   lda #NO_REFLECT            ; 2
   sta REFP1                  ; 3
.checkToDrawPlayerShip
   cpy playerShipAlley        ; 3
   beq .setToDrawPlayerShip   ; 2³        branch if time to draw player ship
   lda #<BlankGraphic         ; 2
   sta tmpKernelShipGraphicPtr; 3         set player ship to BlankGraphic
   lda #>BlankGraphic         ; 2
   sta tmpKernelShipGraphicPtr + 1;3
   bmi .startDrawKernelLane   ; 3         unconditional branch
       
.setToDrawPlayerShip
   lda playerShipGraphicPtr   ; 3
   sta tmpKernelShipGraphicPtr; 3
   lda playerShipGraphicPtr + 1;3
   sta tmpKernelShipGraphicPtr + 1;3
.startDrawKernelLane
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #0                     ; 2
   sta PF0                    ; 3 = @08
   sta PF1                    ; 3 = @11
   sta PF2                    ; 3 = @14
   dec currentKernelLane      ; 5
   bmi DrawStatusKernel       ; 2³
   jmp DrawKernelLane         ; 3
       
DrawStatusKernel
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @27
   sta REFP1                  ; 3 = @30
   lda gameState              ; 3         get current game state
   bmi DrawReservedShipsKernel; 2³        branch if game in progress
   lda transitionKernelBKColor; 3         waste 3 cycles
   ldy gameLevel              ; 3         get current game level
   lda NumberLSBValues,y      ; 4
   sta tmpPlayLevelGraphicPtrs; 3
   lda #>NumberFonts          ; 2
   sta tmpPlayLevelGraphicPtrs + 1;3
   lda #HMOVE_R4 | 5          ; 2
   sta HMP0                   ; 3
   and #$0F                   ; 2
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   SLEEP_3                    ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
.coarsePositionPlayLevel
   dex                        ; 2
   bne .coarsePositionPlayLevel;2³
   sta RESP0                  ; 3
   sta WSYNC
;--------------------------------------
   lda laneColor              ; 3
   cmp #ULTRAMARINE_BLUE + 8  ; 2
   bcc DrawSneakerKernel      ; 2³
   ldy #H_DIGITS              ; 2
.drawDemoPlayLevelValue
   lda #WHITE                 ; 2
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @03
   lda (tmpPlayLevelGraphicPtrs),y;5
   sta GRP0                   ; 3 = @11
   dey                        ; 2
   bpl .drawDemoPlayLevelValue; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @20
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
.jmpIntoDoneStatusKernel
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta WSYNC
;--------------------------------------
   jmp .doneStatusKernel      ; 3
       
DrawSneakerKernel
   ldy #H_SNEAKERS - 1        ; 2
.drawSneakerKernel
   sta WSYNC
;--------------------------------------
   lda SneakerColorValues,y   ; 4
   sta COLUP0                 ; 3 = @07
   lda (sneakerGraphicPtr),y  ; 5
   sta GRP0                   ; 3 = @15
   dey                        ; 2
   bpl .drawSneakerKernel     ; 2³
   sta WSYNC
;--------------------------------------
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   lda #0                     ; 2
   sta GRP0                   ; 3 = @11
   beq .jmpIntoDoneStatusKernel;3         unconditional branch
       
DrawReservedShipsKernel
   lda #NO_REFLECT            ; 2
   sta REFP0                  ; 3 = @41
   sta REFP1                  ; 3 = @44
   ldy reservedShips          ; 3         get number of reserved ships
   lda GRP0_ReservedLivesLSBValues,y;4
   sta tmpLivesGraphicPtrs_00 ; 3
   lda GRP0_ReservedLivesMSBValues,y;4
   sta tmpLivesGraphicPtrs_00 + 1;3
   lda GRP1_ReservedLivesLSBValues,y;4
   sta tmpLivesGraphicPtrs_01 ; 3
   lda GRP1_ReservedLivesMSBValues,y;4
   sta tmpLivesGraphicPtrs_01 + 1;3
   lda reservedShipsFCValue   ; 3
   sta HMP0                   ; 3
   sta HMP1                   ; 3
   and #$0F                   ; 2
   tax                        ; 2
   sta WSYNC
;--------------------------------------
   ldy reservedShips          ; 3         get number of reserved ships
   lda LeftReservedShipNUSIZValues,y;4
   sta NUSIZ0                 ; 3 = @10
   lda RightReservedShipNUSIZValues,y;4
   sta NUSIZ1                 ; 3 = @17
.coarsePositionReservedShips
   dex                        ; 2
   bne .coarsePositionReservedShips;2³
   sta RESP0                  ; 3
   SLEEP 2                    ; 2
   SLEEP 2                    ; 2
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   SLEEP_3                    ; 3
   sta RESP1                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   ldy #12                    ; 2
.drawReservedShips
   lda (tmpLivesGraphicPtrs_00),y ;5
   ldx PlayerShipColorValues,y; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   stx COLUP0                 ; 3 = @06
   stx COLUP1                 ; 3 = @09
   lda (tmpLivesGraphicPtrs_01),y;5
   sta GRP1                   ; 3 = @17
   dey                        ; 2
   bpl .drawReservedShips     ; 2³
.doneStatusKernel
   ldx #OVERSCAN_SCANLINES    ; 2
   jmp .waitForKernelDone     ; 3
       
DrawKernelLane
   ldy #H_KERNEL_LANE - 1     ; 2
.drawKernelLane 
   lda (obstacleColorPtrs),y  ; 5
   tax                        ; 2
   lda (tmpKernelShipGraphicPtr),y;5
   sta tmpPlayerShipGraphic   ; 3
   lda (playerShipShotPtr),y  ; 5
   sta tmpEnableDisablePlayShot;3
   lda (obstacleGraphicPtr),y ; 5
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda PlayerShipColorValues,y; 4
   sta COLUP0                 ; 3 = @10
   lda tmpEnableDisablePlayShot;3
   sta ENAM0                  ; 3 = @16
   lda tmpPlayerShipGraphic   ; 3
   stx COLUP1                 ; 3 = @22
   sta GRP0                   ; 3 = @25
   dey                        ; 2
   bpl .drawKernelLane        ; 2³
   lda CXPPMM                 ; 3         read player collision values
   bpl .checkPlayerObstacleCollision;2³   branch if players didn't collide
   sta tmpPlayerShipCollisionValue;3
   bmi .jmpToBeginLaneKernel  ; 3         unconditional branch
       
.checkPlayerObstacleCollision
   lda CXM0P                  ; 3         read player missile 0 collision value
   bpl .jmpToBeginLaneKernel  ; 2³        branch if obstacle not shot
   ldy currentKernelLane      ; 3
   lda obstacleShotCollisionValues;3
   ora LaneShotCollisionMaskValues,y;4
   sta obstacleShotCollisionValues;3
.jmpToBeginLaneKernel
   jmp BeginLaneKernel        ; 3

SpawnNewObstacle
   ldx playerShipAlley              ; get Player Ship alley
   dex                              ; decrement for player ship lane
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   bne .newRandom                   ; branch if obstacle moving
   lda ghostShipSpawnTimer          ; get Ghost Ship timer value
   bpl .newRandom                   ; branch if not spawning Ghost Ship
   lda #INIT_GHOST_SHIP_SOUND_INDEX
   sta ghostShipSoundIndex
   lda #ID_GHOST_SHIP
   sta ghostShipSpawnTimer          ; set Ghost Ship timer value
   bne .setNewObstacle              ; spawn Ghost Ship in player ship lane
       
.newRandom 
   jmp NewRandom

DetermineLocationForSpawnedObstacle
   lda random + 1                   ; get random high byte
   lsr                              ; divide value by 32
   lsr
   lsr
   lsr
   lsr
   tax                              ; set for new spawned obstacle position
   beq .checkIfObstaclePresentInPosition; branch if top of list
   dex
.checkIfObstaclePresentInPosition
   lda obstacleHorizPos,x           ; get obstacle horizontal position
   beq .checkIfAllowedToSpawnObstacles; branch if obstacle not present
   ldx tmpObstacleIndex
.checkIfAllowedToSpawnObstacles
   lda newSpawnedObstacle
   ldy playerShipCollisionSoundIndex; get player ship collision sound index
   bne .spawnBlankObstacle          ; branch if playing collision sound
   ldy allowedToSpawnObstacles      ; get value to allow obstacle spawning
   bpl .setNewObstacle              ; branch if obstacle spawning allowed
.spawnBlankObstacle
   lda #ID_BLANK
.setNewObstacle
   tay
   sta obstacleList,x               ; place new obstacle type in list
   cmp #ID_CANNON_BALL
   bne .checkForSpawnedArrow        ; branch if new type not ID_CANNON_BALL
   inc obstacleList,x               ; increment type to ID_ENEMY_FIGHTER_01
.checkForSpawnedArrow
   cmp #ID_ARROW
   bne .determineNewObstacleDirection; branch if new type not ID_ARROW
   lda #INIT_ARROW_SPAWN_SOUND_INDEX
   sta arrowSpawnSoundIndex         ; set sound index value for ID_ARROW
.determineNewObstacleDirection
   lda random
   bpl .placeNewObstacleOnLeft
   lda #XMAX - 5
   sta obstacleHorizPos,x           ; spawn new obstacle on right side
   lda InitSpawnedObstacleSpeedValues,y
   sta obstacleAttributes,x         ; set new obstacle attribute value
   bpl .checkForSpawnedPrize        ; unconditional branch
       
.placeNewObstacleOnLeft
   lda #XMIN + 6
   sta obstacleHorizPos,x           ; spawn new obstacle on left side
   lda #OBSTACLE_DIR_RIGHT
   ora InitSpawnedObstacleSpeedValues,y
   sta obstacleAttributes,x         ; set new obstacle attribute value
.checkForSpawnedPrize
   cpy #ID_PRIZE
   bne .resetMovingObstacleIndex    ; branch if new type not ID_PRIZE
   lda prizeFrameLoopCount          ; get prize frame loop count
   bne .spawnBlankObstacle          ; branch if prize currently present
   lda prizesCollected              ; get number of prizes collected
   cmp #MAX_COLLECTED_PRIZES
   bcs .spawnBlankObstacle          ; spawn ID_BLANK if reached prize limit
   lda #2
   sta prizeFrameLoopCount          ; spawn to ID_CANNON_BALL in ~4 seconds
   stx currentPrizeLane             ; set lane number for ID_PRIZE
   lda #$FF
   sta obstacleAttributes,x         ; set attribute values for ID_PRIZE
.resetMovingObstacleIndex
   lda tmpObstacleIndex
   tax
   rts

SetObstacleValuesForGameLevel
   ldy #NUM_LANES - 1
   ldx gameLevel                    ; get current game level
.setObstacleValuesForGameLevel
   lda InitObstacleHorizPosLSBValues,x
   sta tmpObstacleHorizPosPtrs
   lda #>InitObstacleHorizPosLevel_01
   sta tmpObstacleHorizPosPtrs + 1
   lda (tmpObstacleHorizPosPtrs),y
   sta obstacleHorizPos,y
   lda #0 << 4 | OBSTACLE_DIR_LEFT
   sta obstacleAttributes,y
   lda InitObstacleTypeLSBValues,x
   sta tmpObstacleTypePtrs
   lda (tmpObstacleTypePtrs),y
   sta obstacleList,y
   dey
   bpl .setObstacleValuesForGameLevel
   lda ObstacleSpeedValues,x
   sta obstacleSpeedValue
   rts
       
;
; The following 23 bytes aren't used and come from Fast Eddie
;
   .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$70,$70,$47,$47,$44,$44,$7C
   .byte $FE,$F0,$E0,$E6,$E6,$7C,$38

   BOUNDARY 0
   
ObstacleGraphics
CrawlerGraphic_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $1E ; |...XXXX.|
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
CrawlerGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $08 ; |....X...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte $1E ; |...XXXX.|
BulletGraphic_00
BulletGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
TankGraphic_00
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $D5 ; |XX.X.X.X|
   .byte $AB ; |X.X.X.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $F8 ; |XXXXX...|
   .byte $CF ; |XX..XXXX|
   .byte $F8 ; |XXXXX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $AB ; |X.X.X.XX|
   .byte $D5 ; |XX.X.X.X|
   .byte $7E ; |.XXXXXX.|
PrizeGraphic_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $C3 ; |XX....XX|
   .byte $66 ; |.XX..XX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
Cannon_Ball_Graphic_00
Cannon_Ball_Graphic_01
PrizeGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
TankGraphic_01
   .byte $00 ; |........|
   .byte $7E ; |.XXXXXX.|
   .byte $AB ; |X.X.X.XX|
   .byte $D5 ; |XX.X.X.X|
   .byte $7E ; |.XXXXXX.|
   .byte $18 ; |...XX...|
   .byte $F8 ; |XXXXX...|
   .byte $CF ; |XX..XXXX|
   .byte $F8 ; |XXXXX...|
   .byte $18 ; |...XX...|
   .byte $7E ; |.XXXXXX.|
   .byte $D5 ; |XX.X.X.X|
   .byte $AB ; |X.X.X.XX|
   .byte $7E ; |.XXXXXX.|
EnemyFighterGraphic_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $FF ; |XXXXXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
EnemyFighterGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $81 ; |X......X|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $99 ; |X..XX..X|
   .byte $99 ; |X..XX..X|
   .byte $FF ; |XXXXXXXX|
   .byte $99 ; |X..XX..X|
   .byte $99 ; |X..XX..X|
   .byte $A5 ; |X.X..X.X|
   .byte $C3 ; |XX....XX|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
TieFighterGraphic_00
   .byte $00 ; |........|
   .byte $FE ; |XXXXXXX.|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $10 ; |...X....|
   .byte $FE ; |XXXXXXX.|
TieFighterGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FE ; |XXXXXXX.|
   .byte $10 ; |...X....|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $6C ; |.XX.XX..|
   .byte $7C ; |.XXXXX..|
   .byte $38 ; |..XXX...|
   .byte $10 ; |...X....|
   .byte $FE ; |XXXXXXX.|
   .byte $00 ; |........|
   .byte $00 ; |........|
MissileGraphic_00
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $78 ; |.XXXX...|
   .byte $BE ; |X.XXXXX.|
   .byte $71 ; |.XXX...X|
   .byte $BE ; |X.XXXXX.|
   .byte $78 ; |.XXXX...|
   .byte $60 ; |.XX.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MissileGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $60 ; |.XX.....|
   .byte $B8 ; |X.XXX...|
   .byte $7E ; |.XXXXXX.|
   .byte $B1 ; |X.XX...X|
   .byte $7E ; |.XXXXXX.|
   .byte $B8 ; |X.XXX...|
   .byte $60 ; |.XX.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
BlankGraphic
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
ArrowGraphic_00
ArrowGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $06 ; |.....XX.|
   .byte $0C ; |....XX..|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
GhostShipGraphic_00
GhostShipGraphic_01
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
ExplosionGraphic_00
   .byte $00 ; |........|
   .byte $12 ; |...X..X.|
   .byte $24 ; |..X..X..|
   .byte $22 ; |..X...X.|
   .byte $94 ; |X..X.X..|
   .byte $FA ; |XXXXX.X.|
   .byte $1D ; |...XXX.X|
   .byte $38 ; |..XXX...|
   .byte $7C ; |.XXXXX..|
   .byte $9A ; |X..XX.X.|
   .byte $54 ; |.X.X.X..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $62 ; |.XX...X.|
ExplosionGraphic_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $44 ; |.X...X..|
   .byte $69 ; |.XX.X..X|
   .byte $A5 ; |X.X..X.X|
   .byte $DA ; |XX.XX.X.|
   .byte $7C ; |.XXXXX..|
   .byte $1E ; |...XXXX.|
   .byte $29 ; |..X.X..X|
   .byte $6B ; |.XX.X.XX|
   .byte $58 ; |.X.XX...|
   .byte $50 ; |.X.X....|
   .byte $88 ; |X...X...|

;
; The following 16 bytes aren't used.
;
   .byte $8A,$8A,$8A,$8A,$8A,$8A,$8A,$0F,$0F,$8A,$8A,$8A,$8A,$8A,$00,$00

PlayerShipGraphics
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $FE ; |XXXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $E0 ; |XXX.....|
   .byte $FF ; |XXXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $F8 ; |XXXXX...|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $00 ; |........|
   
LeftReservedShipNUSIZValues
   .byte ONE_COPY, ONE_COPY, TWO_COPIES, THREE_COPIES
   .byte THREE_COPIES, THREE_COPIES, THREE_COPIES

RightReservedShipNUSIZValues
   .byte ONE_COPY, ONE_COPY, ONE_COPY, ONE_COPY
   .byte ONE_COPY, TWO_COPIES, THREE_COPIES

InitObstacleHorizPosLevel_02
InitObstacleHorizPosLevel_06
   .byte 0, 0, 0, 64, 32, 16, 48

InitObstacleHorizPosLevel_03
InitObstacleHorizPosLevel_07
   .byte 0, 0, 64, 16, 48, 32, 56
   
InitObstacleHorizPosLevel_04
InitObstacleHorizPosLevel_08
   .byte 0, 64, 56, 37, 48, 16, 24

InitObstacleTypesLevel_02
InitObstacleTypesLevel_06
   .byte ID_BLANK, ID_BLANK, ID_BLANK, ID_TIE_FIGHTER
   .byte ID_BULLET, ID_MISSILE, ID_BULLET

InitObstacleTypesLevel_03
InitObstacleTypesLevel_07
   .byte ID_BLANK, ID_BLANK, ID_TIE_FIGHTER, ID_TIE_FIGHTER
   .byte ID_BULLET, ID_MISSILE, ID_BULLET

InitObstacleTypesLevel_04
InitObstacleTypesLevel_08
   .byte ID_BLANK, ID_BULLET, ID_BULLET, ID_MISSILE
   .byte ID_MISSILE, ID_TIE_FIGHTER, ID_TIE_FIGHTER

InitObstacleHorizPosLevel_05
InitObstacleHorizPosLevel_09
   .byte 35, 40, 48, 64, 136, 142, 128

InitObstacleTypesLevel_05
InitObstacleTypesLevel_09
   .byte ID_TIE_FIGHTER, ID_MISSILE, ID_BULLET
   .byte ID_CRAWLER, ID_BULLET, ID_BULLET, ID_MISSILE

InitObstacleHorizPosLevel_01
   .byte 0, 0, 0, 0, 32, 64, 16

InitObstacleTypesLevel_01
   .byte ID_BLANK, ID_BLANK, ID_BLANK, ID_BLANK
   .byte ID_MISSILE, ID_TIE_FIGHTER, ID_PRIZE
   
PlayerShipColorValues
   .byte BLACK, RED_ORANGE + 5, RED_ORANGE + 5, RED_ORANGE + 5, BLUE + 11
   .byte BLUE + 9, WHITE, RED_ORANGE + 5, WHITE, BLUE + 9, BLUE + 11
   .byte RED_ORANGE + 5, RED_ORANGE + 5, RED_ORANGE + 5, BLACK
   
ArrowAndGhostShipColorValues
   .byte WHITE, WHITE, BLUE + 10, BLUE + 10, BLUE + 10, BLUE + 10, BLUE + 10
   .byte WHITE, WHITE, BLUE + 10, BLUE + 10, BLUE + 10, BLUE + 10, WHITE, WHITE
   .byte WHITE
   
ExplosionColorValues
   .byte BLACK, RED_ORANGE + 12, RED_ORANGE + 9, RED_ORANGE + 5, RED_ORANGE + 9
   .byte RED_ORANGE + 7, RED_ORANGE + 15, WHITE, RED_ORANGE + 10, RED_ORANGE + 10
   .byte RED_ORANGE + 3, RED_ORANGE + 5, RED_ORANGE + 9, RED_ORANGE + 12

ObstacleColorValues
   .byte BLACK, BRICK_RED + 8, RED + 8, PURPLE + 8, COBALT_BLUE + 8, GREEN + 8
   .byte ORANGE_GREEN + 8, RED_ORANGE + 5, ORANGE_GREEN + 8, GREEN + 8
   .byte PURPLE + 8, RED + 8, BRICK_RED + 8, RED_ORANGE + 8

SneakerGraphics
SneakerGraphic_00
   .byte $07 ; |.....XXX|
   .byte $07 ; |.....XXX|
   .byte $E4 ; |XXX..X..|
   .byte $E4 ; |XXX..X..|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
SneakerGraphic_01
   .byte $E0 ; |XXX.....|
   .byte $E0 ; |XXX.....|
   .byte $27 ; |..X..XXX|
   .byte $27 ; |..X..XXX|
   .byte $24 ; |..X..X..|
   .byte $FF ; |XXXXXXXX|
   .byte $DB ; |XX.XX.XX|
   .byte $DB ; |XX.XX.XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|

SneakerColorValues
   .byte WHITE, WHITE, WHITE, WHITE, WHITE, LT_BLUE + 8
   .byte LT_BLUE + 8, LT_BLUE + 8, LT_BLUE + 8, LT_BLUE + 8

;
; The following 57 bytes aren't used and come from Fast Eddie.
;

   .byte $A5,$99,$6A,$A5,$B1,$6A,$45,$99,$A6,$B1,$85,$B1,$86,$99,$4C,$64
   .byte $FA,$70,$60,$50,$40,$30,$20,$10,$00,$F0,$E0,$D0,$C0,$B0,$A0,$90
   .byte $00,$E0,$0E,$EE,$00,$05,$06,$07,$08,$35,$31,$9E,$BA,$B0,$A0,$90
   .byte $00,$E0,$0E,$EE,$00,$05,$06,$07,$08
   
   BOUNDARY 0
   
NumberFonts
zero
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
one
   .byte $1E ; |...XXXX.|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $1C ; |...XXX..|
   .byte $0C ; |....XX..|
two
   .byte $7F ; |.XXXXXXX|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3E ; |..XXXXX.|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $43 ; |.X....XX|
   .byte $3E ; |..XXXXX.|
three
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $1E ; |...XXXX.|
   .byte $03 ; |......XX|
   .byte $43 ; |.X....XX|
   .byte $3E ; |..XXXXX.|
four
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $7F ; |.XXXXXXX|
   .byte $26 ; |..X..XX.|
   .byte $16 ; |...X.XX.|
   .byte $0E ; |....XXX.|
   .byte $06 ; |.....XX.|
five
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $7F ; |.XXXXXXX|
six
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $7E ; |.XXXXXX.|
   .byte $60 ; |.XX.....|
   .byte $60 ; |.XX.....|
   .byte $3E ; |..XXXXX.|
seven
   .byte $30 ; |..XX....|
   .byte $30 ; |..XX....|
   .byte $10 ; |...X....|
   .byte $08 ; |....X...|
   .byte $04 ; |.....X..|
   .byte $02 ; |......X.|
   .byte $41 ; |.X.....X|
   .byte $7F ; |.XXXXXXX|
eight
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
nine
   .byte $3E ; |..XXXXX.|
   .byte $43 ; |.X....XX|
   .byte $03 ; |......XX|
   .byte $3F ; |..XXXXXX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $63 ; |.XX...XX|
   .byte $3E ; |..XXXXX.|
   
GRP0_ReservedLivesLSBValues
   .byte <BlankGraphic, <PlayerShipGraphics, <PlayerShipGraphics
   .byte <PlayerShipGraphics, <PlayerShipGraphics, <PlayerShipGraphics
   .byte <PlayerShipGraphics
   
GRP1_ReservedLivesLSBValues
   .byte <BlankGraphic, <BlankGraphic, <BlankGraphic, <BlankGraphic
   .byte <PlayerShipGraphics, <PlayerShipGraphics, <PlayerShipGraphics
   
GRP0_ReservedLivesMSBValues
   .byte >BlankGraphic, >PlayerShipGraphics, >PlayerShipGraphics
   .byte >PlayerShipGraphics, >PlayerShipGraphics, >PlayerShipGraphics
   .byte >PlayerShipGraphics
   
GRP1_ReservedLivesMSBValues
   .byte >BlankGraphic, >BlankGraphic, >BlankGraphic, >BlankGraphic
   .byte >PlayerShipGraphics, >PlayerShipGraphics, >PlayerShipGraphics
   
ObstacleGraphicLSBValues_00
   .byte <BlankGraphic
   .byte <Cannon_Ball_Graphic_00
   .byte <EnemyFighterGraphic_00
   .byte <PrizeGraphic_00
   .byte <TieFighterGraphic_00
   .byte <BulletGraphic_00
   .byte <MissileGraphic_00
   .byte <EnemyFighterGraphic_00
   .byte <CrawlerGraphic_00
   .byte <ArrowGraphic_00
   .byte <TankGraphic_00
   .byte <ExplosionGraphic_00
   .byte <GhostShipGraphic_00
   
ObstacleGraphicLSBValues_01
   .byte <BlankGraphic
   .byte <Cannon_Ball_Graphic_01
   .byte <EnemyFighterGraphic_01
   .byte <PrizeGraphic_01
   .byte <TieFighterGraphic_01
   .byte <BulletGraphic_01
   .byte <MissileGraphic_01
   .byte <EnemyFighterGraphic_01
   .byte <CrawlerGraphic_01
   .byte <ArrowGraphic_01
   .byte <TankGraphic_01
   .byte <ExplosionGraphic_01
   .byte <GhostShipGraphic_01
   
InitSpawnedObstacleSpeedValues
   .byte 0 << 4                     ; ID_BLANK
   .byte 0 << 4                     ; ID_CANNON_BALL
   .byte 7 << 4                     ; ID_ENEMY_FIGHTER
   .byte 1 << 4                     ; ID_PRIZE
   .byte 3 << 4                     ; ID_TIE_FIGHTER
   .byte 7 << 4                     ; ID_BULLET
   .byte 0 << 4                     ; ID_MISSILE
   .byte 1 << 4                     ; ID_ENEMY_FIGHTER_02
   .byte 3 << 4                     ; ID_CRAWLER
   .byte 0 << 4                     ; ID_ARROW
   .byte 7 << 4                     ; ID_TANK
   .byte 0 << 4                     ; ID_EXPLOSION
   .byte 0 << 4                     ; ID_GHOST_SHIP
   
PlayerShotEnabledGraphicValues
   .byte DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte -1, -1, -1, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM, DISABLE_BM
   .byte DISABLE_BM

;
; The following 11 bytes aren't used.
;
   .byte $00,$00,$0B,$16,$21,$2C,$37,$42,$4D,$58,$63
   
LaneShotCollisionMaskValues
   .byte 1, 2, 4, 8, 16, 32, 64, 128
   
ObstaclePointValues
   .byte POINT_VALUE_BLANK >> 4, POINT_VALUE_CANNON_BALL >> 4
   .byte POINT_VALUE_FIGHTER_01 >> 4, POINT_VALUE_PRIZE >> 4
   .byte POINT_VALUE_TIE_FIGHTER >> 4, POINT_VALUE_BULLET >> 4
   .byte POINT_VALUE_MISSILE >> 4, POINT_VALUE_FIGHTER_02 >> 4
   .byte POINT_VALUE_CRAWLER >> 4, POINT_VALUE_ARROW >> 4
   .byte POINT_VALUE_TANK >> 4, POINT_VALUE_EXPLOSION >> 4
   .byte POINT_VALIE_GHOST_SHIP >> 4
   
NumberLSBValues
   .byte <one - 1, <two - 1, <three - 1, <four - 1, <five - 1
   .byte <six - 1, <seven - 1, <eight - 1, <nine - 1

;
; The following 53 bytes aren't used and come from Fast Eddie.
;
   .byte $02,$A7,$AD,$FD,$07,$02,$00,$00,$30,$15,$B5,$C5,$95,$E5,$F5,$05
   .byte $A5,$D5,$75,$85,$3C,$4C,$5C,$6C,$7C,$8C,$9C,$AC,$FD,$FD,$FC,$FC
   .byte $FC,$FC,$FC,$FD,$FC,$FC,$FC,$FC,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FD
   .byte $01,$00,$FF,$01,$FF
       
   BOUNDARY 0
   
TurmoilLiteral_00
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $3E ; |..XXXXX.|
TurmoilLiteral_01
   .byte $72 ; |.XXX..X.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8B ; |X...X.XX|
   .byte $8A ; |X...X.X.|
   .byte $8A ; |X...X.X.|
   .byte $8B ; |X...X.XX|
TurmoilLiteral_02
   .byte $28 ; |..X.X...|
   .byte $28 ; |..X.X...|
   .byte $48 ; |.X..X...|
   .byte $8A ; |X...X.X.|
   .byte $CA ; |XX..X.X.|
   .byte $2A ; |..X.X.X.|
   .byte $2D ; |..X.XX.X|
   .byte $C8 ; |XX..X...|
TurmoilLiteral_03
   .byte $9C ; |X..XXX..|
   .byte $A2 ; |X.X...X.|
   .byte $A2 ; |X.X...X.|
   .byte $A2 ; |X.X...X.|
   .byte $A2 ; |X.X...X.|
   .byte $A2 ; |X.X...X.|
   .byte $A2 ; |X.X...X.|
   .byte $9C ; |X..XXX..|
TurmoilLiteral_04
   .byte $FB ; |XXXXX.XX|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $FA ; |XXXXX.X.|
TurmoilLiteral_05
   .byte $E0 ; |XXX.....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
PlayerShipDeathGraphics
PlayerShipDeathGraphics_00
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $FC ; |XXXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FC ; |XXXXXX..|
   .byte $F8 ; |XXXXX...|
   .byte $E0 ; |XXX.....|
   .byte $F8 ; |XXXXX...|
   .byte $F8 ; |XXXXX...|
PlayerShipDeathGraphics_01
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $F8 ; |XXXXX...|
   .byte $A0 ; |X.X.....|
   .byte $98 ; |X..XX...|
   .byte $84 ; |X....X..|
   .byte $AB ; |X.X.X.XX|
   .byte $80 ; |X.......|
   .byte $AB ; |X.X.X.XX|
   .byte $84 ; |X....X..|
   .byte $98 ; |X..XX...|
   .byte $A0 ; |X.X.....|
   .byte $F8 ; |XXXXX...|
   .byte $00 ; |........|
PlayerShipDeathGraphics_02
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $78 ; |.XXXX...|
   .byte $50 ; |.X.X....|
   .byte $48 ; |.X..X...|
   .byte $66 ; |.XX..XX.|
   .byte $57 ; |.X.X.XXX|
   .byte $66 ; |.XX..XX.|
   .byte $48 ; |.X..X...|
   .byte $50 ; |.X.X....|
   .byte $78 ; |.XXXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
PlayerShipDeathGraphics_03
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $30 ; |..XX....|
   .byte $2E ; |..X.XXX.|
   .byte $20 ; |..X.....|
   .byte $2E ; |..X.XXX.|
   .byte $30 ; |..XX....|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PlayerShipDeathGraphics_04
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
PlayerShipDeathGraphics_05
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $10 ; |...X....|
   .byte $18 ; |...XX...|
   .byte $10 ; |...X....|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   
NewRandom
   lda random
   ror
   sta random
   lda random + 1
   ror
   eor random
   ldx random + 1
   sta random + 1
   stx random
   jmp DetermineLocationForSpawnedObstacle
       
NumberOfObstaclesToDestroy
   .byte OBSTACLE_LIMIT_LEVEL_01
   .byte OBSTACLE_LIMIT_LEVEL_02
   .byte OBSTACLE_LIMIT_LEVEL_03
   .byte OBSTACLE_LIMIT_LEVEL_04
   .byte OBSTACLE_LIMIT_LEVEL_05
   .byte OBSTACLE_LIMIT_LEVEL_06
   .byte OBSTACLE_LIMIT_LEVEL_07
   .byte OBSTACLE_LIMIT_LEVEL_08
   .byte OBSTACLE_LIMIT_LEVEL_09
   .byte OBSTACLE_LIMIT_LEVEL_10    ; not used
   
PlayerShipDeathGraphicsLSBValues
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_00
   .byte <PlayerShipDeathGraphics_01
   .byte <PlayerShipDeathGraphics_02
   .byte <PlayerShipDeathGraphics_03
   .byte <PlayerShipDeathGraphics_04
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_05
   .byte <PlayerShipDeathGraphics_04
   .byte <PlayerShipDeathGraphics_03
   .byte <PlayerShipDeathGraphics_02
   .byte <PlayerShipDeathGraphics_01; not used
   
InitObstacleHorizPosLSBValues
   .byte <InitObstacleHorizPosLevel_01
   .byte <InitObstacleHorizPosLevel_02
   .byte <InitObstacleHorizPosLevel_03
   .byte <InitObstacleHorizPosLevel_04
   .byte <InitObstacleHorizPosLevel_05
   .byte <InitObstacleHorizPosLevel_06
   .byte <InitObstacleHorizPosLevel_07
   .byte <InitObstacleHorizPosLevel_08
   .byte <InitObstacleHorizPosLevel_09

InitObstacleTypeLSBValues
   .byte <InitObstacleTypesLevel_01
   .byte <InitObstacleTypesLevel_02
   .byte <InitObstacleTypesLevel_03
   .byte <InitObstacleTypesLevel_04
   .byte <InitObstacleTypesLevel_05
   .byte <InitObstacleTypesLevel_06
   .byte <InitObstacleTypesLevel_07
   .byte <InitObstacleTypesLevel_08
   .byte <InitObstacleTypesLevel_09
   
ObstacleSpeedValues
   .byte 1, 1, 1, 1, 1, 2, 2, 2, 2
   
ObjectFineHMOVEValues
   .byte HMOVE_L7, HMOVE_L6, HMOVE_L5, HMOVE_L4, HMOVE_L3, HMOVE_L2, HMOVE_L1
   .byte HMOVE_0,  HMOVE_R1, HMOVE_R2, HMOVE_R3, HMOVE_R4, HMOVE_R5, HMOVE_R6
   .byte HMOVE_R7
   
LanePF2GraphicData
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $FF ; |XXXXXXXX|
   
ReservedShipsHorizPosValues
   .byte 0, 74, 66, 58, 50, 42, 34

;
; The following 8 bytes aren't used and come from Fast Eddie.
;
   .byte $DD,$E2,$E7,$EC,$F1,$F6,$FB,$FB
       
   .org ROM_BASE + 4096 - 4, 0      ; 4K ROM
   .word Start
   .word Start
