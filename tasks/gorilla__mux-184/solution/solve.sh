#!/bin/bash

set -euo pipefail
cd /go/src/github.com/gorilla/mux

patch -p1 < /solution/fix.patch
