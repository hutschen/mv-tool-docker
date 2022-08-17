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

FROM python:3.10-slim
WORKDIR /usr/src/app

# Install dependencies from Pipfile first!
COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock
RUN ["pip3", "install", "--system", "--deploy"]

# Copy sources and register volume
COPY . .