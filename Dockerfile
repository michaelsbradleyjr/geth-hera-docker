# multi-stage builder images
# ------------------------------------------------------------------------------

FROM golang:1.11-alpine as builder-geth
RUN apk add --no-cache gcc git linux-headers make musl-dev
RUN cd / \
    && git clone --branch ewasm-testnet-milestone1 \
                 --depth 1 \
                 https://github.com/ewasm/go-ethereum.git 2> /dev/null \
    && cd go-ethereum \
    && make geth

# ------------------------------------------------------------------------------

FROM alpine:latest as builder-hera
RUN apk add --no-cache cmake g++ gcc git linux-headers make musl-dev
RUN git clone --branch ewasm-testnet-milestone1 \
              --depth 1 \
              https://github.com/ewasm/hera.git 2> /dev/null \
    && cd hera \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake -DBUILD_SHARED_LIBS=ON .. \
    && cmake --build .

# final image
# ------------------------------------------------------------------------------

FROM alpine:latest
RUN apk add --no-cache ca-certificates libgcc libstdc++
COPY --from=builder-geth /go-ethereum/build/bin/geth /usr/local/bin/
COPY --from=builder-hera /hera/build/src/libhera.so /usr/local/lib/
EXPOSE 8545 8546 8547 30303 30303/udp
ENTRYPOINT ["geth"]
