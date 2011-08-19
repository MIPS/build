#
# Copyright (C) 2007 The Android Open Source Project
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

PRODUCT_BRAND := generic
PRODUCT_DEVICE := generic
PRODUCT_NAME := core

PRODUCT_PROPERTY_OVERRIDES := \
    ro.config.notification_sound=OnTheHunt.ogg \
    ro.config.alarm_alert=Alarm_Classic.ogg

PRODUCT_PACKAGES := \
    bouncycastle \
    com.android.location.provider \
    com.android.location.provider.xml \
    core \
    core-junit \
    create_test_dmtrace \
    dalvikvm \
    dexdeps \
    dexdump \
    dexlist \
    dexopt \
    dmtracedump \
    dvz \
    dx \
    ext \
    framework-res \
    hprof-conv \
    icu.dat \
    jasmin \
    jasmin.jar \
    libcrypto \
    libdex \
    libdvm \
    libexpat \
    libicui18n \
    libicuuc \
    libjavacore \
    libnativehelper \
    libnfc_ndef \
    libsqlite_jni \
    libssl \
    libz \
    sqlite-jdbc \
    Browser \
    Contacts \
    Home \
    HTMLViewer \
    Phone \
    ApplicationsProvider \
    ContactsProvider \
    DownloadProvider \
    DownloadProviderUi \
    MediaProvider \
    PicoTts \
    SettingsProvider \
    TelephonyProvider \
    TtsService \
    VpnServices \
    UserDictionaryProvider \
    PackageInstaller \
    DefaultContainerService \
    Bugreport

# host-only dependencies
ifeq ($(WITH_HOST_DALVIK),true)
    PRODUCT_PACKAGES += \
        bouncycastle-hostdex \
        core-hostdex \
        libjavacore-host
endif

ifeq ($(TARGET_ARCH),mips)
    PRODUCT_PACKAGES += \
	libffi
endif
