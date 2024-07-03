FROM guillaumeai/server:hfjudkbase


ENV DEBIAN_FRONTEND=noninteractive \
	TZ=New_York

USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
USER root
RUN mkdir -p $HOME/.cache $HOME/.config \
 && chmod -R 777 $HOME

 

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
