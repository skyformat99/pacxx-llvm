; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=i386-linux-gnu %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK32
; RUN: llc -mtriple=x86_64-linux-gnu -mattr=+sahf %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK64

; TODO: Reenable verify-machineinstrs once the if (!AXDead) // FIXME in
; X86InstrInfo::copyPhysReg() is resolved.

; The peephole optimizer can elide some physical register copies such as
; EFLAGS. Make sure the flags are used directly, instead of needlessly using
; lahf, when possible.

@L = external global i32
@M = external global i8

declare i32 @bar(i64)

define i1 @plus_one() nounwind {
; CHECK32-LABEL: plus_one:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    movb M, %al
; CHECK32-NEXT:    incl L
; CHECK32-NEXT:    jne .LBB0_2
; CHECK32-NEXT:  # BB#1: # %entry
; CHECK32-NEXT:    andb $8, %al
; CHECK32-NEXT:    je .LBB0_2
; CHECK32-NEXT:  # BB#3: # %exit2
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:    retl
; CHECK32-NEXT:  .LBB0_2: # %exit
; CHECK32-NEXT:    movb $1, %al
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: plus_one:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    movb {{.*}}(%rip), %al
; CHECK64-NEXT:    incl {{.*}}(%rip)
; CHECK64-NEXT:    jne .LBB0_2
; CHECK64-NEXT:  # BB#1: # %entry
; CHECK64-NEXT:    andb $8, %al
; CHECK64-NEXT:    je .LBB0_2
; CHECK64-NEXT:  # BB#3: # %exit2
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:    retq
; CHECK64-NEXT:  .LBB0_2: # %exit
; CHECK64-NEXT:    movb $1, %al
; CHECK64-NEXT:    retq
entry:
  %loaded_L = load i32, i32* @L
  %val = add nsw i32 %loaded_L, 1 ; N.B. will emit inc.
  store i32 %val, i32* @L
  %loaded_M = load i8, i8* @M
  %masked = and i8 %loaded_M, 8
  %M_is_true = icmp ne i8 %masked, 0
  %L_is_false = icmp eq i32 %val, 0
  %cond = and i1 %L_is_false, %M_is_true
  br i1 %cond, label %exit2, label %exit

exit:
  ret i1 true

exit2:
  ret i1 false
}

define i1 @plus_forty_two() nounwind {
; CHECK32-LABEL: plus_forty_two:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    movb M, %al
; CHECK32-NEXT:    movl $42, %ecx
; CHECK32-NEXT:    addl %ecx, L
; CHECK32-NEXT:    jne .LBB1_2
; CHECK32-NEXT:  # BB#1: # %entry
; CHECK32-NEXT:    andb $8, %al
; CHECK32-NEXT:    je .LBB1_2
; CHECK32-NEXT:  # BB#3: # %exit2
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:    retl
; CHECK32-NEXT:  .LBB1_2: # %exit
; CHECK32-NEXT:    movb $1, %al
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: plus_forty_two:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    movb {{.*}}(%rip), %al
; CHECK64-NEXT:    movl $42, %ecx
; CHECK64-NEXT:    addl %ecx, {{.*}}(%rip)
; CHECK64-NEXT:    jne .LBB1_2
; CHECK64-NEXT:  # BB#1: # %entry
; CHECK64-NEXT:    andb $8, %al
; CHECK64-NEXT:    je .LBB1_2
; CHECK64-NEXT:  # BB#3: # %exit2
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:    retq
; CHECK64-NEXT:  .LBB1_2: # %exit
; CHECK64-NEXT:    movb $1, %al
; CHECK64-NEXT:    retq
entry:
  %loaded_L = load i32, i32* @L
  %val = add nsw i32 %loaded_L, 42 ; N.B. won't emit inc.
  store i32 %val, i32* @L
  %loaded_M = load i8, i8* @M
  %masked = and i8 %loaded_M, 8
  %M_is_true = icmp ne i8 %masked, 0
  %L_is_false = icmp eq i32 %val, 0
  %cond = and i1 %L_is_false, %M_is_true
  br i1 %cond, label %exit2, label %exit

exit:
  ret i1 true

exit2:
  ret i1 false
}

define i1 @minus_one() nounwind {
; CHECK32-LABEL: minus_one:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    movb M, %al
; CHECK32-NEXT:    decl L
; CHECK32-NEXT:    jne .LBB2_2
; CHECK32-NEXT:  # BB#1: # %entry
; CHECK32-NEXT:    andb $8, %al
; CHECK32-NEXT:    je .LBB2_2
; CHECK32-NEXT:  # BB#3: # %exit2
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:    retl
; CHECK32-NEXT:  .LBB2_2: # %exit
; CHECK32-NEXT:    movb $1, %al
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: minus_one:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    movb {{.*}}(%rip), %al
; CHECK64-NEXT:    decl {{.*}}(%rip)
; CHECK64-NEXT:    jne .LBB2_2
; CHECK64-NEXT:  # BB#1: # %entry
; CHECK64-NEXT:    andb $8, %al
; CHECK64-NEXT:    je .LBB2_2
; CHECK64-NEXT:  # BB#3: # %exit2
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:    retq
; CHECK64-NEXT:  .LBB2_2: # %exit
; CHECK64-NEXT:    movb $1, %al
; CHECK64-NEXT:    retq
entry:
  %loaded_L = load i32, i32* @L
  %val = add nsw i32 %loaded_L, -1 ; N.B. will emit dec.
  store i32 %val, i32* @L
  %loaded_M = load i8, i8* @M
  %masked = and i8 %loaded_M, 8
  %M_is_true = icmp ne i8 %masked, 0
  %L_is_false = icmp eq i32 %val, 0
  %cond = and i1 %L_is_false, %M_is_true
  br i1 %cond, label %exit2, label %exit

exit:
  ret i1 true

exit2:
  ret i1 false
}

define i1 @minus_forty_two() nounwind {
; CHECK32-LABEL: minus_forty_two:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    movb M, %al
; CHECK32-NEXT:    movl $-42, %ecx
; CHECK32-NEXT:    addl %ecx, L
; CHECK32-NEXT:    jne .LBB3_2
; CHECK32-NEXT:  # BB#1: # %entry
; CHECK32-NEXT:    andb $8, %al
; CHECK32-NEXT:    je .LBB3_2
; CHECK32-NEXT:  # BB#3: # %exit2
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:    retl
; CHECK32-NEXT:  .LBB3_2: # %exit
; CHECK32-NEXT:    movb $1, %al
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: minus_forty_two:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    movb {{.*}}(%rip), %al
; CHECK64-NEXT:    movl $-42, %ecx
; CHECK64-NEXT:    addl %ecx, {{.*}}(%rip)
; CHECK64-NEXT:    jne .LBB3_2
; CHECK64-NEXT:  # BB#1: # %entry
; CHECK64-NEXT:    andb $8, %al
; CHECK64-NEXT:    je .LBB3_2
; CHECK64-NEXT:  # BB#3: # %exit2
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:    retq
; CHECK64-NEXT:  .LBB3_2: # %exit
; CHECK64-NEXT:    movb $1, %al
; CHECK64-NEXT:    retq
entry:
  %loaded_L = load i32, i32* @L
  %val = add nsw i32 %loaded_L, -42 ; N.B. won't emit dec.
  store i32 %val, i32* @L
  %loaded_M = load i8, i8* @M
  %masked = and i8 %loaded_M, 8
  %M_is_true = icmp ne i8 %masked, 0
  %L_is_false = icmp eq i32 %val, 0
  %cond = and i1 %L_is_false, %M_is_true
  br i1 %cond, label %exit2, label %exit

exit:
  ret i1 true

exit2:
  ret i1 false
}

define i64 @test_intervening_call(i64* %foo, i64 %bar, i64 %baz) nounwind {
; CHECK32-LABEL: test_intervening_call:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    pushl %ebp
; CHECK32-NEXT:    movl %esp, %ebp
; CHECK32-NEXT:    pushl %ebx
; CHECK32-NEXT:    pushl %esi
; CHECK32-NEXT:    movl 12(%ebp), %eax
; CHECK32-NEXT:    movl 16(%ebp), %edx
; CHECK32-NEXT:    movl 20(%ebp), %ebx
; CHECK32-NEXT:    movl 24(%ebp), %ecx
; CHECK32-NEXT:    movl 8(%ebp), %esi
; CHECK32-NEXT:    lock cmpxchg8b (%esi)
; CHECK32-NEXT:    pushl %eax
; CHECK32-NEXT:    seto %al
; CHECK32-NEXT:    lahf
; CHECK32-NEXT:    movl %eax, %esi
; CHECK32-NEXT:    popl %eax
; CHECK32-NEXT:    subl $8, %esp
; CHECK32-NEXT:    pushl %edx
; CHECK32-NEXT:    pushl %eax
; CHECK32-NEXT:    calll bar
; CHECK32-NEXT:    addl $16, %esp
; CHECK32-NEXT:    movl %esi, %eax
; CHECK32-NEXT:    addb $127, %al
; CHECK32-NEXT:    sahf
; CHECK32-NEXT:    jne .LBB4_3
; CHECK32-NEXT:  # BB#1: # %t
; CHECK32-NEXT:    movl $42, %eax
; CHECK32-NEXT:    jmp .LBB4_2
; CHECK32-NEXT:  .LBB4_3: # %f
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:  .LBB4_2: # %t
; CHECK32-NEXT:    xorl %edx, %edx
; CHECK32-NEXT:    popl %esi
; CHECK32-NEXT:    popl %ebx
; CHECK32-NEXT:    popl %ebp
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: test_intervening_call:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    pushq %rbp
; CHECK64-NEXT:    movq %rsp, %rbp
; CHECK64-NEXT:    pushq %rbx
; CHECK64-NEXT:    pushq %rax
; CHECK64-NEXT:    movq %rsi, %rax
; CHECK64-NEXT:    lock cmpxchgq %rdx, (%rdi)
; CHECK64-NEXT:    pushq %rax
; CHECK64-NEXT:    seto %al
; CHECK64-NEXT:    lahf
; CHECK64-NEXT:    movq %rax, %rbx
; CHECK64-NEXT:    popq %rax
; CHECK64-NEXT:    movq %rax, %rdi
; CHECK64-NEXT:    callq bar
; CHECK64-NEXT:    movq %rbx, %rax
; CHECK64-NEXT:    addb $127, %al
; CHECK64-NEXT:    sahf
; CHECK64-NEXT:    jne .LBB4_3
; CHECK64-NEXT:  # BB#1: # %t
; CHECK64-NEXT:    movl $42, %eax
; CHECK64-NEXT:    jmp .LBB4_2
; CHECK64-NEXT:  .LBB4_3: # %f
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:  .LBB4_2: # %t
; CHECK64-NEXT:    addq $8, %rsp
; CHECK64-NEXT:    popq %rbx
; CHECK64-NEXT:    popq %rbp
; CHECK64-NEXT:    retq
entry:
  ; cmpxchg sets EFLAGS, call clobbers it, then br uses EFLAGS.
  %cx = cmpxchg i64* %foo, i64 %bar, i64 %baz seq_cst seq_cst
  %v = extractvalue { i64, i1 } %cx, 0
  %p = extractvalue { i64, i1 } %cx, 1
  call i32 @bar(i64 %v)
  br i1 %p, label %t, label %f

t:
  ret i64 42

f:
  ret i64 0
}

define i64 @test_two_live_flags(i64* %foo0, i64 %bar0, i64 %baz0, i64* %foo1, i64 %bar1, i64 %baz1) nounwind {
; CHECK32-LABEL: test_two_live_flags:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    pushl %ebp
; CHECK32-NEXT:    movl %esp, %ebp
; CHECK32-NEXT:    pushl %ebx
; CHECK32-NEXT:    pushl %edi
; CHECK32-NEXT:    pushl %esi
; CHECK32-NEXT:    movl 44(%ebp), %edi
; CHECK32-NEXT:    movl 12(%ebp), %eax
; CHECK32-NEXT:    movl 16(%ebp), %edx
; CHECK32-NEXT:    movl 20(%ebp), %ebx
; CHECK32-NEXT:    movl 24(%ebp), %ecx
; CHECK32-NEXT:    movl 8(%ebp), %esi
; CHECK32-NEXT:    lock cmpxchg8b (%esi)
; CHECK32-NEXT:    seto %al
; CHECK32-NEXT:    lahf
; CHECK32-NEXT:    movl %eax, %esi
; CHECK32-NEXT:    movl 32(%ebp), %eax
; CHECK32-NEXT:    movl 36(%ebp), %edx
; CHECK32-NEXT:    movl %edi, %ecx
; CHECK32-NEXT:    movl 40(%ebp), %ebx
; CHECK32-NEXT:    movl 28(%ebp), %edi
; CHECK32-NEXT:    lock cmpxchg8b (%edi)
; CHECK32-NEXT:    sete %al
; CHECK32-NEXT:    pushl %eax
; CHECK32-NEXT:    movl %esi, %eax
; CHECK32-NEXT:    addb $127, %al
; CHECK32-NEXT:    sahf
; CHECK32-NEXT:    popl %eax
; CHECK32-NEXT:    jne .LBB5_4
; CHECK32-NEXT:  # BB#1: # %entry
; CHECK32-NEXT:    testb %al, %al
; CHECK32-NEXT:    je .LBB5_4
; CHECK32-NEXT:  # BB#2: # %t
; CHECK32-NEXT:    movl $42, %eax
; CHECK32-NEXT:    jmp .LBB5_3
; CHECK32-NEXT:  .LBB5_4: # %f
; CHECK32-NEXT:    xorl %eax, %eax
; CHECK32-NEXT:  .LBB5_3: # %t
; CHECK32-NEXT:    xorl %edx, %edx
; CHECK32-NEXT:    popl %esi
; CHECK32-NEXT:    popl %edi
; CHECK32-NEXT:    popl %ebx
; CHECK32-NEXT:    popl %ebp
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: test_two_live_flags:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    pushq %rbp
; CHECK64-NEXT:    movq %rsp, %rbp
; CHECK64-NEXT:    movq %rsi, %rax
; CHECK64-NEXT:    lock cmpxchgq %rdx, (%rdi)
; CHECK64-NEXT:    seto %al
; CHECK64-NEXT:    lahf
; CHECK64-NEXT:    movq %rax, %rdx
; CHECK64-NEXT:    movq %r8, %rax
; CHECK64-NEXT:    lock cmpxchgq %r9, (%rcx)
; CHECK64-NEXT:    sete %al
; CHECK64-NEXT:    pushq %rax
; CHECK64-NEXT:    movq %rdx, %rax
; CHECK64-NEXT:    addb $127, %al
; CHECK64-NEXT:    sahf
; CHECK64-NEXT:    popq %rax
; CHECK64-NEXT:    jne .LBB5_3
; CHECK64-NEXT:  # BB#1: # %entry
; CHECK64-NEXT:    testb %al, %al
; CHECK64-NEXT:    je .LBB5_3
; CHECK64-NEXT:  # BB#2: # %t
; CHECK64-NEXT:    movl $42, %eax
; CHECK64-NEXT:    popq %rbp
; CHECK64-NEXT:    retq
; CHECK64-NEXT:  .LBB5_3: # %f
; CHECK64-NEXT:    xorl %eax, %eax
; CHECK64-NEXT:    popq %rbp
; CHECK64-NEXT:    retq
entry:
  %cx0 = cmpxchg i64* %foo0, i64 %bar0, i64 %baz0 seq_cst seq_cst
  %p0 = extractvalue { i64, i1 } %cx0, 1
  %cx1 = cmpxchg i64* %foo1, i64 %bar1, i64 %baz1 seq_cst seq_cst
  %p1 = extractvalue { i64, i1 } %cx1, 1
  %flag = and i1 %p0, %p1
  br i1 %flag, label %t, label %f

t:
  ret i64 42

f:
  ret i64 0
}

define i1 @asm_clobbering_flags(i32* %mem) nounwind {
; CHECK32-LABEL: asm_clobbering_flags:
; CHECK32:       # BB#0: # %entry
; CHECK32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK32-NEXT:    movl (%ecx), %edx
; CHECK32-NEXT:    testl %edx, %edx
; CHECK32-NEXT:    setg %al
; CHECK32-NEXT:    #APP
; CHECK32-NEXT:    bsfl %edx, %edx
; CHECK32-NEXT:    #NO_APP
; CHECK32-NEXT:    movl %edx, (%ecx)
; CHECK32-NEXT:    retl
;
; CHECK64-LABEL: asm_clobbering_flags:
; CHECK64:       # BB#0: # %entry
; CHECK64-NEXT:    movl (%rdi), %ecx
; CHECK64-NEXT:    testl %ecx, %ecx
; CHECK64-NEXT:    setg %al
; CHECK64-NEXT:    #APP
; CHECK64-NEXT:    bsfl %ecx, %ecx
; CHECK64-NEXT:    #NO_APP
; CHECK64-NEXT:    movl %ecx, (%rdi)
; CHECK64-NEXT:    retq
entry:
  %val = load i32, i32* %mem, align 4
  %cmp = icmp sgt i32 %val, 0
  %res = tail call i32 asm "bsfl $1,$0", "=r,r,~{cc},~{dirflag},~{fpsr},~{flags}"(i32 %val)
  store i32 %res, i32* %mem, align 4
  ret i1 %cmp
}
