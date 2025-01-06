### xcode-clang-inject-llvm-pass

* 给Xcode自带的clang注入自定义的llvm pass
* Xcode自带的clang和开源版本的clang是由差异的，所以通过注入实现
* 首先确定当前Xcode使用clang的版本

```bash
xcrun clang --verbose

Apple clang version 16.0.0 (clang-1600.0.26.4)
Target: arm64-apple-darwin24.2.0
Thread model: posix
InstalledDir: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin
```

* 下载对应版本的llvm源码

```bash
mkdir -p llvm-development
cd llvm-development
git clone --depth 1 -b 'llvmorg-16.0.0' git@github.com:llvm/llvm-project.git

# 然后参考 PassSkeleton 的目录结构在 llvm-project/llvm/lib/Transforms 下面创建自定义pass 目录
# 然后在 llvm-project/llvm/lib/Transforms/CMakeLists.txt 中追加 add_subdirectory(XXXX)
# 可以复制 PassSkeleton/CMakeLists.txt 到你的pass 目录中，然后将相关target名称改为你自己的
```

* 编写你的pass代码

* 编译

```bash
mkdir -p build_ninja
cd build_ninja

# 注入到Xcode 的clang 必须添加次参数 -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF
cmake -G Ninja -DLLVM_ENABLE_PROJECTS="llvm" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./install -DLLVM_ABI_BREAKING_CHECKS=FORCE_OFF -DLLVM_ENABLE_ZSTD=OFF -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" ../llvm-project/llvm

# 编译pass
ninja install_LLVMPassSkeletonLoader
```

* 脚本说明
```bash
scripts/inject.sh # 注入Xcode clang 执行后会在当前目录创建 Toolchains 目录
# 将你的pass libLLVMXXXDeps.dydlib libLLVMXXXLoader.dylib 拷贝到 Toolchains/lib 下面
# 集成到Xcode中
sudo scripts/install.sh
```

* 测试

```c++
#include <iostream>

int main() {
    std::cout << "Hello World!";
    return 0;
}
```

* 显示注入成功
```
xcrun --toolchain "KK-Xcode" clang -std=c++17 -stdlib=libc++ -lc++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk main.cpp

Applying Clang hook: /Applications/Xcode.app/Contents/Developer/Toolchains/KK-Xcode.xctoolchain/usr/bin/clang
buildO0DefaultPipeline: 0x10327cd2c -> 0x10865c6f4
buildPerModuleDefaultPipeline: 0x10327c8ac -> 0x10865c7dc
Applying Clang hook: /Applications/Xcode.app/Contents/Developer/Toolchains/KK-Xcode.xctoolchain/usr/bin/clang
buildO0DefaultPipeline: 0x10248cd2c -> 0x10786c6f4
buildPerModuleDefaultPipeline: 0x10248c8ac -> 0x10786c7dc
buildO0DefaultPipeline registerPass
buildPerModuleDefaultPipeline registerPass
```

* 启用pass

```
xcrun --toolchain "KK-Xcode" clang -std=c++17 -stdlib=libc++ -lc++ -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk main.cpp -mllvm -my-pass


Applying Clang hook: /Applications/Xcode.app/Contents/Developer/Toolchains/KK-Xcode.xctoolchain/usr/bin/clang
buildO0DefaultPipeline: 0x10524cd2c -> 0x10a62c6f4
buildPerModuleDefaultPipeline: 0x10524c8ac -> 0x10a62c7dc
Applying Clang hook: /Applications/Xcode.app/Contents/Developer/Toolchains/KK-Xcode.xctoolchain/usr/bin/clang
buildO0DefaultPipeline: 0x102a34d2c -> 0x107e146f4
buildPerModuleDefaultPipeline: 0x102a348ac -> 0x107e147dc
buildO0DefaultPipeline registerPass
buildPerModuleDefaultPipeline registerPass
MyPass run func name: main
MyPass run func name: _ZNSt3__1lsB8ne180100INS_11char_traitsIcEEEERNS_13basic_ostreamIcT_EES6_PKc
MyPass run func name: _ZNSt3__124__put_character_sequenceB8ne180100IcNS_11char_traitsIcEEEERNS_13basic_ostreamIT_T0_EES7_PKS4_m
MyPass run func name: _ZNSt3__111char_traitsIcE6lengthB8ne180100EPKc
MyPass run func name: _ZNSt3__113basic_ostreamIcNS_11char_traitsIcEEE6sentryC1ERS3_
MyPass run func name: __gxx_personality_v0
MyPass run func name: _ZNKSt3__113basic_ostreamIcNS_11char_traitsIcEEE6sentrycvbB8ne180100Ev
MyPass run func name: _ZNSt3__116__pad_and_outputB8ne180100IcNS_11char_traitsIcEEEENS_19ostreambuf_iteratorIT_T0_EES6_PKS4_S8_S8_RNS_8ios_baseES4_
MyPass run func name: _ZNSt3__119ostreambuf_iteratorIcNS_11char_traitsIcEEEC1B8ne180100ERNS_13basic_ostreamIcS2_EE
MyPass run func name: _ZNKSt3__18ios_base5flagsB8ne180100Ev
MyPass run func name: _ZNKSt3__19basic_iosIcNS_11char_traitsIcEEE4fillB8ne180100Ev
MyPass run func name: _ZNKSt3__119ostreambuf_iteratorIcNS_11char_traitsIcEEE6failedB8ne180100Ev
MyPass run func name: _ZNSt3__19basic_iosIcNS_11char_traitsIcEEE8setstateB8ne180100Ej
MyPass run func name: _ZNSt3__113basic_ostreamIcNS_11char_traitsIcEEE6sentryD1Ev
MyPass run func name: __cxa_begin_catch
MyPass run func name: _ZNSt3__18ios_base33__set_badbit_and_consider_rethrowEv
MyPass run func name: __cxa_end_catch
MyPass run func name: __clang_call_terminate
MyPass run func name: _ZSt9terminatev

...
```

#### Credits
* [HikariObfuscator/Hanabi](https://github.com/HikariObfuscator/Hanabi)
* [iOS LLVM 混淆插件：Hikari 和 Hanabi](https://kanchuan.com/blog/202-llvm-obfuscation)
* [SsageParuders/SsagePass](https://github.com/SsageParuders/SsagePass)
* [Dobby](https://github.com/jmpews/Dobby)
* [从LLVM到OLLVM学习笔记](https://whitebird0.github.io/post/%E4%BB%8Ellvm%E5%88%B0ollvm%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0.html)