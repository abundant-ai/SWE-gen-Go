#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Apply the fix
patch -p1 < /solution/fix.patch
