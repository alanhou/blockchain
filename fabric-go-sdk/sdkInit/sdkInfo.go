package sdkInit

import (
	mspclient "github.com/hyperledger/fabric-sdk-go/pkg/client/msp"
	"github.com/hyperledger/fabric-sdk-go/pkg/client/resmgmt"
	contextAPI "github.com/hyperledger/fabric-sdk-go/pkg/common/providers/context"
)

type OrgInfo struct {
	OrgAdminUser          string                     //  管理员用户名，如"Admin"
	OrgName               string                     //  组织名，如"Org1"
	OrgMspId              string                     //  组织MSPid，如"Org1MSP"
	OrgUser               string                     //  用户名，如"User1"
	orgMspClient          *mspclient.Client          // MSP客户端
	OrgAdminClientContext *contextAPI.ClientProvider // 客户端上下文信息
	OrgResMgmt            *resmgmt.Client            // 资源管理客户端
	OrgPeerNum            int                        // 组织节点个数
	OrgAnchorFile         string                     //   锚节点配置文件路径
}

type SdkEnvInfo struct {
	// 通道信息
	ChannelID     string // 通道名称，如"simplecc"
	ChannelConfig string // 通道配置文件路径

	// 组织信息
	Orgs []*OrgInfo
	// 排序服务节点信息
	OrdererAdminUser     string                     // orederer管理员用户名，如"Admin"
	OrdererOrgName       string                     // orderer组织名，如"OrdererOrg"
	OrdererEndpoint      string                     // orderer端点，如"orderer.alanhou.org"
	OrdererClientContext *contextAPI.ClientProvider // orderer客户端上下文
	// 链码信息
	ChaincodeID      string // 链码名称
	ChaincodePath    string // 链码路径
	ChaincodeVersion string // 链码版本
}
