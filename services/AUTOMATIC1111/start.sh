#!/bin/bash

set -Eeuo pipefail

pm2 start --name webui "python -u webui.py --opt-sdp-no-mem-attention --api --port 3130 --medvram --no-half-vae"

service nginx start

# Comma separated string to array
IFS=, read -r -a models <<<"${MODELS}"

# Array to parameter list
echo "Loading models: ${MODELS}"

echo $number  # Output: 25
pm2 logs --format | grep auto | while read line
do
    id=$(echo "$line" | grep -oP '(?<=id=)\d+')
    echo "$line" | grep "message=Model loaded in"
    if [ $? = 0 ]
    then
      for model in "${models[@]}"; do echo $model && python loader.py -m $model; done
      break;
    fi
done

sleep infinity