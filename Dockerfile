FROM debian:stable-slim@sha256:382967fd7c35a0899ca3146b0b73d0791478fba2f71020c7aa8c27e3a4f26672 AS build

ENV NTP_VERSION=ntp-4.2.8p18
ENV NTP_ARCHIVE=https://downloads.nwtime.org/ntp/4.2.8/${NTP_VERSION}.tar.gz

WORKDIR /tmp

# RUN set -x \
#   && apt update \
#   && apt install -y build-essential wget
#
# RUN set -x \
#   && wget "${NTP_ARCHIVE}" \
#   && tar xvzf "${NTP_VERSION}.tar.gz" \
#   && mv "${NTP_VERSION}" ntp \
#   && cd ntp \
#   && ./configure --without-crypto \
#   && make \
#   && cd util \
#   && make tg2 \
#   && chmod +x tg2
RUN mkdir -p /tmp/ntp/util/ && echo $(uname -m) > /tmp/ntp/util/tg2

FROM debian:stable-slim@sha256:382967fd7c35a0899ca3146b0b73d0791478fba2f71020c7aa8c27e3a4f26672

WORKDIR /app

COPY --from=build /tmp/ntp/util/tg2 /app/tg2


ENTRYPOINT ["/app/tg2"]
