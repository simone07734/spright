#!/bin/bash

SPRIGHT_PATH=$1

if [ -z "$SPRIGHT_PATH" ] ; then
  echo "Usage: $ <SPRIGHT_PATH>"
  exit 1
fi

tmux set remain-on-exit on

echo "Creating tmux panes..."
for j in {0..5}
do
    tmux split-window -v -p 80 -t ${j}
    tmux select-layout -t ${j} tiled
done

echo "Configuring fds in tmux panes..."
for j in {1..6}
do
    tmux send-keys -t ${j} "cd /mydata/spright/" Enter
    tmux send-keys -t ${j} "export BIN_PATH=/mydata/spright/bin/" Enter
    sleep 0.1
done


echo "Testing S-SPRIGHT with dummy network functions..."
tmux send-keys -t 1 "./run.sh shm_mgr cfg/example.cfg" Enter
sleep 1
tmux send-keys -t 2 "./run.sh gateway" Enter
sleep 10
tmux send-keys -t 3 "./run.sh nf 1" Enter
sleep 1
tmux send-keys -t 4 "./run.sh nf 2" Enter
sleep 1
tmux send-keys -t 5 "./run.sh nf 3" Enter
sleep 1
tmux send-keys -t 6 "./run.sh nf 4" Enter

sleep 0.1

echo "Starting CPU usage collection..."
cd /mydata

if [ ! -d "dummy-test-results/" ] ; then
    echo "dummy-test-results/ DOES NOT exists."
    mkdir dummy-test-results/
fi

cd dummy-test-results

pidstat 1 3600 -G ^gateway_sk_msg$ > skmsg_gw.dummy.cpu & pidstat 1 3600 -G ^nf_sk_msg$ > skmsg_fn.dummy.cpu

echo "CPU usage collection is done!"
