
#include <PassSkeleton/RegisterPass.h>

#include <PassSkeleton/MyPass.h>

namespace kk {
void registerPass(llvm::ModulePassManager &MPM, llvm::OptimizationLevel level, bool LTOPreLink) {
    //    createModuleToFunctionPassAdaptor

    MPM.addPass(kk::MyPass());
}
};  // namespace kk
