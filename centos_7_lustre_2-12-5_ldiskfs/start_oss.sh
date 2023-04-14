#!/bin/sh

echo "Starting Object Storage Server (OSS)"

vagrant up oss
vagrant provision oss

echo "************************************ DEBUG ************************************"
vagrant ssh oss -c "dmesg -T | tail; exit" 2>/dev/null
echo "*******************************************************************************"
