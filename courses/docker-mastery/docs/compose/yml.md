# docker-compose.yml

- Configure relationships between containers
- Save our docker container run settings in *easy to read* file
- Create one-liner developer environment setups
- Comprised of two separate but related tools:
  - YAML formatted file that describes our solution options for:
    - containers
    - networks
    - volumes
  - CLI tool **docker-compose** used for local dev/test automation with YAML files

The default file name is **docker-compose.yml** but any can be specified with:

- docker-compose -f

