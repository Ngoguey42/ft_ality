
UNAME			:= $(shell uname | cut -c1-6)

# ============================================================================ #
# Modules

# Git submodule to init
MODULES					:=

# ============================================================================ #
# Sources Directories

# include search path for .o dependencies
MKGEN_INCLUDESDIRS		:=
# Obj files directory
MKGEN_OBJDIR			:= _build
# mkgenml 'ocamlfind ocamldep -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o'

# Source files directories
MKGEN_SRCSDIRS_TERMBYTE	:= src/shared src/terminal
MKGEN_OBJSUFFIX_TERMBYTE:= {'mli': 'cmi', 'ml': 'cmo'}

MKGEN_SRCSDIRS_TERMNAT	:= src/shared src/terminal
MKGEN_OBJSUFFIX_TERMNAT	:= {'mli': 'cmi', 'ml': 'cmx'}

MKGEN_SRCSDIRS_BROWSER	:= src/shared src/browser
MKGEN_OBJSUFFIX_BROWSER	:= {'mli': 'cmi', 'ml': 'cmo'}

# mkgen -> MKGEN_SRCSBIN_* variables
# mkgen -> $(MKGEN_OBJDIR)/**/*.o rules

# ============================================================================ #
# Default  flags
BASE_FLAGS		=
HEAD_FLAGS		= $(addprefix -I ,$(INCLUDEDIRS))
LD_FLAGS		=

MAKEFLAGS		+= -j

# ============================================================================ #
# Build mode
#	NAME		link; target
#	CC_LD		link; ld
#	SRCSBIN		separate compilation; sources
#	INCLUDEDIRS	separate compilation; sources includes path
#	LIBSBIN		link; dependancies
#	LIBSMAKE	separate compilation; makefiles to call

BUILD_MODE ?= browser

ifeq ($(BUILD_MODE),termbyte)
  NAME			:= ft_ality
  CC_LD			= $(CC_OCAMLC)

  SRCSBIN		= $(MKGEN_SRCSBIN_TERMBYTE) #gen by mkgen
  INCLUDEDIRS	= $(addprefix $(MKGEN_OBJDIR)/,$(MKGEN_SRCSDIRS_TERMBYTE))

else ifeq ($(BUILD_MODE),termnat)
  NAME			:= ft_ality
  CC_LD			= $(CC_OCAMLOPT)

  SRCSBIN		= $(MKGEN_SRCSBIN_TERMNAT) #gen by mkgen
  INCLUDEDIRS	= $(addprefix $(MKGEN_OBJDIR)/,$(MKGEN_SRCSDIRS_TERMNAT))

else ifeq ($(BUILD_MODE),browser)
  NAME			:= $(MKGEN_OBJDIR)/ft_ality
  NAME2			:= $(MKGEN_OBJDIR)/ft_ality.js
  CC_LD			= $(CC_OCAMLC)
  CC_OCAMLC		= ocamlfind ocamlc
  LD_FLAGS		= -linkpkg
  BASE_FLAGS	+= -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o

  SRCSBIN		= $(MKGEN_SRCSBIN_BROWSER) #gen by mkgen
  INCLUDEDIRS	= $(addprefix $(MKGEN_OBJDIR)/,$(MKGEN_SRCSDIRS_BROWSER))

endif

# ============================================================================ #
# Compilers
C_FLAGS			= $(HEAD_FLAGS) $(BASE_FLAGS)
CPP_FLAGS		= $(HEAD_FLAGS) $(BASE_FLAGS) -std=c++14
ML_FLAGS		= $(HEAD_FLAGS) $(BASE_FLAGS)

ifeq ($(UNAME),CYGWIN)
  CC_C			= x86_64-w64-mingw32-gcc
  CC_CPP		= x86_64-w64-mingw32-g++
  CC_AR			= x86_64-w64-mingw32-ar
  ifeq ($(CC_LD),$(CC_CPP))
    LD_FLAGS	+= -static
  endif
else
  CC_OCAMLC		?= ocamlc.opt
  CC_OCAMLOPT	= ocamlopt.opt
  CC_OCAMLJS	= js_of_ocaml
  CC_C			= clang
  CC_CPP		= clang++
  CC_AR			= ar
endif

ifeq ($(CC_LD),$(CC_AR))
  LD_FLAGS_		= rcs $@ $(LD_FLAGS)
else
  LD_FLAGS_		= -o $@ $(LD_FLAGS) $(BASE_FLAGS)
endif


# ============================================================================ #
# Misc
MODULE_RULES	:= $(addsuffix /.git,$(MODULES))
PRINT_OK		= printf '  \033[32m$<\033[0m\n'
PRINT_LINK		= printf '\033[32m$@\033[0m\n'
PRINT_MAKE		= printf '\033[32mmake $@\033[0m\n'
DEPEND			:= depend.mk
SHELL			:= /bin/bash

# ============================================================================ #
# Rules

# Default rule (needed to be before any include)
all: _all_git

-include $(DEPEND)

_all_git: $(MODULE_RULES)
	$(MAKE) _all_libs

_all_libs: $(LIBSMAKE)
	$(MAKE) _all_separate_compilation

_all_separate_compilation: $(SRCSBIN)
	$(MAKE) _all_linkage

_all_linkage: $(NAME)
	$(MAKE) _all_linkage2

_all_linkage2: $(NAME2)

# Linking
$(NAME): $(LIBSBIN) $(SRCSBIN)
# ocamlfind ocamlc -package js_of_ocaml,js_of_ocaml.syntax -syntax camlp4o -linkpkg -only-show $(LD_FLAGS_) $(filter-out %.cmi,$(SRCSBIN)) && $(PRINT_LINK)
	$(CC_LD) $(LD_FLAGS_) $(SRCSBIN) && $(PRINT_LINK)

%.js: $(NAME)
	$(CC_OCAMLJS) -o $@ $(NAME) && $(PRINT_LINK)


# Compiling
$(MKGEN_OBJDIR)/%.o: %.c
	$(CC_C) $(C_FLAGS) -c $< -o $@ && $(PRINT_OK)
$(MKGEN_OBJDIR)/%.o: %.cpp
	$(CC_CPP) $(CPP_FLAGS) -c $< -o $@ && $(PRINT_OK)
$(MKGEN_OBJDIR)/%.o: %.cc
	$(CC_CPP) $(CPP_FLAGS) -c $< -o $@ && $(PRINT_OK)
$(MKGEN_OBJDIR)/%.cmo: %.ml
	$(CC_OCAMLC) $(ML_FLAGS) -o $@ -c $< && $(PRINT_OK)
$(MKGEN_OBJDIR)/%.cmx: %.ml
	$(CC_OCAMLOPT) $(ML_FLAGS) -o $@ -c $< && $(PRINT_OK)
$(MKGEN_OBJDIR)/%.cmi: %.mli
	$(CC_OCAMLC) $(ML_FLAGS) -o $@ -c $< && $(PRINT_OK)

# Init submodules
$(MODULE_RULES):
	git submodule init $(@:.git=)
	git submodule update $(@:.git=)

# Compile libs
$(LIBSMAKE):
	$(MAKE) $@ && $(PRINT_MAKE)

# Create obj directories
$(MKGEN_OBJDIR)/%/:
	mkdir -p $@

# Clean obj files
clean:
	rm -f $(SRCSBIN)

# Clean everything
fclean: clean
	rm -f $(NAME)

# Clean and make
re: fclean
	$(MAKE) all


# ============================================================================ #
# Special targets
# .SILENT:
.PHONY: all clean fclean re _all_git _all_libs _all_separate_compilation _all_linkage $(LIBSMAKE)
