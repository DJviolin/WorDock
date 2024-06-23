# WorDock

Wordpress Docker virtualization for local development replacing Xampp

## Installation

Add these lines to your `hosts` file:

```hosts
127.0.0.1 docker.test
127.0.0.1 www.docker.test
127.0.0.1 app1.test
127.0.0.1 www.app1.test
127.0.0.1 app2.test
127.0.0.1 www.app2.test
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

Copy `.env` file into it's place:

```sh
$ cp .env.example .env
```

```sh
# Start docker-compose
$ ./bin/compose.sh up

# Bootstrap the environment
$ ./bin/compose.sh bootstrap -s docker.test -p secret

# Verify everything running correctly
https://docker.test/phpinfo.php

# Backup webserver files & database
$ ./bin/compose.sh backup -s docker.test -d /mnt/c/temp

# Restore webserver files & database
$ ./bin/compose.sh restore -s docker.test -p secret -f /mnt/c/temp/<FILE_NAME>.tar.gz

# Stop the service
$ ./bin/compose.sh down

# Stop the service and destroy everything
$ ./bin/compose.sh prune
```
