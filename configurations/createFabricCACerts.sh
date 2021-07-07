# export PATH=${PWD}/../bin:$PATH
COMPOSE_FILE_CA=istc/caConfig/docker/docker-compose-ca.yaml
echo $COMPOSE_FILE_CA

if [[ $1 == 'up' ]]; then
    echo "Starting up Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA up -d
    source ./registerEnroll.sh
     while :; do
            if [ ! -f "istc/caConfig/fabric-ca/istc/tls-cert.pem" ]; then
                sleep 1
            else
                break
            fi
        done
    # createIstc
    createOrdererIstc
elif [[ $1 == 'down' ]]; then
    echo "Shuting down Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA down
    rm -rf istc/caConfig/fabric-ca
    rm -rf istc/caConfig/peerOrganizations
    rm -rf istc/caConfig/ordererOrganizations
fi