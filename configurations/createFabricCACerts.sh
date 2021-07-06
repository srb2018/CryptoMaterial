export PATH=${PWD}/../bin:$PATH
COMPOSE_FILE_CA=${PWD}/istc/caConfig/docker/docker-compose-ca.yaml


if [[ $1 == 'up' ]]; then
    echo "Starting up Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA up -d
    source ./registerEnroll.Sh
    createIstc
elif [[ $1 == 'down' ]]; then
    echo "Shuting down Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA down
    rm -rf ${PWD}/istc/caConfig/fabric-ca
    rm -rf ${PWD}/istc/caConfig/peerOrganizations
fi