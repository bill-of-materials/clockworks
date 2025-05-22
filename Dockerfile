FROM debian:stable-slim@sha256:b3ef39b8a45ee3b689c462dfa711454bcfc9c9965fe81c6cfb7ff4029b5b8cd7 AS build

ENV NTP_VERSION=ntp-4.2.8p18
ENV NTP_ARCHIVE=https://downloads.nwtime.org/ntp/4.2.8/${NTP_VERSION}.tar.gz

WORKDIR /tmp

RUN set -x \
  && apt update \
  && apt install -y build-essential wget

RUN set -x \
  && wget "${NTP_ARCHIVE}" \
  && tar xvzf "${NTP_VERSION}.tar.gz" \
  && mv "${NTP_VERSION}" ntp \
  && cd ntp \
  && ./configure --without-crypto \
  && make \
  && cd util \
  && make tg2 \
  && chmod +x tg2

FROM debian:stable-slim@sha256:b3ef39b8a45ee3b689c462dfa711454bcfc9c9965fe81c6cfb7ff4029b5b8cd7

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
