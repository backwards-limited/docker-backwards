# Assignment 6 - Bind Mounts

Goals:

- Use a Jekyll Static Site Generator to start a local web server
- This example shows of bridging the gap between local file access and apps in containers
- We edit files and container detects changes to host files and updates web server
- Start container with **docker container run -p 80:4000 -v $(pwd):/site bretfisher/jekyll-serve**
- Change file in **_posts** and refresh browser to see changes