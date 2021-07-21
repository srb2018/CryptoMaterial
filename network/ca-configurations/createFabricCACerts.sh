COMPOSE_FILE_CA=ca-configurations/istc/caConfig/docker/docker-compose-ca.yaml
echo $COMPOSE_FILE_CA

if [[ $1 == 'up' ]]; then
    echo "Starting up Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA up -d
    source ./ca-configurations/istc/caConfig/registerEnroll.sh
    while :; do
        if [ ! -f "ca-configurations/istc/caConfig/fabric-ca/istc/tls-cert.pem" ]; then
            sleep 2
        else
            break
        fi
    done
    echo "Creating ISTC Org1 Identities"
    createIstc
    echo "Creating ISTC Orderer Identities"
    createOrdererIstc
elif [[ $1 == 'down' ]]; then
    echo "Shuting down Fabric CA services"
    docker-compose -f $COMPOSE_FILE_CA down
    rm -rf istc/caConfig/fabric-ca
    rm -rf istc/peerOrganizations
    rm -rf istc/ordererOrganizations
fi
