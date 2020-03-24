
if(${STM32_TYPE} STREQUAL "L0")
	set(CMAKE_C_FLAGS   "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=c11   -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
	set(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m0 -Wall -std=c++17 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
	set(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m0 -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

	set(CMAKE_EXE_LINKER_FLAGS    "-Wl,--gc-sections -mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "executable linker flags")
	set(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "module linker flags")
	set(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m0 -mabi=aapcs" CACHE INTERNAL "shared linker flags")
elseif(${STM32_TYPE} STREQUAL "H7")
	# TODO
endif()
