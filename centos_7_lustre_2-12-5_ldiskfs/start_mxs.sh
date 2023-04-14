echo "Starting Management and Metadata Server (MXS)"

vagrant up mxs
vagrant provision mxs

echo "************************************ DEBUG ************************************"
vagrant ssh mxs -c "dmesg -T | tail; exit" 2>/dev/null
echo "*******************************************************************************"
