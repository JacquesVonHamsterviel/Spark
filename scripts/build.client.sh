export GO111MODULE=auto
export COMMIT=$(git rev-parse HEAD)
export CLIENT_PATH=Spark/client
export OUTPUT_DIR=../Releases/built

# 定义目标平台和架构
targets=(
    "darwin amd64"
    "darwin arm64"
    "linux amd64"
    "linux arm"
    "linux arm64"
    "linux 386"
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
    go build -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o "$OUTPUT_DIR/${GOOS}_${GOARCH}" $CLIENT_PATH
done

mv ../Releases/built/linux_386 ../Releases/built/linux_i386
mv ../Releases/built/windows_amd64 ../Releases/built/windows_amd64.exe
mv ../Releases/built/windows_arm ../Releases/built/windows_arm.exe
mv ../Releases/built/windows_arm64 ../Releases/built/windows_arm64.exe
mv ../Releases/built/windows_386 ../Releases/built/windows_i386.exe


# export GOOS=android
# export CGO_ENABLED=1

# export GOARCH=arm
# export CC=armv7a-linux-androideabi21-clang
# export CXX=armv7a-linux-androideabi21-clang++
# go build -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/android_arm Spark/client

# export GOARCH=386
# export CC=i686-linux-android21-clang
# export CXX=i686-linux-android21-clang++
# go build -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/android_i386 Spark/client

# export GOARCH=arm64
# export CC=aarch64-linux-android21-clang
# export CXX=aarch64-linux-android21-clang++
# go build -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/android_arm64 Spark/client

# export GOARCH=amd64
# export CC=x86_64-linux-android21-clang
# export CXX=x86_64-linux-android21-clang++
# go build -ldflags "-s -w -X 'Spark/client/config.COMMIT=$COMMIT'" -o ./built/android_amd64 Spark/client
