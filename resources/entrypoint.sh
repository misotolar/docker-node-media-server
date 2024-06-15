#!/bin/sh

set -ex

envsubst < "/usr/local/node-media-server/app.docker.js" > "/usr/local/node-media-server/app.js"

exec "$@"
