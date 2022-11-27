FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

ARG UID=1000
ARG GID=1000

# add new sudo user
ENV USERNAME cudagl
ENV HOME /home/$USERNAME
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        usermod  --uid $UID $USERNAME && \
        groupmod --gid $GID $USERNAME

# install package
RUN echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" > /etc/apt/apt.conf.d/docker-gzip-indexes
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo \
        less \
        emacs \
        tmux \
        bash-completion \
        command-not-found \
        software-properties-common \
        curl \
        wget \
        coreutils \
        build-essential \
        pkg-config \
        git \
        xdg-user-dirs \
        libgl1-mesa-dev \
        freeglut3-dev \
        mesa-utils \
        vulkan-tools \
        libvulkan-dev \
        libglfw3-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config/nvidia_icd.json /usr/share/vulkan/icd.d/

ARG XDG_RUNTIME_DIR="/tmp/xdg_runtime_dir"
RUN mkdir -p ${XDG_RUNTIME_DIR} && chmod 777 ${XDG_RUNTIME_DIR}

USER $USERNAME
WORKDIR /home/$USERNAME
SHELL ["/bin/bash", "-l", "-c"]
RUN echo "export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" >> ~/.bashrc
RUN echo "export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" >> ~/.bashrc

