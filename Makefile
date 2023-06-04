# Copyright (C) 2022 Helmar Hutschenreuter
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

build:
	docker image build --platform linux/amd64 -t hutschen/mv-tool:latest .

scan:
	docker scan hutschen/mv-tool:latest

cmd:
	docker container rm -f mv-tool
	docker container run -it --name mv-tool \
		-p 4200:8000 \
		-v $(shell pwd)/config.yml:/usr/src/api/config.yml \
		--entrypoint '/bin/sh' hutschen/mv-tool

run:
	docker container rm -f mv-tool
	docker container create --name mv-tool -p 4200:8000 hutschen/mv-tool
	docker container cp config.yml mv-tool:/usr/src/api/config.yml
	if [ -f key.pem ]; then docker container cp key.pem mv-tool:/usr/src/api/key.pem; fi
	if [ -f cert.pem ]; then docker container cp cert.pem mv-tool:/usr/src/api/cert.pem; fi
	docker container start mv-tool

test:
	docker container rm -f mv-tool
	docker container run -it --name mv-tool \
		-v $(shell pwd)/config.yml:/usr/src/api/config.yml \
		--entrypoint '/bin/sh' hutschen/mv-tool \
		-c 'pip install pytest pytest-alembic && pytest'

push:
	docker image push hutschen/mv-tool

tag:
	docker image tag hutschen/mv-tool hutschen/mv-tool:$(tag)
	docker image push hutschen/mv-tool:$(tag)

save:
	docker image save hutschen/mv-tool:latest -o mv-tool.tar

pull:
	docker pull --platform linux/amd64 hutschen/mv-tool:$(tag)
	docker image tag hutschen/mv-tool:$(tag) hutschen/mv-tool:latest

load:
	docker image load -i mv-tool.tar

submodules-update:
	git submodule update --init --recursive
