FROM debian:bullseye-slim

MAINTAINER Muutassim-Mukhtar <mukhy16@gmail.com>

WORKDIR /var/www/app

# Install necessary packages
RUN apt-get update && apt-get install -y wget xz-utils make python3 curl gnupg2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install Linux kernel tools
RUN LINUX_VER="5.15.127" && \
    wget "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$LINUX_VER.tar.xz" && \
    tar -xf "./linux-$LINUX_VER.tar.xz" && \
    cd "linux-$LINUX_VER/tools/perf/" && \
    apt-get update && apt-get install -y python3-dev flex bison ocaml \ 
        libelf-dev libdw-dev systemtap-sdt-dev libunwind-dev \
        libperl-dev binutils-dev libzstd-dev libcap-dev \
        libnuma-dev libbabeltrace-dev && \
    make -C . && make install && \
    cp perf /usr/local/bin && \
    cd / && rm -rf "linux-$LINUX_VER" "linux-$LINUX_VER.tar.xz"  # Clean up

# Install Nginx with debug symbols
RUN set -ex && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian/ bullseye nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian/ bullseye nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-get update && \
    apt-get build-dep -y nginx && \
    apt-get install -y nginx nginx-dbg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY config/nginx.conf /etc/nginx/sites-available/default

# Expose port 80
EXPOSE 80

# Run Nginx in the foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]