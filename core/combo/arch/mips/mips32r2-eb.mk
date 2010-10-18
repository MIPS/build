# Configuration for Android on MIPS.
# Generating binaries for MIPS32R2/soft-float/big-endian

ARCH_HAS_BIGENDIAN	:=true
TARGET_YAFFS2_BIGENDIAN :=1
arch_variant_cflags := \
    -EB \
    -march=mips32r2 \
    -mtune=mips32r2 \
    -mips32r2 \
    -msoft-float

arch_variant_ldflags := \
    -EB
