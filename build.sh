#! /bin/sh

if [ -d builddir ]; then
  echo remove builddir
  rm -rf builddir
fi

cmake \
  -DCMAKE_TOOLCHAIN_FILE=toolchain_stm32.cmake \
  -G "Ninja" \
  -S . \
  -B builddir \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX:PATH=instdir \
  --log-level=VERBOSE \
  || exit 1
echo Configure Ok

cmake --build builddir --config Debug || exit 1
echo Build Ok

cmake --install builddir --strip || exit 1
echo install Ok
