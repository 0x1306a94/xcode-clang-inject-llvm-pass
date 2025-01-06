#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include <PassSkeleton/MyPass.h>

using namespace llvm;

static cl::opt<bool> EnableMyPass("my-pass",
                                  cl::init(false),
                                  cl::NotHidden,
                                  cl::desc("Enable MyPass."));

namespace kk {
PreservedAnalyses MyPass::run(Module &M, ModuleAnalysisManager &MAM) {
    bool modified = false;
    if (EnableMyPass) {
        for (auto &F : M) {
            errs() << "MyPass run func name: " << F.getName() << "\n";
        }
    }
    return modified ? llvm::PreservedAnalyses::none() : llvm::PreservedAnalyses::all();
}
};  // namespace kk
