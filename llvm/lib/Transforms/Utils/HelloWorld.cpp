//===-- HelloWorld.cpp - Example Transformations --------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/HelloWorld.h"
#include "llvm/IR/Function.h"

using namespace llvm;

PreservedAnalyses HelloWorldPass::run(Module &M, ModuleAnalysisManager &) {
  std::unordered_set<Function *> TargetFunctions;

  for (Function &F : M) {
    if (F.isDeclaration())
      continue;
    if (F.getName().contains("reverse")) {
      TargetFunctions.insert(&F);
    }
  }
  bool Changed = false;
  for (Function *F : TargetFunctions) {
    if (F->isDeclaration())
      continue;
    if (F->getName().contains("reverse")) {
      F->replaceAllUsesWith(processFunction(*F, M));
      Changed = true;
    }
  }

  return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

Function* HelloWorldPass::processFunction(Function &F, Module &M) {
  // Clone the original function
  ValueToValueMapTy VMap;
  Function *ClonedFunc = CloneFunction(&F, VMap);
  ClonedFunc->setName(F.getName() + ".transformed");


  // Apply transformations to the cloned function
  for (auto &BB : *ClonedFunc) {
    for (auto Inst = BB.begin(), End = BB.end(); Inst != End; ) {
      Instruction *I = &*Inst++;
      IRBuilder<> Builder(I);

      if (auto *BinOp = dyn_cast<BinaryOperator>(I)) {
        Value *LHS = BinOp->getOperand(0);
        Value *RHS = BinOp->getOperand(1);
        Instruction *NewInst = nullptr;

        switch (BinOp->getOpcode()) {
        case Instruction::Add:
          NewInst = BinaryOperator::CreateSub(LHS, RHS);
          break;
        case Instruction::Sub:
          NewInst = BinaryOperator::CreateAdd(LHS, RHS);
          break;
        default:
          continue;
        }

        Builder.Insert(NewInst);
        BinOp->replaceAllUsesWith(NewInst);
        BinOp->eraseFromParent();
      }

      if (auto *CB = dyn_cast<CallBase>(I)) {
        if (Function *Callee = CB->getCalledFunction()) {
          if (!Callee->isDeclaration()) {
            CB->setCalledFunction(processFunction(*Callee, M));
          }
        }
      }
    }
  }

  return ClonedFunc;
}