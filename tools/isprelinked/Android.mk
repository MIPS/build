# Copyright 2005 The Android Open Source Project
#
# Android.mk for apriori 
#

LOCAL_PATH:= $(call my-dir)

ifneq ($(TARGET_ARCH),x86)
include $(CLEAR_VARS)

LOCAL_LDLIBS += -ldl
LOCAL_CFLAGS += -O2 -g 
LOCAL_CFLAGS += -fno-function-sections -fno-data-sections -fno-inline 
LOCAL_CFLAGS += -Wall -Wno-unused-function #-Werror
LOCAL_CFLAGS += -DSUPPORT_ANDROID_PRELINK_TAGS
LOCAL_CFLAGS += -DDEBUG

ifeq ($(TARGET_ARCH),arm)
LOCAL_CFLAGS += -DARM_SPECIFIC_HACKS
endif

ifeq ($(HOST_OS),windows)
LOCAL_LDLIBS += -lintl
endif

LOCAL_SRC_FILES := \
	isprelinked.c \
	debug.c \
	prelink_info.c

LOCAL_C_INCLUDES:= \
	$(LOCAL_PATH)/ \
	external/elfutils/lib/ \
	external/elfutils/libelf/ \
	external/elfutils/libebl/ \
	external/elfcopy/

LOCAL_STATIC_LIBRARIES := libelfcopy libelf libebl #dl
ifeq ($(TARGET_ARCH),arm)
LOCAL_STATIC_LIBRARIES += libebl_arm
endif

LOCAL_MODULE := isprelinked

include $(BUILD_HOST_EXECUTABLE)
endif #TARGET_ARCH!=x86
