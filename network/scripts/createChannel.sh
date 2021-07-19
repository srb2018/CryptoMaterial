#!/bin/bash
# imports
. scripts/utils.sh
. scripts/envVar.sh

CHANNEL_NAME="$1"
DELAY="$2"
MAX_RETRY="$3"
VERBOSE="$4"

if [ ! -d "./channel-artifacts" ]; then
    mkdir ./channel-artifacts
fi

function createChannelTx() {
    set -x
    configtxgen -profile OneOrgsChannel -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
    res=$?
    { set +x; } 2>/dev/null
    verifyResult $res "Failed to generate channel configuration transaction..."
}

function createChannel() {
    setGlobals 1
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        set -x
        peer channel create -o localhost:7050 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.istc.com -f ./channel-artifacts/${CHANNEL_NAME}.tx --outputBlock $BLOCKFILE --tls --cafile $ORDERER_CA
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    verifyResult $res "Channel creation failed"
}

function joinChannel() {
    ORG=$1
    setGlobals $ORG
    local rc=1
    local COUNTER=1
    while [ $rc -ne 0 -a $COUNTER -lt $MAX_RETRY ]; do
        sleep $DELAY
        set -x
        peer channel join -b $BLOCKFILE
        res=$?
        { set +x; } 2>/dev/null
        let rc=$res
        COUNTER=$(expr $COUNTER + 1)
    done
    verifyResult $res "After $MAX_RETRY attempts, peer0.org${ORG} has failed to join channel '$CHANNEL_NAME' "
}

function setAnchorPeer() {
    ORG=$1
    set -x
    docker exec cli ./scripts/setAnchorPeer.sh $ORG $CHANNEL_NAME
    set +x
}

FABRIC_CFG_PATH=${PWD}/configtx
infoln "Generating channel create transaction '${CHANNEL_NAME}.tx'"
createChannelTx

FABRIC_CFG_PATH=${PWD}/../config/
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"

infoln "Creating channel ${CHANNEL_NAME}"
createChannel
successln "Channel '$CHANNEL_NAME' created"

infoln "Joining ISTC org1 peer to the channel..."
joinChannel 1

infoln "Setting anchor peer for ISTC org1..."
setAnchorPeer 1
