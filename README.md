# CA [Certificate Authority]

## In Hyperledger Fabric let we create the certificate in two ways

- Cryptogen
- Fabric-CA

### Cryptogen

    cd configurations
    ./createCryptogenCerts.sh

Following Shell scripit will created the certificate for network component and network user by using cryptogen

### Fabric-CA

    cd configurations
    ./createFabricCACerts.sh up

 `To Down the Network`

    cd configurations
    ./createFabricCACerts.sh down

Following Shell scripit will created the certificate for network component and network user by using Fabric-CA server and Fabric-CA Client
