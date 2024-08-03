#!/bin/bash
as_ns () {
    NAME=$1
    NETNS=faucet-${NAME}
    shift
    sudo ip netns exec ${NETNS} $@
}

create_ns () {
    NAME=$1
    IP=$2
    NETNS=faucet-${NAME}
    sudo ip netns add ${NETNS}
    sudo ip link add dev veth-${NAME} type veth peer name veth0 netns ${NETNS}
    sudo ip link set dev veth-${NAME} up
    as_ns ${NAME} ip link set dev lo up
    [ -n "${IP}" ] && as_ns ${NAME} ip addr add dev veth0 ${IP}
    as_ns ${NAME} ip link set dev veth0 up
}

create_ns host1 10.0.0.1/24
create_ns host2 10.0.0.2/24
create_ns server 10.0.1.1/24
create_ns server2 10.0.1.10/24
create_ns bgp 10.0.1.2/24
as_ns host1 ip route add default via 10.0.0.254
as_ns host2 ip route add default via 10.0.0.254
as_ns server ip route add default via 10.0.1.254
as_ns server2 ip route add default via 10.0.1.254

sudo ovs-vsctl add-br br0 \
-- set bridge br0 other-config:datapath-id=0000000000000001 \
-- set bridge br0 other-config:disable-in-band=true \
-- set bridge br0 fail_mode=secure \
-- add-port br0 veth-host1 -- set interface veth-host1 ofport_request=1 \
-- add-port br0 veth-host2 -- set interface veth-host2 ofport_request=2 \
-- add-port br0 veth-server -- set interface veth-server ofport_request=3 \
-- add-port br0 veth-server2 -- set interface veth-server2 ofport_request=4 \
-- add-port br0 veth-bgp -- set interface veth-bgp ofport_request=5 \
-- set-controller br0 tcp:127.0.0.1:6653 tcp:127.0.0.1:6654

as_ns server ip address add 192.0.2.1/24 dev veth0


sudo ip link add veth-faucet type veth peer name veth-faucet-ovs
sudo ovs-vsctl add-port br0 veth-faucet-ovs -- set interface veth-faucet-ovs ofport_request=5
sudo ip addr add 10.0.1.3/24 dev veth-faucet
sudo ip link set veth-faucet up
sudo ip link set veth-faucet-ovs up

sudo ip link add dev veth-ospf-bird type veth peer name veth1 netns faucet-bgp
sudo ip link set dev veth-ospf-bird up
as_ns bgp ip addr add dev veth1 10.0.2.1/24
as_ns bgp ip link set dev veth1 up

sudo ip link add dev veth-bgp-false type veth peer name veth2 netns faucet-bgp
sudo ip link set dev veth-bgp-false up
as_ns bgp ip addr add dev veth2 10.0.1.4/24
as_ns bgp ip link set dev veth2 up

sudo ovs-vsctl add-port br0 veth-bgp-false -- set interface veth-bgp-false ofport_request=6

sudo ovs-vsctl add-port br0 veth-ospf-bird -- set interface veth-ospf-bird ofport_request=7

create_ns ospf 10.0.2.2/24
as_ns ospf ip route add 10.0.0.0/24 via 10.0.2.1
sudo ovs-vsctl add-port br0 veth-ospf -- set interface veth-ospf ofport_request=9


as_ns bgp bird -P /run/bird-bgp.pid
sudo systemctl reload faucet
