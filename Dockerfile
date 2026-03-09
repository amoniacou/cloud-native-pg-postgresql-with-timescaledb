ARG PG_VERSION=17.6
ARG DEB_VERSION=standard-bookworm
ARG TS_VERSION=2.25.2
ARG MAKEJ=2
ARG IMAGE_VARIANT=${PG_VERSION}-${DEB_VERSION}

FROM ghcr.io/cloudnative-pg/postgresql:${IMAGE_VARIANT}
ARG PG_VERSION
ARG TS_VERSION
ARG MAKEJ
USER 0
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=tmpfs,target=/tmp \
  --mount=type=tmpfs,target=/var/tmp \
  --mount=type=tmpfs,target=/build \
  set -ex \
  && PG_MAJOR=$(echo "${PG_VERSION}" | cut -d. -f1) \
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
  && cd /build/timescaledb && rm -fr build \
  && git checkout ${TS_VERSION} \
  && ./bootstrap -DCMAKE_BUILD_TYPE=RelWithDebInfo -DREGRESS_CHECKS=OFF -DTAP_CHECKS=OFF -DGENERATE_DOWNGRADE_SCRIPT=ON -DWARNINGS_AS_ERRORS=OFF -DPROJECT_INSTALL_METHOD="docker-bitnami" \
  && cd build && make install -j${MAKEJ} \
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
