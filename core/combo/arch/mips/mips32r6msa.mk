# Configuration for Android on MSA.
# Generating binaries for MIPS32R6MSA/hard-float/little-endian

ARCH_MIPS_REV6 := true
ARCH_MIPS_HAS_MSA := true
arch_variant_cflags := \
    -mips32r6 \
    -mmsa \
    -mfp64 \
    -mno-odd-spreg \
    -msynci

arch_variant_ldflags := \
    -Wl,-melf32ltsmip
