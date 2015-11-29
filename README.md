# Securitieth Explorer

### An attempt to explore the [securitieth](https://github.com/jesuscript/securitieth/tree/master/contracts) contracts

## Usage

To test this, start a geth node with standard embark config:

```
running: geth --datadir="/tmp/embark" --logfile="/tmp/embark.log" --port 30303 --rpc --rpcport 8101 --rpcaddr localhost --networkid 9152 --rpccorsdomain "*" --minerthreads "1" --genesis="config/genesis/dev_genesis.json" --rpcapi "eth,web3" --maxpeers 4 --password config/password account list
```

And then run `meteor` in the root directory.

All code is client side and can be easily built and deployed via `meteor-build-client`.

The dapp is expecting to connect to geth via RPC on port `8101`.

For now, just hold on tight until things update - we're polling the local geth node every 2000 ms for updates. In the future this can be replaced with a smarter thing that listens for specific happenings.

## 'Challange' Features

* In-browser deployment of all contracts, no need to deploy via framework
* [Fixed the `corpAct` contract mapping](https://github.com/hitchcott/securitiet-submission/commit/3eefe6d8ad92b15140b0e0deb7b755a0e279c35a)
* Modified contracts to cater better to UI; added a bunch of public record keeping variables

## Things to note

* I had a lot of issues trying to figure out how the contract interacted; I'm still not totally sure that they're working as intended, but with 0 docs this GUI is what the code seems to suggest

## TODOs

```
- Implement a 'growl-like' notification for mining/pending-txs
- Make the theme sexier
- Replace `alert` with modals
- Allow client-side currency conversion using `ethereum:tools`
- Integreate with mist
- Add UI for voting and spinOff
```

---

Let me know if you have any issues.

MIT 2015