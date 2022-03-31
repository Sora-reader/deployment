##########
# Config #
##########

# Include dotenv's variables is exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

_CYAN ?= \033[0;36m
_CYAN_BOLD ?= \033[1;36m
_RED ?= \033[0;31m
_COFF ?= \033[0m

COMPOSE_COMMAND ?= docker-compose
DOCKER_USER ?= docker_user
REPO_DIR ?= $(shell pwd)
DOCKER_USER_HOME ?= /home/${DOCKER_USER}/
_GET_PASSWORD_HASH = 'print crypt($$ARGV[0], "password")'

ARGS := $(filter-out $@,$(MAKECMDGOALS))

# Repo dirs
backend_dir = ${BACKEND_PATH}
frontend_dir = ${FRONTEND_PATH}
nginx_dir = ./
deployment_dir = ./
# ---------

.PHONY: install-prerequisites install-docker install-docker-compose \
	check-dotenv dotenv dotenv-other \
	create-user clone set-commit deploy force-redeploy

.ONESHELL:
.DEFAULT: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(word 1,$(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(_CYAN)%-30s$(_COFF) %s\n", $$1, $$2}'

%: # stub so that chained targets won't fire. Allows to pass positional arguments to targets. Also has a stub for error if target not found
	@:
		$(if ${ARGS},,$(error No rule to make target '$@'))

###############
# Depedencies #
###############

install-prerequisites: ## Install prerequisites
	sudo apt update
	sudo apt install git curl

install-docker: install-prerequisites ## Install docker
	sudo apt-get install -y \
		apt-transport-https \
		ca-certificates \
		software-properties-common
	curl -fsSL 'https://download.docker.com/linux/ubuntu/gpg' | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(shell lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce
	sudo docker run hello-world
	# Linux post-install
	sudo groupadd docker
	sudo usermod -aG docker $USER
	sudo systemctl enable docker
	sudo systemctl start docker

install-docker-compose: install-docker ## Install docker-compose
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(shell uname -s)-$(shell uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

##############
# Management #
##############

check-dotenv: # check dotenvs
	@$(eval DOTENVS := $(shell test -f ./.env && echo 'nonzero string'))
	$(if $(DOTENVS),,$(error No .env files found, maybe run "make dotenv"?))

dotenv: ## Copy all repo's dotenvs
	cp -i .env.example .env

dotenv-other: ## Generate other service-specific dotenvs
	cp -i ${BACKEND_PATH}/.envs.example/deployment.env.example backend.env

create-user: check-dotenv ## Create user for docker and give him permissions
	# Setup group
	sudo groupadd sora_deployment
	sudo usermod -aG sora_deployment ${USER}
	sudo chown -R :sora_deployment ${REPO_DIR}
	sudo chmod g+rwx -R ${REPO_DIR}
	# create docker_user and add to groups
	sudo useradd -s /bin/bash --create-home -p $(shell perl -e $(_GET_PASSWORD_HASH) ${DOCKER_USER_PASSWORD}) ${DOCKER_USER}
	sudo usermod -aG docker ${DOCKER_USER}
	sudo usermod -aG sora_deployment ${DOCKER_USER}
	sudo chown -R :sora_deployment ${DOCKER_USER_HOME}
	sudo chmod g+rwx -R ${DOCKER_USER_HOME}
	sudo echo "export DEPLOYMENT_DIR=${REPO_DIR}" >> ${DOCKER_USER_HOME}/.profile
	@echo; echo "${_CYAN}Please, reload shell with ${_CYAN_BOLD}exec newgrp sora_deployment${_COFF}"

clone: ## Clone all repos
	git -C $(shell realpath ${BACKEND_PATH} | xargs dirname) clone https://oauth:${GITHUB_PAT}@github.com/sora-reader/backend.git
	git -C $(shell realpath ${FRONTEND_PATH} | xargs dirname) clone https://oauth:${GITHUB_PAT}@github.com/sora-reader/frontend.git

set-commit: check-dotenv ## Hard reset repo's dir given reference
	cd ${${ARGS}_dir}
	git fetch origin "${CURRENT_BRANCH}"
	git reset --hard "origin/${CURRENT_BRANCH}"

deploy: check-dotenv ## Deploy specified service
	$(COMPOSE_COMMAND) up --build -d ${ARGS}

force-redeploy: check-dotenv ## Force redeploy all services
	$(COMPOSE_COMMAND) up -d --force-recreate

