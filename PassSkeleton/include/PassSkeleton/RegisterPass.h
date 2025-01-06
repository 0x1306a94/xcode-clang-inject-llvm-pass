#ifndef __REGISTER_PASS_H__
#define __REGISTER_PASS_H__

#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>

namespace kk
{
     void registerPass(llvm::ModulePassManager &MPM,llvm::OptimizationLevel level, bool LTOPreLink);
};
#endif // __REGISTER_PASS_H__