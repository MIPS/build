# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_NO_RADIOIMAGE := true
ifeq ($(TARGET_ARCH),arm)
TARGET_CPU_ABI := armeabi
endif
ifeq ($(TARGET_ARCH),mips)
TARGET_CPU_ABI := mipso32
endif
HAVE_HTC_AUDIO_DRIVER := true
BOARD_USES_GENERIC_AUDIO := true
