# Generic Terraform DevContainer Dockerfile
FROM mcr.microsoft.com/devcontainers/base:bullseye

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
    && bash /tmp/scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get install -y \
        curl \
        wget \
        git \
        unzip \
        jq \
        python3 \
        python3-pip \
        python3-venv \
        build-essential \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Python packages for Terraform development
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir \
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
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update && apt-get install -y google-cloud-sdk \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*; \
    fi

# Install Docker CLI
ARG INSTALL_DOCKER="true"
RUN if [ "${INSTALL_DOCKER}" = "true" ]; then \
    bash /tmp/scripts/docker-debian.sh "true" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    fi

# Install Terraform tools during build
COPY scripts/terraform-tools.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/terraform-tools.sh

# Install Bicep tools during build
COPY scripts/bicep-tools.sh /tmp/scripts/
RUN chmod +x /tmp/scripts/bicep-tools.sh

# Environment variables for tool versions (will be set at runtime)
ENV TERRAFORM_VERSION="" \
    TFLINT_VERSION="" \
    TERRAFORM_DOCS_VERSION="" \
    TERRAGRUNT_VERSION="" \
    CHECKOV_VERSION="" \
    BICEP_VERSION="" \
    INSTALL_BICEP="true"

# Clean up
RUN rm -rf /tmp/scripts \
    && rm -rf /root/.cache/pip/*

ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
