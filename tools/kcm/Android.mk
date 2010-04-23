# Copyright 2007 The Android Open Source Project
#
# Copies files into the directory structure described by a manifest

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	kcm.cpp

ifeq ($(TARGET_ARCH),mips)
LOCAL_CFLAGS += -DMIPS_SPECIFIC_HACKS
ifeq ($(TARGET_CPU_ENDIAN),EB)
LOCAL_CFLAGS += -DBYTE_ORDER_BIG_ENDIAN=1
endif
endif

LOCAL_MODULE := kcm

include $(BUILD_HOST_EXECUTABLE)


