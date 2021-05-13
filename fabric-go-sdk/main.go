package main

import (
	"fabric-go-sdk/sdkInit"
	"fmt"
	"os"
)

// 定义链码名称与版本
const (
	cc_name    = "sacc"
	cc_version = "1.0.0"
)

func main() {

	homeDir, _ := os.UserHomeDir()
	// 初始化组织信息
	orgs := []*sdkInit.OrgInfo{
		{
			OrgAdminUser:  "Admin",
			OrgName:       "Org1",
			OrgMspId:      "Org1MSP",
			OrgUser:       "User1",
			OrgPeerNum:    1,
			OrgAnchorFile: homeDir + "/fabric-go-sdk/fixtures/channel-artifacts/Org1MSPanchors.tx",
		},
		{
			OrgAdminUser:  "Admin",
			OrgName:       "Org2",
			OrgMspId:      "Org2MSP",
			OrgUser:       "User1",
			OrgPeerNum:    1,
			OrgAnchorFile: homeDir + "/fabric-go-sdk/fixtures/channel-artifacts/Org2MSPanchors.tx",
		},
	}

	// 初始化sdk相关信息
	info := sdkInit.SdkEnvInfo{
		ChannelID:        "mychannel",
		ChannelConfig:    homeDir + "/fabric-go-sdk/fixtures/channel-artifacts/mychannel.tx",
		Orgs:             orgs,
		OrdererAdminUser: "Admin",
		OrdererOrgName:   "OrdererOrg",
		OrdererEndpoint:  "orderer.alanhou.org",
		ChaincodeID:      cc_name,
		ChaincodePath:    homeDir + "/fabric-go-sdk/chaincode/",
		ChaincodeVersion: cc_version,
	}

	// 调用setup方法将sdk初始化
	sdk, err := sdkInit.Setup("config.yaml", &info)
	if err != nil {
		fmt.Println(">> SDK setup error:", err)
		os.Exit(-1)
	}

	// 调用CreateAndJoinChannel方法，创建并加入通道
	if err := sdkInit.CreateAndJoinChannel(&info); err != nil {
		fmt.Println(">> Create channel and join error:", err)
		os.Exit(-1)
	}

	// 调用CreateCCLifecycle方法实现链码生命周期
	if err := sdkInit.CreateCCLifecycle(&info, 1, false, sdk); err != nil {
		fmt.Println(">> create chaincode lifecycle error: %v", err)
		os.Exit(-1)
	}

	// invoke chaincode set status
	fmt.Println(">> 通过链码外部服务设置链码状态......")

}
