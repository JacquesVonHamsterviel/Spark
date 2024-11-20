#!/bin/bash

# 使用 go modules
export GO111MODULE=auto

# 获取当前的 Git 提交哈希值
COMMIT=$(git rev-parse HEAD)

echo "Building for darwin arm64"
# 设置 GOOS 为 darwin（macOS）
export GOOS=darwin
export GOARCH=arm64
go build -x -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/darwin_arm64 Spark/client

echo "Building for darwin amd64"
export GOARCH=amd64
go build -x -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/darwin_amd64 Spark/client
