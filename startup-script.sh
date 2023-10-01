#!/bin/sh

set -m

echo "$LINK_UP_USERNAME"
echo "$LINK_UP_PASSWORD"

node /srv/index.js &

node /opt/app/lib/server/server.js

fg %1