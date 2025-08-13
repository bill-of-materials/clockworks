FROM debian:stable-slim@sha256:8810492a2dd16b7f59239c1e0cc1e56c1a1a5957d11f639776bd6798e795608b AS build

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

FROM debian:stable-slim@sha256:8810492a2dd16b7f59239c1e0cc1e56c1a1a5957d11f639776bd6798e795608b

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
