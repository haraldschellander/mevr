FROM rocker/verse:latest
#FROM rocker/r-ver:4.3.0

ARG GITLAB_PAT

# install system dependencies
RUN apt-get update -qq && \
    apt-get -y --no-install-recommends install \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev 

#  install R dependencies
#RUN R -q -e "R.version.string" 
Run R -q -e "install.packages(c('devtools', 'remotes'), repos = 'cran.r-project.org')"
Run R -q -e "install.packages(c('bamlss', 'doParallel', 'EnvStats', 'foreach'), repos = 'cran.r-project.org')"

# install mevr package
RUN R -q -e "devtools::install_gitlab(repo = 'r-packages/mevr', \
             host = 'https://gitlab.geosphere.at', \
             upgrade = 'always', \
             dependencies = TRUE)"
#             auth_token = 'glpat-2UsdDMAyTuXzYVFhiBeM', \

# start with shell
ENTRYPOINT [""]

