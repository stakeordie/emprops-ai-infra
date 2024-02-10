#!/bin/bash

set -Eeuo pipefail

pm2 start --name webui "python -u webui.py --opt-sdp-no-mem-attention --api --port 3130 --medvram --no-half-vae"

service nginx start

# Comma separated string to array
IFS=, read -r -a models <<<"${MODELS}"

# Array to parameter list
echo "Loading models: ${MODELS}"

sleep 125

for model in "${models[@]}"; do echo $model && python loader.py -m $model; done

sleep infinity