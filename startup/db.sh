#!/usr/bin/env bash
# Startup script for db-vm and tools-vm.
# It does NOT need internet access: it uses the python3 that ships with Debian.
# On db-vm it pretends to be a database listening on tcp:5432 (a tiny HTTP server),
# which is enough to test firewall rules with curl.
set -e
mkdir -p /srv/fake-db
echo "fake-db OK from $(hostname) ($(hostname -I | awk '{print $1}'))" > /srv/fake-db/index.html
systemd-run --unit=fake-db --property=Restart=always \
  python3 -m http.server 5432 --directory /srv/fake-db
