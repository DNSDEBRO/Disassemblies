#
# Makefile for Millipede
#

#
# --- Defines ---
#
TRUE		:=	1
FALSE		:=	0

#
# --- Project Details ---
#
PROJ		:=	millipede_atari
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
buildall_ntsc: build_original_ntsc build_original_cheat_ntsc build_free_space_ntsc build_free_space_cheat_ntsc
buildall_pal50: build_original_pal50 build_original_cheat_pal50 build_free_space_pal50 build_free_space_cheat_pal50
buildall_pal60: build_original_pal60 build_original_cheat_pal60 build_free_space_pal60 build_free_space_cheat_pal60

#
# --- NTSC Build Rules ---
#
build_original_ntsc: clean_original_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_ORIGINAL_NTSC.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_NTSC.$(BUILDEXT)
build_original_cheat_ntsc: clean_original_cheat_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_ORIGINAL_CHEAT_NTSC.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_CHEAT_NTSC.$(BUILDEXT)
build_free_space_ntsc: clean_free_space_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_FREE_SPACE_NTSC.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_NTSC.$(BUILDEXT)
build_free_space_cheat_ntsc: clean_free_space_cheat_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_FREE_SPACE_CHEAT_NTSC.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_CHEAT_NTSC.$(BUILDEXT)
		
#
# --- PAL50 Build Rules ---
#
build_original_pal50: clean_original_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_ORIGINAL_PAL50.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_PAL50.$(BUILDEXT)
build_original_cheat_pal50: clean_original_cheat_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_ORIGINAL_CHEAT_PAL50.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_CHEAT_PAL50.$(BUILDEXT)
build_free_space_pal50: clean_free_space_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_FREE_SPACE_PAL50.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_PAL50.$(BUILDEXT)
build_free_space_cheat_pal50: clean_free_space_cheat_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_FREE_SPACE_CHEAT_PAL50.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_CHEAT_PAL50.$(BUILDEXT)

#
# --- PAL60 Build Rules ---
#
build_original_pal60: clean_original_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_ORIGINAL_PAL60.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_PAL60.$(BUILDEXT)
build_original_cheat_pal60: clean_original_cheat_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DORIGINAL_ROM=$(TRUE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_ORIGINAL_CHEAT_PAL60.$(LSTEXT) \
		-o$(PROJ)_ORIGINAL_CHEAT_PAL60.$(BUILDEXT)
build_free_space_pal60: clean_free_space_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(FALSE) \
		-l$(PROJ)_FREE_SPACE_PAL60.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_PAL60.$(BUILDEXT)
build_free_space_cheat_pal60: clean_free_space_cheat_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DORIGINAL_ROM=$(FALSE) \
		-DCHEAT_ENABLE=$(TRUE) \
		-l$(PROJ)_FREE_SPACE_CHEAT_PAL60.$(LSTEXT) \
		-o$(PROJ)_FREE_SPACE_CHEAT_PAL60.$(BUILDEXT)

#
# --- NTSC Clean Rules ---
#
clean_original_ntsc:
	@rm -fv $(PROJ)_ORIGINAL_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_NTSC.$(BUILDEXT)
clean_original_cheat_ntsc:
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_NTSC.$(BUILDEXT)
clean_free_space_ntsc:
	@rm -fv $(PROJ)_FREE_SPACE_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_NTSC.$(BUILDEXT)
clean_free_space_cheat_ntsc:
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_NTSC.$(BUILDEXT)

#
# --- PAL50 Clean Rules ---
#
clean_original_pal50:
	@rm -fv $(PROJ)_ORIGINAL_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_PAL50.$(BUILDEXT)
clean_original_cheat_pal50:
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_PAL50.$(BUILDEXT)
clean_free_space_pal50:
	@rm -fv $(PROJ)_FREE_SPACE_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_PAL50.$(BUILDEXT)
clean_free_space_cheat_pal50:
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_PAL50.$(BUILDEXT)

#
# --- PAL60 Clean Rules ---
#
clean_original_pal60:
	@rm -fv $(PROJ)_ORIGINAL_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_PAL60.$(BUILDEXT)
clean_original_cheat_pal60:
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_ORIGINAL_CHEAT_PAL60.$(BUILDEXT)
clean_free_space_pal60:
	@rm -fv $(PROJ)_FREE_SPACE_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_PAL60.$(BUILDEXT)
clean_free_space_cheat_pal60:
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_FREE_SPACE_CHEAT_PAL60.$(BUILDEXT)