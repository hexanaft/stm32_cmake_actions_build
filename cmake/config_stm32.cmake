

#	-mcpu=cortex-m0 \ # Cortex m0
#	-mthumb \
#	-ffunction-sections \
#	-fdata-sections 
#	-flto \
#	-g -fno-common -fmessage-length=0 -specs=nosys.specs")


if(${STM32_TYPE} STREQUAL "L0")
	message(STATUS "Stm32 type: " ${STM32_TYPE})
	
	set(COMMON_FLAGS "\
-mthumb \
-mcpu=cortex-m0 \
-mabi=aapcs \
")

	set(COMMON_C_CXX_FLAGS "\
-fno-builtin \
-fno-common \
-ffunction-sections \
-fdata-sections \
-fomit-frame-pointer \
-fno-unroll-loops \
-ffast-math \
-ftree-vectorize \
-fmessage-length=0 \
")
#-specs=nosys.specs \
	
	set(COMMON_WARNING_FLAGS "\
-Wall \
-Wextra \
-Wpedantic \
-Wcast-align \
-Wcast-qual \
-Wconversion \
")
#-Werror \
#-pedantic-errors \
	
	set(CPP_WARNING_FLAGS "\
-Wctor-dtor-privacy \
-Wduplicated-branches \
-Wduplicated-cond \
-Wextra-semi \
-Wfloat-equal \
-Wlogical-op \
-Wnon-virtual-dtor \
-Wold-style-cast \
-Woverloaded-virtual \
-Wredundant-decls \
-Wsign-conversion \
-Wsign-promo \
")
	
	set(CMAKE_C_FLAGS   "${COMMON_FLAGS} ${COMMON_C_CXX_FLAGS} ${COMMON_WARNING_FLAGS}" CACHE INTERNAL "c compiler flags")
	set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${COMMON_C_CXX_FLAGS} ${COMMON_WARNING_FLAGS} ${CPP_WARNING_FLAGS}" CACHE INTERNAL "cxx compiler flags")
	set(CMAKE_ASM_FLAGS "${COMMON_FLAGS} -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

	set(CMAKE_EXE_LINKER_FLAGS    "-Wl,--gc-sections ${COMMON_FLAGS}" CACHE INTERNAL "executable linker flags")
	set(CMAKE_MODULE_LINKER_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "module linker flags")
	set(CMAKE_SHARED_LINKER_FLAGS "${COMMON_FLAGS}" CACHE INTERNAL "shared linker flags")
elseif(${STM32_TYPE} STREQUAL "H7")
	# TODO
endif()
