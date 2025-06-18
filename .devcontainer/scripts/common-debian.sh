#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Common setup script for devcontainer
# Based on Microsoft's devcontainer scripts
#-------------------------------------------------------------------------------------------------------------

INSTALL_ZSH=${1:-"false"}
USERNAME=${2:-"vscode"}
USER_UID=${3:-1000}
USER_GID=${4:-$USER_UID}
UPGRADE_PACKAGES=${5:-"false"}
INSTALL_OH_MY_ZSH=${6:-"true"}
ADD_NON_FREE_PACKAGES=${7:-"false"}

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

# Install common packages
install_common_packages() {
    echo "Installing common packages..."
    
    PACKAGE_LIST="apt-utils \
        dialog \
        git \
        openssh-client \
        gnupg2 \
        iproute2 \
        procps \
        lsof \
        htop \
        net-tools \
        psmisc \
        curl \
        wget \
        rsync \
        ca-certificates \
        unzip \
        zip \
        nano \
        vim-tiny \
        less \
        jq \
        lsb-release \
        apt-transport-https \
        software-properties-common \
        build-essential \
        locales"
    
    # Add non-free packages if requested
    if [ "${ADD_NON_FREE_PACKAGES}" = "true" ]; then
        # Use libssl3 for Debian bookworm instead of libssl1.1
        PACKAGE_LIST="${PACKAGE_LIST} libssl3"
    fi
    
    check_packages ${PACKAGE_LIST}
}

# Set up locale
setup_locale() {
    echo "Setting up locale..."
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/default/locale
}

# Create or update a non-root user
create_or_update_user() {
    if id -u ${USERNAME} > /dev/null 2>&1; then
        echo "User ${USERNAME} already exists."
        if [ "${USER_UID}" != "$(id -u ${USERNAME})" ]; then
            echo "Updating UID for user ${USERNAME}..."
            usermod --uid ${USER_UID} ${USERNAME}
        fi
        if [ "${USER_GID}" != "$(id -g ${USERNAME})" ]; then
            echo "Updating GID for user ${USERNAME}..."
            groupmod --gid ${USER_GID} ${USERNAME}
            usermod --gid ${USER_GID} ${USERNAME}
        fi
    else
        echo "Creating user ${USERNAME}..."
        groupadd --gid ${USER_GID} ${USERNAME}
        useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME}
    fi
    
    # Add user to sudo group
    usermod -aG sudo ${USERNAME}
    
    # Allow passwordless sudo
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}
    chmod 0440 /etc/sudoers.d/${USERNAME}
}

# Install zsh and oh-my-zsh
install_zsh() {
    if [ "${INSTALL_ZSH}" = "true" ]; then
        echo "Installing zsh..."
        check_packages zsh
        
        if [ "${INSTALL_OH_MY_ZSH}" = "true" ]; then
            echo "Installing oh-my-zsh for ${USERNAME}..."
            sudo -u ${USERNAME} sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            
            # Set zsh as default shell
            chsh -s /bin/zsh ${USERNAME}
        fi
    fi
}

# Clean up
cleanup() {
    echo "Cleaning up..."
    apt-get autoremove -y
    apt-get clean -y
    rm -rf /var/lib/apt/lists/*
}

# Main setup
echo "Starting common setup..."

# Update packages if requested
if [ "${UPGRADE_PACKAGES}" = "true" ]; then
    echo "Upgrading packages..."
    apt_get_update_if_needed
    apt-get -y upgrade --no-install-recommends
fi

# Install common packages
install_common_packages

# Set up locale
setup_locale

# Create or update user
if [ "${USERNAME}" != "root" ]; then
    create_or_update_user
fi

# Install zsh if requested
install_zsh

# Clean up
cleanup

echo "Common setup completed!"
