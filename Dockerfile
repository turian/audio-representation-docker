FROM ubuntu:18.04
ENV LANG C.UTF-8

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Add non root user
RUN useradd -ms /bin/bash repr && echo "repr:repr" | chpasswd && adduser repr sudo

WORKDIR /home/repr

RUN apt-get update
RUN apt-get install -y git build-essential python3-pip

RUN pip3 install -q tqdm tabulate
RUN pip3 install -q "tensorflow-gpu<1.14"
#ln -sf /opt/bin/nvidia-smi /usr/bin/nvidia-smi
RUN pip3 install gputil psutil humanize

RUN apt-get install -y wget git
RUN wget -q -c http://download.magenta.tensorflow.org/models/nsynth/wavenet-ckpt.tar && tar xf wavenet-ckpt.tar
RUN git clone https://github.com/xavierfav/coala.git
RUN perl -i -pe 's/torch==1.5.0//g' coala/requirements.txt
RUN perl -i -pe 's/torchvision==0.6.0/torchvision/g' coala/requirements.txt
RUN perl -i -pe 's/"device": .*/"device": "cuda"/g' coala/configs/*
RUN ln -s coala/utils.py
RUN ln -s coala/models_t1000.py
RUN ln -s coala/scaler_top_1000.pkl
RUN ln -s coala/json

RUN apt-get install -y libsndfile-dev vorbis-tools
RUN apt-get install -y lsb-release wget software-properties-common
#RUN apt-get install -y llvm clang
RUN apt-get install -y llvm-10*

RUN cd /usr/bin && ln -s llvm-config-10 llvm-config
#RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
RUN pip3 install soundfile tqdm resampy tabulate

# Open l3
RUN pip3 install openl3

# Wavenet
RUN pip3 install magenta

RUN pip3 install -r coala/requirements.txt

USER repr
ENV HOME /home/repr
