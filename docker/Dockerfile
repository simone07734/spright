# Use Ubuntu 20.04 as the base image, as specified in the YAML
FROM ubuntu:20.04

# Ubuntu 20.04 image hangs unless timezone is set
RUN DEBIAN_FRONTEND=noninteractive \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# Install any necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libelf-dev \
    libpcap-dev \
    libnuma-dev \
    libconfig-dev \
    libbpf-dev \
    uuid-dev \
    dpdk-dev \
    pkg-config \
    iproute2 \
    gettext-base

# Set up working directory for SPRIGHT
WORKDIR /mydata/spright

# Copy SPRIGHT source into container
COPY . /mydata/spright

# Build SPRIGHT
RUN make clean || true
RUN make -j$(nproc)

# Copy entrypoint (script that starts shm_mgr, gateway, and functions)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
