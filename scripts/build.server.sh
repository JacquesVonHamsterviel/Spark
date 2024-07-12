export GO111MODULE=auto
export COMMIT=$(git rev-parse HEAD)
export OUTPUT_DIR=../Releases

# 定义目标平台和架构
targets=(
    "darwin arm64"
    "darwin amd64"
    "linux arm"
    "linux 386"
    "linux arm64"
    "linux amd64"
    "windows arm"
    "windows 386"
    "windows arm64"
    "windows amd64"
)

# 循环构建
for target in "${targets[@]}"; do
    export CGO_ENABLED=0
    GOOS=${target% *}
    GOARCH=${target##* }
    OUTPUT_FILE="$OUTPUT_DIR/server_${GOOS}_${GOARCH}"
    if [[ "$GOOS" == *"windows"* ]]; then
        OUTPUT_FILE="$OUTPUT_FILE.exe"
    fi

    echo "Building for $GOOS $GOARCH"
    go build -ldflags "-s -w -X 'Spark/server/config.COMMIT=$COMMIT'" -tags=jsoniter -o "$OUTPUT_FILE" Spark/server
done
