# Configuration for Linux on MIPS.
# Included by combo/select.make

# Set default values for target flags
# TARGET_CPU_ARCH:	Used in -march=$(TARGET_CPU_ARCH)
# TARGET_CPU_TUNE:	Used in -mtune=$(TARGET_CPU_TUNE)
# TARGET_CPU_FLOAT:	Used in -m$(TARGET_CPU_FLOAT)
# TARGET_CPU_ENDIAN:	Used in -$(TARGET_CPU_ENDIAN)
ifeq ($(strip $(TARGET_CPU_ARCH)),)
TARGET_CPU_ARCH := mips32r2
$(warning Defaulted TARGET_CPU_ARCH to $(TARGET_CPU_ARCH))
endif
ifeq ($(strip $(TARGET_CPU_TUNE)),)
$(echo Defaulting TARGET_CPU_TUNE)
TARGET_CPU_TUNE := mips32r2
$(warning Defaulted TARGET_CPU_TUNE to $(TARGET_CPU_TUNE))
endif
ifeq ($(strip $(TARGET_CPU_FLOAT)),)
TARGET_CPU_FLOAT := soft-float
$(warning Defaulted TARGET_CPU_FLOAT to $(TARGET_CPU_FLOAT))
endif
ifeq ($(strip $(TARGET_CPU_ENDIAN)),)
TARGET_CPU_ENDIAN := EL
$(warning Defaulted TARGET_CPU_ENDIAN to $(TARGET_CPU_ENDIAN))
endif

# You can set TARGET_TOOLS_PREFIX to get gcc from somewhere else
ifeq ($(strip $($(combo_target)TOOLS_PREFIX)),)
$(combo_target)TOOLS_PREFIX := \
	prebuilt/$(HOST_PREBUILT_TAG)/toolchain/mips-4.3/bin/mips-linux-gnu-
endif

$(combo_target)CC := $($(combo_target)TOOLS_PREFIX)gcc$(HOST_EXECUTABLE_SUFFIX) -$(TARGET_CPU_ENDIAN)
$(combo_target)CXX := $($(combo_target)TOOLS_PREFIX)g++$(HOST_EXECUTABLE_SUFFIX) -$(TARGET_CPU_ENDIAN)
$(combo_target)AR := $($(combo_target)TOOLS_PREFIX)ar$(HOST_EXECUTABLE_SUFFIX)
$(combo_target)OBJCOPY := $($(combo_target)TOOLS_PREFIX)objcopy$(HOST_EXECUTABLE_SUFFIX)
$(combo_target)LD := $($(combo_target)TOOLS_PREFIX)ld$(HOST_EXECUTABLE_SUFFIX)

$(combo_target)NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

TARGET_mips_CFLAGS :=	-O2 \
			-fomit-frame-pointer \
			-fstrict-aliasing    \
			-funswitch-loops     \
			-finline-limit=300

# Set FORCE_MIPS_DEBUGGING to "true" in your buildspec.mk
# or in your environment to gdb debugging easier.
# Don't forget to do a clean build.
ifeq ($(FORCE_MIPS_DEBUGGING),true)
  TARGET_mips_CFLAGS := $(TARGET_mips_CFLAGS) -fno-omit-frame-pointer
endif

$(combo_target)GLOBAL_CFLAGS += \
			-Ulinux \
			-march=$(TARGET_CPU_ARCH) -mtune=$(TARGET_CPU_TUNE) -m$(TARGET_CPU_FLOAT) \
			-fpic \
			-ffunction-sections \
			-funwind-tables \
			-include $(call select-android-config-h,linux-mips)

$(combo_target)GLOBAL_CPPFLAGS += -fvisibility-inlines-hidden \
				-fno-use-cxa-atexit

$(combo_target)RELEASE_CFLAGS := \
			-DSK_RELEASE -DNDEBUG \
			-g \
			-Wstrict-aliasing=2 \
			-finline-functions \
			-fno-inline-functions-called-once \
			-fgcse-after-reload \
			-frerun-cse-after-loop \
			-frename-registers

ifneq ($(wildcard $($(combo_target)CC)),)
# We compile with the global cflags to ensure that any flags which affect selection of
# libgcc are correctly taken into account.
$(combo_target)LIBGCC := \
	$(shell $($(combo_target)CC) $($(combo_target)GLOBAL_CFLAGS) -print-file-name=libgcc.a) \
	$(shell $($(combo_target)CC) $($(combo_target)GLOBAL_CFLAGS) -print-file-name=libgcc_eh.a)
endif

libc_root := bionic/libc
libm_root := bionic/libm
libstdc++_root := bionic/libstdc++
libthread_db_root := bionic/libthread_db

# unless CUSTOM_KERNEL_HEADERS is defined, we're going to use
# symlinks located in out/ to point to the appropriate kernel
# headers. see 'config/kernel_headers.make' for more details
#
ifneq ($(CUSTOM_KERNEL_HEADERS),)
    KERNEL_HEADERS_COMMON := $(CUSTOM_KERNEL_HEADERS)
    KERNEL_HEADERS_ARCH   := $(CUSTOM_KERNEL_HEADERS)
else
    KERNEL_HEADERS_COMMON := $(libc_root)/kernel/common
    KERNEL_HEADERS_ARCH   := $(libc_root)/kernel/arch-$(TARGET_ARCH)
endif
KERNEL_HEADERS := $(KERNEL_HEADERS_COMMON) $(KERNEL_HEADERS_ARCH)

$(combo_target)C_INCLUDES := \
	$(libc_root)/arch-mips/include \
	$(libc_root)/include \
	$(libstdc++_root)/include \
	$(KERNEL_HEADERS) \
	$(libm_root)/include \
	$(libm_root)/include/arch/mips \
	$(libthread_db_root)/include

TARGET_CRTBEGIN_STATIC_O := $(TARGET_OUT_STATIC_LIBRARIES)/crtbegin_static.o
TARGET_CRTBEGIN_DYNAMIC_O := $(TARGET_OUT_STATIC_LIBRARIES)/crtbegin_dynamic.o
TARGET_CRTEND_O := $(TARGET_OUT_STATIC_LIBRARIES)/crtend_android.o

TARGET_STRIP_MODULE:=true

$(combo_target)DEFAULT_SYSTEM_SHARED_LIBRARIES := libc libstdc++ libm

$(combo_target)CUSTOM_LD_COMMAND := true
define transform-o-to-shared-lib-inner
$(TARGET_CXX) \
	-nostdlib -Wl,-soname,$(notdir $@) -Wl,-T,$(BUILD_SYSTEM)/mipself.xsc \
	-Wl,--gc-sections \
	-Wl,-shared,-Bsymbolic \
	$(TARGET_GLOBAL_LD_DIRS) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(call normalize-target-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	-o $@ \
	$(PRIVATE_LDFLAGS) \
	$(TARGET_LIBGCC)
endef

define transform-o-to-executable-inner
$(TARGET_CXX) -nostdlib -Bdynamic -Wl,-T,$(BUILD_SYSTEM)/mipself.x \
	-Wl,-dynamic-linker,/system/bin/linker \
	-Wl,--gc-sections \
	-Wl,-z,nocopyreloc \
	-o $@ \
	$(TARGET_GLOBAL_LD_DIRS) \
	-Wl,-rpath-link=$(TARGET_OUT_INTERMEDIATE_LIBRARIES) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	$(TARGET_CRTBEGIN_DYNAMIC_O) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(PRIVATE_LDFLAGS) \
	$(TARGET_LIBGCC) \
	$(TARGET_CRTEND_O)
endef

define transform-o-to-static-executable-inner
$(TARGET_CXX) -nostdlib -Bstatic -Wl,-T,$(BUILD_SYSTEM)/mipself.x \
        -Wl,--gc-sections \
	-o $@ \
	$(TARGET_GLOBAL_LD_DIRS) \
	$(TARGET_CRTBEGIN_STATIC_O) \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_ALL_OBJECTS) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(TARGET_LIBGCC) \
	$(TARGET_CRTEND_O)
endef
