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

FROM node:18.11.0-alpine3.16 AS ng_build
WORKDIR /usr/src/ng

# Install npm dependencies
COPY ./mv-tool-ng/package.json ./mv-tool-ng/package-lock.json ./
RUN npm clean-install

# Build Angular app
COPY ./mv-tool-ng ./
RUN npm run ng build --optimization


FROM python:3.10.8-alpine3.17
WORKDIR /usr/src/api

# Install dependencies for web API
# - upgrade openssl to temporarily fix https://security.snyk.io/vuln/SNYK-ALPINE317-OPENSSL-3188632
# - mailcap for inferring MIME types from file extensions
# - libpq is the PostgreSQL client library
# - build-deps, build-base for building Python C extensions
# - postgresql14-dev to build psycopg2 for PostgreSQL support
COPY ./mv-tool-api/Pipfile ./mv-tool-api/Pipfile.lock ./db-drivers.txt ./
RUN apk update \
    && apk add --no-cache "openssl>=3.0.7-r2" mailcap libpq \
    && apk add --no-cache --virtual build-deps build-base libpq-dev \
    && pip3 install pipenv \
    && pipenv install --ignore-pipfile --system --deploy \
    && pip3 uninstall -y pipenv \
    && pip3 install -r db-drivers.txt \
    && apk del build-deps \
    && rm Pipfile Pipfile.lock db-drivers.txt

# Copy API sources and Angular app build artifacts
COPY ./mv-tool-api ./
COPY --from=ng_build /usr/src/ng/dist/mv-tool-ng ./htdocs

ENTRYPOINT [ "python", "-u", "serve.py"]