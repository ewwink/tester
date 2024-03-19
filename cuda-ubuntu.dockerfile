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
COPY ./copyfiles.sh /app/copyfiles.sh

RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /code/nv-codec-headers && \
    cd /code/nv-codec-headers && make install && \
    git clone https://git.ffmpeg.org/ffmpeg.git /code/ffmpeg


RUN cd /code/ffmpeg && \
    echo "Configuring ffmpeg..." && \
    ./configure --quiet --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 \
    --enable-nonfree --enable-cuda-nvcc --enable-libnpp --disable-static --enable-shared  --prefix=/app/workspace --libdir=/lib/x86_64-linux-gnu/ \
    --disable-debug --disable-doc --enable-gpl  --enable-gnutls \
    --enable-libaom \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libsrt \
    --enable-libwebp \
    --enable-mediafoundation \
    --enable-libxvid \
    --enable-libx265 && \
    echo "make ffmpeg... $(nproc) core" && \
    make V=0 -s -j $(nproc) && \
    echo "make install ffmpeg..." && \
    make install && \
    echo "Listing directory:" && \
    ls -l /app/workspace
    #ls -l /app/workspace/lib

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN cp /app/workspace/bin/ffmpeg /usr/bin/ffmpeg
# Copy ffmpeg

RUN ldd /usr/bin/ffmpeg

CMD         ["--help"]
ENTRYPOINT  ["/usr/bin/ffmpeg"]
