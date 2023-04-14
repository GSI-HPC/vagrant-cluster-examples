#!/bin/bash

echo "Starting virtual Lustre cluster"

./start_mxs.sh

sleep 2s

./start_oss.sh

sleep 2s

./start_client.sh
