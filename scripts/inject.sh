#!/bin/bash

############################################################################
############################ Install KK-Xcode #########################
############################################################################

SOURCE="$0"
while [ -h "$SOURCE"  ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"

workspace=$DIR

echo "Installing Toolchains..."

# Get the path of the active developer directory
XCODE_PATH=$(xcode-select -p)
XCTOOL_CHAIN_ORI=$XCODE_PATH/Toolchains/XcodeDefault.xctoolchain
XCTOOL_CHAIN_NEW=$workspace/../Toolchains
XCTOOL_IDENTIFER=KK-Xcode16.1-Toolchain

rm -rf $XCTOOL_CHAIN_NEW
mkdir -p $XCTOOL_CHAIN_NEW/{bin,lib}
cp $XCTOOL_CHAIN_ORI/usr/bin/clang $XCTOOL_CHAIN_NEW/bin/clang

/usr/bin/lipo $XCTOOL_CHAIN_NEW/bin/clang -thin arm64 -o $XCTOOL_CHAIN_NEW/bin/clang_arm64
/usr/bin/lipo $XCTOOL_CHAIN_NEW/bin/clang -thin x86_64 -o $XCTOOL_CHAIN_NEW/bin/clang_x86_64
sudo /opt/homebrew/bin/inject $XCTOOL_CHAIN_NEW/bin/clang_arm64 -d @executable_path/../lib/libLLVMPassSkeletonLoader.dylib
sudo /opt/homebrew/bin/inject $XCTOOL_CHAIN_NEW/bin/clang_x86_64 -d @executable_path/../lib/libLLVMPassSkeletonLoader.dylib
rm $XCTOOL_CHAIN_NEW/bin/clang
/usr/bin/lipo -create -output $XCTOOL_CHAIN_NEW/bin/clang $XCTOOL_CHAIN_NEW/bin/clang_arm64 $XCTOOL_CHAIN_NEW/bin/clang_x86_64
rm $XCTOOL_CHAIN_NEW/bin/clang_x86_64 $XCTOOL_CHAIN_NEW/bin/clang_arm64
codesign --force --sign - $XCTOOL_CHAIN_NEW/bin/clang

cat > $XCTOOL_CHAIN_NEW/ToolchainInfo.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Identifier</key>
    <string>$XCTOOL_IDENTIFER</string>
</dict>
</plist>
EOF