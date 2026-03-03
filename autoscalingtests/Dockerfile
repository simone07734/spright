# Use Ubuntu 20.04 as the base image, as specified in the YAML
FROM ubuntu:20.04

# Ubuntu 20.04 image hangs unless timezone is set
RUN DEBIAN_FRONTEND=noninteractive \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# Install any necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    flex \
    bison \
    build-essential \
    dwarves \
    libssl-dev \
    libelf-dev \
    libnuma-dev \
    pkg-config \
    python3-pip \
    python3-pyelftools \
    libconfig-dev \
    golang \
    clang \
    gcc-multilib \
    uuid-dev \
    sysstat \
    conntrack

RUN pip3 install meson ninja

# Set up working directory for SPRIGHT
WORKDIR /mydata/spright

# Copy SPRIGHT source into container
COPY . /mydata/spright

# run setup script to install libbpf, dpdk, setup hugepages, and build spright
RUN chmod +x env-setup.sh
RUN env-setup.sh

# Build SPRIGHT
# RUN make clean || true
# RUN make -j$(nproc)

# Copy entrypoint (script that starts shm_mgr, gateway, and functions)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
