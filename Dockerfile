ARG OS=ubuntu
ARG CODENAME=jammy
ARG CLOUDCLI_ARCH=x86_64

FROM ${OS}:${CODENAME}

ARG OS
ARG CODENAME
ARG CLOUDCLI_ARCH
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Stockholm

RUN apt update && apt install --yes curl bash-completion gawk vim-nox less python3

RUN curl https://apt.releases.teleport.dev/gpg -o /usr/share/keyrings/teleport-archive-keyring.asc && \
    echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/${OS?} ${CODENAME?} stable/v11" | tee /etc/apt/sources.list.d/teleport.list && \
    apt update && \
    apt install --yes teleport

RUN useradd --create-home --shell /usr/bin/bash user
USER user
WORKDIR /home/user

RUN curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-413.0.0-linux-${CLOUDCLI_ARCH?}.tar.gz" && \
    tar xf "google-cloud-cli-413.0.0-linux-${CLOUDCLI_ARCH?}.tar.gz" && \
    ./google-cloud-sdk/install.sh && \
    /home/user/google-cloud-sdk/bin/gcloud components install kubectl

COPY bashrc /home/user/.bashrc

VOLUME [ "/home/user/.tsh" ]
