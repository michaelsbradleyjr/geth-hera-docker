Build the container:

```
$ docker build . -t my/geth-hera
```

Or pull it from the hub:

```
$ docker pull michaelsbradleyjr/geth-hera
```

In a DApp, e.g. `embark_demo`, start the geth-hera container before running
`embark run` (similar to running a separate `embark blockchain`):

```
$ docker \
    run \
    -it \
    --rm \
    -p 8545:8545 \
    -p 8546:8546 \
    -v "$PWD/.embark":"/.embark" \
    michaelsbradleyjr/geth-hera \
    --nousb \
    --vm.ewasm="/usr/local/lib/libhera.so,metering=true,fallback=true" \
    --networkid=1337 \
    --datadir=/.embark/development/datadir \
    --gcmode=archive \
    --ipcpath=/tmp/geth.ipc \
    --port=30303 \
    --rpc \
    --rpcport=8545 \
    --rpcaddr=0.0.0.0 \
    --rpccorsdomain=*,http://0.0.0.0:8000,http://0.0.0.0:8080,http://embark \
    --ws \
    --wsport=8546 \
    --wsaddr=0.0.0.0 \
    --wsorigins=*,http://0.0.0.0:8000,http://0.0.0.0:8080,http://embark \
    --nodiscover \
    --maxpeers=0 \
    --shh \
    --rpcapi=eth,web3,net,debug,personal,shh \
    --wsapi=eth,web3,net,shh,debug,pubsub,personal \
    --unlock= \
    --miner.gastarget=8000000 \
    --dev
```
