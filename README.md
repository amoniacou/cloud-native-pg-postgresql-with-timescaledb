# CNPG PostgreSQL with TimescaleDB

Custom [CloudNativePG](https://cloudnative-pg.io/) PostgreSQL images with [TimescaleDB](https://www.timescale.com/) extension pre-installed.

Built on top of the official `ghcr.io/cloudnative-pg/postgresql` images with multi-arch support (amd64, arm64).

## Available images

```
ghcr.io/amoniacou/cloud-native-pg-postgresql-with-timescaledb:<pg_version>-ts<ts_version>-standard-trixie
```

**PostgreSQL versions:** 14, 15, 16, 17
**Debian variant:** `standard-trixie`

| PG Major | TimescaleDB | Edition | Install method |
|----------|------------|---------|----------------|
| 14 | 2.19.3 | TSL (compiled from source) | Source |
| 15 | 2.25.2 | Apache 2.0 (OSS package) | apt |
| 16 | 2.25.2 | Apache 2.0 (OSS package) | apt |
| 17 | 2.25.2 | Apache 2.0 (OSS package) | apt |

Example:
```
ghcr.io/amoniacou/cloud-native-pg-postgresql-with-timescaledb:17.9-ts2.25.2-standard-trixie
```

## Usage with CloudNativePG

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: my-cluster
spec:
  instances: 3
  imageName: ghcr.io/amoniacou/cloud-native-pg-postgresql-with-timescaledb:17.9-ts2.25.2-standard-trixie

  postgresql:
    shared_preload_libraries:
      - timescaledb
```

Then enable the extension in your database:

```sql
CREATE EXTENSION timescaledb;
```

## How it works

The [Dockerfile](Dockerfile) takes the official CNPG PostgreSQL image and installs TimescaleDB:
- **PG 15+**: installs `timescaledb-2-oss` package from [Timescale's apt repository](https://packagecloud.io/timescale/timescaledb)
- **PG 14**: compiles from source (last TS version with PG 14 support)

Build arguments:

| Argument | Default | Description |
|---|---|---|
| `PG_VERSION` | `17.9` | PostgreSQL version |
| `DEB_VERSION` | `standard-trixie` | Debian variant |
| `TS_VERSION` | `2.25.2` | TimescaleDB version (used for PG 14 source build) |
| `MAKEJ` | `2` | Parallel compilation threads (PG 14 only) |

## Auto-updates

A [daily workflow](.github/workflows/check-updates.yaml) checks for new PostgreSQL minor versions published by CloudNativePG and automatically builds images for any versions not yet in our registry. Each PG major version is mapped to the correct TimescaleDB version.

Every Monday, all tracked versions are rebuilt to pick up security updates.

You can also trigger the check manually via the "Run workflow" button in GitHub Actions with an optional `force_rebuild` flag.

## Building locally

```bash
docker buildx build \
  --build-arg PG_VERSION=17.9 \
  --build-arg DEB_VERSION=standard-trixie \
  --platform linux/amd64 \
  -t my-pg-with-ts:local \
  .
```

## License

This project is provided as-is. The base PostgreSQL images are maintained by the [CloudNativePG](https://github.com/cloudnative-pg/postgres-containers) project. TimescaleDB is developed by [Timescale](https://github.com/timescale/timescaledb).
