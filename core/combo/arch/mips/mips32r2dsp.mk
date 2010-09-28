# Configuration for Android on MIPS.
# Generating binaries for MIPS32R2/soft-float/little-endian/dspr2

arch_variant_cflags := \
    -EL \
    -march=mips32r2 \
    -mtune=mips32r2 \
    -mips32r2 \
    -msoft-float \
    -mdsp

arch_variant_ldflags := \
    -EL
