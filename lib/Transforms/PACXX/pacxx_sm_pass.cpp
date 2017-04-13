//
// Created by lars

#include "pacxx_sm_pass.h"

using namespace llvm;
using namespace std;
using namespace pacxx;

namespace llvm {
    void initializePACXXNativeSMTransformerPass(PassRegistry&);
}

PACXXNativeSMTransformer::PACXXNativeSMTransformer() : ModulePass(ID) {
    __verbose("created sm pass\n");
    initializePACXXNativeSMTransformerPass(*PassRegistry::getPassRegistry());
}

PACXXNativeSMTransformer::~PACXXNativeSMTransformer() {}

void PACXXNativeSMTransformer::releaseMemory() {}

void PACXXNativeSMTransformer::getAnalysisUsage(AnalysisUsage &AU) const {}

bool PACXXNativeSMTransformer::runOnModule(Module &M) {

    __verbose("Generating shared memory \n");

    auto kernels = pacxx::getTagedFunctions(&M, "nvvm.annotations", "kernel");

    for(auto &kernel : kernels) {
        __verbose(kernel->getName().str());
        runOnKernel(kernel);
    }

    return true;
}

void PACXXNativeSMTransformer::runOnKernel(Function *kernel) {
    auto argIt = kernel->arg_end();

    // the sm_size is always the second last arg
    Value *sm_size = &*(--(--argIt));

    createSharedMemoryBuffer(kernel, sm_size);
}

void PACXXNativeSMTransformer::createSharedMemoryBuffer(Function *func, Value *sm_size) {

    Module *M = func->getParent();

    auto internal_sm = getSMGlobalsUsedByKernel(M, func, true);
    auto external_sm = getSMGlobalsUsedByKernel(M, func, false);

    if(!internal_sm.empty() || !external_sm.empty()) {
        BasicBlock *entry = &func->front();
        BasicBlock *sharedMemBB = BasicBlock::Create(func->getContext(), "shared mem", func, entry);

        if (!internal_sm.empty()) {
            __verbose("internal shared memory found\n");
            createInternalSharedMemoryBuffer(*M, func, internal_sm, sharedMemBB);
        }

        if (!external_sm.empty()) {
            __verbose("external shared memory found\n");
            createExternalSharedMemoryBuffer(*M, func, external_sm, sm_size, sharedMemBB);
        }

        BranchInst::Create(entry, sharedMemBB);

        __verbose("created shared memory");
    }
}

set<GlobalVariable *> PACXXNativeSMTransformer::getSMGlobalsUsedByKernel(Module *M, Function *func, bool internal) {
    set<GlobalVariable *> sm;
    for (auto &GV : M->globals()) {
        if (internal ? GV.hasInternalLinkage() : GV.hasExternalLinkage() && GV.getMetadata("pacxx.as.shared")) {
            for (User *GVUsers : GV.users()) {
                if (Instruction *Inst = dyn_cast<Instruction>(GVUsers)) {
                    if (Inst->getParent()->getParent() == func) {
                        sm.insert(&GV);
                    }
                }

                if(ConstantExpr *constExpr = dyn_cast<ConstantExpr>(GVUsers)) {
                    vector<ConstantUser> smUsers = findInstruction(func, constExpr);
                    set<Constant *> constantsToRemove;
                    for(auto &smUser : smUsers) {
                        auto inst = smUser._inst;
                        for(auto constant : smUser._constants) {
                            Instruction *constInst = constant->getAsInstruction();
                            constInst->insertBefore(inst);
                            inst->replaceUsesOfWith(constant, constInst);
                            inst = constInst;
                            constantsToRemove.insert(constant);
                        }
                    }

                    for(auto constant : constantsToRemove) {
                        constant->dropAllReferences();
                    }

                    sm.insert(&GV);
                }
            }
        }
    }
    return sm;
}

vector<PACXXNativeSMTransformer::ConstantUser> PACXXNativeSMTransformer::findInstruction(Function *func, ConstantExpr * constExpr) {
    vector<ConstantUser> smUsers;
    for (auto &B : *func) {
        for (auto &I : B) {
            vector<ConstantExpr *> constants;
            vector<ConstantExpr *> tmp;
            Instruction *inst = &I;
            for (auto &op : inst->operands()) {
                if (ConstantExpr *opConstant = dyn_cast<ConstantExpr>(op.get())) {
                    bool usesSM = false;
                    if (opConstant == constExpr) {
                        constants.push_back(opConstant);
                        smUsers.push_back(ConstantUser(inst, constants));
                    }
                    else {
                        tmp.push_back(opConstant);
                        lookAtConstantOps(opConstant, constExpr, tmp, constants, &usesSM);
                        if (usesSM) {
                            smUsers.push_back(ConstantUser(inst, constants));
                        }
                    }
                }
            }
        }
    }
    return smUsers;
}

void PACXXNativeSMTransformer::lookAtConstantOps(ConstantExpr *constExp, ConstantExpr *smUser,
                                                 vector<ConstantExpr *> &tmp,
                                                 vector<ConstantExpr *> &constants,
                                                 bool *usesSM) {
   for(auto &op : constExp->operands()) {
       if(ConstantExpr *opConstant = dyn_cast<ConstantExpr>(op.get())) {
           if(opConstant == smUser) {
               for(auto constant : tmp) {
                   constants.push_back(constant);
               }
               constants.push_back(opConstant);
               *usesSM = true;
               return;
           }

           tmp.push_back(opConstant);
           lookAtConstantOps(opConstant, smUser, tmp, constants, usesSM);
       }
   }
}

void PACXXNativeSMTransformer::createInternalSharedMemoryBuffer(Module &M,
                                                                Function *kernel,
                                                                set<GlobalVariable *> &globals,
                                                                BasicBlock *sharedMemBB) {

    for (auto GV : globals) {

        Type *sm_type = GV->getType()->getElementType();
        AllocaInst *sm_alloc = new AllocaInst(sm_type, 0, nullptr,
                                              0, "internal_sm",
                                              sharedMemBB);

        if (GV->hasInitializer() && !isa<UndefValue>(GV->getInitializer()))
            new StoreInst(GV->getInitializer(), sm_alloc, sharedMemBB);

        replaceAllUsesInKernel(kernel, GV, sm_alloc);
    }
}

void PACXXNativeSMTransformer::createExternalSharedMemoryBuffer(Module &M,
                                                                Function *kernel,
                                                                set<GlobalVariable *> &globals,
                                                                Value *sm_size,
                                                                BasicBlock *sharedMemBB) {
    for (auto GV : globals) {
        Type *GVType = GV->getType()->getElementType();
        Type *sm_type = nullptr;

        sm_type = GVType->getArrayElementType();

        Value *typeSize = ConstantInt::get(Type::getInt32Ty(M.getContext()),
                                           M.getDataLayout().getTypeAllocSize(sm_type));

        //calc number of elements
        BinaryOperator *div = BinaryOperator::CreateUDiv(sm_size, typeSize, "numElem", sharedMemBB);
        AllocaInst *sm_alloc = new AllocaInst(GV->getType(), 0, div,
                                              "external_sm", sharedMemBB);

        BitCastInst *cast = new BitCastInst(sm_alloc, GV->getType(), "cast", sharedMemBB);

        replaceAllUsesInKernel(kernel, GV, cast);
    }
}

void PACXXNativeSMTransformer::replaceAllUsesInKernel(Function *kernel, Value *from, Value *with) {
    auto UI = from->use_begin(), E = from->use_end();
    for (; UI != E;) {
        Use &U = *UI;
        ++UI;
        auto *Usr = dyn_cast<Instruction>(U.getUser());
        if (Usr && Usr->getParent()->getParent() == kernel)
            U.set(with);
        else
            //this is needed because of some leftover reflection calls that use the sm variable
            U.set(UndefValue::get(from->getType()));
    }
    return;
}

char PACXXNativeSMTransformer::ID = 0;

INITIALIZE_PASS_BEGIN(PACXXNativeSMTransformer, "sm-transformer",
                "Shared memory pass", true, true)
INITIALIZE_PASS_END(PACXXNativeSMTransformer, "sm-transformer",
                "Shared memory pass", true, true)

namespace llvm {
    Pass* createPACXXNativeSMPass() { return new PACXXNativeSMTransformer(); }
}


