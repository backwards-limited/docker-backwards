FROM ubuntu:latest

LABEL author = davidainslie

RUN apt-get update
RUN apt-get install -y nodejs npm
RUN apt-get clean

RUN mkdir src/
WORKDIR src/

CMD ["npm", "start"]

ONBUILD COPY ./package.json ./
ONBUILD RUN npm install
ONBUILD COPY . .