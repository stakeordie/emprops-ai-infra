#!/bin/bash

set -Eeuo pipefail

pm2 start --name webui "python -u webui.py --opt-sdp-no-mem-attention --api --port 3130 --medvram --no-half-vae"

service nginx start

# Comma separated string to array
IFS=, read -r -a models <<<"$MODELS"

# Array to parameter list
for model in "${models[@]}"; do python loader.py -m $models; done

sleep infinity