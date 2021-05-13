
## Environment Preparation

```
cd network/setup
./install-prereqs.sh
sudo -E ./install-fabric.sh

# to validate
./validate/validate-prereqs.sh
./validate/validate-fabric.sh

# install govendor & download examples
./install-gotools.sh

# install hyper ledger explorer
./install-explorer.sh
# validate
./validate/validate-explorer.sh

# install nodejs
./install-node-utils.sh
# validate with the command node -v
```


Credit to: [Mastering Hyperledger Chaincode Development using GoLang
](https://www.udemy.com/course/golang-chaincode-development/)