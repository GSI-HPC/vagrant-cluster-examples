#!/bin/sh

echo "Starting Object Storage Server (OSS)"

echo "*******************************************************************************"
echo "Booting up"
echo "*******************************************************************************"
vagrant up oss

echo "*******************************************************************************"
echo "Runing config management"
echo "*******************************************************************************"
./build_playbook_oss.sh
vagrant scp playbook_oss.yml oss:/home/vagrant/
vagrant ssh oss -c "sudo ansible-playbook /home/vagrant/playbook_oss.yml"

echo "*******************************************************************************"
echo "Last kernel logs"
echo "*******************************************************************************"
vagrant ssh oss -c "dmesg -T | tail; exit" 2>/dev/null

echo "*******************************************************************************"
echo "Checking Lustre OST mount points"
echo "*******************************************************************************"
CHECK=$(vagrant ssh oss -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 2 ]; then
  echo "All OSTs mounted on OSS"
else
  echo "Failed to mount all OSTs on OSS" >&2
  exit 1
fi

exit 0

