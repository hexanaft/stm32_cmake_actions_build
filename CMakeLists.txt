project(stm32-all)

cmake_minimum_required(VERSION 3.6)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

include_directories(
    ./STM32CubeL0/Drivers/STM32L0xx_HAL_Driver/Inc/
    ./STM32CubeL0/Drivers/CMSIS/Include/
    ./STM32CubeL0/Drivers/CMSIS/Device/ST/STM32L0xx/Include/
)

add_subdirectory(template)
