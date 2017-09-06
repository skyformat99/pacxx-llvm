; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -verify-machineinstrs | FileCheck %s

target triple = "x86_64-unknown-unknown"

@g64 = external global i64, align 8
@g32 = external global i32, align 4
@g16 = external global i16, align 2
@g8 = external global i8, align 1

declare void @a()
declare void @b()

define void @add64_imm_br() nounwind {
; CHECK-LABEL: add64_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    addq %rax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB0_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB0_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i64, i64* @g64
  %add = add nsw i64 %load1, 42
  store i64 %add, i64* @g64
  %cond = icmp slt i64 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add32_imm_br() nounwind {
; CHECK-LABEL: add32_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    addl %eax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB1_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB1_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i32, i32* @g32
  %add = add nsw i32 %load1, 42
  store i32 %add, i32* @g32
  %cond = icmp slt i32 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add16_imm_br() nounwind {
; CHECK-LABEL: add16_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movw $42, %ax
; CHECK-NEXT:    addw %ax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB2_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB2_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i16, i16* @g16
  %add = add nsw i16 %load1, 42
  store i16 %add, i16* @g16
  %cond = icmp slt i16 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add8_imm_br() nounwind {
; CHECK-LABEL: add8_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movb $42, %al
; CHECK-NEXT:    addb %al, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB3_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB3_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i8, i8* @g8
  %add = add nsw i8 %load1, 42
  store i8 %add, i8* @g8
  %cond = icmp slt i8 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add64_reg_br(i64 %arg) nounwind {
; CHECK-LABEL: add64_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    addq %rdi, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB4_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB4_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i64, i64* @g64
  %add = add nsw i64 %load1, %arg
  store i64 %add, i64* @g64
  %cond = icmp slt i64 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add32_reg_br(i32 %arg) nounwind {
; CHECK-LABEL: add32_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    addl %edi, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB5_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB5_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i32, i32* @g32
  %add = add nsw i32 %load1, %arg
  store i32 %add, i32* @g32
  %cond = icmp slt i32 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add16_reg_br(i16 %arg) nounwind {
; CHECK-LABEL: add16_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    addw %di, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB6_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB6_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i16, i16* @g16
  %add = add nsw i16 %load1, %arg
  store i16 %add, i16* @g16
  %cond = icmp slt i16 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @add8_reg_br(i8 %arg) nounwind {
; CHECK-LABEL: add8_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    addb %dil, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB7_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB7_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i8, i8* @g8
  %add = add nsw i8 %load1, %arg
  store i8 %add, i8* @g8
  %cond = icmp slt i8 %add, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub64_imm_br() nounwind {
; CHECK-LABEL: sub64_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movq $-42, %rax
; CHECK-NEXT:    addq %rax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB8_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB8_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i64, i64* @g64
  %sub = sub nsw i64 %load1, 42
  store i64 %sub, i64* @g64
  %cond = icmp slt i64 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub32_imm_br() nounwind {
; CHECK-LABEL: sub32_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movl $-42, %eax
; CHECK-NEXT:    addl %eax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB9_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB9_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i32, i32* @g32
  %sub = sub nsw i32 %load1, 42
  store i32 %sub, i32* @g32
  %cond = icmp slt i32 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub16_imm_br() nounwind {
; CHECK-LABEL: sub16_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movw $-42, %ax
; CHECK-NEXT:    addw %ax, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB10_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB10_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i16, i16* @g16
  %sub = sub nsw i16 %load1, 42
  store i16 %sub, i16* @g16
  %cond = icmp slt i16 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub8_imm_br() nounwind {
; CHECK-LABEL: sub8_imm_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movb $-42, %al
; CHECK-NEXT:    addb %al, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB11_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB11_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i8, i8* @g8
  %sub = sub nsw i8 %load1, 42
  store i8 %sub, i8* @g8
  %cond = icmp slt i8 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub64_reg_br(i64 %arg) nounwind {
; CHECK-LABEL: sub64_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    subq %rdi, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB12_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB12_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i64, i64* @g64
  %sub = sub nsw i64 %load1, %arg
  store i64 %sub, i64* @g64
  %cond = icmp slt i64 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub32_reg_br(i32 %arg) nounwind {
; CHECK-LABEL: sub32_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    subl %edi, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB13_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB13_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i32, i32* @g32
  %sub = sub nsw i32 %load1, %arg
  store i32 %sub, i32* @g32
  %cond = icmp slt i32 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub16_reg_br(i16 %arg) nounwind {
; CHECK-LABEL: sub16_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    subw %di, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB14_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB14_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i16, i16* @g16
  %sub = sub nsw i16 %load1, %arg
  store i16 %sub, i16* @g16
  %cond = icmp slt i16 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}

define void @sub8_reg_br(i8 %arg) nounwind {
; CHECK-LABEL: sub8_reg_br:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    subb %dil, {{.*}}(%rip)
; CHECK-NEXT:    js .LBB15_1
; CHECK-NEXT:  # BB#2: # %b
; CHECK-NEXT:    jmp b # TAILCALL
; CHECK-NEXT:  .LBB15_1: # %a
; CHECK-NEXT:    jmp a # TAILCALL
entry:
  %load1 = load i8, i8* @g8
  %sub = sub nsw i8 %load1, %arg
  store i8 %sub, i8* @g8
  %cond = icmp slt i8 %sub, 0
  br i1 %cond, label %a, label %b

a:
  tail call void @a()
  ret void

b:
  tail call void @b()
  ret void
}
