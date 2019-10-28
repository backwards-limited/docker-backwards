# Assignment 7 - Compose File for Multi Container Service

Goals:

- Build a compose file for a Drupal content management system
- Use image **drupal** and **postgres**
- Use **ports** to expose Drupal on 8080 e.g. localhost:8080
- Set **POSTGRES_PASSWORD** for postgres
- Walk through Drupal setup via browser
- Watchout - Drupal assumes DB is **localhost** but we will need service name
- Use volumes to store Drupal unique data

See [docker-compose.yml](docker-compose.yml).

