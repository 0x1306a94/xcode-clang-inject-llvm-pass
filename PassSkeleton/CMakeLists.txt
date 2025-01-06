add_llvm_library(LLVMPassSkeletonCommon
    src/pass/MyPass.cpp
    src/register/RegisterPass.cpp

    DEPENDS
    intrinsics_gen
)

target_include_directories(LLVMPassSkeletonCommon PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)
# set_target_properties(LLVMPassSkeletonCommon PROPERTIES COMPILE_FLAGS "-fno-rtti")

if(APPLE)
  SET(CMAKE_BUILD_WITH_INSTALL_NAME_DIR FALSE)
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) # 禁止自动使用链接路径
  set(CMAKE_SKIP_BUILD_RPATH TRUE)           # 构建时仍生成 RPATH
  set(CMAKE_INSTALL_RPATH "")
  set(CMAKE_CXX_FLAGS "-std=c++17")

  # LLVMPassSkeletonDeps 
  add_library(LLVMPassSkeletonDeps SHARED
    src/dummy/Dummy.cpp
  )
  target_link_options(LLVMPassSkeletonDeps PRIVATE -undefined PRIVATE dynamic_lookup PRIVATE -all_load)
  target_link_libraries(LLVMPassSkeletonDeps PRIVATE LLVMCore LLVMSupport)
  
  # LLVMPassSkeletonLoader
  add_library(LLVMPassSkeletonLoader SHARED
    src/loader/Loader.cpp
  )
  target_link_options(LLVMPassSkeletonLoader PRIVATE -undefined PRIVATE dynamic_lookup PRIVATE -flat_namespace)
  target_include_directories(LLVMPassSkeletonLoader PRIVATE ${CMAKE_CURRENT_LIST_DIR}/dobby)
  target_include_directories(LLVMPassSkeletonLoader PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)
  # target_link_directories(LLVMPassSkeletonLoader PRIVATE ${CMAKE_CURRENT_LIST_DIR}/dobby)
  target_link_libraries(LLVMPassSkeletonLoader LLVMPassSkeletonDeps LLVMPassSkeletonCommon ${CMAKE_CURRENT_LIST_DIR}/dobby/libdobby.a)
  add_custom_target(fix_LLVMPassSkeletonLoader_rpath ALL
    # COMMAND install_name_tool -delete_rpath ${CMAKE_BINARY_DIR}/lib $<TARGET_FILE:LLVMPassSkeletonLoader>
    COMMAND install_name_tool -change @rpath/libLLVMPassSkeletonDeps.dylib @loader_path/libLLVMPassSkeletonDeps.dylib $<TARGET_FILE:LLVMPassSkeletonLoader>
    DEPENDS LLVMPassSkeletonLoader
  )

  add_custom_target(install_LLVMPassSkeletonLoader ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/lib
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:LLVMPassSkeletonLoader> ${CMAKE_INSTALL_PREFIX}/lib
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:LLVMPassSkeletonDeps> ${CMAKE_INSTALL_PREFIX}/lib
    COMMENT "Installing LLVMPassSkeletonLoader LLVMPassSkeletonDeps to ${CMAKE_INSTALL_PREFIX}/lib"
    DEPENDS fix_LLVMPassSkeletonLoader_rpath
  )
 
else()

endif(APPLE)

if(UNIX AND NOT APPLE)
  set(CMAKE_CXX_FLAGS "-fPIC")
endif()