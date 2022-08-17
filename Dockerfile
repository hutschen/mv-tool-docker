# Copyright 2022 Helmar Hutschenreuter
#
# The source code of this program is made available
# under the terms of the GNU Affero General Public License version 3
# (GNU AGPL V3) as published by the Free Software Foundation. You may obtain
# a copy of the GNU AGPL V3 at https://www.gnu.org/licenses/.
#
# In the case you use this program under the terms of the GNU AGPL V3,
# the program is provided in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU AGPL V3 for more details.

FROM debian:11-slim
ENV LANG=en_US.UTF-8

# Pre-installation
RUN apt update && apt upgrade -y
RUN apt install wget build-essential libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev -y

# Install Python from source, see https://www.python.org/downloads/
RUN wget https://www.python.org/ftp/python/3.10.4/Python-3.10.4.tgz
RUN tar xf Python-3.10.4.tgz && cd Python-3.10.4 && ./configure --enable-optimizations --with-lto && make && make install
RUN cd .. && rm Python-3.10.4.tgz && rm -rf Python-3.10.4

# Install pip environment
RUN pip3 install --upgrade pip
RUN pip3 install pipenv

# Install nodejs LTS from Linux binaries, see https://nodejs.org/en/download/
RUN wget https://nodejs.org/dist/v16.17.0/node-v16.17.0-linux-x64.tar.xz
SHELL ["/bin/bash", "-c"]
RUN tar xf node-v16.17.0-linux-x64.tar.xz && cd node-v16.17.0-linux-x64 && cp -r ./{lib,share,include,bin} /usr
RUN cd .. && rm node-v16.17.0-linux-x64.tar.xz && rm -rf node-v16.17.0-linux-x64

# Cleanup after installation
RUN apt remove -y wget build-essential libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev
RUN apt -y autoremove && apt clean && rm -rf /var/lib/apt/lists/*

# Copy MV-Tool sources
WORKDIR /usr/src
COPY ./mv-tool-api ./mv-tool-api
COPY ./mv-tool-ng ./mv-tool-ng

# Set up mv-tool-api
WORKDIR /usr/src/mv-tool-api

# Install dependencies
RUN pipenv install --ignore-pipfile --deploy

# # Set up mv-tool-ng
# WORKDIR /usr/src/mv-tool-ng