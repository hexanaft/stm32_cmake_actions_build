project(stm32-blinky C CXX ASM)

cmake_minimum_required(VERSION 3.9)
enable_language(ASM)

set(STM32_TYPE "L0")
include(cmake/config_stm32)

include_directories(
    Inc/
)

set(TargetSources
    Src/main.c
    SW4STM32/startup_stm32l073xx.s
    SW4STM32/STM32L073RZ_NUCLEO/STM32L073RZTx_FLASH.ld
)

#file (GLOB TargetSources    "Src/*.c" "Src/*.cpp")
#file (GLOB TargetHeaders    "Inc/*.h")

add_executable(${PROJECT_NAME} ${TargetSources})
#set(EXECUTABLE_OUTPUT_PATH outbin)
STM32_SET_LD(${PROJECT_NAME} SW4STM32/STM32L073RZ_NUCLEO/STM32L073RZTx_FLASH.ld)
STM32_PRINT_SIZE(${PROJECT_NAME})
STM32_ADD_DUMP(${PROJECT_NAME})
STM32_ADD_HEX(${PROJECT_NAME})
STM32_ADD_BIN(${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} DESTINATION instbin/${PROJECT_NAME}.elf)