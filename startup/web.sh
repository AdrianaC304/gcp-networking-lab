#!/usr/bin/env bash
# Startup script for web-vm: installs nginx and serves a page that says which VM answered.
set -e
# Put your name here before you create web-vm (Part 2).
STUDENT="CHANGE-ME"
apt-get update -y
apt-get install -y nginx
HOST="$(hostname)"
IP="$(hostname -I | awk '{print $1}')"
cat > /var/www/html/index.html <<HTML
<h1>Hello from ${HOST} (${STUDENT})</h1>
<p>Internal IP: ${IP}</p>
HTML
systemctl enable --now nginx
