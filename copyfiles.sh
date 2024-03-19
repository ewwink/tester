#!/bin/bash 

set -e

echo " Archive File and Copying Dynamics Libs"


#copying artificats

## ffmpeg archive 
mkdir -p /app/ffmpeg/lib
cp /app/workspace/bin/ffmpeg /app/ffmpeg/
cp /app/workspace/bin/ffprobe /app/ffmpeg/
cp /app/workspace/bin/ffplay /app/ffmpeg/
cd /usr/local/cuda/targets/x86_64-linux/lib/{libnppc.so.12,libnppig.so.12,libnppicc.so.12,libnppidei.so.12,libnppif.so.12} /app/ffmpeg/lib/

cd /app/ffmpeg
OUTPUT_FNAME="ffmpeg-${FFMPEG_VERSION}-ubuntu20.04.zip"
zip -r "${OUTPUT_FNAME}" .