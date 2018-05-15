# Probe exporter [![Build Status](https://travis-ci.org/prometheus/probe_exporter.svg)][travis]

[![CircleCI](https://circleci.com/gh/prometheus/probe_exporter/tree/master.svg?style=shield)][circleci]
[![Docker Repository on Quay](https://quay.io/repository/prometheus/probe-exporter/status)][quay]
[![Docker Pulls](https://img.shields.io/docker/pulls/prom/probe-exporter.svg?maxAge=604800)][hub]

The probe exporter (formerly the blackbox exporter) allows probing of endpoints over
HTTP, HTTPS, DNS, TCP and ICMP.

## Building and running

### Local Build

    make
    ./probe_exporter <flags>

Visiting [http://localhost:9115/probe?target=google.com&module=http_2xx](http://localhost:9115/probe?target=google.com&module=http_2xx)
will return metrics for a HTTP probe against google.com. The `probe_success`
metric indicates if the probe succeeded. Adding a `debug=true` parameter
will return debug information for that probe.

### Building with Docker

    docker build -t probe_exporter .
    docker run -d -p 9115:9115 --name probe_exporter -v `pwd`:/config probe_exporter --config.file=/config/probe.yml

## [Configuration](CONFIGURATION.md)

Probe exporter is configured via a [configuration file](CONFIGURATION.md) and command-line flags (such as what configuration file to load, what port to listen on, and the logging format and level).

Probe exporter can reload its configuration file at runtime. If the new configuration is not well-formed, the changes will not be applied.
A configuration reload is triggered by sending a `SIGHUP` to the Probe exporter process or by sending a HTTP POST request to the `/-/reload` endpoint.

To view all available command-line flags, run `./probe_exporter -h`.

To specify which [configuration file](CONFIGURATION.md) to load, use the `--config.file` flag.

Additionally, an [example configuration](example.yml) is also available.

HTTP, HTTPS (via the `http` prober), DNS, TCP socket and ICMP (see permissions section) are currently supported.
Additional modules can be defined to meet your needs.

The timeout of each probe is automatically determined from the `scrape_timeout` in the [Prometheus config](https://prometheus.io/docs/operating/configuration/#configuration-file), slightly reduced to allow for network delays.
This can be further limited by the `timeout` in the Probe exporter config file. If neither is specified, it defaults to 10 seconds.

## Prometheus Configuration

The probe exporter needs to be passed the target as a parameter, this can be
done with relabelling.

Example config:
```yml
scrape_configs:
  - job_name: 'probe'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://prometheus.io    # Target to probe with http.
        - https://prometheus.io   # Target to probe with https.
        - http://example.com:8080 # Target to probe with http on port 8080.
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115  # The probe exporter's real hostname:port.
```

## Permissions

The ICMP probe requires elevated privileges to function:

* *Windows*: Administrator privileges are required.
* *Linux*: root user _or_ `CAP_NET_RAW` capability is required.
  * Can be set by executing `setcap cap_net_raw+ep probe_exporter`
* *BSD / OS X*: root user is required.

[circleci]: https://circleci.com/gh/prometheus/probe_exporter
[hub]: https://hub.docker.com/r/prom/probe-exporter/
[travis]: https://travis-ci.org/prometheus/probe_exporter
[quay]: https://quay.io/repository/prometheus/probe-exporter
