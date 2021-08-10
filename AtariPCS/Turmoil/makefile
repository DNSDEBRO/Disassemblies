#
# Makefile for Turmoil
#

#
# --- Project Details ---
#
PROJ		:=	turmoil
ASM		:=	dasm

#
# --- Assembler Switch Values ---
#
CANDY		:=	0
CX5200		:=	1

#
# --- Build Defines ---
#
ASMEXT		:=	asm
LSTEXT		:=	lst
EXT		:=	bin

PROJ_ASMEXT	:=	$(PROJ).$(ASMEXT)
PROJ_LST	:=	$(PROJ).$(LSTEXT)
PROJ_BIN	:=	$(PROJ).$(EXT)

# --- Tool settings ---
ASMFLAGS	:=	-f3 -v3
PROJ_FLAGS	:=	$(ASMFLAGS) -DATARI=$(CANDY)

# --- Build Steps ---
buildall: build
cleanall: clean

# --- Build Rules ---
build: clean
	$(ASM) $(PROJ_ASMEXT) $(PROJ_FLAGS) -l$(PROJ_LST) -o$(PROJ_BIN)

# --- Clean ---
clean:
	@rm -fv $(PROJ_LST)
	@rm -fv $(PROJ_BIN)