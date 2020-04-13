// [Streaming transactions from bitcoind via ZeroMQ](https://degreesofzero.com/article/streaming-transactions-from-bitcoind-via-zeromq.html)

// Library for working with the bitcoin protocol.
// For working with transactions, hd wallets, etc.
const bitcoin = require('bitcoinjs-lib');

// Implementation of ZeroMQ in node.js.
// From the maintainers of the ZeroMQ protocol.
const zmq = require('zeromq');

// Create a subscriber socket.
const sock = zmq.socket('sub');
const addr = 'tcp://192.168.0.117:28333';

// Initiate connection to TCP socket.
sock.connect(addr);

// Subscribe to receive messages for a specific topic.
// This can be "rawblock", "hashblock", "rawtx", or "hashtx".
sock.subscribe('rawblock');
// sock.subscribe('hashblock');
sock.subscribe('rawtx');
// sock.subscribe('hashtx');

function handleRawBlock(rawBlock) {
    const block = bitcoin.Block.fromHex(rawBlock);
    let blockId = block.getId();
    console.info("blockId", blockId);
}

function handleHashBlock(hashBlock) {
    console.info("hashBlock", hashBlock);
}

function handleRawTx(rawTx) {
    // Use bitcoinjs-lib to decode the raw transaction.
    const tx = bitcoin.Transaction.fromHex(rawTx);

    // Get the txid as a reference.
    const txid = tx.getId();

    console.info('received transaction', txid);
}

function handleHashTx(hashTx) {
    console.info("hashTx", hashTx);
}

sock.on('message', function (topic, message) {
    let hexContent = message.toString('hex');
    switch (topic.toString()) {
        case "rawblock":
            handleRawBlock(hexContent);
            break;
        case "hashblock":
            handleHashBlock(hexContent);
            break;
        case "rawtx":
            handleRawTx(hexContent);
            break;
        case "hashtx":
            handleHashTx(hexContent);
            break;
        default:
            console.error("unknown topic :", topic.toString());
            break;
    }
});
