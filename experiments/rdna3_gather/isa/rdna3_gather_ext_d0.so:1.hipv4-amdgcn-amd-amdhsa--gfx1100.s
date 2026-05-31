
<stdin>:	file format elf64-amdgpu

Disassembly of section .text:

0000000000007a00 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll>:
	s_clause 0x1                                               // 000000007A00: BF850001
	s_load_b32 s6, s[0:1], 0x4c                                // 000000007A04: F4000180 F800004C
	s_load_b64 s[2:3], s[0:1], 0x38                            // 000000007A0C: F4040080 F8000038
	v_mov_b32_e32 v2, 0                                        // 000000007A14: 7E040280
	s_add_u32 s4, s0, 64                                       // 000000007A18: 8004C000
	s_addc_u32 s5, s1, 0                                       // 000000007A1C: 82058001
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000007A20: BF8700C1
	v_mov_b32_e32 v1, v2                                       // 000000007A24: 7E020302
	s_waitcnt lgkmcnt(0)                                       // 000000007A28: BF89FC07
	s_and_b32 s16, s6, 0xffff                                  // 000000007A2C: 8B10FF06 0000FFFF
	s_mov_b32 s6, exec_lo                                      // 000000007A34: BE86007E
	v_mad_u64_u32 v[4:5], null, s16, s15, v[0:1]               // 000000007A38: D6FE7C04 04001E10
	s_delay_alu instid0(VALU_DEP_1)                            // 000000007A40: BF870001
	v_cmpx_gt_i64_e64 s[2:3], v[4:5]                           // 000000007A44: D4D4007E 00020802
	s_cbranch_execz 563                                        // 000000007A4C: BFA50233 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x91c>
	s_load_b128 s[12:15], s[0:1], 0x28                         // 000000007A50: F4080300 F8000028
	s_load_b32 s18, s[4:5], null                               // 000000007A58: F4000482 F8000000
	s_waitcnt lgkmcnt(0)                                       // 000000007A60: BF89FC07
	s_mul_i32 s28, s14, s12                                    // 000000007A64: 961C0C0E
	s_mul_i32 s4, s14, s13                                     // 000000007A68: 96040D0E
	v_cvt_f32_u32_e32 v0, s28                                  // 000000007A6C: 7E000C1C
	s_mul_hi_u32 s5, s14, s12                                  // 000000007A70: 96850C0E
	s_mul_i32 s6, s15, s12                                     // 000000007A74: 96060C0F
	s_add_i32 s4, s5, s4                                       // 000000007A78: 81040405
	v_cvt_f32_u32_e32 v1, s14                                  // 000000007A7C: 7E020C0E
	v_rcp_iflag_f32_e32 v0, v0                                 // 000000007A80: 7E005700
	s_add_i32 s29, s4, s6                                      // 000000007A84: 811D0604
	s_sub_u32 s30, 0, s28                                      // 000000007A88: 809E1C80
	s_subb_u32 s31, 0, s29                                     // 000000007A8C: 829F1D80
	s_sub_i32 s4, 0, s28                                       // 000000007A90: 81841C80
	v_rcp_iflag_f32_e32 v6, v1                                 // 000000007A94: 7E0C5701
	s_mul_hi_u32 s17, s16, s18                                 // 000000007A98: 96911210
	s_mul_i32 s16, s16, s18                                    // 000000007A9C: 96101210
	s_lshl_b64 s[18:19], s[12:13], 2                           // 000000007AA0: 8492820C
	s_lshl_b64 s[20:21], s[16:17], 2                           // 000000007AA4: 84948210
	s_waitcnt_depctr 0xfff                                     // 000000007AA8: BF880FFF
	v_mul_f32_e32 v0, 0x4f7ffffe, v0                           // 000000007AAC: 100000FF 4F7FFFFE
	s_ashr_i32 s22, s29, 31                                    // 000000007AB4: 86169F1D
	s_ashr_i32 s24, s15, 31                                    // 000000007AB8: 86189F0F
	v_mul_f32_e32 v6, 0x4f7ffffe, v6                           // 000000007ABC: 100C0CFF 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007AC4: BF870112
	v_cvt_u32_f32_e32 v3, v0                                   // 000000007AC8: 7E060F00
	v_cvt_u32_f32_e32 v13, v6                                  // 000000007ACC: 7E1A0F06
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000007AD0: BF8700B2
	v_mul_lo_u32 v0, s4, v3                                    // 000000007AD4: D72C0000 00020604
	s_load_b256 s[4:11], s[0:1], null                          // 000000007ADC: F40C0100 F8000000
	s_mov_b32 s1, 0                                            // 000000007AE4: BE810080
	v_mul_hi_u32 v7, v3, v0                                    // 000000007AE8: D72D0007 00020103
	v_lshlrev_b64 v[0:1], 2, v[4:5]                            // 000000007AF0: D73C0000 00020882
	s_delay_alu instid0(VALU_DEP_2)                            // 000000007AF8: BF870002
	v_add_nc_u32_e32 v12, v3, v7                               // 000000007AFC: 4A180F03
	s_branch 23                                                // 000000007B00: BFA00017 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x160>
	s_or_b32 exec_lo, exec_lo, s0                              // 000000007B04: 8C7E007E
	v_add_co_u32 v4, vcc_lo, v4, s16                           // 000000007B08: D7006A04 00002104
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000007B10: BF8700A1
	v_add_co_ci_u32_e64 v5, null, s17, v5, vcc_lo              // 000000007B14: D5207C05 01AA0A11
	v_add_co_u32 v6, vcc_lo, s8, v0                            // 000000007B1C: D7006A06 00020008
	v_add_co_ci_u32_e64 v7, null, s9, v1, vcc_lo               // 000000007B24: D5207C07 01AA0209
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000007B2C: BF8700A3
	v_cmp_le_i64_e32 vcc_lo, s[2:3], v[4:5]                    // 000000007B30: 7CA60802
	v_add_co_u32 v0, s0, v0, s20                               // 000000007B34: D7000000 00002900
	v_add_co_ci_u32_e64 v1, null, s21, v1, s0                  // 000000007B3C: D5207C01 00020215
	s_waitcnt vmcnt(0)                                         // 000000007B44: BF8903F7
	global_store_b32 v[6:7], v3, off                           // 000000007B48: DC6A0000 007C0306
	s_or_b32 s1, vcc_lo, s1                                    // 000000007B50: 8C01016A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000007B54: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s1                        // 000000007B58: 917E017E
	s_cbranch_execz 495                                        // 000000007B5C: BFA501EF <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x91c>
	v_or_b32_e32 v3, s29, v5                                   // 000000007B60: 38060A1D
	s_mov_b32 s0, exec_lo                                      // 000000007B64: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 000000007B68: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000007B6C: 7DBA0480
	s_xor_b32 s25, exec_lo, s0                                 // 000000007B70: 8D19007E
	s_cbranch_execz 175                                        // 000000007B74: BFA500AF <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x434>
	s_add_u32 s26, s28, s22                                    // 000000007B78: 801A161C
	s_mov_b32 s23, s22                                         // 000000007B7C: BE970016
	s_addc_u32 s27, s29, s22                                   // 000000007B80: 821B161D
	v_ashrrev_i32_e32 v14, 31, v5                              // 000000007B84: 341C0A9F
	s_xor_b64 s[26:27], s[26:27], s[22:23]                     // 000000007B88: 8D9A161A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000007B8C: BF870159
	v_cvt_f32_u32_e32 v3, s26                                  // 000000007B90: 7E060C1A
	v_cvt_f32_u32_e32 v6, s27                                  // 000000007B94: 7E0C0C1B
	s_sub_u32 s0, 0, s26                                       // 000000007B98: 80801A80
	s_subb_u32 s34, 0, s27                                     // 000000007B9C: 82A21B80
	v_add_co_u32 v7, vcc_lo, v4, v14                           // 000000007BA0: D7006A07 00021D04
	v_fmac_f32_e32 v3, 0x4f800000, v6                          // 000000007BA8: 56060CFF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007BB0: BF870112
	v_xor_b32_e32 v15, v7, v14                                 // 000000007BB4: 3A1E1D07
	v_rcp_f32_e32 v3, v3                                       // 000000007BB8: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000007BBC: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000007BC0: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007BC8: BF870091
	v_mul_f32_e32 v6, 0x2f800000, v3                           // 000000007BCC: 100C06FF 2F800000
	v_trunc_f32_e32 v6, v6                                     // 000000007BD4: 7E0C4306
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000007BD8: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v6                          // 000000007BDC: 56060CFF CF800000
	v_cvt_u32_f32_e32 v6, v6                                   // 000000007BE4: 7E0C0F06
	v_cvt_u32_f32_e32 v3, v3                                   // 000000007BE8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007BEC: BF870112
	v_readfirstlane_b32 s23, v6                                // 000000007BF0: 7E2E0506
	v_readfirstlane_b32 s33, v3                                // 000000007BF4: 7E420503
	s_mul_i32 s35, s0, s23                                     // 000000007BF8: 96231700
	v_add_co_ci_u32_e64 v3, null, v5, v14, vcc_lo              // 000000007BFC: D5207C03 01AA1D05
	s_mul_hi_u32 s37, s0, s33                                  // 000000007C04: 96A52100
	s_mul_i32 s36, s34, s33                                    // 000000007C08: 96242122
	s_add_i32 s35, s37, s35                                    // 000000007C0C: 81232325
	s_mul_i32 s38, s0, s33                                     // 000000007C10: 96262100
	s_add_i32 s35, s35, s36                                    // 000000007C14: 81232423
	s_mul_hi_u32 s37, s33, s38                                 // 000000007C18: 96A52621
	s_mul_i32 s40, s33, s35                                    // 000000007C1C: 96282321
	s_mul_hi_u32 s39, s23, s38                                 // 000000007C20: 96A72617
	s_mul_i32 s36, s23, s38                                    // 000000007C24: 96242617
	s_mul_hi_u32 s38, s33, s35                                 // 000000007C28: 96A62321
	s_add_u32 s37, s37, s40                                    // 000000007C2C: 80252825
	s_addc_u32 s38, 0, s38                                     // 000000007C30: 82262680
	s_mul_hi_u32 s41, s23, s35                                 // 000000007C34: 96A92317
	s_add_u32 s36, s37, s36                                    // 000000007C38: 80242425
	s_mul_i32 s35, s23, s35                                    // 000000007C3C: 96232317
	s_addc_u32 s36, s38, s39                                   // 000000007C40: 82242726
	s_addc_u32 s37, s41, 0                                     // 000000007C44: 82258029
	s_add_u32 s35, s36, s35                                    // 000000007C48: 80232324
	s_addc_u32 s36, 0, s37                                     // 000000007C4C: 82242580
	s_add_u32 s33, s33, s35                                    // 000000007C50: 80212321
	s_cselect_b32 s35, -1, 0                                   // 000000007C54: 982380C1
	s_mul_hi_u32 s37, s0, s33                                  // 000000007C58: 96A52100
	s_cmp_lg_u32 s35, 0                                        // 000000007C5C: BF078023
	s_mul_i32 s35, s0, s33                                     // 000000007C60: 96232100
	s_addc_u32 s23, s23, s36                                   // 000000007C64: 82172417
	s_mul_i32 s34, s34, s33                                    // 000000007C68: 96222122
	s_mul_i32 s0, s0, s23                                      // 000000007C6C: 96001700
	s_mul_hi_u32 s36, s33, s35                                 // 000000007C70: 96A42321
	s_add_i32 s0, s37, s0                                      // 000000007C74: 81000025
	s_mul_hi_u32 s37, s23, s35                                 // 000000007C78: 96A52317
	s_add_i32 s0, s0, s34                                      // 000000007C7C: 81002200
	s_mul_i32 s34, s23, s35                                    // 000000007C80: 96222317
	s_mul_i32 s39, s33, s0                                     // 000000007C84: 96270021
	s_mul_hi_u32 s38, s33, s0                                  // 000000007C88: 96A60021
	s_add_u32 s36, s36, s39                                    // 000000007C8C: 80242724
	s_addc_u32 s38, 0, s38                                     // 000000007C90: 82262680
	s_mul_hi_u32 s35, s23, s0                                  // 000000007C94: 96A30017
	s_add_u32 s34, s36, s34                                    // 000000007C98: 80222224
	s_mul_i32 s0, s23, s0                                      // 000000007C9C: 96000017
	s_addc_u32 s34, s38, s37                                   // 000000007CA0: 82222526
	s_addc_u32 s35, s35, 0                                     // 000000007CA4: 82238023
	s_add_u32 s0, s34, s0                                      // 000000007CA8: 80000022
	s_addc_u32 s34, 0, s35                                     // 000000007CAC: 82222380
	s_add_u32 s0, s33, s0                                      // 000000007CB0: 80000021
	s_cselect_b32 s33, -1, 0                                   // 000000007CB4: 982180C1
	v_xor_b32_e32 v3, v3, v14                                  // 000000007CB8: 3A061D03
	s_cmp_lg_u32 s33, 0                                        // 000000007CBC: BF078021
	v_mul_hi_u32 v16, v15, s0                                  // 000000007CC0: D72D0010 0000010F
	s_addc_u32 s23, s23, s34                                   // 000000007CC8: 82172217
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000007CCC: BF8701B9
	v_mad_u64_u32 v[6:7], null, v15, s23, 0                    // 000000007CD0: D6FE7C06 02002F0F
	v_mad_u64_u32 v[8:9], null, v3, s0, 0                      // 000000007CD8: D6FE7C08 02000103
	v_mad_u64_u32 v[10:11], null, v3, s23, 0                   // 000000007CE0: D6FE7C0A 02002F03
	v_add_co_u32 v6, vcc_lo, v16, v6                           // 000000007CE8: D7006A06 00020D10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007CF0: BF870111
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 000000007CF4: D5207C07 01AA0E80
	v_add_co_u32 v6, vcc_lo, v6, v8                            // 000000007CFC: D7006A06 00021106
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000007D04: BF870122
	v_add_co_ci_u32_e32 v6, vcc_lo, v7, v9, vcc_lo             // 000000007D08: 400C1307
	v_add_co_ci_u32_e32 v7, vcc_lo, 0, v11, vcc_lo             // 000000007D0C: 400E1680
	v_add_co_u32 v8, vcc_lo, v6, v10                           // 000000007D10: D7006A08 00021506
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007D18: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v7, vcc_lo                // 000000007D1C: D5207C09 01AA0E80
	v_mul_lo_u32 v10, s27, v8                                  // 000000007D24: D72C000A 0002101B
	v_mad_u64_u32 v[6:7], null, s26, v8, 0                     // 000000007D2C: D6FE7C06 0202101A
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007D34: BF870113
	v_mul_lo_u32 v11, s26, v9                                  // 000000007D38: D72C000B 0002121A
	v_sub_co_u32 v6, vcc_lo, v15, v6                           // 000000007D40: D7016A06 00020D0F
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000007D48: BF8700A2
	v_add3_u32 v7, v7, v11, v10                                // 000000007D4C: D6550007 042A1707
	v_add_co_u32 v11, s0, v8, 2                                // 000000007D54: D700000B 00010508
	v_add_co_ci_u32_e64 v15, null, 0, v9, s0                   // 000000007D5C: D5207C0F 00021280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000007D64: BF8701B3
	v_sub_nc_u32_e32 v10, v3, v7                               // 000000007D68: 4C140F03
	v_sub_co_u32 v16, s0, v6, s26                              // 000000007D6C: D7010010 00003506
	v_sub_co_ci_u32_e64 v3, null, v3, v7, vcc_lo               // 000000007D74: D5217C03 01AA0F03
	v_subrev_co_ci_u32_e64 v10, null, s27, v10, vcc_lo         // 000000007D7C: D5227C0A 01AA141B
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007D84: BF870113
	v_cmp_le_u32_e32 vcc_lo, s26, v16                          // 000000007D88: 7C96201A
	v_subrev_co_ci_u32_e64 v10, null, 0, v10, s0               // 000000007D8C: D5227C0A 00021480
	v_cndmask_b32_e64 v7, 0, -1, vcc_lo                        // 000000007D94: D5010007 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 000000007D9C: BF870002
	v_cmp_le_u32_e32 vcc_lo, s27, v10                          // 000000007DA0: 7C96141B
	v_cndmask_b32_e64 v16, 0, -1, vcc_lo                       // 000000007DA4: D5010010 01A98280
	v_cmp_le_u32_e32 vcc_lo, s26, v6                           // 000000007DAC: 7C960C1A
	v_cndmask_b32_e64 v6, 0, -1, vcc_lo                        // 000000007DB0: D5010006 01A98280
	v_cmp_le_u32_e32 vcc_lo, s27, v3                           // 000000007DB8: 7C96061B
	v_cndmask_b32_e64 v17, 0, -1, vcc_lo                       // 000000007DBC: D5010011 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s27, v10                          // 000000007DC4: 7C94141B
	v_cndmask_b32_e32 v7, v16, v7, vcc_lo                      // 000000007DC8: 020E0F10
	v_add_co_u32 v10, vcc_lo, v8, 1                            // 000000007DCC: D7006A0A 00010308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000007DD4: BF8701D1
	v_add_co_ci_u32_e64 v16, null, 0, v9, vcc_lo               // 000000007DD8: D5207C10 01AA1280
	v_cmp_eq_u32_e32 vcc_lo, s27, v3                           // 000000007DE0: 7C94061B
	v_cndmask_b32_e32 v3, v17, v6, vcc_lo                      // 000000007DE4: 02060D11
	v_cmp_ne_u32_e32 vcc_lo, 0, v7                             // 000000007DE8: 7C9A0E80
	v_xor_b32_e32 v7, s22, v14                                 // 000000007DEC: 3A0E1C16
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 000000007DF0: D44D0000 00020680
	v_cndmask_b32_e32 v3, v10, v11, vcc_lo                     // 000000007DF8: 0206170A
	v_cndmask_b32_e32 v6, v16, v15, vcc_lo                     // 000000007DFC: 020C1F10
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007E00: BF870112
	v_cndmask_b32_e64 v3, v8, v3, s0                           // 000000007E04: D5010003 00020708
	v_cndmask_b32_e64 v6, v9, v6, s0                           // 000000007E0C: D5010006 00020D09
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007E14: BF870112
	v_xor_b32_e32 v3, v3, v7                                   // 000000007E18: 3A060F03
	v_xor_b32_e32 v8, v6, v7                                   // 000000007E1C: 3A100F06
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007E20: BF870092
	v_sub_co_u32 v6, vcc_lo, v3, v7                            // 000000007E24: D7016A06 00020F03
	v_sub_co_ci_u32_e64 v7, null, v8, v7, vcc_lo               // 000000007E2C: D5217C07 01AA0F08
	s_and_not1_saveexec_b32 s0, s25                            // 000000007E34: BE803019
	s_cbranch_execz 18                                         // 000000007E38: BFA50012 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x484>
	v_mul_hi_u32 v3, v4, v12                                   // 000000007E3C: D72D0003 00021904
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007E44: BF870091
	v_mul_lo_u32 v6, v3, s28                                   // 000000007E48: D72C0006 00003903
	v_sub_nc_u32_e32 v6, v4, v6                                // 000000007E50: 4C0C0D04
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000007E54: BF870121
	v_subrev_nc_u32_e32 v8, s28, v6                            // 000000007E58: 4E100C1C
	v_cmp_le_u32_e32 vcc_lo, s28, v6                           // 000000007E5C: 7C960C1C
	v_dual_cndmask_b32 v6, v6, v8 :: v_dual_add_nc_u32 v7, 1, v3// 000000007E60: CA601106 06060681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007E68: BF870111
	v_cndmask_b32_e32 v3, v3, v7, vcc_lo                       // 000000007E6C: 02060F03
	v_cmp_le_u32_e32 vcc_lo, s28, v6                           // 000000007E70: 7C960C1C
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007E74: BF870092
	v_add_nc_u32_e32 v7, 1, v3                                 // 000000007E78: 4A0E0681
	v_dual_cndmask_b32 v6, v3, v7 :: v_dual_mov_b32 v7, v2     // 000000007E7C: CA500F03 06060102
	s_or_b32 exec_lo, exec_lo, s0                              // 000000007E84: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007E88: BF870111
	v_mad_u64_u32 v[8:9], null, s30, v6, v[4:5]                // 000000007E8C: D6FE7C08 04120C1E
	v_mul_lo_u32 v3, s30, v7                                   // 000000007E94: D72C0003 00020E1E
	v_mul_lo_u32 v10, s31, v6                                  // 000000007E9C: D72C000A 00020C1F
	s_mov_b32 s0, exec_lo                                      // 000000007EA4: BE80007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007EA8: BF870091
	v_add3_u32 v9, v10, v9, v3                                 // 000000007EAC: D6550009 040E130A
	v_or_b32_e32 v3, s15, v9                                   // 000000007EB4: 3806120F
	s_delay_alu instid0(VALU_DEP_1)                            // 000000007EB8: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000007EBC: 7DBA0480
	s_xor_b32 s23, exec_lo, s0                                 // 000000007EC0: 8D17007E
	s_cbranch_execz 175                                        // 000000007EC4: BFA500AF <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x784>
	s_add_u32 s26, s14, s24                                    // 000000007EC8: 801A180E
	s_mov_b32 s25, s24                                         // 000000007ECC: BE990018
	s_addc_u32 s27, s15, s24                                   // 000000007ED0: 821B180F
	v_ashrrev_i32_e32 v16, 31, v9                              // 000000007ED4: 3420129F
	s_xor_b64 s[26:27], s[26:27], s[24:25]                     // 000000007ED8: 8D9A181A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000007EDC: BF870159
	v_cvt_f32_u32_e32 v3, s26                                  // 000000007EE0: 7E060C1A
	v_cvt_f32_u32_e32 v10, s27                                 // 000000007EE4: 7E140C1B
	s_sub_u32 s0, 0, s26                                       // 000000007EE8: 80801A80
	s_subb_u32 s34, 0, s27                                     // 000000007EEC: 82A21B80
	v_add_co_u32 v8, vcc_lo, v8, v16                           // 000000007EF0: D7006A08 00022108
	v_fmac_f32_e32 v3, 0x4f800000, v10                         // 000000007EF8: 560614FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007F00: BF870112
	v_xor_b32_e32 v17, v8, v16                                 // 000000007F04: 3A222108
	v_rcp_f32_e32 v3, v3                                       // 000000007F08: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000007F0C: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000007F10: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000007F18: BF870091
	v_mul_f32_e32 v10, 0x2f800000, v3                          // 000000007F1C: 101406FF 2F800000
	v_trunc_f32_e32 v10, v10                                   // 000000007F24: 7E14430A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000007F28: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v10                         // 000000007F2C: 560614FF CF800000
	v_cvt_u32_f32_e32 v10, v10                                 // 000000007F34: 7E140F0A
	v_cvt_u32_f32_e32 v3, v3                                   // 000000007F38: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000007F3C: BF870112
	v_readfirstlane_b32 s25, v10                               // 000000007F40: 7E32050A
	v_readfirstlane_b32 s33, v3                                // 000000007F44: 7E420503
	s_mul_i32 s35, s0, s25                                     // 000000007F48: 96231900
	v_add_co_ci_u32_e64 v3, null, v9, v16, vcc_lo              // 000000007F4C: D5207C03 01AA2109
	s_mul_hi_u32 s37, s0, s33                                  // 000000007F54: 96A52100
	s_mul_i32 s36, s34, s33                                    // 000000007F58: 96242122
	s_add_i32 s35, s37, s35                                    // 000000007F5C: 81232325
	s_mul_i32 s38, s0, s33                                     // 000000007F60: 96262100
	s_add_i32 s35, s35, s36                                    // 000000007F64: 81232423
	s_mul_hi_u32 s37, s33, s38                                 // 000000007F68: 96A52621
	s_mul_i32 s40, s33, s35                                    // 000000007F6C: 96282321
	s_mul_hi_u32 s39, s25, s38                                 // 000000007F70: 96A72619
	s_mul_i32 s36, s25, s38                                    // 000000007F74: 96242619
	s_mul_hi_u32 s38, s33, s35                                 // 000000007F78: 96A62321
	s_add_u32 s37, s37, s40                                    // 000000007F7C: 80252825
	s_addc_u32 s38, 0, s38                                     // 000000007F80: 82262680
	s_mul_hi_u32 s41, s25, s35                                 // 000000007F84: 96A92319
	s_add_u32 s36, s37, s36                                    // 000000007F88: 80242425
	s_mul_i32 s35, s25, s35                                    // 000000007F8C: 96232319
	s_addc_u32 s36, s38, s39                                   // 000000007F90: 82242726
	s_addc_u32 s37, s41, 0                                     // 000000007F94: 82258029
	s_add_u32 s35, s36, s35                                    // 000000007F98: 80232324
	s_addc_u32 s36, 0, s37                                     // 000000007F9C: 82242580
	s_add_u32 s33, s33, s35                                    // 000000007FA0: 80212321
	s_cselect_b32 s35, -1, 0                                   // 000000007FA4: 982380C1
	s_mul_hi_u32 s37, s0, s33                                  // 000000007FA8: 96A52100
	s_cmp_lg_u32 s35, 0                                        // 000000007FAC: BF078023
	s_mul_i32 s35, s0, s33                                     // 000000007FB0: 96232100
	s_addc_u32 s25, s25, s36                                   // 000000007FB4: 82192419
	s_mul_i32 s34, s34, s33                                    // 000000007FB8: 96222122
	s_mul_i32 s0, s0, s25                                      // 000000007FBC: 96001900
	s_mul_hi_u32 s36, s33, s35                                 // 000000007FC0: 96A42321
	s_add_i32 s0, s37, s0                                      // 000000007FC4: 81000025
	s_mul_hi_u32 s37, s25, s35                                 // 000000007FC8: 96A52319
	s_add_i32 s0, s0, s34                                      // 000000007FCC: 81002200
	s_mul_i32 s34, s25, s35                                    // 000000007FD0: 96222319
	s_mul_i32 s39, s33, s0                                     // 000000007FD4: 96270021
	s_mul_hi_u32 s38, s33, s0                                  // 000000007FD8: 96A60021
	s_add_u32 s36, s36, s39                                    // 000000007FDC: 80242724
	s_addc_u32 s38, 0, s38                                     // 000000007FE0: 82262680
	s_mul_hi_u32 s35, s25, s0                                  // 000000007FE4: 96A30019
	s_add_u32 s34, s36, s34                                    // 000000007FE8: 80222224
	s_mul_i32 s0, s25, s0                                      // 000000007FEC: 96000019
	s_addc_u32 s34, s38, s37                                   // 000000007FF0: 82222526
	s_addc_u32 s35, s35, 0                                     // 000000007FF4: 82238023
	s_add_u32 s0, s34, s0                                      // 000000007FF8: 80000022
	s_addc_u32 s34, 0, s35                                     // 000000007FFC: 82222380
	s_add_u32 s0, s33, s0                                      // 000000008000: 80000021
	s_cselect_b32 s33, -1, 0                                   // 000000008004: 982180C1
	v_xor_b32_e32 v3, v3, v16                                  // 000000008008: 3A062103
	s_cmp_lg_u32 s33, 0                                        // 00000000800C: BF078021
	v_mul_hi_u32 v18, v17, s0                                  // 000000008010: D72D0012 00000111
	s_addc_u32 s25, s25, s34                                   // 000000008018: 82192219
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000801C: BF8701B9
	v_mad_u64_u32 v[8:9], null, v17, s25, 0                    // 000000008020: D6FE7C08 02003311
	v_mad_u64_u32 v[10:11], null, v3, s0, 0                    // 000000008028: D6FE7C0A 02000103
	v_mad_u64_u32 v[14:15], null, v3, s25, 0                   // 000000008030: D6FE7C0E 02003303
	v_add_co_u32 v8, vcc_lo, v18, v8                           // 000000008038: D7006A08 00021112
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008040: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000008044: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 00000000804C: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008054: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 000000008058: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v15, vcc_lo             // 00000000805C: 40121E80
	v_add_co_u32 v10, vcc_lo, v8, v14                          // 000000008060: D7006A0A 00021D08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008068: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 00000000806C: D5207C0B 01AA1280
	v_mul_lo_u32 v14, s27, v10                                 // 000000008074: D72C000E 0002141B
	v_mad_u64_u32 v[8:9], null, s26, v10, 0                    // 00000000807C: D6FE7C08 0202141A
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008084: BF870113
	v_mul_lo_u32 v15, s26, v11                                 // 000000008088: D72C000F 0002161A
	v_sub_co_u32 v8, vcc_lo, v17, v8                           // 000000008090: D7016A08 00021111
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000008098: BF8700A2
	v_add3_u32 v9, v9, v15, v14                                // 00000000809C: D6550009 043A1F09
	v_add_co_u32 v15, s0, v10, 2                               // 0000000080A4: D700000F 0001050A
	v_add_co_ci_u32_e64 v17, null, 0, v11, s0                  // 0000000080AC: D5207C11 00021680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000000080B4: BF8701B3
	v_sub_nc_u32_e32 v14, v3, v9                               // 0000000080B8: 4C1C1303
	v_sub_co_u32 v18, s0, v8, s26                              // 0000000080BC: D7010012 00003508
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 0000000080C4: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v14, null, s27, v14, vcc_lo         // 0000000080CC: D5227C0E 01AA1C1B
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000080D4: BF870113
	v_cmp_le_u32_e32 vcc_lo, s26, v18                          // 0000000080D8: 7C96241A
	v_subrev_co_ci_u32_e64 v14, null, 0, v14, s0               // 0000000080DC: D5227C0E 00021C80
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 0000000080E4: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 0000000080EC: BF870002
	v_cmp_le_u32_e32 vcc_lo, s27, v14                          // 0000000080F0: 7C961C1B
	v_cndmask_b32_e64 v18, 0, -1, vcc_lo                       // 0000000080F4: D5010012 01A98280
	v_cmp_le_u32_e32 vcc_lo, s26, v8                           // 0000000080FC: 7C96101A
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 000000008100: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s27, v3                           // 000000008108: 7C96061B
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 00000000810C: D5010013 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s27, v14                          // 000000008114: 7C941C1B
	v_cndmask_b32_e32 v9, v18, v9, vcc_lo                      // 000000008118: 02121312
	v_add_co_u32 v14, vcc_lo, v10, 1                           // 00000000811C: D7006A0E 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000008124: BF8701D1
	v_add_co_ci_u32_e64 v18, null, 0, v11, vcc_lo              // 000000008128: D5207C12 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s27, v3                           // 000000008130: 7C94061B
	v_cndmask_b32_e32 v3, v19, v8, vcc_lo                      // 000000008134: 02061113
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 000000008138: 7C9A1280
	v_xor_b32_e32 v9, s24, v16                                 // 00000000813C: 3A122018
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 000000008140: D44D0000 00020680
	v_cndmask_b32_e32 v3, v14, v15, vcc_lo                     // 000000008148: 02061F0E
	v_cndmask_b32_e32 v8, v18, v17, vcc_lo                     // 00000000814C: 02102312
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008150: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s0                          // 000000008154: D5010003 0002070A
	v_cndmask_b32_e64 v8, v11, v8, s0                          // 00000000815C: D5010008 0002110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008164: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 000000008168: 3A061303
	v_xor_b32_e32 v8, v8, v9                                   // 00000000816C: 3A101308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008170: BF870092
	v_sub_co_u32 v10, vcc_lo, v3, v9                           // 000000008174: D7016A0A 00021303
	v_sub_co_ci_u32_e64 v11, null, v8, v9, vcc_lo              // 00000000817C: D5217C0B 01AA1308
	s_and_not1_saveexec_b32 s0, s23                            // 000000008184: BE803017
	s_cbranch_execz 25                                         // 000000008188: BFA50019 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x7f0>
	s_sub_i32 s23, 0, s14                                      // 00000000818C: 81970E80
	v_mov_b32_e32 v11, v2                                      // 000000008190: 7E160302
	v_mul_lo_u32 v3, s23, v13                                  // 000000008194: D72C0003 00021A17
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000819C: BF870091
	v_mul_hi_u32 v3, v13, v3                                   // 0000000081A0: D72D0003 0002070D
	v_add_nc_u32_e32 v3, v13, v3                               // 0000000081A8: 4A06070D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000081AC: BF870091
	v_mul_hi_u32 v3, v8, v3                                    // 0000000081B0: D72D0003 00020708
	v_mul_lo_u32 v9, v3, s14                                   // 0000000081B8: D72C0009 00001D03
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000081C0: BF870121
	v_sub_nc_u32_e32 v8, v8, v9                                // 0000000081C4: 4C101308
	v_add_nc_u32_e32 v9, 1, v3                                 // 0000000081C8: 4A120681
	v_subrev_nc_u32_e32 v10, s14, v8                           // 0000000081CC: 4E14100E
	v_cmp_le_u32_e32 vcc_lo, s14, v8                           // 0000000081D0: 7C96100E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000081D4: BF870092
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_cndmask_b32 v3, v3, v9// 0000000081D8: CA521508 08021303
	v_cmp_le_u32_e32 vcc_lo, s14, v8                           // 0000000081E0: 7C96100E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000081E4: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 0000000081E8: 4A120681
	v_cndmask_b32_e32 v10, v3, v9, vcc_lo                      // 0000000081EC: 02141303
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000081F0: 8C7E007E
	v_mul_lo_u32 v3, v7, s12                                   // 0000000081F4: D72C0003 00001907
	v_mul_lo_u32 v14, v6, s13                                  // 0000000081FC: D72C000E 00001B06
	v_mad_u64_u32 v[8:9], null, v6, s12, 0                     // 000000008204: D6FE7C08 02001906
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000820C: BF870091
	v_add3_u32 v9, v9, v14, v3                                 // 000000008210: D6550009 040E1D09
	v_lshlrev_b64 v[14:15], 2, v[8:9]                          // 000000008218: D73C000E 00021082
	v_lshlrev_b64 v[8:9], 2, v[10:11]                          // 000000008220: D73C0008 00021482
	s_waitcnt lgkmcnt(0)                                       // 000000008228: BF89FC07
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000822C: BF870092
	v_add_co_u32 v3, vcc_lo, s6, v14                           // 000000008230: D7006A03 00021C06
	v_add_co_ci_u32_e64 v11, null, s7, v15, vcc_lo             // 000000008238: D5207C0B 01AA1E07
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008240: BF870092
	v_add_co_u32 v10, vcc_lo, v3, v8                           // 000000008244: D7006A0A 00021103
	v_add_co_ci_u32_e64 v11, null, v11, v9, vcc_lo             // 00000000824C: D5207C0B 01AA130B
	v_mov_b32_e32 v3, 0                                        // 000000008254: 7E060280
	global_load_b32 v10, v[10:11], off                         // 000000008258: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 000000008260: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 000000008264: 3416149F
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 000000008268: BF8704B1
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 00000000826C: 7CA214C1
	v_cmp_gt_i64_e64 s0, s[10:11], v[10:11]                    // 000000008270: D4540000 0002140A
	s_and_b32 s23, vcc_lo, s0                                  // 000000008278: 8B17006A
	s_and_saveexec_b32 s0, s23                                 // 00000000827C: BE802017
	s_cbranch_execz 65056                                      // 000000008280: BFA5FE20 <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x104>
	v_mul_lo_u32 v3, s19, v6                                   // 000000008284: D72C0003 00020C13
	v_mul_lo_u32 v16, s18, v7                                  // 00000000828C: D72C0010 00020E12
	v_mad_u64_u32 v[14:15], null, s18, v6, 0                   // 000000008294: D6FE7C0E 02020C12
	v_lshlrev_b64 v[6:7], 2, v[10:11]                          // 00000000829C: D73C0006 00021482
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000082A4: BF870112
	v_add3_u32 v3, v15, v16, v3                                // 0000000082A8: D6550003 040E210F
	v_sub_co_u32 v6, vcc_lo, v6, v14                           // 0000000082B0: D7016A06 00021D06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000082B8: BF870111
	v_sub_co_ci_u32_e64 v3, null, v7, v3, vcc_lo               // 0000000082BC: D5217C03 01AA0707
	v_sub_co_u32 v8, vcc_lo, v6, v8                            // 0000000082C4: D7016A08 00021106
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000082CC: BF870111
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 0000000082D0: D5217C03 01AA1303
	v_mul_lo_u32 v9, s15, v8                                   // 0000000082D8: D72C0009 0002100F
	v_mad_u64_u32 v[6:7], null, s14, v8, v[0:1]                // 0000000082E0: D6FE7C06 0402100E
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000082E8: BF870113
	v_mul_lo_u32 v3, s14, v3                                   // 0000000082EC: D72C0003 0002060E
	v_add_co_u32 v6, vcc_lo, s4, v6                            // 0000000082F4: D7006A06 00020C04
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000082FC: BF870092
	v_add3_u32 v3, v9, v7, v3                                  // 000000008300: D6550003 040E0F09
	v_add_co_ci_u32_e64 v7, null, s5, v3, vcc_lo               // 000000008308: D5207C07 01AA0605
	global_load_b32 v3, v[6:7], off                            // 000000008310: DC520000 037C0006
	s_branch 65018                                             // 000000008318: BFA0FDFA <_ZN12_GLOBAL__N_120gather_global_kernelEPKjPKiPjlllll+0x104>
	s_endpgm                                                   // 00000000831C: BFB00000
		...

0000000000008400 <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll>:
	s_clause 0x1                                               // 000000008400: BF850001
	s_load_b256 s[4:11], s[0:1], 0x18                          // 000000008404: F40C0100 F8000018
	s_load_b64 s[12:13], s[0:1], 0x10                          // 00000000840C: F4040300 F8000010
	v_mov_b32_e32 v2, 0                                        // 000000008414: 7E040280
	s_mov_b32 s18, 0                                           // 000000008418: BE920080
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000841C: BF8700A1
	v_dual_mov_b32 v1, v2 :: v_dual_lshlrev_b32 v12, 2, v0     // 000000008420: CA220102 010C0082
	s_waitcnt lgkmcnt(0)                                       // 000000008428: BF89FC07
	v_cmp_gt_i64_e64 s2, s[10:11], v[0:1]                      // 00000000842C: D4540002 0002000A
	s_and_saveexec_b32 s14, s2                                 // 000000008434: BE8E2002
	s_cbranch_execz 300                                        // 000000008438: BFA5012C <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x4ec>
	v_cvt_f32_u32_e32 v3, s8                                   // 00000000843C: 7E060C08
	s_load_b128 s[24:27], s[0:1], null                         // 000000008440: F4080600 F8000000
	s_mul_i32 s3, s7, s15                                      // 000000008448: 96030F07
	s_mul_hi_u32 s7, s6, s15                                   // 00000000844C: 96870F06
	s_mul_i32 s6, s6, s15                                      // 000000008450: 96060F06
	v_rcp_iflag_f32_e32 v3, v3                                 // 000000008454: 7E065703
	s_add_i32 s7, s7, s3                                       // 000000008458: 81070307
	s_load_b32 s3, s[0:1], 0x44                                // 00000000845C: F40000C0 F8000044
	s_lshl_b64 s[6:7], s[6:7], 2                               // 000000008464: 84868206
	v_add_nc_u32_e32 v13, 0, v12                               // 000000008468: 4A1A1880
	s_waitcnt_depctr 0xfff                                     // 00000000846C: BF880FFF
	v_mul_f32_e32 v3, 0x4f7ffffe, v3                           // 000000008470: 100606FF 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000008478: BF8704D1
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000847C: 7E060F03
	s_waitcnt lgkmcnt(0)                                       // 000000008480: BF89FC07
	s_add_u32 s19, s26, s6                                     // 000000008484: 8013061A
	s_addc_u32 s20, s27, s7                                    // 000000008488: 8214071B
	s_sub_i32 s6, 0, s8                                        // 00000000848C: 81860880
	v_mul_lo_u32 v4, s6, v3                                    // 000000008490: D72C0004 00020606
	s_and_b32 s21, s3, 0xffff                                  // 000000008498: 8B15FF03 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000084A0: BF870099
	s_lshl_b32 s22, s21, 2                                     // 0000000084A4: 84168215
	v_mul_hi_u32 v6, v3, v4                                    // 0000000084A8: D72D0006 00020903
	v_add_co_u32 v4, s6, s24, v12                              // 0000000084B0: D7000604 00021818
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000084B8: BF870001
	v_add_co_ci_u32_e64 v5, null, s25, 0, s6                   // 0000000084BC: D5207C05 00190019
	s_ashr_i32 s6, s9, 31                                      // 0000000084C4: 86069F09
	v_dual_mov_b32 v7, v1 :: v_dual_add_nc_u32 v14, v3, v6     // 0000000084C8: CA200101 070E0D03
	v_mov_b32_e32 v6, v0                                       // 0000000084D0: 7E0C0300
	s_branch 19                                                // 0000000084D4: BFA00013 <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x124>
	s_or_b32 exec_lo, exec_lo, s3                              // 0000000084D8: 8C7E037E
	v_add_co_u32 v6, vcc_lo, v6, s21                           // 0000000084DC: D7006A06 00002B06
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000084E4: BF870001
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 0000000084E8: D5207C07 01AA0E80
	v_add_co_u32 v4, s3, v4, s22                               // 0000000084F0: D7000304 00002D04
	s_waitcnt vmcnt(0)                                         // 0000000084F8: BF8903F7
	ds_store_b32 v13, v3                                       // 0000000084FC: D8340000 0000030D
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 000000008504: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s3                    // 000000008508: D5207C05 000E0A80
	v_add_nc_u32_e32 v13, s22, v13                             // 000000008510: 4A1A1A16
	s_or_b32 s18, vcc_lo, s18                                  // 000000008514: 8C12126A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000008518: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s18                       // 00000000851C: 917E127E
	s_cbranch_execz 242                                        // 000000008520: BFA500F2 <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x4ec>
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000008524: BF8700A2
	v_or_b32_e32 v3, s9, v7                                    // 000000008528: 38060E09
	s_mov_b32 s3, exec_lo                                      // 00000000852C: BE83007E
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000008530: 7DBA0480
	s_xor_b32 s23, exec_lo, s3                                 // 000000008534: 8D17037E
	s_cbranch_execz 175                                        // 000000008538: BFA500AF <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x3f8>
	s_add_u32 s16, s8, s6                                      // 00000000853C: 80100608
	s_mov_b32 s7, s6                                           // 000000008540: BE870006
	s_addc_u32 s17, s9, s6                                     // 000000008544: 82110609
	v_ashrrev_i32_e32 v17, 31, v7                              // 000000008548: 34220E9F
	s_xor_b64 s[16:17], s[16:17], s[6:7]                       // 00000000854C: 8D900610
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000008550: BF870159
	v_cvt_f32_u32_e32 v3, s16                                  // 000000008554: 7E060C10
	v_cvt_f32_u32_e32 v8, s17                                  // 000000008558: 7E100C11
	s_sub_u32 s3, 0, s16                                       // 00000000855C: 80831080
	s_subb_u32 s25, 0, s17                                     // 000000008560: 82991180
	v_add_co_u32 v9, vcc_lo, v6, v17                           // 000000008564: D7006A09 00022306
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 00000000856C: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008574: BF870112
	v_xor_b32_e32 v18, v9, v17                                 // 000000008578: 3A242309
	v_rcp_f32_e32 v3, v3                                       // 00000000857C: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000008580: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000008584: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000858C: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 000000008590: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 000000008598: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000859C: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 0000000085A0: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 0000000085A8: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 0000000085AC: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000085B0: BF870112
	v_readfirstlane_b32 s7, v8                                 // 0000000085B4: 7E0E0508
	v_readfirstlane_b32 s24, v3                                // 0000000085B8: 7E300503
	s_mul_i32 s26, s3, s7                                      // 0000000085BC: 961A0703
	v_add_co_ci_u32_e64 v3, null, v7, v17, vcc_lo              // 0000000085C0: D5207C03 01AA2307
	s_mul_hi_u32 s28, s3, s24                                  // 0000000085C8: 969C1803
	s_mul_i32 s27, s25, s24                                    // 0000000085CC: 961B1819
	s_add_i32 s26, s28, s26                                    // 0000000085D0: 811A1A1C
	s_mul_i32 s29, s3, s24                                     // 0000000085D4: 961D1803
	s_add_i32 s26, s26, s27                                    // 0000000085D8: 811A1B1A
	s_mul_hi_u32 s28, s24, s29                                 // 0000000085DC: 969C1D18
	s_mul_i32 s31, s24, s26                                    // 0000000085E0: 961F1A18
	s_mul_hi_u32 s30, s7, s29                                  // 0000000085E4: 969E1D07
	s_mul_i32 s27, s7, s29                                     // 0000000085E8: 961B1D07
	s_mul_hi_u32 s29, s24, s26                                 // 0000000085EC: 969D1A18
	s_add_u32 s28, s28, s31                                    // 0000000085F0: 801C1F1C
	s_addc_u32 s29, 0, s29                                     // 0000000085F4: 821D1D80
	s_mul_hi_u32 s33, s7, s26                                  // 0000000085F8: 96A11A07
	s_add_u32 s27, s28, s27                                    // 0000000085FC: 801B1B1C
	s_mul_i32 s26, s7, s26                                     // 000000008600: 961A1A07
	s_addc_u32 s27, s29, s30                                   // 000000008604: 821B1E1D
	s_addc_u32 s28, s33, 0                                     // 000000008608: 821C8021
	s_add_u32 s26, s27, s26                                    // 00000000860C: 801A1A1B
	s_addc_u32 s27, 0, s28                                     // 000000008610: 821B1C80
	s_add_u32 s24, s24, s26                                    // 000000008614: 80181A18
	s_cselect_b32 s26, -1, 0                                   // 000000008618: 981A80C1
	s_mul_hi_u32 s28, s3, s24                                  // 00000000861C: 969C1803
	s_cmp_lg_u32 s26, 0                                        // 000000008620: BF07801A
	s_mul_i32 s26, s3, s24                                     // 000000008624: 961A1803
	s_addc_u32 s7, s7, s27                                     // 000000008628: 82071B07
	s_mul_i32 s25, s25, s24                                    // 00000000862C: 96191819
	s_mul_i32 s3, s3, s7                                       // 000000008630: 96030703
	s_mul_hi_u32 s27, s24, s26                                 // 000000008634: 969B1A18
	s_add_i32 s3, s28, s3                                      // 000000008638: 8103031C
	s_mul_hi_u32 s28, s7, s26                                  // 00000000863C: 969C1A07
	s_add_i32 s3, s3, s25                                      // 000000008640: 81031903
	s_mul_i32 s25, s7, s26                                     // 000000008644: 96191A07
	s_mul_i32 s30, s24, s3                                     // 000000008648: 961E0318
	s_mul_hi_u32 s29, s24, s3                                  // 00000000864C: 969D0318
	s_add_u32 s27, s27, s30                                    // 000000008650: 801B1E1B
	s_addc_u32 s29, 0, s29                                     // 000000008654: 821D1D80
	s_mul_hi_u32 s26, s7, s3                                   // 000000008658: 969A0307
	s_add_u32 s25, s27, s25                                    // 00000000865C: 8019191B
	s_mul_i32 s3, s7, s3                                       // 000000008660: 96030307
	s_addc_u32 s25, s29, s28                                   // 000000008664: 82191C1D
	s_addc_u32 s26, s26, 0                                     // 000000008668: 821A801A
	s_add_u32 s3, s25, s3                                      // 00000000866C: 80030319
	s_addc_u32 s25, 0, s26                                     // 000000008670: 82191A80
	s_add_u32 s3, s24, s3                                      // 000000008674: 80030318
	s_cselect_b32 s24, -1, 0                                   // 000000008678: 981880C1
	v_xor_b32_e32 v3, v3, v17                                  // 00000000867C: 3A062303
	s_cmp_lg_u32 s24, 0                                        // 000000008680: BF078018
	v_mul_hi_u32 v19, v18, s3                                  // 000000008684: D72D0013 00000712
	s_addc_u32 s7, s7, s25                                     // 00000000868C: 82071907
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000008690: BF8701B9
	v_mad_u64_u32 v[8:9], null, v18, s7, 0                     // 000000008694: D6FE7C08 02000F12
	v_mad_u64_u32 v[10:11], null, v3, s3, 0                    // 00000000869C: D6FE7C0A 02000703
	v_mad_u64_u32 v[15:16], null, v3, s7, 0                    // 0000000086A4: D6FE7C0F 02000F03
	v_add_co_u32 v8, vcc_lo, v19, v8                           // 0000000086AC: D7006A08 00021113
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000086B4: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 0000000086B8: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 0000000086C0: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000086C8: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 0000000086CC: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v16, vcc_lo             // 0000000086D0: 40122080
	v_add_co_u32 v10, vcc_lo, v8, v15                          // 0000000086D4: D7006A0A 00021F08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000086DC: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 0000000086E0: D5207C0B 01AA1280
	v_mul_lo_u32 v15, s17, v10                                 // 0000000086E8: D72C000F 00021411
	v_mad_u64_u32 v[8:9], null, s16, v10, 0                    // 0000000086F0: D6FE7C08 02021410
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000086F8: BF870113
	v_mul_lo_u32 v16, s16, v11                                 // 0000000086FC: D72C0010 00021610
	v_sub_co_u32 v8, vcc_lo, v18, v8                           // 000000008704: D7016A08 00021112
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000870C: BF8700A2
	v_add3_u32 v9, v9, v16, v15                                // 000000008710: D6550009 043E2109
	v_add_co_u32 v16, s3, v10, 2                               // 000000008718: D7000310 0001050A
	v_add_co_ci_u32_e64 v18, null, 0, v11, s3                  // 000000008720: D5207C12 000E1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000008728: BF8701B3
	v_sub_nc_u32_e32 v15, v3, v9                               // 00000000872C: 4C1E1303
	v_sub_co_u32 v19, s3, v8, s16                              // 000000008730: D7010313 00002108
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 000000008738: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v15, null, s17, v15, vcc_lo         // 000000008740: D5227C0F 01AA1E11
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008748: BF870113
	v_cmp_le_u32_e32 vcc_lo, s16, v19                          // 00000000874C: 7C962610
	v_subrev_co_ci_u32_e64 v15, null, 0, v15, s3               // 000000008750: D5227C0F 000E1E80
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 000000008758: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 000000008760: BF870002
	v_cmp_le_u32_e32 vcc_lo, s17, v15                          // 000000008764: 7C961E11
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 000000008768: D5010013 01A98280
	v_cmp_le_u32_e32 vcc_lo, s16, v8                           // 000000008770: 7C961010
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 000000008774: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s17, v3                           // 00000000877C: 7C960611
	v_cndmask_b32_e64 v20, 0, -1, vcc_lo                       // 000000008780: D5010014 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s17, v15                          // 000000008788: 7C941E11
	v_cndmask_b32_e32 v9, v19, v9, vcc_lo                      // 00000000878C: 02121313
	v_add_co_u32 v15, vcc_lo, v10, 1                           // 000000008790: D7006A0F 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000008798: BF8701D1
	v_add_co_ci_u32_e64 v19, null, 0, v11, vcc_lo              // 00000000879C: D5207C13 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s17, v3                           // 0000000087A4: 7C940611
	v_cndmask_b32_e32 v3, v20, v8, vcc_lo                      // 0000000087A8: 02061114
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 0000000087AC: 7C9A1280
	v_xor_b32_e32 v9, s6, v17                                  // 0000000087B0: 3A122206
	v_cmp_ne_u32_e64 s3, 0, v3                                 // 0000000087B4: D44D0003 00020680
	v_cndmask_b32_e32 v3, v15, v16, vcc_lo                     // 0000000087BC: 0206210F
	v_cndmask_b32_e32 v8, v19, v18, vcc_lo                     // 0000000087C0: 02102513
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000087C4: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s3                          // 0000000087C8: D5010003 000E070A
	v_cndmask_b32_e64 v8, v11, v8, s3                          // 0000000087D0: D5010008 000E110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000087D8: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 0000000087DC: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 0000000087E0: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000087E4: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 0000000087E8: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 0000000087F0: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s3, s23                            // 0000000087F8: BE833017
	s_cbranch_execz 18                                         // 0000000087FC: BFA50012 <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x448>
	v_mul_hi_u32 v3, v6, v14                                   // 000000008800: D72D0003 00021D06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008808: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 00000000880C: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 000000008814: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008818: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 00000000881C: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000008820: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 000000008824: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000882C: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 000000008830: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000008834: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008838: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 00000000883C: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 000000008840: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s3                              // 000000008848: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000884C: BF870121
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 000000008850: D73C0008 00021082
	v_mov_b32_e32 v3, 0                                        // 000000008858: 7E060280
	v_add_co_u32 v10, vcc_lo, s19, v8                          // 00000000885C: D7006A0A 00021013
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000008864: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s20, v9, vcc_lo             // 000000008868: D5207C0B 01AA1214
	global_load_b32 v10, v[10:11], off                         // 000000008870: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 000000008878: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 00000000887C: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 000000008880: 7CA214C1
	v_cmp_gt_i64_e64 s3, s[4:5], v[10:11]                      // 000000008884: D4540003 00021404
	s_and_b32 s7, vcc_lo, s3                                   // 00000000888C: 8B07036A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000008890: BF870009
	s_and_saveexec_b32 s3, s7                                  // 000000008894: BE832007
	s_cbranch_execz 65295                                      // 000000008898: BFA5FF0F <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0xd8>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 00000000889C: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000088A4: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 0000000088A8: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 0000000088B0: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000088B8: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 0000000088BC: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 0000000088C4: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 0000000088CC: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000088D4: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 0000000088D8: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 0000000088E0: DC520000 037C0008
	s_branch 65275                                             // 0000000088E8: BFA0FEFB <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0xd8>
	s_or_b32 exec_lo, exec_lo, s14                             // 0000000088EC: 8C7E0E7E
	s_waitcnt lgkmcnt(0)                                       // 0000000088F0: BF89FC07
	s_barrier                                                  // 0000000088F4: BFBD0000
	buffer_gl0_inv                                             // 0000000088F8: E0AC0000 00000000
	s_and_saveexec_b32 s3, s2                                  // 000000008900: BE832002
	s_cbranch_execz 50                                         // 000000008904: BFA50032 <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x5d0>
	s_load_b32 s4, s[0:1], 0x44                                // 000000008908: F4000100 F8000044
	s_mul_i32 s1, s11, s15                                     // 000000008910: 96010F0B
	s_mul_hi_u32 s2, s10, s15                                  // 000000008914: 96820F0A
	s_mul_i32 s0, s10, s15                                     // 000000008918: 96000F0A
	s_add_i32 s1, s2, s1                                       // 00000000891C: 81010102
	v_add_nc_u32_e32 v4, 0, v12                                // 000000008920: 4A081880
	s_lshl_b64 s[2:3], s[0:1], 2                               // 000000008924: 84828200
	s_waitcnt lgkmcnt(0)                                       // 000000008928: BF89FC07
	s_and_b32 s1, s4, 0xffff                                   // 00000000892C: 8B01FF04 0000FFFF
	s_add_u32 s0, s12, s2                                      // 000000008934: 8000020C
	s_addc_u32 s2, s13, s3                                     // 000000008938: 8202030D
	v_add_co_u32 v2, s0, s0, v12                               // 00000000893C: D7000002 00021800
	s_delay_alu instid0(VALU_DEP_1)                            // 000000008944: BF870001
	v_add_co_ci_u32_e64 v3, null, s2, 0, s0                    // 000000008948: D5207C03 00010002
	s_mov_b32 s2, 0                                            // 000000008950: BE820080
	s_lshl_b32 s3, s1, 2                                       // 000000008954: 84038201
	s_nop 0                                                    // 000000008958: BF800000
	s_nop 0                                                    // 00000000895C: BF800000
	s_nop 0                                                    // 000000008960: BF800000
	s_nop 0                                                    // 000000008964: BF800000
	s_nop 0                                                    // 000000008968: BF800000
	s_nop 0                                                    // 00000000896C: BF800000
	s_nop 0                                                    // 000000008970: BF800000
	s_nop 0                                                    // 000000008974: BF800000
	s_nop 0                                                    // 000000008978: BF800000
	s_nop 0                                                    // 00000000897C: BF800000
	ds_load_b32 v5, v4                                         // 000000008980: D8D80000 05000004
	v_add_co_u32 v0, vcc_lo, v0, s1                            // 000000008988: D7006A00 00000300
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008990: BF870121
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 000000008994: D5207C01 01AA0280
	v_add_nc_u32_e32 v4, s3, v4                                // 00000000899C: 4A080803
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[0:1]                  // 0000000089A0: 7CA6000A
	s_or_b32 s2, vcc_lo, s2                                    // 0000000089A4: 8C02026A
	s_waitcnt lgkmcnt(0)                                       // 0000000089A8: BF89FC07
	global_store_b32 v[2:3], v5, off                           // 0000000089AC: DC6A0000 007C0502
	v_add_co_u32 v2, s0, v2, s3                                // 0000000089B4: D7000002 00000702
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000089BC: BF870001
	v_add_co_ci_u32_e64 v3, null, 0, v3, s0                    // 0000000089C0: D5207C03 00020680
	s_and_not1_b32 exec_lo, exec_lo, s2                        // 0000000089C8: 917E027E
	s_cbranch_execnz 65516                                     // 0000000089CC: BFA6FFEC <_ZN12_GLOBAL__N_122gather_vgpr_lds_kernelEPKjPKiPjllll+0x580>
	s_endpgm                                                   // 0000000089D0: BFB00000
		...

0000000000008a00 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll>:
	s_clause 0x2                                               // 000000008A00: BF850002
	s_load_b256 s[4:11], s[0:1], 0x18                          // 000000008A04: F40C0100 F8000018
	s_load_b128 s[16:19], s[0:1], null                         // 000000008A0C: F4080400 F8000000
	s_load_b64 s[12:13], s[0:1], 0x10                          // 000000008A14: F4040300 F8000010
	v_mov_b32_e32 v1, 0                                        // 000000008A1C: 7E020280
	s_waitcnt lgkmcnt(0)                                       // 000000008A20: BF89FC07
	s_delay_alu instid0(VALU_DEP_1)                            // 000000008A24: BF870001
	v_cmp_gt_i64_e64 s2, s[10:11], v[0:1]                      // 000000008A28: D4540002 0002000A
	s_and_saveexec_b32 s3, s2                                  // 000000008A30: BE832002
	s_cbranch_execz 24                                         // 000000008A34: BFA50018 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x98>
	s_load_b32 s14, s[0:1], 0x4c                               // 000000008A38: F4000380 F800004C
	v_lshl_add_u32 v4, v0, 2, 0                                // 000000008A40: D6460004 02010500
	v_dual_mov_b32 v3, v1 :: v_dual_mov_b32 v2, v0             // 000000008A48: CA100101 03020100
	s_mov_b32 s20, 0                                           // 000000008A50: BE940080
	s_waitcnt lgkmcnt(0)                                       // 000000008A54: BF89FC07
	s_and_b32 s14, s14, 0xffff                                 // 000000008A58: 8B0EFF0E 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000008A60: BF870009
	s_lshl_b32 s21, s14, 2                                     // 000000008A64: 8415820E
	v_add_co_u32 v2, vcc_lo, v2, s14                           // 000000008A68: D7006A02 00001D02
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000008A70: BF8704D1
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo                // 000000008A74: D5207C03 01AA0680
	ds_store_b32 v4, v1                                        // 000000008A7C: D8340000 00000104
	v_add_nc_u32_e32 v4, s21, v4                               // 000000008A84: 4A080815
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[2:3]                  // 000000008A88: 7CA6040A
	s_or_b32 s20, vcc_lo, s20                                  // 000000008A8C: 8C14146A
	s_and_not1_b32 exec_lo, exec_lo, s20                       // 000000008A90: 917E147E
	s_cbranch_execnz 65524                                     // 000000008A94: BFA6FFF4 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x68>
	s_or_b32 exec_lo, exec_lo, s3                              // 000000008A98: 8C7E037E
	v_lshlrev_b32_e32 v12, 2, v0                               // 000000008A9C: 30180082
	s_mov_b32 s14, 0                                           // 000000008AA0: BE8E0080
	s_waitcnt lgkmcnt(0)                                       // 000000008AA4: BF89FC07
	s_barrier                                                  // 000000008AA8: BFBD0000
	buffer_gl0_inv                                             // 000000008AAC: E0AC0000 00000000
	s_and_saveexec_b32 s20, s2                                 // 000000008AB4: BE942002
	s_cbranch_execz 298                                        // 000000008AB8: BFA5012A <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x564>
	v_cvt_f32_u32_e32 v2, s8                                   // 000000008ABC: 7E040C08
	s_mul_i32 s3, s7, s15                                      // 000000008AC0: 96030F07
	s_mul_hi_u32 s7, s6, s15                                   // 000000008AC4: 96870F06
	s_mul_i32 s6, s6, s15                                      // 000000008AC8: 96060F06
	s_add_i32 s7, s7, s3                                       // 000000008ACC: 81070307
	v_rcp_iflag_f32_e32 v2, v2                                 // 000000008AD0: 7E045702
	s_lshl_b64 s[6:7], s[6:7], 2                               // 000000008AD4: 84868206
	s_load_b32 s3, s[0:1], 0x4c                                // 000000008AD8: F40000C0 F800004C
	s_add_u32 s18, s18, s6                                     // 000000008AE0: 80120612
	s_addc_u32 s19, s19, s7                                    // 000000008AE4: 82130713
	s_sub_i32 s6, 0, s8                                        // 000000008AE8: 81860880
	s_waitcnt_depctr 0xfff                                     // 000000008AEC: BF880FFF
	v_dual_mul_f32 v2, 0x4f7ffffe, v2 :: v_dual_add_nc_u32 v13, 0, v12// 000000008AF0: C8E004FF 020C1880 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008AFC: BF870091
	v_cvt_u32_f32_e32 v3, v2                                   // 000000008B00: 7E060F02
	v_mul_lo_u32 v2, s6, v3                                    // 000000008B04: D72C0002 00020606
	v_add_co_u32 v4, s6, s16, v12                              // 000000008B0C: D7000604 00021810
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000008B14: BF8701D1
	v_add_co_ci_u32_e64 v5, null, s17, 0, s6                   // 000000008B18: D5207C05 00190011
	s_waitcnt lgkmcnt(0)                                       // 000000008B20: BF89FC07
	s_and_b32 s21, s3, 0xffff                                  // 000000008B24: 8B15FF03 0000FFFF
	s_ashr_i32 s6, s9, 31                                      // 000000008B2C: 86069F09
	s_lshl_b32 s22, s21, 2                                     // 000000008B30: 84168215
	v_mul_hi_u32 v6, v3, v2                                    // 000000008B34: D72D0006 00020503
	v_mov_b32_e32 v2, 0                                        // 000000008B3C: 7E040280
	s_delay_alu instid0(VALU_DEP_2)                            // 000000008B40: BF870002
	v_dual_mov_b32 v7, v1 :: v_dual_add_nc_u32 v14, v3, v6     // 000000008B44: CA200101 070E0D03
	v_mov_b32_e32 v6, v0                                       // 000000008B4C: 7E0C0300
	s_branch 16                                                // 000000008B50: BFA00010 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x194>
	s_or_b32 exec_lo, exec_lo, s3                              // 000000008B54: 8C7E037E
	v_add_co_u32 v6, vcc_lo, v6, s21                           // 000000008B58: D7006A06 00002B06
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000008B60: BF8700A1
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 000000008B64: D5207C07 01AA0E80
	v_add_co_u32 v4, s3, v4, s22                               // 000000008B6C: D7000304 00002D04
	v_add_co_ci_u32_e64 v5, null, 0, v5, s3                    // 000000008B74: D5207C05 000E0A80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 000000008B7C: BF8704B3
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 000000008B80: 7CA60C0A
	v_add_nc_u32_e32 v13, s22, v13                             // 000000008B84: 4A1A1A16
	s_or_b32 s14, vcc_lo, s14                                  // 000000008B88: 8C0E0E6A
	s_and_not1_b32 exec_lo, exec_lo, s14                       // 000000008B8C: 917E0E7E
	s_cbranch_execz 244                                        // 000000008B90: BFA500F4 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x564>
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000008B94: BF8700A2
	v_or_b32_e32 v3, s9, v7                                    // 000000008B98: 38060E09
	s_mov_b32 s3, exec_lo                                      // 000000008B9C: BE83007E
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000008BA0: 7DBA0480
	s_xor_b32 s23, exec_lo, s3                                 // 000000008BA4: 8D17037E
	s_cbranch_execz 175                                        // 000000008BA8: BFA500AF <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x468>
	s_add_u32 s16, s8, s6                                      // 000000008BAC: 80100608
	s_mov_b32 s7, s6                                           // 000000008BB0: BE870006
	s_addc_u32 s17, s9, s6                                     // 000000008BB4: 82110609
	v_ashrrev_i32_e32 v17, 31, v7                              // 000000008BB8: 34220E9F
	s_xor_b64 s[16:17], s[16:17], s[6:7]                       // 000000008BBC: 8D900610
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000008BC0: BF870159
	v_cvt_f32_u32_e32 v3, s16                                  // 000000008BC4: 7E060C10
	v_cvt_f32_u32_e32 v8, s17                                  // 000000008BC8: 7E100C11
	s_sub_u32 s3, 0, s16                                       // 000000008BCC: 80831080
	s_subb_u32 s25, 0, s17                                     // 000000008BD0: 82991180
	v_add_co_u32 v9, vcc_lo, v6, v17                           // 000000008BD4: D7006A09 00022306
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 000000008BDC: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008BE4: BF870112
	v_xor_b32_e32 v18, v9, v17                                 // 000000008BE8: 3A242309
	v_rcp_f32_e32 v3, v3                                       // 000000008BEC: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000008BF0: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000008BF4: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008BFC: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 000000008C00: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 000000008C08: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008C0C: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 000000008C10: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 000000008C18: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 000000008C1C: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008C20: BF870112
	v_readfirstlane_b32 s7, v8                                 // 000000008C24: 7E0E0508
	v_readfirstlane_b32 s24, v3                                // 000000008C28: 7E300503
	s_mul_i32 s26, s3, s7                                      // 000000008C2C: 961A0703
	v_add_co_ci_u32_e64 v3, null, v7, v17, vcc_lo              // 000000008C30: D5207C03 01AA2307
	s_mul_hi_u32 s28, s3, s24                                  // 000000008C38: 969C1803
	s_mul_i32 s27, s25, s24                                    // 000000008C3C: 961B1819
	s_add_i32 s26, s28, s26                                    // 000000008C40: 811A1A1C
	s_mul_i32 s29, s3, s24                                     // 000000008C44: 961D1803
	s_add_i32 s26, s26, s27                                    // 000000008C48: 811A1B1A
	s_mul_hi_u32 s28, s24, s29                                 // 000000008C4C: 969C1D18
	s_mul_i32 s31, s24, s26                                    // 000000008C50: 961F1A18
	s_mul_hi_u32 s30, s7, s29                                  // 000000008C54: 969E1D07
	s_mul_i32 s27, s7, s29                                     // 000000008C58: 961B1D07
	s_mul_hi_u32 s29, s24, s26                                 // 000000008C5C: 969D1A18
	s_add_u32 s28, s28, s31                                    // 000000008C60: 801C1F1C
	s_addc_u32 s29, 0, s29                                     // 000000008C64: 821D1D80
	s_mul_hi_u32 s33, s7, s26                                  // 000000008C68: 96A11A07
	s_add_u32 s27, s28, s27                                    // 000000008C6C: 801B1B1C
	s_mul_i32 s26, s7, s26                                     // 000000008C70: 961A1A07
	s_addc_u32 s27, s29, s30                                   // 000000008C74: 821B1E1D
	s_addc_u32 s28, s33, 0                                     // 000000008C78: 821C8021
	s_add_u32 s26, s27, s26                                    // 000000008C7C: 801A1A1B
	s_addc_u32 s27, 0, s28                                     // 000000008C80: 821B1C80
	s_add_u32 s24, s24, s26                                    // 000000008C84: 80181A18
	s_cselect_b32 s26, -1, 0                                   // 000000008C88: 981A80C1
	s_mul_hi_u32 s28, s3, s24                                  // 000000008C8C: 969C1803
	s_cmp_lg_u32 s26, 0                                        // 000000008C90: BF07801A
	s_mul_i32 s26, s3, s24                                     // 000000008C94: 961A1803
	s_addc_u32 s7, s7, s27                                     // 000000008C98: 82071B07
	s_mul_i32 s25, s25, s24                                    // 000000008C9C: 96191819
	s_mul_i32 s3, s3, s7                                       // 000000008CA0: 96030703
	s_mul_hi_u32 s27, s24, s26                                 // 000000008CA4: 969B1A18
	s_add_i32 s3, s28, s3                                      // 000000008CA8: 8103031C
	s_mul_hi_u32 s28, s7, s26                                  // 000000008CAC: 969C1A07
	s_add_i32 s3, s3, s25                                      // 000000008CB0: 81031903
	s_mul_i32 s25, s7, s26                                     // 000000008CB4: 96191A07
	s_mul_i32 s30, s24, s3                                     // 000000008CB8: 961E0318
	s_mul_hi_u32 s29, s24, s3                                  // 000000008CBC: 969D0318
	s_add_u32 s27, s27, s30                                    // 000000008CC0: 801B1E1B
	s_addc_u32 s29, 0, s29                                     // 000000008CC4: 821D1D80
	s_mul_hi_u32 s26, s7, s3                                   // 000000008CC8: 969A0307
	s_add_u32 s25, s27, s25                                    // 000000008CCC: 8019191B
	s_mul_i32 s3, s7, s3                                       // 000000008CD0: 96030307
	s_addc_u32 s25, s29, s28                                   // 000000008CD4: 82191C1D
	s_addc_u32 s26, s26, 0                                     // 000000008CD8: 821A801A
	s_add_u32 s3, s25, s3                                      // 000000008CDC: 80030319
	s_addc_u32 s25, 0, s26                                     // 000000008CE0: 82191A80
	s_add_u32 s3, s24, s3                                      // 000000008CE4: 80030318
	s_cselect_b32 s24, -1, 0                                   // 000000008CE8: 981880C1
	v_xor_b32_e32 v3, v3, v17                                  // 000000008CEC: 3A062303
	s_cmp_lg_u32 s24, 0                                        // 000000008CF0: BF078018
	v_mul_hi_u32 v19, v18, s3                                  // 000000008CF4: D72D0013 00000712
	s_addc_u32 s7, s7, s25                                     // 000000008CFC: 82071907
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000008D00: BF8701B9
	v_mad_u64_u32 v[8:9], null, v18, s7, 0                     // 000000008D04: D6FE7C08 02000F12
	v_mad_u64_u32 v[10:11], null, v3, s3, 0                    // 000000008D0C: D6FE7C0A 02000703
	v_mad_u64_u32 v[15:16], null, v3, s7, 0                    // 000000008D14: D6FE7C0F 02000F03
	v_add_co_u32 v8, vcc_lo, v19, v8                           // 000000008D1C: D7006A08 00021113
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008D24: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000008D28: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 000000008D30: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008D38: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 000000008D3C: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v16, vcc_lo             // 000000008D40: 40122080
	v_add_co_u32 v10, vcc_lo, v8, v15                          // 000000008D44: D7006A0A 00021F08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008D4C: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 000000008D50: D5207C0B 01AA1280
	v_mul_lo_u32 v15, s17, v10                                 // 000000008D58: D72C000F 00021411
	v_mad_u64_u32 v[8:9], null, s16, v10, 0                    // 000000008D60: D6FE7C08 02021410
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008D68: BF870113
	v_mul_lo_u32 v16, s16, v11                                 // 000000008D6C: D72C0010 00021610
	v_sub_co_u32 v8, vcc_lo, v18, v8                           // 000000008D74: D7016A08 00021112
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000008D7C: BF8700A2
	v_add3_u32 v9, v9, v16, v15                                // 000000008D80: D6550009 043E2109
	v_add_co_u32 v16, s3, v10, 2                               // 000000008D88: D7000310 0001050A
	v_add_co_ci_u32_e64 v18, null, 0, v11, s3                  // 000000008D90: D5207C12 000E1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000008D98: BF8701B3
	v_sub_nc_u32_e32 v15, v3, v9                               // 000000008D9C: 4C1E1303
	v_sub_co_u32 v19, s3, v8, s16                              // 000000008DA0: D7010313 00002108
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 000000008DA8: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v15, null, s17, v15, vcc_lo         // 000000008DB0: D5227C0F 01AA1E11
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008DB8: BF870113
	v_cmp_le_u32_e32 vcc_lo, s16, v19                          // 000000008DBC: 7C962610
	v_subrev_co_ci_u32_e64 v15, null, 0, v15, s3               // 000000008DC0: D5227C0F 000E1E80
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 000000008DC8: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 000000008DD0: BF870002
	v_cmp_le_u32_e32 vcc_lo, s17, v15                          // 000000008DD4: 7C961E11
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 000000008DD8: D5010013 01A98280
	v_cmp_le_u32_e32 vcc_lo, s16, v8                           // 000000008DE0: 7C961010
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 000000008DE4: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s17, v3                           // 000000008DEC: 7C960611
	v_cndmask_b32_e64 v20, 0, -1, vcc_lo                       // 000000008DF0: D5010014 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s17, v15                          // 000000008DF8: 7C941E11
	v_cndmask_b32_e32 v9, v19, v9, vcc_lo                      // 000000008DFC: 02121313
	v_add_co_u32 v15, vcc_lo, v10, 1                           // 000000008E00: D7006A0F 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000008E08: BF8701D1
	v_add_co_ci_u32_e64 v19, null, 0, v11, vcc_lo              // 000000008E0C: D5207C13 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s17, v3                           // 000000008E14: 7C940611
	v_cndmask_b32_e32 v3, v20, v8, vcc_lo                      // 000000008E18: 02061114
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 000000008E1C: 7C9A1280
	v_xor_b32_e32 v9, s6, v17                                  // 000000008E20: 3A122206
	v_cmp_ne_u32_e64 s3, 0, v3                                 // 000000008E24: D44D0003 00020680
	v_cndmask_b32_e32 v3, v15, v16, vcc_lo                     // 000000008E2C: 0206210F
	v_cndmask_b32_e32 v8, v19, v18, vcc_lo                     // 000000008E30: 02102513
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008E34: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s3                          // 000000008E38: D5010003 000E070A
	v_cndmask_b32_e64 v8, v11, v8, s3                          // 000000008E40: D5010008 000E110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008E48: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 000000008E4C: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 000000008E50: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008E54: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 000000008E58: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 000000008E60: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s3, s23                            // 000000008E68: BE833017
	s_cbranch_execz 18                                         // 000000008E6C: BFA50012 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x4b8>
	v_mul_hi_u32 v3, v6, v14                                   // 000000008E70: D72D0003 00021D06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008E78: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 000000008E7C: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 000000008E84: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000008E88: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 000000008E8C: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000008E90: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 000000008E94: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008E9C: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 000000008EA0: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000008EA4: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008EA8: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 000000008EAC: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 000000008EB0: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s3                              // 000000008EB8: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008EBC: BF870091
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 000000008EC0: D73C0008 00021082
	v_add_co_u32 v10, vcc_lo, s18, v8                          // 000000008EC8: D7006A0A 00021012
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000008ED0: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s19, v9, vcc_lo             // 000000008ED4: D5207C0B 01AA1213
	global_load_b32 v10, v[10:11], off                         // 000000008EDC: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 000000008EE4: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 000000008EE8: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 000000008EEC: 7CA214C1
	v_cmp_gt_i64_e64 s3, s[4:5], v[10:11]                      // 000000008EF0: D4540003 00021404
	s_and_b32 s7, vcc_lo, s3                                   // 000000008EF8: 8B07036A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000008EFC: BF870009
	s_and_saveexec_b32 s3, s7                                  // 000000008F00: BE832007
	s_cbranch_execz 65299                                      // 000000008F04: BFA5FF13 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x154>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 000000008F08: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000008F10: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 000000008F14: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 000000008F1C: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000008F24: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 000000008F28: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 000000008F30: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 000000008F38: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 000000008F40: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 000000008F44: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 000000008F4C: DC520000 037C0008
	s_waitcnt vmcnt(0)                                         // 000000008F54: BF8903F7
	ds_store_b32 v13, v3                                       // 000000008F58: D8340000 0000030D
	s_branch 65276                                             // 000000008F60: BFA0FEFC <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x154>
	s_or_b32 exec_lo, exec_lo, s20                             // 000000008F64: 8C7E147E
	s_waitcnt lgkmcnt(0)                                       // 000000008F68: BF89FC07
	s_barrier                                                  // 000000008F6C: BFBD0000
	buffer_gl0_inv                                             // 000000008F70: E0AC0000 00000000
	s_and_saveexec_b32 s3, s2                                  // 000000008F78: BE832002
	s_cbranch_execz 52                                         // 000000008F7C: BFA50034 <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x650>
	s_load_b32 s4, s[0:1], 0x4c                                // 000000008F80: F4000100 F800004C
	s_mul_i32 s1, s11, s15                                     // 000000008F88: 96010F0B
	s_mul_hi_u32 s2, s10, s15                                  // 000000008F8C: 96820F0A
	s_mul_i32 s0, s10, s15                                     // 000000008F90: 96000F0A
	s_add_i32 s1, s2, s1                                       // 000000008F94: 81010102
	v_add_nc_u32_e32 v4, 0, v12                                // 000000008F98: 4A081880
	s_lshl_b64 s[2:3], s[0:1], 2                               // 000000008F9C: 84828200
	s_waitcnt lgkmcnt(0)                                       // 000000008FA0: BF89FC07
	s_and_b32 s1, s4, 0xffff                                   // 000000008FA4: 8B01FF04 0000FFFF
	s_add_u32 s0, s12, s2                                      // 000000008FAC: 8000020C
	s_addc_u32 s2, s13, s3                                     // 000000008FB0: 8202030D
	v_add_co_u32 v2, s0, s0, v12                               // 000000008FB4: D7000002 00021800
	s_delay_alu instid0(VALU_DEP_1)                            // 000000008FBC: BF870001
	v_add_co_ci_u32_e64 v3, null, s2, 0, s0                    // 000000008FC0: D5207C03 00010002
	s_mov_b32 s2, 0                                            // 000000008FC8: BE820080
	s_lshl_b32 s3, s1, 2                                       // 000000008FCC: 84038201
	s_nop 0                                                    // 000000008FD0: BF800000
	s_nop 0                                                    // 000000008FD4: BF800000
	s_nop 0                                                    // 000000008FD8: BF800000
	s_nop 0                                                    // 000000008FDC: BF800000
	s_nop 0                                                    // 000000008FE0: BF800000
	s_nop 0                                                    // 000000008FE4: BF800000
	s_nop 0                                                    // 000000008FE8: BF800000
	s_nop 0                                                    // 000000008FEC: BF800000
	s_nop 0                                                    // 000000008FF0: BF800000
	s_nop 0                                                    // 000000008FF4: BF800000
	s_nop 0                                                    // 000000008FF8: BF800000
	s_nop 0                                                    // 000000008FFC: BF800000
	ds_load_b32 v5, v4                                         // 000000009000: D8D80000 05000004
	v_add_co_u32 v0, vcc_lo, v0, s1                            // 000000009008: D7006A00 00000300
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009010: BF870121
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 000000009014: D5207C01 01AA0280
	v_add_nc_u32_e32 v4, s3, v4                                // 00000000901C: 4A080803
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[0:1]                  // 000000009020: 7CA6000A
	s_or_b32 s2, vcc_lo, s2                                    // 000000009024: 8C02026A
	s_waitcnt lgkmcnt(0)                                       // 000000009028: BF89FC07
	global_store_b32 v[2:3], v5, off                           // 00000000902C: DC6A0000 007C0502
	v_add_co_u32 v2, s0, v2, s3                                // 000000009034: D7000002 00000702
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000903C: BF870001
	v_add_co_ci_u32_e64 v3, null, 0, v3, s0                    // 000000009040: D5207C03 00020680
	s_and_not1_b32 exec_lo, exec_lo, s2                        // 000000009048: 917E027E
	s_cbranch_execnz 65516                                     // 00000000904C: BFA6FFEC <_ZN12_GLOBAL__N_124gather_direct_lds_kernelEPKjPKiPjlllll+0x600>
	s_endpgm                                                   // 000000009050: BFB00000
		...

0000000000009100 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii>:
	s_load_b64 s[18:19], s[0:1], 0x38                          // 000000009100: F4040480 F8000038
	s_mov_b32 s2, s15                                          // 000000009108: BE82000F
	s_mov_b32 s3, 0                                            // 00000000910C: BE830080
	s_waitcnt lgkmcnt(0)                                       // 000000009110: BF89FC07
	s_cmp_gt_i32 s18, 0                                        // 000000009114: BF028012
	s_cbranch_scc1 9                                           // 000000009118: BFA20009 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x40>
	s_add_u32 s6, s0, 64                                       // 00000000911C: 8006C000
	s_addc_u32 s7, s1, 0                                       // 000000009120: 82078001
	s_mov_b32 s4, s3                                           // 000000009124: BE840003
	s_load_b64 s[16:17], s[0:1], 0x10                          // 000000009128: F4040400 F8000010
	v_mov_b32_e32 v14, 0                                       // 000000009130: 7E1C0280
	s_and_not1_b32 vcc_lo, exec_lo, s4                         // 000000009134: 916A047E
	s_cbranch_vccz 4                                           // 000000009138: BFA30004 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x4c>
	s_branch 454                                               // 00000000913C: BFA001C6 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x758>
	s_load_b64 s[16:17], s[0:1], 0x10                          // 000000009140: F4040400 F8000010
	v_mov_b32_e32 v14, 0                                       // 000000009148: 7E1C0280
	s_clause 0x1                                               // 00000000914C: BF850001
	s_load_b256 s[4:11], s[0:1], 0x18                          // 000000009150: F40C0100 F8000018
	s_load_b128 s[12:15], s[0:1], null                         // 000000009158: F4080300 F8000000
	v_lshlrev_b32_e32 v5, 2, v0                                // 000000009160: 300A0082
	s_mov_b32 s22, 0                                           // 000000009164: BE960080
	v_mov_b32_e32 v2, 0                                        // 000000009168: 7E040280
	v_mov_b32_e32 v14, 0                                       // 00000000916C: 7E1C0280
	s_waitcnt lgkmcnt(0)                                       // 000000009170: BF89FC07
	v_cvt_f32_u32_e32 v1, s8                                   // 000000009174: 7E020C08
	s_mul_i32 s7, s7, s2                                       // 000000009178: 96070207
	s_mul_hi_u32 s20, s6, s2                                   // 00000000917C: 96940206
	s_mul_i32 s6, s6, s2                                       // 000000009180: 96060206
	s_add_i32 s7, s20, s7                                      // 000000009184: 81070714
	v_rcp_iflag_f32_e32 v1, v1                                 // 000000009188: 7E025701
	s_lshl_b64 s[6:7], s[6:7], 2                               // 00000000918C: 84868206
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009190: BF870009
	s_add_u32 s20, s14, s6                                     // 000000009194: 8014060E
	s_addc_u32 s21, s15, s7                                    // 000000009198: 8215070F
	s_cmp_eq_u32 s19, 0                                        // 00000000919C: BF068013
	s_cselect_b32 s19, -1, 0                                   // 0000000091A0: 981380C1
	s_add_u32 s6, s0, 64                                       // 0000000091A4: 8006C000
	s_addc_u32 s7, s1, 0                                       // 0000000091A8: 82078001
	s_waitcnt_depctr 0xfff                                     // 0000000091AC: BF880FFF
	v_mul_f32_e32 v1, 0x4f7ffffe, v1                           // 0000000091B0: 100202FF 4F7FFFFE
	s_sub_i32 s0, 0, s8                                        // 0000000091B8: 81800880
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000091BC: BF870121
	v_cvt_u32_f32_e32 v3, v1                                   // 0000000091C0: 7E060F01
	v_mov_b32_e32 v1, v2                                       // 0000000091C4: 7E020302
	v_mul_lo_u32 v4, s0, v3                                    // 0000000091C8: D72C0004 00020600
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000091D0: BF870112
	v_cmp_gt_i64_e64 s0, s[10:11], v[0:1]                      // 0000000091D4: D4540000 0002000A
	v_mul_hi_u32 v6, v3, v4                                    // 0000000091DC: D72D0006 00020903
	v_add_co_u32 v4, s1, s12, v5                               // 0000000091E4: D7000104 00020A0C
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000091EC: BF870001
	v_add_co_ci_u32_e64 v5, null, s13, 0, s1                   // 0000000091F0: D5207C05 0005000D
	s_ashr_i32 s12, s9, 31                                     // 0000000091F8: 860C9F09
	v_add_nc_u32_e32 v15, v3, v6                               // 0000000091FC: 4A1E0D03
	s_add_i32 s22, s22, 1                                      // 000000009200: 81168116
	s_and_saveexec_b32 s23, s0                                 // 000000009204: BE972000
	s_cbranch_execz 399                                        // 000000009208: BFA5018F <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x748>
	s_load_b32 s1, s[6:7], 0xc                                 // 00000000920C: F4000043 F800000C
	v_cvt_f32_u32_e32 v16, s22                                 // 000000009214: 7E200C16
	v_dual_mov_b32 v7, v5 :: v_dual_mov_b32 v6, v4             // 000000009218: CA100105 07060104
	v_dual_mov_b32 v9, v1 :: v_dual_mov_b32 v8, v0             // 000000009220: CA100101 09080100
	s_mov_b32 s25, 0                                           // 000000009228: BE990080
	s_waitcnt lgkmcnt(0)                                       // 00000000922C: BF89FC07
	s_and_b32 s24, s1, 0xffff                                  // 000000009230: 8B18FF01 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009238: BF870009
	s_lshl_b32 s26, s24, 2                                     // 00000000923C: 841A8218
	s_branch 22                                                // 000000009240: BFA00016 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x19c>
	s_or_b32 exec_lo, exec_lo, s14                             // 000000009244: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009248: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 00000000924C: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009250: BF870009
	s_or_b32 exec_lo, exec_lo, s1                              // 000000009254: 8C7E017E
	v_add_co_u32 v8, vcc_lo, v8, s24                           // 000000009258: D7006A08 00003108
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000009260: BF870191
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000009264: D5207C09 01AA1280
	v_add_f32_e32 v3, v3, v10                                  // 00000000926C: 06061503
	v_add_co_u32 v6, s1, v6, s26                               // 000000009270: D7000106 00003506
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_4)// 000000009278: BF870223
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[8:9]                  // 00000000927C: 7CA6100A
	v_add_co_ci_u32_e64 v7, null, 0, v7, s1                    // 000000009280: D5207C07 00060E80
	v_fmac_f32_e32 v14, v3, v16                                // 000000009288: 561C2103
	s_or_b32 s25, vcc_lo, s25                                  // 00000000928C: 8C19196A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009290: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s25                       // 000000009294: 917E197E
	s_cbranch_execz 362                                        // 000000009298: BFA5016A <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x744>
	v_or_b32_e32 v3, s9, v9                                    // 00000000929C: 38061209
	s_mov_b32 s1, exec_lo                                      // 0000000092A0: BE81007E
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000092A4: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 0000000092A8: 7DBA0480
	s_xor_b32 s27, exec_lo, s1                                 // 0000000092AC: 8D1B017E
	s_cbranch_execz 175                                        // 0000000092B0: BFA500AF <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x470>
	s_add_u32 s14, s8, s12                                     // 0000000092B4: 800E0C08
	s_mov_b32 s13, s12                                         // 0000000092B8: BE8D000C
	s_addc_u32 s15, s9, s12                                    // 0000000092BC: 820F0C09
	v_ashrrev_i32_e32 v19, 31, v9                              // 0000000092C0: 3426129F
	s_xor_b64 s[14:15], s[14:15], s[12:13]                     // 0000000092C4: 8D8E0C0E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 0000000092C8: BF870159
	v_cvt_f32_u32_e32 v3, s14                                  // 0000000092CC: 7E060C0E
	v_cvt_f32_u32_e32 v10, s15                                 // 0000000092D0: 7E140C0F
	s_sub_u32 s1, 0, s14                                       // 0000000092D4: 80810E80
	s_subb_u32 s29, 0, s15                                     // 0000000092D8: 829D0F80
	v_add_co_u32 v11, vcc_lo, v8, v19                          // 0000000092DC: D7006A0B 00022708
	v_fmac_f32_e32 v3, 0x4f800000, v10                         // 0000000092E4: 560614FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000092EC: BF870112
	v_xor_b32_e32 v20, v11, v19                                // 0000000092F0: 3A28270B
	v_rcp_f32_e32 v3, v3                                       // 0000000092F4: 7E065503
	s_waitcnt_depctr 0xfff                                     // 0000000092F8: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 0000000092FC: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009304: BF870091
	v_mul_f32_e32 v10, 0x2f800000, v3                          // 000000009308: 101406FF 2F800000
	v_trunc_f32_e32 v10, v10                                   // 000000009310: 7E14430A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009314: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v10                         // 000000009318: 560614FF CF800000
	v_cvt_u32_f32_e32 v10, v10                                 // 000000009320: 7E140F0A
	v_cvt_u32_f32_e32 v3, v3                                   // 000000009324: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009328: BF870112
	v_readfirstlane_b32 s13, v10                               // 00000000932C: 7E1A050A
	v_readfirstlane_b32 s28, v3                                // 000000009330: 7E380503
	s_mul_i32 s30, s1, s13                                     // 000000009334: 961E0D01
	v_add_co_ci_u32_e64 v3, null, v9, v19, vcc_lo              // 000000009338: D5207C03 01AA2709
	s_mul_hi_u32 s33, s1, s28                                  // 000000009340: 96A11C01
	s_mul_i32 s31, s29, s28                                    // 000000009344: 961F1C1D
	s_add_i32 s30, s33, s30                                    // 000000009348: 811E1E21
	s_mul_i32 s34, s1, s28                                     // 00000000934C: 96221C01
	s_add_i32 s30, s30, s31                                    // 000000009350: 811E1F1E
	s_mul_hi_u32 s33, s28, s34                                 // 000000009354: 96A1221C
	s_mul_i32 s36, s28, s30                                    // 000000009358: 96241E1C
	s_mul_hi_u32 s35, s13, s34                                 // 00000000935C: 96A3220D
	s_mul_i32 s31, s13, s34                                    // 000000009360: 961F220D
	s_mul_hi_u32 s34, s28, s30                                 // 000000009364: 96A21E1C
	s_add_u32 s33, s33, s36                                    // 000000009368: 80212421
	s_addc_u32 s34, 0, s34                                     // 00000000936C: 82222280
	s_mul_hi_u32 s37, s13, s30                                 // 000000009370: 96A51E0D
	s_add_u32 s31, s33, s31                                    // 000000009374: 801F1F21
	s_mul_i32 s30, s13, s30                                    // 000000009378: 961E1E0D
	s_addc_u32 s31, s34, s35                                   // 00000000937C: 821F2322
	s_addc_u32 s33, s37, 0                                     // 000000009380: 82218025
	s_add_u32 s30, s31, s30                                    // 000000009384: 801E1E1F
	s_addc_u32 s31, 0, s33                                     // 000000009388: 821F2180
	s_add_u32 s28, s28, s30                                    // 00000000938C: 801C1E1C
	s_cselect_b32 s30, -1, 0                                   // 000000009390: 981E80C1
	s_mul_hi_u32 s33, s1, s28                                  // 000000009394: 96A11C01
	s_cmp_lg_u32 s30, 0                                        // 000000009398: BF07801E
	s_mul_i32 s30, s1, s28                                     // 00000000939C: 961E1C01
	s_addc_u32 s13, s13, s31                                   // 0000000093A0: 820D1F0D
	s_mul_i32 s29, s29, s28                                    // 0000000093A4: 961D1C1D
	s_mul_i32 s1, s1, s13                                      // 0000000093A8: 96010D01
	s_mul_hi_u32 s31, s28, s30                                 // 0000000093AC: 969F1E1C
	s_add_i32 s1, s33, s1                                      // 0000000093B0: 81010121
	s_mul_hi_u32 s33, s13, s30                                 // 0000000093B4: 96A11E0D
	s_add_i32 s1, s1, s29                                      // 0000000093B8: 81011D01
	s_mul_i32 s29, s13, s30                                    // 0000000093BC: 961D1E0D
	s_mul_i32 s35, s28, s1                                     // 0000000093C0: 9623011C
	s_mul_hi_u32 s34, s28, s1                                  // 0000000093C4: 96A2011C
	s_add_u32 s31, s31, s35                                    // 0000000093C8: 801F231F
	s_addc_u32 s34, 0, s34                                     // 0000000093CC: 82222280
	s_mul_hi_u32 s30, s13, s1                                  // 0000000093D0: 969E010D
	s_add_u32 s29, s31, s29                                    // 0000000093D4: 801D1D1F
	s_mul_i32 s1, s13, s1                                      // 0000000093D8: 9601010D
	s_addc_u32 s29, s34, s33                                   // 0000000093DC: 821D2122
	s_addc_u32 s30, s30, 0                                     // 0000000093E0: 821E801E
	s_add_u32 s1, s29, s1                                      // 0000000093E4: 8001011D
	s_addc_u32 s29, 0, s30                                     // 0000000093E8: 821D1E80
	s_add_u32 s1, s28, s1                                      // 0000000093EC: 8001011C
	s_cselect_b32 s28, -1, 0                                   // 0000000093F0: 981C80C1
	v_xor_b32_e32 v3, v3, v19                                  // 0000000093F4: 3A062703
	s_cmp_lg_u32 s28, 0                                        // 0000000093F8: BF07801C
	v_mul_hi_u32 v21, v20, s1                                  // 0000000093FC: D72D0015 00000314
	s_addc_u32 s13, s13, s29                                   // 000000009404: 820D1D0D
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000009408: BF8701B9
	v_mad_u64_u32 v[10:11], null, v20, s13, 0                  // 00000000940C: D6FE7C0A 02001B14
	v_mad_u64_u32 v[12:13], null, v3, s1, 0                    // 000000009414: D6FE7C0C 02000303
	v_mad_u64_u32 v[17:18], null, v3, s13, 0                   // 00000000941C: D6FE7C11 02001B03
	v_add_co_u32 v10, vcc_lo, v21, v10                         // 000000009424: D7006A0A 00021515
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000942C: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo              // 000000009430: D5207C0B 01AA1680
	v_add_co_u32 v10, vcc_lo, v10, v12                         // 000000009438: D7006A0A 0002190A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009440: BF870122
	v_add_co_ci_u32_e32 v10, vcc_lo, v11, v13, vcc_lo          // 000000009444: 40141B0B
	v_add_co_ci_u32_e32 v11, vcc_lo, 0, v18, vcc_lo            // 000000009448: 40162480
	v_add_co_u32 v12, vcc_lo, v10, v17                         // 00000000944C: D7006A0C 0002230A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009454: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v11, vcc_lo              // 000000009458: D5207C0D 01AA1680
	v_mul_lo_u32 v17, s15, v12                                 // 000000009460: D72C0011 0002180F
	v_mad_u64_u32 v[10:11], null, s14, v12, 0                  // 000000009468: D6FE7C0A 0202180E
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009470: BF870113
	v_mul_lo_u32 v18, s14, v13                                 // 000000009474: D72C0012 00021A0E
	v_sub_co_u32 v10, vcc_lo, v20, v10                         // 00000000947C: D7016A0A 00021514
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000009484: BF8700A2
	v_add3_u32 v11, v11, v18, v17                              // 000000009488: D655000B 0446250B
	v_add_co_u32 v18, s1, v12, 2                               // 000000009490: D7000112 0001050C
	v_add_co_ci_u32_e64 v20, null, 0, v13, s1                  // 000000009498: D5207C14 00061A80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000000094A0: BF8701B3
	v_sub_nc_u32_e32 v17, v3, v11                              // 0000000094A4: 4C221703
	v_sub_co_u32 v21, s1, v10, s14                             // 0000000094A8: D7010115 00001D0A
	v_sub_co_ci_u32_e64 v3, null, v3, v11, vcc_lo              // 0000000094B0: D5217C03 01AA1703
	v_subrev_co_ci_u32_e64 v17, null, s15, v17, vcc_lo         // 0000000094B8: D5227C11 01AA220F
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000094C0: BF870113
	v_cmp_le_u32_e32 vcc_lo, s14, v21                          // 0000000094C4: 7C962A0E
	v_subrev_co_ci_u32_e64 v17, null, 0, v17, s1               // 0000000094C8: D5227C11 00062280
	v_cndmask_b32_e64 v11, 0, -1, vcc_lo                       // 0000000094D0: D501000B 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 0000000094D8: BF870002
	v_cmp_le_u32_e32 vcc_lo, s15, v17                          // 0000000094DC: 7C96220F
	v_cndmask_b32_e64 v21, 0, -1, vcc_lo                       // 0000000094E0: D5010015 01A98280
	v_cmp_le_u32_e32 vcc_lo, s14, v10                          // 0000000094E8: 7C96140E
	v_cndmask_b32_e64 v10, 0, -1, vcc_lo                       // 0000000094EC: D501000A 01A98280
	v_cmp_le_u32_e32 vcc_lo, s15, v3                           // 0000000094F4: 7C96060F
	v_cndmask_b32_e64 v22, 0, -1, vcc_lo                       // 0000000094F8: D5010016 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s15, v17                          // 000000009500: 7C94220F
	v_cndmask_b32_e32 v11, v21, v11, vcc_lo                    // 000000009504: 02161715
	v_add_co_u32 v17, vcc_lo, v12, 1                           // 000000009508: D7006A11 0001030C
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000009510: BF8701D1
	v_add_co_ci_u32_e64 v21, null, 0, v13, vcc_lo              // 000000009514: D5207C15 01AA1A80
	v_cmp_eq_u32_e32 vcc_lo, s15, v3                           // 00000000951C: 7C94060F
	v_cndmask_b32_e32 v3, v22, v10, vcc_lo                     // 000000009520: 02061516
	v_cmp_ne_u32_e32 vcc_lo, 0, v11                            // 000000009524: 7C9A1680
	v_xor_b32_e32 v11, s12, v19                                // 000000009528: 3A16260C
	v_cmp_ne_u32_e64 s1, 0, v3                                 // 00000000952C: D44D0001 00020680
	v_cndmask_b32_e32 v3, v17, v18, vcc_lo                     // 000000009534: 02062511
	v_cndmask_b32_e32 v10, v21, v20, vcc_lo                    // 000000009538: 02142915
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000953C: BF870112
	v_cndmask_b32_e64 v3, v12, v3, s1                          // 000000009540: D5010003 0006070C
	v_cndmask_b32_e64 v10, v13, v10, s1                        // 000000009548: D501000A 0006150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009550: BF870112
	v_xor_b32_e32 v3, v3, v11                                  // 000000009554: 3A061703
	v_xor_b32_e32 v12, v10, v11                                // 000000009558: 3A18170A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000955C: BF870092
	v_sub_co_u32 v10, vcc_lo, v3, v11                          // 000000009560: D7016A0A 00021703
	v_sub_co_ci_u32_e64 v11, null, v12, v11, vcc_lo            // 000000009568: D5217C0B 01AA170C
	s_and_not1_saveexec_b32 s1, s27                            // 000000009570: BE81301B
	s_cbranch_execz 18                                         // 000000009574: BFA50012 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x4c0>
	v_mul_hi_u32 v3, v8, v15                                   // 000000009578: D72D0003 00021F08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009580: BF870091
	v_mul_lo_u32 v10, v3, s8                                   // 000000009584: D72C000A 00001103
	v_sub_nc_u32_e32 v10, v8, v10                              // 00000000958C: 4C141508
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009590: BF870121
	v_subrev_nc_u32_e32 v12, s8, v10                           // 000000009594: 4E181408
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 000000009598: 7C961408
	v_dual_cndmask_b32 v10, v10, v12 :: v_dual_add_nc_u32 v11, 1, v3// 00000000959C: CA60190A 0A0A0681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000095A4: BF870111
	v_cndmask_b32_e32 v3, v3, v11, vcc_lo                      // 0000000095A8: 02061703
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 0000000095AC: 7C961408
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000095B0: BF870092
	v_add_nc_u32_e32 v11, 1, v3                                // 0000000095B4: 4A160681
	v_dual_cndmask_b32 v10, v3, v11 :: v_dual_mov_b32 v11, v2  // 0000000095B8: CA501703 0A0A0102
	s_or_b32 exec_lo, exec_lo, s1                              // 0000000095C0: 8C7E017E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000095C4: BF870121
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 0000000095C8: D73C000A 00021482
	v_mov_b32_e32 v17, 0                                       // 0000000095D0: 7E220280
	v_add_co_u32 v12, vcc_lo, s20, v10                         // 0000000095D4: D7006A0C 00021414
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 0000000095DC: BF8700C1
	v_add_co_ci_u32_e64 v13, null, s21, v11, vcc_lo            // 0000000095E0: D5207C0D 01AA1615
	global_load_b32 v12, v[12:13], off                         // 0000000095E8: DC520000 0C7C000C
	s_waitcnt vmcnt(0)                                         // 0000000095F0: BF8903F7
	v_ashrrev_i32_e32 v13, 31, v12                             // 0000000095F4: 341A189F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[12:13]                      // 0000000095F8: 7CA218C1
	v_cmp_gt_i64_e64 s1, s[4:5], v[12:13]                      // 0000000095FC: D4540001 00021804
	s_and_b32 s13, vcc_lo, s1                                  // 000000009604: 8B0D016A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009608: BF870009
	s_and_saveexec_b32 s1, s13                                 // 00000000960C: BE81200D
	s_cbranch_execnz 9                                         // 000000009610: BFA60009 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x538>
	s_or_b32 exec_lo, exec_lo, s1                              // 000000009614: 8C7E017E
	v_lshlrev_b32_e32 v3, 16, v17                              // 000000009618: 30062290
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000961C: 916A137E
	s_cbranch_vccz 29                                          // 000000009620: BFA3001D <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x598>
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 000000009624: 916A137E
	s_cbranch_vccz 84                                          // 000000009628: BFA30054 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x67c>
	v_and_b32_e32 v10, 0xffff0000, v17                         // 00000000962C: 361422FF FFFF0000
	s_branch 65288                                             // 000000009634: BFA0FF08 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x158>
	v_lshlrev_b64 v[12:13], 2, v[12:13]                        // 000000009638: D73C000C 00021882
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009640: BF870091
	v_sub_co_u32 v3, vcc_lo, v12, v10                          // 000000009644: D7016A03 0002150C
	v_sub_co_ci_u32_e64 v10, null, v13, v11, vcc_lo            // 00000000964C: D5217C0A 01AA170D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009654: BF870112
	v_mul_lo_u32 v13, s9, v3                                   // 000000009658: D72C000D 00020609
	v_mul_lo_u32 v12, s8, v10                                  // 000000009660: D72C000C 00021408
	v_mad_u64_u32 v[10:11], null, s8, v3, v[6:7]               // 000000009668: D6FE7C0A 041A0608
	s_delay_alu instid0(VALU_DEP_1)                            // 000000009670: BF870001
	v_add3_u32 v11, v13, v11, v12                              // 000000009674: D655000B 0432170D
	global_load_b32 v17, v[10:11], off                         // 00000000967C: DC520000 117C000A
	s_or_b32 exec_lo, exec_lo, s1                              // 000000009684: 8C7E017E
	s_waitcnt vmcnt(0)                                         // 000000009688: BF8903F7
	v_lshlrev_b32_e32 v3, 16, v17                              // 00000000968C: 30062290
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 000000009690: 916A137E
	s_cbranch_vccnz 65507                                      // 000000009694: BFA4FFE3 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x524>
	v_bfe_u32 v10, v17, 10, 5                                  // 000000009698: D610000A 02151511
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000096A0: BF870122
	v_and_b32_e32 v3, 0x80000000, v3                           // 0000000096A4: 360606FF 80000000
	s_mov_b32 s1, exec_lo                                      // 0000000096AC: BE81007E
	v_cmpx_lt_i32_e32 30, v10                                  // 0000000096B0: 7D82149E
	s_xor_b32 s1, exec_lo, s1                                  // 0000000096B4: 8D01017E
	v_lshlrev_b32_e32 v10, 13, v17                             // 0000000096B8: 3014228D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000096BC: BF870091
	v_and_b32_e32 v10, 0x7fe000, v10                           // 0000000096C0: 361414FF 007FE000
	v_or3_b32 v3, v10, v3, 0x7f800000                          // 0000000096C8: D6580003 03FE070A 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 0000000096D4: BE813001
	s_cbranch_execz 36                                         // 0000000096D8: BFA50024 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x66c>
	v_and_b32_e32 v11, 0x3ff, v17                              // 0000000096DC: 361622FF 000003FF
	s_mov_b32 s13, exec_lo                                     // 0000000096E4: BE8D007E
	v_cmpx_ne_u32_e32 0, v10                                   // 0000000096E8: 7D9A1480
	s_xor_b32 s13, exec_lo, s13                                // 0000000096EC: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000096F0: BF870092
	v_lshlrev_b32_e32 v11, 13, v11                             // 0000000096F4: 3016168D
	v_lshl_or_b32 v10, v10, 23, v11                            // 0000000096F8: D656000A 042D2F0A
	s_delay_alu instid0(VALU_DEP_1)                            // 000000009700: BF870001
	v_add3_u32 v3, v10, v3, 0x38000000                         // 000000009704: D6550003 03FE070A 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 000000009710: BE8D300D
	s_cbranch_execz 19                                         // 000000009714: BFA50013 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x664>
	s_mov_b32 s14, exec_lo                                     // 000000009718: BE8E007E
	v_cmpx_ne_u32_e32 0, v11                                   // 00000000971C: 7D9A1680
	s_cbranch_execz 15                                         // 000000009720: BFA5000F <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x660>
	v_clz_i32_u32_e32 v10, v11                                 // 000000009724: 7E14730B
	v_or_b32_e32 v3, 0x43000000, v3                            // 000000009728: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009730: BF870122
	v_xor_b32_e32 v11, 31, v10                                 // 000000009734: 3A16149F
	v_lshlrev_b32_e32 v10, 23, v10                             // 000000009738: 30141497
	v_sub_nc_u32_e32 v11, 9, v11                               // 00000000973C: 4C161689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009740: BF870112
	v_sub_nc_u32_e32 v3, v3, v10                               // 000000009744: 4C061503
	v_lshlrev_b32_e32 v11, v11, v17                            // 000000009748: 3016230B
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000974C: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 000000009750: 3016168E
	v_and_or_b32 v3, 0x7fc000, v11, v3                         // 000000009754: D6570003 040E16FF 007FC000
	s_or_b32 exec_lo, exec_lo, s14                             // 000000009760: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009764: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 000000009768: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000976C: BF870499
	s_or_b32 exec_lo, exec_lo, s1                              // 000000009770: 8C7E017E
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 000000009774: 916A137E
	s_cbranch_vccnz 65452                                      // 000000009778: BFA4FFAC <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x52c>
	v_bfe_u32 v12, v17, 26, 5                                  // 00000000977C: D610000C 02153511
	v_and_b32_e32 v10, 0x80000000, v17                         // 000000009784: 361422FF 80000000
	v_mov_b16_e32 v11.h, 0                                     // 00000000978C: 7F163880
	v_mov_b16_e32 v11.l, v17.h                                 // 000000009790: 7E163991
	s_mov_b32 s1, exec_lo                                      // 000000009794: BE81007E
	v_cmpx_lt_i32_e32 30, v12                                  // 000000009798: 7D82189E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000979C: 8D01017E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000097A0: BF870092
	v_lshlrev_b32_e32 v11, 13, v11                             // 0000000097A4: 3016168D
	v_or3_b32 v10, v11, v10, 0x7f800000                        // 0000000097A8: D658000A 03FE150B 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 0000000097B4: BE813001
	s_cbranch_execz 65189                                      // 0000000097B8: BFA5FEA5 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x150>
	v_bfe_u32 v13, v17, 16, 10                                 // 0000000097BC: D610000D 02292111
	s_mov_b32 s13, exec_lo                                     // 0000000097C4: BE8D007E
	v_cmpx_ne_u32_e32 0, v12                                   // 0000000097C8: 7D9A1880
	s_xor_b32 s13, exec_lo, s13                                // 0000000097CC: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000097D0: BF870092
	v_lshlrev_b32_e32 v11, 13, v13                             // 0000000097D4: 30161A8D
	v_lshl_or_b32 v11, v12, 23, v11                            // 0000000097D8: D656000B 042D2F0C
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000097E0: BF870001
	v_add3_u32 v10, v11, v10, 0x38000000                       // 0000000097E4: D655000A 03FE150B 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 0000000097F0: BE8D300D
	s_cbranch_execz 65172                                      // 0000000097F4: BFA5FE94 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x148>
	s_mov_b32 s14, exec_lo                                     // 0000000097F8: BE8E007E
	v_cmpx_ne_u32_e32 0, v13                                   // 0000000097FC: 7D9A1A80
	s_cbranch_execz 65168                                      // 000000009800: BFA5FE90 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x144>
	v_clz_i32_u32_e32 v12, v13                                 // 000000009804: 7E18730D
	v_or_b32_e32 v10, 0x43000000, v10                          // 000000009808: 381414FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009810: BF870122
	v_xor_b32_e32 v13, 31, v12                                 // 000000009814: 3A1A189F
	v_lshlrev_b32_e32 v12, 23, v12                             // 000000009818: 30181897
	v_sub_nc_u32_e32 v13, 9, v13                               // 00000000981C: 4C1A1A89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009820: BF870112
	v_sub_nc_u32_e32 v10, v10, v12                             // 000000009824: 4C14190A
	v_lshlrev_b32_e32 v11, v13, v11                            // 000000009828: 3016170D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000982C: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 000000009830: 3016168E
	v_and_or_b32 v10, 0x7fc000, v11, v10                       // 000000009834: D657000A 042A16FF 007FC000
	s_branch 65152                                             // 000000009840: BFA0FE80 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x144>
	s_or_b32 exec_lo, exec_lo, s25                             // 000000009844: 8C7E197E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009848: BF870009
	s_or_b32 exec_lo, exec_lo, s23                             // 00000000984C: 8C7E177E
	s_cmp_lg_u32 s22, s18                                      // 000000009850: BF071216
	s_cbranch_scc1 65130                                       // 000000009854: BFA2FE6A <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x100>
	v_lshl_add_u32 v1, v0, 2, 0                                // 000000009858: D6460001 02010500
	ds_store_b32 v1, v14                                       // 000000009860: D8340000 00000E01
	s_waitcnt lgkmcnt(0)                                       // 000000009868: BF89FC07
	s_barrier                                                  // 00000000986C: BFBD0000
	buffer_gl0_inv                                             // 000000009870: E0AC0000 00000000
	s_load_b32 s0, s[6:7], 0xc                                 // 000000009878: F4000003 F800000C
	s_waitcnt lgkmcnt(0)                                       // 000000009880: BF89FC07
	s_and_b32 s0, s0, 0xffff                                   // 000000009884: 8B00FF00 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000988C: BF870009
	s_cmp_lt_u32 s0, 2                                         // 000000009890: BF0A8200
	s_cbranch_scc1 34                                          // 000000009894: BFA20022 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x820>
	s_lshr_b32 s0, s0, 1                                       // 000000009898: 85008100
	s_branch 17                                                // 00000000989C: BFA00011 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x7e4>
	s_nop 0                                                    // 0000000098A0: BF800000
	s_nop 0                                                    // 0000000098A4: BF800000
	s_nop 0                                                    // 0000000098A8: BF800000
	s_nop 0                                                    // 0000000098AC: BF800000
	s_nop 0                                                    // 0000000098B0: BF800000
	s_nop 0                                                    // 0000000098B4: BF800000
	s_nop 0                                                    // 0000000098B8: BF800000
	s_nop 0                                                    // 0000000098BC: BF800000
	s_or_b32 exec_lo, exec_lo, s1                              // 0000000098C0: 8C7E017E
	s_lshr_b32 s1, s0, 1                                       // 0000000098C4: 85018100
	s_cmp_lt_u32 s0, 2                                         // 0000000098C8: BF0A8200
	s_mov_b32 s0, s1                                           // 0000000098CC: BE800001
	s_waitcnt lgkmcnt(0)                                       // 0000000098D0: BF89FC07
	s_barrier                                                  // 0000000098D4: BFBD0000
	buffer_gl0_inv                                             // 0000000098D8: E0AC0000 00000000
	s_cbranch_scc1 15                                          // 0000000098E0: BFA2000F <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x820>
	s_mov_b32 s1, exec_lo                                      // 0000000098E4: BE81007E
	v_cmpx_gt_u32_e64 s0, v0                                   // 0000000098E8: D4CC007E 00020000
	s_cbranch_execz 65523                                      // 0000000098F0: BFA5FFF3 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x7c0>
	v_lshl_add_u32 v2, s0, 2, v1                               // 0000000098F4: D6460002 04050400
	ds_load_b32 v2, v2                                         // 0000000098FC: D8D80000 02000002
	ds_load_b32 v3, v1                                         // 000000009904: D8D80000 03000001
	s_waitcnt lgkmcnt(0)                                       // 00000000990C: BF89FC07
	v_add_f32_e32 v2, v2, v3                                   // 000000009910: 06040702
	ds_store_b32 v1, v2                                        // 000000009914: D8340000 00000201
	s_branch 65512                                             // 00000000991C: BFA0FFE8 <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x7c0>
	s_mov_b32 s0, exec_lo                                      // 000000009920: BE80007E
	v_cmpx_eq_u32_e32 0, v0                                    // 000000009924: 7D940080
	s_cbranch_execz 10                                         // 000000009928: BFA5000A <_ZN12_GLOBAL__N_123fused_global_sum_kernelEPKjPKiPfllllii+0x854>
	v_mov_b32_e32 v0, 0                                        // 00000000992C: 7E000280
	s_lshl_b64 s[0:1], s[2:3], 2                               // 000000009930: 84808202
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009934: BF870009
	s_add_u32 s0, s16, s0                                      // 000000009938: 80000010
	s_addc_u32 s1, s17, s1                                     // 00000000993C: 82010111
	ds_load_b32 v1, v0                                         // 000000009940: D8D80000 01000000
	s_waitcnt lgkmcnt(0)                                       // 000000009948: BF89FC07
	global_store_b32 v0, v1, s[0:1]                            // 00000000994C: DC6A0000 00000100
	s_endpgm                                                   // 000000009954: BFB00000
		...

0000000000009a00 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii>:
	s_mov_b32 s12, s15                                         // 000000009A00: BE8C000F
	s_clause 0x1                                               // 000000009A04: BF850001
	s_load_b256 s[4:11], s[0:1], 0x18                          // 000000009A08: F40C0100 F8000018
	s_load_b64 s[14:15], s[0:1], 0x10                          // 000000009A10: F4040380 F8000010
	v_mov_b32_e32 v2, 0                                        // 000000009A18: 7E040280
	s_mov_b32 s13, 0                                           // 000000009A1C: BE8D0080
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000009A20: BF8700A1
	v_mov_b32_e32 v1, v2                                       // 000000009A24: 7E020302
	s_waitcnt lgkmcnt(0)                                       // 000000009A28: BF89FC07
	v_cmp_gt_i64_e64 s2, s[10:11], v[0:1]                      // 000000009A2C: D4540002 0002000A
	s_and_saveexec_b32 s18, s2                                 // 000000009A34: BE922002
	s_cbranch_execz 302                                        // 000000009A38: BFA5012E <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x4f4>
	v_cvt_f32_u32_e32 v3, s8                                   // 000000009A3C: 7E060C08
	s_load_b128 s[24:27], s[0:1], null                         // 000000009A40: F4080600 F8000000
	v_lshlrev_b32_e32 v5, 2, v0                                // 000000009A48: 300A0082
	s_mul_i32 s3, s7, s12                                      // 000000009A4C: 96030C07
	s_mul_hi_u32 s7, s6, s12                                   // 000000009A50: 96870C06
	v_rcp_iflag_f32_e32 v3, v3                                 // 000000009A54: 7E065703
	s_mul_i32 s6, s6, s12                                      // 000000009A58: 96060C06
	s_add_i32 s7, s7, s3                                       // 000000009A5C: 81070307
	s_load_b32 s3, s[0:1], 0x4c                                // 000000009A60: F40000C0 F800004C
	s_lshl_b64 s[6:7], s[6:7], 2                               // 000000009A68: 84868206
	s_mov_b32 s23, s13                                         // 000000009A6C: BE97000D
	s_waitcnt_depctr 0xfff                                     // 000000009A70: BF880FFF
	v_dual_mul_f32 v3, 0x4f7ffffe, v3 :: v_dual_add_nc_u32 v12, 0, v5// 000000009A74: C8E006FF 030C0A80 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 000000009A80: BF8704D1
	v_cvt_u32_f32_e32 v3, v3                                   // 000000009A84: 7E060F03
	s_waitcnt lgkmcnt(0)                                       // 000000009A88: BF89FC07
	s_add_u32 s19, s26, s6                                     // 000000009A8C: 8013061A
	s_addc_u32 s20, s27, s7                                    // 000000009A90: 8214071B
	s_sub_i32 s6, 0, s8                                        // 000000009A94: 81860880
	v_mul_lo_u32 v4, s6, v3                                    // 000000009A98: D72C0004 00020606
	s_and_b32 s21, s3, 0xffff                                  // 000000009AA0: 8B15FF03 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009AA8: BF870099
	s_lshl_b32 s22, s21, 2                                     // 000000009AAC: 84168215
	v_mul_hi_u32 v6, v3, v4                                    // 000000009AB0: D72D0006 00020903
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000009AB8: BF8700B1
	v_add_nc_u32_e32 v13, v3, v6                               // 000000009ABC: 4A1A0D03
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 000000009AC0: CA100101 07060100
	v_add_co_u32 v4, s6, s24, v5                               // 000000009AC8: D7000604 00020A18
	v_add_co_ci_u32_e64 v5, null, s25, 0, s6                   // 000000009AD0: D5207C05 00190019
	s_ashr_i32 s6, s9, 31                                      // 000000009AD8: 86069F09
	s_branch 19                                                // 000000009ADC: BFA00013 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x12c>
	s_or_b32 exec_lo, exec_lo, s3                              // 000000009AE0: 8C7E037E
	v_add_co_u32 v6, vcc_lo, v6, s21                           // 000000009AE4: D7006A06 00002B06
	s_delay_alu instid0(VALU_DEP_1)                            // 000000009AEC: BF870001
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 000000009AF0: D5207C07 01AA0E80
	v_add_co_u32 v4, s3, v4, s22                               // 000000009AF8: D7000304 00002D04
	s_waitcnt vmcnt(0)                                         // 000000009B00: BF8903F7
	ds_store_b32 v12, v3                                       // 000000009B04: D8340000 0000030C
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 000000009B0C: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s3                    // 000000009B10: D5207C05 000E0A80
	v_add_nc_u32_e32 v12, s22, v12                             // 000000009B18: 4A181816
	s_or_b32 s23, vcc_lo, s23                                  // 000000009B1C: 8C17176A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009B20: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s23                       // 000000009B24: 917E177E
	s_cbranch_execz 242                                        // 000000009B28: BFA500F2 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x4f4>
	v_or_b32_e32 v3, s9, v7                                    // 000000009B2C: 38060E09
	s_mov_b32 s3, exec_lo                                      // 000000009B30: BE83007E
	s_delay_alu instid0(VALU_DEP_1)                            // 000000009B34: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000009B38: 7DBA0480
	s_xor_b32 s24, exec_lo, s3                                 // 000000009B3C: 8D18037E
	s_cbranch_execz 175                                        // 000000009B40: BFA500AF <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x400>
	s_add_u32 s16, s8, s6                                      // 000000009B44: 80100608
	s_mov_b32 s7, s6                                           // 000000009B48: BE870006
	s_addc_u32 s17, s9, s6                                     // 000000009B4C: 82110609
	v_ashrrev_i32_e32 v16, 31, v7                              // 000000009B50: 34200E9F
	s_xor_b64 s[16:17], s[16:17], s[6:7]                       // 000000009B54: 8D900610
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000009B58: BF870159
	v_cvt_f32_u32_e32 v3, s16                                  // 000000009B5C: 7E060C10
	v_cvt_f32_u32_e32 v8, s17                                  // 000000009B60: 7E100C11
	s_sub_u32 s3, 0, s16                                       // 000000009B64: 80831080
	s_subb_u32 s26, 0, s17                                     // 000000009B68: 829A1180
	v_add_co_u32 v9, vcc_lo, v6, v16                           // 000000009B6C: D7006A09 00022106
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 000000009B74: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009B7C: BF870112
	v_xor_b32_e32 v17, v9, v16                                 // 000000009B80: 3A222109
	v_rcp_f32_e32 v3, v3                                       // 000000009B84: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000009B88: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000009B8C: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009B94: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 000000009B98: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 000000009BA0: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009BA4: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 000000009BA8: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 000000009BB0: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 000000009BB4: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009BB8: BF870112
	v_readfirstlane_b32 s7, v8                                 // 000000009BBC: 7E0E0508
	v_readfirstlane_b32 s25, v3                                // 000000009BC0: 7E320503
	s_mul_i32 s27, s3, s7                                      // 000000009BC4: 961B0703
	v_add_co_ci_u32_e64 v3, null, v7, v16, vcc_lo              // 000000009BC8: D5207C03 01AA2107
	s_mul_hi_u32 s29, s3, s25                                  // 000000009BD0: 969D1903
	s_mul_i32 s28, s26, s25                                    // 000000009BD4: 961C191A
	s_add_i32 s27, s29, s27                                    // 000000009BD8: 811B1B1D
	s_mul_i32 s30, s3, s25                                     // 000000009BDC: 961E1903
	s_add_i32 s27, s27, s28                                    // 000000009BE0: 811B1C1B
	s_mul_hi_u32 s29, s25, s30                                 // 000000009BE4: 969D1E19
	s_mul_i32 s33, s25, s27                                    // 000000009BE8: 96211B19
	s_mul_hi_u32 s31, s7, s30                                  // 000000009BEC: 969F1E07
	s_mul_i32 s28, s7, s30                                     // 000000009BF0: 961C1E07
	s_mul_hi_u32 s30, s25, s27                                 // 000000009BF4: 969E1B19
	s_add_u32 s29, s29, s33                                    // 000000009BF8: 801D211D
	s_addc_u32 s30, 0, s30                                     // 000000009BFC: 821E1E80
	s_mul_hi_u32 s34, s7, s27                                  // 000000009C00: 96A21B07
	s_add_u32 s28, s29, s28                                    // 000000009C04: 801C1C1D
	s_mul_i32 s27, s7, s27                                     // 000000009C08: 961B1B07
	s_addc_u32 s28, s30, s31                                   // 000000009C0C: 821C1F1E
	s_addc_u32 s29, s34, 0                                     // 000000009C10: 821D8022
	s_add_u32 s27, s28, s27                                    // 000000009C14: 801B1B1C
	s_addc_u32 s28, 0, s29                                     // 000000009C18: 821C1D80
	s_add_u32 s25, s25, s27                                    // 000000009C1C: 80191B19
	s_cselect_b32 s27, -1, 0                                   // 000000009C20: 981B80C1
	s_mul_hi_u32 s29, s3, s25                                  // 000000009C24: 969D1903
	s_cmp_lg_u32 s27, 0                                        // 000000009C28: BF07801B
	s_mul_i32 s27, s3, s25                                     // 000000009C2C: 961B1903
	s_addc_u32 s7, s7, s28                                     // 000000009C30: 82071C07
	s_mul_i32 s26, s26, s25                                    // 000000009C34: 961A191A
	s_mul_i32 s3, s3, s7                                       // 000000009C38: 96030703
	s_mul_hi_u32 s28, s25, s27                                 // 000000009C3C: 969C1B19
	s_add_i32 s3, s29, s3                                      // 000000009C40: 8103031D
	s_mul_hi_u32 s29, s7, s27                                  // 000000009C44: 969D1B07
	s_add_i32 s3, s3, s26                                      // 000000009C48: 81031A03
	s_mul_i32 s26, s7, s27                                     // 000000009C4C: 961A1B07
	s_mul_i32 s31, s25, s3                                     // 000000009C50: 961F0319
	s_mul_hi_u32 s30, s25, s3                                  // 000000009C54: 969E0319
	s_add_u32 s28, s28, s31                                    // 000000009C58: 801C1F1C
	s_addc_u32 s30, 0, s30                                     // 000000009C5C: 821E1E80
	s_mul_hi_u32 s27, s7, s3                                   // 000000009C60: 969B0307
	s_add_u32 s26, s28, s26                                    // 000000009C64: 801A1A1C
	s_mul_i32 s3, s7, s3                                       // 000000009C68: 96030307
	s_addc_u32 s26, s30, s29                                   // 000000009C6C: 821A1D1E
	s_addc_u32 s27, s27, 0                                     // 000000009C70: 821B801B
	s_add_u32 s3, s26, s3                                      // 000000009C74: 8003031A
	s_addc_u32 s26, 0, s27                                     // 000000009C78: 821A1B80
	s_add_u32 s3, s25, s3                                      // 000000009C7C: 80030319
	s_cselect_b32 s25, -1, 0                                   // 000000009C80: 981980C1
	v_xor_b32_e32 v3, v3, v16                                  // 000000009C84: 3A062103
	s_cmp_lg_u32 s25, 0                                        // 000000009C88: BF078019
	v_mul_hi_u32 v18, v17, s3                                  // 000000009C8C: D72D0012 00000711
	s_addc_u32 s7, s7, s26                                     // 000000009C94: 82071A07
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000009C98: BF8701B9
	v_mad_u64_u32 v[8:9], null, v17, s7, 0                     // 000000009C9C: D6FE7C08 02000F11
	v_mad_u64_u32 v[10:11], null, v3, s3, 0                    // 000000009CA4: D6FE7C0A 02000703
	v_mad_u64_u32 v[14:15], null, v3, s7, 0                    // 000000009CAC: D6FE7C0E 02000F03
	v_add_co_u32 v8, vcc_lo, v18, v8                           // 000000009CB4: D7006A08 00021112
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009CBC: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000009CC0: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 000000009CC8: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009CD0: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 000000009CD4: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v15, vcc_lo             // 000000009CD8: 40121E80
	v_add_co_u32 v10, vcc_lo, v8, v14                          // 000000009CDC: D7006A0A 00021D08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009CE4: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 000000009CE8: D5207C0B 01AA1280
	v_mul_lo_u32 v14, s17, v10                                 // 000000009CF0: D72C000E 00021411
	v_mad_u64_u32 v[8:9], null, s16, v10, 0                    // 000000009CF8: D6FE7C08 02021410
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009D00: BF870113
	v_mul_lo_u32 v15, s16, v11                                 // 000000009D04: D72C000F 00021610
	v_sub_co_u32 v8, vcc_lo, v17, v8                           // 000000009D0C: D7016A08 00021111
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000009D14: BF8700A2
	v_add3_u32 v9, v9, v15, v14                                // 000000009D18: D6550009 043A1F09
	v_add_co_u32 v15, s3, v10, 2                               // 000000009D20: D700030F 0001050A
	v_add_co_ci_u32_e64 v17, null, 0, v11, s3                  // 000000009D28: D5207C11 000E1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 000000009D30: BF8701B3
	v_sub_nc_u32_e32 v14, v3, v9                               // 000000009D34: 4C1C1303
	v_sub_co_u32 v18, s3, v8, s16                              // 000000009D38: D7010312 00002108
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 000000009D40: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v14, null, s17, v14, vcc_lo         // 000000009D48: D5227C0E 01AA1C11
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009D50: BF870113
	v_cmp_le_u32_e32 vcc_lo, s16, v18                          // 000000009D54: 7C962410
	v_subrev_co_ci_u32_e64 v14, null, 0, v14, s3               // 000000009D58: D5227C0E 000E1C80
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 000000009D60: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 000000009D68: BF870002
	v_cmp_le_u32_e32 vcc_lo, s17, v14                          // 000000009D6C: 7C961C11
	v_cndmask_b32_e64 v18, 0, -1, vcc_lo                       // 000000009D70: D5010012 01A98280
	v_cmp_le_u32_e32 vcc_lo, s16, v8                           // 000000009D78: 7C961010
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 000000009D7C: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s17, v3                           // 000000009D84: 7C960611
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 000000009D88: D5010013 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s17, v14                          // 000000009D90: 7C941C11
	v_cndmask_b32_e32 v9, v18, v9, vcc_lo                      // 000000009D94: 02121312
	v_add_co_u32 v14, vcc_lo, v10, 1                           // 000000009D98: D7006A0E 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 000000009DA0: BF8701D1
	v_add_co_ci_u32_e64 v18, null, 0, v11, vcc_lo              // 000000009DA4: D5207C12 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s17, v3                           // 000000009DAC: 7C940611
	v_cndmask_b32_e32 v3, v19, v8, vcc_lo                      // 000000009DB0: 02061113
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 000000009DB4: 7C9A1280
	v_xor_b32_e32 v9, s6, v16                                  // 000000009DB8: 3A122006
	v_cmp_ne_u32_e64 s3, 0, v3                                 // 000000009DBC: D44D0003 00020680
	v_cndmask_b32_e32 v3, v14, v15, vcc_lo                     // 000000009DC4: 02061F0E
	v_cndmask_b32_e32 v8, v18, v17, vcc_lo                     // 000000009DC8: 02102312
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009DCC: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s3                          // 000000009DD0: D5010003 000E070A
	v_cndmask_b32_e64 v8, v11, v8, s3                          // 000000009DD8: D5010008 000E110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009DE0: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 000000009DE4: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 000000009DE8: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009DEC: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 000000009DF0: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 000000009DF8: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s3, s24                            // 000000009E00: BE833018
	s_cbranch_execz 18                                         // 000000009E04: BFA50012 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x450>
	v_mul_hi_u32 v3, v6, v13                                   // 000000009E08: D72D0003 00021B06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009E10: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 000000009E14: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 000000009E1C: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009E20: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 000000009E24: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000009E28: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 000000009E2C: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009E34: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 000000009E38: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 000000009E3C: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009E40: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 000000009E44: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 000000009E48: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s3                              // 000000009E50: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000009E54: BF870121
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 000000009E58: D73C0008 00021082
	v_mov_b32_e32 v3, 0                                        // 000000009E60: 7E060280
	v_add_co_u32 v10, vcc_lo, s19, v8                          // 000000009E64: D7006A0A 00021013
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000009E6C: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s20, v9, vcc_lo             // 000000009E70: D5207C0B 01AA1214
	global_load_b32 v10, v[10:11], off                         // 000000009E78: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 000000009E80: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 000000009E84: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 000000009E88: 7CA214C1
	v_cmp_gt_i64_e64 s3, s[4:5], v[10:11]                      // 000000009E8C: D4540003 00021404
	s_and_b32 s7, vcc_lo, s3                                   // 000000009E94: 8B07036A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009E98: BF870009
	s_and_saveexec_b32 s3, s7                                  // 000000009E9C: BE832007
	s_cbranch_execz 65295                                      // 000000009EA0: BFA5FF0F <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0xe0>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 000000009EA4: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000009EAC: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 000000009EB0: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 000000009EB8: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009EC0: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 000000009EC4: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 000000009ECC: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 000000009ED4: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 000000009EDC: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 000000009EE0: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 000000009EE8: DC520000 037C0008
	s_branch 65275                                             // 000000009EF0: BFA0FEFB <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0xe0>
	s_or_b32 exec_lo, exec_lo, s18                             // 000000009EF4: 8C7E127E
	s_load_b64 s[4:5], s[0:1], 0x38                            // 000000009EF8: F4040100 F8000038
	s_mov_b32 s3, 0                                            // 000000009F00: BE830080
	s_waitcnt lgkmcnt(0)                                       // 000000009F04: BF89FC07
	s_barrier                                                  // 000000009F08: BFBD0000
	buffer_gl0_inv                                             // 000000009F0C: E0AC0000 00000000
	s_cmp_gt_i32 s4, 0                                         // 000000009F14: BF028004
	s_cbranch_scc1 6                                           // 000000009F18: BFA20006 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x534>
	s_add_u32 s6, s0, 64                                       // 000000009F1C: 8006C000
	s_addc_u32 s7, s1, 0                                       // 000000009F20: 82078001
	v_mov_b32_e32 v4, 0                                        // 000000009F24: 7E080280
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000009F28: 916A037E
	s_cbranch_vccz 2                                           // 000000009F2C: BFA30002 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x538>
	s_branch 167                                               // 000000009F30: BFA000A7 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x7d0>
	v_mov_b32_e32 v4, 0                                        // 000000009F34: 7E080280
	s_cmp_eq_u32 s5, 0                                         // 000000009F38: BF068005
	v_lshl_add_u32 v5, v0, 2, 0                                // 000000009F3C: D6460005 02010500
	v_mov_b32_e32 v4, 0                                        // 000000009F44: 7E080280
	s_cselect_b32 s3, -1, 0                                    // 000000009F48: 980380C1
	s_add_u32 s6, s0, 64                                       // 000000009F4C: 8006C000
	s_mov_b32 s5, 0                                            // 000000009F50: BE850080
	s_addc_u32 s7, s1, 0                                       // 000000009F54: 82078001
	s_add_i32 s5, s5, 1                                        // 000000009F58: 81058105
	s_and_saveexec_b32 s0, s2                                  // 000000009F5C: BE802002
	s_cbranch_execz 151                                        // 000000009F60: BFA50097 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x7c0>
	s_load_b32 s1, s[6:7], 0xc                                 // 000000009F64: F4000043 F800000C
	v_mov_b32_e32 v3, v1                                       // 000000009F6C: 7E060301
	v_cvt_f32_u32_e32 v6, s5                                   // 000000009F70: 7E0C0C05
	v_dual_mov_b32 v7, v5 :: v_dual_mov_b32 v2, v0             // 000000009F74: CA100105 07020100
	s_mov_b32 s8, 0                                            // 000000009F7C: BE880080
	s_waitcnt lgkmcnt(0)                                       // 000000009F80: BF89FC07
	s_and_b32 s1, s1, 0xffff                                   // 000000009F84: 8B01FF01 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009F8C: BF870009
	s_lshl_b32 s9, s1, 2                                       // 000000009F90: 84098201
	s_branch 19                                                // 000000009F94: BFA00013 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x5e4>
	s_or_b32 exec_lo, exec_lo, s18                             // 000000009F98: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009F9C: BF870009
	s_or_b32 exec_lo, exec_lo, s17                             // 000000009FA0: 8C7E117E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009FA4: BF870009
	s_or_b32 exec_lo, exec_lo, s16                             // 000000009FA8: 8C7E107E
	v_add_co_u32 v2, vcc_lo, v2, s1                            // 000000009FAC: D7006A02 00000302
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000009FB4: BF870191
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo                // 000000009FB8: D5207C03 01AA0680
	v_dual_add_f32 v8, v8, v10 :: v_dual_add_nc_u32 v7, s9, v7 // 000000009FC0: C9201508 08060E09
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000009FC8: BF870112
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[2:3]                  // 000000009FCC: 7CA6040A
	v_fmac_f32_e32 v4, v8, v6                                  // 000000009FD0: 56080D08
	s_or_b32 s8, vcc_lo, s8                                    // 000000009FD4: 8C08086A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000009FD8: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s8                        // 000000009FDC: 917E087E
	s_cbranch_execz 118                                        // 000000009FE0: BFA50076 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x7bc>
	ds_load_b32 v9, v7                                         // 000000009FE4: D8D80000 09000007
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000009FEC: 916A037E
	s_waitcnt lgkmcnt(0)                                       // 000000009FF0: BF89FC07
	v_lshlrev_b32_e32 v8, 16, v9                               // 000000009FF4: 30101290
	s_cbranch_vccz 5                                           // 000000009FF8: BFA30005 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x610>
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 000000009FFC: 916A037E
	s_cbranch_vccz 60                                          // 00000000A000: BFA3003C <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x6f4>
	v_and_b32_e32 v10, 0xffff0000, v9                          // 00000000A004: 361412FF FFFF0000
	s_branch 65511                                             // 00000000A00C: BFA0FFE7 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x5ac>
	v_bfe_u32 v10, v9, 10, 5                                   // 00000000A010: D610000A 02151509
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A018: BF870122
	v_and_b32_e32 v8, 0x80000000, v8                           // 00000000A01C: 361010FF 80000000
	s_mov_b32 s16, exec_lo                                     // 00000000A024: BE90007E
	v_cmpx_lt_i32_e32 30, v10                                  // 00000000A028: 7D82149E
	s_xor_b32 s16, exec_lo, s16                                // 00000000A02C: 8D10107E
	v_lshlrev_b32_e32 v10, 13, v9                              // 00000000A030: 3014128D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A034: BF870091
	v_and_b32_e32 v10, 0x7fe000, v10                           // 00000000A038: 361414FF 007FE000
	v_or3_b32 v8, v10, v8, 0x7f800000                          // 00000000A040: D6580008 03FE110A 7F800000
	s_and_not1_saveexec_b32 s16, s16                           // 00000000A04C: BE903010
	s_cbranch_execz 36                                         // 00000000A050: BFA50024 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x6e4>
	v_and_b32_e32 v11, 0x3ff, v9                               // 00000000A054: 361612FF 000003FF
	s_mov_b32 s17, exec_lo                                     // 00000000A05C: BE91007E
	v_cmpx_ne_u32_e32 0, v10                                   // 00000000A060: 7D9A1480
	s_xor_b32 s17, exec_lo, s17                                // 00000000A064: 8D11117E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A068: BF870092
	v_lshlrev_b32_e32 v11, 13, v11                             // 00000000A06C: 3016168D
	v_lshl_or_b32 v10, v10, 23, v11                            // 00000000A070: D656000A 042D2F0A
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A078: BF870001
	v_add3_u32 v8, v10, v8, 0x38000000                         // 00000000A07C: D6550008 03FE110A 38000000
	s_and_not1_saveexec_b32 s17, s17                           // 00000000A088: BE913011
	s_cbranch_execz 19                                         // 00000000A08C: BFA50013 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x6dc>
	s_mov_b32 s18, exec_lo                                     // 00000000A090: BE92007E
	v_cmpx_ne_u32_e32 0, v11                                   // 00000000A094: 7D9A1680
	s_cbranch_execz 15                                         // 00000000A098: BFA5000F <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x6d8>
	v_clz_i32_u32_e32 v10, v11                                 // 00000000A09C: 7E14730B
	v_or_b32_e32 v8, 0x43000000, v8                            // 00000000A0A0: 381010FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A0A8: BF870122
	v_xor_b32_e32 v11, 31, v10                                 // 00000000A0AC: 3A16149F
	v_lshlrev_b32_e32 v10, 23, v10                             // 00000000A0B0: 30141497
	v_sub_nc_u32_e32 v11, 9, v11                               // 00000000A0B4: 4C161689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A0B8: BF870112
	v_sub_nc_u32_e32 v8, v8, v10                               // 00000000A0BC: 4C101508
	v_lshlrev_b32_e32 v11, v11, v9                             // 00000000A0C0: 3016130B
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A0C4: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 00000000A0C8: 3016168E
	v_and_or_b32 v8, 0x7fc000, v11, v8                         // 00000000A0CC: D6570008 042216FF 007FC000
	s_or_b32 exec_lo, exec_lo, s18                             // 00000000A0D8: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A0DC: BF870009
	s_or_b32 exec_lo, exec_lo, s17                             // 00000000A0E0: 8C7E117E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000A0E4: BF870499
	s_or_b32 exec_lo, exec_lo, s16                             // 00000000A0E8: 8C7E107E
	s_and_not1_b32 vcc_lo, exec_lo, s3                         // 00000000A0EC: 916A037E
	s_cbranch_vccnz 65476                                      // 00000000A0F0: BFA4FFC4 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x604>
	v_bfe_u32 v12, v9, 26, 5                                   // 00000000A0F4: D610000C 02153509
	v_and_b32_e32 v10, 0x80000000, v9                          // 00000000A0FC: 361412FF 80000000
	v_mov_b16_e32 v11.h, 0                                     // 00000000A104: 7F163880
	v_mov_b16_e32 v11.l, v9.h                                  // 00000000A108: 7E163989
	s_mov_b32 s16, exec_lo                                     // 00000000A10C: BE90007E
	v_cmpx_lt_i32_e32 30, v12                                  // 00000000A110: 7D82189E
	s_xor_b32 s16, exec_lo, s16                                // 00000000A114: 8D10107E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A118: BF870092
	v_lshlrev_b32_e32 v9, 13, v11                              // 00000000A11C: 3012168D
	v_or3_b32 v10, v9, v10, 0x7f800000                         // 00000000A120: D658000A 03FE1509 7F800000
	s_and_not1_saveexec_b32 s16, s16                           // 00000000A12C: BE903010
	s_cbranch_execz 65436                                      // 00000000A130: BFA5FF9C <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x5a4>
	v_bfe_u32 v9, v9, 16, 10                                   // 00000000A134: D6100009 02292109
	s_mov_b32 s17, exec_lo                                     // 00000000A13C: BE91007E
	v_cmpx_ne_u32_e32 0, v12                                   // 00000000A140: 7D9A1880
	s_xor_b32 s17, exec_lo, s17                                // 00000000A144: 8D11117E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A148: BF870092
	v_lshlrev_b32_e32 v9, 13, v9                               // 00000000A14C: 3012128D
	v_lshl_or_b32 v9, v12, 23, v9                              // 00000000A150: D6560009 04252F0C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A158: BF870001
	v_add3_u32 v10, v9, v10, 0x38000000                        // 00000000A15C: D655000A 03FE1509 38000000
	s_and_not1_saveexec_b32 s17, s17                           // 00000000A168: BE913011
	s_cbranch_execz 65419                                      // 00000000A16C: BFA5FF8B <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x59c>
	s_mov_b32 s18, exec_lo                                     // 00000000A170: BE92007E
	v_cmpx_ne_u32_e32 0, v9                                    // 00000000A174: 7D9A1280
	s_cbranch_execz 65415                                      // 00000000A178: BFA5FF87 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x598>
	v_clz_i32_u32_e32 v9, v9                                   // 00000000A17C: 7E127309
	v_or_b32_e32 v10, 0x43000000, v10                          // 00000000A180: 381414FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A188: BF870122
	v_xor_b32_e32 v12, 31, v9                                  // 00000000A18C: 3A18129F
	v_lshlrev_b32_e32 v9, 23, v9                               // 00000000A190: 30121297
	v_sub_nc_u32_e32 v12, 9, v12                               // 00000000A194: 4C181889
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A198: BF870112
	v_sub_nc_u32_e32 v9, v10, v9                               // 00000000A19C: 4C12130A
	v_lshlrev_b32_e32 v11, v12, v11                            // 00000000A1A0: 3016170C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A1A4: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 00000000A1A8: 3016168E
	v_and_or_b32 v10, 0x7fc000, v11, v9                        // 00000000A1AC: D657000A 042616FF 007FC000
	s_branch 65399                                             // 00000000A1B8: BFA0FF77 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x598>
	s_or_b32 exec_lo, exec_lo, s8                              // 00000000A1BC: 8C7E087E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A1C0: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000A1C4: 8C7E007E
	s_cmp_lg_u32 s5, s4                                        // 00000000A1C8: BF070405
	s_cbranch_scc1 65378                                       // 00000000A1CC: BFA2FF62 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x558>
	s_lshl_b32 s0, s10, 2                                      // 00000000A1D0: 8400820A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000A1D4: BF870499
	s_add_i32 s0, s0, 0                                        // 00000000A1D8: 81008000
	v_lshl_add_u32 v1, v0, 2, s0                               // 00000000A1DC: D6460001 00010500
	ds_store_b32 v1, v4                                        // 00000000A1E4: D8340000 00000401
	s_waitcnt lgkmcnt(0)                                       // 00000000A1EC: BF89FC07
	s_barrier                                                  // 00000000A1F0: BFBD0000
	buffer_gl0_inv                                             // 00000000A1F4: E0AC0000 00000000
	s_load_b32 s1, s[6:7], 0xc                                 // 00000000A1FC: F4000043 F800000C
	s_waitcnt lgkmcnt(0)                                       // 00000000A204: BF89FC07
	s_and_b32 s1, s1, 0xffff                                   // 00000000A208: 8B01FF01 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A210: BF870009
	s_cmp_lt_u32 s1, 2                                         // 00000000A214: BF0A8201
	s_cbranch_scc1 33                                          // 00000000A218: BFA20021 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x8a0>
	s_lshr_b32 s1, s1, 1                                       // 00000000A21C: 85018101
	s_branch 16                                                // 00000000A220: BFA00010 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x864>
	s_nop 0                                                    // 00000000A224: BF800000
	s_nop 0                                                    // 00000000A228: BF800000
	s_nop 0                                                    // 00000000A22C: BF800000
	s_nop 0                                                    // 00000000A230: BF800000
	s_nop 0                                                    // 00000000A234: BF800000
	s_nop 0                                                    // 00000000A238: BF800000
	s_nop 0                                                    // 00000000A23C: BF800000
	s_or_b32 exec_lo, exec_lo, s2                              // 00000000A240: 8C7E027E
	s_lshr_b32 s2, s1, 1                                       // 00000000A244: 85028101
	s_cmp_lt_u32 s1, 2                                         // 00000000A248: BF0A8201
	s_mov_b32 s1, s2                                           // 00000000A24C: BE810002
	s_waitcnt lgkmcnt(0)                                       // 00000000A250: BF89FC07
	s_barrier                                                  // 00000000A254: BFBD0000
	buffer_gl0_inv                                             // 00000000A258: E0AC0000 00000000
	s_cbranch_scc1 15                                          // 00000000A260: BFA2000F <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x8a0>
	s_mov_b32 s2, exec_lo                                      // 00000000A264: BE82007E
	v_cmpx_gt_u32_e64 s1, v0                                   // 00000000A268: D4CC007E 00020001
	s_cbranch_execz 65523                                      // 00000000A270: BFA5FFF3 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x840>
	v_lshl_add_u32 v2, s1, 2, v1                               // 00000000A274: D6460002 04050401
	ds_load_b32 v2, v2                                         // 00000000A27C: D8D80000 02000002
	ds_load_b32 v3, v1                                         // 00000000A284: D8D80000 03000001
	s_waitcnt lgkmcnt(0)                                       // 00000000A28C: BF89FC07
	v_add_f32_e32 v2, v2, v3                                   // 00000000A290: 06040702
	ds_store_b32 v1, v2                                        // 00000000A294: D8340000 00000201
	s_branch 65512                                             // 00000000A29C: BFA0FFE8 <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x840>
	s_mov_b32 s1, exec_lo                                      // 00000000A2A0: BE81007E
	v_cmpx_eq_u32_e32 0, v0                                    // 00000000A2A4: 7D940080
	s_cbranch_execz 11                                         // 00000000A2A8: BFA5000B <_ZN12_GLOBAL__N_120fused_lds_sum_kernelEPKjPKiPfllllii+0x8d8>
	v_dual_mov_b32 v0, s0 :: v_dual_mov_b32 v1, 0              // 00000000A2AC: CA100000 00000080
	s_lshl_b64 s[0:1], s[12:13], 2                             // 00000000A2B4: 8480820C
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A2B8: BF870009
	s_add_u32 s0, s14, s0                                      // 00000000A2BC: 8000000E
	ds_load_b32 v0, v0                                         // 00000000A2C0: D8D80000 00000000
	s_addc_u32 s1, s15, s1                                     // 00000000A2C8: 8201010F
	s_waitcnt lgkmcnt(0)                                       // 00000000A2CC: BF89FC07
	global_store_b32 v1, v0, s[0:1]                            // 00000000A2D0: DC6A0000 00000001
	s_endpgm                                                   // 00000000A2D8: BFB00000
		...

000000000000a300 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli>:
	s_load_b256 s[4:11], s[0:1], 0x20                          // 00000000A300: F40C0100 F8000020
	v_mov_b32_e32 v2, 0                                        // 00000000A308: 7E040280
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A30C: BF870001
	v_mov_b32_e32 v1, v2                                       // 00000000A310: 7E020302
	s_waitcnt lgkmcnt(0)                                       // 00000000A314: BF89FC07
	s_mul_i32 s2, s10, s7                                      // 00000000A318: 9602070A
	s_mul_hi_u32 s3, s10, s6                                   // 00000000A31C: 9683060A
	s_mul_i32 s12, s11, s6                                     // 00000000A320: 960C060B
	s_add_i32 s2, s3, s2                                       // 00000000A324: 81020203
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A328: BF870009
	s_add_i32 s3, s2, s12                                      // 00000000A32C: 81030C02
	s_mul_i32 s2, s10, s6                                      // 00000000A330: 9602060A
	s_mov_b32 s12, exec_lo                                     // 00000000A334: BE8C007E
	v_cmpx_gt_i64_e64 s[2:3], v[0:1]                           // 00000000A338: D4D4007E 00020002
	s_cbranch_execz 618                                        // 00000000A340: BFA5026A <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x9ec>
	s_load_b256 s[16:23], s[0:1], null                         // 00000000A344: F40C0400 F8000000
	v_cvt_f32_u32_e32 v3, s6                                   // 00000000A34C: 7E060C06
	s_load_b32 s24, s[0:1], 0x40                               // 00000000A350: F4000600 F8000040
	s_mul_i32 s13, s7, s15                                     // 00000000A358: 960D0F07
	s_mul_hi_u32 s14, s6, s15                                  // 00000000A35C: 968E0F06
	s_mul_i32 s12, s6, s15                                     // 00000000A360: 960C0F06
	v_rcp_iflag_f32_e32 v3, v3                                 // 00000000A364: 7E065703
	s_add_i32 s13, s14, s13                                    // 00000000A368: 810D0D0E
	s_mul_i32 s11, s11, s15                                    // 00000000A36C: 960B0F0B
	s_lshl_b64 s[12:13], s[12:13], 2                           // 00000000A370: 848C820C
	s_mul_hi_u32 s25, s10, s15                                 // 00000000A374: 96990F0A
	s_load_b32 s0, s[0:1], 0x54                                // 00000000A378: F4000000 F8000054
	s_mul_i32 s15, s10, s15                                    // 00000000A380: 960F0F0A
	s_mov_b32 s26, 0                                           // 00000000A384: BE9A0080
	s_waitcnt_depctr 0xfff                                     // 00000000A388: BF880FFF
	v_mul_f32_e32 v3, 0x4f7ffffe, v3                           // 00000000A38C: 100606FF 4F7FFFFE
	s_waitcnt lgkmcnt(0)                                       // 00000000A394: BF89FC07
	s_add_u32 s14, s20, s12                                    // 00000000A398: 800E0C14
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A39C: BF870001
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000A3A0: 7E060F03
	s_addc_u32 s20, s21, s13                                   // 00000000A3A4: 82140D15
	s_add_i32 s21, s25, s11                                    // 00000000A3A8: 81150B19
	s_cmp_eq_u32 s24, 0                                        // 00000000A3AC: BF068018
	v_cmp_gt_i64_e64 s25, s[8:9], 0                            // 00000000A3B0: D4540019 00010008
	s_cselect_b32 s24, -1, 0                                   // 00000000A3B8: 981880C1
	s_sub_i32 s1, 0, s6                                        // 00000000A3BC: 81810680
	s_ashr_i32 s10, s7, 31                                     // 00000000A3C0: 860A9F07
	v_mul_lo_u32 v4, s1, v3                                    // 00000000A3C4: D72C0004 00020601
	s_and_b32 s27, s0, 0xffff                                  // 00000000A3CC: 8B1BFF00 0000FFFF
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A3D4: BF870091
	v_mul_hi_u32 v4, v3, v4                                    // 00000000A3D8: D72D0004 00020903
	v_add_nc_u32_e32 v9, v3, v4                                // 00000000A3E0: 4A120903
	s_branch 33                                                // 00000000A3E4: BFA00021 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x16c>
	v_mov_b32_e32 v12, 0                                       // 00000000A3E8: 7E180280
	v_mul_lo_u32 v7, v11, s6                                   // 00000000A3EC: D72C0007 00000D0B
	v_mul_lo_u32 v8, v10, s7                                   // 00000000A3F4: D72C0008 00000F0A
	v_mad_u64_u32 v[5:6], null, v10, s6, 0                     // 00000000A3FC: D6FE7C05 02000D0A
	v_add_co_u32 v0, vcc_lo, v0, s27                           // 00000000A404: D7006A00 00003700
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000A40C: BF870191
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 00000000A410: D5207C01 01AA0280
	v_add3_u32 v6, v6, v8, v7                                  // 00000000A418: D6550006 041E1106
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A420: BF870091
	v_lshlrev_b64 v[5:6], 2, v[5:6]                            // 00000000A424: D73C0005 00020A82
	v_add_co_u32 v5, vcc_lo, s22, v5                           // 00000000A42C: D7006A05 00020A16
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000A434: BF8701A1
	v_add_co_ci_u32_e64 v6, null, s23, v6, vcc_lo              // 00000000A438: D5207C06 01AA0C17
	v_cmp_le_i64_e32 vcc_lo, s[2:3], v[0:1]                    // 00000000A440: 7CA60002
	v_add_co_u32 v3, s0, v5, v3                                // 00000000A444: D7000003 00020705
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A44C: BF870001
	v_add_co_ci_u32_e64 v4, null, v6, v4, s0                   // 00000000A450: D5207C04 00020906
	s_or_b32 s26, vcc_lo, s26                                  // 00000000A458: 8C1A1A6A
	global_store_b32 v[3:4], v12, off                          // 00000000A45C: DC6A0000 007C0C03
	s_and_not1_b32 exec_lo, exec_lo, s26                       // 00000000A464: 917E1A7E
	s_cbranch_execz 544                                        // 00000000A468: BFA50220 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x9ec>
	v_or_b32_e32 v3, s7, v1                                    // 00000000A46C: 38060207
	s_mov_b32 s0, exec_lo                                      // 00000000A470: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A474: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000A478: 7DBA0480
	s_xor_b32 s1, exec_lo, s0                                  // 00000000A47C: 8D01007E
	s_cbranch_execz 175                                        // 00000000A480: BFA500AF <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x440>
	s_add_u32 s12, s6, s10                                     // 00000000A484: 800C0A06
	s_mov_b32 s11, s10                                         // 00000000A488: BE8B000A
	s_addc_u32 s13, s7, s10                                    // 00000000A48C: 820D0A07
	v_ashrrev_i32_e32 v10, 31, v1                              // 00000000A490: 3414029F
	s_xor_b64 s[12:13], s[12:13], s[10:11]                     // 00000000A494: 8D8C0A0C
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000A498: BF870159
	v_cvt_f32_u32_e32 v3, s12                                  // 00000000A49C: 7E060C0C
	v_cvt_f32_u32_e32 v4, s13                                  // 00000000A4A0: 7E080C0D
	s_sub_u32 s0, 0, s12                                       // 00000000A4A4: 80800C80
	s_subb_u32 s29, 0, s13                                     // 00000000A4A8: 829D0D80
	v_add_co_u32 v5, vcc_lo, v0, v10                           // 00000000A4AC: D7006A05 00021500
	v_fmac_f32_e32 v3, 0x4f800000, v4                          // 00000000A4B4: 560608FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A4BC: BF870112
	v_xor_b32_e32 v11, v5, v10                                 // 00000000A4C0: 3A161505
	v_rcp_f32_e32 v3, v3                                       // 00000000A4C4: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000A4C8: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000A4CC: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A4D4: BF870091
	v_mul_f32_e32 v4, 0x2f800000, v3                           // 00000000A4D8: 100806FF 2F800000
	v_trunc_f32_e32 v4, v4                                     // 00000000A4E0: 7E084304
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A4E4: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v4                          // 00000000A4E8: 560608FF CF800000
	v_cvt_u32_f32_e32 v4, v4                                   // 00000000A4F0: 7E080F04
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000A4F4: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A4F8: BF870112
	v_readfirstlane_b32 s11, v4                                // 00000000A4FC: 7E160504
	v_readfirstlane_b32 s28, v3                                // 00000000A500: 7E380503
	s_mul_i32 s30, s0, s11                                     // 00000000A504: 961E0B00
	v_add_co_ci_u32_e64 v3, null, v1, v10, vcc_lo              // 00000000A508: D5207C03 01AA1501
	s_mul_hi_u32 s33, s0, s28                                  // 00000000A510: 96A11C00
	s_mul_i32 s31, s29, s28                                    // 00000000A514: 961F1C1D
	s_add_i32 s30, s33, s30                                    // 00000000A518: 811E1E21
	s_mul_i32 s34, s0, s28                                     // 00000000A51C: 96221C00
	s_add_i32 s30, s30, s31                                    // 00000000A520: 811E1F1E
	s_mul_hi_u32 s33, s28, s34                                 // 00000000A524: 96A1221C
	s_mul_i32 s36, s28, s30                                    // 00000000A528: 96241E1C
	s_mul_hi_u32 s35, s11, s34                                 // 00000000A52C: 96A3220B
	s_mul_i32 s31, s11, s34                                    // 00000000A530: 961F220B
	s_mul_hi_u32 s34, s28, s30                                 // 00000000A534: 96A21E1C
	s_add_u32 s33, s33, s36                                    // 00000000A538: 80212421
	s_addc_u32 s34, 0, s34                                     // 00000000A53C: 82222280
	s_mul_hi_u32 s37, s11, s30                                 // 00000000A540: 96A51E0B
	s_add_u32 s31, s33, s31                                    // 00000000A544: 801F1F21
	s_mul_i32 s30, s11, s30                                    // 00000000A548: 961E1E0B
	s_addc_u32 s31, s34, s35                                   // 00000000A54C: 821F2322
	s_addc_u32 s33, s37, 0                                     // 00000000A550: 82218025
	s_add_u32 s30, s31, s30                                    // 00000000A554: 801E1E1F
	s_addc_u32 s31, 0, s33                                     // 00000000A558: 821F2180
	s_add_u32 s28, s28, s30                                    // 00000000A55C: 801C1E1C
	s_cselect_b32 s30, -1, 0                                   // 00000000A560: 981E80C1
	s_mul_hi_u32 s33, s0, s28                                  // 00000000A564: 96A11C00
	s_cmp_lg_u32 s30, 0                                        // 00000000A568: BF07801E
	s_mul_i32 s30, s0, s28                                     // 00000000A56C: 961E1C00
	s_addc_u32 s11, s11, s31                                   // 00000000A570: 820B1F0B
	s_mul_i32 s29, s29, s28                                    // 00000000A574: 961D1C1D
	s_mul_i32 s0, s0, s11                                      // 00000000A578: 96000B00
	s_mul_hi_u32 s31, s28, s30                                 // 00000000A57C: 969F1E1C
	s_add_i32 s0, s33, s0                                      // 00000000A580: 81000021
	s_mul_hi_u32 s33, s11, s30                                 // 00000000A584: 96A11E0B
	s_add_i32 s0, s0, s29                                      // 00000000A588: 81001D00
	s_mul_i32 s29, s11, s30                                    // 00000000A58C: 961D1E0B
	s_mul_i32 s35, s28, s0                                     // 00000000A590: 9623001C
	s_mul_hi_u32 s34, s28, s0                                  // 00000000A594: 96A2001C
	s_add_u32 s31, s31, s35                                    // 00000000A598: 801F231F
	s_addc_u32 s34, 0, s34                                     // 00000000A59C: 82222280
	s_mul_hi_u32 s30, s11, s0                                  // 00000000A5A0: 969E000B
	s_add_u32 s29, s31, s29                                    // 00000000A5A4: 801D1D1F
	s_mul_i32 s0, s11, s0                                      // 00000000A5A8: 9600000B
	s_addc_u32 s29, s34, s33                                   // 00000000A5AC: 821D2122
	s_addc_u32 s30, s30, 0                                     // 00000000A5B0: 821E801E
	s_add_u32 s0, s29, s0                                      // 00000000A5B4: 8000001D
	s_addc_u32 s29, 0, s30                                     // 00000000A5B8: 821D1E80
	s_add_u32 s0, s28, s0                                      // 00000000A5BC: 8000001C
	s_cselect_b32 s28, -1, 0                                   // 00000000A5C0: 981C80C1
	v_xor_b32_e32 v12, v3, v10                                 // 00000000A5C4: 3A181503
	s_cmp_lg_u32 s28, 0                                        // 00000000A5C8: BF07801C
	v_mul_hi_u32 v13, v11, s0                                  // 00000000A5CC: D72D000D 0000010B
	s_addc_u32 s11, s11, s29                                   // 00000000A5D4: 820B1D0B
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000A5D8: BF8701B9
	v_mad_u64_u32 v[3:4], null, v11, s11, 0                    // 00000000A5DC: D6FE7C03 0200170B
	v_mad_u64_u32 v[5:6], null, v12, s0, 0                     // 00000000A5E4: D6FE7C05 0200010C
	v_mad_u64_u32 v[7:8], null, v12, s11, 0                    // 00000000A5EC: D6FE7C07 0200170C
	v_add_co_u32 v3, vcc_lo, v13, v3                           // 00000000A5F4: D7006A03 0002070D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A5FC: BF870111
	v_add_co_ci_u32_e64 v4, null, 0, v4, vcc_lo                // 00000000A600: D5207C04 01AA0880
	v_add_co_u32 v3, vcc_lo, v3, v5                            // 00000000A608: D7006A03 00020B03
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A610: BF870122
	v_add_co_ci_u32_e32 v3, vcc_lo, v4, v6, vcc_lo             // 00000000A614: 40060D04
	v_add_co_ci_u32_e32 v4, vcc_lo, 0, v8, vcc_lo              // 00000000A618: 40081080
	v_add_co_u32 v5, vcc_lo, v3, v7                            // 00000000A61C: D7006A05 00020F03
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A624: BF870111
	v_add_co_ci_u32_e64 v6, null, 0, v4, vcc_lo                // 00000000A628: D5207C06 01AA0880
	v_mul_lo_u32 v7, s13, v5                                   // 00000000A630: D72C0007 00020A0D
	v_mad_u64_u32 v[3:4], null, s12, v5, 0                     // 00000000A638: D6FE7C03 02020A0C
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A640: BF870113
	v_mul_lo_u32 v8, s12, v6                                   // 00000000A644: D72C0008 00020C0C
	v_sub_co_u32 v3, vcc_lo, v11, v3                           // 00000000A64C: D7016A03 0002070B
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000A654: BF8700A2
	v_add3_u32 v4, v4, v8, v7                                  // 00000000A658: D6550004 041E1104
	v_add_co_u32 v8, s0, v5, 2                                 // 00000000A660: D7000008 00010505
	v_add_co_ci_u32_e64 v11, null, 0, v6, s0                   // 00000000A668: D5207C0B 00020C80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000A670: BF8701B3
	v_sub_nc_u32_e32 v7, v12, v4                               // 00000000A674: 4C0E090C
	v_sub_co_u32 v13, s0, v3, s12                              // 00000000A678: D701000D 00001903
	v_sub_co_ci_u32_e64 v4, null, v12, v4, vcc_lo              // 00000000A680: D5217C04 01AA090C
	v_subrev_co_ci_u32_e64 v7, null, s13, v7, vcc_lo           // 00000000A688: D5227C07 01AA0E0D
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A690: BF870113
	v_cmp_le_u32_e32 vcc_lo, s12, v13                          // 00000000A694: 7C961A0C
	v_subrev_co_ci_u32_e64 v7, null, 0, v7, s0                 // 00000000A698: D5227C07 00020E80
	v_cndmask_b32_e64 v12, 0, -1, vcc_lo                       // 00000000A6A0: D501000C 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000A6A8: BF870002
	v_cmp_le_u32_e32 vcc_lo, s13, v7                           // 00000000A6AC: 7C960E0D
	v_cndmask_b32_e64 v13, 0, -1, vcc_lo                       // 00000000A6B0: D501000D 01A98280
	v_cmp_le_u32_e32 vcc_lo, s12, v3                           // 00000000A6B8: 7C96060C
	v_cndmask_b32_e64 v3, 0, -1, vcc_lo                        // 00000000A6BC: D5010003 01A98280
	v_cmp_le_u32_e32 vcc_lo, s13, v4                           // 00000000A6C4: 7C96080D
	v_cndmask_b32_e64 v14, 0, -1, vcc_lo                       // 00000000A6C8: D501000E 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s13, v7                           // 00000000A6D0: 7C940E0D
	v_cndmask_b32_e32 v7, v13, v12, vcc_lo                     // 00000000A6D4: 020E190D
	v_add_co_u32 v12, vcc_lo, v5, 1                            // 00000000A6D8: D7006A0C 00010305
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000A6E0: BF8701D1
	v_add_co_ci_u32_e64 v13, null, 0, v6, vcc_lo               // 00000000A6E4: D5207C0D 01AA0C80
	v_cmp_eq_u32_e32 vcc_lo, s13, v4                           // 00000000A6EC: 7C94080D
	v_cndmask_b32_e32 v3, v14, v3, vcc_lo                      // 00000000A6F0: 0206070E
	v_cmp_ne_u32_e32 vcc_lo, 0, v7                             // 00000000A6F4: 7C9A0E80
	v_xor_b32_e32 v7, s10, v10                                 // 00000000A6F8: 3A0E140A
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 00000000A6FC: D44D0000 00020680
	v_dual_cndmask_b32 v3, v12, v8 :: v_dual_cndmask_b32 v4, v13, v11// 00000000A704: CA52110C 0304170D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A70C: BF870111
	v_cndmask_b32_e64 v3, v5, v3, s0                           // 00000000A710: D5010003 00020705
	v_cndmask_b32_e64 v4, v6, v4, s0                           // 00000000A718: D5010004 00020906
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A720: BF870112
	v_xor_b32_e32 v3, v3, v7                                   // 00000000A724: 3A060F03
	v_xor_b32_e32 v4, v4, v7                                   // 00000000A728: 3A080F04
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A72C: BF870092
	v_sub_co_u32 v5, vcc_lo, v3, v7                            // 00000000A730: D7016A05 00020F03
	v_sub_co_ci_u32_e64 v6, null, v4, v7, vcc_lo               // 00000000A738: D5217C06 01AA0F04
	s_and_not1_saveexec_b32 s0, s1                             // 00000000A740: BE803001
	s_cbranch_execz 18                                         // 00000000A744: BFA50012 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x490>
	v_mul_hi_u32 v3, v0, v9                                    // 00000000A748: D72D0003 00021300
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A750: BF870091
	v_mul_lo_u32 v4, v3, s6                                    // 00000000A754: D72C0004 00000D03
	v_sub_nc_u32_e32 v4, v0, v4                                // 00000000A75C: 4C080900
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A760: BF870121
	v_subrev_nc_u32_e32 v6, s6, v4                             // 00000000A764: 4E0C0806
	v_cmp_le_u32_e32 vcc_lo, s6, v4                            // 00000000A768: 7C960806
	v_dual_cndmask_b32 v4, v4, v6 :: v_dual_add_nc_u32 v5, 1, v3// 00000000A76C: CA600D04 04040681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A774: BF870111
	v_dual_cndmask_b32 v3, v3, v5 :: v_dual_mov_b32 v6, v2     // 00000000A778: CA500B03 03060102
	v_cmp_le_u32_e32 vcc_lo, s6, v4                            // 00000000A780: 7C960806
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A784: BF870092
	v_add_nc_u32_e32 v5, 1, v3                                 // 00000000A788: 4A0A0681
	v_cndmask_b32_e32 v5, v3, v5, vcc_lo                       // 00000000A78C: 020A0B03
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000A790: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A794: BF870111
	v_mul_lo_u32 v7, v6, s6                                    // 00000000A798: D72C0007 00000D06
	v_mul_lo_u32 v8, v5, s7                                    // 00000000A7A0: D72C0008 00000F05
	v_mad_u64_u32 v[3:4], null, v5, s6, 0                      // 00000000A7A8: D6FE7C03 02000D05
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000A7B0: BF870111
	v_add3_u32 v4, v4, v8, v7                                  // 00000000A7B4: D6550004 041E1104
	v_sub_co_u32 v3, vcc_lo, v0, v3                            // 00000000A7BC: D7016A03 00020700
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000A7C4: BF8700A1
	v_sub_co_ci_u32_e64 v4, null, v1, v4, vcc_lo               // 00000000A7C8: D5217C04 01AA0901
	v_add_co_u32 v10, vcc_lo, v5, s15                          // 00000000A7D0: D7006A0A 00001F05
	v_add_co_ci_u32_e64 v11, null, s21, v6, vcc_lo             // 00000000A7D8: D5207C0B 01AA0C15
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000A7E0: BF870003
	v_lshlrev_b64 v[3:4], 2, v[3:4]                            // 00000000A7E4: D73C0003 00020682
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000A7EC: 916A197E
	s_cbranch_vccnz 65277                                      // 00000000A7F0: BFA4FEFD <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0xe8>
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A7F4: BF870091
	v_add_co_u32 v5, vcc_lo, s14, v3                           // 00000000A7F8: D7006A05 0002060E
	v_add_co_ci_u32_e64 v6, null, s20, v4, vcc_lo              // 00000000A800: D5207C06 01AA0814
	v_mul_lo_u32 v14, v11, s8                                  // 00000000A808: D72C000E 0000110B
	v_mul_lo_u32 v15, v10, s9                                  // 00000000A810: D72C000F 0000130A
	global_load_b32 v7, v[5:6], off                            // 00000000A818: DC520000 077C0005
	v_mad_u64_u32 v[5:6], null, v10, s8, 0                     // 00000000A820: D6FE7C05 0200110A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A828: BF870091
	v_add3_u32 v6, v6, v15, v14                                // 00000000A82C: D6550006 043A1F06
	v_lshlrev_b64 v[5:6], 2, v[5:6]                            // 00000000A834: D73C0005 00020A82
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A83C: BF870091
	v_add_co_u32 v5, vcc_lo, s18, v5                           // 00000000A840: D7006A05 00020A12
	v_add_co_ci_u32_e64 v6, null, s19, v6, vcc_lo              // 00000000A848: D5207C06 01AA0C13
	s_waitcnt vmcnt(0)                                         // 00000000A850: BF8903F7
	v_ashrrev_i32_e32 v8, 31, v7                               // 00000000A854: 34100E9F
	v_mul_lo_u32 v16, s9, v7                                   // 00000000A858: D72C0010 00020E09
	v_mad_u64_u32 v[12:13], null, s8, v7, 0                    // 00000000A860: D6FE7C0C 02020E08
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_4) | instid1(VALU_DEP_1)// 00000000A868: BF8700D3
	v_mul_lo_u32 v17, s8, v8                                   // 00000000A86C: D72C0011 00021008
	v_cmp_lt_i64_e32 vcc_lo, -1, v[7:8]                        // 00000000A874: 7CA20EC1
	v_cmp_gt_i64_e64 s0, s[4:5], v[7:8]                        // 00000000A878: D4540000 00020E04
	s_and_b32 s11, vcc_lo, s0                                  // 00000000A880: 8B0B006A
	v_add3_u32 v13, v13, v17, v16                              // 00000000A884: D655000D 0442230D
	v_lshlrev_b64 v[12:13], 2, v[12:13]                        // 00000000A88C: D73C000C 00021882
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A894: BF870091
	v_add_co_u32 v7, s1, s16, v12                              // 00000000A898: D7000107 00021810
	v_add_co_ci_u32_e64 v8, null, s17, v13, s1                 // 00000000A8A0: D5207C08 00061A11
	v_mov_b32_e32 v12, 0                                       // 00000000A8A8: 7E180280
	s_mov_b64 s[0:1], s[8:9]                                   // 00000000A8AC: BE800108
	s_branch 23                                                // 00000000A8B0: BFA00017 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x610>
	s_or_b32 exec_lo, exec_lo, s28                             // 00000000A8B4: 8C7E1C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A8B8: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 00000000A8BC: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A8C0: BF870009
	s_or_b32 exec_lo, exec_lo, s12                             // 00000000A8C4: 8C7E0C7E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000A8C8: BF8700A1
	v_mul_f32_e32 v14, v17, v16                                // 00000000A8CC: 101C2111
	v_add_co_u32 v5, vcc_lo, v5, 4                             // 00000000A8D0: D7006A05 00010905
	v_add_co_ci_u32_e64 v6, null, 0, v6, vcc_lo                // 00000000A8D8: D5207C06 01AA0C80
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000A8E0: BF870003
	v_fmac_f32_e32 v14, v13, v15                               // 00000000A8E4: 561C1F0D
	v_add_co_u32 v7, vcc_lo, v7, 4                             // 00000000A8E8: D7006A07 00010907
	s_add_u32 s0, s0, -1                                       // 00000000A8F0: 8000C100
	v_add_co_ci_u32_e64 v8, null, 0, v8, vcc_lo                // 00000000A8F4: D5207C08 01AA1080
	v_add_f32_e32 v12, v12, v14                                // 00000000A8FC: 06181D0C
	s_addc_u32 s1, s1, -1                                      // 00000000A900: 8201C101
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000A904: BF870009
	s_cmp_eq_u64 s[0:1], 0                                     // 00000000A908: BF108000
	s_cbranch_scc1 65207                                       // 00000000A90C: BFA2FEB7 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0xec>
	v_mov_b32_e32 v16, 0                                       // 00000000A910: 7E200280
	s_and_saveexec_b32 s12, s11                                // 00000000A914: BE8C200B
	s_cbranch_execz 2                                          // 00000000A918: BFA50002 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x624>
	global_load_b32 v16, v[7:8], off                           // 00000000A91C: DC520000 107C0007
	s_or_b32 exec_lo, exec_lo, s12                             // 00000000A924: 8C7E0C7E
	global_load_b32 v14, v[5:6], off                           // 00000000A928: DC520000 0E7C0005
	s_waitcnt vmcnt(1)                                         // 00000000A930: BF8907F7
	v_lshlrev_b32_e32 v13, 16, v16                             // 00000000A934: 301A2090
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000A938: 916A187E
	s_cbranch_vccz 13                                          // 00000000A93C: BFA3000D <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x674>
	s_waitcnt vmcnt(0)                                         // 00000000A940: BF8903F7
	v_lshlrev_b32_e32 v15, 16, v14                             // 00000000A944: 301E1C90
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000A948: 916A187E
	s_cbranch_vccz 68                                          // 00000000A94C: BFA30044 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x760>
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000A950: 916A187E
	s_cbranch_vccz 123                                         // 00000000A954: BFA3007B <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x844>
	v_and_b32_e32 v17, 0xffff0000, v16                         // 00000000A958: 362220FF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000A960: 916A187E
	s_cbranch_vccz 175                                         // 00000000A964: BFA300AF <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x924>
	v_and_b32_e32 v16, 0xffff0000, v14                         // 00000000A968: 36201CFF FFFF0000
	s_branch 65493                                             // 00000000A970: BFA0FFD5 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x5c8>
	v_bfe_u32 v15, v16, 10, 5                                  // 00000000A974: D610000F 02151510
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000A97C: BF870122
	v_and_b32_e32 v13, 0x80000000, v13                         // 00000000A980: 361A1AFF 80000000
	s_mov_b32 s12, exec_lo                                     // 00000000A988: BE8C007E
	v_cmpx_lt_i32_e32 30, v15                                  // 00000000A98C: 7D821E9E
	s_xor_b32 s12, exec_lo, s12                                // 00000000A990: 8D0C0C7E
	v_lshlrev_b32_e32 v15, 13, v16                             // 00000000A994: 301E208D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A998: BF870091
	v_and_b32_e32 v15, 0x7fe000, v15                           // 00000000A99C: 361E1EFF 007FE000
	v_or3_b32 v13, v15, v13, 0x7f800000                        // 00000000A9A4: D658000D 03FE1B0F 7F800000
	s_and_not1_saveexec_b32 s12, s12                           // 00000000A9B0: BE8C300C
	s_cbranch_execz 36                                         // 00000000A9B4: BFA50024 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x748>
	v_and_b32_e32 v17, 0x3ff, v16                              // 00000000A9B8: 362220FF 000003FF
	s_mov_b32 s13, exec_lo                                     // 00000000A9C0: BE8D007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000A9C4: 7D9A1E80
	s_xor_b32 s13, exec_lo, s13                                // 00000000A9C8: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000A9CC: BF870092
	v_lshlrev_b32_e32 v17, 13, v17                             // 00000000A9D0: 3022228D
	v_lshl_or_b32 v15, v15, 23, v17                            // 00000000A9D4: D656000F 04452F0F
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000A9DC: BF870001
	v_add3_u32 v13, v15, v13, 0x38000000                       // 00000000A9E0: D655000D 03FE1B0F 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 00000000A9EC: BE8D300D
	s_cbranch_execz 19                                         // 00000000A9F0: BFA50013 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x740>
	s_mov_b32 s28, exec_lo                                     // 00000000A9F4: BE9C007E
	v_cmpx_ne_u32_e32 0, v17                                   // 00000000A9F8: 7D9A2280
	s_cbranch_execz 15                                         // 00000000A9FC: BFA5000F <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x73c>
	v_clz_i32_u32_e32 v15, v17                                 // 00000000AA00: 7E1E7311
	v_or_b32_e32 v13, 0x43000000, v13                          // 00000000AA04: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000AA0C: BF870122
	v_xor_b32_e32 v17, 31, v15                                 // 00000000AA10: 3A221E9F
	v_lshlrev_b32_e32 v15, 23, v15                             // 00000000AA14: 301E1E97
	v_sub_nc_u32_e32 v17, 9, v17                               // 00000000AA18: 4C222289
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AA1C: BF870112
	v_sub_nc_u32_e32 v13, v13, v15                             // 00000000AA20: 4C1A1F0D
	v_lshlrev_b32_e32 v17, v17, v16                            // 00000000AA24: 30222111
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AA28: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 00000000AA2C: 3022228E
	v_and_or_b32 v13, 0x7fc000, v17, v13                       // 00000000AA30: D657000D 043622FF 007FC000
	s_or_b32 exec_lo, exec_lo, s28                             // 00000000AA3C: 8C7E1C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000AA40: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 00000000AA44: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000AA48: BF870009
	s_or_b32 exec_lo, exec_lo, s12                             // 00000000AA4C: 8C7E0C7E
	s_waitcnt vmcnt(0)                                         // 00000000AA50: BF8903F7
	v_lshlrev_b32_e32 v15, 16, v14                             // 00000000AA54: 301E1C90
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000AA58: 916A187E
	s_cbranch_vccnz 65468                                      // 00000000AA5C: BFA4FFBC <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x650>
	v_bfe_u32 v17, v14, 10, 5                                  // 00000000AA60: D6100011 0215150E
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000AA68: BF870122
	v_and_b32_e32 v15, 0x80000000, v15                         // 00000000AA6C: 361E1EFF 80000000
	s_mov_b32 s12, exec_lo                                     // 00000000AA74: BE8C007E
	v_cmpx_lt_i32_e32 30, v17                                  // 00000000AA78: 7D82229E
	s_xor_b32 s12, exec_lo, s12                                // 00000000AA7C: 8D0C0C7E
	v_lshlrev_b32_e32 v17, 13, v14                             // 00000000AA80: 30221C8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AA84: BF870091
	v_and_b32_e32 v17, 0x7fe000, v17                           // 00000000AA88: 362222FF 007FE000
	v_or3_b32 v15, v17, v15, 0x7f800000                        // 00000000AA90: D658000F 03FE1F11 7F800000
	s_and_not1_saveexec_b32 s12, s12                           // 00000000AA9C: BE8C300C
	s_cbranch_execz 36                                         // 00000000AAA0: BFA50024 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x834>
	v_and_b32_e32 v18, 0x3ff, v14                              // 00000000AAA4: 36241CFF 000003FF
	s_mov_b32 s13, exec_lo                                     // 00000000AAAC: BE8D007E
	v_cmpx_ne_u32_e32 0, v17                                   // 00000000AAB0: 7D9A2280
	s_xor_b32 s13, exec_lo, s13                                // 00000000AAB4: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AAB8: BF870092
	v_lshlrev_b32_e32 v18, 13, v18                             // 00000000AABC: 3024248D
	v_lshl_or_b32 v17, v17, 23, v18                            // 00000000AAC0: D6560011 04492F11
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000AAC8: BF870001
	v_add3_u32 v15, v17, v15, 0x38000000                       // 00000000AACC: D655000F 03FE1F11 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 00000000AAD8: BE8D300D
	s_cbranch_execz 19                                         // 00000000AADC: BFA50013 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x82c>
	s_mov_b32 s28, exec_lo                                     // 00000000AAE0: BE9C007E
	v_cmpx_ne_u32_e32 0, v18                                   // 00000000AAE4: 7D9A2480
	s_cbranch_execz 15                                         // 00000000AAE8: BFA5000F <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x828>
	v_clz_i32_u32_e32 v17, v18                                 // 00000000AAEC: 7E227312
	v_or_b32_e32 v15, 0x43000000, v15                          // 00000000AAF0: 381E1EFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000AAF8: BF870122
	v_xor_b32_e32 v18, 31, v17                                 // 00000000AAFC: 3A24229F
	v_lshlrev_b32_e32 v17, 23, v17                             // 00000000AB00: 30222297
	v_sub_nc_u32_e32 v18, 9, v18                               // 00000000AB04: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AB08: BF870112
	v_sub_nc_u32_e32 v15, v15, v17                             // 00000000AB0C: 4C1E230F
	v_lshlrev_b32_e32 v18, v18, v14                            // 00000000AB10: 30241D12
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AB14: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 00000000AB18: 3024248E
	v_and_or_b32 v15, 0x7fc000, v18, v15                       // 00000000AB1C: D657000F 043E24FF 007FC000
	s_or_b32 exec_lo, exec_lo, s28                             // 00000000AB28: 8C7E1C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000AB2C: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 00000000AB30: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000AB34: BF870499
	s_or_b32 exec_lo, exec_lo, s12                             // 00000000AB38: 8C7E0C7E
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000AB3C: 916A187E
	s_cbranch_vccnz 65413                                      // 00000000AB40: BFA4FF85 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x658>
	v_bfe_u32 v19, v16, 26, 5                                  // 00000000AB44: D6100013 02153510
	v_and_b32_e32 v17, 0x80000000, v16                         // 00000000AB4C: 362220FF 80000000
	v_mov_b16_e32 v18.h, 0                                     // 00000000AB54: 7F243880
	v_mov_b16_e32 v18.l, v16.h                                 // 00000000AB58: 7E243990
	s_mov_b32 s12, exec_lo                                     // 00000000AB5C: BE8C007E
	v_cmpx_lt_i32_e32 30, v19                                  // 00000000AB60: 7D82269E
	s_xor_b32 s12, exec_lo, s12                                // 00000000AB64: 8D0C0C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AB68: BF870092
	v_lshlrev_b32_e32 v16, 13, v18                             // 00000000AB6C: 3020248D
	v_or3_b32 v17, v16, v17, 0x7f800000                        // 00000000AB70: D6580011 03FE2310 7F800000
	s_and_not1_saveexec_b32 s12, s12                           // 00000000AB7C: BE8C300C
	s_cbranch_execz 36                                         // 00000000AB80: BFA50024 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x914>
	v_bfe_u32 v16, v16, 16, 10                                 // 00000000AB84: D6100010 02292110
	s_mov_b32 s13, exec_lo                                     // 00000000AB8C: BE8D007E
	v_cmpx_ne_u32_e32 0, v19                                   // 00000000AB90: 7D9A2680
	s_xor_b32 s13, exec_lo, s13                                // 00000000AB94: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AB98: BF870092
	v_lshlrev_b32_e32 v16, 13, v16                             // 00000000AB9C: 3020208D
	v_lshl_or_b32 v16, v19, 23, v16                            // 00000000ABA0: D6560010 04412F13
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000ABA8: BF870001
	v_add3_u32 v17, v16, v17, 0x38000000                       // 00000000ABAC: D6550011 03FE2310 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 00000000ABB8: BE8D300D
	s_cbranch_execz 19                                         // 00000000ABBC: BFA50013 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x90c>
	s_mov_b32 s28, exec_lo                                     // 00000000ABC0: BE9C007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000ABC4: 7D9A2080
	s_cbranch_execz 15                                         // 00000000ABC8: BFA5000F <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x908>
	v_clz_i32_u32_e32 v16, v16                                 // 00000000ABCC: 7E207310
	v_or_b32_e32 v17, 0x43000000, v17                          // 00000000ABD0: 382222FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000ABD8: BF870122
	v_xor_b32_e32 v19, 31, v16                                 // 00000000ABDC: 3A26209F
	v_lshlrev_b32_e32 v16, 23, v16                             // 00000000ABE0: 30202097
	v_sub_nc_u32_e32 v19, 9, v19                               // 00000000ABE4: 4C262689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000ABE8: BF870112
	v_sub_nc_u32_e32 v16, v17, v16                             // 00000000ABEC: 4C202111
	v_lshlrev_b32_e32 v18, v19, v18                            // 00000000ABF0: 30242513
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000ABF4: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 00000000ABF8: 3024248E
	v_and_or_b32 v17, 0x7fc000, v18, v16                       // 00000000ABFC: D6570011 044224FF 007FC000
	s_or_b32 exec_lo, exec_lo, s28                             // 00000000AC08: 8C7E1C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000AC0C: BF870009
	s_or_b32 exec_lo, exec_lo, s13                             // 00000000AC10: 8C7E0D7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000AC14: BF870499
	s_or_b32 exec_lo, exec_lo, s12                             // 00000000AC18: 8C7E0C7E
	s_and_not1_b32 vcc_lo, exec_lo, s24                        // 00000000AC1C: 916A187E
	s_cbranch_vccnz 65361                                      // 00000000AC20: BFA4FF51 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x668>
	v_bfe_u32 v19, v14, 26, 5                                  // 00000000AC24: D6100013 0215350E
	v_and_b32_e32 v16, 0x80000000, v14                         // 00000000AC2C: 36201CFF 80000000
	v_mov_b16_e32 v18.h, 0                                     // 00000000AC34: 7F243880
	v_mov_b16_e32 v18.l, v14.h                                 // 00000000AC38: 7E24398E
	s_mov_b32 s12, exec_lo                                     // 00000000AC3C: BE8C007E
	v_cmpx_lt_i32_e32 30, v19                                  // 00000000AC40: 7D82269E
	s_xor_b32 s12, exec_lo, s12                                // 00000000AC44: 8D0C0C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AC48: BF870092
	v_lshlrev_b32_e32 v14, 13, v18                             // 00000000AC4C: 301C248D
	v_or3_b32 v16, v14, v16, 0x7f800000                        // 00000000AC50: D6580010 03FE210E 7F800000
	s_and_not1_saveexec_b32 s12, s12                           // 00000000AC5C: BE8C300C
	s_cbranch_execz 65303                                      // 00000000AC60: BFA5FF17 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x5c0>
	v_bfe_u32 v14, v14, 16, 10                                 // 00000000AC64: D610000E 0229210E
	s_mov_b32 s13, exec_lo                                     // 00000000AC6C: BE8D007E
	v_cmpx_ne_u32_e32 0, v19                                   // 00000000AC70: 7D9A2680
	s_xor_b32 s13, exec_lo, s13                                // 00000000AC74: 8D0D0D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AC78: BF870092
	v_lshlrev_b32_e32 v14, 13, v14                             // 00000000AC7C: 301C1C8D
	v_lshl_or_b32 v14, v19, 23, v14                            // 00000000AC80: D656000E 04392F13
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000AC88: BF870001
	v_add3_u32 v16, v14, v16, 0x38000000                       // 00000000AC8C: D6550010 03FE210E 38000000
	s_and_not1_saveexec_b32 s13, s13                           // 00000000AC98: BE8D300D
	s_cbranch_execz 65286                                      // 00000000AC9C: BFA5FF06 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x5b8>
	s_mov_b32 s28, exec_lo                                     // 00000000ACA0: BE9C007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000ACA4: 7D9A1C80
	s_cbranch_execz 65282                                      // 00000000ACA8: BFA5FF02 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x5b4>
	v_clz_i32_u32_e32 v14, v14                                 // 00000000ACAC: 7E1C730E
	v_or_b32_e32 v16, 0x43000000, v16                          // 00000000ACB0: 382020FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000ACB8: BF870122
	v_xor_b32_e32 v19, 31, v14                                 // 00000000ACBC: 3A261C9F
	v_lshlrev_b32_e32 v14, 23, v14                             // 00000000ACC0: 301C1C97
	v_sub_nc_u32_e32 v19, 9, v19                               // 00000000ACC4: 4C262689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000ACC8: BF870112
	v_sub_nc_u32_e32 v14, v16, v14                             // 00000000ACCC: 4C1C1D10
	v_lshlrev_b32_e32 v18, v19, v18                            // 00000000ACD0: 30242513
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000ACD4: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 00000000ACD8: 3024248E
	v_and_or_b32 v16, 0x7fc000, v18, v14                       // 00000000ACDC: D6570010 043A24FF 007FC000
	s_branch 65266                                             // 00000000ACE8: BFA0FEF2 <_ZN12_GLOBAL__N_117dot_global_kernelEPKjS1_PKiPflllli+0x5b4>
	s_endpgm                                                   // 00000000ACEC: BFB00000
		...

000000000000ad00 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli>:
	s_clause 0x3                                               // 00000000AD00: BF850003
	s_load_b256 s[4:11], s[0:1], 0x20                          // 00000000AD04: F40C0100 F8000020
	s_load_b64 s[12:13], s[0:1], 0x8                           // 00000000AD0C: F4040300 F8000008
	s_load_b64 s[16:17], s[0:1], 0x18                          // 00000000AD14: F4040400 F8000018
	s_load_b64 s[18:19], s[0:1], 0x40                          // 00000000AD1C: F4040480 F8000040
	v_mov_b32_e32 v2, 0                                        // 00000000AD24: 7E040280
	s_mov_b32 s14, 0                                           // 00000000AD28: BE8E0080
	s_mov_b32 s3, exec_lo                                      // 00000000AD2C: BE83007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000AD30: BF8700A1
	v_mov_b32_e32 v1, v2                                       // 00000000AD34: 7E020302
	s_waitcnt lgkmcnt(0)                                       // 00000000AD38: BF89FC07
	v_cmpx_gt_i64_e64 s[10:11], v[0:1]                         // 00000000AD3C: D4D4007E 0002000A
	s_cbranch_execz 304                                        // 00000000AD44: BFA50130 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x508>
	v_cvt_f32_u32_e32 v3, s8                                   // 00000000AD48: 7E060C08
	s_load_b64 s[20:21], s[0:1], 0x10                          // 00000000AD4C: F4040500 F8000010
	v_lshlrev_b32_e32 v5, 2, v0                                // 00000000AD54: 300A0082
	s_mul_i32 s2, s7, s15                                      // 00000000AD58: 96020F07
	s_mul_hi_u32 s23, s6, s15                                  // 00000000AD5C: 96970F06
	v_rcp_iflag_f32_e32 v3, v3                                 // 00000000AD60: 7E065703
	s_mul_i32 s22, s6, s15                                     // 00000000AD64: 96160F06
	s_add_i32 s23, s23, s2                                     // 00000000AD68: 81170217
	s_clause 0x1                                               // 00000000AD6C: BF850001
	s_load_b64 s[26:27], s[0:1], null                          // 00000000AD70: F4040680 F8000000
	s_load_b32 s2, s[0:1], 0x5c                                // 00000000AD78: F4000080 F800005C
	s_lshl_b64 s[22:23], s[22:23], 2                           // 00000000AD80: 84968216
	s_waitcnt_depctr 0xfff                                     // 00000000AD84: BF880FFF
	v_dual_mul_f32 v3, 0x4f7ffffe, v3 :: v_dual_add_nc_u32 v12, 0, v5// 00000000AD88: C8E006FF 030C0A80 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 00000000AD94: BF8704D1
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000AD98: 7E060F03
	s_waitcnt lgkmcnt(0)                                       // 00000000AD9C: BF89FC07
	s_add_u32 s24, s20, s22                                    // 00000000ADA0: 80181614
	s_addc_u32 s25, s21, s23                                   // 00000000ADA4: 82191715
	s_sub_i32 s20, 0, s8                                       // 00000000ADA8: 81940880
	v_mul_lo_u32 v4, s20, v3                                   // 00000000ADAC: D72C0004 00020614
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000ADB4: BF870091
	v_mul_hi_u32 v6, v3, v4                                    // 00000000ADB8: D72D0006 00020903
	v_add_nc_u32_e32 v13, v3, v6                               // 00000000ADC0: 4A1A0D03
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 00000000ADC4: CA100101 07060100
	v_add_co_u32 v4, s20, s26, v5                              // 00000000ADCC: D7001404 00020A1A
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000ADD4: BF870001
	v_add_co_ci_u32_e64 v5, null, s27, 0, s20                  // 00000000ADD8: D5207C05 0051001B
	s_and_b32 s26, s2, 0xffff                                  // 00000000ADE0: 8B1AFF02 0000FFFF
	s_ashr_i32 s20, s9, 31                                     // 00000000ADE8: 86149F09
	s_lshl_b32 s27, s26, 2                                     // 00000000ADEC: 841B821A
	s_branch 19                                                // 00000000ADF0: BFA00013 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x140>
	s_or_b32 exec_lo, exec_lo, s2                              // 00000000ADF4: 8C7E027E
	v_add_co_u32 v6, vcc_lo, v6, s26                           // 00000000ADF8: D7006A06 00003506
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000AE00: BF870001
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000AE04: D5207C07 01AA0E80
	v_add_co_u32 v4, s2, v4, s27                               // 00000000AE0C: D7000204 00003704
	s_waitcnt vmcnt(0)                                         // 00000000AE14: BF8903F7
	ds_store_b32 v12, v3                                       // 00000000AE18: D8340000 0000030C
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 00000000AE20: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s2                    // 00000000AE24: D5207C05 000A0A80
	v_add_nc_u32_e32 v12, s27, v12                             // 00000000AE2C: 4A18181B
	s_or_b32 s14, vcc_lo, s14                                  // 00000000AE30: 8C0E0E6A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000AE34: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s14                       // 00000000AE38: 917E0E7E
	s_cbranch_execz 242                                        // 00000000AE3C: BFA500F2 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x508>
	v_or_b32_e32 v3, s9, v7                                    // 00000000AE40: 38060E09
	s_mov_b32 s2, exec_lo                                      // 00000000AE44: BE82007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000AE48: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000AE4C: 7DBA0480
	s_xor_b32 s28, exec_lo, s2                                 // 00000000AE50: 8D1C027E
	s_cbranch_execz 175                                        // 00000000AE54: BFA500AF <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x414>
	s_add_u32 s22, s8, s20                                     // 00000000AE58: 80161408
	s_mov_b32 s21, s20                                         // 00000000AE5C: BE950014
	s_addc_u32 s23, s9, s20                                    // 00000000AE60: 82171409
	v_ashrrev_i32_e32 v16, 31, v7                              // 00000000AE64: 34200E9F
	s_xor_b64 s[22:23], s[22:23], s[20:21]                     // 00000000AE68: 8D961416
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000AE6C: BF870159
	v_cvt_f32_u32_e32 v3, s22                                  // 00000000AE70: 7E060C16
	v_cvt_f32_u32_e32 v8, s23                                  // 00000000AE74: 7E100C17
	s_sub_u32 s2, 0, s22                                       // 00000000AE78: 80821680
	s_subb_u32 s30, 0, s23                                     // 00000000AE7C: 829E1780
	v_add_co_u32 v9, vcc_lo, v6, v16                           // 00000000AE80: D7006A09 00022106
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 00000000AE88: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AE90: BF870112
	v_xor_b32_e32 v17, v9, v16                                 // 00000000AE94: 3A222109
	v_rcp_f32_e32 v3, v3                                       // 00000000AE98: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000AE9C: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000AEA0: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000AEA8: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 00000000AEAC: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 00000000AEB4: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000AEB8: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 00000000AEBC: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 00000000AEC4: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000AEC8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AECC: BF870112
	v_readfirstlane_b32 s21, v8                                // 00000000AED0: 7E2A0508
	v_readfirstlane_b32 s29, v3                                // 00000000AED4: 7E3A0503
	s_mul_i32 s31, s2, s21                                     // 00000000AED8: 961F1502
	v_add_co_ci_u32_e64 v3, null, v7, v16, vcc_lo              // 00000000AEDC: D5207C03 01AA2107
	s_mul_hi_u32 s34, s2, s29                                  // 00000000AEE4: 96A21D02
	s_mul_i32 s33, s30, s29                                    // 00000000AEE8: 96211D1E
	s_add_i32 s31, s34, s31                                    // 00000000AEEC: 811F1F22
	s_mul_i32 s35, s2, s29                                     // 00000000AEF0: 96231D02
	s_add_i32 s31, s31, s33                                    // 00000000AEF4: 811F211F
	s_mul_hi_u32 s34, s29, s35                                 // 00000000AEF8: 96A2231D
	s_mul_i32 s37, s29, s31                                    // 00000000AEFC: 96251F1D
	s_mul_hi_u32 s36, s21, s35                                 // 00000000AF00: 96A42315
	s_mul_i32 s33, s21, s35                                    // 00000000AF04: 96212315
	s_mul_hi_u32 s35, s29, s31                                 // 00000000AF08: 96A31F1D
	s_add_u32 s34, s34, s37                                    // 00000000AF0C: 80222522
	s_addc_u32 s35, 0, s35                                     // 00000000AF10: 82232380
	s_mul_hi_u32 s38, s21, s31                                 // 00000000AF14: 96A61F15
	s_add_u32 s33, s34, s33                                    // 00000000AF18: 80212122
	s_mul_i32 s31, s21, s31                                    // 00000000AF1C: 961F1F15
	s_addc_u32 s33, s35, s36                                   // 00000000AF20: 82212423
	s_addc_u32 s34, s38, 0                                     // 00000000AF24: 82228026
	s_add_u32 s31, s33, s31                                    // 00000000AF28: 801F1F21
	s_addc_u32 s33, 0, s34                                     // 00000000AF2C: 82212280
	s_add_u32 s29, s29, s31                                    // 00000000AF30: 801D1F1D
	s_cselect_b32 s31, -1, 0                                   // 00000000AF34: 981F80C1
	s_mul_hi_u32 s34, s2, s29                                  // 00000000AF38: 96A21D02
	s_cmp_lg_u32 s31, 0                                        // 00000000AF3C: BF07801F
	s_mul_i32 s31, s2, s29                                     // 00000000AF40: 961F1D02
	s_addc_u32 s21, s21, s33                                   // 00000000AF44: 82152115
	s_mul_i32 s30, s30, s29                                    // 00000000AF48: 961E1D1E
	s_mul_i32 s2, s2, s21                                      // 00000000AF4C: 96021502
	s_mul_hi_u32 s33, s29, s31                                 // 00000000AF50: 96A11F1D
	s_add_i32 s2, s34, s2                                      // 00000000AF54: 81020222
	s_mul_hi_u32 s34, s21, s31                                 // 00000000AF58: 96A21F15
	s_add_i32 s2, s2, s30                                      // 00000000AF5C: 81021E02
	s_mul_i32 s30, s21, s31                                    // 00000000AF60: 961E1F15
	s_mul_i32 s36, s29, s2                                     // 00000000AF64: 9624021D
	s_mul_hi_u32 s35, s29, s2                                  // 00000000AF68: 96A3021D
	s_add_u32 s33, s33, s36                                    // 00000000AF6C: 80212421
	s_addc_u32 s35, 0, s35                                     // 00000000AF70: 82232380
	s_mul_hi_u32 s31, s21, s2                                  // 00000000AF74: 969F0215
	s_add_u32 s30, s33, s30                                    // 00000000AF78: 801E1E21
	s_mul_i32 s2, s21, s2                                      // 00000000AF7C: 96020215
	s_addc_u32 s30, s35, s34                                   // 00000000AF80: 821E2223
	s_addc_u32 s31, s31, 0                                     // 00000000AF84: 821F801F
	s_add_u32 s2, s30, s2                                      // 00000000AF88: 8002021E
	s_addc_u32 s30, 0, s31                                     // 00000000AF8C: 821E1F80
	s_add_u32 s2, s29, s2                                      // 00000000AF90: 8002021D
	s_cselect_b32 s29, -1, 0                                   // 00000000AF94: 981D80C1
	v_xor_b32_e32 v3, v3, v16                                  // 00000000AF98: 3A062103
	s_cmp_lg_u32 s29, 0                                        // 00000000AF9C: BF07801D
	v_mul_hi_u32 v18, v17, s2                                  // 00000000AFA0: D72D0012 00000511
	s_addc_u32 s21, s21, s30                                   // 00000000AFA8: 82151E15
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000AFAC: BF8701B9
	v_mad_u64_u32 v[8:9], null, v17, s21, 0                    // 00000000AFB0: D6FE7C08 02002B11
	v_mad_u64_u32 v[10:11], null, v3, s2, 0                    // 00000000AFB8: D6FE7C0A 02000503
	v_mad_u64_u32 v[14:15], null, v3, s21, 0                   // 00000000AFC0: D6FE7C0E 02002B03
	v_add_co_u32 v8, vcc_lo, v18, v8                           // 00000000AFC8: D7006A08 00021112
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AFD0: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000AFD4: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 00000000AFDC: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000AFE4: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 00000000AFE8: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v15, vcc_lo             // 00000000AFEC: 40121E80
	v_add_co_u32 v10, vcc_lo, v8, v14                          // 00000000AFF0: D7006A0A 00021D08
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000AFF8: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 00000000AFFC: D5207C0B 01AA1280
	v_mul_lo_u32 v14, s23, v10                                 // 00000000B004: D72C000E 00021417
	v_mad_u64_u32 v[8:9], null, s22, v10, 0                    // 00000000B00C: D6FE7C08 02021416
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B014: BF870113
	v_mul_lo_u32 v15, s22, v11                                 // 00000000B018: D72C000F 00021616
	v_sub_co_u32 v8, vcc_lo, v17, v8                           // 00000000B020: D7016A08 00021111
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000B028: BF8700A2
	v_add3_u32 v9, v9, v15, v14                                // 00000000B02C: D6550009 043A1F09
	v_add_co_u32 v15, s2, v10, 2                               // 00000000B034: D700020F 0001050A
	v_add_co_ci_u32_e64 v17, null, 0, v11, s2                  // 00000000B03C: D5207C11 000A1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000B044: BF8701B3
	v_sub_nc_u32_e32 v14, v3, v9                               // 00000000B048: 4C1C1303
	v_sub_co_u32 v18, s2, v8, s22                              // 00000000B04C: D7010212 00002D08
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 00000000B054: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v14, null, s23, v14, vcc_lo         // 00000000B05C: D5227C0E 01AA1C17
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B064: BF870113
	v_cmp_le_u32_e32 vcc_lo, s22, v18                          // 00000000B068: 7C962416
	v_subrev_co_ci_u32_e64 v14, null, 0, v14, s2               // 00000000B06C: D5227C0E 000A1C80
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 00000000B074: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000B07C: BF870002
	v_cmp_le_u32_e32 vcc_lo, s23, v14                          // 00000000B080: 7C961C17
	v_cndmask_b32_e64 v18, 0, -1, vcc_lo                       // 00000000B084: D5010012 01A98280
	v_cmp_le_u32_e32 vcc_lo, s22, v8                           // 00000000B08C: 7C961016
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 00000000B090: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s23, v3                           // 00000000B098: 7C960617
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 00000000B09C: D5010013 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s23, v14                          // 00000000B0A4: 7C941C17
	v_cndmask_b32_e32 v9, v18, v9, vcc_lo                      // 00000000B0A8: 02121312
	v_add_co_u32 v14, vcc_lo, v10, 1                           // 00000000B0AC: D7006A0E 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000B0B4: BF8701D1
	v_add_co_ci_u32_e64 v18, null, 0, v11, vcc_lo              // 00000000B0B8: D5207C12 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s23, v3                           // 00000000B0C0: 7C940617
	v_cndmask_b32_e32 v3, v19, v8, vcc_lo                      // 00000000B0C4: 02061113
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 00000000B0C8: 7C9A1280
	v_xor_b32_e32 v9, s20, v16                                 // 00000000B0CC: 3A122014
	v_cmp_ne_u32_e64 s2, 0, v3                                 // 00000000B0D0: D44D0002 00020680
	v_cndmask_b32_e32 v3, v14, v15, vcc_lo                     // 00000000B0D8: 02061F0E
	v_cndmask_b32_e32 v8, v18, v17, vcc_lo                     // 00000000B0DC: 02102312
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B0E0: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s2                          // 00000000B0E4: D5010003 000A070A
	v_cndmask_b32_e64 v8, v11, v8, s2                          // 00000000B0EC: D5010008 000A110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B0F4: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 00000000B0F8: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 00000000B0FC: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B100: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 00000000B104: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 00000000B10C: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s2, s28                            // 00000000B114: BE82301C
	s_cbranch_execz 18                                         // 00000000B118: BFA50012 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x464>
	v_mul_hi_u32 v3, v6, v13                                   // 00000000B11C: D72D0003 00021B06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B124: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 00000000B128: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 00000000B130: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B134: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 00000000B138: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000B13C: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 00000000B140: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B148: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 00000000B14C: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000B150: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B154: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 00000000B158: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 00000000B15C: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s2                              // 00000000B164: 8C7E027E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B168: BF870121
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 00000000B16C: D73C0008 00021082
	v_mov_b32_e32 v3, 0                                        // 00000000B174: 7E060280
	v_add_co_u32 v10, vcc_lo, s24, v8                          // 00000000B178: D7006A0A 00021018
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000B180: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s25, v9, vcc_lo             // 00000000B184: D5207C0B 01AA1219
	global_load_b32 v10, v[10:11], off                         // 00000000B18C: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 00000000B194: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 00000000B198: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 00000000B19C: 7CA214C1
	v_cmp_gt_i64_e64 s2, s[4:5], v[10:11]                      // 00000000B1A0: D4540002 00021404
	s_and_b32 s21, vcc_lo, s2                                  // 00000000B1A8: 8B15026A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B1AC: BF870009
	s_and_saveexec_b32 s2, s21                                 // 00000000B1B0: BE822015
	s_cbranch_execz 65295                                      // 00000000B1B4: BFA5FF0F <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xf4>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 00000000B1B8: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B1C0: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 00000000B1C4: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 00000000B1CC: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B1D4: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 00000000B1D8: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 00000000B1E0: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 00000000B1E8: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B1F0: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 00000000B1F4: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 00000000B1FC: DC520000 037C0008
	s_branch 65275                                             // 00000000B204: BFA0FEFB <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xf4>
	s_or_b32 exec_lo, exec_lo, s3                              // 00000000B208: 8C7E037E
	s_mul_i32 s2, s18, s7                                      // 00000000B20C: 96020712
	s_mul_hi_u32 s3, s18, s6                                   // 00000000B210: 96830612
	s_mul_i32 s4, s19, s6                                      // 00000000B214: 96040613
	s_add_i32 s2, s3, s2                                       // 00000000B218: 81020203
	s_waitcnt lgkmcnt(0)                                       // 00000000B21C: BF89FC07
	s_add_i32 s3, s2, s4                                       // 00000000B220: 81030402
	s_mul_i32 s2, s18, s6                                      // 00000000B224: 96020612
	s_barrier                                                  // 00000000B228: BFBD0000
	buffer_gl0_inv                                             // 00000000B22C: E0AC0000 00000000
	s_mov_b32 s4, exec_lo                                      // 00000000B234: BE84007E
	v_cmpx_gt_i64_e64 s[2:3], v[0:1]                           // 00000000B238: D4D4007E 00020002
	s_cbranch_execz 577                                        // 00000000B240: BFA50241 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xe48>
	v_cvt_f32_u32_e32 v2, s6                                   // 00000000B244: 7E040C06
	s_load_b32 s4, s[0:1], 0x48                                // 00000000B248: F4000100 F8000048
	s_mul_i32 s5, s19, s15                                     // 00000000B250: 96050F13
	s_mul_hi_u32 s10, s18, s15                                 // 00000000B254: 968A0F12
	s_load_b32 s0, s[0:1], 0x5c                                // 00000000B258: F4000000 F800005C
	v_rcp_iflag_f32_e32 v2, v2                                 // 00000000B260: 7E045702
	s_add_i32 s5, s10, s5                                      // 00000000B264: 8105050A
	v_cmp_gt_i64_e64 s20, s[8:9], 0                            // 00000000B268: D4540014 00010008
	s_mul_i32 s18, s18, s15                                    // 00000000B270: 96120F12
	s_mov_b32 s24, 0                                           // 00000000B274: BE980080
	s_waitcnt_depctr 0xfff                                     // 00000000B278: BF880FFF
	v_mul_f32_e32 v2, 0x4f7ffffe, v2                           // 00000000B27C: 100404FF 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B284: BF870001
	v_cvt_u32_f32_e32 v3, v2                                   // 00000000B288: 7E060F02
	s_waitcnt lgkmcnt(0)                                       // 00000000B28C: BF89FC07
	s_cmp_eq_u32 s4, 0                                         // 00000000B290: BF068004
	s_mov_b32 s4, 0                                            // 00000000B294: BE840080
	s_cselect_b32 s19, -1, 0                                   // 00000000B298: 981380C1
	s_sub_i32 s1, 0, s6                                        // 00000000B29C: 81810680
	s_and_b32 s21, s0, 0xffff                                  // 00000000B2A0: 8B15FF00 0000FFFF
	v_mul_lo_u32 v2, s1, v3                                    // 00000000B2A8: D72C0002 00020601
	s_lshl_b32 s22, s8, 2                                      // 00000000B2B0: 84168208
	s_sub_u32 s23, 0, s6                                       // 00000000B2B4: 80970680
	s_ashr_i32 s10, s7, 31                                     // 00000000B2B8: 860A9F07
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B2BC: BF870121
	v_mul_hi_u32 v4, v3, v2                                    // 00000000B2C0: D72D0004 00020503
	v_mov_b32_e32 v2, 0                                        // 00000000B2C8: 7E040280
	v_add_nc_u32_e32 v8, v3, v4                                // 00000000B2CC: 4A100903
	s_branch 48                                                // 00000000B2D0: BFA00030 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x694>
	v_mov_b32_e32 v9, 0                                        // 00000000B2D4: 7E120280
	v_mul_lo_u32 v12, v4, s6                                   // 00000000B2D8: D72C000C 00000D04
	v_mul_lo_u32 v13, v3, s7                                   // 00000000B2E0: D72C000D 00000F03
	v_mad_u64_u32 v[4:5], null, v3, s6, 0                      // 00000000B2E8: D6FE7C04 02000D03
	v_mul_lo_u32 v3, v11, s6                                   // 00000000B2F0: D72C0003 00000D0B
	v_mul_lo_u32 v11, v10, s7                                  // 00000000B2F8: D72C000B 00000F0A
	v_mad_u64_u32 v[6:7], null, v10, s6, 0                     // 00000000B300: D6FE7C06 02000D0A
	s_delay_alu instid0(VALU_DEP_4) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B308: BF870114
	v_add3_u32 v5, v5, v13, v12                                // 00000000B30C: D6550005 04321B05
	v_add3_u32 v7, v7, v11, v3                                 // 00000000B314: D6550007 040E1707
	v_sub_co_u32 v3, vcc_lo, v0, v4                            // 00000000B31C: D7016A03 00020900
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000B324: BF870191
	v_sub_co_ci_u32_e64 v4, null, v1, v5, vcc_lo               // 00000000B328: D5217C04 01AA0B01
	v_lshlrev_b64 v[5:6], 2, v[6:7]                            // 00000000B330: D73C0005 00020C82
	v_add_co_u32 v0, vcc_lo, v0, s21                           // 00000000B338: D7006A00 00002B00
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_4)// 00000000B340: BF870223
	v_lshlrev_b64 v[3:4], 2, v[3:4]                            // 00000000B344: D73C0003 00020682
	v_add_co_ci_u32_e64 v1, null, 0, v1, vcc_lo                // 00000000B34C: D5207C01 01AA0280
	v_add_co_u32 v5, vcc_lo, s16, v5                           // 00000000B354: D7006A05 00020A10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000B35C: BF870191
	v_add_co_ci_u32_e64 v6, null, s17, v6, vcc_lo              // 00000000B360: D5207C06 01AA0C11
	v_cmp_le_i64_e32 vcc_lo, s[2:3], v[0:1]                    // 00000000B368: 7CA60002
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B36C: BF870093
	v_add_co_u32 v3, s0, v5, v3                                // 00000000B370: D7000003 00020705
	v_add_co_ci_u32_e64 v4, null, v6, v4, s0                   // 00000000B378: D5207C04 00020906
	s_or_b32 s24, vcc_lo, s24                                  // 00000000B380: 8C18186A
	global_store_b32 v[3:4], v9, off                           // 00000000B384: DC6A0000 007C0903
	s_and_not1_b32 exec_lo, exec_lo, s24                       // 00000000B38C: 917E187E
	s_cbranch_execz 493                                        // 00000000B390: BFA501ED <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xe48>
	v_or_b32_e32 v3, s7, v1                                    // 00000000B394: 38060207
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000B398: BF8704A1
	v_cmp_ne_u64_e32 vcc_lo, 0, v[2:3]                         // 00000000B39C: 7CBA0480
	s_and_saveexec_b32 s0, vcc_lo                              // 00000000B3A0: BE80206A
	s_xor_b32 s1, exec_lo, s0                                  // 00000000B3A4: 8D01007E
	s_cbranch_execz 174                                        // 00000000B3A8: BFA500AE <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x964>
	s_add_u32 s14, s6, s10                                     // 00000000B3AC: 800E0A06
	s_mov_b32 s11, s10                                         // 00000000B3B0: BE8B000A
	s_addc_u32 s15, s7, s10                                    // 00000000B3B4: 820F0A07
	v_ashrrev_i32_e32 v7, 31, v1                               // 00000000B3B8: 340E029F
	s_xor_b64 s[14:15], s[14:15], s[10:11]                     // 00000000B3BC: 8D8E0A0E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000B3C0: BF870159
	v_cvt_f32_u32_e32 v3, s14                                  // 00000000B3C4: 7E060C0E
	v_cvt_f32_u32_e32 v4, s15                                  // 00000000B3C8: 7E080C0F
	s_sub_u32 s0, 0, s14                                       // 00000000B3CC: 80800E80
	s_subb_u32 s26, 0, s15                                     // 00000000B3D0: 829A0F80
	v_add_co_u32 v5, vcc_lo, v0, v7                            // 00000000B3D4: D7006A05 00020F00
	v_fmac_f32_e32 v3, 0x4f800000, v4                          // 00000000B3DC: 560608FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B3E4: BF870112
	v_xor_b32_e32 v11, v5, v7                                  // 00000000B3E8: 3A160F05
	v_rcp_f32_e32 v3, v3                                       // 00000000B3EC: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000B3F0: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000B3F4: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B3FC: BF870091
	v_mul_f32_e32 v4, 0x2f800000, v3                           // 00000000B400: 100806FF 2F800000
	v_trunc_f32_e32 v4, v4                                     // 00000000B408: 7E084304
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B40C: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v4                          // 00000000B410: 560608FF CF800000
	v_cvt_u32_f32_e32 v4, v4                                   // 00000000B418: 7E080F04
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000B41C: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B420: BF870112
	v_readfirstlane_b32 s11, v4                                // 00000000B424: 7E160504
	v_readfirstlane_b32 s25, v3                                // 00000000B428: 7E320503
	s_mul_i32 s27, s0, s11                                     // 00000000B42C: 961B0B00
	v_add_co_ci_u32_e64 v3, null, v1, v7, vcc_lo               // 00000000B430: D5207C03 01AA0F01
	s_mul_hi_u32 s29, s0, s25                                  // 00000000B438: 969D1900
	s_mul_i32 s28, s26, s25                                    // 00000000B43C: 961C191A
	s_add_i32 s27, s29, s27                                    // 00000000B440: 811B1B1D
	s_mul_i32 s30, s0, s25                                     // 00000000B444: 961E1900
	s_add_i32 s27, s27, s28                                    // 00000000B448: 811B1C1B
	s_mul_hi_u32 s29, s25, s30                                 // 00000000B44C: 969D1E19
	s_mul_i32 s33, s25, s27                                    // 00000000B450: 96211B19
	s_mul_hi_u32 s31, s11, s30                                 // 00000000B454: 969F1E0B
	s_mul_i32 s28, s11, s30                                    // 00000000B458: 961C1E0B
	s_mul_hi_u32 s30, s25, s27                                 // 00000000B45C: 969E1B19
	s_add_u32 s29, s29, s33                                    // 00000000B460: 801D211D
	s_addc_u32 s30, 0, s30                                     // 00000000B464: 821E1E80
	s_mul_hi_u32 s34, s11, s27                                 // 00000000B468: 96A21B0B
	s_add_u32 s28, s29, s28                                    // 00000000B46C: 801C1C1D
	s_mul_i32 s27, s11, s27                                    // 00000000B470: 961B1B0B
	s_addc_u32 s28, s30, s31                                   // 00000000B474: 821C1F1E
	s_addc_u32 s29, s34, 0                                     // 00000000B478: 821D8022
	s_add_u32 s27, s28, s27                                    // 00000000B47C: 801B1B1C
	s_addc_u32 s28, 0, s29                                     // 00000000B480: 821C1D80
	s_add_u32 s25, s25, s27                                    // 00000000B484: 80191B19
	s_cselect_b32 s27, -1, 0                                   // 00000000B488: 981B80C1
	s_mul_hi_u32 s29, s0, s25                                  // 00000000B48C: 969D1900
	s_cmp_lg_u32 s27, 0                                        // 00000000B490: BF07801B
	s_mul_i32 s27, s0, s25                                     // 00000000B494: 961B1900
	s_addc_u32 s11, s11, s28                                   // 00000000B498: 820B1C0B
	s_mul_i32 s26, s26, s25                                    // 00000000B49C: 961A191A
	s_mul_i32 s0, s0, s11                                      // 00000000B4A0: 96000B00
	s_mul_hi_u32 s28, s25, s27                                 // 00000000B4A4: 969C1B19
	s_add_i32 s0, s29, s0                                      // 00000000B4A8: 8100001D
	s_mul_hi_u32 s29, s11, s27                                 // 00000000B4AC: 969D1B0B
	s_add_i32 s0, s0, s26                                      // 00000000B4B0: 81001A00
	s_mul_i32 s26, s11, s27                                    // 00000000B4B4: 961A1B0B
	s_mul_i32 s31, s25, s0                                     // 00000000B4B8: 961F0019
	s_mul_hi_u32 s30, s25, s0                                  // 00000000B4BC: 969E0019
	s_add_u32 s28, s28, s31                                    // 00000000B4C0: 801C1F1C
	s_addc_u32 s30, 0, s30                                     // 00000000B4C4: 821E1E80
	s_mul_hi_u32 s27, s11, s0                                  // 00000000B4C8: 969B000B
	s_add_u32 s26, s28, s26                                    // 00000000B4CC: 801A1A1C
	s_mul_i32 s0, s11, s0                                      // 00000000B4D0: 9600000B
	s_addc_u32 s26, s30, s29                                   // 00000000B4D4: 821A1D1E
	s_addc_u32 s27, s27, 0                                     // 00000000B4D8: 821B801B
	s_add_u32 s0, s26, s0                                      // 00000000B4DC: 8000001A
	s_addc_u32 s26, 0, s27                                     // 00000000B4E0: 821A1B80
	s_add_u32 s0, s25, s0                                      // 00000000B4E4: 80000019
	s_cselect_b32 s25, -1, 0                                   // 00000000B4E8: 981980C1
	v_xor_b32_e32 v12, v3, v7                                  // 00000000B4EC: 3A180F03
	s_cmp_lg_u32 s25, 0                                        // 00000000B4F0: BF078019
	v_mul_hi_u32 v13, v11, s0                                  // 00000000B4F4: D72D000D 0000010B
	s_addc_u32 s11, s11, s26                                   // 00000000B4FC: 820B1A0B
	v_xor_b32_e32 v7, s10, v7                                  // 00000000B500: 3A0E0E0A
	v_mad_u64_u32 v[3:4], null, v11, s11, 0                    // 00000000B504: D6FE7C03 0200170B
	v_mad_u64_u32 v[5:6], null, v12, s0, 0                     // 00000000B50C: D6FE7C05 0200010C
	v_mad_u64_u32 v[9:10], null, v12, s11, 0                   // 00000000B514: D6FE7C09 0200170C
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B51C: BF870093
	v_add_co_u32 v3, vcc_lo, v13, v3                           // 00000000B520: D7006A03 0002070D
	v_add_co_ci_u32_e64 v4, null, 0, v4, vcc_lo                // 00000000B528: D5207C04 01AA0880
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B530: BF870112
	v_add_co_u32 v3, vcc_lo, v3, v5                            // 00000000B534: D7006A03 00020B03
	v_add_co_ci_u32_e32 v3, vcc_lo, v4, v6, vcc_lo             // 00000000B53C: 40060D04
	v_add_co_ci_u32_e32 v4, vcc_lo, 0, v10, vcc_lo             // 00000000B540: 40081480
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B544: BF870092
	v_add_co_u32 v5, vcc_lo, v3, v9                            // 00000000B548: D7006A05 00021303
	v_add_co_ci_u32_e64 v6, null, 0, v4, vcc_lo                // 00000000B550: D5207C06 01AA0880
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000B558: BF8701A2
	v_mul_lo_u32 v9, s15, v5                                   // 00000000B55C: D72C0009 00020A0F
	v_mad_u64_u32 v[3:4], null, s14, v5, 0                     // 00000000B564: D6FE7C03 02020A0E
	v_mul_lo_u32 v10, s14, v6                                  // 00000000B56C: D72C000A 00020C0E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B574: BF870112
	v_sub_co_u32 v3, vcc_lo, v11, v3                           // 00000000B578: D7016A03 0002070B
	v_add3_u32 v4, v4, v10, v9                                 // 00000000B580: D6550004 04261504
	v_add_co_u32 v10, s0, v5, 2                                // 00000000B588: D700000A 00010505
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000B590: BF870191
	v_add_co_ci_u32_e64 v11, null, 0, v6, s0                   // 00000000B594: D5207C0B 00020C80
	v_sub_nc_u32_e32 v9, v12, v4                               // 00000000B59C: 4C12090C
	v_sub_co_u32 v13, s0, v3, s14                              // 00000000B5A0: D701000D 00001D03
	v_sub_co_ci_u32_e64 v4, null, v12, v4, vcc_lo              // 00000000B5A8: D5217C04 01AA090C
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000B5B0: BF870193
	v_subrev_co_ci_u32_e64 v9, null, s15, v9, vcc_lo           // 00000000B5B4: D5227C09 01AA120F
	v_cmp_le_u32_e32 vcc_lo, s14, v13                          // 00000000B5BC: 7C961A0E
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B5C0: BF870122
	v_subrev_co_ci_u32_e64 v9, null, 0, v9, s0                 // 00000000B5C4: D5227C09 00021280
	v_cndmask_b32_e64 v12, 0, -1, vcc_lo                       // 00000000B5CC: D501000C 01A98280
	v_cmp_le_u32_e32 vcc_lo, s15, v9                           // 00000000B5D4: 7C96120F
	v_cndmask_b32_e64 v13, 0, -1, vcc_lo                       // 00000000B5D8: D501000D 01A98280
	v_cmp_le_u32_e32 vcc_lo, s14, v3                           // 00000000B5E0: 7C96060E
	v_cndmask_b32_e64 v3, 0, -1, vcc_lo                        // 00000000B5E4: D5010003 01A98280
	v_cmp_le_u32_e32 vcc_lo, s15, v4                           // 00000000B5EC: 7C96080F
	v_cndmask_b32_e64 v14, 0, -1, vcc_lo                       // 00000000B5F0: D501000E 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s15, v9                           // 00000000B5F8: 7C94120F
	v_cndmask_b32_e32 v9, v13, v12, vcc_lo                     // 00000000B5FC: 0212190D
	v_add_co_u32 v12, vcc_lo, v5, 1                            // 00000000B600: D7006A0C 00010305
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_2)// 00000000B608: BF870141
	v_add_co_ci_u32_e64 v13, null, 0, v6, vcc_lo               // 00000000B60C: D5207C0D 01AA0C80
	v_cmp_eq_u32_e32 vcc_lo, s15, v4                           // 00000000B614: 7C94080F
	v_cndmask_b32_e32 v3, v14, v3, vcc_lo                      // 00000000B618: 0206070E
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 00000000B61C: 7C9A1280
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 00000000B620: D44D0000 00020680
	v_dual_cndmask_b32 v3, v12, v10 :: v_dual_cndmask_b32 v4, v13, v11// 00000000B628: CA52150C 0304170D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B630: BF870111
	v_cndmask_b32_e64 v3, v5, v3, s0                           // 00000000B634: D5010003 00020705
	v_cndmask_b32_e64 v4, v6, v4, s0                           // 00000000B63C: D5010004 00020906
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B644: BF870112
	v_xor_b32_e32 v3, v3, v7                                   // 00000000B648: 3A060F03
	v_xor_b32_e32 v4, v4, v7                                   // 00000000B64C: 3A080F04
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B650: BF870092
	v_sub_co_u32 v3, vcc_lo, v3, v7                            // 00000000B654: D7016A03 00020F03
	v_sub_co_ci_u32_e64 v4, null, v4, v7, vcc_lo               // 00000000B65C: D5217C04 01AA0F04
	s_and_not1_saveexec_b32 s0, s1                             // 00000000B664: BE803001
	s_cbranch_execz 18                                         // 00000000B668: BFA50012 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x9b4>
	v_mul_hi_u32 v3, v0, v8                                    // 00000000B66C: D72D0003 00021100
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B674: BF870091
	v_mul_lo_u32 v4, v3, s6                                    // 00000000B678: D72C0004 00000D03
	v_sub_nc_u32_e32 v4, v0, v4                                // 00000000B680: 4C080900
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B684: BF870121
	v_subrev_nc_u32_e32 v6, s6, v4                             // 00000000B688: 4E0C0806
	v_cmp_le_u32_e32 vcc_lo, s6, v4                            // 00000000B68C: 7C960806
	v_dual_cndmask_b32 v4, v4, v6 :: v_dual_add_nc_u32 v5, 1, v3// 00000000B690: CA600D04 04040681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B698: BF870111
	v_cndmask_b32_e32 v3, v3, v5, vcc_lo                       // 00000000B69C: 02060B03
	v_cmp_le_u32_e32 vcc_lo, s6, v4                            // 00000000B6A0: 7C960806
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B6A4: BF870092
	v_dual_mov_b32 v4, v2 :: v_dual_add_nc_u32 v5, 1, v3       // 00000000B6A8: CA200102 04040681
	v_cndmask_b32_e32 v3, v3, v5, vcc_lo                       // 00000000B6B0: 02060B03
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000B6B4: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B6B8: BF870091
	v_add_co_u32 v10, vcc_lo, v3, s18                          // 00000000B6BC: D7006A0A 00002503
	v_add_co_ci_u32_e64 v11, null, s5, v4, vcc_lo              // 00000000B6C4: D5207C0B 01AA0805
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000B6CC: 916A147E
	s_cbranch_vccnz 65280                                      // 00000000B6D0: BFA4FF00 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x5d4>
	v_mul_lo_u32 v7, v11, s8                                   // 00000000B6D4: D72C0007 0000110B
	v_mul_lo_u32 v9, v10, s9                                   // 00000000B6DC: D72C0009 0000130A
	v_mad_u64_u32 v[5:6], null, v10, s8, 0                     // 00000000B6E4: D6FE7C05 0200110A
	v_mad_u64_u32 v[12:13], null, s23, v3, v[0:1]              // 00000000B6EC: D6FE7C0C 04020617
	s_mov_b64 s[0:1], s[8:9]                                   // 00000000B6F4: BE800108
	v_add3_u32 v6, v6, v9, v7                                  // 00000000B6F8: D6550006 041E1306
	v_mov_b32_e32 v9, 0                                        // 00000000B700: 7E120280
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B704: BF870122
	v_lshlrev_b64 v[13:14], 2, v[5:6]                          // 00000000B708: D73C000D 00020A82
	v_mad_u64_u32 v[5:6], null, s22, v12, s[4:5]               // 00000000B710: D6FE7C05 00121816
	v_add_co_u32 v6, vcc_lo, s12, v13                          // 00000000B718: D7006A06 00021A0C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B720: BF870001
	v_add_co_ci_u32_e64 v7, null, s13, v14, vcc_lo             // 00000000B724: D5207C07 01AA1C0D
	s_branch 19                                                // 00000000B72C: BFA00013 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa7c>
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000B730: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B734: BF870009
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000B738: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B73C: BF870009
	s_or_b32 exec_lo, exec_lo, s11                             // 00000000B740: 8C7E0B7E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B744: BF870001
	v_mul_f32_e32 v13, v16, v15                                // 00000000B748: 101A1F10
	v_add_co_u32 v6, vcc_lo, v6, 4                             // 00000000B74C: D7006A06 00010906
	s_add_u32 s0, s0, -1                                       // 00000000B754: 8000C100
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000B758: D5207C07 01AA0E80
	v_fmac_f32_e32 v13, v12, v14                               // 00000000B760: 561A1D0C
	v_add_nc_u32_e32 v5, 4, v5                                 // 00000000B764: 4A0A0A84
	s_addc_u32 s1, s1, -1                                      // 00000000B768: 8201C101
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B76C: BF870119
	s_cmp_eq_u64 s[0:1], 0                                     // 00000000B770: BF108000
	v_add_f32_e32 v9, v9, v13                                  // 00000000B774: 06121B09
	s_cbranch_scc1 65239                                       // 00000000B778: BFA2FED7 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0x5d8>
	global_load_b32 v13, v[6:7], off                           // 00000000B77C: DC520000 0D7C0006
	ds_load_b32 v15, v5                                        // 00000000B784: D8D80000 0F000005
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B78C: 916A137E
	s_waitcnt lgkmcnt(0)                                       // 00000000B790: BF89FC07
	v_lshlrev_b32_e32 v12, 16, v15                             // 00000000B794: 30181E90
	s_cbranch_vccz 13                                          // 00000000B798: BFA3000D <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xad0>
	s_waitcnt vmcnt(0)                                         // 00000000B79C: BF8903F7
	v_lshlrev_b32_e32 v14, 16, v13                             // 00000000B7A0: 301C1A90
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B7A4: 916A137E
	s_cbranch_vccz 68                                          // 00000000B7A8: BFA30044 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xbbc>
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B7AC: 916A137E
	s_cbranch_vccz 123                                         // 00000000B7B0: BFA3007B <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xca0>
	v_and_b32_e32 v16, 0xffff0000, v15                         // 00000000B7B4: 36201EFF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B7BC: 916A137E
	s_cbranch_vccz 175                                         // 00000000B7C0: BFA300AF <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xd80>
	v_and_b32_e32 v15, 0xffff0000, v13                         // 00000000B7C4: 361E1AFF FFFF0000
	s_branch 65501                                             // 00000000B7CC: BFA0FFDD <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa44>
	v_bfe_u32 v14, v15, 10, 5                                  // 00000000B7D0: D610000E 0215150F
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B7D8: BF870122
	v_and_b32_e32 v12, 0x80000000, v12                         // 00000000B7DC: 361818FF 80000000
	s_mov_b32 s11, exec_lo                                     // 00000000B7E4: BE8B007E
	v_cmpx_lt_i32_e32 30, v14                                  // 00000000B7E8: 7D821C9E
	s_xor_b32 s11, exec_lo, s11                                // 00000000B7EC: 8D0B0B7E
	v_lshlrev_b32_e32 v14, 13, v15                             // 00000000B7F0: 301C1E8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B7F4: BF870091
	v_and_b32_e32 v14, 0x7fe000, v14                           // 00000000B7F8: 361C1CFF 007FE000
	v_or3_b32 v12, v14, v12, 0x7f800000                        // 00000000B800: D658000C 03FE190E 7F800000
	s_and_not1_saveexec_b32 s11, s11                           // 00000000B80C: BE8B300B
	s_cbranch_execz 36                                         // 00000000B810: BFA50024 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xba4>
	v_and_b32_e32 v16, 0x3ff, v15                              // 00000000B814: 36201EFF 000003FF
	s_mov_b32 s14, exec_lo                                     // 00000000B81C: BE8E007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000B820: 7D9A1C80
	s_xor_b32 s14, exec_lo, s14                                // 00000000B824: 8D0E0E7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B828: BF870092
	v_lshlrev_b32_e32 v16, 13, v16                             // 00000000B82C: 3020208D
	v_lshl_or_b32 v14, v14, 23, v16                            // 00000000B830: D656000E 04412F0E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B838: BF870001
	v_add3_u32 v12, v14, v12, 0x38000000                       // 00000000B83C: D655000C 03FE190E 38000000
	s_and_not1_saveexec_b32 s14, s14                           // 00000000B848: BE8E300E
	s_cbranch_execz 19                                         // 00000000B84C: BFA50013 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xb9c>
	s_mov_b32 s15, exec_lo                                     // 00000000B850: BE8F007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000B854: 7D9A2080
	s_cbranch_execz 15                                         // 00000000B858: BFA5000F <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xb98>
	v_clz_i32_u32_e32 v14, v16                                 // 00000000B85C: 7E1C7310
	v_or_b32_e32 v12, 0x43000000, v12                          // 00000000B860: 381818FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B868: BF870122
	v_xor_b32_e32 v16, 31, v14                                 // 00000000B86C: 3A201C9F
	v_lshlrev_b32_e32 v14, 23, v14                             // 00000000B870: 301C1C97
	v_sub_nc_u32_e32 v16, 9, v16                               // 00000000B874: 4C202089
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B878: BF870112
	v_sub_nc_u32_e32 v12, v12, v14                             // 00000000B87C: 4C181D0C
	v_lshlrev_b32_e32 v16, v16, v15                            // 00000000B880: 30201F10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B884: BF870091
	v_lshlrev_b32_e32 v16, 14, v16                             // 00000000B888: 3020208E
	v_and_or_b32 v12, 0x7fc000, v16, v12                       // 00000000B88C: D657000C 043220FF 007FC000
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000B898: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B89C: BF870009
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000B8A0: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B8A4: BF870009
	s_or_b32 exec_lo, exec_lo, s11                             // 00000000B8A8: 8C7E0B7E
	s_waitcnt vmcnt(0)                                         // 00000000B8AC: BF8903F7
	v_lshlrev_b32_e32 v14, 16, v13                             // 00000000B8B0: 301C1A90
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B8B4: 916A137E
	s_cbranch_vccnz 65468                                      // 00000000B8B8: BFA4FFBC <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xaac>
	v_bfe_u32 v16, v13, 10, 5                                  // 00000000B8BC: D6100010 0215150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B8C4: BF870122
	v_and_b32_e32 v14, 0x80000000, v14                         // 00000000B8C8: 361C1CFF 80000000
	s_mov_b32 s11, exec_lo                                     // 00000000B8D0: BE8B007E
	v_cmpx_lt_i32_e32 30, v16                                  // 00000000B8D4: 7D82209E
	s_xor_b32 s11, exec_lo, s11                                // 00000000B8D8: 8D0B0B7E
	v_lshlrev_b32_e32 v16, 13, v13                             // 00000000B8DC: 30201A8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B8E0: BF870091
	v_and_b32_e32 v16, 0x7fe000, v16                           // 00000000B8E4: 362020FF 007FE000
	v_or3_b32 v14, v16, v14, 0x7f800000                        // 00000000B8EC: D658000E 03FE1D10 7F800000
	s_and_not1_saveexec_b32 s11, s11                           // 00000000B8F8: BE8B300B
	s_cbranch_execz 36                                         // 00000000B8FC: BFA50024 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xc90>
	v_and_b32_e32 v17, 0x3ff, v13                              // 00000000B900: 36221AFF 000003FF
	s_mov_b32 s14, exec_lo                                     // 00000000B908: BE8E007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000B90C: 7D9A2080
	s_xor_b32 s14, exec_lo, s14                                // 00000000B910: 8D0E0E7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B914: BF870092
	v_lshlrev_b32_e32 v17, 13, v17                             // 00000000B918: 3022228D
	v_lshl_or_b32 v16, v16, 23, v17                            // 00000000B91C: D6560010 04452F10
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000B924: BF870001
	v_add3_u32 v14, v16, v14, 0x38000000                       // 00000000B928: D655000E 03FE1D10 38000000
	s_and_not1_saveexec_b32 s14, s14                           // 00000000B934: BE8E300E
	s_cbranch_execz 19                                         // 00000000B938: BFA50013 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xc88>
	s_mov_b32 s15, exec_lo                                     // 00000000B93C: BE8F007E
	v_cmpx_ne_u32_e32 0, v17                                   // 00000000B940: 7D9A2280
	s_cbranch_execz 15                                         // 00000000B944: BFA5000F <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xc84>
	v_clz_i32_u32_e32 v16, v17                                 // 00000000B948: 7E207311
	v_or_b32_e32 v14, 0x43000000, v14                          // 00000000B94C: 381C1CFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000B954: BF870122
	v_xor_b32_e32 v17, 31, v16                                 // 00000000B958: 3A22209F
	v_lshlrev_b32_e32 v16, 23, v16                             // 00000000B95C: 30202097
	v_sub_nc_u32_e32 v17, 9, v17                               // 00000000B960: 4C222289
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000B964: BF870112
	v_sub_nc_u32_e32 v14, v14, v16                             // 00000000B968: 4C1C210E
	v_lshlrev_b32_e32 v17, v17, v13                            // 00000000B96C: 30221B11
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B970: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 00000000B974: 3022228E
	v_and_or_b32 v14, 0x7fc000, v17, v14                       // 00000000B978: D657000E 043A22FF 007FC000
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000B984: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000B988: BF870009
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000B98C: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000B990: BF870499
	s_or_b32 exec_lo, exec_lo, s11                             // 00000000B994: 8C7E0B7E
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000B998: 916A137E
	s_cbranch_vccnz 65413                                      // 00000000B99C: BFA4FF85 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xab4>
	v_bfe_u32 v18, v15, 26, 5                                  // 00000000B9A0: D6100012 0215350F
	v_and_b32_e32 v16, 0x80000000, v15                         // 00000000B9A8: 36201EFF 80000000
	v_mov_b16_e32 v17.h, 0                                     // 00000000B9B0: 7F223880
	v_mov_b16_e32 v17.l, v15.h                                 // 00000000B9B4: 7E22398F
	s_mov_b32 s11, exec_lo                                     // 00000000B9B8: BE8B007E
	v_cmpx_lt_i32_e32 30, v18                                  // 00000000B9BC: 7D82249E
	s_xor_b32 s11, exec_lo, s11                                // 00000000B9C0: 8D0B0B7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B9C4: BF870092
	v_lshlrev_b32_e32 v15, 13, v17                             // 00000000B9C8: 301E228D
	v_or3_b32 v16, v15, v16, 0x7f800000                        // 00000000B9CC: D6580010 03FE210F 7F800000
	s_and_not1_saveexec_b32 s11, s11                           // 00000000B9D8: BE8B300B
	s_cbranch_execz 36                                         // 00000000B9DC: BFA50024 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xd70>
	v_bfe_u32 v15, v15, 16, 10                                 // 00000000B9E0: D610000F 0229210F
	s_mov_b32 s14, exec_lo                                     // 00000000B9E8: BE8E007E
	v_cmpx_ne_u32_e32 0, v18                                   // 00000000B9EC: 7D9A2480
	s_xor_b32 s14, exec_lo, s14                                // 00000000B9F0: 8D0E0E7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000B9F4: BF870092
	v_lshlrev_b32_e32 v15, 13, v15                             // 00000000B9F8: 301E1E8D
	v_lshl_or_b32 v15, v18, 23, v15                            // 00000000B9FC: D656000F 043D2F12
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000BA04: BF870001
	v_add3_u32 v16, v15, v16, 0x38000000                       // 00000000BA08: D6550010 03FE210F 38000000
	s_and_not1_saveexec_b32 s14, s14                           // 00000000BA14: BE8E300E
	s_cbranch_execz 19                                         // 00000000BA18: BFA50013 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xd68>
	s_mov_b32 s15, exec_lo                                     // 00000000BA1C: BE8F007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000BA20: 7D9A1E80
	s_cbranch_execz 15                                         // 00000000BA24: BFA5000F <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xd64>
	v_clz_i32_u32_e32 v15, v15                                 // 00000000BA28: 7E1E730F
	v_or_b32_e32 v16, 0x43000000, v16                          // 00000000BA2C: 382020FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000BA34: BF870122
	v_xor_b32_e32 v18, 31, v15                                 // 00000000BA38: 3A241E9F
	v_lshlrev_b32_e32 v15, 23, v15                             // 00000000BA3C: 301E1E97
	v_sub_nc_u32_e32 v18, 9, v18                               // 00000000BA40: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000BA44: BF870112
	v_sub_nc_u32_e32 v15, v16, v15                             // 00000000BA48: 4C1E1F10
	v_lshlrev_b32_e32 v17, v18, v17                            // 00000000BA4C: 30222312
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BA50: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 00000000BA54: 3022228E
	v_and_or_b32 v16, 0x7fc000, v17, v15                       // 00000000BA58: D6570010 043E22FF 007FC000
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000BA64: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000BA68: BF870009
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000BA6C: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000BA70: BF870499
	s_or_b32 exec_lo, exec_lo, s11                             // 00000000BA74: 8C7E0B7E
	s_and_not1_b32 vcc_lo, exec_lo, s19                        // 00000000BA78: 916A137E
	s_cbranch_vccnz 65361                                      // 00000000BA7C: BFA4FF51 <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xac4>
	v_bfe_u32 v18, v13, 26, 5                                  // 00000000BA80: D6100012 0215350D
	v_and_b32_e32 v15, 0x80000000, v13                         // 00000000BA88: 361E1AFF 80000000
	v_mov_b16_e32 v17.h, 0                                     // 00000000BA90: 7F223880
	v_mov_b16_e32 v17.l, v13.h                                 // 00000000BA94: 7E22398D
	s_mov_b32 s11, exec_lo                                     // 00000000BA98: BE8B007E
	v_cmpx_lt_i32_e32 30, v18                                  // 00000000BA9C: 7D82249E
	s_xor_b32 s11, exec_lo, s11                                // 00000000BAA0: 8D0B0B7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BAA4: BF870092
	v_lshlrev_b32_e32 v13, 13, v17                             // 00000000BAA8: 301A228D
	v_or3_b32 v15, v13, v15, 0x7f800000                        // 00000000BAAC: D658000F 03FE1F0D 7F800000
	s_and_not1_saveexec_b32 s11, s11                           // 00000000BAB8: BE8B300B
	s_cbranch_execz 65311                                      // 00000000BABC: BFA5FF1F <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa3c>
	v_bfe_u32 v13, v13, 16, 10                                 // 00000000BAC0: D610000D 0229210D
	s_mov_b32 s14, exec_lo                                     // 00000000BAC8: BE8E007E
	v_cmpx_ne_u32_e32 0, v18                                   // 00000000BACC: 7D9A2480
	s_xor_b32 s14, exec_lo, s14                                // 00000000BAD0: 8D0E0E7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BAD4: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 00000000BAD8: 301A1A8D
	v_lshl_or_b32 v13, v18, 23, v13                            // 00000000BADC: D656000D 04352F12
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000BAE4: BF870001
	v_add3_u32 v15, v13, v15, 0x38000000                       // 00000000BAE8: D655000F 03FE1F0D 38000000
	s_and_not1_saveexec_b32 s14, s14                           // 00000000BAF4: BE8E300E
	s_cbranch_execz 65294                                      // 00000000BAF8: BFA5FF0E <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa34>
	s_mov_b32 s15, exec_lo                                     // 00000000BAFC: BE8F007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000000BB00: 7D9A1A80
	s_cbranch_execz 65290                                      // 00000000BB04: BFA5FF0A <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa30>
	v_clz_i32_u32_e32 v13, v13                                 // 00000000BB08: 7E1A730D
	v_or_b32_e32 v15, 0x43000000, v15                          // 00000000BB0C: 381E1EFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000BB14: BF870122
	v_xor_b32_e32 v18, 31, v13                                 // 00000000BB18: 3A241A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 00000000BB1C: 301A1A97
	v_sub_nc_u32_e32 v18, 9, v18                               // 00000000BB20: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000BB24: BF870112
	v_sub_nc_u32_e32 v13, v15, v13                             // 00000000BB28: 4C1A1B0F
	v_lshlrev_b32_e32 v17, v18, v17                            // 00000000BB2C: 30222312
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BB30: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 00000000BB34: 3022228E
	v_and_or_b32 v15, 0x7fc000, v17, v13                       // 00000000BB38: D657000F 043622FF 007FC000
	s_branch 65274                                             // 00000000BB44: BFA0FEFA <_ZN12_GLOBAL__N_114dot_lds_kernelEPKjS1_PKiPfllllli+0xa30>
	s_endpgm                                                   // 00000000BB48: BFB00000
		...

000000000000bc00 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli>:
	s_load_b256 s[4:11], s[0:1], 0x20                          // 00000000BC00: F40C0100 F8000020
	v_mov_b32_e32 v1, 0                                        // 00000000BC08: 7E020280
	s_mov_b32 s2, s15                                          // 00000000BC0C: BE82000F
	s_mov_b32 s3, 0                                            // 00000000BC10: BE830080
	s_mov_b32 s13, exec_lo                                     // 00000000BC14: BE8D007E
	s_waitcnt lgkmcnt(0)                                       // 00000000BC18: BF89FC07
	v_cmpx_le_i64_e64 s[10:11], v[0:1]                         // 00000000BC1C: D4D3007E 0002000A
	s_xor_b32 s13, exec_lo, s13                                // 00000000BC24: 8D0D0D7E
	s_load_b32 s12, s[0:1], 0x5c                               // 00000000BC28: F4000300 F800005C
	s_or_saveexec_b32 s26, s13                                 // 00000000BC30: BE9A220D
	s_load_b64 s[16:17], s[0:1], 0x18                          // 00000000BC34: F4040400 F8000018
	s_waitcnt lgkmcnt(0)                                       // 00000000BC3C: BF89FC07
	v_mov_b16_e32 v2.l, s12                                    // 00000000BC40: 7E04380C
	s_xor_b32 exec_lo, exec_lo, s26                            // 00000000BC44: 8D7E1A7E
	s_cbranch_execz 779                                        // 00000000BC48: BFA5030B <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xc78>
	s_clause 0x1                                               // 00000000BC4C: BF850001
	s_load_b64 s[20:21], s[0:1], 0x40                          // 00000000BC50: F4040500 F8000040
	s_load_b64 s[18:19], s[0:1], 0x10                          // 00000000BC58: F4040480 F8000010
	s_mov_b32 s22, 0                                           // 00000000BC60: BE960080
	s_waitcnt lgkmcnt(0)                                       // 00000000BC64: BF89FC07
	s_mov_b32 s23, s21                                         // 00000000BC68: BE970015
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000BC6C: BF870009
	s_cmp_lg_u64 s[22:23], 0                                   // 00000000BC70: BF118016
	s_cbranch_scc0 830                                         // 00000000BC74: BFA1033E <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xd70>
	s_ashr_i32 s12, s21, 31                                    // 00000000BC78: 860C9F15
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000BC7C: BF8704B9
	s_add_u32 s14, s20, s12                                    // 00000000BC80: 800E0C14
	s_mov_b32 s13, s12                                         // 00000000BC84: BE8D000C
	s_addc_u32 s15, s21, s12                                   // 00000000BC88: 820F0C15
	s_xor_b64 s[14:15], s[14:15], s[12:13]                     // 00000000BC8C: 8D8E0C0E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000BC90: BF8700C9
	v_cvt_f32_u32_e32 v2, s14                                  // 00000000BC94: 7E040C0E
	v_cvt_f32_u32_e32 v3, s15                                  // 00000000BC98: 7E060C0F
	s_sub_u32 s25, 0, s14                                      // 00000000BC9C: 80990E80
	s_subb_u32 s27, 0, s15                                     // 00000000BCA0: 829B0F80
	v_fmamk_f32 v2, v3, 0x4f800000, v2                         // 00000000BCA4: 58040503 4F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000BCAC: BF8700B1
	v_rcp_f32_e32 v2, v2                                       // 00000000BCB0: 7E045502
	s_waitcnt_depctr 0xfff                                     // 00000000BCB4: BF880FFF
	v_mul_f32_e32 v2, 0x5f7ffffc, v2                           // 00000000BCB8: 100404FF 5F7FFFFC
	v_mul_f32_e32 v3, 0x2f800000, v2                           // 00000000BCC0: 100604FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BCC8: BF870091
	v_trunc_f32_e32 v3, v3                                     // 00000000BCCC: 7E064303
	v_fmamk_f32 v2, v3, 0xcf800000, v2                         // 00000000BCD0: 58040503 CF800000
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000BCD8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000BCDC: BF870112
	v_cvt_u32_f32_e32 v2, v2                                   // 00000000BCE0: 7E040F02
	v_readfirstlane_b32 s23, v3                                // 00000000BCE4: 7E2E0503
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000BCE8: BF870002
	v_readfirstlane_b32 s24, v2                                // 00000000BCEC: 7E300502
	s_mul_i32 s28, s25, s23                                    // 00000000BCF0: 961C1719
	s_mul_hi_u32 s30, s25, s24                                 // 00000000BCF4: 969E1819
	s_mul_i32 s29, s27, s24                                    // 00000000BCF8: 961D181B
	s_add_i32 s28, s30, s28                                    // 00000000BCFC: 811C1C1E
	s_mul_i32 s31, s25, s24                                    // 00000000BD00: 961F1819
	s_add_i32 s28, s28, s29                                    // 00000000BD04: 811C1D1C
	s_mul_hi_u32 s30, s24, s31                                 // 00000000BD08: 969E1F18
	s_mul_i32 s34, s24, s28                                    // 00000000BD0C: 96221C18
	s_mul_hi_u32 s33, s23, s31                                 // 00000000BD10: 96A11F17
	s_mul_i32 s29, s23, s31                                    // 00000000BD14: 961D1F17
	s_mul_hi_u32 s31, s24, s28                                 // 00000000BD18: 969F1C18
	s_add_u32 s30, s30, s34                                    // 00000000BD1C: 801E221E
	s_addc_u32 s31, 0, s31                                     // 00000000BD20: 821F1F80
	s_mul_hi_u32 s35, s23, s28                                 // 00000000BD24: 96A31C17
	s_add_u32 s29, s30, s29                                    // 00000000BD28: 801D1D1E
	s_mul_i32 s28, s23, s28                                    // 00000000BD2C: 961C1C17
	s_addc_u32 s29, s31, s33                                   // 00000000BD30: 821D211F
	s_addc_u32 s30, s35, 0                                     // 00000000BD34: 821E8023
	s_add_u32 s28, s29, s28                                    // 00000000BD38: 801C1C1D
	s_addc_u32 s29, 0, s30                                     // 00000000BD3C: 821D1E80
	s_add_u32 s24, s24, s28                                    // 00000000BD40: 80181C18
	s_cselect_b32 s28, -1, 0                                   // 00000000BD44: 981C80C1
	s_mul_hi_u32 s30, s25, s24                                 // 00000000BD48: 969E1819
	s_cmp_lg_u32 s28, 0                                        // 00000000BD4C: BF07801C
	s_mul_i32 s28, s25, s24                                    // 00000000BD50: 961C1819
	s_addc_u32 s23, s23, s29                                   // 00000000BD54: 82171D17
	s_mul_i32 s27, s27, s24                                    // 00000000BD58: 961B181B
	s_mul_i32 s25, s25, s23                                    // 00000000BD5C: 96191719
	s_mul_hi_u32 s29, s24, s28                                 // 00000000BD60: 969D1C18
	s_add_i32 s25, s30, s25                                    // 00000000BD64: 8119191E
	s_mul_hi_u32 s30, s23, s28                                 // 00000000BD68: 969E1C17
	s_add_i32 s25, s25, s27                                    // 00000000BD6C: 81191B19
	s_mul_i32 s27, s23, s28                                    // 00000000BD70: 961B1C17
	s_mul_i32 s33, s24, s25                                    // 00000000BD74: 96211918
	s_mul_hi_u32 s31, s24, s25                                 // 00000000BD78: 969F1918
	s_add_u32 s29, s29, s33                                    // 00000000BD7C: 801D211D
	s_addc_u32 s31, 0, s31                                     // 00000000BD80: 821F1F80
	s_mul_hi_u32 s28, s23, s25                                 // 00000000BD84: 969C1917
	s_add_u32 s27, s29, s27                                    // 00000000BD88: 801B1B1D
	s_mul_i32 s25, s23, s25                                    // 00000000BD8C: 96191917
	s_addc_u32 s27, s31, s30                                   // 00000000BD90: 821B1E1F
	s_addc_u32 s28, s28, 0                                     // 00000000BD94: 821C801C
	s_add_u32 s25, s27, s25                                    // 00000000BD98: 8019191B
	s_addc_u32 s27, 0, s28                                     // 00000000BD9C: 821B1C80
	s_add_u32 s28, s24, s25                                    // 00000000BDA0: 801C1918
	s_cselect_b32 s24, -1, 0                                   // 00000000BDA4: 981880C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 00000000BDA8: BF8704C9
	s_cmp_lg_u32 s24, 0                                        // 00000000BDAC: BF078018
	s_addc_u32 s23, s23, s27                                   // 00000000BDB0: 82171B17
	s_add_u32 s24, s2, 0                                       // 00000000BDB4: 80188002
	s_addc_u32 s25, 0, 0                                       // 00000000BDB8: 82198080
	s_xor_b64 s[24:25], s[24:25], 0                            // 00000000BDBC: 8D988018
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000BDC0: BF870009
	s_mul_i32 s29, s24, s23                                    // 00000000BDC4: 961D1718
	s_mul_hi_u32 s30, s24, s28                                 // 00000000BDC8: 969E1C18
	s_mul_hi_u32 s27, s24, s23                                 // 00000000BDCC: 969B1718
	s_mul_hi_u32 s33, s25, s28                                 // 00000000BDD0: 96A11C19
	s_mul_i32 s28, s25, s28                                    // 00000000BDD4: 961C1C19
	s_add_u32 s29, s30, s29                                    // 00000000BDD8: 801D1D1E
	s_addc_u32 s27, 0, s27                                     // 00000000BDDC: 821B1B80
	s_mul_hi_u32 s31, s25, s23                                 // 00000000BDE0: 969F1719
	s_add_u32 s28, s29, s28                                    // 00000000BDE4: 801C1C1D
	s_mul_i32 s23, s25, s23                                    // 00000000BDE8: 96171719
	s_addc_u32 s27, s27, s33                                   // 00000000BDEC: 821B211B
	s_addc_u32 s28, s31, 0                                     // 00000000BDF0: 821C801F
	s_add_u32 s23, s27, s23                                    // 00000000BDF4: 8017171B
	s_addc_u32 s27, 0, s28                                     // 00000000BDF8: 821B1C80
	s_mul_hi_u32 s28, s14, s23                                 // 00000000BDFC: 969C170E
	s_mul_i32 s29, s14, s27                                    // 00000000BE00: 961D1B0E
	s_mul_i32 s30, s15, s23                                    // 00000000BE04: 961E170F
	s_add_i32 s28, s28, s29                                    // 00000000BE08: 811C1D1C
	s_mul_i32 s29, s14, s23                                    // 00000000BE0C: 961D170E
	s_add_i32 s28, s28, s30                                    // 00000000BE10: 811C1E1C
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000BE14: BF8704B9
	s_sub_i32 s30, s25, s28                                    // 00000000BE18: 819E1C19
	s_sub_u32 s24, s24, s29                                    // 00000000BE1C: 80981D18
	s_cselect_b32 s29, -1, 0                                   // 00000000BE20: 981D80C1
	s_cmp_lg_u32 s29, 0                                        // 00000000BE24: BF07801D
	s_subb_u32 s30, s30, s15                                   // 00000000BE28: 829E0F1E
	s_sub_u32 s31, s24, s14                                    // 00000000BE2C: 809F0E18
	s_cselect_b32 s33, -1, 0                                   // 00000000BE30: 982180C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000BE34: BF8704A9
	s_cmp_lg_u32 s33, 0                                        // 00000000BE38: BF078021
	s_subb_u32 s30, s30, 0                                     // 00000000BE3C: 829E801E
	s_cmp_ge_u32 s30, s15                                      // 00000000BE40: BF090F1E
	s_cselect_b32 s33, -1, 0                                   // 00000000BE44: 982180C1
	s_cmp_ge_u32 s31, s14                                      // 00000000BE48: BF090E1F
	s_cselect_b32 s31, -1, 0                                   // 00000000BE4C: 981F80C1
	s_cmp_eq_u32 s30, s15                                      // 00000000BE50: BF060F1E
	s_cselect_b32 s30, s31, s33                                // 00000000BE54: 981E211F
	s_add_u32 s31, s23, 1                                      // 00000000BE58: 801F8117
	s_addc_u32 s33, s27, 0                                     // 00000000BE5C: 8221801B
	s_add_u32 s34, s23, 2                                      // 00000000BE60: 80228217
	s_addc_u32 s35, s27, 0                                     // 00000000BE64: 8223801B
	s_cmp_lg_u32 s30, 0                                        // 00000000BE68: BF07801E
	s_cselect_b32 s30, s34, s31                                // 00000000BE6C: 981E1F22
	s_cselect_b32 s31, s35, s33                                // 00000000BE70: 981F2123
	s_cmp_lg_u32 s29, 0                                        // 00000000BE74: BF07801D
	s_subb_u32 s25, s25, s28                                   // 00000000BE78: 82991C19
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000BE7C: BF870009
	s_cmp_ge_u32 s25, s15                                      // 00000000BE80: BF090F19
	s_cselect_b32 s28, -1, 0                                   // 00000000BE84: 981C80C1
	s_cmp_ge_u32 s24, s14                                      // 00000000BE88: BF090E18
	s_cselect_b32 s14, -1, 0                                   // 00000000BE8C: 980E80C1
	s_cmp_eq_u32 s25, s15                                      // 00000000BE90: BF060F19
	s_cselect_b32 s14, s14, s28                                // 00000000BE94: 980E1C0E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 00000000BE98: BF8704C9
	s_cmp_lg_u32 s14, 0                                        // 00000000BE9C: BF07800E
	s_cselect_b32 s15, s31, s27                                // 00000000BEA0: 980F1B1F
	s_cselect_b32 s14, s30, s23                                // 00000000BEA4: 980E171E
	s_xor_b64 s[12:13], 0, s[12:13]                            // 00000000BEA8: 8D8C0C80
	s_xor_b64 s[14:15], s[14:15], s[12:13]                     // 00000000BEAC: 8D8E0C0E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000BEB0: BF870009
	s_sub_u32 s24, s14, s12                                    // 00000000BEB4: 80980C0E
	s_subb_u32 s25, s15, s13                                   // 00000000BEB8: 82990D0F
	s_load_b128 s[12:15], s[0:1], null                         // 00000000BEBC: F4080300 F8000000
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000BEC4: 916A167E
	s_cbranch_vccnz 27                                         // 00000000BEC8: BFA4001B <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x338>
	v_cvt_f32_u32_e32 v2, s20                                  // 00000000BECC: 7E040C14
	s_sub_i32 s23, 0, s20                                      // 00000000BED0: 81971480
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000BED4: BF8700B1
	v_rcp_iflag_f32_e32 v2, v2                                 // 00000000BED8: 7E045702
	s_waitcnt_depctr 0xfff                                     // 00000000BEDC: BF880FFF
	v_mul_f32_e32 v2, 0x4f7ffffe, v2                           // 00000000BEE0: 100404FF 4F7FFFFE
	v_cvt_u32_f32_e32 v2, v2                                   // 00000000BEE8: 7E040F02
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000BEEC: BF8704A1
	v_readfirstlane_b32 s22, v2                                // 00000000BEF0: 7E2C0502
	s_mul_i32 s23, s23, s22                                    // 00000000BEF4: 96171617
	s_mul_hi_u32 s23, s22, s23                                 // 00000000BEF8: 96971716
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000BEFC: BF870499
	s_add_i32 s22, s22, s23                                    // 00000000BF00: 81161716
	s_mul_hi_u32 s22, s2, s22                                  // 00000000BF04: 96961602
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000BF08: BF8704B9
	s_mul_i32 s23, s22, s20                                    // 00000000BF0C: 96171416
	s_add_i32 s24, s22, 1                                      // 00000000BF10: 81188116
	s_sub_i32 s23, s2, s23                                     // 00000000BF14: 81971702
	s_sub_i32 s25, s23, s20                                    // 00000000BF18: 81991417
	s_cmp_ge_u32 s23, s20                                      // 00000000BF1C: BF091417
	s_cselect_b32 s22, s24, s22                                // 00000000BF20: 98161618
	s_cselect_b32 s23, s25, s23                                // 00000000BF24: 98171719
	s_add_i32 s24, s22, 1                                      // 00000000BF28: 81188116
	s_cmp_ge_u32 s23, s20                                      // 00000000BF2C: BF091417
	s_mov_b32 s25, 0                                           // 00000000BF30: BE990080
	s_cselect_b32 s24, s24, s22                                // 00000000BF34: 98181618
	s_clause 0x1                                               // 00000000BF38: BF850001
	s_load_b32 s22, s[0:1], 0x48                               // 00000000BF3C: F4000580 F8000048
	s_load_b32 s1, s[0:1], 0x5c                                // 00000000BF44: F4000040 F800005C
	v_cvt_f32_u32_e32 v2, s8                                   // 00000000BF4C: 7E040C08
	s_mul_i32 s0, s24, s7                                      // 00000000BF50: 96000718
	s_mul_hi_u32 s7, s24, s6                                   // 00000000BF54: 96870618
	s_mul_i32 s23, s25, s6                                     // 00000000BF58: 96170619
	s_add_i32 s0, s7, s0                                       // 00000000BF5C: 81000007
	v_rcp_iflag_f32_e32 v2, v2                                 // 00000000BF60: 7E045702
	s_mul_i32 s6, s24, s6                                      // 00000000BF64: 96060618
	s_add_i32 s7, s0, s23                                      // 00000000BF68: 81071700
	s_mul_i32 s27, s24, s21                                    // 00000000BF6C: 961B1518
	s_lshl_b64 s[6:7], s[6:7], 2                               // 00000000BF70: 84868206
	s_mul_hi_u32 s28, s24, s20                                 // 00000000BF74: 969C1418
	s_mul_i32 s0, s25, s20                                     // 00000000BF78: 96001419
	s_mul_i32 s24, s24, s20                                    // 00000000BF7C: 96181418
	s_add_u32 s20, s18, s6                                     // 00000000BF80: 80140612
	s_addc_u32 s21, s19, s7                                    // 00000000BF84: 82150713
	s_waitcnt_depctr 0xfff                                     // 00000000BF88: BF880FFF
	v_mul_f32_e32 v2, 0x4f7ffffe, v2                           // 00000000BF8C: 100404FF 4F7FFFFE
	v_mov_b32_e32 v14, 0                                       // 00000000BF94: 7E1C0280
	s_waitcnt lgkmcnt(0)                                       // 00000000BF98: BF89FC07
	s_cmp_eq_u32 s22, 0                                        // 00000000BF9C: BF068016
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000BFA0: BF870002
	v_cvt_u32_f32_e32 v3, v2                                   // 00000000BFA4: 7E060F02
	s_cselect_b32 s22, -1, 0                                   // 00000000BFA8: 981680C1
	s_add_i32 s6, s28, s27                                     // 00000000BFAC: 81061B1C
	s_and_b32 s23, s1, 0xffff                                  // 00000000BFB0: 8B17FF01 0000FFFF
	s_add_i32 s25, s6, s0                                      // 00000000BFB8: 81190006
	s_lshl_b64 s[6:7], s[2:3], 2                               // 00000000BFBC: 84868202
	s_lshl_b64 s[18:19], s[24:25], 2                           // 00000000BFC0: 84928218
	s_lshl_b32 s24, s23, 2                                     // 00000000BFC4: 84188217
	s_sub_u32 s25, s6, s18                                     // 00000000BFC8: 80991206
	s_subb_u32 s27, s7, s19                                    // 00000000BFCC: 829B1307
	s_sub_i32 s0, 0, s8                                        // 00000000BFD0: 81800880
	s_mov_b32 s28, 0                                           // 00000000BFD4: BE9C0080
	v_mul_lo_u32 v2, s0, v3                                    // 00000000BFD8: D72C0002 00020600
	s_ashr_i32 s6, s9, 31                                      // 00000000BFE0: 86069F09
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000BFE4: BF870091
	v_mul_hi_u32 v6, v3, v2                                    // 00000000BFE8: D72D0006 00020503
	v_dual_mov_b32 v2, 0 :: v_dual_add_nc_u32 v15, v3, v6      // 00000000BFF0: CA200080 020E0D03
	v_dual_mov_b32 v7, v1 :: v_dual_lshlrev_b32 v4, 2, v0      // 00000000BFF8: CA220101 07040082
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000C000: BF870002
	v_dual_mov_b32 v5, v2 :: v_dual_mov_b32 v6, v0             // 00000000C004: CA100102 05060100
	s_branch 23                                                // 00000000C00C: BFA00017 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x46c>
	s_or_b32 exec_lo, exec_lo, s18                             // 00000000C010: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C014: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000C018: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C01C: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C020: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000C024: BF8700A1
	v_mul_f32_e32 v3, v9, v10                                  // 00000000C028: 10061509
	v_add_co_u32 v6, vcc_lo, v6, s23                           // 00000000C02C: D7006A06 00002F06
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000C034: D5207C07 01AA0E80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000C03C: BF8701A3
	v_fmac_f32_e32 v3, v1, v8                                  // 00000000C040: 56061101
	v_add_co_u32 v4, s0, v4, s24                               // 00000000C044: D7000004 00003104
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 00000000C04C: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s0                    // 00000000C050: D5207C05 00020A80
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000C058: BF8704A4
	v_add_f32_e32 v14, v14, v3                                 // 00000000C05C: 061C070E
	s_or_b32 s28, vcc_lo, s28                                  // 00000000C060: 8C1C1C6A
	s_and_not1_b32 exec_lo, exec_lo, s28                       // 00000000C064: 917E1C7E
	s_cbranch_execz 512                                        // 00000000C068: BFA50200 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xc6c>
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000C06C: BF8700A2
	v_or_b32_e32 v3, s9, v7                                    // 00000000C070: 38060E09
	s_mov_b32 s0, exec_lo                                      // 00000000C074: BE80007E
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000C078: 7DBA0480
	s_xor_b32 s29, exec_lo, s0                                 // 00000000C07C: 8D1D007E
	s_cbranch_execz 175                                        // 00000000C080: BFA500AF <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x740>
	s_add_u32 s18, s8, s6                                      // 00000000C084: 80120608
	s_mov_b32 s7, s6                                           // 00000000C088: BE870006
	s_addc_u32 s19, s9, s6                                     // 00000000C08C: 82130609
	v_ashrrev_i32_e32 v16, 31, v7                              // 00000000C090: 34200E9F
	s_xor_b64 s[18:19], s[18:19], s[6:7]                       // 00000000C094: 8D920612
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000C098: BF870159
	v_cvt_f32_u32_e32 v1, s18                                  // 00000000C09C: 7E020C12
	v_cvt_f32_u32_e32 v3, s19                                  // 00000000C0A0: 7E060C13
	s_sub_u32 s0, 0, s18                                       // 00000000C0A4: 80801280
	s_subb_u32 s31, 0, s19                                     // 00000000C0A8: 829F1380
	v_add_co_u32 v8, vcc_lo, v6, v16                           // 00000000C0AC: D7006A08 00022106
	v_fmac_f32_e32 v1, 0x4f800000, v3                          // 00000000C0B4: 560206FF 4F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000C0BC: BF8700B1
	v_rcp_f32_e32 v1, v1                                       // 00000000C0C0: 7E025501
	s_waitcnt_depctr 0xfff                                     // 00000000C0C4: BF880FFF
	v_mul_f32_e32 v1, 0x5f7ffffc, v1                           // 00000000C0C8: 100202FF 5F7FFFFC
	v_mul_f32_e32 v3, 0x2f800000, v1                           // 00000000C0D0: 100602FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C0D8: BF870091
	v_trunc_f32_e32 v3, v3                                     // 00000000C0DC: 7E064303
	v_fmac_f32_e32 v1, 0xcf800000, v3                          // 00000000C0E0: 560206FF CF800000
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000C0E8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C0EC: BF870112
	v_cvt_u32_f32_e32 v1, v1                                   // 00000000C0F0: 7E020F01
	v_readfirstlane_b32 s7, v3                                 // 00000000C0F4: 7E0E0503
	v_xor_b32_e32 v3, v8, v16                                  // 00000000C0F8: 3A062108
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000C0FC: BF870003
	v_readfirstlane_b32 s30, v1                                // 00000000C100: 7E3C0501
	s_mul_i32 s33, s0, s7                                      // 00000000C104: 96210700
	v_add_co_ci_u32_e64 v1, null, v7, v16, vcc_lo              // 00000000C108: D5207C01 01AA2107
	s_mul_hi_u32 s35, s0, s30                                  // 00000000C110: 96A31E00
	s_mul_i32 s34, s31, s30                                    // 00000000C114: 96221E1F
	s_add_i32 s33, s35, s33                                    // 00000000C118: 81212123
	s_mul_i32 s36, s0, s30                                     // 00000000C11C: 96241E00
	s_add_i32 s33, s33, s34                                    // 00000000C120: 81212221
	s_mul_hi_u32 s35, s30, s36                                 // 00000000C124: 96A3241E
	s_mul_i32 s38, s30, s33                                    // 00000000C128: 9626211E
	s_mul_hi_u32 s37, s7, s36                                  // 00000000C12C: 96A52407
	s_mul_i32 s34, s7, s36                                     // 00000000C130: 96222407
	s_mul_hi_u32 s36, s30, s33                                 // 00000000C134: 96A4211E
	s_add_u32 s35, s35, s38                                    // 00000000C138: 80232623
	s_addc_u32 s36, 0, s36                                     // 00000000C13C: 82242480
	s_mul_hi_u32 s39, s7, s33                                  // 00000000C140: 96A72107
	s_add_u32 s34, s35, s34                                    // 00000000C144: 80222223
	s_mul_i32 s33, s7, s33                                     // 00000000C148: 96212107
	s_addc_u32 s34, s36, s37                                   // 00000000C14C: 82222524
	s_addc_u32 s35, s39, 0                                     // 00000000C150: 82238027
	s_add_u32 s33, s34, s33                                    // 00000000C154: 80212122
	s_addc_u32 s34, 0, s35                                     // 00000000C158: 82222380
	s_add_u32 s30, s30, s33                                    // 00000000C15C: 801E211E
	s_cselect_b32 s33, -1, 0                                   // 00000000C160: 982180C1
	s_mul_hi_u32 s35, s0, s30                                  // 00000000C164: 96A31E00
	s_cmp_lg_u32 s33, 0                                        // 00000000C168: BF078021
	s_mul_i32 s33, s0, s30                                     // 00000000C16C: 96211E00
	s_addc_u32 s7, s7, s34                                     // 00000000C170: 82072207
	s_mul_i32 s31, s31, s30                                    // 00000000C174: 961F1E1F
	s_mul_i32 s0, s0, s7                                       // 00000000C178: 96000700
	s_mul_hi_u32 s34, s30, s33                                 // 00000000C17C: 96A2211E
	s_add_i32 s0, s35, s0                                      // 00000000C180: 81000023
	s_mul_hi_u32 s35, s7, s33                                  // 00000000C184: 96A32107
	s_add_i32 s0, s0, s31                                      // 00000000C188: 81001F00
	s_mul_i32 s31, s7, s33                                     // 00000000C18C: 961F2107
	s_mul_i32 s37, s30, s0                                     // 00000000C190: 9625001E
	s_mul_hi_u32 s36, s30, s0                                  // 00000000C194: 96A4001E
	s_add_u32 s34, s34, s37                                    // 00000000C198: 80222522
	s_addc_u32 s36, 0, s36                                     // 00000000C19C: 82242480
	s_mul_hi_u32 s33, s7, s0                                   // 00000000C1A0: 96A10007
	s_add_u32 s31, s34, s31                                    // 00000000C1A4: 801F1F22
	s_mul_i32 s0, s7, s0                                       // 00000000C1A8: 96000007
	s_addc_u32 s31, s36, s35                                   // 00000000C1AC: 821F2324
	s_addc_u32 s33, s33, 0                                     // 00000000C1B0: 82218021
	s_add_u32 s0, s31, s0                                      // 00000000C1B4: 8000001F
	s_addc_u32 s31, 0, s33                                     // 00000000C1B8: 821F2180
	s_add_u32 s0, s30, s0                                      // 00000000C1BC: 8000001E
	s_cselect_b32 s30, -1, 0                                   // 00000000C1C0: 981E80C1
	v_xor_b32_e32 v1, v1, v16                                  // 00000000C1C4: 3A022101
	s_cmp_lg_u32 s30, 0                                        // 00000000C1C8: BF07801E
	v_mul_hi_u32 v17, v3, s0                                   // 00000000C1CC: D72D0011 00000103
	s_addc_u32 s7, s7, s31                                     // 00000000C1D4: 82071F07
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000C1D8: BF8701B9
	v_mad_u64_u32 v[8:9], null, v3, s7, 0                      // 00000000C1DC: D6FE7C08 02000F03
	v_mad_u64_u32 v[10:11], null, v1, s0, 0                    // 00000000C1E4: D6FE7C0A 02000101
	v_mad_u64_u32 v[12:13], null, v1, s7, 0                    // 00000000C1EC: D6FE7C0C 02000F01
	v_add_co_u32 v8, vcc_lo, v17, v8                           // 00000000C1F4: D7006A08 00021111
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C1FC: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000C200: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 00000000C208: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C210: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 00000000C214: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v13, vcc_lo             // 00000000C218: 40121A80
	v_add_co_u32 v10, vcc_lo, v8, v12                          // 00000000C21C: D7006A0A 00021908
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C224: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 00000000C228: D5207C0B 01AA1280
	v_mul_lo_u32 v12, s19, v10                                 // 00000000C230: D72C000C 00021413
	v_mad_u64_u32 v[8:9], null, s18, v10, 0                    // 00000000C238: D6FE7C08 02021412
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C240: BF870113
	v_mul_lo_u32 v13, s18, v11                                 // 00000000C244: D72C000D 00021612
	v_sub_co_u32 v3, vcc_lo, v3, v8                            // 00000000C24C: D7016A03 00021103
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C254: BF870092
	v_add3_u32 v9, v9, v13, v12                                // 00000000C258: D6550009 04321B09
	v_sub_nc_u32_e32 v12, v1, v9                               // 00000000C260: 4C181301
	v_sub_co_ci_u32_e64 v1, null, v1, v9, vcc_lo               // 00000000C264: D5217C01 01AA1301
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000C26C: BF8700A2
	v_subrev_co_ci_u32_e64 v8, null, s19, v12, vcc_lo          // 00000000C270: D5227C08 01AA1813
	v_add_co_u32 v12, s0, v10, 2                               // 00000000C278: D700000C 0001050A
	v_add_co_ci_u32_e64 v13, null, 0, v11, s0                  // 00000000C280: D5207C0D 00021680
	v_sub_co_u32 v17, s0, v3, s18                              // 00000000C288: D7010011 00002503
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C290: BF870111
	v_subrev_co_ci_u32_e64 v8, null, 0, v8, s0                 // 00000000C294: D5227C08 00021080
	v_cmp_le_u32_e32 vcc_lo, s18, v17                          // 00000000C29C: 7C962212
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 00000000C2A0: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000C2A8: BF870003
	v_cmp_le_u32_e32 vcc_lo, s19, v8                           // 00000000C2AC: 7C961013
	v_cndmask_b32_e64 v17, 0, -1, vcc_lo                       // 00000000C2B0: D5010011 01A98280
	v_cmp_le_u32_e32 vcc_lo, s18, v3                           // 00000000C2B8: 7C960612
	v_cndmask_b32_e64 v3, 0, -1, vcc_lo                        // 00000000C2BC: D5010003 01A98280
	v_cmp_le_u32_e32 vcc_lo, s19, v1                           // 00000000C2C4: 7C960213
	v_cndmask_b32_e64 v18, 0, -1, vcc_lo                       // 00000000C2C8: D5010012 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s19, v8                           // 00000000C2D0: 7C941013
	v_cndmask_b32_e32 v8, v17, v9, vcc_lo                      // 00000000C2D4: 02101311
	v_add_co_u32 v9, vcc_lo, v10, 1                            // 00000000C2D8: D7006A09 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000C2E0: BF8701D1
	v_add_co_ci_u32_e64 v17, null, 0, v11, vcc_lo              // 00000000C2E4: D5207C11 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s19, v1                           // 00000000C2EC: 7C940213
	v_cndmask_b32_e32 v1, v18, v3, vcc_lo                      // 00000000C2F0: 02020712
	v_cmp_ne_u32_e32 vcc_lo, 0, v8                             // 00000000C2F4: 7C9A1080
	v_xor_b32_e32 v8, s6, v16                                  // 00000000C2F8: 3A102006
	v_cmp_ne_u32_e64 s0, 0, v1                                 // 00000000C2FC: D44D0000 00020280
	v_cndmask_b32_e32 v1, v9, v12, vcc_lo                      // 00000000C304: 02021909
	v_cndmask_b32_e32 v3, v17, v13, vcc_lo                     // 00000000C308: 02061B11
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C30C: BF870112
	v_cndmask_b32_e64 v1, v10, v1, s0                          // 00000000C310: D5010001 0002030A
	v_cndmask_b32_e64 v3, v11, v3, s0                          // 00000000C318: D5010003 0002070B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C320: BF870112
	v_xor_b32_e32 v1, v1, v8                                   // 00000000C324: 3A021101
	v_xor_b32_e32 v3, v3, v8                                   // 00000000C328: 3A061103
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C32C: BF870092
	v_sub_co_u32 v10, vcc_lo, v1, v8                           // 00000000C330: D7016A0A 00021101
	v_sub_co_ci_u32_e64 v11, null, v3, v8, vcc_lo              // 00000000C338: D5217C0B 01AA1103
	s_and_not1_saveexec_b32 s0, s29                            // 00000000C340: BE80301D
	s_cbranch_execz 18                                         // 00000000C344: BFA50012 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x790>
	v_mul_hi_u32 v1, v6, v15                                   // 00000000C348: D72D0001 00021F06
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000C350: BF8700A1
	v_dual_mov_b32 v11, v2 :: v_dual_add_nc_u32 v8, 1, v1      // 00000000C354: CA200102 0B080281
	v_mul_lo_u32 v3, v1, s8                                    // 00000000C35C: D72C0003 00001101
	v_sub_nc_u32_e32 v3, v6, v3                                // 00000000C364: 4C060706
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000C368: BF8700B1
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000C36C: 7C960608
	v_subrev_nc_u32_e32 v9, s8, v3                             // 00000000C370: 4E120608
	v_cndmask_b32_e32 v1, v1, v8, vcc_lo                       // 00000000C374: 02021101
	v_add_nc_u32_e32 v8, 1, v1                                 // 00000000C378: 4A100281
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C37C: BF870093
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 00000000C380: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000C384: 7C960608
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000C388: BF870003
	v_cndmask_b32_e32 v10, v1, v8, vcc_lo                      // 00000000C38C: 02141101
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C390: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C394: BF870091
	v_lshlrev_b64 v[8:9], 2, v[10:11]                          // 00000000C398: D73C0008 00021482
	v_add_co_u32 v12, vcc_lo, s20, v8                          // 00000000C3A0: D7006A0C 00021014
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000C3A8: BF8700C1
	v_add_co_ci_u32_e64 v13, null, s21, v9, vcc_lo             // 00000000C3AC: D5207C0D 01AA1215
	global_load_b32 v12, v[12:13], off                         // 00000000C3B4: DC520000 0C7C000C
	s_waitcnt vmcnt(0)                                         // 00000000C3BC: BF8903F7
	v_ashrrev_i32_e32 v13, 31, v12                             // 00000000C3C0: 341A189F
	v_cmp_gt_i64_e32 vcc_lo, 0, v[12:13]                       // 00000000C3C4: 7CA81880
	v_cmp_le_i64_e64 s0, s[4:5], v[12:13]                      // 00000000C3C8: D4530000 00021804
	s_or_b32 s0, vcc_lo, s0                                    // 00000000C3D0: 8C00006A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000C3D4: BF870499
	s_and_saveexec_b32 s7, s0                                  // 00000000C3D8: BE872000
	s_xor_b32 s0, exec_lo, s7                                  // 00000000C3DC: 8D00077E
	v_lshlrev_b64 v[8:9], 2, v[10:11]                          // 00000000C3E0: D73C0008 00021482
	s_or_saveexec_b32 s0, s0                                   // 00000000C3E8: BE802200
	v_mov_b32_e32 v10, 0                                       // 00000000C3EC: 7E140280
	s_xor_b32 exec_lo, exec_lo, s0                             // 00000000C3F0: 8D7E007E
	s_cbranch_execz 24                                         // 00000000C3F4: BFA50018 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x858>
	v_lshlrev_b64 v[10:11], 2, v[12:13]                        // 00000000C3F8: D73C000A 00021882
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C400: BF870091
	v_sub_co_u32 v1, vcc_lo, v10, v8                           // 00000000C404: D7016A01 0002110A
	v_sub_co_ci_u32_e64 v3, null, v11, v9, vcc_lo              // 00000000C40C: D5217C03 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000C414: BF8701A2
	v_mul_lo_u32 v12, s9, v1                                   // 00000000C418: D72C000C 00020209
	v_mad_u64_u32 v[10:11], null, s8, v1, v[4:5]               // 00000000C420: D6FE7C0A 04120208
	v_mul_lo_u32 v3, s8, v3                                    // 00000000C428: D72C0003 00020608
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C430: BF870112
	v_add_co_u32 v10, vcc_lo, s12, v10                         // 00000000C434: D7006A0A 0002140C
	v_add3_u32 v1, v12, v11, v3                                // 00000000C43C: D6550001 040E170C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C444: BF870001
	v_add_co_ci_u32_e64 v11, null, s13, v1, vcc_lo             // 00000000C448: D5207C0B 01AA020D
	global_load_b32 v10, v[10:11], off                         // 00000000C450: DC520000 0A7C000A
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C458: 8C7E007E
	v_sub_co_u32 v1, vcc_lo, s25, v8                           // 00000000C45C: D7016A01 00021019
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C464: BF870111
	v_sub_co_ci_u32_e64 v3, null, s27, v9, vcc_lo              // 00000000C468: D5217C03 01AA121B
	v_mul_lo_u32 v11, s9, v1                                   // 00000000C470: D72C000B 00020209
	v_mad_u64_u32 v[8:9], null, s8, v1, v[4:5]                 // 00000000C478: D6FE7C08 04120208
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C480: BF870113
	v_mul_lo_u32 v3, s8, v3                                    // 00000000C484: D72C0003 00020608
	v_add_co_u32 v8, vcc_lo, s14, v8                           // 00000000C48C: D7006A08 0002100E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C494: BF870092
	v_add3_u32 v1, v11, v9, v3                                 // 00000000C498: D6550001 040E130B
	v_add_co_ci_u32_e64 v9, null, s15, v1, vcc_lo              // 00000000C4A0: D5207C09 01AA020F
	s_waitcnt vmcnt(0)                                         // 00000000C4A8: BF8903F7
	v_lshlrev_b32_e32 v1, 16, v10                              // 00000000C4AC: 30021490
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C4B0: 916A167E
	global_load_b32 v3, v[8:9], off                            // 00000000C4B4: DC520000 037C0008
	s_cbranch_vccz 13                                          // 00000000C4BC: BFA3000D <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x8f4>
	s_waitcnt vmcnt(0)                                         // 00000000C4C0: BF8903F7
	v_lshlrev_b32_e32 v8, 16, v3                               // 00000000C4C4: 30100690
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C4C8: 916A167E
	s_cbranch_vccz 68                                          // 00000000C4CC: BFA30044 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x9e0>
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C4D0: 916A167E
	s_cbranch_vccz 123                                         // 00000000C4D4: BFA3007B <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xac4>
	v_and_b32_e32 v9, 0xffff0000, v10                          // 00000000C4D8: 361214FF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C4E0: 916A167E
	s_cbranch_vccz 175                                         // 00000000C4E4: BFA300AF <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xba4>
	v_and_b32_e32 v10, 0xffff0000, v3                          // 00000000C4E8: 361406FF FFFF0000
	s_branch 65228                                             // 00000000C4F0: BFA0FECC <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x424>
	v_bfe_u32 v8, v10, 10, 5                                   // 00000000C4F4: D6100008 0215150A
	v_and_b32_e32 v1, 0x80000000, v1                           // 00000000C4FC: 360202FF 80000000
	s_mov_b32 s0, exec_lo                                      // 00000000C504: BE80007E
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000C508: BF870002
	v_cmpx_lt_i32_e32 30, v8                                   // 00000000C50C: 7D82109E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000C510: 8D00007E
	v_lshlrev_b32_e32 v8, 13, v10                              // 00000000C514: 3010148D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C518: BF870091
	v_and_b32_e32 v8, 0x7fe000, v8                             // 00000000C51C: 361010FF 007FE000
	v_or3_b32 v1, v8, v1, 0x7f800000                           // 00000000C524: D6580001 03FE0308 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000C530: BE803000
	s_cbranch_execz 36                                         // 00000000C534: BFA50024 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x9c8>
	v_and_b32_e32 v9, 0x3ff, v10                               // 00000000C538: 361214FF 000003FF
	s_mov_b32 s7, exec_lo                                      // 00000000C540: BE87007E
	v_cmpx_ne_u32_e32 0, v8                                    // 00000000C544: 7D9A1080
	s_xor_b32 s7, exec_lo, s7                                  // 00000000C548: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C54C: BF870092
	v_lshlrev_b32_e32 v9, 13, v9                               // 00000000C550: 3012128D
	v_lshl_or_b32 v8, v8, 23, v9                               // 00000000C554: D6560008 04252F08
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C55C: BF870001
	v_add3_u32 v1, v8, v1, 0x38000000                          // 00000000C560: D6550001 03FE0308 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000C56C: BE873007
	s_cbranch_execz 19                                         // 00000000C570: BFA50013 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x9c0>
	s_mov_b32 s18, exec_lo                                     // 00000000C574: BE92007E
	v_cmpx_ne_u32_e32 0, v9                                    // 00000000C578: 7D9A1280
	s_cbranch_execz 15                                         // 00000000C57C: BFA5000F <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x9bc>
	v_clz_i32_u32_e32 v8, v9                                   // 00000000C580: 7E107309
	v_or_b32_e32 v1, 0x43000000, v1                            // 00000000C584: 380202FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C58C: BF870122
	v_xor_b32_e32 v9, 31, v8                                   // 00000000C590: 3A12109F
	v_lshlrev_b32_e32 v8, 23, v8                               // 00000000C594: 30101097
	v_sub_nc_u32_e32 v9, 9, v9                                 // 00000000C598: 4C121289
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C59C: BF870112
	v_sub_nc_u32_e32 v1, v1, v8                                // 00000000C5A0: 4C021101
	v_lshlrev_b32_e32 v9, v9, v10                              // 00000000C5A4: 30121509
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C5A8: BF870091
	v_lshlrev_b32_e32 v9, 14, v9                               // 00000000C5AC: 3012128E
	v_and_or_b32 v1, 0x7fc000, v9, v1                          // 00000000C5B0: D6570001 040612FF 007FC000
	s_or_b32 exec_lo, exec_lo, s18                             // 00000000C5BC: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C5C0: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000C5C4: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C5C8: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C5CC: 8C7E007E
	s_waitcnt vmcnt(0)                                         // 00000000C5D0: BF8903F7
	v_lshlrev_b32_e32 v8, 16, v3                               // 00000000C5D4: 30100690
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C5D8: 916A167E
	s_cbranch_vccnz 65468                                      // 00000000C5DC: BFA4FFBC <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x8d0>
	v_bfe_u32 v9, v3, 10, 5                                    // 00000000C5E0: D6100009 02151503
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C5E8: BF870122
	v_and_b32_e32 v8, 0x80000000, v8                           // 00000000C5EC: 361010FF 80000000
	s_mov_b32 s0, exec_lo                                      // 00000000C5F4: BE80007E
	v_cmpx_lt_i32_e32 30, v9                                   // 00000000C5F8: 7D82129E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000C5FC: 8D00007E
	v_lshlrev_b32_e32 v9, 13, v3                               // 00000000C600: 3012068D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C604: BF870091
	v_and_b32_e32 v9, 0x7fe000, v9                             // 00000000C608: 361212FF 007FE000
	v_or3_b32 v8, v9, v8, 0x7f800000                           // 00000000C610: D6580008 03FE1109 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000C61C: BE803000
	s_cbranch_execz 36                                         // 00000000C620: BFA50024 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xab4>
	v_and_b32_e32 v11, 0x3ff, v3                               // 00000000C624: 361606FF 000003FF
	s_mov_b32 s7, exec_lo                                      // 00000000C62C: BE87007E
	v_cmpx_ne_u32_e32 0, v9                                    // 00000000C630: 7D9A1280
	s_xor_b32 s7, exec_lo, s7                                  // 00000000C634: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C638: BF870092
	v_lshlrev_b32_e32 v11, 13, v11                             // 00000000C63C: 3016168D
	v_lshl_or_b32 v9, v9, 23, v11                              // 00000000C640: D6560009 042D2F09
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C648: BF870001
	v_add3_u32 v8, v9, v8, 0x38000000                          // 00000000C64C: D6550008 03FE1109 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000C658: BE873007
	s_cbranch_execz 19                                         // 00000000C65C: BFA50013 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xaac>
	s_mov_b32 s18, exec_lo                                     // 00000000C660: BE92007E
	v_cmpx_ne_u32_e32 0, v11                                   // 00000000C664: 7D9A1680
	s_cbranch_execz 15                                         // 00000000C668: BFA5000F <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xaa8>
	v_clz_i32_u32_e32 v9, v11                                  // 00000000C66C: 7E12730B
	v_or_b32_e32 v8, 0x43000000, v8                            // 00000000C670: 381010FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C678: BF870122
	v_xor_b32_e32 v11, 31, v9                                  // 00000000C67C: 3A16129F
	v_lshlrev_b32_e32 v9, 23, v9                               // 00000000C680: 30121297
	v_sub_nc_u32_e32 v11, 9, v11                               // 00000000C684: 4C161689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C688: BF870112
	v_sub_nc_u32_e32 v8, v8, v9                                // 00000000C68C: 4C101308
	v_lshlrev_b32_e32 v11, v11, v3                             // 00000000C690: 3016070B
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C694: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 00000000C698: 3016168E
	v_and_or_b32 v8, 0x7fc000, v11, v8                         // 00000000C69C: D6570008 042216FF 007FC000
	s_or_b32 exec_lo, exec_lo, s18                             // 00000000C6A8: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C6AC: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000C6B0: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000C6B4: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C6B8: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C6BC: 916A167E
	s_cbranch_vccnz 65413                                      // 00000000C6C0: BFA4FF85 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x8d8>
	v_bfe_u32 v12, v10, 26, 5                                  // 00000000C6C4: D610000C 0215350A
	v_and_b32_e32 v9, 0x80000000, v10                          // 00000000C6CC: 361214FF 80000000
	v_mov_b16_e32 v11.h, 0                                     // 00000000C6D4: 7F163880
	v_mov_b16_e32 v11.l, v10.h                                 // 00000000C6D8: 7E16398A
	s_mov_b32 s0, exec_lo                                      // 00000000C6DC: BE80007E
	v_cmpx_lt_i32_e32 30, v12                                  // 00000000C6E0: 7D82189E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000C6E4: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C6E8: BF870092
	v_lshlrev_b32_e32 v10, 13, v11                             // 00000000C6EC: 3014168D
	v_or3_b32 v9, v10, v9, 0x7f800000                          // 00000000C6F0: D6580009 03FE130A 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000C6FC: BE803000
	s_cbranch_execz 36                                         // 00000000C700: BFA50024 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xb94>
	v_bfe_u32 v10, v10, 16, 10                                 // 00000000C704: D610000A 0229210A
	s_mov_b32 s7, exec_lo                                      // 00000000C70C: BE87007E
	v_cmpx_ne_u32_e32 0, v12                                   // 00000000C710: 7D9A1880
	s_xor_b32 s7, exec_lo, s7                                  // 00000000C714: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C718: BF870092
	v_lshlrev_b32_e32 v10, 13, v10                             // 00000000C71C: 3014148D
	v_lshl_or_b32 v10, v12, 23, v10                            // 00000000C720: D656000A 04292F0C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C728: BF870001
	v_add3_u32 v9, v10, v9, 0x38000000                         // 00000000C72C: D6550009 03FE130A 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000C738: BE873007
	s_cbranch_execz 19                                         // 00000000C73C: BFA50013 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xb8c>
	s_mov_b32 s18, exec_lo                                     // 00000000C740: BE92007E
	v_cmpx_ne_u32_e32 0, v10                                   // 00000000C744: 7D9A1480
	s_cbranch_execz 15                                         // 00000000C748: BFA5000F <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xb88>
	v_clz_i32_u32_e32 v10, v10                                 // 00000000C74C: 7E14730A
	v_or_b32_e32 v9, 0x43000000, v9                            // 00000000C750: 381212FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C758: BF870122
	v_xor_b32_e32 v12, 31, v10                                 // 00000000C75C: 3A18149F
	v_lshlrev_b32_e32 v10, 23, v10                             // 00000000C760: 30141497
	v_sub_nc_u32_e32 v12, 9, v12                               // 00000000C764: 4C181889
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C768: BF870112
	v_sub_nc_u32_e32 v9, v9, v10                               // 00000000C76C: 4C121509
	v_lshlrev_b32_e32 v11, v12, v11                            // 00000000C770: 3016170C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C774: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 00000000C778: 3016168E
	v_and_or_b32 v9, 0x7fc000, v11, v9                         // 00000000C77C: D6570009 042616FF 007FC000
	s_or_b32 exec_lo, exec_lo, s18                             // 00000000C788: 8C7E127E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C78C: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000C790: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000C794: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000C798: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s22                        // 00000000C79C: 916A167E
	s_cbranch_vccnz 65361                                      // 00000000C7A0: BFA4FF51 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x8e8>
	v_bfe_u32 v12, v3, 26, 5                                   // 00000000C7A4: D610000C 02153503
	v_and_b32_e32 v10, 0x80000000, v3                          // 00000000C7AC: 361406FF 80000000
	v_mov_b16_e32 v11.h, 0                                     // 00000000C7B4: 7F163880
	v_mov_b16_e32 v11.l, v3.h                                  // 00000000C7B8: 7E163983
	s_mov_b32 s0, exec_lo                                      // 00000000C7BC: BE80007E
	v_cmpx_lt_i32_e32 30, v12                                  // 00000000C7C0: 7D82189E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000C7C4: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C7C8: BF870092
	v_lshlrev_b32_e32 v3, 13, v11                              // 00000000C7CC: 3006168D
	v_or3_b32 v10, v3, v10, 0x7f800000                         // 00000000C7D0: D658000A 03FE1503 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000C7DC: BE803000
	s_cbranch_execz 65038                                      // 00000000C7E0: BFA5FE0E <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x41c>
	v_bfe_u32 v3, v3, 16, 10                                   // 00000000C7E4: D6100003 02292103
	s_mov_b32 s7, exec_lo                                      // 00000000C7EC: BE87007E
	v_cmpx_ne_u32_e32 0, v12                                   // 00000000C7F0: 7D9A1880
	s_xor_b32 s7, exec_lo, s7                                  // 00000000C7F4: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C7F8: BF870092
	v_lshlrev_b32_e32 v3, 13, v3                               // 00000000C7FC: 3006068D
	v_lshl_or_b32 v3, v12, 23, v3                              // 00000000C800: D6560003 040D2F0C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C808: BF870001
	v_add3_u32 v10, v3, v10, 0x38000000                        // 00000000C80C: D655000A 03FE1503 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000C818: BE873007
	s_cbranch_execz 65021                                      // 00000000C81C: BFA5FDFD <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x414>
	s_mov_b32 s18, exec_lo                                     // 00000000C820: BE92007E
	v_cmpx_ne_u32_e32 0, v3                                    // 00000000C824: 7D9A0680
	s_cbranch_execz 65017                                      // 00000000C828: BFA5FDF9 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x410>
	v_clz_i32_u32_e32 v3, v3                                   // 00000000C82C: 7E067303
	v_or_b32_e32 v10, 0x43000000, v10                          // 00000000C830: 381414FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000C838: BF870122
	v_xor_b32_e32 v12, 31, v3                                  // 00000000C83C: 3A18069F
	v_lshlrev_b32_e32 v3, 23, v3                               // 00000000C840: 30060697
	v_sub_nc_u32_e32 v12, 9, v12                               // 00000000C844: 4C181889
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000C848: BF870112
	v_sub_nc_u32_e32 v3, v10, v3                               // 00000000C84C: 4C06070A
	v_lshlrev_b32_e32 v11, v12, v11                            // 00000000C850: 3016170C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000C854: BF870091
	v_lshlrev_b32_e32 v11, 14, v11                             // 00000000C858: 3016168E
	v_and_or_b32 v10, 0x7fc000, v11, v3                        // 00000000C85C: D657000A 040E16FF 007FC000
	s_branch 65001                                             // 00000000C868: BFA0FDE9 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x410>
	s_or_b32 exec_lo, exec_lo, s28                             // 00000000C86C: 8C7E1C7E
	v_mov_b32_e32 v1, v14                                      // 00000000C870: 7E02030E
	v_mov_b16_e32 v2.l, s1                                     // 00000000C874: 7E043801
	s_or_b32 exec_lo, exec_lo, s26                             // 00000000C878: 8C7E1A7E
	v_lshl_add_u32 v3, v0, 2, 0                                // 00000000C87C: D6460003 02010500
	s_mov_b32 s0, 0                                            // 00000000C884: BE800080
	s_mov_b32 s1, exec_lo                                      // 00000000C888: BE81007E
	ds_store_b32 v3, v1                                        // 00000000C88C: D8340000 00000103
	s_waitcnt lgkmcnt(0)                                       // 00000000C894: BF89FC07
	s_barrier                                                  // 00000000C898: BFBD0000
	buffer_gl0_inv                                             // 00000000C89C: E0AC0000 00000000
	v_cmpx_lt_u16_e32 1, v2.l                                  // 00000000C8A4: 7D720481
	s_cbranch_execz 33                                         // 00000000C8A8: BFA50021 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xd30>
	v_lshrrev_b16 v1.l, 1, v2.l                                // 00000000C8AC: D7390001 00020481
	v_mov_b16_e32 v1.h, 0                                      // 00000000C8B4: 7F023880
	s_branch 13                                                // 00000000C8B8: BFA0000D <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xcf0>
	s_nop 0                                                    // 00000000C8BC: BF800000
	s_or_b32 exec_lo, exec_lo, s4                              // 00000000C8C0: 8C7E047E
	v_lshrrev_b32_e32 v2, 1, v1                                // 00000000C8C4: 32040281
	v_cmp_gt_u32_e32 vcc_lo, 2, v1                             // 00000000C8C8: 7C980282
	s_waitcnt lgkmcnt(0)                                       // 00000000C8CC: BF89FC07
	s_barrier                                                  // 00000000C8D0: BFBD0000
	buffer_gl0_inv                                             // 00000000C8D4: E0AC0000 00000000
	v_mov_b32_e32 v1, v2                                       // 00000000C8DC: 7E020302
	s_or_b32 s0, vcc_lo, s0                                    // 00000000C8E0: 8C00006A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C8E4: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s0                        // 00000000C8E8: 917E007E
	s_cbranch_execz 16                                         // 00000000C8EC: BFA50010 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xd30>
	s_mov_b32 s4, exec_lo                                      // 00000000C8F0: BE84007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000C8F4: BF870001
	v_cmpx_lt_u32_e64 v0, v1                                   // 00000000C8F8: D4C9007E 00020300
	s_cbranch_execz 65519                                      // 00000000C900: BFA5FFEF <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xcc0>
	v_lshl_add_u32 v2, v1, 2, v3                               // 00000000C904: D6460002 040D0501
	ds_load_b32 v2, v2                                         // 00000000C90C: D8D80000 02000002
	ds_load_b32 v4, v3                                         // 00000000C914: D8D80000 04000003
	s_waitcnt lgkmcnt(0)                                       // 00000000C91C: BF89FC07
	v_add_f32_e32 v2, v2, v4                                   // 00000000C920: 06040902
	ds_store_b32 v3, v2                                        // 00000000C924: D8340000 00000203
	s_branch 65508                                             // 00000000C92C: BFA0FFE4 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xcc0>
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000C930: 8C7E017E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C934: BF870009
	s_mov_b32 s0, exec_lo                                      // 00000000C938: BE80007E
	v_cmpx_eq_u32_e32 0, v0                                    // 00000000C93C: 7D940080
	s_cbranch_execz 10                                         // 00000000C940: BFA5000A <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0xd6c>
	v_mov_b32_e32 v0, 0                                        // 00000000C944: 7E000280
	s_lshl_b64 s[0:1], s[2:3], 2                               // 00000000C948: 84808202
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000C94C: BF870009
	s_add_u32 s0, s16, s0                                      // 00000000C950: 80000010
	s_addc_u32 s1, s17, s1                                     // 00000000C954: 82010111
	ds_load_b32 v1, v0                                         // 00000000C958: D8D80000 01000000
	s_waitcnt lgkmcnt(0)                                       // 00000000C960: BF89FC07
	global_store_b32 v0, v1, s[0:1]                            // 00000000C964: DC6A0000 00000100
	s_endpgm                                                   // 00000000C96C: BFB00000
	s_load_b128 s[12:15], s[0:1], null                         // 00000000C970: F4080300 F8000000
	s_branch 64852                                             // 00000000C978: BFA0FD54 <_ZN12_GLOBAL__N_119graph_global_kernelEPKjS1_PKiPfllllli+0x2cc>
		...

000000000000ca00 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli>:
	s_clause 0x3                                               // 00000000CA00: BF850003
	s_load_b256 s[4:11], s[0:1], 0x20                          // 00000000CA04: F40C0100 F8000020
	s_load_b64 s[12:13], s[0:1], 0x8                           // 00000000CA0C: F4040300 F8000008
	s_load_b64 s[18:19], s[0:1], 0x18                          // 00000000CA14: F4040480 F8000018
	s_load_b64 s[16:17], s[0:1], 0x40                          // 00000000CA1C: F4040400 F8000040
	v_mov_b32_e32 v2, 0                                        // 00000000CA24: 7E040280
	s_mov_b32 s22, 0                                           // 00000000CA28: BE960080
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000CA2C: BF8700A1
	v_dual_mov_b32 v1, v2 :: v_dual_lshlrev_b32 v12, 2, v0     // 00000000CA30: CA220102 010C0082
	s_waitcnt lgkmcnt(0)                                       // 00000000CA38: BF89FC07
	v_cmp_gt_i64_e64 s2, s[10:11], v[0:1]                      // 00000000CA3C: D4540002 0002000A
	v_cvt_f32_u32_e32 v13, s8                                  // 00000000CA44: 7E1A0C08
	s_and_saveexec_b32 s14, s2                                 // 00000000CA48: BE8E2002
	s_cbranch_execz 302                                        // 00000000CA4C: BFA5012E <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x508>
	s_load_b64 s[20:21], s[0:1], 0x10                          // 00000000CA50: F4040500 F8000010
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000CA58: BF870001
	v_rcp_iflag_f32_e32 v3, v13                                // 00000000CA5C: 7E06570D
	s_mul_i32 s3, s7, s15                                      // 00000000CA60: 96030F07
	s_mul_hi_u32 s7, s6, s15                                   // 00000000CA64: 96870F06
	s_mul_i32 s6, s6, s15                                      // 00000000CA68: 96060F06
	s_add_i32 s7, s7, s3                                       // 00000000CA6C: 81070307
	s_clause 0x1                                               // 00000000CA70: BF850001
	s_load_b64 s[26:27], s[0:1], null                          // 00000000CA74: F4040680 F8000000
	s_load_b32 s3, s[0:1], 0x5c                                // 00000000CA7C: F40000C0 F800005C
	s_lshl_b64 s[6:7], s[6:7], 2                               // 00000000CA84: 84868206
	s_waitcnt_depctr 0xfff                                     // 00000000CA88: BF880FFF
	v_dual_mul_f32 v3, 0x4f7ffffe, v3 :: v_dual_add_nc_u32 v14, 0, v12// 00000000CA8C: C8E006FF 030E1880 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 00000000CA98: BF8704D1
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000CA9C: 7E060F03
	s_waitcnt lgkmcnt(0)                                       // 00000000CAA0: BF89FC07
	s_add_u32 s23, s20, s6                                     // 00000000CAA4: 80170614
	s_addc_u32 s24, s21, s7                                    // 00000000CAA8: 82180715
	s_sub_i32 s6, 0, s8                                        // 00000000CAAC: 81860880
	v_mul_lo_u32 v4, s6, v3                                    // 00000000CAB0: D72C0004 00020606
	s_and_b32 s25, s3, 0xffff                                  // 00000000CAB8: 8B19FF03 0000FFFF
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000CAC0: BF8700A1
	v_mul_hi_u32 v6, v3, v4                                    // 00000000CAC4: D72D0006 00020903
	v_add_co_u32 v4, s6, s26, v12                              // 00000000CACC: D7000604 0002181A
	v_add_co_ci_u32_e64 v5, null, s27, 0, s6                   // 00000000CAD4: D5207C05 0019001B
	s_lshl_b32 s26, s25, 2                                     // 00000000CADC: 841A8219
	s_ashr_i32 s6, s9, 31                                      // 00000000CAE0: 86069F09
	v_add_nc_u32_e32 v15, v3, v6                               // 00000000CAE4: 4A1E0D03
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 00000000CAE8: CA100101 07060100
	s_branch 19                                                // 00000000CAF0: BFA00013 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x140>
	s_or_b32 exec_lo, exec_lo, s3                              // 00000000CAF4: 8C7E037E
	v_add_co_u32 v6, vcc_lo, v6, s25                           // 00000000CAF8: D7006A06 00003306
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000CB00: BF870001
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000CB04: D5207C07 01AA0E80
	v_add_co_u32 v4, s3, v4, s26                               // 00000000CB0C: D7000304 00003504
	s_waitcnt vmcnt(0)                                         // 00000000CB14: BF8903F7
	ds_store_b32 v14, v3                                       // 00000000CB18: D8340000 0000030E
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 00000000CB20: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s3                    // 00000000CB24: D5207C05 000E0A80
	v_add_nc_u32_e32 v14, s26, v14                             // 00000000CB2C: 4A1C1C1A
	s_or_b32 s22, vcc_lo, s22                                  // 00000000CB30: 8C16166A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000CB34: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s22                       // 00000000CB38: 917E167E
	s_cbranch_execz 242                                        // 00000000CB3C: BFA500F2 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x508>
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000CB40: BF8700A1
	v_or_b32_e32 v3, s9, v7                                    // 00000000CB44: 38060E09
	s_mov_b32 s3, exec_lo                                      // 00000000CB48: BE83007E
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000CB4C: 7DBA0480
	s_xor_b32 s27, exec_lo, s3                                 // 00000000CB50: 8D1B037E
	s_cbranch_execz 175                                        // 00000000CB54: BFA500AF <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x414>
	s_add_u32 s20, s8, s6                                      // 00000000CB58: 80140608
	s_mov_b32 s7, s6                                           // 00000000CB5C: BE870006
	s_addc_u32 s21, s9, s6                                     // 00000000CB60: 82150609
	v_ashrrev_i32_e32 v18, 31, v7                              // 00000000CB64: 34240E9F
	s_xor_b64 s[20:21], s[20:21], s[6:7]                       // 00000000CB68: 8D940614
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000CB6C: BF870159
	v_cvt_f32_u32_e32 v3, s20                                  // 00000000CB70: 7E060C14
	v_cvt_f32_u32_e32 v8, s21                                  // 00000000CB74: 7E100C15
	s_sub_u32 s3, 0, s20                                       // 00000000CB78: 80831480
	s_subb_u32 s29, 0, s21                                     // 00000000CB7C: 829D1580
	v_add_co_u32 v9, vcc_lo, v6, v18                           // 00000000CB80: D7006A09 00022506
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 00000000CB88: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CB90: BF870112
	v_xor_b32_e32 v19, v9, v18                                 // 00000000CB94: 3A262509
	v_rcp_f32_e32 v3, v3                                       // 00000000CB98: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000CB9C: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000CBA0: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000CBA8: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 00000000CBAC: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 00000000CBB4: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000CBB8: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 00000000CBBC: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 00000000CBC4: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000CBC8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CBCC: BF870112
	v_readfirstlane_b32 s7, v8                                 // 00000000CBD0: 7E0E0508
	v_readfirstlane_b32 s28, v3                                // 00000000CBD4: 7E380503
	s_mul_i32 s30, s3, s7                                      // 00000000CBD8: 961E0703
	v_add_co_ci_u32_e64 v3, null, v7, v18, vcc_lo              // 00000000CBDC: D5207C03 01AA2507
	s_mul_hi_u32 s33, s3, s28                                  // 00000000CBE4: 96A11C03
	s_mul_i32 s31, s29, s28                                    // 00000000CBE8: 961F1C1D
	s_add_i32 s30, s33, s30                                    // 00000000CBEC: 811E1E21
	s_mul_i32 s34, s3, s28                                     // 00000000CBF0: 96221C03
	s_add_i32 s30, s30, s31                                    // 00000000CBF4: 811E1F1E
	s_mul_hi_u32 s33, s28, s34                                 // 00000000CBF8: 96A1221C
	s_mul_i32 s36, s28, s30                                    // 00000000CBFC: 96241E1C
	s_mul_hi_u32 s35, s7, s34                                  // 00000000CC00: 96A32207
	s_mul_i32 s31, s7, s34                                     // 00000000CC04: 961F2207
	s_mul_hi_u32 s34, s28, s30                                 // 00000000CC08: 96A21E1C
	s_add_u32 s33, s33, s36                                    // 00000000CC0C: 80212421
	s_addc_u32 s34, 0, s34                                     // 00000000CC10: 82222280
	s_mul_hi_u32 s37, s7, s30                                  // 00000000CC14: 96A51E07
	s_add_u32 s31, s33, s31                                    // 00000000CC18: 801F1F21
	s_mul_i32 s30, s7, s30                                     // 00000000CC1C: 961E1E07
	s_addc_u32 s31, s34, s35                                   // 00000000CC20: 821F2322
	s_addc_u32 s33, s37, 0                                     // 00000000CC24: 82218025
	s_add_u32 s30, s31, s30                                    // 00000000CC28: 801E1E1F
	s_addc_u32 s31, 0, s33                                     // 00000000CC2C: 821F2180
	s_add_u32 s28, s28, s30                                    // 00000000CC30: 801C1E1C
	s_cselect_b32 s30, -1, 0                                   // 00000000CC34: 981E80C1
	s_mul_hi_u32 s33, s3, s28                                  // 00000000CC38: 96A11C03
	s_cmp_lg_u32 s30, 0                                        // 00000000CC3C: BF07801E
	s_mul_i32 s30, s3, s28                                     // 00000000CC40: 961E1C03
	s_addc_u32 s7, s7, s31                                     // 00000000CC44: 82071F07
	s_mul_i32 s29, s29, s28                                    // 00000000CC48: 961D1C1D
	s_mul_i32 s3, s3, s7                                       // 00000000CC4C: 96030703
	s_mul_hi_u32 s31, s28, s30                                 // 00000000CC50: 969F1E1C
	s_add_i32 s3, s33, s3                                      // 00000000CC54: 81030321
	s_mul_hi_u32 s33, s7, s30                                  // 00000000CC58: 96A11E07
	s_add_i32 s3, s3, s29                                      // 00000000CC5C: 81031D03
	s_mul_i32 s29, s7, s30                                     // 00000000CC60: 961D1E07
	s_mul_i32 s35, s28, s3                                     // 00000000CC64: 9623031C
	s_mul_hi_u32 s34, s28, s3                                  // 00000000CC68: 96A2031C
	s_add_u32 s31, s31, s35                                    // 00000000CC6C: 801F231F
	s_addc_u32 s34, 0, s34                                     // 00000000CC70: 82222280
	s_mul_hi_u32 s30, s7, s3                                   // 00000000CC74: 969E0307
	s_add_u32 s29, s31, s29                                    // 00000000CC78: 801D1D1F
	s_mul_i32 s3, s7, s3                                       // 00000000CC7C: 96030307
	s_addc_u32 s29, s34, s33                                   // 00000000CC80: 821D2122
	s_addc_u32 s30, s30, 0                                     // 00000000CC84: 821E801E
	s_add_u32 s3, s29, s3                                      // 00000000CC88: 8003031D
	s_addc_u32 s29, 0, s30                                     // 00000000CC8C: 821D1E80
	s_add_u32 s3, s28, s3                                      // 00000000CC90: 8003031C
	s_cselect_b32 s28, -1, 0                                   // 00000000CC94: 981C80C1
	v_xor_b32_e32 v3, v3, v18                                  // 00000000CC98: 3A062503
	s_cmp_lg_u32 s28, 0                                        // 00000000CC9C: BF07801C
	v_mul_hi_u32 v20, v19, s3                                  // 00000000CCA0: D72D0014 00000713
	s_addc_u32 s7, s7, s29                                     // 00000000CCA8: 82071D07
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000CCAC: BF8701B9
	v_mad_u64_u32 v[8:9], null, v19, s7, 0                     // 00000000CCB0: D6FE7C08 02000F13
	v_mad_u64_u32 v[10:11], null, v3, s3, 0                    // 00000000CCB8: D6FE7C0A 02000703
	v_mad_u64_u32 v[16:17], null, v3, s7, 0                    // 00000000CCC0: D6FE7C10 02000F03
	v_add_co_u32 v8, vcc_lo, v20, v8                           // 00000000CCC8: D7006A08 00021114
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CCD0: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000CCD4: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 00000000CCDC: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000CCE4: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 00000000CCE8: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v17, vcc_lo             // 00000000CCEC: 40122280
	v_add_co_u32 v10, vcc_lo, v8, v16                          // 00000000CCF0: D7006A0A 00022108
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CCF8: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 00000000CCFC: D5207C0B 01AA1280
	v_mul_lo_u32 v16, s21, v10                                 // 00000000CD04: D72C0010 00021415
	v_mad_u64_u32 v[8:9], null, s20, v10, 0                    // 00000000CD0C: D6FE7C08 02021414
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CD14: BF870113
	v_mul_lo_u32 v17, s20, v11                                 // 00000000CD18: D72C0011 00021614
	v_sub_co_u32 v8, vcc_lo, v19, v8                           // 00000000CD20: D7016A08 00021113
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000CD28: BF8700A2
	v_add3_u32 v9, v9, v17, v16                                // 00000000CD2C: D6550009 04422309
	v_add_co_u32 v17, s3, v10, 2                               // 00000000CD34: D7000311 0001050A
	v_add_co_ci_u32_e64 v19, null, 0, v11, s3                  // 00000000CD3C: D5207C13 000E1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000CD44: BF8701B3
	v_sub_nc_u32_e32 v16, v3, v9                               // 00000000CD48: 4C201303
	v_sub_co_u32 v20, s3, v8, s20                              // 00000000CD4C: D7010314 00002908
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 00000000CD54: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v16, null, s21, v16, vcc_lo         // 00000000CD5C: D5227C10 01AA2015
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CD64: BF870113
	v_cmp_le_u32_e32 vcc_lo, s20, v20                          // 00000000CD68: 7C962814
	v_subrev_co_ci_u32_e64 v16, null, 0, v16, s3               // 00000000CD6C: D5227C10 000E2080
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 00000000CD74: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000CD7C: BF870002
	v_cmp_le_u32_e32 vcc_lo, s21, v16                          // 00000000CD80: 7C962015
	v_cndmask_b32_e64 v20, 0, -1, vcc_lo                       // 00000000CD84: D5010014 01A98280
	v_cmp_le_u32_e32 vcc_lo, s20, v8                           // 00000000CD8C: 7C961014
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 00000000CD90: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s21, v3                           // 00000000CD98: 7C960615
	v_cndmask_b32_e64 v21, 0, -1, vcc_lo                       // 00000000CD9C: D5010015 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s21, v16                          // 00000000CDA4: 7C942015
	v_cndmask_b32_e32 v9, v20, v9, vcc_lo                      // 00000000CDA8: 02121314
	v_add_co_u32 v16, vcc_lo, v10, 1                           // 00000000CDAC: D7006A10 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000CDB4: BF8701D1
	v_add_co_ci_u32_e64 v20, null, 0, v11, vcc_lo              // 00000000CDB8: D5207C14 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s21, v3                           // 00000000CDC0: 7C940615
	v_cndmask_b32_e32 v3, v21, v8, vcc_lo                      // 00000000CDC4: 02061115
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 00000000CDC8: 7C9A1280
	v_xor_b32_e32 v9, s6, v18                                  // 00000000CDCC: 3A122406
	v_cmp_ne_u32_e64 s3, 0, v3                                 // 00000000CDD0: D44D0003 00020680
	v_cndmask_b32_e32 v3, v16, v17, vcc_lo                     // 00000000CDD8: 02062310
	v_cndmask_b32_e32 v8, v20, v19, vcc_lo                     // 00000000CDDC: 02102714
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CDE0: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s3                          // 00000000CDE4: D5010003 000E070A
	v_cndmask_b32_e64 v8, v11, v8, s3                          // 00000000CDEC: D5010008 000E110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CDF4: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 00000000CDF8: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 00000000CDFC: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000CE00: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 00000000CE04: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 00000000CE0C: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s3, s27                            // 00000000CE14: BE83301B
	s_cbranch_execz 18                                         // 00000000CE18: BFA50012 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x464>
	v_mul_hi_u32 v3, v6, v15                                   // 00000000CE1C: D72D0003 00021F06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000CE24: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 00000000CE28: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 00000000CE30: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000CE34: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 00000000CE38: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000CE3C: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 00000000CE40: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CE48: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 00000000CE4C: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000CE50: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000CE54: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 00000000CE58: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 00000000CE5C: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s3                              // 00000000CE64: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000CE68: BF870121
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 00000000CE6C: D73C0008 00021082
	v_mov_b32_e32 v3, 0                                        // 00000000CE74: 7E060280
	v_add_co_u32 v10, vcc_lo, s23, v8                          // 00000000CE78: D7006A0A 00021017
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000CE80: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s24, v9, vcc_lo             // 00000000CE84: D5207C0B 01AA1218
	global_load_b32 v10, v[10:11], off                         // 00000000CE8C: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 00000000CE94: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 00000000CE98: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 00000000CE9C: 7CA214C1
	v_cmp_gt_i64_e64 s3, s[4:5], v[10:11]                      // 00000000CEA0: D4540003 00021404
	s_and_b32 s7, vcc_lo, s3                                   // 00000000CEA8: 8B07036A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000CEAC: BF870009
	s_and_saveexec_b32 s3, s7                                  // 00000000CEB0: BE832007
	s_cbranch_execz 65295                                      // 00000000CEB4: BFA5FF0F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xf4>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 00000000CEB8: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000CEC0: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 00000000CEC4: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 00000000CECC: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000CED4: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 00000000CED8: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 00000000CEE0: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 00000000CEE8: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000CEF0: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 00000000CEF4: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 00000000CEFC: DC520000 037C0008
	s_branch 65275                                             // 00000000CF04: BFA0FEFB <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xf4>
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000CF08: 8C7E0E7E
	v_cmp_lt_i64_e64 s3, s[16:17], 1                           // 00000000CF0C: D4510003 00010210
	s_waitcnt lgkmcnt(0)                                       // 00000000CF14: BF89FC07
	s_barrier                                                  // 00000000CF18: BFBD0000
	buffer_gl0_inv                                             // 00000000CF1C: E0AC0000 00000000
	s_and_b32 vcc_lo, exec_lo, s3                              // 00000000CF24: 8B6A037E
	s_cbranch_vccnz 605                                        // 00000000CF28: BFA4025D <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xea0>
	s_clause 0x1                                               // 00000000CF2C: BF850001
	s_load_b32 s4, s[0:1], 0x48                                // 00000000CF30: F4000100 F8000048
	s_load_b32 s1, s[0:1], 0x5c                                // 00000000CF38: F4000040 F800005C
	v_rcp_iflag_f32_e32 v2, v13                                // 00000000CF40: 7E04570D
	s_lshl_b32 s0, s10, 2                                      // 00000000CF44: 8400820A
	s_mul_i32 s5, s17, s15                                     // 00000000CF48: 96050F11
	s_add_i32 s3, s0, 0                                        // 00000000CF4C: 81038000
	s_mul_hi_u32 s6, s16, s15                                  // 00000000CF50: 96860F10
	s_mul_i32 s0, s16, s15                                     // 00000000CF54: 96000F10
	v_add_nc_u32_e32 v8, s3, v12                               // 00000000CF58: 4A101803
	s_waitcnt_depctr 0xfff                                     // 00000000CF5C: BF880FFF
	v_dual_mul_f32 v2, 0x4f7ffffe, v2 :: v_dual_add_nc_u32 v9, 0, v12// 00000000CF60: C8E004FF 02081880 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000CF6C: BF870001
	v_cvt_u32_f32_e32 v3, v2                                   // 00000000CF70: 7E060F02
	s_waitcnt lgkmcnt(0)                                       // 00000000CF74: BF89FC07
	s_cmp_eq_u32 s4, 0                                         // 00000000CF78: BF068004
	s_cselect_b32 s20, -1, 0                                   // 00000000CF7C: 981480C1
	s_and_b32 s21, s1, 0xffff                                  // 00000000CF80: 8B15FF01 0000FFFF
	s_bfe_u32 s22, s1, 0xf0001                                 // 00000000CF88: 9316FF01 000F0001
	s_cmp_gt_u32 s21, 1                                        // 00000000CF90: BF088115
	s_cselect_b32 s23, -1, 0                                   // 00000000CF94: 981780C1
	s_add_i32 s1, s6, s5                                       // 00000000CF98: 81010506
	s_mov_b64 s[4:5], 0                                        // 00000000CF9C: BE840180
	s_lshl_b64 s[0:1], s[0:1], 2                               // 00000000CFA0: 84808200
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000CFA4: BF870009
	s_add_u32 s18, s18, s0                                     // 00000000CFA8: 80120012
	s_addc_u32 s19, s19, s1                                    // 00000000CFAC: 82130113
	s_sub_i32 s0, 0, s8                                        // 00000000CFB0: 81800880
	s_lshl_b32 s24, s21, 2                                     // 00000000CFB4: 84188215
	v_mul_lo_u32 v2, s0, v3                                    // 00000000CFB8: D72C0002 00020600
	v_cmp_eq_u32_e64 s0, 0, v0                                 // 00000000CFC0: D44A0000 00020080
	s_ashr_i32 s6, s9, 31                                      // 00000000CFC8: 86069F09
	v_mul_hi_u32 v4, v3, v2                                    // 00000000CFCC: D72D0004 00020503
	v_mov_b32_e32 v2, 0                                        // 00000000CFD4: 7E040280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000CFD8: BF870002
	v_add_nc_u32_e32 v10, v3, v4                               // 00000000CFDC: 4A140903
	s_branch 9                                                 // 00000000CFE0: BFA00009 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x608>
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000CFE4: 8C7E017E
	s_add_u32 s4, s4, 1                                        // 00000000CFE8: 80048104
	s_addc_u32 s5, s5, 0                                       // 00000000CFEC: 82058005
	s_waitcnt_vscnt null, 0x0                                  // 00000000CFF0: BC7C0000
	s_cmp_eq_u64 s[4:5], s[16:17]                              // 00000000CFF4: BF101004
	s_barrier                                                  // 00000000CFF8: BFBD0000
	buffer_gl0_inv                                             // 00000000CFFC: E0AC0000 00000000
	s_cbranch_scc1 550                                         // 00000000D004: BFA20226 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xea0>
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000D008: BF870002
	v_mov_b32_e32 v11, v2                                      // 00000000D00C: 7E160302
	s_and_saveexec_b32 s25, s2                                 // 00000000D010: BE992002
	s_cbranch_execz 486                                        // 00000000D014: BFA501E6 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xdb0>
	s_mul_i32 s1, s4, s9                                       // 00000000D018: 96010904
	s_mul_hi_u32 s7, s4, s8                                    // 00000000D01C: 96870804
	s_mul_i32 s14, s4, s8                                      // 00000000D020: 960E0804
	s_add_i32 s1, s7, s1                                       // 00000000D024: 81010107
	s_mul_i32 s7, s5, s8                                       // 00000000D028: 96070805
	v_dual_mov_b32 v11, 0 :: v_dual_mov_b32 v12, v9            // 00000000D02C: CA100080 0B0C0109
	s_add_i32 s15, s1, s7                                      // 00000000D034: 810F0701
	v_dual_mov_b32 v5, v1 :: v_dual_mov_b32 v4, v0             // 00000000D038: CA100101 05040100
	s_lshl_b64 s[14:15], s[14:15], 2                           // 00000000D040: 848E820E
	s_mov_b32 s27, 0                                           // 00000000D044: BE9B0080
	s_add_u32 s26, s12, s14                                    // 00000000D048: 801A0E0C
	s_addc_u32 s28, s13, s15                                   // 00000000D04C: 821C0F0D
	s_branch 20                                                // 00000000D050: BFA00014 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x6a4>
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000D054: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D058: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000D05C: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D060: BF870009
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000D064: 8C7E017E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000D068: BF8700A1
	v_mul_f32_e32 v6, v14, v13                                 // 00000000D06C: 100C1B0E
	v_add_co_u32 v4, vcc_lo, v4, s21                           // 00000000D070: D7006A04 00002B04
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo                // 00000000D078: D5207C05 01AA0A80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000D080: BF8701A3
	v_fmac_f32_e32 v6, v3, v7                                  // 00000000D084: 560C0F03
	v_add_nc_u32_e32 v12, s24, v12                             // 00000000D088: 4A181818
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[4:5]                  // 00000000D08C: 7CA6080A
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000D090: BF8704A3
	v_add_f32_e32 v11, v11, v6                                 // 00000000D094: 06160D0B
	s_or_b32 s27, vcc_lo, s27                                  // 00000000D098: 8C1B1B6A
	s_and_not1_b32 exec_lo, exec_lo, s27                       // 00000000D09C: 917E1B7E
	s_cbranch_execz 450                                        // 00000000D0A0: BFA501C2 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xdac>
	v_or_b32_e32 v3, s9, v5                                    // 00000000D0A4: 38060A09
	s_mov_b32 s1, exec_lo                                      // 00000000D0A8: BE81007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D0AC: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000D0B0: 7DBA0480
	s_xor_b32 s29, exec_lo, s1                                 // 00000000D0B4: 8D1D017E
	s_cbranch_execz 176                                        // 00000000D0B8: BFA500B0 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x97c>
	s_add_u32 s14, s8, s6                                      // 00000000D0BC: 800E0608
	s_mov_b32 s7, s6                                           // 00000000D0C0: BE870006
	s_addc_u32 s15, s9, s6                                     // 00000000D0C4: 820F0609
	v_ashrrev_i32_e32 v17, 31, v5                              // 00000000D0C8: 34220A9F
	s_xor_b64 s[14:15], s[14:15], s[6:7]                       // 00000000D0CC: 8D8E060E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000D0D0: BF870159
	v_cvt_f32_u32_e32 v3, s14                                  // 00000000D0D4: 7E060C0E
	v_cvt_f32_u32_e32 v6, s15                                  // 00000000D0D8: 7E0C0C0F
	s_sub_u32 s1, 0, s14                                       // 00000000D0DC: 80810E80
	s_subb_u32 s31, 0, s15                                     // 00000000D0E0: 829F0F80
	v_add_co_u32 v7, vcc_lo, v4, v17                           // 00000000D0E4: D7006A07 00022304
	v_fmac_f32_e32 v3, 0x4f800000, v6                          // 00000000D0EC: 56060CFF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D0F4: BF870112
	v_xor_b32_e32 v18, v7, v17                                 // 00000000D0F8: 3A242307
	v_rcp_f32_e32 v3, v3                                       // 00000000D0FC: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000D100: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000D104: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D10C: BF870091
	v_mul_f32_e32 v6, 0x2f800000, v3                           // 00000000D110: 100C06FF 2F800000
	v_trunc_f32_e32 v6, v6                                     // 00000000D118: 7E0C4306
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D11C: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v6                          // 00000000D120: 56060CFF CF800000
	v_cvt_u32_f32_e32 v6, v6                                   // 00000000D128: 7E0C0F06
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000D12C: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D130: BF870112
	v_readfirstlane_b32 s7, v6                                 // 00000000D134: 7E0E0506
	v_readfirstlane_b32 s30, v3                                // 00000000D138: 7E3C0503
	s_mul_i32 s33, s1, s7                                      // 00000000D13C: 96210701
	v_add_co_ci_u32_e64 v3, null, v5, v17, vcc_lo              // 00000000D140: D5207C03 01AA2305
	s_mul_hi_u32 s35, s1, s30                                  // 00000000D148: 96A31E01
	s_mul_i32 s34, s31, s30                                    // 00000000D14C: 96221E1F
	s_add_i32 s33, s35, s33                                    // 00000000D150: 81212123
	s_mul_i32 s36, s1, s30                                     // 00000000D154: 96241E01
	s_add_i32 s33, s33, s34                                    // 00000000D158: 81212221
	s_mul_hi_u32 s35, s30, s36                                 // 00000000D15C: 96A3241E
	s_mul_i32 s38, s30, s33                                    // 00000000D160: 9626211E
	s_mul_hi_u32 s37, s7, s36                                  // 00000000D164: 96A52407
	s_mul_i32 s34, s7, s36                                     // 00000000D168: 96222407
	s_mul_hi_u32 s36, s30, s33                                 // 00000000D16C: 96A4211E
	s_add_u32 s35, s35, s38                                    // 00000000D170: 80232623
	s_addc_u32 s36, 0, s36                                     // 00000000D174: 82242480
	s_mul_hi_u32 s39, s7, s33                                  // 00000000D178: 96A72107
	s_add_u32 s34, s35, s34                                    // 00000000D17C: 80222223
	s_mul_i32 s33, s7, s33                                     // 00000000D180: 96212107
	s_addc_u32 s34, s36, s37                                   // 00000000D184: 82222524
	s_addc_u32 s35, s39, 0                                     // 00000000D188: 82238027
	s_add_u32 s33, s34, s33                                    // 00000000D18C: 80212122
	s_addc_u32 s34, 0, s35                                     // 00000000D190: 82222380
	s_add_u32 s30, s30, s33                                    // 00000000D194: 801E211E
	s_cselect_b32 s33, -1, 0                                   // 00000000D198: 982180C1
	s_mul_hi_u32 s35, s1, s30                                  // 00000000D19C: 96A31E01
	s_cmp_lg_u32 s33, 0                                        // 00000000D1A0: BF078021
	s_mul_i32 s33, s1, s30                                     // 00000000D1A4: 96211E01
	s_addc_u32 s7, s7, s34                                     // 00000000D1A8: 82072207
	s_mul_i32 s31, s31, s30                                    // 00000000D1AC: 961F1E1F
	s_mul_i32 s1, s1, s7                                       // 00000000D1B0: 96010701
	s_mul_hi_u32 s34, s30, s33                                 // 00000000D1B4: 96A2211E
	s_add_i32 s1, s35, s1                                      // 00000000D1B8: 81010123
	s_mul_hi_u32 s35, s7, s33                                  // 00000000D1BC: 96A32107
	s_add_i32 s1, s1, s31                                      // 00000000D1C0: 81011F01
	s_mul_i32 s31, s7, s33                                     // 00000000D1C4: 961F2107
	s_mul_i32 s37, s30, s1                                     // 00000000D1C8: 9625011E
	s_mul_hi_u32 s36, s30, s1                                  // 00000000D1CC: 96A4011E
	s_add_u32 s34, s34, s37                                    // 00000000D1D0: 80222522
	s_addc_u32 s36, 0, s36                                     // 00000000D1D4: 82242480
	s_mul_hi_u32 s33, s7, s1                                   // 00000000D1D8: 96A10107
	s_add_u32 s31, s34, s31                                    // 00000000D1DC: 801F1F22
	s_mul_i32 s1, s7, s1                                       // 00000000D1E0: 96010107
	s_addc_u32 s31, s36, s35                                   // 00000000D1E4: 821F2324
	s_addc_u32 s33, s33, 0                                     // 00000000D1E8: 82218021
	s_add_u32 s1, s31, s1                                      // 00000000D1EC: 8001011F
	s_addc_u32 s31, 0, s33                                     // 00000000D1F0: 821F2180
	s_add_u32 s1, s30, s1                                      // 00000000D1F4: 8001011E
	s_cselect_b32 s30, -1, 0                                   // 00000000D1F8: 981E80C1
	v_xor_b32_e32 v3, v3, v17                                  // 00000000D1FC: 3A062303
	s_cmp_lg_u32 s30, 0                                        // 00000000D200: BF07801E
	v_mul_hi_u32 v19, v18, s1                                  // 00000000D204: D72D0013 00000312
	s_addc_u32 s7, s7, s31                                     // 00000000D20C: 82071F07
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000D210: BF8701B9
	v_mad_u64_u32 v[6:7], null, v18, s7, 0                     // 00000000D214: D6FE7C06 02000F12
	v_mad_u64_u32 v[13:14], null, v3, s1, 0                    // 00000000D21C: D6FE7C0D 02000303
	v_mad_u64_u32 v[15:16], null, v3, s7, 0                    // 00000000D224: D6FE7C0F 02000F03
	v_add_co_u32 v6, vcc_lo, v19, v6                           // 00000000D22C: D7006A06 00020D13
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D234: BF870111
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000D238: D5207C07 01AA0E80
	v_add_co_u32 v6, vcc_lo, v6, v13                           // 00000000D240: D7006A06 00021B06
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D248: BF870122
	v_add_co_ci_u32_e32 v6, vcc_lo, v7, v14, vcc_lo            // 00000000D24C: 400C1D07
	v_add_co_ci_u32_e32 v7, vcc_lo, 0, v16, vcc_lo             // 00000000D250: 400E2080
	v_add_co_u32 v13, vcc_lo, v6, v15                          // 00000000D254: D7006A0D 00021F06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D25C: BF870111
	v_add_co_ci_u32_e64 v14, null, 0, v7, vcc_lo               // 00000000D260: D5207C0E 01AA0E80
	v_mul_lo_u32 v15, s15, v13                                 // 00000000D268: D72C000F 00021A0F
	v_mad_u64_u32 v[6:7], null, s14, v13, 0                    // 00000000D270: D6FE7C06 02021A0E
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D278: BF870113
	v_mul_lo_u32 v13, s14, v14                                 // 00000000D27C: D72C000D 00021C0E
	v_sub_co_u32 v6, vcc_lo, v18, v6                           // 00000000D284: D7016A06 00020D12
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D28C: BF870112
	v_add3_u32 v7, v7, v13, v15                                // 00000000D290: D6550007 043E1B07
	v_cmp_le_u32_e64 s1, s14, v6                               // 00000000D298: D44B0001 00020C0E
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000D2A0: BF8701A2
	v_sub_nc_u32_e32 v13, v3, v7                               // 00000000D2A4: 4C1A0F03
	v_sub_co_ci_u32_e64 v3, null, v3, v7, vcc_lo               // 00000000D2A8: D5217C03 01AA0F03
	v_cndmask_b32_e64 v15, 0, -1, s1                           // 00000000D2B0: D501000F 00058280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000D2B8: BF8700A3
	v_subrev_co_ci_u32_e64 v13, null, s15, v13, vcc_lo         // 00000000D2BC: D5227C0D 01AA1A0F
	v_sub_co_u32 v7, vcc_lo, v6, s14                           // 00000000D2C4: D7016A07 00001D06
	v_subrev_co_ci_u32_e64 v14, null, 0, v13, vcc_lo           // 00000000D2CC: D5227C0E 01AA1A80
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000D2D4: BF8701B2
	v_cmp_le_u32_e64 s1, s14, v7                               // 00000000D2D8: D44B0001 00020E0E
	v_subrev_co_ci_u32_e64 v13, null, s15, v13, vcc_lo         // 00000000D2E0: D5227C0D 01AA1A0F
	v_cmp_le_u32_e32 vcc_lo, s15, v3                           // 00000000D2E8: 7C96060F
	v_cndmask_b32_e64 v16, 0, -1, s1                           // 00000000D2EC: D5010010 00058280
	v_cmp_le_u32_e64 s1, s15, v14                              // 00000000D2F4: D44B0001 00021C0F
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 00000000D2FC: D5010013 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s15, v14                          // 00000000D304: 7C941C0F
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D308: BF870123
	v_cndmask_b32_e64 v18, 0, -1, s1                           // 00000000D30C: D5010012 00058280
	v_cmp_eq_u32_e64 s1, s15, v3                               // 00000000D314: D44A0001 0002060F
	v_cndmask_b32_e32 v16, v18, v16, vcc_lo                    // 00000000D31C: 02202112
	v_sub_co_u32 v18, vcc_lo, v7, s14                          // 00000000D320: D7016A12 00001D07
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000D328: BF870191
	v_subrev_co_ci_u32_e64 v13, null, 0, v13, vcc_lo           // 00000000D32C: D5227C0D 01AA1A80
	v_cmp_ne_u32_e32 vcc_lo, 0, v16                            // 00000000D334: 7C9A2080
	v_cndmask_b32_e64 v15, v19, v15, s1                        // 00000000D338: D501000F 00061F13
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000D340: BF8701A3
	v_cndmask_b32_e32 v13, v14, v13, vcc_lo                    // 00000000D344: 021A1B0E
	v_cndmask_b32_e32 v7, v7, v18, vcc_lo                      // 00000000D348: 020E2507
	v_cmp_ne_u32_e32 vcc_lo, 0, v15                            // 00000000D34C: 7C9A1E80
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D350: BF870092
	v_dual_cndmask_b32 v6, v6, v7 :: v_dual_cndmask_b32 v3, v3, v13// 00000000D354: CA520F06 06021B03
	v_xor_b32_e32 v6, v6, v17                                  // 00000000D35C: 3A0C2306
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D360: BF870112
	v_xor_b32_e32 v3, v3, v17                                  // 00000000D364: 3A062303
	v_sub_co_u32 v6, vcc_lo, v6, v17                           // 00000000D368: D7016A06 00022306
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D370: BF870001
	v_sub_co_ci_u32_e64 v7, null, v3, v17, vcc_lo              // 00000000D374: D5217C07 01AA2303
	s_and_not1_saveexec_b32 s1, s29                            // 00000000D37C: BE81301D
	s_cbranch_execz 15                                         // 00000000D380: BFA5000F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x9c0>
	v_mul_hi_u32 v3, v4, v10                                   // 00000000D384: D72D0003 00021504
	v_mov_b32_e32 v7, v2                                       // 00000000D38C: 7E0E0302
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D390: BF870092
	v_mul_lo_u32 v3, v3, s8                                    // 00000000D394: D72C0003 00001103
	v_sub_nc_u32_e32 v3, v4, v3                                // 00000000D39C: 4C060704
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D3A0: BF870121
	v_subrev_nc_u32_e32 v6, s8, v3                             // 00000000D3A4: 4E0C0608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000D3A8: 7C960608
	v_cndmask_b32_e32 v3, v3, v6, vcc_lo                       // 00000000D3AC: 02060D03
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D3B0: BF870121
	v_subrev_nc_u32_e32 v6, s8, v3                             // 00000000D3B4: 4E0C0608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000D3B8: 7C960608
	v_cndmask_b32_e32 v6, v3, v6, vcc_lo                       // 00000000D3BC: 020C0D03
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000D3C0: 8C7E017E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000D3C4: BF8700B1
	v_lshlrev_b64 v[6:7], 2, v[6:7]                            // 00000000D3C8: D73C0006 00020C82
	ds_load_b32 v13, v12                                       // 00000000D3D0: D8D80000 0D00000C
	v_add_co_u32 v6, vcc_lo, s26, v6                           // 00000000D3D8: D7006A06 00020C1A
	v_add_co_ci_u32_e64 v7, null, s28, v7, vcc_lo              // 00000000D3E0: D5207C07 01AA0E1C
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D3E8: 916A147E
	global_load_b32 v6, v[6:7], off                            // 00000000D3EC: DC520000 067C0006
	s_waitcnt lgkmcnt(0)                                       // 00000000D3F4: BF89FC07
	v_lshlrev_b32_e32 v3, 16, v13                              // 00000000D3F8: 30061A90
	s_cbranch_vccz 13                                          // 00000000D3FC: BFA3000D <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xa34>
	s_waitcnt vmcnt(0)                                         // 00000000D400: BF8903F7
	v_lshlrev_b32_e32 v7, 16, v6                               // 00000000D404: 300E0C90
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D408: 916A147E
	s_cbranch_vccz 68                                          // 00000000D40C: BFA30044 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xb20>
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D410: 916A147E
	s_cbranch_vccz 123                                         // 00000000D414: BFA3007B <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xc04>
	v_and_b32_e32 v14, 0xffff0000, v13                         // 00000000D418: 361C1AFF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D420: 916A147E
	s_cbranch_vccz 175                                         // 00000000D424: BFA300AF <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xce4>
	v_and_b32_e32 v13, 0xffff0000, v6                          // 00000000D428: 361A0CFF FFFF0000
	s_branch 65293                                             // 00000000D430: BFA0FF0D <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x668>
	v_bfe_u32 v7, v13, 10, 5                                   // 00000000D434: D6100007 0215150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D43C: BF870122
	v_and_b32_e32 v3, 0x80000000, v3                           // 00000000D440: 360606FF 80000000
	s_mov_b32 s1, exec_lo                                      // 00000000D448: BE81007E
	v_cmpx_lt_i32_e32 30, v7                                   // 00000000D44C: 7D820E9E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000D450: 8D01017E
	v_lshlrev_b32_e32 v7, 13, v13                              // 00000000D454: 300E1A8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D458: BF870091
	v_and_b32_e32 v7, 0x7fe000, v7                             // 00000000D45C: 360E0EFF 007FE000
	v_or3_b32 v3, v7, v3, 0x7f800000                           // 00000000D464: D6580003 03FE0707 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000D470: BE813001
	s_cbranch_execz 36                                         // 00000000D474: BFA50024 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xb08>
	v_and_b32_e32 v14, 0x3ff, v13                              // 00000000D478: 361C1AFF 000003FF
	s_mov_b32 s7, exec_lo                                      // 00000000D480: BE87007E
	v_cmpx_ne_u32_e32 0, v7                                    // 00000000D484: 7D9A0E80
	s_xor_b32 s7, exec_lo, s7                                  // 00000000D488: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D48C: BF870092
	v_lshlrev_b32_e32 v14, 13, v14                             // 00000000D490: 301C1C8D
	v_lshl_or_b32 v7, v7, 23, v14                              // 00000000D494: D6560007 04392F07
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D49C: BF870001
	v_add3_u32 v3, v7, v3, 0x38000000                          // 00000000D4A0: D6550003 03FE0707 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000D4AC: BE873007
	s_cbranch_execz 19                                         // 00000000D4B0: BFA50013 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xb00>
	s_mov_b32 s14, exec_lo                                     // 00000000D4B4: BE8E007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000D4B8: 7D9A1C80
	s_cbranch_execz 15                                         // 00000000D4BC: BFA5000F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xafc>
	v_clz_i32_u32_e32 v7, v14                                  // 00000000D4C0: 7E0E730E
	v_or_b32_e32 v3, 0x43000000, v3                            // 00000000D4C4: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D4CC: BF870122
	v_xor_b32_e32 v14, 31, v7                                  // 00000000D4D0: 3A1C0E9F
	v_lshlrev_b32_e32 v7, 23, v7                               // 00000000D4D4: 300E0E97
	v_sub_nc_u32_e32 v14, 9, v14                               // 00000000D4D8: 4C1C1C89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D4DC: BF870112
	v_sub_nc_u32_e32 v3, v3, v7                                // 00000000D4E0: 4C060F03
	v_lshlrev_b32_e32 v14, v14, v13                            // 00000000D4E4: 301C1B0E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D4E8: BF870091
	v_lshlrev_b32_e32 v14, 14, v14                             // 00000000D4EC: 301C1C8E
	v_and_or_b32 v3, 0x7fc000, v14, v3                         // 00000000D4F0: D6570003 040E1CFF 007FC000
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000D4FC: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D500: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000D504: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D508: BF870009
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000D50C: 8C7E017E
	s_waitcnt vmcnt(0)                                         // 00000000D510: BF8903F7
	v_lshlrev_b32_e32 v7, 16, v6                               // 00000000D514: 300E0C90
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D518: 916A147E
	s_cbranch_vccnz 65468                                      // 00000000D51C: BFA4FFBC <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xa10>
	v_bfe_u32 v14, v6, 10, 5                                   // 00000000D520: D610000E 02151506
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D528: BF870122
	v_and_b32_e32 v7, 0x80000000, v7                           // 00000000D52C: 360E0EFF 80000000
	s_mov_b32 s1, exec_lo                                      // 00000000D534: BE81007E
	v_cmpx_lt_i32_e32 30, v14                                  // 00000000D538: 7D821C9E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000D53C: 8D01017E
	v_lshlrev_b32_e32 v14, 13, v6                              // 00000000D540: 301C0C8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D544: BF870091
	v_and_b32_e32 v14, 0x7fe000, v14                           // 00000000D548: 361C1CFF 007FE000
	v_or3_b32 v7, v14, v7, 0x7f800000                          // 00000000D550: D6580007 03FE0F0E 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000D55C: BE813001
	s_cbranch_execz 36                                         // 00000000D560: BFA50024 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xbf4>
	v_and_b32_e32 v15, 0x3ff, v6                               // 00000000D564: 361E0CFF 000003FF
	s_mov_b32 s7, exec_lo                                      // 00000000D56C: BE87007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000D570: 7D9A1C80
	s_xor_b32 s7, exec_lo, s7                                  // 00000000D574: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D578: BF870092
	v_lshlrev_b32_e32 v15, 13, v15                             // 00000000D57C: 301E1E8D
	v_lshl_or_b32 v14, v14, 23, v15                            // 00000000D580: D656000E 043D2F0E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D588: BF870001
	v_add3_u32 v7, v14, v7, 0x38000000                         // 00000000D58C: D6550007 03FE0F0E 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000D598: BE873007
	s_cbranch_execz 19                                         // 00000000D59C: BFA50013 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xbec>
	s_mov_b32 s14, exec_lo                                     // 00000000D5A0: BE8E007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000D5A4: 7D9A1E80
	s_cbranch_execz 15                                         // 00000000D5A8: BFA5000F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xbe8>
	v_clz_i32_u32_e32 v14, v15                                 // 00000000D5AC: 7E1C730F
	v_or_b32_e32 v7, 0x43000000, v7                            // 00000000D5B0: 380E0EFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D5B8: BF870122
	v_xor_b32_e32 v15, 31, v14                                 // 00000000D5BC: 3A1E1C9F
	v_lshlrev_b32_e32 v14, 23, v14                             // 00000000D5C0: 301C1C97
	v_sub_nc_u32_e32 v15, 9, v15                               // 00000000D5C4: 4C1E1E89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D5C8: BF870112
	v_sub_nc_u32_e32 v7, v7, v14                               // 00000000D5CC: 4C0E1D07
	v_lshlrev_b32_e32 v15, v15, v6                             // 00000000D5D0: 301E0D0F
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D5D4: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000D5D8: 301E1E8E
	v_and_or_b32 v7, 0x7fc000, v15, v7                         // 00000000D5DC: D6570007 041E1EFF 007FC000
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000D5E8: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D5EC: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000D5F0: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000D5F4: BF870499
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000D5F8: 8C7E017E
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D5FC: 916A147E
	s_cbranch_vccnz 65413                                      // 00000000D600: BFA4FF85 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xa18>
	v_bfe_u32 v16, v13, 26, 5                                  // 00000000D604: D6100010 0215350D
	v_and_b32_e32 v14, 0x80000000, v13                         // 00000000D60C: 361C1AFF 80000000
	v_mov_b16_e32 v15.h, 0                                     // 00000000D614: 7F1E3880
	v_mov_b16_e32 v15.l, v13.h                                 // 00000000D618: 7E1E398D
	s_mov_b32 s1, exec_lo                                      // 00000000D61C: BE81007E
	v_cmpx_lt_i32_e32 30, v16                                  // 00000000D620: 7D82209E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000D624: 8D01017E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D628: BF870092
	v_lshlrev_b32_e32 v13, 13, v15                             // 00000000D62C: 301A1E8D
	v_or3_b32 v14, v13, v14, 0x7f800000                        // 00000000D630: D658000E 03FE1D0D 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000D63C: BE813001
	s_cbranch_execz 36                                         // 00000000D640: BFA50024 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xcd4>
	v_bfe_u32 v13, v13, 16, 10                                 // 00000000D644: D610000D 0229210D
	s_mov_b32 s7, exec_lo                                      // 00000000D64C: BE87007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000D650: 7D9A2080
	s_xor_b32 s7, exec_lo, s7                                  // 00000000D654: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D658: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 00000000D65C: 301A1A8D
	v_lshl_or_b32 v13, v16, 23, v13                            // 00000000D660: D656000D 04352F10
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D668: BF870001
	v_add3_u32 v14, v13, v14, 0x38000000                       // 00000000D66C: D655000E 03FE1D0D 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000D678: BE873007
	s_cbranch_execz 19                                         // 00000000D67C: BFA50013 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xccc>
	s_mov_b32 s14, exec_lo                                     // 00000000D680: BE8E007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000000D684: 7D9A1A80
	s_cbranch_execz 15                                         // 00000000D688: BFA5000F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xcc8>
	v_clz_i32_u32_e32 v13, v13                                 // 00000000D68C: 7E1A730D
	v_or_b32_e32 v14, 0x43000000, v14                          // 00000000D690: 381C1CFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D698: BF870122
	v_xor_b32_e32 v16, 31, v13                                 // 00000000D69C: 3A201A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 00000000D6A0: 301A1A97
	v_sub_nc_u32_e32 v16, 9, v16                               // 00000000D6A4: 4C202089
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D6A8: BF870112
	v_sub_nc_u32_e32 v13, v14, v13                             // 00000000D6AC: 4C1A1B0E
	v_lshlrev_b32_e32 v15, v16, v15                            // 00000000D6B0: 301E1F10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D6B4: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000D6B8: 301E1E8E
	v_and_or_b32 v14, 0x7fc000, v15, v13                       // 00000000D6BC: D657000E 04361EFF 007FC000
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000D6C8: 8C7E0E7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D6CC: BF870009
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000D6D0: 8C7E077E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000D6D4: BF870499
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000D6D8: 8C7E017E
	s_and_not1_b32 vcc_lo, exec_lo, s20                        // 00000000D6DC: 916A147E
	s_cbranch_vccnz 65361                                      // 00000000D6E0: BFA4FF51 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xa28>
	v_bfe_u32 v16, v6, 26, 5                                   // 00000000D6E4: D6100010 02153506
	v_and_b32_e32 v13, 0x80000000, v6                          // 00000000D6EC: 361A0CFF 80000000
	v_mov_b16_e32 v15.h, 0                                     // 00000000D6F4: 7F1E3880
	v_mov_b16_e32 v15.l, v6.h                                  // 00000000D6F8: 7E1E3986
	s_mov_b32 s1, exec_lo                                      // 00000000D6FC: BE81007E
	v_cmpx_lt_i32_e32 30, v16                                  // 00000000D700: 7D82209E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000D704: 8D01017E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D708: BF870092
	v_lshlrev_b32_e32 v6, 13, v15                              // 00000000D70C: 300C1E8D
	v_or3_b32 v13, v6, v13, 0x7f800000                         // 00000000D710: D658000D 03FE1B06 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000D71C: BE813001
	s_cbranch_execz 65103                                      // 00000000D720: BFA5FE4F <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x660>
	v_bfe_u32 v6, v6, 16, 10                                   // 00000000D724: D6100006 02292106
	s_mov_b32 s7, exec_lo                                      // 00000000D72C: BE87007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000D730: 7D9A2080
	s_xor_b32 s7, exec_lo, s7                                  // 00000000D734: 8D07077E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D738: BF870092
	v_lshlrev_b32_e32 v6, 13, v6                               // 00000000D73C: 300C0C8D
	v_lshl_or_b32 v6, v16, 23, v6                              // 00000000D740: D6560006 04192F10
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000D748: BF870001
	v_add3_u32 v13, v6, v13, 0x38000000                        // 00000000D74C: D655000D 03FE1B06 38000000
	s_and_not1_saveexec_b32 s7, s7                             // 00000000D758: BE873007
	s_cbranch_execz 65086                                      // 00000000D75C: BFA5FE3E <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x658>
	s_mov_b32 s14, exec_lo                                     // 00000000D760: BE8E007E
	v_cmpx_ne_u32_e32 0, v6                                    // 00000000D764: 7D9A0C80
	s_cbranch_execz 65082                                      // 00000000D768: BFA5FE3A <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x654>
	v_clz_i32_u32_e32 v6, v6                                   // 00000000D76C: 7E0C7306
	v_or_b32_e32 v13, 0x43000000, v13                          // 00000000D770: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000D778: BF870122
	v_xor_b32_e32 v16, 31, v6                                  // 00000000D77C: 3A200C9F
	v_lshlrev_b32_e32 v6, 23, v6                               // 00000000D780: 300C0C97
	v_sub_nc_u32_e32 v16, 9, v16                               // 00000000D784: 4C202089
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D788: BF870112
	v_sub_nc_u32_e32 v6, v13, v6                               // 00000000D78C: 4C0C0D0D
	v_lshlrev_b32_e32 v15, v16, v15                            // 00000000D790: 301E1F10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D794: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000D798: 301E1E8E
	v_and_or_b32 v13, 0x7fc000, v15, v6                        // 00000000D79C: D657000D 041A1EFF 007FC000
	s_branch 65066                                             // 00000000D7A8: BFA0FE2A <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x654>
	s_or_b32 exec_lo, exec_lo, s27                             // 00000000D7AC: 8C7E1B7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000D7B0: BF870499
	s_or_b32 exec_lo, exec_lo, s25                             // 00000000D7B4: 8C7E197E
	s_and_not1_b32 vcc_lo, exec_lo, s23                        // 00000000D7B8: 916A177E
	s_mov_b32 s1, s22                                          // 00000000D7BC: BE810016
	ds_store_b32 v8, v11                                       // 00000000D7C0: D8340000 00000B08
	s_waitcnt lgkmcnt(0)                                       // 00000000D7C8: BF89FC07
	s_barrier                                                  // 00000000D7CC: BFBD0000
	buffer_gl0_inv                                             // 00000000D7D0: E0AC0000 00000000
	s_cbranch_vccz 34                                          // 00000000D7D8: BFA30022 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xe64>
	s_and_saveexec_b32 s1, s0                                  // 00000000D7DC: BE812000
	s_cbranch_execz 65024                                      // 00000000D7E0: BFA5FE00 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x5e4>
	v_mov_b32_e32 v3, s3                                       // 00000000D7E4: 7E060203
	s_lshl_b64 s[14:15], s[4:5], 2                             // 00000000D7E8: 848E8204
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D7EC: BF870009
	s_add_u32 s14, s18, s14                                    // 00000000D7F0: 800E0E12
	s_addc_u32 s15, s19, s15                                   // 00000000D7F4: 820F0F13
	ds_load_b32 v3, v3                                         // 00000000D7F8: D8D80000 03000003
	s_waitcnt lgkmcnt(0)                                       // 00000000D800: BF89FC07
	global_store_b32 v2, v3, s[14:15]                          // 00000000D804: DC6A0000 000E0302
	s_branch 65013                                             // 00000000D80C: BFA0FDF5 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0x5e4>
	s_nop 0                                                    // 00000000D810: BF800000
	s_nop 0                                                    // 00000000D814: BF800000
	s_nop 0                                                    // 00000000D818: BF800000
	s_nop 0                                                    // 00000000D81C: BF800000
	s_nop 0                                                    // 00000000D820: BF800000
	s_nop 0                                                    // 00000000D824: BF800000
	s_nop 0                                                    // 00000000D828: BF800000
	s_nop 0                                                    // 00000000D82C: BF800000
	s_nop 0                                                    // 00000000D830: BF800000
	s_nop 0                                                    // 00000000D834: BF800000
	s_nop 0                                                    // 00000000D838: BF800000
	s_nop 0                                                    // 00000000D83C: BF800000
	s_or_b32 exec_lo, exec_lo, s7                              // 00000000D840: 8C7E077E
	s_lshr_b32 s7, s1, 1                                       // 00000000D844: 85078101
	s_cmp_lt_u32 s1, 2                                         // 00000000D848: BF0A8201
	s_mov_b32 s1, s7                                           // 00000000D84C: BE810007
	s_waitcnt lgkmcnt(0)                                       // 00000000D850: BF89FC07
	s_barrier                                                  // 00000000D854: BFBD0000
	buffer_gl0_inv                                             // 00000000D858: E0AC0000 00000000
	s_cbranch_scc1 65502                                       // 00000000D860: BFA2FFDE <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xddc>
	s_mov_b32 s7, exec_lo                                      // 00000000D864: BE87007E
	v_cmpx_gt_u32_e64 s1, v0                                   // 00000000D868: D4CC007E 00020001
	s_cbranch_execz 65523                                      // 00000000D870: BFA5FFF3 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xe40>
	v_lshl_add_u32 v3, s1, 2, v8                               // 00000000D874: D6460003 04210401
	ds_load_b32 v3, v3                                         // 00000000D87C: D8D80000 03000003
	ds_load_b32 v4, v8                                         // 00000000D884: D8D80000 04000008
	s_waitcnt lgkmcnt(0)                                       // 00000000D88C: BF89FC07
	v_add_f32_e32 v3, v3, v4                                   // 00000000D890: 06060903
	ds_store_b32 v8, v3                                        // 00000000D894: D8340000 00000308
	s_branch 65512                                             // 00000000D89C: BFA0FFE8 <_ZN12_GLOBAL__N_116graph_lds_kernelEPKjS1_PKiPfllllli+0xe40>
	s_endpgm                                                   // 00000000D8A0: BFB00000
		...

000000000000d900 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli>:
	s_clause 0x1                                               // 00000000D900: BF850001
	s_load_b256 s[16:23], s[0:1], 0x40                         // 00000000D904: F40C0400 F8000040
	s_load_b256 s[4:11], s[0:1], 0x20                          // 00000000D90C: F40C0100 F8000020
	s_mov_b32 s2, 0                                            // 00000000D914: BE820080
	s_waitcnt lgkmcnt(0)                                       // 00000000D918: BF89FC07
	s_mov_b32 s3, s19                                          // 00000000D91C: BE830013
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000D920: BF870009
	s_cmp_lg_u64 s[2:3], 0                                     // 00000000D924: BF118002
	s_cbranch_scc0 1134                                        // 00000000D928: BFA1046E <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x11e4>
	s_ashr_i32 s12, s19, 31                                    // 00000000D92C: 860C9F13
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000D930: BF8704B9
	s_add_u32 s22, s18, s12                                    // 00000000D934: 80160C12
	s_mov_b32 s13, s12                                         // 00000000D938: BE8D000C
	s_addc_u32 s23, s19, s12                                   // 00000000D93C: 82170C13
	s_xor_b64 s[22:23], s[22:23], s[12:13]                     // 00000000D940: 8D960C16
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000D944: BF8700C9
	v_cvt_f32_u32_e32 v1, s22                                  // 00000000D948: 7E020C16
	v_cvt_f32_u32_e32 v2, s23                                  // 00000000D94C: 7E040C17
	s_sub_u32 s24, 0, s22                                      // 00000000D950: 80981680
	s_subb_u32 s25, 0, s23                                     // 00000000D954: 82991780
	v_fmamk_f32 v1, v2, 0x4f800000, v1                         // 00000000D958: 58020302 4F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000D960: BF8700B1
	v_rcp_f32_e32 v1, v1                                       // 00000000D964: 7E025501
	s_waitcnt_depctr 0xfff                                     // 00000000D968: BF880FFF
	v_mul_f32_e32 v1, 0x5f7ffffc, v1                           // 00000000D96C: 100202FF 5F7FFFFC
	v_mul_f32_e32 v2, 0x2f800000, v1                           // 00000000D974: 100402FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000D97C: BF870091
	v_trunc_f32_e32 v2, v2                                     // 00000000D980: 7E044302
	v_fmamk_f32 v1, v2, 0xcf800000, v1                         // 00000000D984: 58020302 CF800000
	v_cvt_u32_f32_e32 v2, v2                                   // 00000000D98C: 7E040F02
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000D990: BF870112
	v_cvt_u32_f32_e32 v1, v1                                   // 00000000D994: 7E020F01
	v_readfirstlane_b32 s3, v2                                 // 00000000D998: 7E060502
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000D99C: BF870002
	v_readfirstlane_b32 s14, v1                                // 00000000D9A0: 7E1C0501
	s_mul_i32 s26, s24, s3                                     // 00000000D9A4: 961A0318
	s_mul_hi_u32 s28, s24, s14                                 // 00000000D9A8: 969C0E18
	s_mul_i32 s27, s25, s14                                    // 00000000D9AC: 961B0E19
	s_add_i32 s26, s28, s26                                    // 00000000D9B0: 811A1A1C
	s_mul_i32 s29, s24, s14                                    // 00000000D9B4: 961D0E18
	s_add_i32 s26, s26, s27                                    // 00000000D9B8: 811A1B1A
	s_mul_hi_u32 s28, s14, s29                                 // 00000000D9BC: 969C1D0E
	s_mul_i32 s31, s14, s26                                    // 00000000D9C0: 961F1A0E
	s_mul_hi_u32 s30, s3, s29                                  // 00000000D9C4: 969E1D03
	s_mul_i32 s27, s3, s29                                     // 00000000D9C8: 961B1D03
	s_mul_hi_u32 s29, s14, s26                                 // 00000000D9CC: 969D1A0E
	s_add_u32 s28, s28, s31                                    // 00000000D9D0: 801C1F1C
	s_addc_u32 s29, 0, s29                                     // 00000000D9D4: 821D1D80
	s_mul_hi_u32 s33, s3, s26                                  // 00000000D9D8: 96A11A03
	s_add_u32 s27, s28, s27                                    // 00000000D9DC: 801B1B1C
	s_mul_i32 s26, s3, s26                                     // 00000000D9E0: 961A1A03
	s_addc_u32 s27, s29, s30                                   // 00000000D9E4: 821B1E1D
	s_addc_u32 s28, s33, 0                                     // 00000000D9E8: 821C8021
	s_add_u32 s26, s27, s26                                    // 00000000D9EC: 801A1A1B
	s_addc_u32 s27, 0, s28                                     // 00000000D9F0: 821B1C80
	s_add_u32 s14, s14, s26                                    // 00000000D9F4: 800E1A0E
	s_cselect_b32 s26, -1, 0                                   // 00000000D9F8: 981A80C1
	s_mul_hi_u32 s28, s24, s14                                 // 00000000D9FC: 969C0E18
	s_cmp_lg_u32 s26, 0                                        // 00000000DA00: BF07801A
	s_mul_i32 s26, s24, s14                                    // 00000000DA04: 961A0E18
	s_addc_u32 s3, s3, s27                                     // 00000000DA08: 82031B03
	s_mul_i32 s25, s25, s14                                    // 00000000DA0C: 96190E19
	s_mul_i32 s24, s24, s3                                     // 00000000DA10: 96180318
	s_mul_hi_u32 s27, s14, s26                                 // 00000000DA14: 969B1A0E
	s_add_i32 s24, s28, s24                                    // 00000000DA18: 8118181C
	s_mul_hi_u32 s28, s3, s26                                  // 00000000DA1C: 969C1A03
	s_add_i32 s24, s24, s25                                    // 00000000DA20: 81181918
	s_mul_i32 s25, s3, s26                                     // 00000000DA24: 96191A03
	s_mul_i32 s30, s14, s24                                    // 00000000DA28: 961E180E
	s_mul_hi_u32 s29, s14, s24                                 // 00000000DA2C: 969D180E
	s_add_u32 s27, s27, s30                                    // 00000000DA30: 801B1E1B
	s_addc_u32 s29, 0, s29                                     // 00000000DA34: 821D1D80
	s_mul_hi_u32 s26, s3, s24                                  // 00000000DA38: 969A1803
	s_add_u32 s25, s27, s25                                    // 00000000DA3C: 8019191B
	s_mul_i32 s24, s3, s24                                     // 00000000DA40: 96181803
	s_addc_u32 s25, s29, s28                                   // 00000000DA44: 82191C1D
	s_addc_u32 s26, s26, 0                                     // 00000000DA48: 821A801A
	s_add_u32 s24, s25, s24                                    // 00000000DA4C: 80181819
	s_addc_u32 s25, 0, s26                                     // 00000000DA50: 82191A80
	s_add_u32 s14, s14, s24                                    // 00000000DA54: 800E180E
	s_cselect_b32 s24, -1, 0                                   // 00000000DA58: 981880C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 00000000DA5C: BF8704C9
	s_cmp_lg_u32 s24, 0                                        // 00000000DA60: BF078018
	s_addc_u32 s3, s3, s25                                     // 00000000DA64: 82031903
	s_add_u32 s24, s15, 0                                      // 00000000DA68: 8018800F
	s_addc_u32 s25, 0, 0                                       // 00000000DA6C: 82198080
	s_xor_b64 s[24:25], s[24:25], 0                            // 00000000DA70: 8D988018
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000DA74: BF870009
	s_mul_i32 s27, s24, s3                                     // 00000000DA78: 961B0318
	s_mul_hi_u32 s28, s24, s14                                 // 00000000DA7C: 969C0E18
	s_mul_hi_u32 s26, s24, s3                                  // 00000000DA80: 969A0318
	s_mul_hi_u32 s30, s25, s14                                 // 00000000DA84: 969E0E19
	s_mul_i32 s14, s25, s14                                    // 00000000DA88: 960E0E19
	s_add_u32 s27, s28, s27                                    // 00000000DA8C: 801B1B1C
	s_addc_u32 s26, 0, s26                                     // 00000000DA90: 821A1A80
	s_mul_hi_u32 s29, s25, s3                                  // 00000000DA94: 969D0319
	s_add_u32 s14, s27, s14                                    // 00000000DA98: 800E0E1B
	s_mul_i32 s3, s25, s3                                      // 00000000DA9C: 96030319
	s_addc_u32 s14, s26, s30                                   // 00000000DAA0: 820E1E1A
	s_addc_u32 s26, s29, 0                                     // 00000000DAA4: 821A801D
	s_add_u32 s3, s14, s3                                      // 00000000DAA8: 8003030E
	s_addc_u32 s14, 0, s26                                     // 00000000DAAC: 820E1A80
	s_mul_hi_u32 s26, s22, s3                                  // 00000000DAB0: 969A0316
	s_mul_i32 s27, s22, s14                                    // 00000000DAB4: 961B0E16
	s_mul_i32 s28, s23, s3                                     // 00000000DAB8: 961C0317
	s_add_i32 s26, s26, s27                                    // 00000000DABC: 811A1B1A
	s_mul_i32 s27, s22, s3                                     // 00000000DAC0: 961B0316
	s_add_i32 s26, s26, s28                                    // 00000000DAC4: 811A1C1A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000DAC8: BF8704B9
	s_sub_i32 s28, s25, s26                                    // 00000000DACC: 819C1A19
	s_sub_u32 s24, s24, s27                                    // 00000000DAD0: 80981B18
	s_cselect_b32 s27, -1, 0                                   // 00000000DAD4: 981B80C1
	s_cmp_lg_u32 s27, 0                                        // 00000000DAD8: BF07801B
	s_subb_u32 s28, s28, s23                                   // 00000000DADC: 829C171C
	s_sub_u32 s29, s24, s22                                    // 00000000DAE0: 809D1618
	s_cselect_b32 s30, -1, 0                                   // 00000000DAE4: 981E80C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000DAE8: BF8704A9
	s_cmp_lg_u32 s30, 0                                        // 00000000DAEC: BF07801E
	s_subb_u32 s28, s28, 0                                     // 00000000DAF0: 829C801C
	s_cmp_ge_u32 s28, s23                                      // 00000000DAF4: BF09171C
	s_cselect_b32 s30, -1, 0                                   // 00000000DAF8: 981E80C1
	s_cmp_ge_u32 s29, s22                                      // 00000000DAFC: BF09161D
	s_cselect_b32 s29, -1, 0                                   // 00000000DB00: 981D80C1
	s_cmp_eq_u32 s28, s23                                      // 00000000DB04: BF06171C
	s_cselect_b32 s28, s29, s30                                // 00000000DB08: 981C1E1D
	s_add_u32 s29, s3, 1                                       // 00000000DB0C: 801D8103
	s_addc_u32 s30, s14, 0                                     // 00000000DB10: 821E800E
	s_add_u32 s31, s3, 2                                       // 00000000DB14: 801F8203
	s_addc_u32 s33, s14, 0                                     // 00000000DB18: 8221800E
	s_cmp_lg_u32 s28, 0                                        // 00000000DB1C: BF07801C
	s_cselect_b32 s28, s31, s29                                // 00000000DB20: 981C1D1F
	s_cselect_b32 s29, s33, s30                                // 00000000DB24: 981D1E21
	s_cmp_lg_u32 s27, 0                                        // 00000000DB28: BF07801B
	s_subb_u32 s25, s25, s26                                   // 00000000DB2C: 82991A19
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000DB30: BF870009
	s_cmp_ge_u32 s25, s23                                      // 00000000DB34: BF091719
	s_cselect_b32 s26, -1, 0                                   // 00000000DB38: 981A80C1
	s_cmp_ge_u32 s24, s22                                      // 00000000DB3C: BF091618
	s_cselect_b32 s22, -1, 0                                   // 00000000DB40: 981680C1
	s_cmp_eq_u32 s25, s23                                      // 00000000DB44: BF061719
	s_cselect_b32 s22, s22, s26                                // 00000000DB48: 98161A16
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 00000000DB4C: BF8704C9
	s_cmp_lg_u32 s22, 0                                        // 00000000DB50: BF078016
	s_cselect_b32 s23, s29, s14                                // 00000000DB54: 98170E1D
	s_cselect_b32 s22, s28, s3                                 // 00000000DB58: 9816031C
	s_xor_b64 s[12:13], 0, s[12:13]                            // 00000000DB5C: 8D8C0C80
	s_xor_b64 s[22:23], s[22:23], s[12:13]                     // 00000000DB60: 8D960C16
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000DB64: BF870009
	s_sub_u32 s22, s22, s12                                    // 00000000DB68: 80960C16
	s_subb_u32 s23, s23, s13                                   // 00000000DB6C: 82970D17
	s_and_not1_b32 vcc_lo, exec_lo, s2                         // 00000000DB70: 916A027E
	s_cbranch_vccnz 27                                         // 00000000DB74: BFA4001B <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x2e4>
	v_cvt_f32_u32_e32 v1, s18                                  // 00000000DB78: 7E020C12
	s_sub_i32 s3, 0, s18                                       // 00000000DB7C: 81831280
	s_mov_b32 s23, 0                                           // 00000000DB80: BE970080
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000DB84: BF8700B1
	v_rcp_iflag_f32_e32 v1, v1                                 // 00000000DB88: 7E025701
	s_waitcnt_depctr 0xfff                                     // 00000000DB8C: BF880FFF
	v_mul_f32_e32 v1, 0x4f7ffffe, v1                           // 00000000DB90: 100202FF 4F7FFFFE
	v_cvt_u32_f32_e32 v1, v1                                   // 00000000DB98: 7E020F01
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000DB9C: BF8704A1
	v_readfirstlane_b32 s2, v1                                 // 00000000DBA0: 7E040501
	s_mul_i32 s3, s3, s2                                       // 00000000DBA4: 96030203
	s_mul_hi_u32 s3, s2, s3                                    // 00000000DBA8: 96830302
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000DBAC: BF870499
	s_add_i32 s2, s2, s3                                       // 00000000DBB0: 81020302
	s_mul_hi_u32 s2, s15, s2                                   // 00000000DBB4: 9682020F
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000DBB8: BF8704B9
	s_mul_i32 s3, s2, s18                                      // 00000000DBBC: 96031202
	s_add_i32 s12, s2, 1                                       // 00000000DBC0: 810C8102
	s_sub_i32 s3, s15, s3                                      // 00000000DBC4: 8183030F
	s_sub_i32 s13, s3, s18                                     // 00000000DBC8: 818D1203
	s_cmp_ge_u32 s3, s18                                       // 00000000DBCC: BF091203
	s_cselect_b32 s2, s12, s2                                  // 00000000DBD0: 9802020C
	s_cselect_b32 s3, s13, s3                                  // 00000000DBD4: 9803030D
	s_add_i32 s12, s2, 1                                       // 00000000DBD8: 810C8102
	s_cmp_ge_u32 s3, s18                                       // 00000000DBDC: BF091203
	s_cselect_b32 s22, s12, s2                                 // 00000000DBE0: 9816020C
	s_clause 0x1                                               // 00000000DBE4: BF850001
	s_load_b64 s[12:13], s[0:1], 0x8                           // 00000000DBE8: F4040300 F8000008
	s_load_b64 s[24:25], s[0:1], 0x18                          // 00000000DBF0: F4040600 F8000018
	v_mov_b32_e32 v2, 0                                        // 00000000DBF8: 7E040280
	v_cvt_f32_u32_e32 v13, s8                                  // 00000000DBFC: 7E1A0C08
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000DC00: BF870092
	v_dual_mov_b32 v1, v2 :: v_dual_lshlrev_b32 v12, 2, v0     // 00000000DC04: CA220102 010C0082
	v_cmp_gt_i64_e64 s2, s[10:11], v[0:1]                      // 00000000DC0C: D4540002 0002000A
	s_and_saveexec_b32 s14, s2                                 // 00000000DC14: BE8E2002
	s_cbranch_execz 304                                        // 00000000DC18: BFA50130 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x7dc>
	s_load_b64 s[26:27], s[0:1], 0x10                          // 00000000DC1C: F4040680 F8000010
	v_rcp_iflag_f32_e32 v3, v13                                // 00000000DC24: 7E06570D
	s_mul_i32 s3, s22, s7                                      // 00000000DC28: 96030716
	s_mul_hi_u32 s7, s22, s6                                   // 00000000DC2C: 96870616
	s_mul_i32 s28, s23, s6                                     // 00000000DC30: 961C0617
	s_add_i32 s3, s7, s3                                       // 00000000DC34: 81030307
	s_mul_i32 s6, s22, s6                                      // 00000000DC38: 96060616
	s_add_i32 s7, s3, s28                                      // 00000000DC3C: 81071C03
	s_clause 0x1                                               // 00000000DC40: BF850001
	s_load_b64 s[30:31], s[0:1], null                          // 00000000DC44: F4040780 F8000000
	s_load_b32 s3, s[0:1], 0x6c                                // 00000000DC4C: F40000C0 F800006C
	s_lshl_b64 s[6:7], s[6:7], 2                               // 00000000DC54: 84868206
	s_waitcnt_depctr 0xfff                                     // 00000000DC58: BF880FFF
	v_dual_mul_f32 v3, 0x4f7ffffe, v3 :: v_dual_add_nc_u32 v14, 0, v12// 00000000DC5C: C8E006FF 030E1880 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(SALU_CYCLE_1)// 00000000DC68: BF8704D1
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000DC6C: 7E060F03
	s_waitcnt lgkmcnt(0)                                       // 00000000DC70: BF89FC07
	s_add_u32 s28, s26, s6                                     // 00000000DC74: 801C061A
	s_addc_u32 s29, s27, s7                                    // 00000000DC78: 821D071B
	s_sub_i32 s6, 0, s8                                        // 00000000DC7C: 81860880
	v_mul_lo_u32 v4, s6, v3                                    // 00000000DC80: D72C0004 00020606
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000DC88: BF8700A1
	v_mul_hi_u32 v6, v3, v4                                    // 00000000DC8C: D72D0006 00020903
	v_add_co_u32 v4, s6, s30, v12                              // 00000000DC94: D7000604 0002181E
	v_add_co_ci_u32_e64 v5, null, s31, 0, s6                   // 00000000DC9C: D5207C05 0019001F
	s_and_b32 s30, s3, 0xffff                                  // 00000000DCA4: 8B1EFF03 0000FFFF
	s_mov_b32 s31, 0                                           // 00000000DCAC: BE9F0080
	s_lshl_b32 s33, s30, 2                                     // 00000000DCB0: 8421821E
	v_add_nc_u32_e32 v15, v3, v6                               // 00000000DCB4: 4A1E0D03
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 00000000DCB8: CA100101 07060100
	s_ashr_i32 s6, s9, 31                                      // 00000000DCC0: 86069F09
	s_branch 19                                                // 00000000DCC4: BFA00013 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x414>
	s_or_b32 exec_lo, exec_lo, s3                              // 00000000DCC8: 8C7E037E
	v_add_co_u32 v6, vcc_lo, v6, s30                           // 00000000DCCC: D7006A06 00003D06
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000DCD4: BF870001
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000DCD8: D5207C07 01AA0E80
	v_add_co_u32 v4, s3, v4, s33                               // 00000000DCE0: D7000304 00004304
	s_waitcnt vmcnt(0)                                         // 00000000DCE8: BF8903F7
	ds_store_b32 v14, v3                                       // 00000000DCEC: D8340000 0000030E
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 00000000DCF4: 7CA60C0A
	v_add_co_ci_u32_e64 v5, null, 0, v5, s3                    // 00000000DCF8: D5207C05 000E0A80
	v_add_nc_u32_e32 v14, s33, v14                             // 00000000DD00: 4A1C1C21
	s_or_b32 s31, vcc_lo, s31                                  // 00000000DD04: 8C1F1F6A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000DD08: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s31                       // 00000000DD0C: 917E1F7E
	s_cbranch_execz 242                                        // 00000000DD10: BFA500F2 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x7dc>
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000DD14: BF8700A1
	v_or_b32_e32 v3, s9, v7                                    // 00000000DD18: 38060E09
	s_mov_b32 s3, exec_lo                                      // 00000000DD1C: BE83007E
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000DD20: 7DBA0480
	s_xor_b32 s34, exec_lo, s3                                 // 00000000DD24: 8D22037E
	s_cbranch_execz 175                                        // 00000000DD28: BFA500AF <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x6e8>
	s_add_u32 s26, s8, s6                                      // 00000000DD2C: 801A0608
	s_mov_b32 s7, s6                                           // 00000000DD30: BE870006
	s_addc_u32 s27, s9, s6                                     // 00000000DD34: 821B0609
	v_ashrrev_i32_e32 v18, 31, v7                              // 00000000DD38: 34240E9F
	s_xor_b64 s[26:27], s[26:27], s[6:7]                       // 00000000DD3C: 8D9A061A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000DD40: BF870159
	v_cvt_f32_u32_e32 v3, s26                                  // 00000000DD44: 7E060C1A
	v_cvt_f32_u32_e32 v8, s27                                  // 00000000DD48: 7E100C1B
	s_sub_u32 s3, 0, s26                                       // 00000000DD4C: 80831A80
	s_subb_u32 s36, 0, s27                                     // 00000000DD50: 82A41B80
	v_add_co_u32 v9, vcc_lo, v6, v18                           // 00000000DD54: D7006A09 00022506
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 00000000DD5C: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DD64: BF870112
	v_xor_b32_e32 v19, v9, v18                                 // 00000000DD68: 3A262509
	v_rcp_f32_e32 v3, v3                                       // 00000000DD6C: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000DD70: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000DD74: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000DD7C: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 00000000DD80: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 00000000DD88: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000DD8C: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 00000000DD90: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 00000000DD98: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000DD9C: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DDA0: BF870112
	v_readfirstlane_b32 s7, v8                                 // 00000000DDA4: 7E0E0508
	v_readfirstlane_b32 s35, v3                                // 00000000DDA8: 7E460503
	s_mul_i32 s37, s3, s7                                      // 00000000DDAC: 96250703
	v_add_co_ci_u32_e64 v3, null, v7, v18, vcc_lo              // 00000000DDB0: D5207C03 01AA2507
	s_mul_hi_u32 s39, s3, s35                                  // 00000000DDB8: 96A72303
	s_mul_i32 s38, s36, s35                                    // 00000000DDBC: 96262324
	s_add_i32 s37, s39, s37                                    // 00000000DDC0: 81252527
	s_mul_i32 s40, s3, s35                                     // 00000000DDC4: 96282303
	s_add_i32 s37, s37, s38                                    // 00000000DDC8: 81252625
	s_mul_hi_u32 s39, s35, s40                                 // 00000000DDCC: 96A72823
	s_mul_i32 s42, s35, s37                                    // 00000000DDD0: 962A2523
	s_mul_hi_u32 s41, s7, s40                                  // 00000000DDD4: 96A92807
	s_mul_i32 s38, s7, s40                                     // 00000000DDD8: 96262807
	s_mul_hi_u32 s40, s35, s37                                 // 00000000DDDC: 96A82523
	s_add_u32 s39, s39, s42                                    // 00000000DDE0: 80272A27
	s_addc_u32 s40, 0, s40                                     // 00000000DDE4: 82282880
	s_mul_hi_u32 s43, s7, s37                                  // 00000000DDE8: 96AB2507
	s_add_u32 s38, s39, s38                                    // 00000000DDEC: 80262627
	s_mul_i32 s37, s7, s37                                     // 00000000DDF0: 96252507
	s_addc_u32 s38, s40, s41                                   // 00000000DDF4: 82262928
	s_addc_u32 s39, s43, 0                                     // 00000000DDF8: 8227802B
	s_add_u32 s37, s38, s37                                    // 00000000DDFC: 80252526
	s_addc_u32 s38, 0, s39                                     // 00000000DE00: 82262780
	s_add_u32 s35, s35, s37                                    // 00000000DE04: 80232523
	s_cselect_b32 s37, -1, 0                                   // 00000000DE08: 982580C1
	s_mul_hi_u32 s39, s3, s35                                  // 00000000DE0C: 96A72303
	s_cmp_lg_u32 s37, 0                                        // 00000000DE10: BF078025
	s_mul_i32 s37, s3, s35                                     // 00000000DE14: 96252303
	s_addc_u32 s7, s7, s38                                     // 00000000DE18: 82072607
	s_mul_i32 s36, s36, s35                                    // 00000000DE1C: 96242324
	s_mul_i32 s3, s3, s7                                       // 00000000DE20: 96030703
	s_mul_hi_u32 s38, s35, s37                                 // 00000000DE24: 96A62523
	s_add_i32 s3, s39, s3                                      // 00000000DE28: 81030327
	s_mul_hi_u32 s39, s7, s37                                  // 00000000DE2C: 96A72507
	s_add_i32 s3, s3, s36                                      // 00000000DE30: 81032403
	s_mul_i32 s36, s7, s37                                     // 00000000DE34: 96242507
	s_mul_i32 s41, s35, s3                                     // 00000000DE38: 96290323
	s_mul_hi_u32 s40, s35, s3                                  // 00000000DE3C: 96A80323
	s_add_u32 s38, s38, s41                                    // 00000000DE40: 80262926
	s_addc_u32 s40, 0, s40                                     // 00000000DE44: 82282880
	s_mul_hi_u32 s37, s7, s3                                   // 00000000DE48: 96A50307
	s_add_u32 s36, s38, s36                                    // 00000000DE4C: 80242426
	s_mul_i32 s3, s7, s3                                       // 00000000DE50: 96030307
	s_addc_u32 s36, s40, s39                                   // 00000000DE54: 82242728
	s_addc_u32 s37, s37, 0                                     // 00000000DE58: 82258025
	s_add_u32 s3, s36, s3                                      // 00000000DE5C: 80030324
	s_addc_u32 s36, 0, s37                                     // 00000000DE60: 82242580
	s_add_u32 s3, s35, s3                                      // 00000000DE64: 80030323
	s_cselect_b32 s35, -1, 0                                   // 00000000DE68: 982380C1
	v_xor_b32_e32 v3, v3, v18                                  // 00000000DE6C: 3A062503
	s_cmp_lg_u32 s35, 0                                        // 00000000DE70: BF078023
	v_mul_hi_u32 v20, v19, s3                                  // 00000000DE74: D72D0014 00000713
	s_addc_u32 s7, s7, s36                                     // 00000000DE7C: 82072407
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000DE80: BF8701B9
	v_mad_u64_u32 v[8:9], null, v19, s7, 0                     // 00000000DE84: D6FE7C08 02000F13
	v_mad_u64_u32 v[10:11], null, v3, s3, 0                    // 00000000DE8C: D6FE7C0A 02000703
	v_mad_u64_u32 v[16:17], null, v3, s7, 0                    // 00000000DE94: D6FE7C10 02000F03
	v_add_co_u32 v8, vcc_lo, v20, v8                           // 00000000DE9C: D7006A08 00021114
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DEA4: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000DEA8: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v10                           // 00000000DEB0: D7006A08 00021508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000DEB8: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v11, vcc_lo            // 00000000DEBC: 40101709
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v17, vcc_lo             // 00000000DEC0: 40122280
	v_add_co_u32 v10, vcc_lo, v8, v16                          // 00000000DEC4: D7006A0A 00022108
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DECC: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v9, vcc_lo               // 00000000DED0: D5207C0B 01AA1280
	v_mul_lo_u32 v16, s27, v10                                 // 00000000DED8: D72C0010 0002141B
	v_mad_u64_u32 v[8:9], null, s26, v10, 0                    // 00000000DEE0: D6FE7C08 0202141A
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DEE8: BF870113
	v_mul_lo_u32 v17, s26, v11                                 // 00000000DEEC: D72C0011 0002161A
	v_sub_co_u32 v8, vcc_lo, v19, v8                           // 00000000DEF4: D7016A08 00021113
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000DEFC: BF8700A2
	v_add3_u32 v9, v9, v17, v16                                // 00000000DF00: D6550009 04422309
	v_add_co_u32 v17, s3, v10, 2                               // 00000000DF08: D7000311 0001050A
	v_add_co_ci_u32_e64 v19, null, 0, v11, s3                  // 00000000DF10: D5207C13 000E1680
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000DF18: BF8701B3
	v_sub_nc_u32_e32 v16, v3, v9                               // 00000000DF1C: 4C201303
	v_sub_co_u32 v20, s3, v8, s26                              // 00000000DF20: D7010314 00003508
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 00000000DF28: D5217C03 01AA1303
	v_subrev_co_ci_u32_e64 v16, null, s27, v16, vcc_lo         // 00000000DF30: D5227C10 01AA201B
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DF38: BF870113
	v_cmp_le_u32_e32 vcc_lo, s26, v20                          // 00000000DF3C: 7C96281A
	v_subrev_co_ci_u32_e64 v16, null, 0, v16, s3               // 00000000DF40: D5227C10 000E2080
	v_cndmask_b32_e64 v9, 0, -1, vcc_lo                        // 00000000DF48: D5010009 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000DF50: BF870002
	v_cmp_le_u32_e32 vcc_lo, s27, v16                          // 00000000DF54: 7C96201B
	v_cndmask_b32_e64 v20, 0, -1, vcc_lo                       // 00000000DF58: D5010014 01A98280
	v_cmp_le_u32_e32 vcc_lo, s26, v8                           // 00000000DF60: 7C96101A
	v_cndmask_b32_e64 v8, 0, -1, vcc_lo                        // 00000000DF64: D5010008 01A98280
	v_cmp_le_u32_e32 vcc_lo, s27, v3                           // 00000000DF6C: 7C96061B
	v_cndmask_b32_e64 v21, 0, -1, vcc_lo                       // 00000000DF70: D5010015 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s27, v16                          // 00000000DF78: 7C94201B
	v_cndmask_b32_e32 v9, v20, v9, vcc_lo                      // 00000000DF7C: 02121314
	v_add_co_u32 v16, vcc_lo, v10, 1                           // 00000000DF80: D7006A10 0001030A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000DF88: BF8701D1
	v_add_co_ci_u32_e64 v20, null, 0, v11, vcc_lo              // 00000000DF8C: D5207C14 01AA1680
	v_cmp_eq_u32_e32 vcc_lo, s27, v3                           // 00000000DF94: 7C94061B
	v_cndmask_b32_e32 v3, v21, v8, vcc_lo                      // 00000000DF98: 02061115
	v_cmp_ne_u32_e32 vcc_lo, 0, v9                             // 00000000DF9C: 7C9A1280
	v_xor_b32_e32 v9, s6, v18                                  // 00000000DFA0: 3A122406
	v_cmp_ne_u32_e64 s3, 0, v3                                 // 00000000DFA4: D44D0003 00020680
	v_cndmask_b32_e32 v3, v16, v17, vcc_lo                     // 00000000DFAC: 02062310
	v_cndmask_b32_e32 v8, v20, v19, vcc_lo                     // 00000000DFB0: 02102714
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DFB4: BF870112
	v_cndmask_b32_e64 v3, v10, v3, s3                          // 00000000DFB8: D5010003 000E070A
	v_cndmask_b32_e64 v8, v11, v8, s3                          // 00000000DFC0: D5010008 000E110B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000DFC8: BF870112
	v_xor_b32_e32 v3, v3, v9                                   // 00000000DFCC: 3A061303
	v_xor_b32_e32 v10, v8, v9                                  // 00000000DFD0: 3A141308
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000DFD4: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v9                            // 00000000DFD8: D7016A08 00021303
	v_sub_co_ci_u32_e64 v9, null, v10, v9, vcc_lo              // 00000000DFE0: D5217C09 01AA130A
	s_and_not1_saveexec_b32 s3, s34                            // 00000000DFE8: BE833022
	s_cbranch_execz 18                                         // 00000000DFEC: BFA50012 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x738>
	v_mul_hi_u32 v3, v6, v15                                   // 00000000DFF0: D72D0003 00021F06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000DFF8: BF870091
	v_mul_lo_u32 v8, v3, s8                                    // 00000000DFFC: D72C0008 00001103
	v_sub_nc_u32_e32 v8, v6, v8                                // 00000000E004: 4C101106
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E008: BF870121
	v_subrev_nc_u32_e32 v10, s8, v8                            // 00000000E00C: 4E141008
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000E010: 7C961008
	v_dual_cndmask_b32 v8, v8, v10 :: v_dual_add_nc_u32 v9, 1, v3// 00000000E014: CA601508 08080681
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E01C: BF870111
	v_cndmask_b32_e32 v3, v3, v9, vcc_lo                       // 00000000E020: 02061303
	v_cmp_le_u32_e32 vcc_lo, s8, v8                            // 00000000E024: 7C961008
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E028: BF870092
	v_add_nc_u32_e32 v9, 1, v3                                 // 00000000E02C: 4A120681
	v_dual_cndmask_b32 v8, v3, v9 :: v_dual_mov_b32 v9, v2     // 00000000E030: CA501303 08080102
	s_or_b32 exec_lo, exec_lo, s3                              // 00000000E038: 8C7E037E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E03C: BF870121
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 00000000E040: D73C0008 00021082
	v_mov_b32_e32 v3, 0                                        // 00000000E048: 7E060280
	v_add_co_u32 v10, vcc_lo, s28, v8                          // 00000000E04C: D7006A0A 0002101C
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000E054: BF8700C1
	v_add_co_ci_u32_e64 v11, null, s29, v9, vcc_lo             // 00000000E058: D5207C0B 01AA121D
	global_load_b32 v10, v[10:11], off                         // 00000000E060: DC520000 0A7C000A
	s_waitcnt vmcnt(0)                                         // 00000000E068: BF8903F7
	v_ashrrev_i32_e32 v11, 31, v10                             // 00000000E06C: 3416149F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[10:11]                      // 00000000E070: 7CA214C1
	v_cmp_gt_i64_e64 s3, s[4:5], v[10:11]                      // 00000000E074: D4540003 00021404
	s_and_b32 s7, vcc_lo, s3                                   // 00000000E07C: 8B07036A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E080: BF870009
	s_and_saveexec_b32 s3, s7                                  // 00000000E084: BE832007
	s_cbranch_execz 65295                                      // 00000000E088: BFA5FF0F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x3c8>
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 00000000E08C: D73C000A 00021482
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E094: BF870091
	v_sub_co_u32 v3, vcc_lo, v10, v8                           // 00000000E098: D7016A03 0002110A
	v_sub_co_ci_u32_e64 v8, null, v11, v9, vcc_lo              // 00000000E0A0: D5217C08 01AA130B
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E0A8: BF870112
	v_mul_lo_u32 v11, s9, v3                                   // 00000000E0AC: D72C000B 00020609
	v_mul_lo_u32 v10, s8, v8                                   // 00000000E0B4: D72C000A 00021008
	v_mad_u64_u32 v[8:9], null, s8, v3, v[4:5]                 // 00000000E0BC: D6FE7C08 04120608
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E0C4: BF870001
	v_add3_u32 v9, v11, v9, v10                                // 00000000E0C8: D6550009 042A130B
	global_load_b32 v3, v[8:9], off                            // 00000000E0D0: DC520000 037C0008
	s_branch 65275                                             // 00000000E0D8: BFA0FEFB <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x3c8>
	s_or_b32 exec_lo, exec_lo, s14                             // 00000000E0DC: 8C7E0E7E
	s_mul_i32 s3, s22, s19                                     // 00000000E0E0: 96031316
	s_mul_hi_u32 s4, s22, s18                                  // 00000000E0E4: 96841216
	s_mul_i32 s5, s22, s18                                     // 00000000E0E8: 96051216
	s_add_i32 s3, s4, s3                                       // 00000000E0EC: 81030304
	s_mul_i32 s4, s23, s18                                     // 00000000E0F0: 96041217
	s_waitcnt lgkmcnt(0)                                       // 00000000E0F4: BF89FC07
	s_add_i32 s3, s3, s4                                       // 00000000E0F8: 81030403
	s_sub_u32 s4, s15, s5                                      // 00000000E0FC: 8084050F
	s_subb_u32 s3, 0, s3                                       // 00000000E100: 82830380
	s_mul_i32 s5, s4, s21                                      // 00000000E104: 96051504
	s_mul_hi_u32 s6, s4, s20                                   // 00000000E108: 96861404
	s_mul_i32 s3, s3, s20                                      // 00000000E10C: 96031403
	s_add_i32 s5, s6, s5                                       // 00000000E110: 81050506
	s_mul_i32 s4, s4, s20                                      // 00000000E114: 96041404
	s_add_i32 s5, s5, s3                                       // 00000000E118: 81050305
	s_add_u32 s6, s4, s20                                      // 00000000E11C: 80061404
	s_addc_u32 s7, s5, s21                                     // 00000000E120: 82071505
	s_barrier                                                  // 00000000E124: BFBD0000
	v_cmp_lt_i64_e64 s3, s[6:7], s[16:17]                      // 00000000E128: D4510003 00002006
	buffer_gl0_inv                                             // 00000000E130: E0AC0000 00000000
	s_and_b32 s3, s3, exec_lo                                  // 00000000E138: 8B037E03
	s_cselect_b32 s7, s7, s17                                  // 00000000E13C: 98071107
	s_cselect_b32 s6, s6, s16                                  // 00000000E140: 98061006
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E144: BF870009
	v_cmp_ge_i64_e64 s3, s[4:5], s[6:7]                        // 00000000E148: D4560003 00000C04
	s_and_b32 vcc_lo, exec_lo, s3                              // 00000000E150: 8B6A037E
	s_cbranch_vccnz 610                                        // 00000000E154: BFA40262 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x11e0>
	s_clause 0x1                                               // 00000000E158: BF850001
	s_load_b32 s14, s[0:1], 0x58                               // 00000000E15C: F4000380 F8000058
	s_load_b32 s0, s[0:1], 0x6c                                // 00000000E164: F4000000 F800006C
	v_rcp_iflag_f32_e32 v2, v13                                // 00000000E16C: 7E04570D
	s_lshl_b32 s1, s10, 2                                      // 00000000E170: 8401820A
	s_mul_i32 s15, s22, s17                                    // 00000000E174: 960F1116
	s_add_i32 s3, s1, 0                                        // 00000000E178: 81038001
	s_mul_hi_u32 s17, s22, s16                                 // 00000000E17C: 96911016
	s_mul_i32 s1, s23, s16                                     // 00000000E180: 96011017
	v_add_nc_u32_e32 v8, s3, v12                               // 00000000E184: 4A101803
	s_waitcnt_depctr 0xfff                                     // 00000000E188: BF880FFF
	v_dual_mul_f32 v2, 0x4f7ffffe, v2 :: v_dual_add_nc_u32 v9, 0, v12// 00000000E18C: C8E004FF 02081880 4F7FFFFE
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E198: BF870001
	v_cvt_u32_f32_e32 v3, v2                                   // 00000000E19C: 7E060F02
	s_waitcnt lgkmcnt(0)                                       // 00000000E1A0: BF89FC07
	s_cmp_eq_u32 s14, 0                                        // 00000000E1A4: BF06800E
	s_cselect_b32 s18, -1, 0                                   // 00000000E1A8: 981280C1
	s_and_b32 s19, s0, 0xffff                                  // 00000000E1AC: 8B13FF00 0000FFFF
	s_bfe_u32 s20, s0, 0xf0001                                 // 00000000E1B4: 9314FF00 000F0001
	s_cmp_gt_u32 s19, 1                                        // 00000000E1BC: BF088113
	s_mul_i32 s0, s22, s16                                     // 00000000E1C0: 96001016
	s_cselect_b32 s21, -1, 0                                   // 00000000E1C4: 981580C1
	s_add_i32 s14, s17, s15                                    // 00000000E1C8: 810E0F11
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000E1CC: BF870499
	s_add_i32 s1, s14, s1                                      // 00000000E1D0: 8101010E
	s_lshl_b64 s[0:1], s[0:1], 2                               // 00000000E1D4: 84808200
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E1D8: BF870009
	s_add_u32 s22, s24, s0                                     // 00000000E1DC: 80160018
	s_addc_u32 s23, s25, s1                                    // 00000000E1E0: 82170119
	s_sub_i32 s0, 0, s8                                        // 00000000E1E4: 81800880
	s_lshl_b32 s24, s19, 2                                     // 00000000E1E8: 84188213
	v_mul_lo_u32 v2, s0, v3                                    // 00000000E1EC: D72C0002 00020600
	v_cmp_eq_u32_e64 s0, 0, v0                                 // 00000000E1F4: D44A0000 00020080
	s_ashr_i32 s14, s9, 31                                     // 00000000E1FC: 860E9F09
	v_mul_hi_u32 v4, v3, v2                                    // 00000000E200: D72D0004 00020503
	v_mov_b32_e32 v2, 0                                        // 00000000E208: 7E040280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000E20C: BF870002
	v_add_nc_u32_e32 v10, v3, v4                               // 00000000E210: 4A140903
	s_branch 11                                                // 00000000E214: BFA0000B <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x944>
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E218: 8C7E017E
	s_add_u32 s4, s4, 1                                        // 00000000E21C: 80048104
	s_addc_u32 s5, s5, 0                                       // 00000000E220: 82058005
	s_waitcnt_vscnt null, 0x0                                  // 00000000E224: BC7C0000
	v_cmp_ge_i64_e64 s1, s[4:5], s[6:7]                        // 00000000E228: D4560001 00000C04
	s_barrier                                                  // 00000000E230: BFBD0000
	buffer_gl0_inv                                             // 00000000E234: E0AC0000 00000000
	s_and_b32 vcc_lo, exec_lo, s1                              // 00000000E23C: 8B6A017E
	s_cbranch_vccnz 551                                        // 00000000E240: BFA40227 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x11e0>
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000E244: BF870002
	v_mov_b32_e32 v11, v2                                      // 00000000E248: 7E160302
	s_and_saveexec_b32 s25, s2                                 // 00000000E24C: BE992002
	s_cbranch_execz 486                                        // 00000000E250: BFA501E6 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x10ec>
	s_mul_i32 s1, s4, s9                                       // 00000000E254: 96010904
	s_mul_hi_u32 s15, s4, s8                                   // 00000000E258: 968F0804
	s_mul_i32 s16, s4, s8                                      // 00000000E25C: 96100804
	s_add_i32 s1, s15, s1                                      // 00000000E260: 8101010F
	s_mul_i32 s15, s5, s8                                      // 00000000E264: 960F0805
	v_dual_mov_b32 v11, 0 :: v_dual_mov_b32 v12, v9            // 00000000E268: CA100080 0B0C0109
	s_add_i32 s17, s1, s15                                     // 00000000E270: 81110F01
	v_dual_mov_b32 v5, v1 :: v_dual_mov_b32 v4, v0             // 00000000E274: CA100101 05040100
	s_lshl_b64 s[16:17], s[16:17], 2                           // 00000000E27C: 84908210
	s_mov_b32 s27, 0                                           // 00000000E280: BE9B0080
	s_add_u32 s26, s12, s16                                    // 00000000E284: 801A100C
	s_addc_u32 s28, s13, s17                                   // 00000000E288: 821C110D
	s_branch 20                                                // 00000000E28C: BFA00014 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x9e0>
	s_or_b32 exec_lo, exec_lo, s16                             // 00000000E290: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E294: BF870009
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000E298: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E29C: BF870009
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E2A0: 8C7E017E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000E2A4: BF8700A1
	v_mul_f32_e32 v6, v14, v13                                 // 00000000E2A8: 100C1B0E
	v_add_co_u32 v4, vcc_lo, v4, s19                           // 00000000E2AC: D7006A04 00002704
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo                // 00000000E2B4: D5207C05 01AA0A80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000E2BC: BF8701A3
	v_fmac_f32_e32 v6, v3, v7                                  // 00000000E2C0: 560C0F03
	v_add_nc_u32_e32 v12, s24, v12                             // 00000000E2C4: 4A181818
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[4:5]                  // 00000000E2C8: 7CA6080A
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000E2CC: BF8704A3
	v_add_f32_e32 v11, v11, v6                                 // 00000000E2D0: 06160D0B
	s_or_b32 s27, vcc_lo, s27                                  // 00000000E2D4: 8C1B1B6A
	s_and_not1_b32 exec_lo, exec_lo, s27                       // 00000000E2D8: 917E1B7E
	s_cbranch_execz 450                                        // 00000000E2DC: BFA501C2 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x10e8>
	v_or_b32_e32 v3, s9, v5                                    // 00000000E2E0: 38060A09
	s_mov_b32 s1, exec_lo                                      // 00000000E2E4: BE81007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E2E8: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000E2EC: 7DBA0480
	s_xor_b32 s29, exec_lo, s1                                 // 00000000E2F0: 8D1D017E
	s_cbranch_execz 176                                        // 00000000E2F4: BFA500B0 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xcb8>
	s_add_u32 s16, s8, s14                                     // 00000000E2F8: 80100E08
	s_mov_b32 s15, s14                                         // 00000000E2FC: BE8F000E
	s_addc_u32 s17, s9, s14                                    // 00000000E300: 82110E09
	v_ashrrev_i32_e32 v17, 31, v5                              // 00000000E304: 34220A9F
	s_xor_b64 s[16:17], s[16:17], s[14:15]                     // 00000000E308: 8D900E10
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000E30C: BF870159
	v_cvt_f32_u32_e32 v3, s16                                  // 00000000E310: 7E060C10
	v_cvt_f32_u32_e32 v6, s17                                  // 00000000E314: 7E0C0C11
	s_sub_u32 s1, 0, s16                                       // 00000000E318: 80811080
	s_subb_u32 s31, 0, s17                                     // 00000000E31C: 829F1180
	v_add_co_u32 v7, vcc_lo, v4, v17                           // 00000000E320: D7006A07 00022304
	v_fmac_f32_e32 v3, 0x4f800000, v6                          // 00000000E328: 56060CFF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E330: BF870112
	v_xor_b32_e32 v18, v7, v17                                 // 00000000E334: 3A242307
	v_rcp_f32_e32 v3, v3                                       // 00000000E338: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000E33C: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000E340: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E348: BF870091
	v_mul_f32_e32 v6, 0x2f800000, v3                           // 00000000E34C: 100C06FF 2F800000
	v_trunc_f32_e32 v6, v6                                     // 00000000E354: 7E0C4306
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E358: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v6                          // 00000000E35C: 56060CFF CF800000
	v_cvt_u32_f32_e32 v6, v6                                   // 00000000E364: 7E0C0F06
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000E368: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E36C: BF870112
	v_readfirstlane_b32 s15, v6                                // 00000000E370: 7E1E0506
	v_readfirstlane_b32 s30, v3                                // 00000000E374: 7E3C0503
	s_mul_i32 s33, s1, s15                                     // 00000000E378: 96210F01
	v_add_co_ci_u32_e64 v3, null, v5, v17, vcc_lo              // 00000000E37C: D5207C03 01AA2305
	s_mul_hi_u32 s35, s1, s30                                  // 00000000E384: 96A31E01
	s_mul_i32 s34, s31, s30                                    // 00000000E388: 96221E1F
	s_add_i32 s33, s35, s33                                    // 00000000E38C: 81212123
	s_mul_i32 s36, s1, s30                                     // 00000000E390: 96241E01
	s_add_i32 s33, s33, s34                                    // 00000000E394: 81212221
	s_mul_hi_u32 s35, s30, s36                                 // 00000000E398: 96A3241E
	s_mul_i32 s38, s30, s33                                    // 00000000E39C: 9626211E
	s_mul_hi_u32 s37, s15, s36                                 // 00000000E3A0: 96A5240F
	s_mul_i32 s34, s15, s36                                    // 00000000E3A4: 9622240F
	s_mul_hi_u32 s36, s30, s33                                 // 00000000E3A8: 96A4211E
	s_add_u32 s35, s35, s38                                    // 00000000E3AC: 80232623
	s_addc_u32 s36, 0, s36                                     // 00000000E3B0: 82242480
	s_mul_hi_u32 s39, s15, s33                                 // 00000000E3B4: 96A7210F
	s_add_u32 s34, s35, s34                                    // 00000000E3B8: 80222223
	s_mul_i32 s33, s15, s33                                    // 00000000E3BC: 9621210F
	s_addc_u32 s34, s36, s37                                   // 00000000E3C0: 82222524
	s_addc_u32 s35, s39, 0                                     // 00000000E3C4: 82238027
	s_add_u32 s33, s34, s33                                    // 00000000E3C8: 80212122
	s_addc_u32 s34, 0, s35                                     // 00000000E3CC: 82222380
	s_add_u32 s30, s30, s33                                    // 00000000E3D0: 801E211E
	s_cselect_b32 s33, -1, 0                                   // 00000000E3D4: 982180C1
	s_mul_hi_u32 s35, s1, s30                                  // 00000000E3D8: 96A31E01
	s_cmp_lg_u32 s33, 0                                        // 00000000E3DC: BF078021
	s_mul_i32 s33, s1, s30                                     // 00000000E3E0: 96211E01
	s_addc_u32 s15, s15, s34                                   // 00000000E3E4: 820F220F
	s_mul_i32 s31, s31, s30                                    // 00000000E3E8: 961F1E1F
	s_mul_i32 s1, s1, s15                                      // 00000000E3EC: 96010F01
	s_mul_hi_u32 s34, s30, s33                                 // 00000000E3F0: 96A2211E
	s_add_i32 s1, s35, s1                                      // 00000000E3F4: 81010123
	s_mul_hi_u32 s35, s15, s33                                 // 00000000E3F8: 96A3210F
	s_add_i32 s1, s1, s31                                      // 00000000E3FC: 81011F01
	s_mul_i32 s31, s15, s33                                    // 00000000E400: 961F210F
	s_mul_i32 s37, s30, s1                                     // 00000000E404: 9625011E
	s_mul_hi_u32 s36, s30, s1                                  // 00000000E408: 96A4011E
	s_add_u32 s34, s34, s37                                    // 00000000E40C: 80222522
	s_addc_u32 s36, 0, s36                                     // 00000000E410: 82242480
	s_mul_hi_u32 s33, s15, s1                                  // 00000000E414: 96A1010F
	s_add_u32 s31, s34, s31                                    // 00000000E418: 801F1F22
	s_mul_i32 s1, s15, s1                                      // 00000000E41C: 9601010F
	s_addc_u32 s31, s36, s35                                   // 00000000E420: 821F2324
	s_addc_u32 s33, s33, 0                                     // 00000000E424: 82218021
	s_add_u32 s1, s31, s1                                      // 00000000E428: 8001011F
	s_addc_u32 s31, 0, s33                                     // 00000000E42C: 821F2180
	s_add_u32 s1, s30, s1                                      // 00000000E430: 8001011E
	s_cselect_b32 s30, -1, 0                                   // 00000000E434: 981E80C1
	v_xor_b32_e32 v3, v3, v17                                  // 00000000E438: 3A062303
	s_cmp_lg_u32 s30, 0                                        // 00000000E43C: BF07801E
	v_mul_hi_u32 v19, v18, s1                                  // 00000000E440: D72D0013 00000312
	s_addc_u32 s15, s15, s31                                   // 00000000E448: 820F1F0F
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000E44C: BF8701B9
	v_mad_u64_u32 v[6:7], null, v18, s15, 0                    // 00000000E450: D6FE7C06 02001F12
	v_mad_u64_u32 v[13:14], null, v3, s1, 0                    // 00000000E458: D6FE7C0D 02000303
	v_mad_u64_u32 v[15:16], null, v3, s15, 0                   // 00000000E460: D6FE7C0F 02001F03
	v_add_co_u32 v6, vcc_lo, v19, v6                           // 00000000E468: D7006A06 00020D13
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E470: BF870111
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000000E474: D5207C07 01AA0E80
	v_add_co_u32 v6, vcc_lo, v6, v13                           // 00000000E47C: D7006A06 00021B06
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E484: BF870122
	v_add_co_ci_u32_e32 v6, vcc_lo, v7, v14, vcc_lo            // 00000000E488: 400C1D07
	v_add_co_ci_u32_e32 v7, vcc_lo, 0, v16, vcc_lo             // 00000000E48C: 400E2080
	v_add_co_u32 v13, vcc_lo, v6, v15                          // 00000000E490: D7006A0D 00021F06
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E498: BF870111
	v_add_co_ci_u32_e64 v14, null, 0, v7, vcc_lo               // 00000000E49C: D5207C0E 01AA0E80
	v_mul_lo_u32 v15, s17, v13                                 // 00000000E4A4: D72C000F 00021A11
	v_mad_u64_u32 v[6:7], null, s16, v13, 0                    // 00000000E4AC: D6FE7C06 02021A10
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E4B4: BF870113
	v_mul_lo_u32 v13, s16, v14                                 // 00000000E4B8: D72C000D 00021C10
	v_sub_co_u32 v6, vcc_lo, v18, v6                           // 00000000E4C0: D7016A06 00020D12
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E4C8: BF870112
	v_add3_u32 v7, v7, v13, v15                                // 00000000E4CC: D6550007 043E1B07
	v_cmp_le_u32_e64 s1, s16, v6                               // 00000000E4D4: D44B0001 00020C10
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000E4DC: BF8701A2
	v_sub_nc_u32_e32 v13, v3, v7                               // 00000000E4E0: 4C1A0F03
	v_sub_co_ci_u32_e64 v3, null, v3, v7, vcc_lo               // 00000000E4E4: D5217C03 01AA0F03
	v_cndmask_b32_e64 v15, 0, -1, s1                           // 00000000E4EC: D501000F 00058280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000E4F4: BF8700A3
	v_subrev_co_ci_u32_e64 v13, null, s17, v13, vcc_lo         // 00000000E4F8: D5227C0D 01AA1A11
	v_sub_co_u32 v7, vcc_lo, v6, s16                           // 00000000E500: D7016A07 00002106
	v_subrev_co_ci_u32_e64 v14, null, 0, v13, vcc_lo           // 00000000E508: D5227C0E 01AA1A80
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000E510: BF8701B2
	v_cmp_le_u32_e64 s1, s16, v7                               // 00000000E514: D44B0001 00020E10
	v_subrev_co_ci_u32_e64 v13, null, s17, v13, vcc_lo         // 00000000E51C: D5227C0D 01AA1A11
	v_cmp_le_u32_e32 vcc_lo, s17, v3                           // 00000000E524: 7C960611
	v_cndmask_b32_e64 v16, 0, -1, s1                           // 00000000E528: D5010010 00058280
	v_cmp_le_u32_e64 s1, s17, v14                              // 00000000E530: D44B0001 00021C11
	v_cndmask_b32_e64 v19, 0, -1, vcc_lo                       // 00000000E538: D5010013 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s17, v14                          // 00000000E540: 7C941C11
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E544: BF870123
	v_cndmask_b32_e64 v18, 0, -1, s1                           // 00000000E548: D5010012 00058280
	v_cmp_eq_u32_e64 s1, s17, v3                               // 00000000E550: D44A0001 00020611
	v_cndmask_b32_e32 v16, v18, v16, vcc_lo                    // 00000000E558: 02202112
	v_sub_co_u32 v18, vcc_lo, v7, s16                          // 00000000E55C: D7016A12 00002107
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000E564: BF870191
	v_subrev_co_ci_u32_e64 v13, null, 0, v13, vcc_lo           // 00000000E568: D5227C0D 01AA1A80
	v_cmp_ne_u32_e32 vcc_lo, 0, v16                            // 00000000E570: 7C9A2080
	v_cndmask_b32_e64 v15, v19, v15, s1                        // 00000000E574: D501000F 00061F13
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000E57C: BF8701A3
	v_cndmask_b32_e32 v13, v14, v13, vcc_lo                    // 00000000E580: 021A1B0E
	v_cndmask_b32_e32 v7, v7, v18, vcc_lo                      // 00000000E584: 020E2507
	v_cmp_ne_u32_e32 vcc_lo, 0, v15                            // 00000000E588: 7C9A1E80
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E58C: BF870092
	v_dual_cndmask_b32 v6, v6, v7 :: v_dual_cndmask_b32 v3, v3, v13// 00000000E590: CA520F06 06021B03
	v_xor_b32_e32 v6, v6, v17                                  // 00000000E598: 3A0C2306
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E59C: BF870112
	v_xor_b32_e32 v3, v3, v17                                  // 00000000E5A0: 3A062303
	v_sub_co_u32 v6, vcc_lo, v6, v17                           // 00000000E5A4: D7016A06 00022306
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E5AC: BF870001
	v_sub_co_ci_u32_e64 v7, null, v3, v17, vcc_lo              // 00000000E5B0: D5217C07 01AA2303
	s_and_not1_saveexec_b32 s1, s29                            // 00000000E5B8: BE81301D
	s_cbranch_execz 15                                         // 00000000E5BC: BFA5000F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xcfc>
	v_mul_hi_u32 v3, v4, v10                                   // 00000000E5C0: D72D0003 00021504
	v_mov_b32_e32 v7, v2                                       // 00000000E5C8: 7E0E0302
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E5CC: BF870092
	v_mul_lo_u32 v3, v3, s8                                    // 00000000E5D0: D72C0003 00001103
	v_sub_nc_u32_e32 v3, v4, v3                                // 00000000E5D8: 4C060704
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E5DC: BF870121
	v_subrev_nc_u32_e32 v6, s8, v3                             // 00000000E5E0: 4E0C0608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000E5E4: 7C960608
	v_cndmask_b32_e32 v3, v3, v6, vcc_lo                       // 00000000E5E8: 02060D03
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E5EC: BF870121
	v_subrev_nc_u32_e32 v6, s8, v3                             // 00000000E5F0: 4E0C0608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 00000000E5F4: 7C960608
	v_cndmask_b32_e32 v6, v3, v6, vcc_lo                       // 00000000E5F8: 020C0D03
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E5FC: 8C7E017E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000E600: BF8700B1
	v_lshlrev_b64 v[6:7], 2, v[6:7]                            // 00000000E604: D73C0006 00020C82
	ds_load_b32 v13, v12                                       // 00000000E60C: D8D80000 0D00000C
	v_add_co_u32 v6, vcc_lo, s26, v6                           // 00000000E614: D7006A06 00020C1A
	v_add_co_ci_u32_e64 v7, null, s28, v7, vcc_lo              // 00000000E61C: D5207C07 01AA0E1C
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E624: 916A127E
	global_load_b32 v6, v[6:7], off                            // 00000000E628: DC520000 067C0006
	s_waitcnt lgkmcnt(0)                                       // 00000000E630: BF89FC07
	v_lshlrev_b32_e32 v3, 16, v13                              // 00000000E634: 30061A90
	s_cbranch_vccz 13                                          // 00000000E638: BFA3000D <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xd70>
	s_waitcnt vmcnt(0)                                         // 00000000E63C: BF8903F7
	v_lshlrev_b32_e32 v7, 16, v6                               // 00000000E640: 300E0C90
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E644: 916A127E
	s_cbranch_vccz 68                                          // 00000000E648: BFA30044 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xe5c>
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E64C: 916A127E
	s_cbranch_vccz 123                                         // 00000000E650: BFA3007B <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xf40>
	v_and_b32_e32 v14, 0xffff0000, v13                         // 00000000E654: 361C1AFF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E65C: 916A127E
	s_cbranch_vccz 175                                         // 00000000E660: BFA300AF <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1020>
	v_and_b32_e32 v13, 0xffff0000, v6                          // 00000000E664: 361A0CFF FFFF0000
	s_branch 65293                                             // 00000000E66C: BFA0FF0D <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x9a4>
	v_bfe_u32 v7, v13, 10, 5                                   // 00000000E670: D6100007 0215150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E678: BF870122
	v_and_b32_e32 v3, 0x80000000, v3                           // 00000000E67C: 360606FF 80000000
	s_mov_b32 s1, exec_lo                                      // 00000000E684: BE81007E
	v_cmpx_lt_i32_e32 30, v7                                   // 00000000E688: 7D820E9E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000E68C: 8D01017E
	v_lshlrev_b32_e32 v7, 13, v13                              // 00000000E690: 300E1A8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E694: BF870091
	v_and_b32_e32 v7, 0x7fe000, v7                             // 00000000E698: 360E0EFF 007FE000
	v_or3_b32 v3, v7, v3, 0x7f800000                           // 00000000E6A0: D6580003 03FE0707 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000E6AC: BE813001
	s_cbranch_execz 36                                         // 00000000E6B0: BFA50024 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xe44>
	v_and_b32_e32 v14, 0x3ff, v13                              // 00000000E6B4: 361C1AFF 000003FF
	s_mov_b32 s15, exec_lo                                     // 00000000E6BC: BE8F007E
	v_cmpx_ne_u32_e32 0, v7                                    // 00000000E6C0: 7D9A0E80
	s_xor_b32 s15, exec_lo, s15                                // 00000000E6C4: 8D0F0F7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E6C8: BF870092
	v_lshlrev_b32_e32 v14, 13, v14                             // 00000000E6CC: 301C1C8D
	v_lshl_or_b32 v7, v7, 23, v14                              // 00000000E6D0: D6560007 04392F07
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E6D8: BF870001
	v_add3_u32 v3, v7, v3, 0x38000000                          // 00000000E6DC: D6550003 03FE0707 38000000
	s_and_not1_saveexec_b32 s15, s15                           // 00000000E6E8: BE8F300F
	s_cbranch_execz 19                                         // 00000000E6EC: BFA50013 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xe3c>
	s_mov_b32 s16, exec_lo                                     // 00000000E6F0: BE90007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000E6F4: 7D9A1C80
	s_cbranch_execz 15                                         // 00000000E6F8: BFA5000F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xe38>
	v_clz_i32_u32_e32 v7, v14                                  // 00000000E6FC: 7E0E730E
	v_or_b32_e32 v3, 0x43000000, v3                            // 00000000E700: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E708: BF870122
	v_xor_b32_e32 v14, 31, v7                                  // 00000000E70C: 3A1C0E9F
	v_lshlrev_b32_e32 v7, 23, v7                               // 00000000E710: 300E0E97
	v_sub_nc_u32_e32 v14, 9, v14                               // 00000000E714: 4C1C1C89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E718: BF870112
	v_sub_nc_u32_e32 v3, v3, v7                                // 00000000E71C: 4C060F03
	v_lshlrev_b32_e32 v14, v14, v13                            // 00000000E720: 301C1B0E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E724: BF870091
	v_lshlrev_b32_e32 v14, 14, v14                             // 00000000E728: 301C1C8E
	v_and_or_b32 v3, 0x7fc000, v14, v3                         // 00000000E72C: D6570003 040E1CFF 007FC000
	s_or_b32 exec_lo, exec_lo, s16                             // 00000000E738: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E73C: BF870009
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000E740: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E744: BF870009
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E748: 8C7E017E
	s_waitcnt vmcnt(0)                                         // 00000000E74C: BF8903F7
	v_lshlrev_b32_e32 v7, 16, v6                               // 00000000E750: 300E0C90
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E754: 916A127E
	s_cbranch_vccnz 65468                                      // 00000000E758: BFA4FFBC <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xd4c>
	v_bfe_u32 v14, v6, 10, 5                                   // 00000000E75C: D610000E 02151506
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E764: BF870122
	v_and_b32_e32 v7, 0x80000000, v7                           // 00000000E768: 360E0EFF 80000000
	s_mov_b32 s1, exec_lo                                      // 00000000E770: BE81007E
	v_cmpx_lt_i32_e32 30, v14                                  // 00000000E774: 7D821C9E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000E778: 8D01017E
	v_lshlrev_b32_e32 v14, 13, v6                              // 00000000E77C: 301C0C8D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E780: BF870091
	v_and_b32_e32 v14, 0x7fe000, v14                           // 00000000E784: 361C1CFF 007FE000
	v_or3_b32 v7, v14, v7, 0x7f800000                          // 00000000E78C: D6580007 03FE0F0E 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000E798: BE813001
	s_cbranch_execz 36                                         // 00000000E79C: BFA50024 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xf30>
	v_and_b32_e32 v15, 0x3ff, v6                               // 00000000E7A0: 361E0CFF 000003FF
	s_mov_b32 s15, exec_lo                                     // 00000000E7A8: BE8F007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000E7AC: 7D9A1C80
	s_xor_b32 s15, exec_lo, s15                                // 00000000E7B0: 8D0F0F7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E7B4: BF870092
	v_lshlrev_b32_e32 v15, 13, v15                             // 00000000E7B8: 301E1E8D
	v_lshl_or_b32 v14, v14, 23, v15                            // 00000000E7BC: D656000E 043D2F0E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E7C4: BF870001
	v_add3_u32 v7, v14, v7, 0x38000000                         // 00000000E7C8: D6550007 03FE0F0E 38000000
	s_and_not1_saveexec_b32 s15, s15                           // 00000000E7D4: BE8F300F
	s_cbranch_execz 19                                         // 00000000E7D8: BFA50013 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xf28>
	s_mov_b32 s16, exec_lo                                     // 00000000E7DC: BE90007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000E7E0: 7D9A1E80
	s_cbranch_execz 15                                         // 00000000E7E4: BFA5000F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xf24>
	v_clz_i32_u32_e32 v14, v15                                 // 00000000E7E8: 7E1C730F
	v_or_b32_e32 v7, 0x43000000, v7                            // 00000000E7EC: 380E0EFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E7F4: BF870122
	v_xor_b32_e32 v15, 31, v14                                 // 00000000E7F8: 3A1E1C9F
	v_lshlrev_b32_e32 v14, 23, v14                             // 00000000E7FC: 301C1C97
	v_sub_nc_u32_e32 v15, 9, v15                               // 00000000E800: 4C1E1E89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E804: BF870112
	v_sub_nc_u32_e32 v7, v7, v14                               // 00000000E808: 4C0E1D07
	v_lshlrev_b32_e32 v15, v15, v6                             // 00000000E80C: 301E0D0F
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E810: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000E814: 301E1E8E
	v_and_or_b32 v7, 0x7fc000, v15, v7                         // 00000000E818: D6570007 041E1EFF 007FC000
	s_or_b32 exec_lo, exec_lo, s16                             // 00000000E824: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E828: BF870009
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000E82C: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000E830: BF870499
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E834: 8C7E017E
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E838: 916A127E
	s_cbranch_vccnz 65413                                      // 00000000E83C: BFA4FF85 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xd54>
	v_bfe_u32 v16, v13, 26, 5                                  // 00000000E840: D6100010 0215350D
	v_and_b32_e32 v14, 0x80000000, v13                         // 00000000E848: 361C1AFF 80000000
	v_mov_b16_e32 v15.h, 0                                     // 00000000E850: 7F1E3880
	v_mov_b16_e32 v15.l, v13.h                                 // 00000000E854: 7E1E398D
	s_mov_b32 s1, exec_lo                                      // 00000000E858: BE81007E
	v_cmpx_lt_i32_e32 30, v16                                  // 00000000E85C: 7D82209E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000E860: 8D01017E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E864: BF870092
	v_lshlrev_b32_e32 v13, 13, v15                             // 00000000E868: 301A1E8D
	v_or3_b32 v14, v13, v14, 0x7f800000                        // 00000000E86C: D658000E 03FE1D0D 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000E878: BE813001
	s_cbranch_execz 36                                         // 00000000E87C: BFA50024 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1010>
	v_bfe_u32 v13, v13, 16, 10                                 // 00000000E880: D610000D 0229210D
	s_mov_b32 s15, exec_lo                                     // 00000000E888: BE8F007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000E88C: 7D9A2080
	s_xor_b32 s15, exec_lo, s15                                // 00000000E890: 8D0F0F7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E894: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 00000000E898: 301A1A8D
	v_lshl_or_b32 v13, v16, 23, v13                            // 00000000E89C: D656000D 04352F10
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E8A4: BF870001
	v_add3_u32 v14, v13, v14, 0x38000000                       // 00000000E8A8: D655000E 03FE1D0D 38000000
	s_and_not1_saveexec_b32 s15, s15                           // 00000000E8B4: BE8F300F
	s_cbranch_execz 19                                         // 00000000E8B8: BFA50013 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1008>
	s_mov_b32 s16, exec_lo                                     // 00000000E8BC: BE90007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000000E8C0: 7D9A1A80
	s_cbranch_execz 15                                         // 00000000E8C4: BFA5000F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1004>
	v_clz_i32_u32_e32 v13, v13                                 // 00000000E8C8: 7E1A730D
	v_or_b32_e32 v14, 0x43000000, v14                          // 00000000E8CC: 381C1CFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E8D4: BF870122
	v_xor_b32_e32 v16, 31, v13                                 // 00000000E8D8: 3A201A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 00000000E8DC: 301A1A97
	v_sub_nc_u32_e32 v16, 9, v16                               // 00000000E8E0: 4C202089
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E8E4: BF870112
	v_sub_nc_u32_e32 v13, v14, v13                             // 00000000E8E8: 4C1A1B0E
	v_lshlrev_b32_e32 v15, v16, v15                            // 00000000E8EC: 301E1F10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E8F0: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000E8F4: 301E1E8E
	v_and_or_b32 v14, 0x7fc000, v15, v13                       // 00000000E8F8: D657000E 04361EFF 007FC000
	s_or_b32 exec_lo, exec_lo, s16                             // 00000000E904: 8C7E107E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000E908: BF870009
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000E90C: 8C7E0F7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000E910: BF870499
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000E914: 8C7E017E
	s_and_not1_b32 vcc_lo, exec_lo, s18                        // 00000000E918: 916A127E
	s_cbranch_vccnz 65361                                      // 00000000E91C: BFA4FF51 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0xd64>
	v_bfe_u32 v16, v6, 26, 5                                   // 00000000E920: D6100010 02153506
	v_and_b32_e32 v13, 0x80000000, v6                          // 00000000E928: 361A0CFF 80000000
	v_mov_b16_e32 v15.h, 0                                     // 00000000E930: 7F1E3880
	v_mov_b16_e32 v15.l, v6.h                                  // 00000000E934: 7E1E3986
	s_mov_b32 s1, exec_lo                                      // 00000000E938: BE81007E
	v_cmpx_lt_i32_e32 30, v16                                  // 00000000E93C: 7D82209E
	s_xor_b32 s1, exec_lo, s1                                  // 00000000E940: 8D01017E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E944: BF870092
	v_lshlrev_b32_e32 v6, 13, v15                              // 00000000E948: 300C1E8D
	v_or3_b32 v13, v6, v13, 0x7f800000                         // 00000000E94C: D658000D 03FE1B06 7F800000
	s_and_not1_saveexec_b32 s1, s1                             // 00000000E958: BE813001
	s_cbranch_execz 65103                                      // 00000000E95C: BFA5FE4F <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x99c>
	v_bfe_u32 v6, v6, 16, 10                                   // 00000000E960: D6100006 02292106
	s_mov_b32 s15, exec_lo                                     // 00000000E968: BE8F007E
	v_cmpx_ne_u32_e32 0, v16                                   // 00000000E96C: 7D9A2080
	s_xor_b32 s15, exec_lo, s15                                // 00000000E970: 8D0F0F7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E974: BF870092
	v_lshlrev_b32_e32 v6, 13, v6                               // 00000000E978: 300C0C8D
	v_lshl_or_b32 v6, v16, 23, v6                              // 00000000E97C: D6560006 04192F10
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000E984: BF870001
	v_add3_u32 v13, v6, v13, 0x38000000                        // 00000000E988: D655000D 03FE1B06 38000000
	s_and_not1_saveexec_b32 s15, s15                           // 00000000E994: BE8F300F
	s_cbranch_execz 65086                                      // 00000000E998: BFA5FE3E <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x994>
	s_mov_b32 s16, exec_lo                                     // 00000000E99C: BE90007E
	v_cmpx_ne_u32_e32 0, v6                                    // 00000000E9A0: 7D9A0C80
	s_cbranch_execz 65082                                      // 00000000E9A4: BFA5FE3A <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x990>
	v_clz_i32_u32_e32 v6, v6                                   // 00000000E9A8: 7E0C7306
	v_or_b32_e32 v13, 0x43000000, v13                          // 00000000E9AC: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000E9B4: BF870122
	v_xor_b32_e32 v16, 31, v6                                  // 00000000E9B8: 3A200C9F
	v_lshlrev_b32_e32 v6, 23, v6                               // 00000000E9BC: 300C0C97
	v_sub_nc_u32_e32 v16, 9, v16                               // 00000000E9C0: 4C202089
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000E9C4: BF870112
	v_sub_nc_u32_e32 v6, v13, v6                               // 00000000E9C8: 4C0C0D0D
	v_lshlrev_b32_e32 v15, v16, v15                            // 00000000E9CC: 301E1F10
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000E9D0: BF870091
	v_lshlrev_b32_e32 v15, 14, v15                             // 00000000E9D4: 301E1E8E
	v_and_or_b32 v13, 0x7fc000, v15, v6                        // 00000000E9D8: D657000D 041A1EFF 007FC000
	s_branch 65066                                             // 00000000E9E4: BFA0FE2A <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x990>
	s_or_b32 exec_lo, exec_lo, s27                             // 00000000E9E8: 8C7E1B7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000E9EC: BF870499
	s_or_b32 exec_lo, exec_lo, s25                             // 00000000E9F0: 8C7E197E
	s_and_not1_b32 vcc_lo, exec_lo, s21                        // 00000000E9F4: 916A157E
	s_mov_b32 s1, s20                                          // 00000000E9F8: BE810014
	ds_store_b32 v8, v11                                       // 00000000E9FC: D8340000 00000B08
	s_waitcnt lgkmcnt(0)                                       // 00000000EA04: BF89FC07
	s_barrier                                                  // 00000000EA08: BFBD0000
	buffer_gl0_inv                                             // 00000000EA0C: E0AC0000 00000000
	s_cbranch_vccz 35                                          // 00000000EA14: BFA30023 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x11a4>
	s_and_saveexec_b32 s1, s0                                  // 00000000EA18: BE812000
	s_cbranch_execz 65022                                      // 00000000EA1C: BFA5FDFE <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x918>
	v_mov_b32_e32 v3, s3                                       // 00000000EA20: 7E060203
	s_lshl_b64 s[16:17], s[4:5], 2                             // 00000000EA24: 84908204
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EA28: BF870009
	s_add_u32 s16, s22, s16                                    // 00000000EA2C: 80101016
	s_addc_u32 s17, s23, s17                                   // 00000000EA30: 82111117
	ds_load_b32 v3, v3                                         // 00000000EA34: D8D80000 03000003
	s_waitcnt lgkmcnt(0)                                       // 00000000EA3C: BF89FC07
	global_store_b32 v2, v3, s[16:17]                          // 00000000EA40: DC6A0000 00100302
	s_branch 65011                                             // 00000000EA48: BFA0FDF3 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x918>
	s_nop 0                                                    // 00000000EA4C: BF800000
	s_nop 0                                                    // 00000000EA50: BF800000
	s_nop 0                                                    // 00000000EA54: BF800000
	s_nop 0                                                    // 00000000EA58: BF800000
	s_nop 0                                                    // 00000000EA5C: BF800000
	s_nop 0                                                    // 00000000EA60: BF800000
	s_nop 0                                                    // 00000000EA64: BF800000
	s_nop 0                                                    // 00000000EA68: BF800000
	s_nop 0                                                    // 00000000EA6C: BF800000
	s_nop 0                                                    // 00000000EA70: BF800000
	s_nop 0                                                    // 00000000EA74: BF800000
	s_nop 0                                                    // 00000000EA78: BF800000
	s_nop 0                                                    // 00000000EA7C: BF800000
	s_or_b32 exec_lo, exec_lo, s15                             // 00000000EA80: 8C7E0F7E
	s_lshr_b32 s15, s1, 1                                      // 00000000EA84: 850F8101
	s_cmp_lt_u32 s1, 2                                         // 00000000EA88: BF0A8201
	s_mov_b32 s1, s15                                          // 00000000EA8C: BE81000F
	s_waitcnt lgkmcnt(0)                                       // 00000000EA90: BF89FC07
	s_barrier                                                  // 00000000EA94: BFBD0000
	buffer_gl0_inv                                             // 00000000EA98: E0AC0000 00000000
	s_cbranch_scc1 65501                                       // 00000000EAA0: BFA2FFDD <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1118>
	s_mov_b32 s15, exec_lo                                     // 00000000EAA4: BE8F007E
	v_cmpx_gt_u32_e64 s1, v0                                   // 00000000EAA8: D4CC007E 00020001
	s_cbranch_execz 65523                                      // 00000000EAB0: BFA5FFF3 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1180>
	v_lshl_add_u32 v3, s1, 2, v8                               // 00000000EAB4: D6460003 04210401
	ds_load_b32 v3, v3                                         // 00000000EABC: D8D80000 03000003
	ds_load_b32 v4, v8                                         // 00000000EAC4: D8D80000 04000008
	s_waitcnt lgkmcnt(0)                                       // 00000000EACC: BF89FC07
	v_add_f32_e32 v3, v3, v4                                   // 00000000EAD0: 06060903
	ds_store_b32 v8, v3                                        // 00000000EAD4: D8340000 00000308
	s_branch 65512                                             // 00000000EADC: BFA0FFE8 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x1180>
	s_endpgm                                                   // 00000000EAE0: BFB00000
	s_branch 64548                                             // 00000000EAE4: BFA0FC24 <_ZN12_GLOBAL__N_124graph_lds_chunked_kernelEPKjS1_PKiPfllllllli+0x278>
		...

000000000000eb00 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii>:
	s_clause 0x4                                               // 00000000EB00: BF850004
	s_load_b128 s[20:23], s[0:1], 0x48                         // 00000000EB04: F4080500 F8000048
	s_load_b256 s[4:11], s[0:1], 0x28                          // 00000000EB0C: F40C0100 F8000028
	s_load_b64 s[24:25], s[0:1], 0x58                          // 00000000EB14: F4040600 F8000058
	s_load_b256 s[12:19], s[0:1], null                         // 00000000EB1C: F40C0300 F8000000
	s_load_b64 s[28:29], s[0:1], 0x20                          // 00000000EB24: F4040700 F8000020
	v_cmp_eq_u32_e64 s2, 0, v0                                 // 00000000EB2C: D44A0002 00020080
	s_mov_b32 s26, 0                                           // 00000000EB34: BE9A0080
	v_dual_mov_b32 v19, 4 :: v_dual_lshlrev_b32 v4, 2, v0      // 00000000EB38: CA220084 13040082
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000EB40: BF870001
	v_add_nc_u32_e32 v16, 4, v4                                // 00000000EB44: 4A200884
	s_waitcnt lgkmcnt(0)                                       // 00000000EB48: BF89FC07
	v_cvt_f32_u32_e32 v3, s20                                  // 00000000EB4C: 7E060C14
	v_cvt_f32_u32_e32 v5, s8                                   // 00000000EB50: 7E0A0C08
	s_cmp_gt_i32 s24, 0                                        // 00000000EB54: BF028018
	s_cselect_b32 s33, -1, 0                                   // 00000000EB58: 982180C1
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000EB5C: BF870092
	v_rcp_iflag_f32_e32 v3, v3                                 // 00000000EB60: 7E065703
	v_rcp_iflag_f32_e32 v6, v5                                 // 00000000EB64: 7E0C5705
	v_mov_b32_e32 v2, 0                                        // 00000000EB68: 7E040280
	s_cmp_eq_u32 s25, 0                                        // 00000000EB6C: BF068019
	s_cselect_b32 s25, -1, 0                                   // 00000000EB70: 981980C1
	s_add_u32 s30, s0, 0x60                                    // 00000000EB74: 801EFF00 00000060
	s_addc_u32 s31, s1, 0                                      // 00000000EB7C: 821F8001
	s_lshl_b64 s[34:35], s[20:21], 2                           // 00000000EB80: 84A28214
	s_ashr_i32 s36, s21, 31                                    // 00000000EB84: 86249F15
	s_waitcnt_depctr 0xfff                                     // 00000000EB88: BF880FFF
	v_mul_f32_e32 v3, 0x4f7ffffe, v3                           // 00000000EB8C: 100606FF 4F7FFFFE
	v_dual_mov_b32 v1, v2 :: v_dual_mul_f32 v6, 0x4f7ffffe, v6 // 00000000EB94: CA060102 01060CFF 4F7FFFFE
	v_mov_b32_e32 v5, v2                                       // 00000000EBA0: 7E0A0302
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_3)// 00000000EBA4: BF870193
	v_cvt_u32_f32_e32 v17, v3                                  // 00000000EBA8: 7E220F03
	v_cmp_gt_i64_e64 s3, s[10:11], v[0:1]                      // 00000000EBAC: D4540003 0002000A
	s_delay_alu instid0(VALU_DEP_4)                            // 00000000EBB4: BF870004
	v_cvt_u32_f32_e32 v18, v6                                  // 00000000EBB8: 7E240F06
	s_branch 4                                                 // 00000000EBBC: BFA00004 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xd0>
	s_mov_b32 s0, 0                                            // 00000000EBC0: BE800080
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EBC4: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s0                         // 00000000EBC8: 916A007E
	s_cbranch_vccz 881                                         // 00000000EBCC: BFA30371 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe94>
	s_and_saveexec_b32 s0, s2                                  // 00000000EBD0: BE802002
	s_cbranch_execz 21                                         // 00000000EBD4: BFA50015 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x12c>
	s_mov_b32 s27, exec_lo                                     // 00000000EBD8: BE9B007E
	s_mov_b32 s1, exec_lo                                      // 00000000EBDC: BE81007E
	v_mbcnt_lo_u32_b32 v3, s27, 0                              // 00000000EBE0: D71F0003 0001001B
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000EBE8: BF870001
	v_cmpx_eq_u32_e32 0, v3                                    // 00000000EBEC: 7D940680
	s_cbranch_execz 6                                          // 00000000EBF0: BFA50006 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x10c>
	s_bcnt1_i32_b32 s27, s27                                   // 00000000EBF4: BE9B181B
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000EBF8: BF870499
	s_mul_i32 s27, s24, s27                                    // 00000000EBFC: 961B1B18
	v_mov_b32_e32 v6, s27                                      // 00000000EC00: 7E0C021B
	global_atomic_add_u32 v6, v2, v6, s[28:29] glc             // 00000000EC04: DCD64000 061C0602
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000EC0C: 8C7E017E
	s_waitcnt vmcnt(0)                                         // 00000000EC10: BF8903F7
	v_readfirstlane_b32 s38, v6                                // 00000000EC14: 7E4C0506
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000EC18: BF870001
	v_mad_u64_u32 v[6:7], null, s24, v3, s[38:39]              // 00000000EC1C: D6FE7C06 009A0618
	ds_store_b32 v2, v6                                        // 00000000EC24: D8340000 00000602
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000EC2C: 8C7E007E
	s_waitcnt lgkmcnt(0)                                       // 00000000EC30: BF89FC07
	s_barrier                                                  // 00000000EC34: BFBD0000
	buffer_gl0_inv                                             // 00000000EC38: E0AC0000 00000000
	ds_load_b32 v3, v2                                         // 00000000EC40: D8D80000 03000002
	s_waitcnt lgkmcnt(0)                                       // 00000000EC48: BF89FC07
	v_readfirstlane_b32 s38, v3                                // 00000000EC4C: 7E4C0503
	s_ashr_i32 s39, s38, 31                                    // 00000000EC50: 86279F26
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EC54: BF870009
	v_cmp_le_i64_e64 s0, s[22:23], s[38:39]                    // 00000000EC58: D4530000 00004C16
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000EC60: 8B6A007E
	s_mov_b32 s0, -1                                           // 00000000EC64: BE8000C1
	s_cbranch_vccnz 65494                                      // 00000000EC68: BFA4FFD6 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xc4>
	s_and_not1_b32 vcc_lo, exec_lo, s33                        // 00000000EC6C: 916A217E
	s_cbranch_vccnz 65491                                      // 00000000EC70: BFA4FFD3 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xc0>
	s_lshl_b64 s[40:41], s[38:39], 2                           // 00000000EC74: 84A88226
	s_mov_b32 s48, 0                                           // 00000000EC78: BEB00080
	s_branch 12                                                // 00000000EC7C: BFA0000C <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x1b0>
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000EC80: 8C7E007E
	s_add_i32 s48, s48, 1                                      // 00000000EC84: 81308130
	s_add_u32 s40, s40, 4                                      // 00000000EC88: 80288428
	s_addc_u32 s41, s41, 0                                     // 00000000EC8C: 82298029
	s_cmp_eq_u32 s48, s24                                      // 00000000EC90: BF061830
	s_waitcnt_vscnt null, 0x0                                  // 00000000EC94: BC7C0000
	s_cselect_b32 s0, -1, 0                                    // 00000000EC98: 980080C1
	s_barrier                                                  // 00000000EC9C: BFBD0000
	buffer_gl0_inv                                             // 00000000ECA0: E0AC0000 00000000
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000ECA8: 8B6A007E
	s_cbranch_vccnz 65476                                      // 00000000ECAC: BFA4FFC4 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xc0>
	s_add_u32 s42, s48, s38                                    // 00000000ECB0: 802A2630
	s_addc_u32 s43, 0, s39                                     // 00000000ECB4: 822B2780
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000ECB8: BF870009
	v_cmp_ge_i64_e64 s0, s[42:43], s[22:23]                    // 00000000ECBC: D4560000 00002C2A
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000ECC4: 8B6A007E
	s_mov_b32 s0, -1                                           // 00000000ECC8: BE8000C1
	s_cbranch_vccnz 65526                                      // 00000000ECCC: BFA4FFF6 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x1a8>
	s_load_b32 s49, s[30:31], 0xc                              // 00000000ECD0: F4000C4F F800000C
	v_mov_b32_e32 v20, 0                                       // 00000000ECD8: 7E280280
	s_and_saveexec_b32 s50, s3                                 // 00000000ECDC: BEB22003
	s_cbranch_execz 746                                        // 00000000ECE0: BFA502EA <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xd8c>
	s_or_b64 s[0:1], s[42:43], s[20:21]                        // 00000000ECE4: 8C80142A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000ECE8: BF870499
	s_mov_b32 s27, s1                                          // 00000000ECEC: BE9B0001
	s_cmp_lg_u64 s[26:27], 0                                   // 00000000ECF0: BF11801A
	s_cbranch_scc0 806                                         // 00000000ECF4: BFA10326 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe90>
	s_add_u32 s0, s20, s36                                     // 00000000ECF8: 80002414
	s_mov_b32 s37, s36                                         // 00000000ECFC: BEA50024
	s_addc_u32 s1, s21, s36                                    // 00000000ED00: 82012415
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000ED04: BF870499
	s_xor_b64 s[0:1], s[0:1], s[36:37]                         // 00000000ED08: 8D802400
	v_cvt_f32_u32_e32 v3, s0                                   // 00000000ED0C: 7E060C00
	v_cvt_f32_u32_e32 v6, s1                                   // 00000000ED10: 7E0C0C01
	s_sub_u32 s45, 0, s0                                       // 00000000ED14: 80AD0080
	s_subb_u32 s46, 0, s1                                      // 00000000ED18: 82AE0180
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000ED1C: BF870091
	v_fmac_f32_e32 v3, 0x4f800000, v6                          // 00000000ED20: 56060CFF 4F800000
	v_rcp_f32_e32 v3, v3                                       // 00000000ED28: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000ED2C: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000ED30: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000ED38: BF870091
	v_mul_f32_e32 v6, 0x2f800000, v3                           // 00000000ED3C: 100C06FF 2F800000
	v_trunc_f32_e32 v6, v6                                     // 00000000ED44: 7E0C4306
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000ED48: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v6                          // 00000000ED4C: 56060CFF CF800000
	v_cvt_u32_f32_e32 v6, v6                                   // 00000000ED54: 7E0C0F06
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000ED58: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000ED5C: BF870112
	v_readfirstlane_b32 s27, v6                                // 00000000ED60: 7E360506
	v_readfirstlane_b32 s44, v3                                // 00000000ED64: 7E580503
	s_mul_i32 s47, s45, s27                                    // 00000000ED68: 962F1B2D
	s_mul_hi_u32 s52, s45, s44                                 // 00000000ED6C: 96B42C2D
	s_mul_i32 s51, s46, s44                                    // 00000000ED70: 96332C2E
	s_add_i32 s47, s52, s47                                    // 00000000ED74: 812F2F34
	s_mul_i32 s53, s45, s44                                    // 00000000ED78: 96352C2D
	s_add_i32 s47, s47, s51                                    // 00000000ED7C: 812F332F
	s_mul_hi_u32 s52, s44, s53                                 // 00000000ED80: 96B4352C
	s_mul_i32 s55, s44, s47                                    // 00000000ED84: 96372F2C
	s_mul_hi_u32 s54, s27, s53                                 // 00000000ED88: 96B6351B
	s_mul_i32 s51, s27, s53                                    // 00000000ED8C: 9633351B
	s_mul_hi_u32 s53, s44, s47                                 // 00000000ED90: 96B52F2C
	s_add_u32 s52, s52, s55                                    // 00000000ED94: 80343734
	s_addc_u32 s53, 0, s53                                     // 00000000ED98: 82353580
	s_mul_hi_u32 s56, s27, s47                                 // 00000000ED9C: 96B82F1B
	s_add_u32 s51, s52, s51                                    // 00000000EDA0: 80333334
	s_mul_i32 s47, s27, s47                                    // 00000000EDA4: 962F2F1B
	s_addc_u32 s51, s53, s54                                   // 00000000EDA8: 82333635
	s_addc_u32 s52, s56, 0                                     // 00000000EDAC: 82348038
	s_add_u32 s47, s51, s47                                    // 00000000EDB0: 802F2F33
	s_addc_u32 s51, 0, s52                                     // 00000000EDB4: 82333480
	s_add_u32 s44, s44, s47                                    // 00000000EDB8: 802C2F2C
	s_cselect_b32 s47, -1, 0                                   // 00000000EDBC: 982F80C1
	s_mul_hi_u32 s52, s45, s44                                 // 00000000EDC0: 96B42C2D
	s_cmp_lg_u32 s47, 0                                        // 00000000EDC4: BF07802F
	s_mul_i32 s47, s45, s44                                    // 00000000EDC8: 962F2C2D
	s_addc_u32 s27, s27, s51                                   // 00000000EDCC: 821B331B
	s_mul_i32 s46, s46, s44                                    // 00000000EDD0: 962E2C2E
	s_mul_i32 s45, s45, s27                                    // 00000000EDD4: 962D1B2D
	s_mul_hi_u32 s51, s44, s47                                 // 00000000EDD8: 96B32F2C
	s_add_i32 s45, s52, s45                                    // 00000000EDDC: 812D2D34
	s_mul_hi_u32 s52, s27, s47                                 // 00000000EDE0: 96B42F1B
	s_add_i32 s45, s45, s46                                    // 00000000EDE4: 812D2E2D
	s_mul_i32 s46, s27, s47                                    // 00000000EDE8: 962E2F1B
	s_mul_i32 s54, s44, s45                                    // 00000000EDEC: 96362D2C
	s_mul_hi_u32 s53, s44, s45                                 // 00000000EDF0: 96B52D2C
	s_add_u32 s51, s51, s54                                    // 00000000EDF4: 80333633
	s_addc_u32 s53, 0, s53                                     // 00000000EDF8: 82353580
	s_mul_hi_u32 s47, s27, s45                                 // 00000000EDFC: 96AF2D1B
	s_add_u32 s46, s51, s46                                    // 00000000EE00: 802E2E33
	s_mul_i32 s45, s27, s45                                    // 00000000EE04: 962D2D1B
	s_addc_u32 s46, s53, s52                                   // 00000000EE08: 822E3435
	s_addc_u32 s47, s47, 0                                     // 00000000EE0C: 822F802F
	s_add_u32 s45, s46, s45                                    // 00000000EE10: 802D2D2E
	s_addc_u32 s46, 0, s47                                     // 00000000EE14: 822E2F80
	s_add_u32 s51, s44, s45                                    // 00000000EE18: 80332D2C
	s_cselect_b32 s44, -1, 0                                   // 00000000EE1C: 982C80C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000EE20: BF8704B9
	s_cmp_lg_u32 s44, 0                                        // 00000000EE24: BF07802C
	s_addc_u32 s27, s27, s46                                   // 00000000EE28: 821B2E1B
	s_ashr_i32 s44, s43, 31                                    // 00000000EE2C: 862C9F2B
	s_add_u32 s46, s42, s44                                    // 00000000EE30: 802E2C2A
	s_mov_b32 s45, s44                                         // 00000000EE34: BEAD002C
	s_addc_u32 s47, s43, s44                                   // 00000000EE38: 822F2C2B
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000EE3C: BF870499
	s_xor_b64 s[46:47], s[46:47], s[44:45]                     // 00000000EE40: 8DAE2C2E
	s_mul_i32 s53, s46, s27                                    // 00000000EE44: 96351B2E
	s_mul_hi_u32 s54, s46, s51                                 // 00000000EE48: 96B6332E
	s_mul_hi_u32 s52, s46, s27                                 // 00000000EE4C: 96B41B2E
	s_mul_hi_u32 s56, s47, s51                                 // 00000000EE50: 96B8332F
	s_mul_i32 s51, s47, s51                                    // 00000000EE54: 9633332F
	s_add_u32 s53, s54, s53                                    // 00000000EE58: 80353536
	s_addc_u32 s52, 0, s52                                     // 00000000EE5C: 82343480
	s_mul_hi_u32 s55, s47, s27                                 // 00000000EE60: 96B71B2F
	s_add_u32 s51, s53, s51                                    // 00000000EE64: 80333335
	s_mul_i32 s27, s47, s27                                    // 00000000EE68: 961B1B2F
	s_addc_u32 s51, s52, s56                                   // 00000000EE6C: 82333834
	s_addc_u32 s52, s55, 0                                     // 00000000EE70: 82348037
	s_add_u32 s27, s51, s27                                    // 00000000EE74: 801B1B33
	s_addc_u32 s51, 0, s52                                     // 00000000EE78: 82333480
	s_mul_hi_u32 s52, s0, s27                                  // 00000000EE7C: 96B41B00
	s_mul_i32 s53, s0, s51                                     // 00000000EE80: 96353300
	s_mul_i32 s54, s1, s27                                     // 00000000EE84: 96361B01
	s_add_i32 s52, s52, s53                                    // 00000000EE88: 81343534
	s_mul_i32 s53, s0, s27                                     // 00000000EE8C: 96351B00
	s_add_i32 s52, s52, s54                                    // 00000000EE90: 81343634
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000EE94: BF8704B9
	s_sub_i32 s54, s47, s52                                    // 00000000EE98: 81B6342F
	s_sub_u32 s46, s46, s53                                    // 00000000EE9C: 80AE352E
	s_cselect_b32 s53, -1, 0                                   // 00000000EEA0: 983580C1
	s_cmp_lg_u32 s53, 0                                        // 00000000EEA4: BF078035
	s_subb_u32 s54, s54, s1                                    // 00000000EEA8: 82B60136
	s_sub_u32 s55, s46, s0                                     // 00000000EEAC: 80B7002E
	s_cselect_b32 s56, -1, 0                                   // 00000000EEB0: 983880C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000EEB4: BF8704A9
	s_cmp_lg_u32 s56, 0                                        // 00000000EEB8: BF078038
	s_subb_u32 s54, s54, 0                                     // 00000000EEBC: 82B68036
	s_cmp_ge_u32 s54, s1                                       // 00000000EEC0: BF090136
	s_cselect_b32 s56, -1, 0                                   // 00000000EEC4: 983880C1
	s_cmp_ge_u32 s55, s0                                       // 00000000EEC8: BF090037
	s_cselect_b32 s55, -1, 0                                   // 00000000EECC: 983780C1
	s_cmp_eq_u32 s54, s1                                       // 00000000EED0: BF060136
	s_cselect_b32 s54, s55, s56                                // 00000000EED4: 98363837
	s_add_u32 s55, s27, 1                                      // 00000000EED8: 8037811B
	s_addc_u32 s56, s51, 0                                     // 00000000EEDC: 82388033
	s_add_u32 s57, s27, 2                                      // 00000000EEE0: 8039821B
	s_addc_u32 s58, s51, 0                                     // 00000000EEE4: 823A8033
	s_cmp_lg_u32 s54, 0                                        // 00000000EEE8: BF078036
	s_cselect_b32 s54, s57, s55                                // 00000000EEEC: 98363739
	s_cselect_b32 s55, s58, s56                                // 00000000EEF0: 9837383A
	s_cmp_lg_u32 s53, 0                                        // 00000000EEF4: BF078035
	s_subb_u32 s47, s47, s52                                   // 00000000EEF8: 82AF342F
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EEFC: BF870009
	s_cmp_ge_u32 s47, s1                                       // 00000000EF00: BF09012F
	s_cselect_b32 s52, -1, 0                                   // 00000000EF04: 983480C1
	s_cmp_ge_u32 s46, s0                                       // 00000000EF08: BF09002E
	s_cselect_b32 s0, -1, 0                                    // 00000000EF0C: 980080C1
	s_cmp_eq_u32 s47, s1                                       // 00000000EF10: BF06012F
	s_cselect_b32 s0, s0, s52                                  // 00000000EF14: 98003400
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 00000000EF18: BF8704C9
	s_cmp_lg_u32 s0, 0                                         // 00000000EF1C: BF078000
	s_cselect_b32 s1, s55, s51                                 // 00000000EF20: 98013337
	s_cselect_b32 s0, s54, s27                                 // 00000000EF24: 98001B36
	s_xor_b64 s[44:45], s[44:45], s[36:37]                     // 00000000EF28: 8DAC242C
	s_xor_b64 s[0:1], s[0:1], s[44:45]                         // 00000000EF2C: 8D802C00
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EF30: BF870009
	s_sub_u32 s0, s0, s44                                      // 00000000EF34: 80802C00
	s_subb_u32 s1, s1, s45                                     // 00000000EF38: 82812D01
	s_cbranch_execnz 20                                        // 00000000EF3C: BFA60014 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x490>
	v_readfirstlane_b32 s0, v17                                // 00000000EF40: 7E000511
	s_sub_i32 s1, 0, s20                                       // 00000000EF44: 81811480
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000EF48: BF870499
	s_mul_i32 s1, s1, s0                                       // 00000000EF4C: 96010001
	s_mul_hi_u32 s1, s0, s1                                    // 00000000EF50: 96810100
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000EF54: BF870499
	s_add_i32 s0, s0, s1                                       // 00000000EF58: 81000100
	s_mul_hi_u32 s0, s42, s0                                   // 00000000EF5C: 9680002A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 00000000EF60: BF8704B9
	s_mul_i32 s1, s0, s20                                      // 00000000EF64: 96011400
	s_add_i32 s27, s0, 1                                       // 00000000EF68: 811B8100
	s_sub_i32 s1, s42, s1                                      // 00000000EF6C: 8181012A
	s_sub_i32 s37, s1, s20                                     // 00000000EF70: 81A51401
	s_cmp_ge_u32 s1, s20                                       // 00000000EF74: BF091401
	s_cselect_b32 s0, s27, s0                                  // 00000000EF78: 9800001B
	s_cselect_b32 s1, s37, s1                                  // 00000000EF7C: 98010125
	s_add_i32 s27, s0, 1                                       // 00000000EF80: 811B8100
	s_cmp_ge_u32 s1, s20                                       // 00000000EF84: BF091401
	s_mov_b32 s1, s26                                          // 00000000EF88: BE81001A
	s_cselect_b32 s0, s27, s0                                  // 00000000EF8C: 9800001B
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000EF90: BF870009
	s_mul_i32 s27, s0, s7                                      // 00000000EF94: 961B0700
	s_mul_hi_u32 s37, s0, s6                                   // 00000000EF98: 96A50600
	s_mul_i32 s44, s0, s6                                      // 00000000EF9C: 962C0600
	s_add_i32 s27, s37, s27                                    // 00000000EFA0: 811B1B25
	s_mul_i32 s37, s1, s6                                      // 00000000EFA4: 96250601
	s_mul_i32 s46, s34, s1                                     // 00000000EFA8: 962E0122
	s_add_i32 s45, s27, s37                                    // 00000000EFAC: 812D251B
	v_dual_mov_b32 v20, 0 :: v_dual_mov_b32 v7, v5             // 00000000EFB0: CA100080 14060105
	s_lshl_b64 s[44:45], s[44:45], 2                           // 00000000EFB8: 84AC822C
	v_dual_mov_b32 v6, v4 :: v_dual_mov_b32 v9, v1             // 00000000EFBC: CA100104 06080101
	s_add_u32 s1, s16, s44                                     // 00000000EFC4: 80012C10
	s_mul_hi_u32 s44, s34, s0                                  // 00000000EFC8: 96AC0022
	s_addc_u32 s27, s17, s45                                   // 00000000EFCC: 821B2D11
	s_waitcnt lgkmcnt(0)                                       // 00000000EFD0: BF89FC07
	s_and_b32 s37, s49, 0xffff                                 // 00000000EFD4: 8B25FF31 0000FFFF
	s_add_i32 s44, s44, s46                                    // 00000000EFDC: 812C2E2C
	s_mul_i32 s45, s35, s0                                     // 00000000EFE0: 962D0023
	s_mul_i32 s0, s34, s0                                      // 00000000EFE4: 96000022
	v_mov_b32_e32 v8, v0                                       // 00000000EFE8: 7E100300
	s_lshl_b32 s51, s37, 2                                     // 00000000EFEC: 84338225
	s_add_i32 s44, s44, s45                                    // 00000000EFF0: 812C2D2C
	s_sub_u32 s52, s40, s0                                     // 00000000EFF4: 80B40028
	s_subb_u32 s54, s41, s44                                   // 00000000EFF8: 82B62C29
	s_mov_b32 s53, 0                                           // 00000000EFFC: BEB50080
	s_branch 23                                                // 00000000F000: BFA00017 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x560>
	s_or_b32 exec_lo, exec_lo, s45                             // 00000000F004: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F008: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000000F00C: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F010: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F014: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000F018: BF8700A1
	v_mul_f32_e32 v10, v13, v12                                // 00000000F01C: 1014190D
	v_add_co_u32 v8, vcc_lo, v8, s37                           // 00000000F020: D7006A08 00004B08
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000F028: D5207C09 01AA1280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000000F030: BF8701A3
	v_fmac_f32_e32 v10, v3, v11                                // 00000000F034: 56141703
	v_add_co_u32 v6, s0, v6, s51                               // 00000000F038: D7000006 00006706
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[8:9]                  // 00000000F040: 7CA6100A
	v_add_co_ci_u32_e64 v7, null, 0, v7, s0                    // 00000000F044: D5207C07 00020E80
	s_delay_alu instid0(VALU_DEP_4) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000000F04C: BF8704A4
	v_add_f32_e32 v20, v20, v10                                // 00000000F050: 06281514
	s_or_b32 s53, vcc_lo, s53                                  // 00000000F054: 8C35356A
	s_and_not1_b32 exec_lo, exec_lo, s53                       // 00000000F058: 917E357E
	s_cbranch_execz 522                                        // 00000000F05C: BFA5020A <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xd88>
	v_or_b32_e32 v3, s9, v9                                    // 00000000F060: 38061209
	s_mov_b32 s0, exec_lo                                      // 00000000F064: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F068: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000F06C: 7DBA0480
	s_xor_b32 s55, exec_lo, s0                                 // 00000000F070: 8D37007E
	s_cbranch_execz 177                                        // 00000000F074: BFA500B1 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x83c>
	s_ashr_i32 s44, s9, 31                                     // 00000000F078: 862C9F09
	v_ashrrev_i32_e32 v21, 31, v9                              // 00000000F07C: 342A129F
	s_add_u32 s46, s8, s44                                     // 00000000F080: 802E2C08
	s_mov_b32 s45, s44                                         // 00000000F084: BEAD002C
	s_addc_u32 s47, s9, s44                                    // 00000000F088: 822F2C09
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F08C: BF870009
	s_xor_b64 s[46:47], s[46:47], s[44:45]                     // 00000000F090: 8DAE2C2E
	v_add_co_u32 v11, vcc_lo, v8, v21                          // 00000000F094: D7006A0B 00022B08
	v_cvt_f32_u32_e32 v3, s46                                  // 00000000F09C: 7E060C2E
	v_cvt_f32_u32_e32 v10, s47                                 // 00000000F0A0: 7E140C2F
	s_sub_u32 s56, 0, s46                                      // 00000000F0A4: 80B82E80
	s_subb_u32 s57, 0, s47                                     // 00000000F0A8: 82B92F80
	v_add_co_ci_u32_e64 v12, null, v9, v21, vcc_lo             // 00000000F0AC: D5207C0C 01AA2B09
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F0B4: BF870112
	v_fmac_f32_e32 v3, 0x4f800000, v10                         // 00000000F0B8: 560614FF 4F800000
	v_xor_b32_e32 v22, v12, v21                                // 00000000F0C0: 3A2C2B0C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 00000000F0C4: BF8700B2
	v_rcp_f32_e32 v3, v3                                       // 00000000F0C8: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000F0CC: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000F0D0: 100606FF 5F7FFFFC
	v_mul_f32_e32 v10, 0x2f800000, v3                          // 00000000F0D8: 101406FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F0E0: BF870091
	v_trunc_f32_e32 v10, v10                                   // 00000000F0E4: 7E14430A
	v_fmac_f32_e32 v3, 0xcf800000, v10                         // 00000000F0E8: 560614FF CF800000
	v_cvt_u32_f32_e32 v10, v10                                 // 00000000F0F0: 7E140F0A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F0F4: BF870112
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000F0F8: 7E060F03
	v_readfirstlane_b32 s0, v10                                // 00000000F0FC: 7E00050A
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000F100: BF870002
	v_readfirstlane_b32 s45, v3                                // 00000000F104: 7E5A0503
	s_mul_i32 s58, s56, s0                                     // 00000000F108: 963A0038
	v_xor_b32_e32 v3, v11, v21                                 // 00000000F10C: 3A062B0B
	s_mul_hi_u32 s60, s56, s45                                 // 00000000F110: 96BC2D38
	s_mul_i32 s59, s57, s45                                    // 00000000F114: 963B2D39
	s_add_i32 s58, s60, s58                                    // 00000000F118: 813A3A3C
	s_mul_i32 s61, s56, s45                                    // 00000000F11C: 963D2D38
	s_add_i32 s58, s58, s59                                    // 00000000F120: 813A3B3A
	s_mul_hi_u32 s60, s45, s61                                 // 00000000F124: 96BC3D2D
	s_mul_i32 s63, s45, s58                                    // 00000000F128: 963F3A2D
	s_mul_hi_u32 s62, s0, s61                                  // 00000000F12C: 96BE3D00
	s_mul_i32 s59, s0, s61                                     // 00000000F130: 963B3D00
	s_mul_hi_u32 s61, s45, s58                                 // 00000000F134: 96BD3A2D
	s_add_u32 s60, s60, s63                                    // 00000000F138: 803C3F3C
	s_addc_u32 s61, 0, s61                                     // 00000000F13C: 823D3D80
	s_mul_hi_u32 s64, s0, s58                                  // 00000000F140: 96C03A00
	s_add_u32 s59, s60, s59                                    // 00000000F144: 803B3B3C
	s_mul_i32 s58, s0, s58                                     // 00000000F148: 963A3A00
	s_addc_u32 s59, s61, s62                                   // 00000000F14C: 823B3E3D
	s_addc_u32 s60, s64, 0                                     // 00000000F150: 823C8040
	s_add_u32 s58, s59, s58                                    // 00000000F154: 803A3A3B
	s_addc_u32 s59, 0, s60                                     // 00000000F158: 823B3C80
	s_add_u32 s45, s45, s58                                    // 00000000F15C: 802D3A2D
	s_cselect_b32 s58, -1, 0                                   // 00000000F160: 983A80C1
	s_mul_hi_u32 s60, s56, s45                                 // 00000000F164: 96BC2D38
	s_cmp_lg_u32 s58, 0                                        // 00000000F168: BF07803A
	s_mul_i32 s58, s56, s45                                    // 00000000F16C: 963A2D38
	s_addc_u32 s0, s0, s59                                     // 00000000F170: 82003B00
	s_mul_i32 s57, s57, s45                                    // 00000000F174: 96392D39
	s_mul_i32 s56, s56, s0                                     // 00000000F178: 96380038
	s_mul_hi_u32 s59, s45, s58                                 // 00000000F17C: 96BB3A2D
	s_add_i32 s56, s60, s56                                    // 00000000F180: 8138383C
	s_mul_hi_u32 s60, s0, s58                                  // 00000000F184: 96BC3A00
	s_add_i32 s56, s56, s57                                    // 00000000F188: 81383938
	s_mul_i32 s57, s0, s58                                     // 00000000F18C: 96393A00
	s_mul_i32 s62, s45, s56                                    // 00000000F190: 963E382D
	s_mul_hi_u32 s61, s45, s56                                 // 00000000F194: 96BD382D
	s_add_u32 s59, s59, s62                                    // 00000000F198: 803B3E3B
	s_addc_u32 s61, 0, s61                                     // 00000000F19C: 823D3D80
	s_mul_hi_u32 s58, s0, s56                                  // 00000000F1A0: 96BA3800
	s_add_u32 s57, s59, s57                                    // 00000000F1A4: 8039393B
	s_mul_i32 s56, s0, s56                                     // 00000000F1A8: 96383800
	s_addc_u32 s57, s61, s60                                   // 00000000F1AC: 82393C3D
	s_addc_u32 s58, s58, 0                                     // 00000000F1B0: 823A803A
	s_add_u32 s56, s57, s56                                    // 00000000F1B4: 80383839
	s_addc_u32 s57, 0, s58                                     // 00000000F1B8: 82393A80
	s_add_u32 s45, s45, s56                                    // 00000000F1BC: 802D382D
	s_cselect_b32 s56, -1, 0                                   // 00000000F1C0: 983880C1
	v_mul_hi_u32 v23, v3, s45                                  // 00000000F1C4: D72D0017 00005B03
	s_cmp_lg_u32 s56, 0                                        // 00000000F1CC: BF078038
	v_mad_u64_u32 v[12:13], null, v22, s45, 0                  // 00000000F1D0: D6FE7C0C 02005B16
	s_addc_u32 s0, s0, s57                                     // 00000000F1D8: 82003900
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F1DC: BF870129
	v_mad_u64_u32 v[10:11], null, v3, s0, 0                    // 00000000F1E0: D6FE7C0A 02000103
	v_mad_u64_u32 v[14:15], null, v22, s0, 0                   // 00000000F1E8: D6FE7C0E 02000116
	v_add_co_u32 v10, vcc_lo, v23, v10                         // 00000000F1F0: D7006A0A 00021517
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F1F8: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo              // 00000000F1FC: D5207C0B 01AA1680
	v_add_co_u32 v10, vcc_lo, v10, v12                         // 00000000F204: D7006A0A 0002190A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F20C: BF870122
	v_add_co_ci_u32_e32 v10, vcc_lo, v11, v13, vcc_lo          // 00000000F210: 40141B0B
	v_add_co_ci_u32_e32 v11, vcc_lo, 0, v15, vcc_lo            // 00000000F214: 40161E80
	v_add_co_u32 v12, vcc_lo, v10, v14                         // 00000000F218: D7006A0C 00021D0A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F220: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v11, vcc_lo              // 00000000F224: D5207C0D 01AA1680
	v_mul_lo_u32 v14, s47, v12                                 // 00000000F22C: D72C000E 0002182F
	v_mad_u64_u32 v[10:11], null, s46, v12, 0                  // 00000000F234: D6FE7C0A 0202182E
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F23C: BF870113
	v_mul_lo_u32 v15, s46, v13                                 // 00000000F240: D72C000F 00021A2E
	v_sub_co_u32 v3, vcc_lo, v3, v10                           // 00000000F248: D7016A03 00021503
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F250: BF870092
	v_add3_u32 v11, v11, v15, v14                              // 00000000F254: D655000B 043A1F0B
	v_sub_nc_u32_e32 v14, v22, v11                             // 00000000F25C: 4C1C1716
	v_sub_co_ci_u32_e64 v11, null, v22, v11, vcc_lo            // 00000000F260: D5217C0B 01AA1716
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000F268: BF8700A2
	v_subrev_co_ci_u32_e64 v10, null, s47, v14, vcc_lo         // 00000000F26C: D5227C0A 01AA1C2F
	v_add_co_u32 v14, s0, v12, 2                               // 00000000F274: D700000E 0001050C
	v_add_co_ci_u32_e64 v15, null, 0, v13, s0                  // 00000000F27C: D5207C0F 00021A80
	v_sub_co_u32 v23, s0, v3, s46                              // 00000000F284: D7010017 00005D03
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F28C: BF870111
	v_subrev_co_ci_u32_e64 v10, null, 0, v10, s0               // 00000000F290: D5227C0A 00021480
	v_cmp_le_u32_e32 vcc_lo, s46, v23                          // 00000000F298: 7C962E2E
	v_cndmask_b32_e64 v22, 0, -1, vcc_lo                       // 00000000F29C: D5010016 01A98280
	s_delay_alu instid0(VALU_DEP_3)                            // 00000000F2A4: BF870003
	v_cmp_le_u32_e32 vcc_lo, s47, v10                          // 00000000F2A8: 7C96142F
	v_cndmask_b32_e64 v23, 0, -1, vcc_lo                       // 00000000F2AC: D5010017 01A98280
	v_cmp_le_u32_e32 vcc_lo, s46, v3                           // 00000000F2B4: 7C96062E
	v_cndmask_b32_e64 v3, 0, -1, vcc_lo                        // 00000000F2B8: D5010003 01A98280
	v_cmp_le_u32_e32 vcc_lo, s47, v11                          // 00000000F2C0: 7C96162F
	v_cndmask_b32_e64 v24, 0, -1, vcc_lo                       // 00000000F2C4: D5010018 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s47, v10                          // 00000000F2CC: 7C94142F
	v_cndmask_b32_e32 v10, v23, v22, vcc_lo                    // 00000000F2D0: 02142D17
	v_add_co_u32 v22, vcc_lo, v12, 1                           // 00000000F2D4: D7006A16 0001030C
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000F2DC: BF870151
	v_add_co_ci_u32_e64 v23, null, 0, v13, vcc_lo              // 00000000F2E0: D5207C17 01AA1A80
	v_cmp_eq_u32_e32 vcc_lo, s47, v11                          // 00000000F2E8: 7C94162F
	v_xor_b32_e32 v11, s44, v21                                // 00000000F2EC: 3A162A2C
	v_cndmask_b32_e32 v3, v24, v3, vcc_lo                      // 00000000F2F0: 02060718
	v_cmp_ne_u32_e32 vcc_lo, 0, v10                            // 00000000F2F4: 7C9A1480
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 00000000F2F8: D44D0000 00020680
	v_dual_cndmask_b32 v3, v22, v14 :: v_dual_cndmask_b32 v10, v23, v15// 00000000F300: CA521D16 030A1F17
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F308: BF870111
	v_cndmask_b32_e64 v3, v12, v3, s0                          // 00000000F30C: D5010003 0002070C
	v_cndmask_b32_e64 v10, v13, v10, s0                        // 00000000F314: D501000A 0002150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F31C: BF870112
	v_xor_b32_e32 v3, v3, v11                                  // 00000000F320: 3A061703
	v_xor_b32_e32 v10, v10, v11                                // 00000000F324: 3A14170A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F328: BF870092
	v_sub_co_u32 v12, vcc_lo, v3, v11                          // 00000000F32C: D7016A0C 00021703
	v_sub_co_ci_u32_e64 v13, null, v10, v11, vcc_lo            // 00000000F334: D5217C0D 01AA170A
	s_and_not1_saveexec_b32 s0, s55                            // 00000000F33C: BE803037
	s_cbranch_execz 26                                         // 00000000F340: BFA5001A <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x8ac>
	s_sub_i32 s44, 0, s8                                       // 00000000F344: 81AC0880
	v_mov_b32_e32 v13, v2                                      // 00000000F348: 7E1A0302
	v_mul_lo_u32 v3, s44, v18                                  // 00000000F34C: D72C0003 0002242C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F354: BF870091
	v_mul_hi_u32 v3, v18, v3                                   // 00000000F358: D72D0003 00020712
	v_add_nc_u32_e32 v3, v18, v3                               // 00000000F360: 4A060712
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F364: BF870091
	v_mul_hi_u32 v3, v8, v3                                    // 00000000F368: D72D0003 00020708
	v_mul_lo_u32 v10, v3, s8                                   // 00000000F370: D72C000A 00001103
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F378: BF870091
	v_sub_nc_u32_e32 v10, v8, v10                              // 00000000F37C: 4C141508
	v_subrev_nc_u32_e32 v12, s8, v10                           // 00000000F380: 4E181408
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 00000000F384: 7C961408
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F388: BF870092
	v_dual_cndmask_b32 v10, v10, v12 :: v_dual_add_nc_u32 v11, 1, v3// 00000000F38C: CA60190A 0A0A0681
	v_cndmask_b32_e32 v3, v3, v11, vcc_lo                      // 00000000F394: 02061703
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F398: BF870112
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 00000000F39C: 7C961408
	v_add_nc_u32_e32 v11, 1, v3                                // 00000000F3A0: 4A160681
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F3A4: BF870001
	v_cndmask_b32_e32 v12, v3, v11, vcc_lo                     // 00000000F3A8: 02181703
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F3AC: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F3B0: BF870091
	v_lshlrev_b64 v[10:11], 2, v[12:13]                        // 00000000F3B4: D73C000A 00021882
	v_add_co_u32 v14, vcc_lo, s1, v10                          // 00000000F3BC: D7006A0E 00021401
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000F3C4: BF8700C1
	v_add_co_ci_u32_e64 v15, null, s27, v11, vcc_lo            // 00000000F3C8: D5207C0F 01AA161B
	global_load_b32 v14, v[14:15], off                         // 00000000F3D0: DC520000 0E7C000E
	s_waitcnt vmcnt(0)                                         // 00000000F3D8: BF8903F7
	v_ashrrev_i32_e32 v15, 31, v14                             // 00000000F3DC: 341E1C9F
	v_cmp_gt_i64_e32 vcc_lo, 0, v[14:15]                       // 00000000F3E0: 7CA81C80
	v_cmp_le_i64_e64 s0, s[4:5], v[14:15]                      // 00000000F3E4: D4530000 00021C04
	s_or_b32 s0, vcc_lo, s0                                    // 00000000F3EC: 8C00006A
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000F3F0: BF870499
	s_and_saveexec_b32 s44, s0                                 // 00000000F3F4: BEAC2000
	s_xor_b32 s0, exec_lo, s44                                 // 00000000F3F8: 8D002C7E
	v_lshlrev_b64 v[10:11], 2, v[12:13]                        // 00000000F3FC: D73C000A 00021882
	s_or_saveexec_b32 s0, s0                                   // 00000000F404: BE802200
	v_mov_b32_e32 v12, 0                                       // 00000000F408: 7E180280
	s_xor_b32 exec_lo, exec_lo, s0                             // 00000000F40C: 8D7E007E
	s_cbranch_execz 24                                         // 00000000F410: BFA50018 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x974>
	v_lshlrev_b64 v[12:13], 2, v[14:15]                        // 00000000F414: D73C000C 00021C82
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F41C: BF870091
	v_sub_co_u32 v3, vcc_lo, v12, v10                          // 00000000F420: D7016A03 0002150C
	v_sub_co_ci_u32_e64 v12, null, v13, v11, vcc_lo            // 00000000F428: D5217C0C 01AA170D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F430: BF870112
	v_mul_lo_u32 v15, s9, v3                                   // 00000000F434: D72C000F 00020609
	v_mul_lo_u32 v14, s8, v12                                  // 00000000F43C: D72C000E 00021808
	v_mad_u64_u32 v[12:13], null, s8, v3, v[6:7]               // 00000000F444: D6FE7C0C 041A0608
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F44C: BF870111
	v_add3_u32 v3, v15, v13, v14                               // 00000000F450: D6550003 043A1B0F
	v_add_co_u32 v12, vcc_lo, s12, v12                         // 00000000F458: D7006A0C 0002180C
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F460: BF870001
	v_add_co_ci_u32_e64 v13, null, s13, v3, vcc_lo             // 00000000F464: D5207C0D 01AA060D
	global_load_b32 v12, v[12:13], off                         // 00000000F46C: DC520000 0C7C000C
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F474: 8C7E007E
	v_sub_co_u32 v3, vcc_lo, s52, v10                          // 00000000F478: D7016A03 00021434
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F480: BF870111
	v_sub_co_ci_u32_e64 v10, null, s54, v11, vcc_lo            // 00000000F484: D5217C0A 01AA1636
	v_mul_lo_u32 v14, s9, v3                                   // 00000000F48C: D72C000E 00020609
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000F494: BF8700A2
	v_mul_lo_u32 v13, s8, v10                                  // 00000000F498: D72C000D 00021408
	v_mad_u64_u32 v[10:11], null, s8, v3, v[6:7]               // 00000000F4A0: D6FE7C0A 041A0608
	v_add3_u32 v3, v14, v11, v13                               // 00000000F4A8: D6550003 0436170E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F4B0: BF870092
	v_add_co_u32 v10, vcc_lo, s14, v10                         // 00000000F4B4: D7006A0A 0002140E
	v_add_co_ci_u32_e64 v11, null, s15, v3, vcc_lo             // 00000000F4BC: D5207C0B 01AA060F
	s_waitcnt vmcnt(0)                                         // 00000000F4C4: BF8903F7
	v_lshlrev_b32_e32 v3, 16, v12                              // 00000000F4C8: 30061890
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F4CC: 916A197E
	global_load_b32 v10, v[10:11], off                         // 00000000F4D0: DC520000 0A7C000A
	s_cbranch_vccz 13                                          // 00000000F4D8: BFA3000D <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xa10>
	s_waitcnt vmcnt(0)                                         // 00000000F4DC: BF8903F7
	v_lshlrev_b32_e32 v11, 16, v10                             // 00000000F4E0: 30161490
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F4E4: 916A197E
	s_cbranch_vccz 68                                          // 00000000F4E8: BFA30044 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xafc>
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F4EC: 916A197E
	s_cbranch_vccz 123                                         // 00000000F4F0: BFA3007B <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xbe0>
	v_and_b32_e32 v13, 0xffff0000, v12                         // 00000000F4F4: 361A18FF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F4FC: 916A197E
	s_cbranch_vccz 175                                         // 00000000F500: BFA300AF <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xcc0>
	v_and_b32_e32 v12, 0xffff0000, v10                         // 00000000F504: 361814FF FFFF0000
	s_branch 65218                                             // 00000000F50C: BFA0FEC2 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x518>
	v_bfe_u32 v11, v12, 10, 5                                  // 00000000F510: D610000B 0215150C
	v_and_b32_e32 v3, 0x80000000, v3                           // 00000000F518: 360606FF 80000000
	s_mov_b32 s0, exec_lo                                      // 00000000F520: BE80007E
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000F524: BF870002
	v_cmpx_lt_i32_e32 30, v11                                  // 00000000F528: 7D82169E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000F52C: 8D00007E
	v_lshlrev_b32_e32 v11, 13, v12                             // 00000000F530: 3016188D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F534: BF870091
	v_and_b32_e32 v11, 0x7fe000, v11                           // 00000000F538: 361616FF 007FE000
	v_or3_b32 v3, v11, v3, 0x7f800000                          // 00000000F540: D6580003 03FE070B 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000F54C: BE803000
	s_cbranch_execz 36                                         // 00000000F550: BFA50024 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xae4>
	v_and_b32_e32 v13, 0x3ff, v12                              // 00000000F554: 361A18FF 000003FF
	s_mov_b32 s44, exec_lo                                     // 00000000F55C: BEAC007E
	v_cmpx_ne_u32_e32 0, v11                                   // 00000000F560: 7D9A1680
	s_xor_b32 s44, exec_lo, s44                                // 00000000F564: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F568: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 00000000F56C: 301A1A8D
	v_lshl_or_b32 v11, v11, 23, v13                            // 00000000F570: D656000B 04352F0B
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F578: BF870001
	v_add3_u32 v3, v11, v3, 0x38000000                         // 00000000F57C: D6550003 03FE070B 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 00000000F588: BEAC302C
	s_cbranch_execz 19                                         // 00000000F58C: BFA50013 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xadc>
	s_mov_b32 s45, exec_lo                                     // 00000000F590: BEAD007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000000F594: 7D9A1A80
	s_cbranch_execz 15                                         // 00000000F598: BFA5000F <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xad8>
	v_clz_i32_u32_e32 v11, v13                                 // 00000000F59C: 7E16730D
	v_or_b32_e32 v3, 0x43000000, v3                            // 00000000F5A0: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F5A8: BF870122
	v_xor_b32_e32 v13, 31, v11                                 // 00000000F5AC: 3A1A169F
	v_lshlrev_b32_e32 v11, 23, v11                             // 00000000F5B0: 30161697
	v_sub_nc_u32_e32 v13, 9, v13                               // 00000000F5B4: 4C1A1A89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F5B8: BF870112
	v_sub_nc_u32_e32 v3, v3, v11                               // 00000000F5BC: 4C061703
	v_lshlrev_b32_e32 v13, v13, v12                            // 00000000F5C0: 301A190D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F5C4: BF870091
	v_lshlrev_b32_e32 v13, 14, v13                             // 00000000F5C8: 301A1A8E
	v_and_or_b32 v3, 0x7fc000, v13, v3                         // 00000000F5CC: D6570003 040E1AFF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 00000000F5D8: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F5DC: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000000F5E0: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F5E4: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F5E8: 8C7E007E
	s_waitcnt vmcnt(0)                                         // 00000000F5EC: BF8903F7
	v_lshlrev_b32_e32 v11, 16, v10                             // 00000000F5F0: 30161490
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F5F4: 916A197E
	s_cbranch_vccnz 65468                                      // 00000000F5F8: BFA4FFBC <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x9ec>
	v_bfe_u32 v13, v10, 10, 5                                  // 00000000F5FC: D610000D 0215150A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F604: BF870122
	v_and_b32_e32 v11, 0x80000000, v11                         // 00000000F608: 361616FF 80000000
	s_mov_b32 s0, exec_lo                                      // 00000000F610: BE80007E
	v_cmpx_lt_i32_e32 30, v13                                  // 00000000F614: 7D821A9E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000F618: 8D00007E
	v_lshlrev_b32_e32 v13, 13, v10                             // 00000000F61C: 301A148D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F620: BF870091
	v_and_b32_e32 v13, 0x7fe000, v13                           // 00000000F624: 361A1AFF 007FE000
	v_or3_b32 v11, v13, v11, 0x7f800000                        // 00000000F62C: D658000B 03FE170D 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000F638: BE803000
	s_cbranch_execz 36                                         // 00000000F63C: BFA50024 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xbd0>
	v_and_b32_e32 v14, 0x3ff, v10                              // 00000000F640: 361C14FF 000003FF
	s_mov_b32 s44, exec_lo                                     // 00000000F648: BEAC007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000000F64C: 7D9A1A80
	s_xor_b32 s44, exec_lo, s44                                // 00000000F650: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F654: BF870092
	v_lshlrev_b32_e32 v14, 13, v14                             // 00000000F658: 301C1C8D
	v_lshl_or_b32 v13, v13, 23, v14                            // 00000000F65C: D656000D 04392F0D
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F664: BF870001
	v_add3_u32 v11, v13, v11, 0x38000000                       // 00000000F668: D655000B 03FE170D 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 00000000F674: BEAC302C
	s_cbranch_execz 19                                         // 00000000F678: BFA50013 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xbc8>
	s_mov_b32 s45, exec_lo                                     // 00000000F67C: BEAD007E
	v_cmpx_ne_u32_e32 0, v14                                   // 00000000F680: 7D9A1C80
	s_cbranch_execz 15                                         // 00000000F684: BFA5000F <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xbc4>
	v_clz_i32_u32_e32 v13, v14                                 // 00000000F688: 7E1A730E
	v_or_b32_e32 v11, 0x43000000, v11                          // 00000000F68C: 381616FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F694: BF870122
	v_xor_b32_e32 v14, 31, v13                                 // 00000000F698: 3A1C1A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 00000000F69C: 301A1A97
	v_sub_nc_u32_e32 v14, 9, v14                               // 00000000F6A0: 4C1C1C89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F6A4: BF870112
	v_sub_nc_u32_e32 v11, v11, v13                             // 00000000F6A8: 4C161B0B
	v_lshlrev_b32_e32 v14, v14, v10                            // 00000000F6AC: 301C150E
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F6B0: BF870091
	v_lshlrev_b32_e32 v14, 14, v14                             // 00000000F6B4: 301C1C8E
	v_and_or_b32 v11, 0x7fc000, v14, v11                       // 00000000F6B8: D657000B 042E1CFF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 00000000F6C4: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F6C8: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000000F6CC: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000F6D0: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F6D4: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F6D8: 916A197E
	s_cbranch_vccnz 65413                                      // 00000000F6DC: BFA4FF85 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x9f4>
	v_bfe_u32 v15, v12, 26, 5                                  // 00000000F6E0: D610000F 0215350C
	v_and_b32_e32 v13, 0x80000000, v12                         // 00000000F6E8: 361A18FF 80000000
	v_mov_b16_e32 v14.h, 0                                     // 00000000F6F0: 7F1C3880
	v_mov_b16_e32 v14.l, v12.h                                 // 00000000F6F4: 7E1C398C
	s_mov_b32 s0, exec_lo                                      // 00000000F6F8: BE80007E
	v_cmpx_lt_i32_e32 30, v15                                  // 00000000F6FC: 7D821E9E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000F700: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F704: BF870092
	v_lshlrev_b32_e32 v12, 13, v14                             // 00000000F708: 30181C8D
	v_or3_b32 v13, v12, v13, 0x7f800000                        // 00000000F70C: D658000D 03FE1B0C 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000F718: BE803000
	s_cbranch_execz 36                                         // 00000000F71C: BFA50024 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xcb0>
	v_bfe_u32 v12, v12, 16, 10                                 // 00000000F720: D610000C 0229210C
	s_mov_b32 s44, exec_lo                                     // 00000000F728: BEAC007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000F72C: 7D9A1E80
	s_xor_b32 s44, exec_lo, s44                                // 00000000F730: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F734: BF870092
	v_lshlrev_b32_e32 v12, 13, v12                             // 00000000F738: 3018188D
	v_lshl_or_b32 v12, v15, 23, v12                            // 00000000F73C: D656000C 04312F0F
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F744: BF870001
	v_add3_u32 v13, v12, v13, 0x38000000                       // 00000000F748: D655000D 03FE1B0C 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 00000000F754: BEAC302C
	s_cbranch_execz 19                                         // 00000000F758: BFA50013 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xca8>
	s_mov_b32 s45, exec_lo                                     // 00000000F75C: BEAD007E
	v_cmpx_ne_u32_e32 0, v12                                   // 00000000F760: 7D9A1880
	s_cbranch_execz 15                                         // 00000000F764: BFA5000F <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xca4>
	v_clz_i32_u32_e32 v12, v12                                 // 00000000F768: 7E18730C
	v_or_b32_e32 v13, 0x43000000, v13                          // 00000000F76C: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F774: BF870122
	v_xor_b32_e32 v15, 31, v12                                 // 00000000F778: 3A1E189F
	v_lshlrev_b32_e32 v12, 23, v12                             // 00000000F77C: 30181897
	v_sub_nc_u32_e32 v15, 9, v15                               // 00000000F780: 4C1E1E89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F784: BF870112
	v_sub_nc_u32_e32 v12, v13, v12                             // 00000000F788: 4C18190D
	v_lshlrev_b32_e32 v14, v15, v14                            // 00000000F78C: 301C1D0F
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F790: BF870091
	v_lshlrev_b32_e32 v14, 14, v14                             // 00000000F794: 301C1C8E
	v_and_or_b32 v13, 0x7fc000, v14, v12                       // 00000000F798: D657000D 04321CFF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 00000000F7A4: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F7A8: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000000F7AC: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000F7B0: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000F7B4: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000000F7B8: 916A197E
	s_cbranch_vccnz 65361                                      // 00000000F7BC: BFA4FF51 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xa04>
	v_bfe_u32 v15, v10, 26, 5                                  // 00000000F7C0: D610000F 0215350A
	v_and_b32_e32 v12, 0x80000000, v10                         // 00000000F7C8: 361814FF 80000000
	v_mov_b16_e32 v14.h, 0                                     // 00000000F7D0: 7F1C3880
	v_mov_b16_e32 v14.l, v10.h                                 // 00000000F7D4: 7E1C398A
	s_mov_b32 s0, exec_lo                                      // 00000000F7D8: BE80007E
	v_cmpx_lt_i32_e32 30, v15                                  // 00000000F7DC: 7D821E9E
	s_xor_b32 s0, exec_lo, s0                                  // 00000000F7E0: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F7E4: BF870092
	v_lshlrev_b32_e32 v10, 13, v14                             // 00000000F7E8: 30141C8D
	v_or3_b32 v12, v10, v12, 0x7f800000                        // 00000000F7EC: D658000C 03FE190A 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000000F7F8: BE803000
	s_cbranch_execz 65028                                      // 00000000F7FC: BFA5FE04 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x510>
	v_bfe_u32 v10, v10, 16, 10                                 // 00000000F800: D610000A 0229210A
	s_mov_b32 s44, exec_lo                                     // 00000000F808: BEAC007E
	v_cmpx_ne_u32_e32 0, v15                                   // 00000000F80C: 7D9A1E80
	s_xor_b32 s44, exec_lo, s44                                // 00000000F810: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F814: BF870092
	v_lshlrev_b32_e32 v10, 13, v10                             // 00000000F818: 3014148D
	v_lshl_or_b32 v10, v15, 23, v10                            // 00000000F81C: D656000A 04292F0F
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000F824: BF870001
	v_add3_u32 v12, v10, v12, 0x38000000                       // 00000000F828: D655000C 03FE190A 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 00000000F834: BEAC302C
	s_cbranch_execz 65011                                      // 00000000F838: BFA5FDF3 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x508>
	s_mov_b32 s45, exec_lo                                     // 00000000F83C: BEAD007E
	v_cmpx_ne_u32_e32 0, v10                                   // 00000000F840: 7D9A1480
	s_cbranch_execz 65007                                      // 00000000F844: BFA5FDEF <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x504>
	v_clz_i32_u32_e32 v10, v10                                 // 00000000F848: 7E14730A
	v_or_b32_e32 v12, 0x43000000, v12                          // 00000000F84C: 381818FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000F854: BF870122
	v_xor_b32_e32 v15, 31, v10                                 // 00000000F858: 3A1E149F
	v_lshlrev_b32_e32 v10, 23, v10                             // 00000000F85C: 30141497
	v_sub_nc_u32_e32 v15, 9, v15                               // 00000000F860: 4C1E1E89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000F864: BF870112
	v_sub_nc_u32_e32 v10, v12, v10                             // 00000000F868: 4C14150C
	v_lshlrev_b32_e32 v14, v15, v14                            // 00000000F86C: 301C1D0F
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000F870: BF870091
	v_lshlrev_b32_e32 v14, 14, v14                             // 00000000F874: 301C1C8E
	v_and_or_b32 v12, 0x7fc000, v14, v10                       // 00000000F878: D657000C 042A1CFF 007FC000
	s_branch 64991                                             // 00000000F884: BFA0FDDF <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x504>
	s_or_b32 exec_lo, exec_lo, s53                             // 00000000F888: 8C7E357E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F88C: BF870009
	s_or_b32 exec_lo, exec_lo, s50                             // 00000000F890: 8C7E327E
	s_waitcnt lgkmcnt(0)                                       // 00000000F894: BF89FC07
	s_and_b32 s0, 0xffff, s49                                  // 00000000F898: 8B0031FF 0000FFFF
	ds_store_b32 v16, v20                                      // 00000000F8A0: D8340000 00001410
	s_cmp_lt_u32 s0, 2                                         // 00000000F8A8: BF0A8200
	s_waitcnt lgkmcnt(0)                                       // 00000000F8AC: BF89FC07
	s_barrier                                                  // 00000000F8B0: BFBD0000
	buffer_gl0_inv                                             // 00000000F8B4: E0AC0000 00000000
	s_cbranch_scc1 40                                          // 00000000F8BC: BFA20028 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe60>
	s_lshr_b32 s0, s0, 1                                       // 00000000F8C0: 85008100
	s_branch 23                                                // 00000000F8C4: BFA00017 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe24>
	s_nop 0                                                    // 00000000F8C8: BF800000
	s_nop 0                                                    // 00000000F8CC: BF800000
	s_nop 0                                                    // 00000000F8D0: BF800000
	s_nop 0                                                    // 00000000F8D4: BF800000
	s_nop 0                                                    // 00000000F8D8: BF800000
	s_nop 0                                                    // 00000000F8DC: BF800000
	s_nop 0                                                    // 00000000F8E0: BF800000
	s_nop 0                                                    // 00000000F8E4: BF800000
	s_nop 0                                                    // 00000000F8E8: BF800000
	s_nop 0                                                    // 00000000F8EC: BF800000
	s_nop 0                                                    // 00000000F8F0: BF800000
	s_nop 0                                                    // 00000000F8F4: BF800000
	s_nop 0                                                    // 00000000F8F8: BF800000
	s_nop 0                                                    // 00000000F8FC: BF800000
	s_or_b32 exec_lo, exec_lo, s1                              // 00000000F900: 8C7E017E
	s_lshr_b32 s1, s0, 1                                       // 00000000F904: 85018100
	s_cmp_lt_u32 s0, 2                                         // 00000000F908: BF0A8200
	s_mov_b32 s0, s1                                           // 00000000F90C: BE800001
	s_waitcnt lgkmcnt(0)                                       // 00000000F910: BF89FC07
	s_barrier                                                  // 00000000F914: BFBD0000
	buffer_gl0_inv                                             // 00000000F918: E0AC0000 00000000
	s_cbranch_scc1 15                                          // 00000000F920: BFA2000F <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe60>
	s_mov_b32 s1, exec_lo                                      // 00000000F924: BE81007E
	v_cmpx_gt_u32_e64 s0, v0                                   // 00000000F928: D4CC007E 00020000
	s_cbranch_execz 65523                                      // 00000000F930: BFA5FFF3 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe00>
	v_lshl_add_u32 v3, s0, 2, v16                              // 00000000F934: D6460003 04410400
	ds_load_b32 v3, v3                                         // 00000000F93C: D8D80000 03000003
	ds_load_b32 v6, v16                                        // 00000000F944: D8D80000 06000010
	s_waitcnt lgkmcnt(0)                                       // 00000000F94C: BF89FC07
	v_add_f32_e32 v3, v3, v6                                   // 00000000F950: 06060D03
	ds_store_b32 v16, v3                                       // 00000000F954: D8340000 00000310
	s_branch 65512                                             // 00000000F95C: BFA0FFE8 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0xe00>
	s_and_saveexec_b32 s0, s2                                  // 00000000F960: BE802002
	s_cbranch_execz 64710                                      // 00000000F964: BFA5FCC6 <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x180>
	ds_load_b32 v3, v19                                        // 00000000F968: D8D80000 03000013
	s_lshl_b64 s[42:43], s[42:43], 2                           // 00000000F970: 84AA822A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000F974: BF870009
	s_add_u32 s42, s18, s42                                    // 00000000F978: 802A2A12
	s_addc_u32 s43, s19, s43                                   // 00000000F97C: 822B2B13
	s_waitcnt lgkmcnt(0)                                       // 00000000F980: BF89FC07
	global_store_b32 v2, v3, s[42:43]                          // 00000000F984: DC6A0000 002A0302
	s_branch 64700                                             // 00000000F98C: BFA0FCBC <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x180>
	s_branch 64875                                             // 00000000F990: BFA0FD6B <_ZN12_GLOBAL__N_130graph_persistent_global_kernelEPKjS1_PKiPfPillllllii+0x440>
	s_endpgm                                                   // 00000000F994: BFB00000
		...

000000000000fa00 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii>:
	s_clause 0x4                                               // 00000000FA00: BF850004
	s_load_b256 s[4:11], s[0:1], 0x28                          // 00000000FA04: F40C0100 F8000028
	s_load_b256 s[12:19], s[0:1], null                         // 00000000FA0C: F40C0300 F8000000
	s_load_b64 s[24:25], s[0:1], 0x58                          // 00000000FA14: F4040600 F8000058
	s_load_b128 s[20:23], s[0:1], 0x48                         // 00000000FA1C: F4080500 F8000048
	s_load_b64 s[26:27], s[0:1], 0x20                          // 00000000FA24: F4040680 F8000020
	v_dual_mov_b32 v2, 0 :: v_dual_lshlrev_b32 v3, 2, v0       // 00000000FA2C: CA220080 02020082
	v_cmp_eq_u32_e64 s2, 0, v0                                 // 00000000FA34: D44A0002 00020080
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_3) | instid1(VALU_DEP_2)// 00000000FA3C: BF870142
	v_dual_mov_b32 v1, v2 :: v_dual_add_nc_u32 v14, 4, v3      // 00000000FA40: CA200102 010E0684
	s_waitcnt lgkmcnt(0)                                       // 00000000FA48: BF89FC07
	v_cvt_f32_u32_e32 v4, s8                                   // 00000000FA4C: 7E080C08
	s_lshl_b32 s28, s10, 2                                     // 00000000FA50: 841C820A
	v_cmp_gt_i64_e64 s3, s[10:11], v[0:1]                      // 00000000FA54: D4540003 0002000A
	s_add_i32 s33, s28, 4                                      // 00000000FA5C: 8121841C
	s_cmp_gt_i32 s24, 0                                        // 00000000FA60: BF028018
	v_rcp_iflag_f32_e32 v6, v4                                 // 00000000FA64: 7E0C5704
	v_add_co_u32 v4, s12, s12, v3                              // 00000000FA68: D7000C04 0002060C
	v_add_nc_u32_e32 v15, s33, v3                              // 00000000FA70: 4A1E0621
	v_add_co_ci_u32_e64 v5, null, s13, 0, s12                  // 00000000FA74: D5207C05 0031000D
	s_cselect_b32 s38, -1, 0                                   // 00000000FA7C: 982680C1
	s_add_u32 s12, s0, 0x60                                    // 00000000FA80: 800CFF00 00000060
	s_addc_u32 s13, s1, 0                                      // 00000000FA88: 820D8001
	v_cmp_gt_i64_e64 s1, s[20:21], 0                           // 00000000FA8C: D4540001 00010014
	s_waitcnt_depctr 0xfff                                     // 00000000FA94: BF880FFF
	v_mul_f32_e32 v3, 0x4f7ffffe, v6                           // 00000000FA98: 10060CFF 4F7FFFFE
	s_cmp_eq_u32 s25, 0                                        // 00000000FAA0: BF068019
	s_cselect_b32 s25, -1, 0                                   // 00000000FAA4: 981980C1
	s_ashr_i32 s28, s9, 31                                     // 00000000FAA8: 861C9F09
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FAAC: BF870001
	v_cvt_u32_f32_e32 v16, v3                                  // 00000000FAB0: 7E200F03
	s_branch 4                                                 // 00000000FAB4: BFA00004 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xc8>
	s_mov_b32 s0, 0                                            // 00000000FAB8: BE800080
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FABC: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s0                         // 00000000FAC0: 916A007E
	s_cbranch_vccz 950                                         // 00000000FAC4: BFA303B6 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xfa0>
	s_and_saveexec_b32 s0, s2                                  // 00000000FAC8: BE802002
	s_cbranch_execz 21                                         // 00000000FACC: BFA50015 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x124>
	s_mov_b32 s30, exec_lo                                     // 00000000FAD0: BE9E007E
	s_mov_b32 s29, exec_lo                                     // 00000000FAD4: BE9D007E
	v_mbcnt_lo_u32_b32 v3, s30, 0                              // 00000000FAD8: D71F0003 0001001E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FAE0: BF870001
	v_cmpx_eq_u32_e32 0, v3                                    // 00000000FAE4: 7D940680
	s_cbranch_execz 6                                          // 00000000FAE8: BFA50006 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x104>
	s_bcnt1_i32_b32 s30, s30                                   // 00000000FAEC: BE9E181E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 00000000FAF0: BF870499
	s_mul_i32 s30, s24, s30                                    // 00000000FAF4: 961E1E18
	v_mov_b32_e32 v6, s30                                      // 00000000FAF8: 7E0C021E
	global_atomic_add_u32 v6, v2, v6, s[26:27] glc             // 00000000FAFC: DCD64000 061A0602
	s_or_b32 exec_lo, exec_lo, s29                             // 00000000FB04: 8C7E1D7E
	s_waitcnt vmcnt(0)                                         // 00000000FB08: BF8903F7
	v_readfirstlane_b32 s30, v6                                // 00000000FB0C: 7E3C0506
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FB10: BF870001
	v_mad_u64_u32 v[6:7], null, s24, v3, s[30:31]              // 00000000FB14: D6FE7C06 007A0618
	ds_store_b32 v2, v6                                        // 00000000FB1C: D8340000 00000602
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000FB24: 8C7E007E
	s_waitcnt lgkmcnt(0)                                       // 00000000FB28: BF89FC07
	s_barrier                                                  // 00000000FB2C: BFBD0000
	buffer_gl0_inv                                             // 00000000FB30: E0AC0000 00000000
	ds_load_b32 v3, v2                                         // 00000000FB38: D8D80000 03000002
	s_waitcnt lgkmcnt(0)                                       // 00000000FB40: BF89FC07
	v_readfirstlane_b32 s30, v3                                // 00000000FB44: 7E3C0503
	s_ashr_i32 s31, s30, 31                                    // 00000000FB48: 861F9F1E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FB4C: BF870009
	v_cmp_le_i64_e64 s0, s[22:23], s[30:31]                    // 00000000FB50: D4530000 00003C16
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000FB58: 8B6A007E
	s_mov_b32 s0, -1                                           // 00000000FB5C: BE8000C1
	s_cbranch_vccnz 65494                                      // 00000000FB60: BFA4FFD6 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xbc>
	s_and_not1_b32 vcc_lo, exec_lo, s38                        // 00000000FB64: 916A267E
	s_cbranch_vccnz 65491                                      // 00000000FB68: BFA4FFD3 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb8>
	s_mov_b32 s39, 0                                           // 00000000FB6C: BEA70080
	s_branch 7                                                 // 00000000FB70: BFA00007 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x190>
	s_add_i32 s39, s39, 1                                      // 00000000FB74: 81278127
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FB78: BF870009
	s_cmp_eq_u32 s39, s24                                      // 00000000FB7C: BF061827
	s_cselect_b32 s0, -1, 0                                    // 00000000FB80: 980080C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FB84: BF870009
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000FB88: 8B6A007E
	s_cbranch_vccnz 65482                                      // 00000000FB8C: BFA4FFCA <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb8>
	s_add_u32 s34, s39, s30                                    // 00000000FB90: 80221E27
	s_addc_u32 s35, 0, s31                                     // 00000000FB94: 82231F80
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FB98: BF870009
	v_cmp_ge_i64_e64 s0, s[34:35], s[22:23]                    // 00000000FB9C: D4560000 00002C22
	s_and_b32 vcc_lo, exec_lo, s0                              // 00000000FBA4: 8B6A007E
	s_mov_b32 s0, -1                                           // 00000000FBA8: BE8000C1
	s_cbranch_vccnz 65525                                      // 00000000FBAC: BFA4FFF5 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x184>
	s_and_saveexec_b32 s40, s3                                 // 00000000FBB0: BEA82003
	s_cbranch_execz 292                                        // 00000000FBB4: BFA50124 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x648>
	s_load_b32 s0, s[12:13], 0xc                               // 00000000FBB8: F4000006 F800000C
	s_mul_i32 s29, s34, s7                                     // 00000000FBC0: 961D0722
	s_mul_hi_u32 s37, s34, s6                                  // 00000000FBC4: 96A50622
	s_mul_i32 s41, s35, s6                                     // 00000000FBC8: 96290623
	s_add_i32 s29, s37, s29                                    // 00000000FBCC: 811D1D25
	s_mul_i32 s36, s34, s6                                     // 00000000FBD0: 96240622
	s_add_i32 s37, s29, s41                                    // 00000000FBD4: 8125291D
	v_mov_b32_e32 v7, v5                                       // 00000000FBD8: 7E0E0305
	s_lshl_b64 s[36:37], s[36:37], 2                           // 00000000FBDC: 84A48224
	v_mov_b32_e32 v9, v1                                       // 00000000FBE0: 7E120301
	v_dual_mov_b32 v17, v14 :: v_dual_mov_b32 v6, v4           // 00000000FBE4: CA10010E 11060104
	v_mov_b32_e32 v8, v0                                       // 00000000FBEC: 7E100300
	s_add_u32 s41, s16, s36                                    // 00000000FBF0: 80292410
	s_addc_u32 s42, s17, s37                                   // 00000000FBF4: 822A2511
	s_mov_b32 s45, 0                                           // 00000000FBF8: BEAD0080
	s_waitcnt lgkmcnt(0)                                       // 00000000FBFC: BF89FC07
	s_and_b32 s43, s0, 0xffff                                  // 00000000FC00: 8B2BFF00 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FC08: BF870009
	s_lshl_b32 s44, s43, 2                                     // 00000000FC0C: 842C822B
	s_branch 19                                                // 00000000FC10: BFA00013 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x260>
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000FC14: 8C7E007E
	v_add_co_u32 v8, vcc_lo, v8, s43                           // 00000000FC18: D7006A08 00005708
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FC20: BF870001
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 00000000FC24: D5207C09 01AA1280
	v_add_co_u32 v6, s0, v6, s44                               // 00000000FC2C: D7000006 00005906
	s_waitcnt vmcnt(0)                                         // 00000000FC34: BF8903F7
	ds_store_b32 v17, v3                                       // 00000000FC38: D8340000 00000311
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[8:9]                  // 00000000FC40: 7CA6100A
	v_add_co_ci_u32_e64 v7, null, 0, v7, s0                    // 00000000FC44: D5207C07 00020E80
	v_add_nc_u32_e32 v17, s44, v17                             // 00000000FC4C: 4A22222C
	s_or_b32 s45, vcc_lo, s45                                  // 00000000FC50: 8C2D2D6A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FC54: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s45                       // 00000000FC58: 917E2D7E
	s_cbranch_execz 250                                        // 00000000FC5C: BFA500FA <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x648>
	v_or_b32_e32 v3, s9, v9                                    // 00000000FC60: 38061209
	s_mov_b32 s0, exec_lo                                      // 00000000FC64: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FC68: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000000FC6C: 7DBA0480
	s_xor_b32 s46, exec_lo, s0                                 // 00000000FC70: 8D2E007E
	s_cbranch_execz 175                                        // 00000000FC74: BFA500AF <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x534>
	s_add_u32 s36, s8, s28                                     // 00000000FC78: 80241C08
	s_mov_b32 s29, s28                                         // 00000000FC7C: BE9D001C
	s_addc_u32 s37, s9, s28                                    // 00000000FC80: 82251C09
	v_ashrrev_i32_e32 v20, 31, v9                              // 00000000FC84: 3428129F
	s_xor_b64 s[36:37], s[36:37], s[28:29]                     // 00000000FC88: 8DA41C24
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 00000000FC8C: BF870159
	v_cvt_f32_u32_e32 v3, s36                                  // 00000000FC90: 7E060C24
	v_cvt_f32_u32_e32 v10, s37                                 // 00000000FC94: 7E140C25
	s_sub_u32 s0, 0, s36                                       // 00000000FC98: 80802480
	s_subb_u32 s48, 0, s37                                     // 00000000FC9C: 82B02580
	v_add_co_u32 v11, vcc_lo, v8, v20                          // 00000000FCA0: D7006A0B 00022908
	v_fmac_f32_e32 v3, 0x4f800000, v10                         // 00000000FCA8: 560614FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FCB0: BF870112
	v_xor_b32_e32 v21, v11, v20                                // 00000000FCB4: 3A2A290B
	v_rcp_f32_e32 v3, v3                                       // 00000000FCB8: 7E065503
	s_waitcnt_depctr 0xfff                                     // 00000000FCBC: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 00000000FCC0: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000FCC8: BF870091
	v_mul_f32_e32 v10, 0x2f800000, v3                          // 00000000FCCC: 101406FF 2F800000
	v_trunc_f32_e32 v10, v10                                   // 00000000FCD4: 7E14430A
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000FCD8: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v10                         // 00000000FCDC: 560614FF CF800000
	v_cvt_u32_f32_e32 v10, v10                                 // 00000000FCE4: 7E140F0A
	v_cvt_u32_f32_e32 v3, v3                                   // 00000000FCE8: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FCEC: BF870112
	v_readfirstlane_b32 s29, v10                               // 00000000FCF0: 7E3A050A
	v_readfirstlane_b32 s47, v3                                // 00000000FCF4: 7E5E0503
	s_mul_i32 s49, s0, s29                                     // 00000000FCF8: 96311D00
	v_add_co_ci_u32_e64 v3, null, v9, v20, vcc_lo              // 00000000FCFC: D5207C03 01AA2909
	s_mul_hi_u32 s51, s0, s47                                  // 00000000FD04: 96B32F00
	s_mul_i32 s50, s48, s47                                    // 00000000FD08: 96322F30
	s_add_i32 s49, s51, s49                                    // 00000000FD0C: 81313133
	s_mul_i32 s52, s0, s47                                     // 00000000FD10: 96342F00
	s_add_i32 s49, s49, s50                                    // 00000000FD14: 81313231
	s_mul_hi_u32 s51, s47, s52                                 // 00000000FD18: 96B3342F
	s_mul_i32 s54, s47, s49                                    // 00000000FD1C: 9636312F
	s_mul_hi_u32 s53, s29, s52                                 // 00000000FD20: 96B5341D
	s_mul_i32 s50, s29, s52                                    // 00000000FD24: 9632341D
	s_mul_hi_u32 s52, s47, s49                                 // 00000000FD28: 96B4312F
	s_add_u32 s51, s51, s54                                    // 00000000FD2C: 80333633
	s_addc_u32 s52, 0, s52                                     // 00000000FD30: 82343480
	s_mul_hi_u32 s55, s29, s49                                 // 00000000FD34: 96B7311D
	s_add_u32 s50, s51, s50                                    // 00000000FD38: 80323233
	s_mul_i32 s49, s29, s49                                    // 00000000FD3C: 9631311D
	s_addc_u32 s50, s52, s53                                   // 00000000FD40: 82323534
	s_addc_u32 s51, s55, 0                                     // 00000000FD44: 82338037
	s_add_u32 s49, s50, s49                                    // 00000000FD48: 80313132
	s_addc_u32 s50, 0, s51                                     // 00000000FD4C: 82323380
	s_add_u32 s47, s47, s49                                    // 00000000FD50: 802F312F
	s_cselect_b32 s49, -1, 0                                   // 00000000FD54: 983180C1
	s_mul_hi_u32 s51, s0, s47                                  // 00000000FD58: 96B32F00
	s_cmp_lg_u32 s49, 0                                        // 00000000FD5C: BF078031
	s_mul_i32 s49, s0, s47                                     // 00000000FD60: 96312F00
	s_addc_u32 s29, s29, s50                                   // 00000000FD64: 821D321D
	s_mul_i32 s48, s48, s47                                    // 00000000FD68: 96302F30
	s_mul_i32 s0, s0, s29                                      // 00000000FD6C: 96001D00
	s_mul_hi_u32 s50, s47, s49                                 // 00000000FD70: 96B2312F
	s_add_i32 s0, s51, s0                                      // 00000000FD74: 81000033
	s_mul_hi_u32 s51, s29, s49                                 // 00000000FD78: 96B3311D
	s_add_i32 s0, s0, s48                                      // 00000000FD7C: 81003000
	s_mul_i32 s48, s29, s49                                    // 00000000FD80: 9630311D
	s_mul_i32 s53, s47, s0                                     // 00000000FD84: 9635002F
	s_mul_hi_u32 s52, s47, s0                                  // 00000000FD88: 96B4002F
	s_add_u32 s50, s50, s53                                    // 00000000FD8C: 80323532
	s_addc_u32 s52, 0, s52                                     // 00000000FD90: 82343480
	s_mul_hi_u32 s49, s29, s0                                  // 00000000FD94: 96B1001D
	s_add_u32 s48, s50, s48                                    // 00000000FD98: 80303032
	s_mul_i32 s0, s29, s0                                      // 00000000FD9C: 9600001D
	s_addc_u32 s48, s52, s51                                   // 00000000FDA0: 82303334
	s_addc_u32 s49, s49, 0                                     // 00000000FDA4: 82318031
	s_add_u32 s0, s48, s0                                      // 00000000FDA8: 80000030
	s_addc_u32 s48, 0, s49                                     // 00000000FDAC: 82303180
	s_add_u32 s0, s47, s0                                      // 00000000FDB0: 8000002F
	s_cselect_b32 s47, -1, 0                                   // 00000000FDB4: 982F80C1
	v_xor_b32_e32 v3, v3, v20                                  // 00000000FDB8: 3A062903
	s_cmp_lg_u32 s47, 0                                        // 00000000FDBC: BF07802F
	v_mul_hi_u32 v22, v21, s0                                  // 00000000FDC0: D72D0016 00000115
	s_addc_u32 s29, s29, s48                                   // 00000000FDC8: 821D301D
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000FDCC: BF8701B9
	v_mad_u64_u32 v[10:11], null, v21, s29, 0                  // 00000000FDD0: D6FE7C0A 02003B15
	v_mad_u64_u32 v[12:13], null, v3, s0, 0                    // 00000000FDD8: D6FE7C0C 02000103
	v_mad_u64_u32 v[18:19], null, v3, s29, 0                   // 00000000FDE0: D6FE7C12 02003B03
	v_add_co_u32 v10, vcc_lo, v22, v10                         // 00000000FDE8: D7006A0A 00021516
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FDF0: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo              // 00000000FDF4: D5207C0B 01AA1680
	v_add_co_u32 v10, vcc_lo, v10, v12                         // 00000000FDFC: D7006A0A 0002190A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000FE04: BF870122
	v_add_co_ci_u32_e32 v10, vcc_lo, v11, v13, vcc_lo          // 00000000FE08: 40141B0B
	v_add_co_ci_u32_e32 v11, vcc_lo, 0, v19, vcc_lo            // 00000000FE0C: 40162680
	v_add_co_u32 v12, vcc_lo, v10, v18                         // 00000000FE10: D7006A0C 0002250A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FE18: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v11, vcc_lo              // 00000000FE1C: D5207C0D 01AA1680
	v_mul_lo_u32 v18, s37, v12                                 // 00000000FE24: D72C0012 00021825
	v_mad_u64_u32 v[10:11], null, s36, v12, 0                  // 00000000FE2C: D6FE7C0A 02021824
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FE34: BF870113
	v_mul_lo_u32 v19, s36, v13                                 // 00000000FE38: D72C0013 00021A24
	v_sub_co_u32 v10, vcc_lo, v21, v10                         // 00000000FE40: D7016A0A 00021515
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 00000000FE48: BF8700A2
	v_add3_u32 v11, v11, v19, v18                              // 00000000FE4C: D655000B 044A270B
	v_add_co_u32 v19, s0, v12, 2                               // 00000000FE54: D7000013 0001050C
	v_add_co_ci_u32_e64 v21, null, 0, v13, s0                  // 00000000FE5C: D5207C15 00021A80
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 00000000FE64: BF8701B3
	v_sub_nc_u32_e32 v18, v3, v11                              // 00000000FE68: 4C241703
	v_sub_co_u32 v22, s0, v10, s36                             // 00000000FE6C: D7010016 0000490A
	v_sub_co_ci_u32_e64 v3, null, v3, v11, vcc_lo              // 00000000FE74: D5217C03 01AA1703
	v_subrev_co_ci_u32_e64 v18, null, s37, v18, vcc_lo         // 00000000FE7C: D5227C12 01AA2425
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FE84: BF870113
	v_cmp_le_u32_e32 vcc_lo, s36, v22                          // 00000000FE88: 7C962C24
	v_subrev_co_ci_u32_e64 v18, null, 0, v18, s0               // 00000000FE8C: D5227C12 00022480
	v_cndmask_b32_e64 v11, 0, -1, vcc_lo                       // 00000000FE94: D501000B 01A98280
	s_delay_alu instid0(VALU_DEP_2)                            // 00000000FE9C: BF870002
	v_cmp_le_u32_e32 vcc_lo, s37, v18                          // 00000000FEA0: 7C962425
	v_cndmask_b32_e64 v22, 0, -1, vcc_lo                       // 00000000FEA4: D5010016 01A98280
	v_cmp_le_u32_e32 vcc_lo, s36, v10                          // 00000000FEAC: 7C961424
	v_cndmask_b32_e64 v10, 0, -1, vcc_lo                       // 00000000FEB0: D501000A 01A98280
	v_cmp_le_u32_e32 vcc_lo, s37, v3                           // 00000000FEB8: 7C960625
	v_cndmask_b32_e64 v23, 0, -1, vcc_lo                       // 00000000FEBC: D5010017 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s37, v18                          // 00000000FEC4: 7C942425
	v_cndmask_b32_e32 v11, v22, v11, vcc_lo                    // 00000000FEC8: 02161716
	v_add_co_u32 v18, vcc_lo, v12, 1                           // 00000000FECC: D7006A12 0001030C
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_3)// 00000000FED4: BF8701D1
	v_add_co_ci_u32_e64 v22, null, 0, v13, vcc_lo              // 00000000FED8: D5207C16 01AA1A80
	v_cmp_eq_u32_e32 vcc_lo, s37, v3                           // 00000000FEE0: 7C940625
	v_cndmask_b32_e32 v3, v23, v10, vcc_lo                     // 00000000FEE4: 02061517
	v_cmp_ne_u32_e32 vcc_lo, 0, v11                            // 00000000FEE8: 7C9A1680
	v_xor_b32_e32 v11, s28, v20                                // 00000000FEEC: 3A16281C
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 00000000FEF0: D44D0000 00020680
	v_cndmask_b32_e32 v3, v18, v19, vcc_lo                     // 00000000FEF8: 02062712
	v_cndmask_b32_e32 v10, v22, v21, vcc_lo                    // 00000000FEFC: 02142B16
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FF00: BF870112
	v_cndmask_b32_e64 v3, v12, v3, s0                          // 00000000FF04: D5010003 0002070C
	v_cndmask_b32_e64 v10, v13, v10, s0                        // 00000000FF0C: D501000A 0002150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FF14: BF870112
	v_xor_b32_e32 v3, v3, v11                                  // 00000000FF18: 3A061703
	v_xor_b32_e32 v12, v10, v11                                // 00000000FF1C: 3A18170A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000FF20: BF870092
	v_sub_co_u32 v10, vcc_lo, v3, v11                          // 00000000FF24: D7016A0A 00021703
	v_sub_co_ci_u32_e64 v11, null, v12, v11, vcc_lo            // 00000000FF2C: D5217C0B 01AA170C
	s_and_not1_saveexec_b32 s0, s46                            // 00000000FF34: BE80302E
	s_cbranch_execz 26                                         // 00000000FF38: BFA5001A <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x5a4>
	s_sub_i32 s29, 0, s8                                       // 00000000FF3C: 819D0880
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000FF40: BF870099
	v_mul_lo_u32 v3, s29, v16                                  // 00000000FF44: D72C0003 0002201D
	v_mul_hi_u32 v3, v16, v3                                   // 00000000FF4C: D72D0003 00020710
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000000FF54: BF870091
	v_add_nc_u32_e32 v3, v16, v3                               // 00000000FF58: 4A060710
	v_mul_hi_u32 v3, v8, v3                                    // 00000000FF5C: D72D0003 00020708
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000FF64: BF870121
	v_mul_lo_u32 v10, v3, s8                                   // 00000000FF68: D72C000A 00001103
	v_add_nc_u32_e32 v11, 1, v3                                // 00000000FF70: 4A160681
	v_sub_nc_u32_e32 v10, v8, v10                              // 00000000FF74: 4C141508
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000FF78: BF870121
	v_subrev_nc_u32_e32 v12, s8, v10                           // 00000000FF7C: 4E181408
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 00000000FF80: 7C961408
	v_dual_cndmask_b32 v10, v10, v12 :: v_dual_cndmask_b32 v3, v3, v11// 00000000FF84: CA52190A 0A021703
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000000FF8C: BF870111
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 00000000FF90: 7C961408
	v_add_nc_u32_e32 v11, 1, v3                                // 00000000FF94: 4A160681
	s_delay_alu instid0(VALU_DEP_1)                            // 00000000FF98: BF870001
	v_dual_cndmask_b32 v10, v3, v11 :: v_dual_mov_b32 v11, v2  // 00000000FF9C: CA501703 0A0A0102
	s_or_b32 exec_lo, exec_lo, s0                              // 00000000FFA4: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000000FFA8: BF870121
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 00000000FFAC: D73C000A 00021482
	v_mov_b32_e32 v3, 0                                        // 00000000FFB4: 7E060280
	v_add_co_u32 v12, vcc_lo, s41, v10                         // 00000000FFB8: D7006A0C 00021429
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 00000000FFC0: BF8700C1
	v_add_co_ci_u32_e64 v13, null, s42, v11, vcc_lo            // 00000000FFC4: D5207C0D 01AA162A
	global_load_b32 v12, v[12:13], off                         // 00000000FFCC: DC520000 0C7C000C
	s_waitcnt vmcnt(0)                                         // 00000000FFD4: BF8903F7
	v_ashrrev_i32_e32 v13, 31, v12                             // 00000000FFD8: 341A189F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[12:13]                      // 00000000FFDC: 7CA218C1
	v_cmp_gt_i64_e64 s0, s[4:5], v[12:13]                      // 00000000FFE0: D4540000 00021804
	s_and_b32 s29, vcc_lo, s0                                  // 00000000FFE8: 8B1D006A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000000FFEC: BF870009
	s_and_saveexec_b32 s0, s29                                 // 00000000FFF0: BE80201D
	s_cbranch_execz 65287                                      // 00000000FFF4: BFA5FF07 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x214>
	v_lshlrev_b64 v[12:13], 2, v[12:13]                        // 00000000FFF8: D73C000C 00021882
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010000: BF870091
	v_sub_co_u32 v3, vcc_lo, v12, v10                          // 000000010004: D7016A03 0002150C
	v_sub_co_ci_u32_e64 v10, null, v13, v11, vcc_lo            // 00000001000C: D5217C0A 01AA170D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010014: BF870112
	v_mul_lo_u32 v13, s9, v3                                   // 000000010018: D72C000D 00020609
	v_mul_lo_u32 v12, s8, v10                                  // 000000010020: D72C000C 00021408
	v_mad_u64_u32 v[10:11], null, s8, v3, v[6:7]               // 000000010028: D6FE7C0A 041A0608
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010030: BF870001
	v_add3_u32 v11, v13, v11, v12                              // 000000010034: D655000B 0432170D
	global_load_b32 v3, v[10:11], off                          // 00000001003C: DC520000 037C000A
	s_branch 65267                                             // 000000010044: BFA0FEF3 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x214>
	s_or_b32 exec_lo, exec_lo, s40                             // 000000010048: 8C7E287E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000001004C: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s1                         // 000000010050: 916A017E
	s_waitcnt lgkmcnt(0)                                       // 000000010054: BF89FC07
	s_barrier                                                  // 000000010058: BFBD0000
	buffer_gl0_inv                                             // 00000001005C: E0AC0000 00000000
	s_cbranch_vccnz 65219                                      // 000000010064: BFA4FEC3 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x174>
	s_load_b32 s0, s[12:13], 0xc                               // 000000010068: F4000006 F800000C
	s_mul_i32 s29, s34, s21                                    // 000000010070: 961D1522
	s_mul_hi_u32 s36, s34, s20                                 // 000000010074: 96A41422
	s_mul_i32 s34, s34, s20                                    // 000000010078: 96221422
	s_waitcnt lgkmcnt(0)                                       // 00000001007C: BF89FC07
	s_and_b32 s40, s0, 0xffff                                  // 000000010080: 8B28FF00 0000FFFF
	s_bfe_u32 s41, s0, 0xf0001                                 // 000000010088: 9329FF00 000F0001
	s_cmp_gt_u32 s40, 1                                        // 000000010090: BF088128
	s_mul_i32 s0, s35, s20                                     // 000000010094: 96001423
	s_cselect_b32 s42, -1, 0                                   // 000000010098: 982A80C1
	s_add_i32 s29, s36, s29                                    // 00000001009C: 811D1D24
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000000100A0: BF870499
	s_add_i32 s35, s29, s0                                     // 0000000100A4: 8123001D
	s_lshl_b64 s[34:35], s[34:35], 2                           // 0000000100A8: 84A28222
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000100AC: BF870009
	s_add_u32 s43, s18, s34                                    // 0000000100B0: 802B2212
	s_addc_u32 s44, s19, s35                                   // 0000000100B4: 822C2313
	s_lshl_b32 s45, s40, 2                                     // 0000000100B8: 842D8228
	s_mov_b64 s[34:35], 0                                      // 0000000100BC: BEA20180
	s_branch 9                                                 // 0000000100C0: BFA00009 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x6e8>
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000100C4: 8C7E007E
	s_add_u32 s34, s34, 1                                      // 0000000100C8: 80228122
	s_addc_u32 s35, s35, 0                                     // 0000000100CC: 82238023
	s_waitcnt_vscnt null, 0x0                                  // 0000000100D0: BC7C0000
	s_cmp_lg_u64 s[34:35], s[20:21]                            // 0000000100D4: BF111422
	s_barrier                                                  // 0000000100D8: BFBD0000
	buffer_gl0_inv                                             // 0000000100DC: E0AC0000 00000000
	s_cbranch_scc0 65187                                       // 0000000100E4: BFA1FEA3 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x174>
	v_mov_b32_e32 v10, 0                                       // 0000000100E8: 7E140280
	s_and_saveexec_b32 s46, s3                                 // 0000000100EC: BEAE2003
	s_cbranch_execz 494                                        // 0000000100F0: BFA501EE <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xeac>
	s_mul_i32 s0, s34, s9                                      // 0000000100F4: 96000922
	s_mul_hi_u32 s29, s34, s8                                  // 0000000100F8: 969D0822
	s_mul_i32 s36, s34, s8                                     // 0000000100FC: 96240822
	s_add_i32 s0, s29, s0                                      // 000000010100: 8100001D
	s_mul_i32 s29, s35, s8                                     // 000000010104: 961D0823
	v_dual_mov_b32 v10, 0 :: v_dual_mov_b32 v11, v14           // 000000010108: CA100080 0A0A010E
	s_add_i32 s37, s0, s29                                     // 000000010110: 81251D00
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 000000010114: CA100101 07060100
	s_lshl_b64 s[36:37], s[36:37], 2                           // 00000001011C: 84A48224
	s_mov_b32 s48, 0                                           // 000000010120: BEB00080
	s_add_u32 s47, s14, s36                                    // 000000010124: 802F240E
	s_addc_u32 s49, s15, s37                                   // 000000010128: 8231250F
	s_branch 20                                                // 00000001012C: BFA00014 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x780>
	s_or_b32 exec_lo, exec_lo, s36                             // 000000010130: 8C7E247E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010134: BF870009
	s_or_b32 exec_lo, exec_lo, s29                             // 000000010138: 8C7E1D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 00000001013C: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 000000010140: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000010144: BF8700A1
	v_dual_mul_f32 v8, v13, v12 :: v_dual_add_nc_u32 v11, s45, v11// 000000010148: C8E0190D 080A162D
	v_add_co_u32 v6, vcc_lo, v6, s40                           // 000000010150: D7006A06 00005106
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 000000010158: D5207C07 01AA0E80
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010160: BF870113
	v_fmac_f32_e32 v8, v3, v9                                  // 000000010164: 56101303
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 000000010168: 7CA60C0A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 00000001016C: BF8704A2
	v_add_f32_e32 v10, v10, v8                                 // 000000010170: 0614110A
	s_or_b32 s48, vcc_lo, s48                                  // 000000010174: 8C30306A
	s_and_not1_b32 exec_lo, exec_lo, s48                       // 000000010178: 917E307E
	s_cbranch_execz 458                                        // 00000001017C: BFA501CA <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xea8>
	v_or_b32_e32 v3, s9, v7                                    // 000000010180: 38060E09
	s_mov_b32 s0, exec_lo                                      // 000000010184: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010188: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 00000001018C: 7DBA0480
	s_xor_b32 s50, exec_lo, s0                                 // 000000010190: 8D32007E
	s_cbranch_execz 176                                        // 000000010194: BFA500B0 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xa58>
	s_add_u32 s36, s8, s28                                     // 000000010198: 80241C08
	s_mov_b32 s29, s28                                         // 00000001019C: BE9D001C
	s_addc_u32 s37, s9, s28                                    // 0000000101A0: 82251C09
	v_ashrrev_i32_e32 v19, 31, v7                              // 0000000101A4: 34260E9F
	s_xor_b64 s[36:37], s[36:37], s[28:29]                     // 0000000101A8: 8DA41C24
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 0000000101AC: BF870159
	v_cvt_f32_u32_e32 v3, s36                                  // 0000000101B0: 7E060C24
	v_cvt_f32_u32_e32 v8, s37                                  // 0000000101B4: 7E100C25
	s_sub_u32 s0, 0, s36                                       // 0000000101B8: 80802480
	s_subb_u32 s52, 0, s37                                     // 0000000101BC: 82B42580
	v_add_co_u32 v9, vcc_lo, v6, v19                           // 0000000101C0: D7006A09 00022706
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 0000000101C8: 560610FF 4F800000
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000101D0: BF870112
	v_xor_b32_e32 v20, v9, v19                                 // 0000000101D4: 3A282709
	v_rcp_f32_e32 v3, v3                                       // 0000000101D8: 7E065503
	s_waitcnt_depctr 0xfff                                     // 0000000101DC: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 0000000101E0: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000101E8: BF870091
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 0000000101EC: 101006FF 2F800000
	v_trunc_f32_e32 v8, v8                                     // 0000000101F4: 7E104308
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000101F8: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 0000000101FC: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 000000010204: 7E100F08
	v_cvt_u32_f32_e32 v3, v3                                   // 000000010208: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000001020C: BF870112
	v_readfirstlane_b32 s29, v8                                // 000000010210: 7E3A0508
	v_readfirstlane_b32 s51, v3                                // 000000010214: 7E660503
	s_mul_i32 s53, s0, s29                                     // 000000010218: 96351D00
	v_add_co_ci_u32_e64 v3, null, v7, v19, vcc_lo              // 00000001021C: D5207C03 01AA2707
	s_mul_hi_u32 s55, s0, s51                                  // 000000010224: 96B73300
	s_mul_i32 s54, s52, s51                                    // 000000010228: 96363334
	s_add_i32 s53, s55, s53                                    // 00000001022C: 81353537
	s_mul_i32 s56, s0, s51                                     // 000000010230: 96383300
	s_add_i32 s53, s53, s54                                    // 000000010234: 81353635
	s_mul_hi_u32 s55, s51, s56                                 // 000000010238: 96B73833
	s_mul_i32 s58, s51, s53                                    // 00000001023C: 963A3533
	s_mul_hi_u32 s57, s29, s56                                 // 000000010240: 96B9381D
	s_mul_i32 s54, s29, s56                                    // 000000010244: 9636381D
	s_mul_hi_u32 s56, s51, s53                                 // 000000010248: 96B83533
	s_add_u32 s55, s55, s58                                    // 00000001024C: 80373A37
	s_addc_u32 s56, 0, s56                                     // 000000010250: 82383880
	s_mul_hi_u32 s59, s29, s53                                 // 000000010254: 96BB351D
	s_add_u32 s54, s55, s54                                    // 000000010258: 80363637
	s_mul_i32 s53, s29, s53                                    // 00000001025C: 9635351D
	s_addc_u32 s54, s56, s57                                   // 000000010260: 82363938
	s_addc_u32 s55, s59, 0                                     // 000000010264: 8237803B
	s_add_u32 s53, s54, s53                                    // 000000010268: 80353536
	s_addc_u32 s54, 0, s55                                     // 00000001026C: 82363780
	s_add_u32 s51, s51, s53                                    // 000000010270: 80333533
	s_cselect_b32 s53, -1, 0                                   // 000000010274: 983580C1
	s_mul_hi_u32 s55, s0, s51                                  // 000000010278: 96B73300
	s_cmp_lg_u32 s53, 0                                        // 00000001027C: BF078035
	s_mul_i32 s53, s0, s51                                     // 000000010280: 96353300
	s_addc_u32 s29, s29, s54                                   // 000000010284: 821D361D
	s_mul_i32 s52, s52, s51                                    // 000000010288: 96343334
	s_mul_i32 s0, s0, s29                                      // 00000001028C: 96001D00
	s_mul_hi_u32 s54, s51, s53                                 // 000000010290: 96B63533
	s_add_i32 s0, s55, s0                                      // 000000010294: 81000037
	s_mul_hi_u32 s55, s29, s53                                 // 000000010298: 96B7351D
	s_add_i32 s0, s0, s52                                      // 00000001029C: 81003400
	s_mul_i32 s52, s29, s53                                    // 0000000102A0: 9634351D
	s_mul_i32 s57, s51, s0                                     // 0000000102A4: 96390033
	s_mul_hi_u32 s56, s51, s0                                  // 0000000102A8: 96B80033
	s_add_u32 s54, s54, s57                                    // 0000000102AC: 80363936
	s_addc_u32 s56, 0, s56                                     // 0000000102B0: 82383880
	s_mul_hi_u32 s53, s29, s0                                  // 0000000102B4: 96B5001D
	s_add_u32 s52, s54, s52                                    // 0000000102B8: 80343436
	s_mul_i32 s0, s29, s0                                      // 0000000102BC: 9600001D
	s_addc_u32 s52, s56, s55                                   // 0000000102C0: 82343738
	s_addc_u32 s53, s53, 0                                     // 0000000102C4: 82358035
	s_add_u32 s0, s52, s0                                      // 0000000102C8: 80000034
	s_addc_u32 s52, 0, s53                                     // 0000000102CC: 82343580
	s_add_u32 s0, s51, s0                                      // 0000000102D0: 80000033
	s_cselect_b32 s51, -1, 0                                   // 0000000102D4: 983380C1
	v_xor_b32_e32 v3, v3, v19                                  // 0000000102D8: 3A062703
	s_cmp_lg_u32 s51, 0                                        // 0000000102DC: BF078033
	v_mul_hi_u32 v21, v20, s0                                  // 0000000102E0: D72D0015 00000114
	s_addc_u32 s29, s29, s52                                   // 0000000102E8: 821D341D
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000000102EC: BF8701B9
	v_mad_u64_u32 v[8:9], null, v20, s29, 0                    // 0000000102F0: D6FE7C08 02003B14
	v_mad_u64_u32 v[12:13], null, v3, s0, 0                    // 0000000102F8: D6FE7C0C 02000103
	v_mad_u64_u32 v[17:18], null, v3, s29, 0                   // 000000010300: D6FE7C11 02003B03
	v_add_co_u32 v8, vcc_lo, v21, v8                           // 000000010308: D7006A08 00021115
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010310: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000010314: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v12                           // 00000001031C: D7006A08 00021908
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010324: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v13, vcc_lo            // 000000010328: 40101B09
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v18, vcc_lo             // 00000001032C: 40122480
	v_add_co_u32 v12, vcc_lo, v8, v17                          // 000000010330: D7006A0C 00022308
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010338: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v9, vcc_lo               // 00000001033C: D5207C0D 01AA1280
	v_mul_lo_u32 v17, s37, v12                                 // 000000010344: D72C0011 00021825
	v_mad_u64_u32 v[8:9], null, s36, v12, 0                    // 00000001034C: D6FE7C08 02021824
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010354: BF870113
	v_mul_lo_u32 v12, s36, v13                                 // 000000010358: D72C000C 00021A24
	v_sub_co_u32 v8, vcc_lo, v20, v8                           // 000000010360: D7016A08 00021114
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010368: BF870112
	v_add3_u32 v9, v9, v12, v17                                // 00000001036C: D6550009 04461909
	v_cmp_le_u32_e64 s0, s36, v8                               // 000000010374: D44B0000 00021024
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000001037C: BF8701A2
	v_sub_nc_u32_e32 v12, v3, v9                               // 000000010380: 4C181303
	v_sub_co_ci_u32_e64 v3, null, v3, v9, vcc_lo               // 000000010384: D5217C03 01AA1303
	v_cndmask_b32_e64 v17, 0, -1, s0                           // 00000001038C: D5010011 00018280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000010394: BF8700A3
	v_subrev_co_ci_u32_e64 v12, null, s37, v12, vcc_lo         // 000000010398: D5227C0C 01AA1825
	v_sub_co_u32 v9, vcc_lo, v8, s36                           // 0000000103A0: D7016A09 00004908
	v_subrev_co_ci_u32_e64 v13, null, 0, v12, vcc_lo           // 0000000103A8: D5227C0D 01AA1880
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000000103B0: BF8701B2
	v_cmp_le_u32_e64 s0, s36, v9                               // 0000000103B4: D44B0000 00021224
	v_subrev_co_ci_u32_e64 v12, null, s37, v12, vcc_lo         // 0000000103BC: D5227C0C 01AA1825
	v_cmp_le_u32_e32 vcc_lo, s37, v3                           // 0000000103C4: 7C960625
	v_cndmask_b32_e64 v18, 0, -1, s0                           // 0000000103C8: D5010012 00018280
	v_cmp_le_u32_e64 s0, s37, v13                              // 0000000103D0: D44B0000 00021A25
	v_cndmask_b32_e64 v21, 0, -1, vcc_lo                       // 0000000103D8: D5010015 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s37, v13                          // 0000000103E0: 7C941A25
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000103E4: BF870123
	v_cndmask_b32_e64 v20, 0, -1, s0                           // 0000000103E8: D5010014 00018280
	v_cmp_eq_u32_e64 s0, s37, v3                               // 0000000103F0: D44A0000 00020625
	v_cndmask_b32_e32 v18, v20, v18, vcc_lo                    // 0000000103F8: 02242514
	v_sub_co_u32 v20, vcc_lo, v9, s36                          // 0000000103FC: D7016A14 00004909
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000010404: BF870191
	v_subrev_co_ci_u32_e64 v12, null, 0, v12, vcc_lo           // 000000010408: D5227C0C 01AA1880
	v_cmp_ne_u32_e32 vcc_lo, 0, v18                            // 000000010410: 7C9A2480
	v_cndmask_b32_e64 v17, v21, v17, s0                        // 000000010414: D5010011 00022315
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 00000001041C: BF8701A3
	v_cndmask_b32_e32 v12, v13, v12, vcc_lo                    // 000000010420: 0218190D
	v_cndmask_b32_e32 v9, v9, v20, vcc_lo                      // 000000010424: 02122909
	v_cmp_ne_u32_e32 vcc_lo, 0, v17                            // 000000010428: 7C9A2280
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000001042C: BF870092
	v_dual_cndmask_b32 v8, v8, v9 :: v_dual_cndmask_b32 v3, v3, v12// 000000010430: CA521308 08021903
	v_xor_b32_e32 v8, v8, v19                                  // 000000010438: 3A102708
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000001043C: BF870112
	v_xor_b32_e32 v3, v3, v19                                  // 000000010440: 3A062703
	v_sub_co_u32 v8, vcc_lo, v8, v19                           // 000000010444: D7016A08 00022708
	s_delay_alu instid0(VALU_DEP_1)                            // 00000001044C: BF870001
	v_sub_co_ci_u32_e64 v9, null, v3, v19, vcc_lo              // 000000010450: D5217C09 01AA2703
	s_and_not1_saveexec_b32 s0, s50                            // 000000010458: BE803032
	s_cbranch_execz 23                                         // 00000001045C: BFA50017 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xabc>
	s_sub_i32 s29, 0, s8                                       // 000000010460: 819D0880
	v_mov_b32_e32 v9, v2                                       // 000000010464: 7E120302
	v_mul_lo_u32 v3, s29, v16                                  // 000000010468: D72C0003 0002201D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010470: BF870091
	v_mul_hi_u32 v3, v16, v3                                   // 000000010474: D72D0003 00020710
	v_add_nc_u32_e32 v3, v16, v3                               // 00000001047C: 4A060710
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010480: BF870091
	v_mul_hi_u32 v3, v6, v3                                    // 000000010484: D72D0003 00020706
	v_mul_lo_u32 v3, v3, s8                                    // 00000001048C: D72C0003 00001103
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010494: BF870091
	v_sub_nc_u32_e32 v3, v6, v3                                // 000000010498: 4C060706
	v_subrev_nc_u32_e32 v8, s8, v3                             // 00000001049C: 4E100608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 0000000104A0: 7C960608
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000104A4: BF870092
	v_cndmask_b32_e32 v3, v3, v8, vcc_lo                       // 0000000104A8: 02061103
	v_subrev_nc_u32_e32 v8, s8, v3                             // 0000000104AC: 4E100608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 0000000104B0: 7C960608
	s_delay_alu instid0(VALU_DEP_2)                            // 0000000104B4: BF870002
	v_cndmask_b32_e32 v8, v3, v8, vcc_lo                       // 0000000104B8: 02101103
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000104BC: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000000104C0: BF8700B1
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 0000000104C4: D73C0008 00021082
	ds_load_b32 v12, v11                                       // 0000000104CC: D8D80000 0C00000B
	v_add_co_u32 v8, vcc_lo, s47, v8                           // 0000000104D4: D7006A08 0002102F
	v_add_co_ci_u32_e64 v9, null, s49, v9, vcc_lo              // 0000000104DC: D5207C09 01AA1231
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 0000000104E4: 916A197E
	global_load_b32 v8, v[8:9], off                            // 0000000104E8: DC520000 087C0008
	s_waitcnt lgkmcnt(0)                                       // 0000000104F0: BF89FC07
	v_lshlrev_b32_e32 v3, 16, v12                              // 0000000104F4: 30061890
	s_cbranch_vccz 13                                          // 0000000104F8: BFA3000D <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb30>
	s_waitcnt vmcnt(0)                                         // 0000000104FC: BF8903F7
	v_lshlrev_b32_e32 v9, 16, v8                               // 000000010500: 30121090
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 000000010504: 916A197E
	s_cbranch_vccz 68                                          // 000000010508: BFA30044 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xc1c>
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000001050C: 916A197E
	s_cbranch_vccz 123                                         // 000000010510: BFA3007B <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xd00>
	v_and_b32_e32 v13, 0xffff0000, v12                         // 000000010514: 361A18FF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 00000001051C: 916A197E
	s_cbranch_vccz 175                                         // 000000010520: BFA300AF <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xde0>
	v_and_b32_e32 v12, 0xffff0000, v8                          // 000000010524: 361810FF FFFF0000
	s_branch 65285                                             // 00000001052C: BFA0FF05 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x744>
	v_bfe_u32 v9, v12, 10, 5                                   // 000000010530: D6100009 0215150C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010538: BF870122
	v_and_b32_e32 v3, 0x80000000, v3                           // 00000001053C: 360606FF 80000000
	s_mov_b32 s0, exec_lo                                      // 000000010544: BE80007E
	v_cmpx_lt_i32_e32 30, v9                                   // 000000010548: 7D82129E
	s_xor_b32 s0, exec_lo, s0                                  // 00000001054C: 8D00007E
	v_lshlrev_b32_e32 v9, 13, v12                              // 000000010550: 3012188D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010554: BF870091
	v_and_b32_e32 v9, 0x7fe000, v9                             // 000000010558: 361212FF 007FE000
	v_or3_b32 v3, v9, v3, 0x7f800000                           // 000000010560: D6580003 03FE0709 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 00000001056C: BE803000
	s_cbranch_execz 36                                         // 000000010570: BFA50024 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xc04>
	v_and_b32_e32 v13, 0x3ff, v12                              // 000000010574: 361A18FF 000003FF
	s_mov_b32 s29, exec_lo                                     // 00000001057C: BE9D007E
	v_cmpx_ne_u32_e32 0, v9                                    // 000000010580: 7D9A1280
	s_xor_b32 s29, exec_lo, s29                                // 000000010584: 8D1D1D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010588: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 00000001058C: 301A1A8D
	v_lshl_or_b32 v9, v9, 23, v13                              // 000000010590: D6560009 04352F09
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010598: BF870001
	v_add3_u32 v3, v9, v3, 0x38000000                          // 00000001059C: D6550003 03FE0709 38000000
	s_and_not1_saveexec_b32 s29, s29                           // 0000000105A8: BE9D301D
	s_cbranch_execz 19                                         // 0000000105AC: BFA50013 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xbfc>
	s_mov_b32 s36, exec_lo                                     // 0000000105B0: BEA4007E
	v_cmpx_ne_u32_e32 0, v13                                   // 0000000105B4: 7D9A1A80
	s_cbranch_execz 15                                         // 0000000105B8: BFA5000F <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xbf8>
	v_clz_i32_u32_e32 v9, v13                                  // 0000000105BC: 7E12730D
	v_or_b32_e32 v3, 0x43000000, v3                            // 0000000105C0: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000105C8: BF870122
	v_xor_b32_e32 v13, 31, v9                                  // 0000000105CC: 3A1A129F
	v_lshlrev_b32_e32 v9, 23, v9                               // 0000000105D0: 30121297
	v_sub_nc_u32_e32 v13, 9, v13                               // 0000000105D4: 4C1A1A89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000105D8: BF870112
	v_sub_nc_u32_e32 v3, v3, v9                                // 0000000105DC: 4C061303
	v_lshlrev_b32_e32 v13, v13, v12                            // 0000000105E0: 301A190D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000105E4: BF870091
	v_lshlrev_b32_e32 v13, 14, v13                             // 0000000105E8: 301A1A8E
	v_and_or_b32 v3, 0x7fc000, v13, v3                         // 0000000105EC: D6570003 040E1AFF 007FC000
	s_or_b32 exec_lo, exec_lo, s36                             // 0000000105F8: 8C7E247E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000105FC: BF870009
	s_or_b32 exec_lo, exec_lo, s29                             // 000000010600: 8C7E1D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010604: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 000000010608: 8C7E007E
	s_waitcnt vmcnt(0)                                         // 00000001060C: BF8903F7
	v_lshlrev_b32_e32 v9, 16, v8                               // 000000010610: 30121090
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 000000010614: 916A197E
	s_cbranch_vccnz 65468                                      // 000000010618: BFA4FFBC <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb0c>
	v_bfe_u32 v13, v8, 10, 5                                   // 00000001061C: D610000D 02151508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010624: BF870122
	v_and_b32_e32 v9, 0x80000000, v9                           // 000000010628: 361212FF 80000000
	s_mov_b32 s0, exec_lo                                      // 000000010630: BE80007E
	v_cmpx_lt_i32_e32 30, v13                                  // 000000010634: 7D821A9E
	s_xor_b32 s0, exec_lo, s0                                  // 000000010638: 8D00007E
	v_lshlrev_b32_e32 v13, 13, v8                              // 00000001063C: 301A108D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010640: BF870091
	v_and_b32_e32 v13, 0x7fe000, v13                           // 000000010644: 361A1AFF 007FE000
	v_or3_b32 v9, v13, v9, 0x7f800000                          // 00000001064C: D6580009 03FE130D 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000010658: BE803000
	s_cbranch_execz 36                                         // 00000001065C: BFA50024 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xcf0>
	v_and_b32_e32 v17, 0x3ff, v8                               // 000000010660: 362210FF 000003FF
	s_mov_b32 s29, exec_lo                                     // 000000010668: BE9D007E
	v_cmpx_ne_u32_e32 0, v13                                   // 00000001066C: 7D9A1A80
	s_xor_b32 s29, exec_lo, s29                                // 000000010670: 8D1D1D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010674: BF870092
	v_lshlrev_b32_e32 v17, 13, v17                             // 000000010678: 3022228D
	v_lshl_or_b32 v13, v13, 23, v17                            // 00000001067C: D656000D 04452F0D
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010684: BF870001
	v_add3_u32 v9, v13, v9, 0x38000000                         // 000000010688: D6550009 03FE130D 38000000
	s_and_not1_saveexec_b32 s29, s29                           // 000000010694: BE9D301D
	s_cbranch_execz 19                                         // 000000010698: BFA50013 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xce8>
	s_mov_b32 s36, exec_lo                                     // 00000001069C: BEA4007E
	v_cmpx_ne_u32_e32 0, v17                                   // 0000000106A0: 7D9A2280
	s_cbranch_execz 15                                         // 0000000106A4: BFA5000F <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xce4>
	v_clz_i32_u32_e32 v13, v17                                 // 0000000106A8: 7E1A7311
	v_or_b32_e32 v9, 0x43000000, v9                            // 0000000106AC: 381212FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000106B4: BF870122
	v_xor_b32_e32 v17, 31, v13                                 // 0000000106B8: 3A221A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 0000000106BC: 301A1A97
	v_sub_nc_u32_e32 v17, 9, v17                               // 0000000106C0: 4C222289
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000106C4: BF870112
	v_sub_nc_u32_e32 v9, v9, v13                               // 0000000106C8: 4C121B09
	v_lshlrev_b32_e32 v17, v17, v8                             // 0000000106CC: 30221111
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000106D0: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 0000000106D4: 3022228E
	v_and_or_b32 v9, 0x7fc000, v17, v9                         // 0000000106D8: D6570009 042622FF 007FC000
	s_or_b32 exec_lo, exec_lo, s36                             // 0000000106E4: 8C7E247E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000106E8: BF870009
	s_or_b32 exec_lo, exec_lo, s29                             // 0000000106EC: 8C7E1D7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000000106F0: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000106F4: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 0000000106F8: 916A197E
	s_cbranch_vccnz 65413                                      // 0000000106FC: BFA4FF85 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb14>
	v_bfe_u32 v18, v12, 26, 5                                  // 000000010700: D6100012 0215350C
	v_and_b32_e32 v13, 0x80000000, v12                         // 000000010708: 361A18FF 80000000
	v_mov_b16_e32 v17.h, 0                                     // 000000010710: 7F223880
	v_mov_b16_e32 v17.l, v12.h                                 // 000000010714: 7E22398C
	s_mov_b32 s0, exec_lo                                      // 000000010718: BE80007E
	v_cmpx_lt_i32_e32 30, v18                                  // 00000001071C: 7D82249E
	s_xor_b32 s0, exec_lo, s0                                  // 000000010720: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010724: BF870092
	v_lshlrev_b32_e32 v12, 13, v17                             // 000000010728: 3018228D
	v_or3_b32 v13, v12, v13, 0x7f800000                        // 00000001072C: D658000D 03FE1B0C 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000010738: BE803000
	s_cbranch_execz 36                                         // 00000001073C: BFA50024 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xdd0>
	v_bfe_u32 v12, v12, 16, 10                                 // 000000010740: D610000C 0229210C
	s_mov_b32 s29, exec_lo                                     // 000000010748: BE9D007E
	v_cmpx_ne_u32_e32 0, v18                                   // 00000001074C: 7D9A2480
	s_xor_b32 s29, exec_lo, s29                                // 000000010750: 8D1D1D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010754: BF870092
	v_lshlrev_b32_e32 v12, 13, v12                             // 000000010758: 3018188D
	v_lshl_or_b32 v12, v18, 23, v12                            // 00000001075C: D656000C 04312F12
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010764: BF870001
	v_add3_u32 v13, v12, v13, 0x38000000                       // 000000010768: D655000D 03FE1B0C 38000000
	s_and_not1_saveexec_b32 s29, s29                           // 000000010774: BE9D301D
	s_cbranch_execz 19                                         // 000000010778: BFA50013 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xdc8>
	s_mov_b32 s36, exec_lo                                     // 00000001077C: BEA4007E
	v_cmpx_ne_u32_e32 0, v12                                   // 000000010780: 7D9A1880
	s_cbranch_execz 15                                         // 000000010784: BFA5000F <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xdc4>
	v_clz_i32_u32_e32 v12, v12                                 // 000000010788: 7E18730C
	v_or_b32_e32 v13, 0x43000000, v13                          // 00000001078C: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010794: BF870122
	v_xor_b32_e32 v18, 31, v12                                 // 000000010798: 3A24189F
	v_lshlrev_b32_e32 v12, 23, v12                             // 00000001079C: 30181897
	v_sub_nc_u32_e32 v18, 9, v18                               // 0000000107A0: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000107A4: BF870112
	v_sub_nc_u32_e32 v12, v13, v12                             // 0000000107A8: 4C18190D
	v_lshlrev_b32_e32 v17, v18, v17                            // 0000000107AC: 30222312
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000107B0: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 0000000107B4: 3022228E
	v_and_or_b32 v13, 0x7fc000, v17, v12                       // 0000000107B8: D657000D 043222FF 007FC000
	s_or_b32 exec_lo, exec_lo, s36                             // 0000000107C4: 8C7E247E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000107C8: BF870009
	s_or_b32 exec_lo, exec_lo, s29                             // 0000000107CC: 8C7E1D7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000000107D0: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000107D4: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s25                        // 0000000107D8: 916A197E
	s_cbranch_vccnz 65361                                      // 0000000107DC: BFA4FF51 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xb24>
	v_bfe_u32 v18, v8, 26, 5                                   // 0000000107E0: D6100012 02153508
	v_and_b32_e32 v12, 0x80000000, v8                          // 0000000107E8: 361810FF 80000000
	v_mov_b16_e32 v17.h, 0                                     // 0000000107F0: 7F223880
	v_mov_b16_e32 v17.l, v8.h                                  // 0000000107F4: 7E223988
	s_mov_b32 s0, exec_lo                                      // 0000000107F8: BE80007E
	v_cmpx_lt_i32_e32 30, v18                                  // 0000000107FC: 7D82249E
	s_xor_b32 s0, exec_lo, s0                                  // 000000010800: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010804: BF870092
	v_lshlrev_b32_e32 v8, 13, v17                              // 000000010808: 3010228D
	v_or3_b32 v12, v8, v12, 0x7f800000                         // 00000001080C: D658000C 03FE1908 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000010818: BE803000
	s_cbranch_execz 65095                                      // 00000001081C: BFA5FE47 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x73c>
	v_bfe_u32 v8, v8, 16, 10                                   // 000000010820: D6100008 02292108
	s_mov_b32 s29, exec_lo                                     // 000000010828: BE9D007E
	v_cmpx_ne_u32_e32 0, v18                                   // 00000001082C: 7D9A2480
	s_xor_b32 s29, exec_lo, s29                                // 000000010830: 8D1D1D7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010834: BF870092
	v_lshlrev_b32_e32 v8, 13, v8                               // 000000010838: 3010108D
	v_lshl_or_b32 v8, v18, 23, v8                              // 00000001083C: D6560008 04212F12
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010844: BF870001
	v_add3_u32 v12, v8, v12, 0x38000000                        // 000000010848: D655000C 03FE1908 38000000
	s_and_not1_saveexec_b32 s29, s29                           // 000000010854: BE9D301D
	s_cbranch_execz 65078                                      // 000000010858: BFA5FE36 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x734>
	s_mov_b32 s36, exec_lo                                     // 00000001085C: BEA4007E
	v_cmpx_ne_u32_e32 0, v8                                    // 000000010860: 7D9A1080
	s_cbranch_execz 65074                                      // 000000010864: BFA5FE32 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x730>
	v_clz_i32_u32_e32 v8, v8                                   // 000000010868: 7E107308
	v_or_b32_e32 v12, 0x43000000, v12                          // 00000001086C: 381818FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010874: BF870122
	v_xor_b32_e32 v18, 31, v8                                  // 000000010878: 3A24109F
	v_lshlrev_b32_e32 v8, 23, v8                               // 00000001087C: 30101097
	v_sub_nc_u32_e32 v18, 9, v18                               // 000000010880: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010884: BF870112
	v_sub_nc_u32_e32 v8, v12, v8                               // 000000010888: 4C10110C
	v_lshlrev_b32_e32 v17, v18, v17                            // 00000001088C: 30222312
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010890: BF870091
	v_lshlrev_b32_e32 v17, 14, v17                             // 000000010894: 3022228E
	v_and_or_b32 v12, 0x7fc000, v17, v8                        // 000000010898: D657000C 042222FF 007FC000
	s_branch 65058                                             // 0000000108A4: BFA0FE22 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x730>
	s_or_b32 exec_lo, exec_lo, s48                             // 0000000108A8: 8C7E307E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000000108AC: BF870499
	s_or_b32 exec_lo, exec_lo, s46                             // 0000000108B0: 8C7E2E7E
	s_and_not1_b32 vcc_lo, exec_lo, s42                        // 0000000108B4: 916A2A7E
	s_mov_b32 s0, s41                                          // 0000000108B8: BE800029
	ds_store_b32 v15, v10                                      // 0000000108BC: D8340000 00000A0F
	s_waitcnt lgkmcnt(0)                                       // 0000000108C4: BF89FC07
	s_barrier                                                  // 0000000108C8: BFBD0000
	buffer_gl0_inv                                             // 0000000108CC: E0AC0000 00000000
	s_cbranch_vccz 35                                          // 0000000108D4: BFA30023 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xf64>
	s_and_saveexec_b32 s0, s2                                  // 0000000108D8: BE802002
	s_cbranch_execz 65017                                      // 0000000108DC: BFA5FDF9 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x6c4>
	v_mov_b32_e32 v3, s33                                      // 0000000108E0: 7E060221
	s_lshl_b64 s[36:37], s[34:35], 2                           // 0000000108E4: 84A48222
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000108E8: BF870009
	s_add_u32 s36, s43, s36                                    // 0000000108EC: 8024242B
	s_addc_u32 s37, s44, s37                                   // 0000000108F0: 8225252C
	ds_load_b32 v3, v3                                         // 0000000108F4: D8D80000 03000003
	s_waitcnt lgkmcnt(0)                                       // 0000000108FC: BF89FC07
	global_store_b32 v2, v3, s[36:37]                          // 000000010900: DC6A0000 00240302
	s_branch 65006                                             // 000000010908: BFA0FDEE <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0x6c4>
	s_nop 0                                                    // 00000001090C: BF800000
	s_nop 0                                                    // 000000010910: BF800000
	s_nop 0                                                    // 000000010914: BF800000
	s_nop 0                                                    // 000000010918: BF800000
	s_nop 0                                                    // 00000001091C: BF800000
	s_nop 0                                                    // 000000010920: BF800000
	s_nop 0                                                    // 000000010924: BF800000
	s_nop 0                                                    // 000000010928: BF800000
	s_nop 0                                                    // 00000001092C: BF800000
	s_nop 0                                                    // 000000010930: BF800000
	s_nop 0                                                    // 000000010934: BF800000
	s_nop 0                                                    // 000000010938: BF800000
	s_nop 0                                                    // 00000001093C: BF800000
	s_or_b32 exec_lo, exec_lo, s29                             // 000000010940: 8C7E1D7E
	s_lshr_b32 s29, s0, 1                                      // 000000010944: 851D8100
	s_cmp_lt_u32 s0, 2                                         // 000000010948: BF0A8200
	s_mov_b32 s0, s29                                          // 00000001094C: BE80001D
	s_waitcnt lgkmcnt(0)                                       // 000000010950: BF89FC07
	s_barrier                                                  // 000000010954: BFBD0000
	buffer_gl0_inv                                             // 000000010958: E0AC0000 00000000
	s_cbranch_scc1 65501                                       // 000000010960: BFA2FFDD <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xed8>
	s_mov_b32 s29, exec_lo                                     // 000000010964: BE9D007E
	v_cmpx_gt_u32_e64 s0, v0                                   // 000000010968: D4CC007E 00020000
	s_cbranch_execz 65523                                      // 000000010970: BFA5FFF3 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xf40>
	v_lshl_add_u32 v3, s0, 2, v15                              // 000000010974: D6460003 043D0400
	ds_load_b32 v3, v3                                         // 00000001097C: D8D80000 03000003
	ds_load_b32 v6, v15                                        // 000000010984: D8D80000 0600000F
	s_waitcnt lgkmcnt(0)                                       // 00000001098C: BF89FC07
	v_add_f32_e32 v3, v3, v6                                   // 000000010990: 06060D03
	ds_store_b32 v15, v3                                       // 000000010994: D8340000 0000030F
	s_branch 65512                                             // 00000001099C: BFA0FFE8 <_ZN12_GLOBAL__N_127graph_persistent_lds_kernelEPKjS1_PKiPfPillllllii+0xf40>
	s_endpgm                                                   // 0000000109A0: BFB00000
		...

0000000000010a00 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii>:
	s_clause 0x3                                               // 000000010A00: BF850003
	s_load_b512 s[4:19], s[0:1], 0x28                          // 000000010A04: F4100100 F8000028
	s_load_b256 s[20:27], s[0:1], null                         // 000000010A0C: F40C0500 F8000000
	s_load_b64 s[28:29], s[0:1], 0x68                          // 000000010A14: F4040700 F8000068
	s_load_b64 s[30:31], s[0:1], 0x20                          // 000000010A1C: F4040780 F8000020
	v_dual_mov_b32 v2, 0 :: v_dual_lshlrev_b32 v3, 2, v0       // 000000010A24: CA220080 02020082
	v_cmp_eq_u32_e64 s2, 0, v0                                 // 000000010A2C: D44A0002 00020080
	s_mov_b32 s34, 0                                           // 000000010A34: BEA20080
	v_dual_mov_b32 v1, v2 :: v_dual_add_nc_u32 v14, 4, v3      // 000000010A38: CA200102 010E0684
	s_waitcnt lgkmcnt(0)                                       // 000000010A40: BF89FC07
	v_cvt_f32_u32_e32 v4, s14                                  // 000000010A44: 7E080C0E
	v_cvt_f32_u32_e32 v5, s8                                   // 000000010A48: 7E0A0C08
	s_lshl_b32 s33, s10, 2                                     // 000000010A4C: 8421820A
	v_cmp_gt_i64_e64 s3, s[10:11], v[0:1]                      // 000000010A50: D4540003 0002000A
	s_add_i32 s33, s33, 4                                      // 000000010A58: 81218421
	v_rcp_iflag_f32_e32 v6, v4                                 // 000000010A5C: 7E0C5704
	v_rcp_iflag_f32_e32 v7, v5                                 // 000000010A60: 7E0E5705
	v_add_co_u32 v4, s20, s20, v3                              // 000000010A64: D7001404 00020614
	v_add_nc_u32_e32 v15, s33, v3                              // 000000010A6C: 4A1E0621
	s_cmp_gt_i32 s28, 0                                        // 000000010A70: BF02801C
	v_add_co_ci_u32_e64 v5, null, s21, 0, s20                  // 000000010A74: D5207C05 00510015
	s_cselect_b32 s48, -1, 0                                   // 000000010A7C: 983080C1
	s_add_u32 s20, s0, 0x70                                    // 000000010A80: 8014FF00 00000070
	s_waitcnt_depctr 0xfff                                     // 000000010A88: BF880FFF
	v_dual_mul_f32 v3, 0x4f7ffffe, v6 :: v_dual_mul_f32 v6, 0x4f7ffffe, v7// 000000010A8C: C8C60CFF 03060EFF 4F7FFFFE
	s_addc_u32 s21, s1, 0                                      // 000000010A98: 82158001
	s_cmp_eq_u32 s29, 0                                        // 000000010A9C: BF06801D
	s_cselect_b32 s29, -1, 0                                   // 000000010AA0: 981D80C1
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010AA4: BF870001
	v_cvt_u32_f32_e32 v16, v3                                  // 000000010AA8: 7E200F03
	v_cvt_u32_f32_e32 v17, v6                                  // 000000010AAC: 7E220F06
	s_ashr_i32 s36, s15, 31                                    // 000000010AB0: 86249F0F
	s_branch 4                                                 // 000000010AB4: BFA00004 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xc8>
	s_mov_b32 s0, 0                                            // 000000010AB8: BE800080
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010ABC: BF870009
	s_and_not1_b32 vcc_lo, exec_lo, s0                         // 000000010AC0: 916A007E
	s_cbranch_vccz 1143                                        // 000000010AC4: BFA30477 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x12a4>
	s_and_saveexec_b32 s0, s2                                  // 000000010AC8: BE802002
	s_cbranch_execz 21                                         // 000000010ACC: BFA50015 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x124>
	s_mov_b32 s35, exec_lo                                     // 000000010AD0: BEA3007E
	s_mov_b32 s1, exec_lo                                      // 000000010AD4: BE81007E
	v_mbcnt_lo_u32_b32 v3, s35, 0                              // 000000010AD8: D71F0003 00010023
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010AE0: BF870001
	v_cmpx_eq_u32_e32 0, v3                                    // 000000010AE4: 7D940680
	s_cbranch_execz 6                                          // 000000010AE8: BFA50006 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x104>
	s_bcnt1_i32_b32 s35, s35                                   // 000000010AEC: BEA31823
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010AF0: BF870499
	s_mul_i32 s35, s28, s35                                    // 000000010AF4: 9623231C
	v_mov_b32_e32 v6, s35                                      // 000000010AF8: 7E0C0223
	global_atomic_add_u32 v6, v2, v6, s[30:31] glc             // 000000010AFC: DCD64000 061E0602
	s_or_b32 exec_lo, exec_lo, s1                              // 000000010B04: 8C7E017E
	s_waitcnt vmcnt(0)                                         // 000000010B08: BF8903F7
	v_readfirstlane_b32 s38, v6                                // 000000010B0C: 7E4C0506
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010B10: BF870001
	v_mad_u64_u32 v[6:7], null, s28, v3, s[38:39]              // 000000010B14: D6FE7C06 009A061C
	ds_store_b32 v2, v6                                        // 000000010B1C: D8340000 00000602
	s_or_b32 exec_lo, exec_lo, s0                              // 000000010B24: 8C7E007E
	s_waitcnt lgkmcnt(0)                                       // 000000010B28: BF89FC07
	s_barrier                                                  // 000000010B2C: BFBD0000
	buffer_gl0_inv                                             // 000000010B30: E0AC0000 00000000
	ds_load_b32 v3, v2                                         // 000000010B38: D8D80000 03000002
	s_waitcnt lgkmcnt(0)                                       // 000000010B40: BF89FC07
	v_readfirstlane_b32 s38, v3                                // 000000010B44: 7E4C0503
	s_ashr_i32 s39, s38, 31                                    // 000000010B48: 86279F26
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010B4C: BF870009
	v_cmp_le_i64_e64 s0, s[18:19], s[38:39]                    // 000000010B50: D4530000 00004C12
	s_and_b32 vcc_lo, exec_lo, s0                              // 000000010B58: 8B6A007E
	s_mov_b32 s0, -1                                           // 000000010B5C: BE8000C1
	s_cbranch_vccnz 65494                                      // 000000010B60: BFA4FFD6 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xbc>
	s_and_not1_b32 vcc_lo, exec_lo, s48                        // 000000010B64: 916A307E
	s_cbranch_vccnz 65491                                      // 000000010B68: BFA4FFD3 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xb8>
	s_mov_b32 s49, 0                                           // 000000010B6C: BEB10080
	s_branch 7                                                 // 000000010B70: BFA00007 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x190>
	s_add_i32 s49, s49, 1                                      // 000000010B74: 81318131
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010B78: BF870009
	s_cmp_eq_u32 s49, s28                                      // 000000010B7C: BF061C31
	s_cselect_b32 s0, -1, 0                                    // 000000010B80: 980080C1
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010B84: BF870009
	s_and_b32 vcc_lo, exec_lo, s0                              // 000000010B88: 8B6A007E
	s_cbranch_vccnz 65482                                      // 000000010B8C: BFA4FFCA <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xb8>
	s_add_u32 s40, s49, s38                                    // 000000010B90: 80282631
	s_addc_u32 s41, 0, s39                                     // 000000010B94: 82292780
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010B98: BF870009
	v_cmp_ge_i64_e64 s0, s[40:41], s[18:19]                    // 000000010B9C: D4560000 00002428
	s_and_b32 vcc_lo, exec_lo, s0                              // 000000010BA4: 8B6A007E
	s_mov_b32 s0, -1                                           // 000000010BA8: BE8000C1
	s_cbranch_vccnz 65525                                      // 000000010BAC: BFA4FFF5 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x184>
	s_or_b64 s[0:1], s[40:41], s[14:15]                        // 000000010BB0: 8C800E28
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010BB4: BF870499
	s_mov_b32 s35, s1                                          // 000000010BB8: BEA30001
	s_cmp_lg_u64 s[34:35], 0                                   // 000000010BBC: BF118022
	s_cbranch_scc0 1079                                        // 000000010BC0: BFA10437 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x12a0>
	s_add_u32 s0, s14, s36                                     // 000000010BC4: 8000240E
	s_mov_b32 s37, s36                                         // 000000010BC8: BEA50024
	s_addc_u32 s1, s15, s36                                    // 000000010BCC: 8201240F
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010BD0: BF870499
	s_xor_b64 s[0:1], s[0:1], s[36:37]                         // 000000010BD4: 8D802400
	v_cvt_f32_u32_e32 v3, s0                                   // 000000010BD8: 7E060C00
	v_cvt_f32_u32_e32 v6, s1                                   // 000000010BDC: 7E0C0C01
	s_sub_u32 s43, 0, s0                                       // 000000010BE0: 80AB0080
	s_subb_u32 s44, 0, s1                                      // 000000010BE4: 82AC0180
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010BE8: BF870091
	v_fmac_f32_e32 v3, 0x4f800000, v6                          // 000000010BEC: 56060CFF 4F800000
	v_rcp_f32_e32 v3, v3                                       // 000000010BF4: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000010BF8: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000010BFC: 100606FF 5F7FFFFC
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010C04: BF870091
	v_mul_f32_e32 v6, 0x2f800000, v3                           // 000000010C08: 100C06FF 2F800000
	v_trunc_f32_e32 v6, v6                                     // 000000010C10: 7E0C4306
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000010C14: BF870121
	v_fmac_f32_e32 v3, 0xcf800000, v6                          // 000000010C18: 56060CFF CF800000
	v_cvt_u32_f32_e32 v6, v6                                   // 000000010C20: 7E0C0F06
	v_cvt_u32_f32_e32 v3, v3                                   // 000000010C24: 7E060F03
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010C28: BF870112
	v_readfirstlane_b32 s35, v6                                // 000000010C2C: 7E460506
	v_readfirstlane_b32 s42, v3                                // 000000010C30: 7E540503
	s_mul_i32 s45, s43, s35                                    // 000000010C34: 962D232B
	s_mul_hi_u32 s47, s43, s42                                 // 000000010C38: 96AF2A2B
	s_mul_i32 s46, s44, s42                                    // 000000010C3C: 962E2A2C
	s_add_i32 s45, s47, s45                                    // 000000010C40: 812D2D2F
	s_mul_i32 s50, s43, s42                                    // 000000010C44: 96322A2B
	s_add_i32 s45, s45, s46                                    // 000000010C48: 812D2E2D
	s_mul_hi_u32 s47, s42, s50                                 // 000000010C4C: 96AF322A
	s_mul_i32 s52, s42, s45                                    // 000000010C50: 96342D2A
	s_mul_hi_u32 s51, s35, s50                                 // 000000010C54: 96B33223
	s_mul_i32 s46, s35, s50                                    // 000000010C58: 962E3223
	s_mul_hi_u32 s50, s42, s45                                 // 000000010C5C: 96B22D2A
	s_add_u32 s47, s47, s52                                    // 000000010C60: 802F342F
	s_addc_u32 s50, 0, s50                                     // 000000010C64: 82323280
	s_mul_hi_u32 s53, s35, s45                                 // 000000010C68: 96B52D23
	s_add_u32 s46, s47, s46                                    // 000000010C6C: 802E2E2F
	s_mul_i32 s45, s35, s45                                    // 000000010C70: 962D2D23
	s_addc_u32 s46, s50, s51                                   // 000000010C74: 822E3332
	s_addc_u32 s47, s53, 0                                     // 000000010C78: 822F8035
	s_add_u32 s45, s46, s45                                    // 000000010C7C: 802D2D2E
	s_addc_u32 s46, 0, s47                                     // 000000010C80: 822E2F80
	s_add_u32 s42, s42, s45                                    // 000000010C84: 802A2D2A
	s_cselect_b32 s45, -1, 0                                   // 000000010C88: 982D80C1
	s_mul_hi_u32 s47, s43, s42                                 // 000000010C8C: 96AF2A2B
	s_cmp_lg_u32 s45, 0                                        // 000000010C90: BF07802D
	s_mul_i32 s45, s43, s42                                    // 000000010C94: 962D2A2B
	s_addc_u32 s35, s35, s46                                   // 000000010C98: 82232E23
	s_mul_i32 s44, s44, s42                                    // 000000010C9C: 962C2A2C
	s_mul_i32 s43, s43, s35                                    // 000000010CA0: 962B232B
	s_mul_hi_u32 s46, s42, s45                                 // 000000010CA4: 96AE2D2A
	s_add_i32 s43, s47, s43                                    // 000000010CA8: 812B2B2F
	s_mul_hi_u32 s47, s35, s45                                 // 000000010CAC: 96AF2D23
	s_add_i32 s43, s43, s44                                    // 000000010CB0: 812B2C2B
	s_mul_i32 s44, s35, s45                                    // 000000010CB4: 962C2D23
	s_mul_i32 s51, s42, s43                                    // 000000010CB8: 96332B2A
	s_mul_hi_u32 s50, s42, s43                                 // 000000010CBC: 96B22B2A
	s_add_u32 s46, s46, s51                                    // 000000010CC0: 802E332E
	s_addc_u32 s50, 0, s50                                     // 000000010CC4: 82323280
	s_mul_hi_u32 s45, s35, s43                                 // 000000010CC8: 96AD2B23
	s_add_u32 s44, s46, s44                                    // 000000010CCC: 802C2C2E
	s_mul_i32 s43, s35, s43                                    // 000000010CD0: 962B2B23
	s_addc_u32 s44, s50, s47                                   // 000000010CD4: 822C2F32
	s_addc_u32 s45, s45, 0                                     // 000000010CD8: 822D802D
	s_add_u32 s43, s44, s43                                    // 000000010CDC: 802B2B2C
	s_addc_u32 s44, 0, s45                                     // 000000010CE0: 822C2D80
	s_add_u32 s46, s42, s43                                    // 000000010CE4: 802E2B2A
	s_cselect_b32 s42, -1, 0                                   // 000000010CE8: 982A80C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 000000010CEC: BF8704B9
	s_cmp_lg_u32 s42, 0                                        // 000000010CF0: BF07802A
	s_addc_u32 s35, s35, s44                                   // 000000010CF4: 82232C23
	s_ashr_i32 s42, s41, 31                                    // 000000010CF8: 862A9F29
	s_add_u32 s44, s40, s42                                    // 000000010CFC: 802C2A28
	s_mov_b32 s43, s42                                         // 000000010D00: BEAB002A
	s_addc_u32 s45, s41, s42                                   // 000000010D04: 822D2A29
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010D08: BF870499
	s_xor_b64 s[44:45], s[44:45], s[42:43]                     // 000000010D0C: 8DAC2A2C
	s_mul_i32 s50, s44, s35                                    // 000000010D10: 9632232C
	s_mul_hi_u32 s51, s44, s46                                 // 000000010D14: 96B32E2C
	s_mul_hi_u32 s47, s44, s35                                 // 000000010D18: 96AF232C
	s_mul_hi_u32 s53, s45, s46                                 // 000000010D1C: 96B52E2D
	s_mul_i32 s46, s45, s46                                    // 000000010D20: 962E2E2D
	s_add_u32 s50, s51, s50                                    // 000000010D24: 80323233
	s_addc_u32 s47, 0, s47                                     // 000000010D28: 822F2F80
	s_mul_hi_u32 s52, s45, s35                                 // 000000010D2C: 96B4232D
	s_add_u32 s46, s50, s46                                    // 000000010D30: 802E2E32
	s_mul_i32 s35, s45, s35                                    // 000000010D34: 9623232D
	s_addc_u32 s46, s47, s53                                   // 000000010D38: 822E352F
	s_addc_u32 s47, s52, 0                                     // 000000010D3C: 822F8034
	s_add_u32 s35, s46, s35                                    // 000000010D40: 8023232E
	s_addc_u32 s46, 0, s47                                     // 000000010D44: 822E2F80
	s_mul_hi_u32 s47, s0, s35                                  // 000000010D48: 96AF2300
	s_mul_i32 s50, s0, s46                                     // 000000010D4C: 96322E00
	s_mul_i32 s51, s1, s35                                     // 000000010D50: 96332301
	s_add_i32 s47, s47, s50                                    // 000000010D54: 812F322F
	s_mul_i32 s50, s0, s35                                     // 000000010D58: 96322300
	s_add_i32 s47, s47, s51                                    // 000000010D5C: 812F332F
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_2) | instid1(SALU_CYCLE_1)// 000000010D60: BF8704B9
	s_sub_i32 s51, s45, s47                                    // 000000010D64: 81B32F2D
	s_sub_u32 s44, s44, s50                                    // 000000010D68: 80AC322C
	s_cselect_b32 s50, -1, 0                                   // 000000010D6C: 983280C1
	s_cmp_lg_u32 s50, 0                                        // 000000010D70: BF078032
	s_subb_u32 s51, s51, s1                                    // 000000010D74: 82B30133
	s_sub_u32 s52, s44, s0                                     // 000000010D78: 80B4002C
	s_cselect_b32 s53, -1, 0                                   // 000000010D7C: 983580C1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 000000010D80: BF8704A9
	s_cmp_lg_u32 s53, 0                                        // 000000010D84: BF078035
	s_subb_u32 s51, s51, 0                                     // 000000010D88: 82B38033
	s_cmp_ge_u32 s51, s1                                       // 000000010D8C: BF090133
	s_cselect_b32 s53, -1, 0                                   // 000000010D90: 983580C1
	s_cmp_ge_u32 s52, s0                                       // 000000010D94: BF090034
	s_cselect_b32 s52, -1, 0                                   // 000000010D98: 983480C1
	s_cmp_eq_u32 s51, s1                                       // 000000010D9C: BF060133
	s_cselect_b32 s51, s52, s53                                // 000000010DA0: 98333534
	s_add_u32 s52, s35, 1                                      // 000000010DA4: 80348123
	s_addc_u32 s53, s46, 0                                     // 000000010DA8: 8235802E
	s_add_u32 s54, s35, 2                                      // 000000010DAC: 80368223
	s_addc_u32 s55, s46, 0                                     // 000000010DB0: 8237802E
	s_cmp_lg_u32 s51, 0                                        // 000000010DB4: BF078033
	s_cselect_b32 s51, s54, s52                                // 000000010DB8: 98333436
	s_cselect_b32 s52, s55, s53                                // 000000010DBC: 98343537
	s_cmp_lg_u32 s50, 0                                        // 000000010DC0: BF078032
	s_subb_u32 s45, s45, s47                                   // 000000010DC4: 82AD2F2D
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010DC8: BF870009
	s_cmp_ge_u32 s45, s1                                       // 000000010DCC: BF09012D
	s_cselect_b32 s47, -1, 0                                   // 000000010DD0: 982F80C1
	s_cmp_ge_u32 s44, s0                                       // 000000010DD4: BF09002C
	s_cselect_b32 s0, -1, 0                                    // 000000010DD8: 980080C1
	s_cmp_eq_u32 s45, s1                                       // 000000010DDC: BF06012D
	s_cselect_b32 s0, s0, s47                                  // 000000010DE0: 98002F00
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_3) | instid1(SALU_CYCLE_1)// 000000010DE4: BF8704C9
	s_cmp_lg_u32 s0, 0                                         // 000000010DE8: BF078000
	s_cselect_b32 s1, s52, s46                                 // 000000010DEC: 98012E34
	s_cselect_b32 s0, s51, s35                                 // 000000010DF0: 98002333
	s_xor_b64 s[42:43], s[42:43], s[36:37]                     // 000000010DF4: 8DAA242A
	s_xor_b64 s[0:1], s[0:1], s[42:43]                         // 000000010DF8: 8D802A00
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010DFC: BF870009
	s_sub_u32 s44, s0, s42                                     // 000000010E00: 80AC2A00
	s_subb_u32 s45, s1, s43                                    // 000000010E04: 82AD2B01
	s_cbranch_execnz 20                                        // 000000010E08: BFA60014 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x45c>
	v_readfirstlane_b32 s0, v16                                // 000000010E0C: 7E000510
	s_sub_i32 s1, 0, s14                                       // 000000010E10: 81810E80
	s_mov_b32 s45, s34                                         // 000000010E14: BEAD0022
	s_mul_i32 s1, s1, s0                                       // 000000010E18: 96010001
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010E1C: BF870499
	s_mul_hi_u32 s1, s0, s1                                    // 000000010E20: 96810100
	s_add_i32 s0, s0, s1                                       // 000000010E24: 81000100
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000010E28: BF870499
	s_mul_hi_u32 s0, s40, s0                                   // 000000010E2C: 96800028
	s_mul_i32 s1, s0, s14                                      // 000000010E30: 96010E00
	s_add_i32 s35, s0, 1                                       // 000000010E34: 81238100
	s_sub_i32 s1, s40, s1                                      // 000000010E38: 81810128
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010E3C: BF870009
	s_sub_i32 s37, s1, s14                                     // 000000010E40: 81A50E01
	s_cmp_ge_u32 s1, s14                                       // 000000010E44: BF090E01
	s_cselect_b32 s0, s35, s0                                  // 000000010E48: 98000023
	s_cselect_b32 s1, s37, s1                                  // 000000010E4C: 98010125
	s_add_i32 s35, s0, 1                                       // 000000010E50: 81238100
	s_cmp_ge_u32 s1, s14                                       // 000000010E54: BF090E01
	s_cselect_b32 s44, s35, s0                                 // 000000010E58: 982C0023
	s_and_saveexec_b32 s1, s3                                  // 000000010E5C: BE812003
	s_cbranch_execz 294                                        // 000000010E60: BFA50126 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x8fc>
	s_load_b32 s0, s[20:21], 0xc                               // 000000010E64: F400000A F800000C
	s_mul_i32 s35, s44, s7                                     // 000000010E6C: 9623072C
	s_mul_hi_u32 s37, s44, s6                                  // 000000010E70: 96A5062C
	s_mul_i32 s43, s45, s6                                     // 000000010E74: 962B062D
	s_add_i32 s35, s37, s35                                    // 000000010E78: 81232325
	s_mul_i32 s42, s44, s6                                     // 000000010E7C: 962A062C
	s_add_i32 s43, s35, s43                                    // 000000010E80: 812B2B23
	v_dual_mov_b32 v18, v14 :: v_dual_mov_b32 v7, v5           // 000000010E84: CA10010E 12060105
	s_lshl_b64 s[42:43], s[42:43], 2                           // 000000010E8C: 84AA822A
	v_dual_mov_b32 v6, v4 :: v_dual_mov_b32 v9, v1             // 000000010E90: CA100104 06080101
	v_mov_b32_e32 v8, v0                                       // 000000010E98: 7E100300
	s_add_u32 s35, s24, s42                                    // 000000010E9C: 80232A18
	s_addc_u32 s37, s25, s43                                   // 000000010EA0: 82252B19
	s_mov_b32 s52, 0                                           // 000000010EA4: BEB40080
	s_waitcnt lgkmcnt(0)                                       // 000000010EA8: BF89FC07
	s_and_b32 s50, s0, 0xffff                                  // 000000010EAC: 8B32FF00 0000FFFF
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010EB4: BF870009
	s_lshl_b32 s51, s50, 2                                     // 000000010EB8: 84338232
	s_branch 19                                                // 000000010EBC: BFA00013 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x50c>
	s_or_b32 exec_lo, exec_lo, s0                              // 000000010EC0: 8C7E007E
	v_add_co_u32 v8, vcc_lo, v8, s50                           // 000000010EC4: D7006A08 00006508
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010ECC: BF870001
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000010ED0: D5207C09 01AA1280
	v_add_co_u32 v6, s0, v6, s51                               // 000000010ED8: D7000006 00006706
	s_waitcnt vmcnt(0)                                         // 000000010EE0: BF8903F7
	ds_store_b32 v18, v3                                       // 000000010EE4: D8340000 00000312
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[8:9]                  // 000000010EEC: 7CA6100A
	v_add_co_ci_u32_e64 v7, null, 0, v7, s0                    // 000000010EF0: D5207C07 00020E80
	v_add_nc_u32_e32 v18, s51, v18                             // 000000010EF8: 4A242433
	s_or_b32 s52, vcc_lo, s52                                  // 000000010EFC: 8C34346A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010F00: BF870009
	s_and_not1_b32 exec_lo, exec_lo, s52                       // 000000010F04: 917E347E
	s_cbranch_execz 252                                        // 000000010F08: BFA500FC <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x8fc>
	v_or_b32_e32 v3, s9, v9                                    // 000000010F0C: 38061209
	s_mov_b32 s0, exec_lo                                      // 000000010F10: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 000000010F14: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 000000010F18: 7DBA0480
	s_xor_b32 s53, exec_lo, s0                                 // 000000010F1C: 8D35007E
	s_cbranch_execz 177                                        // 000000010F20: BFA500B1 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x7e8>
	s_ashr_i32 s42, s9, 31                                     // 000000010F24: 862A9F09
	v_ashrrev_i32_e32 v21, 31, v9                              // 000000010F28: 342A129F
	s_add_u32 s46, s8, s42                                     // 000000010F2C: 802E2A08
	s_mov_b32 s43, s42                                         // 000000010F30: BEAB002A
	s_addc_u32 s47, s9, s42                                    // 000000010F34: 822F2A09
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000010F38: BF870009
	s_xor_b64 s[46:47], s[46:47], s[42:43]                     // 000000010F3C: 8DAE2A2E
	v_add_co_u32 v11, vcc_lo, v8, v21                          // 000000010F40: D7006A0B 00022B08
	v_cvt_f32_u32_e32 v3, s46                                  // 000000010F48: 7E060C2E
	v_cvt_f32_u32_e32 v10, s47                                 // 000000010F4C: 7E140C2F
	s_sub_u32 s54, 0, s46                                      // 000000010F50: 80B62E80
	s_subb_u32 s55, 0, s47                                     // 000000010F54: 82B72F80
	v_add_co_ci_u32_e64 v12, null, v9, v21, vcc_lo             // 000000010F58: D5207C0C 01AA2B09
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010F60: BF870112
	v_fmac_f32_e32 v3, 0x4f800000, v10                         // 000000010F64: 560614FF 4F800000
	v_xor_b32_e32 v22, v12, v21                                // 000000010F6C: 3A2C2B0C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 000000010F70: BF8700B2
	v_rcp_f32_e32 v3, v3                                       // 000000010F74: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000010F78: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000010F7C: 100606FF 5F7FFFFC
	v_mul_f32_e32 v10, 0x2f800000, v3                          // 000000010F84: 101406FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000010F8C: BF870091
	v_trunc_f32_e32 v10, v10                                   // 000000010F90: 7E14430A
	v_fmac_f32_e32 v3, 0xcf800000, v10                         // 000000010F94: 560614FF CF800000
	v_cvt_u32_f32_e32 v10, v10                                 // 000000010F9C: 7E140F0A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000010FA0: BF870112
	v_cvt_u32_f32_e32 v3, v3                                   // 000000010FA4: 7E060F03
	v_readfirstlane_b32 s0, v10                                // 000000010FA8: 7E00050A
	s_delay_alu instid0(VALU_DEP_2)                            // 000000010FAC: BF870002
	v_readfirstlane_b32 s43, v3                                // 000000010FB0: 7E560503
	s_mul_i32 s56, s54, s0                                     // 000000010FB4: 96380036
	v_xor_b32_e32 v3, v11, v21                                 // 000000010FB8: 3A062B0B
	s_mul_hi_u32 s58, s54, s43                                 // 000000010FBC: 96BA2B36
	s_mul_i32 s57, s55, s43                                    // 000000010FC0: 96392B37
	s_add_i32 s56, s58, s56                                    // 000000010FC4: 8138383A
	s_mul_i32 s59, s54, s43                                    // 000000010FC8: 963B2B36
	s_add_i32 s56, s56, s57                                    // 000000010FCC: 81383938
	s_mul_hi_u32 s58, s43, s59                                 // 000000010FD0: 96BA3B2B
	s_mul_i32 s61, s43, s56                                    // 000000010FD4: 963D382B
	s_mul_hi_u32 s60, s0, s59                                  // 000000010FD8: 96BC3B00
	s_mul_i32 s57, s0, s59                                     // 000000010FDC: 96393B00
	s_mul_hi_u32 s59, s43, s56                                 // 000000010FE0: 96BB382B
	s_add_u32 s58, s58, s61                                    // 000000010FE4: 803A3D3A
	s_addc_u32 s59, 0, s59                                     // 000000010FE8: 823B3B80
	s_mul_hi_u32 s62, s0, s56                                  // 000000010FEC: 96BE3800
	s_add_u32 s57, s58, s57                                    // 000000010FF0: 8039393A
	s_mul_i32 s56, s0, s56                                     // 000000010FF4: 96383800
	s_addc_u32 s57, s59, s60                                   // 000000010FF8: 82393C3B
	s_addc_u32 s58, s62, 0                                     // 000000010FFC: 823A803E
	s_add_u32 s56, s57, s56                                    // 000000011000: 80383839
	s_addc_u32 s57, 0, s58                                     // 000000011004: 82393A80
	s_add_u32 s43, s43, s56                                    // 000000011008: 802B382B
	s_cselect_b32 s56, -1, 0                                   // 00000001100C: 983880C1
	s_mul_hi_u32 s58, s54, s43                                 // 000000011010: 96BA2B36
	s_cmp_lg_u32 s56, 0                                        // 000000011014: BF078038
	s_mul_i32 s56, s54, s43                                    // 000000011018: 96382B36
	s_addc_u32 s0, s0, s57                                     // 00000001101C: 82003900
	s_mul_i32 s55, s55, s43                                    // 000000011020: 96372B37
	s_mul_i32 s54, s54, s0                                     // 000000011024: 96360036
	s_mul_hi_u32 s57, s43, s56                                 // 000000011028: 96B9382B
	s_add_i32 s54, s58, s54                                    // 00000001102C: 8136363A
	s_mul_hi_u32 s58, s0, s56                                  // 000000011030: 96BA3800
	s_add_i32 s54, s54, s55                                    // 000000011034: 81363736
	s_mul_i32 s55, s0, s56                                     // 000000011038: 96373800
	s_mul_i32 s60, s43, s54                                    // 00000001103C: 963C362B
	s_mul_hi_u32 s59, s43, s54                                 // 000000011040: 96BB362B
	s_add_u32 s57, s57, s60                                    // 000000011044: 80393C39
	s_addc_u32 s59, 0, s59                                     // 000000011048: 823B3B80
	s_mul_hi_u32 s56, s0, s54                                  // 00000001104C: 96B83600
	s_add_u32 s55, s57, s55                                    // 000000011050: 80373739
	s_mul_i32 s54, s0, s54                                     // 000000011054: 96363600
	s_addc_u32 s55, s59, s58                                   // 000000011058: 82373A3B
	s_addc_u32 s56, s56, 0                                     // 00000001105C: 82388038
	s_add_u32 s54, s55, s54                                    // 000000011060: 80363637
	s_addc_u32 s55, 0, s56                                     // 000000011064: 82373880
	s_add_u32 s43, s43, s54                                    // 000000011068: 802B362B
	s_cselect_b32 s54, -1, 0                                   // 00000001106C: 983680C1
	v_mul_hi_u32 v23, v3, s43                                  // 000000011070: D72D0017 00005703
	s_cmp_lg_u32 s54, 0                                        // 000000011078: BF078036
	v_mad_u64_u32 v[12:13], null, v22, s43, 0                  // 00000001107C: D6FE7C0C 02005716
	s_addc_u32 s0, s0, s55                                     // 000000011084: 82003700
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011088: BF870129
	v_mad_u64_u32 v[10:11], null, v3, s0, 0                    // 00000001108C: D6FE7C0A 02000103
	v_mad_u64_u32 v[19:20], null, v22, s0, 0                   // 000000011094: D6FE7C13 02000116
	v_add_co_u32 v10, vcc_lo, v23, v10                         // 00000001109C: D7006A0A 00021517
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000110A4: BF870111
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo              // 0000000110A8: D5207C0B 01AA1680
	v_add_co_u32 v10, vcc_lo, v10, v12                         // 0000000110B0: D7006A0A 0002190A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000110B8: BF870122
	v_add_co_ci_u32_e32 v10, vcc_lo, v11, v13, vcc_lo          // 0000000110BC: 40141B0B
	v_add_co_ci_u32_e32 v11, vcc_lo, 0, v20, vcc_lo            // 0000000110C0: 40162880
	v_add_co_u32 v12, vcc_lo, v10, v19                         // 0000000110C4: D7006A0C 0002270A
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000110CC: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v11, vcc_lo              // 0000000110D0: D5207C0D 01AA1680
	v_mul_lo_u32 v19, s47, v12                                 // 0000000110D8: D72C0013 0002182F
	v_mad_u64_u32 v[10:11], null, s46, v12, 0                  // 0000000110E0: D6FE7C0A 0202182E
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000110E8: BF870113
	v_mul_lo_u32 v20, s46, v13                                 // 0000000110EC: D72C0014 00021A2E
	v_sub_co_u32 v3, vcc_lo, v3, v10                           // 0000000110F4: D7016A03 00021503
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000110FC: BF870092
	v_add3_u32 v11, v11, v20, v19                              // 000000011100: D655000B 044E290B
	v_sub_nc_u32_e32 v19, v22, v11                             // 000000011108: 4C261716
	v_sub_co_ci_u32_e64 v11, null, v22, v11, vcc_lo            // 00000001110C: D5217C0B 01AA1716
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000011114: BF8700A2
	v_subrev_co_ci_u32_e64 v10, null, s47, v19, vcc_lo         // 000000011118: D5227C0A 01AA262F
	v_add_co_u32 v19, s0, v12, 2                               // 000000011120: D7000013 0001050C
	v_add_co_ci_u32_e64 v20, null, 0, v13, s0                  // 000000011128: D5207C14 00021A80
	v_sub_co_u32 v23, s0, v3, s46                              // 000000011130: D7010017 00005D03
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011138: BF870111
	v_subrev_co_ci_u32_e64 v10, null, 0, v10, s0               // 00000001113C: D5227C0A 00021480
	v_cmp_le_u32_e32 vcc_lo, s46, v23                          // 000000011144: 7C962E2E
	v_cndmask_b32_e64 v22, 0, -1, vcc_lo                       // 000000011148: D5010016 01A98280
	s_delay_alu instid0(VALU_DEP_3)                            // 000000011150: BF870003
	v_cmp_le_u32_e32 vcc_lo, s47, v10                          // 000000011154: 7C96142F
	v_cndmask_b32_e64 v23, 0, -1, vcc_lo                       // 000000011158: D5010017 01A98280
	v_cmp_le_u32_e32 vcc_lo, s46, v3                           // 000000011160: 7C96062E
	v_cndmask_b32_e64 v3, 0, -1, vcc_lo                        // 000000011164: D5010003 01A98280
	v_cmp_le_u32_e32 vcc_lo, s47, v11                          // 00000001116C: 7C96162F
	v_cndmask_b32_e64 v24, 0, -1, vcc_lo                       // 000000011170: D5010018 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s47, v10                          // 000000011178: 7C94142F
	v_cndmask_b32_e32 v10, v23, v22, vcc_lo                    // 00000001117C: 02142D17
	v_add_co_u32 v22, vcc_lo, v12, 1                           // 000000011180: D7006A16 0001030C
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_4) | instid1(VALU_DEP_2)// 000000011188: BF870151
	v_add_co_ci_u32_e64 v23, null, 0, v13, vcc_lo              // 00000001118C: D5207C17 01AA1A80
	v_cmp_eq_u32_e32 vcc_lo, s47, v11                          // 000000011194: 7C94162F
	v_xor_b32_e32 v11, s42, v21                                // 000000011198: 3A162A2A
	v_cndmask_b32_e32 v3, v24, v3, vcc_lo                      // 00000001119C: 02060718
	v_cmp_ne_u32_e32 vcc_lo, 0, v10                            // 0000000111A0: 7C9A1480
	v_cmp_ne_u32_e64 s0, 0, v3                                 // 0000000111A4: D44D0000 00020680
	v_dual_cndmask_b32 v3, v22, v19 :: v_dual_cndmask_b32 v10, v23, v20// 0000000111AC: CA522716 030A2917
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000111B4: BF870111
	v_cndmask_b32_e64 v3, v12, v3, s0                          // 0000000111B8: D5010003 0002070C
	v_cndmask_b32_e64 v10, v13, v10, s0                        // 0000000111C0: D501000A 0002150D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000111C8: BF870112
	v_xor_b32_e32 v3, v3, v11                                  // 0000000111CC: 3A061703
	v_xor_b32_e32 v12, v10, v11                                // 0000000111D0: 3A18170A
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000111D4: BF870092
	v_sub_co_u32 v10, vcc_lo, v3, v11                          // 0000000111D8: D7016A0A 00021703
	v_sub_co_ci_u32_e64 v11, null, v12, v11, vcc_lo            // 0000000111E0: D5217C0B 01AA170C
	s_and_not1_saveexec_b32 s0, s53                            // 0000000111E8: BE803035
	s_cbranch_execz 26                                         // 0000000111EC: BFA5001A <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x858>
	s_sub_i32 s42, 0, s8                                       // 0000000111F0: 81AA0880
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000111F4: BF870099
	v_mul_lo_u32 v3, s42, v17                                  // 0000000111F8: D72C0003 0002222A
	v_mul_hi_u32 v3, v17, v3                                   // 000000011200: D72D0003 00020711
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011208: BF870091
	v_add_nc_u32_e32 v3, v17, v3                               // 00000001120C: 4A060711
	v_mul_hi_u32 v3, v8, v3                                    // 000000011210: D72D0003 00020708
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011218: BF870121
	v_mul_lo_u32 v10, v3, s8                                   // 00000001121C: D72C000A 00001103
	v_add_nc_u32_e32 v11, 1, v3                                // 000000011224: 4A160681
	v_sub_nc_u32_e32 v10, v8, v10                              // 000000011228: 4C141508
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000001122C: BF870121
	v_subrev_nc_u32_e32 v12, s8, v10                           // 000000011230: 4E181408
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 000000011234: 7C961408
	v_dual_cndmask_b32 v10, v10, v12 :: v_dual_cndmask_b32 v3, v3, v11// 000000011238: CA52190A 0A021703
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011240: BF870111
	v_cmp_le_u32_e32 vcc_lo, s8, v10                           // 000000011244: 7C961408
	v_add_nc_u32_e32 v11, 1, v3                                // 000000011248: 4A160681
	s_delay_alu instid0(VALU_DEP_1)                            // 00000001124C: BF870001
	v_dual_cndmask_b32 v10, v3, v11 :: v_dual_mov_b32 v11, v2  // 000000011250: CA501703 0A0A0102
	s_or_b32 exec_lo, exec_lo, s0                              // 000000011258: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 00000001125C: BF870121
	v_lshlrev_b64 v[10:11], 2, v[10:11]                        // 000000011260: D73C000A 00021482
	v_mov_b32_e32 v3, 0                                        // 000000011268: 7E060280
	v_add_co_u32 v12, vcc_lo, s35, v10                         // 00000001126C: D7006A0C 00021423
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)// 000000011274: BF8700C1
	v_add_co_ci_u32_e64 v13, null, s37, v11, vcc_lo            // 000000011278: D5207C0D 01AA1625
	global_load_b32 v12, v[12:13], off                         // 000000011280: DC520000 0C7C000C
	s_waitcnt vmcnt(0)                                         // 000000011288: BF8903F7
	v_ashrrev_i32_e32 v13, 31, v12                             // 00000001128C: 341A189F
	v_cmp_lt_i64_e32 vcc_lo, -1, v[12:13]                      // 000000011290: 7CA218C1
	v_cmp_gt_i64_e64 s0, s[4:5], v[12:13]                      // 000000011294: D4540000 00021804
	s_and_b32 s42, vcc_lo, s0                                  // 00000001129C: 8B2A006A
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000112A0: BF870009
	s_and_saveexec_b32 s0, s42                                 // 0000000112A4: BE80202A
	s_cbranch_execz 65285                                      // 0000000112A8: BFA5FF05 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x4c0>
	v_lshlrev_b64 v[12:13], 2, v[12:13]                        // 0000000112AC: D73C000C 00021882
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000112B4: BF870091
	v_sub_co_u32 v3, vcc_lo, v12, v10                          // 0000000112B8: D7016A03 0002150C
	v_sub_co_ci_u32_e64 v10, null, v13, v11, vcc_lo            // 0000000112C0: D5217C0A 01AA170D
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000112C8: BF870112
	v_mul_lo_u32 v13, s9, v3                                   // 0000000112CC: D72C000D 00020609
	v_mul_lo_u32 v12, s8, v10                                  // 0000000112D4: D72C000C 00021408
	v_mad_u64_u32 v[10:11], null, s8, v3, v[6:7]               // 0000000112DC: D6FE7C0A 041A0608
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000112E4: BF870001
	v_add3_u32 v11, v13, v11, v12                              // 0000000112E8: D655000B 0432170D
	global_load_b32 v3, v[10:11], off                          // 0000000112F0: DC520000 037C000A
	s_branch 65265                                             // 0000000112F8: BFA0FEF1 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x4c0>
	s_or_b32 exec_lo, exec_lo, s1                              // 0000000112FC: 8C7E017E
	s_mul_i32 s0, s44, s15                                     // 000000011300: 96000F2C
	s_mul_hi_u32 s1, s44, s14                                  // 000000011304: 96810E2C
	s_mul_i32 s35, s44, s14                                    // 000000011308: 96230E2C
	s_add_i32 s0, s1, s0                                       // 00000001130C: 81000001
	s_mul_i32 s1, s45, s14                                     // 000000011310: 96010E2D
	s_waitcnt lgkmcnt(0)                                       // 000000011314: BF89FC07
	s_add_i32 s0, s0, s1                                       // 000000011318: 81000100
	s_sub_u32 s1, s40, s35                                     // 00000001131C: 80812328
	s_subb_u32 s0, s41, s0                                     // 000000011320: 82800029
	s_mul_i32 s35, s1, s17                                     // 000000011324: 96231101
	s_mul_hi_u32 s37, s1, s16                                  // 000000011328: 96A51001
	s_mul_i32 s0, s0, s16                                      // 00000001132C: 96001000
	s_add_i32 s35, s37, s35                                    // 000000011330: 81232325
	s_mul_i32 s40, s1, s16                                     // 000000011334: 96281001
	s_add_i32 s41, s35, s0                                     // 000000011338: 81290023
	s_add_u32 s0, s40, s16                                     // 00000001133C: 80001028
	s_addc_u32 s1, s41, s17                                    // 000000011340: 82011129
	s_barrier                                                  // 000000011344: BFBD0000
	v_cmp_lt_i64_e64 s35, s[0:1], s[12:13]                     // 000000011348: D4510023 00001800
	buffer_gl0_inv                                             // 000000011350: E0AC0000 00000000
	s_and_b32 s35, s35, exec_lo                                // 000000011358: 8B237E23
	s_cselect_b32 s43, s1, s13                                 // 00000001135C: 982B0D01
	s_cselect_b32 s42, s0, s12                                 // 000000011360: 982A0C00
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011364: BF870009
	v_cmp_ge_i64_e64 s0, s[40:41], s[42:43]                    // 000000011368: D4560000 00005428
	s_and_b32 vcc_lo, exec_lo, s0                              // 000000011370: 8B6A007E
	s_cbranch_vccnz 65023                                      // 000000011374: BFA4FDFF <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x174>
	s_load_b32 s0, s[20:21], 0xc                               // 000000011378: F400000A F800000C
	s_mul_i32 s46, s44, s13                                    // 000000011380: 962E0D2C
	s_mul_hi_u32 s47, s44, s12                                 // 000000011384: 96AF0C2C
	s_mul_i32 s44, s44, s12                                    // 000000011388: 962C0C2C
	s_waitcnt lgkmcnt(0)                                       // 00000001138C: BF89FC07
	s_and_b32 s1, s0, 0xffff                                   // 000000011390: 8B01FF00 0000FFFF
	s_bfe_u32 s35, s0, 0xf0001                                 // 000000011398: 9323FF00 000F0001
	s_cmp_gt_u32 s1, 1                                         // 0000000113A0: BF088101
	s_mul_i32 s0, s45, s12                                     // 0000000113A4: 96000C2D
	s_cselect_b32 s37, -1, 0                                   // 0000000113A8: 982580C1
	s_add_i32 s45, s47, s46                                    // 0000000113AC: 812D2E2F
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 0000000113B0: BF870499
	s_add_i32 s45, s45, s0                                     // 0000000113B4: 812D002D
	s_lshl_b64 s[44:45], s[44:45], 2                           // 0000000113B8: 84AC822C
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000113BC: BF870009
	s_add_u32 s46, s26, s44                                    // 0000000113C0: 802E2C1A
	s_addc_u32 s47, s27, s45                                   // 0000000113C4: 822F2D1B
	s_lshl_b32 s50, s1, 2                                      // 0000000113C8: 84328201
	s_branch 11                                                // 0000000113CC: BFA0000B <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x9fc>
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000113D0: 8C7E007E
	s_add_u32 s40, s40, 1                                      // 0000000113D4: 80288128
	s_addc_u32 s41, s41, 0                                     // 0000000113D8: 82298029
	s_waitcnt_vscnt null, 0x0                                  // 0000000113DC: BC7C0000
	v_cmp_lt_i64_e64 s0, s[40:41], s[42:43]                    // 0000000113E0: D4510000 00005428
	s_barrier                                                  // 0000000113E8: BFBD0000
	buffer_gl0_inv                                             // 0000000113EC: E0AC0000 00000000
	s_and_b32 vcc_lo, exec_lo, s0                              // 0000000113F4: 8B6A007E
	s_cbranch_vccz 64990                                       // 0000000113F8: BFA3FDDE <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x174>
	v_mov_b32_e32 v10, 0                                       // 0000000113FC: 7E140280
	s_and_saveexec_b32 s51, s3                                 // 000000011400: BEB32003
	s_cbranch_execz 496                                        // 000000011404: BFA501F0 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x11c8>
	s_mul_i32 s0, s40, s9                                      // 000000011408: 96000928
	s_mul_hi_u32 s44, s40, s8                                  // 00000001140C: 96AC0828
	s_mul_i32 s45, s41, s8                                     // 000000011410: 962D0829
	s_add_i32 s0, s44, s0                                      // 000000011414: 8100002C
	s_mul_i32 s44, s40, s8                                     // 000000011418: 962C0828
	s_add_i32 s45, s0, s45                                     // 00000001141C: 812D2D00
	v_dual_mov_b32 v10, 0 :: v_dual_mov_b32 v11, v14           // 000000011420: CA100080 0A0A010E
	s_lshl_b64 s[44:45], s[44:45], 2                           // 000000011428: 84AC822C
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0             // 00000001142C: CA100101 07060100
	s_add_u32 s52, s22, s44                                    // 000000011434: 80342C16
	s_addc_u32 s54, s23, s45                                   // 000000011438: 82362D17
	s_mov_b32 s53, 0                                           // 00000001143C: BEB50080
	s_branch 20                                                // 000000011440: BFA00014 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa94>
	s_or_b32 exec_lo, exec_lo, s45                             // 000000011444: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011448: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000001144C: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011450: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 000000011454: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 000000011458: BF8700A1
	v_dual_mul_f32 v8, v13, v12 :: v_dual_add_nc_u32 v11, s50, v11// 00000001145C: C8E0190D 080A1632
	v_add_co_u32 v6, vcc_lo, v6, s1                            // 000000011464: D7006A06 00000306
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo                // 00000001146C: D5207C07 01AA0E80
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011474: BF870113
	v_fmac_f32_e32 v8, v3, v9                                  // 000000011478: 56101303
	v_cmp_le_i64_e32 vcc_lo, s[10:11], v[6:7]                  // 00000001147C: 7CA60C0A
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(SALU_CYCLE_1)// 000000011480: BF8704A2
	v_add_f32_e32 v10, v10, v8                                 // 000000011484: 0614110A
	s_or_b32 s53, vcc_lo, s53                                  // 000000011488: 8C35356A
	s_and_not1_b32 exec_lo, exec_lo, s53                       // 00000001148C: 917E357E
	s_cbranch_execz 460                                        // 000000011490: BFA501CC <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x11c4>
	v_or_b32_e32 v3, s9, v7                                    // 000000011494: 38060E09
	s_mov_b32 s0, exec_lo                                      // 000000011498: BE80007E
	s_delay_alu instid0(VALU_DEP_1)                            // 00000001149C: BF870001
	v_cmpx_ne_u64_e32 0, v[2:3]                                // 0000000114A0: 7DBA0480
	s_xor_b32 s55, exec_lo, s0                                 // 0000000114A4: 8D37007E
	s_cbranch_execz 178                                        // 0000000114A8: BFA500B2 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xd74>
	s_ashr_i32 s44, s9, 31                                     // 0000000114AC: 862C9F09
	v_ashrrev_i32_e32 v20, 31, v7                              // 0000000114B0: 34280E9F
	s_add_u32 s56, s8, s44                                     // 0000000114B4: 80382C08
	s_mov_b32 s45, s44                                         // 0000000114B8: BEAD002C
	s_addc_u32 s57, s9, s44                                    // 0000000114BC: 82392C09
	s_delay_alu instid0(SALU_CYCLE_1)                          // 0000000114C0: BF870009
	s_xor_b64 s[44:45], s[56:57], s[44:45]                     // 0000000114C4: 8DAC2C38
	v_add_co_u32 v9, vcc_lo, v6, v20                           // 0000000114C8: D7006A09 00022906
	v_cvt_f32_u32_e32 v3, s44                                  // 0000000114D0: 7E060C2C
	v_cvt_f32_u32_e32 v8, s45                                  // 0000000114D4: 7E100C2D
	s_sub_u32 s57, 0, s44                                      // 0000000114D8: 80B92C80
	s_subb_u32 s58, 0, s45                                     // 0000000114DC: 82BA2D80
	v_add_co_ci_u32_e64 v12, null, v7, v20, vcc_lo             // 0000000114E0: D5207C0C 01AA2907
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000114E8: BF870112
	v_fmac_f32_e32 v3, 0x4f800000, v8                          // 0000000114EC: 560610FF 4F800000
	v_xor_b32_e32 v21, v12, v20                                // 0000000114F4: 3A2A290C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000000114F8: BF8700B2
	v_rcp_f32_e32 v3, v3                                       // 0000000114FC: 7E065503
	s_waitcnt_depctr 0xfff                                     // 000000011500: BF880FFF
	v_mul_f32_e32 v3, 0x5f7ffffc, v3                           // 000000011504: 100606FF 5F7FFFFC
	v_mul_f32_e32 v8, 0x2f800000, v3                           // 00000001150C: 101006FF 2F800000
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011514: BF870091
	v_trunc_f32_e32 v8, v8                                     // 000000011518: 7E104308
	v_fmac_f32_e32 v3, 0xcf800000, v8                          // 00000001151C: 560610FF CF800000
	v_cvt_u32_f32_e32 v8, v8                                   // 000000011524: 7E100F08
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011528: BF870112
	v_cvt_u32_f32_e32 v3, v3                                   // 00000001152C: 7E060F03
	v_readfirstlane_b32 s0, v8                                 // 000000011530: 7E000508
	s_delay_alu instid0(VALU_DEP_2)                            // 000000011534: BF870002
	v_readfirstlane_b32 s56, v3                                // 000000011538: 7E700503
	s_mul_i32 s59, s57, s0                                     // 00000001153C: 963B0039
	v_xor_b32_e32 v3, v9, v20                                  // 000000011540: 3A062909
	s_mul_hi_u32 s61, s57, s56                                 // 000000011544: 96BD3839
	s_mul_i32 s60, s58, s56                                    // 000000011548: 963C383A
	s_add_i32 s59, s61, s59                                    // 00000001154C: 813B3B3D
	s_mul_i32 s62, s57, s56                                    // 000000011550: 963E3839
	s_add_i32 s59, s59, s60                                    // 000000011554: 813B3C3B
	s_mul_hi_u32 s61, s56, s62                                 // 000000011558: 96BD3E38
	s_mul_i32 s64, s56, s59                                    // 00000001155C: 96403B38
	s_mul_hi_u32 s63, s0, s62                                  // 000000011560: 96BF3E00
	s_mul_i32 s60, s0, s62                                     // 000000011564: 963C3E00
	s_mul_hi_u32 s62, s56, s59                                 // 000000011568: 96BE3B38
	s_add_u32 s61, s61, s64                                    // 00000001156C: 803D403D
	s_addc_u32 s62, 0, s62                                     // 000000011570: 823E3E80
	s_mul_hi_u32 s65, s0, s59                                  // 000000011574: 96C13B00
	s_add_u32 s60, s61, s60                                    // 000000011578: 803C3C3D
	s_mul_i32 s59, s0, s59                                     // 00000001157C: 963B3B00
	s_addc_u32 s60, s62, s63                                   // 000000011580: 823C3F3E
	s_addc_u32 s61, s65, 0                                     // 000000011584: 823D8041
	s_add_u32 s59, s60, s59                                    // 000000011588: 803B3B3C
	s_addc_u32 s60, 0, s61                                     // 00000001158C: 823C3D80
	s_add_u32 s56, s56, s59                                    // 000000011590: 80383B38
	s_cselect_b32 s59, -1, 0                                   // 000000011594: 983B80C1
	s_mul_hi_u32 s61, s57, s56                                 // 000000011598: 96BD3839
	s_cmp_lg_u32 s59, 0                                        // 00000001159C: BF07803B
	s_mul_i32 s59, s57, s56                                    // 0000000115A0: 963B3839
	s_addc_u32 s0, s0, s60                                     // 0000000115A4: 82003C00
	s_mul_i32 s58, s58, s56                                    // 0000000115A8: 963A383A
	s_mul_i32 s57, s57, s0                                     // 0000000115AC: 96390039
	s_mul_hi_u32 s60, s56, s59                                 // 0000000115B0: 96BC3B38
	s_add_i32 s57, s61, s57                                    // 0000000115B4: 8139393D
	s_mul_hi_u32 s61, s0, s59                                  // 0000000115B8: 96BD3B00
	s_add_i32 s57, s57, s58                                    // 0000000115BC: 81393A39
	s_mul_i32 s58, s0, s59                                     // 0000000115C0: 963A3B00
	s_mul_i32 s63, s56, s57                                    // 0000000115C4: 963F3938
	s_mul_hi_u32 s62, s56, s57                                 // 0000000115C8: 96BE3938
	s_add_u32 s60, s60, s63                                    // 0000000115CC: 803C3F3C
	s_addc_u32 s62, 0, s62                                     // 0000000115D0: 823E3E80
	s_mul_hi_u32 s59, s0, s57                                  // 0000000115D4: 96BB3900
	s_add_u32 s58, s60, s58                                    // 0000000115D8: 803A3A3C
	s_mul_i32 s57, s0, s57                                     // 0000000115DC: 96393900
	s_addc_u32 s58, s62, s61                                   // 0000000115E0: 823A3D3E
	s_addc_u32 s59, s59, 0                                     // 0000000115E4: 823B803B
	s_add_u32 s57, s58, s57                                    // 0000000115E8: 8039393A
	s_addc_u32 s58, 0, s59                                     // 0000000115EC: 823A3B80
	s_add_u32 s56, s56, s57                                    // 0000000115F0: 80383938
	s_cselect_b32 s57, -1, 0                                   // 0000000115F4: 983980C1
	v_mul_hi_u32 v22, v3, s56                                  // 0000000115F8: D72D0016 00007103
	s_cmp_lg_u32 s57, 0                                        // 000000011600: BF078039
	v_mad_u64_u32 v[12:13], null, v21, s56, 0                  // 000000011604: D6FE7C0C 02007115
	s_addc_u32 s0, s0, s58                                     // 00000001160C: 82003A00
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011610: BF870129
	v_mad_u64_u32 v[8:9], null, v3, s0, 0                      // 000000011614: D6FE7C08 02000103
	v_mad_u64_u32 v[18:19], null, v21, s0, 0                   // 00000001161C: D6FE7C12 02000115
	v_add_co_u32 v8, vcc_lo, v22, v8                           // 000000011624: D7006A08 00021116
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 00000001162C: BF870111
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo                // 000000011630: D5207C09 01AA1280
	v_add_co_u32 v8, vcc_lo, v8, v12                           // 000000011638: D7006A08 00021908
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011640: BF870122
	v_add_co_ci_u32_e32 v8, vcc_lo, v9, v13, vcc_lo            // 000000011644: 40101B09
	v_add_co_ci_u32_e32 v9, vcc_lo, 0, v19, vcc_lo             // 000000011648: 40122680
	v_add_co_u32 v12, vcc_lo, v8, v18                          // 00000001164C: D7006A0C 00022508
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011654: BF870111
	v_add_co_ci_u32_e64 v13, null, 0, v9, vcc_lo               // 000000011658: D5207C0D 01AA1280
	v_mul_lo_u32 v18, s45, v12                                 // 000000011660: D72C0012 0002182D
	v_mad_u64_u32 v[8:9], null, s44, v12, 0                    // 000000011668: D6FE7C08 0202182C
	s_delay_alu instid0(VALU_DEP_3) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011670: BF870113
	v_mul_lo_u32 v12, s44, v13                                 // 000000011674: D72C000C 00021A2C
	v_sub_co_u32 v3, vcc_lo, v3, v8                            // 00000001167C: D7016A03 00021103
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011684: BF870112
	v_add3_u32 v9, v9, v12, v18                                // 000000011688: D6550009 044A1909
	v_cmp_le_u32_e64 s0, s44, v3                               // 000000011690: D44B0000 0002062C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 000000011698: BF8701A2
	v_sub_nc_u32_e32 v12, v21, v9                              // 00000001169C: 4C181315
	v_sub_co_ci_u32_e64 v9, null, v21, v9, vcc_lo              // 0000000116A0: D5217C09 01AA1315
	v_cndmask_b32_e64 v18, 0, -1, s0                           // 0000000116A8: D5010012 00018280
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_1)// 0000000116B0: BF8700A3
	v_subrev_co_ci_u32_e64 v8, null, s45, v12, vcc_lo          // 0000000116B4: D5227C08 01AA182D
	v_sub_co_u32 v12, vcc_lo, v3, s44                          // 0000000116BC: D7016A0C 00005903
	v_subrev_co_ci_u32_e64 v13, null, 0, v8, vcc_lo            // 0000000116C4: D5227C0D 01AA1080
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_2) | instid1(VALU_DEP_3)// 0000000116CC: BF8701B2
	v_cmp_le_u32_e64 s0, s44, v12                              // 0000000116D0: D44B0000 0002182C
	v_subrev_co_ci_u32_e64 v8, null, s45, v8, vcc_lo           // 0000000116D8: D5227C08 01AA102D
	v_cmp_le_u32_e32 vcc_lo, s45, v9                           // 0000000116E0: 7C96122D
	v_cndmask_b32_e64 v19, 0, -1, s0                           // 0000000116E4: D5010013 00018280
	v_cmp_le_u32_e64 s0, s45, v13                              // 0000000116EC: D44B0000 00021A2D
	v_cndmask_b32_e64 v22, 0, -1, vcc_lo                       // 0000000116F4: D5010016 01A98280
	v_cmp_eq_u32_e32 vcc_lo, s45, v13                          // 0000000116FC: 7C941A2D
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011700: BF870123
	v_cndmask_b32_e64 v21, 0, -1, s0                           // 000000011704: D5010015 00018280
	v_cmp_eq_u32_e64 s0, s45, v9                               // 00000001170C: D44A0000 0002122D
	v_cndmask_b32_e32 v19, v21, v19, vcc_lo                    // 000000011714: 02262715
	v_sub_co_u32 v21, vcc_lo, v12, s44                         // 000000011718: D7016A15 0000590C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_3)// 000000011720: BF870191
	v_subrev_co_ci_u32_e64 v8, null, 0, v8, vcc_lo             // 000000011724: D5227C08 01AA1080
	v_cmp_ne_u32_e32 vcc_lo, 0, v19                            // 00000001172C: 7C9A2680
	v_cndmask_b32_e64 v18, v22, v18, s0                        // 000000011730: D5010012 00022516
	s_delay_alu instid0(VALU_DEP_3) | instskip(SKIP_1) | instid1(VALU_DEP_3)// 000000011738: BF8701A3
	v_cndmask_b32_e32 v8, v13, v8, vcc_lo                      // 00000001173C: 0210110D
	v_cndmask_b32_e32 v12, v12, v21, vcc_lo                    // 000000011740: 02182B0C
	v_cmp_ne_u32_e32 vcc_lo, 0, v18                            // 000000011744: 7C9A2480
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_4)// 000000011748: BF870212
	v_cndmask_b32_e32 v3, v3, v12, vcc_lo                      // 00000001174C: 02061903
	v_cndmask_b32_e32 v8, v9, v8, vcc_lo                       // 000000011750: 02101109
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011754: BF870112
	v_xor_b32_e32 v3, v3, v20                                  // 000000011758: 3A062903
	v_xor_b32_e32 v9, v8, v20                                  // 00000001175C: 3A122908
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011760: BF870092
	v_sub_co_u32 v8, vcc_lo, v3, v20                           // 000000011764: D7016A08 00022903
	v_sub_co_ci_u32_e64 v9, null, v9, v20, vcc_lo              // 00000001176C: D5217C09 01AA2909
	s_and_not1_saveexec_b32 s0, s55                            // 000000011774: BE803037
	s_cbranch_execz 23                                         // 000000011778: BFA50017 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xdd8>
	s_sub_i32 s44, 0, s8                                       // 00000001177C: 81AC0880
	v_mov_b32_e32 v9, v2                                       // 000000011780: 7E120302
	v_mul_lo_u32 v3, s44, v17                                  // 000000011784: D72C0003 0002222C
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000001178C: BF870091
	v_mul_hi_u32 v3, v17, v3                                   // 000000011790: D72D0003 00020711
	v_add_nc_u32_e32 v3, v17, v3                               // 000000011798: 4A060711
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000001179C: BF870091
	v_mul_hi_u32 v3, v6, v3                                    // 0000000117A0: D72D0003 00020706
	v_mul_lo_u32 v3, v3, s8                                    // 0000000117A8: D72C0003 00001103
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000117B0: BF870091
	v_sub_nc_u32_e32 v3, v6, v3                                // 0000000117B4: 4C060706
	v_subrev_nc_u32_e32 v8, s8, v3                             // 0000000117B8: 4E100608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 0000000117BC: 7C960608
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000117C0: BF870092
	v_cndmask_b32_e32 v3, v3, v8, vcc_lo                       // 0000000117C4: 02061103
	v_subrev_nc_u32_e32 v8, s8, v3                             // 0000000117C8: 4E100608
	v_cmp_le_u32_e32 vcc_lo, s8, v3                            // 0000000117CC: 7C960608
	s_delay_alu instid0(VALU_DEP_2)                            // 0000000117D0: BF870002
	v_cndmask_b32_e32 v8, v3, v8, vcc_lo                       // 0000000117D4: 02101103
	s_or_b32 exec_lo, exec_lo, s0                              // 0000000117D8: 8C7E007E
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_2) | instid1(VALU_DEP_1)// 0000000117DC: BF8700B1
	v_lshlrev_b64 v[8:9], 2, v[8:9]                            // 0000000117E0: D73C0008 00021082
	ds_load_b32 v12, v11                                       // 0000000117E8: D8D80000 0C00000B
	v_add_co_u32 v8, vcc_lo, s52, v8                           // 0000000117F0: D7006A08 00021034
	v_add_co_ci_u32_e64 v9, null, s54, v9, vcc_lo              // 0000000117F8: D5207C09 01AA1236
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011800: 916A1D7E
	global_load_b32 v8, v[8:9], off                            // 000000011804: DC520000 087C0008
	s_waitcnt lgkmcnt(0)                                       // 00000001180C: BF89FC07
	v_lshlrev_b32_e32 v3, 16, v12                              // 000000011810: 30061890
	s_cbranch_vccz 13                                          // 000000011814: BFA3000D <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xe4c>
	s_waitcnt vmcnt(0)                                         // 000000011818: BF8903F7
	v_lshlrev_b32_e32 v9, 16, v8                               // 00000001181C: 30121090
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011820: 916A1D7E
	s_cbranch_vccz 68                                          // 000000011824: BFA30044 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xf38>
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011828: 916A1D7E
	s_cbranch_vccz 123                                         // 00000001182C: BFA3007B <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x101c>
	v_and_b32_e32 v13, 0xffff0000, v12                         // 000000011830: 361A18FF FFFF0000
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011838: 916A1D7E
	s_cbranch_vccz 175                                         // 00000001183C: BFA300AF <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x10fc>
	v_and_b32_e32 v12, 0xffff0000, v8                          // 000000011840: 361810FF FFFF0000
	s_branch 65283                                             // 000000011848: BFA0FF03 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa58>
	v_bfe_u32 v9, v12, 10, 5                                   // 00000001184C: D6100009 0215150C
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011854: BF870122
	v_and_b32_e32 v3, 0x80000000, v3                           // 000000011858: 360606FF 80000000
	s_mov_b32 s0, exec_lo                                      // 000000011860: BE80007E
	v_cmpx_lt_i32_e32 30, v9                                   // 000000011864: 7D82129E
	s_xor_b32 s0, exec_lo, s0                                  // 000000011868: 8D00007E
	v_lshlrev_b32_e32 v9, 13, v12                              // 00000001186C: 3012188D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011870: BF870091
	v_and_b32_e32 v9, 0x7fe000, v9                             // 000000011874: 361212FF 007FE000
	v_or3_b32 v3, v9, v3, 0x7f800000                           // 00000001187C: D6580003 03FE0709 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000011888: BE803000
	s_cbranch_execz 36                                         // 00000001188C: BFA50024 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xf20>
	v_and_b32_e32 v13, 0x3ff, v12                              // 000000011890: 361A18FF 000003FF
	s_mov_b32 s44, exec_lo                                     // 000000011898: BEAC007E
	v_cmpx_ne_u32_e32 0, v9                                    // 00000001189C: 7D9A1280
	s_xor_b32 s44, exec_lo, s44                                // 0000000118A0: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000118A4: BF870092
	v_lshlrev_b32_e32 v13, 13, v13                             // 0000000118A8: 301A1A8D
	v_lshl_or_b32 v9, v9, 23, v13                              // 0000000118AC: D6560009 04352F09
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000118B4: BF870001
	v_add3_u32 v3, v9, v3, 0x38000000                          // 0000000118B8: D6550003 03FE0709 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 0000000118C4: BEAC302C
	s_cbranch_execz 19                                         // 0000000118C8: BFA50013 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xf18>
	s_mov_b32 s45, exec_lo                                     // 0000000118CC: BEAD007E
	v_cmpx_ne_u32_e32 0, v13                                   // 0000000118D0: 7D9A1A80
	s_cbranch_execz 15                                         // 0000000118D4: BFA5000F <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xf14>
	v_clz_i32_u32_e32 v9, v13                                  // 0000000118D8: 7E12730D
	v_or_b32_e32 v3, 0x43000000, v3                            // 0000000118DC: 380606FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000118E4: BF870122
	v_xor_b32_e32 v13, 31, v9                                  // 0000000118E8: 3A1A129F
	v_lshlrev_b32_e32 v9, 23, v9                               // 0000000118EC: 30121297
	v_sub_nc_u32_e32 v13, 9, v13                               // 0000000118F0: 4C1A1A89
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000118F4: BF870112
	v_sub_nc_u32_e32 v3, v3, v9                                // 0000000118F8: 4C061303
	v_lshlrev_b32_e32 v13, v13, v12                            // 0000000118FC: 301A190D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011900: BF870091
	v_lshlrev_b32_e32 v13, 14, v13                             // 000000011904: 301A1A8E
	v_and_or_b32 v3, 0x7fc000, v13, v3                         // 000000011908: D6570003 040E1AFF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 000000011914: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011918: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 00000001191C: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011920: BF870009
	s_or_b32 exec_lo, exec_lo, s0                              // 000000011924: 8C7E007E
	s_waitcnt vmcnt(0)                                         // 000000011928: BF8903F7
	v_lshlrev_b32_e32 v9, 16, v8                               // 00000001192C: 30121090
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011930: 916A1D7E
	s_cbranch_vccnz 65468                                      // 000000011934: BFA4FFBC <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xe28>
	v_bfe_u32 v13, v8, 10, 5                                   // 000000011938: D610000D 02151508
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011940: BF870122
	v_and_b32_e32 v9, 0x80000000, v9                           // 000000011944: 361212FF 80000000
	s_mov_b32 s0, exec_lo                                      // 00000001194C: BE80007E
	v_cmpx_lt_i32_e32 30, v13                                  // 000000011950: 7D821A9E
	s_xor_b32 s0, exec_lo, s0                                  // 000000011954: 8D00007E
	v_lshlrev_b32_e32 v13, 13, v8                              // 000000011958: 301A108D
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 00000001195C: BF870091
	v_and_b32_e32 v13, 0x7fe000, v13                           // 000000011960: 361A1AFF 007FE000
	v_or3_b32 v9, v13, v9, 0x7f800000                          // 000000011968: D6580009 03FE130D 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000011974: BE803000
	s_cbranch_execz 36                                         // 000000011978: BFA50024 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x100c>
	v_and_b32_e32 v18, 0x3ff, v8                               // 00000001197C: 362410FF 000003FF
	s_mov_b32 s44, exec_lo                                     // 000000011984: BEAC007E
	v_cmpx_ne_u32_e32 0, v13                                   // 000000011988: 7D9A1A80
	s_xor_b32 s44, exec_lo, s44                                // 00000001198C: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011990: BF870092
	v_lshlrev_b32_e32 v18, 13, v18                             // 000000011994: 3024248D
	v_lshl_or_b32 v13, v13, 23, v18                            // 000000011998: D656000D 04492F0D
	s_delay_alu instid0(VALU_DEP_1)                            // 0000000119A0: BF870001
	v_add3_u32 v9, v13, v9, 0x38000000                         // 0000000119A4: D6550009 03FE130D 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 0000000119B0: BEAC302C
	s_cbranch_execz 19                                         // 0000000119B4: BFA50013 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x1004>
	s_mov_b32 s45, exec_lo                                     // 0000000119B8: BEAD007E
	v_cmpx_ne_u32_e32 0, v18                                   // 0000000119BC: 7D9A2480
	s_cbranch_execz 15                                         // 0000000119C0: BFA5000F <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x1000>
	v_clz_i32_u32_e32 v13, v18                                 // 0000000119C4: 7E1A7312
	v_or_b32_e32 v9, 0x43000000, v9                            // 0000000119C8: 381212FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 0000000119D0: BF870122
	v_xor_b32_e32 v18, 31, v13                                 // 0000000119D4: 3A241A9F
	v_lshlrev_b32_e32 v13, 23, v13                             // 0000000119D8: 301A1A97
	v_sub_nc_u32_e32 v18, 9, v18                               // 0000000119DC: 4C242489
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 0000000119E0: BF870112
	v_sub_nc_u32_e32 v9, v9, v13                               // 0000000119E4: 4C121B09
	v_lshlrev_b32_e32 v18, v18, v8                             // 0000000119E8: 30241112
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 0000000119EC: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 0000000119F0: 3024248E
	v_and_or_b32 v9, 0x7fc000, v18, v9                         // 0000000119F4: D6570009 042624FF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 000000011A00: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011A04: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 000000011A08: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000011A0C: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 000000011A10: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011A14: 916A1D7E
	s_cbranch_vccnz 65413                                      // 000000011A18: BFA4FF85 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xe30>
	v_bfe_u32 v19, v12, 26, 5                                  // 000000011A1C: D6100013 0215350C
	v_and_b32_e32 v13, 0x80000000, v12                         // 000000011A24: 361A18FF 80000000
	v_mov_b16_e32 v18.h, 0                                     // 000000011A2C: 7F243880
	v_mov_b16_e32 v18.l, v12.h                                 // 000000011A30: 7E24398C
	s_mov_b32 s0, exec_lo                                      // 000000011A34: BE80007E
	v_cmpx_lt_i32_e32 30, v19                                  // 000000011A38: 7D82269E
	s_xor_b32 s0, exec_lo, s0                                  // 000000011A3C: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011A40: BF870092
	v_lshlrev_b32_e32 v12, 13, v18                             // 000000011A44: 3018248D
	v_or3_b32 v13, v12, v13, 0x7f800000                        // 000000011A48: D658000D 03FE1B0C 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000011A54: BE803000
	s_cbranch_execz 36                                         // 000000011A58: BFA50024 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x10ec>
	v_bfe_u32 v12, v12, 16, 10                                 // 000000011A5C: D610000C 0229210C
	s_mov_b32 s44, exec_lo                                     // 000000011A64: BEAC007E
	v_cmpx_ne_u32_e32 0, v19                                   // 000000011A68: 7D9A2680
	s_xor_b32 s44, exec_lo, s44                                // 000000011A6C: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011A70: BF870092
	v_lshlrev_b32_e32 v12, 13, v12                             // 000000011A74: 3018188D
	v_lshl_or_b32 v12, v19, 23, v12                            // 000000011A78: D656000C 04312F13
	s_delay_alu instid0(VALU_DEP_1)                            // 000000011A80: BF870001
	v_add3_u32 v13, v12, v13, 0x38000000                       // 000000011A84: D655000D 03FE1B0C 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 000000011A90: BEAC302C
	s_cbranch_execz 19                                         // 000000011A94: BFA50013 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x10e4>
	s_mov_b32 s45, exec_lo                                     // 000000011A98: BEAD007E
	v_cmpx_ne_u32_e32 0, v12                                   // 000000011A9C: 7D9A1880
	s_cbranch_execz 15                                         // 000000011AA0: BFA5000F <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x10e0>
	v_clz_i32_u32_e32 v12, v12                                 // 000000011AA4: 7E18730C
	v_or_b32_e32 v13, 0x43000000, v13                          // 000000011AA8: 381A1AFF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011AB0: BF870122
	v_xor_b32_e32 v19, 31, v12                                 // 000000011AB4: 3A26189F
	v_lshlrev_b32_e32 v12, 23, v12                             // 000000011AB8: 30181897
	v_sub_nc_u32_e32 v19, 9, v19                               // 000000011ABC: 4C262689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011AC0: BF870112
	v_sub_nc_u32_e32 v12, v13, v12                             // 000000011AC4: 4C18190D
	v_lshlrev_b32_e32 v18, v19, v18                            // 000000011AC8: 30242513
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011ACC: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 000000011AD0: 3024248E
	v_and_or_b32 v13, 0x7fc000, v18, v12                       // 000000011AD4: D657000D 043224FF 007FC000
	s_or_b32 exec_lo, exec_lo, s45                             // 000000011AE0: 8C7E2D7E
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011AE4: BF870009
	s_or_b32 exec_lo, exec_lo, s44                             // 000000011AE8: 8C7E2C7E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000011AEC: BF870499
	s_or_b32 exec_lo, exec_lo, s0                              // 000000011AF0: 8C7E007E
	s_and_not1_b32 vcc_lo, exec_lo, s29                        // 000000011AF4: 916A1D7E
	s_cbranch_vccnz 65361                                      // 000000011AF8: BFA4FF51 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xe40>
	v_bfe_u32 v19, v8, 26, 5                                   // 000000011AFC: D6100013 02153508
	v_and_b32_e32 v12, 0x80000000, v8                          // 000000011B04: 361810FF 80000000
	v_mov_b16_e32 v18.h, 0                                     // 000000011B0C: 7F243880
	v_mov_b16_e32 v18.l, v8.h                                  // 000000011B10: 7E243988
	s_mov_b32 s0, exec_lo                                      // 000000011B14: BE80007E
	v_cmpx_lt_i32_e32 30, v19                                  // 000000011B18: 7D82269E
	s_xor_b32 s0, exec_lo, s0                                  // 000000011B1C: 8D00007E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011B20: BF870092
	v_lshlrev_b32_e32 v8, 13, v18                              // 000000011B24: 3010248D
	v_or3_b32 v12, v8, v12, 0x7f800000                         // 000000011B28: D658000C 03FE1908 7F800000
	s_and_not1_saveexec_b32 s0, s0                             // 000000011B34: BE803000
	s_cbranch_execz 65093                                      // 000000011B38: BFA5FE45 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa50>
	v_bfe_u32 v8, v8, 16, 10                                   // 000000011B3C: D6100008 02292108
	s_mov_b32 s44, exec_lo                                     // 000000011B44: BEAC007E
	v_cmpx_ne_u32_e32 0, v19                                   // 000000011B48: 7D9A2680
	s_xor_b32 s44, exec_lo, s44                                // 000000011B4C: 8D2C2C7E
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011B50: BF870092
	v_lshlrev_b32_e32 v8, 13, v8                               // 000000011B54: 3010108D
	v_lshl_or_b32 v8, v19, 23, v8                              // 000000011B58: D6560008 04212F13
	s_delay_alu instid0(VALU_DEP_1)                            // 000000011B60: BF870001
	v_add3_u32 v12, v8, v12, 0x38000000                        // 000000011B64: D655000C 03FE1908 38000000
	s_and_not1_saveexec_b32 s44, s44                           // 000000011B70: BEAC302C
	s_cbranch_execz 65076                                      // 000000011B74: BFA5FE34 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa48>
	s_mov_b32 s45, exec_lo                                     // 000000011B78: BEAD007E
	v_cmpx_ne_u32_e32 0, v8                                    // 000000011B7C: 7D9A1080
	s_cbranch_execz 65072                                      // 000000011B80: BFA5FE30 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa44>
	v_clz_i32_u32_e32 v8, v8                                   // 000000011B84: 7E107308
	v_or_b32_e32 v12, 0x43000000, v12                          // 000000011B88: 381818FF 43000000
	s_delay_alu instid0(VALU_DEP_2) | instskip(SKIP_1) | instid1(VALU_DEP_2)// 000000011B90: BF870122
	v_xor_b32_e32 v19, 31, v8                                  // 000000011B94: 3A26109F
	v_lshlrev_b32_e32 v8, 23, v8                               // 000000011B98: 30101097
	v_sub_nc_u32_e32 v19, 9, v19                               // 000000011B9C: 4C262689
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)// 000000011BA0: BF870112
	v_sub_nc_u32_e32 v8, v12, v8                               // 000000011BA4: 4C10110C
	v_lshlrev_b32_e32 v18, v19, v18                            // 000000011BA8: 30242513
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)// 000000011BAC: BF870091
	v_lshlrev_b32_e32 v18, 14, v18                             // 000000011BB0: 3024248E
	v_and_or_b32 v12, 0x7fc000, v18, v8                        // 000000011BB4: D657000C 042224FF 007FC000
	s_branch 65056                                             // 000000011BC0: BFA0FE20 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0xa44>
	s_or_b32 exec_lo, exec_lo, s53                             // 000000011BC4: 8C7E357E
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)// 000000011BC8: BF870499
	s_or_b32 exec_lo, exec_lo, s51                             // 000000011BCC: 8C7E337E
	s_and_not1_b32 vcc_lo, exec_lo, s37                        // 000000011BD0: 916A257E
	s_mov_b32 s0, s35                                          // 000000011BD4: BE800023
	ds_store_b32 v15, v10                                      // 000000011BD8: D8340000 00000A0F
	s_waitcnt lgkmcnt(0)                                       // 000000011BE0: BF89FC07
	s_barrier                                                  // 000000011BE4: BFBD0000
	buffer_gl0_inv                                             // 000000011BE8: E0AC0000 00000000
	s_cbranch_vccz 28                                          // 000000011BF0: BFA3001C <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x1264>
	s_and_saveexec_b32 s0, s2                                  // 000000011BF4: BE802002
	s_cbranch_execz 65013                                      // 000000011BF8: BFA5FDF5 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x9d0>
	v_mov_b32_e32 v3, s33                                      // 000000011BFC: 7E060221
	s_lshl_b64 s[44:45], s[40:41], 2                           // 000000011C00: 84AC8228
	s_delay_alu instid0(SALU_CYCLE_1)                          // 000000011C04: BF870009
	s_add_u32 s44, s46, s44                                    // 000000011C08: 802C2C2E
	s_addc_u32 s45, s47, s45                                   // 000000011C0C: 822D2D2F
	ds_load_b32 v3, v3                                         // 000000011C10: D8D80000 03000003
	s_waitcnt lgkmcnt(0)                                       // 000000011C18: BF89FC07
	global_store_b32 v2, v3, s[44:45]                          // 000000011C1C: DC6A0000 002C0302
	s_branch 65002                                             // 000000011C24: BFA0FDEA <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x9d0>
	s_nop 0                                                    // 000000011C28: BF800000
	s_nop 0                                                    // 000000011C2C: BF800000
	s_nop 0                                                    // 000000011C30: BF800000
	s_nop 0                                                    // 000000011C34: BF800000
	s_nop 0                                                    // 000000011C38: BF800000
	s_nop 0                                                    // 000000011C3C: BF800000
	s_or_b32 exec_lo, exec_lo, s44                             // 000000011C40: 8C7E2C7E
	s_lshr_b32 s44, s0, 1                                      // 000000011C44: 852C8100
	s_cmp_lt_u32 s0, 2                                         // 000000011C48: BF0A8200
	s_mov_b32 s0, s44                                          // 000000011C4C: BE80002C
	s_waitcnt lgkmcnt(0)                                       // 000000011C50: BF89FC07
	s_barrier                                                  // 000000011C54: BFBD0000
	buffer_gl0_inv                                             // 000000011C58: E0AC0000 00000000
	s_cbranch_scc1 65508                                       // 000000011C60: BFA2FFE4 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x11f4>
	s_mov_b32 s44, exec_lo                                     // 000000011C64: BEAC007E
	v_cmpx_gt_u32_e64 s0, v0                                   // 000000011C68: D4CC007E 00020000
	s_cbranch_execz 65523                                      // 000000011C70: BFA5FFF3 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x1240>
	v_lshl_add_u32 v3, s0, 2, v15                              // 000000011C74: D6460003 043D0400
	ds_load_b32 v3, v3                                         // 000000011C7C: D8D80000 03000003
	ds_load_b32 v6, v15                                        // 000000011C84: D8D80000 0600000F
	s_waitcnt lgkmcnt(0)                                       // 000000011C8C: BF89FC07
	v_add_f32_e32 v3, v3, v6                                   // 000000011C90: 06060D03
	ds_store_b32 v15, v3                                       // 000000011C94: D8340000 0000030F
	s_branch 65512                                             // 000000011C9C: BFA0FFE8 <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x1240>
	s_branch 64602                                             // 000000011CA0: BFA0FC5A <_ZN12_GLOBAL__N_135graph_persistent_lds_chunked_kernelEPKjS1_PKiPfPillllllllii+0x40c>
	s_endpgm                                                   // 000000011CA4: BFB00000
