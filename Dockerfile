FROM rocker/r-ver:3.5.3


RUN apt-get update --fix-missing -qq && \
    apt-get install -y -q \
    vim \
    git \
    python3 \
    python3-pip \
    python \
    python-pip \
    libz-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libpng-dev \
    libjpeg-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libgl-dev \
    libgsl-dev \
    && apt-get clean \
    && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
RUN pip3 install numpy pandas sklearn statsmodels matplotlib seaborn
#
RUN pip install numpy 
#
RUN mkdir -p /usr/local/lib/R/site-library/
ADD latticeExtra /usr/local/lib/R/site-library/latticeExtra
#
RUN R -e 'install.packages(c("BiocManager", "devtools", "argparse", "statmod"))'
#
RUN R -e 'install.packages("XML", repos = "http://www.omegahat.net/R")'
#
RUN R -e 'install.packages("Hmisc")'
#
RUN R -e 'BiocManager::install(c("EnrichmentBrowser", "tximport", "rhdf5"))'

RUN R -e 'BiocManager::install("ballgown")'
#
#RUN R -e 'BiocManager::install("pachterlab/sleuth")'
#
ADD data /home/data
ADD scripts /home/scripts

