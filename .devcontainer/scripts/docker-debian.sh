#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Simplified Docker installation script for devcontainer
# Based on Microsoft's devcontainer scripts
#-------------------------------------------------------------------------------------------------------------

ENABLE_NONROOT_DOCKER=${1:-"true"}
SOURCE_SOCKET=${2:-"/var/run/docker-host.sock"}
TARGET_SOCKET=${3:-"/var/run/docker.sock"}
USERNAME=${4:-"vscode"}
USE_MOBY=${5:-"true"}

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Function to run apt-get if needed
apt_get_update_if_needed() {
    if [ ! -d "/var/lib/apt/lists" ] || [ "$(ls /var/lib/apt/lists/ | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update
    else
        echo "Skipping apt-get update."
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update_if_needed
        apt-get -y install --no-install-recommends "$@"
    fi
}

# Install Docker
install_docker() {
    echo "Installing Docker..."
    
    # Install prerequisites
    check_packages apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update and install Docker
    apt-get update
    apt-get install -y docker-ce-cli docker-compose-plugin
}

# Set up Docker socket forwarding
setup_docker_socket() {
    echo "Setting up Docker socket forwarding..."
    
    # Create docker-init script
    cat > /usr/local/share/docker-init.sh << 'EOF'
#!/bin/bash
set -e

# Start socat to forward docker socket if it doesn't exist
if [ ! -S "$TARGET_SOCKET" ]; then
    if [ -S "$SOURCE_SOCKET" ]; then
        echo "Starting Docker socket forward from $SOURCE_SOCKET to $TARGET_SOCKET..."
        socat UNIX-LISTEN:$TARGET_SOCKET,fork,mode=660,user=root,group=docker UNIX-CONNECT:$SOURCE_SOCKET &
    else
        echo "Docker socket $SOURCE_SOCKET not found. Make sure Docker is running on the host."
    fi
fi

# Execute the command passed to the script
exec "$@"
EOF
    
    chmod +x /usr/local/share/docker-init.sh
    
    # Install socat for socket forwarding
    check_packages socat
}

# Configure non-root access
configure_nonroot_access() {
    if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${USERNAME}" != "root" ]; then
        echo "Configuring non-root access for user ${USERNAME}..."
        
        # Create docker group if it doesn't exist
        if ! getent group docker > /dev/null 2>&1; then
            groupadd docker
        fi
        
        # Add user to docker group
        usermod -aG docker ${USERNAME}
        
        # Set permissions on docker socket
        echo "Setting up Docker socket permissions..."
        cat > /etc/sudoers.d/docker-socket << EOF
${USERNAME} ALL=(ALL) NOPASSWD: /bin/chmod 666 ${TARGET_SOCKET}
EOF
    fi
}

# Main installation
echo "Starting Docker installation..."

# Install Docker CLI
install_docker

# Set up socket forwarding
setup_docker_socket

# Configure non-root access
configure_nonroot_access

echo "Docker installation completed!"
echo "Note: The container uses socket forwarding to connect to the host's Docker daemon."
