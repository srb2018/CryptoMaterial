#!/bin/bash

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/ca-configurations/istc/ordererOrganizations/istc.com/orderers/orderer.istc.com/msp/tlscacerts/tlsca.istc.com-cert.pem
export PEER0_ORG1_CA=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/peers/peer0.istcorg1.istc.com/tls/ca.crt

function setGlobals() {
    if [ ! -z $1 ]; then
        ORG=$1
    else
        exit 1
    fi
    infoln "Using organization ${ORG}"

    if [ $ORG -eq 1 ]; then
        export CORE_PEER_LOCALMSPID="ISTCOrg1MSP"
        export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
        export CORE_PEER_MSPCONFIGPATH=${PWD}/ca-configurations/istc/peerOrganizations/istcorg1.istc.com/users/ISTCOrgAdmin@istcorg1.istc.com/msp
        export CORE_PEER_ADDRESS=localhost:7051
    else
        errorln "ORG Unknown"
    fi
}

function setGlobalsCLI() {
    setGlobals $1

    if [ ! -z $1 ]; then
        ORG=$1
    else
        exit 1
    fi

    if [ $ORG -eq 1 ]; then
        export CORE_PEER_ADDRESS=peer0.istcorg1.istc.com:7051
    else
        errorln "ORG Unknown"
    fi
}

function parsePeerConnectionParameters() {
    PEER_CONN_PARMS=""
    PEERS=""
    while [ "$#" -gt 0 ]; do
        setGlobals $1
        PEER="peer0.istcorg$1"
        ## Set peer addresses
        PEERS="$PEERS $PEER"
        PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
        ## Set path to TLS certificate
        TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
        PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
        # shift by one to get to the next organization
        shift
    done
    # remove leading space for output
    PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

function verifyResult() {
    if [ $1 -ne 0 ]; then
        fatalln "$2"
    fi
}
