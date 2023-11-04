#
# Makefile for Megamania
#

#
# --- Defines ---
#
TRUE		:=	1
FALSE		:=	0

#
# --- Project Details ---
#
PROJ		:=	megamania
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
BUILDEXT	:=	bin

# --- Tool settings ---
ASMFLAGS	:=	-f3 -v3 -I$(INCLUDES)

# --- Build Steps ---
buildall: buildall_ntsc buildall_pal50 buildall_pal60
buildall_ntsc: build_ntsc build_cheat_ntsc
buildall_pal50: build_pal50 build_cheat_pal50
buildall_pal60: build_pal60 build_cheat_pal60

#
# --- NTSC Build Rules ---
#
build_ntsc: clean_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_NTSC.$(LSTEXT) \
		-o$(PROJ)_NTSC.$(BUILDEXT)
build_cheat_ntsc: clean_cheat_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_CHEAT_NTSC.$(LSTEXT) \
		-o$(PROJ)_CHEAT_NTSC.$(BUILDEXT)
#
# --- PAL50 Build Rules ---
#
build_pal50: clean_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_PAL50.$(LSTEXT) \
		-o$(PROJ)_PAL50.$(BUILDEXT)
build_cheat_pal50: clean_cheat_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_CHEAT_PAL50.$(LSTEXT) \
		-o$(PROJ)_CHEAT_PAL50.$(BUILDEXT)
#
# --- PAL60 Build Rules ---
#
build_pal60: clean_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_PAL60.$(LSTEXT) \
		-o$(PROJ)_PAL60.$(BUILDEXT)
build_cheat_pal60: clean_cheat_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_CHEAT_PAL60.$(LSTEXT) \
		-o$(PROJ)_CHEAT_PAL60.$(BUILDEXT)
#
# --- NTSC Clean Rules ---
#
clean_ntsc:
	@rm -fv $(PROJ)_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_NTSC.$(BUILDEXT)
clean_cheat_ntsc:
	@rm -fv $(PROJ)_CHEAT_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_CHEAT_NTSC.$(BUILDEXT)
#
# --- PAL50 Clean Rules ---
#
clean_pal50:
	@rm -fv $(PROJ)_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_PAL50.$(BUILDEXT)
clean_cheat_pal50:
	@rm -fv $(PROJ)_CHEAT_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_CHEAT_PAL50.$(BUILDEXT)
#
# --- PAL60 Clean Rules ---
#
clean_pal60:
	@rm -fv $(PROJ)_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_PAL60.$(BUILDEXT)
clean_cheat_pal60:
	@rm -fv $(PROJ)_CHEAT_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_CHEAT_PAL60.$(BUILDEXT)