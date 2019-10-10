# Assignment 4 - Build own Dockerfile

Goals:

- Dockerize an existing Node.js app
- Use Alpine version of the official "node" 6.x image
- Expected result is web site at [http://localhost](http://localhost)
- Tag and push to your Docker Hub account
- Remove image from local cache and run again from Hub

In [assignment root](../assignments/4), we have to source code and [Dockerfile](../assignments/4/Dockerfile):

```dockerfile
FROM node:8.16.1-alpine

EXPOSE 3000

WORKDIR /app

COPY package.json .

RUN npm install

COPY . .

CMD ["npm", "start"]
```

Build:

```bash
➜ docker image build -t davidainslie/nodejs-app .
```

Run:

```bash
➜ docker container run --rm -p 80:3000 davidainslie/nodejs-app
```

Assert:

```bash
➜ http localhost:80
HTTP/1.1 200 OK
...
```

There is an [alternative](../assignments/4/Dockerfile-alt):

```bash
➜ docker image build -t davidainslie/nodejs-app -f Dockerfile-alt .

➜ docker container run --rm -p 80:3000 davidainslie/nodejs-app
```

Finally; push; delete locally; and run again (which will result in a pull):

```bash
➜ docker image push davidainslie/nodejs-app
The push refers to repository [docker.io/davidainslie/nodejs-app]
...
sha256:79ba796ebb8292d4cc4bbbf79ca90e2bd93fde874cd1abe26ade46222522c31b size: 1997

➜ docker image rm davidainslie/nodejs-app
Untagged: davidainslie/nodejs-app:latest
...

➜ docker container run --rm -p 80:3000 davidainslie/nodejs-app
Unable to find image 'davidainslie/nodejs-app:latest' locally
latest: Pulling from davidainslie/nodejs-app
...

➜ http localhost
HTTP/1.1 200 OK
```

