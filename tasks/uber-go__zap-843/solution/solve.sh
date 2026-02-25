#!/bin/bash

set -euo pipefail
cd /app/zap

patch -p1 < /solution/fix.patch
