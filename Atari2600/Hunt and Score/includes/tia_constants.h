; TIA_CONSTANTS.H
; Version 1.01, 25/JULY/2022

VERSION_TIA_CONSTANTS	= 101

;
; This file defines TIA constants useful for development for the Atari 2600.
;
; Latest Revisions...
;
; 1.01  22/JULY/2022	- Added COMPILE_REGION constants
;						- Added COMPILE_REGION compile switch
;						- Added color constants

;-------------------------------------------------------------------------------
;
; COMPILE_REGION constants

NTSC                    = 0
PAL50                   = 1
PAL60                   = 2

;-------------------------------------------------------------------------------
;
; COMPILE_REGION
; The COMPILE_REGION defines the region for the ROM build. This defines 3
; unique regions (0 = NTSC, 1 = PAL50, 2 = PAL60). If a COMPILE_REGION is not
; defined then the build is assumed to be for NTSC.
; An invalid COMPILE_REGION value will cause the build to fail.

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

;-------------------------------------------------------------------------------
;
; Color constants
; These are color constant values I use when building VCS games. The NTSC values
; come from the Atari Explorer ... magazine
;
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
DK_BLUE                 = $90
CYAN                    = $A0
OLIVE_GREEN             = $B0
GREEN                   = $C0
DK_GREEN                = $D0
ORANGE_GREEN            = $E0
BROWN                   = $F0

	ELSE

GREY_01					= $10
YELLOW					= $20
ORANGE_GREEN			= $20
DK_GREEN				= $30
RED_ORANGE				= $40
BRICK_RED				= $40
BROWN					= $40
GREEN					= $50
RED						= $60
OLIVE_GREEN				= $70
PURPLE					= $80
CYAN					= $90
COLBALT_BLUE			= $A0
DK_BLUE					= $B0
ULTRAMARINE_BLUE		= $C0
BLUE					= $D0
GREY_02					= $F0

	ENDIF

;-------------------------------------------------------------------------------
;
; Horizontal Motion Values
; These are horizontal motion values used to adjust the player horizontal
; position.
;
HMOVE_L7          		= $70		; move 7 pixels left  (-7)
HMOVE_L6          		= $60		; move 6 pixels left  (-6)
HMOVE_L5          		= $50		; move 5 pixels left  (-5)
HMOVE_L4          		= $40		; move 4 pixels left  (-4)
HMOVE_L3          		= $30		; move 3 pixels left  (-3)
HMOVE_L2          		= $20		; move 2 pixels left  (-2)
HMOVE_L1          		= $10		;  move 1 pixel left  (-1)
HMOVE_0           		= $00		; no motion			  (0)
HMOVE_R1          		= $F0		;  move 1 pixel right (+1)
HMOVE_R2          		= $E0		; move 2 pixels right (+2)
HMOVE_R3          		= $D0		; move 3 pixels right (+3)
HMOVE_R4          		= $C0		; move 4 pixels right (+4)
HMOVE_R5          		= $B0		; move 5 pixels right (+5)
HMOVE_R6          		= $A0		; move 6 pixels right (+6)
HMOVE_R7          		= $90		; move 7 pixels right (+7)
HMOVE_R8          		= $80		; move 8 pixels right (+8)

; values for ENAMx and ENABL
DISABLE_BM        = %00
ENABLE_BM         = %10

; values for RESMPx
LOCK_MISSILE      = %10
UNLOCK_MISSILE    = %00

; values for REFPx:
NO_REFLECT        = %0000
REFLECT           = %1000

; values for NUSIZx:
ONE_COPY          = %000
TWO_COPIES        = %001
TWO_MED_COPIES    = %010
THREE_COPIES      = %011
TWO_WIDE_COPIES   = %100
DOUBLE_SIZE       = %101
THREE_MED_COPIES  = %110
QUAD_SIZE         = %111
MSBL_SIZE1        = %000000
MSBL_SIZE2        = %010000
MSBL_SIZE4        = %100000
MSBL_SIZE8        = %110000

; values for CTRLPF:
PF_PRIORITY       = %100
PF_SCORE          = %10
PF_REFLECT        = %01
PF_NO_REFLECT     = %00

; values for SWCHB
P1_DIFF_MASK      = %10000000
P0_DIFF_MASK      = %01000000
BW_MASK           = %00001000
SELECT_MASK       = %00000010
RESET_MASK        = %00000001

VERTICAL_DELAY    = 1

; SWCHA joystick bits:
MOVE_RIGHT        = %01111111
MOVE_LEFT         = %10111111
MOVE_DOWN         = %11011111
MOVE_UP           = %11101111
P0_JOYSTICK_MASK  = %11110000
P1_JOYSTICK_MASK  = %00001111
P0_NO_MOVE        = P0_JOYSTICK_MASK
P1_NO_MOVE        = P1_JOYSTICK_MASK
NO_MOVE           = P0_NO_MOVE | P1_NO_MOVE
P0_HORIZ_MOVE     = MOVE_RIGHT & MOVE_LEFT & P0_NO_MOVE
P0_VERT_MOVE      = MOVE_UP & MOVE_DOWN & P0_NO_MOVE
P1_HORIZ_MOVE     = [(MOVE_RIGHT & MOVE_LEFT) >> 4] & P1_NO_MOVE
P1_VERT_MOVE      = [(MOVE_UP & MOVE_DOWN) >> 4] & P1_NO_MOVE

; SWCHA paddle bits:
P0_TRIGGER_PRESSED = %01111111
P1_TRIGGER_PRESSED = %10111111
P2_TRIGGER_PRESSED = %11110111
P3_TRIGGER_PRESSED = %11111011

; values for VBLANK:
DUMP_PORTS        = %10000000
ENABLE_LATCHES    = %01000000
DISABLE_TIA       = %00000010
ENABLE_TIA        = %00000000

;values for VSYNC:
START_VERT_SYNC   = %10
STOP_VERT_SYNC    = %00

;===============================================================================
; C O L O R - C O N S T A N T S
;===============================================================================

