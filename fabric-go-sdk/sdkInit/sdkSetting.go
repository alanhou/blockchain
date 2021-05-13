package sdkInit

import (
	"fmt"

	"strings"

	mb "github.com/hyperledger/fabric-protos-go/msp"
	pb "github.com/hyperledger/fabric-protos-go/peer"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/channel"
	mspclient "github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/retry"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/errors/status"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/providers/fab"
	"github.com/hyperledger/fabric-sdk-go/pkg/common/providers/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	lcpackager "github.com/hyperledger/fabric-sdk-go/pkg/fab/ccpackager/lifecycle"
	"github.com/hyperledger/fabric-sdk-go/pkg/fabsdk"
	"github.com/hyperledger/fabric-sdk-go/third_party/github.com/hyperledger/fabric/common/policydsl"
)

func Setup(configFile string, info *SdkEnvInfo) (*fabsdk.FabricSDK, error) {
	var err error
	// 使用fabsdk包的new方法根据config.yaml文件提供的网络信息初始化sdk
	sdk, err := fabsdk.New(config.FromFile(configFile))
	if err != nil {
		return nil, err
	}
	// 为组织获得Client句柄和Context信息
	for _, org := range info.Orgs {
		// 初始化组织msp客户端
		org.orgMspClient, err = mspclient.New(sdk.Context(), mspclient.WithOrg(org.OrgName))
		if err != nil {
			return nil, err
		}
		// 创建所有所需上下文信息
		orgContext := sdk.Context(fabsdk.WithUser(org.OrgAdminUser), fabsdk.WithOrg(org.OrgName))
		org.OrgAdminClientContext = &orgContext

		// 新建客户端资源管理器实例
		resMgmtClient, err := resmgmt.New(orgContext)
		if err != nil {
			return nil, fmt.Errorf("根据指定的资源管理客户端Context创建通道管理客户端失败: %v", err)
		}
		org.OrgResMgmt = resMgmtClient
	}

	// 为Orderer获得Context信息
	ordererClientContext := sdk.Context(fabsdk.WithUser(info.OrdererAdminUser), fabsdk.WithOrg(info.OrdererOrgName))
	info.OrdererClientContext = &ordererClientContext
	return sdk, nil
}

func CreateAndJoinChannel(info *SdkEnvInfo) error {
	fmt.Println(">> 开始创建通道......")
	if len(info.Orgs) == 0 {
		return fmt.Errorf("通道组织不能为空，请提供组织信息")
	}

	// 获得所有组织的签名信息
	signIds := []msp.SigningIdentity{}
	for _, org := range info.Orgs {
		// Get signing identity that is used to sign create channel request
		orgSignId, err := org.orgMspClient.GetSigningIdentity(org.OrgAdminUser)
		if err != nil {
			return fmt.Errorf("GetSigningIdentity error: %v", err)
		}
		signIds = append(signIds, orgSignId)
	}

	// 创建通道，createChannel方法在下面定义
	if err := createChannel(signIds, info); err != nil {
		return fmt.Errorf("Create channel error: %v", err)
	}

	fmt.Println(">> 创建通道成功")

	fmt.Println(">> 加入通道......")
	for _, org := range info.Orgs {
		// 加入通道
		if err := org.OrgResMgmt.JoinChannel(info.ChannelID, resmgmt.WithRetry(retry.DefaultResMgmtOpts), resmgmt.WithOrdererEndpoint("orderer.alanhou.org")); err != nil {
			return fmt.Errorf("%s peers failed to JoinChannel: %v", org.OrgName, err)
		}
	}
	fmt.Println(">> 加入通道成功")
	return nil
}

func createChannel(signIDs []msp.SigningIdentity, info *SdkEnvInfo) error {
	// Channel management client 负责管理通道，如创建更新通道
	chMgmtClient, err := resmgmt.New(*info.OrdererClientContext)
	if err != nil {
		return fmt.Errorf("Channel management client create error: %v", err)
	}

	// 根据channel.tx创建通道
	req := resmgmt.SaveChannelRequest{ChannelID: info.ChannelID,
		ChannelConfigPath: info.ChannelConfig,
		SigningIdentities: signIDs}

	if _, err := chMgmtClient.SaveChannel(req, resmgmt.WithRetry(retry.DefaultResMgmtOpts), resmgmt.WithOrdererEndpoint("orderer.alanhou.org")); err != nil {
		return fmt.Errorf("error should be nil for SaveChannel of orgchannel: %v", err)
	}

	fmt.Println(">>>> 使用每个org的管理员身份更新锚节点配置...")
	//根据锚节点文件更新锚节点，与上面创建通道流程相同
	for i, org := range info.Orgs {
		req = resmgmt.SaveChannelRequest{ChannelID: info.ChannelID,
			ChannelConfigPath: org.OrgAnchorFile,
			SigningIdentities: []msp.SigningIdentity{signIDs[i]}}

		if _, err = org.OrgResMgmt.SaveChannel(req, resmgmt.WithRetry(retry.DefaultResMgmtOpts), resmgmt.WithOrdererEndpoint("orderer.alanhou.org")); err != nil {
			return fmt.Errorf("SaveChannel for anchor org %s error: %v", org.OrgName, err)
		}
	}
	fmt.Println(">>>> 使用每个org的管理员身份更新锚节点配置完成")

	return nil
}

func packageCC(ccName, ccVersion, ccpath string) (string, []byte, error) {

	label := ccName + "_" + ccVersion // 链码的标签
	desc := &lcpackager.Descriptor{   // 使用lcpackager包中的Descriptor结构体添加描述信息
		Path:  ccpath,                  //链码路径
		Type:  pb.ChaincodeSpec_GOLANG, //链码的语言
		Label: label,                   // 链码的标签
	}
	ccPkg, err := lcpackager.NewCCPackage(desc) // 使用lcpackager包中NewCCPackage方法对链码进行打包
	if err != nil {
		return "", nil, fmt.Errorf("Package chaincode source error: %v", err)
	}
	return desc.Label, ccPkg, nil
}

func installCC(label string, ccPkg []byte, orgs []*OrgInfo) error {
	installCCReq := resmgmt.LifecycleInstallCCRequest{
		Label:   label,
		Package: ccPkg,
	}
	// 使用lcpackager中的ComputePackageID方法查询并返回链码的packageID
	packageID := lcpackager.ComputePackageID(installCCReq.Label, installCCReq.Package)
	for _, org := range orgs {
		orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, org.OrgPeerNum)
		if err != nil {
			fmt.Errorf("DiscoverLocalPeers error: %v", err)
		}
		// 检查是否安装链码，如果未安装则继续执行
		if flag, _ := checkInstalled(packageID, orgPeers[0], org.OrgResMgmt); flag == false {
			// 使用resmgmt中的LifecycleInstallCC方法安装链码，其中WithRetry方法为安装不成功时重试安装，DefaultResMgmtOpts为默认的重试安装规则
			if _, err := org.OrgResMgmt.LifecycleInstallCC(installCCReq, resmgmt.WithTargets(orgPeers...), resmgmt.WithRetry(retry.DefaultResMgmtOpts)); err != nil {
				return fmt.Errorf("LifecycleInstallCC error: %v", err)
			}
		}
	}
	return nil
}

//检查是否安装过链码
func checkInstalled(packageID string, peer fab.Peer, client *resmgmt.Client) (bool, error) {
	flag := false
	resp1, err := client.LifecycleQueryInstalledCC(resmgmt.WithTargets(peer))
	if err != nil {
		return flag, fmt.Errorf("LifecycleQueryInstalledCC error: %v", err)
	}
	for _, t := range resp1 {
		if t.PackageID == packageID {
			flag = true
		}
	}
	return flag, nil
}

func getInstalledCCPackage(packageID string, org *OrgInfo) error {
	// use org1
	orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, 1)
	if err != nil {
		return fmt.Errorf("DiscoverLocalPeers error: %v", err)
	}
	// 使用resmgmt中的LifecycleGetInstalledCCPackage方法，对于给定的packageID检索已安装的链码包
	if _, err := org.OrgResMgmt.LifecycleGetInstalledCCPackage(packageID, resmgmt.WithTargets([]fab.Peer{orgPeers[0]}...)); err != nil {
		return fmt.Errorf("LifecycleGetInstalledCCPackage error: %v", err)
	}
	return nil
}

func queryInstalled(packageID string, org *OrgInfo) error {
	orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, 1)
	if err != nil {
		return fmt.Errorf("DiscoverLocalPeers error: %v", err)
	}
	// 使用resmgmt中的LifecycleQueryInstalledCC方法，返回在指定节点上安装的链码packageID
	resp1, err := org.OrgResMgmt.LifecycleQueryInstalledCC(resmgmt.WithTargets([]fab.Peer{orgPeers[0]}...))
	if err != nil {
		return fmt.Errorf("LifecycleQueryInstalledCC error: %v", err)
	}
	packageID1 := ""
	for _, t := range resp1 {
		if t.PackageID == packageID {
			packageID1 = t.PackageID
		}
	}
	// 查询的packageID与给定的packageID不一致则报错
	if !strings.EqualFold(packageID, packageID1) {
		return fmt.Errorf("check package id error")
	}
	return nil
}

func approveCC(packageID string, ccName, ccVersion string, sequence int64, channelID string, orgs []*OrgInfo, ordererEndpoint string) error {
	mspIDs := []string{}
	// 获取各个组织的mspID
	for _, org := range orgs {
		mspIDs = append(mspIDs, org.OrgMspId)
	}
	// 签名策略，由所有给出的mspid签名
	ccPolicy := policydsl.SignedByNOutOfGivenRole(int32(len(mspIDs)), mb.MSPRole_MEMBER, mspIDs)
	// approve所需参数
	approveCCReq := resmgmt.LifecycleApproveCCRequest{
		Name:              ccName,    // 链码名
		Version:           ccVersion, // 版本
		PackageID:         packageID, // 链码包id
		Sequence:          sequence,  // 序列号
		EndorsementPlugin: "escc",    // 系统内置链码escc
		ValidationPlugin:  "vscc",    // 系统内置链码vscc
		SignaturePolicy:   ccPolicy,  // 组织签名策略
		InitRequired:      true,      // 是否初始化
	}

	for _, org := range orgs {
		orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, org.OrgPeerNum)
		fmt.Printf(">>> chaincode approved by %s peers:\n", org.OrgName)
		for _, p := range orgPeers {
			fmt.Printf("	%s\n", p.URL())
		}

		if err != nil {
			return fmt.Errorf("DiscoverLocalPeers error: %v", err)
		}
		// 使用resmgmt中的LifecycleApproveCC方法为组织批准链码
		if _, err := org.OrgResMgmt.LifecycleApproveCC(channelID, approveCCReq, resmgmt.WithTargets(orgPeers...), resmgmt.WithOrdererEndpoint(ordererEndpoint), resmgmt.WithRetry(retry.DefaultResMgmtOpts)); err != nil {
			fmt.Errorf("LifecycleApproveCC error: %v", err)
		}
	}
	return nil
}

func queryApprovedCC(ccName string, sequence int64, channelID string, orgs []*OrgInfo) error {
	// queryApproved所需参数
	queryApprovedCCReq := resmgmt.LifecycleQueryApprovedCCRequest{
		Name:     ccName,   // 链码名称
		Sequence: sequence, // 序列号
	}

	for _, org := range orgs {
		orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, org.OrgPeerNum)
		if err != nil {
			return fmt.Errorf("DiscoverLocalPeers error: %v", err)
		}
		// Query approve cc
		for _, p := range orgPeers {
			resp, err := retry.NewInvoker(retry.New(retry.TestRetryOpts)).Invoke(
				func() (interface{}, error) {
					// LifecycleQueryApprovedCC返回有关已批准的链码定义的信息
					resp1, err := org.OrgResMgmt.LifecycleQueryApprovedCC(channelID, queryApprovedCCReq, resmgmt.WithTargets(p))
					if err != nil {
						return nil, status.New(status.TestStatus, status.GenericTransient.ToInt32(), fmt.Sprintf("LifecycleQueryApprovedCC returned error: %v", err), nil)
					}
					return resp1, err
				},
			)
			if err != nil {
				return fmt.Errorf("Org %s Peer %s NewInvoker error: %v", org.OrgName, p.URL(), err)
			}
			if resp == nil {
				return fmt.Errorf("Org %s Peer %s Got nil invoker", org.OrgName, p.URL())
			}
		}
	}
	return nil
}

func checkCCCommitReadiness(packageID string, ccName, ccVersion string, sequence int64, channelID string, orgs []*OrgInfo) error {
	mspIds := []string{}
	for _, org := range orgs {
		mspIds = append(mspIds, org.OrgMspId)
	}
	// 签名策略，由所有给出的mspid签名
	ccPolicy := policydsl.SignedByNOutOfGivenRole(int32(len(mspIds)), mb.MSPRole_MEMBER, mspIds)
	// 所需所有参数，同上
	req := resmgmt.LifecycleCheckCCCommitReadinessRequest{
		Name:    ccName,
		Version: ccVersion,
		//PackageID:         packageID,
		EndorsementPlugin: "escc",
		ValidationPlugin:  "vscc",
		SignaturePolicy:   ccPolicy,
		Sequence:          sequence,
		InitRequired:      true,
	}
	for _, org := range orgs {
		orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, org.OrgPeerNum)
		if err != nil {
			fmt.Errorf("DiscoverLocalPeers error: %v", err)
		}
		for _, p := range orgPeers {
			resp, err := retry.NewInvoker(retry.New(retry.TestRetryOpts)).Invoke(
				func() (interface{}, error) {
					// 使用resmgmt中的LifecycleCheckCCCommitReadiness方法检查链代码的“提交准备”,返回组织批准。
					resp1, err := org.OrgResMgmt.LifecycleCheckCCCommitReadiness(channelID, req, resmgmt.WithTargets(p))
					fmt.Printf("LifecycleCheckCCCommitReadiness cc = %v, = %v\n", ccName, resp1)
					if err != nil {
						return nil, status.New(status.TestStatus, status.GenericTransient.ToInt32(), fmt.Sprintf("LifecycleCheckCCCommitReadiness returned error: %v", err), nil)
					}
					flag := true
					for _, r := range resp1.Approvals {
						flag = flag && r
					}
					if !flag {
						return nil, status.New(status.TestStatus, status.GenericTransient.ToInt32(), fmt.Sprintf("LifecycleCheckCCCommitReadiness returned : %v", resp1), nil)
					}
					return resp1, err
				},
			)
			if err != nil {
				return fmt.Errorf("NewInvoker error: %v", err)
			}
			if resp == nil {
				return fmt.Errorf("Got nill invoker response")
			}
		}
	}

	return nil
}

func commitCC(ccName, ccVersion string, sequence int64, channelID string, orgs []*OrgInfo, ordererEndpoint string) error {
	mspIDs := []string{}
	for _, org := range orgs {
		mspIDs = append(mspIDs, org.OrgMspId)
	}
	ccPolicy := policydsl.SignedByNOutOfGivenRole(int32(len(mspIDs)), mb.MSPRole_MEMBER, mspIDs)
	// commit所需参数信息，内容同上
	req := resmgmt.LifecycleCommitCCRequest{
		Name:              ccName,
		Version:           ccVersion,
		Sequence:          sequence,
		EndorsementPlugin: "escc",
		ValidationPlugin:  "vscc",
		SignaturePolicy:   ccPolicy,
		InitRequired:      true,
	}
	// LifecycleCommitCC将链代码提交给给定的通道
	_, err := orgs[0].OrgResMgmt.LifecycleCommitCC(channelID, req, resmgmt.WithOrdererEndpoint(ordererEndpoint), resmgmt.WithRetry(retry.DefaultResMgmtOpts))
	if err != nil {
		return fmt.Errorf("LifecycleCommitCC error: %v", err)
	}
	return nil
}

func queryCommittedCC(ccName string, channelID string, sequence int64, orgs []*OrgInfo) error {
	req := resmgmt.LifecycleQueryCommittedCCRequest{
		Name: ccName,
	}

	for _, org := range orgs {
		orgPeers, err := DiscoverLocalPeers(*org.OrgAdminClientContext, org.OrgPeerNum)
		if err != nil {
			return fmt.Errorf("DiscoverLocalPeers error: %v", err)
		}
		for _, p := range orgPeers {
			resp, err := retry.NewInvoker(retry.New(retry.TestRetryOpts)).Invoke(
				func() (interface{}, error) {
					// LifecycleQueryCommittedCC查询给定通道上提交的链码
					resp1, err := org.OrgResMgmt.LifecycleQueryCommittedCC(channelID, req, resmgmt.WithTargets(p))
					if err != nil {
						return nil, status.New(status.TestStatus, status.GenericTransient.ToInt32(), fmt.Sprintf("LifecycleQueryCommittedCC returned error: %v", err), nil)
					}
					flag := false
					for _, r := range resp1 {
						if r.Name == ccName && r.Sequence == sequence {
							flag = true
							break
						}
					}
					if !flag {
						return nil, status.New(status.TestStatus, status.GenericTransient.ToInt32(), fmt.Sprintf("LifecycleQueryCommittedCC returned : %v", resp1), nil)
					}
					return resp1, err
				},
			)
			if err != nil {
				return fmt.Errorf("NewInvoker error: %v", err)
			}
			if resp == nil {
				return fmt.Errorf("Got nil invoker response")
			}
		}
	}
	return nil
}

func initCC(ccName string, upgrade bool, channelID string, org *OrgInfo, sdk *fabsdk.FabricSDK) error {
	// 准备通道客户端上下文
	clientChannelContext := sdk.ChannelContext(channelID, fabsdk.WithUser(org.OrgUser), fabsdk.WithOrg(org.OrgName))
	// 通道客户端用于查询执行交易
	client, err := channel.New(clientChannelContext)
	if err != nil {
		return fmt.Errorf("Failed to create new channel client: %s", err)
	}

	// 调用链码初始化
	_, err = client.Execute(channel.Request{ChaincodeID: ccName, Fcn: "init", Args: nil, IsInit: true},
		channel.WithRetry(retry.DefaultChannelOpts))
	if err != nil {
		return fmt.Errorf("Failed to init: %s", err)
	}
	return nil
}

func CreateCCLifecycle(info *SdkEnvInfo, sequence int64, upgrade bool, sdk *fabsdk.FabricSDK) error {
	if len(info.Orgs) == 0 {
		return fmt.Errorf("the number of organization should not be zero.")
	}
	// 打包链码
	fmt.Println(">> 开始打包链码......")
	label, ccPkg, err := packageCC(info.ChaincodeID, info.ChaincodeVersion, info.ChaincodePath)
	if err != nil {
		return fmt.Errorf("pakcagecc error: %v", err)
	}
	packageID := lcpackager.ComputePackageID(label, ccPkg)
	fmt.Println(">> 打包链码成功")

	// 安装链码
	fmt.Println(">> 开始安装链码......")
	if err := installCC(label, ccPkg, info.Orgs); err != nil {
		return fmt.Errorf("installCC error: %v", err)
	}

	// 检索已安装链码包
	if err := getInstalledCCPackage(packageID, info.Orgs[0]); err != nil {
		return fmt.Errorf("getInstalledCCPackage error: %v", err)
	}

	// 查询已安装链码
	if err := queryInstalled(packageID, info.Orgs[0]); err != nil {
		return fmt.Errorf("queryInstalled error: %v", err)
	}
	fmt.Println(">> 安装链码成功")

	// 批准链码
	fmt.Println(">> 组织认可智能合约定义......")
	if err := approveCC(packageID, info.ChaincodeID, info.ChaincodeVersion, sequence, info.ChannelID, info.Orgs, info.OrdererEndpoint); err != nil {
		return fmt.Errorf("approveCC error: %v", err)
	}

	// 查询批准
	if err := queryApprovedCC(info.ChaincodeID, sequence, info.ChannelID, info.Orgs); err != nil {
		return fmt.Errorf("queryApprovedCC error: %v", err)
	}
	fmt.Println(">> 组织认可智能合约定义完成")

	// 检查智能合约是否就绪
	fmt.Println(">> 检查智能合约是否就绪......")
	if err := checkCCCommitReadiness(packageID, info.ChaincodeID, info.ChaincodeVersion, sequence, info.ChannelID, info.Orgs); err != nil {
		return fmt.Errorf("checkCCCommitReadiness error: %v", err)
	}
	fmt.Println(">> 智能合约已经就绪")

	// Commit
	fmt.Println(">> 提交智能合约定义......")
	if err := commitCC(info.ChaincodeID, info.ChaincodeVersion, sequence, info.ChannelID, info.Orgs, info.OrdererEndpoint); err != nil {
		return fmt.Errorf("commitCC error: %v", err)
	}
	// 查询Commit结果
	if err := queryCommittedCC(info.ChaincodeID, info.ChannelID, sequence, info.Orgs); err != nil {
		return fmt.Errorf("queryCommittedCC error: %v", err)
	}
	fmt.Println(">> 智能合约定义提交完成")

	// 初始化
	fmt.Println(">> 调用智能合约初始化方法......")
	if err := initCC(info.ChaincodeID, upgrade, info.ChannelID, info.Orgs[0], sdk); err != nil {
		return fmt.Errorf("initCC error: %v", err)
	}
	fmt.Println(">> 完成智能合约初始化")
	return nil
}
