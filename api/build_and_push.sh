#!/bin/bash

set -e

# docker buildx create --use
docker buildx build --platform linux/amd64 --push -t rathrio/lists .
