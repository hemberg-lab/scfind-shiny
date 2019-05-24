# scfind-shiny

This is a [shiny](https://shiny.rstudio.com/) implementation of the [`scfind` R package](http://bioconductor.org/packages/scfind) for searching cell atlases by genes.

## Running using Docker

To run `scfind-shiny` on a Cloud please create a Docker image of it using the [Dockerfile](Dockerfile) provided. Once the image is ready it can be run either locally or on a Cloud.

We have built our own image of `scfind-shiny` using [quay.io](quay.io). To run it locally:
```
docker run --rm -p 3838:3838 quay.io/hemberg-group/scfind-shiny:1.1.1
```
Then `scfind-shiny` will be accessible at http://localhost:3838/scfind/


To run in a detached mode on the Cloud:
```
docker run -d -p 80:3838 quay.io/hemberg-group/scfind-shiny:1.1.1
```
Then `scfind-shiny` will be accessible at http://YOUR_CLOUD_IP/scmap/. In our case it is [https://scfind.sanger.ac.uk](https://scfind.sanger.ac.uk).

Alternatively, you can manually install a Shiny server on your instance and all corresponding R packages mentioned in the [Dockerfile](Dockerfile). You will also need to copy your `scfind-shiny` files to `/srv/shiny-server/scfind` folder.

## Indexes

All `scfind` indexes used in this app are available for browsing and downloading from [here](https://scfind.cog.sanger.ac.uk/index.html?prefix=indexes/).