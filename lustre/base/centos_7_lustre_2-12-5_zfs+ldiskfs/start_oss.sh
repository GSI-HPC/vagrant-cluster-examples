#!/bin/sh

echo "Starting Object Storage Server (OSS)"

vagrant up oss
vagrant provision oss

echo "************************************ DEBUG ************************************"
vagrant ssh oss -c "dmesg -T | tail; exit" 2>/dev/null
echo "*******************************************************************************"

CHECK=$(vagrant ssh oss -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 2 ]; then
  echo "All OSTs mounted on OSS"
else
  echo "Failed to mount all OSTs on OSS" >&2
  exit 1
fi

exit 0

