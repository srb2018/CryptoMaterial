#!/bin/bash
export FABRIC_CA_CLIENT_HOME=${PWD}/istc/caConfig/fabric-ca-client
CONFIG_YAML_LOC=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/msp/config.yaml
ORG_LOC=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com
TLS_SERVER_LOC=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com/peers/peer0.istcorg.istc.com/tls
TLS_LOC="E:/JAVA/BlockChain/Codebase/IstcProject/configurations/istc/caConfig/fabric-ca/istc/tls-cert.pem"

function createIstc() {
    echo "-->Creating directory"
    mkdir -p ${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com

    export FABRIC_CA_CLIENT_HOME=${PWD}/istc/caConfig/peerOrganizations/istcorg.istc.com

    echo "-->Enrolling the CA admin"
    fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-istc --tls.certfiles $TLS_LOC

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
        OrganizationalUnitIdentifier: orderer' > $CONFIG_YAML_LOC

    echo "-->Register Entity"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrg --id.secret ISTCOrgpw --id.type peer --id.attrs '"hf.Registrar.Roles=peer"' --tls.certfiles $TLS_LOC

    echo "-->Registering Admin"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrgadmin --id.secret ISTCOrgadminpw --id.type admin --id.attrs '"hf.Registrar.Roles=admin"' --tls.certfiles $TLS_LOC

    echo "-->Registering user"
    fabric-ca-client register --caname ca-istc --id.name ISTCOrguser1 --id.secret ISTCOrguser1pw --id.type client --id.attrs '"hf.Registrar.Roles=client"' --tls.certfiles $TLS_LOC

    echo "-->Enroll peer0"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $ORG_LOC/msp --csr.hosts peer0.istcorg.istc.com --tls.certfiles $TLS_LOC

    echo "-->Enroll Admin"
    fabric-ca-client enroll -u https://ISTCOrgadmin:ISTCOrgadminpw@localhost:7054 --caname ca-istc -M $ORG_LOC/users/ISTCOrgadmin@istcorg.istc.com --tls.certfiles $TLS_LOC

    echo "-->Enroll User"
    fabric-ca-client enroll -u https://ISTCOrguser1:ISTCOrguser1pw@localhost:7054 --caname ca-istc -M $ORG_LOC/users/ISTCOrguser1@istcorg.istc.com --tls.certfiles $TLS_LOC

    echo "--->enroll TLS server cert"
    fabric-ca-client enroll -u https://ISTCOrg:ISTCOrgpw@localhost:7054 --caname ca-istc -M $TLS_SERVER_LOC --enrollment.profile tls --csr.hosts peer0.istcorg.istc.com --csr.hosts localhost --tls.certfiles $TLS_LOC

}