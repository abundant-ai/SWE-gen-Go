#!/bin/bash

set -euo pipefail
cd /go/src/github.com/labstack/echo

patch -p1 < /solution/fix.patch
