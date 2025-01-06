#!/bin/bash

if [ $UID -ne 0 ]; then
  echo "please run this script as root"
  exit 1
fi

echo "Uninstalling Toolchains..."

XCODE_PATH=$(xcode-select -p)
if [ ! -d $XCODE_PATH ]; then
	echo "$XCODE_PATH not found"
	echo ""
	echo "********************************************"
	echo "******* Uninstallation Failed 0x1 ! ********"
	echo "********************************************"
	echo ""
	exit 1
fi

XCTOOL_CHAIN=$XCODE_PATH/Toolchains/KK-Xcode.xctoolchain
if [ ! -d "${XCTOOL_CHAIN}" ];then
	echo "$XCTOOL_CHAIN not found"
	echo ""
	echo "********************************************"
	echo "******* Uninstallation Failed 0x2 ! ********"
	echo "********************************************"
	echo ""
	exit 1
fi

rm -rf ${XCTOOL_CHAIN}
if [ $? -ne 0 ]; then
	echo ""
	echo "********************************************"
	echo "******* Uninstallation Failed 0x3 ! ********"
	echo "********************************************"
	echo ""
	exit 1
fi

echo ""
echo "*************************************************************"
echo "******** Congratulations! Uninstallation Successful! ********"
echo "*************************************************************"
echo ""
