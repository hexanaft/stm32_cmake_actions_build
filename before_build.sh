#! /bin/sh

stm32_family="L0"

if [ ! -d "STM32Cube$stm32_family" ]; then
  url="https://api.github.com/repos/STMicroelectronics/STM32Cube$stm32_family/tags"
  latest_version=$(curl --silent $url | sed -n 's/.*name":\s"\(.*\)".*/\1/p' | head -2 | cut -c 2-)
  echo latest version: $latest_version
  wget https://github.com/STMicroelectronics/STM32CubeL0/archive/v$latest_version.zip
  7z x v$latest_version.zip
  mv STM32Cube$stm32_family-$latest_version STM32Cube$stm32_family
else
  echo Dir STM32Cube$stm32_family already exist
fi
