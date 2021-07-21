export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/configtx
export VERBOSE=false

# Import's scripts
. scripts/utils.sh

CRYPTO="Certificate Authorities"
CHANNEL_NAME="teachannel"
COMPOSE_FILE_BASE=docker/docker-compose.yaml
COMPOSE_FILE_COUCH=docker/docker-compose-couch.yaml
DATABASE="couchdb"
CA_IMAGETAG="latest"
CLI_DELAY=3
MAX_RETRY=5

function checkPrereqs() {
    peer version

    if [[ $? -ne 0 || ! -d "../config" ]]; then
        errorln "Peer binary and configuration files not found.."
        errorln
        errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
        errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
        exit 1
    fi

    LOCAL_VERSION=$(peer version | sed -ne 's/ Version: //p')
    DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-tools:2.3 peer version | sed -ne 's/ Version: //p' | head -1)

    infoln "LOCAL_VERSION=$LOCAL_VERSION"
    infoln "DOCKER_IMAGE_VERSION=$DOCKER_IMAGE_VERSION"

    if [ "$LOCAL_VERSION" != "$DOCKER_IMAGE_VERSION" ]; then
        warnln "Local fabric binaries and docker images are out of sync. This may cause problems."
    fi

    ## Check for fabric-ca
    if [ "$CRYPTO" == "Certificate Authorities" ]; then
        fabric-ca-client version
        if [[ $? -ne 0 ]]; then
            errorln "fabric-ca-client binary not found.."
            errorln
            errorln "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
            errorln "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
            exit 1
        fi
        CA_LOCAL_VERSION=$(fabric-ca-client version | sed -ne 's/ Version: //p')
        CA_DOCKER_IMAGE_VERSION=$(docker run --rm hyperledger/fabric-ca:$CA_IMAGETAG fabric-ca-client version | sed -ne 's/ Version: //p' | head -1)
        infoln "CA_LOCAL_VERSION=$CA_LOCAL_VERSION"
        infoln "CA_DOCKER_IMAGE_VERSION=$CA_DOCKER_IMAGE_VERSION"

        if [ "$CA_LOCAL_VERSION" != "$CA_DOCKER_IMAGE_VERSION" ]; then
            warnln "Local fabric-ca binaries and docker images are out of sync. This may cause problems."
        fi
    fi
}

function createOrgs() {
    if [ -d "ca-configurations/istc/peerOrganizations" ]; then
        rm -Rf ca-configurations/istc/peerOrganizations && rm -Rf ca-configurations/istc/ordererOrganizations
    fi
    # Create the CA by crytogen
    if [ "$CRYPTO" == "cryptogen" ]; then
        which cryptogen
        if [ "$?" -ne 0 ]; then
            fatalln "cryptogen tool not found. exiting"
        fi
        ca-configurations/createCryptogenCerts.sh
    fi

    # Create the CA by Fabric-CA
    if [ "$CRYPTO" == "Certificate Authorities" ]; then
        ca-configurations/createFabricCACerts.sh up
    fi

    # Create (CCP) chaincode connection profile
    ./ccp/ccp-generate.sh
}

function createConsortium() {
    which configtxgen
    if [ "$?" -ne 0 ]; then
        fatalln "configtxgen tool not found."
    fi

    infoln "Generating Orderer Genesis block"

    #Generate orderer system channel genesis block.
    set -x
    configtxgen -profile OneOrgsOrdererGenesis -channelID istc-channel -outputBlock ./istc-genesis-block/istcGenesis.block
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        fatalln "Failed to generate orderer genesis block..."
    fi
}

function networkUp() {
    checkPrereqs
    # generate artifacts if they don't exist
    if [ ! -d "ca-configurations/istc/peerOrganizations" ]; then
        createOrgs
        createConsortium
    fi

    COMPOSE_FILES="-f ${COMPOSE_FILE_BASE}"

    if [ "$DATABASE" == "couchdb" ]; then
        COMPOSE_FILES="${COMPOSE_FILES} -f ${COMPOSE_FILE_COUCH}"
    fi

    IMAGE_TAG=$IMAGETAG docker-compose ${COMPOSE_FILES} up -d 2>&1

    # docker ps -a
    if [ $? -ne 0 ]; then
        fatalln "Unable to start network"
    fi
}

function createChannel() {
    if [ ! -d "ca-configurations/istc/peerOrganizations" ]; then
        infoln "Bringing up network"
        networkUp
    fi

    scripts/createChannel.sh $CHANNEL_NAME $CLI_DELAY $MAX_RETRY $VERBOSE

}

createChannel
# createOrgs
