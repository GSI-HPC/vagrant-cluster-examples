#!/bin/sh

echo "Starting Client"

vagrant up client
vagrant provision client

echo "************************************ DEBUG ************************************"
echo ""
echo "Last kernel messages:"
echo ""
vagrant ssh client -c "dmesg -T | tail; exit" 2>/dev/null
echo ""
echo "Lustre filesystem information:"
echo ""
vagrant ssh client -c "lfs df -h; exit" 2>/dev/null
echo "*******************************************************************************"

CHECK=$(vagrant ssh client -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 1 ]; then
  echo "Lustre filesystem mounted on client"
else
  echo "Failed to mount Lustre filesystem on client" >&2
  exit 1
fi

CHECK=$(vagrant ssh client -c 'lfs df -h' 2>/dev/null | grep -c filesystem_summary)

if [ "$CHECK" -eq 1 ]; then
  echo "Lustre filesystem information found on client"
else
  echo "Failed to retrieve Lustre filesystem information on client" >&2
  exit 2
fi

exit 0

