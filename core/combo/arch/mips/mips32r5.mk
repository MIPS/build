# Android configuration for MIPS32R5 with FP64 and MSA

ARCH_MIPS_HAS_FPU	:=true
ARCH_HAVE_ALIGNED_DOUBLES :=true
ARCH_MIPS_HAS_MSA := true
arch_variant_cflags := \
    -mips32r2 \
    -mfp64 \
    -mno-odd-spreg \
    -mmsa \
    -msynci

arch_variant_ldflags := \
    -Wl,-melf32ltsmip
