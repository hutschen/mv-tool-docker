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

FROM node:18.14.1-alpine3.17 AS ng_build
WORKDIR /usr/src/ng

# Install npm dependencies
COPY ./mv-tool-ng/package.json ./mv-tool-ng/package-lock.json ./
RUN npm clean-install

# Build Angular app
COPY ./mv-tool-ng ./
RUN npm run ng build --optimization


FROM python:3.11.5-alpine3.18
WORKDIR /usr/src/api

# Install dependencies for web API
# - mailcap for inferring MIME types from file extensions
# - libpq is the PostgreSQL client library
# - libstdc++ is needed for pandas
# - openldap-clients for LDAP support
# - build-deps, build-base for building Python C extensions
# - libpq-dev to build psycopg2 for PostgreSQL support
# - openldap-dev to build python-ldap for LDAP support
COPY ./mv-tool-api/Pipfile ./mv-tool-api/Pipfile.lock ./db-drivers.txt ./
RUN apk update \
    && apk add --no-cache mailcap libpq libstdc++ openldap-clients \
    && apk add --no-cache --virtual build-deps build-base libpq-dev openldap-dev \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir pipenv \
    && pipenv install --ignore-pipfile --system --deploy \
    && pip3 uninstall -y pipenv \
    && pip3 install --no-cache-dir -r db-drivers.txt \
    && apk del build-deps \
    && rm Pipfile Pipfile.lock db-drivers.txt \
    && rm -rf /var/cache/apk/*

# Copy API sources and Angular app build artifacts
COPY ./mv-tool-api ./
COPY --from=ng_build /usr/src/ng/dist/mv-tool-ng ./htdocs

ENTRYPOINT [ "python", "-u", "serve.py"]