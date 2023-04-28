#!/bin/sh

echo "Starting Management and Metadata Server (MXS)"

echo "*******************************************************************************"
echo "Booting up"
echo "*******************************************************************************"
vagrant up mxs

echo "*******************************************************************************"
echo "Runing config management"
echo "*******************************************************************************"
./build_playbook_mxs.sh
vagrant scp playbook_mxs.yml mxs:/home/vagrant/
vagrant ssh mxs -c "sudo ansible-playbook /home/vagrant/playbook_mxs.yml"

echo "*******************************************************************************"
echo "Last kernel logs"
echo "*******************************************************************************"
vagrant ssh mxs -c "dmesg -T | tail; exit" 2>/dev/null

echo "*******************************************************************************"
echo "Checking Lustre mount point"
echo "*******************************************************************************"
CHECK=$(vagrant ssh mxs -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 1 ]; then
  echo "Lustre filesystem mounted on MXS"
else
  echo "Failed to mount Lustre filesystem on MXS" >&2
  exit 1
fi

exit 0

