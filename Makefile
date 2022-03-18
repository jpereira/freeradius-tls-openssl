#FR_SOURCE := https://github.com/FreeRADIUS/freeradius-server.git
#FR_BRANCH := v3.0.x

FR_REPO := https://github.com/jpereira/freeradius-server.git
FR_BRANCH := v3/fix-ssl

DOCKER := docker

help:
	@echo "build       - Build the containers for FreeRADIUS v3.0.x + OpenSSL 1.1.x and OpenSSL 3.0.x"
	@echo "start       - Start both containers"
	@echo "stop        - Stop both containers"
	@echo "clean       - Remove both containers"
	@echo "ssl1.shell  - Get in test-freeradius-v3-ssl1.1.x containers"
	@echo "ssl1.logs   - Show all logs of test-freeradius-v3-ssl1.1.x"
	@echo "ssl1.auth   - Auth check"
	@echo ""
	@echo "ssl3.shell  - Get in test-freeradius-v3-ssl3.0.x containers"
	@echo "ssl3.logs   - Show all logs of test-freeradius-v3-ssl3.0.x"
	@echo "ssl3.auth   - Auth check"
	@echo ""

build: ssl1.build ssl3.build

restart: stop start

start: ssl1.start ssl3.start

stop: ssl1.stop ssl3.stop

auth: ssl1.auth ssl3.auth

clean: ssl1.clean ssl3.clean

# openssl 1.1.x
ssl1.clean:
	$(DOCKER) rm -f "test-freeradius-v3-ssl1.1.x" 1> /dev/null 2>&1 || true

ssl1.stop:
	$(DOCKER) stop "test-freeradius-v3-ssl1.1.x" 1> /dev/null 2>&1 || true

ssl1.start: ssl1.stop
	$(DOCKER) run -dt --rm --name "test-freeradius-v3-ssl1.1.x" --hostname "test-freeradius-v3-ssl1.1.x" networkradius/test-freeradius-v3-ssl1.1.x

ssl1.build:
	$(DOCKER) build --build-arg fr_repo=$(FR_REPO) --build-arg fr_branch=$(FR_BRANCH) "$(PWD)" -f "Dockerfile.freeradiusv3-openssl1.1.1j" -t networkradius/test-freeradius-v3-ssl1.1.x

ssl1.shell:
	$(DOCKER) exec -it test-freeradius-v3-ssl1.1.x /bin/bash

ssl1.logs:
	$(DOCKER) exec -it test-freeradius-v3-ssl1.1.x tail -f /var/log/radiusd.log

ssl1.auth:
	$(DOCKER) exec -it test-freeradius-v3-ssl1.1.x eapol_test -s testing123 -c /root/eap-ttls-mschapv2.conf

# openssl 3.0.x
ssl3.build:
	$(DOCKER) build --build-arg fr_repo=$(FR_REPO) --build-arg fr_branch=$(FR_BRANCH) "$(PWD)" -f "Dockerfile.freeradiusv3-openssl3.0.x" -t networkradius/test-freeradius-v3-ssl3.0.x

ssl3.clean:
	$(DOCKER) rm -f "test-freeradius-v3-ssl3.0.x" 1> /dev/null 2>&1 || true

ssl3.stop:
	$(DOCKER) stop "test-freeradius-v3-ssl3.0.x" 1> /dev/null 2>&1 || true

ssl3.start: ssl3.stop
	$(DOCKER) run -dt --rm --name "test-freeradius-v3-ssl3.0.x" --hostname "test-freeradius-v3-ssl3.0.x" networkradius/test-freeradius-v3-ssl3.0.x

ssl3.shell:
	$(DOCKER) exec -it test-freeradius-v3-ssl3.0.x /bin/bash

ssl3.logs:
	$(DOCKER) exec -it test-freeradius-v3-ssl3.0.x tail -f /var/log/radiusd.log

ssl3.auth:
	$(DOCKER) exec -it test-freeradius-v3-ssl3.0.x eapol_test -s testing123 -c /root/eap-ttls-mschapv2.conf 2>&1
