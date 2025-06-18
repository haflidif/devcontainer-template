# Generic Terraform DevContainer Dockerfile
FROM mcr.microsoft.com/devcontainers/base:bookworm

# Copy installation scripts
COPY scripts/*.sh /tmp/scripts/

# Arguments for customization
ARG INSTALL_ZSH="false"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install common packages and setup user
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && bash /tmp/scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "false" \
    && apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        jq \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install pip and Python packages for Terraform development
RUN apt-get update \
    && apt-get install -y python3-pip \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip \
    && python3 -m pip install --no-cache-dir --break-system-packages \
        pytest \
        black \
        flake8 \
        PyYAML \
        checkov \
        terrascan \
        pre-commit \
        bandit

# Set Python environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install cloud CLI tools (customize based on your needs)
ARG INSTALL_AZURE_CLI="true"
ARG INSTALL_AWS_CLI="false"
ARG INSTALL_GCLOUD_CLI="false"

# Install Azure CLI
RUN if [ "${INSTALL_AZURE_CLI}" = "true" ]; then \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash; \
    fi

# Install AWS CLI
RUN if [ "${INSTALL_AWS_CLI}" = "true" ]; then \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/; \
    fi

# Install Google Cloud SDK
RUN if [ "${INSTALL_GCLOUD_CLI}" = "true" ]; then \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update && apt-get install -y google-cloud-sdk \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*; \
    fi

# Install Docker CLI
ARG INSTALL_DOCKER="true"
RUN if [ "${INSTALL_DOCKER}" = "true" ]; then \
    bash /tmp/scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    fi

# Environment variables for tool versions (tools will be installed via postStart)
ENV TERRAFORM_VERSION="latest" \
    TFLINT_VERSION="latest" \
    TERRAFORM_DOCS_VERSION="latest" \
    TERRAGRUNT_VERSION="latest" \
    CHECKOV_VERSION="latest" \
    BICEP_VERSION="latest" \
    INSTALL_BICEP="true"

# Clean up
RUN rm -rf /tmp/scripts \
    && rm -rf /root/.cache/pip/*

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
