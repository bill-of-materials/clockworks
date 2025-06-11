FROM debian:stable-slim@sha256:50db38a20a279ccf50761943c36f9e82378f92ef512293e1239b26bb77a8b496 AS build

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

FROM debian:stable-slim@sha256:50db38a20a279ccf50761943c36f9e82378f92ef512293e1239b26bb77a8b496

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
