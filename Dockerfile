# multi-stage builder images
# ------------------------------------------------------------------------------

FROM golang:1.12-alpine as builder-geth
RUN apk add --no-cache gcc git linux-headers make musl-dev
RUN cd / \
    && git clone --branch v1.9.2-evmc.6.3.0-0 \
                 --depth 1 \
                 https://github.com/ewasm/go-ethereum.git 2> /dev/null \
    && cd go-ethereum \
    && make geth

# ------------------------------------------------------------------------------

FROM alpine:latest as builder-hera
RUN apk add --no-cache cmake g++ gcc git linux-headers make musl-dev
RUN mkdir hera \
    && cd hera \
    && git init \
    && git remote add origin https://github.com/ewasm/hera.git \
    && git fetch origin --depth=1 \
                        d77f71e0619d1da90177201b75c4ff922e8c7f00 2> /dev/null \
    && git reset --hard FETCH_HEAD \
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
