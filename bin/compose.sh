#!/bin/sh

set -e

DIR=$( cd "$(dirname $0)" && pwd )
. $DIR/env_variables.sh

usage_fn() {
	cat <<- EOF
	####################################################
	Run Docker Compose project
	    Usage: $0 up|down|prune|bootstrap|backup|restore
	####################################################
	EOF
}

check_docker_fn() {
	if [ ! "$(docker compose ps --services --status running | grep $1)" ]; then
		echo "ERROR: \"$1\" container does not exist..." >&2 # write error message to stderr
		exit 1
	fi
}

up_fn() {
	echo "Start Docker Compose project"
	docker compose \
		--env-file $ABS_PATH/.env \
		--file $ABS_PATH/compose.yaml \
		up --detach $SERVICES
}

down_fn() {
	echo "Stop and remove containers, networks"
	docker compose \
		--env-file $ABS_PATH/.env \
		--file $ABS_PATH/compose.yaml \
		down
}

prune_fn() {
	echo "Prune everything"
	echo "Remove all containers"
		docker container stop $(docker container ls --all --quiet) 2>/dev/null || true
		docker container prune --force
	echo "Remove all unused local volumes"
		docker volume prune --force
	echo "Remove all unused networks"
		docker network prune --force
	echo "Remove unused images"
		docker image prune --all --force
}

cleanup_fn() {
	echo "Cleanup Docker leftovers"
	echo "Remove all unused data"
		docker system prune --all --force
	echo "Remove build cache"
		docker builder prune --all --force
}

bootstrap_fn() {
	# A POSIX variable
	# Reset in case getopts has been used previously in the shell.
	OPTIND=1

	check_docker_fn 'mariadb'
	echo "Download Wordpress & Create database"

	usage() {
		echo "Usage: $0 bootstrap [ -s SITE NAME ] [ -p MYSQL PASSWORD ]" 1>&2
	}

	while getopts "hs:p:" opt; do
		case "$opt" in
			h)
				usage
				exit 0
				;;
			s)
				site=$OPTARG
				;;
			p)
				pass=$OPTARG
				;;
		esac
	done
	shift $((OPTIND-1))
	[ "${1:-}" = "--" ] && shift
	# echo "site=$site, password=$pass, Leftovers: $@"

	if [ -z "$site" ] || [ -z "$pass" ]; then
        echo "Error: Both -s (site name) and -p (MySQL password) are required."
        echo "Please refer to the help page for usage."
        usage
		exit 1
    fi

	echo "Bootstrapping site: $site"
	dir="$PROJECT_CONTAINER_DIR/$site"
	db="${site}_db"
	user="${site}_user"

	docker compose cp $DIR/benchmark.html php-fpm:$dir/benchmark.html
	docker compose exec php-fpm sh -c "set -e \
		&& mkdir -p $dir && curl -L https://wordpress.org/latest.tar.gz | tar -xzf - -C $dir --strip-components=1 \
		&& echo \"<?php phpinfo(); ?>\" > $dir/phpinfo.php \
		&& chown -R $USER_NAME:$USER_NAME $PROJECT_CONTAINER_DIR/$site \
	"
	docker compose exec mariadb sh -c "mariadb -uroot -p$MYSQL_ROOT_PASSWORD -e' \
		CREATE DATABASE IF NOT EXISTS \`$db\` COLLATE \"$COLLATION\"; \
		CREATE USER IF NOT EXISTS \"$user\"@\"%\" IDENTIFIED BY \"$pass\"; \
		GRANT ALL PRIVILEGES ON \`$db\`.* TO \"$user\"@\"%\"; \
		ALTER DATABASE \`$db\` COLLATE \"$COLLATION\"; \
	' -v"

	# Catch-All domain to Apache
	# docker compose exec php-fpm sh -c "set -e \
	# 	&& mkdir -p $PROJECT_CONTAINER_DIR/$SERVER_NAME \
	# 	&& echo '<html><body><h1>It works!</h1></body></html>' > $PROJECT_CONTAINER_DIR/$SERVER_NAME/index.html \
	# 	&& chown -R $USER_NAME:$USER_NAME $PROJECT_CONTAINER_DIR/$SERVER_NAME \
	# "
}

backup_fn() {
	OPTIND=1
	check_docker_fn 'mariadb'
	echo "Backup single site to custom location"

	usage() {
		echo "Usage: $0 backup [ -s SITE NAME ] [ -d DIRECTORY ]" 1>&2
	}

	while getopts "hs:d:" opt; do
		case "$opt" in
			h)
				usage
				exit 0
				;;
			s)
				site=$OPTARG
				;;
			d)
				dir=$OPTARG
				;;
		esac
	done
	shift $((OPTIND-1))
	[ "${1:-}" = "--" ] && shift

	if [ -z "$site" ] || [ -z "$dir" ]; then
        echo "Error: Both -s (site name) and -d (directory) are required."
        echo "Please refer to the help page for usage."
        usage
		exit 1
    fi

	echo "Backing up site: $site"
	archive="${site}_$TIMESTAMP"
	dest="$PROJECT_HOST_DIR/$archive"
	dir_data="$dest/data"
	dir_sql="$dest/sql"
	db="${site}_db"
	mkdir -p $dir_data $dir_sql

	# Backup .htaccess file
	docker compose exec php-fpm sh -c "set -e \
		&& cp $PROJECT_CONTAINER_DIR/$site/.htaccess $PROJECT_CONTAINER_DIR/$site/htaccess \
	"
	docker compose cp php-fpm:$PROJECT_CONTAINER_DIR/$site/ $dir_data
	mv $dir_data/$site/* $dir_data
	rm -r $dir_data/$site

	docker compose exec mariadb sh -c "mariadb-dump -uroot -p$MYSQL_ROOT_PASSWORD \
		--lock-tables=false --single-transaction --quick \
		$db" > $dir_sql/$db.sql

	(cd $dest && tar -czf $dir/backup_${archive}.tar.gz data sql)
	rm -r $dest
}

restore_fn() {
	OPTIND=1
	check_docker_fn 'mariadb'
	echo "Restore single site from custom location"

	usage() {
		echo "Usage: $0 restore [ -s SITE NAME ] [ -p MYSQL PASSWORD ] [ -f ARCHIVE LOCATION ]" 1>&2
	}

	while getopts "hs:p:f:" opt; do
		case "$opt" in
			h)
				usage
				exit 0
				;;
			s)
				site=$OPTARG
				;;
			p)
				pass=$OPTARG
				;;
			f)
				archive=$OPTARG
				;;
		esac
	done
	shift $((OPTIND-1))
	[ "${1:-}" = "--" ] && shift

	if [ -z "$site" ] || [ -z "$pass" ] || [ -z "$archive" ]; then
        echo "Error: Both -s (site name), -p (MySQL password) and -f (archive location) are required."
        echo "Please refer to the help page for usage."
        usage
		exit 1
    fi

	echo "Restoring site: $site"
	file="$(basename "$archive" .tar.gz)"
	dest="$PROJECT_HOST_DIR/$file"
	db="${site}_db"
	user="${site}_user"
	dir_data="$dest/data"
	dir_sql="$dest/sql/$db.sql"
	mkdir -p $dest
	tar -xf $archive -C $dest

	docker compose cp $dir_data/ php-fpm:/tmp/
	docker compose exec php-fpm sh -c "set -e \
		&& rm -rf $PROJECT_CONTAINER_DIR/$site \
		&& mkdir -p $PROJECT_CONTAINER_DIR/$site \
		&& mv /tmp/data/* $PROJECT_CONTAINER_DIR/$site \
		&& mv $PROJECT_CONTAINER_DIR/$site/htaccess $PROJECT_CONTAINER_DIR/$site/.htaccess \
		&& chown -R $USER_NAME:$USER_NAME $PROJECT_CONTAINER_DIR/$site \
		&& rm -rf /tmp/data \
	"

	docker compose exec mariadb sh -c "mariadb -uroot -p$MYSQL_ROOT_PASSWORD -e' \
		DROP DATABASE IF EXISTS \`$db\`; \
		DROP USER IF EXISTS \"$user\"@\"%\"; \
		\
		CREATE DATABASE \`$db\` COLLATE \"$COLLATION\"; \
		CREATE USER \"$user\"@\"%\" IDENTIFIED BY \"$pass\"; \
		GRANT ALL PRIVILEGES ON \`$db\`.* TO \"$user\"@\"%\"; \
		ALTER DATABASE \`$db\` COLLATE \"$COLLATION\"; \
	' -v"
	docker compose cp $dir_sql mariadb:/tmp/
	docker compose exec mariadb sh -c "set -e \
		&& mariadb -uroot -p$MYSQL_ROOT_PASSWORD -D$db < /tmp/$db.sql \
		&& rm /tmp/$db.sql \
	"

	rm -rf $dest
}

case "$1" in
	up)
		up_fn
		;;
	down)
		down_fn
		;;
	prune)
		down_fn
		prune_fn
		cleanup_fn
		;;
	bootstrap)
		shift # Remove the first argument `bootstrap` from the argument list
		bootstrap_fn "$@" # Pass the remaining arguments
		;;
	backup)
		shift
		backup_fn "$@"
		;;
	restore)
		shift
		restore_fn "$@"
		;;
	*)
		usage_fn
		echo "$0: unknown argument provided => $1\n"
		exit 1
		;;
esac
