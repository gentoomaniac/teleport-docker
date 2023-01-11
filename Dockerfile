ARG OS=ubuntu
ARG CODENAME=jammy
FROM ${OS}:${CODENAME}

ARG OS
ARG CODENAME

RUN apt update && apt install --yes curl

RUN curl https://apt.releases.teleport.dev/gpg -o /usr/share/keyrings/teleport-archive-keyring.asc && \
    echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/${OS?} ${CODENAME?} stable/v11" | tee /etc/apt/sources.list.d/teleport.list && \
    apt update && \
    apt install --yes teleport

RUN useradd --create-home --shell /usr/bin/bash user
USER user
WORKDIR /home/user

RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-413.0.0-linux-x86_64.tar.gz && \
    tar xf google-cloud-cli-413.0.0-linux-x86_64.tar.gz && \
    ./google-cloud-sdk/install.sh && \
    /home/user/google-cloud-sdk/bin/gcloud components install kubectl

COPY bashrc /home/user/.bashrc

VOLUME [ "/home/user/.tsh" ]
