#!/bin/sh
set -ex

curl --insecure --head --fail "http://localhost:8080" || exit 1
