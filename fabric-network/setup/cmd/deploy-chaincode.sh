export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/crypto-config/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem
export PEER0_ORG1_CA=${PWD}/crypto-config/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/crypto-config/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/crypto-config/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/ordererOrganizations/alanhou.org/users/Admin@alanhou.org/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG1_CA}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.alanhou.org/users/Admin@org1.alanhou.org/msp
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG1_CA}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org1.alanhou.org/users/Admin@org1.alanhou.org/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG2_CA}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.alanhou.org/users/Admin@org2.alanhou.org/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PEER0_ORG2_CA}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/crypto-config/peerOrganizations/org2.alanhou.org/users/Admin@org2.alanhou.org/msp
    export CORE_PEER_ADDRESS=localhost:10051

}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ../chaincode/fabcar/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1" # increase this number while upgrading
CC_SRC_PATH="../chaincode/fabcar/go"
CC_NAME="fabcar"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    # setGlobalsForPeer1Org1
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    # echo "===================== Chaincode is installed on peer1.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

    # setGlobalsForPeer1Org2
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    # echo "===================== Chaincode is installed on peer1.org2 ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \
# --collections-config $PRIVATE_DATA_CONFIG \

approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.alanhou.org --tls \
        --cafile ${ORDERER_CA} --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

getBlock() {
    setGlobalsForPeer0Org1
    # peer channel fetch 10 -c mychannel -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.alanhou.org --tls \
    #     --cafile $ORDERER_CA

    peer channel getinfo  -c mychannel -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.alanhou.org --tls \
        --cafile ${ORDERER_CA}
}

# getBlock

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.alanhou.org:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.alanhou.org:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

checkCommitReadiness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness \
        --collections-config $PRIVATE_DATA_CONFIG \
        --channelID ${CHANNEL_NAME} --name ${CC_NAME} --version ${VERSION} \
        --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# --collections-config ./artifacts/private-data/collections_config.json \
# --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \
approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.alanhou.org --tls ${CORE_PEER_TLS_ENABLED} \
        --cafile ${ORDERER_CA} --channelID ${CHANNEL_NAME} --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${VERSION}

    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadiness() {

    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readiness from org 1 ===================== "
}

# checkCommitReadiness

commitChaincodeDefinition() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.alanhou.org \
        --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} \
        --channelID ${CHANNEL_NAME} --name ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
        --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
        --version ${VERSION} --sequence ${VERSION} --init-required

}

# commitChaincodeDefinition

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.alanhou.org \
        --tls ${CORE_PEER_TLS_ENABLED} --cafile ${ORDERER_CA} \
        -C ${CHANNEL_NAME} -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
        --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
        --isInit -c '{"Args":[]}'

}


chaincodeInvoke() {
    # setGlobalsForPeer0Org1
    # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.alanhou.org \
    # --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    # --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    # --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA  \
    # -c '{"function":"initLedger","Args":[]}'

    setGlobalsForPeer0Org1

    ## Create Car
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.alanhou.org \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME}  \
    #     --peerAddresses localhost:7051 \
    #     --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA   \
    #     -c '{"function": "createCar","Args":["Car-ABCDEEE", "Audi", "R8", "Red", "Pavan"]}'

    ## Init ledger
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.alanhou.org \
        --tls ${CORE_PEER_TLS_ENABLED} \
        --cafile ${ORDERER_CA} \
        -C ${CHANNEL_NAME} -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles ${PEER0_ORG1_CA} \
        --peerAddresses localhost:9051 --tlsRootCertFiles ${PEER0_ORG2_CA} \
        -c '{"function": "initLedger","Args":[]}'
}

# chaincodeInvoke

chaincodeQuery() {
    setGlobalsForPeer0Org2

    # Query all cars
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

    # Query Car by Id
    peer chaincode query -C ${CHANNEL_NAME} -n ${CC_NAME} -c '{"function": "queryCar","Args":["CAR0"]}'
    #'{"Args":["GetSampleData","Key1"]}'

    # Query Private Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readPrivateCar","Args":["1111"]}'
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readCarPrivateDetails","Args":["1111"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
# presetup

packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadiness
approveForMyOrg2
checkCommitReadiness
commitChaincodeDefinition
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
