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

# Copy sources
WORKDIR /usr/src
COPY ./mv-tool-api ./api
COPY ./mv-tool-ng ./ng

# Install dependencies for web API
#
# 1. Install runtime dependencies
#    - mailcap for inferring MIME types from file extensions
#    - python3 and pip3
#      (Yes, pip3 is curiosly needed during runtime.)
# 2. Install build dependencies
#    - build-base for building Python C extensions
#    - python-dev contains necessary headers for building Python C extensions
# 3. Install pipenv for installing python3 dependencies
# 4. Install python3 dependencies using pipenv
# 5. Remove pipenv
# 6. Remove build dependencies
WORKDIR /usr/src/api
RUN apk update \
    && apk add --no-cache \
        mailcap=2.1.53-r0 \
        python3=3.10.5-r0 \
        py3-pip=22.1.1-r0 \
    && apk add --no-cache --virtual api-build-deps build-base python3-dev=3.10.5-r0 \
    && pip3 install pipenv \
    && pipenv install --ignore-pipfile --system --deploy \
    && pip3 uninstall -y pipenv \
    && apk del api-build-deps

# Install npm dependencies and build Angular app
#
# 1. Install nodejs and npm as build dependencies
# 2. Install dependencies using npm
# 3. Build Angular app
# 7. Remove build dependencies
# 4. Clean up the htdocs directory
# 5. Move the Angular app to the htdocs directory
# 6. Clean the working directory. 
#    Neither the source nor the npm dependencies are needed during runtime.
WORKDIR /usr/src/ng
RUN apk update \
    && apk add --no-cache --virtual ng-build-deps \
        nodejs=16.16.0-r0 \
        npm=8.10.0-r0 \
    && npm install \
    && npm run build --omit=dev \
    && apk del ng-build-deps \
    && rm -rf ../api/htdocs/* \
    && mv ./dist/mv-tool-ng/* ../api/htdocs/ \
    && rm -rf ./*

WORKDIR /usr/src/api
COPY ./config.yml ./config.yml
ENTRYPOINT [ "uvicorn", "mvtool:app", "--host", "0.0.0.0", "--port", "8000",  "--proxy-headers" ]