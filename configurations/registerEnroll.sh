# export FABRIC_CA_CLIENT_HOME=${PWD}/istc/caConfig/fabric-ca-client
CONFIG_YAML_LOC=istc/caConfig/peerOrganizations/istcorg.istc.com/msp/config.yaml
TLS_SERVER_LOC=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls
TLS_LOC_ISTC=${PWD}/istc/caConfig/fabric-ca/istc/tls-cert.pem
ORG_LOC_ISTC=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com

function createIstc() {
    echo "Enrolling the CA admin"
    mkdir -p istc/caConfig/peerOrganizations/istcorg.istc.com

    export FABRIC_CA_CLIENT_HOME=istc/caConfig/peerOrganizations/istcorg.istc.com/

    fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-istc --tls.certfiles $TLS_LOC_ISTC

    echo "Register and Enroll Each Entity"
    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-istc.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-istc.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-istc.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-7054-ca-istc.pem
        OrganizationalUnitIdentifier: orderer' >$CONFIG_YAML_LOC

    echo "<-- Register Entity -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrg --id.secret ISTCOrgpw --id.type peer --tls.certfiles $TLS_LOC_ISTC

    echo "<-- Registering user -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrguser1 --id.secret ISTCOrguser1pw --id.type client --tls.certfiles $TLS_LOC_ISTC

    echo "<-- Registering Admin -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrgadmin --id.secret ISTCOrgadminpw --id.type admin --tls.certfiles $TLS_LOC_ISTC

    echo "<-- Generating the ISTCOrg msp -->"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $ORG_LOC_ISTC/msp --csr.hosts peer0.istcorg.istc.com --tls.certfiles $TLS_LOC_ISTC

    # cp [Source] [Destination]
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/msp/config.yaml ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/msp/config.yaml
    # *--------------------------------* #

    echo "<-- Generating the ISTCOrg TLS certificates -->"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $TLS_SERVER_LOC --enrollment.profile tls --csr.hosts peer0.istcorg.istc.com --csr.hosts localhost --tls.certfiles $TLS_LOC_ISTC

    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/ca.crt
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/signcerts/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/server.crt
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/keystore/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/server.key
    # *--------------------------------* # TLS cacerts
    mkdir -p istc/caConfig/peerOrganizations/istcorg.istc.com/msp/tlscacerts
    sleep 5
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/msp/tlscacerts/ca.crt
    # *--------------------------------* # TLS CA
    mkdir -p istc/caConfig/peerOrganizations/istcorg.istc.com/tlsca
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/tlsca/tlsca.istcorg.istc.com-cert.pem
    # *--------------------------------* # CA
    mkdir -p istc/caConfig/peerOrganizations/istcorg.istc.com/ca
    cp -r ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/msp/cacerts/* ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/ca/ca.istcorg.istc.com-cert.pem
    # *--------------------------------* #
    echo "<-- Generating the User MSP -->"
    fabric-ca-client enroll -u https://ISTCOrguser1:ISTCOrguser1pw@localhost:7054 --caname ca-istc -M ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/users/ISTCOrguser1@istcorg.istc.com/msp --tls.certfiles $TLS_LOC_ISTC
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/msp/config.yaml ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/users/ISTCOrguser1@istcorg.istc.com/msp/config.yaml
    # *--------------------------------* #
    echo "<-- Generating the ISTCOrg Admin MSP -->"
    fabric-ca-client enroll -u https://ISTCOrgadmin:ISTCOrgadminpw@localhost:7054 --caname ca-istc -M ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/users/ISTCOrgadmin@istcorg.istc.com/msp --tls.certfiles $TLS_LOC_ISTC
    cp ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/msp/config.yaml ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/users/ISTCOrgadmin@istcorg.istc.com/msp/config.yaml
}

function createOrdererIstc() {
    echo "Enrolling the CA admin Orderer"
    mkdir -p istc/caConfig/ordererOrganizations/istcorderer.istc.com

    export FABRIC_CA_CLIENT_HOME=${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com

    fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    echo 'NodeOUs:
    Enable: true
    ClientOUIdentifier:
        Certificate: cacerts/localhost-9054-ca-orderer.pem
        OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
        Certificate: cacerts/localhost-9054-ca-orderer.pem
        OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
        Certificate: cacerts/localhost-9054-ca-orderer.pem
        OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
        Certificate: cacerts/localhost-9054-ca-orderer.pem
        OrganizationalUnitIdentifier: orderer' >${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/msp/config.yaml

    echo "<--- Registering Orderer --->"
    fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    echo "<--- Registering the Orderer Admin --->"
    fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    echo "<--- Generating the Orderer MSP --->"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/msp --csr.hosts orderer.istc.com --csr.hosts localhost --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/msp/config.yaml ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/msp/config.yaml

    echo "<--- Generating the orderer TLS certificates --->"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls --enrollment.profile tls --csr.hosts orderer.istc.com --csr.hosts localhost --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/ca.crt
    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/signcerts/* ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/server.crt
    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/keystore/* ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/server.key

    mkdir -p ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/msp/tlscacerts
    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/msp/tlscacerts/tlsca.example.com-cert.pem

    mkdir -p ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/msp/tlscacerts
    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/msp/tlscacerts/tlsca.example.com-cert.pem

    echo "<--- Generating the admin msp --->"
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/users/Admin@example.com/msp --tls.certfiles ${PWD}/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/msp/config.yaml ${PWD}/istc/caConfig/ordererOrganizations/istcorderer.istc.com/users/Admin@example.com/msp/config.yaml

}
