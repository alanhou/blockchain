
1、Fabric节点创建(fabric-setup/duonodes)
```
# 生成证书
cryptogen generate --config=crypto-config.yaml

# 生成创世块文件，通道ID 需要与后面的不同 configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID fabric-channel 
# 生成通道文件 configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel 
# 创建 Org1和 Org2的锚节点文件 configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP 
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

docker-compose up -d
```

2、区块链浏览器(fabric-setup/explorer)
```
cp -R ../duonodes/crypto-config ./organizations

docker-compose up -d
```