#!/bin/bash

cd /go/src/github.com/spf13/viper

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/viper_test.go" "viper_test.go"

# Install key dependencies individually
go get github.com/BurntSushi/toml 2>&1 || true
go get github.com/kr/pretty 2>&1 || true
go get github.com/mitchellh/mapstructure 2>&1 || true
go get github.com/spf13/cast 2>&1 || true
go get github.com/spf13/jwalterweatherman 2>&1 || true
go get github.com/spf13/pflag 2>&1 || true
go get gopkg.in/yaml.v2 2>&1 || true
go get github.com/stretchr/testify/assert 2>&1 || true
go get github.com/magiconair/properties 2>&1 || true

# Stub out the problematic crypt dependency (old code uses xordataexchange/crypt which has broken transitive deps)
# The test doesn't actually use remote config features (etcd/consul)
cat > crypt_stub.go <<'EOF'
package viper

import (
    "fmt"
    "os"
)

type ConfigManager interface {
    Get(key string) ([]byte, error)
}

type stubConfigManager struct{}

func (s *stubConfigManager) Get(key string) ([]byte, error) {
    return nil, fmt.Errorf("remote config not supported")
}

func NewEtcdConfigManager(endpoints []string, keyring *os.File) (ConfigManager, error) {
    return &stubConfigManager{}, nil
}

func NewConsulConfigManager(endpoints []string, keyring *os.File) (ConfigManager, error) {
    return &stubConfigManager{}, nil
}

func NewStandardEtcdConfigManager(endpoints []string) (ConfigManager, error) {
    return &stubConfigManager{}, nil
}

func NewStandardConsulConfigManager(endpoints []string) (ConfigManager, error) {
    return &stubConfigManager{}, nil
}
EOF

# Comment out crypt import and replace crypt.X with local stubs
sed -i 's|^\(\s*crypt\s\+"github.com/xordataexchange/crypt/config"\)|//\1|' viper.go
sed -i 's|crypt\.ConfigManager|ConfigManager|g' viper.go
sed -i 's|crypt\.New|New|g' viper.go

# Run tests
go test -v -timeout 30s . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
