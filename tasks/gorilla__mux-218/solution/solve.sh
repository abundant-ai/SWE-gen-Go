#!/bin/bash

set -euo pipefail
export GOPATH="/go"
cd "${GOPATH}/src/github.com/gorilla/mux"

patch -p1 < /solution/fix.patch
