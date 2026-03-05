#/bin/bash
# copied from sigcomm-experiment/env-setup/002-env_setup_master.sh
# ran in the dockerfile
# This script can be run with non-root user

echo "Installing libbpf"
cd /mydata # Use the extended disk with enough space

git clone --single-branch https://github.com/libbpf/libbpf.git
cd libbpf
git switch --detach v0.6.0
cd src
make -j $(nproc)
make install
echo "/usr/lib64/" | tee -a /etc/ld.so.conf
ldconfig
cd /mydata && rm -rf libbpf # remove source and build tree since no longer needed

echo "Installing DPDK"
cd /mydata # Use the extended disk with enough space

git clone --single-branch git://dpdk.org/dpdk
cd dpdk
git switch --detach v21.11
meson build
cd build
ninja
ninja install
ldconfig
cd /mydata && rm -rf dpdk # remove source and build tree since no longer needed

echo "build SPRIGHT"
cd /mydata # Use the extended disk with enough space

# git clone https://github.com/simone07734/spright.git
cd spright/src/cstl && make
cd ../../ && make
