#!/bin/bash

set -euo pipefail
cd /go/src/github.com/sirupsen/logrus

patch -p1 < /solution/fix.patch
