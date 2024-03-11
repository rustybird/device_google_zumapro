#
# Copyright (C) 2019 The Android Open-Source Project
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
include build/make/target/board/BoardConfigMainlineCommon.mk
include build/make/target/board/BoardConfigPixelCommon.mk

# Include settings for 16k page size kernel if enabled.
include device/google/zumapro/BoardConfig-16k-common.mk

# HACK : To fix up after bring up multimedia devices.
TARGET_SOC := zumapro

TARGET_SOC_NAME := google

USES_DEVICE_GOOGLE_ZUMAPRO := true

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv9-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76
TARGET_HAS_ARM_MTE := true

BOARD_KERNEL_CMDLINE += dyndbg=\"func alloc_contig_dump_pages +p\"
BOARD_KERNEL_CMDLINE += earlycon=exynos4210,0x10870000 console=ttySAC0,115200 androidboot.console=ttySAC0 printk.devkmsg=on
BOARD_KERNEL_CMDLINE += cma_sysfs.experimental=Y
BOARD_KERNEL_CMDLINE += cgroup_disable=memory
BOARD_KERNEL_CMDLINE += cgroup.memory=nokmem
BOARD_KERNEL_CMDLINE += rcupdate.rcu_expedited=1 rcu_nocbs=all rcutree.enable_rcu_lazy
BOARD_KERNEL_CMDLINE += swiotlb=noforce
BOARD_KERNEL_CMDLINE += disable_dma32=on
BOARD_KERNEL_CMDLINE += sysctl.kernel.sched_pelt_multiplier=4
ifeq (,$(filter %_fullmte,$(TARGET_PRODUCT)))
BOARD_KERNEL_CMDLINE += kasan=off
endif
BOARD_BOOTCONFIG += androidboot.boot_devices=13200000.ufs

# Enable KUnit for userdebug and eng builds
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
  BOARD_KERNEL_CMDLINE += kunit.enable=1
endif

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_PREBUILT_BOOTIMAGE := $(wildcard $(TARGET_KERNEL_DIR)/boot.img)
ifneq (,$(BOARD_PREBUILT_BOOTIMAGE))
TARGET_NO_KERNEL := true
else
TARGET_NO_KERNEL := false
endif
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
TARGET_RECOVERY_WIPE := device/google/zumapro/conf/recovery.wipe

# This is the fstab file that will be included in the recovery image.  Note that
# recovery doesn't care about the encryption settings, so it doesn't matter
# whether we use the normal or the fips fstab here.
TARGET_RECOVERY_FSTAB_GENRULE := gen_fstab.zumapro-sw-encrypt

TARGET_RECOVERY_PIXEL_FORMAT := ABGR_8888
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 165
TARGET_RECOVERY_UI_LIB := \
	librecovery_ui_pixel \
	libfstab

AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
	system \
	system_dlkm \
	system_ext \
	product \
	boot \
	init_boot \
	vendor_boot \
	dtbo \
	vendor_kernel_boot \
	vbmeta \
	pvmfw

# EMULATOR common modules
BOARD_EMULATOR_COMMON_MODULES := liblight

OVERRIDE_RS_DRIVER := libRSDriverArm.so
BOARD_EGL_CFG := device/google/zumapro/conf/egl.cfg
#BOARD_USES_HGL := true
USE_OPENGL_RENDERER := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
BOARD_USES_EXYNOS5_COMMON_GRALLOC := true
BOARD_USES_EXYNOS_GRALLOC_VERSION := 4
#BOARD_USES_EXYNOS_GRALLOC_VERSION := $(DEVICE_USES_EXYNOS_GRALLOC_VERSION)
BOARD_USES_ALIGN_RESTRICTION := false
BOARD_USES_GRALLOC_ION_SYNC := true

# This should be the same value as USE_SWIFTSHADER in device.mk
BOARD_USES_SWIFTSHADER ?= false

# Gralloc4
ifeq ($(BOARD_USES_EXYNOS_GRALLOC_VERSION),4)
ifeq ($(BOARD_USES_SWIFTSHADER),true)
$(warning BOARD_USES_SWIFTSHADER set to current target)
TARGET_DISABLE_TRIPLE_BUFFERING := true
$(call soong_config_set,arm_gralloc,gralloc_arm_no_external_afbc,true)
$(call soong_config_set,arm_gralloc,mali_gpu_support_afbc_basic,false)
$(call soong_config_set,arm_gralloc,mali_gpu_support_afbc_wideblk,false)
$(call soong_config_set,arm_gralloc,gralloc_init_afbc,false)
$(call soong_config_set,arm_gralloc,dpu_support_1010102_afbc,false)
else
$(call soong_config_set,arm_gralloc,gralloc_arm_no_external_afbc,false)
$(call soong_config_set,arm_gralloc,mali_gpu_support_afbc_basic,true)
$(call soong_config_set,arm_gralloc,mali_gpu_support_afbc_wideblk,true)
$(call soong_config_set,arm_gralloc,gralloc_init_afbc,true)
$(call soong_config_set,arm_gralloc,dpu_support_1010102_afbc,true)
endif # ifeq ($(BOARD_USES_SWIFTSHADER),true)
$(call soong_config_set,arm_gralloc,gralloc_ion_sync_on_lock,$(BOARD_USES_GRALLOC_ION_SYNC))
endif # ifeq ($(BOARD_USES_EXYNOS_GRALLOC_VERSION),4)

# libVendorGraphicbuffer
ifeq ($(BOARD_USES_EXYNOS_GRALLOC_VERSION),4)
$(call soong_config_set,vendorgraphicbuffer,gralloc_version,four)
else
$(call soong_config_set,vendorgraphicbuffer,gralloc_version,three)
endif

#display_unit_test
ifeq ($(USES_DEVICE_GOOGLE_ZUMAPRO),true)
$(call soong_config_set,display_unit_test,soc,zuma)
endif

# Graphics
#BOARD_USES_EXYNOS_DATASPACE_FEATURE := true

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_USERDATAIMAGE_PARTITION_SIZE := 11796480000
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
PRODUCT_FS_COMPRESSION := 1
BOARD_FLASH_BLOCK_SIZE := 4096
BOARD_MOUNT_SDCARD_RW := true

# system.img
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4

# product.img
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_PRODUCT := product

# system_ext.img
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# persist.img
BOARD_PERSISTIMAGE_FILE_SYSTEM_TYPE := f2fs

########################
# Video Codec
########################
# 1. Exynos C2
BOARD_USE_CODEC2_HIDL_1_2 := true
BOARD_USE_CSC_FILTER := false
BOARD_USE_DEC_SW_CSC := true
BOARD_USE_ENC_SW_CSC := true
BOARD_SUPPORT_MFC_ENC_RGB := true
BOARD_USE_BLOB_ALLOCATOR := false
BOARD_SUPPORT_MFC_ENC_BT2020 := true
BOARD_SUPPORT_FLEXIBLE_P010 := true
BOARD_SUPPORT_MFC_VERSION := 1660
########################

BOARD_SUPER_PARTITION_SIZE := 8531214336
BOARD_SUPER_PARTITION_GROUPS := google_dynamic_partitions
# Set size to BOARD_SUPER_PARTITION_SIZE - overhead (4MiB) (b/182237294)
BOARD_GOOGLE_DYNAMIC_PARTITIONS_SIZE := 8527020032
BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_dlkm \
    system_ext \
    product \
    vendor \
    vendor_dlkm

# Set error limit to BOARD_SUPER_PARTITON_SIZE - 500MB
BOARD_SUPER_PARTITION_ERROR_LIMIT := 8006926336

# Build a separate system_dlkm partition
BOARD_USES_SYSTEM_DLKMIMAGE := true
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

#
# AUDIO & VOICE
#
BOARD_USES_GENERIC_AUDIO := true

$(call soong_config_set,aoc_audio_func,ext_hidl,true)

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call soong_config_set,aoc_audio_func,dump_usecase_data,true)
$(call soong_config_set,aoc_audio_func,hal_socket_control,true)
$(call soong_config_set,aoc_audio_func,record_tuning_keys,true)
$(call soong_config_set,aoc_audio_func,aidl_command_interface,true)
endif

ifneq (,$(filter aosp_%,$(TARGET_PRODUCT)))
$(call soong_config_set,aoc_audio_func,aosp_build,true)
endif

# Primary AudioHAL Configuration
#BOARD_USE_COMMON_AUDIOHAL := true
#BOARD_USE_CALLIOPE_AUDIOHAL := false
#BOARD_USE_AUDIOHAL := true

# Compress Offload Configuration
#BOARD_USE_OFFLOAD_AUDIO := true
#BOARD_USE_OFFLOAD_EFFECT := false

# SoundTriggerHAL Configuration
#BOARD_USE_SOUNDTRIGGER_HAL := false

# Vibrator HAL actuator model configuration
$(call soong_config_set,haptics,actuator_model,$(ACTUATOR_MODEL))
$(call soong_config_set,haptics,adaptive_haptics_feature,$(ADAPTIVE_HAPTICS_FEATURE))

# HWComposer
BOARD_HWC_VERSION := hwc3
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := false
BOARD_HDMI_INCAPABLE := true
TARGET_USES_HWC2 := true
HWC_SUPPORT_RENDER_INTENT := true
HWC_SUPPORT_COLOR_TRANSFORM := true
#BOARD_USES_DISPLAYPORT := true
# if AFBC is enabled, must set ro.vendor.ddk.set.afbc=1
BOARD_USES_EXYNOS_AFBC_FEATURE := true
#BOARD_USES_HDRUI_GLES_CONVERSION := true

BOARD_LIBACRYL_DEFAULT_COMPOSITOR := fimg2d_zuma
BOARD_LIBACRYL_G2D_HDR_PLUGIN := libacryl_hdr_plugin

# HWCServices
BOARD_USES_HWC_SERVICES := true

# WiFiDisplay
# BOARD_USES_VIRTUAL_DISPLAY := true
# BOARD_USES_VDS_EXYNOS_HWC := true
# BOARD_USES_WIFI_DISPLAY:= true
# BOARD_USES_EGL_SURFACE_FOR_COMPOSITION_MIXED := true
# BOARD_USES_VDS_YUV420SPM := true
# BOARD_USES_VDS_OTHERFORMAT := true
# BOARD_USES_VDS_DEBUG_FLAG := true
# BOARD_USES_DISABLE_COMPOSITIONTYPE_GLES := true
# BOARD_USES_SECURE_ENCODER_ONLY := true
# BOARD_USES_TSMUX := true

# SCALER
BOARD_USES_DEFAULT_CSC_HW_SCALER := true
BOARD_DEFAULT_CSC_HW_SCALER := 4
BOARD_USES_SCALER_M2M1SHOT := true

# Device Tree
BOARD_USES_DT := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(TARGET_KERNEL_DIR)
BOARD_PREBUILT_DTBOIMAGE := $(BOARD_PREBUILT_DTBIMAGE_DIR)/dtbo.img

# PLATFORM LOG
TARGET_USES_LOGD := true

# LIBHWJPEG
#TARGET_USES_UNIVERSAL_LIBHWJPEG := true
#LIBHWJPEG_HWSCALER_ID := 0

#Keymaster
#BOARD_USES_KEYMASTER_VER1 := true

#FMP
#BOARD_USES_FMP_DM_CRYPT := true
#BOARD_USES_FMP_FSCRYPTO := true
BOARD_USES_METADATA_PARTITION := true

# SKIA
#BOARD_USES_SKIA_MULTITHREADING := true
#BOARD_USES_FIMGAPI_V5X := true

# SECCOMP Policy
BOARD_SECCOMP_POLICY = device/google/zumapro/seccomp_policy

#CURL
BOARD_USES_CURL := true

# Sensor HAL
BOARD_USES_EXYNOS_SENSORS_DUMMY := true

# VISION
# Exynos vision framework (EVF)
#TARGET_USES_EVF := true
# HW acceleration
#TARGET_USES_VPU_KERNEL := true
#TARGET_USES_SCORE_KERNEL := true
#TARGET_USES_CL_KERNEL := false

# exynos RIL
TARGET_EXYNOS_RIL_SOURCE := true
ENABLE_VENDOR_RIL_SERVICE := true

# GNSS
# BOARD_USES_EXYNOS_GNSS_DUMMY := true

# Bluetooth defines
# TODO(b/123695868): Remove the need for this
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := \
	build/make/target/board/mainline_arm64/bluetooth

#VNDK
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
BOARD_VNDK_VERSION := current

# H/W align restriction of MM IPs
BOARD_EXYNOS_S10B_FORMAT_ALIGN := 64

# Boot.img
BOARD_RAMDISK_USE_LZ4     := true
#BOARD_KERNEL_BASE        := 0x80000000
#BOARD_KERNEL_PAGESIZE    := 2048
#BOARD_KERNEL_OFFSET      := 0x80000
#BOARD_RAMDISK_OFFSET     := 0x4000000
BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

# Enable AVB2.0
BOARD_AVB_ENABLE := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 0x800000
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 0x04000000
BOARD_DTBOIMG_PARTITION_SIZE := 0x01000000

# Build vendor kernel boot image
BOARD_VENDOR_KERNEL_BOOTIMAGE_PARTITION_SIZE := 0x04000000

# Vendor ramdisk image for kernel development
BOARD_BUILD_VENDOR_RAMDISK_IMAGE := true

BOARD_DO_NOT_STRIP_RECOVERY_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_RAMDISK_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_KERNEL_RAMDISK_MODULES := true

KERNEL_MODULE_DIR := $(TARGET_KERNEL_DIR)
KERNEL_MODULES := $(wildcard $(KERNEL_MODULE_DIR)/*.ko)

BOARD_SYSTEM_KERNEL_MODULES_BLOCKLIST_FILE := $(KERNEL_MODULE_DIR)/system_dlkm.modules.blocklist
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(KERNEL_MODULE_DIR)/vendor_dlkm.modules.blocklist

# Prebuilt kernel modules that are *not* listed in vendor_kernel_boot.modules.load
BOARD_PREBUILT_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES = fips140.ko
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_EXTRA = $(foreach k,$(BOARD_PREBUILT_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES),$(if $(wildcard $(KERNEL_MODULE_DIR)/$(k)), $(k)))

# Kernel modules that are listed in vendor_kernel_boot.modules.load
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_FILE := $(strip $(shell cat $(KERNEL_MODULE_DIR)/vendor_kernel_boot.modules.load))
ifndef BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_FILE
$(error vendor_kernel_boot.modules.load not found or empty)
endif
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_EXTRA)
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD += $(BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_FILE)
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES := $(addprefix $(KERNEL_MODULE_DIR)/, $(BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_EXTRA))
BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES += $(addprefix $(KERNEL_MODULE_DIR)/, $(notdir $(BOARD_VENDOR_KERNEL_RAMDISK_KERNEL_MODULES_LOAD_FILE)))

BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_MODULE_DIR)/vendor_dlkm.modules.load))
ifndef BOARD_VENDOR_KERNEL_MODULES_LOAD
$(error vendor_dlkm.modules.load not found or empty)
endif
BOARD_VENDOR_KERNEL_MODULES := $(addprefix $(KERNEL_MODULE_DIR)/, $(notdir $(BOARD_VENDOR_KERNEL_MODULES_LOAD)))

BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_MODULE_DIR)/system_dlkm.modules.load))
ifndef BOARD_SYSTEM_KERNEL_MODULES_LOAD
$(error system_dlkm.modules.load not found or empty)
endif
BOARD_SYSTEM_KERNEL_MODULES := $(addprefix $(KERNEL_MODULE_DIR)/, $(notdir $(BOARD_SYSTEM_KERNEL_MODULES_LOAD)))

# Using BUILD_COPY_HEADERS
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true

include device/google/zumapro-sepolicy/zumapro-sepolicy.mk

# Battery options
BOARD_KERNEL_CMDLINE += at24.write_timeout=100

# Enable larger logbuf
BOARD_KERNEL_CMDLINE += log_buf_len=1024K

# Protected VM firmware
BOARD_PVMFWIMAGE_PARTITION_SIZE := 0x00100000

# pick up library for cleaning digital car keys on factory reset
-include vendor/google_devices/gs-common/proprietary/BoardConfigVendor.mk
