FROM rocker/shiny:3.5.1

# install some R required stuff
RUN apt-get update -y --no-install-recommends \
    && apt-get -y install -f \
       zlib1g-dev \
       libssl-dev \
       libcurl4-openssl-dev \
       gnupg2 \
       python3-software-properties \
       software-properties-common \
       apt-utils \
       apt-transport-https \
       && apt-get clean && \
       rm -rf /var/lib/apt/lists/*

# R packages
# https://askubuntu.com/questions/610449/w-gpg-error-the-following-signatures-couldnt-be-verified-because-the-public-k
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# https://launchpad.net/~marutter/+archive/ubuntu/c2d4u3.5
RUN echo "deb http://ppa.launchpad.net/marutter/c2d4u3.5/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/marutter/c2d4u3.5/ubuntu xenial main" | sudo tee -a /etc/apt/sources.list
# Install CRAN binaries from ubuntu
RUN apt-get update && apt-get install -yq --no-install-recommends \
    r-cran-data.table \
    r-cran-DT \
    r-cran-devtools \
    r-cran-ggplot2 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'source("https://bioconductor.org/biocLite.R")' > /opt/bioconductor.r && \
    echo 'biocLite()' >> /opt/bioconductor.r && \
    echo 'biocLite(c("SingleCellExperiment", "SummarizedExperiment"))' >> /opt/bioconductor.r && \
    Rscript /opt/bioconductor.r

RUN Rscript -e "devtools::install_github('pati-ni/scfind', ref='develop')"

# install shiny
RUN export ADD=shiny && bash /etc/cont-init.d/add

# add app to the server
ADD indexes indexes/
ADD app app/
RUN for d in indexes/*/; do cp app/* "$d"; done
RUN cp -r indexes/* /srv/shiny-server

# update the index page
COPY index_page/index.html /srv/shiny-server/index.html
COPY index_page/img /srv/shiny-server/img

CMD ["/usr/bin/shiny-server.sh"]
