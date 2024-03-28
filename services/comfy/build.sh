#!/bin/bash

set -Eeuo pipefail

ROOT=/comfyui-launcher

echo $ROOT
ls -lha $ROOT
ls -lha / 

echo "Installing pm2..."
apt-get install -y ca-certificates curl gnupg ufw
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs
npm install -g npm@9.8.0
npm install -g pm2@latest
pm2 status

cd ${ROOT}

pm2 start --name launcher "./run.sh"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_ed25519
rm -rf /etc/nginx
ssh-keyscan github.com > ~/.ssh/githubKey
ssh-keygen -lf ~/.ssh/githubKey
cat ~/.ssh/githubKey >> ~/.ssh/known_hosts
git clone -b comfy-node git@github.com:stakeordie/emprops-nginx-conf.git /etc/nginx
apt install -y nvtop
service nginx start

# Comma separated string to array
# IFS=, read -r -a models <<<"${MODELS}"

# # Array to parameter list
# echo "WAITING TO START UP BEFORE LOADING MODELS..."

# sleep 75

# # Array to parameter list
# echo "Loading models: ${MODELS}"

# for model in "${models[@]}"; do echo $model && python /docker/loader.py -m $model; done

echo "~~READY~~"