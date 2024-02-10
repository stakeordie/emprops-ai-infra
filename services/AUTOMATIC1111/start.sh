#!/bin/bash

set -Eeuo pipefail

pm2 start --name webui "python -u webui.py --opt-sdp-no-mem-attention --api --port 3130 --medvram --no-half-vae"

service nginx start



sleep infinity