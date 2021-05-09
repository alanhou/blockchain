
chmod -R 0755 ./crypto-config
# Delete existing channel artifacts
rm -rf ./crypto-config
rm -f ./channel-artifacts/*

#Generate Crypto artifactes for organizations
cryptogen generate --config=./config/crypto-config.yaml --output=./crypto-config/


# System channel
SYS_CHANNEL="fabric-channel"

# channel name defaults to "mychannel"
CHANNEL_NAME="mychannel"

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath ./config -channelID $SYS_CHANNEL  -outputBlock ./channel-artifacts/genesis.block


# Generate channel configuration block
echo "#######    Generating channel block  ##########"
configtxgen -profile BasicChannel -configPath ./config -outputCreateChannelTx ./channel-artifacts/mychannel.tx -channelID $CHANNEL_NAME
echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath ./config -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP