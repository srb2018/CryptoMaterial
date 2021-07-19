#!/bin/bash
# Imports
. scripts/envVar.sh
. scripts/configUpdate.sh
. scripts/utils.sh

function createAnchorPeerUpdate() {
    infoln "Fetching channel config for channel $CHANNEL_NAME"
    fetchChannelConfig $ORG $CHANNEL_NAME ${CORE_PEER_LOCALMSPID}config.json

    infoln "Generating anchor peer update transaction for ISTC Org${ORG} on channel $CHANNEL_NAME"

    if [ $ORG -eq 1 ]; then
        HOST="peer0.istcorg1.istc.com"
        PORT=7051
    else
        errorln "Org${ORG} unknown"
    fi

    set -x
    # Modify the configuration to append the anchor peer
    jq '.channel_group.groups.Application.groups.'${CORE_PEER_LOCALMSPID}'.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "'$HOST'","port": '$PORT'}]},"version": "0"}}' ${CORE_PEER_LOCALMSPID}config.json >${CORE_PEER_LOCALMSPID}modified_config.json
    { set +x; } 2>/dev/null

    # Compute a config update, based on the differences between
    # {orgmsp}config.json and {orgmsp}modified_config.json, write
    # it as a transaction to {orgmsp}anchors.tx
    createConfigUpdate ${CHANNEL_NAME} ${CORE_PEER_LOCALMSPID}config.json ${CORE_PEER_LOCALMSPID}modified_config.json ${CORE_PEER_LOCALMSPID}anchors.tx
}

function updateAnchorPeer() {
    peer channel update -o orderer.istc.com:7050 --ordererTLSHostnameOverride orderer.istc.com -c $CHANNEL_NAME -f ${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA
    res=$?
    verifyResult $res "Anchor peer update failed"
    successln "Anchor peer set for org '$CORE_PEER_LOCALMSPID' on channel '$CHANNEL_NAME'"
}

ORG=$1
CHANNEL_NAME=$2
setGlobalsCLI $ORG

createAnchorPeerUpdate

updateAnchorPeer
