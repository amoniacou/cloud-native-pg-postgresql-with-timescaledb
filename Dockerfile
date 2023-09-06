ARG TS_VERSION=2.11.2
ARG CNPG_VERSION=14.9-debian

FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_VERSION
ARG TS_VERSION
ENV TS_VERSION=${TS_VERSION}
USER 0
ARG TS_VERSION
RUN set -ex \
  && mkdir -p /var/lib/apt/lists/partial \
  && apt-get update \
  && apt-get -y install \
  \
  build-essential \
  libssl-dev \
  libkrb5-dev \
  git \
  \
  dpkg-dev \
  gcc \
  libc-dev \
  make \
  cmake \
  wget \
  postgresql-server-dev-${PG_MAJOR} \
  && mkdir -p /build/ \
  && git clone https://github.com/timescale/timescaledb /build/timescaledb \
  \
  # Build current version \
  && cd /build/timescaledb && rm -fr build \
  && git checkout ${TS_VERSION} \
  && ./bootstrap -DCMAKE_BUILD_TYPE=RelWithDebInfo -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker-bitnami" \
  && cd build && make install \
  && cd ~ \
  \
  && apt-get autoremove --purge -y \
  \
  build-essential \
  libssl-dev \
  libkrb5-dev \
  git \
  \
  dpkg-dev \
  gcc \
  libc-dev \
  make \
  cmake \
  wget \
  postgresql-server-dev-${PG_MAJOR} \
  && apt-get clean -y \
  && rm -rf \
  "${HOME}/.cache" \
  /var/lib/apt/lists/* \
  /tmp/*               \
  /var/tmp/*

USER 26
