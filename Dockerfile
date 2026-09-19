FROM debian:stable-slim@sha256:d06d3717fbfe78c4143ae0ce22694ccebcd8e7c35ac179bbcb7f49afb5e65c68 AS build

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

FROM debian:stable-slim@sha256:d06d3717fbfe78c4143ae0ce22694ccebcd8e7c35ac179bbcb7f49afb5e65c68

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
