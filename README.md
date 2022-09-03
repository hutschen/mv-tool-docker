# Docker Container for MV-Tool

MV-Tool is for tracking measures in information security. If information security is to be implemented according to [BSI IT Grundschutz](https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/IT-Grundschutz/IT-Grundschutz-Kompendium/it-grundschutz-kompendium_node.html) or another procedure or standard, many information security measures need to be implemented.

MV-Tool supports this process insofar as concrete implementation steps (measures) can be determined for each information security requirement. The implementation of these measures can later be tracked in an issue tracker. Currently, only JIRA by [Atlassian](https://www.atlassian.com/software/jira) is supported as issue tracker.

MV-Tool consists of two components, the [web API](https://github.com/hutschen/mv-tool-api) and the [web client](https://github.com/hutschen/mv-tool-ng). This repository contains the Docker setup you need to easily deploy MV-Tool.

If you want to make it easy, you can simply pull the Docker image from [Docker Hub](https://hub.docker.com/r/hutschen/mv-tool) instead of building it yourself. If you still want to build the MV-Tool image yourself, read the following sections of this readme.

## Clone the repository

**Attention**, there are submodules included in this repository. You should clone them together with this repository. This can be done with the following command:

```sh
git clone --recurse-submodules git@github.com:hutschen/mv-tool-docker.git
```

## Build the Docker image

To build the Docker image, first make sure [Docker](https://www.docker.com/) is installed on your system. Then, change to the root directory of this repository and run the following command:

```sh
docker image build -t hutschen/mv-tool .
```

## How to configure MV-Tool

Before you can run the MV-Tool in a Docker container, you have to configure it. This is done by a configuration file. This is very simple and contains only a few entries:

- The URL to your JIRA instance with which you want to use with the MV-Tool.
- The URL to the database (connect string).
- Optional logging configuration.

```yaml
jira:
  url: http://localhost:2990/jira
database:
  url: sqlite:///mvtool.db
uvicorn:
  log_level: error
  log_filename: mvtool.log
```

### Connection to JIRA

The connection to JIRA is mandatory for using the MV-Tool. The MV-Tool does not have its own user management, but uses that of the JIRA instance to which it is connected.

To connect to JIRA, simply specify the URL to your JIRA instance in the configuration file. For example, to access a JIRA instance that you have installed locally on your computer, the configuration might look like this:

```yaml
jira:
  url: http://localhost:2990/jira
```

#### Enable JSON API

Users log in to the MV-Tool with their JIRA credentials. The MV-Tool uses these credentials to authenticate with the JSON API of the JIRA instance via HTTP Basic Auth. To make this work, JSON API access must have been enabled in your JIRA instance. The credentials are not stored by the MV-Tool on the server side. The MV-Tool does not manage server-side user sessions. The user session is only managed on the client side.

If you use **JIRA as a cloud service**, you can only use HTTP Basic Auth in a limited way. Authentication is in this case not possible with your normal JIRA password. Instead of your password you have to use an access token. You need to generate this token in your JIRA user profile.

MV-Tool uses [jira-python](https://jira.readthedocs.io/) to access JIRA. For more information on authentication, see the [jira-python documentation](https://jira.readthedocs.io/examples.html#http-basic).

### Database connection

Only SQLite and PostgreSQL are currently supported as databases. You should use PostgreSQL if you want to use MV-Tool in production. MV-Tool is significantly slower with SQLite than with PostgreSQL. **SQLite is therefore not suitable in production**.

MV-Tool uses SQLAlchemy as the ORM mapper. The database URLs (connect strings) must therefore be specified so that SQLAlchemy understands them:

- For **SQLite** you can find the information about the structure of the connect string in the [SQLAlchemy Dokumentation](https://docs.sqlalchemy.org/en/14/dialects/sqlite.html#connect-strings).
- Connections to **PostgreSQL** databases are made using the [psycopg2](https://www.psycopg.org/) driver. You can also find the information about the connect string in the [SQLAlchemy Dokumentation](https://docs.sqlalchemy.org/en/14/dialects/postgresql.html#dialect-postgresql-psycopg2-connect).

A connection to a SQLite database file might look like the following in your configuration file:

```yaml
database:
  url: sqlite:///mvtool.db
```

The database file `mvtool.db` addressed in this example is created automatically if it does not exist. It is stored in the Docker container under `/usr/src/api/mvtool.db`.

### Logging

Logging is important so that bugs can be noticed and fixed in future versions of the MV-Tool. Therefore, you should set up logging and save log files outside the Docker container as well. Regarding logging, there are the following configuration options:

- **Log level** with the options `critical`, `error`, `warning`, `info`, `debug`, `trace` and the default value `error`.
- **Log Dateiname** with the default value `mvtool.log`.

The logging configuration may look like the following in your configuration file:

```yaml
uvicorn:
  log_level: error
  log_filename: mvtool.log
```

The log file is stored in the Docker container at `/usr/src/api/mvtool.log`. Contents of the log file are not deleted. New log entries are appended to an existing file.

## How to start up the Docker container
