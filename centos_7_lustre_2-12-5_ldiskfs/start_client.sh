#!/bin/sh

echo "Starting Client"

echo "*******************************************************************************"
echo "Booting up"
echo "*******************************************************************************"
vagrant up client

echo "*******************************************************************************"
echo "Runing config management"
echo "*******************************************************************************"
./build_playbook_client.sh
vagrant scp playbook_client.yml client:/home/vagrant/
vagrant ssh client -c "sudo ansible-playbook /home/vagrant/playbook_client.yml"

echo "*******************************************************************************"
echo "Last kernel logs"
echo "*******************************************************************************"
vagrant ssh client -c "dmesg -T | tail; exit" 2>/dev/null

echo "*******************************************************************************"
echo "Checking Lustre mount point"
echo "*******************************************************************************"
CHECK=$(vagrant ssh client -c "mount -l" 2>/dev/null | grep -c 'type lustre')

if [ "$CHECK" -eq 1 ]; then
  echo "Lustre filesystem mounted on client"
else
  echo "Failed to mount Lustre filesystem on client" >&2
  exit 1
fi

echo "*******************************************************************************"
echo "Lustre filesystem information"
echo "*******************************************************************************"
CHECK=$(vagrant ssh client -c 'lfs df -h' 2>/dev/null | grep -c filesystem_summary)

if [ "$CHECK" -eq 1 ]; then
  vagrant ssh client -c "lfs df -h; exit" 2>/dev/null
else
  echo "Failed to retrieve Lustre filesystem information on client" >&2
  exit 2
fi

exit 0

