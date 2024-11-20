export GO111MODULE=auto
export COMMIT=$(git rev-parse HEAD)
export CLIENT_PATH=Spark/client-windows
export OUTPUT_DIR=../Releases/built

# 定义目标平台和架构
targets=(
    "windows amd64"
    "windows arm"
    "windows arm64"
    "windows 386"
)

# 循环构建
for target in "${targets[@]}"; do
    export CGO_ENABLED=0

    export GOOS=${target%% *}
    export GOARCH=${target##* }
    if [[ "$GOOS" == *"windows"* ]]; then
        OUTPUT_FILE="$OUTPUT_FILE.exe"
    fi
    go build -ldflags "-s -w -X 'Spark/client-windows/config.COMMIT=$COMMIT'" -o "$OUTPUT_DIR/${GOOS}_${GOARCH}" $CLIENT_PATH
done


mv ../Releases/built/windows_386 ../Releases/built/windows_i386
