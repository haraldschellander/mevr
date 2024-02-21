FROM rocker/verse:latest

# install system dependencies
RUN apt-get update -qq && \
    apt-get -y --no-install-recommends install \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

#  install R dependencies
RUN R -e "devtools::install_cran('sf')"
RUN R -e "devtools::install_gitlab(repo = 'kmayer/zamg.trend', \
    host = 'vgitlab.zamg.ac.at', dependencies = TRUE)"

RUN R -q -e "devtools::install_gitlab(repo = 'r-packages/mevr', \
             subdir = 'mevr', \
             host = 'https://gitlab.geosphere.at', \
             auth_token = 'glpat-BmwsJ8M5yWYXQJsX798_', \
             upgrade = 'always', \
             dependencies = TRUE)"



# start with shell
ENTRYPOINT [""]

