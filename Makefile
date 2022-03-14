DOCKER := docker

build: ssl1.build ssl3.build

start: ssl1.start ssl3.start

# openssl 1.1.x
ssl1.start:
	$(DOCKER) rm -f "test-freeradius-v3-ssl1.1.x" 1> /dev/null 2>&1 || true
	$(DOCKER) run -dt --rm --name "test-freeradius-v3-ssl1.1.x" --hostname "test-freeradius-v3-ssl1.1.x" networkradius/test-freeradius-v3-ssl1.1.x

ssl1.build:
	$(DOCKER) build "$(PWD)" -f "Dockerfile.freeradiusv3-openssl1.1.1j" -t networkradius/test-freeradius-v3-ssl1.1.x

ssl1.shell:
	$(DOCKER) exec -it test-freeradius-v3-ssl1.1.x /bin/bash

# openssl 3.0.x
ssl3.build:
	$(DOCKER) build "$(PWD)" -f "Dockerfile.freeradiusv3-openssl3.0.1" -t networkradius/test-freeradius-v3-ssl3.0.x

ssl3.start:
	$(DOCKER) rm -f "test-freeradius-v3-ssl3.0.x" 1> /dev/null 2>&1 || true
	$(DOCKER) run -dt --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl1.1.x" networkradius/test-freeradius-v3-ssl3.0.x

ssl3.shell:
	$(DOCKER) exec -t test-freeradius-v3-ssl1.1.x --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl3.0.x" -it networkradius/test-freeradius-v3-ssl3.0.x /bin/bash
