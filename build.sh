#! /bin/sh

cmake \
  -S . \
  -B . \
  -G "Ninja" \
  -DCMAKE_TOOLCHAIN_FILE=toolchain_stm32.cmake \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX:PATH=instdir
echo Configure Ok

cmake --build . --config Debug
echo Build Ok

cmake --install . --strip
echo install Ok
