#
# Copyright 2017 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_PROPERTY_OVERRIDES += \
	rild.libpath=/vendor/lib/libreference-ril.so

# Note: the following lines need to stay at the beginning so that it can
# take priority  and override the rules it inherit from other mk files
# see copy file rules in core/Makefile
PRODUCT_COPY_FILES += \
    development/sys-img/advancedFeatures.ini.arm:advancedFeatures.ini \
    device/generic/goldfish/fstab.ranchu.mips:root/fstab.ranchu \
    device/generic/goldfish/fstab.ranchu.early.arm:root/fstab.ranchu.early

ifeq ($(filter mips32r5 mips32r6,$(TARGET_ARCH_VARIANT)),)
PRODUCT_COPY_FILES += \
    prebuilts/qemu-kernel/mips/ranchu/kernel-qemu:kernel-ranchu
else
PRODUCT_COPY_FILES += \
    prebuilts/qemu-kernel/mips/ranchu/kernel-qemu-$(TARGET_ARCH_VARIANT):kernel-ranchu
endif

include $(SRC_TARGET_DIR)/product/full_mips.mk

PRODUCT_NAME := aosp_mips
