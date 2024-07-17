FROM debian:stable-slim AS build

ENV NTP_VERSION=ntp-4.2.8p18
ENV NTP_ARCHIVE=http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/${NTP_VERSION}.tar.gz

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
  && make tg2

FROM debian:stable-slim

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2

CMD ["/app/tg2"]
