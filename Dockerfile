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

FROM python:3.10.4-slim
SHELL ["/bin/bash", "-c"]
ENV LANG=en_US.UTF-8

# Install pip environment
RUN pip3 install --upgrade pip
RUN pip3 install pipenv

# Pre-installation
RUN apt update && apt upgrade -y && apt -y install wget xz-utils

# Install nodejs LTS from Linux binaries, see https://nodejs.org/en/download/
RUN wget https://nodejs.org/dist/v16.17.0/node-v16.17.0-linux-x64.tar.xz
RUN tar xf node-v16.17.0-linux-x64.tar.xz 
RUN cd node-v16.17.0-linux-x64 && cp -r ./{lib,share,include,bin} /usr
RUN rm node-v16.17.0-linux-x64.tar.xz && rm -rf node-v16.17.0-linux-x64

# Post-installation cleanup
RUN apt -y remove wget xz-utils && apt -y autoremove && apt clean && rm -rf /var/lib/apt/lists/*

# Copy mv-tool sources
WORKDIR /usr/src
COPY ./mv-tool-api ./mv-tool-api
COPY ./mv-tool-ng ./mv-tool-ng

# Set up and start mv-tool-api
WORKDIR /usr/src/mv-tool-api
RUN pipenv install --ignore-pipfile --system --deploy
RUN pip3 uninstall -y pipenv

# Set up mv-tool-ng
WORKDIR /usr/src/mv-tool-ng
RUN npm install
RUN npm run build --omit=dev

# Start mv-tool
WORKDIR /usr/src/mv-tool-api
COPY ./config.yml ./config.yml
EXPOSE 8000
ENTRYPOINT [ "uvicorn", "mvtool:app", "--port", "8000" ]