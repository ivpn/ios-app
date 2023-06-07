// SPDX-License-Identifier: MIT

#define OQS_VERSION_TEXT "0.8.0-rc1"
#define OQS_COMPILE_BUILD_TARGET "aarch64-Darwin-22.3.0"
#define OQS_DIST_BUILD 1
/* #undef OQS_DIST_X86_64_BUILD */
/* #undef OQS_DIST_X86_BUILD */
#define OQS_DIST_ARM64_V8_BUILD 1
/* #undef OQS_DIST_ARM32_V7_BUILD */
/* #undef OQS_DIST_PPC64LE_BUILD */
/* #undef OQS_DEBUG_BUILD */
/* #undef ARCH_X86_64 */
#define ARCH_ARM64v8 1
/* #undef ARCH_ARM32v7 */
/* #undef BUILD_SHARED_LIBS */
#define OQS_BUILD_ONLY_LIB 1
#define OQS_OPT_TARGET "generic"
/* #undef USE_SANITIZER */
/* #undef CMAKE_BUILD_TYPE */

/* #undef OQS_USE_OPENSSL */
/* #undef OQS_USE_AES_OPENSSL */
/* #undef OQS_USE_SHA2_OPENSSL */
/* #undef OQS_USE_SHA3_OPENSSL */

/* #undef OQS_USE_PTHREADS_IN_TESTS */

/* #undef OQS_USE_ADX_INSTRUCTIONS */
/* #undef OQS_USE_AES_INSTRUCTIONS */
/* #undef OQS_USE_AVX_INSTRUCTIONS */
/* #undef OQS_USE_AVX2_INSTRUCTIONS */
/* #undef OQS_USE_AVX512_INSTRUCTIONS */
/* #undef OQS_USE_BMI1_INSTRUCTIONS */
/* #undef OQS_USE_BMI2_INSTRUCTIONS */
/* #undef OQS_USE_PCLMULQDQ_INSTRUCTIONS */
/* #undef OQS_USE_VPCLMULQDQ_INSTRUCTIONS */
/* #undef OQS_USE_POPCNT_INSTRUCTIONS */
/* #undef OQS_USE_SSE_INSTRUCTIONS */
/* #undef OQS_USE_SSE2_INSTRUCTIONS */
/* #undef OQS_USE_SSE3_INSTRUCTIONS */

/* #undef OQS_USE_ARM_AES_INSTRUCTIONS */
/* #undef OQS_USE_ARM_SHA2_INSTRUCTIONS */
/* #undef OQS_USE_ARM_SHA3_INSTRUCTIONS */
/* #undef OQS_USE_ARM_NEON_INSTRUCTIONS */

/* #undef OQS_SPEED_USE_ARM_PMU */

/* #undef OQS_ENABLE_TEST_CONSTANT_TIME */

/* #undef OQS_ENABLE_SHA3_xkcp_low_avx2 */

/* #undef OQS_ENABLE_KEM_BIKE */
/* #undef OQS_ENABLE_KEM_bike_l1 */
/* #undef OQS_ENABLE_KEM_bike_l3 */
/* #undef OQS_ENABLE_KEM_bike_l5 */

/* #undef OQS_ENABLE_KEM_FRODOKEM */
/* #undef OQS_ENABLE_KEM_frodokem_640_aes */
/* #undef OQS_ENABLE_KEM_frodokem_640_shake */
/* #undef OQS_ENABLE_KEM_frodokem_976_aes */
/* #undef OQS_ENABLE_KEM_frodokem_976_shake */
/* #undef OQS_ENABLE_KEM_frodokem_1344_aes */
/* #undef OQS_ENABLE_KEM_frodokem_1344_shake */

/* #undef OQS_ENABLE_KEM_NTRUPRIME */
/* #undef OQS_ENABLE_KEM_ntruprime_sntrup761 */
/* #undef OQS_ENABLE_KEM_ntruprime_sntrup761_avx2 */

///// OQS_COPY_FROM_UPSTREAM_FRAGMENT_ADD_ALG_ENABLE_DEFINES_START

/* #undef OQS_ENABLE_KEM_CLASSIC_MCELIECE */
/* #undef OQS_ENABLE_KEM_classic_mceliece_348864 */
/* #undef OQS_ENABLE_KEM_classic_mceliece_348864_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_348864f */
/* #undef OQS_ENABLE_KEM_classic_mceliece_348864f_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_460896 */
/* #undef OQS_ENABLE_KEM_classic_mceliece_460896_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_460896f */
/* #undef OQS_ENABLE_KEM_classic_mceliece_460896f_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6688128 */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6688128_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6688128f */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6688128f_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6960119 */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6960119_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6960119f */
/* #undef OQS_ENABLE_KEM_classic_mceliece_6960119f_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_8192128 */
/* #undef OQS_ENABLE_KEM_classic_mceliece_8192128_avx */
/* #undef OQS_ENABLE_KEM_classic_mceliece_8192128f */
/* #undef OQS_ENABLE_KEM_classic_mceliece_8192128f_avx */

/* #undef OQS_ENABLE_KEM_HQC */
/* #undef OQS_ENABLE_KEM_hqc_128 */
/* #undef OQS_ENABLE_KEM_hqc_128_avx2 */
/* #undef OQS_ENABLE_KEM_hqc_192 */
/* #undef OQS_ENABLE_KEM_hqc_192_avx2 */
/* #undef OQS_ENABLE_KEM_hqc_256 */
/* #undef OQS_ENABLE_KEM_hqc_256_avx2 */

#define OQS_ENABLE_KEM_KYBER 1
/* #undef OQS_ENABLE_KEM_kyber_512 */
/* #undef OQS_ENABLE_KEM_kyber_512_avx2 */
/* #undef OQS_ENABLE_KEM_kyber_512_aarch64 */
/* #undef OQS_ENABLE_KEM_kyber_768 */
/* #undef OQS_ENABLE_KEM_kyber_768_avx2 */
/* #undef OQS_ENABLE_KEM_kyber_768_aarch64 */
#define OQS_ENABLE_KEM_kyber_1024 1
/* #undef OQS_ENABLE_KEM_kyber_1024_avx2 */
/* #undef OQS_ENABLE_KEM_kyber_1024_aarch64 */

/* #undef OQS_ENABLE_SIG_DILITHIUM */
/* #undef OQS_ENABLE_SIG_dilithium_2 */
/* #undef OQS_ENABLE_SIG_dilithium_2_avx2 */
/* #undef OQS_ENABLE_SIG_dilithium_2_aarch64 */
/* #undef OQS_ENABLE_SIG_dilithium_3 */
/* #undef OQS_ENABLE_SIG_dilithium_3_avx2 */
/* #undef OQS_ENABLE_SIG_dilithium_3_aarch64 */
/* #undef OQS_ENABLE_SIG_dilithium_5 */
/* #undef OQS_ENABLE_SIG_dilithium_5_avx2 */
/* #undef OQS_ENABLE_SIG_dilithium_5_aarch64 */

/* #undef OQS_ENABLE_SIG_FALCON */
/* #undef OQS_ENABLE_SIG_falcon_512 */
/* #undef OQS_ENABLE_SIG_falcon_512_avx2 */
/* #undef OQS_ENABLE_SIG_falcon_1024 */
/* #undef OQS_ENABLE_SIG_falcon_1024_avx2 */

/* #undef OQS_ENABLE_SIG_SPHINCS */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_128f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_128f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_128s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_128s_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_192f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_192f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_192s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_192s_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_256f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_256f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_256s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_sha2_256s_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_128f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_128f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_128s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_128s_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_192f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_192f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_192s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_192s_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_256f_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_256f_simple_avx2 */
/* #undef OQS_ENABLE_SIG_sphincs_shake_256s_simple */
/* #undef OQS_ENABLE_SIG_sphincs_shake_256s_simple_avx2 */
///// OQS_COPY_FROM_UPSTREAM_FRAGMENT_ADD_ALG_ENABLE_DEFINES_END
