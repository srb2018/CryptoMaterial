# ISTC Application

<!-- ## In Hyperledger Fabric we can create the certificate in two ways

- Cryptogen
- Fabric-CA

### Cryptogen

    cd ca-configurations
    ./createCryptogenCerts.sh

Following Shell scripit will created the certificate for network component and network user by using cryptogen

### Fabric-CA

    cd ca-configurations
    ./createFabricCACerts.sh up

 `To Down the Network`

    cd ca-configurations
    ./createFabricCACerts.sh down

Following Shell scripit will created the certificate for network component and network user by using Fabric-CA server and Fabric-CA Client -->

## Create the Network and Channel

    cd network
    ./networkUp.sh

## Deploy the chaincode

    cd network
    ./deployCC.sh

 `Down the Network and Channel`

    cd network
    ./networkDown.sh
