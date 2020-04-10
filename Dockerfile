
FROM alpine as builder

ARG BITCOIN_VERSION=0.19.1

ENV BITCOIN_FILENAME bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_DOWNLOAD_URL https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_FILENAME}
ENV BITCOIN_FILENAME_SHA256SUMS https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
ENV LAANWJ_RELEASE_ASC https://bitcoin.org/laanwj-releases.asc

RUN apk update && \
    \
    apk --no-cache add wget tar ca-certificates gnupg bash && \
    \
    wget ${BITCOIN_DOWNLOAD_URL} && \
    wget ${BITCOIN_FILENAME_SHA256SUMS} && \
    wget ${LAANWJ_RELEASE_ASC} && \
    \
    cat /laanwj-releases.asc | gpg --with-fingerprint --with-colons - | sed -ne 's|^fpr:::::::::\([0-9A-F]\+\):$|\1|p' | grep '01EA5486DE18A882D4C2684590C8019E36C2E964' && \
    \
    gpg --import /laanwj-releases.asc && \
    \
    gpg --verify /SHA256SUMS.asc && \
    \
    sha256sum --check --ignore-missing SHA256SUMS.asc 2>&1 | grep OK

FROM frolvlad/alpine-glibc

MAINTAINER "qyvlik <qyvlik@qq.com>"

COPY --from=builder /${BITCOIN_FILENAME} /

RUN apk update && \
    \
    apk --no-cache add bash && \
    \
    tar xzvf /${BITCOIN_FILENAME} && \
    \
    mv /bitcoin-${BITCOIN_VERSION}/bin/* /usr/local/bin/ && \
    \
    rm -rf /bitcoin-${BITCOIN_VERSION}/

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh

RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

VOLUME /home/bitcoin/.bitcoin

RUN adduser -D -u 1000 bitcoin bitcoin && \
    \
    chown bitcoin:bitcoin -R /home/bitcoin

USER bitcoin



ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
