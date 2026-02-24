#!/bin/bash

set -euo pipefail
cd /app/src

# First, move the renamed directories back to their original names
mv internal/logger/target/types internal/logger/target/loggertypes

# Fix the import paths in files that aren't covered by fix.patch
sed -i 's|"github.com/minio/minio/internal/logger/target/types"|types "github.com/minio/minio/internal/logger/target/loggertypes"|g' internal/logger/target/http/http.go
sed -i 's|"github.com/minio/minio/internal/logger/target/types"|types "github.com/minio/minio/internal/logger/target/loggertypes"|g' internal/logger/target/kafka/kafka.go
sed -i 's|"github.com/minio/minio/internal/logger/target/types"|types "github.com/minio/minio/internal/logger/target/loggertypes"|g' internal/logger/target/testlogger/testlogger.go

# Now apply the fix.patch
patch -p1 < /solution/fix.patch

# Rebuild with the fixes
make build
