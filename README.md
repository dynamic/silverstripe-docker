# Docker Container for Silverstripe Development

A server equiped with apache and PHP 8.2. Intended to be used with [docker-compose](http://github.com/dynamic/silverstripe-docker-compose) and a MySQL container.

## Requirements


- [Docker Desktop](https://www.docker.com/products/docker-desktop/)


## Usage

Below, subsititue `yourproject` with the name of your project.

### Docker Compose

Create a `docker-compose.yml` file in your project root:

```
version: '3'
services:
 web:
   image: dynamicagency/silverstripe-docker
   working_dir: /var/www
   ports:
    - 8080:80
   volumes:
    - .:/var/www
    - ./public:/var/www/html

 database:
   image: mysql
   volumes:
    - db-data:/var/lib/mysql
   restart: always
   environment:
    - MYSQL_ALLOW_EMPTY_PASSWORD=true

volumes:
 db-data:
```

In terminal, bring the Docker containers up:

`docker-compose up -d`

### Setup Your Environment

For Silverstripe projects:

```
# DB credentials
SS_DATABASE_SERVER="database"
SS_DATABASE_USERNAME="root"
SS_DATABASE_PASSWORD=""
SS_DATABASE_NAME="yourproject"
SS_BASE_URL="http://localhost:8080/"
```



In your browser, navigate to localhost port `8080`

`http://localhost:8080`

### SSH Access

Get the project name:

`docker ps`

Connect to the web container:

`docker exec -it yourproject-web-1 bash`

### Database access via SSH

`mysql -u root -h database yourproject`

### Stop a Machine

`docker-compose stop` or

`docker-machine stop yourproject`
