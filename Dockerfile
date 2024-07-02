FROM nvidia/cuda:12.5.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=New_York

# Remove any third-party apt sources to avoid issues with expiring keys.
# Install some basic utilities
# RUN rm -f /etc/apt/sources.list.d/*.list && \
RUN \
    --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    sudo \
    git \
    wget \
    procps \
    git-lfs \
    zip \
    unzip \
    htop \
    vim \
    nano \
    bzip2 \
    libx11-6 \
    build-essential \
    libsndfile-dev \
    software-properties-common \
    gnupg \
    net-tools
#  && rm -rf /var/lib/apt/lists/*

# RUN add-apt-repository ppa:flexiondotorg/nvtop && \
#     apt-get upgrade -y && \
#     apt-get install -y --no-install-recommends nvtop

RUN \
    --mount=type=cache,target=/var/cache/apt \
     mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key |  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg &&\
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt update && \
    apt install nodejs -y
RUN npm install -g configurable-http-proxy


# RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash - && \
#     apt-get install -y nodejs && \
#     npm install -g configurable-http-proxy

# Create a working directory
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN mkdir $HOME/.cache $HOME/.config \
 && chmod -R 777 $HOME


# Set up the Conda environment
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=$HOME/miniconda/bin:$PATH
RUN curl -sLo ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-py310_24.4.0-0-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda clean -ya


WORKDIR $HOME/app

#######################################
# Start root user section
#######################################

USER root

# User Debian packages
## Security warning : Potential user code executed as root (build time)
RUN --mount=target=/root/packages.txt,source=packages.txt \
    apt-get update && \
    xargs -r -a /root/packages.txt apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*





 USER user

 # Python packages
 RUN --mount=target=requirements.txt,source=requirements.txt \
 pip install --no-cache-dir --upgrade -r requirements.txt
 
 #RUN pip install --upgrade "@plotly/dash-jupyterlab"
 #RUN pip install --user -U jgtfxcon
 
USER root
WORKDIR /opt/sr
COPY ./StrategyRunner-Linux-x86_64.tar.gz .
#RUN --mount=target=/opt/sr/StrategyRunner-Linux-x86_64.tar.gz,source=sr/StrategyRunner-Linux-x86_64.tar.gz \
RUN tar xzf StrategyRunner-Linux-x86_64.tar.gz && rm StrategyRunner-Linux-x86_64.tar.gz
RUN \
    --mount=type=cache,target=/var/cache/apt \
     apt update && apt upgrade -y
RUN echo "upgraded 2407020613">>/_upgraded.txt
RUN npm install droxul -g
USER user   
WORKDIR $HOME/app
