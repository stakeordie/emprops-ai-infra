#!/bin/bash

set -Eeuo pipefail

mkdir -vp /data/config/comfy/custom_nodes

echo $ROOT
ls -lha $ROOT
ls -lha /

apt-get install git-lfs
git lfs install
git clone https://github.com/stakeordie/sd_models.git /docker/emprops_models_repo
rm -rf /docker/emprops_models_repo/.git

echo "Installing pm2..."
apt-get install -y ca-certificates curl gnupg
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs
npm install -g npm@9.8.0
npm install -g pm2@latest
pm2 status

declare -A MOUNTS

MOUNTS["/root/.cache"]="/data/.cache"
MOUNTS["${ROOT}/input"]="/data/config/comfy/input"
MOUNTS["${ROOT}/output"]="/output/comfy"

for to_path in "${!MOUNTS[@]}"; do
  set -Eeuo pipefail
  from_path="${MOUNTS[${to_path}]}"
  rm -rf "${to_path}"
  if [ ! -f "$from_path" ]; then
    mkdir -vp "$from_path"
  fi
  mkdir -vp "$(dirname "${to_path}")"
  ln -sT "${from_path}" "${to_path}"
  echo Mounted $(basename "${from_path}")
done

if [ -f "/data/config/comfy/startup.sh" ]; then
  pushd ${ROOT}
  . /data/config/comfy/startup.sh
  popd
fi

rsync -avz --progress /docker/emprops_models_repo/Lora /stable-diffusion/models/loras
rsync -avz --progress /docker/emprops_models_repo/ESRGAN /stable-diffusion/models/upscale_models
rsync -avz --progress /docker/emprops_models_repo/GFPGAN /stable-diffusion/models/upscale_models
rsync -avz --progress /docker/emprops_models_repo/RealESRGAN /stable-diffusion/models/upscale_models
rsync -avz --progress /docker/emprops_models_repo/ScuNET /stable-diffusion/models/upscale_models
rsync -avz --progress /docker/emprops_models_repo/SwinIR /stable-diffusion/models/upscale_models

# mkdir ${ROOT}/models/Stable-diffusion && cd ${ROOT}/models/Stable-diffusion
# ## 1.5
wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.safetensors -O /stable-diffusion/v1-5-pruned.safetensors

# ## 2.1
# wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.safetensors && MODELS+=",v2-1_768-ema-pruned.safetensors"

# ## SDXL
# wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0_0.9vae.safetensors && MODELS+=",sd_xl_refiner_1.0_0.9vae.safetensors"

# ##SDXL Refiner
# wget --no-verbose --show-progress --progress=bar:force:noscroll https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors && MODELS+=",sd_xl_base_1.0_0.9vae.safetensors"

# ##JuggernautXL
# wget --no-verbose --show-progress --progress=bar:force:noscroll "https://civitai.com/api/download/models/288982?type=Model&format=SafeTensor&size=full&fp=fp16" -O juggernautXL_v8Rundiffusion.safetensors && MODELS+=",juggernautXL_v8Rundiffusion.safetensors"

# ##EpiCPhotoGasm
# wget --no-verbose --show-progress --progress=bar:force:noscroll "https://civitai.com/api/download/models/223670?type=Model&format=SafeTensor&size=full&fp=fp16" -O epiCPhotoGasm.safetensors && MODELS+=",epiCPhotoGasm.safetensors"

cd ${ROOT}

pm2 start --name webui "python -u main.py --port 3130"

eval "$(ssh-agent -s)"
ssh-add /root/.ssh/id_ed25519
rm -rf /etc/nginx
ssh-keyscan github.com > ~/.ssh/githubKey
ssh-keygen -lf ~/.ssh/githubKey
cat ~/.ssh/githubKey >> ~/.ssh/known_hosts
git clone -b sd-node git@github.com:stakeordie/emprops-nginx-conf.git /etc/nginx
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