#!/bin/bash
set -e

export RTE_RING=1

# automatically assign hostname and ip
SERVICE_NAME=${SERVICE_NAME:-$(hostname)}
POD_IP=${POD_IP:-$(hostname -i | awk '{print $1}')}
export SERVICE_NAME POD_IP

envsubst < cfg/nf.cfg.template > cfg/runtime.cfg

echo "Starting shm_mgr..."
./run.sh shm_mgr cfg/runtime.cfg &
sleep 2

echo "Starting gateway..."
./run.sh gateway &
sleep 2

echo "Starting 4 network functions..."

./run.sh nf 1 &
./run.sh nf 2 &
./run.sh nf 3 &
./run.sh nf 4 &

wait