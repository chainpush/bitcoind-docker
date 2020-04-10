
FROM alpine as builder

ARG BITCOIN_VERSION=0.19.1

ENV BITCOIN_FILENAME bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_DOWNLOAD_URL https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${BITCOIN_FILENAME}
ENV BITCOIN_FILENAME_SHA256SUMS https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
ENV LAANWJ_RELEASE_ASC https://bitcoin.org/laanwj-releases.asc

RUN apk update && \
    \
    apk --no-cache add wget tar ca-certificates gnupg

RUN wget ${BITCOIN_DOWNLOAD_URL}

RUN wget ${BITCOIN_FILENAME_SHA256SUMS}

RUN wget ${LAANWJ_RELEASE_ASC}

RUN cat /laanwj-releases.asc | gpg --with-fingerprint --with-colons - | sed -ne 's|^fpr:::::::::\([0-9A-F]\+\):$|\1|p' | grep '01EA5486DE18A882D4C2684590C8019E36C2E964'

RUN gpg --import /laanwj-releases.asc

RUN gpg --verify /SHA256SUMS.asc

RUN sha256sum -c SHA256SUMS.asc 2>&1 | grep "${BITCOIN_FILENAME}: OK"

FROM frolvlad/alpine-glibc

MAINTAINER "qyvlik <qyvlik@qq.com>"

COPY --from=builder /${BITCOIN_FILENAME} /

RUN apk update && \
    \
    apk --no-cache add tar bash && \

RUN echo "${BITCOIN_FILENAME}"

RUN tar xzvf /${BITCOIN_FILENAME} && \
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
