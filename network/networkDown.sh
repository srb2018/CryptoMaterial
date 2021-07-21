COMPOSE_FILE_CA=ca-configurations/istc/caConfig/docker/docker-compose-ca.yaml
COMPOSE_FILE_BASE=docker/docker-compose.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml

docker-compose -f $COMPOSE_FILE_BASE -f $COMPOSE_FILE_COUCH -f $COMPOSE_FILE_CA down --volumes --remove-orphans
rm -rf ca-configurations/istc/caConfig/fabric-ca
rm -rf ca-configurations/istc/peerOrganizations
rm -rf ca-configurations/istc/ordererOrganizations
rm -rf istc-genesis-block
rm -rf channel-artifacts
rm -rf ISTC.tar.gz
rm -rf log.txt

