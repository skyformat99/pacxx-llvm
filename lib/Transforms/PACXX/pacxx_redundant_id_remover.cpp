#define PACXX_PASS_NAME "PACXXIdRemover"
#define USE_STANDALONE 1
#include "Log.h"

#include "ModuleHelper.h"
#include "CallVisitor.h"
#include "IdHelper.h"

#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;
using namespace std;
using namespace pacxx;

namespace {

class PACXXIdRemover : public ModulePass{

public:

    static char ID;
    PACXXIdRemover() : ModulePass(ID) {}
    virtual ~PACXXIdRemover() {}

    // the ids do not change during the execution so they need to be calculated only once
    virtual bool runOnModule(Module &M) {
        auto kernels = pacxx::getTagedFunctions(&M, "nvvm.annotations", "kernel");
        bool changed = false;
        for (auto &F : kernels) {
            changed |= removeRedundantIdCalculations(F);
            moveIdCalculation(F);
        }
        return changed;
    }

private:

    void moveIdCalculation(Function *F) {
        BasicBlock *entry = &F->front();
        BasicBlock *BB = BasicBlock::Create(F->getContext(), "IdCalc", F, &F->front());
        for(auto inst : _instructionsToMove) {
            inst->removeFromParent();
            BB->getInstList().insert(BB->getFirstInsertionPt(), inst);
        }
        BranchInst::Create(entry, BB);
    }

    bool removeRedundantIdCalculations(Function *F) {
        removeRedundantIdCalculation(F, IdHelper::X);
        removeRedundantIdCalculation(F, IdHelper::Y);
        removeRedundantIdCalculation(F, IdHelper::Z);



        for (auto inst : _instructionsToRemove) {
            inst->eraseFromParent();
        }

        if (_instructionsToRemove.size() == 0)
            return false;

        return true;
    }

    void removeRedundantIdCalculation(Function *F, IdHelper::IdType id) {
        Instruction *firstIdCalculation = nullptr;
        for (auto &B : *F) {
            for (auto &I : B) {
                if (IdHelper::isBaseId(&I, id)) {
                    if (!firstIdCalculation) {
                        firstIdCalculation = &I;
                        _instructionsToMove.push_back(&I);
                        determineUsesToMove(&I);
                    }
                    else {
                        I.replaceAllUsesWith(firstIdCalculation);
                        _instructionsToRemove.push_back(&I);
                        recursiveRemovingOfUses(&I);
                    }
                }
            }
        }
    }

    void recursiveRemovingOfUses(Instruction *inst) {
        for(Instruction::op_iterator I = inst->op_begin(), E = inst->op_end(); I != E; I++) {
            if(Instruction *use = dyn_cast<Instruction>(I)) {
                _instructionsToRemove.push_back(use);
                recursiveRemovingOfUses(use);
            }
        }
    }

    void determineUsesToMove(Instruction *inst) {
        for(Instruction::op_iterator I = inst->op_begin(), E = inst->op_end(); I != E; I++) {
            if(Instruction *use = dyn_cast<Instruction>(I)) {
                _instructionsToMove.push_back(use);
                determineUsesToMove(use);
            }
        }
    }

private:
    vector<Instruction *> _instructionsToRemove;
    vector<Instruction *> _instructionsToMove;

};

char PACXXIdRemover::ID = 0;
}

namespace llvm {
Pass *createPACXXIdRemover() { return new PACXXIdRemover(); }
}
