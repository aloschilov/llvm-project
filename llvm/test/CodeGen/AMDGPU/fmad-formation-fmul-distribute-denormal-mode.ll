; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn -mcpu=tahiti -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=FMA %s
; RUN: llc -mtriple=amdgcn -mcpu=verde -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=NOFUSE %s
; RUN: llc -mtriple=amdgcn -mcpu=fiji -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=NOFUSE %s
; RUN: llc -mtriple=amdgcn -mcpu=tonga -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=NOFUSE %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=FMA %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1010 -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=FMAGFX10 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -amdgpu-enable-delay-alu=0 -denormal-fp-math-f32=ieee < %s | FileCheck --check-prefix=FMAGFX11 %s

; RUN: llc -mtriple=amdgcn -mcpu=tahiti -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAD %s
; RUN: llc -mtriple=amdgcn -mcpu=verde -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAD %s
; RUN: llc -mtriple=amdgcn -mcpu=fiji -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAD %s
; RUN: llc -mtriple=amdgcn -mcpu=tonga -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAD %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx900 -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAD %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1010 -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMADGFX10 %s
; RUN: llc -mtriple=amdgcn -mcpu=gfx1100 -amdgpu-enable-delay-alu=0 -denormal-fp-math-f32=preserve-sign < %s | FileCheck --check-prefix=FMAGFX11 %s

; Check for incorrect fmad formation when distributing

define float @unsafe_fmul_fadd_distribute_fast_f32(float %arg0, float %arg1) #0 {
; FMA-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, v1, v0, v0
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_add_f32_e32 v1, 1.0, v1
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v0, v1
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fmac_f32_e32 v0, v1, v0
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_fmac_f32_e32 v0, v1, v0
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mac_f32_e32 v0, v1, v0
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fmul_fadd_distribute_fast_f32:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_fmac_f32_e32 v0, v1, v0
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %add = fadd fast float %arg1, 1.0
  %tmp1 = fmul fast float %arg0, %add
  ret float %tmp1
}

define float @unsafe_fmul_fsub_distribute_fast_f32(float %arg0, float %arg1) #0 {
; FMA-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, -v1, v0, v0
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_sub_f32_e32 v1, 1.0, v1
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v0, v1
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fma_f32 v0, -v1, v0, v0
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_fma_f32 v0, -v1, v0, v0
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mad_f32 v0, -v1, v0, v0
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fmul_fsub_distribute_fast_f32:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_fma_f32 v0, -v1, v0, v0
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %add = fsub fast float 1.0, %arg1
  %tmp1 = fmul fast float %arg0, %add
  ret float %tmp1
}

define <2 x float> @unsafe_fmul_fadd_distribute_fast_v2f32(<2 x float> %arg0, <2 x float> %arg1) #0 {
; FMA-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, v2, v0, v0
; FMA-NEXT:    v_fma_f32 v1, v3, v1, v1
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_add_f32_e32 v3, 1.0, v3
; NOFUSE-NEXT:    v_add_f32_e32 v2, 1.0, v2
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v0, v2
; NOFUSE-NEXT:    v_mul_f32_e32 v1, v1, v3
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fmac_f32_e32 v0, v2, v0
; FMAGFX10-NEXT:    v_fmac_f32_e32 v1, v3, v1
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_dual_fmac_f32 v0, v2, v0 :: v_dual_fmac_f32 v1, v3, v1
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mac_f32_e32 v0, v2, v0
; FMAD-NEXT:    v_mac_f32_e32 v1, v3, v1
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fmul_fadd_distribute_fast_v2f32:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_fmac_f32_e32 v0, v2, v0
; FMADGFX10-NEXT:    v_fmac_f32_e32 v1, v3, v1
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %add = fadd fast <2 x float> %arg1, <float 1.0, float 1.0>
  %tmp1 = fmul fast <2 x float> %arg0, %add
  ret <2 x float> %tmp1
}

define <2 x float> @unsafe_fmul_fsub_distribute_fast_v2f32(<2 x float> %arg0, <2 x float> %arg1) #0 {
; FMA-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, -v2, v0, v0
; FMA-NEXT:    v_fma_f32 v1, -v3, v1, v1
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_sub_f32_e32 v3, 1.0, v3
; NOFUSE-NEXT:    v_sub_f32_e32 v2, 1.0, v2
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v0, v2
; NOFUSE-NEXT:    v_mul_f32_e32 v1, v1, v3
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fma_f32 v0, -v2, v0, v0
; FMAGFX10-NEXT:    v_fma_f32 v1, -v3, v1, v1
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_fma_f32 v0, -v2, v0, v0
; FMAGFX11-NEXT:    v_fma_f32 v1, -v3, v1, v1
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mad_f32 v0, -v2, v0, v0
; FMAD-NEXT:    v_mad_f32 v1, -v3, v1, v1
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fmul_fsub_distribute_fast_v2f32:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_fma_f32 v0, -v2, v0, v0
; FMADGFX10-NEXT:    v_fma_f32 v1, -v3, v1, v1
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %add = fsub  fast <2 x float> <float 1.0, float 1.0>, %arg1
  %tmp1 = fmul fast <2 x float> %arg0, %add
  ret <2 x float> %tmp1
}

define <2 x float> @unsafe_fast_fmul_fadd_distribute_post_legalize_f32(float %arg0, <2 x float> %arg1) #0 {
; FMA-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, v0, v1, v1
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_add_f32_e32 v0, 1.0, v0
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v1, v0
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fma_f32 v0, v0, v1, v1
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_fma_f32 v0, v0, v1, v1
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mad_f32 v0, v0, v1, v1
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fast_fmul_fadd_distribute_post_legalize_f32:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_mad_f32 v0, v0, v1, v1
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %add = fadd fast float %arg0, 1.0
  %splat = insertelement <2 x float> poison, float %add, i32 0
  %tmp1 = fmul fast <2 x float> %arg1, %splat
  ret <2 x float> %tmp1
}

define <2 x float> @unsafe_fast_fmul_fsub_ditribute_post_legalize(float %arg0, <2 x float> %arg1) #0 {
; FMA-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; FMA:       ; %bb.0:
; FMA-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMA-NEXT:    v_fma_f32 v0, -v0, v1, v1
; FMA-NEXT:    s_setpc_b64 s[30:31]
;
; NOFUSE-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; NOFUSE:       ; %bb.0:
; NOFUSE-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; NOFUSE-NEXT:    v_sub_f32_e32 v0, 1.0, v0
; NOFUSE-NEXT:    v_mul_f32_e32 v0, v1, v0
; NOFUSE-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX10-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; FMAGFX10:       ; %bb.0:
; FMAGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX10-NEXT:    v_fma_f32 v0, -v0, v1, v1
; FMAGFX10-NEXT:    s_setpc_b64 s[30:31]
;
; FMAGFX11-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; FMAGFX11:       ; %bb.0:
; FMAGFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAGFX11-NEXT:    v_fma_f32 v0, -v0, v1, v1
; FMAGFX11-NEXT:    s_setpc_b64 s[30:31]
;
; FMAD-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; FMAD:       ; %bb.0:
; FMAD-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMAD-NEXT:    v_mad_f32 v0, -v0, v1, v1
; FMAD-NEXT:    s_setpc_b64 s[30:31]
;
; FMADGFX10-LABEL: unsafe_fast_fmul_fsub_ditribute_post_legalize:
; FMADGFX10:       ; %bb.0:
; FMADGFX10-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; FMADGFX10-NEXT:    v_mad_f32 v0, -v0, v1, v1
; FMADGFX10-NEXT:    s_setpc_b64 s[30:31]
  %sub = fsub fast float 1.0, %arg0
  %splat = insertelement <2 x float> poison, float %sub, i32 0
  %tmp1 = fmul fast <2 x float> %arg1, %splat
  ret <2 x float> %tmp1
}

attributes #0 = { "no-infs-fp-math"="true" "unsafe-fp-math"="true" }
