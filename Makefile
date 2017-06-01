all: bootstrap

build: ## build a keystone docker image
	docker build -t keystone .

run: ## run the keystone docker image, linked to mysql
	docker run -t -d --link mysql:mysql -p 127.0.0.1:35357:35357 -p 127.0.0.1:5000:5000 --name keystone keystone

run-mysql:
	docker run -d --name mysql keystone-mysql

build-mysql: 
	docker build -t keystone-mysql -f Dockerfile.mysql .

kill: ## kill the docker images
	docker ps | grep keystone | awk '{ print $$1 }' | xargs docker kill > /dev/null
	docker ps -a | grep keystone | awk '{ print $$1 }' | xargs docker rm > /dev/null

bash: ## run interactive bash in the keystone image
	docker exec -it keystone /bin/bash

bootstrap: build-mysql run-mysql build run ## build/run mysql & keystone docker image
