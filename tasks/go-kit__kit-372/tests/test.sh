#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Install Consul
apt-get update > /dev/null 2>&1 && apt-get install -y wget unzip default-jre > /dev/null 2>&1
wget -q https://releases.hashicorp.com/consul/1.0.7/consul_1.0.7_linux_amd64.zip
unzip -q consul_1.0.7_linux_amd64.zip
mv consul /usr/local/bin/
consul agent -dev > /dev/null 2>&1 &
CONSUL_PID=$!

# Install and start ZooKeeper
wget -q https://archive.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
tar -xzf zookeeper-3.4.10.tar.gz
cd zookeeper-3.4.10
cp conf/zoo_sample.cfg conf/zoo.cfg
bin/zkServer.sh start > /dev/null 2>&1
cd /go/src/github.com/go-kit/kit

# Wait for services to be ready
sleep 3

# Set environment variables for integration tests
# Note: BASE (buggy) code uses CONSUL_ADDRESS, but we set CONSUL_ADDR
# This will cause the buggy Consul test to fail
export CONSUL_ADDR=localhost:8500
export ZK_ADDR=localhost:2181

# Run integration tests with the integration build tag
go test -v -tags integration ./sd/consul ./sd/zk 2>&1
test_status=$?

# Cleanup
kill $CONSUL_PID 2>/dev/null || true
zookeeper-3.4.10/bin/zkServer.sh stop > /dev/null 2>&1 || true

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
