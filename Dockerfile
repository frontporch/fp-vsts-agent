FROM microsoft/vsts-agent:ubuntu-16.04-docker-17.12.0-ce-standard

# Setting this variable causes NVM to install it automaticly when NVM is installed
ARG NODE_VERSION=9.11.1

# Install NVM and Yarn
RUN echo alias nodejs=node >> /root/.bashrc && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    sudo apt-get update && \
    sudo apt-get install --no-install-recommends yarn && \
    rm -rf /var/lib/apt/lists/*
