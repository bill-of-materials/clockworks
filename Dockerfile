FROM debian:stable-slim@sha256:f8bbfa052db81e5b8ac12e4a1d8310a85d1509d4d0d5579148059c0e8b717d4e AS build

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

FROM debian:stable-slim@sha256:f8bbfa052db81e5b8ac12e4a1d8310a85d1509d4d0d5579148059c0e8b717d4e

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
