ARG CUDAVER=12.3.2
ARG UBUNTUVER=20.04

FROM nvidia/cuda:${CUDAVER}-devel-ubuntu${UBUNTUVER} AS buildFFmpeg

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

WORKDIR /app
COPY ./copyfiles.sh /app/copyfiles.sh

RUN mkdir -p /app/workspace && apt-get -qq update && \
    apt-get -y -qq install git build-essential gcc-11 g++-11 nasm yasm pkg-config cmake zip libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev libgnutls28-dev \
        python3-pip meson && \ 
    # clean
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN mkdir -p /app/ffmpeg_sources && cd /app/ffmpeg_sources && \
    git -C dav1d pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/dav1d.git && \
    mkdir -p dav1d/build && \
    cd dav1d/build && \
    meson setup -Denable_tools=false -Denable_tests=false --default-library=static .. --prefix "$HOME/ffmpeg_build" --libdir="$HOME/ffmpeg_build/lib" && \
    ninja && \
    ninja install

RUN cd /app/ffmpeg_sources && \
    git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
    mkdir -p aom_build && \
    cd aom_build && \
    PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_TESTS=OFF -DENABLE_NASM=on ../aom && \
    PATH="$HOME/bin:$PATH" make V=0 -s -j $(nproc) && \
    make install
    


RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /code/nv-codec-headers && \
    cd /code/nv-codec-headers && make install && \
    git clone https://git.ffmpeg.org/ffmpeg.git /code/ffmpeg


RUN cd /code/ffmpeg && \
    echo "Configuring ffmpeg..." && \
    ./configure --quiet --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 \
    --enable-nonfree --enable-cuda-nvcc --enable-libnpp --disable-static --enable-shared  --prefix=/app/workspace --libdir=/lib/x86_64-linux-gnu/ \
    --disable-debug --disable-doc --enable-gpl --enable-gnutls \
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
    --enable-libdav1d \
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
