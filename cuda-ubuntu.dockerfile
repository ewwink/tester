ARG CUDAVER=12.3.2
ARG UBUNTUVER=20.04

FROM nvidia/cuda:${CUDAVER}-devel-ubuntu${UBUNTUVER} AS buildFFmpeg

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

RUN mkdir -p /app/workspace && apt-get -qq update && \
    apt-get -y -qq install git build-essential yasm pkg-config cmake zip libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev > /dev/null && \
    # clean
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /app

RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /code/nv-codec-headers && \
    cd /code/nv-codec-headers && make install && \
    git clone https://git.ffmpeg.org/ffmpeg.git /code/ffmpeg


RUN cd /code/ffmpeg && \
    echo "Configuring ffmpeg..." && \
    ./configure --quiet --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags=-L/usr/local/cuda/lib64 --disable-static --enable-shared  --prefix=/app/workspace --libdir=/app/workspace/lib \
    --disable-debug --disable-doc && \
    echo "make ffmpeg..." && \
    make V=0 -s -j 8 && \
    ls /app/workspace && \
    echo "make install ffmpeg..." && \
    make install

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN cp /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
# Copy ffmpeg

RUN ldd /usr/bin/ffmpeg

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]
