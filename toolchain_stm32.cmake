
# based on https://github.com/ObKo/stm32-cmake/blob/master/cmake/gcc_stm32.cmake

if(NOT TOOLCHAIN_PREFIX)
     set(TOOLCHAIN_PREFIX "/usr")
     message(STATUS "No TOOLCHAIN_PREFIX specified, using default: " ${TOOLCHAIN_PREFIX})
else()
     file(TO_CMAKE_PATH "${TOOLCHAIN_PREFIX}" TOOLCHAIN_PREFIX)
endif()

if(NOT TARGET_TRIPLET)
    set(TARGET_TRIPLET "arm-none-eabi")
    message(STATUS "No TARGET_TRIPLET specified, using default: " ${TARGET_TRIPLET})
endif()

set(TOOLCHAIN_BIN_DIR "${TOOLCHAIN_PREFIX}/bin")
set(TOOLCHAIN_INC_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/lib")

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

if(${CMAKE_VERSION} VERSION_LESS 3.6.0)
    include(CMakeForceCompiler)
    CMAKE_FORCE_C_COMPILER(  "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}" GNU)
    CMAKE_FORCE_CXX_COMPILER("${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}" GNU)
else()
    set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
    set(CMAKE_C_COMPILER     "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
    set(CMAKE_CXX_COMPILER   "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}")
endif()
set(CMAKE_ASM_COMPILER       "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")

set(CMAKE_OBJCOPY      "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objcopy tool")
set(CMAKE_OBJDUMP      "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objdump tool")
set(CMAKE_SIZE         "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size${TOOL_EXECUTABLE_SUFFIX}"    CACHE INTERNAL "size tool")
set(CMAKE_DEBUGER      "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gdb${TOOL_EXECUTABLE_SUFFIX}"     CACHE INTERNAL "debuger")
set(CMAKE_CPPFILT      "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-c++filt${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "C++filt")

set(CMAKE_C_FLAGS_DEBUG   "-Og -g" CACHE INTERNAL "c compiler flags debug")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "cxx compiler flags debug")
set(CMAKE_ASM_FLAGS_DEBUG "-g"     CACHE INTERNAL "asm compiler flags debug")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-Xlinker -Map=output.map" CACHE INTERNAL "linker flags debug")

set(CMAKE_C_FLAGS_RELEASE   "-Os -flto" CACHE INTERNAL "c compiler flags release")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto" CACHE INTERNAL "cxx compiler flags release")
set(CMAKE_ASM_FLAGS_RELEASE ""          CACHE INTERNAL "asm compiler flags release")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-Xlinker -Map=output.map -s -flto" CACHE INTERNAL "linker flags release")

set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}" ${EXTRA_FIND_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

function(STM32_ADD_HEX_BIN_TARGETS TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.hex DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Oihex   ${FILENAME} ${FILENAME}.hex)
    add_custom_target(${TARGET}.bin DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Obinary ${FILENAME} ${FILENAME}.bin)
endfunction()

function(STM32_ADD_DUMP_TARGET TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_target(${TARGET}.dump DEPENDS ${TARGET} COMMAND ${CMAKE_OBJDUMP} -x -D -S -s ${FILENAME} | ${CMAKE_CPPFILT} > ${FILENAME}.dump)
endfunction()

function(STM32_PRINT_SIZE_OF_TARGETS TARGET)
    if(EXECUTABLE_OUTPUT_PATH)
      set(FILENAME "${EXECUTABLE_OUTPUT_PATH}/${TARGET}")
    else()
      set(FILENAME "${TARGET}")
    endif()
    add_custom_target(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_SIZE} ${FILENAME})
endfunction()



