Docker Monitoring with cAdvisor + InfluxDB + Grafana
====================================================

This repo contains a couple [`docker-compose`][1] templates for standing up the cAdvisor + InfluxDB + Grafana monitoring stack.

Requirements:

1. `docker` command line client is installed
2. `docker-compose` is installed
3. `envsubst` command is installed (usually this is in `gettext` package)
4. `docker -d` daemon is running somewhere that `docker` CLI can connect to (If on Mac, you might try [`boot2docker`][2] + [`docker-machine`][4])
5. `openssl` is installed (for generating self-signed SSL certs)

## Running:

First, set up your passwords & secrets in the `env.sh` file:


    export CERT_NAME=*.boot2docker.local
    export HOSTNAME=boot2docker.local
    export INFLUXDB_PASS=123abcU&MeEzasInfluxDB
    export GRAFANA_PASS=TarPitaSaurus
    export GRAFANA_SECRET_KEY=BodP3JV4TbbggerfJo16kQ
    
    ## These do not work yet because `grafana.ini` section name is `[auth.google]`
    ## ENV vars cannot have periods in them, and [Grafana's ENV var config syntax][3] wants `GF_<SECTION_NAME>_<KEYNAME>`
    #    export AUTH_GOOGLE_CLIENT_ID=1234567890abcdefghijlkmnopqrstuvwxyz.apps.googleusercontent.com
    #    export AUTH_GOOGLE_CLIENT_SECRET=<YOUR GOOGLE OAUTH CLIENT SECRET>
    
To generate a `GRAFANA_SECRET_KEY` easily, run: `ruby -r securerandom -e 'puts SecureRandom.urlsafe_base64'`

**Note:** An example `env.sh` is provided with this repo: `env.sh.example`

Next, simply run:

`./docker-run.sh`

## Destroying:

To completely stop, and remove all containers, volumes, and data (including InfluxDB data & Grafana Dashboards!), run:

`./docker-destroy.sh`

[1]: https://docs.docker.com/compose/
[2]: http://boot2docker.io
[3]: https://github.com/grafana/grafana/blob/master/docs/sources/installation/configuration.md#using-environment-variables
[4]: https://docs.docker.com/machine/install-machine/
