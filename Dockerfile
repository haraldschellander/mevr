FROM rocker/verse:latest
#FROM rocker/r-ver:4.3.0

# install system dependencies
RUN apt-get update -qq && \
    apt-get -y --no-install-recommends install \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev 

#  install R dependencies
#Run R -q -e "install.packages(c('bamlss', 'doParallel', 'EnvStats', 'foreach'))"
RUN R -q -e "R.version.string" 
Run R -q -e "install.packages(c('devtools', 'remotes'))"

# install mevr package
RUN R -q -e "devtools::install_gitlab(repo = 'r-packages/mevr', \
             host = 'https://gitlab.geosphere.at', \
             auth_token = 'glpat-2UsdDMAyTuXzYVFhiBeM', \
             upgrade = 'always', \
             dependencies = TRUE)"


# start with shell
ENTRYPOINT [""]

