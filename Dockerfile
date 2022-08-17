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

# Set up mv-tool-api
WORKDIR /usr/src/mv-tool-api
RUN pipenv install --ignore-pipfile --deploy

# Set up mv-tool-ng
WORKDIR /usr/src/mv-tool-ng
RUN npm install
RUN npm run build --prod