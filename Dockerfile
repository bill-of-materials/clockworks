FROM debian:stable-slim@sha256:99fc6d2a0882fcbcdc452948d2d54eab91faafc7db037df82425edcdcf950e1f AS build

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

FROM debian:stable-slim@sha256:99fc6d2a0882fcbcdc452948d2d54eab91faafc7db037df82425edcdcf950e1f

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
