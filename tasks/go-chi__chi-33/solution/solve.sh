#!/bin/bash

set -euo pipefail
cd /app/src/github.com/go-chi/chi

patch -p1 < /solution/fix.patch
