ARG TS_VERSION=2.20.3
ARG CNPG_VERSION=16.9-bookworm
ARG MAKEJ=2

FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_VERSION
ARG TS_VERSION
ENV TS_VERSION=${TS_VERSION}
ARG MAKEJ
ENV MAKEJ=${MAKEJ}
USER 0
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=cache,sharing=locked,target=${HOME}/.cache \
  --mount=type=tmpfs,target=/tmp \
  --mount=type=tmpfs,target=/var/tmp \
  --mount=type=tmpfs,target=/build \
  set -ex \
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
  && cd build && make install -j${MAKEJ}\
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
  && apt-get clean -y

USER 26
