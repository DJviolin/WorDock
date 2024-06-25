# WorDock

Wordpress Docker virtualization for local development replacing Xampp

## Installation

Add these lines to your `hosts` file:

```hosts
127.0.0.1 docker.test
127.0.0.1 www.docker.test
```

This project can be used with any Linux/Mac environment with Docker installed. WSL2 + Docker Desktop is recommended for Windows users.

Prepare WSL2:

```powershell
PS wsl --set-default-version 2
PS wsl --install --distribution Ubuntu
# Username: user
# Password: secret
PS wsl --set-default Ubuntu
PS wsl -l -v
PS wsl --update
$ sudo apt update && sudo apt upgrade -y
```

## Usage

```sh
# Copy `.env` file into it's place and edit your settings
$ cp .env.example .env

# Start docker-compose
$ ./bin/compose.sh up

# Bootstrap the environment
# Database name: app1_db
# Database user: app1_user
# Database password: secret
# Database host: mariadb
$ ./bin/compose.sh bootstrap -s app1 -p secret

# Verify everything running correctly
https://docker.test/phpinfo.php

# Use an SFTP client (like FileZilla) to copy the files (default password: examplepass)
sftp -P 2222 www-data@docker.test

# Open your app after you copied the files
https://docker.test/app1

# Backup webserver files & database
$ ./bin/compose.sh backup -s app1 -d /mnt/c/temp

# Restore webserver files & database
$ ./bin/compose.sh restore -s app1 -p secret -f /mnt/c/temp/<FILE_NAME>.tar.gz

# Stop the service
$ ./bin/compose.sh down

# Stop the service and destroy everything (except volumes)
$ ./bin/compose.sh prune
```
