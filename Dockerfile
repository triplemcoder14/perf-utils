FROM debian:bullseye-slim

MAINTAINER Muutassim-Mukhtar 

WORKDIR /var/www/app

# Install necessary packages
RUN apt-get update && apt-get install -y wget xz-utils make python3

# Download and install Linux tools
RUN LINUX_NUM=$(uname -r | cut -d'.' -f1) && \
    LINUX_VER=$(uname -r | cut -d'.' -f1-3 | cut -d'-' -f1) && \
    wget "https://cdn.kernel.org/pub/linux/kernel/v$LINUX_NUM.x/linux-$LINUX_VER.tar.xz" && \
    tar -xf "./linux-$LINUX_VER.tar.xz" && cd "linux-$LINUX_VER/tools/perf/" && \
    apt-get update && apt-get install -y python3-dev flex bison ocaml \ 
        libelf-dev libdw-dev systemtap-sdt-dev libunwind-dev \
        libperl-dev binutils-dev libzstd-dev libcap-dev \
        libnuma-dev libbabeltrace-dev && \
    make -C . && make install && \
    cp perf /usr/local/bin && \
    cd / && rm -rf "linux-$LINUX_VER" "linux-$LINUX_VER.tar.xz"  # Clean up

# Install Nginx with debug symbols
RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y gnupg1 \
    && NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62; \
    found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
        apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1; \
    nginxPackages="nginx nginx-dbg" && \
    echo "deb http://nginx.org/packages/mainline/debian/ bullseye nginx" >> /etc/apt/sources.list && \
    echo "deb-src http://nginx.org/packages/mainline/debian/ bullseye nginx" >> /etc/apt/sources.list && \
    apt-get update && apt-get build-dep -y $nginxPackages && \
    apt-get install -y $nginxPackages

COPY conf/nginx.conf /etc/nginx/sites-available/default

# Expose port 80
EXPOSE 80

# Run Nginx in the foreground
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]