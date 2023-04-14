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

FOUND=`vagrant ssh client -c "lfs df -h | grep -c filesystem_summary; exit" 2>/dev/null`

if [ $FOUND -eq 1 ]; then
  echo "Lustre filesystem information found on client!"
else
  echo "No Lustre filesystem information found on client!"
fi
