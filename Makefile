DOCKER := docker
DOCKET_OPTS :=

build: build.frv3_openssl1.1.x build.frv3_openssl3.0.x

build.frv3_openssl1.1.x:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.freeradiusv3-openssl1.1.1j" -t networkradius/test-freeradius-v3-ssl1.1.x

build.frv3_openssl3.0.x:
	$(DOCKER) build $(DOCKER_OPTS) "$(PWD)" -f "Dockerfile.freeradiusv3-openssl3.0.1" -t networkradius/test-freeradius-v3-ssl3.0.x

shell.ssl1:
	$(DOCKER) run --rm --name "test-freeradius-v3-ssl1.1.x" --hostname "test-freeradius-v3-ssl1.1.x" -it networkradius/test-freeradius-v3-ssl1.1.x /bin/bash

shell.ssl3:
	$(DOCKER) run --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl3.0.x" -it networkradius/test-freeradius-v3-ssl3.0.x /bin/bash

