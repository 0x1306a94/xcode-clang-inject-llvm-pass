#ifndef __MY_PASS_H__
#define __MY_PASS_H__

#include <llvm/IR/PassManager.h>

namespace kk {
using namespace llvm;
struct MyPass : public PassInfoMixin<MyPass> {
    PreservedAnalyses run(Module &M, ModuleAnalysisManager &MAM);
    static bool isRequired() { return false; }
};

};  // namespace kk

#endif  // __MY_PASS_H__
