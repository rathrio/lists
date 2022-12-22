#!/bin/sh

set -e

docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 --push -t rathrio/lists .