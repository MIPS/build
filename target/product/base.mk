#
# Copyright (C) 2012 The Android Open Source Project
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

# Base modules (will move elsewhere, previously user tagged)
PRODUCT_PACKAGES += \
    20-dns.conf \
    95-configured \
    org.apache.http.legacy.boot \
    appwidget \
    appops \
    am \
    android.policy \
    android.test.mock \
    android.test.runner \
    app_process \
    applypatch \
    audioserver \
    bit \
    blkid \
    bmgr \
    bpfloader \
    bugreport \
    bugreportz \
    cameraserver \
    content \
    dnsmasq \
    dpm \
    framework \
    framework-sysconfig.xml \
    fsck_msdos \
    hid \
    ime \
    incidentd \
    incident \
    incident_report \
    input \
    javax.obex \
    libandroid \
    libandroid_runtime \
    libandroid_servers \
    libaudioeffect_jni \
    libaudioflinger \
    libaudiopolicyservice \
    libaudiopolicymanager \
    libbundlewrapper \
    libcamera_client \
    libcameraservice \
    libcamera2ndk \
    libdl \
    libdrmclearkeyplugin \
    libclearkeycasplugin \
    libeffectproxy \
    libeffects \
    libinput \
    libinputflinger \
    libiprouteutil \
    libjnigraphics \
    libldnhncr \
    libmedia \
    libmedia_jni \
    libmediaplayerservice \
    libmtp \
    libnetd_client \
    libnetlink \
    libnetutils \
    libpdfium \
    libradio_metadata \
    libreference-ril \
    libreverbwrapper \
    libril \
    librtp_jni \
    libsensorservice \
    libskia \
    libsonic \
    libsonivox \
    libsoundpool \
    libsoundtrigger \
    libsoundtriggerservice \
    libsqlite \
    libstagefright \
    libstagefright_amrnb_common \
    libstagefright_avc_common \
    libstagefright_enc_common \
    libstagefright_foundation \
    libstagefright_omx \
    libstagefright_yuv \
    libusbhost \
    libutils \
    libvisualizer \
    libvorbisidec \
    libmediandk \
    libvulkan \
    libwifi-service \
    locksettings \
    media \
    media_cmd \
    mediadrmserver \
    mediaserver \
    mediametrics \
    mediaextractor \
    monkey \
    mtpd \
    ndc \
    netd \
    perfetto \
    ping \
    ping6 \
    platform.xml \
    privapp-permissions-platform.xml \
    pppd \
    pm \
    racoon \
    run-as \
    schedtest \
    sdcard \
    secdiscard \
    services \
    settings \
    sgdisk \
    sm \
    svc \
    tc \
    telecom \
    traced \
    traced_probes \
    vdc \
    vold \
    wm

# Essential HAL modules
PRODUCT_PACKAGES += \
    android.hardware.cas@1.0-service \
    android.hardware.media.omx@1.0-service

# XML schema files
PRODUCT_PACKAGES += \
    media_profiles_V1_0.dtd

# Packages included only for eng or userdebug builds, previously debug tagged
PRODUCT_PACKAGES_DEBUG := \
    logpersist.start \
    perfprofd \
    sqlite3 \
    strace

# Packages included only for eng/userdebug builds, when building with SANITIZE_TARGET=address
PRODUCT_PACKAGES_DEBUG_ASAN :=

PRODUCT_COPY_FILES := $(call add-to-product-copy-files-if-exists,\
    frameworks/base/config/preloaded-classes:system/etc/preloaded-classes)

# Note: it is acceptable to not have a dirty-image-objects file. In that case, the special bin
#       for known dirty objects in the image will be empty.
PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
    frameworks/base/config/dirty-image-objects:system/etc/dirty-image-objects)

$(call inherit-product, $(SRC_TARGET_DIR)/product/embedded.mk)
