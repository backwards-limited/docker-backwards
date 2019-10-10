# This sample shows how we can extend/change an existing official image from Docker Hub

FROM nginx:latest
# Highly recommend you always pin versions for anything beyond dev/learn

WORKDIR /usr/share/nginx/html
# Change working directory to root of nginx webhost using WORKDIR is preferred to using 'RUN cd /some/path'

COPY index.html index.html

# Don't have to specify EXPOSE or CMD because they're in my FROM
