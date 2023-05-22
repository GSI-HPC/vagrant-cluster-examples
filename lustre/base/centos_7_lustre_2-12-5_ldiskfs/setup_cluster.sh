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

./start_client.sh

if [ $? -eq 0 ]; then
  echo "Successfully started client"
else
  echo "Failed to start client" >&2
  exit 1
fi

