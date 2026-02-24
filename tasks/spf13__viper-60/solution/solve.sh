#!/bin/bash

set -euo pipefail
cd /go/src/github.com/spf13/viper

patch -p1 < /solution/fix.patch
