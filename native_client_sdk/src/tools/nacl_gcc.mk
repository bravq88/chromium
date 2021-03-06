# Copyright (c) 2012 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

#
# GNU Make based build file.  For details on GNU Make see:
#   http://www.gnu.org/software/make/manual/make.html
#

#
# Macros for TOOLS
#
# We always link with the C++ compiler but include -Wl,-as-needed flag
# in LDFLAGS so the linker should drop libc++ unless it's actually needed.
#
X86_32_CC := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=cc)
X86_32_CXX := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=c++)
X86_32_LINK := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=c++)
X86_32_LIB := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=ar)
X86_32_STRIP := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=strip)
X86_32_NM := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_32 --tool=nm)

X86_64_CC := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=cc)
X86_64_CXX := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=c++)
X86_64_LINK := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=c++)
X86_64_LIB := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=ar)
X86_64_STRIP := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=strip)
X86_64_NM := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a x86_64 --tool=nm)

ifneq ($(TOOLCHAIN),glibc)
ARM_CC := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=cc)
ARM_CXX := $(NACL_COMPILER_PREFIX) $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=c++)
ARM_LINK := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=c++)
ARM_LIB := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=ar)
ARM_STRIP := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=strip)
ARM_NM := $(shell $(NACL_CONFIG) -t $(TOOLCHAIN) -a arm --tool=nm)
endif

NCVAL ?= python $(NACL_SDK_ROOT)/tools/ncval.py

# Architecture-specific flags
X86_32_CFLAGS ?=
X86_64_CFLAGS ?=
ARM_CFLAGS ?=

X86_32_CXXFLAGS ?=
X86_64_CXXFLAGS ?=
ARM_CXXFLAGS ?=

X86_32_LDFLAGS ?= -Wl,-Map,$(OUTDIR)/$(TARGET)_x86_32.map
X86_64_LDFLAGS ?= -Wl,-Map,$(OUTDIR)/$(TARGET)_x86_64.map
ARM_LDFLAGS ?= -Wl,-Map,$(OUTDIR)/$(TARGET)_arm.map

LDFLAGS_SHARED = -shared

#
# Compile Macro
#
# $1 = Source Name
# $2 = Compile Flags
#
define C_COMPILER_RULE
-include $(call SRC_TO_DEP,$(1),_x86_32)
$(call SRC_TO_OBJ,$(1),_x86_32): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(X86_32_CC) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(X86_32_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_32)

-include $(call SRC_TO_DEP,$(1),_x86_64)
$(call SRC_TO_OBJ,$(1),_x86_64): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(X86_64_CC) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(X86_64_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_64)

-include $(call SRC_TO_DEP,$(1),_arm)
$(call SRC_TO_OBJ,$(1),_arm): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(ARM_CC) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(ARM_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_arm)

-include $(call SRC_TO_DEP,$(1),_x86_32_pic)
$(call SRC_TO_OBJ,$(1),_x86_32_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(X86_32_CC) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(X86_32_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_32_pic)

-include $(call SRC_TO_DEP,$(1),_x86_64_pic)
$(call SRC_TO_OBJ,$(1),_x86_64_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(X86_64_CC) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(X86_64_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_64_pic)

-include $(call SRC_TO_DEP,$(1),_arm_pic)
$(call SRC_TO_OBJ,$(1),_arm_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CC  ,$$@,$(ARM_CC) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CFLAGS) $(ARM_CFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_arm_pic)
endef

define CXX_COMPILER_RULE
-include $(call SRC_TO_DEP,$(1),_x86_32)
$(call SRC_TO_OBJ,$(1),_x86_32): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(X86_32_CXX) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(X86_32_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_32)

-include $(call SRC_TO_DEP,$(1),_x86_64)
$(call SRC_TO_OBJ,$(1),_x86_64): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(X86_64_CXX) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(X86_64_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_64)

-include $(call SRC_TO_DEP,$(1),_arm)
$(call SRC_TO_OBJ,$(1),_arm): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(ARM_CXX) -o $$@ -c $$< $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(ARM_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_arm)

-include $(call SRC_TO_DEP,$(1),_x86_32_pic)
$(call SRC_TO_OBJ,$(1),_x86_32_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(X86_32_CXX) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(X86_32_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_32_pic)

-include $(call SRC_TO_DEP,$(1),_x86_64_pic)
$(call SRC_TO_OBJ,$(1),_x86_64_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(X86_64_CXX) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(X86_64_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_x86_64_pic)

-include $(call SRC_TO_DEP,$(1),_arm_pic)
$(call SRC_TO_OBJ,$(1),_arm_pic): $(1) $(TOP_MAKE) | $(dir $(call SRC_TO_OBJ,$(1)))dir.stamp
	$(call LOG,CXX ,$$@,$(ARM_CXX) -o $$@ -c $$< -fPIC $(POSIX_FLAGS) $(2) $(NACL_CXXFLAGS) $(ARM_CXXFLAGS))
	@$(FIXDEPS) $(call SRC_TO_DEP_PRE_FIXUP,$(1),_arm_pic)
endef


#
# $1 = Source Name
# $2 = POSIX Compile Flags
# $3 = Include Directories
# $4 = VC Flags (unused)
#
define COMPILE_RULE
ifeq ($(suffix $(1)),.c)
$(call C_COMPILER_RULE,$(1),$(2) $(foreach inc,$(INC_PATHS),-I$(inc)) $(3))
else
$(call CXX_COMPILER_RULE,$(1),$(2) $(foreach inc,$(INC_PATHS),-I$(inc)) $(3))
endif
endef

#
# Determine which architectures to build for.  The user can set NACL_ARCH or
# ARCHES in the environment to control this.
#
VALID_ARCHES := x86_32 x86_64
ifeq (newlib,$(TOOLCHAIN))
VALID_ARCHES += arm
endif

ifdef NACL_ARCH
ifeq (,$(findstring $(NACL_ARCH),$(VALID_ARCHES)))
$(error Invalid arch specified in NACL_ARCH: $(NACL_ARCH).  Valid values are: $(VALID_ARCHES))
endif
ARCHES = ${NACL_ARCH}
else
ARCHES ?= ${VALID_ARCHES}
endif

GLIBC_REMAP :=

#
# SO Macro
#
# As well as building and installing a shared library this rule adds dependencies
# on the library's .stamp file in STAMPDIR.  However, the rule for creating the stamp
# file is part of LIB_RULE, so users of the DEPS system are currently required to
# use the LIB_RULE macro as well as the SO_RULE for each shared library.
#
# $1 = Target Name
# $2 = List of Sources
# $3 = List of LIBS
# $4 = List of DEPS
# $5 = Library Paths
# $6 = 1 => Don't add to NMF.
#
define SO_LINKER_RULE
ifneq (,$(findstring x86_32,$(ARCHES)))
all: $(OUTDIR)/lib$(1)_x86_32.so
$(OUTDIR)/lib$(1)_x86_32.so: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_32_pic)) $(foreach dep,$(4),$(STAMPDIR)/$(dep).stamp)
	$(call LOG,LINK,$$@,$(X86_32_LINK) -o $$@ $$(filter %.o,$$^) $(LDFLAGS_SHARED) -m32 $(NACL_LDFLAGS) $(X86_32_LDFLAGS) $(LDFLAGS) $(foreach path,$(5),-L$(path)/$(TOOLCHAIN)_x86_32/$(CONFIG)) $(foreach lib,$(3),-l$(lib)))
	$(call LOG,VALIDATE,$$@,$(NCVAL) $$@)

$(STAMPDIR)/$(1).stamp: $(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).so
install: $(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).so
$(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).so: $(OUTDIR)/lib$(1)_x86_32.so
	$(MKDIR) -p $$(dir $$@)
	$(call LOG,CP  ,$$@,$(OSHELPERS) cp $$^ $$@)
ifneq ($(6),1)
GLIBC_SO_LIST += $(OUTDIR)/lib$(1)_x86_32.so
GLIBC_REMAP += -n lib$(1)_x86_32.so,lib$(1).so
endif
endif

ifneq (,$(findstring x86_64,$(ARCHES)))
all: $(OUTDIR)/lib$(1)_x86_64.so
$(OUTDIR)/lib$(1)_x86_64.so: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_64_pic)) $(foreach dep,$(4),$(STAMPDIR)/$(dep).stamp)
	$(call LOG,LINK,$$@,$(X86_32_LINK) -o $$@ $$(filter %.o,$$^) $(LDFLAGS_SHARED) -m64 $(NACL_LDFLAGS) $(X86_64_LDFLAGS) $(LDFLAGS) $(foreach path,$(5),-L$(path)/$(TOOLCHAIN)_x86_64/$(CONFIG)) $(foreach lib,$(3),-l$(lib)))
	$(call LOG,VALIDATE,$$@,$(NCVAL) $$@)

$(STAMPDIR)/$(1).stamp: $(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).so
install: $(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).so
$(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).so: $(OUTDIR)/lib$(1)_x86_64.so
	$(MKDIR) -p $$(dir $$@)
	$(call LOG,CP  ,$$@,$(OSHELPERS) cp $$^ $$@)
ifneq ($(6),1)
GLIBC_SO_LIST += $(OUTDIR)/lib$(1)_x86_64.so
GLIBC_REMAP += -n lib$(1)_x86_64.so,lib$(1).so
endif
endif
endef

#
# $1 = Target Name
# $2 = List of Sources
# $3 = List of LIBS
# $4 = List of DEPS
# $5 = 1 => Don't add to NMF.
#
define SO_RULE
$(call SO_LINKER_RULE,$(1),$(2),$(filter-out pthread,$(3)),$(4),$(LIB_PATHS),$(5))
endef

#
# LIB Macro
#
# $1 = Target Name
# $2 = List of Sources
# $3 = POSIX Link Flags
# $4 = VC Link Flags (unused)
#
define LIB_RULE
$(STAMPDIR)/$(1).stamp:
	@echo "  STAMP $$@"
	@echo "TOUCHED $$@" > $(STAMPDIR)/$(1).stamp

ifneq (,$(findstring x86_32,$(ARCHES)))
all: $(OUTDIR)/lib$(1)_x86_32.a
$(OUTDIR)/lib$(1)_x86_32.a: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_32))
	$(MKDIR) -p $$(dir $$@)
	$(RM) -f $$@
	$(call LOG,LIB ,$$@,$(X86_32_LIB) -cr $$@ $$^)

$(STAMPDIR)/$(1).stamp: $(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).a
install: $(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).a
$(LIBDIR)/$(TOOLCHAIN)_x86_32/$(CONFIG)/lib$(1).a: $(OUTDIR)/lib$(1)_x86_32.a
	$(MKDIR) -p $$(dir $$@)
	$(RM) -f $$@
	$(call LOG,CP  ,$$@,$(OSHELPERS) cp $$^ $$@)
endif

ifneq (,$(findstring x86_64,$(ARCHES)))
all: $(OUTDIR)/lib$(1)_x86_64.a
$(OUTDIR)/lib$(1)_x86_64.a: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_64))
	$(MKDIR) -p $$(dir $$@)
	$(RM) -f $$@
	$(call LOG,LIB ,$$@,$(X86_64_LIB) -cr $$@ $$^)

$(STAMPDIR)/$(1).stamp: $(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).a
install: $(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).a
$(LIBDIR)/$(TOOLCHAIN)_x86_64/$(CONFIG)/lib$(1).a: $(OUTDIR)/lib$(1)_x86_64.a
	$(MKDIR) -p $$(dir $$@)
	$(call LOG,CP  ,$$@,$(OSHELPERS) cp $$^ $$@)
endif

ifneq (,$(findstring arm,$(ARCHES)))
ifneq ($(TOOLCHAIN),glibc)
all: $(OUTDIR)/lib$(1)_arm.a
$(OUTDIR)/lib$(1)_arm.a: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_arm))
	$(MKDIR) -p $$(dir $$@)
	$(RM) -f $$@
	$(call LOG,LIB ,$$@,$(ARM_LIB) -cr $$@ $$^)

$(STAMPDIR)/$(1).stamp: $(LIBDIR)/$(TOOLCHAIN)_arm/$(CONFIG)/lib$(1).a
install: $(LIBDIR)/$(TOOLCHAIN)_arm/$(CONFIG)/lib$(1).a
$(LIBDIR)/$(TOOLCHAIN)_arm/$(CONFIG)/lib$(1).a: $(OUTDIR)/lib$(1)_arm.a
	$(MKDIR) -p $$(dir $$@)
	$(call LOG,CP  ,$$@,$(OSHELPERS) cp $$^ $$@)
endif
endif
endef


#
# Specific Link Macro
#
# $1 = Target Name
# $2 = List of Sources
# $3 = List of LIBS
# $4 = List of DEPS
# $5 = Link Flags
# $6 = Library Paths
#
define LINKER_RULE
ifneq (,$(findstring x86_32,$(ARCHES)))
all: $(OUTDIR)/$(1)_x86_32.nexe
$(OUTDIR)/$(1)_x86_32.nexe: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_32)) $(foreach dep,$(4),$(STAMPDIR)/$(dep).stamp)
	$(call LOG,LINK,$$@,$(X86_32_LINK) -o $$@ $$(filter %.o,$$^) $(NACL_LDFLAGS) $(X86_32_LDFLAGS) $(foreach path,$(6),-L$(path)/$(TOOLCHAIN)_x86_32/$(CONFIG)) $(foreach lib,$(3),-l$(lib)) $(5))
	$(call LOG,VALIDATE,$$@,$(NCVAL) $$@)
endif

ifneq (,$(findstring x86_64,$(ARCHES)))
all: $(OUTDIR)/$(1)_x86_64.nexe
$(OUTDIR)/$(1)_x86_64.nexe: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_x86_64)) $(foreach dep,$(4),$(STAMPDIR)/$(dep).stamp)
	$(call LOG,LINK,$$@,$(X86_64_LINK) -o $$@ $$(filter %.o,$$^) $(NACL_LDFLAGS) $(X86_64_LDFLAGS) $(foreach path,$(6),-L$(path)/$(TOOLCHAIN)_x86_64/$(CONFIG)) $(foreach lib,$(3),-l$(lib)) $(5))
	$(call LOG,VALIDATE,$$@,$(NCVAL) $$@)
endif

ifneq (,$(findstring arm,$(ARCHES)))
all: $(OUTDIR)/$(1)_arm.nexe
$(OUTDIR)/$(1)_arm.nexe: $(foreach src,$(2),$(call SRC_TO_OBJ,$(src),_arm)) $(foreach dep,$(4),$(STAMPDIR)/$(dep).stamp)
	$(call LOG,LINK,$$@,$(ARM_LINK) -o $$@ $$(filter %.o,$$^) $(NACL_LDFLAGS) $(ARM_LDFLAGS) $(foreach path,$(6),-L$(path)/$(TOOLCHAIN)_arm/$(CONFIG)) $(foreach lib,$(3),-l$(lib)) $(5))
	$(call LOG,VALIDATE,$$@,$(NCVAL) $$@)
endif
endef


#
# Generalized Link Macro
#
# $1 = Target Name
# $2 = List of Sources
# $3 = List of LIBS
# $4 = List of DEPS
# $5 = POSIX Linker Switches
# $6 = VC Linker Switches
#
define LINK_RULE
$(call LINKER_RULE,$(1),$(2),$(filter-out pthread,$(3)),$(4),$(5),$(LIB_PATHS))
endef


#
# Strip Macro for each arch (e.g., each arch supported by LINKER_RULE).
#
# $1 = Target Name
# $2 = Source Name
#
define STRIP_ALL_RULE
ifneq (,$(findstring x86_32,$(ARCHES)))
$(OUTDIR)/$(1)_x86_32.nexe: $(OUTDIR)/$(2)_x86_32.nexe
	$(call LOG,STRIP,$$@,$(X86_32_STRIP) -o $$@ $$^)
endif

ifneq (,$(findstring x86_64,$(ARCHES)))
$(OUTDIR)/$(1)_x86_64.nexe: $(OUTDIR)/$(2)_x86_64.nexe
	$(call LOG,STRIP,$$@,$(X86_64_STRIP) -o $$@ $$^)
endif

ifneq (,$(findstring arm,$(ARCHES)))
$(OUTDIR)/$(1)_arm.nexe: $(OUTDIR)/$(2)_arm.nexe
	$(call LOG,STRIP,$$@,$(ARM_STRIP) -o $$@ $$^)
endif
endef


#
# Top-level Strip Macro
#
# $1 = Target Basename
# $2 = Source Basename
#
define STRIP_RULE
$(call STRIP_ALL_RULE,$(1),$(2))
endef


#
# Strip Macro for each arch (e.g., each arch supported by MAP_RULE).
#
# $1 = Target Name
# $2 = Source Name
#
define MAP_ALL_RULE
ifneq (,$(findstring x86_32,$(ARCHES)))
all: $(OUTDIR)/$(1)_x86_32.map
$(OUTDIR)/$(1)_x86_32.map: $(OUTDIR)/$(2)_x86_32.nexe
	$(call LOG,MAP,$$@,$(X86_32_NM) -l $$^ > $$@)
endif

ifneq (,$(findstring x86_64,$(ARCHES)))
all: $(OUTDIR)/$(1)_x86_64.map
$(OUTDIR)/$(1)_x86_64.map: $(OUTDIR)/$(2)_x86_64.nexe
	$(call LOG,MAP,$$@,$(X86_64_NM) -l $$^ > $$@)
endif

ifneq (,$(findstring arm,$(ARCHES)))
all: $(OUTDIR)/$(1)_arm.map
$(OUTDIR)/$(1)_arm.map: $(OUTDIR)/$(2)_arm.nexe
	$(call LOG,MAP,$$@,$(ARM_NM) -l $$^ > $$@ )
endif
endef


#
# Top-level MAP Generation Macro
#
# $1 = Target Basename
# $2 = Source Basename
#
define MAP_RULE
$(call MAP_ALL_RULE,$(1),$(2))
endef


#
# Generate ARCH_SUFFIXES, a list of suffixes for executables corresponding to all
# the architectures in the current build.
#
ARCH_SUFFIXES := $(foreach arch,$(ARCHES),_$(arch).nexe)


#
# NMF Manifiest generation
#
# Use the python script create_nmf to scan the binaries for dependencies using
# objdump.  Pass in the (-L) paths to the default library toolchains so that we
# can find those libraries and have it automatically copy the files (-s) to
# the target directory for us.
#
# $1 = Target Name (the basename of the nmf
# $2 = Additional create_nmf.py arguments
#
NMF := python $(NACL_SDK_ROOT)/tools/create_nmf.py
ifeq ($(CONFIG),Debug)
NMF_FLAGS += --debug-libs
HTML_FLAGS += --debug-libs
endif

EXECUTABLES=$(foreach arch,$(ARCH_SUFFIXES),$(OUTDIR)/$(1)$(arch)) $(GLIBC_SO_LIST)

define NMF_RULE
all: $(OUTDIR)/$(1).nmf
$(OUTDIR)/$(1).nmf: $(EXECUTABLES)
	$(call LOG,CREATE_NMF,$$@,$(NMF) $(NMF_FLAGS) -o $$@ $$^ $(GLIBC_PATHS) -s $(OUTDIR) $(2) $(GLIBC_REMAP))
endef

#
# HTML file generation
#
CREATE_HTML := python $(NACL_SDK_ROOT)/tools/create_html.py

define HTML_RULE
all: $(OUTDIR)/$(1).html
$(OUTDIR)/$(1).html: $(EXECUTABLES)
	$(call LOG,CREATE_HTML,$$@,$(CREATE_HTML) $(HTML_FLAGS) -o $$@ $$^)
endef


#
# Determine which executable to pass into the debugger.  For newlib
# this is the NEXE which will actually be used.  For glibc, runnable-ld.so
# is the "app", and the "app" is actual an .so we load.
#
ifeq (x86_32,$(SYSARCH))
LIB_NAME = lib32
else
LIB_NAME = lib64
endif


ifeq (newlib,$(TOOLCHAIN))
GDB_DEBUG_TARGET = $(abspath $(OUTDIR))/$(TARGET)_$(SYSARCH).nexe
else
GDB_DEBUG_TARGET = $(abspath $(OUTDIR))/$(LIB_NAME)/runnable-ld.so
endif

ifdef STANDALONE
run: all
ifndef NACL_ARCH
	$(error Cannot run in sel_ldr unless $$NACL_ARCH is set)
endif
	$(SEL_LDR_PATH) $(SEL_LDR_ARGS) $(OUTDIR)/$(TARGET)_$(NACL_ARCH).nexe -- $(EXE_ARGS)

debug: all
ifndef NACL_ARCH
	$(error Cannot run in sel_ldr unless $$NACL_ARCH is set)
endif
	$(SEL_LDR_PATH) -d $(SEL_LDR_ARGS) $(OUTDIR)/$(TARGET)_$(NACL_ARCH).nexe -- $(EXE_ARGS)
endif
