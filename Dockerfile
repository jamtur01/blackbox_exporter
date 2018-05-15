FROM        quay.io/prometheus/busybox:latest
MAINTAINER  The Prometheus Authors <prometheus-developers@googlegroups.com>

COPY probe_exporter  /bin/probe_exporter
COPY probe.yml       /etc/probe_exporter/config.yml

EXPOSE      9115
ENTRYPOINT  [ "/bin/probe_exporter" ]
CMD         [ "--config.file=/etc/probe_exporter/config.yml" ]
