ARG ARCH=amd64
FROM balenalib/${ARCH}-debian

LABEL maintainer="Julio Gutierrez <bubuntux@gmail.com>"

HEALTHCHECK --interval=60s --timeout=5s --start-period=120s \
             CMD STATUS=$(nordvpn status); echo $STATUS; if test "${STATUS#*Disconnected}" != "$STATUS"; then nordvpn connect ${CONNECT} ; exit 1; fi

ARG NORDVPN_BIN_ARCH=amd64
ARG NORDVPN_BIN_VERSION=3.6.0-1

#CROSSRUN [ "cross-build-start" ]
RUN apt-get update && apt-get upgrade && \
    curl "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/nordvpn_${NORDVPN_BIN_VERSION}_${NORDVPN_BIN_ARCH}.deb" -o /tmp/nordvpn.deb && \
    apt-get install /tmp/nordvpn.deb || echo "error on post-installation script expected" && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/*
#CROSSRUN [ "cross-build-end" ]

COPY start_vpn.sh /usr/bin
CMD /usr/bin/start_vpn.sh

