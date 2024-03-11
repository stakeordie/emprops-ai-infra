FROM pytorch/pytorch:2.1.2-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

RUN apt-get update && apt-get install -y git rsync nginx wget nano && apt-get clean

ARG GITACCESSKEY

COPY build.sh /build.sh
COPY .bash_aliases /root/.bash_aliases
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo ${GITACCESSKEY} >> ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519

ENV ROOT=/stable-diffusion
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/ComfyWorkflows/comfyui-launcher ${ROOT}

WORKDIR ${ROOT}
COPY . /docker/
RUN chmod u+x /docker/start.sh && chmod u+x /docker/build.sh && cp /docker/extra_model_paths.yaml ${ROOT}

CMD /docker/start.sh