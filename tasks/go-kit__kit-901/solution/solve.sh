#!/bin/bash

set -euo pipefail
cd /go/src/github.com/go-kit/kit

patch -p1 < /solution/fix.patch
