@echo off
setlocal

goto :%1

:build
    docker-compose build --no-cache app
    goto :eof

:up
    if not exist config.yml (copy config.example.yml config.yml)
    docker-compose up app -d
    goto :eof

:down
    docker-compose down
    goto :eof

:pytest
    if not exist config.yml (copy config.example.yml config.yml)
    docker compose up pytest
    docker compose down pytest
    goto :eof

:cleanup
    docker-compose down --volumes --rmi all
    goto :eof

:submodules-update
    git submodule update --init --recursive
    goto :eof

:eof
