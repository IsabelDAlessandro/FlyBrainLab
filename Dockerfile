# Initial setup
FROM continuumio/miniconda3
MAINTAINER FlyBrainLab <x@gmail.com>
ADD . /code
WORKDIR /code

#Set up apt-get
RUN apt-get update && apt-get install -y --allow-unauthenticated apt-transport-https
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty main universe" >> /etc/apt/sources.list
RUN apt-get update


# Install basic applications
RUN apt-get install -y build-essential

#Python dependencies
RUN conda create -n neuromynerva python=3.6 nodejs jupyterlab cookiecutter git -c conda-forge
#NOTE: This is not recommended, but it does work
ENV PATH /opt/conda/envs/neuromynerva/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py networkx
#RUN /bin/bash -c "conda activate ffbolabdev && pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py networkx"
RUN pip install txaio twisted autobahn crochet service_identity autobahn-sync matplotlib h5py networkx
RUN git clone https://github.com/FlyBrainLab/Neuroballad.git
WORKDIR ./Neuroballad
RUN python setup.py develop
WORKDIR ..
RUN git clone https://github.com/FlyBrainLab/FBLClient.git
WORKDIR ./FBLClient
RUN python setup.py develop

#NPM dependencies
WORKDIR ..
RUN git clone https://github.com/FlyBrainLab/FlyBrainLab.git
WORKDIR ./FlyBrainLab
RUN yarn install
RUN npm run build
RUN npm run build && npm run link

WORKDIR ..

#Launch app
CMD jupyter lab --allow-root --ip=$(hostname -I)
