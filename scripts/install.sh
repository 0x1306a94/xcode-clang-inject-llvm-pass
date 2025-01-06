#!/bin/bash

############################################################################
############################ Install KK-Xcode #########################
############################################################################

######################## Environment Configuration #########################

if [ $UID -ne 0 ]; then
  echo "please run this script as root"
  exit 1
fi

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
XCTOOL_CHAIN_NEW=$XCODE_PATH/Toolchains/KK-Xcode.xctoolchain
if [ -d "$XCTOOL_CHAIN_NEW" ]; then
  rm -rf $XCTOOL_CHAIN_NEW
fi
####################### Install KK-Xcode ########################

TOOLCHAINS_DIR=$workspace/../Toolchains
if [ ! -d $TOOLCHAINS_DIR ]; then
  echo "$TOOLCHAINS_DIR not found"
  echo ""
  echo "********************************************"
  echo "******** Installation Failed 0x1 ! *********"
  echo "********************************************"
  echo ""
  exit 1
fi

mkdir -p ${XCTOOL_CHAIN_NEW}/usr/bin
mkdir -p ${XCTOOL_CHAIN_NEW}/usr/lib
ln -sf ${XCTOOL_CHAIN_ORI}/Developer ${XCTOOL_CHAIN_NEW}/Developer
ln -sf ${XCTOOL_CHAIN_ORI}/usr/bin/* ${XCTOOL_CHAIN_NEW}/usr/bin/
ln -sf ${XCTOOL_CHAIN_ORI}/usr/include ${XCTOOL_CHAIN_NEW}//usr/include
ln -sf ${XCTOOL_CHAIN_ORI}/usr/lib/* ${XCTOOL_CHAIN_NEW}//usr/lib/
ln -sf ${XCTOOL_CHAIN_ORI}/usr/libexec ${XCTOOL_CHAIN_NEW}//usr/libexec
ln -sf ${XCTOOL_CHAIN_ORI}/usr/metal ${XCTOOL_CHAIN_NEW}//usr/metal
ln -sf ${XCTOOL_CHAIN_ORI}/usr/share ${XCTOOL_CHAIN_NEW}//usr/share
if [ $? -ne 0 ]; then
  echo ""
  echo "********************************************"
  echo "******** Installation Failed 0x2 ! *********"
  echo "********************************************"
  echo ""
  exit 1
fi

cp -Rf $TOOLCHAINS_DIR/lib/libLLVMPassSkeleton* "${XCTOOL_CHAIN_NEW}/usr/lib/"
if [ $? -ne 0 ]; then
  echo ""
  echo "********************************************"
  echo "******** Installation Failed 0x3 ! *********"
  echo "********************************************"
  echo ""
  exit 1
fi

rm -rf ${XCTOOL_CHAIN_NEW}/usr/bin/clang
cp -Rf $TOOLCHAINS_DIR/bin/clang "${XCTOOL_CHAIN_NEW}/usr/bin/clang"

# 修正软链到clang的tool
find "${XCTOOL_CHAIN_ORI}/usr/bin" -type l -lname "clang" | while read -r symlink; do
    toolname=$(basename $symlink)
    echo "Found symbolic link: $symlink toolname: $toolname"
    rm -rf ${XCTOOL_CHAIN_NEW}/usr/bin/$toolname
    ln -sf clang ${XCTOOL_CHAIN_NEW}/usr/bin/${toolname}
done

if [ $? -ne 0 ]; then
  echo ""
  echo "********************************************"
  echo "******** Installation Failed 0x4 ! *********"
  echo "********************************************"
  echo ""
  exit 1
fi

cp -f "$TOOLCHAINS_DIR/ToolchainInfo.plist" "${XCTOOL_CHAIN_NEW}/ToolchainInfo.plist"
if [ $? -ne 0 ]; then
  echo ""
  echo "********************************************"
  echo "******** Installation Failed 0x5 ! *********"
  echo "********************************************"
  echo ""
  exit 1
fi

echo ""
echo "**************************************************************"
echo "********* Congratulations! Installation Successful! **********"
echo "**************************************************************"
echo ""
