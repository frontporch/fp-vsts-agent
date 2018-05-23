FROM microsoft/vsts-agent:ubuntu-16.04-docker-17.12.0-ce-standard

# Mono is required for GitVersion
ARG MONO_VERSION=5.12.0.226

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

# Install Mono
# https://www.mono-project.com/download/stable/#download-lin
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    apt install apt-transport-https && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update -qq && \
    apt-get install -qq mono-runtime binutils curl mono-devel ca-certificates-mono fsharp mono-vbnc nuget referenceassemblies-pcl && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install GitVersion
RUN curl -Ls https://github.com/GitTools/GitVersion/releases/download/v4.0.0-beta.13/GitVersion.CommandLine.4.0.0-beta0013.nupkg -o tmp.zip && \ 
    unzip -d /usr/lib/GitVersion tmp.zip && \
    rm tmp.zip && \
    echo '#!/bin/bash\nmono /usr/lib/GitVersion/tools/GitVersion.exe "$@"' > /usr/lib/GitVersion/tools/GitVersion && \
    chmod +x /usr/lib/GitVersion/tools/GitVersion

# Add GitVersion to the PATH
ENV PATH="${PATH}:/usr/lib/GitVersion/tools"
