#!/bin/bash 

set -e

echo " Archive File and Copying Dynamics Libs"


#copying artificats

## ffmpeg archive 
mkdir -p /app/ffmpeg/lib
cp /app/workspace/bin/ffmpeg /app/ffmpeg
cp /app/workspace/bin/ffprobe /app/ffmpeg
cp /app/workspace/bin/ffplay /app/ffmpeg/
cp /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppc.so /app/ffmpeg/lib/libnppc.so.12
cp /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppig.so /app/ffmpeg/lib/libnppig.so.12
cp /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppicc.so /app/ffmpeg/lib/libnppicc.so.12
cp /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppidei.so /app/ffmpeg/lib/libnppidei.so.12
cp /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppif.so /app/ffmpeg/lib/libnppif.so.12

cd /app/ffmpeg
OUTPUT_FNAME="ffmpeg-${FFMPEG_VERSION}-ubuntu20.04.zip"
zip -r "${OUTPUT_FNAME}" .