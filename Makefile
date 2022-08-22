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
	docker image build -t hutschen/mv-tool:latest .

cmd:
	docker container rm -f mv-tool
	docker container run -it --name mv-tool hutschen/mv-tool

run:
	docker container rm -f mv-tool
	docker container create --name mv-tool -it -p 4200:8000 hutschen/mv-tool
	docker container cp config.yml mv-tool:/usr/src/api/config.yml
	docker container start mv-tool

push:
	docker image push hutschen/mv-tool