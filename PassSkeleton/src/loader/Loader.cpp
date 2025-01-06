
#include <PassSkeleton/RegisterPass.h>

#include <llvm/Passes/PassBuilder.h>
#include <llvm/Support/raw_ostream.h>

#include <filesystem>

#include "dobby.h"

using namespace std;
using namespace llvm;

namespace fs = std::filesystem;

using BuildPerModulePipelineFunc = llvm::ModulePassManager (*)(llvm::PassBuilder *, llvm::OptimizationLevel, bool);
using BuildO0DefaultPipelineFunc = llvm::ModulePassManager (*)(llvm::PassBuilder *, llvm::OptimizationLevel, bool);
using ParseModulePassFunc = llvm::Error (*)(llvm::PassBuilder *, llvm::ModulePassManager &MPM, const llvm::PassBuilder::PipelineElement &E);

BuildPerModulePipelineFunc original_buildPerModulePipeline = nullptr;
BuildO0DefaultPipelineFunc original_buildO0DefaultPipeline = nullptr;
ParseModulePassFunc original_parseModulePassFunc = nullptr;

//static llvm::Error hooked_parseModulePassFunc(llvm::PassBuilder *PB, llvm::ModulePassManager &MPM, const llvm::PassBuilder::PipelineElement &E) {
//    llvm::Error error = original_parseModulePassFunc(PB, MPM, E);
//    if (error) {
//        MPM.addPass(kk::MyPass());
//        errs() << "parseModulePassFunc add pass: kk::MyPass" << '\n';
//    }
//    return error;
//}

static ModulePassManager hooked_buildPerModuleDefaultPipeline(llvm::PassBuilder *PB, OptimizationLevel level, bool LTOPreLink) {
    ModulePassManager MPM = original_buildPerModulePipeline(PB, level, LTOPreLink);

    kk::registerPass(MPM, level, LTOPreLink);
    errs() << "buildPerModuleDefaultPipeline registerPass" << '\n';
    return MPM;
}

static ModulePassManager hooked_buildO0DefaultPipeline(llvm::PassBuilder *PB, OptimizationLevel level, bool LTOPreLink) {
    ModulePassManager MPM = original_buildO0DefaultPipeline(PB, level, LTOPreLink);
    kk::registerPass(MPM, level, LTOPreLink);

    errs() << "buildO0DefaultPipeline registerPass" << '\n';

    return MPM;
}

static __attribute__((__constructor__)) void Inject(int argc, char *argv[]) {
    //    char *executablePath = argv[0];
    auto executablePath = fs::canonical(argv[0]);
    const auto executable = executablePath.c_str();
    errs() << "Applying Clang hook: " << executable << '\n';

    // Hook buildO0DefaultPipeline
    void *targetAddr = DobbySymbolResolver(executable, "__ZN4llvm11PassBuilder22buildO0DefaultPipelineENS_17OptimizationLevelEb");
    errs() << "buildO0DefaultPipeline: " << targetAddr << " -> " << (void *)hooked_buildO0DefaultPipeline << '\n';

    void *original_buildO0DefaultPipeline_ptr = nullptr;
    DobbyHook(targetAddr, (void *)hooked_buildO0DefaultPipeline, &original_buildO0DefaultPipeline_ptr);
    original_buildO0DefaultPipeline = reinterpret_cast<BuildO0DefaultPipelineFunc>(original_buildO0DefaultPipeline_ptr);

    // Hook buildPerModuleDefaultPipeline
    targetAddr = DobbySymbolResolver(executable, "__ZN4llvm11PassBuilder29buildPerModuleDefaultPipelineENS_17OptimizationLevelEb");
    errs() << "buildPerModuleDefaultPipeline: " << targetAddr << " -> " << (void *)hooked_buildPerModuleDefaultPipeline << '\n';

    void *original_buildPerModulePipeline_ptr = nullptr;
    DobbyHook(targetAddr, (void *)hooked_buildPerModuleDefaultPipeline, &original_buildPerModulePipeline_ptr);
    original_buildPerModulePipeline = reinterpret_cast<BuildPerModulePipelineFunc>(original_buildPerModulePipeline_ptr);

    // Hook parseModulePassFunc
    //    targetAddr = DobbySymbolResolver(executable, "__ZN4llvm11PassBuilder15parseModulePassERNS_11PassManagerINS_6ModuleENS_15AnalysisManagerIS2_JEEEJEEERKNS0_15PipelineElementE");
    //    errs() << "parseModulePassFunc: " << targetAddr << " -> " << (void *)hooked_parseModulePassFunc << '\n';
    //    void *original_parseModulePassFunc_ptr = nullptr;
    //    DobbyHook(targetAddr, (void *)hooked_parseModulePassFunc, &original_parseModulePassFunc_ptr);
    //    original_parseModulePassFunc = reinterpret_cast<ParseModulePassFunc>(original_buildPerModulePipeline_ptr);
}
