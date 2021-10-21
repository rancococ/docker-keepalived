# docker-keepalived

base on alpine 3.11

environment and default value:
# 绑定网卡
KEEPALIVED_BIND_INTERFACE="ens33"
# 路由编号(两个节点相同)
KEEPALIVED_ROUTER_ID="100"
# 节点前缀
KEEPALIVED_NODE_PREFIX="node"
# 节点状态
KEEPALIVED_NODE_STATES="BACKUP,BACKUP"
# 节点优先级
KEEPALIVED_NODE_PRIORITYS="100,90"
# 节点地址
KEEPALIVED_NODE_IPS="192.168.8.161,192.168.8.162"
# 虚拟地址(dev:ip,dev:ip)
KEEPALIVED_VIRTUAL_IPS="ens33:192.168.8.160/24,ens33:192.168.9.160/24"
# 认证密码(两个节点相同)
KEEPALIVED_AUTH_PASS="abcd1234"
# 启动参数(config-id=node01,node02)
KEEPALIVED_COMMAND_LINE_ARGUMENTS="--log-detail --dump-conf --config-id node1"

docker run -it --rm --network=host \
-e "KEEPALIVED_BIND_INTERFACE=ens33" \
-e "KEEPALIVED_ROUTER_ID=100" \
-e "KEEPALIVED_NODE_PREFIX=node" \
-e "KEEPALIVED_NODE_STATES=BACKUP,BACKUP" \
-e "KEEPALIVED_NODE_PRIORITYS=100,90" \
-e "KEEPALIVED_NODE_IPS=192.168.8.52,192.168.8.53" \
-e "KEEPALIVED_VIRTUAL_IPS=ens33:192.168.8.160/24,ens33:192.168.9.160/24" \
-e "KEEPALIVED_AUTH_PASS=abcd1234" \
-e "KEEPALIVED_COMMAND_LINE_ARGUMENTS=--log-detail --dump-conf --config-id node01"  \
--cap-add=NET_RAW \
--cap-add=NET_ADMIN \
--cap-add=NET_BROADCAST \
c589c
