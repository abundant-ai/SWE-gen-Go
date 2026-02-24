#!/bin/bash

set -euo pipefail
cd /app/gorm

patch -p1 < /solution/fix.patch
