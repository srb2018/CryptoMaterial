#!/bin/bash

COMPOSE_EXPLORER=docker-compose.yaml

function explorerUp() {
    filename=${PWD}/../network/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgAdmin@istcorg1.istc.com/msp/keystore/
    org1Keystore=$(basename $(ls $filename))
    echo "************************ Keystore Updated **************************"
    jq '.organizations.ISTCOrg1MSP.adminPrivateKey.path="/etc/data/peerOrganizations/istcorg1.istc.com/users/ISTCOrgAdmin@istcorg1.istc.com/msp/keystore/'${org1Keystore}'"' ./connection-profile/istc-network.json | sponge ./connection-profile/istc-network.json
    echo "************************ Docker Explorer Up ************************"
    docker-compose -f $COMPOSE_EXPLORER up -d
    echo "***************** Docker Explorer Completed ************************"
}

explorerUp
