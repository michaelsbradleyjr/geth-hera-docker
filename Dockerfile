# multi-stage builder images
# ------------------------------------------------------------------------------

FROM ubuntu as builder-base
RUN apt-get update \
    && apt-get -y install build-essential git

# ------------------------------------------------------------------------------

FROM builder-base as builder-geth
RUN apt-get -y install software-properties-common wget \
    && add-apt-repository -y ppa:longsleep/golang-backports \
    && apt-get update \
    && apt-get -y install golang-1.11
RUN cd / \
    && git clone --branch ewasm-testnet-milestone1 \
                 https://github.com/ewasm/go-ethereum.git 2> /dev/null \
    && cd go-ethereum \
    && export "PATH=/usr/lib/go-1.11/bin:$PATH" \
    && make geth

# ------------------------------------------------------------------------------

FROM builder-base as builder-hera
RUN apt-get -y install cmake
RUN cd / \
    && git clone --branch ewasm-testnet-milestone1 \
                 https://github.com/ewasm/hera.git 2> /dev/null \
    && cd hera \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON -DHERA_DEBUGGING=ON .. \
    && cmake --build .

# final image
# ------------------------------------------------------------------------------

FROM ubuntu
RUN apt-get update \
    && apt-get -y install ca-certificates \
                          libgcc1 \
                          libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder-geth /go-ethereum/build/bin/geth /usr/local/bin/
COPY --from=builder-hera /hera/build/src/libhera.so /usr/local/lib/
EXPOSE 8545 8546 8547 30303 30303/udp
ENTRYPOINT ["geth"]
