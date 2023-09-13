#!/bin/sh

echo "Starting virtual Lustre cluster"

./start_mxs.sh

if [ $? -eq 0 ]; then
  echo "Successfully started MXS"
else
  echo "Failed to start MXS" >&2
  exit 1
fi

sleep 2s

./start_oss.sh

if [ $? -eq 0 ]; then
  echo "Successfully started OSS"
else
  echo "Failed to start OSS" >&2
  exit 1
fi

sleep 2s

NUM_CLIENT=2
for i in $(seq 1 $NUM_CLIENT)
do

CLIENT_NAME="client$i"

  ./start_client.sh $i
  if [ $? -eq 0 ]; then
    echo "Successfully started $CLIENT_NAME"
  else
    echo "Failed to start $CLIENT_NAME" >&2
    exit 1
  fi

done

