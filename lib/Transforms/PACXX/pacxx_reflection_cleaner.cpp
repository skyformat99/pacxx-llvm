/* Copyright (C) University of Muenster - All Rights Reserved
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Written by Michael Haidl <michael.haidl@uni-muenster.de>, 2010-2014
*/

#include <vector>
#include <cassert>
#include <algorithm>

#define DEBUG_TYPE "pacxx_reflection"

#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Argument.h"
#include "llvm/IR/Operator.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/InstVisitor.h"
#include "llvm/IR/InlineAsm.h"
#include "llvm/Support/Host.h"
#include "llvm/Transforms/PACXXTransforms.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Target/TargetLowering.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/FileSystem.h"

#include "ModuleHelper.h"

using namespace llvm;
using namespace std;
using namespace pacxx;

namespace pacxx {

struct PACXXReflectionCleaner : public ModulePass {
  static char ID;
  PACXXReflectionCleaner() : ModulePass(ID) {}
  virtual ~PACXXReflectionCleaner() {}
  virtual bool runOnModule(Module &M);

private:
  void cleanFromKerneles(Module &M);
};

bool PACXXReflectionCleaner::runOnModule(Module &M) {
  bool modified = true;

  M.setTargetTriple(sys::getProcessTriple());
  string Error;
  auto HostTarget = TargetRegistry::lookupTarget(M.getTargetTriple(), Error);
  if (!HostTarget) {
    assert(false);
  }

  TargetOptions Options;
  auto RM = Optional<Reloc::Model>();
  auto HostMachine =
      HostTarget->createTargetMachine(M.getTargetTriple(), "", "", Options, RM);
  M.setDataLayout(HostMachine->createDataLayout().getStringRepresentation());
  cleanFromKerneles(M);

  for (auto &F : M.getFunctionList())
    F.setCallingConv(CallingConv::C);

  return modified;
}

void PACXXReflectionCleaner::cleanFromKerneles(Module &M) {
  auto kernels = pacxx::getTagedFunctions(&M, "nvvm.annotations", "kernel");

  for (auto F : kernels) {
    F->replaceAllUsesWith(UndefValue::get(F->getType()));
    F->eraseFromParent();
  }

  // vector<Function*> Fs;
  // for (auto& F : M.getFunctionList()) {
  //    //if (!F.getName().startswith("__pacxx"))
  //    //    Fs.push_back(&F);
  //    //else
  //    if (F.isDeclaration())
  //        Fs.push_back(&F);
  //}

  // for (auto F : Fs)
  //    F->eraseFromParent();

  // auto& MDs = M.getNamedMDList();

  // vector<NamedMDNode*> nMDs;

  // for (auto& MD : MDs)
  //{
  //    if (MD.getName().startswith("opencl") || MD.getName().startswith("nvvm")
  //    || MD.getName().startswith("pacxx.kernel"))
  //        nMDs.push_back(&MD);
  //}

  // for (auto MD : nMDs)
  //    MD->eraseFromParent();

  // auto refNode = M.getOrInsertNamedMetadata("pacxx.reflection");

  // for (unsigned i = 0; i != refNode->getNumOperands(); ++i)
  //{
  //    if (MDNode* MD = dyn_cast<MDNode>(refNode->getOperand(i)))
  //    {
  //        if (MDString* MS = dyn_cast<MDString>(MD->getOperand(1)))
  //        {
  //            if (!MS->getString().equals("stub"))
  //            {
  //                MD->replaceOperandWith()
  //            }
  //        }
  //    }
  //}
}

//
// void PACXXReflection::cleanFromReflections(Module &M) {
//  auto reflections = pacxx::getTagedFunctions(&M, "pacxx.reflection", "");
//
//  for (auto F : reflections) {
//    F->replaceAllUsesWith(UndefValue::get(F->getType()));
//    F->eraseFromParent();
//  }
//
//  auto& MDs = M.getNamedMDList();
//
//  vector<NamedMDNode*> nMDs;
//
//  for (auto& MD : MDs)
//  {
//      if (MD.getName().startswith("pacxx"))
//          nMDs.push_back(&MD);
//  }
//
//  for (auto MD : nMDs)
//      MD->eraseFromParent();
//
//}

char PACXXReflectionCleaner::ID = 0;
static RegisterPass<PACXXReflectionCleaner>
    X("pacxx_reflection_cleaner",
      "PACXXReflectionCleaner: "
      "finalizes the reflection module by cleaning up",
      false, false);
}

namespace llvm {
Pass *createPACXXReflectionCleanerPass() {
  return new PACXXReflectionCleaner();
}
}
