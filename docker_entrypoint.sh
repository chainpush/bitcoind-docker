#!/bin/sh

BITCOIN_DIR=/home/bitcoin/.bitcoin
BITCOIN_CONF=${BITCOIN_DIR}/bitcoin.conf

# https://github.com/bitcoin/bitcoin/blob/v0.19.1/share/examples/bitcoin.conf

if [ $# -eq 0 ]; then

    if [ ! -e "${BITCOIN_CONF}" ]; then
        echo "${BITCOIN_CONF} not exist!";
        exit 1;
    fi

  exec bitcoind -datadir=${BITCOIN_DIR} -conf=${BITCOIN_CONF}
else
  exec "$@"
fi
