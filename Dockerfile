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
# download indexes from google drive
# https://github.com/circulosmeos/gdown.pl
ADD gdown.pl /
RUN ./gdown.pl https://drive.google.com/file/d/17SURePw72sv7AO2-KLe2VCKNiTzsnfO-/view?usp=sharing indexes/atacseq/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/17NkExp_xlZGY3uBOgB7TzAM8JbsQg2GG/view?usp=sharing indexes/mca/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/17GTbjMw0u1r3aBKxYdA4aGLCVxqCnJgz/view?usp=sharing indexes/tm-10X/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/17GfNSaOvc4kM7pYMna3jBLsRKcRfjD_E/view?usp=sharing indexes/tm-facs/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/17PzfTuhiTdfz1hIRzJfBNHJxCWIojNFU/view?usp=sharing indexes/brain/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/172cKeUU47wLQ_5qHpkg65JylRMDm0QAU/view?usp=sharing indexes/malaria/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/175rs8N4gxRYzRAUoZiXVtMPLMHk7TnUT/view?usp=sharing indexes/liver/www/data.rds
RUN ./gdown.pl https://drive.google.com/file/d/178n081u8DsRdFrMY7o14exHOLU1wNigr/view?usp=sharing indexes/spinalcord/www/data.rds
ADD app app/
RUN for d in indexes/*/; do cp app/* "$d"; done
RUN cp -r indexes/* /srv/shiny-server

# update the index page
COPY index_page/index.html /srv/shiny-server/index.html
COPY index_page/img /srv/shiny-server/img
COPY index_page/doc /srv/shiny-server/doc
COPY index_page/css /srv/shiny-server/css

# R packages
RUN install2.r data.table DT devtools ggplot2 hash

RUN echo 'source("https://bioconductor.org/biocLite.R")' > /opt/bioconductor.r && \
    echo 'biocLite()' >> /opt/bioconductor.r && \
    echo 'biocLite(c("SingleCellExperiment", "SummarizedExperiment"))' >> /opt/bioconductor.r && \
    Rscript /opt/bioconductor.r

RUN Rscript -e "devtools::install_github('thjimmylee/scfind', ref = 'patch-3-umap')"

# try to avoid greying out of the apps
# https://stackoverflow.com/questions/44397818/shiny-apps-greyed-out-nginx-proxy-over-ssl
RUN echo 'sanitize_errors off;disable_protocols xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile;' >> /etc/shiny-server/shiny-server.conf

CMD ["/usr/bin/shiny-server.sh"]
