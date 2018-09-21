FROM rocker/shiny:3.5.1

# install some R required stuff
RUN apt-get update -y --no-install-recommends \
    && apt-get -y install -f \
       zlib1g-dev \
       libssl-dev \
       libcurl4-openssl-dev \
       wget \
       && apt-get clean && \
       rm -rf /var/lib/apt/lists/*

# R packages
RUN install2.r data.table DT devtools ggplot2 hash

RUN echo 'source("https://bioconductor.org/biocLite.R")' > /opt/bioconductor.r && \
    echo 'biocLite()' >> /opt/bioconductor.r && \
    echo 'biocLite(c("SingleCellExperiment", "SummarizedExperiment"))' >> /opt/bioconductor.r && \
    Rscript /opt/bioconductor.r

RUN Rscript -e "devtools::install_github('pati-ni/scfind', ref='develop')"

# add app to the server
ADD indexes indexes/
# download indexes from google drive
RUN ./gdown.pl https://drive.google.com/file/d/1xz_ecGA0L85OzNf3Y2ifjYRyn3-H7q3X/view\?usp\=sharing indexes/mca/www/mca.rds
ADD app app/
RUN for d in indexes/*/; do cp app/* "$d"; done
RUN cp -r indexes/* /srv/shiny-server

# update the index page
COPY index_page/index.html /srv/shiny-server/index.html
COPY index_page/img /srv/shiny-server/img

CMD ["/usr/bin/shiny-server.sh"]
