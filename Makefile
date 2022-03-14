DOCKER := docker

help:
	@echo "build       - Build the containers for FreeRADIUS v3.0.x + OpenSSL 1.1.x and OpenSSL 3.0.x"
	@echo "start       - Start both containers"
	@echo "ssl1.shell  - Get in test-freeradius-v3-ssl1.1.x containers"
	@echo "ssl1.logs   - Show all logs of test-freeradius-v3-ssl1.1.x"
	@echo ""
	@echo "ssl3.shell  - Get in test-freeradius-v3-ssl3.0.x containers"
	@echo "ssl3.logs   - Show all logs of test-freeradius-v3-ssl3.0.x"
	@echo ""

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

ssl1.logs:
	$(DOCKER) exec -it test-freeradius-v3-ssl1.1.x tail -f /var/log/radiusd.log

# openssl 3.0.x
ssl3.build:
	$(DOCKER) build "$(PWD)" -f "Dockerfile.freeradiusv3-openssl3.0.1" -t networkradius/test-freeradius-v3-ssl3.0.x

ssl3.start:
	$(DOCKER) rm -f "test-freeradius-v3-ssl3.0.x" 1> /dev/null 2>&1 || true
	$(DOCKER) run -dt --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl1.1.x" networkradius/test-freeradius-v3-ssl3.0.x

ssl3.shell:
	$(DOCKER) exec -t test-freeradius-v3-ssl1.1.x --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl3.0.x" -it networkradius/test-freeradius-v3-ssl3.0.x /bin/bash

ssl3.logs:
	$(DOCKER) exec -it test-freeradius-v3-ssl3.0.x tail -f /var/log/radiusd.log
