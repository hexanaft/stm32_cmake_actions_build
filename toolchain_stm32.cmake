get_filename_component(STM32_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
set(CMAKE_MODULE_PATH ${STM32_CMAKE_DIR} ${CMAKE_MODULE_PATH})

# based on https://github.com/ObKo/stm32-cmake/blob/master/cmake/gcc_stm32.cmake

if(NOT TARGET_TRIPLET)
    set(TARGET_TRIPLET "arm-none-eabi")
    message(STATUS "No TARGET_TRIPLET specified, using default: " ${TARGET_TRIPLET})
endif()

set(CMAKE_SYSTEM_NAME       Generic)
set(CMAKE_SYSTEM_PROCESSOR  arm)

if (WIN32)
    set(TOOL_EXECUTABLE_SUFFIX ".exe")
else()
    set(TOOL_EXECUTABLE_SUFFIX "")
endif()

if(NOT TOOLCHAIN_PREFIX)
    message(STATUS "NOT TOOLCHAIN_PREFIX !!!" )
    if(${CMAKE_VERSION} VERSION_LESS 3.6.0)
        message(STATUS "Cmake version: " ${CMAKE_VERSION} )
        include(CMakeForceCompiler)
        CMAKE_FORCE_C_COMPILER(  "${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}" GNU)
        CMAKE_FORCE_CXX_COMPILER("${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}" GNU)
    else()
        message(STATUS "Cmake version: " ${CMAKE_VERSION} )
        set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
        set(CMAKE_C_COMPILER   "${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
        set(CMAKE_CXX_COMPILER "${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}")
    endif()
    set(CMAKE_ASM_COMPILER     "${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")

    set(CMAKE_OBJCOPY "${TARGET_TRIPLET}-objcopy${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objcopy tool")
    set(CMAKE_OBJDUMP "${TARGET_TRIPLET}-objdump${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objdump tool")
    set(CMAKE_SIZE    "${TARGET_TRIPLET}-size${TOOL_EXECUTABLE_SUFFIX}"    CACHE INTERNAL "size tool")
    set(CMAKE_DEBUGER "${TARGET_TRIPLET}-gdb${TOOL_EXECUTABLE_SUFFIX}"     CACHE INTERNAL "debuger")
    set(CMAKE_CPPFILT "${TARGET_TRIPLET}-c++filt${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "C++filt")

else()
    set(TOOLCHAIN_BIN_DIR "${TOOLCHAIN_PREFIX}/bin")
    set(TOOLCHAIN_INC_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/include")
    set(TOOLCHAIN_LIB_DIR "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}/lib")

    if(${CMAKE_VERSION} VERSION_LESS 3.6.0)
        message(STATUS "Cmake version: " ${CMAKE_VERSION} )
        include(CMakeForceCompiler)
        CMAKE_FORCE_C_COMPILER(  "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}" GNU)
        CMAKE_FORCE_CXX_COMPILER("${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}" GNU)
    else()
        message(STATUS "Cmake version: " ${CMAKE_VERSION} )
        set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
        set(CMAKE_C_COMPILER   "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")
        set(CMAKE_CXX_COMPILER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-g++${TOOL_EXECUTABLE_SUFFIX}")
    endif()
    set(CMAKE_ASM_COMPILER     "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gcc${TOOL_EXECUTABLE_SUFFIX}")

    set(CMAKE_OBJCOPY "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objcopy${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objcopy tool")
    set(CMAKE_OBJDUMP "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-objdump${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "objdump tool")
    set(CMAKE_SIZE    "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-size${TOOL_EXECUTABLE_SUFFIX}"    CACHE INTERNAL "size tool")
    set(CMAKE_DEBUGER "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-gdb${TOOL_EXECUTABLE_SUFFIX}"     CACHE INTERNAL "debuger")
    set(CMAKE_CPPFILT "${TOOLCHAIN_BIN_DIR}/${TARGET_TRIPLET}-c++filt${TOOL_EXECUTABLE_SUFFIX}" CACHE INTERNAL "C++filt")
endif()

# DEBUG FLAGS
set(CMAKE_C_FLAGS_DEBUG   "-Og -g" CACHE INTERNAL "c compiler flags debug")
set(CMAKE_CXX_FLAGS_DEBUG "-Og -g" CACHE INTERNAL "cxx compiler flags debug")
set(CMAKE_ASM_FLAGS_DEBUG "-g"     CACHE INTERNAL "asm compiler flags debug")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-Xlinker -Map=output.map" CACHE INTERNAL "linker flags debug")

# RELEASE FLAGS
set(CMAKE_C_FLAGS_RELEASE   "-Os -flto -ffat-lto-objects" CACHE INTERNAL "c compiler flags release")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -flto -ffat-lto-objects" CACHE INTERNAL "cxx compiler flags release")
set(CMAKE_ASM_FLAGS_RELEASE ""          CACHE INTERNAL "asm compiler flags release")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-Xlinker -Map=output.map -s -flto" CACHE INTERNAL "linker flags release")

# ROOT PATH
set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}/${TARGET_TRIPLET}" ${EXTRA_FIND_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

function(STM32_SET_LD TARGET STM32_LINKER_SCRIPT)
    get_target_property(TARGET_LD_FLAGS ${TARGET} LINK_FLAGS)
    message(STATUS "TARGET_LD_FLAGS1: " ${TARGET_LD_FLAGS})
    if(TARGET_LD_FLAGS)
        set(TARGET_LD_FLAGS "\"-T${STM32_LINKER_SCRIPT}\" ${TARGET_LD_FLAGS}")
    else()
        set(TARGET_LD_FLAGS "\"-T${STM32_LINKER_SCRIPT}\"")
    endif()
    set_target_properties(${TARGET} PROPERTIES LINK_FLAGS ${TARGET_LD_FLAGS})
    message(STATUS "TARGET_LD_FLAGS2: " ${TARGET_LD_FLAGS})
endfunction()

function(STM32_ADD_BIN MYTARGET)
    message(STATUS "STM32_ADD_BIN MYTARGET: " ${MYTARGET})
    add_custom_command(TARGET ${MYTARGET} POST_BUILD
        COMMAND echo "Generate bin:" && ${CMAKE_OBJCOPY} -Obinary ${MYTARGET} ${MYTARGET}.bin
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generate bin..."
    )
    install(FILES ${MYTARGET}.bin DESTINATION bin)
endfunction()

function(STM32_ADD_HEX MYTARGET)
    message(STATUS "STM32_ADD_HEX MYTARGET: " ${MYTARGET})
    add_custom_command(TARGET ${MYTARGET} POST_BUILD
        COMMAND echo "Generate HEX:" && ${CMAKE_OBJCOPY} -Oihex ${MYTARGET} ${MYTARGET}.hex
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generate hex..."
    )
    install(FILES ${MYTARGET}.hex DESTINATION bin)
endfunction()

function(STM32_ADD_DUMP MYTARGET)
    message(STATUS "STM32_ADD_DUMP MYTARGET: " ${MYTARGET})
    add_custom_command(TARGET ${MYTARGET} POST_BUILD
        COMMAND echo "Generate DUMP:" && ${CMAKE_OBJDUMP} -x -D -S -s ${MYTARGET} | ${CMAKE_CPPFILT} > ${MYTARGET}.dump
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generate dump..."
    )
    install(FILES ${MYTARGET}.dump DESTINATION bin)
endfunction()

function(STM32_PRINT_SIZE MYTARGET)
    message(STATUS "STM32_PRINT_SIZE MYTARGET: " ${MYTARGET})
    add_custom_command(TARGET ${MYTARGET} POST_BUILD
        COMMAND echo "Check size:" && ${CMAKE_SIZE} ${MYTARGET}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running size check..."
    )
endfunction()

function(STM32_CONFIGURE_TYPE STM32_TYPE)
    message(STATUS "STM32_CONFIGURE_TYPE STM32_TYPE: " ${STM32_TYPE})

    if(${STM32_TYPE} STREQUAL "L0")
        set(COMMON_FLAGS "" CACHE INTERNAL "Reset COMMON_FLAGS")
        set(COMMON_FLAGS "${COMMON_FLAGS} -mthumb"          CACHE INTERNAL "Switch to ARM THUMB")
        set(COMMON_FLAGS "${COMMON_FLAGS} -mcpu=cortex-m0"  CACHE INTERNAL "Set CPU to Cortex-M0")
        set(COMMON_FLAGS "${COMMON_FLAGS} -mabi=aapcs"      CACHE INTERNAL "Set ABI to aapcs")
        #set(COMMON_FLAGS "${COMMON_FLAGS} -flto")

        set(COMMON_C_CXX_FLAGS "" CACHE INTERNAL "Reset COMMON_C_CXX_FLAGS")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fno-builtin")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fno-common")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -ffunction-sections")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fdata-sections")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fomit-frame-pointer")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fno-unroll-loops")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -ffast-math")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -ftree-vectorize")
        set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -fmessage-length=0")
        #set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -specs=nosys.specs")
        #set(COMMON_C_CXX_FLAGS "${COMMON_C_CXX_FLAGS} -ffat-lto-objects")

        set(COMMON_WARNING_FLAGS "" CACHE INTERNAL "Reset COMMON_WARNING_FLAGS")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wall")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wextra")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wpedantic")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wcast-align")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wcast-qual")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Wconversion")

        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -Werror")
        set(COMMON_WARNING_FLAGS "${COMMON_WARNING_FLAGS} -pedantic-errors")

        set(CPP_WARNING_FLAGS "" CACHE INTERNAL "Reset CPP_WARNING_FLAGS")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wctor-dtor-privacy")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wduplicated-branches")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wduplicated-cond")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wextra-semi")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wfloat-equal")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wlogical-op")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wnon-virtual-dtor")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wold-style-cast")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Woverloaded-virtual")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wredundant-decls")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wsign-conversion")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wsign-promo")
        set(CPP_WARNING_FLAGS "${CPP_WARNING_FLAGS} -Wno-unused-parameter")
	
        set(CMAKE_C_FLAGS   "${COMMON_FLAGS} ${COMMON_C_CXX_FLAGS} ${COMMON_WARNING_FLAGS}" CACHE INTERNAL "c compiler flags")
        set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${COMMON_C_CXX_FLAGS} ${COMMON_WARNING_FLAGS} ${CPP_WARNING_FLAGS}" CACHE INTERNAL "cxx compiler flags")
        set(CMAKE_ASM_FLAGS "${COMMON_FLAGS} -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

        set(CMAKE_EXE_LINKER_FLAGS    "-Wl,--gc-sections ${COMMON_FLAGS}" CACHE INTERNAL "executable linker flags")
        set(CMAKE_MODULE_LINKER_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "module linker flags")
        set(CMAKE_SHARED_LINKER_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "shared linker flags")
    elseif(${STM32_TYPE} STREQUAL "H7")
            # TODO
    endif()
endfunction()


function(PRINT_FLAGS MYTARGET)
    message(STATUS "STM32_ADD_DUMP MYTARGET: " ${MYTARGET})
    add_custom_command(TARGET ${MYTARGET} POST_BUILD
        COMMAND echo "CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}" &&
                echo "CMAKE_CXX_FLAGS: ${CMAKE_CXX_FLAGS}" &&
                echo "CMAKE_EXE_LINKER_FLAGS: ${CMAKE_EXE_LINKER_FLAGS}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Print flags..."
    )
    install(FILES ${MYTARGET}.dump DESTINATION bin)
endfunction()

# reference : https://gist.github.com/Asher-/617872

# function processes each sub-directory and then adds each source file in directory
# each function should cascade back upward in setting variables so that the bottom directory
# adds its source first, and then the level above it adds its source and passes both up, and so on...

# Using examples.
# recursively_include_src(src ".c;.cpp;.h;.hpp")

function(recursively_include_src which_directory extension_list)
        # get list of all files for this directory
        file(GLOB this_directory_all_files "${which_directory}/*")

  # get rid of .srctree
  file(GLOB this_srctree "${which_directory}/.srctree")

  # get directories only
  if(this_directory_all_files)
    if(this_srctree)
      # remove .srctree from list of files to get list of directories
      list(REMOVE_ITEM this_directory_all_files ${this_srctree})

      # remove "BlockList" File from list
      file(READ ${CMAKE_SOURCE_DIR}/BlockList block_list)
      string(ASCII 27 Esc)
      string(REGEX REPLACE "\n" "${Esc};" block_list "${block_list}")

      foreach(block_file ${block_list})
        if(block_file)
          list(REMOVE_ITEM this_directory_all_files ${block_file})
        endif()
      endforeach()

      message(STATUS "return var a : ${extension_list}, dir : ${which_directory}")

      set(files_list "")
      # get list of source from this directory
      foreach(file_extension ${extension_list})
        set(file_extension_src ${which_directory}/*${file_extension})
        file(GLOB this_directory_src ${file_extension_src})

        if(this_directory_src)
          set(files_list "${files_list};${this_directory_src}")

          # remove source from list of files to get list of directories
          list(REMOVE_ITEM this_directory_all_files ${this_directory_src})
        endif()
      endforeach()

      set(this_directory_directories ${this_directory_all_files})

      # for each sub-directory, call self with sub-directory as arg
      foreach(this_sub_directory ${this_directory_directories})
        recursively_include_src(${this_sub_directory} "${extension_list}")
      endforeach()

      # add source files to ${src_files} in PARENT_SCOPE
      set(src_files ${src_files} ${files_list} PARENT_SCOPE)
      # add directories to ${src_directories} in PARENT_SCOPE
      set(src_directories ${src_directories} ${which_directory} PARENT_SCOPE)
    endif()
  endif()

endfunction()
