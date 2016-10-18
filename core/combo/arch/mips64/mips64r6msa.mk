# Configuration for Android on mips64r6msa.

ARCH_MIPS_REV6 := true
ARCH_MIPS_HAS_MSA := true
arch_variant_cflags := \
    -mips64r6 \
    -mmsa \
    -mfp64 \
    -msynci
