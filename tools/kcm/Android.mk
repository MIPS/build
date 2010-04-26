# Copyright 2007 The Android Open Source Project
#
# Copies files into the directory structure described by a manifest

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	kcm.cpp

LOCAL_DEVICE_BYTE_ORDER:=LITTLE_ENDIAN

ifeq ($(TARGET_ARCH),mips)
ifeq ($(TARGET_CPU_ENDIAN),EB)
LOCAL_DEVICE_BYTE_ORDER:=BIG_ENDIAN
endif
endif

LOCAL_CFLAGS += -DDEVICE_BYTE_ORDER=$(LOCAL_DEVICE_BYTE_ORDER)

LOCAL_MODULE := kcm

include $(BUILD_HOST_EXECUTABLE)


