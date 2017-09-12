# Docker Container for SilverStripe Development

A server equiped with apache and PHP 7.1. Intended to be used with [docker-compose](http://github.com/dynamic/silverstripe-docker-compose) and a MySQL container.

Works best on MacOS with Docker Toolbox, rather than Docker for Mac.

## Requirements


- [Docker Toolbox](https://www.docker.com/products/docker-toolbox/)


## Usage

Below, subsititue `yourproject` with the name of your project.

### Create A Machine

Create a new machine for your project:

`docker-machine create --driver virtualbox yourproject`

### Start a Machine

If you've already created a machine:

`docker-machine start yourproject`

### Set the Environment

Tell Docker to talk to the new machine:

`docker-machine env yourproject`

Connect your shell to the new machine. You need to do this each time you open a new shell or restart your machine:

`eval "$(docker-machine env yourproject)"`

### Docker Compose

Create a `docker-compose.yml` file:

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

Get the machine IP:

`docker-machine ip yourproject`

In your browser, navigate to the IP returned about, port `8080`

`http://192.168.99.100:8080`

### Webroot

Once your environment has been built and the containers have been started, a `public` folder will be created. Place your project files there.

### Stop a Machine

`docker-compose stop`

`docker-machine stop yourproject`

### Database Info

For SilverStripe projects:

```
# DB credentials
SS_DATABASE_SERVER="database"
SS_DATABASE_USERNAME="root"
SS_DATABASE_PASSWORD=""
SS_DATABASE_NAME="yourproject"
```

### SSH Access

`docker exec -it yourproject_web_1 bash`