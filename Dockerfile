ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
FROM ${CI_REGISTRY_IMAGE}/${DOCKERFS_TYPE}:${DOCKERFS_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \ 
    curl xdg-utils desktop-file-utils shared-mime-info libswt-gtk-4-java dbus-x11 at-spi2-core && \
    curl -sSL "https://arx.deidentifier.org/?ddownload=2135" -o arxinstaller && \
    mkdir -p ~/.local/share/applications && \
    mkdir -p ~/.local/share/mime/packages && \
    mkdir -p ~/.local/share/icons/hicolor && \
    update-desktop-database ~/.local/share/applications/ && \ 
    update-mime-database ~/.local/share/mime/ && \ 
    gtk-update-icon-cache ~/.local/share/icons/hicolor/ -t && \ 
    chmod 755 arxinstaller && \
    ./arxinstaller --mode unattended && \ 
    apt-get remove -y --purge curl && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV APP_SPECIAL="no"
ENV APP_CMD="/opt/ARX-3.9.1/ARX-launcher.run"
ENV PROCESS_NAME="ARX-launcher"
ENV APP_DATA_DIR_ARRAY=".local"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
