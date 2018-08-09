FROM microsoft/vsts-agent:ubuntu-16.04-standard

# The version of Docker to install  
ENV DOCKER_CHANNEL edge 
ENV DOCKER_VERSION 18.05.0-ce 
RUN set -ex \ 
  && curl -fL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/`uname -m`/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \ 
  && tar --extract --file docker.tgz --strip-components 1 --directory /usr/local/bin \ 
  && rm docker.tgz \ 
  && docker -v 

# The version of Docker Compose to install 
ENV DOCKER_COMPOSE_VERSION 1.21.2 
RUN set -x \ 
  && curl -fSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose \ 
  && chmod +x /usr/local/bin/docker-compose \ 
  && docker-compose -v 

# Setting this variable causes NVM to install it automatically when NVM is installed
ARG NODE_VERSION=9.11.1

# The version of NVM to install
ENV NVM_VERSION=0.33.11

# Install NVM
RUN echo alias nodejs=node >> /root/.bashrc && \
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
  echo '#!/bin/bash\n/root/.nvm/nvm.sh "$@"' > /root/.nvm/nvm && \
  chmod +x /root/.nvm/nvm && \
  chmod +x /root/.nvm/nvm.sh

# Add NVM to the PATH
ENV PATH="${PATH}:/root/.nvm"

# Advertise nvm capability to VSTS
ENV nvm=/root/.nvm/nvm.sh

# The version of GitVersion to install
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

# The version of AWS CLI to install
ENV AWSCLI_VERSION=1.15.73

# Install AWS CLI
RUN pip install --upgrade setuptools wheel && \
  pip install --upgrade awscli==${AWSCLI_VERSION}

# Advertise AWS CLI capability to VSTS
ENV aws=/usr/local/bin/aws
