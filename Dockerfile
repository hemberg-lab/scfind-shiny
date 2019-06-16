FROM rocker/shiny:3.5.1

# install some R required stuff
RUN apt-get update -y --no-install-recommends \
    && apt-get -y install -f \
       zlib1g-dev \
       libssl-dev \
       libcurl4-openssl-dev \
       wget \
       libxml2-dev \
       && apt-get clean && \
       rm -rf /var/lib/apt/lists/*

# add app to the server
RUN mkdir -p indexes/atacseq/www/
RUN mkdir -p indexes/mca/www/
RUN mkdir -p indexes/tm-10X/www/
RUN mkdir -p indexes/tm-facs/www/
RUN mkdir -p indexes/brain/www/
RUN mkdir -p indexes/malaria/www/
RUN mkdir -p indexes/liver/www/
RUN mkdir -p indexes/spinalcord/www/
RUN mkdir -p indexes/kidney/www/
RUN wget https://scfind.cog.sanger.ac.uk/indexes/atacseq.rds -O indexes/atacseq/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/mca.rds -O indexes/mca/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/tm_10X.rds -O indexes/tm-10X/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/tm_facs.rds -O indexes/tm-facs/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/LinnarssonAtlas.rds -O indexes/brain/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/malaria_index.rds -O indexes/malaria/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/HLiver_MacParland.rds -O indexes/liver/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/SpinalCordAtlas.rds -O indexes/spinalcord/www/data.rds
RUN wget https://scfind.cog.sanger.ac.uk/indexes/HKidney_Clatworthy.rds -O indexes/kidney/www/data.rds
ADD app app/
RUN for d in indexes/*/; do cp app/* "$d"; done
RUN cp -r indexes/* /srv/shiny-server

# update the index page
COPY index_page/index.html /srv/shiny-server/index.html
COPY index_page/img /srv/shiny-server/img
COPY index_page/doc /srv/shiny-server/doc
COPY index_page/css /srv/shiny-server/css

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.0

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "bea4570d7358016d8ed29d2c15787dbefaea3e746c570763e7ad6040f17831f3 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# R packages
RUN install2.r data.table DT devtools ggplot2 hash JuliaCall wordcloud

RUN echo 'source("https://bioconductor.org/biocLite.R")' > /opt/bioconductor.r && \
    echo 'biocLite()' >> /opt/bioconductor.r && \
    echo 'biocLite(c("SingleCellExperiment", "SummarizedExperiment"))' >> /opt/bioconductor.r && \
    Rscript /opt/bioconductor.r

RUN Rscript -e "devtools::install_github('hemberg-lab/scfind', ref = 'shiny-server')"

# try to avoid greying out of the apps
# https://stackoverflow.com/questions/44397818/shiny-apps-greyed-out-nginx-proxy-over-ssl
COPY cfg/shiny-server.conf /etc/shiny-server/shiny-server.conf

CMD ["/usr/bin/shiny-server.sh"]
