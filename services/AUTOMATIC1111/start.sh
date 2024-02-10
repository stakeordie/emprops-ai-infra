#!/bin/bash

set -Eeuo pipefail

mkdir ${ROOT}/models/Stable-diffusion && cd ${ROOT}/models/Stable-diffusion
wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors
wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.safetensors
wget --no-verbose --show-progress --progress=dot:giga https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
wget --no-verbose --show-progress --progress=dot:giga https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

cd ${ROOT}

pm2 start --name webui "python -u webui.py --opt-sdp-no-mem-attention --api --nowebui --port 3130 --medvram --no-half-vae"

service nginx start

# Comma separated string to array
IFS=, read -r -a models <<<"${MODELS}"

# Array to parameter list
echo "Loading models: ${MODELS}"

sleep 50

for model in "${models[@]}"; do echo $model && python /docker/loader.py -m $model; done

echo "~~READY~~"

sleep infinity