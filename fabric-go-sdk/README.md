## execute all the commands in this directory


### generate crypto materials & create artifacts 
`cmd/create-artifacts.sh`

### start up orderer nodes && peer nodes
`docker-compose up -d`


### createChannel && joinChannel && updateAnchorPeers
`cmd/create-channel.sh`

### deploy chain code
`cmd/deploy-chaincode.sh`

### fabcar sample chaincode
fabric-demo/fabric-samples/chaincode/fabcar/go/

### create certificate through customized script
```
cd create-certificate-with-ca
docker-compose up -d
./create-certificate-with-ca.sh
cp crypto-config-ca ../crypto-config
```
now you get the same thing as from the cryptogen command execution, now comment the lines to cryptogen command line in cmd/create-artifacts.sh, you'll get the same services up and running as before
```
cd ..
cmd/create-artifacts.sh
docker-compose up -d
cmd/create-channel.sh
cmd/deploy-chaincode.sh
```


```
# 安装链码依赖包
cd chaincode
go mod init chaincode
go mod vendor
# 添加项目依赖包
cd ..
go mod init fabric-go-sdk
go mod tidy

# 打包、运行
go build
./fabric-go-sdk
```
