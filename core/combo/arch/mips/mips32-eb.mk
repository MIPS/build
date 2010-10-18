# Configuration for Android on MIPS.
# Generating binaries for MIPS32/soft-float/big-endian

ARCH_HAS_BIGENDIAN	:=true
TARGET_YAFFS2_BIGENDIAN :=1
arch_variant_cflags := \
    -EB \
    -march=mips32 \
    -mtune=mips32 \
    -mips32 \
    -msoft-float

arch_variant_ldflags := \
    -EB
