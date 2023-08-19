#
# Makefile for Asteroids
#

#
# --- Defines ---
#
TRUE		:=	1
FALSE		:=	0

#
# --- Project Details ---
#
PROJ		:=	asteroids
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
buildall: build_copyright build_nocopyright
build_copyright: build_copyright_ntsc build_copyright_pal50 build_copyright_pal60
build_nocopyright: build_nocopyright_ntsc build_nocopyright_pal50 build_nocopyright_pal60

#
# --- Copyright Build Rules ---
#
build_copyright_ntsc: clean_copyright_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DCOPYRIGHT_ROM=$(TRUE) \
		-l$(PROJ)_COPYRIGHT_NTSC.$(LSTEXT) \
		-o$(PROJ)_COPYRIGHT_NTSC.$(BUILDEXT)
build_copyright_pal50: clean_copyright_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DCOPYRIGHT_ROM=$(TRUE) \
		-l$(PROJ)_COPYRIGHT_PAL50.$(LSTEXT) \
		-o$(PROJ)_COPYRIGHT_PAL50.$(BUILDEXT)
build_copyright_pal60: clean_copyright_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DCOPYRIGHT_ROM=$(TRUE) \
		-l$(PROJ)_COPYRIGHT_PAL60.$(LSTEXT) \
		-o$(PROJ)_COPYRIGHT_PAL60.$(BUILDEXT)
#
# --- No Copyright Build Rules ---
#
build_nocopyright_ntsc: clean_nocopyright_ntsc
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(NTSC) \
		-DCOPYRIGHT_ROM=$(FALSE) \
		-l$(PROJ)_NO_COPYRIGHT_NTSC.$(LSTEXT) \
		-o$(PROJ)_NO_COPYRIGHT_NTSC.$(BUILDEXT)
build_nocopyright_pal50: clean_nocopyright_pal50
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL50) \
		-DCOPYRIGHT_ROM=$(FALSE) \
		-l$(PROJ)_NO_COPYRIGHT_PAL50.$(LSTEXT) \
		-o$(PROJ)_NO_COPYRIGHT_PAL50.$(BUILDEXT)
build_nocopyright_pal60: clean_nocopyright_pal60
	$(ASM) $(PROJ).$(ASMEXT) \
		$(ASMFLAGS) \
		-DCOMPILE_REGION=$(PAL60) \
		-DCOPYRIGHT_ROM=$(FALSE) \
		-l$(PROJ)_NO_COPYRIGHT_PAL60.$(LSTEXT) \
		-o$(PROJ)_NO_COPYRIGHT_PAL60.$(BUILDEXT)
#
# --- Copyright Clean Rules ---
#
clean_copyright_ntsc:
	@rm -fv $(PROJ)_COPYRIGHT_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_COPYRIGHT_NTSC.$(BUILDEXT)
clean_copyright_pal50:
	@rm -fv $(PROJ)_COPYRIGHT_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_COPYRIGHT_PAL50.$(BUILDEXT)
clean_copyright_pal60:
	@rm -fv $(PROJ)_COPYRIGHT_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_COPYRIGHT_PAL60.$(BUILDEXT)
#
# --- No Copyright Clean Rules ---
#
clean_nocopyright_ntsc:
	@rm -fv $(PROJ)_NO_COPYRIGHT_NTSC.$(LSTEXT)
	@rm -fv $(PROJ)_NO_COPYRIGHT_NTSC.$(BUILDEXT)
clean_nocopyright_pal50:
	@rm -fv $(PROJ)_NO_COPYRIGHT_PAL50.$(LSTEXT)
	@rm -fv $(PROJ)_NO_COPYRIGHT_PAL50.$(BUILDEXT)
clean_nocopyright_pal60:
	@rm -fv $(PROJ)_NO_COPYRIGHT_PAL60.$(LSTEXT)
	@rm -fv $(PROJ)_NO_COPYRIGHT_PAL60.$(BUILDEXT)