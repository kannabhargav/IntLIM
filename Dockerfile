FROM rocker/shiny:4.1.0

RUN apt-get update --allow-releaseinfo-change && apt-get install -y build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev default-libmysqlclient-dev r-base

RUN R -e "install.packages(c('devtools', 'DT', 'ggplot2', 'gplots', 'graphics', 'grDevices', 'heatmaply', 'highcharter', 'htmltools', 'KernSmooth', 'margins', 'methods', 'MASS', 'RColorBrewer', 'reshape2', 'rmarkdown', 'shiny', 'shinydashboard', 'shinyFiles', 'shinyjs', 'stats', 'testthat', 'utils'), repos = 'http://cran.r-project.org/')"

COPY install-dependency.R install-dependency.R
RUN Rscript install-dependency.R

#RUN R -e "update.packages(ask = FALSE)"

COPY install-intlim.R install-intlim.R
RUN Rscript install-intlim.R

COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
