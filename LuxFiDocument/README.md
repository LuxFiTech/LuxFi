# 保交链2.5自动化部署程序

## 开始使用

#### 准备

> 请确保运行环境为linux，并且支持兼容的Shell脚本语言

#### 安装

```sh
.Makefile
├── ark.sh
├── bin
│   ├── consus
│   ├── bridge
│   └── odyssey
├── etc
│   ├── functions
│   ├── genesis.template
│   ├── settings
│   └── settings.template
├── README.md
└── run
```

> 进入保交链2.5项目根目录运行

```shell
$# make && make ark
```

> 该命令会在部署保交链2.5的时候，首先检查部署脚本的完备性，如果部署脚本不完备，则会触发拉取远端仓库，并且需要权限验证和监控系统环境变量的设置，然后会编译保交链2.5的可执行文件，并将编译好的文件放置在`.bin`目录中，其中consus为共识引擎的可执行文件，bridge为前置应用与保交链2.5交互的接口程序，odyssey为保交链2.5的核心系统的可执行文件。

## 使用说明

#### 系统初始化

```go
./ark.sh init
```

> 该命令将在`.run`目录中创建记录日志的目录`.run/logs`，并且会初始化保交链2.5核心系统，为其在`.run`建立相关的节点数据文件在`.run/data/odyssey`，也为保交链2.5的共识引擎建立配置文件在`.run/data/config`中，配置包括Genesis block 节点的共识角色以及公私钥等

#### 系统启动

```go
./ark.sh start
```

> 该命令用于启动已经配置好的保交链2.5节点程序，首先启动共识引擎，然后记录并监听共识引擎的进程，共识引擎根据初始化时候的数据开启共识接口，等待核心系统连接；同时核心系统启动，核心系统与共识引擎对接，然后发包请共识引擎确认，共识引擎确认后，与核心系统建立长连接，至此节点启动完毕

#### 节点组网

> 当有一个节点启动后，其他节点需要加入该网络则需要被加入节点首先使用命令：

```go
./ark.sh info
==Genesis Info:==
{
  "genesis_time": "2019-08-06T01:35:11.928471449Z",
  "chain_id": "test-chain-BQG22M",
  "consensus_params": {
    "block": {
      "max_bytes": "22020096",
      "max_gas": "-1",
      "time_iota_ms": "1000"
    },
    "evidence": {
      "max_age": "100000"
    },
    "validator": {
      "pub_key_types": [
        "ed25519"
      ]
    }
  },
  "validators": [
    {
      "address": "94F6A1E227D3ABCDC08CDB5B8D993E16FE0184F4",
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": "U1XbX1FhJx+pmfNN4SgdvJAhY6dxyCer/ROQv0Fz2Zg="
      },
      "power": "10",
      "name": ""
    }
  ],
  "app_hash": ""
}  
==Node Id:== 
365534d5b10f0049371b007bdb93004a81aa0e24
```

> 这条命令会显示出需要被加入的节点的Genesis信息和节点的ID，其他需要加入的节点通过在之前初始化中的配置文件里修改Genesis.json为需要被加入的节点的Genesis信息

```go
vi run/data/genesis.json
{
  "genesis_time": "2019-08-02T07:51:33.939942004Z",
  "chain_id": "test-chain-YUgA7t",
  "consensus_params": {
    "block": {
      "max_bytes": "22020096",
      "max_gas": "-1",
      "time_iota_ms": "1000"
    },
    "evidence": {
      "max_age": "100000"
    },
    "validator": {
      "pub_key_types": [
        "ed25519"
      ]
    }
  },
  "validators": [
    {
      "address": "CA89125453DB7904A569256AF5C1F8E476EAE999",
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": "QqXxqKxF4EB2fC17bxMvHEoteyXoZGThLfDETInMkQI="
      },
      "power": "10",
      "name": ""
    },
	{
      "address": "EAE3D5C672D0E0E50F8D85F569C5D7867D33D49F",
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": "mEm5eEIKSLqRYMcBiLV5f4hZFTK4oB1nBx2Zaq5C3gY="
      },
      "power": "10",
      "name": ""
    },
	{
      "address": "F75B2B92396A5A4F5EEE6867A31A2F04B5E43339",
      "pub_key": {
        "type": "tendermint/PubKeyEd25519",
        "value": "Ga1F2KtZCZE62ZqPFAdqHuI1yuAblUULcLHJ88evkNY="
      },
      "power": "10",
      "name": ""
    },
	…

  ], 
  "app_hash": ""
}
```

> 然后向配置文件里面添加需要被加入节点的ID，以及该节点ID对应的IP地址

```go
vi etc/settings

odys_rpcaddr=0.0.0.0
odys_rpcport=8545
odys_wsaddr=0.0.0.0
odys_wsport=8546
odys_corsdomain='*'

consus_p2p_laddr=tcp://0.0.0.0:26656
consus_rpc_laddr=tcp://0.0.0.0:26657
consus_proxy_app=tcp://127.0.0.1:26658
consus_seed_mode=false
consus_create_empty_blocks=false
# consus_persistent_peers=the_root_node_id_you_want_to_join@ip.address:26656
# consus_seed_peers=the_root_node_id_you_want_to_join@ip.address:26656
consus_persistent_peers=43c09f86ebf18cf5238e1608f2be0e2ddde5ba99@172.16.124.96:26656,5b7560fb1aa403184d6009ef9f83b22ebe2c4fee@172.16.124.97:26656,5b9158219545385a83acd1d90eb66a90c706e3c2@172.16.124.98:26656,f3f83113829d814e08602a752f7c60320143b8f1@172.16.124.99:26656
# consus_seed_peers=eb81347012a83038638369bed3dbf78f8e579137@172.16.123.66:26656

```

> 接着启动该节点，这个节点就可以直接加入已经启动好的节点的网络中运行了

#### 连接

```sh
./ark.sh attach
```

> 该条命令可以在节点启动并组网完成后使用，可以为用户提供与保交链2.5直接交互的接口，用户可以通过该接口查询保交链2.5的区块信息，交易信息，发送交易，部署合约等等

#### 状态

```sh
./ark.sh status
```

> 该条命令用于查询保交链2.5核心系统和共识引擎的进程运行状态

#### 停止

```sh
./ark.sh stop
```

> 该条命令可以将当前的节点的核心系统与共识引擎暂停，节点会退出当前网络，不再参与区块链的记账与交易的执行，同时节点之前在区块链网络中执行的数据不会被删除

#### 重启

```sh
./ark.sh restart
```

> 该命令可以让一个已经停止的节点重新加入之前的网络，在重启过程中，会监测当前节点数据的完备性，被从其他节点获取最新的数据，并重新检查这些数据获取到的最新交易的情况

#### 格式化

```sh
./ark.sh clear
```

> 该条命令可以在节点停止后，清除节点所有数据，如果您之前已经在一个网络中建立节点，并参与了记账，那么请谨慎使用该命令。

