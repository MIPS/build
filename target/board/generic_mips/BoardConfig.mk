# BoardConfig.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true

TARGET_ARCH := mips
ifeq (,$(TARGET_ARCH_VARIANT))
TARGET_ARCH_VARIANT := mips32r2-fp
endif

ifeq (,$(findstring -eb,$(TARGET_ARCH_VARIANT)))

ifneq (,$(findstring -fp,$(TARGET_ARCH_VARIANT)))
# Hard Float LE
ifeq (,$(findstring r2,$(TARGET_ARCH_VARIANT)))
TARGET_CPU_ABI  := mips
else
TARGET_CPU_ABI  := mips-r2
TARGET_CPU_ABI2 := mips
endif
else
# Soft Float LE
ifeq (,$(findstring r2,$(TARGET_ARCH_VARIANT)))
TARGET_CPU_ABI  := mips-sf
else
TARGET_CPU_ABI  := mips-r2-sf
TARGET_CPU_ABI2 := mips-sf
endif
endif

else # BE systems

ifneq (,$(findstring -fp,$(TARGET_ARCH_VARIANT)))
# Hard Float BE
ifeq (,$(findstring r2,$(TARGET_ARCH_VARIANT)))
TARGET_CPU_ABI  := mips-eb
else
TARGET_CPU_ABI  := mips-eb-r2
TARGET_CPU_ABI2 := mips-eb
endif
else
# Soft Float BE
ifeq (,$(findstring r2,$(TARGET_ARCH_VARIANT)))
TARGET_CPU_ABI  := mips-eb-sf
else
TARGET_CPU_ABI  := mips-eb-r2-sf
TARGET_CPU_ABI2 := mips-eb-sf
endif
endif

endif

HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true

# no hardware camera
USE_CAMERA_STUB := true

# Set /system/bin/sh to ash, not mksh, to make sure we can switch back.
TARGET_SHELL := ash

# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
  ifeq ($(WITH_DEXPREOPT),)
    WITH_DEXPREOPT := true
  endif
endif

# Build OpenGLES emulation guest and host libraries
BUILD_EMULATOR_OPENGL := true

# Build and enable the OpenGL ES View renderer. When running on the emulator,
# the GLES renderer disables itself if host GL acceleration isn't available.
USE_OPENGL_RENDERER := true
