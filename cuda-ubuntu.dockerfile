ARG CUDAVER=12.3.2
ARG UBUNTUVER=20.04

FROM nvidia/cuda:${CUDAVER}-devel-ubuntu${UBUNTUVER} AS build

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

RUN apt-get update && \
    git build-essential yasm zip libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev -y && \
    # clean
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /app

RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /code/nv-codec-headers && \
    cd /code/nv-codec-headers && make install && \
    git clone https://git.ffmpeg.org/ffmpeg.git /code/ffmpeg


RUN cd /code/ffmpeg && \
    ./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 --disable-static --enable-shared

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p /app/ffmpeg-cuda/lib

# Copy libnpp
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppc.so /app/ffmpeg-cuda/liblibnppc.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppig.so /app/ffmpeg-cuda/liblibnppig.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppicc.so /app/ffmpeg-cuda/liblibnppicc.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppidei.so /app/ffmpeg-cuda/liblibnppidei.so.12
COPY --from=build /usr/local/cuda-12.3/targets/x86_64-linux/lib/libnppif.so /app/ffmpeg-cuda/lib/libnppif.so.12

# Copy ffmpeg
COPY --from=build /app/workspace/bin/ffmpeg /app/ffmpeg-cuda/ffmpeg
COPY --from=build /app/workspace/bin/ffprobe /app/ffmpeg-cuda/ffprobe
COPY --from=build /app/workspace/bin/ffplay /app/ffmpeg-cuda/ffplay

RUN cd /app/ffmpeg-cuda && zip -r ffmpeg-cuda.zip .

# Check shared library
RUN ldd /app/ffmpeg-cuda/ffmpeg
RUN ldd /app/ffmpeg-cuda/ffprobe
RUN ldd /app/ffmpeg-cuda/ffplay

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]
