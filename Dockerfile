ARG VOID_VARIANT=glibc
ARG VOID_PLATFORM=linux/amd64
FROM --platform="${VOID_PLATFORM}" ghcr.io/void-linux/void-${VOID_VARIANT}:latest

# Update package index and install required packages
ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "FINE"
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"


ARG UID=1000
ENV UID=${UID}

RUN xbps-install -Sy shadow

RUN groupadd -g ${UID} nekobox && \
    useradd -m -u ${UID} -g ${UID} nekobox

RUN xbps-install -Sy git 
RUN xbps-install -Sy sudo 
RUN xbps-install -Sy bash 
RUN xbps-install -Sy coreutils 
RUN xbps-install -Sy util-linux
RUN xbps-install -Sy base-devel
RUN echo 'ALL ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN xbps-install -Sy sed

USER nekobox
WORKDIR /home/nekobox
COPY ./script.sh /home/nekobox/script.sh
ENTRYPOINT ["bash", "-x"]
CMD ["./script.sh", "$TARGETARCH"]
