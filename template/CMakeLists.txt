project(stm32-blinky C CXX ASM)

cmake_minimum_required(VERSION 3.9)
enable_language(ASM)

set(TargetSources
    Src/main.c
    SW4STM32/startup_stm32l073xx.s
)
set(TargetHeaders
    Inc/main.h
)

#file (GLOB_RECURSE TargetSources "*.c")
#file (GLOB_RECURSE TargetHeaders "*.h")

add_executable(${PROJECT_NAME} ${TargetSources} ${TargetHeaders})
target_include_directories(${PROJECT_NAME} PRIVATE
    Inc/
)
#set(EXECUTABLE_OUTPUT_PATH outbin)
STM32_CONFIGURE_TYPE("L0")
file (GLOB_RECURSE TargetLinkFile "*.ld")
STM32_SET_LD(${PROJECT_NAME} ${TargetLinkFile})
STM32_PRINT_SIZE(${PROJECT_NAME})
STM32_ADD_DUMP(${PROJECT_NAME})
STM32_ADD_HEX(${PROJECT_NAME})
STM32_ADD_BIN(${PROJECT_NAME})
PRINT_FLAGS(${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} DESTINATION instbin/${PROJECT_NAME}.elf)
