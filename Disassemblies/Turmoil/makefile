#
# Makefile for Turmoil
#

#
# --- Project Details ---
#
PROJ		:=	turmoil
INCLUDES	:=	$(DEVDASM)\machines\atari2600
ASM		:=	dasm

#
# --- Compile Region Variables ---
#
NTSC		:=	0
PAL50		:=	1
PAL60		:=	2

#
# --- Build Defines ---
#
ASMEXT		:=	asm
LSTEXT		:=	lst
EXT		:=	bin

PROJ_ASMEXT	:=	$(PROJ).$(ASMEXT)

PROJ_NTSC	:=	$(PROJ)_NTSC

PROJ_NTSC_LST	:=	$(PROJ_NTSC).$(LSTEXT)

PROJ_NTSC_BIN	:=	$(PROJ_NTSC).$(EXT)

# --- Tool settings ---
ASMFLAGS	:=	-f3 -v3 -I$(INCLUDES)
PROJ_NTSC_FLAGS	:=	$(ASMFLAGS) -DCOMPILE_REGION=$(NTSC)

# --- Build Steps ---
buildall: buildntsc
cleanall: cleanntsc

# --- Build Rules ---
buildntsc: cleanntsc
	$(ASM) $(PROJ_ASMEXT) $(PROJ_NTSC_FLAGS) -l$(PROJ_NTSC_LST) -o$(PROJ_NTSC_BIN)

# --- Clean ---
cleanntsc:
	@rm -fv $(PROJ_NTSC_LST)
	@rm -fv $(PROJ_NTSC_BIN)