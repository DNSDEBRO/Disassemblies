#
# Makefile for Sky Diver
#

#
# --- Project Details ---
#
PROJ		:=	sky_diver
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
PROJ_PAL50	:=	$(PROJ)_PAL50
PROJ_PAL60	:=	$(PROJ)_PAL60

PROJ_NTSC_LST	:=	$(PROJ_NTSC).$(LSTEXT)
PROJ_PAL50_LST	:=	$(PROJ_PAL50).$(LSTEXT)
PROJ_PAL60_LST	:=	$(PROJ_PAL60).$(LSTEXT)

PROJ_NTSC_BIN	:=	$(PROJ_NTSC).$(EXT)
PROJ_PAL50_BIN	:=	$(PROJ_PAL50).$(EXT)
PROJ_PAL60_BIN	:=	$(PROJ_PAL60).$(EXT)


# --- Tool settings ---
ASMFLAGS	:=	-f3 -v3 -I$(INCLUDES)
PROJ_NTSC_FLAGS	:=	$(ASMFLAGS) -DCOMPILE_REGION=$(NTSC)
PROJ_PAL50_FLAGS:=	$(ASMFLAGS) -DCOMPILE_REGION=$(PAL50)
PROJ_PAL60_FLAGS:=	$(ASMFLAGS) -DCOMPILE_REGION=$(PAL60)

# --- Build Steps ---
buildall: buildntsc buildpal50 buildpal60
cleanall: cleanntsc cleanpal50 cleanpal60

# --- Build Rules ---
buildntsc: cleanntsc
	$(ASM) $(PROJ_ASMEXT) $(PROJ_NTSC_FLAGS) -l$(PROJ_NTSC_LST) -o$(PROJ_NTSC_BIN)
buildpal50: cleanpal50
	$(ASM) $(PROJ_ASMEXT) $(PROJ_PAL50_FLAGS) -l$(PROJ_PAL50_LST) -o$(PROJ_PAL50_BIN)
buildpal60: cleanpal60
	$(ASM) $(PROJ_ASMEXT) $(PROJ_PAL60_FLAGS) -l$(PROJ_PAL60_LST) -o$(PROJ_PAL60_BIN)

# --- Clean ---
cleanntsc:
	@rm -fv $(PROJ_NTSC_LST)
	@rm -fv $(PROJ_NTSC_BIN)
cleanpal50:
	@rm -fv $(PROJ_PAL50_LST)
	@rm -fv $(PROJ_PAL50_BIN)
cleanpal60:
	@rm -fv $(PROJ_PAL60_LST)
	@rm -fv $(PROJ_PAL60_BIN)