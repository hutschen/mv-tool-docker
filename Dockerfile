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

FROM alpine:3.16.2

# Install main dependencies
# RUN apk update \
#     && apk add --no-cache nodejs=16.16.0-r0 \
#     && apk add --no-cache nginx=1.22.0-r1

# Copy sources
WORKDIR /usr/src
COPY ./mv-tool-api ./api
COPY ./mv-tool-ng ./ng

# Install Python dependencies
WORKDIR /usr/src/api
RUN apk update \
    && apk add --no-cache python3=3.10.5-r0 py3-pip=22.1.1-r0 \
    && apk add --no-cache --virtual api-build-deps build-base python3-dev=3.10.5-r0 \
    && pip3 install pipenv \
    && pipenv install --ignore-pipfile --system --deploy \
    && pip3 uninstall -y pipenv \
    && apk del api-build-deps

# Install npm dependencies and build Angular app
WORKDIR /usr/src/ng
# Install and set up Nginx
RUN apk update \
    && apk add --no-cache nginx=1.22.0-r1

WORKDIR /usr/src/api
COPY ./config.yml ./config.yml
# ENTRYPOINT [ "uvicorn", "mvtool:app", "--host", "0.0.0.0", "--port", "8000"]