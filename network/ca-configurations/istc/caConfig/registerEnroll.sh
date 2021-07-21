# imports 
source scripts/utils.sh

CONFIG_YAML_LOC=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/config.yaml
TLS_SERVER_LOC=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls
TLS_LOC_ISTC=${PWD}/ca-configurations/istc/caConfig/fabric-ca/istc/tls-cert.pem
ORG_LOC_ISTC=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com

function createIstc() {
    infoln "Enrolling the CA admin"
    mkdir -p ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com

    export FABRIC_CA_CLIENT_HOME=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/

    fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-istc --tls.certfiles $TLS_LOC_ISTC

    infoln "Register and Enroll Each Entity"
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

    infoln "<-- Register Entity -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrg --id.secret ISTCOrgpw --id.type peer --tls.certfiles $TLS_LOC_ISTC

    infoln "<-- Registering user -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrguser1 --id.secret ISTCOrguser1pw --id.type client --tls.certfiles $TLS_LOC_ISTC

    infoln "<-- Registering Admin -->"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrgadmin --id.secret ISTCOrgadminpw --id.type admin --tls.certfiles $TLS_LOC_ISTC

    infoln "<-- Generating the ISTCOrg msp -->"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $ORG_LOC_ISTC/msp --csr.hosts peer0.istcorg1.istc.com --tls.certfiles $TLS_LOC_ISTC

    # cp [Source] [Destination]
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/config.yaml ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/msp/config.yaml
    # *--------------------------------* #

    infoln "<-- Generating the ISTCOrg TLS certificates -->"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $TLS_SERVER_LOC --enrollment.profile tls --csr.hosts peer0.istcorg1.istc.com --csr.hosts localhost --tls.certfiles $TLS_LOC_ISTC

    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/ca.crt
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/signcerts/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/server.crt
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/keystore/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/server.key
    # *--------------------------------* # TLS cacerts
    mkdir -p ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/tlscacerts
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/tlscacerts/ca.crt
    # *--------------------------------* # TLS CA
    mkdir -p ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/tlsca
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/tlsca/tlsca.istcorg1.istc.com-cert.pem
    # *--------------------------------* # CA
    mkdir -p ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/ca
    cp -r ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/msp/cacerts/* ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/ca/ca.istcorg1.istc.com-cert.pem
    # *--------------------------------* #
    infoln "<-- Generating the User MSP -->"
    fabric-ca-client enroll -u https://ISTCOrguser1:ISTCOrguser1pw@localhost:7054 --caname ca-istc -M ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgUser1@istcorg1.istc.com/msp --tls.certfiles $TLS_LOC_ISTC
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/config.yaml ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgUser1@istcorg1.istc.com/msp/config.yaml
    # *--------------------------------* #
    infoln "<-- Generating the ISTCOrg Admin MSP -->"
    fabric-ca-client enroll -u https://ISTCOrgadmin:ISTCOrgadminpw@localhost:7054 --caname ca-istc -M ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgAdmin@istcorg1.istc.com/msp --tls.certfiles $TLS_LOC_ISTC
    cp ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/msp/config.yaml ${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgAdmin@istcorg1.istc.com/msp/config.yaml
}

function createOrdererIstc() {
    infoln "Enrolling the CA admin Orderer"
    mkdir -p ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com

    export FABRIC_CA_CLIENT_HOME=${PWD}/ca-configurations/istc/ordererOrganizations/istc.com

    fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

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
        OrganizationalUnitIdentifier: orderer' >${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/msp/config.yaml

    infoln "<--- Registering Orderer --->"
    fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    infoln "<--- Registering the Orderer Admin --->"
    fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    infoln "<--- Generating the Orderer MSP --->"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/msp --csr.hosts orderer.istc.com --csr.hosts localhost --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/msp/config.yaml ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/msp/config.yaml

    infoln "<--- Generating the orderer TLS certificates --->"
    fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls --enrollment.profile tls --csr.hosts orderer.istc.com --csr.hosts localhost --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/ca.crt
    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/signcerts/* ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/server.crt
    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/keystore/* ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/server.key

    mkdir -p ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/msp/tlscacerts
    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/msp/tlscacerts/tlsca.istc.com-cert.pem

    mkdir -p ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/msp/tlscacerts
    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/tls/tlscacerts/* ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/msp/tlscacerts/tlsca.istc.com-cert.pem

    infoln "<--- Generating the admin msp --->"
    fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/users/Admin@istc.com/msp --tls.certfiles ${PWD}/ca-configurations/istc/caConfig/fabric-ca/ordererOrg/tls-cert.pem

    cp ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/msp/config.yaml ${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/users/Admin@istc.com/msp/config.yaml

}
