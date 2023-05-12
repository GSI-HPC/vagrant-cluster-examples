#!/bin/sh

echo "Starting Management and Metadata Server (MXS)"

vagrant up mxs
#vagrant provision mxs

echo "************************************ DEBUG ************************************"
vagrant ssh mxs -c "dmesg -T | tail; exit" 2>/dev/null
echo "*******************************************************************************"

CHECK=$(vagrant ssh mxs -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 1 ]; then
  echo "Lustre filesystem mounted on MXS"
else
  echo "Failed to mount Lustre filesystem on MXS" >&2
  exit 1
fi

exit 0

