#!/bin/bash

if [ "$(arch)" == "aarch64" ]; then
  cd /lib/aarch64-linux-gnu
else
  cd /lib/x86_64-linux-gnu
fi

cp libassimp.so.5 /app/libassimp.so
cp libfreeimage.so.3 /app/libFreeImage.so
cp libfreetype.so.6 /app/libfreetype6.so
cp libopus.so.0 /app/libopus.so
cp libbrotlicommon.so.1 libbrotlidec.so.1 libbrotlienc.so.1 /app/
