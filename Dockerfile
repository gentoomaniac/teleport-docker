ARG OS=ubuntu
ARG CODENAME=jammy
ARG TELEPORT_VERSION=15.3.1
ARG CLOUDCLI_ARCH=arm
ARG CLOUDCLI_VERSION=476.0.0

FROM ${OS}:${CODENAME}

ARG OS
ARG CODENAME
ARG TELEPORT_VERSION
ARG CLOUDCLI_ARCH
ARG CLOUDCLI_VERSION
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Stockholm

RUN apt update && apt install --yes curl bash-completion gawk vim-nox neovim less python3 jq ca-certificates

RUN curl https://goteleport.com/static/install.sh | bash -s ${TELEPORT_VERSION}

COPY caadmin.netskope.com.crt /usr/local/share/ca-certificates/caadmin.netskope.com.crt
RUN update-ca-certificates

RUN useradd --create-home --shell /usr/bin/bash user
USER user
WORKDIR /home/user

RUN curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${CLOUDCLI_VERSION}-linux-${CLOUDCLI_ARCH?}.tar.gz" && \
  tar xf "google-cloud-cli-${CLOUDCLI_VERSION}-linux-${CLOUDCLI_ARCH?}.tar.gz" && \
  ./google-cloud-sdk/install.sh && \
  /home/user/google-cloud-sdk/bin/gcloud components install kubectl

COPY bashrc /home/user/.bashrc
RUN mkdir /home/user/.config/nvim

VOLUME [ "/home/user/.tsh", "/home/user/.config/nvim" ]
