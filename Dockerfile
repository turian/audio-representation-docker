# ==================================================================
# module list
# ------------------------------------------------------------------
# python        3.7    (apt)
# pytorch       latest (pip)
# tensorflow    1.13.1 (pip)
# ==================================================================

FROM nvidia/cuda:11-devel-ubuntu18.04
ENV LANG C.UTF-8
RUN APT_INSTALL="apt-get install -y --no-install-recommends" && \
    PIP_INSTALL="python -m pip --no-cache-dir install --upgrade" && \
    GIT_CLONE="git clone --depth 10" && \

    rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \

    apt-get update && \

# ==================================================================
# tools
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        build-essential \
        apt-utils \
        ca-certificates \
        wget \
        git \
        vim \
        libssl-dev \
        curl \
        unzip \
        unrar \
        && \

    $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
    cd ~/cmake && \
    ./bootstrap && \
    make -j"$(nproc)" install && \

# ==================================================================
# python
# ------------------------------------------------------------------

    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        software-properties-common \
        && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
        python3.7 \
        python3.7-dev \
        python3-distutils-extra \
        && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3.7 ~/get-pip.py && \
    ln -s /usr/bin/python3.7 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.7 /usr/local/bin/python && \
    $PIP_INSTALL \
        setuptools \
        && \
    $PIP_INSTALL \
        numpy \
        scipy \
        pandas \
        cloudpickle \
        scikit-image>=0.14.2 \
        scikit-learn \
        matplotlib \
        Cython \
        tqdm \
        && \

# ==================================================================
# pytorch
# ------------------------------------------------------------------

    $PIP_INSTALL \
        future \
        numpy \
        protobuf \
        enum34 \
        pyyaml \
        typing \
        && \
    $PIP_INSTALL \
        --pre torch torchvision -f \
        https://download.pytorch.org/whl/nightly/cu110/torch_nightly.html \
        && \

# ==================================================================
# tensorflow
# ------------------------------------------------------------------

    $PIP_INSTALL \
        tensorflow-gpu==1.13.1 \
        && \

# ==================================================================
# config & cleanup
# ------------------------------------------------------------------

    ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* ~/*

EXPOSE 6006
# Add non root user
RUN useradd -ms /bin/bash audio && echo "audio:audio" | chpasswd && adduser audio sudo

WORKDIR /home/audio

RUN pip3 install -q soundfile tqdm resampy tabulate
#pip install -q "tensorflow-gpu<1.14"
#ln -sf /opt/bin/nvidia-smi /usr/bin/nvidia-smi
RUN pip3 install gputil psutil humanize

# Open l3
RUN pip3 install -q openl3

# Wavenet
RUN pip3 install -q magenta

RUN wget -q -c http://download.magenta.tensorflow.org/models/nsynth/wavenet-ckpt.tar && tar xf wavenet-ckpt.tar
RUN git clone https://github.com/xavierfav/coala.git
RUN perl -i -pe 's/torch==1.5.0//g' coala/requirements.txt
RUN perl -i -pe 's/torchvision==0.6.0/torchvision/g' coala/requirements.txt
RUN perl -i -pe 's/"device": .*/"device": "cuda"/g' coala/configs/*
RUN pip install -q -r coala/requirements.txt
RUN ln -s coala/utils.py
RUN ln -s coala/models_t1000.py
RUN ln -s coala/scaler_top_1000.pkl
RUN ln -s coala/scaler_top_1000.pkl
RUN ln -s coala/json

USER audio
ENV HOME /home/audio
