#!/bin/bash
set -e

export RTE_RING=0
export BIN_PATH=/mydata/spright/bin/

ulimit -l unlimited

# automatically assign hostname and ip
SERVICE_NAME=${SERVICE_NAME:-$(hostname)}
POD_IP=${POD_IP:-$(hostname -i | awk '{print $1}')}
export SERVICE_NAME POD_IP

ls

envsubst < /mydata/spright/cfg/nf.cfg.template > /mydata/spright/cfg/runtime.cfg

echo "Starting shm_mgr..."
/mydata/spright/run.sh shm_mgr /mydata/spright/cfg/runtime.cfg &
sleep 2

echo "Starting gateway..."
/mydata/spright/run.sh gateway &
sleep 2

echo "Starting 4 network functions..."

/mydata/spright/run.sh nf 1 &
/mydata/spright/run.sh nf 2 &
/mydata/spright/run.sh nf 3 &
/mydata/spright/run.sh nf 4 &

wait