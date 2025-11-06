FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    clamav \
    clamav-libunrar \
    bash \
    curl \
    unzip \
    jq \
    coreutils \
    tzdata \
    ncurses \
    rsync \
    wget \
    bind-tools

# Install clamav-unofficial-sigs from GitHub
RUN mkdir -p /opt/tools && \
    curl -L https://github.com/extremeshok/clamav-unofficial-sigs/archive/master.zip -o /tmp/cus.zip && \
    unzip /tmp/cus.zip -d /opt/tools && \
    mv /opt/tools/clamav-unofficial-sigs-master /opt/clamav-unofficial-sigs && \
    chmod +x /opt/clamav-unofficial-sigs/clamav-unofficial-sigs.sh && \
    rm /tmp/cus.zip

# Create directories for signatures and output
RUN mkdir -p /var/lib/clamav /opt/output /opt/config

# Copy configuration overrides
COPY config/ /opt/config/
RUN mkdir -p /opt/work
COPY scripts/update_and_convert.sh /usr/local/bin/update_and_convert.sh
RUN chmod +x /usr/local/bin/update_and_convert.sh

RUN mkdir -p /etc/clamav-unofficial-sigs && \
    ln -s /opt/config/master.conf /etc/clamav-unofficial-sigs/master.conf && \
    ln -s /opt/config/os.conf /etc/clamav-unofficial-sigs/os.conf && \
    ln -s /opt/config/user.conf /etc/clamav-unofficial-sigs/user.conf && \
    ln -s /opt/config/mirrors.dat /etc/clamav-unofficial-sigs/mirrors.dat

WORKDIR /opt
ENTRYPOINT ["/usr/local/bin/update_and_convert.sh"]