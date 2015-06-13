Docker Monitoring with cAdvisor + InfluxDB + Grafana
====================================================

This repo contains a couple [`docker-compose`][1] templates for standing up the cAdvisor + InfluxDB + Grafana monitoring stack.

Requirements:

1. `docker` command line client is installed
2. `docker-compose` is installed
3. `envsubst` command is installed (usually this is in `gettext` package)
4. `docker -d` daemon is running somewhere that `docker` CLI can connect to (If on Mac, you might try [`boot2docker`][2])
5. `openssl` is installed (for generating self-signed SSL certs)

## Running:

Simply run:

`./docker-run.sh`

## Destroying:

To completely stop, and remove all containers, volumes, and data (including InfluxDB data & Grafana Dashboards!), run:

`./docker-destroy.sh`

[1]: https://docs.docker.com/compose/
[2]: http://boot2docker.io
