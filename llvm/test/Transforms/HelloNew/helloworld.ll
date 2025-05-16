; RUN: opt -passes=helloworld -S %s | FileCheck %s

define i32 @test(i32 %a, i32 %b) {
  %add = add i32 %a, %b
  ret i32 %add
}

define i32 @reversesmth(i32 %a, i32 %b) {
  %call = call i32 @test(i32 %a, i32 %b)
  ret i32 %call
}

; CHECK: define i32 @reversesmth.transformed(i32 %a, i32 %b) {
; CHECK-NEXT:   %call = call i32 @test.transformed(i32 %a, i32 %b)
; CHECK-NEXT:   ret i32 %call
; CHECK-NEXT: }

; CHECK: define i32 @test.transformed(i32 %a, i32 %b) {
; CHECK-NEXT:   %1 = sub i32 %a, %b
; CHECK-NEXT:   ret i32 %1
; CHECK-NEXT: }
