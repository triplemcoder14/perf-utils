# Performance Triage Utility Docker Image

this Docker image is based on Debian and includes the ``` perf ```  utility, designed for use on Docker for debian-based linux system. It comes pre-configured with Nginx to demonstrate how to use ``perf`` for performance profiling. feel free to adapt the image to include other utilities as needed

## Features

- Debian base image
- ``perf`` installed for performance profiling
- Nginx included as a web server (modifiable)
- Privileged mode support for ``perf`` commands

## Usage

### Running the Container

start the container in a privileged mode, run:

``docker run --name perf-utils --privileged -p 8080:80 -d muuta/perfutils``

### Accessing the Container

create a bash shell in the running container, execute:

``docker exec -it perf-utils bash``

### Running perf Commands

Once inside the container, you can run ``perf`` commands to probe your applications. Here are some examples:

1. List available probes for Nginx:

``perf probe -x /usr/sbin/nginx -F``


output:

![output4](https://github.com/user-attachments/assets/5c3114a6-9988-4d26-ab5e-7607ed35f10e)

2. Inspect specific function variables:

``perf probe -x `which nginx` -V ngx_accept_log_error``

output:

![output8](https://github.com/user-attachments/assets/c30d72a9-bce3-4a89-9795-ab4c7ddbdb07)


Feel free to customize this image by adding additional utilities or configurations as needed. Simply modify the Dockerfile to install any required packages or dependencies. cheers 









