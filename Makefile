all: bootstrap

build: ## build a keystone docker image
	docker build -t keystone .

run: ## run the keystone docker image, linked to mysql
	docker run -t -d -h 127.0.0.1 --link mysql:mysql -p 0.0.0.0:35357:35357 -p 0.0.0.0:5000:5000 \
      -v /etc/localtime:/etc/localtime --restart unless-stopped --name keystone keystone

ssl-run: ## run the keystone docker image, linked to mysql
	mkdir -p ./ssl
	docker run -t -d -h 127.0.0.1 --link mysql:mysql -e HTTPS_ENABLED=true -p 0.0.0.0:35357:35357 \
	-p 0.0.0.0:5000:5000 -v /etc/localtime:/etc/localtime -v `pwd`/ssl/:/etc/apache2/ssl \
	--name keystone keystone

run-mysql:
	docker run -d --name mysql --restart unless-stopped --ulimit nofile=65536:65536 keystone-mysql --max-connections=500

build-mysql:
	docker build -t keystone-mysql -f Dockerfile.mysql .

restart:
	docker start mysql && docker start keystone

stop:
	docker ps | grep keystone | awk '{ print $$1 }' | xargs docker stop

kill: ## kill the docker images
	docker ps | grep keystone | awk '{ print $$1 }' | xargs docker kill > /dev/null
	docker ps -a | grep keystone | awk '{ print $$1 }' | xargs docker rm -v > /dev/null

bash: ## run interactive bash in the keystone image
	docker exec -it keystone /bin/bash

bootstrap: build-mysql run-mysql build run ## build/run mysql & keystone docker image

bootstrap-ssl: build-mysql run-mysql build ssl-run
