FROM microsoft/vsts-agent:ubuntu-16.04-docker-17.12.0-ce-standard

# Setting this variable causes NVM to install it automaticly when NVM is installed
ARG NODE_VERSION=9.11.1

# The version of NVM to install
ENV NVM_VERSION=0.33.11

# Install NVM
RUN echo alias nodejs=node >> /root/.bashrc && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
    echo '#!/bin/bash\n/root/.nvm/nvm.sh "$@"' > /root/.nvm/nvm && \
    chmod +x /root/.nvm/nvm && \
    chmod +x /root/.nvm/nvm.sh

# Advertise nvm capability to VSTS
ENV nvm=/root/.nvm/nvm.sh

# The version of yarn to install
ENV YARN_VERSION=1.7.0

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -qq --no-install-recommends yarn=${YARN_VERSION}* && \
    rm -rf /var/lib/apt/lists/*

# Advertise yarn capability to VSTS
ENV yarn=/usr/bin/yarn

# The version of Mono to install
ENV MONO_VERSION=5.12.0.226

# Install Mono (required for GitVersion)
# https://www.mono-project.com/download/stable/#download-lin
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
    apt install apt-transport-https && \
    echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list && \
    apt-get update -qq && \
    apt-get install -qq mono-runtime=${MONO_VERSION}* binutils curl mono-devel ca-certificates-mono fsharp mono-vbnc nuget referenceassemblies-pcl && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENV GITVERSION_VERSION=4.0.0-beta.13

# Install GitVersion
# https://github.com/sashagavrilov/docker-gitversion/blob/master/Dockerfile
RUN GITVERSION_PREFIX=${GITVERSION_VERSION%.*} && \
    GITVERSION_SUFFIX=$(printf "%04d" ${GITVERSION_VERSION##*.}) && \
    curl -Ls https://github.com/GitTools/GitVersion/releases/download/v${GITVERSION_VERSION}/GitVersion.CommandLine.${GITVERSION_PREFIX}${GITVERSION_SUFFIX}.nupkg -o tmp.zip && \
    unzip -d /usr/lib/GitVersion tmp.zip && \
    rm tmp.zip && \
    echo '#!/bin/bash\nmono /usr/lib/GitVersion/tools/GitVersion.exe "$@"' > /usr/lib/GitVersion/tools/GitVersion && \
    chmod +x /usr/lib/GitVersion/tools/GitVersion

# Add GitVersion to the PATH
ENV PATH="${PATH}:/usr/lib/GitVersion/tools"

# Advertise GitVersion capability to VSTS
ENV GitVersion=/usr/lib/GitVersion/tools/GitVersion
