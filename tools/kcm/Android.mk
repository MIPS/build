# Copyright 2007 The Android Open Source Project
#
# Copies files into the directory structure described by a manifest

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	kcm.cpp

ifeq ($(ARCH_HAS_BIGENDIAN),true)
LOCAL_DEVICE_BYTE_ORDER:=BIG_ENDIAN
else
LOCAL_DEVICE_BYTE_ORDER:=LITTLE_ENDIAN
endif

LOCAL_CFLAGS += -DDEVICE_BYTE_ORDER=$(LOCAL_DEVICE_BYTE_ORDER)

LOCAL_MODULE := kcm

include $(BUILD_HOST_EXECUTABLE)


