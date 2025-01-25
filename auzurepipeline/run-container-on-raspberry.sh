#!/bin/bash
APP_NAME=sp-craft.notifier
DOCKER_IMAGE=lukasztomalczyk/$APP_NAME-arm64
CONTAINER_NAME=$APP_NAME-container
PORT_HOST=7003
PORT_CONTAINER=8083

# Sprawdzenie czy argument został podany
if [ $# -eq 0 ]; then
    echo "Brak argumentu. Użycie: $0 <environment>"
    exit 1
fi

# Przypisanie argumentu do zmiennej
ENVIRONMENT=$1

# Metoda wywołująca komendę docker-compose
function start_docker_compose {
    docker pull "$DOCKER_IMAGE:$ENVIRONMENT"
    docker stop $CONTAINER_NAME >/dev/null 2>&1
    docker rm -f $CONTAINER_NAME >/dev/null 2>&1
    docker run -d -it --rm --name $CONTAINER_NAME -p $PORT_HOST:$PORT_CONTAINER -v /home/lukas/$ENVIRONMENT/SpCraft.Notifier/appsettings.$ENVIRONMENT.json:/App/out/appsettings.$ENVIRONMENT.json -v "/home/lukas/$ENVIRONMENT/Certs/$APP_NAME.pfx:/App/out/Certs/$APP_NAME.pfx" -e ASPNETCORE_ENVIRONMENT=$ENVIRONMENT "$DOCKER_IMAGE:$ENVIRONMENT"
}

# Wywołanie funkcji
start_docker_compose
