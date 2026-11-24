FROM debian:stable-slim@sha256:a64d9dbf633e2a2503afac76be521dc25d9b5765150b30d31a3914d4ae969cab AS build

ENV NTP_VERSION=ntp-4.2.8p18
ENV NTP_ARCHIVE=https://downloads.nwtime.org/ntp/4.2.8/${NTP_VERSION}.tar.gz

WORKDIR /tmp

RUN set -x \
  && apt update \
  && apt install -y build-essential wget

COPY fixes /tmp/fixes

RUN set -x \
  && wget "${NTP_ARCHIVE}" \
  && tar xvzf "${NTP_VERSION}.tar.gz" \
  && mv "${NTP_VERSION}" ntp \
  && cd ntp \
  && patch -N -p1 -i "/tmp/fixes/bug_3926_pthread_detach.patch" \
  && ./configure --without-crypto \
  && make \
  && cd util \
  && make tg2 \
  && chmod +x tg2

FROM debian:stable-slim@sha256:a64d9dbf633e2a2503afac76be521dc25d9b5765150b30d31a3914d4ae969cab

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
