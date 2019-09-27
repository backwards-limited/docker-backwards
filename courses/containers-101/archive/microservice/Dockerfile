FROM ubuntu:latest

LABEL author = davidainslie

RUN apt-get update

RUN apt-get install -y nodejs npm

RUN apt-get clean

# Our microservice

COPY ./package.json src/

RUN cd src && npm install

COPY . src/

WORKDIR src/

CMD ["npm", "start"]